require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("custom_sender")
function main_form_init(form)
  form.Fixed = false
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
end
function on_btn_begin_click(btn)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_START_OFFLINE_JOB))
  end
end
function on_btn_stop_click(btn)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_OFFLINE_JOB))
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
