require("share\\client_custom_define")
require("util_gui")
require("util_functions")
require("share\\logicstate_define")
require("share\\view_define")
require("define\\gamehand_type")
require("game_object")
require("util_vip")
local TotalCellCount = 60
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(self)
  setGridCount(self.buy_grid)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_STALL_PURCHASE_BOX, self.buy_grid, "form_stage_main\\form_stall\\form_stall_buy", "on_buy_viewport_changed")
  return 1
end
function setGridCount(grid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local level = client_player:QueryProp("StallLevel")
  local playerBuyCount = nx_execute("form_stage_main\\form_stall\\form_stall_main", "GetBuyCount", client_player)
  local cellCount = TotalCellCount
  grid.typeid = VIEWPORT_STALL_PURCHASE_BOX
  grid.beginindex = 1
  grid.endindex = nx_int(cellCount)
  grid.playerCount = playerBuyCount
  local grid_index = 0
  for view_index = grid.beginindex, grid.endindex do
    grid:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  grid.canselect = false
  grid.candestroy = false
  grid.cansplit = false
  grid.canlock = false
  grid.canarrange = false
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
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_buy_viewport_changed(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  local sellCount = nx_int(grid.endindex)
  if optype == "createview" then
    RefreshGrid(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
    RefreshGrid(grid)
  elseif optype == "additem" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_on_update_item", grid, index)
  elseif optype == "delitem" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_on_delete_item", grid, index)
  elseif optype == "updateitem" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_on_update_item", grid, index)
  end
  nx_execute("form_stage_main\\form_stall\\form_stall_main", "refresh_total_price", VIEWPORT_STALL_PURCHASE_BOX)
end
function RefreshGrid(grid)
  nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_fresh_all", grid)
end
function add_buy_by_rightclick(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local form = nx_value("form_stage_main\\form_stall\\form_stall_main")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.page_buy) then
    return
  end
  if not nx_is_valid(form.page_buy.buy_grid) then
    return
  end
  local src_amount = grid:GetItemNumber(index)
  local src_viewid = grid.typeid
  local src_pos = index + 1
  local selected_index = nx_execute("form_stage_main\\form_stall\\form_stall_main", "find_empty_pos", VIEWPORT_STALL_PURCHASE_BOX, 60) - 1
  local playerCount = nx_int(form.page_buy.buy_grid.playerCount)
  if nx_number(selected_index) > nx_number(playerCount) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local vip_status = nx_execute("util_vip", "is_vip", client_player, VT_NORMAL)
    if not vip_status then
      local form_prompt = nx_value("form_stage_main\\form_vip_prompt")
      if nx_is_valid(form_prompt) then
        form_prompt:Close()
      end
      form_prompt = util_show_form("form_stage_main\\form_vip_prompt", true)
      form_prompt.info_mltbox.HtmlText = gui.TextManager:GetText("ui_jhhy_5")
    end
    return
  end
  local client_role = get_client_player()
  if nx_is_valid(client_role) then
    local stallstate = client_role:QueryProp("StallState")
    if nx_int(stallstate) == nx_int(2) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7040"))
      return
    end
  end
  local view_id = nx_number(gui.GameHand.Para1)
  local view_index = nx_number(gui.GameHand.Para2)
  local amount = nx_number(gui.GameHand.Para3)
  local goods_grid = nx_value("GoodsGrid")
  if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(src_viewid)) then
    local view_index = grid:GetBindIndex(index)
    local addbag_index = nx_execute("form_stage_main\\form_bag_func", "get_addbag_index", view_index)
    if addbag_index ~= 0 then
      src_pos = view_index
    end
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local item_config = viewobj:QueryProp("ConfigID")
    if item_config then
      pop_purchase_set_form(form.page_buy.buy_grid, selected_index, nx_string(item_config))
    end
  end
end
function on_buy_grid_select_changed(self, index)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local selected_index = self:GetSelectItemIndex()
  local playerCount = nx_int(self.playerCount)
  if nx_number(selected_index) >= nx_number(playerCount) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local vip_status = nx_execute("util_vip", "is_vip", client_player, VT_NORMAL)
    if not vip_status then
      local form_prompt = nx_value("form_stage_main\\form_vip_prompt")
      if nx_is_valid(form_prompt) then
        form_prompt:Close()
      end
      form_prompt = util_show_form("form_stage_main\\form_vip_prompt", true)
      form_prompt.info_mltbox.HtmlText = gui.TextManager:GetText("ui_jhhy_5")
    end
    gui.GameHand:ClearHand()
    return
  end
  if gui.GameHand:IsEmpty() then
    return
  end
  local client_role = get_client_player()
  if nx_is_valid(client_role) then
    local stallstate = client_role:QueryProp("StallState")
    if nx_int(stallstate) == nx_int(2) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7040"))
      return
    end
  end
  local gamehand_type = gui.GameHand.Type
  if gamehand_type == GHT_FUNC then
    local func = gui.GameHand.Para1
    if func == "search" then
      local index = nx_number(gui.GameHand.Para2)
      gui.GameHand:ClearHand()
      push_search_item(self, selected_index, index)
    end
  elseif gamehand_type == GHT_VIEWITEM then
    local view_id = nx_number(gui.GameHand.Para1)
    local view_index = nx_number(gui.GameHand.Para2)
    local amount = nx_number(gui.GameHand.Para3)
    local goods_grid = nx_value("GoodsGrid")
    if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(view_id)) then
      gui.GameHand:ClearHand()
      local game_client = nx_value("game_client")
      local view = game_client:GetView(nx_string(view_id))
      local viewobj = view:GetViewObj(nx_string(view_index))
      if not nx_is_valid(viewobj) then
        return
      end
      local item_config = viewobj:QueryProp("ConfigID")
      if item_config then
        pop_purchase_set_form(self, selected_index, nx_string(item_config))
      end
    end
  end
end
function on_drop_in_buy_grid(grid, index)
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  if gamehand.IsDragged and not gamehand.IsDropped then
    nx_execute("form_stage_main\\form_stall\\form_stall_buy", "on_buy_grid_select_changed", grid, index)
    gamehand.IsDropped = true
  end
end
function push_search_item(grid, posto, posfrom)
  local item_config = nx_execute("form_stage_main\\form_stall\\form_stallsearch", "get_search_item_config", posfrom)
  if nx_string(item_config) == nx_string("") then
  else
    pop_purchase_set_form(grid, posto, nx_string(item_config))
  end
end
function on_btn_clear_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REMOVE_ALL_BUY))
end
function on_btn_sousuo_click(btn)
  util_show_form("form_stage_main\\form_stall\\form_stallsearch", true)
end
function pop_purchase_set_form(grid, posto, item_config)
  local playerCount = nx_int(grid.playerCount)
  if nx_number(posto) >= nx_number(playerCount) then
    return
  end
  local view_index = grid:GetBindIndex(posto)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if bExist == false then
    return
  end
  local item_MaxAmount = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("MaxAmount"))
  if item_MaxAmount == nil or item_MaxAmount == "" or nx_int(item_MaxAmount) <= nx_int(0) then
    item_MaxAmount = "1"
  end
  show_input_form(view_index, item_config, item_MaxAmount)
  return 1
end
function show_input_form(posto, item_config, total_num)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_sell_inputbox", true, false)
  dialog.lbl_total_num.Text = nx_widestr(total_num)
  local ding, liang, wen = nx_execute("form_stage_main\\form_stall\\form_stall_main", "find_item_price", VIEWPORT_STALL_PURCHASE_BOX, item_config)
  dialog.ipt_yb_ding.Text = nx_widestr(ding)
  dialog.ipt_yb_liang.Text = nx_widestr(liang)
  dialog.ipt_yb_wen.Text = nx_widestr(wen)
  dialog:ShowModal()
  local res, money_silver, number = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" then
    custom_set_purchase_item(posto, item_config, number, money_silver)
  end
end
function custom_set_purchase_item(pos, config, count, silver)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_SET_PURCHASE_ITEM), nx_int(pos), nx_string(config), nx_int(count), nx_int64(silver))
end
function on_buy_grid_rightclick_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("StallState")
  if state == 2 then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local bind_index = self:GetBindIndex(index)
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_DEL_PURCHASE_ITEM), nx_int(bind_index))
end
function on_buy_grid_doubleclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  local state = game_player:QueryProp("LogicState")
  if nx_int(state) == nx_int(101) or nx_int(state) == nx_int(111) then
    return
  end
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
  local count = viewobj:QueryProp("BuyCountAll")
  if goldprice <= 0 and silverprice <= 0 then
    return
  end
  if config_id == "" then
    return
  end
  if count <= 0 or goldprice <= 0 and silverprice <= 0 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_sell_inputbox", true, false)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(config_id))
  if bExist == false then
    return
  end
  local item_MaxAmount = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("MaxAmount"))
  if item_MaxAmount == nil or item_MaxAmount == "" then
    item_MaxAmount = "1"
  end
  dialog.lbl_total_num.Text = nx_widestr(item_MaxAmount)
  if 0 < goldprice then
    local ding, liang, wen = trans_price(goldprice)
  else
    local ding, liang, wen = trans_price(silverprice)
    dialog.ipt_yb_ding.Text = nx_widestr(ding)
    dialog.ipt_yb_liang.Text = nx_widestr(liang)
    dialog.ipt_yb_wen.Text = nx_widestr(wen)
  end
  dialog.ipt_number.Text = nx_widestr(count)
  dialog:ShowModal()
  local res, money_silver, new_count = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" then
    custom_set_purchase_item(bind_index, config_id, new_count, money_silver)
  end
end
function on_buy_grid_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  if nx_int(index + 1) > nx_int(self.playerCount) then
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
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(self, index)
    item_data.ConfigID = nx_string(viewobj:QueryProp("ConfigID"))
    item_data.StallPrice1 = nx_int64(viewobj:QueryProp("PurchasePrice1"))
    item_data.Amount = nx_int64(viewobj:QueryProp("BuyedCount"))
    item_data.MaxAmount = nx_int64(viewobj:QueryProp("BuyCountAll"))
    item_data.IsShop = true
  end
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), self.GridWidth, self.GridHeight, self.ParentForm)
  end
end
function on_buy_grid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function trans_price(price)
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  return price_ding, price_liang, price_wen
end
function view_get_item(item_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local view_id = ""
  local goods_grid = nx_value("GoodsGrid")
  if nx_is_valid(goods_grid) then
    view_id = goods_grid:GetToolBoxViewport(nx_string(item_id))
  end
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return 0
  end
  local total_num = 0
  local viewobj_list = view:GetViewObjList()
  for i, item in pairs(viewobj_list) do
    if item_id == item:QueryProp("ConfigID") then
      total_num = total_num + item:QueryProp("Amount")
    end
  end
  local view = game_client:GetView(nx_string(VIEWPORT_ADDTOOLBOX))
  if not nx_is_valid(view) then
    return 0
  end
  local viewobj_list = view:GetViewObjList()
  for i, item in pairs(viewobj_list) do
    if item_id == item:QueryProp("ConfigID") then
      total_num = total_num + item:QueryProp("Amount")
    end
  end
  return total_num
end
function open_kuorong()
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_kuorong", true, false)
  dialog.Type = 2
  dialog:ShowModal()
end
function on_btn_kuorong_click(btn)
end
function shengji_success()
  local form = util_get_form("form_stage_main\\form_stall\\form_stall_buy", false, false)
  if not nx_is_valid(form) then
    return
  end
  setGridCount(form.buy_grid)
  RefreshGrid(form.buy_grid)
end
