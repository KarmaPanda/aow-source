require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function on_main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.mltbox_1.Visible = false
  self.mltbox_2.Visible = false
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
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOBILE_COMFIRM), 0, nx_widestr(form.ipt_mobile.Text), nx_widestr(""), nx_widestr(1))
  form.mltbox_1.Visible = true
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
  if nx_int(count) ~= nx_int(11) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_number_failed")
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOBILE_COMFIRM), 0, nx_widestr(form.ipt_mobile.Text), nx_widestr(form.ipt_confirm.Text), nx_widestr(2))
  form.mltbox_2.Visible = true
end
function on_server_msg(...)
  local flag = arg[1]
  local aid = nx_widestr(arg[2])
  local mobile = nx_widestr(arg[3])
  local authentic = nx_widestr(arg[4])
  local type = nx_widestr(arg[5])
  if flag == 2 then
    util_show_form("form_stage_main\\form_enthrall\\form_mobilecode", true)
    return
  end
  local form = nx_value("form_stage_main\\form_enthrall\\form_mobilecode")
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("UnenthrallModule")
    nx_set_value("UnenthrallModule", mgr)
  end
  local ret_tab = mgr:MobileCofirm(aid, type, mobile, authentic)
  local ret = ret_tab[1]
  if nx_int(ret) == nx_int(1) then
    if nx_int(type) == nx_int(2) then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return 0
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOBILE_COMFIRM), 1)
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_authentic_success")
      form:Close()
    end
  elseif nx_int(ret) == nx_int(54067) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_have_mobile_authentic")
    form:Close()
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_authentic_failed")
  end
end
function on_update_time(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  form.btn_mobile.Enabled = true
end
