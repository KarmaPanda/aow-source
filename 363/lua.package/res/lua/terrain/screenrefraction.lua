function create_ppscreenrefraction(scene)
  if not nx_is_valid(scene) then
    return false
  end
  local ppscreenrefraction_uiparam = scene.ppscreenrefraction_uiparam
  local ppscreenrefraction = scene:Create("PPScreenRefraction")
  if not nx_is_valid(ppscreenrefraction) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    scene:Delete(ppscreenrefraction)
    return false
  end
  postprocess_man:RegistPostProcess(ppscreenrefraction)
  scene.ppscreenrefraction = ppscreenrefraction
  return true
end
function change_ppscreenrefraction(scene)
  if not nx_is_valid(scene) then
    return false
  end
  local ppscreenrefraction_uiparam = scene.ppscreenrefraction_uiparam
  if not nx_is_valid(ppscreenrefraction_uiparam) then
    return false
  end
  ppscreenrefraction_uiparam.enable = true
  if ppscreenrefraction_uiparam.enable then
    local ppscreenrefraction = scene.ppscreenrefraction
    if not nx_is_valid(ppscreenrefraction) then
      create_ppscreenrefraction(scene)
      ppscreenrefraction = scene.ppscreenrefraction
      if not nx_is_valid(ppscreenrefraction) then
        return false
      end
    end
    ppscreenrefraction.RefractionInten = ppscreenrefraction_uiparam.refraction_inten
    ppscreenrefraction.RefractionScale = ppscreenrefraction_uiparam.refraction_scale
    ppscreenrefraction.OffsetDirectionX = ppscreenrefraction_uiparam.offset_direction_x
    ppscreenrefraction.OffsetDirectionZ = ppscreenrefraction_uiparam.offset_direction_z
    ppscreenrefraction.RefractionMap = ppscreenrefraction_uiparam.refraction_map
  else
    delete_ppscreenrefraction(scene)
  end
  return true
end
function create_ppscreenrefraction_uiparam(scene)
  local ppscreenrefraction_uiparam = nx_call("util_gui", "get_global_arraylist", "ppscreenrefraction_uiparam")
  ppscreenrefraction_uiparam.enable = false
  ppscreenrefraction_uiparam.refraction_inten = 0.03
  ppscreenrefraction_uiparam.refraction_scale = 0.9
  ppscreenrefraction_uiparam.offset_direction_x = 0.12
  ppscreenrefraction_uiparam.offset_direction_z = 0.08
  ppscreenrefraction_uiparam.refraction_map = ""
  scene.ppscreenrefraction_uiparam = ppscreenrefraction_uiparam
  return ppscreenrefraction_uiparam
end
function load_ppscreenrefraction_ini(scene, filename)
  local ppscreenrefraction_uiparam = scene.ppscreenrefraction_uiparam
  if not nx_is_valid(ppscreenrefraction_uiparam) then
    ppscreenrefraction_uiparam = create_ppscreenrefraction_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  ppscreenrefraction_uiparam.refraction_inten = ini:ReadFloat("ppscreenrefraction", "RefractionInten", 0.03)
  ppscreenrefraction_uiparam.refraction_scale = ini:ReadFloat("ppscreenrefraction", "RefractionScale", 0.9)
  ppscreenrefraction_uiparam.offset_direction_x = ini:ReadFloat("ppscreenrefraction", "OffsetDirectionX", 0.12)
  ppscreenrefraction_uiparam.offset_direction_z = ini:ReadFloat("ppscreenrefraction", "OffsetDirectionZ", 0.08)
  ppscreenrefraction_uiparam.refraction_map = ini:ReadString("ppscreenrefraction", "RefractionMap", "map\\tex\\Water\\default_screen_refraction.dds")
  local pos = string.find(ppscreenrefraction_uiparam.refraction_map, "map")
  if pos == nil or 1 < pos then
    ppscreenrefraction_uiparam.refraction_map = "map\\" .. ppscreenrefraction_uiparam.refraction_map
  end
  nx_destroy(ini)
  return true
end
function delete_ppscreenrefraction(scene)
  if not nx_is_valid(scene) then
    return false
  end
  local ppscreenrefraction = scene.ppscreenrefraction
  if nx_is_valid(ppscreenrefraction) then
    local postprocess_man = scene.postprocess_man
    if not nx_is_valid(postprocess_man) then
      return false
    end
    postprocess_man:UnregistPostProcess(ppscreenrefraction)
    scene:Delete(ppscreenrefraction)
  end
  return true
end
