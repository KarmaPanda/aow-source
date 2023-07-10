function change_pphdr(scene)
  local pphdr_uiparam = scene.pphdr_uiparam
  if not nx_is_valid(pphdr_uiparam) then
    pphdr_uiparam = create_pphdr_uiparam(scene)
  end
  if pphdr_uiparam.hdr_enable or pphdr_uiparam.bloom_enable then
    local pphdr = get_pphdr(scene)
    if not nx_is_valid(pphdr) then
      return false
    end
    if pphdr_uiparam.hdr_enable then
      scene.EnableHDR = true
    end
    scene.EnableHDR = pphdr_uiparam.hdr_enable
    pphdr.HDREnable = pphdr_uiparam.hdr_enable
    pphdr.HDRExposure = pphdr_uiparam.hdr_exposure
    pphdr.HDRGaussianScale = pphdr_uiparam.hdr_gaussianscale
    pphdr.HDRExposureAdd = pphdr_uiparam.hdr_exposureadd
    pphdr.BloomEnable = pphdr_uiparam.bloom_enable
    pphdr.MaxBrightness = pphdr_uiparam.bloom_brightness
    pphdr.GlowWeight = pphdr_uiparam.bloom_glowweight
    pphdr.Dither = pphdr_uiparam.bloom_dither
    pphdr.Gamma = pphdr_uiparam.bloom_gamma
  else
    scene.EnableHDR = false
    del_pphdr(scene)
  end
  return true
end
function load_pphdr_ini(scene, filename)
  local pphdr_uiparam = scene.pphdr_uiparam
  if not nx_is_valid(pphdr_uiparam) then
    pphdr_uiparam = create_pphdr_uiparam(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  pphdr_uiparam.bloom_brightness = ini:ReadFloat("pphdr", "MaxBrightness", pphdr_uiparam.bloom_brightness)
  pphdr_uiparam.bloom_glowweight = ini:ReadFloat("pphdr", "GlowWeight", pphdr_uiparam.bloom_glowweight)
  pphdr_uiparam.bloom_dither = ini:ReadFloat("pphdr", "Dither", pphdr_uiparam.bloom_dither)
  pphdr_uiparam.bloom_gamma = ini:ReadFloat("pphdr", "Gamma", pphdr_uiparam.bloom_gamma)
  pphdr_uiparam.hdr_exposure = ini:ReadFloat("pphdr", "HDRExposure", pphdr_uiparam.hdr_exposure)
  pphdr_uiparam.hdr_gaussianscale = ini:ReadFloat("pphdr", "HDRGaussianScale", pphdr_uiparam.hdr_gaussianscale)
  pphdr_uiparam.hdr_exposureadd = ini:ReadFloat("pphdr", "HDRExposureAdd", pphdr_uiparam.hdr_exposureadd)
  nx_destroy(ini)
  return true
end
function create_pphdr_uiparam(scene)
  local pphdr_uiparam = nx_call("util_gui", "get_global_arraylist", "pphdr_uiparam")
  pphdr_uiparam.bloom_enable = false
  pphdr_uiparam.bloom_brightness = 0.5
  pphdr_uiparam.bloom_glowweight = 0.38
  pphdr_uiparam.bloom_dither = 0.0025
  pphdr_uiparam.bloom_gamma = 1.5
  pphdr_uiparam.hdr_enable = false
  pphdr_uiparam.hdr_exposure = 5
  pphdr_uiparam.hdr_gaussianscale = 20
  pphdr_uiparam.hdr_exposureadd = 0.1
  scene.pphdr_uiparam = pphdr_uiparam
  return pphdr_uiparam
end
function delete_pphdr_force(scene)
  local pphdr = scene.pphdr
  if not nx_is_valid(pphdr) then
    return false
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    return false
  end
  postprocess_man:UnregistPostProcess(pphdr)
  scene:Delete(pphdr)
  return true
end
function del_pphdr(scene)
  local pphdr = scene.pphdr
  if not nx_is_valid(pphdr) then
    return false
  end
  local pphdr_uiparam = scene.pphdr_uiparam
  if not nx_is_valid(pphdr_uiparam) then
    return false
  end
  if not pphdr_uiparam.hdr_enable then
    delete_pphdr_force(scene)
    return true
  end
  return false
end
function get_pphdr(scene)
  local pphdr = scene.pphdr
  if nx_is_valid(pphdr) then
    return pphdr
  end
  local pphdr_uiparam = scene.pphdr_uiparam
  if not nx_is_valid(pphdr_uiparam) then
    return nx_null()
  end
  if not pphdr_uiparam.hdr_enable and not pphdr_uiparam.bloom_enable then
    return nx_null()
  end
  pphdr = scene:Create("PPHDR")
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    scene:Delete(pphdr)
    return nx_null()
  end
  postprocess_man:RegistPostProcess(pphdr)
  scene.pphdr = pphdr
  return pphdr
end
