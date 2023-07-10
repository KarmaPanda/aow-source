require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\state_const")
function change_form_size()
end
function is_ride()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("Mount") then
    local mount = client_player:QueryProp("Mount")
    if string.len(mount) > 0 then
      return true
    end
  end
  return false
end
function on_ride_spurt(live_time, spurt_speed)
  local game_visual = nx_value("game_visual")
  local role = nx_value("role")
  game_visual:SetRoleMoveDistance(role, 0)
  game_visual:SwitchPlayerState(role, "ride_spurt", nx_int(STATE_RIDE_SPURT_INDEX))
  game_visual:SetRoleMoveDistance(role, spurt_speed * live_time * 0.8 / 1000)
end
function on_btn_spurt_click(self)
end
