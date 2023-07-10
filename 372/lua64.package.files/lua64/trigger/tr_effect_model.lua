function on_init(self, para)
  return 1
end
function on_timer(self, seconds, para)
  return 1
end
function on_entry(self, player, para)
  local scene = nx_value("scene")
  local effect = scene:Create("EffectModel")
  if not nx_is_valid(effect) then
    return 0
  end
  if not effect:CreateFromIniEx("map\\ini\\particles_mdl.ini", nx_string(para), true, "map\\") then
    scene:Delete(effect)
    return 0
  end
  effect.Loop = false
  effect:SetPosition(self.PositionX, self.PositionY, self.PositionZ)
  local terrain = nx_value("terrain")
  terrain:AddVisual("", effect)
  return 1
end
function on_leave(self, player, para)
  return 1
end
