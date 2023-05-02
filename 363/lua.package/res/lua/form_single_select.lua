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
function on_main_form_close(self)
end
function ok_btn_click(self)
  local form = self.ParentForm
  form:Close()
  nx_gen_event(form, "confirm_return", "ok")
  nx_destroy(form)
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
  nx_gen_event(form, "confirm_return", "cancel")
  nx_destroy(form)
end
