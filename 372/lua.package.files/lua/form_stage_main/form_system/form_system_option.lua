require("util_gui")
require("util_functions")
require("share\\logicstate_define")
local PRE_SELECT_ROLE = 1
local SELECT_ROLE = 0
function open_form()
  util_auto_show_hide_form(nx_current())
end
function form_system_option_Init(self)
  self.Fixed = false
end
function form_system_option_Open(self)
  local gui = nx_value("gui")
  local AOWSteamClient = nx_value("AOWSteamClient")
  if nx_is_valid(AOWSteamClient) then
    self.btn_relogin.Enabled = false
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function form_system_option_OnClickVideoOption(btn)
  local mapQuery = nx_value("MapQuery")
  if nx_is_valid(mapQuery) then
    local target_visual_radius = mapQuery:GetSpecialSceneVisualRadius()
    if mapQuery:IsSpecialScene() and target_visual_radius ~= 0 then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("jddb_jm_01"), 2)
      end
    else
      util_auto_show_hide_form("form_stage_main\\form_system\\form_system_setting")
    end
  else
    util_auto_show_hide_form("form_stage_main\\form_system\\form_system_setting")
  end
end
function form_system_option_OnClickAudioOption(btn)
  local form = nx_value("form_common\\form_play_video")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19902"), 2)
    end
  else
    util_auto_show_hide_form("form_stage_main\\form_system\\form_system_music_setting")
  end
end
function form_system_option_OnClickGongNengOption(btn)
  util_auto_show_hide_form("form_stage_main\\form_system\\form_system_funcconfig")
end
function form_system_option_OnAttackUI(btn)
  local game_config_info = nx_value("game_config_info")
  local is_first_open = nx_string(util_get_property_key(game_config_info, "is_first_open", 1)) == nx_string("1")
  util_auto_show_hide_form("form_stage_main\\form_system\\form_system_interface_setting")
end
function form_system_option_OnClickKeyOption(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shortcut_key", true, false)
  dialog:ShowModal()
end
function form_system_option_OnClickReLogin(btn)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  if game_player:FindProp("LogicState") then
    local logic_state = game_player:QueryProp("LogicState")
    if nx_int(logic_state) == nx_int(LS_FIGHTING) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "log_out_err")
      return
    end
  end
  ShowMovieSaveForm()
  local karmamgr = nx_value("Karma")
  if nx_is_valid(karmamgr) then
    karmamgr:SaveFilterNative()
  end
  if wait_relogin_game() then
    local gEffect = nx_value("global_effect")
    if nx_is_valid(gEffect) then
      gEffect:ClearEffects()
    end
    local team_manager = nx_value("team_manager")
    if nx_is_valid(team_manager) then
      team_manager:ClearAllData()
    end
    nx_execute("stage", "set_current_stage", "login")
    nx_execute("client", "close_connect")
    return true
  end
  return false
end
function form_system_option_OnClickQuit(btn)
  ShowMovieSaveForm()
  nx_execute("main", "exit_game")
end
function on_close_form(btn)
  local form = btn.Parent
  form.Visible = false
  form:Close()
end
function wait_relogin_game()
  nx_execute("custom_sender", "custom_checked_selectrole", PRE_SELECT_ROLE)
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "exit_game")
  if not nx_is_valid(dialog) then
    return
  end
  dialog.ok_btn.Visible = false
  dialog.relogin_btn.Visible = false
  dialog:ShowModal()
  local text = nx_widestr(util_format_string("ui_waittocharacter", nx_int(10)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.cancel_btn.Text = nx_widestr(util_text("ui_fanhui"))
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    local res = common_execute:AddExecute("WaitReSelectRole", dialog, 1, nx_int(10))
  end
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("LogicState", "int", dialog, nx_current(), "check_can_exit")
  local res = nx_wait_event(100000000, dialog, "exit_game_confirm_return")
  databinder:DelRolePropertyBind("LogicState", dialog)
  if res == "cancel" then
    if nx_is_valid(common_execute) then
      common_execute:RemoveExecute("WaitReSelectRole", dialog)
    end
    return false
  elseif res == "ok" then
    nx_execute("custom_sender", "custom_checked_selectrole", SELECT_ROLE)
    local game_config = nx_value("game_config")
    if nx_is_valid(game_config) then
      game_config.res_login = true
    end
    return false
  end
end
function check_can_exit(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(prop_name) == "LogicState" and nx_int(prop_value) == nx_int(LS_FIGHTING) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "log_out_err")
    nx_execute("form_common\\form_confirm", "cancel_btn_click", form.cancel_btn)
  end
end
function ShowMovieSaveForm()
  local MovieSaver = nx_value("MovieSaverModule")
  if not nx_is_valid(MovieSaver) then
    return
  end
  local bRet = MovieSaver:IsRecording()
  if bRet == true then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_movie_save", true, false)
    dialog:ShowModal()
    nx_wait_event(100000000, dialog, "MovieSaver")
  end
end
function on_gui_size_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 1
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function form_system_option_OnClickCameraSave(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera", true, false)
  dialog:Show()
  local form = btn.Parent
  form.Visible = false
  form:Close()
end
function on_btn_relogin_click(btn)
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "relogin")
  if not nx_is_valid(dialog) then
    return
  end
  dialog.relogin_btn.Visible = false
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_relogin_confirm"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  res = nx_wait_event(100000000, dialog, "relogin_confirm_return")
  if res == "ok" then
    local gEffect = nx_value("global_effect")
    if nx_is_valid(gEffect) then
      gEffect:ClearEffects()
    end
    local team_manager = nx_value("team_manager")
    if nx_is_valid(team_manager) then
      team_manager:ClearAllData()
    end
    nx_execute("stage", "set_current_stage", "login")
    nx_execute("client", "close_connect")
    local karmamgr = nx_value("Karma")
    if nx_is_valid(karmamgr) then
      karmamgr:SaveFilterNative()
    end
  elseif res == "cancel" then
    return
  end
end
function on_btn_cancel_click(btn)
  on_close_form(btn)
end
