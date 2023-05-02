require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\switch\\switch_define")
local FORM_INFO = "form_stage_main\\form_battlefield\\form_battlefield_balance_info"
local SELF_TEAM = 1
local ENEMY_TEAM = 2
local SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_SELF_TEAM_INFO = 5
local SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_ENEMY_TEAM_INFO = 6
local CLIENT_SUB_REQUEST_TEAM_NUM = 512
local balance_war_info_head_info = {
  "ui_guildwar_order_mingci",
  "ui_guildwar_order_xingming",
  "ui_battle_killenemy",
  "ui_battle_damage",
  "ui_battle_maxkill",
  "ui_battle_help",
  "ui_battle_dead"
}
function open_balance_info_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_BALANCE_CROSS_WAR) then
    return
  end
  local form = nx_value(FORM_INFO)
  if not nx_is_valid(form) then
    form = util_auto_show_hide_form(FORM_INFO)
  else
    return
  end
  if not nx_is_valid(form) then
    return
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
  init_balance_war_info_grid(self)
  self.rbtn_self_team.Checked = true
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
  local custom_data = rbtn.DataSource
  local sub_msg = 0
  if nx_int(custom_data) == nx_int(SELF_TEAM) then
    sub_msg = SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_SELF_TEAM_INFO
  elseif nx_int(custom_data) == nx_int(ENEMY_TEAM) then
    sub_msg = SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_ENEMY_TEAM_INFO
  end
  if nx_int(sub_msg) == nx_int(0) then
    return
  end
  custom_request_balance_info(sub_msg)
end
function custom_request_balance_info(info_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(info_type))
end
function rec_balance_war_info(...)
  local form = nx_value(FORM_INFO)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_balance_info
  if not nx_is_valid(grid) then
    return
  end
  grid:ClearRow()
  local temp_player_info_data = {}
  for i = 1, #arg do
    local str_info = arg[i]
    local info_list = util_split_wstring(str_info, ",")
    local info_list_num = table.getn(info_list)
    if nx_int(info_list_num) == nx_int(6) then
      table.insert(temp_player_info_data, {
        info_list[1],
        nx_int(info_list[2]),
        nx_int64(info_list[3]),
        info_list[4],
        info_list[5],
        info_list[6]
      })
    end
  end
  table.sort(temp_player_info_data, function(a, b)
    if a[2] ~= b[2] then
      return a[2] > b[2]
    end
    return a[3] > b[3]
  end)
  for j = 1, #temp_player_info_data do
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(j))
    for k = 1, 6 do
      grid:SetGridText(row, k, nx_widestr(temp_player_info_data[j][k]))
    end
  end
end
function init_balance_war_info_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_balance_info
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid.ColCount = 7
  grid:ClearRow()
  for i = 1, grid.ColCount do
    grid:SetColWidth(i - 1, 100)
    grid:SetColTitle(i - 1, util_text(balance_war_info_head_info[i]))
  end
  grid:SetColWidth(1, 120)
  grid:EndUpdate()
end
function close_form()
  local form = nx_value(FORM_INFO)
  if nx_is_valid(form) then
    form:Close()
  end
end
function a(b)
  nx_msgbox(nx_string(b))
end
