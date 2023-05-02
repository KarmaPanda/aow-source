require("const_define")
require("define\\object_type_define")
require("define\\gamehand_type")
require("util_functions")
require("utils")
require("share\\view_define")
local table_effect_file = {
  "ini\\effect\\model.ini"
}
EFFECT_MODEL_FILE = "ini\\effect\\model.ini"
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function game_effect_init(game_effect, scene)
  game_effect.EffectFinderDir = nx_resource_path() .. "ini\\effect\\effectfinder\\"
  game_effect:ReLoadEffectFinder()
  game_effect.EffectContentDir = nx_resource_path() .. "ini\\effect\\effectcontent\\"
  game_effect.SaberArcFile = "ini\\effect\\effectcontent\\weapon_trail.ini"
  game_effect.GameClient = nx_value("game_client")
  set_scene(game_effect, scene)
end
function show_visual_object_effect(visual_object)
  if not nx_is_valid(visual_object) then
    return
  end
  local scene = visual_object.scene
  local game_effect = scene.game_effect
  visual_object.b_show_effect = true
  game_effect:ShowPlayerEffect(visual_object)
end
function hide_visual_object_effect(visual_object)
  if not nx_is_valid(visual_object) then
    return
  end
  local scene = visual_object.scene
  local game_effect = scene.game_effect
  visual_object.b_show_effect = false
  game_effect:HidePlayerEffect(visual_object)
end
function set_scene(game_effect, scene)
  if nx_is_valid(game_effect) and scene ~= nil and nx_is_valid(scene) then
    game_effect.Scene = scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      game_effect.Terrain = scene.terrain
    end
    if nx_find_custom(scene, "saberarc_man") then
      game_effect.SaberArcManager = game_effect.Scene.saberarc_man
    end
  end
end
function set_terrain(game_effect, terrain)
  if nx_is_valid(game_effect) and scene ~= nil and nx_is_valid(terrain) then
    game_effect.Terrain = terrain
  end
end
function get_actor_role(role)
  local game_visual = nx_value("game_visual")
  local role_type = game_visual:QueryRoleType(role)
  if role_type == TYPE_PLAYER then
    local actor_role = role:GetLinkObject("actor_role")
    if not nx_is_valid(actor_role) then
      actor_role = role
    else
    end
    return actor_role
  end
  return role
end
function create_effect(effect_name, self_model, target_model, user_flag, client_ident, action_name, target_client_ident)
  if is_super_simple_config() then
    return true
  end
  if (self_model == nil or not nx_is_valid(self_model)) and (target_model == nil or not nx_is_valid(target_model)) then
    return false
  end
  if (self_model == nil or not nx_is_valid(self_model)) and nx_is_valid(target_model) then
    self_model = target_model
  end
  if (target_model == nil or not nx_is_valid(target_model)) and nx_is_valid(self_model) then
    target_model = self_model
  end
  if target_model == nil then
    target_model = self_model
  elseif self_model == nil then
    self_model = target_model
  end
  local scene = self_model.scene
  if not nx_is_valid(scene) then
    return false
  end
  if user_flag == nil then
    user_flag = ""
  end
  local game_effect = scene.game_effect
  if client_ident ~= nil and string.len(client_ident) > 0 and string.find(effect_name, "con:") ~= nil then
    local key_name = string.sub(effect_name, 5, string.len(effect_name))
    local new_effect_name, point = game_effect:FindEffect(key_name, client_ident)
    effect_name = new_effect_name
  end
  if effect_name == nil then
    return false
  end
  if not nx_is_valid(game_effect.Scene) then
    game_effect.Scene = scene
  end
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  local result
  if nx_is_valid(self_model) then
    local self_actor_role = get_actor_role(self_model)
    local target_actor_role = get_actor_role(target_model)
    if action_name == nil then
      action_name = ""
    end
    local game_visual = nx_value("game_visual")
    local game_client = nx_value("game_client")
    local visual_object = game_visual:GetSceneObj(nx_string(client_ident))
    if effect_name == nil or effect_name == "nil" then
      return false
    end
    if client_ident == nil then
      client_ident = ""
    end
    if target_client_ident == nil then
      target_client_ident = ""
    end
    if nx_is_valid(visual_object) then
      result = game_effect:CreateEffect(effect_name, self_actor_role, target_actor_role, user_flag, action_name, client_ident, target_client_ident, visual_object, visual_object.b_show_effect)
    else
      result = game_effect:CreateEffect(effect_name, self_actor_role, target_actor_role, user_flag, action_name, client_ident, target_client_ident, "", true)
    end
  end
  return result
end
function alpha_effect(effect_name, self_model, target_model, num)
  if (self_model == nil or not nx_is_valid(self_model)) and (target_model == nil or not nx_is_valid(target_model)) then
    return false
  end
  if num < 0 then
    num = 0
  elseif 255 < num then
    num = 255
  end
  if (self_model == nil or not nx_is_valid(self_model)) and nx_is_valid(target_model) then
    self_model = target_model
  end
  if (target_model == nil or not nx_is_valid(target_model)) and nx_is_valid(self_model) then
    target_model = self_model
  end
  if target_model == nil then
    target_model = self_model
  elseif self_model == nil then
    self_model = target_model
  end
  if not nx_find_custom(self_model, "scene") then
    return
  end
  local scene = self_model.scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "game_effect") or not nx_is_valid(scene.game_effect) then
    return
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  if nx_is_valid(self_model) then
    if nx_is_valid(target_model) then
    end
    local self_actor_role = get_actor_role(self_model)
    local target_actor_role = get_actor_role(target_model)
    local result = game_effect:SetEffectAlpha(effect_name, num, self_actor_role, target_actor_role)
  end
end
function remove_effect(effect_name, self_model, target_model)
  if (self_model == nil or not nx_is_valid(self_model)) and (target_model == nil or not nx_is_valid(target_model)) then
    return false
  end
  if (self_model == nil or not nx_is_valid(self_model)) and nx_is_valid(target_model) then
    self_model = target_model
  end
  if (target_model == nil or not nx_is_valid(target_model)) and nx_is_valid(self_model) then
    target_model = self_model
  end
  if target_model == nil then
    target_model = self_model
  elseif self_model == nil then
    self_model = target_model
  end
  if not nx_find_custom(self_model, "scene") then
    return
  end
  local scene = self_model.scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "game_effect") or not nx_is_valid(scene.game_effect) then
    return
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  if nx_is_valid(self_model) then
    if nx_is_valid(target_model) then
    end
    local self_actor_role = get_actor_role(self_model)
    local target_actor_role = get_actor_role(target_model)
    local result = game_effect:RemoveEffect(effect_name, self_actor_role, target_actor_role)
  end
end
function remove_same_effect(effect_name, self_model, target_model)
  if self_model == nil and target_model == nil then
    return
  end
  if self_model == nil and nx_is_valid(target_model) then
    self_model = target_model
  end
  if target_model == nil and nx_is_valid(self_model) then
    target_model = self_model
  end
  local scene = self_model.scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "game_effect") or not nx_is_valid(scene.game_effect) then
    return
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  if nx_is_valid(self_model) then
    if nx_is_valid(target_model) then
    end
    local self_actor_role = get_actor_role(self_model)
    local target_actor_role = get_actor_role(target_model)
    local result = game_effect:RemoveSameEffects(effect_name, self_actor_role, target_actor_role)
  end
end
function remove_effect_by_user_flag(user_flag, self_model, target_model)
  local scene = self_model.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  local result = game_effect:RemoveEffectByUserFlag(user_flag, self_model, target_model)
  return result
end
function create_saberarc(scene, saberarc_name, weapon_model)
  if not nx_is_valid(scene) then
    return
  end
  local game_effect = scene.game_effect
  return game_effect:CreateSaberSrc(saberarc_name, weapon_model)
end
function delete_saberarc(scene, saberarc_id)
  if not nx_is_valid(scene) then
    return
  end
  local game_effect = scene.game_effect
  return game_effect:DeleteSaberSrc(saberarc_id)
end
function create_swim_effect(terrain, role)
  local swim_effect_move = nx_value("swim_effect_move")
  if swim_effect_move ~= nil and swim_effect_move then
    return true
  end
  create_effect("swim_move", role, role, "swim_effect_move", nil, nil)
  nx_set_value("swim_effect_move", true)
end
function remove_swim_effect(terrain, role)
  local swim_effect_move = nx_value("swim_effect_move")
  if swim_effect_move ~= nil and swim_effect_move then
    local actor_role = get_actor_role(role)
    local result = remove_effect_by_user_flag("swim_effect_move", actor_role, actor_role)
    if result then
      nx_set_value("swim_effect_move", false)
    end
  end
end
function create_brokenshadow(role)
  role.BrokenShadow = true
  local actor2 = get_actor_role(role)
  actor2.BrokenShadow = true
end
function remove_brokenshadow(role)
  role.BrokenShadow = false
  local actor2 = get_actor_role(role)
  actor2.BrokenShadow = false
end
function create_motion_blur(scene)
  local motion_blur = nx_value("motion_blur")
  if nx_is_valid(motion_blur) then
    motion_blur.Visible = true
    return motion_blur
  end
  scene.EnableRealizeVelocity = true
  motion_blur = nx_create("PPMotionBlur")
  motion_blur.DynamicBlur = true
  motion_blur.StaticBlur = true
  motion_blur.NumSamples = 8
  motion_blur.MaxVelocity = 4
  motion_blur.VelocityScale = 0.01
  motion_blur:Load()
  scene.postprocess_man:RegistPostProcess(motion_blur)
  motion_blur.Visible = true
  nx_set_value("motion_blur", motion_blur)
  return motion_blur
end
function remove_motion_blur(scene)
  if nx_find_value("motion_blur") then
    local motion_blur = nx_value("motion_blur")
    if nx_is_valid(motion_blur) then
      scene.postprocess_man:UnregistPostProcess(motion_blur)
      nx_destroy(motion_blur)
    end
  end
end
function create_ppblast(scene)
  local PPBlast = nx_value("PPBlast")
  if nx_is_valid(PPBlast) then
    PPBlast.Visible = true
    return PPBlast
  end
  PPBlast = nx_create("PPBlast")
  if not nx_is_valid(PPBlast) then
    return
  end
  PPBlast.Intensity = 0.0015
  PPBlast.LifeTime = 0.2
  PPBlast.BlastColor = "255,255,255,255"
  local game_config = nx_value("game_config")
  if game_config.effect_quality < 2 then
    PPBlast.MaxLoop = 0
  end
  scene.postprocess_man:RegistPostProcess(PPBlast)
  PPBlast.Visible = true
  nx_set_value("PPBlast", PPBlast)
  return PPBlast
end
function remove_ppblast(scene)
  if nx_find_value("PPBlast") then
    local PPBlast = nx_value("PPBlast")
    if nx_is_valid(PPBlast) then
      scene.postprocess_man:UnregistPostProcess(PPBlast)
      nx_destroy(PPBlast)
    end
  end
end
function create_ppdizzy(scene)
  local PPDizzy = nx_value("PPDizzy")
  if nx_is_valid(PPDizzy) then
    PPDizzy.Visible = true
    return PPDizzy
  end
  PPDizzy = nx_create("PPDizzy")
  scene.postprocess_man:RegistPostProcess(PPDizzy)
  PPDizzy.Visible = true
  nx_set_value("PPDizzy", PPDizzy)
  return PPDizzy
end
function remove_ppdizzy(scene)
  if nx_find_value("PPDizzy") then
    local PPDizzy = nx_value("PPDizzy")
    if nx_is_valid(PPDizzy) then
      scene.postprocess_man:UnregistPostProcess(PPDizzy)
      nx_destroy(PPDizzy)
    end
  end
end
function update_ppdizzy(role)
  if not nx_is_valid(role) then
    return
  end
  if nx_find_value("PPDizzy") then
    local PPDizzy = nx_value("PPDizzy")
    if not nx_find_custom(role, "pp_rradius") then
      return
    end
    if nx_is_valid(PPDizzy) then
      local delat = (nx_function("ext_get_tickcount") - role.pp_begintime) / 1000
      local ratio = math.sin(delat)
      local new_value = role.pp_rradius * role.preDrunkState
      PPDizzy.RotationalRadius = new_value * ratio * ratio * ratio
      PPDizzy.RotationalSpeed = role.pp_rspeed * role.preDrunkState
      new_value = role.pp_dinten * role.preDrunkState * 0.5
      PPDizzy.DistortInten = PPDizzy.DistortInten + (new_value - PPDizzy.DistortInten) * 0.01
    end
  end
end
function update_ppblast(role)
  if not nx_is_valid(role) then
    return
  end
  if nx_find_value("PPBlast") then
    local PPBlast = nx_value("PPBlast")
    if nx_is_valid(PPBlast) then
      PPBlast:SetPosition(role.PositionX, role.PositionY + role.Radius, role.PositionZ)
      if not nx_find_custom(role, "ppblastfade") or not role.ppblastfade then
        local x = math.sin(role.move_angle) * 10
        local z = math.cos(role.move_angle) * 10
        PPBlast:SetSpeed(x, 0, z)
      else
        PPBlast:SetSpeed(0, 0, 0)
      end
    end
  end
end
EFFECT_MODEL_FILE = "ini\\effect\\model.ini"
function create_eff_model_in_scenebox(name, scenebox)
  if is_super_simple_config() then
    return nx_null()
  end
  local eff_model = create_eff_model(scenebox.Scene, name)
  scenebox.Scene:AddObject(eff_model, 20)
  return eff_model
end
function delete_eff_model_in_scenebox(eff_model, scenebox)
  scenebox.Scene:RemoveObject(eff_model)
  delete_eff_model(scenebox.Scene, eff_model)
end
function create_eff_model_in_mainscene(main_scene, name, x, y, z)
  if is_super_simple_config() then
    return nx_null()
  end
  if not nx_is_valid(main_scene) then
    return nx_null()
  end
  if not nx_find_custom(main_scene, "terrain") then
    return nx_null()
  end
  local eff_model = create_eff_model(main_scene, name)
  local terrain = main_scene.terrain
  terrain:AddVisual(name, eff_model)
  if x and y and z then
    terrain:RelocateVisual(eff_model, x, y, z)
  end
  return eff_model
end
function delete_eff_model_in_mainscene(main_scene, eff_model)
  if not nx_is_valid(main_scene) then
    return nx_null()
  end
  local terrain = main_scene.terrain
  terrain:RemoveVisual(eff_model)
  delete_eff_model(main_scene, eff_model)
end
function create_eff_model(scene, name)
  if is_super_simple_config() then
    return nx_null()
  end
  if not nx_is_valid(scene) then
    nx_msgbox("no find scene [game_effect:create_eff_model]")
    return nx_null()
  end
  local eff_model = scene:Create("EffectModel")
  if not nx_is_valid(eff_model) then
    nx_msgbox("faild Create EffectModel [game_effect:create_eff_model]")
    return nx_null()
  end
  EFFECT_MODEL_FILE = "ini\\effect\\model.ini"
  local bSuccess = eff_model:CreateFromIni(EFFECT_MODEL_FILE, name, true)
  if bSuccess then
    return eff_model
  else
    bSuccess = eff_model:CreateFromIni("ini\\effect\\weapon_effect.ini", name, true)
    bSuccess = bSuccess or eff_model:CreateFromIni("ini\\effect\\test.ini", name, true)
  end
  if bSuccess then
    return eff_model
  else
    scene:Delete(eff_model)
    return nx_null()
  end
end
function create_effect_model(scene, file_name, effect_name, asyncload)
  if is_super_simple_config() then
    return nx_null()
  end
  if asyncload == nil then
    asyncload = true
  end
  local eff_model = scene:Create("EffectModel")
  if not nx_is_valid(eff_model) then
    nx_msgbox("faild Create EffectModel [game_effect:create_eff_model]")
    return nx_null()
  end
  local bSuccess = eff_model:CreateFromIni(file_name, effect_name, asyncload)
  if bSuccess then
    return eff_model
  else
    scene:Delete(eff_model)
    return nx_null()
  end
end
function delete_eff_model(scene, eff_model)
  if not nx_is_valid(scene) then
    return false
  end
  scene:Delete(eff_model)
  return true
end
function bind_effect_to_gameomodel_pos(target_model, eff_model, offset_x, offset_y, offset_z, offset_anglex, offset_angley, offset_anglez, is_angle_follow)
  local scene = target_model.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect.Terrain) then
    local terrain = scene.terrain
    game_effect.Terrain = terrain
  end
  eff_model:SetAngle(target_model.AngleX + offset_anglex, target_model.AngleY + offset_angley, target_model.AngleZ + offset_anglez)
  game_effect:BindPosFollowEffect(target_model, eff_model, offset_x, offset_y, offset_z, is_angle_follow, offset_anglex, offset_angley, offset_anglez)
end
function create_nomove_effect_by_target(name, liftime, target, offset_x, offset_y, offset_z, offset_anglex, offset_angley, offset_anglez)
  if is_super_simple_config() then
    return nx_null()
  end
  local scene = target.scene
  local eff_model = create_eff_model_in_mainscene(scene, name)
  if nx_is_valid(eff_model) then
    eff_model.LifeTime = liftime
    local world = nx_value("world")
    local scene = world.MainScene
    local terrain = scene.terrain
    if nx_is_valid(terrain) then
      terrain:RelocateVisual(eff_model, target.PositionX + offset_x, target.PositionY + offset_y, target.PositionZ + offset_z)
    end
    eff_model:SetAngle(target.AngleX + offset_anglex, target.AngleY + offset_angley, target.AngleZ + offset_anglez)
  end
  return eff_model
end
function create_pos_follow_effect_by_target(name, lifetime, target, offset_x, offset_y, offset_z, offset_anglex, offset_angley, offset_anglez, is_angle_follow)
  if is_super_simple_config() then
    return nx_null()
  end
  local scene = target.scene
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local eff_model = create_nomove_effect_by_target(name, lifetime, target, offset_x, offset_y, offset_z, offset_anglex, offset_angley, offset_anglez)
  if nx_is_valid(eff_model) then
    bind_effect_to_gameomodel_pos(target, eff_model, offset_x, offset_y, offset_z, offset_anglex, offset_angley, offset_anglez, is_angle_follow)
  end
  return eff_model
end
function create_linktopoint_effect_by_target(name, lifetime, target, pointname, offset_x, offset_y, offset_z, offset_anglex, offset_angley, offset_anglez, offset_scalex, offset_scaley, offset_scalez)
  if is_super_simple_config() then
    return nx_null()
  end
  local scene = target.scene
  if not nx_is_valid(scene) then
    return nx_null()
  end
  if offset_scalex == nil or nx_number(offset_scalex) == 0 then
    offset_scalex = 1
    offset_scaley = 1
    offset_scalez = 1
  end
  local eff_model = create_eff_model(scene, name)
  if nx_is_valid(eff_model) then
    eff_model.LifeTime = lifetime
    local res = target:LinkToPoint(name, pointname, eff_model, false)
    target:SetLinkScale(name, offset_scalex, offset_scaley, offset_scalez)
    target:SetLinkAngle(name, offset_anglex, offset_angley, offset_anglez)
    target:SetLinkPosition(name, offset_x, offset_y, offset_z)
  else
  end
  return eff_model
end
function create_effect_by_pos(actor, effect, loop, x, z, height_string)
  if is_super_simple_config() then
    return nx_null()
  end
  local scene = actor.scene
  local effect_model = scene:Create("EffectModel")
  effect_model:CreateFromIni(EFFECT_MODEL_FILE, effect, false)
  if not nx_is_valid(effect_model) then
    scene:Delete(effect_model)
    return
  end
  effect_model.Loop = loop
  local terrain = scene.terrain
  local y = 0
  if nx_string(height_string) == "on_water" then
    y = terrain:GetWalkWaterHeight(x, z)
  elseif nx_string(height_string) == "on_groud" then
    y = terrain:GetWalkHeight(x, z)
  end
  terrain:AddVisual("", effect_model)
  terrain:RelocateVisual(effect_model, x, y, z)
  return effect_model
end
function create_light(scene, role, light_name, point)
  if not nx_is_valid(scene) then
    return nx_null()
  end
  if nx_find_custom(role, "light") and nx_is_valid(role.light) then
    return role.light
  end
  if not scene.EnableLightPrepass then
    scene.EnableLightPrepass = true
  end
  if not scene.EnableDynamicShadow then
    scene.EnableDynamicShadow = true
  end
  if not nx_find_custom(scene, "light_man") or not nx_is_valid(scene.light_man) then
    return nx_null()
  end
  local ini_manager = nx_value("IniManager")
  if not nx_is_valid(ini_manager) then
    return nx_null()
  end
  local ini = ini_manager:LoadIniToManager("ini\\effect\\light_effect.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("Can't Creat light! the file can't find! :" .. ini.FileName)
    nx_destroy(ini)
    return nx_null()
  end
  local light_man = scene.light_man
  local light = light_man:Create()
  light.Color = "255," .. ini:ReadString(nx_string(light_name), "color_r", "255") .. "," .. ini:ReadString(nx_string(light_name), "color_g", "255") .. "," .. ini:ReadString(nx_string(light_name), "color_b", "255")
  light.Range = ini:ReadFloat(nx_string(light_name), "range", 1)
  light.Attenu0 = ini:ReadFloat(nx_string(light_name), "att0", 0)
  light.Attenu1 = ini:ReadFloat(nx_string(light_name), "att1", 1)
  light.Attenu2 = ini:ReadFloat(nx_string(light_name), "att2", 0)
  light.Blink = ini:ReadFloat(nx_string(light_name), "blink", 0)
  light.BlinkPeriod = ini:ReadFloat(nx_string(light_name), "blinkPeriod", 0)
  light.BlinkTick = ini:ReadFloat(nx_string(light_name), "blinkTick", 0)
  light.Intensity = ini:ReadFloat(nx_string(light_name), "intensity", 1)
  light.name = light_name
  light:Load()
  light:SetPosition(0, 0, 0)
  scene.terrain:AddVisual("light", light)
  light:SetPosition(role.PositionX, role.PositionY + 2.5, role.PositionZ)
  role.light = light
  return light
end
function delete_light(scene, role)
  if not nx_is_valid(light) then
    return false
  end
  if not nx_is_valid(scene) then
    return false
  end
  if not nx_find_custom(scene, "light_man") or not nx_is_valid(scene.light_man) then
    return false
  end
  return scene.light_man:Delete(light)
end
function create_range_skill_effect(attacker_id, beattacker_id, skill_name)
  if is_super_simple_config() then
    return
  end
  local game_client = nx_value("game_client")
  local attacker_client = game_client:GetSceneObj(nx_string(attacker_id))
  if not nx_is_valid(attacker_client) then
    return
  end
  if nil == skill_name or "" == skill_name then
    return
  end
  local game_visual = nx_value("game_visual")
  local client_visual = game_visual:GetSceneObj(nx_string(attacker_id))
  local select_visual = game_visual:GetSceneObj(nx_string(beattacker_id))
  if not nx_is_valid(client_visual) or not nx_is_valid(select_visual) then
    return
  end
  local scene = nx_value("game_scene")
  local game_effect = scene.game_effect
  local effects = game_effect:FindEffectBySkillName(nx_string(skill_name))
  if effects ~= nil and 0 < table.getn(effects) then
    local role1 = nx_execute("custom_effect", "get_role_model", client_visual)
    local role2 = nx_execute("custom_effect", "get_role_model", select_visual)
    for _, effect_name in ipairs(effects) do
      create_effect(effect_name, role1, role2, "", "")
    end
  end
end
function create_skill_effect(client_scene_obj, skill_name)
  if is_super_simple_config() then
    return
  end
  if not nx_is_valid(client_scene_obj) then
    return
  end
  if nil == skill_name or "" == skill_name then
    return
  end
  local obj_type = client_scene_obj:QueryProp("Type")
  local select_target_ident
  if obj_type == TYPE_PLAYER then
    select_target_ident = client_scene_obj:QueryProp("CurSkillTarget")
  elseif obj_type == TYPE_NPC then
    select_target_ident = client_scene_obj:QueryProp("CurSkillTarget")
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_visual = game_visual:GetSceneObj(client_scene_obj.Ident)
  local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
  local select_visual
  if not nx_is_valid(select_target) then
    select_visual = client_visual
  else
    select_visual = game_visual:GetSceneObj(select_target.Ident)
  end
  local scene = nx_value("game_scene")
  local game_effect = scene.game_effect
  local effects = game_effect:FindEffectBySkillName(nx_string(skill_name))
  if effects ~= nil and 0 < table.getn(effects) then
    local role1 = nx_execute("custom_effect", "get_role_model", client_visual)
    local role2 = nx_execute("custom_effect", "get_role_model", select_visual)
    for _, effect_name in ipairs(effects) do
      create_effect(effect_name, role1, role2, "", "")
    end
  end
end
function del_ground_pick_effect()
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return 0
  end
  local scene = visual_player.scene
  local eff_model = nx_value("ground_pick_effect")
  if nx_is_valid(eff_model) then
    nx_execute("game_effect", "delete_eff_model_in_mainscene", scene, eff_model)
    nx_set_value("ground_pick_effect", nx_null())
  end
end
function locate_ground_pick_effect(eff_x, eff_y, eff_z)
  local eff_model = nx_value("ground_pick_effect")
  if not nx_is_valid(eff_model) then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return 0
  end
  local scene = visual_player.scene
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  terrain:RelocateVisual(eff_model, eff_x, eff_y, eff_z)
end
function add_ground_pick_effect(size, range, dds_res)
  if size <= 0 then
    size = 4
  end
  del_ground_pick_decal()
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  local photo = game_hand.Image
  local dds = "map\\tex\\Target_area_G.dds"
  if dds_res ~= "" and dds_res ~= nil then
    dds = dds_res
  end
  game_hand:SetHand(GHT_GROUD_PICK, "Default", nx_string(dds), "" .. size, "ground_pick_up_decal,on_left_mouse_down", nx_string(range))
end
function add_ground_pick_decal(decal_name, size, range)
  del_ground_pick_decal()
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local decal = scene:Create("SimpleDecal")
  decal.AsyncLoad = false
  decal.DiffuseMap = decal_name
  decal:Load()
  decal.EnableAlphaTest = false
  decal.EnableAlphaBlend = true
  decal.EnableAlphaBlendEnhance = true
  decal.CullThreshold = 0.4
  decal.Visible = false
  local player = util_get_role_model()
  local x, y, z = get_target_pos(player)
  local pick_x, pick_y, pick_z = game_control:TracePickRay()
  if pick_x and pick_y and pick_z then
    x = pick_x
    y = pick_y
    z = pick_z
  end
  decal:SetPosition(x, y, z)
  decal.size = size
  decal.range = nx_number(range)
  local terrain = scene.terrain
  local value = terrain:AddVisualRole("ground_pick_decal", decal)
  if not value then
    nx_msgbox("add_ground_pick_decal AddVisualRole failed " .. nx_string(value))
    scene:Delete(decal)
    return false
  end
  terrain:RelocateVisual(decal, x, y, z)
  decal.EnableRotateUV = true
  nx_set_value("ground_pick_decal", decal)
  decal.DisplayBias = 0.001
  decal.PosX = x
  decal.PosY = y
  decal.PosZ = z
end
function del_ground_pick_decal()
  local decal = nx_value("ground_pick_decal")
  if nx_is_valid(decal) then
    local scene = nx_value("game_scene")
    scene:Delete(decal)
  end
end
function hide_ground_pick_decal()
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  local decal = nx_value("ground_pick_decal")
  if nx_is_valid(decal) then
    decal.hided = true
    decal.Visible = false
  end
end
function locate_ground_pick_decal(x, y, z, distance)
  if y == nil then
    y = 0
  end
  if x == nil or z == nil then
    return
  end
  local decal = nx_value("ground_pick_decal")
  if not nx_is_valid(decal) then
    return
  end
  decal.EnableAlphaTest = false
  decal.EnableAlphaBlend = true
  decal.EnableAlphaBlendEnhance = true
  if nx_find_custom(decal, "hided") then
    decal.Visible = not decal.hided
  else
    decal.Visible = true
  end
  if nx_find_custom(decal, "range") and decal.range ~= nil and distance ~= nil then
    if distance > decal.range + 2 then
      decal.Color = "255,255,0,0"
    else
      decal.Color = "255,255,255,255"
    end
  end
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return 0
  end
  local scene = visual_player.scene
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  local mask_role = terrain:GetTraceMask("Role")
  local mask_effectmodel = terrain:GetTraceMask("EffectModel")
  local mask_model = terrain:GetTraceMask("Model")
  terrain:SetTraceMask("Role", true)
  terrain:SetTraceMask("EffectModel", true)
  terrain:SetTraceMask("Model", false)
  if not decal:BuildByOrthoLH(terrain, x, y + 0.1, z, x, y, z, decal.size, decal.size, 0.1, 2, 0, false, true) then
    nx_msgbox("build select decal fail")
    return false
  end
  decal.PosX = x
  decal.PosY = y
  decal.PosZ = z
  terrain:RelocateVisual(decal, decal.PositionX, decal.PositionY, decal.PositionZ)
  terrain:SetTraceMask("Role", mask_role)
  terrain:SetTraceMask("EffectModel", mask_effectmodel)
  terrain:SetTraceMask("Model", mask_model)
end
function create_ground_decal(name, x, y, z, radius, dif_map, async_load, rotate_angle)
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  if rotate_angle == nil then
    rotate_angle = 0
  end
  local decal = scene:Create("SimpleDecal")
  decal.AsyncLoad = async_load
  decal.DiffuseMap = dif_map
  decal:Load()
  decal.EnableAlphaTest = false
  decal.EnableAlphaBlend = true
  decal.EnableAlphaBlendEnhance = true
  decal:SetPosition(x, y, z)
  local terrain = scene.terrain
  if not terrain:AddVisual(name, decal) then
    scene:Delete(decal)
    return nx_null()
  end
  terrain:RelocateVisual(decal, x, y + 0.1, z)
  if not decal:BuildByOrthoLH(terrain, x, y + 0.1, z, x, y, z, radius * 2, radius * 2, 0.1, 2, nx_number(rotate_angle)) then
    scene:Delete(decal)
    return nx_null()
  end
  return decal
end
function delete_ground_decal(decal)
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) and nx_is_valid(decal) then
    scene:Delete(decal)
  end
end
function isSupportCondition(client_ident, neigong, neigongLevelMin, neigongLevelMax, skill, skillLevelMin, skillLevelMax, isSelf)
  local imitate_grid = nx_value("imitate_grid")
  if nx_is_valid(imitate_grid) then
    local res = nx_execute("EffectEditor\\form_condition", "_isSupportCondition", neigong, neigongLevelMin, neigongLevelMax, skill, skillLevelMin, skillLevelMax, isSelf)
    return res
  end
  local game_client = nx_value("game_client")
  local cur_neigong_name = ""
  local neigong_level = ""
  local skill_name = ""
  local skill_level = ""
  if client_ident == nil or client_ident == "" then
    return false
  end
  local client_obj = game_client:GetSceneObj(nx_string(client_ident))
  if not nx_is_valid(client_obj) then
    return false
  end
  if client_obj:FindProp("CurNeiGong") then
    cur_neigong_name = client_obj:QueryProp("CurNeiGong")
  end
  if client_obj:FindProp("CurNeiGongLevel") then
    neigong_level = client_obj:QueryProp("CurNeiGongLevel")
  end
  if client_obj:FindProp("CurSkillID") then
    skill_name = client_obj:QueryProp("CurSkillID")
  end
  if client_obj:FindProp("CurSkillLevel") then
    skill_level = client_obj:QueryProp("CurSkillLevel")
  end
  neigong_level = nx_number(neigong_level)
  skill_level = nx_number(skill_level)
  neigongLevelMin = nx_number(neigongLevelMin)
  neigongLevelMax = nx_number(neigongLevelMax)
  skillLevelMin = nx_number(skillLevelMin)
  skillLevelMax = nx_number(skillLevelMax)
  console_log_down("[\202\244\208\212] " .. cur_neigong_name .. "," .. neigong_level .. "," .. skill_name .. "," .. skill_level)
  console_log_down("[\204\245\188\254] " .. nx_string(neigong) .. "," .. nx_string(neigongLevelMin) .. "-" .. nx_string(neigongLevelMax) .. "," .. nx_string(skill) .. "," .. nx_string(skillLevelMin) .. "," .. nx_string(skillLevelMax))
  if neigong ~= "" and neigong ~= cur_neigong_name then
    console_log_down("[\196\218\185\166\195\251] is false")
    return false
  end
  if 0 < neigongLevelMin and 0 < neigongLevelMax and (neigong_level < neigongLevelMin or neigong_level > neigongLevelMax) then
    console_log_down("[\196\218\185\166\181\200\188\182] is false")
    return false
  end
  if skill ~= "" and skill_name ~= skill then
    console_log_down("[\188\188\196\220\195\251] is false")
    return false
  end
  if 0 < skillLevelMin and 0 < skillLevelMax and (skill_level < skillLevelMin or skill_level > skillLevelMax) then
    console_log_down("[\188\188\196\220\181\200\188\182] is false")
    return false
  end
  console_log_down("[\197\208\182\207\189\225\185\251] is Ok")
  return true
end
function my_msgbox(msg)
  console_log_down(nx_string(msg))
end
function get_target_pos(actor2)
  if not nx_is_valid(actor2) then
    return 0, 0, 0
  end
  local target_actor2 = actor2
  local actor2_role = target_actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor2_role) then
    target_actor2 = actor2_role
  end
  return actor2.CenterX, actor2.PositionY, actor2.CenterZ
end
function is_super_simple_config()
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and game_config.level == "supersimple" then
    return true
  end
  return false
end
