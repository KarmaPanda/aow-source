require("util_gui")
require("util_functions")
local FORM_BUY = "form_stage_main\\form_guild_global_war\\form_guild_global_war_buy"
local CLIENT_MSG_GGW_BUY_FLAG = 1
local CLIENT_MSG_GGW_BUY_CAMP = 2
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
  local flag = nx_int(form.ipt_flag.Text)
  local camp = nx_int(0)
  local info = nx_widestr("")
  if flag > nx_int(0) then
    local cost = get_captial_text(flag * form.cost_flag)
    info = info .. util_format_string("ui_golbal_war_shp_009", flag, cost)
  end
  if camp > nx_int(0) then
    local cost = get_captial_text(camp * form.cost_camp)
    info = info .. util_format_string("ui_golbal_war_shp_010", camp, cost)
  end
  local res = util_form_confirm("", info)
  if res == "ok" then
    if flag > nx_int(0) then
      nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_BUY_FLAG, flag)
    end
    if camp > nx_int(0) then
      nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_BUY_CAMP, camp)
    end
    close_form()
  end
end
function on_btn_buy_camp_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local flag = nx_int(0)
  local camp = nx_int(form.ipt_camp.Text)
  local info = nx_widestr("")
  if flag > nx_int(0) then
    local cost = get_captial_text(flag * form.cost_flag)
    info = info .. util_format_string("ui_golbal_war_shp_009", flag, cost)
  end
  if camp > nx_int(0) then
    local cost = get_captial_text(camp * form.cost_camp)
    info = info .. util_format_string("ui_golbal_war_shp_010", camp, cost)
  end
  local res = util_form_confirm("", info)
  if res == "ok" then
    if flag > nx_int(0) then
      nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_BUY_FLAG, flag)
    end
    if camp > nx_int(0) then
      nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_BUY_CAMP, camp)
    end
    close_form()
  end
end
function refresh_price(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildGlobalWar\\guild_global_war.ini")
  local str_cost_flag = ini:ReadString("rule", "flag_cost", "")
  local cost_camp = nx_int(ini:ReadInteger("rule", "camp_cost", 0))
  local tab_cost_flag = util_split_string(str_cost_flag, ",")
  local tab_flag_nums = util_split_wstring(form.lbl_flag_buy.Text, "/")
  if #tab_flag_nums < 2 then
    return
  end
  local flag_nums = nx_number(tab_flag_nums[2])
  local cost_flag = 0
  if flag_nums > #tab_cost_flag then
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
