require("share\\client_custom_define")
require("share\\view_define")
require("define\\request_type")
require("define\\team_rec_define")
require("form_stage_main\\form_team\\team_util_functions")
require("util_functions")
local FORM_TEAM_RECRUIT = "form_stage_main\\form_team\\form_team_recruit"
local FORM_RECRUIT_PUBLISH = "form_stage_main\\form_team\\form_recruit_publish"
local TEAM_RECRUIT_REC = "team_recruit_rec"
function refresh_form(form)
  if nx_is_valid(form) then
    refresh_team_grid(form)
    nx_execute("custom_sender", "custom_team_info_refresh")
  end
end
function main_form_init(self)
  self.Fixed = true
end
function main_form_open(self)
  init_grid(self)
  self.cur_selected_index = -1
  self.btn_invite.Enabled = false
  self.btn_request.Enabled = false
  data_bind_prop(self)
  refresh_team_grid(self)
  nx_execute("custom_sender", "custom_team_info_refresh")
end
function on_main_form_close(form)
  del_data_bind_prop(form)
  nx_destroy(form)
  nx_set_value(nx_current(), nx_null())
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  refresh_form(form)
end
function on_btn_request_click(btn)
  local form = btn.ParentForm
  local index = form.cur_selected_index
  if index < 0 then
    return
  end
  local name = form.grid_details:GetGridText(index, 1)
  nx_execute("custom_sender", "custom_team_request_join", name)
end
function on_btn_invite_click(btn)
  local form = btn.ParentForm
  local index = form.cur_selected_index
  if index < 0 then
    return
  end
  local name = form.grid_details:GetGridText(index, 1)
  nx_execute("custom_sender", "custom_team_invite", name)
end
function on_btn_publish_click(btn)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local form_publish = nx_execute("util_gui", "util_get_form", FORM_RECRUIT_PUBLISH, true, false)
  if nx_is_valid(form_publish) then
    local self_name = client_player:QueryProp("Name")
    local captainname = client_player:QueryProp("TeamCaptain")
    if nx_ws_equal(nx_widestr(self_name), nx_widestr(captainname)) then
      form_publish.lbl_title.Text = gui.TextManager:GetText("ui_zudui0052")
    else
      form_publish.lbl_title.Text = gui.TextManager:GetText("ui_zudui0028")
    end
    form_publish:ShowModal()
  end
end
function on_btn_destroy_click(btn)
  nx_execute("custom_sender", "custom_team_remove_info")
end
function on_grid_details_select_grid(grid, row)
  local form = grid.ParentForm
  form.cur_selected_index = row
  switch_team_btn_state(form, row)
end
function on_grid_details_right_select_grid(grid, row, col)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local team_name = client_player:QueryRecord(TEAM_RECRUIT_REC, row, TEAM_RECRUIT_TEAM_NAME)
  nx_execute("menu_game", "menu_game_reset", nx_string(team_name), "recruit")
  nx_execute("menu_game", "menu_recompose", menu_game)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x, y)
end
function data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(TEAM_RECRUIT_REC, self, nx_current(), "on_table_operat")
    databinder:AddRolePropertyBind("TeamCaptain", "widestr", self, nx_current(), "on_TeamCaptain_Change")
  end
end
function del_data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("TeamCaptain", self)
    databinder:DelTableBind(TEAM_RECRUIT_REC, self)
  end
end
function init_grid(form)
  form.grid_details.ColCount = 5
  form.grid_details:SetColAlign(0, "center")
  form.grid_details:SetColAlign(1, "center")
  form.grid_details:SetColAlign(2, "center")
  form.grid_details:SetColAlign(3, "center")
  form.grid_details:SetColAlign(4, "center")
  form.grid_details:SetColWidth(0, form.btn_1.Width)
  form.grid_details:SetColWidth(1, form.btn_3.Width)
  form.grid_details:SetColWidth(2, form.btn_4.Width)
  form.grid_details:SetColWidth(3, form.btn_5.Width)
  form.grid_details:SetColWidth(4, form.btn_6.Width - 25)
end
function on_TeamCaptain_Change(form)
  if not form.Visible then
    return
  end
  refresh_recruit_btn_state(form)
end
function on_table_operat(self, tablename, ttype, line, col)
  if not self.Visible then
    return
  end
  refresh_all_info(self)
end
function refresh_all_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_all_info", form)
    timer:Register(500, 1, nx_current(), "on_refresh_all_info", form, -1, -1)
  end
end
function on_refresh_all_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_all_info", form)
  end
  refresh_team_grid(form)
end
function refresh_team_grid(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local item_row_num = client_player:GetRecordRows(TEAM_RECRUIT_REC)
  form.grid_details.RowCount = 0
  if 0 < item_row_num then
    for i = 0, item_row_num - 1 do
      local flag = client_player:QueryRecord(TEAM_RECRUIT_REC, i, TEAM_RECRUIT_TEAM_ID)
      local playername = client_player:QueryRecord(TEAM_RECRUIT_REC, i, TEAM_RECRUIT_TEAM_NAME)
      local school = client_player:QueryRecord(TEAM_RECRUIT_REC, i, TEAM_RECRUIT_TEAM_SCHOOL)
      local school_name = ""
      if nil == school or "" == school or nx_string(0) == school then
        school_name = gui.TextManager:GetText("ui_None")
      else
        school_name = gui.TextManager:GetText(nx_string(school))
      end
      local playermission = nx_widestr(client_player:QueryRecord(TEAM_RECRUIT_REC, i, TEAM_RECRUIT_TEAM_TYPE)) .. nx_widestr("-") .. nx_widestr(client_player:QueryRecord(TEAM_RECRUIT_REC, i, TEAM_RECRUIT_TEAM_MISSION))
      local playerinfo = client_player:QueryRecord(TEAM_RECRUIT_REC, i, TEAM_RECRUIT_TEAM_INFO)
      local row = form.grid_details:InsertRow(-1)
      if flag == 0 then
        form.grid_details:SetGridText(row, 0, nx_widestr(util_text("ui_SearchTeam")))
      else
        form.grid_details:SetGridText(row, 0, nx_widestr(util_text("ui_Recruit")))
      end
      form.grid_details:SetGridText(row, 1, nx_widestr(playername))
      form.grid_details:SetGridText(row, 2, nx_widestr(school_name))
      form.grid_details:SetGridText(row, 3, nx_widestr(playermission))
      form.grid_details:SetGridText(row, 4, nx_widestr(playerinfo))
    end
  end
  clear_team_btn_state(form)
  refresh_recruit_btn_state(form)
end
function clear_team_btn_state(form)
  form.btn_invite.Visible = false
  form.btn_invite.Enabled = false
  form.btn_request.Visible = false
  form.btn_request.Enabled = false
  form.cur_selected_index = -1
end
function switch_team_btn_state(form, row)
  if row < 0 then
    clear_team_btn_state(form)
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  local recruit_name = form.grid_details:GetGridText(row, 1)
  form.btn_invite.Visible = false
  form.btn_invite.Enabled = false
  form.btn_request.Visible = false
  form.btn_request.Enabled = false
  local record_row = client_player:FindRecordRow(TEAM_RECRUIT_REC, TEAM_RECRUIT_TEAM_NAME, nx_widestr(recruit_name), 0)
  if record_row < 0 then
    return
  end
  local recruit_team_id = client_player:QueryRecord(TEAM_RECRUIT_REC, record_row, TEAM_RECRUIT_TEAM_ID)
  if nx_ws_equal(nx_widestr(recruit_name), nx_widestr(self_name)) then
    return
  end
  local self_is_team_captain = is_team_captain()
  local self_is_in_team = is_in_team()
  if self_is_team_captain then
    form.btn_invite.Visible = true
    form.btn_invite.Enabled = recruit_team_id == 0
  elseif self_is_in_team then
    if recruit_team_id ~= 0 then
      form.btn_request.Visible = true
      form.btn_request.Enabled = false
    else
      form.btn_invite.Visible = true
      form.btn_invite.Enabled = get_team_type() == TYPE_LARGE_TEAM and get_team_work() == TYPE_NORAML_ASSIST
    end
  elseif recruit_team_id ~= 0 then
    form.btn_request.Visible = true
    form.btn_request.Enabled = true
  else
    form.btn_invite.Visible = true
    form.btn_invite.Enabled = true
  end
end
function refresh_recruit_btn_state(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local self_name = client_player:QueryProp("Name")
  local captainname = client_player:QueryProp("TeamCaptain")
  if nx_ws_equal(nx_widestr(self_name), nx_widestr(captainname)) then
    form.btn_publish.Text = gui.TextManager:GetText("ui_zudui0052")
  else
    form.btn_publish.Text = gui.TextManager:GetText("ui_zudui0028")
  end
  form.btn_publish.Visible = false
  form.btn_destroy.Visible = false
  local self_is_team_captain = is_team_captain()
  local self_is_in_team = is_in_team()
  if self_is_team_captain or not self_is_in_team then
    local row = client_player:FindRecordRow(TEAM_RECRUIT_REC, TEAM_RECRUIT_TEAM_NAME, nx_widestr(self_name), 0)
    if row < 0 then
      form.btn_publish.Visible = true
    else
      form.btn_destroy.Visible = true
    end
  end
end
