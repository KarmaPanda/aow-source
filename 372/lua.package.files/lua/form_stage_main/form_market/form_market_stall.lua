require("util_gui")
require("util_functions")
require("share\\capital_define")
require("share\\view_define")
local TotalCellCount = 60
local SUB_CLIENT_ClOSE_STALL = 4
function main_form_init(self)
  self.Fixed = false
  self.master = ""
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  util_show_form("form_stage_main\\form_stall\\form_stallbusiness", false)
  self.sell_grid.beginindex = nx_number(1)
  self.sell_grid.endindex = nx_number(TotalCellCount)
  self.sell_grid.playerCount = nx_number(TotalCellCount)
  self.sell_grid.typeid = VIEWPORT_MARKET_SELL_BOX
  for i = 1, TotalCellCount do
    self.sell_grid:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  self.sell_grid.canselect = true
  self.sell_grid.candestroy = true
  self.sell_grid.cansplit = false
  self.sell_grid.canlock = false
  self.sell_grid.canarrange = false
  self.buy_grid.beginindex = nx_number(1)
  self.buy_grid.endindex = nx_number(TotalCellCount)
  self.buy_grid.playerCount = nx_number(TotalCellCount)
  self.buy_grid.typeid = VIEWPORT_MARKET_PURCHASE_BOX
  for i = 1, TotalCellCount do
    self.buy_grid:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  self.buy_grid.canselect = true
  self.buy_grid.candestroy = true
  self.buy_grid.cansplit = false
  self.buy_grid.canlock = false
  self.buy_grid.canarrange = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_MARKET_SELL_BOX, self.sell_grid, nx_current(), "on_sell_viewport_changed")
    databinder:AddViewBind(VIEWPORT_MARKET_PURCHASE_BOX, self.buy_grid, nx_current(), "on_sell_viewport_changed")
  end
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self.sell_grid)
  databinder:DelViewBind(self.buy_grid)
  nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ClOSE_STALL)
end
function on_sell_viewport_changed(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 0
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  if optype == "createview" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_fresh_all_no_suo", grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_fresh_all_no_suo", grid)
  elseif optype == "additem" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_on_update_item", grid, index)
  elseif optype == "delitem" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_on_delete_item", grid, index)
  elseif optype == "updateitem" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_on_update_item", grid, index)
  end
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_sell_grid_rightclick_grid(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_MARKET_SELL_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  local item_id = viewobj:QueryProp("ConfigID")
  local item_price = viewobj:QueryProp("StallPrice1")
  local item_sellcount = viewobj:QueryProp("SellCount")
  local item_uniqueid = viewobj:QueryProp("UniqueID")
  if item_id == nil or item_id == "" then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  dialog.lbl_max_count.Text = nx_widestr(item_sellcount)
  dialog.lbl_max_count.Visible = false
  dialog.lbl_tip.Text = nx_widestr(util_text(item_id))
  dialog.ipt_count.Text = nx_widestr(1)
  dialog.Left = self.Parent.Left + (self.Parent.Width - dialog.Width) / 2
  dialog.Top = self.Parent.Top + (self.Parent.Height - dialog.Height) / 2
  nx_execute("form_stage_main\\form_shop\\form_trade_buy", "init_buy_form", dialog, 2, item_price, item_sellcount)
  dialog.retail_mode = "buy"
  dialog.Visible = true
  dialog:ShowModal()
  local res, count, paymodel = nx_wait_event(100000000, dialog, "form_retail_return")
  if res == "ok" then
    if count == 0 then
      count = item_sellcount
    end
    nx_execute("custom_sender", "custom_stall_buy_from_stall", nx_widestr(form.master), nx_string(item_uniqueid), nx_int(count), nx_int64(item_price))
  end
end
function on_sell_grid_mousein_grid(self, index)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(self, index)
  end
  nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
end
function on_sell_grid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_buy_grid_mousein_grid(self, index)
  nx_execute("form_stage_main\\form_stall\\form_stallbusiness", "on_buy_grid_mousein_grid", self, index)
end
function on_buy_grid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_buy_grid_select_changed(self, index)
  local uniqueid, have_amount, configid = nx_execute("form_stage_main\\form_stall\\form_stallbusiness", "get_buy_hand_data")
  if uniqueid == "" or nx_int(have_amount) <= nx_int(0) or configid == "" then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_MARKET_PURCHASE_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  local item_id = viewobj:QueryProp("ConfigID")
  local price = viewobj:QueryProp("PurchasePrice1")
  local count = viewobj:QueryProp("BuyedCount")
  local max_count = viewobj:QueryProp("BuyCountAll")
  local item_name = nx_widestr(util_text(item_id))
  if item_id == nil or item_id == "" then
    return
  end
  if nx_string(configid) ~= nx_string(item_id) then
    return
  end
  local buy_count = max_count - count
  if nx_int(have_amount) < nx_int(buy_count) then
    buy_count = have_amount
  end
  nx_execute("form_stage_main\\form_stall\\form_stallbusiness", "show_sell_item_retail_form", self, index, uniqueid, buy_count, item_name, 0, price)
end
function on_btn_liuyan_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_liuyan = util_get_form("form_stage_main\\form_market\\form_market_liuyan", true)
  if not nx_is_valid(form) then
    return
  end
  form_liuyan.name = form.master
  util_show_form("form_stage_main\\form_market\\form_market_liuyan", true)
end
