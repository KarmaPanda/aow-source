require("role_composite")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
READ_ALL_SHILI = 0
local unopened_list = {
  10,
  11,
  12,
  13,
  16,
  20,
  21,
  22,
  25,
  26,
  27,
  39,
  42,
  43,
  44,
  45,
  47,
  48,
  51,
  54,
  55,
  57,
  59,
  60,
  61,
  63,
  64,
  65,
  66,
  67,
  71,
  72,
  73,
  74,
  75,
  76,
  77,
  78,
  79,
  80
}
local table_player_boy_action = {
  "interact117",
  "interact118",
  "interact381"
}
local table_player_girl_action = {
  "interact117",
  "interact118",
  "interact381"
}
local table_npc_girl_action = {
  "ty_stand_01",
  "ty_stand_02",
  "ty_stand_03",
  "ty_stand_05",
  "ty_stand_06"
}
local table_npc_boy_action = {
  "ty_stand_01",
  "ty_stand_02",
  "ty_stand_03",
  "ty_stand_05",
  "ty_stand_06"
}
local SHOW_REGION_RECT = 0
local SHOW_REGION_REAL_WORLD = 1
local SHOW_REGION_LINK = 2
local SHOW_REGION_IN_CYCLE = 0
local SHOW_REGION_IN_REGION = 1
local BACK_EFFECT_NAME = {
  [1] = "",
  [2] = "haoyou_move_01",
  [3] = "jiebai_move_01",
  [4] = "chouren_move_01",
  [5] = "xuechou_move_01",
  [6] = "guanzhu_move_01"
}
function open_form()
  util_auto_show_hide_form(nx_current())
end
function on_main_form_init(self)
  self.Fixed = true
  self.CurrentGroup = RELATION_GROUP_ZONGLAN
  self.CurrentRelation = RELATION_TYPE_RENMAI
end
function util_addscene_to_scenebox(scenebox)
  local ini = nx_execute("util_functions", "get_ini", "ini\\sns\\sns_weather.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local ambient_red = ini:ReadInteger("light", "ambient_red", 0)
  local ambient_green = ini:ReadInteger("light", "ambient_green", 0)
  local ambient_blue = ini:ReadInteger("light", "ambient_blue", 0)
  local ambient_intensity = ini:ReadFloat("light", "ambient_intensity", 0)
  local sunglow_red = ini:ReadInteger("light", "sunglow_red", 0)
  local sunglow_green = ini:ReadInteger("light", "sunglow_green", 0)
  local sunglow_blue = ini:ReadInteger("light", "sunglow_blue", 0)
  local sunglow_intensity = ini:ReadFloat("light", "sunglow_intensity", 0)
  local sun_height = ini:ReadInteger("light", "sun_height", 0)
  local sun_azimuth = ini:ReadInteger("light", "sun_azimuth", 0)
  local point_light_red = ini:ReadInteger("light", "point_light_red", 0)
  local point_light_green = ini:ReadInteger("light", "point_light_green", 0)
  local point_light_blue = ini:ReadInteger("light", "point_light_blue", 0)
  local point_light_range = ini:ReadFloat("light", "point_light_range", 0)
  local point_light_intensity = ini:ReadFloat("light", "point_light_intensity", 0)
  local point_light_pos_x = ini:ReadFloat("light", "point_light_pos_x", 0)
  local point_light_pos_y = ini:ReadFloat("light", "point_light_pos_y", 0)
  local point_light_pos_z = ini:ReadFloat("light", "point_light_pos_z", 0)
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    local world = nx_value("world")
    scene = world:Create("Scene")
    scenebox.Scene = scene
    local weather = scene.Weather
    weather.FogEnable = false
    weather.AmbientColor = "255," .. nx_string(ambient_red) .. "," .. nx_string(ambient_green) .. "," .. nx_string(ambient_blue)
    weather.SunGlowColor = "255," .. nx_string(sunglow_red) .. "," .. nx_string(sunglow_green) .. "," .. nx_string(sunglow_blue)
    weather.SpecularColor = "255,196,196,196"
    weather.AmbientIntensity = ambient_intensity
    weather.SunGlowIntensity = sunglow_intensity
    weather.SpecularIntensity = 2
    local sun_height_rad = sun_height / 360 * math.pi * 2
    local sun_azimuth_rad = sun_azimuth / 360 * math.pi * 2
    scenebox.sun_height_rad = sun_height_rad
    scenebox.sun_azimuth_rad = sun_azimuth_rad
    weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
    scene.BackColor = scenebox.BackColor
    scene.EnableRealizeTempRT = false
    local camera = scene:Create("Camera")
    camera.AllowControl = false
    camera.Fov = 0.10416666666666667 * math.pi * 2
    scene.camera = camera
    scene:AddObject(camera, 0)
    local light_man = scene:Create("LightManager")
    scene.light_man = light_man
    scene.light_man = light_man
    scene:AddObject(light_man, 1)
    light_man.SunLighting = true
    local light = light_man:Create()
    scene.light = light
    light.Color = "255," .. nx_string(point_light_red) .. "," .. nx_string(point_light_green) .. "," .. nx_string(point_light_blue)
    light.Range = point_light_range
    light.Intensity = point_light_intensity
    light.Attenu0 = 0
    light.Attenu1 = 1
    light.Attenu2 = 0
    light:SetPosition(point_light_pos_x, point_light_pos_y, point_light_pos_z)
    local radius = 1.5
    scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
    scene.camera:SetAngle(0, 0, 0)
    scene:Load()
  end
  return true
end
function on_main_form_open(self)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  karmamgr:RefreshRelationList()
  refersh_npc_news()
  show_terrain(false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Desktop.Visible = true
  self.scenebox.Transparent = true
  if not util_addscene_to_scenebox(self.scenebox) then
  end
  local scene = self.scenebox.Scene
  local particle_man = nx_null()
  if not nx_is_valid(particle_man) then
    particle_man = scene:Create("ParticleManager")
    particle_man.TexturePath = "map\\tex\\particles\\"
    particle_man:Load()
    particle_man.EnableCacheIni = true
    scene:AddObject(particle_man, 100)
    scene.particle_man = particle_man
  end
  local game_effect = nx_create("GameEffect")
  if nx_is_valid(game_effect) then
    nx_bind_script(game_effect, "game_effect", "game_effect_init", scene)
    scene.game_effect = game_effect
    self.game_effect = game_effect
  end
  add_sns_control_to_scene(scene)
  scene.ClearZBuffer = true
  scene.camera:SetPosition(3, 4, 0)
  scene.camera:SetAngle(0, 0, 0)
  local balls = gui:Create("BalloonSet")
  balls.Name = "sns_balls"
  balls.Sort = true
  balls.Scene = scene
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  sns_manager.head_balls = balls
  sns_manager:ChangeSunParam(self.scenebox.sun_height_rad, self.scenebox.sun_azimuth_rad)
  self.groupbox_head:Add(balls)
  init_group_renmai()
  add_self_model("", "")
  nx_execute(nx_current(), "delay_create_operate", scene)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord("job_rec") then
    self.groupbox_buttons.Visible = false
  end
  change_form_size()
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  sns_manager:SetRelationType(group_id, RELATION_TYPE_RENMAI_SELF)
  sns_manager.NoShowDelete = false
  local scene = self.scenebox.Scene
  if nx_is_valid(scene) then
    local sns_control = scene.sns_control
    if not nx_is_valid(sns_control) then
      return
    end
    sns_control:SetCameraDirect(0, 3, 17, 0.3, 0, 0)
  end
  local btn_jianghu = self.btn_jianghu
  btn_jianghu.NormalImage = btn_jianghu.FocusImage
  local is_has = is_study_job()
  if not is_has then
    self.btn_life.Enabled = false
  end
  local new_note_form = nx_value("form_stage_main\\form_note\\form_new_note")
  if nx_is_valid(new_note_form) then
    new_note_form:Close()
  end
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) then
    form_renmai.lbl_no_man.Visible = false
  end
end
function open_show_geren(form)
  nx_pause(1)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_zonglan.Visible = false
  form.rbtn_geren.Checked = true
end
function delay_create_operate(scene)
  nx_pause(1)
  if not nx_is_valid(scene) then
    return false
  end
  if not nx_is_valid(scene.sns_control) then
    return false
  end
  scene.sns_control:CreateGloabeCameraEffect("scene_move_269a")
end
function on_main_form_close(self)
  close_sub_form()
  show_terrain(true)
  check_shortcut_ride()
  self.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_feed_info", "close_all_blog")
  nx_execute("form_stage_main\\form_main\\form_main_team", "update_team_panel")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_itemskill", "shortcut_itemskill_view")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_buff_common", "shortcut_buff_common_view")
  nx_execute("form_stage_main\\form_card\\form_card_skill", "show_form_cardskill")
  nx_execute("form_stage_main\\form_main\\form_main", "move_over")
  local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  local form_main = nx_value(GAME_GUI_MAIN)
  if nx_is_valid(form_sysinfo) and nx_is_valid(form_main) then
    form_main:ToBack(form_sysinfo)
  end
  nx_destroy(self)
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  local rbtn = form_main.rbtn_fight
  if rbtn.Checked ~= true then
    rbtn.Checked = true
  end
end
function on_form_main_shut(self)
  if nx_find_custom(self, "game_effect") and nx_is_valid(self.game_effect) then
    nx_destroy(self.game_effect)
  end
  local scene = self.scenebox.Scene
  if nx_is_valid(scene) and nx_find_custom(scene, "sns_control") then
    scene:Delete(scene.sns_control)
  end
  if nx_is_valid(scene) and nx_find_custom(scene, "game_effect") then
    if nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
    scene:Delete(scene.game_effect)
  end
  if nx_is_valid(scene) and nx_find_custom(scene, "sky") then
    scene:Delete(scene.sky)
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  if nx_is_valid(sns_manager) then
    local head_balls = sns_manager.head_balls
    nx_destroy(sns_manager)
  end
  if nx_is_valid(head_balls) then
    self.groupbox_head:Remove(head_balls)
    local gui = nx_value("gui")
    gui:Delete(head_balls)
  end
end
function add_ground(scene, red, green, blue)
  if not nx_find_custom(scene, "ground") or not nx_is_valid(scene.ground) then
    local ground = scene:Create("Model")
    ground.ModelFile = "obj\\effect_sns\\SNS_dimian01.xmod"
    ground:Load()
    ground:SetPosition(0, 0, 0)
    scene:AddObject(ground, 10)
    ground:Play()
    scene.ground = ground
  end
end
function set_visual_radius(scene, radius)
  local far_clip = 1000
  scene.FarClipDistance = far_clip
  local weather = scene.Weather
  if nx_is_valid(weather) then
    weather.FogStart = 100
    weather.FogEnd = 200
    weather.FogLinear = true
    weather.FogColor = "255,79,112,172"
    weather.FogExpColor = "255,79,112,172"
    weather.FogHeight = 300
    weather.FogHeightExp = 1
    weather.FogExp = true
    weather.FogDensity = 0.07
    scene.BackColor = "255,79,112,172"
    weather.FogEnable = true
  end
end
function add_sns_control_to_scene(scene)
  if not nx_is_valid(scene) then
    return
  end
  local sns_control = scene:Create("SnsControl")
  if not nx_is_valid(sns_control) then
    return
  end
  nx_bind_script(sns_control, nx_current(), "sns_control_init")
  sns_control.Camera = scene.camera
  sns_control.BaseAngleY = 4
  scene.sns_control = sns_control
  sns_control:Load()
  scene:AddObject(sns_control, 0)
  local sns_manager = nx_create("SnsManager")
  if nx_is_valid(sns_manager) then
    nx_set_value(SnsManagerCacheName, sns_manager)
  end
  nx_bind_script(sns_manager, nx_current(), "sns_manager_init")
  sns_manager.SceneID = scene
  sns_manager.SnsControlID = sns_control
  local group_main_id = sns_manager:AddRelationGroup(RELATION_GROUP_ZONGLAN)
  local relation_group_main = sns_manager:GetRelationGroup(group_main_id)
  relation_group_main.group_index = RELATION_GROUP_ZONGLAN
  relation_group_main:SetPos(0, 0, 0, 0)
  local index = relation_group_main:AddRelationType(SHOW_REGION_IN_CYCLE, SHOW_REGION_LINK)
  relation_group_main:SetRootEffectDist(index, 8)
  relation_group_main:SetRelationTypeColor(index, 136, 124, 88, 255)
  index = relation_group_main:AddRelationType(SHOW_REGION_IN_CYCLE, SHOW_REGION_LINK)
  relation_group_main:SetRootEffectDist(index, 8)
  relation_group_main:SetRelationTypeColor(index, 136, 109, 88, 255)
  index = relation_group_main:AddRelationType(SHOW_REGION_IN_CYCLE, SHOW_REGION_LINK)
  relation_group_main:SetRootEffectDist(index, 8)
  relation_group_main:SetRelationTypeColor(index, 118, 141, 118, 255)
  relation_group_main.ShowTree = true
  relation_group_main.MaxRolePerLine = 5
  relation_group_main.CameraHeight = 1.2
  relation_group_main.CameraAngleX = 0
  relation_group_main.BaseCameraRadius = -3
  local clip_angle = math.pi * 2 / RELATION_TYPE_ZONGLAN_MAX
  local distance = 15
  local cur_angle = clip_angle * RELATION_TYPE_RENMAI
  local x = math.sin(cur_angle) * distance
  local z = math.cos(cur_angle) * distance
  local sec_count = 6
  local relation_group_renmai = add_group(sns_manager, relation_group_main, RELATION_TYPE_RENMAI, RELATION_GROUP_RENMAI, x, 0, z, 0, sec_count, SHOW_REGION_RECT, SHOW_REGION_IN_CYCLE)
  relation_group_renmai.ShowTree = true
  relation_group_renmai.MaxRolePerLine = 5
  relation_group_renmai.CameraHeight = 3
  relation_group_renmai.CameraAngleX = 0.3
  relation_group_renmai.BaseCameraRadius = (sec_count - 4) * 0.2 - 3 + 10
  relation_group_renmai:RelationPrepare()
end
function add_group(sns_manager, group_main, mian_area_id, group_index, x, y, z, o, area_num, area_type, region_type)
  if nx_number(area_num) == 0 then
    return
  end
  local group_id = sns_manager:AddRelationGroup(group_index)
  local relation_group = sns_manager:GetRelationGroup(group_id)
  if not nx_is_valid(relation_group) then
    return
  end
  relation_group.group_index = group_index
  relation_group:SetPos(x, y, z, o)
  group_main:SetLinkGroup(mian_area_id, relation_group)
  for i = 1, nx_number(area_num) do
    local index = relation_group:AddRelationType(region_type, area_type)
    relation_group:SetRootEffectDist(index, 8)
    relation_group:SetBackEffectName(index, BACK_EFFECT_NAME[i])
    relation_group:SetRelationTypeColor(index, 124, 131, 98, 0)
    if region_type == SHOW_REGION_IN_REGION then
      relation_group:SetRelationPos(index, 0, 0, 0, 0)
    end
  end
  return relation_group
end
function sns_manager_init(sns_manager)
  nx_callback(sns_manager, "on_focus_change", "on_focus_change")
  nx_callback(sns_manager, "on_relation_type_change", "on_relation_type_change")
  nx_callback(sns_manager, "on_focus_end", "on_focus_end")
end
function on_relation_type_change_event(new_group_id, new_relation_type)
  nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "on_relation_type_change_event", new_group_id, new_relation_type)
end
function on_focus_change_event(group_id, relation_type, index, name)
  if nx_int(group_id) < nx_int(0) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "on_focus_change_event", group_id, relation_type, index, name)
end
function on_relation_type_change(sns_manager, old_group_id, old_relation_type, new_group_id, new_relation_type)
  close_sub_form()
  nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_form", true)
  on_relation_type_change_event(new_group_id, new_relation_type)
end
function on_focus_change(sns_manager, group_id, relation_type, index, name)
  on_focus_change_event(group_id, relation_type, index, name)
end
function on_focus_end(sns_manager, group_id, relation_type)
  on_relation_type_change_event(group_id, relation_type)
end
function get_form_index(group_id)
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local relation_group = sns_manager:GetRelationGroup(group_id)
  if not nx_is_valid(relation_group) then
    return
  end
  if nx_find_custom(relation_group, "group_index") then
    group_index = relation_group.group_index
  end
  local index = 0
  if group_index >= 0 and group_index <= 3 then
    index = group_index + 1
  elseif group_index >= 8 and group_index <= 20 then
    index = 2
  elseif group_index >= 70 then
    index = 3
  end
  return index
end
function sns_control_init(sns_control)
  sns_control.MaxDistance = 10
  sns_control.MinDistance = 1
end
function add_actor2_to_scene(scene, actor2, x, y, z, orient)
  if not nx_is_valid(scene) or not nx_is_valid(actor2) then
    return false
  end
  nx_execute(nx_current(), "show_role_model", scene, actor2, x, y, z, orient)
end
function show_terrain(show)
  if show then
    nx_execute("gui", "gui_open_closedsystem_form")
  else
    nx_execute("gui", "gui_close_allsystem_form")
  end
  local form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(form_chat) then
    if not show then
      form_chat.Visible = true
      local gui = nx_value("gui")
      gui.Desktop:ToFront(form_chat)
      nx_execute("form_stage_main\\form_main\\form_laba_info", "set_all_trumpet_form_visible", false)
    else
      nx_execute("form_stage_main\\form_main\\form_laba_info", "set_all_trumpet_form_visible", true)
    end
  end
  local world = nx_value("world")
  local scene = world.MainScene
  local terrain = scene.terrain
  scene.postprocess_man.Visible = show
  if not nx_is_valid(terrain) then
    return
  end
  terrain.GroundVisible = show
  terrain.VisualVisible = show
  terrain.WaterVisible = show
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.Pause = not show
  game_control.AllowControl = show
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.groupbox_relation2.Left = 0
  form.groupbox_relation2.Width = form.Width
  form.groupbox_relation2.Top = form.Top + form.Height - form.groupbox_relation2.Height
  form.scenebox.Left = 0
  form.scenebox.Top = 0
  form.scenebox.Width = form.Width
  form.scenebox.Height = form.Height - form.groupbox_rbtn.Height
  form.lbl_background.Left = 0
  form.lbl_background.Top = 0
  form.lbl_background.Width = form.Width
  form.lbl_background.Height = form.Height - form.groupbox_relation2.Height
  if nx_find_custom(form, "lbl_top_back") then
    form.lbl_top_back.Left = form.scenebox.Left
    form.lbl_top_back.Top = form.scenebox.Top
    form.lbl_top_back.Height = form.scenebox.Height
    form.lbl_top_back.Width = form.scenebox.Width
  end
  if nx_find_custom(form, "gb_front") then
    form.gb_front.Left = 0
    form.gb_front.Top = 0
    form.gb_front.Width = form.Width
    form.gb_front.Height = form.Height
    form.gb_front.BlendAlpha = 150
  end
  form.groupbox_head.Left = form.scenebox.Left
  form.groupbox_head.Top = form.scenebox.Top
  form.groupbox_head.Width = form.scenebox.Width
  form.groupbox_head.Height = form.scenebox.Height
  for i = 1, table.getn(str_group) do
    local form = nx_value("form_stage_main\\form_relation\\form_relation_" .. str_group[i])
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_relation\\form_relation_" .. str_group[i], "change_form_size")
    end
  end
end
function init_group_zonglan()
  init_area_renmai()
  init_area_shili()
end
function init_area_renmai()
  local list = {}
  local player = get_client_player()
  if nx_is_valid(player) then
    local nums = 0
    local is_finished = false
    local is_add_name = false
    local table_name = FRIEND_REC
    local rows = player:GetRecordRows(table_name)
    if 0 < rows and not is_finished then
      rows = math.min(5 - nums, rows)
      for i = 0, rows - 1 do
        local playerInfo = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_MODEL))
        table.insert(list, playerInfo)
        nums = nums + 1
      end
      if nums == 5 then
        is_finished = true
      end
    end
    table_name = BUDDY_REC
    rows = player:GetRecordRows(table_name)
    if 0 < rows and not is_finished then
      rows = math.min(5 - nums, rows)
      for i = 0, rows - 1 do
        local playerInfo = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_MODEL))
        table.insert(list, playerInfo)
        nums = nums + 1
      end
      if nums == 5 then
        is_finished = true
      end
    end
    table_name = ENEMY_REC
    rows = player:GetRecordRows(table_name)
    if 0 < rows and not is_finished then
      rows = math.min(5 - nums, rows)
      for i = 0, rows - 1 do
        local playerInfo = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_MODEL))
        table.insert(list, playerInfo)
        nums = nums + 1
      end
      if nums == 5 then
        is_finished = true
      end
    end
    table_name = BLOOD_REC
    rows = player:GetRecordRows(table_name)
    if 0 < rows and not is_finished then
      rows = math.min(5 - nums, rows)
      for i = 0, rows - 1 do
        local playerInfo = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_MODEL))
        table.insert(list, playerInfo)
        nums = nums + 1
      end
      if nums == 5 then
        is_finished = true
      end
    end
    table_name = ATTENTION_REC
    rows = player:GetRecordRows(table_name)
    if 0 < rows and not is_finished then
      rows = math.min(5 - nums, rows)
      for i = 0, rows - 1 do
        local playerInfo = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_MODEL))
        table.insert(list, playerInfo)
        nums = nums + 1
      end
      if nums == 5 then
        is_finished = true
      end
    end
    table_name = JIESHI_REC
    rows = player:GetRecordRows(table_name)
    if 0 < rows and not is_finished then
      rows = math.min(5 - nums, rows)
      for i = 0, rows - 1 do
        local playerInfo = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_MODEL))
        table.insert(list, playerInfo)
        nums = nums + 1
      end
      if nums == 5 then
        is_finished = true
      end
    end
    table_name = "rec_npc_relation"
    rows = player:GetRecordRows(table_name)
    if 0 < rows and not is_finished then
      for i = 0, rows - 1 do
        local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
        local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
        if nx_number(npc_relation) == 0 or nx_number(npc_relation) == 1 then
          table.insert(list, npc_id)
          nums = nums + 1
        end
        if nums == 5 then
          is_finished = true
          break
        end
      end
    end
    table_name = "rec_npc_attention"
    rows = player:GetRecordRows(table_name)
    if 0 < rows and not is_finished then
      for i = 0, rows - 1 do
        local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
        table.insert(list, npc_id)
        nums = nums + 1
        if nums == 5 then
          is_finished = true
          break
        end
      end
    end
    add_model_to_renmai(RELATION_GROUP_ZONGLAN, RELATION_TYPE_RENMAI, list)
    if not is_finished then
      if nums == 0 then
        local npc_list = {}
        local area_name = util_text("ui_sns_new_" .. str_group[RELATION_TYPE_RENMAI + 2])
        add_npc_list_model(RELATION_GROUP_ZONGLAN, RELATION_TYPE_RENMAI, npc_list, area_name, 0)
      else
        add_black_model(RELATION_GROUP_ZONGLAN, RELATION_TYPE_RENMAI, 5 - nums, "ZONGLAN")
      end
    end
  end
end
function find_shili_list()
  local shili_id_list = {}
  local index = 1
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  if READ_ALL_SHILI == 1 then
    for i = SHILI_MIN, SHILI_MAX do
      shili_id_list[index] = i
      index = index + 1
    end
  else
    for i = SHILI_MIN, SHILI_MAX do
      if not is_unopened_shili(i) then
        if 0 <= player:FindRecordRow("GroupKarmaRec", 0, i, 0) then
          shili_id_list[index] = i
          index = index + 1
        else
          local npc_list_id = karmamgr:GetActiveGroupNpcNameList(i)
          if 0 < table.getn(npc_list_id) then
            shili_id_list[index] = i
            index = index + 1
          end
        end
      end
    end
  end
  return shili_id_list
end
function is_unopened_shili(shili_id)
  local count = table.getn(unopened_list)
  for i = 1, count do
    if nx_number(shili_id) == nx_number(unopened_list[i]) then
      return true
    end
  end
  return false
end
function init_area_shili()
  local npc_list = {}
  local index = 1
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  for i = SHILI_MIN, SHILI_MAX do
    local npc_list_id = karmamgr:GetActiveGroupNpcNameList(i)
    for i = 1, table.getn(npc_list_id) do
      npc_list[index] = npc_list_id[i]
      index = index + 1
    end
  end
  local area_name = util_text("ui_sns_new_" .. str_group[RELATION_TYPE_SHILI + 2])
  add_npc_list_model(RELATION_GROUP_ZONGLAN, RELATION_TYPE_SHILI, npc_list, area_name, 0)
end
function init_group_renmai()
  get_player_modle(RELATION_GROUP_RENMAI, RELATION_TYPE_FRIEND, FRIEND_REC, false)
  get_player_modle(RELATION_GROUP_RENMAI, RELATION_TYPE_BUDDY, BUDDY_REC, false)
  get_player_modle(RELATION_GROUP_RENMAI, RELATION_TYPE_ENEMY, ENEMY_REC, false)
  get_player_modle(RELATION_GROUP_RENMAI, RELATION_TYPE_BLOOD, BLOOD_REC, false)
  get_player_modle(RELATION_GROUP_RENMAI, RELATION_TYPE_ATTENTION, ATTENTION_REC, false)
end
function init_group_shili()
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local shili_list = find_shili_list()
  for i = 1, table.getn(shili_list) do
    add_shili_model(RELATION_GROUP_SHILI, i - 1, nx_int(shili_list[i]), true)
    add_shili_model(70 + i - 1, 0, nx_int(shili_list[i]), false)
  end
end
function add_shili_model(group_index, relation_type, shili_id, is_zonglan)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  if is_zonglan == true then
    local npc_list = {}
    if nx_int(shili_id) > nx_int(SHILI_MAX) then
      local is_jindi = nx_execute("form_stage_main\\form_relation\\form_clone_describe", "get_show_clonenpc_model", shili_id)
      if is_jindi == true then
        local strNpcList = karmamgr:GetGroupNpc(nx_int(shili_id))
        local table_npc = util_split_string(nx_string(strNpcList), ";")
        for i = 1, table.getn(table_npc) do
          local table_npc_info = util_split_string(nx_string(table_npc[i]), ",")
          table.insert(npc_list, table_npc_info[1])
        end
      end
    else
      npc_list = karmamgr:GetActiveGroupNpcNameList(shili_id)
    end
    local shili_name = nx_widestr(util_text("group_karma_" .. nx_string(shili_id)))
    local model_sex = 0
    if shili_id == 1 then
      model_sex = 1
    elseif shili_id == 3 then
      model_sex = 2
    end
    add_npc_list_model(group_index, relation_type, npc_list, shili_name, model_sex)
    return
  end
  local strNpcList = karmamgr:GetGroupNpc(nx_int(shili_id))
  local table_npc = util_split_string(nx_string(strNpcList), ";")
  local npc_num = table.getn(table_npc)
  for i = 1, npc_num do
    local table_npc_info = util_split_string(nx_string(table_npc[i]), ",")
    add_npc_model(group_index, relation_type, table_npc_info[1], "")
  end
end
function is_relation_npc(npc_id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return false
  end
  if npc_id == "" or npc_id == nil then
    return false
  end
  local shili_id = karmamgr:GetGroupKarma(npc_id)
  if nx_int(shili_id) > nx_int(SHILI_MAX) then
    local is_jindi = nx_execute("form_stage_main\\form_relation\\form_clone_describe", "get_show_clonenpc_model", nx_int(shili_id))
    return is_jindi
  end
  local player = get_client_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindRecord("rec_npc_relation") and not player:FindRecord("rec_npc_attention") then
    return false
  end
  local rows_1 = player:GetRecordRows("rec_npc_relation")
  local rows_2 = player:GetRecordRows("rec_npc_attention")
  if rows_1 == 0 and rows_2 == 0 then
    return false
  end
  if 0 <= player:FindRecordRow("rec_npc_relation", 0, nx_string(npc_id), 0) then
    return true
  end
  if 0 <= player:FindRecordRow("rec_npc_attention", 0, nx_string(npc_id), 0) then
    return true
  end
  return false
end
function get_player_modle(group_id, relation_type, table_name, is_zonglan)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if is_zonglan == true then
    rows = math.min(4, rows)
  end
  for i = 0, rows - 1 do
    local playerName = nx_widestr(player:QueryRecord(table_name, i, FRIEND_REC_NAME))
    local playerInfo = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_MODEL))
    local player_menpai = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_MENPAI))
    add_player_model(group_id, relation_type, playerName, playerInfo, nx_widestr(player_menpai), is_zonglan)
  end
  local form_relationship = nx_value(nx_current())
  if not nx_is_valid(form_relationship) then
    return
  end
  if table_name == FRIEND_REC then
    form_relationship.rbtn_relation2_friend.model_count = rows
  elseif table_name == BUDDY_REC then
    form_relationship.rbtn_relation2_buddy.model_count = rows
  elseif table_name == ENEMY_REC then
    form_relationship.rbtn_relation2_enemy.model_count = rows
  elseif table_name == BLOOD_REC then
    form_relationship.rbtn_relation2_blood.model_count = rows
  elseif table_name == ATTENTION_REC then
    form_relationship.rbtn_relation2_attention.model_count = rows
  end
end
function get_teacher_player_modle(group_id, relation_type, table_name, is_zonglan)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if is_zonglan == true then
    rows = math.min(4, rows)
  end
  local player_menpai = util_text(nx_string(player:QueryProp("School")))
  for i = 0, rows - 1 do
    local playerName = nx_widestr(player:QueryRecord(table_name, i, PUPIL_REC_NAME))
    local playerInfo = nx_string(player:QueryRecord(table_name, i, PUPIL_REC_MODEL))
    if nx_widestr(playerInfo) ~= nx_widestr("") then
      add_player_model(group_id, relation_type, playerName, playerInfo, nx_widestr(player_menpai), is_zonglan)
    end
  end
  jm_rows = player:GetRecordRows(PUPIL_JINGMAI_REC)
  for i = 0, jm_rows - 1 do
    local playerName = player:QueryRecord(PUPIL_JINGMAI_REC, i, PUPIL_REC_JM_NAME)
    local playerInfo = nx_string(player:QueryRecord(PUPIL_JINGMAI_REC, i, PUPIL_REC_JM_ROLE_MODEL))
    if nx_widestr(playerInfo) ~= nx_widestr("") then
      add_player_model(group_id, relation_type, playerName, playerInfo, nx_widestr(player_menpai), is_zonglan)
    end
  end
  local count = rows + jm_rows
  if count < 4 and is_zonglan == true then
    add_black_model(group_id, relation_type, 5 - count, table_name)
  end
end
function add_npc_friend_modle(group_id, relation_type, is_zonglan)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local table_name = "rec_npc_relation"
  local friend_num = 0
  local rows = player:GetRecordRows(table_name)
  for i = 0, rows - 1 do
    local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
    local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
    if nx_number(npc_relation) == 0 then
      if is_zonglan and friend_num < 5 then
        add_npc_model(group_id, relation_type, npc_id, "")
        friend_num = friend_num + 1
      elseif not is_zonglan then
        add_npc_model(group_id, relation_type, npc_id, "")
        friend_num = friend_num + 1
      end
    end
  end
  if is_zonglan and friend_num < 5 then
    add_black_model(group_id, relation_type, 5 - friend_num, "npc_haoyou")
  end
end
function add_npc_buddy_modle(group_id, relation_type, is_zonglan)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local table_name = "rec_npc_relation"
  local buddy_num = 0
  local rows = player:GetRecordRows(table_name)
  for i = 0, rows - 1 do
    local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
    local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
    if nx_number(npc_relation) == 1 then
      if is_zonglan and buddy_num < 5 then
        add_npc_model(group_id, relation_type, npc_id, "")
        buddy_num = buddy_num + 1
      elseif not is_zonglan then
        add_npc_model(group_id, relation_type, npc_id, "")
        buddy_num = buddy_num + 1
      end
    end
  end
  if is_zonglan and buddy_num < 5 then
    add_black_model(group_id, relation_type, 5 - buddy_num, "npc_zhiyou")
  end
end
function add_npc_attention_modle(group_id, relation_type, is_zonglan)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local table_name = "rec_npc_attention"
  local num = 0
  local rows = player:GetRecordRows(table_name)
  for i = 0, rows - 1 do
    local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
    if is_zonglan and num < 5 then
      add_npc_model(group_id, relation_type, npc_id, "")
      num = num + 1
    elseif not is_zonglan then
      add_npc_model(group_id, relation_type, npc_id, "")
      num = num + 1
    end
  end
  if is_zonglan and num < 5 then
    add_black_model(group_id, relation_type, 5 - num, "npc_guanzhu")
  end
end
function add_model_to_renmai(group_index, relation_type, list)
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(group_index)
  local relation_group = sns_manager:GetRelationGroup(group_id)
  local nums = table.getn(list)
  for i = 0, nums do
    local model = list[i]
    if is_relation_npc(model) == true then
      local resource = ItemQuery:GetItemPropByConfigID(nx_string(model), nx_string("Resource"))
      local npc_info = "n" .. nx_string(resource)
      if i == 1 then
        local name = util_text("ui_sns_new_" .. str_group[RELATION_TYPE_RENMAI + 2])
        local index = relation_group:AddSnsObject(relation_type, nx_widestr(name), nx_string(npc_info), "")
        if index ~= -1 then
          relation_group:SetHeadBalloonType(relation_type, index, 1)
          relation_group:SetSnsObjectState(relation_type, index, 0)
          relation_group:CreateSnsObj(relation_type, index)
        end
      else
        local index = relation_group:AddSnsObject(relation_type, nx_widestr(model), npc_info, "")
        if index ~= -1 then
          relation_group:SetSnsObjectState(relation_type, index, 0)
          relation_group:SetHeadBalloonType(relation_type, index, 0)
          relation_group:CreateSnsObj(relation_type, index)
        end
      end
    elseif i == 1 then
      local name = util_text("ui_sns_new_" .. str_group[RELATION_TYPE_RENMAI + 2])
      local index = relation_group:AddSnsObject(relation_type, nx_widestr(name), nx_string(model), "")
      if index ~= -1 then
        relation_group:SetHeadBalloonType(relation_type, index, 1)
        relation_group:SetSnsObjectState(relation_type, index, 0)
        relation_group:CreateSnsObj(relation_type, index)
      end
    else
      local index = relation_group:AddSnsObject(relation_type, nx_widestr("black_model_" .. i), nx_string(model), "")
      if index ~= -1 then
        relation_group:SetHeadBalloonType(relation_type, index, 0)
        relation_group:SetSnsObjectState(relation_type, index, 0)
        relation_group:CreateSnsObj(relation_type, index)
      end
    end
  end
end
function add_black_model(group_index, relation_type, nums, name)
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(group_index)
  local relation_group = sns_manager:GetRelationGroup(group_id)
  local black_model_list = {
    "nnpc\\b_sns_npc",
    "nnpc\\g_sns_npc"
  }
  local is_add = false
  for i = 1, nums do
    black_model = black_model_list[math.random(2)]
    local index = relation_group:AddSnsObject(relation_type, nx_widestr(name .. nx_string(i)), nx_string(black_model), "")
    if index ~= -1 then
      relation_group:SetHeadBalloonType(relation_type, index, 0)
      relation_group:SetSnsObjectState(relation_type, index, 1)
      relation_group:CreateSnsObj(relation_type, index)
    end
  end
end
function add_self_model(menpai, role_info)
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return
  end
  local menpai = game_player:QueryProp("School")
  local name = client_player:QueryProp("Name")
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local role_info = sns_manager:GetMainPlayerShowInfo()
  add_player_model(RELATION_GROUP_RENMAI, RELATION_TYPE_RENMAI_SELF, name, nx_string(role_info), nx_widestr(menpai))
end
function add_npc_model(group_index, relation_type, npc_id, add_info, flag)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(group_index)
  local relation_group = sns_manager:GetRelationGroup(group_id)
  if not nx_is_valid(relation_group) then
    return
  end
  local resource = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Resource"))
  local npc_info = "n" .. nx_string(resource)
  local index = relation_group:AddSnsObject(relation_type, nx_widestr(npc_id), npc_info, "")
  if index == -1 then
    return
  end
  if is_relation_npc(npc_id) == true then
    relation_group:SetSnsObjectState(relation_type, index, 0)
    relation_group:SetHeadBalloonType(relation_type, index, 2)
  else
    relation_group:SetSnsObjectState(relation_type, index, 1)
    relation_group:SetHeadBalloonType(relation_type, index, 0)
  end
  if flag ~= nil and flag then
    relation_group:SetSnsObjectState(relation_type, index, 0)
    relation_group:SetHeadBalloonType(relation_type, index, 0)
  end
end
function add_npc_list_model(group_index, relation_type, npc_list, area_name, model_sex)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(group_index)
  local relation_group = sns_manager:GetRelationGroup(group_id)
  if not nx_is_valid(relation_group) then
    return
  end
  local npc_num = table.getn(npc_list)
  local black_model_list = {
    "nnpc\\b_sns_npc",
    "nnpc\\g_sns_npc"
  }
  local black_model
  if nx_number(model_sex) ~= nx_number(0) then
    black_model = black_model_list[nx_number(model_sex)]
  end
  if npc_num < 5 then
    for i = 1, npc_num do
      local npc_id = npc_list[i]
      if npc_id ~= "" then
        local resource = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Resource"))
        local npc_name = util_text(nx_string(npc_id))
        local npc_info = "n" .. nx_string(resource)
        if i == 1 then
          local index = relation_group:AddSnsObject(relation_type, nx_widestr(area_name), npc_info, "")
          if index ~= -1 then
            relation_group:SetHeadBalloonType(relation_type, index, 1)
            relation_group:SetSnsObjectState(relation_type, index, 0)
            relation_group:CreateSnsObj(relation_type, index)
          end
        else
          local index = relation_group:AddSnsObject(relation_type, nx_widestr(npc_name), npc_info, "")
          if index ~= -1 then
            relation_group:SetHeadBalloonType(relation_type, index, 0)
            relation_group:SetSnsObjectState(relation_type, index, 0)
            relation_group:CreateSnsObj(relation_type, index)
          end
        end
      end
    end
    for i = npc_num + 1, 5 do
      if nx_number(model_sex) == nx_number(0) then
        black_model = black_model_list[math.random(2)]
      end
      if i == 1 then
        local index = relation_group:AddSnsObject(relation_type, nx_widestr(area_name), nx_string(black_model), "")
        if index ~= -1 then
          relation_group:SetHeadBalloonType(relation_type, index, 1)
          relation_group:SetSnsObjectState(relation_type, index, 1)
          relation_group:CreateSnsObj(relation_type, index)
        end
      else
        local index = relation_group:AddSnsObject(relation_type, nx_widestr("black_model_" .. i), nx_string(black_model), "")
        if index ~= -1 then
          relation_group:SetHeadBalloonType(relation_type, index, 0)
          relation_group:SetSnsObjectState(relation_type, index, 1)
          relation_group:CreateSnsObj(relation_type, index)
        end
      end
    end
  else
    for i = 1, 5 do
      local npc_id = npc_list[i]
      if npc_id ~= "" then
        local resource = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Resource"))
        local npc_name = util_text(nx_string(npc_id))
        local npc_info = "n" .. nx_string(resource)
        if i == 1 then
          local index = relation_group:AddSnsObject(relation_type, nx_widestr(area_name), npc_info, "")
          if index ~= -1 then
            relation_group:SetHeadBalloonType(relation_type, index, 1)
            relation_group:SetSnsObjectState(relation_type, index, 0)
            relation_group:CreateSnsObj(relation_type, index)
          end
        else
          local index = relation_group:AddSnsObject(relation_type, nx_widestr(npc_name), npc_info, "")
          if index ~= -1 then
            relation_group:SetHeadBalloonType(relation_type, index, 0)
            relation_group:SetSnsObjectState(relation_type, index, 0)
            relation_group:CreateSnsObj(relation_type, index)
          end
        end
      end
    end
  end
end
function add_player_model(group_index, relation_type, player_name, player_info, add_info, flag)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local menpai = karmamgr:ParseColValue(FRIEND_REC_MENPAI, nx_string(add_info))
  if nx_string(menpai) == "" then
    add_info = gui.TextManager:GetText("ui_task_school_null")
  else
    add_info = gui.TextManager:GetText(menpai)
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(group_index)
  local relation_group = sns_manager:GetRelationGroup(group_id)
  if not nx_is_valid(relation_group) then
    return
  end
  local index = relation_group:AddSnsObject(relation_type, nx_widestr(player_name), player_info, add_info)
  if flag ~= nil and flag then
    relation_group:SetHeadBalloonType(relation_type, index, 0)
    relation_group:SetSnsObjectState(relation_type, index, 0)
    relation_group:CreateSnsObj(relation_type, index)
  end
  return index
end
function interface_delete_player_model(group_index, relation_type, player_name)
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(group_index)
  local relation_group = sns_manager:GetRelationGroup(group_id)
  if not nx_is_valid(relation_group) then
    return
  end
  relation_group:DeleteObject(relation_type, nx_widestr(player_name))
end
function focus_player_model(group_index, relation_type, player_name)
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(group_index)
  if nx_number(group_id) == nx_number(-1) then
    return
  end
  sns_manager:SetRelationType(group_id, relation_type)
  sns_manager:FocusPlayer(group_id, relation_type, nx_widestr(player_name))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_news")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_size_change()
  change_form_size()
end
function on_rbtn_renmai_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    goto_group(RELATION_GROUP_RENMAI)
    local scene = form.scenebox.Scene
    if nx_is_valid(scene) then
      local sns_control = scene.sns_control
      if not nx_is_valid(sns_control) then
        return
      end
      sns_control:SetCameraDirect(0, 3, 17, 0.3, 0, 0)
    end
    resume_btn_image()
    btn.Checked = true
  end
end
function on_rbtn_shili_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    goto_group(RELATION_GROUP_SHILI)
    resume_btn_image()
    btn.Checked = true
  end
end
function on_rbtn_menpai_checked_changed(btn)
end
function on_rbtn_bangpai_checked_changed(btn)
end
function on_rbtn_jindi_checked_changed(btn)
end
function on_rbtn_fujin_checked_changed(btn)
end
function on_rbtn_geren_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked == true then
    goto_group(RELATION_GROUP_SELF)
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local player_name = client_player:QueryProp("Name")
    focus_player_model(RELATION_GROUP_SELF, 0, player_name)
    local sns_manager = nx_value(SnsManagerCacheName)
    if not nx_is_valid(sns_manager) then
      return
    end
    local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_SELF)
    on_focus_change(sns_manager, group_id, 0, 0, player_name)
    resume_btn_image()
    btn.Checked = true
  end
end
function on_rbtn_shijie_checked_changed(btn)
  if btn.Checked == true then
    close_sub_form()
    local sns_manager = nx_value(SnsManagerCacheName)
    local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GPOUP_WORLD)
    if nx_number(group_id) == nx_number(-1) then
      return
    end
    sns_manager:SetRelationType(group_id, RELATION_TYPE_WORLD_A)
    nx_execute("form_stage_main\\form_relation\\form_relation_world", "show_form", true)
    resume_btn_image()
    btn.Checked = true
    local helper_id = nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "get_cur_helper")
    local stage = nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "get_cur_stage")
    if nx_string(helper_id) == nx_string("karma_help_04") and nx_string(stage) == nx_string("2") then
      return
    end
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function close_sub_form()
  for i = 1, table.getn(str_group) do
    local form = nx_value("form_stage_main\\form_relation\\form_relation_" .. str_group[i])
    if nx_is_valid(form) then
      form:Close()
    end
  end
  local form_present = nx_value("form_stage_main\\form_present_to_npc")
  if nx_is_valid(form_present) and form_present.Visible then
    form_present:Close()
    nx_destroy(form_present)
  end
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", false)
  nx_execute("form_stage_main\\form_relation\\form_feed_info", "close_all_blog")
  local enchou_form = nx_value("form_stage_main\\form_relation\\form_relation_enchou")
  if nx_is_valid(enchou_form) then
    enchou_form:Close()
  end
end
function resume_btn_image()
  local form_ship = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form_ship) then
    form_ship.rbtn_renmai.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_rm_out1.png"
    form_ship.rbtn_shili.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_sl_out1.png"
    form_ship.rbtn_fujin.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_fj_out.png"
    form_ship.rbtn_geren.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_gr_out1.png"
  end
end
function goto_group(group_index, area_index)
  local sns_manager = nx_value("sns_manager_cache")
  local group_id = sns_manager:GetGroupIdByDefineIndex(group_index)
  if nx_number(group_id) == nx_number(-1) then
    return
  end
  show_title()
  if nx_string(area_index) == "" then
    area_index = 0
  end
  sns_manager:SetRelationType(group_id, nx_int(area_index))
end
function on_btn_return_relationtype_click(btn)
  local form_world = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if nx_is_valid(form_world) then
    local sns_manager = nx_value(SnsManagerCacheName)
    if nx_is_valid(sns_manager) then
      sns_manager:InWorld()
    end
  end
  local form_player = nx_value("form_stage_main\\form_relation\\form_player_info")
  if nx_is_valid(form_player) then
    nx_destroy(form_player)
  end
  local form = btn.ParentForm
  local sns_manager = nx_value(SnsManagerCacheName)
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) then
    sns_manager:SetRelationType(RELATION_GROUP_RENMAI, form_renmai.relation_type)
    on_relation_type_change_event(RELATION_GROUP_RENMAI, form_renmai.relation_type)
  end
end
function check_shortcut_ride()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local mount = client_player:QueryProp("Mount")
  local muliti_ride = client_player:QueryProp("RideLinkState")
  local form_main_shortcut_ride = nx_value("form_stage_main\\form_main\\form_main_shortcut_ride")
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  if nx_is_valid(form_main_shortcut_ride) then
    if string.len(mount) == 0 or mount == 0 then
      if 0 < muliti_ride then
        form_main_shortcut_ride.Visible = true
        shortcut_grid.Visible = false
      else
        form_main_shortcut_ride.Visible = false
        shortcut_grid.Visible = true
      end
    else
      shortcut_grid.Visible = false
      form_main_shortcut_ride.Visible = true
    end
  end
  local buff_common_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_buff_common")
  if nx_is_valid(buff_common_grid) and buff_common_grid.Visible == true and buff_common_grid.isclose_shortgrid == 0 then
    shortcut_grid.Visible = false
  end
end
function show_role_model(scene, actor2, x, y, z, orient)
  local game_visual = nx_value("game_visual")
  local role_type = game_visual:QueryRoleType(actor2)
  if role_type == 2 then
    local face = actor2.face
    if face == nil then
      return
    end
  end
  nx_pause(0)
  local role_composite = nx_value("role_composite")
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(actor2) or not nx_is_valid(sns_manager) then
    return false
  end
  if role_type == 2 then
    local actor_role = get_actor_role(actor2)
    if not nx_is_valid(actor_role) then
      return false
    end
    while not actor_role.LoadFinish do
      nx_pause(0.5)
      if not nx_is_valid(actor_role) or not nx_is_valid(scene) then
        break
      end
      if not sns_manager:IsShowNow(actor2.group_id, actor2.relation_type, actor2.obj_index) then
        scene:Delete(actor2)
        return false
      end
    end
    if not nx_is_valid(actor2) then
      return false
    end
    local face_actor2 = get_role_face(actor2)
    while nx_is_valid(face_actor2) and not face_actor2.LoadFinish do
      nx_pause(0.5)
      if not sns_manager:IsShowNow(actor2.group_id, actor2.relation_type, actor2.obj_index) then
        scene:Delete(actor2)
        return false
      end
    end
    if nx_is_valid(face_actor2) then
      role_composite:SetPlayerFaceDetial(face_actor2, nx_string(actor2.face), nx_int(actor2.sex), actor2)
    end
    role_composite:refresh_body(actor2, true)
    local skin_info = {
      [1] = {link_name = "face", model_name = ""},
      [2] = {
        link_name = "impress",
        model_name = actor2.impress
      },
      [3] = {
        link_name = "hat",
        model_name = actor2.hat
      },
      [4] = {
        link_name = "cloth",
        model_name = actor2.cloth
      },
      [5] = {
        link_name = "pants",
        model_name = actor2.pants
      },
      [6] = {
        link_name = "shoes",
        model_name = actor2.shoes
      }
    }
    for i, info in pairs(skin_info) do
      if info.model_name ~= nil and 0 < string.len(nx_string(info.model_name)) then
        if "Cloth" == prop or "cloth" == prop then
          link_cloth_skin(role_composite, actor2, info.model_name)
        else
          role_composite:LinkSkin(actor2, info.link_name, info.model_name .. ".xmod", false)
        end
      end
    end
    role_composite:LinkSkin(actor2, "cloth_h", nx_string(actor2.cloth) .. "_h" .. ".xmod", false)
    local action_module = nx_value("action_module")
    action_module:DoAction(actor2, "logoin_stand")
    if actor2.weapon ~= "" then
      game_visual:SetRoleWeaponName(actor2, actor2.weapon)
      role_composite:RefreshWeapon(actor2)
    end
  else
  end
  if not nx_is_valid(actor2) or not nx_is_valid(scene) then
    return
  end
  actor2:SetPosition(x, y, z)
  actor2:SetAngle(0, orient, 0)
  while not actor2.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(actor2) or not nx_is_valid(scene) then
      break
    end
    if not sns_manager:IsShowNow(actor2.group_id, actor2.relation_type, actor2.obj_index) then
      scene:Delete(actor2)
      return false
    end
  end
  if not nx_is_valid(actor2) then
    return false
  end
  if role_type == 2 then
    local action_module = nx_value("action_module")
    if actor2.sex == 0 then
      local count = table.maxn(table_player_boy_action)
      local index = math.random(1, count)
      action_module:ChangeState(actor2, table_player_boy_action[nx_number(nx_int(index))], true)
    else
      local count = table.maxn(table_player_girl_action)
      local index = math.random(1, count)
      action_module:ChangeState(actor2, table_player_girl_action[nx_number(nx_int(index))], true)
    end
  elseif role_type == 4 then
    local role_composite = nx_value("role_composite")
    while role_composite:IsLoading(4, actor2) do
      nx_pause(0.1)
      if not nx_is_valid(actor2) or not nx_is_valid(scene) then
        break
      end
      if not sns_manager:IsShowNow(actor2.group_id, actor2.relation_type, actor2.obj_index) then
        scene:Delete(actor2)
        return false
      end
    end
    if not nx_is_valid(actor2) then
      return false
    end
    game_visual:SetRoleCreateFinish(actor2, true)
    local state_action = ""
    if not nx_find_custom(actor2, "sex") or actor2.sex == 0 then
      local count = table.maxn(table_npc_boy_action)
      local index = math.random(1, count)
      local action = table_npc_boy_action[nx_number(nx_int(index))]
      if action == nil then
      end
      state_action = action
    else
      local count = table.maxn(table_npc_girl_action)
      local index = math.random(1, count)
      state_action = table_npc_girl_action[nx_number(nx_int(index))]
    end
    local action_index = actor2:FindAction(state_action)
    if 0 <= action_index then
      local action_module = nx_value("action_module")
      action_module:ChangeState(actor2, state_action, true)
      actor2:LoadAction(action_index)
      local time = 0
      while 0 >= actor2:GetActionFrame(state_action) do
        time = time + nx_pause(0.05)
        if 10 < time then
          break
        end
        if not nx_is_valid(actor2) then
          break
        end
      end
      if nx_is_valid(actor2) then
        local frame_count = actor2:GetActionFrame(state_action)
        if 1 < frame_count then
          local cur_frame = math.random(1, nx_number(frame_count))
          actor2:SetCurrentFrame(state_action, cur_frame - 1)
        end
      end
      nx_pause(0.5)
    end
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  if nx_is_valid(sns_manager) and nx_is_valid(actor2) then
    add_balloon(sns_manager, actor2)
    scene:AddObject(actor2, 20)
    sns_manager:CreateSnsPlayerFinish(actor2.group_id, actor2.relation_type, actor2.obj_index, actor2)
  end
  return true
end
function get_role_face(actor2)
  if not nx_is_valid(actor2) then
    return nil
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return nil
  end
  local actor2_face = game_visual:QueryActFace(actor2)
  if not nx_is_valid(actor2_face) then
    local actor_role = actor2:GetLinkObject("actor_role")
    if not nx_is_valid(actor_role) then
      return nil
    end
    actor2_face = actor_role:GetLinkObject("actor_role_face")
  end
  return actor2_face
end
function add_balloon(sns_manager, vis_obj)
  if vis_obj.balloon_type == 0 then
    return
  end
  local gui = nx_value("gui")
  local balls = sns_manager.head_balls
  local mtextbox = gui:Create("MultiTextBox")
  if vis_obj.balloon_type == 1 then
    mtextbox.Width = 280
    mtextbox.Height = 60
    mtextbox.ViewRect = "0,0,280,60"
    mtextbox.LineColor = "0,255,255,255"
    mtextbox.Font = "font_sns_title_hual_3"
    mtextbox.TextColor = "255,255,255,255"
    local ball = balls:AddBalloon(mtextbox, vis_obj, 3)
    ball.Name = "test:add_balloon:" .. nx_string(vis_obj)
    balls.UseDepthScale = false
    ball.OffsetTop = -60
  elseif vis_obj.balloon_type == 2 then
    mtextbox.Width = 128
    mtextbox.Height = 60
    mtextbox.ViewRect = "0,0,128,60"
    mtextbox.LineColor = "0,255,255,255"
    mtextbox.Font = "font_sns_event_mid"
    mtextbox.TextColor = "255,255,255,255"
    local ball = balls:AddBalloon(mtextbox, vis_obj, 3)
    ball.Name = "test:add_balloon:" .. nx_string(vis_obj)
    balls.UseDepthScale = false
    ball.OffsetTop = -60
  end
  local relation_group = sns_manager:GetRelationGroup(vis_obj.group_id)
  if not nx_is_valid(relation_group) then
    return
  end
  local name = ""
  local game_visual = nx_value("game_visual")
  local vis_obj_type = game_visual:QueryRoleType(vis_obj)
  if vis_obj_type == 2 then
    name = relation_group:GetPlayerName(vis_obj.relation_type, vis_obj.obj_index)
  elseif vis_obj_type == 4 then
    name = relation_group:GetPlayerName(vis_obj.relation_type, vis_obj.obj_index)
    if gui.TextManager:IsIDName(nx_string(name)) then
      name = util_text(nx_string(name))
    end
  end
  nx_set_custom(vis_obj, "head_ball", mtextbox)
  mtextbox:AddHtmlText(nx_widestr("<center>") .. nx_widestr(name) .. nx_widestr("</center>"), -1)
  mtextbox:AddHtmlText(nx_widestr("<center><font color=\"#777777\">") .. nx_widestr(relation_group:GetPlayerAddInfo(vis_obj.relation_type, vis_obj.obj_index)) .. nx_widestr("</font></center>"), -1)
end
function on_btn_card_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_card\\form_card")
end
function on_btn_life_click(self)
  local form = self.ParentForm
  form:Close()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  form_main.rbtn_life.Checked = true
end
function on_btn_fight_click(self)
  local form = self.ParentForm
  form:Close()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  form_main.rbtn_fight.Checked = true
end
function get_table_nums(table_name)
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local player = game_client:GetPlayer()
    if nx_is_valid(player) then
      local rows = 0
      local haoyou_nums = 0
      local zhiyou_nums = 0
      local guanzhu_nums = 0
      if player:FindRecord(table_name) then
        rows = player:GetRecordRows(table_name)
      else
        rows = 0
      end
      if player:FindRecord("rec_npc_relation") then
        local npc_rows = player:GetRecordRows("rec_npc_relation")
        for i = 0, npc_rows - 1 do
          local npc_relation = player:QueryRecord("rec_npc_relation", i, 3)
          if nx_number(npc_relation) == 0 then
            haoyou_nums = haoyou_nums + 1
          elseif nx_number(npc_relation) == 1 then
            zhiyou_nums = zhiyou_nums + 1
          end
        end
      end
      if player:FindRecord("rec_npc_attention") then
        guanzhu_nums = player:GetRecordRows("rec_npc_attention")
      end
      if table_name == FRIEND_REC then
        rows = rows + haoyou_nums
      elseif table_name == BUDDY_REC then
        rows = rows + zhiyou_nums
      elseif table_name == ATTENTION_REC then
        rows = rows + guanzhu_nums
      end
      return rows
    end
  end
  return 0
end
function show_title()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_sns_backbutton1")
  gui.TextManager:Format_AddParam(name)
  local text1 = gui.TextManager:Format_GetText()
  local form = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form) then
    form.mltbox_title:Clear()
    form.mltbox_title:AddHtmlText(nx_widestr(text1), -1)
  end
end
function create_terrain(scene, unit_size, tex_units, zone_rows, zone_cols)
  local terrain = scene:Create("Terrain")
  if unit_size == 1 then
    terrain:SetParameter(256, 32, 256, tex_units, 2, 2)
    terrain.UnitSize = 1
    terrain.LightPerUnit = 2
  else
    terrain:SetParameter(128, 16, 256, tex_units, 4, 4)
    terrain.UnitSize = 2
    terrain.LightPerUnit = 4
  end
  terrain.DesignMode = true
  terrain.InitHeight = 0
  terrain.ShowDesignLine = false
  local dev_caps = nx_value("device_caps")
  if 2 < dev_caps.MaxTextures then
    terrain.TexStage2 = false
  else
    terrain.TexStage2 = true
  end
  terrain.ZoneLightPath = "lzone"
  terrain.ModelLightPath = "lmodel"
  terrain.WalkablePath = "walk"
  terrain:AddBaseTex("base1", terrain.AppendPath .. "map\\tex\\dibiao_03")
  terrain:AddTexturePath("map\\tex\\model\\")
  local gui = nx_value("gui")
  terrain:Load()
  scene:AddObject(terrain, 20)
  scene.terrain = terrain
  nx_set_value("terrain", terrain)
  terrain:InitZones(zone_rows, zone_cols, zone_rows / 2, zone_cols / 2, 2)
  return terrain
end
function create_sky(scene)
  local sky = scene:Create("SkyBox")
  if not nx_is_valid(sky) then
    disp_error("\180\180\189\168\204\236\191\213\186\208\202\167\176\220")
    return nil
  end
  local asyncLoad = true
  sky.AsyncLoad = nx_boolean(asyncLoad)
  local yawSpeed = 0.01
  sky.YawSpeed = yawSpeed
  local mulFactor = 500
  sky.MulFactor = mulFactor
  local visible = true
  sky.Visible = nx_boolean(visible)
  sky.UpTex = "map\\tex\\sky.dds"
  sky.SideTex = "map\\tex\\sky.dds"
  return sky
end
function refersh_npc_news()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local npc_list = karmamgr:GetPrizeNpcList()
  local npc_num = table.getn(npc_list)
  local news_num_list = {
    0,
    0,
    0,
    0,
    0
  }
  if npc_num ~= 0 then
    for i = 1, npc_num do
      local npc_id = npc_list[i]
      local group_id = karmamgr:GetGroupKarma(npc_id)
      local relation = nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "get_npc_relation", npc_id)
      if 0 <= relation then
        news_num_list[1] = news_num_list[1] + 1
      end
      if nx_string(group_id) ~= "" and nx_int(group_id) >= nx_int(SHILI_MIN) and nx_int(group_id) <= nx_int(SHILI_MAX) then
        news_num_list[2] = news_num_list[2] + 1
      end
    end
    news_num_list[5] = nx_execute("form_stage_main\\form_relation\\form_relation_fujin", "get_news_fujin")
  end
  if news_num_list[1] == 0 then
    form.lbl_renmai_news.Visible = false
  else
    form.lbl_renmai_news.Visible = true
    form.lbl_renmai_news.Text = nx_widestr(news_num_list[1])
    nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_renmai_news_num")
  end
  if news_num_list[2] == 0 then
    form.lbl_shili_news.Visible = false
  else
    form.lbl_shili_news.Visible = true
    form.lbl_shili_news.Text = nx_widestr(news_num_list[2])
    nx_execute("form_stage_main\\form_relation\\form_relation_shili", "refersh_npc_news")
  end
  if news_num_list[5] == 0 then
    form.lbl_enchou_news.Visible = false
  else
    form.lbl_enchou_news.Visible = true
    form.lbl_enchou_news.Text = nx_widestr(news_num_list[5])
  end
end
function show_npcfriend_info(groupscrollbox, ...)
  local npclist = arg
  local form = groupscrollbox.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  if not client_player:FindRecord("rec_npc_relation") then
    return
  end
  groupscrollbox.IsEditMode = true
  local rows = table.getn(npclist)
  if rows == 0 then
    return
  end
  for i = 1, rows do
    local npcname = npclist[i]
    local index = client_player:FindRecordRow("rec_npc_relation", 0, npcname)
    if 0 <= index then
      local npcKarmaGroup = karmamgr:GetGroupKarma(npcname)
      local relationvalue = client_player:QueryRecord("rec_npc_relation", index, 2)
      local relation = client_player:QueryRecord("rec_npc_relation", index, 3)
      local npcinfogroupbox = clone_npcfriendinfo(form, i, npcname, relation, relationvalue)
      groupscrollbox:Add(npcinfogroupbox)
    end
  end
  groupscrollbox:ResetChildrenYPos()
  groupscrollbox.IsEditMode = false
end
function clone_npcfriendinfo(formuse, id, npcname, relation, relationvalue)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local clone = clone_groupbox(form.groupbox_npcfriendinfo)
  clone.Name = clone.Name .. nx_string(id)
  clone.Visable = true
  clone.index = id
  nx_bind_script(clone, nx_script_name(formuse))
  nx_callback(clone, "on_get_capture", "on_groupbox_npcfriendinfo_get_capture")
  nx_callback(clone, "on_lost_capture", "on_groupbox_npcfriendinfo_lost_capture")
  local btn_npcfriendinfo = clone_button(form.btn_npcfriendinfo)
  btn_npcfriendinfo.npcname = npcname
  nx_bind_script(btn_npcfriendinfo, nx_script_name(formuse))
  nx_callback(btn_npcfriendinfo, "on_click", "on_btn_npcfriendinfo_click")
  clone:Add(btn_npcfriendinfo)
  local temp
  local lbl_npcinfo_feeling = clone_label(form.lbl_npcinfo_feeling)
  clone:Add(lbl_npcinfo_feeling)
  lbl_npcinfo_feeling.Name = lbl_npcinfo_feeling.Name .. nx_string(id)
  local lbl_npcinfo_head = clone_label(form.lbl_npcinfo_head)
  clone:Add(lbl_npcinfo_head)
  lbl_npcinfo_head.Name = lbl_npcinfo_head.Name .. nx_string(id)
  local lbl_npcinfo_xia = clone_label(form.lbl_npcinfo_xia)
  clone:Add(lbl_npcinfo_xia)
  local CharacterFlag = ItemQuery:GetItemPropByConfigID(nx_string(npcname), nx_string("Character"))
  if nx_number(CharacterFlag) == nx_number(1) then
    lbl_npcinfo_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_colour.png"
  elseif nx_number(CharacterFlag) == nx_number(2) then
    lbl_npcinfo_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_colour.png"
  elseif nx_number(CharacterFlag) == nx_number(3) then
    lbl_npcinfo_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_colour.png"
  elseif nx_number(CharacterFlag) == nx_number(4) then
    lbl_npcinfo_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_colour.png"
  end
  lbl_npcinfo_xia.Name = lbl_npcinfo_xia.Name .. nx_string(id)
  local lbl_npcinfo_head_pic = clone_label(form.lbl_npcinfo_head_pic)
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(npcname), nx_string("Photo"))
  if photo == "" then
    photo = "gui\\special\\sns_new\\sns_head\\common_head.png"
  end
  lbl_npcinfo_head_pic.BackImage = photo
  lbl_npcinfo_head_pic.DrawMode = "FitWindow"
  clone:Add(lbl_npcinfo_head_pic)
  lbl_npcinfo_head_pic.Name = lbl_npcinfo_head_pic.Name .. nx_string(id)
  local lbl_npcinfo_feeling_head = clone_label(form.lbl_npcinfo_feeling_head)
  clone:Add(lbl_npcinfo_feeling_head)
  lbl_npcinfo_feeling_head.Name = lbl_npcinfo_feeling_head.Name .. nx_string(id)
  local lbl_npcInfo_name = clone_label(form.lbl_npcInfo_name)
  lbl_npcInfo_name.Text = nx_widestr(util_text(nx_string(npcname)))
  clone:Add(lbl_npcInfo_name)
  lbl_npcInfo_name.Name = lbl_npcInfo_name.Name .. nx_string(id)
  local lbl_npcInfo_job = clone_label(form.lbl_npcInfo_job)
  if nx_widestr(util_text(nx_string(npcname) .. "_1")) ~= nx_widestr(nx_string(npcname) .. "_1") then
    lbl_npcInfo_job.Text = nx_widestr(util_text(nx_string(npcname) .. "_1"))
  end
  clone:Add(lbl_npcInfo_job)
  lbl_npcInfo_job.Name = lbl_npcInfo_job.Name .. nx_string(id)
  local lbl_npcInfo_relation = clone_label(form.lbl_npcInfo_relation)
  if relation == 0 then
    lbl_npcInfo_relation.Text = nx_widestr(util_text(nx_string("ui_haoyou_01")))
  elseif relation == 1 then
    lbl_npcInfo_relation.Text = nx_widestr(util_text(nx_string("ui_zhiyou_01")))
  elseif relation == 2 then
    lbl_npcInfo_relation.Text = nx_widestr(util_text(nx_string("ui_guanzhu_01")))
  else
    lbl_npcInfo_relation.Text = nx_widestr(util_text(nx_string("ui_putong_01")))
  end
  clone:Add(lbl_npcInfo_relation)
  lbl_npcInfo_relation.Name = lbl_npcInfo_relation.Name .. nx_string(id)
  set_karma_groupbox(lbl_npcinfo_feeling, lbl_npcinfo_feeling_head, relationvalue)
  return clone
end
function clone_button(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Button")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.PushImage = source.PushImage
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  return clone
end
function set_karma_groupbox(label_fstip, label_face, karma_value)
  if not nx_is_valid(label_fstip) then
    return
  end
  local photo = ""
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("Karma")
  if sec_index < 0 then
    sec_index = "0"
  end
  local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(GroupMsgData)) do
    local stepData = util_split_string(GroupMsgData[i], ",")
    if nx_int(stepData[1]) <= nx_int(karma_value) and nx_int(karma_value) <= nx_int(stepData[2]) then
      photo = nx_string(stepData[4])
    end
  end
  local KarmaMaxValue = 200000
  local index_max = ini:FindSectionIndex("KarmaValue")
  if 0 <= index_max then
    KarmaMaxValue = ini:GetSectionItemValue(index_max, nx_string("MaxValue"))
  end
  label_fstip.Minimum = 0
  label_fstip.Maximum = nx_int(KarmaMaxValue)
  label_fstip.Value = nx_int(KarmaMaxValue) / 2 + nx_int(karma_value)
  if photo == "" then
    return
  end
  label_face.BackImage = photo
  local radio = nx_number(label_fstip.Value) / nx_number(label_fstip.Maximum)
  local height = label_fstip.Height * (0.5 - math.abs(radio - 0.5)) / 0.5
  label_face.Top = label_fstip.Top + height - label_face.Height / 2
  label_face.Left = label_fstip.Left - label_face.Width / 2 + label_fstip.Width * radio
end
function clone_label(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Label")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.Text = source.Text
  clone.BackImage = source.BackImage
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_groupbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("GroupBox")
  clone.AutoSize = source.AutoSize
  clone.Name = source.Name
  clone.BackColor = source.BackColor
  clone.NoFrame = source.NoFrame
  clone.Left = 0
  clone.Top = 0
  clone.Width = source.Width
  clone.Height = source.Height
  clone.LineColor = source.LineColor
  return clone
end
function bind_rec_npc_relation(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("rec_npc_relation", form, "form_stage_main\\form_relationship", "on_npc_relation_change")
    databinder:AddTableBind("rec_npc_relation_delay", form, "form_stage_main\\form_relationship", "on_npc_relation_change")
  end
end
function on_npc_relation_change(self, recordname, optype, row, clomn)
  refersh_npc_news()
  if optype == "add" then
  end
  if optype == "update" then
  end
  if optype == "del" then
  end
  if optype == "clear" then
  end
  return 1
end
function refersh_npc_prize(count)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  if count == 0 then
    form.lbl_shijie_news.Visible = false
  else
    form.lbl_shijie_news.Visible = true
    form.lbl_shijie_news.Text = nx_widestr(count)
  end
end
function is_study_job()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindRecord("job_rec") then
    return false
  end
  local job_cnt = client_player:GetRecordRows("job_rec")
  if 0 < job_cnt then
    return true
  end
  return false
end
function on_rbtn_relation2_checked_changed(rbtn)
  if not nx_boolean(rbtn.Checked) then
    return
  end
  local index = nx_number(rbtn.TabIndex)
  if index < 0 or 6 <= index then
    return
  end
  local sns_manager = nx_value("sns_manager_cache")
  if not nx_is_valid(sns_manager) then
    return
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_RENMAI)
  sns_manager:SetRelationType(group_id, index)
  local form_relation_news = nx_value("form_stage_main\\form_relation\\form_relation_news")
  if nx_is_valid(form_relation_news) then
    form_relation_news:Close()
  end
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form_renmai) then
    return
  end
  if nx_find_custom(rbtn, "model_count") and nx_int(rbtn.model_count) <= nx_int(0) then
    form_renmai.lbl_no_man.Visible = true
  else
    form_renmai.lbl_no_man.Visible = false
  end
end
function show_fps(form)
  local world = nx_value("world")
  local gui = world.MainGui
  while true do
    if not nx_is_valid(form) or not form.Visible then
      return false
    end
    form.lbl_frame.Text = nx_widestr("FPS:" .. nx_decimals(gui.FPS, 0))
    nx_pause(1)
  end
  return true
end
