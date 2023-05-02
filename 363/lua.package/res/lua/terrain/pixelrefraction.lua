function change_pppixelrefraction(scene)
  if not nx_is_valid(scene) then
    return false
  end
  local pppixelrefraction_uiparam = scene.pppixelrefraction_uiparam
  if not nx_is_valid(pppixelrefraction_uiparam) then
    pppixelrefraction_uiparam = create_pppixelrefraction_uiparam(scene)
  end
  if pppixelrefraction_uiparam.enable then
    scene.EnableRealizeRefraction = true
    local pppixelrefraction = scene.pppixelrefraction
    if not nx_is_valid(pppixelrefraction) then
      create_pppixelrefraction(scene)
      pppixelrefraction = scene.pppixelrefraction
      if not nx_is_valid(pppixelrefraction) then
        return false
      end
    end
  else
    delete_pppixelrefraction(scene)
  end
  return true
end
function delete_pppixelrefraction(scene)
  if not nx_is_valid(scene) then
    return false
  end
  local pppixelrefraction = scene.pppixelrefraction
  if nx_is_valid(pppixelrefraction) then
    local postprocess_man = scene.postprocess_man
    if not nx_is_valid(postprocess_man) then
      return false
    end
    postprocess_man:UnregistPostProcess(pppixelrefraction)
    scene:Delete(pppixelrefraction)
  end
  scene.EnableRealizeRefraction = false
  return true
end
function create_pppixelrefraction(scene)
  if not nx_is_valid(scene) then
    return false
  end
  local pppixelrefraction_uiparam = scene.pppixelrefraction_uiparam
  if not nx_is_valid(pppixelrefraction_uiparam) then
    return false
  end
  local pppixelrefraction = scene:Create("PPPixelRefraction")
  if not nx_is_valid(pppixelrefraction) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    scene:Delete(pppixelrefraction)
    return false
  end
  postprocess_man:RegistPostProcess(pppixelrefraction)
  pppixelrefraction.RefractionInten = pppixelrefraction_uiparam.refraction_inten
  scene.pppixelrefraction = pppixelrefraction
  return true
end
function create_pppixelrefraction_uiparam(scene)
  local pppixelrefraction_uiparam = nx_call("util_gui", "get_global_arraylist", "pppixelrefraction_uiparam")
  pppixelrefraction_uiparam.enable = false
  pppixelrefraction_uiparam.refraction_inten = 0.1
  scene.pppixelrefraction_uiparam = pppixelrefraction_uiparam
  return pppixelrefraction_uiparam
end
function load_pppixelrefraction_ini(scene, filename)
  local pppixelrefraction_uiparam = scene.pppixelrefraction_uiparam
  if not nx_is_valid(pppixelrefraction_uiparam) then
    pppixelrefraction_uiparam = create_pppixelrefraction_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  pppixelrefraction_uiparam.refraction_inten = ini:ReadFloat("pppixelrefraction", "RefractionInten", 0.1)
  nx_destroy(ini)
  return true
end
