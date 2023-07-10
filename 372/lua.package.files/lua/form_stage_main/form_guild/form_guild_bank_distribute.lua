require("utils")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
require("util_functions")
function main_form_init(form)
  form.Fixed = true
  form.pageno = 1
  form.page_next_ok = 1
  form.mini_active_members = 0
  form.active_member_num = 0
  form.cunrrent_siliver = 0
  form.min_active_value = 0
  form.max_chairman_wage_ratio = 0
  form.max_member_wage_ratio = 0
  form.Picture_ok = ""
  form.Picture_un = ""
  form.npcid = nil
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 68
  form.dis_data = nx_call("util_gui", "get_arraylist", "dis_data")
  Load_Ini(form)
  reset_grid_data(form)
  request_member_list(1, form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form.dis_data)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guild\\form_guild_bank_distribute", nx_null())
end
function reset_grid_data(form)
  local gui = nx_value("gui")
  form.grid_member_info:BeginUpdate()
  form.grid_member_info.ColCount = 5
  form.grid_member_info:ClearRow()
  form.grid_member_info:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_guild_bank_distribute_name")))
  form.grid_member_info:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_guild_bank_distribute_position")))
  form.grid_member_info:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_guild_bank_distribute_active")))
  form.grid_member_info:SetColTitle(4, nx_widestr(gui.TextManager:GetText("ui_guild_bank_distribute_number")))
  form.grid_member_info:EndUpdate()
end
function on_grid_member_info_select_row(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local designer = gui.Designer
  local row = self.RowSelectIndex
  local col = self.ColSelectIndex
  local active_value = self:GetGridText(row, 3)
  if nx_int(active_value) < nx_int(form.min_active_value) then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("19330"), 0, 0)
    end
    return
  end
  if nx_int(form.cunrrent_siliver) <= nx_int(0) then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("19324"), 0, 0)
    end
    return
  end
  local ctrl = nx_null()
  ctrl = gui:Create("Edit")
  ctrl.Font = "GE_FONT"
  ctrl.Text = self:GetGridText(row, 4)
  ctrl.OnlyDigit = true
  ctrl.MaxLength = 3
  ctrl.ChangedEvent = true
  nx_bind_script(ctrl, nx_current())
  self:SetGridControl(row, 4, ctrl)
  gui.Focused = ctrl
  return 1
end
function distuibute_edit_change(self)
  local form = self.ParentForm
  if nx_int(form.cunrrent_siliver) <= nx_int(0) then
    return
  end
  if nx_int(form.cunrrent_siliver) >= nx_int(self.Text) then
    form.cunrrent_siliver = nx_int(form.cunrrent_siliver) - nx_int(self.Text)
    form.lbl_current_siliver:AddHtmlText(nx_widestr(nx_string(form.cunrrent_siliver) .. "<img src=\"gui\\common\\money\\liang.png\" valign=\"center\" only=\"line\" data=\"\" />"), -1)
  end
end
function on_btn_distribute_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if is_captain() == 0 then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("19320"), 0, 0)
    end
    return
  end
  if form.mini_active_members > form.active_member_num then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("19321"), 0, 0)
    end
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_guild_bank_distribute_info8", name)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    add_distribute_data(form)
    local dis_data = form.dis_data
    local count = dis_data:GetChildCount()
    if count == 0 then
      local form_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_logic) then
        form_logic:AddSystemInfo(util_text("19328"), 0, 0)
      end
      return
    end
    send_request_distribute(form)
    request_member_list(1, form)
  end
end
function on_btn_cancle_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_guild_bank_distribute_info7", name)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    local dis_data = form.dis_data
    dis_data:ClearChild()
    local main_form = nx_value("form_stage_main\\form_guild\\form_guild_bank")
    if nx_is_valid(main_form) then
      main_form:Close()
    end
  end
end
function on_btn_help_click(btn)
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.pageno > 1 then
    request_member_list(form.pageno - 1, form)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    if is_captain() == 0 then
      return 0
    end
    add_distribute_data(form)
    request_member_list(form.pageno + 1, form)
  end
end
function request_member_list(pageno, form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_DISTRIBUTE_LIST), form.npcid, from, to)
end
function add_distribute_data(form)
  if not nx_is_valid(form) then
    return 0
  end
  local grid = form.grid_member_info
  local ctrl = nx_null()
  for i = 0, 9 do
    ctrl = grid:GetGridControl(i, 4)
    if nx_is_valid(ctrl) then
      local dis_data = form.dis_data
      local name = grid:GetGridText(i, 1)
      local dis_bum = ctrl.Text
      if dis_data:FindChild(nx_string(name)) then
        local child = dis_data:GetChild(nx_string(name))
        child.dis_num = dis_bum
      else
        local child = dis_data:CreateChild(nx_string(name))
        if nx_is_valid(child) then
          child.name = nx_widestr(name)
          child.dis_num = dis_bum
        end
      end
    end
  end
end
function send_request_distribute(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local dis_data = form.dis_data
  local count = dis_data:GetChildCount()
  if nx_int(count) == nx_int(0) then
    return 0
  end
  for i = 0, count do
    local child = dis_data:GetChildByIndex(i)
    if nx_is_valid(child) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_DISTRIBUTE), form.npcid, nx_int(i + 1), nx_int(count), nx_widestr(child.name), nx_int(child.dis_num))
    end
  end
end
function on_recv_member_list(all_member_num, active_member_num, current_siliver_num, from, to, ...)
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_distribute")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size < 0 or size % 3 ~= 0 then
    return 0
  end
  if from < 0 then
    form.page_next_ok = 0
    return 0
  end
  form.active_member_num = active_member_num
  form.cunrrent_siliver = current_siliver_num
  form.lbl_active_num.Text = nx_widestr(active_member_num) .. nx_widestr("/") .. nx_widestr(all_member_num)
  form.lbl_current_siliver:AddHtmlText(nx_widestr(nx_string(current_siliver_num) .. "<img src=\"gui\\common\\money\\liang.png\" valign=\"center\" only=\"line\" data=\"\" />"), -1)
  form.page_next_ok = 1
  form.pageno = from / 10 + 1
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(all_member_num / 10))
  form.lbl_line.Text = nx_widestr(nowpage .. maxpage)
  local rows = size / 3
  if 10 < rows then
    rows = 10
  end
  form.grid_member_info:BeginUpdate()
  form.grid_member_info:ClearRow()
  for i = 1, rows do
    local base = (i - 1) * 3
    local row = form.grid_member_info:InsertRow(-1)
    form.grid_member_info:SetGridText(row, 1, nx_widestr(arg[base + 1]))
    if is_default_name(arg[base + 2]) then
      form.grid_member_info:SetGridText(row, 2, nx_widestr(util_text(nx_string(arg[base + 2]))))
    else
      form.grid_member_info:SetGridText(row, 2, nx_widestr(arg[base + 2]))
    end
    form.grid_member_info:SetGridText(row, 3, nx_widestr(arg[base + 3]))
    local gui = nx_value("gui")
    local designer = gui.Designer
    local ctrl_picture = nx_null()
    ctrl_picture = gui:Create("Picture")
    ctrl_picture.NoFrame = true
    if nx_int(arg[base + 3]) >= nx_int(form.min_active_value) then
      ctrl_picture.Image = form.Picture_ok
    else
      ctrl_picture.Image = form.Picture_un
    end
    form.grid_member_info:SetGridControl(row, 0, ctrl_picture)
  end
  form.grid_member_info:EndUpdate()
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
function is_captain()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_captain = client_player:QueryProp("IsGuildCaptain")
  if is_captain ~= nx_int(2) then
    return 0
  end
  return 1
end
function Load_Ini(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "..\\Res\\share\\Guild\\GuildBankMoney\\guild_bank.ini")
  if nx_is_valid(ini) then
    local sec_count = ini:GetSectionCount()
    if sec_count == 0 then
      return
    end
    form.mini_active_members = ini:ReadInteger(0, "mini_active_members", 0)
    form.min_active_value = ini:ReadInteger(nx_string(0), "mini_active_hours", 0)
    form.max_chairman_wage_ratio = ini:ReadFloat(nx_string(0), "max_chairman_wage_ratio", 0)
    form.max_member_wage_ratio = ini:ReadFloat(nx_string(0), "max_member_wage_ratio", 0)
    form.Picture_ok = ini:ReadString(nx_string(0), "picture_ok", "")
    form.Picture_un = ini:ReadString(nx_string(0), "picture_un", "")
  else
    nx_log("..\\Res\\share\\Guild\\GuildBankMoney\\guild_bank.ini " .. get_msg_str("msg_120"))
  end
end
