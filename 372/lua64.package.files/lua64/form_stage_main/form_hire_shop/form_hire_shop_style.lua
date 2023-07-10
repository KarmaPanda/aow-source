function main_form_init(form)
  form.Fixed = false
  form.npcid = nil
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  reset_grid_data(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop_style", nx_null())
end
function reset_grid_data(form)
  local gui = nx_value("gui")
  form.grid_style_info:BeginUpdate()
  form.grid_style_info.ColCount = 3
  form.grid_style_info:ClearRow()
  form.grid_style_info:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_hire_shop_style_desc")))
  form.grid_style_info:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_hire_shop_style_golden")))
  form.grid_style_info:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_hire_shop_style_silver")))
  local ini = nx_execute("util_functions", "get_ini", "share\\Trade\\HireShopStyle.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_size = ini:GetSectionCount()
  for i = 1, sec_size do
    local sec_name = ini:GetSectionByIndex(i - 1)
    local desc = ini:ReadString(i - 1, "shopname", "")
    local shopname = gui.TextManager:GetText(desc)
    local golden = ini:ReadInteger(i - 1, "Golden", 0)
    local silver = ini:ReadInteger(i - 1, "Silver", 0)
    local show_golden = format_money(golden)
    local show_silver = format_money(silver)
    local row = form.grid_style_info:InsertRow(-1)
    form.grid_style_info:SetGridText(row, 0, nx_widestr(shopname))
    form.grid_style_info:SetGridText(row, 1, nx_widestr(show_golden))
    form.grid_style_info:SetGridText(row, 2, nx_widestr(show_silver))
    form.grid_style_info:SetRowTitle(row, nx_widestr(sec_name))
  end
  form.grid_style_info:EndUpdate()
end
function format_money(money)
  local gui = nx_value("gui")
  local d = nx_int(money / 1000000)
  local l = nx_int((money - d * 1000000) / 1000)
  local w = money - d * 1000000 - l * 1000
  local str = nx_widestr(d) .. nx_widestr(gui.TextManager:GetText("ui_bag_ding")) .. nx_widestr(l) .. nx_widestr(gui.TextManager:GetText("ui_bag_liang")) .. nx_widestr(w) .. nx_widestr(gui.TextManager:GetText("ui_bag_wen"))
  return nx_widestr(str)
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  local grid = form.grid_style_info
  local row = grid.RowSelectIndex
  local style_id = nx_int(grid:GetRowTitle(row))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(7), nx_int(6), nx_int(style_id), form.npcid)
end
function on_grid_style_info_select_row(grid)
  local form = grid.ParentForm
  local grid = form.grid_style_info
  local row = grid.RowSelectIndex
  local style_id = nx_int(grid:GetRowTitle(row))
  if nx_int(style_id) <= nx_int(0) then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Trade\\HireShopStyle.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local pic = ini:ReadString(style_id - 1, "Pictrue", "")
  form.lbl_preview.BackImage = nx_string(pic)
end
