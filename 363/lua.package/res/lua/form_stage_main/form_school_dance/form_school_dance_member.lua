require("util_gui")
require("util_functions")
require("share\\view_define")
require("define\\request_type")
require("define\\object_type_define")
local FORM_FACULTY_TEAM = "form_stage_main\\form_school_dance\\form_school_dance_member"
local SUB_CLIENT_PLAY_SUCCESS = 1
local SUB_CLIENT_PLAY_FAILED = 2
local SUB_CLIENT_EXIT_DANCE = 10
local SUB_SERVER_DANCE_WAIT = 1
local SUB_SERVER_DANCE_READY = 2
local SUB_SERVER_DANCE_OVER = 3
local SUB_SERVER_PLAYER_OPEN = 10
local SUB_SERVER_PLAYER_SUCCESS = 11
local SUB_SERVER_PLAYER_FAILED = 12
function main_form_init(self)
  self.Fixed = true
  self.showhead_hp = 1
  self.showhead_info = 1
  self.showself_qg = 1
  self.playname = ""
  self.playident = ""
end
function on_main_form_open(self)
  change_form_size()
  util_show_form("form_stage_main\\form_relationship", false)
  local form_game = util_get_form("form_stage_main\\puzzle_quest\\form_puzzle_quest", false)
  if nx_is_valid(form_game) then
    nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "show_world_alpha_out")
    form_game:Close()
  end
  nx_execute("form_stage_main\\form_main\\form_main", "move_over")
  nx_execute("gui", "gui_close_allsystem_form", 2)
  self.Visible = true
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
  form_back.name = FORM_FACULTY_TEAM
  form_back.lbl_back.BlendColor = "100,255,255,255"
  util_show_form("form_stage_main\\form_wuxue\\form_faculty_back", true)
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) then
    form_main.groupbox_4.Visible = false
    form_main.groupbox_5.Visible = false
  end
  save_head_info(self)
  self.groupbox_score.Visible = false
  nx_execute("form_stage_main\\form_main\\form_main_trumpet", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_marry", "change_form_size")
  show_other_obj()
  self.btn_hide.Visible = true
  self.btn_show.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_SCHOOL_DANCE, self, nx_current(), "on_teamfaculty_viewport_change")
    databinder:AddRolePropertyBind("SchoolDanceTotalScore", "int", self, nx_current(), "on_scorce_change")
    databinder:AddRolePropertyBind("SchoolDanceDayScore", "int", self, nx_current(), "on_scorce_change")
    databinder:AddRolePropertyBind("Faculty", "int", self, nx_current(), "on_Faculty_change")
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
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("SchoolDanceTotalScore", self)
    databinder:DelRolePropertyBind("SchoolDanceDayScore", self)
    databinder:DelRolePropertyBind("Faculty", self)
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "count_down_time", self)
    timer:UnRegister(nx_current(), "hide_player_menu", self)
    timer:UnRegister(nx_current(), "on_refresh_all_info", self)
  end
  nx_execute("gui", "gui_open_closedsystem_form")
  show_head_info(self)
  local form_chat = util_get_form("form_stage_main\\form_main\\form_main_chat", false)
  if nx_is_valid(form_chat) then
    form_chat.Top = -681
  end
  local form_sysinfo = util_get_form("form_stage_main\\form_main\\form_main_sysinfo", false)
  if nx_is_valid(form_sysinfo) then
    form_sysinfo.Top = -407
  end
  nx_execute("form_stage_main\\form_main\\form_main_team", "update_team_panel")
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) and nx_is_valid(form_main.groupbox_4) and nx_is_valid(form_main.groupbox_5) then
    form_main.groupbox_4.Visible = true
    form_main.groupbox_5.Visible = true
  end
  util_show_form("form_stage_main\\form_wuxue\\form_faculty_back", false)
  nx_execute("form_stage_main\\form_main\\form_main_trumpet", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_marry", "change_form_size")
end
function on_scorce_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local totalscore = client_player:QueryProp("SchoolDanceTotalScore")
  local dayscorce = client_player:QueryProp("SchoolDanceDayScore")
  local total_max = get_inisec("TotalScore")
  local day_max = get_inisec("DayScore")
  form.pbar_point.Maximum = nx_int(total_max)
  form.pbar_point.Value = nx_int(totalscore)
  form.pbar_get_point.Maximum = nx_int(day_max)
  form.pbar_get_point.Value = nx_int(dayscorce)
end
function on_Faculty_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_faculty = client_player:QueryProp("Faculty")
  form.lbl_faculty.Text = nx_widestr(cur_faculty)
end
function on_teamfaculty_viewport_change(form, optype, view_ident, index)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(500, 1, nx_current(), "on_refresh_all_info", form, -1, -1)
end
function on_btn_quit_click(self)
  nx_execute("form_stage_main\\form_school_dance\\form_school_dance", "hide_form")
end
function on_btn_faculty_click(self)
  util_auto_show_hide_form("form_stage_main\\form_wuxue\\form_wuxue_faculty")
end
function on_btn_help_click(self)
  local form_school = util_get_form("form_stage_main\\form_tvt\\form_tvt_main", true)
  if form_school.Visible == false then
    util_show_form("form_stage_main\\form_tvt\\form_tvt_main", true)
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "show_type_info", 39)
  else
    form_school:Close()
  end
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
  local form = util_get_form(FORM_FACULTY_TEAM, false, false)
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
  local form = util_get_form(FORM_FACULTY_TEAM, false)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
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
function get_inisec(prop)
  local ini = nx_execute("util_functions", "get_ini", "share\\InterActive\\SchoolDacne\\school_dance_main.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("DanceInfo"))
  if sec_index < 0 then
    return ""
  end
  local value = ini:ReadString(sec_index, prop, "")
  return value
end
function on_refresh_all_info(form)
  local totalturn = get_inisec("TotalTurn")
  local totalscore = get_inisec("TotalScore")
  local dayscore = get_inisec("DayScore")
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SCHOOL_DANCE))
  if not nx_is_valid(view) then
    return 0
  end
  local cur_turn = nx_int(view:QueryProp("CurTurn")) + nx_int(1)
  form.lbl_turn.Text = nx_widestr(cur_turn) .. nx_widestr("/") .. nx_widestr(totalturn)
  local cur_stete = view:QueryProp("CurState")
  if nx_int(cur_stete) == nx_int(1) then
    form.lbl_wait.Visible = true
  else
    form.lbl_wait.Visible = false
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
    if nx_is_valid(visual_obj) and not nx_id_equal(visual_obj, visual_player) and nx_is_valid(client_obj) and client_obj:QueryProp("Type") == 2 then
      visual_obj.Visible = false
    end
  end
  game_visual.HidePlayer = true
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
    end
  end
  game_visual.HidePlayer = false
end
