require("utils")
material_keys = {
  Ambient = "0.588,0.588,0.588",
  Diffuse = "0.588,0.588,0.588",
  Specular = "1.0,1.0,1.0",
  Emissive = "1.0,1.0,1.0",
  Glossiness = "10.0",
  Opacity = "1.0",
  AlphaRef = "0.0",
  SubSurfaceScale = "1.0",
  SubSurfaceFactor = "1.0",
  ReflectFactor = "1.0",
  BumpScale = "1.0",
  SpecularEnable = "false",
  EmissiveEnable = "false",
  OpacityEnable = "false",
  ReflectEnable = "false",
  BumpMapEnable = "false",
  AlphaTest = "false",
  Blend = "false",
  BlendEnhance = "false",
  BlendQuality = "false",
  NoZWrite = "false",
  DoubleSide = "false",
  PointFilter = "false",
  NoLight = "false",
  SphereAmbient = "false",
  Disappear = "false",
  SkinEffect = "false",
  HairEffect = "false",
  Refraction = "false",
  Applique = "false",
  SceneFog = "false",
  GlowEnable = "false",
  GlowEntire = "false",
  GlowEmissive = "false",
  GlowEmissiveMap = "false",
  GlowDiffuse = "false",
  GlowVertexColor = "false",
  GlowAppendColor = "false",
  GlowEnhance = "false",
  GlowBlur = "false",
  GlowSize = "0.0",
  GlowAlpha = "1.0",
  DiffuseMap = "",
  BumpMap = "",
  SpecularMap = "",
  SpecularLevelMap = "",
  GlossinessMap = "",
  EmissiveMap = "",
  ReflectionMap = "",
  LightMap = ""
}
function log(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = false
  self.tool_form_path = ""
  return 1
end
function string_to_color(color)
  local red = 0
  local green = 0
  local blue = 0
  local pos1 = string.find(color, ",")
  if pos1 == nil then
    return red, green, blue
  end
  local pos2 = string.find(color, ",", pos1 + 1)
  if pos2 == nil then
    return red, green, blue
  end
  local red = nx_number(string.sub(color, 1, pos1 - 1))
  local green = nx_number(string.sub(color, pos1 + 1, pos2 - 1))
  local blue = nx_number(string.sub(color, pos2 + 1))
  return math.floor(red * 255), math.floor(green * 255), math.floor(blue * 255)
end
function get_color_label(color)
  local red, green, blue = string_to_color(color)
  return "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function init_model_material(edit_material, visual)
  local child_model = edit_material:CreateChild(visual.ModelFile)
  child_model.visual = visual
  child_model.changed = false
  local material_table = visual:GetMaterialNameList()
  for i = 1, table.getn(material_table) do
    local material_name = string.lower(material_table[i])
    local child_material = child_model:CreateChild(material_name)
    for key in pairs(material_keys) do
      local val = visual:GetMaterialValue(material_name, key)
      nx_set_custom(child_material, key, val)
      nx_set_custom(child_material, "old_" .. key, val)
    end
  end
  load_material_file(child_model)
end
function init_visual_material(edit_material, visual)
  local entity_name = nx_name(visual)
  if entity_name == "Actor" or entity_name == "Actor2" then
    local visual_table = visual:GetVisualList()
    for i = 1, table.getn(visual_table) do
      init_visual_material(edit_material, visual_table[i])
    end
  elseif entity_name == "Model" or entity_name == "Skin" then
    init_model_material(edit_material, visual)
  elseif entity_name == "EffectModel" and nx_is_valid(visual.ModelID) and nx_name(visual.ModelID) == "Model" then
    init_model_material(edit_material, visual.ModelID)
  end
end
function init_edit_material()
  local edit_material = nx_call("util_gui", "get_global_arraylist", "edit_material")
  edit_material:ClearChild()
  edit_material.use_custom_material = false
  local game_select_obj = nx_value("game_select_obj")
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_select_obj) and nx_is_valid(game_visual) then
    local visual_object = game_visual:GetSceneObj(game_select_obj.Ident)
    if nx_is_valid(visual_object) then
      edit_material.visual = visual_object
      init_visual_material(edit_material, visual_object)
      return
    end
  end
  local role = nx_value("role")
  if nx_is_valid(role) then
    edit_material.visual = role
    init_visual_material(edit_material, role)
    return
  end
  local select = nx_value("visual_select")
  if nx_is_valid(select) and nx_is_valid(select.visual) then
    edit_material.visual = select.visual
    init_visual_material(edit_material, select.visual)
    return
  end
end
function update_vertex_info(form)
  local game_select_obj = nx_value("game_select_obj")
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_select_obj) and nx_is_valid(game_visual) then
    local visual_object = game_visual:GetSceneObj(game_select_obj.Ident)
    if nx_is_valid(visual_object) then
      return
    end
  end
  local role = nx_value("role")
  if nx_is_valid(role) then
    return
  end
  local select = nx_value("visual_select")
  if nx_is_valid(select) and nx_is_valid(select.visual) then
    local visual = select.visual
    if nx_name(visual) == "Model" then
      form.triangle_count_babel.Text = nx_widestr("\200\253\189\199\195\230\202\253\163\186") .. nx_widestr(visual:GetAllTriangleCount())
      form.vertex_count_label.Text = nx_widestr("\182\165\181\227\202\253\163\186") .. nx_widestr(visual:GetAllVertexCount())
    end
    return
  end
end
function get_select_model(form)
  local model_name = nx_string(form.model_combo.Text)
  if model_name == "" then
    return nx_null()
  end
  local edit_material = nx_value("edit_material")
  local child_model = edit_material:GetChild(model_name)
  if not nx_is_valid(child_model) then
    return nx_null()
  end
  return child_model.visual
end
function get_select_material(form)
  local model_name = nx_string(form.model_combo.Text)
  if model_name == "" then
    return nx_null()
  end
  local edit_material = nx_value("edit_material")
  local child_model = edit_material:GetChild(model_name)
  if not nx_is_valid(child_model) then
    return nx_null()
  end
  local material_name = nx_string(form.material_list.SelectString)
  if material_name == "" then
    return nx_null()
  end
  return child_model:GetChild(material_name)
end
function change_material(form, key, val)
  local child_material = get_select_material(form)
  if not nx_is_valid(child_material) then
    return false
  end
  local old_val = nx_custom(child_material, key)
  if val == old_val then
    return false
  end
  nx_set_custom(child_material, key, val)
  local edit_material = nx_value("edit_material")
  local model = get_select_model(form)
  if nx_is_valid(model) then
    if edit_material.use_custom_material == true then
      model:SetCustomMaterialValue(child_material.Name, key, val)
    else
      model:SetMaterialValue(child_material.Name, key, val)
    end
  end
  local model_name = nx_string(form.model_combo.Text)
  local child_model = edit_material:GetChild(model_name)
  if nx_is_valid(child_model) then
    child_model.changed = true
  end
  return true
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  init_edit_material()
  update_vertex_info(self)
  local edit_material = nx_value("edit_material")
  local model_table = edit_material:GetChildList()
  local model_list = self.model_combo.DropListBox
  model_list:ClearString()
  for i = 1, table.getn(model_table) do
    model_list:AddString(nx_widestr(model_table[i].Name))
    if i == 1 then
      self.model_combo.Text = nx_widestr(model_table[i].Name)
    end
  end
  nx_execute(nx_current(), "model_combo_selected", self.model_combo)
  self.lock_ambient_check.Checked = true
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  local gui = nx_value("gui")
  local edit_material = nx_value("edit_material")
  local model_table = edit_material:GetChildList()
  for i = 1, table.getn(model_table) do
    local child_model = model_table[i]
    if child_model.changed then
      local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. form.tool_form_path .. "form_confirm.xml")
      dialog.info_label.Text = nx_widestr("\196\163\208\205[" .. child_model.Name .. "]\183\162\201\250\208\222\184\196\163\172\210\170\177\163\180\230\178\196\214\202\206\196\188\254\194\240\163\191")
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "cancel" then
        return 0
      end
      if not save_material_file(child_model) then
        nx_msgbox("\206\222\183\168\177\163\180\230\196\163\208\205[" .. child_model.Name .. "]\181\196\178\196\214\202\206\196\188\254")
      end
    end
  end
  form:Close()
  nx_gen_event(form, "edit_material_return", "ok")
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  local edit_material = nx_value("edit_material")
  local model_table = edit_material:GetChildList()
  for i = 1, table.getn(model_table) do
    local child_model = model_table[i]
    local model = child_model.visual
    local material_table = model_table[i]:GetChildList()
    local changed = false
    for k = 1, table.getn(material_table) do
      local child_material = material_table[k]
      for key in pairs(material_keys) do
        local new_val = nx_custom(child_material, key)
        local old_val = nx_custom(child_material, "old_" .. key)
        if new_val ~= old_val then
          if edit_material.use_custom_material == true then
            model:SetCustomMaterialValue(child_material.Name, key, old_val)
          else
            model:SetMaterialValue(child_material.Name, key, old_val)
          end
          changed = true
        end
      end
    end
    if changed then
      model:ReloadMaterialTextures()
    end
  end
  form:Close()
  nx_gen_event(form, "edit_material_return", "cancel")
  nx_destroy(form)
  return 1
end
function save_btn_click(self)
  local form = self.Parent
  local edit_material = nx_value("edit_material")
  local model_name = nx_string(form.model_combo.Text)
  local child_model = edit_material:GetChild(model_name)
  if not nx_is_valid(child_model) then
    return 0
  end
  local model_full_name = nx_resource_path() .. nx_string(form.model_combo.Text)
  local model_path, model_n = nx_function("ext_split_file_path", model_full_name)
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. form.tool_form_path .. "form_filename.xml")
  dialog.path = model_path
  dialog.ext = "*.mtl"
  dialog:ShowModal()
  local res, new_name = nx_wait_event(100000000, dialog, "filename_return")
  if res == "cancel" then
    return 0
  end
  if new_name == "" then
    return 0
  end
  if new_name ~= "" then
    local file_name, file_ext = nx_function("ext_split_file_name", new_name)
    if file_ext == "" then
      new_name = new_name .. ".mtl"
    end
  end
  if not save_material_file(child_model, model_path .. new_name) then
    disp_error("\206\222\183\168\177\163\180\230\196\163\208\205\181\196\178\196\214\202\206\196\188\254")
    return 0
  end
  return 1
end
function model_combo_selected(self)
  local model_name = nx_string(self.Text)
  if model_name == "" then
    return 0
  end
  local edit_material = nx_value("edit_material")
  local child_model = edit_material:GetChild(model_name)
  if not nx_is_valid(child_model) then
    return 0
  end
  local material_table = child_model:GetChildList()
  local form = self.Parent
  local material_list = form.material_list
  material_list:ClearString()
  material_list.SelectIndex = -1
  for i = 1, table.getn(material_table) do
    material_list:AddString(nx_widestr(material_table[i].Name))
  end
  if 0 < table.getn(material_table) then
    material_list.SelectIndex = 0
  end
  form.color_label.BackColor = child_model.visual.Color
  return 1
end
function material_list_select_changed(self)
  local form = self.Parent
  local child_material = get_select_material(form)
  if not nx_is_valid(child_material) then
    return 0
  end
  form.ambient_label.BackColor = get_color_label(nx_custom(child_material, "Ambient"))
  form.diffuse_label.BackColor = get_color_label(nx_custom(child_material, "Diffuse"))
  form.specular_label.BackColor = get_color_label(nx_custom(child_material, "Specular"))
  form.emissive_label.BackColor = get_color_label(nx_custom(child_material, "Emissive"))
  form.glossiness_edit.Text = nx_widestr(nx_custom(child_material, "Glossiness"))
  form.opacity_edit.Text = nx_widestr(nx_custom(child_material, "Opacity"))
  form.alpha_ref_edit.Text = nx_widestr(nx_custom(child_material, "AlphaRef"))
  form.subsurface_scale_edit.Text = nx_widestr(nx_custom(child_material, "SubSurfaceScale"))
  form.subsurface_factor_edit.Text = nx_widestr(nx_custom(child_material, "SubSurfaceFactor"))
  form.reflect_factor_edit.Text = nx_widestr(nx_custom(child_material, "ReflectFactor"))
  form.bump_scale_edit.Text = nx_widestr(nx_custom(child_material, "BumpScale"))
  form.specular_check.Checked = nx_boolean(nx_custom(child_material, "SpecularEnable"))
  form.emissive_check.Checked = nx_boolean(nx_custom(child_material, "EmissiveEnable"))
  form.opacity_check.Checked = nx_boolean(nx_custom(child_material, "OpacityEnable"))
  form.reflect_check.Checked = nx_boolean(nx_custom(child_material, "ReflectEnable"))
  form.bumpmap_check.Checked = nx_boolean(nx_custom(child_material, "BumpMapEnable"))
  form.alpha_test_check.Checked = nx_boolean(nx_custom(child_material, "AlphaTest"))
  form.blend_check.Checked = nx_boolean(nx_custom(child_material, "Blend"))
  form.blend_enhance_check.Checked = nx_boolean(nx_custom(child_material, "BlendEnhance"))
  form.blend_quality_check.Checked = nx_boolean(nx_custom(child_material, "BlendQuality"))
  form.no_zwrite_check.Checked = nx_boolean(nx_custom(child_material, "NoZWrite"))
  form.double_side_check.Checked = nx_boolean(nx_custom(child_material, "DoubleSide"))
  form.point_filter_check.Checked = nx_boolean(nx_custom(child_material, "PointFilter"))
  form.no_light_check.Checked = nx_boolean(nx_custom(child_material, "NoLight"))
  form.sphere_ambient_check.Checked = nx_boolean(nx_custom(child_material, "SphereAmbient"))
  form.disappear_check.Checked = nx_boolean(nx_custom(child_material, "Disappear"))
  form.skin_effect_check.Checked = nx_boolean(nx_custom(child_material, "SkinEffect"))
  form.hair_effect_check.Checked = nx_boolean(nx_custom(child_material, "HairEffect"))
  form.refraction_check.Checked = nx_boolean(nx_custom(child_material, "Refraction"))
  form.applique_check.Checked = nx_boolean(nx_custom(child_material, "Applique"))
  form.scene_fog_check.Checked = nx_boolean(nx_custom(child_material, "SceneFog"))
  form.glow_enable_check.Checked = nx_boolean(nx_custom(child_material, "GlowEnable"))
  form.glow_entire_check.Checked = nx_boolean(nx_custom(child_material, "GlowEntire"))
  form.glow_emissive_check.Checked = nx_boolean(nx_custom(child_material, "GlowEmissive"))
  form.glow_emissivemap_check.Checked = nx_boolean(nx_custom(child_material, "GlowEmissiveMap"))
  form.glow_diffuse_check.Checked = nx_boolean(nx_custom(child_material, "GlowDiffuse"))
  form.glow_vertexcolor_check.Checked = nx_boolean(nx_custom(child_material, "GlowVertexColor"))
  form.glow_appendcolor_check.Checked = nx_boolean(nx_custom(child_material, "GlowAppendColor"))
  form.glow_enhance_check.Checked = nx_boolean(nx_custom(child_material, "GlowEnhance"))
  form.glow_blur_check.Checked = nx_boolean(nx_custom(child_material, "GlowBlur"))
  form.glow_size_edit.Text = nx_widestr(nx_custom(child_material, "GlowSize"))
  form.glow_alpha_edit.Text = nx_widestr(nx_custom(child_material, "GlowAlpha"))
  form.diffuse_map_edit.Text = nx_widestr(nx_custom(child_material, "DiffuseMap"))
  form.bump_map_edit.Text = nx_widestr(nx_custom(child_material, "BumpMap"))
  form.specular_map_edit.Text = nx_widestr(nx_custom(child_material, "SpecularMap"))
  form.specular_level_map_edit.Text = nx_widestr(nx_custom(child_material, "SpecularLevelMap"))
  form.glossiness_map_edit.Text = nx_widestr(nx_custom(child_material, "GlossinessMap"))
  form.emissive_map_edit.Text = nx_widestr(nx_custom(child_material, "EmissiveMap"))
  form.reflection_map_edit.Text = nx_widestr(nx_custom(child_material, "ReflectionMap"))
  form.light_map_edit.Text = nx_widestr(nx_custom(child_material, "LightMap"))
  local diffuse_map = nx_custom(child_material, "DiffuseMap")
  display_texture(form, diffuse_map)
  return 1
end
function display_texture(form, tex_name)
  if tex_name ~= "" then
    local model_name = nx_resource_path() .. nx_string(form.model_combo.Text)
    local file_path, file_name = nx_function("ext_split_file_path", model_name)
    form.diffuse_pict.Image = file_path .. tex_name
    form.image_size_label.Text = nx_widestr("\191\237\163\186" .. nx_string(form.diffuse_pict.ImageWidth) .. "\163\172\184\223\163\186" .. nx_string(form.diffuse_pict.ImageHeight))
  else
    form.diffuse_pict.Image = ""
    form.image_size_label.Text = nx_widestr("\204\249\205\188\179\223\180\231\163\186")
  end
  return true
end
function lock_ambient_check_checked_changed(self)
  local form = self.Parent
  form.ambient_btn.Enabled = not self.Checked
  return 1
end
function ambient_notify(form, alpha, red, green, blue)
  local val = nx_decimals(red / 255, 3) .. "," .. nx_decimals(green / 255, 3) .. "," .. nx_decimals(blue / 255, 3)
  change_material(form, "Ambient", val)
  return 1
end
function diffuse_notify(form, alpha, red, green, blue)
  local val = nx_decimals(red / 255, 3) .. "," .. nx_decimals(green / 255, 3) .. "," .. nx_decimals(blue / 255, 3)
  change_material(form, "Diffuse", val)
  if form.lock_ambient_check.Checked then
    change_material(form, "Ambient", val)
  end
  return 1
end
function specular_notify(form, alpha, red, green, blue)
  local val = nx_decimals(red / 255, 3) .. "," .. nx_decimals(green / 255, 3) .. "," .. nx_decimals(blue / 255, 3)
  change_material(form, "Specular", val)
  return 1
end
function emissive_notify(form, alpha, red, green, blue)
  local val = nx_decimals(red / 255, 3) .. "," .. nx_decimals(green / 255, 3) .. "," .. nx_decimals(blue / 255, 3)
  change_material(form, "Emissive", val)
  return 1
end
function ambient_btn_click(self)
  local form = self.Parent
  local child_material = get_select_material(form)
  if not nx_is_valid(child_material) then
    return 0
  end
  local old_value = nx_custom(child_material, "Ambient")
  local red, green, blue = string_to_color(old_value)
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. form.tool_form_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = red
  dialog.green = green
  dialog.blue = blue
  dialog.notify_script = nx_current()
  dialog.notify_function = "ambient_notify"
  dialog.notify_context = form
  dialog:ShowModal()
  local res, a, r, g, b = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    change_material(form, "Ambient", old_value)
  end
  form.ambient_label.BackColor = get_color_label(nx_custom(child_material, "Ambient"))
  return 1
end
function diffuse_btn_click(self)
  local form = self.Parent
  local child_material = get_select_material(form)
  if not nx_is_valid(child_material) then
    return 0
  end
  local old_value = nx_custom(child_material, "Diffuse")
  local red, green, blue = string_to_color(old_value)
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. form.tool_form_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = red
  dialog.green = green
  dialog.blue = blue
  dialog.notify_script = nx_current()
  dialog.notify_function = "diffuse_notify"
  dialog.notify_context = form
  dialog:ShowModal()
  local res, a, r, g, b = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    change_material(form, "Diffuse", old_value)
    if form.lock_ambient_check.Checked then
      change_material(form, "Ambient", old_value)
    end
  end
  form.diffuse_label.BackColor = get_color_label(nx_custom(child_material, "Diffuse"))
  if form.lock_ambient_check.Checked then
    form.ambient_label.BackColor = get_color_label(nx_custom(child_material, "Ambient"))
  end
  return 1
end
function specular_btn_click(self)
  local form = self.Parent
  local child_material = get_select_material(form)
  if not nx_is_valid(child_material) then
    return 0
  end
  local old_value = nx_custom(child_material, "Specular")
  local red, green, blue = string_to_color(old_value)
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. form.tool_form_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = red
  dialog.green = green
  dialog.blue = blue
  dialog.notify_script = nx_current()
  dialog.notify_function = "specular_notify"
  dialog.notify_context = form
  dialog:ShowModal()
  local res, a, r, g, b = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    change_material(form, "Specular", old_value)
  end
  form.specular_label.BackColor = get_color_label(nx_custom(child_material, "Specular"))
  return 1
end
function emissive_btn_click(self)
  local form = self.Parent
  local child_material = get_select_material(form)
  if not nx_is_valid(child_material) then
    return 0
  end
  local old_value = nx_custom(child_material, "Emissive")
  local red, green, blue = string_to_color(old_value)
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. form.tool_form_path .. "form_set_color.xml")
  dialog.alpha = 255
  dialog.red = red
  dialog.green = green
  dialog.blue = blue
  dialog.notify_script = nx_current()
  dialog.notify_function = "emissive_notify"
  dialog.notify_context = form
  dialog:ShowModal()
  local res, a, r, g, b = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    change_material(form, "Emissive", old_value)
  end
  form.emissive_label.BackColor = get_color_label(nx_custom(child_material, "Emissive"))
  return 1
end
function glossiness_edit_changed(self)
  change_material(self.Parent, "Glossiness", nx_string(self.Text))
  return 1
end
function opacity_edit_changed(self)
  change_material(self.Parent, "Opacity", nx_string(self.Text))
  return 1
end
function alpha_ref_edit_changed(self)
  change_material(self.Parent, "AlphaRef", nx_string(self.Text))
  return 1
end
function subsurface_scale_edit_changed(self)
  change_material(self.Parent, "SubSurfaceScale", nx_string(self.Text))
  return 1
end
function subsurface_factor_edit_changed(self)
  change_material(self.Parent, "SubSurfaceFactor", nx_string(self.Text))
  return 1
end
function reflect_factor_edit_changed(self)
  change_material(self.Parent, "ReflectFactor", nx_string(self.Text))
  return 1
end
function bump_scale_edit_changed(self)
  change_material(self.Parent, "BumpScale", nx_string(self.Text))
  return 1
end
function specular_check_checked_changed(self)
  change_material(self.Parent, "SpecularEnable", nx_string(self.Checked))
  return 1
end
function emissive_check_checked_changed(self)
  change_material(self.Parent, "EmissiveEnable", nx_string(self.Checked))
  return 1
end
function opacity_check_checked_changed(self)
  change_material(self.Parent, "OpacityEnable", nx_string(self.Checked))
  return 1
end
function reflect_check_checked_changed(self)
  change_material(self.Parent, "ReflectEnable", nx_string(self.Checked))
  return 1
end
function bumpmap_check_checked_changed(self)
  change_material(self.Parent, "BumpMapEnable", nx_string(self.Checked))
  return 1
end
function alpha_test_check_checked_changed(self)
  change_material(self.Parent, "AlphaTest", nx_string(self.Checked))
  return 1
end
function blend_check_checked_changed(self)
  change_material(self.Parent, "Blend", nx_string(self.Checked))
  return 1
end
function blend_enhance_check_checked_changed(self)
  change_material(self.Parent, "BlendEnhance", nx_string(self.Checked))
  return 1
end
function blend_quality_check_checked_changed(self)
  change_material(self.Parent, "BlendQuality", nx_string(self.Checked))
  return 1
end
function alpha_test_check_checked_changed(self)
  change_material(self.Parent, "AlphaTest", nx_string(self.Checked))
  return 1
end
function no_zwrite_check_checked_changed(self)
  change_material(self.Parent, "NoZWrite", nx_string(self.Checked))
  return 1
end
function double_side_check_checked_changed(self)
  change_material(self.Parent, "DoubleSide", nx_string(self.Checked))
  return 1
end
function point_filter_check_checked_changed(self)
  change_material(self.Parent, "PointFilter", nx_string(self.Checked))
  return 1
end
function no_light_check_checked_changed(self)
  change_material(self.Parent, "NoLight", nx_string(self.Checked))
  return 1
end
function sphere_ambient_check_checked_changed(self)
  change_material(self.Parent, "SphereAmbient", nx_string(self.Checked))
  return 1
end
function disappear_check_checked_changed(self)
  change_material(self.Parent, "Disappear", nx_string(self.Checked))
  return 1
end
function skin_effect_check_checked_changed(self)
  change_material(self.Parent, "SkinEffect", nx_string(self.Checked))
  return 1
end
function hair_effect_check_checked_changed(self)
  change_material(self.Parent, "HairEffect", nx_string(self.Checked))
  return 1
end
function refraction_check_checked_changed(self)
  change_material(self.Parent, "Refraction", nx_string(self.Checked))
  return 1
end
function applique_check_checked_changed(self)
  change_material(self.Parent, "Applique", nx_string(self.Checked))
  return 1
end
function scene_fog_check_checked_changed(self)
  change_material(self.Parent, "SceneFog", nx_string(self.Checked))
  return 1
end
function glow_enable_check_checked_changed(self)
  change_material(self.Parent, "GlowEnable", nx_string(self.Checked))
  return 1
end
function glow_entire_check_checked_changed(self)
  change_material(self.Parent, "GlowEntire", nx_string(self.Checked))
  return 1
end
function glow_emissive_check_checked_changed(self)
  change_material(self.Parent, "GlowEmissive", nx_string(self.Checked))
  return 1
end
function glow_emissivemap_check_checked_changed(self)
  change_material(self.Parent, "GlowEmissiveMap", nx_string(self.Checked))
  return 1
end
function glow_diffuse_check_checked_changed(self)
  change_material(self.Parent, "GlowDiffuse", nx_string(self.Checked))
  return 1
end
function glow_vertexcolor_check_checked_changed(self)
  change_material(self.Parent, "GlowVertexColor", nx_string(self.Checked))
  return 1
end
function glow_appendcolor_check_checked_changed(self)
  change_material(self.Parent, "GlowAppendColor", nx_string(self.Checked))
  return 1
end
function glow_enhance_check_checked_changed(self)
  change_material(self.Parent, "GlowEnhance", nx_string(self.Checked))
  return 1
end
function glow_blur_check_checked_changed(self)
  change_material(self.Parent, "GlowBlur", nx_string(self.Checked))
  return 1
end
function glow_size_edit_changed(self)
  change_material(self.Parent, "GlowSize", nx_string(self.Text))
  return 1
end
function glow_alpha_edit_changed(self)
  change_material(self.Parent, "GlowAlpha", nx_string(self.Text))
  return 1
end
function select_material_tex(form, material_key, edit_control)
  local child_material = get_select_material(form)
  if not nx_is_valid(child_material) then
    return 0
  end
  local tex_name = nx_custom(child_material, material_key)
  display_texture(form, tex_name)
  local model_full_name = nx_resource_path() .. nx_string(form.model_combo.Text)
  local model_path, model_name = nx_function("ext_split_file_path", model_full_name)
  local text_path = model_path
  if not nx_file_exists(text_path .. tex_name) then
    local terrain = nx_value("terrain")
    if nx_is_valid(terrain) then
      local tex_path_table = terrain:GetTexturePathList()
      local tex_num = table.getn(tex_path_table)
      for i = 1, tex_num do
        if nx_file_exists(nx_resource_path() .. tex_path_table[i] .. tex_name) then
          text_path = nx_resource_path() .. tex_path_table[i]
          break
        end
      end
    end
  end
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. form.tool_form_path .. "form_pictfile.xml")
  dialog.path = text_path
  dialog.ext = "*.dds"
  dialog:ShowModal()
  local res, new_name = nx_wait_event(100000000, dialog, "pictfile_return")
  if res == "cancel" then
    return 0
  end
  if new_name ~= "" then
    local file_name, file_ext = nx_function("ext_split_file_name", new_name)
    if string.lower(file_ext) ~= "dds" then
      disp_error("\178\187\202\199\211\208\208\167\181\196\204\249\205\188\206\196\188\254")
      return 0
    end
  end
  change_material(form, material_key, new_name)
  edit_control.Text = nx_widestr(new_name)
  local child_model = get_select_model(form)
  if nx_is_valid(child_model) then
    child_model:ReloadMaterialTextures()
  end
  display_texture(form, new_name)
  return 1
end
function diffuse_map_btn_click(self)
  select_material_tex(self.Parent, "DiffuseMap", self.Parent.diffuse_map_edit)
  return 1
end
function bump_map_btn_click(self)
  select_material_tex(self.Parent, "BumpMap", self.Parent.bump_map_edit)
  return 1
end
function specular_map_btn_click(self)
  select_material_tex(self.Parent, "SpecularMap", self.Parent.specular_map_edit)
  return 1
end
function specular_level_map_btn_click(self)
  select_material_tex(self.Parent, "SpecularLevelMap", self.Parent.specular_level_map_edit)
  return 1
end
function glossiness_map_btn_click(self)
  select_material_tex(self.Parent, "GlossinessMap", self.Parent.glossiness_map_edit)
  return 1
end
function emissive_map_btn_click(self)
  select_material_tex(self.Parent, "EmissiveMap", self.Parent.emissive_map_edit)
  return 1
end
function reflection_map_btn_click(self)
  select_material_tex(self.Parent, "ReflectionMap", self.Parent.reflection_map_edit)
  return 1
end
function light_map_btn_click(self)
  select_material_tex(self.Parent, "LightMap", self.Parent.light_map_edit)
  return 1
end
local inner_load_material_file = function(file_name, child_model)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local sect_table = ini:GetSectionList()
  for i = 1, table.getn(sect_table) do
    local sect = string.lower(sect_table[i])
    local child_material = child_model:GetChild(sect)
    if nx_is_valid(child_material) then
      for key, def_val in pairs(material_keys) do
        if ini:FindItem(sect, key) then
          local val = ini:ReadString(sect, key, def_val)
          nx_set_custom(child_material, key, val)
        end
      end
    end
  end
  nx_destroy(ini)
  return true
end
local function inner_load_custom_material_file(child_model)
  local edit_material = nx_value("edit_material")
  local visual = edit_material.visual
  if nx_name(visual) == "Actor2" then
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. visual.ConfigFile
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return false
    end
    local sect_table = ini:GetSectionList()
    if table.getn(sect_table) == 0 then
      nx_destroy(ini)
      return false
    end
    local material_file = ini:ReadString(sect_table[1], "@Model", "")
    nx_destroy(ini)
    if "" ~= material_file then
      return inner_load_material_file(material_file, child_model)
    end
  end
  return false
end
function load_material_file(child_model)
  if inner_load_custom_material_file(child_model) then
    local edit_material = nx_value("edit_material")
    edit_material.use_custom_material = true
    return true
  end
  local file_name = string.lower(child_model.Name)
  local pos = string.find(file_name, ".xmod")
  if pos ~= nil then
    file_name = string.sub(file_name, 1, pos - 1)
  end
  return inner_load_material_file(file_name .. ".mtl", child_model)
end
function material_value_changed(child_material, key)
  if not nx_is_valid(child_material) then
    return false
  end
  local now_val = nx_custom(child_material, key)
  local old_val = nx_custom(child_material, "old_" .. key)
  if now_val ~= old_val then
    return true
  end
  return false
end
local inner_save_material_file = function(file_name, child_model)
  local ini = nx_create("IniDocument")
  local material_table = child_model:GetChildList()
  for i = 1, table.getn(material_table) do
    local child_material = material_table[i]
    if not ini:FindSection(child_material.Name) then
      for key, def_val in pairs(material_keys) do
        local val = nx_custom(child_material, key)
        if val ~= def_val or material_value_changed(child_material, key) then
          ini:WriteString(child_material.Name, key, val)
        end
      end
    end
  end
  ini.FileName = file_name
  if not ini:SaveToFile() then
    nx_destroy(ini)
    return false
  end
  nx_destroy(ini)
  return true
end
local function inner_save_custom_material_file(child_model)
  local edit_material = nx_value("edit_material")
  local visual = edit_material.visual
  if nx_name(visual) == "Actor2" then
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. visual.ConfigFile
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return false
    end
    local sect_table = ini:GetSectionList()
    if table.getn(sect_table) == 0 then
      nx_destroy(ini)
      return false
    end
    local material_file = ini:ReadString(sect_table[1], "@Model", "")
    nx_destroy(ini)
    if "" ~= material_file then
      return inner_save_material_file(nx_resource_path() .. material_file, child_model)
    end
  end
  return false
end
function save_material_file(child_model, file_name)
  if file_name == nil then
    if inner_save_custom_material_file(child_model) then
      return true
    end
    local model_name = string.lower(child_model.Name)
    local pos = string.find(model_name, ".xmod")
    if pos ~= nil then
      model_name = string.sub(model_name, 1, pos - 1)
    end
    file_name = nx_resource_path() .. model_name .. ".mtl"
  end
  return inner_save_material_file(file_name, child_model)
end
