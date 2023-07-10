require("util_static_data")
require("tips_func_equip")
require("share\\itemtype_define")
Ingredient_INI = "share\\Item\\item_ingredient_static.ini"
Formula_INI = "share\\Item\\life_formula.ini"
JOB_INI = "share\\Life\\job.ini"
local g_ydc_pinzhi = {
  "YSSkillLevel1",
  "YSSkillLevel2",
  "YSSkillLevel3",
  "CSSkillLevel",
  "DSSkillLevel"
}
function show_ydc_goods_pinzhi(item)
  local item_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
  local item_type = nx_execute("tips_func_equip", "get_item_type", item)
  if nx_int(item_type) ~= nx_int(ITEMTYPE_COMPOSE_YAOSAN) and nx_int(item_type) ~= nx_int(ITEMTYPE_COMPOSE_SHIWU) then
    return ""
  end
  local pz_key = nx_execute("tips_data", "get_prop_in_item", item, "PZKey")
  local pz_value = nx_execute("tips_data", "get_prop_in_item", item, "PZValue")
  if pz_key == nil or pz_key == "" or pz_value == nil or pz_value == "" then
    pz_key, pz_value = get_ydc_pingzhi(item)
  end
  if pz_key == nil or pz_key == "" or pz_value == nil or pz_value == "" then
    return ""
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local key = "tips_sh_" .. nx_string(pz_key)
  local text = gui.TextManager:GetFormatText(key, nx_int(pz_value))
  return nx_widestr(nx_string(text) .. "<br>")
end
function get_ydc_pingzhi(item)
  local pingzhi_key = ""
  local pingzhi_value = ""
  for i = 1, table.getn(g_ydc_pinzhi) do
    pingzhi_key = g_ydc_pinzhi[i]
    pingzhi_value = nx_execute("tips_data", "get_prop_in_item", item, nx_string(pingzhi_key))
    if pingzhi_value ~= nil and pingzhi_value ~= "" then
      break
    end
  end
  if pingzhi_value ~= "" and nx_string(pingzhi_key) == "YSSkillLevel1" then
    pingzhi_value = pingzhi_value / 12
  end
  return pingzhi_key, pingzhi_value
end
function show_goods_type(item)
  local text = nx_execute("tips_func_equip", "show_item_type_text", item)
  return nx_widestr(text)
end
function get_bind_status(item)
  local text = nx_execute("tips_func_equip", "get_bind_status", item)
  return nx_widestr(text)
end
function show_equip_production_info(config_id, item_type)
  local color_level = nx_number(get_prop_in_ItemQuery(config_id, "ColorLevel"))
  local need_sex = get_prop_in_ItemQuery(config_id, "NeedSex")
  local tex_name = func_get_name(color_level, config_id)
  local tex_type = func_get_type(item_type)
  local tex_sex = func_get_sex(need_sex)
  local tex_num = func_get_num("", true, item_type, config_id)
  local item_Array = nx_call("util_gui", "get_arraylist", "tips_func_goods:show_equip_production_info")
  local Level = get_prop_in_ItemQuery(config_id, "Level")
  local MinMeleeDamage = get_prop_in_ItemQuery(config_id, "MinMeleeDamage")
  local MaxMeleeDamage = get_prop_in_ItemQuery(config_id, "MaxMeleeDamage")
  local MinShotDamage = get_prop_in_ItemQuery(config_id, "MinShotDamage")
  local MaxShotDamage = get_prop_in_ItemQuery(config_id, "MaxShotDamage")
  local PhyDef = get_prop_in_ItemQuery(config_id, "PhyDef")
  local MagicDef = get_prop_in_ItemQuery(config_id, "MagicDef")
  item_Array.ColorLevel = color_level
  item_Array.NeedSex = need_sex
  item_Array.ConfigID = config_id
  item_Array.Level = nx_int(Level)
  item_Array.ItemType = item_type
  item_Array.MinMeleeDamage = MinMeleeDamage
  item_Array.MaxMeleeDamage = MaxMeleeDamage
  item_Array.MinShotDamage = MinShotDamage
  item_Array.MaxShotDamage = MaxShotDamage
  item_Array.PhyDef = PhyDef
  item_Array.MagicDef = MagicDef
  item_Array.buf_text = ""
  nx_execute("tips_game", "get_props_for_formula", item_Array, item_Array)
  local tex_props = item_Array.buf_text_left .. item_Array.buf_text .. item_Array.buf_text_desc
  nx_destroy(item_Array)
  local out_text = ""
  out_text = nx_string(out_text) .. nx_string(tex_name) .. "<br>"
  out_text = nx_string(out_text) .. nx_string(tex_props)
  return out_text
end
function get_job_level(job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local row = client_player:FindRecordRow("job_rec", 0, job_id, 0)
  if row < 0 then
    return 0
  end
  return client_player:QueryRecord("job_rec", row, 1)
end
function is_material_enough(material)
  local game_client = nx_value("game_client")
  local str_lst = util_split_string(material, ";")
  if table.getn(str_lst) <= 0 then
    return true
  end
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item = str_temp[1]
    local num = str_temp[2]
    local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
    if nx_is_valid(view) then
      local viewobj_list = view:GetViewObjList()
      local total = 0
      for i, obj in pairs(viewobj_list) do
        local tempid = obj:QueryProp("ConfigID")
        if nx_string(tempid) == nx_string(item) then
          local cur_amount = obj:QueryProp("Amount")
          total = total + cur_amount
        end
      end
      if nx_int(total) < nx_int(num) then
        return false
      end
    end
  end
  return true
end
function get_limit_LearnSkillItem(tip_control, item, limit_prop, level_prop, limit_type, view_id, titled)
  local limit_text = ""
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local item_query = nx_value("ItemQuery")
  local id = get_prop_in_item(item, "ConfigID")
  local skill_pack = item_query:GetItemPropByConfigID(id, "LearnSkillPack")
  skill_pack = nx_int(skill_pack)
  local limits = nx_execute("util_static_data", "item_static_query", skill_pack, limit_prop, STATIC_DATA_ITEM_LEARNSKILL)
  local levels = nx_execute("util_static_data", "item_static_query", skill_pack, level_prop, STATIC_DATA_ITEM_LEARNSKILL)
  local limit_table = nx_function("ext_split_string", limits, nx_string(","))
  local level_table = nx_function("ext_split_string", levels, nx_string(","))
  for index = 1, table.getn(limit_table) do
    local limit_item = nx_string(limit_table[index])
    local limit_level = nx_int(level_table[index])
    local view = game_client:GetView(nx_string(view_id))
    local viewobj_list = view:GetViewObjList()
    local color_start = "<font color=\"#ff0000\">"
    local color_end = "</font>"
    for count = 1, table.getn(viewobj_list) do
      local view_obj = viewobj_list[count]
      local configID = nx_string(view_obj:QueryProp("ConfigID"))
      if configID == limit_item then
        local skill_level = nx_int(view_obj:QueryProp("Level"))
        if limit_level <= skill_level then
          color_start = "<font color=\"#00ff00\">"
          color_end = "</font>"
          break
        end
      end
    end
    local strid = ""
    if limit_type == nx_int(0) then
      strid = "tips_skillbook_zhaoshi"
    elseif limit_type == nx_int(1) then
      strid = "tips_skillbook_neigong"
    elseif limit_type == nx_int(2) then
      strid = "tips_skillbook_jingmai"
    end
    gui.TextManager:Format_SetIDName(strid)
    gui.TextManager:Format_AddParam(nx_widestr(gui.TextManager:GetText(limit_item)))
    gui.TextManager:Format_AddParam(limit_level)
    limit_text = nx_string(limit_text) .. nx_string(color_start) .. nx_string(gui.TextManager:Format_GetText()) .. nx_string(color_end)
    limit_text = nx_string(limit_text) .. "<br>"
  end
  return limit_text
end
function get_prop_limit(tip_control, item)
  local gui = nx_value("gui")
  local id = nx_string(get_prop_in_item(item, "ConfigID"))
  local item_query = nx_value("ItemQuery")
  local pack = item_query:GetItemPropByConfigID(id, "LearnSkillPack")
  pack = nx_int(pack)
  local props = nx_execute("util_static_data", "item_static_query", pack, "PropNeeded", STATIC_DATA_ITEM_LEARNSKILL)
  local vals = nx_execute("util_static_data", "item_static_query", pack, "PropValue", STATIC_DATA_ITEM_LEARNSKILL)
  if props == nil or vals == nil then
    return
  end
  local prop_limit_text = ""
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local props_table = nx_function("ext_split_string", props, nx_string(","))
  local vals_table = nx_function("ext_split_string", vals, nx_string(","))
  for index = 1, table.getn(props_table) do
    local limit_prop = nx_string(props_table[index])
    local limit_value = nx_number(vals_table[index])
    local limit_prop_mul = limit_prop .. nx_string("Mul")
    local limit_prop_add = limit_prop .. nx_string("Add")
    local color_start = "<font color=\"#ff0000\">"
    local color_end = "</font>"
    if client_player:FindProp(limit_prop) then
      local prop_value = nx_number(client_player:QueryProp(limit_prop))
      local prop_value_mul = nx_number(0)
      local prop_value_add = nx_number(0)
      if client_player:FindProp(limit_prop_mul) then
        prop_value_mul = nx_number(client_player:QueryProp(limit_prop_mul))
      end
      if client_player:FindProp(limit_prop_add) then
        prop_value_add = nx_number(client_player:QueryProp(limit_prop_add))
      end
      prop_value = prop_value + prop_value * prop_value_mul + prop_value_add
      if limit_value <= prop_value then
        color_start = "<font color=\"#00ff00\">"
        color_end = "</font>"
      end
      gui.TextManager:Format_SetIDName("tips_skillbook_shuxing")
      gui.TextManager:Format_AddParam(nx_widestr(gui.TextManager:GetText(limit_prop)))
      gui.TextManager:Format_AddParam(nx_int(limit_value))
      prop_limit_text = prop_limit_text .. color_start .. nx_string(gui.TextManager:Format_GetText()) .. color_end .. "<br>"
    end
  end
  return nx_string(prop_limit_text)
end
function get_desc_info(item)
  local text = nx_execute("tips_func_equip", "get_desc_info", item)
  return text
end
