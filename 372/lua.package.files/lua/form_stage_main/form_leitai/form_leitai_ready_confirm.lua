require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_btn_ok_click(self)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_READY_CONFIRMED))
  local form = self.ParentForm
  form:Close()
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
end
