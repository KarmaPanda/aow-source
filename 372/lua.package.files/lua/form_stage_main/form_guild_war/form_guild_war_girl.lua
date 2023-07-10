require("util_functions")
local last_sky_stage = 0
local file_map = "map\\"
local guild_weather_path = "map\\ini\\weather\\guildwar\\"
local weather_stage_table = "guild_war_sky_rec"
local VIEWPORT_GUILDWAR_BOX = 132
local temp_table = {}
function main_form_init(form)
  form.Fixed = false
  form.UpdateFlag = true
  form.HideFlag = false
  form.show = true
  form.sum_girl_count = 0
  form.abductor_girls_count = 0
  form.refresh_time = 0
  return 1
end
function on_main_form_open(form)
  form.btn_show.Visible = false
  set_girl_info(form)
end
function set_girl_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_girl_count.Text = nx_widestr("")
  form.lbl_abductor_girl_count.Text = nx_widestr("")
  local cunrent_girl_count = nx_int(form.sum_girl_count) - nx_int(form.abductor_girls_count)
  form.lbl_girl_count.Text = nx_widestr(cunrent_girl_count) .. nx_widestr("/") .. nx_widestr(form.sum_girl_count)
  form.lbl_abductor_girl_count.Text = nx_widestr(form.abductor_girls_count)
end
function on_main_form_close(form)
  form.UpdateFlag = true
  form.HideFlag = false
  form.Visible = false
  nx_destroy(form)
end
function show_guild_girl_form()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  return 1
end
function change_time_form(form)
  local gui = nx_value("gui")
  form.Height = nx_number(34)
  if form.UpdateFlag then
    form.UpdateFlag = false
  else
    form.UpdateFlag = true
    form.Height = nx_number(70)
  end
end
function do_show_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_girl", true, false, "timelimitform")
  create_timelimit_table()
  if table.getn(TimeLimitTable) == 0 then
    close_time_limit_form()
    return
  end
  if not form.HideFlag then
    change_time_form(form)
  end
  form.Visible = true
  form:Show()
  update_info(form)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  init_timer(form)
  return 1
end
function on_btn_help_click(btn)
  local form = btn.ParentForm
end
function on_btn_hide_click(btn)
  local form = btn.ParentForm
  if form.show then
    form.groupbox_girl.Visible = false
    form.btn_show.Visible = true
    form.show = false
  else
    form.groupbox_girl.Visible = true
    form.btn_show.Visible = false
    form.show = true
  end
  if form.HideFlag then
    form.Height = 34
  else
    form.BlendColor = "255,255,255,255"
    change_time_form(form)
  end
end
function on_main_form_get_capture(form)
  if form.Height ~= 34 then
    return
  end
  if is_mouse_in_control(form.btn_help) or is_mouse_in_control(form.btn_hide) then
    return
  end
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("FormBlendColorOut", form)
  local blend = form.BlendColor
  local temp = util_split_string(blend, ",")
  form.cur_alpha = nx_float(temp[1])
  common_execute:AddExecute("FormBlendColorIn", form, nx_float(0.01), nx_float(255))
end
function on_main_form_lost_capture(form)
  if form.Height ~= 34 then
    return
  end
  if is_mouse_in_control(form.btn_help) or is_mouse_in_control(form.btn_hide) then
    return
  end
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("FormBlendColorIn", form)
  local blend = form.BlendColor
  local temp = util_split_string(blend, ",")
  form.cur_alpha = nx_float(temp[1])
  common_execute:AddExecute("FormBlendColorOut", form, nx_float(0.01))
end
function is_mouse_in_control(self)
  local gui = nx_value("gui")
  local mouse_x, mouse_y = gui:GetCursorPosition()
  if nx_float(mouse_x) > nx_float(self.AbsLeft) and nx_float(mouse_x) < nx_float(self.AbsLeft + self.Width) and nx_float(mouse_y) > nx_float(self.AbsTop) and nx_float(mouse_y) < nx_float(self.AbsTop + self.Height) then
    return true
  else
    return false
  end
end
function on_timer(self, seconds, para)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local domain_id = client_player:QueryProp("GuildWarDomainID")
  if domain_id <= 0 then
    return
  end
  change_weather_by_stage(self)
  return 1
end
function on_entry(form)
  local scene = nx_value("game_scene")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", form)
    timer:Register(2000, -1, nx_current(), "on_timer", form, -1, -1)
  end
  return 1
end
function on_leave(self)
  if 1 == 1 then
    return
  end
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
  end
  local scene = nx_value("game_scene")
  local ter = scene.terrain
  local file_path = nx_string(ter.FilePath .. "weather.ini")
  local path_lst = util_split_string(file_path, "\\")
  local split_path = ""
  for j = 1, table.getn(path_lst) do
    local map = path_lst[j]
    if split_path ~= "" then
      split_path = split_path .. "\\" .. map
    end
    if map == "map" then
      split_path = map
    end
  end
  file_path = split_path
  if nx_running(nx_current(), "set_weather", self) then
    nx_kill(nx_current(), "set_weather", self)
  end
  if not nx_running(nx_current(), "set_weather", self) then
    nx_execute(nx_current(), "set_weather", self, file_path)
  end
  last_sky_stage = 0
  temp_table = {}
  return 1
end
function get_sky_stage(domain_id)
  get_westher_data()
  if temp_table == nil then
    return false
  end
  local rows = table.getn(temp_table)
  for i = 1, rows do
    local id = temp_table[i][1]
    local sky_stage = temp_table[i][2]
    if domain_id == id then
      return sky_stage
    end
  end
  return true
end
function change_weather_by_stage(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local domain_id = client_player:QueryProp("GuildWarDomainID")
  if domain_id <= 0 then
    return 0
  end
  local sky_stage = 0
  get_westher_data()
  if temp_table == nil then
    return 0
  end
  local rows = table.getn(temp_table)
  for i = 1, rows do
    local id = temp_table[i][1]
    sky_stage = temp_table[i][2]
    if domain_id == id then
      break
    end
  end
  if nx_int(sky_stage) <= nx_int(0) then
    return 0
  end
  if last_sky_stage == sky_stage then
    return 0
  end
  last_sky_stage = sky_stage
  local file_path = guild_weather_path .. nx_string(sky_stage) .. ".ini"
  if nx_running(nx_current(), "set_weather", form) then
    nx_kill(nx_current(), "set_weather", form)
  end
  if not nx_running(nx_current(), "set_weather", form) then
    nx_execute(nx_current(), "set_weather", form, file_path)
  end
  return 1
end
function async_set_sky_sun(form, ini, append_path)
  local scene = nx_value("game_scene")
  local sky = scene.sky
  local sun = scene.sun
  local weather = scene.Weather
  local world = nx_value("world")
  world.BackColor = weather.FogColor
  weather.show_sun = ini:ReadString("weather", "ShowSun", nx_string(weather.show_sun))
  if weather.show_sun == true then
    sun.ShowFlare = ini:ReadString("weather", "ShowFlare", nx_string(weather.show_flare))
    sun.GlowTex = append_path .. ini:ReadString("weather", "SunTex", weather.sun_tex)
  else
    sun.ShowGlow = false
    sun.ShowFlare = false
  end
  sky.YawSpeed = ini:ReadFloat("weather", "SkyYawSpeed", sky.YawSpeed)
end
function set_intensity(form, weather, new_ambient, new_sunglow, new_specular, lerp)
  local delta_ambient = weather.AmbientIntensity - new_ambient
  local delta_sunglow = weather.SunGlowIntensity - new_sunglow
  local delta_specular = weather.SpecularIntensity - new_specular
  local ended = false
  while not ended do
    local seconds = nx_strict_pause(0)
    if not nx_is_valid(form) or not nx_is_valid(weather) then
      return false
    end
    lerp = lerp - seconds
    if lerp < 0 then
      lerp = 0
      ended = true
    end
    weather.AmbientIntensity = new_ambient + delta_ambient * lerp
    weather.SunGlowIntensity = new_sunglow + delta_sunglow * lerp
    weather.SpecularIntensity = new_specular + delta_specular * lerp
  end
end
function async_set_weather(form, ini, append_path)
  local scene = nx_value("game_scene")
  local sky = scene.sky
  local weather = scene.Weather
  weather.FogLinear = ini:ReadString("weather", "FogLinear", nx_string(weather.FogLinear))
  weather.FogExp = ini:ReadString("weather", "FogExp", nx_string(weather.FogExp))
  weather.FogStart = ini:ReadFloat("weather", "FogStart", weather.FogStart)
  weather.FogEnd = ini:ReadFloat("weather", "FogEnd", weather.FogEnd)
  weather.FogHeight = ini:ReadFloat("weather", "FogHeight", weather.FogHeight)
  weather.FogHeightExp = ini:ReadFloat("weather", "FogHeightExp", weather.FogHeightExp)
  weather.FogDensity = ini:ReadFloat("weather", "FogDensity", weather.FogDensity)
  weather.fog_red = ini:ReadInteger("weather", "FogRed", weather.fog_red)
  weather.fog_green = ini:ReadInteger("weather", "FogGreen", weather.fog_green)
  weather.fog_blue = ini:ReadInteger("weather", "FogBlue", weather.fog_blue)
  weather.fog_exp_red = ini:ReadInteger("weather", "FogExpRed", weather.fog_exp_red)
  weather.fog_exp_green = ini:ReadInteger("weather", "FogExpGreen", weather.fog_exp_green)
  weather.fog_exp_blue = ini:ReadInteger("weather", "FogExpBlue", weather.fog_exp_blue)
  weather.FogColor = "0," .. nx_string(weather.fog_red) .. "," .. nx_string(weather.fog_green) .. "," .. nx_string(weather.fog_blue)
  weather.FogExpColor = "0," .. nx_string(weather.fog_exp_red) .. "," .. nx_string(weather.fog_exp_green) .. "," .. nx_string(weather.fog_exp_blue)
  weather.sunglow_red = ini:ReadInteger("weather", "SunglowRed", weather.sunglow_red)
  weather.sunglow_green = ini:ReadInteger("weather", "SunglowGreen", weather.sunglow_green)
  weather.sunglow_blue = ini:ReadInteger("weather", "SunglowBlue", weather.sunglow_blue)
  weather.SunGlowColor = "0," .. nx_string(weather.sunglow_red) .. "," .. nx_string(weather.sunglow_green) .. "," .. nx_string(weather.sunglow_blue)
  weather.ambient_red = ini:ReadInteger("weather", "AmbientRed", weather.ambient_red)
  weather.ambient_green = ini:ReadInteger("weather", "AmbientGreen", weather.ambient_green)
  weather.ambient_blue = ini:ReadInteger("weather", "AmbientBlue", weather.ambient_blue)
  weather.AmbientColor = "0," .. nx_string(weather.ambient_red) .. "," .. nx_string(weather.ambient_green) .. "," .. nx_string(weather.ambient_blue)
  weather.specular_red = ini:ReadInteger("weather", "SpecularRed", weather.specular_red)
  weather.specular_green = ini:ReadInteger("weather", "SpecularGreen", weather.specular_green)
  weather.specular_blue = ini:ReadInteger("weather", "SpecularBlue", weather.specular_blue)
  weather.SpecularColor = "0," .. nx_string(weather.specular_red) .. "," .. nx_string(weather.specular_green) .. "," .. nx_string(weather.specular_blue)
  local ambient_intensity = ini:ReadFloat("weather", "AmbientIntensity", weather.AmbientIntensity)
  local sunglow_intensity = ini:ReadFloat("weather", "SunGlowIntensity", weather.SunGlowIntensity)
  local specular_intensity = ini:ReadFloat("weather", "SpecularIntensity", weather.SpecularIntensity)
  nx_execute(nx_current(), "set_intensity", form, weather, ambient_intensity, sunglow_intensity, specular_intensity, 0)
  weather.WindSpeed = ini:ReadFloat("weather", "WindSpeed", weather.WindSpeed)
  weather.WindAngle = ini:ReadFloat("weather", "WindAngle", weather.WindAngle)
  weather.sun_height = ini:ReadInteger("weather", "SunHeight", weather.sun_height)
  weather.sun_azimuth = ini:ReadInteger("weather", "SunAzimuth", weather.sun_azimuth)
  local sun_height_rad = weather.sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = weather.sun_azimuth / 360 * math.pi * 2
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  local game_config = nx_value("game_config")
  nx_execute("game_config", "set_visual_radius", scene, game_config.visual_radius)
end
function set_weather(form, file_path)
  local scene = nx_value("game_scene")
  local sky = scene.sky
  local sun = scene.sun
  if not (nx_is_valid(scene) and nx_is_valid(sky)) or not nx_is_valid(sun) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", file_path)
  if not nx_is_valid(ini) then
    return false
  end
  if not ini:FindSection("weather") then
    return
  end
  nx_execute(nx_current(), "async_set_sky_sun", form, ini, file_map)
  nx_execute(nx_current(), "async_set_weather", form, ini, file_map)
end
function on_view_oper(self, op_type, view_ident, index)
  if not nx_is_valid(self) then
    return false
  end
  local new_time = nx_function("ext_get_tickcount")
  if new_time - self.refresh_time < 1000 then
    return 0
  end
  self.refresh_time = new_time
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return false
  end
  if op_type == "createview" then
    get_westher_data()
  elseif op_type == "deleteview" then
    temp_table = {}
  elseif op_type == "additem" then
    get_westher_data()
  elseif op_type == "delitem" then
    get_westher_data()
  elseif op_type == "updateitem" then
    get_westher_data()
  end
  return true
end
function get_westher_data()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_GUILDWAR_BOX))
  if not nx_is_valid(view) then
    return false
  end
  if not view:FindRecord(weather_stage_table) then
    return false
  end
  temp_table = {}
  local rows = view:GetRecordRows(weather_stage_table)
  for i = 0, rows - 1 do
    local domain_id = view:QueryRecord(weather_stage_table, i, 0)
    local sky_stage = view:QueryRecord(weather_stage_table, i, 1)
    table.insert(temp_table, {domain_id, sky_stage})
  end
  return true
end
