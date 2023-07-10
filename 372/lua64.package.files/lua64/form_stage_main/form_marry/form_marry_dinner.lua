require("form_stage_main\\form_marry\\form_marry_util")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.rbtn_type_1.Checked = true
  set_form_pos(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  if form.rbtn_type_1.Checked == true then
    custom_marry(CLIENT_MSG_SUB_MARRY_DINNER_START, DINNER_TYPE_ONLY_FRIEND)
  else
    custom_marry(CLIENT_MSG_SUB_MARRY_DINNER_START, DINNER_TYPE_ALL_PERPLE)
  end
  form:Close()
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
end
function show_data()
  local form = util_get_form(FORM_MARRY_DINNER, true)
  if not nx_is_valid(form) then
    return 0
  end
  util_show_form(FORM_MARRY_DINNER, true)
end
