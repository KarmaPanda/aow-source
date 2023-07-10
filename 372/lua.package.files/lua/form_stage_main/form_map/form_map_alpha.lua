local base_alpha = 100
local max_alpha = 255
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  change_form_size()
  local cur_alpha = max_alpha
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_find_custom(form_map, "map_ui_ini") and nx_is_valid(form_map.map_ui_ini) then
    local ini = form_map.map_ui_ini
    base_alpha = ini:ReadInteger("map", "MinBlendAlpha", 100)
    max_alpha = ini:ReadInteger("map", "MaxBlendAlpha", 255)
    cur_alpha = ini:ReadInteger("map", "CurBlendAlpha", max_alpha)
  end
  form.tbar_1.Value = cur_alpha
  on_tbar_1_value_changed(form.tbar_1)
end
function on_main_form_close(form)
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_find_custom(form_map, "map_ui_ini") and nx_is_valid(form_map.map_ui_ini) then
    local ini = form_map.map_ui_ini
    ini:WriteInteger("map", "CurBlendAlpha", form.tbar_1.Value)
    ini:SaveToFile()
  end
end
function on_tbar_1_value_changed(bar)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  local min_val = bar.Minimum
  local max_val = bar.Maximum
  local cur_val = bar.Value
  form.BlendAlpha = base_alpha + cur_val / (max_val - min_val) * (max_alpha - base_alpha)
  local form = bar.ParentForm
  local ratio = cur_val / (max_val - min_val)
  local lbl_back = form.lbl_2
  lbl_back.Left = form.tbar_1.Left
  lbl_back.Top = form.tbar_1.Top
  lbl_back.Width = bar.TrackButton.Left
  form.lbl_3.Text = nx_widestr("" .. nx_string(nx_int(ratio * 100)) .. "%")
end
function change_form_size()
end
