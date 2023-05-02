require("util_gui")
require("util_functions")
require("game_object")
require("util_static_data")
require("define\\tip_define")
require("share\\view_define")
require("share\\capital_define")
local MAX_DROP_BOX_CAPACITY = 16
local color_lst = global_color_list
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_window_position(form)
  form.icg_items.typeid = VIEWPORT_BOX_CHOICES
  form.icg_items.beginindex = 1
  form.icg_items.endindex = MAX_DROP_BOX_CAPACITY
  form.icg_items.Data = nx_create("ArrayList", nx_current())
  form.icg_items:Clear()
  local grid_index = 0
  for view_index = form.icg_items.beginindex, form.icg_items.endindex do
    form.icg_items:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_BOX_CHOICES, form, nx_current(), "on_dropbox_viewport_change")
  end
  form.nCurrentIndex = -1
end
function on_dropbox_viewport_change(form, optype, view_ident, index)
  if optype == "additem" then
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_BOX_CHOICES))
    if not nx_is_valid(view) then
      return
    end
    local viewobjlist = view:GetViewObjList()
    form.icg_items.RowNum = 4
    for pos = table.getn(viewobjlist), 1, -1 do
      local obj = view:GetViewObj(nx_string(pos))
      if nx_is_valid(obj) then
        reset_list_item(form, pos, obj)
        break
      end
    end
  end
end
function on_main_form_close(form)
  if nx_is_valid(form.icg_items.Data) then
    nx_destroy(form.icg_items.Data)
  end
  if form.icg_items.Capture == true then
    nx_execute("tips_game", "hide_tip", form)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
  nx_execute("custom_sender", "custom_choice", 1)
end
function on_icg_items_mousein_grid(grid, index)
  local form = grid.ParentForm
  show_normal_tips(grid, index + 1)
end
function on_icg_items_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_pick_click(btn)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local form = btn.ParentForm
  if form.nCurrentIndex < 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 1, nx_string("formpickNoChoices"))
    return
  end
  nx_execute("custom_sender", "custom_choice", 2, form.nCurrentIndex + 1)
end
function on_icg_items_select_changed(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local form = grid.ParentForm
  form.nCurrentIndex = index
end
function reset_list_item(form, pos, viewobj)
  local gui = nx_value("gui")
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local item_config = viewobj:QueryProp("ConfigID")
  local item_count = viewobj:QueryProp("Amount")
  local item_equip_type = viewobj:QueryProp("EquipType")
  local item_color_level = viewobj:QueryProp("ColorLevel")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_name = gui.TextManager:GetText(item_config)
  local base_name = nx_widestr(tips_manager:GetItemBaseName(viewobj))
  if not nx_ws_equal(base_name, nx_widestr("")) then
    item_name = base_name
  end
  local item_photo = nx_execute("util_static_data", "query_equip_photo_by_sex", viewobj)
  if nil == item_photo or "" == item_photo then
    item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
  end
  if nx_number(item_color_level) < 1 or nx_number(item_color_level) > 6 then
    item_color_level = 1
  end
  local item_back_image = get_grid_treasure_back_image(item_equip_type, item_color_level)
  form.icg_items:AddItemEx(nx_int(pos) - 1, nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0), nx_string(item_back_image))
  local tee = nx_widestr("<font color=\"") .. nx_widestr(color_lst[nx_number(item_color_level)]) .. nx_widestr("\">") .. nx_widestr(item_name) .. nx_widestr("</font>")
  form.icg_items:SetItemInfo(nx_int(pos) - 1, tee)
end
function show_normal_tips(grid, index)
  local form = grid.ParentForm
  local nrealindex = index
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BOX_CHOICES))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(nrealindex))
  if not nx_is_valid(viewobj) then
    return
  end
  grid.view_obj = viewobj
  if nx_is_valid(grid.Data) then
    nx_execute("tips_game", "show_goods_tip", grid.view_obj, grid:GetMouseInItemLeft() + grid.GridOffsetX, grid:GetMouseInItemTop() + grid.GridOffsetY, 32, 32, form)
  end
end
function set_window_position(form)
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  local key = util_get_property_key(game_config_info, "pick_position", 1)
  if nx_int(key) == nx_int(0) then
    local x, y = gui:GetCursorPosition()
    x = x + 32
    y = y + 32
    if x + form.Width > gui.Width then
      x = x - 32
      x = x - form.Width
    end
    if y + form.Height > gui.Height then
      if y > form.Height then
        y = y - 32
        y = y - form.Height
      else
        y = gui.Height - form.Height
      end
    end
    form.AbsLeft = x
    form.AbsTop = y
  else
    form.AbsLeft = (gui.Width - form.Width) * 7 / 10
    form.AbsTop = (gui.Height - form.Height) / 2
  end
end
