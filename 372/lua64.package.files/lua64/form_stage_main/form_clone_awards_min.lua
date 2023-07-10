function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  change_form_size(self)
end
function change_form_size(self)
  if not nx_is_valid(self) then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  if not nx_is_valid(form) then
    return
  end
  self.AbsLeft = form.AbsLeft - 10
  self.AbsTop = form.AbsTop + self.Height
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_1_click(self)
  local form = nx_value("form_stage_main\\form_clone_awards")
  if nx_is_valid(form) then
    form.Visible = true
  end
  local Parent_form = self.Parent
  Parent_form:Close()
end
