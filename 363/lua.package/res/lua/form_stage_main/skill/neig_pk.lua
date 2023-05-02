require("util_gui")
require("util_functions")
require("custom_sender")
function on_server_msg(type, ...)
  local path = "form_stage_main\\skill\\form_neig_pk"
  if type == "update" then
    local point = nx_int(arg[1])
    local revert = nx_int(arg[2])
    local nextChipPoint = nx_int(arg[3])
    local max_point = nx_int(arg[4])
    nx_execute(path, "update_revert", point, revert, nextChipPoint, max_point)
  elseif type == "end" then
    local self = nx_object(arg[1])
    nx_execute("form_stage_main\\skill\\neig_pk", "end_neig_pk", self)
  elseif type == "begin" then
    local self = nx_object(arg[1])
    local target = nx_object(arg[2])
    local show_1 = nx_int(arg[3])
    local show_2 = nx_int(arg[4])
    local sx = nx_float(arg[5])
    local sy = nx_float(arg[6])
    local sz = nx_float(arg[7])
    local so = nx_float(arg[8])
    local tx = nx_float(arg[9])
    local ty = nx_float(arg[10])
    local tz = nx_float(arg[11])
    local to = nx_float(arg[12])
    move_to(self, sx, sy, sz, so, target, tx, ty, tz, to)
    nx_execute("form_stage_main\\skill\\neig_pk", "start_neig_pk", self, target, show_1, show_2)
  elseif type == "join" then
    local self = nx_object(arg[1])
    local target = nx_object(arg[2])
    nx_execute(path, "join_neig_pk", self, target)
  elseif type == "chip" then
    local side = nx_int(arg[1])
    local index = nx_int(arg[2])
    local style = nx_int(arg[3])
    local consum = nx_int(arg[4])
    nx_execute(path, "on_chip", side, index, style, consum)
  elseif type == "over_pause" then
    nx_execute(path, "show_result")
  end
end
function move_to(self, x, y, z, o, target, tx, ty, tz, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_self = game_visual:GetSceneObj(nx_string(self))
  local visual_target = game_visual:GetSceneObj(nx_string(target))
  if not nx_is_valid(visual_self) or not nx_is_valid(visual_target) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  terrain:RelocateVisual(visual_self, x, y, z)
  terrain:RelocateVisual(visual_target, tx, ty, tz)
  visual_self:SetAngle(0, nx_float(o), 0)
  visual_target:SetAngle(0, nx_float(to), 0)
  nx_pause(0.3)
end
function on_space_up()
  if is_main_neig_pker() then
    chip_in()
    return true
  end
  return false
end
function is_main_neig_pker()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return false
  end
  local pos = game_role:QueryProp("NeigPkPos")
  if nx_int(pos) == nx_int(1) or nx_int(pos) == nx_int(101) then
    return true
  end
  return false
end
function can_pk_neig(self, target)
  if nx_string(self) == nx_string(target) then
    return 0
  end
  local pos = self:QueryProp("NeigPkPos")
  if nx_int(pos) > nx_int(0) then
    return 0
  end
  pos = target:QueryProp("NeigPkPos")
  if nx_int(pos) > nx_int(0) then
    return 0
  end
  local isRiding = nx_execute("form_stage_main\\form_life\\form_ride_op", "is_ride")
  if isRiding then
    return 0
  end
  isRiding = target:QueryProp("Mount")
  if 0 < string.len(isRiding) then
    return 0
  end
  return 1
end
function can_join_pk_neig(self, target)
  if nx_string(self) == nx_string(target) then
    return 0
  end
  local pos = self:QueryProp("NeigPkPos")
  if nx_int(pos) > nx_int(0) then
    return 0
  end
  pos = target:QueryProp("NeigPkPos")
  if nx_int(pos) <= nx_int(0) then
    return 0
  end
  local isRiding = nx_execute("form_stage_main\\form_life\\form_ride_op", "is_ride")
  if isRiding then
    return 0
  end
  return 1
end
function chip_in()
  nx_execute("custom_sender", "custom_neigong_pk_chipin")
end
function start_neig_pk(self, target, show_1, show_2)
  nx_execute("form_stage_main\\skill\\form_neig_pk", "on_begin_init", self, target, show_1, show_2)
end
function end_neig_pk(self)
  nx_execute("form_stage_main\\skill\\form_neig_pk", "end_game")
end
