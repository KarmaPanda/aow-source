require("util_functions")
require("form_stage_main\\form_origin\\form_origin_define")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.lbl_n1_1.o_id = 41
  form.main_type = ORIGIN_TYPE_MENPAI
  local origin_manager = nx_value("OriginManager")
  if nx_is_valid(origin_manager) then
    local line = origin_manager:GetOriginLine(form.lbl_n1_1.o_id)
    nx_execute(FORM_ORIGIN_LINE, "refresh_origin_name", form, origin_manager, "lbl_n1_", line, 1)
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_click(btn)
  nx_execute(FORM_ORIGIN_LINE, "on_btn_click", btn)
end
