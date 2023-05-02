require("scene")
require("util_functions")
function add_login_private_to_scene(scene)
  if nx_is_valid(scene) and (not nx_find_custom(scene, "login_control") or not nx_is_valid(scene.login_control)) then
    local world = nx_value("world")
    local login_control = scene:Create("LoginControl")
    nx_bind_script(login_control, "login_scene", "login_control_init")
    login_control.Camera = scene.camera
    scene.login_control = login_control
    login_control:Load()
    scene:AddObject(login_control, 0)
  end
end
function load_login_scene(scene, scene_path)
  local world = nx_value("world")
  apply_login01_camera(scene, scene_path)
  load_scene(scene, scene_path, true)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  apply_login01_effect(scene, scene_path)
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
function clear_login_scene_private(scene)
  if nx_find_custom(scene, "login_control") then
    scene:Delete(scene.login_control)
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
  local game_config = nx_value("game_config")
  if not game_config.is_first_in_game then
    nx_execute("game_config", "apply_performance_config", scene, game_config)
    if game_config.level == "high" or game_config.level == "ultra" then
      scene.FarClipDistance = 600
    end
    return
  end
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain.LodRadius = 200
    terrain.GrassRadius = 100
    terrain.AlphaFadeRadius = 300
    terrain.AlphaHideRadius = 350
    terrain.ClipRadiusNear = 400
    terrain.ClipRadiusFar = 600
  end
  local game_config = nx_value("game_config")
  game_config.is_enable_realize_depth = false
  game_config.is_enable_realize_normal = false
  local stage = nx_value("stage")
  if 4 <= device_level then
    game_config.is_enable_realize_depth = true
    game_config.is_enable_realize_normal = true
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
    nx_execute("game_config", "set_dof_enable", scene, true)
    nx_execute("game_config", "set_texture_quality", scene, 2)
    nx_execute("game_config", "set_effect_quality", scene, 2)
  elseif 3 <= device_level then
    nx_execute("game_config", "set_anisotropic", scene, 8)
    nx_execute("game_config", "set_shadow_quality", scene, 1)
    nx_execute("game_config", "set_filter_enable", scene, true)
    nx_execute("game_config", "set_bloom_enable", scene, true)
    nx_execute("game_config", "set_volume_lighting_enable", scene, false)
    set_high_water_quality(scene, 2)
    nx_execute("game_config", "set_hdr_enable", scene, true)
    nx_execute("game_config", "set_screen_blur_enable", scene, true)
    nx_execute("game_config", "set_prelight_enable", scene, false)
    nx_execute("game_config", "set_ssao_enable", scene, false)
    nx_execute("game_config", "set_dof_enable", scene, false)
    nx_execute("game_config", "set_texture_quality", scene, 1)
    nx_execute("game_config", "set_effect_quality", scene, 1)
  elseif 2 <= device_level then
    nx_execute("game_config", "set_anisotropic", scene, 8)
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
  scene.EnableEarlyZ = false
  scene.FarClipDistance = 600
  if nx_is_valid(terrain) then
    terrain:RefreshGrass()
    terrain:RefreshWater()
  end
end
function apply_login01_camera(scene, scene_path)
  load_scene_camera(scene, nx_resource_path() .. scene_path .. "\\editor.ini", true)
end
function change_login_effect()
  nx_call("terrain\\weather_set", "delete_weather_data")
  clear_login_weather()
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "map\\ini\\weather\\weather_login.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  local scet_num = ini:GetSectionCount()
  if scet_num < 1 then
    nx_destroy(ini)
    return 0
  end
  local num = math.random(1, scet_num)
  local sect_table = {}
  local sect_list = ini:GetSectionList()
  for i, sect in ipairs(sect_list) do
    table.insert(sect_table, nx_string(sect))
  end
  if 0 >= table.getn(sect_table) then
    nx_destroy(ini)
    return 0
  end
  local model_config = ini:ReadString(sect_table[num], "weather_model", "ini\\particles_mdl.ini,E_test_weather")
  local model_table = util_split_string(model_config, ",")
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    nx_destroy(ini)
    return 0
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    nx_destroy(ini)
    return 0
  end
  local name = nx_function("ext_gen_unique_name")
  local effectmodel_config = "map\\" .. model_table[1]
  local effectmodel_name = model_table[2]
  local pos_x, pos_y, pos_z = camera.PositionX, camera.PositionY, camera.PositionZ
  local angle_x, angle_y, angle_z = 0, 0, 0
  local scale_x, scale_y, scale_z = 1, 1, 1
  local tag = "model"
  local effectmodel = scene:Create("EffectModel")
  if not nx_is_valid(effectmodel) then
    nx_destroy(ini)
    return 0
  end
  effectmodel.AsyncLoad = true
  effectmodel:SetPosition(pos_x, pos_y, pos_z)
  effectmodel:SetAngle(angle_x, angle_y, angle_z)
  effectmodel:SetScale(scale_x, scale_y, scale_z)
  if not effectmodel:CreateFromIniEx(effectmodel_config, effectmodel_name, false, "map\\") then
    nx_log("create effectmodel from ini file failed")
    nx_log(effectmodel_config)
    nx_log(effectmodel_name)
    nx_destroy(ini)
    return 0
  end
  while not effectmodel.LoadFinish do
    nx_pause(0)
  end
  effectmodel.name = name
  effectmodel.config = effectmodel_config
  effectmodel.effectmodel_config = effectmodel_config
  effectmodel.effectmodel_name = effectmodel_name
  effectmodel.clip_radius = 1000
  effectmodel.WaterReflect = false
  effectmodel.tag = tag
  scene:AddObject(effectmodel, 21)
  if nx_is_valid(effectmodel) then
    nx_set_value("login_weather_model", effectmodel)
    effectmodel.path = "login001"
    if "" ~= sect_table[num] then
      effectmodel.path = sect_table[num]
    end
    camera:AddAsynPosObject(effectmodel, 0, 0, 0)
    local item_list = ini:GetItemList(sect_table[num])
    for j, item in ipairs(item_list) do
      if "weather_model" ~= item then
        local value = ini:ReadString(sect_table[num], item, "")
        if "" ~= value then
          local helper_list = effectmodel:GetHelperNameList()
          effectmodel:AddParticle(value, helper_list[1], -1, -1)
        end
      end
    end
  end
  nx_destroy(ini)
  return 1
end
function clear_login_weather()
  local effectmodel = nx_value("login_weather_model")
  if nx_is_valid(effectmodel) then
    local helper_list = effectmodel:GetHelperNameList()
    effectmodel:DeleteParticleOnHelper(helper_list[1])
    local scene = nx_value("game_scene")
    if nx_is_valid(scene) then
      local camera = scene.camera
      if nx_is_valid(camera) then
        camera:RemoveAsynPosObject(effectmodel)
      end
      scene:Delete(effectmodel)
    end
  end
end
function apply_login01_effect(scene, scene_path)
  local game_config = nx_value("game_config")
  local stage = nx_value("stage")
  if "login" == stage then
    if nx_is_valid(game_config) then
      change_login_effect()
      local effectmodel = nx_value("login_weather_model")
      if nx_is_valid(effectmodel) then
        nx_execute("terrain\\terrain", "load_scene_screeneffect", scene, nx_resource_path() .. "map\\ini\\weather\\weather_login\\" .. effectmodel.path .. "\\", true)
      end
    end
  else
    nx_execute("terrain\\terrain", "load_scene_screeneffect", scene, nx_resource_path() .. scene_path, true)
  end
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
  nx_execute("terrain\\terrain", "load_scene_screeneffect", scene, nx_resource_path() .. "map\\ter\\login03\\", false)
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
function on_login_sun_change(scene)
  local add_SunShineRadius = true
  local add_SampleBias = true
  local speed_SunShineRadius = 0.1
  local speed_SampleBias = 0.1
  local cur_min_SunShineRadius = 0.261
  local cur_max_SunShineRadius = 0.8
  local cur_min_SampleBias = 0.44
  local cur_max_SampleBias = 1.21
  local ppvolumelighting = scene.ppvolumelighting
  local is_first_time = true
  while true do
    local stage = nx_value("stage")
    if stage == "login" then
      local time = nx_pause(0)
      if not nx_is_valid(scene) then
        return
      end
      local ppvolumelighting = scene.ppvolumelighting
      if nx_is_valid(ppvolumelighting) then
        if is_first_time then
          is_first_time = false
          ppvolumelighting.SunShineRadius = 0.261
          ppvolumelighting.SampleBias = 0.44
        end
        if add_SunShineRadius then
          ppvolumelighting.SunShineRadius = ppvolumelighting.SunShineRadius + speed_SunShineRadius * time
          if cur_max_SunShineRadius <= ppvolumelighting.SunShineRadius then
            add_SunShineRadius = false
          end
        else
          ppvolumelighting.SunShineRadius = ppvolumelighting.SunShineRadius - speed_SunShineRadius * time
          if cur_min_SunShineRadius >= ppvolumelighting.SunShineRadius then
            add_SunShineRadius = true
            cur_min_SunShineRadius = math.random(10) * 0.539 / 10 + 0.261
            cur_max_SunShineRadius = cur_min_SunShineRadius + 0.4
            if 0.8 < cur_max_SunShineRadius then
              cur_max_SunShineRadius = 0.8
            end
          end
        end
        if add_SampleBias then
          ppvolumelighting.SampleBias = ppvolumelighting.SampleBias + speed_SampleBias * time
          if cur_max_SampleBias <= ppvolumelighting.SampleBias then
            add_SampleBias = false
          end
        else
          ppvolumelighting.SampleBias = ppvolumelighting.SampleBias - speed_SampleBias * time
          if cur_min_SampleBias >= ppvolumelighting.SampleBias then
            add_SampleBias = true
            cur_min_SampleBias = math.random(10) * 0.77 / 10 + 0.44
            cur_max_SampleBias = cur_min_SampleBias + 0.4
          end
        end
      end
    else
      break
    end
  end
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
  local login_control = scene.login_control
  login_control:SetCameraDirect(0, radius * 0.6, -radius * 2.5, 0, 0, 0)
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
    local result = load_from_ini(scene, actor2, "ini\\" .. res_name .. ".ini")
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
function login_control_init(login_control)
  login_control.MaxDistance = 10
  login_control.MinDistance = 1
end
function login_control_mouse_move(self, mouse_x, mouse_y)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or nx_is_valid(gui.Capture) then
    return 0
  end
  local pick_model = test_click_model(mouse_x, mouse_y)
  if not nx_is_valid(pick_model) then
    pick_model = nx_null()
  end
  return 1
end
function login_control_left_down(self, mouse_x, mouse_y)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or nx_is_valid(gui.Capture) then
    return 0
  end
  local pick_model = test_click_model(mouse_x, mouse_y)
  if nx_is_valid(pick_model) then
  end
  return 1
end
function test_click_model(mouse_x, mouse_y)
  if mouse_x == nil or mouse_y == nil then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_find_custom(scene, "terrain") then
    return nx_null()
  end
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
