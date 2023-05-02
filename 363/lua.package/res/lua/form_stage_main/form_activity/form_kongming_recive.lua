require("share\\client_custom_define")
require("util_functions")
require("util_gui")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
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
  local gui = nx_value("gui")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LANTERN), nx_int(4))
  form:Close()
end
function on_server_msg(...)
  util_show_form("form_stage_main\\form_activity\\form_kongming_recive", true)
  local form = nx_value("form_stage_main\\form_activity\\form_kongming_recive")
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_context.HtmlText = util_text(arg[1])
  local select_form = nx_value("form_stage_main\\form_activity\\form_kongming_send")
  if nx_is_valid(select_form) then
    select_form:Close()
  end
end
