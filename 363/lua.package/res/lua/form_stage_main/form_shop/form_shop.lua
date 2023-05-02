require("util_functions")
require("goods_grid")
require("share\\view_define")
require("share\\itemtype_define")
require("share\\capital_define")
local SEED_LEVEL_CHECKED = 20
function on_main_form_init(form)
  form.Fixed = false
  form.pagenum = 0
  form.shopid = ""
  form.pages = 0
  form.curpage = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.form_shop_goods.typeid = VIEWPORT_SHOP
  for i = 1, 100 do
    form.form_shop_goods:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  form.form_shop_goods.canselect = true
  form.form_shop_goods.candestroy = true
  form.form_shop_goods.cansplit = true
  form.form_shop_goods.canlock = true
  form.form_shop_goods.canarrange = true
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_SHOP, form, nx_current(), "on_view_operat")
  end
  form.rbtn_page1.Checked = true
  form.form_shop_prepage.Visible = false
  form.form_shop_nextpage.Visible = false
  form.form_shop_page.Visible = false
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) and form_bag.Visible then
    form.close_form_bag = 0
    if nx_find_custom(form_bag, "mountshop_opt") and nx_int(form_bag.mountshop_opt) == nx_int(1) then
      form.openwithbag = 1
    end
  else
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
    form.close_form_bag = 1
  end
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function on_main_form_close(form)
  local form_buy_back = nx_value("form_stage_main\\form_shop\\form_buy_back")
  if nx_is_valid(form_buy_back) then
    form_buy_back:Close()
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  nx_execute("tips_game", "hide_tip", form)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if not game_hand:IsEmpty() then
    game_hand:ClearHand()
  end
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and not nx_find_custom(form, "openwithbag") then
    form_talk:Close()
  end
  if nx_int(form.close_form_bag) == nx_int(1) then
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", false)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
end
function prepage_on_click(btn)
  refresh_shop_item(btn.Parent, btn.Parent.curpage - 1)
end
function nextpage_on_click(btn)
  refresh_shop_item(btn.Parent, btn.Parent.curpage + 1)
end
function form_grid_on_rightclick_grid(grid)
  on_grid_click_right_or_left(grid, true)
end
function form_grid_on_select_changed(grid)
  on_grid_click_right_or_left(grid, false)
end
function on_grid_click_right_or_left(grid, is_right)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if gui.GameHand:IsEmpty() then
    local selected_index = grid:GetSelectItemIndex()
    if is_right then
      selected_index = grid:GetRBClickItemIndex()
    end
    if grid:IsEmpty(selected_index) then
      return
    end
    if nx_execute("animation", "check_has_animation", nx_string("ShopBoxShow"), nx_int(selected_index)) then
      nx_execute("animation", "del_animation", nx_string("ShopBoxShow"))
    end
    local data = grid.Data:GetChild(nx_string(selected_index))
    if not nx_is_valid(data) then
      return
    end
    local shop_id = grid.Parent.shopid
    local page = grid.Parent.curpage
    local pos = selected_index
    local index = grid:GetBindIndex(selected_index)
    buy_shop_item(shop_id, page, pos + 1, nx_string(VIEWPORT_SHOP), index)
  elseif gui.GameHand.Type == GHT_VIEWITEM then
    local view_id = nx_number(gui.GameHand.Para1)
    local view_index = nx_number(gui.GameHand.Para2)
    local amount = nx_number(gui.GameHand.Para3)
    local goods_grid = nx_value("GoodsGrid")
    if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(view_id)) then
      local item_name, gold, silver, card = get_item_needprop(view_id, view_index)
      show_sell_item_retail_form(view_id, view_index, item_name, amount, gold, silver, card)
    else
    end
  end
end
function refresh_shop_item(form, page)
  if page >= form.pages then
    return
  end
  form.curpage = page
  form.form_shop_page.Text = nx_widestr(nx_string(page + 1) .. "/" .. nx_string(form.pages))
  if page == 0 then
    form.form_shop_prepage.Enabled = false
  else
    form.form_shop_prepage.Enabled = true
  end
  if page < form.pages - 1 then
    form.form_shop_nextpage.Enabled = true
  else
    form.form_shop_nextpage.Enabled = false
  end
  if not nx_find_custom(form, "type") or form.type ~= 1 then
    local form_buy_back = nx_value("form_stage_main\\form_shop\\form_buy_back")
    if not nx_is_valid(form_buy_back) then
      return
    end
    if page + 1 == form.pages then
      form_buy_back.Visible = true
      form.form_shop_goods.Visible = false
      form.btn_repair_usesilver.Visible = false
      form.btn_repair.Visible = false
      form.btn_repairall.Visible = false
      return
    end
    form_buy_back.Visible = false
    form.form_shop_goods.Visible = true
    form.btn_repair_usesilver.Visible = true
    form.btn_repair.Visible = true
    form.btn_repairall.Visible = true
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SHOP))
  if not nx_is_valid(view) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  GoodsGrid:GridClear(form.form_shop_goods)
  local viewobj_list = view:GetViewObjList()
  for i, item in pairs(viewobj_list) do
    local prop_table = {}
    local index = nx_number(item.Ident)
    if form.pagenum * form.curpage <= index - 1 and index - 1 < form.pagenum * (form.curpage + 1) then
      local proplist = item:GetPropList()
      for i, prop in pairs(proplist) do
        prop_table[prop] = item:QueryProp(prop)
      end
      local item_data = nx_create("ArrayList", nx_current())
      for prop, value in pairs(prop_table) do
        nx_set_custom(item_data, prop, value)
      end
      local grid_index = index % form.pagenum - 1
      GoodsGrid:GridAddItem(form.form_shop_goods, grid_index, item_data)
      refresh_item_cover_color(form, item_data, grid_index)
      form.form_shop_goods:SetBindIndex(grid_index, index)
    end
  end
  form.Data = data
end
function on_view_operat(form, optype, view_ident, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  if optype == "createview" then
    form.shopid = view:QueryProp("ShopID")
    form.pagenum = view:QueryProp("PageNum")
    form.curpage = 0
    form.type = nx_number(view:QueryProp("ShopType"))
    form.title = gui.TextManager:GetText(nx_string(form.shopid))
    if form.type == 1 then
      form.lbl_form_title.Text = nx_widestr(form.title)
      form.btn_repair_usesilver.Visible = false
      form.btn_repair.Visible = false
      form.btn_repairall.Visible = false
      form.pages = view:QueryProp("PageCount")
    else
      form.lbl_form_title.Text = nx_widestr("@ui_shop")
      form.btn_repair_usesilver.Visible = true
      form.btn_repair.Visible = true
      form.btn_repairall.Visible = true
      form.pages = view:QueryProp("PageCount") + 1
      local form_buy_back = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_buy_back", true, false)
      local is_load = form:Add(form_buy_back)
      if is_load == true then
        form_buy_back.Left = 0
        form_buy_back.Top = 32
        form_buy_back.Visible = false
      end
    end
    refresh_page_buttons(form.groupbox_pagebuttons, form.shopid, form.pages)
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText(form.shopid)
    form.form_shop_window_name.Text = text
    form.form_shop_page.Text = nx_widestr("1/" .. nx_string(form.pages))
    form.form_shop_goods:Clear()
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(form.form_shop_goods)
  end
  local prop_table = {}
  local item = view:GetViewObj(nx_string(index))
  if nx_is_null(item) then
    return 1
  end
  if form.pagenum * form.curpage <= index - 1 and index - 1 < form.pagenum * (form.curpage + 1) then
    local proplist = item:GetPropList()
    for i, prop in pairs(proplist) do
      prop_table[prop] = item:QueryProp(prop)
    end
    local item_data = nx_create("ArrayList", nx_current())
    for prop, value in pairs(prop_table) do
      nx_set_custom(item_data, prop, value)
    end
    local grid_index = index % form.pagenum - 1
    GoodsGrid:GridAddItem(form.form_shop_goods, grid_index, item_data)
    refresh_item_cover_color(form, item_data, grid_index)
    form.form_shop_goods:SetBindIndex(grid_index, index)
  end
  return 1
end
function refresh_item_cover_color(form, item_data, index)
  if nx_find_custom(item_data, "SellLimit") and item_data.SellLimit > 0 then
    if nx_find_custom(item_data, "SellCount") and 0 < item_data.SellCount then
      form.form_shop_goods:CoverItem(index, false)
    else
      form.form_shop_goods:CoverItem(index, true)
    end
  else
    form.form_shop_goods:CoverItem(index, false)
  end
end
function on_form_shop_goods_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return 0
  end
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return
  end
  local bindindex = grid:GetBindIndex(index)
  local viewobj = get_view_item(grid.typeid, bindindex)
  if not nx_is_valid(viewobj) then
    return
  end
  viewobj.IsShop = true
  viewobj.is_static = true
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) > nx_int(0) then
    viewobj.exchange_item = true
  end
  nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_form_shop_goods_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function buy_shop_item(shop_id, page, pos, view_ident, index)
  local gui = nx_value("gui")
  local viewobj = get_view_item(view_ident, index)
  if not nx_is_valid(viewobj) then
    return
  end
  local item_nameid = viewobj:QueryProp("ConfigID")
  local item_name = gui.TextManager:GetText(item_nameid)
  local item_gold = viewobj:QueryProp("SellPrice0")
  local item_sivr = viewobj:QueryProp("SellPrice1")
  local item_card = viewobj:QueryProp("SellPrice2")
  local item_buylimit = viewobj:QueryProp("BuyLimit")
  local item_selllimit = viewobj:QueryProp("SellLimit")
  local item_sellcount = viewobj:QueryProp("SellCount")
  local item_canbuycount = 0
  if view_ident == nx_string(VIEWPORT_SHOP) then
    local nMaxAmount = viewobj:QueryProp("MaxAmount")
    if 0 < item_selllimit then
      if 0 < item_buylimit then
        item_canbuycount = item_buylimit < item_sellcount and item_buylimit or item_sellcount
      else
        item_canbuycount = item_sellcount
      end
    elseif 0 < item_buylimit then
      item_canbuycount = item_buylimit
    else
      item_canbuycount = nMaxAmount
    end
    item_canbuycount = nMaxAmount > item_canbuycount and item_canbuycount or nMaxAmount
  else
    item_canbuycount = viewobj:QueryProp("Amount")
  end
  if is_show_exchange_form(view_ident, index) == 1 then
    show_exchange_form(view_ident, index, shop_id, page, pos)
    return
  end
  nx_execute("form_stage_main\\form_bag", "clear_select_items")
  if item_canbuycount == 1 then
    show_buy_item_confirm_form(shop_id, page, pos, view_ident, index, item_canbuycount, item_name, item_gold, item_sivr, item_card)
  else
    show_buy_item_retail_form(shop_id, page, pos, view_ident, index, item_canbuycount, item_name, item_gold, item_sivr, item_card)
  end
end
function show_sell_item_retail_form(view_id, view_index, itemname, count, gold, sivr, card)
  local gui = nx_value("gui")
  local item = get_view_item(view_id, view_index)
  if not nx_is_valid(item) then
    return
  end
  local sell_price1 = item:QueryProp("SellPrice1")
  local total_money = sell_price1 * count
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local have_money = client_player:QueryProp("CapitalType1")
  local CapitalModule = nx_value("CapitalModule")
  local max_value = CapitalModule:GetMaxValue(1)
  local view_item = game_client:GetView(nx_string(VIEWPORT_SHOP))
  if not nx_is_valid(view_item) then
    return
  end
  local shopid = view_item:QueryProp("ShopID")
  if max_value < have_money + total_money then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = gui.TextManager:GetText("ui_money_tips")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if "cancel" == res then
      gui.GameHand:ClearHand()
      return
    end
  end
  if count == 1 then
    nx_execute("custom_sender", "custom_sell_item", view_id, view_index, count, shopid)
    gui.GameHand:ClearHand()
    return -1
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  dialog.bSell = true
  tipinfo = nx_widestr(itemname)
  dialog.lbl_tip.Text = tipinfo
  local price_type, price = CAPITAL_TYPE_SILVER, sivr
  if 0 < gold then
    price_type = CAPITAL_TYPE_GOLDEN
    price = gold
  elseif 0 < card then
    price_type = CAPITAL_TYPE_SILVER_CARD
    price = card
  end
  nx_execute("form_stage_main\\form_shop\\form_trade_buy", "init_buy_form", dialog, price_type, price, count)
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog:ShowModal()
  local res, count, paymodel = nx_wait_event(100000000, dialog, "form_retail_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_sell_item", view_id, view_index, count, shopid)
    gui.GameHand:ClearHand()
  end
  return -1
end
function show_buy_item_confirm_form(shop_id, page, pos, view_ident, index, count, itemname, gold, sivr, card)
  local viewobj = get_view_item(view_ident, index)
  if not nx_is_valid(viewobj) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  dialog.lbl_tip.Text = nx_widestr(itemname)
  dialog.item_obj = viewobj
  local price_type, price = CAPITAL_TYPE_SILVER, sivr
  if 0 < gold then
    price_type = CAPITAL_TYPE_GOLDEN
    price = gold
  elseif 0 < card then
    price_type = CAPITAL_TYPE_SILVER_CARD
    price = card
  end
  nx_execute("form_stage_main\\form_shop\\form_trade_buy", "init_buy_form", dialog, price_type, price, count)
  local gui = nx_value("gui")
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog:ShowModal()
  res = nx_wait_event(100000000, dialog, "form_retail_return")
  if res == "ok" and view_ident == nx_string(VIEWPORT_SHOP) then
    nx_execute("custom_sender", "custom_buy_item", shop_id, page, pos, count)
  end
  return -1
end
function show_buy_item_retail_form(shop_id, page, pos, view_ident, index, count, itemname, gold, sivr, card)
  local viewobj = get_view_item(view_ident, index)
  if not nx_is_valid(viewobj) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  dialog.lbl_tip.Text = nx_widestr(itemname)
  dialog.item_obj = viewobj
  local gui = nx_value("gui")
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  local price_type, price = CAPITAL_TYPE_SILVER, sivr
  if 0 < gold then
    price_type = CAPITAL_TYPE_GOLDEN
    price = gold
  elseif 0 < card then
    price_type = CAPITAL_TYPE_SILVER_CARD
    price = card
  end
  nx_execute("form_stage_main\\form_shop\\form_trade_buy", "init_buy_form", dialog, price_type, price, count)
  dialog:ShowModal()
  local res, count, paymodel = nx_wait_event(100000000, dialog, "form_retail_return")
  if res == "ok" then
    local seed_checked = buy_seed_level_checked(viewobj)
    if nx_int(1) == nx_int(seed_checked) then
      return
    end
    if 0 < gold then
      show_buy_item_confirm_form(shop_id, page, pos, view_ident, index, count, itemname, gold, sivr, card)
    else
      nx_execute("custom_sender", "custom_buy_item", shop_id, page, pos, count)
    end
  end
end
function get_item_needprop(view_ident, index)
  local gui = nx_value("gui")
  local viewobj = get_view_item(view_ident, index)
  if not nx_is_valid(viewobj) then
    return
  end
  local item_nameid = viewobj:QueryProp("ConfigID")
  local item_name = gui.TextManager:GetText(item_nameid)
  local item_gold = viewobj:QueryProp("SellPrice0")
  local item_sivr = viewobj:QueryProp("SellPrice1")
  local item_card = viewobj:QueryProp("SellPrice2")
  return item_name, item_gold, item_sivr, item_card
end
function refresh_page_buttons(page_button_group, shop_id, pagecount)
  local gui = nx_value("gui")
  local i = 1
  local rbtn = page_button_group:Find("rbtn_page1")
  while nx_is_valid(rbtn) do
    if pagecount >= i then
      rbtn.Text = gui.TextManager:GetText(shop_id .. "_page" .. nx_string(nx_int(i)))
      rbtn.Visible = true
    else
      rbtn.Visible = false
    end
    i = i + 1
    rbtn = page_button_group:Find("rbtn_page" .. nx_string(nx_int(i)))
  end
  if page_button_group.Parent.type ~= 1 then
    rbtn = page_button_group:Find("rbtn_page" .. nx_string(nx_int(pagecount)))
    if nx_is_valid(rbtn) then
      rbtn.Text = gui.TextManager:GetText("ui_buy_back")
      rbtn.Visible = true
    end
  end
end
function on_rbtn_page_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    local page_num = nx_number(rbtn.DataSource)
    refresh_shop_item(form, page_num - 1)
  end
end
function on_btn_repair_usesilver_click(btn)
  local gui = nx_value("gui")
  local photo = "gui\\common\\zhuangshi\\fix.png"
  gui.GameHand:SetHand("repair_one_bynpc_usesilver", photo, "", "", "", "")
end
function on_btn_repair_click(btn)
  local gui = nx_value("gui")
  local photo = "gui\\common\\zhuangshi\\fix.png"
  gui.GameHand:SetHand("repair_one_bynpc", photo, "", "", "", "")
end
function on_btn_repairall_click(btn)
  nx_execute("custom_sender", "custom_send_repair_all", 0, 0, 0)
end
function on_btn_repair_usesilver_get_capture(btn)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetText("tips_repair_usesilver")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
end
function on_btn_repair_usesilver_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_repair_get_capture(btn)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetText("tips_repair_single")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
end
function on_btn_repair_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_repairall_get_capture(btn)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetText("tips_repair_all")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
end
function on_btn_repairall_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function get_view_item(view_ident, index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return nil
  end
  return view:GetViewObj(nx_string(index))
end
function show_exchange_form(view_ident, bind_index, shop_id, page, pos)
  local old_form = nx_value("form_stage_main\\form_shop\\form_exchange")
  if nx_is_valid(old_form) then
    old_form:Close()
  end
  local viewobj = get_view_item(view_ident, bind_index)
  if not nx_is_valid(viewobj) then
    return
  end
  nx_execute("custom_sender", "custom_request_shop_exchange_form", view_ident, bind_index, shop_id, page, pos)
end
function is_show_exchange_form(view_ident, bindindex)
  local viewobj = get_view_item(view_ident, bindindex)
  if not nx_is_valid(viewobj) then
    return 0
  end
  local exchange_item_manager = nx_value("exchange_item_manager")
  if not nx_is_valid(exchange_item_manager) then
    return 0
  end
  local exchange_index = viewobj:QueryProp("ExchangeData")
  if nx_int(exchange_index) <= nx_int(0) then
    return 0
  end
  return 1
end
function get_job_level(job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local row = client_player:FindRecordRow("job_rec", 0, job_id, 0)
  if row < 0 then
    return 0
  end
  return client_player:QueryRecord("job_rec", row, 1)
end
function buy_seed_level_checked(viewobj)
  if not nx_is_valid(viewobj) then
    return -1
  end
  local itemType = nx_execute("tips_func_equip", "get_goods_item_type", viewobj)
  if nx_int(ITEMTYPE_SEED) ~= nx_int(itemType) then
    return -1
  end
  local item_level = nx_execute("tips_func_equip", "get_item_level", viewobj)
  local player_nf_level = get_job_level("sh_nf")
  local checked_level = SEED_LEVEL_CHECKED + nx_int(item_level)
  local game_gui = nx_value("gui")
  if nx_int(player_nf_level) < nx_int(item_level) then
    game_gui.TextManager:Format_SetIDName("ui_myfarm_1")
  elseif nx_int(player_nf_level) >= nx_int(checked_level) then
    game_gui.TextManager:Format_SetIDName("ui_myfarm_2")
  else
    return 0
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local seed_name = nx_execute("tips_func_equip", "get_name", viewobj)
  game_gui.TextManager:Format_AddParam(nx_string(seed_name))
  game_gui.TextManager:Format_AddParam(nx_int(item_level))
  local wcsInfo = game_gui.TextManager:Format_GetText()
  dialog.mltbox_info:Clear()
  dialog.mltbox_info.HtmlText = nx_widestr(wcsInfo)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return 1
  else
    return 0
  end
  return 0
end
function CanBuyGuildChaseTool(item_obj)
  if not nx_is_valid(item_obj) then
    return false
  end
  if nx_int(item_obj:QueryProp("ItemType")) ~= nx_int(ITEMTYPE_GUILD_CHASE) then
    return true
  end
  local item_lvl = item_obj:QueryProp("ChaseToolLvl")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if nx_int(client_player:QueryProp("IsGuildCaptain")) ~= nx_int(2) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("87321"), 2)
    end
    return false
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false
  end
  local view_id = goods_grid:GetToolBoxViewport(nx_string(item_obj:QueryProp("ConfigID")))
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return false
  end
  local viewobj_list = view:GetViewObjList()
  for i, obj in pairs(viewobj_list) do
    if nx_int(obj:QueryProp("ItemType")) == nx_int(ITEMTYPE_GUILD_CHASE) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("87322"), 2)
      end
      return false
    end
  end
  return true
end
function on_btn_help_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
