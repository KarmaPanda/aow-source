require("util_gui")
local GUILD_DISBAND = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_manage_disband"
function main_form_init(self)
  self.Fixed = true
  self.time = os.time()
end
function on_main_form_open(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  if guild_name == "" then
    return
  end
  nx_execute("custom_sender", "custom_request_guild_disband_list", guild_name)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_ok_click(self)
  util_show_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_disband", true)
end
function on_msg(agree_list, refuse_list, resume_time)
  if resume_time == nil then
    return
  end
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_manage_disband", false, false)
  if not nx_is_valid(form) then
    return
  end
  local agree_table = util_split_string(nx_string(agree_list), ",")
  local refuse_table = util_split_string(nx_string(refuse_list), ",")
  local agree_count = table.getn(agree_table)
  local refuse_count = table.getn(refuse_table)
  if 0 < agree_count then
    agree_count = agree_count - 1
  end
  if 0 < refuse_count then
    refuse_count = refuse_count - 1
  end
  form.lbl_agree_num.Text = nx_widestr(agree_count)
  form.lbl_refuse_num.Text = nx_widestr(refuse_count)
  form.textgrid_agree:BeginUpdate()
  form.textgrid_agree:ClearRow()
  for row = 0, agree_count - 1 do
    form.textgrid_agree:InsertRow(-1)
    form.textgrid_agree:SetGridText(row, 0, nx_widestr(agree_table[row + 1]))
  end
  form.textgrid_agree:EndUpdate()
  form.textgrid_refuse:BeginUpdate()
  form.textgrid_refuse:ClearRow()
  for row = 0, refuse_count - 1 do
    form.textgrid_refuse:InsertRow(-1)
    form.textgrid_refuse:SetGridText(row, 0, nx_widestr(refuse_table[row + 1]))
  end
  form.textgrid_refuse:EndUpdate()
  if nx_int(resume_time) > nx_int(0) then
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "init_time", form)
    if nx_is_valid(timer) then
      timer:Register(1000, -1, nx_current(), "init_time", form, resume_time, -1)
    end
  end
end
function init_time(form, resume_time)
  if not nx_is_valid(form) then
    return
  end
  local now_time = os.time()
  local use_time = now_time - form.time
  local time_limit = resume_time - use_time
  if nx_int(time_limit) >= nx_int(0) then
    form.lbl_time.Text = nx_widestr(get_format_time_text(time_limit))
  else
    form.lbl_time.Text = nx_widestr("")
  end
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
function close_time()
  local form = util_get_form(GUILD_DISBAND, false, false)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "init_time", form)
  end
end
