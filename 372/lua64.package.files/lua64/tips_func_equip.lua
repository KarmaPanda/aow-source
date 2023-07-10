require("define\\tip_define")
require("share\\view_define")
require("share\\itemtype_define")
require("share\\static_data_type")
require("share\\item_static_data_define")
require("util_static_data")
require("util_gui")
require("util_functions")
require("tips_data")
require("utils")
function get_item_type(item, configid)
  if configid == "" or configid == nil then
    configid = get_prop_in_item(item, nx_string("ConfigID"))
  end
  local item_type = get_prop_in_ItemQuery(configid, nx_string("ItemType"))
  if item_type == "" or item_type == nil then
    item_type = get_prop_in_item(item, "ItemType")
  end
  return item_type
end
function get_item_level(item)
  local level = 0
  if nx_find_custom(item, "is_static") and item.is_static then
    local item_query = nx_value("ItemQuery")
    local configid = get_prop_in_item(item, "ConfigID")
    level = item_query:GetItemPropByConfigID(configid, "Level")
  else
    level = get_prop_in_item(item, "Level")
  end
  return level
end
function has_mount_used(item)
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  local mount = game_player:QueryProp("CurRideMount")
  if mount == nil or mount == "" then
    return false
  end
  if nx_is_valid(mount) then
    local id = get_prop_in_item(mount, "UniqueID")
    local the_id = get_prop_in_item(item, "UniqueID")
    return id == the_id
  end
  return false
end
function has_equip_used(item)
  local equiptype = get_prop_in_item(item, "EquipType")
  local pos1, pos2, pos3 = nx_execute("goods_grid", "get_equip_pos_by_equiptype", equiptype)
  local pos_table = {}
  if pos1 == nil then
    pos_table = nil
  else
    pos_table[1] = pos1
    if pos2 ~= nil then
      pos_table[2] = pos2
      if pos3 ~= nil then
        pos_table[3] = pos2
      end
    end
  end
  if pos_table == nil then
    return false
  end
  local index = 0
  local count = table.maxn(pos_table)
  local game_client = nx_value("game_client")
  local equipbox = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  if not nx_is_valid(equipbox) then
    return false
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return false
  end
  local the_id = get_prop_in_item(item, "UniqueID")
  for i = 1, count do
    local view_item = equipbox:GetViewObj(nx_string(pos_table[i]))
    if nx_is_valid(view_item) then
      local id = get_prop_in_item(view_item, "UniqueID")
      if id == the_id then
        return true
      end
    end
  end
  return false
end
function show_name_with_colorlevel(item)
  local config_id = nx_string(get_prop_in_item(item, "ConfigID"))
  local color_level = get_colorlevel(item)
  color_level = nx_number(color_level)
  return func_get_name(color_level, config_id)
end
function func_get_name(color_level, config_id)
  local name = ""
  local color_lst = global_color_list
  local gui = nx_value("gui")
  local color = COLOR_White
  color_level = nx_number(color_level)
  if color_lst[color_level] ~= nil then
    color = color_lst[color_level]
  end
  name = gui.TextManager:GetFormatText(config_id)
  name = get_text_by_color(name, color)
  return name
end
function get_colorlevel(item)
  local config_id = nx_string(get_prop_in_item(item, "ConfigID"))
  local color_level = get_prop_in_item(item, "ColorLevel")
  if color_level == nil or nx_string(color_level) == nx_string("") then
    color_level = get_ColorLevel_by_INI(item, config_id)
  end
  if nx_number(color_level) == nx_number(0) then
    color_level = 1
  end
  return nx_number(color_level)
end
function get_name(item)
  local config_id = nx_string(get_prop_in_item(item, "ConfigID"))
  local gui = nx_value("gui")
  local name = gui.TextManager:GetFormatText(config_id)
  return name
end
function get_ColorLevel_by_INI(item, config_id)
  local ini_file = query_INI_by_type(item, config_id)
  local color_level = get_ini_prop(ini_file, config_id, "ColorLevel", "0")
  return color_level
end
function get_bind_status(item)
  local status = get_prop_in_item(item, "BindStatus")
  if status == nil then
    return
  end
  local str_id = ""
  status = nx_number(status)
  if 0 == status then
    local type = get_prop_in_item(item, "BindType")
    type = nx_number(type)
    if 0 == type then
      str_id = ""
    elseif 1 == type then
      str_id = "tips_item_bindtype_pickup"
    elseif 2 == type then
      str_id = "tips_item_bindtype_equip"
    end
  elseif 1 == status then
    str_id = "tips_item_bound"
  end
  local text = ""
  if 0 < string.len(str_id) then
    local gui = nx_value("gui")
    text = nx_string(gui.TextManager:GetText(str_id))
  end
  local out_text = get_text_by_color(text, COLOR_Title)
  if 0 < nx_ws_length(nx_widestr(out_text)) then
    out_text = nx_string(out_text) .. "<br>"
  end
  return out_text
end
function get_goods_item_type(item)
  local type = get_item_type(item)
  return type
end
function show_item_type_text(item)
  local item_type = get_item_type(item)
  local out_text = func_get_type(item_type)
  if nx_ws_length(nx_widestr(out_text)) > 0 then
    out_text = nx_string(out_text) .. "<br>"
  end
  return nx_widestr(out_text)
end
function func_get_type(item_type)
  local gui = nx_value("gui")
  local out_text = ""
  item_type = nx_number(item_type)
  out_text = gui.TextManager:GetFormatText("tips_itemtype_" .. nx_string(item_type))
  return out_text
end
function func_get_sex(need_sex)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_sex = client_player:QueryProp("Sex")
  self_sex = nx_number(self_sex)
  local tips = ""
  if nx_string(need_sex) == "" or need_sex == nil then
    tips = "tips_need_sex_nil"
  elseif nx_number(need_sex) == 0 then
    tips = "tips_need_sex_0"
  elseif nx_number(need_sex) == 1 then
    tips = "tips_need_sex_1"
  else
    tips = "tips_need_sex_nil"
  end
  local color = ""
  if (need_sex == 0 or need_sex == 1) and need_sex ~= self_sex then
    color = COLOR_Red
  end
  local title = gui.TextManager:GetFormatText("tips_need_sex")
  local value = gui.TextManager:GetFormatText(nx_string(tips))
  local out_text = link_title_value(title, value, false, "", color)
  return out_text
end
function func_get_num(item, isEquip, item_type, config_id)
  local gui = nx_value("gui")
  local out_text = ""
  local title = ""
  local acount = "Amount"
  local max_acount = "MaxAmount"
  if isEquip then
    acount = "Hardiness"
    max_acount = "MaxHardiness"
    title = gui.TextManager:GetFormatText("tips_hardiness_1")
    local maxAmount = nx_number(get_prop_in_ItemAndItemQuery(item, config_id, nx_string("MaxAmount")))
    if 1 < maxAmount then
      acount = "Amount"
      max_acount = "MaxAmount"
      title = gui.TextManager:GetFormatText("tips_hidden_num")
    end
  else
    acount = "Amount"
    max_acount = "MaxAmount"
    title = gui.TextManager:GetFormatText("tips_hidden_num")
  end
  local cur_value = get_prop_in_item(item, nx_string(acount))
  local max_value = get_prop_in_ItemAndItemQuery(item, config_id, nx_string(max_acount))
  if cur_value == nil or nx_string(cur_value) == "" then
    if isEquip then
      cur_value = 0
      if nx_is_valid(item) then
        if nx_find_custom(item, "is_static") and item.is_static then
          cur_value = max_value
        end
      else
        cur_value = max_value
      end
    else
      return ""
    end
  end
  if max_value == nil or nx_string(max_value) == "" then
    return ""
  end
  if nx_number(max_value) < nx_number(cur_value) then
    max_value = cur_value
  end
  local color = COLOR_Value
  if not isEquip or nx_int(cur_value) >= nx_int(40) then
  elseif nx_int(cur_value) >= nx_int(10) then
    color = COLOR_Gold
  else
    color = COLOR_Red
  end
  cur_value = get_text_by_color(nx_string(cur_value), color)
  local max_value = nx_string("/") .. nx_string(max_value)
  max_value = get_text_by_color(nx_string(max_value), COLOR_Value)
  out_text = nx_string(title) .. cur_value .. max_value
  return out_text
end
function show_faculty_info(item)
  local book_obj, client_obj, faculty_table
  local date_row = nx_int(0)
  local item_query = nx_value("ItemQuery")
  local configid = get_prop_in_item(item, "ConfigID")
  if nx_find_custom(item, "is_static") and item.is_static then
    local faculty_info = item_query:GetItemPropByConfigID(configid, "@AddFaculty")
    faculty_table = util_split_string(faculty_info, ",")
    date_row = nx_int(table.getn(faculty_table) / 2)
  else
    book_obj = get_item_obj(item)
    if not nx_is_valid(book_obj) then
      return ""
    end
    client_obj = book_obj
    if not nx_find_method(client_obj, "FindRecord") then
      return ""
    end
  end
  local item_type = get_item_type(item)
  local jobid = "sh_ss"
  local pzpackidkey = ""
  if nx_number(item_type) == ITEMTYPE_WEAPON_PAINT then
    jobid = "sh_hs"
    pzpackidkey = "PainterPz"
  elseif nx_number(item_type) == ITEMTYPE_WEAPON_BOOK then
    jobid = "sh_ss"
    pzpackidkey = "ScholarPz"
  end
  local gui = nx_value("gui")
  local text = ""
  local title = ""
  local link_text = ""
  title = gui.TextManager:GetFormatText("tips_facultybook_effect_1")
  if 0 < nx_ws_length(nx_widestr(title)) then
    text = nx_string(text) .. nx_string(title) .. "<br>"
  end
  if nx_find_custom(item, "is_static") and item.is_static then
    for i = 0, nx_number(date_row - 1) do
      local index = i * 2 + 1
      local jn_id = faculty_table[index]
      local add_num = faculty_table[index + 1]
      local jn_text = gui.TextManager:GetFormatText(jn_id)
      gui.TextManager:Format_SetIDName(nx_string("tips_facultybook_effect_2"))
      gui.TextManager:Format_AddParam(nx_string(jn_text))
      gui.TextManager:Format_AddParam(nx_int(add_num))
      local context_text = nx_string(gui.TextManager:Format_GetText())
      if 0 < nx_ws_length(nx_widestr(context_text)) then
        text = nx_string(text) .. nx_string(context_text) .. "<br>"
      end
    end
  elseif client_obj:FindRecord("AddFaculty") then
    local rows = client_obj:GetRecordRows("AddFaculty")
    for i = 0, rows - 1 do
      local jn_id = client_obj:QueryRecord("AddFaculty", i, 0)
      local add_num = client_obj:QueryRecord("AddFaculty", i, 1)
      local jn_text = gui.TextManager:GetFormatText(jn_id)
      gui.TextManager:Format_SetIDName(nx_string("tips_facultybook_effect_2"))
      gui.TextManager:Format_AddParam(nx_string(jn_text))
      gui.TextManager:Format_AddParam(add_num)
      local context_text = nx_string(gui.TextManager:Format_GetText())
      if 0 < nx_ws_length(nx_widestr(context_text)) then
        text = nx_string(text) .. nx_string(context_text) .. "<br>"
      end
    end
  end
  local value = get_prop_in_item(item, "MaxPzCount") - get_prop_in_item(item, "PzCount")
  gui.TextManager:Format_SetIDName(nx_string("tips_pizhu_num"))
  gui.TextManager:Format_AddParam(nx_int(value))
  local context_text = nx_string(gui.TextManager:Format_GetText())
  if 0 < nx_ws_length(nx_widestr(context_text)) then
    text = nx_string(text) .. nx_string(context_text) .. "<br>"
  end
  title = gui.TextManager:GetFormatText("tips_faculty_names")
  local value = get_prop_in_item(item, "ProNames")
  link_text = link_title_value(title, value)
  if 0 < nx_ws_length(nx_widestr(link_text)) then
    text = nx_string(text) .. nx_string(link_text) .. "<br>"
  end
  local pzpackid
  if nx_find_custom(item, "is_static") and item.is_static then
    pzpackid = item_query:GetItemPropByConfigID(configid, pzpackidkey)
  else
    pzpackid = get_prop_in_item(item, pzpackidkey)
  end
  local filepath = "share\\Life\\" .. pzpackidkey .. ".ini"
  local pz_ini = nx_execute("util_functions", "get_ini", filepath)
  local index = pz_ini:FindSectionIndex(nx_string(pzpackid))
  if index < 0 then
    return ""
  end
  local value = pz_ini:ReadInteger(index, "PzNeedLevel", 0)
  gui.TextManager:Format_SetIDName(nx_string("tips_pizhu_need_level"))
  gui.TextManager:Format_AddParam(gui.TextManager:GetFormatText(jobid))
  gui.TextManager:Format_AddParam(nx_int(value))
  local context_text = nx_string(gui.TextManager:Format_GetText())
  if 0 < nx_ws_length(nx_widestr(context_text)) then
    text = nx_string(text) .. nx_string(context_text) .. "<br>"
  end
  if nx_find_custom(item, "is_static") and item.is_static then
  else
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      local row = client_player:FindRecordRow("job_rec", 0, jobid, 0)
      if 0 <= row then
        local value = pz_ini:ReadInteger(index, "NeedEne", 0)
        gui.TextManager:Format_SetIDName(nx_string("tips_faculty_NeedEne"))
        gui.TextManager:Format_AddParam(nx_int(value))
        local context_text = nx_string(gui.TextManager:Format_GetText())
        if 0 < nx_ws_length(nx_widestr(context_text)) then
          text = nx_string(text) .. nx_string(context_text) .. "<br>"
        end
        local toollimited = nx_number(pz_ini:ReadInteger(index, "ToolLimited", 0))
        local tool_id = get_tool_from_limited(toollimited)
        if nx_string(tool_id) ~= "" then
          local have = life_tool_limit_check(toollimited)
          if have then
            gui.TextManager:Format_SetIDName(nx_string("tips_pizhu_tool_1"))
          else
            gui.TextManager:Format_SetIDName(nx_string("tips_pizhu_tool_2"))
          end
          gui.TextManager:Format_AddParam(nx_string(tool_id))
          local context_text = nx_string(gui.TextManager:Format_GetText())
          if 0 < nx_ws_length(nx_widestr(context_text)) then
            text = nx_string(text) .. nx_string(context_text) .. "<br>"
          end
        end
        local exp_package = nx_number(pz_ini:ReadInteger(index, "LifeExpPackage", 0))
        local temp_job_id, value = get_exp_from_package(exp_package)
        if nx_string(temp_job_id) ~= "" then
          gui.TextManager:Format_SetIDName(nx_string("tips_faculty_exppackage"))
          gui.TextManager:Format_AddParam(nx_string(temp_job_id))
          gui.TextManager:Format_AddParam(nx_int(value))
          local context_text = nx_string(gui.TextManager:Format_GetText())
          if 0 < nx_ws_length(nx_widestr(context_text)) then
            text = nx_string(text) .. nx_string(context_text) .. "<br>"
          end
        end
      end
    end
  end
  if 0 < nx_ws_length(nx_widestr(text)) then
    return nx_widestr(text)
  else
    return ""
  end
end
function get_price_info(tip_control, item)
  local gui = nx_value("gui")
  local count = nx_number(get_prop_in_item(item, "Amount"))
  if count < 1 then
    count = 1
  end
  if not nx_find_custom(tip_control, "buf_text") then
    tip_control.buf_text = ""
  end
  local stall_price_lst = {
    {
      tips_id = "tips_stallprice_0",
      prop = "StallPrice0"
    },
    {
      tips_id = "tips_stallprice_1",
      prop = "StallPrice1"
    },
    {
      tips_id = "tips_sellprice_0",
      prop = "SellPrice0"
    },
    {
      tips_id = "tips_sellprice_1",
      prop = "SellPrice1"
    },
    {
      tips_id = "tips_sellprice_2",
      prop = "SellPrice2"
    }
  }
  local normal_price_lst = {
    {
      tips_id = "tips_sellprice_0",
      prop = "SellPrice0"
    },
    {
      tips_id = "tips_sellprice_1",
      prop = "SellPrice1"
    },
    {
      tips_id = "tips_buyprice_2",
      prop = "SellPrice2"
    },
    {
      tips_id = "tips_sellprice_busiprice",
      prop = "BusiPrice"
    },
    {
      tips_id = "tips_buyprice_0",
      prop = "BuyPrice0"
    },
    {
      tips_id = "tips_buyprice_1",
      prop = "BuyPrice1"
    }
  }
  if nx_find_custom(item, "IsShop") and item.IsShop then
    for i, price_info in pairs(stall_price_lst) do
      if nx_string(price_info.prop) == "SellPrice0" then
        price_info.tips_id = "tips_buyprice_0"
      elseif nx_string(price_info.prop) == "SellPrice1" then
        price_info.tips_id = "tips_buyprice_1"
      elseif nx_string(price_info.prop) == "SellPrice2" then
        price_info.tips_id = "tips_buyprice_2"
      elseif nx_string(price_info.prop) == "StallPrice0" then
        price_info.tips_id = "tips_stall_buyprice_0"
      elseif nx_string(price_info.prop) == "StallPrice1" then
        price_info.tips_id = "tips_stall_buyprice_1"
      end
    end
  end
  local b_stall = false
  local text = ""
  for i, price_info in pairs(stall_price_lst) do
    local price = nx_number(get_prop_in_item(item, price_info.prop))
    if nx_string(price_info.prop) == "StallPrice0" or nx_string(price_info.prop) == "StallPrice1" then
    else
      price = price * count
    end
    if 0 < price then
      local captial_text = nx_execute("util_functions", "trans_capital_string", nx_int64(price))
      text = nx_string(text) .. nx_string(gui.TextManager:GetFormatText(price_info.tips_id, captial_text))
      text = nx_string(text) .. "<br>"
      b_stall = true
      break
    end
  end
  if b_stall then
    tip_control.buf_text = nx_string(tip_control.buf_text) .. nx_string(text)
    return nx_widestr(text)
  end
  for i, price_info in pairs(normal_price_lst) do
    local price = nx_number(get_prop_in_item(item, price_info.prop))
    price = price * count
    if 0 < price then
      if price_info.prop == "BusiPrice" then
        local captial_text = gui.TextManager:GetFormatText("tips_baochao", nx_int64(price))
        text = nx_string(text) .. nx_string(gui.TextManager:GetFormatText(price_info.tips_id, captial_text))
        text = nx_string(text) .. "<br>"
      else
        local captial_text = nx_execute("util_functions", "trans_capital_string", nx_int64(price))
        text = nx_string(text) .. nx_string(gui.TextManager:GetFormatText(price_info.tips_id, captial_text))
        text = nx_string(text) .. "<br>"
      end
    end
  end
  tip_control.buf_text = nx_string(tip_control.buf_text) .. nx_string(text)
  return nx_widestr(text)
end
function get_desc_info(item)
  local gui = nx_value("gui")
  local congfigid = nx_string(get_prop_in_item(item, "ConfigID"))
  local level = nx_int(get_prop_in_item(item, "Level"))
  local desc_id = "desc_" .. congfigid .. "_" .. nx_string(level)
  local text = gui.TextManager:GetFormatText(desc_id)
  if nx_ws_length(nx_widestr(text)) > 0 then
    text = nx_string(text) .. "<br>"
  end
  return nx_widestr(text)
end
function get_text_by_table_id(item, type, table_id)
  local first_string = ""
  local color = COLOR_Value
  if type == 1 then
    first_string = "tips_proppack_"
  elseif type == 2 then
    first_string = "tips_skillpack_"
  elseif type == 3 then
    first_string = "tips_buffpack_"
  elseif type == 4 then
    first_string = "tips_equippack_"
  elseif type == 5 then
    first_string = "tips_taskpack_"
  else
    return ""
  end
  local gui = nx_value("gui")
  local buf = ""
  for _, id in pairs(table_id) do
    if id == "" or id == nil then
      return buf
    end
    local str_id = nx_string(first_string) .. nx_string(id)
    local text = ""
    if type == 2 then
      text = nx_string(gui.TextManager:GetFormatText(str_id, COLOR_Pink, COLOR_Value))
      buf = nx_string(buf) .. nx_string(text) .. "<br>"
    else
      text = nx_string(gui.TextManager:GetFormatText(str_id))
      if check_modify_condition(item, type, id) then
        color = COLOR_Value
      else
        color = COLOR_Red
      end
      text = get_text_by_color(text, color)
      buf = nx_string(buf) .. nx_string(text) .. "<br>"
    end
  end
  return buf
end
function check_modify_condition(item, type, pack_id)
  local cdtkmgr = nx_value("ConditionManager")
  if not nx_is_valid(cdtkmgr) then
    return false
  end
  local file_name = ""
  if type == 1 then
    file_name = "share\\ModifyPack\\PropPack.ini"
  elseif type == 2 then
    file_name = "share\\ModifyPack\\SkillPack.ini"
  elseif type == 3 then
    file_name = "share\\ModifyPack\\BuffPack.ini"
  elseif type == 4 then
    file_name = "share\\ModifyPack\\EquipPack.ini"
  elseif type == 5 then
    file_name = "share\\ModifyPack\\TaskPack.ini"
  end
  local ini = nx_execute("util_functions", "get_ini", file_name)
  local value = get_ini_prop(file_name, nx_string(pack_id), "r", "")
  local tuple = util_split_string(value, ",")
  local limit_id = tuple[5]
  if limit_id == nil then
    return true
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  return cdtkmgr:CanSatisfyCondition(player, player, nx_int(limit_id))
end
function show_image_prop(item)
  local config_id = get_prop_in_item(item, "ConfigID")
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(config_id), nx_string("Photo"))
  return photo
end
function show_zhaoshi_type(item)
  local gui = nx_value("gui")
  local item_type = get_item_type(item)
  local config_id = get_prop_in_item(item, "ConfigID")
  local skill_type = -1
  local is_zhenfa_skill = "0"
  local normal_sub_type = "0"
  local img = "gui\\language\\ChineseS\\fighttips\\"
  local text_type = "tips_itemtype_" .. nx_string(item_type)
  item_type = nx_number(item_type)
  if item_type == ITEMTYPE_ZHAOSHI or item_type == ITEMTYPE_LOCKZHAOAHI then
    local Data_Type = STATIC_DATA_SKILL_STATIC
    local Data_Index = get_prop_in_item(item, "StaticData")
    skill_type = get_prop_in_static_query(Data_Type, Data_Index, "EffectType")
    is_zhenfa_skill = get_prop_in_static_query(Data_Type, Data_Index, "IsZhenFaSkill")
    if item_type == ITEMTYPE_ZHAOSHI then
      normal_sub_type = get_prop_in_static_query(Data_Type, Data_Index, "NormalSubType")
    end
    if nx_int(skill_type) == nx_int(1) then
      text_type = img .. "shi_new.png"
    elseif nx_int(skill_type) == nx_int(2) then
      text_type = img .. "xu_new.png"
    elseif nx_int(skill_type) == nx_int(3) then
      text_type = img .. "jia_new.png"
    elseif nx_string(is_zhenfa_skill) == "1" then
      text_type = img .. "shu_new.png"
    elseif nx_string(normal_sub_type) == "0" then
      text_type = img .. "shu_new.png"
    elseif nx_string(normal_sub_type) == "1" then
      text_type = img .. "ji_new.png"
    elseif nx_string(normal_sub_type) == "2" then
      text_type = img .. "she_new.png"
    end
  elseif item_type == ITEMTYPE_NEIGONG then
    text_type = img .. "neigong_new.png"
  elseif item_type == ITEMTYPE_QINGGONG then
    text_type = img .. "qinggong_new.png"
  elseif item_type == ITEMTYPE_ZHENFA then
    text_type = img .. "zhenfa_new.png"
  elseif item_type == ITEMTYPE_ANQI_SHOUFA then
    text_type = img .. "anzhao_new.png"
  elseif item_type == ITEMTYPE_JINGMAI then
    text_type = img .. "jingmai_new.png"
  elseif item_type == ITEMTYPE_XUEWEI then
    text_type = img .. "xuewei.png"
  elseif item_type == ITEMTYPE_HUIHAI_SKILL then
    text_type = img .. "jingfa_new.png"
  elseif item_type == ITEMTYPE_ANQI_NORMAL then
    text_type = img .. "shu_new.png"
  elseif item_type == ITEMTYPE_CHESS_SKILL then
    local chess_npc_manager = nx_value("ChessNpcManager")
    if nx_is_valid(chess_npc_manager) then
      local config_id = get_prop_in_item(item, "ConfigID")
      text_type = chess_npc_manager:GetChessSkillPhto(config_id)
    end
  elseif item_type == ITEMTYPE_QG_TYPE then
    text_type = img .. "qinggong_new.png"
  elseif item_type == ITEMTYPE_PUZZLE_SKILL then
    local jewel_game_manager = nx_value("jewel_game_manager")
    if nx_is_valid(jewel_game_manager) then
      text_type = jewel_game_manager:GetPhoto(config_id)
    end
  end
  return text_type
end
function create_model_1(scenebox, modelpath, offsetY, mode_angleX)
  local mode_1 = nx_execute("util_functions", "util_create_model", nx_string(modelpath) .. ".xmod", "", "", "", "", false, scenebox.Scene)
  if isuccess == false then
    return
  end
  scenebox.Scene:AddObject(mode_1, 20)
  scenebox.Scene.model_1 = mode_1
  mode_1:SetPosition(0, offsetY, 0)
  mode_1:SetAngle(mode_angleX, 0, 0)
end
function get_item_3D_model(tip_control, item)
  local item_name = get_prop_in_item(item, "ConfigID")
  local itemmap = nx_value("ItemQuery")
  local str_type = itemmap:GetItemPropByConfigID(nx_string(item_name), nx_string("ItemType"))
  local item_type = nx_number(str_type)
  if item_type < ITEMTYPE_EQUIP_MIN or item_type > ITEMTYPE_EQUIP_MAX + 1 then
    return
  end
  local equip_type = itemmap:GetItemPropByConfigID(nx_string(item_name), nx_string("EquipType"))
  local bExist = itemmap:FindItemByConfigID(nx_string(item_name))
  if bExist == false then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local modelpath_man = get_weaponmode_path_by_name(nx_string(item_name), "MaleModel")
  local modelpath_womam = get_weaponmode_path_by_name(nx_string(item_name), "FemaleModel")
  local sex = -1
  local modelpath = ""
  local need_sex = nx_number(get_prop_in_item(item, "NeedSex"))
  if need_sex == 0 then
    sex = 0
    modelpath = modelpath_man
  elseif need_sex == 1 then
    sex = 1
    modelpath = modelpath_womam
  else
    sex = client_player:QueryProp("Sex")
    if sex == 0 then
      modelpath = modelpath_man
    else
      modelpath = modelpath_womam
    end
  end
  if modelpath == "" or modelpath == nil then
    return false
  end
  local form = tip_control.ParentForm
  local gui = nx_value("gui")
  local scene
  scene = tip_control.scenebox_1
  if item_type >= ITEMTYPE_WEAPON_MIN and item_type <= ITEMTYPE_WEAPON_MAX then
    if not nx_is_valid(scene.Scene) then
      nx_execute("util_gui", "util_addscene_to_scenebox", scene)
    end
    local mode = nx_execute("util_functions", "util_create_model", nx_string(modelpath) .. ".xmod", "", "", "", "", false, scene.Scene)
    if not nx_is_valid(mode) then
      return
    end
    local radius = mode.Radius
    local offsetY = 0
    local Camera_z = -radius * 3
    local mode_angleX = math.pi / 3
    nx_execute("util_gui", "util_add_model_to_scenebox", scene, mode)
    if item_type == ITEMTYPE_WEAPON_BLADE then
      offsetY = offsetY - 0.2
      Camera_z = Camera_z + 0.4
      mode_angleX = -mode_angleX
    elseif item_type == ITEMTYPE_WEAPON_COSH then
      offsetY = offsetY - 0.65
      Camera_z = Camera_z + 0.4
    elseif item_type == ITEMTYPE_WEAPON_STUFF then
      offsetY = offsetY - 0.9
      Camera_z = Camera_z + 0.4
    elseif item_type == ITEMTYPE_WEAPON_SWORD then
      offsetY = offsetY - 0.1
      mode_angleX = -mode_angleX
    elseif item_type == ITEMTYPE_WEAPON_THORN then
      offsetY = offsetY - 0.2
      Camera_z = Camera_z + 0.3
    elseif item_type == ITEMTYPE_WEAPON_STHORN then
      offsetY = offsetY - 0.35
      Camera_z = Camera_z + 0.3
      create_model_1(scene, modelpath, offsetY, mode_angleX * 2)
    elseif item_type >= ITEMTYPE_WEAPON_HIDDEN and item_type <= ITEMTYPE_WEAPON_ARROR then
      offsetY = offsetY - 0.15
    elseif item_type == ITEMTYPE_WEAPON_SSWORD then
      offsetY = offsetY - 0.9
      create_model_1(scene, modelpath, offsetY, mode_angleX * 2)
    elseif item_type == ITEMTYPE_WEAPON_SBLADE then
      offsetY = offsetY - 0.8
      create_model_1(scene, modelpath, offsetY, mode_angleX * 2)
    end
    mode:SetAngle(mode_angleX, 0, 0)
    mode:SetPosition(0, offsetY, 0)
    scene.Scene.BackColor = "0,0,0,0"
    scene.Scene.camera.Fov = 0.125 * math.pi * 2
    scene.Scene.camera:SetPosition(0, -radius * 2 / 2.5, Camera_z)
    nx_execute(nx_current(), "rotate_x", mode, math.pi / 2)
    if nx_find_custom(scene.Scene, nx_string("model_1")) then
      nx_execute(nx_current(), "rotate_x", scene.Scene.model_1, math.pi / 2)
    end
  elseif item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    if not nx_is_valid(scene.Scene) then
      nx_execute("util_gui", "util_addscene_to_scenebox", scene)
    end
    local actor2_man = nx_execute("role_composite", "create_role_composite", scene.Scene, true, sex)
    if not nx_is_valid(actor2_man) then
      return
    end
    actor2_man:BlendAction("stand", true, true)
    actor2_man:SetActionSpeed("stand", 0)
    local offsetX = 0
    local offsetY = 0
    local offsetY_woman = 0
    local offsetZ = 0
    local radius = actor2_man.Radius
    local Camera_z = -radius * 1.5
    if equip_type == "Hat" then
      nx_execute("role_composite", "link_skin", actor2_man, "hat", modelpath .. ".xmod")
      offsetY = -0.7
      Camera_z = Camera_z + 1.5
    elseif equip_type == "Mask" then
      nx_execute("role_composite", "link_skin", actor2_man, "mask", modelpath .. ".xmod")
    elseif equip_type == "Cloth" then
      nx_execute("role_composite", "link_skin", actor2_man, "cloth", modelpath .. ".xmod")
      offsetY = -0.1
      Camera_z = Camera_z + 0.5
    elseif equip_type == "Pants" then
      nx_execute("role_composite", "link_skin", actor2_man, "pants", modelpath .. ".xmod")
      offsetY = 0.3
      Camera_z = Camera_z + 0.7
    elseif equip_type == "Shoes" then
      nx_execute("role_composite", "link_skin", actor2_man, "shoes", modelpath .. ".xmod")
      offsetY = 0.75
      Camera_z = Camera_z + 1
    elseif equip_type == "Mantle" then
      nx_execute("role_composite", "link_skin", actor2_man, "mantle", modelpath .. ".xmod")
    elseif equip_type == "Suit" then
      nx_execute("role_composite", "link_skin", actor2_man, "Suit", modelpath .. ".xmod")
      offsetY = 0.1
    else
      return false
    end
    nx_execute("util_gui", "util_add_model_to_scenebox", scene, actor2_man)
    actor2_man:SetPosition(offsetX, offsetY, offsetZ)
    scene.Scene.BackColor = "0,0,0,0"
    scene.Scene.camera.Fov = 0.125 * math.pi * 2
    scene.Scene.camera:SetPosition(0, radius * 0.6, Camera_z)
  elseif item_type == ITEMTYPE_MOUNT then
    local world = nx_value("world")
    local scene1 = nx_value("game_scene")
    local actor2 = nx_null()
    local item_resource = itemmap:GetItemPropByConfigID(nx_string(item_name), nx_string("Resource"))
    if not nx_is_valid(scene.Scene) then
      nx_execute("util_gui", "util_addscene_to_scenebox", scene)
    end
    actor2 = nx_execute("role_composite", "create_actor2", scene.Scene)
    local result = nx_execute("role_composite", "load_from_ini", actor2, "ini\\" .. nx_string(item_resource) .. ".ini")
    actor2:BlendAction("stand", true, true)
    actor2:SetActionSpeed("stand", 0)
    if not result then
      scene1:Delete(actor2)
      return nx_null()
    end
    local offsetY = 0.5
    local radius = actor2.Radius
    local Camera_z = -radius * 1.5
    nx_execute("util_gui", "util_add_model_to_scenebox", scene, actor2)
    actor2:SetPosition(0, offsetY, 0)
    actor2:SetAngle(0, -math.pi / 2, 0)
    scene.Scene.BackColor = "0,0,0,0"
    scene.Scene.camera.Fov = 0.125 * math.pi * 2
    scene.Scene.camera:SetPosition(0, radius * 0.6, Camera_z)
  end
  return true
end
function rotate_x(mode, rotate_x)
  local angle = 0
  while nx_is_valid(mode) do
    angle = rotate_x * nx_pause(0)
    if nx_is_valid(mode) then
      mode:SetAngle(mode.AngleX, mode.AngleY + angle, mode.AngleZ)
    end
  end
end
function get_enchase_info(item)
  if nx_find_custom(item, "is_static") and item.is_static then
    return ""
  end
  local max_count = get_prop_in_item(item, "MaxHoleCount")
  local cur_count = get_prop_in_item(item, "CurHoleCount")
  local gui = nx_value("gui")
  local zero_int = nx_int(0)
  local text_out = ""
  local photo_out = ""
  if zero_int >= nx_int(max_count) then
    return text_out
  end
  cur_count = nx_int(cur_count)
  if cur_count == zero_int then
    text_out = gui.TextManager:GetFormatText("tips_enchase_info1")
    return text_out
  elseif zero_int < cur_count then
    local has_enchase, result, photo = get_active_enchase(item, cur_count)
    if has_enchase then
      text_out = result
      photo_out = photo
      text_out = nx_string(text_out) .. nx_string(photo_out)
    else
      text_out = gui.TextManager:GetFormatText("tips_enchase_info2")
    end
  end
  return nx_widestr(text_out)
end
function get_active_enchase(item, count)
  local gui = nx_value("gui")
  local has_enchase = false
  local info_id = ""
  local info = ""
  local result = ""
  local text = ""
  local text_out = ""
  local photo = ""
  local photo_out = ""
  local index = 1
  for index = 1, nx_number(count) do
    info_id = "EnchaseItem" .. nx_string(index)
    info = get_prop_in_item(item, info_id)
    result = util_split_string(info, ",")
    if nx_string(result[1]) == nx_string(1) then
      has_enchase = true
      local config_id = result[2]
      text = gui.TextManager:GetFormatText("tips_" .. nx_string(config_id))
      if nx_ws_length(nx_widestr(text)) > 0 then
        text_out = text_out .. nx_string(text) .. "<br>"
      end
      photo = "<img src=\"" .. nx_string("gui\\common\\haoyoudu.png") .. "\"" .. "/>"
      photo_out = photo_out .. nx_string(photo)
    end
  end
  return has_enchase, text_out, photo_out
end
function get_enhance_modify_desc(item)
  if nx_find_custom(item, "is_static") and item.is_static then
    return ""
  end
  local text = ""
  local prop_built = get_prop_in_item(item, "PropBuilt")
  if prop_built == nil or prop_built == "" then
    return ""
  end
  local props = util_split_string(prop_built, ";")
  for _, prop in ipairs(props) do
    local pos = string.find(prop, ",")
    if pos ~= nil then
      local prop_type = nx_number(string.sub(prop, pos - 1))
      local prop_pack = string.sub(prop, pos + 1)
      text = text .. get_text_by_table_id(item, prop_type, {prop_pack})
    end
  end
  return nx_widestr(text)
end
function get_enhance_desc(item)
  if nx_find_custom(item, "is_static") and item.is_static then
    return ""
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return ""
  end
  local configid = get_prop_in_item(item, "ConfigID")
  local can_build = false
  if nx_find_custom(item, "view_obj") then
    if nx_is_valid(item.view_obj) then
      can_build = item.view_obj:QueryProp("IsCanBuild")
    end
  elseif nx_name(item) ~= "ArrayList" and not item:FindProp("IsCanBuild") then
    can_build = nx_int(0)
  else
    can_build = get_prop_in_ItemAndItemQuery(item, configid, "IsCanBuild")
  end
  if can_build == nil or can_build == "" or nx_int(can_build) == nx_int(0) then
    return ""
  end
  local gui = nx_value("gui")
  if nx_find_custom(item, "is_static") and item.is_static then
    local out = gui.TextManager:GetFormatText("tips_RandomRulePack")
    out = nx_widestr(out) .. nx_widestr("<br>")
    return nx_widestr(out)
  end
  local prop_get_pack = nx_string(get_prop_in_item(item, "PropGetPack"))
  if prop_get_pack == nil or prop_get_pack == "" then
    return ""
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\equip_prop_rand.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(prop_get_pack)
  if sec_index < 0 then
    return ""
  end
  local job_id = ini:ReadString(sec_index, "JobName", "")
  if job_id == nil or job_id == "" then
    return ""
  end
  local job_level = ini:ReadString(sec_index, "JobLevel", "")
  if job_level == nil or job_level == "" then
    return ""
  end
  local cost = ini:ReadString(sec_index, "Cost", "")
  local items = ini:ReadString(sec_index, "Item", "")
  local equip_pack = ini:ReadString(sec_index, "EquipPack", "")
  local prop_pack = ini:ReadString(sec_index, "PropPack", "")
  local skill_pack = ini:ReadString(sec_index, "SkillPack", "")
  local buff_pack = ini:ReadString(sec_index, "BuffPack", "")
  local task_pack = ini:ReadString(sec_index, "TaskPack", "")
  local text = ""
  local job_name = gui.TextManager:GetText(job_id)
  local format_id = "tips_equip_build_job"
  if job_id == "sh_cf" then
    format_id = "tips_equip_build_job_cf"
  elseif job_id == "sh_ds" then
    format_id = "tips_equip_build_job_ds"
  elseif job_id == "sh_cs" then
    format_id = "tips_equip_build_job_cs"
  elseif job_id == "sh_ys" then
    format_id = "tips_equip_build_job_ys"
  elseif job_id == "sh_tj" then
    format_id = "tips_equip_build_job_tj"
  elseif job_id == "sh_jq" then
    format_id = "tips_equip_build_job_jq"
  end
  local job_sf_path = "share\\Item\\lifesfname.ini"
  local sf_ini = nx_execute("util_functions", "get_ini", job_sf_path)
  if not nx_is_valid(sf_ini) then
    return ""
  end
  local index = sf_ini:FindSectionIndex(nx_string(job_id))
  if index < 0 then
    return
  end
  job_level = gui.TextManager:GetText("role_title_" .. sf_ini:ReadString(index, nx_string(job_level), ""))
  gui.TextManager:Format_SetIDName(format_id)
  gui.TextManager:Format_AddParam(nx_widestr(job_level))
  gui.TextManager:Format_AddParam(nx_widestr(job_name))
  text = nx_widestr(text) .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
  text = text .. gui.TextManager:GetText("tips_equip_need_item")
  items = util_split_string(items, ";")
  for _, data in ipairs(items) do
    local pos = string.find(data, ",")
    if pos ~= nil then
      local config_id = string.sub(data, 1, pos - 1)
      local name = gui.TextManager:GetText(config_id)
      local next_pos = string.find(data, ",", pos + 1)
      local count = string.sub(data, pos + 1, next_pos - 1)
      gui.TextManager:Format_SetIDName("tips_equip_enhance_item")
      gui.TextManager:Format_AddParam(nx_widestr(name))
      gui.TextManager:Format_AddParam(nx_widestr(count))
      text = text .. gui.TextManager:Format_GetText()
    end
  end
  if 0 < nx_number(cost) then
    local format_cost = nx_execute("util_functions", "trans_capital_string", nx_int64(cost))
    local photo = nx_widestr(" <img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" /> ")
    text = text .. photo .. nx_widestr(format_cost)
  end
  return nx_widestr(text)
end
function show_special_eaffect_info(item)
  local gui = nx_value("gui")
  local effect_packid = 0
  local karma_packid = 0
  local text = nx_widestr("")
  effect_packid = nx_number(get_prop_in_item(item, "EffectPackID"))
  karma_packid = nx_number(get_prop_in_item(item, "KarmaModifyPack"))
  if 0 < karma_packid then
    local content = gui.TextManager:GetFormatText("tips_karma_" .. nx_string(karma_packid))
    content = nx_widestr(get_text_by_color(content, COLOR_Green_2))
    text = text .. content .. nx_widestr("<br>")
  end
  if effect_packid <= 0 then
    return text
  end
  local file_name = "share\\Rule\\equip_special_effect_pack.ini"
  local ini = nx_execute("util_functions", "get_ini", file_name)
  if not nx_is_valid(ini) then
    return text
  end
  local index = ini:FindSectionIndex(nx_string(effect_packid))
  if index < 0 then
    return text
  end
  local EquipAddBuff = ini:ReadString(index, "EquipAddBuff", "")
  local SkillAddBuff = ini:ReadString(index, "SkillAddBuff", "")
  local PrizePackID = ini:ReadInteger(index, "PrizePackID", 0)
  local props = util_split_string(EquipAddBuff, ";")
  for _, data in ipairs(props) do
    local pos = string.find(data, ",")
    if pos ~= nil then
      local buff_id = string.sub(data, 1, pos - 1)
      local level = nx_number(string.sub(data, pos + 1))
      local desc = nx_string("tips_") .. nx_string(buff_id) .. nx_string("_") .. nx_string(level)
      local content = gui.TextManager:GetFormatText(desc)
      content = nx_widestr(get_text_by_color(content, COLOR_Green_2))
      text = text .. content .. nx_widestr("<br>")
    end
  end
  local skill_buff = util_split_string(SkillAddBuff, ";")
  for _, data in ipairs(skill_buff) do
    local pos = string.find(data, ",")
    if pos ~= nil then
      local buff_id = string.sub(data, 1, pos - 1)
      local level = nx_number(string.sub(data, pos + 1))
      local desc = nx_string("tips_") .. nx_string(buff_id) .. nx_string("_") .. nx_string(level)
      local content = gui.TextManager:GetFormatText(desc)
      content = nx_widestr(get_text_by_color(content, COLOR_Green_2))
      text = text .. content .. nx_widestr("<br>")
    end
  end
  if 0 < PrizePackID then
    local content = gui.TextManager:GetFormatText("tips_prize_" .. nx_string(PrizePackID))
    content = nx_widestr(get_text_by_color(content, COLOR_Green_2))
    text = text .. content .. nx_widestr("<br>")
  end
  return nx_widestr(text)
end
