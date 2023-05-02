require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\form_taosha\\apex_util")
local FORM = "form_stage_main\\form_taosha\\form_apex_match"
local CLIENT_CUSTOMMSG_LUAN_DOU = 902
local ST_FUNCTION_APEX = 890
local CTS_SUB_APEX_MSG_GO = 0
local CTS_SUB_APEX_MSG_CANCEL_APPLY = 3
local apex_apply = 1
local apex_invite = 2
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2 + (gui.Width - self.Width) / 4
    self.AbsTop = (gui.Height - self.Height) / 2 + (gui.Height - self.Height) / 4
  end
  self.apex_state = 0
  self.left_time = 0
  self.btn_goto.Visible = false
  self.btn_cancel.Visible = true
  self.lbl_match_wait.Visible = true
  self.lbl_match_finish.Visible = false
  time_format(self)
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_apply_time", self)
    game_timer:Register(1000, -1, nx_current(), "update_apply_time", self, -1, -1)
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_apply_time", self)
  end
  nx_destroy(self)
end
function on_btn_goto_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_apex", nx_int(CTS_SUB_APEX_MSG_GO))
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_apex", nx_int(CTS_SUB_APEX_MSG_CANCEL_APPLY))
  form:Close()
end
function on_apex_apply_success(...)
  util_show_form(FORM, true)
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    return
  end
  form.apex_state = apex_apply
end
function on_apex_invite(...)
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    util_show_form(FORM, true)
  end
  form.apex_state = apex_invite
  form.left_time = 60
  form.btn_goto.Visible = true
  form.btn_cancel.Visible = false
  form.lbl_match_wait.Visible = false
  form.lbl_match_finish.Visible = true
end
function on_apex_apply_cancel(...)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function update_apply_time(form)
  if not nx_is_valid(form) then
    return
  end
  time_format(form)
  if form.apex_state == apex_invite then
    form.left_time = form.left_time - 1
  else
    form.left_time = form.left_time + 1
  end
  if form.apex_state == apex_invite and form.left_time < 0 then
    form:Close()
  end
end
function time_format(form)
  local now_time = form.left_time
  local minute = nx_int(now_time / 60)
  local second = now_time - minute * 60
  local str = nx_string(minute) .. ":" .. nx_string(second)
  form.lbl_time_text.Text = nx_widestr(str)
end
function close_form()
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    form:Close()
  end
end
