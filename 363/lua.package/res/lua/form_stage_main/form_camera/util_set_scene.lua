function restore_scene_param()
  local world = nx_value("world")
  local scene = world.MainScene
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    nx_msgbox("not nx_is_valid(client_scene)")
    return false
  end
  local scene_res_name = client_scene:QueryProp("Resource")
  local terrain_dir = "map\\ter\\" .. scene_res_name .. "\\"
  nx_call("terrain\\filter", "load_ppfilter_ini", scene, nx_resource_path() .. terrain_dir .. "ppfilter.ini")
  nx_call("terrain\\hdr", "load_pphdr_ini", scene, nx_resource_path() .. terrain_dir .. "pphdr.ini")
  local old_enable = scene.ppfilter_uiparam.enable
  scene.ppfilter_uiparam.enable = true
  nx_call("terrain\\filter", "change_ppfilter", scene)
  nx_call("terrain\\hdr", "change_pphdr", scene)
  scene.ppfilter_uiparam.enable = old_enable
  nx_call("terrain\\weather", "load_weather_ini", scene, nx_resource_path() .. terrain_dir .. "weather.ini")
  nx_call("terrain\\weather", "load_shadow_ini", scene, nx_resource_path() .. terrain_dir .. "shadow.ini")
  nx_call("terrain\\weather", "change_weather", scene)
  nx_call("terrain\\role_param", "load_role_ini", scene, nx_resource_path() .. terrain_dir .. "role.ini")
  nx_call("terrain\\role_param", "change_role_param", scene)
end
function change_scene_param(filepath)
  local world = nx_value("world")
  local scene = world.MainScene
  nx_call("terrain\\filter", "load_ppfilter_ini", scene, filepath)
  nx_call("terrain\\hdr", "load_pphdr_ini", scene, filepath)
  local old_enable = scene.ppfilter_uiparam.enable
  scene.ppfilter_uiparam.enable = true
  nx_call("terrain\\filter", "change_ppfilter", scene)
  nx_call("terrain\\hdr", "change_pphdr", scene)
  scene.ppfilter_uiparam.enable = old_enable
  nx_call("terrain\\weather", "load_weather_ini", scene, filepath)
  nx_call("terrain\\weather", "load_shadow_ini", scene, filepath)
  nx_call("terrain\\weather", "change_weather", scene)
  nx_call("terrain\\role_param", "load_role_ini", scene, filepath)
  nx_call("terrain\\role_param", "change_role_param", scene)
end
