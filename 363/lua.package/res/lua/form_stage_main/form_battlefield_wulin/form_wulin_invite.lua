require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_INVITE = "form_stage_main\\form_battlefield_wulin\\form_wulin_invite"
local wudao_war_file = "share\\War\\WuDaoWar\\wudao_war.ini"
local wudao_invent_head_info = {
  "ui_wudao_player_name",
  "ui_wudao_server_name",
  "ui_wudao_grade"
}
local wudao_tip_select_player = "wudao_systeminfo_10100"
function close_form()
  local form = nx_value(FORM_WULIN_INVITE)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_wudao_invent_form()
  if not is_in_wudao_prepare_scene() then
    return
  end
  local form_invent = nx_value(FORM_WULIN_INVITE)
  if nx_is_valid(form_invent) and not form_invent.Visible then
    form_invent.Visible = true
  else
    util_show_form(FORM_WULIN_INVITE, true)
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
  init_invent_grid(self)
  init_server_combox(self)
  custom_can_invent_player()
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
function on_btn_find_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local server_name = form.combobox_1.Text
  if nx_widestr(server_name) == nx_widestr("") or nx_widestr(server_name) == nx_widestr("nil") then
    return
  end
  local player_name = form.ipt_1.Text
  if nx_widestr(player_name) == nx_widestr("") or nx_widestr(player_name) == nx_widestr("nil") then
    return
  end
  local full_name = player_name .. nx_widestr("@") .. server_name
  custom_find_player_by_name(full_name)
end
function on_btn_invent_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_invent
  if not nx_is_valid(grid) then
    return
  end
  local row = grid.RowSelectIndex
  if nx_int(row) < nx_int(0) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "show_caution_info", wudao_tip_select_player)
    return
  end
  local player_name = grid:GetGridText(row, 0)
  if nx_widestr(player_name) == nx_widestr("") then
    return
  end
  local server_name = grid:GetGridText(row, 1)
  if nx_widestr(server_name) == nx_widestr("") then
    return
  end
  local full_name = player_name .. nx_widestr("@") .. server_name
  custom_player_join_team(full_name)
end
function on_combobox_1_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
end
function on_ipt_1_get_focus(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  self.Text = ""
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_can_invent_player()
end
function custom_server_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_SERVER_NAME))
end
function custom_can_invent_player()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_OPEN_INVENT_FORM))
end
function custom_player_join_team(wstrPlayreName)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_INVENT_PLAYER), nx_widestr(wstrPlayreName))
end
function custom_find_player_by_name(wstrPlayreName)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_FIND_PLAYER_BY_NAME), nx_widestr(wstrPlayreName))
end
function custom_respond_agree_join(wstrTeamName)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_PLAYER_AGREE_JOIN_TEAM), nx_widestr(wstrTeamName))
end
function custom_reject_invent_join(leader_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RejectInvent), nx_widestr(leader_name))
end
function rec_can_invent_player_info(...)
  local form = nx_value(FORM_WULIN_INVITE)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_invent
  if not nx_is_valid(grid) then
    return
  end
  grid:ClearRow()
  for i = 1, #arg do
    local invent_info = arg[i]
    local invent_list = util_split_wstring(invent_info, ",")
    if nx_int(#invent_list) == nx_int(3) then
      local row = grid:InsertRow(-1)
      local player_all_name = nx_widestr(invent_list[1])
      local player_all_name_list = util_split_wstring(player_all_name, "@")
      local number = table.getn(player_all_name_list)
      local player_name = nx_widestr(player_all_name_list[1])
      local player_server_name = nx_widestr(player_all_name_list[number])
      local player_win = nx_widestr(invent_list[2])
      local player_total = nx_widestr(invent_list[3])
      local player_lost = nx_widestr(nx_int(player_total) - nx_int(player_win))
      grid:SetGridText(row, 0, player_name)
      grid:SetGridText(row, 1, player_server_name)
      grid:SetGridText(row, 2, player_win .. nx_widestr("/") .. player_lost)
    end
  end
end
function rec_server_list(...)
  local form = nx_value(FORM_WULIN_INVITE)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, #arg do
    form.combobox_1.DropListBox:AddString(nx_widestr(arg[i]))
  end
end
function rec_find_player_info(...)
  local form = nx_value(FORM_WULIN_INVITE)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_invent
  if not nx_is_valid(grid) then
    return
  end
  if nx_int(#arg) < nx_int(3) then
    return
  end
  grid:ClearRow()
  local row = grid:InsertRow(-1)
  local player_all_name_list = util_split_wstring(arg[1], "@")
  local count = table.getn(player_all_name_list)
  grid:SetGridText(row, 0, player_all_name_list[1])
  grid:SetGridText(row, 1, player_all_name_list[2])
  local player_win = nx_widestr(arg[2])
  local player_total = nx_widestr(arg[3])
  local player_lost = nx_widestr(nx_int(player_total) - nx_int(player_win))
  grid:SetGridText(row, 2, player_win .. nx_widestr("/") .. player_lost)
end
function rec_invent_to_join(...)
  if nx_int(#arg) < nx_int(2) then
    return
  end
  local team_name = nx_widestr(arg[1])
  if nx_widestr(team_name) == nx_widestr("") or nx_widestr(team_name) == nx_widestr("nil") then
    return
  end
  local leader_name = nx_widestr(arg[2])
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return true
  end
  gui.TextManager:Format_SetIDName("ui_wudao_invent_join")
  gui.TextManager:Format_AddParam(leader_name)
  gui.TextManager:Format_AddParam(team_name)
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "wudao_invent_join")
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "wudao_invent_join_confirm_return")
  if res ~= "ok" then
    custom_reject_invent_join(leader_name)
    return
  end
  custom_respond_agree_join(team_name)
end
function init_invent_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_invent
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid.ColCount = 3
  grid:ClearRow()
  for i = 1, grid.ColCount do
    grid:SetColTitle(i - 1, util_text(wudao_invent_head_info[i]))
  end
  grid:SetColAlign(0, "left")
  grid:SetColWidth(0, 120)
  grid:SetColWidth(1, 120)
  grid:SetColWidth(2, 80)
  grid:EndUpdate()
end
function init_server_combox(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", wudao_war_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("server_name")
  if sec_count < 0 then
    return
  end
  local total_count = ini:GetSectionItemCount(sec_count)
  for i = 1, total_count do
    local server_ui = "ui_server_name_list_" .. nx_string(i)
    form.combobox_1.DropListBox:AddString(util_text(server_ui))
  end
end
