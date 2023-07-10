function change_fxaa(scene)
  local fxaa_uiparam = scene.fxaa_uiparam
  if not nx_is_valid(fxaa_uiparam) then
    fxaa_uiparam = create_fxaa_uiparam(scene)
  end
  if fxaa_uiparam.enable then
    local fxaa = get_fxaa(scene)
    fxaa.Level = fxaa_uiparam.level
  else
    del_fxaa(scene)
  end
  return true
end
function create_fxaa_uiparam(scene)
  local fxaa_uiparam = nx_call("util_gui", "get_global_arraylist", "fxaa_uiparam")
  fxaa_uiparam.enable = false
  fxaa_uiparam.level = 2
  scene.fxaa_uiparam = fxaa_uiparam
  return fxaa_uiparam
end
function delete_fxaa_force(scene)
  local fxaa = scene.fxaa
  if not nx_is_valid(fxaa) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  postprocess_man:UnregistPostProcess(fxaa)
  scene:Delete(fxaa)
  return true
end
function del_fxaa(scene)
  local fxaa = scene.fxaa
  if not nx_is_valid(fxaa) then
    return false
  end
  local fxaa_uiparam = scene.fxaa_uiparam
  if not nx_is_valid(fxaa_uiparam) then
    return false
  end
  if not fxaa_uiparam.enable then
    delete_fxaa_force(scene)
    return true
  end
  return false
end
function get_fxaa(scene)
  local fxaa = scene.fxaa
  if nx_is_valid(fxaa) then
    return fxaa
  end
  local fxaa_uiparam = scene.fxaa_uiparam
  if not nx_is_valid(fxaa_uiparam) then
    return nx_null()
  end
  if not fxaa_uiparam.enable then
    return nx_null()
  end
  fxaa = scene:Create("FXAA")
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    scene:Delete(fxaa)
    return nx_null()
  end
  postprocess_man:RegistPostProcess(fxaa)
  scene.fxaa = fxaa
  return fxaa
end
