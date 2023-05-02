require("utils")
require("util_gui")
require("util_functions")
require("device_const")
function main_form_init(self)
  self.Fixed = false
  self.init_samescene = false
  self.first_open = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  local world = nx_value("world")
  local device_caps = nx_value("device_caps")
  self.init_samescene = false
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local game_config = nx_value("game_config")
  local left, top, width, height, maximized = world:GetWindowPos()
  if maximized then
    local screen_width, screen_height = nx_function("ext_get_screen_size")
    game_config.win_left = 0
    game_config.win_top = 0
    game_config.win_width = screen_width
    game_config.win_height = screen_height
  else
    game_config.win_left = left
    game_config.win_top = top
  end
  game_config.win_maximized = maximized
  nx_execute("game_config", "backup_game_config", game_config)
  self.multisample_combo.DropListBox:ClearString()
  self.multisample_combo.DropListBox:AddString(nx_widestr(0))
  local ms_table = {2, 4}
  for _, ms in pairs(ms_table) do
    local multisample_type = nx_string(ms) .. "_SAMPLES"
    local support = device_caps:CheckMultiSampleType(world.RenderName, world.ColorFormat, world.DepthFormat, world.Windowed, multisample_type)
    if support then
      self.multisample_combo.DropListBox:AddString(nx_widestr(ms))
    end
    if multisample_type == nx_string(game_config.multisample) then
      self.multisample_combo.Text = nx_widestr(ms)
    end
  end
  self.screen_size_combo.DropListBox:ClearString()
  refresh_screen_size_list(self)
  self.screen_size_combo.Text = nx_widestr(nx_string(game_config.win_width) .. "x" .. nx_string(game_config.win_height))
  self.first_open = true
  show_game_config(self, game_config, false)
  nx_execute(nx_current(), "show_fps", self)
  if 0 < self.shadow_quality_track.Value then
    self.cbtn_nolight.Checked = false
    self.cbtn_nolight.Enabled = false
  else
    self.cbtn_nolight.Enabled = true
  end
  self.tbar_samescene.Visible = false
  init_samescene_obj(self)
  return 1
end
function get_player()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    return client_player
  end
  return nx_null()
end
function init_samescene_obj(form)
  if not nx_is_valid(form) then
    return
  end
  local scene_obj = nx_value("scene_obj")
  if not nx_is_valid(scene_obj) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local max_obj = scene_obj.MaxNumOfSameScene
  local min_obj = scene_obj.MinNumOfSameScene
  local cur_value = scene_obj.NumOfSameScene
  if min_obj > cur_value then
    cur_value = min_obj
  end
  if max_obj < cur_value then
    cur_value = max_obj
  end
  form.init_samescene = true
  local tbar = form.tbar_samescene
  tbar.Visible = true
  tbar.Minimum = min_obj
  tbar.Maximum = max_obj
  tbar.Value = cur_value
end
function on_tbar_samescene_value_changed(tbar, old_value)
  local form = tbar.ParentForm
  if form.init_samescene == true then
    form.init_samescene = false
    return
  end
  local cur_value = tbar.Value
  local scene_obj = nx_value("scene_obj")
  if not nx_is_valid(scene_obj) then
    return
  end
  if cur_value > scene_obj.MaxNumOfSameScene then
    return
  end
  scene_obj.NumOfSameScene = cur_value
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function show_fps(form)
  local world = nx_value("world")
  local gui = world.MainGui
  while true do
    if not nx_is_valid(form) or not form.Visible then
      return false
    end
    form.average_fps = gui.FPS
    form.lbl_fps.Text = nx_widestr("FPS:" .. nx_decimals(gui.FPS, 0))
    nx_pause(1)
  end
  return true
end
function set_control_value(control, value)
  local name = nx_name(control)
  if name == "CheckButton" then
    control.Enabled = false
    control.Checked = value
    control.Enabled = true
  elseif name == "TrackBar" then
    control.Enabled = false
    control.Value = value
    control.Enabled = true
  elseif name == "Label" then
    control.Enabled = false
    control.Text = nx_widestr(value)
    control.Enabled = true
  end
end
function show_game_config(form, game_config, issampleschanged)
  if not nx_is_valid(form) then
    return
  end
  show_config_level(form, game_config)
  set_control_value(form.windowed_check, game_config.windowed)
  set_control_value(form.vsync_check, game_config.vsync)
  set_control_value(form.wide_angle_check, game_config.wide_angle)
  set_control_value(form.visual_radius_track, (game_config.visual_radius - 50) * 0.5)
  set_control_value(form.grass_radius_track, (game_config.grass_radius - 50) * 2)
  set_control_value(form.grass_lod_track, game_config.grass_lod * 100)
  set_control_value(form.shadow_quality_track, game_config.shadow_quality)
  set_control_value(form.water_quality_track, game_config.water_quality)
  set_control_value(form.effect_quality_track, game_config.effect_quality)
  set_control_value(form.texture_quality_track, game_config.texture_quality)
  form.fxaa_check.Enabled = false
  if game_config.fxaa_quality == 0 then
    form.fxaa_check.Checked = false
  else
    form.fxaa_check.Checked = true
  end
  form.fxaa_check.Enabled = true
  if game_config.multisample == "16_SAMPLES" then
    form.multisample_combo.Text = nx_widestr("16")
  elseif game_config.multisample == "8_SAMPLES" then
    form.multisample_combo.Text = nx_widestr("8")
  elseif game_config.multisample == "4_SAMPLES" then
    form.multisample_combo.Text = nx_widestr("4")
  elseif game_config.multisample == "2_SAMPLES" then
    form.multisample_combo.Text = nx_widestr("2")
  elseif game_config.multisample == "NONE" then
    form.multisample_combo.Text = nx_widestr("0")
  end
  local scene = get_cur_main_scene()
  if nx_is_valid(scene) and issampleschanged then
    nx_execute("game_config", "set_multisample", scene)
  end
  local anisotropic_value = 0
  if game_config.anisotropic == 2 then
    anisotropic_value = 1
  elseif game_config.anisotropic == 4 then
    anisotropic_value = 2
  elseif game_config.anisotropic == 8 then
    anisotropic_value = 3
  elseif game_config.anisotropic == 16 then
    anisotropic_value = 4
  end
  set_control_value(form.anisotropic_track, anisotropic_value)
  set_control_value(form.filter_check, game_config.filter_enable)
  set_control_value(form.bloom_check, game_config.bloom_enable)
  set_control_value(form.screen_blur_check, game_config.screen_blur_enable)
  set_control_value(form.volume_lighting_check, game_config.volume_lighting_enable)
  set_control_value(form.hdr_check, game_config.hdr_enable)
  set_control_value(form.ssao_check, game_config.ssao_enable)
  set_control_value(form.prelight_check, game_config.prelight_enable)
  set_control_value(form.foliage_blend_check, game_config.foliage_blend)
  set_control_value(form.hardware_accel_check, game_config.hardware_accel)
  set_control_value(form.cbtn_nolight, not game_config.nolight_enable)
  set_control_value(form.cbtn_physics, game_config.physics_enable)
  if game_config.level == "supersimple" then
    form.cbtn_nolight.Enabled = true
    form.weather_check.Enabled = false
    form.weather_check.Checked = false
    game_config.weather_enable = form.weather_check.Checked
  elseif game_config.level == "simple" then
    form.cbtn_nolight.Enabled = true
    form.weather_check.Enabled = false
    form.weather_check.Checked = false
    game_config.weather_enable = form.weather_check.Checked
  elseif game_config.level == "low" then
    form.cbtn_nolight.Enabled = true
    form.weather_check.Enabled = false
    form.weather_check.Checked = false
    game_config.weather_enable = form.weather_check.Checked
  elseif game_config.level == "middle" then
    form.cbtn_nolight.Enabled = false
    form.weather_check.Enabled = false
    form.weather_check.Checked = false
    form.weather_check.Enabled = true
    game_config.weather_enable = form.weather_check.Checked
  elseif game_config.level == "high" then
    form.cbtn_nolight.Enabled = false
    form.weather_check.Enabled = false
    form.weather_check.Checked = true
    form.weather_check.Enabled = true
    game_config.weather_enable = form.weather_check.Checked
  elseif game_config.level == "ultra" then
    form.cbtn_nolight.Enabled = false
    form.weather_check.Enabled = false
    form.weather_check.Checked = true
    form.weather_check.Enabled = true
    game_config.weather_enable = form.weather_check.Checked
  else
    form.cbtn_nolight.Enabled = true
    form.weather_check.Enabled = false
    form.weather_check.Checked = game_config.weather_enable
    form.weather_check.Enabled = true
  end
  can_use_physics(form)
  if not form.first_open then
    local weather_manager = nx_value("weather_manager")
    if nx_is_valid(weather_manager) then
      weather_manager:UpdateWeatherSystem()
    end
  else
    form.first_open = false
  end
  return true
end
function show_config_level(form, game_config)
  form.config_supersimple_check.Enabled = false
  form.config_simple_check.Enabled = false
  form.config_low_check.Enabled = false
  form.config_middle_check.Enabled = false
  form.config_high_check.Enabled = false
  form.config_ultra_check.Enabled = false
  form.config_personal_check.Enabled = false
  if game_config.level == "supersimple" then
    form.config_supersimple_check.Checked = true
  elseif game_config.level == "simple" then
    form.config_simple_check.Checked = true
  elseif game_config.level == "low" then
    form.config_low_check.Checked = true
  elseif game_config.level == "middle" then
    form.config_middle_check.Checked = true
  elseif game_config.level == "high" then
    form.config_high_check.Checked = true
  elseif game_config.level == "ultra" then
    form.config_ultra_check.Checked = true
  else
    form.config_personal_check.Checked = true
  end
  form.config_supersimple_check.Enabled = true
  form.config_simple_check.Enabled = true
  form.config_low_check.Enabled = true
  form.config_middle_check.Enabled = true
  form.config_high_check.Enabled = true
  form.config_ultra_check.Enabled = true
  form.config_personal_check.Enabled = true
  return true
end
function change_config_level(form, level_name)
  local game_config = nx_value("game_config")
  game_config.level = level_name
  show_config_level(form, game_config)
  if game_config.level == "personal" then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_system_xiaoguo_tips_3"), 2)
    end
  end
  return true
end
function on_ok_btn_click(self)
  local form = self.ParentForm
  local game_config = nx_value("game_config")
  local game_config_info = nx_value("game_config_info")
  local game_config_backup = nx_value("game_config_backup")
  if form.average_fps < 20 and game_config.level ~= "supersimple" and game_config.level ~= "simple" and game_config.level ~= "low" then
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, gui.TextManager:GetText("ui_frame_info_hint"))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "cancel" then
      return 0
    end
  end
  local ms_support, ms_value = nx_call("game_config", "validate_multisample", game_config.multisample)
  if not ms_support then
    game_config.multisample = ms_value
  end
  if game_config_backup.win_width ~= game_config.win_width or game_config_backup.win_height ~= game_config.win_height or game_config_backup.windowed ~= game_config.windowed then
    nx_execute("game_config", "set_display", game_config)
  end
  if game_config.win_width == 800 and game_config.win_height == 600 or game_config.win_width == 960 and game_config.win_height == 600 or game_config.win_width == 1024 and game_config.win_height == 768 then
    game_config_info.ui_scale_enable = 1
    game_config_info.ui_scale_value = 100
    local form = util_get_form("form_stage_main\\form_system\\form_system_Fight_info_Setting", false)
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_system\\form_system_Fight_info_Setting", "show_to_form", form)
    end
  end
  nx_execute("game_config", "save_game_config", game_config, "system_set.ini", "main")
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  nx_execute("form_stage_main\\form_camera\\form_movie_save", "Save_movie_config", true)
  close_form(self.ParentForm)
  local world = nx_value("world")
  world:ClearRenderResource()
  local weather_manager = nx_value("weather_manager")
  if not nx_is_valid(weather_manager) then
    return 0
  end
  local IsLua = weather_manager:IsLua()
  if not IsLua then
    weather_manager:UpdateWeatherSystem()
  elseif game_config.weather_enable then
    local weather_set_data = nx_value("weather_set_data")
    if not nx_is_valid(weather_set_data) then
      nx_execute("terrain\\weather_set", "initialize_weather_data")
    end
  else
    local weather_set_data = nx_value("weather_set_data")
    if nx_is_valid(weather_set_data) then
      nx_call("terrain\\weather_set", "delete_weather_data")
      local scene = world.MainScene
      local terrain = scene.terrain
      nx_execute("terrain\\weather_set", "resume_weather_state", scene, terrain.FilePath, game_config)
    end
  end
  return 1
end
function on_cancel_btn_click(self)
  local game_config = nx_value("game_config")
  local game_config_backup = nx_value("game_config_backup")
  local world = nx_value("world")
  local scene = world.MainScene
  nx_execute("game_config", "restore_game_config", game_config)
  nx_execute("game_config", "apply_performance_config", scene, game_config)
  close_form(self.ParentForm)
  local world = nx_value("world")
  world:ClearRenderResource()
  local weather_manager = nx_value("weather_manager")
  if nx_is_valid(weather_manager) then
    weather_manager:UpdateWeatherSystem()
  end
  return 1
end
function on_close_btn_click(self)
  return on_cancel_btn_click(self)
end
function close_form(form)
  form.screen_size_combo.DroppedDown = false
  form.multisample_combo.DroppedDown = false
  util_show_form("form_stage_main\\form_system\\form_system_setting", false)
  return true
end
function get_device_enable(set_type)
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return false
  end
  local append_memory_size = 0
  if world.may_device_level > world.device_level then
    nx_log("world.may_device_level=" .. nx_string(world.may_device_level))
    if world.may_device_level >= 5 then
      append_memory_size = 500
    elseif world.may_device_level >= 4 then
      append_memory_size = 400
    elseif world.may_device_level >= 3 then
      append_memory_size = 300
    elseif world.may_device_level >= 2 then
      append_memory_size = 200
    elseif world.may_device_level >= 1 then
      append_memory_size = 100
    end
  end
  local dev_caps = nx_value("device_caps")
  if DEVICE_LOW_CONFIG == set_type then
    if 200 > dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory + append_memory_size then
      return false
    else
      return true
    end
  elseif DEVICE_MIDDLE_CONFIG == set_type then
    if 200 > dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory + append_memory_size then
      return false
    else
      return true
    end
  elseif DEVICE_HIGH_CONFIG == set_type then
    if 400 > dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory + append_memory_size then
      return false
    else
      return true
    end
  elseif DEVICE_ULTRA_CONFIG == set_type then
    if dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory + append_memory_size < 480 then
      return false
    else
      return true
    end
  elseif DEVICE_MULTISAMPLE_CONFIG == set_type or DEVICE_FXAA_CONFIG == set_type or DEVICE_FILTER_CONFIG == set_type or DEVICE_BLOOM_CONFIG == set_type or DEVICE_SCREEN_BLUR_CONFIG == set_type then
    if 200 > dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory + append_memory_size then
      return false
    else
      return true
    end
  elseif DEVICE_VOLUME_LIGHTING_CONFIG == set_type then
    if 400 > dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory + append_memory_size then
      return false
    else
      return true
    end
  elseif DEVICE_HDR_CONFIG == set_type or DEVICE_SSAO_CONFIG == set_type then
    if dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory + append_memory_size < 480 then
      return false
    else
      return true
    end
  elseif DEVICE_PRELIGHT_CONFIG == set_type or DEVICE_SHADOW_QUALITY_CONFIG == set_type or DEVICE_WATER_QUALITY_CONFIG == set_type then
    if 200 > dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory + append_memory_size then
      return false
    else
      return true
    end
  end
  return false
end
function on_config_supersimple_check_checked_changed(self)
  if not self.Checked then
    return 0
  end
  local world = nx_value("world")
  local scene = world.MainScene
  local game_config = nx_value("game_config")
  local supersimple_config = nx_value("game_config_supersimple")
  game_config.level = "supersimple"
  local issampleschanged = supersimple_config.multisample == game_config.multisample
  nx_call("game_config", "copy_performance_config", game_config, supersimple_config)
  nx_call("game_config", "apply_performance_config", scene, game_config)
  show_game_config(self.ParentForm, game_config, issampleschanged)
end
function on_config_simple_check_checked_changed(self)
  if not self.Checked then
    return 0
  end
  local world = nx_value("world")
  local scene = world.MainScene
  local game_config = nx_value("game_config")
  local simple_config = nx_value("game_config_simple")
  game_config.level = "simple"
  local issampleschanged = simple_config.multisample == game_config.multisample
  nx_call("game_config", "copy_performance_config", game_config, simple_config)
  nx_call("game_config", "apply_performance_config", scene, game_config)
  show_game_config(self.ParentForm, game_config, issampleschanged)
  return 1
end
function on_config_low_check_checked_changed(self)
  local gui = nx_value("gui")
  if not self.Checked then
    return 0
  end
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_LOW_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  local low_config = nx_value("game_config_low")
  game_config.level = "low"
  local issampleschanged = low_config.multisample == game_config.multisample
  local world = nx_value("world")
  local scene = world.MainScene
  nx_execute("game_config", "copy_performance_config", game_config, low_config)
  nx_execute("game_config", "apply_performance_config", scene, game_config)
  show_game_config(self.ParentForm, game_config, issampleschanged)
  return 1
end
function on_config_middle_check_checked_changed(self)
  local gui = nx_value("gui")
  if not self.Checked then
    return 0
  end
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_MIDDLE_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local world = nx_value("world")
  local scene = world.MainScene
  local game_config = nx_value("game_config")
  local middle_config = nx_value("game_config_middle")
  game_config.level = "middle"
  local issampleschanged = middle_config.multisample == game_config.multisample
  nx_execute("game_config", "copy_performance_config", game_config, middle_config)
  nx_execute("game_config", "apply_performance_config", scene, game_config)
  show_game_config(self.ParentForm, game_config, issampleschanged)
  return 1
end
function on_config_high_check_checked_changed(self)
  local gui = nx_value("gui")
  if not self.Checked then
    return 0
  end
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_HIGH_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local world = nx_value("world")
  local scene = world.MainScene
  local game_config = nx_value("game_config")
  local high_config = nx_value("game_config_high")
  game_config.level = "high"
  local issampleschanged = high_config.multisample == game_config.multisample
  nx_execute("game_config", "copy_performance_config", game_config, high_config)
  nx_execute("game_config", "apply_performance_config", scene, game_config)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_system_xiaoguo_tips_1"), 2)
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_system_xiaoguo_tips_2"), 2)
  end
  show_game_config(self.ParentForm, game_config, issampleschanged)
  return 1
end
function on_config_ultra_check_checked_changed(self)
  local gui = nx_value("gui")
  if not self.Checked then
    return 0
  end
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_ULTRA_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local world = nx_value("world")
  local scene = world.MainScene
  local game_config = nx_value("game_config")
  local ultra_config = nx_value("game_config_ultra")
  game_config.level = "ultra"
  local issampleschanged = ultra_config.multisample == game_config.multisample
  nx_execute("game_config", "copy_performance_config", game_config, ultra_config)
  nx_execute("game_config", "apply_performance_config", scene, game_config)
  show_game_config(self.ParentForm, game_config, issampleschanged)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_system_xiaoguo_tips_1"), 2)
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_system_xiaoguo_tips_2"), 2)
  end
  return 1
end
function on_config_personal_check_checked_changed(self)
  if not self.Checked then
    return 0
  end
  local game_config = nx_value("game_config")
  game_config.level = "personal"
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_system_xiaoguo_tips_3"), 2)
  end
  return 1
end
function refresh_screen_size_list(form)
  local frequency = nx_function("ext_get_cur_system_frequency")
  local result_screen = nx_function("ext_enum_screen_size_byfrequency", nx_int(800), nx_int(600), nx_int(frequency))
  local table_result = util_split_string(result_screen, ",")
  for i = 1, table.maxn(table_result) / 2 do
    for j = i + 1, table.maxn(table_result) / 2 do
      if table_result[i * 2 - 1] * table_result[i * 2] > table_result[j * 2 - 1] * table_result[j * 2] then
        local _a, _b = table_result[i * 2 - 1], table_result[i * 2]
        table_result[i * 2 - 1], table_result[i * 2] = table_result[j * 2 - 1], table_result[j * 2]
        table_result[j * 2 - 1], table_result[j * 2] = _a, _b
      end
    end
  end
  local count = table.maxn(table_result) / 2
  local list = form.screen_size_combo.DropListBox
  list:ClearString()
  for i = 1, count do
    list:AddString(nx_widestr(nx_string(table_result[i * 2 - 1]) .. "x" .. nx_string(table_result[i * 2])))
  end
  return true
end
function on_screen_size_combo_selected(self)
  local game_config = nx_value("game_config")
  local gui = nx_value("gui")
  local form = self.ParentForm
  local screen_size = nx_string(self.Text)
  local table_result = util_split_string(screen_size, "x")
  game_config.win_width = nx_number(table_result[1])
  game_config.win_height = nx_number(table_result[2])
  return 1
end
function on_multisample_combo_selected(self)
  local gui = nx_value("gui")
  local value = nx_number(self.Text)
  if 0 < value then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_MULTISAMPLE_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  local value = nx_number(self.Text)
  local old_multisample = game_config.multisample
  if 0 < value then
    game_config.multisample = nx_string(self.Text) .. "_SAMPLES"
  else
    game_config.multisample = "NONE"
  end
  local ms_support, ms_value = nx_call("game_config", "validate_multisample", game_config.multisample)
  if not ms_support then
    game_config.multisample = ms_value
    if ms_value == "16_SAMPLES" then
      set_control_value(self, 16)
    elseif ms_value == "8_SAMPLES" then
      set_control_value(self, 8)
    elseif ms_value == "4_SAMPLES" then
      set_control_value(self, 4)
    elseif ms_value == "2_SAMPLES" then
      set_control_value(self, 2)
    elseif ms_value == "NONE" then
      set_control_value(self, 0)
    end
    disp_error(gui.TextManager:GetText("ui_system_setting_text2"))
  end
  if game_config.multisample ~= old_multisample then
    local scene = get_cur_main_scene()
    nx_execute("game_config", "set_multisample", scene)
  end
  change_config_level(self.Parent, "personal")
  return 1
end
function on_fxaa_check_checked_changed(self)
  local gui = nx_value("gui")
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_FXAA_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  if self.Checked then
    game_config.fxaa_quality = 1
  else
    game_config.fxaa_quality = 0
  end
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_fxaa_quality", scene, game_config.fxaa_quality)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_windowed_check_checked_changed(self)
  local game_config = nx_value("game_config")
  local gui = nx_value("gui")
  local form = self.ParentForm
  local screen_size_combo = form.screen_size_combo
  local screen_size = nx_string(screen_size_combo.Text)
  local table_result = util_split_string(screen_size, "x")
  local win_width = nx_number(table_result[1])
  local win_height = nx_number(table_result[2])
  game_config.windowed = self.Checked
  return 1
end
function on_vsync_check_checked_changed(self)
  local game_config = nx_value("game_config")
  game_config.vsync = self.Checked
  nx_execute("game_config", "set_display", game_config)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_wide_angle_check_checked_changed(self)
  local game_config = nx_value("game_config")
  game_config.wide_angle = self.Checked
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_wide_angle", scene, game_config.wide_angle)
  return 1
end
function on_filter_check_checked_changed(self)
  local gui = nx_value("gui")
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_FILTER_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  game_config.filter_enable = self.Checked
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_filter_enable", scene, game_config.filter_enable)
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_bloom_check_checked_changed(self)
  local gui = nx_value("gui")
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_BLOOM_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  game_config.bloom_enable = self.Checked
  local scene = get_cur_main_scene()
  local form = self.ParentForm
  form.hdr_check.Checked = self.Checked
  nx_execute("game_config", "set_bloom_enable", scene, game_config.bloom_enable)
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_screen_blur_check_checked_changed(self)
  local gui = nx_value("gui")
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_SCREEN_BLUR_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  game_config.screen_blur_enable = self.Checked
  if not nx_call("game_config", "validate_multisample", game_config.multisample) then
    disp_error(gui.TextManager:GetText("ui_system_setting_text3"))
    game_config.screen_blur_enable = false
    set_control_value(self, false)
    return 0
  end
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_screen_blur_enable", scene, game_config.screen_blur_enable)
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_volume_lighting_check_checked_changed(self)
  local gui = nx_value("gui")
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_VOLUME_LIGHTING_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  game_config.volume_lighting_enable = self.Checked
  if not nx_call("game_config", "validate_multisample", game_config.multisample) then
    disp_error(gui.TextManager:GetText("ui_system_setting_text3"))
    game_config.volume_lighting_enable = false
    set_control_value(self, false)
    return 0
  end
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_volume_lighting_enable", scene, game_config.volume_lighting_enable)
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_hdr_check_checked_changed(self)
  local gui = nx_value("gui")
  if self.Checked and not nx_call("game_config", "validate_hdr_texture") then
    disp_error(gui.TextManager:GetText("ui_system_setting_text2"))
    set_control_value(self, false)
    return 0
  end
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_HDR_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  game_config.hdr_enable = self.Checked
  if not nx_call("game_config", "validate_multisample", game_config.multisample) then
    disp_error(gui.TextManager:GetText("ui_system_setting_text3"))
    game_config.hdr_enable = false
    set_control_value(self, false)
    return 0
  end
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_hdr_enable", scene, game_config.hdr_enable)
  local form = self.ParentForm
  form.bloom_check.Checked = form.hdr_check.Checked
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_ssao_check_checked_changed(self)
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  if self.Checked and game_config.shadow_quality == 0 then
    disp_error(gui.TextManager:GetText("ui_system_setting_text4"))
    set_control_value(self, false)
    return 0
  end
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_SSAO_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  game_config.ssao_enable = self.Checked
  if not nx_call("game_config", "validate_multisample", game_config.multisample) then
    disp_error(gui.TextManager:GetText("ui_system_setting_text3"))
    game_config.ssao_enable = false
    set_control_value(self, false)
    return 0
  end
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_ssao_enable", scene, game_config.ssao_enable)
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_prelight_check_checked_changed(self)
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  if self.Checked and game_config.shadow_quality == 0 then
    disp_error(gui.TextManager:GetText("ui_system_setting_text4"))
    set_control_value(self, false)
    return 0
  end
  if self.Checked then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_PRELIGHT_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  game_config.prelight_enable = self.Checked
  if not nx_call("game_config", "validate_multisample", game_config.multisample) then
    disp_error(gui.TextManager:GetText("ui_system_setting_text3"))
    game_config.prelight_enable = false
    set_control_value(self, false)
    return 0
  end
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_prelight_enable", scene, game_config.prelight_enable)
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_foliage_blend_check_checked_changed(self)
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  game_config.foliage_blend = self.Checked
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_foliage_blend", scene, game_config.foliage_blend)
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_cbtn_nolight_checked_changed(self)
  local game_config = nx_value("game_config")
  game_config.nolight_enable = not self.Checked
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_nolight_enable", scene, game_config.nolight_enable)
  change_config_level(self.ParentForm, "personal")
  return 1
end
function on_cbtn_physics_checked_changed(self)
  local game_config = nx_value("game_config")
  local form = self.ParentForm
  if not can_use_physics(self.ParentForm) then
    game_config.physics_enable = false
    nx_execute("game_config", "set_physics_enable", false)
    return
  end
  local flag = false
  if self.Checked and not nx_function("ext_is_64bit_system") then
    local device_caps = nx_value("device_caps")
    if not nx_is_valid(device_caps) then
      return
    end
    local table_mem = device_caps:QueryMemory()
    if table_mem ~= nil and table.getn(table_mem) > 0 then
      if table_mem[2] < 3000 then
        flag = show_dialog("ui_neicunbuzutishi_1")
      else
        flag = show_dialog("ui_neicunbuzutishi_2")
      end
      if not flag then
        game_config.physics_enable = false
        nx_execute("game_config", "set_physics_enable", false)
        set_control_value(self, false)
        return
      end
    end
  end
  game_config.physics_enable = self.Checked
  nx_execute("game_config", "set_physics_enable", game_config.physics_enable)
  change_config_level(self.ParentForm, "personal")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local gui = nx_value("gui")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("16569"), 2)
  end
  return 1
end
function show_dialog(string_id)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, gui.TextManager:GetText(string_id))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
end
function on_cbtn_physics_get_capture(self)
  if not self.Enabled then
    local gui = nx_value("gui")
    local form = self.ParentForm
    local text = nx_widestr("")
    local device_caps = nx_value("device_caps")
    if not nx_is_valid(device_caps) then
      return
    end
    if not device_caps.SupportPhysxCloth then
      text = gui.TextManager:GetText("ui_wuliyinqing_tips_3")
    end
    local num = nx_function("ext_get_logic_instances")
    if 1 < num then
      text = gui.TextManager:GetText("16570") .. nx_widestr("<br>") .. text
    end
    nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 0, form)
  end
end
function on_cbtn_physics_lost_capture(self)
  if not self.Enabled then
    nx_execute("tips_game", "hide_tip", self.ParentForm)
  end
end
function can_support_physics()
  local device_caps = nx_value("device_caps")
  if not nx_is_valid(device_caps) then
    return false
  end
  if not device_caps.SupportPhysxCloth then
    return false
  end
  local num = nx_function("ext_get_logic_instances")
  if 1 < num then
    return false
  end
  return true
end
function can_use_physics(form)
  if can_support_physics() then
    form.cbtn_physics.Enabled = true
    return true
  else
    form.cbtn_physics.Checked = false
    form.cbtn_physics.Enabled = false
    nx_execute("game_config", "set_physics_enable", false)
    return false
  end
end
function on_hardware_accel_check_checked_changed(self)
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  if self.Checked then
    local world = nx_value("world")
    if not world.SupportOcclusionQuery then
      disp_error(gui.TextManager:GetText("ui_system_setting_text2"))
      set_control_value(self, false)
      return 0
    end
  end
  game_config.hardware_accel = self.Checked
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_hardware_accel", scene, game_config.hardware_accel)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_visual_radius_track_value_changed(self)
  local game_config = nx_value("game_config")
  game_config.visual_radius = 50 + self.Value * 2
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_visual_radius", scene, game_config.visual_radius)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_grass_radius_track_value_changed(self)
  local game_config = nx_value("game_config")
  game_config.grass_radius = 50 + self.Value * 0.5
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_grass_radius", scene, game_config.grass_radius)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_grass_lod_track_value_changed(self)
  local game_config = nx_value("game_config")
  game_config.grass_lod = self.Value * 0.01
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_grass_lod", scene, game_config.grass_lod)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_shadow_quality_track_value_changed(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  if self.Value > 0 then
    form.cbtn_nolight.Checked = false
    form.cbtn_nolight.Enabled = false
  else
    form.cbtn_nolight.Enabled = true
  end
  if self.Value >= 1 and not nx_call("game_config", "validate_shadow_texture") then
    disp_error(gui.TextManager:GetText("ui_system_setting_text2"))
    set_control_value(self, 0)
    return 0
  end
  if self.Value >= 1 then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_SHADOW_QUALITY_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  game_config.shadow_quality = self.Value
  if not nx_call("game_config", "validate_multisample", game_config.multisample) then
    disp_error(gui.TextManager:GetText("ui_system_setting_text3"))
    game_config.shadow_quality = 0
    set_control_value(self, 0)
    return 0
  end
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_shadow_quality", scene, game_config.shadow_quality)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_water_quality_track_value_changed(self)
  local gui = nx_value("gui")
  if self.Value >= 2 then
    local dev_caps = nx_value("device_caps")
    if not get_device_enable(DEVICE_WATER_QUALITY_CONFIG) then
      disp_error(gui.TextManager:GetText("ui_system_setting_text1"))
      set_control_value(self, false)
      return 0
    end
  end
  local game_config = nx_value("game_config")
  game_config.water_quality = self.Value
  if not nx_call("game_config", "validate_multisample", game_config.multisample) then
    disp_error(gui.TextManager:GetText("ui_system_setting_text3"))
    game_config.water_quality = 0
    set_control_value(self, 0)
    return 0
  end
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_water_quality", scene, game_config.water_quality)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_effect_quality_track_value_changed(self)
  local game_config = nx_value("game_config")
  game_config.effect_quality = self.Value
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_effect_quality", scene, game_config.effect_quality)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_texture_quality_track_value_changed(self)
  local game_config = nx_value("game_config")
  game_config.texture_quality = self.Value
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_texture_quality", scene, game_config.texture_quality)
  change_config_level(self.Parent, "personal")
  return 1
end
function on_anisotropic_track_value_changed(self)
  local game_config = nx_value("game_config")
  local val = self.Value
  local level = 0
  if val == 1 then
    level = 2
  elseif val == 2 then
    level = 4
  elseif val == 3 then
    level = 8
  elseif val == 4 then
    level = 16
  end
  game_config.anisotropic = level
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_anisotropic", scene, game_config.anisotropic)
  change_config_level(self.Parent, "personal")
  return 1
end
function get_cur_main_scene()
  local world = nx_value("world")
  return world.MainScene
end
function on_gui_size_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 1
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function weather_checked_changed(self)
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    game_config.weather_enable = self.Checked
  end
  change_config_level(self.ParentForm, "personal")
  local weather_manager = nx_value("weather_manager")
  if nx_is_valid(weather_manager) then
    weather_manager:UpdateWeatherSystem()
  end
end
function on_tbar_samescene_lost_capture(pbar)
  nx_execute("tips_game", "hide_tip")
end
function on_tbar_samescene_get_capture(pbar)
  local x = pbar.AbsLeft
  local y = pbar.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_samescene_tip")
  nx_execute("tips_game", "show_text_tip", text, x, y)
end
