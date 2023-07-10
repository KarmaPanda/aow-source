require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("share\\logicstate_define")
local FORM_PATH = "form_stage_main\\form_taosha\\form_apex_map_scene"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = gui.Width - form.Width
  form.AbsTop = gui.Height - form.Height
  form.map_query = nx_value("MapQuery")
  form.current_map = ""
  refresh_form(form)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    form.groupmap_objs:AddMainPlayerBind("gui\\map\\icon\\me.png", game_visual:GetPlayer())
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(30, -1, nx_current(), "updata_circle_position", form, -1, -1)
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "updata_circle_position", form)
  end
  form.groupmap_objs:Clear()
  nx_destroy(form)
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
  if ratio <= 0.4 then
    ratio = 0.4
  end
  local zoom_width = form.pic_map.min_zoom_width + ratio * (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
  local zoom_height = form.pic_map.min_zoom_height + ratio * (form.pic_map.max_zoom_height - form.pic_map.min_zoom_height)
  set_map_zoom(form, zoom_width, zoom_height)
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    mgr:UpdateArenaCircle()
  end
  local TaoShaManager = nx_value("TaoShaManager")
  if nx_is_valid(TaoShaManager) then
    TaoShaManager:RefreshTaoShaEventLabelAtMap()
  end
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
  end
  if zoom_width >= min_zoom_width + average_zoom_width * 2 and (not nx_find_custom(form.pic_map, "ZoomLevel") or form.pic_map.ZoomLevel ~= 3) then
    form.pic_map.ZoomLevel = 3
  end
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
    if nx_int(form.tbar_zoom.Value) == nx_int(0) then
      set_map_zoom(form, zoom_width, zoom_height)
    end
  end
end
function on_btn_zoom_out_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = false
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.map_query) then
    return
  end
  local sceneid = form.map_query:GetCurrentScene()
  if sceneid == "" then
    return
  end
  form.current_map = sceneid
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
  form.groupmap_objs.MapControl = form.pic_map
  set_map_zoom(form, 1, 1)
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
  form.pic_map.ZoomWidth = 1
  form.pic_map.ZoomHeight = 1
  local ratio = (form.pic_map.ZoomWidth - form.pic_map.min_zoom_width) / (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
  ratio = 1 - ratio
  form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
end
function updata_circle_position()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local TaoShaManager = nx_value("TaoShaManager")
  if nx_is_valid(TaoShaManager) then
    TaoShaManager:RefreshTaoShaEventLabelAtMap()
  end
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    mgr:UpdateArenaCircle()
  end
  form:ToFront(form.gb_lbl)
end
function show_or_hide_form()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = not form.Visible
end
function close_form()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function open_form()
  local flag = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if not flag then
    return
  end
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_PATH, true)
  end
end
