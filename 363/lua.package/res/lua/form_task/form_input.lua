function main_form_init(self)
  self.Fixed = false
  self.allow_empty = true
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.input_edit
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  local name = nx_string(form.input_edit.Text)
  if name == "" and not form.allow_empty then
    return 0
  end
  form:Close()
  nx_gen_event(form, "form_input_return", "ok", name)
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "form_input_return", "cancel")
  nx_destroy(form)
  return 1
end
