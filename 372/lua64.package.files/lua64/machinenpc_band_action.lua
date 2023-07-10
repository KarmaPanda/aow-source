require("const_define")
require("player_state\\state_const")
require("player_state\\logic_const")
require("role_composite")
require("share\\npc_type_define")
function machine_spring_start(npc, player, band_point, npc_action, player_action)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_visual) then
    return false
  end
  if not nx_is_valid(game_client) then
    return false
  end
  while true do
    nx_pause(0)
    if game_client.ready then
      break
    end
  end
  local client_player_obj = game_client:GetSceneObj(nx_string(player))
  local client_machine_obj = game_client:GetSceneObj(nx_string(npc))
  local visual_player_obj = game_visual:GetSceneObj(nx_string(player))
  local visual_machine_obj = game_visual:GetSceneObj(nx_string(npc))
  while true do
    nx_pause(0)
    if not nx_is_valid(game_visual) then
      return false
    end
    if not nx_is_valid(game_client) then
      return false
    end
    if not nx_is_valid(visual_player_obj) or not nx_is_valid(visual_machine_obj) then
      return
    end
    if game_visual:QueryRoleCreateFinish(visual_player_obj) and game_visual:QueryRoleCreateFinish(visual_machine_obj) then
      break
    end
  end
  local npc_config = client_machine_obj:QueryProp("ConfigID")
  visual_machine_obj:LinkToPoint(nx_string(npc_config), nx_string(band_point), visual_player_obj)
  visual_machine_obj.linkfinish = 1
  visual_machine_obj:SetLinkPosition(nx_string(npc_config), 0, 0, 0)
  local scale = client_machine_obj:QueryProp("Scale")
  if scale ~= 0 and scale ~= "" and scale ~= nil then
    local scalelist = util_split_string(scale, ",")
    local scale_x = nx_float(scalelist[1])
    local scale_y = nx_float(scalelist[2])
    local scale_z = nx_float(scalelist[3])
    if 0 < nx_number(scale_x) and 0 < nx_number(scale_y) and 0 < nx_number(scale_z) then
      local rescale_x = 1 / scale_x
      local rescale_y = 1 / scale_y
      local rescale_z = 1 / scale_z
      visual_machine_obj:SetLinkScale(nx_string(npc_config), rescale_x, rescale_y, rescale_z)
    end
  end
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) then
    action_module:ChangeState(visual_machine_obj, nx_string(npc_action), true)
    action_module:ChangeState(visual_player_obj, nx_string(player_action), true)
  end
  local scene
  if nx_is_valid(visual_player_obj) and nx_find_custom(visual_player_obj, "scene") then
    scene = visual_player_obj.scene
    if not nx_is_valid(scene) then
      scene = nx_value("game_scene")
    end
  else
    scene = nx_value("game_scene")
  end
  local terrain
  if nx_is_valid(scene) and nx_find_custom(scene, "terrain") then
    terrain = scene.terrain
    if not nx_is_valid(scene.terrain) then
      terrain = nx_value("terrain")
    end
  else
    terrain = nx_value("terrain")
  end
  if not nx_is_valid(terrain) then
    return
  end
  terrain:RemoveVisual(visual_player_obj)
  if nx_is_valid(visual_player_obj) then
    visual_player_obj.Visible = true
  end
end
function machine_spring_end(npc, player, band_point, npc_action, player_action)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player_obj = game_client:GetSceneObj(nx_string(player))
  local client_machine_obj = game_client:GetSceneObj(nx_string(npc))
  local visual_player_obj = game_visual:GetSceneObj(nx_string(player))
  local visual_machine_obj = game_visual:GetSceneObj(nx_string(npc))
  if not nx_is_valid(visual_player_obj) or not nx_is_valid(visual_machine_obj) then
    return
  end
  local npc_config = client_machine_obj:QueryProp("ConfigID")
  visual_machine_obj:UnLink(nx_string(npc_config), false)
  visual_machine_obj.linkfinish = 0
  local scene = visual_player_obj.scene
  local terrain = scene.terrain
  local dest_x = visual_player_obj.PositionX
  local dest_y = visual_player_obj.PositionY
  local dest_z = visual_player_obj.PositionZ
  game_visual:SetRoleMoveDestX(visual_player_obj, dest_x)
  game_visual:SetRoleMoveDestY(visual_player_obj, dest_y)
  game_visual:SetRoleMoveDestZ(visual_player_obj, dest_z)
  visual_player_obj.move_dest_orient = client_player_obj.DestOrient
  visual_player_obj:SetPosition(dest_x, dest_y, dest_z)
  terrain:AddVisualRole("", visual_player_obj)
  visual_player_obj:SetAngle(0, visual_player_obj.move_dest_orient, 0)
  local scene_obj = nx_value("scene_obj")
  scene_obj:LocatePlayer(visual_player_obj, dest_x, dest_y, dest_z, client_player_obj.DestOrient)
  if game_client:IsPlayer(player) then
    game_visual:SwitchPlayerState(visual_player_obj, "static", STATE_STATIC_INDEX)
  else
    game_visual:SwitchPlayerState(visual_player_obj, "be_stop", STATE_BE_STOP_INDEX)
  end
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) then
    action_module:ChangeState(visual_machine_obj, nx_string(npc_action), true)
  end
end
