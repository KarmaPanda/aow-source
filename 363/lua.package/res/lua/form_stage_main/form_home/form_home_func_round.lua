require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\client_custom_define")
FORM_FUNC_ROUND = "form_stage_main\\form_home\\form_home_func_round"
local CLIENT_FURNITURE_TURN_ROUND = 34
local TURN_LEFT = 0
local TURN_RIGHT = 1
local TURN_STOP = 2
function main_form_init(form)
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.Visible = true
  form.Fixed = false
  form:Show()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_find_custom(form, "target_npc") then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), nx_int(CLIENT_FURNITURE_TURN_ROUND), nx_int(TURN_STOP), nx_object(form.target_npc))
  end
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_find_custom(form, "target_npc") then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), nx_int(CLIENT_FURNITURE_TURN_ROUND), nx_int(TURN_STOP), nx_object(form.target_npc))
  end
  form:Close()
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form) then
    timer:UnRegister(nx_current(), "auto_left_rotate", form)
  end
  return
end
function on_btn_left_push(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_find_custom(form, "target_npc") then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), nx_int(CLIENT_FURNITURE_TURN_ROUND), nx_int(TURN_LEFT), nx_object(form.target_npc))
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form) then
    timer:Register(100, -1, nx_current(), "auto_left_rotate", form, -1, -1)
  end
end
function on_btn_right_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form) then
    timer:UnRegister(nx_current(), "auto_right_rotate", form)
  end
end
function on_btn_left_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form) then
    timer:UnRegister(nx_current(), "auto_left_rotate", form)
  end
end
function on_btn_right_push(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_find_custom(form, "target_npc") then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), nx_int(CLIENT_FURNITURE_TURN_ROUND), nx_int(TURN_RIGHT), nx_object(form.target_npc))
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form) then
    timer:Register(100, -1, nx_current(), "auto_right_rotate", form, -1, -1)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form) then
    timer:UnRegister(nx_current(), "auto_right_rotate", form)
  end
  return
end
function auto_right_rotate(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_find_custom(form, "target_npc") then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), nx_int(CLIENT_FURNITURE_TURN_ROUND), nx_int(TURN_RIGHT), nx_object(form.target_npc))
  end
end
function auto_left_rotate(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_find_custom(form, "target_npc") then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), nx_int(CLIENT_FURNITURE_TURN_ROUND), nx_int(TURN_LEFT), nx_object(form.target_npc))
  end
end
