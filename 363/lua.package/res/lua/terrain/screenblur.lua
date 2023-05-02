function change_ppscreenblur(scene)
  local ppscreenblur_uiparam = scene.ppscreenblur_uiparam
  if not nx_is_valid(ppscreenblur_uiparam) then
    ppscreenblur_uiparam = create_ppscreenblur_uiparam
  end
  if ppscreenblur_uiparam.enable then
    local ppscreenblur = scene.ppscreenblur
    if not nx_is_valid(ppscreenblur) then
      create_ppscreenblur(scene)
      ppscreenblur = scene.ppscreenblur
    end
    ppscreenblur.BlurRate = ppscreenblur_uiparam.blurrate
    ppscreenblur.BlurValue = ppscreenblur_uiparam.blurvalue
  else
    delete_ppscreenblur(scene)
  end
  return true
end
function create_ppscreenblur(scene)
  local ppscreenblur_uiparam = scene.ppscreenblur_uiparam
  if not nx_is_valid(ppscreenblur_uiparam) then
    return false
  end
  local ppscreenblur = scene:Create("PPScreenBlur")
  if not nx_is_valid(ppscreenblur) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  postprocess_man:RegistPostProcess(ppscreenblur)
  scene.ppscreenblur = ppscreenblur
  return true
end
function delete_ppscreenblur(scene)
  local ppscreenblur = scene.ppscreenblur
  if not nx_is_valid(ppscreenblur) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  postprocess_man:UnregistPostProcess(ppscreenblur)
  scene:Delete(ppscreenblur)
  return true
end
function create_ppscreenblur_uiparam(scene)
  local ppscreenblur_uiparam = nx_call("util_gui", "get_global_arraylist", "ppscreenblur_uiparam")
  ppscreenblur_uiparam.enable = false
  ppscreenblur_uiparam.blurrate = 0.01
  ppscreenblur_uiparam.blurvalue = 1
  scene.ppscreenblur_uiparam = ppscreenblur_uiparam
  return ppscreenblur_uiparam
end
function load_ppscreenblur_ini(scene, filename)
  ppscreenblur_uiparam = scene.ppscreenblur_uiparam
  if not nx_is_valid(ppscreenblur_uiparam) then
    ppscreenblur_uiparam = create_ppscreenblur_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  ppscreenblur_uiparam.blurrate = ini:ReadFloat("ppscrblur", "BlurRate", ppscreenblur_uiparam.blurrate)
  ppscreenblur_uiparam.blurvalue = ini:ReadFloat("ppscrblur", "BlurValue", ppscreenblur_uiparam.blurvalue)
  nx_destroy(ini)
  return true
end
