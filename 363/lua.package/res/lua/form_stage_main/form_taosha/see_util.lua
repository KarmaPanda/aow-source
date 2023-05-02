require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\form_taosha\\taosha_util")
local player_prop_hide = "Hide"
local player_prop_see_state = "SeeModuleSeeState"
local file_name = "form_stage_main\\form_taosha\\see_util"
function get_see_state()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp(player_prop_see_state) then
    return false
  end
  local state = player:QueryProp(player_prop_see_state)
  return nx_int(state)
end
function is_see()
  local state = get_see_state()
  return state == nx_int(1)
end
function is_be_see()
  local state = get_see_state()
  return state == nx_int(2)
end
function stop_see()
  custom_see(nx_int(1))
end
function recv_start_see(target_name)
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  player.see_target_name = nx_widestr(target_name)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(file_name, "timer_see_target", player)
    timer:Register(100, -1, file_name, "timer_see_target", player, -1, -1)
  end
  timer_see_target()
end
function recv_stop()
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  player.see_target_name = nx_widestr("")
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(file_name, "timer_see_target", player)
  end
  nx_execute("form_test\\form_camera", "reset_camera_target", true)
  bind_hide_prop()
end
function IsExistObject(obj)
  local game_visual = nx_value("game_visual")
  local visual_obj = game_visual:GetSceneObj(obj.Ident)
  if not nx_is_valid(visual_obj) then
    return false
  end
  return true
end
function timer_see_target()
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local target_name = player.see_target_name
  local target = nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "find_obj_by_name", target_name)
  if not nx_is_valid(target) then
    return
  end
  local role = nx_value("role")
  local head_game = nx_value("HeadGame")
  role.Visible = false
  head_game:ShowHead(role, false)
  nx_execute("form_test\\form_camera", "set_camera_target", target)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(file_name, "timer_see_target", player)
  end
end
function l(text)
  nx_msgbox(nx_string(text))
end
function reset_scene()
  recv_stop()
  bind_hide_prop()
end
function bind_hide_prop()
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelRolePropertyBind(player_prop_hide, player)
  databinder:AddRolePropertyBind(player_prop_hide, "int", player, file_name, "on_hide_prop_change")
end
function on_hide_prop_change(form, propname, proptype, value)
  local head_game = nx_value("HeadGame")
  local role = nx_value("role")
  if nx_int(value) == nx_int(0) then
    head_game:ShowHead(role, true)
  else
    head_game:ShowHead(role, false)
  end
end
