require("utils")
require("util_gui")
require("util_functions")
function main_form_init(self)
  local form_gather = nx_value("form_stage_main\\form_life\\form_job_gather")
  if not nx_is_valid(form_gather) then
    return
  end
  if nx_find_custom(form_gather, "node") then
    self.gather_id = form_gather.node.gather_list
  else
    self.gather_id = nil
  end
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  self.map_query = map_query
  self.btn_trace.dest_x = -10
  self.btn_trace.dest_z = -10
  local gui = nx_value("gui")
  local resource = client_scene:QueryProp("Resource")
  local scene_cfg_id = client_scene:QueryProp("ConfigID")
  local str_scene = gui.TextManager:GetText(nx_string(scene_cfg_id)) .. nx_widestr(": ")
  self.lbl_current_scene.Text = str_scene
  self.Left = (gui.Desktop.Width - self.Width) / 2
  self.Top = (gui.Desktop.Height - self.Height) / 2
  load_map_pic(self.pic_map, resource)
  init_groupmap_objs(self.pic_map.ParentForm, resource)
  on_update_role_position(self)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_role_position", self, -1, -1)
  update_big_map_trace(self)
  return 1
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_role_position", self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function load_map_pic(pic_map, resource)
  pic_map.ParentForm.current_map = resource
  local pic_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  pic_map.Image = pic_name
  local ini_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  local ini_file = get_ini(ini_name)
  if not nx_is_valid(ini_file) then
    return
  end
  local sec_index = ini_file:FindSectionIndex("Map")
  if sec_index < 0 then
    return
  end
  pic_map.TerrainStartX = ini_file:ReadInteger(sec_index, "StartX", 0)
  pic_map.TerrainStartZ = ini_file:ReadInteger(sec_index, "StartZ", 0)
  pic_map.TerrainWidth = ini_file:ReadInteger(sec_index, "Width", 1024)
  pic_map.TerrainHeight = ini_file:ReadInteger(sec_index, "Height", 1024)
  pic_map.CenterX = pic_map.ImageWidth / 2
  pic_map.CenterY = pic_map.ImageHeight / 2
end
function init_groupmap_objs(form, resource)
  local npc_type = form.map_query:GetNpcType(form.gather_id)
  local the_type = nx_string(npc_type)
  if form.map_query:HasNpcTypeInfo(the_type) then
    local tmp_photo = form.map_query:GetNpcTypeProp(the_type, "Photo")
    form.groupmap_objs:AddType(the_type, tmp_photo)
  end
  form.groupmap_objs:SetShape(1)
  form.groupmap_objs.MapControl = form.pic_map
  form.groupbox_map:ToFront(form.groupmap_objs)
  form.groupmap_objs:Clear()
  form.groupmap_objs.Left = form.pic_map.Left
  form.groupmap_objs.Width = form.pic_map.Width
  form.groupmap_objs.Top = form.pic_map.Top
  form.groupmap_objs.Height = form.pic_map.Height
  form.groupmap_objs:InitTerrain(form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  form.map_query:AddNpcForMap(resource, form.groupmap_objs, form.gather_id)
end
function on_groupmap_objs_mouse_in_obj(self, obj_type, id, npc_type, x, y, z)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local text = ""
  local str_id = ""
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if form.map_query:HasNpcTypeInfo(nx_string(npc_type)) then
    str_id = form.map_query:GetNpcTypeStrId(nx_string(npc_type))
    text = gui.TextManager:GetFormatText("[{@0:type}]{@1:name}({@2:x},{@3:y})", str_id, id, nx_int(x), nx_int(z))
  else
    text = gui.TextManager:GetFormatText("{@0:name}({@1:x},{@2:y})", nx_widestr(id), nx_int(x), nx_int(z))
  end
  if nx_string(text) ~= "" then
    local sx, sz = trans_scene_pos_to_map(x, z, form.pic_map)
    local AbsLeft = form.pic_map.AbsLeft + sx - 10
    local AbsTop = form.pic_map.AbsTop + sz - 60
    local show_tips = true
    if nx_find_custom(form.pic_map, "right_down") and form.pic_map.right_down == true then
      show_tips = false
    end
    if show_tips then
      nx_execute("tips_game", "show_text_tip", nx_widestr(text), AbsLeft, AbsTop, 0, form)
    end
  end
end
function on_groupmap_objs_mouse_out_obj(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_update_role_position(form, param1, param2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_role.x = visual_player.PositionX
  form.lbl_role.y = visual_player.PositionY
  form.lbl_role.z = visual_player.PositionZ
  set_lbl_position(form.lbl_role, form.pic_map)
  form.lbl_role.AngleZ = -visual_player.AngleY + math.pi
  if nx_find_custom(visual_player, "state") and visual_player.state == "trans" and nx_find_custom(client_player, "vislink") and nx_is_valid(client_player.vislink) then
    local vis_link = client_player.vislink
    local client_ident_link = game_visual:QueryRoleClientIdent(vis_link)
    local cli_link = game_client:GetSceneObj(client_ident_link)
    if nx_is_valid(cli_link) then
      local npc_type = cli_link:QueryProp("SubType")
      if npc_type ~= 0 then
      else
        form.lbl_role.AngleZ = form.lbl_role.AngleZ - math.pi / 2
      end
    end
  end
  form:ToFront(form.lbl_role)
  if math.abs(form.lbl_role.x - form.btn_trace.dest_x) < 5 and 5 > math.abs(form.lbl_role.z - form.btn_trace.dest_z) then
    form.btn_trace.Visible = false
  end
end
function set_lbl_position(label, pic_map)
  local form = pic_map.ParentForm
  if not nx_is_valid(label) then
    return
  end
  if not nx_find_custom(label, "x") and not nx_find_custom(label, "z") then
    return
  end
  local x = label.x
  local z = label.z
  local sx, sz = trans_scene_pos_to_map(label.x, label.z, pic_map)
  local gui = nx_value("gui")
  label.AbsLeft = pic_map.AbsLeft + sx - label.Width / 2
  label.AbsTop = pic_map.AbsTop + sz - label.Height / 2
end
function on_groupmap_objs_click_obj(self, obj_type, lab_id, npc_type, x, y, z)
  local form = nx_value("form_stage_main\\form_life\\form_map_gather")
  if not nx_is_valid(form) then
    return
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if npc_type == 0 then
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:FindPath(x, y, z, 0)
    end
  else
    local form = nx_value("form_stage_main\\form_life\\form_map_gather")
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:TraceTargetByID(form.current_map, x, y, z, 1.8, lab_id)
    end
  end
  set_dest_pos(form, x, z)
  update_big_map_trace(form)
end
function on_pic_map_left_up(self, x, y)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local sx = -(self.Width / 2 - x)
  local sz = self.Height / 2 - y
  local map_x = self.ImageWidth - self.CenterX - sx / self.ZoomWidth
  local map_z = self.CenterY - sz / self.ZoomHeight
  local pos_x, pos_z = trans_image_pos_to_scene(map_x, map_z, self.ImageWidth, self.ImageHeight, self.TerrainStartX, self.TerrainStartZ, self.TerrainWidth, self.TerrainHeight)
  local form = self.ParentForm
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "find_path_limit") and role.find_path_limit == true then
    return
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if trace_flag == 1 or trace_flag == 2 then
    path_finding:FindPath(pos_x, -10000, pos_z, 0)
  end
  set_dest_pos(form, pos_x, pos_z)
  update_big_map_trace(form)
end
function on_pic_map_mouse_move(self, x, y)
  local form = self.ParentForm
  if not nx_find_custom(self, "TerrainStartX") then
    return
  end
  local sx = -(self.Width / 2 - x)
  local sz = self.Height / 2 - y
  local map_x = self.ImageWidth - self.CenterX - sx / self.ZoomWidth
  local map_z = self.CenterY - sz / self.ZoomHeight
  local pos_x, pos_z = trans_image_pos_to_scene(map_x, map_z, self.ImageWidth, self.ImageHeight, self.TerrainStartX, self.TerrainStartZ, self.TerrainWidth, self.TerrainHeight)
  form.lbl_pos.Text = nx_widestr(nx_string(nx_int(pos_x)) .. "," .. nx_string(nx_int(pos_z)))
end
function on_btn_trace_get_capture(self)
  local form = self.ParentForm
  local map_query = form.map_query
  local x, z, npc_id, scene_id
  if not nx_find_custom(map_query, "x") then
    return
  end
  if not nx_find_custom(map_query, "z") then
    return
  end
  if not nx_find_custom(map_query, "scene_id") then
    return
  end
  x = map_query.x
  z = map_query.z
  scene_id = map_query.scene_id
  if nx_find_custom(map_query, "npc_id") then
    npc_id = map_query.npc_id
  end
  local text = "(" .. x .. "," .. z .. ")"
  text = nx_widestr(text)
  local gui = nx_value("gui")
  if npc_id ~= nil then
    text = gui.TextManager:GetText(npc_id) .. nx_widestr(text)
  end
  if scene_id ~= nil and form.current_map ~= scene_id then
    local scene_name = gui.TextManager:GetText("scene_" .. scene_id)
    text = nx_widestr(scene_name) .. nx_widestr(" ") .. nx_widestr(text)
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 0, form)
end
function on_btn_trace_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function set_dest_pos(form, x, z)
  form.btn_trace.dest_x = x
  form.btn_trace.dest_z = z
end
function update_big_map_trace(form)
  if nx_name(form.pic_map) ~= "Picture" then
    return
  end
  local path_finding = nx_value("path_finding")
  if not nx_is_valid(path_finding) then
    return
  end
  local dest_point
  local scene_name = form.current_map
  local find_count = path_finding.PointCount
  local draw_count = path_finding:GetDrawPointCount(scene_name, false)
  local btn_trace = form.btn_trace
  local map_query = form.map_query
  if nx_find_custom(map_query, "x") and map_query.x ~= nil and nx_find_custom(map_query, "z") and map_query.z ~= nil and nx_find_custom(map_query, "scene_id") and map_query.scene_id ~= nil then
    if scene_name == map_query.scene_id then
      dest_point = {
        map_query.x,
        -10000,
        map_query.z
      }
    elseif 0 < draw_count then
      dest_point = path_finding:GetPointByIndex(draw_count - 1, scene_name)
    end
  elseif 0 < find_count then
    dest_point = path_finding:GetPointByIndex(find_count - 1)
  elseif 0 < draw_count then
    dest_point = path_finding:GetPointByIndex(draw_count - 1, scene_name)
  end
  form.btn_trace.Visible = false
  if dest_point ~= nil then
    dest_x, dest_z = trans_scene_pos_to_map(dest_point[1], dest_point[3], form.pic_map)
    local in_map = form.map_query:IsPointInRect(dest_x, dest_z, form.pic_map.Width, form.pic_map.Height)
    form.btn_trace.Visible = in_map
    form.btn_trace.AbsLeft = form.pic_map.AbsLeft + dest_x - form.btn_trace.Width / 2
    form.btn_trace.AbsTop = form.pic_map.AbsTop + dest_z - form.btn_trace.Height + 10
    local trace_flag = path_finding.AutoTraceFlag
    if trace_flag == 1 then
      form.btn_trace.Visible = in_map and false
    elseif trace_flag == 2 then
      form.btn_trace.Visible = in_map and true
    elseif trace_flag == 3 then
      form.btn_trace.Visible = in_map and true
    end
  end
end
function update_direction_hint(form)
  local lbl_role = form.lbl_role
  if form.map_query:IsInMap(lbl_role, form.pic_map) then
    return
  end
  local map_x, map_z = trans_scene_pos_to_image(lbl_role.x, lbl_role.z, form.pic_map.ImageWidth, form.pic_map.ImageHeight, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local delta_x = map_x - form.pic_map.CenterX
  local delta_z = map_z - form.pic_map.CenterY
  form.btn_dir.Visible = true
  local flag_x = 0 < delta_x
  local flag_z = 0 < delta_z
  local map_role_x, map_role_z = trans_scene_pos_to_map(lbl_role.x, lbl_role.z, form.pic_map)
  local map_center_x, map_center_z = form.pic_map.Width / 2, form.pic_map.Height / 2
  local exact_x = 0
  local exact_y = 0
  local k = (map_role_z - map_center_z) / (map_role_x - map_center_x)
  local b = map_center_z - k * map_center_x
  if not flag_x and flag_z then
    exact_x = 0
    exact_y = k * exact_x + b
    if exact_y > form.pic_map.Height then
      exact_y = form.pic_map.Height
      exact_x = (exact_y - b) / k
    end
  elseif not flag_x and not flag_z then
    exact_x = 0
    exact_y = k * exact_x + b
    if exact_y < 0 then
      exact_y = 0
      exact_x = (exact_y - b) / k
    end
  elseif flag_x and not flag_z then
    exact_y = 0
    exact_x = (exact_y - b) / k
    if exact_x > form.pic_map.Width then
      exact_x = form.pic_map.Width
      exact_y = k * exact_x + b
    end
  elseif flag_x and flag_z then
    exact_x = form.pic_map.Width
    exact_y = k * exact_x + b
    if exact_y > form.pic_map.Height then
      exact_y = form.pic_map.Height
      exact_x = (exact_y - b) / k
    end
  end
  if exact_x == 0 then
    exact_y = exact_y - form.btn_dir.Height / 2
  end
  if exact_x == form.pic_map.Width then
    exact_x = exact_x - form.btn_dir.Width
    exact_y = exact_y - form.btn_dir.Height / 2
  end
  if exact_y == 0 then
    exact_x = exact_x - form.btn_dir.Width / 2
  end
  if exact_y == form.pic_map.Height then
    exact_y = exact_y - form.btn_dir.Height
    exact_x = exact_x - form.btn_dir.Width / 2
  end
  form.btn_dir.AbsLeft = form.pic_map.AbsLeft + exact_x
  form.btn_dir.AbsTop = form.pic_map.AbsTop + exact_y
end
function trans_scene_pos_to_map(x, z, pic_map)
  local map_x, map_z
  map_x, map_z = trans_scene_pos_to_image(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function trans_scene_pos_to_image(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local map_x = map_width - (x - terrain_start_x) / terrain_width * map_width
  local map_z = (z - terrain_start_z) / terrain_height * map_height
  return map_x, map_z
end
function trans_image_pos_to_scene(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local pos_x = x * terrain_width / map_width + terrain_start_x
  local pos_z = z * terrain_height / map_height + terrain_start_z
  return pos_x, pos_z
end
