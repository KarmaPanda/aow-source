require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_school_war\\form_newschool_gmp_wabao"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
end
function on_main_form_close(self)
end
function open_heath_form(value)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  refresh(form, value)
  form.Visible = true
  form:Show()
end
function close_heath_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function set_heath_value(value)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  refresh(form, value)
end
function add_heath_value(value)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.heathvalue = nx_int(form.heathvalue) + nx_int(value)
  refresh(form, form.heathvalue)
end
function refresh(form, value)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_value.Text = gui.TextManager:GetFormatText("ui_gmpwb_healthpoint", nx_int(value))
  form.heathvalue = value
end
