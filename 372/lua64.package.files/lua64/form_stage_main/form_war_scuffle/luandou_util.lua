require("util_gui")
require("util_functions")
require("custom_sender")
local luandou_player_prop_player_state = "LuanDouPlayerState"
function request_quit_luandou()
  custom_luandou(nx_int(102))
end
function get_player_luandou_state()
  local player = get_player()
  if not nx_is_valid(player) then
    return nx_int(0)
  end
  if not player:FindProp(luandou_player_prop_player_state) then
    return nx_int(0)
  end
  return nx_int(player:QueryProp(luandou_player_prop_player_state))
end
function get_player_name()
  local player = get_player()
  if not nx_is_valid(player) then
    return nx_widestr("")
  end
  return nx_widestr(player:QueryProp("Name"))
end
function is_in_luandou_scene()
  return get_player_luandou_state() > nx_int(0)
end
function show_battle_begin_animation(animation_name)
  if animation_name == nil or nx_string(animation_name) == nx_string("") then
    animation_name = nx_string("jhdld_zbq")
  end
  show_animation(animation_name)
end
function show_animation(ani_name)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = ani_name
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = gui.Width / 2 - 125
  animation.Top = gui.Height / 4
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "end_animation")
  animation:Play()
end
function end_animation(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function show_add_score_effect(add_score)
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local SpriteManager = nx_value("SpriteManager")
  if not nx_is_valid(SpriteManager) then
    return
  end
  local score_text = nx_string("")
  if nx_int(add_score) > nx_int(0) then
    score_text = nx_string("+")
  elseif nx_int(add_score) < nx_int(0) then
    score_text = nx_string("-")
  end
  score_text = score_text .. nx_string(add_score)
  SpriteManager:ShowBallFormModelPos("self_Addchaoswar", score_text, player.Ident, "")
end
function confirm_quit()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = util_format_string("sys_activity_918_05")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    request_quit_luandou()
  else
  end
end
