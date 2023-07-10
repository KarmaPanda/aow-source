require("util_gui")
require("util_functions")
require("custom_sender")
function main_form_init(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
end
