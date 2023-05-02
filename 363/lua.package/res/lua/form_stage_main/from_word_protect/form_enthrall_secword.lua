require("util_functions")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\switch\\url_define")
function on_main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.step = 1
  set_step(self, 1)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if form.step == 1 then
    local text = nx_string(form.ipt_mobile.Text)
    local count = string.len(text)
    if nx_int(count) ~= nx_int(11) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_mobile_number_failed")
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), 7, nx_widestr(form.ipt_mobile.Text))
  elseif form.step == 2 then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), 8, nx_string(form.ipt_mobile.Text), nx_string(form.ipt_code.Text))
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(...)
  local aid = nx_widestr(arg[2])
  local mobile = nx_widestr(arg[3])
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("UnenthrallModule")
    nx_set_value("UnenthrallModule", mgr)
  end
  local ret_tab = mgr:ResetSecondWord(aid, mobile)
  local ret = ret_tab[1]
  if nx_int(ret) == nx_int(1) then
    local form = nx_value("form_stage_main\\from_word_protect\\form_enthrall_secword")
    if not nx_is_valid(form) then
      return
    end
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_send_mobile_code_success")
    set_step(form, 2)
  elseif nx_int(ret) == nx_int(13110) then
    local switch_manager = nx_value("SwitchManager")
    if nx_is_valid(switch_manager) then
      switch_manager:OpenUrl(URL_TYPE_9YIN_BIND_PHONE)
      return
    end
  elseif nx_int(ret) == nx_int(13111) then
    local form = nx_value("form_stage_main\\from_word_protect\\form_enthrall_secword")
    if not nx_is_valid(form) then
      util_show_form("form_stage_main\\from_word_protect\\form_enthrall_secword", true)
      return
    else
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_not_same_mobile")
    end
  elseif nx_int(ret) == nx_int(13112) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_same_mobile_quick")
  elseif nx_int(ret) == nx_int(13104) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_not_exsit_account")
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_quest_mobile_code_failed")
  end
end
function set_step(form, step)
  if nx_int(step) == nx_int(1) then
    form.lbl_mobile.Visible = true
    form.ipt_mobile.Visible = true
    form.mltbox_mobile.Visible = true
    form.lbl_code.Visible = false
    form.ipt_code.Visible = false
    form.mltbox_code.Visible = false
    form.step = 1
  elseif nx_int(step) == nx_int(2) then
    form.lbl_mobile.Visible = false
    form.ipt_mobile.Visible = false
    form.mltbox_mobile.Visible = false
    form.lbl_code.Visible = true
    form.ipt_code.Visible = true
    form.mltbox_code.Visible = true
    form.step = 2
  end
end
