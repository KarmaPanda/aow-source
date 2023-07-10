function main_form_init(self)
  self.Fixed = false
  self.alpha = 0
  self.red = 0
  self.green = 0
  self.blue = 0
  self.notify_script = nil
  self.notify_function = nil
  self.notify_context = nil
  self.disable_bright = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  convert_to_hsb(self)
  local world = nx_value("world")
  local edit_color = world:Create("EditColor")
  edit_color:MakeColorTex("inner_tex:color_hue_sat", 256, 256)
  edit_color:MakeBrightTex("inner_tex:color_bright", 16, 256, self.hue, self.sat)
  self.color_rect.BackImage = "inner_tex:color_hue_sat,0,0,256,256"
  self.bri_track.BackImage = "inner_tex:color_bright,0,0,16,256"
  self.bri_track.TrackButton.Height = 8
  world:Delete(edit_color)
  set_current_color(self)
  if self.disable_bright then
    self.bri_track.Enabled = false
  end
  return 1
end
function notify_color_changed(form)
  if form.notify_script == nil then
    return 0
  end
  nx_execute(form.notify_script, form.notify_function, form.notify_context, form.alpha, form.red, form.green, form.blue)
  return 1
end
function convert_to_rgb(form)
  local red, green, blue = nx_function("ext_hsb_to_rgb", form.hue, form.sat, form.bri)
  form.red = red
  form.green = green
  form.blue = blue
  return 1
end
function convert_to_hsb(form)
  local hue, sat, bri = nx_function("ext_rgb_to_hsb", form.red, form.green, form.blue)
  form.hue = hue
  form.sat = sat
  form.bri = bri
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "set_color_return", "ok", form.alpha, form.red, form.green, form.blue)
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "set_color_return", "cancel")
  nx_destroy(form)
  return 1
end
function set_current_color(form)
  form.hue_edit.Text = nx_widestr(nx_int(form.hue * 360))
  form.sat_edit.Text = nx_widestr(nx_int(form.sat * 100))
  form.bri_edit.Text = nx_widestr(nx_int(form.bri * 100))
  form.color_rect.Enabled = false
  form.color_rect.HorizonValue = form.hue * 360
  form.color_rect.VerticalValue = (1 - form.sat) * 100
  form.color_rect.Enabled = true
  form.bri_track.Enabled = false
  form.bri_track.Value = (1 - form.bri) * 100
  if not form.disable_bright then
    form.bri_track.Enabled = true
  end
  form.alpha_edit.Text = nx_widestr(form.alpha)
  form.red_edit.Text = nx_widestr(form.red)
  form.green_edit.Text = nx_widestr(form.green)
  form.blue_edit.Text = nx_widestr(form.blue)
  form.alpha_track.Enabled = false
  form.alpha_track.Value = form.alpha
  form.alpha_track.Enabled = true
  form.red_track.Enabled = false
  form.red_track.Value = form.red
  form.red_track.Enabled = true
  form.green_track.Enabled = false
  form.green_track.Value = form.green
  form.green_track.Enabled = true
  form.blue_track.Enabled = false
  form.blue_track.Value = form.blue
  form.blue_track.Enabled = true
  update_sample_color(form)
  return 1
end
function set_bright_color(form)
  local world = nx_value("world")
  local edit_color = world:Create("EditColor")
  edit_color:MakeBrightTex("inner_tex:color_bright", 16, 256, form.hue, form.sat)
  world:Delete(edit_color)
  return 1
end
function update_sample_color(form)
  local color = nx_string(form.alpha) .. "," .. nx_string(form.red) .. "," .. nx_string(form.green) .. "," .. nx_string(form.blue)
  form.preview_label.BackColor = color
  return 1
end
function color_horizon_changed(self)
  local form = self.Parent
  form.hue = self.HorizonValue / 360
  convert_to_rgb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function color_vertical_changed(self)
  local form = self.Parent
  form.sat = 1 - self.VerticalValue / 100
  convert_to_rgb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function bri_value_changed(self)
  local form = self.Parent
  form.bri = 1 - self.Value / 100
  convert_to_rgb(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function alpha_value_changed(self)
  local form = self.Parent
  form.alpha = self.Value
  form.alpha_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  notify_color_changed(form)
  return 1
end
function red_value_changed(self)
  local form = self.Parent
  form.red = self.Value
  convert_to_hsb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function green_value_changed(self)
  local form = self.Parent
  form.green = self.Value
  convert_to_hsb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function blue_value_changed(self)
  local form = self.Parent
  form.blue = self.Value
  convert_to_hsb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function hue_edit_lost_focus(self)
  local num = nx_number(self.Text)
  if num < 0 then
    num = 0
  end
  if 360 < num then
    num = 360
  end
  self.Text = nx_widestr(num)
  local form = self.Parent
  form.hue = num / 360
  convert_to_rgb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function sat_edit_lost_focus(self)
  local num = nx_number(self.Text)
  if num < 0 then
    num = 0
  end
  if 100 < num then
    num = 100
  end
  self.Text = nx_widestr(num)
  local form = self.Parent
  form.sat = num / 100
  convert_to_rgb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function bri_edit_lost_focus(self)
  local num = nx_number(self.Text)
  if num < 0 then
    num = 0
  end
  if 100 < num then
    num = 100
  end
  self.Text = nx_widestr(num)
  local form = self.Parent
  form.bri = num / 100
  convert_to_rgb(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function alpha_edit_lost_focus(self)
  local num = nx_number(nx_int(self.Text))
  if num < 0 then
    num = 0
  end
  if 255 < num then
    num = 255
  end
  self.Text = nx_widestr(num)
  local form = self.Parent
  form.alpha = num
  form.alpha_track.Value = num
  update_sample_color(form)
  notify_color_changed(form)
  return 1
end
function red_edit_lost_focus(self)
  local num = nx_number(nx_int(self.Text))
  if num < 0 then
    num = 0
  end
  if 255 < num then
    num = 255
  end
  self.Text = nx_widestr(num)
  local form = self.Parent
  form.red = num
  convert_to_hsb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function green_edit_lost_focus(self)
  local num = nx_number(nx_int(self.Text))
  if num < 0 then
    num = 0
  end
  if 255 < num then
    num = 255
  end
  self.Text = nx_widestr(num)
  local form = self.Parent
  form.green = num
  convert_to_hsb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
function blue_edit_lost_focus(self)
  local num = nx_number(nx_int(self.Text))
  if num < 0 then
    num = 0
  end
  if 255 < num then
    num = 255
  end
  self.Text = nx_widestr(num)
  local form = self.Parent
  form.blue = num
  convert_to_hsb(form)
  set_bright_color(form)
  set_current_color(form)
  notify_color_changed(form)
  return 1
end
