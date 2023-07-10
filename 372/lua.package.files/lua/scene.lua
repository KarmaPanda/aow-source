function init_scene(scene)
  scene.sky = nx_null()
  scene.sun = nx_null()
  scene.shadow_uiparam = nx_null()
  scene.weather = nx_null()
  scene.screen = nx_null()
  scene.role_param = nx_null()
  scene.camera = nx_null()
  scene.particle_man = nx_null()
  scene.postprocess_man = nx_null()
  scene.light_man = nx_null()
  scene.ppvolumelighting_uiparam = nx_null()
  scene.ppvolumelighting = nx_null()
  scene.ppscreenrefraction = nx_null()
  scene.ppscreenrefraction_uiparam = nx_null()
  scene.ppscreenrefraction = nx_null()
  scene.pppixelrefraction_uiparam = nx_null()
  scene.pppixelrefraction = nx_null()
  scene.pppixelrefraction_uiparam = nx_null()
  scene.pssm_uiparam = nx_null()
  scene.pssm = nx_null()
  scene.ssao_uiparam = nx_null()
  scene.ssao = nx_null()
  scene.ppdof_uiparam = nx_null()
  scene.ppdof = nx_null()
  scene.ppscreenblur_uiparam = nx_null()
  scene.ppscreenblur = nx_null()
  scene.ppbloom_uiparam = nx_null()
  scene.ppbloom = nx_null()
  scene.pphdr_uiparam = nx_null()
  scene.pphdr = nx_null()
  scene.ppfilter_uiparam = nx_null()
  scene.ppfilter = nx_null()
  scene.ppfilter_dead = nx_null()
  scene.fxaa_uiparam = nx_null()
  scene.fxaa = nx_null()
  scene.ppglow_uiparam = nx_null()
  scene.ppglow = nx_null()
end
function support_physics(world, scene)
  if world.SupportPhysics then
    local device_caps = nx_value("device_caps")
    if device_caps.SupportPhysxCloth and (not nx_find_custom(scene, "physics_scene") or not nx_is_valid(scene.physics_scene)) then
      local PhysicsScene = scene:Create("PhysicsScene")
      scene:AddObject(PhysicsScene, 999)
      scene.physics_scene = PhysicsScene
    end
  end
end
function create_scene(global_scene_name)
  local world = nx_value("world")
  local scene = world:Create("Scene")
  init_scene(scene)
  scene.resource = ""
  nx_set_value(global_scene_name, scene)
  nx_set_value("scene", scene)
  local weather = scene.Weather
  weather.FogEnable = true
  weather.SunGlowColor = "0,255,255,255"
  weather.AmbientColor = "0,150,150,150"
  local sun_height_rad = 0.08333333333333333 * math.pi * 2
  local sun_azimuth_rad = 0.5555555555555556 * math.pi * 2
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  nx_execute("terrain\\weather", "create_weather", scene)
  nx_execute("terrain\\terrain", "create_screen", scene)
  local camera = scene:Create("Camera")
  camera.AllowControl = false
  camera.Fov = 0.18055555555555555 * math.pi * 2
  camera.NearPlane = 0.3
  camera.FarPlane = 1200
  camera:SetPosition(0, 15, 0)
  camera:SetAngle(0, 0, 0)
  camera.allow_wasd = true
  camera.move_speed = 10
  camera.drag_speed = 0.1
  camera.fov_angle = 51.8
  camera.fov_wide_angle = 68
  camera:Load()
  scene:AddObject(camera, 0)
  scene.camera = camera
  local light_man = nx_null()
  if not nx_is_valid(light_man) then
    light_man = scene:Create("LightManager")
    light_man:Load()
    scene:AddObject(light_man, 1)
    light_man.SunLighting = true
    scene.light_man = light_man
  end
  local sound_man = nx_null()
  if not nx_is_valid(sound_man) then
    sound_man = scene:Create("SoundManager")
    sound_man.GlobalFocus = true
    sound_man.RolloffFactor = 1
    sound_man:Load()
    scene:AddObject(sound_man, 2)
    scene.sound_man = sound_man
  end
  local shadow_man = nx_null()
  if not nx_is_valid(shadow_man) then
    shadow_man = scene:Create("ShadowManager")
    shadow_man.MaxShadowNum = 10
    shadow_man.UseSimpleShadow = true
    shadow_man:Load()
    scene:AddObject(shadow_man, 90)
    scene.shadow_man = shadow_man
  end
  local postprocess_man = nx_null()
  if not nx_is_valid(postprocess_man) then
    postprocess_man = scene:Create("PostProcessMgr")
    scene:AddObject(postprocess_man, 110)
    scene.postprocess_man = postprocess_man
  end
  local saberarc_man = nx_null()
  if not nx_is_valid(saberArc_man) then
    saberarc_man = scene:Create("SaberArcManager")
    saberarc_man.TexturePath = "map\\"
    saberarc_man:Load()
    scene:AddObject(saberarc_man, 90)
    scene.saberarc_man = saberarc_man
  end
  local particle_man = nx_null()
  if not nx_is_valid(particle_man) then
    particle_man = scene:Create("ParticleManager")
    particle_man.TexturePath = "map\\tex\\particles\\"
    particle_man:Load()
    particle_man.EnableCacheIni = true
    scene:AddObject(particle_man, 100)
    scene.particle_man = particle_man
  end
  local game_effect = nx_create("GameEffect")
  nx_bind_script(game_effect, "game_effect", "game_effect_init", scene)
  scene.game_effect = game_effect
  scene.ClearZBuffer = true
  scene.EnableRealizeRefraction = true
  scene.ModelSphereAmbient = true
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    nx_execute("game_config", "apply_misc_config", scene, game_config)
  end
end
function delete_scene(scene)
  local world = nx_value("world")
  if nx_is_valid(scene) then
    if nx_find_custom(scene, "camera") then
      scene:Delete(scene.camera)
    end
    if nx_find_custom(scene, "login_control") then
      scene:Delete(scene.login_control)
    end
    if nx_find_custom(scene, "light_man") then
      scene:Delete(scene.light_man)
    end
    if nx_find_custom(scene, "shadow_man") then
      scene:Delete(scene.shadow_man)
    end
    if nx_find_custom(scene, "particle_man") then
      scene:Delete(scene.particle_man)
    end
    if nx_find_custom(scene, "saberarc_man") then
      scene:Delete(scene.saberarc_man)
    end
    if nx_find_custom(scene, "sound_man") then
      scene:Delete(scene.sound_man)
    end
    if nx_find_custom(scene, "game_effect") then
      nx_destroy(scene.game_effect)
    end
    if nx_find_custom(scene, "postprocess_man") then
      scene:Delete(scene.postprocess_man)
    end
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
    world:Delete(scene)
  end
  return true
end
function load_scene(scene, scene_path, is_login, weather)
  local terrain_filepath = nx_resource_path() .. scene_path
  if nx_is_valid(scene) then
    if terrain_filepath ~= scene.resource then
      if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
        nx_call("terrain\\terrain", "unload_terrain", scene)
      end
      local result = nx_execute("terrain\\terrain", "load_terrain", scene, terrain_filepath, is_login, weather)
      if result ~= nil and not result then
        nx_msgbox(get_msg_str("msg_435") .. terrain_filepath)
        return false
      end
      scene.terrain.WaterVisible = false
      scene.terrain.GroundVisible = false
      scene.terrain.VisualVisible = false
      scene.terrain.HelperVisible = false
    elseif nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      return true
    else
      nx_execute("terrain\\terrain", "load_terrain", scene, terrain_filepath, is_login, weather)
    end
    scene.resource = terrain_filepath
  end
end
function load_editor_ini(scene, filename)
  local world = nx_value("world")
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
    local terrain = scene.terrain
    local show_design_line = nx_boolean(ini:ReadString("system", "ShowDesignLine", ""))
    local design_radius = ini:ReadFloat("system", "DesignRadius", 200)
    local auto_save = nx_boolean(ini:ReadString("system", "AutoSave", ""))
    local auto_save_minutes = ini:ReadInteger("system", "AutoSaveMinutes", 30)
    local role_config = ini:ReadString("system", "RoleConfig", "ini\\role.ini")
    local show_light_range = nx_boolean(ini:ReadString("system", "ShowLightRange", "false"))
    terrain.ShowDesignLine = show_design_line
    terrain.ShowLightRange = show_light_range
    if 100 <= design_radius and design_radius <= 500 then
      terrain.DesignRadius = design_radius
    end
    world.auto_save = auto_save
    world.auto_save_minutes = auto_save_minutes
    world.role_config = role_config
  end
  nx_destroy(ini)
  return 1
end
function load_scene_camera(scene, filename)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  local camera = scene.camera
  local cam_posi_x = ini:ReadFloat("camera", "PositionX", 0)
  local cam_posi_y = ini:ReadFloat("camera", "PositionY", 15)
  local cam_posi_z = ini:ReadFloat("camera", "PositionZ", 0)
  local cam_angle_x = ini:ReadFloat("camera", "AngleX", 0)
  local cam_angle_y = ini:ReadFloat("camera", "AngleY", 0)
  local cam_angle_z = ini:ReadFloat("camera", "AngleZ", 0)
  local cam_fov_angle = ini:ReadFloat("camera", "FovAngle", 51.8)
  local cam_fov_wide_angle = ini:ReadFloat("camera", "FovWideAngle", 68)
  local cam_speed = ini:ReadFloat("camera", "Speed", 50)
  local drag_speed = ini:ReadFloat("camera", "DragSpeed", 0.1)
  local camera = scene.camera
  if 1 <= cam_speed and cam_speed < 100 then
    camera.move_speed = cam_speed
  end
  if 0.01 <= drag_speed and drag_speed < 1 then
    camera.drag_speed = drag_speed
  end
  if 10 <= cam_fov_angle and cam_fov_angle <= 180 then
    camera.Fov = cam_fov_angle / 360 * math.pi * 2
  end
  camera.fov_angle = cam_fov_angle
  camera.fov_wide_angle = cam_fov_wide_angle
  if nx_find_custom(scene, "login_control") then
    local login_control = scene.login_control
    if login_control ~= nil and nx_is_valid(login_control) then
      login_control.Target = nx_null()
      login_control:SetCameraDirect(cam_posi_x, cam_posi_y, cam_posi_z, cam_angle_x, cam_angle_y, cam_angle_z)
    end
  end
  if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
    local terrain = scene.terrain
    nx_pause(0.1)
    while nx_is_valid(terrain) and not terrain.LoadFinish do
      nx_pause(0.2)
    end
  end
end
