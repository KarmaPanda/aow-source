require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\url_define")
require("form_stage_main\\switch\\switch_define")
require("share\\capital_define")
local g_form_name = "form_stage_main\\form_consign\\form_buy_capital"
BCCST_BUY = 2
BCCST_HISTROY = 3
BCCST_SILVER_BUY = 4
BCCST_OPEN_BUY_FORM = 5
BCCST_SILVER_HISTORY = 6
BCCST_REFRESH_SILVER = 7
function on_switch_changed(type, is_open)
  refresh_bag_golden_icon()
end
function refresh_bag_golden_icon()
  local type = get_default_buy_capital_type()
  local bag_icons = {
    [CAPITAL_TYPE_GOLDEN] = {
      icon_on = "gui\\language\\ChineseS\\dh-on.png",
      icon_down = "gui\\language\\ChineseS\\dh-down.png",
      icon_out = "gui\\language\\ChineseS\\dh-out.png",
      tips = "tips_goldexchange"
    },
    [CAPITAL_TYPE_BIND_CARD] = {
      icon_on = "gui\\language\\ChineseS\\yinpiao_on.png",
      icon_down = "gui\\language\\ChineseS\\yinpiao_down.png",
      icon_out = "gui\\language\\ChineseS\\yinpiao_out.png",
      tips = "tips_yinpiaoexchange"
    },
    [CAPITAL_TYPE_SILVER] = {
      icon_on = "gui\\language\\ChineseS\\silver_ex_on.png",
      icon_down = "gui\\language\\ChineseS\\silver_ex_down.png",
      icon_out = "gui\\language\\ChineseS\\silver_ex_out.png",
      tips = "tips_silverexchange"
    }
  }
  local config = bag_icons[type]
  if config == nil then
    return
  end
  local bag_form = nx_value("form_stage_main\\form_bag")
  if not nx_is_valid(bag_form) then
    return
  end
  bag_form.btn_golddh.FocusImage = config.icon_on
  bag_form.btn_golddh.PushImage = config.icon_down
  bag_form.btn_golddh.NormalImage = config.icon_out
  bag_form.btn_golddh.HintText = nx_widestr("@" .. config.tips)
end
function get_default_buy_capital_type()
  local type
  local switchmgr = nx_value("SwitchManager")
  local switchtbl = {
    [1] = {switch = ST_FUNCTION_POINT_TO_SILVERCARD, type = CAPITAL_TYPE_GOLDEN},
    [2] = {switch = ST_FUNCTION_POINT_TO_BINDCARD, type = CAPITAL_TYPE_BIND_CARD},
    [3] = {switch = ST_FUNCTION_SILVER_TO_SILVERCARD, type = CAPITAL_TYPE_SILVER}
  }
  if nx_is_valid(switchmgr) then
    local cnt = table.getn(switchtbl)
    for i = 1, cnt do
      if switchmgr:CheckSwitchEnable(switchtbl[i].switch) then
        type = switchtbl[i].type
        break
      end
    end
  end
  if type == nil then
    type = 0
  end
  return type
end
function show_hide_buy_capital_form(type)
  if type == nil then
    type = get_default_buy_capital_type()
  end
  local form_name = "form_stage_main\\form_consign\\form_buy_capital_point"
  local form = nx_value(form_name)
  if nx_is_valid(form) and form.Visible then
    nx_destroy(form)
    return
  end
  form_name = "form_stage_main\\form_consign\\form_buy_capital_silver"
  form = nx_value(form_name)
  if nx_is_valid(form) and form.Visible then
    nx_destroy(form)
    return
  end
  form_name = "form_stage_main\\form_consign\\form_buy_capital_bind"
  form = nx_value(form_name)
  if nx_is_valid(form) and form.Visible then
    nx_destroy(form)
    return
  end
  send_server(BCCST_OPEN_BUY_FORM, type)
end
function send_server(...)
  nx_execute("custom_sender", "custom_buy_capital", unpack(arg))
end
function on_server_msg(...)
  if table.getn(arg) < 1 then
    return
  end
  local msgid = nx_number(arg[1])
  if msgid == BCCST_HISTROY then
    nx_execute("form_stage_main\\form_consign\\form_buy_capital_point", "on_server_msg", unpack(arg))
    return
  elseif msgid == BCCST_SILVER_HISTORY then
    nx_execute("form_stage_main\\form_consign\\form_buy_capital_silver", "on_server_msg", unpack(arg))
    return
  elseif msgid == BCCST_REFRESH_SILVER then
    local cur_buy_value = nx_number(arg[2])
    local max_buy_value = nx_number(arg[3])
    local form_name = "form_stage_main\\form_consign\\form_buy_capital_silver"
    local form = nx_value(form_name)
    if not nx_is_valid(form) then
      return
    end
    nx_set_custom(form, "max_buy_value", max_buy_value)
    nx_set_custom(form, "can_buy_value", cur_buy_value)
    nx_execute(form_name, "on_fresh_max_buy_value", form)
  elseif msgid == BCCST_OPEN_BUY_FORM then
    local type = arg[2]
    if type == nil then
      return
    end
    local cur_buy_value = nx_number(arg[3])
    local max_buy_value = nx_number(arg[4])
    local buy_price = nx_number(arg[5])
    local switch = nx_number(arg[6])
    if switch == 0 then
      sysinfo("10011")
      return
    end
    local form = nx_null()
    local form_name
    if type == "point" then
      form_name = "form_stage_main\\form_consign\\form_buy_capital_point"
    elseif type == "silver" then
      form_name = "form_stage_main\\form_consign\\form_buy_capital_silver"
    elseif type == "bind" then
      form_name = "form_stage_main\\form_consign\\form_buy_capital_bind"
    end
    if form_name == nil then
      return
    end
    form = util_show_form(form_name, true)
    if not nx_is_valid(form) then
      return
    end
    nx_set_custom(form, "max_buy_value", max_buy_value)
    nx_set_custom(form, "buy_price", buy_price)
    nx_set_custom(form, "can_buy_value", cur_buy_value)
    nx_execute(form_name, "on_fresh_max_buy_value", form)
  end
end
function sysinfo(strid, ...)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_format_string(strid, unpack(arg)), 2)
  end
end
