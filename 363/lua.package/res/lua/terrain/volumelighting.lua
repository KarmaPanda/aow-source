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
function change_ppvolumelighting(scene)
  local ppvolumelighting_uiparam = scene.ppvolumelighting_uiparam
  if not nx_is_valid(ppvolumelighting_uiparam) then
    ppvolumelighting_uiparam = create_ppvolumelighting_uiparam(scene)
  end
  if ppvolumelighting_uiparam.enable then
    local ppvolumelighting = scene.ppvolumelighting
    if not nx_is_valid(ppvolumelighting) then
      create_ppvolumelighting(scene)
      ppvolumelighting = scene.ppvolumelighting
    end
    ppvolumelighting.SunColor = ppvolumelighting_uiparam.sun_color
    ppvolumelighting.SunRadius = ppvolumelighting_uiparam.sun_radius
    ppvolumelighting.SunLevel = ppvolumelighting_uiparam.sun_level
    ppvolumelighting.SunShineRadius = ppvolumelighting_uiparam.sun_shine_radius
    ppvolumelighting.SunShineUp = ppvolumelighting_uiparam.sun_shine_up
    ppvolumelighting.SampleBias = ppvolumelighting_uiparam.sample_bias
    ppvolumelighting.SampleDistance = ppvolumelighting_uiparam.sample_distance
  else
    delete_ppvolumelighting(scene)
  end
  return true
end
function create_ppvolumelighting(scene)
  local ppvolumelighting_uiparam = scene.ppvolumelighting_uiparam
  if not nx_is_valid(ppvolumelighting_uiparam) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  local ppvolumelighting = scene:Create("PPVolumelighting")
  if not nx_is_valid(ppvolumelighting) then
    return false
  end
  postprocess_man:RegistPostProcess(ppvolumelighting)
  scene.ppvolumelighting = ppvolumelighting
  return true
end
function delete_ppvolumelighting(scene)
  local ppvolumelighting = scene.ppvolumelighting
  if nx_is_valid(ppvolumelighting) then
    local postprocess_man = scene.postprocess_man
    if nx_is_valid(postprocess_man) then
      postprocess_man:UnregistPostProcess(ppvolumelighting)
    end
    scene:Delete(ppvolumelighting)
  end
  return true
end
function create_ppvolumelighting_uiparam(scene)
  local ppvolumelighting_uiparam = nx_call("util_gui", "get_global_arraylist", "ppvolumelighting_uiparam")
  ppvolumelighting_uiparam.enable = false
  ppvolumelighting_uiparam.sun_color = "255,153,90,255"
  ppvolumelighting_uiparam.sun_radius = 0.167
  ppvolumelighting_uiparam.sun_level = 2.577
  ppvolumelighting_uiparam.sun_shine_radius = 0.698
  ppvolumelighting_uiparam.sun_shine_up = 1.345
  ppvolumelighting_uiparam.sample_bias = 0.28
  ppvolumelighting_uiparam.sample_distance = 0.042
  scene.ppvolumelighting_uiparam = ppvolumelighting_uiparam
  return ppvolumelighting_uiparam
end
function load_ppvolumelighting_ini(scene, filename)
  local ppvolumelighting_uiparam = scene.ppvolumelighting_uiparam
  if not nx_is_valid(ppvolumelighting_uiparam) then
    ppvolumelighting_uiparam = create_ppvolumelighting_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  ppvolumelighting_uiparam.sun_color = convert_color(ini:ReadString("ppvolumelighting", "SunColor", ppvolumelighting_uiparam.sun_color))
  ppvolumelighting_uiparam.sun_radius = ini:ReadFloat("ppvolumelighting", "SunRadius", ppvolumelighting_uiparam.sun_radius)
  ppvolumelighting_uiparam.sun_level = ini:ReadFloat("ppvolumelighting", "SunLevel", ppvolumelighting_uiparam.sun_level)
  ppvolumelighting_uiparam.sun_shine_radius = ini:ReadFloat("ppvolumelighting", "SunShineRadius", ppvolumelighting_uiparam.sun_shine_radius)
  ppvolumelighting_uiparam.sun_shine_up = ini:ReadFloat("ppvolumelighting", "SunShineUp", ppvolumelighting_uiparam.sun_shine_up)
  ppvolumelighting_uiparam.sample_bias = ini:ReadFloat("ppvolumelighting", "SampleBias", ppvolumelighting_uiparam.sample_bias)
  ppvolumelighting_uiparam.sample_distance = ini:ReadFloat("ppvolumelighting", "SampleDistance", ppvolumelighting_uiparam.sample_distance)
  nx_destroy(ini)
  return true
end
