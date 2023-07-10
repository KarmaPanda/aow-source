require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
local table_col_info = {}
local SUB_CUSTOMMSG_REQUEST_DKP_LIST = 81
local SUB_CUSTOMMSG_DKP_CHANGE = 82
local SUB_CUSTOMMSG_DKP_RESET = 83
local SUB_CUSTOMMSG_DKP_PUBLISH_NOTICE = 84
local SUB_CUSTOMMSG_REQUEST_DKP_LOG_LIST = 85
local SUB_CUSTOMMSG_REQUEST_DKP_UNITSCORE_LIST = 86
local SUB_CUSTOMMSG_DKP_UNIT_SET_SCORE = 87
local SUB_CUSTOMMSG_DELETE_DKP_UNITSCORE = 88
local SUB_CUSTOMMSG_DKP_CLEAR_ALL = 89
local SUB_CUSTOMMSG_DKP_CALCULATE_PERSONAL = 90
local SUB_CUSTOMMSG_DKP_CALCULATE_ALL = 91
local SUB_CUSTOMMSG_DKP_SELF_DEFINE = 92
local SUB_CUSTOMMSG_DKP_DKP_SEARCH = 93
local operate_add = 1
local operate_reduce = 1
local log_type_set_socre = 0
local log_type_personal = 1
local log_type_all = 2
local dkp_log_type_change_sum_score = 0
local dkp_log_type_change_unit_score = 1
local dkp_log_type_clear_all_score = 2
local dkp_log_type_clear_score = 3
local dkp_log_type_calculate = 4
function main_form_init(form)
  form.Fixed = false
  form.pageno = 1
  form.page_next_ok = 1
  form.grid_dkp_type = 0
  form.cmb_dkp_type = 0
end
function on_main_form_open(self)
  self.Fixed = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.groupbox_dkp.Visible = true
  self.groupbox_log.Visible = false
  self.groupbox_dkp_set.Visible = false
  local width = self.textgrid_dkp.Width
  self.textgrid_dkp:BeginUpdate()
  self.textgrid_dkp:SetColWidth(0, width * 0.125)
  self.textgrid_dkp:SetColWidth(1, width * 0.15)
  self.textgrid_dkp:SetColWidth(2, width * 0.15)
  self.textgrid_dkp:SetColWidth(3, width * 0.15)
  self.textgrid_dkp:SetColWidth(4, width * 0.15)
  self.textgrid_dkp:SetColWidth(5, width * 0.15)
  self.textgrid_dkp:SetColWidth(6, width * 0.1)
  self.textgrid_dkp:SetColTitle(0, nx_widestr(util_text("ui_guild_player_name")))
  self.textgrid_dkp:SetColTitle(1, nx_widestr(util_text("ui_guild_dkp_type_1")))
  self.textgrid_dkp:SetColTitle(2, nx_widestr(util_text("ui_guild_dkp_type_2")))
  self.textgrid_dkp:SetColTitle(3, nx_widestr(util_text("ui_guild_dkp_type_3")))
  self.textgrid_dkp:SetColTitle(4, nx_widestr(util_text("ui_guild_dkp_type_4")))
  self.textgrid_dkp:SetColTitle(5, nx_widestr(util_text("ui_guild_dkp_type_5")))
  self.textgrid_dkp:SetColTitle(6, nx_widestr(util_text("ui_guild_total_points")))
  self.textgrid_dkp:EndUpdate()
  self.textgrid_dkp_set:BeginUpdate()
  self.textgrid_dkp_set:SetColWidth(0, 0)
  self.textgrid_dkp_set:SetColWidth(1, width * 0.16666666666666666)
  self.textgrid_dkp_set:SetColWidth(2, width * 0.14285714285714285)
  self.textgrid_dkp_set:SetColTitle(1, nx_widestr(util_text("ui_dkp_set_dkp_type")))
  self.textgrid_dkp_set:SetColTitle(2, nx_widestr(util_text("ui_dkp_set_value")))
  self.textgrid_dkp_set:EndUpdate()
  inti_cmp_dkp_type(self)
  request_dkp_list(self.pageno)
  request_dkp_log_list()
  self.btn_left.Visible = true
  self.btn_right.Visible = false
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_rbtn_dkp_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.groupbox_dkp.Visible = true
  form.groupbox_log.Visible = false
  form.groupbox_dkp_set.Visible = false
  request_dkp_list(form.pageno)
  form.cmb_choose.DropListBox.Visible = false
end
function on_rbtn_log_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.groupbox_dkp_set.Visible = false
  form.groupbox_dkp.Visible = false
  form.groupbox_log.Visible = true
  form.cmb_choose.DropListBox.Visible = false
end
function on_rbtn_dkp_set_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.groupbox_dkp.Visible = false
  form.groupbox_log.Visible = false
  form.groupbox_dkp_set.Visible = true
  form.cmb_choose.DropListBox.Visible = true
  request_dkp_ste_list()
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.pageno > 1 then
    request_dkp_list(form.pageno - 1)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    request_dkp_list(form.pageno + 1)
  end
end
function on_textgrid_dkp_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local name = grid:GetGridText(row, 0)
  form.lbl_name.Text = nx_widestr(name)
  local sum_score = grid:GetGridText(row, 4)
  form.fipt_score.Text = nx_widestr(sum_score)
  form.ipt_log.Text = nx_widestr("")
end
function on_btn_clear_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local lengh = nx_ws_length(form.lbl_name.Text)
  if nx_int(lengh) == nx_int(0) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19658"), 2)
    end
    return 0
  end
  if not show_confirm_info("19657", nx_widestr(form.lbl_name.Text)) then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_RESET), nx_widestr(form.lbl_name.Text), nx_int(from), nx_int(to))
  request_dkp_list(form.pageno)
end
function on_btn_clear_all_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  if not show_confirm_info("19671") then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_CLEAR_ALL), nx_int(from), nx_int(to))
end
function on_btn_score_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local lengh = nx_ws_length(form.lbl_name.Text)
  if nx_int(lengh) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19658"), 2)
    return 0
  end
  if nx_int(form.fipt_score.Text) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19693"), 2)
    return
  end
  if not show_confirm_info("19656", nx_widestr(form.lbl_name.Text), nx_int(form.fipt_score.Text)) then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_CHANGE), nx_widestr(form.lbl_name.Text), nx_int(form.fipt_score.Text), form.ipt_log.Text, nx_int(from), nx_int(to))
end
function on_btn_reduce_score_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local lengh = nx_ws_length(form.lbl_name.Text)
  if nx_int(lengh) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19658"), 2)
    return 0
  end
  local reduce_value = nx_int(0) - nx_int(form.fipt_1.Text)
  if nx_int(reduce_value) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19693"), 2)
    return
  end
  if not show_confirm_info("19673", nx_widestr(form.lbl_name.Text), nx_int(form.fipt_1.Text)) then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_CHANGE), nx_widestr(form.lbl_name.Text), nx_int(reduce_value), form.ipt_log.Text, nx_int(from), nx_int(to))
end
function on_btn_team_add_score_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local gui = nx_value("gui")
  if nx_int(form.fipt_team_add_score.Text) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19693"), 2)
    return
  end
  if not show_confirm_info("19690") then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_SELF_DEFINE), nx_int(form.fipt_team_add_score.Text), form.ipt_log.Text, nx_int(from), nx_int(to))
end
function on_btn_team_reduce_score_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local reduce_value = nx_int(0) - nx_int(form.fipt_team_reduce_score.Text)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local gui = nx_value("gui")
  if nx_int(reduce_value) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19693"), 2)
    return
  end
  if not show_confirm_info("19689") then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_SELF_DEFINE), nx_int(reduce_value), form.ipt_log.Text, nx_int(from), nx_int(to))
end
function on_btn_calculate_one_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local lengh = nx_ws_length(form.lbl_name.Text)
  if nx_int(lengh) == nx_int(0) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19658"), 2)
    end
    return 0
  end
  if not show_confirm_info("19672") then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_CALCULATE_PERSONAL), nx_widestr(form.lbl_name.Text), nx_int(from), nx_int(to))
  form.lbl_name.Text = nx_widestr("")
  form.fipt_score.Text = nx_widestr("")
  form.ipt_log.Text = nx_widestr("")
end
function on_btn_calculate_all_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if not show_confirm_info("19672") then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_CALCULATE_ALL), nx_int(from), nx_int(to))
end
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local notice = form.redit_notice.Text
  local notice = form.redit_notice.Text
  local check_words = nx_value("CheckWords")
  if nx_is_valid(check_words) and not check_words:CheckBadWords(nx_widestr(notice)) then
    local gui = nx_value("gui")
    local text = nx_widestr(gui.TextManager:GetText("ui_EnterValidNote"))
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local from = (nx_int(form.pageno) - 1) * 10
  local to = form.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_PUBLISH_NOTICE), notice, nx_int(from), nx_int(to))
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.grb_change.Visible = true
  form.btn_left.Visible = true
  form.btn_right.Visible = false
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.grb_change.Visible = false
  form.btn_left.Visible = false
  form.btn_right.Visible = true
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local playre_name = form.ipt_name.Text
  local lengh = nx_ws_length(playre_name)
  if nx_int(lengh) == nx_int(0) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19696"), 2)
    end
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_DKP_SEARCH), nx_widestr(playre_name))
end
function recv_search_data(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_dkp")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size <= 0 or size % 7 ~= 0 then
    return 0
  end
  if from < 0 or from == to then
    form.page_next_ok = 0
    return 0
  end
  form.page_next_ok = 0
  form.pageno = from / 10 + 1
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / 10))
  form.lbl_pageno.Text = nx_widestr(nowpage .. maxpage)
  local rows = size / 7
  if 11 < rows then
    rows = 11
  end
  form.textgrid_dkp:BeginUpdate()
  form.textgrid_dkp:ClearRow()
  local v1 = get_col_value(nx_int(1))
  local v2 = get_col_value(nx_int(2))
  local v3 = get_col_value(nx_int(3))
  local v4 = get_col_value(nx_int(4))
  local v5 = get_col_value(nx_int(5))
  for i = 1, rows do
    local row = form.textgrid_dkp:InsertRow(-1)
    local base = (i - 1) * 7
    local p1 = nx_int(arg[base + 2])
    local p2 = nx_int(arg[base + 3])
    local p3 = nx_int(arg[base + 4])
    local p4 = nx_int(arg[base + 5])
    local p5 = nx_int(arg[base + 6])
    form.textgrid_dkp:SetGridText(row, 0, nx_widestr(arg[base + 1]))
    form.textgrid_dkp:SetGridText(row, 1, nx_widestr(v1 * p1) .. nx_widestr(" ( ") .. nx_widestr(p1) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 2, nx_widestr(v2 * p2) .. nx_widestr(" ( ") .. nx_widestr(p2) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 3, nx_widestr(v3 * p3) .. nx_widestr(" ( ") .. nx_widestr(p3) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 4, nx_widestr(v4 * p4) .. nx_widestr(" ( ") .. nx_widestr(p4) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 5, nx_widestr(v5 * p5) .. nx_widestr(" ( ") .. nx_widestr(p5) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 6, nx_widestr(arg[base + 7]))
  end
  form.textgrid_dkp:EndUpdate()
end
function request_dkp_list(pageno)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DKP_LIST), nx_int(from), nx_int(to))
end
function on_recv_dkp_list(notice, col_no_list, from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_dkp")
  if not nx_is_valid(form) then
    return
  end
  reset_dkp_title(form, col_no_list)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.redit_notice.Text = nx_widestr(notice)
  local count = #arg
  if count < 4 then
    return
  end
  local size = table.getn(arg)
  if size <= 0 or size % 7 ~= 0 then
    return 0
  end
  if from < 0 or from == to then
    form.page_next_ok = 0
    return 0
  end
  form.page_next_ok = 1
  form.pageno = from / 10 + 1
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / 10))
  form.lbl_pageno.Text = nx_widestr(nowpage .. maxpage)
  local rows = size / 7
  if 11 < rows then
    rows = 11
  end
  form.textgrid_dkp:BeginUpdate()
  form.textgrid_dkp:ClearRow()
  for index = 0, 7 do
    form.textgrid_dkp:SetGridForeColor(0, index, "255,255,0,0")
  end
  local v1 = get_col_value(nx_int(1))
  local v2 = get_col_value(nx_int(2))
  local v3 = get_col_value(nx_int(3))
  local v4 = get_col_value(nx_int(4))
  local v5 = get_col_value(nx_int(5))
  for i = 1, rows do
    local row = form.textgrid_dkp:InsertRow(-1)
    local base = (i - 1) * 7
    local p1 = nx_int(arg[base + 2])
    local p2 = nx_int(arg[base + 3])
    local p3 = nx_int(arg[base + 4])
    local p4 = nx_int(arg[base + 5])
    local p5 = nx_int(arg[base + 6])
    form.textgrid_dkp:SetGridText(row, 0, nx_widestr(arg[base + 1]))
    form.textgrid_dkp:SetGridText(row, 1, nx_widestr(v1 * p1) .. nx_widestr(" ( ") .. nx_widestr(arg[base + 2]) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 2, nx_widestr(v2 * p2) .. nx_widestr(" ( ") .. nx_widestr(arg[base + 3]) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 3, nx_widestr(v3 * p3) .. nx_widestr(" ( ") .. nx_widestr(arg[base + 4]) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 4, nx_widestr(v4 * p4) .. nx_widestr(" ( ") .. nx_widestr(arg[base + 5]) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 5, nx_widestr(v5 * p5) .. nx_widestr(" ( ") .. nx_widestr(arg[base + 6]) .. nx_widestr(" ) "))
    form.textgrid_dkp:SetGridText(row, 6, nx_widestr(arg[base + 7]))
  end
  local playre_name = client_player:QueryProp("Name")
  local dkp_role_name = nx_widestr(arg[1])
  if playre_name == dkp_role_name then
    for index = 0, 7 do
      form.textgrid_dkp:SetGridForeColor(0, index, "255,150,0,150")
    end
  end
  form.textgrid_dkp:EndUpdate()
end
function get_col_value(col_no)
  local lengh = table.getn(table_col_info)
  for i = 1, lengh do
    local base_info = table_col_info[i]
    local index = base_info[1]
    local value = base_info[2]
    if nx_int(index) == nx_int(col_no) then
      return nx_int(value)
    end
  end
  return 0
end
function request_dkp_log_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DKP_LOG_LIST), nx_int(log_type_all))
end
function on_btn_log_set_score_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DKP_LOG_LIST), nx_int(log_type_set_socre))
end
function on_btn_log_personal_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DKP_LOG_LIST), nx_int(log_type_personal))
end
function on_btn_log_all_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DKP_LOG_LIST), nx_int(log_type_all))
end
function on_recv_dkp_log_list(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_dkp")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size <= 0 or size % 7 ~= 0 then
    form.textgrid_dkp.HtmlText = ""
    return 0
  end
  local all_content
  local rows = size / 7
  for i = 1, rows do
    local base = (i - 1) * 7
    local log_time = arg[base + 1]
    local role1 = arg[base + 2]
    local role2 = arg[base + 3]
    local old_point = arg[base + 4]
    local new_point = arg[base + 5]
    local remark = arg[base + 6]
    local log_type = arg[base + 7]
    local info = get_log_info(role1, role2, old_point, new_point, remark, log_type)
    local content = nx_widestr(log_time) .. nx_widestr("   ") .. nx_widestr(info)
    if all_content ~= nil then
      all_content = nx_widestr(all_content) .. nx_widestr("<br>") .. nx_widestr(" ") .. content
    else
      all_content = nx_widestr(" ") .. nx_widestr(content)
    end
  end
  form.mltbox_log.NoFrame = false
  form.mltbox_log.ReadOnly = true
  form.mltbox_log.Solid = false
  form.mltbox_log.BackColor = "0,255,255,255"
  form.mltbox_log.Font = "font_sns_main_2"
  if nx_int(log_type) == nx_int(0) then
    form.mltbox_log.TextColor = "255,0,120,0"
  else
    form.mltbox_log.TextColor = "255,255,120,0"
  end
  form.mltbox_log.HtmlText = all_content
  form.mltbox_log.SelectBarColor = "0,0,0,0"
  form.mltbox_log.MouseInBarColor = "0,0,0,0"
end
function get_log_info(role1, role2, old_point, new_point, remark, log_type)
  local string_id = ""
  local info = ""
  if log_type == dkp_log_type_change_sum_score then
    string_id = "19667"
    info = format_info(string_id, nx_widestr(role1), nx_widestr(role2), nx_int(old_point), nx_int(new_point), nx_widestr(remark))
  elseif log_type == dkp_log_type_clear_all_score then
    string_id = "19679"
    info = format_info(string_id, nx_widestr(role1))
  elseif log_type == dkp_log_type_clear_score then
    string_id = "19691"
    info = format_info(string_id, nx_widestr(role1), nx_widestr(role2), nx_int(old_point), nx_int(new_point))
  elseif log_type == dkp_log_type_change_unit_score then
    local type1 = util_text("ui_guild_dkp_type_" .. nx_string(old_point))
    local type2 = util_text("ui_guild_dkp_type_" .. nx_string(new_point))
    local old_score, new_score = split_dkp_log_info(remark)
    string_id = "19668"
    info = format_info(string_id, nx_widestr(role1), nx_widestr(type1), nx_widestr(type2), nx_widestr(old_score), nx_widestr(new_score))
  else
    if log_type == dkp_log_type_calculate then
      string_id = "19680"
      info = format_info(string_id, nx_widestr(role1), nx_widestr(role2), nx_int(old_point), nx_int(new_point))
    else
    end
  end
  return info
end
function inti_cmp_dkp_type(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local guild_manager = nx_value("GuildManager")
  if not nx_is_valid(guild_manager) then
    return
  end
  local dkp_type_list = {}
  dkp_type_list = guild_manager:GetDkpTypeList()
  local lengh = table.getn(dkp_type_list)
  form.cmb_choose.DropListBox:ClearString()
  for i = 1, lengh do
    local type = dkp_type_list[i]
    form.cmb_choose.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_guild_dkp_type_" .. nx_string(i))))
    local id = nx_string(type) .. "-0"
    form.cmb_choose.DropListBox:SetTag(i - 1, nx_object(id))
  end
  form.cmb_choose.DropListBox.SelectIndex = 0
  form.cmb_choose.Text = form.cmb_choose.DropListBox:GetString(0)
  form.btn_define_one.Visible = false
  form.btn_define_two.Visible = false
end
function on_cmb_choose_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_index = combobox.DropListBox.SelectIndex
  local obj_id = combobox.DropListBox:GetTag(select_index)
  form.cmb_dkp_type = nx_int(nx_string(obj_id))
  form.cmb_choose.Text = nx_widestr(util_text("ui_guild_dkp_type_" .. nx_string(form.cmb_dkp_type)))
  form.mltbox_introduce.HtmlText = nx_widestr(util_text("ui_guild_dkp_tips_" .. nx_string(form.cmb_dkp_type)))
end
function on_textgrid_dkp_set_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.grid_dkp_type = grid:GetGridText(row, 0)
  form.cmb_dkp_type = form.grid_dkp_type
  local name = util_text("ui_guild_dkp_type_" .. nx_string(form.grid_dkp_type))
  form.cmb_choose.Text = nx_widestr(name)
  local set_score = grid:GetGridText(row, 2)
  form.fipt_set_score.Text = nx_widestr(set_score)
  form.mltbox_introduce.HtmlText = nx_widestr(util_text("ui_guild_dkp_tips_" .. nx_string(form.grid_dkp_type)))
  if nx_int(form.grid_dkp_type) == nx_int(15) then
    form.btn_define_one.Visible = true
  elseif nx_int(form.grid_dkp_type) == nx_int(16) then
    form.btn_define_two.Visible = true
  else
    form.btn_define_one.Visible = false
    form.btn_define_two.Visible = false
  end
end
function request_dkp_ste_list(rbtn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DKP_UNITSCORE_LIST))
end
function on_recv_dkp_set_list(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_dkp")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size <= 0 or size % 2 ~= 0 then
    return
  end
  local rows = size / 2
  form.textgrid_dkp_set:BeginUpdate()
  form.textgrid_dkp_set:ClearRow()
  for i = 1, rows do
    local row = form.textgrid_dkp_set:InsertRow(-1)
    local base = (i - 1) * 2
    local dkp_type = arg[base + 1]
    form.textgrid_dkp_set:SetGridText(row, 0, nx_widestr(dkp_type))
    form.textgrid_dkp_set:SetGridText(row, 1, nx_widestr(util_text("ui_guild_dkp_type_" .. nx_string(dkp_type))))
    form.textgrid_dkp_set:SetGridText(row, 2, nx_widestr(arg[base + 2]))
  end
  form.textgrid_dkp_set:EndUpdate()
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_int(form.grid_dkp_type) == nx_int(0) or nx_int(form.cmb_dkp_type) == nx_int(0) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19662"), 2)
    end
    return
  end
  local type1 = "ui_guild_dkp_type_" .. nx_string(form.grid_dkp_type)
  local type2 = "ui_guild_dkp_type_" .. nx_string(form.cmb_dkp_type)
  if not show_confirm_info("19663", nx_widestr(util_text(type1)), nx_widestr(util_text(type2)), nx_int(form.fipt_set_score.Text)) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_int(form.fipt_set_score.Text) > nx_int(100) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_UNIT_SET_SCORE), nx_int(form.grid_dkp_type), nx_int(form.cmb_dkp_type), nx_int(form.fipt_set_score.Text))
end
function show_confirm_info(tip, ...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = nx_widestr(format_info(tip, unpack(arg)))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return false
    end
  end
  return true
end
function format_info(strid, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return strid
  end
  gui.TextManager:Format_SetIDName(strid)
  for i, v in ipairs(arg) do
    gui.TextManager:Format_AddParam(v)
  end
  return gui.TextManager:Format_GetText()
end
function reset_dkp_title(form, list)
  if not nx_is_valid(form) then
    return
  end
  table_col_info = {}
  local info_table = util_split_string(nx_string(list), ";")
  local info_count = table.getn(info_table) - 1
  form.textgrid_dkp:BeginUpdate()
  for i = 1, info_count do
    local dkp_info = info_table[i]
    local type_table = util_split_string(nx_string(dkp_info), ":")
    local lengh = table.getn(type_table)
    if 3 <= lengh then
      local dkp_type = type_table[1]
      local col_no = type_table[2]
      local col_value = type_table[3]
      local title = util_text("ui_guild_dkp_type_" .. nx_string(dkp_type))
      form.textgrid_dkp:SetColTitle(nx_int(col_no), nx_widestr(title))
      local ctr_unit = form.groupbox_dkp:Find("lbl_name" .. nx_string(col_no))
      if nx_is_valid(ctr_unit) then
        ctr_unit.Text = util_text("ui_guild_dkp_type_" .. nx_string(dkp_type) .. nx_string("_1"))
      end
      table.insert(table_col_info, {
        nx_int(col_no),
        nx_int(col_value)
      })
    end
  end
  form.textgrid_dkp:EndUpdate()
end
function split_dkp_log_info(list)
  local gui = nx_value("gui")
  local old_score = ""
  local new_score = ""
  local info_table = util_split_string(nx_string(list), ":")
  local length = table.getn(info_table)
  if nx_int(length) == nx_int(2) then
    old_score = info_table[1]
    new_score = info_table[2]
  end
  return old_score, new_score
end
function on_btn_file_out_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) and nx_find_method(form_logic, "SaveGuildDKPInfo") then
    form_logic:SaveGuildDKPInfo(nx_widestr("-----------------------------------------------page:") .. nx_widestr(form.pageno) .. nx_widestr("------------------------------------------"))
  end
  local grid = form.textgrid_dkp
  local tittle = nx_widestr("  ")
  for i = 0, 6 do
    tittle = tittle .. grid:GetColTitle(i) .. nx_widestr("    ")
  end
  if nx_is_valid(form_logic) and nx_find_method(form_logic, "SaveGuildDKPInfo") then
    form_logic:SaveGuildDKPInfo(tittle)
  end
  local row_info = nx_widestr("")
  local count = grid.RowCount
  for i = 0, count - 1 do
    row_info = nx_widestr("  ") .. grid:GetGridText(i, 0) .. nx_widestr("   ") .. grid:GetGridText(i, 1) .. nx_widestr("    ") .. grid:GetGridText(i, 2) .. nx_widestr("    ") .. grid:GetGridText(i, 3) .. nx_widestr("    ") .. grid:GetGridText(i, 4) .. nx_widestr("    ") .. grid:GetGridText(i, 5) .. nx_widestr("    ") .. grid:GetGridText(i, 6) .. nx_widestr("    ")
    if nx_is_valid(form_logic) and nx_find_method(form_logic, "SaveGuildDKPInfo") then
      form_logic:SaveGuildDKPInfo(row_info)
    end
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19822"), 2)
  end
end
