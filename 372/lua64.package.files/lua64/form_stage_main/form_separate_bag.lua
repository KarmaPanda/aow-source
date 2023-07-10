require("util_gui")
function form_init(form)
  form.Fixed = false
  form.mouse_index = -1
end
function on_main_form_open(form)
  local form_bag_name = "form_stage_main\\form_bag"
  local form_bag = nx_value(form_bag_name)
  form.form_bag = form_bag
  form.form_bag_name = form_bag_name
end
function on_main_form_close(form)
  local form_bag = form.form_bag
  if form_bag.addbox1 ~= nil then
    form_bag.addbox1 = nil
    form_bag.current_open = 0
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  local form_bag = form.form_bag
  if form_bag.addbox1 ~= nil then
    form_bag.addbox1 = nil
    form_bag.current_open = 0
    form:Close()
  end
end
function on_imagegrid_tool_mousein_grid(grid, index)
  local form = grid.ParentForm
  form.mouse_index = index
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(grid, index)
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_imagegrid_tool_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mouse_index = -1
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_tool_rightclick_grid(grid, index)
  local form = grid.ParentForm
  nx_execute(form.form_bag_name, "on_bag_right_click", grid, index)
end
function on_imagegrid_tool_select_changed(grid, index)
  local form = grid.ParentForm
  nx_execute(form.form_bag_name, "on_bag_select_changed", grid, index)
end
