require("define\\gamehand_type")
require("util_static_data")
require("share\\itemtype_define")
require("share\\view_define")
require("share\\client_custom_define")
require("util_functions")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function view_grid_on_update_item(grid, view_index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  GoodsGrid:ViewUpdateItem(grid, view_index)
end
function view_grid_on_delete_item(grid, view_index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  GoodsGrid:ViewDeleteItem(grid, view_index)
end
function view_grid_clear_item_indirect()
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if nx_find_custom(game_hand, "indirect_select") and game_hand.indirect_select == 1 then
    game_hand.indirect_select = 0
  end
end
function view_grid_split_item(grid, selected_index, num)
  local gui = nx_value("gui")
  local photo = grid:GetItemImage(selected_index)
  local amount = grid:GetItemNumber(selected_index)
  local split_num = math.min(num or 1, amount - 1)
  if 2 <= amount then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
    dialog.info_label.Text = gui.TextManager:GetFormatText("ui_inputbox_spititem", nx_int(amount - 1))
    dialog.name_edit.OnlyDigit = true
    dialog.name_edit.MaxDigit = nx_int(amount - 1)
    dialog.name_edit.Max = nx_int(amount - 1)
    dialog.name_edit.Text = nx_widestr(split_num)
    dialog:ShowModal()
    local res, text = nx_wait_event(100000000, dialog, "input_box_return")
    if not nx_is_valid(grid) then
      return
    end
    if res == "ok" then
      amount = nx_number(text)
    end
    if 0 < amount then
      local view_index = grid:GetBindIndex(selected_index)
      gui.GameHand:SetHand(GHT_VIEWITEM, photo, nx_string(grid.typeid), nx_string(view_index), nx_string(amount), "split")
    end
  end
end
function view_grid_destroy_item(grid, selected_index)
  local isEmpty = grid:IsEmpty(selected_index)
  if grid:IsEmpty(selected_index) then
    return
  end
  local view_index = grid:GetBindIndex(selected_index)
  local item = get_view_item(grid.typeid, view_index)
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  if flag then
    nx_execute("custom_sender", "custom_delete_item", grid.typeid, view_index)
    return true
  end
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if flag_apex then
    nx_execute("custom_sender", "custom_delete_item", grid.typeid, view_index)
    return true
  end
  local configID = item:QueryProp("ConfigID")
  local is_spacil = nx_execute("form_stage_main\\form_bag", "is_important_item", item)
  if 1 == is_spacil then
    local dia = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm_del", true, false)
    dia.event_type = "my_del"
    dia:ShowModal()
    local res = nx_wait_event(100000000, dia, "my_del_confirm_return")
    if not nx_is_valid(grid) then
      return
    end
    if "ok" == res then
      nx_execute("custom_sender", "custom_delete_item", grid.typeid, view_index)
      return
    else
      return
    end
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_confirm_destroyitem")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if not nx_is_valid(grid) then
    return
  end
  if res == "ok" then
    local view_index = grid:GetBindIndex(selected_index)
    nx_execute("custom_sender", "custom_delete_item", grid.typeid, view_index)
  end
end
function view_grid_arrange_item(grid, begin_view_index, end_view_index)
  if not grid.canarrange then
    return
  end
  nx_execute("form_stage_main\\form_bag", "clear_select_items")
  nx_execute("form_stage_main\\form_bag", "add_select_items", "all")
  nx_execute("custom_sender", "custom_arrange_item", grid.typeid, begin_view_index, end_view_index)
end
function view_grid_fresh_all(grid)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(grid)
  end
end
function get_view_item(view_id, view_index)
  local game_client = nx_value("game_client")
  return game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
end
function get_equip_pos(equip)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(equip) then
    return nil
  end
  return goods_grid:GetEquipPositionList(equip)
end
function get_equip_pos_by_equiptype(equip_type)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return nil
  end
  return goods_grid:GetEquipPositionTuple(nx_string(equip_type))
end
function show_equip_pos_tips(equip)
  local form = nx_value("form_rp_arm")
  if not nx_is_valid(form) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local pos_lst = get_equip_pos(equip)
  if pos_lst == nil then
    return
  end
  for i, pos in pairs(pos_lst) do
    local grid_pos = GoodsGrid:GetGridIndexFromViewIndex(form.equip_grid, nx_number(pos))
    if 0 <= grid_pos then
      form.equip_grid:CoverItem(grid_pos, true)
    end
  end
end
function clear_equip_pos_tips()
  local form = nx_value("form_rp_arm")
  if not nx_is_valid(form) then
    return
  end
  for i = 0, form.equip_grid.RowNum do
    for j = 0, form.equip_grid.ClomnNum do
      local grid_pos = i * form.equip_grid.ClomnNum + j
      form.equip_grid:CoverItem(grid_pos, false)
    end
  end
end
function can_change_equip(equip, pos)
  local pos_tuple = get_equip_pos(equip)
  if pos_tuple == nil then
    return false
  end
  for _, val in ipairs(pos_tuple) do
    if nx_number(val) == nx_number(pos) then
      return true
    end
  end
  return false
end
function show_mount_pos_tips(mount)
  local form = nx_value("form_rp_arm")
  if not nx_is_valid(form) then
    return
  end
  form.mount_grid:CoverItem(1, true)
end
function clear_mount_pos_tips()
  local form = nx_value("form_rp_arm")
  if not nx_is_valid(form) then
    return
  end
  form.mount_grid:CoverItem(1, false)
end
