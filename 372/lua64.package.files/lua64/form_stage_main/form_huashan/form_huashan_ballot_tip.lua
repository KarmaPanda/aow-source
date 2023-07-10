require("util_functions")
require("util_gui")
local select
function main_form_init(self)
  self.Fixed = false
  select = false
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  if select then
    nx_gen_event(self, "ballot_result", "yes")
  else
    nx_gen_event(self, "ballot_result", "no")
  end
  select = false
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_click(btn)
  local form = btn.ParentForm
  if btn.Name == nx_string("ok_btn") then
    select = true
  end
  form:Close()
end
