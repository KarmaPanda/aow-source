NPC_ANI_EVENT_HEAD = "npc_fight_ani_"
function play_npc_ani(npc_ani, npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if npc_ani == "" or npc_ani == nil then
    return
  end
  nx_execute("npc_animation", "play_fight_ent_ani", nx_string(npc_ani))
  if npc then
    local res = nx_wait_event(30, nx_null(), NPC_ANI_EVENT_HEAD .. nx_string(npc_ani))
    nx_execute("custom_sender", "custom_send_fight_ent_ani_end", nx_string(npc_ani), nx_string(npc))
  end
end
function close_npc_ani()
  local scenario_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_manager) then
    scenario_manager:StopScenarioImmediately()
  end
end
function play_end_notice(file_name)
  if file_name == nil or file_name == "" then
    return
  end
  local ani_name = ""
  ani_name = string.gsub(file_name, nx_string(nx_resource_path() .. "ini\\Scenario\\"), "")
  ani_name = string.gsub(ani_name, ".ini", "")
  nx_gen_event(nx_null(), NPC_ANI_EVENT_HEAD .. nx_string(ani_name), "true")
end
function clear_npc_ani(npc_ani)
end
function npc_ani_begin_callback(file_name, action_index)
end
function npc_ani_end_callback(file_name, action_index)
end
function play_fight_ent_ani(ani_name)
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(scenario_npc_manager) then
    return
  end
  scenario_npc_manager:PlayScenario(nx_resource_path() .. "ini\\Scenario\\" .. nx_string(ani_name) .. ".ini")
end
