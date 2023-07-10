require("share\\client_custom_define")
require("form_stage_main\\form_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
function main_form_init(form)
  form.Fixed = false
  form.npcid = nil
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 68
  reset_grid_data(form)
  requery_bank_event_list(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guild\\form_guild_bank_event", nx_null())
end
function reset_grid_data(form)
  local gui = nx_value("gui")
  form.grid_style_info:BeginUpdate()
  form.grid_style_info.ColCount = 2
  form.grid_style_info:ClearRow()
  form.textgrid_event.ColCount = 2
  form.textgrid_event:ClearRow()
  form.grid_style_info:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_guild_bank_event_time")))
  form.grid_style_info:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_guild_bank_event_papers")))
  form.textgrid_event:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_guild_bank_event_content")))
  form.textgrid_event:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_guild_bank_event_number")))
  form.grid_style_info:EndUpdate()
end
function requery_bank_event_list(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_SETTLEMENT_LIST), form.npcid)
end
function requery_bank_eventdetail_list(form, settlement_date)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_BANKEVENT_LIST), form.npcid, nx_string(settlement_date))
end
function on_grid_style_info_select_row(grid)
  local form = grid.ParentForm
  local grid = form.grid_style_info
  local row = grid.RowSelectIndex
  local settlement_date = grid:GetGridText(row, 0)
  requery_bank_eventdetail_list(form, settlement_date)
end
function on_get_guildbank_seetlement_list(...)
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_event")
  local size = table.getn(arg)
  if size < 1 then
    return 0
  end
  local rows = arg[1]
  if rows < 1 then
    form.grid_style_info:ClearRow()
    return 0
  end
  form.grid_style_info:BeginUpdate()
  form.grid_style_info:ClearRow()
  for i = 1, rows do
    local base = (i - 1) * 2
    local row = form.grid_style_info:InsertRow(-1)
    form.grid_style_info:SetGridText(row, 0, nx_widestr(arg[base + 2]))
    form.grid_style_info:SetGridText(row, 1, nx_widestr(arg[base + 3]))
  end
  form.grid_style_info:EndUpdate()
end
function on_get_guildbank_event_list(...)
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank_event")
  local size = table.getn(arg)
  if size < 1 then
    return 0
  end
  local rows = arg[1]
  if rows < 1 then
    form.textgrid_event:ClearRow()
    return 0
  end
  form.textgrid_event:BeginUpdate()
  form.textgrid_event:ClearRow()
  for i = 1, rows do
    local base = (i - 1) * 3
    local row = form.textgrid_event:InsertRow(-1)
    local desc = get_type_dec(arg[base + 2])
    form.textgrid_event:SetGridText(row, 0, nx_widestr(desc) .. nx_widestr(arg[base + 3]))
    form.textgrid_event:SetGridText(row, 1, nx_widestr(arg[base + 4]))
  end
  form.grid_style_info:EndUpdate()
end
function get_type_dec(type)
  local desc = ""
  local gui = nx_value("gui")
  if type == 0 then
    desc = nx_widestr(gui.TextManager:GetText("ui_guildbank_info1"))
  elseif type == 1 then
    desc = nx_widestr(gui.TextManager:GetText("ui_guildbank_info2"))
  elseif type == 2 then
    desc = nx_widestr(gui.TextManager:GetText("ui_guildbank_info3"))
  end
  return desc
end
