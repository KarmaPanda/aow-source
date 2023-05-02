require("util_gui")
require("util_functions")
function on_main_form_init(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.no_need_motion_alpha = true
end
function on_main_form_open(form)
  form.Fixed = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_reg_btn_click(btn)
  nx_execute("form_stage_main\\form_enthrall\\enthrall", "show_reg")
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
