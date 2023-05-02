require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_netbar_changed(form)
  set_netbar_info(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
