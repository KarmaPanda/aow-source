require("util_gui")
require("util_functions")
require("share\\view_define")
local SUB_CLIENT_PLAY_SUCCESS = 1
local SUB_CLIENT_PLAY_FAILED = 2
local SUB_CLIENT_EXIT_DANCE = 10
local SUB_SERVER_DANCE_WAIT = 1
local SUB_SERVER_DANCE_READY = 2
local SUB_SERVER_DANCE_OVER = 3
local SUB_SERVER_DANCE_END = 4
local SUB_SERVER_PLAYER_OPEN = 10
local SUB_SERVER_RESULT_SUCCESS = 11
local SUB_SERVER_RESULT_FAILED = 12
local FORM_FACULTY_TEAM = "form_stage_main\\form_school_dance\\form_school_dance_member"
local FORM_DANCE = "form_stage_main\\form_school_dance\\form_school_dance_key"
function on_msg(sub_cmd, ...)
  if sub_cmd == nil then
    return
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_DANCE_WAIT) then
    util_show_form(FORM_FACULTY_TEAM, true)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_DANCE_READY) then
    local form_shcool = util_get_form(FORM_FACULTY_TEAM, true)
    nx_execute(FORM_FACULTY_TEAM, "hide_head_info", form_shcool)
    create_begin_animation()
    local scene = nx_value("game_scene")
    local game_control = scene.game_control
    if nx_is_valid(game_control) then
      game_control:CameraStopYawRotate()
    end
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_RESULT_SUCCESS) then
    if arg[1] == nil then
      return
    end
    local form_school = util_get_form(FORM_FACULTY_TEAM, true)
    form_school.groupbox_score.Visible = true
    form_school.lbl_queue.Visible = true
    form_school.lbl_queue.Text = nx_widestr(arg[1])
    create_animation("train_team_success")
    util_show_form(FORM_DANCE, false)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_RESULT_FAILED) then
    local form_school = util_get_form(FORM_FACULTY_TEAM, true)
    form_school.groupbox_score.Visible = true
    form_school.lbl_queue.Text = nx_widestr(0)
    create_animation("train_team_failure")
    util_show_form(FORM_DANCE, false)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAYER_OPEN) then
    local time = nx_execute(FORM_FACULTY_TEAM, "get_inisec", "ActionTime")
    local form_school = util_get_form(FORM_FACULTY_TEAM, true)
    nx_execute(FORM_FACULTY_TEAM, "begin_show_time", form_school, nx_int(time))
    util_show_form(FORM_DANCE, true)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_DANCE_OVER) then
    util_show_form(FORM_FACULTY_TEAM, false)
    util_show_form(FORM_DANCE, false)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_DANCE_END) then
    create_end_animation()
  end
end
function hide_form()
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local text = nx_widestr(util_text("ui_school_dance_quit"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_to_shool_dance", SUB_CLIENT_EXIT_DANCE)
  elseif res == "cancel" then
  end
end
function create_animation(ani_name)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = ani_name
  gui.Desktop:Add(animation)
  animation.AutoSize = true
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "dance_animation_end")
  animation:Play()
end
function create_begin_animation()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SCHOOL_DANCE))
  if not nx_is_valid(view) then
    return
  end
  local cur_turn = view:QueryProp("CurTurn")
  if nx_int(cur_turn) == nx_int(0) then
    local gui = nx_value("gui")
    local animation = gui:Create("Animation")
    animation.AnimationImage = "train_smsy_start"
    gui.Desktop:Add(animation)
    animation.Left = (gui.Width - 500) / 2
    animation.Top = gui.Height / 6
    animation.Loop = false
    nx_bind_script(animation, nx_current())
    nx_callback(animation, "on_animation_end", "dance_animation_end")
    animation:Play()
  end
end
function create_end_animation()
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = "train_smsy_complete"
  gui.Desktop:Add(animation)
  animation.Left = (gui.Width - 500) / 2
  animation.Top = gui.Height / 6
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "dance_animation_end")
  animation:Play()
end
function dance_animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function start_success_move()
  local game_visual = nx_value("game_visual")
  local player = game_visual:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local scene = player.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect) then
    return false
  end
  game_effect:SetGlobalEffect(0, player, 3, "", 0)
end
