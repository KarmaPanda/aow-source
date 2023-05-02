require("util_functions")
require("util_gui")
require("custom_sender")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  nx_destroy(self)
end
function ok_btn_click(btn)
  nx_execute("form_stage_main\\form_match\\form_match_sanmeng", "open_form_guide")
  btn.ParentForm:Close()
end
