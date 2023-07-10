require("util_gui")
require("util_functions")
require("form_stage_main\\form_chat_system\\chat_util_define")
require("form_stage_main\\switch\\switch_define")
local RELATION_TYPE_FRIEND = 0
local RELATION_TYPE_BUDDY = 1
local RELATION_TYPE_ENEMY = 3
local RELATION_TYPE_BLOOD = 4
local RELATION_TYPE_ATTENTION = 5
local RELATION_TYPE_ACQUAINT = 6
local FORM_CHAT_PANEL = "form_stage_main\\form_chat_system\\form_chat_panel"
local FORM_CHAT_GROUP = "form_stage_main\\form_chat_system\\form_chat_group"
local FORM_CHAT_AD_SETTING = "form_stage_main\\form_chat_system\\form_chat_ad_setting"
local FORM_INPUT_NAME = "form_stage_main\\form_relation\\form_input_name"
local FORM_STATE_MENU = "form_stage_main\\form_main\\form_state_menu"
local FORM_SEARCH_GUILD = "form_stage_main\\form_relation\\form_relation_guild\\form_search_guild"
local FORM_CREATE_GUILD = "form_stage_main\\form_relation\\form_relation_guild\\form_create_guild"
local FORM_GUILD_QUIT = "form_stage_main\\form_relation\\form_relation_guild\\form_guild_quit_confirm"
local FORM_QIFU = "form_stage_main\\form_relation\\form_qifu"
local FORM_PRESENT = "form_stage_main\\form_relation\\form_present"
local FORM_REQUEST_RIGHT = "form_stage_main\\form_main\\form_main_request_right"
local PRESENT_REC = "rec_present"
local QIFU_REC = "rec_qifu"
local fold_normalimage = "gui\\common\\button\\btn_maximum_out.png"
local fold_focusimage = "gui\\common\\button\\btn_maximum_on.png"
local fold_pushimage = "gui\\common\\button\\btn_maximum_down.png"
local unfold_normalimage = "gui\\common\\button\\btn_minimum_out.png"
local unfold_focusimage = "gui\\common\\button\\btn_minimum_on.png"
local unfold_pushimage = "gui\\common\\button\\btn_minimum_down.png"
local icon_friendly = "gui\\special\\sns_new\\icon_relation_1.png"
local icon_enmity = "gui\\special\\sns_new\\icon_relation_2.png"
local color_online = "255,255,255,255"
local color_offline = "255,128,128,128"
local TreeNodeList = {
  {mark_type = "partner", ui_tag = "ui_fuqi_01"},
  {
    mark_type = "sworn",
    ui_tag = "ui_sworn_01"
  },
  {
    mark_type = "newteacher",
    ui_tag = "ui_pupil_01"
  },
  {
    mark_type = "friend",
    ui_tag = "ui_haoyou_01"
  },
  {
    mark_type = "buddy",
    ui_tag = "ui_zhiyou_01"
  },
  {
    mark_type = "attention",
    ui_tag = "ui_guanzhu_01"
  },
  {
    mark_type = "acquaint",
    ui_tag = "ui_jieshi_01"
  },
  {
    mark_type = "enemy",
    ui_tag = "ui_chouren_01"
  },
  {
    mark_type = "blood",
    ui_tag = "ui_xuechou_01"
  },
  {
    mark_type = "filter",
    ui_tag = "ui_heimingdan_01"
  },
  {
    mark_type = "filter_native",
    ui_tag = "ui_filter_native"
  }
}
function main_form_init(form)
  form.Fixed = false
  form.treenode_list = nil
  form.treenode_karma_list = nil
  form.treenode_groupchat_list = nil
end
function main_form_open(form)
  change_form_size()
  form.groupbox_relations.Visible = true
  form.groupbox_guilds.Visible = false
  form.groupbox_karma.Visible = false
  form.groupbox_groupchat.Visible = false
  InitForm_Relation(form)
  InitForm_Guild(form)
  InitForm_Karma(form)
  InitForm_CheckAds(form)
  InitForm_Groupchat(form)
  UpdateFilterNative()
  init_qifu_present(form)
  add_relation_binder(form)
  add_guild_binder(form)
  add_karma_binder(form)
  add_qifu_binder(form)
  add_groupchat_binder(form)
  nx_execute(FORM_STATE_MENU, "refresh_btn_state_menu_image")
  local VScrollBar = form.groupbox_playerlist.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  request_is_in_rtm()
end
function main_form_close(form)
  local form_state_menu = nx_value(FORM_STATE_MENU)
  if nx_is_valid(form_state_menu) then
    form_state_menu:Close()
  end
  if nx_is_valid(form.treenode_list) then
    form.treenode_list:ClearChild()
    nx_destroy(form.treenode_list)
  end
  del_relation_binder(form)
  del_guild_binder(form)
  del_karma_binder(form)
  del_qifu_binder(form)
  del_groupchat_binder(form)
  nx_destroy(form)
end
function reset_scene()
  local form = nx_value(FORM_CHAT_PANEL)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_state_click(btn)
  local form = btn.ParentForm
  local form_state_menu = util_auto_show_hide_form(FORM_STATE_MENU)
  if not nx_is_valid(form) or not nx_is_valid(form_state_menu) then
    return
  end
  form_state_menu.AbsLeft = form.AbsLeft - form_state_menu.Width
  form_state_menu.AbsTop = form.AbsTop + 25
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_relation_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_relations.Visible = true
    form.groupbox_guilds.Visible = false
    form.groupbox_karma.Visible = false
    form.groupbox_groupchat.Visible = false
  end
end
function on_rbtn_guild_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_relations.Visible = false
    form.groupbox_guilds.Visible = true
    form.groupbox_karma.Visible = false
    form.groupbox_groupchat.Visible = false
  end
end
function on_rbtn_enchou_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_karma.Visible = true
    form.groupbox_relations.Visible = false
    form.groupbox_guilds.Visible = false
    form.groupbox_groupchat.Visible = false
  end
end
function on_rbtn_groupchat_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local switch_manager = nx_value("SwitchManager")
    if nx_is_valid(switch_manager) then
      local ST_FUNCTION_GROUP_CHAT = 514
      local open = switch_manager:CheckSwitchEnable(ST_FUNCTION_GROUP_CHAT)
      if open then
        form.groupbox_groupchat.Visible = true
      else
        form.groupbox_groupchat.Visible = false
      end
    end
    form.groupbox_karma.Visible = false
    form.groupbox_relations.Visible = false
    form.groupbox_guilds.Visible = false
  end
end
function on_btnadsetting_click(btn)
  local form_chat_ad_setting = nx_value(FORM_CHAT_AD_SETTING)
  if nx_is_valid(form_chat_ad_setting) then
    form_chat_ad_setting:Close()
  else
    util_show_form(FORM_CHAT_AD_SETTING, true)
  end
end
function on_btn_intropupil_click(btn)
  nx_execute("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_msg_new", "show_main_reg_shixiong_page")
end
function on_btn_introfriend_click(btn)
  nx_execute("custom_sender", "custom_recommend_friends")
end
function on_btn_find_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", FORM_INPUT_NAME, true, false)
  if nx_is_valid(dialog) then
    dialog:ShowModal()
    nx_execute(FORM_INPUT_NAME, "is_siliao", false)
  end
end
function on_btn_chat_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", FORM_INPUT_NAME, true, false)
  if nx_is_valid(dialog) then
    dialog:ShowModal()
    nx_execute(FORM_INPUT_NAME, "is_siliao", true)
  end
end
function on_btn_mark_click(btn)
  local form = btn.ParentForm
  local mark = btn.Parent
  if not nx_is_valid(form) or not nx_is_valid(mark) then
    return
  end
  SetExtButtonStyle(mark, not mark.isUnfold)
  if mark.isUnfold then
    if nx_string(mark.mark_type) == "friend" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_FRIEND)
    elseif nx_string(mark.mark_type) == "buddy" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_BUDDY)
    elseif nx_string(mark.mark_type) == "attention" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_ATTENTION)
    elseif nx_string(mark.mark_type) == "acquaint" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_ACQUAINT)
    elseif nx_string(mark.mark_type) == "blood" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_BLOOD)
    elseif nx_string(mark.mark_type) == "enemy" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_ENEMY)
    end
  end
  AdjustTreeLayout(form.groupbox_playerlist)
  AdjustTreeKarmaLayout(form.groupscrollbox_karma_playerlist)
  AdjustTreeGroupchatLayout(form.groupscrollbox_groupchat_list)
end
function on_gchat_btn_mark_rclick(btn)
  local item = btn.Parent
  if not nx_is_valid(item) then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  local form = item.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_groupchat.Visible then
    nx_execute("menu_game", "menu_game_reset", "groupchat", "groupchat")
    nx_execute("menu_game", "menu_recompose", menu_game, item)
    menu_game.groupid = nx_string(item.groupid)
  end
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x + 25, y)
end
function on_btn_ext_click(btn)
  on_btn_mark_click(btn)
end
function on_btn_mark_left_double_click(btn)
  local form = btn.ParentForm
  local mark = btn.Parent
  if not nx_is_valid(form) or not nx_is_valid(mark) then
    return
  end
  if not nx_find_custom(mark, "groupid") then
    return
  end
  sendopen_groupchat(mark.groupid)
end
function on_item_select_changed(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local form = item.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    if form.groupbox_relations.Visible then
      ClearItemSelected(rbtn)
    elseif form.groupbox_karma.Visible then
      ClearKarmaItemSelected(rbtn)
    elseif form.groupbox_groupchat.Visible then
      ClearGroupchatItemSelected(rbtn)
    end
  end
end
function on_item_double_click(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local form = item.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_karma.Visible then
    return
  end
  local player_name = item.lbl_name.Text
  nx_execute("custom_sender", "custom_request_chat", player_name)
end
function on_item_right_click(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  local form = item.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_relations.Visible then
    nx_execute("menu_game", "menu_game_reset", "chat_panel", "chat_panel")
    nx_execute("menu_game", "menu_recompose", menu_game, item)
  elseif form.groupbox_karma.Visible then
    nx_execute("menu_game", "menu_game_reset", "select_npc_karma_list", "select_npc_karma_list")
    nx_execute("menu_game", "menu_recompose", menu_game, rbtn.npcid)
    menu_game.npc_id = nx_string(rbtn.npcid)
    menu_game.scene_id = nx_string(rbtn.sceneid)
  elseif form.groupbox_groupchat.Visible then
    nx_execute("menu_game", "menu_game_reset", "member_groupchat", "member_groupchat")
    nx_execute("menu_game", "menu_recompose", menu_game, item)
    menu_game.target_name = nx_widestr(item.target)
    menu_game.groupid = nx_string(item.groupid)
  end
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x + 25, y)
end
function on_lbl_revenge_get_capture(lbl)
  local gui = nx_value("gui")
  local item = lbl.Parent
  if not nx_is_valid(item) then
    return
  end
  if not nx_find_custom(item, "revenge_point") then
    return
  end
  local revenge_point = nx_int(item.revenge_point)
  local room_name = get_revenge_room_name(revenge_point)
  local out_text = nx_widestr("")
  gui.TextManager:Format_SetIDName("ui_tianti_jifen")
  gui.TextManager:Format_AddParam(revenge_point)
  out_text = out_text .. nx_widestr(gui.TextManager:Format_GetText()) .. nx_widestr("<br/>")
  local cn_name = gui.TextManager:GetText("ui_tianti_" .. room_name)
  gui.TextManager:Format_SetIDName("ui_tianti_zubie")
  gui.TextManager:Format_AddParam(cn_name)
  out_text = out_text .. nx_widestr(gui.TextManager:Format_GetText())
  local x, y = gui:GetCursorPosition()
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(out_text, x, y, -1, "0-0")
  end
end
function on_lbl_revenge_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip")
end
function on_table_rec_changed(form, rec_name, opt_type, row, col)
  local typename = get_typename_by_tablename(rec_name)
  if nx_string(typename) ~= "" then
    UpdateFormTree(form, typename)
    if nx_string(typename) == nx_string("friend") or nx_string(typename) == nx_string("buddy") then
      UpdateFormTree(form, "partner")
    end
  end
end
function on_player_prop_changed(form, prop_name, prop_type, prop_value)
  local typename = get_typename_by_propname(prop_name)
  if nx_string(typename) ~= "" then
    UpdateFormTree(form, typename)
  end
end
function on_karma_table_rec_changed(form, rec_name, opt_type, row, col)
  UpdateFormKarmaTree(form, "friend")
  UpdateFormKarmaTree(form, "buddy")
  UpdateFormKarmaTree(form, "attention")
end
function on_karma_attentiontable_rec_changed(form, rec_name, opt_type, row, col)
  UpdateFormKarmaTree(form, "attention")
end
function on_player_group_chat_rec_changed(form, rec_name, opt_type, row, col)
  if nx_string(opt_type) == "update" then
    UpdateFormGroupChatTree(form, "groupchat", row)
  else
    UpdateFormGroupChatTree2(form, "groupchat")
  end
end
function add_relation_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddTableBind(FRIEND_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(BUDDY_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(ATTENTION_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(ACQUAINT_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(ENEMY_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(BLOOD_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(FILTER_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(PUPIL_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(PUPIL_JINGMAI_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(SWORN_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(NEW_TEACHER_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddRolePropertyBind("PartnerNamePrivate", "widestr", form, nx_current(), "on_player_prop_changed")
  end
end
function del_relation_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind(FRIEND_REC, form)
    data_binder:DelTableBind(BLOOD_REC, form)
    data_binder:DelTableBind(ATTENTION_REC, form)
    data_binder:DelTableBind(ACQUAINT_REC, form)
    data_binder:DelTableBind(ENEMY_REC, form)
    data_binder:DelTableBind(BLOOD_REC, form)
    data_binder:DelTableBind(FILTER_REC, form)
    data_binder:DelTableBind(PUPIL_REC, form)
    data_binder:DelTableBind(PUPIL_JINGMAI_REC, form)
    data_binder:DelTableBind(SWORN_REC, form)
    data_binder:DelTableBind(NEW_TEACHER_REC, form)
    data_binder:DelRolePropertyBind("PartnerNamePrivate", form)
  end
end
function add_karma_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddTableBind(NPC_ATTENTION_REC, form, nx_current(), "on_karma_attentiontable_rec_changed")
    data_binder:AddTableBind(NPC_RELATION_REC, form, nx_current(), "on_karma_table_rec_changed")
  end
end
function del_karma_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind(NPC_ATTENTION_REC, form)
    data_binder:DelTableBind(NPC_RELATION_REC, form)
  end
end
function add_groupchat_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddTableBind(PLAYER_GROUP_CHAT_REC, form, nx_current(), "on_player_group_chat_rec_changed")
  end
end
function del_groupchat_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind(PLAYER_GROUP_CHAT_REC, form)
  end
end
function init_treenode_list(form)
  for i = 1, table.getn(TreeNodeList) do
    local node = TreeNodeList[i]
    local child = form.treenode_list:CreateChild(nx_string(node.mark_type))
    child.mark_type = node.mark_type
    child.ui_tag = node.ui_tag
    child.mark_node = nil
  end
end
function init_treenode_karma_list(form)
  local karmaNodeList = {
    {
      mark_type = "friend",
      ui_tag = "ui_haoyou_01"
    },
    {
      mark_type = "buddy",
      ui_tag = "ui_zhiyou_01"
    },
    {
      mark_type = "attention",
      ui_tag = "ui_guanzhu_01"
    }
  }
  for i = 1, table.getn(karmaNodeList) do
    local node = karmaNodeList[i]
    local child = form.treenode_karma_list:CreateChild(nx_string(node.mark_type))
    child.mark_type = node.mark_type
    child.ui_tag = node.ui_tag
    child.mark_node = nil
  end
end
function init_treenode_groupchat_list(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(PLAYER_GROUP_CHAT_REC) then
    return false
  end
  local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
  for i = 0, rows - 1 do
    local group_id = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_groupid)
    local group_name = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_groupname)
    local member_list = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_memberlist)
    local str_lst = util_split_wstring(nx_widestr(member_list), ";")
    local child = form.treenode_groupchat_list:CreateChild(group_id)
    child.mark_type = "groupchat"
    child.group_id = group_id
    child.member_list = member_list
    child.member_count = nx_int(table.getn(str_lst))
    child.ui_tag = group_name
    child.mark_node = nil
  end
end
function get_member_list(typename)
  if nx_string(typename) == "partner" then
    return get_partner_table()
  elseif nx_string(typename) == "sworn" then
    return get_sworn_table()
  elseif nx_string(typename) == "newteacher" then
    return get_new_teacher_table()
  elseif nx_string(typename) == "friend" then
    return get_friend_table()
  elseif nx_string(typename) == "buddy" then
    return get_buddy_table()
  elseif nx_string(typename) == "teacherpupil" then
    return get_pupil_table()
  elseif nx_string(typename) == "attention" then
    return get_attention_table()
  elseif nx_string(typename) == "acquaint" then
    return get_acquaint_table()
  elseif nx_string(typename) == "enemy" then
    return get_enemy_table()
  elseif nx_string(typename) == "blood" then
    return get_blood_table()
  elseif nx_string(typename) == "filter" then
    return get_filter_table()
  elseif nx_string(typename) == "filter_native" then
    return get_filter_native_table()
  else
    return {}
  end
end
function get_member_karma_list(typename)
  local result_table = {}
  if nx_string(typename) == nx_string("attention") then
    result_table = get_npc_attention_table()
  elseif nx_string(typename) == nx_string("friend") then
    result_table = get_npc_friend_table(0)
  elseif nx_string(typename) == nx_string("buddy") then
    result_table = get_npc_friend_table(1)
  end
  return result_table
end
function do_sort_byonline(record_table)
  local online_table = {}
  local offline_table = {}
  local count = table.getn(record_table)
  for i = 1, count do
    local record = record_table[i]
    if nx_int(record.online) == nx_int(0) then
      table.insert(online_table, record)
    else
      table.insert(offline_table, record)
    end
  end
  local new_table = {}
  count = table.getn(online_table)
  for i = 1, count do
    table.insert(new_table, online_table[i])
  end
  count = table.getn(offline_table)
  for i = 1, count do
    table.insert(new_table, offline_table[i])
  end
  return new_table
end
function gchat_do_sort_byonline(record_table)
  local online_table = {}
  local offline_table = {}
  local count = table.getn(record_table)
  for i = 1, count do
    local name_lst = util_split_wstring(nx_widestr(record_table[i]), ",")
    if nx_int(name_lst[2]) == nx_int(1) then
      table.insert(online_table, record_table[i])
    else
      table.insert(offline_table, record_table[i])
    end
  end
  local new_table = {}
  count = table.getn(online_table)
  for i = 1, count do
    table.insert(new_table, online_table[i])
  end
  count = table.getn(offline_table)
  for i = 1, count do
    table.insert(new_table, offline_table[i])
  end
  return new_table
end
function get_relation_karma_icon(karma_value)
  local information = {}
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return information
  end
  local sec_index = ini:FindSectionIndex("Karma")
  if nx_int(sec_index) < nx_int(0) then
    return information
  end
  local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(GroupMsgData)) do
    local stepData = util_split_string(GroupMsgData[i], ",")
    if nx_int(stepData[1]) <= nx_int(karma_value) and nx_int(karma_value) <= nx_int(stepData[2]) then
      information.photo = nx_string(stepData[4])
      information.hinttext = nx_string(stepData[3])
    end
  end
  return information
end
function get_relation_icon(typename)
  if nx_string(typename) == nx_string("enemy") or nx_string(typename) == nx_string("blood") then
    return icon_enmity
  elseif nx_string(typename) == nx_string("attention") or nx_string(typename) == nx_string("acquaint") or nx_string(typename) == nx_string("filter") or nx_string(typename) == nx_string("filter_native") or nx_string(typename) == nx_string("teacherpupil") then
    return ""
  else
    return icon_friendly
  end
end
function get_shane_icon(typename, flag, value)
  if nx_string(typename) == nx_string("partner") or nx_string(typename) == nx_string("friend") or nx_string(typename) == nx_string("buddy") or nx_string(typename) == nx_string("enemy") or nx_string(typename) == nx_string("blood") or nx_string(typename) == nx_string("sworn") then
    return get_shane_image(flag, value)
  end
  return ""
end
function get_revenge_room_icon(typename, revenge)
  if nx_string(typename) == nx_string("partner") or nx_string(typename) == nx_string("friend") or nx_string(typename) == nx_string("buddy") or nx_string(typename) == nx_string("enemy") or nx_string(typename) == nx_string("blood") or nx_string(typename) == nx_string("sworn") then
    local room_name = get_revenge_room_name(revenge)
    if room_name ~= "" then
      return "gui\\special\\tianti\\glory\\icon_" .. room_name .. ".png"
    end
  end
  return ""
end
function get_typename_by_tablename(rec_name)
  if nx_string(rec_name) == SWORN_REC then
    return "sworn"
  end
  if nx_string(rec_name) == NEW_TEACHER_REC then
    return "newteacher"
  end
  if string.find(nx_string(rec_name), "rec_") == nil then
    return ""
  end
  if nx_string(rec_name) == PUPIL_JINGMAI_REC then
    return "teacherpupil"
  end
  local typename = string.sub(nx_string(rec_name), string.len("rec_") + 1)
  return typename
end
function get_typename_by_propname(prop_name)
  if nx_string(prop_name) == "PartnerNamePrivate" then
    return "partner"
  else
    return ""
  end
end
function InitForm_CheckAds(form)
  form.btnadsetting.Visible = true
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) then
    local enable = switchmgr:CheckSwitchEnable(ST_FUNCTION_CHECKADS)
    if not enable then
      form.btnadsetting.Visible = false
    end
  end
end
function InitForm_Relation(form)
  local gui = nx_value("gui")
  form.groupbox_mark.Visible = false
  form.groupbox_item.Visible = false
  form.groupbox_intro.Visible = false
  form.treenode_list = nx_call("util_gui", "get_arraylist", "panel:treenode_list")
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return
  end
  ClearAllChild(form.groupbox_playerlist)
  init_treenode_list(form)
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    local mark = GetNewMark()
    if nx_is_valid(mark) then
      mark.mark_type = node.mark_type
      mark.lbl_title.Text = nx_widestr(gui.TextManager:GetText(node.ui_tag))
      mark.lbl_num.Text = nx_widestr("[0/0]")
      SetExtButtonStyle(mark, false)
      mark.Top = i * mark.Height
      node.mark_node = mark
    end
  end
  AdjustTreeLayout(form.groupbox_playerlist)
end
function InitForm_Karma(form)
  local gui = nx_value("gui")
  local treenode_karma_list = nx_call("util_gui", "get_arraylist", "panel:treenode_karma_list")
  if not nx_is_valid(treenode_karma_list) then
    return
  end
  form.treenode_karma_list = treenode_karma_list
  ClearAllChildKarma(form.groupscrollbox_karma_playerlist)
  init_treenode_karma_list(form)
  local list_count = treenode_karma_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_karma_list:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local mark = GetNewMark()
    if nx_is_valid(mark) then
      mark.mark_type = node.mark_type
      mark.lbl_title.Text = nx_widestr(gui.TextManager:GetText(node.ui_tag))
      mark.lbl_num.Text = nx_widestr("[0/0]")
      SetExtButtonStyle(mark, false)
      mark.Top = i * mark.Height
      node.mark_node = mark
    end
  end
  local VScrollBar = form.groupscrollbox_karma_playerlist.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  AdjustTreeKarmaLayout(form.groupscrollbox_karma_playerlist)
end
function InitForm_Groupchat(form)
  form.groupbox_gchat_mark.Visible = false
  form.groupbox_gchat_item.Visible = false
  local gui = nx_value("gui")
  local treenode_groupchat_list = nx_call("util_gui", "get_arraylist", "panel:treenode_groupchat_list")
  if not nx_is_valid(treenode_groupchat_list) then
    return
  end
  form.treenode_groupchat_list = treenode_groupchat_list
  ClearAllChildGroupchat(form.groupscrollbox_groupchat_list)
  init_treenode_groupchat_list(form)
  local list_count = treenode_groupchat_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_groupchat_list:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local mark = GetNewGChatMark()
    if nx_is_valid(mark) then
      mark.mark_type = node.mark_type
      mark.lbl_title.Text = nx_widestr(node.ui_tag)
      mark.lbl_num.Text = nx_widestr(string.format("[%s]", node.member_count))
      SetExtButtonStyle(mark, false)
      mark.Top = i * mark.Height
      mark.groupid = node.group_id
      if get_groupchat_shield(mark.groupid) then
        mark.lbl_shield.Visible = true
      else
        mark.lbl_shield.Visible = false
      end
      node.mark_node = mark
      local str_lst = util_split_wstring(nx_widestr(node.member_list), ";")
      local member_table = gchat_do_sort_byonline(str_lst)
      for j = 1, table.getn(member_table) do
        local name_lst = util_split_wstring(nx_widestr(member_table[j]), ",")
        local is_online = nx_int(name_lst[2])
        local new_item = GetNewGChatItem()
        if not nx_is_valid(new_item) then
          break
        end
        new_item.Visible = false
        new_item.mark_type = typename
        new_item.is_online = is_online
        new_item.is_online = nx_int(name_lst[2])
        new_item.lbl_name.Text = name_lst[1]
        if is_online == nx_int(1) then
          new_item.lbl_name.ForeColor = color_online
        else
          new_item.lbl_name.ForeColor = color_offline
        end
        new_item.target = name_lst[1]
        new_item.groupid = mark.groupid
        new_item.lbl_flag.Visible = false
        if is_groupchat_master(mark.groupid, name_lst[1]) then
          new_item.lbl_flag.Visible = true
        end
        local sub_node = node:CreateChild("")
        if not nx_is_valid(sub_node) then
          break
        end
        sub_node.item = new_item
      end
    end
  end
  local VScrollBar = form.groupscrollbox_groupchat_list.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  AdjustTreeGroupchatLayout(form.groupscrollbox_groupchat_list)
end
function UpdateFormTree(form, typename)
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return
  end
  local index = GetNodeIndex(typename)
  if index < 0 then
    return
  end
  local node = treenode_list:GetChildByIndex(index)
  local node_count = node:GetChildCount()
  for i = 0, node_count - 1 do
    local sub_node = node:GetChildByIndex(i)
    local item = sub_node.item
    if nx_is_valid(item) then
      item.Visible = false
      item.isneedremove = true
    end
  end
  local member_table = do_sort_byonline(get_member_list(typename))
  local member_count = table.getn(member_table)
  local online_count = 0
  for i = 1, table.getn(member_table) do
    local record = member_table[i]
    local is_online = nx_int(record.online) == nx_int(0)
    local hot_num = record.self_relation + record.target_relation
    local new_item = GetNewItem()
    new_item.Visible = false
    new_item.mark_type = typename
    new_item.is_online = is_online
    new_item.revenge_point = nx_int(record.revenge_point)
    new_item.lbl_mobile.Visible = nx_int(record.online) == nx_int(200)
    new_item.lbl_name.Text = nx_widestr(record.player_name)
    new_item.lbl_name.ForeColor = is_online and color_online or color_offline
    local icon_revenge = get_revenge_room_icon(typename, record.revenge_point)
    new_item.lbl_revenge.BackImage = icon_revenge
    new_item.lbl_revenge.Visible = icon_revenge ~= ""
    local icon_shane = get_shane_icon(typename, record.character_flag, record.character_value)
    new_item.lbl_shane.BackImage = icon_shane
    new_item.lbl_shane.Visible = icon_shane ~= ""
    new_item.lbl_shane.Left = 106.5 - new_item.lbl_shane.Width / 2
    new_item.lbl_shane.Top = 13.5 - new_item.lbl_shane.Height / 2
    local icon_path = get_relation_icon(typename)
    new_item.lbl_flag.BackImage = icon_path
    new_item.lbl_hot.Text = nx_widestr(nx_string(hot_num))
    new_item.lbl_flag.Visible = icon_path ~= ""
    new_item.lbl_hot.Visible = icon_path ~= ""
    local sub_node = node:CreateChild("")
    sub_node.item = new_item
    if is_online then
      online_count = online_count + 1
    end
  end
  local mark = node.mark_node
  mark.lbl_num.Text = nx_widestr(string.format("[%s/%s]", online_count, member_count))
  mark.online_count = online_count
  mark.member_count = member_count
  AdjustTreeLayout(form.groupbox_playerlist)
end
function UpdateFormKarmaTree(form, typename)
  local gui = nx_value("gui")
  local treenode_karma_list = form.treenode_karma_list
  if not nx_is_valid(treenode_karma_list) then
    return
  end
  local index = GetNodeKarmaIndex(typename)
  if index < 0 then
    return
  end
  local node = treenode_karma_list:GetChildByIndex(index)
  if not nx_is_valid(node) then
    return
  end
  local node_count = node:GetChildCount()
  for i = 0, node_count - 1 do
    local sub_node = node:GetChildByIndex(i)
    if not nx_is_valid(sub_node) then
      break
    end
    local item = sub_node.item
    if nx_is_valid(item) then
      item.Visible = false
      item.isneedremove = true
    end
  end
  local member_table = get_member_karma_list(typename)
  local member_count = table.getn(member_table)
  local online_count = 0
  for i = 1, table.getn(member_table) do
    local record = member_table[i]
    local is_online = true
    local new_item = GetNewItem()
    if not nx_is_valid(new_item) then
      break
    end
    local icon_path = ""
    if nx_int(record.karma) ~= nx_int(-100001) then
      local information = get_relation_karma_icon(record.karma)
      if information.photo ~= nil and information.hinttext ~= nil then
        icon_path = information.photo
        new_item.rbtn_item.HintText = gui.TextManager:GetText(information.hinttext)
      end
    elseif nx_int(record.karma) == nx_int(-100001) then
      icon_path = "gui\\mainform\\NPC\\Level_0.png"
      new_item.rbtn_item.HintText = gui.TextManager:GetText("ui_karma_rela4")
    end
    new_item.Visible = false
    new_item.mark_type = typename
    new_item.is_online = is_online
    new_item.lbl_name.Text = gui.TextManager:GetText(record.config)
    new_item.lbl_name.ForeColor = is_online and color_online or color_offline
    new_item.rbtn_item.npcid = record.config
    new_item.rbtn_item.sceneid = record.sceneid
    new_item.lbl_flag.DrawMode = "FitWindow"
    new_item.lbl_flag.Top = 0
    new_item.lbl_flag.Width = 17
    new_item.lbl_flag.Height = 24
    new_item.lbl_flag.AutoSize = false
    new_item.lbl_flag.BackImage = icon_path
    new_item.lbl_flag.Visible = icon_path ~= ""
    local sub_node = node:CreateChild("")
    if not nx_is_valid(sub_node) then
      break
    end
    sub_node.item = new_item
    if is_online then
      online_count = online_count + 1
    end
  end
  local mark = node.mark_node
  mark.lbl_num.Text = nx_widestr(string.format("[%s/%s]", online_count, member_count))
  mark.online_count = online_count
  mark.member_count = member_count
  AdjustTreeKarmaLayout(form.groupscrollbox_karma_playerlist)
end
function UpdateFormGroupChatTree(form, typename, index)
  if nx_int(index) < nx_int(0) then
    return
  end
  local treenode_groupchat_list = form.treenode_groupchat_list
  if not nx_is_valid(treenode_groupchat_list) then
    return
  end
  local list_count = treenode_groupchat_list:GetChildCount()
  if nx_int(index) >= nx_int(list_count) then
    return
  end
  local node = treenode_groupchat_list:GetChildByIndex(index)
  local node_count = node:GetChildCount()
  for i = 0, node_count - 1 do
    local sub_node = node:GetChildByIndex(i)
    local item = sub_node.item
    if nx_is_valid(item) then
      item.Visible = false
      item.isneedremove = true
    end
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(PLAYER_GROUP_CHAT_REC) then
    return
  end
  local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
  if index > rows then
    return
  end
  local group_id = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, index, player_group_rec_groupid)
  local group_name = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, index, player_group_rec_groupname)
  local member_list = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, index, player_group_rec_memberlist)
  local sheild = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, index, player_group_rec_shield)
  local str_lst = util_split_wstring(nx_widestr(member_list), ";")
  node.mark_type = "groupchat"
  node.group_id = group_id
  node.member_list = member_list
  node.member_count = nx_int(table.getn(str_lst))
  node.ui_tag = group_name
  node.mark_node.lbl_num.Text = nx_widestr(string.format("[%s]", node.member_count))
  if nx_int(sheild) == nx_int(1) then
    node.mark_node.lbl_shield.Visible = true
  else
    node.mark_node.lbl_shield.Visible = false
  end
  local str_lst = util_split_wstring(nx_widestr(node.member_list), ";")
  local member_table = gchat_do_sort_byonline(str_lst)
  for j = 1, table.getn(member_table) do
    local new_item = GetNewGChatItem()
    if not nx_is_valid(new_item) then
      break
    end
    local name_lst = util_split_wstring(nx_widestr(member_table[j]), ",")
    local is_online = nx_int(name_lst[2])
    new_item.Visible = false
    new_item.mark_type = typename
    new_item.is_online = nx_int(name_lst[2])
    new_item.lbl_name.Text = name_lst[1]
    if is_online == nx_int(1) then
      new_item.lbl_name.ForeColor = color_online
    else
      new_item.lbl_name.ForeColor = color_offline
    end
    new_item.target = name_lst[1]
    new_item.groupid = node.group_id
    new_item.lbl_flag.Visible = false
    if is_groupchat_master(new_item.groupid, name_lst[1]) then
      new_item.lbl_flag.Visible = true
    end
    local sub_node = node:CreateChild("")
    if not nx_is_valid(sub_node) then
      break
    end
    sub_node.item = new_item
  end
  AdjustTreeGroupchatLayout(form.groupscrollbox_groupchat_list)
end
function UpdateFormGroupChatTree2(form, typename)
  local treenode_groupchat_list = form.treenode_groupchat_list
  if not nx_is_valid(treenode_groupchat_list) then
    return
  end
  ClearAllChildGroupchat(form.groupscrollbox_groupchat_list)
  init_treenode_groupchat_list(form)
  local list_count = treenode_groupchat_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_groupchat_list:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local mark = GetNewGChatMark()
    if nx_is_valid(mark) then
      mark.mark_type = node.mark_type
      mark.lbl_title.Text = nx_widestr(node.ui_tag)
      mark.lbl_num.Text = nx_widestr(string.format("[%s]", node.member_count))
      SetExtButtonStyle(mark, false)
      mark.Top = i * mark.Height
      mark.groupid = node.group_id
      if get_groupchat_shield(mark.groupid) then
        mark.lbl_shield.Visible = true
      else
        mark.lbl_shield.Visible = false
      end
      node.mark_node = mark
      local str_lst = util_split_wstring(nx_widestr(node.member_list), ";")
      local member_table = gchat_do_sort_byonline(str_lst)
      for j = 1, table.getn(member_table) do
        local name_lst = util_split_wstring(nx_widestr(member_table[j]), ",")
        local is_online = nx_int(name_lst[2])
        local new_item = GetNewGChatItem()
        if not nx_is_valid(new_item) then
          break
        end
        new_item.Visible = false
        new_item.mark_type = typename
        new_item.is_online = is_online
        new_item.is_online = nx_int(name_lst[2])
        new_item.lbl_name.Text = name_lst[1]
        if is_online == nx_int(1) then
          new_item.lbl_name.ForeColor = color_online
        else
          new_item.lbl_name.ForeColor = color_offline
        end
        new_item.target = name_lst[1]
        new_item.groupid = mark.groupid
        new_item.lbl_flag.Visible = false
        if is_groupchat_master(mark.groupid, name_lst[1]) then
          new_item.lbl_flag.Visible = true
        end
        local sub_node = node:CreateChild("")
        if not nx_is_valid(sub_node) then
          break
        end
        sub_node.item = new_item
      end
    end
  end
  AdjustTreeGroupchatLayout(form.groupscrollbox_groupchat_list)
end
function AdjustTreeLayout(groupbox)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return
  end
  ClearAllNeedRemoveChild(groupbox)
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    local mark = node.mark_node
    if nx_is_valid(mark) then
      if not groupbox:IsChild(mark) then
        groupbox:Add(mark)
      end
      local node_child_count = node:GetChildCount()
      if 0 < node_child_count then
        for j = node_child_count - 1, 0, -1 do
          local sub_node = node:GetChildByIndex(j)
          local item = sub_node.item
          if nx_is_valid(item) then
            if not groupbox:IsChild(item) then
              groupbox:InsertAfter(item, mark)
            end
            if mark.isUnfold and item.isneedremove == false then
              item.Visible = true
            else
              item.Visible = false
            end
          end
        end
      end
    end
  end
  RefreshGroupBoxIntro(groupbox)
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function RefreshGroupBoxIntro(groupbox)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local _, pupil_count = GetMemberCount(form, "teacherpupil")
  if nx_int(pupil_count) <= nx_int(0) then
    form.groupbox_intropupil.Visible = true
  else
    form.groupbox_intropupil.Visible = false
  end
  local _, friend_count = GetMemberCount(form, "friend")
  local _, buddy_count = GetMemberCount(form, "buddy")
  if nx_int(friend_count) <= nx_int(0) and nx_int(buddy_count) <= nx_int(0) then
    form.groupbox_introfriend.Visible = true
  else
    form.groupbox_introfriend.Visible = false
  end
  if form.groupbox_intropupil.Visible or form.groupbox_introfriend.Visible then
    form.groupbox_intro.Visible = true
    groupbox:Remove(form.groupbox_intro)
    groupbox:Add(form.groupbox_intro)
  else
    form.groupbox_intro.Visible = false
  end
  if form.groupbox_intropupil.Visible then
    form.groupbox_intropupil.Top = form.lbl_intro1.Top + form.lbl_intro1.Height + 2
    form.groupbox_introfriend.Top = form.groupbox_intropupil.Top + form.groupbox_intropupil.Height + 2
  else
    form.groupbox_introfriend.Top = form.lbl_intro1.Top + form.lbl_intro1.Height + 2
  end
  local offset = 0
  if form.groupbox_intropupil.Visible then
    offset = offset + form.groupbox_intropupil.Height + 2
  end
  if form.groupbox_introfriend.Visible then
    offset = offset + form.groupbox_introfriend.Height + 2
  end
  form.groupbox_intro.Height = form.lbl_intro1.Top + form.lbl_intro1.Height + 2 + offset
end
function AdjustTreeKarmaLayout(groupbox)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local treenode_karma_list = form.treenode_karma_list
  if not nx_is_valid(treenode_karma_list) then
    return
  end
  ClearAllNeedRemoveChildKarma(groupbox)
  local list_count = treenode_karma_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_karma_list:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local mark = node.mark_node
    if not nx_is_valid(mark) then
      break
    end
    if not groupbox:IsChild(mark) then
      groupbox:Add(mark)
    end
    local node_child_count = node:GetChildCount()
    for j = node_child_count - 1, 0, -1 do
      local sub_node = node:GetChildByIndex(j)
      if not nx_is_valid(sub_node) then
        break
      end
      local item = sub_node.item
      if not nx_is_valid(item) then
        break
      end
      if not groupbox:IsChild(item) then
        groupbox:InsertAfter(item, mark)
      end
      if mark.isUnfold and item.isneedremove == false then
        item.Visible = true
      else
        item.Visible = false
      end
    end
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function AdjustTreeGroupchatLayout(groupbox)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local treenode_groupchat_list = form.treenode_groupchat_list
  if not nx_is_valid(treenode_groupchat_list) then
    return
  end
  ClearAllNeedRemoveChildGroupchat(groupbox)
  local list_count = treenode_groupchat_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_groupchat_list:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local mark = node.mark_node
    if not nx_is_valid(mark) then
      break
    end
    if not groupbox:IsChild(mark) then
      groupbox:Add(mark)
    end
    local node_child_count = node:GetChildCount()
    for j = node_child_count - 1, 0, -1 do
      local sub_node = node:GetChildByIndex(j)
      if not nx_is_valid(sub_node) then
        break
      end
      local item = sub_node.item
      if not nx_is_valid(item) then
        break
      end
      if not groupbox:IsChild(item) then
        groupbox:InsertAfter(item, mark)
      end
      if mark.isUnfold and item.isneedremove == false then
        item.Visible = true
      else
        item.Visible = false
      end
    end
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function GetMemberCount(form, typename)
  local online_count = 0
  local member_count = 0
  local child_table = form.groupbox_playerlist:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("mark") and nx_find_custom(child, "mark_type") and nx_string(child.mark_type) == nx_string(typename) then
      if nx_find_custom(child, "online_count") then
        online_count = nx_int(child.online_count)
      end
      if nx_find_custom(child, "member_count") then
        member_count = nx_int(child.member_count)
      end
      break
    end
  end
  return online_count, member_count
end
function ClearAllChild(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  form.treenode_list:ClearChild()
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  if 0 < child_count then
    for i = child_count, 1, -1 do
      local child = child_table[i]
      if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
        groupbox:Remove(child)
        gui:Delete(child)
      end
    end
  end
end
function ClearAllChildKarma(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  form.treenode_karma_list:ClearChild()
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      groupbox:Remove(child)
      gui:Delete(child)
    end
  end
end
function ClearAllChildGroupchat(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  form.treenode_groupchat_list:ClearChild()
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      groupbox:Remove(child)
      gui:Delete(child)
    end
  end
end
function ClearAllNeedRemoveChild(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return
  end
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    local node_child_count = node:GetChildCount()
    if 0 < node_child_count then
      for j = node_child_count - 1, 0, -1 do
        local sub_node = node:GetChildByIndex(j)
        local item = sub_node.item
        if nx_is_valid(item) then
          if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") and item.isneedremove == true then
            groupbox:Remove(item)
            gui:Delete(item)
            node:RemoveChildByIndex(j)
          end
        else
          node:RemoveChildByIndex(j)
        end
      end
    end
  end
end
function ClearAllNeedRemoveChildKarma(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  local treenode_karma_list = form.treenode_karma_list
  if not nx_is_valid(treenode_karma_list) then
    return
  end
  local list_count = treenode_karma_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_karma_list:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local node_child_count = node:GetChildCount()
    for j = node_child_count - 1, 0, -1 do
      local sub_node = node:GetChildByIndex(j)
      if not nx_is_valid(sub_node) then
        break
      end
      local item = sub_node.item
      if nx_is_valid(item) then
        if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") and item.isneedremove == true then
          groupbox:Remove(item)
          gui:Delete(item)
          node:RemoveChildByIndex(j)
        end
      else
        node:RemoveChildByIndex(j)
      end
    end
  end
end
function ClearAllNeedRemoveChildGroupchat(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  local treenode_groupchat_list = form.treenode_groupchat_list
  if not nx_is_valid(treenode_groupchat_list) then
    return
  end
  local list_count = treenode_groupchat_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_groupchat_list:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local node_child_count = node:GetChildCount()
    for j = node_child_count - 1, 0, -1 do
      local sub_node = node:GetChildByIndex(j)
      if not nx_is_valid(sub_node) then
        break
      end
      local item = sub_node.item
      if nx_is_valid(item) then
        if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") and item.isneedremove == true then
          groupbox:Remove(item)
          gui:Delete(item)
          node:RemoveChildByIndex(j)
        end
      else
        node:RemoveChildByIndex(j)
      end
    end
  end
end
function ClearKarmaItemSelected(rbtn)
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.groupscrollbox_karma_playerlist:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("item") then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.rbtn_item, rbtn) then
          child.rbtn_hide.Checked = true
        end
      else
        child.rbtn_hide.Checked = true
      end
    end
  end
end
function ClearGroupchatItemSelected(rbtn)
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.groupscrollbox_groupchat_list:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("item") then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.rbtn_item, rbtn) then
          child.rbtn_hide.Checked = true
        end
      else
        child.rbtn_hide.Checked = true
      end
    end
  end
end
function ClearItemSelected(rbtn)
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.groupbox_playerlist:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("item") then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.rbtn_item, rbtn) then
          child.rbtn_hide.Checked = true
        end
      else
        child.rbtn_hide.Checked = true
      end
    end
  end
end
function GetNodeIndex(typename)
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return -1
  end
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return -1
  end
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    if nx_string(node.mark_type) == nx_string(typename) then
      return i
    end
  end
  return -1
end
function GetNodeKarmaIndex(typename)
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return -1
  end
  local treenode_karma_list = form.treenode_karma_list
  if not nx_is_valid(treenode_karma_list) then
    return -1
  end
  local list_count = treenode_karma_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_karma_list:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    if nx_string(node.mark_type) == nx_string(typename) then
      return i
    end
  end
  return -1
end
function GetMark(typename)
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return 0
  end
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return 0
  end
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    if nx_string(node.mark_type) == nx_string(typename) then
      return node.mark_node
    end
  end
  return nil
end
function SetExtButtonStyle(mark, isUnfold)
  if nx_is_valid(mark) and nx_is_valid(mark.btn_ext) then
    mark.btn_ext.NormalImage = isUnfold and unfold_normalimage or fold_normalimage
    mark.btn_ext.FocusImage = isUnfold and unfold_focusimage or fold_focusimage
    mark.btn_ext.PushImage = isUnfold and unfold_pushimage or fold_pushimage
    mark.isUnfold = isUnfold
  end
end
function GetNewMark()
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return nil
  end
  local mark = gui:Create("GroupBox")
  local tpl_mark = form.groupbox_mark
  if not nx_is_valid(mark) or not nx_is_valid(tpl_mark) then
    return nil
  end
  mark.ctrltype = "mark"
  mark.isUnfold = true
  mark.isneedremove = false
  mark.Left = tpl_mark.Left
  mark.Top = tpl_mark.Top
  mark.Width = tpl_mark.Width
  mark.Height = tpl_mark.Height
  mark.BackColor = tpl_mark.BackColor
  mark.NoFrame = tpl_mark.NoFrame
  local tpl_bg = tpl_mark:Find("mark_bg")
  if nx_is_valid(tpl_bg) then
    local btn_mark = gui:Create("Button")
    btn_mark.Left = tpl_bg.Left
    btn_mark.Top = tpl_bg.Top
    btn_mark.Width = tpl_bg.Width
    btn_mark.Height = tpl_bg.Height
    btn_mark.NormalImage = tpl_bg.NormalImage
    btn_mark.FocusImage = tpl_bg.FocusImage
    btn_mark.PushImage = tpl_bg.PushImage
    btn_mark.DrawMode = tpl_bg.DrawMode
    btn_mark.AutoSize = tpl_bg.AutoSize
    nx_bind_script(btn_mark, nx_current())
    nx_callback(btn_mark, "on_click", "on_btn_mark_click")
    nx_callback(btn_mark, "on_left_double_click", "on_btn_mark_left_double_click")
    mark:Add(btn_mark)
    mark.btn_mark = btn_mark
  end
  local tpl_ext = tpl_mark:Find("mark_ext")
  if nx_is_valid(tpl_ext) then
    local btn_ext = gui:Create("Button")
    btn_ext.Left = tpl_ext.Left
    btn_ext.Top = tpl_ext.Top
    btn_ext.Width = tpl_ext.Width
    btn_ext.Height = tpl_ext.Height
    btn_ext.NormalImage = tpl_ext.NormalImage
    btn_ext.FocusImage = tpl_ext.FocusImage
    btn_ext.PushImage = tpl_ext.PushImage
    btn_ext.DrawMode = tpl_ext.DrawMode
    btn_ext.AutoSize = tpl_ext.AutoSize
    nx_bind_script(btn_ext, nx_current())
    nx_callback(btn_ext, "on_click", "on_btn_ext_click")
    mark:Add(btn_ext)
    mark.btn_ext = btn_ext
  end
  local tpl_title = tpl_mark:Find("mark_title")
  if nx_is_valid(tpl_title) then
    local lbl_title = gui:Create("Label")
    lbl_title.Left = tpl_title.Left
    lbl_title.Top = tpl_title.Top
    lbl_title.Width = tpl_title.Width
    lbl_title.Height = tpl_title.Height
    lbl_title.ForeColor = tpl_title.ForeColor
    lbl_title.Font = tpl_title.Font
    mark:Add(lbl_title)
    mark.lbl_title = lbl_title
  end
  local tpl_num = tpl_mark:Find("mark_num")
  if nx_is_valid(tpl_num) then
    local lbl_num = gui:Create("Label")
    lbl_num.Left = tpl_num.Left
    lbl_num.Top = tpl_num.Top
    lbl_num.Width = tpl_num.Width
    lbl_num.Height = tpl_num.Height
    lbl_num.ForeColor = tpl_num.ForeColor
    lbl_num.Font = tpl_num.Font
    mark:Add(lbl_num)
    mark.lbl_num = lbl_num
  end
  return mark
end
function GetNewItem()
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "item"
  item.isneedremove = false
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  local tpl_bg = tpl_item:Find("item_bg")
  if nx_is_valid(tpl_bg) then
    local rbtn_item = gui:Create("RadioButton")
    rbtn_item.Left = tpl_bg.Left
    rbtn_item.Top = tpl_bg.Top
    rbtn_item.Width = tpl_bg.Width
    rbtn_item.Height = tpl_bg.Height
    rbtn_item.NormalImage = tpl_bg.NormalImage
    rbtn_item.FocusImage = tpl_bg.FocusImage
    rbtn_item.CheckedImage = tpl_bg.CheckedImage
    rbtn_item.DrawMode = tpl_bg.DrawMode
    rbtn_item.AutoSize = tpl_bg.AutoSize
    nx_bind_script(rbtn_item, nx_current())
    nx_callback(rbtn_item, "on_checked_changed", "on_item_select_changed")
    nx_callback(rbtn_item, "on_left_double_click", "on_item_double_click")
    nx_callback(rbtn_item, "on_right_click", "on_item_right_click")
    item:Add(rbtn_item)
    item.rbtn_item = rbtn_item
  end
  local tpl_hide = tpl_item:Find("item_hide")
  if nx_is_valid(tpl_hide) then
    local rbtn_hide = gui:Create("RadioButton")
    rbtn_hide.Left = tpl_hide.Left
    rbtn_hide.Top = tpl_hide.Top
    rbtn_hide.Width = tpl_hide.Width
    rbtn_hide.Height = tpl_hide.Height
    rbtn_hide.NormalImage = tpl_hide.NormalImage
    rbtn_hide.FocusImage = tpl_hide.FocusImage
    rbtn_hide.CheckedImage = tpl_hide.CheckedImage
    rbtn_hide.DrawMode = tpl_hide.DrawMode
    rbtn_hide.AutoSize = tpl_hide.AutoSize
    rbtn_hide.Visible = false
    item:Add(rbtn_hide)
    item.rbtn_hide = rbtn_hide
  end
  local tpl_mobile = tpl_item:Find("item_mobile")
  if nx_is_valid(tpl_mobile) then
    local lbl_mobile = gui:Create("Label")
    lbl_mobile.Left = tpl_mobile.Left
    lbl_mobile.Top = tpl_mobile.Top
    lbl_mobile.Width = tpl_mobile.Width
    lbl_mobile.Height = tpl_mobile.Height
    lbl_mobile.ForeColor = tpl_mobile.ForeColor
    lbl_mobile.Font = tpl_mobile.Font
    lbl_mobile.DrawMode = tpl_mobile.DrawMode
    lbl_mobile.AutoSize = tpl_mobile.AutoSize
    lbl_mobile.Align = tpl_mobile.Align
    lbl_mobile.BackImage = tpl_mobile.BackImage
    item:Add(lbl_mobile)
    item.lbl_mobile = lbl_mobile
    item.lbl_mobile.Visible = false
  end
  local tpl_name = tpl_item:Find("item_name")
  if nx_is_valid(tpl_name) then
    local lbl_name = gui:Create("Label")
    lbl_name.Left = tpl_name.Left
    lbl_name.Top = tpl_name.Top
    lbl_name.Width = tpl_name.Width
    lbl_name.Height = tpl_name.Height
    lbl_name.ForeColor = tpl_name.ForeColor
    lbl_name.Font = tpl_name.Font
    lbl_name.Align = tpl_name.Align
    item:Add(lbl_name)
    item.lbl_name = lbl_name
  end
  local tpl_revenge = tpl_item:Find("item_revenge")
  if nx_is_valid(tpl_revenge) then
    local lbl_revenge = gui:Create("Label")
    lbl_revenge.Left = tpl_revenge.Left
    lbl_revenge.Top = tpl_revenge.Top
    lbl_revenge.Width = tpl_revenge.Width
    lbl_revenge.Height = tpl_revenge.Height
    lbl_revenge.DrawMode = tpl_revenge.DrawMode
    lbl_revenge.AutoSize = tpl_revenge.AutoSize
    lbl_revenge.Align = tpl_revenge.Align
    lbl_revenge.Transparent = false
    nx_bind_script(lbl_revenge, nx_current())
    nx_callback(lbl_revenge, "on_get_capture", "on_lbl_revenge_get_capture")
    nx_callback(lbl_revenge, "on_lost_capture", "on_lbl_revenge_lost_capture")
    item:Add(lbl_revenge)
    item.lbl_revenge = lbl_revenge
  end
  local tpl_shane = tpl_item:Find("item_shane")
  if nx_is_valid(tpl_shane) then
    local lbl_shane = gui:Create("Label")
    lbl_shane.Left = tpl_shane.Left
    lbl_shane.Top = tpl_shane.Top
    lbl_shane.Width = tpl_shane.Width
    lbl_shane.Height = tpl_shane.Height
    lbl_shane.DrawMode = tpl_shane.DrawMode
    lbl_shane.AutoSize = tpl_shane.AutoSize
    lbl_shane.Align = tpl_shane.Align
    item:Add(lbl_shane)
    item.lbl_shane = lbl_shane
  end
  local tpl_flag = tpl_item:Find("item_flag")
  if nx_is_valid(tpl_flag) then
    local lbl_flag = gui:Create("Label")
    lbl_flag.Left = tpl_flag.Left
    lbl_flag.Top = tpl_flag.Top
    lbl_flag.Width = tpl_flag.Width
    lbl_flag.Height = tpl_flag.Height
    lbl_flag.DrawMode = tpl_flag.DrawMode
    lbl_flag.AutoSize = tpl_flag.AutoSize
    lbl_flag.Align = tpl_flag.Align
    item:Add(lbl_flag)
    item.lbl_flag = lbl_flag
  end
  local tpl_hot = tpl_item:Find("item_hot")
  if nx_is_valid(tpl_hot) then
    local lbl_hot = gui:Create("Label")
    lbl_hot.Left = tpl_hot.Left
    lbl_hot.Top = tpl_hot.Top
    lbl_hot.Width = tpl_hot.Width
    lbl_hot.Height = tpl_hot.Height
    lbl_hot.ForeColor = tpl_hot.ForeColor
    lbl_hot.Font = tpl_hot.Font
    lbl_hot.Align = tpl_hot.Align
    item:Add(lbl_hot)
    item.lbl_hot = lbl_hot
  end
  return item
end
function GetNewGChatMark()
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return nil
  end
  local mark = gui:Create("GroupBox")
  local tpl_mark = form.groupbox_gchat_mark
  if not nx_is_valid(mark) or not nx_is_valid(tpl_mark) then
    return nil
  end
  mark.ctrltype = "mark"
  mark.isUnfold = true
  mark.isneedremove = false
  mark.Left = tpl_mark.Left
  mark.Top = tpl_mark.Top
  mark.Width = tpl_mark.Width
  mark.Height = tpl_mark.Height
  mark.BackColor = tpl_mark.BackColor
  mark.NoFrame = tpl_mark.NoFrame
  local tpl_bg = tpl_mark:Find("gchat_mark_bg")
  if nx_is_valid(tpl_bg) then
    local btn_mark = gui:Create("Button")
    btn_mark.Left = tpl_bg.Left
    btn_mark.Top = tpl_bg.Top
    btn_mark.Width = tpl_bg.Width
    btn_mark.Height = tpl_bg.Height
    btn_mark.NormalImage = tpl_bg.NormalImage
    btn_mark.FocusImage = tpl_bg.FocusImage
    btn_mark.PushImage = tpl_bg.PushImage
    btn_mark.DrawMode = tpl_bg.DrawMode
    btn_mark.AutoSize = tpl_bg.AutoSize
    nx_bind_script(btn_mark, nx_current())
    nx_callback(btn_mark, "on_click", "on_btn_mark_click")
    nx_callback(btn_mark, "on_right_click", "on_gchat_btn_mark_rclick")
    nx_callback(btn_mark, "on_left_double_click", "on_btn_mark_left_double_click")
    mark:Add(btn_mark)
    mark.btn_mark = btn_mark
  end
  local tpl_ext = tpl_mark:Find("gchat_mark_ext")
  if nx_is_valid(tpl_ext) then
    local btn_ext = gui:Create("Button")
    btn_ext.Left = tpl_ext.Left
    btn_ext.Top = tpl_ext.Top
    btn_ext.Width = tpl_ext.Width
    btn_ext.Height = tpl_ext.Height
    btn_ext.NormalImage = tpl_ext.NormalImage
    btn_ext.FocusImage = tpl_ext.FocusImage
    btn_ext.PushImage = tpl_ext.PushImage
    btn_ext.DrawMode = tpl_ext.DrawMode
    btn_ext.AutoSize = tpl_ext.AutoSize
    nx_bind_script(btn_ext, nx_current())
    nx_callback(btn_ext, "on_click", "on_btn_ext_click")
    mark:Add(btn_ext)
    mark.btn_ext = btn_ext
  end
  local tpl_title = tpl_mark:Find("gchat_mark_title")
  if nx_is_valid(tpl_title) then
    local lbl_title = gui:Create("Label")
    lbl_title.Left = tpl_title.Left
    lbl_title.Top = tpl_title.Top
    lbl_title.Width = tpl_title.Width
    lbl_title.Height = tpl_title.Height
    lbl_title.ForeColor = tpl_title.ForeColor
    lbl_title.Font = tpl_title.Font
    mark:Add(lbl_title)
    mark.lbl_title = lbl_title
  end
  local tpl_num = tpl_mark:Find("gchat_mark_num")
  if nx_is_valid(tpl_num) then
    local lbl_num = gui:Create("Label")
    lbl_num.Left = tpl_num.Left
    lbl_num.Top = tpl_num.Top
    lbl_num.Width = tpl_num.Width
    lbl_num.Height = tpl_num.Height
    lbl_num.ForeColor = tpl_num.ForeColor
    lbl_num.Font = tpl_num.Font
    mark:Add(lbl_num)
    mark.lbl_num = lbl_num
  end
  local tpl_shield = tpl_mark:Find("gchat_mark_shield")
  if nx_is_valid(tpl_shield) then
    local lbl_shield = gui:Create("Label")
    lbl_shield.Left = tpl_shield.Left
    lbl_shield.Top = tpl_shield.Top
    lbl_shield.Width = tpl_shield.Width
    lbl_shield.Height = tpl_shield.Height
    lbl_shield.ForeColor = tpl_shield.ForeColor
    lbl_shield.Font = tpl_shield.Font
    lbl_shield.BackImage = tpl_shield.BackImage
    mark:Add(lbl_shield)
    mark.lbl_shield = lbl_shield
  end
  return mark
end
function GetNewGChatItem()
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_gchat_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "item"
  item.isneedremove = false
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  local tpl_bg = tpl_item:Find("gchat_item_bg")
  if nx_is_valid(tpl_bg) then
    local rbtn_item = gui:Create("RadioButton")
    rbtn_item.Left = tpl_bg.Left
    rbtn_item.Top = tpl_bg.Top
    rbtn_item.Width = tpl_bg.Width
    rbtn_item.Height = tpl_bg.Height
    rbtn_item.NormalImage = tpl_bg.NormalImage
    rbtn_item.FocusImage = tpl_bg.FocusImage
    rbtn_item.CheckedImage = tpl_bg.CheckedImage
    rbtn_item.DrawMode = tpl_bg.DrawMode
    rbtn_item.AutoSize = tpl_bg.AutoSize
    nx_bind_script(rbtn_item, nx_current())
    nx_callback(rbtn_item, "on_checked_changed", "on_item_select_changed")
    nx_callback(rbtn_item, "on_left_double_click", "on_item_double_click")
    nx_callback(rbtn_item, "on_right_click", "on_item_right_click")
    item:Add(rbtn_item)
    item.rbtn_item = rbtn_item
  end
  local tpl_hide = tpl_item:Find("gchat_item_hide")
  if nx_is_valid(tpl_hide) then
    local rbtn_hide = gui:Create("RadioButton")
    rbtn_hide.Left = tpl_hide.Left
    rbtn_hide.Top = tpl_hide.Top
    rbtn_hide.Width = tpl_hide.Width
    rbtn_hide.Height = tpl_hide.Height
    rbtn_hide.NormalImage = tpl_hide.NormalImage
    rbtn_hide.FocusImage = tpl_hide.FocusImage
    rbtn_hide.CheckedImage = tpl_hide.CheckedImage
    rbtn_hide.DrawMode = tpl_hide.DrawMode
    rbtn_hide.AutoSize = tpl_hide.AutoSize
    rbtn_hide.Visible = false
    item:Add(rbtn_hide)
    item.rbtn_hide = rbtn_hide
  end
  local tpl_name = tpl_item:Find("gchat_item_name")
  if nx_is_valid(tpl_name) then
    local lbl_name = gui:Create("Label")
    lbl_name.Left = tpl_name.Left
    lbl_name.Top = tpl_name.Top
    lbl_name.Width = tpl_name.Width
    lbl_name.Height = tpl_name.Height
    lbl_name.ForeColor = tpl_name.ForeColor
    lbl_name.Font = tpl_name.Font
    lbl_name.Align = tpl_name.Align
    item:Add(lbl_name)
    item.lbl_name = lbl_name
  end
  local tpl_flag = tpl_item:Find("gchat_item_flag")
  if nx_is_valid(tpl_flag) then
    local lbl_flag = gui:Create("Label")
    lbl_flag.Left = tpl_flag.Left
    lbl_flag.Top = tpl_flag.Top
    lbl_flag.Width = tpl_flag.Width
    lbl_flag.Height = tpl_flag.Height
    lbl_flag.DrawMode = tpl_flag.DrawMode
    lbl_flag.AutoSize = tpl_flag.AutoSize
    lbl_flag.Align = tpl_flag.Align
    lbl_flag.BackImage = tpl_flag.BackImage
    item:Add(lbl_flag)
    item.lbl_flag = lbl_flag
  end
  return item
end
function on_btn_findguild_click(btn)
  nx_execute(FORM_SEARCH_GUILD, "show_form_search_guild")
end
function on_btn_createguild_click(btn)
  nx_execute(FORM_CREATE_GUILD, "auto_show_hide_form_create_guild", true)
end
function on_btn_guildchat_click(btn)
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("9920"))
end
function on_btn_exitguild_click(btn)
  util_show_form(FORM_GUILD_QUIT, true)
end
function on_guildname_changed(form)
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  if nx_string(guild_name) == nx_string("0") or nx_string(guild_name) == nx_string("") then
    form.groupbox_guildwithout.Visible = true
    form.groupbox_guildhave.Visible = false
  else
    form.groupbox_guildwithout.Visible = false
    form.groupbox_guildhave.Visible = false
    nx_execute("custom_sender", "custom_request_basic_guild_info")
  end
end
function on_receive_guild_basic_info(...)
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 12 then
    return
  end
  local guild_name = nx_widestr(arg[1])
  local guild_level = nx_int(arg[2])
  local guild_purpose = nx_widestr(arg[5])
  local guild_notice = nx_widestr(arg[6])
  local guild_hotness = nx_int(arg[8])
  local guild_onlinecount = nx_int(arg[10])
  local guild_membercount = nx_int(arg[12])
  form.lbl_guildname.Text = guild_name
  local fmt = string.format("[%d/%d]", nx_number(guild_onlinecount), nx_number(guild_membercount))
  form.lbl_guildnum.Text = nx_widestr(fmt)
  local level_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_level", guild_level)
  local notice_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_notice", guild_notice)
  local purpose_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_aim", guild_purpose)
  local content = nx_widestr(level_info) .. nx_widestr("<br/><br/>") .. nx_widestr(notice_info) .. nx_widestr("<br/><br/>") .. nx_widestr(purpose_info)
  form.mb_notice.HtmlText = content
  form.groupbox_guildhave.Visible = true
end
function add_guild_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddRolePropertyBind("GuildName", "wstring", form, nx_current(), "on_guildname_changed")
  end
end
function del_guild_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("GuildName", form)
  end
end
function get_format_info(content_flag, name_tip, value_info)
  local gui = nx_value("gui")
  local name_info = gui.TextManager:GetText(name_tip)
  return gui.TextManager:GetFormatText(content_flag, name_info, value_info)
end
function InitForm_Guild(form)
  on_guildname_changed(form)
end
function change_form_size()
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = gui.Width - form.Width - 40
  form.Top = gui.Height - form.Height
end
function extend_sub_group(typename)
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    form = util_show_form(FORM_CHAT_PANEL, true)
  end
  form.Visible = true
  form.rbtn_relation.Checked = true
  local child_table = form.groupbox_playerlist:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("mark") and nx_find_custom(child, "mark_type") then
      SetExtButtonStyle(child, false)
      if nx_string(child.mark_type) == nx_string(typename) then
        on_btn_mark_click(child.btn_mark)
      end
    end
  end
end
function on_btn_qifu_click(btn)
  local qifu_form = nx_value(FORM_QIFU)
  if nx_is_valid(qifu_form) then
    nx_destroy(qifu_form)
    return
  end
  local form = btn.ParentForm
  local dialog = nx_execute("util_gui", "util_get_form", FORM_QIFU, true, false)
  if form.lbl_qifu_focus.Visible then
    dialog.TypeMode = 1
  end
  local gui = nx_value("gui")
  gui.Desktop:ToFront(dialog)
  dialog.Visible = true
  dialog:Show()
  form.lbl_qifu_focus.Visible = false
end
function on_btn_gift_click(btn)
  local gift_form = nx_value(FORM_PRESENT)
  if nx_is_valid(gift_form) then
    nx_destroy(gift_form)
    return
  end
  local form = btn.ParentForm
  local dialog = nx_execute("util_gui", "util_get_form", FORM_PRESENT, true, false)
  if form.lbl_gift_focus.Visible then
    dialog.TypeMode = 1
  end
  local gui = nx_value("gui")
  gui.Desktop:ToFront(dialog)
  dialog.Visible = true
  dialog:Show()
  form.lbl_gift_focus.Visible = false
end
function init_qifu_present(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_gift_count.Visible = false
  form.lbl_qifu_count.Visible = false
  form.lbl_gift_focus.Visible = false
  form.lbl_qifu_focus.Visible = false
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_ACCPECT_PRESENT))
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_ACCPECT_QIFU))
end
function add_qifu_binder(form)
  local databinder = nx_value("data_binder")
  databinder:AddTableBind(PRESENT_REC, form, FORM_CHAT_PANEL, "refresh_table_changed")
  databinder:AddTableBind(QIFU_REC, form, FORM_CHAT_PANEL, "refresh_table_changed")
end
function del_qifu_binder(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(PRESENT_REC, form)
    databinder:DelTableBind(QIFU_REC, form)
  end
end
function refresh_table_changed(form, record_name)
  if nx_string(record_name) == nx_string(PRESENT_REC) then
    local present_count = get_table_row_count(PRESENT_REC)
    if nx_number(present_count) > 0 then
      form.lbl_gift_count.Visible = true
      form.lbl_gift_count.Text = nx_widestr(present_count)
    else
      form.lbl_gift_count.Visible = false
    end
  elseif nx_string(record_name) == nx_string(QIFU_REC) then
    local qifu_count = get_table_row_count(QIFU_REC)
    if nx_number(qifu_count) > 0 then
      form.lbl_qifu_count.Visible = true
      form.lbl_qifu_count.Text = nx_widestr(qifu_count)
    else
      form.lbl_qifu_count.Visible = false
    end
  end
end
function get_table_row_count(table_name)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return 0
  end
  if not player:FindRecord(table_name) then
    return 0
  end
  local rows = player:GetRecordRows(table_name)
  return rows
end
function focus_light(optype)
  if nx_int(optype) == nx_int(0) then
    nx_execute(FORM_REQUEST_RIGHT, "add_request_item", 4, "")
  elseif nx_int(optype) == nx_int(1) then
    nx_execute(FORM_REQUEST_RIGHT, "add_request_item", 5, "")
  end
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(optype) == nx_int(0) then
    form.lbl_gift_focus.Visible = true
  elseif nx_int(optype) == nx_int(1) then
    form.lbl_qifu_focus.Visible = true
  end
end
function UpdateFilterNative()
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return
  end
  UpdateFormTree(form, "filter_native")
end
function on_btn_friend_seting_click(btn)
  nx_execute("form_stage_main\\form_system\\form_system_interface_setting", "chat_open_form")
end
function request_is_in_rtm()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(236), nx_int(0))
end
function set_in_rtm_group(...)
  if table.getn(arg) < 1 then
    return
  end
  local form = nx_value(FORM_CHAT_PANEL)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(arg[1]) == nx_int(1) then
    form.in_rtm_flag = true
  else
    form.in_rtm_flag = false
  end
end
function is_can_invite()
  local form = util_get_form(FORM_CHAT_PANEL, false)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "in_rtm_flag") then
    return false
  end
  return form.in_rtm_flag
end
function sendopen_groupchat(groupid)
  nx_execute("custom_sender", "custom_open_groupchat", 3, groupid)
end
function on_btn_create_groupchat_click(btn)
  local home_farm = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_chat_system\\form_create_groupchat", true, false)
  home_farm:Show()
end
function is_groupchat_master(groupid, name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
  for i = 0, rows - 1 do
    local group_id = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_groupid)
    if nx_string(groupid) == nx_string(group_id) then
      local master = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_master)
      if nx_ws_equal(nx_widestr(name), nx_widestr(master)) then
        return true
      end
    end
  end
  return false
end
function get_groupchat_shield(groupid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow(PLAYER_GROUP_CHAT_REC, player_group_rec_groupid, nx_string(groupid))
  if nx_int(row) < nx_int(0) then
    return false
  end
  local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
  local shield = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, row, player_group_rec_shield)
  if nx_int(shield) == nx_int(1) then
    return true
  end
  return false
end
