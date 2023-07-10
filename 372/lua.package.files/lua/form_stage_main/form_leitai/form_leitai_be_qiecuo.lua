function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "confirm_return", "ok")
  form:Close()
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "confirm_return", "cancel")
  if nx_is_valid(form) then
    form:Close()
  end
end
