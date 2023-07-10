require("util_functions")
local HEART_TIME = 1000
function parse_color(color)
  local alpha = 0
  local red = 0
  local green = 0
  local blue = 0
  if nil == color then
    return alpha, red, green, blue
  end
  local pos1 = string.find(color, ",")
  if pos1 == nil then
    return alpha, red, green, blue
  end
  local pos2 = string.find(color, ",", pos1 + 1)
  if pos2 == nil then
    return alpha, red, green, blue
  end
  local pos3 = string.find(color, ",", pos2 + 1)
  if pos3 == nil then
    return alpha, red, green, blue
  end
  local alpha = nx_number(string.sub(color, 1, pos1 - 1))
  local red = nx_number(string.sub(color, pos1 + 1, pos2 - 1))
  local green = nx_number(string.sub(color, pos2 + 1, pos3 - 1))
  local blue = nx_number(string.sub(color, pos3 + 1))
  return alpha, red, green, blue
end
function convert_color(color)
  local pos = string.find(color, ",")
  if pos ~= nil then
    return color
  end
  local num = nx_number(color)
  local alpha = math.floor(num / 16777216)
  num = num - alpha * 256 * 256 * 256
  local red = math.floor(num / 65536)
  num = num - red * 256 * 256
  local green = math.floor(num / 256)
  num = num - green * 256
  local blue = math.floor(num)
  return nx_string(alpha) .. "," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
local gen_unique_name = function()
  local name = nx_function("ext_gen_unique_name")
  local used_unique_name = nx_value("used_unique_name")
  if nx_is_valid(used_unique_name) then
    while true do
      local is_exist = false
      local file_unique_name_list = used_unique_name:GetChildList()
      local count = table.getn(file_unique_name_list)
      for i = 1, count do
        if file_unique_name_list[i]:FindChild(name) then
          is_exist = true
          break
        end
      end
      if is_exist then
        name = nx_function("ext_gen_unique_name")
      else
        break
      end
    end
    return name
  end
  return name
end
function add_append_path(value)
  local new_value = value
  if "" ~= value then
    local append_path_len = string.len("map\\")
    if string.sub(value, 1, append_path_len) ~= "map\\" then
      new_value = "map\\" .. value
    end
  end
  return new_value
end
function get_append_path()
  return "map\\"
end
function put_effectmodel(name, effectmodel_config, effectmodel_name, x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, tag)
  effectmodel_config = add_append_path(effectmodel_config)
  local world = nx_value("world")
  local scene = world.MainScene
  if not nx_is_valid(scene) then
    return 0
  end
  local terrain = scene.terrain
  local effectmodel = scene:Create("EffectModel")
  if not nx_is_valid(effectmodel) then
    return nx_null()
  end
  effectmodel.AsyncLoad = true
  effectmodel:SetPosition(x, y, z)
  effectmodel:SetAngle(angle_x, angle_y, angle_z)
  effectmodel:SetScale(scale_x, scale_y, scale_z)
  if not effectmodel:CreateFromIniEx(effectmodel_config, effectmodel_name, false, get_append_path()) then
    nx_log("create effectmodel from ini file failed")
    nx_log(effectmodel_config)
    nx_log(effectmodel_name)
    return nx_null()
  end
  while not effectmodel.LoadFinish do
    nx_pause(0)
  end
  effectmodel.name = name
  effectmodel.config = effectmodel_config
  effectmodel.effectmodel_config = effectmodel_config
  effectmodel.effectmodel_name = effectmodel_name
  effectmodel.clip_radius = 1000
  effectmodel.WaterReflect = false
  effectmodel.tag = tag
  if "" ~= effectmodel.tag then
    scene:AddObject(effectmodel, 21)
  elseif not nx_is_valid(terrain) or not terrain:AddVisual(name, effectmodel) then
    scene:Delete(effectmodel)
    effectmodel = nx_null()
  end
  return effectmodel
end
function create_sky_manager(scene)
  local sky_manager = nx_value("sky_manager")
  if nx_is_valid(sky_manager) then
    return sky_manager
  end
  local sky_manager = scene:Create("SkyManager")
  nx_set_value("sky_manager", sky_manager)
  return sky_manager
end
function create_cloud(scene)
  if nx_find_custom(scene, "cloud") then
    local cloud = nx_custom(scene, "cloud")
    if nx_is_valid(cloud) then
      return 0
    end
  end
  local cloud = scene:Create("Cloud")
  scene.cloud = cloud
  cloud.AsyncLoad = true
  cloud.MulFactor = 600
  cloud.Height = 1000
  cloud.WindScale = 0.09
  cloud.ShowCloud = true
  cloud.Texture = ""
  cloud:Load()
  cloud.special = false
  return 1
end
function create_sky(scene)
  if nx_find_custom(scene, "sky") then
    local sky = nx_custom(scene, "sky")
    if nx_is_valid(sky) then
      return 1
    end
  end
  local sky = scene:Create("SkyBox")
  sky.UpTex = "map\\tex\\SKIES\\sky03\\cub_sky03"
  sky.AsyncLoad = true
  sky.YawSpeed = 0.01
  sky.MulFactor = 600
  local a, r, g, b = parse_color(sky.Color)
  sky.Color = "255" .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
  sky:Load()
  scene.sky = sky
  local sky_manager = create_sky_manager(scene)
  sky_manager:AddSky(sky)
  return true
end
function create_sky2(scene)
  if nx_find_custom(scene, "sky2") then
    local sky = nx_custom(scene, "sky2")
    if nx_is_valid(sky) then
      return 1
    end
  end
  local sky = scene:Create("SkyBox")
  sky.AsyncLoad = true
  sky.YawSpeed = 0.01
  sky.MulFactor = 600
  sky.UpTex = ""
  sky.SideTex = ""
  local a, r, g, b = parse_color(sky.Color)
  sky.Color = "0" .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
  sky:Load()
  scene.sky2 = sky
  return 1
end
function create_sky3(scene)
  if nx_find_custom(scene, "sky3") then
    local sky = nx_custom(scene, "sky3")
    if nx_is_valid(sky) then
      return 1
    end
  end
  local sky = scene:Create("SkyBox")
  sky.AsyncLoad = true
  sky.YawSpeed = 0.01
  sky.MulFactor = 600
  sky.UpTex = ""
  sky.SideTex = ""
  local a, r, g, b = parse_color(sky.Color)
  sky.Color = "0" .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
  sky:Load()
  scene.sky3 = sky
  return 1
end
function create_sun(scene)
  local sun = scene:Create("SunGlow")
  sun.GlowTex = "map\\tex\\sun\\glow\\sunglow3.tga"
  sun.FlareTex = "map\\tex\\allflares.tga"
  sun.GlowSize = 200
  sun.ShowFlare = true
  sun.ShowGlow = true
  sun:AddFlare(0.8, 55, 1, "0, 31, 31, 31")
  sun:AddFlare(0.75, 25, 2, "0, 31, 31, 31")
  sun:AddFlare(0.7, 15, 3, "0, 31, 31, 31")
  sun:AddFlare(0.6, 30, 4, "0, 31, 31, 31")
  sun:AddFlare(0.54, 25, 3, "0, 31, 31, 31")
  sun:AddFlare(0.49, 50, 2, "0, 31, 31, 31")
  sun:AddFlare(0.47, 80, 2, "0, 47, 47, 47")
  sun:AddFlare(0.4, 40, 4, "0, 31, 31, 31")
  sun:AddFlare(0.35, 20, 3, "0, 31, 31, 31")
  sun:AddFlare(0.27, 90, 2, "0, 31, 31, 31")
  sun:AddFlare(0.25, 120, 1, "0, 47, 47, 47")
  sun:AddFlare(0.15, 30, 4, "0, 31, 31, 31")
  sun:Load()
  scene:AddObject(sun, 80)
  scene.sun = sun
  return true
end
function create_lunar_model(scene)
  if nx_find_custom(scene, "lunar_mdl") then
    local lunar_mdl = nx_custom(scene, "lunar_mdl")
    if nx_is_valid(lunar_mdl) then
      return 0
    end
  end
  local name = gen_unique_name()
  local effectmodel_config = "ini\\particles_mdl.ini"
  local effectmodel_name = "moon01"
  local weather_wrapper = nx_value("WeatherWrapper")
  if nx_is_valid(weather_wrapper) then
    local pos_x, pos_y, pos_z = weather_wrapper:ModifySunPosition(4000)
    if pos_x ~= nil and pos_y ~= nil and pos_z ~= nil then
      local angle_x, angle_y, angle_z = 0, 0, 0
      local scale_x, scale_y, scale_z = 15, 15, 15
      local tag = "lunar"
      local effectmodel = put_effectmodel(name, effectmodel_config, effectmodel_name, pos_x, pos_y, pos_z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, tag)
      if nx_is_valid(effectmodel) then
        scene.lunar_mdl = effectmodel
        local list = effectmodel.ModelID:GetMaterialNameList()
        local exist_custom_mat = effectmodel.ModelID:FindCustomMaterial(list[1])
        effectmodel.ModelID:SetMaterialValue(list[1], "Celestial", "true")
        if not exist_custom_mat then
          effectmodel.ModelID:ReloadCustomMaterialTextures()
        end
        effectmodel.Visible = false
      else
        scene.lunar_mdl = nx_null()
      end
    end
  end
end
function change_lunar_position()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return 0
  end
  if not nx_find_custom(scene, "lunar_mdl") or not nx_is_valid(nx_custom(scene, "lunar_mdl")) then
    return 0
  end
  local lunar_mdl = scene.lunar_mdl
  if nx_is_valid(lunar_mdl) then
    local weather_set_data = nx_value("weather_set_data")
    if nx_is_valid(weather_set_data) then
      if lunar_mdl.Visible then
        local weather_wrapper = nx_value("WeatherWrapper")
        if nx_is_valid(weather_wrapper) then
          local pos_x, pos_y, pos_z = weather_wrapper:ModifySunPosition(4000)
          if pos_x ~= nil and pos_y ~= nil and pos_z ~= nil then
            lunar_mdl:SetPosition(pos_x, pos_y, pos_z)
          end
        end
        local sun = scene.sun
        if nx_is_valid(sun) then
          sun.ShowGlow = false
          sun.ShowFlare = false
        end
      end
    else
      local sun = scene.sun
      if nx_is_valid(sun) and nil ~= string.find(string.lower(sun.GlowTex), "moon") then
        local weather_wrapper = nx_value("WeatherWrapper")
        if nx_is_valid(weather_wrapper) then
          local pos_x, pos_y, pos_z = weather_wrapper:ModifySunPosition(4000)
          if pos_x ~= nil and pos_y ~= nil and pos_z ~= nil then
            lunar_mdl:SetPosition(pos_x, pos_y, pos_z)
            lunar_mdl.Visible = true
            sun.ShowGlow = false
            sun.ShowFlare = false
          end
        end
      else
        lunar_mdl.Visible = false
      end
    end
  end
end
function create_weather(scene)
  local weather = scene.Weather
  weather.show_sun = true
  weather.show_flare = false
  weather.show_sky = true
  weather.fog_linear = true
  weather.fog_exp = false
  weather.fog_density = 0.001
  weather.fog_height = 380
  weather.fog_height_exp = 1
  weather.fog_start = 200
  weather.fog_start_origin = weather.fog_start
  weather.fog_end = 500
  weather.fog_red = 200
  weather.fog_green = 200
  weather.fog_blue = 200
  weather.fog_exp_red = 200
  weather.fog_exp_green = 200
  weather.fog_exp_blue = 200
  weather.sunglow_red = 255
  weather.sunglow_green = 255
  weather.sunglow_blue = 255
  weather.ambient_red = 150
  weather.ambient_green = 150
  weather.ambient_blue = 150
  weather.global_ambient_red = 0
  weather.global_ambient_green = 0
  weather.global_ambient_blue = 0
  weather.specular_red = 255
  weather.specular_green = 255
  weather.specular_blue = 255
  weather.ambient_intensity = 1
  weather.sunglow_intensity = 1
  weather.specular_intensity = 1
  weather.sun_height = 45
  weather.sun_azimuth = 200
  weather.sky_up_tex = "map\\tex\\SKIES\\sky03\\cub_sky03"
  weather.sky_side_tex = "map\\tex\\sky_side.tga"
  weather.sun_tex = "map\\tex\\sun\\glow\\sunglow.tga"
  weather.wind_speed = 0.5
  weather.wind_angle = 0
  scene.weather = weather
  return true
end
function shade_weather_brightness()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.weather
  if not nx_is_valid(weather) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  if weather_set_data.special_sun then
    return 0
  end
  local special_lightning = false
  if not weather_set_data.lightning_ongoing then
    special_lightning = false
  else
    special_lightning = true
  end
  if not special_lightning and nx_is_valid(weather_set_data) then
    local time = math.floor(weather_set_data.fadein_time)
    if time <= 1 then
      time = 1
    end
    if 0 <= weather.AmbientIntensity + (weather_set_data.ambient_current - weather_set_data.ambient_last) / time then
      weather.AmbientIntensity = weather.AmbientIntensity + (weather_set_data.ambient_current - weather_set_data.ambient_last) / time
    end
    if 0 <= weather.SunGlowIntensity + (weather_set_data.sunglow_current - weather_set_data.sunglow_last) / time then
      weather.SunGlowIntensity = weather.SunGlowIntensity + (weather_set_data.sunglow_current - weather_set_data.sunglow_last) / time
    end
    if 0 <= weather.SpecularIntensity + (weather_set_data.specular_current - weather_set_data.specular_last) / time then
      weather.SpecularIntensity = weather.SpecularIntensity + (weather_set_data.specular_current - weather_set_data.specular_last) / time
    end
  end
end
function shade_weather_color()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.weather
  if not nx_is_valid(weather) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  if weather_set_data.special_sun then
    return 0
  end
  if nx_is_valid(weather_set_data) then
    local a, r, g, b = parse_color(weather.FogColor)
    if r ~= weather_set_data.fog_red_current then
      r = r + weather_set_data.fog_red_add
    end
    if g ~= weather_set_data.fog_green_current then
      g = g + weather_set_data.fog_green_add
    end
    if b ~= weather_set_data.fog_blue_current then
      b = b + weather_set_data.fog_blue_add
    end
    weather.FogColor = "0," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
    a, r, g, b = parse_color(weather.FogExpColor)
    if r ~= weather_set_data.fog_exp_red_current then
      r = r + weather_set_data.fog_exp_red_add
    end
    if g ~= weather_set_data.fog_exp_green_current then
      g = g + weather_set_data.fog_exp_green_add
    end
    if b ~= weather_set_data.fog_exp_blue_current then
      b = b + weather_set_data.fog_exp_blue_add
    end
    weather.FogExpColor = "0," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
    a, r, g, b = parse_color(weather.AmbientColor)
    if r ~= weather_set_data.ambient_red then
      r = r + weather_set_data.ambient_red_add
    end
    if g ~= weather_set_data.ambient_green then
      g = g + weather_set_data.ambient_green_add
    end
    if b ~= weather_set_data.ambient_blue then
      b = b + weather_set_data.ambient_blue_add
    end
    weather.AmbientColor = "0," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
    if not weather_set_data.lightning_ongoing then
      a, r, g, b = parse_color(weather.SunGlowColor)
      if r ~= weather_set_data.sunglow_red then
        r = r + weather_set_data.sunglow_red_add
      end
      if g ~= weather_set_data.sunglow_green then
        g = g + weather_set_data.sunglow_green_add
      end
      if b ~= weather_set_data.sunglow_blue then
        b = b + weather_set_data.sunglow_blue_add
      end
      weather.SunGlowColor = "0," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
    end
    a, r, g, b = parse_color(weather.SpecularColor)
    if r ~= weather_set_data.specular_red then
      r = r + weather_set_data.specular_red_add
    end
    if g ~= weather_set_data.specular_green then
      g = g + weather_set_data.specular_green_add
    end
    if b ~= weather_set_data.specular_blue then
      b = b + weather_set_data.specular_blue_add
    end
    weather.SpecularColor = "0," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
  end
end
function change_weather(scene)
  local stage = nx_value("stage")
  if "login" ~= stage and "create" ~= stage then
    local weather_manager = nx_value("weather_manager")
    if nx_is_valid(weather_manager) then
      local IsLua = weather_manager:IsLua()
      if not IsLua then
        weather_manager:InitWeatherData()
        return 0
      end
    end
  end
  local timer_game = nx_value(GAME_TIMER)
  local world = nx_value("world")
  timer_game:UnRegister("terrain\\weather", "change_lunar_position", world)
  timer_game:UnRegister("terrain\\weather", "shade_weather_brightness", world)
  timer_game:UnRegister("terrain\\weather", "shade_weather_color", world)
  local weather = scene.weather
  weather.FogLinear = weather.fog_linear
  weather.FogExp = weather.fog_exp
  weather.FogStart = weather.fog_start
  weather.FogEnd = weather.fog_end
  weather.FogHeight = weather.fog_height
  weather.FogHeightExp = weather.fog_height_exp
  weather.FogDensity = weather.fog_density
  weather.FogSeaDensity = weather.fog_density
  local weather_set_data = nx_value("weather_set_data")
  local special_lightning = false
  if not nx_is_valid(weather_set_data) then
    special_lightning = false
    weather.AmbientIntensity = weather.ambient_intensity
    weather.SunGlowIntensity = weather.sunglow_intensity
    weather.SpecularIntensity = weather.specular_intensity
  elseif not weather_set_data.lightning_ongoing and not weather_set_data.lightning_gm then
    special_lightning = false
  else
    special_lightning = true
  end
  weather.WindSpeed = weather.wind_speed
  weather.WindAngle = weather.wind_angle / 360 * math.pi * 2
  local sun_height_rad = weather.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = weather.sun_azimuth / 360 * math.pi * 2
  if not nx_is_valid(weather_set_data) then
    weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  end
  weather.GlowSize = weather.glow_size
  weather.FlareSize = weather.flare_size
  weather.GlowDistanc = weather.glow_distanc
  weather.FlareDistance = weather.flare_distanc
  create_sky(scene)
  create_sky2(scene)
  create_sky3(scene)
  create_cloud(scene)
  local sky = scene.sky
  local sky2 = scene.sky2
  local sky3 = scene.sky3
  if not nx_is_valid(weather_set_data) then
    if weather.sky_up_tex ~= "" then
      local sky = scene.sky
      if nx_is_valid(sky) and sky.UpTex ~= weather.sky_up_tex then
        sky.UpTex = weather.sky_up_tex
        local sky_manager = create_sky_manager(scene)
        sky.Color = "255,255,255,255"
        sky:UpdateTexture()
        sky_manager:RemoveSky(sky)
        sky_manager:AddSky(sky)
        sky_manager:RemoveSky(sky2)
      end
    end
    weather.FogColor = "0," .. nx_string(weather.fog_red) .. "," .. nx_string(weather.fog_green) .. "," .. nx_string(weather.fog_blue)
    weather.FogExpColor = "0," .. nx_string(weather.fog_exp_red) .. "," .. nx_string(weather.fog_exp_green) .. "," .. nx_string(weather.fog_exp_blue)
    weather.AmbientColor = "0," .. nx_string(weather.ambient_red) .. "," .. nx_string(weather.ambient_green) .. "," .. nx_string(weather.ambient_blue)
    weather.SpecularColor = "0," .. nx_string(weather.specular_red) .. "," .. nx_string(weather.specular_green) .. "," .. nx_string(weather.specular_blue)
    weather.SunGlowColor = "0," .. nx_string(weather.sunglow_red) .. "," .. nx_string(weather.sunglow_green) .. "," .. nx_string(weather.sunglow_blue)
  elseif weather_set_data.special_brightness == 0 then
    local world = nx_value("world")
    local timer_game = nx_value(GAME_TIMER)
    timer_game:UnRegister("terrain\\weather", "change_sky_color", world)
    if weather.sky_up_tex ~= "" then
      local sky2 = scene.sky2
      if nx_is_valid(sky2) then
        local sky_manager = create_sky_manager(scene)
        local fadeInTime = 1
        local date = util_split_string(weather_set_data.data, ";")
        local specific_list = util_split_string(date[3], ",")
        if sky2.UpTex ~= "" then
          sky.UpTex = sky2.UpTex
          sky.Color = "255,255,255,255"
          sky:UpdateTexture()
          if "" == specific_list[2] or "" == specific_list[1] then
            sky_manager:RemoveSky(sky)
            sky_manager:AddSky(sky)
          end
          fadeInTime = math.ceil(nx_number(date[2]) / 10) + 1
        end
        if fadeInTime <= 0 then
          fadeInTime = 1
        end
        weather_set_data.fadein_time = fadeInTime
        weather_set_data.ambient_current = weather.ambient_intensity
        weather_set_data.sunglow_current = weather.sunglow_intensity
        weather_set_data.specular_current = weather.specular_intensity
        weather_set_data.ambient_last = weather.AmbientIntensity
        weather_set_data.sunglow_last = weather.SunGlowIntensity
        weather_set_data.specular_last = weather.SpecularIntensity
        if ("" == specific_list[2] or "" == specific_list[1]) and not weather_set_data.special_sun then
          timer_game:Register(HEART_TIME, weather_set_data.fadein_time, "terrain\\weather", "shade_weather_brightness", world, -1, -1)
        end
        if 1 ~= weather_set_data.fadein_time then
          weather_set_data.fog_red_current = weather.fog_red
          weather_set_data.fog_green_current = weather.fog_green
          weather_set_data.fog_blue_current = weather.fog_blue
          local a, r, g, b = parse_color(weather.FogColor)
          if r < weather.fog_red then
            weather_set_data.fog_red_add = 1
          else
            weather_set_data.fog_red_add = -1
          end
          if g < weather.fog_green then
            weather_set_data.fog_green_add = 1
          else
            weather_set_data.fog_green_add = -1
          end
          if b < weather.fog_blue then
            weather_set_data.fog_blue_add = 1
          else
            weather_set_data.fog_blue_add = -1
          end
          weather_set_data.fog_exp_red_current = weather.fog_exp_red
          weather_set_data.fog_exp_green_current = weather.fog_exp_green
          weather_set_data.fog_exp_blue_current = weather.fog_exp_blue
          a, r, g, b = parse_color(weather.FogExpColor)
          if r < weather.fog_exp_red then
            weather_set_data.fog_exp_red_add = 1
          else
            weather_set_data.fog_exp_red_add = -1
          end
          if g < weather.fog_exp_green then
            weather_set_data.fog_exp_green_add = 1
          else
            weather_set_data.fog_exp_green_add = -1
          end
          if b < weather.fog_exp_blue then
            weather_set_data.fog_exp_blue_add = 1
          else
            weather_set_data.fog_exp_blue_add = -1
          end
          weather_set_data.ambient_red = weather.ambient_red
          weather_set_data.ambient_green = weather.ambient_green
          weather_set_data.ambient_blue = weather.ambient_blue
          a, r, g, b = parse_color(weather.AmbientColor)
          if r < weather.ambient_red then
            weather_set_data.ambient_red_add = 1
          else
            weather_set_data.ambient_red_add = -1
          end
          if g < weather.ambient_green then
            weather_set_data.ambient_green_add = 1
          else
            weather_set_data.ambient_green_add = -1
          end
          if b < weather.ambient_blue then
            weather_set_data.ambient_blue_add = 1
          else
            weather_set_data.ambient_blue_add = -1
          end
          weather_set_data.sunglow_red = weather.sunglow_red
          weather_set_data.sunglow_green = weather.sunglow_green
          weather_set_data.sunglow_blue = weather.sunglow_blue
          a, r, g, b = parse_color(weather.SunGlowColor)
          if r < weather.sunglow_red then
            weather_set_data.sunglow_red_add = 1
          else
            weather_set_data.sunglow_red_add = -1
          end
          if g < weather.sunglow_green then
            weather_set_data.sunglow_green_add = 1
          else
            weather_set_data.sunglow_green_add = -1
          end
          if b < weather.sunglow_blue then
            weather_set_data.sunglow_blue_add = 1
          else
            weather_set_data.sunglow_blue_add = -1
          end
          weather_set_data.specular_red = weather.sunglow_red
          weather_set_data.specular_green = weather.sunglow_green
          weather_set_data.specular_blue = weather.sunglow_blue
          a, r, g, b = parse_color(weather.SpecularColor)
          if r < weather.specular_red then
            weather_set_data.specular_red_add = 1
          else
            weather_set_data.specular_red_add = -1
          end
          if g < weather.specular_green then
            weather_set_data.specular_green_add = 1
          else
            weather_set_data.specular_green_add = -1
          end
          if b < weather.specular_blue then
            weather_set_data.specular_blue_add = 1
          else
            weather_set_data.specular_blue_add = -1
          end
          if "" == specific_list[2] or "" == specific_list[1] then
            timer_game:Register(HEART_TIME / 4, 255, "terrain\\weather", "shade_weather_color", world, -1, -1)
          end
        else
          weather.FogColor = "0," .. nx_string(weather.fog_red) .. "," .. nx_string(weather.fog_green) .. "," .. nx_string(weather.fog_blue)
          weather.FogExpColor = "0," .. nx_string(weather.fog_exp_red) .. "," .. nx_string(weather.fog_exp_green) .. "," .. nx_string(weather.fog_exp_blue)
          weather.AmbientColor = "0," .. nx_string(weather.ambient_red) .. "," .. nx_string(weather.ambient_green) .. "," .. nx_string(weather.ambient_blue)
          if not special_lightning then
            weather.SunGlowColor = "0," .. nx_string(weather.sunglow_red) .. "," .. nx_string(weather.sunglow_green) .. "," .. nx_string(weather.sunglow_blue)
          end
          weather.SpecularColor = "0," .. nx_string(weather.specular_red) .. "," .. nx_string(weather.specular_green) .. "," .. nx_string(weather.specular_blue)
        end
        sky2.UpTex = weather.sky_up_tex
        a, r, g, b = parse_color(sky2.Color)
        sky2.Color = "0" .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
        sky2:UpdateTexture()
        if "" == specific_list[2] or "" == specific_list[1] then
          sky_manager:RemoveSky(sky2)
          sky_manager:AddSky(sky2)
        end
        local heart_frequency = math.ceil(1000 / (255 / fadeInTime))
        timer_game:Register(heart_frequency, -1, "terrain\\weather", "change_sky_color", world, -1, -1)
      end
    end
  end
  scene.BackColor = weather.FogColor
  world.BackColor = weather.FogColor
  if nx_is_valid(sky3) and nx_is_valid(weather_set_data) then
    local sky_manager = create_sky_manager(scene)
    local cloud = scene.cloud
    if weather_set_data.special_brightness == 1 then
      sky3.UpTex = weather_set_data.sky3_upTex
      if nx_is_valid(cloud) then
        cloud.special = true
      end
      if "" == sky3.UpTex then
        sky_manager:RemoveSky(sky)
        sky_manager:AddSky(sky)
        sky_manager:RemoveSky(sky2)
        sky_manager:AddSky(sky2)
        sky_manager:RemoveSky(sky3)
      else
        local a, r, g, b = parse_color(sky3.Color)
        sky3.Color = "255" .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
        sky_manager:RemoveSky(sky3)
        sky_manager:AddSky(sky3)
        sky_manager:RemoveSky(sky)
        sky_manager:RemoveSky(sky2)
      end
      sky3:UpdateTexture()
      if not weather_set_data.special_sun then
        weather.AmbientIntensity = weather.ambient_intensity
        weather.SunGlowIntensity = weather.sunglow_intensity
        weather.SpecularIntensity = weather.specular_intensity
      end
    elseif weather_set_data.special_brightness == 2 then
      weather_set_data.special_brightness = 0
      sky_manager:RemoveSky(sky)
      sky_manager:AddSky(sky)
      sky_manager:RemoveSky(sky2)
      sky_manager:AddSky(sky2)
      sky_manager:RemoveSky(sky3)
      sky2.UpTex = ""
      if nx_is_valid(cloud) then
        cloud.special = false
      end
      if "" ~= weather_set_data.period_current then
        local path = nx_resource_path() .. "share\\Rule\\Weather\\SceneParaStore\\" .. weather_set_data.period_current .. "\\"
        local tag = nx_call("terrain\\weather_set", "path_is_null", weather_set_data.period_current)
        if tag then
          change_special_weather(scene, path)
        end
      end
    end
  end
  create_lunar_model(scene)
  local weather_set_data = nx_value("weather_set_data")
  if nx_is_valid(weather_set_data) then
    timer_game:Register(HEART_TIME, -1, "terrain\\weather", "change_lunar_position", world, -1, -1)
  end
  local sun = scene.sun
  if not nx_is_valid(weather_set_data) then
    if weather.show_sun then
      if not nx_is_valid(sun) then
        create_sun(scene)
      end
    elseif nx_is_valid(sun) then
      sun.ShowGlow = false
      sun.ShowFlare = false
    end
    sun = scene.sun
    if nx_is_valid(sun) then
      sun.ShowFlare = weather.show_flare
      if weather.sun_tex ~= "" then
        sun.GlowTex = weather.sun_tex
      end
      sun:Load()
    end
  end
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain:RefreshWater()
    terrain:RefreshGrass()
  end
  return true
end
function load_weather_ini(scene, filename)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_msgbox(get_msg_str("msg_460") .. filename)
    nx_destroy(ini)
    return false
  end
  local weather = scene.weather
  weather.show_sun = nx_boolean(ini:ReadString("weather", "ShowSun", "true"))
  weather.show_flare = nx_boolean(ini:ReadString("weather", "ShowFlare", "true"))
  weather.fog_linear = nx_boolean(ini:ReadString("weather", "FogLinear", "true"))
  weather.fog_exp = nx_boolean(ini:ReadString("weather", "FogExp", "false"))
  weather.fog_density = ini:ReadFloat("weather", "FogDensity", 0.017)
  weather.fog_height = ini:ReadFloat("weather", "FogHeight", 380)
  weather.fog_height_exp = ini:ReadFloat("weather", "FogHeightExp", 1)
  weather.fog_start = ini:ReadFloat("weather", "FogStart", 200)
  weather.fog_start_origin = weather.fog_start
  weather.fog_end = ini:ReadFloat("weather", "FogEnd", 500)
  weather.fog_red = ini:ReadInteger("weather", "FogRed", 200)
  weather.fog_green = ini:ReadInteger("weather", "FogGreen", 200)
  weather.fog_blue = ini:ReadInteger("weather", "FogBlue", 200)
  weather.fog_exp_red = ini:ReadInteger("weather", "FogExpRed", 200)
  weather.fog_exp_green = ini:ReadInteger("weather", "FogExpGreen", 200)
  weather.fog_exp_blue = ini:ReadInteger("weather", "FogExpBlue", 200)
  weather.sunglow_red = ini:ReadInteger("weather", "SunglowRed", 0)
  weather.sunglow_green = ini:ReadInteger("weather", "SunglowGreen", 0)
  weather.sunglow_blue = ini:ReadInteger("weather", "SunglowBlue", 0)
  weather.ambient_red = ini:ReadInteger("weather", "AmbientRed", 0)
  weather.ambient_green = ini:ReadInteger("weather", "AmbientGreen", 0)
  weather.ambient_blue = ini:ReadInteger("weather", "AmbientBlue", 0)
  weather.specular_red = ini:ReadInteger("weather", "SpecularRed", 0)
  weather.specular_green = ini:ReadInteger("weather", "SpecularGreen", 0)
  weather.specular_blue = ini:ReadInteger("weather", "SpecularBlue", 0)
  weather.ambient_intensity = ini:ReadFloat("weather", "AmbientIntensity", 1)
  weather.sunglow_intensity = ini:ReadFloat("weather", "SunGlowIntensity", 1)
  weather.specular_intensity = ini:ReadFloat("weather", "SpecularIntensity", 1)
  weather.sun_height = ini:ReadInteger("weather", "SunHeight", 20)
  weather.sun_azimuth = ini:ReadInteger("weather", "SunAzimuth", 0)
  weather.glow_size = ini:ReadInteger("weather", "GlowSize", 200)
  weather.flare_size = ini:ReadInteger("weather", "FlareSize", 1)
  weather.glow_distanc = ini:ReadInteger("weather", "GlowDistanc", 1000)
  weather.flare_distanc = ini:ReadInteger("weather", "FlareDistance", 1000)
  local skyuptex = ini:ReadString("weather", "SkyUpTex", "")
  if skyuptex ~= "" then
    weather.sky_up_tex = "map\\" .. skyuptex
  end
  local skysidetex = ini:ReadString("weather", "SkySideTex", "")
  if skysidetex ~= "" then
    weather.sky_side_tex = "map\\" .. skysidetex
  end
  local suntex = ini:ReadString("weather", "SunTex", "")
  if suntex ~= "" then
    weather.sun_tex = "map\\" .. suntex
  end
  weather.wind_speed = ini:ReadFloat("weather", "WindSpeed", 0)
  weather.wind_angle = ini:ReadFloat("weather", "WindAngle", 0)
  local weather_set_data = nx_value("weather_set_data")
  if nx_is_valid(weather_set_data) then
    weather_set_data.show_sun = weather.show_sun
    weather_set_data.show_moon = weather.show_sun
    if weather_set_data.special_brightness == 1 then
      if skyuptex ~= "" then
        weather_set_data.sky3_upTex = weather.sky_up_tex
      else
        weather_set_data.sky3_upTex = ""
      end
    else
      weather_set_data.sky3_upTex = ""
    end
  end
  nx_destroy(ini)
  return true
end
function change_sky_color()
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return 0
  end
  local sky = scene.sky
  local sky2 = scene.sky2
  local sky3 = scene.sky3
  if nx_is_valid(sky2) then
    local a, r, g, b = parse_color(sky2.Color)
    if 255 <= a then
      local sky_manager = create_sky_manager(scene)
      sky_manager:RemoveSky(sky)
      local world = nx_value("world")
      local timer_game = nx_value(GAME_TIMER)
      timer_game:UnRegister("terrain\\weather", "change_sky_color", world)
      return 0
    end
    sky2.Color = nx_string(a + 1) .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
  end
end
function change_cloud_color()
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return 0
  end
  local cloud = scene.cloud
  if nx_is_valid(cloud) then
    local a, r, g, b = parse_color(cloud.Color)
    if 255 <= a then
      local world = nx_value("world")
      local timer_game = nx_value(GAME_TIMER)
      timer_game:UnRegister("terrain\\weather", "change_cloud_color", world)
      return 0
    end
    cloud.Color = nx_string(a + 1) .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
  end
end
function load_cloud_ini(scene, filename)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    local cloud = scene.cloud
    if nx_is_valid(cloud) then
      local sky_manager = create_sky_manager(scene)
      sky_manager:RemoveWidget(cloud)
    end
    return 0
  end
  local weather = scene.weather
  weather.show_cloud = nx_boolean(ini:ReadString("Cloud", "ShowCloud", "false"))
  weather.zEnable = nx_boolean(ini:ReadString("Cloud", "ZEnable", "false"))
  weather.shadow_enable = nx_boolean(ini:ReadString("Cloud", "ShadowEnable", "false"))
  weather.cloud_height = nx_number(ini:ReadString("Cloud", "Height", "1000.0"))
  weather.cloud_speed = ini:ReadFloat("Cloud", "WindScale", 0.09)
  weather.cloud_alpha = nx_string(ini:ReadInteger("Cloud", "Alpha", 255))
  weather.cloud_red = nx_string(ini:ReadInteger("Cloud", "Red", 200))
  weather.cloud_green = nx_string(ini:ReadInteger("Cloud", "Green", 200))
  weather.cloud_blue = nx_string(ini:ReadInteger("Cloud", "Blue", 200))
  local cloud_tex = ini:ReadString("Cloud", "Texture", "")
  if cloud_tex ~= "" then
    weather.cloud_tex = "map\\" .. cloud_tex
  else
    weather.cloud_tex = ""
  end
  nx_destroy(ini)
  local cloud = scene.cloud
  local weather_set_data = nx_value("weather_set_data")
  if nx_is_valid(cloud) then
    if weather.show_cloud then
      local world = nx_value("world")
      local timer_game = nx_value(GAME_TIMER)
      timer_game:UnRegister("terrain\\weather", "change_cloud_color", world)
      cloud.Color = weather.cloud_alpha .. "," .. weather.cloud_red .. "," .. weather.cloud_green .. "," .. weather.cloud_blue
      if cloud.Texture ~= weather.cloud_tex then
        cloud.Texture = weather.cloud_tex
        local a, r, g, b = parse_color(cloud.Color)
        if nx_is_valid(weather_set_data) then
          cloud.Color = "0" .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
        end
        cloud:UpdateTexture()
      end
      cloud.ZEnable = weather.zEnable
      cloud.ShadowEnable = weather.shadow_enable
      cloud.WindScale = weather.cloud_speed
      if cloud.Height ~= weather.cloud_height then
        cloud.Height = weather.cloud_height
        cloud:Load()
      end
      local sky_manager = create_sky_manager(scene)
      sky_manager:RemoveWidget(cloud)
      sky_manager:AddSkyWidget(cloud)
      local fadein_time = 5
      local heart_frequency = math.ceil(1000 / (255 / fadein_time))
      if nx_is_valid(weather_set_data) then
        timer_game:Register(heart_frequency, -1, "terrain\\weather", "change_cloud_color", world, -1, -1)
      end
    else
      local sky_manager = create_sky_manager(scene)
      sky_manager:RemoveWidget(cloud)
    end
  end
  return 1
end
function create_shadow_uiparam(scene)
  local shadow_uiparam = nx_call("util_gui", "get_global_arraylist", nx_current())
  shadow_uiparam.shadow_enable = true
  shadow_uiparam.topcolor = "10,0,0,0"
  shadow_uiparam.bottomcolor = "200,0,0,0"
  shadow_uiparam.lightdispersion = 0.1
  scene.shadow_uiparam = shadow_uiparam
  return shadow_uiparam
end
function load_shadow_ini(scene, filename)
  local shadow_uiparam = scene.shadow_uiparam
  if not nx_is_valid(shadow_uiparam) then
    shadow_uiparam = create_shadow_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  shadow_uiparam.shadow_enable = nx_boolean(ini:ReadString("Shadow", "ShadowEnable", "false"))
  shadow_uiparam.topcolor = convert_color(ini:ReadString("Shadow", "ShadowTopColor", "150,255,255,255"))
  shadow_uiparam.bottomcolor = convert_color(ini:ReadString("Shadow", "ShadowBottomColor", "150,255,255,255"))
  shadow_uiparam.lightdispersion = ini:ReadFloat("Shadow", "LightDispersion", 0.1)
  nx_destroy(ini)
  return 1
end
function change_special_weather_data(scene)
  local weather = scene.weather
  weather.FogLinear = weather.fog_linear
  weather.FogExp = weather.fog_exp
  weather.FogStart = weather.fog_start
  weather.FogEnd = weather.fog_end
  weather.FogColor = "0," .. nx_string(weather.fog_red) .. "," .. nx_string(weather.fog_green) .. "," .. nx_string(weather.fog_blue)
  weather.FogExpColor = "0," .. nx_string(weather.fog_exp_red) .. "," .. nx_string(weather.fog_exp_green) .. "," .. nx_string(weather.fog_exp_blue)
  weather.FogHeight = weather.fog_height
  weather.FogHeightExp = weather.fog_height_exp
  weather.FogDensity = weather.fog_density
  weather.FogSeaDensity = weather.fog_density
  weather.AmbientColor = "0," .. nx_string(weather.ambient_red) .. "," .. nx_string(weather.ambient_green) .. "," .. nx_string(weather.ambient_blue)
  weather.SpecularColor = "0," .. nx_string(weather.specular_red) .. "," .. nx_string(weather.specular_green) .. "," .. nx_string(weather.specular_blue)
  local weather_set_data = nx_value("weather_set_data")
  local special_lightning = false
  if not nx_is_valid(weather_set_data) then
    special_lightning = false
  elseif not weather_set_data.lightning_ongoing and not weather_set_data.lightning_gm then
    special_lightning = false
  else
    special_lightning = true
  end
  if not special_lightning then
    weather.SunGlowColor = "0," .. nx_string(weather.sunglow_red) .. "," .. nx_string(weather.sunglow_green) .. "," .. nx_string(weather.sunglow_blue)
    weather.AmbientIntensity = weather.ambient_intensity
    weather.SunGlowIntensity = weather.sunglow_intensity
    weather.SpecularIntensity = weather.specular_intensity
  end
  weather.WindSpeed = weather.wind_speed
  weather.WindAngle = weather.wind_angle / 360 * math.pi * 2
  local sun_height_rad = weather.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = weather.sun_azimuth / 360 * math.pi * 2
  if not nx_is_valid(weather_set_data) then
    weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  end
  local world = nx_value("world")
  scene.BackColor = weather.FogColor
  world.BackColor = weather.FogColor
  create_sky(scene)
  create_sky2(scene)
  create_sky3(scene)
  create_cloud(scene)
  local sky = scene.sky
  local sky2 = scene.sky2
  local sky3 = scene.sky3
  if nx_find_custom(scene, "sky3") then
    local sky3 = nx_custom(scene, "sky3")
    if nx_is_valid(sky3) and nx_is_valid(weather_set_data) then
      local sky_manager = create_sky_manager(scene)
      local cloud = scene.cloud
      sky3.UpTex = weather_set_data.sky3_upTex
      if nx_is_valid(cloud) then
        cloud.special = true
      end
      if "" == sky3.UpTex then
        sky_manager:RemoveSky(sky)
        sky_manager:AddSky(sky)
        sky_manager:RemoveSky(sky2)
        sky_manager:AddSky(sky2)
        sky_manager:RemoveSky(sky3)
      else
        local a, r, g, b = parse_color(sky3.Color)
        sky3.Color = "255" .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
        sky_manager:RemoveSky(sky3)
        sky_manager:AddSky(sky3)
        sky_manager:RemoveSky(sky)
        sky_manager:RemoveSky(sky2)
      end
      sky3:UpdateTexture()
    end
  end
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain:RefreshWater()
    terrain:RefreshGrass()
  end
  return true
end
function load_special_weather_ini(scene, filename)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_msgbox(get_msg_str("msg_460") .. filename)
    nx_destroy(ini)
    return false
  end
  local weather = scene.weather
  weather.show_sun = nx_boolean(ini:ReadString("weather", "ShowSun", "true"))
  weather.show_flare = nx_boolean(ini:ReadString("weather", "ShowFlare", "true"))
  weather.fog_linear = nx_boolean(ini:ReadString("weather", "FogLinear", "true"))
  weather.fog_exp = nx_boolean(ini:ReadString("weather", "FogExp", "false"))
  weather.fog_density = ini:ReadFloat("weather", "FogDensity", 0.017)
  weather.fog_height = ini:ReadFloat("weather", "FogHeight", 380)
  weather.fog_height_exp = ini:ReadFloat("weather", "FogHeightExp", 1)
  weather.fog_start = ini:ReadFloat("weather", "FogStart", 200)
  weather.fog_start_origin = weather.fog_start
  weather.fog_end = ini:ReadFloat("weather", "FogEnd", 500)
  weather.fog_red = ini:ReadInteger("weather", "FogRed", 200)
  weather.fog_green = ini:ReadInteger("weather", "FogGreen", 200)
  weather.fog_blue = ini:ReadInteger("weather", "FogBlue", 200)
  weather.fog_exp_red = ini:ReadInteger("weather", "FogExpRed", 200)
  weather.fog_exp_green = ini:ReadInteger("weather", "FogExpGreen", 200)
  weather.fog_exp_blue = ini:ReadInteger("weather", "FogExpBlue", 200)
  weather.sunglow_red = ini:ReadInteger("weather", "SunglowRed", 0)
  weather.sunglow_green = ini:ReadInteger("weather", "SunglowGreen", 0)
  weather.sunglow_blue = ini:ReadInteger("weather", "SunglowBlue", 0)
  weather.ambient_red = ini:ReadInteger("weather", "AmbientRed", 0)
  weather.ambient_green = ini:ReadInteger("weather", "AmbientGreen", 0)
  weather.ambient_blue = ini:ReadInteger("weather", "AmbientBlue", 0)
  weather.specular_red = ini:ReadInteger("weather", "SpecularRed", 0)
  weather.specular_green = ini:ReadInteger("weather", "SpecularGreen", 0)
  weather.specular_blue = ini:ReadInteger("weather", "SpecularBlue", 0)
  weather.ambient_intensity = ini:ReadFloat("weather", "AmbientIntensity", 1)
  weather.sunglow_intensity = ini:ReadFloat("weather", "SunGlowIntensity", 1)
  weather.specular_intensity = ini:ReadFloat("weather", "SpecularIntensity", 1)
  weather.sun_height = ini:ReadInteger("weather", "SunHeight", 20)
  weather.sun_azimuth = ini:ReadInteger("weather", "SunAzimuth", 0)
  local skyuptex = ini:ReadString("weather", "SkyUpTex", "")
  if skyuptex ~= "" then
    weather.sky_up_tex = "map\\" .. skyuptex
  end
  local skysidetex = ini:ReadString("weather", "SkySideTex", "")
  if skysidetex ~= "" then
    weather.sky_side_tex = "map\\" .. skysidetex
  end
  local suntex = ini:ReadString("weather", "SunTex", "")
  if suntex ~= "" then
    weather.sun_tex = "map\\" .. suntex
  end
  weather.wind_speed = ini:ReadFloat("weather", "WindSpeed", 0)
  weather.wind_angle = ini:ReadFloat("weather", "WindAngle", 0)
  local weather_set_data = nx_value("weather_set_data")
  if nx_is_valid(weather_set_data) then
    weather_set_data.show_sun = weather.show_sun
    weather_set_data.show_moon = weather.show_sun
    if skyuptex ~= "" then
      weather_set_data.sky3_upTex = weather.sky_up_tex
    else
      weather_set_data.sky3_upTex = ""
    end
  end
  nx_destroy(ini)
end
function change_special_weather(scene, filepath)
  local weather_manager = nx_value("weather_manager")
  if nx_is_valid(weather_manager) then
    local IsLua = weather_manager:IsLua()
    if not IsLua then
      return 0
    end
  end
  if not nx_is_valid(scene) then
    return 0
  end
  local cloud = scene.cloud
  if not nx_is_valid(cloud) then
    return 0
  end
  if cloud.special then
    return 0
  end
  load_cloud_ini(scene, filepath .. "cloud.ini")
  load_special_weather_ini(scene, filepath .. "weather.ini")
  nx_execute("terrain\\weather", "change_special_weather_data", scene)
  nx_call("terrain\\filter", "load_ppfilter_ini", scene, filepath .. "ppfilter.ini")
  nx_execute("terrain\\filter", "change_ppfilter", scene)
  nx_call("terrain\\hdr", "load_pphdr_ini", scene, filepath .. "pphdr.ini")
  nx_execute("terrain\\hdr", "change_pphdr", scene)
  nx_call("terrain\\bloom", "load_ppbloom_ini", scene, filepath .. "ppbloom.ini")
  nx_execute("terrain\\bloom", "change_ppbloom", scene)
  nx_call("terrain\\volumelighting", "load_ppvolumelighting_ini", scene, filepath .. "ppvolumelighting.ini")
  nx_execute("terrain\\volumelighting", "change_ppvolumelighting", scene)
  nx_call("terrain\\screenrefraction", "load_ppscreenrefraction_ini", scene, filepath .. "ppscreenrefraction.ini")
  nx_execute("terrain\\screenrefraction", "change_ppscreenrefraction", scene)
  nx_call("terrain\\pixelrefraction", "load_pppixelrefraction_ini", scene, filepath .. "pppixelrefraction.ini")
  nx_execute("terrain\\pixelrefraction", "change_pppixelrefraction", scene)
  nx_call("terrain\\glow", "load_ppglow_ini", scene, filepath .. "ppglow.ini")
  nx_execute("terrain\\glow", "change_ppglow", scene)
  nx_call("terrain\\pssm", "load_pssm_ini", scene, filepath .. "pssm.ini")
  nx_execute("terrain\\pssm", "change_pssm", scene)
  nx_call("terrain\\hbao", "load_hbao_ini", scene, filepath .. "hbao.ini")
  nx_execute("terrain\\hbao", "change_hbao", scene)
  nx_call("terrain\\ssao", "load_ssao_ini", scene, filepath .. "ssao.ini")
  nx_execute("terrain\\ssao", "change_ssao", scene)
  nx_call("terrain\\dof", "load_ppdof_ini", scene, filepath .. "ppdof.ini")
  nx_execute("terrain\\dof", "change_ppdof", scene)
  nx_execute("terrain\\terrain", "change_screen", scene)
  nx_call("terrain\\role_param", "load_role_ini", scene, filepath .. "role.ini")
  nx_execute("terrain\\role_param", "change_role_param", scene)
  nx_call("terrain\\screenblur", "load_ppscreenblur_ini", scene, filepath .. "ppscrblur.ini")
  nx_execute("terrain\\screenblur", "change_ppscreenblur", scene)
  nx_execute("terrain\\fxaa", "change_fxaa", scene)
  nx_execute("terrain\\terrain", "load_water_ini", scene, filepath .. "water.ini", false)
  nx_execute("ocean_edit\\ocean_edit", "terrain_read_ocean")
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    nx_call("game_config", "apply_performance_config", scene, game_config)
  end
  return 1
end
