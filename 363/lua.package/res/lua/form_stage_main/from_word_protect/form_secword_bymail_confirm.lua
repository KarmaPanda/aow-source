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
  return 1
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  nx_destroy(form)
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), 13, nx_string(form.ipt_code.Text))
  form.time_limit = 0
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(...)
  local type = nx_int(arg[2])
  if nx_int(type) == nx_int(2) then
    local form = nx_value("form_stage_main\\from_word_protect\\form_secword_bymail_confirm")
    if not nx_is_valid(form) then
      return
    end
    form:Close()
    return
  end
  local ret = nx_int(arg[3])
  if nx_int(ret) == nx_int(1) then
    util_show_form("form_stage_main\\from_word_protect\\form_secword_bymail_confirm", true)
    local form = nx_value("form_stage_main\\from_word_protect\\form_secword_bymail_request")
    if nx_is_valid(form) then
      form:Close()
    end
  else
    local form = nx_value("form_stage_main\\from_word_protect\\form_secword_bymail_request")
    if nx_is_valid(form) then
      form.mltbox_code.HtmlText = util_text("mail_back_08")
      form.btn_ok.Visible = false
    end
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "30074")
  end
end
function on_update_time(form)
  form.time_limit = form.time_limit - 1
  form.lbl_timelimit.Text = nx_widestr(form.time_limit)
  if form.time_limit > 0 then
    form.lbl_timelimit.Visible = true
    form.btn_ok.Enabled = false
  else
    form.lbl_timelimit.Visible = false
    form.btn_ok.Enabled = true
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
end
