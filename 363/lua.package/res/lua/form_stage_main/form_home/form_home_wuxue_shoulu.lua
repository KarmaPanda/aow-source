require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\client_custom_define")
local CLIENT_FURNITURE_GUIDE_WUXUE = 25
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
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
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), nx_int(CLIENT_FURNITURE_GUIDE_WUXUE))
  form:Close()
end
function show_form()
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form:ShowModal()
end
