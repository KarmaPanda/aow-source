require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local CLIENT_CUSTOMMSG_GUILD_WAR = 8
local CLIENT_SUBMSG_JOIN_WAR = 29
local CLIENT_SUBMSG_CANCEL_JOIN_WAR = 30
local CLIENT_SUBMSG_GET_JOIN_LIST = 31
local CLIENT_SUBMSG_REQUEST_MEMBER_LIST = 32
local CLIENT_SUBMSG_REQUEST_ONLINE_MEMBER_LIST = 33
local CLIENT_SUBMSG_REFRESH_DOMAIN_LIST = 34
local CLIENT_SUBMSG_GUILD_FIND_GUILD_MEMBER = 42
local CLIENT_SUBMSG_SEARCH_GUILD_JOIN_WAR_MEMBER = 44
local GUILD_MEM_OFFLINE = 0
local GUILD_MEM_ONLINE = 1
local temp_add_table = {}
local temp_delete_table = {}
local domain_list = {}
function main_form_init(self)
  self.Fixed = false
  self.pageno = 1
  self.page_next_ok = 1
  self.domainID = 0
  self.pageno2 = 1
  self.page_next_ok2 = 1
  self.is_offline = 0
end
function on_main_form_open(self)
  local width = self.textgrid_2.Width
  self.textgrid_2:SetColWidth(0, width * 0.1388888888888889)
  self.textgrid_2:SetColWidth(1, width * 0.2777777777777778)
  self.textgrid_2:SetColWidth(2, width * 0.2777777777777778)
  self.textgrid_2:SetColWidth(3, width * 0.2777777777777778)
  self.textgrid_2:SetColTitle(0, nx_widestr(util_text("")))
  self.textgrid_2:SetColTitle(1, nx_widestr(util_text("ui_guild_player_name")))
  self.textgrid_2:SetColTitle(2, nx_widestr(util_text("ui_guild_position")))
  self.textgrid_2:SetColTitle(3, nx_widestr(util_text("ui_guild_power")))
  local width = self.grid_join.Width
  self.grid_join:SetColWidth(0, width * 0.1388888888888889)
  self.grid_join:SetColWidth(1, width * 0.2777777777777778)
  self.grid_join:SetColWidth(2, width * 0.2777777777777778)
  self.grid_join:SetColTitle(0, nx_widestr(util_text("")))
  self.grid_join:SetColTitle(1, nx_widestr(util_text("ui_guild_player_name")))
  self.grid_join:SetColTitle(2, nx_widestr(util_text("ui_guild_power")))
  temp_add_table = {}
  request_domain_list()
  request_online_member_list(self.pageno)
end
function on_main_form_close(form)
  form:Close()
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  send_add_member_list()
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
  if 0 < form.page_next_ok then
    if form.cbtn_base.Checked then
      request_member_list(form.pageno + 1)
    else
      request_online_member_list(form.pageno + 1)
    end
  end
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
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUEST_MEMBER_LIST), nx_int(from), nx_int(to))
end
function request_online_member_list(pageno)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUEST_ONLINE_MEMBER_LIST), nx_int(from), nx_int(to))
end
function create_cbtn(form, grid, row, PlayerName, ctbtn_name, call_back_name)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  local cbtn = form:Find(ctbtn_name)
  if not nx_is_valid(cbtn) then
    cbtn = gui:Create("CheckButton")
    cbtn.BoxSize = form.cbtn_base.BoxSize
    cbtn.NormalImage = form.cbtn_base.NormalImage
    cbtn.FocusImage = form.cbtn_base.FocusImage
    cbtn.CheckedImage = form.cbtn_base.CheckedImage
    cbtn.DisableImage = form.cbtn_base.DisableImage
    cbtn.NormalColor = form.cbtn_base.NormalColor
    cbtn.FocusColor = form.cbtn_base.FocusColor
    cbtn.PushColor = form.cbtn_base.PushColor
    cbtn.DisableColor = form.cbtn_base.DisableColor
    cbtn.Left = form.cbtn_base.Left
    cbtn.Top = form.cbtn_base.Top
    cbtn.Width = form.cbtn_base.Width
    cbtn.Height = form.cbtn_base.Height
    cbtn.BackColor = form.cbtn_base.BackColor
    cbtn.ShadowColor = form.cbtn_base.ShadowColor
    cbtn.AutoSize = form.cbtn_base.AutoSize
    nx_bind_script(cbtn, nx_current())
    nx_callback(cbtn, "on_checked_changed", call_back_name)
  end
  if not nx_is_valid(cbtn) then
    return
  end
  cbtn.PlayerName = PlayerName
  cbtn.Name = ctbtn_name
  grid:SetGridControl(row, 0, cbtn)
end
function on_recv_member_list(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_baoming")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size <= 0 or size % 4 ~= 0 then
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
  local rows = size / 4
  if 10 < rows then
    rows = 10
  end
  local temp_online_table = {}
  local temp_offline_table = {}
  for i = 1, rows do
    local base = (i - 1) * 4
    local online_state = nx_int(arg[base + 4])
    if online_state == nx_int(GUILD_MEM_ONLINE) then
      table.insert(temp_online_table, {
        arg[base + 1],
        arg[base + 2],
        arg[base + 3]
      })
    else
      table.insert(temp_offline_table, {
        arg[base + 1],
        arg[base + 2],
        arg[base + 3]
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
  local gui = nx_value("gui")
  for i = 1, table.getn(temp_online_table) do
    local row = form.textgrid_2:InsertRow(-1)
    local player_name = temp_online_table[i][1]
    local ctbtn_name = "cbtn" .. nx_string(i)
    local grid = form.textgrid_2
    create_cbtn(form, grid, row, player_name, ctbtn_name, "on_cbtn_checked_changed")
    form.textgrid_2:SetGridText(row, 1, player_name)
    if is_default_name(temp_online_table[i][2]) then
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text(nx_string(temp_online_table[i][2]))))
    else
      form.textgrid_2:SetGridText(row, 2, nx_widestr(temp_online_table[i][2]))
    end
    form.textgrid_2:SetGridText(row, 3, nx_widestr(util_text("desc_" .. temp_online_table[i][3])))
  end
  for i = 1, table.getn(temp_offline_table) do
    local row = form.textgrid_2:InsertRow(-1)
    local player_name = temp_offline_table[i][1]
    local ctbtn_name = "cbtn_" .. nx_string(i)
    local grid = form.textgrid_2
    create_cbtn(form, grid, row, player_name, ctbtn_name, "on_cbtn_checked_changed")
    form.textgrid_2:SetGridText(row, 1, player_name)
    if is_default_name(temp_offline_table[i][2]) then
      form.textgrid_2:SetGridText(row, 2, nx_widestr(util_text(nx_string(temp_offline_table[i][2]))))
    else
      form.textgrid_2:SetGridText(row, 2, nx_widestr(temp_offline_table[i][2]))
    end
    form.textgrid_2:SetGridText(row, 3, nx_widestr(util_text("desc_" .. temp_offline_table[i][3])))
    form.textgrid_2:SetGridForeColor(row, 0, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 1, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 2, "255,160,160,160")
    form.textgrid_2:SetGridForeColor(row, 3, "255,160,160,160")
  end
  form.textgrid_2:EndUpdate()
end
function on_cbtn_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_find_custom(cbtn, "PlayerName") then
    return
  end
  local name = cbtn.PlayerName
  if cbtn.Checked then
    local length = table.getn(temp_add_table)
    for i = 1, length do
      if nx_widestr(name) == nx_widestr(temp_add_table[i]) then
        return
      end
    end
    table.insert(temp_add_table, name)
  else
    local length = table.getn(temp_add_table)
    for i = 1, length do
      if nx_widestr(name) == nx_widestr(temp_add_table[i]) then
        table.remove(temp_add_table, i)
        return
      end
    end
  end
end
function on_cbtn_all_sel1_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    for i = 1, form.textgrid_2.RowCount do
      local cbtn = form.textgrid_2:GetGridControl(i - 1, 0)
      if nx_is_valid(cbtn) then
        cbtn.Checked = true
      end
    end
  else
    for i = 1, form.textgrid_2.RowCount do
      local cbtn = form.textgrid_2:GetGridControl(i - 1, 0)
      if nx_is_valid(cbtn) then
        cbtn.Checked = false
      end
    end
  end
end
function on_cbtn_all_select2_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    for i = 1, form.grid_join.RowCount do
      local cbtn = form.grid_join:GetGridControl(i - 1, 0)
      if nx_is_valid(cbtn) then
        cbtn.Checked = true
      end
    end
  else
    for i = 1, form.grid_join.RowCount do
      local cbtn = form.grid_join:GetGridControl(i - 1, 0)
      if nx_is_valid(cbtn) then
        cbtn.Checked = false
      end
    end
  end
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  send_add_member_list(form)
end
function send_add_member_list(form)
  if not nx_is_valid(form) then
    return
  end
  if form.domainID == 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1000301"))
    return
  end
  local length = table.getn(temp_add_table)
  if length == 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1000302"))
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_JOIN_WAR), nx_int(form.domainID), unpack(temp_add_table))
end
function request_domain_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REFRESH_DOMAIN_LIST))
end
function on_recv_domain_list(...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_baoming")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  form.combobox_domain.DropListBox:ClearString()
  domain_list = {}
  local size = table.getn(arg)
  if size <= 0 or size % 2 ~= 0 then
    return 0
  end
  local rows = size / 2
  for i = 1, rows do
    local base = (i - 1) * 2
    local domain_id = arg[base + 1]
    local max_join = arg[base + 2]
    table.insert(domain_list, {domain_id, max_join})
    form.combobox_domain.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_dipan_" .. nx_string(domain_id))))
    local id = nx_string(domain_id) .. "-0"
    form.combobox_domain.DropListBox:SetTag(i - 1, nx_object(id))
    if i == 1 then
      form.lbl_max_count.Text = nx_widestr(max_join)
    end
  end
  form.combobox_domain.DropListBox.SelectIndex = 0
  form.combobox_domain.Text = form.combobox_domain.DropListBox:GetString(0)
  local obj_id = form.combobox_domain.DropListBox:GetTag(0)
  local id = nx_string(obj_id)
  local domian_id = nx_int(id)
  form.domainID = domian_id
  request_join_list(form.domainID, form.pageno2, form.is_offline)
end
function on_combobox_domain_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local select_index = combobox.DropListBox.SelectIndex
  local obj_id = combobox.DropListBox:GetTag(select_index)
  local id = nx_string(obj_id)
  local domian_id = nx_int(id)
  form.domainID = domian_id
  if domian_id == 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1000301"))
    return
  end
  request_join_list(form.domainID, form.pageno2, form.is_offline)
  local max_join = get_max_join(form.domainID)
  form.lbl_max_count.Text = nx_widestr(max_join)
end
function get_max_join(domain_id)
  local length = table.getn(domain_list)
  local max_join = 0
  for i = 1, length do
    local id = domain_list[i][1]
    if nx_int(domain_id) == nx_int(id) then
      max_join = domain_list[i][2]
      return max_join
    end
  end
  return max_join
end
function on_ctn_offline_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.is_offline = 1
  else
    form.is_offline = 0
  end
  form.pageno2 = 1
  request_join_list(form.domainID, form.pageno2, form.is_offline)
end
function on_btn_last2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.pageno2 > 1 then
    request_join_list(form.domainID, form.pageno2 - 1, form.is_offline)
  end
end
function on_btn_next2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  request_join_list(form.domainID, form.pageno2 + 1, form.is_offline)
end
function on_rev_refresh_list(domain_id, ...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_baoming")
  if not nx_is_valid(form) then
    return 0
  end
  request_join_list(domain_id, form.pageno2, form.is_offline)
end
function request_join_list(domainID, pageno, is_offline)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  if nx_int(domainID) == nx_int(0) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_GET_JOIN_LIST), nx_int(domainID), nx_int(from), nx_int(to), nx_int(is_offline))
end
function on_recv_join_list(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_baoming")
  if not nx_is_valid(form) then
    return 0
  end
  if rowcount == 0 then
    form.grid_join:BeginUpdate()
    form.grid_join:ClearRow()
    form.grid_join:EndUpdate()
    return
  end
  local size = table.getn(arg)
  if size <= 0 or size % 3 ~= 0 then
    return 0
  end
  if from < 0 or from == to then
    form.page_next_ok2 = 0
    return 0
  end
  form.page_next_ok2 = 1
  form.pageno2 = from / 10 + 1
  local nowpage = nx_string(form.pageno2)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / 10))
  form.lbl_pageno2.Text = nx_widestr(nowpage .. maxpage)
  form.lbl_cur_count.Text = nx_widestr(rowcount)
  local rows = size / 3
  if 10 < rows then
    rows = 10
  end
  local temp_online_table = {}
  local temp_offline_table = {}
  for i = 1, rows do
    local base = (i - 1) * 3
    local online_state = nx_int(arg[base + 3])
    if online_state == nx_int(GUILD_MEM_ONLINE) then
      table.insert(temp_online_table, {
        arg[base + 1],
        arg[base + 2]
      })
    else
      table.insert(temp_offline_table, {
        arg[base + 1],
        arg[base + 2]
      })
    end
  end
  table.sort(temp_online_table, function(l, r)
    return l[1] < r[1]
  end)
  table.sort(temp_offline_table, function(l, r)
    return l[1] < r[1]
  end)
  form.grid_join:BeginUpdate()
  form.grid_join:ClearRow()
  local gui = nx_value("gui")
  for i = 1, table.getn(temp_online_table) do
    local row = form.grid_join:InsertRow(-1)
    local player_name = temp_online_table[i][1]
    local ctbtn_name = "cbtn_join_" .. nx_string(i)
    local grid = form.grid_join
    create_cbtn(form, grid, row, player_name, ctbtn_name, "on_cbtn_join_checked_changed")
    form.grid_join:SetGridText(row, 1, player_name)
    form.grid_join:SetGridText(row, 2, nx_widestr(util_text("desc_" .. temp_online_table[i][2])))
  end
  for i = 1, table.getn(temp_offline_table) do
    local row = form.grid_join:InsertRow(-1)
    local player_name = temp_offline_table[i][1]
    local ctbtn_name = "cbtn_join_off" .. nx_string(i)
    local grid = form.grid_join
    create_cbtn(form, grid, row, player_name, ctbtn_name, "on_cbtn_join_checked_changed")
    form.grid_join:SetGridText(row, 1, player_name)
    form.grid_join:SetGridText(row, 2, nx_widestr(util_text("desc_" .. temp_offline_table[i][2])))
    form.grid_join:SetGridForeColor(row, 0, "255,160,160,160")
    form.grid_join:SetGridForeColor(row, 1, "255,160,160,160")
    form.grid_join:SetGridForeColor(row, 2, "255,160,160,160")
  end
  form.grid_join:EndUpdate()
end
function on_cbtn_join_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_find_custom(cbtn, "PlayerName") then
    return
  end
  local name = cbtn.PlayerName
  local length = table.getn(temp_delete_table)
  if cbtn.Checked then
    for i = 1, length do
      if nx_widestr(name) == nx_widestr(temp_delete_table[i]) then
        return
      end
    end
    table.insert(temp_delete_table, name)
  else
    for i = 1, length do
      if nx_widestr(name) == nx_widestr(temp_delete_table[i]) then
        table.remove(temp_delete_table, i)
        return
      end
    end
  end
end
function on_btn_delete_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.domainID == 0 then
    return
  end
  local length = table.getn(temp_delete_table)
  if length == 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1000303"))
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_CANCEL_JOIN_WAR), nx_int(form.domainID), unpack(temp_delete_table))
  temp_delete_table = {}
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
function on_textgrid_2_select_row(self)
  local form = self.ParentForm
end
function on_textgrid_2_select_grid(self, row)
  local rowcount = self.RowCount
  if row > rowcount - 1 then
    self:ClearSelect()
  end
end
function on_btn_search_member1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local player_name = form.ipt_filter1.Text
  if nx_widestr(player_name) == nx_widestr("") then
    return
  end
  search_guild_member(nx_widestr(player_name))
end
function on_btn_search_member2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local player_name = form.ipt_filter2.Text
  if nx_widestr(player_name) == nx_widestr("") then
    return
  end
  form.pageno2 = 1
  search_guild_join_war_member(form.domainID, form.pageno2, form.is_offline, player_name)
end
function search_guild_member(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_GUILD_FIND_GUILD_MEMBER), 0, 10, player_name)
end
function search_guild_join_war_member(domainID, pageno, is_offline, player_name)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  if nx_int(domainID) == nx_int(0) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_SEARCH_GUILD_JOIN_WAR_MEMBER), nx_int(domainID), nx_int(is_offline), player_name)
end
