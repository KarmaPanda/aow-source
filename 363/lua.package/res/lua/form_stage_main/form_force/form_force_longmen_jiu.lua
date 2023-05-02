require("util_gui")
require("custom_sender")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 5
  form.Top = (gui.Height - form.Height) / 2
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 11, 3)
end
function on_main_form_close(form)
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 12, 3)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 8, nx_widestr(form.ipt_name.Text))
  form.Visible = false
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function show_form()
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu", true)
  form.Visible = true
  form:Show()
end
