CONTROLLER_TYPE_POS_X = 0
CONTROLLER_TYPE_POS_Y = 1
CONTROLLER_TYPE_POS_Z = 2
CONTROLLER_TYPE_ANGLE_X = 3
CONTROLLER_TYPE_ANGLE_Y = 4
CONTROLLER_TYPE_ANGLE_Z = 5
CONTROLLER_TYPE_FOV_X = 6
CONTROLLER_TYPE_FOV_Y = 7
CONTROLLER_TYPE_LIGHTNING_KEY = 8
CONTROLLER_TYPE_ACTION = 9
CONTROLLER_TYPE_SKY_ANGLE_Y = 10
CONTROLLER_TYPE_ACTION_KEY = 11
CONTROLLER_TYPE_AMBIENT_INTENSITY = 12
CONTROLLER_TYPE_SUNGLOW_INTENSITY = 13
CONTROLLER_TYPE_SPECULAR_INTENSITY = 14
CONTROLLER_TYPE_SUNHEIGHT = 15
CONTROLLER_TYPE_SUNAZIMUTH = 16
CONTROLLER_TYPE_FOCUSDEPTH = 17
CONTROLLER_TYPE_BLURVALUE = 18
CONTROLLER_TYPE_MAXOFBLUR = 19
CONTROLLER_TYPE_START_DEPTH = 20
CONTROLLER_TYPE_END_DEPTH = 21
CONTROLLER_TYPE_VISIBLE = 22
CONTROLLER_TYPE_BIND_OBJECT = 23
CONTROLLER_TYPE_WIND_SPEED = 24
CONTROLLER_TYPE_WIND_ANGLE = 25
CONTROLLER_TYPE_LIGHT_INTENSITY = 26
CONTROLLER_TYPE_FOG_DENSITY = 27
CONTROLLER_TYPE_FOG_START = 28
CONTROLLER_TYPE_FOG_END = 29
CONTROLLER_TYPE_FOG_HEIGHT = 30
CONTROLLER_TYPE_SKY_TEXTURE = 31
CONTROLLER_TYPE_COLOR_A = 32
CONTROLLER_TYPE_COLOR_R = 33
CONTROLLER_TYPE_COLOR_G = 34
CONTROLLER_TYPE_COLOR_B = 35
CONTROLLER_TYPE_SCALE_X = 36
CONTROLLER_TYPE_SCALE_Y = 37
CONTROLLER_TYPE_SCALE_Z = 38
CONTROLLER_TYPE_LIGHT_RANGE = 39
CONTROLLER_TYPE_SOUND = 40
CONTROLLER_TYPE_FOCUS_OBJECT = 41
CONTROLLER_TYPE_CUSTOM = 42
CONTROLLER_TYPE_ALPHA = 43
CONTROLLER_TYPE_ALPHA_PPFILTER = 44
CONTROLLER_TYPE_MUSIC = 46
CONTROLLER_TYPE_WOBBLE_X = 50
CONTROLLER_TYPE_WOBBLE_Y = 51
CONTROLLER_TYPE_WOBBLE_Z = 52
CONTROLLER_TYPE_WOBBLE_F = 53
CONTROLLER_TYPE_POSITION_ANGLE = 100
function get_game_camera()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return nx_null()
  end
  return game_control.Camera
end
function get_game_terrain()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return nx_null()
  end
  return scene.terrain
end
function set_camera_distance(distance)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return false
  end
  game_control.Distance = nx_float(distance)
  return true
end
function set_camera_mode()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return false
  end
  game_control.CameraMode = 1
  game_control.CameraMode = 0
  return true
end
function set_camera_control(control)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return false
  end
  game_control.AllowControl = control
  return true
end
local to_degree = function(value)
  return value * 180 / math.pi
end
local to_radian = function(value)
  return value * math.pi / 180
end
function set_first_person_camera(camera_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return false
  end
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    return false
  end
  local movie_objects = nx_value("movie_objects")
  if not nx_is_valid(movie_objects) then
    return false
  end
  local camera = get_game_camera()
  if not nx_is_valid(camera) then
    return false
  end
  local child = movie_objects:GetChild(camera_id)
  if not nx_is_valid(child) then
    return false
  end
  if movie_objects.first_person_camera_id == "" then
    local scene = nx_value("game_scene")
    if not nx_is_valid(scene) then
      return false
    end
    local game_control = scene.game_control
    if not nx_is_valid(game_control) then
      return false
    end
    local normal_camera = game_control:GetCameraController(0)
    normal_camera:RecordCameraFov()
  else
    local child_old = movie_objects:GetChild(movie_objects.first_person_camera_id)
    if nx_is_valid(child_old) then
      local camera_wrapper_old = child_old.visual
      if nx_find_custom(camera_wrapper_old, "third_camera") and nx_is_valid(camera_wrapper_old.third_camera) then
        camera_wrapper_old.Camera = camera_wrapper_old.third_camera
        camera_wrapper_old.third_camera = nil
      end
      terrain:RelocateVisual(camera_wrapper_old.Camera, camera.PositionX, camera.PositionY, camera.PositionZ)
      camera_wrapper_old.Camera:SetAngle(camera.AngleX, camera.AngleY, camera.AngleZ)
    end
  end
  camera:SetPosition(child.visual.PositionX, child.visual.PositionY, child.visual.PositionZ)
  camera:SetAngle(child.visual.AngleX, child.visual.AngleY, child.visual.AngleZ)
  local object_list = movie_objects:GetChildList()
  for _, child_object in pairs(object_list) do
    if nx_is_valid(child_object) then
      child_object.visual.Visible = false
      time_axis:SetPathVisible(child_object.Name, false)
    end
  end
  local camera_wrapper = child.visual
  camera_wrapper.Visible = true
  time_axis:SetPathVisible(camera_id, false)
  camera_wrapper.PyramidVisible = false
  camera_wrapper.third_camera = camera_wrapper.Camera
  camera_wrapper.Camera = camera
  movie_objects.first_person_camera_id = camera_id
  camera_wrapper:UpdateFovy(gui.Width / gui.Height)
end
function set_third_person_camera()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return false
  end
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return false
  end
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    return false
  end
  local movie_objects = nx_value("movie_objects")
  if not nx_is_valid(movie_objects) then
    return false
  end
  local camera = get_game_camera()
  if not nx_is_valid(camera) then
    return false
  end
  local child = movie_objects:GetChild(movie_objects.first_person_camera_id)
  if not nx_is_valid(child) then
    return false
  end
  local camera_wrapper = child.visual
  if nx_find_custom(camera_wrapper, "third_camera") and nx_is_valid(camera_wrapper.third_camera) then
    camera_wrapper.Camera = camera_wrapper.third_camera
    camera_wrapper.third_camera = nil
  end
  terrain:RelocateVisual(camera_wrapper.Camera, camera.PositionX, camera.PositionY, camera.PositionZ)
  camera_wrapper:SetAngle(camera.AngleX, camera.AngleY, camera.AngleZ)
  set_camera_mode()
  local normal_camera = game_control:GetCameraController(0)
  normal_camera.MovieCameraChange = true
  camera_wrapper.Visible = true
  time_axis:SetPathVisible(child.Name, true)
  camera_wrapper.PyramidVisible = true
  local object_list = movie_objects:GetChildList()
  for _, child_object in pairs(object_list) do
    if nx_is_valid(child_object) then
      child_object.visual.Visible = true
      time_axis:SetPathVisible(child_object.Name, true)
    end
  end
  movie_objects.first_person_camera_id = ""
end
function modify_pos_by_player(x, y, z)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return false
  end
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    return x, y, z
  end
  local angle_y = time_axis.player_ang_y
  local new_y = y + visual_player.PositionY - 10
  local new_x, new_z = nx_function("ext_rotate_by_point", 0, 0, x, z, angle_y)
  new_x = new_x + time_axis.player_pos_x
  new_z = new_z + time_axis.player_pos_z
  return new_x, new_y, new_z
end
function modify_angley_by_player(rx, ry, rz)
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    return rx, ry, rz
  end
  rx = rx + time_axis.player_ang_x
  ry = ry + time_axis.player_ang_y
  rz = rz + time_axis.player_ang_z
  return rx, ry, rz
end
function get_camera_angle(camera_x, camera_y, camera_z, angle_x, angle_y, angle_z)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return angle_x, angle_y, angle_z
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return angle_x, angle_y, angle_z
  end
  local new_angle_x, new_angle_y = nx_function("ext_GetCameraAngle", visual_player.PositionX, visual_player.PositionY, visual_player.PositionZ, camera_x, camera_y, camera_z, angle_x, angle_y, angle_z)
  return new_angle_x, new_angle_y, angle_z
end
function start_movie(movie_id)
  movie_init()
  movie_load(movie_id)
  movie_play()
end
function movie_init()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return false
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  set_third_person_camera()
  movie_delete()
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    time_axis = scene:Create("TimeAxis")
  end
  if not nx_is_valid(time_axis) then
    return false
  end
  scene:AddObject(time_axis, 20)
  nx_set_value("time_axis", time_axis)
  nx_bind_script(time_axis, nx_current())
  nx_callback(time_axis, "on_execute_frame", "on_execute_frame")
  nx_callback(time_axis, "on_play_over", "on_play_over")
  local movie_objects = nx_value("movie_objects")
  if not nx_is_valid(movie_objects) then
    movie_objects = nx_create("ArrayList")
    nx_set_value("movie_objects", movie_objects)
  end
  movie_objects.first_person_camera_id = ""
  time_axis.player_pos_x = visual_player.PositionX
  time_axis.player_pos_y = visual_player.PositionY
  time_axis.player_pos_z = visual_player.PositionZ
  time_axis.player_ang_x = visual_player.AngleX
  time_axis.player_ang_y = visual_player.AngleY
  time_axis.player_ang_z = visual_player.AngleZ
end
function movie_load(movie_id)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local camera = get_game_camera()
  if not nx_is_valid(camera) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return false
  end
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    return false
  end
  local movie_objects = nx_value("movie_objects")
  if not nx_is_valid(movie_objects) then
    return false
  end
  movie_objects:ClearChild()
  local root_path = nx_resource_path() .. "ini\\quest\\" .. movie_id .. "\\"
  local ini = nx_create("IniDocument")
  ini.FileName = root_path .. "project_info.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local sect_table = ini:GetSectionList()
  local sect_count = table.getn(sect_table)
  if sect_count < 1 then
    return false
  end
  time_axis.FrameInterval = ini:ReadFloat(sect_table[1], "FrameTime", 0.1)
  local start_ = nx_int(ini:ReadFloat(sect_table[1], "RulerStart", -1))
  local end_ = nx_int(ini:ReadFloat(sect_table[1], "RulerEnd", -1))
  time_axis.BeginTime = start_ * time_axis.FrameInterval
  time_axis.EndTime = end_ * time_axis.FrameInterval
  local camera_x = ini:ReadFloat(sect_table[1], "CameraX", 0)
  local camera_y = ini:ReadFloat(sect_table[1], "CameraY", 0)
  local camera_z = ini:ReadFloat(sect_table[1], "CameraZ", 0)
  local camera_rx = ini:ReadFloat(sect_table[1], "CameraRX", 0)
  local camera_ry = ini:ReadFloat(sect_table[1], "CameraRY", 0)
  local camera_rz = ini:ReadFloat(sect_table[1], "CameraRZ", 0)
  local tempx = camera_x
  local tempy = camera_y
  local tempz = camera_z
  camera_x, camera_y, camera_z = modify_pos_by_player(camera_x, camera_y, camera_z)
  camera_rx, camera_ry, camera_rz = modify_angley_by_player(camera_rx, camera_ry, camera_rz)
  if camera_x ~= 0 or camera_y ~= 0 or camera_z ~= 0 then
    camera:SetPosition(camera_x, camera_y, camera_z)
  end
  if camera_rx ~= 0 or camera_ry ~= 0 or camera_rz ~= 0 then
    camera:SetAngle(camera_rx, camera_ry, camera_rz)
  end
  local sx = camera_x - visual_player.PositionX
  local sy = camera_y - visual_player.PositionY - 1.65
  local sz = camera_z - visual_player.PositionZ
  local distance = math.sqrt(sx * sx + sy * sy + sz * sz)
  set_camera_distance(distance)
  for i = 2, sect_count do
    local object_id = sect_table[i]
    if object_id ~= "" then
      local object_type = ini:ReadString(object_id, "ObjectType", "")
      if object_type == "camera" then
        local world_type = ini:ReadString(object_id, "WorldType", "objects")
        local visual_type = ini:ReadString(object_id, "VisualType", "")
        local name = ini:ReadString(object_id, "Name", "")
        local visual_config = ini:ReadString(object_id, "VisualConfig", "")
        local x = ini:ReadFloat(object_id, "PositionX", 0)
        local y = ini:ReadFloat(object_id, "PositionY", 0)
        local z = ini:ReadFloat(object_id, "PositionZ", 0)
        local rx = ini:ReadFloat(object_id, "AngleX", 0)
        local ry = ini:ReadFloat(object_id, "AngleY", 0)
        local rz = ini:ReadFloat(object_id, "AngleZ", 0)
        local scale_x = ini:ReadFloat(object_id, "ScaleX", 1)
        local scale_y = ini:ReadFloat(object_id, "ScaleY", 1)
        local scale_z = ini:ReadFloat(object_id, "ScaleZ", 1)
        x, y, z = modify_pos_by_player(x, y, z)
        rx, ry, rz = modify_angley_by_player(rx, ry, rz)
        local camera_wrapper = scene:Create("CameraWrapper")
        if nx_is_valid(camera_wrapper) then
          scene:AddObject(camera_wrapper, 100)
          camera_wrapper.FocusDepth = 20
          camera_wrapper.Fovx = ini:ReadFloat(object_id, "Fovx", to_radian(45))
          camera_wrapper.Camera = create_movie_model(name, visual_config, x, y, z, rx, ry, rz, scale_x, scale_y, scale_z)
          local object_xml = ini:ReadString(object_id, "Path", "")
          time_axis:LoadObjectKeyFrame(object_id, root_path .. object_xml, true)
          add_object_manager(object_id, camera_wrapper)
        end
      end
    end
  end
  nx_destroy(ini)
  time_axis:Pause(time_axis.BeginTime)
end
function movie_play()
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    return false
  end
  local movie_objects = nx_value("movie_objects")
  if not nx_is_valid(movie_objects) then
    return false
  end
  local object_list = movie_objects:GetChildList()
  if table.getn(object_list) > 0 then
    set_first_person_camera(object_list[1].Name)
  end
  set_camera_control(false)
  time_axis:Play()
end
function movie_stop()
  set_third_person_camera()
  movie_delete()
  set_camera_control(true)
end
function movie_delete()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local camera = get_game_camera()
  if not nx_is_valid(camera) then
    return false
  end
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    return false
  end
  local movie_objects = nx_value("movie_objects")
  if not nx_is_valid(movie_objects) then
    return false
  end
  local child_list = movie_objects:GetChildList()
  for i = 1, table.getn(child_list) do
    if nx_is_valid(child_list[i]) then
      local camera_wrapper = child_list[i].visual
      if nx_is_valid(camera_wrapper) then
        local temp_camera = camera_wrapper.Camera
        camera_wrapper.Camera = nil
        time_axis:DeleteObject(child_list[i].Name)
        if nx_find_custom(camera_wrapper, "third_camera") and nx_is_valid(camera_wrapper.third_camera) and not nx_id_equal(camera, temp_camera) then
          scene:Delete(camera_wrapper.third_camera)
        end
        if not nx_id_equal(camera, temp_camera) then
          scene:Delete(temp_camera)
        end
        scene:Delete(camera_wrapper)
      end
    end
  end
  movie_objects:ClearChild()
  nx_destroy(movie_objects)
  time_axis:Clear()
  scene:Delete(time_axis)
end
function create_movie_model(name, model_file, x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z)
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return nx_null()
  end
  if nil == model_file or "" == model_file then
    return nx_null()
  end
  if 32 ~= string.len(name) then
    name = nx_function("ext_gen_unique_name")
  end
  local tex_path_table = terrain:GetTexturePathList()
  local tex_paths = ""
  local tex_num = table.getn(tex_path_table)
  for i = 1, tex_num do
    tex_paths = tex_paths .. tex_path_table[i]
    if i ~= tex_num then
      tex_paths = tex_paths .. "|"
    end
  end
  local scene = nx_value("scene")
  local model = scene:Create("Model")
  model.AsyncLoad = true
  model.ShowBoundBox = false
  model.ModelFile = model_file
  model.LightFile = ""
  model.TexPaths = tex_paths
  model.name = name
  model.no_light = true
  model.only_design = false
  model.clip_radius = 0
  model.light_map_size = 0
  model.WaterReflect = false
  model.co_walkable = false
  model.co_gen_wall = false
  model.co_gen_roof = false
  model.co_through = false
  model.ExtraInfo = ""
  model.tag = "MovieObject"
  model.widget = false
  model:SetPosition(x, y, z)
  model:SetAngle(angle_x, angle_y, angle_z)
  model:SetScale(scale_x, scale_y, scale_z)
  model:Load()
  if no_light then
    model.UseVertexColor = false
    model.UseLightMap = false
  else
    model.UseVertexColor = model.HasVertexColor
    if model.HasLightMap then
      model.UseLightMap = true
    end
  end
  if not nx_is_valid(terrain) or not terrain:AddVisual(name, model) then
    scene:Delete(model)
    return nx_null()
  end
  return model
end
function add_object_manager(object_id, camera_wrapper)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    return false
  end
  local movie_objects = nx_value("movie_objects")
  if not nx_is_valid(movie_objects) then
    return false
  end
  if movie_objects:FindChild(object_id) then
    local child = movie_objects:GetChild(object_id)
    child.visual = camera_wrapper
    time_axis:SetObjectID(object_id, camera_wrapper)
    time_axis:SetNeedVisual(object_id, true)
    return false
  end
  if not time_axis:IsObjectExist(object_id) then
    time_axis:AddObject(object_id)
  end
  time_axis:SetObjectID(object_id, camera_wrapper)
  time_axis:SetNeedVisual(object_id, true)
  local child = movie_objects:CreateChild(object_id)
  if nx_is_valid(child) then
    child.visual = camera_wrapper
  end
  camera_wrapper.Aspect = 1.7777777777777777
  camera_wrapper:UpdateFovy(gui.Width / gui.Height)
  return true
end
function on_execute_frame(time_axis, object_id, visual, key_time, ...)
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return
  end
  local movie_objects = nx_value("movie_objects")
  if not nx_is_valid(movie_objects) then
    return
  end
  local count = #arg
  local i = 1
  local add = 1
  while count > i do
    local controller_type = nx_number(arg[i])
    local add = 2
    if controller_type == CONTROLLER_TYPE_POSITION_ANGLE then
      local x = arg[i + 1]
      local y = arg[i + 2]
      local z = arg[i + 3]
      local rx = arg[i + 4]
      local ry = arg[i + 5]
      local rz = arg[i + 6]
      x, y, z = modify_pos_by_player(x, y, z)
      rx, ry, rz = modify_angley_by_player(rx, ry, rz)
      if not nx_is_valid(terrain) then
        return
      end
      if not nx_is_valid(visual.Camera) then
        return
      end
      terrain:RelocateVisual(visual.Camera, x, y, z)
      visual.Camera:SetAngle(rx, ry, rz)
      add = 7
    elseif controller_type == CONTROLLER_TYPE_CHANGE_CAMERA then
      local param_list = util_split_string(arg[i + 1], ",")
      local new_camera = ""
      if "change_camera" == param_list[1] then
        new_camera = param_list[2]
      else
        new_camera = param_list[1]
      end
      if movie_objects.first_person_camera_id ~= "" and movie_objects.first_person_camera_id ~= new_camera then
        set_first_person_camera(new_camera)
      end
    elseif controller_type == CONTROLLER_TYPE_ACTION_KEY or controller_type == CONTROLLER_TYPE_ALPHA or controller_type == CONTROLLER_TYPE_ALPHA_PPFILTER or controller_type == CONTROLLER_TYPE_LIGHTNING_KEY or controller_type == CONTROLLER_TYPE_SOUND or controller_type == CONTROLLER_TYPE_MUSIC or controller_type == CONTROLLER_TYPE_GROUND_Y then
      add = 4
    end
    i = i + add
  end
end
function on_play_over(time_axis, key_time)
  movie_stop()
end
