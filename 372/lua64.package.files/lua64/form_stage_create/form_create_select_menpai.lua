require("util_gui")
require("login_scene")
require("util_functions")
require("tips_data")
require("util_static_data")
require("share\\static_data_type")
require("role_composite")
require("gameinfo_collector")
local FILE_SKILL_INI = "share\\Skill\\skill_new.ini"
local FINE_NEIGONG_INI = "share\\Skill\\NeiGong\\neigong.ini"
local FINE_POS_INI = "ini\\form\\create_npc_pos.ini"
local Cover_Ng_Img = {
  "gui\\create\\school_select\\bq_1n.png",
  "gui\\create\\school_select\\bq_2n.png",
  "gui\\create\\school_select\\bq_3n.png",
  "gui\\create\\school_select\\bq_4n.png",
  "gui\\create\\school_select\\bq_5n.png",
  "gui\\create\\school_select\\bq_6n.png"
}
local Cover_Cloth_Img = {
  "gui\\create\\school_select\\bq_dz.png",
  "gui\\create\\school_select\\bq_zs.png",
  "gui\\create\\school_select\\bq_zl.png",
  "gui\\create\\school_select\\bq_zm.png"
}
local NORMAL_SCHOOL_IMG = "gui\\create\\school_select\\xianzhi.png"
local SPECIAL_FORCE_IMG = "gui\\language\\ChineseS\\create_school\\school_select_new\\suoda.png"
local ArtPack = {
  ArtPack = "Cloth",
  HatArtPack = "Hat",
  PlantsArtPack = "Pants",
  ShoesArtPack = "Shoes"
}
local effect_data_tab = {
  [1] = "ini\\particles_mdl.ini,P_flower05a",
  [2] = "dongku_shanguang",
  [3] = "tianqi_yushui",
  [4] = "P_flower05a"
}
local openbook_table = {
  book1 = {
    0,
    false,
    "rbtn_book_1"
  },
  book2 = {
    0,
    false,
    "rbtn_book_4"
  },
  book4 = {
    0,
    false,
    "rbtn_book_3"
  },
  book5 = {
    0,
    false,
    "rbtn_book_2"
  }
}
function on_main_form_init(form)
  form.Fixed = true
  form.cur_select_school = ""
  form.neigong = ""
  form.book_id = ""
  form.actor_man = nx_null()
  form.actor_woman = nx_null()
  form.sex = 0
  form.is_school = -1
  form.body = 2
  GTP_set_collector_time(GTP_LUA_FUNC_CREATE_ROLE, true, true)
end
function on_main_form_open(self)
  self.groupbox_sex.Visible = false
  self.groupbox_desc.Visible = false
  self.groupbox_school.Visible = false
  self.groupbox_rbt_title.Visible = false
  self.groupbox_btn.Visible = false
  self.btn_other.Visible = false
  self.groupbox_scene.Visible = true
  self.groupbox_map.Visible = false
  self.groupbox_book.Visible = false
  self.btn_book.Visible = false
  self.lbl_lock.Visible = false
  self.groupscrollbox_ys_school.Visible = false
  self.groupscrollbox_jh_school.Visible = false
  self.groupscrollbox_8_school.Visible = false
  self.rbtn_book_1.book_vis = false
  self.rbtn_book_2.book_vis = false
  self.rbtn_book_3.book_vis = false
  self.rbtn_book_4.book_vis = false
  self.rbtn_book_5.book_vis = false
  self.btn_zhezhao.Visible = false
  self.groupbox_size.Visible = false
  self.groupbox_2.Visible = false
  self.ani_fanye.AsyncLoad = true
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    form_create_introduce = nx_create("form_create_introduce")
    nx_set_value("form_create_introduce", form_create_introduce)
  end
  change_form_size()
  local scene = nx_value("game_scene")
  nx_execute(nx_current(), "load_menpai_scene", self, scene, "map\\ter\\login11\\")
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) and game_visual.GameTest then
    nx_set_value("debug_scene_box_light", scene)
  end
  local gui = nx_value("gui")
  gui.Desktop.Visible = true
  scene.ClearZBuffer = true
  self.lbl_back.BackImage = "gui\\login\\school_select.jpg"
  self.lbl_load.BackImage = "gui\\loading\\login.jpg"
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    sock.Sender:GetWorldInfo(0)
  end
end
function add_small_model_to_scene(form, scene)
  if not nx_is_valid(scene) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return false
  end
  local x = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionX", "-1"))
  local y = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionY", "-1"))
  local z = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionZ", "-1"))
  local actor2 = create_role_composite(scene, true, 0, "stand", 4)
  while not actor2.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(scene) or not nx_is_valid(actor2) then
      return false
    end
  end
  if not nx_is_valid(actor2) then
    return false
  end
  actor2.AsyncLoad = true
  actor2.cloth_sex = "_b"
  actor2.sex = 0
  actor2.Visible = false
  actor2.body_type = 4
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  form.actor_man = actor2
  form_create_introduce:AddNpcToTerrain(actor2, x, y, z)
  if form.sex == 1 then
    set_npc_default_pos(actor2, "mengpai_pos_b")
  else
    set_npc_default_pos(actor2, "mengpai_pos_main", "mengpai_pos_b")
  end
  local x = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionX", "-1"))
  local y = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionY", "-1"))
  local z = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionZ", "-1"))
  local actor2 = create_role_composite(scene, true, 1, "stand", 3)
  while not actor2.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(scene) or not nx_is_valid(actor2) then
      return false
    end
  end
  if not nx_is_valid(actor2) then
    return false
  end
  actor2.AsyncLoad = true
  actor2.cloth_sex = "_g"
  actor2.sex = 1
  actor2.Visible = false
  actor2.body_type = 3
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  form.actor_woman = actor2
  form_create_introduce:AddNpcToTerrain(actor2, x, y, z)
  if form.sex == 1 then
    set_npc_default_pos(actor2, "mengpai_pos_main", "mengpai_pos_g")
  else
    set_npc_default_pos(actor2, "mengpai_pos_g")
  end
  update_model_cloth(form)
  set_school_default_action(form)
  init_action_visible(form)
  return true
end
function add_model_to_scene(form, scene, show_map)
  if not nx_is_valid(scene) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return false
  end
  local x = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionX", "-1"))
  local y = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionY", "-1"))
  local z = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionZ", "-1"))
  local actor2 = create_role_composite(scene, true, 0, "stand")
  while not actor2.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(scene) or not nx_is_valid(actor2) then
      return false
    end
  end
  if not nx_is_valid(actor2) then
    return false
  end
  actor2.AsyncLoad = true
  actor2.cloth_sex = "_b"
  actor2.sex = 0
  actor2.Visible = false
  actor2.body_type = 2
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  form.actor_man = actor2
  form_create_introduce:AddNpcToTerrain(actor2, x, y, z)
  if form.sex == 1 then
    set_npc_default_pos(actor2, "mengpai_pos_b")
  else
    set_npc_default_pos(actor2, "mengpai_pos_main", "mengpai_pos_b")
  end
  local x = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionX", "-1"))
  local y = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionY", "-1"))
  local z = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionZ", "-1"))
  local actor2 = create_role_composite(scene, true, 1, "stand")
  while not actor2.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(scene) or not nx_is_valid(actor2) then
      return false
    end
  end
  if not nx_is_valid(actor2) then
    return false
  end
  actor2.AsyncLoad = true
  actor2.cloth_sex = "_g"
  actor2.sex = 1
  actor2.Visible = false
  actor2.body_type = 1
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  form.actor_woman = actor2
  form_create_introduce:AddNpcToTerrain(actor2, x, y, z)
  if form.sex == 1 then
    set_npc_default_pos(actor2, "mengpai_pos_main", "mengpai_pos_g")
  else
    set_npc_default_pos(actor2, "mengpai_pos_g")
  end
  scene.ClearZBuffer = true
  if show_map then
    form.lbl_load.BackImage = ""
    form.lbl_load.Visible = false
    form.groupbox_map.Visible = true
  else
    update_model_cloth(form)
    set_school_default_action(form)
  end
  init_action_visible(form)
  return true
end
function add_empty_model_to_scene(form, scene)
  if not nx_is_valid(scene) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return false
  end
  local actor2 = create_actor2(scene)
  local result = role_composite:CreateSceneObjectFromIni(actor2, "ini\\npc\\sizechange.ini")
  if not result then
    scene:Delete(actor2)
  end
  if not nx_is_valid(actor2) then
    return false
  end
  local x = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionX", "-1"))
  local y = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionY", "-1"))
  local z = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_b", "PositionZ", "-1"))
  set_npc_default_pos(actor2, "mengpai_pos_b")
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  form.actor_empty_1 = actor2
  form_create_introduce:AddNpcToTerrain(actor2, x, y, z)
  actor2 = create_actor2(scene)
  result = role_composite:CreateSceneObjectFromIni(actor2, "ini\\npc\\sizechange.ini")
  if not result then
    scene:Delete(actor2)
  end
  if not nx_is_valid(actor2) then
    return false
  end
  x = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionX", "-1"))
  y = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionY", "-1"))
  z = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_g", "PositionZ", "-1"))
  set_npc_default_pos(actor2, "mengpai_pos_g")
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  form.actor_empty_2 = actor2
  form_create_introduce:AddNpcToTerrain(actor2, x, y, z)
  actor2 = create_actor2(scene)
  result = role_composite:CreateSceneObjectFromIni(actor2, "ini\\npc\\sizechange.ini")
  if not result then
    scene:Delete(actor2)
  end
  if not nx_is_valid(actor2) then
    return false
  end
  x = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_main", "PositionX", "-1"))
  y = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_main", "PositionY", "-1"))
  z = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_main", "PositionZ", "-1"))
  set_npc_default_pos(actor2, "mengpai_pos_main")
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  form.actor_empty_3 = actor2
  form_create_introduce:AddNpcToTerrain(actor2, x, y, z)
  return true
end
function on_main_form_shut(self)
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) and nx_is_valid(self.actor_man) then
    scene:Delete(self.actor_man)
  end
  if nx_is_valid(scene) and nx_is_valid(self.actor_woman) then
    scene:Delete(self.actor_woman)
  end
end
function on_main_form_close(form)
  if nx_running(nx_current(), "load_menpai_scene") then
    nx_kill(nx_current(), "load_menpai_scene")
  end
  if nx_running(nx_current(), "add_model_to_scene") then
    nx_kill(nx_current(), "add_model_to_scene")
  end
  if nx_running(nx_current(), "add_small_model_to_scene") then
    nx_kill(nx_current(), "add_small_model_to_scene")
  end
  if nx_running(nx_current(), "add_empty_model_to_scene") then
    nx_kill(nx_current(), "add_empty_model_to_scene")
  end
  if nx_running(nx_current(), "change_cloth") then
    nx_kill(nx_current(), "change_cloth")
  end
  if nx_running(nx_current(), "play_action_jump_out") then
    nx_kill(nx_current(), "play_action_jump_out")
  end
  if nx_running(nx_current(), "play_action_jump_in") then
    nx_kill(nx_current(), "play_action_jump_in")
  end
  if nx_running(nx_current(), "create_show_in_scene") then
    nx_kill(nx_current(), "create_show_in_scene")
  end
  if nx_running(nx_current(), "wait_action_down_end") then
    nx_kill(nx_current(), "wait_action_down_end")
  end
  if nx_running(nx_current(), "wait_action_on_end") then
    nx_kill(nx_current(), "wait_action_on_end")
  end
  if nx_running(nx_current(), "wait_skill_end") then
    nx_kill(nx_current(), "wait_skill_end")
  end
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager(FILE_SKILL_INI)
    IniManager:UnloadIniFromManager(FINE_NEIGONG_INI)
    IniManager:UnloadIniFromManager(FINE_POS_INI)
  end
  local form_select_menpai_preload = nx_value("form_stage_create\\form_creat_model")
  if nx_is_valid(form_select_menpai_preload) then
    nx_destroy(form_select_menpai_preload)
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if nx_is_valid(form_create_introduce) then
    nx_destroy(form_create_introduce)
  end
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) and nx_is_valid(form.actor_man) then
    scene:Delete(form.actor_man)
  end
  if nx_is_valid(scene) and nx_is_valid(form.actor_woman) then
    scene:Delete(form.actor_woman)
  end
  if nx_is_valid(scene) and nx_is_valid(form.actor_empty_1) then
    scene:Delete(form.actor_empty_1)
  end
  if nx_is_valid(scene) and nx_is_valid(form.actor_empty_2) then
    scene:Delete(form.actor_empty_2)
  end
  if nx_is_valid(scene) and nx_is_valid(form.actor_empty_3) then
    scene:Delete(form.actor_empty_3)
  end
  if nx_is_valid(scene) and nx_find_custom(scene, "light") and nx_is_valid(scene.light) then
    scene:Delete(scene.light)
  end
  nx_set_value("form_stage_create\\form_create_select_menpai", nil)
end
function on_btn_book_click(btn)
  local form = btn.ParentForm
  if form.cur_select_school == "" then
    return
  end
  if form.book_id == "" then
    return
  end
  form.Visible = false
  enter_create_form(form)
end
function set_groupbox_center(groupbox)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  groupbox.Left = (form.Width - groupbox.Width) / 2
  groupbox.Top = (form.Height - groupbox.Height) / 2
end
function on_btn_enter_game_click(btn)
  local form = btn.ParentForm
  if form.cur_select_school == "" then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  if form.cur_select_school == "school_gaibang" then
  elseif form.cur_select_school == "school_junzitang" then
  end
  id = form_create_introduce:GetNameId(form.cur_select_school)
  form.lbl_school_name.Text = util_text(id)
  form.groupbox_book.Left = (form.Width - form.groupbox_book.Width) / 2
  form.groupbox_book.Top = (form.Height - form.groupbox_book.Height) / 2
  form.groupbox_school.Visible = false
  form.groupbox_rbt_title.Visible = false
  form.groupbox_sex.Visible = false
  form.groupbox_desc.Visible = false
  form.groupbox_map.Visible = false
  form.btn_back.Visible = false
  form.lbl_lock.Visible = false
  form.groupbox_size.Visible = false
  form.groupbox_book.Visible = true
  form.lbl_back.Visible = true
  form.lbl_back.BackImage = "gui\\login\\book_select.jpg"
  form.btn_enter_game.Visible = false
  form.btn_book.Visible = true
end
function on_btn_back_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("stage", "set_current_stage", "login")
  GTP_reset_specific_time(GTP_LUA_FUNC_CREATE_ROLE)
end
function on_btn_other_click(btn)
  local form = btn.ParentForm
  form.ani_6.Visible = false
  form.groupbox_map.Visible = true
  form.groupbox_desc.Visible = false
  form.groupbox_school.Visible = false
  form.groupscrollbox_ys_school.Visible = false
  form.groupscrollbox_jh_school.Visible = false
  form.groupscrollbox_8_school.Visible = false
  form.groupbox_rbt_title.Visible = false
  form.groupbox_btn.Visible = false
  form.btn_other.Visible = false
  form.groupbox_sex.Visible = false
  form.groupbox_book.Visible = false
  form.groupbox_size.Visible = false
  form.btn_enter_game.Visible = true
  form.btn_book.Visible = false
  form.btn_back.Visible = true
  form.lbl_back.Visible = true
  form.lbl_back.BackImage = "gui\\login\\school_select.jpg"
  form.lbl_lock.Visible = false
end
function change_form_size()
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_scene.Width = form.Width
  form.groupbox_scene.Height = form.Height
  form.lbl_back.Width = form.Width
  form.lbl_back.Height = form.Height
  form.btn_zhezhao.Width = form.Width
  form.btn_zhezhao.Height = form.Height
  form.lbl_load.Width = form.Width
  form.lbl_load.Height = form.Height
end
function load_scene_camera(scene, filename)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  local camera = scene.camera
  local cam_posi_x = ini:ReadFloat("camera", "PositionX", 0)
  local cam_posi_y = ini:ReadFloat("camera", "PositionY", 15)
  local cam_posi_z = ini:ReadFloat("camera", "PositionZ", 0)
  local cam_angle_x = ini:ReadFloat("camera", "AngleX", 0)
  local cam_angle_y = ini:ReadFloat("camera", "AngleY", 0)
  local cam_angle_z = ini:ReadFloat("camera", "AngleZ", 0)
  local cam_fov_angle = ini:ReadFloat("camera", "FovAngle", 51.8)
  local cam_fov_wide_angle = ini:ReadFloat("camera", "FovWideAngle", 68)
  local cam_speed = ini:ReadFloat("camera", "Speed", 50)
  local drag_speed = ini:ReadFloat("camera", "DragSpeed", 0.1)
  local camera = scene.camera
  if 1 <= cam_speed and cam_speed < 100 then
    camera.move_speed = cam_speed
  end
  if 0.01 <= drag_speed and drag_speed < 1 then
    camera.drag_speed = drag_speed
  end
  if 10 <= cam_fov_angle and cam_fov_angle <= 180 then
    camera.Fov = cam_fov_angle / 360 * math.pi * 2
  end
  camera.fov_angle = cam_fov_angle
  camera.fov_wide_angle = cam_fov_wide_angle
  camera:SetPosition(cam_posi_x, cam_posi_y, cam_posi_z)
  camera:SetAngle(cam_angle_x, cam_angle_y, cam_angle_z)
  if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
    local terrain = scene.terrain
    nx_pause(0.1)
    while nx_is_valid(terrain) and not terrain.LoadFinish do
      nx_pause(0.2)
    end
  end
  nx_destroy(ini)
end
function load_menpai_scene(form, scene, scene_path)
  load_scene_camera(scene, nx_resource_path() .. scene_path .. "\\editor.ini")
  load_scene(scene, scene_path, true)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  nx_execute("terrain\\terrain", "load_scene_screeneffect", scene, nx_resource_path() .. scene_path, true)
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
  add_light(scene)
  local x = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_main", "x", "-1"))
  local y = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_main", "y", "-1"))
  local z = nx_number(get_ini_prop(FINE_POS_INI, "mengpai_pos_main", "z", "-1"))
  nx_execute(nx_current(), "add_empty_model_to_scene", form, scene)
  nx_execute(nx_current(), "add_model_to_scene", form, scene, true)
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return
  end
  weather.FogLinear = true
end
function open_form()
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  if not nx_is_valid(form) then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_create\\form_create_select_menpai", true, false)
    if nx_is_valid(form) then
      form:ShowModal()
    end
  else
    form:ShowModal()
    form.Visible = true
  end
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
function add_weapon(actor2, skill_name)
  if skill_name == nil then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  if not nx_is_valid(actor2) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  role_composite:UnLinkWeapon(actor2)
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  else
    nx_set_custom(actor2, "wuxue_book_set", "")
  end
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, skill_name, "UseLimit", "")
  if LimitIndex == nil or nx_int(LimitIndex) == nx_int(0) then
    return false
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return false
  end
  local ItemType = skill_query:GetSkillWeaponType(nx_int(LimitIndex))
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  local weapon_name = get_weapon_name(taolu)
  if weapon_name == "" then
    return false
  end
  local weapon_list = util_split_string(weapon_name, ",")
  local count = table.getn(weapon_list)
  local bow, arrow_case = "", ""
  if count == 2 then
    bow = nx_string(weapon_list[1])
    arrow_case = nx_string(weapon_list[2])
    if bow ~= "" and arrow_case ~= "" and bow ~= nil and arrow_case ~= nil and nx_int(ItemType) == nx_int(127) then
      show_bow_n_arrow(true, actor2, bow, arrow_case)
    end
  elseif count == 1 then
    game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
  end
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) or nx_int(set_index) <= nx_int(8) then
    local action_set = nx_string(set_index) .. "h"
    nx_set_custom(actor2, "wuxue_book_set", action_set)
  end
  role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), 2, nx_int(ItemType))
  if nx_int(ItemType) == nx_int(116) then
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::H_weaponR_01", "ini\\npc\\hw_fz001")
    local actor_role = game_visual:QueryActRole(actor2)
    if nx_is_valid(actor_role) then
      local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
      if nx_is_valid(shot_weapon) then
        shot_weapon.Visible = false
      end
    end
  end
  game_visual:SetRoleLogicState(actor2, 1)
  return true
end
function get_weapon_name(skill_id)
  local ini = get_ini("ini\\ui\\wuxue\\skill_weapon.ini", true)
  if not nx_is_valid(ini) then
    return ""
  end
  local weapon_name = ini:ReadString("weapon_name", skill_id, "")
  return weapon_name
end
function on_ImageControlGrid_neigong_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local taolu_text = grid:GetItemAddText(index, 0)
  form.lbl_tips.Text = nx_widestr(taolu_text)
  form.lbl_tips.AbsLeft = mouse_x + 20
  form.lbl_tips.AbsTop = mouse_z + 15
  form.lbl_tips.Width = form.lbl_tips.TextWidth + 10
  form.lbl_tips.Visible = true
end
function on_ImageControlGrid_neigong_mouseout_grid(grid, index)
  local form = grid.ParentForm
  form.lbl_tips.Text = nx_widestr("")
  form.lbl_tips.Visible = false
end
function on_ImageControlGrid_neigong_select_changed(grid, index)
  local form = grid.ParentForm
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local neigongpic = form_create_introduce:GetNeiGongPic(form.cur_select_school)
  form.lbl_ng_pic.BackImage = neigongpic
end
function on_cbtn_detial_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.groupbox_ng_pic.Visible = true
    form.groupbox_detial.Visible = false
  else
    form.groupbox_ng_pic.Visible = false
    form.groupbox_detial.Visible = true
  end
end
function on_ImageControlGrid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  local name = get_skill_id(index)
  if not name then
    return
  end
  local actor2 = form.actor_man
  if form.rbtn_woman.Checked then
    actor2 = form.actor_woman
  end
  show_skill_action(name, actor2)
end
function on_ImageControlGrid_wuxue_select_changed(grid, index)
  local form = grid.ParentForm
  local school_id = form.cur_select_school
  if "" == school_id then
    return
  end
  local taolu_id = nx_string(grid:GetItemAddText(index, 0))
  show_skill(school_id, taolu_id, form)
  form.lbl_wuxie_name.Text = util_text(taolu_id)
end
function on_ImageControlGrid_cloth_select_changed(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local form = grid.ParentForm
  local cur_school = form.cur_select_school
  if "" == cur_school then
    return
  end
  local cloth_str = ""
  if form.body == 2 then
    cloth_str = form_create_introduce:GetSchoolCloth(cur_school)
  elseif form.body == 1 then
    cloth_str = form_create_introduce:GetSmallCloth(cur_school)
  end
  local cloth_list = util_split_string(cloth_str, ",")
  if index >= table.getn(cloth_list) then
    return
  end
  local cloth = cloth_list[index + 1]
  if form.body == 2 then
    local cloth_ani = form_create_introduce:GetClothAni(cloth)
    form.ani_6.Visible = true
    form.ani_6.AnimationImage = cloth_ani
    form.ani_6.Loop = false
    form.ani_6:Play()
  else
    form.ani_6.Visible = false
  end
  local actor2 = form.actor_man
  if form.rbtn_woman.Checked then
    actor2 = form.actor_woman
  end
  nx_execute(nx_current(), "change_cloth", form, cloth, actor2, false)
end
function change_cloth(form, cloth, actor2, change_all)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local model_name = "MaleModel"
  local other_model_name = "FemaleModel"
  local actor2_other = form.actor_woman
  if actor2.cloth_sex == "_g" then
    model_name = "FemaleModel"
    actor2_other = form.actor_man
    other_model_name = "MaleModel"
  end
  if not nx_is_valid(actor2_other) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  if form.body == 2 then
    actor2.AsyncLoad = false
    change_model_cloth(actor2, model_name, cloth)
    actor2.AsyncLoad = true
    if change_all then
      actor2_other.AsyncLoad = false
      change_model_cloth(actor2_other, other_model_name, cloth)
      actor2_other.AsyncLoad = true
    end
  elseif form.body == 1 then
    actor2.AsyncLoad = false
    change_model_cloth(actor2, model_name, cloth .. actor2.cloth_sex)
    actor2.AsyncLoad = true
    if change_all then
      actor2_other.AsyncLoad = false
      change_model_cloth(actor2_other, other_model_name, cloth .. actor2_other.cloth_sex)
      actor2_other.AsyncLoad = true
    end
  end
end
function change_model_cloth(actor2, model_name, cloth)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  role_composite:UnLinkWeapon(actor2)
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  else
    nx_set_custom(actor2, "wuxue_book_set", "")
  end
  show_bow_n_arrow(false, actor2)
  local part = {
    "headdress",
    "mask",
    "scarf",
    "shoulders",
    "pendant1",
    "pendant2",
    "cloth",
    "shoes",
    "pants",
    "hat",
    "cloth_h"
  }
  for _, v in pairs(part) do
    role_composite:UnLinkSkin(actor2, v)
  end
  role_composite:LinkSkin(actor2, "Hat", " ", false)
  for id, prop in pairs(ArtPack) do
    local art_id = nx_number(item_query:GetItemPropByConfigID(cloth, id))
    if art_id < 0 then
      nx_execute("role_composite", "unlink_skin", actor2, prop)
      nx_execute("role_composite", "unlink_skin", actor2, string.lower(prop))
    elseif 0 < art_id then
      local model = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(art_id), model_name)
      if "Cloth" == prop or "cloth" == prop then
        role_composite:LinkClothSkin(actor2, model)
        role_composite:LinkSkin(actor2, "cloth_h", model .. "_h.xmod", false)
      else
        role_composite:LinkSkin(actor2, prop, model .. ".xmod", false)
      end
    end
  end
end
function reset_model_cloth(form, sex_in)
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  if not nx_is_valid(form) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local cloth = ""
  if form.body == 2 then
    cloth = form_create_introduce:GetSchoolCloth(form.cur_select_school)
  elseif form.body == 1 then
    cloth = form_create_introduce:GetSmallCloth(form.cur_select_school)
  end
  show_cloth(cloth, form, sex_in)
end
function on_rbtn_man_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    reset_model_cloth(form, 0)
    form.sex = 0
    wait_action_end(form, false)
    play_sex_checked_action(form.actor_man, form.actor_woman)
    update_model_cloth(form)
    change_size_btn_image(form, "man")
  end
end
function on_rbtn_woman_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    reset_model_cloth(form, 1)
    form.sex = 1
    wait_action_end(form, false)
    play_sex_checked_action(form.actor_woman, form.actor_man)
    update_model_cloth(form)
    change_size_btn_image(form, "woman")
  end
end
function get_skill_id(skill_grid_index)
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local taolu_id = get_cur_taolu_id()
  if "" == taolu_id then
    return
  end
  local skill = form_create_introduce:GetTaoluSkill(taolu_id)
  local skill_list = util_split_string(skill, ",")
  if skill_grid_index >= table.getn(skill_list) then
    return
  end
  local name = skill_list[skill_grid_index + 1]
  return name
end
function show_select_school(school_id)
  if school_id == "" then
    return
  end
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  if not nx_is_valid(form) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local info_id = form_create_introduce:GetIntroduce(school_id)
  show_desc(info_id, form)
  local neigong = form_create_introduce:GetSchoolNeiGong(school_id)
  local neigongpic = form_create_introduce:GetNeiGongPic(school_id)
  show_neigong(neigong, neigongpic, form)
  local taolu = form_create_introduce:GetSchoolTaolu(school_id)
  show_taolu(taolu, form)
  local text_id = form_create_introduce:GetConditonInfo(school_id)
  if text_id == "" then
    form.groupbox_1.Visible = false
  else
    form.mltbox_conditioninfo:Clear()
    form.mltbox_conditioninfo:AddHtmlText(util_text(text_id), -1)
    form.groupbox_1.Visible = true
  end
  local map_pic = form_create_introduce:GetMiniMapPic(school_id)
  form.lbl_school_map.BackImage = map_pic
end
function show_desc(info_id, form)
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(util_text(info_id), -1)
end
function show_neigong(neigong, neigongpic, form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.ImageControlGrid_neigong
  local ng_list = util_split_string(neigong, ",")
  grid:Clear()
  local grid_index = 0
  for i, id in ipairs(ng_list) do
    local staticdata = get_ini_prop(FINE_NEIGONG_INI, id, "StaticData", "")
    local photo = neigong_static_query(staticdata, "Photo")
    grid:AddItem(grid_index, photo, util_text(id), 1, -1)
    grid:SetItemCoverImage(grid_index, nx_string(Cover_Ng_Img[grid_index + 1]))
    grid:CoverItem(grid_index, true)
    grid_index = grid_index + 1
  end
  form.lbl_ng_pic.BackImage = neigongpic
end
function show_cloth(cloth, form, sex)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local grid = form.ImageControlGrid_cloth
  grid:Clear()
  local cloth_list = util_split_string(cloth, ",")
  local size = table.getn(cloth_list)
  local cloth_sex = "_b"
  if sex == 1 then
    cloth_sex = "_g"
  end
  local grid_index = 0
  for i = 1, size do
    local cloth_id = cloth_list[i]
    if form.body == 1 then
      cloth_id = cloth_id .. cloth_sex
    end
    local photo = item_query_ArtPack_by_id(cloth_id, "Photo", sex)
    if photo ~= "" then
      grid:AddItem(grid_index, photo, util_text(cloth_id), 1, -1)
      grid:SetItemCoverImage(grid_index, nx_string(Cover_Cloth_Img[grid_index + 1]))
      grid:CoverItem(grid_index, true)
      grid_index = grid_index + 1
    end
  end
end
function show_taolu(taolu, form)
  if not nx_is_valid(form) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local grid = form.ImageControlGrid_wuxue
  local taolu_list = util_split_string(taolu, ",")
  grid:Clear()
  local grid_index = 0
  for _, id in ipairs(taolu_list) do
    local photo = form_create_introduce:GetTaoluPic(id)
    grid:AddItem(grid_index, photo, nx_widestr(id), 1, -1)
    grid_index = grid_index + 1
  end
  if 0 < grid_index then
    on_ImageControlGrid_wuxue_select_changed(form.ImageControlGrid_wuxue, 0)
    form.ImageControlGrid_wuxue:SetSelectItemIndex(0)
  end
end
function get_cur_taolu_id()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return ""
  end
  local grid = form.ImageControlGrid_wuxue
  local index = grid:GetSelectItemIndex()
  if 0 <= index then
    return nx_string(grid:GetItemName(index))
  else
    return ""
  end
end
function show_skill(school_id, taolu_id, form)
  if not nx_is_valid(form) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local grid = form.ImageControlGrid_skill
  local skill = form_create_introduce:GetTaoluSkill(taolu_id)
  local skill_list = util_split_string(skill, ",")
  grid:Clear()
  local grid_index = 0
  for _, id in ipairs(skill_list) do
    local photo = skill_static_query_by_id(id, "Photo")
    grid:AddItem(grid_index, photo, util_text(id), 1, -1)
    grid_index = grid_index + 1
  end
  show_taolu_info(school_id, taolu_id, form)
end
function show_taolu_info(school_id, taolu_id, form)
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local taolu_attack = form_create_introduce:GetTaoluAttack(taolu_id)
  local taolu_defend = form_create_introduce:GetTaoluDefend(taolu_id)
  local taolu_recover = form_create_introduce:GetTaoluRecover(taolu_id)
  local taolu_operate = form_create_introduce:GetTaoluOperate(taolu_id)
  local taolu_site = form_create_introduce:GetTaoluSite(taolu_id)
  set_star(form.groupbox_attack, taolu_attack)
  set_star(form.groupbox_defend, taolu_defend)
  set_star(form.groupbox_recover, taolu_recover)
  set_star(form.groupbox_operate, taolu_operate)
  form.mltbox_site:Clear()
  form.mltbox_site:AddHtmlText(util_text(taolu_site), -1)
end
function set_star(groupbox, num)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox:DeleteAll()
  local quotientr = num / 2
  for i = 1, quotientr do
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = true
  end
  local remainder = num % 2
  if remainder == 1 then
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = quotientr * 20 - 10
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_1.png"
    lbl_star.AutoSize = true
  end
end
function show_skill_action(skill_id, actor2)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  if not nx_is_valid(action) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  skill_effect:EndShowZhaoshi(actor2, "")
  if skill_id == "CS_jy_xsd01" then
    skill_id = "CS_jy_xsd01_creat"
  end
  skill_effect:BeginShowZhaoshi(actor2, skill_id)
  add_weapon(actor2, skill_id)
  wait_action_end(form, false)
  nx_execute(nx_current(), "wait_skill_end", actor2)
end
function wait_skill_end(actor2)
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  if not nx_is_valid(form) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  while nx_is_valid(action) and skill_effect:IsPlayShowZhaoShi(actor2) do
    nx_pause(0)
  end
  wait_action_end(form, true)
end
function update_model_cloth(form)
  if not nx_is_valid(form) then
    return
  end
  local max_size = form.ImageControlGrid_cloth.ClomnNum
  local index = 0
  for i = max_size - 1, 0, -1 do
    if not form.ImageControlGrid_cloth:IsEmpty(i) then
      index = i
      break
    end
  end
  form.ImageControlGrid_cloth:SetSelectItemIndex(index)
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local cur_school = form.cur_select_school
  if "" == cur_school then
    return
  end
  local cloth_str = ""
  if form.body == 2 then
    cloth_str = form_create_introduce:GetSchoolCloth(cur_school)
  elseif form.body == 1 then
    cloth_str = form_create_introduce:GetSmallCloth(cur_school)
  end
  local cloth_list = util_split_string(cloth_str, ",")
  if index >= table.getn(cloth_list) then
    return
  end
  local cloth = cloth_list[index + 1]
  if form.body == 2 then
    local cloth_ani = form_create_introduce:GetClothAni(cloth)
    form.ani_6.Visible = true
    form.ani_6.AnimationImage = cloth_ani
    form.ani_6.Loop = false
    form.ani_6:Play()
  else
    form.ani_6.Visible = false
  end
  nx_execute(nx_current(), "change_cloth", form, cloth, form.actor_man, true)
end
function init_rbtn(form)
  if not nx_is_valid(form) then
    return
  end
  if form.cur_select_school == "" then
    return
  end
  form.rbtn_man.Enabled = false
  form.rbtn_woman.Enabled = false
  if form.cur_select_school == "school_emei" or form.cur_select_school == "force_yihua" or form.cur_select_school == "newschool_shenshui" then
    form.rbtn_woman.Checked = true
    form.sex = 1
    change_size_btn_image(form, "woman")
    form.rbtn_woman.Enabled = true
  elseif form.cur_select_school == "school_shaolin" or form.cur_select_school == "force_wugeng" or form.cur_select_school == "newschool_damo" then
    form.rbtn_man.Checked = true
    form.sex = 0
    change_size_btn_image(form, "man")
    form.rbtn_man.Enabled = true
  else
    form.rbtn_man.Enabled = true
    form.rbtn_woman.Enabled = true
  end
end
function enter_create_form(form)
  local gui = nx_value("gui")
  local scene = nx_value("game_scene")
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  nx_bind_script(gui.Desktop, "")
  local world = nx_value("world")
  world:CollectResource()
  nx_execute("create_scene", "clear_game_control", scene)
  nx_execute("form_stage_create\\form_create", "init_camera")
  gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_create\\form_create.xml")
  if form.cur_select_school == "" or form.book_id == "" then
    return
  end
  if form.is_school == 1 then
    if "school_wumenpai" == form.cur_select_school then
      gui.Desktop.school_id = ""
    else
      gui.Desktop.school_id = form.cur_select_school
    end
  else
    gui.Desktop.school_id = ""
  end
  gui.Desktop.select_sex = form.sex
  gui.Desktop.bookid = form.book_id
  gui.Desktop.nameLimit = nameLimit
  gui.Desktop.Left = 0
  gui.Desktop.Top = 0
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  gui.Desktop.Transparent = true
  gui.Desktop.Visible = true
  gui.Desktop:ShowModal()
  nx_set_value("form_stage_create\\form_create", gui.Desktop)
  if nx_is_valid(login_control) and login_control ~= nil then
    login_control.Target = nx_null()
    scene.login_control = nx_null()
  end
  return 1
end
function on_map_school_btns_click(btn)
  local form = btn.ParentForm
  if btn.DataSource == "" then
    return
  end
  if form.body == 2 then
    form.lbl_force_tips.Visible = false
    form.btn_enter_game.Visible = true
  else
    form.lbl_force_tips.Visible = true
    form.btn_enter_game.Visible = false
  end
  form.cur_select_school = btn.DataSource
  form.is_school = 1
  goto_school(form, form.groupscrollbox_8_school)
  form.rbtn_8_school.Enabled = false
  form.rbtn_8_school.Checked = true
  form.rbtn_8_school.Enabled = true
  form.lbl_6.BackImage = nx_string(NORMAL_SCHOOL_IMG)
  form.lbl_lock.Visible = false
end
function on_map_force_btns_click(btn)
  local form = btn.ParentForm
  if btn.DataSource == "" then
    return
  end
  form.lbl_force_tips.Visible = true
  form.cur_select_school = btn.DataSource
  form.is_school = 0
  form.btn_enter_game.Visible = false
  goto_school(form, form.groupscrollbox_jh_school)
  form.rbtn_shili.Enabled = false
  form.rbtn_shili.Checked = true
  form.rbtn_shili.Enabled = true
  form.lbl_force_tips.Visible = true
  form.lbl_6.BackImage = nx_string(SPECIAL_FORCE_IMG)
  form.lbl_lock.Visible = true
end
function on_map_new_school_btns_click(btn)
  local form = btn.ParentForm
  if btn.DataSource == "" then
    return
  end
  form.lbl_force_tips.Visible = true
  form.cur_select_school = btn.DataSource
  form.is_school = 0
  form.btn_enter_game.Visible = false
  goto_school(form, form.groupscrollbox_ys_school)
  form.rbtn_new_school.Enabled = false
  form.rbtn_new_school.Checked = true
  form.rbtn_new_school.Enabled = true
  form.lbl_force_tips.Visible = true
  form.lbl_6.BackImage = nx_string(SPECIAL_FORCE_IMG)
  form.lbl_lock.Visible = true
end
function goto_school(form, groupscrollbox)
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  if not nx_is_valid(form) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  init_rbtn(form)
  init_action_visible(form)
  local cloth = ""
  if form.body == 2 then
    cloth = form_create_introduce:GetSchoolCloth(form.cur_select_school)
  elseif form.body == 1 then
    cloth = form_create_introduce:GetSmallCloth(form.cur_select_school)
  end
  show_cloth(cloth, form, form.sex)
  update_model_cloth(form)
  nx_execute(nx_current(), "show_select_school", form.cur_select_school)
  local rbtn = groupscrollbox:Find("rbtn_" .. form.cur_select_school)
  if nx_is_valid(rbtn) then
    rbtn.Enabled = false
    rbtn.Checked = true
    rbtn.Enabled = true
    rbtn.Width = 456
    rbtn.Height = 142
    groupscrollbox:ResetChildrenYPos()
    rbtn.CheckedImage = form_create_introduce:GetRbtnBackImageDown(rbtn.DataSource)
  end
  form.groupbox_desc.Visible = true
  form.groupbox_school.Visible = true
  groupscrollbox.Visible = true
  form.groupbox_rbt_title.Visible = true
  form.groupbox_btn.Visible = true
  form.btn_other.Visible = true
  form.groupbox_sex.Visible = true
  form.groupbox_map.Visible = false
  form.lbl_back.Visible = false
  form.btn_back.Visible = false
  form.groupbox_size.Visible = true
  if form.sex == 1 then
    set_npc_default_pos(form.actor_woman, "mengpai_pos_main", "mengpai_pos_g")
    set_npc_default_pos(form.actor_man, "mengpai_pos_b")
    set_camera_direct(form.actor_woman.cloth_sex, false)
  else
    set_npc_default_pos(form.actor_woman, "mengpai_pos_g")
    set_npc_default_pos(form.actor_man, "mengpai_pos_main", "mengpai_pos_b")
    set_camera_direct(form.actor_man.cloth_sex, false)
  end
  set_school_default_action(form)
end
function on_rbtn_school_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.DataSource == "" then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if rbtn.Checked then
    if form.body == 2 then
      form.btn_enter_game.Visible = true
      form.lbl_force_tips.Visible = false
    else
      form.btn_enter_game.Visible = false
      form.lbl_force_tips.Visible = true
    end
    rbtn.Width = 456
    rbtn.Height = 142
    play_school_checked_action(form, form.sex)
    form.cur_select_school = rbtn.DataSource
    form.is_school = 1
    reset_model_cloth(form, form.sex)
    init_rbtn(form)
    nx_execute(nx_current(), "show_select_school", form.cur_select_school)
    rbtn.CheckedImage = form_create_introduce:GetRbtnBackImageDown(rbtn.DataSource)
  else
    rbtn.Width = 230
    rbtn.Height = 35
    form.groupscrollbox_8_school:ResetChildrenYPos()
    create_animation(form, form.cur_select_school, form.groupscrollbox_8_school)
    rbtn.CheckedImage = form_create_introduce:GetRbtnBackImage(rbtn.DataSource)
  end
end
function on_rbtn_froce_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.DataSource == "" then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  if rbtn.Checked then
    form.btn_enter_game.Visible = false
    form.lbl_force_tips.Visible = true
    rbtn.Width = 456
    rbtn.Height = 142
    play_school_checked_action(form, form.sex)
    form.cur_select_school = rbtn.DataSource
    form.is_school = 0
    reset_model_cloth(form, form.sex)
    init_rbtn(form)
    nx_execute(nx_current(), "show_select_school", form.cur_select_school)
    rbtn.CheckedImage = form_create_introduce:GetRbtnBackImageDown(rbtn.DataSource)
  else
    rbtn.Width = 230
    rbtn.Height = 35
    form.groupscrollbox_jh_school:ResetChildrenYPos()
    create_animation(form, form.cur_select_school, form.groupscrollbox_jh_school)
    rbtn.CheckedImage = form_create_introduce:GetRbtnBackImage(rbtn.DataSource)
  end
end
function on_rbtn_book_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.DataSource == "" then
    return
  end
  if rbtn.Checked then
    form.book_id = rbtn.DataSource
    local ani_name = ""
    if form.book_id == "book1" then
      ani_name = "open_book_1"
    elseif form.book_id == "book5" then
      ani_name = "open_book_2"
    elseif form.book_id == "book4" then
      ani_name = "open_book_3"
    elseif form.book_id == "book2" then
      ani_name = "open_book_4"
    elseif form.book_id == "book8" then
      ani_name = "open_book_5"
    end
    form.ani_fanye.AnimationImage = ani_name
    form.ani_fanye.PlayMode = 0
    form.ani_fanye.Loop = false
    form.groupbox_book_info.Visible = false
  end
end
function on_ani_fanye_animation_end(ani)
  local form = ani.ParentForm
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  id = form_create_introduce:GetBookTitle(form.book_id)
  form.lbl_book_name.Text = util_text(id)
  id = form_create_introduce:GetBookInfo(form.book_id)
  form.mltbox_info:Clear()
  form.mltbox_info:AddHtmlText(util_text(id), -1)
  id = form_create_introduce:GetNameId(form.cur_select_school)
  form.lbl_school_name.Text = util_text(id)
  form.groupbox_book_info.Visible = true
end
function on_server_world_info(info_type, info)
  local info_list = util_split_string(nx_string(info), ",")
  local size = nx_int(table.getn(info_list) / 2) - 1
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  local max_player_book = 0
  local min_player_book = 9999999
  local min_player_rbtn_name = ""
  for i = 1, size do
    local book = info_list[(i - 1) * 2 + 2]
    local num = nx_number(info_list[(i - 1) * 2 + 3])
    if nil ~= openbook_table[book] then
      openbook_table[book][1] = num
      if min_player_book >= num then
        min_player_book = num
        min_player_rbtn_name = openbook_table[book][3]
      end
      if max_player_book <= num then
        max_player_book = num
      end
      openbook_table[book][2] = true
    end
  end
  if not nx_is_valid(form) then
    return
  end
  for i, openbook in pairs(openbook_table) do
    local rbtn = nx_custom(form, openbook[3])
    if nx_is_valid(rbtn) then
      nx_set_custom(rbtn, "book_vis", openbook[2])
      nx_set_custom(rbtn, "num", openbook[1])
    end
  end
  local top = 20
  local count = 0
  for i, openbook in pairs(openbook_table) do
    local rbtn = nx_custom(form, openbook[3])
    if nx_is_valid(rbtn) and rbtn.Visible then
      rbtn.Top = count * 42 + top
      count = count + 1
    end
  end
  local ini_manager = nx_value("IniManager")
  local file_name = "ini\\ui\\book_player_limit.ini"
  local ini = ini_manager:LoadIniToManager("ini\\ui\\book_player_limit.ini")
  local section_count = ini:GetSectionCount()
  local min_player = 0
  local max_player = 0
  for i = 1, section_count do
    local max_num = nx_number(ini:ReadInteger(i - 1, "max", 99999999))
    local min_num = nx_number(ini:ReadInteger(i - 1, "min", 0))
    if min_player_book >= min_num and min_player_book < max_num then
      min_player = min_num
      max_player = max_num
    end
  end
  ini_manager:UnloadIniFromManager(file_name)
  for i, rbtn in ipairs(openbook_table) do
    if nx_name(rbtn) == "RadioButton" and nx_find_custom(rbtn, "num") then
      if nx_int(rbtn.num) >= nx_int(max_player) then
        rbtn.Enabled = false
      else
        rbtn.Enabled = true
      end
    end
  end
  local min_player_rbtn = nx_custom(form, min_player_rbtn_name)
  if nx_is_valid(min_player_rbtn) then
    form.lbl_new.Top = min_player_rbtn.Top
    min_player_rbtn.is_recommend = true
    min_player_rbtn.Checked = true
  end
end
function create_animation(form, ani_name, groupscrollbox)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(groupscrollbox) then
    return
  end
  local rbtn = groupscrollbox:Find("rbtn_" .. nx_string(form.cur_select_school))
  if not nx_is_valid(rbtn) then
    return
  end
  local animation = form:Find("ani_rbtn_check")
  if nx_is_valid(animation) then
    gui:Delete(animation)
  end
  animation = gui:Create("Animation")
  form:Add(animation)
  animation.Visible = false
  if nx_is_valid(rbtn) then
    animation.AbsTop = rbtn.AbsTop
    animation.AbsLeft = rbtn.AbsLeft
  else
    animation.Top = 0
    animation.Left = 0
  end
  animation.AnimationImage = ani_name .. "_down"
  animation.Loop = false
  form:ToFront(animation)
  animation.Name = "ani_rbtn_check"
  nx_bind_script(animation, "form_stage_create\\form_create_select_menpai")
  nx_callback(animation, "on_animation_end", "animation_event_end")
  animation.Visible = true
  animation:Stop()
  animation:Play()
end
function animation_event_end(animation, ani_name, mode)
  if nx_is_valid(animation) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui:Delete(animation)
    else
      local world = nx_value("world")
      if nx_is_valid(world) then
        world:Delete(animation)
      end
    end
  end
end
function play_school_checked_action(form, sex)
  if not nx_is_valid(form) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(form.actor_man) then
    return
  end
  if not nx_is_valid(form.actor_woman) then
    return
  end
  wait_action_end(form, false)
  action:ClearState(form.actor_man)
  action:BlendAction(form.actor_man, "stand", true, true)
  action:ClearState(form.actor_woman)
  action:BlendAction(form.actor_woman, "stand", true, true)
  local action_out_man = ""
  local action_out_woman = ""
  if form.body == 1 then
    action_out_man = "s_leave"
    action_out_woman = "s_leave"
  elseif form.body == 2 then
    action_out_man = form_create_introduce:GetSchoolLeaveAction(form.cur_select_school .. form.actor_man.cloth_sex)
    action_out_woman = form_create_introduce:GetSchoolLeaveAction(form.cur_select_school .. form.actor_woman.cloth_sex)
  end
  if action_out_man ~= "" then
    action:BlendAction(form.actor_man, action_out_man, false, false)
  end
  if action_out_woman ~= "" then
    action:BlendAction(form.actor_woman, action_out_woman, false, false)
  end
  local actor2 = form.actor_woman
  local actor2_action_name = action_out_woman
  if form.actor_man.Visible then
    actor2 = form.actor_man
    actor2_action_name = action_out_man
  end
  nx_execute(nx_current(), "play_action_jump_out", form, form.actor_man, form.actor_woman, actor2, actor2_action_name, sex)
end
function play_sex_checked_action(actor2_on, actor2_down)
  if not nx_is_valid(actor2_on) then
    return
  end
  local form = nx_value("form_stage_create\\form_create_select_menpai")
  if not nx_is_valid(form) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(form.actor_man) then
    return
  end
  if not nx_is_valid(form.actor_woman) then
    return
  end
  set_camera_direct(actor2_on.cloth_sex, true)
  action:ClearState(form.actor_man)
  action:BlendAction(form.actor_man, "stand", true, true)
  action:ClearState(form.actor_woman)
  action:BlendAction(form.actor_woman, "stand", true, true)
  local action_on_name = ""
  if form.body == 1 then
    action_on_name = "s_preview"
  elseif form.body == 2 then
    action_on_name = form_create_introduce:GetSchoolPreviewAction(form.cur_select_school .. actor2_on.cloth_sex)
  end
  form_create_introduce:PlayAction(actor2_on, action_on_name)
  local action_down_name = ""
  if nx_is_valid(actor2_down) then
    if form.body == 1 then
      action_down_name = "s_back"
    elseif form.body == 2 then
      action_down_name = form_create_introduce:GetSchoolBackAction(form.cur_select_school .. actor2_down.cloth_sex)
    end
    form_create_introduce:PlayAction(actor2_down, action_down_name)
    nx_execute(nx_current(), "wait_action_down_end", form, actor2_down, action_down_name)
  end
  nx_execute(nx_current(), "wait_action_on_end", form, actor2_on, action_on_name)
end
function wait_action_on_end(form, actor2, action_name)
  local action = nx_value("action_module")
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  local time_count = 0
  while nx_is_valid(action) and not action:ActionFinished(actor2, action_name) do
    time_count = time_count + nx_pause(0)
  end
  local time_delay = time_count + 0.5
  while time_count < time_delay do
    time_count = time_count + nx_pause(0)
  end
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  set_npc_default_pos(actor2, "mengpai_pos_main")
  set_school_default_action(form)
  wait_action_end(form, true)
end
function wait_action_down_end(form, actor2, action_name)
  local action = nx_value("action_module")
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  local time_count = 0
  while nx_is_valid(action) and not action:ActionFinished(actor2, action_name) do
    time_count = time_count + nx_pause(0)
  end
  local time_delay = time_count + 0.5
  while time_count < time_delay do
    time_count = time_count + nx_pause(0)
  end
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  if form.sex == 0 then
    set_npc_default_pos(actor2, "mengpai_pos_g")
  elseif form.sex == 1 then
    set_npc_default_pos(actor2, "mengpai_pos_b")
  end
end
function play_action_jump_out(form, actor_man, actor_woman, actor2, action_name, before_sex)
  local action = nx_value("action_module")
  if not (nx_is_valid(action) and nx_is_valid(actor_man) and nx_is_valid(form) and nx_is_valid(actor_woman)) or not nx_is_valid(actor2) then
    return
  end
  local time_count = 0
  while nx_is_valid(action) and not action:ActionFinished(actor2, action_name) do
    time_count = time_count + nx_pause(0)
  end
  if not (nx_is_valid(action) and nx_is_valid(actor_man) and nx_is_valid(form)) or not nx_is_valid(actor_woman) then
    return
  end
  actor_man.Visible = false
  actor_woman.Visible = false
  if form.sex == 0 then
    set_npc_default_pos(actor_woman, "mengpai_pos_g")
  else
    set_npc_default_pos(actor_man, "mengpai_pos_b")
  end
  update_model_cloth(form)
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local action_man_name = ""
  local action_woman_name = ""
  if form.body == 1 then
    action_man_name = "s_entrance"
    action_woman_name = "s_entrance"
  elseif form.body == 2 then
    action_man_name = form_create_introduce:GetSchoolEntranceAction(form.cur_select_school .. actor_man.cloth_sex)
    action_woman_name = form_create_introduce:GetSchoolEntranceAction(form.cur_select_school .. actor_woman.cloth_sex)
  end
  if action_man_name ~= "" then
    action:DoAction(actor_man, action_man_name)
  end
  if action_woman_name ~= "" then
    action:DoAction(actor_woman, action_woman_name)
  end
  init_action_visible(form)
  local actor2 = actor_woman
  local actor2_action_name = action_woman_name
  if actor_man.Visible then
    actor2 = actor_man
    actor2_action_name = action_man_name
  end
  nx_execute(nx_current(), "play_action_jump_in", form, actor2, actor2_action_name, before_sex)
end
function play_action_jump_in(form, actor2, action_name, before_sex)
  local action = nx_value("action_module")
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  local time_count = 0
  while nx_is_valid(action) and not action:ActionFinished(actor2, action_name) do
    time_count = time_count + nx_pause(0)
  end
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  if before_sex ~= form.sex then
    if form.actor_man.Visible then
      play_sex_checked_action(form.actor_man, nil)
    else
      play_sex_checked_action(form.actor_woman, nil)
    end
    reset_model_cloth(form, form.sex)
  else
    set_school_default_action(form)
    wait_action_end(form, true)
  end
end
function add_light(scene)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\form\\light_set_create.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local point_light_red = ini:ReadInteger("light", "point_light_red", game_config.point_light_red)
  local point_light_green = ini:ReadInteger("light", "point_light_green", game_config.point_light_green)
  local point_light_blue = ini:ReadInteger("light", "point_light_blue", game_config.point_light_blue)
  local point_light_range = ini:ReadFloat("light", "point_light_range", game_config.point_light_range)
  local point_light_intensity = ini:ReadFloat("light", "point_light_intensity", game_config.point_light_intensity)
  local point_light_pos_x = ini:ReadFloat("light", "point_light_pos_x", game_config.point_light_pos_x)
  local point_light_pos_y = ini:ReadFloat("light", "point_light_pos_y", game_config.point_light_pos_y)
  local point_light_pos_z = ini:ReadFloat("light", "point_light_pos_z", game_config.point_light_pos_z)
  nx_destroy(ini)
  if not nx_is_valid(scene) then
    return
  end
  local light_man = scene.light_man
  if not nx_is_valid(light_man) then
    return
  end
  if not nx_find_custom(scene, "light") or not nx_is_valid(scene.light) then
    local light = light_man:Create()
    scene.light = light
  end
  local light = scene.light
  light.LightType = "point"
  light:Load()
  scene:AddObject(light, 20)
  light.Color = "255," .. nx_string(point_light_red) .. "," .. nx_string(point_light_green) .. "," .. nx_string(point_light_blue)
  light.Range = point_light_range
  light.Intensity = point_light_intensity
  light.Attenu0 = 0
  light.Attenu1 = 1
  light.Attenu2 = 0
  light:SetPosition(point_light_pos_x, point_light_pos_y, point_light_pos_z)
  scene:Load()
end
local put_effectmodel = function(scene, terrain, camera, name, effectmodel_config, effectmodel_name, x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, tag)
  effectmodel_config = "map\\" .. effectmodel_config
  local effectmodel = scene:Create("EffectModel")
  if not nx_is_valid(effectmodel) then
    return nx_null()
  end
  effectmodel.AsyncLoad = true
  effectmodel:SetPosition(x, y, z)
  effectmodel:SetAngle(angle_x, angle_y, angle_z)
  effectmodel:SetScale(scale_x, scale_y, scale_z)
  if not effectmodel:CreateFromIniEx(effectmodel_config, effectmodel_name, false, "map\\") then
    nx_log("create effectmodel from ini file failed")
    nx_log("create " .. effectmodel_config)
    nx_log("create " .. effectmodel_name)
    return nx_null()
  end
  while not effectmodel.LoadFinish do
    nx_log("effectmodel.LoadFinish")
    nx_pause(0)
  end
  effectmodel.name = name
  effectmodel.config = effectmodel_config
  effectmodel.effectmodel_config = effectmodel_config
  effectmodel.effectmodel_name = effectmodel_name
  effectmodel.clip_radius = 0
  effectmodel.WaterReflect = false
  effectmodel.tag = tag
  return effectmodel
end
function create_show_in_scene(scene, terrain, camera, x, y, z, effectmodel_config, effectmodel_name)
  local weather_model = nx_null()
  if nx_find_custom(scene, "weather_model") then
    weather_model = scene.weather_model
  end
  if not nx_is_valid(weather_model) then
    local name = nx_function("ext_gen_unique_name")
    local pos_x, pos_y, pos_z = camera.PositionX, camera.PositionY, camera.PositionZ
    local angle_x, angle_y, angle_z = 0, 0, 0
    local scale_x, scale_y, scale_z = 1, 1, 1
    local tag = 0
    local effectmodel = put_effectmodel(scene, terrain, camera, name, effectmodel_config, effectmodel_name, pos_x, pos_y, pos_z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, tag)
    scene.weather_model = effectmodel
    if not nx_is_valid(effectmodel) then
      return
    end
    while not effectmodel.LoadFinish do
      nx_pause(0.1)
      if not nx_is_valid(scene) or not nx_is_valid(effectmodel) then
        return
      end
    end
    effectmodel:SetPosition(x, y, z)
    effectmodel:SetAngle(0, 0, 0)
    scene:AddObject(effectmodel, 20)
    scene.ClearZBuffer = true
    local helper_list = effectmodel:GetHelperNameList()
    effectmodel:AddParticle(effectmodel_name, helper_list[1], -1, -1)
  end
end
function on_rbtn_shili_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupscrollbox_8_school.Visible = false
    form.groupscrollbox_jh_school.Visible = true
    form.groupscrollbox_ys_school.Visible = false
    form.rbtn_force_xujia.Enabled = false
    form.rbtn_force_xujia.Checked = true
    form.rbtn_force_xujia.Enabled = true
    form.rbtn_force_xujia.Width = 456
    form.rbtn_force_xujia.Height = 142
    form.groupscrollbox_jh_school:ResetChildrenYPos()
    show_select_school_info(form, form.rbtn_force_xujia, form.rbtn_force_xujia.DataSource, 0)
    form.lbl_force_tips.Visible = true
    wait_action_end(form, false)
    form.lbl_6.BackImage = nx_string(SPECIAL_FORCE_IMG)
    form.lbl_lock.Visible = true
  end
end
function on_rbtn_8_school_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupscrollbox_8_school.Visible = true
    form.groupscrollbox_jh_school.Visible = false
    form.groupscrollbox_ys_school.Visible = false
    form.rbtn_school_shaolin.Enabled = false
    form.rbtn_school_shaolin.Checked = true
    form.rbtn_school_shaolin.Enabled = true
    form.rbtn_school_shaolin.Width = 456
    form.rbtn_school_shaolin.Height = 142
    form.groupscrollbox_8_school:ResetChildrenYPos()
    show_select_school_info(form, form.rbtn_school_shaolin, form.rbtn_school_shaolin.DataSource, 1)
    wait_action_end(form, false)
    form.lbl_6.BackImage = nx_string(NORMAL_SCHOOL_IMG)
    if form.body == 2 then
      form.lbl_lock.Visible = false
    end
  end
end
function on_rbtn_new_school_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupscrollbox_8_school.Visible = false
    form.groupscrollbox_jh_school.Visible = false
    form.groupscrollbox_ys_school.Visible = true
    form.rbtn_newschool_damo.Enabled = false
    form.rbtn_newschool_damo.Checked = true
    form.rbtn_newschool_damo.Enabled = true
    form.rbtn_newschool_damo.Width = 456
    form.rbtn_newschool_damo.Height = 142
    form.groupscrollbox_ys_school:ResetChildrenYPos()
    show_select_school_info(form, form.rbtn_newschool_damo, form.rbtn_newschool_damo.DataSource, 0)
    form.lbl_force_tips.Visible = true
    form.lbl_6.BackImage = nx_string(SPECIAL_FORCE_IMG)
    form.lbl_lock.Visible = true
    wait_action_end(form, false)
  end
end
function on_rbtn_newschool_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.DataSource == "" then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  if rbtn.Checked then
    form.btn_enter_game.Visible = false
    form.lbl_force_tips.Visible = true
    rbtn.Width = 456
    rbtn.Height = 142
    play_school_checked_action(form, form.sex)
    form.cur_select_school = rbtn.DataSource
    form.is_school = 0
    reset_model_cloth(form, form.sex)
    init_rbtn(form)
    nx_execute(nx_current(), "show_select_school", form.cur_select_school)
    rbtn.CheckedImage = form_create_introduce:GetRbtnBackImageDown(rbtn.DataSource)
  else
    rbtn.Width = 230
    rbtn.Height = 35
    form.groupscrollbox_ys_school:ResetChildrenYPos()
    create_animation(form, form.cur_select_school, form.groupscrollbox_ys_school)
    rbtn.CheckedImage = form_create_introduce:GetRbtnBackImage(rbtn.DataSource)
  end
end
function show_select_school_info(form, rbtn, school, is_school)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(rbtn) then
    return
  end
  if school == "" then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  form.cur_select_school = school
  form.is_school = is_school
  if is_school == 1 and form.body == 2 then
    form.btn_enter_game.Visible = true
    form.lbl_force_tips.Visible = false
  else
    form.btn_enter_game.Visible = false
    form.lbl_force_tips.Visible = true
  end
  play_school_checked_action(form, form.sex)
  reset_model_cloth(form, form.sex)
  init_rbtn(form)
  nx_execute(nx_current(), "show_select_school", form.cur_select_school)
  create_animation(form, form.cur_select_school, rbtn.Parent)
  rbtn.CheckedImage = form_create_introduce:GetRbtnBackImageDown(school)
end
function set_rbtn_enabled(groupbox, flag)
  local rbtns = groupbox:GetChildControlList()
  if flag then
    for _, btn in ipairs(rbtns) do
      if nx_name(btn) == "RadioButton" then
        btn.Enabled = flag
      end
    end
  elseif groupbox.Name == "groupbox_sex" then
    for _, btn in ipairs(rbtns) do
      if nx_name(btn) == "RadioButton" then
        btn.Enabled = flag
      end
    end
  else
    for _, btn in ipairs(rbtns) do
      if nx_name(btn) == "RadioButton" and not btn.Checked then
        btn.Enabled = flag
      end
    end
  end
end
function wait_action_end(form, flag)
  if not nx_is_valid(form) then
    return
  end
  form.btn_zhezhao.Visible = not flag
  if flag then
    form.groupscrollbox_ys_school.BlendAlpha = 255
    form.groupscrollbox_8_school.BlendAlpha = 255
    form.groupscrollbox_jh_school.BlendAlpha = 255
    form.groupbox_desc.BlendAlpha = 255
  else
    form.groupscrollbox_ys_school.BlendAlpha = 100
    form.groupscrollbox_8_school.BlendAlpha = 100
    form.groupscrollbox_jh_school.BlendAlpha = 100
    form.groupbox_desc.BlendAlpha = 100
  end
end
function set_school_default_action(form)
  if not nx_is_valid(form) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  if form.sex == 0 then
    action:BlendAction(form.actor_man, "stand", true, true)
    local action_name = form_create_introduce:GetSchoolAwaitAction(form.cur_select_school .. "_g")
    if form.actor_woman.Visible then
      action:BlendAction(form.actor_woman, action_name, true, true)
    end
  elseif form.sex == 1 then
    action:BlendAction(form.actor_woman, "stand", true, true)
    local action_name = form_create_introduce:GetSchoolAwaitAction(form.cur_select_school .. "_b")
    if form.actor_man.Visible then
      action:BlendAction(form.actor_man, action_name, true, true)
    end
  end
end
function set_npc_default_pos(actor2, key, key_ang)
  local x = nx_number(get_ini_prop(FINE_POS_INI, key, "PositionX", "-1"))
  local y = nx_number(get_ini_prop(FINE_POS_INI, key, "PositionY", "-1"))
  local z = nx_number(get_ini_prop(FINE_POS_INI, key, "PositionZ", "-1"))
  local angle_x = nx_number(get_ini_prop(FINE_POS_INI, key, "AngleX", "-1"))
  local angle_y = nx_number(get_ini_prop(FINE_POS_INI, key, "AngleY", "-1"))
  local angle_z = nx_number(get_ini_prop(FINE_POS_INI, key, "AngleZ", "-1"))
  if nx_is_valid(actor2) then
    actor2:SetPosition(x, y, z)
    if key ~= "mengpai_pos_main" then
      actor2:SetAngle(angle_x, angle_y, angle_z)
    end
  end
  if key_ang ~= nil and key_ang ~= "" then
    local angle_x = nx_number(get_ini_prop(FINE_POS_INI, key_ang, "AngleX", "-1"))
    local angle_y = nx_number(get_ini_prop(FINE_POS_INI, key_ang, "AngleY", "-1"))
    local angle_z = nx_number(get_ini_prop(FINE_POS_INI, key_ang, "AngleZ", "-1"))
    actor2:SetAngle(angle_x, angle_y, angle_z)
  end
end
function init_action_visible(form)
  if not nx_is_valid(form) then
    return
  end
  if form.cur_select_school == "" then
    return
  end
  if not nx_is_valid(form.actor_man) or not nx_is_valid(form.actor_woman) then
    return
  end
  if form.cur_select_school == "school_emei" or form.cur_select_school == "force_yihua" or form.cur_select_school == "newschool_shenshui" then
    form.actor_man.Visible = false
    form.actor_woman.Visible = true
  elseif form.cur_select_school == "school_shaolin" or form.cur_select_school == "force_wugeng" or form.cur_select_school == "newschool_damo" then
    form.actor_man.Visible = true
    form.actor_woman.Visible = false
  else
    form.actor_man.Visible = true
    form.actor_woman.Visible = true
  end
end
function set_camera_direct(sex, b_move)
  local scene = nx_value("game_scene")
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  camera.t_time = 2000
  camera.s_time = 0
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("MoveCamera", camera)
  local ini = get_ini(FINE_POS_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  local key = "camera_boy"
  if sex == "_g" then
    key = "camera_girl"
  end
  local index = ini:FindSectionIndex(nx_string(key))
  if -1 == index then
    return
  end
  local x = nx_number(get_ini_prop(FINE_POS_INI, key, "PositionX", "-1"))
  local y = nx_number(get_ini_prop(FINE_POS_INI, key, "PositionY", "-1"))
  local z = nx_number(get_ini_prop(FINE_POS_INI, key, "PositionZ", "-1"))
  local angle_x = nx_number(get_ini_prop(FINE_POS_INI, key, "AngleX", "-1"))
  local angle_y = nx_number(get_ini_prop(FINE_POS_INI, key, "AngleY", "-1"))
  local angle_z = nx_number(get_ini_prop(FINE_POS_INI, key, "AngleZ", "-1"))
  if b_move then
    asynor:AddExecute("MoveCamera", camera, nx_float(0), nx_float(camera.PositionX), nx_float(camera.PositionY), nx_float(camera.PositionZ), nx_float(camera.AngleX), nx_float(camera.AngleY), nx_float(camera.AngleZ), nx_float(x), nx_float(y), nx_float(z), nx_float(angle_x), nx_float(angle_y), nx_float(angle_z))
  else
    camera:SetPosition(x, y, z)
    camera:SetAngle(angle_x, angle_y, angle_z)
  end
end
function on_rbtn_small_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local scene = nx_value("game_scene")
    if not nx_is_valid(scene) then
      return
    end
    if not nx_is_valid(form.actor_man) then
      return
    end
    if not nx_is_valid(form.actor_woman) then
      return
    end
    local form_create_introduce = nx_value("form_create_introduce")
    if not nx_is_valid(form_create_introduce) then
      return
    end
    local timer = nx_value("timer_game")
    if not nx_is_valid(timer) then
      return
    end
    form.ani_6.Visible = false
    form.lbl_lock.Visible = true
    form.groupbox_2.Visible = true
    form.btn_enter_game.Visible = false
    form.lbl_force_tips.Visible = true
    wait_action_end(form, false)
    timer:Register(2000, 1, nx_current(), "change_body_timer", form, -1, -1)
    nx_execute(nx_current(), "play_effect", form)
    scene:Delete(form.actor_man)
    scene:Delete(form.actor_woman)
    form.body = 1
    local cloth = form_create_introduce:GetSmallCloth(form.cur_select_school)
    show_cloth(cloth, form, form.sex)
    nx_execute(nx_current(), "add_small_model_to_scene", form, scene)
  end
end
function on_rbtn_normal_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local scene = nx_value("game_scene")
    if not nx_is_valid(scene) then
      return
    end
    if not nx_is_valid(form.actor_man) then
      return
    end
    if not nx_is_valid(form.actor_woman) then
      return
    end
    local form_create_introduce = nx_value("form_create_introduce")
    if not nx_is_valid(form_create_introduce) then
      return
    end
    local timer = nx_value("timer_game")
    if not nx_is_valid(timer) then
      return
    end
    form.ani_6.Visible = false
    form.groupbox_2.Visible = false
    if form.is_school == 1 then
      form.btn_enter_game.Visible = true
      form.lbl_force_tips.Visible = false
    end
    wait_action_end(form, false)
    timer:Register(2000, 1, nx_current(), "change_body_timer", form, -1, -1)
    if form.is_school == 1 then
      form.lbl_lock.Visible = false
    end
    nx_execute(nx_current(), "play_effect", form)
    scene:Delete(form.actor_man)
    scene:Delete(form.actor_woman)
    form.body = 2
    local cloth = form_create_introduce:GetSchoolCloth(form.cur_select_school)
    show_cloth(cloth, form, form.sex)
    nx_execute(nx_current(), "add_model_to_scene", form, scene, false)
  end
end
function play_effect(form)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect) then
    return
  end
  if not nx_is_valid(form.actor_man) then
    return
  end
  if not nx_is_valid(form.actor_woman) then
    return
  end
  if form.actor_man.Visible then
    if form.sex == 0 then
      game_effect:CreateEffect("SizeChange", form.actor_empty_3, form.actor_empty_3, "", "", "", "", form.actor_empty_3, true)
    else
      game_effect:CreateEffect("SizeChange", form.actor_empty_1, form.actor_empty_1, "", "", "", "", form.actor_empty_1, true)
    end
  end
  if form.actor_woman.Visible then
    if form.sex == 0 then
      game_effect:CreateEffect("SizeChange", form.actor_empty_2, form.actor_empty_2, "", "", "", "", form.actor_empty_2, true)
    else
      game_effect:CreateEffect("SizeChange", form.actor_empty_3, form.actor_empty_3, "", "", "", "", form.actor_empty_3, true)
    end
  end
end
function change_size_btn_image(form, type)
  if not nx_is_valid(form) then
    return
  end
  if type == "man" then
    form.rbtn_small.NormalImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_lq_out.png"
    form.rbtn_small.FocusImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_lq_on.png"
    form.rbtn_small.CheckedImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_lq_down.png"
    form.rbtn_small.DisableImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_lq_out.png"
    form.rbtn_big.NormalImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_kw_out.png"
    form.rbtn_big.FocusImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_kw_on.png"
    form.rbtn_big.CheckedImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_kw_down.png"
    form.rbtn_big.DisableImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_kw_forbid.png"
  else
    form.rbtn_small.NormalImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_jx_out.png"
    form.rbtn_small.FocusImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_jx_on.png"
    form.rbtn_small.CheckedImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_jx_down.png"
    form.rbtn_small.DisableImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_jx_out.png"
    form.rbtn_big.NormalImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_gt_out.png"
    form.rbtn_big.FocusImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_gt_on.png"
    form.rbtn_big.CheckedImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_gt_down.png"
    form.rbtn_big.DisableImage = "gui\\language\\ChineseS\\create\\creat_new\\tg_gt_forbid.png"
  end
end
function change_body_timer(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  wait_action_end(form, true)
end
function show_bow_n_arrow(b_link, actor2, bow, arrow_case)
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local actor_role = game_visual:QueryActRole(actor2)
  if not nx_is_valid(actor_role) then
    return
  end
  if nx_boolean(b_link) then
    nx_set_custom(actor2, "wuxue_book_set", "0h")
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::B_weaponR_01", bow)
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::B_weaponR_01", arrow_case)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    if nx_is_valid(shot_weapon) then
      shot_weapon.Visible = true
    end
    game_visual:SetRoleWeaponName(actor2, bow)
  else
    if nx_find_custom(actor2, "wuxue_book_set") then
      actor2.wuxue_book_set = nil
    else
      nx_set_custom(actor2, "wuxue_book_set", "")
    end
    role_composite:UnLinkWeapon(actor2)
    actor_role:UnLink("ShotWeapon", false)
  end
end
