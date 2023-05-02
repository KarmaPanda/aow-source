require("form_test\\public")
local AMBIENT_COLOR = "255,201,203,255"
local SUN_GLOW_COLOR = "255,255,198,163"
local AMBIENT_INTENSITY = 1.71
local SUNgLOW_INTENSITY = 0.7
local SUN_HEIGHT_RAD = 160
local SUN_AZIMUTH_RAD = 21
local LIGHT_COLOR = "255,15,63,255"
local LIGHT_INTENSITY = 1
local LIGHT_RANGE = 8
local LIGHT_POS_X = 2
local LIGHT_POS_Y = 2.5
local LIGHT_POS_Z = 0
function log(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = false
  self.scene = nx_value("debug_scene_box_light")
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local scene = self.scene
  local game_config = nx_value("game_config")
  if not nx_is_valid(scene) or not nx_is_valid(game_config) then
    self:Close()
    nx_destroy(self)
    return 0
  end
  self.old_ambient_red = game_config.ambient_red
  self.old_ambient_green = game_config.ambient_green
  self.old_ambient_blue = game_config.ambient_blue
  self.old_sunglow_red = game_config.sunglow_red
  self.old_sunglow_green = game_config.sunglow_green
  self.old_sunglow_blue = game_config.sunglow_blue
  self.old_sun_height = game_config.sun_height
  self.old_sun_azimuth = game_config.sun_azimuth
  self.old_point_light_red = game_config.point_light_red
  self.old_point_light_green = game_config.point_light_green
  self.old_point_light_blue = game_config.point_light_blue
  self.old_point_light_range = game_config.point_light_range
  self.old_point_light_intensity = game_config.point_light_intensity
  self.old_point_light_pos_x = game_config.point_light_pos_x
  self.old_point_light_pos_y = game_config.point_light_pos_y
  self.old_point_light_pos_z = game_config.point_light_pos_z
  update_ambient_color_label(self, game_config.ambient_red, game_config.ambient_green, game_config.ambient_blue)
  update_ambient_intensity_edit(self, game_config.ambient_intensity)
  update_sunglow_color_label(self, game_config.sunglow_red, game_config.sunglow_green, game_config.sunglow_blue)
  update_sunglow_intensity_edit(self, game_config.sunglow_intensity)
  self.sun_height_track.Enabled = false
  self.sun_height_track.Value = game_config.sun_height
  self.sun_height_track.Enabled = true
  self.sun_azimuth_track.Enabled = false
  self.sun_azimuth_track.Value = game_config.sun_azimuth
  self.sun_azimuth_track.Enabled = true
  update_light_color_label(self, game_config.point_light_red, game_config.point_light_green, game_config.point_light_blue)
  self.light_range_edit.Enabled = false
  self.light_range_edit.Text = nx_widestr(game_config.point_light_range)
  self.light_range_edit.Enabled = true
  self.light_range_edit.Enabled = false
  self.light_intensity_edit.Text = nx_widestr(game_config.point_light_intensity)
  self.light_range_edit.Enabled = true
  self.light_range_edit.Enabled = false
  self.point_light_pos_x_edit.Text = nx_widestr(game_config.point_light_pos_x)
  self.light_range_edit.Enabled = true
  self.light_range_edit.Enabled = false
  self.point_light_pos_y_edit.Text = nx_widestr(game_config.point_light_pos_y)
  self.light_range_edit.Enabled = true
  self.light_range_edit.Enabled = false
  self.point_light_pos_z_edit.Text = nx_widestr(game_config.point_light_pos_z)
  self.light_range_edit.Enabled = true
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  save_scene_box_light_config(form)
  form:Close()
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  local scene = form.scene
  local game_config = nx_value("game_config")
  if nx_is_valid(scene) and nx_is_valid(game_config) then
    game_config.ambient_red = form.old_ambient_red
    game_config.ambient_green = form.old_ambient_green
    game_config.ambient_blue = form.old_ambient_blue
    game_config.sunglow_red = form.old_sunglow_red
    game_config.sunglow_green = form.old_sunglow_green
    game_config.sunglow_blue = form.old_sunglow_blue
    game_config.sun_height = form.old_sun_height
    game_config.sun_azimuth = form.old_sun_azimuth
    game_config.point_light_red = form.old_point_light_red
    game_config.point_light_green = form.old_point_light_green
    game_config.point_light_blue = form.old_point_light_blue
    game_config.point_light_range = form.old_point_light_range
    game_config.point_light_intensity = form.old_point_light_intensity
    game_config.point_light_pos_x = form.old_point_light_pos_x
    game_config.point_light_pos_y = form.old_point_light_pos_y
    game_config.point_light_pos_z = form.old_point_light_pos_z
    change_light(form)
  end
  form:Close()
  nx_destroy(form)
  return 1
end
function refresh_terrain(scene)
  return true
end
function update_ambient_color_label(form, red, green, blue)
  form.ambient_color_label.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function update_ambient_intensity_edit(form, value)
  form.ambient_intensity_edit.Text = nx_widestr(value)
end
function ambient_color_btn_click(self)
  local form = self.Parent
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  local default_color = "255," .. nx_string(game_config.ambient_red) .. "," .. nx_string(game_config.ambient_green) .. "," .. nx_string(game_config.ambient_blue)
  local res, alpha, red, green, blue = get_color(default_color, "form_test\\form_scene_box_light", "ambient_color_notify", form)
  return 1
end
function ambient_color_notify(form, alpha, red, green, blue)
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  game_config.ambient_red = red
  game_config.ambient_green = green
  game_config.ambient_blue = blue
  scene.Weather.AmbientColor = "255," .. nx_string(game_config.ambient_red) .. "," .. nx_string(game_config.ambient_green) .. "," .. nx_string(game_config.ambient_blue)
  update_ambient_color_label(form, game_config.ambient_red, game_config.ambient_green, game_config.ambient_blue)
  refresh_terrain(scene)
  return 1
end
function ambient_intensity_edit_changed(self)
  local form = self.Parent
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  local value = nx_number(self.Text)
  game_config.ambient_intensity = value
  scene.Weather.AmbientIntensity = value
  return 1
end
function update_sunglow_color_label(form, red, green, blue)
  form.sunglow_color_label.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function update_sunglow_intensity_edit(form, value)
  form.sunglow_intensity_edit.Text = nx_widestr(value)
end
function sun_glow_color_btn_click(self)
  local form = self.Parent
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  local default_color = "255," .. nx_string(game_config.sunglow_red) .. "," .. nx_string(game_config.sunglow_green) .. "," .. nx_string(game_config.sunglow_blue)
  local res, alpha, red, green, blue = get_color(default_color, "form_test\\form_scene_box_light", "sunglow_color_notify", form)
  return 1
end
function sunglow_color_notify(form, alpha, red, green, blue)
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  game_config.sunglow_red = red
  game_config.sunglow_green = green
  game_config.sunglow_blue = blue
  scene.Weather.SunGlowColor = "255," .. nx_string(game_config.sunglow_red) .. "," .. nx_string(game_config.sunglow_green) .. "," .. nx_string(game_config.sunglow_blue)
  update_sunglow_color_label(form, game_config.sunglow_red, game_config.sunglow_green, game_config.sunglow_blue)
  refresh_terrain(scene)
  return 1
end
function sunglow_intensity_edit_changed(self)
  local form = self.Parent
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  local value = nx_number(self.Text)
  game_config.sunglow_intensity = value
  scene.Weather.SunGlowIntensity = value
  return 1
end
function update_sun_height_label(form, value)
  form.sun_height_label.Text = nx_widestr("\204\171\209\244\184\223\182\200\189\199:" .. nx_string(value))
end
function sun_height_value_changed(self)
  local form = self.Parent
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  local value = self.Value
  game_config.sun_height = value
  update_sun_height_label(form, value)
  local sun_height_rad = game_config.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = game_config.sun_azimuth / 360 * math.pi * 2
  scene.Weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  refresh_terrain(scene)
  return 1
end
function update_sun_azimuth_label(form, value)
  form.sun_azimuth_label.Text = nx_widestr("\204\171\209\244\183\189\206\187\189\199:" .. nx_string(value))
end
function sun_azimuth_value_changed(self)
  local form = self.Parent
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  local value = self.Value
  game_config.sun_azimuth = value
  update_sun_azimuth_label(form, value)
  local sun_height_rad = game_config.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = game_config.sun_azimuth / 360 * math.pi * 2
  scene.Weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  refresh_terrain(scene)
  return 1
end
function update_light_color_label(form, red, green, blue)
  form.light_color_label.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function light_color_btn_click(self)
  local form = self.Parent
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  local default_color = "255," .. nx_string(game_config.point_light_red) .. "," .. nx_string(game_config.point_light_green) .. "," .. nx_string(game_config.point_light_blue)
  local res, alpha, red, green, blue = get_color(default_color, "form_test\\form_scene_box_light", "light_color_notify", form)
  return 1
end
function light_color_notify(form, alpha, red, green, blue)
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  if not nx_find_custom(scene, "light") then
    nx_msgbox("light not valid")
    return 0
  end
  game_config.point_light_red = red
  game_config.point_light_green = green
  game_config.point_light_blue = blue
  scene.light.Color = "255," .. nx_string(game_config.point_light_red) .. "," .. nx_string(game_config.point_light_green) .. "," .. nx_string(game_config.point_light_blue)
  update_light_color_label(form, game_config.point_light_red, game_config.point_light_green, game_config.point_light_blue)
  refresh_terrain(scene)
  return 1
end
function light_range_edit_changed(self)
  local form = self.Parent
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  if not nx_find_custom(scene, "light") then
    nx_msgbox("light not valid")
    return 0
  end
  local value = nx_number(self.Text)
  scene.light.Range = value
  game_config.point_light_range = value
  return 1
end
function light_intensity_edit_changed(self)
  local form = self.Parent
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  if not nx_find_custom(scene, "light") then
    nx_msgbox("light not valid")
    return 0
  end
  local value = nx_number(self.Text)
  scene.light.Intensity = value
  game_config.point_light_intensity = value
  return 1
end
function set_light_pos(form, x, y, z)
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  if not nx_find_custom(scene, "light") then
    nx_msgbox("light not valid")
    return 0
  end
  if nil ~= x then
    scene.light:SetPosition(x, scene.light.PositionY, scene.light.PositionZ)
    game_config.point_light_pos_x = x
  elseif nil ~= y then
    scene.light:SetPosition(scene.light.PositionX, y, scene.light.PositionZ)
    game_config.point_light_pos_y = y
  elseif nil ~= z then
    scene.light:SetPosition(scene.light.PositionX, scene.light.PositionY, z)
    game_config.point_light_pos_z = z
  end
  return 1
end
function point_light_pos_x_edit_changed(self)
  set_light_pos(self.Parent, nx_number(self.Text), nil, nil)
  return 1
end
function point_light_pos_y_edit_changed(self)
  set_light_pos(self.Parent, nil, nx_number(self.Text), nil)
  return 1
end
function point_light_pos_z_edit_changed(self)
  set_light_pos(self.Parent, nil, nil, nx_number(self.Text))
  return 1
end
function change_light(form)
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return 0
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return 0
  end
  if not nx_find_custom(scene, "light") then
    nx_msgbox("light not valid")
    return 0
  end
  local weather = scene.Weather
  weather.AmbientColor = "255," .. nx_string(game_config.ambient_red) .. "," .. nx_string(game_config.ambient_green) .. "," .. nx_string(game_config.ambient_blue)
  weather.AmbientIntensity = game_config.ambient_intensity
  weather.SunGlowColor = "255," .. nx_string(game_config.sunglow_red) .. "," .. nx_string(game_config.sunglow_green) .. "," .. nx_string(game_config.sunglow_blue)
  weather.SunGlowIntensity = game_config.sunglow_intensity
  local sun_height_rad = game_config.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = game_config.sun_azimuth / 360 * math.pi * 2
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  local light = scene.light
  light.Color = "255," .. nx_string(game_config.point_light_red) .. "," .. nx_string(game_config.point_light_green) .. "," .. nx_string(game_config.point_light_blue)
  light.Range = game_config.point_light_range
  light.Intensity = game_config.point_light_intensity
  light:SetPosition(game_config.point_light_pos_x, game_config.point_light_pos_y, game_config.point_light_pos_z)
  refresh_terrain(scene)
  return 1
end
function save_scene_box_light_config(form)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_msgbox("game_config not valid")
    return false
  end
  local scene = form.scene
  if not nx_is_valid(scene) then
    nx_msgbox("scene not valid")
    return false
  end
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\systemset\\light_set.ini"
  ini:WriteInteger("light", "ambient_red", nx_int(game_config.ambient_red))
  ini:WriteInteger("light", "ambient_green", nx_int(game_config.ambient_green))
  ini:WriteInteger("light", "ambient_blue", nx_int(game_config.ambient_blue))
  ini:WriteFloat("light", "ambient_intensity", nx_float(game_config.ambient_intensity))
  ini:WriteInteger("light", "sunglow_red", nx_int(game_config.sunglow_red))
  ini:WriteInteger("light", "sunglow_green", nx_int(game_config.sunglow_green))
  ini:WriteInteger("light", "sunglow_blue", nx_int(game_config.sunglow_blue))
  ini:WriteFloat("light", "sunglow_intensity", nx_float(game_config.sunglow_intensity))
  ini:WriteInteger("light", "sun_height", nx_int(game_config.sun_height))
  ini:WriteInteger("light", "sun_azimuth", nx_int(game_config.sun_azimuth))
  ini:WriteInteger("light", "point_light_red", nx_int(game_config.point_light_red))
  ini:WriteInteger("light", "point_light_green", nx_int(game_config.point_light_green))
  ini:WriteInteger("light", "point_light_blue", nx_int(game_config.point_light_blue))
  ini:WriteFloat("light", "point_light_range", nx_float(game_config.point_light_range))
  ini:WriteFloat("light", "point_light_intensity", nx_float(game_config.point_light_intensity))
  ini:WriteFloat("light", "point_light_pos_x", nx_float(game_config.point_light_pos_x))
  ini:WriteFloat("light", "point_light_pos_y", nx_float(game_config.point_light_pos_y))
  ini:WriteFloat("light", "point_light_pos_z", nx_float(game_config.point_light_pos_z))
  ini:SaveToFile()
  nx_destroy(ini)
  return true
end
