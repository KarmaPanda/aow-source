require("util_functions")
require("share\\logicstate_define")
require("define\\move_define")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local function get_method_arg(ent, method_list)
  local nifo_list = nx_method(ent, method_list)
  log("method_list bagin")
  for _, info in pairs(nifo_list) do
    log("info = " .. nx_string(info))
  end
  log("method_list end")
end
local function get_method(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local method_list = nx_method_list(ent)
  log("method_list bagin")
  for _, method in ipairs(method_list) do
    log("method = " .. method)
  end
  log("method_list end")
end
function init(role_composite)
end
local get_global_list = function(global_list_name)
  return nx_call("util_gui", "get_global_arraylist", global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
function on_load_finish(role_composite, actor2)
end
function create_actor2(scene, debug_info)
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local actor2 = scene:Create("Actor2")
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  actor2.scene = scene
  return actor2
end
function create_role_face(scene, sex, file_name)
  local actor2 = create_actor2(scene, "create_role_face")
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  if file_name == nil then
    file_name = sex == 0 and "obj\\char\\b_face\\face_5\\composite.ini" or "obj\\char\\g_face\\face_5\\composite.ini"
  end
  if not actor2:CreateFromIni(file_name) then
    scene:Delete(actor2)
    nx_log("not find role_face ")
    return nx_null()
  end
  return actor2
end
function create_role_composite_with_actor2(scene, actor2, async_load, sex, default_action)
  actor2.AsyncLoad = async_load
  local actor_role = create_actor2(scene, "create_role_composite2")
  if not nx_is_valid(actor_role) then
    return nx_null()
  end
  actor_role.AsyncLoad = async_load
  local action = ""
  local main_model = ""
  if sex == 0 then
    action = "obj\\char\\b_action\\action.ini"
    main_model = "obj\\char\\b_model\\tpose.xmod"
  else
    action = "obj\\char\\g_action\\action.ini"
    main_model = "obj\\char\\g_model\\tpose.xmod"
  end
  if nil == default_action then
    actor2.default_action = "stand"
  else
    actor2.default_action = default_action
  end
  if not actor_role:SetActionEx(action, actor2.default_action, "", async_load) then
    scene:Delete(actor2)
    scene:Delete(actor_role)
    return nx_null()
  end
  actor_role.Callee = nx_create("ActionEventHandler")
  if not actor_role:AddSkin("main_model", main_model) then
    scene:Delete(actor2)
    scene:Delete(actor_role)
    return nx_null()
  end
  while not actor_role.LoadFinish do
    nx_pause(0)
  end
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0)
  end
  if not nx_is_valid(actor2) then
    scene:Delete(actor_role)
    return nx_null()
  end
  actor2:LinkToPoint("actor_role", "mount::Point01", actor_role)
  local game_visual = nx_value("game_visual")
  game_visual:CreateRoleUserData(actor2)
  game_visual:SetActRole(actor2, actor_role)
  local child_actor2 = create_role_face(scene, sex)
  if nx_is_valid(child_actor2) then
    actor_role:LinkToPoint("actor_role_face", "mount::Point01", child_actor2)
    actor_role:AddChildAction(child_actor2)
    child_actor2:AddParentAction(actor_role)
    game_visual:SetActFace(actor2, child_actor2)
  end
  if not nx_is_valid(actor2) then
    scene:Delete(actor_role)
    scene:Delete(child_actor2)
    return nx_null()
  end
  actor_role.link_parent = actor2
  return actor2
end
function create_role_composite_with_actor2_body(scene, actor2, async_load, sex, default_action, body_type)
  actor2.AsyncLoad = async_load
  local actor_role = create_actor2(scene, "create_role_composite2")
  if not nx_is_valid(actor_role) then
    return nx_null()
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return nx_null()
  end
  local xmod_scale = body_manager:GetBodyScale(body_type)
  local face_id = body_manager:GetBodyFaceId(body_type)
  local xmod_init = body_manager:GetInitModel(body_type)
  actor_role.AsyncLoad = async_load
  local action = ""
  local main_model = ""
  if sex == 0 then
    action = "obj\\char\\b_action\\action.ini"
    main_model = "obj\\char\\b_model_simple\\tpose.xmod"
  else
    action = "obj\\char\\g_action\\action.ini"
    main_model = "obj\\char\\g_model_simple\\tpose.xmod"
  end
  if nil == default_action then
    actor2.default_action = "stand"
  else
    actor2.default_action = default_action
  end
  if not actor_role:SetActionEx(action, actor2.default_action, "", async_load) then
    scene:Delete(actor2)
    scene:Delete(actor_role)
    return nx_null()
  end
  actor_role.Callee = nx_create("ActionEventHandler")
  if not actor_role:AddSkin("main_model", main_model) then
    scene:Delete(actor2)
    scene:Delete(actor_role)
    return nx_null()
  end
  while not actor_role.LoadFinish do
    nx_pause(0)
  end
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0)
  end
  if not nx_is_valid(actor2) then
    scene:Delete(actor_role)
    return nx_null()
  end
  actor2:LinkToPoint("actor_role", "mount::Point01", actor_role)
  local game_visual = nx_value("game_visual")
  game_visual:CreateRoleUserData(actor2)
  game_visual:SetActRole(actor2, actor_role)
  local child_actor2 = create_role_face(scene, sex)
  if nx_is_valid(child_actor2) then
    actor_role:LinkToPoint("actor_role_face", "mount::Point01", child_actor2)
    actor_role:AddChildAction(child_actor2)
    child_actor2:AddParentAction(actor_role)
    game_visual:SetActFace(actor2, child_actor2)
    role_composite:LinkFaceSkin(actor2, sex, face_id, false)
  end
  if not nx_is_valid(actor2) then
    scene:Delete(actor_role)
    scene:Delete(child_actor2)
    return nx_null()
  end
  actor_role.link_parent = actor2
  local hat_xmod = xmod_init[1]
  local cloth_xmod = xmod_init[2]
  if hat_xmod ~= nil and cloth_xmod ~= nil then
    link_skin(actor2, "hat", nx_string(hat_xmod) .. ".xmod")
    link_skin(actor2, "cloth", nx_string(cloth_xmod) .. ".xmod")
  end
  actor2:SetScale(xmod_scale, xmod_scale, xmod_scale)
  nx_set_custom(actor2, "is_new_body", 1)
  return actor2
end
function create_role_composite(scene, async_load, sex, default_action, body_type)
  local world = nx_value("world")
  local actor2 = create_actor2(scene, "create_role_composite1")
  async_load = false
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  if body_type == nil or body_type <= 2 then
    create_role_composite_with_actor2(scene, actor2, async_load, sex, default_action)
  else
    create_role_composite_with_actor2_body(scene, actor2, async_load, sex, default_action, body_type)
  end
  return actor2
end
function create_role_composite_simple(scene, async_load, sex, default_action)
  local world = nx_value("world")
  local actor2 = create_actor2(scene, "create_role_composite1")
  async_load = false
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  actor2.AsyncLoad = async_load
  local actor_role = create_actor2(scene, "create_role_composite2")
  if not nx_is_valid(actor_role) then
    return nx_null()
  end
  actor_role.AsyncLoad = async_load
  local action = ""
  local main_model = ""
  if sex == 0 then
    action = "obj\\char\\b_action\\action_simple.ini"
    main_model = "obj\\char\\b_model_simple\\tpose.xmod"
  else
    action = "obj\\char\\g_action\\action_simple.ini"
    main_model = "obj\\char\\g_model_simple\\tpose.xmod"
  end
  if nil == default_action then
    actor2.default_action = "stand"
  else
    actor2.default_action = default_action
  end
  if not actor_role:SetActionEx(action, actor2.default_action, "", async_load) then
    scene:Delete(actor2)
    scene:Delete(actor_role)
    return nx_null()
  end
  actor_role.Callee = nx_create("ActionEventHandler")
  if not actor_role:AddSkin("main_model", main_model) then
    scene:Delete(actor2)
    scene:Delete(actor_role)
    return nx_null()
  end
  while not actor_role.LoadFinish do
    nx_pause(0)
  end
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0)
  end
  if not nx_is_valid(actor2) then
    scene:Delete(actor_role)
    return nx_null()
  end
  actor2:LinkToPoint("actor_role", "mount::Point01", actor_role)
  local game_visual = nx_value("game_visual")
  game_visual:CreateRoleUserData(actor2)
  game_visual:SetActRole(actor2, actor_role)
  local child_actor2 = create_role_face(scene, sex)
  if nx_is_valid(child_actor2) then
    actor_role:LinkToPoint("actor_role_face", "mount::Point01", child_actor2)
    actor_role:AddChildAction(child_actor2)
    child_actor2:AddParentAction(actor_role)
    game_visual:SetActFace(actor2, child_actor2)
  end
  if not nx_is_valid(actor2) then
    scene:Delete(actor_role)
    scene:Delete(child_actor2)
    return nx_null()
  end
  actor_role.link_parent = actor2
  return actor2
end
function link_skin(actor2, link_name, model_name, root)
  if link_name == nil or model_name == nil then
    return
  end
  if root == nil then
    root = false
  end
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    role_composite:LinkSkin(actor2, link_name, model_name, root)
  end
end
function link_skin_ex(actor2, link_name, model_name, add_model_material, root)
  if link_name == nil or model_name == nil then
    return
  end
  if add_model_material == nil then
    add_model_material = ""
  end
  if root == nil then
    root = false
  end
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    role_composite:LinkSkinEx(actor2, link_name, model_name, add_model_material, root)
  end
end
function link_model_ex(actor2, link_name, point_name, model_name, material, root)
  if link_name == nil or string.len(link_name) == 0 then
    return
  end
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    role_composite:LinkModel(actor2, link_name, point_name, model_name, material, root)
  end
  return true
end
function link_weapon(actor2, link_name, point_name, model_name, root)
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    role_composite:LinkWeapon(actor2, link_name, point_name, model_name)
  end
end
function set_player_face_ex(actor2, face, sex, ...)
  if not nx_is_valid(actor2) or face == nil or sex == nil then
    return
  end
  local role_composite = nx_value("role_composite")
  local obj = arg[1]
  if not nx_is_valid(obj) then
    obj = 0
  end
  if nx_is_valid(role_composite) then
    role_composite:SetPlayerFaceDetial(actor2, face, sex, obj)
  end
end
function get_role_faceEx(role_actor2)
  if not nx_is_valid(role_actor2) then
    return nx_null()
  end
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    actor_role = role_actor2
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function create_scene_obj_composite(scene, client_scene_obj, include_mount, debug_info, obj_type, include_subrole)
  local role_composite = nx_value("role_composite")
  local actor2 = nx_null()
  if include_mount == nil then
    include_mount = false
  end
  if nx_is_valid(role_composite) then
    if include_subrole ~= nil then
      actor2 = role_composite:CreateSceneObjectWithSubModel(scene, client_scene_obj, false, include_mount, include_subrole)
    else
      actor2 = role_composite:CreateSceneObject(scene, client_scene_obj, false, include_mount)
    end
  end
  return actor2
end
function script_create_scene_obj_composite(scene, client_scene_obj, include_mount, debug_info, obj_type)
  local actor2 = create_actor2(scene, "create_scene_obj_composite " .. nx_string(debug_info))
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  create_scene_obj_composite_with_actor2(scene, actor2, client_scene_obj, include_mount, debug_info)
  return actor2
end
function is_loading(object_type, actor2)
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    return role_composite:IsLoading(object_type, actor2)
  end
  return false
end
function create_scene_obj_composite_with_actor2(scene, actor2, client_scene_obj, include_mount, debug_info)
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    return role_composite:CreateSceneObjectWithActor2(scene, client_scene_obj, actor2, false, include_mount, false, false)
  end
end
function unlink_skin(actor2, prop_name)
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    return role_composite:UnLinkSkin(actor2, prop_name)
  end
end
function refresh_role_composite(actor2, prop_name)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local client_scene_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    return role_composite:PlayerVisPropChange(actor2, client_scene_obj, prop_name)
  end
end
function load_from_ini(actor2, ini_file)
  if not nx_is_valid(actor2) then
    return false
  end
  while not actor2.LoadFinish do
    nx_pause(0)
    if not nx_is_valid(actor2) then
      return false
    end
  end
  local world = nx_value("world")
  local scene = nx_null()
  if nx_find_custom(actor2, "scene") then
    scene = actor2.scene
  end
  if not nx_is_valid(scene) then
    scene = nx_value("game_scene")
  end
  if not nx_is_valid(scene) then
    nx_log("Scene not found role_composite.lua 874 line")
    return false
  end
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(nx_resource_path() .. ini_file)
  if not ini:LoadFromFile() then
    nx_log("Can't Creat object form loading the file ! the file can't find ! :" .. ini.FileName)
    nx_destroy(ini)
    return false
  end
  local sect_lst = ini:GetSectionList()
  if table.getn(sect_lst) == 0 then
    nx_log(" the file is empty! :" .. ini.FileName)
    nx_destroy(ini)
    return false
  end
  local sect = sect_lst[1]
  local action = ini:ReadString(sect, "Action", "")
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  if client_ident == "" then
    actor2.default_action = ini:ReadString(sect, "DefaultAction", "")
  else
    local client_scene_obj = game_client:GetSceneObj(client_ident)
    if client_scene_obj:FindProp("BornAction") and client_scene_obj:QueryProp("BornAction") ~= "" then
      actor2.default_action = client_scene_obj:QueryProp("BornAction")
    else
      actor2.default_action = ini:ReadString(sect, "DefaultAction", "")
    end
  end
  local talk_action = ini:ReadString(sect, "TalkAction", "")
  actor2.talk_action = talk_action
  local is_skin = 0 < string.len(action)
  if is_skin then
    actor2:SetActionEx(action, actor2.default_action, "", true)
    actor2.Callee = nx_create("ActionEventHandler")
  end
  local rider = ini:ReadString(sect, "Rider", "")
  if rider ~= "" then
    local split_table = util_split_string(rider, ",")
    if table.getn(split_table) >= 2 then
      local link_point = split_table[1]
      local rider_file = split_table[2]
      local rider_actor2 = create_actor2(scene)
      if nx_is_valid(rider_actor2) then
        rider_actor2.AsyncLoad = true
        local result = load_from_ini(rider_actor2, rider_file)
        if result then
          if not nx_is_valid(actor2) then
            scene:Delete(rider_actor2)
            return false
          end
          actor2:LinkToPoint("actor_role", link_point, rider_actor2)
          rider_actor2.link_parent = actor2
        elseif nx_is_valid(rider_actor2) then
          scene:Delete(rider_actor2)
        end
      end
    end
  end
  if not nx_is_valid(actor2) then
    return false
  end
  local no_model_key_lst = {
    Action = 0,
    DefaultAction = 0,
    IdleAction = 0,
    EffectModel = 0,
    MinRandomTime = 0,
    MaxRandomTime = 0,
    TalkAction = 0,
    Height = 0,
    ["@Model"] = 0,
    CullEnable = 0,
    Rider = 0
  }
  local model_material = ini:ReadString(sect, "@Model", "")
  local item_lst = ini:GetItemList(sect)
  for i, item in pairs(item_lst) do
    if no_model_key_lst[item] == nil then
      local model_file = ini:ReadString(sect, item, "")
      if 0 < string.len(model_file) then
        if is_skin then
          if 1 < string.len(model_material) then
            if not link_skin_ex(actor2, item, model_file, model_material, true) then
            end
          else
            link_skin(actor2, item, model_file, true)
          end
        elseif link_model_ex(actor2, item, "", model_file, model_material, true) then
          local cull_enable = ini:ReadString(sect, "CullEnable", "true")
          if "false" == cull_enable then
            local link_obj = actor2:GetLinkObject(item)
            link_obj.CullEnable = false
          end
        end
      end
    end
  end
  local need_face = ini:ReadInteger(sect, "NeedFace", 0)
  if 0 < need_face then
    local child_actor2 = create_role_face(scene, need_face - 1)
    if nx_is_valid(child_actor2) and nx_is_valid(game_visual) then
      actor2:LinkToPoint("actor_role_face", "mount::Point01", child_actor2)
      actor2:AddChildAction(child_actor2)
      child_actor2:AddParentAction(actor2)
      game_visual:SetActFace(actor2, child_actor2)
    end
  end
  local effectmodel_file = ini:ReadString(sect, "EffectModel", "")
  if 0 < string.len(effectmodel_file) then
    local effect_ini = nx_create("IniDocument")
    effect_ini.FileName = nx_string(nx_resource_path() .. effectmodel_file)
    if effect_ini:LoadFromFile() then
      local sect_lst = effect_ini:GetSectionList()
      local sect_count = table.maxn(sect_lst)
      for i = 1, sect_count do
        if not nx_is_valid(scene) then
          return false
        end
        local section_name = sect_lst[i]
        local effect_name = effect_ini:ReadString(section_name, "Name", "")
        local type = effect_ini:ReadString(section_name, "Type", "")
        local link_piont = effect_ini:ReadString(section_name, "LinkPoint", "")
        local effect_file = effect_ini:ReadString(section_name, "File", "")
        local essobj = effect_ini:ReadString(section_name, "EsseObj", "true")
        local cull_enable = effect_ini:ReadString(section_name, "CullEnable", "true")
        local sub_modal
        if type == "EffectContent" then
          local res = create_effect(nx_string(effect_name), actor2, actor2, "", "", "", "", "", true)
          if res then
          else
          end
        else
          if type == "EffectModel" then
            sub_modal = scene:Create("EffectModel")
            sub_modal.AsyncLoad = true
            sub_modal:CreateFromIniEx(effect_file, effect_name, true, "")
          elseif type == "Actor2" then
            sub_modal = create_actor2(scene, "role_composite 1053")
            sub_modal:CreateFromIni(effect_file)
          end
          if not nx_is_valid(sub_modal) then
            return false
          end
          if nx_is_valid(actor2) then
            if "false" == essobj then
              actor2:LinkToPoint(section_name, link_piont, sub_modal, false)
            else
              actor2:LinkToPoint(section_name, link_piont, sub_modal)
            end
          elseif nx_is_valid(sub_modal) then
            if nx_is_valid(scene) then
              scene:Delete(sub_modal)
            else
              world.MainScene:Delete(scene)
            end
            return false
          end
          local offset_x = effect_ini:ReadFloat(section_name, "offset_x", 0)
          local offset_y = effect_ini:ReadFloat(section_name, "offset_y", 0)
          local offset_z = effect_ini:ReadFloat(section_name, "offset_z", 0)
          actor2:SetLinkPosition(section_name, offset_x, offset_y, offset_z)
          local angle_x = effect_ini:ReadFloat(section_name, "angle_x", 0)
          local angle_y = effect_ini:ReadFloat(section_name, "angle_y", 0)
          local angle_z = effect_ini:ReadFloat(section_name, "angle_z", 0)
          actor2:SetLinkAngle(section_name, angle_x, angle_y, angle_z)
          local scale_x = effect_ini:ReadFloat(section_name, "scale_x", 1)
          local scale_y = effect_ini:ReadFloat(section_name, "scale_y", 1)
          local scale_z = effect_ini:ReadFloat(section_name, "scale_z", 1)
          actor2:SetLinkScale(section_name, scale_x, scale_y, scale_z)
          if "false" == cull_enable then
            sub_modal.CullEnable = false
          end
        end
      end
    end
    nx_destroy(effect_ini)
  end
  nx_destroy(ini)
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0)
  end
  return true
end
function test_add_neigong_effect(effect_name)
  local role = nx_value("role")
  link_neigong_effect(role, effect_name)
end
function test_del_neigong_effect()
  local role = nx_value("role")
  link_neigong_effect(role, "")
end
function link_neigong_effect(actor2, effect)
  local link_name = "neigong_effect"
  local actor_role = nx_null()
  if root == nil or not root then
    actor_role = actor2:GetLinkObject("actor_role")
  end
  if not nx_is_valid(actor_role) then
    actor_role = actor2
  end
  local old_effect_model = actor_role:GetLinkObject(link_name)
  if nx_is_valid(old_effect_model) then
    if nx_find_custom(old_effect_model, "alpha_out") and old_effect_model.alpha_out then
      nx_execute(nx_current(), "alpha_neigong_effect", actor_role, false, old_effect_model.alpha_in_speed)
    end
    if nx_find_custom(old_effect_model, "alpha_out") and old_effect_model.scale_out then
      nx_execute(nx_current(), "scale_neigong_effect", actor_role, true, old_effect_model.scale_out_speed, old_effect_model.scale_target)
    end
    while nx_is_valid(old_effect_model) do
      nx_pause(0)
    end
  end
  if effect == nil or string.len(effect) == 0 then
    return
  end
  local scene = nx_value("game_scene")
  local effect_model = scene:Create("EffectModel")
  effect_model:CreateFromIni("ini\\effect\\model.ini", effect, false)
  if not nx_is_valid(effect_model) then
    local scene = actor2.scene
    scene:Delete(effect_model)
    return
  end
  if not actor_role:LinkToPoint(link_name, "", effect_model) then
    scene:Delete(effect_model)
    return false
  end
  actor_role:SetLinkAngleKeep(link_name, true)
  local ini_manager = nx_value("IniManager")
  if nx_is_valid(ini_manager) then
    ini_manager:UnloadIniFromManager("ini\\effect\\neigong.ini")
    ini_manager:LoadIniToManager("ini\\effect\\neigong.ini")
    local neigong_ini = ini_manager:GetIniDocument("ini\\effect\\neigong.ini")
    if nx_is_valid(neigong_ini) then
      effect_model.alpha_in_speed = neigong_ini:ReadFloat(effect, "AlphaInSpeed", 100)
      effect_model.alpha_out_speed = neigong_ini:ReadFloat(effect, "AlphaOutSpeed", 100)
      effect_model.alpha_in = neigong_ini:ReadInteger(effect, "AlphaIn", 0)
      effect_model.alpha_out = neigong_ini:ReadInteger(effect, "AlphaOut", 0)
      effect_model.scale_in_speed = neigong_ini:ReadFloat(effect, "ScaleInSpeed", 0.05)
      effect_model.scale_out_speed = neigong_ini:ReadFloat(effect, "ScaleOutSpeed", 0.05)
      effect_model.scale_in = neigong_ini:ReadInteger(effect, "ScaleIn", 0)
      effect_model.scale_out = neigong_ini:ReadInteger(effect, "ScaleOut", 0)
      local base_range = neigong_ini:ReadFloat(effect, "BaseRange", 7)
      local effect_range = neigong_ini:ReadFloat(effect, "EffectRange", 7)
      effect_model.scale_target = effect_range / base_range
    end
  else
    return 0
  end
  if effect_model.scale_in then
    nx_execute(nx_current(), "scale_neigong_effect", actor_role, false, effect_model.scale_in_speed, effect_model.scale_target)
  end
  if effect_model.alpha_in then
    nx_execute(nx_current(), "alpha_neigong_effect", actor_role, true, effect_model.alpha_in_speed)
  end
end
function scale_neigong_effect(actor_role, shrink, speed, scale_target)
  if scale_target == nil then
    scale_target = 1
  end
  if shrink then
    local sep, y, z = actor_role:GetLinkScale("neigong_effect")
    sep = (scale_target - sep) * 2
    while true do
      sep = sep + nx_pause(0) * speed
      actor_role:SetLinkScale("neigong_effect", scale_target - sep / 2, scale_target - sep / 2, scale_target - sep / 2)
      if scale_target <= sep / 2 then
        break
      end
    end
    actor_role:UnLink("neigong_effect", true)
  else
    local sep = 0.01
    while true do
      actor_role:SetLinkScale("neigong_effect", sep / 2, sep / 2, sep / 2)
      sep = sep + nx_pause(0) * speed
      if scale_target <= sep / 2 then
        break
      end
    end
    local result = actor_role:SetLinkScale("neigong_effect", scale_target, scale_target, scale_target)
  end
end
function alpha_neigong_effect(actor_role, in_or_out, speed)
  if not nx_is_valid(actor_role) then
    return 0
  end
  local link_name = "neigong_effect"
  local effect_model = actor_role:GetLinkObject(link_name)
  if in_or_out then
    local sep = 0
    effect_model.Color = "0,255,255,255"
    while nx_is_valid(effect_model) do
      if 255 < sep then
        effect_model.Color = "255,255,255,255"
        break
      end
      effect_model.Color = nx_string(nx_int(sep)) .. ",255,255,255"
      sep = sep + speed * nx_pause(0)
    end
  else
    local sep = 255
    effect_model.ColorString = "255,255,255,255"
    while nx_is_valid(effect_model) do
      if sep < 0 then
        effect_model.Color = "0,255,255,255"
        break
      end
      effect_model.Color = nx_string(nx_int(sep)) .. ",255,255,255"
      sep = sep - speed * nx_pause(0)
    end
    if nx_is_valid(actor_role) then
      actor_role:UnLink(link_name, true)
    end
  end
end
function get_scene_obj_height(role)
  if not nx_is_valid(role) then
    return 1.7
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(role)
  local client_scene_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_scene_obj) then
    return 0
  end
  local type = client_scene_obj:QueryProp("Type")
  if type == 2 then
    local sex = 0
    if client_scene_obj:FindProp("Sex") then
      sex = client_scene_obj:QueryProp("Sex")
    end
    if sex == 0 then
      return 1.8
    else
      return 1.7
    end
  else
    local height = 1.7
    local ini = nx_create("IniDocument")
    local res_name = client_scene_obj:QueryProp("Resource")
    ini.FileName = nx_resource_path() .. "ini\\" .. res_name .. ".ini"
    if ini:LoadFromFile() then
      local sect_lst = ini:GetSectionList()
      if 0 < table.getn(sect_lst) then
        local sect = sect_lst[1]
        height = ini:ReadFloat(sect, "Height", 1.7)
      end
    end
    nx_destroy(ini)
    return height
  end
  return 0
end
function control_role_weapon_position(actor2, flag)
  local game_visual = nx_value("game_visual")
  if flag == 1 then
    actor2.old_weapon_name = game_visual:QueryRoleWeaponName(actor2)
    game_visual:SetRoleWeaponName(actor2, "")
    refresh_weapon_position(actor2)
  elseif flag == 2 then
    if not nx_find_custom(role, "old_weapon_name") then
      return
    end
    game_visual:SetRoleWeaponName(actor2, actor2.old_weapon_name)
    refresh_weapon_position(actor2)
  end
end
function refresh_weapon_position(role)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:RefreshWeapon(role)
end
function get_weapon_link_point(role, pos_type, side_type, action_set)
  if pos_type == "hand" then
    if side_type == "right" then
      return "main_model::H_weaponR_01"
    else
      return "main_model::H_weaponL_01"
    end
  elseif side_type == "right" then
    if action_set == "1h" then
      return "main_model::B_weaponR_01"
    elseif action_set == "2h" then
      return "main_model::B_weaponR_01"
    elseif action_set == "3h" then
      return "main_model::W_weaponR_02"
    elseif action_set == "4h" then
      return "main_model::B_weaponR_01"
    elseif action_set == "5h" then
      return "main_model::B_weaponR_01"
    elseif action_set == "6h" then
      return "main_model::W_weaponR_01"
    elseif action_set == "7h" then
      return "main_model::B_weaponR_02"
    elseif action_set == "8h" then
      return "main_model::B_weaponR_02"
    elseif action_set == "9h" then
      return "main_model::W_weaponR_01"
    else
      return "main_model::B_weaponR_01"
    end
  elseif action_set == "5h" then
    return "main_model::B_weaponL_01"
  elseif action_set == "4h" then
    return "main_model::B_weaponL_01"
  elseif action_set == "6h" then
    return "main_model::W_weaponL_01"
  else
    return "main_model::B_weaponL_01"
  end
end
