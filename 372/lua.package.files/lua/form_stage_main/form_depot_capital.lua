require("util_gui")
require("util_functions")
require("share\\capital_define")
require("share\\view_define")
local g_form_name = "form_stage_main\\form_depot_capital"
local Ding = 1000000
local Liang = 1000
function showDepotMoney(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local box = game_client:GetView(nx_string(VIEWPORT_DEPOT))
  if not nx_is_valid(box) then
    return
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local silver = nx_int64(box:QueryProp("DepotSilver"))
  local silver_card = nx_int64(box:QueryProp("DepotSilverCard"))
  form.mltbox_1.HtmlText = capital:FormatCapital(CAPITAL_TYPE_SILVER, nx_int64(silver))
  form.mltbox_2.HtmlText = capital:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(silver_card))
  return
end
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.type = 0
  form.maxsilver = 0
  form.maxcard = 0
  form.cursilver = 0
  form.curcard = 0
  check_value(form)
  showDepotMoney(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function show_form_save(maxsilver, maxcard, cursilver, curcard)
  util_show_form(g_form_name, true)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  form.type = 2
  form.maxsilver = maxsilver
  form.maxcard = maxcard
  form.cursilver = cursilver
  form.curcard = curcard
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  form.lbl_3.Text = util_format_string("ui_depot_tip_1")
  form.lbl_9.Text = util_format_string("ui_store_amount")
  form.lbl_1.Visible = true
  form.lbl_2.Visible = true
  form.lbl_1.Text = util_format_string("ui_deposit_limit_1", capital:FormatCapital(CAPITAL_TYPE_SILVER, nx_int64(maxsilver)))
  form.lbl_2.Text = util_format_string("ui_deposit_limit_2", capital:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(maxcard)))
  local now_silver = nx_int64(capital:GetCapital(CAPITAL_TYPE_SILVER))
  local now_card = nx_int64(capital:GetCapital(CAPITAL_TYPE_SILVER_CARD))
  local save_silver = 0
  local save_card = 0
  if maxcard < curcard then
    save_card = 0
  else
    save_card = nx_int64(maxcard - curcard)
  end
  if maxsilver < cursilver then
    save_silver = 0
  else
    save_silver = nx_int64(maxsilver - cursilver)
  end
  if nx_int64(save_silver) < nx_int64(0) then
    save_silver = 0
  end
  if nx_number(save_silver) > nx_number(now_silver) then
    save_silver = now_silver
  end
  if nx_number(save_card) > nx_number(now_card) then
    save_card = now_card
  end
  form.ipt_1.Max_Digit = save_silver
  form.ipt_2.Max_Digit = save_card
end
function show_form_putout(cursilver, curcard)
  util_show_form(g_form_name, true)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  form.type = 3
  form.cursilver = cursilver
  form.curcard = curcard
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  form.lbl_3.Text = util_format_string("ui_depot_tip_2")
  form.lbl_9.Text = util_format_string("ui_take_amount")
  form.lbl_1.Visible = false
  form.lbl_2.Visible = false
  form.ipt_1.Max_Digit = nx_int64(cursilver)
  form.ipt_2.Max_Digit = nx_int64(curcard)
end
function on_ipt_1_changed(ipt)
  local form = ipt.ParentForm
  if nx_int64(form.ipt_1.Text) < nx_int64(0) then
    form.ipt_1.Text = nx_widestr(0)
  end
  if nx_int64(form.ipt_sliver_liang.Text) < nx_int64(0) then
    form.ipt_sliver_liang.Text = nx_widestr(0)
  end
  if nx_int64(form.ipt_sliver_wen.Text) < nx_int64(0) then
    form.ipt_sliver_wen.Text = nx_widestr(0)
  end
  local tmp_max_silver = nx_int64(nx_int64(form.ipt_1.Text) * Ding + nx_int64(form.ipt_sliver_liang.Text) * Liang + nx_int64(form.ipt_sliver_wen.Text))
  if nx_number(tmp_max_silver) > nx_number(form.ipt_1.Max_Digit) then
    tmp_max_silver = nx_int64(form.ipt_1.Max_Digit)
    form.ipt_1.Text = nx_widestr(nx_int64(tmp_max_silver / Ding))
    form.ipt_sliver_liang.Text = nx_widestr(nx_int64((nx_int64(tmp_max_silver) - nx_int64(form.ipt_1.Text) * Ding) / Liang))
    form.ipt_sliver_wen.Text = nx_widestr(nx_int64(tmp_max_silver) - nx_int64(form.ipt_1.Text) * Ding - nx_int64(form.ipt_sliver_liang.Text) * Liang)
  end
  check_value(ipt.ParentForm)
end
function on_ipt_2_changed(ipt)
  local form = ipt.ParentForm
  if nx_number(form.ipt_2.Text) < nx_number(0) then
    form.ipt_2.Text = nx_widestr(0)
  end
  if nx_number(form.ipt_card_liang.Text) < nx_number(0) then
    form.ipt_card_liang.Text = nx_widestr(0)
  end
  if nx_number(form.ipt_card_wen.Text) < nx_number(0) then
    form.ipt_card_wen.Text = nx_widestr(0)
  end
  local tmp_max_card = nx_int64(nx_int64(form.ipt_2.Text) * Ding + nx_int64(form.ipt_card_liang.Text) * Liang + nx_int64(form.ipt_card_wen.Text))
  if nx_number(tmp_max_card) > nx_number(form.ipt_2.Max_Digit) then
    tmp_max_card = nx_int64(form.ipt_2.Max_Digit)
    form.ipt_2.Text = nx_widestr(nx_int64(tmp_max_card / Ding))
    form.ipt_card_liang.Text = nx_widestr(nx_int64((tmp_max_card - nx_int64(form.ipt_2.Text) * Ding) / Liang))
    form.ipt_card_wen.Text = nx_widestr(tmp_max_card - nx_int64(form.ipt_2.Text) * Ding - nx_int64(form.ipt_card_liang.Text) * Liang)
  end
  check_value(ipt.ParentForm)
end
function check_value(form)
  local silver = nx_int64(nx_int64(form.ipt_1.Text) * Ding + nx_int64(form.ipt_sliver_liang.Text) * Liang + nx_int64(form.ipt_sliver_wen.Text))
  local card = nx_int64(nx_int64(form.ipt_2.Text) * Ding + nx_int64(form.ipt_card_liang.Text) * Liang + nx_int64(form.ipt_card_wen.Text))
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  if nx_number(silver) < nx_number(0) or nx_number(card) < nx_number(0) then
    form.btn_2.Enabled = false
    return
  end
  form.btn_2.Enabled = nx_number(silver) > nx_number(0) or nx_number(card) > nx_number(0)
end
function on_ok_click(btn)
  local form = btn.ParentForm
  local value = nx_int64(nx_int64(form.ipt_1.Text) * Ding + nx_int64(form.ipt_sliver_liang.Text) * Liang + nx_int64(form.ipt_sliver_wen.Text))
  if nx_number(value) > nx_number(0) then
    nx_execute("custom_sender", "send_depot_msg", form.type, CAPITAL_TYPE_SILVER, value)
  end
  value = nx_int64(nx_int64(form.ipt_2.Text) * Ding + nx_int64(form.ipt_card_liang.Text) * Liang + nx_int64(form.ipt_card_wen.Text))
  if nx_number(value) > nx_number(0) then
    nx_execute("custom_sender", "send_depot_msg", form.type, CAPITAL_TYPE_SILVER_CARD, value)
  end
  util_show_form(g_form_name, false)
end
