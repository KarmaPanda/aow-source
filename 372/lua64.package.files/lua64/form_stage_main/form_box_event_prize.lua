require("util_gui")
require("tips_data")
require("util_functions")
require("util_static_data")
require("share\\itemtype_define")
local FORM_EVENT_PRIZE = "form_stage_main\\form_box_event_prize"
local FORM_NEW_ORIGIN = "form_stage_main\\form_origin_new\\form_new_origin_main"
local PHOTO_ORIGIN = "gui\\language\\ChineseS\\origin\\origin\\donghai\\xiakedao\\wushenfen.png"
local REC_EVENT_PRIZE = "rec_box_event_prize"
local GRID_COUNT = 3
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_size(form)
  return 1
end
function on_main_form_close(form)
  nx_execute("custom_sender", "custom_box_event", nx_int(1), nx_int(1))
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 10
  form.Top = (gui.Height - form.Height) / 2
end
function set_form_data(form, event_id, origin_list, exp_value)
  local event = util_text("box_event_" .. nx_string(event_id))
  form.lbl_event.HtmlText = util_format_string("box_event_title", nx_string(event))
  if nx_number(0) >= nx_number(exp_value) then
    form.lbl_exp.Visible = false
  else
    form.lbl_exp.Visible = true
    form.lbl_exp.HtmlText = util_format_string("box_event_jinyan", exp_value)
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local grid = form.grid_item
  goods_grid:GridClear(grid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord(REC_EVENT_PRIZE) then
  end
  local rows = player:GetRecordRows(REC_EVENT_PRIZE)
  if nx_int(rows) <= nx_int(0) then
  end
  local count = GRID_COUNT
  count = math.min(count, rows)
  count = math.max(count, 0)
  for i = 0, count - 1 do
    local item_id = player:QueryRecord(REC_EVENT_PRIZE, i, 0)
    local item_count = player:QueryRecord(REC_EVENT_PRIZE, i, 1)
    local item_type = nx_number(get_prop_in_ItemQuery(item_id, nx_string("ItemType")))
    local item_data = nx_create("ArrayList", nx_current())
    if not nx_is_valid(item_data) then
      return
    end
    item_data.ConfigID = item_id
    item_data.Count = item_count
    item_data.item_type = item_type
    goods_grid:GridAddItem(grid, i, item_data)
    grid:SetBindIndex(i, i + 1)
    local photo = ""
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      photo = item_query_ArtPack_by_id(item_id, "Photo")
    else
      photo = get_prop_in_ItemQuery(item_id, nx_string("Photo"))
    end
    grid:AddItem(i, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  end
  local btn_origin = {
    form.btn_origin_1,
    form.btn_origin_2,
    form.btn_origin_3
  }
  for i = 1, GRID_COUNT do
    btn_origin[i].NormalImage = PHOTO_ORIGIN
    btn_origin[i].FocusImage = PHOTO_ORIGIN
    btn_origin[i].PushImage = PHOTO_ORIGIN
    btn_origin[i].origin_id = -1
  end
  local origin_count = table.getn(origin_list)
  origin_count = math.min(origin_count, GRID_COUNT)
  origin_count = math.max(origin_count, 0)
  for i = 1, nx_number(origin_count) do
    local origin_id = nx_number(origin_list[i])
    set_origin_btn(btn_origin[i], origin_id)
  end
end
function set_origin_btn(btn, origin_id)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local data = origin_manager:GetOriginInfo(origin_id)
  local count = table.getn(data)
  if nx_number(count) < nx_number(6) then
    return
  end
  local image = ""
  if origin_manager:IsCompletedOrigin(origin_id) then
    image = data[6]
  elseif origin_manager:IsActiveOrigin(origin_id) then
    image = data[4]
  else
    image = data[5]
  end
  btn.NormalImage = image
  btn.FocusImage = image
  btn.PushImage = image
  btn.origin_id = origin_id
end
function on_grid_item_mousein_grid(grid, index)
  local item_id = grid:GetItemName(nx_int(index))
  if nx_string("") == nx_string(item_id) then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local item_type = item_query:GetItemPropByConfigID(item_id, "ItemType")
  nx_execute("tips_game", "show_tips_common", item_id, nx_number(item_type), x, y, grid.ParentForm)
end
function on_grid_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_pick_bag_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_box_event", nx_int(1), nx_int(0))
  form:Close()
end
function on_btn_pick_mail_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_box_event", nx_int(1), nx_int(1))
  form:Close()
end
function on_server_msg(...)
  if nx_int(table.getn(arg)) < nx_int(1) then
    return
  end
  local sub_msg = arg[1]
  if nx_number(1) == nx_number(sub_msg) then
    if nx_int(table.getn(arg)) < nx_int(4) then
      return
    end
    local event_id = arg[2]
    local origin = arg[3]
    local origin_list = util_split_string(origin, ",")
    local exp_value = arg[4]
    local form = util_show_form(FORM_EVENT_PRIZE, true)
    if not nx_is_valid(form) then
      return
    end
    set_form_data(form, event_id, origin_list, exp_value)
  end
end
function on_btn_origin_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local id = btn.origin_id
  if nx_number(id) < nx_number(0) then
    return
  end
  nx_execute(FORM_NEW_ORIGIN, "open_origin_desc_form_by_id", id)
end
