require("form_stage_main\\form_charge_shop\\shop_util")
require("form_stage_main\\switch\\url_define")
require("form_stage_main\\switch\\util_switch_function")
local g_no_charge_shop = false
local g_form_name = "form_stage_main\\form_charge_shop\\form_charge_shop"
local g_buy_form = "form_stage_main\\form_charge_shop\\form_charge_confirm_buy"
local g_give_form = "form_stage_main\\form_charge_shop\\form_charge_confirm_give"
function open_form()
  open_shop(-1)
end
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local shop_manager = nx_value("ChargeShop")
  if not nx_is_valid(shop_manager) then
    shop_manager = nx_create("ChargeShop")
    nx_set_value("ChargeShop", shop_manager)
  end
  if nx_is_valid(shop_manager) and not shop_manager.IsConfigLoaded then
    shop_manager:LoadShopConfig()
  end
end
function on_main_form_open(form)
  local switch = nx_value("SwitchManager")
  if not nx_is_valid(switch) then
    return
  end
  local mgr = nx_value("ChargeShop")
  if nx_is_valid(mgr) then
    mgr:SetMoneyTypeShow(0, 1, false)
    mgr:SetMoneyTypeShow(3, switch:CheckSwitchEnable(ST_FUNCTION_CHARGESHOP_INTEGRAL), false)
    mgr:SetMoneyTypeShow(-1, switch:CheckSwitchEnable(ST_FUNCTION_CHARGESHOP_WEB), true)
  end
  init_form_control(form)
end
function on_main_form_close(form)
  util_show_form(g_buy_form, false)
  util_show_form(g_give_form, false)
  util_show_form(g_virtual_tip_form, false)
  nx_destroy(form)
end
function on_main_form_active(form)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form.Visible = false
  form:Close()
end
function open_shop(type)
  local old_visible = false
  local form = nx_value(g_form_name)
  if nx_is_valid(form) then
    old_visible = form.Visible
  end
  if old_visible then
    util_show_form(g_form_name, false)
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    mgr = nx_create("ChargeShop")
    nx_set_value("ChargeShop", mgr)
    if not mgr.IsConfigLoaded then
      mgr:LoadShopConfig()
    end
  end
  if nx_is_valid(mgr) and not mgr.Closed then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local ConditionManager = nx_value("ConditionManager")
  if not nx_is_valid(ConditionManager) then
    return
  end
  if not ConditionManager:CanSatisfyCondition(player, player, mgr.OpenCondition) then
    local tips = mgr.OpenTipsId
    SystemCenterInfo:ShowSystemCenterInfo(util_format_string(tips), 2)
    return
  end
  util_show_form(g_form_name, true)
  mgr:SetFilterInfo("money_type", 0, 0)
  local form = nx_value(g_form_name)
  nx_execute(g_filter_form, "on_select_shop", type)
  refresh_shop(form)
  if not old_visible then
    nx_execute("util_gui", "ui_show_attached_form", form)
  end
end
function show_charge_shop(type)
  open_shop(type)
end
function refresh_shop(form)
  if form == nil then
    form = nx_value(g_form_name)
  end
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  local page = 1
  local page_form = nx_custom(form, "page_form")
  if nx_is_valid(page_form) then
    page = page_form.page
  end
  local filter_type = mgr:QueryFilterInfo("filter_type")[1]
  local bFav = filter_type == 2
  local begin_item = (page - 1) * g_item_rows * g_item_cols
  for i = 1, g_item_rows do
    for j = 1, g_item_cols do
      local index = begin_item + (i - 1) * g_item_cols + (j - 1)
      local item = form["item_" .. nx_string(i) .. nx_string(j)]
      item.btn_delete.Visible = bFav
      item.Visible = false
      set_item_info(form, index, item)
    end
  end
end
function on_money_type_switch_changed(type, isopen)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  local money_type
  if type == ST_FUNCTION_CHARGESHOP_GOLD then
    money_type = 0
  elseif type == ST_FUNCTION_CHARGESHOP_INTEGRAL then
    money_type = 3
  elseif type == ST_FUNCTION_CHARGESHOP_WEB then
    money_type = -1
  else
    return
  end
  if money_type == nil then
    return
  end
  mgr:SetMoneyTypeShow(money_type, nx_int(isopen), true)
end
function fresh_money_type_labal(isfresh, count, ...)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if count < 1 then
    return
  end
  local g_items = {
    form.rbtn_gold,
    form.rbtn_virtual,
    form.rbtn_gift
  }
  for i = 1, table.getn(g_items) do
    g_items[i].Visible = false
  end
  form.mltbox_score.Visible = false
  form.lbl_score.Visible = false
  for i = 0, count - 1 do
    local index = arg[2 * i + 1]
    local str = arg[2 * i + 2]
    local item = g_items[i + 1]
    nx_set_custom(item, "money_type", index)
    item.Text = util_format_string(str)
    item.Visible = true
    if index == 3 then
      form.mltbox_score.Visible = true
      form.lbl_score.Visible = true
    end
  end
  if 0 < isfresh then
    form.rbtn_gold.Checked = true
  end
end
function init_form_control(form)
  form.rbtn_gold.Checked = true
  form.money_type = 0
  local control = util_get_form(g_filter_form, true, false)
  form.groupbox_type:Add(control)
  control.Left, control.Top, control.Width, control.Height = 0, 0, form.groupbox_type.Width, form.groupbox_type.Height
  control.Fixed = true
  nx_set_custom(form, "filter_form", control)
  control = util_get_form(g_page_form, true, false)
  form.groupbox_18:Add(control)
  control.Left, control.Top, control.Width, control.Height = 0, 0, form.groupbox_18.Width, form.groupbox_18.Height
  control.Fixed = true
  nx_set_custom(form, "page_form", control)
  control = util_get_form(g_browser_form, true, false)
  form.groupbox_browse:Add(control)
  control.Left, control.Top, control.Width, control.Height = 0, 0, form.groupbox_browse.Width, form.groupbox_browse.Height
  control.Fixed = true
  nx_execute(g_browser_form, "show_model", -1, 0, form, false)
  local w, h = form.groupbox_5.Width / g_item_cols, form.groupbox_5.Height / g_item_rows
  for i = 1, g_item_rows do
    for j = 1, g_item_cols do
      control = util_get_form(g_item_form, true, false, nx_string(i) .. nx_string(j))
      form.groupbox_5:Add(control)
      control.Fixed, control.Left, control.Top = true, (j - 1) * w, (i - 1) * h
      nx_set_custom(form, "item_" .. nx_string(i) .. nx_string(j), control)
      control.Visible = false
    end
  end
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("CapitalType0", "int", form, g_form_name, "on_gold_changed")
  databinder:AddRolePropertyBind("CapitalType2", "int", form, g_form_name, "on_silvercard_changed")
  databinder:AddRolePropertyBind("CapitalType3", "int", form, g_form_name, "on_virtual_changed")
  databinder:AddTableBind("ChargeShopFav", form, g_shop_form, "on_favrate_record_change")
  request_update_shop()
  nx_execute(g_filter_form, "on_select_shop", -1)
end
function request_update_shop()
  local manager = nx_value("ChargeShop")
  local t = 0
  if nx_is_valid(manager) then
    t = manager.LastUpdateTime
  end
  send_server_msg(CLIENT_REQUEST_UPDATE, nx_int(t), 0)
end
function OnServerMsg(self, ...)
  local form = nx_value(g_form_name)
  local up_page = -1
  local subCmd = nx_int(arg[1])
  if subCmd == nx_int(1) then
    local res = nx_number(arg[2])
    local uptime = nx_number(arg[3])
    local totalpage = nx_number(arg[4])
    local page = nx_number(arg[5])
    local info = nx_string(arg[6])
    local manager = nx_value("ChargeShop")
    if nx_is_valid(manager) then
      manager:SetAllChargeInfo(uptime, info)
      nx_log("update items " .. nx_string(page) .. "/" .. nx_string(totalpage))
      nx_log(info)
      if totalpage > page then
        up_page = page + 1
      end
    end
  end
  if 0 < up_page then
    nx_pause(2)
    send_server_msg(CLIENT_REQUEST_UPDATE, nx_int(t), nx_int(up_page))
  end
end
function on_favrate_record_change(self, recordname, optype, row, clomn)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  local infos = mgr:QueryFilterInfo("filter_type")
  local filter_type = infos[1]
  if filter_type == nil then
    return
  end
  if filter_type ~= 2 then
    return
  end
  mgr:SetFilterInfo("filter_type", filter_type, 1)
end
function on_gold_changed(form)
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local point = manager:GetCapital(CAPITAL_TYPE_GOLDEN)
  local txt = manager:GetFormatCapitalHtml(CAPITAL_TYPE_GOLDEN, point)
  form.mltbox_silver.HtmlText = txt
end
function on_silvercard_changed(form)
  if form.money_type ~= CAPITAL_TYPE_SILVER_CARD then
    return
  end
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local capital = manager:GetCapital(CAPITAL_TYPE_SILVER_CARD)
  local txt = manager:GetFormatCapitalHtml(CAPITAL_TYPE_SILVER_CARD, capital)
  form.mltbox_silver.HtmlText = txt
end
function on_virtual_changed(form)
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local capital = manager:GetCapital(3)
  local txt = manager:GetFormatCapitalHtml(3, capital)
  form.mltbox_score.HtmlText = txt
end
function on_money_type_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    local money_type = nx_custom(rbtn, "money_type")
    form.lbl_tips.Visible = money_type == 3
    if money_type == -1 then
      local switch_manager = nx_value("SwitchManager")
      local game_config = nx_value("game_config")
      if nx_is_valid(switch_manager) and nx_is_valid(game_config) then
        local url = switch_manager:GetUrl(URL_TYPE_GIFT_SHOP)
        local district_id = switch_manager:GetDistrictID()
        local service_id = switch_manager:GetServiceID()
        local district_name = game_config.cur_area_name
        local service_name = game_config.cur_server_name
        local login_account = game_config.login_account
        local login_account_id = game_config.login_account_id
        local final_url = nx_widestr(url) .. nx_widestr("?district_id=") .. nx_widestr(district_id) .. nx_widestr("&server_id=") .. nx_widestr(service_id) .. nx_widestr("&district_name=") .. nx_widestr(district_name) .. nx_widestr("&server_name=") .. nx_widestr(service_name) .. nx_widestr("&account=") .. nx_widestr(login_account) .. nx_widestr("&accountid=") .. nx_widestr(login_account_id)
        nx_log(nx_string(final_url))
        form.webview_gift_shop.Visible = true
        form.webview_gift_shop.Url = nx_widestr(final_url)
        if not nx_find_custom(form, "init_web") then
          form.webview_gift_shop:Refresh()
          form.init_web = true
        else
          form.webview_gift_shop:Navigate()
        end
      end
      nx_execute(g_filter_form, "on_money_type_changed", money_type)
      return
    end
    form.webview_gift_shop.Visible = false
    form.money_type = money_type
    nx_execute(g_filter_form, "on_money_type_changed", money_type)
    nx_execute(g_browser_form, "on_money_type_changed", money_type)
    form.btn_virtual_tip.Visible = money_type == 3
  end
end
function on_buy_silver_click(btn)
  nx_execute("form_stage_main\\form_consign\\form_buy_capital", "show_hide_buy_capital_form")
end
function on_consign_click(btn)
end
function on_btn_virtual_tip_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_charge_shop\\form_virtual_tip")
end
function on_buy_vip_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_vip_info")
end
function set_item_info(form, index, shop_item)
  local manager = nx_value("ChargeShop")
  if not nx_is_valid(manager) then
    return
  end
  local siftindex = index
  index = manager:SiftIndexToBaseIndex(index)
  local info = manager:GetSelectItem(index)
  local infos = util_split_string(info, ",")
  if table.getn(infos) == 0 then
    return
  end
  local id = infos[2]
  local photo = item_query_ArtPack_by_id(id, "Photo")
  shop_item.imagegrid_item:AddItem(0, nx_string(photo), nx_widestr(id), nx_int(1), 0)
  item = shop_item.lbl_item_name
  item.Text = util_format_string(id)
  local g_item_icon = {
    [1] = "",
    [2] = "icon_discount.png",
    [3] = "icon_depreciate.png",
    [4] = "",
    [5] = "icon_quota.png"
  }
  local item_type = nx_number(infos[10])
  shop_item.btn_give.Enabled = item_type ~= 5
  local photo = g_item_icon[item_type]
  if photo == nil then
    photo = ""
  end
  shop_item.lbl_zhekou.Visible = 0 < string.len(photo)
  if shop_item.lbl_zhekou.Visible then
    photo = "gui\\language\\chineseS\\charge_shop\\" .. photo
    shop_item.lbl_zhekou.BackImage = photo
  end
  local mgr = nx_value("CapitalModule")
  local money_type = manager:GetPriceType(index)
  local item = shop_item.mltbox_price
  shop_item.btn_give.Visible = money_type == 0
  item:Clear()
  local price = mgr:GetFormatCapitalHtml(money_type, nx_int64(infos[8]))
  local txstr, axstr = "81106", "81107"
  if item_type == 5 then
    txstr = "81104"
    axstr = "81105"
  end
  local tx, ax = shop_item.lbl_xianliang_total, shop_item.lbl_xianliang_account
  if item_type == 1 then
    item:Clear()
    item:AddHtmlText(nx_widestr(price), 0)
    tx.Text = util_format_string(txstr, nx_int(infos[13]))
    ax.Text = util_format_string(axstr, nx_int(infos[14]))
  elseif item_type == 2 then
    price = nx_widestr(price) .. util_format_string("81108", nx_int(infos[11]))
    item:AddHtmlText(price, 0)
    tx.Text = util_format_string(txstr, nx_int(infos[13]))
    ax.Text = util_format_string(axstr, nx_int(infos[14]))
  elseif item_type == 3 then
    price = nx_widestr(price) .. util_format_string("81109", nx_int(infos[11]))
    item:AddHtmlText(price, 0)
    tx.Text = util_format_string(txstr, nx_int(infos[13]))
    ax.Text = util_format_string(axstr, nx_int(infos[14]))
  elseif item_type == 4 then
    item:AddHtmlText(nx_widestr(price), 0)
    tx.Text = util_format_string(txstr, nx_int(infos[13]))
    ax.Text = util_format_string(axstr, nx_int(infos[14]))
  elseif item_type == 5 then
    item:AddHtmlText(nx_widestr(price), 0)
    if 0 >= nx_number(infos[13]) then
      txstr = "81106"
    end
    if 0 >= nx_number(infos[14]) then
      txstr = "81107"
    end
    tx.Text = util_format_string(txstr, nx_int(infos[13]))
    ax.Text = util_format_string(axstr, nx_int(infos[14]))
  end
  shop_item.mltbox_9:Clear()
  local valid_prop = manager:GetValidTimeProp(nx_int(get_prop(id, "ItemType")))
  local valid_info = util_split_string(valid_prop)
  if table.getn(valid_info) == 2 then
    shop_item.mltbox_9.HtmlText = util_format_string(valid_info[1], nx_int(get_prop(id, valid_info[2])))
  end
  local vip_buy = nx_number(get_prop(id, "OnlyVipBuy"))
  shop_item.lbl_vip.Visible = 0 < vip_buy
  shop_item.Visible = true
  nx_set_custom(shop_item, "index", index)
end
function on_online_charge_click(btn)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function on_btn_yinzishop_click(btn)
  local AOWSteamClient = nx_value("AOWSteamClient")
  if nx_is_valid(AOWSteamClient) then
    util_show_form("haiwai_pt", true)
    return
  end
  nx_function("ext_open_url", "http://member.us.woniu.com/commodity.post?gameId=10")
end
