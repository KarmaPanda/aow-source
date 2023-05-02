require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_MAIN_TEAM = "form_stage_main\\form_battlefield_wulin\\form_wulin_main_team"
local wudao_tip_leader_can_not_quit = "wudao_systeminfo_10010"
local wudao_tip_not_in_team = "wudao_systeminfo_10007"
local wudao_tip_not_team = "wudao_systeminfo_10006"
local wudao_tip_not_select = "wudao_systeminfo_10102"
local wudao_tip_input_team_name = "wudao_systeminfo_10103"
local wudao_tip_not_judge = "wudao_systeminfo_10104"
local image_member = "gui/special/battlefiled_wudao/team_member.png"
local image_leader = "gui/special/battlefiled_wudao/team_leader.png"
local mouse_out = "gui/special/battlefiled_wudao/team_btn_out.png"
local mouse_on = "gui/special/battlefiled_wudao/team_btn_on.png"
local gbox_mouse_on = "gui/special/battlefiled_wudao/match_gb_on.png"
local gbox_mouse_out = "gui/special/battlefiled_wudao/match_gb_out.png"
local rank_one = "gui/special/battlefiled_wudao/rank_1.png"
local rank_two = "gui/special/battlefiled_wudao/rank_2.png"
local rank_three = "gui/special/battlefiled_wudao/rank_3.png"
local rank_othre = "gui/special/battlefiled_wudao/rank_4.png"
local not_in_war_scene = "wudao_systeminfo_10066"
local PLAYER_NAME = {}
function open_form()
  if not is_in_wudao_prepare_scene() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", not_in_war_scene)
    return
  end
  local form_main_team = nx_value(FORM_WULIN_MAIN_TEAM)
  if nx_is_valid(form_main_team) and not form_main_team.Visible then
    form_main_team.Visible = true
  else
    form_main_team = util_show_form(FORM_WULIN_MAIN_TEAM, true)
  end
  if not nx_is_valid(form_main_team) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", form_main_team)
    game_timer:Register(3000, -1, nx_current(), "update_left_time", form_main_team, -1, -1)
  end
end
function main_form_init(self)
  self.Fixed = false
  self.select_team_name = ""
  self.reject_uid = ""
  self.team_photo = 0
  self.room = 1
  self.player_classify = 1
  self.group_player_classify = 1
  self.left_time_1 = 0
  self.left_time_2 = 0
  self.left_time_3 = 0
  self.left_time_4 = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  self.rbtn_my_team.Checked = true
  self.rbtn_room_1.Checked = true
  if is_player_in_war_team() then
    custom_request_team_info()
    custom_request_team_member_info()
  end
  hide_and_stop_play_animinal(self)
  custom_request_team_list()
  custom_request_match_info()
  custom_request_take_part_info()
  group_hide_or_show_ctrl(self)
  clear_tean_name_lbl(self)
  custom_group_info()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
    game_timer:UnRegister(nx_current(), "update_left_time_1", self)
    game_timer:UnRegister(nx_current(), "update_left_time_2", self)
    game_timer:UnRegister(nx_current(), "update_left_time_3", self)
    game_timer:UnRegister(nx_current(), "update_left_time_4", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_my_team_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  if not is_player_in_war_team() then
    form.groupbox_create.Visible = true
    form.groupbox_member.Visible = false
  else
    form.groupbox_member.Visible = true
    form.groupbox_create.Visible = false
    if player_is_team_leader() then
      form.btn_dismiss.Visible = true
      form.btn_quit.Visible = false
    else
      form.btn_dismiss.Visible = false
      form.btn_quit.Visible = true
    end
  end
  form.groupbox_team.Visible = false
  form.groupbox_match.Visible = false
  form.groupbox_room.Visible = false
  form.groupbox_group.Visible = false
end
function on_rbtn_team_list_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.groupbox_member.Visible = false
  form.groupbox_create.Visible = false
  form.groupbox_team.Visible = true
  form.groupbox_match.Visible = false
  form.groupbox_room.Visible = false
  form.groupbox_group.Visible = false
end
function on_rbtn_match_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.groupbox_member.Visible = false
  form.groupbox_create.Visible = false
  form.groupbox_team.Visible = false
  form.groupbox_match.Visible = true
  form.groupbox_room.Visible = false
  form.groupbox_group.Visible = false
end
function on_rbtn_create_room_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.groupbox_member.Visible = false
  form.groupbox_create.Visible = false
  form.groupbox_team.Visible = false
  form.groupbox_match.Visible = false
  form.groupbox_room.Visible = true
  form.groupbox_group.Visible = false
end
function on_rbtn_group_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.groupbox_member.Visible = false
  form.groupbox_create.Visible = false
  form.groupbox_team.Visible = false
  form.groupbox_match.Visible = false
  form.groupbox_room.Visible = false
  form.groupbox_group.Visible = true
end
function on_btn_create_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_create.Visible then
    return
  end
  if is_player_in_war_team() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_in_team)
    return
  end
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "open_wudao_create_form")
end
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_member.Visible then
    return
  end
  if not is_player_in_war_team() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_in_team)
    return
  end
  if player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_leader_can_not_quit)
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return true
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local strTeamName = player:QueryProp("WuDaoWarTeamName")
  if nx_widestr(strTeamName) == nx_widestr("") then
    return
  end
  gui.TextManager:Format_SetIDName("ui_wudao_quit_team")
  gui.TextManager:Format_AddParam(strTeamName)
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "wudao_quit_team")
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "wudao_quit_team_confirm_return")
  if res ~= "ok" then
    return
  end
  custom_request_quit_team()
  form:Close()
end
function on_btn_dismiss_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_member.Visible then
    return
  end
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return true
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local strTeamName = player:QueryProp("WuDaoWarTeamName")
  if nx_widestr(strTeamName) == nx_widestr("") then
    return
  end
  gui.TextManager:Format_SetIDName("ui_wudao_dismiss_team")
  gui.TextManager:Format_AddParam(strTeamName)
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "wudao_dismiss_team")
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "wudao_dismiss_team_confirm_return")
  if res ~= "ok" then
    return
  end
  custom_request_dimiss_team()
  form:Close()
end
function on_btn_invent_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_member.Visible then
    return
  end
  if not is_player_in_war_team() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_in_team)
    return
  end
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_invite", "open_wudao_invent_form")
end
function on_btn_apply_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_member.Visible then
    return
  end
  if not is_player_in_war_team() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_in_team)
    return
  end
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_apply", "open_wudao_apply_form")
end
function on_btn_event_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_member.Visible then
    return
  end
  if not is_player_in_war_team() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_in_team)
    return
  end
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_daily", "open_wudao_event_form")
end
function on_groupbox_get_capture(gbox)
  if not nx_is_valid(gbox) then
    return
  end
  local form = gbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  gbox.BackImage = mouse_on
  form.groupbox_menu.Visible = false
end
function on_groupbox_lost_capture(gbox)
  if not nx_is_valid(gbox) then
    return
  end
  gbox.BackImage = mouse_out
end
function on_match_groupbox_get_capture(gbox)
  if not nx_is_valid(gbox) then
    return
  end
  gbox.BackImage = gbox_mouse_on
end
function on_match_groupbox_lost_capture(gbox)
  if not nx_is_valid(gbox) then
    return
  end
  gbox.BackImage = gbox_mouse_out
end
function on_btn_find_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local teamname = form.ipt_1.Text
  if nx_widestr(teamname) == nx_widestr("") or nx_widestr(teamname) == nx_widestr(util_text("ui_wudoa_input_name")) then
    return
  end
  custom_find_team_by_team_name(teamname)
end
function on_btn_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_team_name = nx_widestr(btn.team_name)
end
function on_ipt_1_get_focus(self)
  local gui = nx_value("gui")
  gui.hyperfocused = self
  if nx_widestr(self.Text) == nx_widestr(util_text("ui_wudoa_input_name")) then
    self.Text = ""
  end
end
function on_ipt_1_lost_focus(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_widestr(self.Text) == nx_widestr("") then
    self.Text = nx_widestr(util_text("ui_wudoa_input_name"))
  end
end
function on_btn_look_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local team_name = nx_widestr(form.select_team_name)
  if nx_widestr(team_name) == nx_widestr("") or nx_widestr(team_name) == nx_widestr("nil") then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_select)
    return
  end
  custom_find_team_by_team_name(team_name)
end
function on_btn_ready_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_ready()
end
function on_btn_begin_match_click(btn)
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  custom_request_begin_match()
end
function on_btn_attend_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  custom_request_bao_ming()
end
function on_btn_look_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
end
function on_btn_invent_match_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  local invented_name = btn.player_name
  if nx_widestr(invented_name) == nx_widestr("") or nx_widestr(invented_name) == nx_widestr("nil") then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(445), nx_widestr(invented_name))
end
function on_btn_change_leader_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  local reject_uid = nx_string(form.reject_uid)
  if nx_string(reject_uid) == nx_string("") then
    return
  end
  custom_request_change_leader(reject_uid)
end
function on_btn_reject_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  local reject_uid = nx_string(form.reject_uid)
  if nx_string(reject_uid) == nx_string("") then
    return
  end
  custom_request_reject_player(reject_uid)
end
function on_groupbox_right_click(gbox)
  local form = gbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPositionInChildControl(gbox)
  form.groupbox_menu.Left = x
  form.groupbox_menu.Top = y
  form.groupbox_menu.Visible = true
  form.reject_uid = gbox.reject_uid
end
function on_btn_teammanage_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_member.Visible then
    return
  end
  if not player_is_team_leader() then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_not_team)
    return
  end
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_damin", "open_wudao_team_damin_create_form", nx_int(form.team_photo))
end
function on_btn_final_click(btn)
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_final", "open_form")
end
function custom_request_team_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_INFO))
end
function custom_request_team_member_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_PLAYER_INFO))
end
function custom_request_quit_team()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_QUIT_BATTLE_TEAM))
end
function custom_request_team_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_LIST))
end
function custom_find_team_by_team_name(teamname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_FIND_TEAM_BY_TEAM_NAME), nx_widestr(teamname))
end
function custom_request_bao_ming()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_Apply))
end
function custom_request_match_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_PiPeiRequestUI))
end
function custom_request_reject_player(strUid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REJECT_PLAYER), nx_string(strUid))
end
function custom_request_change_leader(strUid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_CHANGE_BATTLE_TEAM_LEADER), nx_string(strUid))
end
function custom_request_begin_match()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_Join))
end
function custom_request_ready()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_PiPeiReady))
end
function custom_request_take_part_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RequestApplyUI))
end
function custom_request_dimiss_team()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RELEASE_BATTLE_TEAM))
end
function rec_player_owner_team_info(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(#arg) < nx_int(7) then
    return
  end
  if form.rbtn_my_team.Checked then
    form.groupbox_member.Visible = true
    form.groupbox_create.Visible = false
  end
  local teamname = nx_widestr(arg[1])
  form.mltbox_2.Text = teamname
  local photo = get_photo_by_index(nx_int(arg[2]))
  form.imagegrid_team_1:AddItem(0, nx_string(photo), "", 1, -1)
  form.team_photo = nx_int(arg[2])
  local rank = nx_int(arg[3])
  if nx_int(rank) == nx_int(-1) then
    form.lbl_rank_1.Text = util_text("ui_wudao_no_have_rank")
  else
    form.lbl_rank_1.Text = nx_widestr(rank)
  end
  local score = nx_int(arg[4])
  form.lbl_score_1.Text = nx_widestr(score)
  local win = nx_int(arg[5])
  form.lbl_win_num.Text = nx_widestr(win)
  local lost = nx_int(arg[6])
  form.lbl_lost_num.Text = nx_widestr(lost)
  local win_ratio = 0
  if nx_int(win + lost) ~= nx_int(0) then
    win_ratio = nx_number(win / (win + lost)) * 100
  end
  local str_ratio = string.format("%0.2f", win_ratio)
  form.lbl_winpro_1.Text = nx_widestr(str_ratio) .. nx_widestr("%")
  local member_num = nx_int(arg[7])
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.TextManager:Format_SetIDName("ui_wudao_common_8")
    gui.TextManager:Format_AddParam(member_num)
    local text_number = gui.TextManager:Format_GetText()
    form.lbl_12.Text = text_number
  end
end
function rec_team_member_info(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  local main_player_name = get_player_name()
  if form.rbtn_my_team.Checked then
    form.groupbox_member.Visible = true
    form.groupbox_create.Visible = false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupscrollbox_member:DeleteAll()
  local refer_gbox = form.groupbox_2
  if not nx_is_valid(refer_gbox) then
    return
  end
  PLAYER_NAME = {}
  for i = 1, #arg do
    local member_info = nx_widestr(arg[i])
    local member_info_list = util_split_wstring(member_info, ",")
    if nx_int(#member_info_list) == nx_int(7) then
      local player_uid = nx_string(member_info_list[1])
      local player_photo = nx_string(member_info_list[2])
      local position = nx_int(member_info_list[3])
      local player_name = member_info_list[4]
      table.insert(PLAYER_NAME, player_name)
      local win = nx_int(member_info_list[5])
      local total = nx_int(member_info_list[6])
      local lost = nx_int(total - win)
      local win_ratio = 0
      if nx_int(total) ~= nx_int(0) then
        win_ratio = nx_number(win / total) * 100
      end
      local str_ratio = nx_widestr(string.format("%0.2f", win_ratio)) .. nx_widestr("%")
      local online = nx_int(member_info_list[7])
      local gbox = create_ctrl("GroupBox", "gbox_member_" .. nx_string(i), refer_gbox, form.groupscrollbox_member)
      if nx_is_valid(gbox) then
        gbox.reject_uid = player_uid
        local lbl_name = create_ctrl("Label", "lbl_player_name_" .. nx_string(i), form.lbl_name, gbox)
        lbl_name.Text = player_name
        local lbl_position = create_ctrl("Label", "lbl_position_" .. nx_string(i), form.lbl_position, gbox)
        if nx_int(position) == nx_int(1) then
          lbl_position.BackImage = image_leader
          if nx_widestr(player_name) == nx_widestr(main_player_name) then
            form.btn_dismiss.Visible = true
            form.btn_quit.Visible = false
          else
            form.btn_dismiss.Visible = false
            form.btn_quit.Visible = true
          end
        else
          lbl_position.BackImage = image_member
        end
        local lbl_win = create_ctrl("Label", "lbl_win_" .. nx_string(i), form.lbl_zhanji_1, gbox)
        gui.TextManager:Format_SetIDName("ui_wudao_win_self")
        gui.TextManager:Format_AddParam(win)
        local text_win = gui.TextManager:Format_GetText()
        lbl_win.Text = text_win
        local lbl_lost = create_ctrl("Label", "lbl_total_" .. nx_string(i), form.lbl_zhanji_2, gbox)
        gui.TextManager:Format_SetIDName("ui_wudao_total_self")
        gui.TextManager:Format_AddParam(lost)
        local text_lost = gui.TextManager:Format_GetText()
        lbl_lost.Text = text_lost
        local lbl_ratio = create_ctrl("Label", "lbl_ratio_" .. nx_string(i), form.lbl_zhanji_3, gbox)
        gui.TextManager:Format_SetIDName("ui_wudao_winratio_self")
        gui.TextManager:Format_AddParam(str_ratio)
        local text_ratio = gui.TextManager:Format_GetText()
        lbl_ratio.Text = text_ratio
        local mlt_online = create_ctrl("MultiTextBox", "mlt_online_" .. nx_string(i), form.mltbox_line, gbox)
        if nx_int(online) == nx_int(1) then
          mlt_online.HtmlText = nx_widestr(util_text("ui_wudao_online_tips"))
        else
          mlt_online.HtmlText = nx_widestr(util_text("ui_wudao_outline"))
        end
        local grid = create_ctrl("ImageGrid", "grid_photo_" .. nx_string(i), form.imagegrid_player, gbox)
        grid:AddItem(0, player_photo, "", 1, -1)
        nx_bind_script(gbox, nx_current())
        nx_callback(gbox, "on_get_capture", "on_groupbox_get_capture")
        nx_callback(gbox, "on_lost_capture", "on_groupbox_lost_capture")
        nx_callback(gbox, "on_right_click", "on_groupbox_right_click")
      end
      change_position(gbox, nx_int(i))
    end
  end
  form.groupscrollbox_member.IsEditMode = false
  form.groupscrollbox_member:ApplyChildrenCustomYPos()
  updata_match_form()
end
function rec_team_list(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  form.groupscrollbox_team:DeleteAll()
  local refer_gbox = form.groupbox_3
  if not nx_is_valid(refer_gbox) then
    return
  end
  for i = 1, #arg do
    local team_info = nx_widestr(arg[i])
    local team_info_list = util_split_wstring(team_info, ",")
    if nx_int(#team_info_list) == nx_int(6) then
      local team_name = team_info_list[1]
      local photo_index = nx_int(team_info_list[2])
      local photo = get_photo_by_index(photo_index)
      local team_leader_name = team_info_list[3]
      local score = nx_int(team_info_list[4])
      local limite = nx_int(team_info_list[5])
      local team_member = nx_int(team_info_list[6])
      local gbox = create_ctrl("GroupBox", "gbox_team_" .. nx_string(i), refer_gbox, form.groupscrollbox_team)
      if nx_is_valid(gbox) then
        local btn = create_ctrl("Button", "btn_team_" .. nx_string(i), form.btn_1, gbox)
        if nx_is_valid(btn) then
          btn.team_name = team_name
          nx_bind_script(btn, nx_current())
          nx_callback(btn, "on_click", "on_btn_team_click")
        end
        local lbl_rank = create_ctrl("Label", "lbl_team_rank_" .. nx_string(i), form.lbl_team_rank, gbox)
        if nx_int(i) == nx_int(1) then
          lbl_rank.BackImage = rank_one
        elseif nx_int(i) == nx_int(2) then
          lbl_rank.BackImage = rank_two
        elseif nx_int(i) == nx_int(3) then
          lbl_rank.BackImage = rank_three
        else
          lbl_rank.BackImage = rank_othre
        end
        local grid = create_ctrl("ImageGrid", "grid_team_photo_" .. nx_string(i), form.imagegrid_team_2, gbox)
        grid:AddItem(0, photo, "", 1, -1)
        local lbl_team_name = create_ctrl("Label", "lbl_team_name_" .. nx_string(i), form.lbl_team_name, gbox)
        lbl_team_name.Text = team_name
        local lbl_leader_name = create_ctrl("Label", "lbl_leader_name_" .. nx_string(i), form.lbl_team_leader, gbox)
        lbl_leader_name.Text = team_leader_name
        local lbl_score = create_ctrl("Label", "lbl_score" .. nx_string(i), form.lbl_team_score, gbox)
        lbl_score.Text = nx_widestr(score)
        local mlt_limite = create_ctrl("MultiTextBox", "mlt_limite" .. nx_string(i), form.mltbox_limit, gbox)
        local gui = nx_value("gui")
        if nx_is_valid(gui) then
          gui.TextManager:Format_SetIDName("ui_wudao_win")
          gui.TextManager:Format_AddParam(limite)
          local text_limite = gui.TextManager:Format_GetText()
          mlt_limite.HtmlText = text_limite
        end
        local lbl_member = create_ctrl("Label", "lbl_member_" .. nx_string(i), form.lbl_num, gbox)
        gui.TextManager:Format_SetIDName("ui_wudao_common_9")
        gui.TextManager:Format_AddParam(team_member)
        local text_member = gui.TextManager:Format_GetText()
        lbl_member.Text = text_member
      end
    end
  end
  form.groupscrollbox_team.IsEditMode = false
  form.groupscrollbox_team:ResetChildrenYPos()
end
function rec_team_member_ready_info(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  local rbtn = form.rbtn_match
  if nx_is_valid(rbtn) then
  end
  local count = nx_int(#arg)
  if nx_int(#arg) > nx_int(6) then
    count = 6
  end
  local outer_gbox = form.groupbox_4
  if not nx_is_valid(outer_gbox) then
    return
  end
  clear_left_match_info(outer_gbox)
  hide_and_stop_play_animinal(form)
  for i = 1, nx_number(count) do
    local player_info = nx_widestr(arg[i])
    local player_info_list = util_split_wstring(player_info, ",")
    local player_photo = nx_string(player_info_list[2])
    local player_name_full = player_info_list[1]
    local player_state = nx_int(player_info_list[3])
    if nx_int(i) == nx_int(1) then
      player_state = 1
    end
    if nx_int(player_state) ~= nx_int(0) then
      local gbox_name = "groupbox_ready_" .. nx_string(i)
      local ani_gbox = outer_gbox:Find(gbox_name)
      if nx_is_valid(ani_gbox) then
        local ani_name = "ani_" .. nx_string(i)
        local ani = ani_gbox:Find(ani_name)
        if nx_is_valid(ani) then
          ani.Visible = true
          ani:Play()
        end
      end
    end
    local player_name_full_list = util_split_wstring(player_name_full, "@")
    local player_name = player_name_full_list[1]
    local player_server_name = player_name_full_list[2]
    local gbox = outer_gbox:Find("groupbox_ready_" .. nx_string(i))
    if nx_is_valid(gbox) then
      local igrid = gbox:Find("imagegrid_ready_" .. nx_string(i))
      igrid:AddItem(0, player_photo, "", 1, -1)
      local lbl_name = gbox:Find("lbl_ready_" .. nx_string(i) .. nx_string("_1"))
      lbl_name.Text = player_name
      local lbl_server = gbox:Find("lbl_ready_" .. nx_string(i) .. nx_string("_2"))
      lbl_server.Text = player_server_name
    end
  end
end
function rec_take_part_info(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  local rbtn = form.rbtn_match
  if nx_is_valid(rbtn) then
  end
  if nx_int(#arg) < nx_int(8) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local baoming_state = nx_int(arg[1])
  local is_apply_open = nx_int(arg[2]) > nx_int(0)
  local is_sea_open = nx_int(arg[3]) > nx_int(0)
  local apply_begin_time = nx_int64(arg[4])
  local apply_end_time = nx_int64(arg[5])
  local apply_day_time = nx_string(arg[6])
  local sea_begin_time = nx_int64(arg[7])
  local sea_end_time = nx_int64(arg[8])
  local sea_day_time = nx_string(arg[9])
  if apply_begin_time == nx_int64(0) then
    form.mltbox_tip_1.HtmlText = nx_widestr(util_text("ui_wudao_baoming_zhuangtai_1"))
  elseif baoming_state == nx_int(1) then
    form.mltbox_tip_1.HtmlText = nx_widestr(util_text("ui_wudao_baoming_zhuangtai_2"))
  elseif baoming_state == nx_int(2) then
    form.mltbox_tip_1.HtmlText = nx_widestr(util_text("ui_wudao_baoming_zhuangtai_3"))
  elseif baoming_state == nx_int(3) then
    form.mltbox_tip_1.HtmlText = nx_widestr(util_text("ui_wudao_baoming_zhuangtai_4"))
  end
  form.mltbox_tip_2.HtmlText = gui.TextManager:GetFormatText("ui_wudao_baoming_time_star", get_time_range_text("ui_wudao_time_mixed", apply_begin_time, apply_end_time, apply_day_time))
  form.mltbox_tip_3.HtmlText = gui.TextManager:GetFormatText("ui_wudao_haixuansai_time_star", get_time_range_text("ui_wudao_time_mixed", sea_begin_time, sea_end_time, sea_day_time))
  form.mltbox_tip_4.HtmlText = gui.TextManager:GetFormatText("ui_wudao_focused_tips_1")
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function is_player_in_war_team()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("WuDaoWarTeamName") then
    return false
  end
  local strTeamName = player:QueryProp("WuDaoWarTeamName")
  if nx_widestr(strTeamName) == nx_widestr("") then
    return false
  end
  return true
end
function player_is_team_leader()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("WuDaoWarTeamLeader") then
    return false
  end
  local isleader = player:QueryProp("WuDaoWarTeamLeader")
  if nx_int(isleader) == nx_int(1) then
    return true
  else
    return false
  end
end
function get_photo_by_index(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\WuDaoWar\\wudao_war.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("team_photo")
  if sec_count < 0 then
    return ""
  end
  local photo = ini:ReadString(sec_count, nx_string(index), "")
  return photo
end
function updata_match_form()
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  local group_parent = form.groupscrollbox_2
  if not nx_is_valid(group_parent) then
    return
  end
  group_parent:DeleteAll()
  for i = 1, #PLAYER_NAME do
    local gbox = create_ctrl("GroupBox", "gbox_match_player_" .. nx_string(i), form.groupbox_12, group_parent)
    if nx_is_valid(gbox) then
      nx_bind_script(gbox, nx_current())
      nx_callback(gbox, "on_get_capture", "on_match_groupbox_get_capture")
      nx_callback(gbox, "on_lost_capture", "on_match_groupbox_lost_capture")
      local lbl = create_ctrl("Label", "lbl_match_player_name_" .. nx_string(i), form.lbl_29, gbox)
      lbl.Text = nx_widestr(PLAYER_NAME[i])
      local btn = create_ctrl("Button", "btn_invent_match_" .. nx_string(i), form.btn_2, gbox)
      if nx_is_valid(btn) then
        btn.player_name = PLAYER_NAME[i]
        nx_bind_script(btn, nx_current())
        nx_callback(btn, "on_click", "on_btn_invent_match_click")
      end
      if not player_is_team_leader() then
        btn.Enabled = false
        form.btn_begin_match.Visible = false
        form.btn_ready.Visible = true
      else
        btn.Enabled = true
        form.btn_begin_match.Visible = true
        form.btn_ready.Visible = false
      end
    end
  end
  group_parent.IsEditMode = false
  group_parent:ResetChildrenYPos()
end
function clear_left_match_info(parent_gbox)
  if not nx_is_valid(parent_gbox) then
    return
  end
  for i = 1, 6 do
    local gbox = parent_gbox:Find("groupbox_ready_" .. nx_string(i))
    if nx_is_valid(gbox) then
      local igrid = gbox:Find("imagegrid_ready_" .. nx_string(i))
      igrid:Clear()
      local lbl_name = gbox:Find("lbl_ready_" .. nx_string(i) .. nx_string("_1"))
      lbl_name.Text = nx_widestr("")
      local lbl_server = gbox:Find("lbl_ready_" .. nx_string(i) .. nx_string("_2"))
      lbl_server.Text = nx_widestr("")
    end
  end
end
function shut_war_team_form(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if nx_is_valid(form) then
    form:Close()
  end
end
function hide_and_stop_play_animinal(form)
  if not nx_is_valid(form) then
    return
  end
  local gbox_parent = form.groupbox_4
  if nx_is_valid(gbox_parent) then
    for i = 1, 6 do
      local gbox_name = "groupbox_ready_" .. nx_string(i)
      local gbox = gbox_parent:Find(gbox_name)
      local ani_name = "ani_" .. nx_string(i)
      local ani = gbox:Find(ani_name)
      if nx_is_valid(ani) then
        ani:Stop()
        ani.Visible = false
      end
    end
  end
end
function get_time_text(time64)
  if time64 == nx_int(0) then
    return util_text("ui_wudao_time_out")
  else
    local gui = nx_value("gui")
    local year, month, day, hour, mins, sec = nx_function("util_time_utc_to_local", time64)
    local strTime = gui.TextManager:GetFormatText("ui_wudaodahui_time_mixed", nx_int(year), nx_int(month), nx_int(day), nx_int(hour), nx_int(mins))
    return strTime
  end
end
function get_time_range_text(tip_text, begin_time, end_time, day_time)
  if nx_int64(begin_time) == nx_int64(0) or nx_int64(end_time) == nx_int64(0) then
    return nx_widestr(util_text("ui_wudao_time_out"))
  else
    local gui = nx_value("gui")
    local split_day_time = util_split_string(day_time, "~")
    local begin_hour = nx_int(0)
    local begin_minute = nx_int(0)
    local end_hour = nx_int(0)
    local end_minute = nx_int(0)
    if #split_day_time == 2 then
      local split_day_begin = util_split_string(split_day_time[1], ":")
      local split_day_end = util_split_string(split_day_time[2], ":")
      begin_hour = nx_int(split_day_begin[1])
      begin_minute = nx_int(split_day_begin[2])
      end_hour = nx_int(split_day_end[1])
      end_minute = nx_int(split_day_end[2])
    end
    local str_begin_time = nx_string(get_time_text(begin_time))
    local str_end_time = nx_string(get_time_text(end_time))
    local text = gui.TextManager:GetFormatText(tip_text, str_begin_time, str_end_time, begin_hour, begin_minute, end_hour, end_minute)
    return nx_widestr(text)
  end
end
function close_form()
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if nx_is_valid(form) then
    form:Close()
  end
end
function change_position(gbox, i)
  gbox.Top = gbox.Height * (i - 1) + i * 2
end
function get_player_name()
  local player = get_player()
  if not nx_is_valid(player) then
    return nx_widestr("")
  end
  if not player:FindProp("Name") then
    return nx_widestr("")
  end
  local player_name = player:QueryProp("Name")
  return player_name
end
function on_rbtn_room_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.room = nx_int(rbtn.DataSource)
  clear_room_info()
  custom_wudao_request_room_info(nx_int(form.room))
end
function on_btn_yaoqing_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_widestr(form.ipt_team_1.Text) == nx_widestr("") or nx_widestr(form.ipt_team_2.Text) == nx_widestr("") then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_input_team_name)
  end
  custom_wudao_invent_war_team(nx_int(form.room), nx_widestr(form.ipt_team_1.Text), nx_widestr(form.ipt_team_2.Text))
end
function on_btn_view_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_view(nx_int(form.room))
end
function on_btn_leave_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_close_room(nx_int(form.room))
end
function on_btn_begin_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_begin_match(nx_int(form.room))
end
function custom_wudao_request_room_info(room_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RoomRequestUI), nx_int(room_index))
end
function custom_wudao_invent_war_team(room_index, team_name_1, team_name_2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RoomGmInvite), nx_int(room_index), nx_widestr(team_name_1), nx_widestr(team_name_2))
end
function custom_request_view(room_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RoomRequestLook), nx_int(room_index))
end
function custom_begin_match(room_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RoomGmStart), nx_int(room_index))
end
function custom_request_close_room(room_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RoomGmClose), nx_int(room_index))
end
function rec_room_info(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  local gbox_1 = form.groupbox_7
  clear_player_info(1, gbox_1)
  local gbox_2 = form.groupbox_8
  clear_player_info(2, gbox_2)
  if nx_int(#arg) < nx_int(4) then
    return
  end
  local player_classify = nx_int(arg[1])
  form.player_classify = player_classify
  show_or_hide_ctrl_by_player_classify(player_classify)
  local room_index = nx_int(arg[2])
  if nx_int(room_index) ~= nx_int(form.room) then
    return
  end
  local team_one = nx_widestr(arg[3])
  local team_one_list = util_split_wstring(team_one, ",")
  form.lbl_team_1.Text = team_one_list[1]
  for i = 2, #team_one_list do
    local lbl = get_team_player_name_lbl(1, i - 1, form.groupbox_7)
    if nx_is_valid(lbl) then
      lbl.Text = team_one_list[i]
    end
  end
  local team_two = nx_widestr(arg[4])
  local team_two_list = util_split_wstring(team_two, ",")
  form.lbl_team_2.Text = team_two_list[1]
  for j = 2, #team_two_list do
    local lbl = get_team_player_name_lbl(2, j - 1, form.groupbox_8)
    if nx_is_valid(lbl) then
      lbl.Text = team_two_list[j]
    end
  end
end
function clear_room_info()
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_team_1.Text = nx_widestr("")
  form.lbl_team_2.Text = nx_widestr("")
  form.ipt_team_1.Text = nx_widestr("")
  form.ipt_team_2.Text = nx_widestr("")
  local gbox_1 = form.groupbox_7
  clear_player_info(1, gbox_1)
  local gbox_2 = form.groupbox_8
  clear_player_info(2, gbox_2)
  form.btn_yaoqing.Visible = false
  form.btn_view.Visible = false
  form.btn_leave.Visible = false
  form.btn_begin.Visible = false
end
function clear_player_info(index, gbox)
  if not nx_is_valid(gbox) then
    return
  end
  for i = 1, 6 do
    local lbl_name = "lbl_player_" .. nx_string(index) .. nx_string("_") .. nx_string(i)
    local lbl = gbox:Find(lbl_name)
    if nx_is_valid(lbl) then
      lbl.Text = nx_widestr("")
    end
  end
end
function get_team_player_name_lbl(index, player_index, gbox)
  if not nx_is_valid(gbox) then
    return nil
  end
  local lbl_name = "lbl_player_" .. nx_string(index) .. nx_string("_") .. nx_string(player_index)
  local lbl = gbox:Find(lbl_name)
  return lbl
end
function show_or_hide_ctrl_by_player_classify(player_classify)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(player_classify) == nx_int(1) then
    form.btn_yaoqing.Visible = false
    form.btn_view.Visible = false
    form.btn_leave.Visible = false
    form.btn_begin.Visible = false
    form.ipt_team_1.Visible = false
    form.ipt_team_2.Visible = false
    form.lbl_team_1.Visible = true
    form.lbl_team_2.Visible = true
  elseif nx_int(player_classify) == nx_int(2) then
    form.btn_yaoqing.Visible = false
    form.btn_view.Visible = true
    form.btn_leave.Visible = false
    form.btn_begin.Visible = false
    form.ipt_team_1.Visible = false
    form.ipt_team_2.Visible = false
    form.lbl_team_1.Visible = true
    form.lbl_team_2.Visible = true
  elseif nx_int(player_classify) == nx_int(3) then
    form.btn_yaoqing.Visible = false
    form.btn_view.Visible = true
    form.btn_leave.Visible = false
    form.btn_begin.Visible = false
    form.ipt_team_1.Visible = false
    form.ipt_team_2.Visible = false
    form.lbl_team_1.Visible = true
    form.lbl_team_2.Visible = true
  elseif nx_int(player_classify) == nx_int(4) then
    form.btn_yaoqing.Visible = true
    form.btn_view.Visible = true
    form.btn_leave.Visible = true
    form.btn_begin.Visible = true
    form.ipt_team_1.Visible = true
    form.ipt_team_2.Visible = true
    form.lbl_team_1.Visible = true
    form.lbl_team_2.Visible = true
  end
end
function update_left_time(form)
  if not nx_is_valid(form) then
    return
  end
  custom_wudao_request_room_info(nx_int(form.room))
end
function on_btn_group_begin_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_begin_group_match(nx_int(btn.DataSource))
end
function on_btn_pause_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_stop_group_match(nx_int(btn.DataSource))
end
function on_btn_result_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_group_result", "open_wudao_score_form", nx_int(btn.DataSource))
end
function on_btn_modify_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_int(btn.DataSource)
  local gbox = get_group_gbox(form, index)
  if not nx_is_valid(gbox) then
    return
  end
  local ipt_name = "ipt_time_" .. nx_string(index)
  local ipt = gbox:Find(ipt_name)
  if not nx_is_valid(ipt) then
    return
  end
  custom_set_tip(index, nx_widestr(ipt.Text))
end
function on_btn_watch_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(btn, "team_name") then
    return
  end
  custom_request_watch_match(nx_widestr(btn.team_name))
end
function custom_group_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_GroupRequestUI))
end
function custom_begin_group_match(group_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_GroupGmStart), nx_int(group_index))
end
function custom_stop_group_match(group_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_GroupGmPause), nx_int(group_index))
end
function custom_request_watch_match(wstrTeamName)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_GoLook), nx_widestr(wstrTeamName))
end
function custom_set_tip(index, strTime)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_GroupGmSetTip), nx_int(index), nx_widestr(strTime))
end
function rec_group_match_info(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  clear_tean_name_lbl(form)
  clear_all_time(form)
  if nx_int(#arg) < nx_int(1) then
    return
  end
  form.group_player_classify = nx_int(arg[1])
  group_hide_or_show_ctrl(form)
  for i = 2, #arg do
    local group_info = nx_widestr(arg[i])
    updata_group_match_info(form, nx_int(i - 1), group_info)
  end
end
function group_hide_or_show_ctrl(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.group_player_classify) == nx_int(4) then
    form.btn_begin_1.Visible = true
    form.btn_pause_1.Visible = true
    form.btn_begin_2.Visible = true
    form.btn_pause_2.Visible = true
    form.btn_begin_3.Visible = true
    form.btn_pause_3.Visible = true
    form.btn_begin_4.Visible = true
    form.btn_pause_4.Visible = true
    form.btn_modify_1.Visible = true
    form.btn_modify_2.Visible = true
    form.btn_modify_3.Visible = true
    form.btn_modify_4.Visible = true
    form.ipt_time_1.ReadOnly = false
    form.ipt_time_2.ReadOnly = false
    form.ipt_time_3.ReadOnly = false
    form.ipt_time_4.ReadOnly = false
  else
    form.btn_begin_1.Visible = false
    form.btn_pause_1.Visible = false
    form.btn_begin_2.Visible = false
    form.btn_pause_2.Visible = false
    form.btn_begin_3.Visible = false
    form.btn_pause_3.Visible = false
    form.btn_begin_4.Visible = false
    form.btn_pause_4.Visible = false
    form.btn_modify_1.Visible = false
    form.btn_modify_2.Visible = false
    form.btn_modify_3.Visible = false
    form.btn_modify_4.Visible = false
    form.ipt_time_1.ReadOnly = true
    form.ipt_time_2.ReadOnly = true
    form.ipt_time_3.ReadOnly = true
    form.ipt_time_4.ReadOnly = true
  end
end
function updata_group_match_info(form, group_index, str_info)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local gbox = get_group_gbox(form, group_index)
  if not nx_is_valid(gbox) then
    return
  end
  local group_info_list = util_split_wstring(str_info, "|")
  local turn = nx_int(group_info_list[1])
  local lbl_turn_name = "lbl_turn_" .. nx_string(group_index)
  local lbl_turn = gbox:Find(lbl_turn_name)
  if nx_is_valid(lbl_turn) then
    lbl_turn.Text = gui.TextManager:GetFormatText("ui_wudao_turn", turn)
  end
  local ipt_time_name = "ipt_time_" .. nx_string(group_index)
  local ipt_time = gbox:Find(ipt_time_name)
  if nx_is_valid(ipt_time) then
    ipt_time.Text = group_info_list[2]
  end
  local left_time = nx_int(group_info_list[3])
  save_left_time(group_index, form, left_time)
  local state = nx_int(group_info_list[4])
  updata_by_time_and_state(group_index, form, left_time, state)
  if nx_int(state) == nx_int(4) then
    return
  end
  for i = 5, #group_info_list do
    local team_match_info = group_info_list[i]
    local team_match_info_list = util_split_wstring(team_match_info, ",")
    set_team_name(gbox, group_index, nx_int(i - 4), team_match_info_list[1], team_match_info_list[2])
  end
end
function get_group_gbox(form, index)
  if not nx_is_valid(form) then
    return
  end
  local gbox
  if nx_int(index) == nx_int(1) then
    gbox = form.groupbox_gp_1
  elseif nx_int(index) == nx_int(2) then
    gbox = form.groupbox_gp_2
  elseif nx_int(index) == nx_int(3) then
    gbox = form.groupbox_gp_3
  elseif nx_int(index) == nx_int(4) then
    gbox = form.groupbox_gp_4
  end
  return gbox
end
function update_left_time_1(form)
  if not nx_is_valid(form) then
    return
  end
  form.left_time_1 = form.left_time_1 - 1
  if nx_int(form.left_time_1) < nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "update_left_time_1", form)
    end
  else
    form.lbl_upset_1_second.Text = nx_widestr(form.left_time_1)
  end
end
function update_left_time_2(form)
  if not nx_is_valid(form) then
    return
  end
  form.left_time_2 = form.left_time_2 - 1
  if nx_int(form.left_time_2) < nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "update_left_time_2", form)
    end
  else
    form.lbl_upset_2_second.Text = nx_widestr(form.left_time_2)
  end
end
function update_left_time_3(form)
  if not nx_is_valid(form) then
    return
  end
  form.left_time_3 = form.left_time_3 - 1
  if nx_int(form.left_time_3) < nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "update_left_time_3", form)
    end
  else
    form.lbl_upset_3_second.Text = nx_widestr(form.left_time_3)
  end
end
function update_left_time_4(form)
  if not nx_is_valid(form) then
    return
  end
  form.left_time_4 = form.left_time_4 - 1
  if nx_int(form.left_time_2) < nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "update_left_time_4", form)
    end
  else
    form.lbl_upset_4_second.Text = nx_widestr(form.left_time_4)
  end
end
function save_left_time(index, form, left_time)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(index) == nx_int(1) then
    form.left_time_1 = nx_int(left_time)
  elseif nx_int(index) == nx_int(2) then
    form.left_time_2 = nx_int(left_time)
  elseif nx_int(index) == nx_int(3) then
    form.left_time_3 = nx_int(left_time)
  elseif nx_int(index) == nx_int(4) then
    form.left_time_4 = nx_int(left_time)
  end
end
function updata_by_time_and_state(index, form, left_time, state)
  if not nx_is_valid(form) then
    return
  end
  local gbox = get_group_gbox(form, index)
  if not nx_is_valid(gbox) then
    return
  end
  local lbl_state_name = "lbl_upset_" .. nx_string(index) .. "_fight_pause_over"
  local lbl_state = gbox:Find(lbl_state_name)
  local lbl_upset_name = "lbl_upset_" .. nx_string(index)
  local lbl_upset = gbox:Find(lbl_upset_name)
  local lbl_left_name = "lbl_upset_" .. nx_string(index) .. "_second"
  lbl_time = gbox:Find(lbl_left_name)
  local lbl_second_name = "lbl_upset_" .. nx_string(index) .. "_second_tips"
  local lbl_second = gbox:Find(lbl_second_name)
  if not (nx_is_valid(lbl_state) and nx_is_valid(lbl_upset) and nx_is_valid(lbl_time)) or not nx_is_valid(lbl_second) then
    return
  end
  if nx_int(state) == nx_int(0) then
    lbl_time.Visible = false
    lbl_upset.Visible = false
    lbl_second.Visible = false
    lbl_state.Visible = true
    lbl_state.Text = util_text("ui_wudao_group_10")
  elseif nx_int(state) == nx_int(1) then
    add_time(index, form)
    lbl_time.Visible = true
    lbl_upset.Visible = true
    lbl_second.Visible = true
    lbl_state.Visible = false
  elseif nx_int(state) == nx_int(2) then
    delate_time(index, form)
    lbl_time.Visible = false
    lbl_upset.Visible = false
    lbl_second.Visible = false
    lbl_state.Visible = true
    lbl_state.Text = util_text("ui_wudao_group_7")
  elseif nx_int(state) == nx_int(3) then
    delate_time(index, form)
    lbl_time.Visible = false
    lbl_upset.Visible = false
    lbl_second.Visible = false
    lbl_state.Visible = true
    lbl_state.Text = util_text("ui_wudao_group_8")
  elseif nx_int(state) == nx_int(4) then
    delate_time(index, form)
    lbl_time.Visible = false
    lbl_upset.Visible = false
    lbl_second.Visible = false
    lbl_state.Visible = true
    lbl_state.Text = util_text("ui_wudao_group_9")
  end
end
function add_time(index, form)
  if not nx_is_valid(form) then
    return
  end
  local game_timer = nx_value("timer_game")
  if not nx_is_valid(game_timer) then
    return
  end
  if nx_int(index) == nx_int(1) then
    game_timer:UnRegister(nx_current(), "update_left_time_1", form)
    game_timer:Register(1000, -1, nx_current(), "update_left_time_1", form, -1, -1)
  elseif nx_int(index) == nx_int(2) then
    game_timer:UnRegister(nx_current(), "update_left_time_2", form)
    game_timer:Register(1000, -1, nx_current(), "update_left_time_2", form, -1, -1)
  elseif nx_int(index) == nx_int(3) then
    game_timer:UnRegister(nx_current(), "update_left_time_3", form)
    game_timer:Register(1000, -1, nx_current(), "update_left_time_3", form, -1, -1)
  elseif nx_int(index) == nx_int(4) then
    game_timer:UnRegister(nx_current(), "update_left_time_4", form)
    game_timer:Register(1000, -1, nx_current(), "update_left_time_4", form, -1, -1)
  end
end
function delate_time(index, form)
  if not nx_is_valid(form) then
    return
  end
  local game_timer = nx_value("timer_game")
  if not nx_is_valid(game_timer) then
    return
  end
  if nx_int(index) == nx_int(1) then
    game_timer:UnRegister(nx_current(), "update_left_time_1", form)
  elseif nx_int(index) == nx_int(2) then
    game_timer:UnRegister(nx_current(), "update_left_time_2", form)
  elseif nx_int(index) == nx_int(3) then
    game_timer:UnRegister(nx_current(), "update_left_time_3", form)
  elseif nx_int(index) == nx_int(4) then
    game_timer:UnRegister(nx_current(), "update_left_time_4", form)
  end
end
function set_team_name(gbox, gbox_index, match_index, name_1, name_2)
  if not nx_is_valid(gbox) then
    return
  end
  local lbl_left_name = "lbl_team_" .. nx_string(gbox_index) .. nx_string("_") .. nx_string(2 * (match_index - 1) + 1)
  local lbl_right_name = "lbl_team_" .. nx_string(gbox_index) .. nx_string("_") .. nx_string(2 * (match_index - 1) + 2)
  local btn_view_name = "btn_watch_" .. nx_string(gbox_index) .. nx_string("_") .. nx_string(match_index)
  local lbl_left = gbox:Find(lbl_left_name)
  local lbl_right = gbox:Find(lbl_right_name)
  local btn_view = gbox:Find(btn_view_name)
  if not (nx_is_valid(lbl_left) and nx_is_valid(lbl_right)) or not nx_is_valid(btn_view) then
    return
  end
  lbl_left.Text = nx_widestr(name_1)
  lbl_right.Text = nx_widestr(name_2)
  btn_view.team_name = nx_widestr(name_1)
end
function clear_tean_name_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 4 do
    local gbox = get_group_gbox(form, nx_int(i))
    if nx_is_valid(gbox) then
      for j = 1, 8 do
        local lbl_name = "lbl_team_" .. nx_string(i) .. nx_string("_") .. nx_string(j)
        local lbl = gbox:Find(lbl_name)
        if nx_is_valid(lbl) then
          lbl.Text = nx_widestr("")
        end
      end
    end
  end
end
function clear_all_time(form)
  if not nx_is_valid(form) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time_1", form)
    game_timer:UnRegister(nx_current(), "update_left_time_2", form)
    game_timer:UnRegister(nx_current(), "update_left_time_3", form)
    game_timer:UnRegister(nx_current(), "update_left_time_4", form)
  end
end
function open_room_page(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    form = util_show_form(FORM_WULIN_MAIN_TEAM, true)
  end
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_create_room.Checked = true
  local gbox = form.groupscrollbox_1
  if not nx_is_valid(gbox) then
    return
  end
  local room_index = nx_int(arg[1])
  local rbtn_name = "rbtn_room_" .. nx_string(room_index)
  local rbtn = gbox:Find(rbtn_name)
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  end
end
function open_group_page(...)
  local form = nx_value(FORM_WULIN_MAIN_TEAM)
  if not nx_is_valid(form) then
    form = util_show_form(FORM_WULIN_MAIN_TEAM, true)
  end
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_group.Checked = true
end
function custom_wudao_request_web_adress()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_AliveAdress))
end
