require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\sub_command_define")
local GUILD_MEM_OFFLINE = 0
local GUILD_MEM_ONLINE = 1
local GUILD_MEM_MOBILE = 2
local MAX_ROWS = 12
function main_form_init(form)
  form.pageno_member = 1
  form.page_member_next_ok = 1
  form.pageno_candidate = 1
  form.page_candidate_next_ok = 1
  form.Fixed = true
end
function on_main_form_open(form)
  form.groupbox_candidate_list.Visible = false
  local width = form.textgrid_2.Width
  form.textgrid_2:SetColWidth(0, width * 0.14285714285714285)
  form.textgrid_2:SetColWidth(1, width * 0.14285714285714285)
  form.textgrid_2:SetColWidth(2, width * 0.14285714285714285)
  form.textgrid_2:SetColWidth(3, width * 0.14285714285714285)
  form.textgrid_2:SetColWidth(4, width * 0.14285714285714285)
  form.textgrid_2:SetColWidth(5, width * 0.14285714285714285)
  form.textgrid_2:SetColWidth(6, width * 0.14285714285714285)
  form.textgrid_2:SetColTitle(0, nx_widestr(util_text("ui_guild_player_name")))
  form.textgrid_2:SetColTitle(1, nx_widestr(util_text("ui_guild_position")))
  form.textgrid_2:SetColTitle(2, nx_widestr(util_text("ui_guild_school")))
  form.textgrid_2:SetColTitle(3, nx_widestr(util_text("ui_guild_power")))
  form.textgrid_2:SetColTitle(4, nx_widestr(util_text("ui_guild_last_online")))
  form.textgrid_2:SetColTitle(5, nx_widestr(util_text("ui_guild_total_score")))
  form.textgrid_2:SetColTitle(6, nx_widestr(util_text("ui_guildbank_distribute_info3")))
  request_online_member_list(form.pageno_member)
  width = form.textgrid_1.Width
  form.textgrid_1:SetColWidth(0, width / 5 - 1)
  form.textgrid_1:SetColWidth(1, width / 5 - 1)
  form.textgrid_1:SetColWidth(2, width / 5 - 1)
  form.textgrid_1:SetColWidth(3, width / 5 - 1)
  form.textgrid_1:SetColWidth(4, width / 5 - 1)
  form.textgrid_1:SetColTitle(0, nx_widestr(util_text("ui_guild_player_name")))
  form.textgrid_1:SetColTitle(1, nx_widestr(util_text("ui_guild_school")))
  form.textgrid_1:SetColTitle(2, nx_widestr(util_text("ui_guild_power")))
  form.textgrid_1:SetColTitle(3, nx_widestr(util_text("ui_guild_request_date")))
  form.textgrid_1:SetColTitle(4, nx_widestr(util_text("ui_guild_last_online")))
  request_candidate_list(form.pageno_candidate)
  request_invent_condition()
  form.groupbox_power_limit.Visible = false
  return true
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  return true
end
function on_rbtn_member_list_checked_changed(rbtn)
  if not rbtn.Checked then
    return false
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.groupbox_member_list.Visible = true
  form.groupbox_candidate_list.Visible = false
end
function on_btn_online_checked_changed(self)
  if self.Checked then
    request_member_list(1)
  else
    request_online_member_list(1)
  end
end
function on_btn_member_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
  end
  if form.pageno_member > 1 then
    if form.btn_online.Checked then
      request_member_list(form.pageno_member - 1)
    else
      request_online_member_list(form.pageno_member - 1)
    end
  end
  return true
end
function on_btn_member_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
  end
  if form.page_member_next_ok > 0 then
    if form.btn_online.Checked then
      request_member_list(form.pageno_member + 1)
    else
      request_online_member_list(form.pageno_member + 1)
    end
  end
  return true
end
function request_member_list(pageno)
  local from = (nx_int(pageno) - 1) * MAX_ROWS
  local to = pageno * MAX_ROWS
  custom_request_guild_member(from, to)
end
function request_online_member_list(pageno)
  local from = (nx_int(pageno) - 1) * MAX_ROWS
  local to = pageno * MAX_ROWS
  custom_request_guild_online_member(from, to)
end
function on_btn_invite_click(btn)
  if not btn.have_right then
    local gui = nx_value("gui")
    local text = nx_widestr(gui.TextManager:GetText("19018"))
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return
  end
  util_show_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_invite", true)
end
function on_btn_quit_click(btn)
  util_show_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_quit_confirm", true)
end
function on_textgrid_2_right_select_grid(self, row, col)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  self:SelectRow(row)
  local playername = nx_widestr(self:GetGridText(row, 0))
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return false
  end
  local role_name = game_role:QueryProp("Name")
  if playername == role_name then
    form.sender_menu.Visible = false
    return false
  end
  if playername == "" or row < 0 then
    form.sender_menu.Visible = false
    self:ClearSelect()
    return false
  end
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local x, y = gui:GetCursorPosition()
  if x + form.sender_menu.Width > form.AbsLeft + form.Width - 30 then
    form.sender_menu.AbsLeft = x - form.sender_menu.Width
  else
    form.sender_menu.AbsLeft = x
  end
  if y + form.sender_menu.Height > form.textgrid_2.AbsTop + form.textgrid_2.Height then
    form.sender_menu.AbsTop = y - form.sender_menu.Height
  else
    form.sender_menu.AbsTop = y
  end
  form.sender_menu.Visible = true
  form.sender_name = playername
  return true
end
function on_textgrid_2_select_row(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
  end
  return true
end
function on_textgrid_2_select_grid(self, row)
  local rowcount = self.RowCount
  if row > rowcount - 1 then
    self:ClearSelect()
  end
  return true
end
function on_btn_secret_chat_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.sender_name))
  return true
end
function on_btn_friend_request_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "sender_message", nx_int(1), nx_widestr(form.sender_name), nx_int(0), nx_int(-1))
  return true
end
function on_btn_add_blacklist_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = nx_widestr(gui.TextManager:GetFormatText("ui_menu_friend_modify_filter", nx_string(form.sender_name)))
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("form_stage_main\\form_relation\\form_friend_list", "sender_message", nx_int(4), nx_widestr(form.sender_name), nx_int(8), nx_int(-1))
  end
  return true
end
function on_btn_team_request_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_team_invite", nx_string(form.sender_name))
  return true
end
function on_btn_member_manage_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member_manage", "open_member_manage", nx_widestr(form.sender_name))
  return true
end
function on_btn_kick_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_kickout", "on_kickout", nx_widestr(form.sender_name))
  return true
end
function on_btn_mail_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
  local form_send = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail_send", true, false)
  if nx_is_valid(form_send) then
    form_send.targetname.Text = nx_widestr(form.sender_name)
    gui.Desktop:ToFront(form_send)
  end
  local form_bag = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_bag", true, false)
  if nx_is_valid(form_bag) then
    form_bag.Visible = true
    form_bag:Show()
    gui.Desktop:ToFront(form_bag)
  end
  return true
end
function on_btn_shanrang_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_shanrang", "on_shangrang", nx_widestr(form.sender_name))
  return true
end
function on_btn_role_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_send_get_player_game_info", nx_widestr(form.sender_name))
  return true
end
function on_btn_equip_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_role_chakan", "get_player_info", nx_widestr(form.sender_name))
  return true
end
function on_btn_binglu_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_binglu_chakan", "get_player_binglu_info", nx_widestr(form.sender_name))
  return true
end
function on_rbtn_candidate_list_checked_changed(rbtn)
  if not rbtn.Checked then
    return false
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.groupbox_member_list.Visible = false
  form.groupbox_candidate_list.Visible = true
end
function on_btn_candidate_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.pageno_candidate > 1 then
    request_candidate_list(form.pageno_candidate - 1)
  end
end
function on_btn_candidate_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.page_candidate_next_ok > 0 then
    request_candidate_list(form.pageno_candidate + 1)
  end
end
function request_candidate_list(pageno)
  local from = (nx_int(pageno) - 1) * MAX_ROWS
  local to = pageno * MAX_ROWS
  custom_request_guild_candidate(from, to)
end
function on_btn_accept_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local player_name = form.textgrid_1:GetGridText(form.textgrid_1.RowSelectIndex, 0)
  if nx_string(player_name) ~= "" then
    custom_request_accept_guild_member(player_name)
  end
  return true
end
function on_btn_reject_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local player_name = form.textgrid_1:GetGridText(form.textgrid_1.RowSelectIndex, 0)
  if nx_string(player_name) ~= "" then
    custom_request_reject_guild_member(player_name)
  end
  return true
end
function is_default_name(pos_name)
  if nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level1_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level2_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level3_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level4_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level5_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level6_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level7_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level8_name") then
    return true
  end
  return false
end
function get_online_text(dif_days)
  local online_text = ""
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return online_text
  end
  local year_days = 365
  local month_days = 30
  local day_hours = 24
  if nx_number(dif_days) < nx_number(0) then
    dif_days = 0
  end
  if nx_int(dif_days) >= nx_int(year_days) then
    local years = dif_days / year_days
    online_text = gui.TextManager:GetFormatText("ui_guild_offlion_year", nx_int(years))
  elseif nx_int(dif_days) >= nx_int(month_days) then
    local months = dif_days / month_days
    online_text = gui.TextManager:GetFormatText("ui_guild_offlion_month", nx_int(months))
  elseif nx_int(dif_days) >= nx_int(1) then
    local days = nx_int(dif_days)
    online_text = gui.TextManager:GetFormatText("ui_guild_offlion_day", nx_int(days))
  elseif nx_int(dif_days * day_hours) >= nx_int(1) then
    local hours = nx_int(dif_days * day_hours)
    online_text = gui.TextManager:GetFormatText("ui_guild_offlion_hour", nx_int(hours))
  else
    local minutes = nx_int(dif_days * day_hours * 60)
    online_text = gui.TextManager:GetFormatText("ui_guild_offlion_minute", nx_int(minutes))
  end
  return online_text
end
function transform_date(pdate)
  local text = nx_string(pdate)
  text = string.gsub(text, " ", "")
  text = string.gsub(text, "-", "/")
  text = string.gsub(text, "#", " ")
  return text
end
function custom_request_guild_member(from, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_MEMBER), nx_int(from), nx_int(to))
  return true
end
function custom_request_guild_online_member(from, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_ONLINE_MEMBER), nx_int(from), nx_int(to))
  return true
end
function custom_request_guild_candidate(from, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_CANDIDATE), nx_int(from), nx_int(to))
  return true
end
function custom_request_accept_guild_member(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_ACCEPT_GUILD_MEMBER), player_name)
  return true
end
function custom_request_reject_guild_member(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_REJECT_GUILD_MEMBER), player_name)
  return true
end
function on_recv_member_list(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_member")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local size = table.getn(arg)
  if size <= 0 or size % 9 ~= 0 then
    return 0
  end
  if from < 0 or from == to then
    form.page_next_ok = 0
    return 0
  end
  form.page_next_ok = 1
  form.pageno = from / MAX_ROWS + 1
  local nowpage = nx_string(form.pageno)
  form.pageno_member = nx_int(nowpage)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / MAX_ROWS))
  form.lbl_pageno_member.Text = nx_widestr(nowpage .. maxpage)
  local rows = size / 9
  if rows > MAX_ROWS then
    rows = MAX_ROWS
  end
  local temp_online_table = {}
  local temp_offline_table = {}
  for i = 1, rows do
    local base = (i - 1) * 9
    local online_state = nx_int(arg[base + 6])
    if online_state == nx_int(GUILD_MEM_ONLINE) or online_state == nx_int(GUILD_MEM_MOBILE) then
      table.insert(temp_online_table, {
        arg[base + 1],
        arg[base + 2],
        arg[base + 3],
        arg[base + 4],
        arg[base + 5],
        arg[base + 6],
        arg[base + 7],
        arg[base + 8],
        arg[base + 9]
      })
    else
      table.insert(temp_offline_table, {
        arg[base + 1],
        arg[base + 2],
        arg[base + 3],
        arg[base + 4],
        arg[base + 5],
        arg[base + 6],
        arg[base + 7],
        arg[base + 8],
        arg[base + 9]
      })
    end
  end
  table.sort(temp_online_table, function(l, r)
    return l[2] < r[2]
  end)
  table.sort(temp_offline_table, function(l, r)
    return l[2] < r[2]
  end)
  form.textgrid_2:BeginUpdate()
  form.textgrid_2:ClearRow()
  for i = 1, table.getn(temp_online_table) do
    local row = form.textgrid_2:InsertRow(-1)
    form.textgrid_2:SetGridText(row, 0, temp_online_table[i][1])
    if is_default_name(temp_online_table[i][2]) then
      form.textgrid_2:SetGridText(row, 1, nx_widestr(util_text(nx_string(temp_online_table[i][2]))))
    else
      form.textgrid_2:SetGridText(row, 1, nx_widestr(temp_online_table[i][2]))
    end
    if 0 < string.len(nx_string(temp_online_table[i][3])) then
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text(temp_online_table[i][3])))
    elseif 0 < string.len(nx_string(temp_online_table[i][9])) then
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text(temp_online_table[i][9])))
    else
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text("ui_None")))
    end
    form.textgrid_2:SetGridText(row, 3, nx_widestr(util_text("desc_" .. temp_online_table[i][4])))
    if nx_int(temp_online_table[i][6]) == nx_int(GUILD_MEM_ONLINE) then
      form.textgrid_2:SetGridText(row, 4, nx_widestr(util_text("ui_guild_onlion")))
    elseif nx_int(temp_online_table[i][6]) == nx_int(GUILD_MEM_MOBILE) then
      form.textgrid_2:SetGridText(row, 4, nx_widestr(util_text("ui_sjzs_online")))
    end
    local var = nx_int(temp_online_table[i][8])
    if var >= nx_int(10000) then
      form.textgrid_2:SetGridText(row, 5, gui.TextManager:GetFormatText("ui_newguildinterface_text", nx_int(var / 10000)))
    else
      form.textgrid_2:SetGridText(row, 5, nx_widestr(var))
    end
    form.textgrid_2:SetGridText(row, 6, nx_widestr(temp_online_table[i][7]))
  end
  for i = 1, table.getn(temp_offline_table) do
    local row = form.textgrid_2:InsertRow(-1)
    form.textgrid_2:SetGridText(row, 0, temp_offline_table[i][1])
    if is_default_name(temp_offline_table[i][2]) then
      form.textgrid_2:SetGridText(row, 1, nx_widestr(util_text(nx_string(temp_offline_table[i][2]))))
    else
      form.textgrid_2:SetGridText(row, 1, nx_widestr(temp_offline_table[i][2]))
    end
    if 0 < string.len(nx_string(temp_offline_table[i][3])) then
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text(temp_offline_table[i][3])))
    elseif 0 < string.len(nx_string(temp_offline_table[i][9])) then
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text(temp_offline_table[i][9])))
    else
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text("ui_None")))
    end
    form.textgrid_2:SetGridText(row, 3, nx_widestr(util_text("desc_" .. temp_offline_table[i][4])))
    form.textgrid_2:SetGridText(row, 4, nx_widestr(get_online_text(temp_offline_table[i][5])))
    local var = nx_int(temp_offline_table[i][8])
    if var >= nx_int(10000) then
      var = nx_int(var / 10000)
    end
    form.textgrid_2:SetGridText(row, 5, nx_widestr(var))
    form.textgrid_2:SetGridText(row, 6, nx_widestr(temp_offline_table[i][7]))
    form.textgrid_2:SetGridForeColor(row, 0, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 1, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 2, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 3, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 4, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 5, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 6, "255,160,160,160")
  end
  form.textgrid_2:EndUpdate()
  return true
end
function on_recv_candidate(from, to, rowcount, ...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) or table.getn(arg) % 6 ~= 0 then
    return false
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  form.textgrid_1:EndUpdate()
  if from < 0 then
    form.page_candidate_next_ok = 0
    form.lbl_pageno_candidate.Text = nx_widestr("0/0")
    return false
  end
  if rowcount <= to then
    form.page_candidate_next_ok = 0
  else
    form.page_candidate_next_ok = 1
  end
  form.pageno_candidate = from / MAX_ROWS + 1
  local nowpage = nx_string(form.pageno_candidate)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / MAX_ROWS))
  form.lbl_pageno_candidate.Text = nx_widestr(nowpage .. maxpage)
  local rows = table.getn(arg) / 6
  if rows > MAX_ROWS then
    rows = MAX_ROWS
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  for i = 1, rows do
    local base = (i - 1) * 6
    local row = form.textgrid_1:InsertRow(-1)
    form.textgrid_1:SetGridText(row, 0, nx_widestr(arg[base + 1]))
    if 0 < string.len(nx_string(arg[base + 2])) then
      form.textgrid_1:SetGridText(row, 1, nx_widestr(util_text(arg[base + 2])))
    else
      form.textgrid_1:SetGridText(row, 1, nx_widestr(util_text("ui_None")))
    end
    form.textgrid_1:SetGridText(row, 2, nx_widestr(util_text("desc_" .. arg[base + 3])))
    form.textgrid_1:SetGridText(row, 3, nx_widestr(transform_date(arg[base + 5])))
    form.textgrid_1:SetGridText(row, 4, nx_widestr(transform_date(arg[base + 6])))
    local state = nx_int(arg[base + 4])
    if state == nx_int(0) then
      form.textgrid_1:SetGridForeColor(row, 0, "255,160,160,160")
      form.textgrid_1:SetGridForeColor(row, 1, "255,160,160,160")
      form.textgrid_1:SetGridForeColor(row, 2, "255,160,160,160")
      form.textgrid_1:SetGridForeColor(row, 3, "255,160,160,160")
      form.textgrid_1:SetGridForeColor(row, 4, "255,160,160,160")
    end
  end
  form.textgrid_1:EndUpdate()
  return false
end
function on_btn_member_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
  end
  if form.pageno_member > 1 then
    if form.btn_online.Checked then
      request_member_list(form.pageno_member - 1)
    else
      request_online_member_list(form.pageno_member - 1)
    end
  end
  return true
end
function on_btn_set_power_limit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if nx_string(form.invite_ability) ~= nx_string(btn.DataSource) then
    custom_request_guild_set_suggest(nx_string(""), nx_int(btn.DataSource), nx_int(0), nx_int(0))
  end
  form.groupbox_power_limit.Visible = false
end
function on_btn_limit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form.groupbox_power_limit.Visible = not form.groupbox_power_limit.Visible
end
function request_invent_condition()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  if guild_name == "" then
    return
  end
  nx_execute("custom_sender", "custom_request_join_suggest", guild_name)
end
function on_msg(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 2 then
    return
  end
  form.invite_ability = nx_int(arg[2])
  refresh_invent_condition(form)
end
function refresh_invent_condition(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.invite_ability) < nx_int(1) then
    form.invite_ability = 1
  end
  local power_desc = "desc_title0"
  if nx_int(form.invite_ability) < nx_int(10) then
    power_desc = power_desc .. "0"
  end
  form.btn_limit.Text = nx_widestr(util_text(power_desc .. nx_string(form.invite_ability)))
end
