require("util_gui")
require("util_functions")
local g_form_keep = "form_stage_main\\form_charge_shop\\form_charge_keep"
function main_form_init(form)
  form.Fixed = true
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = gui.Desktop.Width - form.Width
  form.Top = (gui.Desktop.Height - form.Height) * 2 / 10
  dove_pass(form, gui)
end
function dove_pass(form, gui)
  local top_start = form.Top
  local top_end = (gui.Desktop.Height - form.Height) * 5 / 10 - form.Height
  local use_time = 1
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("ShopKeepMove", form)
    common_execute:AddExecute("ShopKeepMove", form, nx_float(0), nx_float(top_start), nx_float(top_end), nx_float(use_time))
  end
end
function on_btn_show_click(btn)
  local form = btn.ParentForm
  util_show_form(g_form_keep, true)
  form:Close()
end
