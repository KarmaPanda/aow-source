require("role_composite")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
local show_role_info = {}
function open_form(...)
  show_role_info = {}
  local count = table.getn(arg) % 4
  if 0 < count then
    return
  end
  count = table.getn(arg) / 4
  for i = 1, count do
    local value = {}
    value.sex = arg[(i - 1) * 4 + 1]
    value.face = arg[(i - 1) * 4 + 2]
    value.workcloth = arg[(i - 1) * 4 + 3]
    value.name = arg[(i - 1) * 4 + 4]
    table.insert(show_role_info, value)
  end
  util_auto_show_hide_form(nx_current())
end
function on_main_form_init(self)
  self.Fixed = true
end
function util_addscene_to_scenebox(scenebox)
  local ambient_red = 130
  local ambient_green = 174
  local ambient_blue = 237
  local ambient_intensity = 2
  local sunglow_red = 255
  local sunglow_green = 191
  local sunglow_blue = 127
  local sunglow_intensity = 1.5
  local sun_height = 9
  local sun_azimuth = 91
  local point_light_red = 255
  local point_light_green = 174
  local point_light_blue = 104
  local point_light_range = 1300
  local point_light_intensity = 0
  local point_light_pos_x = 30
  local point_light_pos_y = 75
  local point_light_pos_z = 55
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    local world = nx_value("world")
    scene = world:Create("Scene")
    scenebox.Scene = scene
    local weather = scene.Weather
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
    weather:MakeSunDirection(sun_height_rad, 3)
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
    scene.camera:SetPosition(0, -0.1, -5)
    scene.camera:SetAngle(-0.12, 0, 0)
    local particle_man = nx_null()
    if not nx_is_valid(particle_man) then
      particle_man = scene:Create("ParticleManager")
      particle_man.TexturePath = "map\\tex\\particles\\"
      particle_man:Load()
      particle_man.EnableCacheIni = true
      scene:AddObject(particle_man, 100)
      scene.particle_man = particle_man
    end
    scene:Load()
  end
  create_terrain(scene, 1, 4, 100, 100)
  local game_effect = nx_create("GameEffect")
  if nx_is_valid(game_effect) then
    nx_bind_script(game_effect, "game_effect", "game_effect_init", scene)
    if not nx_is_valid(game_effect.Scene) then
      game_effect.Scene = scene
    end
    if not nx_is_valid(game_effect.Terrain) then
      game_effect.Terrain = scene.terrain
    end
    scene.game_effect = game_effect
  end
  return true
end
function on_main_form_open(self)
  if not nx_is_valid(self) then
    return
  end
  change_form_size()
  if not nx_is_valid(self.scenebox.Scene) then
    util_addscene_to_scenebox(self.scenebox)
  end
  add_role(self, 0, 0, -1, 0, 0, 3.14, 0, "CS_jh_xlsbz03", 0)
end
function add_role(form, type, PositionX, PositionY, PositionZ, AngleX, AngleY, AngleZ, action_name, action_type)
  if type > table.getn(show_role_info) - 1 then
    nx_execute(nx_current(), "flash_name_ctrl", form)
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
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_actor2 = create_role_composite(form.scenebox.Scene, true, show_role_info[type + 1].sex)
  if not nx_is_valid(role_actor2) then
    return false
  end
  while not role_actor2.LoadFinish do
    nx_pause(0)
  end
  if not nx_is_valid(role_actor2) then
    return false
  end
  link_skin(role_actor2, "face", show_role_info[type + 1].face .. ".xmod")
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    role_composite:LinkWorkSkinByString(role_actor2, show_role_info[type + 1].workcloth, show_role_info[type + 1].sex)
  end
  local name_ctrl = nx_null()
  if type == 0 then
    name_ctrl = form.lbl_main_role
  elseif type == 1 then
    name_ctrl = form.lbl_left_role
  elseif type == 2 then
    name_ctrl = form.lbl_right_role
  end
  if nx_is_valid(name_ctrl) then
    name_ctrl.Text = nx_widestr(show_role_info[type + 1].name)
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CreateRoleUserData(role_actor2)
  nx_function("ext_set_role_create_finish", role_actor2, true)
  add_model_to_scenebox(form.scenebox, role_actor2, PositionX, PositionY, PositionZ, AngleX, AngleY, AngleZ)
  play_action(role_actor2, action_name, action_type)
  nx_execute(nx_current(), "set_role_end_pos", form, role_actor2, action_name, type, action_type)
end
function add_model_to_scenebox(scenebox, model, PositionX, PositionY, PositionZ, AngleX, AngleY, AngleZ)
  if not nx_is_valid(scenebox) then
    return false
  end
  if not nx_is_valid(model) then
    return false
  end
  if not nx_is_valid(scenebox.Scene) then
    return false
  end
  local scene = scenebox.Scene
  while not model.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(scene) or not nx_is_valid(model) then
      return false
    end
  end
  model:SetPosition(PositionX, PositionY, PositionZ)
  model:SetAngle(AngleX, AngleY, AngleZ)
  scene:AddObject(model, 20)
  scene.ClearZBuffer = true
  return true
end
function play_action(role, action_name, type)
  if type == 0 then
    local skill_effect = nx_value("skill_effect")
    if not nx_is_valid(skill_effect) then
      return
    end
    skill_effect:BeginShowZhaoshi(role_actor2, action_name)
  else
    local form_create_introduce = nx_value("form_create_introduce")
    if not nx_is_valid(form_create_introduce) then
      form_create_introduce = nx_create("form_create_introduce")
      nx_set_value("form_create_introduce", form_create_introduce)
    end
    form_create_introduce:PlayAction(role, action_name)
  end
end
function set_role_end_pos(form, actor2, action_name, type, action_type)
  local action = nx_value("action_module")
  if not nx_is_valid(action) or not nx_is_valid(actor2) then
    return
  end
  local time_count = 0
  if action_type == 0 then
    local skill_effect = nx_value("skill_effect")
    if not nx_is_valid(skill_effect) then
      return
    end
    while nx_is_valid(action) and skill_effect:IsPlayShowZhaoShi(actor2) do
      nx_pause(0.1)
    end
  else
    while nx_is_valid(action) and not action:ActionFinished(actor2, action_name) do
      time_count = time_count + nx_pause(0)
      if 10 < time_count then
        break
      end
    end
  end
  if type == 0 then
    action:BlendAction(actor2, "stand", true, true)
  elseif type == 1 then
    action:BlendAction(actor2, "new_stand_free01", true, true)
  elseif type == 2 then
    action:BlendAction(actor2, "new_stand_free02", true, true)
    nx_execute(nx_current(), "flash_name_ctrl", form)
  end
  local time_delay = time_count + 0
  while time_count < time_delay do
    time_count = time_count + nx_pause(0)
  end
  if not nx_is_valid(action) or not nx_is_valid(actor2) then
    return
  end
  if type == 1 then
    add_role(form, 2, 0, -1, 4, 0, -3.5, 0, "apex_show_03", 1)
  elseif type == 0 then
    add_role(form, 1, 0, -1, 4.25, 0, 3.45, 0, "apex_show_02", 1)
  end
end
function on_main_form_close(self)
  if nx_running(nx_current(), "set_role_end_pos") then
    nx_kill(nx_current(), "set_role_end_pos")
  end
  if nx_running(nx_current(), "flash_name_ctrl") then
    nx_kill(nx_current(), "flash_name_ctrl")
  end
  if nx_running(nx_current(), "flash_title_ctrl") then
    nx_kill(nx_current(), "flash_title_ctrl")
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "auto_close_form", self)
  end
  local scene = self.scenebox.Scene
  if nx_is_valid(scene) and nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
    scene:Delete(scene.game_effect)
  end
  nx_destroy(self)
end
function auto_close_form(form)
  form:Close()
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_taosha\\form_team_ts_succeed")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.lbl_background.Width = gui.Desktop.Width
  form.lbl_background.Height = gui.Desktop.Height
  form.scenebox.Width = gui.Desktop.Width
  form.scenebox.Height = gui.Desktop.Height
  form.btn_close.Left = (gui.Desktop.Width - form.btn_close.Width) / 2
  form.lbl_title.Left = (gui.Desktop.Width - form.lbl_title.Width) / 2
  form.lbl_main_role.Left = (gui.Desktop.Width - form.lbl_main_role.Width) / 2
  form.lbl_left_role.Left = gui.Desktop.Width / 3 - form.lbl_left_role.Width / 2
  form.lbl_right_role.Left = gui.Desktop.Width * 2 / 3 - form.lbl_right_role.Width / 2
  form.lbl_main_role.Top = gui.Desktop.Height * 1 / 3 - form.lbl_main_role.Height / 2
  form.lbl_left_role.Top = gui.Desktop.Height * 1 / 3 - form.lbl_left_role.Height / 2
  form.lbl_right_role.Top = gui.Desktop.Height * 1 / 3 - form.lbl_right_role.Height / 2
  form.btn_close.Top = gui.Desktop.Height - 80
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function flash_name_ctrl(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local color = "255,255,255"
  local shadowcolor = "0,0,0"
  local scotch = 0
  local time_count = 0
  local time_delay = time_count + 1000
  while time_count < time_delay do
    time_count = time_count + nx_pause(0)
    scotch = scotch + 3
    if 255 < scotch then
      nx_execute(nx_current(), "flash_title_ctrl", form)
      return
    end
    form.lbl_main_role.ForeColor = nx_string(scotch) .. "," .. color
    form.lbl_left_role.ForeColor = nx_string(scotch) .. "," .. color
    form.lbl_right_role.ForeColor = nx_string(scotch) .. "," .. color
    form.lbl_main_role.ShadowColor = nx_string(scotch) .. "," .. shadowcolor
    form.lbl_left_role.ShadowColor = nx_string(scotch) .. "," .. shadowcolor
    form.lbl_right_role.ShadowColor = nx_string(scotch) .. "," .. shadowcolor
  end
  nx_msgbox(nx_string(form.lbl_main_role.ForeColor))
end
function flash_title_ctrl(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local time_count = 0
  local time_delay = time_count + 1000
  while time_count < time_delay do
    time_count = time_count + nx_pause(0)
    form.lbl_title.Height = form.lbl_title.Height + 10
    form.lbl_title.Width = form.lbl_title.Width + 85
    form.lbl_title.Left = (gui.Desktop.Width - form.lbl_title.Width) / 2
    form.lbl_title.Top = gui.Desktop.Height * 1 / 5 - form.lbl_title.Height / 2
    if form.lbl_title.Width >= 850 then
      local game_timer = nx_value("timer_game")
      if nx_is_valid(game_timer) then
        game_timer:Register(5000, 1, nx_current(), "auto_close_form", form, -1, -1)
      end
      return
    end
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
  terrain.InitHeight = -1
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
  terrain.GroundVisible = false
  return terrain
end
