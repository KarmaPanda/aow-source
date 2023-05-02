function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.name_edit
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "input_search_return", "ok", nx_string(form.name_edit.Text))
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "input_search_return", "cancel")
  nx_destroy(form)
  return 1
end
