require("util_functions")
ERROR_HEIGHT = 100000000
MIN_COLLIDE_RADIUS = 0.5
function get_floor_index(terrain, role, dx, dy, dz)
  local floor_num = terrain:GetFloorCount(dx, dz)
  for i = 0, floor_num - 1 do
    if terrain:GetFloorExists(dx, dz, i) then
      local floor_y = terrain:GetFloorHeight(dx, dz, i)
      if float_equal(floor_y, dy, 0.001, "util_move 15") then
        return i
      end
    end
  end
  if terrain:GetWalkWaterExists(dx, dz) then
    local water_y = terrain:GetWalkWaterHeight(dx, dz)
    if float_equal(water_y, dy, 0.001, "util_move 24") then
      return FLOOR_AT_WATER
    end
    local swim_y = water_y - role.height * 0.5
    if dy <= swim_y then
      return FLOOR_UNDER_WATER
    end
  end
  return FLOOR_IN_AIR
end
function get_stand_point(terrain, role, dx, dy, dz, info)
  local stand_y, floor_index
  local can_stand = false
  if not nx_is_valid(terrain) then
    nx_msgbox(info)
    terrain = role.scene.terrain
  end
  if dx == nil or dx == nil or dy == nil then
    nx_msgbox(info)
  end
  local floor_num = terrain:GetFloorCount(dx, dz)
  for i = floor_num - 1, 0, -1 do
    if terrain:GetFloorExists(dx, dz, i) then
      local floor_y = terrain:GetFloorHeight(dx, dz, i)
      local floor_space = terrain:GetFloorSpace(dx, dz, i)
      if floor_space >= role.height and dy >= floor_y then
        stand_y = floor_y
        if terrain:GetFloorCanMove(dx, dz, i) or terrain:GetFloorCanStand(dx, dz, i) then
          floor_index = i
          can_stand = true
          break
        end
        can_stand = false
        floor_index = FLOOR_IN_AIR
        break
      end
    end
  end
  if terrain:GetWalkWaterExists(dx, dz) then
    local water_y = terrain:GetWalkWaterHeight(dx, dz)
    local swim_y = water_y - role.height * 0.5
    local apex_y = terrain:GetApexHeight(dx, dz)
    if stand_y == nil or swim_y > stand_y + 0.001 then
      if swim_y > apex_y then
        return swim_y, FLOOR_UNDER_WATER
      end
      local ground_y = terrain:GetFloorHeight(dx, dz, 0)
      local ground_space = terrain:GetFloorSpace(dx, dz, 0)
      local swim_space = ground_space - (swim_y - ground_y)
      if swim_space > role.height then
        return swim_y, FLOOR_UNDER_WATER, false
      end
    end
  end
  return stand_y, floor_index, can_stand
end
function get_cur_floor_height(terrain, floor_index, x, y, z)
  if floor_index == FLOOR_AT_WATER then
    if terrain:GetWaterExists(x, z) then
      return terrain:GetWalkWaterHeight(x, z)
    end
  else
    local floor_count = terrain:GetFloorCount(x, z)
    if 0 <= floor_index and floor_index < floor_count then
      return terrain:GetFloorHeight(x, z, floor_index)
    end
  end
  return y
end
function get_pos_floor_index(terrain, x, y, z)
  local floor_num = terrain:GetFloorCount(x, z)
  local higher_floor = -1
  local higher_floor_y = 1000
  local lower_floor = -1
  local lower_floor_y = -1000
  for i = floor_num - 1, 0, -1 do
    if terrain:GetFloorExists(x, z, i) then
      local floor_y = terrain:GetFloorHeight(x, z, i)
      if y < floor_y and higher_floor_y > floor_y then
        higher_floor = i
        higher_floor_y = floor_y
      end
      if y >= floor_y and lower_floor_y < floor_y then
        lower_floor = i
        lower_floor_y = floor_y
      end
    end
  end
  local min_distance = 1000
  if -1 < higher_floor then
    min_distance = higher_floor_y - y
  end
  if -1 < lower_floor then
    if min_distance > y - lower_floor_y then
      min_distance = y - lower_floor_y
      return lower_floor, lower_floor_y
    else
      return higher_floor, higher_floor_y
    end
  end
  return higher_floor, higher_floor_y
end
function is_your_player_offline()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  return is_doing_offline(player.Ident)
end
function is_doing_offline(client_ident)
  local game_client = nx_value("game_client")
  local player = game_client:GetSceneObj(nx_string(client_ident))
  local propval = player:QueryProp("LogicState")
  if nx_int(propval) == nx_int(LS_OFFLINEJOB) then
    return true
  end
  return false
end
function can_swim(terrain, role, dx, dy, dz)
  if terrain:GetWalkWaterExists(dx, dz) then
    local water_y = terrain:GetWalkWaterHeight(dx, dz)
    local swim_y = water_y - role.height * 0.5
    if dy < swim_y then
      return true
    end
  end
  return false
end
function can_forward(terrain, role, distance)
  if is_path_finding(role) then
    return true
  end
  local beg_x = role.PositionX
  local beg_y = role.PositionY + role.height * 0.5
  local beg_z = role.PositionZ
  local end_x = role.PositionX + math.sin(role.move_angle) * (distance + MIN_COLLIDE_RADIUS)
  local end_y = beg_y
  local end_z = role.PositionZ + math.cos(role.move_angle) * (distance + MIN_COLLIDE_RADIUS)
  set_track_mask(terrain)
  if terrain:TraceHit(beg_x, beg_y, beg_z, end_x, end_y, end_z) then
    return false
  end
  return true
end
function can_forward2(terrain, role, distance)
  if is_path_finding(role) then
    return true
  end
  local beg_x = role.PositionX
  local beg_y = role.PositionY + role.height * 0.5
  local beg_z = role.PositionZ
  local end_x = role.PositionX + math.sin(role.move_angle) * (distance + MIN_COLLIDE_RADIUS)
  local end_y = beg_y
  local end_z = role.PositionZ + math.cos(role.move_angle) * (distance + MIN_COLLIDE_RADIUS)
  set_track_mask(terrain)
  local game_control = nx_value("game_control")
  if game_control:CanForward(beg_x, beg_y, beg_z, end_x, end_y, end_z) then
    return false
  end
  return true
end
function can_forward_pos(terrain, role, dx, dz)
  if is_path_finding(role) then
    return true
  end
  local sub_x = dx - role.PositionX
  local sub_z = dz - role.PositionZ
  local n_x, n_z = normalize(sub_x, sub_z)
  local beg_x = role.PositionX
  local beg_y = role.PositionY + role.height * 0.5
  local beg_z = role.PositionZ
  local end_x = dx + n_x * MIN_COLLIDE_RADIUS
  local end_y = beg_y
  local end_z = dz + n_z * MIN_COLLIDE_RADIUS
  set_track_mask(terrain)
  if terrain:TraceHit(beg_x, beg_y, beg_z, end_x, end_y, end_z) then
    return false
  end
  return true
end
function can_forward_pos2(terrain, role, dx, dz)
  if is_path_finding(role) then
    return true
  end
  local sub_x = dx - role.PositionX
  local sub_z = dz - role.PositionZ
  local n_x, n_z = normalize(sub_x, sub_z)
  local beg_x = role.PositionX
  local beg_y = role.PositionY + role.height * 0.5
  local beg_z = role.PositionZ
  local end_x = dx + n_x * MIN_COLLIDE_RADIUS
  local end_y = beg_y
  local end_z = dz + n_z * MIN_COLLIDE_RADIUS
  set_track_mask(terrain)
  local game_control = nx_value("game_control")
  if game_control:CanForward(beg_x, beg_y, beg_z, end_x, end_y, end_z) then
    return false
  end
  return true
end
function can_across(terrain, sx, sy, sz, dx, dy, dz)
  if is_path_finding(nil) then
    return true
  end
  local sub_x = dx - sx
  local sub_y = dy - sy
  local sub_z = dz - sz
  local n_x, n_y, n_z = normalize3d(sub_x, sub_y, sub_z)
  local beg_x = sx
  local beg_y = sy
  local beg_z = sz
  local end_x = dx + n_x * MIN_COLLIDE_RADIUS
  local end_y = dy + n_y * MIN_COLLIDE_RADIUS
  local end_z = dz + n_z * MIN_COLLIDE_RADIUS
  set_track_mask(terrain)
  if terrain:TraceHit(beg_x, beg_y, beg_z, end_x, end_y, end_z) then
    return false
  end
  return true
end
function can_dive(terrain, role)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  if game_visual:QueryRoleFloorIndex(role) ~= FLOOR_UNDER_WATER then
    console_log("\206\180\189\248\200\235\203\174\214\208")
    return false
  end
  local terrain_height = terrain:GetFloorHeight(role.PositionX, role.PositionZ, 0)
  local water_height = terrain:GetWalkWaterHeight(role.PositionX, role.PositionZ)
  if water_height - terrain_height > role.height then
    return true
  end
  console_log("\203\228\200\187\194\228\203\174\163\172\181\171\184\223\182\200\178\187\185\187\206\222\183\168\207\194\199\177")
  return false
end
function get_collide_height(terrain, role)
  local x = role.PositionX
  local y = role.PositionY
  local z = role.PositionZ
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return y
  end
  local floor_num = terrain:GetFloorCount(x, z)
  local floor_index = game_visual:QueryRoleFloorIndex(role)
  if floor_num > floor_index then
    if terrain:GetFloorExists(x, z, floor_index) then
      local new_y = terrain:GetFloorHeight(x, z, floor_index)
      if math.abs(new_y - y) > 1 then
      end
      return new_y
    end
  elseif floor_index == FLOOR_AT_WATER and terrain:GetWalkWaterExists(x, z) then
    return terrain:GetWalkWaterHeight(x, z)
  end
  return y
end
function can_fall_point(terrain, role, dest_x, dest_z, old_state)
  local dx = role.PositionX - dest_x
  local dz = role.PositionZ - dest_z
  local x = role.PositionX
  local z = role.PositionZ
  if old_state ~= nil then
    if old_state == "motion" then
      x = dest_x
      z = dest_z
    elseif old_state == "jump" or old_state == "fly" then
    end
  end
  if dx == 0 and dz == 0 then
    local move_angle = nx_execute("player", "get_move_angle", role)
    local dy = role.PositionY
    dx, dy, dz = player_next_pos(role, move_angle, 1, -0.5, dx, dy, dz)
  elseif dx < 0.05 and dz < 0.05 then
    local distance = math.sqrt(dx * dx + dz * dz)
    dx = dx / distance
    dz = dz / distance
  end
  local cur_height = role.PositionY
  if not float_equal(role.floor_height, ERROR_HEIGHT, 0.01, "util_move 426") then
    cur_height = role.floor_height
  end
  while true do
    local floor_num = terrain:GetFloorCount(x, z)
    for i = floor_num - 1, 0, -1 do
      if terrain:GetFloorExists(x, z, i) then
        local floor_y = terrain:GetFloorHeight(x, z, i)
        local floor_space = terrain:GetFloorSpace(x, z, i)
        if cur_height >= floor_y and cur_height + role.height <= floor_y + floor_space then
          local test_center_x = x
          local test_center_z = z
          if terrain:GetFloorCanMove(test_center_x, test_center_z, i) then
            do return test_center_x, test_center_z end
            break
          end
          if terrain:GetWalkWaterExists(test_center_x, test_center_z) then
            local water_y = terrain:GetWalkWaterHeight(test_center_x, test_center_z)
            if floor_y <= water_y then
              return test_center_x, test_center_z
            end
          end
          break
        end
      end
    end
    x = x + dx
    z = z + dz
    if dx == 0 and dz == 0 then
      break
    end
  end
  return x, z
end
function player_next_pos(role, angle, time, dist, x, y, z)
  local ret_x = x
  local ret_y = y
  local ret_z = z
  ret_x = x + math.sin(angle) * dist
  ret_z = z + math.cos(angle) * dist
  return ret_x, ret_y, ret_z
end
function get_walk_enable(terrain, x, z)
  if not nx_is_valid(terrain) then
    return false
  end
  local floor_count = terrain:GetFloorCount(x, z)
  for i = 0, floor_count - 1 do
    if terrain:GetFloorExists(x, z, i) and terrain:GetFloorCanMove(x, z, i) then
      return true
    end
  end
  return false
end
function set_track_mask(terrain)
  terrain:SetTraceMask("Role", true)
  terrain:SetTraceMask("EffectModel", true)
  terrain:SetTraceMask("Sound", true)
  terrain:SetTraceMask("Model", false)
end
function normalize(dx, dz)
  local length = math.sqrt(dx * dx + dz * dz)
  dx = dx / length
  dz = dz / length
  return dx, dz
end
function normalize3d(dx, dy, dz)
  local length = math.sqrt(dx * dx + dy * dy + dz * dz)
  dx = dx / length
  dy = dy / length
  dz = dz / length
  return dx, dy, dz
end
function distance2d(bx, bz, dx, dz)
  return math.sqrt((dx - bx) * (dx - bx) + (dz - bz) * (dz - bz))
end
function distance3d(bx, by, bz, dx, dy, dz)
  return math.sqrt((dx - bx) * (dx - bx) + (dy - by) * (dy - by) + (dz - bz) * (dz - bz))
end
function is_path_finding(visual_player)
  if nil == player then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    visual_player = game_visual:GetPlayer()
  end
  if visual_player.path_finding ~= nil and visual_player.path_finding then
    return true
  end
  return false
end
function get_next_height(terrain, role, dx, dz, step)
  local cur_y = role.PositionY
  local floor_num = terrain:GetFloorCount(dx, dz)
  for i = floor_num - 1, 0, -1 do
    if terrain:GetFloorCanMove(dx, dz, i) then
      local floor_y = terrain:GetFloorHeight(dx, dz, i)
      if floor_y <= cur_y + step and floor_y >= cur_y - step then
        return floor_y
      end
    end
  end
  return nil
end
