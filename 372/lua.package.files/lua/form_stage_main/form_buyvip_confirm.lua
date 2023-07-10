require("util_gui")
require("util_functions")
require("share\\capital_define")
require("util_vip")
require("form_stage_main\\switch\\switch_define")
local g_form_name = "form_stage_main\\form_buyvip_confirm"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  form.fipt_1.Text = nx_widestr(1)
  form.lbl_3.Text = util_format_string("{@0:gold}", g_buy_vip_price)
  databinder:AddRolePropertyBind("CapitalType0", "int", form, g_form_name, "on_gold_changed")
  databinder:AddTableBind("vip_info_rec", form, g_form_name, "on_vip_info_rec_change")
  form.rbtn_1.Checked = true
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return
  end
  change_switch_41(ST_FUNCTION_VIP_JINGXIU_1, mgr:CheckSwitchEnable(ST_FUNCTION_VIP_JINGXIU_1))
  change_switch_42(ST_FUNCTION_VIP_JINGXIU_2, mgr:CheckSwitchEnable(ST_FUNCTION_VIP_JINGXIU_2))
end
function on_vip_info_rec_change(self, recordname, optype, row, clomn)
  if clomn == VIR_STATUS or clomn == VIR_VALID_TIME then
    on_vip_changed(self)
  end
end
function open_form(...)
  local count = arg[1]
  if count == nil or nx_int(count) < nx_int(1) then
    return
  end
  local price = 0
  local str_price = ""
  for i = 1, nx_number(count) do
    local vtype = arg[i * 2]
    local vprice = arg[i * 2 + 1]
    str_price = str_price .. "|" .. nx_string(vtype) .. ";" .. nx_string(vprice)
    if vtype == VT_NORMAL then
      price = vprice
    end
  end
  if price == 0 then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.str_price = str_price
  form.lbl_3.Text = util_format_string("{@0:gold}", price)
  form.lbl_price.Text = util_format_string("ui_buyvip_price", nx_int(price), nx_int(1))
  util_show_form(g_form_name, true)
end
function get_vip_price(vip_type)
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  local list = util_split_string(nx_string(form.str_price), "|")
  for i = 2, table.getn(list) do
    if list[i] ~= "" then
      local sub_list = util_split_string(list[i], ";")
      if nx_int(vip_type) == nx_int(sub_list[1]) then
        return nx_int(sub_list[2])
      end
    end
  end
  return 0
end
function on_vip_changed(form)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local now = nx_number(get_vip_time(player, VT_NORMAL))
  if not is_vip(player, VT_NORMAL) or now == 0 then
    local vip_module = nx_value("VipModule")
    if nx_is_valid(vip_module) then
      now = nx_number(vip_module:GetServerSecond())
    else
      now = os.time()
    end
  end
  local times = nx_int(form.fipt_1.Text)
  local valid_time = nx_number(g_buy_vip_time * times) + nx_number(now)
  local t = os.date("*t", valid_time)
  local vtype = get_type(form)
  form.mltbox_info:Clear()
  if vtype == 1 then
    form.mltbox_info.HtmlText = util_format_string("ui_buyvip_tips", nx_int(t.year), nx_int(t.month), nx_int(t.day), nx_int(t.hour))
  elseif vtype == 2 then
    if not is_vip(player, VT_NORMAL) then
      form.mltbox_info.HtmlText = util_format_string("ui_buyvip_1")
    elseif get_vip_revert_time(VT_NORMAL) - get_vip_revert_time(VT_JINGXIU) < g_buy_vip_time then
      form.mltbox_info.HtmlText = util_format_string("ui_buyvip_1")
    else
      local t_jingxiu = get_jingxiu_endtime(form)
      form.mltbox_info.HtmlText = util_format_string("ui_buyvip_3", nx_int(t_jingxiu.year), nx_int(t_jingxiu.month), nx_int(t_jingxiu.day), nx_int(t_jingxiu.hour))
    end
  elseif vtype == 3 then
    local t_jingxiu = get_jingxiu_endtime(form)
    form.mltbox_info.HtmlText = util_format_string("ui_buyvip_4", nx_int(t.year), nx_int(t.month), nx_int(t.day), nx_int(t.hour), nx_int(t_jingxiu.year), nx_int(t_jingxiu.month), nx_int(t_jingxiu.day), nx_int(t_jingxiu.hour))
  elseif vtype == 4 then
    local time_normal = nx_number(get_vip_revert_time(VT_NORMAL))
    local time_jingxiu = nx_number(get_vip_revert_time(VT_JINGXIU))
    if is_vip(player, VT_NORMAL) and nx_number(time_normal - time_jingxiu) >= nx_number(g_buy_vip_time * 3) then
      local t_jingxiu = get_jingxiu_endtime(form)
      form.mltbox_info.HtmlText = util_format_string("ui_buyvip_3", nx_int(t_jingxiu.year), nx_int(t_jingxiu.month), nx_int(t_jingxiu.day), nx_int(t_jingxiu.hour))
    else
      form.mltbox_info.HtmlText = util_format_string("ui_buyvip_6")
    end
  end
end
function get_jingxiu_endtime(form)
  if not nx_is_valid(form) then
    return os.date("*t", os.time())
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return os.date("*t", os.time())
  end
  local now_jingxiu = nx_number(get_vip_time(player, VT_JINGXIU))
  if not is_vip(player, VT_JINGXIU) or now_jingxiu == 0 then
    local vip_module = nx_value("VipModule")
    if nx_is_valid(vip_module) then
      now_jingxiu = nx_number(vip_module:GetServerSecond())
    else
      now_jingxiu = os.time()
    end
  end
  local times_jingxiu = nx_int(form.fipt_1.Text)
  if get_type(form) == 4 then
    times_jingxiu = times_jingxiu * 3
  end
  local valid_time_jingxiu = nx_number(g_buy_vip_time * times_jingxiu) + nx_number(now_jingxiu)
  return os.date("*t", valid_time_jingxiu)
end
function on_gold_changed(form)
  local glod = 0
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    gold = mgr:GetCapital(CAPITAL_TYPE_GOLDEN)
  end
  form.lbl_money.Text = util_format_string("{@0:gold}", nx_int64(gold))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_buy_click(btn)
  local form = btn.ParentForm
  local now = nx_number(form.fipt_1.Text)
  local vip_type = get_type(form)
  send_vip_msg(G_CMD_BUY_VIP, nx_int(vip_type), nx_int(now))
  util_show_form(g_form_name, false)
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  local type = get_type(form)
  local now = nx_int(form.fipt_1.Text)
  if now < nx_int(36) then
    form.fipt_1.Text = nx_widestr(now + 1)
    form.lbl_3.Text = util_format_string("{@0:gold}", nx_int(form.fipt_1.Text) * get_vip_price(type))
    on_vip_changed(form)
  end
  if nx_int(form.fipt_1.Text) == nx_int(36) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("100118"))
  elseif nx_int(form.fipt_1.Text) >= nx_int(form.fipt_1.Max) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("100113"))
  end
  form.sure_btn.Enaled = get_gold() >= nx_int(form.fipt_1.Text) * get_vip_price(type)
end
function on_btn_sub_click(btn)
  local form = btn.ParentForm
  local type = get_type(form)
  local now = nx_int(form.fipt_1.Text)
  if now > nx_int(1) then
    form.fipt_1.Text = nx_widestr(now - 1)
    form.lbl_3.Text = util_format_string("{@0:gold}", nx_int(form.fipt_1.Text) * get_vip_price(type))
    on_vip_changed(form)
  end
  form.sure_btn.Enaled = get_gold() >= nx_int(form.fipt_1.Text) * get_vip_price(type)
end
function on_rbtn_vip_type_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if form.rbtn_1.Checked == true then
    reset_ctrl_state(form)
  elseif form.rbtn_2.Checked == true then
    local time = nx_number(get_vip_revert_time(VT_NORMAL))
    local time_jingxiu = nx_number(get_vip_revert_time(VT_JINGXIU))
    if is_vip(player, VT_NORMAL) and nx_number(time - time_jingxiu) >= nx_number(g_buy_vip_time) then
      form.fipt_1.Max = nx_int((time - time_jingxiu) / g_buy_vip_time)
      form.btn_3.Enabled = true
      form.fipt_1.Text = nx_widestr("1")
      form.sure_btn.Enabled = true
    else
      form.btn_3.Enabled = false
      form.fipt_1.Text = nx_widestr("0")
      form.sure_btn.Enabled = false
    end
  elseif form.rbtn_3.Checked == true then
    reset_ctrl_state(form)
  elseif form.rbtn_4.Checked == true then
    local time = nx_number(get_vip_revert_time(VT_NORMAL))
    local time_jingxiu = nx_number(get_vip_revert_time(VT_JINGXIU))
    if is_vip(player, VT_NORMAL) and nx_number(time - time_jingxiu) >= nx_number(g_buy_vip_time * 3) then
      form.fipt_1.Max = nx_int((time - time_jingxiu) / (g_buy_vip_time * 3))
      form.btn_3.Enabled = true
      form.fipt_1.Text = nx_widestr("1")
      form.sure_btn.Enabled = true
    else
      form.btn_3.Enabled = false
      form.fipt_1.Text = nx_widestr("0")
      form.sure_btn.Enabled = false
    end
  end
  local type = get_type(form)
  if type == 4 then
    form.lbl_price.Text = util_format_string("ui_buyvip_price", nx_int(get_vip_price(type)), nx_int(3))
  else
    form.lbl_price.Text = util_format_string("ui_buyvip_price", nx_int(get_vip_price(type)), nx_int(1))
  end
  form.lbl_3.Text = util_format_string("{@0:gold}", nx_int(form.fipt_1.Text) * get_vip_price(type))
  form.sure_btn.Enaled = get_gold() >= nx_int(form.fipt_1.Text) * get_vip_price(type)
  on_vip_changed(form)
end
function reset_ctrl_state(form)
  form.btn_3.Enabled = true
  form.fipt_1.Max = 36
  form.fipt_1.Text = nx_widestr("1")
  form.sure_btn.Enabled = true
end
function get_type(form)
  if form.rbtn_1.Checked == true then
    return 1
  elseif form.rbtn_2.Checked == true then
    return 2
  elseif form.rbtn_3.Checked == true then
    return 3
  elseif form.rbtn_4.Checked == true then
    return 4
  end
  return 0
end
function get_gold()
  local glod = 0
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    gold = mgr:GetCapital(CAPITAL_TYPE_GOLDEN)
  end
  return gold
end
function change_switch_41(type, is_open)
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  if not nx_is_valid(form) then
    return false
  end
  if type == ST_FUNCTION_VIP_JINGXIU_1 then
    form.rbtn_2.Visible = is_open
    form.rbtn_3.Visible = is_open
    form.lbl_9.Visible = is_open
    form.lbl_10.Visible = is_open
  end
end
function change_switch_42(type, is_open)
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  if not nx_is_valid(form) then
    return false
  end
  if type == ST_FUNCTION_VIP_JINGXIU_2 then
    form.rbtn_4.Visible = is_open
    form.lbl_11.Visible = is_open
  end
end
