require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_APPLY = "form_stage_main\\form_battlefield_wulin\\form_wulin_apply"
local wudao_apply_head_info = {
  "ui_wudao_player_name",
  "ui_wudao_server_name",
  "ui_wudao_grade",
  "ui_wudao_online"
}
local player_uid = {}
local wudao_tip_select_player = "wudao_systeminfo_10100"
function close_form()
  local form = nx_value(FORM_WULIN_APPLY)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_wudao_apply_form()
  if not is_in_wudao_prepare_scene() then
    return
  end
  local form_apply = nx_value(FORM_WULIN_APPLY)
  if nx_is_valid(form_apply) and not form_apply.Visible then
    form_apply.Visible = true
  else
    util_show_form(FORM_WULIN_APPLY, true)
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
  init_apply_grid(self)
  custom_wudao_team_apply_info()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  player_uid = {}
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_clear_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_apply:ClearRow()
  custom_clear_apply_info()
end
function on_btn_agree_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_apply
  if not nx_is_valid(grid) then
    return
  end
  local row = grid.RowSelectIndex
  if nx_int(row) < nx_int(0) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_select_player)
    return
  end
  local player_uid = player_uid[row + 1]
  if nx_string(player_uid) == nx_string("") or player_uid == nil then
    return
  end
  custom_agree_player_apply(player_uid)
end
function custom_wudao_team_apply_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_APPLY))
end
function custom_clear_apply_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_CLEAR_APPLY_INFO))
end
function custom_agree_player_apply(struid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_AGREE_PLAYER_APPLY), nx_string(struid))
end
function rec_wudao_team_apply_info(...)
  local form = nx_value(FORM_WULIN_APPLY)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_apply
  if not nx_is_valid(grid) then
    return
  end
  grid:ClearRow()
  for i = 1, #arg do
    local apply_info = arg[i]
    local apply_list = util_split_wstring(apply_info, ",")
    if nx_int(#apply_list) == nx_int(5) then
      local row = grid:InsertRow(-1)
      player_uid[i] = nx_string(apply_list[1])
      local player_all_name = nx_widestr(apply_list[2])
      local player_all_name_list = util_split_wstring(player_all_name, "@")
      local number = table.getn(player_all_name_list)
      local player_name = nx_widestr(player_all_name_list[1])
      local player_server_name = nx_widestr(player_all_name_list[number])
      local player_win = nx_widestr(apply_list[3])
      local player_total = nx_widestr(apply_list[4])
      local player_lost = nx_widestr(nx_int(player_total) - nx_int(player_win))
      local player_online = nx_widestr(apply_list[5])
      grid:SetGridText(row, 0, player_name)
      grid:SetGridText(row, 1, player_server_name)
      grid:SetGridText(row, 2, player_win .. nx_widestr("/") .. player_lost)
      if nx_int(player_online) == nx_int(0) then
        grid:SetGridText(row, 3, util_text("ui_wudao_apply_5_no"))
      elseif nx_int(player_online) == nx_int(1) then
        grid:SetGridText(row, 3, util_text("ui_wudao_apply_5_yes"))
      end
    end
  end
end
function init_apply_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_apply
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid.ColCount = 4
  grid:ClearRow()
  for i = 1, grid.ColCount do
    grid:SetColWidth(i - 1, 80)
    grid:SetColTitle(i - 1, util_text(wudao_apply_head_info[i]))
  end
  grid:SetColWidth(0, 120)
  grid:SetColWidth(1, 120)
  grid:SetColAlign(0, "left")
  grid:EndUpdate()
end
