function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function skill_effect_init(skill_effect)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local action_module = nx_value("action_module")
  skill_effect.GameClient = game_client
  skill_effect.GameVisual = game_visual
  skill_effect.Action = action_module
end
function play_hurt_sound(vis_src, visual_target, bva)
  if bva then
    nx_call("util_sound", "play_link_sound", "1", visual_target, 0, 0, 0)
  else
    nx_call("util_sound", "play_link_sound", "2", visual_target, 0, 0, 0)
  end
end
function play_zhaoshi(role, zhaoshi_name, btranslate)
  if btranslate == nil then
    btranslate = true
  end
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) then
    skill_effect:PlayZhaoshi(role, zhaoshi_name, btranslate, 0)
  end
  return true
end
function play_skill_action(role, action)
  nx_pause(0.1)
  if not nx_is_valid(role) then
    return
  end
  if nx_running(nx_current(), "play_zhaoshi", role) then
    nx_kill(nx_current(), "play_zhaoshi", role)
  end
  if not play_zhaoshi(role, action, false) then
    local action_module = nx_value("action_module")
    local full_action = action_module:DoAction(role, action)
  end
end
function create_effect(effect_name, self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
  if effect_name == nil or nx_string(effect_name) == nx_string("") or nx_string(effect_name) == nx_string("nil") then
    return false
  end
  if not nx_is_valid(self) then
    return false
  end
  local scene = self.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect) then
    return false
  end
  if not nx_is_valid(game_effect.Scene) then
    game_effect.Scene = scene
  end
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  return game_effect:CreateEffect(nx_string(effect_name), self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
end
function delay_show_pickup_effect(actor)
  nx_pause(2)
  if nx_is_valid(actor) and nx_find_custom(actor, "canpick") and actor.canpick then
    create_effect("DeadPickup", actor, actor, "DeadEffect", "", "", "", "", true)
  end
end
