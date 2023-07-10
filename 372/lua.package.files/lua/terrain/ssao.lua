function delete_ssao(scene)
  local ssao = scene.ssao
  if nx_is_valid(ssao) then
    scene:RemoveObject(ssao)
    scene:Delete(ssao)
  end
  return true
end
function change_ssao(scene)
  local ssao_uiparam = scene.ssao_uiparam
  if not nx_is_valid(ssao_uiparam) then
    ssao_uiparam = create_ssao_uiparam(scene)
  end
  if ssao_uiparam.enable then
    local ssao = scene.ssao
    if not nx_is_valid(ssao) then
      ssao = scene:Create("SSAO")
      scene.ssao = ssao
      scene:AddObject(ssao, 201)
    end
    if ssao_uiparam.ao_half_resolution then
      scene.EnableRealizeHalfDepth = true
    end
    ssao.AoHalfResolution = ssao_uiparam.ao_half_resolution
    ssao.AoQualityLevel = ssao_uiparam.ao_quality_level
    ssao.AoRadius = ssao_uiparam.ao_radius
    ssao.AoDepthScale = ssao_uiparam.ao_depth_scale
    ssao.AoLowLimit = ssao_uiparam.ao_low_limit
    ssao.AoContrast = ssao_uiparam.ao_contrast
    ssao.AoBlurSharpness = ssao_uiparam.ao_blur_sharpness
  else
    delete_ssao(scene)
  end
  return true
end
function create_ssao_uiparam(scene)
  local ssao_uiparam = nx_call("util_gui", "get_global_arraylist", "ssao_uiparam")
  ssao_uiparam.enable = false
  ssao_uiparam.ao_half_resolution = false
  ssao_uiparam.ao_quality_level = 1
  ssao_uiparam.ao_radius = 1
  ssao_uiparam.ao_depth_scale = 1
  ssao_uiparam.ao_low_limit = 0.075
  ssao_uiparam.ao_contrast = 1.25
  ssao_uiparam.ao_blur_sharpness = 2
  scene.ssao_uiparam = ssao_uiparam
  return ssao_uiparam
end
function load_ssao_ini(scene, filename)
  local ssao_uiparam = scene.ssao_uiparam
  if not nx_is_valid(ssao_uiparam) then
    ssao_uiparam = create_ssao_uiparam(scene)
  end
  return true
end
