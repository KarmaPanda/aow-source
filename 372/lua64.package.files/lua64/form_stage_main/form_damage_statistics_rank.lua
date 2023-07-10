require("utils")
require("util_gui")
local text_table = {
  "ui_info_main_01",
  "ui_info_main_02",
  "ui_info_main_03",
  "ui_info_main_04"
}
function on_damage_statistics_rank_init(form)
end
local timer_tick_num = 0
function on_main_form_open(form)
  form.Fixed = false
  local form_rank = nx_value("form_stage_main\\form_damage_statistics_rank")
  if not nx_is_valid(form_rank) then
    form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_damage_statistics_rank", true, false)
    nx_set_value("form_stage_main\\form_damage_statistics_rank", form_rank)
  end
  local form_col_awards = nx_value("form_stage_main\\form_clone_col_awards")
  if not nx_is_valid(form_col_awards) then
    return
  end
  form.Left = form_col_awards.Left
  form.Top = form_col_awards.Top
  local DamageStatistics = nx_value("damage_statistics")
  if not nx_is_valid(DamageStatistics) then
    return
  end
  form.lbl_ani.Visible = true
  form.lbl_back.Visible = true
  form.Fixed = false
  refresh_rank(form, 0)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_1_click(btn)
  local form_col_awards = nx_value("form_stage_main\\form_clone_col_awards")
  if not nx_is_valid(form_col_awards) then
    form_col_awards = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_col_awards", true, false)
    nx_set_value("form_clone_col_awards", form_col_awards)
  end
  form_col_awards.Visible = true
  local form_rank = nx_value("form_stage_main\\form_damage_statistics_rank")
  if nx_is_valid(form_rank) then
    form_rank:Close()
  end
end
function refresh_rank(form)
  local DamageStatistics = nx_value("damage_statistics")
  if not nx_is_valid(DamageStatistics) then
    return false
  end
  local args = DamageStatistics:GetDamageRank()
  local result = check_rank_args_valid(args)
  if not result then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:Register(1000, 3, nx_current(), "timer_update_rank", form, -1, -1)
      timer_tick_num = 0
      form.lbl_ani.Visible = true
      form.lbl_back.Visible = true
      return false
    end
  end
  local player_num = args[2]
  if player_num < 1 then
    return
  end
  format_to_grid(form, args)
  form.lbl_ani.Visible = false
  form.lbl_back.Visible = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_update_rank", form)
    return true
  end
  return true
end
function on_btn_total_click(btn)
  local form = btn.ParentForm
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:SortRowsByInt(3, true)
  fresh_textgrid(form.textgrid_1)
  form.textgrid_1:EndUpdate()
end
function on_btn_boss_click(btn)
  local form = btn.ParentForm
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:SortRowsByInt(2, true)
  fresh_textgrid(form.textgrid_1)
  form.textgrid_1:EndUpdate()
end
function fresh_textgrid(grid)
  local row_num = grid.RowCount
  for i = 0, row_num - 1 do
    grid:SetGridText(i, 0, nx_widestr(i + 1))
  end
end
function check_rank_args_valid(args)
  if args == nil then
    return false
  end
  local length = table.getn(args)
  if length < 2 then
    return false
  end
  local result = args[2]
  if result < 1 then
    return false
  end
  return true
end
function timer_update_rank(form)
  timer_tick_num = timer_tick_num + 1
  local DamageStatistics = nx_value("damage_statistics")
  if not nx_is_valid(DamageStatistics) then
    return false
  end
  local args = DamageStatistics:GetDamageRank()
  local result = check_rank_args_valid(args)
  if not result then
    if timer_tick_num < 3 then
      return false
    else
      local timer = nx_value(GAME_TIMER)
      if nx_is_valid(timer) then
        timer:UnRegister(nx_current(), "timer_update_rank", form)
        return true
      end
      form.lbl_ani.Visible = false
      form.lbl_back.Visible = false
      return false
    end
  end
  format_to_grid(form, args)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_update_rank", form)
    return true
  end
  form.lbl_ani.Visible = false
  form.lbl_back.Visible = false
  return true
end
function format_to_grid(form, args)
  if args == nil then
    return
  end
  local length = table.getn(args)
  if length < 2 then
    return
  end
  local player_num = args[2]
  if player_num < 1 then
    return
  end
  local grid = form.textgrid_1
  grid:BeginUpdate()
  grid:ClearRow()
  grid.ColCount = 4
  grid:SetColWidth(0, 20)
  grid:SetColWidth(1, 75)
  grid:SetColWidth(2, 85)
  grid:SetColWidth(3, 85)
  grid.VScrollLeft = false
  local rank_index = 1
  for i = 0, player_num - 1 do
    local player_name = nx_widestr(args[i * 3 + 3])
    local damage_boss = nx_widestr(args[i * 3 + 4])
    local damage_total = nx_widestr(args[i * 3 + 5])
    local row = grid:InsertRow(-1)
    grid:SetGridForeColor(row, 1, "255,255,180,40")
    grid:SetGridText(row, 0, nx_widestr(rank_index))
    grid:SetGridText(row, 1, player_name)
    grid:SetGridText(row, 2, damage_boss)
    grid:SetGridText(row, 3, damage_total)
    rank_index = rank_index + 1
  end
  grid:SortRowsByInt(3, true)
  fresh_textgrid(grid)
  grid:EndUpdate()
  form.lbl_ani.Visible = false
  form.lbl_back.Visible = false
end
