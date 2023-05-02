require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("define\\gamehand_type")
require("util_gui")
require("util_functions")
require("custom_sender")
require("util_vip")
local TotalCellCount = 60
function main_form_init(form)
  form.Fixed = false
  form.form_bag = nil
  return 1
end
function on_main_form_open(self)
  setGridCount(self.sell_grid)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_OFFLINE_SELL_BOX, self.sell_grid, "form_stage_main\\form_stall\\form_stall_sell", "on_sell_viewport_changed")
  return 1
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
function setGridCount(grid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local playerSellCount = nx_execute("form_stage_main\\form_stall\\form_stall_main", "GetSellCount", client_player)
  local cellCount = TotalCellCount
  grid.typeid = VIEWPORT_OFFLINE_SELL_BOX
  grid.beginindex = 1
  grid.endindex = nx_int(cellCount)
  grid.playerCount = playerSellCount
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
function on_sell_viewport_changed(grid, optype, view_ident, index)
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
    cover_goods_grid(grid.ParentForm, VIEWPORT_OFFLINE_SELL_BOX)
  elseif optype == "delitem" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_on_delete_item", grid, index)
  elseif optype == "updateitem" then
    nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_on_update_item", grid, index)
  end
  nx_execute("form_stage_main\\form_stall\\form_stall_main", "refresh_total_price", VIEWPORT_OFFLINE_SELL_BOX)
  return 1
end
function RefreshSell()
  local form = util_get_form("form_stage_main\\form_stall\\form_stall_sell", false, false)
  if not nx_is_valid(form) then
    return
  end
  setGridCount(form.sell_grid)
  RefreshGrid(form.sell_grid)
end
function RefreshGrid(grid)
  nx_execute("form_stage_main\\form_stall\\stall_goods_grid", "view_grid_fresh_all", grid)
end
function add_sell_by_rightclick(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local form = nx_value("form_stage_main\\form_stall\\form_stall_main")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.page_sell) then
    return
  end
  if not nx_is_valid(form.page_sell.sell_grid) then
    return
  end
  local src_amount = grid:GetItemNumber(index)
  local src_viewid = grid.typeid
  local src_pos = index + 1
  local selected_index = nx_execute("form_stage_main\\form_stall\\form_stall_main", "find_empty_pos", VIEWPORT_OFFLINE_SELL_BOX, 60)
  local playerCount = nx_int(form.page_sell.sell_grid.playerCount)
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
  local view_index = grid:GetBindIndex(index)
  local addbag_index = nx_execute("form_stage_main\\form_bag_func", "get_addbag_index", view_index)
  if addbag_index ~= 0 then
    src_pos = view_index
  end
  local view = game_client:GetView(nx_string(src_viewid))
  local viewobj = view:GetViewObj(nx_string(src_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  if viewobj:FindProp("BindStatus") then
    local bind = viewobj:QueryProp("BindStatus")
    if nx_int(bind) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7043"))
      return
    end
  end
  if viewobj:FindProp("CantExchange") then
    local cant_exchange = viewobj:QueryProp("CantExchange")
    if nx_int(cant_exchange) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
      return
    end
  end
  if viewobj:FindProp("LockStatus") then
    local lock_status = viewobj:QueryProp("LockStatus")
    if nx_int(lock_status) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
      return
    end
  end
  local client_player = game_client:GetPlayer()
  if nx_int(client_player:QueryProp("StallState")) == nx_int(2) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7040"))
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_sell_inputbox", true, false)
  dialog.lbl_total_num.Text = nx_widestr(src_amount)
  if viewobj:FindProp("ConfigID") then
    local ConfigID = viewobj:QueryProp("ConfigID")
    if ConfigID ~= "" then
      local ding, liang, wen = nx_execute("form_stage_main\\form_stall\\form_stall_main", "find_item_price", VIEWPORT_OFFLINE_SELL_BOX, ConfigID)
      dialog.ipt_yb_ding.Text = nx_widestr(ding)
      dialog.ipt_yb_liang.Text = nx_widestr(liang)
      dialog.ipt_yb_wen.Text = nx_widestr(wen)
    end
  end
  if nx_int(src_amount) <= nx_int(0) then
    return
  end
  dialog.lbl_total_sign.Visible = false
  dialog.lbl_total_num.Visible = false
  dialog.ipt_number.ReadOnly = true
  dialog.ipt_number.Text = nx_widestr(src_amount)
  dialog:ShowModal()
  local res, money_silver, number = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" and nx_is_valid(viewobj) then
    custom_offline_sell_add_item(src_viewid, src_pos, selected_index, money_silver, number, viewobj)
  end
end
function on_sell_grid_select(grid, index)
  local gui = nx_value("gui")
  local form = grid.ParentForm
  local selected_index = grid:GetSelectItemIndex()
  local playerCount = nx_int(grid.playerCount)
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
  local view_index = grid:GetBindIndex(selected_index)
  local gamehand_type = gui.GameHand.Type
  if gamehand_type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local src_amount = nx_int(gui.GameHand.Para3)
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local bind = 0
    if viewobj:FindProp("BindStatus") then
      bind = viewobj:QueryProp("BindStatus")
      if nx_int(bind) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7043"))
        return
      end
    end
    local cant_exchange = 0
    if viewobj:FindProp("CantExchange") then
      cant_exchange = viewobj:QueryProp("CantExchange")
      if nx_int(cant_exchange) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
        return
      end
    end
    local lock_status = 0
    if viewobj:FindProp("LockStatus") then
      lock_status = viewobj:QueryProp("LockStatus")
      if nx_int(lock_status) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
        return
      end
    end
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if nx_int(client_player:QueryProp("StallState")) == nx_int(2) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7040"))
      return
    end
    if nx_number(src_viewid) ~= VIEWPORT_EQUIP_TOOL and nx_number(src_viewid) ~= VIEWPORT_TOOL and nx_number(src_viewid) ~= VIEWPORT_MATERIAL_TOOL and nx_number(src_viewid) ~= VIEWPORT_TASK_TOOL then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
      return
    end
    gui.GameHand:ClearHand()
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_sell_inputbox", true, false)
    dialog.lbl_total_num.Text = nx_widestr(src_amount)
    if viewobj:FindProp("ConfigID") then
      local ConfigID = viewobj:QueryProp("ConfigID")
      if ConfigID ~= "" then
        local ding, liang, wen = nx_execute("form_stage_main\\form_stall\\form_stall_main", "find_item_price", VIEWPORT_OFFLINE_SELL_BOX, ConfigID)
        dialog.ipt_yb_ding.Text = nx_widestr(ding)
        dialog.ipt_yb_liang.Text = nx_widestr(liang)
        dialog.ipt_yb_wen.Text = nx_widestr(wen)
      end
    end
    if nx_int(src_amount) <= nx_int(0) then
      return
    end
    dialog.lbl_total_sign.Visible = false
    dialog.lbl_total_num.Visible = false
    dialog.ipt_number.ReadOnly = true
    dialog.ipt_number.Text = nx_widestr(src_amount)
    dialog:ShowModal()
    local res, money_silver, number = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
    if res == "ok" and nx_is_valid(viewobj) then
      custom_offline_sell_add_item(src_viewid, src_pos, view_index, money_silver, number, viewobj)
    end
  end
end
function on_btn_clear_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REMOVE_ALL_SELL), nx_int(1))
end
function custom_offline_sell_add_item(src_viewid, src_pos, dst_pos, silver, num, viewobj)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if not (nx_is_valid(viewobj) and viewobj:FindProp("ConfigID")) or not viewobj:FindProp("UniqueID") then
    return 0
  end
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) and nx_find_method(form_logic, "SaveFightInfoToFile") then
    form_logic:SaveStallPriceInfo(nx_widestr(viewobj:QueryProp("ConfigID")) .. nx_widestr("/") .. nx_widestr(viewobj:QueryProp("UniqueID")) .. nx_widestr("/") .. nx_widestr(nx_int(nx_number(silver) / 1000000)) .. nx_widestr("/") .. nx_widestr(nx_int(nx_number(silver) % 1000000 / 1000)) .. nx_widestr("/") .. nx_widestr(nx_int(nx_number(silver) % 1000)) .. nx_widestr("/"))
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ADD_OFFLINE_SELL_ITEM), nx_int(src_viewid), nx_int(src_pos), nx_int(dst_pos), nx_int64(silver), nx_int(num))
end
function on_sell_grid_rightclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("StallState")
  if state == 2 then
    return
  end
  local view_index = grid:GetBindIndex(index)
  custom_sell_remove_item(view_index)
end
function custom_sell_remove_item(src_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_REMOVE_SELL_ITEM), nx_int(src_pos))
end
function on_sell_grid_doubleclick(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("LogicState")
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
  if not view:FindRecord("offline_sellbox_table") then
    return
  end
  local row = view:FindRecordRow("offline_sellbox_table", 1, viewobj:QueryProp("UniqueID"))
  if row < 0 then
    return
  end
  local silverprice = view:QueryRecord("offline_sellbox_table", row, 7)
  if silverprice <= 0 then
    return
  end
  local sellCount = view:QueryRecord("offline_sellbox_table", row, 5)
  if sellCount <= 0 then
    return
  end
  local totalCount = viewobj:QueryProp("Amount")
  if totalCount <= 0 then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_sell_inputbox", true, false)
  local ding, liang, wen = trans_price(silverprice)
  dialog.ipt_yb_ding.Text = nx_widestr(ding)
  dialog.ipt_yb_liang.Text = nx_widestr(liang)
  dialog.ipt_yb_wen.Text = nx_widestr(wen)
  if nx_int(totalCount) <= nx_int(0) then
    return
  end
  dialog.lbl_total_num.Text = nx_widestr(totalCount)
  dialog.ipt_number.Text = nx_widestr(totalCount)
  dialog.lbl_total_sign.Visible = false
  dialog.lbl_total_num.Visible = false
  dialog.ipt_number.ReadOnly = true
  dialog:ShowModal()
  local res, money_silver, number = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" then
    custom_sell_set_itemprice(bind_index, money_silver, number)
  end
end
function on_drop_in_sell_grid(grid, index)
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  if gamehand.IsDragged and not gamehand.IsDropped then
    nx_execute("form_stage_main\\form_stall\\form_stall_sell", "on_sell_grid_select", grid, index)
    gamehand.IsDropped = true
  end
end
function custom_sell_set_itemprice(pos, silver, sellCount)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_SET_SELL_ITEMPRICE), nx_int(pos), nx_int64(silver), nx_int(sellCount))
end
function trans_price(price)
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  return price_ding, price_liang, price_wen
end
function cover_goods_grid(form, viewport)
  if nx_is_valid(form.form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form.form_bag)
  end
end
function on_mousein_sell_grid(self, index)
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
function on_mouseout_sell_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function open_kuorong()
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_kuorong", true, false)
  dialog.Type = 1
  dialog:ShowModal()
end
function on_btn_kuorong_click(btn)
end
