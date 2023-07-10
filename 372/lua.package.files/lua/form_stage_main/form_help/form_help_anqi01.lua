function on_main_form_open(self)
  on_gui_size_change(self)
end
function on_main_form_close(self)
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  form.Visible = false
  form:Close()
end
function on_gui_size_change(form)
  if not nx_is_valid(form) then
    form = nx_value(nx_current())
  end
  if not nx_is_valid(form) then
    return 1
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
