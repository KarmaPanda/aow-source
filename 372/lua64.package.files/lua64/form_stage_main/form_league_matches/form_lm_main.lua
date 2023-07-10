require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_league_matches\\form_lm_main"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_LEAGUE_MATCHES) then
      self.lbl_lm_season_close.Visible = false
    else
      self.lbl_lm_season_close.Visible = true
    end
  end
  init_lm(self)
  init_reward_grid(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_ig_price_mousein_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local config = grid.config
  nx_execute("tips_game", "show_tips_by_config", nx_string(config), x, y, form)
end
function on_imagegrid_desc_mousein_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local config = grid.DataSource
  nx_execute("tips_game", "show_tips_by_config", nx_string(config), x, y, form)
end
function on_imagegrid_desc_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function init_lm(form)
  form.tg_lm_rank:SetColTitle(0, nx_widestr(util_text("ui_lm_rank_001")))
  form.tg_lm_rank:SetColTitle(1, nx_widestr(util_text("ui_lm_rank_002")))
  form.tg_lm_rank:SetColTitle(2, nx_widestr(util_text("ui_lm_rank_003")))
  form.tg_lm_rank:SetColTitle(3, nx_widestr(util_text("ui_lm_rank_004")))
  form.tg_lm_rank:SetColTitle(4, nx_widestr(util_text("ui_lm_rank_005")))
  custom_league_matches(7)
  custom_league_matches(8)
  form.rbtn_lm_1.Checked = true
  form.rbtn_war_1.Checked = true
end
function on_lm_apply(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_lm_apply.Text = nx_widestr(util_text("ui_lm_apply_1"))
  form.btn_lm_apply.Enabled = false
  form.lbl_16.Visible = true
end
function on_lm_guild(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local is_apply = nx_number(arg[1])
  local score_match = nx_number(arg[2])
  local wins = nx_number(arg[3])
  local joins = nx_number(arg[4])
  local score_last = nx_number(arg[5])
  local score_his = nx_number(arg[6])
  local wins_his = nx_number(arg[7])
  local joins_his = nx_number(arg[8])
  local can_go = nx_number(arg[9])
  local player_joins = nx_number(arg[10])
  local group_res = nx_widestr(arg[11])
  deal_group_res(form, group_res)
  if is_apply == 1 then
    form.btn_lm_apply.Enabled = false
  else
    form.lbl_16.Visible = false
  end
  if 0 == can_go then
    form.btn_lm_go.Enabled = false
  end
  form.lbl_lm_apply.Text = nx_widestr(util_text("ui_lm_apply_" .. nx_string(is_apply)))
  form.lbl_lm_score.Text = nx_widestr(score_match)
  form.lbl_lm_wins.Text = nx_widestr(wins)
  form.lbl_lm_joins.Text = nx_widestr(joins)
  if joins == 0 then
    form.lbl_lm_rate.Text = nx_widestr("0%")
  else
    form.lbl_lm_rate.Text = nx_widestr(nx_string(wins * 100 / joins) .. nx_string("%"))
  end
  form.lbl_lm_score_last.Text = nx_widestr(score_last)
  form.lbl_lm_score_his.Text = nx_widestr(score_his)
  form.lbl_lm_wins_his.Text = nx_widestr(wins_his)
  form.lbl_lm_joins_his.Text = nx_widestr(joins_his)
  if joins_his == 0 then
    form.lbl_lm_rate_his.Text = nx_widestr("0%")
  else
    form.lbl_lm_rate_his.Text = nx_widestr(nx_string(wins_his * 100 / joins_his) .. nx_string("%"))
  end
  form.lbl_lm_player_joins.Text = nx_widestr(player_joins)
end
function on_lm_cross(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local season_no = nx_number(arg[1])
  local season_begin = nx_double(arg[2])
  local season_end = nx_double(arg[3])
  local stage = nx_number(arg[4])
  local stage_more = nx_number(arg[5])
  trans_day(form, stage_more)
  local stage_text = util_text("ui_lm_stage_" .. nx_string(stage))
  local stage_more_text
  if 0 == stage or 1 == stage or 4 == stage then
    stage_more_text = util_text("ui_lm_stage_beizhan_" .. nx_string(stage_more))
  else
    stage_more_text = util_text("ui_lm_stage_more_" .. nx_string(stage))
    if 3 == stage then
      form.rbtn_war_2.Checked = true
    end
  end
  form.lbl_lm_season_no.Text = nx_widestr(season_no + 1)
  form.lbl_lm_season_begin.Text = nx_widestr(get_time_text(season_begin))
  form.lbl_lm_season_end.Text = nx_widestr(get_time_text(season_end))
  form.lbl_lm_stage.Text = nx_widestr(stage_text)
  form.lbl_lm_stage_more.Text = nx_widestr(stage_more_text)
end
function on_lm_group(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local guild_1 = nx_widestr(arg[1])
  local guild_2 = nx_widestr(arg[2])
  local guild_3 = nx_widestr(arg[3])
  local guild_4 = nx_widestr(arg[4])
  local guild_win_1 = nx_widestr(arg[5])
  local guild_win_2 = nx_widestr(arg[6])
  local guild_lose_1 = nx_widestr(arg[7])
  local guild_lose_2 = nx_widestr(arg[8])
  local guild_sort_1 = nx_widestr(arg[9])
  local guild_sort_2 = nx_widestr(arg[10])
  local guild_sort_3 = nx_widestr(arg[11])
  local guild_sort_4 = nx_widestr(arg[12])
  if guild_win_1 == guild_lose_1 then
    guild_win_1 = nx_widestr("")
    guild_lose_1 = nx_widestr("")
  end
  if guild_win_2 == guild_lose_2 then
    guild_win_2 = nx_widestr("")
    guild_lose_2 = nx_widestr("")
  end
  if guild_sort_1 == guild_sort_2 and guild_sort_1 == guild_sort_3 and guild_sort_1 == guild_sort_4 then
    guild_sort_1 = nx_widestr("")
    guild_sort_2 = nx_widestr("")
    guild_sort_3 = nx_widestr("")
    guild_sort_4 = nx_widestr("")
  end
  local war_res_1 = 0
  local war_res_2 = 0
  local war_res_3 = 0
  local war_res_4 = 0
  form.lbl_lm_res_1_1.Visible = false
  form.lbl_lm_res_1_2.Visible = false
  form.lbl_lm_res_2_1.Visible = false
  form.lbl_lm_res_2_2.Visible = false
  form.lbl_lm_res_3_1.Visible = false
  form.lbl_lm_res_3_2.Visible = false
  form.lbl_lm_res_4_1.Visible = false
  form.lbl_lm_res_4_2.Visible = false
  if guild_win_1 ~= nx_widestr("") and guild_win_1 ~= nx_widestr("@") and guild_1 == guild_win_1 then
    war_res_1 = 1
    form.lbl_lm_res_1_1.Visible = true
    form.lbl_lm_res_1_2.Visible = true
    form.lbl_lm_res_1_1.BackImage = "gui\\commom_new\\icon\\win.png"
    form.lbl_lm_res_1_2.BackImage = "gui\\commom_new\\icon\\lose.png"
    form.lbl_lm_index_2_1.BackImage = "gui\\commom_new\\icon\\gp_index_1.png"
    form.lbl_lm_index_2_3.BackImage = "gui\\commom_new\\icon\\gp_index_4.png"
  elseif guild_win_1 ~= nx_widestr("") and guild_win_1 ~= nx_widestr("@") and guild_4 == guild_win_1 then
    war_res_1 = -1
    form.lbl_lm_res_1_1.Visible = true
    form.lbl_lm_res_1_2.Visible = true
    form.lbl_lm_res_1_1.BackImage = "gui\\commom_new\\icon\\lose.png"
    form.lbl_lm_res_1_2.BackImage = "gui\\commom_new\\icon\\win.png"
    form.lbl_lm_index_2_1.BackImage = "gui\\commom_new\\icon\\gp_index_4.png"
    form.lbl_lm_index_2_3.BackImage = "gui\\commom_new\\icon\\gp_index_1.png"
  end
  if guild_win_2 ~= nx_widestr("") and guild_win_2 ~= nx_widestr("@") and guild_2 == guild_win_2 then
    war_res_2 = 1
    form.lbl_lm_res_2_1.Visible = true
    form.lbl_lm_res_2_2.Visible = true
    form.lbl_lm_res_2_1.BackImage = "gui\\commom_new\\icon\\win.png"
    form.lbl_lm_res_2_2.BackImage = "gui\\commom_new\\icon\\lose.png"
    form.lbl_lm_index_2_2.BackImage = "gui\\commom_new\\icon\\gp_index_2.png"
    form.lbl_lm_index_2_4.BackImage = "gui\\commom_new\\icon\\gp_index_3.png"
  elseif guild_win_2 ~= nx_widestr("") and guild_win_2 ~= nx_widestr("@") and guild_3 == guild_win_2 then
    war_res_2 = -1
    form.lbl_lm_res_2_1.Visible = true
    form.lbl_lm_res_2_2.Visible = true
    form.lbl_lm_res_2_1.BackImage = "gui\\commom_new\\icon\\lose.png"
    form.lbl_lm_res_2_2.BackImage = "gui\\commom_new\\icon\\win.png"
    form.lbl_lm_index_2_2.BackImage = "gui\\commom_new\\icon\\gp_index_3.png"
    form.lbl_lm_index_2_4.BackImage = "gui\\commom_new\\icon\\gp_index_2.png"
  end
  if guild_sort_1 ~= nx_widestr("") and guild_sort_1 ~= nx_widestr("@") and guild_win_1 == guild_sort_1 then
    war_res_3 = 1
    form.lbl_lm_res_3_1.Visible = true
    form.lbl_lm_res_3_2.Visible = true
    form.lbl_lm_res_3_1.BackImage = "gui\\commom_new\\icon\\win.png"
    form.lbl_lm_res_3_2.BackImage = "gui\\commom_new\\icon\\lose.png"
  elseif guild_sort_1 ~= nx_widestr("") and guild_sort_1 ~= nx_widestr("@") and guild_win_2 == guild_sort_1 then
    war_res_3 = -1
    form.lbl_lm_res_3_1.Visible = true
    form.lbl_lm_res_3_2.Visible = true
    form.lbl_lm_res_3_1.BackImage = "gui\\commom_new\\icon\\lose.png"
    form.lbl_lm_res_3_2.BackImage = "gui\\commom_new\\icon\\win.png"
  end
  if guild_sort_3 ~= nx_widestr("") and guild_sort_3 ~= nx_widestr("@") and guild_lose_1 == guild_sort_3 then
    war_res_4 = 1
    form.lbl_lm_res_4_1.Visible = true
    form.lbl_lm_res_4_2.Visible = true
    form.lbl_lm_res_4_1.BackImage = "gui\\commom_new\\icon\\win.png"
    form.lbl_lm_res_4_2.BackImage = "gui\\commom_new\\icon\\lose.png"
  elseif guild_sort_3 ~= nx_widestr("") and guild_sort_3 ~= nx_widestr("@") and guild_lose_2 == guild_sort_3 then
    war_res_4 = -1
    form.lbl_lm_res_4_1.Visible = true
    form.lbl_lm_res_4_2.Visible = true
    form.lbl_lm_res_4_1.BackImage = "gui\\commom_new\\icon\\lose.png"
    form.lbl_lm_res_4_2.BackImage = "gui\\commom_new\\icon\\win.png"
  end
  local guildname_1_1, server_1_1 = split_guild_name(guild_1)
  local guildname_1_2, server_1_2 = split_guild_name(guild_4)
  local guildname_2_1, server_2_1 = split_guild_name(guild_2)
  local guildname_2_2, server_2_2 = split_guild_name(guild_3)
  local guildname_3_1, server_3_1 = split_guild_name(guild_win_1)
  local guildname_3_2, server_3_2 = split_guild_name(guild_win_2)
  local guildname_4_1, server_4_1 = split_guild_name(guild_lose_1)
  local guildname_4_2, server_4_2 = split_guild_name(guild_lose_2)
  form.lbl_lm_war_1_1.Text = guildname_1_1
  form.lbl_server_1_1.Text = trans_server_name(server_1_1)
  form.lbl_lm_war_1_2.Text = guildname_1_2
  form.lbl_server_1_2.Text = trans_server_name(server_1_2)
  form.lbl_lm_war_2_1.Text = guildname_2_1
  form.lbl_server_2_1.Text = trans_server_name(server_2_1)
  form.lbl_lm_war_2_2.Text = guildname_2_2
  form.lbl_server_2_2.Text = trans_server_name(server_2_2)
  form.lbl_lm_war_3_1.Text = guildname_3_1
  form.lbl_server_3_1.Text = trans_server_name(server_3_1)
  form.lbl_lm_war_3_2.Text = guildname_3_2
  form.lbl_server_3_2.Text = trans_server_name(server_3_2)
  form.lbl_lm_war_4_1.Text = guildname_4_1
  form.lbl_server_4_1.Text = trans_server_name(server_4_1)
  form.lbl_lm_war_4_2.Text = guildname_4_2
  form.lbl_server_4_2.Text = trans_server_name(server_4_2)
  form.lbl_lm_index_1_1.BackImage = "gui\\commom_new\\icon\\gp_index_1.png"
  form.lbl_lm_index_1_2.BackImage = "gui\\commom_new\\icon\\gp_index_2.png"
  form.lbl_lm_index_1_3.BackImage = "gui\\commom_new\\icon\\gp_index_3.png"
  form.lbl_lm_index_1_4.BackImage = "gui\\commom_new\\icon\\gp_index_4.png"
  replace_gp_image(guild_1, form.lbl_lm_index_1_1)
  replace_gp_image(guild_4, form.lbl_lm_index_1_2)
  replace_gp_image(guild_2, form.lbl_lm_index_1_3)
  replace_gp_image(guild_3, form.lbl_lm_index_1_4)
  replace_gp_image(guild_win_1, form.lbl_lm_index_2_1)
  replace_gp_image(guild_win_2, form.lbl_lm_index_2_2)
  replace_gp_image(guild_lose_1, form.lbl_lm_index_2_3)
  replace_gp_image(guild_lose_2, form.lbl_lm_index_2_4)
end
function replace_gp_image(guild, lbl_lm_index)
  local gp_image = get_guild_flag_image(guild)
  if gp_image ~= nil and gp_image ~= "" then
    lbl_lm_index.BackImage = gp_image
  end
end
function on_lm_rank(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local my_server_name = nx_widestr(arg[1])
  local count = nx_number(arg[2])
  form.tg_lm_rank:ClearRow()
  for i = 1, count do
    local info = arg[i + 2]
    local tab_info = util_split_wstring(info, ",")
    local guild_and_server = nx_widestr(tab_info[1])
    local tab = util_split_wstring(guild_and_server, "@")
    local guild = tab[1]
    local server = tab[2]
    local score = nx_number(tab_info[2])
    local joins = nx_number(tab_info[3])
    local row = form.tg_lm_rank:InsertRow(-1)
    form.tg_lm_rank:SetGridText(row, 0, nx_widestr(i))
    form.tg_lm_rank:SetGridText(row, 1, nx_widestr(guild))
    form.tg_lm_rank:SetGridText(row, 2, nx_widestr(server))
    form.tg_lm_rank:SetGridText(row, 3, nx_widestr(score))
    form.tg_lm_rank:SetGridText(row, 4, nx_widestr(joins))
    if get_player_guild_name() == guild and nx_widestr(server) == my_server_name then
      form.tg_lm_rank:SetGridForeColor(row, 0, "255,255,204,0")
      form.tg_lm_rank:SetGridForeColor(row, 1, "255,255,204,0")
      form.tg_lm_rank:SetGridForeColor(row, 2, "255,255,204,0")
      form.tg_lm_rank:SetGridForeColor(row, 3, "255,255,204,0")
      form.tg_lm_rank:SetGridForeColor(row, 4, "255,255,204,0")
      form.lbl_lm_my_rank.Text = nx_widestr(i)
    end
  end
end
function on_lm_res_his(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local rows_res = nx_number(arg[1])
  form.mltbox_lm_his:Clear()
  for i = 1, rows_res do
    local res_info = arg[i + 1]
    local tab_res = util_split_string(res_info, ";")
    if table.getn(tab_res) ~= 3 then
      break
    end
    local time = nx_double(tab_res[1])
    local res_type = nx_number(tab_res[2])
    local res_info = tab_res[3]
    local time_text = get_time_text(time)
    local ui_text = "ui_lm_his_type" .. nx_string(res_type)
    local text = nx_widestr("")
    if 0 == res_type then
      local tab_info = util_split_string(res_info, ",")
      local no = nx_number(tab_info[1])
      local score_diff = nx_number(tab_info[2])
      local score_match_new = nx_number(tab_info[4])
      if 0 < score_diff then
        ui_text = ui_text .. "_add"
      else
        ui_text = ui_text .. "_dec"
      end
      text = util_format_string(ui_text, time_text, no + 1, score_diff, score_match_new)
    elseif 1 == res_type then
      local tab_info = util_split_string(res_info, ",")
      local score_diff = nx_number(tab_info[1])
      local score_match_new = nx_number(tab_info[3])
      if 0 < score_diff then
        ui_text = ui_text .. "_add"
      else
        ui_text = ui_text .. "_dec"
      end
      text = util_format_string(ui_text, time_text, score_diff, score_match_new)
    elseif 2 == res_type then
      local tab_info = util_split_string(res_info, ",")
      local res = nx_number(tab_info[1])
      local guild_2 = nx_widestr(tab_info[2])
      local score_diff = nx_number(tab_info[3])
      local score_match_new = nx_number(tab_info[5])
      if 0 < score_diff then
        ui_text = ui_text .. "_add"
      else
        ui_text = ui_text .. "_dec"
      end
      if 1 == res then
        ui_text = ui_text .. "_win"
      else
        ui_text = ui_text .. "_lose"
      end
      if guild_2 == nx_widestr("@") then
        text = util_format_string("ui_lm_his_type2_lunkong", time_text, score_diff, score_match_new)
      else
        text = util_format_string(ui_text, time_text, guild_2, score_diff, score_match_new)
      end
    end
    form.mltbox_lm_his:AddHtmlText(nx_widestr(text), -1)
  end
end
function deal_group_res(form, group_res)
  if group_res == nx_widestr("") then
    form.gb_group_res.Visible = false
    return
  end
  form.groupbox_11.Visible = false
  form.gb_group_res.Visible = true
  form.gb_group_res:DeleteAll()
  local arg = util_split_wstring(group_res, ",")
  local count = #arg / 5
  local tab_wins = {
    2,
    1,
    1,
    0
  }
  local tab_price = {
    "box_guild_match_team_001",
    "box_guild_match_team_002",
    "box_guild_match_team_003",
    "box_guild_match_team_004"
  }
  for i = 1, count do
    local no = nx_number(arg[(i - 1) * 5 + 1])
    local index = nx_number(arg[(i - 1) * 5 + 2])
    local guild = nx_widestr(arg[(i - 1) * 5 + 3])
    local server = nx_widestr(arg[(i - 1) * 5 + 4])
    local kill = nx_number(arg[(i - 1) * 5 + 5])
    local gb = create_ctrl("GroupBox", "gb_gp_res_" .. nx_string(i), form.gb_group_res_mod, form.gb_group_res)
    if nx_is_valid(gb) then
      gb.Left = 0
      gb.Top = gb.Height * (i - 1)
      create_ctrl("Label", "lbl_gp_mod_bg_" .. nx_string(i), form.lbl_gp_mod_bg, gb)
      create_ctrl("Label", "lbl_gp_mod_1_" .. nx_string(i), form.lbl_gp_mod_1, gb)
      create_ctrl("Label", "lbl_gp_mod_2_" .. nx_string(i), form.lbl_gp_mod_2, gb)
      local lbl_no = create_ctrl("Label", "lbl_gp_mod_no_" .. nx_string(i), form.lbl_gp_mod_no, gb)
      local lbl_index = create_ctrl("Label", "lbl_gp_mod_index_" .. nx_string(i), form.lbl_gp_mod_index, gb)
      local lbl_guild = create_ctrl("Label", "lbl_gp_mod_guild_" .. nx_string(i), form.lbl_gp_mod_guild, gb)
      local lbl_server = create_ctrl("Label", "lbl_gp_mod_server_" .. nx_string(i), form.lbl_gp_mod_server, gb)
      local lbl_wins = create_ctrl("Label", "lbl_gp_mod_wins_" .. nx_string(i), form.lbl_gp_mod_wins, gb)
      local lbl_kill = create_ctrl("Label", "lbl_gp_mod_kill_" .. nx_string(i), form.lbl_gp_mod_kill, gb)
      local ig_price = create_ctrl("ImageGrid", "ig_gp_mod_price_" .. nx_string(i), form.ig_gp_mod_price, gb)
      nx_bind_script(ig_price, nx_current())
      nx_callback(ig_price, "on_mousein_grid", "on_ig_price_mousein_grid")
      nx_callback(ig_price, "on_mouseout_grid", "on_imagegrid_desc_mouseout_grid")
      lbl_no.BackImage = "gui\\commom_new\\icon\\gp_no_" .. nx_string(no + 1) .. ".png"
      lbl_index.BackImage = "gui\\commom_new\\icon\\gp_index_" .. nx_string(index + 1) .. ".png"
      lbl_guild.Text = guild
      lbl_server.Text = trans_server_name(server)
      lbl_kill.Text = nx_widestr(kill)
      lbl_wins.Text = nx_widestr(tab_wins[i])
      ig_price.config = tab_price[i]
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", tab_price[i], "Photo")
      ig_price:AddItem(0, nx_string(photo), nx_widestr(tab_price[i]), nx_int(1), nx_int(i - 1))
    end
  end
end
function trans_day(form, week_open)
  local msg_delay = nx_value("MessageDelay")
  local cur_date_time = msg_delay:GetServerDateTime()
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", cur_date_time)
  local week = nx_function("ext_get_day_of_week", year, month, day)
  if week == 0 then
    week = 7
  end
  local day_diff = week_open - week
  if day_diff < 0 then
    day_diff = day_diff + 7
  end
  local open_day = cur_date_time + day_diff
  local year2, month2, day2, hour2, mins2, sec2 = nx_function("ext_decode_date", open_day)
  local day_text = util_format_string("ui_lm_day", month2, day2)
  form.lbl_lm_day.Text = nx_widestr(day_text)
end
function split_guild_name(cross_guild)
  local tab_guild_name = util_split_wstring(cross_guild, "@")
  local guild_name = tab_guild_name[1]
  local server_name = tab_guild_name[2]
  return guild_name, server_name
end
function trans_server_name(server_name)
  if server_name == nil or server_name == nx_widestr("") then
    server_name = "--"
  end
  local new_name = "@" .. nx_string(server_name)
  return nx_widestr(new_name)
end
function get_guild_wstr(guild_name, war_res)
  if nx_widestr(guild_name) == nx_widestr("@") or nx_widestr(guild_name) == nx_widestr("") then
    return nx_widestr("--")
  end
  return guild_name
end
function on_btn_lm_apply_click(btn)
  custom_league_matches(0)
end
function on_btn_lm_go_click(btn)
  custom_league_matches(1)
end
function on_rbtn_lm_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = true
    form.gb_lm_2.Visible = false
    form.gb_lm_3.Visible = false
    form.gb_lm_4.Visible = false
    form.gb_lm_5.Visible = false
    form.gb_lm_6.Visible = false
  end
end
function on_rbtn_lm_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = false
    form.gb_lm_2.Visible = true
    form.gb_lm_3.Visible = false
    form.gb_lm_4.Visible = false
    form.gb_lm_5.Visible = false
    form.gb_lm_6.Visible = false
  end
end
function on_rbtn_lm_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = false
    form.gb_lm_2.Visible = false
    form.gb_lm_3.Visible = true
    form.gb_lm_4.Visible = false
    form.gb_lm_5.Visible = false
    form.gb_lm_6.Visible = false
  end
end
function on_rbtn_lm_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = false
    form.gb_lm_2.Visible = false
    form.gb_lm_3.Visible = false
    form.gb_lm_4.Visible = true
    form.gb_lm_5.Visible = false
    form.gb_lm_6.Visible = false
  end
end
function on_rbtn_lm_5_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = false
    form.gb_lm_2.Visible = false
    form.gb_lm_3.Visible = false
    form.gb_lm_4.Visible = false
    form.gb_lm_5.Visible = true
    form.gb_lm_6.Visible = false
  end
end
function on_rbtn_lm_6_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = false
    form.gb_lm_2.Visible = false
    form.gb_lm_3.Visible = false
    form.gb_lm_4.Visible = false
    form.gb_lm_5.Visible = false
    form.gb_lm_6.Visible = true
  end
end
function on_rbtn_war_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_war_1.Visible = true
    form.gb_war_2.Visible = false
  end
end
function on_rbtn_war_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_war_1.Visible = false
    form.gb_war_2.Visible = true
  end
end
function get_time_text(time)
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", time)
  local time_text = string.format("%04d-%02d-%02d %02d:%02d", nx_number(year), nx_number(month), nx_number(day), nx_number(hour), nx_number(mins))
  return time_text
end
function get_player_name()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  return nx_widestr(client_player:QueryProp("Name"))
end
function get_player_guild_name()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  return nx_widestr(client_player:QueryProp("GuildName"))
end
function init_reward_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_1 = form.groupbox_1
  local gb_2 = form.groupbox_3
  for i = 1, 10 do
    local grid_name = "imagegrid_desc_" .. nx_string(i)
    local grid = gb_1:Find(nx_string(grid_name))
    if nx_is_valid(grid) then
      local config_id = nx_string(grid.DataSource)
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
      grid:AddItem(0, nx_string(photo), nx_widestr(config_id), nx_int(1), nx_int(i - 1))
    end
  end
  for i = 11, 20 do
    local grid_name = nx_string("imagegrid_desc_") .. nx_string(i)
    local grid = gb_2:Find(nx_string(grid_name))
    if nx_is_valid(grid) then
      local config_id = nx_string(grid.DataSource)
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
      grid:AddItem(0, nx_string(photo), nx_widestr(config_id), nx_int(1), nx_int(i - 1))
    end
  end
end
function get_guild_flag_image(guild)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\league_matches\\league_matches.ini")
  if not nx_is_valid(ini) then
    return nil
  end
  if not ini:FindSection("guild_flag") then
    return nil
  end
  local sec_index = ini:FindSectionIndex("guild_flag")
  if nx_number(sec_index) < 0 then
    return nil
  end
  return ini:ReadString(sec_index, nx_string(guild), "")
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
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
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function a(info)
  nx_msgbox(nx_string(info))
end
