require("share\\view_define")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\sysinfo_define")
stall_old_pos_x = -1
stall_old_pos_y = -1
local stall_style_table = {
  [1] = "ui_FirstStyle",
  [2] = "ui_SecondStyle",
  [3] = "ui_thirdstyle"
}
function move_stall_form(self)
  local gui = nx_value("gui")
  self.Left = 0
  self.Top = (gui.Height - self.Height) / 2
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  self.sell_grid.typeid = VIEWPORT_SELFSHOP
  self.sell_grid.beginindex = 1
  self.sell_grid.endindex = 20
  local grid_index = 0
  for view_index = self.sell_grid.beginindex, self.sell_grid.endindex do
    self.sell_grid:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  self.sell_grid.canselect = false
  self.sell_grid.candestroy = false
  self.sell_grid.cansplit = false
  self.sell_grid.canlock = false
  self.sell_grid.canarrange = false
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_SELFSHOP, self.sell_grid, "form_stage_main\\form_stall\\form_stallmanager", "on_sell_viewport_changed")
  databinder:AddRolePropertyBind("StallState", "int", self.btn_stall, "form_stage_main\\form_stall\\form_stallmanager", "on_update_stall_state")
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(self.sell_grid)
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(self.sell_grid.typeid))
  if not nx_is_valid(view) then
    return 1
  end
  init_combobox_style(self)
  local stallpuff = view:QueryProp("Puff")
  if nx_string(stallpuff) ~= nx_string("0") then
    self.redit_puff.Text = nx_widestr(stallpuff)
  else
    self.redit_puff.Text = nx_widestr("")
  end
  local target = game_client:GetPlayer()
  if nx_is_valid(target) then
    local stallname = target:QueryProp("StallName")
    if nx_string(stallname) ~= nx_string("0") then
      self.edit_name.Text = nx_widestr(stallname)
    else
      self.edit_name.Text = nx_widestr("")
    end
  end
  local game_gui = nx_value("gui")
  if stall_old_pos_x == -1 then
    stall_old_pos_x = (game_gui.Width - self.Width) / 2
  end
  if stall_old_pos_y == -1 then
    stall_old_pos_y = (game_gui.Height - self.Height) / 2
  end
  move_stall_form(self)
  local bag_form = util_get_form("form_stage_main\\form_bag", false)
  if nx_is_valid(bag_form) and bag_form.Visible then
    nx_execute("form_stage_main\\form_bag", "move_bag_form", bag_form)
  end
  return 1
end
function main_form_close(self)
  local ini = nx_execute("form_stage_main\\form_stall\\form_stall_note", "get_stall_ini")
  if nil ~= ini and nx_is_valid(ini) then
    ini:WriteInteger("stall", "style", self.combobox_style.DropListBox.SelectIndex + 1)
    ini:SaveToFile()
  end
  local game_gui = nx_value("gui")
  stall_old_pos_x = self.Left
  stall_old_pos_y = self.Top
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self.sell_grid)
  databinder:DelRolePropertyBind("StallState", self.btn_stall)
  nx_execute("tips_game", "hide_tip", self)
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_stall\\form_stallmanager", nx_null())
  util_show_form("form_stage_main\\form_stall\\form_stallsearch", false)
  util_show_form("form_stage_main\\form_stall\\form_stall_note", false)
end
function on_btn_note_click(self)
  util_auto_show_hide_form("form_stage_main\\form_stall\\form_stall_note")
  local form_stall_note = nx_value("form_stage_main\\form_stall\\form_stall_note")
  if nx_is_valid(form_stall_note) then
    form_stall_note.AbsLeft = self.ParentForm.AbsLeft + self.ParentForm.Width
    form_stall_note.AbsTop = self.ParentForm.AbsTop
  end
end
function on_help_btn_click(self)
  local gui = nx_value("gui")
  local form_stump = nx_value("form_stage_main\\form_smallgame\\form_game_stump")
  if not nx_is_valid(form_stump) then
    form_stump = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_smallgame\\form_game_stump", true, false)
    nx_set_value("form_stage_main\\form_smallgame\\form_game_stump", form_stump)
  end
  form_stump.Limit = nx_int(20)
  form_stump:Show()
end
function on_close_btn_click(self)
  util_show_form("form_stage_main\\form_stall\\form_stall_note", false)
  local client_role = get_client_player()
  if nx_is_valid(client_role) then
    local stallstate = client_role:QueryProp("StallState")
    if stallstate == 2 then
      self.Parent.Visible = false
      return 0
    end
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_SureToCancelStallbox"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  dialog.Left = self.Parent.Left + (self.Parent.Width - dialog.Width) / 2
  dialog.Top = self.Parent.Top + (self.Parent.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_stall_stop_stall")
    util_show_form("form_stage_main\\form_stall\\form_stallmanager", false)
  end
end
function check_stall_name(name)
  if name == nx_widestr("") then
    return false
  end
  local temp = nx_string(name)
  temp = string.gsub(temp, "%s+", "")
  return 0 < string.len(temp)
end
function on_stall_btn_click(self)
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    nx_log("no client player")
    return 0
  end
  local root = self.Parent
  local stallstate = client_role:QueryProp("StallState")
  if stallstate == 1 then
    if is_empty_stall(self.ParentForm) then
      return 0
    end
    local name = nx_widestr(root.edit_name.Text)
    if not check_stall_name(name) then
      local gui = nx_value("gui")
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
      dialog.info_label.Text = nx_widestr(util_text("ui_StallNameCanNotBeEmpty"))
      dialog.Left = root.Left + (root.Width - dialog.Width) / 2
      dialog.Top = root.Top + (root.Height - dialog.Height) / 2
      dialog:ShowModal()
      nx_wait_event(100000000, dialog, "error_return")
      return 0
    end
    local cur_sel = root.combobox_style.DropListBox.SelectIndex + 1
    if cur_sel < 1 then
      cur_sel = 1
    end
    local role = nx_value("role")
    nx_execute("custom_sender", "custom_stall_begin_stall", root.edit_name.Text, cur_sel, root.redit_puff.Text)
  elseif stallstate == 2 then
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(util_text("ui_SureToGoBackToStallPos"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    dialog.Left = root.Left + (root.Width - dialog.Width) / 2
    dialog.Top = root.Top + (root.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_stall_return_ready")
    end
  end
  return 1
end
function on_sell_viewport_changed(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
    local viewobj = view:GetViewObj(nx_string(index))
    local goldprice = viewobj:QueryProp("StallPrice0")
    local sivrprice = viewobj:QueryProp("StallPrice1")
    if goldprice <= 0 and sivrprice <= 0 then
      set_price_form_add_item(grid, view_ident, index)
    end
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  if optype == "updateview" or optype == "createview" then
    on_purchase_changed(grid.Parent, view)
  end
  return 1
end
function on_buy_grid_select(self)
  local form = self.ParentForm
  local sell_grid = form.sell_grid
  sell_grid:SetSelectItemIndex(-1)
  local gui = nx_value("gui")
  local selected_index = self:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    return
  end
  local gamehand_type = gui.GameHand.Type
  if gamehand_type == GHT_FUNC then
    local func = gui.GameHand.Para1
    if func == "search" then
      local client_role = get_client_player()
      if nx_is_valid(client_role) then
        local stallstate = client_role:QueryProp("StallState")
        if stallstate == 2 then
          disp_error(util_text("ui_NoOperationWhenStall"))
          return
        end
      end
      local index = nx_number(gui.GameHand.Para2)
      push_search_item(self, selected_index, index)
      gui.GameHand:ClearHand()
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
function on_sell_grid_select(grid)
  local form = grid.ParentForm
  local buy_grid = form.buy_grid
  buy_grid:SetSelectItemIndex(-1)
  local selected_index = grid:GetSelectItemIndex()
  local view_index = grid:GetBindIndex(selected_index)
  local gui = nx_value("gui")
  local gamehand_type = gui.GameHand.Type
  if gamehand_type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    local bind = 0
    if nx_is_valid(viewobj) then
      bind = viewobj:QueryProp("BindStatus")
      if nx_int(bind) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7043"))
        return
      end
    end
    local cant_exchange = 0
    if nx_is_valid(viewobj) then
      cant_exchange = viewobj:QueryProp("CantExchange")
      if nx_int(cant_exchange) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
        return
      end
    end
    local found = find_item_in_stallbox(viewobj, get_unique_id)
    if found then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7083"))
      gui.GameHand:ClearHand()
      return 0
    end
    local goldprice = 0
    local silverprice = 0
    local item = find_item_in_stallbox(viewobj, get_congid_id)
    if item ~= nil and nx_is_valid(item) then
      goldprice = item:QueryProp("StallPrice0")
      silverprice = item:QueryProp("StallPrice1")
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stallinputbox", true, false)
    dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
    dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
    local price = 0
    if 0 < goldprice then
      dialog.rbtn_gold.Checked = true
      price = goldprice
    else
      dialog.rbtn_silver.Checked = true
      price = silverprice
    end
    local ding, liang, wen = trans_price(price)
    dialog.ipt_price_ding.Text = nx_widestr(ding)
    dialog.ipt_price_liang.Text = nx_widestr(liang)
    dialog.ipt_price_wen.Text = nx_widestr(wen)
    dialog:ShowModal()
    local res, money_gold, money_silver = nx_wait_event(100000000, dialog, "stall_price_input_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_stall_add_item", src_viewid, src_pos, view_index, money_gold, money_silver)
    end
    local gui = nx_value("gui")
    gui.GameHand:ClearHand()
  end
end
function on_sell_grid_select_old(self)
  local gui = nx_value("gui")
  local selected_index = self:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    if self:IsEmpty(selected_index) then
      return 1
    end
    if self.canselect then
      local photo = self:GetItemImage(selected_index)
      local amount = self:GetItemNumber(selected_index)
      gui.GameHand:SetHand(GHT_VIEWITEM, photo, nx_string(self.typeid), nx_string(selected_index + self.beginindex), nx_string(amount), "")
    end
  else
    if gui.GameHand.Type ~= GHT_VIEWITEM then
      return
    end
    if self.typeid <= 0 then
      return 1
    end
    local view_id = nx_number(gui.GameHand.Para1)
    local view_index = nx_number(gui.GameHand.Para2)
    local amount = nx_number(gui.GameHand.Para3)
    if self.canselect then
      if self.typeid == VIEWPORT_TOOL and view_id == VIEWPORT_SELFSHOP then
        nx_execute("custom_sender", "custom_stall_moveto_toolbox", view_index, amount)
      elseif self.typeid == VIEWPORT_SELFSHOP and view_id == VIEWPORT_TOOL then
        nx_execute("custom_sender", "custom_stall_moveto_stall", view_index, amount, 1, 1, 1, 1)
      else
        nx_execute("custom_sender", "custom_move_item", view_id, view_index, amount, self.typeid, selected_index + self.beginindex)
      end
      gui.GameHand:ClearHand()
    end
  end
end
function set_price_form_add_item(grid, view_ident, index)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stallinputbox", true, false)
  dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
  dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
  dialog.rbtn_silver.Checked = true
  dialog:ShowModal()
  local res, money_gold, money_silver = nx_wait_event(100000000, dialog, "stall_price_input_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_stall_set_itemprice", index, money_gold, money_silver)
  else
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_SELFSHOP))
    local viewobj = view:GetViewObj(nx_string(index))
    if not nx_is_valid(viewobj) then
      return 0
    end
    local cur_amount = viewobj:QueryProp("Amount")
    local toolbox_id = ""
    local goods_grid = nx_value("GoodsGrid")
    if nx_is_valid(goods_grid) then
      toolbox_id = goods_grid:GetToolBoxViewport(viewobj)
    end
    nx_execute("custom_sender", "custom_move_item", VIEWPORT_SELFSHOP, index, cur_amount, toolbox_id, 0)
  end
  return 1
end
function on_mousein_sell_grid(self, index)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(self, index)
  end
  nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
end
function on_mouseout_sell_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function is_empty_stall(self)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SELFSHOP))
  if nx_is_valid(view) and 0 < table.getn(view:GetViewObjList()) then
    return false
  end
  local count = self.buy_grid.RowNum * self.buy_grid.ClomnNum
  for index = 0, count - 1 do
    local prop_key = "Purchase" .. index
    local prop_str = view:QueryProp(nx_string(prop_key))
    if nx_string(prop_str) ~= "" and nx_string(prop_str) ~= "0" then
      return false
    end
  end
  return true
end
function on_mousein_buy_grid(self, index)
  local game_client = nx_value("game_client")
  local stall = game_client:GetView(nx_string(VIEWPORT_SELFSHOP))
  local prop_key = "Purchase" .. index
  local prop_str = stall:QueryProp(nx_string(prop_key))
  local prop_table = util_split_string(nx_string(prop_str), nx_string(","))
  if not prop_table then
    return
  end
  local item_config = prop_table[1]
  local item_count = prop_table[2]
  local item_price = prop_table[4]
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
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
  prop_array.ConfigID = nx_string(item_config)
  prop_array.Amount = nx_int64(0)
  prop_array.MaxAmount = nx_int64(item_count)
  prop_array.BuyPrice1 = nx_int64(item_price)
  prop_array.ItemType = nx_int64(item_type)
  if not nx_is_valid(self.Data) then
    self.Data = nx_create("ArrayList", nx_current())
  end
  self.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(self.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", self.Data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), self.GridWidth, self.GridHeight, self.ParentForm)
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
function on_mouseout_buy_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
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
  nx_execute("custom_sender", "custom_stall_remove_item", view_index)
end
function on_sell_grid_doubleclick(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("StallState")
  if state ~= 1 then
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
  local goldprice = viewobj:QueryProp("StallPrice0")
  local silverprice = viewobj:QueryProp("StallPrice1")
  if goldprice <= 0 and silverprice <= 0 then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stallinputbox", true, false)
  dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
  dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
  dialog.rbtn_silver.Checked = true
  local ding, liang, wen = trans_price(silverprice)
  dialog.ipt_price_ding.Text = nx_widestr(ding)
  dialog.ipt_price_liang.Text = nx_widestr(liang)
  dialog.ipt_price_wen.Text = nx_widestr(wen)
  dialog:ShowModal()
  local res, money_gold, money_silver = nx_wait_event(100000000, dialog, "stall_price_input_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_stall_set_itemprice", bind_index, money_gold, money_silver)
  end
end
function get_purchase_item_info(index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SELFSHOP))
  if not nx_is_valid(view) then
    return
  end
  local item_name = string.format("Purchase%d", index)
  local item_prop = view:QueryProp(item_name)
  local config_id, count, gold, silver = unpack(util_split_string(item_prop, ","))
  return config_id, tonumber(count), tonumber(gold), tonumber(silver)
end
function on_buy_grid_doubleclick(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  local stall_state = game_player:QueryProp("StallState")
  if stall_state ~= 1 then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_SELFSHOP))
  if not nx_is_valid(view) then
    return
  end
  local config_id, count, goldprice, silverprice = get_purchase_item_info(index)
  if not (config_id and count and goldprice) or not silverprice then
    return
  end
  if count <= 0 and goldprice <= 0 and silverprice <= 0 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_purchase_dialog", true, false)
  dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
  dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
  dialog.rbtn_silver.Checked = true
  local ding, liang, wen = trans_price(silverprice)
  dialog.ipt_price_ding.Text = nx_widestr(ding)
  dialog.ipt_price_liang.Text = nx_widestr(liang)
  dialog.ipt_price_wen.Text = nx_widestr(wen)
  dialog.ipt_count.Text = nx_widestr(count)
  dialog:ShowModal()
  local res, money_gold, money_silver, new_count = nx_wait_event(100000000, dialog, "purchase_price_input_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_set_purchase_item", index, config_id, new_count, money_gold, money_silver)
  end
end
function on_btn_buy_click(self)
  util_auto_show_hide_form("form_stage_main\\form_stall\\form_stallsearch")
end
function push_search_item(grid, posto, posfrom)
  local item_config = nx_execute("form_stage_main\\form_stall\\form_stallsearch", "get_search_item_config", posfrom)
  if nx_string(item_config) == nx_string("") then
  else
    pop_purchase_set_form(grid, posto, nx_string(item_config))
  end
end
function pop_purchase_set_form(grid, posto, configid)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_purchase_dialog", true, false)
  dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
  dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
  dialog.rbtn_silver.Checked = true
  dialog:ShowModal()
  local res, money_gold, money_silver, count = nx_wait_event(100000000, dialog, "purchase_price_input_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_set_purchase_item", posto, configid, count, money_gold, money_silver)
  end
  return 1
end
function on_purchase_changed(form, stall)
  local nRealPos = 0
  for nIndex = 0, 6 do
    local prop_key = "Purchase" .. nIndex
    local prop_str = stall:QueryProp(nx_string(prop_key))
    local prop_table = util_split_string(nx_string(prop_str), nx_string(","))
    if prop_table then
      local prop_count = table.getn(prop_table)
      if 0 < prop_count then
        local item_config = prop_table[1]
        if nx_string(item_config) ~= nx_string("") then
          local item_count = prop_table[2]
          local ItemQuery = nx_value("ItemQuery")
          if nx_is_valid(ItemQuery) then
            local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
            if bExist == true then
              local item_image = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(item_config), "Photo")
              form.buy_grid:AddItem(nx_int(nRealPos), nx_string(item_image), nx_widestr(item_config), nx_int(item_count), -1)
            end
          end
        end
      else
        form.buy_grid:DelItem(nx_int(nRealPos))
      end
    end
    nRealPos = nRealPos + 1
  end
end
function on_buy_grid_rightclick_grid(self, index)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("StallState")
  if state == 2 then
    return
  end
  nx_execute("custom_sender", "custom_del_purchase_item", index)
end
function on_update_stall_state(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local root = btn.Parent
  local form = btn.ParentForm
  local state = client_player:QueryProp("StallState")
  if nx_int(state) == nx_int(2) then
    btn.Text = nx_widestr(util_text("ui_CancelStallBox"))
    root.redit_puff.Enabled = false
    root.edit_name.Enabled = false
    root.combobox_style.Enabled = false
    root.sell_grid.Enabled = false
    root.buy_grid.Enabled = false
    form.btn_price.Visible = false
  else
    btn.Text = nx_widestr(util_text("ui_MakeStallbox"))
    root.redit_puff.Enabled = true
    root.edit_name.Enabled = true
    root.combobox_style.Enabled = true
    root.sell_grid.Enabled = true
    root.buy_grid.Enabled = true
    form.btn_price.Visible = true
  end
end
function on_btn_price_click(btn)
  local form = btn.ParentForm
  local grid = form.sell_grid
  local index = grid:GetSelectItemIndex()
  if 0 <= index then
    on_sell_grid_doubleclick(grid, index)
    return
  end
  grid = form.buy_grid
  index = grid:GetSelectItemIndex()
  if 0 <= index then
    on_buy_grid_doubleclick(grid, index)
  end
end
function init_combobox_style(form)
  local default_style = 1
  local ini = nx_execute("form_stage_main\\form_stall\\form_stall_note", "get_stall_ini")
  if nil ~= ini and nx_is_valid(ini) then
    default_style = ini:ReadInteger("stall", "style", 1)
  end
  if default_style < 1 or 3 < default_style then
    default_style = 1
  end
  if not check_stall_style(default_style) then
    default_style = 1
  end
  local self = form
  self.combobox_style.InputEdit.Text = nx_widestr("")
  self.combobox_style.DropListBox:ClearString()
  for _, item_str in ipairs(stall_style_table) do
    self.combobox_style.DropListBox:AddString(nx_widestr(util_text(item_str)))
  end
  self.combobox_style.DropListBox.SelectIndex = default_style - 1
  self.combobox_style.Text = nx_widestr(util_text(stall_style_table[default_style]))
  nx_execute("custom_sender", "custom_set_stall_style", default_style)
end
function on_combobox_style_selected(self)
  local index = self.DropListBox.SelectIndex + 1
  if not check_stall_style(index) then
    local text = ""
    if index == 2 then
      text = util_text("ui_baitan020")
    elseif index == 3 then
      text = util_text("ui_baitan021")
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(text)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog.cancel_btn.Visible = false
    dialog.ok_btn.Left = (dialog.Width - dialog.ok_btn.Width) / 2
    dialog:ShowModal()
    dialog.Left = self.ParentForm.Left + (self.ParentForm.Width - dialog.Width) / 2
    dialog.Top = self.ParentForm.Top + (self.ParentForm.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    self.InputEdit.Text = nx_widestr(util_text(stall_style_table[1]))
    self.DropListBox.SelectIndex = 0
    return
  end
  nx_execute("custom_sender", "custom_set_stall_style", index)
end
function get_congid_id(item)
  return item:QueryProp("ConfigID")
end
function get_unique_id(item)
  return item:QueryProp("UniqueID")
end
function find_item_in_stallbox(item, pred)
  if not nx_is_valid(item) then
    return
  end
  local value = pred(item)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SELFSHOP))
  if not nx_is_valid(view) then
    return
  end
  local item
  local obj_list = view:GetViewObjList()
  for _, obj in ipairs(obj_list) do
    if value == pred(obj) then
      item = obj
    end
  end
  return item
end
function check_stall_style(index)
  local origin_ids
  if index == 1 then
    origin_ids = nil
  elseif index == 2 then
    origin_ids = {
      603,
      606,
      609,
      612
    }
  elseif index == 3 then
    origin_ids = {
      604,
      607,
      610,
      613
    }
  end
  if origin_ids == nil then
    return true
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return true
  end
  for _, id in ipairs(origin_ids) do
    if origin_manager:IsCompletedOrigin(id) then
      return true
    end
  end
  return false
end
