require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_clone\\define")
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
