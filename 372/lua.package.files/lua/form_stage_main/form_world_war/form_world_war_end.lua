require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
local exit_immediately = 1
local AUTO_CLOSE_FORM_MSEC = 3000
function main_form_init(form)
  form.Fixed = false
end
function on_btn_exit_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(CLIENT_WORLDWAR_EXIT), nx_int(1))
  btn.ParentForm:Close()
end
function on_world_war_end(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", form)
    timer:Register(AUTO_CLOSE_FORM_MSEC, -1, nx_current(), "on_timer", form, -1, -1)
  end
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 68
  on_world_war_end(form)
end
function on_timer(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(CLIENT_WORLDWAR_EXIT), nx_int(1))
  form:Close()
end
