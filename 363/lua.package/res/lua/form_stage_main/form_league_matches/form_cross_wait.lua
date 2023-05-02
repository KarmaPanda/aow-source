require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_league_matches\\form_cross_wait"
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  set_allow_control(false)
  self.wait_sec = 0
  self.time = 0
  self.cross_type = 0
  self.cross_server_type = 0
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_time_refresh", self)
    timer:Register(1000, -1, nx_current(), "on_time_refresh", self, -1, -1)
  end
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_time_refresh", self)
  end
  set_allow_control(true)
  nx_destroy(self)
end
function open_form(wait_sec, cross_type, cross_server_type)
  wait_sec = nx_number(wait_sec) + 30
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
    form.wait_sec = nx_number(wait_sec)
    form.cross_type = nx_number(cross_type)
    form.cross_server_type = nx_number(cross_server_type)
    set_sec(form, nx_number(wait_sec))
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function ok_btn_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_cross_server", 3, form.cross_type, form.cross_server_type)
  close_form()
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
  if form.time <= 0 then
    close_form()
    return
  end
  set_sec(form, form.time - 1)
end
function set_sec(form, sec)
  form.lbl_time.Text = nx_widestr(sec)
  form.time = sec
end
