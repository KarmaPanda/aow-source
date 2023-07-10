require("util_functions")
function on_init(form)
  form.Fixed = false
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return
  end
  local file_name = "ini\\Scenario\\weather\\save_camera_weather.ini"
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  if not nx_is_valid(ini) then
    return
  end
  form.weather_ini = ini
  form.angleType = 4
  form.is_show_subtitle = false
  form.is_show_camera = false
  form.selected_weather = 0
end
function on_main_form_open(form)
  if not nx_is_valid(form.weather_ini) then
    return
  end
  local weather_count = form.weather_ini:GetSectionCount()
  local no_weather = "ui_changjingmoren"
  form.combobox_weather.InputEdit.Text = util_text(no_weather)
  form.combobox_weather.DropListBox:AddString(util_text(no_weather))
  for i = 0, weather_count - 1 do
    local weather_name = form.weather_ini:ReadString(i, "name", "")
    form.combobox_weather.DropListBox:AddString(util_text(weather_name))
  end
  form.combobox_weather.OnlySelect = true
  form.combobox_weather.DropListBox.SelectIndex = form.selected_weather
  form.combobox_weather.InputEdit.Text = form.combobox_weather.DropListBox.SelectString
  if form.angleType == 1 then
    form.rbtn_move.Checked = true
  elseif form.angleType == 2 then
    form.rbtn_player.Checked = true
  elseif form.angleType == 5 then
    form.rbtn_free.Checked = true
  else
    form.rbtn_point.Checked = true
  end
  form.cbtn_show_subtitle.Checked = form.is_show_subtitle
  form.cbtn_show_camera.Checked = form.is_show_camera
end
function on_main_form_close(form)
  nx_gen_event(form, "camera_setting_return", "cancel")
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "camera_setting_return", "cancel")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "camera_setting_return", "cancel")
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local save_camera_form = nx_value("form_stage_main\\form_camera\\form_save_camera")
  if nx_is_valid(save_camera_form) then
    save_camera_form.angleType = form.angleType
    save_camera_form.IsShowSubtitle = form.is_show_subtitle
    save_camera_form.IsShowCamera = form.is_show_camera
    save_camera_form.selected_weather = form.selected_weather
  end
  nx_gen_event(form, "camera_setting_return", "ok")
  form:Close()
end
function on_btn_def_click(btn)
  local form = btn.ParentForm
  form.rbtn_point.Checked = true
  form.cbtn_show_subtitle.Checked = false
  form.cbtn_show_camera.Checked = false
  form.selected_weather = 0
  form.combobox_weather.DropListBox.SelectIndex = form.selected_weather
  form.combobox_weather.InputEdit.Text = form.combobox_weather.DropListBox.SelectString
end
function on_cbtn_show_subtitle_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.is_show_subtitle = true
  else
    form.is_show_subtitle = false
  end
end
function on_cbtn_show_camera_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.is_show_camera = true
  else
    form.is_show_camera = false
  end
end
function on_rbtn_point_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.angleType = 4
  end
end
function on_rbtn_move_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.angleType = 1
  end
end
function on_rbtn_player_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.angleType = 2
  end
end
function on_rbtn_free_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.angleType = 5
  end
end
function on_combobox_weather_selected(boxitem)
  local form = boxitem.ParentForm
  form.selected_weather = form.combobox_weather.DropListBox.SelectIndex
end
