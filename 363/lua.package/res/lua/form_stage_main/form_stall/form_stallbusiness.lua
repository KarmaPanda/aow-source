require("share\\client_custom_define")
require("share\\view_define")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("share\\capital_define")
local vpos_start_pos = 1
local vpos_end_pos = 1
local vpos_buy_start_pos = 1
local vpos_buy_end_pos = 1
local TotalCellCount = 60
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = 100
  self.Top = (gui.Height - self.Height) / 2
  if not initForm(self) then
    self:Close()
    return
  end
  util_show_form("form_stage_main\\form_market\\form_market_stall", false)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_OFFLINE_OTHER_SELL_BOX, self.sell_grid, "form_stage_main\\form_stall\\form_stallbusiness", "on_sell_viewport_changed")
  databinder:AddViewBind(VIEWPORT_OTHER_STALL_PURCHASE_BOX, self.buy_grid, "form_stage_main\\form_stall\\form_stallbusiness", "on_sell_viewport_changed")
  databinder:AddRolePropertyBind("LastObject", "object", self, "form_stage_main\\form_stall\\form_stallbusiness", "on_selectobj_changed")
  return 1
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self.sell_grid)
  databinder:DelViewBind(self.buy_grid)
  databinder:DelRolePropertyBind("LastObject", self)
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_stall\\form_stallbusiness", nx_null())
end
function initForm(self)
  local sellCount = TotalCellCount
  local buyCount = TotalCellCount
  vpos_end_pos = nx_number(sellCount)
  vpos_buy_end_pos = nx_number(buyCount)
  local otherPlayer = GetPlayer()
  if not nx_is_valid(otherPlayer) then
    return false
  end
  local playerSellCount = nx_execute("form_stage_main\\form_stall\\form_stall_main", "GetSellCount", otherPlayer)
  local playerBuyCount = nx_execute("form_stage_main\\form_stall\\form_stall_main", "GetBuyCount", otherPlayer)
  self.sell_grid.typeid = VIEWPORT_OFFLINE_OTHER_SELL_BOX
  self.sell_grid.beginindex = vpos_start_pos
  self.sell_grid.endindex = vpos_end_pos
  self.sell_grid.playerCount = vpos_end_pos
  local grid_index = 0
  for view_index = self.sell_grid.beginindex, self.sell_grid.endindex do
    self.sell_grid:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  self.sell_grid.canselect = true
  self.sell_grid.candestroy = true
  self.sell_grid.cansplit = false
  self.sell_grid.canlock = false
  self.sell_grid.canarrange = false
  nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_fresh_all_no_suo", self.sell_grid, sellCount)
  self.buy_grid.typeid = VIEWPORT_OTHER_STALL_PURCHASE_BOX
  self.buy_grid.beginindex = vpos_buy_start_pos
  self.buy_grid.endindex = vpos_buy_end_pos
  self.buy_grid.playerCount = vpos_buy_end_pos
  grid_index = 0
  for view_index = self.buy_grid.beginindex, self.buy_grid.endindex do
    self.buy_grid:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  self.buy_grid.canselect = true
  self.buy_grid.candestroy = true
  self.buy_grid.cansplit = false
  self.buy_grid.canlock = false
  self.buy_grid.canarrange = false
  nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_fresh_all_no_suo", self.buy_grid, buyCount)
  local target = nx_value("game_select_obj")
  if nx_is_valid(target) then
    local stallname, targetname
    local type = target:QueryProp("Type")
    if TYPE_PLAYER == tonumber(type) then
      stallname = target:QueryProp("StallName")
      targetname = target:QueryProp("Name")
    end
    self.Label_form_name.Text = nx_widestr(stallname)
  end
  return true
end
function getSellBuyCount()
  local sellCount = TotalCellCount
  local buyCount = TotalCellCount
  return sellCount, buyCount
end
function getIniValue(level, key)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\stall.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\Rule\\stall.ini " .. get_msg_str("msg_120"))
    return 0
  end
  local section_name = "Rank_" .. nx_string(level)
  if not ini:FindSection(nx_string(section_name)) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(section_name))
  if sec_index < 0 then
    return 0
  end
  local lev = ini:ReadString(sec_index, "Level", "0")
  if nx_int(lev) == nx_int(level) then
    local value = ini:ReadString(sec_index, key, "0")
    return nx_int64(value)
  end
  return 0
end
function on_btn_help_click(self)
end
function on_btn_close_click(self)
  util_show_form("form_stage_main\\form_stall\\form_stallbusiness", false)
end
function on_sell_viewport_changed(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
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
function get_viewport_valid_item_count(view_ident)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  local count = 0
  for index = vpos_start_pos, vpos_end_pos do
    local viewobj = view:GetViewObj(nx_string(index))
    if nx_is_valid(viewobj) then
      count = count + 1
    end
  end
  return count
end
function on_sell_grid_rightclick_grid(self, index)
  buy_stall_item(self, index + self.beginindex, 0)
end
function send_stall_buy_msg(index, count)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_OFFLINE_OTHER_SELL_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  local viewobj = view:GetViewObj(nx_string(index))
  if not nx_is_valid(viewobj) then
    return 0
  end
  if not view:FindRecord("offline_sellbox_table") then
    return
  end
  local row = view:FindRecordRow("offline_sellbox_table", 1, viewobj:QueryProp("UniqueID"))
  if row < 0 then
    return
  end
  local sivr_price = view:QueryRecord("offline_sellbox_table", row, 7)
  local item_uniqueid = viewobj:QueryProp("UniqueID")
  if count == 0 then
    count = view:QueryRecord("offline_sellbox_table", row, 5)
  end
  local otherPlayer = GetPlayer()
  if not nx_is_valid(otherPlayer) then
    return
  end
  local master_name = otherPlayer:QueryProp("Name")
  nx_execute("custom_sender", "custom_stall_buy_from_stall", nx_widestr(master_name), nx_string(item_uniqueid), nx_int(count), nx_int64(sivr_price))
end
function on_btn_buy_click(self)
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, GHT_FUNC_ICON.buy, "buy", "", "", "")
end
function on_sell_grid_select_changed(self)
  local gui = nx_value("gui")
  local selected_index = self:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    if not self:IsEmpty(selected_index) and self.canselect then
      buy_stall_item(self, selected_index + self.beginindex, 1)
    end
  elseif not self:IsEmpty(selected_index) and gui.GameHand.Type == GHT_FUNC and gui.GameHand.Para1 == "buy" then
    send_stall_buy_msg(selected_index + self.beginindex, 1)
    gui.GameHand:ClearHand()
  end
end
function buy_stall_item(grid, index, buymodel)
  local game_client = nx_value("game_client")
  local game_gui = nx_value("gui")
  local otherstall_view = game_client:GetView(nx_string(VIEWPORT_OFFLINE_OTHER_SELL_BOX))
  local viewobj = otherstall_view:GetViewObj(nx_string(index))
  if not nx_is_valid(viewobj) then
    return
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  if not otherstall_view:FindRecord("offline_sellbox_table") then
    return
  end
  local row = otherstall_view:FindRecordRow("offline_sellbox_table", 1, viewobj:QueryProp("UniqueID"))
  if row < 0 then
    return
  end
  local item_nameid = viewobj:QueryProp("ConfigID")
  local item_name = tips_manager:GetItemBaseName(viewobj)
  local item_sivr = otherstall_view:QueryRecord("offline_sellbox_table", row, 7)
  local item_realcount = viewobj:QueryProp("Amount")
  local item_sellcount = otherstall_view:QueryRecord("offline_sellbox_table", row, 5)
  show_buy_item_retail_form(grid, index, item_sellcount, item_name, item_sivr, buymodel)
end
function show_buy_item_retail_form(grid, index, count, itemname, sivr, buymodel)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  dialog.lbl_max_count.Text = nx_widestr(count)
  dialog.lbl_max_count.Visible = false
  dialog.ipt_count.Text = nx_widestr(1)
  if buymodel == 0 then
    dialog.ipt_count.Text = nx_widestr(1)
  end
  local tipinfo = nx_widestr(itemname)
  dialog.lbl_tip.Text = tipinfo
  dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
  dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
  local type, price = CAPITAL_TYPE_SILVER_CARD, sivr
  nx_execute("form_stage_main\\form_shop\\form_trade_buy", "init_buy_form", dialog, type, price, count)
  dialog.retail_mode = "buy"
  dialog.Visible = true
  dialog:ShowModal()
  local left = dialog.Left
  local top = dialog.Top
  local res, count, paymodel = nx_wait_event(100000000, dialog, "form_retail_return")
  if res == "ok" and countersign_again(left, top, itemname, count, sivr) then
    send_stall_buy_msg(index, count)
  end
end
function countersign_again(left, top, itemname, count, sivr)
  local gui = nx_value("gui")
  dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_confirm", true, false)
  local goumai = gui.TextManager:GetText("ui_stall_goumai_desc")
  dialog.ipt_count.Text = nx_widestr(count)
  dialog.lbl_tip.Text = nx_widestr(goumai .. itemname)
  if nx_int(sivr) > nx_int(0) then
    dialog.lbl_gold_mark1.Visible = false
    dialog.lbl_gold_mark2.Visible = false
    dialog.lbl_silver_mark1.Visible = true
    dialog.lbl_silver_mark2.Visible = true
    dialog.ipt_price.Text = nx_execute("util_functions", "trans_capital_string", sivr)
    dialog.ipt_total_price.Text = nx_execute("util_functions", "trans_capital_string", sivr * count)
    local mgr = nx_value("CapitalModule")
    if nx_is_valid(mgr) then
      local icon = mgr:GetCapitalIcon(nx_int(CAPITAL_TYPE_SILVER_CARD))
      dialog.lbl_silver_mark1.BackImage = icon
      dialog.lbl_silver_mark2.BackImage = icon
    end
  end
  dialog.Left = left
  dialog.Top = top
  dialog.trade_mode = "sell"
  dialog:ShowModal()
  res = nx_wait_event(100000000, dialog, "form_stage_main\\form_shop\\form_trade_buy_return_sell")
  if res == "ok" then
    return true
  end
  return false
end
function trans_price(price)
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  return price_ding, price_liang, price_wen
end
function format_price(ding, liang, wen)
  local fmt_text = nx_widestr(ding) .. nx_widestr(util_text("ui_Ding")) .. nx_widestr(liang) .. nx_widestr(util_text("ui_Liang")) .. nx_widestr(wen) .. nx_widestr(util_text("ui_Wen"))
  return fmt_text
end
function on_sell_grid_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(self.typeid))
  if not nx_is_valid(view) then
    return
  end
  local bind_index = self:GetBindIndex(index)
  local viewobj = view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return
  end
  if not view:FindRecord("offline_sellbox_table") then
    return
  end
  local row = view:FindRecordRow("offline_sellbox_table", 1, viewobj:QueryProp("UniqueID"))
  if row < 0 then
    return
  end
  local item_svil_price = view:QueryRecord("offline_sellbox_table", row, 7)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(self, index)
    item_data.StallPrice1 = nx_int64(item_svil_price)
  end
  if nx_is_valid(item_data) then
    local ConfigID = nx_execute("tips_data", "get_prop_in_item", item_data, "StallPrice1")
    nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
  end
end
function on_sell_grid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_buy_grid_mousein_grid(self, index)
  local item_config = ""
  local item_count = 0
  local item_max_count = 0
  local item_gold_price = 0
  local item_svil_price = 0
  item_config, item_count, item_max_count, item_gold_price, item_svil_price = get_buy_item_info(self, index)
  if item_config == nil or item_config == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if bExist == false then
    return
  end
  local prop_array = {}
  local item_name = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Name"))
  local item_image = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
  prop_array.IsShop = true
  prop_array.ConfigID = nx_string(item_config)
  prop_array.Amount = nx_int64(item_count)
  prop_array.MaxAmount = nx_int64(item_max_count)
  if nx_int(item_gold_price) > nx_int(0) then
    prop_array.StallPrice0 = nx_int64(item_gold_price)
    prop_array.StallPrice1 = nx_int64(0)
  end
  if nx_int(item_svil_price) > nx_int(0) then
    prop_array.StallPrice0 = nx_int64(0)
    prop_array.StallPrice1 = nx_int64(item_svil_price)
  end
  if not nx_is_valid(self.Data) then
    self.Data = nx_create("ArrayList", nx_current())
  end
  self.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(self.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", self.Data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), self.GridWidth, self.GridHeight, self.ParentForm)
end
function on_buy_grid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_buy_grid_rightclick_grid(self, selected_index)
  return
end
function on_buy_grid_select_changed(self, selected_index)
  local uniqueid, have_amount, configid = get_buy_hand_data()
  if uniqueid == "" or nx_int(have_amount) == nx_int(0) or configid == "" then
    return
  end
  local nConfigId, nCount, nMaxCount, nGoldPrice, nSvrPrice = get_buy_item_info(self, selected_index)
  if nConfigId == nil or nConfigId == "" then
    return
  end
  if nx_string(configid) ~= nx_string(nConfigId) then
    return
  end
  nCount = nMaxCount - nCount
  local real_amount = 0
  if nx_int(have_amount) > nx_int(nCount) then
    real_amount = nCount
  else
    real_amount = have_amount
  end
  local game_gui = nx_value("gui")
  local item_name = game_gui.TextManager:GetText(nConfigId)
  show_sell_item_retail_form(self, selected_index, uniqueid, real_amount, item_name, nGoldPrice, nSvrPrice)
end
function show_sell_item_confirm_form(grid, index, uniqueid, count, itemname, gold, sivr)
  local gui = nx_value("gui")
  dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_confirm", true, false)
  local chushou = gui.TextManager:GetText("ui_stall_chushou_desc")
  dialog.ipt_count.Text = nx_widestr(count)
  tipinfo = nx_widestr(chushou .. itemname)
  dialog.lbl_tip.Text = tipinfo
  if nx_int(gold) > nx_int(0) then
    dialog.lbl_gold_mark1.Visible = true
    dialog.lbl_gold_mark2.Visible = true
    dialog.lbl_silver_mark1.Visible = false
    dialog.lbl_silver_mark2.Visible = false
    dialog.ipt_price.Text = nx_execute("util_functions", "trans_capital_string", gold)
    dialog.ipt_total_price.Text = nx_execute("util_functions", "trans_capital_string", gold * count)
  elseif nx_int(sivr) > nx_int(0) then
    dialog.lbl_gold_mark1.Visible = false
    dialog.lbl_gold_mark2.Visible = false
    dialog.lbl_silver_mark1.Visible = true
    dialog.lbl_silver_mark2.Visible = true
    dialog.ipt_price.Text = nx_execute("util_functions", "trans_capital_string", sivr)
    dialog.ipt_total_price.Text = nx_execute("util_functions", "trans_capital_string", sivr * count)
    local mgr = nx_value("CapitalModule")
    if nx_is_valid(mgr) then
      local icon = mgr:GetCapitalIcon(nx_int(CAPITAL_TYPE_SILVER_CARD))
      dialog.lbl_silver_mark1.BackImage = icon
      dialog.lbl_silver_mark2.BackImage = icon
    end
  end
  if not nx_is_valid(grid) then
    return
  end
  dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
  dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
  dialog.trade_mode = "sell"
  dialog:ShowModal()
  res = nx_wait_event(100000000, dialog, "form_stage_main\\form_shop\\form_trade_buy_return_sell")
  if not nx_is_valid(grid) then
    return
  end
  if res == "ok" then
    local view_index = grid:GetBindIndex(index)
    custom_sell_purchase_item(view_index, uniqueid, count, sivr)
  end
end
function show_sell_item_retail_form(grid, index, uniqueid, count, itemname, gold, sivr)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  dialog.bSell = true
  dialog.lbl_max_count.Text = nx_widestr(count)
  dialog.lbl_max_count.Visible = false
  dialog.ipt_count.Text = nx_widestr(1)
  local tipinfo = nx_widestr(util_text("ui_PlsInputItemToSell")) .. nx_widestr(itemname) .. nx_widestr(util_text("ui_ItemAmount"))
  dialog.lbl_tip.Text = tipinfo
  dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
  dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
  if nx_int(gold) > nx_int(0) then
    dialog.lbl_gold_mark1.Visible = true
    dialog.lbl_gold_mark2.Visible = true
    dialog.lbl_silver_mark1.Visible = false
    dialog.lbl_silver_mark2.Visible = false
    dialog.ipt_price.Text = nx_execute("util_functions", "trans_capital_string", gold)
    dialog.lbl_s_price.Text = nx_widestr(gold)
    dialog.ipt_total_price.Text = nx_execute("util_functions", "trans_capital_string", gold)
    dialog.lbl_model.Text = nx_widestr(0)
  elseif nx_int(sivr) > nx_int(0) then
    dialog.lbl_gold_mark1.Visible = false
    dialog.lbl_gold_mark2.Visible = false
    dialog.lbl_silver_mark1.Visible = true
    dialog.lbl_silver_mark2.Visible = true
    dialog.ipt_price.Text = nx_execute("util_functions", "trans_capital_string", sivr)
    dialog.ipt_total_price.Text = nx_execute("util_functions", "trans_capital_string", sivr)
    dialog.lbl_s_price.Text = nx_widestr(sivr)
    dialog.lbl_model.Text = nx_widestr(1)
    local mgr = nx_value("CapitalModule")
    if nx_is_valid(mgr) then
      local icon = mgr:GetCapitalIcon(nx_int(CAPITAL_TYPE_SILVER_CARD))
      dialog.lbl_silver_mark1.BackImage = icon
      dialog.lbl_silver_mark2.BackImage = icon
    end
  end
  dialog.lbl_model.Visible = false
  dialog.lbl_s_price.Visible = false
  dialog.retail_mode = "sell"
  dialog.Visible = true
  dialog:ShowModal()
  local res, count, paymodel = nx_wait_event(100000000, dialog, "form_retail_return_sell")
  if res == "ok" then
    show_sell_item_confirm_form(grid, index, uniqueid, count, itemname, gold, sivr)
  end
end
function get_buy_item_info(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(view) then
    return
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return
  end
  local config_id = viewobj:QueryProp("ConfigID")
  local goldprice = viewobj:QueryProp("PurchasePrice0")
  local silverprice = viewobj:QueryProp("PurchasePrice1")
  local maxcount = viewobj:QueryProp("BuyCountAll")
  local count = viewobj:QueryProp("BuyedCount")
  return config_id, count, maxcount, goldprice, silverprice
end
function get_have_item_count(self, dest_config)
  local game_client = nx_value("game_client")
  local view_id = ""
  local goods_grid = nx_value("GoodsGrid")
  if nx_is_valid(goods_grid) then
    view_id = goods_grid:GetToolBoxViewport(nx_string(dest_config))
  end
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return 0
  end
  local viewobj_list = view:GetViewObjList()
  local CanSell = false
  local have_amount = 0
  for index, view_item in pairs(viewobj_list) do
    local config_id = view_item:QueryProp("ConfigID")
    if nx_string(config_id) == nx_string(dest_config) then
      local MaxAmount = view_item:QueryProp("MaxAmount")
      if nx_int(MaxAmount) == nx_int(1) then
        have_amount = have_amount + 1
      else
        have_amount = have_amount + view_item:QueryProp("Amount")
      end
      CanSell = true
    end
  end
  if CanSell == false then
    return 0
  end
  return have_amount
end
function on_btn_liuyan_click(btn)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_liuyan", true, false)
  form:Show()
end
function custom_sell_purchase_item(index, uniqueid, sellnum, sellsivr)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_SEL_PURCHASE_ITEM), nx_int(index), nx_string(uniqueid), nx_int(sellnum), nx_int64(sellsivr))
end
function close_stallbusiness()
  local f = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stallbusiness", false, false)
  if nil == f then
    return
  end
  if not nx_is_valid(f) then
    return
  end
  f:Close()
end
function on_selectobj_changed(form)
  if not nx_is_valid(form) then
    return
  end
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    close_stallbusiness()
    return
  end
  local playerObj = GetPlayer()
  if not nx_is_valid(playerObj) then
    close_stallbusiness()
    return
  end
  local state = playerObj:QueryProp("StallState")
  if 2 ~= state then
    close_stallbusiness()
    return
  end
  initForm(form)
end
function IsPlayerObj(obj)
  if not nx_is_valid(obj) then
    return false
  end
  local type = obj:QueryProp("Type")
  if TYPE_PLAYER == tonumber(type) then
    return true
  end
  return false
end
function GetPlayerByStallNpc(stallNpc)
  if not nx_is_valid(stallNpc) then
    return nil
  end
  local game_client = nx_value("game_client")
  local player = stallNpc:QueryProp("Player")
  local playerObj = game_client:GetSceneObj(nx_string(player))
  if IsPlayerObj(playerObj) then
    return playerObj
  end
  return nil
end
function GetPlayer()
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return nil
  end
  local playerObj
  if IsPlayerObj(target) then
    playerObj = target
  end
  return playerObj
end
function get_buy_hand_data()
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) or not nx_is_valid(gui) then
    return "", 0
  end
  if gui.GameHand:IsEmpty() then
    return "", 0
  end
  if gui.GameHand.Type ~= GHT_VIEWITEM then
    return "", 0
  end
  local toolbox_view = game_client:GetView(nx_string(gui.GameHand.Para1))
  if not nx_is_valid(toolbox_view) then
    return "", 0
  end
  local viewobj = toolbox_view:GetViewObj(nx_string(gui.GameHand.Para2))
  gui.GameHand:ClearHand()
  if nx_int(viewobj:QueryProp("BindStatus")) == nx_int(1) then
    return "", 0
  end
  local have_amount = viewobj:QueryProp("Amount")
  local uniqueid = viewobj:QueryProp("UniqueID")
  local configid = viewobj:QueryProp("ConfigID")
  return uniqueid, have_amount, configid
end
function on_btn_auction_click(btn)
  util_show_form("form_stage_main\\form_stall\\form_stallbusiness", false)
  nx_execute("form_stage_main\\form_auction\\form_auction_main", "open_form")
end
