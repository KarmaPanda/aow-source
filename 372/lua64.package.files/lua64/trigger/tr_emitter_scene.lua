function on_init(self, para)
  return 1
end
function on_timer(self, seconds, para)
  return 1
end
function on_entry(self, player, para)
  local particle_man = nx_value("particle_man")
  if not nx_is_valid(particle_man) then
    return 0
  end
  local particle = particle_man:CreateFromIni("map\\ini\\particles_scene.ini", nx_string(para))
  if not nx_is_valid(particle) then
    return 0
  end
  particle.Repeat = false
  particle:SetPosition(self.PositionX, self.PositionY, self.PositionZ)
  local terrain = nx_value("terrain")
  terrain:AddVisual("", particle)
  return 1
end
function on_leave(self, player, para)
  return 1
end
