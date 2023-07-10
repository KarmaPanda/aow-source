require("util_functions")
local weather_tab = {
  [1] = "weather1.ini",
  [2] = "weather2.ini",
  [3] = "weather3.ini"
}
local effect_data_tab = {
  [1] = "ini\\particles_mdl.ini,P_flower05a",
  [2] = "dongku_shanguang",
  [3] = "tianqi_yushui",
  [4] = "P_flower05a"
}
local backup_camera_params = function(camera)
  camera.old_x = camera.PositionX
  camera.old_y = camera.PositionY
  camera.old_z = camera.PositionZ
  camera.old_ax = camera.AngleX
  camera.old_ay = camera.AngleY
  camera.old_az = camera.AngleZ
end
local gen_unique_name = function()
  return nx_function("ext_gen_unique_name")
end
local add_append_path = function(value)
  local world = nx_value("world")
  local new_value = "map\\" .. value
  return new_value
end
local function put_effectmodel(scene, terrain, camera, name, effectmodel_config, effectmodel_name, x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, tag)
  effectmodel_config = add_append_path(effectmodel_config)
  local effectmodel = scene:Create("EffectModel")
  if not nx_is_valid(effectmodel) then
    return nx_null()
  end
  effectmodel.AsyncLoad = true
  effectmodel:SetPosition(x, y, z)
  effectmodel:SetAngle(angle_x, angle_y, angle_z)
  effectmodel:SetScale(scale_x, scale_y, scale_z)
  if not effectmodel:CreateFromIniEx(effectmodel_config, effectmodel_name, false, "map\\") then
    nx_log("create effectmodel from ini file failed")
    nx_log("create " .. effectmodel_config)
    nx_log("create " .. effectmodel_name)
    return nx_null()
  end
  while not effectmodel.LoadFinish do
    nx_log("effectmodel.LoadFinish")
    nx_pause(0)
  end
  effectmodel.name = name
  effectmodel.config = effectmodel_config
  effectmodel.effectmodel_config = effectmodel_config
  effectmodel.effectmodel_name = effectmodel_name
  effectmodel.clip_radius = 0
  effectmodel.WaterReflect = false
  effectmodel.tag = tag
  return effectmodel
end
local util_add_model_to_scene = function(scene, model)
  if not nx_is_valid(model) then
    return false
  end
  if not nx_is_valid(scene) then
    return false
  end
  while not model.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(scene) or not nx_is_valid(model) then
      return false
    end
  end
  model:SetPosition(0, 0, 0)
  model:SetAngle(0, math.pi, 0)
  local radius = 1.5
  if radius < 1 then
    radius = 1
  end
  if 50 < radius then
    radius = 50
  end
  scene:AddObject(model, 20)
  local radius = 1.5
  if radius < 1 then
    radius = 1
  end
  if 50 < radius then
    radius = 50
  end
  scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
  scene.camera:SetAngle(0, 0, 0)
  scene.model = model
  scene.ClearZBuffer = true
  return true
end
function show_snow(scene, terrain, camera)
  backup_camera_params(camera)
  local weather_model = nx_null()
  if nx_find_custom(scene, "weather_model") then
    weather_model = scene.weather_model
  end
  if not nx_is_valid(weather_model) then
    local name = gen_unique_name()
    local effectmodel_list = util_split_string(effect_data_tab[1], ",")
    local effectmodel_config = effectmodel_list[1]
    local effectmodel_name = effectmodel_list[2]
    local pos_x, pos_y, pos_z = camera.PositionX, camera.PositionY, camera.PositionZ
    local angle_x, angle_y, angle_z = 0, 0, 0
    local scale_x, scale_y, scale_z = 1, 1, 1
    local tag = 0
    local effectmodel = put_effectmodel(scene, terrain, camera, name, effectmodel_config, effectmodel_name, pos_x, pos_y, pos_z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, tag)
    scene.weather_model = effectmodel
    if not nx_is_valid(effectmodel) then
      return
    end
    util_add_model_to_scene(scene, effectmodel)
    local helper_list = effectmodel:GetHelperNameList()
    effectmodel:AddParticle(effect_data_tab[4], helper_list[1], -1, -1)
  end
end
