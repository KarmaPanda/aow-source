require("const_define")
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
function load_ppfilter_ini(scene, filename)
  local ppfilter_uiparam = scene.ppfilter_uiparam
  if not nx_is_valid(ppfilter_uiparam) then
    ppfilter_uiparam = create_ppfilter_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  ppfilter_uiparam.gradual_enable = nx_boolean(ini:ReadString("ppfilter", "GradualEnable", nx_string(ppfilter_uiparam.gradual_enable)))
  ppfilter_uiparam.gradualstart = ini:ReadFloat("ppfilter", "GradualStart", ppfilter_uiparam.gradualstart)
  ppfilter_uiparam.gradualend = ini:ReadFloat("ppfilter", "GradualEnd", ppfilter_uiparam.gradualend)
  ppfilter_uiparam.gradualexp = ini:ReadFloat("ppfilter", "GradualExp", ppfilter_uiparam.gradualexp)
  ppfilter_uiparam.gradualcolor = convert_color(ini:ReadString("ppfilter", "GradualColor", ppfilter_uiparam.gradualcolor))
  ppfilter_uiparam.hsi_enable = nx_boolean(ini:ReadString("ppfilter", "HSIEnable", nx_string(ppfilter_uiparam.hsi_enable)))
  ppfilter_uiparam.hsi_basecolor = convert_color(ini:ReadString("ppfilter", "AdjustBaseColor", ppfilter_uiparam.hsi_basecolor))
  ppfilter_uiparam.hsi_brightness = ini:ReadFloat("ppfilter", "AdjustBrightness", ppfilter_uiparam.hsi_brightness)
  ppfilter_uiparam.hsi_contrast = ini:ReadFloat("ppfilter", "AdjustContrast", ppfilter_uiparam.hsi_contrast)
  ppfilter_uiparam.hsi_saturation = ini:ReadFloat("ppfilter", "AdjustSaturation", ppfilter_uiparam.hsi_saturation)
  ppfilter_uiparam.angle_enable = nx_boolean(ini:ReadString("ppfilter", "AngleEnable", nx_string(ppfilter_uiparam.angle_enable)))
  ppfilter_uiparam.anglestart = ini:ReadFloat("ppfilter", "AngleStart", ppfilter_uiparam.anglestart)
  ppfilter_uiparam.angleend = ini:ReadFloat("ppfilter", "AngleEnd", ppfilter_uiparam.angleend)
  ppfilter_uiparam.angleexp = ini:ReadFloat("ppfilter", "AngleExp", ppfilter_uiparam.angleexp)
  ppfilter_uiparam.anglecolor = convert_color(ini:ReadString("ppfilter", "AngleColor", ppfilter_uiparam.anglecolor))
  nx_destroy(ini)
  return true
end
function change_ppfilter(scene)
  local ppfilter_uiparam = scene.ppfilter_uiparam
  if not nx_is_valid(ppfilter_uiparam) then
    ppfilter_uiparam = create_ppfilter_uiparam(scene)
  end
  if ppfilter_uiparam.enable then
    local ppfilter = get_ppfilter(scene)
    ppfilter.GradualEnable = ppfilter_uiparam.gradual_enable
    ppfilter.GradualStart = ppfilter_uiparam.gradualstart
    ppfilter.GradualEnd = ppfilter_uiparam.gradualend
    ppfilter.GradualExp = ppfilter_uiparam.gradualexp
    ppfilter.GradualColor = ppfilter_uiparam.gradualcolor
    ppfilter.AdjustEnable = ppfilter_uiparam.hsi_enable
    ppfilter.AdjustBaseColor = ppfilter_uiparam.hsi_basecolor
    ppfilter.AdjustBrightness = ppfilter_uiparam.hsi_brightness
    ppfilter.AdjustContrast = ppfilter_uiparam.hsi_contrast
    ppfilter.AdjustSaturation = ppfilter_uiparam.hsi_saturation
    ppfilter.AngleEnable = ppfilter_uiparam.angle_enable
    ppfilter.AngleStart = ppfilter_uiparam.anglestart
    ppfilter.AngleEnd = ppfilter_uiparam.angleend
    ppfilter.AngleExp = ppfilter_uiparam.angleexp
    ppfilter.AngleColor = ppfilter_uiparam.anglecolor
  else
    del_ppfilter(scene)
  end
  return true
end
function change_ppfilter_transitional(scene)
  local ppfilter_uiparam = scene.ppfilter_uiparam
  if not nx_is_valid(ppfilter_uiparam) then
    ppfilter_uiparam = create_ppfilter_uiparam(scene)
  end
  local timer_game = nx_value(GAME_TIMER)
  local world = nx_value("world")
  timer_game:UnRegister("terrain\\filter", "shade_weather_gradualcolor", world)
  if ppfilter_uiparam.enable then
    local ppfilter = get_ppfilter(scene)
    ppfilter.GradualEnable = ppfilter_uiparam.gradual_enable
    ppfilter.GradualStart = ppfilter_uiparam.gradualstart
    ppfilter.GradualEnd = ppfilter_uiparam.gradualend
    ppfilter.GradualExp = ppfilter_uiparam.gradualexp
    local weather_set_data = nx_value("weather_set_data")
    if nx_is_valid(weather_set_data) then
      local a, r, g, b = nx_call("terrain\\weather", "parse_color", ppfilter_uiparam.gradualcolor)
      weather_set_data.gradual_color_red = r
      weather_set_data.gradual_color_green = g
      weather_set_data.gradual_color_blue = b
      a, r, g, b = nx_call("terrain\\weather", "parse_color", ppfilter.GradualColor)
      if r < weather_set_data.gradual_color_red then
        weather_set_data.gradual_color_red_add = 1
      else
        weather_set_data.gradual_color_red_add = -1
      end
      if g < weather_set_data.gradual_color_green then
        weather_set_data.gradual_color_green_add = 1
      else
        weather_set_data.gradual_color_green_add = -1
      end
      if b < weather_set_data.gradual_color_blue then
        weather_set_data.gradual_color_blue_add = 1
      else
        weather_set_data.gradual_color_blue_add = -1
      end
      timer_game:Register(250, 255, "terrain\\filter", "shade_weather_gradualcolor", world, -1, -1)
    end
    ppfilter.AdjustEnable = ppfilter_uiparam.hsi_enable
    ppfilter.AdjustBaseColor = ppfilter_uiparam.hsi_basecolor
    ppfilter.AdjustBrightness = ppfilter_uiparam.hsi_brightness
    ppfilter.AdjustContrast = ppfilter_uiparam.hsi_contrast
    ppfilter.AdjustSaturation = ppfilter_uiparam.hsi_saturation
    ppfilter.AngleEnable = ppfilter_uiparam.angle_enable
    ppfilter.AngleStart = ppfilter_uiparam.anglestart
    ppfilter.AngleEnd = ppfilter_uiparam.angleend
    ppfilter.AngleExp = ppfilter_uiparam.angleexp
    ppfilter.AngleColor = ppfilter_uiparam.anglecolor
  else
    del_ppfilter(scene)
  end
  return true
end
function shade_weather_gradualcolor()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return 0
  end
  local weather_set_data = nx_value("weather_set_data")
  if not nx_is_valid(weather_set_data) then
    return 0
  end
  if nx_find_custom(scene, "ppfilter") then
    local ppfilter = scene.ppfilter
    if nx_is_valid(ppfilter) then
      local a, r, g, b = nx_call("terrain\\weather", "parse_color", ppfilter.GradualColor)
      if r ~= weather_set_data.gradual_color_red then
        r = r + weather_set_data.gradual_color_red_add
      end
      if g ~= weather_set_data.gradual_color_green then
        g = g + weather_set_data.gradual_color_green_add
      end
      if b ~= weather_set_data.gradual_color_blue then
        b = b + weather_set_data.gradual_color_blue_add
      end
      ppfilter.GradualColor = "255," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
    end
  end
end
function create_ppfilter_uiparam(scene)
  local ppfilter_uiparam = nx_call("util_gui", "get_global_arraylist", "ppfilter_uiparam")
  ppfilter_uiparam.enable = false
  ppfilter_uiparam.gradual_enable = false
  ppfilter_uiparam.gradualstart = -0.5
  ppfilter_uiparam.gradualend = 0.8
  ppfilter_uiparam.gradualexp = 3
  ppfilter_uiparam.gradualcolor = "255,154,169,178"
  ppfilter_uiparam.hsi_enable = false
  ppfilter_uiparam.hsi_basecolor = "255,242,255,229"
  ppfilter_uiparam.hsi_brightness = 50
  ppfilter_uiparam.hsi_contrast = 0
  ppfilter_uiparam.hsi_saturation = 50
  ppfilter_uiparam.angle_enable = false
  ppfilter_uiparam.anglestart = 0.5
  ppfilter_uiparam.angleend = 0.7
  ppfilter_uiparam.angleexp = 0.7
  ppfilter_uiparam.anglecolor = "255,122,134,178"
  scene.ppfilter_uiparam = ppfilter_uiparam
  return ppfilter_uiparam
end
function delete_ppfilter_force(scene)
  local ppfilter = scene.ppfilter
  if not nx_is_valid(ppfilter) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  postprocess_man:UnregistPostProcess(ppfilter)
  scene:Delete(ppfilter)
  return true
end
function del_ppfilter(scene)
  local ppfilter = scene.ppfilter
  if not nx_is_valid(ppfilter) then
    return false
  end
  local ppfilter_uiparam = scene.ppfilter_uiparam
  if not nx_is_valid(ppfilter_uiparam) then
    return false
  end
  if not ppfilter_uiparam.enable then
    delete_ppfilter_force(scene)
    return true
  end
  return false
end
function get_ppfilter(scene)
  local ppfilter = scene.ppfilter
  if nx_is_valid(ppfilter) then
    return ppfilter
  end
  local ppfilter_uiparam = scene.ppfilter_uiparam
  if not nx_is_valid(ppfilter_uiparam) then
    return nx_null()
  end
  if not ppfilter_uiparam.enable then
    return nx_null()
  end
  ppfilter = scene:Create("PPFilter")
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    scene:Delete(ppfilter)
    return nx_null()
  end
  postprocess_man:RegistPostProcess(ppfilter)
  scene.ppfilter = ppfilter
  return ppfilter
end
