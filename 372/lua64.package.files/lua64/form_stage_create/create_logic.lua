require("role_composite")
require("const_define")
local FILE_SKILL_INI = "share\\Skill\\skill_new.ini"
local BOOK_LIST = {
  book1 = "introduction_qdz01",
  book2 = "introduction_yyz01",
  book4 = "introduction_cd01",
  book5 = "introduction_jm01",
  book8 = "introduction_wmp01"
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function change_face_skin_material(skin, key, value)
  if not nx_is_valid(skin) then
    return
  end
  local material_name_list = skin:GetMaterialNameList()
  if type(material_name_list) ~= "table" or table.getn(material_name_list) == 0 then
    return
  end
  for i, _ in ipairs(material_name_list) do
    if material_name_list[i] ~= "Standard_3" then
      skin:SetCustomMaterialValue(material_name_list[i], key, value)
    end
  end
  if not skin:ReloadCustomMaterialTextures() then
    return
  end
end
function create_role_add_cur_scene(form, sex, pos_x, pos_y, pos_z, angx, angy, angz, default_action, body_type)
  local main_scene = nx_value("game_scene")
  local visual_player = create_role_composite(main_scene, false, sex, default_action, body_type)
  if not nx_is_valid(visual_player) then
    return nx_null()
  end
  while nx_call("role_composite", "is_loading", 2, visual_player) do
    nx_pause(0)
  end
  if body_type == nil or body_type <= 2 then
    local skin_info = {
      [1] = {
        link_name = "hat",
        model_name = "obj\\char\\b_hair\\b_hair1"
      },
      [2] = {
        link_name = "cloth",
        model_name = "obj\\char\\b_jianghu001\\b_cloth001"
      },
      [3] = {
        link_name = "pants",
        model_name = "obj\\char\\b_jianghu001\\b_pants001"
      },
      [4] = {
        link_name = "shoes",
        model_name = "obj\\char\\b_jianghu001\\b_shoes001"
      }
    }
    for i, info in pairs(skin_info) do
      if info.model_name ~= nil then
        link_skin(visual_player, info.link_name, info.model_name .. ".xmod")
      end
    end
    while nx_is_valid(visual_player) and not visual_player.LoadFinish do
      nx_log("not visual_player.LoadFinish")
      nx_pause(0)
    end
    if not nx_is_valid(visual_player) then
      return
    end
    nx_pause(0.1)
    add_role_in_scene(main_scene, visual_player, pos_x, pos_y, pos_z, angx, angy, angz, 1, 1, 1)
  else
    add_role_in_scene_1(main_scene, visual_player, pos_x, pos_y, pos_z, angx, angy, angz)
  end
  if nx_is_valid(form) then
    if nx_find_custom(form, "rbtn_woman") and nx_is_valid(form.rbtn_woman) and nx_find_custom(form, "rbtn_man") and nx_is_valid(form.rbtn_man) then
      form.rbtn_woman.Enabled = true
      form.rbtn_man.Enabled = true
      form.btn_back_create.Enabled = true
      form.btn_back_login.Enabled = true
      form.btn_random.Enabled = true
    else
      local world = nx_value("world")
      if nx_is_valid(world) and nx_is_valid(visual_player) then
        world:Delete(visual_player)
      end
      return nx_null()
    end
  else
    local world = nx_value("world")
    if nx_is_valid(world) and nx_is_valid(visual_player) then
      world:Delete(visual_player)
    end
    return nx_null()
  end
  return visual_player
end
function add_role_in_scene_1(scene, visual_player, posx, posy, posz, angx, angy, angz)
  if not nx_is_valid(visual_player) then
    return
  end
  local terrain = scene.terrain
  while nx_is_valid(terrain) and not terrain.LoadFinish do
    nx_pause(0)
    if not nx_is_valid(terrain) then
      return false
    end
  end
  if not nx_is_valid(terrain) then
    return
  end
  local res = terrain:AddVisualRole("", visual_player)
  res = terrain:RelocateVisual(visual_player, posx, posy, posz)
  visual_player:SetPosition(posx, posy, posz)
  visual_player:SetAngle(get_pi(angx), get_pi(angy), get_pi(angz))
  res = terrain:RefreshVisual()
end
function get_equip_item_model(config_id, model_prop)
  return get_weaponmode_path_by_name(config_id, model_prop)
end
function add_role_in_scene(scene, visual_player, posx, posy, posz, angx, angy, angz, scax, scay, scaz)
  if not nx_is_valid(visual_player) then
    return
  end
  local terrain = scene.terrain
  while nx_is_valid(terrain) and not terrain.LoadFinish do
    nx_pause(0)
    if not nx_is_valid(terrain) then
      return false
    end
  end
  if not nx_is_valid(terrain) then
    return
  end
  local res = terrain:AddVisualRole("", visual_player)
  res = terrain:RelocateVisual(visual_player, posx, posy, posz)
  visual_player:SetPosition(posx, posy, posz)
  visual_player:SetAngle(get_pi(angx), get_pi(angy), get_pi(angz))
  if nil == scax then
    scax = 1
  end
  if nil == scay then
    scay = 1
  end
  if nil == scaz then
    scaz = 1
  end
  visual_player:SetScale(scax, scay, scaz)
  res = terrain:RefreshVisual()
end
function get_equip_info(str_type, sex, index, is_model)
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return ""
  end
  local photo, config = create_role:GetEquipInfo(nx_string(str_type), nx_int(sex), nx_int(index))
  if nil == is_model or is_model then
    if nil == config then
      return ""
    end
    if "hat" == str_type or "photo" == str_type then
      return config
    end
    local model_prop = nx_int(sex) == nx_int(0) and "MaleModel" or "FemaleModel"
    local model = get_equip_item_model(config, model_prop)
    return model
  end
  return photo
end
function remove_role(form)
  if nx_is_valid(form) and nx_is_valid(form.role_actor2) then
    local world = nx_value("world")
    world:Delete(form.role_actor2)
  end
end
function set_beard(actor2, model_name)
  local skin = actor2:GetLinkObject("beard")
  actor2:DeleteSkin("beard")
  local world = nx_value("world")
  world:Delete(skin)
  if model_name == "" then
    return false
  end
  link_skin(actor2, "beard", nx_string(model_name .. ".xmod"))
  return true
end
function set_face_materialfile(actor2, sex, type_index, feature_index)
  if not nx_is_valid(actor2) then
    return
  end
  local str_sex = sex == 0 and "b_face" or "g_face"
  local skin = actor2:GetLinkObject(str_sex)
  if not nx_is_valid(skin) then
    return
  end
  local texture = "face_" .. type_index .. "\\"
  local material_path = texture .. str_sex .. "_" .. feature_index .. ".dds"
  change_face_skin_material(skin, "DiffuseMap", material_path)
  if sex == 0 and nx_number(feature_index) > 1 and nx_number(feature_index) < 5 then
    local face_path = "obj\\char\\" .. str_sex .. "\\" .. texture .. "\\"
    local huzi_path = "b_huzi_" .. nx_string(feature_index)
    face_path = face_path .. huzi_path
    set_beard(actor2, face_path)
  else
    set_beard(actor2, "")
  end
end
function get_role_face(form)
  if not nx_is_valid(form) or not nx_find_custom(form, "role_actor2") then
    return nil
  end
  if not nx_is_valid(form.role_actor2) then
    return nil
  end
  local actor_role = form.role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function set_save_face(form, filepath)
  local info = ""
  local create_role = nx_value("create_role")
  local face = create_role:GetPlayerFaceData()
  local size = string.len(face)
  local hat = form.hat
  info = face .. string.char(hat + 1)
  local cloth = form.cloth
  info = info .. string.char(cloth + 1)
  local pants = form.pants
  info = info .. string.char(pants + 1)
  local shoes = form.shoes
  info = info .. string.char(shoes + 1)
  local feature = form.feature
  info = info .. string.char(feature + 1)
  local sex = form.sex
  info = info .. string.char(sex + 1)
  local beforehand = form.beforehand
  info = info .. string.char(beforehand + 1)
  local photo = form.photo
  info = info .. string.char(photo + 1)
  local create_time = os.date("%Y.%m.%d %H:%M")
  info = info .. create_time
  nx_function("ext_write_face_file", "", filepath, info)
end
function read_str_set_form_data(str, form, name, min_value, max_value)
  local value = 0
  if "hat" == name then
    value = string.byte(string.sub(str, 47, 47))
  elseif "cloth" == name then
    value = string.byte(string.sub(str, 48, 48))
  elseif "pants" == name then
    value = string.byte(string.sub(str, 49, 49))
  elseif "shoes" == name then
    value = string.byte(string.sub(str, 50, 50))
  elseif "feature" == name then
    value = string.byte(string.sub(str, 51, 51))
  elseif "sex" == name then
    value = string.byte(string.sub(str, 52, 52))
  elseif "beforehand" == name then
    value = string.byte(string.sub(str, 53, 53))
  elseif "photo" == name then
    value = string.byte(string.sub(str, 54, 54))
  else
    return false
  end
  value = nx_int(value)
  value = value - 1
  if value > min_value - 1 and value < max_value + 1 then
    local old_value = nx_custom(form, name)
    if value == old_value then
      return true
    end
    nx_set_custom(form, name, value)
    return true
  end
  return false
end
function check_name_separator(name, name_type)
  if nx_string(name) == nx_string("") or nx_string(name_type) == nx_string("") then
    return 0
  end
  local client_ini = nx_execute("util_functions", "get_ini", "ini\\name\\client_name_rule.ini", true)
  if not nx_is_valid(client_ini) then
    return 0
  end
  local client_rule_index = client_ini:FindSectionIndex("cur_rule")
  if client_rule_index < 0 then
    return 0
  end
  local client_rule = client_ini:ReadInteger(client_rule_index, "r", 0)
  if client_rule <= 0 then
    return 0
  end
  local section_index = client_ini:FindSectionIndex(nx_string(name_type))
  if section_index < 0 then
    return 0
  end
  local forbid_char = client_ini:ReadString(section_index, "forbid_char", "")
  local separator = client_ini:ReadString(section_index, "separator", "")
  if forbid_char ~= "" then
    local char_list = util_split_string(forbid_char, ";")
    local char_count = #char_list
    for i = 1, char_count do
      if nil ~= string.find(nx_string(name), char_list[i]) then
        return 1
      end
    end
  end
  if separator ~= "" then
    local result = 0
    while true do
      result = string.find(nx_string(name), separator, result + 1)
      if result == nil then
        return 0
      elseif result == 1 or result == string.len(nx_string(name)) then
        return 2
      elseif result + 1 <= string.len(nx_string(name)) and string.sub(nx_string(name), result + 1, result + 1) == separator then
        return 3
      end
    end
  end
  return 0
end
function set_camera_move(form, move_type)
  local scene = nx_value("game_scene")
  local game_control = nx_execute("create_scene", "create_game_control", scene)
  game_control.Player = scene.camera
  game_control.Camera = scene.camera
  game_control.CameraMode = 2
  form.is_move = true
  local story_camera = game_control:GetCameraController(2)
  local ini = get_ini("ini\\form\\book_camera.ini", true)
  story_camera:ClearRoute()
  local time_count = 0
  if ini:FindSection(move_type) then
    local index = ini:FindSectionIndex(move_type)
    local item_value_list = ini:GetItemValueList(index, "r")
    for i, item_list in ipairs(item_value_list) do
      local value_list = util_split_string(item_list, ",")
      time_count = time_count + nx_float(value_list[19])
      story_camera:AddMoveRoute(nx_float(value_list[1]), nx_float(value_list[2]), nx_float(value_list[3]), nx_float(value_list[4]), nx_float(value_list[5]), nx_float(value_list[6]), nx_float(value_list[7]), nx_float(value_list[8]), nx_float(value_list[9]), nx_float(value_list[10]), nx_float(value_list[11]), nx_float(value_list[12]), nx_float(value_list[13]), nx_float(value_list[14]), nx_float(value_list[15]), nx_float(value_list[16]), nx_float(value_list[17]), nx_float(value_list[18]), nx_float(value_list[19]))
    end
  end
  story_camera.StartRouteMove = true
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000 * time_count, 1, nx_current(), "camera_move_end", form, -1, -1)
end
function camera_move_end(form)
  if not nx_is_valid(form) then
    return
  end
  local stage = nx_value("stage")
  if "create" ~= stage then
    return
  end
  local select_npc = form.select_npc
  if nx_is_valid(select_npc) then
    form.groupbox_ani.Visible = true
    form.mltbox_2.Visible = false
    form.mltbox_2.Top = 0 - form.mltbox_2.Height
    form.btn_ok.Visible = true
    local book_info = BOOK_LIST[select_npc.book_id]
    local gui = nx_value("gui")
    form.mltbox_2.HtmlText = nx_widestr(gui.TextManager:GetText(book_info))
    form.mltbox_2.Visible = true
    form.btn_repeat_select.Visible = true
    form.lbl_3.Visible = true
    local asynor = nx_value("common_execute")
    asynor:RemoveExecute("BookText", form.mltbox_2)
    asynor:AddExecute("BookText", form.mltbox_2, nx_float(0))
    local action = nx_value("action_module")
    if not nx_is_valid(select_npc) then
      return
    end
    if not nx_is_valid(action) then
      return
    end
    action:ActionInit(select_npc)
    action:ClearAction(select_npc)
    action:ClearState(select_npc)
    action:BlendAction(select_npc, select_npc.call_action, false, true)
    nx_execute("form_stage_create\\form_select_book", "action_finished", form, select_npc, select_npc.call_action)
    nx_execute("form_stage_create\\form_select_book", "recover_play_dof_info", form)
    nx_execute("form_stage_create\\form_select_book", "set_play_dof_info", form, select_npc)
  else
    local form_select_book = nx_value("form_select_book")
    local scene = nx_value("game_scene")
    local count = form_select_book:GetEffectModelCount()
    for i = 1, count do
      nx_execute("form_stage_create\\create_logic", "put_effectmodel", scene, i - 1)
    end
  end
  set_btn_visible(form, true)
  form.btn_back.Visible = true
  form.is_move = false
end
function set_btn_visible(form, visible)
  form.rbtn_1.Visible = visible and form.rbtn_1.book_vis
  form.rbtn_2.Visible = visible and form.rbtn_2.book_vis
  form.rbtn_3.Visible = visible and form.rbtn_3.book_vis
  form.rbtn_4.Visible = visible and form.rbtn_4.book_vis
  form.rbtn_5.Visible = visible and form.rbtn_5.book_vis
  form.lbl_recommend.Visible = visible
  form.mltbox_tips_1.Visible = false
  form.mltbox_tips_2.Visible = false
end
function link_weapon(actor2, model, item_type)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:SetRoleWeaponName(actor2, nx_string(model))
  role_composite:UseWeapon(actor2, model, 2, nx_int(item_type))
end
function show_skill_action(skill_id, actor2)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  skill_effect:EndShowZhaoshi(actor2, "")
  add_weapon(actor2, skill_id)
  action:ActionInit(actor2)
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "stand", true, true)
  skill_effect:BeginShowZhaoshi(actor2, skill_id)
end
function add_weapon(actor2, skill_name)
  if skill_name == nil then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  if not nx_is_valid(actor2) then
    return false
  end
  role_composite:UnLinkWeapon(actor2)
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  else
    nx_set_custom(actor2, "wuxue_book_set", "")
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, skill_name, "UseLimit", "")
  if LimitIndex == nil or nx_int(LimitIndex) == nx_int(0) then
    return false
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return false
  end
  local ItemType = skill_query:GetSkillWeaponType(nx_int(LimitIndex))
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local weapon_name = get_weapon_name(ItemType)
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  if nx_string(taolu) == "CS_th_bhcs" then
    weapon_name = "flute_thd_002"
  elseif nx_string(taolu) == "CS_xjz_wmcf" then
    weapon_name = "rule_xjz_001"
  end
  game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) or nx_int(set_index) <= nx_int(8) then
    local action_set = nx_string(set_index) .. "h"
    nx_set_custom(actor2, "wuxue_book_set", action_set)
  end
  role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), 2, nx_int(ItemType))
  if nx_int(ItemType) == nx_int(116) then
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::H_weaponR_01", "ini\\npc\\hw_fz001")
    local actor_role = game_visual:QueryActRole(actor2)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    shot_weapon.Visible = false
  end
  game_visual:SetRoleLogicState(actor2, 1)
  return true
end
function get_weapon_name(item_type)
  if item_type == nil then
    return
  end
  if nx_int(item_type) == nx_int(101) then
    return "blade_0024"
  elseif nx_int(item_type) == nx_int(102) then
    return "sword_0020"
  elseif nx_int(item_type) == nx_int(103) then
    return "npcitem392"
  elseif nx_int(item_type) == nx_int(104) then
    return "sblade_00232"
  elseif nx_int(item_type) == nx_int(105) then
    return "ssword_0004"
  elseif nx_int(item_type) == nx_int(106) then
    return "npcitem479"
  elseif nx_int(item_type) == nx_int(107) then
    return "npcitem210"
  elseif nx_int(item_type) == nx_int(108) then
    return "npcitem397"
  end
  return
end
function set_rbtn_stage_photo(group_box, item_type, sex)
  local child_control_list = group_box:GetChildControlList()
  local ini
  local game_config = nx_value("game_config")
  if game_config.login_type == "2" then
    ini = get_ini("ini\\form\\create_form_new.ini", true)
  else
    ini = get_ini("ini\\form\\create_form.ini", true)
  end
  local index = ini:FindSectionIndex(item_type)
  if -1 == index then
    return
  end
  local item_value_list = ini:GetItemValueList(index, "photo")
  for i, rbtn in ipairs(child_control_list) do
    if i < table.getn(item_value_list) + 1 then
      local value_list = util_split_string(item_value_list[i], ";")
      local stage_list = util_split_string(value_list[1 + sex], ",")
      rbtn.AutoSize = true
      rbtn.NormalImage = stage_list[1]
      rbtn.FocusImage = stage_list[2]
      rbtn.CheckedImage = stage_list[3]
      rbtn.DisableImage = stage_list[4]
      if nx_string(item_type) == nx_string("beforehand") and table.getn(value_list) >= 3 then
        rbtn.model_face_id = value_list[3]
      end
    end
  end
end
function set_model_angle(btn, direction, actor)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926 * direction
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    local model = actor
    if nx_is_valid(model) then
      local angle_x = model.AngleX
      local angle_y = model.AngleY
      local angle_z = model.AngleZ
      angle_y = angle_y + dist
      model:SetAngle(angle_x, angle_y, angle_z)
    end
  end
end
function create_effect_model(scene, config_id, is_door, index)
  local model = scene:Create("Model")
  local effectmodel = scene:Create("EffectModel")
  local form_select_book = nx_value("form_select_book")
  local config_id = ""
  local tex_paths = ""
  if is_door == nil or is_door == true then
    config_id = "map\\scene\\login05\\DLJMdamen.xmod"
    tex_paths = "map\\scene\\login05\\DLJMdamen.dds" .. "|" .. "map\\scene\\login05\\DLJMdamen01.dds"
  else
    if nil == index then
      return
    end
    config_id = form_select_book:GetEffectModelResource(index)
    tex_paths = form_select_book:GetEffectModelTexPaths(index)
  end
  model.AsyncLoad = false
  model.ModelFile = config_id
  model.no_light = "no_light"
  model.Visible = true
  model.TexPaths = model:SetPosition(0, 0.1, 0)
  model:Load()
  while not model.LoadFinish do
    nx_pause(0)
  end
  effectmodel.ModelID = model
  model:Play()
  model.Loop = false
  scene:AddObject(effectmodel, 20)
  if is_door == nil or is_door == false then
    form_select_book.DoorModel = effectmodel
  else
    form_select_book:SetEffectModel(index, effectmodel)
  end
  local ini = get_ini("ini\\form\\book_camera.ini", true)
  local index = ini:FindSectionIndex("main")
  if -1 ~= index then
    local item_value_list = ini:GetItemValueList(index, "r")
    local value_list = util_split_string(item_value_list[1], ",")
    local timer = nx_value("timer_game")
    local run_time = nx_number(value_list[table.getn(value_list)] + 1) * 1000
  end
  return effectmodel
end
function put_effectmodel(scene, index)
  local effectmodel_config = "map\\ini\\particles_mdl.ini"
  local effectmodel_name = "E_fire05"
  local effectmodel = scene:Create("EffectModel")
  if not nx_is_valid(effectmodel) then
    return nx_null()
  end
  effectmodel.AsyncLoad = true
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
  effectmodel.name = nx_string(index)
  effectmodel.config = effectmodel_config
  effectmodel.effectmodel_config = effectmodel_config
  effectmodel.effectmodel_name = effectmodel_name
  effectmodel.clip_radius = 0
  effectmodel.WaterReflect = false
  effectmodel.tag = 0
  local form_select_book = nx_value("form_select_book")
  form_select_book:SetEffectModel(index, effectmodel)
  scene:AddObject(effectmodel, 20)
  local helper_list = effectmodel:GetHelperNameList()
  return effectmodel
end
function start_play_open_door(effectmodel)
  local form = nx_value("form_stage_create\\form_select_book")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(effectmodel) then
    return
  end
  local model = effectmodel.ModelID
  if not nx_is_valid(model) then
    return
  end
  model:Play()
  model.Loop = false
end
function start_animation(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local animation = create_animation(form, index)
  if not nx_is_valid(animation) then
    return 0
  end
  animation:Stop()
  animation:Play()
  local animation_info = get_step_info(index)
  if animation_info == nil then
    return 0
  end
  local count = (table.getn(animation_info) - 4) / 2
  if count <= 0 then
    return 0
  end
  local created_table = {}
  local real_time_count = 0
  while true do
    local all_create = true
    local base_index = 4
    for i = 1, count do
      if created_table[base_index + i] == nil or not created_table[base_index + i] then
        if real_time_count * 1000 >= nx_number(animation_info[base_index + i * 2]) then
          nx_execute(nx_current(), "start_animation", form, nx_int(animation_info[base_index + i * 2 - 1]))
          created_table[base_index + i] = true
        else
          all_create = false
        end
      end
    end
    if all_create then
      break
    end
    real_time_count = real_time_count + nx_pause(0)
  end
end
function create_animation(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local animation_info = get_step_info(index)
  if animation_info == nil then
    return
  end
  if table.getn(animation_info) < 4 then
    return
  end
  local animation = gui:Create("Animation")
  form:Add(animation)
  animation.Visible = false
  animation.Left = animation_info[2]
  animation.Top = animation_info[3]
  animation.AnimationImage = animation_info[1]
  if string.find(animation_info[1], "Login_Finish_Step") ~= nil then
    form:ToFront(animation)
  end
  local flag = animation_info[4]
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "animation_event_end")
  animation.Visible = true
  animation.index = index
  return animation
end
function get_step_info(step)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\animation\\create_role.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local ani_info_str = ini:ReadString("create_role_animation", nx_string(step), "")
  if ani_info_str == "" then
    return
  end
  return nx_function("ext_split_string", ani_info_str, ",")
end
function animation_event_end(animation, ani_name, mode)
  if not nx_is_valid(animation) then
    return 1
  end
  local form = animation.ParentForm
  local index = animation.index
  local animation_info = get_step_info(index)
  if animation_info == nil then
    return 1
  end
  if "Login_Finish_Step6" == ani_name then
  end
  if nx_is_valid(animation) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui:Delete(animation)
    else
      local world = nx_value("world")
      if nx_is_valid(world) then
        world:Delete(animation)
      end
    end
  end
end
