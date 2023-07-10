require("util_functions")
require("share\\client_custom_define")
local form_name = "form_stage_main\\form_small_game\\form_push_box"
function main_form_init(form)
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  stop_timer(self)
  nx_destroy(self)
end
function on_btn_push_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PUSH_BOX_GAME), nx_int(1))
end
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.curtime = form.curtime + 100
  if nx_int(form.curtime) <= nx_int(form.maxtime * 1000) then
    form.pbar_1.Value = 100 * (form.curtime / (form.maxtime * 1000))
  else
    form.pbar_1.Value = 100 * (1 - (form.curtime - form.maxtime * 1000) / (form.maxtime * 1000))
  end
  if nx_int(form.curtime) == nx_int(0) then
    nx_destroy(form)
  end
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
function open_form(maxTime)
  local form = nx_value(form_name)
  if nx_is_valid(form) then
    form:Close()
  end
  local form = nx_execute("util_gui", "util_get_form", form_name, true, false)
  form:Show()
  form.curtime = 0
  form.maxtime = maxTime
  local timer = nx_value(GAME_TIMER)
  nx_execute(nx_current(), "on_update_time", form, 0)
  timer:Register(100, -1, nx_current(), "on_update_time", form, 0, -1)
end
function close_form()
  local form = nx_value(form_name)
  if nx_is_valid(form) then
    form:Close()
    return
  end
end
