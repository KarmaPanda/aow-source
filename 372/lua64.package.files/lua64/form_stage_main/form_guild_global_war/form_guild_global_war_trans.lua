require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("share\\logicstate_define")
local FORM_TRANS = "form_stage_main\\form_guild_global_war\\form_guild_global_war_trans"
local CLIENT_MSG_GGW_DOMAIN_TRANS = 6
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
  form.btn_trace.Visible = false
  form.domain_select = 0
  nx_execute("tips_game", "hide_tip", form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupmap_objs:Clear()
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupmap_objs:Clear()
  nx_destroy(form)
end
function open_form(domain_id)
  local form = util_show_form(FORM_TRANS, true)
  if nx_is_valid(form) then
    if nx_number(domain_id) <= 0 then
      domain_id = 101
    end
    form.domain_select = domain_id
    show_trans_map(form, form.domain_select)
    local rbtn_name = "rbtn_101" .. nx_string(domain_id)
    local rbtn = form.groupbox_domain:Find(rbtn_name)
    if not nx_is_valid(rbtn) then
      rbtn = form.rbtn_101
    end
  end
end
function show_trans_map(form, domain_id)
  if nx_number(domain_id) <= 0 then
    domain_id = 101
  end
  local scene_resource = get_scene_by_domain(domain_id)
  refresh_form(form, scene_resource)
  show_trace_pos(form, domain_id)
end
function refresh_form(form, sceneid)
  if not nx_is_valid(form) then
    return
  end
  if sceneid == "" then
    return
  end
  form.current_map = sceneid
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
  form.map_query:GroupmapInit(form)
  form.groupmap_objs.MapControl = form.pic_map
  form.map_query:LoadMapText(form, sceneid)
  set_map_zoom(form, form.pic_map.min_zoom_width, form.pic_map.min_zoom_height)
end
function show_trace_pos(form, domain_id)
  local x, y, z = get_domain_scene_trans_pos(domain_id)
  update_trace_pos(form, x, y, z)
end
function update_trace_pos(form, x, y, z)
  form.btn_trace.x = x
  form.btn_trace.z = z
  local sx, sz = trans_scene_pos_to_map(x, z, form.pic_map)
  form.btn_trace.Top = sz
  form.btn_trace.Left = sx
  form.btn_trace.Visible = true
end
function on_rbtn_domain_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.domain_select = rbtn.DataSource
  show_trans_map(form, form.domain_select)
end
function on_btn_trans_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_DOMAIN_TRANS, nx_int(form.domain_select))
    on_main_form_close(form)
  end
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
end
function on_btn_trace_get_capture(self)
  local form = self.ParentForm
  local x = nx_int(self.x)
  local z = nx_int(self.z)
  local npc_id
  local scene_id = form.current_map
  local text = nx_widestr("(") .. nx_widestr(x) .. nx_widestr(",") .. nx_widestr(z) .. nx_widestr(")")
  local gui = nx_value("gui")
  if npc_id ~= nil and nx_string(gui.TextManager:GetText(npc_id)) ~= "" then
    text = gui.TextManager:GetText(npc_id) .. nx_widestr("<br>") .. text
  end
  if scene_id ~= nil then
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
function get_scene_by_domain(domain_id)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return ""
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildGlobalWar\\domain_info.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(domain_id))
  if 0 <= index then
    local scene_id = ini:ReadInteger(index, "scene_id", 0)
    return map_query:GetSceneName(nx_string(scene_id))
  end
  return ""
end
function get_domain_scene_trans_pos(domain_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildGlobalWar\\domain_info.ini")
  if not nx_is_valid(ini) then
    return 0, 0, 0
  end
  local index = ini:FindSectionIndex(nx_string(domain_id))
  if 0 <= index then
    local trans_pos = ini:ReadString(index, "trans_point", "")
    local tab_trans = util_split_string(trans_pos, ",")
    if nx_number(#tab_trans) == 4 then
      return nx_number(tab_trans[1]), nx_number(tab_trans[2]), nx_number(tab_trans[3])
    end
  end
  return 0, 0, 0
end
