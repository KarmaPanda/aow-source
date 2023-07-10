function delete_pssm(scene)
  local pssm = scene.pssm
  if nx_is_valid(pssm) then
    scene:RemoveObject(pssm)
    scene:Delete(pssm)
  end
  scene.EnableDynamicShadow = false
  return true
end
function change_pssm(scene)
  local pssm_uiparam = scene.pssm_uiparam
  if not nx_is_valid(pssm_uiparam) then
    pssm_uiparam = create_pssm_uiparam(scene)
  end
  if pssm_uiparam.pssm_enable then
    local pssm = scene.pssm
    if not nx_is_valid(pssm) then
      pssm = scene:Create("PSSM")
      scene.pssm = pssm
      scene:AddObject(pssm, 200)
    end
    local filter_mode = pssm_uiparam.filter_mode
    if filter_mode == "VSM" then
      pssm.EnableVSM = true
      pssm.EnablePCF = false
    elseif filter_mode == "PCF" then
      pssm.EnableVSM = false
      pssm.EnablePCF = true
    else
      pssm.EnableVSM = false
      pssm.EnablePCF = false
    end
    if pssm_uiparam.shadow_map_count == 3 then
      pssm.DepthSlope0 = pssm_uiparam.depth_slope0
      pssm.DepthSlope1 = pssm_uiparam.depth_slope1
      pssm.DepthSlope2 = pssm_uiparam.depth_slope2
      pssm.DepthBias0 = pssm_uiparam.depth_bias0
      pssm.DepthBias1 = pssm_uiparam.depth_bias1
      pssm.DepthBias2 = pssm_uiparam.depth_bias2
    else
      pssm.DepthSlope0 = pssm_uiparam.depth_slope0
      pssm.DepthSlope1 = pssm_uiparam.depth_slope1
      pssm.DepthSlope2 = pssm_uiparam.depth_slope2
      pssm.DepthSlope3 = pssm_uiparam.depth_slope3
      pssm.DepthBias0 = pssm_uiparam.depth_bias0
      pssm.DepthBias1 = pssm_uiparam.depth_bias1
      pssm.DepthBias2 = pssm_uiparam.depth_bias2
      pssm.DepthBias3 = pssm_uiparam.depth_bias3
    end
    pssm.FilterLevel = pssm_uiparam.filter_level
    pssm.ShadowInten = pssm_uiparam.shadow_inten
    pssm.ShadowMapCount = pssm_uiparam.shadow_map_count
    pssm.ShadowMapSize = pssm_uiparam.shadow_map_size
    pssm.ShadowMapCameraDistance = pssm_uiparam.camera_distance
    pssm.ShadowDistance = pssm_uiparam.shadow_distance
    pssm.LogSplitWeight = pssm_uiparam.log_split_weight
    pssm.VSMLowLimit = pssm_uiparam.vsm_low_limit
    pssm.ShadowMapCameraDistance = 250
    pssm.LogSplitWeight = 0.75
    scene.EnableDynamicShadow = true
    local light_man = scene.light_man
    light_man.FilterLevel = pssm_uiparam.filter_level
    light_man.VSMLowLimit = pssm_uiparam.vsm_low_limit
    light_man.MaxDistance = pssm_uiparam.shadow_distance
    light_man.ScatteringIntensity = pssm_uiparam.scattering_intensity
    light_man.ScatteringColor = pssm_uiparam.scattering_color
  else
    delete_pssm(scene)
  end
  if pssm_uiparam.pssm_enable and pssm_uiparam.prelight_enable then
    scene.EnableLightPrepass = true
  else
    scene.EnableLightPrepass = false
  end
  return true
end
function create_pssm_uiparam(scene)
  local pssm_uiparam = nx_call("util_gui", "get_global_arraylist", "pssm_uiparam")
  pssm_uiparam.pssm_enable = false
  pssm_uiparam.prelight_enable = false
  pssm_uiparam.filter_mode = "PCF"
  pssm_uiparam.filter_level = 1
  pssm_uiparam.depth_slope0 = 5.0E-5
  pssm_uiparam.depth_slope1 = 1.0E-4
  pssm_uiparam.depth_slope2 = 1.5E-4
  pssm_uiparam.depth_slope3 = 2.0E-4
  pssm_uiparam.depth_bias0 = 2.0E-4
  pssm_uiparam.depth_bias1 = 4.0E-4
  pssm_uiparam.depth_bias2 = 8.0E-4
  pssm_uiparam.depth_bias3 = 0.0016
  pssm_uiparam.shadow_inten = 1
  pssm_uiparam.shadow_map_count = 4
  pssm_uiparam.shadow_map_size = 1024
  pssm_uiparam.camera_distance = 150
  pssm_uiparam.shadow_distance = 100
  pssm_uiparam.log_split_weight = 0.75
  pssm_uiparam.vsm_low_limit = 0.1
  pssm_uiparam.scattering_intensity = 1
  pssm_uiparam.scattering_color = "0,0,0,0"
  scene.pssm_uiparam = pssm_uiparam
  return pssm_uiparam
end
function load_pssm_ini(scene, filename)
  local pssm_uiparam = scene.pssm_uiparam
  if not nx_is_valid(pssm_uiparam) then
    pssm_uiparam = create_pssm_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  pssm_uiparam.filter_mode = ini:ReadString("pssm", "FilterMode", pssm_uiparam.filter_mode)
  pssm_uiparam.filter_level = ini:ReadInteger("pssm", "FilterLevel", pssm_uiparam.filter_level)
  pssm_uiparam.depth_slope0 = ini:ReadFloat("pssm", "DepthSlope0", pssm_uiparam.depth_slope0)
  pssm_uiparam.depth_slope1 = ini:ReadFloat("pssm", "DepthSlope1", pssm_uiparam.depth_slope1)
  pssm_uiparam.depth_slope2 = ini:ReadFloat("pssm", "DepthSlope2", pssm_uiparam.depth_slope2)
  pssm_uiparam.depth_slope3 = ini:ReadFloat("pssm", "DepthSlope3", pssm_uiparam.depth_slope3)
  pssm_uiparam.depth_bias0 = ini:ReadFloat("pssm", "DepthBias0", pssm_uiparam.depth_bias0)
  pssm_uiparam.depth_bias1 = ini:ReadFloat("pssm", "DepthBias1", pssm_uiparam.depth_bias1)
  pssm_uiparam.depth_bias2 = ini:ReadFloat("pssm", "DepthBias2", pssm_uiparam.depth_bias2)
  pssm_uiparam.depth_bias3 = ini:ReadFloat("pssm", "DepthBias3", pssm_uiparam.depth_bias3)
  pssm_uiparam.shadow_inten = ini:ReadFloat("pssm", "ShadowInten", pssm_uiparam.shadow_inten)
  pssm_uiparam.shadow_map_count = ini:ReadInteger("pssm", "ShadowMapCount", pssm_uiparam.shadow_map_count)
  pssm_uiparam.shadow_map_size = ini:ReadInteger("pssm", "ShadowMapSize", pssm_uiparam.shadow_map_size)
  pssm_uiparam.camera_distance = ini:ReadFloat("pssm", "CameraDistance", pssm_uiparam.camera_distance)
  pssm_uiparam.shadow_distance = ini:ReadFloat("pssm", "ShadowDistance", pssm_uiparam.shadow_distance)
  pssm_uiparam.log_split_weight = ini:ReadFloat("pssm", "LogSplitWeight", pssm_uiparam.log_split_weight)
  pssm_uiparam.vsm_low_limit = ini:ReadFloat("pssm", "VSMLowLimit", pssm_uiparam.vsm_low_limit)
  pssm_uiparam.scattering_intensity = ini:ReadFloat("pssm", "ScatteringIntensity", pssm_uiparam.scattering_intensity)
  pssm_uiparam.scattering_color = ini:ReadString("pssm", "ScatteringColor", pssm_uiparam.scattering_color)
  nx_destroy(ini)
  return true
end
