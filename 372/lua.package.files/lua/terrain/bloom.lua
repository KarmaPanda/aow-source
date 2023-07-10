function create_ppbloom(scene)
  local ppbloom_uiparam = scene.ppbloom_uiparam
  if not nx_is_valid(ppbloom_uiparam) then
    ppbloom_uiparam = create_ppbloom_uiparam(scene)
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  local ppbloom = scene:Create("PPBloom")
  postprocess_man:RegistPostProcess(ppbloom)
  ppbloom.MaxBrightness = ppbloom_uiparam.brightness
  ppbloom.GlowWeight = ppbloom_uiparam.glowweight
  ppbloom.Dither1X = ppbloom_uiparam.dither1x
  ppbloom.Dither1Y = ppbloom_uiparam.dither1y
  ppbloom.Dither2X = ppbloom_uiparam.dither2x
  ppbloom.Dither2Y = ppbloom_uiparam.dither2y
  scene.ppbloom = ppbloom
  return true
end
function delete_ppbloom(scene)
  local ppbloom = scene.ppbloom
  if nx_is_valid(ppbloom) then
    local ppm = scene.postprocess_man
    if nx_is_valid(ppm) then
      ppm:UnregistPostProcess(ppbloom)
    end
    scene:Delete(ppbloom)
  end
  return true
end
function create_ppbloom_uiparam(scene)
  local ppbloom_uiparam = nx_call("util_gui", "get_global_arraylist", "ppbloom_uiparam")
  ppbloom_uiparam.bloom_enable = false
  ppbloom_uiparam.brightness = 1
  ppbloom_uiparam.glowweight = 1.2
  ppbloom_uiparam.dither1x = 0.0025
  ppbloom_uiparam.dither1y = 0.0026
  ppbloom_uiparam.dither2x = 0.002
  ppbloom_uiparam.dither2y = 0.002
  scene.ppbloom_uiparam = ppbloom_uiparam
  return ppbloom_uiparam
end
function load_ppbloom_ini(scene, filename)
  local ppbloom_uiparam = scene.ppbloom_uiparam
  if not nx_is_valid(ppbloom_uiparam) then
    ppbloom_uiparam = create_ppbloom_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  ppbloom_uiparam.brightness = ini:ReadFloat("ppbloom", "MaxBrightness", ppbloom_uiparam.brightness)
  ppbloom_uiparam.glowweight = ini:ReadFloat("ppbloom", "GlowWeight", ppbloom_uiparam.glowweight)
  ppbloom_uiparam.dither1x = ini:ReadFloat("ppbloom", "Dither1X", ppbloom_uiparam.dither1x)
  ppbloom_uiparam.dither1y = ini:ReadFloat("ppbloom", "Dither1Y", ppbloom_uiparam.dither1y)
  ppbloom_uiparam.dither2x = ini:ReadFloat("ppbloom", "Dither2X", ppbloom_uiparam.dither2x)
  ppbloom_uiparam.dither2y = ini:ReadFloat("ppbloom", "Dither2Y", ppbloom_uiparam.dither2y)
  nx_destroy(ini)
  return true
end
function change_ppbloom(scene)
  local ppbloom_uiparam = scene.ppbloom_uiparam
  if not nx_is_valid(ppbloom_uiparam) then
    ppbloom_uiparam = create_ppbloom_uiparam(scene)
  end
  if ppbloom_uiparam.bloom_enable then
    local ppbloom = scene.ppbloom
    if not nx_is_valid(ppbloom) then
      create_ppbloom(scene)
      ppbloom = scene.ppbloom
    end
    ppbloom.MaxBrightness = ppbloom_uiparam.brightness
    ppbloom.GlowWeight = ppbloom_uiparam.glowweight
    ppbloom.Dither1X = ppbloom_uiparam.dither1x
    ppbloom.Dither1Y = ppbloom_uiparam.dither1y
    ppbloom.Dither2X = ppbloom_uiparam.dither2x
    ppbloom.Dither2Y = ppbloom_uiparam.dither2y
  else
    delete_ppbloom(scene)
  end
  return true
end
