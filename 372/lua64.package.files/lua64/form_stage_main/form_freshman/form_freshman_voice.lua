require("util_functions")
require("util_gui")
local GUIDE_VOICE_PLAYER_ID = "guide_voice"
local FORM_FRESHMAN_VOICE = "form_stage_main\\form_freshman\\form_freshman_voice"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.btn_pause.Visible = false
  form.lbl_wave.BackImage = ""
  local gui = nx_value("gui")
  form.Top = -form.Height - gui.Height / 2.27
  form.Left = -form.Width
  local voice_player = get_voice_player()
  if nx_is_valid(voice_player) then
    voice_player:SetStateLuaCallback("playing", nx_current(), "on_voice_player_playing")
    voice_player:SetStateLuaCallback("stop", nx_current(), "on_voice_player_stop")
    voice_player:SetStateLuaCallback("pause", nx_current(), "on_voice_player_pause")
    voice_player:SetStateLuaCallback("error", nx_current(), "on_voice_player_stop")
  end
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_FRESHMAN_VOICE, "on_main_form_close", form)
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:ClearVoicePlayer(GUIDE_VOICE_PLAYER_ID)
  end
  nx_destroy(form)
end
function on_btn_play_click(btn)
  local voice_player = get_voice_player()
  if not nx_is_valid(voice_player) then
    return
  end
  if not voice_player:Continue() and not voice_player:Replay() then
    return
  end
end
function on_btn_pause_click(btn)
  local voice_player = get_voice_player()
  if not nx_is_valid(voice_player) then
    return
  end
  if not voice_player:Pause() then
    return
  end
end
function on_btn_replay_click(btn)
  local voice_player = get_voice_player()
  if not nx_is_valid(voice_player) then
    return
  end
  if not voice_player:Replay() then
    return
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_voice_player_stop(voice_player)
  local form = util_get_form(FORM_FRESHMAN_VOICE, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.btn_play.Visible = true
  form.btn_play.HintText = nx_widestr("@tips_voice_play")
  form.btn_pause.Visible = false
  form.lbl_wave.BackImage = ""
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(30000, -1, FORM_FRESHMAN_VOICE, "on_main_form_close", form, -1, -1)
  end
end
function on_voice_player_pause(voice_player)
  local form = util_get_form(FORM_FRESHMAN_VOICE, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.btn_play.Visible = true
  form.btn_play.HintText = nx_widestr("@tips_voice_go_on")
  form.btn_pause.Visible = false
  form.lbl_wave.BackImage = ""
end
function on_voice_player_playing(voice_player)
  local form = util_get_form(FORM_FRESHMAN_VOICE, false, false)
  if not nx_is_valid(form) then
    return
  end
  stop_other_voice_player()
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_FRESHMAN_VOICE, "on_main_form_close", form)
  end
  form.btn_play.Visible = false
  form.btn_pause.Visible = true
  form.lbl_wave.BackImage = "voice_wave"
end
function on_size_change()
  local form = util_get_form(FORM_FRESHMAN_VOICE, false, false)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible then
    local gui = nx_value("gui")
    gui.Desktop:ToFront(form)
  end
end
function get_voice_player()
  local voice_manager = nx_value("voice_manager")
  if not nx_is_valid(voice_manager) then
    return nx_null()
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(1510) then
    return nx_null()
  end
  local voice_player = voice_manager:GetVoicePlayer(GUIDE_VOICE_PLAYER_ID)
  if not nx_is_valid(voice_player) then
    return nx_null()
  end
  return voice_player
end
function stop_other_voice_player()
  local voice_manager = nx_value("voice_manager")
  if not nx_is_valid(voice_manager) then
    return
  end
  voice_manager:StopALLWithoutId(GUIDE_VOICE_PLAYER_ID)
end
function play_voice(voice_name)
  local game_config_info = nx_value("game_config_info")
  local enable_guide_voice = nx_int(util_get_property_key(game_config_info, "guide_voice", 1))
  if nx_int(1) ~= enable_guide_voice then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "845198")
    return
  end
  local form = util_get_form(FORM_FRESHMAN_VOICE, true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  form.Visible = true
  form:Show()
  local voice_player = get_voice_player()
  if nx_is_valid(voice_player) then
    voice_player:Play(voice_name)
  end
end
function close_form()
  local form = util_get_form(FORM_FRESHMAN_VOICE, false, false)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
