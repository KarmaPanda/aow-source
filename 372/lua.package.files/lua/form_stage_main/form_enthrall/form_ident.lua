require("util_gui")
require("tips_data")
require("util_functions")
require("util_static_data")
local FORM_IDENT = "form_stage_main\\form_enthrall\\form_ident"
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_size(form)
  set_form_data(form)
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:set_start_ident_count(false)
  return 1
end
function on_main_form_close(form)
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:set_start_ident_count(true)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function set_form_data(form)
  form.ipt_1.Text = nx_widestr("")
  form.ipt_2.Text = nx_widestr("")
  check_button(form)
end
function on_ok_click(btn)
  local form = btn.ParentForm
  local name = form.ipt_1.Text
  local identy = form.ipt_2.Text
  if not check_button(form) then
    return
  end
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    return
  end
  local name = form.ipt_1.Text
  local identy = form.ipt_2.Text
  mgr:ident_http_set(nx_string(name), nx_string(identy))
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
function show_form(show)
  if show then
    if not util_is_lockform_visible(FORM_IDENT) then
      util_auto_show_hide_form_lock(FORM_IDENT)
    end
  elseif util_is_lockform_visible(FORM_IDENT) then
    util_auto_show_hide_form_lock(FORM_IDENT)
  end
end
function on_exit_click(btn)
  nx_execute("main", "wait_exit_game")
end
