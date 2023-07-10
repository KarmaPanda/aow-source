require("util_gui")
require("util_functions")
require("util_vip")
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_online_click(btn)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function on_btn_gold_click(btn)
  nx_execute("form_stage_main\\form_vip_info", "pay_by_golden")
end
