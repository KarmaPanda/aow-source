require("util_functions")
require("util_gui")
require("custom_sender")
local COUNTDOWN = 90
local CS_REQUEST_CANCEL_ENTERWAR = 4
function main_form_init(self)
  self.Fixed = false
  self.time = COUNTDOWN
  return 1
end
function close_form()
  if util_is_lockform_visible("form_stage_main\\form_new_war_rule\\form_new_war_rule_wait") then
    util_auto_show_hide_form_lock("form_stage_main\\form_new_war_rule\\form_new_war_rule_wait")
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  set_allow_control(false)
  on_time_refresh(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_time_refresh", self)
    timer:Register(1000, -1, nx_current(), "on_time_refresh", self, -1, -1)
  end
end
function on_main_form_close(self)
  set_allow_control(true)
  nx_destroy(self)
end
function ok_btn_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "send_server_msg", nx_int(CS_REQUEST_CANCEL_ENTERWAR))
end
function set_allow_control(allow)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.AllowControl = allow
end
function on_time_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  if form.time < 0 then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_time_refresh", form)
    end
    nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "send_server_msg", nx_int(CS_REQUEST_CANCEL_ENTERWAR))
    return
  end
  local gui = nx_value("gui")
  form.lbl_time.Text = nx_widestr(form.time)
  form.time = form.time - 1
end
