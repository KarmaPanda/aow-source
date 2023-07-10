require("utils")
require("util_gui")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local form = util_get_form("form_stage_main\\form_wuxue\\form_faculty_exchange", false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_yes_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "confirm_return", "ok")
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function on_btn_no_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, "confirm_return", "cancel")
  form:Close()
  return 1
end
