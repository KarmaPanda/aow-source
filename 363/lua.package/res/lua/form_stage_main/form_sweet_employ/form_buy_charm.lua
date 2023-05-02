require("util_gui")
require("util_functions")
require("share\\capital_define")
require("form_stage_main\\form_sweet_employ\\sweet_employ_define")
require("form_stage_main\\form_sweet_employ\\sweet_employ_common")
local FORM_BUY_CHARM = "form_stage_main\\form_sweet_employ\\form_buy_charm"
local FORM_CONFIRM = "form_common\\form_confirm"
local INI_GROW_PLAYER = "share\\SweetEmploy\\Grow\\Grow_player.ini"
local table_charm_value = {}
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_pos(form)
  add_data_bind(form)
  set_form_data(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 + 450
  form.Top = (gui.Height - form.Height) / 2 + 230
end
function load_grow_config()
  local ini = get_ini(INI_GROW_PLAYER)
  if not nx_is_valid(ini) then
    return
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local level = ini:GetSectionByIndex(i)
    local value = ini:ReadInteger(i, "cur_value", 0)
    table_charm_value[nx_number(level)] = nx_int(value)
  end
end
function get_money()
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return 0
  end
  return capital:GetCapital(CAPITAL_TYPE_SILVER_CARD)
end
function set_money(form)
  local money = get_money()
  local text = format_money_text(money)
  form.lbl_money.Text = nx_widestr(text)
end
function get_unit_price()
  local level = get_player_prop("CharmLevel")
  if nx_int(level) < nx_int(MIN_LEVEL_CHARM) or nx_int(level) > nx_int(MAX_LEVEL_CHARM) then
    return 0
  end
  return nx_int(10 + level / 3)
end
function set_unit_price(form)
  form.lbl_unit_price.Text = nx_widestr(get_unit_price())
end
function get_total_value(form)
  local unit_price = get_unit_price()
  local count = nx_int(form.lbl_buy_count.DataSource)
  return unit_price * count
end
function set_total_value(form)
  local value = get_total_value(form)
  form.ipt_total_value.Text = nx_widestr(value)
end
function get_buy_count(form)
  return nx_int(form.lbl_buy_count.DataSource)
end
function set_buy_count(form)
  local count = get_buy_count(form)
  form.lbl_buy_count.Text = nx_widestr(count)
end
function reset_buy_count(form)
  form.lbl_buy_count.DataSource = nx_string("0")
end
function set_buy_info(form)
  load_grow_config()
  set_unit_price(form)
  set_total_value(form)
  set_buy_count(form)
end
function reset_buy_info(form)
  reset_buy_count(form)
  set_buy_info(form)
end
function set_form_data(form)
  set_buy_info(form)
  set_buy_max_info(form)
end
function add_data_bind(form)
  local binder = nx_value("data_binder")
  if not nx_is_valid(binder) then
    return
  end
  binder:AddRolePropertyBind("CapitalType2", "int", form, nx_current(), "on_silver_card_change")
  binder:AddRolePropertyBind("CharmLevel", "int", form, nx_current(), "on_charm_level_change")
  binder:AddRolePropertyBind("CharmValue", "int", form, nx_current(), "on_charm_value_change")
end
function on_silver_card_change(form)
  set_buy_max_info(form)
end
function on_charm_level_change(form)
  set_buy_info(form)
  set_buy_max_info(form)
end
function on_charm_value_change(form)
  reset_buy_info(form)
  set_buy_max_info(form)
end
function on_btn_dec_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local count = nx_int(form.lbl_buy_count.DataSource)
  if nx_int(count) <= nx_int(0) then
    return
  end
  form.lbl_buy_count.DataSource = nx_string(count - 1)
  set_buy_info(form)
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local count = nx_int(form.lbl_buy_count.DataSource)
  if not is_buy_count_valid(count + 1) then
    return
  end
  form.lbl_buy_count.DataSource = nx_string(count + 1)
  set_buy_info(form)
end
function is_buy_count_valid(count)
  if nx_int(count) <= nx_int(0) then
    return false
  end
  local delta_value = get_charm_delta()
  if nx_int(delta_value) <= nx_int(0) then
    return false
  end
  local unit_price = get_unit_price()
  if nx_int(unit_price) <= nx_int(0) then
    return false
  end
  local total_value = unit_price * count
  if nx_int(total_value) > nx_int(delta_value) then
    return false
  end
  local money = nx_int64(get_money()) / 1000
  local total_price = count
  if nx_int(total_price) > nx_int(money) then
    return false
  end
  return true
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local count = nx_int(form.lbl_buy_count.DataSource)
  if nx_int(count) <= nx_int(0) and not is_buy_count_valid(count) then
    return
  end
  buy_charm(form, count)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_charm_delta()
  load_grow_config()
  local level = get_player_prop("CharmLevel")
  if nx_int(level) < nx_int(MIN_LEVEL_CHARM) or nx_int(level) > nx_int(MAX_LEVEL_CHARM) then
    return 0
  end
  local max_value = 0
  if table_charm_value[nx_number(level)] ~= nil then
    max_value = table_charm_value[nx_number(level)]
  end
  local cur_value = get_player_prop("CharmValue")
  if nx_int(cur_value) < nx_int(0) or nx_int(cur_value) > nx_int(max_value) then
    return 0
  end
  local delta_value = nx_int(max_value - cur_value)
  if nx_int(delta_value) <= nx_int(0) then
    return 0
  end
  return delta_value
end
function close_buy_max(form)
  form.btn_buy_max.Enabled = false
  form.mltbox_buy_max.HtmlText = util_format_string("ui_sweetemploy_tips24", 0)
end
function open_buy_max(form, value, money)
  form.btn_buy_max.Enabled = true
  form.mltbox_buy_max.HtmlText = util_format_string("ui_sweetemploy_tips24", value)
end
function set_buy_max_info(form)
  close_buy_max(form)
  local delta_value = get_charm_delta()
  if nx_int(delta_value) <= nx_int(0) then
    return false
  end
  local unit_price = get_unit_price()
  if nx_int(unit_price) <= nx_int(0) then
    return false
  end
  local count = nx_int(delta_value / unit_price)
  local money = nx_int64(get_money()) / 1000
  if nx_int(money) <= nx_int(0) then
    return false
  end
  if nx_int(count) > nx_int(money) then
    count = money
  end
  form.mltbox_buy_max.DataSource = nx_string(count)
  local total_value = unit_price * count
  open_buy_max(form, total_value, count)
end
function on_btn_buy_max_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local count = nx_int(form.mltbox_buy_max.DataSource)
  if nx_int(count) <= nx_int(0) and not is_buy_count_valid(count) then
    return
  end
  buy_charm(form, count)
end
function buy_charm(form, count)
  local unit_price = get_unit_price()
  if nx_int(unit_price) <= nx_int(0) then
    return
  end
  local total_value = unit_price * count
  local dialog = util_get_form(FORM_CONFIRM, true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = util_format_string("ui_sweetemploy_tips23", count, total_value)
  nx_execute(FORM_CONFIRM, "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  nx_execute("custom_sender", "custom_offline_employ", nx_int(14), nx_int(count))
end
