function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  gui.Desktop:ToFront(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_grid_award_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_config), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_grid_award_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_form(...)
  if table.getn(arg) < 1 then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.grid_award_1.Visible = false
  form.grid_award_2.Visible = false
  form.grid_award_3.Visible = false
  for i = 1, table.getn(arg) do
    local item_id = nx_string(arg[i])
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_id), "Photo")
    local img_grid = form:Find("grid_award_" .. nx_string(i))
    if nx_is_valid(img_grid) then
      img_grid.Visible = true
      img_grid:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(1), nx_int(-1))
    end
  end
end
