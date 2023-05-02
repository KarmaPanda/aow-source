require("form_stage_main\\switch\\url_define")
require("util_functions")
require("util_gui")
function main_form_init(form)
  form.Fixed = true
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_openweb_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(URL_TYPE_WLDH_100WAN)
end
