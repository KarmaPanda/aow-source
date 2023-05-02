require("scene")
require("util_functions")
require("role_composite")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function add_create_private_to_scene(scene)
  if nx_is_valid(scene) then
    local world = nx_value("world")
    local create_control = scene:Create("CreateControl")
    nx_bind_script(create_control, nx_current(), "init_create_control")
    create_control.Camera = scene.camera
    scene.create_control = create_control
    create_control:Load()
    scene:AddObject(create_control, 0)
  end
end
function load_create_scene(scene, scene_path)
  local world = nx_value("world")
  apply_login01_camera(scene)
  load_scene(scene, scene_path, true)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  apply_login01_effect(scene)
  nx_pause(0.1)
  while nx_is_valid(terrain) and not terrain.LoadFinish do
    nx_pause(0.2)
  end
  terrain.WaterVisible = true
  terrain.GroundVisible = true
  terrain.VisualVisible = true
  terrain.HelperVisible = true
  terrain:RefreshGround()
  terrain:RefreshVisual()
  terrain:RefreshGrass()
  terrain:RefreshWater()
  local game_config = nx_value("game_config")
  nx_execute("game_config", "set_logic_sound_enable", scene, 0, game_config.area_music_enable)
  local stage = nx_value("stage")
  nx_function("ext_set_screen_colorfull")
end
function create_menu_scene()
  local gui = nx_value("gui")
  local menu_config = gui:Create("Menu")
  menu_config.Left = 0
  menu_config.Top = 0
  menu_config.Width = 100
  menu_config.ItemWidth = 60
  menu_config.NoFrame = true
  menu_config.BackColor = "255, 192, 192, 192"
  menu_config.Width = 160
  menu_config:CreateItem("camera", nx_widestr("\177\224\188\173\198\247\178\206\202\253"))
  menu_config:CreateItem("weather", nx_widestr("\204\236\198\248\178\206\202\253"))
  menu_config:CreateItem("material", nx_widestr("\181\216\195\230\178\196\214\202"))
  menu_config:CreateItem("s1", nx_widestr("-"))
  menu_config:CreateItem("terrain", nx_widestr("\181\216\208\206\197\228\214\195"))
  menu_config:CreateItem("water", nx_widestr("\203\174\195\230\197\228\214\195"))
  menu_config:CreateItem("grass", nx_widestr("\187\168\178\221\197\228\214\195"))
  menu_config:CreateItem("screen", nx_widestr("\200\171\198\193\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("role", nx_widestr("\189\199\201\171\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("s2", nx_widestr("-"))
  menu_config:CreateItem("ppfilter", nx_widestr("\201\171\178\202\181\247\189\218\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("pphdr", nx_widestr("HDR\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("ppbloom", nx_widestr("\183\186\185\226\208\167\185\251\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("ppvolumelighting", nx_widestr("\200\221\187\253\185\226\213\213\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("ppscreenrefraction", nx_widestr("\203\174\207\194\213\219\201\228\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("pppixelrefraction", nx_widestr("\200\171\198\193\213\219\201\228\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("ppblast", nx_widestr("\177\172\213\168\208\167\185\251\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("ppdof", nx_widestr("\190\176\201\238\208\167\185\251\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("ppscrblur", nx_widestr("\200\171\198\193\200\225\187\175\208\167\185\251\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("ppmotionblur", nx_widestr("\212\203\182\175\196\163\186\253\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("ppglow", nx_widestr("\196\163\208\205\183\186\185\226\208\167\185\251\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("s3", nx_widestr("-"))
  menu_config:CreateItem("pssm", nx_widestr("\202\181\202\177\210\245\211\176\178\206\202\253\197\228\214\195"))
  menu_config:CreateItem("hbao", nx_widestr("\202\181\202\177\187\183\190\179\213\218\181\178(HBAO)\197\228\214\195"))
  menu_config:CreateItem("ssao", nx_widestr("\202\181\202\177\187\183\190\179\213\218\181\178(SSAO)\197\228\214\195"))
  menu_config:CreateItem("s4", nx_widestr("-"))
  menu_config:CreateItem("put_creator", nx_widestr("\176\218\183\197\194\183\181\227"))
  menu_config:CreateItem("s5", nx_widestr("-"))
  menu_config:CreateItem("save_camera", nx_widestr("\177\163\180\230\201\227\207\241\187\250"))
  menu_config:CreateItem("edit_camera", nx_widestr("\177\224\188\173\201\227\207\241\187\250"))
  nx_bind_script(menu_config, "scene_editor\\menu_config", "menu_config_init")
  gui.Desktop:Add(menu_config)
  gui.menu_scene = menu_config
end
function clear_create_scene_private(scene)
  if nx_find_custom(scene, "create_control") then
    scene:Delete(scene.create_control)
    local camera = scene.camera
    if nx_is_valid(camera) then
      camera.fov_angle = 51.8
      camera.fov_wide_angle = 68
    end
  end
end
function set_high_water_quality(scene, value)
  nx_execute("game_config", "set_water_quality", scene, value)
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain.GroundEnvMap = value
    terrain.VisualEnvMap = value
  end
end
function set_low_water_quality(scene)
  nx_execute("game_config", "set_water_quality", scene, 1)
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain.GroundEnvMap = 1
    terrain.VisualEnvMap = 0
    local water_table = terrain:GetWaterList()
    for i = 1, table.getn(water_table) do
      water_table[i].CubeMapStatic = true
    end
  end
end
function set_device_level_quality(scene, device_level)
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain.LodRadius = 200
    terrain.GrassRadius = 100
    terrain.AlphaFadeRadius = 300
    terrain.AlphaHideRadius = 350
    terrain.ClipRadiusNear = 400
    terrain.ClipRadiusFar = 600
  end
  if 4 <= device_level then
    nx_execute("game_config", "set_prelight_enable", scene, true)
    nx_execute("game_config", "set_anisotropic", scene, 16)
    nx_execute("game_config", "set_shadow_quality", scene, 2)
    nx_execute("game_config", "set_filter_enable", scene, true)
    nx_execute("game_config", "set_bloom_enable", scene, true)
    nx_execute("game_config", "set_volume_lighting_enable", scene, true)
    set_high_water_quality(scene, 2)
    nx_execute("game_config", "set_hdr_enable", scene, true)
    nx_execute("game_config", "set_screen_blur_enable", scene, true)
    nx_execute("game_config", "set_ssao_enable", scene, true)
  elseif 3 <= device_level then
    nx_execute("game_config", "set_anisotropic", scene, 16)
    nx_execute("game_config", "set_shadow_quality", scene, 1)
    nx_execute("game_config", "set_filter_enable", scene, true)
    nx_execute("game_config", "set_bloom_enable", scene, true)
    nx_execute("game_config", "set_volume_lighting_enable", scene, false)
    set_high_water_quality(scene, 2)
    nx_execute("game_config", "set_hdr_enable", scene, true)
    nx_execute("game_config", "set_screen_blur_enable", scene, true)
  elseif 2 <= device_level then
    nx_execute("game_config", "set_anisotropic", scene, 16)
    nx_execute("game_config", "set_filter_enable", scene, true)
    nx_execute("game_config", "set_bloom_enable", scene, true)
    nx_execute("game_config", "set_volume_lighting_enable", scene, true)
    set_high_water_quality(scene, 1)
  elseif 1 <= device_level then
    nx_execute("game_config", "set_anisotropic", scene, 4)
    set_low_water_quality(scene)
    if nx_is_valid(terrain) then
      terrain.GrassLod = 0.5
    end
  else
    nx_execute("game_config", "set_anisotropic", scene, 0)
    nx_execute("game_config", "set_water_quality", scene, 0)
    if nx_is_valid(terrain) then
      terrain.GrassRadius = 50
      terrain.GrassLod = 0.25
    end
  end
  scene.EnableEarlyZ = true
  scene.FarClipDistance = 600
  if nx_is_valid(terrain) then
    terrain:RefreshGrass()
    terrain:RefreshWater()
  end
end
function apply_login01_camera(scene)
  load_scene_camera(scene, nx_resource_path() .. "map\\ter\\login04\\editor.ini", true)
end
function apply_login01_effect(scene, is_update_camera)
  nx_execute("terrain\\terrain", "load_scene_screeneffect", scene, nx_resource_path() .. "map\\ter\\login04\\", false)
  local terrain = scene.terrain
  local water_table = terrain:GetWaterList()
  for _, water in pairs(water_table) do
    water.ReflectionRatio = 1
    water:UpdateSeaData()
  end
  terrain.WaterWave = false
  terrain.LodRadius = 2000
  terrain.GrassRadius = 1000
  terrain.GrassLod = 1
  local world = nx_value("world")
  set_device_level_quality(scene, world.device_level)
end
function apply_login02_camera(scene)
  load_scene_camera(scene, nx_resource_path() .. "map\\ter\\login02\\editor.ini", true)
  local camera = scene.camera
  camera.Fov = 51.8 * math.pi * 2 / 360
end
function apply_login02_effect(scene)
  nx_execute("terrain\\terrain", "load_scene_screeneffect", scene, nx_resource_path() .. "map\\ter\\login01\\login02\\", false)
  local terrain = scene.terrain
  local water_table = terrain:GetWaterList()
  for _, water in pairs(water_table) do
    water.ReflectionRatio = 1
    water:UpdateSeaData()
  end
  terrain.WaterWave = false
  terrain.LodRadius = 2000
  terrain.GrassRadius = 1000
  terrain.GrassLod = 1
  local world = nx_value("world")
  set_device_level_quality(scene, world.device_level)
end
function get_pi(degree)
  return math.pi * degree / 180
end
function add_obj_to_scene(scene, actor2)
  while not actor2.LoadFinish do
    nx_pause(0)
  end
  actor2:SetPosition(0, 0, 0)
  actor2:SetAngle(0, math.pi, 0)
  local radius = 1.5
  if radius < 1 then
    radius = 1
  end
  if 50 < radius then
    radius = 50
  end
  local create_control = scene.create_control
  create_control:SetCameraDirect(0, radius * 0.6, -radius * 2.5, 0, 0, 0)
  scene:AddObject(actor2, 20)
end
function load_scene_npc(terrain, terrain_path)
  local ini = nx_execute("util_functions", "get_ini", "share\\creator\\scenenpc.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\creator\\scenenpc.ini " .. get_msg_str("msg_120"))
    return false
  end
  local count = ini:GetSectionCount()
  for i = 1, count do
    local res_name = ini:ReadString(i - 1, "resource", "")
    if resource_name ~= "" then
      local actor2_npc = create_scene_npc(terrain, res_name)
      actor2_npc.terrain = terrain
      local path_type = ini:ReadInteger(i - 1, "pathtype", -1)
      if path_type == 0 then
        local action_count = 0
        local move_count = 0
        while true do
          local action_type = ini:ReadString(i - 1, "time_action" .. nx_string(nx_int(action_count)), "")
          if action_type ~= "" then
            local table_string = nx_function("ext_split_string", action_type)
            if table.maxn(table_string) >= 4 then
              do
                local name = "time_action" .. nx_string(nx_int(action_count))
                local array_list = nx_create("ArrayList", "login_scene:" .. name)
                if not nx_is_valid(actor2_npc.Data) then
                  actor2_npc.Data = nx_create("ArrayList", "login_scene:actor2_npc.Data")
                end
                actor2_npc.Data:AddChild(name, array_list)
                nx_set_custom(actor2_npc, name, array_list)
                array_list.move_type = table_string[1]
                array_list.pos_x = nx_number(table_string[2])
                array_list.pos_y = nx_number(table_string[3])
                array_list.pos_z = nx_number(table_string[4])
                if array_list.move_type == "stop" then
                  if table.maxn(table_string) >= 9 then
                    array_list.angle_x = nx_number(table_string[5])
                    array_list.angle_y = nx_number(table_string[6])
                    array_list.angle_z = nx_number(table_string[7])
                    array_list.action = table_string[8]
                    array_list.keey_time = nx_number(table_string[9])
                  else
                  end
                else
                  if array_list.move_type == "moveto" then
                    if table.maxn(table_string) >= 6 then
                      array_list.action = table_string[5]
                      array_list.keey_time = nx_number(table_string[6])
                    else
                    end
                    move_count = move_count + 1
                  else
                  end
                end
              end
            end
          else
            break
          end
          action_count = action_count + 1
        end
        actor2_npc.action_count = action_count - 1
        if move_count == 0 then
        else
          nx_bind_script(actor2_npc, "scene_npc_line_move", "init")
        end
      elseif path_type == 1 then
        actor2_npc.round_center_x = ini:ReadFloat(i - 1, "round_center_x", 0)
        actor2_npc.round_center_y = ini:ReadFloat(i - 1, "round_center_y", 0)
        actor2_npc.round_center_z = ini:ReadFloat(i - 1, "round_center_z", 0)
        actor2_npc.round_radius = ini:ReadFloat(i - 1, "round_radius", 2)
        actor2_npc.round_time = ini:ReadInteger(i - 1, "round_time", 10)
        nx_bind_script(actor2_npc, "scene_npc_round_move", "init")
      elseif path_type == 2 then
        actor2_npc.allipse_center_x = ini:ReadFloat(i - 1, "allipse_center_x", 0)
        actor2_npc.allipse_center_y = ini:ReadFloat(i - 1, "allipse_center_y", 0)
        actor2_npc.allipse_center_z = ini:ReadFloat(i - 1, "allipse_center_z", 0)
        actor2_npc.ellipse_angle_y = ini:ReadFloat(i - 1, "ellipse_angle_y", 0)
        actor2_npc.ellipse_x_radius = ini:ReadFloat(i - 1, "ellipse_x_radius", 5)
        actor2_npc.ellipse_z_radius = ini:ReadFloat(i - 1, "ellipse_z_radius", 5)
        actor2_npc.ellipse_time = ini:ReadInteger(i - 1, "ellipse_time", 10)
        nx_bind_script(actor2_npc, "scene_npc_ellipse_move", "init")
      elseif path_type == 3 then
        local action_count = 0
        while true do
          local action_type = ini:ReadString(i - 1, "time_action" .. nx_string(nx_int(action_count)), "")
          if action_type ~= "" then
            local table_string = nx_function("ext_split_string", action_type)
            if table.maxn(table_string) >= 4 then
              local name = "time_action" .. nx_string(nx_int(action_count))
              local array_list = nx_call("util_gui", "get_arraylist", "login_scene:" .. name)
              if not nx_is_valid(actor2_npc.Data) then
                actor2_npc.Data = nx_create("ArrayList", "login_scene:actor2_npc.Data2")
              end
              actor2_npc.Data:AddChild(name, array_list)
              nx_set_custom(actor2_npc, name, array_list)
              array_list.move_type = table_string[1]
              array_list.pos_x = nx_number(table_string[2])
              array_list.pos_y = nx_number(table_string[3])
              array_list.pos_z = nx_number(table_string[4])
              if array_list.move_type == "stop" then
                if table.maxn(table_string) >= 9 then
                  array_list.angle_x = nx_number(table_string[5])
                  array_list.angle_y = nx_number(table_string[6])
                  array_list.angle_z = nx_number(table_string[7])
                  array_list.action = table_string[8]
                  array_list.keey_time = nx_number(table_string[9])
                else
                end
              else
                if array_list.move_type == "moveto" and table.maxn(table_string) >= 6 then
                  array_list.action = table_string[5]
                  array_list.keey_time = nx_number(table_string[6])
                else
                end
              end
            else
            end
          else
            break
          end
          action_count = action_count + 1
        end
        actor2_npc.action_count = action_count - 1
        nx_bind_script(actor2_npc, "scene_npc_smoothline_move", "init")
      elseif path_type == 4 then
        local script_file = ini:ReadString(i - 1, "script", "")
        nx_bind_script(actor2_npc, script_file, "init")
      end
    end
  end
end
function create_scene_npc(terrain, res_name)
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  local actor2 = nx_null()
  if res_name ~= nil and string.len(res_name) > 0 then
    actor2 = nx_execute("role_composite", "create_actor2", scene)
    if not nx_is_valid(actor2) then
      return 0
    end
    actor2.AsyncLoad = true
    local result = load_from_ini(actor2, "ini\\" .. res_name .. ".ini")
    if not result then
      scene:Delete(actor2)
      return nx_null()
    end
    if not nx_is_valid(terrain) or not nx_is_valid(actor2) then
      return
    end
    terrain:AddVisualRole("", actor2)
    terrain:RelocateVisual(actor2, 0, 0, 0)
    terrain:RefreshVisual()
  end
  return actor2
end
function init_create_control(create_control)
  create_control.MaxDistance = 10
  create_control.MinDistance = 1
  nx_callback(create_control, "on_mouse_move", "create_control_mouse_move")
  nx_callback(create_control, "on_left_down", "create_control_left_down")
end
function create_control_mouse_move(self, mouse_x, mouse_y)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or nx_is_valid(gui.Capture) then
    return 0
  end
  local pick_model = test_click_model(mouse_x, mouse_y)
  if not nx_is_valid(pick_model) then
    return 0
  end
  return 1
end
function create_control_left_down(self, mouse_x, mouse_y)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_create\\form_select_book")
  if not nx_is_valid(form) then
    return
  end
  if form.is_move then
    return
  end
  if not nx_is_valid(gui) or nx_is_valid(gui.Capture) then
    return 0
  end
  local visual_npc = test_click_model(mouse_x, mouse_y)
  if not nx_is_valid(visual_npc) then
    return 0
  end
  if not nx_find_custom(visual_npc, "book_id") then
    return 0
  end
  local child_control_list = form.groupbox_1:GetChildControlList()
  for _, rbtn in ipairs(child_control_list) do
    local data_source = rbtn.DataSource
    if visual_npc.book_id == data_source then
      if rbtn.Enabled then
        rbtn.Checked = true
      else
        nx_execute("form_stage_create\\form_select_book", "set_mltbox_tips", rbtn)
      end
      return
    end
  end
  return 1
end
function track_select_npc(visual_npc, form, track)
  if not nx_find_custom(visual_npc, "book_id") then
    return
  end
  if visual_npc.is_click then
    return
  end
  visual_npc.is_click = true
  local old_select_npc = form.select_npc
  if nx_is_valid(old_select_npc) then
    old_select_npc.is_click = false
  end
  form.select_npc = visual_npc
  if nx_find_custom(visual_npc, "book_id") then
    form.book_id = book_id
  end
  if nil == track or "" == track then
    return
  end
  nx_execute("form_stage_create\\create_logic", "set_camera_move", form, track, visual_npc)
  nx_execute("form_stage_create\\create_logic", "set_btn_visible", form, false)
end
function test_click_model(mouse_x, mouse_y)
  if mouse_x == nil or mouse_y == nil then
    return
  end
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return nx_null()
  end
  terrain:SetTraceMask("Role", false)
  terrain:SetTraceMask("Model", true)
  terrain:SetTraceMask("Ground", true)
  terrain:SetTraceMask("Particle", true)
  terrain:SetTraceMask("Light", true)
  terrain:SetTraceMask("Sound", true)
  terrain:SetTraceMask("Trigger", true)
  terrain:SetTraceMask("Helper", true)
  terrain:SetTraceMask("EffectModel", false)
  terrain:SetTraceMask("Through", true)
  local pick_id = terrain:PickVisual(mouse_x, mouse_y, 100)
  terrain:SetTraceMask("Ground", false)
  terrain:SetTraceMask("Role", true)
  terrain:SetTraceMask("Model", false)
  terrain:SetTraceMask("EffectModel", true)
  return pick_id
end
