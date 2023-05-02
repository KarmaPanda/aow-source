require("util_gui")
require("util_functions")
local FORM_BUY = "form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_buy"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.cost_flag = nx_int(2000000)
  form.cost_camp = nx_int(2000000)
  refresh_price(form)
  nx_execute("custom_sender", "custom_corss_station_war", 10)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form()
  util_show_form(FORM_BUY, true)
end
function close_form()
  local form = nx_value(FORM_BUY)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_buy_flag_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local flag = nx_number(form.ipt_flag.Text)
  local camp = 0
  if flag < 0 or 1 < flag or camp < 0 then
    return
  end
  local info = nx_widestr("")
  if 0 < flag then
    local cost = get_captial_text(1 * form.cost_flag)
    info = info .. util_format_string("ui_golbal_war_shp_009", 1, cost)
  end
  if 0 < camp then
    local cost = get_captial_text(camp * form.cost_camp)
    info = info .. util_format_string("ui_golbal_war_shp_010", camp, cost)
  end
  local res = util_form_confirm("", info)
  if res == "ok" then
    if 0 < flag then
      nx_execute("custom_sender", "custom_corss_station_war", 8, flag)
    end
    if 0 < camp then
      nx_execute("custom_sender", "custom_corss_station_war", 9, camp)
    end
  end
end
function on_btn_buy_camp_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local flag = 0
  local camp = nx_number(form.ipt_camp.Text)
  if flag < 0 or 1 < flag or camp < 0 then
    return
  end
  local info = nx_widestr("")
  if 0 < flag then
    local cost = get_captial_text(1 * form.cost_flag)
    info = info .. util_format_string("ui_golbal_war_shp_009", 1, cost)
  end
  if 0 < camp then
    local cost = get_captial_text(camp * form.cost_camp)
    info = info .. util_format_string("ui_golbal_war_shp_010", camp, cost)
  end
  local res = util_form_confirm("", info)
  if res == "ok" then
    if 0 < flag then
      nx_execute("custom_sender", "custom_corss_station_war", 8, flag)
    end
    if 0 < camp then
      nx_execute("custom_sender", "custom_corss_station_war", 9, camp)
    end
  end
end
function update_flag_nums(flag_nums, camp_nums)
  local form = util_get_form(FORM_BUY, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_flag_buy.Text = nx_widestr(flag_nums)
  form.lbl_camp_num.Text = nx_widestr(camp_nums)
  refresh_price(form)
end
function refresh_price(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\StationCrossWar\\StationCrossWar.ini")
  if not nx_is_valid(ini) then
    return
  end
  local str_cost_flag = ini:ReadString("property", "flag_price", "")
  local cost_camp = nx_int(ini:ReadInteger("property", "relive_price", 0))
  local tab_cost_flag = util_split_string(str_cost_flag, ",")
  local flag_nums = nx_number(form.lbl_flag_buy.Text)
  if flag_nums + 1 > #tab_cost_flag then
    cost_flag = tab_cost_flag[#tab_cost_flag]
  else
    cost_flag = tab_cost_flag[flag_nums + 1]
  end
  form.cost_flag = nx_number(cost_flag)
  form.cost_camp = nx_number(cost_camp)
  form.lbl_flag_cost.Text = nx_widestr(get_captial_text(form.cost_flag))
  form.lbl_camp_cost.Text = nx_widestr(get_captial_text(form.cost_camp))
end
function get_captial_text(capital_num)
  local gui = nx_value("gui")
  local capital = nx_number(capital_num)
  local ding = math.floor(capital / 1000000)
  local liang = math.floor(capital % 1000000 / 1000)
  local wen = math.floor(capital % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = nx_widestr(nx_int(ding)) .. nx_widestr(gui.TextManager:GetText("ui_ding"))
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(text)
  end
  if 0 < liang then
    local text = nx_widestr(nx_int(liang)) .. nx_widestr(gui.TextManager:GetText("ui_liang"))
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(text)
  end
  if 0 < wen then
    local text = nx_widestr(nx_int(wen)) .. nx_widestr(gui.TextManager:GetText("ui_wen"))
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(text)
  end
  if capital == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(text)
  end
  return htmlTextYinZi
end
function a(info)
  nx_msgbox(nx_string(info))
end
