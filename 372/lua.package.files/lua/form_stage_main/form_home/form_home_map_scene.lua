require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("share\\logicstate_define")
local NPC_TYPE = {
  503,
  504,
  505,
  506,
  507,
  508,
  509,
  350,
  1101
}
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.map_query = nx_value("MapQuery")
  form.current_map = ""
  form.show_role_pos = true
  form.btn_trace.Visible = false
  local asynor = nx_value("common_execute")
  if nx_is_valid(asynor) then
    asynor:AddExecute("RefreshMapScenePlayer", form, 0)
  end
  nx_execute("tips_game", "hide_tip", form)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "update_form_on_timer", form, -1, -1)
end
function on_main_form_close(form)
  local asynor = nx_value("common_execute")
  if nx_is_valid(asynor) then
    asynor:RemoveExecute("RefreshMapScenePlayer", form)
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "update_form_on_timer", form)
  form.groupmap_objs:Clear()
  nx_destroy(form)
end
function refresh_form(form, sceneid, iscreatemode)
  if not nx_is_valid(form) then
    return
  end
  form.iscreatemode = iscreatemode
  if sceneid == "" then
    return
  end
  form.current_map = sceneid
  form.lbl_role.Visible = form.map_query:IsPlayerInScene(sceneid)
  form.show_role_pos = form.map_query:IsPlayerInScene(sceneid)
  form.groupmap_objs:Clear()
  local file_name = "gui\\map\\scene\\" .. sceneid .. "\\" .. sceneid .. ".ini"
  local map_name = "gui\\map\\scene\\" .. sceneid .. "\\" .. sceneid .. ".dds"
  form.pic_map.Image = map_name
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    return
  end
  form.pic_map.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  scene_map_init(form, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  form.groupmap_objs:InitTerrain(form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local exact_zoom_width = (form.pic_map.max_zoom_width + form.pic_map.min_zoom_width) / 2
  local exact_zoom_height = (form.pic_map.max_zoom_height + form.pic_map.min_zoom_height) / 2
  form.map_query:GroupmapInit(form)
  for i = 1, table.getn(NPC_TYPE) do
    local npctype = NPC_TYPE[i]
    if form.map_query:HasNpcTypeInfo(nx_string(npctype)) then
      local photo = form.map_query:GetNpcTypeProp(nx_string(npctype), "Photo")
      form.groupmap_objs:AddType(nx_string(npctype), nx_string(photo))
      form.groupmap_objs:ShowType(nx_string(npctype), true)
    end
  end
  form.groupmap_objs.MapControl = form.pic_map
  form.groupmap_objs:SetElementZoom(1)
  form.groupmap_objs:SetFocusedZoom(1.2)
  form.map_query:LoadMapText(form, sceneid)
  for i = 1, table.getn(NPC_TYPE) do
    local npctype = NPC_TYPE[i]
    local SceneCreator = nx_value("SceneCreator")
    local npcs = SceneCreator:GetNpcConfigIDByNpcType(sceneid, npctype, true)
    for _, npcid in ipairs(npcs) do
      form.map_query:AddNpcForMap(sceneid, form.groupmap_objs, npcid)
    end
  end
  form.groupmap_objs:ShowAllType(true)
  set_map_zoom(form, form.pic_map.min_zoom_width, form.pic_map.min_zoom_height)
end
function scene_map_init(form, x, z, w, h)
  form.groupmap_objs:Clear()
  form.groupmap_objs.Left = form.pic_map.Left
  form.groupmap_objs.Top = form.pic_map.Top
  form.groupmap_objs.Width = form.pic_map.Width
  form.groupmap_objs.Height = form.pic_map.Height
  local max_zoom_width = w / form.pic_map.ImageWidth
  local max_zoom_height = h / form.pic_map.ImageHeight
  local min_zoom_width = form.pic_map.Width / form.pic_map.ImageWidth
  local min_zoom_height = form.pic_map.Height / form.pic_map.ImageHeight
  if max_zoom_width < min_zoom_width then
    max_zoom_width = min_zoom_width
  end
  if max_zoom_height < min_zoom_height then
    max_zoom_height = min_zoom_height
  end
  local max_zoom_value = 1.2
  if max_zoom_width > max_zoom_value then
    max_zoom_width = max_zoom_value
  end
  if max_zoom_height > max_zoom_value then
    max_zoom_height = max_zoom_value
  end
  form.pic_map.min_zoom_width = min_zoom_width
  form.pic_map.min_zoom_height = min_zoom_height
  form.pic_map.max_zoom_width = max_zoom_width
  form.pic_map.max_zoom_height = max_zoom_height
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2
  form.pic_map.ZoomWidth = zoom_width
  form.pic_map.ZoomHeight = zoom_height
  local ratio = (form.pic_map.ZoomWidth - form.pic_map.min_zoom_width) / (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
  ratio = 1 - ratio
  form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
end
function on_tbar_zoom_value_changed(self)
  if not can_change_map() then
    return
  end
  local form = self.ParentForm
  if not nx_find_custom(form.pic_map, "min_zoom_width") then
    return
  end
  local ratio = self.Value / (self.Maximum - self.Minimum)
  ratio = 1 - ratio
  local zoom_width = form.pic_map.min_zoom_width + ratio * (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
  local zoom_height = form.pic_map.min_zoom_height + ratio * (form.pic_map.max_zoom_height - form.pic_map.min_zoom_height)
  set_map_zoom(form, zoom_width, zoom_height)
end
function can_change_map()
  local can_open_map = nx_execute("form_stage_main\\form_map\\form_map_scene", "can_open_map")
  if not can_open_map then
    return false
  end
  local big_map_limit = false
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "big_map_limit") then
    big_map_limit = role.big_map_limit
  end
  if big_map_limit then
    return false
  end
  return true
end
function on_btn_zoom_in_push(self)
  local form = self.ParentForm
  if not nx_find_custom(form.pic_map, "min_zoom_width") then
    return
  end
  self.mouse_down_zoom_in = true
  while nx_is_valid(form) and self.mouse_down_zoom_in do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local zoom_width = form.pic_map.ZoomWidth + 0.05
    local zoom_height = form.pic_map.ZoomHeight + 0.05
    if zoom_width >= form.pic_map.max_zoom_width or zoom_height >= form.pic_map.max_zoom_height then
      zoom_width = form.pic_map.max_zoom_width
      zoom_height = form.pic_map.max_zoom_height
    end
    local ratio = (zoom_width - form.pic_map.min_zoom_width) / (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
  end
end
function on_btn_zoom_in_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_in = false
end
function on_btn_zoom_out_push(self)
  local form = self.ParentForm
  if not nx_find_custom(form.pic_map, "min_zoom_width") then
    return
  end
  self.mouse_down_zoom_out = true
  while nx_is_valid(form) and self.mouse_down_zoom_out do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local zoom_width = form.pic_map.ZoomWidth - 0.05
    local zoom_height = form.pic_map.ZoomHeight - 0.05
    if zoom_width <= form.pic_map.min_zoom_width or zoom_height <= form.pic_map.min_zoom_height then
      zoom_width = form.pic_map.min_zoom_width
      zoom_height = form.pic_map.min_zoom_height
    end
    local ratio = (zoom_width - form.pic_map.min_zoom_width) / (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
  end
end
function on_btn_zoom_out_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = false
end
function on_btn_trace_click(self)
  local form = self.ParentForm
  local map_query = form.map_query
  if not nx_find_custom(map_query, "x") or map_query.x == nil then
    return
  end
  if not nx_find_custom(map_query, "y") or map_query.y == nil then
    return
  end
  if not nx_find_custom(map_query, "z") or map_query.z == nil then
    return
  end
  if not nx_find_custom(map_query, "scene_id") or map_query.scene_id == nil then
    return
  end
  local npc_id
  if nx_find_custom(map_query, "npc_id") and map_query.npc_id ~= nil then
    npc_id = map_query.npc_id
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if trace_flag == 3 then
    return
  end
  if npc_id == nil then
    path_finding:FindPathScene(map_query.scene_id, map_query.x, map_query.y, map_query.z, 0)
  else
    path_finding:TraceTargetByID(map_query.scene_id, map_query.x, map_query.y, map_query.z, 1.8, map_query.npc_id)
  end
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
  local text = nx_widestr("(") .. nx_widestr(x) .. nx_widestr(",") .. nx_widestr(z) .. nx_widestr(")")
  local gui = nx_value("gui")
  if npc_id ~= nil and nx_string(gui.TextManager:GetText(npc_id)) ~= "" then
    text = gui.TextManager:GetText(npc_id) .. nx_widestr("<br>") .. text
  end
  if scene_id ~= nil and form.current_map ~= scene_id then
    local scene_name = gui.TextManager:GetText("scene_" .. scene_id)
    text = nx_widestr(scene_name) .. nx_widestr("<br>") .. text
  end
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop, 0, form)
end
function on_btn_trace_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function set_map_zoom(form, zoom_width, zoom_height)
  form.pic_map.ZoomWidth = zoom_width
  form.pic_map.ZoomHeight = zoom_height
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  if center_x_min > form.pic_map.CenterX then
    form.pic_map.CenterX = center_x_min
  end
  if center_x_max < form.pic_map.CenterX then
    form.pic_map.CenterX = center_x_max
  end
  if center_z_min > form.pic_map.CenterY then
    form.pic_map.CenterY = center_z_min
  end
  if center_z_max < form.pic_map.CenterY then
    form.pic_map.CenterY = center_z_max
  end
  form.groupmap_objs:ShowText("A", true)
  form.groupmap_objs:ShowText("B", false)
  form.groupmap_objs:ShowText("C", false)
  if not nx_find_custom(form.pic_map, "min_zoom_width") then
    return
  end
  local min_zoom_width = form.pic_map.min_zoom_width
  local max_zoom_width = form.pic_map.max_zoom_width
  local max_zoom_height = form.pic_map.max_zoom_height
  local average_zoom_width = (max_zoom_width - min_zoom_width) / 3
  if zoom_width >= min_zoom_width + average_zoom_width * 0 and (not nx_find_custom(form.pic_map, "ZoomLevel") or form.pic_map.ZoomLevel ~= 1) then
    form.pic_map.ZoomLevel = 1
  end
  if zoom_width >= min_zoom_width + average_zoom_width * 1 and (not nx_find_custom(form.pic_map, "ZoomLevel") or form.pic_map.ZoomLevel ~= 2) then
    form.pic_map.ZoomLevel = 2
    form.groupmap_objs:ShowText("B", true)
  end
  if zoom_width >= min_zoom_width + average_zoom_width * 2 and (not nx_find_custom(form.pic_map, "ZoomLevel") or form.pic_map.ZoomLevel ~= 3) then
    form.pic_map.ZoomLevel = 3
    form.groupmap_objs:ShowText("C", true)
  end
end
function on_pic_map_right_down(pic_map, x, y)
  local gui = nx_value("gui")
  gui.GameHand:SetHand("func", "snapmap", "", "", "", "")
  pic_map.mouse_move = false
  pic_map.right_down = true
  pic_map.click_center_x = pic_map.CenterX
  pic_map.click_center_z = pic_map.CenterY
  pic_map.click_offset_x = x
  pic_map.click_offset_y = y
end
function on_pic_map_right_up(pic_map, x, y)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  pic_map.right_down = false
  pic_map.mouse_move = false
  pic_map.drag_move = false
end
function on_pic_map_left_up(pic_map, x, y)
  local form = pic_map.ParentForm
  if not nx_is_valid(form) then
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
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  local sx = -(pic_map.Width / 2 - x)
  local sz = pic_map.Height / 2 - y
  local map_x = pic_map.ImageWidth - pic_map.CenterX - sx / pic_map.ZoomWidth
  local map_z = pic_map.CenterY - sz / pic_map.ZoomHeight
  local pos_x, pos_z = trans_image_pos_to_scene(map_x, map_z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "find_path_limit") and role.find_path_limit == true then
    return
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  set_trace_npc_id(nil, pos_x, -10000, pos_z, form.current_map, true)
  if trace_flag == 1 or trace_flag == 2 then
    path_finding:FindPathScene(nx_string(form.current_map), pos_x, -10000, pos_z, 0)
  end
end
function on_pic_map_mouse_move(pic_map, offset_x, offset_y)
  local form = pic_map.ParentForm
  if nx_find_custom(pic_map, "right_down") and pic_map.right_down then
    on_pic_map_drag_move(pic_map, offset_x - pic_map.click_offset_x, offset_y - pic_map.click_offset_y)
  else
    if not nx_find_custom(pic_map, "TerrainStartX") then
      return
    end
    form.pic_map.mouse_move = true
    local sx = -(pic_map.Width / 2 - offset_x)
    local sz = pic_map.Height / 2 - offset_y
    local map_x = pic_map.ImageWidth - pic_map.CenterX - sx / pic_map.ZoomWidth
    local map_z = pic_map.CenterY - sz / pic_map.ZoomHeight
    local pos_x, pos_z = trans_image_pos_to_scene(map_x, map_z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
    pic_map.ParentForm.lbl_pos.Text = nx_widestr(nx_string(nx_int(pos_x)) .. "," .. nx_string(nx_int(pos_z)))
  end
end
function on_pic_map_drag_move(pic_map, offset_x, offset_y)
  if not nx_find_custom(pic_map, "click_center_x") then
    return
  end
  local sx = -offset_x / pic_map.ZoomWidth * 0.5
  local sz = -offset_y / pic_map.ZoomHeight * 0.5
  local map_x = sx + pic_map.click_center_x
  local map_z = sz + pic_map.click_center_z
  local form = pic_map.ParentForm
  set_map_center(form, map_x, map_z)
end
function set_map_center(form, center_x, center_z)
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  if center_x < center_x_min then
    center_x = center_x_min
  end
  if center_x_max < center_x then
    center_x = center_x_max
  end
  if center_z < center_z_min then
    center_z = center_z_min
  end
  if center_z_max < center_z then
    center_z = center_z_max
  end
  form.pic_map.CenterX = center_x
  form.pic_map.CenterY = center_z
end
function on_groupmap_objs_click_obj(self, obj_type, id, npc_type, x, y, z)
  self.x = x
  self.y = y
  self.z = z
  self.id = id
  self.npc_id = id
  self.npc_type = npc_type
  nx_execute("form_stage_main\\form_home\\form_home_world", "click_community_btn", x, y, z)
  self.ParentForm.lbl_pos.Text = nx_widestr(nx_string(nx_int(x)) .. "," .. nx_string(nx_int(z)))
  on_lbl_click(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_groupmap_objs_mouse_in_obj(self, obj_type, id, npc_type, x, y, z)
  local form = self.ParentForm
  if obj_type == 3 then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr("")
  local str_id = ""
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if form.map_query:HasNpcTypeInfo(nx_string(npc_type)) then
    str_id = form.map_query:GetNpcTypeStrId(nx_string(npc_type))
    local title = gui.TextManager:GetText(str_id)
    local name = gui.TextManager:GetText(id)
    text = gui.TextManager:GetFormatText("<font color=\"#B9B29F\">[{@0:type}]</font><br><font color=\"#FFFFFF\">{@1:name}</font><br><font color=\"#ED5F00\">({@2:x},{@3:y})</font>", title, name, nx_int(x), nx_int(z))
  end
  text = nx_widestr(text)
  if text ~= nx_widestr("") then
    local sx, sz = trans_scene_pos_to_map(x, z, form.pic_map)
    local AbsLeft = form.pic_map.AbsLeft + sx - 10
    local AbsTop = form.pic_map.AbsTop + sz - 60
    local show_tips = true
    if nx_find_custom(form.pic_map, "right_down") and form.pic_map.right_down == true then
      show_tips = false
    end
    if show_tips then
      local form = nx_value(nx_current())
      nx_execute("tips_game", "show_text_tip", nx_widestr(text), AbsLeft, AbsTop, 0, form)
    end
  end
end
function on_groupmap_objs_mouse_out_obj(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
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
function trans_scene_pos_to_map(x, z, pic_map)
  local map_x, map_z
  map_x, map_z = trans_scene_pos_to_image(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function set_map_center_according_world_pos(form, x, z)
  if not nx_find_custom(form.pic_map, "TerrainStartX") then
    return
  end
  local map_x, map_z = trans_scene_pos_to_image(x, z, form.pic_map.ImageWidth, form.pic_map.ImageHeight, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local sx = (map_x - form.pic_map.CenterX) * form.pic_map.ZoomWidth
  local sz = (map_z - form.pic_map.CenterY) * form.pic_map.ZoomHeight
  local center_x = form.pic_map.CenterX + sx / form.pic_map.ZoomWidth
  local center_z = form.pic_map.CenterY + sz / form.pic_map.ZoomHeight
  set_map_center(form, center_x, center_z)
end
function update_trace_pos(form)
  form.btn_trace.Visible = false
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    map_query:UpdateHomeMapTrace()
  end
end
function render_path_finding(form)
  form.line_path:Clear()
  form.line_path.Visible = false
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    map_query:RenderPathFinding(form, form.line_path, form.pic_map)
  end
end
function update_form_on_timer(form, param1, param2)
  if not form.Visible then
    return
  end
  render_path_finding(form)
  update_trace_pos(form)
end
function set_trace_npc_id(npc_id, npc_x, npc_y, npc_z, scene_id, no_center)
  local form_map = nx_value("form_stage_main\\form_home\\form_home_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local btn_trace = form_map.btn_trace
  if not nx_find_custom(btn_trace, "npc_id") then
    btn_trace.npc_id = nil
  end
  if not nx_find_custom(btn_trace, "scene_id") then
    btn_trace.scene_id = nil
  end
  form_map.btn_trace.old_npc_id = form_map.btn_trace.npc_id
  form_map.btn_trace.old_scene_id = form_map.btn_trace.scene_id
  form_map.btn_trace.scene_id = scene_id
  form_map.btn_trace.npc_id = npc_id
  form_map.btn_trace.x = nx_number(nx_int(npc_x))
  form_map.btn_trace.y = nx_number(nx_int(npc_y))
  form_map.btn_trace.z = nx_number(nx_int(npc_z))
  local map_query = form_map.map_query
  if not nx_find_custom(map_query, "npc_id") then
    map_query.npc_id = nil
  end
  if not nx_find_custom(map_query, "scene_id") then
    map_query.scene_id = nil
  end
  map_query.old_npc_id = map_query.npc_id
  map_query.old_scene_id = map_query.scene_id
  map_query.scene_id = scene_id
  map_query.npc_id = npc_id
  map_query.x = nx_number(nx_int(npc_x))
  map_query.y = nx_number(nx_int(npc_y))
  map_query.z = nx_number(nx_int(npc_z))
  if map_query.old_npc_id == nil then
    map_query.old_npc_id = map_query.npc_id
  end
  if map_query.old_scene_id == nil then
    map_query.old_scene_id = map_query.scene_id
  end
  if not no_center and npc_id ~= nil and npc_x ~= nil and npc_z ~= nil then
    if scene_id == form_map.current_map then
      set_map_center_according_world_pos(form_map, npc_x, npc_z)
    else
      local path_finding = nx_value("path_finding")
      if nx_is_valid(path_finding) then
        local draw_count = path_finding:GetDrawPointCount(form_map.current_map, true)
        if 0 < draw_count then
          dest_point = path_finding:GetPointByIndex(draw_count - 1, form_map.current_map)
          if dest_point ~= nil and dest_point[1] ~= nil and dest_point[3] ~= nil then
            set_map_center_according_world_pos(form_map, dest_point[1], dest_point[3])
          end
        end
      end
    end
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "set_trace_npc_id", npc_id, npc_x, npc_z, scene_id)
end
function on_lbl_click(lbl)
  local form = nx_value("form_stage_main\\form_home\\form_home_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(lbl) then
    return
  end
  if nx_find_custom(lbl, "id") then
    local id = lbl.id
    local target_scene = form.map_query:GetTransNpcScene(nx_string(id))
    if "" ~= target_scene and nil ~= target_scene then
      turn_to_scene_map(form, nx_string(target_scene))
      return
    end
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if lbl.npc_type == 0 then
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:FindPath(lbl.x, lbl.y, lbl.z, 0)
    end
  elseif lbl.npc_type == 240 or lbl.npc_type == 241 or lbl.npc_type == 242 or lbl.npc_type == 243 or lbl.npc_type == 244 then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLONE_STRONGPOINT_MSG), nx_int(lbl.npc_type))
  elseif trace_flag == 1 or trace_flag == 2 then
    if nx_int(form.iscreatemode) == nx_int(1) then
      local home_manager = nx_value("HomeManager")
      if not nx_is_valid(home_manager) then
        return
      end
      local scene_id = form.map_query:GetSceneId(nx_string(form.current_map))
      if nx_int(scene_id) <= nx_int(0) then
        return
      end
      local signid = home_manager:GetSignIDByPlace(nx_int(scene_id), nx_float(lbl.x), nx_float(lbl.y), nx_float(lbl.z))
      if nx_int(signid) <= nx_int(0) then
        return
      end
      nx_execute("form_stage_main\\form_home\\form_home_build", "open_form", nx_int(signid))
    else
      path_finding:TraceTargetByID(nx_string(form.current_map), lbl.x, lbl.y, lbl.z, 1.8, lbl.npc_id)
      path_finding:FindPath(lbl.x, lbl.y, lbl.z, 0)
    end
  end
end
