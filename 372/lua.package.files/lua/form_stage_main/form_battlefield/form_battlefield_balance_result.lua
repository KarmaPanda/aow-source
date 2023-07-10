require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\switch\\switch_define")
local SELF_TEAM = 1
local ENEMY_TEAM = 2
local win = 0
local lose = 1
local equal = 2
local team_self = {}
local team_enemy = {}
local SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_SELF_TEAM_RESULT = 7
local SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_ENEMY_TEAM_RESULT = 8
local SUB_CUSTOMMSG_REQUEST_QUIT_BALANCE_WAR = 9
local FORM_RESULT = "form_stage_main\\form_battlefield\\form_battlefield_balance_result"
local balance_war_head_info = {
  "ui_guildwar_order_mingci",
  "ui_guildwar_order_xingming",
  "ui_battle_getmoney",
  "ui_battle_killenemy",
  "ui_battle_damage",
  "ui_battle_maxkill",
  "ui_battle_help",
  "ui_battle_dead"
}
function open_balance_result_form(...)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_BALANCE_CROSS_WAR) then
    return
  end
  local form = nx_value(FORM_RESULT)
  if not nx_is_valid(form) then
    form = util_auto_show_hide_form(FORM_RESULT)
  else
    return
  end
  if not nx_is_valid(form) then
    return
  end
end
function close_form()
  local form = nx_value(FORM_RESULT)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function main_form_init(self)
  self.Fixed = true
  custom_request_balance_result(SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_SELF_TEAM_RESULT)
  custom_request_balance_result(SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_ENEMY_TEAM_RESULT)
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  init_rank_grid(self)
  self.rbtn_self.Checked = true
  self.rbtn_enemy.Enabled = false
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local result_type = rbtn.DataSource
  if nx_int(result_type) == nx_int(SELF_TEAM) then
    reflash_balance_war_result(team_self)
  elseif nx_int(result_type) == nx_int(ENEMY_TEAM) then
    reflash_balance_war_result(team_enemy)
  end
end
function on_btn_exit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local text = util_text("ui_quit_balance_war")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "quit_balance_war")
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "quit_balance_war_confirm_return")
  if res ~= "ok" then
    dialog:Close()
    return
  end
  dialog:Close()
  if nx_is_valid(form) then
    form:Close()
  end
  custom_request_quit_balance_war()
end
function custom_request_balance_result(result_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(result_type))
end
function custom_request_quit_balance_war()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_QUIT_BALANCE_WAR))
end
function rec_self_team_balance_war_result(...)
  team_self = {}
  for i = 1, #arg do
    team_self[i] = arg[i]
  end
  reflash_balance_war_result(team_self)
  local form = nx_value(FORM_RESULT)
  if nx_is_valid(form) then
    form.rbtn_enemy.Enabled = true
  end
end
function rec_enemy_team_balance_war_result(...)
  team_enemy = {}
  for i = 1, #arg do
    team_enemy[i] = arg[i]
  end
end
function reflash_balance_war_result(result_table)
  local form = nx_value(FORM_RESULT)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_balance_result
  if not nx_is_valid(grid) then
    return
  end
  local result = nx_int(result_table[1])
  show_win_or_lose(form, result)
  local result_type = nx_int(result_table[2])
  if result_type == nx_int(1) then
    form.rbtn_enemy.Visible = false
  end
  grid:ClearRow()
  local temp_player_data = {}
  for i = 3, #result_table do
    local str_result = result_table[i]
    local result_list = util_split_wstring(str_result, ",")
    local result_list_num = table.getn(result_list)
    if nx_int(result_list_num) == nx_int(7) then
      table.insert(temp_player_data, {
        result_list[1],
        nx_int(result_list[2]),
        nx_int(result_list[3]),
        nx_int64(result_list[4]),
        result_list[5],
        result_list[6],
        result_list[7]
      })
    end
  end
  table.sort(temp_player_data, function(a, b)
    if a[2] ~= b[2] then
      return a[2] > b[2]
    elseif a[3] ~= b[3] then
      return a[3] > b[3]
    else
      return a[4] > b[4]
    end
  end)
  for j = 1, #temp_player_data do
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(j))
    for k = 1, 7 do
      grid:SetGridText(row, k, nx_widestr(temp_player_data[j][k]))
    end
  end
end
function init_rank_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_balance_result
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid.ColCount = 8
  grid:ClearRow()
  for i = 1, grid.ColCount do
    grid:SetColWidth(i - 1, 100)
    grid:SetColTitle(i - 1, util_text(balance_war_head_info[i]))
  end
  grid:SetColWidth(1, 120)
  grid:EndUpdate()
end
function show_win_or_lose(form, result)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(result) == nx_int(win) then
    form.lbl_win_text.Visible = true
    form.lbl_lose_text.Visible = false
    form.lbl_equal_text.Visible = false
  elseif nx_int(result) == nx_int(lose) then
    form.lbl_win_text.Visible = false
    form.lbl_lose_text.Visible = true
    form.lbl_equal_text.Visible = false
  elseif nx_int(result) == nx_int(equal) then
    form.lbl_win_text.Visible = false
    form.lbl_lose_text.Visible = false
    form.lbl_equal_text.Visible = true
  end
end
function compel_close_result_form(...)
  local form = nx_value(FORM_RESULT)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
