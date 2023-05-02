function start_action(player, npc, player_action, npc_action)
  local game_client = nx_value("game_client")
  local client_player_obj = game_client:GetSceneObj(nx_string(player))
  local client_npc_obj = game_client:GetSceneObj(nx_string(npc))
  local game_visual = nx_value("game_visual")
  local visual_player_obj = game_visual:GetSceneObj(client_player_obj.Ident)
  local visual_npc_obj = game_visual:GetSceneObj(client_npc_obj.Ident)
  local scene = visual_player_obj.scene
  local terrain = scene.terrain
  local x, y, z = visual_npc_obj:GetNodePosition("Model::E_S_P01")
  local angleX = visual_npc_obj.AngleX
  local angleY = visual_npc_obj.AngleY
  local angleZ = visual_npc_obj.AngleZ
  local angle_x, angle_y, angle_z = visual_npc_obj:GetNodeAngle("Model::E_S_P01")
  terrain:RelocateVisual(visual_player_obj, x, y, z)
  visual_player_obj:SetAngle(angleX, angleY, angleZ)
  local action_module = nx_value("action_module")
  action_module:ChangeState(visual_player_obj, player_action)
  action_module:ChangeState(visual_npc_obj, npc_action)
end
function end_action(player, npc)
  local game_client = nx_value("game_client")
  local client_player_obj = game_client:GetSceneObj(nx_string(player))
  local client_npc_obj = game_client:GetSceneObj(nx_string(npc))
  local game_visual = nx_value("game_visual")
  local visual_player_obj = game_visual:GetSceneObj(client_player_obj.Ident)
  local visual_npc_obj = game_visual:GetSceneObj(client_npc_obj.Ident)
  local action_module = nx_value("action_module")
  action_module:ChangeState(visual_player_obj, "stand")
  action_module:ChangeState(visual_npc_obj, "stand")
end
