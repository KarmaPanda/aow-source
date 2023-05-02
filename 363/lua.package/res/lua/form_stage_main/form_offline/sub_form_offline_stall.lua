require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_offline\\offline_define")
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_quit_click(btn)
  nx_execute("main", "wait_exit_game")
end
function on_btn_stall_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_main", true, false)
  dialog.IsOnline = false
  dialog:Show()
end
