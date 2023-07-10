require("util_functions")
require("util_gui")
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) * 4 / 5
  form.Top = (gui.Height - form.Height) * 2 / 5
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ready_click(btn)
  local taolu_form = util_get_form("form_stage_main\\form_match\\form_taolu_confirm_new", false)
  if nx_is_valid(taolu_form) then
    return
  end
  nx_execute("custom_sender", "custom_egwar_trans", nx_number(10))
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
