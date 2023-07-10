function is_action_exists(role, real_action)
  local actor_role = role:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    actor_role = role
  end
  if actor_role:GetActionFrame(real_action) <= 0 then
    return false
  end
  return true
end
function get_player_state(role)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(role)
  local game_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(game_obj) then
    return ""
  end
  local state = game_obj:QueryProp("State")
  return state
end
