require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\static_data_type")
require("util_functions")
require("share\\view_define")
require("util_role_prop")
local CAMERA_TYPE_NEAR = 1
local CAMERA_TYPE_FAR = 2
local BACK_IMG_PLAYER = "gui\\special\\attire\\attire_back\\bg.jpg"
local BACK_IMG_MOUNT = "gui\\special\\attire\\attire_back\\bg_horse.jpg"
local BACK_IMG_PET = "gui\\special\\attire\\attire_back\\bg_pet.jpg"
local SUB_FORM = {
  "form_stage_main\\form_attire\\form_attire_card",
  "form_stage_main\\form_attire\\form_attire_jianghu",
  "form_stage_main\\form_attire\\form_attire_origin",
  "form_stage_main\\form_attire\\form_attire_body"
}
local BOY_SHOW_CLOTH_ACTION = "attire_boy_"
local GIRL_SHOW_CLOTH_ACTION = "attire_girl_"
local equip_model = {
  hat_boy = "obj\\char\\b_jianghu000\\b_helmet000",
  hat_girl = "obj\\char\\g_jianghu000\\g_helmet000",
  cloth_boy = "obj\\char\\b_jianghu000\\b_cloth000",
  cloth_girl = "obj\\char\\g_jianghu000\\g_cloth000",
  pants_boy = "obj\\char\\b_jianghu000\\b_pants000",
  pants_girl = "obj\\char\\g_jianghu000\\g_pants000",
  shoes_boy = "obj\\char\\b_jianghu000\\b_shoes000",
  shoes_girl = "obj\\char\\g_jianghu000\\g_shoes000"
}
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_main"
function open_form()
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    form:Close()
  end
  if is_newjhmodule() then
    return
  end
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_main_form_init(self)
  self.camera_type = CAMERA_TYPE_FAR
  self.role_model = nx_null()
  self.role_fwz_model = nx_null()
  self.hat = ""
  self.cloth = ""
  self.pants = ""
  self.shoes = ""
  self.cloak = ""
  self.weapon = ""
  self.sf_equip = ""
  self.Fixed = true
  self.see_other = false
  self.scale_value = 0
end
function on_main_form_open(self)
  form_size(self)
  create_fwz_other()
  self.role_fwz_box.Visible = false
  self.rbtn_jh_equip.Checked = false
  self.rbtn_jh_equip.Checked = true
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    self.scale_value = game_config_info.ui_scale_value
    self.scale_value = 100
    self.tb_scale.Value = self.scale_value * 0.1
    self.lbl_scale_number.Text = nx_widestr(nx_decimals(nx_int(self.scale_value) * 0.01, 1))
    nx_execute("game_config", "set_ui_scale", true, self.scale_value)
  end
end
function on_tb_scale_value_changed(bar)
  local form = bar.ParentForm
  form.lbl_scale_number.Text = nx_widestr(nx_decimals(bar.Value * 0.1, 1))
  form.pbar_scale.Value = bar.Value
  if nx_int(form.scale_value) == nx_int(bar.Value * 10) then
    return
  end
  form.scale_value = bar.Value * 10
end
function on_btn_quedin_click(btn)
  local form = btn.ParentForm
  nx_execute("game_config", "set_ui_scale", true, form.scale_value)
end
function form_size(form)
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_main.Width = gui.Width
  form.groupbox_title.Left = (gui.Width - form.groupbox_title.Width) / 2
  form.groupbox_1.Left = (gui.Width - form.groupbox_title.Width) / 2 - 330
  form.groupbox_1.Top = form.groupbox_main.Height + 2
  form.groupbox_1.Height = gui.Height - form.groupbox_main.Height - 2
  form.role_box.Height = gui.Height - form.groupbox_main.Height - 2
  form.role_fwz_box.Height = gui.Height - form.groupbox_main.Height - 2
  form.groupbox_2.Top = form.groupbox_main.Height + 2
  form.groupbox_2.Width = gui.Width
  form.groupbox_2.Height = gui.Height - form.groupbox_main.Height - 2
end
function on_main_form_close(self)
  local count = table.getn(SUB_FORM)
  for i = 1, count do
    local sub_form = nx_value(SUB_FORM[i])
    if nx_is_valid(sub_form) then
      sub_form:Close()
    end
  end
  if nx_is_valid(self.role_model) and nx_is_valid(self.role_box.Scene) then
    self.role_box.Scene:Delete(self.role_model)
  end
  if nx_find_custom(self.role_box.Scene, "game_effect") and nx_is_valid(self.role_box.Scene.game_effect) then
    nx_destroy(self.role_box.Scene.game_effect)
  end
  if nx_find_custom(self.role_box.Scene, "terrain") and nx_is_valid(self.role_box.Scene.terrain) then
    self.role_box.Scene:Delete(self.role_box.Scene.terrain)
  end
  if nx_is_valid(self.role_fwz_model) and nx_is_valid(self.role_fwz_box.Scene) then
    self.role_fwz_box.Scene:Delete(self.role_fwz_model)
  end
  if nx_find_custom(self.role_fwz_box.Scene, "game_effect") and nx_is_valid(self.role_fwz_box.Scene.game_effect) then
    nx_destroy(self.role_fwz_box.Scene.game_effect)
  end
  if nx_find_custom(self.role_fwz_box.Scene, "terrain") and nx_is_valid(self.role_fwz_box.Scene.terrain) then
    self.role_fwz_box.Scene:Delete(self.role_fwz_box.Scene.terrain)
  end
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  local form_copy = nx_value("form_stage_main\\form_attire\\form_attire_copy")
  if nx_is_valid(form_copy) then
    form_copy:Close()
  end
  if nx_running("role_composite", "load_from_ini") then
    nx_kill("role_composite", "load_from_ini")
  end
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    nx_execute("game_config", "set_ui_scale", game_config_info.ui_scale_enable, game_config_info.ui_scale_value)
  end
  nx_destroy(self)
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
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local ambient_red = ini:ReadInteger("light", "ambient_red", game_config.ambient_red)
  local ambient_green = ini:ReadInteger("light", "ambient_green", game_config.ambient_green)
  local ambient_blue = ini:ReadInteger("light", "ambient_blue", game_config.ambient_blue)
  local ambient_intensity = ini:ReadFloat("light", "ambient_intensity", game_config.ambient_intensity)
  local sunglow_red = ini:ReadInteger("light", "sunglow_red", game_config.sunglow_red)
  local sunglow_green = ini:ReadInteger("light", "sunglow_green", game_config.sunglow_green)
  local sunglow_blue = ini:ReadInteger("light", "sunglow_blue", game_config.sunglow_blue)
  local sunglow_intensity = ini:ReadFloat("light", "sunglow_intensity", game_config.sunglow_intensity)
  local sun_height = ini:ReadInteger("light", "sun_height", game_config.sun_height)
  local sun_azimuth = ini:ReadInteger("light", "sun_azimuth", game_config.sun_azimuth)
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
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return
  end
  weather.FogEnable = false
  weather.AmbientColor = "255," .. nx_string(ambient_red) .. "," .. nx_string(ambient_green) .. "," .. nx_string(ambient_blue)
  weather.SunGlowColor = "255," .. nx_string(sunglow_red) .. "," .. nx_string(sunglow_green) .. "," .. nx_string(sunglow_blue)
  weather.SpecularColor = "255,196,196,196"
  weather.AmbientIntensity = ambient_intensity
  weather.SunGlowIntensity = sunglow_intensity
  weather.SpecularIntensity = 2
  local sun_height_rad = sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = sun_azimuth / 360 * math.pi * 2
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  if not nx_find_custom(scene, "light") then
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
  light:SetPosition(-3, 2.5, -4.5)
  scene:Load()
end
function get_item_info(configid, prop)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function create_npc_model(form, item_config, npc_type)
  if nx_running("role_composite", "load_from_ini") then
    nx_kill("role_composite", "load_from_ini")
  end
  if nx_is_valid(form.role_model) and nx_is_valid(form.role_box.Scene) then
    form.role_box.Scene:Delete(form.role_model)
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  if nx_is_valid(form.role_box.Scene) then
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
    init_effect(form.role_box.Scene)
  end
  local actor2 = form.role_box.Scene:Create("Actor2")
  if not nx_is_valid(actor2) then
    return false
  end
  form.role_model = actor2
  actor2.AsyncLoad = true
  actor2.mount = ""
  local itemArtPack = nx_int(get_item_info(item_config, "ArtPack"))
  if itemArtPack ~= "" then
    if nx_string(item_config) == nx_string("ride_feshorse_1_10") then
      actor2.mount = "npc\\ride_yunzhu_02"
    else
      actor2.mount = item_static_query(itemArtPack, 0, STATIC_DATA_ITEM_ART)
    end
    if 0 < string.len(actor2.mount) then
      nx_execute("role_composite", "load_from_ini", actor2, "ini\\" .. actor2.mount .. ".ini")
    end
  end
  if nx_string(item_config) == nx_string("pet_peacock_gensui") then
    actor2:SetScale(0.3, 0.3, 0.3)
  end
  if nx_string(item_config) == nx_string("pet_kuilei_gensui") then
    actor2:SetScale(0.3, 0.3, 0.3)
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return false
  end
  actor2.model_type = npc_type
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  form.role_model = actor2
  return true
end
function create_npc_model_by_path(model_path, npc_type)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if nx_running("role_composite", "load_from_ini") then
    nx_kill("role_composite", "load_from_ini")
  end
  if nx_is_valid(form.role_model) and nx_is_valid(form.role_box.Scene) then
    form.role_box.Scene:Delete(form.role_model)
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  if nx_is_valid(form.role_box.Scene) then
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
    init_effect(form.role_box.Scene)
  end
  local actor2 = create_actor2(form.role_box.Scene)
  if not nx_is_valid(actor2) then
    return false
  end
  form.role_model = actor2
  actor2.AsyncLoad = true
  actor2.mount = model_path
  local result = role_composite:CreateSceneObjectFromIni(actor2, "ini\\" .. actor2.mount .. ".ini")
  if not result then
    form.role_box.Scene:Delete(actor2)
  end
  if not nx_is_valid(actor2) then
    return false
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and not role_composite:GetNpcLoadFinish(actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return false
  end
  actor2.model_type = npc_type
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  form.role_model = actor2
  local radius = 2.1
  local scene = form.role_box.Scene
  if nx_is_valid(scene) then
    scene.camera:SetPosition(0, radius * 0.6, -radius * 3)
  end
  local dist = 1.2
  nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
end
function on_btn_close_click(btn)
  on_main_form_close(btn.ParentForm)
end
function on_rbtn_sf_equip_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.is_equip_fwz_weapon = false
    form.see_other = false
    switch_role_box(form, 1)
    create_sf_player()
    set_camera_direct(CAMERA_TYPE_FAR)
    set_form_main_backimg(1)
    open_sub_form(form, rbtn.TabIndex)
  end
end
function on_rbtn_jh_equip_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.is_equip_fwz_weapon = false
    form.see_other = false
    switch_role_box(form, 1)
    create_jh_player()
    set_camera_direct(CAMERA_TYPE_FAR)
    set_form_main_backimg(1)
    open_sub_form(form, rbtn.TabIndex)
    nx_execute("form_stage_main\\form_attire\\form_attire_jianghu", "refresh_form_change")
  end
end
function on_rbtn_fwz_equip_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.is_equip_fwz_weapon = false
    form.see_other = false
    local gui = nx_value("gui")
    switch_role_box(form, 1)
    create_fwz_player()
    set_camera_direct(CAMERA_TYPE_FAR)
    set_form_main_backimg(1)
    open_sub_form(form, rbtn.TabIndex)
    nx_execute("form_stage_main\\form_attire\\form_attire_card", "ctr_sex_btn", true)
  end
end
function on_rbtn_body_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.is_equip_fwz_weapon = false
  form.see_other = false
  local body_type = 0
  local sex = nx_execute(SUB_FORM[4], "get_player_prop", "Sex")
  if nx_int(sex) == nx_int(0) then
    body_type = 4
  else
    body_type = 3
  end
  create_body_player(body_type)
  switch_role_box(form, 1)
  set_form_main_backimg(1)
  set_camera_direct(CAMERA_TYPE_FAR)
  open_sub_form(form, rbtn.TabIndex)
  local form_body = nx_value(SUB_FORM[4])
  if not nx_is_valid(form_body) then
    return
  end
  nx_execute(SUB_FORM[4], "show_page", 3)
  form_body.body_type = body_type
  if nx_int(sex) == nx_int(0) then
    form_body.rbtn_zhengtai.Checked = true
  else
    form_body.rbtn_luoli.Checked = true
  end
end
function show_page_body()
  local form = util_show_form("form_stage_main\\form_attire\\form_attire_main", true)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_body.Checked = true
  on_rbtn_body_checked_changed(form.rbtn_body)
end
function open_sub_form(form_main, sub_index)
  if not nx_is_valid(form_main) then
    return
  end
  local form_path = SUB_FORM[sub_index]
  if form_path == nil or form_path == "" then
    return
  end
  local count = table.getn(SUB_FORM)
  for i = 1, count do
    local sub_form = nx_value(SUB_FORM[i])
    if nx_is_valid(sub_form) then
      sub_form.Visible = false
    end
  end
  local sub_form = nx_value(form_path)
  if nx_is_valid(sub_form) then
    sub_form.Visible = true
  else
    sub_form = util_get_form(form_path, true, true)
    if nx_is_valid(sub_form) then
      sub_form.Left = 0
      sub_form.Top = 0
      sub_form.Width = form_main.groupbox_2.Width
      sub_form.Height = form_main.groupbox_2.Height
      form_main.groupbox_2:Add(sub_form)
      sub_form.Visible = true
    end
  end
  sub_form = nx_value("form_stage_main\\form_attire\\form_attire_save")
  if nx_is_valid(sub_form) then
    sub_form:Close()
  end
end
function on_btn_model_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_model_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_model_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while nx_is_valid(form) and nx_is_valid(btn) and btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    if form.see_other then
      nx_execute("util_gui", "ui_RotateModel", form.role_fwz_box, dist)
    else
      nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
    end
  end
end
function on_btn_model_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_model_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_model_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while nx_is_valid(form) and nx_is_valid(btn) and btn.MouseDown do
    local elapse = nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    local dist = speed * elapse
    if form.see_other then
      nx_execute("util_gui", "ui_RotateModel", form.role_fwz_box, dist)
    else
      nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
    end
  end
end
function change_form_size()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  form_size(form)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  local count = table.getn(SUB_FORM)
  for i = 1, count do
    local sub_form = nx_value(SUB_FORM[i])
    if nx_is_valid(sub_form) then
      sub_form.Left = 0
      sub_form.Top = 0
      sub_form.Width = form.groupbox_2.Width
      sub_form.Height = form.groupbox_2.Height
    end
  end
end
function create_jh_player()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "role_model") and nx_is_valid(form.role_model) then
    local role_model = form.role_model
    if nx_find_custom(role_model, "model_type") and nx_int(role_model.model_type) == nx_int(1) then
      init_player_jh_model(form)
      return
    end
  end
  if nx_is_valid(form.role_model) and nx_is_valid(form.role_box.Scene) then
    form.role_box.Scene:Delete(form.role_model)
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  if nx_is_valid(form.role_box.Scene) then
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
    init_effect(form.role_box.Scene)
  end
  local actor2 = nx_execute("role_composite", "create_role_composite_simple", form.role_box.Scene, true, client_player:QueryProp("Sex"))
  if not nx_is_valid(actor2) then
    return
  end
  form.role_model = actor2
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  actor2.attire_weapon = 1
  local scene = form.role_box.Scene
  local camera = scene.camera
  camera:SetPosition(camera.PositionX, camera.PositionY, -4.2)
  actor2.model_type = 1
  local sex = client_player:QueryProp("Sex")
  actor2.sex = sex
  form.role_model = actor2
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("new_attire_stand", true, true)
  end
  local addr = ""
  if sex == 0 then
    addr = "_boy"
  elseif sex == 1 then
    addr = "_girl"
  end
  local hat_model = get_equip_model(sex, 1)
  local cloth_model = get_equip_model(sex, 3)
  local pants_model = get_equip_model(sex, 4)
  local shoes_model = get_equip_model(sex, 8)
  if hat_model == nil then
    hat_model = client_player:QueryProp("Hair")
  end
  if cloth_model == nil then
    cloth_model = equip_model["cloth" .. addr]
  end
  if pants_model == nil then
    pants_model = equip_model["pants" .. addr]
  end
  if shoes_model == nil then
    shoes_model = equip_model["shoes" .. addr]
  end
  local skin_info = {
    [1] = {link_name = "hat", model_name = hat_model},
    [2] = {link_name = "cloth", model_name = cloth_model},
    [3] = {link_name = "pants", model_name = pants_model},
    [4] = {link_name = "shoes", model_name = shoes_model}
  }
  form.hat = hat_model
  form.cloth = cloth_model
  form.pants = pants_model
  form.shoes = shoes_model
  for i, info in ipairs(skin_info) do
    if info.model_name ~= nil and "" ~= info.model_name then
      player_link_equip(info.link_name, info.model_name)
    end
  end
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  form.weapon = client_player:QueryProp("Weapon")
  role_composite:PlayerVisPropChange(actor2, client_player, "Face")
  change_action_by_weapon(actor2)
end
function init_player_jh_model(form, del_cloak)
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
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  local sex = actor2.sex
  local addr = ""
  if sex == 0 then
    addr = "_boy"
  elseif sex == 1 then
    addr = "_girl"
  end
  local hat_model = get_equip_model(sex, 1)
  local cloth_model = get_equip_model(sex, 3)
  local pants_model = get_equip_model(sex, 4)
  local shoes_model = get_equip_model(sex, 8)
  if hat_model == nil then
    hat_model = client_player:QueryProp("Hair")
  end
  if cloth_model == nil then
    cloth_model = equip_model["cloth" .. addr]
  end
  if pants_model == nil then
    pants_model = equip_model["pants" .. addr]
  end
  if shoes_model == nil then
    shoes_model = equip_model["shoes" .. addr]
  end
  local skin_info = {
    [1] = {link_name = "hat", model_name = hat_model},
    [2] = {link_name = "cloth", model_name = cloth_model},
    [3] = {link_name = "pants", model_name = pants_model},
    [4] = {link_name = "shoes", model_name = shoes_model}
  }
  role_composite:UnPlayerSkin(actor2, "hat")
  role_composite:UnPlayerSkin(actor2, "shoes")
  role_composite:UnPlayerSkin(actor2, "cloth")
  role_composite:UnPlayerSkin(actor2, "pants")
  if del_cloak == nil or del_cloak == true then
    role_composite:UnPlayerSkin(actor2, "cloak")
    role_composite:UnPlayerSkin(actor2, "waist")
    delete_face_effect(form, actor2)
    LinkCardDecorate("", 1)
    LinkCardDecorate("", 3)
    role_composite:UnLinkWeapon(actor2)
    role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
    form.weapon = client_player:QueryProp("Weapon")
  end
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  form.hat = hat_model
  form.cloth = cloth_model
  form.pants = pants_model
  form.shoes = shoes_model
  for i, info in ipairs(skin_info) do
    if info.model_name ~= nil and "" ~= info.model_name then
      player_link_equip(info.link_name, info.model_name)
    end
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  if del_cloak == nil or del_cloak == true then
    role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
    form.weapon = client_player:QueryProp("Weapon")
  end
  change_action_by_weapon(actor2)
end
function init_player_fwz_model(form, is_init, card_id)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
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
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  nx_execute("role_composite", "unlink_skin", actor2, "hat")
  if is_init == nil or is_init == true then
    role_composite:UnPlayerSkin(actor2, "cloak")
    role_composite:UnPlayerSkin(actor2, "waist")
    delete_face_effect(form, actor2)
    LinkCardDecorate("", 1)
    LinkCardDecorate("", 3)
    role_composite:UnLinkWeapon(actor2)
    role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
    form.weapon = client_player:QueryProp("Weapon")
  end
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  if is_init == nil or is_init == true then
    card_id = collect_card_manager:GetCurEquipId()
    if nx_find_custom(actor2, "model_type") and nx_number(actor2.model_type) == nx_number(3) and nx_find_custom(actor2, "body_type") then
      card_id = collect_card_manager:query_cur_body_cloth(actor2.body_type)
    end
    if card_id <= 0 then
      if nx_find_custom(actor2, "model_type") and nx_number(actor2.model_type) == nx_number(3) then
        init_player_body_model(form)
      else
        init_player_jh_model(form)
      end
      return
    end
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  show_cloth(form, female_model, male_model)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  local show_action = GIRL_SHOW_CLOTH_ACTION
  if actor2.sex == 0 then
    show_action = BOY_SHOW_CLOTH_ACTION
  end
  local rand_num = math.random(2)
  Play_role_action(show_action .. nx_string(rand_num), 2)
end
function init_player_sf_model(form)
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
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  role_composite:UnPlayerSkin(actor2, "cloak")
  role_composite:UnPlayerSkin(actor2, "waist")
  delete_face_effect(form, actor2)
  LinkCardDecorate("", 1)
  LinkCardDecorate("", 3)
  role_composite:UnLinkWeapon(actor2)
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  form.weapon = client_player:QueryProp("Weapon")
  local item = game_client:GetViewObj(nx_string(VIEWPORT_EQUIP), nx_string(16))
  if not nx_is_valid(item) then
    init_player_jh_model(form)
    return
  end
  local item_id = item:QueryProp("ConfigID")
  local sex = actor2.sex
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "Pants")
  nx_execute("role_composite", "unlink_skin", actor2, "cloak")
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  form.sf_equip = item_id
  local cloth = item_query_ArtPack_by_id_Ex(item_id, sex)
  if cloth ~= "" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", nx_string(cloth) .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "cloth_h", nx_string(cloth) .. "_h.xmod")
  end
  local model_table = {
    "HatArtPack",
    "PlantsArtPack",
    "ShoesArtPack"
  }
  local model_name = {
    "hat",
    "pants",
    "shoes"
  }
  local size = table.getn(model_table)
  for i = 1, size do
    local pack_no = get_item_info(item_id, model_table[i])
    if nx_int(pack_no) > nx_int(0) then
      local model_path = item_static_query(nx_int(pack_no), sex, STATIC_DATA_ITEM_ART)
      if model_path ~= "" then
        nx_execute("role_composite", "link_skin", actor2, model_name[i], nx_string(model_path) .. ".xmod")
      end
    end
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  form.weapon = client_player:QueryProp("Weapon")
  change_action_by_weapon(actor2)
end
function create_fwz_player()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "role_model") and nx_is_valid(form.role_model) then
    local role_model = form.role_model
    if nx_find_custom(role_model, "model_type") and nx_int(role_model.model_type) == nx_int(1) then
      init_player_fwz_model(form)
      return
    end
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local card_id = collect_card_manager:GetCurEquipId()
  if card_id <= 0 then
    create_jh_player()
    return
  end
  if nx_is_valid(form.role_model) and nx_is_valid(form.role_box.Scene) then
    form.role_box.Scene:Delete(form.role_model)
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  if nx_is_valid(form.role_box.Scene) then
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
    init_effect(form.role_box.Scene)
  end
  local actor2 = nx_execute("role_composite", "create_role_composite_simple", form.role_box.Scene, true, client_player:QueryProp("Sex"))
  if not nx_is_valid(actor2) then
    return
  end
  form.role_model = actor2
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  actor2.attire_weapon = 1
  local scene = form.role_box.Scene
  local camera = scene.camera
  camera:SetPosition(camera.PositionX, camera.PositionY, -4.2)
  actor2.model_type = 1
  local sex = client_player:QueryProp("Sex")
  actor2.sex = sex
  form.role_model = actor2
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("new_attire_stand", true, true)
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  show_cloth(form, female_model, male_model)
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  form.weapon = client_player:QueryProp("Weapon")
  role_composite:PlayerVisPropChange(actor2, client_player, "Face")
end
function show_cloth(form, female_model, male_model)
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if not nx_find_custom(actor2, "sex") then
    return
  end
  local sex = actor2.sex
  local model = ""
  if sex == 1 then
    model = female_model
  else
    model = male_model
  end
  local model_table = util_split_string(model, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  local bHat_model = false
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        local prop_name = base_table[1]
        local prop_value = base_table[2]
        if prop_name == "Hat" then
          bHat_model = true
          if prop_value == nil or prop_value == "" then
            prop_value = client_player:QueryProp("Hair")
          end
          form.hat = prop_value
          player_link_equip("hat", prop_value)
        elseif prop_name == "Shoes" then
          form.shoes = prop_value
          player_link_equip("shoes", prop_value)
        elseif prop_name == "Cloth" then
          form.cloth = prop_value
          player_link_equip("cloth", prop_value)
        elseif prop_name == "Pants" then
          form.pants = prop_value
          player_link_equip("pants", prop_value)
        elseif prop_name == "Cloak" then
          form.cloak = prop_value
          player_link_equip("cloak", prop_value)
        elseif prop_name == "Waist" then
          form.cloak = prop_value
          player_link_equip("waist", prop_value)
        end
      end
    end
  end
  if bHat_model == false then
    local hair = client_player:QueryProp("Hair")
    form.hat = hair
    player_link_equip("hat", hair)
  end
end
function create_sf_player()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "role_model") and nx_is_valid(form.role_model) then
    local role_model = form.role_model
    if nx_find_custom(role_model, "model_type") and nx_int(role_model.model_type) == nx_int(1) then
      init_player_sf_model(form)
      return
    end
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local item = game_client:GetViewObj(nx_string(VIEWPORT_EQUIP), nx_string(16))
  if not nx_is_valid(item) then
    create_jh_player()
    return
  end
  if nx_is_valid(form.role_model) and nx_is_valid(form.role_box.Scene) then
    form.role_box.Scene:Delete(form.role_model)
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  if nx_is_valid(form.role_box.Scene) then
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
    init_effect(form.role_box.Scene)
  end
  local actor2 = nx_execute("role_composite", "create_role_composite_simple", form.role_box.Scene, true, client_player:QueryProp("Sex"))
  if not nx_is_valid(actor2) then
    return
  end
  form.role_model = actor2
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  actor2.attire_weapon = 1
  local scene = form.role_box.Scene
  local camera = scene.camera
  camera:SetPosition(camera.PositionX, camera.PositionY, -4.2)
  actor2.model_type = 1
  local sex = client_player:QueryProp("Sex")
  actor2.sex = sex
  form.role_model = actor2
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("new_attire_stand", true, true)
  end
  local item_id = item:QueryProp("ConfigID")
  nx_execute("role_composite", "unlink_skin", actor2, "hat")
  nx_execute("role_composite", "unlink_skin", actor2, "shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "pants")
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  form.sf_equip = item_id
  local cloth = item_query_ArtPack_by_id_Ex(item_id, sex)
  if cloth ~= "" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", nx_string(cloth) .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "cloth_h", nx_string(cloth) .. "_h.xmod")
  end
  local model_table = {
    "HatArtPack",
    "PlantsArtPack",
    "ShoesArtPack"
  }
  local model_name = {
    "hat",
    "pants",
    "shoes"
  }
  local size = table.getn(model_table)
  for i = 1, size do
    local pack_no = get_item_info(item_id, model_table[i])
    if nx_int(pack_no) > nx_int(0) then
      local model_path = item_static_query(nx_int(pack_no), sex, STATIC_DATA_ITEM_ART)
      if model_path ~= "" then
        nx_execute("role_composite", "link_skin", actor2, model_name[i], nx_string(model_path) .. ".xmod")
      end
    end
  end
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  form.weapon = client_player:QueryProp("Weapon")
  role_composite:PlayerVisPropChange(actor2, client_player, "Face")
  change_action_by_weapon(actor2)
end
function get_equip_model(sex, equip_pos)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local item = game_client:GetViewObj(nx_string(VIEWPORT_EQUIP), nx_string(equip_pos))
  if not nx_is_valid(item) then
    return nil
  end
  local pack_id
  local id = item:QueryProp("ReplacePack")
  if id ~= nil and 0 < id then
    pack_id = id
  else
    id = item:QueryProp("ArtPack")
    if id ~= nil and 0 < id then
      pack_id = id
    end
  end
  local sex_prop_name = ""
  if sex == 0 then
    sex_prop_name = "MaleModel"
  elseif sex == 1 then
    sex_prop_name = "FemaleModel"
  end
  if sex_prop_name == "" then
    return nil
  end
  local data_query = nx_value("data_query_manager")
  local modelfile = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(pack_id), sex_prop_name)
  return modelfile
end
function create_scene_box_npc(item_config, npc_type)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  if nx_int(npc_type) == nx_int(1) then
    return
  end
  if nx_int(npc_type) == nx_int(3) then
    local camera_t = attire_manager:GetPetCamera(item_config)
    if table.getn(camera_t) < 6 then
      return
    end
  end
  if not create_npc_model(form, item_config, npc_type) then
    return
  end
  local scene = form.role_box.Scene
  local actor2 = form.role_model
  if nx_int(npc_type) == nx_int(2) then
    local radius = 2.1
    actor2:SetPosition(0, 0, 0)
    if nx_is_valid(scene) then
      scene.camera:SetPosition(0, radius * 0.6, -radius * 3.1)
    end
    local dist = 1.2
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
    if nx_string(item_config) == nx_string("attire_mount_3") then
      scene.camera:SetPosition(0, radius * 0.8, -8.99)
    elseif nx_string(item_config) == nx_string("attire_mount_5") then
      scene.camera:SetPosition(0, radius * 0.8, -10.85)
    elseif nx_string(item_config) == nx_string("attire_mount_7") then
      actor2:SetPosition(0, 1.6, 0)
      scene.camera:SetPosition(0, 4.8, -23.25)
    elseif nx_string(item_config) == nx_string("ride_feshorse_1_8") then
      actor2:SetPosition(0, 2, 0)
      scene.camera:SetPosition(0, 4.8, -10)
    elseif nx_string(item_config) == nx_string("ride_feshorse_1_10") then
      actor2:SetPosition(0, 3.5, 0)
      scene.camera:SetPosition(0, 4.8, -7.5)
    end
  elseif nx_int(npc_type) == nx_int(3) then
    local radius = 0.5
    local pos_y = 0.12
    actor2:SetPosition(0, pos_y, radius * 0.34)
    if string.find(item_config, "_line") then
      radius = 1
    end
    local camera_t = attire_manager:GetPetCamera(item_config)
    if nx_is_valid(scene) then
      scene.camera:SetPosition(camera_t[1], camera_t[2], camera_t[3])
      scene.camera:SetAngle(camera_t[4], camera_t[5], camera_t[6])
    end
    if nx_string(item_config) == nx_string("fengzheng_gensui") then
      load_from_ini(actor2, "ini\\npc\\part_back_1_16_2.ini")
      actor2:SetPosition(0, pos_y + 0.1, radius * 0.34)
      actor2:SetScale(0.3, 0.3, 0.3)
    end
  end
  local game_effect = nx_null()
  if nx_find_custom(scene, "game_effect") then
    game_effect = scene.game_effect
  end
  local effect_id = "szg_hz_2"
  if nx_is_valid(game_effect) then
    game_effect:CreateEffect(nx_string(effect_id), actor2, actor2, "", "", "", "", actor2, true)
  end
end
function set_camera_direct(camera_type)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) then
    return
  end
  local scene = form.role_box.Scene
  if not nx_is_valid(scene) then
    return
  end
  form.camera_type = camera_type
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  camera.t_time = 2000
  camera.s_time = 0
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("MoveCamera", camera)
  local camera_Z = -4.2
  local camera_Y = 0.9
  if nx_int(form.camera_type) == nx_int(1) then
    camera_Z = -1
    camera_Y = 1.5
  end
  asynor:AddExecute("MoveCamera", camera, nx_float(0), nx_float(camera.PositionX), nx_float(camera.PositionY), nx_float(camera.PositionZ), nx_float(camera.AngleX), nx_float(camera.AngleY), nx_float(camera.AngleZ), nx_float(camera.PositionX), nx_float(camera_Y), nx_float(camera_Z), nx_float(camera.AngleX), nx_float(camera.AngleY), nx_float(camera.AngleZ))
end
function player_link_equip(link_pos, model_path, see_fwz_other, fwz_card)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local actor2 = nx_null()
  if form.see_other == true or see_fwz_other == true then
    actor2 = form.role_fwz_model
  else
    actor2 = form.role_model
  end
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) and nx_int(actor2.model_type) ~= nx_int(3) then
    return
  end
  if nx_string(link_pos) == nx_string("hat") then
    link_hat_skin(role_composite, actor2, model_path)
  elseif nx_string(link_pos) == nx_string("cloth") then
    link_cloth_skin(role_composite, actor2, model_path)
  elseif nx_string(link_pos) == nx_string("pants") then
    role_composite:LinkSkin(actor2, "pants", model_path .. ".xmod", false)
  elseif nx_string(link_pos) == nx_string("shoes") then
    role_composite:LinkSkin(actor2, "shoes", model_path .. ".xmod", false)
  elseif nx_string(link_pos) == nx_string("cloak") then
    role_composite:LinkSkin(actor2, "cloak", model_path .. ".xmod", false)
  elseif nx_string(link_pos) == nx_string("waist") then
    role_composite:LinkSkin(actor2, "waist", model_path .. ".xmod", false)
  elseif nx_string(link_pos) == nx_string("weapon") then
    local data_query = nx_value("data_query_manager")
    if not nx_is_valid(data_query) then
      return
    end
    role_composite:RefreshCustomWeaponFormArtPack(actor2, nx_string(model_path))
    nx_pause(0.2)
    local sex = actor2.sex
    local model_name = "MaleModel"
    if 0 ~= sex then
      model_name = "FemaleModel"
    end
    local attire_manager = nx_value("attire_manager")
    if not nx_is_valid(attire_manager) then
      return
    end
    local sp_action = attire_manager:GetFwzWeaponAction(fwz_card)
    local table_action = util_split_string(sp_action, ",")
    actor2.fwz_a_sp = ""
    actor2.fwz_show_weapon = ""
    if table.getn(table_action) == 2 then
      actor2.fwz_a_sp = table_action[1]
      actor2.fwz_show_weapon = table_action[2]
    end
    local weapon = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(model_path), model_name)
    local action_set = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(model_path), "ActionSet")
    form.fwz_action_set = action_set
    role_composite:CreateBackSheath(actor2, weapon, weapon, action_set, true)
  end
end
function player_unlink_equip(link_pos)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(link_pos) == nx_string("hat") then
    player_link_equip(link_pos, form.hat)
  elseif nx_string(link_pos) == nx_string("cloth") then
    player_link_equip(link_pos, form.cloth)
  elseif nx_string(link_pos) == nx_string("pants") then
    player_link_equip(link_pos, form.pants)
  elseif nx_string(link_pos) == nx_string("shoes") then
    player_link_equip(link_pos, form.shoes)
  elseif nx_string(link_pos) == nx_string("cloak") then
    player_link_equip(link_pos, form.cloak)
  end
end
function player_link_sf(item_id, main_type)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if item_id == "" or item_id == nil then
    return
  end
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) then
    return
  end
  local sex = actor2.sex
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "Pants")
  nx_execute("role_composite", "unlink_skin", actor2, "cloak")
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  local cloth = item_query_ArtPack_by_id_Ex(item_id, sex)
  if cloth ~= "" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", nx_string(cloth) .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "cloth_h", nx_string(cloth) .. "_h.xmod")
  end
  local model_table = {
    "HatArtPack",
    "PlantsArtPack",
    "ShoesArtPack"
  }
  local model_name = {
    "hat",
    "pants",
    "shoes"
  }
  local size = table.getn(model_table)
  for i = 1, size do
    local pack_no = get_item_info(item_id, model_table[i])
    if nx_int(pack_no) > nx_int(0) then
      local model_path = item_static_query(nx_int(pack_no), sex, STATIC_DATA_ITEM_ART)
      if model_path ~= "" then
        nx_execute("role_composite", "link_skin", actor2, model_name[i], nx_string(model_path) .. ".xmod")
      end
    end
  end
end
function create_body_player(body_type)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "role_model") and nx_is_valid(form.role_model) then
    local role_model = form.role_model
    if nx_find_custom(role_model, "model_type") and nx_int(role_model.model_type) == nx_int(3) and nx_find_custom(role_model, "body_type") and nx_int(role_model.body_type) == nx_int(body_type) then
      init_player_body_model(form)
      return
    end
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_is_valid(form.role_model) and nx_is_valid(form.role_box.Scene) then
    form.role_box.Scene:Delete(form.role_model)
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  if nx_is_valid(form.role_box.Scene) then
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  if not nx_is_valid(form.role_box.Scene) then
    util_addscene_to_scenebox(form.role_box)
    init_effect(form.role_box.Scene)
  end
  local sex = 0
  if nx_int(body_type) == nx_int(3) or nx_int(body_type) == nx_int(5) then
    sex = 1
  end
  local actor2 = nx_execute("role_composite", "create_role_composite", form.role_box.Scene, true, sex, "stand", body_type)
  if not nx_is_valid(actor2) then
    return
  end
  form.role_model = actor2
  while nx_is_valid(form) and nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CreateRoleUserData(actor2)
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_function("ext_set_role_create_finish", actor2, true)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  actor2.attire_weapon = 1
  local scene = form.role_box.Scene
  local camera = scene.camera
  camera:SetPosition(camera.PositionX, camera.PositionY, -4.2)
  actor2.model_type = 3
  actor2.sex = sex
  actor2.body_type = body_type
  form.role_model = actor2
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("new_attire_stand", true, true)
  end
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  form.weapon = client_player:QueryProp("Weapon")
end
function init_player_body_model(form)
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
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  role_composite:UnPlayerSkin(actor2, "cloak")
  role_composite:UnPlayerSkin(actor2, "waist")
  delete_face_effect(form, actor2)
  LinkCardDecorate("", 1)
  LinkCardDecorate("", 3)
  role_composite:UnLinkWeapon(actor2)
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  form.weapon = client_player:QueryProp("Weapon")
  local sex = actor2.sex
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "Pants")
  nx_execute("role_composite", "unlink_skin", actor2, "cloak")
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  local xmod_init = body_manager:GetInitModel(actor2.body_type)
  link_skin(actor2, "hat", xmod_init[1] .. nx_string(".xmod"))
  link_skin(actor2, "cloth", xmod_init[2] .. nx_string(".xmod"))
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  form.weapon = client_player:QueryProp("Weapon")
  change_action_by_weapon(actor2)
end
function player_link_body_origin(item_id)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if item_id == "" or item_id == nil then
    return
  end
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(3) then
    return
  end
  local sex = actor2.sex
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local need_sex = item_query:GetItemPropByConfigID(item_id, "NeedSex")
  if nx_int(need_sex) ~= nx_int(2) and nx_int(need_sex) ~= nx_int(sex) then
    return
  end
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "Pants")
  local cloth = item_query_ArtPack_by_id_Ex(item_id, sex)
  if cloth ~= "" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", nx_string(cloth) .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "hat", nx_string(cloth) .. "_h.xmod")
  end
end
function player_link_body_card(card_id, is_sub_cloth)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.see_other == true then
    player_link_fwz_other(form, card_id)
    return
  end
  if nx_find_custom(form, "role_model") and nx_is_valid(form.role_model) then
    local role_model = form.role_model
    if nx_find_custom(role_model, "model_type") and nx_int(role_model.model_type) == nx_int(3) then
      init_player_card_model(form, false, card_id)
      return
    end
  end
  if is_sub_cloth == true then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) or not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.role_model) and nx_is_valid(form.role_box.Scene) then
    form.role_box.Scene:Delete(form.role_model)
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  if nx_is_valid(form.role_box.Scene) then
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
    init_effect(form.role_box.Scene)
  end
  local actor2 = nx_execute("role_composite", "create_role_composite", form.role_box.Scene, true, client_player:QueryProp("Sex"))
  if not nx_is_valid(actor2) then
    return
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  actor2.attire_weapon = 1
  actor2.model_type = 1
  local sex = client_player:QueryProp("Sex")
  actor2.sex = sex
  form.role_model = actor2
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("new_attire_stand", true, true)
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  show_cloth(form, female_model, male_model)
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  local show_action = GIRL_SHOW_CLOTH_ACTION
  if actor2.sex == 0 then
    show_action = BOY_SHOW_CLOTH_ACTION
  end
  local rand_num = math.random(2)
  Play_role_action(show_action .. nx_string(rand_num), 2)
end
function init_player_card_model(form, is_init, card_id)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
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
  local actor2 = form.role_model
  if not nx_is_valid(actor2) then
    return
  end
  nx_execute("role_composite", "unlink_skin", actor2, "hat")
  if is_init == nil or is_init == true then
    role_composite:UnPlayerSkin(actor2, "cloak")
    role_composite:UnPlayerSkin(actor2, "waist")
    delete_face_effect(form, actor2)
    LinkCardDecorate("", 1)
    LinkCardDecorate("", 3)
    role_composite:UnLinkWeapon(actor2)
    role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
    form.weapon = client_player:QueryProp("Weapon")
  end
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  if is_init == nil or is_init == true then
    card_id = collect_card_manager:GetCurEquipId()
    if card_id <= 0 then
      init_player_jh_model(form)
      return
    end
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  show_cloth(form, female_model, male_model)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  change_action_by_weapon(actor2)
  local show_action = GIRL_SHOW_CLOTH_ACTION
  if actor2.sex == 0 then
    show_action = BOY_SHOW_CLOTH_ACTION
  end
  local rand_num = math.random(2)
  Play_role_action(show_action .. nx_string(rand_num), 2)
end
function player_unlink_sf()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if form.sf_equip == "" then
    create_sf_player()
    return
  end
  local actor2 = form.role_model
  if not nx_is_valid(form.role_model) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) then
    return
  end
  local sex = actor2.sex
  local item_id = form.sf_equip
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "Pants")
  nx_execute("role_composite", "unlink_skin", actor2, "cloak")
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  local cloth = item_query_ArtPack_by_id_Ex(item_id, sex)
  if cloth ~= "" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", nx_string(cloth) .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "cloth_h", nx_string(cloth) .. "_h.xmod")
  end
  local model_table = {
    "HatArtPack",
    "PlantsArtPack",
    "ShoesArtPack"
  }
  local model_name = {
    "hat",
    "pants",
    "shoes"
  }
  local size = table.getn(model_table)
  for i = 1, size do
    local pack_no = get_item_info(item_id, model_table[i])
    if nx_int(pack_no) > nx_int(0) then
      local model_path = item_static_query(nx_int(pack_no), sex, STATIC_DATA_ITEM_ART)
      if model_path ~= "" then
        nx_execute("role_composite", "link_skin", actor2, model_name[i], nx_string(model_path) .. ".xmod")
      end
    end
  end
end
function player_link_fwz(card_id, is_sub_cloth)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.see_other == true then
    player_link_fwz_other(form, card_id)
    return
  end
  if nx_find_custom(form, "role_model") and nx_is_valid(form.role_model) then
    local role_model = form.role_model
    if nx_find_custom(role_model, "model_type") and nx_int(role_model.model_type) == nx_int(1) then
      init_player_fwz_model(form, false, card_id)
      return
    end
  end
  if is_sub_cloth == true then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) or not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.role_model) and nx_is_valid(form.role_box.Scene) then
    form.role_box.Scene:Delete(form.role_model)
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  if nx_is_valid(form.role_box.Scene) then
    local scene = form.role_box.Scene
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      nx_destroy(scene.game_effect)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
    init_effect(form.role_box.Scene)
  end
  local actor2 = nx_execute("role_composite", "create_role_composite_simple", form.role_box.Scene, true, client_player:QueryProp("Sex"))
  if not nx_is_valid(actor2) then
    return
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  actor2.attire_weapon = 1
  actor2.model_type = 1
  local sex = client_player:QueryProp("Sex")
  actor2.sex = sex
  form.role_model = actor2
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("new_attire_stand", true, true)
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  show_cloth(form, female_model, male_model)
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
  local show_action = GIRL_SHOW_CLOTH_ACTION
  if actor2.sex == 0 then
    show_action = BOY_SHOW_CLOTH_ACTION
  end
  local rand_num = math.random(2)
  Play_role_action(show_action .. nx_string(rand_num), 2)
end
function LinkCardDecorate(dec_model, sub_type)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  actor2 = form.role_model
  if form.see_other == true then
    actor2 = form.role_fwz_model
  end
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) and nx_int(actor2.model_type) ~= nx_int(3) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:DeleteRideBase(actor2)
  local action_module = nx_value("action_module")
  action_module:BlendAction(actor2, "new_attire_stand", true, true)
  UnLinkCardDecorate(form, actor2, sub_type)
  local model_table = util_split_string(dec_model, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  config_cloth_table = {}
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        local prop_name = base_table[1]
        local prop_value = base_table[2]
        collect_card_manager:LinkCardDecorate(actor2, prop_value)
        nx_set_custom(actor2, "dec_link_name" .. nx_string(sub_type), prop_value)
      end
    end
  end
end
function UnLinkCardDecorate(form, actor2, sub_type)
  if not nx_find_custom(actor2, "dec_link_name" .. nx_string(sub_type)) then
    return
  end
  local link_name = nx_custom(actor2, "dec_link_name" .. nx_string(sub_type))
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  if link_name == "" then
    return
  end
  collect_card_manager:UnLinkCardDecorate(actor2, nx_string(link_name))
  nx_set_custom(actor2, "dec_link_name" .. nx_string(sub_type), "")
end
function Play_role_action(action_id, play_type)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.role_model) then
    return
  end
  actor2 = form.role_model
  if form.see_other == true or see_fwz_other == true then
    actor2 = form.role_fwz_model
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  skill_effect:EndShowZhaoshi(actor2, "")
  action:ActionInit(actor2)
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  change_action_by_weapon(actor2)
  if nx_int(play_type) == nx_int(1) then
    skill_effect:BeginShowZhaoshi(actor2, nx_string(action_id))
  else
    action:BlendAction(actor2, nx_string(action_id), false, false)
  end
end
function init_effect(scene)
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene:Create("Terrain")
  scene.terrain = terrain
  local game_effect = nx_create("GameEffect")
  nx_bind_script(game_effect, "game_effect", "game_effect_init", scene)
  scene.game_effect = game_effect
end
function set_form_main_backimg(img_type)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if img_type == 1 then
    form.BackImage = BACK_IMG_PLAYER
  elseif img_type == 2 then
    form.BackImage = BACK_IMG_MOUNT
  elseif img_type == 3 then
    form.BackImage = BACK_IMG_PET
  end
end
function play_attire_skill_action(action_id)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.role_model) then
    return
  end
  actor2 = form.role_model
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) then
    return
  end
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, nx_string(action_id), false, false)
  end
end
function add_face_effect(card_id)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  actor2 = form.role_model
  if form.see_other == true then
    actor2 = form.role_fwz_model
  end
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) and nx_int(actor2.model_type) ~= nx_int(3) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local BufferEffect = nx_value("BufferEffect")
  if not nx_is_valid(BufferEffect) then
    return
  end
  local real_sex = 0
  if form.see_other == true then
    real_sex = 1
  end
  local buff_id = collect_card_manager:GetFaceEffectID(card_id, real_sex)
  local effect_id = BufferEffect:GetBufferEffectInfoByID(buff_id, "effect")
  local game_effect = nx_null()
  if nx_find_custom(form.role_box.Scene, "game_effect") then
    game_effect = form.role_box.Scene.game_effect
  end
  if form.see_other then
    game_effect = nx_null()
    if nx_find_custom(form.role_fwz_box.Scene, "game_effect") then
      game_effect = form.role_fwz_box.Scene.game_effect
    end
  end
  if not nx_is_valid(game_effect) then
    return
  end
  if game_effect:FindEffect(effect_id, actor2, actor2) then
    return
  end
  if nx_find_custom(actor2, "face_effect_id") and nx_string(actor2.face_effect_id) == nx_string(effect_id) then
    return
  end
  delete_face_effect(form, actor2)
  if nx_int(card_id) == nx_int(0) then
    return
  end
  actor2.face_effect_id = effect_id
  if nx_is_valid(game_effect) then
    game_effect:CreateEffect(nx_string(effect_id), actor2, actor2, "", "", "", "", actor2, true)
  end
end
function delete_face_effect(form, actor2)
  if not nx_find_custom(actor2, "face_effect_id") then
    return
  end
  if actor2.face_effect_id == "" then
    return
  end
  local game_effect = nx_null()
  if nx_find_custom(form.role_box.Scene, "game_effect") then
    game_effect = form.role_box.Scene.game_effect
  end
  if form.see_other then
    game_effect = nx_null()
    if nx_find_custom(form.role_fwz_box.Scene, "game_effect") then
      game_effect = form.role_fwz_box.Scene.game_effect
    end
  end
  if nx_is_valid(game_effect) then
    game_effect:RemoveEffect(actor2.face_effect_id, actor2, actor2)
  end
  actor2.face_effect_id = ""
end
function player_unlink_fwz(fwz_type)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local model_player = false
  if nx_find_custom(form, "role_model") and nx_is_valid(form.role_model) then
    local role_model = form.role_model
    if nx_find_custom(role_model, "model_type") and (nx_int(role_model.model_type) == nx_int(1) or nx_int(role_model.model_type) == nx_int(3)) then
      model_player = true
    end
  end
  if form.see_other == true then
    model_player = true
  end
  if model_player == false then
    return
  end
  local actor2 = form.role_model
  if form.see_other == true then
    actor2 = form.role_fwz_model
  end
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) and nx_int(actor2.model_type) ~= nx_int(3) then
    return
  end
  if fwz_type == "cloth" then
    if form.see_other == true then
      local addr = ""
      sex = actor2.sex
      if sex == 0 then
        addr = "_boy"
      elseif sex == 1 then
        addr = "_girl"
      end
      local hat_model = equip_model["hat" .. addr]
      local cloth_model = equip_model["cloth" .. addr]
      local pants_model = equip_model["pants" .. addr]
      local shoes_model = equip_model["shoes" .. addr]
      local skin_info = {
        [1] = {link_name = "hat", model_name = hat_model},
        [2] = {link_name = "cloth", model_name = cloth_model},
        [3] = {link_name = "pants", model_name = pants_model},
        [4] = {link_name = "shoes", model_name = shoes_model}
      }
      for i, info in ipairs(skin_info) do
        if info.model_name ~= nil and "" ~= info.model_name then
          player_link_equip(info.link_name, info.model_name, true)
        end
      end
    else
      init_player_jh_model(form, false)
    end
  elseif fwz_type == "cloak" then
    role_composite:UnPlayerSkin(actor2, "cloak")
  elseif fwz_type == "weapon" then
    action:ClearAction(actor2)
    action:ClearState(actor2)
    action:BlendAction(actor2, "new_attire_stand", true, true)
    role_composite:UnLinkWeapon(actor2)
    role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
    form.weapon = client_player:QueryProp("Weapon")
  elseif fwz_type == "waist" then
    role_composite:UnPlayerSkin(actor2, "waist")
  end
  if nx_number(actor2.model_type) == nx_number(3) and nx_string(fwz_type) == nx_string("cloth") then
    unlink_skin(actor2, "Hat")
    unlink_skin(actor2, "Shoes")
    unlink_skin(actor2, "Cloth")
    unlink_skin(actor2, "Pants")
    unlink_skin(actor2, "cloak")
    unlink_skin(actor2, "cloth_h")
    local body_manager = nx_value("body_manager")
    if not nx_is_valid(body_manager) then
      return
    end
    local xmod_init = body_manager:GetInitModel(actor2.body_type)
    link_skin(actor2, "hat", xmod_init[1] .. nx_string(".xmod"))
    link_skin(actor2, "cloth", xmod_init[2] .. nx_string(".xmod"))
  end
  change_action_by_weapon(actor2)
end
function player_fwz_link_sp(card_id)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local is_sub_cloth = false
  if nx_find_custom(form, "role_model") and nx_is_valid(form.role_model) then
    local role_model = form.role_model
    if nx_find_custom(role_model, "model_type") and (nx_int(role_model.model_type) == nx_int(1) or nx_int(role_model.model_type) == nx_int(3)) then
      is_sub_cloth = true
    end
  end
  if is_sub_cloth ~= true then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor2 = form.role_model
  if form.see_other then
    actor2 = form.role_fwz_model
  end
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(actor2, "model_type") then
    return
  end
  if nx_int(actor2.model_type) ~= nx_int(1) and nx_int(actor2.model_type) ~= nx_int(3) then
    return
  end
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  local sex = actor2.sex
  local model = ""
  if sex == 1 then
    model = female_model
  else
    model = male_model
  end
  local model_table = util_split_string(model, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        local prop_name = base_table[1]
        local prop_value = base_table[2]
        if prop_name == "Cloak" then
          form.cloak = prop_value
          player_link_equip("cloak", prop_value)
        elseif prop_name == "Waist" then
          form.cloak = prop_value
          player_link_equip("waist", prop_value)
        end
      end
    end
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  local show_action = GIRL_SHOW_CLOTH_ACTION
  if actor2.sex == 0 then
    show_action = BOY_SHOW_CLOTH_ACTION
  end
  local rand_num = math.random(2)
  Play_role_action(show_action .. nx_string(rand_num), 2)
end
function check_close_form()
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    form:Close()
  end
end
function switch_role_box(form, index)
  if not nx_is_valid(form) then
    return
  end
  form.role_box.Visible = false
  form.role_fwz_box.Visible = false
  if index == 1 then
    form.role_box.Visible = true
  elseif index == 2 then
    form.role_fwz_box.Visible = true
  end
end
function on_btn_model_fwz_click()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return false
  end
  form.see_other = not form.see_other
  local gui = nx_value("gui")
  if form.see_other == true then
    switch_role_box(form, 2)
    refresh_fwz_other()
  else
    switch_role_box(form, 1)
    create_fwz_player()
  end
  return true
end
function create_fwz_other()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_fwz_box)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.role_fwz_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_fwz_box)
    init_effect(form.role_fwz_box.Scene)
  end
  local sex = client_player:QueryProp("Sex")
  local other_sex = math.abs(sex - 1)
  local actor2 = nx_execute("role_composite", "create_role_composite_simple", form.role_fwz_box.Scene, true, other_sex)
  if not nx_is_valid(actor2) then
    return
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  form.role_fwz_model = actor2
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_fwz_box, actor2)
  actor2.attire_weapon = 1
  local scene = form.role_fwz_box.Scene
  local camera = scene.camera
  camera:SetPosition(0, 0.9, -4.2)
  actor2.model_type = 1
  actor2.sex = other_sex
  local actor_role = actor2:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("new_attire_stand", true, true)
  end
  refresh_fwz_other()
end
function refresh_fwz_other()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.role_fwz_model) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor2 = form.role_fwz_model
  nx_execute("role_composite", "unlink_skin", actor2, "hat")
  nx_execute("role_composite", "unlink_skin", actor2, "shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "pants")
  nx_execute("role_composite", "unlink_skin", actor2, "cloak")
  nx_execute("role_composite", "unlink_skin", actor2, "waist")
  delete_face_effect(form, actor2)
  LinkCardDecorate("", 1)
  LinkCardDecorate("", 3)
  role_composite:UnLinkWeapon(actor2)
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  local card_id = collect_card_manager:GetCurEquipId()
  if card_id <= 0 then
    local addr = ""
    local sex = form.role_fwz_model.sex
    if sex == 0 then
      addr = "_boy"
    elseif sex == 1 then
      addr = "_girl"
    end
    local hat_model = equip_model["hat" .. addr]
    local cloth_model = equip_model["cloth" .. addr]
    local pants_model = equip_model["pants" .. addr]
    local shoes_model = equip_model["shoes" .. addr]
    local skin_info = {
      [1] = {link_name = "hat", model_name = hat_model},
      [2] = {link_name = "cloth", model_name = cloth_model},
      [3] = {link_name = "pants", model_name = pants_model},
      [4] = {link_name = "shoes", model_name = shoes_model}
    }
    for i, info in ipairs(skin_info) do
      if info.model_name ~= nil and "" ~= info.model_name then
        player_link_equip(info.link_name, info.model_name, true)
      end
    end
    role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
    change_action_by_weapon(actor2)
    return
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  show_fwz_other_cloth(form, female_model, male_model)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  local show_action = GIRL_SHOW_CLOTH_ACTION
  if actor2.sex == 0 then
    show_action = BOY_SHOW_CLOTH_ACTION
  end
  local rand_num = math.random(2)
  Play_role_action(show_action .. nx_string(rand_num), 2)
  role_composite:PlayerVisPropChange(actor2, client_player, "Weapon")
end
function player_link_fwz_other(form, card_id)
  if not nx_is_valid(form) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local actor2 = form.role_fwz_model
  if not nx_is_valid(actor2) then
    return
  end
  nx_execute("role_composite", "unlink_skin", actor2, "hat")
  nx_execute("role_composite", "unlink_skin", actor2, "shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "pants")
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  show_fwz_other_cloth(form, female_model, male_model)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "new_attire_stand", true, true)
  local show_action = GIRL_SHOW_CLOTH_ACTION
  if actor2.sex == 0 then
    show_action = BOY_SHOW_CLOTH_ACTION
  end
  local rand_num = math.random(2)
  Play_role_action(show_action .. nx_string(rand_num), 2)
  change_action_by_weapon(actor2)
end
function show_fwz_other_cloth(form, female_model, male_model)
  local actor2 = form.role_fwz_model
  if not nx_is_valid(actor2) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local sex = actor2.sex
  local model = ""
  if sex == 1 then
    model = female_model
  else
    model = male_model
  end
  local model_table = util_split_string(model, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  local bHat_model = false
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        local prop_name = base_table[1]
        local prop_value = base_table[2]
        if prop_name == "Hat" then
          if prop_value ~= nil and prop_value ~= "" then
            bHat_model = true
            player_link_equip("hat", prop_value)
          end
        elseif prop_name == "Shoes" then
          player_link_equip("shoes", prop_value)
        elseif prop_name == "Cloth" then
          player_link_equip("cloth", prop_value)
        elseif prop_name == "Pants" then
          player_link_equip("pants", prop_value)
        elseif prop_name == "Cloak" then
          player_link_equip("cloak", prop_value)
        elseif prop_name == "Waist" then
          player_link_equip("waist", prop_value)
        end
      end
    end
  end
  if bHat_model == false then
    local hat = "obj\\char\\b_jianghu000\\b_helmet000"
    if sex == 1 then
      hat = "obj\\char\\g_jianghu000\\g_helmet000"
    end
    player_link_equip("hat", hat)
  end
end
function reset_fwz(show_btn)
  local form_main = nx_value(FORM_PATH)
  if not nx_is_valid(form_main) then
    return
  end
  form_main.see_other = false
  local gui = nx_value("gui")
  switch_role_box(form_main, 1)
end
function change_action_by_weapon(actor2)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local action_set = ""
  if nx_find_custom(form, "is_equip_fwz_weapon") and form.is_equip_fwz_weapon then
    if nx_find_custom(form, "fwz_action_set") then
      action_set = form.fwz_action_set
    end
  else
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    if client_player:FindProp("ActionSet") then
      action_set = nx_string(client_player:QueryProp("ActionSet"))
    end
  end
  if "" == action_set then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local action_name = "grd_" .. action_set .. "_stand"
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, action_name, true, true)
end
