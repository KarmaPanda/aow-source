require("util_functions")
require("util_gui")
require("role_composite")
require("share\\logicstate_define")
require("custom_handler")
require("form_stage_main\\form_sweet_employ\\sweet_employ_common")
local SUB_FORM_NAME = "form_stage_main\\form_sweet_employ\\form_offline_sub_employee"
local INI_FILE_FACULTY = "share\\Faculty\\WuXueLevelInfo.ini"
function create_body_player(scene_box, obj)
  if not nx_is_valid(scene_box) then
    return
  end
  if not nx_is_valid(obj) then
    return
  end
  local sex = obj:QueryProp("Sex")
  local body_type = obj:QueryProp("BodyType")
  local actor2 = nx_execute("role_composite", "create_role_composite", scene_box.Scene, true, sex, "stand", body_type)
  if not nx_is_valid(actor2) then
    return
  end
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0)
  end
  local hat = obj:QueryProp("Hat")
  local cloth = obj:QueryProp("Cloth")
  local pants = obj:QueryProp("Pants")
  local shoes = obj:QueryProp("Shoes")
  local skin_array = {}
  skin_array.hat = hat
  skin_array.cloth = cloth
  skin_array.pants = pants
  skin_array.shoes = shoes
  for link_name, model_path in pairs(skin_array) do
    if 0 < string.len(nx_string(model_path)) then
      link_skin(actor2, link_name, model_path .. ".xmod", false)
    end
  end
  util_add_model_to_scenebox(scene_box, actor2)
  scene_box.role_actor2 = actor2
end
function show_self_model(scenebox)
  if not nx_is_valid(scenebox) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
    local world = nx_value("world")
    world:Delete(scenebox.role_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    util_addscene_to_scenebox(scenebox)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, scenebox.Scene)
  end
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  local actor2 = create_scene_obj_composite(scenebox.Scene, client_player, false)
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if body_manager:IsNewBodyType(client_player) then
    actor2.sex = client_player:QueryProp("Sex")
    actor2.body_type = client_player:QueryProp("BodyType")
    actor2.body_face = client_player:QueryProp("BodyFace")
    role_composite:refresh_body(actor2, true)
  end
  util_add_model_to_scenebox(scenebox, actor2)
  scenebox.role_actor2 = actor2
end
function show_sweet_model(scenebox)
  if not nx_is_valid(scenebox) then
    return
  end
  local uid, name, photo, hair, cloth, pants, shoes, school, powerlevel, sex, tacitLevel, tacitValue, targetfaccost, body_type, body_face = get_sweetpet_showinfo()
  if uid == nil or uid == "" then
    return
  end
  if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
    local world = nx_value("world")
    world:Delete(scenebox.role_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    util_addscene_to_scenebox(scenebox)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, scenebox.Scene)
  end
  local actor2 = create_role_composite(scenebox.Scene, false, nx_number(sex))
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if nx_int(body_type) >= nx_int(3) and nx_int(body_type) <= nx_int(6) then
    actor2.sex = sex
    actor2.body_type = body_type
    actor2.body_face = body_face
    role_composite:refresh_body(actor2, true)
  end
  local skin_info = {
    [1] = {link_name = "face", model_name = ""},
    [2] = {link_name = "impress", model_name = ""},
    [3] = {link_name = "hat", model_name = hair},
    [4] = {link_name = "cloth", model_name = cloth},
    [5] = {link_name = "pants", model_name = pants},
    [6] = {link_name = "shoes", model_name = shoes}
  }
  for i, info in pairs(skin_info) do
    if info.model_name ~= nil and string.len(nx_string(info.model_name)) > 0 then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod", false)
    end
  end
  local show_type = get_sweet_show_type()
  if nx_int(show_type) == nx_int(1) then
    link_skin(actor2, "cloth_h", cloth .. "_h.xmod", false)
  end
  util_add_model_to_scenebox(scenebox, actor2)
  scenebox.role_actor2 = actor2
end
function show_black_model(scenebox)
  hat_model = {
    [0] = "obj\\char\\b_hair\\b_hair1",
    [1] = "obj\\char\\g_hair\\g_hair1"
  }
  cloth_model = {
    [0] = "obj\\char\\b_jianghu001\\b_cloth001",
    [1] = "obj\\char\\g_jianghu001\\g_cloth001"
  }
  pants_model = {
    [0] = "obj\\char\\b_jianghu001\\b_pants001",
    [1] = "obj\\char\\g_jianghu001\\g_pants001"
  }
  shoes_model = {
    [0] = "obj\\char\\b_jianghu001\\b_shoes001",
    [1] = "obj\\char\\g_jianghu001\\g_shoes001"
  }
  if not nx_is_valid(scenebox) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sweet_sex = 1
  local sex = client_player:QueryProp("Sex")
  if nx_number(sex) == nx_number(1) then
    sweet_sex = 0
  end
  if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
    local world = nx_value("world")
    world:Delete(scenebox.role_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    util_addscene_to_scenebox(scenebox)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, scenebox.Scene)
  end
  local actor2 = create_role_composite(scenebox.Scene, false, sweet_sex)
  local skin_info = {
    [1] = {
      link_name = "hat",
      model_name = hat_model[sweet_sex]
    },
    [2] = {
      link_name = "cloth",
      model_name = cloth_model[sweet_sex]
    },
    [3] = {
      link_name = "pants",
      model_name = pants_model[sweet_sex]
    },
    [4] = {
      link_name = "shoes",
      model_name = shoes_model[sweet_sex]
    }
  }
  for i, info in pairs(skin_info) do
    if info.model_name ~= nil then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  util_add_model_to_scenebox(scenebox, actor2)
  scenebox.role_actor2 = actor2
  nx_function("ext_set_model_single_color", actor2, "0.05,0.05,0.05")
  nx_function("ext_set_model_around_color", actor2, "0.69,0.825,0.996", "0.005")
end
function get_sweetpet_showinfo()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local table_name = "rec_pet_show"
  if not client_player:FindRecord(table_name) then
    return
  end
  local rows = client_player:GetRecordRows(table_name)
  if rows ~= 1 then
    return
  end
  local row = 0
  local uid = nx_widestr(client_player:QueryRecord(table_name, row, 0))
  local name = nx_widestr(client_player:QueryRecord(table_name, row, 1))
  local photo = nx_string(client_player:QueryRecord(table_name, row, 2))
  local hair = nx_string(client_player:QueryRecord(table_name, row, 3))
  local cloth = nx_string(client_player:QueryRecord(table_name, row, 4))
  local pants = nx_string(client_player:QueryRecord(table_name, row, 5))
  local shoes = nx_string(client_player:QueryRecord(table_name, row, 6))
  local school = nx_string(client_player:QueryRecord(table_name, row, 7))
  local powerlevel = nx_int(client_player:QueryRecord(table_name, row, 8))
  local sex = nx_int(client_player:QueryRecord(table_name, row, 9))
  local tacitLevel = nx_int(client_player:QueryRecord(table_name, row, 10))
  local tacitValue = nx_int(client_player:QueryRecord(table_name, row, 11))
  local targetfaccost = nx_int(client_player:QueryRecord(table_name, row, 12))
  local body_type = nx_int(client_player:QueryRecord(table_name, row, 14))
  local body_face = nx_int(client_player:QueryRecord(table_name, row, 15))
  return uid, name, photo, hair, cloth, pants, shoes, school, powerlevel, sex, tacitLevel, tacitValue, targetfaccost, body_type, body_face
end
function get_sweet_show_type()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  local table_name = "rec_pet_show"
  if not client_player:FindRecord(table_name) then
    return -1
  end
  local rows = client_player:GetRecordRows(table_name)
  if rows ~= 1 then
    return -1
  end
  return nx_int(client_player:QueryRecord(table_name, 0, 13))
end
function doPossAction(actor2, aciton)
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) and nx_is_valid(actor2) then
    actor2.cur_action = aciton
    local isExists = action_module:ActionExists(actor2, nx_string(aciton))
    if isExists then
      local is_in_list = action_module:ActionBlended(actor2, nx_string(aciton))
      if not is_in_list then
        action_module:BlendAction(actor2, nx_string(aciton), true, true)
      end
    end
  end
end
function IsBuildEmployRelation()
  local flag = GetPlayerProp("SweetEmployFlag")
  if nx_number(flag) ~= nx_number(0) then
    return true
  end
  return false
end
function IsOpenFormOfflineEmp()
  local sum = GetPlayerProp("CanSummonSweetPet")
  if nx_int(sum) == nx_int(2) then
    return true
  end
  return false
end
function GetPlayerProp(prop)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp(prop) then
    return ""
  end
  local result = client_player:QueryProp(prop)
  return result
end
function GetFormatStringFromRecord(type, ...)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local record_name = ""
  if nx_number(type) == nx_number(1) then
    record_name = "sweet_pet_ng"
    if not client_player:FindRecord(record_name) then
      return ""
    end
    local result = ""
    local rows = client_player:GetRecordRows(record_name)
    for i = 0, rows - 1 do
      local id = client_player:QueryRecord(record_name, i, 0)
      local level = client_player:QueryRecord(record_name, i, 1)
      local flag = 0
      if nx_number(table.getn(arg)) == nx_number(1) and nx_string(id) == nx_string(arg[1]) then
        flag = 1
      end
      result = result .. id .. "," .. level .. "," .. flag .. ";"
    end
    return result
  elseif nx_number(type) == nx_number(2) then
    record_name = "sweet_pet_zs"
    if not client_player:FindRecord(record_name) then
      return ""
    end
    local result = ""
    local rows = client_player:GetRecordRows(record_name)
    for i = 0, rows - 1 do
      local id = client_player:QueryRecord(record_name, i, 0)
      local level = client_player:QueryRecord(record_name, i, 1)
      local flag = 0
      result = result .. id .. "," .. level .. "," .. flag .. ";"
    end
    return result
  elseif nx_number(type) == nx_number(6) then
    record_name = "sweet_pet_jm"
    if not client_player:FindRecord(record_name) then
      return ""
    end
    local result = ""
    local rows = client_player:GetRecordRows(record_name)
    for i = 0, rows - 1 do
      local id = client_player:QueryRecord(record_name, i, 0)
      local level = client_player:QueryRecord(record_name, i, 1)
      local flag = 0
      for i = 1, table.getn(arg) do
        if nx_string(id) == nx_string(arg[i]) then
          flag = 1
        end
      end
      result = result .. id .. "," .. level .. "," .. flag .. ";"
    end
    return result
  elseif nx_number(type) == nx_number(7) then
    record_name = "sweet_pet_eq"
    if not client_player:FindRecord(record_name) then
      return ""
    end
    local result = ""
    local rows = client_player:GetRecordRows(record_name)
    for i = 0, rows - 1 do
      local id = client_player:QueryRecord(record_name, i, 0)
      local level = client_player:QueryRecord(record_name, i, 1)
      result = result .. id .. "," .. level .. ";"
    end
    return result
  end
end
function ReflushFormStr(form, type, selected_str)
  if not (nx_is_valid(form) and nx_find_custom(form, "neigong") and nx_find_custom(form, "zhaoshi")) or not nx_find_custom(form, "jingmai") then
    return
  end
  local tmp_str
  if nx_number(type) == nx_number(1) then
    tmp_str = form.neigong
  elseif nx_number(type) == nx_number(2) then
    tmp_str = form.zhaoshi
  elseif nx_number(type) == nx_number(6) then
    tmp_str = form.jingmai
  end
  local result = ""
  local str_lst = util_split_string(nx_string(tmp_str), ";")
  for _, val in ipairs(str_lst) do
    local str_temp = util_split_string(val, ",")
    if table.getn(str_temp) == nx_number(3) then
      local id = str_temp[1]
      local level = str_temp[2]
      local flag = 0
      if nx_number(type) == nx_number(1) then
        if nx_string(id) == nx_string(selected_str) then
          flag = 1
        end
      elseif nx_number(type) == nx_number(2) then
        flag = 0
      elseif nx_number(type) == nx_number(6) then
        local seleced = util_split_string(selected_str, ",")
        for _, val2 in ipairs(seleced) do
          if nx_string(id) == nx_string(val2) then
            flag = 1
          end
        end
      end
      result = result .. id .. "," .. level .. "," .. flag .. ";"
    end
  end
  return result
end
function GetSelectResult(form, type)
  if not nx_is_valid(form) then
    return ""
  end
  local tmp_str
  local result = ""
  if nx_number(type) == nx_number(2) then
    tmp_str = ""
    if nx_find_custom(form.lbl_taolu, "type_name") then
      tmp_str = form.lbl_taolu.type_name
    end
    local wuxue_query = nx_value("WuXueQuery")
    if not nx_is_valid(wuxue_query) then
      return
    end
    local main_type_name = ""
    local type_tab = wuxue_query:GetMainNames(2)
    for i = 1, table.getn(type_tab) do
      local main_type = type_tab[i]
      local sub_type = wuxue_query:GetSubNames(2, main_type)
      for j = 1, table.getn(sub_type) do
        if nx_string(tmp_str) == nx_string(sub_type[j]) then
          main_type_name = main_type
          break
        end
      end
    end
    local item_tab = wuxue_query:GetItemNames(2, nx_string(tmp_str))
    local photo_number = table.getn(item_tab)
    for i = 1, photo_number do
      local item_name = item_tab[i]
      local level = GetDataFromRecord("sweet_pet_zs", 1, item_name)
      result = result .. item_name .. "," .. level .. ";"
    end
    return main_type_name, result
  end
end
function GetDataFromRecord(rec_name, col, id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindRecord(rec_name) then
    return ""
  end
  local row = client_player:FindRecordRow(rec_name, 0, id)
  if nx_number(row) < nx_number(0) then
    return ""
  end
  local result = client_player:QueryRecord(rec_name, row, col)
  return result
end
function GetMaxFacutlyValue(wuxue_name, level)
  local ini = nx_call("util_functions", "get_ini", INI_FILE_FACULTY)
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_name))
  if index < 0 then
    return 0
  end
  local level_tab = ini:GetItemValueList(index, "r")
  for i = 1, table.getn(level_tab) do
    local data_tab = util_split_string(nx_string(level_tab[i]), ",")
    if table.getn(data_tab) < 3 then
      break
    end
    local ini_level = data_tab[1]
    local ini_max_faculty = data_tab[2]
    if nx_number(level) == nx_number(ini_level) then
      return ini_max_faculty
    end
  end
  return 0
end
function neigong_query_photo_by_configid(neigong_id)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager("share\\Skill\\NeiGong\\neigong.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(neigong_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  return data_query:Query(26, nx_int(static_data), "Photo")
end
function close_learn_xiulian_form()
  local xiulian_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_xiulian")
  if nx_is_valid(xiulian_form) then
    xiulian_form.Visible = false
    xiulian_form:Close()
    nx_destroy(xiulian_form)
  end
  local learn_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_learn")
  if nx_is_valid(learn_form) then
    learn_form.Visible = false
    learn_form:Close()
    nx_destroy(learn_form)
  end
end
function can_accost()
  local vipmodule = nx_value("VipModule")
  if not nx_is_valid(vipmodule) then
    return false
  end
  if not vipmodule:IsVip(1) then
    custom_sysinfo(1, 1, 1, 2, "9755")
    return false
  end
  if IsBuildEmployRelation() then
    custom_sysinfo(1, 1, 1, 2, "9760")
    return false
  end
  local dead = GetPlayerProp("Dead")
  if nx_int(dead) > nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "9792")
    return false
  end
  local logic_state = GetPlayerProp("LogicState")
  if nx_int(logic_state) == nx_int(LS_FIGHTING) then
    custom_sysinfo(1, 1, 1, 2, "9787")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_STALLED) then
    custom_sysinfo(1, 1, 1, 2, "9789")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_SERIOUS_INJURY) then
    custom_sysinfo(1, 1, 1, 2, "9792")
    return false
  end
  local isexchange = GetPlayerProp("IsExchange")
  if nx_int(isexchange) == 1 then
    custom_sysinfo(1, 1, 1, 2, "9789")
    return false
  end
  local OnTransToolState = GetPlayerProp("OnTransToolState")
  if nx_int(OnTransToolState) ~= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "9788")
    return false
  end
  local guild_war_side = GetPlayerProp("GuildWarSide")
  if nx_int(guild_war_side) ~= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "9791")
    return false
  end
  local in_schoo_fight = GetPlayerProp("IsInSchoolFight")
  if nx_int(1) == nx_int(in_schoo_fight) then
    custom_sysinfo(1, 1, 1, 2, "9791")
    return false
  end
  local interact_status = GetPlayerProp("InteractStatus")
  if nx_int(interact_status) >= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "9762")
    return false
  end
  return true
end
function is_self_body()
  local body_type = get_player_prop("BodyType")
  if nx_number(body_type) >= nx_number(3) and nx_number(body_type) <= nx_number(6) then
    return true
  end
  return false
end
function is_npc_body()
  local uid, name, photo, hair, cloth, pants, shoes, school, powerlevel, sex, tacitLevel, tacitValue, targetfaccost, body_type, body_face = get_sweetpet_showinfo()
  if nx_number(body_type) >= nx_number(3) and nx_number(body_type) <= nx_number(6) then
    return true
  end
  return false
end
