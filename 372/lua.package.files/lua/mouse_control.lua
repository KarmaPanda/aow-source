require("define\\object_type_define")
require("share\\npc_type_define")
require("tips_data")
require("util_functions")
local ROAD_SIGN_TYPE = 44
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function show_road_sign_info(new_pick_id, old_pick_id, mouse_x, mouse_y)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local gui = nx_value("gui")
  if nx_is_valid(new_pick_id) then
    local client_ident = game_visual:QueryRoleClientIdent(new_pick_id)
    if client_ident == "" then
      nx_execute("tips_game", "hide_tip")
      gui.Cursor = "Default"
      return
    end
    local client_scene_obj = game_client:GetSceneObj(client_ident)
    if nx_is_valid(client_scene_obj) then
      local npc_type = nx_number(client_scene_obj:QueryProp("NpcType"))
      if npc_type == ROAD_SIGN_TYPE then
        handle_road_sign_npc(new_pick_id, mouse_x, mouse_y)
        return
      end
    end
  end
  if nx_is_valid(old_pick_id) and not nx_is_valid(new_pick_id) then
    local client_ident = game_visual:QueryRoleClientIdent(old_pick_id)
    if client_ident == "" then
      nx_execute("tips_game", "hide_tip")
      gui.Cursor = "Default"
      return
    end
    local client_scene_obj = game_client:GetSceneObj(client_ident)
    if nx_is_valid(client_scene_obj) then
      local npc_type = nx_number(client_scene_obj:QueryProp("NpcType"))
      if npc_type == ROAD_SIGN_TYPE then
        nx_execute("tips_game", "hide_tip")
        gui.Cursor = "Default"
      end
    end
  end
end
function change_mouse_style_by_scene_pick(new_pick_id, mouse_x, mouse_y)
  local gui = nx_value("gui")
  if nx_is_valid(new_pick_id) then
    local game_client = nx_value("game_client")
    local game_visual = nx_value("game_visual")
    local client_player = game_client:GetPlayer()
    local client_ident = game_visual:QueryRoleClientIdent(new_pick_id)
    if client_ident == "" then
      gui.Cursor = "Default"
      return 0
    end
    local client_scene_obj = game_client:GetSceneObj(client_ident)
    if nx_id_equal(client_player, client_scene_obj) then
      return 0
    end
    local distance = get_distance(client_player, client_scene_obj)
    local buffer_effect = nx_value("BufferEffect")
    local buff_cursor = buffer_effect:GetBufferCursor(new_pick_id)
    if buff_cursor ~= nil and buff_cursor ~= "" then
      gui.Cursor = buff_cursor
      return 1
    end
    if nx_is_valid(client_scene_obj) then
      local obj_type = nx_number(client_scene_obj:QueryProp("Type"))
      if obj_type == TYPE_ITEM then
        gui.Cursor = "Hand"
      elseif obj_type == TYPE_NPC then
        local fight = nx_value("fight")
        local can_attack = fight:CanAttackNpc(client_player, client_scene_obj)
        local script_type = get_npc_script_type(client_scene_obj)
        if can_attack and script_type ~= "SkinableNpc" then
          if client_scene_obj:FindProp("Dead") == false and nx_int(client_scene_obj:QueryProp("Dead")) == nx_int(0) then
            gui.Cursor = "Attack"
          elseif client_scene_obj:FindProp("CanPick") then
            local can_pick = 0 < nx_number(client_scene_obj:QueryProp("CanPick"))
            local pick_member = client_scene_obj:QueryProp("PickMember")
            if can_pick and nx_execute("scene_obj_prop", "is_in_pick_member_list", pick_member) then
              local range = 2
              if client_scene_obj:FindProp("OpenRange") then
                range = nx_number(client_scene_obj:QueryProp("OpenRange"))
              else
                range = get_range("pickrange")
              end
              if range < 2 then
                range = 2
              end
              gui.Cursor = distance <= range and "pick" or "pick1"
            end
          end
        elseif script_type == "SkinableNpc" then
          if client_scene_obj:FindProp("Dead") == false and nx_int(client_scene_obj:QueryProp("Dead")) == nx_int(0) then
            gui.Cursor = "Attack"
          else
            if nx_execute("form_stage_main\\form_life\\form_job_main_new", "find_life_job", "sh_lh") then
              local range = nx_number(client_scene_obj:QueryProp("SkinRange"))
              gui.Cursor = distance <= range and "Skin" or "Skin1"
            end
            local pick_member = client_scene_obj:QueryProp("PickMember")
            if nx_execute("scene_obj_prop", "is_in_pick_member_list", pick_member) and client_scene_obj:FindProp("CanPick") and nx_int(client_scene_obj:QueryProp("CanPick")) == nx_int(1) then
              local drop_count = nx_execute("form_stage_main\\form_pick\\form_droppick", "can_player_pickup")
              if nx_int(drop_count) ~= nx_int(0) then
                local range = get_range("pickrange")
                gui.Cursor = distance <= range and "pick" or "pick1"
              end
            end
          end
        elseif script_type == "EscortNpc" then
          gui.Cursor = "mend"
        elseif script_type == "CropNpc" then
          local CropType = client_scene_obj:QueryProp("CropType")
          local CropTempState = client_scene_obj:QueryProp("CropTempState")
          local range = nx_number(client_scene_obj:QueryProp("GatherRange"))
          gui.Cursor = distance <= range and "pick" or "pick1"
          if 1 == CropType then
            if CropTempState == 1 then
              gui.Cursor = distance <= range and "pestis" or "pestis1"
            elseif CropTempState == 256 then
              gui.Cursor = distance <= range and "weeding" or "weeding1"
            end
          elseif CropTempState == 1 then
            gui.Cursor = distance <= range and "pestis" or "pestis1"
          elseif CropTempState == 256 then
            gui.Cursor = distance <= range and "feed" or "feed1"
          end
        elseif script_type == "MineNpc" then
          local range = nx_number(client_scene_obj:QueryProp("GatherRange"))
          local cur = get_mousetype_from_ini(client_scene_obj, false)
          if distance > range then
            cur = cur .. "1"
          end
          gui.Cursor = cur
        elseif client_scene_obj:FindProp("OpenRange") then
          local range = nx_number(client_scene_obj:QueryProp("OpenRange"))
          local cur = get_mousetype_from_ini(client_scene_obj, false)
          if range < 2 then
            range = 2
          end
          if distance > range then
            cur = cur .. "1"
          end
          gui.Cursor = cur
        else
          gui.Cursor = get_mousetype_from_ini(client_scene_obj, true)
        end
        if client_scene_obj:QueryProp("NpcType") == NpcType180 then
          local host_name = client_scene_obj:QueryProp("HostName")
          local player_name = client_player:QueryProp("Name")
          if nx_widestr(host_name) == nx_widestr(player_name) then
            local range = get_range("riderange")
            gui.Cursor = distance <= range and "rideup" or "rideup1"
          end
        end
        if not client_scene_obj:FindProp("HasKarma") then
          return 0
        end
        local has_karma = client_scene_obj:QueryProp("HasKarma")
        if 0 >= tonumber(has_karma) then
          return 0
        end
        local configid = client_scene_obj:QueryProp("ConfigID")
        local ItemQuery = nx_value("ItemQuery")
        if not nx_is_valid(ItemQuery) then
          return 0
        end
        local bExist = ItemQuery:FindItemByConfigID(nx_string(configid))
        if not bExist then
          return 0
        end
        local text = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("script"))
        if text == "CommonNpc" then
          local game_visual = nx_value("game_visual")
          if not nx_is_valid(game_visual) then
            return 0
          end
          local visual_scene_obj = game_visual:GetSceneObj(nx_string(client_scene_obj.Ident))
          if not nx_is_valid(visual_scene_obj) then
            return 0
          end
          if not nx_find_custom(visual_scene_obj, "nearest_get_npc_karma_time") or os.difftime(os.time(), visual_scene_obj.nearest_get_npc_karma_time) > 5 then
            nx_execute("custom_sender", "custom_get_npc_karma_value", client_scene_obj.Ident)
            visual_scene_obj.nearest_get_npc_karma_time = os.time()
          end
          if not nx_find_custom(visual_scene_obj, "karma_value") then
            return 0
          end
          if not nx_find_custom(visual_scene_obj, "balloon_name") then
            return 0
          end
          local ball = visual_scene_obj.balloon_name
          if not nx_is_valid(ball) then
            return 0
          end
          local groupbox_karma = ball.Control:Find("groupbox_karma")
          if not nx_is_valid(groupbox_karma) then
            return 0
          end
          groupbox_karma.Visible = true
          local scene = visual_scene_obj.scene
          if nx_is_valid(scene) then
            local game_effect = scene.game_effect
            if nx_is_valid(game_effect) then
              game_effect:HideEffect(nx_string(client_scene_obj.Ident), visual_scene_obj, visual_scene_obj)
            end
          end
          local head_game = nx_value("HeadGame")
          if nx_is_valid(head_game) then
            head_game:RefreshDataAndPos(visual_scene_obj, false)
          end
        end
        if nx_string(gui.Cursor) == nx_string(0) or nx_string(gui.Cursor) == nx_string("") then
          gui.Cursor = "Default"
        end
      elseif obj_type == TYPE_PLAYER then
        local fight = nx_value("fight")
        local can_attack = fight:CanAttackPlayer(client_player, client_scene_obj)
        if can_attack then
          gui.Cursor = "Attack"
        else
          gui.Cursor = "Talk"
        end
      end
      return 1
    end
    gui.Cursor = "Default"
  else
    gui.Cursor = "Default"
  end
end
function get_npc_script_type(client_scene_obj)
  local config = client_scene_obj:QueryProp("ConfigID")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(config))
  if not bExist then
    return ""
  end
  local script = ItemQuery:GetItemPropByConfigID(nx_string(config), nx_string("script"))
  return nx_string(script)
end
function get_mousetype_from_ini(client_scene_obj, autotrans)
  local mouse_type = "Default"
  local range = 0
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return mouse_type
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return mouse_type
  end
  if not nx_is_valid(client_scene_obj) then
    return mouse_type
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\cursor\\cursor_rule_new.ini")
  if not nx_is_valid(ini) then
    return mouse_type
  end
  local select_state = client_scene_obj:QueryProp("CursorShape")
  local sec_index = ini:FindSectionIndex("SelectState")
  mouse_type = ini:ReadString(sec_index, nx_string(select_state), "Default")
  local str_lst = util_split_string(nx_string(mouse_type), ",")
  if table.getn(str_lst) >= 1 then
    mouse_type = str_lst[1]
  end
  if table.getn(str_lst) > 1 and str_lst[2] ~= "" then
    range = get_range(str_lst[2])
  end
  local distance = get_distance(client_player, client_scene_obj)
  if 0 < distance and 0 < range and range < distance and mouse_type ~= "Default" and ini:FindSectionItemIndex(sec_index, mouse_type .. "1") and autotrans then
    mouse_type = mouse_type .. "1"
  end
  return mouse_type
end
function get_range(range_type)
  local range = "0"
  local ini = nx_execute("util_functions", "get_ini", "ini\\cursor\\cursor_rule_new.ini")
  if nx_is_valid(ini) and ini:FindSection("Distance") then
    local sec_index = ini:FindSectionIndex("Distance")
    range = ini:ReadString(sec_index, nx_string(range_type), "0")
  end
  return nx_number(range)
end
function set_mouse_type(TypeInfo)
  console_log("set_mouse_type")
  if nx_string(TypeInfo) == "" then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if gui:FindCursor(nx_string(TypeInfo)) == true then
    gui.Cursor = nx_string(TypeInfo)
  end
end
function mouse_action_change(action)
  if nx_find_value("Mouse_State_Value") == false then
    nx_set_value("Mouse_State_Value", "None")
  end
  if nx_string(action) == "LeftDown" then
    nx_set_value("Mouse_State_Value", "None")
  elseif nx_string(action) == "RightDown" then
    nx_set_value("Mouse_State_Value", "RightDown")
  elseif nx_string(action) == "RightUp" then
    nx_set_value("Mouse_State_Value", "None")
  elseif nx_string(action) == "Move" and nx_value("Mouse_State_Value") == "RightDown" then
    action = "RightDownMove"
  end
  return nx_string(action)
end
function form_mouse_type_handle(Form_Capture, action)
  local gui = nx_value("gui")
  action = mouse_action_change(action)
  local obj = Form_Capture
  while nx_is_valid(obj) do
    if nx_name(obj) == "Form" then
      local name = nx_string(nx_script_name(obj))
      local mouse_type = is_need_change_form_mouse(name, action)
      if mouse_type ~= "" then
        set_mouse_type(mouse_type)
      end
    end
    obj = obj.Parent
  end
end
function is_need_change_form_mouse(name, action)
  local ini = nx_execute("util_functions", "get_ini", "ini\\cursor\\cursor_rule.ini")
  if not nx_is_valid(ini) or not ini:FindSection(name) then
    return ""
  end
  local mouse_type = ini:ReadString(nx_string(name), nx_string(action), "")
  if mouse_type == "" then
    return ""
  end
  return nx_string(mouse_type)
end
function handle_road_sign_npc(road_sign, mouse_x, mouse_y)
  if mouse_x == nil or mouse_y == nil then
    nx_msgbox(get_msg_str("msg_433"))
    return
  end
  local gui = nx_value("gui")
  local road_sign_npc_manager = nx_value("RoadSignNpcManager")
  local text = road_sign_npc_manager:GetSelectRoadBoardText(road_sign, mouse_x, mouse_y)
  if text ~= "" then
    nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText(text), mouse_x - 64, mouse_y - 68)
    gui.Cursor = "roadsign2"
  else
    nx_execute("tips_game", "hide_tip")
    gui.Cursor = "Default"
  end
end
function UpDateNpcHeadKarma(npc, karma)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local visual_scene_obj = game_visual:GetSceneObj(nx_string(npc))
  if not nx_is_valid(visual_scene_obj) then
    return 0
  end
  visual_scene_obj.karma_value = nx_int(karma)
  if not nx_find_custom(visual_scene_obj, "balloon_name") then
    return 0
  end
  local ball = visual_scene_obj.balloon_name
  if not nx_is_valid(ball) then
    return 0
  end
  local groupbox_karma = ball.Control:Find("groupbox_karma")
  if not nx_is_valid(groupbox_karma) then
    return 0
  end
  local label_fstip = groupbox_karma:Find("pbar_fstip")
  if not nx_is_valid(label_fstip) then
    return 0
  end
  local lbl_face = groupbox_karma:Find("lbl_face")
  if not nx_is_valid(lbl_face) then
    return 0
  end
  set_karma_groupbox(label_fstip, lbl_face, karma)
end
function set_karma_groupbox(label_fstip, label_face, karma_value)
  if not nx_is_valid(label_fstip) then
    return
  end
  if not nx_is_valid(label_face) then
    return
  end
  local photo = ""
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("Karma")
  if sec_index < 0 then
    sec_index = "0"
  end
  local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(GroupMsgData)) do
    local stepData = util_split_string(GroupMsgData[i], ",")
    if nx_int(stepData[1]) <= nx_int(karma_value) and nx_int(karma_value) <= nx_int(stepData[2]) then
      photo = nx_string(stepData[4])
    end
  end
  local KarmaMaxValue = 200000
  local index_max = ini:FindSectionIndex("KarmaValue")
  if 0 <= index_max then
    KarmaMaxValue = ini:GetSectionItemValue(index_max, nx_string("MaxValue"))
  end
  label_fstip.Minimum = 0
  label_fstip.Maximum = nx_int(KarmaMaxValue)
  label_fstip.Value = nx_int(KarmaMaxValue) / 2 + nx_int(karma_value)
  if photo == "" then
    return
  end
  label_face.BackImage = photo
  local radio = nx_number(label_fstip.Value) / nx_number(label_fstip.Maximum)
  local radius = (label_fstip.Width + 10) / 2
  local diff = radio - 0.5
  local edge = math.abs(diff) * radius * 2
  local height = math.pow(radius * radius - edge * edge, 0.5)
  local top = label_fstip.Top + (radius - height)
  local left = label_fstip.Left + label_fstip.Width * radio
  label_face.Left = left - label_face.Width / 2
  label_face.Top = top - label_face.Height / 2 + 5
  if 0 > label_face.Left then
    label_face.Left = 0
  end
  if label_face.Left > label_fstip.Width - 13 then
    label_face.Left = label_fstip.Width - 13
  end
  if label_face.Top > 75 - label_face.Height then
    label_face.Top = 75 - label_face.Height
  end
end
function get_distance(obj1, obj2)
  if not nx_is_valid(obj1) or not nx_is_valid(obj2) then
    return 100000000
  end
  local game_visual = nx_value("game_visual")
  local obj1_visual = game_visual:GetSceneObj(obj1.Ident)
  local obj2_visual = game_visual:GetSceneObj(obj2.Ident)
  if not nx_is_valid(obj1_visual) or not nx_is_valid(obj2_visual) then
    return 100000000
  end
  local offX = obj1_visual.PositionX - obj2_visual.PositionX
  local offY = obj1_visual.PositionY - obj2_visual.PositionY
  local offZ = obj1_visual.PositionZ - obj2_visual.PositionZ
  return math.sqrt(offX * offX + offY * offY + offZ * offZ)
end
