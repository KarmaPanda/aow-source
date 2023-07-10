require("util_gui")
require("util_functions")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Top = gui.Desktop.Height / 2 - 200
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
function on_btn_tips_click(btn)
  local form = btn.ParentForm
  form:Close()
  util_auto_show_hide_form("form_stage_main\\form_stall\\form_stall_main")
end
