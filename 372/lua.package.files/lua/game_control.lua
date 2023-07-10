require("define\\gamehand_type")
require("share\\view_define")
require("define\\camera_mode")
require("define\\move_define")
require("define\\control_mode_define")
require("util_gui")
require("player_state\\state_input")
require("share\\logicstate_define")
require("game_hand")
require("player_state\\state_const")
require("share\\npc_type_define")
local table_is_key_down = {}
local KEY_CLICK_TIME = 100
function game_control_init(self)
  self.Camera = nx_value("camera")
  self.World = nx_value("world")
  self.pick_id = nx_null()
  self.right_down_pick_id = nx_null()
  self.left_down_pick_id = nx_null()
  self.show_all_balloon = false
  self.space_flag = false
  local game_config_info = nx_value("game_config_info")
  local camera_max_dis = 20
  local camera_modify_y = 0
  if nx_is_valid(game_config_info) then
    if nx_find_property(game_config_info, "max_camera_dis") then
      camera_max_dis = nx_float(game_config_info.max_camera_dis)
    end
    if nx_find_property(game_config_info, "camera_modify_y") then
      camera_modify_y = nx_float(game_config_info.camera_modify_y)
    end
  end
  self.MouseResponseRate = 1.5
  local normal_camera = self:GetCameraController(GAME_CAMERA_NORMAL)
  normal_camera.DistanceMoveSpeed = 5
  normal_camera.YawMoveSpeed = 10
  normal_camera.PitchMoveSpeed = 10
  normal_camera.WheelMoveSpeed = 1
  normal_camera.MinDistance = 0.5
  normal_camera.MaxDistance = camera_max_dis
  normal_camera.MinPitchAngle = -math.pi * 0.5 + 0.5
  normal_camera.MaxPitchAngle = math.pi * 0.5 - 0.5
  normal_camera.CameraMinHeight = 0.5
  normal_camera.DefDistance = 3.8
  normal_camera.DefPitch = 0.4
  normal_camera.DeflectAngle = nx_int(nx_execute("control_set", "get_camera_deflect_angle"))
  normal_camera.DeflectZeorPos = 1
  normal_camera.CameraModifyY = -0.1
  normal_camera.AlphaChangeDis = 0.7
  local story_camera = self:GetCameraController(GAME_CAMERA_STORY)
  story_camera.DistanceMoveSpeed = 2
  story_camera.YawMoveSpeed = 5
  story_camera.PitchMoveSpeed = 5
  story_camera.WheelMoveSpeed = 1
  story_camera.MaxDistance = 40
  local scene_camera = self:GetCameraController(GAME_CAMERA_MOVIESCENE)
  scene_camera.DistanceMoveSpeed = 2
  scene_camera.YawMoveSpeed = 5
  scene_camera.PitchMoveSpeed = 5
  scene_camera.WheelMoveSpeed = 1
  scene_camera.MinDistance = 1
  scene_camera.MaxDistance = 20
  scene_camera.MinPitchAngle = -math.pi * 0.5 + 0.5
  scene_camera.MaxPitchAngle = math.pi * 0.5 - 0.5
  scene_camera.CameraMinHeight = 0.5
  scene_camera.DefDistance = 3.8
  scene_camera.DefPitch = 0.4
  scene_camera.DeflectAngle = nx_int(nx_execute("control_set", "get_camera_deflect_angle"))
  scene_camera.DeflectZeorPos = 1
  local bindpos_camera = self:GetCameraController(GAME_CAMERA_BINDPOS)
  bindpos_camera.DistanceMoveSpeed = 2
  bindpos_camera.YawMoveSpeed = 5
  bindpos_camera.PitchMoveSpeed = 5
  bindpos_camera.WheelMoveSpeed = 1
  bindpos_camera.DefYDistance = 1
  bindpos_camera.DefXZDistance = 4
  bindpos_camera.MinDistance = 1
  bindpos_camera.MaxDistance = camera_max_dis
  bindpos_camera.MinPitchAngle = -math.pi * 0.5 + 0.5
  bindpos_camera.MaxPitchAngle = math.pi * 0.5 - 0.5
  bindpos_camera.CameraMinHeight = 0.5
  bindpos_camera.DeflectAngle = nx_int(nx_call("control_set", "get_camera_deflect_angle"))
  bindpos_camera.DeflectZeorPos = 1
  if nx_find_property(bindpos_camera, "CameraModifyY") then
    bindpos_camera.CameraModifyY = camera_modify_y
  end
  local fix_target_camera = self:GetCameraController(GAME_CAMERA_FIXTARGET)
  fix_target_camera.DistanceMoveSpeed = 5
  fix_target_camera.YawMoveSpeed = 10
  fix_target_camera.PitchMoveSpeed = 10
  fix_target_camera.WheelMoveSpeed = 1
  fix_target_camera.MinDistance = 0.5
  fix_target_camera.MaxDistance = camera_max_dis
  fix_target_camera.MinPitchAngle = -math.pi * 0.5 + 0.5
  fix_target_camera.MaxPitchAngle = math.pi * 0.5 - 0.5
  fix_target_camera.CameraMinHeight = 0.5
  fix_target_camera.DefDistance = 3.8
  fix_target_camera.DefPitch = 0.4
  fix_target_camera.DeflectAngle = nx_int(nx_execute("control_set", "get_camera_deflect_angle"))
  fix_target_camera.DeflectZeorPos = 1
  fix_target_camera.CameraModifyY = -0.1
  fix_target_camera.AlphaChangeDis = 0.7
  self.last_key_down_time = 0
  local scene = nx_value("game_scene")
  local trangledraw = scene:Create("TrangleDraw")
  if nx_is_valid(trangledraw) then
    scene:AddObject(trangledraw, 0)
    self.TrangleDrawID = trangledraw
    self.CollideShowMode = 0
  else
  end
  nx_execute("control_set", "initial_control_mode", self)
  return 1
end
function add_location_effect(eff_x, eff_y, eff_z)
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return 0
  end
  local scene = visual_player.scene
  local eff_model = nx_execute("game_effect", "create_eff_model_in_mainscene", scene, "item_walked", eff_x, eff_y, eff_z)
  if nx_is_valid(eff_model) then
    eff_model.x = eff_x
    eff_model.y = eff_y
    eff_model.z = eff_z
    nx_set_value("scene_location_effect", eff_model)
  end
end
function del_location_effect()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return 0
  end
  local scene = visual_player.scene
  local eff_model = nx_value("scene_location_effect")
  if nx_is_valid(eff_model) then
    nx_execute("game_effect", "delete_eff_model_in_mainscene", scene, eff_model)
    nx_set_value("scene_location_effect", nx_null())
  end
end
function check_location_effect()
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  while true do
    nx_pause(0.1)
    if not nx_is_valid(visual_player) then
      del_location_effect()
      break
    end
    local eff_model = nx_value("scene_location_effect")
    if not nx_is_valid(eff_model) then
      break
    end
    local pos_x = visual_player.PositionX
    local pos_z = visual_player.PositionZ
    local delta_x = math.abs(pos_x - eff_model.x)
    local delta_z = math.abs(pos_z - eff_model.z)
    if delta_x <= 0.01 and delta_z <= 0.01 then
      del_location_effect()
      break
    end
  end
end
function begin_location_effect(x, y, z)
  if nx_running(nx_current(), "check_location_effect") then
    nx_kill(nx_current(), "check_location_effect")
  end
  del_location_effect()
  add_location_effect(x, y, z)
  nx_execute(nx_current(), "check_location_effect")
end
function camera_vibrate(type, swing_begin, swing_end, period, keep_time)
  type = type or 0
  swing_begin = swing_begin or 0.2
  swing_end = swing_end or 0.2
  period = period or 0.05
  keep_time = keep_time or 0.5
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if nx_is_valid(game_control) then
    game_control.VibrateType = nx_int(type)
    game_control.VibrateSwingBegin = nx_float(swing_begin)
    game_control.VibrateSwingEnd = nx_float(swing_end)
    game_control.VibratePeriod = nx_float(period)
    game_control.VibrateKeepTime = nx_float(keep_time)
    game_control.Vibrate = true
  end
end
function stop_camera_vibrate()
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if nx_is_valid(game_control) and game_control.Vibrate then
    game_control.Vibrate = false
  end
end
function set_foucs_height()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local ClientPlayer = game_client:GetPlayer()
  if not nx_is_valid(ClientPlayer) then
    return
  end
  local sex = 0
  if ClientPlayer:FindProp("Sex") then
    sex = ClientPlayer:QueryProp("Sex")
  end
  local camera_modify_y = 0
  if sex == 0 then
    camera_modify_y = -0.1
  else
    camera_modify_y = -0.1
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local camera_control = game_control:GetCameraController(game_control.CameraMode)
  if not nx_is_valid(camera_control) then
    return
  end
  camera_control.CameraModifyY = camera_modify_y
end
