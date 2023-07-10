require("player_state\\state_const")
require("player_state\\logic_const")
function emit_player_input(role, input, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual.Terrain) then
    game_visual:EmitPlayerInput(role, input, unpack(arg))
  end
end
