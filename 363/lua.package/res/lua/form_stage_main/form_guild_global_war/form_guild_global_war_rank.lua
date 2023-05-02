require("util_gui")
require("util_functions")
local FORM_RANK_MAIN = "form_stage_main\\form_guild_global_war\\form_guild_global_war_rank"
local CLIENT_MSG_GGW_GUILD_ACHIEVEMNT_RANK = 3
local CLIENT_MSG_GGW_PLAYER_ACHIEVEMNT_RANK = 4
local tab_title = {
  [CLIENT_MSG_GGW_GUILD_ACHIEVEMNT_RANK] = "ui_global_war_rank_g_01,ui_global_war_rank_g_02,ui_global_war_rank_g_03,ui_global_war_rank_g_04,ui_global_war_rank_g_05,ui_global_war_rank_g_06",
  [CLIENT_MSG_GGW_PLAYER_ACHIEVEMNT_RANK] = "ui_global_war_rank_p_01,ui_global_war_rank_p_02,ui_global_war_rank_p_03,ui_global_war_rank_p_04,ui_global_war_rank_p_05,ui_global_war_rank_p_06"
}
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.rank_type = 0
  form.rank_value = ""
  form.self_name = ""
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form(rank_type)
  local form = util_show_form(FORM_RANK_MAIN, true)
  if nx_is_valid(form) then
    if nx_int(rank_type) ~= form.rank_type then
      form.rank_type = rank_type
      init_grid(form)
    end
    nx_execute("custom_sender", "custom_guildglobalwar", rank_type)
  end
end
function on_btn_find_yourself_click(btn)
  local form = btn.ParentForm
  if not (nx_is_valid(form) and nx_find_custom(form, "self_row")) or form.self_row < 0 then
    return
  end
  form.textgrid_ranking:SelectRow(form.self_row)
end
function on_receive(rank_type, ...)
  local form = nx_value(FORM_RANK_MAIN)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(rank_type) ~= nx_int(form.rank_type) then
    return
  end
  if #arg < 2 then
    return
  end
  local GuildManager = nx_value("GuildManager")
  if not nx_is_valid(GuildManager) then
    return
  end
  form.self_name = nx_string(arg[1])
  local rank_info = nx_widestr(arg[2])
  if nx_int(CLIENT_MSG_GGW_GUILD_ACHIEVEMNT_RANK) == nx_int(form.rank_type) then
    form.rank_value = nx_string(GuildManager:SortStringByTwoElement(5, 1, 2, rank_info))
  elseif nx_int(CLIENT_MSG_GGW_PLAYER_ACHIEVEMNT_RANK) == nx_int(form.rank_type) then
    form.rank_value = nx_string(GuildManager:SortStringByTwoElement(5, 1, 3, rank_info))
  end
  show_rank(form)
end
function show_rank(form)
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local key_name = client_player:QueryProp("Name")
  local rank_gird = form.textgrid_ranking
  if not nx_is_valid(rank_gird) then
    return
  end
  init_grid(form)
  if rank_gird.ColCount <= 0 then
    return
  end
  rank_gird:BeginUpdate()
  rank_gird:ClearRow()
  local string_table = util_split_wstring(nx_widestr(form.rank_value), ",")
  local value_count = nx_int(table.getn(string_table) - 1)
  local col_count = nx_int(rank_gird.ColCount - 1)
  local row_count = nx_int(value_count / col_count)
  form.self_row = -1
  local no_index = 1
  local begin_index = nx_number(1)
  for row = 0, row_count - 1 do
    if value_count < nx_int(begin_index + col_count - 1) then
      break
    end
    rank_gird:InsertRow(-1)
    rank_gird:SetGridText(row, 0, nx_widestr(no_index))
    rank_gird:SetGridText(row, 1, nx_widestr(string_table[begin_index]))
    rank_gird:SetGridText(row, 2, nx_widestr(string_table[begin_index + 1]))
    rank_gird:SetGridText(row, 3, nx_widestr(string_table[begin_index + 2]))
    rank_gird:SetGridText(row, 4, nx_widestr(string_table[begin_index + 3]))
    rank_gird:SetGridText(row, 5, nx_widestr(string_table[begin_index + 4]))
    no_index = no_index + 1
    begin_index = begin_index + col_count
    local temp_name = rank_gird:GetGridText(row, 1)
    if nx_ws_equal(nx_widestr(form.self_name), nx_widestr(temp_name)) then
      form.self_row = row
    end
  end
  if nx_int(form.self_row) >= nx_int(0) then
    for index = 0, col_count - 1 do
      rank_gird:SetGridForeColor(form.self_row, index, "255,255,0,0")
    end
  end
  rank_gird:EndUpdate()
end
function init_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_ranking
  grid:BeginUpdate()
  grid:ClearRow()
  grid.ColCount = 0
  local title = nx_string(tab_title[form.rank_type])
  if title ~= "" then
    local tab_col_title = util_split_string(title, ",")
    grid.ColCount = table.getn(tab_col_title)
    for i = 1, grid.ColCount do
      grid:SetColTitle(i - 1, nx_widestr(util_text(tab_col_title[i])))
    end
  end
  grid:EndUpdate()
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  return game_client:GetPlayer()
end
