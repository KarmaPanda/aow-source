function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function yes_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "yes_no_cancel_return", "yes")
  nx_destroy(form)
  return 1
end
function no_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "yes_no_cancel_return", "no")
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "yes_no_cancel_return", "cancel")
  nx_destroy(form)
  return 1
end
