function delete_hbao(scene)
  local hbao = scene.hbao
  if nx_is_valid(hbao) then
    scene:RemoveObject(hbao)
    scene:Delete(hbao)
  end
  return true
end
function change_hbao(scene)
  local hbao_uiparam = scene.hbao_uiparam
  if not nx_is_valid(hbao_uiparam) then
    hbao_uiparam = create_hbao_uiparam(scene)
  end
  if hbao_uiparam.enable then
    local hbao = scene.hbao
    if not nx_is_valid(hbao) then
      hbao = scene:Create("HBAO")
      scene.hbao = hbao
      scene:AddObject(hbao, 201)
    end
    hbao.AoHalfResolution = hbao_uiparam.ao_half_resolution
    hbao.AoQualityLevel = hbao_uiparam.ao_quality_level
    hbao.AoNumOfDirection = hbao_uiparam.ao_num_of_direction
    hbao.AoNumOfStep = hbao_uiparam.ao_num_of_step
    hbao.AoRadius = hbao_uiparam.ao_radius
    hbao.AoAngleBias = hbao_uiparam.ao_angle_bias
    hbao.AoAttenuation = hbao_uiparam.ao_attenuation
    hbao.AoContrast = hbao_uiparam.ao_contrast
    hbao.AoDistance = hbao_uiparam.ao_distance
    hbao.AoBlurSize = hbao_uiparam.ao_blur_size
    hbao.AoBlurSharpness = hbao_uiparam.ao_blur_sharpness
  elseif nx_find_custom(scene, "hbao") and nx_is_valid(nx_custom(scene, "hbao")) then
    delete_hbao(scene)
  end
  return true
end
function create_hbao_uiparam(scene)
  local hbao_uiparam = nx_call("util_gui", "get_global_arraylist", "hbao_uiparam")
  hbao_uiparam.enable = false
  hbao_uiparam.ao_half_resolution = true
  hbao_uiparam.ao_quality_level = 2
  hbao_uiparam.ao_num_of_direction = 8
  hbao_uiparam.ao_num_of_step = 8
  hbao_uiparam.ao_radius = 1
  hbao_uiparam.ao_angle_bias = 20
  hbao_uiparam.ao_attenuation = 1
  hbao_uiparam.ao_contrast = 1.25
  hbao_uiparam.ao_distance = 100
  hbao_uiparam.ao_blur_size = 7
  hbao_uiparam.ao_blur_sharpness = 16
  scene.hbao_uiparam = hbao_uiparam
  return hbao_uiparam
end
function load_hbao_ini(scene, filename)
  if not nx_find_custom(scene, "hbao_uiparam") or not nx_is_valid(nx_custom(scene, "hbao_uiparam")) then
    create_hbao_uiparam(scene)
  end
  local hbao_uiparam = scene.hbao_uiparam
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  hbao_uiparam.ao_half_resolution = nx_boolean(ini:ReadString("hbao", "AoHalfResolution", "false"))
  hbao_uiparam.ao_quality_level = ini:ReadInteger("hbao", "AoQualityLevel", 2)
  hbao_uiparam.ao_num_of_direction = ini:ReadInteger("hbao", "AoNumOfDirection", 8)
  hbao_uiparam.ao_num_of_step = ini:ReadInteger("hbao", "AoNumOfStep", 8)
  hbao_uiparam.ao_radius = ini:ReadFloat("hbao", "AoRadius", 1)
  hbao_uiparam.ao_angle_bias = ini:ReadFloat("hbao", "AoAngleBias", 1)
  hbao_uiparam.ao_attenuation = ini:ReadFloat("hbao", "AoAttenuation", 1)
  hbao_uiparam.ao_contrast = ini:ReadFloat("hbao", "AoContrast", 1.25)
  hbao_uiparam.ao_distance = ini:ReadFloat("hbao", "AoDistance", 100)
  hbao_uiparam.ao_blur_size = ini:ReadFloat("hbao", "AoBlurSize", 7)
  hbao_uiparam.ao_blur_sharpness = ini:ReadFloat("hbao", "AoBlurSharpness", 16)
  nx_destroy(ini)
  return true
end
