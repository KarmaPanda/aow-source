require("util_gui")
require("game_object")
require("share\\capital_define")
local g_form_name = "form_stage_main\\form_shop\\form_trade_buy"
function main_form_init(form)
  form.Fixed = false
  form.bSell = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  gui.Focused = form.ipt_count
  form.lbl_max_count.Visible = false
  form.lbl_s_price.Visible = false
  form.lbl_model.Visible = false
  form.type = 1
  form.ipt_count.Text = nx_widestr("1")
  return 1
end
function on_main_form_close(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_gen_event(form, "form_retail_return", "cancel")
  nx_destroy(form)
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  local count = nx_int(form.ipt_count.Text)
  local max_count = nx_int(form.lbl_max_count.Text)
  local paymodel = nx_int(form.lbl_model.Text)
  if count <= nx_int(0) or count > max_count then
  else
    form:Close()
    if nx_find_custom(form, "retail_mode") and nx_string(form.retail_mode) == nx_string("sell") then
      nx_gen_event(form, "form_retail_return_sell", "ok", count, paymodel)
    else
      nx_gen_event(form, "form_retail_return", "ok", count, paymodel)
    end
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  on_btn_close_click(btn)
end
function on_ipt_count_changed(txt)
  if nx_string(txt.Text) == "-" then
    txt.Text = nx_widestr("")
    return
  end
  local value = nx_string(txt.Text)
  value = nx_number(value)
  if value < 0 then
    txt.Text = nx_widestr("")
    return
  end
  refresh_total_price(txt.ParentForm)
end
function on_btn_auto_fit_click(btn)
  local form = btn.ParentForm
  local max_count = nx_int(form.lbl_max_count.Text)
  if max_count <= nx_int(0) then
    local text = nx_widestr(util_text("1650"))
    show_prompt_dialog(form, text)
    return
  end
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    return 0
  end
  local total_money = 0
  local trade_model = nx_int(form.lbl_model.Text)
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return 0
  end
  local total_money = mgr:GetCapital(trade_model)
  if trade_model == nx_int(CAPITAL_TYPE_SILVER) then
    total_money = total_money + mgr:GetCapital(CAPITAL_TYPE_SILVER_CARD)
  end
  local unit_price = nx_int64(form.lbl_s_price.Text)
  local count = max_count
  if nx_int64(unit_price) > nx_int64(0) then
    count = nx_int64(total_money / unit_price)
  end
  if max_count <= count then
    form.ipt_count.Text = nx_widestr(max_count)
  else
    form.ipt_count.Text = nx_widestr(count)
  end
  if form.bSell then
    form.ipt_count.Text = nx_widestr(max_count)
  end
  refresh_total_price(form)
  if nx_string(form.ipt_count.Text) == "" then
    local text = nx_widestr(util_text("ui_buy_money"))
    if trade_model == nx_int(CAPITAL_TYPE_SILVER_CARD) then
      text = nx_widestr(util_text("ui_buy_kubi_money"))
    elseif trade_model == nx_int(CAPITAL_TYPE_GOLDEN) then
      text = nx_widestr(util_text("ui_buy_dakubi_money"))
    end
    show_prompt_dialog(form, text)
  end
end
function on_btn_down_click(btn)
  local form = btn.ParentForm
  local cur_count = nx_int(form.ipt_count.Text)
  local max_count = nx_int(form.lbl_max_count.Text)
  if cur_count <= nx_int(1) then
    cur_count = nx_int(1)
  else
    cur_count = cur_count - 1
  end
  form.ipt_count.Text = nx_widestr(cur_count)
  refresh_total_price(form)
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  local cur_count = nx_int(form.ipt_count.Text)
  local max_count = nx_int(form.lbl_max_count.Text)
  if cur_count >= max_count then
    cur_count = max_count
  else
    cur_count = cur_count + 1
  end
  form.ipt_count.Text = nx_widestr(cur_count)
  refresh_total_price(form)
end
function init_buy_form(form, money_type, price, count)
  money_type = nx_number(money_type)
  if money_type ~= CAPITAL_TYPE_GOLDEN and money_type ~= CAPITAL_TYPE_SILVER and money_type ~= CAPITAL_TYPE_SILVER_CARD then
    return
  end
  form.type = money_type
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return
  end
  if nx_find_custom(form, "item_obj") and nx_is_valid(form.item_obj) then
    price = nx_execute("form_stage_main\\form_shop\\form_exchange", "get_rebate_value", form.item_obj, price)
  end
  form.lbl_s_price.Text = nx_widestr(price)
  form.lbl_model.Text = nx_widestr(money_type)
  form.ipt_count.Text = nx_widestr(count)
  form.lbl_max_count.Text = nx_widestr(count)
  local cur_count = nx_int(form.ipt_count.Text)
  local icon = mgr:GetCapitalIcon(nx_int(money_type))
  local wsprice = mgr:FormatCapital(nx_int(money_type), nx_int64(price))
  local wstotal = mgr:FormatCapital(nx_int(money_type), nx_int64(price * cur_count))
  form.lbl_silver_mark1.BackImage = icon
  form.lbl_silver_mark2.BackImage = icon
  form.ipt_price.Text = wsprice
  form.ipt_total_price.Text = wstotal
end
function refresh_total_price(form)
  local input_text = nx_string(form.ipt_count.Text)
  if string.find(input_text, "0") == 1 then
    input_text = string.sub(input_text, 2, string.len(input_text))
    form.ipt_count.Text = nx_widestr(input_text)
  end
  local cur_count = nx_int(form.ipt_count.Text)
  local max_count = nx_int(form.lbl_max_count.Text)
  if cur_count > max_count then
    cur_count = max_count
    form.ipt_count.Text = nx_widestr(cur_count)
  end
  local unit_price = nx_int64(form.lbl_s_price.Text)
  local total_price = nx_int64(unit_price * cur_count)
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return
  end
  local type = nx_int(form.type)
  local ws = mgr:FormatCapital(type, total_price)
  form.ipt_total_price.Text = ws
end
function show_prompt_dialog(form, text)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.cancel_btn.Visible = false
  dialog.ok_btn.Left = (dialog.Width - dialog.ok_btn.Width) / 2
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
end
