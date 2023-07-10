require("util_functions")
require("util_gui")
require("custom_sender")
local count_down = 60
function main_form_init(self)
  self.Fixed = false
  return 1
end
function show_form(is_show)
  if is_show ~= util_is_lockform_visible("form_stage_main\\form_jiuyang_faculty\\form_jyf_wait") then
    util_auto_show_hide_form_lock("form_stage_main\\form_jiuyang_faculty\\form_jyf_wait")
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  set_allow_control(false)
  self.CD = count_down
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "refresh", self, -1, -1)
  end
end
function on_main_form_close(self)
  set_allow_control(true)
  nx_destroy(self)
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
function refresh(self)
  self.CD = self.CD - 1
  self.lbl_2.Text = nx_widestr(self.CD)
  if self.CD == 0 then
    util_auto_show_hide_form_lock("form_stage_main\\form_jiuyang_faculty\\form_jyf_wait")
  end
end
