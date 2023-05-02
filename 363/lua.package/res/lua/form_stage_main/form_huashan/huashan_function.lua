require("form_stage_main\\form_huashan\\huashan_define")
require("util_functions")
require("util_gui")
require("role_composite")
function self_SpriteManager(form, type, text)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "canshowsprite") then
    return
  end
  if not form.canshowsprite then
    return
  end
  if not nx_is_valid(form.player) then
    return
  end
  local SpriteManager = nx_value("SpriteManager")
  if not nx_is_valid(SpriteManager) then
    return
  end
  SpriteManager:ShowBallFormModelPos(nx_string(type), nx_string(text), form.player.Ident, "")
end
function get_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  local scene = game_client:GetScene()
  if not nx_is_valid(scene) then
    return nx_null()
  end
  return scene
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_null()
  end
  return client_player
end
function self_systemcenterinfo(msgid)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text(nx_string(msgid))), 2)
  end
end
function self_systemcenterinfos(msg)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(msg), 2)
  end
end
function get_name(name)
  local str = nx_widestr(name)
  if str == nx_widestr(m_Name_NULL) then
    local gui = nx_value("gui")
    str = gui.TextManager:GetText(m_Name_NULL)
  end
  return str
end
function change_action(scenebox, action)
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "model") then
    return
  end
  local actor2 = scene.model
  if not nx_is_valid(actor2) then
    return
  end
  local action_module = nx_value("action_module")
  if not nx_is_valid(action_module) then
    return
  end
  local isExists = action_module:ActionExists(actor2, action)
  if not isExists then
    return
  end
  local is_in_list = action_module:ActionBlended(actor2, action)
  if not is_in_list then
    action_module:BlendAction(actor2, action, true, true)
  end
end
function do_once_action(scenebox, action)
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "model") then
    return
  end
  local actor2 = scene.model
  if not nx_is_valid(actor2) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) then
    skill_effect:BeginShowZhaoshi(actor2, action)
  end
end
function add_player_model(scenebox, role_info_obj)
  if not nx_is_valid(scenebox) or not nx_is_valid(role_info_obj) then
    return false
  end
  local body_type = 0
  if nx_find_custom(role_info_obj, "body_type") then
    body_type = nx_number(role_info_obj.body_type)
  end
  local actor2 = create_role_composite(scenebox.Scene, true, role_info_obj.sex, "stand", body_type)
  if not nx_is_valid(actor2) then
    return false
  end
  while nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local body_face = 0
  if nx_find_custom(role_info_obj, "body_face") then
    body_face = nx_number(role_info_obj.body_face)
  end
  if 0 < body_face then
    role_composite:LinkFaceSkin(actor2, role_info_obj.sex, body_face, false)
  end
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  local skin_info = {
    [1] = {
      link_name = "mask",
      model_name = role_info_obj.mask
    },
    [2] = {
      link_name = "hat",
      model_name = role_info_obj.hat
    },
    [3] = {
      link_name = "cloth",
      model_name = role_info_obj.cloth
    },
    [4] = {
      link_name = "pants",
      model_name = role_info_obj.pants
    },
    [5] = {
      link_name = "shoes",
      model_name = role_info_obj.shoes
    },
    [6] = {
      link_name = "mantle",
      model_name = role_info_obj.mantle
    }
  }
  local effect_info = {
    [1] = {
      link_name = "WeaponEffect",
      model_name = role_info_obj.weaponeffect
    },
    [2] = {
      link_name = "MaskEffect",
      model_name = role_info_obj.maskeffect
    },
    [3] = {
      link_name = "HatEffect",
      model_name = role_info_obj.hateffect
    },
    [4] = {
      link_name = "ClothEffect",
      model_name = role_info_obj.clotheffect
    },
    [5] = {
      link_name = "PantsEffect",
      model_name = role_info_obj.pantseffect
    },
    [6] = {
      link_name = "ShoesEffect",
      model_name = role_info_obj.shoeseffect
    },
    [7] = {
      link_name = "MantleEffect",
      model_name = role_info_obj.mantleeffect
    }
  }
  for i, info in pairs(skin_info) do
    if 0 < string.len(nx_string(info.model_name)) then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  if nx_int(1) == nx_int(role_info_obj.show_equip_type) then
    link_skin(actor2, "cloth_h", nx_string(nx_string(role_info_obj.cloth) .. "_h" .. ".xmod"))
  end
  for i, info in pairs(effect_info) do
    if model_name ~= nil and model_name ~= null then
      link_effect(actor2, info.link_name, info.model_name)
    end
  end
  if role_info_obj.weapon ~= "" then
    actor2.weapon_name = role_info_obj.weapon
    refresh_weapon_position(actor2)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", scenebox, actor2)
  return true
end
function analysis_role_info(role_info, arraylist_obj)
  if "" == role_info or not nx_is_valid(arraylist_obj) then
    return false
  end
  local role_info_table = nx_function("ext_split_string", nx_string(role_info), ",")
  if table.getn(role_info_table) < 24 then
    return false
  end
  nx_set_custom(arraylist_obj, "sex", nx_number(role_info_table[1]))
  nx_set_custom(arraylist_obj, "face", role_info_table[6])
  local offset = get_offset(role_info_table)
  nx_set_custom(arraylist_obj, "show_equip_type", role_info_table[7 + offset])
  nx_set_custom(arraylist_obj, "hat", role_info_table[8 + offset])
  nx_set_custom(arraylist_obj, "mask", role_info_table[9 + offset])
  nx_set_custom(arraylist_obj, "cloth", role_info_table[10 + offset])
  nx_set_custom(arraylist_obj, "pants", role_info_table[11 + offset])
  nx_set_custom(arraylist_obj, "shoes", role_info_table[12 + offset])
  nx_set_custom(arraylist_obj, "weapon", role_info_table[13 + offset])
  nx_set_custom(arraylist_obj, "mantle", role_info_table[14 + offset])
  nx_set_custom(arraylist_obj, "hateffect", role_info_table[15 + offset])
  nx_set_custom(arraylist_obj, "maskeffect", role_info_table[16 + offset])
  nx_set_custom(arraylist_obj, "clotheffect", role_info_table[17 + offset])
  nx_set_custom(arraylist_obj, "pantseffect", role_info_table[18 + offset])
  nx_set_custom(arraylist_obj, "shoeseffect", role_info_table[19 + offset])
  nx_set_custom(arraylist_obj, "weaponeffect", role_info_table[20 + offset])
  nx_set_custom(arraylist_obj, "mantleeffect", role_info_table[21 + offset])
  nx_set_custom(arraylist_obj, "action_set", role_info_table[22 + offset])
  nx_set_custom(arraylist_obj, "level_title", role_info_table[24 + offset])
  nx_set_custom(arraylist_obj, "body_type", role_info_table[37 + offset])
  nx_set_custom(arraylist_obj, "body_face", role_info_table[38 + offset])
  return true
end
function get_offset(role_info_table)
  local face = role_info_table[6]
  local count = table.getn(role_info_table)
  local offset = 0
  for i = 7, count do
    if string.len(face) > 46 or string.len(face) == 46 then
      return offset
    end
    face = face .. string.char(44) .. role_info_table[i]
    offset = offset + 1
  end
  return offset
end
