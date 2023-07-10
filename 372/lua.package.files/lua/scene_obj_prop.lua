require("share\\logicstate_define")
require("share\\qinggong_define")
require("util_functions")
require("player_state\\state_input")
require("share\\npc_type_define")
require("define\\team_rec_define")
local life_effect = {
  "life_diaoyu",
  "life_diaoyu1",
  "",
  "",
  "npcitem031",
  "npcitem095",
  "life_tanqin",
  "",
  "life_langtou",
  "",
  "life_liandu",
  "life_lianyao",
  "npcitem126"
}
local ZHENFATYPE_NORMAL = 0
local ZHENFATYPE_JIEBAI = 1
function enter_warning_area()
  nx_pause(1)
  local game_client = nx_value("game_client")
  local client_scene_obj = game_client:GetPlayer()
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetPlayer()
  if not nx_is_valid(client_scene_obj) or not nx_is_valid(visual_scene_obj) then
    return
  end
  local ls = game_visual:QueryRoleLogicState(visual_scene_obj)
  local action_set = ""
  if client_scene_obj:FindProp("ActionSet") then
    action_set = client_scene_obj:QueryProp("ActionSet")
  end
  local weapon_model = ""
  if client_scene_obj:FindProp("Weapon") then
    weapon_model = client_scene_obj:QueryProp("Weapon")
  end
  if weapon_model == "" then
    return
  end
  if ls == LS_WARNING then
    if nx_find_custom(visual_scene_obj, "weapon_pos_type") then
      visual_scene_obj.weapon_pos_type = ""
    end
    nx_execute("role_composite", "refresh_weapon_position", visual_scene_obj)
  end
end
function on_movetype(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if nx_is_valid(visual_scene_obj) then
    emit_player_input(visual_scene_obj, PLAYER_INPUT_LOGIC, LOGIC_MOVE_TYPE_CHANGE)
  end
end
function on_resource(client_scene_obj, prop_name)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  client_scene_obj.tempX = visual_scene_obj.PositionX
  client_scene_obj.tempY = visual_scene_obj.PositionY
  client_scene_obj.tempZ = visual_scene_obj.PositionZ
  local scene = visual_scene_obj.scene
  game_visual:DeleteSceneObj(client_scene_obj.Ident, false)
  if nx_is_valid(visual_scene_obj) then
    scene:Delete(visual_scene_obj)
  end
  nx_execute("stage_main", "show_scene_obj", client_scene_obj.Ident)
end
function on_visprop(client_scene_obj, prop_name)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  if game_visual:QueryRoleClientIdent(visual_scene_obj) == "" then
    game_visual:SetRoleClientIdent(visual_scene_obj, client_scene_obj.Ident)
  end
  if prop_name == "Mount" then
    visual_scene_obj.mount = client_scene_obj:QueryProp("Mount")
  end
  nx_execute("role_composite", "refresh_role_composite", visual_scene_obj, prop_name)
  if prop_name == "Mount" then
    local game_visual = nx_value("game_visual")
    local action_module = nx_value("action_module")
    local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
    local game_client = nx_value("game_client")
    if visual_scene_obj.mount ~= "" then
      if game_client:IsPlayer(client_scene_obj.Ident) then
        if visual_scene_obj.state == "static" or visual_scene_obj.state == "motion" or visual_scene_obj.state == "jump" then
          switch_player_state(visual_scene_obj, "ride_stay", nx_current(), STATE_RIDE_STAY_INDEX)
        elseif visual_scene_obj.state == "swim_stop" or visual_scene_obj.state == "swim" then
          switch_player_state(visual_scene_obj, "ride_swim_stop", nx_current(), STATE_RIDE_SWIM_STOP_INDEX)
        end
      else
        switch_player_state(visual_scene_obj, "be_ride_stay", nx_current(), STATE_BE_RIDE_STAY_INDEX)
      end
    elseif game_client:IsPlayer(client_scene_obj.Ident) then
      if visual_scene_obj.state == "ride_stay" or visual_scene_obj.state == "ride" then
        switch_player_state(visual_scene_obj, "static", nx_current(), STATE_STATIC_INDEX)
      elseif visual_scene_obj.state == "ride_swim_stop" or visual_scene_obj.state == "ride_swim" then
        switch_player_state(visual_scene_obj, "swim_stop", nx_current(), STATE_SWIM_STOP_INDEX)
      end
    else
      switch_player_state(visual_scene_obj, "be_stop", nx_current(), STATE_BE_STOP_INDEX)
    end
  end
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshAll(visual_scene_obj)
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
function on_stall(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local role = visual_scene_obj:GetLinkObject("actor_role")
  local stall_style = client_scene_obj:QueryProp("StallStyle")
  if nx_int(stall_style) == nx_int(1) then
    create_effect("itemnpc509", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(2) then
    create_effect("itemnpc510", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(3) then
    create_effect("itemnpc511", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(4) then
    create_effect("itemnpc512", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(5) then
    create_effect("itemnpc513", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(6) then
    create_effect("itemnpc519", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(7) then
    create_effect("itemnpc520", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(8) then
    create_effect("itemnpc521", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(9) then
    create_effect("itemnpc522", role, role, "", "", "", "", "", true)
  else
    nx_execute("game_effect", "remove_effect", "itemnpc509", role, role)
    nx_execute("game_effect", "remove_effect", "itemnpc510", role, role)
    nx_execute("game_effect", "remove_effect", "itemnpc511", role, role)
    nx_execute("game_effect", "remove_effect", "itemnpc512", role, role)
    nx_execute("game_effect", "remove_effect", "itemnpc513", role, role)
    nx_execute("game_effect", "remove_effect", "itemnpc519", role, role)
    nx_execute("game_effect", "remove_effect", "itemnpc520", role, role)
    nx_execute("game_effect", "remove_effect", "itemnpc521", role, role)
    nx_execute("game_effect", "remove_effect", "itemnpc522", role, role)
  end
end
function on_fortunetelling_stall(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local role = visual_scene_obj:GetLinkObject("actor_role")
  local stall_style = client_scene_obj:QueryProp("FortuneTellingStallStyle")
  nx_execute("game_effect", "remove_effect", "npcitem454", role, role)
  nx_execute("game_effect", "remove_effect", "npcitem455", role, role)
  nx_execute("game_effect", "remove_effect", "npcitem456", role, role)
  nx_execute("game_effect", "remove_effect", "life_gs_06", role, role)
  nx_execute("game_effect", "remove_effect", "life_gs_07", role, role)
  if nx_int(stall_style) == nx_int(1) then
    create_effect("npcitem454", role, role, "", "", "", "", "", true)
    create_effect("npcitem455", role, role, "", "", "", "", "", true)
    create_effect("npcitem456", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(2) then
    create_effect("life_gs_06", role, role, "", "", "", "", "", true)
    create_effect("npcitem455", role, role, "", "", "", "", "", true)
    create_effect("npcitem456", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(3) then
    create_effect("life_gs_07", role, role, "", "", "", "", "", true)
    create_effect("npcitem455", role, role, "", "", "", "", "", true)
    create_effect("npcitem456", role, role, "", "", "", "", "", true)
  elseif nx_int(stall_style) == nx_int(4) then
    create_effect("npcitem454", role, role, "", "", "", "", "", true)
    create_effect("npcitem455", role, role, "", "", "", "", "", true)
    create_effect("npcitem456", role, role, "", "", "", "", "", true)
  end
end
function on_ridespurt(client_scene_obj, prop_name)
  local scene = nx_value("game_scene")
end
function is_in_team(visual_obj)
  if nx_is_valid(visual_obj) then
    if not visual_obj:FindProp("TeamCaptain") then
      return false
    end
    local captainname = visual_obj:QueryProp("TeamCaptain")
    if not nx_ws_equal(nx_widestr(captainname), nx_widestr("")) then
      return true
    else
      return false
    end
  else
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not client_player:FindProp("TeamCaptain") then
      return false
    end
    local captainname = client_player:QueryProp("TeamCaptain")
    if not nx_ws_equal(nx_widestr(captainname), nx_widestr("")) then
      return true
    else
      return false
    end
  end
end
function is_in_pick_member_list(pick_member)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local self_name = client_player:QueryProp("Name")
  if not is_in_team() then
    if nx_ws_equal(nx_widestr(pick_member), nx_widestr(self_name)) then
      return true
    else
      return false
    end
  else
    local member_list = util_split_wstring(nx_widestr(pick_member), ",")
    local member_count = table.getn(member_list)
    if member_count == 0 then
      return false
    end
    for i = 1, member_count do
      if nx_ws_equal(nx_widestr(member_list[i]), nx_widestr(self_name)) then
        return true
      end
    end
    return false
  end
end
function on_change_pick_state(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  visual_scene_obj.canpick = nx_number(client_scene_obj:QueryProp("CanPick")) > 0
  local pick_member = client_scene_obj:QueryProp("PickMember")
  if client_scene_obj:QueryProp("NpcType") == NpcType161 then
    if visual_scene_obj.canpick then
      local effectname = client_scene_obj:QueryProp("BeforeOpenEffect")
      nx_execute("game_effect", "remove_effect", nx_string(effectname), visual_scene_obj, visual_scene_obj)
      local effectname1 = client_scene_obj:QueryProp("AfterOpenEffect")
      create_effect(nx_string(effectname1), visual_scene_obj, visual_scene_obj, "", "", "", "", "", true)
    else
      local effectname = client_scene_obj:QueryProp("AfterOpenEffect")
      nx_execute("game_effect", "remove_effect", nx_string(effectname), visual_scene_obj, visual_scene_obj)
    end
  elseif visual_scene_obj.canpick then
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    local force_enemy = false
    local fight = nx_value("fight")
    if nx_is_valid(fight) then
      force_enemy = fight:ForceCanAttackNpc(client_player, client_scene_obj)
    end
    if force_enemy and is_in_pick_member_list(pick_member) then
      nx_execute("skill_effect", "delay_show_pickup_effect", visual_scene_obj)
    else
      nx_execute("game_effect", "remove_effect", "DeadPickup", visual_scene_obj, visual_scene_obj)
    end
  else
    nx_execute("game_effect", "remove_effect", "DeadPickup", visual_scene_obj, visual_scene_obj)
  end
end
function on_cur_qingqgong(client_scene_obj, prop_name)
  local qg_type = client_scene_obj:QueryProp("CurQingGong")
  local game_client = nx_value("game_client")
  local main_player = game_client:GetPlayer()
  if nx_id_equal(main_player, client_scene_obj) then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  visual_scene_obj.qinggong_type = qg_type
end
function on_speed_ratio(client_scene_obj, prop_name)
  local value = client_scene_obj:QueryProp(prop_name)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  local speedadd = value / 100
  visual_scene_obj.Speed = 1 + speedadd
end
function on_lifetooleffect(client_scene_obj, prop_name)
  local ToolEffect = client_scene_obj:QueryProp(prop_name)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local role = visual_scene_obj:GetLinkObject("actor_role")
  if nx_find_custom(visual_scene_obj, "old_lifetool") then
    nx_execute("game_effect", "remove_effect", nx_string(visual_scene_obj.old_lifetool), role, role)
  end
  if ToolEffect == "" or ToolEffect == nil then
    if client_scene_obj:FindProp("Weapon") then
      local weapon_name = client_scene_obj:QueryProp("Weapon")
      game_visual:SetRoleWeaponName(visual_scene_obj, nx_string(weapon_name))
    end
  else
    visual_scene_obj.old_weapon_name = ""
    game_visual:SetRoleWeaponName(visual_scene_obj, "")
    create_effect(nx_string(ToolEffect), role, role, "", "", "", "", "", true)
    visual_scene_obj.old_lifetool = ToolEffect
  end
end
function refresh_lifejobtool(actor2, client_scene_obj, prop_name)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local value = client_scene_obj:QueryProp(prop_name)
  local role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(role) then
    return
  end
  for i = 1, table.getn(life_effect) do
    nx_execute("game_effect", "remove_effect", life_effect[i], role, role)
  end
  local game_visual = nx_value("game_visual")
  if value == 0 then
    if client_scene_obj:FindProp("Weapon") then
      local weapon_name = client_scene_obj:QueryProp("Weapon")
      game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
    end
  else
    game_visual:SetRoleWeaponName(actor2, "")
    local effect_name = life_effect[value]
    create_effect(effect_name, role, role, "", "", "", "", "", true)
  end
end
function on_cantmovechange(client_scene_obj, prop_name)
  local value = client_scene_obj:QueryProp(prop_name)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local visual_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_obj) then
    return
  end
  local is_main_player = game_client:IsPlayer(client_scene_obj.Ident)
  if 0 < value and is_main_player then
    nx_function("ext_clear_v_h_orient")
    game_visual:EmitPlayerInput(visual_obj, PLAYER_INPUT_END_MOVE)
    visual_obj.self_cantmove = 0
  end
end
function on_scalechange(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local scale = client_scene_obj:QueryProp("Scale")
  if scale ~= 0 and scale ~= "" and scale ~= nil then
    local scalelist = util_split_string(scale, ",")
    local scale_x = nx_float(scalelist[1])
    local scale_y = nx_float(scalelist[2])
    local scale_z = nx_float(scalelist[3])
    if 0 < nx_number(scale_x) and 0 < nx_number(scale_y) and 0 < nx_number(scale_z) then
      visual_target:SetScale(nx_float(scale_x), nx_float(scale_y), nx_float(scale_z))
    else
      visual_target:SetScale(1, 1, 1)
    end
  else
    visual_target:SetScale(1, 1, 1)
  end
  local x, y, z = visual_target.PositionX, visual_target.PositionY, visual_target.PositionZ
  local scene = visual_target.scene
  local terrain = scene.terrain
end
function on_rotate_change(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local rotate = client_scene_obj:QueryProp("RotatePara")
  if rotate ~= 0 and rotate ~= "" and rotate ~= nil then
    local rlist = util_split_string(rotate, ",")
    local r_x = nx_float(rlist[1])
    local r_y = nx_float(rlist[2])
    local r_z = nx_float(rlist[3])
    visual_target:SetAngle(nx_float(r_x), nx_float(r_y), nx_float(r_z))
  end
  local x, y, z = visual_target.PositionX, visual_target.PositionY, visual_target.PositionZ
  local scene = visual_target.scene
  local terrain = scene.terrain
end
function on_ai_effect_change(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local cur_effect = client_scene_obj:QueryProp("AIEffect")
  local old_effect = ""
  if nx_find_custom(visual_scene_obj, "effect_name") then
    old_effect = visual_scene_obj.effect_name
  end
  local bOldHave, bNowHave
  if old_effect ~= "" and old_effect ~= "0" and old_effect ~= nil and old_effect ~= "nil" then
    bOldHave = true
  end
  if cur_effect ~= "" and cur_effect ~= "0" and cur_effect ~= nil and cur_effect ~= "nil" then
    bNowHave = true
  end
  if cur_effect == old_effect then
    return
  end
  if not bOldHave and bNowHave then
    auto_show_hide_effect(client_scene_obj, cur_effect, true)
    visual_scene_obj.effect_name = cur_effect
  elseif bOldHave and not bNowHave then
    auto_show_hide_effect(client_scene_obj, old_effect, nil)
    visual_scene_obj.effect_name = ""
  elseif bOldHave and bNowHave then
    auto_show_hide_effect(client_scene_obj, old_effect, nil)
    auto_show_hide_effect(client_scene_obj, cur_effect, true)
    visual_scene_obj.effect_name = cur_effect
  end
end
function auto_show_hide_effect(client_scene_obj, effect_name, b_show)
  local effect_list = util_split_string(effect_name, ";")
  if b_show then
    for i = 1, table.getn(effect_list) do
      nx_execute("custom_effect", "custom_effect_offline_ai", client_scene_obj.Ident, effect_list[i], 1)
    end
  else
    for i = 1, table.getn(effect_list) do
      nx_execute("custom_effect", "custom_effect_offline_ai", client_scene_obj.Ident, effect_list[i], 0)
    end
  end
end
function on_special_prop_id_change(client_scene_obj, prop_name)
  local special_prop_id = client_scene_obj:QueryProp("SpecialPropID")
  nx_execute("form_stage_main\\npc_special_add_prop", "on_special_id_change", client_scene_obj, special_prop_id)
end
function on_gravity_change(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local gravity = client_scene_obj:QueryProp(prop_name)
  local visual_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if nx_is_valid(visual_obj) then
    visual_obj.gravity = gravity
  end
end
function on_link_obj_change(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local link_obj = client_scene_obj:QueryProp("LinkObj")
  if nx_string(link_obj) ~= "0-0" then
    local parent_obj = game_visual:GetSceneObj(nx_string(link_obj))
    if not nx_is_valid(parent_obj) then
      return false
    else
      local visual_self = game_visual:GetSceneObj(nx_string(client_scene_obj.Ident))
      if nx_is_valid(visual_self) then
        local state_index = game_visual:QueryRoleStateIndex(visual_self)
        if state_index ~= STATE_LINK_MOTION_INDEX and state_index ~= STATE_LINK_STOP_INDEX then
          local link_manager = nx_value("link_manager")
          if nx_is_valid(link_manager) and link_manager:FindChild(client_scene_obj.Ident) then
            local link_item = link_manager:GetChild(client_scene_obj.Ident)
            local npc_type = game_visual:QueryRoleNpcType(parent_obj)
            if npc_type == NpcType48 then
            end
          else
            local game_client = nx_value("game_client")
            local parent_net = game_client:GetSceneObj(nx_string(link_obj))
            local stand_height = parent_net:QueryProp("StandHeight")
            local npc_type = game_visual:QueryRoleNpcType(parent_obj)
            if npc_type == NpcType48 then
              nx_call("link", "link_to_float_area", client_scene_obj.Ident, nx_string(link_obj), 0, stand_height, 0, 0)
            end
          end
        end
      else
        nx_execute("stage_main", "show_scene_obj", client_scene_obj.Ident)
      end
    end
  else
    local self_visual = game_visual:GetSceneObj(client_scene_obj.Ident)
    if not nx_is_valid(self_visual) then
      nx_execute("stage_main", "show_scene_obj", client_scene_obj.Ident)
    end
  end
end
function on_cur_zhanfa_map(client_scene_obj, prop_name)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local zhenfa_map = client_scene_obj:QueryProp(prop_name)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  if zhenfa_map == 0 then
    local zhenfa_id = client_scene_obj:QueryProp("BelongZhenFa")
    emit_player_input(visual_scene_obj, PLAYER_INPUT_LOGIC, LOGIC_END_ZHENFA, zhenfa_id ~= 0 and zhenfa_id ~= "")
    nx_execute("custom_effect", "custom_effect_del_zhenfamap", client_scene_obj)
  else
    if game_client:IsPlayer(client_scene_obj.Ident) then
      nx_execute("util_sound", "play_link_sound", "fight_formation_begin.wav", nx_value("role"), 0, 0, 0, 1, 5, 1, "snd\\action\\fight\\other\\")
    end
    if is_team_captain_or_assist(client_scene_obj) then
      visual_scene_obj.delay_zhenfa_map = true
    else
      visual_scene_obj.delay_zhenfa_map = false
    end
  end
end
function is_team_captain_or_assist(target)
  if not nx_is_valid(target) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  local team_id = player:QueryProp("TeamID")
  if team_id < 0 then
    return false
  end
  local leader_name = player:QueryProp("TeamCaptain")
  local target_name = target:QueryProp("Name")
  if nx_string(leader_name) == nx_string(target_name) then
    return true
  end
  if player:FindRecord("team_rec") then
    local row = player:FindRecordRow("team_rec", TEAM_REC_COL_NAME, target_name)
    if 0 <= row then
      local work = player:QueryRecord("team_rec", row, TEAM_REC_COL_TEAMWORK)
      if work == 2 then
        return true
      end
    end
  end
  return false
end
function on_zhenfa_effect(client_scene_obj, prop_name)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local role = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(role) then
    return
  end
  local zhenfa_id = client_scene_obj:QueryProp("BelongZhenFa")
  local zhenfa_type = 0
  zhenfa_type = nx_execute("util_static_data", "zhenfa_static_query_by_id", nx_string(zhenfa_id), "ZhenFaType")
  local cur_zhenfa_effect = client_scene_obj:QueryProp(prop_name)
  if nx_string(cur_zhenfa_effect) ~= "" then
    local b_is_player = game_client:IsPlayer(client_scene_obj.Ident)
    local row = client_player:FindRecordRow("team_rec", TEAM_REC_COL_NAME, nx_widestr(client_scene_obj:QueryProp("Name")))
    local b_is_teammate = 0 <= row
    if not b_is_player and not b_is_teammate and nx_int(ZHENFATYPE_NORMAL) == nx_int(zhenfa_type) then
      return
    end
    if nx_int(ZHENFATYPE_JIEBAI) == nx_int(zhenfa_type) and nx_int(1) == nx_int(client_player:QueryProp("TeamType")) then
      local self_row = client_player:FindRecordRow("team_rec", TEAM_REC_COL_NAME, nx_widestr(client_player:QueryProp("Name")))
      local self_position = client_player:QueryRecord("team_rec", self_row, TEAM_REC_COL_TEAMPOSITION)
      local target_position = client_player:QueryRecord("team_rec", row, TEAM_REC_COL_TEAMPOSITION)
      if nx_int(target_position / 10) ~= nx_int(self_position / 10) then
        b_is_teammate = false
      end
    end
    if b_is_player then
      nx_execute("util_sound", "play_link_sound", "fight_formation_cast_successful.wav", nx_value("role"), 0, 0, 0, 1, 5, 1, "snd\\action\\fight\\other\\")
    end
    local leader_name = client_scene_obj:QueryProp("TeamCaptain")
    local self_name = client_scene_obj:QueryProp("Name")
    local effect_color = ""
    local range_effect = ""
    local range_color = ""
    local zhenfa_effect = ""
    local zhenfa_once_effect = ""
    local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\zhenfa_effect.ini")
    if nx_is_valid(ini) then
      local sec_index = ini:FindSectionIndex(nx_string(zhenfa_id))
      if 0 <= sec_index then
        range_effect = ini:ReadString(sec_index, "ZhenFaRangeEffect", "")
        range_color = ini:ReadString(sec_index, "ZhenFaRangeColor", "")
        effect_color = ini:ReadString(sec_index, "ZhenFaFollowColor", "")
        zhenfa_effect = ini:ReadString(sec_index, "ZhenFaEffect", cur_zhenfa_effect)
        zhenfa_once_effect = ini:ReadString(sec_index, "ZhenFaOnceEffect", "battleform_effect_1b")
      end
    end
    if not b_is_teammate and nx_int(ZHENFATYPE_JIEBAI) == nx_int(zhenfa_type) then
      effect_color = "255,235,222,254"
    end
    if nx_string(zhenfa_effect) == "" then
      return
    end
    if nx_string(client_scene_obj:QueryProp("CurZhenFaID")) == zhenfa_id then
      local range = nx_number(client_scene_obj:QueryProp("CurZhenFaRange")) * 2
      if range <= 0 then
        range = 1
      end
      if not b_is_teammate and nx_int(ZHENFATYPE_JIEBAI) == nx_int(zhenfa_type) and not b_is_player then
        nx_execute("custom_effect", "custom_effect_add_zhenfa_effect", client_scene_obj, role, zhenfa_effect, zhenfa_once_effect, effect_color)
      else
        nx_execute("custom_effect", "custom_effect_add_zhenfa_effect", client_scene_obj, role, zhenfa_effect, zhenfa_once_effect, effect_color, range_effect, range, range_color)
      end
    else
      nx_execute("custom_effect", "custom_effect_add_zhenfa_effect", client_scene_obj, role, zhenfa_effect, zhenfa_once_effect, effect_color)
    end
  else
    if game_client:IsPlayer(client_scene_obj.Ident) then
      nx_execute("util_sound", "play_link_sound", "fight_formation_end.wav", nx_value("role"), 0, 0, 0, 1, 5, 1, "snd\\action\\fight\\other\\")
    end
    nx_execute("custom_effect", "custom_effect_del_zhenfa_effect", client_scene_obj, role)
  end
end
function on_shaqi(client_scene_obj, prop_name)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local role = visual_scene_obj:GetLinkObject("actor_role")
  local shaqi = client_scene_obj:QueryProp("ShaQi")
  if not nx_find_custom(visual_scene_obj, "shaqi_effect") then
    visual_scene_obj.shaqi_effect = ""
  end
  if nx_int(shaqi) >= nx_int(500) then
    if nx_string(visual_scene_obj.shaqi_effect) ~= nx_string("pvp_effect_01") then
      if visual_scene_obj.shaqi_effect ~= "" then
        nx_execute("game_effect", "remove_effect", nx_string(visual_scene_obj.shaqi_effect), role, role)
      end
      create_effect("pvp_effect_01", role, role, "", "", "", "", "", true)
      visual_scene_obj.shaqi_effect = "pvp_effect_01"
    end
  else
    if visual_scene_obj.shaqi_effect ~= "" then
      nx_execute("game_effect", "remove_effect", nx_string(visual_scene_obj.shaqi_effect), role, role)
    end
    visual_scene_obj.shaqi_effect = ""
  end
end
local cant_see_player_list = {}
function add_player_hide_list(visual_obj)
  if nx_is_valid(visual_obj) then
    visual_obj.Visible = false
    table.insert(cant_see_player_list, visual_obj)
  end
end
function show_hide_player_list()
  local b_show_player = not game_visual.HidePlayer
  for i = 1, table.getn(cant_see_player_list) do
    local visual_obj = cant_see_player_list[i]
    if nx_is_valid(visual_obj) and b_show_player then
      visual_obj.Visible = true
    end
  end
  cant_see_player_list = {}
  nx_function("ext_hide_player_F9")
  nx_function("ext_hide_no_attack_player")
end
