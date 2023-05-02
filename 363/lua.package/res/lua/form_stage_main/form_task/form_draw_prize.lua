require("util_gui")
require("util_functions")
CLIENT_SUB_DRAW_PRIZE_OPEN = 0
CLIENT_SUB_DRAW_PRIZE_BEGIN = 1
SERVER_SUB_DRAW_PRIZE_OPEN = 0
SERVER_SUB_DRAW_PRIZE_INDEX = 1
local MAX_ITEM_COUNT = 20
local FORM_DRAW = "form_stage_main\\form_task\\form_draw_prize"
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  self.min_loop = 0
  self.box_frame.select_index = -1
  self.box_frame.cur_loop = 0
  nx_execute("custom_sender", "custom_draw_prize", CLIENT_SUB_DRAW_PRIZE_OPEN)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_server_msg(sub_msg, ...)
  local form = nx_value(FORM_DRAW)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_msg) == nx_int(SERVER_SUB_DRAW_PRIZE_OPEN) then
    local min_loop = nx_int(arg[1])
    table.remove(arg, 1)
    on_refresh_prize_item(form, min_loop, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SERVER_SUB_DRAW_PRIZE_INDEX) then
    on_play_effect(form, nx_int(arg[1]))
  end
end
function on_refresh_prize_item(form, min_loop, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  form.min_loop = min_loop
  for i = 1, table.getn(arg) do
    local item_config = arg[i]
    local item_box = clone_control(form, "item_box", i - 1)
    form.box_frame:Add(item_box)
    item_box.Visible = true
    local aid = item_box.aid
    set_item_box_pos(form, item_box)
    local child_name = string.format("%s_%s", nx_string("lbl_select"), nx_string(aid))
    local lbl_select = item_box:Find(child_name)
    if form.box_frame.select_index == aid then
      lbl_select.Visible = true
    else
      lbl_select.Visible = false
    end
    child_name = string.format("%s_%s", nx_string("lbl_prize"), nx_string(aid))
    local lbl_prize = item_box:Find(child_name)
    lbl_prize.Text = nx_widestr(gui.TextManager:GetText(item_config))
    child_name = string.format("%s_%s", nx_string("imagegrid_prize"), nx_string(aid))
    local imagegrid = item_box:Find(child_name)
    nx_bind_script(imagegrid, nx_current())
    nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_prize_mousein_grid")
    nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_prize_mouseout_grid")
    add_imagegrid_item(imagegrid, item_config)
  end
end
function set_item_box_pos(form, item_box)
  local aid = item_box.aid
  item_box.Left = nx_int(aid % 4) * item_box.Width
  item_box.Top = nx_int(aid / 4) * item_box.Height
end
function add_imagegrid_item(imagegrid, prize)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  imagegrid:Clear()
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(prize), "Photo")
  imagegrid:AddItem(0, photo, nx_widestr(prize), 1, 0)
end
function on_imagegrid_prize_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function clone_control(form, control_name, aid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local control = nx_custom(form, nx_string(control_name))
  local new_control = gui.Designer:Clone(control)
  if not nx_is_valid(new_control) then
    return nx_null()
  end
  nx_bind_script(new_control, nx_current())
  new_control.DesignMode = false
  new_control.Name = string.format("%s_%s", nx_string(control_name), nx_string(aid))
  new_control.Visible = true
  new_control.aid = aid
  local child_list = control:GetChildControlList()
  for _, child_control in pairs(child_list) do
    if nx_is_valid(child_control) then
      local new_child = gui.Designer:Clone(child_control)
      new_child.fatherctl = new_control
      new_child.DesignMode = false
      new_child.Name = string.format("%s_%s", nx_string(child_control.Name), nx_string(aid))
      new_child.aid = aid
      new_control:Add(new_child)
    end
  end
  return new_control
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_type = grid:GetItemMark(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  if nx_number(prize_type) == 1 then
    local tip_text = nx_widestr(util_text(nx_string(prize_id)) .. ":" .. nx_string(prize_count))
    nx_execute("tips_game", "show_text_tip", tip_text, x, y)
  elseif nx_number(prize_type) == 2 then
    local tip_text = nx_widestr(prize_id)
    nx_execute("tips_game", "show_text_tip", tip_text, x, y)
  elseif nx_number(prize_type) == 0 then
    local itemmap = nx_value("ItemQuery")
    if not nx_is_valid(itemmap) then
      return
    end
    local table_prop_name = {}
    local table_prop_value = {}
    table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
    if 0 >= table.getn(table_prop_name) then
      return
    end
    table_prop_value.ConfigID = nx_string(prize_id)
    for count = 1, table.getn(table_prop_name) do
      local prop_name = table_prop_name[count]
      local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
      table_prop_value[prop_name] = prop_value
    end
    local staticdatamgr = nx_value("data_query_manager")
    if nx_is_valid(staticdatamgr) then
      local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
      local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
      if nx_string(photo) ~= "" and photo ~= nil then
        table_prop_value.Photo = photo
      end
    end
    if nx_is_valid(grid.Data) then
      nx_destroy(grid.Data)
    end
    grid.Data = nx_create("ArrayList", "task_grid_data")
    grid.Data:ClearChild()
    for prop, value in pairs(table_prop_value) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_set_custom(grid.Data, "is_static", true)
    nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
    grid.Data:ClearChild()
  end
end
function on_btn_begin_click(btn)
  nx_execute("custom_sender", "custom_draw_prize", CLIENT_SUB_DRAW_PRIZE_BEGIN)
end
function on_play_effect(form, index)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(index) < nx_int(0) or nx_int(index) >= nx_int(MAX_ITEM_COUNT) then
    return
  end
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if common_execute:FindExecute("DrawPrizeIndexMove", form.box_frame) then
    return
  end
  common_execute:AddExecute("DrawPrizeIndexMove", form.box_frame, nx_float(0.08), nx_int(form.min_loop), nx_int(MAX_ITEM_COUNT), nx_int(index), "")
end
function on_play_effect_2(result)
  local form = nx_value(FORM_DRAW)
  if not nx_is_valid(form) then
    return
  end
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if common_execute:FindExecute("ExecuteDrawPrizeSlowdownMove", form.box_frame) then
    return
  end
  common_execute:AddExecute("ExecuteDrawPrizeSlowdownMove", form.box_frame, nx_float(0.3), nx_int(result))
end
function refresh_box(index)
  local form = nx_value(FORM_DRAW)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, MAX_ITEM_COUNT do
    local child_name = string.format("%s_%s", nx_string("item_box"), nx_string(i - 1))
    local item_box = form.box_frame:Find(child_name)
    if nx_is_valid(item_box) then
      child_name = string.format("%s_%s", nx_string("lbl_select"), nx_string(i - 1))
      local lbl_select = item_box:Find(child_name)
      lbl_select.Visible = false
    end
  end
  local child_name = string.format("%s_%s", nx_string("item_box"), nx_string(index))
  local item_box = form.box_frame:Find(child_name)
  if nx_is_valid(item_box) then
    child_name = string.format("%s_%s", nx_string("lbl_select"), nx_string(index))
    local lbl_select = item_box:Find(child_name)
    lbl_select.Visible = true
  end
end
