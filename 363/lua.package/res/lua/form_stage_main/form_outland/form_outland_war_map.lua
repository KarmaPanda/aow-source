require("utils")
require("util_gui")
require("define\\gamehand_type")
require("util_functions")
local CRASH_NPC_REC = "crash_npc_rec"
local FOCUS_X = 792
local FOCUS_Z = 397
function main_form_init(self)
  self.Fixed = false
  nx_set_custom(self, "last_stage", nil)
  return 1
end
function on_main_form_open(self)
  load_map(self)
  local gui = nx_value("gui")
  self.Left = (gui.Desktop.Width - self.Width) / 2
  self.Top = (gui.Desktop.Height - self.Height) / 2
  self.tbar_zoom.Value = (self.tbar_zoom.Maximum - self.tbar_zoom.Minimum) / 2
  set_map_zoom(self, self.pic_map.MaxZoomWidth / 2, self.pic_map.MaxZoomHeight / 2)
  mouse_right_up()
  local timer = nx_value(GAME_TIMER)
  timer:Register(500, -1, nx_current(), "on_update_role_position", self, -1, -1)
  update_outland_stage(self)
  set_camp_to_map_center(self)
  data_bind_prop(self)
  return 1
end
function data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("crash_npc_rec", self, nx_current(), "refresh_campsite")
end
function del_data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelTableBind("crash_npc_rec", self)
end
function load_map(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local resource = client_scene:QueryProp("Resource")
  form.pic_map.Image = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  local file_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    return
  end
  form.pic_map.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  form.map_query = nx_value("MapQuery")
  local real_zoom_width = form.pic_map.TerrainWidth / form.pic_map.ImageWidth
  local real_zoom_height = form.pic_map.TerrainHeight / form.pic_map.ImageHeight
  form.pic_map.MinZoomWidth = form.pic_map.Width / form.pic_map.ImageWidth
  form.pic_map.MinZoomHeight = form.pic_map.Height / form.pic_map.ImageHeight
  form.pic_map.MaxZoomWidth = real_zoom_width * 1.5
  form.pic_map.MaxZoomHeight = real_zoom_height * 1.5
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2
  form.pic_map.ZoomWidth = 1
  form.pic_map.ZoomHeight = 1
  local ratio = (form.pic_map.ZoomWidth - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
  ratio = 1 - ratio
  form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
  local gui = nx_value("gui")
  local scene_config = client_scene:QueryProp("ConfigID")
  local scene_name = gui.TextManager:GetFormatText(scene_config)
  local current_scene = nx_widestr(gui.TextManager:GetText("ui_current_scene")) .. nx_widestr(": ") .. nx_widestr(scene_name)
  form.lbl_current_scene.Text = nx_widestr(current_scene)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_role_position", self)
  mouse_right_up()
  del_data_bind_prop()
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
function on_update_role_position(form, param1, param2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  form.lbl_role.x = visual_player.PositionX
  form.lbl_role.y = visual_player.PositionY
  form.lbl_role.z = visual_player.PositionZ
  set_lbl_position(form.lbl_role, form.pic_map)
  form.lbl_role.AngleZ = -visual_player.AngleY + math.pi
  local camptbl = getAllCampsiteName()
  for i = 1, table.getn(camptbl) do
    if nx_find_custom(form, camptbl[i]) then
      local lbl = nx_custom(form, camptbl[i])
      if nx_is_valid(lbl) then
        set_lbl_position(lbl, form.pic_map)
      end
    end
  end
  form:ToFront(form.lbl_role)
  if nx_is_valid(form.groupbox_move) then
    form:ToFront(form.groupbox_move)
  end
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
  form.map_query:UpdateMapLabel()
  on_update_role_position(form)
end
function is_in_map(control, pic_map)
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    return map_query:IsInMap(control, pic_map)
  end
  return false
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
function on_pic_map_mouse_move(pic_map, offset_x, offset_y)
  local form = pic_map.ParentForm
  local sx = offset_x - pic_map.Width / 2
  local sz = offset_y - pic_map.Height / 2
  local map_x = pic_map.CenterX + sx / pic_map.ZoomWidth
  local map_z = pic_map.CenterY + sz / pic_map.ZoomHeight
  local pos_x, pos_z = trans_pos_to_scene(map_x, map_z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  form.lbl_pos.Text = nx_widestr(nx_string(nx_int(pos_x)) .. "," .. nx_string(nx_int(pos_z)))
end
function mouse_right_up()
  local form = nx_value("form_stage_main\\form_outland\\form_outland_eren_warmap")
  if nx_is_valid(form) and nx_find_custom(form.pic_map, "right_down") and form.pic_map.right_down then
    on_pic_map_right_up(form.pic_map, 0, 0)
  end
end
function on_pic_map_right_down(pic_map, x, y)
  local form = pic_map.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
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
end
function trans_scene_pos_to_map(x, z, pic_map)
  local map_x, map_z
  map_x, map_z = trans_pos_to_map(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function trans_pos_to_map(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local map_x = map_width - (x - terrain_start_x) / terrain_width * map_width
  local map_z = (z - terrain_start_z) / terrain_height * map_height
  return map_x, map_z
end
function trans_pos_to_scene(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local pos_x = terrain_width - x * terrain_width / map_width + terrain_start_x
  local pos_z = z * terrain_height / map_height + terrain_start_z
  return pos_x, pos_z
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
  label.Visible = is_in_map(label, pic_map)
  return label.AbsLeft, label.AbsTop, label.Visible
end
function update_outland_stage(self)
  local title_form = nx_value("form_stage_main\\form_outland\\form_outland_eren_war_title")
  local cur_stage
  if nx_is_valid(title_form) then
    cur_stage = nx_execute("form_stage_main\\form_outland\\form_outland_war_title", "get_cur_outland_stageid", title_form)
  end
  if cur_stage == nil then
    return
  end
  on_update_stage(self, cur_stage)
end
function on_update_stage(self, stage)
  if self == nil or not nx_is_valid(self) then
    return
  end
  if not nx_find_custom(self, "last_stage") or self.last_stage == nil or self.last_stage ~= stage then
    self.last_stage = stage
    init_outland_campsite(self)
    refresh_campsite(self, stage)
  end
  self.btn_1.Enabled = false
  self.btn_2.Enabled = false
  self.btn_3.Enabled = false
  self.btn_4.Enabled = false
  if stage == 1 then
    self.btn_1.Enabled = true
  elseif stage == 2 then
    self.btn_2.Enabled = true
  elseif stage == 3 then
    self.btn_3.Enabled = true
  elseif stage == 4 then
    self.btn_4.Enabled = true
  end
end
function on_btn_up_click(self)
  self.mouse_down_move_up = false
end
function on_btn_up_push(self)
  local form = self.ParentForm
  self.mouse_down_move_up = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_up do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_y = form.pic_map.CenterY - 10
    if center_z_min >= center_y then
      center_y = center_z_min
    end
    form.pic_map.CenterY = center_y
    on_update_role_position(form)
    if center_z_min >= center_y then
      break
    end
  end
end
function on_btn_down_click(self)
  self.mouse_down_move_down = false
end
function on_btn_down_push(self)
  local form = self.ParentForm
  self.mouse_down_move_down = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_down do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_y = form.pic_map.CenterY + 10
    if center_z_max <= center_y then
      center_y = center_z_max
    end
    form.pic_map.CenterY = center_y
    on_update_role_position(form)
    if center_z_max <= center_y then
      break
    end
  end
end
function on_btn_left_click(self)
  self.mouse_down_move_left = false
end
function on_btn_left_push(self)
  local form = self.ParentForm
  self.mouse_down_move_left = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_left do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_x = form.pic_map.CenterX - 10
    if center_x_min >= center_x then
      center_x = center_x_min
    end
    form.pic_map.CenterX = center_x
    on_update_role_position(form)
    if center_x_min >= center_x then
      break
    end
  end
end
function on_btn_right_click(self)
  self.mouse_down_move_right = false
end
function on_btn_right_push(self)
  local form = self.ParentForm
  self.mouse_down_move_right = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_right do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_x = form.pic_map.CenterX + 10
    if center_x_max <= center_x then
      center_x = center_x_max
    end
    form.pic_map.CenterX = center_x
    on_update_role_position(form)
    if center_x_max <= center_x then
      break
    end
  end
end
function on_tbar_zoom_value_changed(self)
  local form = self.ParentForm
  local ratio = self.Value / (self.Maximum - self.Minimum)
  ratio = 1 - ratio
  local zoom_width = form.pic_map.MinZoomWidth + ratio * (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
  local zoom_height = form.pic_map.MinZoomHeight + ratio * (form.pic_map.MaxZoomHeight - form.pic_map.MinZoomHeight)
  local lbl_back = form.lbl_track
  lbl_back.AbsTop = form.tbar_zoom.TrackButton.AbsTop + form.tbar_zoom.TrackButton.Height - 2
  lbl_back.Height = form.tbar_zoom.Height - form.tbar_zoom.TrackButton.Top - form.tbar_zoom.TrackButton.Height - 2
  lbl_back.Visible = 0.0010000000000000009 < ratio
  set_map_zoom(form, zoom_width, zoom_height)
  on_update_role_position(form)
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
end
function on_btn_zoom_in_push(self)
  local form = self.ParentForm
  self.mouse_down_zoom_in = true
  while self.mouse_down_zoom_in do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local zoom_width = form.pic_map.ZoomWidth + 0.05
    local zoom_height = form.pic_map.ZoomHeight + 0.05
    if zoom_width >= form.pic_map.MaxZoomWidth or zoom_height >= form.pic_map.MaxZoomHeight then
      zoom_width = form.pic_map.MaxZoomWidth
      zoom_height = form.pic_map.MaxZoomHeight
    end
    local ratio = (zoom_width - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
    on_update_role_position(form)
  end
end
function on_btn_zoom_in_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_in = false
end
function on_btn_zoom_out_push(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = true
  while self.mouse_down_zoom_out do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local zoom_width = form.pic_map.ZoomWidth - 0.05
    local zoom_height = form.pic_map.ZoomHeight - 0.05
    if zoom_width <= form.pic_map.MinZoomWidth or zoom_height <= form.pic_map.MinZoomHeight then
      zoom_width = form.pic_map.MinZoomWidth
      zoom_height = form.pic_map.MinZoomHeight
    end
    local ratio = (zoom_width - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
    on_update_role_position(form)
  end
end
function on_btn_zoom_out_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = false
end
function set_camp_to_map_center(form)
  if not nx_find_custom(form.lbl_role, "x") and not nx_find_custom(form.lbl_role, "z") then
    return
  end
  local x = FOCUS_X
  local z = FOCUS_Z
  local map_x, map_z = trans_pos_to_map(x, z, form.pic_map.ImageWidth, form.pic_map.ImageHeight, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local sx = (map_x - form.pic_map.CenterX) * form.pic_map.ZoomWidth
  local sz = (map_z - form.pic_map.CenterY) * form.pic_map.ZoomHeight
  local center_x = form.pic_map.CenterX + sx / form.pic_map.ZoomWidth
  local center_z = form.pic_map.CenterY + sz / form.pic_map.ZoomHeight
  set_map_center(form, center_x, center_z)
end
function refresh_campsite(self, stage)
  local tbl_camp = getCampsitePos(stage)
  if tbl_camp == nil then
    return
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  for i = 1, table.getn(tbl_camp) do
    if camp_is_alive(tbl_camp[i][1], client_scene) then
      update_outland_campsite(self, tbl_camp[i][1], true)
    else
      update_outland_campsite(self, tbl_camp[i][1], false)
    end
  end
end
function camp_is_alive(npc_configid, client_scene)
  if not nx_is_valid(client_scene) then
    return false
  end
  if not client_scene:FindRecord(CRASH_NPC_REC) then
    return false
  end
  local rows = client_scene:GetRecordRows(CRASH_NPC_REC)
  if rows <= 0 then
    return false
  end
  for i = 1, rows do
    if client_scene:QueryRecord(CRASH_NPC_REC, i - 1, 1) == npc_configid then
      return true
    end
  end
  return false
end
function init_outland_campsite(self)
  if self == nil or not nx_is_valid(self) then
    return false
  end
  if not nx_find_custom(self, "last_stage") then
    return false
  end
  local tbl_camp = getCampsitePos(self.last_stage)
  if tbl_camp == nil then
    return false
  end
  if table.getn(tbl_camp) == 0 then
    return false
  end
  local gui = nx_value("gui")
  local all_camp_name = getAllCampsiteName()
  if all_camp_name ~= nil and table.getn(all_camp_name) ~= 0 then
    for i = 1, table.getn(all_camp_name) do
      if nx_find_custom(self, all_camp_name[i]) then
        local lbl = nx_custom(self, all_camp_name[i])
        if nx_is_valid(lbl) then
          gui:Delete(lbl)
        end
        nx_set_custom(self, all_camp_name[i], nil)
      end
    end
  end
  for i = 1, table.getn(tbl_camp) do
    local pos_info = tbl_camp[i]
    if table.getn(pos_info) >= 5 then
      local lbl
      if not nx_find_custom(self, pos_info[1]) or nx_custom(self, pos_info[1]) == nil then
        lbl = gui:Create("Label")
        lbl.Name = pos_info[1]
        lbl.AutoSize = true
        lbl.BackImage = "gui\\special\\outland\\huoxi.png"
        lbl.NoFrame = false
        self:Add(lbl)
        nx_set_custom(self, pos_info[1], lbl)
      else
        lbl = nx_custom(self, pos_info[1])
      end
      lbl.x = pos_info[2]
      lbl.y = pos_info[3]
      lbl.z = pos_info[4]
      set_lbl_position(lbl, self.pic_map)
    end
  end
  if nx_is_valid(self.groupbox_move) then
    self:ToFront(self.groupbox_move)
  end
end
function update_outland_campsite(self, npc_configid, is_alive)
  if not (self ~= nil and nx_is_valid(self)) or npc_configid == nil or npc_configid == "" or is_alive == nil then
    return
  end
  if not nx_find_custom(self, npc_configid) then
    return
  end
  local camp_lbl = nx_custom(self, npc_configid)
  if is_alive == true then
    camp_lbl.BackImage = "gui\\special\\outland\\huo.png"
  else
    camp_lbl.BackImage = "gui\\special\\outland\\huoxi.png"
  end
end
function getCampsitePos(stage)
  if stage == nil or nx_int(stage) < nx_int(1) then
    return nil
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\WorldEvent\\bad_guy_vally.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string("Stages"))
    local content = ini:ReadString(sec_index, nx_string("CreateNpc"), 0)
    local content_list = util_split_string(nx_string(content), ";")
    if stage > table.getn(content_list) then
      return nil
    end
    local camp_paks = util_split_string(nx_string(content_list[stage]), ",")
    if table.getn(camp_paks) == 0 then
      return nil
    end
    local tbl_camp = {}
    ini = nx_execute("util_functions", "get_ini", "share\\WorldEvent\\bad_guy_vally_npc.ini")
    if nx_is_valid(ini) then
      for i = 1, table.getn(camp_paks) do
        local sec_index = ini:FindSectionIndex(nx_string(camp_paks[i]))
        local camp_id = ini:ReadString(sec_index, nx_string("ID"), "")
        local camp_x = ini:ReadFloat(sec_index, nx_string("TransInX"), 0)
        local camp_y = ini:ReadFloat(sec_index, nx_string("TransInY"), 0)
        local camp_z = ini:ReadFloat(sec_index, nx_string("TransInZ"), 0)
        local camp_o = ini:ReadFloat(sec_index, nx_string("TransInO"), 0)
        local camp_info = {}
        table.insert(camp_info, camp_id)
        table.insert(camp_info, camp_x)
        table.insert(camp_info, camp_y)
        table.insert(camp_info, camp_z)
        table.insert(camp_info, camp_o)
        table.insert(tbl_camp, camp_info)
      end
    end
    return tbl_camp
  end
end
function getAllCampsiteName()
  local tbl_camp = {}
  local ini = nx_execute("util_functions", "get_ini", "share\\WorldEvent\\bad_guy_vally_npc.ini")
  if nx_is_valid(ini) then
    for i = 1, ini:GetSectionCount() do
      local camp_id = ini:ReadString(i - 1, nx_string("ID"), "")
      table.insert(tbl_camp, camp_id)
    end
  end
  return tbl_camp
end
