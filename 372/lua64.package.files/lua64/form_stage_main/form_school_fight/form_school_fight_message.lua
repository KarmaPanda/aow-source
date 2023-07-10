local TYPE_SINGLE_MSG = 1
local TYPE_CAMP_MSG = 2
local TYPE_ALL_MSG = 3
local MAX_INFO_CNT = 30
local TVT_TYPE_SF_TRACEINFO = 60
local FORM_NAME = "form_stage_main\\form_school_fight\\form_school_fight_message"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "add_form", 0, TVT_TYPE_SF_TRACEINFO)
end
function on_main_form_close(self)
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "del_form", 0, TVT_TYPE_SF_TRACEINFO)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    if nx_number(rbtn.DataSource) == 1 then
      form.groupbox_cmd.Visible = true
      form.groupbox_single.Visible = false
    elseif nx_number(rbtn.DataSource) == 2 then
      form.groupbox_cmd.Visible = false
      form.groupbox_single.Visible = true
    end
  end
end
function add_content_by_type(msg_type, msg_info)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  local mltbox_list
  if nx_number(msg_type) == TYPE_SINGLE_MSG then
    mltbox_list = form.mltbox_list_single
  elseif nx_number(msg_type) == TYPE_CAMP_MSG then
    mltbox_list = form.mltbox_list_camp
  elseif nx_number(msg_type) == TYPE_ALL_MSG then
    mltbox_list = form.mltbox_list_all
  end
  if mltbox_list == nil or not nx_is_valid(mltbox_list) then
    return
  end
  mltbox_list:AddHtmlText(msg_info, -1)
  if nx_number(msg_type) == TYPE_CAMP_MSG then
    mltbox_list.VScrollBar.Value = mltbox_list.VScrollBar.Maximum
  end
  if mltbox_list.ItemCount > MAX_INFO_CNT then
    mltbox_list:DelHtmlItem(0)
  end
end
function add_content_by_id(msg_id, msg_info)
  local file_name = "ini\\ui\\schoolfight\\schoolfight_msgid_index.ini"
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    return
  end
  local msg_type = ini:ReadInteger("Main", nx_string(msg_id), 0)
  if nx_number(msg_type) == 0 then
    return
  end
  msg_info = nx_widestr(msg_info) .. nx_widestr("<s><s>") .. nx_widestr(get_server_date())
  add_content_by_type(msg_type, msg_info)
end
function add_leader_chat_info(name, msg_info)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "leader_name") then
    return
  end
  if not nx_ws_equal(nx_widestr(name), nx_widestr(form.leader_name)) then
    return
  end
  msg_info = nx_widestr(name) .. nx_widestr(":<s>") .. nx_widestr(msg_info)
  msg_info = nx_widestr(msg_info) .. nx_widestr("<s><s>") .. nx_widestr(get_server_date())
  add_content_by_type(TYPE_CAMP_MSG, msg_info)
end
function add_all_trace_info(id, time)
  if id == nil or time == nil then
    return
  end
  local gui = nx_value("gui")
  local content = gui.TextManager:GetText(nx_string(id))
  local hour = math.floor(time / 100)
  local mins = math.fmod(time, 100)
  local time_text = string.format("%02d:%02d", nx_number(hour), nx_number(mins))
  local msg_info = nx_widestr(content) .. nx_widestr("<s><s>") .. nx_widestr(time_text)
  add_content_by_type(TYPE_ALL_MSG, msg_info)
end
function get_ini(file_name)
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return nx_null()
  end
  if not IniManager:IsIniLoadedToManager(nx_string(file_name)) then
    IniManager:LoadIniToManager(nx_string(file_name))
  end
  return IniManager:GetIniDocument(nx_string(file_name))
end
function get_server_date()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return ""
  end
  local date_time = msg_delay:GetServerDateTime()
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", date_time)
  local time_text = string.format("%02d:%02d", nx_number(hour), nx_number(mins))
  return nx_widestr(time_text)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "check_cbtn_state", 0, TVT_TYPE_SF_TRACEINFO)
end
function open_form(leader_name, ...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.leader_name = leader_name
  for i = 1, table.getn(arg), 2 do
    local id = nx_string(arg[i])
    local time = nx_number(arg[i + 1])
    local content = gui.TextManager:GetText(nx_string(id))
    local hour = math.floor(time / 100)
    local mins = math.fmod(time, 100)
    local time_text = string.format("%02d:%02d", nx_number(hour), nx_number(mins))
    local msg_info = nx_widestr(content) .. nx_widestr("<s><s>") .. nx_widestr(time_text)
    add_content_by_type(TYPE_ALL_MSG, msg_info)
  end
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    delay_timer:Register(3000, -1, nx_current(), "on_delay_show_form_time", form, -1, -1)
  else
    form:Show()
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_delay_show_form_time(form)
  if not nx_is_valid(form) then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  form:Show()
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
end
