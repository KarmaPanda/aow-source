function Get_PowerLevel_Name(PowerLevel)
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\FacultyLevel.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  if not ini:FindSection(nx_string("config")) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("config"))
  if sec_index < 0 then
    return ""
  end
  local power_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
  for i = 1, table.getn(power_table) do
    local powerinfo = power_table[i]
    local info_lst = util_split_string(powerinfo, ",")
    if nx_int(PowerLevel) == nx_int(info_lst[1]) then
      return util_text("desc_" .. nx_string(info_lst[3]))
    end
  end
  return ""
end
function get_date_string(_date)
  local year, month, day = nx_function("ext_decode_date", nx_double(_date))
  year = year or 1970
  month = month or 1
  day = day or 1
  return string.format("%s-%s-%s", year, month, day)
end
function get_is_online(is_online)
  if is_online == 1 then
    return "ui_leitai_online"
  else
    return "ui_leitai_none"
  end
end
function get_tp_type(tp_type)
  if tp_type == 1 then
    return "ui_neigongshixiong"
  else
    return "ui_neigongshidi"
  end
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local client_player = game_client:GetPlayer()
  return client_player
end
function get_shitu_flag()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  return client_player:QueryProp("NewShiTuFlag")
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function get_item_info(configid, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function get_shitu_value()
  local player = get_player()
  if not nx_is_valid(player) then
    return 0
  end
  local shitu_value = 0
  if player:FindProp("NewShiTuValue") then
    shitu_value = player:QueryProp("NewShiTuValue")
  end
  return shitu_value
end
function get_today_shitu_value()
  local player = get_player()
  if not nx_is_valid(player) then
    return 0
  end
  local today_shitu_value = 0
  if player:FindProp("NewTodayShiTuValueAdd") then
    today_shitu_value = player:QueryProp("NewTodayShiTuValueAdd")
  end
  return today_shitu_value
end
