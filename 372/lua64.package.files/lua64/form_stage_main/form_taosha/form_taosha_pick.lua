require("util_gui")
require("util_functions")
require("game_object")
require("util_static_data")
require("define\\tip_define")
require("share\\view_define")
require("share\\capital_define")
local FORM_TAOSHA_PICK = "form_stage_main\\form_taosha\\form_taosha_pick"
local FORM_TEAM_ASSIGN = "form_stage_main\\form_team\\form_team_assign"
local FORM_ITEMBIND_MANAGER = "form_stage_main\\form_itembind\\form_itembind_manager"
local DATAOSHA_MAX_DROP_BOX_CAPACITY = 100
local color_lst = {
  "#C95851",
  "#98A0CD",
  "#BA9772",
  "#999999",
  "#E9C050",
  "#A3CA44",
  "#82AB23"
}
function main_form_init(form)
  form.Fixed = false
  form.nMaxIndexCount = 0
  form.VScrollBarValue = 0
  return 1
end
function on_main_form_open(form)
  set_window_position(form)
  form.icg_items.typeid = VIEWPORT_DROP_BOX
  form.icg_items.beginindex = 1
  form.icg_items.endindex = DATAOSHA_MAX_DROP_BOX_CAPACITY
  local grid_index = 0
  for view_index = form.icg_items.beginindex, form.icg_items.endindex do
    form.icg_items:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_DROP_BOX, form, nx_current(), "on_dropbox_viewport_change")
  end
  on_dropbox_viewport_change(form, 0, VIEWPORT_DROP_BOX, 0)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  if form.icg_items.Capture == true then
    nx_execute("tips_game", "hide_tip", form)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  nx_destroy(form)
  local form_team_assign = nx_value(FORM_TEAM_ASSIGN)
  if nx_is_valid(form_team_assign) then
    form_team_assign:Close()
  end
end
function on_btn_close_click(btn)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
  if not nx_is_valid(view) then
    return 1
  end
  local drop_type = view:QueryProp("DropType")
  if 1 == drop_type then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr("@ui_diuqi"))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if "ok" ~= res then
      return 1
    end
  end
  nx_execute("custom_sender", "custom_close_drop_box")
  return 1
end
function on_icg_items_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  grid.view_obj = viewobj
  nx_execute("tips_game", "show_goods_tip", grid.view_obj, grid:GetMouseInItemLeft() + grid.GridOffsetX, grid:GetMouseInItemTop() + grid.GridOffsetY, 32, 32, form)
end
function on_icg_items_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_pick_all_click(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.nMaxIndexCount) == nx_int(0) then
    nx_execute("custom_sender", "custom_close_drop_box")
    return
  end
  nx_execute("form_stage_main\\form_bag", "clear_select_items")
  for i = form.nMaxIndexCount, 1, -1 do
    local b_need_bind = nx_execute(FORM_ITEMBIND_MANAGER, "drop_itemobj_need_bind", VIEWPORT_DROP_BOX, nx_int(i))
    if b_need_bind then
      local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
      if nx_is_valid(view) then
        local viewobj = view:GetViewObj(nx_string(i))
        if nx_is_valid(viewobj) then
          gui.TextManager:Format_SetIDName("1313")
          local configid = viewobj:QueryProp("ConfigID")
          gui.TextManager:Format_AddParam(nx_string(configid))
          local content = gui.TextManager:Format_GetText()
          local res, dialog = util_form_confirm(title, content, MB_OKCANCEL, true)
          if res == "ok" then
            nx_execute("custom_sender", "custom_pickup_single_item", i)
            dialog:Close()
          end
        end
      end
    else
      nx_execute("custom_sender", "custom_pickup_single_item", i)
    end
  end
  if nx_is_valid(form) then
    form.VScrollBarValue = form.icg_items.VScrollBar.Value
  end
end
function on_icg_items_select_changed(grid, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local nrealindex = index + 1
  nx_execute("form_stage_main\\form_bag", "clear_select_items")
  local b_need_bind = nx_execute(FORM_ITEMBIND_MANAGER, "drop_itemobj_need_bind", VIEWPORT_DROP_BOX, nx_int(nrealindex))
  if b_need_bind then
    local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
    if nx_is_valid(view) then
      local viewobj = view:GetViewObj(nx_string(nrealindex))
      if nx_is_valid(viewobj) then
        gui.TextManager:Format_SetIDName("1313")
        local configid = viewobj:QueryProp("ConfigID")
        gui.TextManager:Format_AddParam(nx_string(configid))
        local content = gui.TextManager:Format_GetText()
        local res = util_form_confirm(title, content, MB_OKCANCEL, true)
        if res == "ok" then
          nx_execute("custom_sender", "custom_pickup_single_item", nrealindex)
        end
      end
    end
  else
    nx_execute("custom_sender", "custom_pickup_single_item", nrealindex)
  end
  local form = nx_value(FORM_TAOSHA_PICK)
  if nx_is_valid(form) then
    form.VScrollBarValue = form.icg_items.VScrollBar.Value
  end
end
function on_dropbox_viewport_change(form, optype, view_ident, index)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_handle_viewport_change", form)
    timer:Register(100, 1, nx_current(), "on_handle_viewport_change", form, -1, -1)
  end
end
function on_handle_viewport_change(form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
  if not nx_is_valid(view) then
    return 1
  end
  form.nMaxIndexCount = get_viewport_valid_item_type_cout(view)
  fresh_viewport_item_to_list(form, view)
end
function get_viewport_valid_item_type_cout(view)
  local max_index = 0
  if not nx_is_valid(view) then
    return max_index
  end
  for i = DATAOSHA_MAX_DROP_BOX_CAPACITY, 1, -1 do
    local obj = view:GetViewObj(nx_string(i))
    if nx_is_valid(obj) then
      max_index = i
      break
    end
  end
  return max_index
end
function fresh_viewport_item_to_list(form, view)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(view) then
    return
  end
  form.icg_items:Clear()
  for i = 1, form.nMaxIndexCount do
    local viewobj = view:GetViewObj(nx_string(i))
    if nx_is_valid(viewobj) then
      reset_list_item(form, i - 1, true, viewobj)
    else
      reset_list_item(form, i - 1, false, viewobj)
    end
  end
end
function reset_list_item(form, pos, bshow, viewobj)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  form.icg_items:DelItem(nx_int(pos))
  if bshow then
    local item_config = viewobj:QueryProp("ConfigID")
    local item_count = viewobj:QueryProp("Amount")
    local item_equip_type = viewobj:QueryProp("EquipType")
    local item_color_level = viewobj:QueryProp("ColorLevel")
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == false then
      return
    end
    local item_name = nx_widestr("")
    if nx_string(item_equip_type) == nx_string("NewTreasure") then
      local suit_id = viewobj:QueryProp("TersureSuitID")
      if 0 < suit_id and suit_id <= 10 then
        item_name_1 = gui.TextManager:GetText("desc_newtreasure_combination_" .. suit_id)
        item_name_2 = gui.TextManager:GetText(item_config)
        item_name = nx_widestr(item_name_1) .. nx_widestr(item_name_2)
      else
        item_name = gui.TextManager:GetText(item_config)
      end
    else
      local base_name = nx_widestr(tips_manager:GetItemBaseName(viewobj))
      item_name = gui.TextManager:GetText(item_config)
      if not nx_ws_equal(base_name, nx_widestr("")) then
        item_name = base_name
      end
    end
    local item_photo = nx_execute("util_static_data", "query_equip_photo_by_sex", viewobj)
    if nil == item_photo or "" == item_photo then
      item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
    end
    if nx_number(item_color_level) < 1 or nx_number(item_color_level) > 6 then
      item_color_level = 1
    end
    local item_back_image = get_grid_treasure_back_image(item_equip_type, item_color_level)
    form.icg_items:AddItemEx(nx_int(pos), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0), nx_string(item_back_image))
    local tee = nx_widestr("<font color=\"") .. nx_widestr(color_lst[nx_number(item_color_level)]) .. nx_widestr("\">") .. nx_widestr(item_name) .. nx_widestr("</font>")
    form.icg_items:SetItemInfo(nx_int(pos), tee)
  end
  if form.VScrollBarValue > form.icg_items.VScrollBar.Maximum then
    form.icg_items.VScrollBar.Value = form.icg_items.VScrollBar.Maximum
  else
    form.icg_items.VScrollBar.Value = form.VScrollBarValue
  end
end
function auto_pick_all(form)
  local game_config_info = nx_value("game_config_info")
  local game_visual = nx_value("game_visual")
  local vis_player = game_visual:GetPlayer()
  if not nx_is_valid(vis_player) then
    return
  end
  if not nx_find_custom(vis_player, "last_mouse_op") then
    return
  end
  local key = util_get_property_key(game_config_info, "pick_autopick", 1)
  if vis_player.last_mouse_op ~= "right" or nx_string(key) == nx_string("0") then
    return
  end
  nx_pause(1)
  if nx_is_valid(form) and form.Visible then
    on_btn_pick_click(form.btn_pick)
  end
end
function show_normal_tips(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  grid.view_obj = viewobj
  nx_execute("tips_game", "show_goods_tip", grid.view_obj, grid:GetMouseInItemLeft() + grid.GridOffsetX, grid:GetMouseInItemTop() + grid.GridOffsetY, 32, 32, form)
end
function set_window_position(form)
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(gui) or not nx_is_valid(game_config_info) then
    return
  end
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
function close_form()
  local form = nx_value(FORM_TAOSHA_PICK)
  if nx_is_valid(form) then
    form:Close()
  end
end
