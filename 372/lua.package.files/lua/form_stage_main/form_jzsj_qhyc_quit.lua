require("util_gui")
require("util_functions")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Top = gui.Desktop.Height / 2 - 200
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
function on_btn_tips_click(btn)
  Giveup()
end
function ShowForm()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_jzsj_qhyc_quit", true, false)
  form:Show()
end
function HideForm()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_jzsj_qhyc_quit", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function Giveup()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_jzsj_qhyc_giveup")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  nx_execute("custom_sender", "custom_send_jzsj_qhyc", nx_int(0))
end
