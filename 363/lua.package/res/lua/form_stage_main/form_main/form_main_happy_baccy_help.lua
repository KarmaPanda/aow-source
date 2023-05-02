require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\url_define")
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  open_web_view(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_web_view(form)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local url = switch_manager:GetUrl(URL_TYPE_HAPPY_BACCY)
  form.WebView_happy_baccy.Fixed = false
  form.WebView_happy_baccy.Url = nx_widestr(url)
  form.WebView_happy_baccy:Refresh()
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
