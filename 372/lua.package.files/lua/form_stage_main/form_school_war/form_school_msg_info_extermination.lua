require("util_gui")
require("util_functions")
local FILE_SCHOOL_MSGINFO_EXTERMIN = "form_stage_main\\form_school_war\\form_school_msg_info_extermination"
local INI_SCHOOL_MSGINFO_EXTERMIN = "share\\War\\School_MsgInfo_Extermin.ini"
local EXTERMIN_LOG = {
  ["01"] = "19913",
  ["00"] = "19914",
  ["11"] = "19915",
  ["10"] = "19916"
}
function open_form()
  local form = util_get_form(FILE_SCHOOL_MSGINFO_EXTERMIN, true, false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_shcool_destroy", 40)
  return form
end
function on_extermin_server_msg(...)
  local form = nx_value(FILE_SCHOOL_MSGINFO_EXTERMIN)
  if not nx_is_valid(form) then
    return
  end
  refresh_extermin_log(form, arg[1])
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  if not is_school_extermination() then
    return
  end
  form.school_id = get_player_school()
  init_data_extermination(form)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function get_player_school()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  return client_player:QueryProp("School")
end
function is_school_extermination()
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return false
  end
  local school = get_player_school()
  if school == "" then
    return false
  end
  local result = SchoolExtinct:IsSchoolExtincted(school)
  return result
end
function init_data_extermination(form)
  if not nx_is_valid(form) then
    return
  end
  local ini_extermin = get_ini(INI_SCHOOL_MSGINFO_EXTERMIN, true)
  if not nx_is_valid(ini_extermin) then
    return
  end
  if not nx_find_custom(form, "school_id") then
    return
  end
  local school_id = nx_string(form.school_id)
  if school_id == "" then
    return
  end
  local school_index = ini_extermin:FindSectionIndex(school_id)
  local image = ini_extermin:ReadString(school_index, "ImagePath", "")
  local desc = ini_extermin:ReadString(school_index, "Desc", "")
  form.pic_info.Image = image
  form.mltbox_info.HtmlText = util_text(desc)
end
function change_form_size(form_menpai)
  local form = nx_value(FILE_SCHOOL_MSGINFO_EXTERMIN)
  if not nx_is_valid(form) or not nx_is_valid(form_menpai) then
    return
  end
  form.Left = 0
  form.Top = 0
  form.Width = form_menpai.groupbox_extermin.Width
  form.Height = form_menpai.groupbox_extermin.Height
end
function refresh_extermin_log(form, str_log)
  local log_table = util_split_string(str_log, "|")
  local log_count = table.getn(log_table)
  if log_count < 0 then
    return
  end
  local ini_extermin = get_ini(INI_SCHOOL_MSGINFO_EXTERMIN, true)
  if not nx_is_valid(ini_extermin) then
    return
  end
  local row, tmp_text, index, num, school_id, logs = 0, nx_widestr(""), "00", 5, "", ""
  form.textgrid_log:BeginUpdate()
  form.textgrid_log:ClearRow()
  form.textgrid_log:ClearSelect()
  form.textgrid_log.ColCount = 1
  local count = log_count - 1
  if log_count == 1 then
    count = 1
  end
  for i = 1, count do
    logs = util_split_string(log_table[i], ";")
    if table.getn(logs) ~= 5 then
      return
    end
    str_time = get_format_time(nx_string(logs[1]))
    num = nx_number(logs[3])
    if 5 <= num and num <= 12 then
      school_id = ini_extermin:GetSectionByIndex(num - 5)
    elseif num == 1 then
      school_id = "school_waiyu"
    else
      return
    end
    index = nx_string(logs[2]) .. nx_string(logs[4])
    if index == "00" or index == "01" or index == "10" or index == "11" then
      tmp_text = util_format_string(EXTERMIN_LOG[index], str_time, util_text(school_id), nx_int(logs[5]))
    else
      tmp_text = nx_widestr("")
    end
    row = form.textgrid_log:InsertRow(-1)
    form.textgrid_log:SetGridText(row, 0, tmp_text)
  end
  form.textgrid_log:EndUpdate()
end
function get_format_time(str_time)
  if str_time == "" then
    return ""
  end
  time_list = util_split_string(str_time, ",")
  if table.getn(time_list) ~= 3 then
    return ""
  end
  local format_time = nx_widestr(time_list[1]) .. util_text("ui_g_year") .. nx_widestr(string.format("%02d", time_list[2])) .. util_text("ui_g_month") .. nx_widestr(string.format("%02d", time_list[3])) .. util_text("ui_g_day")
  return format_time
end
