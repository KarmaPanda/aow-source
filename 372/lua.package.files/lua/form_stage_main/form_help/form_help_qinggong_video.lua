require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_help\\form_help_qinggong_video"
function close_form()
  if util_is_lockform_visible(FORM_NAME) then
    util_auto_show_hide_form_lock(FORM_NAME)
  end
end
function main_form_init(self)
  self.Fixed = true
  return
end
function on_main_form_open(self)
  refresh_form_pos(self)
  set_allow_control(false)
  nx_execute("gui", "gui_close_allsystem_form")
  self.video_1.Loop = true
  self.video_1.AutoPlay = false
  self.video_1.Video = "video\\move_qg_show.flv"
  self.video_1:Play()
end
function on_delay_play(self)
  if not nx_is_valid(self) then
    return
  end
  self.video_1:Play()
end
function on_main_form_close(self)
  set_allow_control(true)
  nx_execute("gui", "gui_open_closedsystem_form")
  nx_destroy(self)
end
function ok_btn_click(btn)
  btn.ParentForm:Close()
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
function refresh_form_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_back.AbsLeft = 0
  form.groupbox_back.AbsTop = 0
  form.groupbox_back.Width = gui.Width
  form.groupbox_back.Height = gui.Height
  form.video_1.AbsLeft = form.Width / 2 - form.video_1.Width / 2
  form.video_1.AbsTop = form.Height / 2 - form.video_1.Height / 2
  form.btn_1.AbsTop = form.video_1.AbsTop - form.btn_1.Height / 2
  form.btn_1.AbsLeft = form.video_1.AbsLeft + form.video_1.Width + 20
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  refresh_form_pos(form)
end
