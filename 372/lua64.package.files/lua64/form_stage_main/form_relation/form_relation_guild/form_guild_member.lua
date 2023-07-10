require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local year_days = 365
local month_days = 30
local day_hours = 24
local school_image_list = {
  school_null = "gui\\special\\school_head\\wmp.png",
  school_emei = "gui\\special\\school_head\\em.png",
  school_jinyiwei = "gui\\special\\school_head\\jh.png",
  school_wudang = "gui\\special\\school_head\\wd.png",
  school_tangmen = "gui\\special\\school_head\\tm.png",
  school_junzitang = "gui\\special\\school_head\\jz.png",
  school_shaolin = "gui\\special\\school_head\\sl.png",
  school_gaibang = "gui\\special\\school_head\\gb.png",
  school_jilegu = "gui\\special\\school_head\\jl.png",
  force_jinzhen = "gui\\special\\HW_force_head\\jinzhen02.png",
  force_taohua = "gui\\special\\HW_force_head\\taohua02.png",
  force_wanshou = "gui\\special\\HW_force_head\\wanshou02.png",
  force_wugen = "gui\\special\\HW_force_head\\wugen02.png",
  force_xujia = "gui\\special\\HW_force_head\\xujia02.png",
  force_yihua = "gui\\special\\HW_force_head\\yihua02.png"
}
local GUILD_MEM_OFFLINE = 0
local GUILD_MEM_ONLINE = 1
local GUILD_MEM_MOBILE = 2
function main_form_init(self)
  self.Fixed = true
  self.pageno = 1
  self.page_next_ok = 1
end
function on_main_form_open(self)
  local width = self.textgrid_2.Width
  self.textgrid_2:SetColWidth(0, width * 0.16666666666666666)
  self.textgrid_2:SetColWidth(1, width * 0.17857142857142858)
  self.textgrid_2:SetColWidth(2, width * 0.08333333333333333)
  self.textgrid_2:SetColWidth(3, width * 0.09523809523809523)
  self.textgrid_2:SetColWidth(4, width * 0.3333333333333333)
  self.textgrid_2:SetColWidth(5, width * 0.14285714285714285)
  self.textgrid_2:SetColTitle(0, nx_widestr(util_text("ui_guild_player_name")))
  self.textgrid_2:SetColTitle(1, nx_widestr(util_text("ui_guild_position")))
  self.textgrid_2:SetColTitle(2, nx_widestr(util_text("ui_guild_school")))
  self.textgrid_2:SetColTitle(3, nx_widestr(util_text("ui_guild_member_force")))
  self.textgrid_2:SetColTitle(4, nx_widestr(util_text("ui_guild_power")))
  self.textgrid_2:SetColTitle(5, nx_widestr(util_text("ui_guild_last_online")))
  self.textgrid_2:SetColTitle(6, nx_widestr(util_text("ui_guild_member_contribution")))
  self.textgrid_2:SetColTitle(7, nx_widestr(util_text("ui_guildbank_distribute_info3")))
  self.sender_menu.Visible = false
  request_online_member_list(self.pageno)
  nx_set_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", self)
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
  end
  if form.pageno > 1 then
    if form.btn_online.Checked then
      request_member_list(form.pageno - 1)
    else
      request_online_member_list(form.pageno - 1)
    end
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
  end
  local self_form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member")
  if not nx_is_valid(self_form) then
    return 0
  end
  if 0 < self_form.page_next_ok then
    if form.btn_online.Checked then
      request_member_list(form.pageno + 1)
    else
      request_online_member_list(form.pageno + 1)
    end
  end
end
function on_btn_member_manage_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member_manage", "open_member_manage", nx_widestr(form.sender_name))
  end
  form.sender_menu.Visible = false
end
function on_btn_disband_click(btn)
  util_show_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_disband", true)
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
function on_btn_donate_click(btn)
  util_show_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_donate", true)
end
function on_btn_quit_click(btn)
  util_show_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_quit_confirm", true)
end
function on_btn_online_checked_changed(self)
  if self.Checked then
    request_member_list(1)
  else
    request_online_member_list(1)
  end
end
function request_member_list(pageno)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  custom_request_guild_member(from, to)
end
function request_online_member_list(pageno)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  custom_request_guild_online_member(from, to)
end
function on_recv_member_list(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member")
  if not nx_is_valid(form) then
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
  form.pageno = from / 10 + 1
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / 10))
  form.lbl_pageno.Text = nx_widestr(nowpage .. maxpage)
  local rows = size / 9
  if 10 < rows then
    rows = 10
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
    show_school_image(form.textgrid_2, row, 2, temp_online_table[i][3])
    if 0 < string.len(nx_string(temp_online_table[i][9])) then
      show_school_image(form.textgrid_2, row, 3, temp_online_table[i][9])
    else
      show_school_image(form.textgrid_2, row, 3, "school_null")
    end
    form.textgrid_2:SetGridText(row, 4, nx_widestr(util_text("desc_" .. temp_online_table[i][4])))
    if nx_int(temp_online_table[i][6]) == nx_int(GUILD_MEM_ONLINE) then
      form.textgrid_2:SetGridText(row, 5, nx_widestr(util_text("ui_guild_onlion")))
    elseif nx_int(temp_online_table[i][6]) == nx_int(GUILD_MEM_MOBILE) then
      form.textgrid_2:SetGridText(row, 5, nx_widestr(util_text("ui_sjzs_online")))
    end
    form.textgrid_2:SetGridText(row, 6, nx_widestr(temp_online_table[i][8]))
    form.textgrid_2:SetGridText(row, 7, nx_widestr(temp_online_table[i][7]))
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
    else
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text("ui_None")))
    end
    if 0 < string.len(nx_string(temp_offline_table[i][9])) then
      form.textgrid_2:SetGridText(row, 3, nx_widestr(util_text(temp_offline_table[i][9])))
    else
      form.textgrid_2:SetGridText(row, 3, nx_widestr(util_text("ui_force_none")))
    end
    form.textgrid_2:SetGridText(row, 4, nx_widestr(util_text("desc_" .. temp_offline_table[i][4])))
    form.textgrid_2:SetGridText(row, 5, nx_widestr(get_online_text(temp_offline_table[i][5])))
    form.textgrid_2:SetGridText(row, 6, nx_widestr(temp_offline_table[i][8]))
    form.textgrid_2:SetGridText(row, 7, nx_widestr(temp_offline_table[i][7]))
    form.textgrid_2:SetGridForeColor(row, 0, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 1, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 2, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 3, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 4, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 5, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 6, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 7, "255,160,160,160")
  end
  form.textgrid_2:EndUpdate()
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
function on_btn_shanrang_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_shanrang", "on_shangrang", nx_widestr(form.sender_name))
  end
  form.sender_menu.Visible = false
end
function on_btn_kick_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_kickout", "on_kickout", nx_widestr(form.sender_name))
  end
  form.sender_menu.Visible = false
end
function on_textgrid_2_right_select_grid(self, row, col)
  self:SelectRow(row)
  local form = self.ParentForm
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
    return
  end
  if playername == "" or row < 0 then
    form.sender_menu.Visible = false
    self:ClearSelect()
    return
  end
  if form.sender_menu.Visible == true then
    form.sender_menu.Visible = false
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local playername = nx_widestr(self:GetGridText(row, 0))
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
end
function on_textgrid_2_select_row(self)
  local form = self.ParentForm
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
  end
end
function on_textgrid_2_select_grid(self, row)
  local rowcount = self.RowCount
  if row > rowcount - 1 then
    self:ClearSelect()
  end
end
function on_btn_secret_chat_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.sender_name))
end
function on_btn_team_request_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_team_invite", nx_string(form.sender_name))
end
function on_btn_friend_request_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "sender_message", nx_int(1), nx_widestr(form.sender_name), nx_int(0), nx_int(-1))
end
function on_btn_add_blacklist_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  local gui = nx_value("gui")
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
end
function on_btn_mail_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
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
end
function on_rbtn_member_list_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form) then
    return
  end
  form.page_member.groupbox_member_list.Visible = true
  if nx_is_valid(form.page_candidate) then
    form.page_candidate.Visible = false
  end
end
function on_rbtn_candidate_list_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.page_candidate) then
    local page_candidate = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_candidate", true, false)
    if form:Add(page_candidate) then
      form.page_candidate = page_candidate
      form.page_candidate.Visible = false
      form.page_candidate.Fixed = true
      form.page_candidate.Left = 190
      form.page_candidate.Top = 130
    end
  end
  form:ToFront(form.page_candidate)
  form.page_member.groupbox_member_list.Visible = false
  form.page_candidate.Visible = true
  form.page_member.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_candidate", "request_candidate_list", form.page_candidate.pageno)
end
function show_school_image(grid, row, col, school)
  if nx_string(school) == nx_string("") then
    school = "school_null"
  end
  local school_image = school_image_list[nx_string(school)]
  local gui = nx_value("gui")
  local lbl = gui:Create("Label")
  lbl.AutoSize = true
  lbl.Transparent = false
  lbl.Top = 0
  lbl.Left = 8
  lbl.BackImage = school_image
  lbl.HintText = nx_widestr(gui.TextManager:GetFormatText(nx_string(school)))
  local grp = gui:Create("GroupBox")
  grp.LineColor = "0,0,0,0"
  grp.BackColor = "0,0,0,0"
  grp:Add(lbl)
  grid:SetGridControl(row, col, grp)
end
function get_online_text(dif_days)
  local online_text = ""
  local gui = nx_value("gui")
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
