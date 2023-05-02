require("share\\itemtype_define")
require("share\\view_define")
require("share\\static_data_type")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function get_prop_in_object(object, prop)
  if object == nil or object == "" or not nx_is_valid(object) then
    return ""
  end
  local value = ""
  if nx_name(object) == "ArrayList" then
    if nx_find_custom(object, prop) then
      value = nx_custom(object, prop)
    end
  elseif object:FindProp(prop) then
    value = object:QueryProp(prop)
  end
  return value
end
function query_equip_photo_by_sex(object)
  local photo = "Photo"
  local game_client = nx_value("game_client")
  local client_palyer = game_client:GetPlayer()
  local sex = 0
  if nx_is_valid(client_palyer) then
    sex = client_palyer:QueryProp("Sex")
  end
  if 0 ~= sex then
    photo = "FemalePhoto"
  end
  local value = get_prop_in_object(object, photo)
  if nil ~= value then
    if "" ~= nx_string(value) then
      return value
    else
      value = get_prop_in_object(object, "Photo")
      if nil ~= value and "" ~= nx_string(value) then
        return value
      end
    end
  end
  local item_query = nx_value("ItemQuery")
  if nx_is_valid(item_query) then
    local id = get_prop_in_object(object, "ConfigID")
    if nil ~= id then
      local value = item_query:GetItemPropByConfigID(id, photo)
      if nil ~= value then
        if "" ~= nx_string(value) then
          return value
        else
          value = item_query:GetItemPropByConfigID(id, "Photo")
          if nil ~= value and "" ~= nx_string(value) then
            return value
          end
        end
      end
    end
  end
  table_type = STATIC_DATA_ITEM_ART
  static_data = get_prop_in_object(object, "ArtPack")
  local item_type = get_prop_in_object(object, "ItemType")
  if nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) then
    local replacepack = get_prop_in_object(object, "ReplacePack")
    if nx_int(replacepack) > nx_int(0) then
      static_data = replacepack
      local replace_id = get_prop_in_object(object, "ReplaceID")
      if nx_is_valid(item_query) then
        local logic_pack_id = item_query:GetItemPropByConfigID(replace_id, "LogicPack")
        local use_sex = item_static_query(nx_int(logic_pack_id), "UseSex", STATIC_DATA_ITEM_LOGIC)
        if nx_int(1) == nx_int(use_sex) then
          photo = "Photo"
        elseif nx_int(2) == nx_int(use_sex) then
          photo = "FemalePhoto"
        end
      end
    end
  end
  local data_query = nx_value("data_query_manager")
  if nx_is_valid(data_query) then
    if "" == nx_string(data_query:Query(table_type, static_data, photo)) then
      photo = "Photo"
    end
    return data_query:Query(table_type, nx_int(static_data), photo)
  end
end
function queryprop_by_object(object, prop_name)
  local item_type = get_prop_in_object(object, "ItemType")
  if ITEMTYPE_EQUIP_MIN <= nx_number(item_type) and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX and "Photo" == prop_name then
    return query_equip_photo_by_sex(object)
  end
  local value = get_prop_in_object(object, prop_name)
  if value ~= nil and nx_string(value) ~= "" then
    return value
  end
  local item_query = nx_value("ItemQuery")
  if nx_is_valid(item_query) then
    local id = get_prop_in_object(object, "ConfigID")
    if id ~= nil then
      local value = item_query:GetItemPropByConfigID(id, prop_name)
      if value ~= nil and value ~= "" then
        return value
      end
    end
  end
  local table_type = STATIC_DATA_ITEM_ART
  local item_type = get_prop_in_object(object, "ItemType")
  local static_data = get_prop_in_object(object, "StaticData")
  if item_type == ITEMTYPE_ZHAOSHI or item_type == ITEMTYPE_LOCKZHAOAHI then
    table_type = STATIC_DATA_SKILL_STATIC
  elseif item_type == ITEMTYPE_NEIGONG then
    table_type = STATIC_DATA_NEIGONG
  elseif item_type == ITEMTYPE_JINGMAI then
    table_type = STATIC_DATA_JINGMAI
  elseif item_type == ITEMTYPE_QINGGONG then
    table_type = STATIC_DATA_QGSKILL
  elseif item_type == ITEMTYPE_ZHENFA then
    table_type = STATIC_DATA_ZHENFA
  elseif item_type == ITEMTYPE_ANQI_SHOUFA then
    table_type = STATIC_DATA_SHOUFA
  else
    table_type = STATIC_DATA_ITEM_ART
    static_data = get_prop_in_object(object, "ArtPack")
  end
  local data_query = nx_value("data_query_manager")
  if nx_is_valid(data_query) then
    return data_query:Query(table_type, static_data, prop_name)
  end
end
function queryprop_by_proptable(prop_table, prop_name)
  local value = prop_table[prop_name]
  if value ~= nil and nx_string(value) ~= "" then
    return value
  end
  local item_query = nx_value("ItemQuery")
  if nx_is_valid(item_query) then
    local id = prop_table.ConfigID
    if id ~= nil then
      local value = item_query:GetItemPropByConfigID(id, prop_name)
      if value ~= nil and value ~= "" then
        return value
      end
    end
  end
  local table_type = STATIC_DATA_ITEM_ART
  local item_type = prop_table.ItemType
  local static_data = prop_table.StaticData
  if item_type == ITEMTYPE_ZHAOSHI or item_type == ITEMTYPE_LOCKZHAOAHI then
    table_type = STATIC_DATA_SKILL_STATIC
  elseif item_type == ITEMTYPE_NEIGONG then
    table_type = STATIC_DATA_NEIGONG
  elseif item_type == ITEMTYPE_QINGGONG then
    table_type = STATIC_DATA_QGSKILL
  elseif item_type == ITEMTYPE_ZHENFA then
    table_type = STATIC_DATA_ZHENFA
  elseif item_type == ITEMTYPE_ANQI_SHOUFA then
    table_type = STATIC_DATA_SHOUFA
  else
    table_type = STATIC_DATA_ITEM_ART
    static_data = prop_table.ArtPack
  end
  local data_query = nx_value("data_query_manager")
  if nx_is_valid(data_query) then
    return data_query:Query(table_type, static_data, prop_name)
  end
end
function skill_static_query(static_data, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_SKILL_STATIC, static_data, prop_name)
end
function skill_static_query_by_id(skill_id, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager("share\\Skill\\skill_new.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(skill_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  return data_query:Query(STATIC_DATA_SKILL_STATIC, nx_int(static_data), prop_name)
end
function neigong_static_query(static_data, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_NEIGONG, nx_int(static_data), prop_name)
end
function neigong_static_query_by_id(neigong_id, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local view = game_client:GetView(nx_string(VIEWPORT_NEIGONG))
  if not nx_is_valid(view) then
    return ""
  end
  local viewobj_list = view:GetViewObjList()
  local count = table.maxn(viewobj_list)
  for i = 1, count do
    local ng_obj = viewobj_list[i]
    local tempid = ng_obj:QueryProp("ConfigID")
    if tempid == neigong_id then
      return data_query:Query(STATIC_DATA_NEIGONG, ng_obj:QueryProp("StaticData"), prop_name), ng_obj
    end
  end
  return ""
end
function qgskill_static_query(static_data, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_QGSKILL, nx_int(static_data), prop_name)
end
function qgskill_static_query_by_id(qgskill_id, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager("share\\Skill\\qinggong\\QGSkill.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(qgskill_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  return data_query:Query(STATIC_DATA_QGSKILL, nx_int(static_data), prop_name)
end
function shoufa_static_query(static_data, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_SHOUFA, nx_int(static_data), prop_name)
end
function shoufa_static_query_by_id(shoufa_id, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager("share\\Skill\\shoufa\\shoufa.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(shoufa_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  return data_query:Query(STATIC_DATA_SHOUFA, nx_int(static_data), prop_name)
end
function zhenfa_static_query(static_data, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_ZHENFA, nx_int(static_data), prop_name)
end
function zhenfa_static_query_by_id(zhenfa_id, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager("share\\Skill\\zhenfa.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(zhenfa_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  return data_query:Query(STATIC_DATA_ZHENFA, nx_int(static_data), prop_name)
end
function jingmai_static_query(static_data, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_JINGMAI, nx_int(static_data), prop_name)
end
function xuewei_static_query(static_data, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_XUEWEI, static_data, prop_name)
end
function xuewei_static_query_by_id(xuewei_id, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager("share\\Skill\\xuewei\\xuewei.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(xuewei_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  return data_query:Query(STATIC_DATA_XUEWEI, static_data, prop_name)
end
function item_query_LearnSkillPack(configid, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local row = nx_int(item_query:GetItemPropByConfigID(configid, "LearnSkillPack"))
  return item_static_query(row, prop, STATIC_DATA_ITEM_LEARNSKILL)
end
function buff_static_query(buff_id, prop_name)
  local data_query_manager = nx_value("data_query_manager")
  if not nx_is_valid(data_query_manager) then
    return ""
  end
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return ""
  end
  local ini = IniManager:LoadIniToManager("share\\Skill\\buff_new.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(buff_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, nx_string("StaticData"), "")
  return data_query_manager:Query(STATIC_DATA_BUFF, nx_int(static_data), prop_name)
end
function flow_static_query(static_data, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_SKILL_FLOW, static_data, prop_name)
end
function zhenfa_skill_static_query(zhenfaskill, prop_name)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(STATIC_DATA_ZHENFA_SKILL, nx_int(zhenfaskill), prop_name)
end
function item_static_query(static_data, prop_name, class_type)
  class_type = class_type or STATIC_DATA_ITEM_ART
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  return data_query:Query(class_type, static_data, prop_name)
end
function item_query_ArtPack(item, prop)
  local pack_no = item:QueryProp("ArtPack")
  if item:FindProp("ReplacePack") then
    local id = item:QueryProp("ReplacePack")
    if id ~= nil and 0 < id then
      pack_no = id
    end
  end
  if item:FindProp(prop) then
    local value = item:QueryProp(prop)
    if value ~= nil and nx_string(value) ~= "" then
      return value
    end
  end
  local item_query = nx_value("ItemQuery")
  if nx_is_valid(item_query) then
    local id = item:QueryProp("ConfigID")
    if id ~= nil then
      local value = item_query:GetItemPropByConfigID(id, prop)
      if value ~= nil and value ~= "" then
        return value
      end
    end
  end
  return item_static_query(pack_no, prop, STATIC_DATA_ITEM_ART)
end
function item_query_LogicPack(item, prop)
  return item_static_query(item:QueryProp("LogicPack"), prop, STATIC_DATA_ITEM_LOGIC)
end
function item_query_UseSkillPack(item, prop)
  return item_static_query(item:QueryProp("UseSkillPack"), prop, STATIC_DATA_ITEM_USESKILL)
end
function item_query_FuncPack(item, prop)
  return item_static_query(item:QueryProp("FuncPack"), prop, STATIC_DATA_ITEM_FUNC)
end
function item_query_ArtPack_by_id(id, prop, sex)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local value = item_query:GetItemPropByConfigID(id, prop)
  if value ~= nil and value ~= "" then
    return value
  end
  local row = nx_int(item_query:GetItemPropByConfigID(id, "ArtPack"))
  local item_type = item_query:GetItemPropByConfigID(id, "ItemType")
  if sex == nil then
    sex = 0
    local game_client = nx_value("game_client")
    local client_palyer = game_client:GetPlayer()
    if nx_is_valid(client_palyer) then
      sex = client_palyer:QueryProp("Sex")
    end
  end
  if ITEMTYPE_EQUIP_MIN <= nx_number(item_type) and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX and "Photo" == prop and 0 ~= sex then
    prop = "FemalePhoto"
    local result = item_static_query(row, prop, STATIC_DATA_ITEM_ART)
    if "" == result then
      prop = "Photo"
    end
  end
  return item_static_query(row, prop, STATIC_DATA_ITEM_ART)
end
function item_query_ArtPack_by_id_Ex(id, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local row = nx_int(item_query:GetItemPropByConfigID(id, "ArtPack"))
  return item_static_query(row, prop, STATIC_DATA_ITEM_ART)
end
function item_query_ActivatePack_by_id(configid, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local row = nx_int(item_query:GetItemPropByConfigID(configid, "ActivatePack"))
  return item_static_query(row, prop, STATIC_DATA_EQUIP_ACTIVATE)
end
