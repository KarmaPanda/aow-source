require("util_functions")
require("util_role_prop")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function create_game_config()
  local game_config = nx_create("GameConfig")
  init_game_config(game_config, "personal")
  nx_set_value("game_config", game_config)
  local game_config_supersimple = nx_create("GameConfig")
  init_performance_config(game_config_supersimple)
  nx_set_value("game_config_supersimple", game_config_supersimple)
  local game_config_simple = nx_create("GameConfig")
  init_performance_config(game_config_simple)
  nx_set_value("game_config_simple", game_config_simple)
  local game_config_low = nx_create("GameConfig")
  init_performance_config(game_config_low)
  nx_set_value("game_config_low", game_config_low)
  local game_config_middle = nx_create("GameConfig")
  init_performance_config(game_config_middle)
  nx_set_value("game_config_middle", game_config_middle)
  local game_config_high = nx_create("GameConfig")
  init_performance_config(game_config_high)
  nx_set_value("game_config_high", game_config_high)
  local game_config_ultra = nx_create("GameConfig")
  init_performance_config(game_config_ultra)
  nx_set_value("game_config_ultra", game_config_ultra)
  local game_config_info = nx_create("GameConfig")
  init_game_config_info(game_config_info)
  nx_set_value("game_config_info", game_config_info)
  nx_execute("form_stage_main\\form_camera\\form_movie_save", "load_moive_config")
  game_config.is_first_in_game = false
  if not load_game_config(game_config, "system_set.ini", "main") then
    local world = nx_value("world")
    if world.device_level >= 3 then
      game_config.level = "high"
    elseif world.device_level >= 2 then
      game_config.level = "middle"
    elseif world.device_level >= 1 then
      game_config.level = "low"
    else
      game_config.level = "simple"
    end
    game_config.win_maximized = true
    game_config.windowed = false
    game_config.is_first_in_game = true
  end
  load_game_config(game_config_supersimple, nx_resource_path() .. "ini\\systemset\\system_set_supersimple.ini", "supersimple")
  load_game_config(game_config_simple, nx_resource_path() .. "ini\\systemset\\system_set_simple.ini", "simple")
  load_game_config(game_config_low, nx_resource_path() .. "ini\\systemset\\system_set_low.ini", "low")
  load_game_config(game_config_middle, nx_resource_path() .. "ini\\systemset\\system_set_middle.ini", "middle")
  load_game_config(game_config_high, nx_resource_path() .. "ini\\systemset\\system_set_high.ini", "high")
  load_game_config(game_config_ultra, nx_resource_path() .. "ini\\systemset\\system_set_ultra.ini", "ultra")
  local dev_caps = nx_value("device_caps")
  if nx_is_valid(dev_caps) then
    dev_caps:QueryVideoMemory()
    local freeVideoMemory = nx_number(dev_caps.FreeVideoMemory)
    local freeAgpMemory = nx_number(dev_caps.FreeAgpMemory)
    if freeVideoMemory + freeAgpMemory < 100 then
      game_config.level = "simple"
    end
    local mem_table = dev_caps:QueryMemory()
    if mem_table ~= nil and table.getn(mem_table) > 0 then
      local free_memory = nx_number(mem_table[7])
      if free_memory < 100 then
        game_config.level = "simple"
      end
    end
  end
  if game_config.level == "supersimple" then
    copy_performance_config(game_config, game_config_supersimple)
  elseif game_config.level == "simple" then
    copy_performance_config(game_config, game_config_simple)
  elseif game_config.level == "low" then
    copy_performance_config(game_config, game_config_low)
  elseif game_config.level == "middle" then
    copy_performance_config(game_config, game_config_middle)
  elseif game_config.level == "high" then
    copy_performance_config(game_config, game_config_high)
  elseif game_config.level == "ultra" then
    copy_performance_config(game_config, game_config_ultra)
  end
  init_scene_box_light_config(game_config)
  load_scene_box_light_config(game_config)
  load_select_server_info(game_config)
  game_config.bind_yy_num = 0
  game_config.switch_server = false
  game_config.switch_ip = ""
  game_config.switch_port = 0
  game_config.show_activity = true
  game_config.ret_normal_server = false
  game_config.is_login_switch_server = true
  game_config.switch_normal_server = false
  game_config.res_login = false
  game_config.freshman_btn_show = false
  game_config.first_lead = false
  game_config.is_cross_ready = false
  game_config.role_name = nx_widestr("")
  game_config.role_sex = 0
  game_config.back_normal_server = 0
  return true
end
function init_game_config(game_config, config_name)
  game_config.Name = config_name
  game_config.level = "personal"
  game_config.set_display = false
  game_config.login_addr = ""
  game_config.login_port = 0
  game_config.server_name = nx_widestr("")
  game_config.area_addr = ""
  game_config.area_port = 0
  game_config.server_sdo = "0"
  game_config.login_account = ""
  game_config.login_password = ""
  game_config.login_validate = ""
  game_config.login_niudun = ""
  game_config.login_shoujiniudun = ""
  game_config.save_account = false
  game_config.bind_yy_num = 0
  game_config.switch_server = false
  game_config.show_activity = true
  game_config.phone_lock = 0
  game_config.ret_normal_server = false
  game_config.is_login_switch_server = true
  game_config.switch_normal_server = false
  game_config.res_login = false
  game_config.sound_enable = true
  game_config.sound_volume = 1
  game_config.music_enable = true
  game_config.music_volume = 0.5
  game_config.area_music_enable = true
  game_config.area_music_volume = 1
  game_config.win_left = 0
  game_config.win_top = 0
  local screen_width, screen_height = nx_function("ext_get_screen_size")
  game_config.win_width = screen_width
  game_config.win_height = screen_height
  game_config.win_maximized = false
  game_config.windowed = true
  game_config.vsync = false
  game_config.wide_angle = false
  game_config.multisample = "NONE"
  game_config.hardware_accel = false
  game_config.fxaa_quality = 0
  game_config.card_no = ""
  game_config.Language = ""
  game_config.small_map_icon_role = 1
  game_config.small_map_icon_enemy = 1
  game_config.small_map_icon_enemy_guild = 1
  game_config.small_map_icon_team = 1
  game_config.small_map_icon_group = 1
  game_config.freshman_btn_show = false
  game_config.first_lead = false
  game_config.show_unknown_skill = false
  game_config.is_cross_ready = false
  game_config.role_name = nx_widestr("")
  game_config.role_sex = 0
  game_config.role_photo = ""
  game_config.role_face = ""
  game_config.role_hair = ""
  game_config.back_normal_server = 0
  init_performance_config(game_config)
  return true
end
function init_performance_config(game_config)
  game_config.visual_radius = 200
  game_config.grass_radius = 100
  game_config.grass_lod = 1
  game_config.shadow_quality = 0
  game_config.water_quality = 1
  game_config.effect_quality = 0
  game_config.texture_quality = 0
  game_config.anisotropic = 16
  game_config.filter_enable = true
  game_config.bloom_enable = true
  game_config.screen_blur_enable = false
  game_config.dof_enable = false
  game_config.volume_lighting_enable = false
  game_config.hdr_enable = false
  game_config.ssao_enable = false
  game_config.prelight_enable = false
  game_config.foliage_blend = false
  game_config.nolight_enable = false
  game_config.physics_enable = false
  game_config.weather_enable = false
  return true
end
function copy_performance_config(game_config, performance_config)
  local property_table = nx_property_list(performance_config)
  for i = 1, table.getn(property_table) do
    local property_name = property_table[i]
    if performance_config:IsPropUsed(property_name) then
      local property_value = nx_property(performance_config, property_name)
      nx_set_property(game_config, property_name, property_value)
    end
  end
  return true
end
function save_game_config(game_config, file_name, section_name)
  local ini = nx_create("IniDocument")
  local login_addr = ""
  local login_port = ""
  local server_name = nx_widestr("")
  local area_addr = ""
  local area_port = ""
  local card_no = ""
  if nx_find_property(game_config, "login_addr") then
    login_addr = game_config.login_addr
  end
  if nx_find_property(game_config, "login_port") then
    login_port = game_config.login_port
  end
  if nx_find_property(game_config, "server_name") then
    server_name = game_config.server_name
  end
  if nx_find_property(game_config, "area_addr") then
    area_addr = game_config.area_addr
  end
  if nx_find_property(game_config, "area_port") then
    area_port = game_config.area_port
  end
  if nx_find_property(game_config, "login_account") then
    login_account = game_config.login_account
  end
  if OPERATORS_TYPE_WONIU ~= get_operators_name() then
    game_config.login_account = ""
  end
  if nx_find_property(game_config, "card_no") then
    card_no = game_config.card_no
  end
  if nx_find_property(game_config, "save_account") and not game_config.save_account then
    game_config.login_account = ""
  end
  game_config.login_addr = ""
  game_config.login_port = ""
  game_config.server_name = nx_widestr("")
  game_config.area_addr = ""
  game_config.area_port = ""
  game_config.login_password = ""
  game_config.login_validate = ""
  game_config.card_no = ""
  if section_name == "main" then
    local world = nx_value("world")
    local left, top, width, height, maximized = world:GetWindowPos()
    game_config.win_left = left
    game_config.win_top = top
    game_config.win_width = width
    game_config.win_height = height
    game_config.win_maximized = maximized
  end
  local property_table = nx_property_list(game_config)
  for i = 1, table.getn(property_table) do
    local property_name = property_table[i]
    local property_value = nx_property(game_config, property_name)
    if game_config:IsPropUsed(property_name) and nx_string(property_value) ~= "" and property_value ~= nil then
      ini:WriteString(section_name, property_name, nx_string(property_value))
    end
  end
  ini.FileName = file_name
  ini:SaveToFile()
  nx_destroy(ini)
  game_config.login_addr = login_addr
  game_config.login_port = login_port
  game_config.server_name = server_name
  game_config.area_addr = area_addr
  game_config.area_port = area_port
  game_config.login_account = login_account
  game_config.card_no = card_no
  return true
end
function load_game_config(game_config, file_name, section_name)
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local property_table = nx_property_list(game_config)
  for i = 1, table.getn(property_table) do
    local property_name = property_table[i]
    local property_value = nx_property(game_config, property_name)
    local property_type = nx_type(property_value)
    if ini:FindItem(section_name, property_name) then
      local new_value = ""
      if property_type == "boolean" then
        new_value = nx_boolean(ini:ReadString(section_name, property_name, ""))
      elseif property_type == "number" then
        new_value = ini:ReadFloat(section_name, property_name, 0)
      else
        new_value = ini:ReadString(section_name, property_name, "")
      end
      nx_set_property(game_config, property_name, new_value)
    end
  end
  if section_name == "main" and not ini:FindItem(section_name, "res_process") then
    nx_set_property(game_config, "res_process", true)
  end
  nx_destroy(ini)
  return true
end
function backup_game_config(game_config)
  local backup = nx_value("game_config_backup")
  if not nx_is_valid(backup) then
    backup = nx_create("GameConfig")
    nx_set_value("game_config_backup", backup)
  end
  local property_table = nx_property_list(game_config)
  for i = 1, table.getn(property_table) do
    local property_name = property_table[i]
    local property_value = nx_property(game_config, property_name)
    if game_config:IsPropUsed(property_name) then
      nx_set_property(backup, property_name, property_value)
    end
  end
  return true
end
function restore_game_config(game_config)
  local backup = nx_value("game_config_backup")
  if not nx_is_valid(backup) then
    return false
  end
  local property_table = nx_property_list(backup)
  for i = 1, table.getn(property_table) do
    local property_name = property_table[i]
    local property_value = nx_property(backup, property_name)
    if backup:IsPropUsed(property_name) then
      nx_set_property(game_config, property_name, property_value)
    end
  end
  return true
end
function apply_performance_config(scene, game_config)
  if nx_is_valid(scene) then
    local game_effect = scene.game_effect
    if nx_is_valid(game_effect) then
      local level = game_config.level
      if level == "ultra" then
        game_effect:RefreshShadowEffect(0)
      else
        game_effect:RefreshShadowEffect(1)
      end
    end
  end
  if 1 <= game_config.shadow_quality and not validate_shadow_texture() then
    game_config.shadow_quality = 0
  end
  if game_config.hdr_enable and not validate_hdr_texture() then
    game_config.hdr_enable = false
  end
  if game_config.shadow_quality == 0 then
    game_config.ssao_enable = false
    game_config.prelight_enable = false
  end
  local ms_support, ms_value = validate_multisample(game_config.multisample)
  if not ms_support then
    game_config.multisample = ms_value
    set_display(game_config)
  end
  set_fxaa_quality(scene, game_config.fxaa_quality)
  local mapQuery = nx_value("MapQuery")
  if nx_is_valid(mapQuery) then
    local target_visual_radius = mapQuery:GetSpecialSceneVisualRadius()
    if mapQuery:IsSpecialScene() and target_visual_radius ~= 0 then
      set_visual_radius(scene, target_visual_radius)
    else
      set_visual_radius(scene, game_config.visual_radius)
    end
  else
    set_visual_radius(scene, game_config.visual_radius)
  end
  set_grass_radius(scene, game_config.grass_radius)
  set_grass_lod(scene, game_config.grass_lod)
  set_shadow_quality(scene, game_config.shadow_quality)
  set_water_quality(scene, game_config.water_quality)
  set_effect_quality(scene, game_config.effect_quality)
  set_texture_quality(scene, game_config.texture_quality)
  set_anisotropic(scene, game_config.anisotropic)
  set_filter_enable(scene, game_config.filter_enable)
  set_bloom_enable(scene, game_config.bloom_enable)
  set_screen_blur_enable(scene, game_config.screen_blur_enable)
  set_dof_enable(scene, game_config.dof_enable)
  set_volume_lighting_enable(scene, game_config.volume_lighting_enable)
  set_hdr_enable(scene, game_config.hdr_enable)
  set_ssao_enable(scene, game_config.ssao_enable)
  set_prelight_enable(scene, game_config.prelight_enable)
  set_foliage_blend(scene, game_config.foliage_blend)
  set_hardware_accel(scene, game_config.hardware_accel)
  set_nolight_enable(scene, game_config.nolight_enable)
  set_physics_enable(game_config.physics_enable)
  set_ocean_showtype(scene, game_config)
  return true
end
function set_ocean_showtype(scene, game_config)
  if not nx_is_valid(scene) then
    return
  end
  if not nx_is_valid(game_config) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  if game_config.level == "ultra" then
    terrain.OceanShowType = 2
  end
end
function apply_window_config(game_config)
  local ms_support, ms_value = validate_multisample(game_config.multisample)
  if not ms_support then
    game_config.multisample = ms_value
  end
  local world = nx_value("world")
  world.Left = game_config.win_left
  world.Top = game_config.win_top
  world.Width = game_config.win_width
  world.Height = game_config.win_height
  world.Maximized = game_config.win_maximized
  world.Vsync = game_config.vsync
  world.MultiSampleType = game_config.multisample
  world.ShowTitle = game_config.windowed
  set_display(game_config)
  return true
end
function apply_window_config_no_reset(game_config)
  local ms_support, ms_value = validate_multisample(game_config.multisample)
  if not ms_support then
    game_config.multisample = ms_value
  end
  local world = nx_value("world")
  world.Left = game_config.win_left
  world.Top = game_config.win_top
  world.Width = game_config.win_width
  world.Height = game_config.win_height
  world.Maximized = game_config.win_maximized
  world.Vsync = game_config.vsync
  world.MultiSampleType = game_config.multisample
  world.ShowTitle = game_config.windowed
  set_display_no_reset(game_config)
  return true
end
function apply_misc_config(scene, game_config)
  set_wide_angle(scene, game_config.wide_angle)
  set_sound_enable(scene, game_config.sound_enable)
  set_sound_volume(scene, game_config.sound_volume)
  set_logic_sound_enable(scene, 0, game_config.area_music_enable)
  set_logic_sound_volume(scene, 0, game_config.area_music_volume)
  set_logic_sound_enable(scene, 2, game_config.music_enable)
  set_logic_sound_volume(scene, 2, game_config.music_volume)
  set_logic_sound_enable(scene, 1, game_config.sound_enable)
  set_logic_sound_volume(scene, 1, game_config.sound_volume)
  enable_sound_man(scene)
  return true
end
function check_depth_map_switch(scene)
  if not nx_is_valid(scene) then
    return false
  end
  local stage = nx_value("stage")
  local game_config = nx_value("game_config")
  if not game_config.is_first_in_game or "login" ~= stage and "create" ~= stage then
    if game_config.shadow_quality == 0 and game_config.water_quality < 2 and not game_config.volume_lighting_enable and not game_config.screen_blur_enable and not game_config.dof_enable then
      scene.EnableRealizeDepth = false
    else
      scene.EnableRealizeDepth = true
    end
  elseif game_config.is_enable_realize_depth then
    scene.EnableRealizeDepth = true
  else
    scene.EnableRealizeDepth = false
  end
  scene.EnableEarlyZ = true
  local world = nx_value("world")
  local has_depth_tex = false
  if string.upper(game_config.multisample) ~= "NONE" then
    has_depth_tex = world.ResolveDepthNV or world.ResolveDepthATI
  else
    has_depth_tex = world.UseIntZDepth or world.UseRawZDepth
  end
  if not game_config.is_first_in_game or "login" ~= stage and "create" ~= stage then
    if game_config.prelight_enable and has_depth_tex then
      scene.EnableRealizeNormal = true
    else
      scene.EnableRealizeNormal = false
    end
  elseif game_config.is_enable_realize_normal and has_depth_tex then
    scene.EnableRealizeNormal = true
  else
    scene.EnableRealizeNormal = false
  end
  return true
end
function set_display(game_config)
  local world = nx_value("world")
  game_config.set_display = true
  local ms_support, ms_value = validate_multisample(game_config.multisample)
  if not ms_support then
    game_config.multisample = ms_value
  end
  local screen_width, screen_height = nx_function("ext_get_screen_size")
  local cur_width = world.Width
  local cur_height = world.Height
  local win_l, win_t, win_w, win_h, win_maximized = world:GetWindowPos()
  if win_maximized then
    cur_width = screen_width
    cur_height = screen_height
  end
  if cur_width ~= game_config.win_width or cur_height ~= game_config.win_height or world.ShowTitle ~= game_config.windowed then
    world:HideWindow()
  end
  if game_config.win_width == screen_width and game_config.win_height == screen_height then
    world.Maximized = win_maximized
  else
    world.Maximized = false
  end
  world.Windowed = true
  world.ShowTitle = game_config.windowed
  world.Left = -1
  world.Top = -1
  if game_config.win_width < world.MinDeviceWidth then
    world.FixDeviceWidth = world.MinDeviceWidth
  else
    world.FixDeviceWidth = game_config.win_width
  end
  if game_config.win_height < world.MinDeviceHeight then
    world.FixDeviceHeight = world.MinDeviceHeight
  else
    world.FixDeviceHeight = game_config.win_height
  end
  world.Width = game_config.win_width
  world.Height = game_config.win_height
  world.Vsync = game_config.vsync
  world.MultiSampleType = game_config.multisample
  world:UpdateWindow()
  if not game_config.windowed then
    local screen_width, screen_height = nx_function("ext_get_screen_size")
    world.Width = screen_width
    world.Height = screen_height
    world:UpdateWindow()
  else
    local client_width, client_height = nx_function("ext_get_client_rect")
    if client_width < world.MinDeviceWidth then
      world.FixDeviceWidth = world.MinDeviceWidth
    else
      world.FixDeviceWidth = client_width
    end
    if client_height < world.MinDeviceHeight then
      world.FixDeviceHeight = world.MinDeviceHeight
    else
      world.FixDeviceHeight = client_height
    end
  end
  local game_name = nx_widestr(util_text("ui_GameName")) .. nx_widestr("  ") .. nx_widestr(game_config.server_name)
  nx_function("ext_set_window_title", game_name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local scale_enable = gui.ScaleEnable
  if scale_enable then
    gui.ScaleEnable = false
  end
  world:ResetDevice()
  local desktop = gui.Desktop
  gui.ScaleEnable = scale_enable
  desktop.Width = gui.Width
  desktop.Height = gui.Height
  world:ShowWindow()
  nx_pause(0.1)
  game_config.set_display = false
  nx_execute("gui", "gui_size", gui, gui.Width, gui.Height)
  return 1
end
function set_display_no_reset(game_config)
  local world = nx_value("world")
  game_config.set_display = true
  local ms_support, ms_value = validate_multisample(game_config.multisample)
  if not ms_support then
    game_config.multisample = ms_value
  end
  local screen_width, screen_height = nx_function("ext_get_screen_size")
  local cur_width = world.Width
  local cur_height = world.Height
  local win_l, win_t, win_w, win_h, win_maximized = world:GetWindowPos()
  if win_maximized then
    cur_width = screen_width
    cur_height = screen_height
  end
  if cur_width ~= game_config.win_width or cur_height ~= game_config.win_height or world.ShowTitle ~= game_config.windowed then
    world:HideWindow()
  end
  if game_config.win_width == screen_width and game_config.win_height == screen_height then
    world.Maximized = win_maximized
  else
    world.Maximized = false
  end
  world.Windowed = true
  world.ShowTitle = game_config.windowed
  world.Left = -1
  world.Top = -1
  if game_config.win_width < world.MinDeviceWidth then
    world.FixDeviceWidth = world.MinDeviceWidth
  else
    world.FixDeviceWidth = game_config.win_width
  end
  if game_config.win_height < world.MinDeviceHeight then
    world.FixDeviceHeight = world.MinDeviceHeight
  else
    world.FixDeviceHeight = game_config.win_height
  end
  world.Width = game_config.win_width
  world.Height = game_config.win_height
  world.Vsync = game_config.vsync
  world.MultiSampleType = game_config.multisample
  world:UpdateWindow()
  if not game_config.windowed then
    local screen_width, screen_height = nx_function("ext_get_screen_size")
    world.Width = screen_width
    world.Height = screen_height
    world:UpdateWindow()
  else
    local client_width, client_height = nx_function("ext_get_client_rect")
    if client_width < world.MinDeviceWidth then
      world.FixDeviceWidth = world.MinDeviceWidth
    else
      world.FixDeviceWidth = client_width
    end
    if client_height < world.MinDeviceHeight then
      world.FixDeviceHeight = world.MinDeviceHeight
    else
      world.FixDeviceHeight = client_height
    end
  end
  game_config.set_display = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local scale_enable = gui.ScaleEnable
  if scale_enable then
    gui.ScaleEnable = false
  end
  local desktop = gui.Desktop
  gui.ScaleEnable = scale_enable
  desktop.Width = gui.Width
  desktop.Height = gui.Height
  nx_execute("gui", "gui_size", gui, gui.Width, gui.Height)
end
function set_fxaa_quality(scene, level)
  local fxaa_uiparam = scene.fxaa_uiparam
  if not nx_is_valid(fxaa_uiparam) then
    return false
  end
  fxaa_uiparam.enable = 0 < level
  fxaa_uiparam.level = level
  nx_execute("terrain\\fxaa", "change_fxaa", scene)
  return true
end
local MAX_VISUAL_RADIUS = 250
local MAX_FAR_CLIP_DISTANCE = 400
function get_comfortable_radius(far_clip)
  console_log("get_comfortable_radius =" .. nx_string(far_clip))
  local device_caps = nx_value("device_caps")
  if not nx_is_valid(device_caps) and 150 < far_clip then
    return 150
  end
  local mem_list = device_caps:QueryMemory()
  if mem_list[6] < 2100 then
    local scene_table = {
      "city05",
      "city03",
      "school03"
    }
    local game_client = nx_value("game_client")
    local scene = game_client:GetScene()
    if nx_is_valid(scene) then
      local scene_name = scene:QueryProp("Resource")
      console_log(scene_name)
      for i = 1, table.maxn(scene_table) do
        if scene_name == scene_table[i] then
          if 150 < far_clip then
            return 150
          end
          break
        end
      end
    end
  end
  console_log(nx_string(mem_list[6]) .. " value=" .. nx_string(far_clip))
  return far_clip
end
function is_new_scene()
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    local map_query = nx_value("MapQuery")
    if not nx_is_valid(map_query) then
      return false
    end
    local scene_id = map_query:GetCurrentScene()
    if "" == scene_id then
      return false
    end
    local isnew = map_query:IsShowPicMask(scene_id)
    if not isnew then
      return false
    end
  end
  local flag = nx_execute("terrain\\terrain", "can_open_big_view")
  if not flag then
    return false
  end
  return true
end
function new_scene_reset(scene)
  if not nx_is_valid(scene) then
    return false
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  if not is_new_scene() then
    local camera = scene.camera
    if nx_is_valid(camera) then
      camera.FarPlane = 1200
    end
    terrain.LodRadius = 300
    terrain.NoLodRadius = 50
    terrain.FarLodCheckError = true
    terrain.FarLodLevel = -1
    local weather = scene.weather
    if nx_is_valid(weather) then
      weather.GlowSize = 200
      weather.FlareSize = 1
      weather.GlowDistanc = 1000
      weather.FlareDistance = 1000
    end
    return false
  end
  nx_execute("terrain\\weather", "change_weather", scene)
  nx_execute("terrain\\terrain", "change_screen", scene)
  nx_execute("terrain\\dof", "change_ppdof", scene, true)
  local camera = scene.camera
  local screen = scene.screen
  if nx_is_valid(camera) then
    camera.FarPlane = screen.far_plane
  end
  return true
end
function set_visual_radius(scene, radius)
  local game_config_supersimple = nx_value("game_config_supersimple")
  local game_config_simple = nx_value("game_config_simple")
  local game_config_low = nx_value("game_config_low")
  local game_config_middle = nx_value("game_config_middle")
  local game_config_high = nx_value("game_config_high")
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  if new_scene_reset(scene) then
    return
  end
  console_log("radius = " .. nx_string(radius))
  radius = get_comfortable_radius(radius)
  terrain.ClipRadiusNear = radius
  terrain.ClipRadiusFar = radius + 50
  console_log("real clip radius = " .. nx_string(radius) .. " -- " .. nx_string(radius + 50))
  local far_clip = radius + 50 + radius / MAX_VISUAL_RADIUS * 100
  if far_clip > MAX_FAR_CLIP_DISTANCE then
    far_clip = MAX_FAR_CLIP_DISTANCE
  end
  scene.FarClipDistance = far_clip
  local weather = scene.Weather
  if nx_is_valid(weather) then
    local fog_sub, fog_add
    if radius < game_config_supersimple.visual_radius + 10 then
      fog_sub = radius * 0.5
      fog_add = radius * 0.1
    elseif radius < game_config_simple.visual_radius + 10 then
      fog_sub = radius * 0.5
      fog_add = radius * 0.1
    elseif radius < game_config_low.visual_radius + 10 then
      fog_sub = radius * 0.5
      fog_add = radius * 0.2
    elseif radius < game_config_middle.visual_radius + 10 then
      fog_sub = radius * 0.5
      fog_add = radius * 0.3
    elseif radius < game_config_high.visual_radius + 10 then
      fog_sub = radius * 0.5
      fog_add = radius * 0.4
    else
      fog_sub = radius * 0.5
      fog_add = radius * 0.5
    end
    local fog_start = radius - fog_sub
    if fog_start < weather.fog_start_origin then
      weather.FogStart = fog_start
    end
    weather.FogEnd = radius + fog_add
    weather.FogLinear = true
    if weather.FogStart >= weather.FogEnd then
      weather.FogStart = fog_start
    end
    if radius > game_config_high.visual_radius - 1 then
      weather.FogExp = true
    else
      weather.FogExp = false
    end
  end
  terrain.AlphaFadeRadius = radius + 30
  terrain.AlphaHideRadius = radius + 80
  if far_clip > game_config_high.visual_radius - 1 then
    terrain.LodRadius = MAX_FAR_CLIP_DISTANCE
    terrain.PixelError = 10
    terrain.FarLodLevel = -1
  else
    terrain.LodRadius = MAX_FAR_CLIP_DISTANCE * 0.5
    terrain.PixelError = 20
    terrain.FarLodLevel = 2
  end
  terrain:RefreshVisual()
  terrain:RefreshGround()
  return true
end
function set_grass_radius(scene, radius)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  if is_new_scene() then
    local screen = scene.screen
    terrain.GrassRadius = screen.grass_radius
  else
    terrain.GrassRadius = radius
  end
  terrain:RefreshGrass()
  return true
end
function set_grass_lod(scene, radius)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  terrain.GrassLod = radius
  terrain:RefreshGrass()
  return true
end
function create_effect(effect_name, self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
  if effect_name == nil or nx_string(effect_name) == nx_string("") or nx_string(effect_name) == nx_string("nil") then
    return false
  end
  if not nx_is_valid(self) then
    return false
  end
  local scene = self.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect) then
    return false
  end
  if not nx_is_valid(game_effect.Scene) then
    game_effect.Scene = scene
  end
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  return game_effect:CreateEffect(nx_string(effect_name), self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
end
function set_shadow_quality(scene, level)
  local pssm_uiparam = scene.pssm_uiparam
  if not nx_is_valid(pssm_uiparam) then
    return false
  end
  local shadow_man = scene.shadow_man
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(shadow_man) then
    return false
  end
  local stage = nx_value("stage")
  if level == 0 then
    pssm_uiparam.pssm_enable = false
    shadow_man.UseSimpleShadow = true
    shadow_man.MaxShadowNum = 1
  elseif level == 1 then
    pssm_uiparam.pssm_enable = true
    pssm_uiparam.filter_level = 1
    pssm_uiparam.shadow_map_count = 3
    pssm_uiparam.shadow_map_size = 512
    pssm_uiparam.shadow_distance = 50
  elseif 2 <= level then
    pssm_uiparam.pssm_enable = true
    pssm_uiparam.filter_level = 2
    pssm_uiparam.shadow_map_count = 3
    pssm_uiparam.shadow_map_size = 1024
    pssm_uiparam.shadow_distance = 100
  else
    return false
  end
  check_depth_map_switch(scene)
  nx_execute("terrain\\pssm", "change_pssm", scene)
  return true
end
function set_water_quality(scene, level)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  local ppscreenrefraction_uiparam = scene.ppscreenrefraction_uiparam
  if not nx_is_valid(ppscreenrefraction_uiparam) then
    return false
  end
  terrain.WaterEnvMapReusable = true
  if level == 0 then
    terrain.GroundEnvMap = 0
    terrain.VisualEnvMap = 0
    terrain.WaterReflect = false
    terrain.WaterDepth = false
    terrain.WaterBorder = false
    terrain.WaterWave = false
    terrain.WaterSunReflect = false
    scene.EnableRealizeTempRT = false
    ppscreenrefraction_uiparam.enable = false
    terrain.OceanShowType = 0
    terrain.EnableMirror = false
  elseif level == 1 then
    terrain.GroundEnvMap = 1
    terrain.VisualEnvMap = 1
    terrain.WaterReflect = true
    terrain.WaterDepth = false
    terrain.WaterBorder = false
    terrain.WaterWave = false
    terrain.WaterSunReflect = false
    scene.EnableRealizeTempRT = true
    ppscreenrefraction_uiparam.enable = true
    terrain.OceanShowType = 0
    terrain.EnableMirror = true
  elseif level == 2 then
    terrain.GroundEnvMap = 1
    terrain.VisualEnvMap = 1
    terrain.WaterReflect = true
    terrain.WaterDepth = true
    terrain.WaterBorder = true
    terrain.WaterWave = true
    terrain.WaterSunReflect = true
    scene.EnableRealizeTempRT = true
    ppscreenrefraction_uiparam.enable = true
    terrain.OceanShowType = 1
    terrain.EnableMirror = true
  end
  check_depth_map_switch(scene)
  nx_execute("terrain\\screenrefraction", "change_ppscreenrefraction", scene)
  return true
end
function set_effect_quality(scene, level)
  local world = nx_value("world")
  local pppixelrefraction_uiparam = scene.pppixelrefraction_uiparam
  if not nx_is_valid(pppixelrefraction_uiparam) then
    return false
  end
  local has_depth_tex = world.UseIntZDepth or world.UseRawZDepth
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) and nx_find_property(action_module, "FootStepLevel") then
    action_module.FootStepLevel = level
  end
  if level == 0 then
    pppixelrefraction_uiparam.enable = false
    if has_depth_tex then
      if world.device_level >= 3 then
        scene.BlendDownLevel = 2
      else
        scene.BlendDownLevel = 3
      end
    end
  elseif level == 1 then
    pppixelrefraction_uiparam.enable = true
    if has_depth_tex then
      if world.device_level >= 3 then
        scene.BlendDownLevel = 1
      else
        scene.BlendDownLevel = 2
      end
    end
  elseif level == 2 then
    pppixelrefraction_uiparam.enable = true
    if has_depth_tex then
      if world.device_level >= 3 then
        scene.BlendDownLevel = 0
      else
        scene.BlendDownLevel = 1
      end
    end
  end
  nx_execute("terrain\\screenrefraction", "change_ppscreenrefraction", scene)
  nx_execute("terrain\\pixelrefraction", "change_pppixelrefraction", scene)
  return true
end
function set_texture_quality(scene, level)
  local world = nx_value("world")
  if level == 0 then
    world.TextureLod = 1
    world.TextureLodBias = 0
  elseif level == 1 then
    world.TextureLod = 0
    world.TextureLodBias = 0
  elseif level == 2 then
    world.TextureLod = 0
    world.TextureLodBias = -0.5
  end
  return true
end
function set_anisotropic(scene, level)
  local world = nx_value("world")
  if level == 0 then
    world.Anisotropic = false
    world.MaxAnisotropy = 1
  else
    local device_caps = nx_value("device_caps")
    if level > device_caps.MaxAnisotropy then
      level = device_caps.MaxAnisotropy
    end
    world.Anisotropic = true
    world.MaxAnisotropy = level
  end
  return true
end
function set_filter_enable(scene, enable)
  local ppfilter_uiparam = scene.ppfilter_uiparam
  if not nx_is_valid(ppfilter_uiparam) then
    return false
  end
  ppfilter_uiparam.enable = enable
  nx_execute("terrain\\filter", "change_ppfilter", scene)
  return true
end
function set_bloom_enable(scene, enable)
  local pphdr_uiparam = scene.pphdr_uiparam
  if not nx_is_valid(pphdr_uiparam) then
    return false
  end
  pphdr_uiparam.bloom_enable = enable
  if enable and not pphdr_uiparam.hdr_enable then
    pphdr_uiparam.hdr_enable = enable
  end
  nx_call("terrain\\hdr", "change_pphdr", scene)
  return true
end
function set_screen_blur_enable(scene, enable)
  local ppscreenblur_uiparam = scene.ppscreenblur_uiparam
  if not nx_is_valid(ppscreenblur_uiparam) then
    return false
  end
  ppscreenblur_uiparam.enable = enable
  check_depth_map_switch(scene)
  nx_execute("terrain\\screenblur", "change_ppscreenblur", scene)
  return true
end
function set_dof_enable(scene, enable, b_focus_player)
  local ppdof_uiparam = scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) then
    return false
  end
  ppdof_uiparam.enable = enable
  check_depth_map_switch(scene)
  nx_execute("terrain\\dof", "change_ppdof", scene, b_focus_player)
  return true
end
function set_volume_lighting_enable(scene, enable)
  local ppvolumelighting_uiparam = scene.ppvolumelighting_uiparam
  if not nx_is_valid(ppvolumelighting_uiparam) then
    return false
  end
  ppvolumelighting_uiparam.enable = enable
  check_depth_map_switch(scene)
  nx_execute("terrain\\volumelighting", "change_ppvolumelighting", scene)
  return true
end
function set_hdr_enable(scene, enable)
  local pphdr_uiparam = scene.pphdr_uiparam
  if not nx_is_valid(pphdr_uiparam) then
    return false
  end
  pphdr_uiparam.hdr_enable = enable
  nx_call("terrain\\hdr", "change_pphdr", scene)
end
function set_ssao_enable(scene, enable)
  local ssao_uiparam = scene.ssao_uiparam
  if not nx_is_valid(ssao_uiparam) then
    return false
  end
  ssao_uiparam.enable = enable
  check_depth_map_switch(scene)
  nx_execute("terrain\\ssao", "change_ssao", scene)
  return true
end
function set_prelight_enable(scene, enable)
  local pssm_uiparam = scene.pssm_uiparam
  if not nx_is_valid(pssm_uiparam) then
    return false
  end
  pssm_uiparam.prelight_enable = enable
  check_depth_map_switch(scene)
  nx_execute("terrain\\pssm", "change_pssm", scene)
  return true
end
function set_foliage_blend(scene, enable)
  scene.FoliageBlend = enable
  return true
end
function set_nolight_enable(scene, enable)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  terrain.NoLight = enable
  return true
end
function get_weather_is_night()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local scene = game_client:GetScene()
  if not nx_is_valid(scene) then
    return false
  end
  local weather = scene:QueryProp("Weather")
  if weather ~= 0 and weather ~= "" then
    local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\scene_weather.ini")
    if not nx_is_valid(ini) then
      return false
    end
    local sec_index = ini:FindSectionIndex(weather)
    if sec_index < 0 then
      return false
    end
    local is_night = ini:ReadString(sec_index, "IsNight", "")
    return is_night == "1"
  end
  return false
end
function refresh_use_light_map()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return
  end
  local is_night = get_weather_is_night()
  if is_night then
    game_config.backup_uselightmap = world.UseLightMap
    if world.UseLightMap then
      world.UseLightMap = false
    end
  elseif nx_find_custom(game_config, "backup_uselightmap") and game_config.backup_uselightmap ~= nil then
    world.UseLightMap = game_config.backup_uselightmap
    game_config.backup_uselightmap = nil
  end
end
function set_physics_enable(enable)
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return false
  end
  if nx_execute("form_stage_main\\form_system\\form_system_setting", "can_support_physics") then
    world.SupportPhysics = enable
    world.SupportPhysicsDestructible = enable
    world.SupportPhysicsRagdoll = enable
    world.SupportPhysicsRigidBody = enable
  else
    world.SupportPhysics = false
  end
  return true
end
function set_weather_enable(enable)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return false
  end
  game_config.weather_enable = enable
  return true
end
function set_wide_angle(scene, enable)
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return false
  end
  if enable then
    camera.Fov = camera.fov_wide_angle / 360 * math.pi * 2
  else
    camera.Fov = camera.fov_angle / 360 * math.pi * 2
  end
  return true
end
function set_hardware_accel(scene, enable)
  scene.EnableOcclusionQuery = enable
  local world = nx_value("world")
  world.ShadowMapInstancing = enable
  return true
end
function set_multisample(scene)
  local game_config = nx_value("game_config")
  set_display(game_config)
  scene.EnableRealizeDepth = false
  scene.EnableRealizeNormal = false
  check_depth_map_switch(scene)
  return true
end
function set_logic_sound_enable(scene, logic_type, enable)
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return false
  end
  sound_man:SetLogicEnable(logic_type, enable)
  return true
end
function set_logic_sound_volume(scene, logic_type, volume)
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return false
  end
  sound_man:SetLogicVolume(logic_type, volume)
  return true
end
function set_sound_enable(scene, enable)
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return false
  end
  if enable then
    local game_config = nx_value("game_config")
    sound_man.SoundVolume = game_config.sound_volume
  else
    sound_man.SoundVolume = 0
  end
  return true
end
function set_sound_volume(scene, volume)
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return false
  end
  local game_config = nx_value("game_config")
  if game_config.sound_enable then
    sound_man.SoundVolume = volume
  end
  return true
end
function enable_sound_man(scene)
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return false
  end
  sound_man.MusicVolume = 1
end
function set_music_enable(scene, enable)
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return false
  end
  if enable then
    local game_config = nx_value("game_config")
    sound_man.MusicVolume = game_config.music_volume
  else
    sound_man.MusicVolume = 0
  end
  return true
end
function set_music_volume(scene, volume)
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return false
  end
  local game_config = nx_value("game_config")
  if game_config.music_enable then
    sound_man.MusicVolume = volume
  end
  return true
end
function set_ui_scale(enable, value)
  local gui = nx_value("gui")
  if nx_int(enable) == nx_int(1) then
    gui.ScaleEnable = true
    gui.ScaleRatio = nx_int(value) * 0.01
  else
    gui.ScaleEnable = false
    gui.ScaleRatio = 1
  end
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  nx_execute("gui", "scale_change")
  nx_execute("gui", "gui_size", gui, gui.Width, gui.Height)
  return true
end
function validate_multisample(multisample_type)
  local world = nx_value("world")
  local device_caps = nx_value("device_caps")
  local game_config = nx_value("game_config")
  local color_format = "A8R8G8B8"
  local depth_format = "D24S8"
  if game_config.hdr_enable or game_config.prelight_enable then
    color_format = "A16B16G16R16F"
  elseif game_config.screen_blur_enable or game_config.dof_enable or game_config.volume_lighting_enable or game_config.shadow_quality >= 1 or game_config.water_quality == 2 then
    color_format = "R32F"
  end
  local ms_value = multisample_type
  while true do
    if ms_value == "NONE" or device_caps:CheckMultiSampleType(world.RenderName, color_format, depth_format, true, ms_value) then
      break
    elseif ms_value == "16_SAMPLES" then
      ms_value = "8_SAMPLES"
    elseif ms_value == "8_SAMPLES" then
      ms_value = "4_SAMPLES"
    elseif ms_value == "4_SAMPLES" then
      ms_value = "2_SAMPLES"
    else
      ms_value = "NONE"
    end
  end
  if ms_value == multisample_type then
    return true, ms_value
  else
    return false, ms_value
  end
end
function validate_shadow_texture()
  local world = nx_value("world")
  local device_caps = nx_value("device_caps")
  return device_caps:CheckDeviceFormat(world.RenderName, world.ColorFormat, "DEPTHSTENCIL", "TEXTURE", "D24X8")
end
function validate_hdr_texture()
  local world = nx_value("world")
  local device_caps = nx_value("device_caps")
  return device_caps:CheckDeviceFormat(world.RenderName, world.ColorFormat, "RENDERTARGET", "TEXTURE", "A16B16G16R16F")
end
function init_game_config_info(game_config)
  game_config.shortcut_page = 0
  game_config.shortcut_lockstate = 0
  game_config.camera_value = 0
  game_config.camera_angle = 100
  game_config.control_mode = 0
  game_config.lmouse_fight_mode = 0
  game_config.game_control_mode = 0
  game_config.max_camera_dis = 15
  game_config.camera_modify_y = 0
  game_config.lmouse_normal_mode = 0
  game_config.mr_rotate_mode = 0
  game_config.operate_control_mode = 1
  game_config.shortcut_keys1_control_mode = 1
  game_config.shortcut_keys2_control_mode = 1
  game_config.apply_shortcut_keys = 0
  game_config.lock_camera = 0
  game_config.is_first_open = 1
  game_config.inv_y_axis = 0
  game_config.play_movie_camera = 1
  game_config.vip_auto_play_qin = 2
  game_config.fight_open_info = 1
  game_config.fight_self_info = 1
  game_config.fight_self_damage = 1
  game_config.fight_self_effect = 1
  game_config.fight_self_recover = 1
  game_config.fight_self_stisle = 1
  game_config.fight_self_hits = 1
  game_config.fight_self_inout = 1
  game_config.fight_target_info = 1
  game_config.fight_target_damage = 1
  game_config.fight_target_effect = 1
  game_config.fight_target_stisle = 1
  game_config.fight_flutter_mode = 1
  game_config.right_fight_info = 1
  game_config.save_fight_info = 1
  game_config.show_range_buff_effect = 1
  game_config.autopath_useskill = 0
  game_config.autopath_clicktarget = 0
  game_config.autoselect_target = 1
  game_config.movie_animation_effect = 1
  game_config.open_movie_scene_start = 1
  game_config.open_animation_img = 1
  game_config.auto_equip_shotweapon = 0
  game_config.priority_skill_effect = 1
  game_config.start_keep_delay = 1
  game_config.keep_delay_sec = 100
  game_config.speedattack = 0
  game_config.fightparry = 0
  game_config.show_whole_chat_info = 1
  game_config.show_team_chat_info = 1
  game_config.play_chatprompt_sound = 1
  game_config.auto_showheadinfo = 0
  game_config.showhead_info = 1
  game_config.shownpc_name = 1
  game_config.shownpc_idname = 1
  game_config.shownpc_corpsename = 1
  game_config.showself_name = 1
  game_config.showself_titleid = 1
  game_config.showself_guild = 1
  game_config.showself_guildid = 1
  game_config.showfriends_name = 1
  game_config.showfriends_titleid = 1
  game_config.showfriends_guild = 1
  game_config.showfriends_guildid = 1
  game_config.showenemy_name = 1
  game_config.showenemy_titleid = 1
  game_config.showenemy_guild = 1
  game_config.showenemy_guildid = 1
  game_config.partner_name = 1
  game_config.showhead_hp = 1
  game_config.showplayer_hp = 1
  game_config.showself_hp = 0
  game_config.showfriends_hp = 0
  game_config.showenemy_hp = 1
  game_config.shownpc_hp = 1
  game_config.showfriendnpc_hp = 0
  game_config.showenemynpc_hp = 1
  game_config.showself_qg = 1
  game_config.showqg_always = 0
  game_config.show_adv_self_qg = 1
  game_config.show_adv_qg_always = 0
  game_config.head_zoom_value = 200
  game_config.show_tips_name = 1
  game_config.show_tips_school = 1
  game_config.show_tips_guildname = 1
  game_config.show_tips_guildtitle = 1
  game_config.show_tips_origin = 1
  game_config.show_tips_strength = 1
  game_config.show_tips_target = 1
  game_config.show_tips_force = 1
  game_config.show_tips_distance = 1
  game_config.show_tips_position = 0
  game_config.mouse_response_rate = 15
  game_config.pick_position = 1
  game_config.pick_autopick = 1
  game_config.prompt_friend_login = 1
  game_config.prompt_friend_logout = 1
  game_config.prompt_attent_login = 1
  game_config.prompt_attent_logout = 1
  game_config.prompt_guild_login = 1
  game_config.prompt_guild_logout = 1
  game_config.prompt_banners = 1
  game_config.prompt_buddynews = 1
  game_config.prompt_enemy_point = 1
  game_config.show_strength_cmp_photo = 0
  game_config.right_motionblur_info = 1
  game_config.dialog_alpha = 0
  game_config.watch_na = 600
  game_config.auto_small_jump = 1
  game_config.select_effect = 0
  game_config.story_record = 1
  game_config.is_check_equip_hardiness = 1
  game_config.guide_voice = 1
  game_config.ui_scale_enable = 0
  game_config.ui_scale_value = 100
  game_config.right_movieeffect_info = 1
  game_config.boss_help_indirect = 0
  game_config.is_auto_get_hongbao_place = 1
  game_config.watch_autona = 0
  game_config.filter_playerask = 0
end
function load_game_config_info(game_config, file_name, section_name)
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  if not ini:FindSection(nx_string(section_name)) then
    nx_destroy(ini)
    return false
  end
  local property_table = nx_property_list(game_config)
  for i = 1, table.getn(property_table) do
    local property_name = property_table[i]
    local property_value = nx_property(game_config, property_name)
    local property_type = nx_type(property_value)
    if ini:FindItem(section_name, property_name) then
      local new_value = ""
      if property_type == "boolean" then
        new_value = nx_boolean(ini:ReadString(section_name, property_name, ""))
      elseif property_type == "number" then
        new_value = ini:ReadFloat(section_name, property_name, 0)
      else
        new_value = ini:ReadString(section_name, property_name, "")
      end
      nx_set_property(game_config, property_name, new_value)
    end
  end
  nx_destroy(ini)
  return true
end
function save_game_config_item(file_name, section_name, key, value)
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  if not ini:FindSection(nx_string(section_name)) then
    nx_destroy(ini)
    return false
  end
  ini:WriteString(section_name, key, nx_string(value))
  ini:SaveToFile()
  nx_destroy(ini)
end
function load_game_config_item(file_name, section_name, key)
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  if not ini:FindSection(nx_string(section_name)) then
    nx_destroy(ini)
    return false
  end
  local val = ""
  val = ini:ReadString(section_name, key, "")
  nx_destroy(ini)
  return val
end
function save_game_config_info(game_config, file_name, section_name)
  return save_game_config(game_config, file_name, section_name)
end
function init_scene_box_light_config(game_config)
  game_config.ambient_red = 201
  game_config.ambient_green = 203
  game_config.ambient_blue = 255
  game_config.ambient_intensity = 1.71
  game_config.sunglow_red = 255
  game_config.sunglow_green = 198
  game_config.sunglow_blue = 163
  game_config.sunglow_intensity = 0.7
  game_config.sun_height = 160
  game_config.sun_azimuth = 21
  game_config.point_light_red = 15
  game_config.point_light_green = 63
  game_config.point_light_blue = 255
  game_config.point_light_range = 8
  game_config.point_light_intensity = 2
  game_config.point_light_pos_x = 2
  game_config.point_light_pos_y = 2.5
  game_config.point_light_pos_z = 0
  return true
end
function load_scene_box_light_config(game_config)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\systemset\\light_set.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  game_config.ambient_red = ini:ReadInteger("light", "ambient_red", game_config.ambient_red)
  game_config.ambient_green = ini:ReadInteger("light", "ambient_green", game_config.ambient_green)
  game_config.ambient_blue = ini:ReadInteger("light", "ambient_blue", game_config.ambient_blue)
  game_config.ambient_intensity = ini:ReadFloat("light", "ambient_intensity", game_config.ambient_intensity)
  game_config.sunglow_red = ini:ReadInteger("light", "sunglow_red", game_config.sunglow_red)
  game_config.sunglow_green = ini:ReadInteger("light", "sunglow_green", game_config.sunglow_green)
  game_config.sunglow_blue = ini:ReadInteger("light", "sunglow_blue", game_config.sunglow_blue)
  game_config.sunglow_intensity = ini:ReadFloat("light", "sunglow_intensity", game_config.sunglow_intensity)
  game_config.sun_height = ini:ReadInteger("light", "sun_height", game_config.sun_height)
  game_config.sun_azimuth = ini:ReadInteger("light", "sun_azimuth", game_config.sun_azimuth)
  game_config.point_light_red = ini:ReadInteger("light", "point_light_red", game_config.point_light_red)
  game_config.point_light_green = ini:ReadInteger("light", "point_light_green", game_config.point_light_green)
  game_config.point_light_blue = ini:ReadInteger("light", "point_light_blue", game_config.point_light_blue)
  game_config.point_light_range = ini:ReadFloat("light", "point_light_range", game_config.point_light_range)
  game_config.point_light_intensity = ini:ReadFloat("light", "point_light_intensity", game_config.point_light_intensity)
  game_config.point_light_pos_x = ini:ReadFloat("light", "point_light_pos_x", game_config.point_light_pos_x)
  game_config.point_light_pos_y = ini:ReadFloat("light", "point_light_pos_y", game_config.point_light_pos_y)
  game_config.point_light_pos_z = ini:ReadFloat("light", "point_light_pos_z", game_config.point_light_pos_z)
  nx_destroy(ini)
  return true
end
function load_select_server_info(game_config)
  if not nx_is_valid(game_config) then
    return false
  end
  local path = nx_work_path()
  if string.sub(path, string.len(path)) == "\\" then
    path = string.sub(path, 1, string.len(path) - 1)
  end
  local root_path, s1 = nx_function("ext_split_file_path", path)
  local file_name = root_path .. "updater\\updater_cfg\\server_last.ini"
  local ini = nx_create("IniDocumentUtf8")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local area_name = ini:ReadString(nx_widestr("main"), nx_widestr("area_name"), nx_widestr(""))
  local server_name = ini:ReadString(nx_widestr("main"), nx_widestr("server_name"), nx_widestr(""))
  if area_name ~= nx_widestr("") and server_name ~= nx_widestr("") then
    game_config.cur_area_name = area_name
    game_config.cur_server_name = server_name
    game_config.server_name = area_name .. nx_widestr("-") .. server_name
  end
  nx_destroy(ini)
  return true
end
