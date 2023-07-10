require("const_define")
require("player_state\\state_const")
require("player_state\\logic_const")
require("role_composite")
require("share\\npc_type_define")
require("form_stage_main\\form_main\\form_main_shortcut_trans")
function console_log(info)
  console_log2(info)
end
function console_log2(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function get_player_bind(link_ident, ident)
  local game_client = nx_value("game_client")
  local target_obj = game_client:GetSceneObj(link_ident)
  local role_obj = game_client:GetSceneObj(ident)
  if not nx_is_valid(target_obj) or not nx_is_valid(role_obj) then
    return ""
  end
  local name = role_obj:QueryProp("Name")
  local link_point = role_obj:QueryProp("BindRoleSitus")
  link_point = nx_string(link_point)
  return link_point
end
function get_role_binds(link_ident)
  local points = {}
  local game_client = nx_value("game_client")
  local target_obj = game_client:GetSceneObj(link_ident)
  if not nx_is_valid(target_obj) then
    return points
  end
  local npc_type = target_obj:QueryProp("SubType")
  local situs = target_obj:QueryProp("BindRoleSitus")
  if npc_type ~= 0 then
    for r = 1, 6 do
      local pos = "boat::" .. r
      if nx_string(situs) ~= nx_string(pos) then
        table.insert(points, nx_string(pos))
      end
    end
  else
    for r = 1, 6 do
      local pos = "mount::" .. r
      if nx_string(situs) ~= nx_string(pos) then
        table.insert(points, nx_string(pos))
      end
    end
  end
  return points
end
function show_scene_obj(ident)
  local scene_obj = nx_value("scene_obj")
  if nx_is_valid(scene_obj) then
    scene_obj:ShowSceneObj(ident)
    return true
  end
  return false
end
function link_to(ident, link_ident)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_visual) then
    return false
  end
  if not nx_is_valid(game_client) then
    return false
  end
  while true do
    nx_pause(0)
    if game_client.ready then
      break
    end
  end
  while true do
    nx_pause(0)
    if not nx_is_valid(game_visual) then
      return false
    end
    if not nx_is_valid(game_client) then
      return false
    end
    local vis_role = game_visual:GetSceneObj(ident)
    local vis_target = game_visual:GetSceneObj(link_ident)
    local role_obj = game_client:GetSceneObj(ident)
    local target_obj = game_client:GetSceneObj(link_ident)
    if not nx_is_valid(vis_target) and not nx_is_valid(vis_role) and not nx_is_valid(role_obj) and not nx_is_valid(target_obj) then
      return false
    end
    if not nx_is_valid(vis_role) then
      show_scene_obj(ident)
      vis_role = game_visual:GetSceneObj(ident)
    end
    if not nx_is_valid(vis_target) then
      show_scene_obj(link_ident)
      vis_target = game_visual:GetSceneObj(link_ident)
    end
    local vis_target_create_finish = game_visual:QueryRoleCreateFinish(vis_target)
    local vis_role_create_finish = game_visual:QueryRoleCreateFinish(vis_role)
    if nx_is_valid(vis_target) and nx_is_valid(vis_role) and nx_is_valid(role_obj) and nx_is_valid(target_obj) and vis_target_create_finish and vis_role_create_finish then
      local scene = vis_target.scene
      local terrain = scene.terrain
      while true do
        nx_pause(0)
        if terrain.LoadFinish then
          break
        end
      end
      if not nx_is_valid(role_obj) then
        return false
      end
      local name = role_obj:QueryProp("Name")
      if not nx_is_valid(target_obj) then
        return false
      end
      if not target_obj:FindProp("BindRoleSitus") then
        return false
      end
      local link_point = target_obj:QueryProp("BindRoleSitus")
      role_obj.vislink = vis_target
      role_obj.linkname = "chair"
      if not nx_is_valid(vis_target) then
        return false
      end
      if not nx_is_valid(role_obj) then
        return false
      end
      if not nx_is_valid(vis_role) then
        return false
      end
      vis_target:LinkToPoint(role_obj.linkname, link_point, vis_role)
      local npc_type = target_obj:QueryProp("SubType")
      if npc_type ~= 0 then
        vis_target:SetLinkAngle(role_obj.linkname, 0, math.pi, 0)
      end
      vis_target:SetLinkPosition(role_obj.linkname, 0, -0.1, 0)
      vis_target.linkfinish = 1
      local action_module = nx_value("action_module")
      if game_client:IsPlayer(ident) then
        action_module:ChangeState(vis_role, "sitdown", true)
        switch_player_state(vis_role, "trans", nx_current(), STATE_TRANS_INDEX)
        switch_player_state(vis_target, "trans", nx_current(), STATE_TRANS_INDEX)
      else
        action_module:ChangeState(vis_role, "sitdown", true)
      end
      game_visual:SetRoleMoveSpeed(vis_target, target_obj.MoveSpeed)
      vis_target.rotate_speed = target_obj.RotateSpeed
      vis_target.move_dest_orient = target_obj.DestOrient
      local scene = vis_target.scene
      if not nx_is_valid(scene) then
        scene = nx_value("game_scene")
      end
      local terrain = scene.terrain
      if not nx_is_valid(scene.terrain) then
        terrain = nx_value("terrain")
      end
      terrain:RemoveVisual(vis_role)
      if nx_is_valid(vis_role) then
        vis_role.Visible = true
      end
      local cur_player_obj = game_client:GetPlayer()
      if nx_id_equal(cur_player_obj, role_obj) and role_obj:FindProp("OnTransToolState") then
        local trans_tool_state = role_obj:QueryProp("OnTransToolState")
        if 0 < trans_tool_state then
          local dialog = "form_stage_main\\form_main\\form_main_shortcut_trans"
          if not nx_is_valid(dialog) then
            show_off_trans_form(npc_type)
          end
        end
      end
      break
    end
  end
  return true
end
function unlink(ident)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 1
  end
  local vis_role = game_visual:GetSceneObj(ident)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 1
  end
  local role_obj = game_client:GetSceneObj(ident)
  if not nx_is_valid(vis_role) then
    return 1
  end
  if not nx_is_valid(role_obj) then
    return 1
  end
  vis_role.Visible = true
  if not nx_find_custom(role_obj, "vislink") then
    return 1
  end
  local vis_target = role_obj.vislink
  if not nx_is_valid(vis_target) then
    return 1
  end
  nx_execute("util_sound", "del_sound", vis_target)
  if nx_find_custom(vis_target, "switch") and vis_target.switch == 1 then
    return
  end
  local linkname = role_obj.linkname
  vis_target:UnLink(linkname, false)
  vis_target.linkfinish = 0
  local scene = vis_target.scene
  local terrain = scene.terrain
  local dest_x = vis_target.PositionX
  local dest_y = vis_target.PositionY
  local dest_z = vis_target.PositionZ
  game_visual:SetRoleMoveDestX(vis_role, dest_x)
  game_visual:SetRoleMoveDestY(vis_role, dest_y)
  game_visual:SetRoleMoveDestZ(vis_role, dest_z)
  vis_role.move_dest_orient = role_obj.DestOrient
  vis_role:SetPosition(dest_x, dest_y, dest_z)
  terrain:AddVisualRole("", vis_role)
  vis_role:SetAngle(0, vis_role.move_dest_orient, 0)
  local scene_obj = nx_value("scene_obj")
  scene_obj:LocatePlayer(vis_role, dest_x, dest_y, dest_z, role_obj.DestOrient)
  local role = vis_role:GetLinkObject("actor_role")
  role.Speed = 1
  role_obj.vislink = nx_null()
  role_obj.linkname = ""
  vis_role.server_pos_can_accept = true
  local action_module = nx_value("action_module")
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if game_client:IsPlayer(ident) then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_main_shortcut_trans", false)
    local in_water = is_in_water(vis_role.PositionX, vis_role.PositionY, vis_role.PositionZ)
    if in_water == 0 then
      action_module:ChangeState(vis_role, "stand", true)
      switch_player_state(vis_role, "static", nx_current(), STATE_STATIC_INDEX)
    elseif in_water == 2 then
      local water_y = terrain:GetWalkWaterHeight(vis_role.PositionX, vis_role.PositionZ)
      local set_y = water_y - 0.9
      locate_obj(terrain, vis_role, vis_role.PositionX, set_y, vis_role.PositionZ)
      switch_player_state(vis_role, "swim_stop", nx_current(), STATE_SWIM_STOP_INDEX)
    end
  else
    action_module:ChangeState(vis_role, "stand", true)
    switch_player_state(vis_role, "be_stop", nx_current(), STATE_BE_STOP_INDEX)
  end
end
function clear_link(ident)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local vis_obj = game_visual:GetSceneObj(ident)
  local obj = game_client:GetSceneObj(ident)
  if not nx_is_valid(vis_obj) then
    return
  end
  if not nx_is_valid(obj) then
    return
  end
  local linkname = "chair"
  vis_obj:UnLink(linkname, false)
  return
end
function link_driver(ident)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local vis_target = game_visual:GetSceneObj(ident)
  local obj_target = game_client:GetSceneObj(ident)
  while true do
    nx_pause(0)
    if not nx_is_valid(game_visual) then
      return
    end
    if not nx_is_valid(game_client) then
      return
    end
    vis_target = game_visual:GetSceneObj(ident)
    obj_target = game_client:GetSceneObj(ident)
    if not nx_is_valid(obj_target) then
      break
    end
    if nx_is_valid(vis_target) and vis_target.LoadFinish then
      break
    end
  end
  local world = nx_value("world")
  if not nx_is_valid(vis_target) then
    return
  end
  if not nx_is_valid(obj_target) then
    return
  end
  if obj_target:QueryProp("NpcType") == NpcType45 then
    local world = nx_value("world")
    local scene = world.MainScene
    actor2 = nx_execute("role_composite", "create_actor2", scene)
    if not nx_is_valid(actor2) then
      return 0
    end
    actor2.AsyncLoad = false
    local res_name = obj_target:QueryProp("Driver")
    local result = load_from_ini(actor2, res_name)
    if not result then
      scene:Delete(actor2)
      return nx_null()
    end
    local id = ""
    local npc_type = obj_target:QueryProp("SubType")
    if npc_type ~= 0 then
      vis_target:LinkToPoint("driver", "boat::7", actor2)
      vis_target:SetLinkAngle("driver", 0, math.pi, 0)
      id = "boat"
    else
      vis_target:LinkToPoint("driver", "mount::7", actor2)
      id = "mount"
    end
    vis_target.jy_link_driver = actor2
    if nx_find_custom(vis_target, "npc_index") and vis_target.npc_index == 1 then
      nx_execute(nx_current(), "Jy_npc_talk", actor2, id)
      nx_execute(nx_current(), "Jy_npc_talk_hide", actor2)
    end
  end
end
function link_npc(ident, point, id, name)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_visual) then
    return
  end
  if not nx_is_valid(game_client) then
    return
  end
  local vis_target = game_visual:GetSceneObj(ident)
  local obj_target = game_client:GetSceneObj(ident)
  while true do
    nx_pause(0)
    vis_target = game_visual:GetSceneObj(ident)
    obj_target = game_client:GetSceneObj(ident)
    if not nx_is_valid(obj_target) then
      break
    end
    if nx_is_valid(vis_target) and vis_target.LoadFinish then
      break
    end
  end
  local world = nx_value("world")
  if not nx_is_valid(vis_target) then
    return
  end
  if not nx_is_valid(obj_target) then
    return
  end
  if obj_target:QueryProp("NpcType") == NpcType45 then
    local world = nx_value("world")
    local scene = world.MainScene
    local actor2 = nx_execute("role_composite", "create_actor2", scene)
    if not nx_is_valid(actor2) then
      return 0
    end
    actor2.AsyncLoad = false
    res_name = "ini\\npc\\" .. id .. ".ini"
    local result = load_from_ini(actor2, res_name)
    if not result then
      scene:Delete(actor2)
      return nx_null()
    end
    local ini = nx_execute("util_functions", "get_ini", "ini\\jy_npc.ini")
    local id_index = ini:FindSectionIndex(nx_string(id))
    if id_index < 0 then
      scene:Delete(actor2)
      return nx_null()
    end
    local offset_x = ini:ReadFloat(id_index, "offset_x", 0)
    local offset_y = ini:ReadFloat(id_index, "offset_y", 0)
    local offset_z = ini:ReadFloat(id_index, "offset_z", 0)
    vis_target:LinkToPoint(name, point, actor2)
    local npc_type = obj_target:QueryProp("SubType")
    if npc_type ~= 0 then
      vis_target:SetLinkAngle(name, 0, math.pi, 0)
    end
    vis_target:SetLinkPosition(name, offset_x, offset_y, offset_z)
    if nx_find_custom(vis_target, "is_zhufa") and vis_target.is_zhufa then
      actor2:BlendAction("stand", true, false)
    end
    return actor2
  end
end
function direct_npc_talk(visual_scene_obj, npc_id)
  visual_scene_obj.name = ""
  visual_scene_obj.JyNpc = true
  nx_execute("head_game", "create_client_npc_head", visual_scene_obj)
  if not nx_find_custom(visual_scene_obj, "balloon_name") then
    return
  end
  local ball = visual_scene_obj.balloon_name
  local gui = nx_value("gui")
  local ini = nx_execute("util_functions", "get_ini", "ini\\jy_npc.ini")
  local id_index = ini:FindSectionIndex(nx_string(npc_id))
  if id_index < 0 then
    return
  end
  local data = ini:ReadString(id_index, "text", "")
  local str_ids = nx_function("ext_split_string", data, ",")
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  if not nx_find_custom(visual_scene_obj, "control") then
    return
  end
  local control = visual_scene_obj.control
  local index = 1
  local id = str_ids[index]
  local text = nx_string(gui.TextManager:GetText(id))
  control.Width = 320
  control.Height = 200
  control.ViewRect = "10,10," .. 150 .. "," .. 390
  control.BackColor = "100,0,0,0"
  control.NoFrame = true
  control.Solid = true
  control.BackImage = "gui\\mainform\\bg_talk.png"
  control.Font = "font_talk"
  control.TextColor = "255,0,0,0"
  control.LineHeight = 1
  control:Clear()
  control:AddHtmlText(nx_widestr(text), -1)
  control.Width = 20 + control:GetContentWidth()
  control.Height = 20 + control:GetContentHeight()
  if control.Width < 60 or control.Height < 42 then
    local gap_Width = 60 - control.Width
    local gap_Height = 42 - control.Height
    local draw_left = 0
    local draw_top = 0
    if gap_Width < 0 then
      draw_left = 10
    else
      control.Width = 60
      draw_left = 10 + gap_Width / 2
    end
    if gap_Height < 0 then
      draw_top = 7
    else
      control.Height = 42
      draw_top = 7 + gap_Height / 2
    end
    control.ViewRect = nx_string(draw_left .. "," .. draw_top .. "," .. control:GetContentWidth() + draw_left .. "," .. 10 + control:GetContentHeight() + draw_top)
  else
    control.ViewRect = "10,7," .. control:GetContentWidth() .. "," .. 10 + control:GetContentHeight()
  end
  local groupbox = control.Parent
  groupbox.Width = control.Width * 3
  groupbox.Height = control.Height
  control.HAnchor = "Center"
  control.Left = 0
  ball.OffsetTop = -groupbox.Height / 2 - 10
  visual_scene_obj.show_head_text = true
  nx_execute("head_game", "refresh_client_npc_head", visual_scene_obj)
end
function direct_npc_talk_hide(visual_scene_obj)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  if not nx_find_custom(visual_scene_obj, "control") then
    return
  end
  if nx_find_custom(visual_scene_obj, "show_head_text") and visual_scene_obj.show_head_text == true then
    if not nx_is_valid(visual_scene_obj) then
      return
    end
    if nx_find_custom(visual_scene_obj, "show_head_text") then
      visual_scene_obj.show_head_text = false
      nx_execute("head_game", "refresh_client_npc_head", visual_scene_obj)
    end
  end
end
function Jy_npc_talk(visual_scene_obj, npc_id)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  visual_scene_obj.name = ""
  visual_scene_obj.JyNpc = true
  nx_execute("head_game", "create_client_npc_head", visual_scene_obj)
  local time_span = math.random(8, 11)
  local gui = nx_value("gui")
  local ini = nx_execute("util_functions", "get_ini", "ini\\jy_npc.ini")
  local id_index = ini:FindSectionIndex(nx_string(npc_id))
  if id_index < 0 then
    return
  end
  local data = ini:ReadString(id_index, "text", "")
  local str_ids = nx_function("ext_split_string", data, ",")
  if not nx_find_custom(visual_scene_obj, "balloon_name") then
    return
  end
  local ball = visual_scene_obj.balloon_name
  while true do
    nx_pause(time_span)
    if not nx_is_valid(visual_scene_obj) then
      break
    end
    if not nx_find_custom(visual_scene_obj, "control") then
      break
    end
    local control = visual_scene_obj.control
    local index = math.random(1, table.getn(str_ids))
    local id = str_ids[index]
    local text = nx_string(gui.TextManager:GetText(id))
    control.Width = 320
    control.Height = 200
    control.ViewRect = "10,10," .. 150 .. "," .. 390
    control.BackColor = "100,0,0,0"
    control.NoFrame = true
    control.Solid = true
    control.BackImage = "gui\\mainform\\bg_talk.png"
    control.Font = "font_talk"
    control.TextColor = "255,0,0,0"
    control.LineHeight = 1
    control:Clear()
    control:AddHtmlText(nx_widestr(text), -1)
    control.Width = 20 + control:GetContentWidth()
    control.Height = 20 + control:GetContentHeight()
    if control.Width < 60 or control.Height < 42 then
      local gap_Width = 60 - control.Width
      local gap_Height = 42 - control.Height
      local draw_left = 0
      local draw_top = 0
      if gap_Width < 0 then
        draw_left = 10
      else
        control.Width = 60
        draw_left = 10 + gap_Width / 2
      end
      if gap_Height < 0 then
        draw_top = 7
      else
        control.Height = 42
        draw_top = 7 + gap_Height / 2
      end
      control.ViewRect = nx_string(draw_left .. "," .. draw_top .. "," .. control:GetContentWidth() + draw_left .. "," .. 10 + control:GetContentHeight() + draw_top)
    else
      control.ViewRect = "10,7," .. control:GetContentWidth() .. "," .. 10 + control:GetContentHeight()
    end
    local groupbox = control.Parent
    groupbox.Width = control.Width * 3
    groupbox.Height = control.Height
    control.HAnchor = "Center"
    control.Left = 0
    ball.OffsetTop = -groupbox.Height / 2 - 10
    visual_scene_obj.show_head_text = true
    nx_execute("head_game", "refresh_client_npc_head", visual_scene_obj)
  end
end
function Jy_npc_talk_hide(visual_scene_obj)
  while true do
    if not nx_is_valid(visual_scene_obj) then
      break
    end
    if not nx_find_custom(visual_scene_obj, "control") then
      break
    end
    if nx_find_custom(visual_scene_obj, "show_head_text") and visual_scene_obj.show_head_text == true then
      nx_pause(3)
      if not nx_is_valid(visual_scene_obj) then
        break
      end
      if nx_find_custom(visual_scene_obj, "show_head_text") then
        visual_scene_obj.show_head_text = false
        nx_execute("head_game", "refresh_client_npc_head", visual_scene_obj)
      end
    else
      nx_pause(1)
    end
  end
end
function table_find(t, v)
  local pos = -1
  for i = 1, table.getn(t) do
    if v == t[i] then
      pos = i
      break
    end
  end
  return pos
end
function link_JY_npc(link_ident, ident)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_is_valid(game_visual) then
    return
  end
  local obj_target = game_client:GetSceneObj(link_ident)
  local vis_target = game_visual:GetSceneObj(link_ident)
  if not nx_is_valid(obj_target) or not nx_is_valid(vis_target) then
    return
  end
  local points = get_role_binds(link_ident)
  local npcs
  local npc_type = obj_target:QueryProp("SubType")
  local ini = nx_execute("util_functions", "get_ini", "ini\\jy_npc.ini")
  if npc_type ~= 0 then
    local id_index = 0
    if nx_find_custom(vis_target, "is_zhufa") and vis_target.is_zhufa then
      id_index = ini:FindSectionIndex("zhufa")
    else
      id_index = ini:FindSectionIndex("boat")
    end
    if id_index < 0 then
      return
    end
    local data = ini:ReadString(id_index, "npc", "")
    npcs = nx_function("ext_split_string", data, ",")
  else
    local id_index = ini:FindSectionIndex("mount")
    if id_index < 0 then
      return
    end
    local data = ini:ReadString(id_index, "npc", "")
    npcs = nx_function("ext_split_string", data, ",")
  end
  local player_point = get_player_bind(link_ident, ident)
  local pos = table_find(points, player_point)
  if pos ~= -1 then
    table.remove(points, pos)
  end
  if 0 >= table.getn(points) then
    return
  end
  local npc_index = -1
  local vis_target = game_visual:GetSceneObj(link_ident)
  if nx_find_custom(vis_target, "npc_index") and vis_target.npc_index > 1 then
    npc_index = vis_target.npc_index - 1
  end
  local npc_count = 2
  for i = 1, npc_count do
    local point_pos = math.random(1, table.getn(points))
    local npc_pos = math.random(1, table.getn(npcs))
    local p = points[point_pos]
    local npc_id = npcs[npc_pos]
    local actor2 = link_npc(link_ident, p, npc_id, npc_id)
    if nx_is_valid(actor2) and i == npc_index then
      nx_execute(nx_current(), "Jy_npc_talk", actor2, npc_id)
      nx_execute(nx_current(), "Jy_npc_talk_hide", actor2)
    end
    table.remove(points, point_pos)
    table.remove(npcs, npc_pos)
  end
end
function on_move(ident, link_ident, link_x, link_y, link_z, link_orient)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_visual) then
    return
  end
  if not nx_is_valid(game_client) then
    return
  end
  local role_obj = game_client:GetSceneObj(ident)
  local vis_target = game_visual:GetSceneObj(link_ident)
  if not nx_is_valid(role_obj) or not nx_is_valid(vis_target) then
    return
  end
  vis_target:SetLinkPosition(role_obj.linkname, link_x, link_y, link_z)
end
function init_timer(time, ident)
  local timer = nx_value(GAME_TIMER)
  temp_time = time
  local game_client = nx_value("game_client")
  while true do
    local ptime = nx_pause(0)
    local obj = game_client:GetSceneObj(nx_string(ident))
    if nx_is_valid(obj) then
      timer:Register(1000, -1, nx_current(), "on_update_time", obj, -1, -1)
      temp_time = temp_time - nx_int(ptime)
      break
    end
  end
end
function on_update_time(obj)
  temp_time = temp_time - 1
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowChatTextOnHead(obj, nx_widestr(temp_time))
  end
  if temp_time <= 0 then
    stop_timer(obj)
  end
end
function stop_timer(obj)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", obj)
end
function link_to_float_area(ident, link_ident, link_x, link_y, link_z, link_orient)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local npc = game_visual:GetSceneObj(link_ident)
  local player = game_visual:GetSceneObj(ident)
  if not nx_is_valid(player) then
    return
  end
  player.vislink = npc
  player.link_x = link_x
  player.link_y = link_y
  player.link_z = link_z
  player.link_orient = link_orient
  nx_call("player_state\\state_input", "emit_player_input", player, PLAYER_INPUT_LOGIC, LOGIC_LINK_TO_FLOAT)
end
function unlink_from_float_area(ident)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_visual) then
    return
  end
  if not nx_is_valid(game_client) then
    return
  end
  local action_module = nx_value("action_module")
  local player = game_visual:GetSceneObj(ident)
  local state_index = game_visual:QueryRoleStateIndex(player)
  player.vislink = nx_null()
  if game_client:IsPlayer(ident) then
    if state_index == STATE_LINK_MOTION_INDEX or state_index == STATE_LINK_STOP_INDEX then
    end
  elseif state_index == STATE_LINK_MOTION_INDEX or state_index == STATE_LINK_STOP_INDEX then
    switch_player_state(player, "be_stop", nx_current(), STATE_BE_STOP_INDEX)
  end
end
