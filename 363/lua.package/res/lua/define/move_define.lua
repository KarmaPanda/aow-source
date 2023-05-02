MMODE_STOP = 0
MMODE_MOTION = 1
MMODE_JUMP = 2
MMODE_JUMPTO = 3
MMODE_FLY = 4
MMODE_SWIM = 5
MMODE_DRIFT = 6
MMODE_CLIMB = 7
MMODE_SLIDE = 8
MMODE_SINK = 9
MIN_DISTANCE = 0.01
MIN_FACE_CHANGE_DISTANCE = 0.5
MUST_SYNC_DISTANCE = 1000
NOT_SYNC_DISTANCE = 0
FLOOR_AT_WATER = 200
FLOOR_IN_AIR = 300
FLOOR_UNDER_WATER = 400
move_action_lst = {
  ground = {
    run_front = "run",
    run_left = "runleft",
    run_right = "runright",
    run_back = "runback",
    run_lb = "runleft_b",
    run_lf = "runleft_f",
    run_rb = "runright_b",
    run_rf = "runright_f",
    walk_front = "walk",
    walk_left = "walkleft",
    walk_right = "walkright",
    walk_back = "walkback",
    walk_lb = "walkleft_b",
    walk_lf = "walkleft_f",
    walk_rb = "walkright_b",
    walk_rf = "walkright_f",
    stand_front = "stand",
    stand_left = "turnleft",
    stand_right = "turnright"
  },
  wall = {
    run_front = "qg_S_runs_f",
    run_left = "qg_S_runs_l",
    run_right = "qg_S_runs_r",
    run_back = "qg_S_runs_f",
    walk_front = "qg_S_runs_f",
    walk_left = "qg_S_runs_l",
    walk_right = "qg_S_runs_r",
    walk_back = "qg_S_runs_f",
    stand_front = "qg_S_runs_f",
    stand_left = "qg_S_runs_l",
    stand_right = "qg_S_runs_r"
  },
  jump_begin = {
    run_front = "jump_f",
    run_left = "jump_l",
    run_right = "jump_r",
    run_back = "jump_b",
    walk_front = "jump_f",
    walk_left = "jump_l",
    walk_right = "jump_r",
    walk_back = "jump_b",
    stand_front = "jump",
    stand_left = "jump_l",
    stand_right = "jump_r"
  },
  jumping = {
    run_front = "jumpdowning",
    run_left = "jumpdowning",
    run_right = "jumpdowning",
    run_back = "jumpdowning",
    walk_front = "jumpdowning",
    walk_left = "jumpdowning",
    walk_right = "jumpdowning",
    walk_back = "jumpdowning",
    stand_front = "jumpdowning",
    stand_left = "jumpdowning",
    stand_right = "jumpdowning"
  },
  jump_jump = {
    run_front = "qg_jump02_f",
    run_left = "qg_jump02_l",
    run_right = "qg_jump02_r",
    run_back = "qg_jump02_b",
    walk_front = "qg_jump02_f",
    walk_left = "qg_jump02_l",
    walk_right = "qg_jump02_r",
    walk_back = "qg_jump02_b",
    stand_front = "qg_jump02",
    stand_left = "qg_jump02_l",
    stand_right = "qg_jump02_r"
  },
  jump_jump_jump = {
    run_front = "qg_jump03_f",
    run_left = "qg_jump03_l",
    run_right = "qg_jump03_r",
    run_back = "qg_jump03_b",
    walk_front = "qg_jump03_f",
    walk_left = "qg_jump03_l",
    walk_right = "qg_jump03_r",
    walk_back = "qg_jump03_b",
    stand_front = "qg_jump03",
    stand_left = "qg_jump03",
    stand_right = "qg_jump03"
  },
  jump_end = {
    run_front = "jumpdown_f",
    run_left = "jumpdown_l",
    run_right = "jumpdown_r",
    run_back = "jumpdown_b",
    walk_front = "jumpdown_f",
    walk_left = "jumpdown_l",
    walk_right = "jumpdown_r",
    walk_back = "jumpdown_b",
    stand_front = "jumpdown",
    stand_left = "jumpdown",
    stand_right = "jumpdown"
  },
  swim = {
    run_front = "swim_walk",
    run_left = "swim_walkleft",
    run_right = "swim_walkright",
    run_back = "swim_walkback",
    walk_front = "swim_walk",
    walk_left = "swim_walkleft",
    walk_right = "swim_walkright",
    walk_back = "swim_walkback",
    stand_front = "swim_stand",
    stand_left = "swim_turnleft",
    stand_right = "swim_turnright"
  },
  water = {
    run_front = "qg_swim_run",
    run_left = "qg_swim_run",
    run_right = "qg_swim_run",
    run_back = "qg_swim_run",
    walk_front = "qg_swim_run",
    walk_left = "qg_swim_run",
    walk_right = "qg_swim_run",
    walk_back = "qg_swim_run",
    stand_front = "qg_swim_run",
    stand_left = "qg_swim_run",
    stand_right = "qg_swim_run"
  },
  fly = {
    run_front = "qg_fastruning_s",
    run_left = "qg_fastruning_s",
    run_right = "qg_fastruning_s",
    run_back = "qg_fastruning_s",
    walk_front = "qg_fastruning_s",
    walk_left = "qg_fastruning_s",
    walk_right = "qg_fastruning_s",
    walk_back = "qg_fastruning_s",
    stand_front = "qg_fastruning_s",
    stand_left = "qg_fastruning_s",
    stand_right = "qg_fastruning_s"
  },
  sinking = {
    run_front = "swim_sinking",
    run_left = "swim_sinking",
    run_right = "swim_sinking",
    run_back = "swim_sinking",
    walk_front = "swim_sinking",
    walk_left = "swim_sinking",
    walk_right = "swim_sinking",
    walk_back = "swim_sinking",
    stand_front = "swim_sinking",
    stand_left = "swim_sinking",
    stand_right = "swim_sinking"
  },
  taolu_ground_half = {
    run_front = "zs_run_f",
    run_left = "zs_run_l",
    run_right = "zs_run_r",
    run_back = "zs_run_b",
    run_lb = "zs_run_b_l",
    run_lf = "zs_run_f_l",
    run_rb = "zs_run_b_r",
    run_rf = "zs_run_f_r",
    walk_front = "zs_walk_f",
    walk_left = "zs_walk_l",
    walk_right = "zs_walk_r",
    walk_back = "zs_walk_b",
    walk_lb = "zs_walk_b_l",
    walk_lf = "zs_walk_f_l",
    walk_rb = "zs_walk_b_r",
    walk_rf = "zs_walk_f_r",
    stand_front = "stand",
    stand_left = "stand",
    stand_right = "stand"
  }
}
local move_action_key = {
  "qg_",
  "stand",
  "run",
  "walk",
  "jump",
  "swim",
  "turnleft",
  "turnright"
}
function is_move_action(action)
  for _, key in pairs(move_action_key) do
    if string.find(action, key) ~= nil then
      return true
    end
  end
  return false
end
function get_move_type(role)
  local game_visual = nx_value("game_visual")
  if game_visual:QueryRoleMoveSpeed(role) > 2.0001 then
    return "run"
  else
    return "walk"
  end
end
function cant_move(role)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return true
  end
  if role.locked > 0 then
    return true
  end
  local cantmove = client_player:QueryProp("CantMove")
  if 0 < cantmove then
    return true
  end
  local OnTransToolState = client_player:QueryProp("OnTransToolState")
  if OnTransToolState ~= 0 then
    return true
  end
  if role.b_sitcross then
    return true
  end
  return false
end
function cant_motion(role)
  local game_visual = nx_value("game_visual")
  if game_visual:QueryRoleMoveSpeed(role) > 0 then
    return false
  else
    return true
  end
end
function stop_motion(role)
  if role.state == "locked" then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(role)
  if game_client:IsPlayer(client_ident) then
    game_visual:SwitchPlayerState(role, "static", 1)
  else
    game_visual:SwitchPlayerState(role, "be_stop", 30)
  end
end
function clear_motion(role)
  if role.state == "locked" then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(role)
  if game_client:IsPlayer(client_ident) then
    game_visual:SwitchPlayerState(role, "static", 1)
  else
    game_visual:SwitchPlayerState(role, "be_stop", 30)
  end
end
function normalize_angle(angle)
  local value = math.fmod(angle, math.pi * 2)
  if value < 0 then
    value = value + math.pi * 2
  end
  return value
end
function calc_yaw_angle(src_angle, dst_angle)
  local angle = normalize_angle(dst_angle) - normalize_angle(src_angle)
  if angle > math.pi then
    angle = angle - 2 * math.pi
  elseif angle < -math.pi then
    angle = angle + 2 * math.pi
  end
  return angle
end
function line_2d_angle(x0, z0, x1, z1)
  local sx = x1 - x0
  local sz = z1 - z0
  local dist_xz = math.sqrt(sx * sx + sz * sz)
  if dist_xz == 0 then
    return 0
  end
  local ay = math.acos(sz / dist_xz)
  if sx < 0 then
    ay = -ay
  end
  return normalize_angle(ay)
end
function line_3d_angle(x0, y0, z0, x1, y1, z1)
  local sx = x1 - x0
  local sy = y1 - y0
  local sz = z1 - z0
  local ax, ay = 0, 0
  local dist_xz = math.sqrt(sx * sx + sz * sz)
  if 0 < dist_xz then
    ay = math.acos(sz / dist_xz)
    if sx < 0 then
      ay = -ay
    end
  end
  local dist = math.sqrt(sx * sx + sy * sy + sz * sz)
  if 0 < dist then
    ax = math.asin(sy / dist)
    if sy < 0 then
      ax = -ax
    end
  end
  return normalize_angle(ax), normalize_angle(ay)
end
