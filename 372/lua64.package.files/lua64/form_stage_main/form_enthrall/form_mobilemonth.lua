require("util_functions")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\switch\\url_define")
function on_main_form_init(self)
  self.Fixed = true
  self.Visible = false
  return 1
end
function on_main_form_open(self)
  self.mltbox_1.Visible = false
  self.mltbox_2.Visible = false
  self.btn_bind.Visible = false
  self.mltbox_3.Visible = false
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_mobile_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local text = nx_string(form.ipt_mobile.Text)
  local count = string.len(text)
  if nx_int(count) ~= nx_int(11) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_number_failed")
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOBILE_COMFIRM), 2, nx_widestr(form.ipt_mobile.Text), nx_widestr(""), nx_widestr(1))
  btn.Enabled = false
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(10000, -1, nx_current(), "on_update_time", form, -1, -1)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_confirm_click(btn)
  local mgr = nx_value("UnenthrallModule")
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local text = nx_string(form.ipt_mobile.Text)
  local count = string.len(text)
  if nx_int(count) == nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "sys_mobilemonth_007")
    return 0
  elseif nx_int(count) ~= nx_int(11) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_number_failed")
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOBILE_COMFIRM), 2, nx_widestr(form.ipt_mobile.Text), nx_widestr(form.ipt_confirm.Text), nx_widestr(2))
end
function on_server_msg(...)
  local flag = arg[1]
  local aid = nx_widestr(arg[2])
  local mobile = nx_widestr(arg[3])
  local authentic = nx_widestr(arg[4])
  local type = nx_widestr(arg[5])
  if flag == 2 then
    util_show_form("form_stage_main\\form_enthrall\\form_mobilemonth", true)
    return
  end
  local form = nx_value("form_stage_main\\form_enthrall\\form_mobilemonth")
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("UnenthrallModule")
    nx_set_value("UnenthrallModule", mgr)
  end
  local ret_tab = mgr:MobileCofirmMonth(aid, type, mobile, authentic)
  local ret = ret_tab[1]
  if nx_int(ret) == nx_int(1) then
    form.mltbox_1.Visible = true
    form.btn_bind.Visible = false
    form.mltbox_3.Visible = false
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    if nx_int(type) == nx_int(2) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOBILE_COMFIRM), 3)
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_authentic_success")
    elseif nx_int(type) == nx_int(1) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOBILE_COMFIRM), 5)
    end
  elseif nx_int(ret) == nx_int(13110) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobilemonth_002")
    form.btn_bind.Visible = true
    form.mltbox_3.Visible = true
    form.mltbox_1.Visible = false
  elseif nx_int(ret) == nx_int(54069) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_authentic_failed")
    form.mltbox_2.Visible = true
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_authentic_failed")
    form.mltbox_2.Visible = true
  end
end
function on_update_time(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  form.btn_mobile.Enabled = true
end
function on_btn_bind_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(nx_int(URL_TYPE_OPEN_BINDMOBILE_URL))
end
