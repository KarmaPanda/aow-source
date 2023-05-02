require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local SUB_CUSTOMMSG_REQUIRE_LEAGUE_LIST = 39
local SUB_CUSTOMMSG_REQUIRE_ENEMY_LIST = 40
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
local FORM_LEAGUE = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_league"
local FORM_NAME = "form_stage_main\\form_relation\\form_relation_guild\\form_guild_list"
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  reset_grid_data(self)
  request_league_guild_list()
  request_enemy_guild_list()
  set_btn_visible(self)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function reset_grid_data(form)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_league:BeginUpdate()
  form.textgrid_league.ColCount = 2
  form.textgrid_league:ClearRow()
  form.textgrid_league:SetColTitle(0, util_text("ui_guild_league_2"))
  form.textgrid_league:SetColTitle(1, util_text("ui_guild_league_3"))
  form.textgrid_league:EndUpdate()
  form.textgrid_enemy:BeginUpdate()
  form.textgrid_enemy.ColCount = 2
  form.textgrid_enemy:ClearRow()
  form.textgrid_enemy:SetColTitle(0, util_text("ui_FormBangPai"))
  form.textgrid_enemy:SetColTitle(1, util_text("ui_guild_enemy_time"))
  form.textgrid_enemy:EndUpdate()
end
function request_league_guild_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUIRE_LEAGUE_LIST))
end
function request_enemy_guild_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUIRE_ENEMY_LIST))
end
function on_btn_over_enemy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local grid = form.textgrid_enemy
  local row = grid.RowSelectIndex
  local guild_name = nx_widestr(grid:GetRowTitle(row))
  if guild_name == nil or guild_name == nx_widestr("") or guild_name == 0 then
    local text = util_text("ui_new_guild_league_tips_2")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_OFF_GUILD_ENEMY), nx_widestr(guild_name))
  nx_execute("form_stage_main\\form_main\\form_main_map", "GuildEnemyList", 2, nx_widestr(guild_name))
  return true
end
function on_ipt_guild_right_click(self)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  self.Text = form.ipt_1.Text
end
function on_btn_guild_list_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_list", "open_form")
end
function on_btn_enemy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local ipt = form.ipt_guild
  local guild_name = ipt.Text
  if guild_name == nil or guild_name == nx_widestr("") or guild_name == 0 then
    local text = util_text("ui_new_guild_league_tips_3")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local text = gui.TextManager:GetFormatText("ui_guild_adverse_confirm", nx_widestr(guild_name))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
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
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_ADD_GUILD_ENEMY), nx_widestr(guild_name))
  end
  return true
end
function on_btn_invite_league_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local ipt = form.ipt_guild
  local guild_name = ipt.Text
  if guild_name == nil or guild_name == nx_widestr("") or guild_name == 0 then
    local text = util_text("ui_new_guild_league_tips_3")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local text = gui.TextManager:GetFormatText("ui_guild_ally_confirm", nx_widestr(guild_name))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
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
  if not nx_is_valid(form) then
    return false
  end
  local grid = form.textgrid_league
  local row = grid.RowSelectIndex
  local guild_name = nx_widestr(grid:GetRowTitle(row))
  if guild_name == nil or guild_name == nx_widestr("") or guild_name == 0 then
    local text = util_text("ui_new_guild_league_tips_1")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_KICK_OUT_LEAGUE), nx_widestr(guild_name))
  return true
end
function on_btn_dismiss_league_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_new_guild_league_tips_5"))
  dialog:ShowModal()
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
  end
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
function on_btn_leave_league_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_new_guild_league_tips_6"))
  dialog:ShowModal()
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
  end
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
function show_league_guild_list(...)
  local form = nx_value(FORM_LEAGUE)
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
  local form = nx_value(FORM_LEAGUE)
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
function set_btn_visible(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("GuildLeagueName") then
    local guild_league = client_player:QueryProp("GuildLeagueName")
    local guild_name = client_player:QueryProp("GuildName")
    if guild_league == nx_widestr("") then
      form.btn_dissmiss.Visible = false
      form.btn_kickout.Visible = false
      form.btn_over_league.Visible = false
    elseif nx_widestr(guild_name) ~= nx_widestr(guild_league) then
      form.btn_dissmiss.Visible = false
      form.btn_kickout.Visible = false
      form.btn_over_league.Visible = true
    else
      form.btn_dissmiss.Visible = true
      form.btn_kickout.Visible = true
      form.btn_over_league.Visible = false
    end
  else
    form.btn_dissmiss.Visible = false
    form.btn_kickout.Visible = false
    form.btn_over_league.Visible = false
  end
end
function on_btn_create_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_new_guild_league_tips_4"))
  dialog:ShowModal()
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
  end
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
function on_btn_league_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local ipt = form.ipt_guild
  local guild_name = ipt.Text
  if guild_name == nil or guild_name == nx_widestr("") or guild_name == 0 then
    local text = util_text("ui_new_guild_league_tips_3")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local text = gui.TextManager:GetFormatText("ui_guild_ally_confirm", nx_widestr(guild_name))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
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
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_LEAGUE_GUILD), nx_widestr(guild_name))
  end
  return true
end
function on_btn_over_league_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local grid = form.textgrid_league
  local row = grid.RowSelectIndex
  local guild_name = nx_widestr(grid:GetRowTitle(row))
  if guild_name == nil or guild_name == nx_widestr("") or guild_name == 0 then
    local text = util_text("ui_new_guild_league_tips_1")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_OFF_GUILD_LEAGUE), nx_widestr(guild_name))
  return true
end
