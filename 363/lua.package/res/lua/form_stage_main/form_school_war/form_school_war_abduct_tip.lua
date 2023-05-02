require("util_gui")
require("util_functions")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Top = gui.Desktop.Height / 2 - 100
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
function on_btn_tips_click(btn)
  GiveupAbduct()
end
function ShowForm()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_school_war\\form_school_war_abduct_tip", true, false)
  form:Show()
end
function HideForm()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_school_war\\form_school_war_abduct_tip", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function GiveupAbduct()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("CurBindState") then
    return
  end
  if client_player:QueryProp("CurBindState") ~= 3 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_schoolfight_bind_1")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 11)
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_abduct_tip", false, false)
  if nx_is_valid(form) and form.Visible then
    form:Close()
  end
end
