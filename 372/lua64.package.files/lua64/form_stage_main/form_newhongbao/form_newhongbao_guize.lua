require("const_define")
require("util_functions")
require("util_gui")
require("tips_data")
require("role_composite")
require("share\\client_custom_define")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
