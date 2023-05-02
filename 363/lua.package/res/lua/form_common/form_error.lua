function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.Default = self.ok_btn
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "error_return", "ok")
  nx_destroy(form)
  return 1
end
