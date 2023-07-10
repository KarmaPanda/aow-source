require("util_gui")
local FORM_NAME = "form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_h"
local self_color = "255\163\172255\163\172204\163\1720"
function on_main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.textgrid_1:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_csw_guild_1")))
  self.textgrid_1:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_csw_guild_2")))
  self.textgrid_1:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_csw_guild_3")))
  self.textgrid_1:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_csw_guild_4")))
  self.textgrid_1:SetColTitle(4, nx_widestr(gui.TextManager:GetText("ui_csw_guild_5")))
  self.textgrid_1:SetColTitle(5, nx_widestr(gui.TextManager:GetText("ui_csw_guild_6")))
  self.textgrid_1:SetColTitle(6, nx_widestr(gui.TextManager:GetText("ui_csw_guild_7")))
  self.textgrid_2:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_csw_rank_1")))
  self.textgrid_2:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_csw_rank_2")))
  self.textgrid_2:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_csw_rank_3")))
  self.textgrid_2:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_csw_rank_4")))
  self.textgrid_2:SetColTitle(4, nx_widestr(gui.TextManager:GetText("ui_csw_rank_5")))
  self.textgrid_2:SetColTitle(5, nx_widestr(gui.TextManager:GetText("ui_csw_rank_6")))
  self.rbtn_1.Checked = true
  nx_execute("custom_sender", "custom_corss_station_war", 6)
  nx_execute("custom_sender", "custom_corss_station_war", 7)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function open_or_hide()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
  else
    form:Close()
  end
end
function open_form(index)
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
    if index == 1 then
      form.rbtn_1.Checked = true
    elseif index == 2 then
      form.rbtn_2.Checked = true
    end
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = true
    form.gb_2.Visible = false
    if form.gb_menu.Visible then
      form.gb_menu.Visible = false
    end
  end
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = true
    if form.gb_menu.Visible then
      form.gb_menu.Visible = false
    end
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_cancel_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_cross_station_war_005"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  nx_execute("custom_sender", "custom_corss_station_war", 5)
end
function on_textgrid_1_right_select_grid(self, row, col)
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
    form.gb_menu.Visible = false
    return false
  end
  if playername == "" or row < 0 then
    form.gb_menu.Visible = false
    self:ClearSelect()
    return false
  end
  if form.gb_menu.Visible then
    form.gb_menu.Visible = false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local x, y = gui:GetCursorPosition()
  if x + form.gb_menu.Width > form.AbsLeft + form.Width - 30 then
    form.gb_menu.AbsLeft = x - form.gb_menu.Width
  else
    form.gb_menu.AbsLeft = x
  end
  if y + form.gb_menu.Height > form.textgrid_2.AbsTop + form.textgrid_2.Height then
    form.gb_menu.AbsTop = y - form.gb_menu.Height
  else
    form.gb_menu.AbsTop = y
  end
  form.gb_menu.Visible = true
  form.sender_name = playername
  return true
end
function on_textgrid_1_select_row(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.gb_menu.Visible then
    form.gb_menu.Visible = false
  end
  return true
end
function on_textgrid_1_select_grid(self, row)
  local rowcount = self.RowCount
  if row > rowcount - 1 then
    self:ClearSelect()
  end
  return true
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  form.gb_menu.Visible = false
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.sender_name))
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  form.gb_menu.Visible = false
  nx_execute("custom_sender", "custom_team_invite", nx_string(form.sender_name))
end
function on_btn_3_click(btn)
  local form = btn.ParentForm
  form.gb_menu.Visible = false
  nx_execute("custom_sender", "custom_send_get_player_game_info", nx_widestr(form.sender_name))
end
function update_guild_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  form.textgrid_1:ClearRow()
  local tab = {}
  for i = 1, count do
    local member_list = util_split_wstring(arg[i], ",")
    local member_name = nx_widestr(member_list[1])
    local member_pos = nx_widestr(member_list[2])
    local member_school = nx_widestr(member_list[3])
    local member_power = nx_widestr(member_list[4])
    local kill = nx_widestr(member_list[5])
    local bekill = nx_widestr(member_list[6])
    local damage = nx_widestr(member_list[7])
    local member_force = nx_widestr(member_list[8])
    table.insert(tab, {
      member_name,
      member_pos,
      member_school,
      member_power,
      kill,
      bekill,
      damage,
      member_force
    })
  end
  table.sort(tab, function(a, b)
    if nx_number(a[5]) > nx_number(b[5]) then
      return true
    elseif nx_number(a[5]) == nx_number(b[5]) and nx_number(a[2]) < nx_number(b[2]) then
      return true
    end
    return false
  end)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  for i = 1, table.getn(tab) do
    local row = form.textgrid_1:InsertRow(-1)
    form.textgrid_1:SetGridText(row, 0, nx_widestr(tab[i][1]))
    form.textgrid_1:SetGridText(row, 1, nx_widestr(util_text(get_pos_name(tab[i][2]))))
    form.textgrid_1:SetGridText(row, 2, nx_widestr(util_text(get_school_name(tab[i][3], tab[i][8]))))
    form.textgrid_1:SetGridText(row, 3, nx_widestr(util_text("desc_" .. nx_string(tab[i][4]))))
    form.textgrid_1:SetGridText(row, 4, nx_widestr(tab[i][5]))
    form.textgrid_1:SetGridText(row, 5, nx_widestr(tab[i][6]))
    form.textgrid_1:SetGridText(row, 6, nx_widestr(tab[i][7]))
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(tab[i][1])) then
      form.textgrid_1:SetGridForeColor(row, 0, self_color)
      form.textgrid_1:SetGridForeColor(row, 1, self_color)
      form.textgrid_1:SetGridForeColor(row, 2, self_color)
      form.textgrid_1:SetGridForeColor(row, 3, self_color)
      form.textgrid_1:SetGridForeColor(row, 4, self_color)
      form.textgrid_1:SetGridForeColor(row, 5, self_color)
      form.textgrid_1:SetGridForeColor(row, 6, self_color)
    end
  end
end
function get_pos_name(pos_level)
  return "ui_guild_pos_level" .. nx_string(pos_level) .. "_name"
end
function get_school_name(school, force)
  if nx_string(school) ~= "" then
    return nx_string(school)
  elseif nx_string(force) ~= "" then
    return nx_string(force)
  else
    return "ui_None"
  end
end
function update_guild_rank(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  form.textgrid_2:ClearRow()
  local tab = {}
  for i = 1, count do
    local member_list = util_split_wstring(arg[i], ",")
    local guild_name = nx_widestr(member_list[1])
    local l1_nums = nx_widestr(member_list[2])
    local l2_nums = nx_widestr(member_list[3])
    local flag_time = nx_widestr(member_list[4])
    local score = nx_widestr(member_list[5])
    table.insert(tab, {
      guild_name,
      l1_nums,
      l2_nums,
      flag_time,
      score
    })
  end
  table.sort(tab, function(a, b)
    if nx_number(a[5]) > nx_number(b[5]) then
      return true
    end
    return false
  end)
  for i = 1, table.getn(tab) do
    local row = form.textgrid_2:InsertRow(-1)
    form.textgrid_2:SetGridText(row, 0, nx_widestr(i))
    form.textgrid_2:SetGridText(row, 1, nx_widestr(tab[i][1]))
    form.textgrid_2:SetGridText(row, 2, nx_widestr(tab[i][2]))
    form.textgrid_2:SetGridText(row, 3, nx_widestr(tab[i][3]))
    form.textgrid_2:SetGridText(row, 4, nx_widestr(tab[i][4]))
    form.textgrid_2:SetGridText(row, 5, nx_widestr(tab[i][5]))
  end
end
function a(info)
  nx_msgbox(nx_string(info))
end
