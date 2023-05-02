require("util_gui")
require("util_functions")
local JION_TIGUAN_BEGIN = 0
local JION_TIGUAN_CONTINUE = 1
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  local timer_game = nx_value("timer_game")
  if nx_is_valid(timer_game) then
    timer_game:UnRegister(nx_current(), "on_update_trace", form)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function refresh_time(type, use_time, best_time)
  local form = util_get_form(nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  form.use_time = nx_number(use_time) + 1
  form.best_time = best_time
  local timer_game = nx_value("timer_game")
  if nx_is_valid(timer_game) then
    timer_game:UnRegister(nx_current(), "on_update_trace", form)
    timer_game:Register(1000, -1, nx_current(), "on_update_trace", form, -1, -1)
  end
  if form.best_time == 0 then
    form.lbl_best_use_time.Text = nx_widestr("--:--")
  else
    form.lbl_best_use_time.Text = nx_widestr(get_time_str(nx_number(form.best_time)))
  end
  if JION_TIGUAN_BEGIN == type or JION_TIGUAN_CONTINUE == type then
    util_show_form(nx_current(), true)
  end
end
function on_update_trace(form)
  form.use_time = form.use_time + 1
  form.lbl_now_use_time.Text = nx_widestr(get_time_str(nx_number(form.use_time)))
end
function get_time_str(times)
  local szTime = ""
  local minute = nx_number(nx_int(times / 60))
  if minute < 10 then
    szTime = szTime .. "0" .. nx_string(minute)
  else
    szTime = szTime .. nx_string(minute)
  end
  szTime = szTime .. ":"
  local second = times - minute * 60
  if second < 10 then
    szTime = szTime .. "0" .. nx_string(second)
  else
    szTime = szTime .. nx_string(second)
  end
  return szTime
end
function close_form()
  local form = util_get_form(nx_current(), false)
  if nx_is_valid(form) then
    form:Close()
  end
end
