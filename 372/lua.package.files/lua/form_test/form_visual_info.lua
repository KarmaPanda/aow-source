local create_hint_form = function()
  local form = nx_value("hint_form")
  if nx_is_valid(form) then
    return true
  end
  local gui = nx_value("gui")
  form = gui:Create("Form")
  form.Name = "hint_form"
  form.Transparent = true
  form.NoFrame = true
  local hint_label = gui:Create("Label")
  hint_label.Name = "hint_label"
  hint_label.ForeColor = "255,0,255,255"
  hint_label.Transparent = true
  form.hint_label = hint_label
  local res = form:Add(hint_label)
  nx_set_value("hint_form", form)
  return true
end
function open_hint_info(visual, click_x, click_y)
  local info = ""
  if "Model" == nx_name(visual) then
    info = "(Model) " .. nx_string(visual.ModelFile)
  elseif "Actor2" == nx_name(visual) then
    info = "(Actor2) " .. nx_string(visual.ConfigFile)
  elseif "EffectModel" == nx_name(visual) then
    info = "(EffectModel) name:" .. nx_string(visual.Name) .. " config:" .. nx_string(visual.Config)
  elseif "Particle" == nx_name(visual) then
    info = "(Particle) par_name:" .. nx_string(visual.Name) .. " config:" .. nx_string(visual.Config)
  elseif "Sound" == nx_name(visual) then
    info = "(Sound) " .. nx_string(visual.Name)
  else
    info = "(" .. nx_string(nx_name(visual)) .. ")"
  end
  local hint_form = nx_value("hint_form")
  if not nx_is_valid(hint_form) then
    create_hint_form()
  end
  if nx_is_valid(hint_form) then
    hint_form.Left = click_x + 10
    hint_form.Top = click_y + 10
    hint_form.Width = string.len(info) * 10
    hint_form.Height = 30
    hint_form.hint_label.Left = 0
    hint_form.hint_label.Top = 0
    hint_form.hint_label.Width = string.len(info) * 10
    hint_form.hint_label.Height = 30
    hint_form.hint_label.Text = nx_widestr(info)
    hint_form:Show()
  end
  return true
end
function close_hint_info()
  local hint_form = nx_value("hint_form")
  if nx_is_valid(hint_form) then
    hint_form:Close()
  end
  return true
end
