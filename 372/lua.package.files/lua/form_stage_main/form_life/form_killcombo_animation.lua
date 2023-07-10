function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(self)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function show_form(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "animation") then
    close_form()
    return
  end
  reset_control(form)
  form.ani_1.AnimationImage = nx_string(form.animation)
  form.ani_1.PlayMode = 0
  form.ani_1.Loop = false
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(30000, 1, nx_current(), "on_update_time", form, -1, -1)
end
function close_form()
  local form_animation = nx_value("form_stage_main\\form_life\\form_killcombo_animation")
  if nx_is_valid(form_animation) then
    form_animation:Close()
  end
end
function on_update_time(form)
  end_timer(form)
end
function end_timer(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  reset_control(form)
  form.animation = nil
  form:Close()
end
function reset_control(form)
  form.ani_1.AnimationImage = ""
  form.ani_1.PlayMode = 0
  form.ani_1.Loop = false
end
function change_form_size()
end
function show_killcombo_animation(animation)
  local form_animation = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_killcombo_animation", true)
  if nx_is_valid(form_animation) then
    form_animation:Show()
    form_animation.Visible = true
    form_animation.animation = nx_string(animation)
    show_form(form_animation)
  end
end
