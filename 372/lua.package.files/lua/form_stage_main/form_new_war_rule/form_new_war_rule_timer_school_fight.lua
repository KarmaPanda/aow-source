require("util_functions")
require("util_gui")
require("custom_sender")
local FTI_BOSS_POS = 0
local FTI_DEFEND_ACTIVE_STATE = 1
local FTI_ATTACK_ACTIVE_STATE = 2
local FTI_PLAYER_NUM_INFO = 3
local FORM_NAME = "form_stage_main\\form_new_war_rule\\form_new_war_rule_timer_school_fight"
function main_form_init(self)
  self.Fixed = false
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
    form_map.btn_new_war_rule.Visible = false
  end
  nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_score_school_fight", "close_form")
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
  nx_execute("form_stage_main\\form_universal_school_fight\\form_universal_school_fight_progress", "close_form")
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
  local cur_time = get_cur_time()
  local end_time = get_end_time()
  local sur_time = end_time - cur_time
  form.sur_time = sur_time
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
function Update_Trace_Info(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local msg_count = table.getn(arg) / 2
  local index = 0
  for i = 1, msg_count do
    index = index + 1
    local trace_type = arg[index]
    if trace_type == FTI_BOSS_POS then
      index = index + 1
      local pos_index = arg[index]
      nx_execute("form_stage_main\\form_universal_school_fight\\form_universal_school_fight_progress", "Update_Boss_Pos", pos_index)
    elseif trace_type == FTI_DEFEND_ACTIVE_STATE then
      index = index + 1
      local active_state = arg[index]
      analysis_point_info(form, "ui_newschoolwar_guj_021", active_state)
    elseif trace_type == FTI_ATTACK_ACTIVE_STATE then
      index = index + 1
      local active_state = arg[index]
      analysis_point_info(form, "ui_newschoolwar_guj_020", active_state)
    elseif trace_type == FTI_PLAYER_NUM_INFO then
      index = index + 1
      local defend_num = arg[index]
      index = index + 1
      local attack_num = arg[index]
      nx_execute("form_stage_main\\form_universal_school_fight\\form_universal_school_fight_progress", "Update_Show_Player_num", defend_num, attack_num)
    end
  end
end
function analysis_point_info(form, str_id, active_state)
  local MAX_BIT = 6
  local bit_array = get_bit_value(active_state, 32)
  local gui = nx_value("gui")
  for i = 1, MAX_BIT do
    local active = false
    if nx_number(bit_array[i]) == 1 then
      active = true
    end
    if active then
      local lbl = nx_custom(form, "lbl_point_" .. nx_string(i))
      if nx_is_valid(lbl) then
        lbl.Text = nx_widestr(gui.TextManager:GetText(str_id))
      end
    end
  end
  return
end
function get_bit_value(data, bit_count)
  local result = {}
  for i = 1, nx_number(bit_count) do
    table.insert(result, 0)
  end
  local tmpdata = nx_int64(data)
  for i = nx_number(bit_count) - 1, 0, -1 do
    if nx_number(tmpdata) <= nx_number(0) then
      return result
    end
    local tmp = math.floor(tmpdata / math.pow(2, i))
    if nx_number(tmp) == 1 then
      result[i + 1] = nx_number(tmp)
      tmpdata = tmpdata - math.pow(2, i)
    end
  end
  return result
end
