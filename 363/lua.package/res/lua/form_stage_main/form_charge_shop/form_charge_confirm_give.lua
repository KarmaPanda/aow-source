require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\capital_define")
require("util_gui")
function on_main_form_init(self)
  self.Fixed = false
  self.price = 0
  self.charge_id = 0
  self.config = ""
  self.title = nx_widestr("ui_mail_chargeshop_text")
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_friend(form)
  form.ript_liuyan.MaxLength = 128
  form.index = -1
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_buy_click(btn)
  local form = btn.ParentForm
  local nums = nx_int(form.ipt_nums.Text)
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local shop_manager = nx_value("ChargeShop")
  if not nx_is_valid(shop_manager) then
    return
  end
  local index = nx_custom(form, "index")
  local price = shop_manager:GetPrice(index)
  local price_type = shop_manager:GetPriceType(index)
  local total = nx_int(price) * nums
  if nx_int(total) <= nx_int(0) then
    return
  end
  if not can_buy_item(form, total) then
    sysinfo("buy_charge_item_1", form.config)
    return
  end
  local list = form.combobox_friend.DropListBox
  local give_name = list.SelectString
  if nx_string(give_name) == "" then
    sysinfo("buy_charge_item_15")
    return
  end
  local str = manager:GetFormatCapitalHtml(price_type, nx_int64(total))
  if not show_confirm_info("buy_charge_item_3", form.config, nums, str) then
    return
  end
  local charge_id = form.charge_id
  if nx_int(charge_id) <= nx_int(0) then
    return
  end
  local title = form.title
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHARGE_SHOP), nx_int(2), charge_id, nums, give_name, title, context)
    form:Close()
  end
end
function on_nums_changed(ipt)
  local v = nx_int(ipt.Text)
  if v <= nx_int(0) then
    v = nx_int(1)
    ipt.Text = nx_widestr(1)
  end
  local form = ipt.ParentForm
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local shop_manager = nx_value("ChargeShop")
  if not nx_is_valid(shop_manager) then
    return
  end
  local index = nx_custom(form, "index")
  local price = shop_manager:GetPrice(index)
  local price_type = shop_manager:GetPriceType(index)
  local total = nx_int(price) * v
  form.mltbox_2:Clear()
  form.mltbox_2:AddHtmlText(manager:GetFormatCapitalHtml(price_type, nx_int64(total)), 0)
end
function on_mousein_grid(grid)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local manager = nx_value("ChargeShop")
  nx_execute("tips_game", "show_tips_by_config", form.config, x, y, form)
end
function on_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function set_info(form)
  form.lbl_name = form.name
end
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
function sysinfo(strid, ...)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_format_string(strid, unpack(arg)), 2)
  end
end
function can_buy_item(form, total)
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return false
  end
  local shop_manager = nx_value("ChargeShop")
  if not nx_is_valid(shop_manager) then
    return
  end
  local index = nx_custom(form, "index")
  local price_type = shop_manager:GetPriceType(nx_int(index))
  return capital:CanDecCapital(price_type, nx_int64(total))
end
function init_friend(form)
  local list = form.combobox_friend.DropListBox
  list:ClearString()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local str = player:QueryProp("Name")
  local rows = player:GetRecordRows("rec_friend")
  for i = 0, rows - 1 do
    local name = player:QueryRecord("rec_friend", i, 1)
    list:AddString(nx_widestr(name))
  end
  rows = player:GetRecordRows("rec_buddy")
  for i = 0, rows - 1 do
    local name = player:QueryRecord("rec_buddy", i, 1)
    list:AddString(nx_widestr(name))
  end
  rows = player:GetRecordRows("rec_attention")
  for i = 0, rows - 1 do
    local name = player:QueryRecord("rec_attention", i, 1)
    list:AddString(nx_widestr(name))
  end
end
function on_online_charge_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_charge_shop\\form_online_charge")
end
