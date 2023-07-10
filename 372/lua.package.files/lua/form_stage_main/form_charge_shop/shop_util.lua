require("util_functions")
require("util_gui")
require("util_static_data")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("share\\capital_define")
require("custom_sender")
require("share\\client_custom_define")
g_item_rows = 3
g_item_cols = 3
g_item_count_page = g_item_rows * g_item_cols
function get_prop(id, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return nil
  end
  local value = item_query:GetItemPropByConfigID(id, prop)
  if value ~= nil and value ~= "" then
    return value
  end
  return nil
end
function is_art_equip(id)
  local t = nx_number(get_prop(id, "ItemType"))
  return t == 140 or t == 141 or t == 142 or t == 143
end
function is_shenfen_equip(id)
  local t = nx_number(get_prop(id, "ItemType"))
  return t == 180
end
function is_mount(id)
  return nx_number(get_prop(id, "ItemType")) == 200
end
function remove_fav(id)
  send_server_msg(CLIENT_FAVRATE_REMOVE, id)
end
function format_fav_id(base_index)
  base_index = nx_int(base_index)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return ""
  end
  return mgr:GetConfig(base_index) .. "," .. nx_string(mgr:GetChargeID(base_index))
end
function sysinfo(strid, ...)
  local path = "form_stage_main\\form_main\\form_main_centerinfo"
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_format_string(strid, unpack(arg)), 2)
  end
end
function can_buy_item(index)
  local manager = nx_value("ChargeShop")
  if not nx_is_valid(manager) then
    return false
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return false
  end
  local only_vip_buy = get_prop(manager:GetConfig(index), "OnlyVipBuy")
  if nx_number(only_vip_buy) > 0 and not capital:IsVipPlayer() then
    return false
  end
  local price_type = manager:GetPriceType(index)
  return capital:CanDecCapital(price_type, nx_int64(manager:GetPrice(index)))
end
CLIENT_REQUEST_UPDATE = 1
CLIENT_REQUEST_PERSENT = 2
CLIENT_BUY_ITEM = 3
CLIENT_FAVRATE = 4
CLIENT_FAVRATE_REMOVE = 5
function send_server_msg(type, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHARGE_SHOP), nx_int(type), unpack(arg))
  end
end
g_buy_form = "form_stage_main\\form_charge_shop\\form_charge_confirm_buy"
g_give_form = "form_stage_main\\form_charge_shop\\form_charge_confirm_give"
g_browser_form = "form_stage_main\\form_charge_shop\\shop_component\\form_browser"
g_filter_form = "form_stage_main\\form_charge_shop\\shop_component\\form_filter"
g_item_form = "form_stage_main\\form_charge_shop\\shop_component\\form_item"
g_page_form = "form_stage_main\\form_charge_shop\\shop_component\\form_page"
g_shop_form = "form_stage_main\\form_charge_shop\\form_charge_shop"
g_virtual_tip_form = "form_stage_main\\form_charge_shop\\form_virtual_tip"
function buy_item(index)
  util_auto_show_hide_form(g_buy_form)
  local dlg = nx_value(g_buy_form)
  if nx_is_valid(dlg) then
    set_confirm_info(dlg, index)
    util_show_form(g_give_form, false)
  end
end
function give_item(index)
  util_auto_show_hide_form(g_give_form)
  local dlg = nx_value(g_give_form)
  if nx_is_valid(dlg) then
    set_confirm_info(dlg, index)
    util_show_form(g_buy_form, false)
  end
end
g_money_prifix = {
  [0] = "ui_shop_owngold",
  [2] = "ui_shop_ownsilver",
  [3] = "ui_shop_scoremsg"
}
function set_confirm_info(dlg, item_index)
  local cptmgr = nx_value("CapitalModule")
  local manager = nx_value("ChargeShop")
  if not nx_is_valid(manager) or not nx_is_valid(cptmgr) then
    return
  end
  local config = manager:GetConfig(item_index)
  local info = manager:GetSelectItem(item_index)
  local infos = util_split_string(info, ",")
  local item_type = nx_number(infos[10])
  local max_amount = nx_number(get_prop(config, "MaxAmount"))
  if item_type == 5 then
    local tx = nx_number(infos[13])
    local ax = nx_number(infos[14])
    if 0 < tx then
      max_amount = math.min(tx, max_amount)
    end
    if 0 < ax then
      max_amount = math.min(ax, max_amount)
    end
  end
  if max_amount == 0 then
    mnums = 1
  end
  dlg.price = manager:GetPrice(item_index)
  dlg.max_nums = max_amount
  dlg.charge_id = manager:GetChargeID(item_index)
  dlg.mtype = manager:GetPriceType(item_index)
  dlg.config = config
  dlg.lbl_name.Text = util_format_string(config)
  dlg.ipt_nums.MaxDigit = max_amount
  dlg.ipt_nums.Text = nx_widestr(1)
  dlg.ipt_nums.Enabled = 1 < max_amount
  local money_type = manager:GetPriceType(item_index)
  local price = cptmgr:GetFormatCapitalHtml(money_type, nx_int64(infos[8]))
  if item_type == 2 then
    price = nx_widestr(price) .. util_format_string("81108", nx_int(infos[11]))
  elseif item_type == 3 then
    price = nx_widestr(price) .. util_format_string("81109", nx_int(infos[11]))
  end
  dlg.mltbox_1:Clear()
  dlg.mltbox_1:AddHtmlText(nx_widestr(price), 0)
  dlg.mltbox_2:Clear()
  dlg.mltbox_2:AddHtmlText(cptmgr:GetFormatCapitalHtml(money_type, nx_int64(dlg.price)), 0)
  dlg.mltbox_3.HtmlText = cptmgr:GetFormatCapitalHtml(money_type, cptmgr:GetCapital(money_type))
  local prifix = g_money_prifix[money_type]
  if prifix == nil then
    prifix = g_money_prifix[0]
  end
  dlg.lbl_1.Text = util_format_string(prifix)
  local g_item_icon = {
    [1] = "",
    [2] = "icon_discount.png",
    [3] = "icon_depreciate.png",
    [4] = "",
    [5] = "icon_quota.png"
  }
  local photo = g_item_icon[item_type]
  if photo == nil then
    photo = ""
  end
  dlg.lbl_zhekou.Visible = 0 < string.len(photo)
  if dlg.lbl_zhekou.Visible then
    photo = "gui\\language\\chineseS\\charge_shop\\" .. photo
    dlg.lbl_zhekou.BackImage = photo
  end
  local photo = item_query_ArtPack_by_id(config, "Photo")
  dlg.img_item:AddItem(0, nx_string(photo), nx_widestr(config), nx_int(1), 0)
  nx_set_custom(dlg, "index", item_index)
end
