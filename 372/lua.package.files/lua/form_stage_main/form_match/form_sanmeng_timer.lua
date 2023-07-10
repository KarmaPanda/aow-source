require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_match\\form_sanmeng_timer"
local ZQ_INTEGRAL = "ZhengqiIntegral"
local HQ_INTEGRAL = "HaoqiIntegral"
local YQ_INTEGRAL = "YiqiIntegral"
local ZQ_TIPS = "sys_smzb_042"
local HQ_TIPS = "sys_smzb_043"
local YQ_TIPS = "sys_smzb_044"
local DEFAULT_WAR_TIME = 45
function main_form_init(self)
  self.Fixed = false
  self.zq_old_score = 0
  self.hq_old_score = 0
  self.yq_old_score = 0
  self.zq_score = 0
  self.hq_score = 0
  self.yq_score = 0
  return 1
end
function on_main_form_open(self)
  local form_player = util_get_form("form_stage_main\\form_main\\form_main_player", true)
  if not nx_is_valid(form_player) then
    return
  end
  self.AbsLeft = form_player.Left
  self.AbsTop = form_player.lbl_frame.Height + form_player.lbl_frame.Top
  self.state = 0
  self.sur_time = 0
  self.entry_time = get_cur_time()
end
function on_main_form_close(self)
  local form_map = util_get_form("form_stage_main\\form_main\\form_main_map", true)
  if nx_is_valid(form_map) then
    form_map.btn_sanmeng.Visible = false
  end
  nx_execute("form_stage_main\\form_match\\form_sanmeng_score", "close_form")
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
  end
  nx_destroy(self)
end
function check_open_form()
  local loading_flag = nx_value("loading")
  if loading_flag then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(1000, -1, nx_current(), "on_open_timer", nx_value("game_client"), -1, -1)
    end
  else
    open_form()
  end
end
function on_open_timer(self)
  local loading_flag = nx_value("loading")
  if loading_flag then
    return
  end
  open_form()
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_open_timer", self)
  end
end
function open_form()
  util_auto_show_hide_form(FORM_NAME)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local cur_time = get_cur_time()
  local end_time = get_end_time()
  form.sur_time = end_time - cur_time
  refresh_sur_time(form)
  refresh_stage_desc(form)
  refresh_scene_prop(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "on_timer", form, -1, -1)
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_server_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return 0
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local strdate = nx_function("format_date_time", nx_double(cur_date_time))
  local table_date = util_split_string(strdate, ";")
  if table.getn(table_date) ~= 2 then
    return 0
  end
  local table_time = util_split_string(table_date[2], ":")
  if table.getn(table_time) ~= 3 then
    return 0
  end
  return nx_number(table_time[1]), nx_number(table_time[2]), nx_number(table_time[3])
end
function get_server_date()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return nil, nil, nil
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local strdate = nx_function("format_date_time", nx_double(cur_date_time))
  local table_date = util_split_string(strdate, ";")
  if table.getn(table_date) ~= 2 then
    return nil, nil, nil
  end
  local len = string.len(nx_string(table_date[1]))
  if nx_number(len) ~= 11 then
    return nil, nil, nil
  end
  local text = table_date[1]
  local yy = nx_int(string.sub(nx_string(text), 1, 4))
  local mm = nx_int(string.sub(nx_string(text), 6, 7))
  local dd = nx_int(string.sub(nx_string(text), 9, 10))
  return yy, mm, dd
end
function get_cur_time()
  local hour, minute, second = get_server_time()
  local cur_time = nx_int(hour) * nx_int(3600) + nx_int(minute) * nx_int(60) + nx_int(second)
  return cur_time
end
function get_end_time()
  local game_client = nx_value("game_client")
  local scene = game_client:GetScene()
  if nx_string(scene) == nx_string("0-0") then
    return -1
  end
  if not scene:FindProp("StageEndTime") then
    return -1
  end
  local end_time = scene:QueryProp("StageEndTime")
  return end_time
end
function on_timer(form)
  if not nx_is_valid(form) then
    return
  end
  form.sur_time = form.sur_time - 1
  refresh_sur_time(form)
  refresh_stage_desc(form)
  refresh_scene_prop(form)
  local cur_time = get_cur_time()
  local end_time = get_end_time()
  local sur_time = end_time - cur_time
  form.sur_time = sur_time
  check_notice_reach_score(form)
  if nx_string(get_match_stage_desc()) == nx_string(0) then
    form:Close()
  end
end
function get_h_m_s(end_time)
  local h = nx_int(nx_number(end_time) / nx_number(3600))
  local m = nx_int(nx_number(end_time - h * 3600) / nx_number(60))
  local s = end_time - h * 3600 - m * 60
  return h, m, s
end
function refresh_sur_time(form)
  form.timerbox:Clear()
  local sur_time = form.sur_time
  if sur_time < 0 then
    return
  end
  if nx_string(get_match_stage_desc()) == nx_string("desc_smzb_001") and nx_int(sur_time) == nx_int(11) then
    create_animi()
  end
  local minute = nx_int(nx_number(sur_time) / nx_number(60))
  local second = nx_int(sur_time) - minute * 60
  local str_min = ""
  if minute >= nx_int(10) then
    str_min = nx_string(minute)
  else
    str_min = "0" .. nx_string(minute)
  end
  local str_sec = ""
  if nx_int(second) >= nx_int(10) then
    str_sec = nx_string(second)
  else
    str_sec = "0" .. nx_string(second)
  end
  local str = str_min .. ":" .. str_sec
  form.timerbox:AddHtmlText(nx_widestr(str), -1)
end
function create_animi()
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = "smzb_djs"
  gui.Desktop:Add(animation)
  animation.Left = (gui.Width - 240) / 2
  animation.Top = gui.Height / 4
  animation.AutoSize = true
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "animation_end")
  animation:Play()
end
function animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function refresh_scene_prop(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local scene = game_client:GetScene()
  if not nx_is_valid(scene) then
    return false
  end
  form.zq_old_score = form.zq_score
  form.hq_old_score = form.hq_score
  form.yq_old_score = form.yq_score
  form.zq_score = scene:QueryProp(ZQ_INTEGRAL)
  form.hq_score = scene:QueryProp(HQ_INTEGRAL)
  form.yq_score = scene:QueryProp(YQ_INTEGRAL)
  form.lbl_zq_num.Text = nx_widestr(form.zq_score)
  form.lbl_hq_num.Text = nx_widestr(form.hq_score)
  form.lbl_yq_num.Text = nx_widestr(form.yq_score)
end
function get_match_stage_desc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local scene = game_client:GetScene()
  if not nx_is_valid(scene) then
    return false
  end
  return scene:QueryProp("MatchStageDesc")
end
function refresh_stage_desc(form)
  local gui = nx_value("gui")
  form.lbl_desc.Text = nx_widestr(gui.TextManager:GetText(get_match_stage_desc()))
end
function get_war_time()
  local yy, mm, dd = get_server_date()
  if yy == nil or mm == nil or dd == nil then
    return DEFAULT_WAR_TIME
  end
  local week = nx_function("ext_get_day_of_week", yy, mm, dd)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_SanMeng.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string("MatchTimeInfo"))
    local var = ini:ReadString(sec_index, nx_string("week"), "")
    if var == nx_string("") then
      return DEFAULT_WAR_TIME
    end
    local var_list = util_split_string(var, "-")
    if table.getn(var_list) ~= 2 then
      return DEFAULT_WAR_TIME
    end
    return var_list[2]
  end
  return DEFAULT_WAR_TIME
end
function get_delay_check_guaji_time()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_SanMeng.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string("CheckGuaji"))
    return ini:ReadString(sec_index, nx_string("StartCheckTime"), "")
  end
end
function check_notice_guaji(form)
  if nx_find_custom(form, "is_noticed_guaji") and form.is_noticed_guaji == true then
    return
  end
  if not nx_find_custom(form, "entry_time") then
    return
  end
  local entry_sec = nx_int(get_cur_time()) - nx_int(form.entry_time)
  local notice_sec = nx_int(get_delay_check_guaji_time())
  if nx_number(entry_sec) >= nx_number(notice_sec) then
    notice_guaji_check_start()
    form.is_noticed_guaji = true
  end
end
function notice_guaji_check_start()
  local ST_FUNCTION_MATCH_SANMENG_GUAJI_CHECK = 816
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MATCH_SANMENG_GUAJI_CHECK) then
    return
  end
  nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, nx_string("sys_smzb_045"))
end
function notice_score(tips, score)
  local ST_FUNCTION_MATCH_SANMENG_DOUBLE_INTEGRAL = 815
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MATCH_SANMENG_DOUBLE_INTEGRAL) then
    return
  end
  nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, nx_string(tips), nx_int(score))
end
function get_notice_scores()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_SanMeng.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string("WarOver"))
    return ini:ReadString(sec_index, nx_string("NoticeStep"), "")
  end
end
function check_notice_reach_score(form)
  if not (nx_find_custom(form, "zq_old_score") and nx_find_custom(form, "hq_old_score") and nx_find_custom(form, "yq_old_score") and nx_find_custom(form, "zq_score") and nx_find_custom(form, "hq_score")) or not nx_find_custom(form, "yq_score") then
    return
  end
  local var = get_notice_scores()
  local score_list = util_split_string(var, ",")
  for i = 1, table.getn(score_list) do
    if nx_int(form.zq_old_score) >= nx_int(score_list[i]) or nx_int(form.hq_old_score) >= nx_int(score_list[i]) or nx_int(form.yq_old_score) >= nx_int(score_list[i]) then
      return
    end
    if nx_int(form.zq_score) ~= nx_int(form.zq_old_score) and nx_int(form.zq_score) >= nx_int(score_list[i]) then
      notice_score(ZQ_TIPS, score_list[i])
      return
    elseif nx_int(form.hq_score) ~= nx_int(form.hq_old_score) and nx_int(form.hq_score) >= nx_int(score_list[i]) then
      notice_score(HQ_TIPS, score_list[i])
      return
    elseif nx_int(form.yq_score) ~= nx_int(form.yq_old_score) and nx_int(form.yq_score) >= nx_int(score_list[i]) then
      notice_score(YQ_TIPS, score_list[i])
      return
    end
  end
end
