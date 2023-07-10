function write_log(info)
  local console = nx_value("console")
  if not nx_is_valid(console) then
    return
  end
  console:Log(info)
end
function console_log_down(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Out(info)
  end
end
function disp_error(info)
  local gui = nx_value("gui")
  local form = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  form.info_label.Text = nx_widestr(info)
  form:ShowModal()
  nx_wait_event(100000000, form, "error_return")
  return 1
end
function show_confirm(info)
  local gui = nx_value("gui")
  local form = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", form, info)
  form:ShowModal()
  return nx_wait_event(100000000, form, "confirm_return")
end
