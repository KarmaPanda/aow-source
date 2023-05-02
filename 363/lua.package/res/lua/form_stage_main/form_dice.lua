require("const_define")
require("share\\itemtype_define")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
  form.item_array_data = nil
end
function on_main_form_open(form)
  init_imagegrid(form)
  form.pbar_timer.Minimum = nx_int(0)
  form.pbar_timer.Maximum = nx_int(60)
  form.pbar_timer.Value = nx_int(form.wait_time)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "on_update_timer", form, -1, -1)
  end
end
function on_main_form_close(form)
  if nx_is_valid(form.item_array_data) then
    nx_destroy(form.item_array_data)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  return_choice(btn.Parent, 0)
end
function on_btn_need_click(btn)
  return_choice(btn.Parent, 2)
end
function on_btn_greed_click(btn)
  return_choice(btn.Parent, 1)
end
function on_update_timer(form, param1, param2)
  local current_value = form.pbar_timer.Value
  current_value = current_value - 1
  if nx_int(current_value) <= nx_int(0) then
    nx_execute("form_stage_main\\form_dicemanager", "close_dice_form", form)
  else
    form.pbar_timer.Value = current_value
  end
end
function on_lbl_icon_get_capture(grid, index)
  local form = grid.ParentForm
  nx_execute("tips_game", "show_goods_tip", form.item_array_data, grid.AbsLeft + grid.Width, grid.AbsTop, grid.Width, grid.Height, form)
end
function on_lbl_icon_lost_capture(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function init_imagegrid(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_palyer = game_client:GetPlayer()
  if not nx_is_valid(client_palyer) then
    return
  end
  form.item_array_data = nx_call("util_gui", "get_arraylist", "form_dice" .. form.pos)
  nx_execute("form_stage_main\\form_main\\form_main_chat", "get_arraylist_by_parse_xmldata", form.item_info, form.item_array_data)
  local config_id = nx_custom(form.item_array_data, "ConfigID")
  local item_type = nx_custom(form.item_array_data, "ItemType")
  local color_level = nx_custom(form.item_array_data, "ColorLevel")
  local sex = client_palyer:QueryProp("Sex")
  local photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo"))
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local equip_type = ""
  if nx_number(item_type) >= ITEMTYPE_EQUIP_MIN and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX then
    equip_type = item_query:GetItemPropByConfigID(config_id, "EquipType")
  end
  if ITEMTYPE_EQUIP_MIN <= nx_number(item_type) and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX and 0 ~= sex then
    local tmp_photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "FemalePhoto"))
    if nil ~= tmp_photo and "" ~= tmp_photo then
      photo = tmp_photo
    end
  end
  local item_back_image = get_grid_treasure_back_image(equip_type, color_level)
  form.lbl_icon:AddItemEx(0, photo, nx_widestr(nx_string(name)), form.amount, -1, item_back_image)
end
function return_choice(form, dice_mode)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_timer", form)
  end
  local pos = form.pos
  local item = form.item
  form:Close()
  nx_execute("form_stage_main\\form_dicemanager", "send_dice_result", pos, item, dice_mode)
end
