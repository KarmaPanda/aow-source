require("define\\gamehand_type")
require("util_static_data")
require("share\\itemtype_define")
require("share\\view_define")
require("util_functions")
equip_pos_info_lst = {}
function get_gridindex_from_viewindex(grid, view_index, gridCount)
  for i = 0, nx_number(gridCount) - 1 do
    local bind_index = grid:GetBindIndex(i)
    if bind_index == view_index then
      return i
    end
  end
  return -1
end
function get_item_data(grid, grid_index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return nil
  end
  return GoodsGrid:GetItemData(grid, grid_index)
end
function goods_grid_add_item(grid, grid_index, prop_table)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local price = 0
  local sell_price = 0
  local sell_count = 0
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(grid:GetBindIndex(grid_index)))
  if not nx_is_valid(viewobj) then
    return
  end
  if view:FindRecord("offline_sellbox_table") then
    local row = view:FindRecordRow("offline_sellbox_table", 1, viewobj:QueryProp("UniqueID"))
    if 0 <= row then
      sell_price = view:QueryRecord("offline_sellbox_table", row, 7)
      sell_count = view:QueryRecord("offline_sellbox_table", row, 5)
    end
  end
  local item_data = nx_create("ArrayList", nx_current())
  for prop, value in pairs(prop_table) do
    if nx_string(prop) == nx_string("Amount") then
      value = sell_count
    end
    nx_set_custom(item_data, prop, value)
  end
  GoodsGrid:GridAddItem(grid, grid_index, item_data)
  if grid.typeid == VIEWPORT_OFFLINE_SELL_BOX then
    price = sell_price * sell_count
  elseif grid.typeid == VIEWPORT_STALL_PURCHASE_BOX then
    price = viewobj:QueryProp(nx_string("PurchasePrice1")) * (viewobj:QueryProp(nx_string("BuyCountAll")) - viewobj:QueryProp(nx_string("BuyedCount")))
  end
  if 1000000 <= price then
    grid:CoverItem(grid_index, true)
  end
end
function goods_grid_delete_item(grid, grid_index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  GoodsGrid:GridDelItem(grid, grid_index)
  grid:CoverItem(grid_index, false)
end
function view_use_item_indirect(view_id, view_index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if nx_find_custom(game_hand, "indirect_select") and game_hand.indirect_select == 1 then
    game_hand.indirect_select = 0
    game_hand:ClearHand()
    nx_execute("custom_sender", "custom_use_item_on_item", game_hand.indirect_srcviewid, game_hand.indirect_srcviewindex, view_id, view_index)
    return true
  end
  return false
end
function view_grid_on_select_item(grid, index)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  selected_index = index or selected_index
  local view_index = grid:GetBindIndex(selected_index)
  if view_use_item_indirect(grid.typeid, view_index) then
    return
  end
  if nx_execute("animation", "check_has_animation", nx_string("BoxShow"), nx_int(selected_index)) then
    nx_execute("animation", "del_animation", nx_string("BoxShow"))
  end
  if gui.GameHand:IsEmpty() and grid:IsEmpty(selected_index) then
    return
  end
  if gui.GameHand:IsEmpty() then
    if not grid.canselect then
      return
    end
    local photo = grid:GetItemImage(selected_index)
    local amount = grid:GetItemNumber(selected_index)
    gui.GameHand:SetHand(GHT_VIEWITEM, photo, nx_string(grid.typeid), nx_string(view_index), nx_string(amount), "")
    return
  end
  local gamehand_type = gui.GameHand.Type
  if gamehand_type == GHT_VIEWITEM then
    if grid.typeid > 0 and grid.canselect then
      local src_viewid = nx_int(gui.GameHand.Para1)
      local src_pos = nx_int(gui.GameHand.Para2)
      local amount = nx_int(gui.GameHand.Para3)
      nx_execute("custom_sender", "custom_move_item", src_viewid, src_pos, amount, grid.typeid, view_index)
      gui.GameHand:ClearHand()
    end
  elseif gamehand_type == GHT_FUNC then
    local func = gui.GameHand.Para1
    if func == "split" then
      if grid.cansplit then
        view_grid_split_item(grid, selected_index)
      end
    elseif func == "destroy" and grid.candestroy then
      view_grid_destroy_item(grid, selected_index)
    end
  end
end
function view_grid_on_update_item(grid, view_index)
  local gridCount = nx_int(grid.endindex)
  local playerCount = nx_int(grid.playerCount)
  if not nx_find_custom(grid, "typeid") then
    return
  end
  if grid.typeid <= 0 then
    return
  end
  local grid_index = get_gridindex_from_viewindex(grid, view_index, gridCount)
  if grid_index < 0 then
    return
  end
  if nx_number(grid_index) >= nx_number(playerCount) then
    return
  end
  local view_item = get_view_item(grid.typeid, view_index)
  if not nx_is_valid(view_item) then
    return
  end
  local prop_table = {}
  local proplist = view_item:GetPropList()
  for i, prop in pairs(proplist) do
    prop_table[prop] = view_item:QueryProp(prop)
  end
  if prop_table.Photo == nil or prop_table.Photo == "" then
    prop_table.Photo = nx_execute("util_static_data", "queryprop_by_object", view_item, "Photo")
    if prop_table.Photo == nil then
      prop_table.Photo = ""
    end
  end
  goods_grid_add_item(grid, grid_index, prop_table)
end
function view_grid_on_delete_item(grid, view_index)
  local gridCount = nx_int(grid.endindex)
  local playerCount = nx_int(grid.playerCount)
  local grid_index = get_gridindex_from_viewindex(grid, view_index, gridCount)
  if grid_index < 0 then
    return
  end
  if nx_number(grid_index) >= nx_number(playerCount) then
    return
  end
  goods_grid_delete_item(grid, grid_index)
end
function view_grid_clear_item_indirect()
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if nx_find_custom(game_hand, "indirect_select") and game_hand.indirect_select == 1 then
    game_hand.indirect_select = 0
  end
end
function view_grid_split_item(grid, selected_index)
  local gui = nx_value("gui")
  local photo = grid:GetItemImage(selected_index)
  local amount = grid:GetItemNumber(selected_index)
  if 2 <= amount then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
    dialog.info_label.Text = gui.TextManager:GetFormatText("ui_inputbox_spititem", nx_int(amount - 1))
    dialog.name_edit.OnlyDigit = true
    dialog.name_edit.MaxDigit = nx_int(amount - 1)
    dialog:ShowModal()
    local res, text = nx_wait_event(100000000, dialog, "input_box_return")
    if res == "ok" then
      amount = nx_number(text)
    end
    if 0 < amount then
      local view_index = grid:GetBindIndex(selected_index)
      gui.GameHand:SetHand(GHT_VIEWITEM, photo, nx_string(grid.typeid), nx_string(view_index), nx_string(amount), "")
    end
  end
end
function view_grid_destroy_item(grid, selected_index)
  local view_index = grid:GetBindIndex(selected_index)
  local item = get_view_item(grid.typeid, view_index)
  local configID = item:QueryProp("ConfigID")
  local is_spacil = nx_execute("form_stage_main\\form_bag", "is_important_item", item)
  if 1 == is_spacil then
    local dia = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm_del", true, false)
    dia.event_type = "my_del"
    dia:ShowModal()
    local res = nx_wait_event(100000000, dia, "my_del_confirm_return")
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
  if res == "ok" then
    local view_index = grid:GetBindIndex(selected_index)
    nx_execute("custom_sender", "custom_delete_item", grid.typeid, view_index)
  end
end
function view_grid_arrange_item(grid, begin_view_index, end_view_index)
  if not grid.canarrange then
    return
  end
  nx_execute("custom_sender", "custom_arrange_item", grid.typeid, begin_view_index, end_view_index)
end
function goods_grid_clear_item(grid)
  grid:Clear()
  if nx_is_valid(grid.Data) then
    grid.Data:ClearChild()
  end
end
function view_grid_fresh_all(grid)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  GoodsGrid:GridClear(grid)
  if not nx_find_custom(grid, "typeid") then
    return
  end
  if grid.typeid <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(view) then
    return
  end
  local gridCount = nx_int(grid.endindex)
  local playerCount = nx_int(grid.playerCount)
  local viewobj_list = view:GetViewObjList()
  for i, item in pairs(viewobj_list) do
    local view_index = nx_number(item.Ident)
    view_grid_on_update_item(grid, view_index, gridCount)
  end
  for index = nx_number(playerCount), nx_number(gridCount) - 1 do
    grid:AddItem(index, nx_string("gui\\common\\imagegrid\\icon_lock2.png"), nx_widestr(""), nx_int(0), nx_int(0))
  end
end
function view_grid_fresh_all_no_suo(grid)
  if not nx_is_valid(grid) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  GoodsGrid:GridClear(grid)
  if not nx_find_custom(grid, "typeid") then
    return
  end
  if grid.typeid <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(view) then
    return
  end
  local gridCount = nx_int(grid.endindex)
  local playerCount = nx_int(grid.playerCount)
  local viewobj_list = view:GetViewObjList()
  for i, item in pairs(viewobj_list) do
    local view_index = nx_number(item.Ident)
    view_grid_on_update_item(grid, view_index, gridCount)
  end
end
function get_view_item(view_id, view_index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return nx_null()
  end
  return view:GetViewObj(nx_string(view_index))
end
function load_equip_pos_info()
  local ini = nx_execute("util_functions", "get_ini", "ini\\equipbox.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("ini\\equipbox.ini " .. get_msg_str("msg_120"))
  end
  local sec_index = ini:FindSectionIndex("EquipType")
  if sec_index < 0 then
    return
  end
  local key_num = ini:GetSectionItemCount(sec_index)
  for i = 1, key_num do
    local equip_type = ini:GetSectionItemKey(sec_index, i - 1)
    local str_pos = ini:GetSectionItemValue(sec_index, i - 1)
    local pos_lst = nx_function("ext_split_string", str_pos, ",")
    equip_pos_info_lst[equip_type] = {}
    for j = 1, table.getn(pos_lst) do
      equip_pos_info_lst[equip_type][j] = nx_number(pos_lst[j])
    end
  end
end
function get_equip_pos(equip)
  if equip_pos_info_lst == nil or table.getn(equip_pos_info_lst) == 0 then
    load_equip_pos_info()
  end
  if not equip:FindProp("EquipType") then
    return nil
  end
  local equip_type = equip:QueryProp("EquipType")
  return equip_pos_info_lst[equip_type]
end
function get_equip_pos_by_equiptype(equip_type)
  if equip_pos_info_lst == nil or table.getn(equip_pos_info_lst) == 0 then
    load_equip_pos_info()
  end
  local table_list = equip_pos_info_lst[equip_type]
  if table_list == nil then
    return nil
  end
  local count = table.maxn(table_list)
  if count == 1 then
    return table_list[1]
  elseif count == 2 then
    return table_list[1], table_list[2]
  elseif count == 3 then
    return table_list[1], table_list[2], table_list[3]
  end
  return equip_pos_info_lst[equip_type]
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
function GetSellCount()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local level = client_player:QueryProp("StallLevel")
  if nx_int(level) == nx_int(0) then
    level = 1
  end
  local sellCount = getIniValue(nx_int(level), "SellCount")
  return sellCount
end
function getIniValue(level, key)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\stall.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\Rule\\stall.ini " .. get_msg_str("msg_120"))
    return 0
  end
  local section_name = "Rank_" .. nx_string(level)
  if not ini:FindSection(nx_string(section_name)) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(section_name))
  if sec_index < 0 then
    return 0
  end
  local lev = ini:ReadString(sec_index, "Level", "0")
  if nx_int(lev) == nx_int(level) then
    local value = ini:ReadString(sec_index, key, "0")
    return nx_int64(value)
  end
  return 0
end
