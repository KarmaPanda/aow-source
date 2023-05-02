require("util_gui")
require("game_object")
require("util_functions")
require("goods_grid")
require("share\\view_define")
require("define\\tip_define")
require("tips_func_equip")
require("util_vip")
local ARRAYLISTNAME = "exchange_conditionid_list"
local EXCHANGE_TYPE_NORMAL = 0
local EXCHANGE_TYPE_GUILDBUILDING = 1
function main_form_init(form)
  form.Fixed = false
  form.item_obj = nil
  form.viewid = 0
  form.index = 0
  form.shop_id = ""
  form.page = 0
  form.pos = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  gui.Focused = form.ipt_count
  form.imagegrid_goods:SetBindIndex(nx_int(0), nx_int(1))
  for i = 1, 10 do
    form.form_shop_goods:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  form.form_shop_goods.canselect = flase
  form.form_shop_goods.candestroy = flase
  init_conditionid_list(form)
  init_form(form)
end
function on_main_form_close(form)
  destroy_conditionid_list(form)
  local exchange_item_manager = nx_value("exchange_item_manager")
  if nx_is_valid(exchange_item_manager) then
    exchange_item_manager:ClearCurExchangeData()
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  on_btn_cancel_click(btn)
end
function on_btn_exchange_click(btn)
  local form = btn.ParentForm
  local count = nx_int(form.ipt_count.Text)
  if count > nx_int(0) then
    nx_execute("custom_sender", "custom_exchange_item", form.shop_id, form.page, form.pos, count)
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "form_retail_return", "cancel")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_ipt_count_changed(self)
  local form = self.ParentForm
  local content = nx_string(self.Text)
  if content == "-" then
    self.Text = nx_widestr("")
    return
  end
  local goods_num = nx_number(content)
  local viewobj = form.item_obj
  if not nx_is_valid(viewobj) then
    return
  end
  if not viewobj:FindProp("MaxAmount") then
    return
  end
  local max_value = viewobj:QueryProp("MaxAmount")
  if goods_num > max_value then
    local text = string.sub(content, 1, string.len(content) - 1)
    goods_num = nx_number(text)
    self.Text = nx_widestr(text)
    self.InputPos = nx_ws_length(self.Text)
  end
  if goods_num <= 0 then
    self.Text = nx_widestr("")
    return
  end
  update_need_goods(self.ParentForm, goods_num)
  update_consume(self.ParentForm, goods_num)
end
function on_imagegrid_goods_mousein_grid(grid, index)
  local form = grid.ParentForm
  if grid:IsEmpty(index) then
    return
  end
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local viewobj = form.item_obj
  if not nx_is_valid(viewobj) then
    return
  end
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) > nx_int(0) then
    viewobj.exchange_item = true
  end
  nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
end
function on_imagegrid_goods_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_form_shop_goods_mousein_grid(grid, index)
  local form = grid.ParentForm
  if grid:IsEmpty(index) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    local viewobj = GoodsGrid:GetItemData(grid, index)
    local bHave, total = isHaveItem(viewobj.ConfigID, viewobj.Count)
    viewobj.Amount = bHave and viewobj.Count or total
    viewobj.MaxAmount = viewobj.Count
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
  end
end
function on_form_shop_goods_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function init_form(form)
  update_exchange_goods(form)
  update_need_goods(form, 1)
  update_condition(form)
  update_consume(form, 1)
  update_control_layout(form)
end
function update_exchange_goods(form)
  local viewobj = form.item_obj
  if not nx_is_valid(viewobj) then
    return
  end
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) == nx_int(0) then
    return
  end
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    local item_data = nx_create("ArrayList", nx_current())
    local proplist = viewobj:GetPropList()
    for i, prop in pairs(proplist) do
      item_data[prop] = viewobj:QueryProp(prop)
    end
    GoodsGrid:GridAddItem(form.imagegrid_goods, 0, item_data)
    form.imagegrid_goods:SetBindIndex(0, 1)
  end
end
function update_need_goods(form, exchange_num)
  local viewobj = form.item_obj
  if not nx_is_valid(viewobj) then
    return
  end
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) == nx_int(0) then
    return
  end
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  GoodsGrid:GridClear(form.form_shop_goods)
  form.groupbox_items.Visible = false
  local exchange_item_list = exchange_item_manager:GetCurItemList()
  local item_num = table.getn(exchange_item_list)
  local goods_num = item_num / 2
  if nx_int(goods_num) >= nx_int(1) then
    form.groupbox_items.Visible = true
    for i = 0, goods_num - 1 do
      local list_index = i * 2 + 1
      local item_id = exchange_item_list[list_index]
      local count = exchange_item_list[list_index + 1]
      if nx_is_valid(GoodsGrid) then
        local item_data = nx_create("ArrayList", nx_current())
        item_data.ConfigID = item_id
        item_data.Count = get_rebate_value(viewobj, count * exchange_num)
        item_data.ShopID = shop_id
        item_data.Amount = get_rebate_value(viewobj, count * exchange_num)
        item_data.ItemType = get_prop_in_ItemQuery(item_id, nx_string("ItemType"))
        item_data.ArtPack = get_prop_in_ItemQuery(item_id, nx_string("ArtPack"))
        GoodsGrid:GridAddItem(form.form_shop_goods, i, item_data)
        form.form_shop_goods:SetBindIndex(i, i + 1)
      end
    end
  end
  local bind_status = exchange_item_manager:GetCurBindStatus()
  local exchange_bind = exchange_item_manager:GetCurExchangeBind()
  local show_bind = exchange_item_manager:GetCurShowBind()
  if nx_int(bind_status) > nx_int(0) then
    form.mltbox_bindstatus.Visible = true
    form.mltbox_bindstatus:Clear()
    form.mltbox_bindstatus:AddHtmlText(nx_widestr(util_text("ui_gpsd_bdfc_002")), -1)
    if nx_int(exchange_bind) > nx_int(0) then
      form.mltbox_bindstatus:Clear()
      form.mltbox_bindstatus:AddHtmlText(nx_widestr(util_text("ui_gpsd_bdfc_001")), -1)
    end
    if nx_int(show_bind) == nx_int(0) then
      form.mltbox_bindstatus.Visible = false
    end
  else
    form.mltbox_bindstatus.Visible = false
  end
end
function update_condition(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return
  end
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local viewobj = form.item_obj
  if not nx_is_valid(viewobj) then
    return
  end
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) == nx_int(0) then
    return
  end
  local condition_list = exchange_item_manager:GetCurConditionList()
  local condition2_list = exchange_item_manager:GetCurCondition2List()
  local condition_type = exchange_item_manager:GetCurConditionType()
  local condition_num = (table.getn(condition_list) + table.getn(condition2_list)) / 2
  if 0 < condition_num then
    local and_condition_desc = gui.TextManager:GetText("ui_and_condition_desc")
    local or_condition_desc = gui.TextManager:GetText("ui_or_condition_desc")
    local desc = condition_type == 0 and and_condition_desc or or_condition_desc
    local mlt_index = form.mltbox_condition:AddHtmlText(desc, nx_int(-1))
    form.mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
  else
    local desc_none = gui.TextManager:GetText("tips_item_active_condition_none")
    form.mltbox_condition:AddHtmlText(desc_none, nx_int(-1))
    return
  end
  local nCount = nx_number(nx_int(table.getn(condition_list) / 2))
  for i = 1, nCount do
    local condition_id = nx_int(condition_list[2 * i - 1])
    local isneednoshow = nx_int(condition_list[2 * i]) == nx_int(1)
    if not is_exists_condtionid(condition_id) then
      local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(condition_id))
      local b_ok = condition_manager:CanSatisfyCondition(game_player, game_player, condition_id)
      local real_text = color_text(condition_decs, b_ok)
      if not isneednoshow or not b_ok then
        local mlt_index = form.mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        form.mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
      add_conditionid(condition_id)
    end
  end
  update_condition2(form)
end
function update_condition2(form)
  if not nx_is_valid(form) then
    return
  end
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local viewobj = form.item_obj
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) == nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_condition_details", exchange_index)
end
function on_update_condition2(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_shop\\form_exchange")
  if not nx_is_valid(form) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local nCount = nx_number(nx_int(table.getn(arg) / 3))
  for i = 1, nCount do
    local condition_id = nx_int(arg[3 * i - 2])
    local isneedshow = nx_int(arg[3 * i - 1]) == nx_int(1)
    if not is_exists_condtionid(condition_id) then
      local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(condition_id))
      local b_ok = nx_int(arg[3 * i]) == nx_int(1)
      local real_text = color_text(condition_decs, b_ok)
      if isneedshow then
        local mlt_index = form.mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        form.mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
      add_conditionid(condition_id)
    end
  end
end
function update_consume(form, exchange_num)
  local gui = nx_value("gui")
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local viewobj = form.item_obj
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) == nx_int(0) then
    return
  end
  form.mltbox_consume:Clear()
  form.groupbox_consume.Visible = false
  local exchange_prop_list = exchange_item_manager:GetCurPropList()
  local prop_num = table.getn(exchange_prop_list) / 2
  if 0 < prop_num then
    form.groupbox_consume.Visible = true
    for i = 1, prop_num do
      local propname = exchange_prop_list[i * 2 - 1]
      local numeric = nx_number(exchange_prop_list[i * 2]) * nx_number(exchange_num)
      numeric = get_rebate_value(viewobj, numeric)
      local desc = nx_widestr("")
      if nx_string(propname) == "CapitalType1" then
        desc = nx_widestr(gui.TextManager:GetFormatText(nx_string("37402"), nx_int(numeric)))
      elseif nx_string(propname) == "CapitalType2" then
        desc = nx_widestr(gui.TextManager:GetFormatText(nx_string("37401"), nx_int(numeric)))
      else
        desc = nx_widestr(gui.TextManager:GetText(propname)) .. nx_widestr("(") .. nx_widestr(numeric) .. nx_widestr(")")
      end
      local real_text = color_text(desc, false)
      local mlt_index = form.mltbox_consume:AddHtmlText(real_text, nx_int(-1))
      form.mltbox_consume:SetHtmlItemSelectable(mlt_index, false)
    end
  end
  local exchange_type = exchange_item_manager:GetCurType()
  if nx_int(exchange_type) == nx_int(EXCHANGE_TYPE_GUILDBUILDING) then
    form.groupbox_consume.Visible = true
    local guild_price = exchange_item_manager:GetCurAddValue()
    local numeric = nx_number(guild_price) * nx_number(exchange_num)
    numeric = get_rebate_value(viewobj, numeric)
    local desc = nx_widestr(gui.TextManager:GetFormatText("ui_guild_currency_9", nx_int(numeric)))
    local real_text = color_text(desc, false)
    local mlt_index = form.mltbox_consume:AddHtmlText(real_text, nx_int(-1))
    form.mltbox_consume:SetHtmlItemSelectable(mlt_index, false)
  end
end
function update_control_layout(form)
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local viewobj = form.item_obj
  if not nx_is_valid(viewobj) then
    return
  end
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) == nx_int(0) then
    return
  end
  local exchange_prop_list = exchange_item_manager:GetCurPropList()
  local prop_num = table.getn(exchange_prop_list) / 2
  local exchange_item_list = exchange_item_manager:GetCurItemList()
  local item_num = table.getn(exchange_item_list) / 2
  if 0 < prop_num then
    form.groupbox_items.Top = form.groupbox_consume.Top + form.groupbox_consume.Height
  else
    form.groupbox_items.Top = form.groupbox_consume.Top
  end
end
function isHaveItem(item_id, item_number)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false, 0
  end
  local view_id = goods_grid:GetToolBoxViewport(nx_string(item_id))
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return false, 0
  end
  local total = 0
  local viewobj_list = view:GetViewObjList()
  for i, obj in pairs(viewobj_list) do
    if nx_string(obj:QueryProp("ConfigID")) == nx_string(item_id) then
      total = total + nx_number(obj:QueryProp("Amount"))
    end
  end
  return nx_int(item_number) <= nx_int(total), total
end
function color_text(src, b_ok)
  local dest = ""
  dest = dest .. (b_ok and "<font color=\"#006600\">" or "<font color=\"#ff0000\">")
  dest = dest .. nx_string(src)
  dest = dest .. "</font>"
  return nx_widestr(dest)
end
function get_rebate_value(item, value)
  value = nx_number(value)
  local vip_module = nx_value("VipModule")
  if not nx_is_valid(vip_module) then
    return value
  end
  if not vip_module:IsVip(VT_NORMAL) then
    return value
  end
  if not nx_is_valid(item) then
    return value
  end
  if not item:FindProp("VipRebate") then
    return value
  end
  local vip_rebate = nx_number(item:QueryProp("VipRebate"))
  if 0 < vip_rebate and vip_rebate <= 100 then
    local fRebate = vip_rebate / 100
    value = value * fRebate
  end
  local integer = nx_int(value)
  local decimal = value - integer
  value = integer
  if 0 < decimal then
    value = value + 1
  end
  return value
end
function init_conditionid_list(form)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) then
    if common_array:FindArray(ARRAYLISTNAME) then
      common_array:RemoveArray(ARRAYLISTNAME)
    end
    common_array:AddArray(ARRAYLISTNAME, form, 3600, false)
  end
end
function destroy_conditionid_list()
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) and common_array:FindArray(ARRAYLISTNAME) then
    common_array:RemoveArray(ARRAYLISTNAME)
  end
end
function is_exists_condtionid(conditionid)
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) and common_array:FindArray(ARRAYLISTNAME) then
    local result = common_array:FindChild(ARRAYLISTNAME, nx_string(conditionid))
    return result ~= nil
  end
  return false
end
function add_conditionid(conditionid)
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) and common_array:FindArray(ARRAYLISTNAME) then
    common_array:AddChild(ARRAYLISTNAME, nx_string(conditionid), "1")
  end
end
function show_form(view_ident, bind_index, shop_id, page, pos, config_str)
  local viewobj = get_view_item(view_ident, bind_index)
  if not nx_is_valid(viewobj) then
    return
  end
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_exchange", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.item_obj = viewobj
  form.viewid = view_ident
  form.index = bind_index
  form.shop_id = shop_id
  form.page = page
  form.pos = pos
  exchange_item_manager:InitCurExchangeData(config_str)
  form:Show()
end
function get_view_item(view_ident, bind_index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return nil
  end
  return view:GetViewObj(nx_string(bind_index))
end
