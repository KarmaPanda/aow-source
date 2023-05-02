require("util_functions")
require("define\\object_type_define")
local diff_name_table = {
  "Scale",
  "ContextID",
  "EffectID"
}
local INI_FILE_NAME = "share\\Rule\\add_special_ability.ini"
function get_npc_script_type(client_scene_obj)
  local config = client_scene_obj:QueryProp("ConfigID")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(config))
  if not bExist then
    return ""
  end
  local script = ItemQuery:GetItemPropByConfigID(nx_string(config), nx_string("script"))
  return nx_string(script)
end
function on_special_id_change(client_scene_obj, special_prop_id)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return false
  end
  local object_type = nx_number(client_scene_obj:QueryProp("Type"))
  if TYPE_NPC == object_type and "PlayActNpc" == get_npc_script_type(client_scene_obj) and nx_int(special_prop_id) == nx_int(101) then
    local head_game = nx_value("HeadGame")
    if nx_is_valid(head_game) then
      head_game:ShowHead(visual_scene_obj, false)
    end
  end
  if nx_int(special_prop_id) <= nx_int(0) then
    get_default_set(visual_scene_obj)
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", INI_FILE_NAME)
  if not nx_is_valid(ini) then
    get_default_set(visual_scene_obj)
    return false
  end
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not ini:FindSection(nx_string(special_prop_id)) then
    get_default_set(visual_scene_obj)
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(special_prop_id))
  if sec_index < 0 then
    return
  end
  local str_scale = ini:ReadString(sec_index, nx_string("Scale"), "")
  if str_scale ~= 0 and str_scale ~= "" and str_scale ~= nil then
    local scalelist = util_split_string(str_scale, ",")
    local size = table.getn(scalelist)
    if size == 3 then
      local scale_x = nx_float(scalelist[1])
      local scale_y = nx_float(scalelist[2])
      local scale_z = nx_float(scalelist[3])
      if nx_number(scale_x) > 0 and nx_number(scale_y) > 0 and nx_number(scale_z) > 0 then
        visual_scene_obj:SetScale(nx_float(scale_x), nx_float(scale_y), nx_float(scale_z))
      else
        visual_scene_obj:SetScale(nx_float(1), nx_float(1), nx_float(1))
      end
    else
      visual_scene_obj:SetScale(nx_float(1), nx_float(1), nx_float(1))
    end
  else
    visual_scene_obj:SetScale(nx_float(1), nx_float(1), nx_float(1))
  end
  local str_color = ini:ReadString(sec_index, "ModelColor", "")
  if str_color ~= 0 and str_color ~= "" and str_color ~= nil then
    local colorlist = util_split_string(str_color, ",")
    local size = table.getn(colorlist)
    if size == 4 then
      visual_scene_obj.Color = nx_string(str_color)
    else
      visual_scene_obj.Color = nx_string("255,255,255,255")
    end
  else
    visual_scene_obj.Color = nx_string("255,255,255,255")
  end
  local old_effect = visual_scene_obj.special_effect
  if old_effect ~= nil and old_effect ~= 0 and old_effect ~= "" then
    nx_execute("game_effect", "remove_effect", nx_string(old_effect), visual_scene_obj, visual_scene_obj)
    visual_scene_obj.special_effect = ""
  end
  local str_effect = ini:ReadString(sec_index, "EffectID", "")
  if str_effect ~= 0 and str_effect ~= "" and str_effect ~= nil then
    create_effect(nx_string(str_effect), visual_scene_obj, visual_scene_obj, "", "", "", "", "", true)
    visual_scene_obj.special_effect = nx_string(str_effect)
  end
  local str_context = ini:ReadString(sec_index, "ContextID", "")
  if str_context ~= 0 and str_context ~= "" and str_context ~= nil then
    visual_scene_obj.special_descid = nx_string(str_context)
  else
    visual_scene_obj.special_descid = ""
  end
  local last_obj = nx_value("game_select_obj")
  if nx_is_valid(last_obj) and nx_id_equal(last_obj, client_scene_obj) then
    nx_execute("form_stage_main\\form_main\\form_main_select", "show_selectobj_form", client_scene_obj)
  end
  return true
end
function create_effect(effect_name, self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
  if effect_name == nil or nx_string(effect_name) == nx_string("") or nx_string(effect_name) == nx_string("nil") then
    return false
  end
  if not nx_is_valid(self) then
    return false
  end
  local scene = self.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect) then
    return false
  end
  if not nx_is_valid(game_effect.Scene) then
    game_effect.Scene = scene
  end
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  return game_effect:CreateEffect(nx_string(effect_name), self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
end
function get_default_set(visual_scene_obj)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  visual_scene_obj:SetScale(nx_float(1), nx_float(1), nx_float(1))
  visual_scene_obj.Color = nx_string("255,255,255,255")
  local old_effect = visual_scene_obj.special_effect
  if old_effect ~= nil and old_effect ~= 0 and old_effect ~= "" then
    nx_execute("game_effect", "remove_effect", nx_string(old_effect), visual_scene_obj, visual_scene_obj)
    visual_scene_obj.special_effect = ""
  end
  visual_scene_obj.special_descid = ""
  nx_execute("form_stage_main\\form_main\\form_main_select", "show_selectobj_form", client_scene_obj)
end
