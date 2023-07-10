function add_skin(actor_role, bMan, flag, man_path, feman_path)
  local path = feman_path
  if bMan then
    path = man_path
  end
  actor_role:DeleteSkin(flag)
  actor_role:AddSkin(flag, path)
end
function use_faculty_skin(actor_role)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(actor_role) then
    return
  end
  local vis_list = actor_role:GetVisualList()
  for _, vis in pairs(vis_list) do
    if nx_is_valid(vis) and nx_is_kind(vis, "Skin") then
      vis.Visible = false
    end
  end
  local sex = client_player:QueryProp("Sex")
  local bMan = false
  local model_name = ""
  if nx_string(sex) == "0" then
    bMan = true
  end
  model_name = "obj\\char\\b_jianghu000\\b_cloth000.xmod"
  local feman_path = ""
  add_skin(actor_role, bMan, "faculty_cloth", "obj\\char\\b_jianghu000\\b_cloth000.xmod", feman_path)
  add_skin(actor_role, bMan, "faculty_pants", "obj\\char\\b_jianghu000\\b_pants000.xmod", feman_path)
  add_skin(actor_role, bMan, "faculty_shoes", "obj\\char\\b_jianghu000\\b_shoes000.xmod", feman_path)
  actor_role.Visible = true
  while not actor_role.LoadFinish do
    nx_pause(0)
  end
end
function unuse_faculty_skin()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local player = game_visual:GetPlayer()
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(player) or not nx_is_valid(client_player) then
    return
  end
  local actor_role = player:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    actor_role = player
  end
  local vis_list = actor_role:GetVisualList()
  for _, vis in pairs(vis_list) do
    if nx_is_valid(vis) and nx_is_kind(vis, "Skin") then
      vis.Visible = true
    end
  end
  actor_role:DeleteSkin("faculty_cloth")
  actor_role:DeleteSkin("faculty_pants")
  actor_role:DeleteSkin("faculty_shoes")
end
function init_jingmai_effect()
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  local game_visual = nx_value("game_visual")
  local player = game_visual:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local actor_role = player:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    actor_role = player
  end
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return
  end
  effect_jingmai:SetTerrainScene(terrain, scene, false)
  effect_jingmai:SetActorRole(actor_role)
  effect_jingmai:EnterJMCameraMode()
end
function clear_jingmai_effect()
  local effect_jingmai = nx_value("EffectJingMai")
  if nx_is_valid(effect_jingmai) then
    effect_jingmai:ClearAll()
    effect_jingmai:OutJMCameraMode()
  end
end
function get_actor_role(actor2)
  if not nx_is_valid(actor2) then
    return nil
  end
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    return actor_role
  end
  return actor2
end
function clear_scene_player(scene)
  nx_execute("scene", "delete_scene", scene)
end
function create_jingmai(jingmai_group_name, ...)
  local effect_jingmai = nx_value("EffectJingMai")
  if not effect_jingmai then
    return
  end
  effect_jingmai:ClearJingMaiGroup(jingmai_group_name)
  if type(arg) == "table" and table.getn(arg) > 0 then
    effect_jingmai:CreateJingMaiGroup(jingmai_group_name, unpack(arg))
  end
  effect_jingmai:CreateXueWeisInJingMai(jingmai_group_name)
  effect_jingmai:CreateJingMaiProEffect(jingmai_group_name, "point_H_04")
end
function set_jingmai_process_effect(jingmai_group_name, effect)
  local effect_jingmai = nx_value("EffectJingMai")
  if not effect_jingmai then
    return
  end
  effect_jingmai:CreateJingMaiProEffect(jingmai_group_name, effect)
end
function init_jingmai_process(jingmai_group_name, wuxue_name, level, gate, xuewei_lst)
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return
  end
  local jewel_game_manager = nx_value("jewel_game_manager")
  local xuewei_lst = {}
  for i = 0, gate do
    xuewei_lst[i + 1] = jewel_game_manager:GetFacultyGateXueWeiName(wuxue_name, level, i)
  end
  for i = 1, table.getn(xuewei_lst) do
    effect_jingmai:ReplaceXueWeiInJM(jingmai_group_name, xuewei_lst[i], "point_H_02")
  end
end
function set_xuewei_effect(jingmai_group_name, xuewei_name, effect)
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return
  end
  effect_jingmai:ReplaceXueWeiInJM(jingmai_group_name, xuewei_name, effect)
end
function set_jingmai(jingmai_group_name, xuewei_name, ratio)
  local effect_jingmai = nx_value("EffectJingMai")
  if not effect_jingmai then
    return
  end
  effect_jingmai:SetJingMaiProgress(jingmai_group_name, xuewei_name, ratio, true, true)
end
