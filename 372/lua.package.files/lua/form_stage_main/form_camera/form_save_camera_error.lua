function main_form_init(self)
  self.Fixed = false
  self.errorInfo = nil
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.Default = self.ok_btn
  if self.errorInfo then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    gui.TextManager:Format_SetIDName(self.errorInfo)
    local info = gui.TextManager:Format_GetText()
    self.info_label.Text = info
    local width = self.info_label.TextWidth
    self.info_label.Left = (self.Width - width) / 2
  end
  return 1
end
function ok_btn_click(btn)
  local form = btn.Parent
  form:Close()
  nx_gen_event(form, "save_camera_error_return", "ok")
  nx_destroy(form)
  return 1
end
