require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\url_define")
require("share\\capital_define")
local g_form_name = "form_stage_main\\form_consign\\form_buy_capital_point"
function get_gold(form, buy_value)
  local price = form.buy_price
  if 0 < price then
    return buy_value / price
  end
  return buy_value / 10000
end
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    form.CapitalMgr = mgr
  else
    util_show_form(g_form_name, false)
    return
  end
  form.gold = 0
  form.card = 0
  form.buy_value = 0
  form.max_buy_value = 10000000
  form.buy_price = 1.0E-4
  form.buy_page.group = form.groupbox_buy
  form.histroy_page.group = form.groupbox_histroy
  local box = form.combobox_choose.DropListBox
  box:ClearString()
  local g_default = {
    1,
    5,
    10,
    20,
    50,
    100,
    500,
    1000
  }
  for i, value in pairs(g_default) do
    box:AddString(nx_widestr(value))
  end
  box.SelectIndex = 0
  local grid = form.textgrid_1
  grid:SetColTitle(0, util_format_string("ui_buy_capital_date"))
  grid:SetColTitle(1, util_format_string("ui_buy_capital_value"))
  grid:SetColTitle(2, util_format_string("ui_buy_capital_consum"))
  local databinder = nx_value("data_binder")
  local ret = databinder:AddRolePropertyBind("CapitalType0", "int", form, g_form_name, "on_gold_changed")
  ret = databinder:AddRolePropertyBind("CapitalType2", "int", form, g_form_name, "on_card_changed")
  form.groupbox_histroy.Visible = false
  form.groupbox_buy.Visible = false
  form.buy_page.Checked = true
  form.btn_2.Enabled = false
  nx_execute("custom_sender", "custom_buy_capital", 3)
end
function on_main_form_close(form)
  local binder = nx_value("data_binder")
  if nx_is_valid(binder) then
    binder:DelRolePropertyBind("CapitalType0", form)
    binder:DelRolePropertyBind("CapitalType2", form)
  end
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_page_checked_changed(rbtn)
  rbtn.group.Visible = rbtn.Checked
end
function on_combobox_choose_selected(cbox)
  local form = cbox.ParentForm
  local wstr = cbox.DropListBox.SelectString
  local nums = nx_number(wstr) * form.buy_price
  local mgr = form.CapitalMgr
  local v = mgr:FormatCapital(nx_int(CAPITAL_TYPE_SILVER_CARD), nx_int64(nums))
  cbox.ParentForm.mltbox_silver.HtmlText = v
  form.buy_value = nums
  form.btn_2.Enabled = nx_number(wstr) <= form.gold and nums <= form.max_buy_value
end
function on_ok_click(btn)
  local form = btn.ParentForm
  local buy_value = form.buy_value
  if buy_value <= 0 then
    return
  end
  if form.buy_price < 1.0E-5 then
    return
  end
  local consum_point = get_gold(form, buy_value)
  if consum_point > form.gold or buy_value > form.max_buy_value then
    return
  end
  function show_confirm_info(tip, ...)
    local dialog = util_get_form("form_common\\form_confirm", true, false)
    if nx_is_valid(dialog) then
      dialog.mltbox_info.HtmlText = util_format_string(tip, unpack(arg))
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" then
        return true
      end
    end
    return false
  end
  local mgr = form.CapitalMgr
  if show_confirm_info("ui_buy_money_tips", mgr:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(buy_value)), mgr:FormatCapital(CAPITAL_TYPE_GOLDEN, nx_int64(consum_point))) then
    nx_execute("custom_sender", "custom_buy_capital", 2, 2, buy_value)
  end
end
function on_online_charge_click(btn)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function on_server_msg(...)
  if table.getn(arg) < 1 then
    return
  end
  local msgid = nx_number(arg[1])
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  function format_time_form(time_value)
    local str = "{@0:y}{@1:y}{@2:m}{@3:m}{@4:d}{@5:d}{@6:h}{@7:h}"
    local t = os.date("*t", time_value)
    return util_format_string(str, t.year, "ui_g_year", t.month, "ui_g_month", t.day, "ui_g_day", t.hour, "ui_g_hour")
  end
  if msgid == 3 then
    local grid = form.textgrid_1
    local rec = util_split_string(arg[2], ";")
    grid.RowCount = table.getn(rec) - 1
    local mgr = form.CapitalMgr
    for i, str in pairs(rec) do
      local row = util_split_string(str, ",")
      if table.getn(row) >= 3 then
        grid:SetGridText(i - 1, 0, format_time_form(nx_number(row[1])))
        grid:SetGridText(i - 1, 1, mgr:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(row[2])))
        grid:SetGridText(i - 1, 2, mgr:FormatCapital(CAPITAL_TYPE_GOLDEN, nx_int64(row[3])))
      end
    end
  end
end
function on_card_changed(form)
  local card = form.CapitalMgr:GetCapital(CAPITAL_TYPE_SILVER_CARD)
  form.mltbox_capital_silver.HtmlText = form.CapitalMgr:FormatCapital(CAPITAL_TYPE_SILVER_CARD, card)
  form.card = card
end
function on_gold_changed(form)
  local gold = form.CapitalMgr:GetCapital(CAPITAL_TYPE_GOLDEN)
  form.mltbox_capital_gold.HtmlText = form.CapitalMgr:FormatCapital(CAPITAL_TYPE_GOLDEN, gold)
  form.gold = gold
end
function sysinfo(strid, ...)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_format_string(strid, unpack(arg)), 2)
  end
end
function on_fresh_max_buy_value(form)
end
