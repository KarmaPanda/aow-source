require("util_gui")
require("util_functions")
require("share\\view_define")
require("define\\request_type")
require("define\\object_type_define")
require("util_role_prop")
local FORM_FACULTY_TEAM = "form_stage_main\\form_wuxue\\form_team_faculty_member"
local MAX_MEMBER = 10
local PLAY_STEP_ERROR = -1
local PLAY_STEP_WAIT = 0
local PLAY_STEP_READY = 1
local PLAY_STEP_PLAY = 2
local PLAY_STEP_OVER = 3
local SUB_CLIENT_BEGIN = 3
local SUB_CLIENT_EXIT = 4
local SUB_CLIENT_KICK_PLAYER = 30
local MAX_SINGLE_TEAM_MEMBER = 10
local PERCEPTION_MAX_POINT = 490
local CURDAY_MAX_POINT = 70
local JIUGONG_EVERYDAY_MAX_COUNT = 3
local TEAM_FACULTY_TYPE_NORMAL = 0
local TEAM_FACULTY_TYPE_DONGFANG = 1
local TEAM_FACULTY_TYPE_JIUGONG = 3
local chat_backimg = "gui\\special\\xiulian\\team_talk.png"
HEAD_MAX_WIDTH = 134
HEAD_MAX_HEIGHT = 34
function main_form_init(self)
  self.Fixed = true
  self.showhead_hp = 1
  self.showhead_info = 1
  self.showself_qg = 1
  self.playname = ""
  self.playident = ""
  self.rclick = false
end
function on_main_form_open(self)
  change_form_size()
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_TEAM_FACULTY, self, nx_current(), "on_teamfaculty_viewport_change")
    databinder:AddRolePropertyBind("Faculty", "int", self, nx_current(), "on_Faculty_change")
    databinder:AddRolePropertyBind("TeamFacultyValue", "int", self, nx_current(), "on_TeamFacultyValue_change")
    databinder:AddRolePropertyBind("TeamFacultyLast", "int", self, nx_current(), "on_TeamFacultyLast_change")
    databinder:AddRolePropertyBind("ExtTeamFacultyValue", "int", self, nx_current(), "on_ExtTeamFacultyValue_change")
    databinder:AddRolePropertyBind("ExtTeamFacultyLast", "int", self, nx_current(), "on_ExtTeamFacultyLast_change")
    databinder:AddRolePropertyBind("JiuGongEveryDayPoint", "int", self, nx_current(), "on_jiugong_everyday_count")
    databinder:AddRolePropertyBind("CurDayPerceptionPoint", "int", self, nx_current(), "on_jiugong_Perception_Point")
    databinder:AddRolePropertyBind("HeapPerceptionPoint", "int", self, nx_current(), "on_jiugong_heap_Perception_Point")
  end
  on_refresh_all_info(self)
  util_show_form("form_stage_main\\form_relationship", false)
  local form_game = util_get_form("form_stage_main\\puzzle_quest\\form_puzzle_quest", false)
  if nx_is_valid(form_game) then
    nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "show_world_alpha_out")
    form_game:Close()
  end
  nx_execute("form_stage_main\\form_main\\form_main", "move_over")
  nx_execute("gui", "gui_close_allsystem_form", 2)
  self.Visible = true
  change_form_size()
  local form_chat = util_get_form("form_stage_main\\form_main\\form_main_chat", false)
  if nx_is_valid(form_chat) then
    form_chat.Top = -580
  end
  local form_sysinfo = util_get_form("form_stage_main\\form_main\\form_main_sysinfo", false)
  if nx_is_valid(form_sysinfo) then
    form_sysinfo.Top = -380
  end
  local form_back = util_get_form("form_stage_main\\form_wuxue\\form_faculty_back", true, false)
  if not nx_is_valid(form_back) then
    return false
  end
  form_back.name = "form_stage_main\\form_wuxue\\form_team_faculty_member"
  form_back.lbl_back.BlendColor = "100,255,255,255"
  util_show_form("form_stage_main\\form_wuxue\\form_faculty_back", true)
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) then
    form_main.groupbox_4.Visible = false
    form_main.groupbox_5.Visible = false
  end
  save_head_info(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local state = client_player:QueryProp("TeamFacultyState")
  self.groupbox_score.Visible = false
  self.btn_hide.Visible = true
  self.btn_show.Visible = false
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return false
  end
  if not condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(29871)) then
    self.lbl_ext_faculty_value.Visible = false
    self.lbl_ext_faculty.Visible = false
    self.lbl_ext_faculty_last.Visible = false
    self.lbl_ext_faculty_last_value.Visible = false
    self.btn_ext_faculty.Visible = false
    self.lbl_6.Top = 221
    self.lbl_wudi.Top = 221
    self.lbl_protect.Top = 221
    self.lbl_noprotect.Top = 221
    self.groupbox_info.Height = 250
  end
  for i = 1, MAX_SINGLE_TEAM_MEMBER do
    local mltbox = self:Find("MultiTextBox_" .. i)
    if nx_is_valid(mltbox) then
      mltbox.Visible = false
    end
  end
  if nx_int(state) == nx_int(1) then
    self.btn_begin.Visible = true
    set_btn_kick_visible(self, true)
  else
    self.btn_begin.Visible = false
    set_btn_kick_visible(self, false)
  end
  nx_execute("form_stage_main\\form_main\\form_main_trumpet", "change_form_size")
  show_fix_place(self)
  show_other_obj()
  if nx_int(state) <= nx_int(0) then
    self:Close()
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
  if not nx_is_valid(self) then
    return
  end
  local data_binder = nx_value("data_binder")
  if data_binder then
    data_binder:DelTableBind("team_rec", self)
    data_binder:DelRolePropertyBind("Faculty", self)
    data_binder:DelRolePropertyBind("TeamFacultyValue", self)
    data_binder:DelRolePropertyBind("ExtTeamFacultyValue", self)
    data_binder:DelRolePropertyBind("ExtTeamFacultyLast", self)
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "count_down_time", self)
    timer:UnRegister(nx_current(), "hide_player_menu", self)
    timer:UnRegister(nx_current(), "on_refresh_all_info", self)
    timer:UnRegister("form_stage_main\\form_wuxue\\form_faculty_team", "send_to_chat_channel", self)
  end
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) and nx_is_valid(form_main.groupbox_4) and nx_is_valid(form_main.groupbox_5) then
    local bIsNewJHModule = is_newjhmodule()
    if not bIsNewJHModule then
      form_main.groupbox_4.Visible = true
      form_main.groupbox_5.Visible = true
    end
  end
  nx_execute("gui", "gui_open_closedsystem_form")
  show_head_info(self)
  on_btn_show_click(self.btn_show)
  local form_chat = util_get_form("form_stage_main\\form_main\\form_main_chat", false)
  if nx_is_valid(form_chat) then
    form_chat.Top = -681
  end
  local form_sysinfo = util_get_form("form_stage_main\\form_main\\form_main_sysinfo", false)
  if nx_is_valid(form_sysinfo) then
    form_sysinfo.Top = -407
  end
  nx_execute("form_stage_main\\form_main\\form_main_team", "update_team_panel")
  util_show_form("form_stage_main\\form_wuxue\\form_faculty_back", false)
  nx_execute("form_stage_main\\form_main\\form_main_trumpet", "change_form_size")
end
function on_teamfaculty_viewport_change(form, optype, view_ident, index)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(500, 1, nx_current(), "on_refresh_all_info", form, -1, -1)
end
function on_refresh_all_info(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local cur_turn = view:QueryProp("CurTurn")
  local total_turn = view:QueryProp("TotalTurn")
  local queue_point = view:QueryProp("QueuePoint")
  local cur_state = view:QueryProp("CurState")
  form.lbl_score.Text = nx_widestr(view:QueryProp("TotalScore"))
  form.lbl_queue.Text = nx_widestr(view:QueryProp("QueuePoint"))
  form.lbl_turn.Text = nx_widestr(nx_string(total_turn - cur_turn) .. "/" .. nx_string(total_turn))
  if nx_int(view:QueryProp("QueuePoint")) <= nx_int(0) then
    form.lbl_queue.Visible = false
    form.lbl_queue_text.Visible = false
  else
    form.lbl_queue.Visible = true
    form.lbl_queue_text.Visible = true
  end
  for i = 1, MAX_MEMBER do
    local group_box = form:Find("group_player_" .. nx_string(i))
    if nx_is_valid(group_box) then
      group_box.Visible = false
    end
  end
  local row_count = view:GetRecordRows("team_faculty_rec")
  show_protect_state(form)
  form.lbl_score.Visible = false
  form.lbl_2.Visible = false
  form.lbl_wait.Visible = true
  jiugong_interface_info(form)
  if nx_int(cur_state) ~= nx_int(PLAY_STEP_READY) then
    form.lbl_score.Visible = true
    form.lbl_2.Visible = true
    form.lbl_wait.Visible = false
  end
  local type = view:QueryProp("PlayType")
  if nx_int(type) == nx_int(TEAM_FACULTY_TYPE_DONGFANG) then
    form.groupbox_info.Height = 120
    form.groupbox_info.BackImage = "gui\\mainform\\chat\\bg_main_ndf.png"
    form.groupbox_menu.Visible = false
    form.btn_begin.Visible = false
    form.groupbox_score.Visible = false
    set_btn_kick_visible(form, false)
  else
    for row = 0, row_count - 1 do
      if row < MAX_MEMBER then
        show_player_info(form, row)
      end
    end
  end
end
function on_jiugong_everyday_count(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_count = client_player:QueryProp("JiuGongEveryDayPoint")
  form.lbl_taohua_count.Text = nx_widestr(nx_string(cur_count) .. "/" .. nx_string(JIUGONG_EVERYDAY_MAX_COUNT))
end
function on_jiugong_Perception_Point(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_Perception_Point = client_player:QueryProp("CurDayPerceptionPoint")
  form.lbl_cur_realization.Text = nx_widestr(cur_Perception_Point)
  form.lbl_succeed.Text = nx_widestr(nx_string(cur_Perception_Point) .. "/" .. nx_string(CURDAY_MAX_POINT))
end
function on_jiugong_heap_Perception_Point(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local Perception_Point = client_player:QueryProp("HeapPerceptionPoint")
  form.lbl_heap.Text = nx_widestr(nx_string(Perception_Point) .. "/" .. nx_string(PERCEPTION_MAX_POINT))
end
function on_Faculty_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_faculty = client_player:QueryProp("Faculty")
  form.lbl_faculty.Text = nx_widestr(cur_faculty)
end
function on_TeamFacultyValue_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\faculty_team_action.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("setting"))
  if sec_index < 0 then
    return 0
  end
  local total_team_value = ini:ReadInteger(sec_index, "TeamValue", 0)
  if nx_int(total_team_value) <= nx_int(0) then
    form.lbl_team_faculty.Text = nx_widestr("100%")
    return
  end
  local cur_team_value = client_player:QueryProp("TeamFacultyValue")
  local tire = nx_int((total_team_value - cur_team_value) * 100 / total_team_value)
  form.lbl_team_faculty.Text = nx_widestr(nx_string(tire) .. "%")
end
function on_ExtTeamFacultyValue_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\faculty_team_action.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("setting"))
  if sec_index < 0 then
    return 0
  end
  local total_team_value = ini:ReadInteger(sec_index, "TeamValue", 0)
  if nx_int(total_team_value) <= nx_int(0) then
    form.lbl_ext_faculty_value.Text = nx_widestr("100%")
    return
  end
  local cur_team_value = client_player:QueryProp("ExtTeamFacultyValue")
  local tire = nx_int((total_team_value - cur_team_value) * 100 / total_team_value)
  form.lbl_ext_faculty_value.Text = nx_widestr(nx_string(tire) .. "%")
end
function on_TeamFacultyLast_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local last_value = client_player:QueryProp("TeamFacultyLast")
  form.lbl_offset_faculty.Text = nx_widestr(last_value)
end
function on_ExtTeamFacultyLast_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local last_value = client_player:QueryProp("ExtTeamFacultyLast")
  form.lbl_ext_faculty_last_value.Text = nx_widestr(last_value)
end
function on_btn_begin_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_btn_kick_visible(form, false)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister("form_stage_main\\form_wuxue\\form_faculty_team", "send_to_chat_channel", form)
  end
  nx_execute("custom_sender", "custom_team_faculty", SUB_CLIENT_BEGIN)
end
function on_btn_quit_click(self)
  nx_execute("form_stage_main\\form_wuxue\\form_faculty_team", "hide_form")
end
function on_btn_wuxue_click(self)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
end
function on_btn_faculty_click(self)
  util_auto_show_hide_form("form_stage_main\\form_wuxue\\form_wuxue_faculty")
end
function on_btn_faculty_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local FACULTY_STATE_CONVERT = 2
  local FACULTY_NORMAL = 1
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_state = client_player:QueryProp("FacultyState")
  local cur_style = client_player:QueryProp("FacultyStyle")
  if nx_int(cur_state) ~= nx_int(FACULTY_STATE_CONVERT) or nx_int(cur_style) ~= nx_int(FACULTY_NORMAL) then
    return
  end
  util_show_form("form_stage_main\\form_wuxue\\form_tips_faculty", true)
  local form_tips = util_get_form("form_stage_main\\form_wuxue\\form_tips_faculty")
  form.btn_faculty.HintText = ""
  if nx_is_valid(form_tips) then
    form_tips.AbsLeft = self.AbsLeft + 2 * self.Width - form_tips.Width
    form_tips.AbsTop = self.AbsTop + 2 * self.Height - form_tips.Height
  end
end
function on_btn_faculty_lost_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  util_show_form("form_stage_main\\form_wuxue\\form_tips_faculty", false)
  form.btn_faculty.HintText = nx_widestr(util_text("ui_train_title_0_tips"))
end
function on_btn_help_click(self)
  util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
  local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
  if nx_is_valid(form_help) then
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "wxsd,wuxuext02,xiulianxt03,tuanlian04")
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_bag_click(self)
  util_auto_show_hide_form("form_stage_main\\form_bag")
end
function on_btn_role_click(self)
  nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
end
function on_btn_player_menu_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "hide_player_menu", form)
end
function on_btn_player_menu_lost_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "hide_player_menu", form)
  timer:Register(3000, 1, nx_current(), "hide_player_menu", form, -1, -1)
end
function on_btn_invite_faculty_click(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.playname == "" or form.playname == nil then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(form.playident)
  if not nx_is_valid(visual_target) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("9044"), 2)
    end
    return
  end
  nx_execute("custom_sender", "custom_request", REQUESTTYPE_INVITE_FACULTY, nx_widestr(form.playname))
end
function on_btn_equip_click(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.playname == "" or form.playname == nil then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(form.playident)
  if not nx_is_valid(visual_target) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("9044"), 2)
    end
    return
  end
  nx_execute("form_stage_main\\form_role_chakan", "get_player_info", nx_widestr(form.playname))
end
function on_btn_info_click(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.playname == "" or form.playname == nil then
    return
  end
  nx_execute("custom_sender", "custom_send_get_player_game_info", nx_widestr(form.playname))
end
function on_btn_chat_click(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.playname == "" or form.playname == nil then
    return
  end
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.playname))
end
function on_btn_friend_click(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.playname == "" or form.playname == nil then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", nx_string(form.playname))
end
function on_btn_attention_click(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.playname == "" or form.playname == nil then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", nx_string(form.playname))
end
function on_btn_hide_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_hide.Visible = false
  form.btn_show.Visible = true
  hide_other_obj()
end
function on_btn_show_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_hide.Visible = true
  form.btn_show.Visible = false
  show_other_obj()
end
function on_lbl_photo_get_capture(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rclick = false
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return false
  end
  local row = nx_int(self.DataSource) - 1
  local name = view:QueryRecord("team_faculty_rec", row, 2)
  local pressSucceed = view:QueryRecord("team_faculty_rec", row, 4)
  local pressFail = view:QueryRecord("team_faculty_rec", row, 5)
  local halfwayQuit = view:QueryRecord("team_faculty_rec", row, 6)
  local tfValue = getCurrentTeamFacultyValue(form, row)
  local ExttfValue = getCurrentTeamExtFacultyValue(form, row)
  local total_team_value = getTotal_team_value()
  local tire = 0
  local ext_tire = 0
  if nx_int(total_team_value) > nx_int(0) then
    tire = nx_int(nx_int(tfValue) * 100 / nx_int(total_team_value))
    ext_tire = nx_int(nx_int(ExttfValue) * 100 / nx_int(total_team_value))
  end
  local gui = nx_value("gui")
  local tips = nx_string("tips_tlrecord_old_main")
  local tips_text = gui.TextManager:GetFormatText(tips, nx_widestr(name), nx_widestr(tire), nx_widestr(pressSucceed), nx_widestr(pressFail), nx_widestr(halfwayQuit))
  if condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(29871)) then
    tips = nx_string("tips_tlrecord_main")
    tips_text = gui.TextManager:GetFormatText(tips, nx_widestr(name), nx_widestr(tire), nx_widestr(ext_tire), nx_widestr(pressSucceed), nx_widestr(pressFail), nx_widestr(halfwayQuit))
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), self.AbsLeft, self.AbsTop, 0, self)
end
function on_lbl_photo_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self)
end
function on_lbl_photo_right_click(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return false
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local row = nx_int(self.DataSource) - 1
  local name = view:QueryRecord("team_faculty_rec", row, 2)
  local pressSucceed = view:QueryRecord("team_faculty_rec", row, 4)
  local pressFail = view:QueryRecord("team_faculty_rec", row, 5)
  local halfwayQuit = view:QueryRecord("team_faculty_rec", row, 6)
  local tfValue = getCurrentTeamFacultyValue(form, row)
  local ExttfValue = getCurrentTeamExtFacultyValue(form, row)
  local total_team_value = getTotal_team_value()
  local tire = 0
  local ext_tire = 0
  if nx_int(total_team_value) > nx_int(0) then
    tire = nx_int(nx_int(tfValue) * 100 / nx_int(total_team_value))
    ext_tire = nx_int(nx_int(ExttfValue) * 100 / nx_int(total_team_value))
  end
  local gui = nx_value("gui")
  if form.rclick == true then
    form.rclick = false
    local tips = nx_string("tips_tlrecord_old_main")
    local tips_text = gui.TextManager:GetFormatText(tips, nx_widestr(name), nx_widestr(tire), nx_widestr(pressSucceed), nx_widestr(pressFail), nx_widestr(halfwayQuit))
    if condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(29871)) then
      tips = nx_string("tips_tlrecord_main")
      tips_text = gui.TextManager:GetFormatText(tips, nx_widestr(name), nx_widestr(tire), nx_widestr(ext_tire), nx_widestr(pressSucceed), nx_widestr(pressFail), nx_widestr(halfwayQuit))
    end
    nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), self.AbsLeft, self.AbsTop, 0, self)
  elseif form.rclick == false then
    form.rclick = true
    local tips = nx_string("tips_tlrecord_new_detailed")
    if condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(29871)) then
      tips = nx_string("tips_tlrecord_detailed")
    end
    local tips_text = gui.TextManager:GetFormatText(tips)
    nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), self.AbsLeft, self.AbsTop, 0, self)
  end
end
function on_btn_fire_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("TeamFacultyState")
  if nx_int(state) == nx_int(1) then
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
    if not nx_is_valid(view) then
      return
    end
    local row = nx_int(self.DataSource) - 1
    local player_name = view:QueryRecord("team_faculty_rec", row, 2)
    local leader = view:QueryProp("LeaderName")
    local curstate = view:QueryProp("CurState")
    if nx_ws_equal(nx_widestr(leader), nx_widestr(player_name)) == false and nx_int(curstate) == nx_int(1) then
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      if not nx_is_valid(dialog) then
        return
      end
      local gui = nx_value("gui")
      local text = gui.TextManager:GetFormatText("ui_teamfaculty_kick_player", nx_string(player_name))
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" then
        nx_execute("custom_sender", "custom_team_faculty", SUB_CLIENT_KICK_PLAYER, nx_widestr(player_name))
      end
    end
  end
end
function show_player_info(form, row)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local name = view:QueryRecord("team_faculty_rec", row, 2)
  local score = view:QueryRecord("team_faculty_rec", row, 3)
  local tfValue = getCurrentTeamFacultyValue(form, row)
  local group = form:Find("group_player_" .. nx_string(row + 1))
  if not nx_is_valid(group) then
    return
  end
  group.Visible = true
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local control = group:Find("lbl_name_" .. nx_string(row + 1))
  if nx_is_valid(control) then
    control.Text = nx_widestr(name)
    if nx_string(player_name) == nx_string(name) then
      control.ForeColor = "255,255,255,0"
    else
      control.ForeColor = "255,255,255,255"
    end
  end
  local leader = view:QueryProp("LeaderName")
  local control_leader = group:Find("lbl_leader_" .. nx_string(row + 1))
  if nx_is_valid(control_leader) then
    if leader == name then
      control_leader.Visible = true
    else
      control_leader.Visible = false
    end
  end
  local control = group:Find("lbl_score_" .. nx_string(row + 1))
  if nx_is_valid(control) then
    control.Text = nx_widestr(score)
  end
  local ready_name = view:QueryProp("ReadyName")
  local play_name = view:QueryProp("PlayName")
  local lbl_ready = group:Find("lbl_ready_" .. nx_string(row + 1))
  local lbl_play = group:Find("lbl_play_" .. nx_string(row + 1))
  if nx_is_valid(lbl_ready) and nx_is_valid(lbl_play) then
    if name == play_name then
      lbl_ready.Visible = false
      lbl_play.Visible = true
    elseif name == ready_name then
      lbl_ready.Visible = true
      lbl_play.Visible = false
    else
      lbl_ready.Visible = false
      lbl_play.Visible = false
    end
  end
end
function save_head_info(form)
  if not nx_is_valid(form) then
    return
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  form.showhead_hp = game_config_info.showhead_hp
  form.showhead_info = game_config_info.showhead_info
  form.showself_qg = game_config_info.showself_qg
end
function hide_head_info(form)
  if not nx_is_valid(form) then
    return
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  game_config_info.showhead_hp = 0
  game_config_info.showhead_info = 0
  game_config_info.showself_qg = 0
  refresh_obj_head()
end
function show_head_info(form)
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  game_config_info.showhead_hp = form.showhead_hp
  game_config_info.showhead_info = form.showhead_info
  game_config_info.showself_qg = form.showself_qg
  refresh_obj_head()
end
function refresh_obj_head()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  head_game:RefreshHeadConfig()
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      head_game:RefreshAll(visual_obj)
    end
  end
end
function change_form_size()
  local form = util_get_form("form_stage_main\\form_wuxue\\form_team_faculty_member", false, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
end
function begin_show_time(form, time)
  if not nx_is_valid(form) then
    return
  end
  if time <= 0 or time == nil then
    return
  end
  form.lbl_time.Text = nx_widestr(time) .. nx_widestr(util_text("ui_second"))
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "count_down_time", form)
  timer:Register(1000, -1, nx_current(), "count_down_time", form, -1, -1)
end
function count_down_time(form)
  if not nx_is_valid(form) then
    return
  end
  local update_time = nx_int(form.lbl_time.Text) - 1
  if nx_int(update_time) <= nx_int(0) then
    update_time = 0
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "count_down_time", form)
    end
  end
  form.lbl_time.Text = nx_widestr(update_time) .. nx_widestr(util_text("ui_second"))
end
function show_player_menu(player_name, player_ident)
  local form = util_get_form("form_stage_main\\form_wuxue\\form_team_faculty_member", false)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("TeamFacultyState")
  if nx_int(state) ~= nx_int(1) then
    form.btn_invite_faculty.Enabled = false
  else
    form.btn_invite_faculty.Enabled = true
  end
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return false
  end
  if nx_int(view:QueryProp("PlayType")) == nx_int(TEAM_FACULTY_TYPE_DONGFANG) then
    return
  end
  form.playname = player_name
  form.playident = player_ident
  form.lbl_player_name.Text = nx_widestr(player_name)
  form.groupbox_player_menu.Visible = true
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "hide_player_menu", form)
  timer:Register(3000, 1, nx_current(), "hide_player_menu", form, -1, -1)
end
function hide_player_menu(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_player_menu.Visible = false
end
function show_fix_place(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local place_list = client_player:QueryProp("CurPlaceList")
  if nx_int(place_list) > nx_int(0) and nx_int(place_list) <= nx_int(5) then
    form.lbl_fix_place.BackImage = "gui\\language\\ChineseS\\xiulian\\lbl_place_" .. nx_string(place_list) .. ".png"
  end
end
function hide_other_obj()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) and not nx_id_equal(visual_obj, visual_player) and nx_is_valid(client_obj) and client_obj:QueryProp("Type") == 2 and not is_teamfaculty_player(client_obj.Ident) then
      visual_obj.Visible = false
      game_visual.HidePlayer = true
    end
  end
end
function show_other_obj()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) and not nx_id_equal(visual_obj, visual_player) and nx_is_valid(client_obj) and client_obj:QueryProp("Type") == 2 then
      visual_obj.Visible = true
      game_visual.HidePlayer = false
    end
  end
end
function is_teamfaculty_player(ident)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return false
  end
  local row = view:FindRecordRow("team_faculty_rec", 1, nx_object(ident))
  if nx_int(row) < nx_int(0) then
    return false
  end
  return true
end
function getTotal_team_value()
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\faculty_team_action.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("setting"))
  if sec_index < 0 then
    return 0
  end
  local total_team_value = ini:ReadInteger(sec_index, "TeamValue", 0)
  return total_team_value
end
function getCurrentTeamFacultyValue(form, row)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local tfValue = view:QueryRecord("team_faculty_rec", row, 7)
  local total_team_value = getTotal_team_value()
  local tire = nx_int(total_team_value) - nx_int(tfValue)
  return tire
end
function getCurrentTeamExtFacultyValue(form, row)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local tfValue = view:QueryRecord("team_faculty_rec", row, 8)
  local total_team_value = getTotal_team_value()
  local tire = nx_int(total_team_value) - nx_int(tfValue)
  return tire
end
function set_btn_kick_visible(form, bshow)
  if not nx_is_valid(form) then
    return false
  end
  for i = 2, 10 do
    local group = form:Find("group_player_" .. nx_string(i))
    if not nx_is_valid(group) then
      return
    end
    local btn_fire = group:Find("btn_fire_" .. nx_string(i))
    if not nx_is_valid(btn_fire) then
      return
    end
    btn_fire.Visible = bshow
  end
end
function show_protect_state(form)
  if not nx_is_valid(form) then
    return false
  end
  form.lbl_protect.Visible = false
  form.lbl_wudi.Visible = false
  form.lbl_noprotect.Visible = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local place_list = client_player:QueryProp("CurPlaceList")
  if nx_int(place_list) <= nx_int(0) or nx_int(place_list) > nx_int(5) then
    form.lbl_noprotect.Visible = true
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local row_count = view:GetRecordRows("team_faculty_rec")
  if nx_int(row_count) < nx_int(8) then
    form.lbl_protect.Visible = true
  else
    form.lbl_wudi.Visible = true
  end
end
function show_chat_info(name, info)
  local form = nx_value(FORM_FACULTY_TEAM)
  if not nx_is_valid(form) then
    return
  end
  if nx_function("ext_ws_find", nx_widestr(info), nx_widestr("teamfaculty,")) >= 0 then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  for i = 1, MAX_SINGLE_TEAM_MEMBER do
    local groupbox = form:Find("group_player_" .. i)
    if nx_is_valid(groupbox) and groupbox.Visible then
      local lblname = groupbox:Find("lbl_name_" .. i)
      if nx_is_valid(lblname) and nx_string(lblname.Text) == nx_string(name) then
        local mltbox = form:Find("MultiTextBox_" .. i)
        if nx_is_valid(mltbox) then
          set_chat_text(groupbox, mltbox, info)
        end
      end
    end
  end
end
function set_chat_text(groupbox, mltbox, info)
  mltbox.Width = 300
  mltbox.Height = 100
  mltbox.ViewRect = "10,10,290,90"
  mltbox.BackColor = "100,0,0,0"
  mltbox.NoFrame = true
  mltbox.Solid = true
  mltbox.BackImage = chat_backimg
  mltbox.Font = "HEIT12"
  mltbox.TextColor = "255,0,0,0"
  mltbox.LineHeight = 1
  mltbox.HtmlText = nx_widestr(info)
  mltbox.Height = 20 + mltbox:GetContentHeight()
  mltbox.Width = 20 + mltbox:GetContentWidth()
  mltbox.ViewRect = "10,10," .. mltbox.Width .. "," .. mltbox.Height
  mltbox.HtmlText = nx_widestr(info)
  mltbox.Visible = true
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_callback", mltbox)
    timer:Register(5000, 1, nx_current(), "timer_callback", mltbox, -1, -1)
  end
end
function timer_callback(mltbox, param1, param2)
  mltbox.Visible = false
end
function jiugong_interface_info(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local leader = view:QueryProp("LeaderName")
  local type = view:QueryProp("PlayType")
  if nx_int(type) == nx_int(TEAM_FACULTY_TYPE_JIUGONG) then
    form.lbl_5.Visible = false
    form.lbl_4.Visible = false
    form.lbl_7.Visible = false
    form.lbl_offset_faculty.Visible = false
    form.lbl_team_faculty.Visible = false
    form.lbl_faculty.Visible = false
    form.btn_begin.NormalImage = nx_string("gui\\language\\ChineseS\\xiulian\\taohua_start_out.png")
    form.btn_begin.FocusImage = nx_string("gui\\language\\ChineseS\\xiulian\\taohua_start_on.png")
    form.btn_begin.PushImage = nx_string("gui\\language\\ChineseS\\xiulian\\taohua_start_down.png")
    if leader == player_name then
      form.groupbox_staff.Visible = false
      form.groupbox_taohua_header.Visible = true
    else
      form.groupbox_staff.Visible = true
      form.groupbox_taohua_header.Visible = false
    end
  else
    form.groupbox_staff.Visible = false
    form.groupbox_taohua_header.Visible = false
  end
end
function on_btn_ext_faculty_click()
  local form = util_auto_show_hide_form("form_stage_main\\form_wuxue\\form_ext_faculty")
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == true then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
