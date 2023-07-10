require("util_gui")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
end
function main_form_open(form)
  set_form_pos(form)
  nx_set_custom(form, "repentTimeHour", nx_int(0))
  nx_set_custom(form, "repentTimeMinute", nx_int(0))
  nx_set_custom(form, "repentTimeSecond", nx_int(0))
  return 1
end
function on_main_form_close(form)
  end_repent()
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_end_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_repent_quit_confirm")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return 0
  end
  end_repent()
  return 1
end
function begin_repent()
  local form = nx_value("form_stage_main\\form_repent")
  if nx_is_valid(form) then
    form:Close()
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_repent", true, false)
  if nx_is_valid(form) then
    form:Show()
  end
end
function end_repent()
  nx_execute("custom_sender", "end_repent")
  local form = nx_value("form_stage_main\\form_repent")
  if not nx_is_valid(form) then
    return
  end
  clear_repent_time(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_repent_time", form)
  end
  form:Close()
end
function show_window()
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function update_repent_time(form)
  if nx_int(form.repentTimeSecond) == nx_int(0) then
    if nx_int(form.repentTimeMinute) > nx_int(0) then
      form.repentTimeSecond = 60
      form.repentTimeMinute = form.repentTimeMinute - 1
    end
    if nx_int(form.repentTimeMinute) == nx_int(0) and nx_int(form.repentTimeHour) > nx_int(0) then
      form.repentTimeMinute = 59
      form.repentTimeSecond = 60
      form.repentTimeHour = form.repentTimeHour - 1
    end
  end
  if nx_int(form.repentTimeSecond) > nx_int(0) then
    form.repentTimeSecond = form.repentTimeSecond - 1
  end
  showFormatTime(form)
end
function clear_repent_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.repentTimeHour = 0
  form.repentTimeMinute = 0
  form.repentTimeSecond = 0
end
function calcTotalRepentTime(form, repentTimeTotal)
  form.repentTimeHour = nx_int(repentTimeTotal / 3600)
  form.repentTimeMinute = nx_int((repentTimeTotal - form.repentTimeHour * 3600) / 60)
  form.repentTimeSecond = nx_int(repentTimeTotal - form.repentTimeHour * 3600 - form.repentTimeMinute * 60)
end
function showFormatTime(form)
  local str_repent_time = nx_widestr("")
  if nx_int(form.repentTimeHour) <= nx_int(9) then
    str_repent_time = nx_widestr("0")
  end
  str_repent_time = nx_widestr(str_repent_time) .. nx_widestr(form.repentTimeHour) .. nx_widestr(":")
  if nx_int(form.repentTimeMinute) <= nx_int(9) then
    str_repent_time = nx_widestr(str_repent_time) .. nx_widestr("0")
  end
  str_repent_time = nx_widestr(str_repent_time) .. nx_widestr(form.repentTimeMinute) .. nx_widestr(":")
  if nx_int(form.repentTimeSecond) <= nx_int(9) then
    str_repent_time = nx_widestr(str_repent_time) .. nx_widestr("0")
  end
  str_repent_time = nx_widestr(str_repent_time) .. nx_widestr(form.repentTimeSecond)
  form.lbl_time.Text = str_repent_time
end
function showDecPkValue(form, dec_pk)
  form.lbl_dec_pk.Text = nx_widestr(dec_pk)
end
function on_server_msg_update_ui(...)
  local form = nx_value("form_stage_main\\form_repent")
  if not nx_is_valid(form) then
    return
  end
  local count = #arg
  if count < 2 then
    return
  end
  local dec_pk_cd = nx_int(arg[1])
  local next_dec_pk = nx_int(arg[2])
  if dec_pk_cd >= nx_int(0) then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_repent_time", form)
      timer:Register(1000, -1, nx_current(), "update_repent_time", form, -1, -1)
    end
    calcTotalRepentTime(form, dec_pk_cd)
    showFormatTime(form)
  end
  showDecPkValue(form, next_dec_pk)
end
