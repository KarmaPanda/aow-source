require("util_gui")
require("game_object")
function log(info)
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:AddChatInfoEx(nx_widestr(info), 11, false)
  end
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.ok_btn
  return 1
end
function on_main_form_close(self)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  nx_gen_event(form, "form_guild_depot_putitemconfirm_return", "cancel")
  nx_destroy(form)
end
function ok_btn_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  nx_gen_event(form, "form_guild_depot_putitemconfirm_return", "ok")
  nx_destroy(form)
end
