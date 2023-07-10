require("util_gui")
require("util_functions")
local FORM_BUY_CHARM = "form_stage_main\\form_sweet_employ\\form_buy_charm"
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_pos(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_buy_click(btn)
  util_show_form(FORM_BUY_CHARM, true)
end
