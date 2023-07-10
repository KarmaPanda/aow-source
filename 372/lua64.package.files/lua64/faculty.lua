require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
FACULTY_STATE_NO = 0
FACULTY_STATE_READY = 1
FACULTY_STATE_CONVERT = 2
FACULTY_STATE_HELP = 3
SUB_CLIENT_CONVERT_READY = 1
SUB_SERVER_FACULTY_SET = 1
SUB_SERVER_NORMAL_READY = 11
SUB_SERVER_NORMAL_BEGIN = 12
SUB_SERVER_NORMAL_EXIT = 13
SUB_SERVER_NORMAL_LEVEL_UP = 14
SUB_SERVER_ACT_READY = 21
SUB_SERVER_ACT_BEGIN = 22
SUB_SERVER_ACT_EXIT = 23
SUB_SERVER_ACT_PLAY = 24
SUB_KEN_SERVER_SUCCESS = 100
SUB_KEN_SERVER_FAILED = 101
function set_faculty_wuxue(convert_name, ext_faculty)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  if not condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(23614)) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_faculty_function_off"), 2)
    end
    return false
  end
  nx_execute("custom_sender", "custom_send_faculty_msg", SUB_CLIENT_CONVERT_READY, nx_string(convert_name), ext_faculty)
  return true
end
function FacultyProcess(client_scene_obj, visual_scene_obj, cur_logic, old_logic)
  if not nx_is_valid(client_scene_obj) or not nx_is_valid(visual_scene_obj) then
    return
  end
  if nx_int(cur_logic) == nx_int(LS_FACULTY) and nx_int(old_logic) ~= nx_int(LS_FACULTY) then
    emit_player_input(visual_scene_obj, PLAYER_INPUT_LOGIC, LOGIC_BEGIN_FACULTY)
  elseif nx_int(cur_logic) ~= nx_int(LS_FACULTY) and nx_int(old_logic) == nx_int(LS_FACULTY) then
    emit_player_input(visual_scene_obj, PLAYER_INPUT_LOGIC, LOGIC_END_FACULTY)
  end
end
function ken_msg(msg_type, client_id)
  if msg_type == nil or client_id == nil then
    return
  end
  local ident = nx_string(client_id)
  local game_visual = nx_value("game_visual")
  local visual_obj = game_visual:GetSceneObj(ident)
  local game_client = nx_value("game_client")
  local client_obj = game_client:GetSceneObj(ident)
  if nx_is_valid(visual_obj) then
    nx_set_custom(visual_obj, "faculty_state", nx_int(msg_type))
  end
  return
end
function on_msg(arg1, arg2)
  if arg1 == nil then
    return false
  end
  if nx_int(arg1) == nx_int(SUB_KEN_SERVER_SUCCESS) or nx_int(arg1) == nx_int(SUB_KEN_SERVER_FAILED) then
    ken_msg(arg1, arg2)
  elseif nx_int(arg1) == nx_int(SUB_SERVER_NORMAL_EXIT) then
  elseif nx_int(arg1) == nx_int(SUB_SERVER_NORMAL_LEVEL_UP) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_faculty", "on_msg_level_up", arg2)
  elseif nx_int(arg1) == nx_int(SUB_SERVER_ACT_BEGIN) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_act", "on_msg_act_begin")
  elseif nx_int(arg1) == nx_int(SUB_SERVER_ACT_PLAY) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_act", "on_msg_act_play", arg2)
  elseif nx_int(arg1) == nx_int(SUB_SERVER_ACT_EXIT) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_act", "on_msg_exit_faculty")
  elseif nx_int(arg1) == nx_int(SUB_SERVER_FACULTY_SET) then
    util_show_form("form_stage_main\\form_wuxue\\form_wuxue_faculty", true)
  end
end
