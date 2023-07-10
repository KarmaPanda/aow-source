require("util_functions")
require("custom_handler")
require("custom_sender")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local FORM_GUILD_WAR = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info"
local FORM_LEAGUE = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_league"
local CLIENT_CUSTOMMSG_GUILD = 1014
local NONE_DECLEAR = 0
local DECLEAR_WAR = 1
local BE_DECLEAR = 2
local SUB_CUSTOMMSG_REQUEST_HOSTILE_GUILD = 64
local SUB_CUSTOMMSG_REQUEST_CHASE_GUILD = 65
local SUB_CUSTOMMSG_REQUEST_BE_CHASED_INFO = 66
local SUB_CUSTOMMSG_REQUEST_GUILD_WAR = 103
local SUB_CUSTOMMSG_CHASE_AVENGE = 116
local SUB_CUSTOMMSG_GET_AVENGE_LIST = 117
local ENEMY_REC_EMPTY = 0
local ENEMY_REC_FROM_OVER = 1
local ENEMY_REC_TO_OVER = 2
local ENEMY_REC_NORMAL = 3
local ST_FUNCTION_GUILD_CHASE_LEVEL_LIMIT = 695
local tab_cw_level = {}
local table_chase_level_info = {
  [1] = {
    {1},
    1
  },
  [2] = {
    {
      2,
      3,
      4,
      5
    },
    3
  }
}
local chase_tool_table = {
  {
    config_id = "GUILD_CHASE_TOOL_01",
    desc = "chase_tool_new_01"
  },
  {
    config_id = "GUILD_CHASE_TOOL_02",
    desc = "chase_tool_new_02"
  },
  {
    config_id = "GUILD_CHASE_TOOL_03",
    desc = "chase_tool_new_03"
  },
  {
    config_id = "GUILD_CHASE_TOOL_04",
    desc = "chase_tool_new_04"
  },
  {
    config_id = "GUILD_CHASE_TOOL_05",
    desc = "chase_tool_new_05"
  },
  {
    config_id = "GUILD_CHASE_TOOL_06",
    desc = "chase_tool_new_06"
  },
  {
    config_id = "GUILD_CHASE_TOOL_07",
    desc = "chase_tool_new_07"
  },
  {
    config_id = "GUILD_CHASE_TOOL_08",
    desc = "chase_tool_new_08"
  },
  {
    config_id = "GUILD_CHASE_TOOL_09",
    desc = "chase_tool_new_09"
  },
  {
    config_id = "GUILD_CHASE_TOOL_10",
    desc = "chase_tool_new_10"
  },
  {
    config_id = "GUILD_CHASE_TOOL_11",
    desc = "chase_tool_new_11"
  }
}
local tab_guild_domain_link = {}
local tab_domain_color = {
  [101] = "255,178,0,255",
  [201] = "255,128,128,128",
  [302] = "255,0,148,255",
  [402] = "255,214,127,255",
  [503] = "255,127,146,255",
  [602] = "255,255,233,127",
  [703] = "255,127,201,255",
  [801] = "255,255,216,0",
  [902] = "255,255,178,127",
  [1001] = "255,255,127,237",
  [1101] = "255,128,128,128",
  [1203] = "255,128,128,128",
  [1301] = "255,255,0,110",
  [1404] = "255,255,127,127",
  [1602] = "255,128,128,128",
  [1703] = "255,255,106,0"
}
local tab_domain_link = {
  [101] = {902, 1001},
  [302] = {1404, 801},
  [402] = {602, 503},
  [503] = {
    402,
    602,
    1301
  },
  [602] = {
    1301,
    402,
    503
  },
  [703] = {1404, 801},
  [801] = {
    1404,
    703,
    302,
    1301,
    1703
  },
  [902] = {
    1703,
    101,
    1001
  },
  [1001] = {
    101,
    902,
    1703
  },
  [1301] = {
    503,
    602,
    801,
    1703
  },
  [1404] = {
    302,
    703,
    801
  },
  [1703] = {
    1001,
    902,
    801,
    1301
  }
}
local tab_main_domain_id = {
  101,
  402,
  1404
}
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  self.lbl_sel_guild.sel_guild_name = nx_widestr("")
  local gbox = self.groupbox_guild_league
  if not nx_is_valid(gbox) then
    return
  end
  local form_league = util_get_form(FORM_LEAGUE, true, false)
  if nx_is_valid(form_league) then
    form_league.Left = 0
    form_league.Top = 0
    gbox:Add(form_league)
    self.form_league = form_league
  end
  self.rbtn_guild_league.Checked = true
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_WAR))
  end
  self.open_level_limit = false
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_CHASE_LEVEL_LIMIT) then
      self.open_level_limit = true
    end
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_CROSS_STATION_WAR) then
      self.rbtn_cross_station_war.Visible = true
    else
      self.rbtn_cross_station_war.Visible = false
    end
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_CHAMPION_WAR) then
      self.rbtn_champion_war.Visible = true
    else
      self.rbtn_champion_war.Visible = false
    end
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_LEAGUE_MATCHES) then
      self.lbl_lm_season_close.Visible = false
    else
      self.lbl_lm_season_close.Visible = true
    end
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_CHASE_AVENGE) then
      self.gb_chase_rbtn.Visible = true
    else
      self.gb_chase_rbtn.Visible = false
    end
  end
  init_chase_controls(self)
  self.request_flag = 0
  set_page(1)
  self.groupbox_select_tool.Visible = false
  self.btn_chase.Enabled = false
  self.groupbox_select_tool.Top = 160
  self.groupbox_info.Top = 160
  nx_execute("custom_sender", "custom_corss_station_war", 1)
  nx_execute("custom_sender", "custom_corss_station_war", 0)
  init_cw(self)
  init_reward_grid(self)
  init_lm(self)
  init_chase_avenge(self)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_avenge_timer", self)
  timer:UnRegister(nx_current(), "on_delay_get_avenge_list_timer", self)
  if nx_find_custom(self, "form_league") and nx_is_valid(self.form_league) then
    self.form_league:Close()
  end
  nx_destroy(self)
end
function on_rbtn_chase_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked and nx_id_equal(rbtn, form.rbtn_chase) then
    form.groupbox_chase.Visible = true
    form.groupbox_guild_war.Visible = false
    form.groupbox_crosswar.Visible = false
    form.groupbox_guild_league.Visible = false
    form.gb_cross_station_war.Visible = false
    form.groupbox_champion_war.Visible = false
    form.groupbox_league_matches.Visible = false
  end
end
function on_rbtn_guild_war_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked and nx_id_equal(rbtn, form.rbtn_guild_war) then
    form.groupbox_chase.Visible = false
    form.groupbox_guild_war.Visible = true
    form.groupbox_crosswar.Visible = false
    form.groupbox_guild_league.Visible = false
    form.gb_cross_station_war.Visible = false
    form.groupbox_champion_war.Visible = false
    form.groupbox_league_matches.Visible = false
  end
end
function on_rbtn_crosswar_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked and nx_id_equal(rbtn, form.rbtn_crosswar) then
    form.groupbox_chase.Visible = false
    form.groupbox_guild_war.Visible = false
    form.groupbox_crosswar.Visible = true
    form.groupbox_guild_league.Visible = false
    form.gb_cross_station_war.Visible = false
    form.groupbox_champion_war.Visible = false
    form.groupbox_league_matches.Visible = false
  end
end
function on_rbtn_guild_league_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked and nx_id_equal(rbtn, form.rbtn_guild_league) then
    form.groupbox_chase.Visible = false
    form.groupbox_guild_war.Visible = false
    form.groupbox_crosswar.Visible = false
    form.groupbox_guild_league.Visible = true
    form.gb_cross_station_war.Visible = false
    form.groupbox_champion_war.Visible = false
    form.groupbox_league_matches.Visible = false
  end
end
function on_rbtn_cross_station_war_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_chase.Visible = false
    form.groupbox_guild_war.Visible = false
    form.groupbox_crosswar.Visible = false
    form.groupbox_guild_league.Visible = false
    form.gb_cross_station_war.Visible = true
    form.groupbox_champion_war.Visible = false
    form.groupbox_league_matches.Visible = false
  end
end
function on_rbtn_champion_war_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_chase.Visible = false
    form.groupbox_guild_war.Visible = false
    form.groupbox_crosswar.Visible = false
    form.groupbox_guild_league.Visible = false
    form.gb_cross_station_war.Visible = false
    form.groupbox_champion_war.Visible = true
    form.groupbox_league_matches.Visible = false
  end
end
function on_rbtn_league_matches_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_chase.Visible = false
    form.groupbox_guild_war.Visible = false
    form.groupbox_crosswar.Visible = false
    form.groupbox_guild_league.Visible = false
    form.gb_cross_station_war.Visible = false
    form.groupbox_champion_war.Visible = false
    form.groupbox_league_matches.Visible = true
  end
end
function on_btn_crosswar_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_AGREE_WAR) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_switch_close"))
    return
  end
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_req", "open_form")
end
function on_btn_1_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and not switch_manager:CheckSwitchEnable(906) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("desc_events_250"))
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_domain", "open_form_for_browse")
end
function rec_guild_war_info(...)
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  local mltbox = form.mltbox_4
  if not nx_is_valid(mltbox) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local arg_num = table.getn(arg)
  if nx_int(arg_num) < nx_int(5) then
    return
  end
  local war_stage = nx_int(arg[1])
  local domain_id = nx_string(arg[2])
  local domain_name = nx_widestr("")
  if domain_id ~= "" and domain_id ~= nil then
    domain_name = nx_widestr(gui.TextManager:GetText("ui_dipan_" .. nx_string(domain_id)))
  end
  local guild_state = nx_int(arg[3])
  local enemy_name = nx_widestr(arg[4])
  local week = nx_int(arg[5])
  if nx_int(war_stage) == nx_int(NONE_DECLEAR) then
    mltbox.HtmlText = nx_widestr("")
  elseif nx_int(war_stage) == nx_int(DECLEAR_WAR) then
    mltbox.HtmlText = nx_widestr(gui.TextManager:GetFormatText("19958", nx_int(week), nx_widestr(domain_name), nx_widestr(enemy_name)))
  elseif nx_int(war_stage) == nx_int(BE_DECLEAR) then
    mltbox.HtmlText = nx_widestr(gui.TextManager:GetFormatText("19959", nx_int(week), nx_widestr(domain_name), nx_widestr(enemy_name)))
  end
end
function init_chase_controls(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "open_level_limit") then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  set_grid_col(grid, 0, grid.Width * 0.2, "ui_escort_blackmarket_school")
  set_grid_col(grid, 1, grid.Width * 0.1, "ui_search_by_level")
  set_grid_col(grid, 2, grid.Width * 0.1, "ui_domain_rolenum")
  set_grid_col(grid, 3, grid.Width * 0.1, "ui_guild_emeny_days")
  set_grid_col(grid, 4, grid.Width * 0.1, "ui_guild_kill_num")
  set_grid_col(grid, 5, grid.Width * 0.1, "ui_guild_be_kill_num")
  set_grid_col(grid, 6, grid.Width * 0.1, "ui_guild_chasestate")
  set_grid_col(grid, 7, grid.Width * 0.15, "ui_guild_chaseinfo")
  grid:EndUpdate()
end
function set_grid_col(grid, index, width, title)
  grid:SetColWidth(index, width)
  grid:SetColTitle(index, util_text(title))
end
function request_hostile_guild(page_no)
  local from_num = 0
  local to_num = 0
  from_num = (nx_int(page_no) - 1) * 100 + 1
  to_num = nx_int(page_no) * 100
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_HOSTILE_GUILD), nx_int(from_num), nx_int(to_num))
end
function set_page(page_no)
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  form.page_no = nx_int(page_no)
  request_hostile_guild(form.page_no)
end
function priv_page()
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "page_no") then
    return
  end
  if form.page_no <= nx_int(1) then
    return
  end
  form.request_flag = 2
  set_page(form.page_no - nx_int(1))
end
function next_page()
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "page_no") then
    return
  end
  form.request_flag = 1
  set_page(form.page_no + nx_int(1))
end
function update_last_war_res(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  show_domain_info(form, nx_string(arg[1]))
  refresh_domain_color(form)
end
function update_next_war(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local index = arg[1]
  local state = arg[2]
  local time = arg[3]
  local server_list = arg[4]
  form.lbl_war_index.Text = nx_widestr(index)
  form.lbl_state.Text = nx_widestr(util_text("ui_kfzdz_state_" .. nx_string(state)))
  if nx_number(state) == 0 or nx_number(state) == 2 then
    local tab_time = util_split_string(time, ",")
    form.lbl_war_time.Text = nx_widestr(util_format_string("ui_cross_station_war_time_" .. nx_string(tab_time[1]), nx_int(tab_time[2]), nx_int(tab_time[3])))
  else
    form.lbl_war_time.Text = nx_widestr(util_text("ui_cross_station_war_003"))
  end
  local tab_server = util_split_wstring(server_list, ",")
  for i = 1, table.getn(tab_server) do
    local server_name = tab_server[i]
    local gb = form.groupbox_4:Find("gb_server_" .. nx_string(i))
    if nx_is_valid(gb) then
      local lbl = gb:Find("lbl_server_" .. nx_string(i))
      if nx_is_valid(gb) then
        gb.Visible = true
        lbl.Text = nx_widestr(server_name)
      end
    end
  end
end
function on_rec_hostile_guild(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(arg[1]) == nx_int(ENEMY_REC_FROM_OVER) or nx_int(arg[1]) == nx_int(ENEMY_REC_EMPTY) then
    if nx_int(form.request_flag) == nx_int(1) then
      form.page_no = form.page_no - 1
    elseif nx_int(form.request_flag) == nx_int(2) then
      form.page_no = form.page_no + 1
    end
  end
  form.lbl_page.Text = nx_widestr(form.page_no)
  local data_size = table.getn(arg) - 1
  if data_size <= 0 or data_size % 7 ~= 0 then
    return
  end
  clear_grid(form)
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  for i = 1, nx_number(nx_int(data_size) / 7) do
    local row = grid:InsertRow(-1)
    local offset_index = (i - 1) * 7 + 2
    local guild_name_index = offset_index + 0
    local guild_level_index = offset_index + 1
    local member_count_index = offset_index + 2
    local emeny_days_index = offset_index + 3
    local kill_num_index = offset_index + 4
    local be_kill_num_index = offset_index + 5
    local chase_status_index = offset_index + 6
    local guild_name = nx_widestr(arg[guild_name_index])
    grid:SetGridText(row, 0, nx_widestr(arg[guild_name_index]))
    if nx_int(arg[guild_level_index]) ~= nx_int(0) then
      grid:SetGridText(row, 1, nx_widestr(util_text(nx_string("ui_sns_number_") .. nx_string(arg[guild_level_index]))))
    else
      grid:SetGridText(row, 1, nx_widestr(util_text(nx_string("ui_None"))))
    end
    grid:SetGridText(row, 2, nx_widestr(arg[member_count_index]))
    local seconds = calc_diff_sec(arg[emeny_days_index])
    grid:SetGridText(row, 3, nx_widestr(format_days_text(seconds)))
    grid:SetGridText(row, 4, nx_widestr(arg[kill_num_index]))
    grid:SetGridText(row, 5, nx_widestr(arg[be_kill_num_index]))
    local ctrl = gui:Create("Label")
    if nx_is_valid(ctrl) then
      ctrl.AutoSize = false
      ctrl.Align = "Center"
      ctrl.DrawMode = "FitWindow"
      if nx_int(arg[chase_status_index]) == nx_int(0) then
        ctrl.BackImage = "gui\\guild\\guildwar\\chase_can.png"
        ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_chase_state_0"))
        ctrl.Transparent = false
      elseif nx_int(arg[chase_status_index]) == nx_int(1) then
        ctrl.BackImage = "gui\\guild\\guildwar\\chase_cannot.png"
        ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_chase_state_1"))
        ctrl.Transparent = false
      end
      grid:SetGridControl(row, 6, ctrl)
    end
    local btn = gui:Create("Button")
    if nx_is_valid(btn) then
      btn.Width = grid:GetColWidth(4)
      btn.Height = grid.RowHeight
      btn.NormalImage = "gui\\common\\button\\btn_normal1_out.png"
      btn.FocusImage = "gui\\common\\button\\btn_normal1_on.png"
      btn.PushImage = "gui\\common\\button\\btn_normal1_down.png"
      btn.DrawMode = "Expand"
      btn.ForeColor = "255, 255, 255, 255"
      btn.Text = nx_widestr(util_text("ui_xiangxixinxi"))
      btn.Align = "Center"
      btn.NoFrame = true
      btn.Solid = false
      btn.Transparent = false
      btn.GuildName = guild_name
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_info_click")
      grid:SetGridControl(row, 7, btn)
    end
  end
  grid:EndUpdate()
end
function on_rec_guild_be_chased_info(...)
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if table.getn(arg) ~= 2 then
    return
  end
  if form.open_level_limit then
    form.lbl_chase_1.Visible = true
    form.lbl_chase_2.Visible = true
    form.lbl_chase_count_1.Visible = true
    form.lbl_chase_count_2.Visible = true
    form.lbl_chase_1.Text = nx_widestr(util_text(nx_string("ui_chase_tips_03")))
    form.lbl_chase_2.Text = nx_widestr(util_text(nx_string("ui_chase_tips_04")))
    form.lbl_chase_count_1.Text = nx_widestr(nx_string(0) .. "/" .. nx_string(table_chase_level_info[1][2]))
    form.lbl_chase_count_2.Text = nx_widestr(nx_string(0) .. "/" .. nx_string(table_chase_level_info[2][2]))
  else
    form.lbl_chase_1.Visible = true
    form.lbl_chase_2.Visible = false
    form.lbl_chase_count_1.Visible = true
    form.lbl_chase_count_2.Visible = false
    form.lbl_chase_1.Text = nx_widestr(util_text(nx_string("ui_chase_num")))
    form.lbl_chase_count_1.Text = nx_widestr(nx_string(arg[1]) .. "/3")
  end
  local main_str = nx_widestr(arg[2])
  local mltbox = form.mltbox_info
  form.mltbox_info.LeftTimeStr = main_str
  form.mltbox_info.HtmlText = nx_widestr("")
  show_groupbox_info()
  refresh_be_chased_info(form)
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid
  grid:BeginUpdate()
  grid:ClearRow()
  grid:EndUpdate()
end
function on_btn_shop_click(btn)
  nx_execute("form_stage_main\\form_attribute_mall\\form_attribute_shop_kfzdz", "open_form")
end
function on_btn_cross_buy_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_buy", "open_form")
end
function on_btn_cross_join_click(btn)
  nx_execute("custom_sender", "custom_corss_station_war", 4)
end
function on_btn_info_click(btn)
  if nx_ws_length(nx_widestr(btn.GuildName)) <= 0 then
    return
  end
  hide_groupbox_info(false)
  request_guild_be_chased_info(btn.GuildName)
end
function start_info_count_timer()
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "refresh_be_chased_info", form, -1, -1)
  end
end
function end_info_count_timer()
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_be_chased_info", form)
  end
end
function show_groupbox_info()
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  local group_box = form.groupbox_info
  if not nx_is_valid(group_box) then
    return
  end
  group_box.Visible = true
  start_info_count_timer(form)
end
function hide_groupbox_info(init)
  local form = nx_value(FORM_GUILD_WAR)
  if not nx_is_valid(form) then
    return
  end
  local group_box = form.groupbox_info
  if not nx_is_valid(group_box) then
    return
  end
  group_box.Visible = false
  end_info_count_timer()
end
function refresh_be_chased_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local group_box = form.groupbox_info
  if not nx_is_valid(group_box) then
    return
  end
  if group_box.Visible == false then
    end_info_count_timer()
    return
  end
  local mltbox = form.mltbox_info
  if not nx_is_valid(mltbox) then
    return
  end
  local main_str = mltbox.LeftTimeStr
  if nx_ws_length(nx_widestr(main_str)) <= 0 then
    end_info_count_timer()
    return
  end
  local show_text = nx_widestr("")
  local new_main_str = ""
  local new_count = 0
  local new_count_1 = 0
  local new_count_2 = 0
  local main_table = util_split_string(nx_string(main_str), "|")
  for i = 1, table.getn(main_table) do
    local sub_table = util_split_string(nx_string(main_table[i]), ",")
    if table.getn(sub_table) == 5 then
      local cur_type = sub_table[1]
      local cur_guild_name = sub_table[2]
      local left_time = nx_number(sub_table[3]) - nx_number(1)
      local guild_level = nx_int(sub_table[4])
      local is_avenge = nx_number(sub_table[5])
      if nx_number(left_time) > nx_number(0) then
        if nx_int(cur_type) == nx_int(0) then
          show_text = show_text .. nx_widestr((gui.TextManager:GetFormatText("ui_chase_left_time_" .. nx_string(is_avenge), nx_widestr(guild_level), nx_widestr(cur_guild_name))))
          if is_avenge == 0 then
            new_count = new_count + 1
          end
          local level_type = get_chase_level_type(form, guild_level)
          if nx_number(level_type) == nx_number(1) and is_avenge == 0 then
            new_count_1 = new_count_1 + 1
          elseif nx_number(level_type) == nx_number(2) and is_avenge == 0 then
            new_count_2 = new_count_2 + 1
          end
        elseif nx_int(cur_type) == nx_int(1) then
          show_text = show_text .. nx_widestr(util_text("ui_chase_cd_left_time"))
        end
        show_text = show_text .. nx_widestr(get_format_time(nx_number(left_time)))
        show_text = show_text .. nx_widestr("<br>")
        new_main_str = new_main_str .. nx_string(cur_type) .. "," .. nx_string(cur_guild_name) .. "," .. nx_string(left_time) .. "," .. nx_string(guild_level) .. "," .. nx_string(is_avenge) .. "|"
      end
    end
  end
  mltbox.LeftTimeStr = new_main_str
  if form.open_level_limit then
    form.lbl_chase_1.Visible = true
    form.lbl_chase_2.Visible = true
    form.lbl_chase_count_1.Visible = true
    form.lbl_chase_count_2.Visible = true
    form.lbl_chase_1.Text = nx_widestr(util_text(nx_string("ui_chase_tips_03")))
    form.lbl_chase_2.Text = nx_widestr(util_text(nx_string("ui_chase_tips_04")))
    form.lbl_chase_count_1.Text = nx_widestr(nx_string(new_count_1) .. "/" .. nx_string(table_chase_level_info[1][2]))
    form.lbl_chase_count_2.Text = nx_widestr(nx_string(new_count_2) .. "/" .. nx_string(table_chase_level_info[2][2]))
  else
    form.lbl_chase_1.Visible = true
    form.lbl_chase_2.Visible = false
    form.lbl_chase_count_1.Visible = true
    form.lbl_chase_count_2.Visible = false
    form.lbl_chase_1.Text = nx_widestr(util_text(nx_string("ui_chase_num")))
    form.lbl_chase_count_1.Text = nx_widestr(nx_string(new_count) .. "/3")
  end
  mltbox.HtmlText = nx_widestr(show_text)
end
function on_btn_info_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_info.Visible = false
  end_info_count_timer()
end
function on_btn_next_click(btn)
  next_page()
end
function on_btn_priv_click(btn)
  priv_page()
end
function get_chase_level_type(form, guild_level)
  if nx_number(guild_level) <= nx_number(0) then
    return 0
  end
  for i = 1, table.getn(table_chase_level_info) do
    local tab_level_info = table_chase_level_info[i][1]
    for j = 1, table.getn(tab_level_info) do
      if nx_number(guild_level) == nx_number(tab_level_info[j]) then
        return i
      end
    end
  end
  return 0
end
function get_format_time(time)
  local time_text = ""
  if nx_number(time) < nx_number(0) then
    return time_text
  end
  local hour = nx_int(time / 3600)
  local minute = nx_int(time % 3600 / 60)
  local second = nx_int(time % 60)
  time_text = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(minute), nx_number(second))
  return time_text
end
function request_guild_be_chased_info(guild_name)
  if nx_ws_length(nx_widestr(guild_name)) <= 0 then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_BE_CHASED_INFO), nx_widestr(guild_name))
end
function on_btn_set_emeny_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_guild_league.Checked = true
end
function on_btn_chase_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_select_tool_ok.Enabled = false
  fill_tool_info(form)
  form.groupbox_select_tool.Visible = true
end
function on_btn_select_tool_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_select_tool.Visible = false
  if form.lbl_sel_guild.sel_guild_name == nx_widestr("") then
    return
  end
  if not nx_find_custom(form, "sel_chase_tool") then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_CHASE_GUILD), nx_widestr(form.lbl_sel_guild.sel_guild_name), nx_string(form.sel_chase_tool))
end
function on_btn_select_tool_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_select_tool.Visible = false
end
function on_grid_select_row(self, row)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_sel_guild.sel_guild_name = nx_widestr(self:GetGridText(row, 0))
  form.lbl_sel_guild.DataSource = nx_widestr(self:GetGridText(row, 0))
  form.lbl_sel_guild.Text = gui.TextManager:GetFormatText("ui_newguild_title_110", nx_widestr(self:GetGridText(row, 0)))
  form.btn_chase.Enabled = true
end
function fill_tool_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_tools:DeleteAll()
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local has_goods_count = 0
  for i = 1, table.getn(chase_tool_table) do
    local count = goods_grid:GetItemCount(chase_tool_table[i].config_id)
    if 0 < count then
      local rbtn = gui:Create("RadioButton")
      form.groupbox_tools:Add(rbtn)
      rbtn.NormalImage = "gui\\commom_new\\check_btn\\bchoose_out.png"
      rbtn.FocusImage = "gui\\commom_new\\check_btn\\bchoose_on.png"
      rbtn.CheckedImage = "gui\\commom_new\\check_btn\\bchoose_down.png"
      rbtn.Font = "font_text"
      rbtn.ForeColor = "255,255,255,255"
      rbtn.BackColor = "255,192,192,192"
      rbtn.ShadowColor = "0,20,0,0"
      rbtn.Width = 20
      rbtn.Height = 20
      rbtn.Left = 35
      rbtn.Top = (rbtn.Width + 5) * has_goods_count
      rbtn.DrawMode = "FitWindow"
      rbtn.DataSource = nx_string(chase_tool_table[i].config_id)
      nx_bind_script(rbtn, nx_current())
      nx_callback(rbtn, "on_checked_changed", "on_rbtn_select_tool_changed")
      local lbl = gui:Create("Label")
      form.groupbox_tools:Add(lbl)
      lbl.AutoSize = false
      lbl.Align = "Left"
      lbl.Font = "font_main"
      lbl.ForeColor = "255,197,184,159"
      lbl.BackImage = "gui\\special\\camera\\bg_time_out.png"
      lbl.NoFrame = false
      lbl.Top = rbtn.Top
      lbl.Left = rbtn.Left + rbtn.Width + 10
      lbl.Height = rbtn.Height
      lbl.Width = form.groupbox_tools.Width - lbl.Left
      local comment = gui.TextManager:GetFormatText(chase_tool_table[i].desc, util_text(chase_tool_table[i].config_id), nx_int(count))
      lbl.Text = nx_widestr(comment)
      has_goods_count = has_goods_count + 1
    end
  end
  if has_goods_count <= 0 then
    form.groupbox_tools.Visible = false
    form.mltbox_nogoods.Visible = true
    form.groupbox_tools.Height = 80
  else
    form.groupbox_tools.Visible = true
    form.mltbox_nogoods.Visible = false
    form.groupbox_tools.Height = has_goods_count * 25
  end
  if form.groupbox_tools.Height >= form.groupbox_select_tool.Height then
    form.groupbox_tools.Top = 40
  else
    form.groupbox_tools.Top = 40
  end
  form.groupbox_select_tool.Height = form.groupbox_tools.Height + 90
  form.btn_select_tool_ok.Top = form.groupbox_tools.Top + form.groupbox_tools.Height + 15
  form.btn_select_tool_cancel.Top = form.groupbox_tools.Top + form.groupbox_tools.Height + 15
end
function show_domain_info(form, domain_info)
  if not nx_is_valid(form) then
    return
  end
  local weeks_list = form.groupbox_weeks:GetChildControlList()
  for i = 1, #weeks_list do
    local control = weeks_list[i]
    if nx_is_valid(control) then
      control.Visible = false
    end
  end
  local domain_tab = util_split_string(domain_info, ",")
  for i = 1, table.getn(domain_tab) - 1, 3 do
    local domain_id = nx_number(domain_tab[i])
    local guild_name = nx_widestr(domain_tab[i + 1])
    local weeks = nx_number(domain_tab[i + 2])
    if nx_string(guild_name) ~= nx_string("") then
      if not is_table_have(tab_guild_domain_link, "guild_name", guild_name) then
        local tab = {}
        tab.guild_name = nx_string(guild_name)
        tab.color = ""
        tab.link = {main = 0, sub = 0}
        tab.domain = {}
        table.insert(tab_guild_domain_link, tab)
      end
      local index = nx_number(get_table_index(tab_guild_domain_link, "guild_name", guild_name))
      if 0 < index then
        table.insert(tab_guild_domain_link[index].domain, domain_id)
        if is_main_domain(domain_id) then
          local color = tab_guild_domain_link[index].color
          if color == nil or nx_string(color) == nx_string("") then
            tab_guild_domain_link[index].color = tab_domain_color[domain_id]
          end
        end
      end
    end
    local btn_area = get_btn_area(form, domain_id)
    if nx_is_valid(btn_area) then
      btn_area.guild_name = guild_name
    end
    local lbl_guildname = "lbl_guildname_" .. nx_string(domain_id)
    local lbl_guild = form.groupbox_guildname:Find(lbl_guildname)
    if nx_is_valid(lbl_guild) then
      lbl_guild.Text = nx_widestr(util_text("ui_golbal_war_shp_013"))
      if guild_name ~= "" then
        lbl_guild.Text = nx_widestr(guild_name)
      end
    end
    local lbl_weeks_name = "lbl_weeks_" .. nx_string(domain_id)
    local lbl_weeks = form.groupbox_weeks:Find(lbl_weeks_name)
    if nx_is_valid(lbl_weeks) and 1 < weeks then
      lbl_weeks.Visible = true
      lbl_weeks.Text = nx_widestr(util_format_string("ui_cross_station_war_004", weeks))
    end
  end
end
function is_table_have(tab, prop, value)
  for i = 1, table.getn(tab) do
    if nx_string(prop) ~= nx_string("") then
      if nx_string(tab[i][prop]) == nx_string(value) then
        return true
      end
    elseif nx_string(tab[i]) == nx_string(value) then
      return true
    end
  end
  return false
end
function get_table_index(tab, prop, value)
  for i = 1, table.getn(tab) do
    if nx_string(prop) ~= nx_string("") then
      if nx_string(tab[i][prop]) == nx_string(value) then
        return i
      end
    elseif nx_string(tab[i]) == nx_string(value) then
      return i
    end
  end
  return 0
end
function is_main_domain(domain_id)
  if nx_int(domain_id) <= nx_int(0) then
    return false
  end
  for i = 0, table.getn(tab_main_domain_id) do
    if nx_int(domain_id) == nx_int(tab_main_domain_id[i]) then
      return true
    end
  end
  return false
end
function get_btn_area(form, domain_id)
  if not nx_is_valid(form) then
    return
  end
  local area_list = form.groupbox_area:GetChildControlList()
  for i = 1, #area_list do
    local control = area_list[i]
    if nx_is_valid(control) and nx_int(control.DataSource) == nx_int(domain_id) then
      return control
    end
  end
  return
end
function refresh_domain_color(form)
  if not nx_is_valid(form) then
    return
  end
  local area_list = form.groupbox_area:GetChildControlList()
  for i = 1, #area_list do
    local control = area_list[i]
    if nx_is_valid(control) and nx_find_custom(control, "guild_name") and nx_string(control.guild_name) ~= nx_string("") then
      local index = nx_number(get_table_index(tab_guild_domain_link, "guild_name", control.guild_name))
      if 0 < index then
        local color = tab_guild_domain_link[index].color
        if color == nil or nx_string(color) == nx_string("") then
          color = tab_domain_color[nx_number(control.DataSource)]
          tab_guild_domain_link[index].color = color
        end
        control.BlendColor = color
        control.FocusBlendColor = color
        control.PushBlendColor = color
        control.DisableBlendColor = color
        local area_id = string.sub(nx_string(control.Name), 10, -1)
        if control.BlendColor == "255,255,255,255" then
          control.NormalImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_out.png"
          control.FocusImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_on.png"
        else
          control.NormalImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_white_out.png"
          control.FocusImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_white_on.png"
        end
      end
    end
  end
end
function on_rbtn_select_tool_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.sel_chase_tool = rbtn.DataSource
    form.btn_select_tool_ok.Enabled = true
  end
end
function calc_diff_sec(time64)
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return 0
  end
  local cur_time = msg_delay:GetServerNowTime()
  local sec = (nx_int64(cur_time) - nx_int64(time64)) / 1000
  if sec < 0 then
    return 0
  end
  return sec
end
function format_days_text(seconds)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return gui
  end
  if nx_int(seconds) < nx_int(86400) then
    return gui.TextManager:GetFormatText("ui_newguild_today")
  end
  return gui.TextManager:GetFormatText("ui_newguild_days", nx_int(seconds / 86400))
end
function on_rbtn_cw_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_circle.Visible = true
    form.gb_cw_member.Visible = false
    form.gb_cw_his.Visible = false
    form.gb_cw_intro.Visible = false
    form.gb_gold_rank.Visible = false
    form.groupbox_desc.Visible = false
  end
end
function on_rbtn_cw_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_circle.Visible = false
    form.gb_cw_member.Visible = true
    form.gb_cw_his.Visible = false
    form.gb_cw_intro.Visible = false
    form.gb_gold_rank.Visible = false
    form.groupbox_desc.Visible = false
    custom_champion_war(106)
  end
end
function on_rbtn_cw_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_circle.Visible = false
    form.gb_cw_member.Visible = false
    form.gb_cw_his.Visible = true
    form.gb_cw_intro.Visible = false
    form.gb_gold_rank.Visible = false
    form.groupbox_desc.Visible = false
    custom_champion_war(107)
  end
end
function on_rbtn_cw_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_circle.Visible = false
    form.gb_cw_member.Visible = false
    form.gb_cw_his.Visible = false
    form.gb_cw_intro.Visible = true
    form.gb_gold_rank.Visible = false
    form.groupbox_desc.Visible = false
  end
end
function on_rbtn_cw_5_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_circle.Visible = false
    form.gb_cw_member.Visible = false
    form.gb_cw_his.Visible = false
    form.gb_cw_intro.Visible = false
    form.gb_gold_rank.Visible = true
    form.groupbox_desc.Visible = false
  end
end
function on_rbtn_cw_6_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_circle.Visible = false
    form.gb_cw_member.Visible = false
    form.gb_cw_his.Visible = false
    form.gb_cw_intro.Visible = false
    form.gb_gold_rank.Visible = false
    form.groupbox_desc.Visible = true
  end
end
function on_imagegrid_desc_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
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
function on_ig_price_mousein_grid(grid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local config = grid.config
  nx_execute("tips_game", "show_tips_by_config", nx_string(config), x, y, form)
end
function init_reward_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_1 = form.groupbox_10
  local gb_2 = form.groupbox_11
  local gb_3 = form.groupbox_12
  local gb_4 = form.groupbox_13
  for i = 1, 6 do
    local grid_name = "imagegrid_desc_" .. nx_string(i)
    local grid = gb_1:Find(nx_string(grid_name))
    if not nx_is_valid(grid) then
      return
    end
    local config_id = nx_string(grid.DataSource)
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
    grid:AddItem(0, nx_string(photo), nx_widestr(config_id), nx_int(1), nx_int(i - 1))
  end
  for i = 7, 15 do
    local grid_name = nx_string("imagegrid_desc_") .. nx_string(i)
    local grid = gb_2:Find(nx_string(grid_name))
    if not nx_is_valid(grid) then
      return
    end
    local config_id = nx_string(grid.DataSource)
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
    grid:AddItem(0, nx_string(photo), nx_widestr(config_id), nx_int(1), nx_int(i - 1))
  end
  for i = 16, 24 do
    local grid_name = nx_string("imagegrid_desc_") .. nx_string(i)
    local grid = gb_3:Find(nx_string(grid_name))
    if not nx_is_valid(grid) then
      return
    end
    local config_id = nx_string(grid.DataSource)
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
    grid:AddItem(0, nx_string(photo), nx_widestr(config_id), nx_int(1), nx_int(i - 1))
  end
  for i = 25, 27 do
    local grid_name = nx_string("imagegrid_desc_") .. nx_string(i)
    local grid = gb_4:Find(nx_string(grid_name))
    if not nx_is_valid(grid) then
      return
    end
    local config_id = nx_string(grid.DataSource)
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
    grid:AddItem(0, nx_string(photo), nx_widestr(config_id), nx_int(1), nx_int(i - 1))
  end
end
function on_rbtn_his_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_cw_his_guild.Visible = true
    form.gb_cw_his_member.Visible = false
  end
end
function on_rbtn_his_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_cw_his_guild.Visible = false
    form.gb_cw_his_member.Visible = true
  end
end
function on_btn_cw_refresh_click(btn)
  nx_execute("custom_sender", "custom_champion_war", 103)
  custom_sysinfo(0, 0, 0, 2, nx_string("sys_cw_030"))
end
function on_btn_team_apply_click(btn)
  local form = btn.ParentForm
  if form.rbtn_entrance_1.Checked and form.rbtn_entrance_1.Enabled then
    custom_champion_war(104, nx_string(form.rbtn_entrance_1.war_uid))
  elseif form.rbtn_entrance_2.Checked and form.rbtn_entrance_2.Enabled then
    custom_champion_war(104, nx_string(form.rbtn_entrance_2.war_uid))
  elseif form.rbtn_entrance_3.Checked and form.rbtn_entrance_3.Enabled then
    custom_champion_war(104, nx_string(form.rbtn_entrance_3.war_uid))
  else
    custom_sysinfo(0, 0, 0, 2, nx_string("sys_cw_018"))
  end
end
function on_btn_leader_apply_click(btn)
  local form = btn.ParentForm
  custom_champion_war(101)
end
function on_btn_power_set_click(btn)
  nx_execute("form_stage_main\\form_guild_battle\\form_guild_battle_power", "open_form")
end
function init_cw(form)
  load_cw_ini()
  form.rbtn_entrance_1.Enabled = false
  form.rbtn_entrance_2.Enabled = false
  form.rbtn_entrance_3.Enabled = false
  form.rbtn_his_1.Checked = true
  form.rbtn_cw_1.Enabled = false
  form.rbtn_cw_2.Enabled = false
  form.rbtn_cw_4.Checked = true
  form.rbtn_cw_5.Enabled = false
  form.gb_cw_today.Visible = false
  nx_execute("custom_sender", "custom_champion_war", 103)
  form.tg_cw_member:SetColTitle(0, nx_widestr(util_text("ui_tg_cw_1")))
  form.tg_cw_member:SetColTitle(1, nx_widestr(util_text("ui_tg_cw_2")))
  form.tg_cw_member:SetColTitle(2, nx_widestr(util_text("ui_tg_cw_3")))
  form.tg_cw_member:SetColTitle(3, nx_widestr(util_text("ui_tg_cw_4")))
  form.tg_cw_member:SetColTitle(4, nx_widestr(util_text("ui_tg_cw_5")))
  form.tg_cw_member:SetColTitle(5, nx_widestr(util_text("ui_tg_cw_6")))
  form.tg_cw_member:SetColTitle(6, nx_widestr(util_text("ui_tg_cw_7")))
  form.tg_cw_member:SetColTitle(7, nx_widestr(util_text("ui_tg_cw_8")))
  form.textgrid_gold_rank:SetColTitle(0, nx_widestr(util_text("ui_guild_battle_form_shp_066")))
  form.textgrid_gold_rank:SetColTitle(1, nx_widestr(util_text("ui_guild_battle_form_shp_067")))
  form.textgrid_gold_rank:SetColTitle(2, nx_widestr(util_text("ui_guild_battle_form_shp_068")))
  form.textgrid_gold_rank:SetColTitle(3, nx_widestr(util_text("ui_guild_battle_form_shp_069")))
end
function stage_test()
  on_cw_circle_stage(33333, 2, 4, "\176\239\187\225A", 7100066, 2500, 1, "\176\239\187\225B", 7100066, 2400, 2, "\176\239\187\225C", 7100066, 2600, 3, "\176\239\187\225D", 7100066, 2700, 4)
end
function info_test()
  on_cw_circle_info(2000, 1, 3, 40, 5, 3, "abc", 1, "abcd", 101, "abcd", 102)
end
function today_test()
  on_cw_today_res(1.111, nx_widestr("4,3,\176\239\187\2251,7100066,2500,11,0.555,100,4,\176\239\187\2252,7100066,2500,2,0.555,-100,1,\176\239\187\2253,7100066,2500,21,0.555,300,2,\176\239\187\2254,7100066,2500,15,0.555,200,"))
end
function member_test()
  on_cw_member_info(3, nx_widestr("\213\197\200\253;1;122;2;4;1,0,1;3000;3;50"), nx_widestr("\192\238\203\196;2;122;2;4;1;3000;3;50"), nx_widestr("\205\245\206\229;3;122;2;4;1,1,0;3000;3;50"))
end
function member_his_test()
  on_cw_member_his(3, nx_widestr("0;\213\197\200\253;1;1"), nx_widestr("0;\213\197\200\253,\192\238\203\196;101;0"), nx_widestr("0;\213\197\200\253,\192\238\203\196,\205\245\206\229;102;1"))
end
function guild_his_test()
  on_cw_guild_his(3, nx_string("0.0,1,13,100"), nx_string("0.0,1,13,100"), nx_string("0.0,1,13,100"))
end
function player_info_test()
  on_cw_player_info(1, 4, 3, 200, 1, 55)
end
function gold_rank()
  on_cw_gold_rank(nx_widestr("\210\187,\183\254\206\241\210\187,3000"), nx_widestr("\182\254,\183\254\206\241\182\254,3000"), nx_widestr("\200\253,\183\254\206\241\200\253,3000"), nx_widestr("\203\196,\183\254\206\241\203\196,3000"))
end
function on_apply_ok()
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_cw_apply.Text = nx_widestr(util_text("ui_cw_apply_" .. nx_string(1)))
end
function on_cw_circle_stage(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  local season_next = nx_double(arg[1])
  local time_text = get_time_text(season_next)
  form.lbl_season_next.Text = nx_widestr(time_text)
  local stage = nx_number(arg[2])
  form.lbl_cw_stage.Text = nx_widestr(get_stage_text(stage))
  form.lbl_cw_stage.stage = stage
  if stage == 0 then
    form.btn_leader_apply.Enabled = true
  else
    form.btn_leader_apply.Enabled = false
  end
  if stage == 1 or stage == 2 then
    form.lbl_black.Visible = false
    form.lbl_lock.Visible = false
    form.rbtn_cw_1.Enabled = true
    form.rbtn_cw_2.Enabled = true
    form.rbtn_cw_1.Checked = true
    local rows = nx_number(arg[3])
    if 0 == rows then
      form.rbtn_cw_1.Enabled = false
      form.rbtn_cw_2.Enabled = false
      form.rbtn_cw_4.Checked = true
    end
    form.gsb_cw_circle.IsEditMode = true
    form.gsb_cw_circle:DeleteAll()
    for i = 1, rows do
      local guild_name = nx_widestr(arg[(i - 1) * 4 + 4])
      local server_name = nx_widestr(arg[(i - 1) * 4 + 5])
      local score = nx_int(arg[(i - 1) * 4 + 6])
      local wins = nx_int(arg[(i - 1) * 4 + 7])
      local gb = create_ctrl("GroupBox", "gb_cw_1_" .. nx_string(i), form.gb_mod_cw_1, form.gsb_cw_circle)
      if nx_is_valid(gb) then
        create_ctrl("Label", "lbl_59_" .. nx_string(i), form.lbl_59, gb)
        create_ctrl("Label", "lbl_34_" .. nx_string(i), form.lbl_34, gb)
        create_ctrl("Label", "lbl_35_" .. nx_string(i), form.lbl_35, gb)
        create_ctrl("Label", "lbl_36_" .. nx_string(i), form.lbl_36, gb)
        create_ctrl("Label", "lbl_37_" .. nx_string(i), form.lbl_37, gb)
        local lbl_name = create_ctrl("Label", "lbl_1_name_" .. nx_string(i), form.lbl_cw_1_name, gb)
        local lbl_server = create_ctrl("Label", "lbl_1_server_id_" .. nx_string(i), form.lbl_cw_1_server_id, gb)
        local lbl_score = create_ctrl("Label", "lbl_1_score_" .. nx_string(i), form.lbl_cw_1_score, gb)
        local lbl_wins = create_ctrl("Label", "lbl_1_wins_" .. nx_string(i), form.lbl_cw_1_wins, gb)
        lbl_name.Text = nx_widestr(guild_name)
        lbl_server.Text = nx_widestr(server_name)
        lbl_score.Text = nx_widestr(score)
        lbl_wins.Text = nx_widestr(wins)
        gb.Left = 0
      end
    end
    form.gsb_cw_circle.IsEditMode = false
    form.gsb_cw_circle:ResetChildrenYPos()
  elseif form.gb_cw_today.Visible == true then
    form.lbl_black.Visible = true
    form.lbl_lock.Visible = false
    form.rbtn_cw_1.Checked = true
  else
    form.lbl_black.Visible = true
    form.lbl_lock.Visible = true
    form.rbtn_cw_1.Enabled = false
    form.rbtn_cw_2.Enabled = false
    form.rbtn_cw_4.Checked = true
  end
  modify_act(form)
end
function on_cw_circle_info(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  local score = nx_int(arg[1])
  local apply = nx_int(arg[2])
  local alloc = nx_int(arg[3])
  local total = nx_int(arg[4])
  local wins = nx_int(arg[5])
  local war_score = nx_int(arg[6])
  form.lbl_cw_score.Text = nx_widestr(score)
  form.lbl_cw_alloc.Text = nx_widestr(alloc)
  form.lbl_cw_total.Text = nx_widestr(total)
  form.lbl_cw_war_score.Text = nx_widestr(war_score)
  form.lbl_cw_duanwei.BackImage = nx_string(get_level_image(score))
  form.lbl_season_score.Text = nx_widestr(score)
  form.lbl_season_level.BackImage = nx_string(get_level_image(score))
  form.lbl_liangji.Text = nx_widestr(util_text(get_level_tiliang(war_score)))
  form.lbl_cw_apply.Text = nx_widestr(util_text("ui_cw_apply_" .. nx_string(apply)))
  form.lbl_cw_apply.apply = apply
  form.rbtn_entrance_1.Enabled = false
  form.rbtn_entrance_2.Enabled = false
  form.rbtn_entrance_3.Enabled = false
  local entrance_nums = nx_number(arg[7])
  for i = 1, entrance_nums do
    local rbtn_entrance = form.gb_entrance:Find("rbtn_entrance_" .. nx_string(i))
    if nx_is_valid(rbtn_entrance) then
      local war_uid = nx_string(arg[8 + (i - 1) * 2])
      local war_type = nx_string(arg[9 + (i - 1) * 2])
      if war_uid == "nil" then
        return
      end
      rbtn_entrance.NormalImage = nx_string("gui\\guild\\guildwar_new\\entrance_" .. nx_string(war_type) .. ".png")
      rbtn_entrance.FocusImage = nx_string("gui\\guild\\guildwar_new\\entrance_" .. nx_string(war_type) .. "_focus.png")
      rbtn_entrance.CheckedImage = nx_string("gui\\guild\\guildwar_new\\entrance_" .. nx_string(war_type) .. "_checked.png")
      rbtn_entrance.HintText = nx_widestr(util_text("tips_cw_entrace_" .. nx_string(war_type)))
      rbtn_entrance.war_uid = war_uid
      rbtn_entrance.Enabled = true
    end
  end
end
function on_cw_today_res(war_time, war_res)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_black.Visible = true
  form.lbl_lock.Visible = false
  form.gb_cw_today.Visible = true
  form.rbtn_cw_1.Enabled = true
  form.rbtn_cw_2.Enacled = false
  local var = util_split_wstring(war_res, ",")
  local guild_nums = nx_number(var[1])
  local tab = {}
  for i = 1, guild_nums do
    local rank_no = nx_number(var[(i - 1) * 7 + 2])
    local name = nx_widestr(var[(i - 1) * 7 + 3])
    local server = nx_widestr(var[(i - 1) * 7 + 4])
    local score = nx_number(var[(i - 1) * 7 + 5])
    local wins = nx_number(var[(i - 1) * 7 + 6])
    local win_time = nx_number(var[(i - 1) * 7 + 7])
    local score_dif = nx_number(var[(i - 1) * 7 + 8])
    table.insert(tab, {
      rank_no,
      name,
      server,
      score,
      wins,
      win_time,
      score_dif
    })
  end
  table.sort(tab, function(a, b)
    return a[1] < b[1]
  end)
  form.gsb_cw_today.IsEditMode = true
  form.gsb_cw_today:DeleteAll()
  for i = 1, table.getn(tab) do
    local rank_no = tab[i][1]
    local name = tab[i][2]
    local server = tab[i][3]
    local score = tab[i][4]
    local wins = tab[i][5]
    local win_time = tab[i][6]
    local score_dif = tab[i][7]
    local gb = create_ctrl("GroupBox", "gb_cw_2_" .. nx_string(i), form.gb_mod_cw_2, form.gsb_cw_today)
    if nx_is_valid(gb) then
      local lbl_back = create_ctrl("Label", "lbl_2_back_" .. nx_string(i), form.lbl_cw_2_back, gb)
      local lbl_rank = create_ctrl("Label", "lbl_2_rank_" .. nx_string(i), form.lbl_cw_2_rank, gb)
      local lbl_name = create_ctrl("Label", "lbl_2_name_" .. nx_string(i), form.lbl_cw_2_name, gb)
      local lbl_server = create_ctrl("Label", "lbl_2_server_id_" .. nx_string(i), form.lbl_cw_2_server_id, gb)
      local lbl_score = create_ctrl("Label", "lbl_2_score_" .. nx_string(i), form.lbl_cw_2_score, gb)
      local lbl_wins = create_ctrl("Label", "lbl_2_wins_" .. nx_string(i), form.lbl_cw_2_wins, gb)
      local lbl_score_dif = create_ctrl("Label", "lbl_2_score_dif_" .. nx_string(i), form.lbl_cw_2_score_dif, gb)
      if nx_widestr(name) == get_player_guild_name() then
        lbl_back.Visible = true
      else
        lbl_back.Visible = false
      end
      lbl_rank.Text = nx_widestr(rank_no + 1)
      lbl_name.Text = nx_widestr(name)
      lbl_server.Text = nx_widestr(server)
      lbl_score.Text = nx_widestr(score)
      lbl_wins.Text = nx_widestr(wins)
      lbl_score_dif.Text = nx_widestr(score_dif)
      gb.Left = 0
    end
  end
  form.gsb_cw_today.IsEditMode = false
  form.gsb_cw_today:ResetChildrenYPos()
end
function on_cw_member_info(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  local arg_nums = nx_number(arg[1])
  form.tg_cw_member:ClearRow()
  for i = 1, arg_nums do
    local member_info = arg[i + 1]
    local player_info = util_split_wstring(member_info, ";")
    local name = nx_widestr(player_info[1])
    local pos = nx_number(player_info[2])
    local level_title = nx_string(player_info[3])
    local apply_nums = nx_number(player_info[4])
    local total_nums = nx_number(player_info[5])
    local war_res = nx_string(player_info[6])
    local power_param1 = nx_number(player_info[7])
    local balance_param1 = nx_number(player_info[8])
    local balance_rate = nx_number(player_info[9])
    local str_war_res = nx_widestr("")
    local tab_war_res = util_split_string(war_res, ",")
    for i = 1, table.getn(tab_war_res) do
      local res = tab_war_res[i]
      if res == "" then
        res = "0"
      end
      str_war_res = str_war_res .. nx_widestr(util_text("ui_cw_war_res_" .. nx_string(res)))
    end
    apply_nums = table.getn(tab_war_res)
    if 0 < apply_nums then
      local row = form.tg_cw_member:InsertRow(-1)
      form.tg_cw_member:SetGridText(row, 0, name)
      form.tg_cw_member:SetGridText(row, 1, nx_widestr(util_text(get_pos_name(pos))))
      form.tg_cw_member:SetGridText(row, 2, nx_widestr(util_text("desc_" .. level_title)))
      form.tg_cw_member:SetGridText(row, 3, nx_widestr(nx_string(apply_nums) .. "/" .. nx_string(total_nums)))
      form.tg_cw_member:SetGridText(row, 4, str_war_res)
      form.tg_cw_member:SetGridText(row, 5, nx_widestr(power_param1))
      form.tg_cw_member:SetGridText(row, 6, nx_widestr(balance_param1))
      form.tg_cw_member:SetGridText(row, 7, nx_widestr(balance_rate))
      if get_player_name() == name then
        form.tg_cw_member:SetGridForeColor(row, 0, "255,255,204,0")
        form.tg_cw_member:SetGridForeColor(row, 1, "255,255,204,0")
        form.tg_cw_member:SetGridForeColor(row, 2, "255,255,204,0")
        form.tg_cw_member:SetGridForeColor(row, 3, "255,255,204,0")
        form.tg_cw_member:SetGridForeColor(row, 4, "255,255,204,0")
        form.tg_cw_member:SetGridForeColor(row, 5, "255,255,204,0")
        form.tg_cw_member:SetGridForeColor(row, 6, "255,255,204,0")
        form.tg_cw_member:SetGridForeColor(row, 7, "255,255,204,0")
      end
    end
  end
end
function on_cw_member_his(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  local rows = nx_number(arg[1])
  form.mltbox_cw_member:Clear()
  for i = 1, rows do
    local member_his = nx_widestr(arg[i + 1])
    local tab_member_his = util_split_wstring(member_his, ";")
    local time = nx_double(tab_member_his[1])
    local team_info = nx_widestr(tab_member_his[2])
    local war_type = nx_number(tab_member_his[3])
    local win = nx_number(tab_member_his[4])
    local time_text = get_time_text(time)
    local type_text = get_type_text(war_type)
    local tab_team = util_split_wstring(team_info, ",")
    local text
    if table.getn(tab_team) == 1 then
      text = util_format_string("ui_member_event_1_" .. nx_string(win), time_text, tab_team[1], type_text)
    elseif table.getn(tab_team) == 2 then
      text = util_format_string("ui_member_event_2_" .. nx_string(win), time_text, tab_team[1], tab_team[2], type_text)
    elseif table.getn(tab_team) == 3 then
      text = util_format_string("ui_member_event_3_" .. nx_string(win), time_text, tab_team[1], tab_team[2], tab_team[3], type_text)
    end
    form.mltbox_cw_member:AddHtmlText(nx_widestr(text), -1)
  end
end
function on_cw_guild_his(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  local rows = nx_number(arg[1])
  form.mltbox_cw_guild:Clear()
  for i = 1, rows do
    local guild_his = nx_string(arg[i + 1])
    local tab_guild_his = util_split_string(guild_his, ",")
    local time = nx_double(tab_guild_his[1])
    local rank_no = nx_number(tab_guild_his[2]) + 1
    local wins = nx_number(tab_guild_his[3])
    local score_dif = nx_number(tab_guild_his[4])
    local time_text = get_time_text(time)
    local text
    if 0 <= score_dif then
      text = util_format_string("ui_guild_event_1", time_text, rank_no, wins, score_dif)
    else
      text = util_format_string("ui_guild_event_0", time_text, rank_no, wins, score_dif)
    end
    form.mltbox_cw_guild:AddHtmlText(nx_widestr(text), -1)
  end
end
function on_cw_player_info(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_cw_my_joins.Text = nx_widestr(arg[1])
  form.lbl_cw_my_total.Text = nx_widestr(arg[2])
  form.lbl_cw_my_joins_his.Text = nx_widestr(arg[3])
  form.lbl_cw_my_score.Text = nx_widestr(arg[4])
  form.lbl_cw_my_wins.Text = nx_widestr(arg[5])
  form.lbl_cw_my_rate.Text = nx_widestr(arg[6])
  modify_act(form)
end
function on_cw_gold_rank(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  if 0 < count then
    form.rbtn_cw_5.Enabled = true
  end
  form.textgrid_gold_rank:ClearRow()
  for i = 1, count do
    local info = arg[i]
    local tab_info = util_split_wstring(info, ",")
    local guild = nx_widestr(tab_info[1])
    local server = nx_widestr(tab_info[2])
    local score = nx_number(tab_info[3])
    local row = form.textgrid_gold_rank:InsertRow(-1)
    form.textgrid_gold_rank:SetGridText(row, 0, nx_widestr(i))
    form.textgrid_gold_rank:SetGridText(row, 1, nx_widestr(guild))
    form.textgrid_gold_rank:SetGridText(row, 2, nx_widestr(server))
    form.textgrid_gold_rank:SetGridText(row, 3, nx_widestr(score))
    if get_player_guild_name() == guild then
      form.textgrid_gold_rank:SetGridForeColor(row, 0, "255,255,204,0")
      form.textgrid_gold_rank:SetGridForeColor(row, 1, "255,255,204,0")
      form.textgrid_gold_rank:SetGridForeColor(row, 2, "255,255,204,0")
      form.textgrid_gold_rank:SetGridForeColor(row, 3, "255,255,204,0")
    end
  end
end
function modify_act(form)
  local score = nx_number(form.lbl_cw_score.Text)
  local level_text = util_text(get_level_text(score))
  local apply = 0
  if nx_find_custom(form.lbl_cw_apply, "apply") then
    apply = form.lbl_cw_apply.apply
  end
  local stage = 0
  if nx_find_custom(form.lbl_cw_stage, "stage") then
    stage = form.lbl_cw_stage.stage
  end
  local joins = nx_number(form.lbl_cw_my_joins.Text)
  local total = nx_number(form.lbl_cw_my_total.Text)
  local desc_text = nx_widestr(util_format_string("ui_cw_desc_001", score, level_text, joins, total))
  if apply == 1 and stage == 1 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_intro", "modify_act_state", 10, desc_text, true, true)
  else
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_intro", "modify_act_state", 10, desc_text, true, false)
  end
end
function get_type_text(war_type)
  return nx_widestr(util_text("ui_cw_war_type_" .. nx_string(war_type)))
end
function get_time_text(time)
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", time)
  local time_text = string.format("%04d-%02d-%02d %02d:%02d", nx_number(year), nx_number(month), nx_number(day), nx_number(hour), nx_number(mins))
  return time_text
end
function get_stage_text(stage)
  return util_text("ui_cw_stage_" .. nx_string(stage))
end
function get_pos_name(pos_level)
  return "ui_guild_pos_level" .. nx_string(pos_level) .. "_name"
end
function get_level(score)
  for i = 1, table.getn(tab_cw_level) do
    if nx_number(score) >= nx_number(tab_cw_level[i].score_min) and nx_number(score) <= nx_number(tab_cw_level[i].score_max) then
      return i
    end
  end
  return nil
end
function get_level_text(score)
  local level = get_level(score)
  if level == nil then
    return nil
  end
  return tab_cw_level[level].text
end
function get_level_image(score)
  local level = get_level(score)
  if level == nil then
    return nil
  end
  return tab_cw_level[level].image
end
function get_level_tiliang(score)
  local level = get_level(score)
  if level == nil then
    return nil
  end
  return tab_cw_level[level].tiliang
end
function load_cw_ini()
  local ini = nx_execute("util_functions", "get_ini", "share\\ChampionWar\\ChampionWarLevel.ini")
  if not nx_is_valid(ini) then
    return
  end
  tab_cw_level = {}
  local sec_count = ini:GetSectionCount()
  for i = 1, nx_number(sec_count) do
    local sec_index = i - 1
    local sec = nx_number(ini:GetSectionByIndex(sec_index))
    local score_min = nx_number(ini:ReadInteger(sec_index, "score_min", 0))
    local score_max = nx_number(ini:ReadInteger(sec_index, "score_max", 0))
    local text = ini:ReadString(sec_index, "text", "")
    local image = ini:ReadString(sec_index, "image", "")
    local tiliang = ini:ReadString(sec_index, "tiliang", "")
    local tab = {}
    tab.score_min = score_min
    tab.score_max = score_max
    tab.text = text
    tab.image = image
    tab.tiliang = tiliang
    table.insert(tab_cw_level, sec, tab)
  end
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
function init_lm(form)
  form.tg_lm_rank:SetColTitle(0, nx_widestr(util_text("ui_lm_rank_001")))
  form.tg_lm_rank:SetColTitle(1, nx_widestr(util_text("ui_lm_rank_002")))
  form.tg_lm_rank:SetColTitle(2, nx_widestr(util_text("ui_lm_rank_003")))
  form.tg_lm_rank:SetColTitle(3, nx_widestr(util_text("ui_lm_rank_004")))
  form.tg_lm_rank:SetColTitle(4, nx_widestr(util_text("ui_lm_rank_005")))
  custom_league_matches(7)
  custom_league_matches(8)
  form.rbtn_lm_1.Checked = true
end
function on_lm_apply(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_lm_apply.Text = nx_widestr(util_text("ui_lm_apply_1"))
  form.btn_lm_apply.Enabled = false
end
function on_lm_guild(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
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
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  local season_no = nx_number(arg[1])
  local season_begin = nx_double(arg[2])
  local season_end = nx_double(arg[3])
  local stage = nx_number(arg[4])
  local stage_more = nx_number(arg[5])
  local stage_text = util_text("ui_lm_stage_" .. nx_string(stage))
  local stage_more_text
  if 0 == stage or 1 == stage or 4 == stage then
    stage_more_text = util_text("ui_lm_stage_beizhan_" .. nx_string(stage_more))
  else
    stage_more_text = util_text("ui_lm_stage_more_" .. nx_string(stage))
  end
  form.lbl_lm_season_no.Text = nx_widestr(season_no + 1)
  form.lbl_lm_season_begin.Text = nx_widestr(get_time_text(season_begin))
  form.lbl_lm_season_end.Text = nx_widestr(get_time_text(season_end))
  form.lbl_lm_stage.Text = nx_widestr(stage_text)
  form.lbl_lm_stage_more.Text = nx_widestr(stage_more_text)
end
function on_lm_group(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
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
  elseif guild_win_1 ~= nx_widestr("") and guild_win_1 ~= nx_widestr("@") and guild_4 == guild_win_1 then
    war_res_1 = -1
    form.lbl_lm_res_1_1.Visible = true
    form.lbl_lm_res_1_2.Visible = true
    form.lbl_lm_res_1_1.BackImage = "gui\\commom_new\\icon\\lose.png"
    form.lbl_lm_res_1_2.BackImage = "gui\\commom_new\\icon\\win.png"
  end
  if guild_win_2 ~= nx_widestr("") and guild_win_2 ~= nx_widestr("@") and guild_2 == guild_win_2 then
    war_res_2 = 1
    form.lbl_lm_res_2_1.Visible = true
    form.lbl_lm_res_2_2.Visible = true
    form.lbl_lm_res_2_1.BackImage = "gui\\commom_new\\icon\\win.png"
    form.lbl_lm_res_2_2.BackImage = "gui\\commom_new\\icon\\lose.png"
  elseif guild_win_2 ~= nx_widestr("") and guild_win_2 ~= nx_widestr("@") and guild_3 == guild_win_2 then
    war_res_2 = -1
    form.lbl_lm_res_2_1.Visible = true
    form.lbl_lm_res_2_2.Visible = true
    form.lbl_lm_res_2_1.BackImage = "gui\\commom_new\\icon\\lose.png"
    form.lbl_lm_res_2_2.BackImage = "gui\\commom_new\\icon\\win.png"
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
  form.lbl_lm_war_1_1.Text = get_guild_wstr(guild_1, war_res_1)
  form.lbl_lm_war_1_2.Text = get_guild_wstr(guild_4, -war_res_1)
  form.lbl_lm_war_2_1.Text = get_guild_wstr(guild_2, war_res_2)
  form.lbl_lm_war_2_2.Text = get_guild_wstr(guild_3, -war_res_2)
  form.lbl_lm_war_3_1.Text = get_guild_wstr(guild_win_1, war_res_3)
  form.lbl_lm_war_3_2.Text = get_guild_wstr(guild_win_2, -war_res_3)
  form.lbl_lm_war_4_1.Text = get_guild_wstr(guild_lose_1, war_res_4)
  form.lbl_lm_war_4_2.Text = get_guild_wstr(guild_lose_2, -war_res_4)
end
function on_lm_rank(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
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
  local form = util_get_form(FORM_GUILD_WAR, false)
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
      lbl_server.Text = server
      lbl_kill.Text = nx_widestr(kill)
      lbl_wins.Text = nx_widestr(tab_wins[i])
      ig_price.config = tab_price[i]
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", tab_price[i], "Photo")
      ig_price:AddItem(0, nx_string(photo), nx_widestr(tab_price[i]), nx_int(1), nx_int(i - 1))
    end
  end
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
  end
end
function on_rbtn_lm_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = false
    form.gb_lm_2.Visible = true
    form.gb_lm_3.Visible = false
    form.gb_lm_4.Visible = false
  end
end
function on_rbtn_lm_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = false
    form.gb_lm_2.Visible = false
    form.gb_lm_3.Visible = true
    form.gb_lm_4.Visible = false
  end
end
function on_rbtn_lm_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_lm_1.Visible = false
    form.gb_lm_2.Visible = false
    form.gb_lm_3.Visible = false
    form.gb_lm_4.Visible = true
  end
end
function init_chase_avenge(form)
  form.btn_avenge.Enabled = false
  form.rbtn_chase_1.Checked = true
  nx_execute("custom_sender", "custom_guild_list", nx_int(SUB_CUSTOMMSG_GET_AVENGE_LIST))
end
function on_avenge_info(...)
  local form = util_get_form(FORM_GUILD_WAR, false)
  if not nx_is_valid(form) then
    return
  end
  local rows = nx_number(arg[1])
  form.tg_avenge:BeginUpdate()
  form.tg_avenge:ClearRow()
  for i = 1, rows do
    local wstr_guild_info = nx_widestr(arg[1 + i])
    local guild_info = util_split_wstring(wstr_guild_info, ",")
    local guild = nx_widestr(guild_info[1])
    local guild_level = nx_number(guild_info[2])
    local member_nums = nx_number(guild_info[3])
    local left_sec = nx_number(guild_info[4])
    local chase_time = nx_number(guild_info[5])
    local row = form.tg_avenge:InsertRow(-1)
    form.tg_avenge:SetGridText(row, 0, nx_widestr(guild))
    form.tg_avenge:SetGridText(row, 1, nx_widestr(guild_level))
    form.tg_avenge:SetGridText(row, 2, nx_widestr(member_nums))
    form.tg_avenge:SetGridText(row, 3, nx_widestr(get_avenge_left_time_text(left_sec)))
    form.tg_avenge:SetGridText(row, 4, nx_widestr(get_avenge_chase_time_text(chase_time * 3600)))
  end
  form.tg_avenge:EndUpdate()
  local timer = nx_value("timer_game")
  if 0 < rows then
    timer:UnRegister(nx_current(), "on_update_avenge_timer", form)
    timer:Register(1000, -1, nx_current(), "on_update_avenge_timer", form, -1, -1)
  else
    timer:UnRegister(nx_current(), "on_update_avenge_timer", form)
  end
end
function on_update_avenge_timer(form)
  form.tg_avenge:BeginUpdate()
  local rows = form.tg_avenge.RowCount
  for i = 1, rows do
    local left_sec_text = form.tg_avenge:GetGridText(i - 1, 3)
    local left_sec_info = util_split_wstring(left_sec_text, ":")
    local hour = nx_number(left_sec_info[1])
    local minute = nx_number(left_sec_info[2])
    local second = nx_number(left_sec_info[3])
    local left_sec = hour * 3600 + minute * 60 + second
    if 0 < left_sec then
      left_sec = left_sec - 1
    end
    form.tg_avenge:SetGridText(i - 1, 3, nx_widestr(get_avenge_left_time_text(left_sec)))
  end
  form.tg_avenge:EndUpdate()
end
function get_avenge_left_time_text(left_sec)
  local hour = math.floor(left_sec / 3600)
  local minute = math.floor(math.mod(left_sec, 3600) / 60)
  local second = math.mod(math.mod(left_sec, 3600), 60)
  return string.format("%02d:%02d:%02d", hour, minute, second)
end
function get_avenge_chase_time_text(chase_time)
  local hour = math.floor(chase_time / 3600)
  local minute = math.floor(math.mod(chase_time, 3600) / 60)
  local second = math.mod(math.mod(chase_time, 3600), 60)
  return string.format("%02d:%02d:%02d", hour, minute, second)
end
function on_rbtn_chase_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_chase_1.Visible = true
    form.gb_chase_2.Visible = false
  end
end
function on_rbtn_chase_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_chase_1.Visible = false
    form.gb_chase_2.Visible = true
  end
end
function on_tg_avenge_select_row(tg, row)
  local form = tg.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.btn_avenge.avenge_guild = nx_widestr(tg:GetGridText(row, 0))
  form.btn_avenge.sl_row = row
  form.btn_avenge.Enabled = true
end
function on_btn_avenge_refresh_click(btn)
  nx_execute("custom_sender", "custom_guild_list", nx_int(SUB_CUSTOMMSG_GET_AVENGE_LIST))
end
function on_btn_avenge_click(btn)
  local target_guild = btn.avenge_guild
  local row = btn.sl_row
  nx_execute("custom_sender", "custom_guild_list", nx_int(SUB_CUSTOMMSG_CHASE_AVENGE), nx_widestr(target_guild), nx_int(row))
  btn.Enabled = false
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_delay_get_avenge_list_timer", btn.ParentForm)
  timer:Register(1000, 1, nx_current(), "on_delay_get_avenge_list_timer", btn.ParentForm, -1, -1)
end
function on_delay_get_avenge_list_timer(form)
  nx_execute("custom_sender", "custom_guild_list", nx_int(SUB_CUSTOMMSG_GET_AVENGE_LIST))
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
