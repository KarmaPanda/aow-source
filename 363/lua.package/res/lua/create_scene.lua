require("scene")
require("util_functions")
function add_create_private_to_scene(scene)
end
function load_create_scene(scene, scene_path)
  local world = nx_value("world")
  apply_camera(scene, scene_path)
  load_scene(scene, scene_path, true)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  apply_effect(scene, scene_path)
  nx_pause(0.1)
  while nx_is_valid(terrain) and not terrain.LoadFinish do
    nx_pause(0.2)
  end
  terrain.WaterVisible = true
  terrain.GroundVisible = true
  terrain.VisualVisible = true
  terrain.HelperVisible = true
  terrain:RefreshGround()
  terrain:RefreshVisual()
  terrain:RefreshGrass()
  terrain:RefreshWater()
  local game_config = nx_value("game_config")
  nx_execute("game_config", "set_logic_sound_enable", scene, 0, game_config.area_music_enable)
end
function load_apply_scene_effect(scene, scene_path)
  apply_effect(scene, scene_path)
  local world = nx_value("world")
  apply_camera(scene, scene_path)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  while nx_is_valid(terrain) and not terrain.LoadFinish do
    nx_pause(0.2)
  end
  terrain.WaterVisible = true
  terrain.GroundVisible = true
  terrain.VisualVisible = true
  terrain.HelperVisible = true
  terrain:RefreshGround()
  terrain:RefreshVisual()
  terrain:RefreshGrass()
  terrain:RefreshWater()
end
function clear_create_scene_private(scene)
  if nx_find_custom(scene, "login_control") then
    scene:Delete(scene.login_control)
    local camera = scene.camera
    if nx_is_valid(camera) then
      camera.fov_angle = 51.8
      camera.fov_wide_angle = 68
    end
  end
end
function set_high_water_quality(scene, value)
  nx_execute("game_config", "set_water_quality", scene, value)
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain.GroundEnvMap = value
    terrain.VisualEnvMap = value
  end
end
function set_low_water_quality(scene)
  nx_execute("game_config", "set_water_quality", scene, 1)
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain.GroundEnvMap = 1
    terrain.VisualEnvMap = 0
    local water_table = terrain:GetWaterList()
    for i = 1, table.getn(water_table) do
      water_table[i].CubeMapStatic = true
    end
  end
end
function set_device_level_quality(scene, device_level)
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain.LodRadius = 200
    terrain.GrassRadius = 100
    terrain.AlphaFadeRadius = 300
    terrain.AlphaHideRadius = 350
    terrain.ClipRadiusNear = 400
    terrain.ClipRadiusFar = 600
  end
  if 4 <= device_level then
    nx_execute("game_config", "set_prelight_enable", scene, true)
    nx_execute("game_config", "set_anisotropic", scene, 16)
    nx_execute("game_config", "set_shadow_quality", scene, 2)
    nx_execute("game_config", "set_filter_enable", scene, true)
    nx_execute("game_config", "set_bloom_enable", scene, true)
    nx_execute("game_config", "set_volume_lighting_enable", scene, true)
    set_high_water_quality(scene, 2)
    nx_execute("game_config", "set_hdr_enable", scene, true)
    nx_execute("game_config", "set_screen_blur_enable", scene, true)
    nx_execute("game_config", "set_ssao_enable", scene, true)
  elseif 3 <= device_level then
    nx_execute("game_config", "set_anisotropic", scene, 16)
    nx_execute("game_config", "set_shadow_quality", scene, 1)
    nx_execute("game_config", "set_filter_enable", scene, true)
    nx_execute("game_config", "set_bloom_enable", scene, true)
    nx_execute("game_config", "set_volume_lighting_enable", scene, false)
    set_high_water_quality(scene, 2)
    nx_execute("game_config", "set_hdr_enable", scene, true)
    nx_execute("game_config", "set_screen_blur_enable", scene, true)
  elseif 2 <= device_level then
    nx_execute("game_config", "set_anisotropic", scene, 16)
    nx_execute("game_config", "set_filter_enable", scene, true)
    nx_execute("game_config", "set_bloom_enable", scene, true)
    nx_execute("game_config", "set_volume_lighting_enable", scene, true)
    set_high_water_quality(scene, 1)
  elseif 1 <= device_level then
    nx_execute("game_config", "set_anisotropic", scene, 4)
    set_low_water_quality(scene)
    if nx_is_valid(terrain) then
      terrain.GrassLod = 0.5
    end
  else
    nx_execute("game_config", "set_anisotropic", scene, 0)
    nx_execute("game_config", "set_water_quality", scene, 0)
    if nx_is_valid(terrain) then
      terrain.GrassRadius = 50
      terrain.GrassLod = 0.25
    end
  end
  scene.EnableEarlyZ = true
  scene.FarClipDistance = 600
  if nx_is_valid(terrain) then
    terrain:RefreshGrass()
    terrain:RefreshWater()
  end
end
function apply_camera(scene, scene_path)
  load_scene_camera(scene, nx_resource_path() .. scene_path .. "\\editor.ini", true)
end
function apply_effect(scene, scene_path)
  nx_execute("terrain\\terrain", "load_scene_screeneffect", scene, nx_resource_path() .. scene_path, false)
  local terrain = scene.terrain
  local water_table = terrain:GetWaterList()
  for _, water in pairs(water_table) do
    water.ReflectionRatio = 1
    water:UpdateSeaData()
  end
  terrain.WaterWave = false
  terrain.LodRadius = 2000
  terrain.GrassRadius = 1000
  terrain.GrassLod = 1
  local world = nx_value("world")
end
function init_create_control(login_control)
  login_control.MaxDistance = 10
  login_control.MinDistance = 1
  nx_callback(login_control, "on_mouse_move", "create_control_mouse_move")
  nx_callback(login_control, "on_left_down", "create_control_left_down")
end
function create_control_mouse_move(self, mouse_x, mouse_y)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or nx_is_valid(gui.Capture) then
    return 0
  end
  local pick_model = test_click_model(mouse_x, mouse_y)
  if not nx_is_valid(pick_model) then
    return 0
  end
  return 1
end
function create_control_left_down(self, mouse_x, mouse_y)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or nx_is_valid(gui.Capture) then
    return 0
  end
  local visual_npc = test_click_model(mouse_x, mouse_y)
  if not nx_is_valid(visual_npc) then
    return 0
  end
  local npc_pos_x = visual_npc.PositionX
  local npc_pos_y = visual_npc.PositionY
  local npc_pos_z = visual_npc.PositionZ
  local npc_angle_x = visual_npc.AngleX
  local npc_angle_y = visual_npc.AngleY
  local npc_angle_z = visual_npc.AngleZ
  local TALK_CAMERA_DISTANCE = 3
  local camera_pos_x = npc_pos_x + TALK_CAMERA_DISTANCE * math.sin(npc_angle_y)
  local camera_pos_z = npc_pos_z + TALK_CAMERA_DISTANCE * math.cos(npc_angle_y)
  local camera_pos_y = npc_pos_y + 1.8
  local camera_angle_x = -1 * npc_angle_x
  local camera_angle_y = npc_angle_y + math.pi
  local camera_angle_z = -1 * npc_angle_z
  local camera = self.Camera
  camera:SetAngle(camera_angle_x, camera_angle_y, camera_angle_z)
  camera:SetPosition(camera_pos_x, camera_pos_y, camera_pos_z)
  nx_execute("form_stage_create\\form_select_book", "set_selected_npc", visual_npc)
  return 1
end
function test_click_model(mouse_x, mouse_y)
  if mouse_x == nil or mouse_y == nil then
    return
  end
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return nx_null()
  end
  terrain:SetTraceMask("Role", false)
  terrain:SetTraceMask("Model", true)
  terrain:SetTraceMask("Ground", true)
  terrain:SetTraceMask("Particle", true)
  terrain:SetTraceMask("Light", true)
  terrain:SetTraceMask("Sound", true)
  terrain:SetTraceMask("Trigger", true)
  terrain:SetTraceMask("Helper", true)
  terrain:SetTraceMask("EffectModel", false)
  terrain:SetTraceMask("Through", true)
  local pick_id = terrain:PickVisual(mouse_x, mouse_y, 100)
  terrain:SetTraceMask("Ground", false)
  terrain:SetTraceMask("Role", true)
  terrain:SetTraceMask("Model", false)
  terrain:SetTraceMask("EffectModel", true)
  return pick_id
end
function create_game_control(scene)
  if not nx_find_custom(scene, "game_control") or not nx_is_valid(scene.game_control) then
    local game_control = scene:Create("GameControl")
    nx_bind_script(game_control, "game_control", "game_control_init")
    game_control.GameVisual = nx_value("game_visual")
    game_control:Load()
    scene:AddObject(game_control, 0)
    scene.game_control = game_control
  end
  return scene.game_control
end
function clear_game_control(scene)
  if nx_find_custom(scene, "game_control") and nx_is_valid(scene.game_control) then
    local game_control = scene.game_control
    scene:RemoveObject(game_control)
    scene:Delete(game_control)
  end
end
