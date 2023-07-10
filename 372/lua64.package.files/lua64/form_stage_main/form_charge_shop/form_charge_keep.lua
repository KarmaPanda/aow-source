require("util_gui")
require("util_functions")
require("util_static_data")
require("form_stage_main\\form_charge_shop\\shop_util")
require("share\\capital_define")
require("util_vip")
local g_form_name = "form_stage_main\\form_charge_shop\\form_charge_keep"
local g_form_down = "form_stage_main\\form_charge_shop\\form_down_button"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.vipprice = 30
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddRolePropertyBind("CapitalType0", "int", form, g_form_name, "on_gold_changed")
  databinder:AddRolePropertyBind("CapitalType2", "int", form, g_form_name, "on_silver_card_changed")
  databinder:AddRolePropertyBind("CapitalType3", "int", form, g_form_name, "on_integral_changed")
  refresh_form(form)
end
function refresh_form(form)
  local manager = nx_value("ChargeShop")
  local counts = manager:GetOutDataItemCount()
  if counts <= 0 then
    form:Close()
    return
  end
  form.lbl_4.Text = nx_widestr(form.index) .. nx_widestr("/") .. nx_widestr(counts)
  local item_name = form.configid
  local photo
  if form.type == "item" then
    photo = item_query_ArtPack_by_id(nx_string(item_name), "Photo")
    form.lbl_name.Text = util_format_string(form.configid)
  elseif form.type == "vip" then
    photo = item_name
    form.lbl_name.Text = util_format_string("ui_vipka")
  end
  form.imagegrid_item.BackImage = photo
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local txt1 = capital:GetFormatCapitalHtml(form.price_type, form.price)
  form.mltbox_1.HtmlText = txt1
  local charge_count = manager:GetODISubCount(form.index - 1)
  local gui = nx_value("gui")
  form.groupbox_ctype:DeleteAll()
  for i = 1, charge_count do
    local rbtn = gui:Create("RadioButton")
    form.groupbox_ctype:Add(rbtn)
    rbtn.NormalImage = "gui\\common\\checkbutton\\rbtn_top_out.png"
    rbtn.FocusImage = "gui\\common\\checkbutton\\rbtn_top_on.png"
    rbtn.CheckedImage = "gui\\common\\checkbutton\\rbtn_top_down.png"
    rbtn.Font = "font_text"
    rbtn.NormalColor = "255,197,184,159"
    rbtn.FocusColor = "255,255,255,255"
    rbtn.PushColor = "255,255,255,255"
    rbtn.Width = 80
    rbtn.Height = 33
    rbtn.Left = 10 + (i - 1) * 80
    rbtn.Top = 0
    rbtn.DrawMode = "ExpandH"
    local charge_type = manager:GetODIPriceType(form.index - 1, i - 1)
    rbtn.Text = util_format_string("ui_chargetype_" .. nx_string(charge_type))
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_checked_changed", "on_type_changed")
    nx_set_custom(rbtn, "sub_index", i - 1)
    if i == 1 then
      local point = capital:GetCapital(charge_type)
      local txt2 = capital:GetFormatCapitalHtml(charge_type, point)
      form.mltbox_2.HtmlText = txt2
      rbtn.Checked = true
    end
  end
end
function on_type_changed(rbtn)
  if not rbtn.Checked then
    return 0
  end
  local form = rbtn.ParentForm
  local sub_index = rbtn.sub_index
  local manager = nx_value("ChargeShop")
  form.price = manager:GetODIPrice(form.index - 1, sub_index)
  form.charge_id = manager:GetODIChargeID(form.index - 1, sub_index)
  form.price_type = manager:GetODIPriceType(form.index - 1, sub_index)
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local txt1 = capital:GetFormatCapitalHtml(form.price_type, form.price)
  form.mltbox_1.HtmlText = txt1
  local point = capital:GetCapital(form.price_type)
  local txt2 = capital:GetFormatCapitalHtml(form.price_type, point)
  form.mltbox_2.HtmlText = txt2
end
function on_main_form_close(form)
  local manager = nx_value("ChargeShop")
  local counts = manager:GetOutDataItemCount()
  if 0 < counts then
    manager:DeleteOutDataItem(form.index - 1)
    on_btn_add_click(form.btn_4)
  else
    nx_destroy(form)
  end
end
function on_silver_card_changed(form)
  if form.price_type == nil or form.price_type ~= CAPITAL_TYPE_SILVER_CARD then
    return
  end
  local glod = 0
  local txt2 = ""
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    gold = mgr:GetCapital(CAPITAL_TYPE_SILVER_CARD)
    txt2 = mgr:GetFormatCapitalHtml(CAPITAL_TYPE_SILVER_CARD, gold)
  end
  form.mltbox_2.HtmlText = txt2
end
function on_integral_changed(form)
  if form.price_type == nil or form.price_type ~= CAPITAL_TYPE_INTEGRAL then
    return
  end
  local glod = 0
  local txt2 = ""
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    gold = mgr:GetCapital(CAPITAL_TYPE_INTEGRAL)
    txt2 = mgr:GetFormatCapitalHtml(CAPITAL_TYPE_INTEGRAL, gold)
  end
  form.mltbox_2.HtmlText = txt2
end
function on_gold_changed(form)
  if form.price_type == nil or form.price_type ~= CAPITAL_TYPE_GOLDEN then
    return
  end
  local glod = 0
  local txt2 = ""
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    gold = mgr:GetCapital(CAPITAL_TYPE_GOLDEN)
    txt2 = mgr:GetFormatCapitalHtml(CAPITAL_TYPE_GOLDEN, gold)
  end
  form.mltbox_2.HtmlText = txt2
end
function on_keep_click(brn)
  local manager = nx_value("ChargeShop")
  if not nx_is_valid(manager) then
    manager = nx_create("ChargeShop")
    nx_set_value("ChargeShop", manager)
  end
  local form = brn.ParentForm
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local point = capital:GetCapital(CAPITAL_TYPE_GOLDEN)
  if form.type == "vip" then
    nx_execute("form_stage_main\\form_vip_info", "on_point_buy_click")
    return
  end
  local total = capital:GetFormatCapitalHtml(form.price_type, form.price)
  local charge_id = form.charge_id
  local strid = "buy_charge_item_2"
  if not show_confirm_info(strid, form.configid, 1, total) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHARGE_SHOP), nx_int(3), charge_id, 1)
    close_page(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  close_page(form)
end
function on_shop_click(brn)
  nx_execute(G_SHOP_PATH, "show_charge_shop", CHARGE_ARTEQUIP_SHOP)
end
function on_mousein_grid(grid)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  if form.type == "item" then
    local config = form.configid
    nx_execute("tips_game", "show_tips_by_config", config, x, y, form)
  end
end
function on_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_server_msg(cmd, info, ...)
  if table.getn(arg) < 1 then
    return
  end
  if cmd == "vip" then
    show_vip_keep(info, arg[3])
  elseif cmd == "item" then
    show_item_keep(info, unpack(arg))
  end
end
function show_vip_keep(isvip, vipprice)
  if isvip ~= 0 then
    return
  end
  local form = util_get_form(g_form_name, true)
  if not nx_is_valid(form) then
    return
  end
  if vipprice == nil then
    vipprice = 30
  end
  local manager = nx_value("ChargeShop")
  if not nx_is_valid(manager) then
    manager = nx_create("ChargeShop")
    nx_set_value("ChargeShop", manager)
  end
  local index = -1
  local counts = manager:GetOutDataItemCount()
  for i = 1, counts do
    if manager:GetODIType(i - 1) == "vip" then
      index = i - 1
      break
    end
  end
  if index == -1 then
    index = 0
    manager:AddOutDataItem("vip", "icon\\prop\\prop635.png", index, CAPITAL_TYPE_GOLDEN, nx_int(vipprice))
  end
  if form.Visible then
    refresh_form(form)
  else
    local type = manager:GetODIType(index)
    local configid = manager:GetODIConfig(index)
    local price = manager:GetODIPrice(index, 0)
    local price_type = manager:GetODIPriceType(index, 0)
    local charge_id = manager:GetODIChargeID(index, 0)
    nx_set_custom(form, "index", 1)
    nx_set_custom(form, "type", type)
    nx_set_custom(form, "configid", configid)
    nx_set_custom(form, "price_type", price)
    nx_set_custom(form, "price", price)
    nx_set_custom(form, "price_type", price_type)
    nx_set_custom(form, "charge_id", charge_id)
    util_show_form(g_form_down, true)
  end
end
function show_item_keep(configid, ...)
  local form = util_get_form(g_form_name, true)
  if not nx_is_valid(form) then
    return
  end
  local manager = nx_value("ChargeShop")
  if not nx_is_valid(manager) then
    manager = nx_create("ChargeShop")
    nx_set_value("ChargeShop", manager)
  end
  for i = 1, table.getn(arg), 3 do
    manager:AddOutDataItem("item", configid, arg[i], arg[i + 1], arg[i + 2])
  end
  if manager:GetOutDataItemCount() <= 0 then
    return
  end
  if form.Visible then
    refresh_form(form)
  else
    local type = manager:GetODIType(0)
    local configid = manager:GetODIConfig(0)
    local price = manager:GetODIPrice(0, 0)
    local price_type = manager:GetODIPriceType(0, 0)
    local charge_id = manager:GetODIChargeID(0, 0)
    nx_set_custom(form, "index", 1)
    nx_set_custom(form, "type", type)
    nx_set_custom(form, "configid", configid)
    nx_set_custom(form, "price", price)
    nx_set_custom(form, "price_type", price_type)
    nx_set_custom(form, "charge_id", charge_id)
    util_show_form(g_form_down, true)
  end
end
function show_confirm_info(tip, ...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = util_format_string(tip, unpack(arg))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return false
    end
  end
  return true
end
function on_btn_sub_click(btn)
  local form = btn.ParentForm
  local manager = nx_value("ChargeShop")
  local counts = manager:GetOutDataItemCount()
  local index = form.index
  if 1 < index then
    form.index = index - 1
  end
  index = form.index
  local type = manager:GetODIType(index - 1)
  local configid = manager:GetODIConfig(index - 1)
  local price = manager:GetODIPrice(index - 1, 0)
  local price_type = manager:GetODIPriceType(index - 1, 0)
  local charge_id = manager:GetODIChargeID(index - 1, 0)
  nx_set_custom(form, "type", type)
  nx_set_custom(form, "configid", configid)
  nx_set_custom(form, "price", price)
  nx_set_custom(form, "price_type", price_type)
  nx_set_custom(form, "charge_id", charge_id)
  refresh_form(form)
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  local manager = nx_value("ChargeShop")
  local counts = manager:GetOutDataItemCount()
  local index = form.index
  if counts > index then
    form.index = index + 1
  end
  index = form.index
  form.lbl_4.Text = nx_widestr(index) .. nx_widestr("/") .. nx_widestr(counts)
  local type = manager:GetODIType(index - 1)
  local configid = manager:GetODIConfig(index - 1)
  local price = manager:GetODIPrice(index - 1, 0)
  local price_type = manager:GetODIPriceType(index - 1, 0)
  local charge_id = manager:GetODIChargeID(index - 1, 0)
  nx_set_custom(form, "type", type)
  nx_set_custom(form, "configid", configid)
  nx_set_custom(form, "price", price)
  nx_set_custom(form, "price_type", price_type)
  nx_set_custom(form, "charge_id", charge_id)
  refresh_form(form)
end
function close_page(form)
  local manager = nx_value("ChargeShop")
  local counts = manager:GetOutDataItemCount()
  if 0 < counts then
    manager:DeleteOutDataItem(form.index - 1)
    local counts = manager:GetOutDataItemCount()
    local index = form.index
    if counts < index then
      form.index = counts
    end
    index = form.index
    form.lbl_4.Text = nx_widestr(index) .. nx_widestr("/") .. nx_widestr(counts)
    local type = manager:GetODIType(index - 1)
    local configid = manager:GetODIConfig(index - 1)
    local price = manager:GetODIPrice(index - 1, 0)
    local price_type = manager:GetODIPriceType(index - 1, 0)
    local charge_id = manager:GetODIChargeID(index - 1, 0)
    nx_set_custom(form, "type", type)
    nx_set_custom(form, "configid", configid)
    nx_set_custom(form, "price", price)
    nx_set_custom(form, "price_type", price_type)
    nx_set_custom(form, "charge_id", charge_id)
    refresh_form(form)
  else
    form:Close()
  end
end
