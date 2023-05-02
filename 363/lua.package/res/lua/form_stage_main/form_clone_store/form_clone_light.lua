require("util_functions")
function main_form_init(form)
  form.Fixed = true
  form.tick_count = 0
end
function on_main_form_open(form)
  if nx_find_custom(form, "wait_time") then
    reset_timer(form, form.wait_time)
  else
    reset_timer(form, 30)
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function reset_timer(form, count)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  form.lbl_tick.Text = nx_widestr(count)
  form.tick_count = nx_number(count)
  timer:UnRegister(nx_current(), "on_timer_update", form)
  timer:Register(1000, -1, nx_current(), "on_timer_update", form, -1, -1)
end
function on_timer_update(form, param1, param2)
  form.tick_count = form.tick_count - 1
  if form.tick_count == 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_timer_update", form)
      form:Close()
    end
  else
    form.lbl_tick.Text = nx_widestr(form.tick_count)
  end
end
