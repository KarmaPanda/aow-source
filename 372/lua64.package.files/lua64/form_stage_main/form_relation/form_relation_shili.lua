require("role_composite")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  change_form_size()
  self.groupbox_info.Visible = false
  self.mltbox_desc_ex.ViewRect = "0,0,478,100"
end
function on_main_form_close(self)
  nx_destroy(self)
end
function show_form(flag)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  if flag then
    local form_shili = nx_value("form_stage_main\\form_relation\\form_relation_shili")
    if not nx_is_valid(form_shili) then
      local form_shili = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_shili", true, false)
      if nx_is_valid(form_shili) then
        form:Add(form_shili)
      end
    else
      form_shili:Show()
      form_shili.Visible = true
    end
  else
    local form_shili = nx_value("form_stage_main\\form_relation\\form_relation_shili")
    if nx_is_valid(form_shili) then
      form_shili.Visible = false
    end
  end
end
function show_group_karma(groupid)
  local form_shili = nx_value("form_stage_main\\form_relation\\form_relation_shili")
  if not nx_is_valid(form_shili) then
    return
  end
  form_shili.shili_id = groupid
  nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "add_group_info", form_shili, groupid)
end
function on_tree_group_select_changed(tree, node)
  if nx_number(node.Level) ~= nx_number(2) then
    return
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  sns_manager:SetRelationType(RELATION_GROUP_SHILI, get_area_id(node.Mark))
end
function get_area_id(shili_id)
  local shili_list = find_shili_list()
  for i = 1, table.getn(shili_list) do
    if nx_number(shili_id) == nx_number(shili_list[i]) then
      return i - 1
    end
  end
  return 0
end
function get_shili_id(area_id)
  local shili_list = find_shili_list()
  if nx_number(area_id + 1) > nx_number(table.getn(shili_list)) then
    return 0
  end
  return shili_list[area_id + 1]
end
function find_shili_list()
  local shili_id_list = {}
  local index = 1
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  if READ_ALL_SHILI == 1 then
    for i = SHILI_MIN, SHILI_MAX do
      shili_id_list[index] = i
      index = index + 1
    end
  else
    for i = SHILI_MIN, SHILI_MAX do
      if not nx_execute("form_stage_main\\form_relationship", "is_unopened_shili", i) then
        if 0 <= player:FindRecordRow("GroupKarmaRec", 0, i, 0) then
          shili_id_list[index] = i
          index = index + 1
        else
          local npc_list_id = karmamgr:GetActiveGroupNpcNameList(i)
          if 0 < table.getn(npc_list_id) then
            shili_id_list[index] = i
            index = index + 1
          end
        end
      end
    end
  end
  return shili_id_list
end
function set_tree_node_select(shili_id)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_shili")
  if not nx_is_valid(form) then
    return
  end
  local tree = form.tree_group
  local node_list = tree:GetAllNodeList()
  for i = 1, table.getn(node_list) do
    local node = node_list[i]
    if nx_number(node.Level) == nx_number(2) and nx_number(node.Mark) == nx_number(shili_id) then
      tree.SelectNode = node
      return
    end
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local form_shili = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_shili", true, false)
  if nx_is_valid(form_shili) then
    form_shili.Left = 0
    form_shili.Top = 0
    form_shili.Width = form.Width
    form_shili.Height = form.Height - form.groupbox_rbtn.Height
    form_shili.groupbox_info.Width = form_shili.Width
    form_shili.groupbox_info.Height = form_shili.Height
  end
  local form_karma_prize = nx_value("form_stage_main\\form_relation\\form_npc_karma_prize_ex")
  if nx_is_valid(form_karma_prize) then
    nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "change_form_size", form_karma_prize)
  end
end
function on_relation_type_change_event(group_id, relation_type)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_shili")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_sns_backbutton1")
  gui.TextManager:Format_AddParam(client_player:QueryProp("Name"))
  local text = gui.TextManager:Format_GetText()
  gui.TextManager:Format_SetIDName("ui_sns_backbutton20")
  gui.TextManager:Format_AddParam(nx_int(6))
  text = text .. gui.TextManager:Format_GetText()
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local relation_group = sns_manager:GetRelationGroup(group_id)
  if nx_find_custom(relation_group, "group_index") then
    group_index = relation_group.group_index
  end
  if nx_int(group_index) == nx_int(RELATION_GROUP_SHILI) then
    form.groupbox_info.Visible = false
    form.groupscrollbox_group_list.Visible = true
    nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "init_shili", form)
    local shili_id = get_shili_id(relation_type)
    set_tree_node_select(shili_id)
  else
    select_npc(form, "", "")
    form.groupbox_info.Visible = true
    form.groupscrollbox_group_list.Visible = false
    if nx_int(group_index) >= nx_int(70) then
      local shili_id = get_shili_id(group_index - 70)
      show_group_karma(shili_id)
      gui.TextManager:Format_SetIDName("group_karma_" .. nx_string(shili_id))
      gui.TextManager:Format_AddParam(nx_int(7))
      text = text .. nx_widestr("\161\162<font color=\"#E1CC00\">") .. gui.TextManager:Format_GetText() .. nx_widestr("</font>")
    end
  end
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form_relationship) then
    return
  end
  form_relationship.mltbox_title:Clear()
  form_relationship.mltbox_title:AddHtmlText(nx_widestr(text), nx_int(-1))
end
function on_focus_change_event(group_id, relation_type, index, name)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_shili")
  if not nx_is_valid(form) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local groupbox_npc = form.groupbox_npc
  if not nx_find_custom(groupbox_npc, "group_id") then
    return
  end
  local strNpcList = karmamgr:GetGroupNpc(nx_int(groupbox_npc.group_id))
  local table_npc = util_split_string(nx_string(strNpcList), ";")
  local table_npc_info = util_split_string(nx_string(table_npc[index + 1]), ",")
  local npc_id = nx_string(table_npc_info[1])
  local scene_id = nx_string(table_npc_info[3])
  select_npc(form, npc_id, scene_id)
end
function on_gb_get_capture(gb)
end
function on_gb_lost_capture(gb)
end
function on_btn_npc_left_double_click(btn)
  local gb = btn.Parent
  local form = gb.ParentForm
  local npc_id = gb.Name
  local scene_id = gb.Scene
  if gb.selected == true then
    return
  end
  if nx_find_custom(gb.Parent, "group_id") then
    focus_npc(gb.Parent.group_id, npc_id)
  end
  select_npc(form, npc_id, scene_id)
end
function on_btn_npc_right_click(btn)
  local gb = btn.Parent
  local npcid = gb.Name
  local sceneid = gb.Scene
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "select_npc_karma_list", "select_npc_karma_list")
  nx_execute("menu_game", "menu_recompose", menu_game, npcid)
  menu_game.npc_id = nx_string(npcid)
  menu_game.scene_id = nx_string(sceneid)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x, y)
end
function focus_npc(shili_id, select_npc_id)
  group_id = get_area_id(shili_id) + 70
  nx_execute("form_stage_main\\form_relationship", "focus_player_model", group_id, 0, nx_widestr(select_npc_id))
end
function select_npc(form, select_npc_id, scene_id)
  local groupbox_npc = form.groupbox_npc
  if not nx_find_custom(groupbox_npc, "group_id") then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local strNpcList = karmamgr:GetGroupNpc(nx_int(groupbox_npc.group_id))
  local table_npc = util_split_string(nx_string(strNpcList), ";")
  local npc_num = table.getn(table_npc)
  for i = 1, npc_num do
    local table_npc_info = util_split_string(nx_string(table_npc[i]), ",")
    local npc_id = nx_string(table_npc_info[1])
    local gb_npc = groupbox_npc:Find(npc_id)
    if nx_is_valid(gb_npc) and nx_find_custom(gb_npc, "selected") then
      gb_npc.selected = false
      local lbl_select = gb_npc:Find("lbl_select" .. npc_id)
      lbl_select.BackImage = ""
    end
  end
  if select_npc_id == "" then
    return
  end
  local gb_select_npc = groupbox_npc:Find(select_npc_id)
  if nx_is_valid(gb_select_npc) and nx_find_custom(gb_select_npc, "selected") then
    gb_select_npc.selected = true
    local lbl_select = gb_select_npc:Find("lbl_select" .. select_npc_id)
    lbl_select.BackImage = "gui\\special\\sns_new\\bg_event_on.png"
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "add_npc_info", form, select_npc_id, scene_id)
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form_relationship) then
    return
  end
  local text = form_relationship.mltbox_title:GetHtmlItemText(0)
  text = text .. nx_widestr("\161\162") .. nx_widestr(util_text(nx_string(select_npc_id)))
  form_relationship.mltbox_title:Clear()
  form_relationship.mltbox_title:AddHtmlText(text, -1)
end
function refersh_npc_news()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_shili")
  if not nx_is_valid(form) then
    return
  end
  if form.groupscrollbox_group_list.Visible == true then
    form.tree_group.RootNode:ClearNode()
    nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "init_shili", form)
  elseif nx_find_custom(form.groupbox_npc, "group_id") then
    nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "refersh_npc_news_num", form, form.groupbox_npc.group_id)
  end
  if form.groupbox_desc.Visible == true and nx_find_custom(form, "shili_id") then
    nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "show_shili_news", form, form.shili_id)
  end
end
