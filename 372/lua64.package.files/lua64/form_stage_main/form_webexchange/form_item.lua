require("util_gui")
require("util_functions")
require("share\\itemtype_define")
require("share\\view_define")
require("goods_grid")
require("share\\capital_define")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\switch\\url_define")
require("form_stage_main\\form_webexchange\\webexchange_define")
local g_form_name = "form_stage_main\\form_webexchange\\form_item"
function on_main_form_init(form)
end
function on_main_form_open(form)
  local silver_charge, item_charge = 10000, 1000
  local ini = get_ini("share\\rule\\webexchange_config.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex("Main")
    if 0 <= sec_index then
      silver_charge, item_charge = ini:ReadInteger(sec_index, "MoneyCharge", 10000), ini:ReadInteger(sec_index, "ItemCharge", 1000)
    end
  end
  form.silver_charge = silver_charge
  form.item_charge = item_charge
  form.goods.typeid = VIEWPORT_WEB_EXCHANGE_BOX
  form.goods.beginindex = 1
  form.goods.endindex = G_BOX_SIZE
  for i = 1, G_BOX_SIZE do
    form.goods:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  form.goods.canselect = true
  form.goods.candestroy = false
  form.goods.cansplit = false
  form.goods.canlock = false
  form.goods.canarrange = false
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_WEB_EXCHANGE_BOX, form.goods, g_form_name, "on_view_operat")
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  set_charge()
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(form.goods)
  nx_destroy(form)
end
function on_close_click(btn)
  sendserver_msg(G_FLAG_CLOSE)
end
function on_sell_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    local charge = btn.ParentForm.lbl_charge.Text
    dialog.mltbox_info.HtmlText = util_format_string("webe_007", charge)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
  end
  sendserver_msg(G_FLAG_SELL_ITEM, nx_int(get_sell_silver(btn.ParentForm)))
end
function on_sell_silver_changed(ipt)
  local value = nx_number(ipt.Text)
  if value < 0 then
    ipt.Text = nx_widestr(0)
  end
  set_charge()
end
function get_sell_silver(form)
  local sell_silver = nx_int64(form.ipt_ding.Text) * nx_int64(G_SILVER_BASE) * nx_int64(G_SILVER_BASE)
  sell_silver = sell_silver + nx_int64(form.ipt_liang.Text) * nx_int64(G_SILVER_BASE)
  sell_silver = sell_silver + nx_int64(form.ipt_wen.Text)
  return sell_silver
end
function on_select_changed(grid)
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(grid, -1)
end
function on_mousein_grid(grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  local left, top = grid:GetMouseInItemLeft() + 32, grid:GetMouseInItemTop()
  nx_execute("tips_game", "show_goods_tip", item_data, left, top, 32, 32, grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_rightclick_grid(grid, index)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) and form_bag.Visible then
    local view_index = grid:GetBindIndex(index)
    local view_obj = get_view_item(VIEWPORT_WEB_EXCHANGE_BOX, view_index)
    if nx_is_valid(view_obj) then
      local view_id = ""
      local goods_grid = nx_value("GoodsGrid")
      if nx_is_valid(goods_grid) then
        view_id = goods_grid:GetToolBoxViewport(view_obj)
        goods_grid:ViewGridPutToAnotherView(grid, view_id)
      end
    end
  end
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
  set_charge()
  return 1
end
function set_charge()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return
  end
  local item_charge = nx_int64(get_item_charge_value(form))
  local value = mgr:GetCapital(CAPITAL_TYPE_SILVER_CARD)
  local max_exchange_silver = value - item_charge
  local sell_silver = get_sell_silver(form)
  local silver_charge = 0
  local benable = 0 <= max_exchange_silver
  local silver_charge_base = form.silver_charge
  if max_exchange_silver <= silver_charge_base then
    max_exchange_silver = 0
  else
    max_exchange_silver = max_exchange_silver - silver_charge_base
    if 0 < sell_silver then
      silver_charge = silver_charge_base
    end
  end
  if sell_silver > max_exchange_silver then
    form.ipt_ding.Text = nx_widestr(math.floor(max_exchange_silver / (G_SILVER_BASE * G_SILVER_BASE)))
    form.ipt_liang.Text = nx_widestr(math.floor(math.mod(max_exchange_silver, G_SILVER_BASE * G_SILVER_BASE) / G_SILVER_BASE))
    form.ipt_wen.Text = nx_widestr(math.mod(max_exchange_silver, G_SILVER_BASE))
  end
  local charge = nx_int64(silver_charge) + item_charge
  form.lbl_charge.Text = mgr:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(charge))
  form.btn_ok.Enabled = benable
end
function get_item_charge_value(form)
  local item_charge = 0
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_WEB_EXCHANGE_BOX))
  if not nx_is_valid(view) then
    return item_charge
  end
  local items = view:GetViewObjList()
  local item_charge_base = form.item_charge
  for _, item in pairs(items) do
    if nx_is_valid(item) then
      local charge = item_charge_base * item:QueryProp("ColorLevel")
      if item_charge_base > charge then
        charge = item_charge_base
      end
      item_charge = item_charge + charge
    end
  end
  return item_charge
end
function on_exchange_tip_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local id = "ui_platform_item_msg"
  if rbtn.Name == "rbtn_regular" then
    id = "ui_platform_regulate_msg"
  end
  rbtn.ParentForm.mltbox_1.HtmlText = util_format_string(id)
end
function on_web_look_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_EXCHAGE)
  end
end
