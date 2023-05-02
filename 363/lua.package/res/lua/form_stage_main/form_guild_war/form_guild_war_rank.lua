require("util_gui")
require("util_functions")
local FORM_GUILDWARRANK = "form_stage_main\\form_guild_war\\form_guild_war_rank"
local CLIENT_CUSTOMMSG_GUILD = 1014
local SUB_CUSTOMMSG_REQUEST_GUILD_CHASE_STAT = 77
local PLAYER_GUILD_ALL_STAT_TYPE = 4
local EVERYPAGE_COUNT = 20
local player_guild_grid_table = {
  "ui_player",
  "ui_paiming",
  "ui_kill_num_player",
  "ui_be_killed_num_player"
}
local grid_rank_data = {}
function main_form_init(self)
  self.Fixed = false
  self.cur_page = 1
  self.max_page = 1
end
function on_main_form_open(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2 + 485
  self.Top = (gui.Height - self.Height) / 2
  init_grid(self)
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_CHASE_STAT), nx_int(PLAYER_GUILD_ALL_STAT_TYPE))
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  grid_rank_data = {}
  nx_destroy(self)
  return
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_GUILDWARRANK, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page <= 1 then
    return
  end
  form.cur_page = form.cur_page - 1
  fresh_rank(form)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page >= form.max_page then
    return
  end
  form.cur_page = form.cur_page + 1
  fresh_rank(form)
end
function init_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local grid = form.textgrid_rank
  grid:BeginUpdate()
  grid.ColCount = table.getn(player_guild_grid_table)
  for i = 1, table.getn(player_guild_grid_table) do
    grid:SetColTitle(i - 1, nx_widestr(util_text(nx_string(player_guild_grid_table[i]))))
  end
  grid:EndUpdate()
end
function rec_player_guild_data(...)
  local form = nx_value(FORM_GUILDWARRANK)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  grid_rank_data = arg
  local size = table.getn(grid_rank_data) / 4
  form.max_page = nx_int(size / EVERYPAGE_COUNT)
  if math.mod(size, EVERYPAGE_COUNT) ~= 0 then
    form.max_page = form.max_page + 1
  end
  if form.max_page < form.cur_page then
    form.max_page = form.cur_page
  end
  local grid_rank = form.textgrid_rank
  if not nx_is_valid(grid_rank) then
    return
  end
  fresh_rank(form)
end
function fresh_rank(form)
  if not nx_is_valid(form) then
    return
  end
  local grid_rank = form.textgrid_rank
  if not nx_is_valid(grid_rank) then
    return
  end
  local size = table.getn(grid_rank_data)
  local count = size / 4
  if count <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_captain = client_player:QueryProp("IsGuildCaptain")
  local captain = true
  if nx_int(is_captain) ~= nx_int(2) then
    captain = false
  end
  grid_rank:BeginUpdate()
  grid_rank:ClearRow()
  grid_rank:ClearSelect()
  local index = (form.cur_page - 1) * EVERYPAGE_COUNT + 1
  local index_end = form.cur_page * EVERYPAGE_COUNT
  if count < index_end then
    index_end = count
  end
  for i = index, index_end do
    local temp_index = (i - 1) * 4 + 1
    if size < temp_index + 3 then
      return
    end
    local rank_no = nx_int(grid_rank_data[temp_index])
    temp_index = temp_index + 1
    local player_name = nx_widestr(grid_rank_data[temp_index])
    temp_index = temp_index + 1
    local kill_num = nx_int(grid_rank_data[temp_index])
    temp_index = temp_index + 1
    local be_kill_num = nx_int(grid_rank_data[temp_index])
    temp_index = temp_index + 1
    local row = grid_rank:InsertRow(-1)
    grid_rank:SetGridText(row, 0, nx_widestr(player_name))
    grid_rank:SetGridText(row, 1, nx_widestr(rank_no))
    grid_rank:SetGridText(row, 2, nx_widestr(kill_num))
    if captain then
      grid_rank:SetGridText(row, 3, nx_widestr(be_kill_num))
    else
      grid_rank:SetGridText(row, 3, nx_widestr(util_text("ui_guild_war_rank_desc")))
    end
  end
  grid_rank:EndUpdate()
  form.lbl_page.Text = nx_widestr(form.cur_page) .. nx_widestr("/") .. nx_widestr(form.max_page)
end
