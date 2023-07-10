function init(form)
  form.Fixed = false
  local save_camera_form = nx_value("form_stage_main\\form_camera\\form_save_camera")
  if nx_is_valid(save_camera_form) and save_camera_form.IsShowSubtitle then
    local dialog_up = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera_playing_up", true, false)
    local dialog_down = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera_playing_down", true, false)
    dialog_up:Show()
    dialog_down:Show()
  else
  end
end
function on_main_form_open(form)
  on_size_change(form)
end
function on_main_form_close(form)
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_npc_manager) then
    scenario_npc_manager:StopCameraPath()
  end
  nx_gen_event(form, "camera_stop_playing")
  local dialog_up = nx_value("form_stage_main\\form_camera\\form_save_camera_playing_up")
  local dialog_down = nx_value("form_stage_main\\form_camera\\form_save_camera_playing_down")
  if nx_is_valid(dialog_up) then
    dialog_up:Close()
  end
  if nx_is_valid(dialog_down) then
    dialog_down:Close()
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_stop_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_pause_continue_click(btn)
  local form = btn.ParentForm
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(scenario_npc_manager) then
    return 0
  end
  local save_camera_form = nx_value("form_stage_main\\form_camera\\form_save_camera")
  if not nx_is_valid(save_camera_form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if save_camera_form.Ispause then
    save_camera_form.Ispause = false
    form.btn_pause_continue.Text = gui.TextManager:GetText("ui_camera_pause")
    scenario_npc_manager:PauseCameraPath(false)
  else
    save_camera_form.Ispause = true
    form.btn_pause_continue.Text = gui.TextManager:GetText("ui_camera_continue")
    scenario_npc_manager:PauseCameraPath(true)
  end
end
function on_stop_scenario()
  nx_execute("form_stage_main\\form_camera\\form_save_camera", "on_stop_scenario")
  local form = nx_value("form_stage_main\\form_camera\\form_save_camera_playing")
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_size_change()
  local gui = nx_value("gui")
  local dialog_up = nx_value("form_stage_main\\form_camera\\form_save_camera_playing_up")
  if nx_is_valid(dialog_up) then
    dialog_up.AbsLeft = 0
    dialog_up.AbsTop = 0
    dialog_up.Width = gui.Width
  end
  local dialog_down = nx_value("form_stage_main\\form_camera\\form_save_camera_playing_down")
  if nx_is_valid(dialog_down) then
    dialog_down.AbsLeft = 0
    dialog_down.AbsTop = gui.Height - dialog_down.Height
    dialog_down.Width = gui.Width
  end
  local form = nx_value("form_stage_main\\form_camera\\form_save_camera_playing")
  if not nx_is_valid(form) then
    return false
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = gui.Height / 4 * 3
  return true
end
function show_subtitle(subtitle, at_top)
  if 1 == at_top then
    nx_execute("form_stage_main\\form_camera\\form_save_camera_playing_up", "set_subtitle", subtitle)
    nx_execute("form_stage_main\\form_camera\\form_save_camera_playing_down", "set_subtitle", "")
  else
    nx_execute("form_stage_main\\form_camera\\form_save_camera_playing_up", "set_subtitle", "")
    nx_execute("form_stage_main\\form_camera\\form_save_camera_playing_down", "set_subtitle", subtitle)
  end
end
