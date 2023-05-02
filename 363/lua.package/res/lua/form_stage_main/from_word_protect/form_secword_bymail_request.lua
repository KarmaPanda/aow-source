require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function on_main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), 12)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_form()
  local form = nx_value("form_stage_main\\from_word_protect\\form_secword_bymail_confirm")
  if nx_is_valid(form) then
    form:Close()
  end
  local form = nx_value("form_stage_main\\from_word_protect\\form_secword_bymail_request")
  if not nx_is_valid(form) then
    util_show_form("form_stage_main\\from_word_protect\\form_secword_bymail_request", true)
  end
end
