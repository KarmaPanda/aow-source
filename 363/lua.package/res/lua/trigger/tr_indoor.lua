function on_init(self, para)
  local scene = nx_value("scene")
  if not nx_is_valid(scene) then
    scene = nx_value("game_scene")
  end
  self.scene = scene
  return 1
end
function on_timer(self, seconds, para)
  local scene = self.scene
  if not nx_is_valid(scene) then
    return 0
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return 0
  end
  local camera_x = nx_float(camera.PositionX)
  local camera_y = nx_float(camera.PositionY)
  local camera_z = nx_float(camera.PositionZ)
  local trigger_x = nx_float(self.PositionX)
  local trigger_y = nx_float(self.PositionY)
  local trigger_z = nx_float(self.PositionZ)
  local trigger_box_x = nx_float(self.SizeX) / nx_float(2)
  local trigger_box_y = nx_float(self.SizeY) / nx_float(2)
  local trigger_box_z = nx_float(self.SizeZ) / nx_float(2)
  if nx_float(camera_x) > nx_float(trigger_x - trigger_box_x) and nx_float(camera_x) < nx_float(trigger_x + trigger_box_x) and nx_float(camera_z) > nx_float(trigger_z - trigger_box_z) and nx_float(camera_z) < nx_float(trigger_z + trigger_box_z) and nx_float(camera_y) < nx_float(trigger_y + trigger_box_y) then
  else
    return 0
  end
  local weather = scene.Weather
  local ambient_factor = 0.5
  if para ~= "" then
    local pos = string.find(para, ",")
    if pos ~= nil then
      ambient_factor = nx_number(string.sub(para, 1, pos - 1))
    end
  end
  local dark_ambient = weather.ambient_intensity * ambient_factor
  if weather.AmbientIntensity == dark_ambient then
    return
  end
  if nx_running("trigger\\tr_indoor", "leave_light_tune", self) then
    nx_kill("trigger\\tr_indoor", "leave_light_tune", self)
  end
  if nx_running("trigger\\tr_indoor", "entry_light_tune", self) then
    nx_kill("trigger\\tr_indoor", "entry_light_tune", self)
  end
  if not nx_running("trigger\\tr_indoor", "entry_light_tune", self) then
    nx_execute("trigger\\tr_indoor", "entry_light_tune", self, weather)
  end
  return 1
end
function on_entry(self, player, para)
  local scene = self.scene
  if not nx_is_valid(scene) then
    return 0
  end
  if para == "cull" then
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      local terrain = scene.terrain
      terrain.HorizontalCulling = false
    end
    return 1
  end
  local weather = scene.Weather
  local count = 0
  if nx_find_custom(weather, "indoor_count") then
    count = weather.indoor_count
  end
  weather.indoor_count = count + 1
  if nx_running("trigger\\tr_indoor", "leave_light_tune", self) then
    nx_kill("trigger\\tr_indoor", "leave_light_tune", self)
  end
  if nx_running("trigger\\tr_indoor", "entry_light_tune", self) then
    nx_kill("trigger\\tr_indoor", "entry_light_tune", self)
  end
  if not nx_running("trigger\\tr_indoor", "entry_light_tune", self) then
    nx_execute("trigger\\tr_indoor", "entry_light_tune", self, weather)
  end
  return 1
end
function on_leave(self, player, para)
  local scene = self.scene
  if not nx_is_valid(scene) then
    return 0
  end
  if para == "cull" then
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      local terrain = scene.terrain
      terrain.HorizontalCulling = true
    end
    return 1
  end
  local weather = scene.Weather
  local count = weather.indoor_count
  if 0 < count then
    weather.indoor_count = count - 1
  end
  if 0 < weather.indoor_count then
    return 0
  end
  if not nx_running("trigger\\tr_indoor", "leave_light_tune", self) then
    nx_execute("trigger\\tr_indoor", "leave_light_tune", self, weather)
  end
  return 1
end
function entry_light_tune(trigger, weather)
  local ambient_factor = 0.5
  local diffuse_factor = 0.1
  local para = trigger.Parameter
  if para ~= "" then
    local pos = string.find(para, ",")
    if pos ~= nil then
      ambient_factor = nx_number(string.sub(para, 1, pos - 1))
      diffuse_factor = nx_number(string.sub(para, pos + 1))
    end
  end
  local dark_ambient = weather.ambient_intensity * ambient_factor
  local dark_diffuse = weather.sunglow_intensity * diffuse_factor
  local dark_specular = weather.specular_intensity * diffuse_factor
  local delta_ambient = weather.AmbientIntensity - dark_ambient
  local delta_diffuse = weather.SunGlowIntensity - dark_diffuse
  local delta_specular = weather.SpecularIntensity - dark_specular
  local ended = false
  local lerp = 1
  while not ended do
    local seconds = nx_strict_pause(0)
    if not nx_is_valid(trigger) or not nx_is_valid(weather) then
      return false
    end
    lerp = lerp - seconds
    if lerp < 0 then
      lerp = 0
      ended = true
    end
    weather.AmbientIntensity = dark_ambient + delta_ambient * lerp
    weather.SunGlowIntensity = dark_diffuse + delta_diffuse * lerp
    weather.SpecularIntensity = dark_specular + delta_specular * lerp
  end
  return true
end
function leave_light_tune(trigger, weather)
  local delta_ambient = weather.ambient_intensity - weather.AmbientIntensity
  local delta_diffuse = weather.sunglow_intensity - weather.SunGlowIntensity
  local delta_specular = weather.specular_intensity - weather.SpecularIntensity
  local ended = false
  local lerp = 1
  while not ended do
    local seconds = nx_strict_pause(0)
    if not nx_is_valid(trigger) or not nx_is_valid(weather) then
      if nx_is_valid(weather) then
        weather.AmbientIntensity = weather.ambient_intensity
        weather.SunGlowIntensity = weather.sunglow_intensity
        weather.SpecularIntensity = weather.specular_intensity
      end
      return false
    end
    lerp = lerp - seconds
    if lerp < 0 then
      lerp = 0
      ended = true
    end
    weather.AmbientIntensity = weather.ambient_intensity - delta_ambient * lerp
    weather.SunGlowIntensity = weather.sunglow_intensity - delta_diffuse * lerp
    weather.SpecularIntensity = weather.specular_intensity - delta_specular * lerp
  end
  return true
end
function light_tune(trigger, weather)
  local ambient_factor = 0.5
  local diffuse_factor = 0.1
  local para = trigger.Parameter
  if para ~= "" then
    local pos = string.find(para, ",")
    if pos ~= nil then
      ambient_factor = nx_number(string.sub(para, 1, pos - 1))
      diffuse_factor = nx_number(string.sub(para, pos + 1))
    end
  end
  local dark_ambient = weather.ambient_intensity * ambient_factor
  local dark_diffuse = weather.sunglow_intensity * diffuse_factor
  local dark_specular = weather.specular_intensity * diffuse_factor
  local ended = false
  while not ended do
    local seconds = nx_strict_pause(0)
    if trigger.increase then
      trigger.lerp = trigger.lerp + seconds
    else
      trigger.lerp = trigger.lerp - seconds
    end
    if not nx_is_valid(trigger) or not nx_is_valid(weather) then
      return false
    end
    if 0 > trigger.lerp then
      trigger.lerp = 0
      ended = true
    end
    if 1 < trigger.lerp then
      trigger.lerp = 1
      ended = true
    end
    weather.AmbientIntensity = dark_ambient + (weather.ambient_intensity - dark_ambient) * trigger.lerp
    weather.SunGlowIntensity = dark_diffuse + (weather.sunglow_intensity - dark_diffuse) * trigger.lerp
    weather.SpecularIntensity = dark_specular + (weather.specular_intensity - dark_specular) * trigger.lerp
  end
  return true
end
