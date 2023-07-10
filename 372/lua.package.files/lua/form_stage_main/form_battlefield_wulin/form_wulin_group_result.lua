require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_GROUP_RESULT = "form_stage_main\\form_battlefield_wulin\\form_wulin_group_result"
local wudao_group_result_head_info = {
  "ui_wudao_team_name",
  "ui_wudao_win_and_lose",
  "ui_wudao_score"
}
local wudao_group_info = {
  "ui_wudao_group_1",
  "ui_wudao_group_2",
  "ui_wudao_group_3",
  "ui_wudao_group_4"
}
function open_wudao_score_form(group_index)
  local form_score = nx_value(FORM_WULIN_GROUP_RESULT)
  if nx_is_valid(form_score) then
    form_score.group_index = group_index
    clear_team_info_data(form_score)
    custom_request_group_result(group_index)
  else
    local form = util_show_form(FORM_WULIN_GROUP_RESULT, true)
    if nx_is_valid(form) then
      form.group_index = group_index
      clear_team_info_data(form)
      custom_request_group_result(group_index)
    end
  end
end
function main_form_init(self)
  self.Fixed = false
  self.group_index = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  init_group_result_grid(self.textgrid_1)
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
function init_group_result_grid(grid)
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid.ColCount = 3
  grid:ClearRow()
  for i = 1, grid.ColCount do
    grid:SetColTitle(i - 1, util_text(wudao_group_result_head_info[i]))
    grid:SetColAlign(i - 1, "left")
  end
  grid:SetColWidth(0, 80)
  grid:SetColWidth(1, 80)
  grid:SetColWidth(2, 80)
  grid:EndUpdate()
end
function custom_request_group_result(group_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_GroupResult), nx_int(group_index))
end
function rec_team_score_info(...)
  local form = nx_value(FORM_WULIN_GROUP_RESULT)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(#arg) < nx_int(1) then
    return
  end
  local group_index = nx_int(arg[1])
  if nx_int(form.group_index) ~= nx_int(group_index) then
    return
  end
  local team_list = {}
  for i = 2, #arg do
    team_list[i - 1] = nx_widestr(arg[i])
  end
  updata_team_score_info(form.textgrid_1, team_list)
end
function updata_team_score_info(grid, team_list)
  if not nx_is_valid(grid) then
    return
  end
  local team_info_list = {}
  for i = 1, #team_list do
    local team_info = team_list[i]
    local war_team_info_list = util_split_wstring(team_info, ",")
    if nx_int(#war_team_info_list) == nx_int(4) then
      table.insert(team_info_list, {
        war_team_info_list[1],
        nx_int(war_team_info_list[2]),
        nx_int(war_team_info_list[3]),
        nx_int(war_team_info_list[4])
      })
    end
  end
  table.sort(team_info_list, function(a, b)
    if a[4] ~= b[4] then
      return a[4] > b[4]
    end
  end)
  grid:ClearRow()
  for j = 1, #team_info_list do
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(team_info_list[j][1]))
    local win_and_lost = nx_string(team_info_list[j][2]) .. nx_string("/") .. nx_string(team_info_list[j][3])
    grid:SetGridText(row, 1, nx_widestr(win_and_lost))
    grid:SetGridText(row, 2, nx_widestr(team_info_list[j][4]))
  end
end
function clear_team_info_data(form)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_1:ClearRow()
  form.lbl_title.Text = util_text("ui_wudao_group_" .. nx_string(form.group_index))
end
