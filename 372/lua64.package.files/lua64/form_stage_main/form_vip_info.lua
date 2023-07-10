require("util_gui")
require("util_functions")
require("util_vip")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("form_stage_main\\switch\\url_define")
require("form_stage_main\\switch\\switch_define")
local g_form_name = "form_stage_main\\form_vip_info"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local mgr = nx_value("VipModule")
  if nx_is_valid(mgr) then
    local count = mgr.VipProfCount
    if count < 1 then
      mgr:LoadRes()
    end
  end
end
function on_vip_prize_switch_changed(switch_type, switch_status)
  local form = nx_value(g_form_name)
  if nx_is_valid(form) and form.Visible then
    local mgr = nx_value("SwitchManager")
    if not nx_is_valid(mgr) then
      form.btn_reward.Visible = false
    end
    form.btn_reward.Visible = mgr:CheckSwitchEnable(ST_FUNCTION_VIP_PRIZE)
  end
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  databinder:AddTableBind("vip_info_rec", form, g_form_name, "on_vip_info_rec_change")
  init_vip_prof(form.textgrid_1)
  set_vip_time(form)
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return
  end
  vip_info_change_switch_41(ST_FUNCTION_VIP_JINGXIU_1, mgr:CheckSwitchEnable(ST_FUNCTION_VIP_JINGXIU_1))
  form.btn_reward.Visible = mgr:CheckSwitchEnable(ST_FUNCTION_VIP_PRIZE)
end
function init_vip_prof(grid)
  grid:SetColTitle(0, util_format_string("title_vipinfo_01"))
  grid:SetColTitle(1, util_format_string("title_vipinfo_02"))
  grid:SetColTitle(2, util_format_string("title_vipinfo_03"))
  grid:SetColTitle(3, util_format_string("title_vipinfo_04"))
  local mgr = nx_value("VipModule")
  if not nx_is_valid(mgr) then
    return
  end
  local count = mgr.VipProfCount
  grid.RowCount = count
  for i = 1, count do
    local index = i - 1
    local info = mgr:GetVipProf(index)
    if info ~= nil and table.getn(info) == 5 then
      for j = 1, 5 do
        grid:SetGridText(index, j - 1, util_format_string(info[j]))
      end
    end
  end
end
function on_vip_info_rec_change(self, recordname, optype, row, clomn)
  if clomn == VIR_STATUS or clomn == VIR_VALID_TIME then
    on_vip_change(self)
  end
end
function on_vip_change(form)
  nx_execute(g_form_name, "set_vip_time", form)
end
function set_vip_time(form)
  local vipmodule = nx_value("VipModule")
  if not nx_is_valid(vipmodule) then
    return
  end
  local all_vip_time = 0
  local info = vipmodule:QueryVipInfo(VT_NORMAL, VIR_TOTAL_TIME)
  if table.getn(info) >= 1 then
    all_vip_time = info[1]
  end
  local stage_main_flag = nx_value("stage_main")
  if stage_main_flag ~= "success" then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_alltime.HtmlText = util_format_string("ui_vip_alltime", all_vip_time)
  form.mltbox_time:Clear()
  form.mltbox_time.Visible = true
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not is_vip(player, VT_NORMAL) then
    form.mltbox_time:Clear()
    form.mltbox_time.TextColor = "255,255,0,0"
    form.mltbox_time:AddHtmlText(util_format_string("ui_jhhy_3"), nx_int(-1))
  else
    form.mltbox_time:Clear()
    form.mltbox_time.TextColor = "255,0,255,0"
    local time = nx_number(get_vip_time(player, VT_NORMAL))
    form.mltbox_time:AddHtmlText(util_format_string("ui_sns_timelimit") .. format_time_form(time), nx_int(-1))
  end
end
function on_main_form_close(form)
  local binder = nx_value("data_binder")
  if nx_is_valid(binder) then
    binder:DelTableBind("vip_info_rec", form)
  end
  nx_destroy(form)
end
function on_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function open_vip_form_login(flag)
  util_auto_show_hide_form_lock(g_form_name)
  local form = nx_value(g_form_name)
  if nx_is_valid(form) and form.Visible then
    form.btn_1.Visible = false
    form.mltbox_time.Visible = true
    form.btn_reward.Visible = false
  end
end
function on_point_buy_click(btn)
  pay_by_golden()
end
function on_web_buy_click(btn)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function pay_by_golden()
  local confirm_path = "form_stage_main\\form_buyvip_confirm"
  local form = nx_value(confirm_path)
  local bShow = true
  if nx_is_valid(form) and form.Visible then
    bShow = false
  end
  if bShow then
    send_vip_msg(G_CMD_GET_VIPPRICE, nx_int(-1))
  else
    util_show_form("form_stage_main\\form_buyvip_confirm", false)
  end
end
function on_drag_vscroll(vs)
end
function format_time(time)
  local str = "{@0:s}{@1:y}{@2:y}{@3:m}{@4:m}{@5:d}{@6:d}{@7:h}{@8:h}{@9:min}{@10:min}"
  local t = os.date("*t", time)
  if t == nil then
    return nx_widestr("")
  end
  return util_format_string(str, "ui_jhhy_2", t.year, "ui_g_year", t.month, "ui_g_month", t.day, "ui_g_day", t.hour, "ui_g_hour", t.min, "ui_g_minute")
end
function format_time_form(time)
  local str = "{@0:y}{@1:y}{@2:m}{@3:m}{@4:d}{@5:d}{@6:h}{@7:h}{@8:min}{@9:min}"
  local t = os.date("*t", time)
  if t == nil then
    return nx_widestr("")
  end
  return util_format_string(str, t.year, "ui_g_year", t.month, "ui_g_month", t.day, "ui_g_day", t.hour, "ui_g_hour", t.min, "ui_g_minute")
end
function on_btn_zhizunvip_click(btn)
  local form = btn.Parent
  if form.lbl_back.Visible == true then
    form.lbl_back.Visible = false
  end
  local form_zhizunvip_info = nx_value("form_stage_main\\form_zhizunvip\\form_zhizunvip_info")
  if nx_is_valid(form_zhizunvip_info) then
    util_show_form("form_stage_main\\form_zhizunvip\\form_zhizunvip_info", false)
  else
    util_show_form("form_stage_main\\form_zhizunvip\\form_zhizunvip_info", true)
  end
end
function vip_info_change_switch_41(type, is_open)
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  if not nx_is_valid(form) then
    return false
  end
  if type == ST_FUNCTION_VIP_JINGXIU_1 then
    form.lbl_back.Visible = is_open
    form.btn_zhizunvip.Visible = is_open
  end
end
function on_btn_reward_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_zhizunvip\\form_vip_reward")
end
function on_mouse_in_reward(btn)
  local x = btn.AbsLeft + btn.Width / 2
  local y = btn.AbsTop - btn.Height
  nx_execute("tips_game", "show_text_tip", util_format_string("tips_vip_reward01"), x, y)
end
function on_mouse_out_reward(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_check_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_origin\\form_origin")
end
