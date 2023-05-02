require("const_define")
local HEART_TIME = 1000
local CAMERA_TIME = 1000
local SOUND_PATH = "snd\\weather\\"
function get_scene_id()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return -1
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return -1
  end
  local scene_res_name = client_scene:QueryProp("ConfigID")
  if nil == string.find(scene_res_name, "\\") then
    return -1
  end
  local config_table = util_split_string(scene_res_name, "\\")
  local real_name = config_table[table.getn(config_table)]
  local map_id = nx_int(map_query:GetSceneId(real_name))
  if nx_int(map_id) <= nx_int(0) then
    scene_res_name = client_scene:QueryProp("Resource")
    map_id = nx_int(map_query:GetSceneId(scene_res_name))
  end
  return map_id
end
function change_current_effect(filepath)
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local cloud = scene.cloud
  if nx_is_valid(cloud) and cloud.special then
    return 0
  end
  nx_call("terrain\\weather", "load_cloud_ini", scene, filepath .. "cloud.ini")
  nx_call("terrain\\weather", "load_weather_ini", scene, filepath .. "weather.ini")
  nx_execute("terrain\\weather", "change_weather", scene)
  nx_call("terrain\\filter", "load_ppfilter_ini", scene, filepath .. "ppfilter.ini")
  nx_execute("terrain\\filter", "change_ppfilter_transitional", scene)
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
function initialize_weather_comparison_table(filename)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  if not ini:FindSection("weather") then
    nx_destroy(ini)
    return 0
  end
  local str = ini:GetItemList("weather")
  local weather_set_data = nx_create("ArrayList")
  if nx_is_valid(weather_set_data) then
    local effect_data_tab = weather_set_data:CreateChild("effect_data_tab")
    for i = 1, table.getn(str) do
      local key = nx_string(str[i])
      nx_set_custom(effect_data_tab, key, nx_string(ini:ReadString("weather", key, "")))
    end
    nx_set_value("weather_set_data", weather_set_data)
  end
  nx_destroy(ini)
  return 0
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
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local terrain = get_game_terrain()
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
function string_to_second(time_str)
  local second = 1
  if nil == time_str then
    return second
  end
  if nil == string.find(time_str, ":") then
    return second
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return second
  end
  local str_list = util_split_string(time_str, ":")
  second = (nx_number(str_list[1]) * weather_set_data.minute_num + nx_number(str_list[2])) * weather_set_data.minute_scale * 1000 / HEART_TIME + nx_number(str_list[3])
  return second
end
function load_weather_set_ini(scene_id, ini)
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    nx_destroy(weather_set_data)
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    nx_destroy(weather_set_data)
    return 0
  end
  if not ini:FindSection(scene_id) then
    nx_destroy(weather_set_data)
    return 0
  end
  local item_list = ini:GetItemValueList(scene_id, "r")
  local item_count = table.getn(item_list)
  if 0 == item_count then
    nx_destroy(weather_set_data)
    return 0
  end
  local i = 1
  for j = 1, item_count do
    if "" ~= item_list[j] then
      local str_list = util_split_string(item_list[j], ";")
      if "" ~= str_list[2] then
        local child = weather_set_data:CreateChild(nx_string(str_list[2]) .. "_" .. nx_string(i))
        i = i + 1
      end
    end
  end
  local child = weather_set_data:CreateChild("weather_parameter")
  child.type = "default"
  weather_set_data.time_count = ini:ReadInteger(scene_id, "TimeCount", 4)
  return 1
end
function delete_weather_data()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather_manager = nx_value("weather_manager")
  if nx_is_valid(weather_manager) then
    local IsLua = weather_manager:IsLua()
    if not IsLua then
      weather_manager:ClearWeather()
      return 0
    end
  end
  local world = nx_value("world")
  local timer_game = nx_value(GAME_TIMER)
  timer_game:UnRegister("terrain\\weather_set", "eclipse_change", world)
  timer_game:UnRegister("terrain\\weather", "shade_weather_brightness", world)
  timer_game:UnRegister("terrain\\weather_set", "change_time_automatic", world)
  timer_game:UnRegister("terrain\\weather_set", "change_camera_automatic", world)
  timer_game:UnRegister("terrain\\weather_set", "change_lightning_third", world)
  timer_game:UnRegister("terrain\\weather_set", "change_lightning_fourth", world)
  timer_game:UnRegister("terrain\\weather_set", "change_lightning_over", world)
  timer_game:UnRegister("terrain\\weather", "change_lunar_position", world)
  timer_game:UnRegister("terrain\\weather", "change_sky_color", world)
  timer_game:UnRegister("terrain\\weather", "change_cloud_color", world)
  timer_game:UnRegister("terrain\\weather", "shade_weather_color", world)
  timer_game:UnRegister("terrain\\filter", "shade_weather_gradualcolor", world)
  stop_all_specific_sound()
  local eclipse_effectmodel = nx_value("eclipse_effectmodel")
  if nx_is_valid(eclipse_effectmodel) then
    scene:Delete(eclipse_effectmodel)
  end
  if nx_find_custom(scene, "lunar_mdl") then
    local lunar_mdl = nx_custom(scene, "lunar_mdl")
    if nx_is_valid(lunar_mdl) then
      scene:Delete(lunar_mdl)
    end
  end
  if nx_find_custom(scene, "sky") then
    local sky = nx_custom(scene, "sky")
    if nx_is_valid(sky) then
      scene:Delete(sky)
    end
  end
  local weather_set_data = nx_value("weather_set_data")
  if nx_is_valid(weather_set_data) then
    if nx_find_custom(weather_set_data, "model") then
      local model = nx_custom(weather_set_data, "model")
      if nx_is_valid(model) then
        local scene = get_game_scene()
        if nx_is_valid(scene) then
          local helper_list = model:GetHelperNameList()
          model:DeleteParticleOnHelper(helper_list[1])
          scene.camera:RemoveAsynPosObject(model)
          scene:Delete(model)
        end
      end
    end
    if nx_find_custom(weather_set_data, "aerial_model") then
      local aerial_model = nx_custom(weather_set_data, "aerial_model")
      if nx_is_valid(aerial_model) then
        local scene = get_game_scene()
        if nx_is_valid(scene) then
          local helper_list = aerial_model:GetHelperNameList()
          aerial_model:DeleteParticleOnHelper(helper_list[1])
          scene.camera:RemoveAsynPosObject(aerial_model)
          scene:Delete(aerial_model)
        end
      end
    end
    if nx_find_custom(weather_set_data, "upper_model") then
      local upper_model = nx_custom(weather_set_data, "upper_model")
      if nx_is_valid(upper_model) then
        local scene = get_game_scene()
        if nx_is_valid(scene) then
          local helper_list = upper_model:GetHelperNameList()
          upper_model:DeleteParticleOnHelper(helper_list[1])
          scene.camera:RemoveAsynPosObject(upper_model)
          scene:Delete(upper_model)
        end
      end
    end
    if nx_find_custom(weather_set_data, "weather_change_item_ini") then
      local ini = nx_custom(weather_set_data, "weather_change_item_ini")
      if nx_is_valid(ini) then
        nx_destroy(ini)
      end
    end
    nx_destroy(weather_set_data)
  end
  if nx_find_custom(scene, "cloud") then
    local cloud = nx_custom(scene, "cloud")
    if nx_is_valid(cloud) then
      scene:Delete(cloud)
    end
  end
  if nx_find_custom(scene, "sky2") then
    local sky = nx_custom(scene, "sky2")
    if nx_is_valid(sky) then
      scene:Delete(sky)
    end
  end
  if nx_find_custom(scene, "sky3") then
    local sky = nx_custom(scene, "sky3")
    if nx_is_valid(sky) then
      scene:Delete(sky)
    end
  end
  local sun = scene.sun
  if nx_is_valid(sun) then
    scene:Delete(sun)
  end
end
function resume_weather_state(scene, filepath, game_config)
  if not nx_is_valid(scene) then
    return 0
  end
  nx_call("terrain\\weather", "load_cloud_ini", scene, filepath .. "cloud.ini")
  nx_call("terrain\\weather", "load_weather_ini", scene, filepath .. "weather.ini")
  nx_execute("terrain\\weather", "change_weather", scene)
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
  if nx_is_valid(game_config) then
    nx_execute("game_config", "apply_performance_config", scene, game_config)
  end
  nx_execute("terrain\\terrain", "load_water_ini", scene, filepath .. "water.ini", false)
  nx_execute("ocean_edit\\ocean_edit", "terrain_read_ocean")
end
function initialize_weather_data()
  local weather_set_data = nx_value("weather_set_data")
  if nx_is_valid(weather_set_data) then
    nx_destroy(weather_set_data)
  end
  local WeatherTimeManager = nx_value("WeatherTimeManager")
  if not nx_is_valid(WeatherTimeManager) then
    return 0
  end
  local weather_manager = nx_value("weather_manager")
  if not nx_is_valid(weather_manager) then
    return 0
  end
  local year = ""
  local elapse = 0
  while "" == year and elapse <= 30 do
    year = nx_string(WeatherTimeManager:GetGameYear())
    elapse = elapse + nx_pause(0)
  end
  local IsLua = weather_manager:IsLua()
  if not IsLua then
    weather_manager:InitWeatherData()
    return 0
  end
  local month = WeatherTimeManager:GetGameMonth()
  local date = WeatherTimeManager:GetGameDay()
  local hour = WeatherTimeManager:GetGameHour()
  local minute = WeatherTimeManager:GetGameMinute()
  local section = WeatherTimeManager:GetWeatherTTID()
  if section == nil then
    section = ""
  else
    section = nx_string(section)
  end
  local fadeintime = WeatherTimeManager:GetWeatherTTLastTime()
  if fadeintime == nil then
    fadeintime = 0
  else
    fadeintime = nx_number(fadeintime)
  end
  local specific = WeatherTimeManager:GetWeatherTXID()
  if specific == nil then
    specific = ""
  else
    specific = nx_string(specific)
  end
  start_weather(year, month, date, hour, minute, section, fadeintime, specific)
end
function start_weather(year, month, date, hour, minute, section, fadeintime, specific)
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return 0
  end
  local scene = get_game_scene()
  scene.EnableHeightMap = true
  local world = nx_value("world")
  local timer_game = nx_value(GAME_TIMER)
  timer_game:UnRegister("terrain\\weather_set", "change_time_automatic", world)
  timer_game:UnRegister("terrain\\weather_set", "change_camera_automatic", world)
  local filename = nx_resource_path() .. "map\\ini\\weather\\weather_comparison.ini"
  initialize_weather_comparison_table(filename)
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "share\\Rule\\Weather\\WeatherConfig.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    nx_destroy(weather_set_data)
    return 0
  end
  if not ini:FindSection("TimeRule") then
    nx_destroy(ini)
    nx_destroy(weather_set_data)
    return 0
  end
  local ini_item = nx_create("IniDocument")
  ini_item.FileName = nx_resource_path() .. "share\\Rule\\Weather\\WeatherChangeItem.ini"
  if not ini_item:LoadFromFile() then
    nx_destroy(ini_item)
    nx_destroy(ini)
    nx_destroy(weather_set_data)
    return 0
  end
  nx_set_custom(weather_set_data, "weather_change_item_ini", ini_item)
  weather_set_data.month_num = ini:ReadInteger("TimeRule", "Year", 12)
  weather_set_data.date_num = ini:ReadInteger("TimeRule", "Month", 30)
  weather_set_data.hour_num = ini:ReadInteger("TimeRule", "Day", 12)
  weather_set_data.minute_num = ini:ReadInteger("TimeRule", "Hour", 8)
  weather_set_data.minute_scale = ini:ReadInteger("TimeRule", "Minute", 75)
  weather_set_data.sun_up = ini:ReadInteger("TimeRule", "SunDayStart", 4)
  if weather_set_data.sun_up >= weather_set_data.hour_num then
    weather_set_data.sun_up = weather_set_data.hour_num - 1
  end
  if 0 > weather_set_data.sun_up then
    weather_set_data.sun_up = 0
  end
  weather_set_data.moon_up = ini:ReadInteger("TimeRule", "SunDayEnd", 9) + 1
  nx_destroy(ini)
  if weather_set_data.moon_up >= weather_set_data.hour_num then
    weather_set_data.moon_up = weather_set_data.hour_num
  end
  if 0 > weather_set_data.moon_up then
    weather_set_data.moon_up = 0
  end
  weather_set_data.time_adjust = true
  local scene_id = get_scene_id()
  if nx_int(scene_id) > nx_int(0) then
    local ini_period = nx_create("IniDocument")
    ini_period.FileName = nx_resource_path() .. "share\\Rule\\Weather\\WeatherChange.ini"
    if not ini_period:LoadFromFile() then
      nx_destroy(ini_item)
      nx_destroy(ini_period)
      nx_destroy(weather_set_data)
      return 0
    end
    load_weather_set_ini(nx_string(scene_id), ini_period)
    nx_destroy(ini_period)
  else
    nx_destroy(ini_item)
    nx_destroy(weather_set_data)
    return 0
  end
  weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    nx_destroy(ini_item)
    return 0
  end
  weather_set_data.sun_time = (weather_set_data.moon_up - weather_set_data.sun_up) * weather_set_data.minute_num * weather_set_data.minute_scale - 1
  weather_set_data.night_time = (weather_set_data.hour_num - weather_set_data.moon_up) * weather_set_data.minute_num * weather_set_data.minute_scale - 1
  weather_set_data.dawn_time = weather_set_data.sun_up * weather_set_data.minute_num * weather_set_data.minute_scale - 1
  if 0 >= weather_set_data.sun_time then
    weather_set_data.sun_time = 1
  end
  if 0 >= weather_set_data.night_time then
    weather_set_data.night_time = 1
  end
  if 0 >= weather_set_data.dawn_time then
    weather_set_data.dawn_time = 1
  end
  weather_set_data.lightning_scale = 0
  weather_set_data.special_sun = false
  weather_set_data.lightning_ongoing = false
  weather_set_data.lightning_sound = ""
  weather_set_data.special_brightness = 0
  weather_set_data.show_sun = true
  weather_set_data.show_moon = true
  weather_set_data.period_change = true
  weather_set_data.sky3_upTex = ""
  weather_set_data.period_current = section
  weather_set_data.lightning_gm = false
  weather_set_data.special_change = false
  weather_set_data.sun_height = 0
  weather_set_data.sun_azimuth = 120
  rechange_weather(year, month, date, hour, minute, section, fadeintime, specific)
  timer_game:Register(HEART_TIME, -1, "terrain\\weather_set", "change_time_automatic", world, -1, -1)
  timer_game:Register(CAMERA_TIME, -1, "terrain\\weather_set", "change_camera_automatic", world, -1, -1)
  local list = util_split_string(weather_set_data.data, ";")
  local specific_list = util_split_string(list[3], ",")
  if "" ~= specific_list[2] and "" ~= specific_list[1] and nx_find_custom(weather_set_data, "weather_change_item_ini") then
    local ini = nx_custom(weather_set_data, "weather_change_item_ini")
    if nx_is_valid(ini) then
      local child = weather_set_data:GetChild("weather_parameter")
      if nx_is_valid(child) then
        local section = nx_string(specific_list[1])
        if ini:FindSection(section) then
          child.type = ini:ReadString(section, "Para", "")
          if "" ~= child.type then
            local path = nx_resource_path() .. "share\\Rule\\Weather\\SceneParaStore\\" .. nx_string(child.type) .. "\\"
            if path_is_null(nx_string(child.type)) then
              weather_set_data.special_change = true
              nx_call("terrain\\weather", "change_special_weather", scene, path)
            end
          end
        end
      end
    end
  end
  return 1
end
function path_is_null(path)
  if nil == path then
    return false
  end
  if string.len(path) <= 1 then
    return false
  end
  if nil ~= string.find(path, " ") then
    return false
  else
    return true
  end
end
function rechange_weather(year, month, date, hour, minute, section, fadeintime, specific)
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local sun = scene.sun
  if not nx_is_valid(sun) then
    nx_call("terrain\\weather", "create_sun", scene)
  end
  weather_set_data.time_now = nx_string(year) .. "," .. nx_string(month) .. "," .. nx_string(date) .. "," .. nx_string(hour) .. "," .. nx_string(minute) .. ",0"
  weather_set_data.data = nx_string(section) .. ";" .. nx_string(fadeintime) .. ";" .. nx_string(specific)
end
function basic_set_sky_moon()
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return 0
  end
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local sun = scene.sun
  if not nx_is_valid(sun) then
    return 0
  end
  sun.ShowGlow = false
  sun.ShowFlare = false
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local model = nx_value("eclipse_effectmodel")
  if nx_is_valid(model) then
    local lunar_mdl = scene.lunar_mdl
    if nx_is_valid(lunar_mdl) then
      lunar_mdl.Visible = false
    end
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  if nil == string.find(weather_set_data.period_current, "time4") then
    local lunar_mdl = scene.lunar_mdl
    if nx_is_valid(lunar_mdl) then
      lunar_mdl.Visible = false
    end
    local ppvolumelighting = scene.ppvolumelighting
    if nx_is_valid(ppvolumelighting) then
      nx_call("terrain\\volumelighting", "delete_ppvolumelighting", scene)
    end
    return 0
  end
  if world.UseLightMap then
    world.UseLightMap = false
  end
  if not weather_set_data.show_moon then
    local lunar_mdl = scene.lunar_mdl
    if nx_is_valid(lunar_mdl) then
      lunar_mdl.Visible = false
    end
    local ppvolumelighting = scene.ppvolumelighting
    if nx_is_valid(ppvolumelighting) then
      nx_call("terrain\\volumelighting", "delete_ppvolumelighting", scene)
    end
  end
  scene.BackColor = weather.FogColor
  world.BackColor = weather.FogColor
  local moon_scale = 0
  local time_list = util_split_string(weather_set_data.time_now, ",")
  local hour = nx_number(time_list[4])
  if hour <= weather_set_data.sun_up then
    moon_scale = string_to_second(time_list[4] .. ":" .. time_list[5] .. ":" .. time_list[6]) / weather_set_data.dawn_time
    if 1 <= moon_scale then
      moon_scale = 1
    end
    weather.sun_height = (1 - moon_scale) * 90
  elseif hour >= weather_set_data.moon_up then
    moon_scale = (string_to_second(time_list[4] .. ":" .. time_list[5] .. ":" .. time_list[6]) - string_to_second(weather_set_data.moon_up .. ":0:0")) / weather_set_data.night_time
    if 1 <= moon_scale then
      moon_scale = 1
    end
    weather.sun_height = 180 - moon_scale * 90
  end
  weather.sun_azimuth = 120
  weather_set_data.sun_height = weather.sun_height
  if not weather_set_data.lightning_ongoing and not weather_set_data.lightning_gm then
    weather_set_data.sun_azimuth = weather.sun_azimuth
  end
  local sun_height_rad = weather_set_data.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = weather_set_data.sun_azimuth / 360 * math.pi * 2
  if not weather_set_data.lightning_ongoing and not weather_set_data.lightning_gm then
    weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  end
  if weather_set_data.show_moon then
    local lunar_mdl = scene.lunar_mdl
    if nx_is_valid(lunar_mdl) then
      if weather.sun_height <= 180 and 0 <= weather.sun_height and not weather_set_data.lightning_gm then
        lunar_mdl.Visible = true
      else
        lunar_mdl.Visible = false
      end
    end
  end
end
function basic_set_sky_sun()
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return 0
  end
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local sun = scene.sun
  if not nx_is_valid(sun) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local model = nx_value("eclipse_effectmodel")
  if nx_is_valid(model) then
    local lunar_mdl = scene.lunar_mdl
    if nx_is_valid(lunar_mdl) then
      lunar_mdl.Visible = false
    end
    sun.ShowGlow = false
    sun.ShowFlare = false
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local lunar_mdl = scene.lunar_mdl
  if nx_is_valid(lunar_mdl) then
    lunar_mdl.Visible = false
  end
  local time_list = util_split_string(weather_set_data.time_now, ",")
  scene.BackColor = weather.FogColor
  world.BackColor = weather.FogColor
  local sun_scale = (string_to_second(time_list[4] .. ":" .. time_list[5] .. ":" .. time_list[6]) - string_to_second(weather_set_data.sun_up .. ":0:0")) / weather_set_data.sun_time
  if 1 <= sun_scale then
    sun_scale = 1
  end
  weather.sun_height = (1 - sun_scale) * 180
  weather.sun_azimuth = 120
  weather_set_data.sun_height = weather.sun_height
  if not weather_set_data.lightning_ongoing and not weather_set_data.lightning_gm then
    weather_set_data.sun_azimuth = weather.sun_azimuth
  end
  local sun_height_rad = weather_set_data.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = weather_set_data.sun_azimuth / 360 * math.pi * 2
  if not weather_set_data.lightning_ongoing and not weather_set_data.lightning_gm then
    weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  end
  if weather_set_data.show_sun and not weather_set_data.lightning_gm then
    sun.ShowGlow = true
    sun.ShowFlare = true
    if not world.UseLightMap then
      world.UseLightMap = true
    end
  else
    sun.ShowGlow = false
    sun.ShowFlare = false
    if world.UseLightMap then
      world.UseLightMap = false
    end
  end
end
function lightning_specific()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local world = nx_value("world")
  local timer_game = nx_value(GAME_TIMER)
  local function_table = {
    "first",
    "second",
    "third",
    "fourth"
  }
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local ppvolumelighting = scene.ppvolumelighting
  if nx_is_valid(ppvolumelighting) then
    nx_call("terrain\\volumelighting", "delete_ppvolumelighting", scene)
  end
  local camera = scene.camera
  weather_set_data.lightning_angle = 60
  weather_set_data.sun_azimuth = camera.AngleY
  local scale = math.random(3, 4)
  weather_set_data.ambient_intensity = weather.AmbientIntensity
  weather_set_data.sunGlow_intensity = weather.SunGlowIntensity
  weather_set_data.specular_intensity = weather.SpecularIntensity
  weather_set_data.sun_glow_color = weather.SunGlowColor
  timer_game:Register(HEART_TIME / 10, 10, "terrain\\weather_set", "change_lightning_" .. function_table[scale], world, -1, -1)
end
function rechange_lightning_over_effect(scene)
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if nx_is_valid(weather_set_data) then
    weather.SunGlowColor = weather_set_data.sun_glow_color
  end
  nx_execute("terrain\\filter", "change_ppfilter", scene)
  nx_execute("terrain\\hdr", "change_pphdr", scene)
end
function change_lightning_over()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  weather.SunGlowColor = "0,255,255,255"
  local sun_height_rad = weather_set_data.lightning_angle / 360 * math.pi * 2
  local sun_azimuth_rad = weather_set_data.sun_azimuth
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  if scene.EnableHDR and nx_find_custom(scene, "pphdr") then
    local pphdr = scene.pphdr
    if nx_is_valid(pphdr) then
      pphdr.HDRExposure = 4
      pphdr.HDRGaussianScale = 20
    end
  end
  local pphdr_uiparam = nx_value("pphdr_uiparam")
  if nx_is_valid(pphdr_uiparam) and pphdr_uiparam.bloom_enable and nx_find_custom(scene, "pphdr") then
    local pphdr = scene.pphdr
    if nx_is_valid(pphdr) then
      pphdr.MaxBrightness = 0.15
      pphdr.GlowWeight = 0.25
    end
  end
  if nx_find_custom(scene, "ppfilter") then
    local ppfilter = scene.ppfilter
    if nx_is_valid(ppfilter) then
      ppfilter.AdjustEnable = true
      ppfilter.AdjustBaseColor = "255,255,255,255"
      ppfilter.AdjustBrightness = 50
      ppfilter.AdjustContrast = 0
    end
  end
  if weather_set_data.lightning_scale >= 12 then
    weather_set_data.lightning_scale = 12
  end
  local ppfilter = scene.ppfilter
  if nx_is_valid(ppfilter) then
    ppfilter.AdjustSaturation = 4 + ppfilter.AdjustSaturation
    if 50 <= ppfilter.AdjustSaturation then
      ppfilter.AdjustSaturation = 50
    end
  end
  if 0 < weather_set_data.lightning_scale then
    weather_set_data.lightning_scale = weather_set_data.lightning_scale - 1
  else
    weather_set_data.lightning_ongoing = false
    weather_set_data.lightning_gm = false
    weather_set_data.lightning_scale = 0
    local world = nx_value("world")
    local timer_game = nx_value(GAME_TIMER)
    timer_game:UnRegister("terrain\\weather_set", "change_lightning_over", world)
    rechange_lightning_over_effect(scene)
  end
  weather.SunGlowIntensity = weather_set_data.lightning_scale
  weather.AmbientIntensity = weather_set_data.ambient_intensity
  weather.SpecularIntensity = weather_set_data.specular_intensity
end
function change_lightning_fourth()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  weather.SunGlowColor = "0,255,255,255"
  local sun_height_rad = weather_set_data.lightning_angle / 360 * math.pi * 2
  local sun_azimuth_rad = weather_set_data.sun_azimuth
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  if scene.EnableHDR and nx_find_custom(scene, "pphdr") then
    local pphdr = scene.pphdr
    if nx_is_valid(pphdr) then
      pphdr.HDRExposure = 4
      pphdr.HDRGaussianScale = 20
    end
  end
  local pphdr_uiparam = nx_value("pphdr_uiparam")
  if nx_is_valid(pphdr_uiparam) and pphdr_uiparam.bloom_enable and nx_find_custom(scene, "pphdr") then
    local pphdr = scene.pphdr
    if nx_is_valid(pphdr) then
      pphdr.MaxBrightness = 0.15
      pphdr.GlowWeight = 0.25
    end
  end
  if nx_find_custom(scene, "ppfilter") then
    local ppfilter = scene.ppfilter
    if nx_is_valid(ppfilter) then
      ppfilter.AdjustEnable = true
      ppfilter.AdjustBaseColor = "255,255,255,255"
      ppfilter.AdjustBrightness = 50
      ppfilter.AdjustContrast = 0
      ppfilter.AdjustSaturation = 0
    end
  end
  weather.AmbientIntensity = 1
  weather_set_data.lightning_scale = 1 + weather_set_data.lightning_scale
  if weather_set_data.lightning_scale >= 7 then
    weather_set_data.lightning_scale = 10
    local world = nx_value("world")
    local timer_game = nx_value(GAME_TIMER)
    timer_game:UnRegister("terrain\\weather_set", "change_lightning_fourth", world)
    timer_game:Register(HEART_TIME / 10, -1, "terrain\\weather_set", "change_lightning_over", world, -1, -1)
    play_specific_sound(weather_set_data.lightning_sound)
  end
  if 2 < weather_set_data.lightning_scale then
    weather.SunGlowIntensity = weather_set_data.lightning_scale
  end
  weather.SpecularIntensity = 1.5
end
function change_lightning_third()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  weather.SunGlowColor = "0,255,255,255"
  local sun_height_rad = weather_set_data.lightning_angle / 360 * math.pi * 2
  local sun_azimuth_rad = weather_set_data.sun_azimuth
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  if scene.EnableHDR and nx_find_custom(scene, "pphdr") then
    local pphdr = scene.pphdr
    if nx_is_valid(pphdr) then
      pphdr.HDRExposure = 4
      pphdr.HDRGaussianScale = 20
    end
  end
  local pphdr_uiparam = nx_value("pphdr_uiparam")
  if nx_is_valid(pphdr_uiparam) and pphdr_uiparam.bloom_enable and nx_find_custom(scene, "pphdr") then
    local pphdr = scene.pphdr
    if nx_is_valid(pphdr) then
      pphdr.MaxBrightness = 0.15
      pphdr.GlowWeight = 0.25
    end
  end
  if nx_find_custom(scene, "ppfilter") then
    local ppfilter = scene.ppfilter
    if nx_is_valid(ppfilter) then
      ppfilter.AdjustEnable = true
      ppfilter.AdjustBaseColor = "255,255,255,255"
      ppfilter.AdjustBrightness = 50
      ppfilter.AdjustContrast = 0
      ppfilter.AdjustSaturation = 0
    end
  end
  weather.AmbientIntensity = 1
  if weather_set_data.lightning_scale == 0 then
    weather_set_data.lightning_scale = 10
  elseif weather_set_data.lightning_scale == 10 then
    weather_set_data.lightning_scale = 11
  elseif weather_set_data.lightning_scale == 11 then
    weather_set_data.lightning_scale = 3
  else
    weather_set_data.lightning_scale = weather_set_data.lightning_scale + 1
    if weather_set_data.lightning_scale >= 10 then
      weather_set_data.lightning_scale = 10
      local world = nx_value("world")
      local timer_game = nx_value(GAME_TIMER)
      timer_game:UnRegister("terrain\\weather_set", "change_lightning_third", world)
      timer_game:Register(HEART_TIME / 10, -1, "terrain\\weather_set", "change_lightning_over", world, -1, -1)
    elseif weather_set_data.lightning_scale == 8 then
      play_specific_sound(weather_set_data.lightning_sound)
    end
  end
  weather.SunGlowIntensity = weather_set_data.lightning_scale
  weather.SpecularIntensity = 1.5
end
function judge_weather_state()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  weather_set_data.show_sun = true
  weather_set_data.show_moon = true
  weather_set_data.special_brightness = 0
  local date = util_split_string(weather_set_data.data, ";")
  local specific_list = util_split_string(date[3], ",")
  if not nx_find_custom(weather_set_data, "weather_change_item_ini") then
    return 0
  end
  local ini = nx_custom(weather_set_data, "weather_change_item_ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local child = weather_set_data:GetChild("weather_parameter")
  if not nx_is_valid(child) then
    return 0
  end
  if "" == specific_list[2] or "" == specific_list[1] then
    weather_set_data.special_brightness = 2
    local cloud = scene.cloud
    if nx_is_valid(cloud) then
      cloud.special = false
    end
    stop_all_specific_sound()
    if "" ~= weather_set_data.period_current then
      local path = nx_resource_path() .. "share\\Rule\\Weather\\SceneParaStore\\" .. weather_set_data.period_current .. "\\"
      if path_is_null(weather_set_data.period_current) then
        nx_execute("terrain\\weather_set", "change_current_effect", path)
      end
    end
  else
    local section = nx_string(specific_list[1])
    if not ini:FindSection(section) then
      return 0
    end
    if nx_is_valid(child) and child.type == "default" then
      child.type = ini:ReadString(section, "Para", "")
      weather_set_data.special_brightness = 1
      local cloud = scene.cloud
      if nx_is_valid(cloud) then
        cloud.special = false
      end
      if "" ~= nx_string(child.type) then
        local path = nx_resource_path() .. "share\\Rule\\Weather\\SceneParaStore\\" .. nx_string(child.type) .. "\\"
        if path_is_null(nx_string(child.type)) then
          nx_execute("terrain\\weather_set", "change_current_effect", path)
        end
      end
    end
  end
  return 1
end
function change_time_automatic()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local time_list = util_split_string(weather_set_data.time_now, ",")
  local year = nx_number(time_list[1])
  local month = nx_number(time_list[2])
  local date = nx_number(time_list[3])
  local hour = nx_number(time_list[4])
  local minute = nx_number(time_list[5])
  local second = nx_number(time_list[6])
  if weather_set_data.time_adjust then
    second = 0
    weather_set_data.time_adjust = false
  else
    second = second + 1
  end
  if second >= weather_set_data.minute_scale * 1000 / HEART_TIME then
    second = 0
    minute = minute + 1
    if minute >= weather_set_data.minute_num then
      minute = 0
      hour = hour + 1
      if hour >= nx_number(weather_set_data.hour_num) then
        hour = 0
        date = date + 1
        if date > weather_set_data.date_num then
          date = 1
          month = month + 1
          if month > weather_set_data.month_num then
            month = 1
            year = year + 1
          end
        end
      end
    end
  end
  weather_set_data.time_now = nx_string(year) .. "," .. nx_string(month) .. "," .. nx_string(date) .. "," .. nx_string(hour) .. "," .. nx_string(minute) .. "," .. nx_string(second)
  time_list = util_split_string(weather_set_data.time_now, ",")
  hour = nx_number(time_list[4])
  if hour < weather_set_data.sun_up or hour >= weather_set_data.moon_up then
    local sun = scene.sun
    if nx_is_valid(sun) then
      basic_set_sky_moon()
    end
  else
    local sun = scene.sun
    if nx_is_valid(sun) then
      basic_set_sky_sun()
    end
  end
  if weather_set_data.period_change then
    weather_set_data.period_change = false
    local str = util_split_string(weather_set_data.data, ";")
    local specific_list = util_split_string(str[3], ",")
    if "" ~= nx_string(str[1]) then
      weather_set_data.special_brightness = 0
      local cloud = scene.cloud
      if nx_is_valid(cloud) and ("" == specific_list[2] or "" == specific_list[1]) then
        cloud.special = false
      end
      local path = nx_resource_path() .. "share\\Rule\\Weather\\SceneParaStore\\" .. nx_string(str[1]) .. "\\"
      if path_is_null(nx_string(str[1])) then
        nx_execute("terrain\\weather_set", "change_current_effect", path)
      end
    end
  end
end
function get_game_scene()
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) then
    return scene
  end
  return nx_null()
end
function get_game_terrain()
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) then
    return scene.terrain
  end
  return nx_null()
end
function util_split_string(szbuffer, splits)
  if szbuffer == nil then
    return {}
  end
  return nx_function("ext_split_string", szbuffer, splits)
end
function play_specific_sound(sound_name)
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    local voice_player = voice_manager:GetVoicePlayer(sound_name)
    if nx_is_valid(voice_player) then
      voice_player:Play(choose_suited_file(sound_name))
    end
  end
end
function choose_suited_file(sound_name)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. SOUND_PATH .. "weather_snd.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return ""
  end
  local file_table = ini:ReadString("weather", sound_name, "")
  if "" == file_table then
    nx_destroy(ini)
    return ""
  end
  file_table = util_split_string(ini:ReadString("weather", sound_name, ""), ",")
  if table.getn(file_table) > 1 then
    local num = math.random(1, table.getn(file_table))
    nx_destroy(ini)
    return SOUND_PATH .. sound_name .. "\\" .. file_table[num] .. ".wav"
  elseif "" ~= file_table[1] then
    nx_destroy(ini)
    return SOUND_PATH .. sound_name .. "\\" .. file_table[1] .. ".wav"
  end
  nx_destroy(ini)
  return ""
end
function stop_specific_sound(sound_name)
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:ClearVoicePlayer(sound_name)
  end
end
function stop_all_specific_sound()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  local effect_data_tab = weather_set_data:GetChild("effect_data_tab")
  if not nx_is_valid(effect_data_tab) then
    return 0
  end
  local custom_list = nx_custom_list(effect_data_tab)
  local custom_list_num = table.getn(custom_list)
  if custom_list_num <= 0 then
    return 0
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    for i, v in ipairs(custom_list) do
      if "" ~= v then
        voice_manager:ClearVoicePlayer(v)
      end
    end
  end
end
function lightning_gm_start()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return 0
  end
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return 0
  end
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return 0
  end
  local sun = scene.sun
  if not nx_is_valid(sun) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  if not nx_find_custom(weather_set_data, "aerial_model") then
    local camera = scene.camera
    local name = gen_unique_name()
    if not nx_find_custom(effect_data_tab, "weather_model") then
      return 0
    end
    local str = util_split_string(nx_custom(effect_data_tab, "weather_model"), ",")
    local effectmodel_config = str[1]
    local effectmodel_name = str[2]
    local pos_x, pos_y, pos_z = camera.PositionX, camera.PositionY, camera.PositionZ
    local angle_x, angle_y, angle_z = 0, 0, 0
    local scale_x, scale_y, scale_z = 10, 10, 10
    local tag = "aerial_model"
    local effectmodel = put_effectmodel(name, effectmodel_config, effectmodel_name, pos_x, pos_y, pos_z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, tag)
    if nx_is_valid(effectmodel) then
      nx_set_custom(weather_set_data, "aerial_model", effectmodel)
      camera:AddAsynPosObject(effectmodel, 0, 30, -30)
    end
  end
  local aerial_model = nx_custom(weather_set_data, "aerial_model")
  if nx_is_valid(aerial_model) then
    local helper_list = aerial_model:GetHelperNameList()
    if not nx_is_valid(aerial_model:GetParticleFromName(helper_list[1], "lightning02")) then
      aerial_model:AddParticle("lightning02", helper_list[1], -1, -1)
    end
    weather_set_data.lightning_sound = "heavy_lightning"
    lightning_specific()
  end
end
function change_camera_automatic()
