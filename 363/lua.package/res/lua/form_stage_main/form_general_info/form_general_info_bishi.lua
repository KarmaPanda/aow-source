require("util_gui")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("form_stage_main\\form_general_info\\form_general_info_define")
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local form_match = nx_execute("form_stage_main\\form_match\\form_match", "open_form", nil)
  if nx_is_valid(form_match) then
    form.groupbox_5:Add(form_match)
    form.groupbox_5:ToBack(form_match)
    form_match.Left = 0
    form_match.Top = 0
    form_match:Show()
    form_match.Visible = true
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function show_form(form)
  local form_bishi = nx_value(FORM_BISHI)
  if not nx_is_valid(form_bishi) then
    local form_bishi = nx_execute("util_gui", "util_get_form", FORM_BISHI, true, false)
    if nx_is_valid(form_bishi) then
      form.groupbox_main:Add(form_bishi)
      form.groupbox_main:ToBack(form_bishi)
      form_bishi.Left = 0
      form_bishi.Top = 0
    end
  else
    form_bishi:Show()
    form_bishi.Visible = true
  end
end
