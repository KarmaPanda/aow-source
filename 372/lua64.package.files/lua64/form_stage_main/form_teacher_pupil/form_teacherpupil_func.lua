require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
require("form_stage_main\\form_teacher_pupil\\teacherpupil_define")
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
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function get_teacher_pupil_count()
  local player = get_player()
  if not nx_is_valid(player) then
    return 0
  end
  local num = 0
  if player:FindRecord(TBL_NAME_TEACHERPUPIL_NEIGONG) then
    num = num + player:GetRecordRows(TBL_NAME_TEACHERPUPIL_NEIGONG)
  end
  if player:FindRecord(TBL_NAME_TEACHERPUPIL_JINGMAI) then
    num = num + player:GetRecordRows(TBL_NAME_TEACHERPUPIL_JINGMAI)
  end
  return num
end
function get_pupil_neigong_id(school, tp_level)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\shitu\\shitu.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(school))
  if sec_index < 0 then
    return ""
  end
  local school_info_lst = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
  local ng_info = util_split_string(school_info_lst[tp_level], ",")
  return nx_string(ng_info[2])
end
function get_school_name()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return nil
  end
  local school_id = client_player:QueryProp("School")
  return util_text(school_id)
end
function get_school_id(school_id)
  if nx_string(school_id) ~= nx_string("") then
    return school_id
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return nil
  end
  return client_player:QueryProp("School")
end
function get_self_school_id()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return nil
  end
  return client_player:QueryProp("School")
end
function get_pupil_current_level(tp_level)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return 0
  end
  local school_id = client_player:QueryProp("School")
  local neigong_id = get_pupil_neigong_id(school_id, tp_level)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_NEIGONG))
  if not nx_is_valid(view) then
    return 0
  end
  local count = view:GetViewObjCount()
  for i = 1, nx_number(count) do
    local neigong = view:GetViewObjByIndex(i - 1)
    if nx_is_valid(neigong) then
      local temp_neigong_id = neigong:QueryProp("ConfigID")
      if nx_string(temp_neigong_id) == nx_string(neigong_id) then
        local curLevel = neigong:QueryProp("Level")
        return curLevel
      end
    end
  end
  return 0
end
function get_pupil_phase_level()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return 0
  end
  return client_player:QueryProp("PhaseNeiGongLevel")
end
function get_pupil_jingmai_xwcount()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local view = game_client:GetView(nx_string(VIEWPORT_XUEWEI))
  if not nx_is_valid(view) then
    return 0
  end
  return view:GetViewObjCount()
end
function get_shitu_flag()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  return client_player:QueryProp("ShiTuFlag")
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
  if player:FindProp("ShiTu_Point") then
    shitu_value = player:QueryProp("ShiTu_Point")
  end
  return shitu_value
end
