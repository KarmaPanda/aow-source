require("const_define")
function init(form)
  form.mode = "open"
  local gui = nx_value("gui")
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.keep_time = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.no_need_motion_alpha = true
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.AbsLeft = 0
  form.AbsTop = 0
  form.lbl_up.Width = form.Width
  form.lbl_down.Width = form.Width
  form.lbl_left.Height = form.Height
  form.lbl_right.Height = form.Height
  form.lbl_up.Visible = false
  form.lbl_down.Visible = false
  form.lbl_left.Visible = false
  form.lbl_right.Visible = false
  form.close_mode = nx_number(nx_int(math.random(1, 5)))
  local loading_form = nx_execute("util_gui", "util_get_form", "form_common\\form_loading", false, false)
  form.Visible = true
  if nx_is_valid(loading_form) and nx_find_custom(loading_form, "openflag") and loading_form.openflag then
    form.Visible = false
  end
  if nx_find_custom(form, "simulate") then
    if form.simulate == 1 then
      form.keep_time = 0.3
      nx_execute(nx_current(), "up_and_down_close", form)
    end
  elseif form.mode == "open" then
    nx_execute(nx_current(), "do_open_scene", form)
  else
    local timer = nx_value(GAME_TIMER)
    timer:Register(1000, 1, "form_stage_main\\form_close_scene", "do_close_scene", form, -1, -1)
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_close_scene")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.Width = gui.Desktop.Width
    form.Height = gui.Desktop.Height
    form.AbsLeft = 0
    form.AbsTop = 0
    form.lbl_up.Width = form.Width
    form.lbl_down.Width = form.Width
    form.lbl_left.Height = form.Height
    form.lbl_right.Height = form.Height
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister("form_stage_main\\form_close_scene", "do_close_scene", form)
  end
  if nx_running(nx_current(), "do_open_scene") then
    nx_kill(nx_current(), "do_open_scene")
  end
  if nx_running(nx_current(), "do_close_scene") then
    nx_kill(nx_current(), "do_close_scene")
  end
end
function do_open_scene(form)
  if form.close_mode == 1 then
    up_and_down_open(form)
  elseif form.close_mode == 2 then
    left_to_right_open(form)
  elseif form.close_mode == 3 then
    right_to_left_open(form)
  elseif form.close_mode == 4 then
    left_and_right_open(form)
  elseif form.close_mode == 5 then
    up_to_down_open(form)
  end
  nx_gen_event(form, "scene_change_return", true)
end
function do_close_scene(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_close_scene", "do_close_scene", form)
  if form.close_mode == 1 then
    up_and_down_close(form)
  elseif form.close_mode == 2 then
    left_to_right_close(form)
  elseif form.close_mode == 3 then
    right_to_left_close(form)
  elseif form.close_mode == 4 then
    left_and_right_close(form)
  elseif form.close_mode == 5 then
    up_to_down_close(form)
  end
  nx_gen_event(form, "scene_change_return", true)
  nx_set_value("scene_change_return", true)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "game_control") then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.Pause = false
  game_control.AllowControl = true
end
function up_and_down_open(form)
  local gui = nx_value("gui")
  form.lbl_up.Visible = true
  form.lbl_down.Visible = true
  form.lbl_up.Height = gui.Desktop.Height / 2 + 20
  form.lbl_down.Height = gui.Desktop.Height / 2 + 40
  form.lbl_up.AbsTop = 0
  form.lbl_down.AbsTop = gui.Desktop.Height + 20 - form.lbl_down.Height
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  while nx_is_valid(form) and form.lbl_up.Height > 0 and form.lbl_down.Height > 0 do
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
    form.lbl_up.Height = nx_int((1 - time_count / form.keep_time) * (gui.Desktop.Height / 2 + 20))
    form.lbl_down.Height = form.lbl_up.Height + 20
    form.lbl_up.AbsTop = 0
    form.lbl_down.AbsTop = gui.Desktop.Height + 20 - form.lbl_down.Height
  end
  form.lbl_up.Visible = false
  form.lbl_down.Visible = false
end
function up_and_down_close(form)
  local gui = nx_value("gui")
  form.lbl_up.Height = 1
  form.lbl_down.Height = 21
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_up.Visible = true
  form.lbl_down.Visible = true
  while nx_is_valid(form) and form.lbl_up.Height < gui.Desktop.Height / 2 + 20 and form.lbl_down.Height < gui.Desktop.Height / 2 + 40 do
    form.lbl_up.Height = time_count / form.keep_time * (form.Height / 2 + 20)
    form.lbl_down.Height = form.lbl_up.Height + 20
    form.lbl_up.AbsTop = 0
    form.lbl_down.AbsTop = gui.Desktop.Height + 20 - form.lbl_down.Height
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
  end
  form.lbl_up.Height = gui.Desktop.Height / 2 + 50
  form.lbl_down.Height = gui.Desktop.Height / 2 + 50 + 20
  form.lbl_down.AbsTop = gui.Desktop.Height + 20 - form.lbl_down.Height
  time_count = 0
  while time_count < 0.2 do
    time_count = time_count + nx_pause(0)
  end
end
function left_to_right_open(form)
  local gui = nx_value("gui")
  form.lbl_left.Visible = true
  form.lbl_left.AbsLeft = 0
  form.lbl_left.AbsTop = 0
  form.lbl_left.Height = gui.Desktop.Height
  form.lbl_left.Width = gui.Desktop.Width + 40
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  while nx_is_valid(form) and 0 < form.lbl_left.Width do
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
    form.lbl_left.Width = nx_int((1 - time_count / form.keep_time) * (form.Width + 40))
  end
  form.lbl_left.Visible = false
end
function left_to_right_close(form)
  local gui = nx_value("gui")
  form.lbl_left.Visible = true
  form.lbl_left.AbsLeft = 0
  form.lbl_left.AbsTop = 0
  form.lbl_left.Height = gui.Desktop.Height
  form.lbl_left.Width = 1
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  while 0 < form.lbl_left.Width do
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
    form.lbl_left.Width = nx_int(time_count / form.keep_time * (gui.Desktop.Width + 40))
  end
  form.lbl_left.Width = gui.Desktop.Width + 40
  time_count = 0
  while time_count < 0.2 do
    time_count = time_count + nx_pause(0)
  end
end
function right_to_left_open(form)
  local gui = nx_value("gui")
  form.lbl_right.Visible = true
  form.lbl_right.AbsTop = 0
  form.lbl_right.Height = gui.Desktop.Height
  form.lbl_right.Width = gui.Desktop.Width + 40
  form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  while nx_is_valid(form) and 0 < form.lbl_left.Width do
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
    form.lbl_right.Width = nx_int((1 - time_count / form.keep_time) * (gui.Desktop.Width + 40))
    form.lbl_right.AbsLeft = form.Width - form.lbl_right.Width
  end
  form.lbl_right.Visible = false
end
function right_to_left_close(form)
  local gui = nx_value("gui")
  form.lbl_right.Visible = true
  form.lbl_right.AbsTop = 0
  form.lbl_right.Height = gui.Desktop.Height
  form.lbl_right.Width = 1
  form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  while nx_is_valid(form) and 0 < form.lbl_right.Width do
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
    form.lbl_right.Width = nx_int(time_count / form.keep_time * (gui.Desktop.Width + 40))
    form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
  end
  form.lbl_right.Width = gui.Desktop.Width + 40
  form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
  time_count = 0
  while time_count < 0.2 do
    time_count = time_count + nx_pause(0)
  end
end
function left_and_right_open(form)
  local gui = nx_value("gui")
  form.lbl_left.Visible = true
  form.lbl_right.Visible = true
  form.lbl_left.AbsLeft = 0
  form.lbl_left.AbsTop = 0
  form.lbl_left.Height = gui.Desktop.Height
  form.lbl_left.Width = gui.Desktop.Width / 2 + 40
  form.lbl_right.AbsTop = 0
  form.lbl_right.Height = gui.Desktop.Height
  form.lbl_right.Width = gui.Desktop.Width / 2 + 40
  form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  while nx_is_valid(form) and 0 < form.lbl_left.Width and 0 < form.lbl_right.Width do
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
    form.lbl_left.Width = nx_int((1 - time_count / form.keep_time) * (gui.Desktop.Width / 2 + 40))
    form.lbl_right.Width = nx_int((1 - time_count / form.keep_time) * (gui.Desktop.Width / 2 + 40))
    form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
  end
  form.lbl_right.Visible = false
  form.lbl_left.Visible = false
end
function left_and_right_close(form)
  local gui = nx_value("gui")
  form.lbl_left.Visible = true
  form.lbl_right.Visible = true
  form.lbl_left.AbsLeft = 0
  form.lbl_left.AbsTop = 0
  form.lbl_left.Height = gui.Desktop.Height
  form.lbl_left.Width = 1
  form.lbl_right.AbsTop = 0
  form.lbl_right.Height = gui.Desktop.Height
  form.lbl_right.Width = 1
  form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  while nx_is_valid(form) and 0 < form.lbl_left.Width and 0 < form.lbl_right.Width do
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
    form.lbl_left.Width = nx_int(time_count / form.keep_time * (gui.Desktop.Width / 2 + 40))
    form.lbl_right.Width = nx_int(time_count / form.keep_time * (gui.Desktop.Width / 2 + 40))
    form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
  end
  form.lbl_left.Width = gui.Desktop.Width / 2 + 40
  form.lbl_right.Width = gui.Desktop.Width / 2 + 40
  form.lbl_right.AbsLeft = gui.Desktop.Width - form.lbl_right.Width
end
function up_to_down_open(form)
  local gui = nx_value("gui")
  form.lbl_up.Visible = true
  form.lbl_up.Height = gui.Desktop.Height + 40
  form.lbl_up.AbsTop = 0
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  while nx_is_valid(form) and form.lbl_up.Height > 0 do
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
    form.lbl_up.Height = nx_int((1 - time_count / form.keep_time) * (gui.Desktop.Height + 40))
    form.lbl_up.AbsTop = 0
  end
  form.lbl_up.Visible = false
end
function up_to_down_close(form)
  local gui = nx_value("gui")
  form.lbl_up.Height = 1
  local time_count = 0
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_up.Visible = true
  while nx_is_valid(form) and form.lbl_up.Height < gui.Desktop.Height + 40 do
    form.lbl_up.Height = time_count / form.keep_time * (gui.Desktop.Height + 40)
    form.lbl_up.AbsTop = 0
    time_count = time_count + nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    if time_count > form.keep_time then
      break
    end
  end
  form.lbl_up.Height = gui.Desktop.Height + 50
  time_count = 0
  while time_count < 0.2 do
    time_count = time_count + nx_pause(0)
  end
end
