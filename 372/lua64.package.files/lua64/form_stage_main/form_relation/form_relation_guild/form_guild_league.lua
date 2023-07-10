require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local SUB_CUSTOMMSG_REQUEST_LEAGUE_GUILD = 38
local SUB_CUSTOMMSG_OFF_GUILD_LEAGUE = 41
local SUB_CUSTOMMSG_OFF_GUILD_ENEMY = 42
local SUB_CUSTOMMSG_ADD_GUILD_ENEMY = 43
local SUB_CUSTOMMSG_REQUEST_LEAGUE_INFO = 46
local SUB_CUSTOMMSG_GUILD_CREATE_LEAGUE = 104
local SUB_CUSTOMMSG_GUILD_INVITE_LEAGUE = 105
local SUB_CUSTOMMSG_GUILD_ADD_TO_LEAGUE = 106
local SUB_CUSTOMMSG_GUILD_KICK_OUT_LEAGUE = 107
local SUB_CUSTOMMSG_GUILD_LEAVE_LEAGUE = 108
local SUB_CUSTOMMSG_GUILD_DISSMISS_LEAGUE = 109
function main_form_init(form)
  form.Fixed = true
  return true
end
function on_main_form_open(form)
  reset_grid_data(form)
  request_league_guild_list()
  request_enemy_guild_list()
  set_btn_visible(form)
  return 1
end
function on_main_form_close(form)
  return 1
end
function reset_grid_data(form)
  local gui = nx_value("gui")
  form.textgrid_league:BeginUpdate()
  form.textgrid_league.ColCount = 2
  form.textgrid_league:ClearRow()
  form.textgrid_league:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_guild_league_2")))
  form.textgrid_league:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_guild_league_3")))
  form.textgrid_league:EndUpdate()
  form.textgrid_enemy:BeginUpdate()
  form.textgrid_enemy.ColCount = 2
  form.textgrid_enemy:ClearRow()
  form.textgrid_enemy:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_FormBangPai")))
  form.textgrid_enemy:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_guild_enemy_time")))
  form.textgrid_enemy:EndUpdate()
end
function request_league_guild_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(1014), nx_int(39))
end
function request_enemy_guild_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(1014), nx_int(40))
end
function show_league_guild_list(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_league")
  if not nx_is_valid(form) then
    return false
  end
  form.textgrid_league:ClearRow()
  local size = table.getn(arg)
  if size <= 0 or size % 2 ~= 0 then
    return false
  end
  local rows = size / 2
  for i = 1, rows do
    local index = (i - 1) * 2
    local row = form.textgrid_league:InsertRow(-1)
    local guild_name = arg[index + 1]
    local op_time = arg[index + 2]
    if index == 0 then
      local text = util_format_string("ui_guild_league_leader")
      form.textgrid_league:SetGridText(row, 0, nx_widestr(text))
      form.textgrid_league:SetGridText(row, 1, nx_widestr(guild_name))
    else
      local text = util_format_string("ui_guild_league_member")
      form.textgrid_league:SetGridText(row, 0, nx_widestr(text))
      form.textgrid_league:SetGridText(row, 1, nx_widestr(guild_name))
    end
    form.textgrid_league:SetRowTitle(row, nx_widestr(guild_name))
  end
end
function show_enemy_guild_list(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_league")
  if not nx_is_valid(form) then
    return false
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "GuildEnemyList", 0, " ")
  form.textgrid_enemy:ClearRow()
  local size = table.getn(arg)
  if size <= 0 or size % 2 ~= 0 then
    return false
  end
  local rows = size / 2
  for i = 1, rows do
    local index = (i - 1) * 2
    local row = form.textgrid_enemy:InsertRow(-1)
    local guild_name = arg[index + 1]
    local op_time = arg[index + 2]
    form.textgrid_enemy:SetGridText(row, 0, nx_widestr(guild_name))
    form.textgrid_enemy:SetGridText(row, 1, nx_widestr(op_time))
    form.textgrid_enemy:SetRowTitle(row, nx_widestr(guild_name))
    nx_execute("form_stage_main\\form_main\\form_main_map", "GuildEnemyList", 1, nx_widestr(guild_name))
  end
end
function on_btn_over_league_click(btn)
  local form = btn.ParentForm
  local grid = form.textgrid_league
  local row = grid.RowSelectIndex
  local guild_name = nx_widestr(grid:GetRowTitle(row))
  if guild_name == nil or guild_name == "" or guild_name == 0 then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(1014), nx_int(SUB_CUSTOMMSG_OFF_GUILD_LEAGUE), nx_widestr(guild_name))
  return true
end
function on_btn_over_enemy_click(btn)
  local form = btn.ParentForm
  local grid = form.textgrid_enemy
  local row = grid.RowSelectIndex
  local guild_name = nx_widestr(grid:GetRowTitle(row))
  if guild_name == nil or guild_name == "" or guild_name == 0 then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(1014), nx_int(SUB_CUSTOMMSG_OFF_GUILD_ENEMY), nx_widestr(guild_name))
  nx_execute("form_stage_main\\form_main\\form_main_map", "GuildEnemyList", 2, nx_widestr(guild_name))
  return true
end
function on_btn_league_click(btn)
  local form = btn.ParentForm
  local ipt = form.ipt_guild
  local guild_name = ipt.Text
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(1014), nx_int(SUB_CUSTOMMSG_REQUEST_LEAGUE_GUILD), nx_widestr(guild_name))
  return true
end
function on_btn_enemy_click(btn)
  local form = btn.ParentForm
  local ipt = form.ipt_guild
  local guild_name = ipt.Text
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(1014), nx_int(SUB_CUSTOMMSG_ADD_GUILD_ENEMY), nx_widestr(guild_name))
  return true
end
function on_grid_league_select_row(grid, row)
  local gui = nx_value("gui")
  local guild_name = nx_string(grid:GetGridText(row, 1))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(1014), nx_int(SUB_CUSTOMMSG_REQUEST_LEAGUE_INFO), nx_widestr(guild_name))
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_league")
  if not nx_is_valid(form) then
    return false
  end
  form.redit_guild_name.Text = nx_widestr(guild_name)
  return true
end
function on_grid_enemy_select_row(grid, row)
  local gui = nx_value("gui")
  local guild_name = nx_string(grid:GetGridText(row, 0))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(1014), nx_int(SUB_CUSTOMMSG_REQUEST_LEAGUE_INFO), nx_widestr(guild_name))
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_league")
  if not nx_is_valid(form) then
    return false
  end
  form.redit_guild_name.Text = nx_widestr(guild_name)
end
function on_btn_create_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local text = gui.TextManager:GetFormatText("ui_guild_league_8", nx_widestr(guild_name))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_CREATE_LEAGUE))
  end
  return true
end
function on_btn_invite_league_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local ipt = form.ipt_guild
  local guild_name = ipt.Text
  local text = gui.TextManager:GetFormatText("ui_guild_ally_confirm", nx_widestr(guild_name))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_INVITE_LEAGUE), nx_widestr(guild_name))
  end
  return true
end
function on_btn_kickout_league_click(btn)
  local form = btn.ParentForm
  local grid = form.textgrid_league
  local row = grid.RowSelectIndex
  local guild_name = nx_widestr(grid:GetRowTitle(row))
  if guild_name == nil or guild_name == "" or guild_name == 0 then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_KICK_OUT_LEAGUE), nx_widestr(guild_name))
  return true
end
function on_btn_leave_league_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local text = gui.TextManager:GetFormatText("ui_guild_league_7")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_LEAVE_LEAGUE))
  end
  return true
end
function on_btn_dismiss_league_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local text = gui.TextManager:GetFormatText("ui_guild_league_6")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_DISSMISS_LEAGUE))
  end
  return true
end
function get_league_guild_info(logo, purpose, ...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_league")
  if not nx_is_valid(form) then
    return false
  end
  form.pic_frame.Image = ""
  form.pic_guild_logo.Image = "gui\\guild\\formback\\bg_logo.png"
  form.groupbox_logo.BackColor = "0,255,255,255"
  local logo_info = util_split_string(logo, "#")
  if table.getn(logo_info) == 3 then
    form.pic_frame.Image = "gui\\guild\\frame\\" .. logo_info[1]
    form.pic_guild_logo.Image = "gui\\guild\\logo\\" .. logo_info[2]
    form.groupbox_logo.BackColor = logo_info[3]
  end
  if nx_ws_length(nx_widestr(purpose)) <= 0 then
    form.mltbox_guild_purpose.HtmlText = nx_widestr(guild_util_get_text("ui_None"))
  else
    form.mltbox_guild_purpose.HtmlText = nx_widestr(purpose)
  end
  form.listbox_guild_league:ClearString()
  local size = table.getn(arg)
  if size <= 0 then
    form.listbox_guild_league:AddString(gui.TextManager:GetFormatText("ui_guild_alliance_none"))
    return false
  end
  for i = 1, size do
    local guild_name = arg[i]
    form.listbox_guild_league:AddString(guild_name)
  end
  return true
end
function set_btn_visible(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("GuildLeagueName") then
    local guild_league = client_player:QueryProp("GuildLeagueName")
    local guild_name = client_player:QueryProp("GuildName")
    if guild_league == nx_widestr("") then
      form.btn_create.Visible = true
      form.btn_dissmiss.Visible = false
      form.btn_kickout.Visible = false
      form.btn_over_league.Visible = false
    elseif nx_widestr(guild_name) ~= nx_widestr(guild_league) then
      form.btn_create.Visible = false
      form.btn_dissmiss.Visible = false
      form.btn_kickout.Visible = false
      form.btn_over_league.Visible = true
    else
      form.btn_create.Visible = false
      form.btn_dissmiss.Visible = true
      form.btn_kickout.Visible = true
      form.btn_over_league.Visible = false
    end
  else
    form.btn_create.Visible = true
    form.btn_dissmiss.Visible = false
    form.btn_kickout.Visible = false
    form.btn_over_league.Visible = false
  end
end
