require("util_gui")
require("util_functions")
function on_main_form_init(form)
end
function on_main_form_open(form)
  form.Fixed = false
  form.ipt_1.Text = nx_widestr("")
  form.ipt_2.Text = nx_widestr("")
  check_button(form)
end
function on_main_form_close(form)
end
function on_close_click(btn)
  util_show_form("form_stage_main\\form_enthrall\\form_attest", false)
end
function on_ok_click(btn)
  local form = btn.ParentForm
  local name = form.ipt_1.Text
  local identy = form.ipt_2.Text
  if not check_button(form) then
    return
  end
  nx_execute("form_stage_main\\form_enthrall\\enthrall", "request_unenthrall", 1, name, identy)
end
function on_realname_changed(edit)
  check_button(edit.ParentForm)
end
function on_identy_changed(edit)
  check_button(edit.ParentForm)
end
function check_button(form)
  local name = form.ipt_1.Text
  local identy = form.ipt_2.Text
  if string.len(nx_string(name)) < 1 or string.len(nx_string(identy)) < 1 then
    form.btn_1.Enabled = false
    return false
  end
  form.btn_1.Enabled = true
  return true
end
