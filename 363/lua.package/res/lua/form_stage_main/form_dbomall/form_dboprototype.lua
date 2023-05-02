require("utils")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_info_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.groupbox_help.Visible = not form.groupbox_help.Visible
  end
end
