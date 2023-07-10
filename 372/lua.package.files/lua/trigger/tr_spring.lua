function on_init(self, para)
  return 1
end
function on_timer(self, seconds, para)
  return 1
end
function play_random_action(actor)
  if not nx_is_valid(actor) then
    return false
  end
  local actions = actor:GetActionList()
  local action_num = table.getn(actions)
  if action_num < 2 then
    return false
  end
  local rand = math.random(1, action_num)
  local action = actions[rand]
  if action == "stand" then
    if rand == 1 then
      action = actions[action_num]
    else
      action = actions[rand - 1]
    end
  end
  actor:BlendAction(action, false, true)
  local action_len = actor:GetActionSeconds(action)
  local tick = nx_time_begin()
  while action_len > nx_time_elapse(tick) do
    nx_pause(0)
    if not nx_is_valid(actor) then
      return false
    end
  end
  actor:BlendAction("stand", true, true)
  return true
end
function on_entry(self, player, para)
  local terrain = nx_value("terrain")
  local beg_x = self.PositionX - self.SizeX * 0.5
  local beg_z = self.PositionZ - self.SizeZ * 0.5
  local end_x = self.PositionX + self.SizeX * 0.5
  local end_z = self.PositionZ + self.SizeZ * 0.5
  local actor_table = terrain:GetNearActorList(beg_x, beg_z, end_x, end_z)
  for i = 1, table.getn(actor_table) do
    local actor = actor_table[i]
    if nx_name(actor) == "Actor2" and not nx_running(nx_current(), "play_random_action", actor) then
      nx_execute(nx_current(), "play_random_action", actor)
    end
  end
  return 1
end
function on_leave(self, player, para)
  return 1
end
