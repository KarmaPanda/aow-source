require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_RESULT = "form_stage_main\\form_battlefield_wulin\\form_wulin_result"
local wudao_win = "gui/special/battlefiled_balance/result/victory.png"
local wudao_lose = "gui/special/battlefiled_balance/result/failed.png"
local wudao_equal = "gui/special/battlefiled_balance/result/draw.png"
local wudao_result_head_info = {
  "ui_wudao_rank",
  "ui_wudao_player_name",
  "ui_wudao_kill",
  "ui_wudao_damage",
  "ui_wudao_continue_kill",
  "ui_wudao_assist",
  "ui_wudao_dead",
  "ui_wudao_result"
}
function close_form()
  local form = nx_value(FORM_WULIN_RESULT)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_wudao_wulin_result_form()
  local form_result = nx_value(FORM_WULIN_RESULT)
  if nx_is_valid(form_result) then
    custom_request_war_result()
  end
  if nx_is_valid(form_result) and not form_result.Visible then
    form_result.Visible = true
  else
    util_show_form(FORM_WULIN_RESULT, true)
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  init_result_grid(self.textgrid_info_1)
  init_result_grid(self.textgrid_info_2)
  custom_request_war_result()
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
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_quit_wudao_war()
end
function custom_request_quit_wudao_war()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_Quit))
end
function custom_request_war_result()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_WarResultRequestUI))
end
function rec_wudao_war_result_info(...)
  local form = nx_value(FORM_WULIN_RESULT)
  if not nx_is_valid(form) then
    return
  end
  local result_type = nx_int(arg[1])
  show_or_not_wudao_result(form, result_type)
  form.lbl_self.Text = nx_widestr(arg[2])
  local self_result = nx_int(arg[3])
  updata_wudao_war_result(form, 1, self_result)
  local self_teammate_list = util_split_wstring(nx_widestr(arg[5]), "|")
  updata_player_info(form.textgrid_info_1, self_teammate_list)
  form.lbl_enemy.Text = nx_widestr(arg[6])
  local enemy_result = nx_int(arg[7])
  updata_wudao_war_result(form, 2, enemy_result)
  local enemy_teammate_list = util_split_wstring(nx_widestr(arg[9]), "|")
  updata_player_info(form.textgrid_info_2, enemy_teammate_list)
end
function init_result_grid(grid)
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid.ColCount = 8
  grid:ClearRow()
  for i = 1, grid.ColCount do
    grid:SetColTitle(i - 1, util_text(wudao_result_head_info[i]))
    grid:SetColAlign(i - 1, "left")
  end
  grid:SetColWidth(0, 50)
  grid:SetColWidth(1, 180)
  grid:SetColWidth(2, 80)
  grid:SetColWidth(3, 160)
  grid:SetColWidth(4, 80)
  grid:SetColWidth(5, 80)
  grid:SetColWidth(6, 80)
  grid:SetColWidth(7, 40)
  grid:SetColAlign(0, "center")
  grid:EndUpdate()
end
function show_or_not_wudao_result(form, show_type)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 6 do
    local lbl_self_name = "lbl_team_1_" .. nx_string(i)
    local lbl_enemy_name = "lbl_team_2_" .. nx_string(i)
    local lbl_self = form:Find(lbl_self_name)
    local lbl_enemy = form:Find(lbl_enemy_name)
    if nx_is_valid(lbl_self) and nx_is_valid(lbl_enemy) then
      if nx_int(show_type) == nx_int(0) then
        lbl_self.Visible = false
        lbl_enemy.Visible = false
      elseif nx_int(show_type) == nx_int(1) then
        lbl_self.Visible = true
        lbl_enemy.Visible = true
      end
    end
  end
end
function updata_wudao_war_result(form, team_type, war_result)
  if not nx_is_valid(form) then
    return
  end
  local lbl_name = ""
  if nx_int(team_type) == nx_int(1) then
    lbl_name = "lbl_team_1_"
  elseif nx_int(team_type) == nx_int(2) then
    lbl_name = "lbl_team_2_"
  end
  for i = 1, 6 do
    local name = nx_string(lbl_name) .. nx_string(i)
    local lbl = form:Find(name)
    if nx_int(war_result) == nx_int(0) then
      lbl.BackImage = nx_string(wudao_win)
    elseif nx_int(war_result) == nx_int(1) then
      lbl.BackImage = nx_string(wudao_lose)
    elseif nx_int(war_result) == nx_int(2) then
      lbl.BackImage = nx_string(wudao_equal)
    end
  end
end
function updata_player_info(grid, team_player_info_list)
  if not nx_is_valid(grid) then
    return
  end
  local temp_player_data = {}
  for i = 1, #team_player_info_list do
    local player_info = nx_widestr(team_player_info_list[i])
    local player_info_list = util_split_wstring(player_info, ",")
    if nx_int(#player_info_list) == nx_int(6) then
      table.insert(temp_player_data, {
        player_info_list[1],
        nx_int(player_info_list[2]),
        nx_int64(player_info_list[3]),
        nx_int(player_info_list[4]),
        player_info_list[5],
        nx_int(player_info_list[6])
      })
    end
  end
  table.sort(temp_player_data, function(a, b)
    if a[2] ~= b[2] then
      return a[2] > b[2]
    elseif a[3] ~= b[3] then
      return a[3] > b[3]
    else
      return a[6] < b[6]
    end
  end)
  grid:ClearRow()
  for j = 1, #temp_player_data do
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(j))
    for k = 1, 6 do
      grid:SetGridText(row, k, nx_widestr(temp_player_data[j][k]))
    end
    grid:SetGridText(row, 7, nx_widestr(""))
  end
end
