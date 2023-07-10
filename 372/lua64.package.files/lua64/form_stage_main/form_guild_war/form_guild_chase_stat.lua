require("util_gui")
require("share\\chat_define")
local CLIENT_CUSTOMMSG_GUILD = 1014
local SUB_CUSTOMMSG_REQUEST_GUILD_CHASE_STAT = 77
local SUB_CUSTOMMSG_REQUEST_GUILD_CHASE_SPEAKER_DATA = 78
local SUB_CUSTOMMSG_REQUEST_CLEAR_GUILD_CHASE_PUNISH = 80
local FORM_NAME = "form_stage_main\\form_guild_war\\form_guild_chase_stat"
local guild_grid_table = {
  [1] = {
    col_width_per = 3,
    col_title = "ui_escort_blackmarket_school"
  },
  [2] = {
    col_width_per = 3,
    col_title = "ui_guild_chase_relation"
  },
  [3] = {
    col_width_per = 2,
    col_title = "ui_kill_num"
  },
  [4] = {
    col_width_per = 2,
    col_title = "ui_be_killed_num"
  }
}
local player_grid_table = {
  [1] = {
    col_width_per = 4,
    col_title = "ui_escort_blackmarket_school"
  },
  [2] = {
    col_width_per = 3,
    col_title = "ui_kill_num_player"
  },
  [3] = {
    col_width_per = 3,
    col_title = "ui_be_killed_num_player"
  }
}
local player_guild_grid_table = {
  [1] = {col_width_per = 4, col_title = "ui_player"},
  [2] = {col_width_per = 3, col_title = "ui_paiming"},
  [3] = {
    col_width_per = 3,
    col_title = "ui_kill_num_player"
  }
}
local grid_per_base_num = 10
local CHASE_OTHER = 0
local BE_CHASED_BY_OTHER = 1
local PLAYER_DATA = 2
local ERROR_STAT_TYPE = 0
local GUILD_STAT_TYPE = 1
local PLAYER_STAT_TYPE = 2
local PLAYER_GUILD_STAT_TYPE = 3
local PLAYER_GUILD_ALL_STAT_TYPE = 4
local NOT_FOUND_SELF_DATA = 0
local FOUND_SELF_DATA = 1
local CHASE_SPEAKER_TYPE_ERROR = 0
local CHASE_SPEAKER_TYPE_GUILD = 1
local CHASE_SPEAKER_TYPE_PLAYER = 2
local CHASE_SPEAKER_TYPE_PLAYER_GUILD = 3
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  init_controls(form)
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.select_name = nx_widestr("")
  form.select_type = CHASE_SPEAKER_TYPE_ERROR
  form.groupbox_player.Visible = false
  form.groupbox_player_guild.Visible = false
  nx_set_value(FORM_NAME, form)
  nx_execute("util_gui", "ui_show_attached_form", form)
  request_data()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_set_value(FORM_NAME, nx_null())
  nx_destroy(form)
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
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_refresh_click(btn)
  request_data()
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_guild.Visible = false
  form.groupbox_player.Visible = false
  form.groupbox_player_guild.Visible = false
  if form.rbtn_guild.Checked then
    form.groupbox_guild.Visible = true
  elseif form.rbtn_player.Checked then
    form.groupbox_player.Visible = true
  elseif form.rbtn_player_guild.Checked then
    form.groupbox_player_guild.Visible = true
  end
  request_data()
end
function on_textgrid_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = nx_widestr(grid:GetGridText(row, 0))
  if 0 >= nx_ws_length(name) then
    return
  end
  form.select_name = name
  if nx_string(grid.Name) == nx_string("textgrid_guild") then
    form.select_type = CHASE_SPEAKER_TYPE_GUILD
    form.textgrid_player:ClearSelect()
    form.textgrid_player_guild:ClearSelect()
  elseif nx_string(grid.Name) == nx_string("textgrid_player") then
    form.select_type = CHASE_SPEAKER_TYPE_PLAYER
    form.textgrid_guild:ClearSelect()
    form.textgrid_player_guild:ClearSelect()
  elseif nx_string(grid.Name) == nx_string("textgrid_player_guild") then
    form.select_type = CHASE_SPEAKER_TYPE_PLAYER_GUILD
    form.textgrid_player:ClearSelect()
    form.textgrid_guild:ClearSelect()
  else
    form.select_name = nx_widestr("")
    form.select_type = CHASE_SPEAKER_TYPE_ERROR
    form.textgrid_guild:ClearSelect()
    form.textgrid_player:ClearSelect()
  end
end
function on_btn_speaker_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(form) or not nx_is_valid(gui) then
    return
  end
  if nx_int(form.select_type) == nx_int(CHASE_SPEAKER_TYPE_ERROR) or nx_ws_length(form.select_name) <= 0 then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text("91074")), 2)
    end
    return
  end
  local select_name = form.select_name
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_chase_speaker_confirm_" .. nx_string(form.select_type), nx_widestr(form.select_name)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_CHASE_SPEAKER_DATA), nx_int(form.select_type), nx_widestr(form.select_name))
  end
end
function on_btn_clear_punish_click(btn)
  request_clear_punish()
end
function init_controls(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local grid_guild = form.textgrid_guild
  local grid_player = form.textgrid_player
  local grid_player_gulid = form.textgrid_player_guild
  if not (nx_is_valid(grid_guild) and nx_is_valid(grid_player)) or not nx_is_valid(grid_player_gulid) then
    return
  end
  grid_guild:BeginUpdate()
  local grid_width = grid_guild.Width - 30
  grid_guild.ColCount = table.getn(guild_grid_table)
  for i = 1, table.getn(guild_grid_table) do
    grid_guild:SetColWidth(i - 1, grid_width / grid_per_base_num * nx_int(guild_grid_table[i].col_width_per))
    grid_guild:SetColTitle(i - 1, nx_widestr(util_text(nx_string(guild_grid_table[i].col_title))))
  end
  grid_guild:EndUpdate()
  grid_player:BeginUpdate()
  grid_width = grid_player.Width - 30
  grid_player.ColCount = table.getn(player_grid_table)
  for i = 1, table.getn(player_grid_table) do
    grid_player:SetColWidth(i - 1, grid_width / grid_per_base_num * nx_int(player_grid_table[i].col_width_per))
    grid_player:SetColTitle(i - 1, nx_widestr(util_text(nx_string(player_grid_table[i].col_title))))
  end
  grid_guild:EndUpdate()
  grid_player_gulid:BeginUpdate()
  grid_width = grid_player_gulid.Width - 30
  grid_player_gulid.ColCount = table.getn(player_guild_grid_table)
  for i = 1, table.getn(player_guild_grid_table) do
    grid_player_gulid:SetColWidth(i - 1, grid_width / grid_per_base_num * nx_int(player_guild_grid_table[i].col_width_per))
    grid_player_gulid:SetColTitle(i - 1, nx_widestr(util_text(nx_string(player_guild_grid_table[i].col_title))))
  end
  grid_player_gulid:EndUpdate()
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid_guild = form.textgrid_guild
  local grid_player = form.textgrid_player
  local grid_player_guild = form.textgrid_player_guild
  if not (nx_is_valid(grid_guild) and nx_is_valid(grid_player)) or not nx_is_valid(grid_player_guild) then
    return
  end
  grid_guild:BeginUpdate()
  grid_guild:ClearRow()
  grid_guild:ClearSelect()
  grid_guild:EndUpdate()
  grid_player:BeginUpdate()
  grid_player:ClearRow()
  grid_player:ClearSelect()
  grid_player:EndUpdate()
  grid_player_guild:BeginUpdate()
  grid_player_guild:ClearRow()
  grid_player_guild:ClearSelect()
  grid_player_guild:EndUpdate()
end
function request_data()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_grid(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local request_type = ERROR_STAT_TYPE
  if form.rbtn_guild.Checked then
    request_type = GUILD_STAT_TYPE
  elseif form.rbtn_player.Checked then
    request_type = PLAYER_STAT_TYPE
  elseif form.rbtn_player_guild.Checked then
    request_type = PLAYER_GUILD_STAT_TYPE
  end
  if request_type == ERROR_STAT_TYPE then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_CHASE_STAT), nx_int(request_type))
end
function request_clear_punish()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_CLEAR_GUILD_CHASE_PUNISH), nx_int(request_type))
end
function rec_guild_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  clear_grid(form)
  form.select_name = ""
  form.select_type = CHASE_SPEAKER_TYPE_ERROR
  local size = table.getn(arg)
  if size % 4 ~= 0 or size == 0 then
    return
  end
  local grid_guild = form.textgrid_guild
  if not nx_is_valid(grid_guild) then
    return
  end
  grid_guild:BeginUpdate()
  for i = 1, size / 4 do
    local temp_index = (i - 1) * 4 + 1
    local guild_name = nx_widestr(arg[temp_index])
    temp_index = temp_index + 1
    local show_type = nx_widestr(arg[temp_index])
    temp_index = temp_index + 1
    local kill_num = nx_int(arg[temp_index])
    temp_index = temp_index + 1
    local dead_num = nx_int(arg[temp_index])
    temp_index = temp_index + 1
    if nx_int(show_type) == nx_int(CHASE_OTHER) or nx_int(show_type) == nx_int(BE_CHASED_BY_OTHER) then
      local row = grid_guild:InsertRow(-1)
      grid_guild:SetGridText(row, 0, nx_widestr(guild_name))
      grid_guild:SetGridText(row, 1, nx_widestr(util_text("ui_chase_" .. nx_string(show_type))))
      grid_guild:SetGridText(row, 2, nx_widestr(kill_num))
      grid_guild:SetGridText(row, 3, nx_widestr(dead_num))
    end
  end
  grid_guild:EndUpdate()
end
function rec_player_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  clear_grid(form)
  form.select_name = ""
  form.select_type = CHASE_SPEAKER_TYPE_ERROR
  local size = table.getn(arg)
  if size % 3 ~= 0 or size == 0 then
    return
  end
  local grid_player = form.textgrid_player
  if not nx_is_valid(grid_player) then
    return
  end
  grid_player:BeginUpdate()
  for i = 1, size / 3 do
    local temp_index = (i - 1) * 3 + 1
    local guild_name = nx_widestr(arg[temp_index])
    temp_index = temp_index + 1
    local kill_num = nx_int(arg[temp_index])
    temp_index = temp_index + 1
    local dead_num = nx_int(arg[temp_index])
    temp_index = temp_index + 1
    local row = grid_player:InsertRow(-1)
    grid_player:SetGridText(row, 0, nx_widestr(guild_name))
    grid_player:SetGridText(row, 1, nx_widestr(kill_num))
    grid_player:SetGridText(row, 2, nx_widestr(dead_num))
  end
  grid_player:EndUpdate()
end
function rec_player_guild_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  clear_grid(form)
  form.select_name = ""
  form.select_type = CHASE_SPEAKER_TYPE_ERROR
  local found_self_data = arg[1]
  local size = 0
  local offset_num = 5
  if nx_int(found_self_data) == nx_int(FOUND_SELF_DATA) then
    local self_rank_no = nx_int(arg[2])
    local self_name = nx_widestr(arg[3])
    local self_kill_num = nx_int(arg[4])
    local self_dead_num = nx_int(arg[5])
    form.lbl_name.Text = nx_widestr(self_name)
    form.lbl_rank.Text = nx_widestr(self_rank_no)
    form.lbl_kill_num.Text = nx_widestr(self_kill_num)
    offset_num = 5
  else
    offset_num = 1
  end
  size = table.getn(arg) - offset_num
  local grid_player_guild = form.textgrid_player_guild
  if not nx_is_valid(grid_player_guild) then
    return
  end
  grid_player_guild:BeginUpdate()
  for i = 1, size / 4 do
    local temp_index = (i - 1) * 4 + offset_num + 1
    local rank_no = nx_int(arg[temp_index])
    temp_index = temp_index + 1
    local player_name = nx_widestr(arg[temp_index])
    temp_index = temp_index + 1
    local kill_num = nx_int(arg[temp_index])
    temp_index = temp_index + 1
    local row = grid_player_guild:InsertRow(-1)
    grid_player_guild:SetGridText(row, 0, nx_widestr(player_name))
    grid_player_guild:SetGridText(row, 1, nx_widestr(rank_no))
    grid_player_guild:SetGridText(row, 2, nx_widestr(kill_num))
  end
  grid_player_guild:EndUpdate()
end
function rec_speaker_data(...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local size = table.getn(arg)
  if nx_int(size) ~= nx_int(6) then
    return
  end
  local guild_name = nx_widestr(arg[1])
  local select_type = nx_int(arg[2])
  local select_name = nx_widestr(arg[3])
  local kill_num = nx_int(arg[4])
  local dead_num = nx_int(arg[5])
  local rank_no = nx_int(arg[6])
  if nx_int(select_type) == nx_int(CHASE_SPEAKER_TYPE_ERROR) then
    return
  end
  local ui_text = "ui_guild_chase_speaker_" .. nx_string(select_type)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local chat_str = nx_widestr("")
  if nx_int(select_type) == nx_int(CHASE_SPEAKER_TYPE_GUILD) then
    chat_str = nx_widestr(gui.TextManager:GetFormatText(nx_string(ui_text), nx_widestr(guild_name), nx_widestr(select_name), nx_widestr(select_name), nx_int(kill_num), nx_int(dead_num)))
  elseif nx_int(select_type) == nx_int(CHASE_SPEAKER_TYPE_PLAYER) then
    local player_name = player:QueryProp("Name")
    chat_str = nx_widestr(gui.TextManager:GetFormatText(nx_string(ui_text), nx_widestr(player_name), nx_widestr(select_name), nx_widestr(select_name), nx_int(kill_num), nx_int(dead_num)))
  elseif nx_int(select_type) == nx_int(CHASE_SPEAKER_TYPE_PLAYER_GUILD) then
    if nx_int(rank_no) < nx_int(1) or nx_int(rank_no) > nx_int(10) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text("90398")), 2)
      end
      return
    end
    chat_str = nx_widestr(gui.TextManager:GetFormatText(nx_string(ui_text), nx_widestr(guild_name), nx_widestr(select_name), nx_int(kill_num), nx_int(rank_no)))
  end
  local switch = nx_execute("form_stage_main\\form_main\\form_laba_info", "get_used_card_type")
  nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, chat_str, 1, "", switch)
end
function on_btn_rank_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_guild_war\\form_guild_war_rank")
end
