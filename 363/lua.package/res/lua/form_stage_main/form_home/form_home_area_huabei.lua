require("util_functions")
require("util_gui")
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  nx_execute("form_stage_main\\form_home\\form_home_world", "enable_scene_btn", form.groupbox_1)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_world", "btn_open_scene", nx_string(btn.Name))
end
