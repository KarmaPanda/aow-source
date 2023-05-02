require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
function sitcross_configID()
  return "zs_default_01"
end
function SitcrossProcess(client_scene_obj, visual_scene_obj, cur_logic, old_logic)
  if not nx_is_valid(client_scene_obj) or not nx_is_valid(visual_scene_obj) then
    return
  end
  if nx_int(cur_logic) == nx_int(LS_SITCROSS) and nx_int(old_logic) ~= nx_int(LS_SITCROSS) then
    emit_player_input(visual_scene_obj, PLAYER_INPUT_LOGIC, LOGIC_BEGIN_SITCROSS)
  elseif nx_int(cur_logic) ~= nx_int(LS_SITCROSS) and nx_int(old_logic) == nx_int(LS_SITCROSS) then
    emit_player_input(visual_scene_obj, PLAYER_INPUT_LOGIC, LOGIC_END_SITCROSS)
  end
end
function begin_sitcross()
  nx_execute("custom_sender", "custom_sitcross", 1)
end
function end_sitcross()
  nx_execute("custom_sender", "custom_sitcross", 2)
end
function get_sit_start_action()
  return "ng_start_1"
end
function get_sit_state()
  return "ng_state_1"
end
function get_sit_finish_action()
  return "ng_end_1"
end
