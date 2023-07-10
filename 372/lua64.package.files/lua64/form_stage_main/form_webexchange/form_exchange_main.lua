require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\switch\\url_define")
require("form_stage_main\\form_webexchange\\webexchange_define")
local g_form_name = "form_stage_main\\form_webexchange\\form_exchange_main"
function open_form()
  open_close_webexchange()
end
function open_close_webexchange(type)
  local form = nx_value(g_form_name)
  if nx_is_valid(form) and form.Visible then
    util_show_form(g_form_name, false)
    sendserver_msg(G_FLAG_CLOSE)
  else
    sendserver_msg(G_FLAG_OPEN)
  end
end
function on_role_switch_changed(type, isopen)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  form.rb_role.Visible = isopen
  if form.rb_role.Checked then
    form.rb_item.Checked = true
  end
end
function close_webexchange(form)
  sendserver_msg(G_FLAG_CLOSE)
end
function test_webexchange_switch()
  local market_form = nx_value("form_stage_main\\form_market\\form_market")
  if nx_is_valid(market_form) then
    local mgr = nx_value("SwitchManager")
    if not nx_is_valid(mgr) then
      return
    end
    local flag = mgr:CheckSwitchEnable(ST_FUNCTION_WEBEXCHANGE)
    market_form.btn_webexchange.Visible = flag
    market_form.btn_webexchange.Enabled = flag
  end
end
function on_query_webexchange_switch(type, flag)
  local market_form = nx_value("form_stage_main\\form_market\\form_market")
  if nx_is_valid(market_form) then
    market_form.btn_webexchange.Visible = flag
    market_form.btn_webexchange.Enabled = flag
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.btn_webexchange.Visible = flag
    form_bag.btn_webexchange.Enabled = flag
  end
end
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  local control = util_get_form("form_stage_main\\form_webexchange\\form_item", true, false)
  form.gb_item:Add(control)
  control.Left, control.Top, control.Width, control.Height = 0, 0, form.gb_item.Width, form.gb_item.Height
  control.Fixed = true
  local control = util_get_form("form_stage_main\\form_webexchange\\form_role", true, false)
  form.gb_role:Add(control)
  control.Left, control.Top, control.Width, control.Height = 0, 0, form.gb_role.Width, form.gb_role.Height
  control.Fixed = true
  form.rb_item.Checked = true
  local mgr = nx_value("SwitchManager")
  if nx_is_valid(mgr) then
    local flag = mgr:CheckSwitchEnable(ST_FUNCTION_EXCHANGE_ROLE)
    form.rb_role.Visible = flag
  end
end
function on_main_form_active(self)
  if self.rb_web.Checked then
    self.WebView_exchange:Enable()
  else
    self.WebView_exchange:Disable()
  end
end
function on_main_form_unactive(self)
  self.WebView_exchange:Disable()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
  sendserver_msg(G_FLAG_CLOSE)
end
function on_select_func(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.WebView_exchange.Visible = false
    form.gb_item.Visible = false
    form.gb_role.Visible = false
    local name = rbtn.Name
    if name == "rb_web" then
      show_web(form)
    elseif name == "rb_item" then
      form.gb_item.Visible = true
    elseif name == "rb_role" then
      form.gb_role.Visible = true
    end
  end
end
function show_web(form)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_log("open webexchange url error: no game_config")
    return
  end
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    nx_log("open webexchange url error: no SwitchManager")
    return
  end
  local url = SwitchManager:GetUrl(URL_TYPE_WEBEXCHANGE)
  if string.len(url) == 0 then
    nx_log("open webexchange url error: no URL_TYPE_WEBEXCHANGE")
    return
  end
  nx_log("open webexchange url")
  url = url .. "&serverId=" .. nx_string(game_config.server_id)
  local web = form.WebView_exchange
  web.Visible = true
  web.Url = nx_widestr(url)
  if not nx_find_custom(web, "first_open") then
    nx_set_custom(web, "first_open", true)
    web:Refresh()
  else
    web:Navigate()
  end
  local gui = nx_value("gui")
  if form.rb_web.Checked then
    gui.Desktop:ToFront(form)
  end
end
function on_main_form_move(form)
end
