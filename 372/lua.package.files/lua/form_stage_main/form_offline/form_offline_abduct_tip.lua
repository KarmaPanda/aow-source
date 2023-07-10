require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
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
  GiveupAbduct()
end
function ShowForm()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_abduct_tip", true, false)
  form:Show()
end
function HideForm()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_abduct_tip", false, false)
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
  if not CanGiveupAbduct(client_player) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_off_giveupadbuct")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_GIVEUP_ABDUCT))
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_abduct_tip", false, false)
  if nx_is_valid(form) and form.Visible then
    form:Close()
  end
end
function CanGiveupAbduct(player)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return false
  end
  if not player:FindProp("IsAbductor") then
    return false
  end
  if nx_int(player:QueryProp("IsAbductor")) == nx_int(0) then
    return false
  end
  if player:FindProp("LogicState") then
    local logic_state = player:QueryProp("LogicState")
    if nx_int(logic_state) == nx_int(LS_FIGHTING) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("80022"), 2)
      return false
    end
    if nx_int(logic_state) == nx_int(LS_SERIOUS_INJURY) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("80028"), 2)
      return false
    end
  end
  return true
end
