require("role_composite")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
require("form_stage_main\\form_tvt\\define")
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  change_form_size()
  self.lbl_gift_count.Visible = false
  self.lbl_qifu_count.Visible = false
  self.lbl_gift_focus.Visible = false
  self.lbl_qifu_focus.Visible = false
  InitPresentMessage()
  local databinder = nx_value("data_binder")
  databinder:AddTableBind(PRESENT_REC, self, "form_stage_main\\form_relation\\form_relation_self", "refresh_table_changed")
  databinder:AddTableBind(QIFU_REC, self, "form_stage_main\\form_relation\\form_relation_self", "refresh_table_changed")
end
function on_main_form_close(self)
  local form = nx_value("form_stage_main\\form_relation\\form_feed_info")
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  nx_destroy(self)
end
function show_form(flag)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  if flag then
    local form_self = nx_value("form_stage_main\\form_relation\\form_relation_self")
    if not nx_is_valid(form_self) then
      local form_self = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_self", true, false)
      if nx_is_valid(form_self) then
        form:Add(form_self)
      end
    else
      form_self:Show()
      form_self.Visible = true
    end
  else
    local form_self = nx_value("form_stage_main\\form_relation\\form_relation_self")
    if nx_is_valid(form_self) then
      form_self.Visible = false
    end
  end
end
function show_self_model()
  show_form(true)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_self")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  local name = client_player:QueryProp("Name")
  sns_manager:SetRelationType(0, RELATION_TYPE_SELF)
  show_self_shane_info(form)
  form.lbl_relation.BackImage = "gui\\language\\ChineseS\\sns_new\\geren_tip.png"
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
    form.lbl_xia_bar.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
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
    form.lbl_e_bar.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
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
    form.lbl_kuang.Left = 56
    form.lbl_xie.Top = 40
    form.lbl_xie.Left = 40
    form.lbl_kuang_bar.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_kuang_bar.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
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
    form.lbl_xie.Left = 56
    form.lbl_kuang.Top = 40
    form.lbl_kuang.Left = 72
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xie_bar.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_xie_bar.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  end
end
function show_feeds()
  local form_relation = nx_value("form_stage_main\\form_relation\\form_relation_self")
  local playername = ""
  if nx_find_custom(form_relation, "CheckPlayerName") then
    playername = form_relation.CheckPlayerName
  end
  local type, form = nx_execute("form_stage_main\\form_relation\\form_feed_info", "get_sub_form")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local self_name = client_player:QueryProp("Name")
  if nx_number(type) == 0 then
    if nx_ws_equal(nx_widestr(playername), nx_widestr("")) or nx_ws_equal(nx_widestr(playername), nx_widestr(self_name)) then
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "open_blog", nx_int(9))
    else
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "open_blog", nx_int(9), nx_widestr(playername))
    end
    form_relation.btn_event.NormalImage = "gui\\special\\sns_new\\btn_news1_out.png"
    form_relation.btn_event.FocusImage = "gui\\special\\sns_new\\btn_news1_on.png"
  elseif nx_number(type) == 1 then
    form_relation.btn_event.NormalImage = "gui\\special\\sns_new\\btn_news2_out.png"
    form_relation.btn_event.FocusImage = "gui\\special\\sns_new\\btn_news2_on.png"
  elseif nx_number(type) == 2 then
    local form_reply = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply", false, false)
    if nx_is_valid(form_reply) then
      form_reply:Close()
    end
    if nx_ws_equal(nx_widestr(playername), nx_widestr("")) or nx_ws_equal(nx_widestr(playername), nx_widestr(self_name)) then
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "open_blog", nx_int(1))
    else
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "open_blog", nx_int(3), nx_widestr(playername))
    end
    form_relation.btn_event.NormalImage = "gui\\special\\sns_new\\btn_news1_out.png"
    form_relation.btn_event.FocusImage = "gui\\special\\sns_new\\btn_news1_on.png"
  elseif nx_number(type) == 3 then
    form_relation.btn_event.NormalImage = "gui\\special\\sns_new\\btn_news1_out.png"
    form_relation.btn_event.FocusImage = "gui\\special\\sns_new\\btn_news1_on.png"
  end
end
function on_btn_event_click(btn)
  local form_relation = nx_value("form_stage_main\\form_relation\\form_relation_self")
  if not nx_is_valid(form_relation) then
    return
  end
  form_relation.groupbox_select_type.Visible = not form_relation.groupbox_select_type.Visible
  if form_relation.groupbox_select_type.Visible then
    if form_relation.rbtn_feed_info.Checked then
      on_rbtn_feed_info_checked_changed(form_relation.rbtn_feed_info)
    elseif form_relation.rbtn_bagua.Checked then
      on_rbtn_bagua_checked_changed(form_relation.rbtn_bagua)
    end
    form_relation.btn_event.NormalImage = "gui\\special\\sns_new\\btn_news1_out.png"
    form_relation.btn_event.FocusImage = "gui\\special\\sns_new\\btn_news1_on.png"
  else
    nx_execute("form_stage_main\\form_relation\\form_feed_info", "close_all_blog")
    nx_execute("form_stage_main\\form_relation\\form_gossip_info", "close_form")
    form_relation.btn_event.NormalImage = "gui\\special\\sns_new\\btn_news2_out.png"
    form_relation.btn_event.FocusImage = "gui\\special\\sns_new\\btn_news2_on.png"
  end
end
function ChangePosition()
  local main_form = nx_value("form_stage_main\\form_relation\\form_relation_self")
  local type, weibo_form = nx_execute("form_stage_main\\form_relation\\form_feed_info", "get_sub_form")
  local gossip_form = nx_value("form_stage_main\\form_relation\\form_gossip_info")
  if not nx_is_valid(main_form) then
    return
  end
  local sub_form
  if nx_is_valid(weibo_form) then
    sub_form = weibo_form
  elseif nx_is_valid(gossip_form) then
    sub_form = gossip_form
  else
    return
  end
  main_form.groupbox_select_type.AbsLeft = sub_form.AbsLeft
  main_form.groupbox_select_type.AbsTop = sub_form.AbsTop - main_form.groupbox_select_type.Height
end
function on_rbtn_feed_info_checked_changed(rbtn)
  if rbtn.Checked == true then
    nx_execute("form_stage_main\\form_relation\\form_feed_info", "close_all_blog")
    nx_execute("form_stage_main\\form_relation\\form_gossip_info", "close_form")
    show_feeds()
    ChangePosition()
  end
end
function on_rbtn_bagua_checked_changed(rbtn)
  if rbtn.Checked == true then
    nx_execute("form_stage_main\\form_relation\\form_feed_info", "close_all_blog")
    nx_execute("form_stage_main\\form_relation\\form_gossip_info", "close_form")
    show_gossip()
    ChangePosition()
  end
end
function show_gossip()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_self")
  local sub_form = nx_value("form_stage_main\\form_relation\\form_gossip_info")
  if not nx_is_valid(sub_form) then
    sub_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_gossip_info", true, false)
  end
  if not nx_is_valid(sub_form) then
    return
  end
  sub_form.type = 1
  form:Add(sub_form)
  sub_form:Show()
  sub_form.Visible = true
end
function on_btn_gift_click(self)
  local form = self.ParentForm
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
function focus_light(optype)
  if nx_int(optype) == nx_int(0) then
    nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_item", 4, "")
  elseif nx_int(optype) == nx_int(1) then
    nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_item", 5, "")
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_self")
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
  local form_self = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_self", true, false)
  if nx_is_valid(form_self) then
    form_self.Left = 0
    form_self.Top = 0
    form_self.Width = form.Width
    form_self.Height = form.Height - form.groupbox_rbtn.Height
    local form_feed = nx_value("form_stage_main\\form_relation\\form_feed_info")
    if nx_is_valid(form_feed) then
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "change_form_size", form_feed)
    end
    form_feed = nx_value("form_stage_main\\form_relation\\form_feed_reply")
    if nx_is_valid(form_feed) then
      nx_execute("form_stage_main\\form_relation\\form_feed_reply", "change_form_size", form_feed)
    end
    form_feed = nx_value("form_stage_main\\form_relation\\form_feed_reply_simple")
    if nx_is_valid(form_feed) then
      nx_execute("form_stage_main\\form_relation\\form_feed_reply_simple", "change_form_size", form_feed)
    end
    form_feed = nx_value("form_stage_main\\form_relation\\form_feed_simple")
    if nx_is_valid(form_feed) then
      nx_execute("form_stage_main\\form_relation\\form_feed_simple", "change_form_size", form_feed)
    end
    form_feed = nx_value("form_stage_main\\form_relation\\form_gossip_info")
    if nx_is_valid(form_feed) then
      nx_execute("form_stage_main\\form_relation\\form_gossip_info", "change_form_size", form_feed)
    end
    if form_self.groupbox_select_type.Visible then
      ChangePosition()
    end
  end
end
function on_relation_type_change_event(relation_type)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_self")
  if nx_is_valid(form) then
    form.gb_self_shan_e.Visible = false
    get_geren_text()
  end
end
function on_focus_change_event(group_id, relation_type, index, name)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_self")
  if nx_is_valid(form) then
    show_self_shane_info(form)
    form.gb_self_shan_e.Visible = true
  end
end
function on_btn_1_click(self)
  send_server_msg(g_msg_player_list, ITT_ARREST)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_info", "show_tvt_info", ITT_ARREST)
end
function on_btn_2_click(self)
  send_server_msg(g_msg_player_list, ITT_WORLDLEITAI)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_info", "show_tvt_info", ITT_WORLDLEITAI)
end
function on_btn_3_click(self)
  send_server_msg(g_msg_player_list, ITT_XIASHI)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_info", "show_tvt_info", ITT_XIASHI)
end
function on_btn_4_click(self)
  send_server_msg(g_msg_player_list, ITT_BANGFEI)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_info", "show_tvt_info", ITT_BANGFEI)
end
function on_btn_5_click(self)
  util_show_form("form_stage_main\\form_rank\\form_rank_main", true)
end
function on_btn_6_click(self)
  nx_execute("form_stage_main\\form_origin\\form_origin", "auto_show_hide_origin")
end
function on_btn_7_click(self)
  util_show_form("form_stage_main\\form_note\\form_new_note", true)
end
function on_btn_8_click(self)
  util_show_form("form_stage_main\\form_origin\\form_kapai", true)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Desktop:ToFront(nx_value("form_stage_main\\form_origin\\form_kapai"))
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_card_click(self)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_card\\form_card")
end
function get_geren_text()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_sns_backbutton1")
  gui.TextManager:Format_AddParam(name)
  local text1 = gui.TextManager:Format_GetText()
  gui.TextManager:Format_SetIDName("ui_sns_backbutton8")
  local text2 = gui.TextManager:Format_GetText()
  local form = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form) then
    form.mltbox_title:Clear()
    form.mltbox_title:AddHtmlText(nx_widestr(text1 .. text2), -1)
    return text1 .. text2
  end
end
