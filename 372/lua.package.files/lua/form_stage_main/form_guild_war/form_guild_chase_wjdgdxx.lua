require("util_gui")
function on_main_form_init(form)
  form.Fixed = false
  form.refresh_time = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  local new_time = os.time()
  if nx_find_custom(form, "refresh_time") and new_time - form.refresh_time <= 2 then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sns_new_05"), 2)
    end
    return
  end
  form.refresh_time = new_time
  nx_execute("custom_sender", "custom_wjd_request", 2)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function reset_wjdgd_info(...)
  util_show_form("form_stage_main\\form_guild_war\\form_guild_chase_wjdgdxx", true)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_chase_wjdgdxx")
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_wjdgdxx
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid.ColCount = 5
  grid.RowHeight = 24
  grid.ColWidths = "110, 110, 110, 110, 110"
  for i = 1, table.getn(arg) - 1, 5 do
    local ranking = nx_widestr(arg[i + 0])
    local name = nx_widestr(arg[i + 1])
    local school = util_text(arg[i + 3])
    local power_level = util_text("desc_" .. nx_string(arg[i + 2]))
    local score = nx_widestr(arg[i + 4])
    add_info_to_grid(grid, ranking, name, school, power_level, score)
  end
  grid:SortRowsByInt(0, false)
  grid:EndUpdate()
end
function add_info_to_grid(grid, ranking, name, school, power_level, score)
  local row = grid:InsertRow(grid.RowCount)
  grid:SetGridText(row, 0, ranking)
  grid:SetGridText(row, 1, name)
  grid:SetGridText(row, 2, school)
  grid:SetGridText(row, 3, power_level)
  grid:SetGridText(row, 4, score)
end
