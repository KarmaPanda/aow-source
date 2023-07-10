function create_ppglow(scene)
  local ppglow_uiparam = scene.ppglow_uiparam
  if not nx_is_valid(ppglow_uiparam) then
    return false
  end
  local ppglow = scene:Create("PPGlow")
  if not nx_is_valid(ppglow) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  postprocess_man:RegistPostProcess(ppglow)
  ppglow.Dither = ppglow_uiparam.dither
  scene.EnableRealizeGlow = true
  scene.ppglow = ppglow
  return true
end
function create_ppglow_uiparam(scene)
  local ppglow_uiparam = nx_call("util_gui", "get_global_arraylist", "ppglow_uiparam")
  ppglow_uiparam.enable = false
  ppglow_uiparam.dither = 0.002
  scene.ppglow_uiparam = ppglow_uiparam
  return ppglow_uiparam
end
function change_ppglow(scene)
  local ppglow_uiparam = scene.ppglow_uiparam
  if not nx_is_valid(ppglow_uiparam) then
    ppglow_uiparam = create_ppglow_uiparam(scene)
  end
  if ppglow_uiparam.enable then
    local ppglow = scene.ppglow
    if not nx_is_valid(ppglow) then
      create_ppglow(scene)
      ppglow = scene.ppglow
    end
    ppglow.Dither = ppglow_uiparam.dither
  else
    local ppglow = scene.ppglow
    if nx_is_valid(ppglow) then
      local postprocess_man = scene.postprocess_man
      if not nx_is_valid(postprocess_man) then
        return false
      end
      postprocess_man:UnregistPostProcess(ppglow)
      scene:Delete(ppglow)
      scene.EnableRealizeGlow = false
    end
  end
  return true
end
function load_ppglow_ini(scene, filename)
  local ppglow_uiparam = scene.ppglow_uiparam
  if not nx_is_valid(ppglow_uiparam) then
    ppglow_uiparam = create_ppglow_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  ppglow_uiparam.dither = ini:ReadFloat("ppglow", "Dither", ppglow_uiparam.dither)
  nx_destroy(ini)
  return true
end
