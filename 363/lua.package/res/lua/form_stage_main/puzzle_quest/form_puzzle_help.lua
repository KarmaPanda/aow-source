function main_form_init(self)
  self.Fixed = true
  local gui = nx_value("gui")
  self.Left = gui.Desktop.Width / 2 - self.Width / 2
  self.Top = gui.Desktop.Height / 2 - self.Height / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_exit_click(self)
  local form = self.Parent
  form:Close()
end
