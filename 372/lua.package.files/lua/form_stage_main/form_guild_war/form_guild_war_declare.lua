require("util_functions")
local CLIENT_CUSTOMMSG_GUILD_WAR = 8
local CLIENT_SUBMSG_REQUIRE_DECLARE_GUILD_LIST = 0
local CLIENT_SUBMSG_REQUIRE_DECLARE_WAR = 1
local CLIENT_SUBMSG_CHECK_CAN_DECLARE = 22
local MAX_INFO_COUNT_PER_PAGE = 10
function main_form_init(form)
  form.Fixed = false
  form.npcid = ""
  form.pageno = 1
  form.page_next_ok = 1
  return true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  reset_grid_data(form)
  request_guild_list(1, form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_main_form_close(form)
  nx_execute("util_gui", "ui_destroy_attached_form", form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guild_war\\form_guild_war_declare", nx_null())
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function reset_grid_data(form)
  local gui = nx_value("gui")
  form.textgrid_list:BeginUpdate()
  form.textgrid_list.ColCount = 4
  form.textgrid_list:ClearRow()
  form.textgrid_list:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_dipan_name")))
  form.textgrid_list:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_FormBangPai")))
  form.textgrid_list:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_Status")))
  form.textgrid_list:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_avoidwar_time")))
  form.textgrid_list:EndUpdate()
end
function on_btn_declare_click(btn)
  local form = btn.ParentForm
  local grid = form.textgrid_list
  local row = grid.RowSelectIndex
  local domain_id = nx_int(grid:GetRowTitle(row))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUIRE_DECLARE_WAR), nx_int(domain_id), form.npcid)
end
function on_textgrid_list_select_row(grid, row)
  local domain_id = nx_int(grid:GetRowTitle(row))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_CHECK_CAN_DECLARE), nx_int(domain_id))
end
function on_btn_last_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.pageno > 1 then
    request_guild_list(form.pageno - 1, form)
  end
end
function on_btn_next_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    request_guild_list(form.pageno + 1, form)
  end
end
function request_guild_list(pageno, form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local from = (nx_int(pageno) - 1) * MAX_INFO_COUNT_PER_PAGE
  local to = pageno * MAX_INFO_COUNT_PER_PAGE
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUIRE_DECLARE_GUILD_LIST), form.npcid, from, to)
end
function on_recv_guild_list(npc, from, to, ...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_declare")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size < 0 or size % 4 ~= 0 then
    return 0
  end
  if from < 0 then
    form.page_next_ok = 0
    return 0
  end
  form.page_next_ok = 1
  form.pageno = from / MAX_INFO_COUNT_PER_PAGE + 1
  local rows = size / 4
  if rows > MAX_INFO_COUNT_PER_PAGE then
    rows = MAX_INFO_COUNT_PER_PAGE
  end
  form.textgrid_list:BeginUpdate()
  form.textgrid_list:ClearRow()
  for i = 1, rows do
    local base = (i - 1) * 4
    local row = form.textgrid_list:InsertRow(-1)
    form.textgrid_list:SetGridText(row, 1, nx_widestr(util_text(nx_string(arg[base + 1]))))
    local domain_id = arg[base + 2]
    local name_str = "ui_dipan_" .. nx_string(domain_id)
    form.textgrid_list:SetGridText(row, 0, nx_widestr(gui.TextManager:GetText(name_str)))
    local war_state = arg[base + 3]
    local avoid_war_time = arg[base + 4]
    local remain_time = get_format_time_text(avoid_war_time)
    form.textgrid_list:SetGridText(row, 3, nx_widestr(util_text(nx_string(remain_time))))
    local ctrl = gui:Create("Label")
    ctrl.AutoSize = true
    if nx_int(avoid_war_time) > nx_int(0) then
      ctrl.BackImage = "gui\\guild\\guildwar\\mianzhan.png"
      ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_avoidwar"))
      ctrl.Transparent = false
    elseif nx_int(war_state) == nx_int(0) then
      ctrl.BackImage = "gui\\guild\\guildwar\\armistice.png"
      ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_armistice"))
      ctrl.Transparent = false
    elseif nx_int(war_state) == nx_int(1) then
      ctrl.BackImage = "gui\\guild\\guildwar\\battle.png"
      ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_battle"))
      ctrl.Transparent = false
    end
    form.textgrid_list:SetGridControl(row, 2, ctrl)
    form.textgrid_list:SetRowTitle(row, nx_widestr(domain_id))
  end
  form.textgrid_list:EndUpdate()
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
