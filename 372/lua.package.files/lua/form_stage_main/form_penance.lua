require("util_gui")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
end
function main_form_open(form)
  set_form_pos(form)
  nx_set_custom(form, "penanceTimeHour", nx_int(0))
  nx_set_custom(form, "penanceTimeMinute", nx_int(0))
  nx_set_custom(form, "penanceTimeSecond", nx_int(0))
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_end_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_SchoolRule_repent_confirm")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return true
  end
  nx_execute("custom_sender", "end_school_penance")
  end_penance()
end
function begin_penance()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_penance", true, false)
  if nx_is_valid(form) then
    form:Show()
  end
  calcTotalPenanceTime(form)
  setFormFormatTime(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "update_penance_time", form)
  timer:Register(1000, -1, nx_current(), "update_penance_time", form, -1, -1)
end
function end_penance()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_penance", true, false)
  if not nx_is_valid(form) then
    return
  end
  clearPenanceTime(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "update_penance_time", form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_window()
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function update_penance_time(form)
  if nx_int(form.penanceTimeSecond) == nx_int(0) then
    if nx_int(form.penanceTimeMinute) > nx_int(0) then
      form.penanceTimeSecond = 60
      form.penanceTimeMinute = form.penanceTimeMinute - 1
    end
    if nx_int(form.penanceTimeMinute) == nx_int(0) and nx_int(form.penanceTimeHour) > nx_int(0) then
      form.penanceTimeMinute = 59
      form.penanceTimeSecond = 60
      form.penanceTimeHour = form.penanceTimeHour - 1
    end
  end
  if nx_int(form.penanceTimeSecond) > nx_int(0) then
    form.penanceTimeSecond = form.penanceTimeSecond - 1
  end
  setFormFormatTime(form)
end
function clearPenanceTime(form)
  if not nx_is_valid(form) then
    return
  end
  form.penanceTimeHour = 0
  form.penanceTimeMinute = 0
  form.penanceTimeSecond = 0
end
function calcTotalPenanceTime(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local penanceTimeTotal = nx_int(0)
  if client_player:FindProp("SchoolRuleValue") then
    penanceTimeTotal = nx_int(client_player:QueryProp("SchoolRuleValue")) * 60
  end
  form.penanceTimeHour = nx_int(penanceTimeTotal / 3600)
  form.penanceTimeMinute = nx_int((penanceTimeTotal - form.penanceTimeHour * 3600) / 60)
  form.penanceTimeSecond = nx_int(penanceTimeTotal - form.penanceTimeHour * 3600 - form.penanceTimeMinute * 60)
end
function setFormFormatTime(form)
  local StrPenanceTime = nx_widestr("")
  if nx_int(form.penanceTimeHour) <= nx_int(9) then
    StrPenanceTime = nx_widestr("0")
  end
  StrPenanceTime = nx_widestr(StrPenanceTime) .. nx_widestr(form.penanceTimeHour) .. nx_widestr(":")
  if nx_int(form.penanceTimeMinute) <= nx_int(9) then
    StrPenanceTime = nx_widestr(StrPenanceTime) .. nx_widestr("0")
  end
  StrPenanceTime = nx_widestr(StrPenanceTime) .. nx_widestr(form.penanceTimeMinute) .. nx_widestr(":")
  if nx_int(form.penanceTimeSecond) <= nx_int(9) then
    StrPenanceTime = nx_widestr(StrPenanceTime) .. nx_widestr("0")
  end
  StrPenanceTime = nx_widestr(StrPenanceTime) .. nx_widestr(form.penanceTimeSecond)
  form.lbl_time.Text = StrPenanceTime
end
