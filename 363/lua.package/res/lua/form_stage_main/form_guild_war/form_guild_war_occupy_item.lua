require("util_gui")
local FORM_NAME = "form_stage_main\\form_guild_war\\form_guild_war_occupy_item"
local grid_table = {
  [1] = {
    col_width_per = 2,
    col_title = "ui_dr_col_name_1"
  },
  [2] = {
    col_width_per = 2,
    col_title = "ui_dr_col_name_2"
  },
  [3] = {
    col_width_per = 2,
    col_title = "ui_dr_col_name_0"
  },
  [4] = {
    col_width_per = 2,
    col_title = "ui_worldwar_stage_2"
  },
  [5] = {
    col_width_per = 2,
    col_title = "ui_dr_col_name_3"
  }
}
local grid_per_base_num = 10
local GUILDWAR_STAGE_NORMAL = 0
local GUILDWAR_STAGE_READY = 1
local GUILDWAR_STAGE_FIGHTING = 2
local GUILDWAR_STAGE_DECLARED = 3
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  init_controls(form)
  nx_set_value(FORM_NAME, form)
  form.target_domain_id = -1
  form.self_domain_id = -1
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  request_data()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_set_value(FORM_NAME, nx_null())
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local cur_srcviewid = form.srcviewid
  local cur_srcpos = form.srcpos
  local cur_target_domain_id = form.target_domain_id
  local cur_self_domain_id = form.self_domain_id
  if nx_int(cur_target_domain_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_use_guild_war_occupy_item", cur_srcviewid, cur_srcpos, cur_target_domain_id, cur_self_domain_id)
  form:Close()
end
function on_btn_refresh_click(btn)
  request_data()
end
function on_textgrid_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.target_domain_id = nx_execute("form_stage_main\\form_guild_fire\\form_courtfire_info", "get_domain_id_by_name", nx_widestr(grid:GetGridText(row, 0)))
  form.self_domain_id = nx_execute("form_stage_main\\form_guild_fire\\form_courtfire_info", "get_domain_id_by_name", nx_widestr(grid:GetGridText(row, 4)))
end
function init_controls(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  local grid_width = grid.Width - 30
  grid.ColCount = table.getn(grid_table)
  for i = 1, table.getn(grid_table) do
    grid:SetColWidth(i - 1, grid_width / grid_per_base_num * nx_int(grid_table[i].col_width_per))
    grid:SetColTitle(i - 1, nx_widestr(util_text(nx_string(grid_table[i].col_title))))
  end
  grid:EndUpdate()
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid:EndUpdate()
end
function request_data()
  nx_execute("custom_sender", "custom_occupy_item_guild_war_info")
end
function on_rec_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  clear_grid(form)
  local size = table.getn(arg)
  if size % 5 ~= 0 or size == 0 then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  for i = 1, size / 5 do
    local temp_index = (i - 1) * 5 + 1
    local attack_domain_id = nx_widestr(arg[temp_index])
    temp_index = temp_index + 1
    local attack_guild_name = nx_widestr(arg[temp_index])
    temp_index = temp_index + 1
    local defend_guild_name = nx_widestr(arg[temp_index])
    temp_index = temp_index + 1
    local war_stage = nx_int(arg[temp_index])
    temp_index = temp_index + 1
    local self_defend_domain_id = nx_int(arg[temp_index])
    temp_index = temp_index + 1
    local row = grid:InsertRow(-1)
    local war_stage_text = nx_widestr("")
    if nx_int(GUILDWAR_STAGE_DECLARED) == nx_int(war_stage) then
      war_stage_text = util_text("ui_xuanzhan")
    elseif nx_int(GUILDWAR_STAGE_READY) == nx_int(war_stage) then
      war_stage_text = util_text("ui_guildwar_zhunbei")
    elseif nx_int(GUILDWAR_STAGE_FIGHTING) == nx_int(war_stage) then
      war_stage_text = util_text("ui_guildwar_zhandou")
    elseif nx_int(GUILDWAR_STAGE_NORMAL) == nx_int(war_stage) then
      war_stage_text = util_text("ui_guildwar_heping")
    end
    grid:SetGridText(row, 0, nx_widestr(util_text("ui_dipan_" .. nx_string(attack_domain_id))))
    grid:SetGridText(row, 1, nx_widestr(attack_guild_name))
    grid:SetGridText(row, 2, nx_widestr(defend_guild_name))
    grid:SetGridText(row, 3, nx_widestr(war_stage_text))
    if nx_int(self_defend_domain_id) ~= nx_int(0) then
      grid:SetGridText(row, 4, nx_widestr(util_text("ui_dipan_" .. nx_string(self_defend_domain_id))))
    end
  end
  grid:EndUpdate()
end
