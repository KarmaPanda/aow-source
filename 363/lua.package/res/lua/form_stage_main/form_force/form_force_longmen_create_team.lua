require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_force\\form_force_longmen_create_team"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 17, nx_widestr(btn.ParentForm.ipt_1.Text))
  close_form()
end
function on_btn_cancel_click(btn)
  close_form()
end
function show_form()
  local form = util_get_form(FORM_NAME, true)
  form.Visible = true
  form:Show()
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
