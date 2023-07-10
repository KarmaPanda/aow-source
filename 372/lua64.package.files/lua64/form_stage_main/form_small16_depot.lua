require("share\\view_define")
require("util_gui")
function form_main_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self.imagegrid_depot)
  nx_destroy(self)
end
function form_adddepot_bind(self, viewid, beginindex, endindex)
  self.imagegrid_depot.typeid = viewid
  for i = 1, endindex - beginindex + 1 do
    self.imagegrid_depot:SetBindIndex(nx_int(i - 1), nx_int(beginindex + i - 1))
  end
  self.imagegrid_depot.canselect = true
  self.imagegrid_depot.candestroy = false
  self.imagegrid_depot.cansplit = false
  self.imagegrid_depot.canlock = false
  self.imagegrid_depot.canarrange = false
  self.imagegrid_depot.RowNum = nx_int(1)
  self.imagegrid_depot.ClomnNum = nx_int(endindex - beginindex + 1)
  refresh_pos(self, endindex - beginindex + 1)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(nx_int(viewid), self.imagegrid_depot, nx_current(), "on_view_operat")
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(self.imagegrid_depot)
  end
end
function refresh_pos(form, size)
  local gui = nx_value("gui")
  local gridspos = ""
  local i = 0
  while size > i do
    local row = nx_int(i / 4)
    local column = nx_int(i % 4)
    gridspos = gridspos .. nx_string(nx_int(column * 47)) .. "," .. nx_string(nx_int(row * 47)) .. ";"
    i = i + 1
  end
  form.imagegrid_depot.GridsPos = gridspos
  form.imagegrid_depot.Height = nx_int((size + 3) / 4) * 47 + 14
  form.Height = form.imagegrid_depot.Height + 40
  form.lbl_3.Height = form.Height - 36
end
function on_imagegrid_depot_select_changed(self, index)
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(self, -1)
end
function on_imagegrid_depot_rightclick_grid(self, index)
  nx_execute("form_stage_main\\form_depot", "on_goods_grid_rightclick_grid", self, index)
end
function on_imagegrid_depot_mousein_grid(self, index)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(self, index)
  end
  local testleft = self:GetMouseInItemLeft()
  local testtop = self:GetMouseInItemTop()
  nx_execute("tips_game", "show_goods_tip", item_data, testleft, testtop, 32, 32, self.ParentForm)
end
function on_imagegrid_depot_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_view_operat(grid, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  return 1
end
function on_btn_close_click(self)
  form = self.Parent
  form:Close()
end
