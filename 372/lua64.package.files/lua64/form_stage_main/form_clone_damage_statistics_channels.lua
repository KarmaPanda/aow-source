function on_main_form_init(self)
end
function on_main_form_open(self)
  local form_buttons = nx_value("form_stage_main\\form_clone_damage_statistics_buttons")
  if not nx_is_valid(form_buttons) then
    return
  end
  self.Left = form_buttons.Left + form_buttons.Width
  self.Top = form_buttons.Top + form_buttons.btn_2.Height
  local gui = nx_value("gui")
  if not nx_is_valid then
    return
  end
  self.Fixed = false
  self.Visible = true
end
function on_main_form_close(self)
  self.Visible = false
end
