require("util_gui")
require("util_functions")
local g_form_name = "form_stage_main\\form_newneigongpk\\form_newneigongpk_main"
function on_main_form_init(form)
end
function on_main_form_open(form)
  form.Fixed = false
  refresh_form()
end
function refresh_form()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = gui.Desktop.Width / 2 - form.Width / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 1.2
  form.lbl_frd.Height = 22
  form.lbl_enm.Height = 22
end
function on_main_form_close(form)
  form.Visible = false
end
function refresh_state(frd_total, enm_total, frd_hp, enm_hp)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if frd_total == nil or enm_total == nil or frd_hp == nil or enm_hp == nil then
    return
  end
  local scale = frd_hp / (frd_hp + enm_hp)
  local frd_wd = 446 * scale
  local enm_wd = 446 - frd_wd
  form.lbl_frd.Width = nx_int(frd_wd)
  form.lbl_enm.Left = form.lbl_frd.Left + frd_wd
  if enm_wd < 1 then
    form.lbl_enm.Visible = false
  else
    form.lbl_enm.Width = nx_int(enm_wd)
    form.lbl_enm.Visible = true
  end
  form.lbl_mid.Left = form.lbl_frd.Left + frd_wd - 5
  form.lbl_frd_streng.Text = nx_widestr(tostring(frd_hp) .. "/" .. tostring(frd_total))
end
function send_gmcc_msg(subtype, ...)
end
