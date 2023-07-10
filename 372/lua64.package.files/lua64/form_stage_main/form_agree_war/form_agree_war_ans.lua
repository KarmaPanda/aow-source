require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_agree_war\\form_agree_war_ans"
local scene_tab = {}
function main_form_init(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
  self.gb_ans.Visible = false
  self.gb_join.Visible = false
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  custom_agree_war(nx_int(1), nx_string(form.war_id), nx_int(1))
end
function on_btn_no_click(btn)
  local form = btn.ParentForm
  custom_agree_war(nx_int(1), nx_string(form.war_id), nx_int(0))
end
function on_btn_join_a_click(btn)
  local form = btn.ParentForm
  custom_agree_war(nx_int(2), nx_string(form.war_id), nx_int(2351))
end
function on_btn_join_b_click(btn)
  local form = btn.ParentForm
  custom_agree_war(nx_int(2), nx_string(form.war_id), nx_int(2352))
end
function on_btn_close_click(btn)
  close_form()
end
function open_form(info)
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  load_ini()
  local info_list = util_split_string(info, ",")
  local war_id = nx_string(info_list[1])
  local guild_a = nx_widestr(info_list[2])
  local guild_b = nx_widestr(info_list[3])
  local player_a = nx_widestr(info_list[4])
  local player_b = nx_widestr(info_list[5])
  local apply_type_a = nx_int(info_list[6])
  local apply_type_b = nx_int(info_list[7])
  local scale = nx_int(info_list[8])
  local start_time = nx_double(info_list[9])
  local total_time = nx_int(info_list[10])
  local start_sign = nx_int(info_list[11])
  local player_nums_a = nx_int(info_list[12])
  local player_nums_b = nx_int(info_list[13])
  local balance_fight = nx_int(info_list[14])
  local skill_xl = nx_int(info_list[15])
  local skill_sx = nx_int(info_list[16])
  local score_win = nx_int(info_list[17])
  local score_diff_win = nx_int(info_list[18])
  local player_min = nx_int(info_list[19])
  local year, month, day, hour, min, sec = nx_function("ext_decode_date", start_time)
  local time = nx_string(year) .. "-" .. nx_string(month) .. "-" .. nx_string(day) .. " " .. nx_string(hour) .. ":" .. nx_string(min)
  form.war_id = war_id
  form.scale = scale
  form.lbl_scene.Text = nx_widestr(scene_tab[scale + 1].scene_id)
  form.lbl_scene_image.BackImage = nx_widestr(scene_tab[scale + 1].scene_photo)
  form.lbl_test.Text = nx_widestr(war_id)
  form.lbl_guild_a.Text = guild_a
  form.lbl_guild_b.Text = guild_b
  form.lbl_type_a.Text = nx_widestr(apply_type_a)
  form.lbl_type_b.Text = nx_widestr(apply_type_b)
  form.lbl_player_max.Text = nx_widestr(scene_tab[scale + 1].player_max)
  form.lbl_player_min.Text = nx_widestr(player_min)
  form.lbl_time.Text = nx_widestr(time)
  form.lbl_time_total.Text = nx_widestr(total_time)
  form.lbl_score_win.Text = nx_widestr(score_win)
  form.lbl_score_diff_win.Text = nx_widestr(score_diff_win)
  form.lbl_balance_nums.Text = nx_widestr(balance_fight)
  form.lbl_skill_xl.Text = nx_widestr(skill_xl)
  form.lbl_skill_sx.Text = nx_widestr(skill_sx)
  if nx_widestr(player_b) == nx_widestr("") then
    form.gb_ans.Visible = true
  end
  if start_sign == nx_int(1) then
    form.gb_join.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
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
  local scene_id_str = ini:ReadString(section, "scene_id", "")
  local scene_photo_str = ini:ReadString(section, "scene_photo", "")
  local player_max_str = ini:ReadString(section, "player_max", "")
  local player_min_str = ini:ReadString(section, "player_min", "")
  local scene_id_list = util_split_string(scene_id_str, ",")
  local scene_photo_list = util_split_string(scene_photo_str, ",")
  local player_max_list = util_split_string(player_max_str, ",")
  local player_min_list = util_split_string(player_min_str, ",")
  for i = 1, table.getn(scene_id_list) do
    local scene_id = nx_int(scene_id_list[i])
    local tab = {}
    tab.scene_id = scene_id
    tab.scene_photo = nx_string(scene_photo_list[i])
    tab.player_max = nx_int(player_max_list[i])
    tab.player_min = nx_int(player_min_list[i])
    table.insert(scene_tab, i, tab)
  end
end
