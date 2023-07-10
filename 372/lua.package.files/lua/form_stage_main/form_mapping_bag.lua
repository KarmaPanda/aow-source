require("util_gui")
local FORM_PREBAG = "form_stage_main\\form_prebag"
local FORM_PRENEWBAG = "form_stage_main\\form_prenewbag"
function on_main_form_open(self)
  local gui = nx_value("gui")
  local form_pre_bag = nx_create("form_pre_bag")
  if nx_is_valid(form_pre_bag) then
    nx_set_value("formprebag", form_pre_bag)
    form_pre_bag:LoadResouce()
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.Fixed = false
  load_subform(self)
  self:ToFront(self.btn_help)
  self:ToFront(self.btn_1)
  nx_execute("util_gui", "ui_show_attached_form", self)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_main_form_close(self)
  ui_destroy_attached_form(form)
  local form_pre_bag = nx_value("formprebag")
  if nx_is_valid(form_pre_bag) then
    nx_destroy(form_pre_bag)
  end
  local form_prebag = nx_value(FORM_PREBAG)
  if nx_is_valid(form_prebag) then
    nx_destroy(form_prebag)
  end
  local form_prenewbag = nx_value(FORM_PRENEWBAG)
  if nx_is_valid(form_prenewbag) then
    nx_destroy(form_prenewbag)
  end
  nx_destroy(self)
end
function load_subform(form)
  if not nx_is_valid(form) then
    return
  end
  local form_prebag = nx_execute("util_gui", "util_get_form", FORM_PREBAG, true, false)
  local is_load = form:Add(form_prebag)
  if is_load == true then
    form_prebag.Left = 2
    form_prebag.Top = 15
  end
  form_prebag.Visible = true
  local form_prenewbag = nx_execute("util_gui", "util_get_form", FORM_PRENEWBAG, true, false)
  is_load = form:Add(form_prenewbag)
  if is_load == true then
    form_prenewbag.Left = 436
    form_prenewbag.Top = 15
  end
  form_prenewbag.Visible = true
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
