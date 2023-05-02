require("tips_func_equip")
require("util_static_data")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
SCHOOL_INI = "ini\\ui\\wuxue\\wuxue_school.ini"
ZHAOSHI_INI = "ini\\ui\\wuxue\\wuxue_zhaoshi.ini"
WUXUE_STUDY_INI = "ini\\ui\\wuxue\\wuxue_study.ini"
ZHAOSHI_OTHER_INI = "ini\\ui\\wuxue\\skill_other.ini"
SKILL_INI = "share\\Skill\\skill_new.ini"
SKILL_CONSUME_INI = "share\\Skill\\skill_consume.ini"
SKILL_NORMAL_INI = "share\\Skill\\skill_normal_varprop.ini"
SKILL_LOCK_INI = "share\\Skill\\skill_lock_varprop.ini"
SKILL_STATIC_INI = "share\\Skill\\skill_static.ini"
SKILL_FORMULA_INI = "share\\Skill\\formula.ini"
SKILL_DAMAGE_CALCULATE_INI = "share\\Skill\\damage_calculate.ini"
SKILL_EVENT_PROCESS_INI = "share\\Skill\\skill_event_process.ini"
NEIGONG_VARPROP_INI = "share\\Skill\\NeiGong\\neigong_varprop.ini"
SKILL_QG_VARPROP_INI = "share\\Skill\\QingGong\\QGSkillProp.ini"
SKILL_QG_STATIC_INI = "share\\Skill\\QingGong\\QGSkillStatic.ini"
ANQI_SHOUFA_STATIC_INI = "share\\Skill\\ShouFa\\shoufa_static.ini"
JINGMAI_STATIC_INI = "share\\Skill\\JingMai\\jingmai_static.ini"
NEIGONG_STATIC_INI = "share\\Skill\\NeiGong\\neigong_static.ini"
SHOUFA_ANQI_INI = "share\\Skill\\anqi_shoufa.ini"
XUEWEI_INI = "share\\Skill\\XueWei\\xuewei.ini"
XUEWEI_VARPROP_INI = "share\\Skill\\XueWei\\xuewei_varprop.ini"
QINGGONG_DEFINE_INI = "share\\Skill\\QingGong\\QGDefine.ini"
SKILL_PROP_COUNT = 11
function get_skill_type(config_id)
  local skill_script = get_ini_prop(SKILL_INI, config_id, "script", "")
  if nx_string(skill_script) == nx_string("SkillNormal") then
    return 0
  elseif nx_string(skill_script) == nx_string("SkillLock") then
    return 1
  else
    return -1
  end
end
function get_Max_Level(static_data_id, ini_file)
  if ini_file == nil or ini_file == "" then
    ini_file = SKILL_STATIC_INI
  end
  local minlevel = get_ini_prop(ini_file, static_data_id, "MinVarPropNo", "0")
  local maxlevel = get_ini_prop(ini_file, static_data_id, "MaxVarPropNo", "0")
  return nx_int(nx_int(maxlevel) - nx_int(minlevel) + 1)
end
function GetSkillMaxLevel(static_data_id)
  return get_Max_Level(static_data_id, SKILL_STATIC_INI)
end
function get_VarpropNo_by_level(file, configid, level)
  local minlevel = get_ini_prop(file, configid, "MinVarPropNo", "0")
  local maxlevel = get_ini_prop(file, configid, "MaxVarPropNo", "0")
  if nx_int(nx_int(minlevel) + nx_int(level)) > nx_int(maxlevel) then
    return nx_string(maxlevel)
  end
  return nx_string(nx_int(minlevel) + nx_int(level) - nx_int(1))
end
function getAddPropNo(staticDataId, level)
  local propNo = get_VarpropNo_by_level(SKILL_STATIC_INI, staticDataId, level)
  return nx_string(propNo)
end
function get_skill_prop_by_level(item, staticDataId, level, use_ini)
  local gui = nx_value("gui")
  local prepare_time = 0
  local coolDown_time = 0
  local consume_hp = 0
  local consume_mp = 0
  local consume_hp_p = 0
  local consume_mp_p = 0
  local damage_phy = 0
  local damage_sti = 0
  local damage_juj = 0
  local damage_neg = 0
  local damage_mas = 0
  local consume_mp_base = 0
  local config_id = get_prop_in_item(item, "ConfigID")
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return ""
  end
  local values = {}
  if use_ini then
    values = skill_query:QuerySkillBaseProps("", nx_string(config_id), nx_int(level))
  elseif nx_find_custom(item, "is_static") and item.is_static then
    values = skill_query:QuerySkillBaseProps("", nx_string(config_id), nx_int(level))
  else
    values = skill_query:QuerySkillBaseProps(item, "", 0)
  end
  if type(values) ~= "table" then
    return ""
  end
  prepare_time = values[1]
  coolDown_time = values[2]
  consume_hp = values[3]
  consume_mp = values[4]
  consume_hp_p = values[5]
  consume_mp_p = values[6]
  consume_sp = values[7]
  consume_sp_p = values[8]
  consume_mp_base = values[9]
  prepare_time = nx_number(prepare_time)
  coolDown_time = nx_number(coolDown_time)
  local text = ""
  text = addprop_text(text, gui, "tips_yunqi_time", prepare_time / 1000)
  text = addprop_text(text, gui, "tips_huiqi_time", coolDown_time / 1000)
  text = addprop_text(text, gui, "tips_damage_hp", nx_int(consume_hp))
  text = addprop_text(text, gui, "tips_damage_neili", nx_int(consume_mp))
  text = addprop_text(text, gui, "tips_damage_hp_p", nx_int(consume_hp_p))
  text = addprop_text(text, gui, "tips_damage_neili_p", nx_int(consume_mp_p))
  text = addprop_text(text, gui, "tips_damage_neili_base", nx_int(consume_mp_base))
  text = addprop_text(text, gui, "tips_damage_sp", nx_int(consume_sp))
  text = addprop_text(text, gui, "tips_damage_sp_p", nx_int(consume_sp_p))
  return nx_widestr(text)
end
function show_taolu_next_level_need_xiuwei(item)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook then
    return ""
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return ""
  end
  if tips_manager.InShortcut then
    return ""
  end
  if tips_manager.IsMaxLevel then
    return ""
  end
  local curlevel_faculty, isfull = get_wuxu_curlevel_faculty(item, WUXUE_SKILL)
  local gui = nx_value("gui")
  local text = ""
  if isfull then
    text = gui.TextManager:GetFormatText("tips_taolu_lvlup_g", nx_widestr(curlevel_faculty))
  else
    text = gui.TextManager:GetFormatText("tips_taolu_lvlup_r", nx_widestr(curlevel_faculty))
  end
  text = nx_string(text) .. "<br>"
  return nx_widestr(text)
end
function show_skill_next_level(item, stringid)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) and tips_manager.InShortcut then
    return false, ""
  end
  local gui = nx_value("gui")
  local skill_configid = get_prop_in_item(item, "ConfigID")
  local StaticDataID = get_prop_in_item(item, "StaticData")
  local curlevel = get_prop_in_item(item, "Level")
  local nextlevel = nx_int(curlevel) + nx_int(1)
  local maxlevel = GetSkillMaxLevel(StaticDataID)
  if nx_int(nextlevel) > nx_int(maxlevel) then
    return false, ""
  end
  gui.TextManager:Format_SetIDName(stringid)
  gui.TextManager:Format_AddParam(nx_int(nextlevel))
  local text = ""
  text = nx_string(gui.TextManager:Format_GetText())
  if nx_ws_length(nx_widestr(text)) > 0 then
    text = nx_string(text) .. "<br>"
  else
    return false, ""
  end
  return true, text
end
function show_desc_info_next(item)
  local gui = nx_value("gui")
  local congfigid = get_prop_in_item(item, "ConfigID")
  local level = nx_int(get_prop_in_item(item, "Level"))
  level = nx_int(level) + nx_int(1)
  local desc_id = "desc_" .. congfigid .. "_" .. nx_string(level)
  local text = gui.TextManager:GetFormatText(desc_id)
  if nx_ws_length(nx_widestr(text)) > 0 then
    text = nx_string(text) .. "<br>"
  end
  return nx_widestr(text)
end
function show_skill_desc_info_next(item)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook then
    return ""
  end
  local gui = nx_value("gui")
  local congfigid = get_prop_in_item(item, "ConfigID")
  local level = nx_int(get_prop_in_item(item, "Level"))
  level = nx_int(level) + nx_int(1)
  local desc_id = "desc_" .. congfigid .. "_" .. nx_string(level)
  local damage_list = get_dynamic_demage_list(item, level)
  gui.TextManager:Format_SetIDName(nx_string(desc_id))
  if damage_list ~= nil then
    for j = 1, table.getn(damage_list) do
      gui.TextManager:Format_AddParam(nx_widestr(damage_list[j]))
    end
  end
  local text = nx_string(gui.TextManager:Format_GetText())
  if nx_ws_length(nx_widestr(text)) > 0 then
    text = nx_string(text) .. "<br>"
  end
  return nx_widestr(text)
end
function get_skill_desc_info(item)
  local gui = nx_value("gui")
  local congfigid = nx_string(get_prop_in_item(item, "ConfigID"))
  local level = nx_int(get_prop_in_item(item, "Level"))
  local desc_id = "desc_" .. congfigid .. "_" .. nx_string(level)
  local damage_list = get_dynamic_demage_list(item)
  gui.TextManager:Format_SetIDName(nx_string(desc_id))
  if damage_list ~= nil then
    for j = 1, table.getn(damage_list) do
      gui.TextManager:Format_AddParam(nx_widestr(damage_list[j]))
    end
  end
  local text = nx_widestr(gui.TextManager:Format_GetText())
  if nx_ws_length(nx_widestr(text)) > 0 then
    text = nx_widestr(text) .. nx_widestr("<br>")
  end
  return nx_widestr(text)
end
function show_skill_dynamic_demage(item, level)
  local config_id = get_prop_in_item(item, "ConfigID")
  local static_data_id = get_prop_in_item(item, "StaticData")
  local varprop = get_prop_in_item(item, "VarPropNo")
  if level ~= nil and level ~= "" then
    varprop = get_VarpropNo_by_level(SKILL_STATIC_INI, static_data_id, level)
  end
  local gui = nx_value("gui")
  local tips_str = ""
  local type = get_skill_type(config_id)
  local skill_ini = ""
  if nx_int(type) == nx_int(0) then
    skill_ini = SKILL_NORMAL_INI
  elseif nx_int(type) == nx_int(1) then
    skill_ini = SKILL_LOCK_INI
  end
  local damage_calculate = get_ini_prop(skill_ini, varprop, "DamageCalculate", "-1")
  local text = get_damage_cauculate_str(damage_calculate)
  return nx_widestr(text)
end
function get_dynamic_demage_list(item, level)
  local config_id = get_prop_in_item(item, "ConfigID")
  local static_data_id = get_prop_in_item(item, "StaticData")
  local varprop = get_prop_in_item(item, "VarPropNo")
  if level ~= nil and level ~= "" then
    varprop = get_VarpropNo_by_level(SKILL_STATIC_INI, static_data_id, level)
  end
  local gui = nx_value("gui")
  local tips_str = ""
  local type = get_skill_type(config_id)
  local skill_ini = ""
  if nx_int(type) == nx_int(0) then
    skill_ini = SKILL_NORMAL_INI
  elseif nx_int(type) == nx_int(1) then
    skill_ini = SKILL_LOCK_INI
  end
  local damage_cal_str = show_skill_dynamic_demage(item, level)
  if damage_cal_str == "" then
    return
  end
  local result = {}
  table.insert(result, damage_cal_str)
  local event_process = get_ini_prop(skill_ini, varprop, "EventProcess", "-1")
  local event_damage_list = get_damage_package_list(event_process)
  for _, v in ipairs(event_damage_list) do
    local event_damage_str = get_damage_cauculate_str(v)
    if event_damage_str ~= "" then
      table.insert(result, event_damage_str)
    end
  end
  return result
end
function get_damage_package_list(event_process)
  local result = {}
  local event_ini = get_ini_safe(SKILL_EVENT_PROCESS_INI)
  if not nx_is_valid(event_ini) then
    return result
  end
  if not event_ini:FindSection(nx_string(event_process)) then
    return result
  end
  local sec_index = event_ini:FindSectionIndex(nx_string(event_process))
  if sec_index < 0 then
    return result
  end
  local value_list = event_ini:GetItemValueList(sec_index, "r")
  for _, value in pairs(value_list) do
    local str_lst = util_split_string(nx_string(value), ",")
    if table.getn(str_lst) >= 4 then
      local func_type = str_lst[3]
      if func_type == "18" then
        table.insert(result, str_lst[4])
      end
    end
  end
  return result
end
function get_damage_cauculate_str(damage_calculate, damage_binglu)
  local gui = nx_value("gui")
  if damage_binglu == nil then
    damage_binglu = 0
  end
  binglu = damage_binglu
  local damage_ini = get_ini_safe(SKILL_DAMAGE_CALCULATE_INI)
  local formula_ini = get_ini_safe(SKILL_FORMULA_INI)
  if not nx_is_valid(damage_ini) or not nx_is_valid(formula_ini) then
    return ""
  end
  if not damage_ini:FindSection(nx_string(damage_calculate)) then
    return ""
  end
  local sec_index = damage_ini:FindSectionIndex(nx_string(damage_calculate))
  if sec_index < 0 then
    return ""
  end
  local value_list = damage_ini:GetItemValueList(sec_index, "r")
  for _, value in pairs(value_list) do
    local str_lst = util_split_string(nx_string(value), ",")
    local formula_id = str_lst[1]
    local result_list = process_damage_calculate(str_lst, formula_ini)
    local text_id = get_ini_prop(SKILL_FORMULA_INI, nx_string(formula_id), "TipFormatStrID", "")
    if text_id ~= "" then
      gui.TextManager:Format_SetIDName(nx_string(text_id))
      for j = 1, table.getn(result_list) do
        gui.TextManager:Format_AddParam(nx_widestr(result_list[j]))
      end
      tips_str = gui.TextManager:Format_GetText()
    else
      tips_str = ""
    end
  end
  return nx_widestr(tips_str)
end
function process_damage_calculate(str_lst, formula_ini)
  local formula_id = str_lst[1]
  local damage_type = str_lst[2]
  local paras = {}
  for j = 3, table.getn(str_lst) do
    paras[j - 2] = str_lst[j]
  end
  return process_formula(formula_id, damage_type, paras, formula_ini)
end
function process_formula(formula_id, damage_type, paras, formula_ini)
  local result_list = {}
  if not formula_ini:FindSection(nx_string(formula_id)) then
    return result_list
  end
  local srcs = {}
  local sec_index = formula_ini:FindSectionIndex(nx_string(formula_id))
  if sec_index < 0 then
    return result_list
  end
  for k = 1, SKILL_PROP_COUNT do
    srcs[k] = formula_ini:ReadString(sec_index, "Src" .. nx_string(k), "0")
  end
  local param_props = {}
  for k = 1, SKILL_PROP_COUNT do
    param_props[k] = formula_ini:ReadString(sec_index, "Prop" .. nx_string(k), "")
  end
  prop = get_formula_param_value(srcs, param_props)
  argv = {}
  argv[1] = {}
  argv[1][0] = 0
  argv[1][1] = 0
  argv[2] = {}
  argv[2][0] = 0
  argv[2][1] = 0
  for j = 1, table.getn(paras) do
    local cur_para = paras[j]
    local cur_src = srcs[j]
    if cur_para ~= "" then
      local replace = ""
      if nx_int(cur_src) == nx_int(5) then
        argv[j] = nx_number(cur_para)
      else
        if nx_int(cur_src) == nx_int(6) then
          local vallst = util_split_string(cur_para, ";")
          argv[j] = {}
          if 1 < table.getn(vallst) then
            argv[j][0] = nx_number(vallst[1])
            argv[j][1] = nx_number(vallst[2])
          else
            argv[j][0] = 0
            argv[j][1] = 0
          end
        else
        end
      end
    end
  end
  local formula_text = formula_ini:ReadString(sec_index, "TipFormatArgv", "")
  local formula_list = util_split_string(formula_text, ",")
  for j = 1, table.getn(formula_list) do
    local result = ""
    local str = formula_list[j]
    local result = 0
    if check_formula_error(str) then
      result = check_formula(str, damage_type)
    else
    end
    result_list[j] = result
  end
  return result_list
end
function check_formula_error(tag)
  if tag == "TAG_FORMULA_GET_DMG_TYPE" then
    return true
  end
  local i, j = 0, 0
  local argv_count = table.getn(argv)
  local prop_count = table.getn(prop)
  while true do
    i, j = string.find(tag, "argv%[%d%]", j + 1)
    if j == nil then
      break
    end
    local argv_index = nx_number(string.sub(tag, j - 1, j - 1))
    if argv_count < argv_index then
      return false
    end
    if type(argv[argv_index]) == "table" and string.len(tag) > j + 2 and string.sub(tag, j + 1, j + 1) ~= "%[" then
      return false
    end
  end
  i, j = 0, 0
  while true do
    i, j = string.find(tag, "prop%[%d%]", j + 1)
    if j == nil then
      break
    end
    local prop_index = nx_number(string.sub(tag, j - 1, j - 1))
    if prop_count < prop_index then
      return false
    end
  end
  return true
end
function check_formula(tag, damage_type)
  local gui = nx_value("gui")
  local res_text = ""
  if nx_string(tag) == "TAG_FORMULA_GET_DMG_TYPE" then
    res_text = get_demage_type(gui, damage_type)
  else
    local func = loadstring("return " .. nx_string(tag))
    local value = func()
    if value ~= nil then
      res_text = nx_int(value)
    end
  end
  return nx_widestr(res_text)
end
function get_demage_type(gui, damage_type)
  return gui.TextManager:GetFormatText(nx_string("tips_skill_") .. nx_string(damage_type))
end
function get_formula_param_value(srcs, param_props)
  local result = {}
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  for i = 1, SKILL_PROP_COUNT do
    if not nx_is_valid(client_player) then
      result[i] = 0
    end
    if srcs[i] == "0" and param_props[i] ~= "" and client_player:FindProp(param_props[i]) then
      result[i] = nx_number(client_player:QueryProp(param_props[i]))
    else
      result[i] = 0
    end
  end
  return result
end
function find_upgrade_by_configid_and_level(item, configid, is_next)
  local StaticData_id = get_prop_in_item(item, "StaticData")
  local level = get_prop_in_item(item, "Level")
  local min_varpropno = get_prop_in_static_query(STATIC_DATA_NEIGONG, StaticData_id, "MinVarPropNo")
  local varpropno = nx_int(min_varpropno) + nx_int(level) - nx_int(1)
  if is_next then
    varpropno = nx_int(varpropno) + nx_int(1)
  end
  varpropno = nx_string(varpropno)
  local neigong_varprop_ini = get_ini_safe(NEIGONG_VARPROP_INI)
  if not nx_is_valid(neigong_varprop_ini) then
    return
  end
  if not neigong_varprop_ini:FindSection(varpropno) then
    return
  end
  local sec_index = neigong_varprop_ini:FindSectionIndex(varpropno)
  if sec_index < 0 then
    return
  end
  local upgrade = {}
  upgrade[1] = neigong_varprop_ini:ReadString(sec_index, "StrAdd", "0")
  upgrade[2] = neigong_varprop_ini:ReadString(sec_index, "IngAdd", "0")
  upgrade[3] = neigong_varprop_ini:ReadString(sec_index, "DexAdd", "0")
  upgrade[4] = neigong_varprop_ini:ReadString(sec_index, "SpiAdd", "0")
  upgrade[5] = neigong_varprop_ini:ReadString(sec_index, "StaAdd", "0")
  return upgrade
end
function add_int_info(strID, color, prop_value)
  local gui = nx_value("gui")
  if not gui.TextManager:IsIDName(nx_string(strID)) then
    return nx_widestr(strID)
  end
  gui.TextManager:Format_SetIDName(nx_string(strID))
  if color ~= nil then
    gui.TextManager:Format_AddParam(nx_string(color))
  end
  gui.TextManager:Format_AddParam(nx_int(prop_value))
  local text = gui.TextManager:Format_GetText()
  return text
end
function show_neigong_next_level_need_xiuwei(item)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook then
    return ""
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return ""
  end
  if tips_manager.InShortcut then
    return ""
  end
  if tips_manager.IsMaxLevel then
    return ""
  end
  local curlevel_faculty, isfull = get_wuxu_curlevel_faculty(item, WUXUE_NEIGONG)
  local gui = nx_value("gui")
  local text = ""
  if isfull then
    text = gui.TextManager:GetFormatText("tips_ng_lvlup_g", nx_widestr(curlevel_faculty))
  else
    text = gui.TextManager:GetFormatText("tips_ng_lvlup_r", nx_widestr(curlevel_faculty))
  end
  text = nx_string(text) .. "<br>"
  return nx_widestr(text)
end
function show_neigong_prop_info(item)
  local gui = nx_value("gui")
  local nameid = get_prop_in_item(item, "ConfigID")
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return ""
  end
  local item_type = nx_execute("tips_func_equip", "get_item_type", item, configid)
  item_type = nx_number(item_type)
  local last_upgrade_lst = find_upgrade_by_configid_and_level(item, nameid, false)
  if last_upgrade_lst == nil then
    return ""
  end
  local just_show_cur = false
  local curlevel = get_prop_in_item(item, "Level")
  curlevel = nx_number(curlevel)
  local max_level = skill_query:GetSkillMaxLevel(item, item_type)
  if curlevel >= max_level then
    just_show_cur = true
  end
  local upgrade_lst = find_upgrade_by_configid_and_level(item, nameid, true)
  if upgrade_lst == nil then
    just_show_cur = true
  end
  local out_text = show_ng_prop_one("tips_neigong_desc_prop_str", last_upgrade_lst, upgrade_lst, 1, just_show_cur)
  out_text = out_text .. show_ng_prop_one("tips_neigong_desc_prop_dex", last_upgrade_lst, upgrade_lst, 3, just_show_cur)
  out_text = out_text .. show_ng_prop_one("tips_neigong_desc_prop_ing", last_upgrade_lst, upgrade_lst, 2, just_show_cur)
  out_text = out_text .. show_ng_prop_one("tips_neigong_desc_prop_spi", last_upgrade_lst, upgrade_lst, 4, just_show_cur)
  out_text = out_text .. show_ng_prop_one("tips_neigong_desc_prop_sta", last_upgrade_lst, upgrade_lst, 5, just_show_cur)
  return nx_widestr(out_text)
end
function show_ng_prop_one(strid, last_upgrade_lst, upgrade_lst, index, just_show_cur)
  local prop = nx_widestr(add_int_info(strid, COLOR_White, last_upgrade_lst[index]))
  if just_show_cur then
    return prop .. nx_widestr("<br>")
  end
  local photo1 = nx_widestr("<img src=\"gui\\special\\tips\\Arrow_1.png\" only=\"line\" valign=\"center\"/>")
  local photo2 = nx_widestr("<img src=\"gui\\special\\tips\\Arrow_2.png\" only=\"line\" valign=\"center\"/>")
  prop = prop .. photo1 .. get_text_by_color(upgrade_lst[index], COLOR_Gray)
  prop = prop .. get_ng_change_value(photo2, last_upgrade_lst[index], upgrade_lst[index], COLOR_Value)
  return prop
end
function show_confirm(info)
  local gui = nx_value("gui")
  local form = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", form, info)
  form:ShowModal()
end
function get_ng_change_value(photo2, cur, next, color)
  local add = nx_int(nx_int(next) - nx_int(cur))
  if nx_int(add) < nx_int(1) then
    return nx_widestr("<br>")
  end
  local text = nx_widestr(photo2) .. nx_widestr(get_text_by_color(add, color)) .. nx_widestr("<br>")
  return text
end
function get_jm_change_value(photo2, cur, next, color)
  local add = nx_int(nx_int(next) - nx_int(cur))
  if nx_int(add) < nx_int(1) then
    return nx_widestr("<br>")
  end
  local text = nx_widestr(photo2) .. nx_widestr(get_text_by_color(add, color)) .. nx_widestr("<br>")
  return text
end
function get_neigong_addProp(item, is_next)
  local gui = nx_value("gui")
  local StaticData_id = get_prop_in_item(item, "StaticData")
  local level = get_prop_in_item(item, "Level")
  local min_varpropno = get_prop_in_static_query(STATIC_DATA_NEIGONG, StaticData_id, "MinVarPropNo")
  local maxvarpropno = get_prop_in_static_query(STATIC_DATA_NEIGONG, StaticData_id, "MaxVarPropNo")
  local varpropno = nx_int(min_varpropno) + nx_int(level) - nx_int(1)
  maxvarpropno = nx_int(maxvarpropno)
  if is_next then
    varpropno = varpropno + nx_int(1)
  end
  local forever_add_prop = ""
  local addprop_lst = find_tips_ids(varpropno, NEIGONG_VARPROP_INI)
  local color = "#00ff00"
  if nx_int(varpropno) > nx_int(maxvarpropno) then
    color = "#565656"
  end
  if nil ~= addprop_lst then
    for j = 1, table.getn(addprop_lst) do
      forever_add_prop = forever_add_prop .. nx_string(gui.TextManager:GetFormatText(addprop_lst[j], nx_string(color))) .. "<br>"
    end
  end
  if nx_ws_length(nx_widestr(forever_add_prop)) > 0 then
    local add_text = nx_string(gui.TextManager:GetFormatText("tips_neigong_add_text")) .. "<br>" .. nx_string(forever_add_prop)
    return nx_widestr(add_text)
  else
    return ""
  end
end
function show_neigong_addProp(item)
  return get_neigong_addProp(item, false)
end
function show_neigong_next_addProp(item)
  return get_neigong_addProp(item, true)
end
function get_neigong_desc(item)
  local gui = nx_value("gui")
  local nameid = get_prop_in_item(item, "ConfigID")
  local note = gui.TextManager:GetText("desc_" .. nx_string(nameid))
  if nx_ws_length(nx_widestr(note)) > 0 then
    note = nx_string(note) .. "<br>"
    return nx_widestr(note)
  else
    return ""
  end
end
function is_Max_level(item, level)
  local configid = get_prop_in_item(item, "ConfigID")
  local ng_obj = get_item_in_view(VIEWPORT_NEIGONG, configid)
  if not nx_is_valid(ng_obj) then
    return
  end
  local StaticData_id = ng_obj:QueryProp("StaticData")
  local varpropno = get_prop_in_static_query(STATIC_DATA_NEIGONG, StaticData_id, "MinVarPropNo")
  local maxvarpropno = get_prop_in_static_query(STATIC_DATA_NEIGONG, StaticData_id, "MaxVarPropNo")
  varpropno = nx_int(varpropno)
  maxvarpropno = nx_int(maxvarpropno)
  local MaxLevel = maxvarpropno - varpropno + 1
  if nx_int(level) > nx_int(MaxLevel) then
    return true
  end
  return false
end
function show_neigong_next_level(item, str_id)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) and tips_manager.InShortcut then
    return false, ""
  end
  local curlevel = get_prop_in_item(item, "Level")
  curlevel = nx_int(curlevel)
  local nextlevel = curlevel + 1
  if is_Max_level(item, nextlevel) then
    return false, ""
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(str_id)
  gui.TextManager:Format_AddParam(nx_int(nextlevel))
  local text = nx_string(gui.TextManager:Format_GetText())
  if nx_ws_length(nx_widestr(text)) > 0 then
    text = nx_string(text) .. "<br>"
  else
    return false, ""
  end
  return true, text
end
function get_skill_level(item)
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return ""
  end
  local item_type = nx_execute("tips_func_equip", "get_item_type", item, configid)
  local max_level = 0
  if nx_find_method(skill_query, "GetSkillMaxLevel") then
    max_level = skill_query:GetSkillMaxLevel(item, item_type)
  else
    local StaticDataID = get_prop_in_item(item, "StaticData")
    max_level = GetSkillMaxLevel(StaticDataID)
  end
  local curlevel = get_prop_in_item(item, "Level")
  if max_level == -1 then
    return ""
  end
  local gui = nx_value("gui")
  local out_text = gui.TextManager:GetFormatText("tips_level_text4", curlevel, max_level)
  if 0 < nx_ws_length(nx_widestr(out_text)) then
    out_text = nx_widestr(out_text) .. nx_widestr("<br>")
  end
  return nx_widestr(out_text)
end
function get_qgskill_type(item)
  local static_data = get_prop_in_item(item, "StaticData")
  local type = nx_execute("util_static_data", "qgskill_static_query", static_data, "QingGongType")
  local str_id = "qinggong_" .. nx_string(type)
  local gui = nx_value("gui")
  local title = gui.TextManager:GetText("tips_qgshenfa_text")
  local note = gui.TextManager:GetText(str_id)
  note = nx_string(title) .. nx_string(note) .. "<br>"
  return nx_widestr(note)
end
function show_qgskill_props(item)
  return get_qgskill_props(item, false)
end
function show_qgskill_props_next(item)
  return get_qgskill_props(item, true)
end
function get_qgskill_props(item, bNext)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook and bNext == true then
    return ""
  end
  local varpropini = nx_execute("util_functions", "get_ini", SKILL_QG_VARPROP_INI)
  if not nx_is_valid(varpropini) then
    return ""
  end
  local varpropno = get_prop_in_item(item, "VarPropNo")
  if bNext then
    varpropno = nx_int(varpropno) + nx_int(1)
  end
  varpropno = nx_string(varpropno)
  local out_text = ""
  local gui = nx_value("gui")
  if not varpropini:FindSection(varpropno) then
    return ""
  end
  local sec_index = varpropini:FindSectionIndex(varpropno)
  if sec_index < 0 then
    return ""
  end
  local Consumedec = nx_number(varpropini:ReadString(sec_index, "Consumedec", "0"))
  if 0 < Consumedec then
    out_text = gui.TextManager:GetFormatText("tips_qg_Consumedec", Consumedec)
    out_text = nx_string(out_text) .. "<br>"
  end
  local tips_id_rec = {}
  local pack_id_rec = {}
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@PropModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_proppack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@SkillModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_skillpack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@BuffModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_buffpack_" .. nx_string(pack_id_rec[i]))
  end
  for j = 1, table.getn(tips_id_rec) do
    local text = gui.TextManager:GetFormatText(tips_id_rec[j])
    out_text = nx_string(out_text) .. nx_string(text) .. "<br>"
  end
  return nx_widestr(out_text)
end
function get_zf_canuse(item)
  local static_data = get_prop_in_item(item, "StaticData")
  local NeedWeapon = nx_execute("util_static_data", "zhenfa_static_query", static_data, "NeedWeapon")
  NeedWeapon = nx_number(NeedWeapon)
  if NeedWeapon < 100 then
    return ""
  end
  local get_type = 22
  if 110 <= NeedWeapon and NeedWeapon < 120 then
    get_type = 23
  end
  local waepon_type = get_weapon_type(get_type)
  local color = COLOR_Red
  if waepon_type == NeedWeapon then
    color = COLOR_Value
  end
  local gui = nx_value("gui")
  local out_text = ""
  local title = nx_string(gui.TextManager:GetFormatText("tips_use_limit"))
  local str_id = "tips_ItemType_equal_" .. nx_string(NeedWeapon)
  local text = gui.TextManager:GetFormatText(str_id)
  out_text = title .. get_text_by_color(text, color)
  out_text = out_text .. "<br>"
  return nx_widestr(out_text)
end
function get_zhenfa_count(item)
  local gui = nx_value("gui")
  local zhenfamap = get_prop_in_item(item, "ZheFaMap")
  local count = get_ini_prop("share\\Skill\\zhenfa_map.ini", nx_string(zhenfamap), "count", "")
  local text = gui.TextManager:GetFormatText("tips_zhenfa_member_count", nx_int(nx_number(count) + 1))
  text = nx_string(text) .. "<br>"
  return nx_widestr(text)
end
function get_zhenfa_use_info(item)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("tips_zhenfa_canuse")
  local text = get_text_by_color(text, COLOR_Gray)
  text = nx_string(text) .. "<br>"
  return nx_widestr(text)
end
function show_zhenfa_prop_cur(item)
  return get_zhenfa_prop(item, false)
end
function show_zhenfa_next_level_need_xiuwei(item)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook then
    return ""
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return ""
  end
  if tips_manager.InShortcut then
    return ""
  end
  if tips_manager.IsMaxLevel then
    return ""
  end
  local curlevel_faculty, isfull = get_wuxu_curlevel_faculty(item, WUXUE_ZHENFA)
  local gui = nx_value("gui")
  local text = ""
  if isfull then
    text = gui.TextManager:GetFormatText("tips_zhenfa_lvlup_g", nx_widestr(curlevel_faculty))
  else
    text = gui.TextManager:GetFormatText("tips_zhenfa_lvlup_r", nx_widestr(curlevel_faculty))
  end
  text = nx_string(text) .. "<br>"
  return nx_widestr(text)
end
function show_zhenfa_prop_next(item)
  return get_zhenfa_prop(item, true)
end
function get_zhenfa_prop(item, bNext)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook then
    return ""
  end
  local gui = nx_value("gui")
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return ""
  end
  local config_id = get_prop_in_item(item, "ConfigID")
  local values = {}
  values = skill_query:QueryZhenFaBaseProps(item, nx_string(config_id), bNext)
  if type(values) ~= "table" then
    return ""
  end
  Range = values[1]
  prepare_time = nx_number(values[2])
  coolDown_time = nx_number(values[3])
  hit_time = nx_number(values[4])
  consume_hp = values[5]
  consume_mp = values[6]
  consume_hp_p = values[7]
  consume_mp_p = values[8]
  local text = ""
  text = addprop_text(text, gui, "tips_zhenfa_range", nx_int(Range))
  text = addprop_text(text, gui, "tips_yunqi_time", prepare_time / 1000)
  text = addprop_text(text, gui, "tips_huiqi_time", coolDown_time / 1000)
  text = addprop_text(text, gui, "tips_zhenfa_keep_time", nx_int(hit_time / 1000))
  text = addprop_text(text, gui, "tips_damage_hp", nx_int(consume_hp))
  text = addprop_text(text, gui, "tips_damage_neili", nx_int(consume_mp))
  text = addprop_text(text, gui, "tips_damage_hp_p", nx_int(consume_hp_p))
  text = addprop_text(text, gui, "tips_damage_neili_p", nx_int(consume_mp_p))
  return nx_widestr(text)
end
function addprop_text(text, gui, str_id, num)
  if nx_string(num) ~= "" and nx_string(num) ~= "%" and nx_int(num) > nx_int(0) then
    local str = gui.TextManager:GetFormatText(str_id, num)
    return nx_string(text) .. nx_string(str) .. "<br>"
  end
  return nx_string(text)
end
function is_max_zhenfa_level(item, level)
  local static_data = get_prop_in_item(item, "StaticData")
  local varpropno = get_prop_in_item(item, "VarPropNo")
  local maxvarpropno = nx_execute("util_static_data", "zhenfa_static_query", static_data, "MaxVarPropNo")
  varpropno = nx_int(varpropno)
  maxvarpropno = nx_int(maxvarpropno)
  local MaxLevel = maxvarpropno - varpropno + 1
  if nx_int(level) > nx_int(MaxLevel) then
    return true
  end
  return false
end
function get_zhenfa_next_level(item, str_id)
  local curlevel = get_prop_in_item(item, "Level")
  local nextlevel = nx_number(curlevel) + 1
  if is_max_zhenfa_level(item, nextlevel) then
    return false, ""
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(str_id)
  gui.TextManager:Format_AddParam(nx_int(nextlevel))
  local text = nx_string(gui.TextManager:Format_GetText())
  if nx_ws_length(nx_widestr(text)) > 0 then
    text = nx_string(text) .. "<br>"
  else
    return false, ""
  end
  return true, text
end
function get_zhenfa_next_desc(item)
  local curlevel = get_prop_in_item(item, "Level")
  local nextlevel = nx_number(curlevel) + 1
  if is_max_zhenfa_level(item, nextlevel) then
    return ""
  end
  return show_desc_info_next(item)
end
function parse_color(color)
  local alpha = 0
  local red = 0
  local green = 0
  local blue = 0
  local color_list = util_split_string(color, ",")
  if table.getn(color_list) >= 4 then
    alpha = nx_number(color_list[1])
    red = nx_number(color_list[2])
    green = nx_number(color_list[3])
    blue = nx_number(color_list[4])
  end
  return alpha, red, green, blue
end
function get_hex_color(color)
  if color == nil or color == "" then
    return ""
  end
  local alpha, red, green, blue = parse_color(color)
  return "#" .. string.format("%02x", red) .. string.format("%02x", green) .. string.format("%02x", blue)
end
function show_name_with_colorlevel(item)
  local gui = nx_value("gui")
  local config_id = get_prop_in_item(item, "ConfigID")
  local static_data = get_prop_in_item(item, "StaticData")
  local color_level = skill_static_query(static_data, "ColorLevel")
  local name = gui.TextManager:GetFormatText(config_id)
  if color_level ~= nil and nx_string(color_level) ~= "" then
    local color = get_ini_prop(ZHAOSHI_OTHER_INI, nx_string(color_level), "color", "")
    if color ~= "" then
      color = get_hex_color(color)
      name = get_text_by_color(name, color)
    end
  end
  return name
end
function show_skill_cdturns(skill)
  local jewelGameManager = nx_value("jewel_game_manager")
  if not nx_is_valid(jewelGameManager) then
    return ""
  end
  local gui = nx_value("gui")
  local id = get_prop_in_item(skill, "ConfigID")
  local cd_value = jewelGameManager:GetCDTurns(nx_string(id))
  cd_value = nx_widestr(cd_value)
  local text = nx_widestr("")
  if nx_int(cd_value) ~= nx_int(0) then
    text = gui.TextManager:GetText("tips_gemskill_1") .. cd_value .. nx_widestr("<br>")
    if nx_int(cd_value) > nx_int(100) then
      text = gui.TextManager:GetText("tips_gemskill_2") .. nx_widestr("<br>")
    end
  else
    text = gui.TextManager:GetText("tips_gemskill_0") .. nx_widestr("<br>")
  end
  return nx_widestr(text)
end
local POINT_PIC_PATH = {
  [1] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\ahong-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\ahong32.png"
  },
  [2] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\ahuang-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\ahuang32.png"
  },
  [3] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\alan-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\alan32.png"
  },
  [4] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\alv-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\alv32.png"
  },
  [5] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\azi-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\azi32.png"
  }
}
function get_puzzle_prop(item)
  local jewel_game_manager = nx_value("jewel_game_manager")
  if not nx_is_valid(jewel_game_manager) then
    return ""
  end
  local id = get_prop_in_item(item, "ConfigID")
  local text = ""
  local value = jewel_game_manager:GetNeedRed(nx_string(id))
  if nx_int(value) >= nx_int(1) then
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[1][1])) .. nx_string(value) .. nx_string(" ")
  else
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[1][2])) .. nx_string("  ")
  end
  value = jewel_game_manager:GetNeedYellow(nx_string(id))
  if nx_int(value) >= nx_int(1) then
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[2][1])) .. nx_string(value) .. nx_string(" ")
  else
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[2][2])) .. nx_string("  ")
  end
  value = jewel_game_manager:GetNeedBlue(nx_string(id))
  if nx_int(value) >= nx_int(1) then
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[3][1])) .. nx_string(value) .. nx_string(" ")
  else
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[3][2])) .. nx_string("  ")
  end
  value = jewel_game_manager:GetNeedGreen(nx_string(id))
  if nx_int(value) >= nx_int(1) then
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[4][1])) .. nx_string(value) .. nx_string(" ")
  else
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[4][2])) .. nx_string("  ")
  end
  value = jewel_game_manager:GetNeedPurple(nx_string(id))
  if nx_int(value) >= nx_int(1) then
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[5][1])) .. nx_string(value) .. nx_string(" ")
  else
    text = text .. nx_string(get_photo_html(POINT_PIC_PATH[5][2])) .. nx_string("  ")
  end
  text = "<center>" .. text .. "</center>"
  return nx_widestr(text)
end
function show_anqi_need(item)
  local configid = get_prop_in_item(item, "ConfigID")
  local gui = nx_value("gui")
  local title = gui.TextManager:GetFormatText("tips_need_anqi")
  local weapon = get_ini_prop(SHOUFA_ANQI_INI, configid, "r", "")
  if nx_string(weapon) == "" then
    return ""
  end
  local out_text = nx_string(title) .. "<br>" .. nx_string(gui.TextManager:GetFormatText(weapon))
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return out_text .. "<br>"
  end
  local obj = game_client:GetViewObj(nx_string(VIEWPORT_EQUIP), "23")
  local id = ""
  if nx_is_valid(obj) then
    id = obj:QueryProp("ConfigID")
  end
  local is_equip = ""
  if nx_string(weapon) == nx_string(id) then
    is_equip = nx_string(gui.TextManager:GetFormatText("tips_anqi_yes"))
  else
    is_equip = nx_string(gui.TextManager:GetFormatText("tips_anqi_no"))
  end
  out_text = out_text .. is_equip .. "<br>"
  return nx_widestr(out_text)
end
function show_anqi_shoufa(item)
  local gui = nx_value("gui")
  local configid = get_prop_in_item(item, "ConfigID")
  local curlevel = get_prop_in_item(item, "Level")
  local value = gui.TextManager:GetFormatText("desc_active_" .. nx_string(configid) .. "_" .. nx_string(curlevel))
  if nx_ws_length(nx_widestr(value)) > 0 then
    value = nx_string(value) .. "<br>"
    return nx_widestr(value)
  end
  return ""
end
function show_anqi_desc(item)
  local configid = get_prop_in_item(item, "ConfigID")
  local gui = nx_value("gui")
  local value = gui.TextManager:GetFormatText("desc_" .. nx_string(configid))
  value = nx_string(value) .. "<br>"
  return nx_widestr(value)
end
function show_shoufa_props_next(item)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook then
    return ""
  end
  local gui = nx_value("gui")
  local configid = get_prop_in_item(item, "ConfigID")
  local curlevel = get_prop_in_item(item, "Level")
  curlevel = nx_int(curlevel) + nx_int(1)
  local value = gui.TextManager:GetFormatText("desc_active_" .. nx_string(configid) .. "_" .. nx_string(curlevel))
  if nx_ws_length(nx_widestr(value)) > 0 then
    value = nx_string(value) .. "<br>"
    return nx_widestr(value)
  end
  return ""
end
function get_jingfa_level(item)
  local configid = get_prop_in_item(item, "ConfigID")
  local SPLevel = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_huihai", "get_jinfa_prop", configid, "SPLevel")
  if nx_string(SPLevel) == "" then
    return ""
  end
  local gui = nx_value("gui")
  local value = gui.TextManager:GetFormatText("tips_jingfa_level_" .. nx_string(SPLevel))
  value = nx_string(value) .. "<br>"
  return nx_widestr(value)
end
function get_jingfa_props(item)
  local configid = get_prop_in_item(item, "ConfigID")
  local BuffID = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_huihai", "get_jinfa_prop", configid, "BuffID")
  if nx_string(BuffID) == "" then
    return ""
  end
  local gui = nx_value("gui")
  local value = gui.TextManager:GetFormatText("tips_jingfa_buff_" .. nx_string(BuffID))
  value = nx_string(value) .. "<br>"
  return nx_widestr(value)
end
function get_jingfa_consume(item)
  local configid = get_prop_in_item(item, "ConfigID")
  local gui = nx_value("gui")
  local value = ""
  local bActive = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_huihai", "check_has_jinfa", configid)
  if bActive then
    local type = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_huihai", "get_jinfa_prop", configid, "Type")
    value = gui.TextManager:GetFormatText("tips_jingfa_type_" .. nx_string(type))
    return nx_string(value) .. "<br>"
  end
  local CastPoint = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_huihai", "get_jinfa_prop", configid, "CastPoint")
  if nx_string(CastPoint) == "" then
    return ""
  end
  value = gui.TextManager:GetFormatText("tips_jingfa_CastPoint", CastPoint)
  value = nx_string(value) .. "<br>"
  return nx_widestr(value)
end
function show_anqi_next_level_need_xiuwei(item)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook then
    return ""
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return ""
  end
  if tips_manager.InShortcut then
    return ""
  end
  if tips_manager.IsMaxLevel then
    return ""
  end
  local curlevel_faculty, isfull = get_wuxu_curlevel_faculty(item, WUXUE_ANQI)
  local gui = nx_value("gui")
  local text = ""
  if isfull then
    text = gui.TextManager:GetFormatText("tips_aqshoufa_lvlup_g", nx_widestr(curlevel_faculty))
  else
    text = gui.TextManager:GetFormatText("tips_aqshoufa_lvlup_r", nx_widestr(curlevel_faculty))
  end
  text = nx_string(text) .. "<br>"
  return nx_widestr(text)
end
function show_chess_cool_down(item)
  local configid = get_prop_in_item(item, "ConfigID")
  local cd_time = get_ini_prop("share\\War\\chinesechessskill.ini", configid, "CDTime", "0")
  if cd_time == "0" then
    return ""
  end
  local gui = nx_value("gui")
  local value = gui.TextManager:GetFormatText("tips_chees_cool", nx_int(cd_time))
  value = nx_string(value) .. "<br>"
  return nx_widestr(value)
end
function get_qgtype_left(item)
  local configid = get_prop_in_item(item, "ConfigID")
  local text = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_qinggong", "get_qinggong_consume_desc", configid)
  text = text .. "<br>"
  return nx_widestr(text)
end
function show_qinggong_next_level_need_xiuwei(item)
  local isskillbook = get_prop_in_item(item, "IsSkillBook")
  if true == isskillbook then
    return ""
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return ""
  end
  if tips_manager.InShortcut then
    return ""
  end
  if tips_manager.IsMaxLevel then
    return ""
  end
  local curlevel_faculty, isfull = get_wuxu_curlevel_faculty(item, WUXUE_QGSKILL)
  local gui = nx_value("gui")
  local text = ""
  if isfull then
    text = gui.TextManager:GetFormatText("tips_qgskill_lvlup_g", nx_widestr(curlevel_faculty))
  else
    text = gui.TextManager:GetFormatText("tips_qgskill_lvlup_r", nx_widestr(curlevel_faculty))
  end
  text = nx_string(text) .. "<br>"
  return nx_widestr(text)
end
function get_qgtype_desc(item)
  local configid = get_prop_in_item(item, "ConfigID")
  local gui = nx_value("gui")
  local text = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_qinggong", "get_qg_eff_desc", configid)
  local desc = ""
  if nx_string(text) ~= "" then
    desc = text .. "<br>"
  end
  desc = desc .. nx_string(gui.TextManager:GetText("desc_wenhua_" .. configid)) .. "<br>"
  return nx_widestr(desc)
end
function get_wuxu_curlevel_faculty(item, wuxue_type)
  local curlevel = nx_number(get_prop_in_item(item, "Level"))
  local nameid = get_prop_in_item(item, "ConfigID")
  local wuxue_object = get_wuxue_object(nameid, wuxue_type)
  if not nx_is_valid(wuxue_object) then
    return 0
  end
  local total_curlevel_faculty = wuxue_object:QueryProp("TotalFillValue")
  local fillvalue_cur = wuxue_object:QueryProp("CurFillValue")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local faculty = client_player:QueryProp("Faculty")
  return total_curlevel_faculty - fillvalue_cur, total_curlevel_faculty <= faculty + fillvalue_cur
end
function get_desc_info(item)
  return nx_execute("tips_func_equip", "get_desc_info", item)
end
