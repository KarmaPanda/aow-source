require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\form_tvt\\define")
local FORM_NAME = "form_stage_main\\form_agree_war\\form_agree_war_score"
local data_camp_id = 0
local data_info = ""
local data_delay = 0
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) * 3 / 4
  self.Top = (gui.Height - self.Height) / 4
  load_ini(self)
  return 1
end
function on_main_form_open(self)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_lbl_time", self, -1, -1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_lbl_time", self)
  end
  nx_destroy(self)
end
function open_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    return
  end
  form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function on_main_form_shut(self)
end
function on_update_lbl_time(form)
  if not nx_is_valid(form) then
    return
  end
  local time = nx_number(form.lbl_time.Text)
  if time <= 0 then
    return
  end
  form.lbl_time.Text = nx_widestr(time - 1)
  local left_time = nx_int(form.lbl_time.Text)
  local minute = math.floor(nx_number(left_time) / 60)
  local second = math.mod(nx_number(left_time), 60)
  if second < 10 then
    form.lbl_format_time.Text = nx_widestr(nx_string(minute) .. ":0" .. nx_string(second))
  else
    form.lbl_format_time.Text = nx_widestr(nx_string(minute) .. ":" .. nx_string(second))
  end
  form.pbar_time.Value = nx_number(left_time)
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_see_click(btn)
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_eye", "open_form")
end
function on_btn_info_click(btn)
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "open_or_hide")
end
function on_btn_out_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_agree_war_quit_confirm")))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_agree_war(nx_int(3))
  end
end
function on_open_timer(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  data_delay = data_delay + 1
  if not nx_find_custom(game_client, "ready") or game_client.ready == false then
    return
  end
  update_stage_info(data_camp_id, data_info, data_delay)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_open_timer", self)
  end
end
function update_stage_info(camp_id, info, delay)
  data_camp_id = camp_id
  data_info = info
  if delay == nil then
    data_delay = 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_find_custom(game_client, "ready") or game_client.ready == false then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(1000, -1, nx_current(), "on_open_timer", nx_value("game_client"), -1, -1)
    end
    return
  end
  form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
  form.my_camp_id = camp_id
  local info_list = util_split_string(info, ",")
  local guild_a = nx_widestr(info_list[1])
  local guild_b = nx_widestr(info_list[2])
  local type_a = nx_int(info_list[3])
  local type_b = nx_int(info_list[4])
  local score_a = nx_int(info_list[5])
  local score_b = nx_int(info_list[6])
  local point_a = nx_int(info_list[7])
  local point_b = nx_int(info_list[8])
  local player_nums_a = nx_int(info_list[9])
  local player_nums_b = nx_int(info_list[10])
  local relive_max_a = nx_int(info_list[11])
  local relive_max_b = nx_int(info_list[12])
  local relive_a = nx_int(info_list[13])
  local relive_b = nx_int(info_list[14])
  local ready_a = nx_int(info_list[15])
  local ready_b = nx_int(info_list[16])
  local nodead_a = nx_int(info_list[17])
  local nodead_b = nx_int(info_list[18])
  local scale = nx_int(info_list[19])
  local cur_round = nx_int(info_list[20])
  local cur_stage = nx_int(info_list[21])
  local left_time = nx_int(info_list[22])
  left_time = left_time - nx_int(data_delay)
  if nx_int(left_time) <= nx_int(0) then
    left_time = nx_int(1)
  end
  form.lbl_guild_a.Text = guild_a
  form.lbl_guild_b.Text = guild_b
  form.type_a = type_a
  form.type_b = type_b
  form.lbl_score_a.Text = nx_widestr(score_a)
  form.lbl_score_b.Text = nx_widestr(score_b)
  form.lbl_relive_a.Text = nx_widestr(relive_a)
  form.lbl_relive_b.Text = nx_widestr(relive_b)
  form.lbl_nodead_a.Text = nx_widestr(nodead_a)
  form.lbl_nodead_b.Text = nx_widestr(nodead_b)
  form.lbl_round.Text = nx_widestr(cur_round)
  form.lbl_stage.Text = nx_widestr(cur_stage)
  form.lbl_time.Text = nx_widestr(left_time)
  form.scale = scale
  form.lbl_stage_ui.Text = nx_widestr(util_text("ui_agree_war_stage_" .. nx_string(cur_stage)))
  form.point_a = point_a
  form.point_b = point_b
  form.pbar_nodead_a.Maximum = nx_number(player_nums_a)
  form.pbar_nodead_a.Value = nx_number(nodead_a)
  form.pbar_nodead_b.Maximum = nx_number(player_nums_b)
  form.pbar_nodead_b.Value = nx_number(nodead_b)
  form.pbar_a.Maximum = nx_number(relive_max_a)
  form.pbar_a.Value = nx_number(relive_a)
  form.pbar_b.Maximum = nx_number(relive_max_b)
  form.pbar_b.Value = nx_number(relive_b)
  form.lbl_ready_a.Visible = false
  form.lbl_ready_b.Visible = false
  form.lbl_nodead_a.Visible = false
  form.lbl_nodead_b.Visible = false
  form.btn_see.Visible = false
  if nx_int(ready_a) == nx_int(1) then
    form.lbl_ready_a.Visible = true
  end
  if nx_int(ready_b) == nx_int(1) then
    form.lbl_ready_b.Visible = true
  end
  if nx_int(cur_stage) == nx_int(0) then
    if nx_int(cur_round) == nx_int(1) then
      form.pbar_time.Maximum = nx_number(form.time_wait_first)
    else
      form.pbar_time.Maximum = nx_number(form.time_wait)
    end
    form.pbar_nodead_a.Value = 100
    form.pbar_nodead_b.Value = 100
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_eye", "close_form")
  elseif nx_int(cur_stage) == nx_int(1) then
    form.pbar_time.Maximum = nx_number(form.time_fight)
    form.lbl_ready_a.Visible = false
    form.lbl_ready_b.Visible = false
    form.lbl_nodead_a.Visible = true
    form.lbl_nodead_b.Visible = true
    form.btn_see.Visible = true
    local form_fight = util_get_form("form_stage_main\\form_agree_war\\form_agree_war_fight", false)
    if nx_is_valid(form_fight) then
      form_fight.btn_ready.Visible = false
      form_fight.btn_ready_cancel.Visible = false
    end
  elseif nx_int(cur_stage) == nx_int(2) then
    form.pbar_time.Maximum = nx_number(form.time_end)
    form.lbl_ready_a.Visible = false
    form.lbl_ready_b.Visible = false
    form.pbar_nodead_a.Value = 100
    form.pbar_nodead_b.Value = 100
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_eye", "close_form")
  end
  form.pbar_time.Value = nx_number(left_time)
  local minute = math.floor(nx_number(left_time) / 60)
  local second = math.mod(nx_number(left_time), 60)
  form.lbl_time_format = nx_widestr(nx_string(minute) .. ":" .. nx_string(second))
  for i = 1, nx_number(score_a) do
    local lbl = form.groupbox_2:Find("lbl_light_a_" .. nx_string(i))
    if nx_is_valid(lbl) then
      lbl.BackImage = "gui\\special\\agree_war\\btn_light_win.png"
    end
  end
  for i = 1, nx_number(score_b) do
    local lbl = form.groupbox_2:Find("lbl_light_b_" .. nx_string(i))
    if nx_is_valid(lbl) then
      lbl.BackImage = "gui\\special\\agree_war\\btn_light_win.png"
    end
  end
end
function update_relive(camp_id, relive_nums)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(camp_id) == nx_int(2351) then
    form.lbl_relive_a.Text = nx_widestr(relive_nums)
    form.pbar_a.Value = nx_number(relive_nums)
  elseif nx_int(camp_id) == nx_int(2352) then
    form.lbl_relive_b.Text = nx_widestr(relive_nums)
    form.pbar_b.Value = nx_number(relive_nums)
  end
end
function update_ready(camp_id, ready)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local lbl_ready
  if nx_int(camp_id) == nx_int(2351) then
    lbl_ready = form.lbl_ready_a
  elseif nx_int(camp_id) == nx_int(2352) then
    lbl_ready = form.lbl_ready_b
  end
  if nx_int(ready) == nx_int(1) then
    lbl_ready.Visible = true
  elseif nx_int(ready) == nx_int(0) then
    lbl_ready.Visible = false
  end
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "init_camp")
end
function update_nodead(camp_id, nodead)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local lbl_nodead
  if nx_int(camp_id) == nx_int(2351) then
    lbl_nodead = form.lbl_nodead_a
    form.pbar_nodead_a.Value = nx_number(nodead)
  elseif nx_int(camp_id) == nx_int(2352) then
    lbl_nodead = form.lbl_nodead_b
    form.pbar_nodead_b.Value = nx_number(nodead)
  end
  lbl_nodead.Text = nx_widestr(nodead)
end
function load_ini(form)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\agree_war\\agree_war.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section = ini:FindSectionIndex("property")
  if section < 0 then
    return
  end
  form.time_wait_first = ini:ReadInteger(section, "time_wait_first", 0)
  form.time_wait = ini:ReadInteger(section, "time_wait", 0)
  form.time_fight = ini:ReadInteger(section, "time_fight", 0)
  form.time_end = ini:ReadInteger(section, "time_end", 0)
end
