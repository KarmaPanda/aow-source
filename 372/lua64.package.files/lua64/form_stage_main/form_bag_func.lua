require("share\\view_define")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("util_functions")
require("form_common\\form_confirm")
require("form_stage_main\\switch\\switch_define")
require("util_gui")
require("goods_grid")
local EQUIP_STEP = 25
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function get_bag_name()
  return "form_stage_main\\form_bag"
end
function on_bag_select_changed(grid, index)
  local form = nx_value(get_bag_name())
  if not nx_is_valid(form) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local gui = nx_value("gui")
  local cur_addgrid = form.cur_addgrid
  local VIEW_MAIN = grid.main_typeid
  local VIEW_ADD = grid.addtypeid
  cur_addgrid:SetSelectItemIndex(nx_int(-1))
  local view_index = grid:GetBindIndex(index)
  local addbag_index = get_addbag_index(view_index)
  if addbag_index ~= 0 then
    local game_client = nx_value("game_client")
    local bag_item = game_client:GetViewObj(nx_string(VIEW_ADD), nx_string(addbag_index))
    if not nx_is_valid(bag_item) then
      return
    end
    local valid_time = bag_item:QueryProp("Hardiness")
    if valid_time <= 0 then
      if gui.GameHand:IsEmpty() and not grid:IsEmpty(index) then
        local photo = grid:GetItemImage(index)
        local amount = grid:GetItemNumber(index)
        gui.GameHand:SetHand(GHT_VIEWITEM, nx_string(photo), nx_string(VIEW_MAIN), nx_string(view_index), nx_string(amount), "")
      end
      return
    end
  end
  local form
  form = nx_value("form_stage_main\\form_itembind\\form_itembind_equip")
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_value("form_stage_main\\form_itembind\\form_itembind_use")
  if nx_is_valid(form) then
    form:Close()
  end
  if is_using_musician(grid, index) then
    use_skill_musician(grid, index)
    return
  end
  if is_using_pizhushu(grid, index) then
    use_skill_pizhushu(grid, index)
    return
  end
  if is_using_pizhuhua(grid, index) then
    use_skill_pizhuhua(grid, index)
    return
  end
  if is_using_chaolu(grid, index) then
    use_skill_chaolu(grid, index)
    return
  end
  if is_using_life_skill_qianghua(grid, index) then
    use_skill_life_skill_qianghua(grid, index)
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    return
  end
  if is_using_life_skill_splititem(grid, index) then
    use_skill_life_skill_splititem(grid, index)
    return
  end
  if is_repair_addbags("repair_one_byself", grid, grid.main_typeid, index) or is_repair_addbags("repair_one_bynpc", grid, grid.main_typeid, index) then
    begin_repair_addbags(grid, index)
    return
  end
  if is_repair_goods("repair_one_bynpc", grid, index) then
    begin_repair(grid, index, 0, 0)
    return
  end
  if is_repair_goods("repair_one_bynpc_usesilver", grid, index) then
    begin_repair(grid, index, 0, 1)
    return
  end
  if is_repair_goods("repair_one_byself", grid, index) then
    begin_repair(grid, index, 1, 0)
    return
  end
  if is_Posion_ShotWeapon(grid, index) then
    return
  end
  if not is_UseFixItem(grid, index) then
    return
  end
  local game_client = nx_value("game_client")
  local toolbox_view = game_client:GetView(nx_string(VIEW_MAIN))
  local addtool_view = game_client:GetView(nx_string(VIEW_ADD))
  if nx_function("ext_ctrl_pressed") then
    if nx_is_valid(toolbox_view) then
      local bind_index = grid:GetBindIndex(index)
      local item_data = GoodsGrid:GetItemData(grid, index)
      local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
      if nx_is_valid(viewobj) and nx_is_valid(item_data) then
        local configid = viewobj:QueryProp("ConfigID")
        local uniqueid = viewobj:QueryProp("UniqueID")
        local base_name = viewobj:QueryProp("BaseName")
        local item_type = viewobj:QueryProp("ItemType")
        local palyer = game_client:GetPlayer()
        local item_name = gui.TextManager:GetText(nx_string(configid))
        local base_name = tips_manager:GetItemBaseName(viewobj)
        if base_name ~= nx_widestr("") then
          item_name = base_name
        end
        local mark = viewobj:QueryProp("CustomNameMark")
        if mark == 1 then
          local mark_data = viewobj:QueryProp("CustomNameDesc")
          local data_table = nx_function("ext_split_wstring", mark_data, nx_widestr("&"))
          local count = table.maxn(data_table)
          if 2 <= count then
            item_name = data_table[1]
          end
        end
        local equip_type = viewobj:QueryProp("EquipType")
        if nx_string(equip_type) == nx_string("NewTreasure") then
          local suit_id = viewobj:QueryProp("TersureSuitID")
          if 0 < suit_id and suit_id <= 10 then
            item_name_1 = gui.TextManager:GetText("desc_newtreasure_combination_" .. suit_id)
            item_name_2 = gui.TextManager:GetText(nx_string(configid))
            item_name = nx_widestr(item_name_1) .. nx_widestr(item_name_2)
          end
        end
        local role_name = palyer:QueryProp("Name")
        local htmltext = nx_widestr("<a href=\"item,") .. nx_widestr(role_name) .. nx_widestr(",") .. nx_widestr(uniqueid) .. nx_widestr(",") .. nx_widestr(configid) .. nx_widestr("\" style=\"HLChatItem\"><") .. nx_widestr(item_name) .. nx_widestr("></a>")
        grid.htmltext = htmltext
        grid.item_name = nx_widestr(item_name)
        local timer = nx_value("timer_game")
        if nx_is_valid(timer) then
          timer:UnRegister(nx_current(), "add_hyperlink_item", grid)
          timer:Register(300, 1, nx_current(), "add_hyperlink_item", grid, -1, -1)
        end
      end
    end
    return 1
  end
  if not gui.GameHand:IsEmpty() and gui.GameHand.Para1 == nx_string(VIEW_ADD) and nx_is_valid(addtool_view) then
    local viewobj = addtool_view:GetViewObj(gui.GameHand.Para2)
    local beginpos = viewobj:QueryProp("BeginPos")
    local endpos = viewobj:QueryProp("EndPos")
    local bindindex = grid:GetBindIndex(index)
    if beginpos <= bindindex and endpos >= bindindex then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1357"))
      return 0
    end
  end
  if not gui.GameHand:IsEmpty() and gui.GameHand.Para1 == nx_string(VIEWPORT_GUILD_DEPOT) then
    local guild_depot_view_id = nx_number(gui.GameHand.Para1)
    local guild_depot_view_index = nx_number(gui.GameHand.Para2)
    local guild_depot_amount = nx_number(gui.GameHand.Para3)
    local guild_depot_id = nx_object(gui.GameHand.Para4)
    nx_execute("custom_sender", "custom_put_item_from_guilddepot_to_toolbox", nx_int(guild_depot_view_id), nx_int(guild_depot_view_index), nx_int(guild_depot_amount), nx_int(VIEW_MAIN), nx_int(grid:GetBindIndex(index)), guild_depot_id)
    gui.GameHand:ClearHand()
  end
  if gui.GameHand:IsEmpty() and nx_is_valid(toolbox_view) then
    local bind_index = grid:GetBindIndex(index)
    local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
    local form_blend = nx_value("form_stage_main\\form_equipblend")
    if nx_is_valid(viewobj) and nx_is_valid(form_blend) and form_blend.Visible then
      nx_execute("form_stage_main\\form_equipblend", "refresh_place_pos", form_blend, viewobj)
    end
  end
  if not gui.GameHand:IsEmpty() then
    local kg_src_viewid = nx_number(gui.GameHand.Para1)
    local kg_src_pos = nx_number(gui.GameHand.Para2)
    local kg_src_item = get_view_item(kg_src_viewid, kg_src_pos)
    if nx_is_valid(kg_src_item) then
      local kg_src_item_type = kg_src_item:QueryProp("ItemType")
      if kg_src_item_type == ITEMTYPE_SET_ITEM_DROPPROP and nx_string(gui.GameHand.Type) == "proficiencyitem" then
        local bind_index = grid:GetBindIndex(index)
        local item_data = GoodsGrid:GetItemData(grid, index)
        local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
        if not nx_is_valid(viewobj) then
          gui.GameHand:ClearHand()
          return
        end
        local kg_dest_item_type = viewobj:QueryProp("ItemType")
        if viewobj:FindProp("RandomRulePack") or kg_dest_item_type == ITEMTYPE_WEAPON_BOOK or kg_dest_item_type == ITEMTYPE_WEAPON_PAINT then
          local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
          if not nx_is_valid(dialog) then
            gui.GameHand:ClearHand()
            return
          end
          dialog:ShowModal()
          dialog.mltbox_info:Clear()
          dialog.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_enchantitem_001")), -1)
          dialog.relogin_btn.Visible = false
          local res = nx_wait_event(100000000, dialog, "confirm_return")
          if res == "cancel" then
            gui.GameHand:ClearHand()
            return
          end
        end
      end
    end
  end
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(grid, index)
end
function add_hyperlink_item(grid)
  local gui = nx_value("gui")
  local FORM_CHAT_WINDOW = "form_stage_main\\form_chat_system\\form_chat_window"
  local FORM_CHAT_GROUP = "form_stage_main\\form_chat_system\\form_chat_group"
  local FORM_MAIN_CHAT = "form_stage_main\\form_main\\form_main_chat"
  local FORM_MARKET = "form_stage_main\\form_market\\form_market"
  local htmltext = grid.htmltext
  if nx_find_custom(gui, "hyperfocused") and nx_is_valid(gui.hyperfocused) then
    local focused = gui.hyperfocused
    gui.hyperfocused = nil
    local form_market = util_get_form(FORM_MARKET, false)
    if nx_is_valid(form_market) and nx_id_equal(form_market.ipt_search_key, focused) and nx_find_custom(grid, "item_name") then
      form_market.ipt_search_key.Text = nx_widestr(grid.item_name)
      return
    end
    local form_auction = util_get_form("form_stage_main\\form_auction\\form_auction_main", false)
    if nx_is_valid(form_auction) and nx_id_equal(form_auction.ipt_search, focused) and nx_find_custom(grid, "item_name") then
      form_auction.ipt_search.Text = nx_widestr(grid.item_name)
      return
    end
    local form_laba = nx_value("form_stage_main\\form_main\\form_laba_info")
    if nx_is_valid(form_laba) and nx_id_equal(form_laba.redit_info, focused) then
      nx_execute("form_stage_main\\form_main\\form_laba_info", "add_chatface_to_chatedit", nx_widestr(htmltext))
      return
    end
    local form_chat_window = nx_value(FORM_CHAT_WINDOW)
    if nx_is_valid(form_chat_window) and nx_id_equal(form_chat_window.txt_content, focused) then
      nx_execute(FORM_CHAT_WINDOW, "add_hyperlink", nx_widestr(htmltext))
      return
    end
    local form_chat_group = nx_value(FORM_CHAT_GROUP)
    if nx_is_valid(form_chat_group) and nx_id_equal(form_chat_group.txt_content, focused) then
      return
    end
    local form_main_chat = nx_value(FORM_MAIN_CHAT)
    if nx_is_valid(form_main_chat) and nx_id_equal(form_main_chat.chat_edit, focused) then
      nx_execute(FORM_MAIN_CHAT, "add_item_to_chatedit", nx_widestr(htmltext))
      return
    end
  else
    local form_main_chat = nx_value(FORM_MAIN_CHAT)
    if nx_is_valid(form_main_chat) then
      nx_execute(FORM_MAIN_CHAT, "add_item_to_chatedit", nx_widestr(htmltext))
      return
    end
  end
end
function use_item_by_configid(configid)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local grid, grid_index = goods_grid:GetToolBoxGridAndPos(configid)
  if grid == nil or not nx_is_valid(grid) then
    return
  end
  if grid_index == nil or grid_index < 0 then
    return
  end
  on_bag_right_click(grid, grid_index)
end
function on_bag_right_click(grid, index)
  local form = nx_value(get_bag_name())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local VIEW_MAIN = grid.main_typeid
  local VIEW_ADD = grid.addtypeid
  local view_index = grid:GetBindIndex(index)
  local addbag_index = get_addbag_index(view_index)
  if addbag_index ~= 0 then
    local game_client = nx_value("game_client")
    local bag_item = game_client:GetViewObj(nx_string(VIEW_ADD), nx_string(addbag_index))
    if not nx_is_valid(bag_item) then
      return
    end
    local valid_time = bag_item:QueryProp("Hardiness")
    if valid_time <= 0 then
      return
    end
  end
  local form = nx_value("form_stage_main\\form_itembind\\form_itembind_equip")
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_value("form_stage_main\\form_itembind\\form_itembind_use")
  if nx_is_valid(form) then
    form:Close()
  end
  local form_depot = nx_value("form_stage_main\\form_depot")
  if nx_is_valid(form_depot) then
    local GoodsGrid = nx_value("GoodsGrid")
    if not nx_is_valid(GoodsGrid) then
      return
    end
    GoodsGrid:ViewGridPutToAnotherView(grid, VIEWPORT_DEPOT)
    return
  end
  local form_home_depot = nx_value("form_stage_main\\form_home\\form_home_depot")
  if nx_is_valid(form_home_depot) then
    local GoodsGrid = nx_value("GoodsGrid")
    if not nx_is_valid(GoodsGrid) then
      return
    end
    GoodsGrid:ViewGridPutToAnotherView(grid, VIEWPORT_HOME_DEPOT)
    return
  end
  local form_treasurebox = nx_value("form_stage_main\\form_life\\form_treasure_box")
  if nx_is_valid(form_treasurebox) then
    local GoodsGrid = nx_value("GoodsGrid")
    if not nx_is_valid(GoodsGrid) then
      return
    end
    GoodsGrid:ViewGridPutToAnotherView(grid, VIEWPORT_TREASUREBOX)
    return
  end
  local form_websell = nx_value("form_stage_main\\form_webexchange\\form_exchange_main")
  if nx_is_valid(form_websell) then
    local GoodsGrid = nx_value("GoodsGrid")
    if not nx_is_valid(GoodsGrid) then
      return
    end
    GoodsGrid:ViewGridPutToAnotherView(grid, VIEWPORT_WEB_EXCHANGE_BOX)
    return
  end
  if not do_split(grid, index) then
    return
  end
  if not do_shop(grid, index) then
    return
  end
  if not do_onestep_equip(grid, index) then
    return
  end
  if not do_equipblend(grid, index) then
    return
  end
  local form_stall = nx_value("form_stage_main\\form_stall\\form_stall_main")
  if nx_is_valid(form_stall) then
    if form_stall.rbtn_chushou.Checked == true then
      nx_execute("form_stage_main\\form_stall\\form_stall_sell", "add_sell_by_rightclick", grid, index)
      return
    elseif form_stall.rbtn_shougou.Checked == true then
      nx_execute("form_stage_main\\form_stall\\form_stall_buy", "add_buy_by_rightclick", grid, index)
      return
    end
  end
  local form_fuse_dazaotai_additem = nx_value("form_stage_main\\form_life\\form_fuse_dazaotai_additem")
  if nx_is_valid(form_fuse_dazaotai_additem) then
    local GoodsGrid = nx_value("GoodsGrid")
    if not nx_is_valid(GoodsGrid) then
      return
    end
    nx_execute("form_stage_main\\form_life\\form_fuse_dazaotai_additem", "do_equipblend", grid, index)
    return
  end
  if not do_equipblend_collect(grid, index) then
    return
  end
  local form_newtreasure = nx_value("form_stage_main\\form_life\\form_newtreasure_grave")
  if nx_is_valid(form_newtreasure) then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_grave", "add_item_by_rightclick", grid, index)
    return
  end
  local form_newtreasure_transfer = nx_value("form_stage_main\\form_life\\form_newtreasure_transfer")
  if nx_is_valid(form_newtreasure_transfer) then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_transfer", "add_item_by_rightclick", grid, index)
    return
  end
  local form_treasure_repair = nx_value("form_stage_main\\form_life\\form_treasure_repair")
  if nx_is_valid(form_treasure_repair) then
    nx_execute("form_stage_main\\form_life\\form_treasure_repair", "add_item_by_rightclick", grid, index)
    return
  end
  if do_color_egg(grid, index) then
    return
  end
  if not do_bind(grid, index) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local vis_player = game_visual:GetPlayer()
    if nx_is_valid(vis_player) then
      vis_player.last_mouse_op = "right"
    end
  end
  if confirm_use_item(grid.typeid, grid:GetBindIndex(index)) then
    goods_grid:ViewUseItem(grid.typeid, grid:GetBindIndex(index), grid, index)
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_addbag_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_grid:SetSelectItemIndex(nx_int(-1))
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(grid, index)
  if is_repair_addbags("repair_one_byself", grid, grid.typeid, index) or is_repair_addbags("repair_one_bynpc", grid, grid.typeid, index) then
    begin_repair_addbags(grid, index)
    return
  end
end
function on_addbag_right_click(grid, index)
end
function get_addbag_index(view_index)
  local form = nx_value(get_bag_name())
  local cur_addgrid = form.cur_addgrid
  local game_client = nx_value("game_client")
  local addtoolbox_view = game_client:GetView(nx_string(cur_addgrid.addtypeid))
  if not nx_is_valid(addtoolbox_view) then
    return 0
  end
  for i = 1, addtoolbox_view.Capacity do
    local smallbag = addtoolbox_view:GetViewObj(nx_string(i))
    if nx_is_valid(smallbag) then
      local beginpos = smallbag:QueryProp("BeginPos")
      local endpos = smallbag:QueryProp("EndPos")
      if view_index >= beginpos and view_index <= endpos then
        return i
      end
    end
  end
  return 0
end
function remove_overtime_addbag(form, view_index)
  local bag_index = get_addbag_index(view_index)
  if bag_index == 0 then
    return
  end
  local cur_grid = form.cur_grid
  local game_client = nx_value("game_client")
  local bag_item = game_client:GetViewObj(nx_string(cur_grid.addtypeid), nx_string(bag_index))
  local valid_time = bag_item:QueryProp("Hardiness")
  if 0 < valid_time then
    return
  end
  local beginpos = bag_item:QueryProp("BeginPos")
  local endpos = bag_item:QueryProp("EndPos")
  for k = beginpos, endpos do
    local view_item = game_client:GetViewObj(nx_string(cur_grid.typeid), nx_string(k))
    if nx_is_valid(view_item) then
      return
    end
  end
  nx_execute("custom_sender", "custom_delete_item", cur_grid.addtypeid, bag_index, 1)
end
function is_using_musician(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == "Musician" then
    local toolbox_view = game_client:GetView(nx_string(grid.main_typeid))
    if nx_is_valid(toolbox_view) then
      local bind_index = grid:GetBindIndex(index)
      local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
      if nx_is_valid(viewobj) then
        local canmusic = viewobj:QueryProp("CanMusic")
        if 0 < canmusic then
          return true
        end
      end
    end
  end
  return false
end
function use_skill_musician(grid, index)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  nx_execute("custom_sender", "custom_use_item", grid.typeid, grid:GetBindIndex(index))
end
function is_using_pizhushu(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == "Pizhushu" then
    local toolbox_view = game_client:GetView(nx_string(grid.main_typeid))
    if nx_is_valid(toolbox_view) then
      local bind_index = grid:GetBindIndex(index)
      local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
      if nx_is_valid(viewobj) then
        local item_type = viewobj:QueryProp("ItemType")
        if item_type == ITEMTYPE_WEAPON_BOOK then
          return true
        end
      end
    end
  end
  return false
end
function use_skill_pizhushu(grid, index)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  local bind_index = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_send_annotate", grid.typeid, bind_index)
end
function is_using_pizhuhua(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == "Pizhuhua" then
    local toolbox_view = game_client:GetView(nx_string(grid.main_typeid))
    if nx_is_valid(toolbox_view) then
      local bind_index = grid:GetBindIndex(index)
      local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
      if nx_is_valid(viewobj) then
        local item_type = viewobj:QueryProp("ItemType")
        if item_type == ITEMTYPE_WEAPON_PAINT then
          return true
        end
      end
    end
  end
  return false
end
function use_skill_pizhuhua(grid, index)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  local bind_index = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_send_annotate", grid.typeid, bind_index)
end
function is_using_chaolu(grid, index)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return false
  end
  if gui.GameHand.Type ~= "Chaolu" then
    return false
  end
  return true
end
function use_skill_chaolu(grid, index)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  local bind_index = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_send_chaolu", grid.typeid, bind_index)
end
function is_using_life_skill_qianghua(grid, index)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return false
  end
  if gui.GameHand.Type ~= "qianghua" then
    return false
  end
  return true
end
function use_skill_life_skill_qianghua(grid, index)
  local gui = nx_value("gui")
  local bind_index = grid:GetBindIndex(index)
  nx_execute("form_stage_main\\form_life\\form_enhance_reduce", "on_open_form", grid.typeid, bind_index, nx_string(gui.GameHand.Para1))
  gui.GameHand:ClearHand()
end
function is_using_life_skill_splititem(grid, index)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return false
  end
  if gui.GameHand.Type ~= "splititem" then
    return false
  end
  return true
end
function use_skill_life_skill_splititem(grid, index)
  local gui = nx_value("gui")
  local bind_index = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_split_item", grid.typeid, bind_index, nx_string(gui.GameHand.Para1))
  gui.GameHand:ClearHand()
end
function is_Posion_ShotWeapon(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if gui.GameHand:IsEmpty() then
    return false
  end
  if "viewitem" ~= gui.GameHand.Type then
    return false
  end
  local toolbox_view = game_client:GetView(nx_string(grid.main_typeid))
  if not nx_is_valid(toolbox_view) then
    return false
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return false
  end
  local item_script = viewobj:QueryProp("EquipType")
  if "ShotWeapon" ~= item_script then
    return false
  end
  if not nx_find_custom(gui.GameHand, "indirect_select") then
    return false
  end
  if 1 ~= gui.GameHand.indirect_select then
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local Text = nx_widestr(gui.TextManager:GetText("ui_cuidu"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(Text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    gui.GameHand:ClearHand()
    return true
  end
  return false
end
function is_UseFixItem(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if gui.GameHand:IsEmpty() then
    return true
  end
  if gui.GameHand.Type ~= "fixitem" then
    return true
  end
  local toolbox_view = game_client:GetView(nx_string(grid.main_typeid))
  if not nx_is_valid(toolbox_view) then
    return false
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return false
  end
  local nItemType = 0
  if viewobj:FindProp("ItemType") then
    nItemType = viewobj:QueryProp("ItemType")
  end
  if nItemType < 100 or 199 < nItemType or nItemType == 190 or nItemType == 191 or 110 <= nItemType and nItemType <= 119 and nItemType ~= 116 or not viewobj:FindProp("MaxHardiness") then
    nx_execute("util_gui", "util_scrolltext", "fixitem_fail_1")
    return false
  end
  local nHardiness = 0
  if viewobj:FindProp("Hardiness") then
    nHardiness = viewobj:QueryProp("Hardiness")
  end
  local nMaxHardiness = viewobj:QueryProp("MaxHardiness")
  if nHardiness == nMaxHardiness then
    nx_execute("util_gui", "util_scrolltext", "fixitem_fail_2")
    return false
  end
  if not nx_find_custom(gui.GameHand, "indirect_select") then
    return false
  end
  return true
end
function get_repair_money(player, equip, is_normal)
  if not nx_is_valid(player) then
    return -1
  end
  if not nx_is_valid(equip) then
    return -1
  end
  local PowerLevel = nx_number(player:QueryProp("PowerLevel"))
  local MaxHardiness = nx_number(equip:QueryProp("MaxHardiness"))
  local Hardiness = nx_number(equip:QueryProp("Hardiness"))
  local SellPrice1 = nx_number(equip:QueryProp("SellPrice1"))
  local ColorLevel = nx_number(equip:QueryProp("ColorLevel"))
  if MaxHardiness == Hardiness then
    return -1
  end
  if MaxHardiness == 0 then
    return -1
  end
  local money = 0
  if is_normal then
    SellPrice1 = SellPrice1 / 200
    SellPrice1 = nx_number(nx_int(SellPrice1))
    money = (SellPrice1 + 1) * ColorLevel
  else
    money = PowerLevel * PowerLevel / 5
  end
  money = nx_number(nx_int(money))
  money = money * (MaxHardiness - Hardiness) * 100 / MaxHardiness
  return money
end
function show_form(repair_type, money, param1, param2, serviceman, silvertype, card_num, silver_num)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  serviceman = serviceman or 0
  silvertype = silvertype or 0
  local money_silver = nx_number(client_player:QueryProp("CapitalType1"))
  local money_silver_card = nx_number(client_player:QueryProp("CapitalType2"))
  local dec_maxhardiness_tip = ""
  if nx_int(silvertype) == nx_int(1) then
    dec_maxhardiness_tip = gui.TextManager:GetText("ui_repair_3")
  end
  local text = ""
  if nx_int(silver_num) == nx_int(0) then
    text = gui.TextManager:GetFormatText("ui_repair_2", nx_int(card_num), nx_widestr(dec_maxhardiness_tip))
  elseif nx_int(card_num) == nx_int(0) then
    text = gui.TextManager:GetFormatText("ui_repair_0", nx_int(silver_num), nx_widestr(dec_maxhardiness_tip))
  else
    text = gui.TextManager:GetFormatText("ui_repair_1", nx_int(silver_num), nx_int(card_num), nx_widestr(dec_maxhardiness_tip))
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if nx_int(repair_type) == nx_int(0) then
      local view_id = param1
      local index = param2
      nx_execute("custom_sender", "custom_send_repair_item", view_id, index, 1, nx_int(serviceman), nx_int(silvertype))
    else
      nx_execute("custom_sender", "custom_send_repair_all", 1, nx_int(serviceman), nx_int(silvertype))
    end
  end
end
function show_repair_addbag_form(viewid, index, money)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("ui_repair_2", nx_int(money), nx_widestr(""))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_repair_addbags", viewid, index, 1)
  end
end
function is_repair_addbags(repair_type, grid, typeid, index)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() or gui.GameHand.Type ~= repair_type then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local view = game_client:GetView(nx_string(typeid))
  if not nx_is_valid(view) then
    return false
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return false
  end
  if not viewobj:FindProp("ItemType") then
    return false
  end
  local item_type = viewobj:QueryProp("ItemType")
  if nx_int(item_type) == nx_int(31) then
    return true
  end
  return false
end
function begin_repair_addbags(grid, index)
  local bindindex = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_send_repair_addbags", grid.typeid, bindindex, 0)
end
function is_repair_goods(repair_type, grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == repair_type then
    local toolbox_view = game_client:GetView(nx_string(grid.main_typeid))
    if nx_is_valid(toolbox_view) then
      local bind_index = grid:GetBindIndex(index)
      local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
      if nx_is_valid(viewobj) and viewobj:FindProp("MaxHardiness") then
        return true
      end
    end
  end
  return false
end
function begin_repair(grid, index, serviceman, silvertype)
  local bindindex = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_send_repair_item", grid.typeid, bindindex, 0, serviceman, silvertype)
end
function get_item_needprop(view_ident, index)
  local gui = nx_value("gui")
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local game_client = nx_value("game_client")
  local otherstall_view = game_client:GetView(nx_string(view_ident))
  local viewobj = otherstall_view:GetViewObj(nx_string(index))
  if not nx_is_valid(viewobj) then
    return
  end
  local item_nameid = viewobj:QueryProp("ConfigID")
  local item_name = gui.TextManager:GetText(item_nameid)
  local base_name = nx_widestr(tips_manager:GetItemBaseName(viewobj))
  if not nx_ws_equal(base_name, nx_widestr("")) then
    item_name = base_name
  end
  local item_gold = viewobj:QueryProp("SellPrice0")
  local item_sivr = viewobj:QueryProp("SellPrice1")
  return item_name, item_gold, item_sivr
end
function do_split(grid, index)
  local form_split = nx_value("form_stage_main\\form_life\\form_job_split")
  if nx_is_valid(form_split) and form_split.Visible then
    nx_execute("form_stage_main\\form_life\\form_job_split", "add_split_item", grid.typeid, grid:GetBindIndex(index))
    return false
  end
  return true
end
function do_shop(grid, index)
  local form_shop = nx_value("form_stage_main\\form_shop\\form_shop")
  local game_gui = nx_value("gui")
  if nx_is_valid(form_shop) and form_shop.Visible then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local item_name, gold, silver
    item_name, gold, silver = get_item_needprop(grid.typeid, grid:GetBindIndex(index))
    if item_name == nil or gold == nil or silver == nil then
      return false
    end
    local amount = grid:GetItemNumber(index)
    local money_string = nx_execute("util_functions", "trans_capital_string", silver * amount)
    local sell_money = silver * amount
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local have_money = client_player:QueryProp("CapitalType1")
    local CapitalModule = nx_value("CapitalModule")
    local max_value = CapitalModule:GetMaxValue(1)
    local html_text = nx_widestr(game_gui.TextManager:GetText("ui_SureTo")) .. nx_widestr(item_name) .. nx_widestr("X") .. nx_widestr(amount) .. nx_widestr(game_gui.TextManager:GetText("ui_getmoneyaftersale")) .. money_string
    if max_value < sell_money + have_money then
      html_text = nx_widestr(game_gui.TextManager:GetText("ui_SureTo")) .. nx_widestr(item_name) .. nx_widestr("X") .. nx_widestr(amount) .. util_format_string("ui_sell_outnum", money_string)
    end
    dialog.mltbox_info.HtmlText = html_text
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      local game_client = nx_value("game_client")
      local view_item = game_client:GetView(nx_string(VIEWPORT_SHOP))
      if not nx_is_valid(view_item) then
        return false
      end
      local shopid = view_item:QueryProp("ShopID")
      nx_execute("custom_sender", "custom_sell_item", grid.typeid, grid:GetBindIndex(index), grid:GetItemNumber(index), shopid)
    end
    return false
  end
  return true
end
function do_bind(grid, index)
  local view_index = grid:GetBindIndex(index)
  local b_need_bind_equip = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "equip_itemobj_need_bind", grid.typeid, nx_int(view_index))
  local b_need_bind_use = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "use_itemobj_need_bind", grid.typeid, nx_int(view_index))
  if b_need_bind_equip or b_need_bind_use then
    local form = nx_null()
    local gui = nx_value("gui")
    if b_need_bind_equip then
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_equip", true)
      if nx_is_valid(form) then
        form.view_id = VIEWPORT_EQUIP
        form.item_index = tonumber(view_index)
        form.equip_grid = nx_null()
        form.src_viewid = grid.typeid
        form.AbsLeft = (gui.Width - form.Width) / 2
        form.AbsTop = (gui.Height - form.Height) / 4
        nx_execute("form_stage_main\\form_itembind\\form_itembind_equip", "set_form_showinfo")
        nx_execute("util_gui", "util_show_form", "form_stage_main\\form_itembind\\form_itembind_equip", true)
        gui.Desktop:ToFront(form)
      end
    else
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_use", true)
      if nx_is_valid(form) then
        form.view_id = grid.typeid
        form.item_index = tonumber(view_index)
        form.AbsLeft = (gui.Width - form.Width) / 2
        form.AbsTop = (gui.Height - form.Height) / 4
        local text = util_text("ui_item_bindtype_use")
        form.lbl_info:Clear()
        form.lbl_info:AddHtmlText(nx_widestr(text), -1)
        nx_execute("util_gui", "util_show_form", "form_stage_main\\form_itembind\\form_itembind_use", true)
        gui.Desktop:ToFront(form)
      end
    end
    return false
  end
  return true
end
function do_equipblend(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return true
  end
  local form_blend = nx_value("form_stage_main\\form_equipblend")
  if not nx_is_valid(form_blend) or not form_blend.Visible then
    return true
  end
  local blend_view = game_client:GetView(nx_string(VIEWPORT_EQUIP_BLEND_BOX))
  if not nx_is_valid(blend_view) then
    return true
  end
  local VIEW_MAIN = grid.main_typeid
  local tool_view = game_client:GetView(nx_string(VIEW_MAIN))
  if not nx_is_valid(tool_view) then
    return true
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = tool_view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return true
  end
  local lock_status = viewobj:QueryProp("LockStatus")
  if nx_int(lock_status) > nx_int(0) then
    return true
  end
  local item_type = viewobj:QueryProp("ItemType")
  local place_table = {
    [ITEMTYPE_EQUIP_HAT] = 0,
    [ITEMTYPE_HUANPIHEAD] = 1,
    [ITEMTYPE_EQUIP_CLOTH] = 2,
    [ITEMTYPE_HUANPICLOTH] = 3,
    [ITEMTYPE_EQUIP_PANTS] = 4,
    [ITEMTYPE_HUANPIPANTS] = 5,
    [ITEMTYPE_EQUIP_SHOES] = 6,
    [ITEMTYPE_HUANPISHOES] = 7
  }
  if place_table[item_type] == nil then
    return true
  end
  if nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) and not IsFashionOrSuit(viewobj) then
    local dst_pos = form_blend.grid_blend:GetBindIndex(place_table[item_type])
    nx_execute("custom_sender", "custom_add_equip_blend_item", VIEW_MAIN, bind_index, dst_pos)
    return false
  end
  if nx_int(item_type) >= nx_int(ITEMTYPE_HUANPIMIN) and nx_int(item_type) <= nx_int(ITEMTYPE_HUANPIMAX) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("37108"))
    return false
  end
  return true
end
function do_color_egg(grid, index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local VIEW_MAIN = grid.main_typeid
  local tool_view = game_client:GetView(nx_string(VIEW_MAIN))
  if not nx_is_valid(tool_view) then
    return false
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = tool_view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return false
  end
  if not viewobj:FindProp("ItemType") then
    return false
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  if nx_int(viewobj:QueryProp("ItemType")) == nx_int(ITEMTYPE_COLOR_EGG) then
    if switch_manager:CheckSwitchEnable(ST_SNDA_GEM_EGG_GAME) then
      nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\puzzle_quest\\form_select_egg")
    else
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("555505"), 2)
      end
    end
    return true
  else
    return false
  end
end
function do_equipblend_collect(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return true
  end
  local VIEW_MAIN = grid.main_typeid
  local tool_view = game_client:GetView(nx_string(VIEW_MAIN))
  if not nx_is_valid(tool_view) then
    return true
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = tool_view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return true
  end
  local lock_status = viewobj:QueryProp("LockStatus")
  if nx_int(lock_status) > nx_int(0) then
    return true
  end
  local item_type = viewobj:QueryProp("ItemType")
  if nx_int(item_type) >= nx_int(ITEMTYPE_HUANPIMIN) and nx_int(item_type) <= nx_int(ITEMTYPE_HUANPIMAX) then
    local title = gui.TextManager:GetText("str_tishi")
    local content = gui.TextManager:GetText("ui_blendcollect_confirm")
    local res = util_form_confirm(title, content, MB_OKCANCEL, true)
    if res == "ok" then
      nx_execute("custom_sender", "custom_equipblend_collect", VIEW_MAIN, bind_index)
    end
    return false
  end
  return true
end
function get_equip_pos(equip)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(equip) then
    return nil
  end
  return goods_grid:GetEquipPositionList(equip)
end
function do_onestep_equip(grid, index)
  local game_client = nx_value("game_client")
  local form = nx_value("form_stage_main\\form_role_info\\form_onestep_equip")
  local form_role_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if not nx_is_valid(form) or not nx_is_valid(form_role_info) then
    return true
  end
  if not form.Visible or not form_role_info.Visible then
    return true
  end
  if grid.typeid == VIEWPORT_EQUIP_TOOL or grid.typeid == VIEWPORT_EQUIP_ADDTOOLBOX then
    local tool_view = game_client:GetView(nx_string(grid.typeid))
    if not nx_is_valid(tool_view) then
      return true
    end
    local bind_index = grid:GetBindIndex(index)
    local viewobj = tool_view:GetViewObj(nx_string(bind_index))
    if not nx_is_valid(viewobj) then
      return true
    end
    local sureequip = false
    local b_need_bind = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "equip_itemobj_need_bind", nx_int(grid.typeid), nx_int(bind_index))
    if b_need_bind then
      local dialog = nx_execute("form_stage_main\\form_role_info\\form_onestep_equip", "show_dialog_tip", nx_int(grid.typeid), nx_int(bind_index))
      local res = nx_wait_event(100000000, dialog, "onestep_equip_confirm_return")
      if res == "ok" then
        sureequip = true
      end
    else
      sureequip = true
    end
    if sureequip == false then
      return false
    end
    local ret = nx_execute("form_stage_main\\form_role_info\\form_onestep_equip", "get_gridindex_by_item", viewobj)
    if ret == -1 then
      table_pos = get_equip_pos(viewobj)
      local index = table_pos[1]
      if index == nil then
        return false
      end
      local proj = form.sel_index
      local pos = index
      local item_unid = viewobj:QueryProp("UniqueID")
      nx_execute("custom_sender", "custom_onestep_equip_msg_add", proj, pos, item_unid)
      return false
    elseif ret == 100 then
      return false
    else
      local index = form.equip_grid:GetBindIndex(ret)
      local proj = form.sel_index
      local pos = index
      local item_unid = viewobj:QueryProp("UniqueID")
      nx_execute("custom_sender", "custom_onestep_equip_msg_add", proj, pos, item_unid)
      return false
    end
  end
  return true
end
function IsFashionOrSuit(item)
  if not nx_is_valid(item) then
    return false
  end
  if not item:FindProp("EquipType") then
    return false
  end
  local equip_type = item:QueryProp("EquipType")
  if nx_string(equip_type) == nx_string("Suit") or nx_string(equip_type) == nx_string("FashionHat") or nx_string(equip_type) == nx_string("FashionCoat") or nx_string(equip_type) == nx_string("FashionShoes") then
    return true
  end
  return false
end
function show_addtoolbox(form, view_item, view_index)
  local beginindex = view_item:QueryProp("BeginPos")
  local endindex = view_item:QueryProp("EndPos")
  if form.addbox1 ~= nil then
    form.addbox1:Close()
    form.addbox1 = nil
    form.current_open = 0
  end
  form.addbox1 = show_new_addtoolbox(form, view_item, beginindex, endindex)
  form.addbox1.AbsLeft = form.AbsLeft - form.addbox1.Width
  form.addbox1.AbsTop = form.AbsTop
  form.current_open = view_index
  local valid_time = view_item:QueryProp("Hardiness")
  if valid_time <= 0 then
    for i = 1, endindex - beginindex + 1 do
      form.addbox1.goods_grid:SetItemBackImage(nx_int(i - 1), "gui\\common\\imagegrid\\X_bag.png")
    end
  end
end
function show_new_addtoolbox(form, view_item, beginindex, endindex)
  local gui = nx_value("gui")
  local addbox = nx_call("util_gui", "util_get_form", "form_stage_main\\form_separate_bag", true, true, nx_string(beginindex))
  form_addtool_init(form, addbox, beginindex, endindex)
  local configID = view_item:QueryProp("ConfigID")
  addbox.lbl_name.Text = nx_widestr(gui.TextManager:GetText(configID))
  addbox:Show()
  return addbox
end
function form_addtool_init(form, addbox, beginindex, endindex)
  local cur_grid = form.cur_grid
  local grid = addbox.goods_grid
  local capacity = endindex - beginindex + 1
  grid.RowNum = nx_int(1)
  grid.ClomnNum = nx_int(capacity)
  nx_execute(get_bag_name(), "init_grid", grid, cur_grid.main_typeid, cur_grid.addtypeid)
  for i = 0, capacity - 1 do
    grid:SetBindIndex(nx_int(i), nx_int(beginindex + i))
  end
  refresh_pos(addbox, capacity)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(cur_grid.main_typeid, grid, get_bag_name(), "on_view_operat")
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(grid)
  end
end
function refresh_pos(form, size)
  local gui = nx_value("gui")
  local gridspos = ""
  local i = 0
  while size > i do
    local row = nx_int(i / 4)
    local column = nx_int(i % 4)
    gridspos = gridspos .. nx_string(nx_int(column * 60)) .. "," .. nx_string(nx_int(row * 60)) .. ";"
    i = i + 1
  end
  form.goods_grid.GridsPos = gridspos
  form.goods_grid.Height = nx_int((size + 3) / 4) * 60 + 14
  form.Height = form.goods_grid.Height + 60
end
function clear_Cover_all(grid)
end
function show_Cover_by_configid(configid, flag, photo)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local grid, grid_index = goods_grid:GetToolBoxGridAndPos(configid)
  if not nx_is_valid(grid) or grid == nil then
    return
  end
  show_Cover_by_grid_index(grid, grid_index, flag, photo)
end
function show_Cover_by_grid_index(grid, grid_index, flag, photo)
  grid.DrawCover = photo
  grid:CoverItem(grid_index, flag)
end
function show_color_addbox(index, flag)
  local form = nx_value(get_bag_name())
  if not nx_is_valid(form) then
    return
  end
  local cur_grid = form.cur_grid
  local game_client = nx_value("game_client")
  local addbagview = game_client:GetView(nx_string(cur_grid.addtypeid))
  if not nx_is_valid(addbagview) then
    return
  end
  local smallbag = addbagview:GetViewObj(nx_string(index + 1))
  if nx_is_valid(smallbag) then
    local beginindex, endindex = get_addbag_range(form, index)
    for i = beginindex, endindex do
      if flag == false then
        cur_grid:SetItemCoverImage(i, "")
      else
        cur_grid:SetItemCoverImage(i, "gui\\common\\imagegrid\\icon_mouse_on.png")
      end
      cur_grid:CoverItem(i, flag)
    end
  end
end
function set_addbox_CoverItem(index, flag)
  local form = nx_value(get_bag_name())
  if not nx_is_valid(form) then
    return
  end
  local cur_grid = form.cur_grid
  local game_client = nx_value("game_client")
  local addbagview = game_client:GetView(nx_string(cur_grid.addtypeid))
  if not nx_is_valid(addbagview) then
    return
  end
  local smallbag = addbagview:GetViewObj(nx_string(index + 1))
  if nx_is_valid(smallbag) then
    local beginindex, endindex = get_addbag_range(form, index)
    for i = beginindex, endindex do
      cur_grid:CoverItem(i, flag)
    end
  end
end
function get_addbag_range(form, index)
  local cur_grid = form.cur_grid
  local cur_addgrid = form.cur_addgrid
  local game_client = nx_value("game_client")
  local bag_view = game_client:GetView(nx_string(cur_grid.main_typeid))
  local base_cap = bag_view:QueryProp("BaseCap")
  local addbag_view = game_client:GetView(nx_string(cur_grid.addtypeid))
  if not nx_is_valid(addbag_view) then
    return
  end
  for i = 0, index - 1 do
    local small_bag = addbag_view:GetViewObj(nx_string(i + 1))
    if nx_is_valid(small_bag) then
      local beginindex = small_bag:QueryProp("BeginPos")
      local endindex = small_bag:QueryProp("EndPos")
      local count = endindex - beginindex + 1
      base_cap = base_cap + count
    end
  end
  local small_bag = addbag_view:GetViewObj(nx_string(index + 1))
  local beginindex = small_bag:QueryProp("BeginPos")
  local endindex = small_bag:QueryProp("EndPos")
  local count = endindex - beginindex + 1
  return base_cap, base_cap + count - 1
end
function change_grid_toBW_all(grid, flag)
  if not nx_is_valid(grid) then
    return
  end
  local count = grid.RowNum * grid.ClomnNum
  for index = 0, count - 1 do
    grid:ChangeItemImageToBW(index, flag)
  end
end
function change_grid_toBW_by_id(grid, unique_id, flag)
  local game_client = nx_value("game_client")
  local view_id = grid.typeid
  local count = grid.RowNum * grid.ClomnNum
  for index = 0, count - 1 do
    local view_index = grid:GetBindIndex(index)
    local view_item = game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
    if nx_is_valid(view_item) then
      local the_unique_id = view_item:QueryProp("UniqueID")
      if the_unique_id == unique_id then
        grid:ChangeItemImageToBW(index, flag)
        return
      end
    end
  end
end
function open_bag_by_configid(configid)
  local form = nx_value(get_bag_name())
  if not nx_is_valid(form) then
    return false
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return false
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false
  end
  local count = goods_grid:GetItemCount(configid)
  if count == 0 then
    return false
  end
  local bag_no = item_query:GetItemPropByConfigID(configid, "ViewID")
  bag_no = tonumber(bag_no)
  local rbtn
  if bag_no == 1 then
    rbtn = form.rbtn_tool
  elseif bag_no == 2 then
    rbtn = form.rbtn_equip
  elseif bag_no == 3 then
    rbtn = form.rbtn_material
  elseif bag_no == 4 then
    rbtn = form.rbtn_task
  end
  if rbtn ~= nil and nx_is_valid(rbtn) then
    nx_execute(get_bag_name(), "auto_show_hide_bag")
    rbtn.Checked = true
    return true
  end
  return false
end
function use_grid_item_skill()
  local fight = nx_value("fight")
  local goods_grid = nx_value("GoodsGrid")
  if not nx_find_custom(goods_grid, "skill_id") then
    return 0
  end
  local skill_id = goods_grid.skill_id
  if goods_grid.skill_id == nil or goods_grid.skill_id == "" then
    return 0
  end
  goods_grid.skill_id = nil
  local skill = fight:FindSkill(skill_id)
  if nx_is_valid(skill) then
    fight:TraceUseSkill(skill_id, false, false)
  elseif nx_string(skill_id) == nx_string("jn_escort001") then
    nx_execute("custom_sender", "custom_escort_skill", skill_id)
  end
end
function confirm_use_item(view_id, view_index)
  game_client = nx_value("game_client")
  local item = game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
  if not nx_is_valid(item) then
    return true
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return true
  end
  local item_type = item:QueryProp("ItemType")
  local text = ""
  if nx_number(item_type) == nx_number(ITEMTYPE_COMPOSE_LILIANYAO) then
    text = gui.TextManager:GetText("ui_lilianyao_01")
  elseif nx_number(item_type) == nx_number(ITEMTYPE_COMPOSE_LLY_NEW) then
    text = gui.TextManager:GetText("ui_lilianyao_01")
  elseif nx_number(item_type) == nx_number(ITEMTYPE_CHANGE_LIVEPROP) then
    text = gui.TextManager:GetText("ui_home_tinengyao_02")
  elseif nx_number(item_type) == nx_number(ITEMTYPE_FIND_TREASURE) then
    local item_fun = item:QueryProp("FuncPack")
    if nx_number(item_fun) == nx_number(8201) then
      text = gui.TextManager:GetText("info_wbhd_wb_01")
    else
      return true
    end
  else
    if item:FindProp("AddBufferList") then
      local str_buffer_list = item:QueryProp("AddBufferList")
      local strlst = util_split_string(str_buffer_list, ";")
      local client_player = game_client:GetPlayer()
      if nx_is_valid(client_player) then
        for i = 1, table.getn(strlst) do
          local result = nx_function("find_replace_buffer_in_rec", client_player, nx_string(strlst[i]), 3)
          if result ~= nil and 1 <= table.getn(result) then
            text = text .. "<br/>" .. nx_string("<font color=\"#eb7272\">") .. nx_string(gui.TextManager:GetText(result[1])) .. nx_string("</font>")
          end
        end
      end
    end
    if text == "" then
      return true
    end
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "confirm_use_item")
  if not nx_is_valid(dialog) then
    return false
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_buffer_replace")) .. nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_use_item_confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
end
