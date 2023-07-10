require("form_stage_main\\form_charge_shop\\shop_util")
require("form_stage_main\\switch\\url_define")
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_2_click(btn)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
  local form = btn.ParentForm
  form:Close()
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  form:Close()
end
