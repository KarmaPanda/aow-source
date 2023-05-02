function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.name_edit
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function ok_btn_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "input_search_return", "ok", nx_string(form.name_edit.Text), nx_string(form.reason_edit.Text))
  form:Close()
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "input_search_return", "cancel")
  form:Close()
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_reason_edit_get_focus(edit)
  local form = edit.ParentForm
  local gui = nx_value("gui")
  local defaultText = gui.TextManager:GetText("ui_input_interact_info")
  if edit.Text == defaultText then
    edit.Text = ""
  end
end
