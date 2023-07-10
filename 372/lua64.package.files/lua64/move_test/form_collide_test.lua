require("util_functions")
require("move_test\\state_define")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function init(form)
  form.Fixed = false
  form.no_need_motion_alpha = true
end
local table_sync_state = {
  "SYNC_STATE_GROUND_STOP",
  "SYNC_STATE_SWIM_STOP",
  "SYNC_STATE_FLY_STOP",
  "SYNC_STATE_DRIFT_STOP",
  "SYNC_STATE_CLIMB_STOP",
  "SYNC_STATE_NO_COLLIDE_JUMP_TO_STOP",
  "SYNC_STATE_ZHAOSHI_END_STOP",
  "SYNC_STATE_FALLDOWN_STOP",
  "SYNC_STATE_GROUND_WALK",
  "SYNC_STATE_GROUND_RUN",
  "SYNC_STATE_GROUND_TRANS",
  "SYNC_STATE_GROUND_QINGGONG_FAST",
  "SYNC_STATE_GROUND_RUSH",
  "SYNC_STATE_JUMP_GROUND",
  "SYNC_STATE_JUMP_GROUND_BACK",
  "SYNC_STATE_JUMP_GROUND_NOMOVE",
  "SYNC_STATE_JUMP_SECOND",
  "SYNC_STATE_JUMP_SECOND_NOMOVE",
  "SYNC_STATE_JUMP_THIRD",
  "SYNC_STATE_JUMP_THIRD_NOMOVE",
  "SYNC_STATE_JUMP_WATER_DIAN",
  "SYNC_STATE_JUMP_WATER_DIAN_NOMOVE",
  "SYNC_STATE_JUMP_FALL",
  "SYNC_STATE_JUMP_CLIMB_FALL",
  "SYNC_STATE_JUMP_CLIMB_JUMP",
  "SYNC_STATE_JUMP_CLIMB_OVER",
  "SYNC_STATE_JUMP_FLYRUSHEND",
  "SYNC_STATE_NO_COLLIDE_JUMP_GROUND",
  "SYNC_STATE_JUMP_HITOUT",
  "SYNC_STATE_JUMPTO",
  "SYNC_STATE_JUMPTO_NOMOVE",
  "SYNC_STATE_JUMPTO_HITOUT",
  "SYNC_STATE_SWIM",
  "SYNC_STATE_RIDE_SWIM",
  "SYNC_STATE_SWIM_SINK",
  "SYNC_STATE_SWIM_RISE",
  "SYNC_STATE_SWIM_HITSINK",
  "SYNC_STATE_SWIM_HITRAISE",
  "SYNC_STATE_FLY",
  "SYNC_STATE_FLY_NOROTATE",
  "SYNC_STATE_FLY_DOWN",
  "SYNC_STATE_FLY_RISE",
  "SYNC_STATE_FLY_RUSH_BEGIN",
  "SYNC_STATE_FLY_RUSHING",
  "SYNC_STATE_FLY_LIGHT",
  "SYNC_STATE_DRIFT_MOTION",
  "SYNC_STATE_CLIMB_UP",
  "SYNC_STATE_CLIMB_LEFT",
  "SYNC_STATE_CLIMB_RIGHT",
  "SYNC_STATE_SLIDE",
  "SYNC_STATE_ZHAOSHI",
  "SYNC_STATE_HITBACK",
  "SYNC_STATE_SKILLRUSH",
  "SYNC_STATE_SKILLCLASP",
  "MAX_SYNC_STATE"
}
function on_main_form_open(form)
  nx_execute(nx_current(), "refresh_role_info", form)
  form.textgrid_floors:SetColTitle(0, nx_widestr("\178\227\186\197"))
  form.textgrid_floors:SetColTitle(1, nx_widestr("\180\230\212\218"))
  form.textgrid_floors:SetColTitle(2, nx_widestr("\191\201\180\239"))
  form.textgrid_floors:SetColTitle(3, nx_widestr("\178\227\184\223"))
  form.textgrid_floors:SetColTitle(4, nx_widestr("\178\227\191\213\188\228"))
  form.textgrid_floors:SetColTitle(5, nx_widestr("\214\208\208\196\178\227\184\223"))
  form.textgrid_floors:SetColTitle(6, nx_widestr("\178\227\182\165\184\223"))
  form.textgrid_actions:SetColTitle(0, nx_widestr("\198\239"))
  form.textgrid_actions:SetColTitle(1, nx_widestr("\205\234\213\251\182\175\215\247\195\251"))
  form.textgrid_actions:SetColTitle(2, nx_widestr("\209\173\187\183"))
  form.textgrid_head:SetColTitle(0, nx_widestr("AngleX"))
  form.textgrid_head:SetColTitle(1, nx_widestr("AngleY"))
  form.textgrid_head:SetColTitle(2, nx_widestr("AngleZ"))
  form.textgrid_head:InsertRow(-1)
  form.textgrid_head:InsertRow(-1)
  form.textgrid_head:InsertRow(-1)
  form.textgrid_head:InsertRow(-1)
  form.textgrid_neck:SetColTitle(0, nx_widestr("AngleX"))
  form.textgrid_neck:SetColTitle(1, nx_widestr("AngleY"))
  form.textgrid_neck:SetColTitle(2, nx_widestr("AngleZ"))
  form.textgrid_neck:InsertRow(-1)
  form.textgrid_neck:InsertRow(-1)
  form.textgrid_spine1:SetColTitle(0, nx_widestr("AngleX"))
  form.textgrid_spine1:SetColTitle(1, nx_widestr("AngleY"))
  form.textgrid_spine1:SetColTitle(2, nx_widestr("AngleZ"))
  form.textgrid_spine1:InsertRow(-1)
  form.textgrid_spine1:InsertRow(-1)
  form.textgrid_spine:SetColTitle(0, nx_widestr("AngleX"))
  form.textgrid_spine:SetColTitle(1, nx_widestr("AngleY"))
  form.textgrid_spine:SetColTitle(2, nx_widestr("AngleZ"))
  form.textgrid_spine:InsertRow(-1)
  form.textgrid_spine:InsertRow(-1)
  local scene_obj = nx_value("scene_obj")
  form.cbtn_stopradomlook.Checked = not scene_obj.FreeLook
  form.textgrid_turn:SetColTitle(0, nx_widestr("MinAngleY"))
  form.textgrid_turn:SetColTitle(1, nx_widestr("BaseAngleY"))
  form.textgrid_turn:SetColTitle(2, nx_widestr("MaxAngleY"))
  form.textgrid_turn:InsertRow(-1)
  form.textgrid_turn:InsertRow(-1)
  form.textgrid_turn:InsertRow(-1)
  form.textgrid_turn:SetGridText(1, 0, nx_widestr("\196\191\177\234\189\199\182\200"))
  form.textgrid_turn:SetGridText(2, 0, nx_widestr("\189\199\182\200\208\222\213\253"))
end
function on_main_form_close(form)
  nx_kill(nx_current(), "show_msg_per_5m")
  nx_destroy(form)
end
function on_cbtn_page2_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.Width = form.Width * 2
    form.groupbox_action.Visible = true
    form.rbtn_actionlist.Checked = true
  else
    form.Width = form.Width / 2
    form.groupbox_action.Visible = false
    form.rbtn_actionlist.Checked = false
  end
end
function util_get_target_role_model()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local client_role = game_client:GetSceneObj(game_visual.PlayerIdent)
    if nx_is_valid(client_role) then
      local target_ident = client_role:QueryProp("LastObject")
      local vis_target = game_visual:GetSceneObj(nx_string(target_ident))
      return vis_target
    end
  end
  return nx_null()
end
function get_target_model(form)
  if form.cbtn_target.Checked then
    return util_get_target_role_model()
  else
    return util_get_role_model()
  end
end
function get_client_obj(vis_obj)
  if not nx_is_valid(vis_obj) then
    return nx_null()
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(vis_obj)
  local client_obj = game_client:GetSceneObj(client_ident)
  return client_obj
end
local time_count = 6
function show_msg_per_5m(info)
  if 5 < time_count then
    nx_msgbox(info)
    time_count = 0
    nx_pause(5)
    time_count = 6
  end
end
function refresh_role_info(form)
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  local gui = nx_value("gui")
  if not nx_is_valid(scene) then
    return false
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    terrain = nx_value("terrain")
  end
  local game_visual = nx_value("game_visual")
  local role = get_target_model(form)
  local client_role = get_client_obj(role)
  while nx_is_valid(form) and nx_is_valid(terrain) do
    role = get_target_model(form)
    client_role = get_client_obj(role)
    if nx_is_valid(role) and nx_is_valid(client_role) then
      local x = role.PositionX
      local y = role.PositionY
      local z = role.PositionZ
      local angle_y = role.AngleY
      local move_speed = game_visual:QueryRoleMoveSpeed(role)
      local state_old = game_visual:QueryRoleStateOld(role)
      if game_visual:HasRoleUserData(role) then
        local state_index = game_visual:QueryRoleStateIndex(role)
        if tabel_state_index[state_index] ~= nil then
          form.lbl_state_index.Text = nx_widestr("" .. nx_string(tabel_state_index[state_index]))
        else
          form.lbl_state_index.Text = nx_widestr("state_index = " .. nx_string(state_index))
        end
      end
      if nx_find_custom(role, "state") then
        form.lbl_move_mode.Text = nx_widestr("state = " .. nx_string(role.state))
      else
        form.lbl_move_mode.Text = nx_widestr("move_mode = " .. nx_string(role.move_mode))
      end
      local index = client_role:QueryProp("SyncState")
      if nx_find_custom(role, "sync_state") then
        index = nx_number(role.sync_state)
      end
      local sync_state = nx_string(index)
      if 0 < index and index <= table.maxn(table_sync_state) then
        sync_state = nx_string(index) .. table_sync_state[index + 1]
      end
      form.lbl_sync.Text = nx_widestr("sync_state=" .. nx_string(sync_state))
      form.mltbox_key.HtmlText = nx_widestr("key = " .. nx_string(get_key_state(role)))
      form.lbl_x.Text = nx_widestr("X = " .. nx_string(x))
      form.lbl_y.Text = nx_widestr("Y = " .. nx_string(y))
      form.lbl_z.Text = nx_widestr("Z = " .. nx_string(z))
      form.lbl_angley.Text = nx_widestr("AngleY = " .. nx_string(nip_radian(angle_y)))
      form.lbl_move_speed.Text = nx_widestr("MoveSpeed = " .. nx_string(move_speed) .. "," .. nx_string(client_role:QueryProp("MoveSpeed")))
      form.lbl_floor_index.Text = nx_widestr("floor_index = " .. nx_string(game_visual:QueryRoleFloorIndex(role)))
      local MessageDelay = nx_value("MessageDelay")
      local Delay = MessageDelay:GetDelayTime()
      form.lbl_delay.Text = nx_widestr("vis_obj=" .. nx_string(role) .. "\t\tDelay:" .. nx_string(Delay) .. "ms")
      form.lbl_ident.Text = nx_widestr("Ident = " .. nx_string(client_role.Ident))
      local action_module = nx_value("action_module")
      local BaseSpeed = action_module:GetActionBaseSpeed(role, state_old)
      form.lbl_basespeed.Text = nx_widestr("BaseSpeed = " .. nx_string(BaseSpeed))
      local ActionScale = action_module:GetActionScale(role, state_old)
      form.lbl_actionscale.Text = nx_widestr("ActionScale = " .. nx_string(ActionScale))
      local ActionSpeed = action_module:GetActionSpeed(role)
      form.lbl_actionspeed.Text = nx_widestr("ActionSpeed = " .. nx_string(ActionSpeed))
      if form.groupbox_info3.Visible then
        local table_logicstate = {
          [0] = "LS_NORMAL \198\213\205\168",
          [1] = "LS_FIGHTING \213\189\182\183",
          [2] = "LS_WARNING \190\175\189\228",
          [101] = "LS_STALLED \176\218\204\175",
          [102] = "LS_SITCROSS \180\242\215\248",
          [103] = "LS_DANCING \204\248\206\232",
          [104] = "LS_GATHER \178\201\188\175",
          [105] = "LS_LINK \193\180\189\211",
          [106] = "LS_OFFLINEJOB \192\235\207\223\180\242\185\164",
          [107] = "LS_FISHING \181\246\211\227",
          [108] = "LS_FACULTY \208\222\193\182",
          [109] = "LS_FORGE \182\205\212\236",
          [120] = "LS_DIED \203\192\205\246"
        }
        if game_visual:HasRoleUserData(role) then
          local logic_state = game_visual:QueryRoleLogicState(role)
          if table_logicstate[logic_state] == nil then
            form.lbl_logicstate.Text = nx_widestr("logic_state=" .. nx_string(logic_state))
          else
            form.lbl_logicstate.Text = nx_widestr("logic_state=" .. table_logicstate[logic_state])
          end
        end
        if nx_find_custom(role, "path_finding") then
          form.lbl_pathfinding.Visible = true
          form.lbl_pathfinding_old.Visible = true
          form.lbl_pathfinding.Text = nx_widestr("path_finding=" .. nx_string(role.path_finding))
          if nx_find_custom(role, "old_path_finding") then
            form.lbl_pathfinding_old.Text = nx_widestr("old_path_finding=" .. nx_string(role.old_path_finding))
          end
        else
          form.lbl_pathfinding.Visible = false
          form.lbl_pathfinding_old.Visible = false
        end
      end
      if nx_find_custom(role, "face_angle") then
        form.lbl_face_angle.Text = nx_widestr("face_angle = " .. nx_string(role.face_angle))
      end
      if nx_find_custom(role, "move_angle") then
        form.lbl_move_angle.Text = nx_widestr("move_angle = " .. nx_string(role.move_angle))
      end
      local face_orient = 0
      if nx_find_custom(role, "face_orient") then
        face_orient = role.face_orient
      else
      end
      local move_str = ""
      if nx_find_custom(role, "move_v_orient") then
        move_str = nx_string(role.move_v_orient) .. "," .. nx_string(role.move_h_orient)
      end
      form.lbl_face_orient.Text = nx_widestr("face_orient =" .. nx_string(table_face_orient[face_orient]) .. move_str)
      form.lbl_model_angle.Text = nx_widestr("model_angle = " .. nx_string(nip_radian(angle_y)))
      if math.abs(client_role.DestX - x) < 1.0E-4 then
        form.lbl_dest_posix.ForeColor = "255,255,255,0"
        form.lbl_x.ForeColor = "255,255,255,0"
      else
        form.lbl_dest_posix.ForeColor = "255,255,255,255"
        form.lbl_x.ForeColor = "255,255,255,255"
      end
      if 1.0E-4 > math.abs(client_role.DestY - y) then
        form.lbl_dest_posiy.ForeColor = "255,255,255,0"
        form.lbl_y.ForeColor = "255,255,255,0"
      else
        form.lbl_dest_posiy.ForeColor = "255,255,255,255"
        form.lbl_y.ForeColor = "255,255,255,255"
      end
      if 1.0E-4 > math.abs(client_role.DestZ - z) then
        form.lbl_dest_posiz.ForeColor = "255,255,255,0"
        form.lbl_z.ForeColor = "255,255,255,0"
      else
        form.lbl_dest_posiz.ForeColor = "255,255,255,255"
        form.lbl_z.ForeColor = "255,255,255,255"
      end
      if math.abs(nip_radianII(client_role.DestOrient - angle_y)) < 0.01 then
        form.lbl_dest_orient.ForeColor = "255,255,255,0"
        form.lbl_angley.ForeColor = "255,255,255,0"
      else
        form.lbl_dest_orient.ForeColor = "255,255,255,255"
        form.lbl_angley.ForeColor = "255,255,255,255"
      end
      form.textgrid_floors:ClearRow()
      local floor_count = terrain:GetFloorCount(x, z)
      local floor_index = -1
      local floor_exist = false
      local floor_can_on = false
      local floor_can_move = false
      local floor_height = -1000
      local floor_space = -1
      local last_floor_height = -1000000000
      for i = floor_count - 1, 0, -1 do
        if i == floor_count - 1 then
          last_floor_height = -1000000000
        end
        floor_index = i
        if terrain:GetFloorExists(x, z, i) then
          floor_exist = true
          floor_can_move = terrain:GetFloorCanMove(x, z, i)
          floor_can_on = terrain:GetFloorCanStand(x, z, i)
          floor_height = terrain:GetFloorHeight(x, z, i)
          floor_space = terrain:GetFloorSpace(x, z, i)
        else
          floor_exist = false
          floor_can_on = false
          floor_height = -1000
          floor_space = -1
        end
        local row = form.textgrid_floors:InsertRow(floor_count - 1 - i)
        form.textgrid_floors:SetGridText(row, 0, nx_widestr(floor_index))
        form.textgrid_floors:SetGridText(row, 1, nx_widestr(floor_exist))
        form.textgrid_floors:SetGridText(row, 2, nx_widestr(floor_can_on))
        form.textgrid_floors:SetGridText(row, 3, nx_widestr(floor_height))
        form.textgrid_floors:SetGridText(row, 4, nx_widestr(floor_space))
        form.textgrid_floors:SetGridForeColor(row, 0, "255,255,255,255")
        form.textgrid_floors:SetGridForeColor(row, 1, "255,255,255,255")
        form.textgrid_floors:SetGridForeColor(row, 2, "255,255,255,255")
        form.textgrid_floors:SetGridForeColor(row, 3, "255,255,255,255")
        if floor_can_on and floor_can_move then
          form.textgrid_floors:SetGridBackColor(row, 0, "255,0,200,0")
          form.textgrid_floors:SetGridBackColor(row, 1, "255,0,200,0")
          form.textgrid_floors:SetGridBackColor(row, 2, "255,0,200,0")
          form.textgrid_floors:SetGridBackColor(row, 3, "255,0,200,0")
        elseif floor_can_on then
          form.textgrid_floors:SetGridBackColor(row, 0, "255,255,100,0")
          form.textgrid_floors:SetGridBackColor(row, 1, "255,255,100,0")
          form.textgrid_floors:SetGridBackColor(row, 2, "255,255,100,0")
          form.textgrid_floors:SetGridBackColor(row, 3, "255,255,100,0")
        else
          form.textgrid_floors:SetGridBackColor(row, 0, "255,255,0,0")
          form.textgrid_floors:SetGridBackColor(row, 1, "255,255,0,0")
          form.textgrid_floors:SetGridBackColor(row, 2, "255,255,0,0")
          form.textgrid_floors:SetGridBackColor(row, 3, "255,255,0,0")
        end
        local center_x = nx_number(nx_int(x / 0.5)) * 0.5
        if center_x < 0 then
          center_x = center_x - 0.25
        else
          center_x = center_x + 0.25
        end
        local center_z = nx_number(nx_int(z / 0.5)) * 0.5
        if center_z < 0 then
          center_z = center_z - 0.25
        else
          center_z = center_z + 0.25
        end
        local center_floor_height = -1000000000
        local center_floor_space = -1000000000
        if floor_exist then
          center_floor_height = terrain:GetFloorHeight(center_x, center_z, i)
          center_floor_space = terrain:GetFloorSpace(center_x, center_z, i)
        end
        if -9999 < center_floor_height then
          form.textgrid_floors:SetGridText(row, 5, nx_widestr(center_floor_height))
          if 10000000 < center_floor_height + center_floor_space then
            form.textgrid_floors:SetGridText(row, 6, nx_widestr("\206\222\199\238"))
          else
            form.textgrid_floors:SetGridText(row, 6, nx_widestr(center_floor_height + center_floor_space))
          end
          if -1000000000 < last_floor_height and 0.02 < center_floor_height + center_floor_space - last_floor_height then
            form.textgrid_floors:SetGridBackColor(row, 5, "255,255,0,0")
            nx_execute(nx_current(), "show_msg_per_5m", "error cur terrain walk wrong please rebuild walk points " .. nx_string(center_floor_height + center_floor_space - last_floor_height) .. " x=" .. nx_string(center_x) .. " z=" .. nx_string(center_z) .. [[

 center_floor_height=]] .. nx_string(center_floor_height) .. [[

 center_floor_space=]] .. nx_string(center_floor_space) .. [[

 last_floor_height=]] .. nx_string(last_floor_height))
          else
            form.textgrid_floors:SetGridBackColor(row, 5, "50,255,255,255")
          end
        else
          form.textgrid_floors:SetGridText(row, 5, nx_widestr(""))
          form.textgrid_floors:SetGridText(row, 6, nx_widestr(""))
        end
        last_floor_height = center_floor_height
      end
      local water_exists = terrain:GetWalkWaterExists(x, z)
      if water_exists then
        floor_height = terrain:GetWalkWaterHeight(x, z)
        floor_space = terrain:GetWaterWaveHeight(x, z)
        local row = form.textgrid_floors:InsertRow(-1)
        form.textgrid_floors:SetGridText(row, 0, nx_widestr("water"))
        form.textgrid_floors:SetGridText(row, 1, nx_widestr("true"))
        form.textgrid_floors:SetGridText(row, 2, nx_widestr("true"))
        form.textgrid_floors:SetGridText(row, 3, nx_widestr(floor_height))
        form.textgrid_floors:SetGridText(row, 4, nx_widestr(floor_space))
      end
      form.textgrid_floors.VScrollBar.Value = form.textgrid_floors.VScrollBar.Maximum
      if form.groupbox_action.Visible then
        form.lbl_state.Text = nx_widestr("Prop State = " .. nx_string(client_role:QueryProp("State")))
        form.lbl_posix.Text = nx_widestr("PosiX = " .. nx_string(client_role.PosiX))
        form.lbl_posiy.Text = nx_widestr("PosiY = " .. nx_string(client_role.PosiY))
        form.lbl_posiz.Text = nx_widestr("PosiZ = " .. nx_string(client_role.PosiZ))
        form.lbl_dest_posix.Text = nx_widestr("DestX = " .. nx_string(client_role.DestX))
        form.lbl_dest_posiy.Text = nx_widestr("DestY = " .. nx_string(client_role.DestY))
        form.lbl_dest_posiz.Text = nx_widestr("DestZ = " .. nx_string(client_role.DestZ))
        form.lbl_orient.Text = nx_widestr("Orient = " .. nx_string(client_role.Orient))
        form.lbl_dest_orient.Text = nx_widestr("DestOrient = " .. nx_string(client_role.DestOrient))
        form.lbl_actionset.Text = nx_widestr("ActionSet = " .. game_visual:QueryRoleActionSet(role))
        form.lbl_move_dist.Text = nx_widestr("move_distance = " .. nx_string(game_visual:QueryRoleMoveDistance(role)))
        form.lbl_max_move_dist.Text = nx_widestr("max_move_distance = " .. nx_string(game_visual:QueryRoleMaxMoveDistance(role)))
        refresh_role_actions(form)
      end
      if form.groupbox_bones.Visible then
        local actor_role = role:GetLinkObject("actor_role")
        if not nx_is_valid(actor_role) then
          actor_role = role
        end
        local dy, dx, dz = actor_role:GetBoneAngle("Bip01 Head")
        local wx, wy, wz = actor_role:GetNodeAngle("Bip01 Head")
        local cur_min_pitch = -math.pi / 3
        local cur_max_pitch = math.pi / 4
        if wx < cur_min_pitch then
          form.textgrid_head:SetGridBackColor(0, 0, "255,255,0,0")
        else
          form.textgrid_head:SetGridBackColor(0, 0, "87,255,255,255")
        end
        form.textgrid_head:SetGridText(0, 0, nx_widestr(cur_min_pitch))
        form.textgrid_head:SetGridText(0, 1, nx_widestr(0))
        form.textgrid_head:SetGridText(0, 2, nx_widestr(0))
        form.textgrid_head:SetGridText(1, 0, nx_widestr(wx))
        form.textgrid_head:SetGridText(1, 1, nx_widestr(wy))
        form.textgrid_head:SetGridText(1, 2, nx_widestr(wz))
        form.textgrid_head:SetGridText(2, 0, nx_widestr(dx))
        form.textgrid_head:SetGridText(2, 1, nx_widestr(dy))
        form.textgrid_head:SetGridText(2, 2, nx_widestr(dz))
        if wx > cur_max_pitch then
          form.textgrid_head:SetGridBackColor(3, 0, "255,255,0,0")
        else
          form.textgrid_head:SetGridBackColor(3, 0, "87,255,255,255")
        end
        form.textgrid_head:SetGridText(3, 0, nx_widestr(cur_max_pitch))
        form.textgrid_head:SetGridText(3, 1, nx_widestr(0))
        form.textgrid_head:SetGridText(3, 2, nx_widestr(0))
        local dy, dx, dz = actor_role:GetBoneAngle("Bip01 Neck")
        local wx, wy, wz = actor_role:GetNodeAngle("Bip01 Neck")
        form.textgrid_neck:SetGridText(0, 0, nx_widestr(wx))
        form.textgrid_neck:SetGridText(0, 1, nx_widestr(wy))
        form.textgrid_neck:SetGridText(0, 2, nx_widestr(wz))
        form.textgrid_neck:SetGridText(1, 0, nx_widestr(dx))
        form.textgrid_neck:SetGridText(1, 1, nx_widestr(dy))
        form.textgrid_neck:SetGridText(1, 2, nx_widestr(dz))
        local dy, dx, dz = actor_role:GetBoneAngle("Bip01 Spine1")
        local wx, wy, wz = actor_role:GetNodeAngle("Bip01 Spine1")
        form.textgrid_spine1:SetGridText(0, 0, nx_widestr(wx))
        form.textgrid_spine1:SetGridText(0, 1, nx_widestr(wy))
        form.textgrid_spine1:SetGridText(0, 2, nx_widestr(wz))
        form.textgrid_spine1:SetGridText(1, 0, nx_widestr(dx))
        form.textgrid_spine1:SetGridText(1, 1, nx_widestr(dy))
        form.textgrid_spine1:SetGridText(1, 2, nx_widestr(dz))
        local dy, dx, dz = actor_role:GetBoneAngle("Bip01 Spine")
        local wx, wy, wz = actor_role:GetNodeAngle("Bip01 Spine")
        form.textgrid_spine:SetGridText(0, 0, nx_widestr(wx))
        form.textgrid_spine:SetGridText(0, 1, nx_widestr(wy))
        form.textgrid_spine:SetGridText(0, 2, nx_widestr(wz))
        form.textgrid_spine:SetGridText(1, 0, nx_widestr(dx))
        form.textgrid_spine:SetGridText(1, 1, nx_widestr(dy))
        form.textgrid_spine:SetGridText(1, 2, nx_widestr(dz))
        local wx, wy, wz = actor_role:GetNodeAngle("Bip01 Pelvis")
        form.lbl_pelvis.Text = nx_widestr("Bip01 Pelvis=" .. nx_string(wy))
        form.textgrid_turn:SetGridText(0, 1, nx_widestr(wy))
        local min_dest_angle = wy - math.pi / 3
        local max_dest_angle = wy + math.pi / 3
        form.textgrid_turn:SetGridText(0, 0, nx_widestr(min_dest_angle))
        form.textgrid_turn:SetGridText(0, 2, nx_widestr(max_dest_angle))
        local dest_angle = get_dest_angle(role)
        local sub_dest_angle = nip_radianII(dest_angle - wy)
        dest_angle = wy + sub_dest_angle
        form.textgrid_turn:SetGridText(1, 1, nx_widestr(dest_angle))
        if min_dest_angle > dest_angle then
          dest_angle = min_dest_angle
          form.textgrid_turn:SetGridBackColor(0, 0, "255,255,0,0")
        else
          form.textgrid_turn:SetGridBackColor(0, 0, "87,255,255,255")
          if max_dest_angle < dest_angle then
            dest_angle = max_dest_angle
            form.textgrid_turn:SetGridBackColor(0, 2, "255,255,0,0")
          else
            form.textgrid_turn:SetGridBackColor(0, 2, "87,255,255,255")
          end
        end
        form.textgrid_turn:SetGridText(2, 1, nx_widestr(dest_angle))
        form.lbl_aimobj.Text = nx_widestr("AimObj=" .. nx_string(role.AimObject))
        if nx_find_custom(role, "aim_obj_end_time") then
          form.lbl_aimobjendtime.Text = nx_widestr("aim_obj_end_time=" .. nx_string(role.aim_obj_end_time))
        else
          form.lbl_aimobjendtime.Text = nx_widestr("aim_obj_end_time=")
        end
      end
    end
    nx_pause(0.1)
  end
end
function refresh_role_actions(form)
  local role = get_target_model(form)
  if nx_is_valid(role) then
    form.textgrid_actions:ClearRow()
    refresh_role_actions_sub(form, role, "255,100,100,0", "\194\237")
    local actor_role = role:GetLinkObject("actor_role")
    if nx_is_valid(actor_role) then
      refresh_role_actions_sub(form, actor_role, "255,0,255,0", "\200\203")
    end
  end
end
function refresh_role_actions_sub(form, role, head_color, text)
  local mount_action_list = role:GetActionBlendList()
  local floor_count = table.maxn(mount_action_list)
  local action_name = ""
  local action_blended = false
  local action_unblending = false
  local action_loop = false
  for i = 0, floor_count - 1 do
    local row = form.textgrid_actions:InsertRow(i)
    action_name = mount_action_list[i + 1]
    action_blended = role:IsActionBlended(action_name)
    action_unblending = role:IsActionUnblending(action_name)
    action_loop = role:GetBlendActionLoop(action_name)
    form.textgrid_actions:SetGridText(row, 0, nx_widestr(text))
    form.textgrid_actions:SetGridText(row, 1, nx_widestr(action_name))
    if action_blended then
      form.textgrid_actions:SetGridForeColor(row, 0, "255,255,255,255")
      form.textgrid_actions:SetGridForeColor(row, 1, "255,255,255,255")
      form.textgrid_actions:SetGridBackColor(row, 0, head_color)
      form.textgrid_actions:SetGridBackColor(row, 1, "255,0,120,0")
    elseif action_unblending then
      form.textgrid_actions:SetGridForeColor(row, 0, "255,255,255,255")
      form.textgrid_actions:SetGridForeColor(row, 1, "255,255,255,255")
      form.textgrid_actions:SetGridBackColor(row, 0, head_color)
      form.textgrid_actions:SetGridBackColor(row, 1, "255,150,0,0")
    else
      form.textgrid_actions:SetGridForeColor(row, 0, "255,255,255,255")
      form.textgrid_actions:SetGridForeColor(row, 1, "255,255,255,255")
      form.textgrid_actions:SetGridBackColor(row, 0, head_color)
      form.textgrid_actions:SetGridBackColor(row, 1, "255,50,150,50")
    end
    if action_loop then
      form.textgrid_actions:SetGridText(row, 2, nx_widestr("true"))
      form.textgrid_actions:SetGridForeColor(row, 2, "255,255,255,255")
      form.textgrid_actions:SetGridBackColor(row, 2, "255,0,0,250")
    else
      form.textgrid_actions:SetGridText(row, 2, nx_widestr("false"))
      form.textgrid_actions:SetGridForeColor(row, 2, "255,255,255,255")
      form.textgrid_actions:SetGridBackColor(row, 2, "255,0,0,150")
    end
  end
end
function on_rbtn_actionlist_checked_changed(rbtn)
  local form = rbtn.ParentForm
  form.groupbox_action.Visible = rbtn.Checked
end
function on_rbtn_add_info_checked_changed(rbtn)
  local form = rbtn.ParentForm
  form.groupbox_info3.Visible = rbtn.Checked
end
function on_rbtn_boneangle_checked_changed(rbtn)
  local form = rbtn.ParentForm
  form.groupbox_bones.Visible = rbtn.Checked
end
function on_btn_clearaim_click(btn)
  local form = btn.ParentForm
  local role = get_target_model(form)
  role.AimObject = nx_null()
  local actor_role = role:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role.AimObject = nx_null()
  end
end
function on_cbtn_stopradomlook_checked_changed(cbtn)
  local scene_obj = nx_value("scene_obj")
  scene_obj.FreeLook = not cbtn.Checked
end
function nip_radian(r)
  local ret = r - nx_number(nx_int(r / (2 * math.pi))) * (2 * math.pi)
  if ret < 0 then
    ret = ret + 2 * math.pi
  end
  return ret
end
function nip_radianII(r)
  local ret = nip_radian(r)
  if ret > math.pi then
    ret = ret - 2 * math.pi
  end
  return ret
end
function get_dest_angle(role)
  if not nx_is_valid(role) then
    return 0
  end
  if not nx_is_valid(role.AimObject) then
    return 0
  end
  local sx = role.AimObject.PositionX - role.PositionX
  local sz = role.AimObject.PositionZ - role.PositionZ
  local distance = math.sqrt(sx * sx + sz * sz)
  if distance < 0.001 then
    return 0
  end
  local dest_angle = math.acos(sz / distance)
  if sx < 0 then
    dest_angle = -dest_angle
  end
  dest_angle = nip_radianII(dest_angle)
  return dest_angle
end
function on_btn_action_pause_click(btn)
  local form = btn.ParentForm
  local role = get_target_model(form)
  local actor_role = role:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    role = actor_role
  end
  if not nx_find_custom(form, "action_pause") or not form.action_pause then
    local action_list = role:GetActionBlendList()
    for i = 1, table.getn(action_list) do
      role:SetBlendActionPause(action_list[i], true)
    end
    form.action_pause = true
  else
    local action_list = role:GetActionBlendList()
    for i = 1, table.getn(action_list) do
      role:SetBlendActionPause(action_list[i], false)
    end
    form.action_pause = false
  end
end
COLOR_Red = "#FF0000"
COLOR_White = "#ffffff"
COLOR_Black = "#000000"
function get_text_by_color(text, color)
  if nx_ws_length(nx_widestr(text)) < 1 then
    return ""
  end
  local _begin = "<font color=\"" .. nx_string(color) .. "\">"
  local _end = "</font>"
  text = nx_string(_begin) .. nx_string(text) .. nx_string(_end)
  return text
end
function get_key_state_text(role, prop, key_text, change_color)
  local color = COLOR_White
  if nx_find_custom(role, prop) and nx_custom(role, prop) then
    color = change_color
  end
  return get_text_by_color(key_text, color)
end
function get_key_state(role)
  local out_text = ""
  local change_color = COLOR_Red
  out_text = out_text .. get_key_state_text(role, "press_w", "W ", change_color)
  out_text = out_text .. get_key_state_text(role, "press_s", "S ", change_color)
  out_text = out_text .. get_key_state_text(role, "press_q", "A ", change_color)
  out_text = out_text .. get_key_state_text(role, "press_e", "D ", change_color)
  out_text = out_text .. get_key_state_text(role, "press_a", "Q ", change_color)
  out_text = out_text .. get_key_state_text(role, "press_d", "E ", change_color)
  change_color = COLOR_Black
  out_text = out_text .. "<br>" .. "real_key = "
  out_text = out_text .. get_key_state_text(role, "update_w", "W ", change_color)
  out_text = out_text .. get_key_state_text(role, "update_s", "S ", change_color)
  out_text = out_text .. get_key_state_text(role, "update_q", "A ", change_color)
  out_text = out_text .. get_key_state_text(role, "update_e", "D ", change_color)
  out_text = out_text .. get_key_state_text(role, "update_a", "Q ", change_color)
  out_text = out_text .. get_key_state_text(role, "update_d", "E ", change_color)
  return out_text
end
function create_face_effect(role)
  if nx_find_custom(role, "face_effect") and nx_is_valid(role.face_effect) then
    return
  end
  role.face_effect = nx_execute("game_effect", "create_pos_follow_effect_by_target", "npcitem002", -1, role, 0, 10, 0, 0, 0, 0, false)
end
function update_face_effect(role)
  if not nx_find_custom(role, "face_effect") then
    return
  end
  if nx_is_valid(role.face_effect) then
    role.face_effect:SetAngle(0, role.face_angle, 0)
  end
end
function on_btn_fight_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_test\\form_fight_error_info")
end
