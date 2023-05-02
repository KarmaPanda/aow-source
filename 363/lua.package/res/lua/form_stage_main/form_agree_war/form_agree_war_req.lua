require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_agree_war\\form_agree_war_req"
local ARRAY_NAME = "COMMON_ARRAY_AGREE_WAR_REQ"
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
  self.index_count = 0
  load_ini(self)
  init_combobox_scene(self, false)
  self.rbtn_time_3.Checked = true
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  if nx_widestr(guild_name) == nx_widestr("") or nx_widestr(guild_name) == nx_widestr(0) then
    self.rbtn_all.Checked = true
    self.rbtn_guild.Enabled = false
  else
    self.rbtn_guild.Checked = true
  end
  local cooldownbig = nx_value("CoolDownBig")
  if nx_is_valid(cooldownbig) then
    self.lbl_req_cd.Text = nx_widestr(cooldownbig:GetCoolDownBigLeftCount(623))
  end
  custom_agree_war(nx_int(23))
  set_time_after_30(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function on_update_time(form)
  if form.rbtn_time_3.Checked == false then
    return
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local data_time_3 = cur_date_time + nx_number(form.time_start) / 86400
  local year_3, month_3, day_3, hour_3, min_3, sec_3 = nx_function("ext_decode_date", data_time_3)
  form.ipt_time_h.Text = nx_widestr(hour_3)
  form.ipt_time_m.Text = nx_widestr(min_3)
end
function on_combobox_max_selected(combo)
  local form = combo.ParentForm
  reset_scene(form, form.combobox_max.DropListBox.SelectIndex + 1, form.rbtn_all.Checked)
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
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_guild_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.cbtn_type_a.Visible = true
    form.cbtn_type_b.Visible = true
    form.lbl_type_a.Visible = true
    form.lbl_type_b.Visible = true
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local guild_name = client_player:QueryProp("GuildName")
    form.lbl_self_name.Text = nx_widestr(guild_name)
    form.rbtn_time_set.Enabled = true
    form.rbtn_time_set.Visible = true
    form.ipt_time_h.Visible = true
    form.ipt_time_m.Visible = true
    form.lbl_time_day.Visible = true
    form.lbl_5.Visible = true
    form.lbl_4.Visible = true
    form.combobox_guild.Visible = true
    init_combobox_scene(form, false)
    form.cbtn_balance.Checked = true
    form.cbtn_balance.Visible = false
    form.lbl_balance.Visible = false
  end
end
function on_rbtn_all_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.cbtn_type_a.Visible = false
    form.cbtn_type_b.Visible = false
    form.lbl_type_a.Visible = false
    form.lbl_type_b.Visible = false
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local name = client_player:QueryProp("Name")
    form.lbl_self_name.Text = nx_widestr(name)
    form.rbtn_time_3.Checked = true
    form.rbtn_time_set.Enabled = false
    form.rbtn_time_set.Visible = false
    form.ipt_time_h.Visible = false
    form.ipt_time_m.Visible = false
    form.lbl_time_day.Visible = false
    form.lbl_5.Visible = false
    form.lbl_4.Visible = false
    form.combobox_guild.Visible = false
    init_combobox_scene(form, true)
    form.cbtn_balance.Checked = false
    form.cbtn_balance.Visible = true
    form.lbl_balance.Visible = true
  end
end
function on_rbtn_time_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.ipt_time_h.Enabled = false
    form.ipt_time_m.Enabled = false
  end
end
function on_rbtn_time_set_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.ipt_time_h.Enabled = true
    form.ipt_time_m.Enabled = true
  end
end
function set_time_after_30(form)
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local year, month, day, hour, min, sec = nx_function("ext_decode_date", cur_date_time)
  local data_time_30 = cur_date_time + nx_number(1800) / 86400
  local year_30, month_30, day_30, hour_30, min_30, sec_30 = nx_function("ext_decode_date", data_time_30)
  local hour_set = hour_30
  local min_set = min_30
  if day ~= day_30 then
    hour_set = 23
    min_set = 59
  end
  form.ipt_time_h.Text = nx_widestr(hour_set)
  form.ipt_time_m.Text = nx_widestr(min_set)
end
function on_btn_req_click(btn)
  local form = btn.ParentForm
  local type_a = 0
  local type_b = 0
  if form.rbtn_guild.Checked then
    if form.cbtn_type_a.Checked then
      type_a = 1
    end
    if form.cbtn_type_b.Checked then
      type_b = 1
    end
  elseif form.rbtn_all.Checked then
    type_a = 2
    type_b = 2
  end
  local target_guild = nx_widestr(form.ipt_target.Text)
  local scale = form.combobox_max.DropListBox.SelectIndex
  if form.rbtn_guild.Checked then
    scale = scale + 1
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local year, month, day, hour, min, sec = nx_function("ext_decode_date", cur_date_time)
  local start_time
  if form.rbtn_time_3.Checked then
    local time_after = nx_int(form.ipt_1.Text)
    if nx_int(time_after) <= nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_083"))
      return
    end
    local fight_time = cur_date_time + nx_number(time_after) * 60 / 86400
    local y, mon, d, h, m, s = nx_function("ext_decode_date", fight_time)
    start_time = nx_string(y) .. "," .. nx_string(mon) .. "," .. nx_string(d) .. "," .. nx_string(h) .. "," .. nx_string(m) .. ",0"
  elseif form.rbtn_time_set.Checked then
    if nx_widestr(form.ipt_time_h.Text) == nx_widestr("") or nx_widestr(form.ipt_time_m.Text) == nx_widestr("") then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_083"))
      return
    end
    local set_h = nx_int(form.ipt_time_h.Text)
    local set_m = nx_int(form.ipt_time_m.Text)
    if nx_int(set_h) * 60 + nx_int(set_m) <= nx_int(hour) * 60 + nx_int(min) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_084"))
      return
    end
    start_time = nx_string(year) .. "," .. nx_string(month) .. "," .. nx_string(day) .. "," .. nx_string(set_h) .. "," .. nx_string(set_m) .. ",0"
  end
  local balance_nums = nx_int(form.ipt_balance_num.Text)
  local skill_xl = nx_int(form.ipt_skill_xl.Text)
  local skill_sx = nx_int(form.ipt_skill_sx.Text)
  local score_win = nx_int(form.ipt_score.Text)
  local score_diff_win = nx_int(form.ipt_score_diff.Text)
  local player_min = nx_int(form.lbl_min.Text)
  local no_balance = 1
  if form.cbtn_balance.Checked then
    no_balance = 0
  end
  if nx_int(form.lbl_cost.Text) > nx_int(0) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("ui_agree_war_req_war", nx_int(form.lbl_cost.Text))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_agree_war(nx_int(0), target_guild, type_a, type_b, scale, start_time, balance_nums, skill_xl, skill_sx, score_win, score_diff_win, player_min, nx_int(no_balance))
    end
  else
    custom_agree_war(nx_int(0), target_guild, type_a, type_b, scale, start_time, balance_nums, skill_xl, skill_sx, score_win, score_diff_win, player_min, nx_int(no_balance))
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_combobox_guild_selected(combobox)
  local form = combobox.ParentForm
  form.ipt_target.Text = combobox.Text
  combobox.Text = nx_widestr("")
end
function update_guild_list(guild_str)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.combobox_guild.DropListBox:ClearString()
  local guild_list = util_split_string(nx_string(guild_str), ",")
  local index = 1
  local league_count = nx_number(guild_list[index])
  index = index + 1
  for i = 1, league_count do
    local league_name = nx_widestr(guild_list[index])
    index = index + 1
    if nx_widestr(league_name) ~= nx_widestr("") then
      form.combobox_guild.DropListBox:AddString(league_name)
    end
  end
  local league_count = nx_number(guild_list[index])
  index = index + 1
  for i = 1, league_count do
    local enemy_name = nx_widestr(guild_list[index])
    index = index + 1
    if nx_widestr(enemy_name) ~= nx_widestr("") then
      form.combobox_guild.DropListBox:AddString(enemy_name)
    end
  end
end
function load_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\agree_war\\agree_war.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section = ini:FindSectionIndex("property")
  if section < 0 then
    return
  end
  local scene_id_str = ini:ReadString(section, "scene_id", "")
  local cost_str = ini:ReadString(section, "cost", "")
  local scene_photo_str = ini:ReadString(section, "scene_photo", "")
  local player_max_str = ini:ReadString(section, "player_max", "")
  local player_min_str = ini:ReadString(section, "player_min", "")
  local scene_id_list = util_split_string(scene_id_str, ",")
  local cost_list = util_split_string(cost_str, ",")
  local scene_photo_list = util_split_string(scene_photo_str, ",")
  local player_max_list = util_split_string(player_max_str, ",")
  local player_min_list = util_split_string(player_min_str, ",")
  form.index_count = table.getn(scene_id_list)
  for i = 1, table.getn(scene_id_list) do
    local scene_id = nx_int(scene_id_list[i])
    local array_name = get_array_name(i)
    common_array:RemoveArray(array_name)
    common_array:AddArray(array_name, form, 600, true)
    local cost = nx_int(cost_list[i])
    local scene_photo = nx_string(scene_photo_list[i])
    local player_max = nx_int(player_max_list[i])
    local player_min = nx_int(player_min_list[i])
    common_array:AddChild(array_name, "scene_id", nx_string(scene_id))
    common_array:AddChild(array_name, "cost", nx_int(cost))
    common_array:AddChild(array_name, "scene_photo", nx_int(scene_photo))
    common_array:AddChild(array_name, "player_max", nx_int(player_max))
    common_array:AddChild(array_name, "player_min", nx_int(player_min))
  end
  form.time_start = ini:ReadInteger(section, "time_start", "")
  form.ipt_score.Text = nx_widestr(ini:ReadString(section, "score", ""))
  form.ipt_score_diff.Text = nx_widestr(ini:ReadString(section, "score_diff", ""))
end
function get_array_name(index)
  return ARRAY_NAME .. nx_string(index)
end
function reset_scene(form, index, b_all)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if b_all == nil or not b_all then
    index = index + 1
  end
  local scene_id = common_array:FindChild(get_array_name(index), "scene_id")
  local cost = common_array:FindChild(get_array_name(index), "cost")
  local scene_photo = common_array:FindChild(get_array_name(index), "scene_photo")
  local player_max = common_array:FindChild(get_array_name(index), "player_max")
  local player_min = common_array:FindChild(get_array_name(index), "player_min")
  form.lbl_cost.Text = nx_widestr(cost)
  form.lbl_min.Text = nx_widestr(player_min)
end
function init_combobox_scene(form, b_all)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  form.combobox_max.DropListBox:ClearString()
  if b_all then
    for i = 0, form.index_count - 2 do
      local text = "ui_agree_war_scene_" .. nx_string(i)
      form.combobox_max.DropListBox:AddString(nx_widestr(util_text(text)))
    end
  else
    for i = 1, form.index_count - 1 do
      local text = "ui_agree_war_scene_" .. nx_string(i)
      form.combobox_max.DropListBox:AddString(nx_widestr(util_text(text)))
    end
  end
  form.combobox_max.DropListBox.SelectIndex = 0
  form.combobox_max.Text = nx_widestr(form.combobox_max.DropListBox:GetString(0))
  reset_scene(form, 1, b_all)
end
