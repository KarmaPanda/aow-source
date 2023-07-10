require("util_gui")
require("custom_sender")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 5
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
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
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_confirm", false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 9, nx_widestr(form.lbl_name.Text))
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
function show_form(...)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_confirm", true)
  form.Visible = true
  form:Show()
  form.lbl_name.Text = nx_widestr(arg[1])
  form.mltbox_1.Visible = false
  form.mltbox_2.Visible = false
  form.mltbox_3.Visible = false
  form.btn_ok.Visible = false
  if nx_widestr(arg[2]) == nx_widestr("") then
    form.mltbox_3.Visible = true
  else
    local gui = nx_value("gui")
    form.lbl_info.Text = nx_widestr(gui.TextManager:GetText(arg[2]))
    if nx_int(arg[3]) == nx_int(1) then
      form.mltbox_2.Visible = true
    else
      form.mltbox_1.Visible = true
      form.btn_ok.Visible = true
    end
  end
end
