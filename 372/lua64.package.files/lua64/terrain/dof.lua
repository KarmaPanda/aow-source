function create_ppdof(scene, b_focus_player)
  local ppdof_uiparam = scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) then
    return false
  end
  local ppdof = scene:Create("PPDepthofField")
  if not nx_is_valid(ppdof) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  if b_focus_player == nil then
    b_focus_player = true
  end
  postprocess_man:RegistPostProcess(ppdof)
  if nx_find_custom(scene, "terrain") then
    local terrain = scene.terrain
    if nx_is_valid(terrain) then
      if b_focus_player then
        ppdof.FocusObject = terrain.Player
      else
        ppdof.FocusObject = nx_null()
      end
    end
  end
  scene.ppdof = ppdof
  return true
end
function create_ppdof_uiparam(scene)
  local ppdof_uiparam = nx_call("util_gui", "get_global_arraylist", "ppdof_uiparam")
  ppdof_uiparam.enable = false
  ppdof_uiparam.focusdepth = 2
  ppdof_uiparam.blurvalue = 0.02
  ppdof_uiparam.maxofblur = 2
  scene.ppdof_uiparam = ppdof_uiparam
  return ppdof_uiparam
end
function delete_ppdof(scene)
  local ppdof = scene.ppdof
  if nx_is_valid(ppdof) then
    local ppm = scene.postprocess_man
    if nx_is_valid(ppm) then
      ppm:UnregistPostProcess(ppdof)
    end
    scene:Delete(ppdof)
  end
  return true
end
function change_ppdof(scene, b_focus_player)
  local ppdof_uiparam = scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) then
    ppdof_uiparam = create_ppdof_uiparam(scene)
  end
  if ppdof_uiparam.enable then
    local ppdof = scene.ppdof
    if not nx_is_valid(ppdof) then
      create_ppdof(scene, b_focus_player)
      ppdof = scene.ppdof
      if not nx_is_valid(ppdof) then
        return false
      end
    end
    ppdof.FocusDepth = ppdof_uiparam.focusdepth
    ppdof.BlurValue = ppdof_uiparam.blurvalue
    ppdof.MaxofBlur = ppdof_uiparam.maxofblur
  else
    delete_ppdof(scene)
  end
  return true
end
function load_ppdof_ini(scene, filename)
  local ppdof_uiparam = scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) then
    ppdof_uiparam = create_ppdof_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  ppdof_uiparam.enable = nx_boolean(ini:ReadString("ppdof", "PPdofEnable", "false"))
  ppdof_uiparam.focusdepth = ini:ReadFloat("ppdof", "FocusDepth", ppdof_uiparam.focusdepth)
  ppdof_uiparam.blurvalue = ini:ReadFloat("ppdof", "BlurValue", ppdof_uiparam.blurvalue)
  ppdof_uiparam.maxofblur = ini:ReadFloat("ppdof", "MaxofBlur", ppdof_uiparam.maxofblur)
  nx_destroy(ini)
  return true
end
function dof_effect_open()
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local game_scene = role.scene
  if nx_is_valid(game_scene) then
    game_scene.ppdof_uiparam.blurvalue = 0.4
    game_scene.ppdof_uiparam.maxofblur = 4
    game_scene.ppdof_uiparam.focusdepth = 4
    nx_execute("game_config", "set_dof_enable", game_scene, true)
  end
end
function dof_effect_close()
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local game_scene = role.scene
  if nx_is_valid(game_scene) then
    nx_execute("game_config", "set_dof_enable", game_scene, false)
  end
end
function dof_set_depth(distance)
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local game_scene = role.scene
  if nx_is_valid(game_scene) and nx_is_valid(game_scene.ppdof) then
    game_scene.ppdof.FocusDepth = distance
  end
end
