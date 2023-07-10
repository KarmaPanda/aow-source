require("util_static_data")
require("utils")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_main\\form_main_fightvs_util")
function main_form_init(self)
  self.Fixed = true
  self.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  change_form_size()
  init_buffer(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, "form_stage_main\\form_main\\form_main_buff", "wait_game_ready", self, -1, -1)
  end
end
function wait_game_ready(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  if not game_client.ready then
    return
  end
  local form_main_buff = nx_value("form_main_buff")
  if nx_is_valid(form_main_buff) then
    form_main_buff:form_refresh_buffer(form)
  end
  timer:UnRegister("form_stage_main\\form_main\\form_main_buff", "wait_game_ready", form)
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_main\\form_main_buff")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local form_fight_main = nx_value("form_stage_main\\form_fight\\form_fight_main")
  local form_battlefield_trace = nx_value("form_stage_main\\form_battlefield\\form_battlefield_trace")
  if nx_is_valid(form_fight_main) then
    form.Top = 100
    form.Left = 50
  elseif nx_is_valid(form_battlefield_trace) then
    form.Top = 80
    form.Left = 120
  else
    form.Top = 0
    form.Left = gui.Width - form.Width - 200
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("BufferListStr", self)
  end
end
function get_buffer_time_by_id(buff_id, buff_source)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(player_obj) then
    return
  end
  local buffer_info = nx_function("get_buffer_info", player_obj, buff_id, buff_source)
  if table.getn(buffer_info) >= 3 then
    local level = buffer_info[1]
    local end_time = buffer_info[2]
    local num = buffer_info[3]
    return end_time, num, level
  end
end
function init_buffer(form)
  local form_main_buff = nx_value("form_main_buff")
  if nx_is_valid(form_main_buff) then
    form_main_buff:init_buffer(form)
  end
end
function on_get_capture(lbl)
  if not nx_find_custom(lbl, "buffer_id") then
    return 0
  end
  local buff_id = lbl.buffer_id
  if buff_id == "" or buff_id == nil then
    return 0
  end
  local str_index = ""
  local gui = nx_value("gui")
  if buff_id == "buf_schoolfortflag" then
    str_index = get_school_fight_point_buff_desc()
  elseif buff_id == "buf_schoolwar_ywdz" then
    str_index = get_school_fight_balance_buff_desc()
  elseif buff_id == "buff_yybl001" then
    str_index = get_world_war_state_buff_desc()
  elseif buff_id == "buf_zc_lxc012" then
    str_index = get_lxc_active_state_buff_desc()
  elseif buff_id == "buff_AddFacultyBuffFlags" then
    nx_execute("tips_game", "show_special_buffer_tip", lbl.AbsLeft + 35, lbl.AbsTop + 35, 0, 1, lbl.ParentForm)
    return
  elseif buff_id == "buff_LivePointChangeBuffFlags" then
    nx_execute("tips_game", "show_special_buffer_tip", lbl.AbsLeft + 35, lbl.AbsTop + 35, 0, 2, lbl.ParentForm)
    return
  elseif buff_id == "buff_EquipOtherBuffFlags" then
    nx_execute("tips_game", "show_special_buffer_tip", lbl.AbsLeft + 35, lbl.AbsTop + 35, 0, 3, lbl.ParentForm)
    return
  elseif buff_id == "buff_FoodEatBuffFlags" then
    nx_execute("tips_game", "show_special_buffer_tip", lbl.AbsLeft + 35, lbl.AbsTop + 35, 0, 4, lbl.ParentForm)
    return
  elseif buff_id == "buf_new_schoolfortflag" then
    str_index = get_new_school_fight_point_buff_desc()
  else
    local level = lbl.level
    str_index = "desc_" .. nx_string(buff_id) .. "_0"
    if level ~= nil and nx_int(level) > nx_int(0) then
      str_index = "desc_" .. nx_string(buff_id) .. "_" .. nx_string(level)
    end
    str_index = gui.TextManager:GetText(str_index)
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(str_index), lbl.AbsLeft + 5, lbl.AbsTop + 5, 0, lbl.ParentForm)
end
function on_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_left_double_click(lbl)
  if nx_find_custom(lbl, "buffer_id") then
    local buff_id = lbl.buffer_id
    if buff_id == "" or buff_id == nil then
      return
    end
    if not IsAllowControl() then
      return
    end
    nx_execute("custom_sender", "custom_remove_buffer", buff_id)
  end
end
function IsAllowControl()
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return true
  end
  local scene = world.MainScene
  if not nx_is_valid(scene) then
    return true
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return true
  end
  return game_control.AllowControl
end
function get_bit_value(data, bit_count)
  local result = {}
  for i = 1, nx_number(bit_count) do
    table.insert(result, 0)
  end
  local tmpdata = nx_int64(data)
  for i = nx_number(bit_count) - 1, 0, -1 do
    if nx_number(tmpdata) <= nx_number(0) then
      return result
    end
    local tmp = math.floor(tmpdata / math.pow(2, i))
    if nx_number(tmp) == 1 then
      result[i + 1] = nx_number(tmp)
      tmpdata = tmpdata - math.pow(2, i)
    end
  end
  return result
end
function get_school_fight_point_buff_desc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if client_player:QueryProp("IsInSchoolFight") ~= 1 then
    return ""
  end
  local MAX_BIT = 10
  local flag = nx_int64(client_player:QueryProp("SchoolFortFlag"))
  local bit_array = get_bit_value(flag, 32)
  local desc = nx_widestr("")
  local gui = nx_value("gui")
  for i = 1, MAX_BIT do
    local text = gui.TextManager:GetText("tips_buff_schoolfortflag_" .. nx_string(i))
    local tmp = math.fmod(i, 2)
    local active = false
    if nx_number(tmp) == 1 and MAX_BIT >= i + 1 then
      if nx_number(bit_array[i]) == 1 or nx_number(bit_array[i + 1]) == 1 then
        active = true
      end
    elseif nx_number(tmp) == 0 and 1 <= i - 1 and nx_number(bit_array[i]) == 1 and nx_number(bit_array[i - 1]) == 1 then
      active = true
    end
    if active then
      local state = gui.TextManager:GetText("tips_buff_schoolfortflag_11")
      text = nx_widestr("<font color=\"#FF7F00\">") .. nx_widestr(text) .. nx_widestr(" ") .. nx_widestr(state) .. nx_widestr("</font>") .. nx_widestr("<br>")
    else
      local state = gui.TextManager:GetText("tips_buff_schoolfortflag_12")
      text = nx_widestr("<font color=\"#4F4F4F\">") .. nx_widestr(text) .. nx_widestr(" ") .. nx_widestr(state) .. nx_widestr("</font>") .. nx_widestr("<br>")
    end
    desc = nx_widestr(desc) .. nx_widestr(text)
  end
  return desc
end
function get_school_fight_balance_buff_desc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if client_player:QueryProp("IsInSchoolFight") ~= 1 then
    return ""
  end
  local flag = nx_int64(client_player:QueryProp("SchoolFightProtected"))
  local bit_array = get_bit_value(flag, 39)
  local gui = nx_value("gui")
  local desc = nx_widestr(gui.TextManager:GetText("tips_buff_schoolwar_ygdz06"))
  for i = 1, table.getn(bit_array) do
    if nx_number(bit_array[i]) == 1 then
      desc = nx_widestr(gui.TextManager:GetText("tips_buff_schoolwar_wzyx" .. nx_string(i)))
      break
    end
  end
  return desc
end
function get_world_war_state_buff_desc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if client_player:QueryProp("IsInWorldWar") ~= 1 then
    return ""
  end
  local flag = nx_int64(client_player:QueryProp("PlayerRaiseState"))
  local bit_array = get_bit_value(flag, 25)
  local gui = nx_value("gui")
  local desc = nx_widestr("")
  for i = 1, table.getn(bit_array) do
    if nx_number(bit_array[i]) == 1 then
      local text = nx_widestr(gui.TextManager:GetText("desc_buff_yybl001_" .. nx_string(i)))
      text = nx_widestr("<font color=\"#FF7F00\">") .. text .. nx_widestr("</font>") .. nx_widestr("<br>")
      desc = nx_widestr(desc) .. nx_widestr(text)
    end
  end
  if nx_widestr(desc) == nx_widestr("") then
    desc = nx_widestr(gui.TextManager:GetText("desc_buff_yybl001_0"))
  end
  return desc
end
function get_lxc_active_state_buff_desc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if client_player:QueryProp("IsInWorldWar") ~= 1 then
    return ""
  end
  local flag = nx_int64(client_player:QueryProp("PlayerRaiseState"))
  local bit_array = get_bit_value(flag, 4)
  local gui = nx_value("gui")
  local desc = nx_widestr("")
  for i = 1, table.getn(bit_array) do
    if nx_number(bit_array[i]) == 1 then
      local text = nx_widestr(gui.TextManager:GetText("desc_buf_zc_lxc012_" .. nx_string(i)))
      text = nx_widestr("<font color=\"#FF7F00\">") .. text .. nx_widestr("</font>") .. nx_widestr("<br>")
      desc = nx_widestr(desc) .. nx_widestr(text)
    end
  end
  if nx_widestr(desc) == nx_widestr("") then
    desc = nx_widestr(gui.TextManager:GetText("desc_buf_zc_lxc012_0"))
  end
  return desc
end
function get_add_faculty_flage_buff_desc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_widestr("")
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_widestr("")
  end
  local buffer_effect = nx_value("BufferEffect")
  if not nx_is_valid(buffer_effect) then
    return nx_widestr("")
  end
  local gui = nx_value("gui")
  if not client_player:FindRecord("AddWuXueFacultyBufferRec") then
    return nx_widestr("")
  end
  local str_index = nx_widestr("")
  local rownum = client_player:GetRecordRows("AddWuXueFacultyBufferRec")
  for i = 0, rownum - 1 do
    local index = client_player:QueryRecord("AddWuXueFacultyBufferRec", i, 0)
    str_index = nx_widestr(str_index) .. nx_widestr(gui.TextManager:GetText(nx_string(buffer_effect:GetBufferDescIDByIndex(1, index)))) .. nx_widestr("<br>")
    local msgdelay = nx_value("MessageDelay")
    local server_time = msgdelay:GetServerNowTime()
    local end_time = client_player:QueryRecord("AddWuXueFacultyBufferRec", i, 1)
    local live_time = end_time - server_time
    if nx_int(live_time) > nx_int(0) then
      str_index = nx_widestr(str_index) .. nx_widestr("<font color=\"#00FF00\">") .. nx_widestr(gui.TextManager:GetText(nx_string(get_format_time(live_time / 1000)))) .. nx_widestr("</font>")
    end
    local times = client_player:QueryRecord("AddWuXueFacultyBufferRec", i, 2)
    if nx_int(times) > nx_int(1) then
      str_index = nx_widestr(str_index) .. nx_widestr("  ") .. nx_widestr("<font color=\"#FFFF00\">") .. nx_widestr(gui.TextManager:GetFormatText("ui_special_buff_lay_times", nx_int(times))) .. nx_widestr("</font>")
    end
    str_index = nx_widestr(str_index) .. nx_widestr("<br>")
  end
  return str_index
end
function get_live_point_change_flage_buff_desc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local buffer_effect = nx_value("BufferEffect")
  if not nx_is_valid(buffer_effect) then
    return ""
  end
  local gui = nx_value("gui")
  if not client_player:FindRecord("LivePointChangeBufferRec") then
    return ""
  end
  local str_index = ""
  local rownum = client_player:GetRecordRows("LivePointChangeBufferRec")
  for i = 0, rownum - 1 do
    local index = client_player:QueryRecord("LivePointChangeBufferRec", i, 0)
    str_index = str_index .. nx_string(gui.TextManager:GetText(nx_string(buffer_effect:GetBufferDescIDByIndex(2, index)))) .. nx_string("<br>")
    local msgdelay = nx_value("MessageDelay")
    local server_time = msgdelay:GetServerNowTime()
    local end_time = client_player:QueryRecord("LivePointChangeBufferRec", i, 1)
    local live_time = end_time - server_time
    if nx_int(live_time) > nx_int(0) then
      str_index = str_index .. nx_string("<font color=\"#00FF00\">") .. nx_string(gui.TextManager:GetText(nx_string(get_format_time(live_time / 1000)))) .. nx_string("</font>")
    end
    local times = client_player:QueryRecord("LivePointChangeBufferRec", i, 2)
    if nx_int(times) > nx_int(1) then
      str_index = str_index .. "  " .. nx_string("<font color=\"#FFFF00\">") .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_lay_times", nx_int(times))) .. nx_string("</font>")
    end
    str_index = str_index .. nx_string("<br>")
  end
  return str_index
end
function get_special_buff_flage_desc(special_buff_rec)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local buffer_effect = nx_value("BufferEffect")
  if not nx_is_valid(buffer_effect) then
    return ""
  end
  local gui = nx_value("gui")
  if not client_player:FindRecord(nx_string(special_buff_rec)) then
    return ""
  end
  local str_index = ""
  if nx_string(special_buff_rec) == nx_string("EquipOtherBufferRec") then
    str_index = str_index .. nx_string(gui.TextManager:GetText("tips_equipbuff_open")) .. nx_string("<br>")
  end
  local rownum = client_player:GetRecordRows(nx_string(special_buff_rec))
  for i = 0, rownum - 1 do
    local buff_id = client_player:QueryRecord(nx_string(special_buff_rec), i, 0)
    local level = client_player:QueryRecord(nx_string(special_buff_rec), i, 3)
    if level ~= nil and nx_int(level) > nx_int(0) then
      str_index = str_index .. nx_string(gui.TextManager:GetText("desc_" .. nx_string(buff_id) .. "_" .. nx_string(level))) .. nx_string("<br>")
    else
      str_index = str_index .. nx_string(gui.TextManager:GetText("desc_" .. nx_string(buff_id) .. "_" .. "0")) .. nx_string("<br>")
    end
    local msgdelay = nx_value("MessageDelay")
    local server_time = msgdelay:GetServerNowTime()
    local end_time = client_player:QueryRecord(nx_string(special_buff_rec), i, 1)
    local live_time = end_time - server_time
    if nx_int(live_time) > nx_int(0) then
      if nx_int(live_time) < nx_int(120000) then
        str_index = str_index .. nx_string("<font color=\"#FF0000\">") .. nx_string(gui.TextManager:GetText(nx_string(get_format_time(live_time / 1000)))) .. nx_string("</font>")
      else
        str_index = str_index .. nx_string("<font color=\"#00FF00\">") .. nx_string(gui.TextManager:GetText(nx_string(get_format_time(live_time / 1000)))) .. nx_string("</font>")
      end
    end
    local times = client_player:QueryRecord(nx_string(special_buff_rec), i, 2)
    if nx_int(times) > nx_int(1) then
      str_index = str_index .. "  " .. nx_string("<font color=\"#FFFF00\">") .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_lay_times", nx_int(times))) .. nx_string("</font>")
    end
    str_index = str_index .. nx_string("<br>")
  end
  return str_index
end
function get_format_time(time)
  if nx_number(time) < nx_number(0) then
    return ""
  end
  local hour = nx_int(nx_number(time) / 3600)
  local minute = nx_int(nx_number(time) % 3600 / 60)
  local second = nx_int(nx_number(time) % 60)
  local gui = nx_value("gui")
  local str = ""
  if nx_int(hour) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_1", nx_int(hour)))
  end
  if nx_int(minute) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_2", nx_int(minute)))
  end
  if nx_int(second) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_3", nx_int(second)))
  end
  return str
end
function get_new_school_fight_point_buff_desc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if client_player:QueryProp("IsNewWarRule") ~= 1 then
    return ""
  end
  local MAX_BIT = 6
  local flag = nx_int64(client_player:QueryProp("SchoolFortFlag"))
  local bit_array = get_bit_value(flag, 32)
  local desc = nx_widestr("")
  local gui = nx_value("gui")
  for i = 1, MAX_BIT do
    local text = gui.TextManager:GetText("tips_buff_gujschoolfortflag_" .. nx_string(i))
    local tmp = math.fmod(i, 2)
    local active = false
    if nx_number(tmp) == 1 and MAX_BIT >= i + 1 then
      if nx_number(bit_array[i]) == 1 or nx_number(bit_array[i + 1]) == 1 then
        active = true
      end
    elseif nx_number(tmp) == 0 and 1 <= i - 1 and nx_number(bit_array[i]) == 1 and nx_number(bit_array[i - 1]) == 1 then
      active = true
    end
    if active then
      local state = gui.TextManager:GetText("tips_buff_schoolfortflag_11")
      text = nx_widestr("<font color=\"#FF7F00\">") .. nx_widestr(text) .. nx_widestr(" ") .. nx_widestr(state) .. nx_widestr("</font>") .. nx_widestr("<br>")
    else
      local state = gui.TextManager:GetText("tips_buff_schoolfortflag_12")
      text = nx_widestr("<font color=\"#4F4F4F\">") .. nx_widestr(text) .. nx_widestr(" ") .. nx_widestr(state) .. nx_widestr("</font>") .. nx_widestr("<br>")
    end
    desc = nx_widestr(desc) .. nx_widestr(text)
  end
  return desc
end
