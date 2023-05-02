require("util_gui")
require("util_functions")
local guild_domain_table = {
  [1] = 101,
  [2] = 103,
  [3] = 201,
  [4] = 202,
  [5] = 301,
  [6] = 302,
  [7] = 401,
  [8] = 402,
  [9] = 501,
  [10] = 503,
  [11] = 601,
  [12] = 602,
  [13] = 701,
  [14] = 703,
  [15] = 801,
  [16] = 803,
  [17] = 902,
  [18] = 903,
  [19] = 1001,
  [20] = 1003,
  [21] = 1101,
  [22] = 1102,
  [23] = 1202,
  [24] = 1203,
  [25] = 1301,
  [26] = 1304,
  [27] = 1401,
  [28] = 1404,
  [29] = 1602,
  [30] = 1603,
  [31] = 1701,
  [32] = 1703
}
local stage_table = {
  [1] = "ui_cf_nothing",
  [2] = "ui_cf_voting",
  [3] = "ui_cf_non_active",
  [4] = "ui_cf_pre_active",
  [5] = "ui_cf_is_active",
  [6] = "ui_cf_cancelled"
}
local danger_desc_table = {
  [1] = "ui_cf_beyond_danger",
  [2] = "ui_cf_hellish",
  [3] = "ui_cf_warning",
  [4] = "ui_cf_good"
}
local warning_desc_table = {
  [1] = "ui_cf_guilty",
  [2] = "ui_cf_stay_check"
}
local all_grid_col_table = {
  [1] = {
    percent = 2,
    text = "ui_cf_domian"
  },
  [2] = {percent = 4, text = "ui_GongHui"},
  [3] = {percent = 2, text = "ui_cj"},
  [4] = {
    percent = 3,
    text = "ui_cf_vote_count"
  },
  [5] = {percent = 1, text = " "},
  [6] = {
    percent = 3,
    text = "ui_cf_danger_lvl"
  }
}
local voter_grid_col_table = {
  [1] = {
    percent = 5,
    text = "ui_cf_vote_guild"
  },
  [2] = {
    percent = 5,
    text = "ui_domain_level"
  },
  [3] = {
    percent = 5,
    text = "ui_cf_vote_count"
  }
}
local strike_target_col_table = {
  [1] = {
    percent = 3,
    text = "ui_guild_domain"
  },
  [2] = {
    percent = 3,
    text = "ui_search_by_name"
  },
  [3] = {percent = 3, text = "ui_cj"},
  [4] = {
    percent = 3,
    text = "ui_rank_4_gx"
  },
  [5] = {percent = 3, text = "ui_status"}
}
local all_grid_col_base = 15
local FORM_COURTFIRE_INFO = "form_stage_main\\form_guild_fire\\form_courtfire_info"
local CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK = 1023
local GUILD_FIRE_TASK_SUB_CMD_ENEMY_GUILD_WITH_DOMAIN = 7
local GUILD_FIRE_TASK_SUB_CMD_ADD_STRIKE_TARGET = 10
local GUILD_FIRE_TASK_SUB_CMD_DEL_STRIKE_TARGET = 11
local GUILD_FIRE_SUB_CMD_CF_VOTE = 20
local GUILD_FIRE_SUB_CMD_CF_ALL_GUILD_DOMAIN = 21
local GUILD_FIRE_SUB_CMD_CF_SELF = 22
local GUILD_FIRE_SUB_CMD_CF_GET_VOTER = 23
local GUILD_FIRE_SUB_CMD_CF_GET_STAGE = 24
local GUILD_RELATION_NOTHING = 0
local GUILD_RELATION_ENEMY = 1
local GUILD_RELATION_LEAGUE = 2
local INFO_LENGTH = 5
local IS_NOT_STRIKE_TARGET = 0
local IS_STRIKE_TARGET = 1
function main_form_init(form)
  form.Fixed = true
  nx_set_value(FORM_COURTFIRE_INFO, form)
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.groupbox_info.Visible = false
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = true
  form.btn_getvoter.Enabled = false
  form.stage_index = 1
  form.btn_index = 0
  form.domain_vote_num = 0
  form.chose_domain = 0
  request_enemy_guild_with_domain()
  request_stage_info()
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  clear_grid_control()
  nx_destroy(form)
  nx_set_value(FORM_COURTFIRE_INFO, nx_null())
end
function on_main_form_shut(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  clear_grid_control()
  nx_destroy(form)
  nx_set_value(FORM_COURTFIRE_INFO, nx_null())
end
function on_btn_getall_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
  form.btn_getvoter.Enabled = false
  if nx_int(form.btn_index) == nx_int(1) then
    return
  end
  form.groupbox_1.Visible = true
  request_guilddomain_info()
  refresh_grid_col(all_grid_col_table)
  form.domain_vote_num = 0
  form.lbl_guild_domain.Text = nx_widestr("")
  form.btn_index = 1
end
function on_btn_getvoter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
  if nx_int(form.btn_index) == nx_int(2) then
    return
  end
  if nx_int(form.domain_vote_num) == nx_int(0) then
    return
  end
  local chose_domain_name = form.lbl_guild_domain.Text
  local chose_domain_id = get_domain_id_by_name(chose_domain_name)
  if nx_int(chose_domain_id) <= nx_int(0) then
    return
  end
  request_voter_info(chose_domain_id)
  refresh_grid_col(voter_grid_col_table)
  form.domain_vote_num = 0
  form.btn_index = 2
end
function on_btn_getself_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
  form.btn_getvoter.Enabled = false
  if nx_int(form.btn_index) == nx_int(3) then
    return
  end
  request_self_self()
  refresh_grid_col(voter_grid_col_table)
  form.domain_vote_num = 0
  form.lbl_guild_domain.Text = nx_widestr("")
  form.btn_index = 3
end
function on_grid_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_getvoter.Enabled = false
  if nx_int(form.btn_index) == nx_int(0) then
    local chose_domain_name = nx_widestr(grid:GetGridText(row, 0))
    local chose_domain_id = get_domain_id_by_name(chose_domain_name)
    if nx_int(chose_domain_id) <= nx_int(0) then
      return
    end
    if nx_int(form.chose_domain) == nx_int(chose_domain_id) then
      return
    end
    form.chose_domain = chose_domain_id
  elseif nx_int(form.btn_index) == nx_int(1) then
    local domain_name = nx_widestr(grid:GetGridText(row, 0))
    form.lbl_guild_domain.Text = nx_widestr(domain_name)
    form.domain_vote_num = nx_int(grid:GetGridText(row, 4))
    if nx_int(form.domain_vote_num) > nx_int(0) then
      form.btn_getvoter.Enabled = true
    end
  end
end
function on_btn_vote_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local chose_domain_name = form.lbl_guild_domain.Text
  local chose_domain_id = get_domain_id_by_name(chose_domain_name)
  if nx_int(chose_domain_id) <= nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local confirm_dlg = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_cf_vote_confirm", nx_widestr(chose_domain_name)))
  nx_execute("form_common\\form_confirm", "show_common_text", confirm_dlg, nx_widestr(text))
  confirm_dlg:ShowModal()
  local res = nx_wait_event(100000000, confirm_dlg, "confirm_return")
  if res == "ok" then
    send_vote(chose_domain_id)
  end
end
function on_btn_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_getvoter.Enabled = false
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = true
  if nx_int(form.btn_index) == nx_int(0) then
    return
  end
  refresh_grid_col(strike_target_col_table)
  request_enemy_guild_with_domain()
  form.btn_index = 0
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local chose_domain_id = form.chose_domain
  if nx_int(chose_domain_id) <= nx_int(0) then
    show_common_dialog(nx_widestr(util_text("ui_guild_nc")))
    return
  end
  local dialog = show_common_dialog(nx_widestr(gui.TextManager:GetFormatText("ui_add_strike_confirm", nx_widestr(util_text("ui_dipan_" .. nx_string(chose_domain_id))))))
  if not nx_is_valid(dialog) then
    return
  end
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_TASK_SUB_CMD_ADD_STRIKE_TARGET), nx_int(chose_domain_id))
  end
end
function on_btn_del_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local chose_domain_id = form.chose_domain
  if nx_int(chose_domain_id) <= nx_int(0) then
    show_common_dialog(nx_widestr(util_text("ui_guild_nc")))
    return
  end
  local dialog = show_common_dialog(nx_widestr(gui.TextManager:GetFormatText("ui_del_chase_confirm", nx_widestr(util_text("ui_dipan_" .. nx_string(chose_domain_id))))))
  if not nx_is_valid(dialog) then
    return
  end
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_TASK_SUB_CMD_DEL_STRIKE_TARGET), nx_int(chose_domain_id))
  end
end
function request_enemy_guild_with_domain()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_TASK_SUB_CMD_ENEMY_GUILD_WITH_DOMAIN))
end
function request_stage_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_SUB_CMD_CF_GET_STAGE))
end
function request_guilddomain_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_SUB_CMD_CF_ALL_GUILD_DOMAIN))
end
function request_voter_info(domain_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_SUB_CMD_CF_GET_VOTER), nx_int(domain_id))
end
function request_self_self()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_SUB_CMD_CF_SELF))
end
function send_vote(vote_domain_id)
  if nx_int(vote_domain_id) <= nx_int(0) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_SUB_CMD_CF_VOTE), nx_int(vote_domain_id))
end
function rec_guilds_info(...)
  local form = nx_value(FORM_COURTFIRE_INFO)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size <= 0 or size % INFO_LENGTH ~= 0 then
    return
  end
  refresh_grid_col(strike_target_col_table)
  local grid = form.grid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  for i = 1, size / INFO_LENGTH do
    local row = grid:InsertRow(-1)
    local cur_index = (i - 1) * INFO_LENGTH + 1
    grid:SetGridText(row, 0, nx_widestr(util_text(nx_string("ui_dipan_") .. nx_string(arg[cur_index]))))
    cur_index = cur_index + 1
    grid:SetGridText(row, 1, nx_widestr(arg[cur_index]))
    cur_index = cur_index + 1
    if nx_int(arg[cur_index]) > nx_int(0) then
      grid:SetGridText(row, 2, nx_widestr(util_text("ui_scene_" .. nx_string(arg[cur_index]))))
    end
    cur_index = cur_index + 1
    if nx_int(arg[cur_index]) == nx_int(GUILD_RELATION_ENEMY) then
      grid:SetGridText(row, 3, nx_widestr(util_text(nx_string("ui_guild_rivalry"))))
    elseif nx_int(arg[cur_index]) == nx_int(GUILD_RELATION_LEAGUE) then
      grid:SetGridText(row, 3, nx_widestr(util_text(nx_string("ui_guild_alliance"))))
    else
      grid:SetGridText(row, 3, nx_widestr(util_text(nx_string("ui_None"))))
    end
    cur_index = cur_index + 1
    local ctrl = gui:Create("Label")
    if nx_is_valid(ctrl) then
      ctrl.AutoSize = false
      ctrl.Align = "Center"
      ctrl.DrawMode = "Center"
      if nx_int(arg[cur_index]) == nx_int(IS_NOT_STRIKE_TARGET) then
        ctrl.BackImage = "gui\\special\\tvt\\fanghuo\\cantfire.png"
        ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_not_strike_target"))
        ctrl.Transparent = false
      elseif nx_int(arg[cur_index]) == nx_int(IS_STRIKE_TARGET) then
        ctrl.BackImage = "gui\\special\\tvt\\fanghuo\\canfire.png"
        ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_is_strike_target"))
        ctrl.Transparent = false
      end
      grid:SetGridControl(row, 4, ctrl)
    end
    cur_index = cur_index + 1
  end
  grid:EndUpdate()
end
function rec_stage_info(...)
  local form = nx_value(FORM_COURTFIRE_INFO)
  if not nx_is_valid(form) then
    return
  end
  local tab_index = 1
  local stage_index = nx_int(arg[tab_index]) + 1
  tab_index = tab_index + 1
  local has_domain = nx_int(arg[tab_index])
  tab_index = tab_index + 1
  if nx_int(has_domain) == nx_int(1) then
    form.btn_getself.Enabled = true
  end
  local is_captain = nx_int(arg[tab_index])
  tab_index = tab_index + 1
  if nx_int(is_captain) == nx_int(1) then
    form.btn_vote.Enabled = true
  end
  if stage_index > table.getn(stage_table) then
    stage_index = 1
  end
  form.stage_index = stage_index
  local stage_desc = stage_table[stage_index]
  form.lbl_stage.Text = nx_widestr(util_text(nx_string(stage_desc)))
end
function rec_guilddomain_info(...)
  local form = nx_value(FORM_COURTFIRE_INFO)
  if not nx_is_valid(form) then
    return
  end
  local arg_size = table.getn(arg) - 1
  if arg_size % 4 ~= 0 then
    return
  end
  local vote_total = nx_int(arg[table.getn(arg)])
  refresh_grid_col(all_grid_col_table)
  local grid = form.grid
  grid:BeginUpdate()
  for i = 1, arg_size / 4 do
    local row = grid:InsertRow(-1)
    local temp_index = (i - 1) * 4 + 1
    grid:SetGridText(row, 1, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
    local cur_domain_id = arg[temp_index]
    grid:SetGridText(row, 0, nx_widestr(util_text("ui_dipan_" .. nx_string(cur_domain_id))))
    temp_index = temp_index + 1
    grid:SetGridText(row, 2, nx_widestr(util_text("ui_scene_" .. nx_string(arg[temp_index]))))
    temp_index = temp_index + 1
    local isDanger = false
    local vote_count = nx_int(arg[temp_index])
    if nx_int(vote_count) ~= nx_int(0) and nx_int(row) >= nx_int(0) and nx_int(row) <= nx_int(2) then
      isDanger = true
    end
    local gui = nx_value("gui")
    local group_box = gui:Create("GroupBox")
    if nx_is_valid(group_box) then
      group_box.BackColor = "0,0,0,0"
      group_box.LineColor = "0,0,0,0"
      group_box.Text = ""
      group_box.Height = nx_int(grid.RowHeight) - 2
      group_box.Width = nx_int(grid:GetColWidth(3)) - 2
      local pro_bar = gui:Create("ProgressBar")
      if nx_is_valid(pro_bar) then
        pro_bar.NoFrame = false
        pro_bar.BackColor = "0,0,0,0"
        pro_bar.LineColor = "0,0,0,0"
        pro_bar.BackImage = "gui\\common\\progressbar\\bg_pbr_2.png"
        if isDanger == false then
          pro_bar.ProgressImage = "gui\\common\\progressbar\\pbr_3.png"
        else
          pro_bar.ProgressImage = "gui\\common\\progressbar\\pbr_1.png"
        end
        pro_bar.DrawMode = "FitWindow"
        pro_bar.ProgressMode = "LeftToRight"
        pro_bar.TextVisible = true
        pro_bar.TextPercent = true
        if nx_int(vote_total) ~= nx_int(0) then
          pro_bar.Value = vote_count / vote_total * 100
        else
          pro_bar.Value = 0
        end
        pro_bar.Width = group_box.Width
        pro_bar.Height = 8
        pro_bar.Left = 0
        pro_bar.Top = 2
        group_box:Add(pro_bar)
        grid:SetGridControl(row, 3, group_box)
      end
    end
    if nx_int(vote_total) ~= nx_int(0) then
      grid:SetGridText(row, 4, nx_widestr(vote_count))
    else
      grid:SetGridText(row, 4, nx_widestr(0))
    end
    local danger_index = 4
    if nx_int(vote_count) ~= nx_int(0) then
      if nx_int(row) >= nx_int(0) and nx_int(row) <= nx_int(2) then
        danger_index = 1
      elseif nx_int(row) > nx_int(2) and nx_int(row) <= nx_int(5) then
        danger_index = 2
      elseif nx_int(row) > nx_int(5) and nx_int(row) <= nx_int(9) then
        danger_index = 3
      elseif nx_int(row) > nx_int(9) then
        danger_index = 4
      end
    end
    grid:SetGridText(row, 5, nx_widestr(util_text(nx_string(danger_desc_table[danger_index]))))
  end
  grid:EndUpdate()
end
function rec_voter_info(...)
  local form = nx_value(FORM_COURTFIRE_INFO)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(table.getn(arg) % 3) ~= nx_int(0) then
    return
  end
  refresh_grid_col(voter_grid_col_table)
  local grid = form.grid
  grid:BeginUpdate()
  for i = 1, table.getn(arg) / 3 do
    local row = grid:InsertRow(-1)
    local temp_index = (i - 1) * 3 + 1
    grid:SetGridText(row, 0, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
    grid:SetGridText(row, 1, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
    grid:SetGridText(row, 2, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
  end
  grid:EndUpdate()
end
function clear_grid()
  local form = nx_value(FORM_COURTFIRE_INFO)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid
  grid:BeginUpdate()
  grid:ClearRow()
  grid:EndUpdate()
end
function refresh_grid_col(col_table)
  local form = nx_value(FORM_COURTFIRE_INFO)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid
  grid:BeginUpdate()
  grid:ClearRow()
  grid.ColCount = table.getn(col_table)
  local grid_width = grid.Width - 20
  for i = 1, grid.ColCount do
    grid:SetColWidth(i - 1, grid_width / all_grid_col_base * nx_int(col_table[i].percent))
    grid:SetColTitle(i - 1, nx_widestr(util_text(col_table[i].text)))
  end
  grid:ClearSelect()
  grid:EndUpdate()
end
function get_domain_id_by_name(domain_name)
  if nx_ws_length(domain_name) <= 0 then
    return -1
  end
  local counts = table.getn(guild_domain_table)
  local tDomain_id = -1
  for i = 1, counts do
    tDomain_id = guild_domain_table[i]
    local tDomain_name = nx_widestr(util_text("ui_dipan_" .. nx_string(tDomain_id)))
    if nx_ws_equal(nx_widestr(tDomain_name), nx_widestr(domain_name)) == true then
      break
    end
  end
  return tDomain_id
end
function show_common_dialog(show_text)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return nx_null()
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(show_text))
  dialog:ShowModal()
  return dialog
end
function clear_grid_control()
  local form = nx_value(FORM_COURTFIRE_INFO)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.grid) then
    local gui = nx_value("gui")
    local grid = form.grid
    grid:BeginUpdate()
    if nx_int(form.btn_index) == nx_int(0) then
      if grid.ColCount >= 5 then
        for i = 0, grid.RowCount - 1 do
          grid:ClearGridControl(i, 4)
        end
      end
    elseif nx_int(form.btn_index) == nx_int(1) and grid.ColCount > 3 then
      for i = 0, grid.RowCount - 1 do
        grid:ClearGridControl(i, 3)
      end
    end
    grid:EndUpdate()
  end
end
