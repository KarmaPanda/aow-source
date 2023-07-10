require("util_functions")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function get_arraylist(global_name, recreate)
  local array_list_manager = nx_value("array_list_manager")
  if array_list_manager == nil or not nx_is_valid(array_list_manager) then
    array_list_manager = nx_create("ArrayList", "array_list_manager")
    nx_set_value("array_list_manager", array_list_manager)
  end
  if nx_find_custom(array_list_manager, global_name) then
    local array_list = nx_custom(array_list_manager, global_name)
    if nx_is_valid(array_list) then
      if recreate == nil or not recreate then
        return array_list
      end
      nx_destroy(array_list)
    end
  end
  local array_list = nx_create("ArrayList")
  array_list.Name = global_name
  nx_set_custom(array_list_manager, global_name, array_list)
  return array_list
end
function get_global_arraylist(global_name, recreate)
  local global_arraylist = nx_value(global_name)
  if global_arraylist == nil or not nx_is_valid(global_arraylist) then
    global_arraylist = nx_create("ArrayList", global_name)
  elseif recreate == nil or not recreate then
    return global_arraylist
  else
    nx_destroy(global_arraylist)
    global_arraylist = nx_create("ArrayList", global_name)
  end
  nx_set_value(global_name, global_arraylist)
  return global_arraylist
end
function util_get_form(formname, iscreate, isclose, instance_id, ansynload)
  if formname == nil or string.len(formname) == 0 then
    return
  end
  local form, formname_instance
  if instance_id and instance_id ~= "" then
    formname_instance = formname .. nx_string(instance_id)
  else
    formname_instance = formname
  end
  if ansynload == nil then
    ansynload = false
  elseif ansynload ~= true then
    ansynload = false
  end
  local form = nx_value(formname_instance)
  if not nx_is_valid(form) and iscreate then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) or not nx_is_valid(gui.Loader) then
      return nx_null()
    end
    if ansynload then
      form = gui.Loader:LoadFormAsync(nx_resource_path(), gui.skin_path .. formname .. ".xml")
    else
      form = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. formname .. ".xml")
    end
    if not nx_is_valid(form) then
      local error_text = nx_widestr(util_text("msg_CreateFormFailed - ")) .. nx_widestr(gui.skin_path) .. nx_widestr(formname) .. nx_widestr(".xml")
      nx_msgbox(nx_string(error_text))
      return 0
    end
    form.Name = formname
    if instance_id then
      form.instance_id = instance_id
    end
    if isclose == nil or isclose then
      form.Visible = false
      form:Close()
    end
    nx_set_value(formname_instance, form)
    local switchmgr = nx_value("SwitchManager")
    if nx_is_valid(switchmgr) then
      switchmgr:CheckFormItemVis(formname_instance)
    end
    if nx_is_valid(form) then
    end
    return form
  end
  if nx_is_valid(form) then
  end
  return form
end
function util_auto_show_hide_form(formname, instance_id)
  local form = util_get_form(formname, true, true, instance_id)
  if not nx_is_valid(form) then
    return nil
  end
  if form.Visible then
    form.Visible = false
    form:Close()
  else
    form.Visible = true
    form:Show()
  end
  return form
end
function util_auto_show_hide_form_lock(formname, instance_id)
  local form = util_get_form(formname, true, true, instance_id)
  if not nx_is_valid(form) then
    return 0
  end
  if form.Visible then
    form.Visible = false
    form:Close()
  else
    form.Visible = true
    form:ShowModal()
  end
end
function util_show_form(formname, visible, instance_id, ansynload)
  local form = util_get_form(formname, false, true, instance_id, ansynload)
  if not visible then
    if not nx_is_valid(form) then
      return nx_null()
    else
      form.Visible = false
      form:Close()
    end
  else
    form = util_get_form(formname, true, true, instance_id, ansynload)
    if nx_is_valid(form) then
      form.Visible = true
      form:Show()
    end
  end
  return form
end
function util_is_lockform_visible(formname, instance_id)
  local formname_instance
  if instance_id then
    formname_instance = formname .. nx_string(instance_id)
  else
    formname_instance = formname
  end
  local form = nx_value(formname_instance)
  if not nx_is_valid(form) then
    return false
  end
  return form.Visible
end
function util_is_form_visible(formname, instance_id)
  local formname_instance
  if instance_id then
    formname_instance = formname .. nx_string(instance_id)
  else
    formname_instance = formname
  end
  local form = nx_value(formname_instance)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(form.Parent) then
    return false
  end
  return form.Visible
end
function util_form_alpha_in(formname, keeptime, instance_id)
  local form = util_get_form(formname, true, true, instance_id)
  form.BlendAlpha = 0
  form.Visible = true
  form:Show()
  local timecount = 0
  while true do
    timecount = timecount + nx_pause(0)
    if not nx_is_valid(form) then
      break
    end
    if keeptime > timecount then
      form.BlendAlpha = 255 * timecount / keeptime
    else
      form.BlendAlpha = 255
      break
    end
  end
end
function util_form_alpha_out(formname, keeptime, instance_id)
  local form = util_get_form(formname, false, false, instance_id)
  if not nx_is_valid(form) then
    return 0
  end
  local old_alpha = form.BlendAlpha
  local timecount = 0
  while true do
    timecount = timecount + nx_pause(0)
    if not nx_is_valid(form) then
      break
    end
    if keeptime > timecount then
      form.BlendAlpha = old_alpha - old_alpha * timecount / keeptime
    else
      form.BlendAlpha = 255
      form.Visible = false
      form:Close()
      break
    end
  end
end
function util_auto_alpha_in_out_form(formname, instance_id)
  local form = util_get_form(formname, true, true, instance_id)
  if not nx_is_valid(form) then
    return 0
  end
  if form.Visible then
    util_form_alpha_out(formname, 0.1)
  else
    form.Visible = true
    util_form_alpha_in(formname, 0.1)
  end
end
function util_form_moveto(formname, target_x, target_y, instance_id)
  local form = util_get_form(formname, false, false, instance_id)
  local old_x = form.AbsLeft
  local old_y = form.AbsTop
  local timecount = 0
  while true do
    timecount = timecount + nx_pause(0)
    if not nx_is_valid(form) then
      break
    end
    if timecount < keeptime then
      form.AbsLeft = (target_x - old_x) * timecount / keeptime + old_x
      form.AbsTop = (target_y - old_y) * timecount / keeptime + old_y
    else
      form.AbsLeft = target_x
      form.AbsTop = target_y
      break
    end
  end
end
function util_addscene_to_scenebox(scenebox)
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    local game_config = nx_value("game_config")
    local world = nx_value("world")
    scene = world:Create("Scene")
    scenebox.Scene = scene
    local weather = scene.Weather
    weather.FogEnable = false
    weather.AmbientColor = "255," .. nx_string(game_config.ambient_red) .. "," .. nx_string(game_config.ambient_green) .. "," .. nx_string(game_config.ambient_blue)
    weather.SunGlowColor = "255," .. nx_string(game_config.sunglow_red) .. "," .. nx_string(game_config.sunglow_green) .. "," .. nx_string(game_config.sunglow_blue)
    weather.SpecularColor = "255,196,196,196"
    weather.AmbientIntensity = game_config.ambient_intensity
    weather.SunGlowIntensity = game_config.sunglow_intensity
    weather.SpecularIntensity = 2
    local sun_height_rad = game_config.sun_height / 360 * math.pi * 2
    local sun_azimuth_rad = game_config.sun_azimuth / 360 * math.pi * 2
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
    light.Color = "255," .. nx_string(game_config.point_light_red) .. "," .. nx_string(game_config.point_light_green) .. "," .. nx_string(game_config.point_light_blue)
    light.Range = game_config.point_light_range
    light.Intensity = game_config.point_light_intensity
    light.Attenu0 = 0
    light.Attenu1 = 1
    light.Attenu2 = 0
    light:SetPosition(game_config.point_light_pos_x, game_config.point_light_pos_y, game_config.point_light_pos_z)
    local particle_man = nx_null()
    if not nx_is_valid(particle_man) then
      particle_man = scene:Create("ParticleManager")
      particle_man.TexturePath = "map\\tex\\particles\\"
      particle_man:Load()
      particle_man.EnableCacheIni = true
      scene:AddObject(particle_man, 100)
      scene.particle_man = particle_man
    end
    local radius = 1.5
    scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
    scene.camera:SetAngle(0, 0, 0)
    scene:Load()
  end
end
function util_add_model_to_scenebox(scenebox, model)
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
  model:SetPosition(0, 0, 0)
  model:SetAngle(0, math.pi, 0)
  local radius = 1.5
  if radius < 1 then
    radius = 1
  end
  if 50 < radius then
    radius = 50
  end
  scene:AddObject(model, 20)
  local radius = 1.5
  if radius < 1 then
    radius = 1
  end
  if 50 < radius then
    radius = 50
  end
  scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
  scene.camera:SetAngle(0, 0, 0)
  scene.model = model
  scene.ClearZBuffer = true
  return true
end
function ui_ClearModel(scenebox)
  local scene = scenebox.Scene
  if nx_is_valid(scene) then
    scene:Delete(scene.camera)
    scene:Delete(scene.light_man)
    scene:Delete(scene.particle_man)
    if nx_find_custom(scene, "model") and nx_is_valid(scene.model) then
      scene:Delete(scene.model)
    end
    scene:Delete(scene)
  end
  return true
end
function ui_RotateModel(form, delta_angle)
  local scene = form.Scene
  if nx_is_valid(scene) and nx_find_custom(scene, "model") and nx_is_valid(scene.model) then
    local model = scene.model
    if nx_is_valid(model) then
      local angle_x = model.AngleX
      local angle_y = model.AngleY
      local angle_z = model.AngleZ
      angle_y = angle_y + delta_angle
      model:SetAngle(angle_x, angle_y, angle_z)
    end
  end
  return true
end
function ui_SetModelAngle(form, angle)
  local scene = form.Scene
  if nx_is_valid(scene) then
    local model = scene.model
    if nx_is_valid(model) then
      local angle_x = model.AngleX
      local angle_y = model.AngleY
      local angle_z = model.AngleZ
      angle_y = angle
      model:SetAngle(angle_x, angle_y, angle_z)
    end
  end
  return true
end
function util_messagebox(title, ok_info, cancel_info)
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_confirm.xml")
  dialog.Name = "form_confirm"
  local label = dialog.info_label
  label.Text = nx_widestr(title)
  label.Font = "Default"
  label.ForeColor = "255,0,0,0"
  if ok_info ~= nil then
    dialog.btn_ok.Text = nx_widestr(ok_info)
  end
  if cancel_info ~= nil then
    dialog.btn_cancel.Text = nx_widestr(cancel_info)
  end
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if nx_is_valid(dialog) then
      nx_destroy(dialog)
    end
    return true
  end
  if nx_is_valid(dialog) then
    nx_destroy(dialog)
  end
  return false
end
function ui_InputBox(text)
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), "skin_editor\\form_input_name.xml")
  dialog.Name = "skin_editor\\form_input_name"
  dialog.info_label.Text = nx_widestr(text)
  dialog:ShowModal()
  local res, input = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "cancel" then
    nx_destroy(dialog)
    return false, ""
  end
  nx_destroy(dialog)
  return true, input
end
function clear_common_form()
  nx_execute("form_common\\form_confirm", "clear")
  local connect_form = nx_value("form_common\\form_connect")
  if nx_is_valid(connect_form) then
    connect_form:Close()
    if nx_is_valid(connect_form) then
      nx_destroy(connect_form)
    end
  end
  local error_form = nx_value("form_common\\form_error")
  if nx_is_valid(error_form) then
    error_form:Close()
    if nx_is_valid(error_form) then
      nx_destroy(error_form)
    end
  end
  local input_name_form = nx_value("form_common\\form_input_name")
  if nx_is_valid(input_name_form) then
    input_name_form:Close()
    if nx_is_valid(input_name_form) then
      nx_destroy(input_name_form)
    end
  end
  local input_silver_form = nx_value("form_common\\form_input_silver")
  if nx_is_valid(input_silver_form) then
    input_silver_form:Close()
    if nx_is_valid(input_silver_form) then
      nx_destroy(input_silver_form)
    end
  end
  local inputbox_form = nx_value("form_common\\form_inputbox")
  if nx_is_valid(inputbox_form) then
    inputbox_form:Close()
    if nx_is_valid(inputbox_form) then
      nx_destroy(inputbox_form)
    end
  end
  local number_input_form = nx_value("form_common\\form_number_input")
  if nx_is_valid(number_input_form) then
    number_input_form:Close()
    if nx_is_valid(number_input_form) then
      nx_destroy(number_input_form)
    end
  end
  local tips_form = nx_value("form_common\\form_tips")
  if nx_is_valid(tips_form) then
    tips_form:Close()
    if nx_is_valid(tips_form) then
      nx_destroy(tips_form)
    end
  end
  local die_form = nx_value("form_stage_main\\form_die")
  if nx_is_valid(die_form) then
    die_form:Close()
    if nx_is_valid(die_form) then
      nx_destroy(die_form)
    end
  end
end
function ui_show_attached_form(form, flag)
  if not nx_is_valid(form) then
    return
  end
  local attach_manager = nx_value("AttachManager")
  if not nx_is_valid(attach_manager) then
    return
  end
  local form_attach = attach_manager:GetAttachedForm(form)
  if not nx_is_valid(form_attach) then
    return
  end
  ui_bring_attach_form_to_front(form)
  if flag ~= nil then
    form.attached_form.Visible = flag
  else
    local flag = true
    local ini = get_attach_ini()
    if nx_is_valid(ini) then
      flag = 1 ~= ini:ReadInteger("AutoAttach", form.Name, 0)
    end
    form.attached_form.Visible = flag
  end
  return form_attach
end
function ui_bring_attach_form_to_front(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not form.Visible then
    return
  end
  local attached_form = form.attached_form
  if not nx_is_valid(attached_form) then
    return
  end
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  gui.Desktop:ToFront(attached_form)
end
function get_attach_ini()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return nx_null()
  end
  if not nx_find_property(game_config, "login_account") then
    return nx_null()
  end
  local account = game_config.login_account
  local ini = nx_value("attach_ini")
  if not nx_is_valid(ini) then
    ini = nx_create("IniDocument")
    ini.FileName = account .. "\\" .. "attach.ini"
    ini:LoadFromFile()
    nx_set_value("attach_ini", ini)
  end
  return ini
end
function clear_attach_ini()
  local ini = nx_value("attach_ini")
  if nx_is_valid(ini) then
    ini:DeleteSection("AutoAttach")
    ini:DeleteSection("AutoShowNum")
    ini:SaveToFile()
  end
end
function ui_destroy_attached_form(form)
  if not nx_is_valid(form) then
    return
  end
  local attach_manager = nx_value("AttachManager")
  if not nx_is_valid(attach_manager) then
    return
  end
  attach_manager:DestroyAttachedForm(form)
end
function util_msgbox(msg_text)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  local Text = nx_widestr(gui.TextManager:GetText(nx_string(msg_text)))
  if Test == "" then
    Test = nx_widestr(msg_text)
  end
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(Text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
end
function util_scrolltext(msg_text)
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 1, nx_string(msg_text))
end
function ShowTipDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function show_hide_filter_form(tbForms, bShow)
  for i, path in pairs(tbForms) do
    local form = nx_value(path)
    if nx_is_valid(form) then
      form.Visible = bShow
    end
  end
end
function close_filter_form(tbForms, bOpen)
  for i, path in pairs(tbForms) do
    if bOpen then
      util_show_form(path, true)
    else
      local form = nx_value(path)
      if nx_is_valid(form) then
        form:Close()
      end
    end
  end
end
