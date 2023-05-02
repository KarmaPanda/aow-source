require("util_functions")
require("share\\logicstate_define")
require("form_stage_main\\form_offline\\offline_define")
function is_offline(target)
  if is_doing_offline_job(target) or is_doing_offline_trustee(target) then
    return true
  end
  return false
end
function is_doing_offline_job(target)
  local logic_state = target:QueryProp("LogicState")
  local step = target:QueryProp("OfflineJobStep")
  if nx_int(logic_state) == nx_int(LS_OFFLINEJOB) and step == 2 then
    return true
  end
  return false
end
function is_doing_offline_trustee(target)
  local logic_state = target:QueryProp("LogicState")
  if nx_number(logic_state) == nx_number(LS_OFFLINE_WUXUE) then
    return true
  end
  return false
end
function is_doing_offline_stall(target)
  local logic_state = target:QueryProp("LogicState")
  if nx_number(logic_state) == nx_number(LS_OFFLINE_STALL) then
    return true
  end
  return false
end
function is_life_job_server(target)
  if not target:FindProp("LifeServer") then
    return false
  end
  local flag_server = target:QueryProp("LifeServer")
  if nx_number(flag_server) > nx_number(1) then
    return true
  end
  return false
end
function get_fee_type(target)
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return 0
  end
  if not target:FindProp("OfflineJobId") then
    return 0
  end
  local off_id = target:QueryProp("OfflineJobId")
  if nx_string(off_id) == "" then
    return 0
  end
  local fee_type = offmgr:GetOffLineJobProp(off_id, "FeeType")
  if nx_number(fee_type) == nx_number(1) or nx_number(fee_type) == nx_number(2) or nx_number(fee_type) == nx_number(3) or nx_number(fee_type) == nx_number(4) or nx_number(fee_type) == nx_number(5) then
    return nx_number(fee_type)
  end
  return 0
end
function set_offlinejob_effect(visual_scene_obj)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(visual_scene_obj)
  local client_scene_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  if client_scene_obj:FindProp("AIEffect") and client_scene_obj:FindProp("LogicState") then
    local cur_effect = client_scene_obj:QueryProp("AIEffect")
    local logic_state = client_scene_obj:QueryProp("LogicState")
    if string.len(cur_effect) > 0 and nx_number(logic_state) == 106 then
      nx_execute("scene_obj_prop", "auto_show_hide_effect", client_scene_obj, cur_effect, true)
      visual_scene_obj.effect_name = cur_effect
    end
  end
end
function player_offline()
  nx_execute("main", "direct_exit_game")
end
function get_setfree_money_by_level(target)
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return 0
  end
  local type = target:QueryProp("Type")
  if nx_number(type) ~= 2 then
    return 0
  end
  local level = target:QueryProp("PowerLevel")
  if nx_number(level) > nx_number(60) then
    level = 60
  end
  if nx_number(level) < nx_number(0) then
    level = 0
  end
  return offmgr:GetConfigByLevel(nx_int(level))
end
function is_book_keeper(target)
  if not target:FindProp("OfflineTypeTvT") then
    return false
  end
  local type = target:QueryProp("OfflineTypeTvT")
  if nx_number(type) == nx_number(6) then
    return true
  end
  return false
end
function is_doing_poke(target)
  if not target:FindProp("OfflineTypeTvT") then
    return false
  end
  local type = target:QueryProp("OfflineTypeTvT")
  if nx_number(type) == nx_number(4) or nx_number(type) == nx_number(5) then
    return true
  end
  return false
end
function is_abducted(target)
  if target:FindProp("IsAbducted") and nx_number(target:QueryProp("IsAbducted")) > nx_number(0) then
    return true
  end
  return false
end
