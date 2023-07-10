require("util_functions")
require("role_composite")
local obj_table = {}
function create_obj(obj_name, obj_resource, obj_message, x, y, z, angle_x, angle_y, angle_z)
  local obj = get_obj(nx_string(obj_name))
  if nx_is_valid(obj) then
    return
  end
  local manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(manager) then
    return
  end
  local scene = nx_value("game_scene")
  local actor2 = nx_null()
  if string.find(obj_resource, "npc\\") then
    actor2 = create_scene_npc(manager.Terrain, nx_string(obj_resource))
  elseif obj_resource == "" then
    actor2 = create_role_model(manager.Terrain)
  else
    actor2 = create_model(manager.Terrain, nx_string(obj_resource))
  end
  if nx_is_valid(actor2) then
    obj_table[nx_string(obj_name)] = actor2
    actor2.name = nx_string(obj_name)
    actor2.Color = "255,255,255,255"
    manager.Terrain:RelocateVisual(actor2, nx_float(x), nx_float(y), nx_float(z))
    if angle_x and angle_y and angle_z then
      actor2:SetAngle(nx_float(angle_x), nx_float(angle_y), nx_float(angle_z))
    end
    if obj_message then
      actor2.info = ""
      nx_execute("head_game", "create_client_npc_head", actor2)
      local head_game = nx_value("HeadGame")
      if nx_is_valid(head_game) then
        head_game:ShowClientNpcChatTextOnHead(actor2, nx_widestr(obj_message), 86400000)
      end
    end
  end
end
function get_obj(obj_name)
  local actor2 = obj_table[nx_string(obj_name)]
  if not actor2 then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  return actor2
end
function delete_camera_obj(obj_name)
  local actor2 = obj_table[nx_string(obj_name)]
  if not actor2 then
    return false
  end
  local scene = nx_value("game_scene")
  if nx_is_valid(actor2) then
    scene:Delete(actor2)
  end
  obj_table[nx_string(obj_name)] = nx_null()
  return true
end
function create_scene_npc(terrain, res_name)
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  local actor2 = nx_null()
  if res_name ~= nil and string.len(res_name) > 0 then
    actor2 = nx_execute("role_composite", "create_actor2", scene)
    if not nx_is_valid(actor2) then
      return nx_null()
    end
    actor2.AsyncLoad = true
    local result = load_from_ini(actor2, "ini\\" .. res_name .. ".ini")
    if not result then
      scene:Delete(actor2)
      return nx_null()
    end
    terrain:AddVisualRole("", actor2)
    terrain:RelocateVisual(actor2, 0, 0, 0)
    terrain:RefreshVisual()
  end
  return actor2
end
function relocate_obj(obj, x, y, z)
  local manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(manager) then
    return
  end
  if not nx_is_valid(obj) then
    return
  end
  manager.Terrain:RelocateVisual(obj, nx_float(x), nx_float(y), nx_float(z))
end
function reangle_obj(obj, angleX, angleY, angleZ)
  if not nx_is_valid(obj) then
    return
  end
  obj:SetAngle(nx_float(angleX), nx_float(angleY), nx_float(angleZ))
end
function create_camera()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local camera = scene:Create("Camera")
  camera.Fov = 0.125 * math.pi * 2
  nx_bind_logic(camera, "FreeCamera")
  camera:SetPosition(512, 5, 512)
  camera:SetAngle(0, 0, 0)
  camera.allow_wasd = true
  camera.move_speed = 10
  camera.drag_speed = 0.1
  camera.NearPlane = 0.1
  camera.FarPlane = 2000
  camera.AllowControl = true
  camera:Load()
  scene:AddObject(camera, 1)
  nx_set_value("control_camera", camera)
end
function set_camera_mode(form, free_mode, speed, drag_speed)
  local scene = nx_value("game_scene")
  if free_mode then
    local new_camera = nx_value("control_camera")
    if not nx_is_valid(new_camera) then
      scene.old_camera = scene.camera
      scene:RemoveObject(scene.old_camera)
      create_camera()
      new_camera = nx_value("control_camera")
      new_camera:SetPosition(scene.old_camera.PositionX, scene.old_camera.PositionY, scene.old_camera.PositionZ)
      new_camera:SetAngle(scene.old_camera.AngleX, scene.old_camera.AngleY, scene.old_camera.AngleZ)
    end
    new_camera = nx_value("control_camera")
    if speed ~= nil and drag_speed ~= nil then
      if speed < 1 or 200 < speed then
        speed = 10
      end
      if drag_speed < 0.01 or 1 < drag_speed then
        drag_speed = 0.1
      end
      new_camera.move_speed = speed
      new_camera.drag_speed = drag_speed
    end
    if nx_is_valid(scene.game_control) then
      scene.game_control.AllowControl = false
    end
    scene.old_camera.AllowControl = false
    new_camera.AllowControl = true
  else
    local new_camera = nx_value("control_camera")
    if nx_is_valid(new_camera) then
      scene:RemoveObject(new_camera)
      scene:Delete(new_camera)
    end
    if nx_find_custom(scene, "old_camera") and nx_is_valid(scene.old_camera) then
      scene:AddObject(scene.old_camera, 1)
      scene.camera = scene.old_camera
    end
    if nx_is_valid(scene.game_control) then
      scene.game_control.AllowControl = true
    end
  end
end
local MENUCUT = 0
local MENUCOPY = 1
local MENUDELETE = 2
local MENUPASTE = 3
local array_camera_points = {}
local array_points_string = {}
local array_subtitle = {}
local weather_table
local MAXPOINTCOUNT = 3600
local segment_flag = 0
local scene_sky_UpTex, scene_sky_SideTex, scene_sky_YawSpeed, scene_sun_GlowTex, scene_sun_FlareTex, scene_sun_ShowGlow, scene_sun_ShowFlare, scene_sun_GlowSize, scene_sun_FlareSize, scene_sun_GlowDistance, scene_sun_FlareDistance, scene_weather_sun_color, scene_weather_sun_intensity, scene_weather_ambient_color, scene_weather_ambient_intensity, scene_weather_specular_color, scene_weather_sun_direction, scene_weather_wind_speed, scene_weather_wind_angle, count_sun_start_azimuth_angle, count_sun_start_height_angle, count_wind_start_speed, count_wind_start_angle, count_sun_end_azimuth_angle, count_sun_end_height_angle, count_wind_end_speed, count_wind_end_angle, count_sky_start_YawSpeed, count_sky_end_YawSpeed, count_sun_start_GlowSize, count_sun_end_GlowSize, count_sun_start_FlareSize, count_sun_end_FlareSize, count_sun_start_GlowDistance, count_sun_end_GlowDistance, count_sun_start_FlareDistance, count_sun_end_FlareDistance, count_weather_sun_start_intensity, count_weather_sun_end_intensity, count_weather_ambient_start_intensity, count_weather_ambient_end_intensity
function init(form)
  form.Fixed = false
  form.ini = nx_create("IniDocument")
  form.ini:AddSection("scenario_camera")
  form.ini:WriteInteger("scenario_camera", "pathtype", 3)
  form.ini:WriteInteger("scenario_camera", "angletype", 4)
  form.ini:WriteInteger("scenario_camera", "modetype", 0)
  form.angleType = 4
  form.pointClipboard = nil
  form.subtitleClipboard1 = nil
  form.subtitleClipboard2 = nil
  array_camera_points = {}
  array_points_string = {}
  form.weather_ini = nx_create("IniDocument")
  form.weather_ini.FileName = nx_resource_path() .. "ini\\Scenario\\weather\\save_camera_weather.ini"
  form.weather_ini:LoadFromFile()
  form.selected_weather = 0
  form.Ispause = false
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local scene_sky = scene.sky
  if nx_is_valid(scene_sky) then
    scene_sky_UpTex = scene_sky.UpTex
    scene_sky_SideTex = scene_sky.SideTex
    scene_sky_YawSpeed = scene_sky.YawSpeed
  end
  local scene_sun = scene.sun
  if nx_is_valid(scene_sun) then
    scene_sun_GlowTex = scene_sun.GlowTex
    scene_sun_FlareTex = scene_sun.FlareTex
    scene_sun_ShowGlow = scene_sun.ShowGlow
    scene_sun_ShowFlare = scene_sun.ShowFlare
    scene_sun_GlowSize = scene_sun.GlowSize
    scene_sun_FlareSize = scene_sun.FlareSize
    scene_sun_GlowDistance = scene_sun.GlowDistance
    scene_sun_FlareDistance = scene_sun.FlareDistance
  end
  local scene_weather = scene.Weather
  if nx_is_valid(scene_weather) then
    scene_weather_sun_color = scene_weather.SunGlowColor
    scene_weather_sun_intensity = scene_weather.SunGlowIntensity
    scene_weather_ambient_color = scene_weather.AmbientColor
    scene_weather_ambient_intensity = scene_weather.AmbientIntensity
    scene_weather_specular_color = scene_weather.SpecularColor
    scene_weather_sun_direction = scene_weather.SunDirection
    scene_weather_wind_speed = scene_weather.WindSpeed
    scene_weather_wind_angle = scene_weather.WindAngle
  end
  form.subtitle_content = ""
  form.subtitle_duration = 0
  form.subtitle_toporbottom = 0
  form.play_time = 0
  form.IsShowSubtitle = true
  form.IsShowCamera = false
end
function on_main_form_open(form)
  form.btn_add_point.Enabled = true
  form.btn_delete_point.Enabled = false
  form.btn_edit_point.Enabled = false
  form.btn_copy_point.Enabled = false
  form.btn_cut_point.Enabled = false
  form.btn_paste_point.Enabled = false
  form.btn_add_subtitle.Enabled = false
  form.btn_del_subtitle.Enabled = false
  form.btn_edit_subtitle.Enabled = false
  form.textgrid_timeaction:SetGridBackColor(1, 1, "255,200,100,100")
  form.textgrid_timeaction:InsertRow(-1)
  form.textgrid_timeaction:InsertRow(-1)
  form.textgrid_timeaction:InsertRow(-1)
  for i = 0, form.textgrid_timeaction.ColCount - 1 do
    form.textgrid_timeaction:SetGridText(2, i, nx_widestr(nx_float(i)))
  end
  form.btn_test.Enabled = false
  form.rbtn_point.Checked = true
  form.cbtn_show_subtitle.Checked = false
  form.textgrid_timeaction:SelectRow(1)
  form.textgrid_timeaction:SelectCol(0)
  form.select_point_index = 0
  form.select_subtitle_index = 0
  weather_table = form.weather_ini:GetSectionList()
  local weather_count = form.weather_ini:GetSectionCount()
  local no_weather = "\179\161\190\176\196\172\200\207"
  form.combobox_weather.InputEdit.Text = nx_widestr(no_weather)
  form.combobox_weather.DropListBox:AddString(nx_widestr(no_weather))
  for i = 1, weather_count do
    local weather_name = form.weather_ini:ReadString(weather_table[i], "name", "")
    form.combobox_weather.DropListBox:AddString(nx_widestr(weather_name))
  end
  form.combobox_weather.OnlySelect = true
  form.combobox_weather.DropListBox.SelectIndex = 0
  init_operation_menu(form)
  form.menu_operation:GetItem(MENUCUT).Disable = true
  form.menu_operation:GetItem(MENUCOPY).Disable = true
  form.menu_operation:GetItem(MENUDELETE).Disable = true
  form.menu_operation:GetItem(MENUPASTE).Disable = true
  init_file_menu(form)
  form.scene_name = ""
  local client = nx_value("game_client")
  local scene = client:GetScene()
  if nx_is_valid(scene) then
    form.scene_name = scene:QueryProp("Resource")
  end
  if form.scene_name == nil or form.scene_name == "" then
    form.scene_name = "unknown"
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = gui.Height / 2
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    if form.IsShowCamera then
      delete_camera_in_scene()
    end
    nx_destroy(form)
  end
  array_camera_points = {}
  array_points_string = {}
  array_subtitle = {}
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_open_file_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("form_common\\form_open_file", "util_open_file", "*.9ycs")
  local res, filepath, file = nx_wait_event(100000000, dialog, "open_file_return")
  if not nx_is_valid(form) then
    return
  end
  if res == "ok" then
    form.ini.FileName = filepath
    if not read_from_ini(form) then
      return
    end
    if form.angleType == 1 then
      form.rbtn_move.Checked = true
    elseif form.angleType == 2 then
      form.rbtn_player.Checked = true
    elseif form.angleType == 5 then
      form.rbtn_free.Checked = true
    else
      form.rbtn_point.Checked = true
    end
    if form.IsShowSubtitle then
      form.cbtn_show_subtitle.Checked = true
    else
      form.cbtn_show_subtitle.Checked = false
    end
    form.combobox_weather.DropListBox.SelectIndex = form.selected_weather
    form.combobox_weather.InputEdit.Text = form.combobox_weather.DropListBox.SelectString
    refresh_array_camera_points()
    refresh_grid(form.textgrid_timeaction, 0)
    refresh_grid(form.textgrid_timeaction, 1)
    local colindex = form.textgrid_timeaction.ColSelectIndex
    refresh_btn_adddeledit_grid(form.textgrid_timeaction, 1, colindex)
    refresh_pointinfo(form, 1, colindex)
    if form.IsShowCamera then
      create_camera_in_scene()
    end
  end
end
function on_btn_play_all_click(btn)
  if array_camera_points[1] == nil then
    return
  end
  if array_camera_points[2] == nil then
    return
  end
  local form = btn.ParentForm
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(scenario_npc_manager) then
    return 0
  end
  local old_form_ininame = form.ini.FileName
  local temp_file_name = nx_resource_path() .. "cameraPlaytemp9y"
  rewrite_to_ini(form)
  form.ini.FileName = temp_file_name
  form.ini:SaveToFile()
  form.ini.FileName = old_form_ininame
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  local camera_time = table.getn(array_camera_points)
  form.play_time = camera_time
  if 0 == form.play_time then
    return
  end
  set_temp_weather(form)
  form.Visible = false
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera_playing", true, false)
  dialog:Show()
  scenario_npc_manager:PlayCameraPath(temp_file_name)
  local res = nx_wait_event(100000000, dialog, "camera_stop_playing")
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
end
function on_textgrid_timeaction_select_grid(grid, row, col)
  local form = grid.ParentForm
  local menu = form.menu_operation
  menu.Visible = false
  if 0 == row then
    local last_lbl_point = grid:GetGridControl(1, form.select_point_index)
    if nx_is_valid(last_lbl_point) then
      last_lbl_point.BackImage = "gui\\special\\camera\\btn_camera_out.png"
    end
    local last_lbl_subtitle = grid:GetGridControl(row, form.select_subtitle_index)
    if nx_is_valid(last_lbl_subtitle) then
      last_lbl_subtitle.BackImage = "gui\\special\\camera\\subtitle_out.png"
    end
    local this_lbl_subtitle = grid:GetGridControl(row, col)
    if nx_is_valid(this_lbl_subtitle) then
      this_lbl_subtitle.BackImage = "gui\\special\\camera\\subtitle_on.png"
    end
    form.select_subtitle_index = col
    form.select_point_index = 0
  end
  if 1 == row then
    local last_lbl_subtitle = grid:GetGridControl(0, form.select_subtitle_index)
    if nx_is_valid(last_lbl_subtitle) then
      last_lbl_subtitle.BackImage = "gui\\special\\camera\\subtitle_out.png"
    end
    refresh_btn_adddeledit_grid(grid, row, col)
    local last_lbl_point = grid:GetGridControl(row, form.select_point_index)
    if nx_is_valid(last_lbl_point) then
      last_lbl_point.BackImage = "gui\\special\\camera\\btn_camera_out.png"
    end
    local this_lbl_point = grid:GetGridControl(row, col)
    if nx_is_valid(this_lbl_point) then
      this_lbl_point.BackImage = "gui\\special\\camera\\btn_camera_on.png"
    end
    form.select_point_index = col
    form.select_subtitle_index = 0
  elseif 0 == row then
    form.btn_add_point.Enabled = false
    form.btn_delete_point.Enabled = false
    form.btn_edit_point.Enabled = false
    form.btn_copy_point.Enabled = false
    form.btn_cut_point.Enabled = false
    form.btn_paste_point.Enabled = false
    refresh_btn_subtitle(form, row, col)
  else
    form.btn_add_point.Enabled = false
    form.btn_delete_point.Enabled = false
    form.btn_edit_point.Enabled = false
    form.btn_copy_point.Enabled = false
    form.btn_cut_point.Enabled = false
    form.btn_paste_point.Enabled = false
    form.menu_operation:GetItem(MENUCUT).Disable = true
    form.menu_operation:GetItem(MENUCOPY).Disable = true
    form.menu_operation:GetItem(MENUDELETE).Disable = true
    form.menu_operation:GetItem(MENUPASTE).Disable = true
  end
  refresh_pointinfo(form, row, col)
end
function refresh_btn_adddeledit_grid(grid, row, col)
  if row ~= 1 then
    form.btn_add_point.Enabled = false
    form.btn_delete_point.Enabled = false
    form.btn_edit_point.Enabled = false
    form.btn_copy_point.Enabled = false
    form.btn_cut_point.Enabled = false
    form.menu_operation:GetItem(MENUCUT).Disable = true
    form.menu_operation:GetItem(MENUCOPY).Disable = true
    form.menu_operation:GetItem(MENUDELETE).Disable = true
    return
  end
  local form = grid.ParentForm
  if form.pointClipboard then
    form.btn_paste_point.Enabled = true
    form.menu_operation:GetItem(MENUPASTE).Disable = false
  else
    form.btn_paste_point.Enabled = false
    form.menu_operation:GetItem(MENUPASTE).Disable = true
  end
  if col < 0 or col >= MAXPOINTCOUNT then
    form.btn_add_point.Enabled = false
    form.btn_delete_point.Enabled = false
    form.btn_edit_point.Enabled = false
    form.btn_copy_point.Enabled = false
    form.btn_cut_point.Enabled = false
    form.menu_operation:GetItem(MENUCUT).Disable = true
    form.menu_operation:GetItem(MENUCOPY).Disable = true
    form.menu_operation:GetItem(MENUDELETE).Disable = true
    return
  end
  if array_camera_points[1] == nil then
    if col == 0 then
      form.btn_add_point.Enabled = true
      if form.pointClipboard then
        form.btn_paste_point.Enabled = true
        form.menu_operation:GetItem(MENUPASTE).Disable = false
      else
        form.btn_paste_point.Enabled = false
        form.menu_operation:GetItem(MENUPASTE).Disable = true
      end
    else
      form.btn_add_point.Enabled = false
      form.btn_paste_point.Enabled = false
      form.menu_operation:GetItem(MENUPASTE).Disable = true
    end
    form.btn_delete_point.Enabled = false
    form.btn_edit_point.Enabled = false
    form.btn_copy_point.Enabled = false
    form.btn_cut_point.Enabled = false
    form.menu_operation:GetItem(MENUCUT).Disable = true
    form.menu_operation:GetItem(MENUCOPY).Disable = true
    form.menu_operation:GetItem(MENUDELETE).Disable = true
    return
  else
    if col == 0 then
      form.btn_edit_point.Enabled = true
      form.btn_add_point.Enabled = false
      form.btn_copy_point.Enabled = true
      form.menu_operation:GetItem(MENUCOPY).Disable = false
      if array_camera_points[2] == nil then
        form.btn_delete_point.Enabled = true
        form.btn_cut_point.Enabled = true
        form.menu_operation:GetItem(MENUCUT).Disable = false
        form.menu_operation:GetItem(MENUDELETE).Disable = false
      else
        form.btn_delete_point.Enabled = false
        form.btn_cut_point.Enabled = false
        form.menu_operation:GetItem(MENUCUT).Disable = true
        form.menu_operation:GetItem(MENUDELETE).Disable = true
      end
      return
    end
    if is_edit_point(col) then
      form.btn_add_point.Enabled = false
      form.btn_delete_point.Enabled = true
      form.btn_edit_point.Enabled = true
      form.btn_copy_point.Enabled = true
      form.btn_cut_point.Enabled = true
      form.menu_operation:GetItem(MENUCUT).Disable = false
      form.menu_operation:GetItem(MENUCOPY).Disable = false
      form.menu_operation:GetItem(MENUDELETE).Disable = false
    else
      form.btn_add_point.Enabled = true
      form.btn_delete_point.Enabled = false
      form.btn_edit_point.Enabled = false
      form.btn_copy_point.Enabled = false
      form.btn_cut_point.Enabled = false
      form.menu_operation:GetItem(MENUCUT).Disable = true
      form.menu_operation:GetItem(MENUCOPY).Disable = true
      form.menu_operation:GetItem(MENUDELETE).Disable = true
    end
  end
end
function add_point(form, pointStr)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local textgrid = form.textgrid_timeaction
  local addcolindex = textgrid.ColSelectIndex
  local addrowindex = textgrid.RowSelectIndex
  local res, pointindex, thistime, nexttime = add_array_point(addcolindex)
  if res then
    local lbl = gui:Create("Label")
    lbl.BackImage = "gui\\special\\camera\\btn_camera_out.png"
    lbl.ForeColor = "255,255,255,0"
    lbl.Align = "Center"
    lbl.Text = nx_widestr(pointindex)
    textgrid:SetGridControl(addrowindex, addcolindex, lbl)
    add_current_string(pointindex, thistime, nexttime, pointStr)
    for i = addcolindex, MAXPOINTCOUNT do
      if array_camera_points[i] == nil then
        break
      end
      if 10000 <= array_camera_points[i] then
        local lbl = textgrid:GetGridControl(addrowindex, i - 1)
        if nx_is_valid(lbl) then
          lbl.Text = nx_widestr(array_camera_points[i] - 10000)
        end
      end
    end
    refresh_btn_adddeledit_grid(textgrid, addrowindex, addcolindex)
    refresh_pointinfo(form, 1, addcolindex)
    delete_camera_in_scene()
    if form.IsShowCamera then
      create_camera_in_scene()
    end
  end
end
function on_btn_add_point_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local rowindex = textgrid.RowSelectIndex
  if 0 == rowindex then
    on_btn_add_subtitle_click(btn)
  elseif 1 == rowindex then
    add_point(form, nil)
  end
end
function on_btn_delete_point_click(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local addcolindex = textgrid.ColSelectIndex
  local addrowindex = textgrid.RowSelectIndex
  local addrowindex = textgrid.RowSelectIndex
  if 1 < addrowindex then
    return
  end
  local res, pointindex, time = delete_array_point(addcolindex)
  if res then
    textgrid:ClearGridControl(addrowindex, addcolindex)
    delete_current_string(pointindex, time)
    for i = addcolindex, MAXPOINTCOUNT do
      if array_camera_points[i] == nil then
        break
      end
      if 10000 <= array_camera_points[i] then
        local lbl = textgrid:GetGridControl(addrowindex, i - 1)
        if nx_is_valid(lbl) then
          lbl.Text = nx_widestr(array_camera_points[i] - 10000)
        end
      end
    end
    refresh_btn_adddeledit_grid(textgrid, addrowindex, addcolindex)
    refresh_pointinfo(form, 1, addcolindex)
    delete_camera_in_scene()
    if form.IsShowCamera then
      create_camera_in_scene()
    end
  end
end
function is_edit_point(index)
  if array_camera_points[index + 1] then
    local point = array_camera_points[index + 1]
    if 10000 <= point then
      return true
    end
  end
  return false
end
function add_array_point(index)
  if is_edit_point(index) then
    return false
  end
  if index >= MAXPOINTCOUNT and index < 0 then
    return false
  end
  if index == 0 then
    array_camera_points[index + 1] = 10001
    return true, 1, 0, 0
  end
  local counterflagT = 0
  local counterflagN = 0
  local endindex = MAXPOINTCOUNT
  if array_camera_points[index + 1] == nil then
    for i = index, 0, -1 do
      if array_camera_points[i] ~= nil then
        endindex = i
        break
      end
      counterflagT = counterflagT + 1
    end
    local endpoint = array_camera_points[endindex]
    array_camera_points[index + 1] = endpoint + 1
    for i = endindex + 1, index do
      array_camera_points[i] = endpoint + 1 - 10000
    end
    return true, endpoint + 1 - 10000, counterflagT + 1, counterflagN
  end
  local point = array_camera_points[index + 1]
  array_camera_points[index + 1] = point + 10000
  local nextpoint = index + 2
  for i = index + 2, MAXPOINTCOUNT do
    if 10000 <= array_camera_points[i] then
      nextpoint = i
      break
    end
    counterflagN = counterflagN + 1
    array_camera_points[i] = point + 1
  end
  for i = nextpoint, MAXPOINTCOUNT do
    if array_camera_points[i] == nil then
      break
    end
    array_camera_points[i] = array_camera_points[i] + 1
  end
  for i = index, 0, -1 do
    if 10000 <= array_camera_points[i] then
      break
    end
    counterflagT = counterflagT + 1
  end
  return true, point, counterflagT + 1, counterflagN + 1
end
function delete_array_point(index)
  if not is_edit_point(index) then
    return false
  end
  if index == 0 then
    if array_camera_points[2] ~= nil then
      return false
    else
      array_camera_points[1] = nil
      return true, 1, 0
    end
  end
  local point = 0
  local counterflag = 1
  if array_camera_points[index + 2] == nil then
    point = array_camera_points[index + 1] - 10000
    array_camera_points[index + 1] = nil
    for i = index, 0, -1 do
      if 10000 <= array_camera_points[i] then
        break
      end
      array_camera_points[i] = nil
      counterflag = counterflag + 1
    end
    return true, point, counterflag
  end
  point = array_camera_points[index + 1] - 10000
  array_camera_points[index + 1] = point
  for i = index, 0, -1 do
    if 10000 <= array_camera_points[i] then
      break
    end
    counterflag = counterflag + 1
  end
  for i = index + 2, MAXPOINTCOUNT do
    if array_camera_points[i] == nil then
      break
    end
    array_camera_points[i] = array_camera_points[i] - 1
  end
  return true, point, counterflag
end
function print_array_camera_points()
  for i = 1, MAXPOINTCOUNT do
    if array_camera_points[i] == nil then
      break
    end
  end
  for i = 1, MAXPOINTCOUNT do
    if array_points_string[i] == nil then
      break
    end
  end
end
function on_btn_test_click(btn)
end
function refresh_pointinfo(form, rowindex, colindex)
  if 1 == rowindex and is_edit_point(colindex) then
    local pointorder = array_camera_points[colindex + 1] - 10000
    local time = array_points_string[pointorder][2]
    local str_pointinfoT = array_points_string[pointorder][1]
    local string_tableT = util_split_string(str_pointinfoT, ",")
    form.fipt_pos_x.Text = nx_widestr(string_tableT[2])
    form.fipt_pos_y.Text = nx_widestr(string_tableT[3])
    form.fipt_pos_z.Text = nx_widestr(string_tableT[4])
    form.fipt_angle_x.Text = nx_widestr(string_tableT[5])
    form.fipt_angle_y.Text = nx_widestr(string_tableT[6])
    form.fipt_angle_z.Text = nx_widestr(string_tableT[7])
    form.ipt_move_mode.Text = nx_widestr(string_tableT[8])
    form.fipt_pos_x.Format = nx_widestr("%.2f")
    form.fipt_pos_y.Format = nx_widestr("%.2f")
    form.fipt_pos_z.Format = nx_widestr("%.2f")
    form.fipt_angle_x.Format = nx_widestr("%.2f")
    form.fipt_angle_y.Format = nx_widestr("%.2f")
    form.fipt_angle_z.Format = nx_widestr("%.2f")
    if math.abs(time) > 1.0E-4 and colindex ~= 0 then
      local str_pointinfoP = array_points_string[pointorder - 1][1]
      local string_tableP = util_split_string(str_pointinfoP, ",")
      local x_dif = string_tableP[2] - string_tableT[2]
      local y_dif = string_tableP[3] - string_tableT[3]
      local z_dif = string_tableP[4] - string_tableT[4]
      local dis_dif = math.sqrt(x_dif ^ 2 + y_dif ^ 2 + z_dif ^ 2)
      local move_v = dis_dif / time
      form.fipt_move_velocity.Text = nx_widestr(move_v)
      form.fipt_move_velocity.Format = nx_widestr("%.2f")
    else
      form.fipt_move_velocity.Text = nx_widestr("")
    end
  else
    form.fipt_pos_x.Text = nx_widestr("")
    form.fipt_pos_y.Text = nx_widestr("")
    form.fipt_pos_z.Text = nx_widestr("")
    form.fipt_angle_x.Text = nx_widestr("")
    form.fipt_angle_y.Text = nx_widestr("")
    form.fipt_angle_z.Text = nx_widestr("")
    form.fipt_move_velocity.Text = nx_widestr("")
    form.ipt_move_mode.Text = nx_widestr("")
  end
end
function add_current_string(index, thistime, nexttime, pointStr)
  local time = 0
  local camera = nx_value("control_camera")
  if not nx_is_valid(camera) then
    camera = nx_value("camera")
    if not nx_is_valid(camera) then
      local scene = nx_value("game_scene")
      if nx_is_valid(scene) then
        camera = scene.camera
      end
    end
  end
  local movemode = "smooth"
  if index == 1 then
    movemode = "direct"
  end
  if pointStr then
    str_point_info = pointStr
  else
    str_point_info = "stop," .. camera.PositionX .. "," .. camera.PositionY .. "," .. camera.PositionZ .. "," .. camera.AngleX .. "," .. camera.AngleY .. "," .. camera.AngleZ .. "," .. movemode .. ","
  end
  if nexttime ~= 0 then
    array_points_string[index][2] = nexttime
  end
  table.insert(array_points_string, index, {str_point_info, thistime})
end
function delete_current_string(index, thistime)
  if array_points_string[index + 1] ~= nil then
    array_points_string[index + 1][2] = array_points_string[index + 1][2] + thistime
  end
  table.remove(array_points_string, index)
end
function rewrite_to_ini(form)
  if nx_is_valid(form.ini) then
    form.ini:DeleteSection("scenario_camera")
    form.ini:AddSection("scenario_camera")
    form.ini:WriteInteger("scenario_camera", "angletype", form.angleType)
    form.ini:WriteInteger("scenario_camera", "modetype", 0)
    form.ini:WriteInteger("scenario_camera", "weather", form.selected_weather)
    form.ini:WriteString("scenario_camera", "scene", form.scene_name)
    if form.IsShowSubtitle then
      form.ini:WriteInteger("scenario_camera", "showsubtitle", 1)
    else
      form.ini:WriteInteger("scenario_camera", "showsubtitle", 0)
    end
    if form.IsShowCamera then
      form.ini:WriteInteger("scenario_camera", "showcamera", 1)
    else
      form.ini:WriteInteger("scenario_camera", "showcamera", 0)
    end
    for i = 1, MAXPOINTCOUNT do
      if array_points_string[i] == nil then
        break
      end
      form.ini:WriteString("scenario_camera", "time_action" .. i - 1, array_points_string[i][1] .. array_points_string[i][2])
    end
    for i = 1, MAXPOINTCOUNT do
      if array_subtitle[i] == nil then
        break
      end
      form.ini:WriteString("scenario_camera", "subtitle_time" .. i - 1, array_subtitle[i][1])
      form.ini:WriteString("scenario_camera", "subtitle_content" .. i - 1, array_subtitle[i][2])
    end
    return true
  end
  return false
end
function read_from_ini(form)
  if nx_is_valid(form.ini) then
    form.ini:LoadFromFile()
    local string_scene = form.ini:ReadString("scenario_camera", "scene", "")
    if string_scene ~= form.scene_name then
      local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera_error", true, false)
      dialog.errorInfo = "ui_savecamera_loadini_error"
      dialog:ShowModal()
      return false
    end
    array_points_string = {}
    local angle = form.ini:ReadInteger("scenario_camera", "angletype", 4)
    form.angleType = angle
    local weather = form.ini:ReadInteger("scenario_camera", "weather", 0)
    form.selected_weather = weather
    local show_subtitle = form.ini:ReadInteger("scenario_camera", "showsubtitle", 0)
    if 0 == show_subtitle then
      form.IsShowSubtitle = false
    else
      form.IsShowSubtitle = true
    end
    local show_camera = form.ini:ReadInteger("scenario_camera", "showcamera", 0)
    if 0 == show_camera then
      form.IsShowCamera = false
    else
      form.IsShowCamera = true
    end
    array_points_string = {}
    for i = 0, MAXPOINTCOUNT do
      local action_string = form.ini:ReadString("scenario_camera", "time_action" .. i, "")
      if action_string == "" then
        break
      else
        local string_table = util_split_string(action_string, ",")
        local str_point_info = string_table[1] .. "," .. string_table[2] .. "," .. string_table[3] .. "," .. string_table[4] .. "," .. string_table[5] .. "," .. string_table[6] .. "," .. string_table[7] .. "," .. string_table[8] .. ","
        local time = nx_number(string_table[9])
        table.insert(array_points_string, i + 1, {str_point_info, time})
      end
    end
    array_subtitle = {}
    for i = 0, MAXPOINTCOUNT do
      local subtitle_time = form.ini:ReadString("scenario_camera", "subtitle_time" .. i, "")
      local subtitle_content = form.ini:ReadString("scenario_camera", "subtitle_content" .. i, "")
      if subtitle_time == "" then
        break
      else
        table.insert(array_subtitle, i + 1, {subtitle_time, subtitle_content})
      end
    end
    return true
  end
  return false
end
function refresh_array_camera_points()
  array_camera_points = {}
  local counter_flag = 1
  for i = 1, MAXPOINTCOUNT do
    if array_points_string[i] == nil then
      break
    end
    local time = nx_number(array_points_string[i][2])
    for k = 0, time - 2 do
      array_camera_points[counter_flag] = i
      counter_flag = counter_flag + 1
    end
    array_camera_points[counter_flag] = 10000 + i
    counter_flag = counter_flag + 1
  end
end
function refresh_grid(grid, row)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if 0 == row then
    for i = 0, MAXPOINTCOUNT do
      grid:ClearGridControl(0, i)
    end
    for i = 1, MAXPOINTCOUNT do
      if array_subtitle[i] == nil then
        break
      end
      local string_table = util_split_string(array_subtitle[i][1], ",")
      local count = table.maxn(string_table)
      if count < 3 then
        break
      end
      local begin_time = nx_number(string_table[1])
      local duration = nx_number(string_table[2])
      local lbl = gui:Create("Label")
      lbl.BackImage = "gui\\special\\camera\\subtitle_out.png"
      lbl.Align = "Center"
      lbl.Text = nx_widestr(i)
      grid:SetGridControl(0, begin_time, lbl)
    end
  elseif 1 == row then
    local flag = 0
    for i = 1, MAXPOINTCOUNT do
      if array_camera_points[i] == nil then
        flag = i
        break
      end
      if 10000 <= array_camera_points[i] then
        local lbl = gui:Create("Label")
        lbl.BackImage = "gui\\special\\camera\\btn_camera_out.png"
        lbl.ForeColor = "255,255,255,0"
        lbl.Align = "Center"
        lbl.Text = nx_widestr(array_camera_points[i] - 10000)
        grid:SetGridControl(1, i - 1, lbl)
      else
        grid:ClearGridControl(1, i - 1)
      end
    end
    for k = flag - 1, grid.ColCount - 1 do
      grid:ClearGridControl(1, k)
    end
  end
end
function create_camera_in_scene()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 1, MAXPOINTCOUNT do
    if array_points_string[i] == nil then
      break
    end
    local string_table = util_split_string(array_points_string[i][1], ",")
    local count = table.maxn(string_table)
    if count < 6 then
      break
    end
    local cameraTag = gui.TextManager:GetText("ui_camera_name")
    local strtemp = nx_widestr(cameraTag) .. nx_widestr(i)
    local res = create_obj("camera" .. i, "npc\\itemnpc547", strtemp, nx_number(string_table[2]), nx_number(string_table[3]), nx_number(string_table[4]), nx_number(string_table[5]), nx_number(string_table[6]), nx_number(string_table[7]))
  end
end
function delete_camera_in_scene()
  for i = 1, MAXPOINTCOUNT do
    local res = delete_camera_obj("camera" .. i)
    if not res then
      break
    end
  end
end
function on_btn_create_camera_click(btn)
  delete_camera_in_scene()
  create_camera_in_scene()
  local form = btn.ParentForm
  form.IsShowCamera = true
end
function on_btn_delete_camera_click(btn)
  delete_camera_in_scene()
  local form = btn.ParentForm
  form.IsShowCamera = false
end
function on_btn_edit_point_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local rowindex = textgrid.RowSelectIndex
  if 0 == rowindex then
    on_btn_edit_subtitle_click(btn)
  elseif 1 == rowindex then
    edit_point(btn)
  end
end
function edit_point(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = btn.ParentForm
  form.Visible = false
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local pointorder = array_camera_points[colindex + 1] - 10000
  local str_pointinfoT = array_points_string[pointorder][1]
  local string_tableT = util_split_string(str_pointinfoT, ",")
  form.pos_x = nx_number(string_tableT[2])
  form.pos_y = nx_number(string_tableT[3])
  form.pos_z = nx_number(string_tableT[4])
  form.angle_x = nx_number(string_tableT[5])
  form.angle_y = nx_number(string_tableT[6])
  form.angle_z = nx_number(string_tableT[7])
  form.move_mode = string_tableT[8]
  delete_camera_in_scene()
  create_camera_in_scene()
  local camera_name = "camera" .. pointorder
  local obj_camera = get_obj(camera_name)
  obj_camera.ShowBoundBox = true
  set_camera_mode(form, true)
  local view_camera = nx_value("control_camera")
  if nx_is_valid(view_camera) then
    view_camera:SetPosition(form.pos_x, form.pos_y, form.pos_z)
    view_camera:SetAngle(form.angle_x, form.angle_y, form.angle_z)
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera_edit_point", true, false)
  local cameraTag = gui.TextManager:GetText("ui_camera_name")
  local strtemp = nx_widestr(cameraTag) .. nx_widestr(pointorder)
  dialog.camera_name = strtemp
  dialog.edit_camera = obj_camera
  dialog.pos_x = form.pos_x
  dialog.pos_y = form.pos_y
  dialog.pos_z = form.pos_z
  dialog.angle_x = form.angle_x
  dialog.angle_y = form.angle_y
  dialog.angle_z = form.angle_z
  dialog.move_mode = form.move_mode
  dialog:Show()
  local res = nx_wait_event(100000000, dialog, "camera_point_edit_return")
  if not nx_is_valid(form) then
    return
  end
  if res == "save" then
    local str_point_info = "stop," .. form.pos_x .. "," .. form.pos_y .. "," .. form.pos_z .. "," .. form.angle_x .. "," .. form.angle_y .. "," .. form.angle_z .. "," .. form.move_mode .. ","
    array_points_string[pointorder][1] = str_point_info
    refresh_pointinfo(form, 1, colindex)
  elseif res == "cancel" then
    relocate_obj(obj_camera, form.pos_x, form.pos_y, form.pos_z)
    reangle_obj(obj_camera, form.angle_x, form.angle_y, form.angle_z)
  end
  set_camera_mode(form, false)
  form.Visible = true
  delete_camera_in_scene()
  if form.IsShowCamera then
    create_camera_in_scene()
  end
end
function on_btn_copy_point_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local rowindex = textgrid.RowSelectIndex
  if 1 < rowindex then
    return
  end
  if array_camera_points[colindex + 1] == nil then
    return
  end
  if not is_edit_point(colindex) then
    return
  end
  local pointorder = array_camera_points[colindex + 1] - 10000
  form.pointClipboard = array_points_string[pointorder][1]
  form.btn_paste_point.Enabled = true
  form.menu_operation:GetItem(MENUPASTE).Disable = false
  refresh_pointinfo(form, 1, colindex)
end
function on_btn_cut_point_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local rowindex = textgrid.RowSelectIndex
  if 1 < rowindex then
    return
  end
  if array_camera_points[colindex + 1] == nil then
    return
  end
  if not is_edit_point(colindex) then
    return
  end
  local pointorder = array_camera_points[colindex + 1] - 10000
  form.pointClipboard = array_points_string[pointorder][1]
  on_btn_delete_point_click(btn)
  form.btn_cut_point.Enabled = false
  form.btn_copy_point.Enabled = false
  form.btn_paste_point.Enabled = true
  form.menu_operation:GetItem(MENUCUT).Disable = true
  form.menu_operation:GetItem(MENUCOPY).Disable = true
  form.menu_operation:GetItem(MENUPASTE).Disable = false
  refresh_pointinfo(form, 1, colindex)
end
function on_btn_paste_point_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local rowindex = textgrid.RowSelectIndex
  if 1 < rowindex then
    return
  end
  if not form.pointClipboard then
    return
  end
  if is_edit_point(colindex) then
    local pointorder = array_camera_points[colindex + 1] - 10000
    array_points_string[pointorder][1] = form.pointClipboard
    delete_camera_in_scene()
    if form.IsShowCamera then
      create_camera_in_scene()
    end
  else
    add_point(form, form.pointClipboard)
  end
  refresh_pointinfo(form, 1, colindex)
end
function on_btn_save_file_click(btn)
  local form = btn.ParentForm
  local dialog = nx_execute("form_common\\form_save_file", "util_save_file", "*.9ycs")
  local res, filepath, file = nx_wait_event(100000000, dialog, "save_file_return")
  if not nx_is_valid(form) then
    return
  end
  if res == "ok" then
    rewrite_to_ini(form)
    form.ini.FileName = filepath
    form.ini:SaveToFile()
  end
  form.play_time = 0
end
function on_stop_scenario()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera", false, false)
  if not nx_is_valid(form) then
    return
  end
  restore_scene_weather()
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_callback", form)
  end
  form.play_time = 0
end
function on_rbtn_point_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.angleType = 4
  end
end
function on_rbtn_move_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.angleType = 1
  end
end
function on_rbtn_player_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.angleType = 2
  end
end
function on_rbtn_free_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.angleType = 5
  end
end
function on_combobox_weather_selected(boxitem)
  local form = boxitem.ParentForm
  form.selected_weather = form.combobox_weather.DropListBox.SelectIndex
end
function set_temp_weather(form)
  form.weather_ini:LoadFromFile()
  if form.selected_weather == 0 then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local scene_sky = scene.sky
  if not nx_is_valid(scene_sky) then
    return
  end
  local scene_sun = scene.sun
  if not nx_is_valid(scene_sun) then
    return
  end
  local scene_weather = scene.Weather
  if not nx_is_valid(scene_weather) then
    return
  end
  local weather_section = weather_table[form.selected_weather]
  local temp_string = ""
  local temp_float = -1
  temp_string = form.weather_ini:ReadString(weather_section, "sky_up_tex", "null")
  if temp_string == "null" then
    scene_sky.UpTex = scene_sky_UpTex
  else
    scene_sky.UpTex = temp_string
  end
  temp_string = form.weather_ini:ReadString(weather_section, "sky_side_tex", "null")
  if temp_string == "null" then
    scene_sky.SideTex = scene_sky_SideTex
  else
    scene_sky.SideTex = temp_string
  end
  temp_string = form.weather_ini:ReadString(weather_section, "sun_glow_tex", "null")
  if temp_string == "null" then
    scene_sun.GlowTex = scene_sun_GlowTex
  else
    scene_sun.GlowTex = temp_string
  end
  temp_string = form.weather_ini:ReadString(weather_section, "sun_flare_tex", "null")
  if temp_string == "null" then
    scene_sun.FlareTex = scene_sun_FlareTex
  else
    scene_sun.FlareTex = temp_string
  end
  temp_string = form.weather_ini:ReadString(weather_section, "sun_glow_visible", "unknow")
  if temp_string == "unknow" then
    scene_sun.ShowGlow = scene_sun_ShowGlow
  elseif temp_string == "true" then
    scene_sun.ShowGlow = true
  else
    scene_sun.ShowGlow = false
  end
  temp_string = form.weather_ini:ReadString(weather_section, "sun_flare_visible", "unknow")
  if temp_string == "unknow" then
    scene_sun.ShowFlare = scene_sun_ShowFlare
  elseif temp_string == "true" then
    scene_sun.ShowFlare = true
  else
    scene_sun.ShowFlare = false
  end
  temp_string = form.weather_ini:ReadString(weather_section, "sun_color", "null")
  if temp_string == "null" then
    scene_weather.SunGlowColor = scene_weather_sun_color
  else
    scene_weather.SunGlowColor = temp_string
  end
  temp_string = form.weather_ini:ReadString(weather_section, "ambient_color", "null")
  if temp_string == "null" then
    scene_weather.AmbientColor = scene_weather_ambient_color
  else
    scene_weather.AmbientColor = temp_string
  end
  scene_sky:UpdateTexture()
  scene_sun:UpdateTexture()
  count_sun_start_azimuth_angle = form.weather_ini:ReadFloat(weather_section, "sun_start_azimuth_angle", -1)
  count_sun_start_height_angle = form.weather_ini:ReadFloat(weather_section, "sun_start_height_angle", -1)
  count_wind_start_speed = form.weather_ini:ReadFloat(weather_section, "wind_start_speed", -1)
  count_wind_start_angle = form.weather_ini:ReadFloat(weather_section, "wind_start_angle", -1)
  count_sun_end_azimuth_angle = form.weather_ini:ReadFloat(weather_section, "sun_end_azimuth_angle", -1)
  count_sun_end_height_angle = form.weather_ini:ReadFloat(weather_section, "sun_end_height_angle", -1)
  count_wind_end_speed = form.weather_ini:ReadFloat(weather_section, "wind_end_speed", -1)
  count_wind_end_angle = form.weather_ini:ReadFloat(weather_section, "wind_end_angle", -1)
  count_sky_start_YawSpeed = form.weather_ini:ReadFloat(weather_section, "sky_start_speed", -1)
  count_sky_end_YawSpeed = form.weather_ini:ReadFloat(weather_section, "sky_end_speed", -1)
  count_sun_start_GlowSize = form.weather_ini:ReadFloat(weather_section, "sun_start_glow_size", -1)
  count_sun_end_GlowSize = form.weather_ini:ReadFloat(weather_section, "sun_end_glow_size", -1)
  count_sun_start_FlareSize = form.weather_ini:ReadFloat(weather_section, "sun_start_flare_size", -1)
  count_sun_end_FlareSize = form.weather_ini:ReadFloat(weather_section, "sun_end_flare_size", -1)
  count_sun_start_GlowDistance = form.weather_ini:ReadFloat(weather_section, "sun_start_glow_distance", -1)
  count_sun_end_GlowDistance = form.weather_ini:ReadFloat(weather_section, "sun_end_glow_distance", -1)
  count_sun_start_FlareDistance = form.weather_ini:ReadFloat(weather_section, "sun_start_flare_distance", -1)
  count_sun_end_FlareDistance = form.weather_ini:ReadFloat(weather_section, "sun_end_flare_distance", -1)
  count_weather_sun_start_intensity = form.weather_ini:ReadFloat(weather_section, "sun_start_intensity", -1)
  count_weather_sun_end_intensity = form.weather_ini:ReadFloat(weather_section, "sun_end_intensity", -1)
  count_weather_ambient_start_intensity = form.weather_ini:ReadFloat(weather_section, "ambient_start_intensity", -1)
  count_weather_ambient_end_intensity = form.weather_ini:ReadFloat(weather_section, "ambient_end_intensity", -1)
  local is_movable = form.weather_ini:ReadString(weather_section, "is_movable", "false")
  if is_movable == "true" then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:Register(100, -1, nx_current(), "timer_callback", form, 0, 0)
      segment_flag = 0
    end
  else
    if count_sun_start_azimuth_angle < 0 or count_sun_start_height_angle < 0 then
      scene_weather.SunDirection = scene_weather_sun_direction
    else
      scene_weather:MakeSunDirection(count_sun_start_height_angle / 180 * math.pi, count_sun_start_azimuth_angle / 180 * math.pi)
    end
    if count_wind_start_speed < 0 then
      scene_weather.WindSpeed = scene_weather_wind_speed
    else
      scene_weather.WindSpeed = count_wind_start_speed
    end
    if count_wind_start_angle < 0 then
      scene_weather.WindAngle = scene_weather_wind_angle
    else
      scene_weather.WindAngle = count_wind_start_angle
    end
    if count_sky_start_YawSpeed < 0 then
      scene_sky.YawSpeed = scene_sky_YawSpeed
    else
      scene_sky.YawSpeed = count_sky_start_YawSpeed
    end
    if count_sun_start_GlowSize < 0 then
      scene_sun.GlowSize = scene_sun_GlowSize
    else
      scene_sun.GlowSize = count_sun_start_GlowSize
    end
    if count_sun_start_FlareSize < 0 then
      scene_sun.FlareSize = scene_sun_FlareSize
    else
      scene_sun.FlareSize = count_sun_start_FlareSize
    end
    if count_sun_start_GlowDistance < 0 then
      scene_sun.GlowDistance = scene_sun_GlowDistance
    else
      scene_sun.GlowDistance = count_sun_start_GlowDistance
    end
    if count_sun_end_FlareDistance < 0 then
      scene_sun.FlareDistance = scene_sun_FlareDistance
    else
      scene_sun.FlareDistance = count_sun_end_FlareDistance
    end
    if count_weather_sun_start_intensity < 0 then
      scene_weather.SunIntensity = scene_weather_sun_intensity
    else
      scene_weather.SunIntensity = count_weather_sun_start_intensity
    end
    if count_weather_ambient_start_intensity < 0 then
      scene_weather.AmbientIntensity = scene_weather_ambient_intensity
    else
      scene_weather.AmbientIntensity = count_weather_ambient_start_intensity
    end
  end
end
function restore_scene_weather()
  local form = nx_value("form_stage_main\\form_camera\\form_save_camera")
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local scene_sky = scene.sky
  if not nx_is_valid(scene_sky) then
    return
  end
  local scene_sun = scene.sun
  if not nx_is_valid(scene_sun) then
    return
  end
  local scene_weather = scene.Weather
  if not nx_is_valid(scene_weather) then
    return
  end
  scene_sky.UpTex = scene_sky_UpTex
  scene_sky.SideTex = scene_sky_SideTex
  scene_sky.YawSpeed = scene_sky_YawSpeed
  scene_sun.GlowTex = scene_sun_GlowTex
  scene_sun.FlareTex = scene_sun_FlareTex
  scene_sun.ShowGlow = scene_sun_ShowGlow
  scene_sun.ShowFlare = scene_sun_ShowFlare
  scene_sun.GlowSize = scene_sun_GlowSize
  scene_sun.FlareSize = scene_sun_FlareSize
  scene_sun.GlowDistance = scene_sun_GlowDistance
  scene_sun.FlareDistance = scene_sun_FlareDistance
  scene_weather.SunGlowColor = scene_weather_sun_color
  scene_weather.SunGlowIntensity = scene_weather_sun_intensity
  scene_weather.AmbientColor = scene_weather_ambient_color
  scene_weather.AmbientIntensity = scene_weather_ambient_intensity
  scene_weather.SpecularColo = scene_weatherr_specular_color
  scene_weather.WindSpeed = scene_weather_wind_speed
  scene_weather.WindAngle = scene_weather_wind_angle
  scene_weather.SunDirection = scene_weather_sun_direction
  scene_sky:UpdateTexture()
  scene_sun:UpdateTexture()
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_callback", form)
    segment_flag = 0
  end
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  local camera_time = table.getn(array_camera_points)
  form.play_time = camera_time
  set_temp_weather(form)
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  local camera_time = table.getn(array_camera_points)
  form.play_time = 0
  restore_scene_weather(form)
end
function timer_callback(form, para1, para2)
  if 0 == form.play_time then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timer_callback", form)
      return
    end
  end
  if form.Ispause then
    return
  end
  if segment_flag > form.play_time * 10 then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timer_callback", form)
      segment_flag = 0
    end
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local scene_weather = scene.Weather
  if not nx_is_valid(scene_weather) then
    return
  end
  local scene_sky = scene.sky
  if not nx_is_valid(scene_sky) then
    return
  end
  local scene_sun = scene.sun
  if not nx_is_valid(scene_sun) then
    return
  end
  local segment_counts = form.play_time * 10
  if 0 <= count_sun_start_azimuth_angle and 0 <= count_sun_end_azimuth_angle and 0 <= count_sun_start_height_angle and 0 <= count_sun_end_height_angle then
    local height_angle = count_sun_start_height_angle + segment_flag * (count_sun_end_height_angle - count_sun_start_height_angle) / segment_counts
    local azimuth_angle = count_sun_start_azimuth_angle + segment_flag * (count_sun_end_azimuth_angle - count_sun_start_azimuth_angle) / segment_counts
    scene_weather:MakeSunDirection(height_angle / 180 * math.pi, azimuth_angle / 180 * math.pi)
  end
  if 0 <= count_wind_start_speed and 0 <= count_wind_end_speed then
    local wind_speed = count_wind_start_speed + segment_flag * (count_wind_end_speed - count_wind_start_speed) / segment_counts
    scene_weather.WindSpeed = wind_speed
  end
  if 0 <= count_wind_start_angle and 0 <= count_wind_end_angle then
    local wind_angle = count_wind_start_angle + segment_flag * (count_wind_end_angle - count_wind_start_angle) / segment_counts
    scene_weather.WindAngle = wind_angle
  end
  if 0 <= count_sky_start_YawSpeed and 0 <= count_sky_end_YawSpeed then
    local sky_YawSpeed = count_sky_start_YawSpeed + segment_flag * (count_sky_end_YawSpeed - count_sky_start_YawSpeed) / segment_counts
    scene_sky.YawSpeed = sky_YawSpeed
  end
  if 0 <= count_sun_start_GlowSize and 0 <= count_sun_end_GlowSize then
    local sun_GlowSize = count_sun_start_GlowSize + segment_flag * (count_sun_end_GlowSize - count_sun_start_GlowSize) / segment_counts
    scene_sun.GlowSize = sun_GlowSize
  end
  if 0 <= count_sun_start_FlareSize and 0 <= count_sun_end_FlareSize then
    local sun_FlareSize = count_sun_start_FlareSize + segment_flag * (count_sun_end_FlareSize - count_sun_start_FlareSize) / segment_counts
    scene_sun.FlareSize = sun_FlareSize
  end
  if 0 <= count_sun_start_GlowDistance and 0 <= count_sun_end_GlowDistance then
    local sun_GlowDistance = count_sun_start_GlowDistance + segment_flag * (count_sun_end_GlowDistance - count_sun_start_GlowDistance) / segment_counts
    scene_sun.GlowDistance = sun_GlowDistance
  end
  if 0 <= count_sun_start_FlareDistance and 0 <= count_sun_end_FlareDistance then
    local sun_FlareDistance = count_sun_start_FlareDistance + segment_flag * (count_sun_end_FlareDistance - count_sun_start_FlareDistance) / segment_counts
    scene_sun.FlareDistance = sun_FlareDistance
  end
  if 0 <= count_weather_sun_start_intensity and 0 <= count_weather_sun_end_intensity then
    local weather_sun_intensity = count_weather_sun_start_intensity + segment_flag * (count_weather_sun_end_intensity - count_weather_sun_start_intensity) / segment_counts
    scene_weather.SunIntensity = weather_sun_intensity
  end
  if 0 <= count_weather_ambient_start_intensity and 0 <= count_weather_ambient_end_intensity then
    local weather_ambient_intensity = count_weather_ambient_start_intensity + segment_flag * (count_weather_ambient_end_intensity - count_weather_ambient_start_intensity) / segment_counts
    scene_weather.AmbientIntensity = weather_ambient_intensity
  end
  segment_flag = segment_flag + 1
end
function on_btn_add_subtitle_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local rowindex = textgrid.RowSelectIndex
  if rowindex ~= 0 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera_input_subtitle", true, false)
  dialog:Show()
  local res = nx_wait_event(100000000, dialog, "camera_subtitle_edit_return")
  if not nx_is_valid(form) then
    return
  end
  if res == "ok" then
    local flag = 1
    for i = 1, MAXPOINTCOUNT do
      if array_subtitle[i] == nil then
        break
      end
      local string_table = util_split_string(array_subtitle[i][1], ",")
      local count = table.maxn(string_table)
      if count < 3 then
        break
      end
      local begin_time = nx_number(string_table[1])
      local duration = nx_number(string_table[2])
      if begin_time == colindex then
        table.remove(array_subtitle, i)
        break
      end
      if colindex < begin_time then
        break
      end
      flag = flag + 1
    end
    table.insert(array_subtitle, flag, {
      colindex .. "," .. form.subtitle_duration .. "," .. form.subtitle_toporbottom,
      form.subtitle_content
    })
    refresh_grid(form.textgrid_timeaction, 0)
  end
  refresh_btn_subtitle(form, rowindex, colindex)
end
function on_btn_del_subtitle_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local rowindex = textgrid.RowSelectIndex
  if rowindex ~= 0 then
    return
  end
  for i = 1, MAXPOINTCOUNT do
    if array_subtitle[i] == nil then
      break
    end
    local string_table = util_split_string(array_subtitle[i][1], ",")
    local count = table.maxn(string_table)
    if count < 3 then
      break
    end
    local begin_time = nx_number(string_table[1])
    if begin_time == colindex then
      table.remove(array_subtitle, i)
      break
    end
  end
  refresh_grid(form.textgrid_timeaction, 0)
  refresh_btn_subtitle(form, rowindex, colindex)
end
function on_btn_edit_subtitle_click(btn)
  local form = btn.ParentForm
  local begin_time = form.textgrid_timeaction.ColSelectIndex
  local index = 0
  for i = 1, MAXPOINTCOUNT do
    if array_subtitle[i] == nil then
      break
    end
    local string_table = util_split_string(array_subtitle[i][1], ",")
    local count = table.maxn(string_table)
    if count < 3 then
      break
    end
    local begin_time = nx_number(string_table[1])
    if begin_time == form.textgrid_timeaction.ColSelectIndex then
      local string_table = util_split_string(array_subtitle[i][1], ",")
      local count = table.maxn(string_table)
      if count < 3 then
        break
      end
      local duration = nx_number(string_table[2])
      local toporbottom = nx_number(string_table[3])
      form.subtitle_duration = duration
      form.subtitle_toporbottom = toporbottom
      form.subtitle_content = array_subtitle[i][2]
      index = i
      break
    end
  end
  if index ~= 0 then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera_input_subtitle", true, false)
    dialog.ipt_subtitle.Text = nx_widestr(form.subtitle_content)
    dialog.ipt_duration.Text = nx_widestr(form.subtitle_duration)
    if 1 == form.subtitle_toporbottom then
      dialog.rbtn_top.Checked = true
    else
      dialog.rbtn_bottom.Checked = true
    end
    dialog:Show()
    local res = nx_wait_event(100000000, dialog, "camera_subtitle_edit_return")
    if not nx_is_valid(form) then
      return
    end
    if res == "ok" then
      local str_time = begin_time .. "," .. form.subtitle_duration .. "," .. form.subtitle_toporbottom
      array_subtitle[index] = {
        str_time,
        form.subtitle_content
      }
      refresh_grid(form.textgrid_timeaction, 0)
    else
    end
  end
end
function on_btn_cut_subtitle_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local rowindex = textgrid.RowSelectIndex
  if rowindex ~= 0 then
    return
  end
  for i = 1, MAXPOINTCOUNT do
    if array_subtitle[i] == nil then
      break
    end
    local string_table = util_split_string(array_subtitle[i][1], ",")
    local count = table.maxn(string_table)
    if count < 3 then
      break
    end
    local begin_time = nx_number(string_table[1])
    if begin_time == colindex then
      form.subtitleClipboard1 = array_subtitle[i][1]
      form.subtitleClipboard2 = array_subtitle[i][2]
      table.remove(array_subtitle, i)
      break
    end
  end
  refresh_grid(form.textgrid_timeaction, 0)
  refresh_btn_subtitle(form, rowindex, colindex)
end
function on_btn_copy_subtitle_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local rowindex = textgrid.RowSelectIndex
  if rowindex ~= 0 then
    return
  end
  for i = 1, MAXPOINTCOUNT do
    if array_subtitle[i] == nil then
      break
    end
    local string_table = util_split_string(array_subtitle[i][1], ",")
    local count = table.maxn(string_table)
    if count < 3 then
      break
    end
    local begin_time = nx_number(string_table[1])
    if begin_time == colindex then
      form.subtitleClipboard1 = array_subtitle[i][1]
      form.subtitleClipboard2 = array_subtitle[i][2]
      break
    end
  end
  refresh_btn_subtitle(form, rowindex, colindex)
end
function on_btn_paste_subtitle_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_timeaction
  local colindex = textgrid.ColSelectIndex
  local rowindex = textgrid.RowSelectIndex
  if rowindex ~= 0 then
    return
  end
  if not form.subtitleClipboard1 then
    return
  end
  local flag = 1
  for i = 1, MAXPOINTCOUNT do
    if array_subtitle[i] == nil then
      break
    end
    local string_table = util_split_string(array_subtitle[i][1], ",")
    local count = table.maxn(string_table)
    if count < 3 then
      break
    end
    local begin_time = nx_number(string_table[1])
    if begin_time == colindex then
      table.remove(array_subtitle, i)
      break
    end
    if colindex < begin_time then
      break
    end
    flag = flag + 1
  end
  local string_table_recop = util_split_string(form.subtitleClipboard1, ",")
  local duration_time_recop = string_table_recop[2]
  local is_top_recop = string_table_recop[3]
  table.insert(array_subtitle, flag, {
    colindex .. "," .. duration_time_recop .. "," .. is_top_recop,
    form.subtitleClipboard2
  })
  refresh_grid(form.textgrid_timeaction, 0)
  refresh_btn_subtitle(form, rowindex, colindex)
end
function on_cbtn_show_subtitle_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.IsShowSubtitle = true
  else
    form.IsShowSubtitle = false
  end
end
function refresh_btn_subtitle(form, row, col)
  if row ~= 0 then
    form.btn_add_subtitle.Enabled = false
    form.btn_del_subtitle.Enabled = false
    form.btn_edit_subtitle.Enabled = false
    form.btn_cut_subtitle.Enabled = false
    form.btn_copy_subtitle.Enabled = false
    form.btn_paste_subtitle.Enabled = false
    form.menu_operation:GetItem(MENUCUT).Disable = true
    form.menu_operation:GetItem(MENUCOPY).Disable = true
    form.menu_operation:GetItem(MENUDELETE).Disable = true
    form.menu_operation:GetItem(MENUPASTE).Disable = true
    form.btn_add_point.Enabled = false
    form.btn_edit_point.Enabled = false
    return
  end
  if col < 0 or col >= MAXPOINTCOUNT then
    form.btn_add_subtitle.Enabled = false
    form.btn_del_subtitle.Enabled = false
    form.btn_edit_subtitle.Enabled = false
    form.btn_cut_subtitle.Enabled = false
    form.btn_copy_subtitle.Enabled = false
    form.btn_paste_subtitle.Enabled = false
    form.menu_operation:GetItem(MENUCUT).Disable = true
    form.menu_operation:GetItem(MENUCOPY).Disable = true
    form.menu_operation:GetItem(MENUDELETE).Disable = true
    form.menu_operation:GetItem(MENUPASTE).Disable = true
    form.btn_add_point.Enabled = false
    form.btn_edit_point.Enabled = false
    return
  end
  local index = 0
  for i = 1, MAXPOINTCOUNT do
    if array_subtitle[i] == nil then
      break
    end
    local string_table = util_split_string(array_subtitle[i][1], ",")
    local count = table.maxn(string_table)
    if count < 3 then
      break
    end
    local begin_time = nx_number(string_table[1])
    if begin_time == form.textgrid_timeaction.ColSelectIndex then
      index = i
      break
    end
  end
  if index ~= 0 then
    form.btn_add_subtitle.Enabled = false
    form.btn_del_subtitle.Enabled = true
    form.btn_edit_subtitle.Enabled = true
    form.btn_cut_subtitle.Enabled = true
    form.btn_copy_subtitle.Enabled = true
    form.menu_operation:GetItem(MENUCUT).Disable = false
    form.menu_operation:GetItem(MENUCOPY).Disable = false
    form.menu_operation:GetItem(MENUDELETE).Disable = false
    form.btn_add_point.Enabled = false
    form.btn_edit_point.Enabled = true
  else
    form.btn_add_subtitle.Enabled = true
    form.btn_del_subtitle.Enabled = false
    form.btn_edit_subtitle.Enabled = false
    form.btn_cut_subtitle.Enabled = false
    form.btn_copy_subtitle.Enabled = false
    form.menu_operation:GetItem(MENUCUT).Disable = true
    form.menu_operation:GetItem(MENUCOPY).Disable = true
    form.menu_operation:GetItem(MENUDELETE).Disable = true
    form.btn_add_point.Enabled = true
    form.btn_edit_point.Enabled = false
  end
  if form.subtitleClipboard1 then
    form.btn_paste_subtitle.Enabled = true
    form.menu_operation:GetItem(MENUPASTE).Disable = false
  else
    form.btn_paste_subtitle.Enabled = false
    form.menu_operation:GetItem(MENUPASTE).Disable = true
  end
end
function on_textgrid_timeaction_right_select_grid(grid, row, col)
  grid:SelectGrid(row, col)
  local form = grid.ParentForm
  local menu = form.menu_operation
  menu.Visible = true
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local mouse_x, mouse_y = gui:GetCursorPosition()
  menu.Left = mouse_x - form.Left
  menu.Top = mouse_y - form.Top - 64
end
function init_operation_menu(form)
  local menu = form.menu_operation
  menu:CreateItem("ope_cut", nx_widestr(util_text("ui_cut")))
  menu:CreateItem("ope_copy", nx_widestr(util_text("ui_copy")))
  menu:CreateItem("ope_delete", nx_widestr(util_text("ui_Delete")))
  menu:CreateItem("ope_paste", nx_widestr(util_text("ui_paste")))
  menu.LeftBar = false
  menu.Visible = false
  nx_callback(menu, "on_ope_cut_click", "on_menu_cut_click")
  nx_callback(menu, "on_ope_copy_click", "on_menu_copy_click")
  nx_callback(menu, "on_ope_delete_click", "on_menu_delete_click")
  nx_callback(menu, "on_ope_paste_click", "on_menu_paste_click")
end
function init_file_menu(form)
  local menu = form.menu_file
  menu:CreateItem("ope_openfile", nx_widestr(util_text("ui_open")))
  menu:CreateItem("ope_savefile", nx_widestr(util_text("ui_save")))
  menu.LeftBar = false
  menu.Visible = false
  nx_callback(menu, "on_ope_openfile_click", "on_btn_open_file_click")
  nx_callback(menu, "on_ope_savefile_click", "on_btn_save_file_click")
end
function on_menu_operation_lost_capture(menu)
  menu.Visible = false
end
function on_menu_file_lost_capture(menu)
  menu.Visible = false
end
function on_menu_cut_click(menu_item)
  local form = menu_item.ParentForm
  local textgrid = form.textgrid_timeaction
  local rowindex = textgrid.RowSelectIndex
  if 0 == rowindex then
    on_btn_cut_subtitle_click(menu_item)
  elseif 1 == rowindex then
    on_btn_cut_point_click(menu_item)
  end
  form.menu_operation.Visible = false
end
function on_menu_copy_click(menu_item)
  local form = menu_item.ParentForm
  local textgrid = form.textgrid_timeaction
  local rowindex = textgrid.RowSelectIndex
  if 0 == rowindex then
    on_btn_copy_subtitle_click(menu_item)
  elseif 1 == rowindex then
    on_btn_copy_point_click(menu_item)
  end
  form.menu_operation.Visible = false
end
function on_menu_delete_click(menu_item)
  local form = menu_item.ParentForm
  local textgrid = form.textgrid_timeaction
  local rowindex = textgrid.RowSelectIndex
  if 0 == rowindex then
    on_btn_del_subtitle_click(menu_item)
  elseif 1 == rowindex then
    on_btn_delete_point_click(menu_item)
  end
  form.menu_operation.Visible = false
end
function on_menu_paste_click(menu_item)
  local form = menu_item.ParentForm
  local textgrid = form.textgrid_timeaction
  local rowindex = textgrid.RowSelectIndex
  if 0 == rowindex then
    on_btn_paste_subtitle_click(menu_item)
  elseif 1 == rowindex then
    on_btn_paste_point_click(menu_item)
  end
  form.menu_operation.Visible = false
end
function on_btn_set_click(btn)
  local form = btn.ParentForm
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera_setting", true, false)
  dialog.angleType = form.angleType
  dialog.is_show_subtitle = form.IsShowSubtitle
  dialog.is_show_camera = form.IsShowCamera
  dialog.selected_weather = form.selected_weather
  dialog:Show()
  local res = nx_wait_event(100000000, dialog, "camera_setting_return")
  if not nx_is_valid(form) then
    return
  end
  if res == "ok" then
    if form.IsShowCamera then
      create_camera_in_scene()
    else
      delete_camera_in_scene()
    end
  end
end
function on_btn_file_click(btn)
  local form = btn.ParentForm
  form.menu_file.Visible = true
end
function on_btn_video_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_movie_save", true, false)
  dialog:ShowModal()
end
function on_btn_3_click(btn)
  local form = btn.ParentForm
  local ini = nx_create("IniDocument")
  local scenename = form.scene_name
  ini:AddSection(scenename)
  ini:WriteString(scenename, "name", scenename)
  ini:WriteString(scenename, "sky_up_tex", scene_sky_UpTex)
  ini:WriteString(scenename, "sky_side_tex", scene_sky_SideTex)
  ini:WriteString(scenename, "sun_glow_tex", scene_sun_GlowTex)
  ini:WriteString(scenename, "sun_flare_tex", scene_sun_FlareTex)
  ini:WriteString(scenename, "sun_color", scene_weather_sun_color)
  ini:WriteString(scenename, "ambient_color", scene_weather_ambient_color)
  ini:WriteString(scenename, "specular_color", scene_weather_specular_color)
  ini:WriteFloat(scenename, "sun_start_glow_size", scene_sun_GlowSize)
  ini:WriteFloat(scenename, "sun_start_glow_distance", scene_sun_GlowDistance)
  ini:WriteFloat(scenename, "sun_start_flare_size", scene_sun_FlareSize)
  ini:WriteFloat(scenename, "sun_start_flare_distance", scene_sun_FlareDistance)
  ini:WriteFloat(scenename, "sun_start_intensity", scene_weather_sun_intensity)
  ini:WriteFloat(scenename, "ambient_start_intensity", scene_weather_ambient_intensity)
  ini:WriteFloat(scenename, "sky_start_speed", scene_sky_YawSpeed)
  ini:WriteString(scenename, "sun_start_direction", scene_weather_sun_direction)
  if scene_sun_ShowGlow then
    ini:WriteString(scenename, "sun_glow_visible", "true")
  else
    ini:WriteString(scenename, "sun_glow_visible", "false")
  end
  if scene_sun_ShowFlare then
    ini:WriteString(scenename, "sun_flare_visible", "true")
  else
    ini:WriteString(scenename, "sun_flare_visible", "false")
  end
  ini:WriteFloat(scenename, "wind_start_speed", scene_weather_wind_speed)
  ini:WriteFloat(scenename, "wind_start_angle", scene_weather_wind_angle)
  ini.FileName = nx_resource_path() .. "ini\\Scenario\\weather\\" .. scenename .. ".ini"
  ini:SaveToFile()
end
function exit_play_camera()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_save_camera", false, false)
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_value("form_stage_main\\form_camera\\form_save_camera_edit_point")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
  set_camera_mode(form, false)
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_npc_manager) then
    scenario_npc_manager:StopCameraPath()
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_callback", form)
  end
  form.play_time = 0
  form:Close()
end
