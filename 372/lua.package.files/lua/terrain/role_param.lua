function create_role_param(scene)
  local role_param = nx_call("util_gui", "get_global_arraylist", "role_param")
  role_param.enable_camera_light = false
  role_param.camera_light_color = "255,128,128,128"
  role_param.enable_role_falloff = false
  role_param.role_falloff_color = "255,255,255,255"
  role_param.role_falloff_inten = 0.5
  role_param.role_falloff_power = 4
  role_param.role_diffuse_factor = 1
  role_param.role_ambient_factor = 1
  role_param.role_specular_factor = 1
  scene.role_param = role_param
  return role_param
end
function change_role_param(scene)
  local role_param = scene.role_param
  if not nx_is_valid(role_param) then
    return false
  end
  scene.EnableCameraLight = role_param.enable_camera_light
  scene.CameraLightColor = role_param.camera_light_color
  scene.EnableRoleFallOff = role_param.enable_role_falloff
  scene.RoleFallOffColor = role_param.role_falloff_color
  scene.RoleFallOffInten = role_param.role_falloff_inten
  scene.RoleFallOffPower = role_param.role_falloff_power
  scene.RoleDiffuseFactor = role_param.role_diffuse_factor
  scene.RoleAmbientFactor = role_param.role_ambient_factor
  scene.RoleSpecularFactor = role_param.role_specular_factor
  return true
end
function load_role_ini(scene, filename)
  local role_param = scene.role_param
  if not nx_is_valid(role_param) then
    role_param = create_role_param(scene)
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  role_param.enable_camera_light = nx_boolean(ini:ReadString("role_param", "EnableCameraLight", "false"))
  role_param.camera_light_color = ini:ReadString("role_param", "CameraLightColor", role_param.camera_light_color)
  role_param.enable_role_falloff = nx_boolean(ini:ReadString("role_param", "EnableRoleFallOff", "false"))
  role_param.role_falloff_color = ini:ReadString("role_param", "RoleFallOffColor", role_param.role_falloff_color)
  role_param.role_falloff_inten = ini:ReadFloat("role_param", "RoleFallOffInten", role_param.role_falloff_inten)
  role_param.role_falloff_power = ini:ReadFloat("role_param", "RoleFallOffPower", role_param.role_falloff_power)
  role_param.role_diffuse_factor = ini:ReadFloat("role_param", "RoleDiffuseFactor", role_param.role_diffuse_factor)
  role_param.role_ambient_factor = ini:ReadFloat("role_param", "RoleAmbientFactor", role_param.role_ambient_factor)
  role_param.role_specular_factor = ini:ReadFloat("role_param", "RoleSpecularFactor", role_param.role_specular_factor)
  nx_destroy(ini)
  return true
end
