local ocean_file_name = "ocean.ini"
function form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  update_ui(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function SpecularNotify(form, alpha, red, green, blue)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.SpecularColorR = red / 255
  OceanNormal.SpecularColorG = green / 255
  OceanNormal.SpecularColorB = blue / 255
  return 1
end
function on_btn_Specular_click(self)
  local parent = self.ParentForm
  if not nx_is_valid(parent) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  local ColorR = OceanNormal.SpecularColorR * 255
  local ColorG = OceanNormal.SpecularColorG * 255
  local ColorB = OceanNormal.SpecularColorB * 255
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = ColorR
  dialog.green = ColorG
  dialog.blue = ColorB
  dialog.notify_script = nx_current()
  dialog.notify_function = "SpecularNotify"
  dialog.notify_context = parent
  dialog:ShowModal()
  local OldR = ColorR
  local OldG = ColorG
  local OldB = ColorB
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    red = OldR
    green = OldG
    blue = OldB
  end
  OceanNormal.SpecularColorR = red / 255
  OceanNormal.SpecularColorG = green / 255
  OceanNormal.SpecularColorB = blue / 255
  parent.btn_Specular.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function ColorNotify(form, alpha, red, green, blue)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.ColorR = red / 255
  OceanNormal.ColorG = green / 255
  OceanNormal.ColorB = blue / 255
  return 1
end
function on_btn_Color_click(self)
  local parent = self.ParentForm
  if not nx_is_valid(parent) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  local ColorR = OceanNormal.ColorR * 255
  local ColorG = OceanNormal.ColorG * 255
  local ColorB = OceanNormal.ColorB * 255
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = ColorR
  dialog.green = ColorG
  dialog.blue = ColorB
  dialog.notify_script = nx_current()
  dialog.notify_function = "ColorNotify"
  dialog.notify_context = parent
  dialog:ShowModal()
  local OldR = ColorR
  local OldG = ColorG
  local OldB = ColorB
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    red = OldR
    green = OldG
    blue = OldB
  end
  OceanNormal.ColorR = red / 255
  OceanNormal.ColorG = green / 255
  OceanNormal.ColorB = blue / 255
  parent.btn_Color.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function FogNotify(form, alpha, red, green, blue)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.FogColorR = red / 255
  OceanNormal.FogColorG = green / 255
  OceanNormal.FogColorB = blue / 255
  return 1
end
function on_btn_Fog_click(self)
  local parent = self.ParentForm
  if not nx_is_valid(parent) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  local ColorR = OceanNormal.FogColorR * 255
  local ColorG = OceanNormal.FogColorG * 255
  local ColorB = OceanNormal.FogColorB * 255
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = ColorR
  dialog.green = ColorG
  dialog.blue = ColorB
  dialog.notify_script = nx_current()
  dialog.notify_function = "FogNotify"
  dialog.notify_context = parent
  dialog:ShowModal()
  local OldR = ColorR
  local OldG = ColorG
  local OldB = ColorB
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    red = OldR
    green = OldG
    blue = OldB
  end
  OceanNormal.FogColorR = red / 255
  OceanNormal.FogColorG = green / 255
  OceanNormal.FogColorB = blue / 255
  parent.btn_Fog.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function CausticColorNotify(form, alpha, red, green, blue)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.CausticColorR = red / 255
  OceanNormal.CausticColorG = green / 255
  OceanNormal.CausticColorB = blue / 255
  return 1
end
function on_btn_CausticColor_click(self)
  local parent = self.ParentForm
  if not nx_is_valid(parent) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  local ColorR = OceanNormal.CausticColorR * 255
  local ColorG = OceanNormal.CausticColorG * 255
  local ColorB = OceanNormal.CausticColorB * 255
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = ColorR
  dialog.green = ColorG
  dialog.blue = ColorB
  dialog.notify_script = nx_current()
  dialog.notify_function = "CausticColorNotify"
  dialog.notify_context = parent
  dialog:ShowModal()
  local OldR = ColorR
  local OldG = ColorG
  local OldB = ColorB
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    red = OldR
    green = OldG
    blue = OldB
  end
  OceanNormal.CausticColorR = red / 255
  OceanNormal.CausticColorG = green / 255
  OceanNormal.CausticColorB = blue / 255
  parent.btn_CausticColor.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function ScatterColorNotify(form, alpha, red, green, blue)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.ScatterColorR = red / 255
  OceanNormal.ScatterColorG = green / 255
  OceanNormal.ScatterColorB = blue / 255
  return 1
end
function on_btn_ScatterColor_click(self)
  local parent = self.ParentForm
  if not nx_is_valid(parent) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  local ColorR = OceanNormal.ScatterColorR * 255
  local ColorG = OceanNormal.ScatterColorG * 255
  local ColorB = OceanNormal.ScatterColorB * 255
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = ColorR
  dialog.green = ColorG
  dialog.blue = ColorB
  dialog.notify_script = nx_current()
  dialog.notify_function = "ScatterColorNotify"
  dialog.notify_context = parent
  dialog:ShowModal()
  local OldR = ColorR
  local OldG = ColorG
  local OldB = ColorB
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    red = OldR
    green = OldG
    blue = OldB
  end
  OceanNormal.ScatterColorR = red / 255
  OceanNormal.ScatterColorG = green / 255
  OceanNormal.ScatterColorB = blue / 255
  parent.btn_ScatterColor.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function DeepOceanColorNotify(form, alpha, red, green, blue)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.DeepOceanColorR = red / 255
  OceanNormal.DeepOceanColorG = green / 255
  OceanNormal.DeepOceanColorB = blue / 255
  return 1
end
function on_btn_DeepOceanColor_click(self)
  local parent = self.ParentForm
  if not nx_is_valid(parent) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  local ColorR = OceanNormal.DeepOceanColorR * 255
  local ColorG = OceanNormal.DeepOceanColorG * 255
  local ColorB = OceanNormal.DeepOceanColorB * 255
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = ColorR
  dialog.green = ColorG
  dialog.blue = ColorB
  dialog.notify_script = nx_current()
  dialog.notify_function = "DeepOceanColorNotify"
  dialog.notify_context = parent
  dialog:ShowModal()
  local OldR = ColorR
  local OldG = ColorG
  local OldB = ColorB
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    red = OldR
    green = OldG
    blue = OldB
  end
  OceanNormal.DeepOceanColorR = red / 255
  OceanNormal.DeepOceanColorG = green / 255
  OceanNormal.DeepOceanColorB = blue / 255
  parent.btn_DeepOceanColor.BackColor = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function on_tbar_ScatterPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.ScatterPow = 0 + 2 * self.Value / 100
end
function on_tbar_TexScale_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.TexScale = 0.2 + 15 * self.Value / 100
end
function on_tbar_AlphaPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.AlphaPow = 0.2 + 4 * self.Value / 100
end
function on_tbar_Speed_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.Speed = 0.2 + 4 * self.Value / 100
end
function on_tbar_DirAngle_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.DirAngle = 0 + 6.28 * self.Value / 100
end
function on_tbar_ReflectPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.ReflectPow = 0 + 1 * self.Value / 100
end
function on_tbar_FogPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.FogPow = 0.2 + 3 * self.Value / 100
end
function on_tbar_HeightPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.HeightPow = 0 + 3 * self.Value / 100
end
function on_tbar_SharpPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.SharpPow = 0 + 3 * self.Value / 100
end
function on_tbar_CausticBrightness_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.CausticBrightness = 0.1 + 10 * self.Value / 100
end
function on_tbar_CausticScale_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.CausticScale = 0.1 + 3 * self.Value / 100
end
function on_tbar_CausticSpeed_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.CausticSpeed = 0.1 + 2 * self.Value / 100
end
function on_tbar_WhiteSpeed_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.WhiteSpeed = 0.1 + 2 * self.Value / 100
end
function on_tbar_NormalPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.NormalPow = 0 + 1 * self.Value / 100
end
function on_tbar_Ambin_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.Ambin = 0 + 1 * self.Value / 100
end
function on_tbar_Diffuse_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.Diffuse = 0 + 1 * self.Value / 100
end
function on_tbar_ReflectBright_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.ReflectBright = 0 + 2 * self.Value / 100
end
function on_tbar_RefractBright_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.RefractBright = 0 + 2 * self.Value / 100
end
function on_tbar_SpecularPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.SpecularPow = 0.01 + 1 * self.Value / 100
end
function on_tbar_WhitePow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.WhitePow = 0 + 2 * self.Value / 100
end
function on_tbar_WhiteScale_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.WhiteScale = 0.1 + 2 * self.Value / 100
end
function on_tbar_SpecularBright_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.SpecularBright = 0 + 1 * self.Value / 100
end
function on_tbar_RainSpeed_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.RainSpeed = 0.1 + 3 * self.Value / 100
end
function on_tbar_RainPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.RainPow = 0.1 + 3 * self.Value / 100
end
function on_tbar_RainScale_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.RainScale = 0.2 + 5 * self.Value / 100
end
function on_tbar_RefractPow_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.RefractPow = 0.1 + 3 * self.Value / 100
end
function on_btn_Delete_click(self)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local OceanNormal = nx_value("OceanNormal")
  if nx_is_valid(OceanNormal) then
    scene:Delete(OceanNormal)
    nx_set_value("OceanNormal", nx_null())
  end
end
function on_ipt_BaseHeight_lost_focus(self)
  local form = self.ParentForm
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  OceanNormal.BaseHeight = nx_number(self.Text)
end
function update_ui(form)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    form.btn_Specular.BackColor = "255," .. nx_string(127.5) .. "," .. nx_string(127.5) .. "," .. nx_string(127.5)
    form.btn_Color.BackColor = "255," .. nx_string(127.5) .. "," .. nx_string(127.5) .. "," .. nx_string(127.5)
    form.btn_Fog.BackColor = "255," .. nx_string(127.5) .. "," .. nx_string(127.5) .. "," .. nx_string(127.5)
    form.btn_CausticColor.BackColor = "255," .. nx_string(127.5) .. "," .. nx_string(127.5) .. "," .. nx_string(127.5)
    form.btn_ScatterColor.BackColor = "255," .. nx_string(127.5) .. "," .. nx_string(127.5) .. "," .. nx_string(127.5)
    form.btn_DeepOceanColor.BackColor = "255," .. nx_string(127.5) .. "," .. nx_string(127.5) .. "," .. nx_string(127.5)
    form.tbar_TexScale.Value = 0
    form.tbar_AlphaPow.Value = 0
    form.tbar_Speed.Value = 0
    form.tbar_DirAngle.Value = 0
    form.tbar_ReflectPow.Value = 0
    form.tbar_FogPow.Value = 0
    form.tbar_HeightPow.Value = 0
    form.tbar_SharpPow.Value = 0
    form.tbar_CausticBrightness.Value = 0
    form.tbar_CausticScale.Value = 0
    form.tbar_CausticSpeed.Value = 0
    form.tbar_WhiteSpeed.Value = 0
    form.tbar_NormalPow.Value = 0
    form.tbar_Ambin.Value = 0
    form.tbar_Diffuse.Value = 0
    form.tbar_ReflectBright.Value = 0
    form.tbar_RefractBright.Value = 0
    form.tbar_SpecularPow.Value = 0
    form.tbar_WhitePow.Value = 0
    form.tbar_WhiteScale.Value = 0
    form.tbar_SpecularBright.Value = 0
    form.tbar_RainSpeed.Value = 0
    form.tbar_RainPow.Value = 0
    form.tbar_RainScale.Value = 0
    form.tbar_RefractPow.Value = 0
    form.tbar_ScatterPow.Value = 0
    form.ipt_BaseHeight.Text = nx_widestr(0)
    return
  end
  form.btn_Specular.BackColor = "255," .. nx_string(OceanNormal.SpecularColorR * 255) .. "," .. nx_string(OceanNormal.SpecularColorG * 255) .. "," .. nx_string(OceanNormal.SpecularColorB * 255)
  form.btn_Color.BackColor = "255," .. nx_string(OceanNormal.ColorR * 255) .. "," .. nx_string(OceanNormal.ColorG * 255) .. "," .. nx_string(OceanNormal.ColorB * 255)
  form.btn_Fog.BackColor = "255," .. nx_string(OceanNormal.FogColorR * 255) .. "," .. nx_string(OceanNormal.FogColorG * 255) .. "," .. nx_string(OceanNormal.FogColorB * 255)
  form.btn_CausticColor.BackColor = "255," .. nx_string(OceanNormal.CausticColorR * 255) .. "," .. nx_string(OceanNormal.CausticColorG * 255) .. "," .. nx_string(OceanNormal.CausticColorB * 255)
  form.btn_ScatterColor.BackColor = "255," .. nx_string(OceanNormal.ScatterColorR * 255) .. "," .. nx_string(OceanNormal.ScatterColorG * 255) .. "," .. nx_string(OceanNormal.ScatterColorB * 255)
  form.btn_DeepOceanColor.BackColor = "255," .. nx_string(OceanNormal.DeepOceanColorR * 255) .. "," .. nx_string(OceanNormal.DeepOceanColorG * 255) .. "," .. nx_string(OceanNormal.DeepOceanColorB * 255)
  form.tbar_TexScale.Value = (OceanNormal.TexScale - 0.2) / 15 * 100
  form.tbar_AlphaPow.Value = (OceanNormal.AlphaPow - 0.2) / 4 * 100
  form.tbar_Speed.Value = (OceanNormal.Speed - 0.2) / 4 * 100
  form.tbar_DirAngle.Value = (OceanNormal.DirAngle - 0) / 6.28 * 100
  form.tbar_ReflectPow.Value = (OceanNormal.ReflectPow - 0) / 1 * 100
  form.tbar_FogPow.Value = (OceanNormal.FogPow - 0.2) / 3 * 100
  form.tbar_HeightPow.Value = (OceanNormal.HeightPow - 0) / 3 * 100
  form.tbar_SharpPow.Value = (OceanNormal.SharpPow - 0) / 3 * 100
  form.tbar_CausticBrightness.Value = (OceanNormal.CausticBrightness - 0.1) / 10 * 100
  form.tbar_CausticScale.Value = (OceanNormal.CausticScale - 0.1) / 3 * 100
  form.tbar_CausticSpeed.Value = (OceanNormal.CausticSpeed - 0.1) / 2 * 100
  form.tbar_WhiteSpeed.Value = (OceanNormal.WhiteSpeed - 0.1) / 2 * 100
  form.tbar_NormalPow.Value = (OceanNormal.NormalPow - 0) / 1 * 100
  form.tbar_Ambin.Value = (OceanNormal.Ambin - 0) / 1 * 100
  form.tbar_Diffuse.Value = (OceanNormal.Diffuse - 0) / 1 * 100
  form.tbar_ReflectBright.Value = (OceanNormal.ReflectBright - 0) / 2 * 100
  form.tbar_RefractBright.Value = (OceanNormal.RefractBright - 0) / 2 * 100
  form.tbar_SpecularPow.Value = (OceanNormal.SpecularPow - 0.01) / 1 * 100
  form.tbar_WhitePow.Value = (OceanNormal.WhitePow - 0) / 2 * 100
  form.tbar_WhiteScale.Value = (OceanNormal.WhiteScale - 0.1) / 2 * 100
  form.tbar_SpecularBright.Value = (OceanNormal.SpecularBright - 0) / 1 * 100
  form.tbar_RainSpeed.Value = (OceanNormal.RainSpeed - 0.1) / 3 * 100
  form.tbar_RainPow.Value = (OceanNormal.RainPow - 0.1) / 3 * 100
  form.tbar_RainScale.Value = (OceanNormal.RainScale - 0.2) / 5 * 100
  form.tbar_RefractPow.Value = (OceanNormal.RefractPow - 0.1) / 3 * 100
  form.tbar_ScatterPow.Value = (OceanNormal.ScatterPow - 0) / 2 * 100
  form.ipt_BaseHeight.Text = nx_widestr(OceanNormal.BaseHeight)
end
function on_btn_save_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local fog_name = nx_string(form.ipt_save.Text)
  save_ocean_param_to_ini(fog_name)
  update_ui(form)
end
function save_ocean_param_to_ini(fog_name)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = terrain.FilePath .. ocean_file_name
  ini:LoadFromFile()
  ini:AddSection(fog_name)
  ini:WriteFloat(fog_name, "ColorR", OceanNormal.ColorR)
  ini:WriteFloat(fog_name, "ColorG", OceanNormal.ColorG)
  ini:WriteFloat(fog_name, "ColorB", OceanNormal.ColorB)
  ini:WriteFloat(fog_name, "SpecularColorR", OceanNormal.SpecularColorR)
  ini:WriteFloat(fog_name, "SpecularColorG", OceanNormal.SpecularColorG)
  ini:WriteFloat(fog_name, "SpecularColorB", OceanNormal.SpecularColorB)
  ini:WriteFloat(fog_name, "FogColorR", OceanNormal.FogColorR)
  ini:WriteFloat(fog_name, "FogColorG", OceanNormal.FogColorG)
  ini:WriteFloat(fog_name, "FogColorB", OceanNormal.FogColorB)
  ini:WriteFloat(fog_name, "CausticColorR", OceanNormal.CausticColorR)
  ini:WriteFloat(fog_name, "CausticColorG", OceanNormal.CausticColorG)
  ini:WriteFloat(fog_name, "CausticColorB", OceanNormal.CausticColorB)
  ini:WriteFloat(fog_name, "ScatterColorR", OceanNormal.ScatterColorR)
  ini:WriteFloat(fog_name, "ScatterColorG", OceanNormal.ScatterColorG)
  ini:WriteFloat(fog_name, "ScatterColorB", OceanNormal.ScatterColorB)
  ini:WriteFloat(fog_name, "DeepOceanColorR", OceanNormal.DeepOceanColorR)
  ini:WriteFloat(fog_name, "DeepOceanColorG", OceanNormal.DeepOceanColorG)
  ini:WriteFloat(fog_name, "DeepOceanColorB", OceanNormal.DeepOceanColorB)
  ini:WriteFloat(fog_name, "TexScale", OceanNormal.TexScale)
  ini:WriteFloat(fog_name, "AlphaPow", OceanNormal.AlphaPow)
  ini:WriteFloat(fog_name, "Speed", OceanNormal.Speed)
  ini:WriteFloat(fog_name, "DirAngle", OceanNormal.DirAngle)
  ini:WriteFloat(fog_name, "ReflectPow", OceanNormal.ReflectPow)
  ini:WriteFloat(fog_name, "FogPow", OceanNormal.FogPow)
  ini:WriteFloat(fog_name, "HeightPow", OceanNormal.HeightPow)
  ini:WriteFloat(fog_name, "SharpPow", OceanNormal.SharpPow)
  ini:WriteFloat(fog_name, "BaseHeight", OceanNormal.BaseHeight)
  ini:WriteFloat(fog_name, "CausticBrightness", OceanNormal.CausticBrightness)
  ini:WriteFloat(fog_name, "CausticScale", OceanNormal.CausticScale)
  ini:WriteFloat(fog_name, "CausticSpeed", OceanNormal.CausticSpeed)
  ini:WriteFloat(fog_name, "WhiteSpeed", OceanNormal.WhiteSpeed)
  ini:WriteFloat(fog_name, "NormalPow", OceanNormal.NormalPow)
  ini:WriteFloat(fog_name, "Ambin", OceanNormal.Ambin)
  ini:WriteFloat(fog_name, "Diffuse", OceanNormal.Diffuse)
  ini:WriteFloat(fog_name, "ReflectBright", OceanNormal.ReflectBright)
  ini:WriteFloat(fog_name, "RefractBright", OceanNormal.RefractBright)
  ini:WriteFloat(fog_name, "SpecularPow", OceanNormal.SpecularPow)
  ini:WriteFloat(fog_name, "WhitePow", OceanNormal.WhitePow)
  ini:WriteFloat(fog_name, "WhiteScale", OceanNormal.WhiteScale)
  ini:WriteFloat(fog_name, "SpecularBright", OceanNormal.SpecularBright)
  ini:WriteFloat(fog_name, "RainSpeed", OceanNormal.RainSpeed)
  ini:WriteFloat(fog_name, "RainPow", OceanNormal.RainPow)
  ini:WriteFloat(fog_name, "RainScale", OceanNormal.RainScale)
  ini:WriteFloat(fog_name, "RefractPow", OceanNormal.RefractPow)
  ini:WriteFloat(fog_name, "ScatterPow", OceanNormal.ScatterPow)
  ini:SaveToFile()
  nx_destroy(ini)
end
function on_btn_read_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local fog_name = nx_string(form.ipt_read.Text)
  local OceanNormal = nx_value("OceanNormal")
  if nx_is_valid(OceanNormal) then
  else
    OceanNormal = scene:Create("OceanNormal")
    OceanNormal:Load()
    OceanNormal.Visible = true
    terrain:SetOceanNormal(OceanNormal)
    nx_set_value("OceanNormal", OceanNormal)
  end
  read_ocean_param_from_ini(fog_name)
  update_ui(form)
end
function read_ocean_param_from_ini(fog_name)
  local OceanNormal = nx_value("OceanNormal")
  if not nx_is_valid(OceanNormal) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = terrain.FilePath .. ocean_file_name
  local res_load = ini:LoadFromFile()
  if false == res_load then
    nx_destroy(ini)
    return
  end
  OceanNormal.ColorR = ini:ReadFloat(fog_name, "ColorR", 0.1)
  OceanNormal.ColorG = ini:ReadFloat(fog_name, "ColorG", 0.4)
  OceanNormal.ColorB = ini:ReadFloat(fog_name, "ColorB", 0.7)
  OceanNormal.SpecularColorR = ini:ReadFloat(fog_name, "SpecularColorR", 0.7)
  OceanNormal.SpecularColorG = ini:ReadFloat(fog_name, "SpecularColorG", 0.7)
  OceanNormal.SpecularColorB = ini:ReadFloat(fog_name, "SpecularColorB", 0.1)
  OceanNormal.FogColorR = ini:ReadFloat(fog_name, "FogColorR", 0.1529)
  OceanNormal.FogColorG = ini:ReadFloat(fog_name, "FogColorG", 0.686)
  OceanNormal.FogColorB = ini:ReadFloat(fog_name, "FogColorB", 0.7686)
  OceanNormal.CausticColorR = ini:ReadFloat(fog_name, "CausticColorR", 1)
  OceanNormal.CausticColorG = ini:ReadFloat(fog_name, "CausticColorG", 1)
  OceanNormal.CausticColorB = ini:ReadFloat(fog_name, "CausticColorB", 1)
  OceanNormal.ScatterColorR = ini:ReadFloat(fog_name, "ScatterColorR", 0)
  OceanNormal.ScatterColorG = ini:ReadFloat(fog_name, "ScatterColorG", 0)
  OceanNormal.ScatterColorB = ini:ReadFloat(fog_name, "ScatterColorB", 0)
  OceanNormal.DeepOceanColorR = ini:ReadFloat(fog_name, "DeepOceanColorR", 0)
  OceanNormal.DeepOceanColorG = ini:ReadFloat(fog_name, "DeepOceanColorG", 0.1)
  OceanNormal.DeepOceanColorB = ini:ReadFloat(fog_name, "DeepOceanColorB", 0.3)
  OceanNormal.ScatterPow = ini:ReadFloat(fog_name, "ScatterPow", 0)
  OceanNormal.TexScale = ini:ReadFloat(fog_name, "TexScale", 1)
  OceanNormal.AlphaPow = ini:ReadFloat(fog_name, "AlphaPow", 1)
  OceanNormal.Speed = ini:ReadFloat(fog_name, "Speed", 1)
  OceanNormal.DirAngle = ini:ReadFloat(fog_name, "DirAngle", 0)
  OceanNormal.ReflectPow = ini:ReadFloat(fog_name, "ReflectPow", 0.5)
  OceanNormal.FogPow = ini:ReadFloat(fog_name, "FogPow", 1)
  OceanNormal.HeightPow = ini:ReadFloat(fog_name, "HeightPow", 1)
  OceanNormal.SharpPow = ini:ReadFloat(fog_name, "SharpPow", 1)
  OceanNormal.BaseHeight = ini:ReadFloat(fog_name, "BaseHeight", 130)
  OceanNormal.CausticBrightness = ini:ReadFloat(fog_name, "CausticBrightness", 5)
  OceanNormal.CausticScale = ini:ReadFloat(fog_name, "CausticScale", 1)
  OceanNormal.CausticSpeed = ini:ReadFloat(fog_name, "CausticSpeed", 0.5)
  OceanNormal.WhiteSpeed = ini:ReadFloat(fog_name, "WhiteSpeed", 0.5)
  OceanNormal.NormalPow = ini:ReadFloat(fog_name, "NormalPow", 1)
  OceanNormal.Ambin = ini:ReadFloat(fog_name, "Ambin", 0.2)
  OceanNormal.Diffuse = ini:ReadFloat(fog_name, "Diffuse", 0.1)
  OceanNormal.ReflectBright = ini:ReadFloat(fog_name, "ReflectBright", 1)
  OceanNormal.RefractBright = ini:ReadFloat(fog_name, "RefractBright", 1)
  OceanNormal.SpecularPow = ini:ReadFloat(fog_name, "SpecularPow", 1)
  OceanNormal.WhitePow = ini:ReadFloat(fog_name, "WhitePow", 0.8)
  OceanNormal.WhiteScale = ini:ReadFloat(fog_name, "WhiteScale", 1)
  OceanNormal.SpecularBright = ini:ReadFloat(fog_name, "SpecularBright", 1)
  OceanNormal.RainSpeed = ini:ReadFloat(fog_name, "RainSpeed", 1)
  OceanNormal.RainPow = ini:ReadFloat(fog_name, "RainPow", 0)
  OceanNormal.RainScale = ini:ReadFloat(fog_name, "RainScale", 1)
  OceanNormal.RefractPow = ini:ReadFloat(fog_name, "RefractPow", 1)
  nx_destroy(ini)
end
function terrain_read_ocean()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = terrain.FilePath .. ocean_file_name
  local res_load = ini:LoadFromFile()
  if false == res_load then
    nx_destroy(ini)
    return
  end
  local ocean_name = "Ocean"
  local OceanNormal = nx_value("OceanNormal")
  if nx_is_valid(OceanNormal) then
  else
    OceanNormal = scene:Create("OceanNormal")
    OceanNormal:Load()
    OceanNormal.Visible = true
    terrain:SetOceanNormal(OceanNormal)
    nx_set_value("OceanNormal", OceanNormal)
  end
  OceanNormal.ColorR = ini:ReadFloat(ocean_name, "ColorR", 0.1)
  OceanNormal.ColorG = ini:ReadFloat(ocean_name, "ColorG", 0.4)
  OceanNormal.ColorB = ini:ReadFloat(ocean_name, "ColorB", 0.7)
  OceanNormal.SpecularColorR = ini:ReadFloat(ocean_name, "SpecularColorR", 0.7)
  OceanNormal.SpecularColorG = ini:ReadFloat(ocean_name, "SpecularColorG", 0.7)
  OceanNormal.SpecularColorB = ini:ReadFloat(ocean_name, "SpecularColorB", 0.1)
  OceanNormal.FogColorR = ini:ReadFloat(ocean_name, "FogColorR", 0.1529)
  OceanNormal.FogColorG = ini:ReadFloat(ocean_name, "FogColorG", 0.686)
  OceanNormal.FogColorB = ini:ReadFloat(ocean_name, "FogColorB", 0.7686)
  OceanNormal.CausticColorR = ini:ReadFloat(ocean_name, "CausticColorR", 1)
  OceanNormal.CausticColorG = ini:ReadFloat(ocean_name, "CausticColorG", 1)
  OceanNormal.CausticColorB = ini:ReadFloat(ocean_name, "CausticColorB", 1)
  OceanNormal.ScatterColorR = ini:ReadFloat(ocean_name, "ScatterColorR", 0)
  OceanNormal.ScatterColorG = ini:ReadFloat(ocean_name, "ScatterColorG", 0)
  OceanNormal.ScatterColorB = ini:ReadFloat(ocean_name, "ScatterColorB", 0)
  OceanNormal.DeepOceanColorR = ini:ReadFloat(ocean_name, "DeepOceanColorR", 0)
  OceanNormal.DeepOceanColorG = ini:ReadFloat(ocean_name, "DeepOceanColorG", 0.1)
  OceanNormal.DeepOceanColorB = ini:ReadFloat(ocean_name, "DeepOceanColorB", 0.3)
  OceanNormal.ScatterPow = ini:ReadFloat(ocean_name, "ScatterPow", 0)
  OceanNormal.TexScale = ini:ReadFloat(ocean_name, "TexScale", 1)
  OceanNormal.AlphaPow = ini:ReadFloat(ocean_name, "AlphaPow", 1)
  OceanNormal.Speed = ini:ReadFloat(ocean_name, "Speed", 1)
  OceanNormal.DirAngle = ini:ReadFloat(ocean_name, "DirAngle", 0)
  OceanNormal.ReflectPow = ini:ReadFloat(ocean_name, "ReflectPow", 0.5)
  OceanNormal.FogPow = ini:ReadFloat(ocean_name, "FogPow", 1)
  OceanNormal.HeightPow = ini:ReadFloat(ocean_name, "HeightPow", 1)
  OceanNormal.SharpPow = ini:ReadFloat(ocean_name, "SharpPow", 1)
  OceanNormal.BaseHeight = ini:ReadFloat(ocean_name, "BaseHeight", 130)
  OceanNormal.CausticBrightness = ini:ReadFloat(ocean_name, "CausticBrightness", 5)
  OceanNormal.CausticScale = ini:ReadFloat(ocean_name, "CausticScale", 1)
  OceanNormal.CausticSpeed = ini:ReadFloat(ocean_name, "CausticSpeed", 0.5)
  OceanNormal.WhiteSpeed = ini:ReadFloat(ocean_name, "WhiteSpeed", 0.5)
  OceanNormal.NormalPow = ini:ReadFloat(ocean_name, "NormalPow", 1)
  OceanNormal.Ambin = ini:ReadFloat(ocean_name, "Ambin", 0.2)
  OceanNormal.Diffuse = ini:ReadFloat(ocean_name, "Diffuse", 0.1)
  OceanNormal.ReflectBright = ini:ReadFloat(ocean_name, "ReflectBright", 1)
  OceanNormal.RefractBright = ini:ReadFloat(ocean_name, "RefractBright", 1)
  OceanNormal.SpecularPow = ini:ReadFloat(ocean_name, "SpecularPow", 1)
  OceanNormal.WhitePow = ini:ReadFloat(ocean_name, "WhitePow", 0.8)
  OceanNormal.WhiteScale = ini:ReadFloat(ocean_name, "WhiteScale", 1)
  OceanNormal.SpecularBright = ini:ReadFloat(ocean_name, "SpecularBright", 1)
  OceanNormal.RainSpeed = ini:ReadFloat(ocean_name, "RainSpeed", 1)
  OceanNormal.RainPow = ini:ReadFloat(ocean_name, "RainPow", 0)
  OceanNormal.RainScale = ini:ReadFloat(ocean_name, "RainScale", 1)
  OceanNormal.RefractPow = ini:ReadFloat(ocean_name, "RefractPow", 1)
  nx_destroy(ini)
end
function terrain_delete_ocean()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  nx_set_value("OceanNormal", nx_null())
end
function btn_exit_click(self)
  nx_destroy(self.ParentForm)
end
