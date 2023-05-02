require("util_gui")
require("util_vip")
require("util_functions")
require("util_static_data")
require("share\\view_define")
require("player_state\\state_input")
local SUB_CLIENT_NORMAL_BEGIN = 11
local SUB_CLIENT_NORMAL_EXIT = 12
local SUB_CLIENT_UPDATE_ACT = 24
local SUB_SERVER_ACT_BEGIN = 21
local FACULTY_STATE_NO = 0
local FACULTY_STATE_READY = 1
local FACULTY_STATE_CONVERT = 2
local FACULTY_STYLE_NOR = 1
local FACULTY_STYLE_ACT = 2
local WUXUE_NEIGONG = 1
local WUXUE_SKILL = 2
local WUXUE_QGSKILL = 3
local WUXUE_ZHENFA = 4
local WUXUE_ANQI = 5
local WUXUE_JINGMAI = 6
local WUXUE_MAX = 7
local WUXUE_VIEW = {
  [WUXUE_NEIGONG] = VIEWPORT_NEIGONG,
  [WUXUE_SKILL] = VIEWPORT_SKILL,
  [WUXUE_QGSKILL] = VIEWPORT_QINGGONG,
  [WUXUE_ZHENFA] = VIEWPORT_ZHENFA,
  [WUXUE_ANQI] = VIEWPORT_SHOUFA,
  [WUXUE_JINGMAI] = VIEWPORT_JINGMAI
}
local STATE_NULL = 0
local STATE_ONE = 1
local STATE_TWO = 2
local STATE_THREE = 3
local STATE_FOUR = 4
local STATE_FIVE = 5
local STATE_SIX = 6
local FACULTY_ONE = 300000
local FACULTY_TWO = 1000000
local FACULTY_THREE = 3000000
local FACULTY_FOUR = 5000000
local FACULTY_FIVE = 7500000
local FACULTY_SIX = 10000000
local EXCAHNGE_ONE = 30000
local EXCAHNGE_TWO = 100000
local EXCAHNGE_THREE = 300000
local EXCAHNGE_FOUR = 500000
local EXCAHNGE_FIVE = 750000
local EXCAHNGE_SIX = 1000000
function main_form_init(self)
  self.Fixed = false
  self.wuxue_name = ""
end
function change_form_size()
  local gui = nx_value("gui")
  local form = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_faculty", false)
  if nx_is_valid(form) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function on_main_form_open(form)
  ui_show_attached_form(form)
  change_form_size(form)
  form.lbl_neixiu.Visible = false
  form.lbl_act.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("FacultyName", "int", form, nx_current(), "on_Faculty_wuxue_change")
    databinder:AddRolePropertyBind("Faculty", "int", form, nx_current(), "on_Faculty_change")
    databinder:AddRolePropertyBind("FacultyState", "int", form, nx_current(), "prop_callback_ConvertState")
    databinder:AddRolePropertyBind("FacultyStyle", "int", form, nx_current(), "prop_callback_ConvertState")
    databinder:AddRolePropertyBind("TotalFillValue", "int", form, nx_current(), "on_FillValue_change")
    databinder:AddRolePropertyBind("CurFillValue", "int", form, nx_current(), "on_FillValue_change")
    databinder:AddRolePropertyBind("CurLevel", "int", form, nx_current(), "on_cur_level_change")
    databinder:AddRolePropertyBind("FillSpeed", "int", form, nx_current(), "on_FillSpeed_change")
    databinder:AddRolePropertyBind("TeamFacultyValue", "int", form, nx_current(), "on_TeamFacultyValue_change")
    databinder:AddRolePropertyBind("ExtTeamFacultyValue", "int", form, nx_current(), "on_ExtTeamFacultyValue_change")
    databinder:AddRolePropertyBind("ActDayValue", "int", form, nx_current(), "on_ActDayValue_change")
    databinder:AddTableBind("vip_info_rec", form, nx_current(), "on_vip_info_rec_change")
  end
  refresh_time(form)
  set_exchange_show(form)
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(29871)) then
    form.lbl_ext_9.Visible = false
    form.lbl_team_ext_faculty.Visible = false
    form.lbl_9.Top = 30
    form.lbl_team_faculty.Top = 30
  end
  nx_execute("custom_sender", "custom_send_faculty_msg", SUB_CLIENT_UPDATE_ACT)
end
function on_vip_info_rec_change(self, recordname, optype, row, clomn)
  if clomn == VIR_STATUS then
    on_VipStatus_change(self)
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "show_display", self)
  end
  ui_destroy_attached_form(self)
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("FacultyName", self)
  databinder:DelRolePropertyBind("Faculty", self)
  databinder:DelRolePropertyBind("FacultyState", self)
  databinder:DelRolePropertyBind("FacultyStyle", self)
  databinder:DelRolePropertyBind("TotalFillValue", self)
  databinder:DelRolePropertyBind("CurFillValue", self)
  databinder:DelRolePropertyBind("CurLevel", self)
  databinder:DelRolePropertyBind("VipStatus", self)
  databinder:DelRolePropertyBind("FillSpeed", self)
  databinder:DelRolePropertyBind("TeamFacultyValue", self)
  databinder:DelRolePropertyBind("ExtTeamFacultyValue", self)
  databinder:DelRolePropertyBind("ActDayValue", self)
  databinder:DelViewBind(self)
  nx_destroy(self)
  return
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_begin_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  nx_execute("custom_sender", "custom_send_faculty_msg", SUB_CLIENT_NORMAL_BEGIN)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_stop_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cue_state = client_player:QueryProp("FacultyState")
  if nx_int(cue_state) ~= nx_int(FACULTY_STATE_CONVERT) then
    return
  end
  nx_execute("custom_sender", "custom_send_faculty_msg", SUB_CLIENT_NORMAL_EXIT, 0)
end
function on_btn_act_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_send_faculty_msg", SUB_SERVER_ACT_BEGIN)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_team_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  util_show_form("form_stage_main\\form_wuxue\\form_team_faculty_setting", true)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  form:Close()
end
function on_btn_live_click(self)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
  local form = util_get_form("form_stage_main\\form_wuxue\\form_wuxue", false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue", "on_btn_faculty_info_click", form.btn_faculty_info)
  return true
end
function on_btn_quit_click(self)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_photo_click(self)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_offline_faculty_click(self)
  util_auto_show_hide_form("form_stage_main\\form_vip_info")
end
function on_btn_offline_on_get_capture(self)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local time = get_vip_time(player, VT_NORMAL)
  local str = nx_execute("form_stage_main\\form_vip_info", "format_time", get_vip_time(player, VT_NORMAL))
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_offline_faculty_on")) .. str, self.AbsLeft, self.AbsTop, 0, self)
end
function on_btn_offline_on_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self)
end
function on_Faculty_wuxue_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuxue_name = client_player:QueryProp("FacultyName")
  form.wuxue_name = nx_string(wuxue_name)
  set_control_state(form)
  form.lbl_wuxue_name.Text = nx_widestr(util_text(wuxue_name))
  local photo = get_cur_wuxue_static_data(form, "Photo")
  form.imagegrid_wuxue:AddItem(0, nx_string(photo), 0, 1, -1)
  local wuxue_obj = get_cur_wuxue_id(form)
  if not nx_is_valid(wuxue_obj) then
    return
  end
  local property = wuxue_obj:QueryProp("WuXing")
  if nx_int(property) <= nx_int(0) or nx_int(property) > nx_int(7) then
    form.lbl_property.Text = nx_widestr(util_text("ui_train_elemt"))
    return
  end
  local type_str = "ui_wuxue_prop_" .. nx_string(property)
  form.lbl_property.Text = nx_widestr(util_text(type_str))
end
function prop_callback_ConvertState(form)
  if not nx_is_valid(form) then
    return 1
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_state = client_player:QueryProp("FacultyState")
  local cur_style = client_player:QueryProp("FacultyStyle")
  if cur_state == nil or nx_int(cur_state) == nx_int(FACULTY_STATE_NO) then
    form.btn_start.Visible = true
    form.btn_stop.Visible = false
    form.lbl_neixiu.Visible = false
    form.lbl_act.Visible = false
  elseif nx_int(cur_state) == nx_int(FACULTY_STATE_CONVERT) then
    if nx_int(cur_style) == nx_int(FACULTY_STYLE_NOR) then
      form.lbl_neixiu.Visible = true
      form.lbl_act.Visible = false
      form.btn_start.Visible = false
      form.btn_stop.Visible = true
    elseif nx_int(cur_style) == nx_int(FACULTY_STYLE_ACT) then
      form.btn_start.Visible = true
      form.btn_stop.Visible = false
      form.lbl_neixiu.Visible = false
      form.lbl_act.Visible = true
    end
  end
  refresh_time(form)
  return 1
end
function on_cur_level_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_level = client_player:QueryProp("CurLevel")
  form.lbl_level.Text = nx_widestr(gui.TextManager:GetText("ui_wuxue_level_" .. nx_string(cur_level)))
  if nx_int(cur_level) <= nx_int(0) then
    form.lbl_level.Text = nx_widestr(util_text("ui_train_level"))
  end
end
function on_FillValue_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local level_faculty = client_player:QueryProp("TotalFillValue")
  local cur_fillvalue = client_player:QueryProp("CurFillValue")
  if level_faculty < cur_fillvalue then
    cur_fillvalue = level_faculty
  end
  form.pbar_fill.Maximum = level_faculty
  form.pbar_fill.Value = cur_fillvalue
  form.lbl_progress.Text = nx_widestr(nx_string(cur_fillvalue) .. "/" .. nx_string(level_faculty))
  refresh_time(form)
end
function on_Faculty_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_faculty = client_player:QueryProp("Faculty")
  form.lbl_faculty.Text = nx_widestr(cur_faculty)
end
function on_VipStatus_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local vip_status = client_player:QueryProp("VipStatus")
  if nx_int(vip_status) == nx_int(1) then
    form.btn_offline_on.Visible = true
    form.btn_offline_off.Visible = false
  else
    form.btn_offline_on.Visible = false
    form.btn_offline_off.Visible = true
  end
end
function on_FillSpeed_change(form)
  if not nx_is_valid(form) then
    return false
  end
  refresh_time(form)
end
function on_btn_faculty_exchange_click(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_wuxue\\form_exchange_confirm", true, false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_wuxue\\form_faculty_exchange", true)
  end
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
    form.lbl_team_faculty.Text = nx_widestr("100%")
    return
  end
  local cur_team_value = client_player:QueryProp("ExtTeamFacultyValue")
  local tire = nx_int((total_team_value - cur_team_value) * 100 / total_team_value)
  form.lbl_team_ext_faculty.Text = nx_widestr(nx_string(tire) .. "%")
end
function on_ActDayValue_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local day_value = client_player:QueryProp("ActDayValue")
  local cost_value = client_player:QueryProp("ActCostSuiYin")
  local remain_value = day_value - cost_value
  if nx_int(remain_value) < nx_int(0) then
    remain_value = 0
  end
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_train_team_table_11", nx_int(remain_value / 1000)))
  form.lbl_suiyin.Text = nx_widestr(text)
end
function get_cur_wuxue_id(form)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local faculty_query = nx_value("faculty_query")
  local wuxue_type = faculty_query:GetType(form.wuxue_name)
  if nx_int(wuxue_type) <= nx_int(0) or nx_int(wuxue_type) >= nx_int(WUXUE_MAX) or nx_string(form.wuxue_name) == nx_string("") then
    return nx_null()
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(WUXUE_VIEW[wuxue_type]))
  if not nx_is_valid(view) then
    return nx_null()
  end
  local count = view:GetViewObjCount()
  for i = 1, count do
    local wuxue_id = view:GetViewObjByIndex(i - 1)
    local temp_name = wuxue_id:QueryProp("ConfigID")
    if nx_string(temp_name) == nx_string(form.wuxue_name) then
      return wuxue_id
    end
  end
  return nx_null()
end
function get_cur_wuxue_static_data(form, prop_name)
  if not nx_is_valid(form) then
    return
  end
  if prop_name == nil or nx_string(prop_name) == nx_string("") then
    return
  end
  local wuxue_id = get_cur_wuxue_id(form)
  if not nx_is_valid(wuxue_id) then
    return
  end
  local Data_Type
  local faculty_query = nx_value("faculty_query")
  local wuxue_type = faculty_query:GetType(form.wuxue_name)
  if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
    Data_Type = STATIC_DATA_SKILL_STATIC
  elseif nx_int(wuxue_type) == nx_int(WUXUE_NEIGONG) then
    Data_Type = STATIC_DATA_NEIGONG
  elseif nx_int(wuxue_type) == nx_int(WUXUE_QGSKILL) then
    Data_Type = STATIC_DATA_QGSKILL
  elseif nx_int(wuxue_type) == nx_int(WUXUE_ZHENFA) then
    Data_Type = STATIC_DATA_ZHENFA
  elseif nx_int(wuxue_type) == nx_int(WUXUE_JINGMAI) then
    Data_Type = STATIC_DATA_JINGMAI
  elseif nx_int(wuxue_type) == nx_int(WUXUE_ANQI) then
    Data_Type = STATIC_DATA_SHOUFA
  end
  if Data_Type == nil then
    return
  end
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local staticdata = wuxue_id:QueryProp("StaticData")
  local prop = data_query:Query(nx_int(Data_Type), nx_int(staticdata), prop_name)
  return prop
end
function refresh_time(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local level_faculty = client_player:QueryProp("TotalFillValue")
  local cur_fillvalue = client_player:QueryProp("CurFillValue")
  local leave_faculty = level_faculty - cur_fillvalue
  if nx_int(leave_faculty) < nx_int(0) then
    leave_faculty = 0
  end
  local speed = client_player:QueryProp("FillSpeed")
  if nx_int(speed) <= nx_int(0) then
    form.lbl_time.Text = nx_widestr(util_text("ui_faculty_stop"))
    form.lbl_time.ForeColor = "255,153,0,0"
    form.imagegrid_wuxue:ChangeItemImageToBW(0, true)
    return false
  end
  local time = math.ceil(leave_faculty / speed)
  local day = nx_int(time / 1440)
  local hour = nx_int(math.mod(time, 1440) / 60)
  local min = nx_int(math.mod(math.mod(time, 1440), 60))
  local cur_state = client_player:QueryProp("FacultyState")
  local cur_style = client_player:QueryProp("FacultyStyle")
  if nx_int(cur_state) == nx_int(FACULTY_STATE_CONVERT) and nx_int(cur_style) == nx_int(FACULTY_STYLE_NOR) then
    form.lbl_time.Text = nx_widestr(day) .. nx_widestr(util_text("ui_day")) .. nx_widestr(hour) .. nx_widestr(util_text("ui_hourx")) .. nx_widestr(min) .. nx_widestr(util_text("ui_min"))
    form.lbl_time.ForeColor = "255,121,97,70"
    form.imagegrid_wuxue:ChangeItemImageToBW(0, false)
  else
    form.lbl_time.Text = nx_widestr(util_text("ui_faculty_stop"))
    form.lbl_time.ForeColor = "255,153,0,0"
    form.imagegrid_wuxue:ChangeItemImageToBW(0, true)
  end
  return true
end
function set_control_state(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuxue_name = client_player:QueryProp("FacultyName")
  form.btn_start.Enabled = false
  form.btn_stop.Enabled = false
  form.btn_act.Enabled = false
  form.groupbox_suiyin.Visible = false
  form.groupbox_faculty.Visible = true
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  if condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(23607)) then
    form.btn_team.Enabled = true
    form.groupbox_team_faculty.Visible = true
    form.btn_team.HintText = nx_widestr(util_text("ui_train_title_3_tips"))
  else
    form.btn_team.Enabled = false
    form.groupbox_team_faculty.Visible = false
    form.btn_team.HintText = nx_widestr(util_text("ui_faculty_function_off"))
  end
  if condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(23614)) then
    form.btn_start.HintText = nx_widestr(util_text("ui_train_title_1_tips"))
    form.btn_stop.HintText = nx_widestr(util_text("ui_train_title_1_tips"))
  else
    form.btn_start.HintText = nx_widestr(util_text("ui_faculty_function_off"))
    form.btn_stop.HintText = nx_widestr(util_text("ui_faculty_function_off"))
  end
  if condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(23613)) then
    form.btn_act.HintText = nx_widestr(util_text("ui_train_title_2_tips"))
  else
    form.btn_act.HintText = nx_widestr(util_text("ui_faculty_function_off"))
  end
  if wuxue_name == nil or nx_string(wuxue_name) == nx_string("") then
    return
  end
  local wuxue_id = get_cur_wuxue_id(form)
  if not nx_is_valid(wuxue_id) then
    return
  end
  local curLevel = wuxue_id:QueryProp("Level")
  local maxLevel = wuxue_id:QueryProp("MaxLevel")
  if nx_int(curLevel) >= nx_int(maxLevel) then
    return
  end
  if condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(23614)) then
    form.btn_start.Enabled = true
    form.btn_stop.Enabled = true
    form.groupbox_faculty.Visible = false
  end
  if condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(23613)) then
    form.btn_act.Enabled = true
    form.groupbox_suiyin.Visible = true
  end
end
function on_btn_lilian_help_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_msg_level_up(is_max_level)
  if is_max_level == nil then
    is_max_level = nx_int(0)
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "wuxue_lvlup")
  local text = nx_widestr(util_text("ui_normal_faculty_level_up"))
  dialog.ok_btn.Text = gui.TextManager:GetText(nx_string("ui_continue_faculty"))
  dialog.cancel_btn.Text = gui.TextManager:GetText(nx_string("ui_reset_faculty"))
  local text = ""
  local wuxue_name = client_player:QueryProp("FacultyName")
  if nx_string(wuxue_name) == "" or nx_string(wuxue_name) == nil or nx_int(is_max_level) == nx_int(1) then
    dialog.ok_btn.Enabled = false
    text = nx_widestr(util_text("ui_normal_faculty_max_level"))
  else
    local wuxue_level = client_player:QueryProp("CurLevel")
    text = gui.TextManager:GetFormatText(nx_string("ui_normal_faculty_level_up"), nx_string(wuxue_name), nx_int(wuxue_level))
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:Show()
  local form_load = nx_value("form_common\\form_loading")
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(dialog)
  else
    gui.Desktop:ToFront(dialog)
  end
  dialog.AbsLeft = (gui.Width - dialog.Width) / 10 * 9
  dialog.AbsTop = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "wuxue_lvlup_confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_faculty_msg", SUB_CLIENT_NORMAL_BEGIN)
  elseif res == "cancel" then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
  end
end
function set_exchange_show(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_faculty_exchange.Visible = false
  local faculty_state = STATE_NULL
  local max_faculty = client_player:QueryProp("CurMaxFaculty")
  local cur_faculty = client_player:QueryProp("Faculty")
  if nx_int(max_faculty) >= nx_int(FACULTY_ONE) and nx_int(max_faculty) < nx_int(FACULTY_TWO) then
    faculty_state = STATE_ONE
  elseif nx_int(max_faculty) >= nx_int(FACULTY_TWO) and nx_int(max_faculty) < nx_int(FACULTY_THREE) then
    faculty_state = STATE_TWO
  elseif nx_int(max_faculty) >= nx_int(FACULTY_THREE) and nx_int(max_faculty) < nx_int(FACULTY_FOUR) then
    faculty_state = STATE_THREE
  elseif nx_int(max_faculty) >= nx_int(FACULTY_FOUR) and nx_int(max_faculty) < nx_int(FACULTY_FIVE) then
    faculty_state = STATE_FOUR
  elseif nx_int(max_faculty) >= nx_int(FACULTY_FIVE) and nx_int(max_faculty) < nx_int(FACULTY_SIX) then
    faculty_state = STATE_FIVE
  elseif nx_int(max_faculty) >= nx_int(FACULTY_SIX) then
    faculty_state = STATE_SIX
  end
  if nx_int(faculty_state) == nx_int(STATE_ONE) and nx_int(cur_faculty) > nx_int(EXCAHNGE_ONE) then
    form.btn_faculty_exchange.Visible = false
  elseif nx_int(faculty_state) == nx_int(STATE_TWO) and nx_int(cur_faculty) > nx_int(EXCAHNGE_TWO) then
    form.btn_faculty_exchange.Visible = false
  elseif nx_int(faculty_state) == nx_int(STATE_THREE) and nx_int(cur_faculty) > nx_int(EXCAHNGE_THREE) then
    form.btn_faculty_exchange.Visible = false
  elseif nx_int(faculty_state) == nx_int(STATE_FOUR) and nx_int(cur_faculty) > nx_int(EXCAHNGE_FOUR) then
    form.btn_faculty_exchange.Visible = false
  elseif nx_int(faculty_state) == nx_int(STATE_FIVE) and nx_int(cur_faculty) > nx_int(EXCAHNGE_FIVE) then
    form.btn_faculty_exchange.Visible = false
  elseif nx_int(faculty_state) == nx_int(STATE_SIX) and nx_int(cur_faculty) > nx_int(EXCAHNGE_SIX) then
    form.btn_faculty_exchange.Visible = false
  elseif nx_int(faculty_state) == nx_int(STATE_NULL) then
    form.btn_faculty_exchange.Visible = false
  else
    form.btn_faculty_exchange.Visible = true
    form.lbl_faculty_exchange.Visible = true
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(7000, 1, nx_current(), "show_display", form, -1, -1)
    end
  end
end
function show_display(form)
  form.lbl_faculty_exchange.Visible = false
end
