require("util_gui")
require("util_functions")
require("playsnail\\playsnail_define")
local FORM_PLAYSNAIL_MAIN = "playsnail\\form_playsnail_main"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size()
  nx_execute(nx_current(), "open_web_view", form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function change_form_size(form)
  local form = util_get_form(FORM_PLAYSNAIL_MAIN, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
end
function close_web_view()
  local form = util_get_form(FORM_PLAYSNAIL_MAIN, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_playsnail_main_form()
  local form = util_get_form(FORM_PLAYSNAIL_MAIN, false)
  if nx_is_valid(form) then
    form:Close()
    return 0
  end
  local form = util_get_form(FORM_PLAYSNAIL_MAIN, true, false)
  if nx_is_valid(form) then
    util_show_form(FORM_PLAYSNAIL_MAIN, true)
  end
end
function open_web_view(form)
  local strMsg = nx_execute("playsnail\\playsnail_common", "FormatMainMsg")
  form.web_help:Refresh()
  form.web_help:NavigatePost(nx_widestr(strMsg), nx_widestr(""))
  form.lbl_2.Text = nx_execute("playsnail\\playsnail_common", "GetCfgItem", "playsnail", "Domain")
end
function on_btn_close_click(btn)
  close_web_view()
end
