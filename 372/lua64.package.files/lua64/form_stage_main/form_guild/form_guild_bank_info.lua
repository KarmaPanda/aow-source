require("share\\client_custom_define")
require("form_stage_main\\form_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
function main_form_init(form)
  form.Fixed = false
  form.npcid = nil
  form.remain_time = 0
  form.temp_time = 0
  form.temp_time2 = 0
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = 10
  form.Top = 70
  init_guildbank_info(form)
  requery_bankinfo(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guild\\form_guild_bank_info", nx_null())
end
function init_guildbank_info(form)
  local form1 = nx_value("form_stage_main\\form_guild\\form_guild_bank_info")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_next_time.Text = nx_widestr("")
  form.lbl_next_time_remain.Text = nx_widestr("")
  form.lbl_next_produce.Text = nx_widestr("")
  form.lbl_next_distribute_time = nx_widestr("")
  form.lbl_last_produce.Text = nx_widestr("")
  form.lbl_last_receive.Text = nx_widestr("")
  form.lb_last_give.Text = nx_widestr("")
  form.lbl_last_sum.Text = nx_widestr("")
  form.lbl_last_date.Text = nx_widestr("")
end
function requery_bankinfo(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_BANKINFO_LIST), form.npcid)
end
function get_guildbank_info(...)
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_info")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_next_produce.Text = nx_widestr(arg[2])
  local last_date = arg[3]
  if nx_widestr(last_date) == nx_widestr("") then
    form.lbl_last_date.Text = nx_widestr("")
  else
    form.lbl_last_date.Text = nx_widestr(last_date)
  end
  form.lbl_last_produce.Text = nx_widestr(arg[4])
  form.lbl_last_receive.Text = nx_widestr(arg[5])
  form.lb_last_give.Text = nx_widestr(arg[6])
  form.lbl_last_sum.Text = nx_widestr(arg[7])
  form.remain_time = arg[8]
  local remain = get_format_time_text(form.remain_time)
  form.lbl_next_time_remain.Text = nx_widestr(remain)
  form.lbl_next_time.Text = nx_widestr(arg[9])
  form.temp_time2 = arg[10]
  local remain = get_format_time_text(form.temp_time2)
  form.lbl_next_dis_time.Text = nx_widestr(form.temp_time2)
  local isDayOrSecond = arg[11]
  local isDisDayOrSecond = arg[12]
  if isDayOrSecond == 1 then
    if nx_int(form.remain_time) > nx_int(0) then
      init_timer(form.remain_time, form.npcid)
    end
  else
    form.lbl_next_time_remain.Text = nx_widestr(form.remain_time)
  end
  if isDisDayOrSecond == 1 then
    if nx_int(form.temp_time2) > nx_int(0) then
      init_dis_timer(form.temp_time2, form.npcid)
    end
  else
    form.lbl_next_dis_time.Text = nx_widestr(form.temp_time2)
  end
  form.lbl_current.Text = nx_widestr(arg[1]) .. nx_widestr("/") .. nx_widestr(form.lbl_next_produce.Text)
end
function init_timer(time, ident)
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_info")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  form.temp_time = time
  local game_client = nx_value("game_client")
  while true do
    local obj = game_client:GetSceneObj(nx_string(ident))
    if nx_is_valid(obj) then
      timer:Register(1000, -1, nx_current(), "on_update_time", obj, -1, -1)
      break
    end
  end
end
function on_update_time(obj)
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_info")
  if not nx_is_valid(form) then
    return
  end
  form.temp_time = form.temp_time - 1
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_info")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild\\form_guild_bank_info", true, false)
    nx_set_value("form_stage_main\\form_guild\\form_guild_bank_info", form)
  end
  local remain = get_format_time_text(form.temp_time)
  form.lbl_next_time_remain.Text = nx_widestr(remain)
  if form.temp_time <= 0 then
    requery_bankinfo(form)
    stop_timer(obj)
  end
end
function stop_timer(obj)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", obj)
end
function init_dis_timer(time, ident)
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_info")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  form.temp_time2 = time
  local game_client = nx_value("game_client")
  while true do
    local obj = game_client:GetSceneObj(nx_string(ident))
    if nx_is_valid(obj) then
      timer:Register(1000, -1, nx_current(), "on_dis_update_time", obj, -1, -1)
      break
    end
  end
end
function on_dis_update_time(obj)
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_info")
  if not nx_is_valid(form) then
    return
  end
  form.temp_time2 = form.temp_time2 - 1
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_info")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild\\form_guild_bank_info", true, false)
    nx_set_value("form_stage_main\\form_guild\\form_guild_bank_info", form)
  end
  local remain = get_format_time_text(form.temp_time2)
  form.lbl_next_dis_time.Text = nx_widestr(remain)
  if form.temp_time2 <= 0 then
    stop_dis_timer(obj)
  end
end
function stop_dis_timer(obj)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_dis_update_time", obj)
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
