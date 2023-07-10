local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function on_main_form_init(form)
end
function on_main_form_open(form)
  local gui = nx_value("gui")
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(form)
  nx_msgbox("OK")
end
function change_form_size(form)
  local gui = nx_value("gui")
end
