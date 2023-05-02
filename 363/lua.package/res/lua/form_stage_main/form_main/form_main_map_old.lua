require("const_define")
require("util_gui")
require("define\\object_type_define")
require("define\\task_npc_flag")
require("share\\logicstate_define")
local SHOW_SCEHE_OBJ_COUNT = 50
function main_form_init(form)
  form.Fixed = true
  return 1
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_open(form)
  form.roundbox_smallmap.TerrainWidth = 0
  form.roundbox_smallmap.TerrainHeight = 0
  form.roundbox_smallmap.TerrainStartX = 0
  form.roundbox_smallmap.TerrainStartZ = 0
  local timer = nx_value(GAME_TIMER)
  nx_execute("form_stage_main\\form_main\\form_main_map", "on_update_time", form, -1, -1)
  timer:Register(60000, -1, "form_stage_main\\form_main\\form_main_map", "on_update_time", form, -1, -1)
  timer:Register(1000, -1, "form_stage_main\\form_main\\form_main_map", "on_update_position", form, -1, -1)
  timer:Register(500, -1, "form_stage_main\\form_main\\form_main_map", "on_update_map", form, -1, -1)
  local gui = nx_value("gui")
  for i = 1, SHOW_SCEHE_OBJ_COUNT do
    local lbl = gui:Create("Label")
    lbl.Name = "lbl_scene_obj_" .. i
    lbl.AutoSize = true
    lbl.Transparent = false
    lbl.ClickEvent = true
    nx_bind_script(lbl, "form_stage_main\\form_main\\form_main_map")
    nx_callback(lbl, "on_click", "on_lbl_click")
    form.roundbox_smallmap.Parent:Add(lbl)
    form.roundbox_smallmap.Parent:ToBack(lbl)
  end
  form.roundbox_smallmap.Parent:ToBack(form.roundbox_smallmap)
  form.roundbox_smallmap.ZoomWidth = 0.66
  form.roundbox_smallmap.ZoomHeight = 0.66
  form.roundbox_smallmap.Parent.BlendAlpha = 220
  form.lbl_smallmap_role.Parent:ToFront(form.lbl_smallmap_role)
  form.mltbox_area_limit.Visible = false
end
function main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_main\\form_main_map", "on_form_main_update_time", form)
  timer:UnRegister("form_stage_main\\form_main\\form_main_map", "on_form_main_update_pos", form)
  timer:UnRegister("form_stage_main\\form_main\\form_main_map", "on_map_update_role_pos", form.groupbox_smallmap)
  timer:UnRegister("form_stage_main\\form_main\\form_main_map", "hide_area_limit", form)
end
function trans_pos_to_map(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local map_x = map_width - (x - terrain_start_x) / terrain_width * map_width
  local map_z = (z - terrain_start_z) / terrain_height * map_height
  return map_x, map_z
end
function trans_pos_to_scene(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local pos_x = x * terrain_width / map_width + terrain_start_x
  local pos_z = z * terrain_height / map_height + terrain_start_z
  return pos_x, pos_z
end
function get_pos_in_map_pic(x, z, pic_map)
  local selfZoomWidth = 1
  local selfZoomHeight = 1
  local map_x, map_z
  map_x, map_z = trans_pos_to_map(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function get_pos_in_map(x, z, pic_map)
  local selfZoomWidth = 1
  local selfZoomHeight = 1
  local map_x, map_z
  map_x, map_z = trans_pos_to_map(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = map_x * pic_map.ZoomWidth
  local sz = map_z * pic_map.ZoomHeight
  return map_x, map_z
end
function on_update_map(form, param1, param2)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  if nx_is_valid(visual_player) then
    form.lbl_smallmap_role.AngleZ = -visual_player.AngleY + math.pi
  end
  local player_x = visual_player.PositionX
  local player_z = visual_player.PositionZ
  local map_x, map_z = get_pos_in_map(player_x, player_z, form.roundbox_smallmap)
  local center_x = map_x
  local center_z = map_z
  local map_width = form.roundbox_smallmap.ImageWidth
  local map_height = form.roundbox_smallmap.ImageHeight
  if center_x < form.lbl_smallmap_role.Width / 2 then
    center_x = form.lbl_smallmap_role.Width / 2
  end
  if center_x > map_width - form.lbl_smallmap_role.Width / 2 then
    center_x = map_width - form.lbl_smallmap_role.Width / 2
  end
  if center_z < form.lbl_smallmap_role.Height / 2 then
    center_z = form.lbl_smallmap_role.Height / 2
  end
  if center_z > map_height - form.lbl_smallmap_role.Height / 2 then
    center_z = map_height - form.lbl_smallmap_role.Height / 2
  end
  form.roundbox_smallmap.CenterX = nx_int(center_x)
  form.roundbox_smallmap.CenterY = nx_int(center_z)
  show_scene_obj(form, center_x, center_z)
  return 1
end
function on_update_time(form, param1, param2)
  local time = os.date("%H:%M")
  form.lbl_time.Text = nx_widestr(time)
end
function on_update_position(form, param1, param2)
  local game_visual = nx_value("game_visual")
  local player = game_visual:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local map_x, map_z = get_pos_in_map(player.PositionX, player.PositionZ, form.roundbox_smallmap)
  local strpos = string.format("%d,%d", player.PositionX, player.PositionZ)
  form.lbl_position.Text = nx_widestr(strpos)
end
function on_btn_zoom_in_click(btn)
  btn.MouseDown = false
end
function on_btn_zoom_in_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_zoom_in_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local zoom = form.roundbox_smallmap.ZoomWidth
  while btn.MouseDown do
    local elapse = nx_pause(0)
    zoom = zoom + 1 * elapse
    if 1.5 < zoom then
      form.roundbox_smallmap.ZoomWidth = 1.5
      form.roundbox_smallmap.ZoomHeight = 1.5
      break
    end
    form.roundbox_smallmap.ZoomWidth = zoom
    form.roundbox_smallmap.ZoomHeight = zoom
  end
  return 1
end
function on_btn_zoom_out_click(btn)
  btn.MouseDown = false
end
function on_btn_zoom_out_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_zoom_out_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local zoom = form.roundbox_smallmap.ZoomWidth
  while btn.MouseDown do
    local elapse = nx_pause(0)
    zoom = zoom - 1 * elapse
    if zoom < 0.5 then
      form.roundbox_smallmap.ZoomWidth = 0.5
      form.roundbox_smallmap.ZoomHeight = 0.5
      break
    end
    form.roundbox_smallmap.ZoomWidth = zoom
    form.roundbox_smallmap.ZoomHeight = zoom
  end
  return 1
end
function on_btn_gm_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_gm\\form_gm")
  return 1
end
function on_btn_bigmap_click(btn)
  nx_execute("freshman_help", "close_scene_map_effect")
  util_auto_show_hide_form("form_stage_main\\form_map\\form_map_scene")
end
function on_btn_party_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_huodong")
end
function on_btn_path_finding_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_main\\form_main_path")
end
function on_btn_herolist_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_sequence_table")
end
function on_btn_smallgame_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_smallgame\\form_smallgame")
end
function on_btn_versus_click(btn)
  util_auto_show_hide_form("form_versus")
end
function on_btn_lottery_click(btn)
  util_auto_show_hide_form("form_trustee")
end
function on_btn_shop_click(btn)
  util_auto_show_hide_form("form_sns_main")
  local form = nx_value("form_sns_main")
  if nx_is_valid(form) then
    nx_execute("form_sns_main", "on_sub_page_btn_click", form.btn_13)
  end
end
function on_click_btn_mail(form)
  util_auto_show_hide_form("form_sns_main")
  local form = nx_value("form_sns_main")
  if nx_is_valid(form) then
    nx_execute("form_sns_main", "on_sub_page_btn_click", form.btn_13)
  end
end
function on_cbtn_visible_checked_changed(btn)
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "map_limit") and role.map_limit == true then
    return
  end
  local form = btn.ParentForm
  form.groupbox_smallmap.Visible = btn.Checked
  form.btn_zoom_out.Visible = btn.Checked
  form.btn_zoom_in.Visible = btn.Checked
  form.lbl_1.Visible = btn.Checked
  if not form.groupbox_smallmap.Visible then
    form.mltbox_area_limit.Visible = false
  end
end
function show_scene_obj(form, center_x, center_z)
  local gui = nx_value("gui")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_player = game_client:GetPlayer()
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(visual_player) then
    return
  end
  local roundbox_smallmap = form.roundbox_smallmap
  local scale = roundbox_smallmap.ZoomWidth
  local client_obj_lst = game_scene:GetSceneObjList()
  local lbl_scene_obj_index = 1
  for i, client_obj in pairs(client_obj_lst) do
    local client_obj = client_obj_lst[i]
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) and not nx_id_equal(visual_obj, visual_player) then
      local x = visual_obj.PositionX
      local z = visual_obj.PositionZ
      local map_x, map_z = get_pos_in_map(x, z, form.roundbox_smallmap)
      local sx = (map_x - center_x) * scale
      local sz = (map_z - center_z) * scale
      local dist = math.sqrt(sx * sx + sz * sz)
      if dist <= roundbox_smallmap.Width / 2 then
        local back_image = get_scene_obj_image(client_player, client_obj)
        if string.len(back_image) > 0 then
          local lbl = roundbox_smallmap.Parent:Find("lbl_scene_obj_" .. lbl_scene_obj_index)
          if nx_is_valid(lbl) then
            lbl.BackImage = back_image
            lbl.AbsLeft = nx_int(roundbox_smallmap.AbsLeft + sx + (roundbox_smallmap.Width - lbl.Width) / 2)
            lbl.AbsTop = nx_int(roundbox_smallmap.AbsTop + sz + (roundbox_smallmap.Height - lbl.Height) / 2)
            if client_obj:FindProp("ConfigID") then
              lbl.HintText = gui.TextManager:GetFormatText(client_obj:QueryProp("ConfigID"))
            elseif client_obj:FindProp("Name") then
              lbl.HintText = client_obj:QueryProp("Name")
            end
            lbl.Visible = true
            lbl.object = visual_obj
            lbl_scene_obj_index = lbl_scene_obj_index + 1
          end
        end
      end
    end
    if 50 < lbl_scene_obj_index then
      break
    end
  end
  if lbl_scene_obj_index <= SHOW_SCEHE_OBJ_COUNT then
    for i = lbl_scene_obj_index, SHOW_SCEHE_OBJ_COUNT do
      local lbl = roundbox_smallmap.Parent:Find("lbl_scene_obj_" .. i)
      lbl.Visible = false
    end
  end
  local x = visual_player.PositionX
  local z = visual_player.PositionZ
  local map_x, map_z = get_pos_in_map(x, z, form.roundbox_smallmap)
  local sx = (map_x - center_x) * scale
  local sz = (map_z - center_z) * scale
  local lbl_smallmap_role = form.lbl_smallmap_role
  lbl_smallmap_role.AbsLeft = nx_int(roundbox_smallmap.AbsLeft + sx + (roundbox_smallmap.Width - lbl_smallmap_role.Width) / 2)
  lbl_smallmap_role.AbsTop = nx_int(roundbox_smallmap.AbsTop + sz + (roundbox_smallmap.Height - lbl_smallmap_role.Height) / 2)
end
function get_scene_obj_image(client_player, client_obj)
  local target_type = 0
  if client_obj:FindProp("Type") then
    target_type = client_obj:QueryProp("Type")
  end
  if target_type == TYPE_PLAYER then
    if nx_execute("fight", "can_attack_player", client_player, client_obj) then
      return "gui\\map\\icon\\q02.png"
    else
      return "gui\\map\\icon\\q03.png"
    end
  elseif target_type == TYPE_NPC then
    if nx_execute("fight", "can_attack_npc", client_player, client_obj) then
      return "gui\\map\\icon\\q02.png"
    else
      local game_visual = nx_value("game_visual")
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      if nx_is_valid(visual_obj) and nx_find_custom(visual_obj, "TaskFlag") then
        local task_flag = visual_obj.TaskFlag
        if task_flag == TASKNPC_FLAG_CANSUBMIT then
          return "gui\\map\\icon\\w02.png"
        elseif task_flag == TASKNPC_FLAG_CANSUBMIY_REPEAT then
          return "gui\\map\\icon\\w04.png"
        elseif task_flag == TASKNPC_FLAG_NOT_COMPLETE then
          return "gui\\map\\icon\\w03.png"
        elseif task_flag == TASKNPC_FLAG_CANACCEPT then
          return "gui\\map\\icon\\j02.png"
        elseif task_flag == TASKNPC_FLAG_CANACCEPT_REPEAT then
          return "gui\\map\\icon\\j04.png"
        elseif task_flag == TASKNPC_FLAG_CANT_ACCEPT then
          return "gui\\map\\icon\\j01.png"
        elseif task_flag == TASKNPC_FLAG_LOW_LEVEL then
          return "gui\\map\\icon\\j03.png"
        end
      end
      return "gui\\map\\icon\\q01.png"
    end
  end
  return ""
end
function on_lbl_click(lbl)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindProp("LastObject") or not nx_id_equal(client_player:QueryProp("LastObject"), nx_object(lbl.object.client_ident)) then
    nx_execute("custom_sender", "custom_select", lbl.object.client_ident)
  end
  local trace = nx_value("path_finding")
  trace:TraceTarget(lbl.object, 2, "", "")
end
function on_roundbox_smallmap_left_up(round_map, offset_x, offset_y)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  local terrain_width = round_map.TerrainWidth
  local terrain_height = round_map.TerrainHeight
  local terrain_start_x = round_map.TerrainStartX
  local terrain_start_z = round_map.TerrainStartZ
  local map_width = round_map.ImageWidth
  local map_height = round_map.ImageHeight
  local scale = round_map.ZoomWidth
  local inter_xpos = -(round_map.Width / 2 - offset_x)
  local inter_ypos = round_map.Height / 2 - offset_y
  inter_xpos = map_width - round_map.CenterX - inter_xpos / scale
  inter_ypos = round_map.CenterY - inter_ypos / scale
  inter_xpos = terrain_start_x + inter_xpos * terrain_width / map_width
  inter_zpos = terrain_start_z + inter_ypos * terrain_height / map_height
  nx_execute("trace", "trace_position", inter_xpos, -10000, inter_zpos, 0, "", "")
end
function on_roundbox_smallmap_get_capture(round_map)
end
function on_roundbox_smallmap_lost_capture(round_map)
  nx_execute("tips_game", "hide_tip")
end
function on_roundbox_smallmap_mouse_move(round_map, offset_x, offset_y)
  local terrain_width = round_map.TerrainWidth
  local terrain_height = round_map.TerrainHeight
  local terrain_start_x = round_map.TerrainStartX
  local terrain_start_z = round_map.TerrainStartZ
  local map_width = round_map.ImageWidth
  local map_height = round_map.ImageHeight
  local scale = round_map.ZoomWidth
  local inter_xpos = -(round_map.Width / 2 - offset_x)
  local inter_ypos = round_map.Height / 2 - offset_y
  console_log("round_map.CenterX=" .. nx_string(round_map.CenterX) .. " round_map.CenterY=" .. nx_string(round_map.CenterY))
  inter_xpos = map_width - round_map.CenterX - inter_xpos / scale
  inter_ypos = round_map.CenterY - inter_ypos / scale
  inter_xpos = terrain_start_x + inter_xpos * terrain_width / map_width
  inter_ypos = terrain_start_z + inter_ypos * terrain_height / map_height
  nx_execute("tips_game", "show_text_tip", nx_widestr(nx_string(nx_int(inter_xpos)) .. "\163\172" .. nx_string(nx_int(inter_ypos))), round_map.AbsLeft + offset_x, round_map.AbsTop + offset_y, 60, 32)
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "set_current_scene")
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local scale = form.roundbox_smallmap.ZoomWidth
  local gui = nx_value("gui")
  local scene_config = client_scene:QueryProp("ConfigID")
  local scene_name = gui.TextManager:GetFormatText(scene_config)
  form.lbl_map_name.Text = nx_widestr(scene_name)
  local resource = client_scene:QueryProp("Resource")
  local map_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  form.roundbox_smallmap.Image = map_name
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  ini:LoadFromFile()
  form.roundbox_smallmap.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.roundbox_smallmap.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.roundbox_smallmap.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.roundbox_smallmap.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  form.roundbox_smallmap.ZoomWidth = 1
  form.roundbox_smallmap.ZoomHeight = 1
  nx_destroy(ini)
  on_update_map(form, -1, -1)
end
function on_btn_bigmap_push(button)
end
function on_btn_bigmap_drag_move(button, x, y)
end
function on_btn_area_limit_click(btn)
  local visible = btn.NormalImage == "gui\\common\\scrollbar\\button\\fy01-out.png"
  if visible then
    local form_map = nx_value("form_stage_main\\form_main\\form_main_map")
    if nx_is_valid(form_map) then
      nx_execute(nx_current(), "hide_area_limit", form_map)
    end
  else
    nx_execute(nx_current(), "show_area_limit")
  end
end
function clear_area_limit_info()
  local form_map = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form_map) then
    return
  end
  form_map.mltbox_area_limit:Clear()
end
function add_area_limit_info(info)
  local form_map = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form_map) then
    return
  end
  local info_list = form_map.mltbox_area_limit
  info_list:AddHtmlText(info, -1)
  if info_list.ItemCount > 50 then
    info_list:DelHtmlItem(0)
  end
end
function show_area_limit()
  if nx_running(nx_current(), "show_area_limit") then
    return
  end
  if nx_running(nx_current(), "hide_area_limit") then
    nx_kill(nx_current(), "hide_area_limit")
  end
  local form_map = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form_map) then
    return
  end
  if not form_map.groupbox_smallmap.Visible then
    return
  end
  if not form_map.mltbox_area_limit.Visible then
    form_map.mltbox_area_limit.Visible = true
  end
  local origin_left = form_map.mltbox_area_limit.Left
  local target_left = form_map.roundbox_smallmap.Left + form_map.roundbox_smallmap.Width + 8
  local distance = target_left - origin_left
  if 0.1 < distance then
    local time_count = 0
    while time_count < 1 do
      form_map.mltbox_area_limit.Left = origin_left + distance * (time_count / 1)
      time_count = time_count + nx_pause(0.1)
    end
    form_map.mltbox_area_limit.Left = target_left
  end
  if not nx_is_valid(form_map) then
    return
  end
  form_map.btn_area_limit.NormalImage = "gui\\common\\scrollbar\\button\\fy01-out.png"
  form_map.btn_area_limit.FocusImage = "gui\\common\\scrollbar\\button\\fy01-on.png"
  form_map.btn_area_limit.PushImage = "gui\\common\\scrollbar\\button\\fy01-down.png"
  local timer = nx_value(GAME_TIMER)
  timer:Register(20000, 1, "form_stage_main\\form_main\\form_main_map", "hide_area_limit", form_map, -1, -1)
end
function hide_area_limit(form_map)
  if nx_running(nx_current(), "hide_area_limit") then
    return
  end
  if not nx_is_valid(form_map) then
    return
  end
  local origin_left = form_map.mltbox_area_limit.Left
  local target_left = form_map.roundbox_smallmap.Left + form_map.roundbox_smallmap.Width - form_map.mltbox_area_limit.Width
  local distance = target_left - origin_left
  local time_count = 0
  while time_count < 1 do
    form_map.mltbox_area_limit.Left = origin_left + distance * (time_count / 1)
    time_count = time_count + nx_pause(0.1)
  end
  if not nx_is_valid(form_map) then
    return
  end
  form_map.mltbox_area_limit.Left = target_left
  form_map.btn_area_limit.NormalImage = "gui\\common\\scrollbar\\button\\fy02-out.png"
  form_map.btn_area_limit.FocusImage = "gui\\common\\scrollbar\\button\\fy02-on.png"
  form_map.btn_area_limit.PushImage = "gui\\common\\scrollbar\\button\\fy02-down.png"
  form_map.mltbox_area_limit.Visible = false
end
