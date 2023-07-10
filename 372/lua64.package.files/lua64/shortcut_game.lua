require("share\\view_define")
require("share\\logicstate_define")
require("util_static_data")
require("define\\gamehand_type")
require("const_define")
require("define\\camera_mode")
require("util_functions")
require("define\\sysinfo_define")
local shortcut_rec_name = "shortcut_rec"
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function get_view_item(view_id, view_index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  return game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
end
function get_shortcut_info_by_row(row)
  if row < 0 then
    return -1
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return -1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  if not client_player:FindRecord(shortcut_rec_name) then
    return -1
  end
  local index = client_player:QueryRecord(shortcut_rec_name, row, 0)
  local para1 = client_player:QueryRecord(shortcut_rec_name, row, 1)
  local para2 = client_player:QueryRecord(shortcut_rec_name, row, 2)
  return index, para1, para2
end
function get_shortcut_row_by_index(index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return -1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  if not client_player:FindRecord(shortcut_rec_name) then
    return -1
  end
  local row = client_player:FindRecordRow(shortcut_rec_name, 0, nx_int(index), 0)
  return row
end
function on_shortcut_click(grid, index, para3)
  local gui = nx_value("gui")
  local form_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  local game_hand = gui.GameHand
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if grid:IsEmpty(index) and game_hand:IsEmpty() then
    return 0
  end
  local beginindex = grid.beginindex + grid.page * (grid.RowNum * grid.ClomnNum)
  local endindex = beginindex + grid.RowNum * grid.ClomnNum
  if game_hand:IsEmpty() then
    local row = get_shortcut_row_by_index(index + beginindex)
    if 0 <= row then
      local photo = grid:GetItemImage(index)
      local amount = grid:GetItemNumber(index)
      if para3 == nil then
        para3 = ""
      end
      game_hand:SetHand(GHT_SHORTCUT, photo, nx_string(index + beginindex), "", para3, "")
    end
    return 0
  end
  local gamehand_type = game_hand.Type
  if gamehand_type == GHT_VIEWITEM then
    local view_id = nx_number(game_hand.Para1)
    local view_ident = nx_number(game_hand.Para2)
    local item = get_view_item(view_id, view_ident)
    local equip_type = ""
    if nx_is_valid(item) then
      equip_type = item:QueryProp("EquipType")
    end
    if (VIEWPORT_NEIGONG == view_id or is_equip_ng_shortcut(equip_type)) and not is_neigong_grid(grid) then
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_skill_tips_1"), CENTERINFO_PERSONAL_NO)
      end
      game_hand:ClearHand()
      return
    end
    if is_neigong_grid(grid) and view_id ~= VIEWPORT_NEIGONG and not is_equip_ng_shortcut(equip_type) then
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_skill_tips_2"), CENTERINFO_PERSONAL_NO)
      end
      game_hand:ClearHand()
      return
    end
    if put_view_item_into_shortcut(view_id, view_ident, index + beginindex) then
      game_hand:ClearHand()
    end
  elseif gamehand_type == GHT_SHORTCUT then
    local row = get_shortcut_row_by_index(game_hand.Para1)
    local index2, para1, para2 = get_shortcut_info_by_row(row)
    local GameShortcut = nx_value("GameShortcut")
    if not nx_is_valid(GameShortcut) then
      return
    end
    local item = GameShortcut:FindItemInBagByUID(nx_string(para2))
    local equip_type = ""
    if nx_is_valid(item) then
      equip_type = item:QueryProp("EquipType")
    end
    if is_neigong_grid(grid) and not is_in_neigong_grid(nx_number(game_hand.Para1), nx_number(game_hand.Para1)) then
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_skill_tips_2"), CENTERINFO_PERSONAL_NO)
      end
      game_hand:ClearHand()
      return
    end
    if is_in_neigong_grid(nx_number(game_hand.Para1), nx_number(game_hand.Para1)) and not is_neigong_grid(grid) then
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_skill_tips_1"), CENTERINFO_PERSONAL_NO)
      end
      game_hand:ClearHand()
      return
    end
    if put_other_short(index + beginindex, game_hand.Para1) then
      game_hand:ClearHand()
    end
  elseif gamehand_type == GHT_FUNC or gamehand_type == GHT_QIN or gamehand_type == GHT_BEG or gamehand_type == GHT_ACTION_FACE then
    local func = game_hand.Para1
    local func_para = game_hand.Para2
    if is_neigong_grid(grid) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_skill_tips_2"), CENTERINFO_PERSONAL_NO)
      end
      game_hand:ClearHand()
      return
    end
    if put_func_into_shortcut(func, func_para, index + beginindex) then
      game_hand:ClearHand()
    end
  elseif gamehand_type == GHT_SABLE then
    if is_neigong_grid(grid) and not is_in_neigong_grid(nx_number(game_hand.Para1), nx_number(game_hand.Para1)) then
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_skill_tips_2"), CENTERINFO_PERSONAL_NO)
      end
      game_hand:ClearHand()
      return
    end
    local func = game_hand.Para1
    local func_para = game_hand.Para2 .. ":" .. game_hand.Para3
    if put_func_into_shortcut(func, func_para, index + beginindex) then
      game_hand:ClearHand()
    end
  end
  return 1
end
function show_shortcut_tips(grid, index)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local game_shortcut = nx_value("GameShortcut")
  if not nx_is_valid(game_shortcut) then
    return
  end
  local fight = nx_value("fight")
  local beginindex = grid.beginindex + grid.page * (grid.RowNum * grid.ClomnNum)
  local row = get_shortcut_row_by_index(index + beginindex)
  if row < 0 then
    return
  end
  local left = grid:GetMouseInItemLeft()
  local index, para1, para2 = get_shortcut_info_by_row(row)
  if para1 == "item" then
    local item = game_shortcut:FindItemInBagByUID(para2)
    if nx_is_valid(item) then
      tips_manager.InShortcut = true
    end
    nx_execute("tips_game", "show_goods_tip", item, left, grid:GetMouseInItemTop(), 48, 48)
  elseif para1 == "qin" or para1 == "beg" then
    local IniManager = nx_value("IniManager")
    local iniformula = IniManager:GetIniDocument("share\\Item\\life_formula.ini")
    local sec_index = iniformula:FindSectionIndex(para2)
    local item_config = ""
    if 0 <= sec_index then
      item_config = iniformula:ReadString(sec_index, "ComposeResult", "")
    end
    if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
      return
    end
    local item_name, item_type
    local ItemQuery = nx_value("ItemQuery")
    local IniManager = nx_value("IniManager")
    if not nx_is_valid(ItemQuery) or not nx_is_valid(IniManager) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if nx_string(bExist) == nx_string("true") then
      item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
      item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
      local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
      local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
      local prop_array = {}
      prop_array.ConfigID = nx_string(item_config)
      prop_array.ItemType = nx_int(item_type)
      prop_array.Level = nx_int(item_level)
      prop_array.SellPrice1 = nx_int(item_sellPrice1)
      prop_array.Photo = nx_string(photo)
      if not nx_is_valid(grid.Data) then
        grid.Data = nx_call("util_gui", "get_arraylist", "shortcut_game_" .. item_config)
      end
      grid.Data:ClearChild()
      for prop, value in pairs(prop_array) do
        nx_set_custom(grid.Data, prop, value)
      end
      nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    end
  elseif para1 == "skill" then
    local skill = fight:FindSkill(para2)
    skill = fight:GetReplaceSkill(skill, false)
    if nx_is_valid(skill) then
      tips_manager.InShortcut = true
    end
    nx_execute("tips_game", "show_goods_tip", skill, left, grid:GetMouseInItemTop(), 48, 48)
  elseif para1 == "taolu" then
    local gui = nx_value("gui")
    local show_string = gui.TextManager:GetFormatText("tips_taolu", para2, "desc_" .. para2)
    nx_execute("tips_game", "show_text_tip", show_string, left, grid:GetMouseInItemTop())
  elseif para1 == "neigong" then
    local wuxue_query = nx_value("WuXueQuery")
    if not nx_is_valid(wuxue_query) then
      return
    end
    local neigong = wuxue_query:GetLearnID_NeiGong(para2)
    if not nx_is_valid(neigong) then
      return
    end
    if nx_is_valid(neigong) then
      tips_manager.InShortcut = true
    end
    nx_execute("tips_game", "show_neigong_tip", neigong, left, grid:GetMouseInItemTop(), 48, 48)
  elseif para1 == "qinggong" then
    local wuxue_query = nx_value("WuXueQuery")
    if not nx_is_valid(wuxue_query) then
      return
    end
    local qinggong = wuxue_query:GetLearnID_QGSkill(para2)
    if not nx_is_valid(qinggong) then
      return
    end
    nx_execute("tips_game", "show_goods_tip", qinggong, left, grid:GetMouseInItemTop(), 48, 48)
  elseif para1 == "zhenfa" then
    local wuxue_query = nx_value("WuXueQuery")
    if not nx_is_valid(wuxue_query) then
      return
    end
    local zhenfa = wuxue_query:GetLearnID_ZhenFa(para2)
    if not nx_is_valid(zhenfa) then
      return
    end
    if nx_is_valid(zhenfa) then
      tips_manager.InShortcut = true
    end
    nx_execute("tips_game", "show_goods_tip", zhenfa, left, grid:GetMouseInItemTop(), 48, 48)
  elseif para1 == "actionface" then
    local gui = nx_value("gui")
    local mutual_action = nx_value("mutual_action")
    local items_info = nx_widestr("")
    if nx_is_valid(mutual_action) then
      items_info = mutual_action:GetMutualActPackInfo(nx_string(para2))
    end
    local name = "ui_action_" .. nx_string(para2)
    gui.TextManager:Format_SetIDName(nx_string(name))
    gui.TextManager:Format_AddParam(nx_widestr(items_info))
    text = gui.TextManager:Format_GetText()
    local x = grid:GetMouseInItemLeft()
    local y = grid:GetMouseInItemTop()
    nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y, 0, grid.ParentForm)
  elseif para1 == "func" then
    if para2 == "normal_attack" or para2 == "normal_anqi_attack" then
      local skill_id = ""
      if para2 == "normal_attack" then
        skill_id = fight:GetNormalAttackSkillID()
      else
        skill_id = fight:GetNormalAnqiAttackSkillID(false)
        if skill_id == "" then
          local gui = nx_value("gui")
          local item = nx_execute("tips_game", "get_tips_ArrayList")
          if nx_is_valid(item) then
            item.ConfigID = "ui_normal_hw"
            item.ItemType = 1014
            tips_manager.InShortcut = true
            nx_execute("tips_game", "show_goods_tip", item, left, grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
          end
          return
        end
      end
      local skill = fight:FindSkill(skill_id)
      if nx_is_valid(skill) then
        tips_manager.InShortcut = true
      end
      nx_execute("tips_game", "show_goods_tip", skill, left, grid:GetMouseInItemTop(), 48, 48)
    else
      local func_manager = nx_value("func_manager")
      if nx_is_valid(func_manager) then
        local idname = func_manager:GetFuncTip(para2)
        local gui = nx_value("gui")
        local show_string = gui.TextManager:GetText(idname)
        if 0 ~= nx_ws_length(show_string) then
          nx_execute("tips_game", "show_text_tip", show_string, left, grid:GetMouseInItemTop())
        end
      end
    end
  elseif para1 == "sable" then
    local gui = nx_value("gui")
    local item = nx_execute("tips_game", "get_tips_ArrayList")
    if nx_is_valid(item) then
      local sub_table = util_split_string(nx_string(para2), ":")
      if table.getn(sub_table) == 2 then
        item.ConfigID = nx_string(sub_table[1])
        nx_execute("tips_game", "show_goods_tip", item, left, grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
      end
    end
  end
end
function put_view_item_into_shortcut(view_id, view_index, shortcut_index)
  local goods_grid = nx_value("GoodsGrid")
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(view_id)) then
    local item = get_view_item(view_id, view_index)
    if nx_is_valid(item) and item:FindProp("UniqueID") then
      local unique_id = item:QueryProp("UniqueID")
      set_shortcut(shortcut_index, "item", unique_id)
      if is_in_neigong_grid(shortcut_index, shortcut_index) then
        local grid = form.grid_shortcut_3
        local btn_index = shortcut_index - (grid.beginindex + grid.page * (grid.RowNum * grid.ClomnNum)) + 1
        if 5 < btn_index then
          grid = form.grid_shortcut_ng
          btn_index = shortcut_index - (grid.beginindex + grid.page * (grid.RowNum * grid.ClomnNum)) + 6
        end
        nx_execute("form_stage_main\\form_main\\form_main_shortcut", "open_bind_groupbox", btn_index)
      end
    end
  elseif view_id == VIEWPORT_SKILL or view_id == VIEWPORT_NORMALATTACK then
    local skill = get_view_item(view_id, view_index)
    if nx_is_valid(skill) then
      local skill_id = skill:QueryProp("ConfigID")
      set_shortcut(shortcut_index, "skill", skill_id)
    end
  elseif view_id == VIEWPORT_NEIGONG then
    local neigong = get_view_item(view_id, view_index)
    if nx_is_valid(neigong) then
      local neigong_id = neigong:QueryProp("ConfigID")
      set_shortcut(shortcut_index, "neigong", neigong_id)
      if is_in_neigong_grid(shortcut_index, shortcut_index) then
        local grid = form.grid_shortcut_3
        local btn_index = shortcut_index - (grid.beginindex + grid.page * (grid.RowNum * grid.ClomnNum)) + 1
        if 5 < btn_index then
          grid = form.grid_shortcut_ng
          btn_index = shortcut_index - (grid.beginindex + grid.page * (grid.RowNum * grid.ClomnNum)) + 6
        end
        nx_execute("form_stage_main\\form_main\\form_main_shortcut", "open_bind_groupbox", btn_index)
      end
    end
  elseif view_id == VIEWPORT_QINGGONG then
    local qinggong = get_view_item(view_id, view_index)
    if nx_is_valid(qinggong) then
      local qinggong_id = qinggong:QueryProp("ConfigID")
      set_shortcut(shortcut_index, "qinggong", qinggong_id)
    end
  elseif view_id == VIEWPORT_ZHENFA then
    local zhenfa = get_view_item(view_id, view_index)
    if nx_is_valid(zhenfa) then
      local zhenfa_id = zhenfa:QueryProp("ConfigID")
      set_shortcut(shortcut_index, "zhenfa", zhenfa_id)
    end
  end
  return true
end
function put_func_into_shortcut(func, func_para, shortcut_index)
  set_shortcut(shortcut_index, func, func_para)
  return true
end
function put_other_short(self_index, other_index)
  if nx_number(self_index) == nx_number(other_index) then
    return true
  end
  local self_row = get_shortcut_row_by_index(self_index)
  local other_row = get_shortcut_row_by_index(other_index)
  local _, self_para1, self_para2 = get_shortcut_info_by_row(self_row)
  local _, other_para1, other_para2 = get_shortcut_info_by_row(other_row)
  remove_shortcut(self_index)
  if nx_number(other_index) > -1 and other_para1 ~= nil and other_para2 ~= nil then
    set_shortcut(self_index, other_para1, other_para2)
  end
  remove_shortcut(other_index)
  if nx_number(self_index) > -1 and self_para1 ~= nil and self_para2 ~= nil then
    set_shortcut(other_index, self_para1, self_para2)
  end
  return true
end
function remove_shortcut(index)
  nx_execute("custom_sender", "custom_remove_shortcut", index)
end
function set_shortcut(index, para1, para2)
  nx_execute("custom_sender", "custom_set_shortcut", index, para1, para2)
end
function is_in_neigong_grid(lhs_index, rhs_index)
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return false
  end
  local neigong_grid = form.grid_shortcut_3
  local sub_ng_grid = form.grid_shortcut_ng
  lhs_index = nx_number(lhs_index)
  rhs_index = nx_number(rhs_index)
  return (lhs_index >= neigong_grid.beginindex and lhs_index <= neigong_grid.endindex or lhs_index >= sub_ng_grid.beginindex and lhs_index <= sub_ng_grid.endindex) and (rhs_index >= neigong_grid.beginindex and rhs_index <= neigong_grid.endindex or rhs_index >= sub_ng_grid.beginindex and rhs_index <= sub_ng_grid.endindex)
end
function is_neigong_grid(grid)
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return false
  end
  local neigong_grid = form.grid_shortcut_3
  local sub_ng_grid = form.grid_shortcut_ng
  return nx_id_equal(grid, neigong_grid) or nx_id_equal(grid, sub_ng_grid)
end
function is_equip_ng_shortcut(equip_type)
  local equip_type = nx_string(equip_type)
  return equip_type == "Wrist" or equip_type == "Leg" or equip_type == "ShotWeapon" or equip_type == "Weapon"
end
function mouse_use_item(visual_target, mouse_side)
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  local index = 0
  if mouse_side == "left" then
    index = -1
  elseif mouse_side == "right" then
    index = -2
  end
  local trace = nx_value("path_finding")
  trace:TraceTarget(visual_target, 2, "", "")
end
function on_shortcut_record_change(grid, recordname, optype, row, clomn)
end
