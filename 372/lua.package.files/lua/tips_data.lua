require("share\\static_data_type")
require("share\\itemtype_define")
require("define\\tip_define")
require("util_functions")
function get_prop_in_item(item, prop)
  local value = ""
  if item == nil or item == "" or not nx_is_valid(item) then
    return value
  end
  if nx_find_custom(item, "is_static") then
    if nx_name(item) == "ArrayList" then
      if nx_find_custom(item, prop) then
        return nx_custom(item, prop)
      end
    elseif nx_find_custom(item, "ConfigID") then
      return get_prop_by_configid(nx_custom(item, "ConfigID"), prop)
    end
  end
  if nx_name(item) == "ArrayList" then
    if nx_find_custom(item, prop) then
      value = nx_custom(item, prop)
    end
  elseif item:FindProp(prop) then
    value = item:QueryProp(prop)
  end
  return value
end
function get_prop_in_ItemQuery(config_id, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local value = item_query:GetItemPropByConfigID(nx_string(config_id), nx_string(prop))
  return value
end
function get_prop_in_ItemAndItemQuery(item, config_id, prop)
  local value = ""
  value = get_prop_in_item(item, prop)
  if value ~= nil and value ~= "" then
    return value
  end
  if config_id == nil or config_id == "" then
    config_id = get_prop_in_item(item, "ConfigID")
  end
  value = get_prop_in_ItemQuery(config_id, prop)
  return value
end
function get_prop_table_in_ItemQuery(config_id, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  if not nx_find_method(item_query, "GetItemPropValueArrayByConfigID") then
    return ""
  end
  local proptable = ""
  proptable = item_query:GetItemPropValueArrayByConfigID(config_id, nx_string(prop))
  return proptable
end
function get_prop_in_static_query(STATIC_TYPE, static_data_id, prop_name)
  local data_query = nx_value("data_query_manager")
  if nx_is_valid(data_query) then
    return data_query:Query(nx_int(STATIC_TYPE), nx_int(static_data_id), prop_name)
  else
    nx_msgbox(get_msg_str("msg_454"))
  end
  return ""
end
function get_item_in_view(view_id, config_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return nil
  end
  local item_lst = view:GetViewObjList()
  local find_item
  for i, item in pairs(item_lst) do
    if config_id == item:QueryProp("ConfigID") then
      find_item = item
      return find_item
    end
  end
  return find_item
end
function get_prop_in_static_by_type(item_type, static_data_id, prop)
  local Data_Type = STATIC_DATA_ITEM_ART
  if item_type == "" or item_type == nil then
    return ""
  end
  if item_type == ITEMTYPE_ZHAOSHI or item_type == ITEMTYPE_LOCKZHAOAHI then
    Data_Type = STATIC_DATA_SKILL_STATIC
  elseif item_type == ITEMTYPE_NEIGONG then
    Data_Type = STATIC_DATA_NEIGONG
  elseif item_type == ITEMTYPE_QINGGONG then
    Data_Type = STATIC_DATA_QGSKILL
  else
    Data_Type = STATIC_DATA_ITEM_ART
    static_data_id = get_prop_in_item(item, "ArtPack")
  end
  return get_prop_in_static_query(Data_Type, static_data_id, prop)
end
function get_prop_by_configid(config_id, prop)
  local value = get_prop_in_ItemQuery(config_id, prop)
  if value ~= nil and value ~= "" then
    return value
  end
  local item_type = get_prop_in_ItemQuery(config_id, nx_string("ItemType"))
  local static_data_id = get_prop_in_ItemQuery(item, "StaticData")
  return get_prop_in_static_by_type(item_type, static_data_id, prop)
end
function get_prop_in_All(item, prop)
  local value = get_prop_in_item(item, prop)
  if value ~= nil and value ~= "" then
    return value
  end
  local config_id = get_prop_in_item(item, "ConfigID")
  local item_type = get_prop_in_ItemQuery(config_id, nx_string("ItemType"))
  if item_type == "" or item_type == nil then
    item_type = get_prop_in_item(item, nx_string("ItemType"))
  end
  local Data_Type = STATIC_DATA_ITEM_ART
  local static_data_id = get_prop_in_item(item, "StaticData")
  return get_prop_in_static_by_type(item_type, static_data_id, prop)
end
function get_ini_safe(ini_file)
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return nil
  end
  local ini
  if not IniManager:IsIniLoadedToManager(ini_file) then
    ini = IniManager:LoadIniToManager(ini_file)
  else
    ini = IniManager:GetIniDocument(ini_file)
  end
  if not nx_is_valid(ini) then
    return nil
  end
  return ini
end
function get_ini_prop(ini_file, section, prop, default)
  section = nx_string(section)
  local ini = get_ini_safe(ini_file)
  if not nx_is_valid(ini) then
    return ""
  end
  if not ini:FindSection(section) then
    return default
  end
  local sec_index = ini:FindSectionIndex(section)
  local value = ""
  if 0 <= sec_index then
    value = ini:ReadString(sec_index, nx_string(prop), nx_string(default))
  end
  return value
end
function query_INI_by_type(item, configid)
  local ini_file = ""
  local item_type = get_prop_in_ItemQuery(configid, nx_string("ItemType"))
  if item_type == "" or item_type == nil then
    item_type = get_prop_in_item(item, nx_string("ItemType"))
  end
  if item_type == "" or item_type == nil then
    return ""
  end
  item_type = nx_number(item_type)
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    ini_file = _EQUIP_INI
  elseif item_type >= nx_number(1) and item_type <= nx_number(99) then
    ini_file = _GOODS_INI
  elseif item_type == ITEMTYPE_ZAWU then
    ini_file = _GOODS_INI
  elseif item_type > ITEMTYPE_COMPOSE_MATRIAL_MIN and item_type < ITEMTYPE_COMPOSE_MATRIAL_MAX then
    ini_file = _GOODS_INI
  end
  return ini_file
end
function get_text_by_color(text, color)
  if nx_ws_length(nx_widestr(text)) < 1 then
    return ""
  end
  local _begin = nx_widestr("<font color=\"") .. nx_widestr(color) .. nx_widestr("\">")
  local _end = nx_widestr("</font>")
  text = nx_widestr(_begin) .. nx_widestr(text) .. nx_widestr(_end)
  return text
end
function get_photo_html(photo)
  local _begin = "<img src=\"" .. nx_string(photo)
  local _end = "\" only=\"line\" valign=\"center\" />"
  local text = nx_string(_begin) .. nx_string(_end)
  return text
end
function link_title_value(title, value, br, title_color, value_color)
  if title == "" or title == nil or value == "" or value == nil then
    return nx_widestr("")
  end
  if br == "" or br == nil then
    br = false
  end
  title = nx_string(title)
  value = nx_string(value)
  local out_text = nx_widestr("")
  if nx_ws_length(nx_widestr(value)) > 0 then
    if nx_string(title_color) == "" or title_color == nil then
      title_color = COLOR_Title
    end
    if nx_string(value_color) == "" or value_color == nil then
      value_color = COLOR_Value
    end
    out_text = nx_widestr(get_text_by_color(title, title_color))
    if br then
      out_text = out_text .. nx_widestr("<br>")
    end
    out_text = out_text .. nx_widestr(get_text_by_color(value, value_color))
  end
  return out_text
end
function get_item_obj(item)
  local obj = get_prop_in_item(item, "view_obj")
  if not nx_is_valid(obj) then
    obj = item
    if not nx_is_valid(obj) then
      return nil
    end
  end
  return obj
end
function get_exp_from_package(exp_package)
  if nx_number(exp_package) < 0 then
    return "", 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "", 0
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\LifeExpInfo.ini")
  if not nx_is_valid(ini) then
    return "", 0
  end
  if ini:FindSection(nx_string(exp_package)) then
    local sec_index = ini:FindSectionIndex(nx_string(exp_package))
    if sec_index < 0 then
      nx_log("share\\Life\\LifeExpInfo.ini sec_index= " .. nx_string(exp_package))
      return "", 0
    end
    local exp_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    for i = 1, table.getn(exp_table) do
      local exp_info = exp_table[i]
      local info_lst = util_split_string(exp_info, ",")
      if table.getn(info_lst) >= 8 then
        local res1 = false
        local res2 = false
        local row = client_player:FindRecordRow("job_rec", 0, info_lst[1], 0)
        if 0 <= row then
          local job_level = client_player:QueryRecord("job_rec", row, 1)
          res1 = cmp_level_with_op(info_lst[2], job_level, info_lst[3])
        end
        row = client_player:FindRecordRow("job_rec", 0, info_lst[4], 0)
        if 0 <= row then
          local job_level = client_player:QueryRecord("job_rec", row, 1)
          res2 = cmp_level_with_op(info_lst[5], job_level, info_lst[6])
        end
        if res1 and res2 then
          return info_lst[7], info_lst[8]
        end
      end
    end
  end
  return "", 0
end
function cmp_level_with_op(op, cur_level, cmp_val)
  if nx_string(op) == nil or nx_string(op) == "" then
    return false
  end
  cur_level = nx_int(cur_level)
  cmp_val = nx_int(cmp_val)
  if nx_string(op) == ">=" then
    if cur_level >= cmp_val then
      return true
    end
  elseif nx_string(op) == "<=" then
    if cur_level <= cmp_val then
      return true
    end
  elseif nx_string(op) == "=" or nx_string(op) == "==" then
    if cur_level == cmp_val then
      return true
    end
  elseif nx_string(op) == ">" then
    if cur_level > cmp_val then
      return true
    end
  elseif nx_string(op) == "<" and cur_level < cmp_val then
    return true
  end
  return false
end
function get_tool_from_limited(toollimited)
  if nx_number(toollimited) < 0 then
    return ""
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\LifeToolLimitInfo.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local tool_table
  if ini:FindSection(nx_string(toollimited)) then
    local sec_index = ini:FindSectionIndex(nx_string(toollimited))
    if sec_index < 0 then
      nx_log("share\\Life\\LifeToolLimitInfo.ini sec_index= " .. nx_string(toollimited))
      return ""
    end
    local tool_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    for i = 1, table.getn(tool_table) do
      local tool_info = tool_table[i]
      local info_lst = util_split_string(tool_info, ",")
      if table.getn(info_lst) == 3 then
        table.insert(tool_table, info_lst[1])
      end
    end
    for i = 1, table.getn(tool_table) do
      local tool_id = tool_table[i]
      if nx_string(tool_id) ~= "" then
        local view_id = ""
        local goods_grid = nx_value("GoodsGrid")
        if nx_is_valid(goods_grid) then
          view_id = goods_grid:GetToolBoxViewport(nx_string(tool_id))
        end
        local view = game_client:GetView(nx_string(view_id))
        if nx_is_valid(view) then
          local viewobj_list = view:GetViewObjList()
          for j, obj in pairs(viewobj_list) do
            local tempid = obj:QueryProp("ConfigID")
            if tempid == tool_id then
              return tool_id
            end
          end
        end
      end
    end
  end
  return ""
end
function life_tool_limit_check(toollimited)
  if nx_number(toollimited) < 0 then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\LifeToolLimitInfo.ini")
  if not nx_is_valid(ini) then
    return false
  end
  if ini:FindSection(nx_string(toollimited)) then
    local sec_index = ini:FindSectionIndex(nx_string(toollimited))
    if sec_index < 0 then
      nx_log("share\\Life\\LifeToolLimitInfo.ini sec_index= " .. nx_string(toollimited))
      return false
    end
    local tool_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    for i = 1, table.getn(tool_table) do
      local info_lst = util_split_string(tool_table[i], ",")
      if table.getn(info_lst) == 3 then
        local tool_pos = tool_table[2]
        local default_view_id
        if tool_pos == 1 then
          default_view_id = VIEWPORT_EQUIP
        end
        local tool_lst = util_split_string(info_lst[1], "/")
        local tool_have = true
        for j = 1, table.getn(tool_lst) do
          local tool_id = tool_lst[j]
          if default_view_id == nil then
            local goods_grid = nx_value("GoodsGrid")
            if nx_is_valid(goods_grid) then
              default_view_id = goods_grid:GetToolBoxViewport(tool_id)
            end
          end
          local view = game_client:GetView(nx_string(default_view_id))
          local viewobj_list = view:GetViewObjList()
          local view_have = false
          for i, obj in pairs(viewobj_list) do
            local tempid = obj:QueryProp("ConfigID")
            if tempid == tool_id then
              view_have = true
            end
          end
          if not view_have then
            tool_have = false
            break
          end
        end
        if tool_have then
          return true
        end
      end
    end
  end
  return false
end
function get_weapon_type(weapon_type)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  if not nx_is_valid(view) then
    return 0
  end
  local weapon = view:GetViewObj(nx_string(weapon_type))
  if not nx_is_valid(weapon) then
    return 0
  end
  return weapon:QueryProp("ItemType")
end
