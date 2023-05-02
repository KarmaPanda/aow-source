require("util_gui")
require("util_functions")
local g_form_name = "form_stage_main\\form_charge_shop\\form_virtual_tip"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  local mgr = nx_value("CapitalModule")
  local s = nx_widestr("")
  if nx_is_valid(mgr) then
    s = mgr:GetFormatCapitalHtml(3, mgr:GetCapital(3))
  end
  form.mltbox_current.HtmlText = s
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
