require("util_gui")
require("util_functions")
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.LimitInScreen = true
end
function on_main_form_open(form)
  form.type = nil
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_main_form_get_capture(form)
end
