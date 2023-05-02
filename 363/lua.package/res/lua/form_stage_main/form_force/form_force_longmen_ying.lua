require("util_gui")
require("custom_sender")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 5
  form.Top = (gui.Height - form.Height) / 2
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 11, 2)
end
function on_main_form_close(form)
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 12, 2)
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
  if nx_string(form.ipt_x.Text) == nx_string("") or nx_string(form.ipt_z.Text) == nx_string("") or nx_widestr(form.ipt_guild.Text) == nx_widestr("") then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_fqfs_005"))
    return
  end
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 6, nx_int(form.ipt_x.Text), nx_int(form.ipt_z.Text), nx_widestr(form.ipt_guild.Text))
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
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_ying", true)
  form.Visible = true
  form:Show()
end
