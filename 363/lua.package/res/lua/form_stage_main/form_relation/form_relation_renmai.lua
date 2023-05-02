require("role_composite")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
require("form_stage_main\\form_relation\\form_relation_news")
local FRIEND_TYPE = 0
local BUDDY_TYPE = 1
local BROTHER_TYPE = 2
local ENEMY_TYPE = 3
local BLOOD_TYPE = 4
local GUANZHU_TYPE = 5
local ACQUAINT_TYPE = 6
local FANS_TYPE = 7
local FILTER_TYPE = 8
local TEACHER_PUPIL_TYPE = 9
local NPC_FRIEND_TYPE = 101
local NPC_BUDDY_TYPE = 102
local NPC_ATTENTION_TYPE = 103
local SUB_C_NEWS_RED_DOT = 2
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  add_player_list_form(self)
  change_form_size()
  show_player_control(self, false)
  local databinder = nx_value("data_binder")
  databinder:AddTableBind(FRIEND_REC, self, "form_stage_main\\form_relation\\form_relation_renmai", "show_renmai_nums")
  databinder:AddTableBind(BUDDY_REC, self, "form_stage_main\\form_relation\\form_relation_renmai", "show_renmai_nums")
  databinder:AddTableBind(ENEMY_REC, self, "form_stage_main\\form_relation\\form_relation_renmai", "show_renmai_nums")
  databinder:AddTableBind(BLOOD_REC, self, "form_stage_main\\form_relation\\form_relation_renmai", "show_renmai_nums")
  databinder:AddTableBind(ATTENTION_REC, self, "form_stage_main\\form_relation\\form_relation_renmai", "show_renmai_nums")
  self.groupbox_select.Visible = false
  self.btn_event.is_show = false
  self.lbl_dot.Visible = false
  get_renmai_text()
  show_renmai_nums()
  self.btn_reco_teacher.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_world_news", "custom_send_news", SUB_C_NEWS_RED_DOT)
end
function InitGossipForm(self)
  local sub_form = nx_value("form_stage_main\\form_relation\\form_gossip_info")
  if not nx_is_valid(sub_form) then
    sub_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_gossip_info", true, false)
  end
  if not nx_is_valid(sub_form) then
    return
  end
  self:Add(sub_form)
  sub_form:Show()
  sub_form.Visible = true
end
function on_main_form_close(self)
  nx_execute("form_stage_main\\form_relation\\form_feed_info", "close_all_blog")
  local form_world_news = nx_value("form_stage_main\\form_relation\\form_world_news")
  if nx_is_valid(form_world_news) then
    form_world_news:Close()
  end
  local form_npc = nx_value("form_stage_main\\form_relation\\form_npc_info")
  if nx_is_valid(form_npc) then
    nx_destroy(form_npc)
  end
  local form_player = nx_value("form_stage_main\\form_relation\\form_player_info")
  if nx_is_valid(form_player) then
    nx_destroy(form_player)
  end
  local form_karma = nx_value("form_stage_main\\form_relation\\super_book_trace\\form_npc_karma")
  if nx_is_valid(form_karma) then
    nx_destroy(form_karma)
  end
  if nx_is_valid(self.form_friend_list) then
    nx_destroy(self.form_friend_list)
  end
  nx_destroy(self)
end
function show_form(flag)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  if flag then
    local form_self = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
    if not nx_is_valid(form_self) then
      local form_self = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_renmai", true, false)
      if nx_is_valid(form_self) then
        form:Add(form_self)
      end
    else
      form_self:Show()
      form_self.Visible = true
    end
  else
    local form_self = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
    if nx_is_valid(form_self) then
      form_self.Visible = false
    end
  end
end
function focus_player_model(relation_type, player_name)
  local form = nx_value("form_stage_main\\form_relationship")
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  sns_manager:SetRelationType(0, relation_type)
  sns_manager:FocusPlayer(0, relation_type, nx_widestr(player_name))
  form.CurrentGroup = 0
  form.CurrentRelation = relation_type
  form.CheckPlayerName = player_name
end
function show_self_shane_info(form)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local CharacterFlag = nx_number(player:QueryProp("CharacterFlag"))
  local CharacterValue = nx_number(player:QueryProp("CharacterValue"))
  local Justice = nx_int(player:QueryProp("Justice"))
  local Evil = nx_int(player:QueryProp("Evil"))
  local FreeBase = nx_int(player:QueryProp("FreeBase"))
  local gui = nx_value("gui")
  form.lbl_xia_value.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_player_xia", Justice))
  form.lbl_e_value.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_player_e", Evil))
  form.lbl_jieao_value.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_player_jiehao", FreeBase))
  local text = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", CharacterFlag, CharacterValue)
  form.lbl_shane_name.Text = nx_widestr(text)
  if CharacterFlag == 0 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar2.Visible = false
    form.lbl_xia_bar2.Visible = false
    form.lbl_xie_bar2.Visible = false
    form.lbl_kuang_bar2.Visible = false
    form.lbl_e2.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang2.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
  elseif CharacterFlag == 1 then
    form.gb_sanjiao2.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar2.Visible = false
    form.lbl_xia_bar2.Visible = true
    form.lbl_xie_bar2.Visible = false
    form.lbl_kuang_bar2.Visible = false
    form.lbl_e2.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_colour.png"
    form.lbl_xie2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang2.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xia_bar2.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 2 then
    form.gb_sanjiao2.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_e.png"
    form.lbl_e_bar2.Visible = true
    form.lbl_xia_bar2.Visible = false
    form.lbl_xie_bar2.Visible = false
    form.lbl_kuang_bar2.Visible = false
    form.lbl_e2.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_colour.png"
    form.lbl_xia2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang2.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_e_bar2.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 3 then
    form.gb_sanjiao2.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_kuang.png"
    form.lbl_e_bar2.Visible = false
    form.lbl_xia_bar2.Visible = false
    form.lbl_xie_bar2.Visible = false
    form.lbl_kuang_bar2.Visible = true
    form.lbl_e2.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang2.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_colour.png"
    form.lbl_kuang2.Top = 16
    form.lbl_kuang2.Left = 56
    form.lbl_kuang_bar2.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_kuang_bar2.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 4 then
    form.gb_sanjiao2.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xie.png"
    form.lbl_e_bar2.Visible = false
    form.lbl_xia_bar2.Visible = false
    form.lbl_xie_bar2.Visible = true
    form.lbl_kuang_bar2.Visible = false
    form.lbl_e2.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie2.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_colour.png"
    form.lbl_xie2.Top = 16
    form.lbl_xie2.Left = 56
    form.lbl_kuang2.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xie_bar2.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_xie_bar2.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  end
end
function on_btn_gift_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_present", true, false)
  if form.lbl_gift_focus.Visible then
    dialog.TypeMode = 1
  end
  gui.Desktop:ToFront(dialog)
  dialog.Visible = true
  dialog:Show()
  form.lbl_gift_focus.Visible = false
end
function on_btn_present_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_present", true, false)
  dialog.SendPlayerName = form.CheckPlayerName
  if form.lbl_gift_focus.Visible then
    dialog.TypeMode = 1
  end
  gui.Desktop:ToFront(dialog)
  dialog.Visible = true
  dialog:Show()
  form.lbl_gift_focus.Visible = false
end
function on_btn_qifu_1_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_qifu", true, false)
  if form.lbl_qifu_focus.Visible then
    dialog.TypeMode = 1
  end
  gui.Desktop:ToFront(dialog)
  dialog.Visible = true
  dialog:Show()
  form.lbl_qifu_focus.Visible = false
end
function on_btn_qifu_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_qifu", true, false)
  dialog.SendPlayerName = form.CheckPlayerName
  if form.lbl_qifu_focus.Visible then
    dialog.TypeMode = 1
  end
  gui.Desktop:ToFront(dialog)
  dialog.Visible = true
  dialog:Show()
  form.lbl_qifu_focus.Visible = false
end
function on_btn_player_info_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_send_get_player_game_info", form.CheckPlayerName)
end
function show_haoyou()
  nx_execute("custom_sender", "custom_query_enemy_info", 0, 0)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = FRIEND_TYPE
  form.form_friend_list.relation = 0
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 0)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_haoyou_01"))
  form.rbtn_new.Enabled = true
  form.form_friend_list.rbtn_all.Checked = true
  form.form_friend_list.lbl_friend.Visible = true
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_player.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_player_out.png"
  form.form_friend_list.rbtn_player.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_player_on.png"
  form.form_friend_list.rbtn_player.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_player_on.png"
  form.form_friend_list.rbtn_npc.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_NPC_out.png"
  form.form_friend_list.rbtn_npc.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_NPC_on.png"
  form.form_friend_list.rbtn_npc.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_NPC_on.png"
  form.form_friend_list.rbtn_player.Visible = true
  form.form_friend_list.rbtn_npc.Visible = true
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\haoyou.png"
  form.btn_reco_teacher.Visible = false
end
function on_rbtn_haoyou_checked_changed(btn)
  if btn.Checked == true then
    show_haoyou()
  end
end
function show_zhiyou()
  nx_execute("custom_sender", "custom_query_enemy_info", 0, 1)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = BUDDY_TYPE
  form.form_friend_list.relation = 1
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 0)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_zhiyou_01"))
  form.rbtn_new.Enabled = true
  form.form_friend_list.rbtn_all.Checked = true
  form.form_friend_list.lbl_friend.Visible = true
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_player.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_zhiyou_pleyer_out.png"
  form.form_friend_list.rbtn_player.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_zhiyou_player_on.png"
  form.form_friend_list.rbtn_player.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_zhiyou_player_on.png"
  form.form_friend_list.rbtn_npc.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_zhiyou_NPC_out.png"
  form.form_friend_list.rbtn_npc.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_zhiyou_NPC_on.png"
  form.form_friend_list.rbtn_npc.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_zhiyou_NPC_on.png"
  form.form_friend_list.rbtn_player.Visible = true
  form.form_friend_list.rbtn_npc.Visible = true
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\zhiyou.png"
  form.btn_reco_teacher.Visible = false
end
function on_rbtn_zhiyou_checked_changed(btn)
  if btn.Checked == true then
    show_zhiyou()
  end
end
function show_chouren()
  nx_execute("custom_sender", "custom_query_enemy_info", 0, 2)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = ENEMY_TYPE
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 1)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_chouren_01"))
  form.rbtn_new.Enabled = false
  form.form_friend_list.rbtn_all.Checked = true
  form.form_friend_list.lbl_friend.Visible = true
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_chouren_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_chouren_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_chouren_on.png"
  form.form_friend_list.rbtn_player.Visible = false
  form.form_friend_list.rbtn_npc.Visible = false
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\chouren.png"
  form.btn_reco_teacher.Visible = false
end
function on_rbtn_chouren_checked_changed(btn)
  if btn.Checked == true then
    show_chouren()
  end
end
function show_xuechou()
  nx_execute("custom_sender", "custom_query_enemy_info", 0, 4)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = BLOOD_TYPE
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 1)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_xuechou_01"))
  form.rbtn_new.Enabled = false
  form.form_friend_list.rbtn_all.Checked = true
  form.form_friend_list.lbl_friend.Visible = true
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_xuechou_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_xuechou_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_xuechou_on.png"
  form.form_friend_list.rbtn_player.Visible = false
  form.form_friend_list.rbtn_npc.Visible = false
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\xuechou.png"
  form.btn_reco_teacher.Visible = false
end
function on_rbtn_xuechou_checked_changed(btn)
  if btn.Checked == true then
    show_xuechou()
  end
end
function show_guanzhu()
  nx_execute("custom_sender", "custom_query_enemy_info", 0, 5)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = GUANZHU_TYPE
  form.form_friend_list.relation = 2
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 0)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_guanzhu_01"))
  form.rbtn_new.Enabled = true
  form.form_friend_list.rbtn_all.Checked = true
  form.form_friend_list.lbl_friend.Visible = true
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_player.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_guanzhu_player_out.png"
  form.form_friend_list.rbtn_player.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_guanzhu_player_on.png"
  form.form_friend_list.rbtn_player.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_guanzhu_player_on.png"
  form.form_friend_list.rbtn_npc.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_guanzhu_NPC_out.png"
  form.form_friend_list.rbtn_npc.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_guanzhu_NPC_on.png"
  form.form_friend_list.rbtn_npc.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_guanzhu_NPC_on.png"
  form.form_friend_list.rbtn_player.Visible = true
  form.form_friend_list.rbtn_npc.Visible = true
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\guanzhu.png"
  form.btn_reco_teacher.Visible = false
end
function showshixiongdi()
  nx_execute("custom_sender", "custom_query_enemy_info", 0, 0)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = TEACHER_PUPIL_TYPE
  form.form_friend_list.relation = 1
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 0)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_pupil_01"))
  form.rbtn_new.Enabled = true
  form.form_friend_list.rbtn_all.Checked = true
  form.form_friend_list.lbl_friend.Visible = true
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_player.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_player_out.png"
  form.form_friend_list.rbtn_player.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_player_on.png"
  form.form_friend_list.rbtn_player.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_player_on.png"
  form.form_friend_list.rbtn_npc.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_NPC_out.png"
  form.form_friend_list.rbtn_npc.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_NPC_on.png"
  form.form_friend_list.rbtn_npc.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_haoyou_NPC_on.png"
  form.form_friend_list.rbtn_player.Visible = true
  form.form_friend_list.rbtn_npc.Visible = true
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns\\shixiongdi.png"
  form.btn_reco_teacher.Visible = true
end
function show_npc_haoyou()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = NPC_FRIEND_TYPE
  form.form_friend_list.relation = 0
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 0)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_haoyou_01"))
  form.rbtn_new.Enabled = true
  form.form_friend_list.rbtn_all.Checked = false
  form.form_friend_list.lbl_friend.Visible = false
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_player.Visible = false
  form.form_friend_list.rbtn_npc.Visible = false
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\haoyou.png"
end
function show_npc_zhiyou()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = NPC_BUDDY_TYPE
  form.form_friend_list.relation = 1
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 0)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_zhiyou_01"))
  form.rbtn_new.Enabled = true
  form.form_friend_list.rbtn_all.Checked = false
  form.form_friend_list.lbl_friend.Visible = false
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_player.Visible = false
  form.form_friend_list.rbtn_npc.Visible = false
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\zhiyou.png"
end
function show_npc_guanzhu()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = NPC_ATTENTION_TYPE
  form.form_friend_list.relation = 2
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 0)
  form.btn_player_info.Enabled = true
  form.rbtn_friend.Text = nx_widestr(util_text("ui_guanzhu_01"))
  form.rbtn_new.Enabled = true
  form.form_friend_list.rbtn_all.Checked = false
  form.form_friend_list.lbl_friend.Visible = false
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\btn_whole_on.png"
  form.form_friend_list.rbtn_player.Visible = false
  form.form_friend_list.rbtn_npc.Visible = false
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\guanzhu.png"
end
function on_rbtn_guanzhu_checked_changed(btn)
  if btn.Checked == true then
    show_guanzhu()
  end
end
function on_rbtn_shixiongdi_checked_changed(btn)
  if btn.Checked then
    showshixiongdi()
  end
end
function on_rbtn_npc_haoyou_checked_changed(rbtn)
  if rbtn.Checked then
    show_npc_haoyou()
  end
end
function on_rbtn_npc_zhiyou_checked_changed(rbtn)
  if rbtn.Checked then
    show_npc_zhiyou()
  end
end
function on_rbtn_npc_guanzhu_checked_changed(rbtn)
  if rbtn.Checked then
    show_npc_guanzhu()
  end
end
function on_relation_type_change_event(group_id, relation_type)
  nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "hide_form")
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form_relationship) then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "CheckPlayerName") then
    form.CheckPlayerName = ""
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local relation_group = sns_manager:GetRelationGroup(group_id)
  local group_index
  if nx_find_custom(relation_group, "group_index") then
    group_index = relation_group.group_index
  end
  nx_set_custom(form, "relation_type", relation_type)
  get_renmai_text()
  if nx_int(relation_type) == nx_int(RELATION_TYPE_RENMAI_SELF) then
    form.gb_self_shan_e.Visible = true
    show_self_shane_info(form)
    form.btn_event.Visible = true
    form.gb_self_rbtn.Visible = true
    form.groupbox_select.Visible = false
    form.btn_add_player.Visible = false
    form_relationship.rbtn_relation2_personal.Checked = true
  else
    form.gb_self_shan_e.Visible = false
    form.btn_event.is_show = false
    on_btn_event_click(form.btn_event)
    form.gb_self_rbtn.Visible = false
    form.groupbox_select.Visible = true
    if form.groupbox_character.Visible then
      form.groupbox_character.Visible = false
    end
    if form.gb_center.Visible then
      form.gb_center.Visible = false
      local form_player = nx_value("form_stage_main\\form_relation\\form_player_info")
      if nx_is_valid(form_player) then
        nx_destroy(form_player)
      end
    end
    if nx_int(relation_type) == nx_int(RELATION_TYPE_FRIEND) then
      show_haoyou()
      form_relationship.rbtn_relation2_friend.Checked = true
    elseif nx_int(relation_type) == nx_int(RELATION_TYPE_ENEMY) then
      show_chouren()
      form_relationship.rbtn_relation2_enemy.Checked = true
    elseif nx_int(relation_type) == nx_int(RELATION_TYPE_ATTENTION) then
      show_guanzhu()
      form_relationship.rbtn_relation2_attention.Checked = true
    elseif nx_int(relation_type) == nx_int(RELATION_TYPE_BUDDY) then
      show_zhiyou()
      form_relationship.rbtn_relation2_buddy.Checked = true
    elseif nx_int(relation_type) == nx_int(RELATION_TYPE_BLOOD) then
      show_xuechou()
      form_relationship.rbtn_relation2_blood.Checked = true
    end
  end
  local form_feed_simple = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_simple", false, false)
  if nx_is_valid(form_feed_simple) then
    form_feed_simple:Close()
  end
end
function on_focus_change_event(group_id, relation_type, index, name)
  local old_select_player = ""
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "CheckPlayerName") then
    old_select_player = form.CheckPlayerName
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_index
  if nx_is_valid(sns_manager) then
    local relation_group = sns_manager:GetRelationGroup(group_id)
    if nx_find_custom(relation_group, "group_index") then
      group_index = relation_group.group_index
    end
  end
  form.CurrentRelation = group_index
  form.CheckPlayerName = name
  show_player_name(name)
  if nx_ws_equal(nx_widestr(old_select_player), nx_widestr("")) then
    local form_feeds = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_info", false, false)
    if nx_is_valid(form_feeds) then
      form_feeds:Close()
      if nx_is_valid(form_feeds) then
        nx_destroy(form_feeds)
      end
    end
    local form_reply = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply", false, false)
    if nx_is_valid(form_reply) then
      form_reply:Close()
      if nx_is_valid(form_reply) then
        nx_destroy(form_reply)
      end
    end
    form.rbtn_friend.Checked = true
  end
  if not nx_ws_equal(nx_widestr(old_select_player), nx_widestr(name)) then
    local form_feed_simple = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_simple", false, false)
    if nx_is_valid(form_feed_simple) then
      form_feed_simple:Close()
      if nx_is_valid(form_feed_simple) then
        nx_destroy(form_feed_simple)
      end
    end
  end
  show_btnlist(group_index, name, false)
end
function show_btnlist(group_index, name, is_npc)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "hide_form")
  if is_npc then
    form.gb_center.Visible = false
    form.groupbox_character.Visible = true
    form.gb_btnlist.Visible = false
    show_character(nx_string(name))
    nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "show_form", form, nx_string(name))
  else
    local relation_type = form.relation_type
    if nx_int(relation_type) == nx_int(RELATION_TYPE_RENMAI_SELF) then
      form.gb_center.Visible = false
    else
      form.gb_center.Visible = true
    end
  end
end
function is_in_table(table_name, player_name)
  local player = get_client_player()
  if nx_is_valid(player) and player:FindRecord(table_name) then
    local rows = player:GetRecordRows(table_name)
    for i = 0, rows - 1 do
      local name = nx_widestr(player:QueryRecord(table_name, i, FRIEND_REC_NAME))
      if nx_ws_equal(nx_widestr(player_name), nx_widestr(name)) then
        return true
      end
    end
  end
  return false
end
function on_btn_add_player_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog:ShowModal()
end
function focus_light(optype)
  if nx_int(optype) == nx_int(0) then
    nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_item", 4, "")
  elseif nx_int(optype) == nx_int(1) then
    nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_item", 5, "")
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  if nx_int(optype) == nx_int(0) then
    form.lbl_gift_focus.Visible = true
  elseif nx_int(optype) == nx_int(1) then
    form.lbl_qifu_focus.Visible = true
  end
end
function InitPresentMessage()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_ACCPECT_PRESENT))
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_ACCPECT_QIFU))
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
function refresh_table_changed(form, recordname, optype, row, clomn)
  if nx_string(recordname) == nx_string(PRESENT_REC) then
    local present_count = get_table_row_count(PRESENT_REC)
    if nx_number(present_count) > 0 then
      form.lbl_gift_count.Visible = true
      form.lbl_gift_count.Text = nx_widestr(present_count)
    else
      form.lbl_gift_count.Visible = false
    end
  elseif nx_string(recordname) == nx_string(QIFU_REC) then
    local qifu_count = get_table_row_count(QIFU_REC)
    if nx_number(qifu_count) > 0 then
      form.lbl_qifu_count.Visible = true
      form.lbl_qifu_count.Text = nx_widestr(qifu_count)
    else
      form.lbl_qifu_count.Visible = false
    end
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local b_show_relation_news = is_form_relation_news_show()
  local form_renmai = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_renmai", true, false)
  if nx_is_valid(form_renmai) then
    form_renmai.Left = 0
    form_renmai.Top = 0
    form_renmai.Width = form.Width
    form_renmai.Height = form.Height - form.groupbox_rbtn.Height
    form_renmai.form_friend_list.Left = form.Width - form_renmai.form_friend_list.Width - 10
    form_renmai.form_friend_list.Top = (form.Height - form_renmai.form_friend_list.Height) / 2
    form_renmai.groupbox_select.Top = form_renmai.form_friend_list.AbsTop - form_renmai.groupbox_select.Height
    if not nx_boolean(b_show_relation_news) then
      local feed_form_name = {
        "form_stage_main\\form_relation\\form_feed_info",
        "form_stage_main\\form_relation\\form_feed_reply",
        "form_stage_main\\form_relation\\form_feed_simple"
      }
      for _, form_name in ipairs(feed_form_name) do
        local form_feed = nx_value(form_name)
        if nx_is_valid(form_feed) and nx_boolean(form_feed.Visible) then
          form_feed.AbsTop = form_renmai.groupbox_select.AbsTop + form_renmai.groupbox_select.Height
          form_feed.AbsLeft = form_renmai.groupbox_select.AbsLeft + form_renmai.groupbox_select.Width - form_feed.Width
        end
      end
    end
    local form_main_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
    if nx_is_valid(form_main_chat) and nx_find_custom(form_main_chat, "chat_group") and nx_is_valid(form_renmai) then
      form_renmai.gb_self_rbtn.AbsTop = form_main_chat.chat_group.AbsTop - form_renmai.gb_self_rbtn.Height
    end
  end
  if not nx_boolean(b_show_relation_news) then
    local form_world_news = nx_value("form_stage_main\\form_relation\\form_world_news")
    if nx_is_valid(form_world_news) then
      nx_execute("form_stage_main\\form_relation\\form_world_news", "adjust_all_form_pos")
    end
  end
  local form_karma_prize = nx_value("form_stage_main\\form_relation\\form_npc_karma_prize_ex")
  if nx_is_valid(form_karma_prize) then
    nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "change_form_size", form_karma_prize)
  end
  if not nx_boolean(b_show_relation_news) then
    local gossip_form = nx_value("form_stage_main\\form_relation\\form_gossip_info")
    if nx_is_valid(gossip_form) then
      nx_execute("form_stage_main\\form_relation\\form_gossip_info", "change_form_size", gossip_form)
    end
  end
  if not nx_boolean(b_show_relation_news) then
    local form_feed_reply = nx_value("form_stage_main\\form_relation\\form_feed_reply")
    if nx_is_valid(form_feed_reply) and nx_is_valid(form_world_news) then
      form_feed_reply.AbsTop = form_world_news.AbsTop + form_world_news.Height
    end
  end
  local form_relation_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  local gui = nx_value("gui")
  if nx_is_valid(form_relation_renmai) and nx_is_valid(gui) then
    form_relation_renmai.lbl_no_man.AbsLeft = (gui.Width - form_relation_renmai.lbl_no_man.Width) / 2
    form_relation_renmai.lbl_no_man.AbsTop = (gui.Height - form_relation_renmai.lbl_no_man.Height) / 2
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_news", "change_form_size")
end
function relation_type_change_form(new_relation_type)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  if nx_int(new_relation_type) == nx_int(RELATION_TYPE_FRIEND) then
    form.rbtn_haoyou.Checked = true
  elseif nx_int(new_relation_type) == nx_int(RELATION_TYPE_BUDDY) then
    form.rbtn_zhiyou.Checked = true
  elseif nx_int(new_relation_type) == nx_int(RELATION_TYPE_ENEMY) then
    form.rbtn_chouren.Checked = true
  elseif nx_int(new_relation_type) == nx_int(RELATION_TYPE_BLOOD) then
    form.rbtn_xuechou.Checked = true
  elseif nx_int(new_relation_type) == nx_int(RELATION_TYPE_ATTENTION) then
    form.rbtn_guanzhu.Checked = true
  end
end
function add_player_list_form(form)
  local form_friend_list = util_get_form("form_stage_main\\form_relation\\form_friend_list", true, false)
  local gui = nx_value("gui")
  if form:Add(form_friend_list) then
    form.form_friend_list = form_friend_list
    form.form_friend_list.Visible = false
    form.form_friend_list.Fixed = true
    form.form_friend_list.Left = gui.Width - form.form_friend_list.Width - 10
    form.form_friend_list.Top = (gui.Height - form.form_friend_list.Height) / 2
  end
end
function on_btn_split_focus_get_capture(btn)
end
function on_btn_split_focus_lost_capture(btn)
end
function on_btn_split_focus_click(btn)
end
function show_player_list_form(bShow)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.btn_split_focus.Visible = bShow
  nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "show_light", bShow)
end
function on_btn_event_click(btn)
  local form = btn.ParentForm
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form_relationship) and nx_find_custom(form_relationship, "rbtn_relation2_personal") and nx_boolean(form_relationship.rbtn_relation2_personal.Checked) and nx_find_custom(form, "relation_type") and nx_int(form.relation_type) == nx_int(0) then
    on_btn_news_click(form.btn_news)
  elseif not btn.is_show then
    form.rbtn_friend.Checked = true
    form.form_friend_list.Visible = true
    form.btn_event.NormalImage = "gui\\special\\sns_new\\btn_news1_out.png"
    form.btn_event.FocusImage = "gui\\special\\sns_new\\btn_news1_on.png"
    form.groupbox_select.Visible = true
    form.groupbox_select.AbsTop = form.form_friend_list.AbsTop - form.groupbox_select.Height
    btn.is_show = true
    nx_execute("form_stage_main\\form_relation\\form_world_news", "show_form", false)
  else
    form.form_friend_list.Visible = false
    nx_execute("form_stage_main\\form_relation\\form_world_news", "show_form", false)
    form.btn_event.NormalImage = "gui\\special\\sns_new\\btn_news2_out.png"
    form.btn_event.FocusImage = "gui\\special\\sns_new\\btn_news2_on.png"
    form.groupbox_select.Visible = false
    form.groupbox_select.AbsTop = form.form_friend_list.AbsTop - form.groupbox_select.Height
    btn.is_show = false
  end
end
function search_sworn_result(player, table_name, key_name)
  if not player:FindRecord(table_name) then
    return false
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local player_name = nx_widestr(player:QueryRecord(table_name, i, SWORN_REC_COL_NAME))
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(key_name)) then
      return true, ""
    end
  end
  return false
end
function search_friend_result(player, table_name, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, FRIEND_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_MENPAI))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, FRIEND_REC_ONLINE))
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(key_name)) then
      return true, uid
    end
  end
  return false
end
function search_enemy_result(player, table_name, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, ENEMY_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_MENPAI))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, ENEMY_REC_ONLINE))
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(key_name)) then
      return true, uid
    end
  end
  return false
end
function search_fans_result(player, table_name, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, 0))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, 1))
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(key_name)) then
      return true, uid
    end
  end
  return false
end
function search_black_result(player, table_name, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, 0))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, 1))
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(key_name)) then
      return true, uid
    end
  end
  return false
end
function get_relation_type_by_name(player_name)
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    return
  end
  local bFind, uid = search_sworn_result(client_role, "SwornRelationRec", player_name)
  if bFind then
    return bFind, RELATION_TYPE_SWORN, uid
  end
  local bFind, uid = search_friend_result(client_role, FRIEND_REC, player_name)
  if bFind then
    return bFind, RELATION_TYPE_FRIEND, uid
  end
  if not bFind then
    bFind, uid = search_friend_result(client_role, BUDDY_REC, player_name)
    if bFind then
      return bFind, RELATION_TYPE_BUDDY, uid
    end
  end
  if not bFind then
    bFind, uid = search_friend_result(client_role, ATTENTION_REC, player_name)
    if bFind then
      return bFind, RELATION_TYPE_ATTENTION, uid
    end
  end
  if not bFind then
    bFind, uid = search_enemy_result(client_role, ENEMY_REC, player_name)
    if bFind then
      return bFind, RELATION_TYPE_ENEMY, uid
    end
  end
  if not bFind then
    bFind, uid = search_enemy_result(client_role, BLOOD_REC, player_name)
    if bFind then
      return bFind, RELATION_TYPE_BLOOD, uid
    end
  end
  if not bFind then
    bFind, uid = search_black_result(client_role, FILTER_REC, player_name)
    if bFind then
      return bFind, RELATION_TYPE_FLITER, uid
    end
  end
  if not bFind then
    bFind, uid = search_fans_result(client_role, FANS_REC, player_name)
    if bFind then
      return bFind, RELATION_TYPE_FANS, uid
    end
  end
  return false
end
function show_player_control(form, bChecked)
  form.gb_center.Visible = bChecked
  form.groupbox_character.Visible = false
  form.btn_player_info.Visible = true
  form.btn_relation.Visible = true
  form.btn_pingjia.Visible = true
end
function show_renmai_nums()
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  local nums = 0
  local online_nums = 0
  local relation_type = RELATION_TYPE_RENMAI_SELF
  if nx_find_custom(form, "relation_type") then
    relation_type = form.relation_type
  end
  if nx_int(relation_type) == nx_int(RELATION_TYPE_RENMAI_SELF) then
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_FRIEND) then
    local player_haoyou = 0
    if player:FindRecord(FRIEND_REC) then
      player_haoyou = player:GetRecordRows(FRIEND_REC)
      for i = 0, player_haoyou - 1 do
        local logic_state = player:QueryRecord(FRIEND_REC, i, FRIEND_REC_ONLINE)
        if nx_int(logic_state) > nx_int(-1) then
          online_nums = online_nums + 1
        end
      end
    end
    nums = nums + player_haoyou
    local player_zhiyou = 0
    if player:FindRecord(BUDDY_REC) then
      player_zhiyou = player:GetRecordRows(BUDDY_REC)
      for i = 0, player_zhiyou - 1 do
        local logic_state = player:QueryRecord(BUDDY_REC, i, FRIEND_REC_ONLINE)
        if nx_int(logic_state) > nx_int(-1) then
          online_nums = online_nums + 1
        end
      end
    end
    nums = nums + player_zhiyou
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_ENEMY) then
    local player_chouren = 0
    if player:FindRecord(ENEMY_REC) then
      player_chouren = player:GetRecordRows(ENEMY_REC)
      for i = 0, player_chouren - 1 do
        local logic_state = player:QueryRecord(ENEMY_REC, i, FRIEND_REC_ONLINE)
        if nx_int(logic_state) > nx_int(-1) then
          online_nums = online_nums + 1
        end
      end
    end
    nums = nums + player_chouren
    local player_xuechou = 0
    if player:FindRecord(BLOOD_REC) then
      player_xuechou = player:GetRecordRows(BLOOD_REC)
      for i = 0, player_xuechou - 1 do
        local logic_state = player:QueryRecord(BLOOD_REC, i, FRIEND_REC_ONLINE)
        if nx_int(logic_state) > nx_int(-1) then
          online_nums = online_nums + 1
        end
      end
    end
    nums = nums + player_xuechou
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_ATTENTION) then
    local player_guanzhu = 0
    if player:FindRecord(ATTENTION_REC) then
      player_guanzhu = player:GetRecordRows(ATTENTION_REC)
      for i = 0, player_guanzhu - 1 do
        local logic_state = player:QueryRecord(ATTENTION_REC, i, FRIEND_REC_ONLINE)
        if nx_int(logic_state) > nx_int(-1) then
          online_nums = online_nums + 1
        end
      end
    end
    nums = nums + player_guanzhu
  end
  if 0 < nums then
    form.lbl_1.Text = nx_widestr(nx_string(online_nums) .. "/" .. nx_string(nums))
    form.lbl_1.Visible = true
  else
    form.lbl_1.Visible = false
  end
  return nums, online_nums
end
function get_renmai_text()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  local nums = show_renmai_nums()
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_sns_backbutton1")
  gui.TextManager:Format_AddParam(name)
  local text1 = gui.TextManager:Format_GetText()
  gui.TextManager:Format_SetIDName("ui_sns_backbutton2")
  gui.TextManager:Format_AddParam(nx_int(nums))
  local text2 = gui.TextManager:Format_GetText()
  local renmai_form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(renmai_form) then
    return
  end
  local relation_type = RELATION_TYPE_RENMAI_SELF
  if nx_find_custom(renmai_form, "relation_type") then
    relation_type = renmai_form.relation_type
  end
  if nx_int(relation_type) == nx_int(RELATION_TYPE_RENMAI_SELF) then
    gui.TextManager:Format_SetIDName("ui_sns_backbutton8")
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_FRIEND) then
    gui.TextManager:Format_SetIDName("ui_sns_backbutton3")
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_ENEMY) then
    gui.TextManager:Format_SetIDName("ui_sns_backbutton5")
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_ATTENTION) then
    gui.TextManager:Format_SetIDName("ui_sns_backbutton7")
  end
  local text3 = gui.TextManager:Format_GetText()
  local form = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form) then
    form.mltbox_title:Clear()
    form.mltbox_title:AddHtmlText(nx_widestr(text1 .. text2 .. text3), -1)
    return text1 .. text2
  end
end
function get_friend_text(table_name, id)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local form = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form) then
    local text = get_renmai_text()
    if player:FindRecord(table_name) then
      rows = player:GetRecordRows(table_name)
    else
      rows = 0
    end
    local haoyou_nums = 0
    local zhiyou_nums = 0
    local guanzhu_nums = 0
    if player:FindRecord("rec_npc_relation") then
      npc_rows = player:GetRecordRows("rec_npc_relation")
      for i = 0, npc_rows - 1 do
        local npc_relation = nx_string(player:QueryRecord("rec_npc_relation", i, 3))
        if nx_number(npc_relation) == 0 then
          haoyou_nums = haoyou_nums + 1
        elseif nx_number(npc_relation) == 1 then
          zhiyou_nums = haoyou_nums + 1
        elseif nx_number(npc_relation) == 2 then
          guanzhu_nums = haoyou_nums + 1
        end
      end
    end
    if id == "3" then
      rows = rows + haoyou_nums
    elseif id == "4" then
      rows = rows + zhiyou_nums
    elseif id == "7" then
      rows = rows + guanzhu_nums
    end
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_sns_backbutton" .. id)
    gui.TextManager:Format_AddParam(nx_int(rows))
    text = text .. gui.TextManager:Format_GetText()
    form.mltbox_title:Clear()
    form.mltbox_title:AddHtmlText(nx_widestr(text), -1)
    form.mltbox_title.info = text
  end
end
function show_player_name(npc_id)
  local gui = nx_value("gui")
  local name
  if is_relation_npc(npc_id) then
    name = gui.TextManager:GetText(nx_string(npc_id))
  else
    name = npc_id
  end
  local form = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form) and nx_find_custom(form.mltbox_title, "info") then
    local text = form.mltbox_title.info
    text = nx_widestr(text) .. nx_widestr("\161\162") .. nx_widestr(name)
    form.mltbox_title:Clear()
    form.mltbox_title:AddHtmlText(nx_widestr(text), -1)
  end
end
function is_relation_npc(npc_id)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return false
  end
  if player:FindRecord("rec_npc_relation") then
    local rows = player:GetRecordRows("rec_npc_relation")
    if 0 < rows then
      for i = 0, rows - 1 do
        local id = player:QueryRecord("rec_npc_relation", i, 0)
        if nx_string(npc_id) == nx_string(id) then
          return true
        end
      end
    end
  end
  if player:FindRecord("rec_npc_attention") then
    local rows = player:GetRecordRows("rec_npc_attention")
    if 0 < rows then
      for i = 0, rows - 1 do
        local id = player:QueryRecord("rec_npc_attention", i, 0)
        if nx_string(npc_id) == nx_string(id) then
          return true
        end
      end
    end
  end
  return false
end
function on_rbtn_friend_checked_changed(self)
  if not self.Checked then
    change_form_size(self.ParentForm)
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.btn_event.is_show then
    return
  end
  form.form_friend_list.Visible = self.Checked
  if nx_boolean(self.Checked) then
    local form_great_events = nx_value("form_stage_main\\form_relation\\form_great_events")
    if nx_is_valid(form_great_events) then
      form_great_events:Close()
    end
    local form_feed_info = nx_value("form_stage_main\\form_relation\\form_feed_info")
    if nx_is_valid(form_feed_info) then
      form_feed_info:Close()
    end
    local form_feed_simple = nx_value("form_stage_main\\form_relation\\form_feed_simple")
    if nx_is_valid(form_feed_simple) then
      form_feed_simple:Close()
    end
    local form_gossip_info = nx_value("form_stage_main\\form_relation\\form_gossip_info")
    if nx_is_valid(form_gossip_info) then
      form_gossip_info:Close()
    end
  end
end
function on_rbtn_new_checked_changed(self)
  if not self.Checked then
    change_form_size(self.ParentForm)
  end
  nx_execute("form_stage_main\\form_relation\\form_world_news", "show_form", self.Checked, 2, false)
  change_form_size()
end
function show_character(npc_id)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local relation = -1
  local rows = client_player:FindRecordRow("rec_npc_relation", 0, npc_id, 0)
  if 0 <= rows then
    relation = client_player:QueryRecord("rec_npc_relation", rows, 3)
  end
  local karma = get_npc_karma(npc_id)
  if karma == nil then
    form.lbl_npc_relation.Text = get_karma_name(0, false)
    add_karma_bar_info(form, 0)
  else
    form.lbl_npc_relation.Text = get_karma_name(karma, false)
    add_karma_bar_info(form, karma)
  end
  local CharacterFlag = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Character")))
  local Story = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Story"))
  local desc = ""
  if "" ~= Story then
    desc = gui.TextManager:GetText(Story)
  else
    desc = gui.TextManager:GetText("ui_sns_npc_nomess")
  end
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(nx_widestr(desc), -1)
  form.lbl_kuang.Top = 40
  form.lbl_kuang.Left = 87
  form.lbl_xie.Top = 40
  form.lbl_xie.Left = 58
  if CharacterFlag == 0 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
  elseif CharacterFlag == 1 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = true
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_colour.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
  elseif CharacterFlag == 2 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_e.png"
    form.lbl_e_bar.Visible = true
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_colour.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
  elseif CharacterFlag == 3 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_kuang.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = true
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_colour.png"
    form.lbl_kuang.Top = 16
    form.lbl_kuang.Left = 72
  elseif CharacterFlag == 4 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xie.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = true
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_colour.png"
    form.lbl_xie.Top = 16
    form.lbl_xie.Left = 72
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
  end
  form.groupbox_character.Visible = true
end
function show_jieshi()
  nx_execute("custom_sender", "custom_query_enemy_info", 0, 6)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.form_friend_list.PlayerType = ACQUAINT_TYPE
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list, 1)
  form.btn_player_info.Enabled = false
  form.rbtn_friend.Text = nx_widestr(util_text("ui_jieshi_01"))
  form.rbtn_new.Enabled = false
  form.form_friend_list.rbtn_all.Checked = true
  form.form_friend_list.lbl_friend.Visible = true
  form.form_friend_list.lbl_zhiyou.Visible = false
  form.form_friend_list.lbl_chouren.Visible = false
  form.form_friend_list.rbtn_all.NormalImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_jieshi_out.png"
  form.form_friend_list.rbtn_all.FocusImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_jieshi_on.png"
  form.form_friend_list.rbtn_all.CheckedImage = "gui\\language\\ChineseS\\sns_new\\list\\cbtn_jieshi_on.png"
  form.form_friend_list.rbtn_player.Visible = false
  form.form_friend_list.rbtn_npc.Visible = false
  form.form_friend_list.player_list.IsEditMode = false
  form.form_friend_list.player_list:ResetChildrenYPos()
  local sns_manager = nx_value(SnsManagerCacheName)
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns\\jieshi.png"
  form.btn_reco_teacher.Visible = false
end
function on_rbtn_jieshi_checked_changed(self)
  if self.Checked == true then
    show_jieshi()
  end
end
function on_rbtn_black_checked_changed(self)
end
function show_renmai_news_num()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  local num = 0
  num = get_news_haoyou()
  if nx_number(num) ~= nx_number(0) then
    form.rbtn_npc_haoyou.Text = nx_widestr(util_text("ui_haoyou")) .. nx_widestr(" (" .. nx_string(num) .. ")")
  else
    form.rbtn_npc_haoyou.Text = nx_widestr(util_text("ui_haoyou"))
  end
  num = get_news_zhiyou()
  if nx_number(num) ~= nx_number(0) then
    form.rbtn_npc_zhiyou.Text = nx_widestr(util_text("ui_zhiyou_01")) .. nx_widestr(" (" .. nx_string(num) .. ")")
  else
    form.rbtn_npc_zhiyou.Text = nx_widestr(util_text("ui_zhiyou_01"))
  end
  num = get_news_guanzhu()
  if nx_number(num) ~= nx_number(0) then
    form.rbtn_npc_guanzhu.Text = nx_widestr(util_text("ui_guanzhu_01")) .. nx_widestr(" (" .. nx_string(num) .. ")")
  else
    form.rbtn_npc_guanzhu.Text = nx_widestr(util_text("ui_guanzhu_01"))
  end
end
function add_karma_bar_info(form, value)
  local min_val, max_val, name, pic = get_karma_msg_config(value)
  form.lbl_karma_mark.BackImage = pic
  value = nx_int(value)
  local len = max_val - min_val
  local reality = value - min_val
  form.lbl_karma_mark.Left = form.lbl_karma_bar.Left + (reality / len * form.lbl_karma_bar.Width - form.lbl_karma_mark.Width / 2)
  form.lbl_karma_bar.HintText = nx_widestr(util_text("ui_presentkarma")) .. nx_widestr(util_text(name))
end
function get_karma_name(value, grouped)
  value = nx_int(value)
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return nx_widestr("")
  end
  local sec_index = -1
  if grouped then
    sec_index = ini:FindSectionIndex("GroupKarma")
  else
    sec_index = ini:FindSectionIndex("Karma")
  end
  ini:FindSectionIndex("GroupKarma")
  if sec_index < 0 then
    return nx_widestr("")
  end
  local gui = nx_value("gui")
  local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(GroupMsgData)) do
    local stepData = util_split_string(GroupMsgData[i], ",")
    if value >= nx_int(stepData[1]) and value <= nx_int(stepData[2]) then
      return gui.TextManager:GetText(nx_string(stepData[3]))
    end
  end
  return nx_widestr("")
end
function get_npc_karma(npc_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  if not client_player:FindRecord("rec_npc_relation") then
    return nil
  end
  local row = client_player:FindRecordRow("rec_npc_relation", 0, npc_id, 0)
  if row < 0 then
    return nil
  end
  local karma = nx_int(client_player:QueryRecord("rec_npc_relation", row, 2))
  return karma
end
function get_news_haoyou()
  local player = get_client_player()
  if not nx_is_valid(player) then
    return 0
  end
  local table_name = "rec_npc_relation"
  local num = 0
  if player:FindRecord(table_name) then
    local rows = player:GetRecordRows(table_name)
    if 0 < rows then
      for i = 0, rows - 1 do
        local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
        local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
        if nx_number(npc_relation) == 0 then
          num = get_npc_news(npc_id) + num
        end
      end
    end
  end
  return num
end
function get_news_zhiyou()
  local player = get_client_player()
  if not nx_is_valid(player) then
    return 0
  end
  local table_name = "rec_npc_relation"
  local num = 0
  if player:FindRecord(table_name) then
    local rows = player:GetRecordRows(table_name)
    if 0 < rows then
      for i = 0, rows - 1 do
        local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
        local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
        if nx_number(npc_relation) == 1 then
          num = get_npc_news(npc_id) + num
        end
      end
    end
  end
  return num
end
function get_news_guanzhu()
  local table_name = "rec_npc_attention"
  local player = get_client_player()
  if not nx_is_valid(player) then
    return 0
  end
  if not player:FindRecord(table_name) then
    return 0
  end
  local num = 0
  local rows = player:GetRecordRows(table_name)
  for i = 0, rows - 1 do
    local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
    num = get_npc_news(npc_id) + num
  end
  return num
end
function get_npc_news(npc_id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return 0
  end
  local res_list = karmamgr:GetNpcPrize(nx_string(npc_id))
  local news_count = nx_number(table.getn(res_list)) / 3
  return nx_int(news_count)
end
function on_btn_reco_teacher_click(btn)
  nx_execute("form_stage_main\\form_school_war\\form_school_teacher_list", "request_teacher_list")
end
function show_relation_groupbox(relation_type)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_obj_type.Visible = true
  if nx_int(relation_type) >= nx_int(RELATION_TYPE_NPC_FRIEND) and nx_int(realtion_type) <= nx_int(RELATION_TYPE_NPC_ATTENTION) then
    form.rbtn_npc.Checked = true
    form.groupbox_npc_rbtn.Visible = true
    form.rbtn_player.Checked = false
    form.groupbox_rbtn.Visible = false
  else
    form.rbtn_npc.Checked = false
    form.groupbox_npc_rbtn.Visible = false
    form.rbtn_player.Checked = true
    form.groupbox_rbtn.Visible = true
  end
end
function hide_relation_groupbox(relation_type)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_obj_type.Visible = false
  form.groupbox_rbtn.Visible = false
  form.groupbox_npc_rbtn.Visible = false
  if nx_int(relation_type) >= nx_int(RELATION_TYPE_NPC_FRIEND) and nx_int(realtion_type) <= nx_int(RELATION_TYPE_NPC_ATTENTION) then
    form.gb_btnlist.Visible = false
  end
end
function on_rbtn_player_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_rbtn.is_checked = true
  form.groupbox_npc_rbtn.is_checked = false
  form.groupbox_rbtn.Visible = true
  form.groupbox_npc_rbtn.Visible = false
  if not form.rbtn_haoyou.Checked then
    form.rbtn_haoyou.Checked = true
  else
    show_haoyou()
  end
  form.rbtn_npc.Checked = false
  get_renmai_text()
  nx_execute("form_stage_main\\form_relation\\form_gossip_info", "close_form")
  form.btn_add_player.Visible = true
end
function on_rbtn_npc_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_rbtn.is_checked = false
  form.groupbox_npc_rbtn.is_checked = true
  form.groupbox_rbtn.Visible = false
  form.groupbox_npc_rbtn.Visible = true
  if not form.rbtn_npc_haoyou.Checked then
    form.rbtn_npc_haoyou.Checked = true
  else
    show_npc_haoyou()
  end
  form.rbtn_player.Checked = false
  get_renmai_text()
  InitGossipForm(form)
  form.btn_add_player.Visible = false
  form.btn_reco_teacher.Visible = false
end
function on_btn_rank_click(self)
  util_show_form("form_stage_main\\form_rank\\form_rank_main", true)
end
function on_btn_origin_click(self)
  nx_execute("form_stage_main\\form_origin\\form_origin", "auto_show_hide_origin")
end
function on_btn_note_click(self)
  util_show_form("form_stage_main\\form_note\\form_new_note", true)
end
function on_btn_news_click(self)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_news")
  if nx_is_valid(form) then
    form:Close()
  else
    util_show_form("form_stage_main\\form_relation\\form_relation_news", true)
  end
end
function show_red_dot(flag)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_dot.Visible = nx_boolean(flag)
end
