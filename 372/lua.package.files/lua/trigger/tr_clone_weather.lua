local get_append_path = function(terrain)
  local path = terrain.FilePath
  if nil ~= string.find(terrain.FilePath, "\\map\\") then
    return "map\\"
  else
    return ""
  end
end
local set_custom_entity = function(scene, entity, custom_entity_name)
  local custom_entity = nx_value(custom_entity_name)
  if not nx_is_valid(custom_entity) then
    custom_entity = nx_custom(scene, custom_entity_name)
  end
  nx_set_custom(entity, custom_entity_name, custom_entity)
end
function on_init(self, para)
  local scene = nx_value("scene")
  if not nx_is_valid(scene) then
    scene = nx_value("game_scene")
  end
  self.scene = scene
  set_custom_entity(scene, self, "terrain")
  set_custom_entity(scene, self, "sky")
  set_custom_entity(scene, self, "sun")
  return 1
end
function on_timer(self, seconds, para)
  return 1
end
function on_entry(self, player, para)
  local scene = self.scene
  if not nx_is_valid(scene) then
    return 0
  end
  local terrain = self.terrain
  if not nx_is_valid(terrain) then
    return 0
  end
  local weather_file = get_weather_file()
  if "" == weather_file then
    return 0
  end
  if nx_running(nx_current(), "set_weather", self) then
    nx_kill(nx_current(), "set_weather", self)
  end
  if not nx_running(nx_current(), "set_weather", self) then
    nx_execute(nx_current(), "set_weather", self, nx_string(weather_file))
  end
  return 1
end
function on_leave(self, player, para)
  local scene = self.scene
  if not nx_is_valid(scene) then
    return 0
  end
  local terrain = self.terrain
  if not nx_is_valid(terrain) then
    return 0
  end
  local weather_file = get_defualt_weather()
  if "" == weather_file then
    return 0
  end
  if not nx_running(nx_current(), "set_weather", self) then
    nx_execute(nx_current(), "set_weather", self, nx_string(weather_file))
  end
  return 1
end
function set_intensity(trigger, weather, new_ambient, new_sunglow, new_specular, lerp)
  local delta_ambient = weather.AmbientIntensity - new_ambient
  local delta_sunglow = weather.SunGlowIntensity - new_sunglow
  local delta_specular = weather.SpecularIntensity - new_specular
  local ended = false
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
    weather.AmbientIntensity = new_ambient + delta_ambient * lerp
    weather.SunGlowIntensity = new_sunglow + delta_sunglow * lerp
    weather.SpecularIntensity = new_specular + delta_specular * lerp
  end
end
function async_set_sky_sun(trigger, ini, append_path)
  local scene = nx_value("game_scene")
  local sky = scene.sky
  local sun = scene.sun
  local weather = scene.Weather
  local world = nx_value("world")
  world.BackColor = weather.FogColor
  weather.show_sun = ini:ReadString("weather", "ShowSun", nx_string(weather.show_sun))
  if weather.show_sun == true then
    sun.ShowFlare = ini:ReadString("weather", "ShowFlare", nx_string(weather.show_flare))
    sun.GlowTex = append_path .. ini:ReadString("weather", "SunTex", weather.sun_tex)
  else
    sun.ShowGlow = false
    sun.ShowFlare = false
  end
  sky.YawSpeed = ini:ReadFloat("weather", "SkyYawSpeed", sky.YawSpeed)
end
function async_set_weather(trigger, ini, append_path)
  local scene = nx_value("game_scene")
  local sky = scene.sky
  local weather = scene.Weather
  weather.FogLinear = ini:ReadString("weather", "FogLinear", nx_string(weather.FogLinear))
  weather.FogExp = ini:ReadString("weather", "FogExp", nx_string(weather.FogExp))
  weather.FogStart = ini:ReadFloat("weather", "FogStart", weather.FogStart)
  weather.FogEnd = ini:ReadFloat("weather", "FogEnd", weather.FogEnd)
  weather.FogHeight = ini:ReadFloat("weather", "FogHeight", weather.FogHeight)
  weather.FogDensity = ini:ReadFloat("weather", "FogDensity", weather.FogDensity)
  weather.fog_red = ini:ReadInteger("weather", "FogRed", weather.fog_red)
  weather.fog_green = ini:ReadInteger("weather", "FogGreen", weather.fog_green)
  weather.fog_blue = ini:ReadInteger("weather", "FogBlue", weather.fog_blue)
  weather.fog_exp_red = ini:ReadInteger("weather", "FogExpRed", weather.fog_exp_red)
  weather.fog_exp_green = ini:ReadInteger("weather", "FogExpGreen", weather.fog_exp_green)
  weather.fog_exp_blue = ini:ReadInteger("weather", "FogExpBlue", weather.fog_exp_blue)
  weather.FogColor = "0," .. nx_string(weather.fog_red) .. "," .. nx_string(weather.fog_green) .. "," .. nx_string(weather.fog_blue)
  weather.FogExpColor = "0," .. nx_string(weather.fog_exp_red) .. "," .. nx_string(weather.fog_exp_green) .. "," .. nx_string(weather.fog_exp_blue)
  weather.sunglow_red = ini:ReadInteger("weather", "SunglowRed", weather.sunglow_red)
  weather.sunglow_green = ini:ReadInteger("weather", "SunglowGreen", weather.sunglow_green)
  weather.sunglow_blue = ini:ReadInteger("weather", "SunglowBlue", weather.sunglow_blue)
  weather.SunGlowColor = "0," .. nx_string(weather.sunglow_red) .. "," .. nx_string(weather.sunglow_green) .. "," .. nx_string(weather.sunglow_blue)
  weather.ambient_red = ini:ReadInteger("weather", "AmbientRed", weather.ambient_red)
  weather.ambient_green = ini:ReadInteger("weather", "AmbientGreen", weather.ambient_green)
  weather.ambient_blue = ini:ReadInteger("weather", "AmbientBlue", weather.ambient_blue)
  weather.AmbientColor = "0," .. nx_string(weather.ambient_red) .. "," .. nx_string(weather.ambient_green) .. "," .. nx_string(weather.ambient_blue)
  weather.specular_red = ini:ReadInteger("weather", "SpecularRed", weather.specular_red)
  weather.specular_green = ini:ReadInteger("weather", "SpecularGreen", weather.specular_green)
  weather.specular_blue = ini:ReadInteger("weather", "SpecularBlue", weather.specular_blue)
  weather.SpecularColor = "0," .. nx_string(weather.specular_red) .. "," .. nx_string(weather.specular_green) .. "," .. nx_string(weather.specular_blue)
  local ambient_intensity = ini:ReadFloat("weather", "AmbientIntensity", weather.AmbientIntensity)
  local sunglow_intensity = ini:ReadFloat("weather", "SunGlowIntensity", weather.SunGlowIntensity)
  local specular_intensity = ini:ReadFloat("weather", "SpecularIntensity", weather.SpecularIntensity)
  nx_execute(nx_current(), "set_intensity", trigger, weather, ambient_intensity, sunglow_intensity, specular_intensity, sky.FadeInTime)
  weather.WindSpeed = ini:ReadFloat("weather", "WindSpeed", weather.WindSpeed)
  weather.WindAngle = ini:ReadFloat("weather", "WindAngle", weather.WindAngle)
  weather.sun_height = ini:ReadInteger("weather", "SunHeight", weather.sun_height)
  weather.sun_azimuth = ini:ReadInteger("weather", "SunAzimuth", weather.sun_azimuth)
  local sun_height_rad = weather.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = weather.sun_azimuth / 360 * math.pi * 2
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
end
function set_weather(trigger, file_name)
  local scene = nx_value("game_scene")
  local sky = scene.sky
  local sun = scene.sun
  if not nx_is_valid(scene) then
    return
  end
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  if not ini:FindSection("weather") then
    nx_destroy(ini)
    return
  end
  if nx_is_valid(sun) then
    nx_execute(nx_current(), "async_set_sky_sun", trigger, ini, "map\\")
  end
  if nx_is_valid(sky) then
    nx_execute(nx_current(), "async_set_weather", trigger, ini, "map\\")
  end
  nx_destroy(ini)
end
function get_clone_lvl()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return 0
  end
  if not client_scene:FindProp("Level") then
    return 0
  end
  local level = client_scene:QueryProp("Level")
  return nx_int(level)
end
function get_clone_res()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  if not client_scene:FindProp("Resource") then
    return ""
  end
  local res = client_scene:QueryProp("Resource")
  return nx_string(res)
end
function get_weather_file()
  local weather_file = nx_resource_path() .. "map\\ter\\" .. nx_string(get_clone_res()) .. "\\weather" .. nx_string(get_clone_lvl()) .. ".ini"
  return nx_string(weather_file)
end
function get_defualt_weather()
  local weather_file = nx_resource_path() .. "map\\ter\\" .. nx_string(get_clone_res()) .. "\\weather.ini"
  return nx_string(weather_file)
end
