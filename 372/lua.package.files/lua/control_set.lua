require("share\\view_define")
require("util_functions")
require("util_gui")
require("define\\camera_mode")
require("define\\control_mode_define")
require("define\\fight_operate_mode_define")
function get_camera_mode()
  local result = GetIniInfo("camera_value")
  if result == "" or result == nil then
    return GAME_CAMERA_NORMAL
  elseif result == nx_string(GAME_CAMERA_NORMAL) then
    return GAME_CAMERA_NORMAL
  elseif result == nx_string(GAME_CAMERA_BINDPOS) then
    return GAME_CAMERA_BINDPOS
  end
  return GAME_CAMERA_NORMAL
end
function is_joystick_fight_operate_mode()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if nx_is_valid(game_control) then
    return game_control.FightOperateMode == FIGHT_OPERATE_MODE_JOYSTICK
  end
end
function get_camera_deflect_angle()
  local deflect_angle = GetIniInfo("camera_angle")
  if deflect_angle == "" or deflect_angle == nil then
    return 0
  end
  return nx_int(deflect_angle) - 100
end
function initial_control_mode(game_control)
  if not nx_is_valid(game_control) then
    return false
  end
  local lm_key_set = GetIniInfo("lmouse_normal_mode")
  if lm_key_set == nil or lm_key_set == "" then
    game_control.MLKeySlideCamera = true
  elseif nx_int(lm_key_set) == nx_int(0) then
    game_control.MLKeySlideCamera = false
  elseif nx_int(lm_key_set) == nx_int(1) then
    game_control.MLKeySlideCamera = true
  end
  return true
end
function get_control_mode()
  return GetIniInfo("control_mode")
end
function SetIniInfo(key, Value)
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return ""
  end
  nx_set_property(game_config_info, nx_string(key), Value)
end
function GetIniInfo(custom_name, default_value)
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return ""
  end
  if not nx_find_property(game_config_info, nx_string(custom_name)) then
    nx_set_property(game_config_info, nx_string(custom_name), default_value)
    if default_value == nil then
      return "0"
    else
      return default_value
    end
  end
  return nx_property(game_config_info, nx_string(custom_name))
end
function GetCfgInfo(custom_name, default_value)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return ""
  end
  if not nx_find_property(game_config, nx_string(custom_name)) then
    nx_set_property(game_config, nx_string(custom_name), default_value)
    if default_value == nil then
      return "0"
    else
      return default_value
    end
  end
  return nx_property(game_config, nx_string(custom_name))
end
