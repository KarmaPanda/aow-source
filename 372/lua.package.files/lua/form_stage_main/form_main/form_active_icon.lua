require("util_functions")
local ACT_TYPE_HAPPY = 1
local ACT_TYPE_REDEEM = 2
local ACT_TYPE_BUY = 3
local ACT_TYPE_SPECIAL = 4
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  self.ImageControlGrid_happy.beginindex = 0
  self.ImageControlGrid_redeem.beginindex = 0
  self.ImageControlGrid_buy.beginindex = 0
  self.ImageControlGrid_special.beginindex = 0
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if nx_is_valid(activity_icon_mgr) then
    nx_destroy(activity_icon_mgr)
  end
  activity_icon_mgr = nx_create("activity_icon_mgr")
  if nx_is_valid(activity_icon_mgr) then
    nx_set_value("activity_icon_mgr", activity_icon_mgr)
  end
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if nx_is_valid(activity_icon_mgr) then
    activity_icon_mgr:RefreshForm()
  end
end
function on_main_form_close(self)
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if nx_is_valid(activity_icon_mgr) then
    nx_destroy(activity_icon_mgr)
  end
  nx_destroy(self)
end
function on_btn_happy_left_click(btn)
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local form = btn.ParentForm
  local grid = form.ImageControlGrid_happy
  if 0 < grid.beginindex then
    grid.beginindex = grid.beginindex - 1
    activity_icon_mgr:RefreshGrid(grid, ACT_TYPE_HAPPY)
  end
end
function on_btn_happy_right_click(btn)
  local form = btn.ParentForm
  local grid = form.ImageControlGrid_happy
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local max_index = activity_icon_mgr:GetMaxIndex(grid, ACT_TYPE_HAPPY)
  if max_index > grid.beginindex then
    grid.beginindex = grid.beginindex + 1
    activity_icon_mgr:RefreshGrid(grid, ACT_TYPE_HAPPY)
  end
end
function on_btn_redeem_left_click(btn)
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local form = btn.ParentForm
  local grid = form.ImageControlGrid_redeem
  if 0 < grid.beginindex then
    grid.beginindex = grid.beginindex - 1
    activity_icon_mgr:RefreshGrid(grid, ACT_TYPE_REDEEM)
  end
end
function on_btn_redeem_right_click(btn)
  local form = btn.ParentForm
  local grid = form.ImageControlGrid_redeem
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local max_index = activity_icon_mgr:GetMaxIndex(grid, ACT_TYPE_REDEEM)
  if max_index > grid.beginindex then
    grid.beginindex = grid.beginindex + 1
    activity_icon_mgr:RefreshGrid(grid, ACT_TYPE_REDEEM)
  end
end
function on_btn_buy_left_click(btn)
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local form = btn.ParentForm
  local grid = form.ImageControlGrid_buy
  if 0 < grid.beginindex then
    grid.beginindex = grid.beginindex - 1
    activity_icon_mgr:RefreshGrid(grid, ACT_TYPE_BUY)
  end
end
function on_btn_buy_right_click(btn)
  local form = btn.ParentForm
  local grid = form.ImageControlGrid_buy
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local max_index = activity_icon_mgr:GetMaxIndex(grid, ACT_TYPE_BUY)
  if max_index > grid.beginindex then
    grid.beginindex = grid.beginindex + 1
    activity_icon_mgr:RefreshGrid(grid, ACT_TYPE_BUY)
  end
end
function on_btn_special_left_click(btn)
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local form = btn.ParentForm
  local grid = form.ImageControlGrid_special
  if 0 < grid.beginindex then
    grid.beginindex = grid.beginindex - 1
    activity_icon_mgr:RefreshGrid(grid, ACT_TYPE_SPECIAL)
  end
end
function on_btn_special_right_click(btn)
  local form = btn.ParentForm
  local grid = form.ImageControlGrid_special
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local max_index = activity_icon_mgr:GetMaxIndex(grid, ACT_TYPE_SPECIAL)
  if max_index > grid.beginindex then
    grid.beginindex = grid.beginindex + 1
    activity_icon_mgr:RefreshGrid(grid, ACT_TYPE_SPECIAL)
  end
end
function on_ImageControlGrid_changed(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local st_act = grid:GetBindIndex(index)
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if nx_is_valid(activity_icon_mgr) then
    activity_icon_mgr:OnClick(st_act)
  end
end
function on_ImageControlGrid_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local activity_icon_mgr = nx_value("activity_icon_mgr")
  if not nx_is_valid(activity_icon_mgr) then
    return
  end
  local st_act = grid:GetBindIndex(index)
  local tips_text = activity_icon_mgr:GetTipsText(st_act)
  nx_execute("tips_game", "show_text_tip", util_text(tips_text), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop())
end
function on_ImageControlGrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
