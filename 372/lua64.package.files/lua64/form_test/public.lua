function log(str)
  nx_function("ext_log_testor", str .. "\n")
end
function parse_color(color)
  local alpha = 0
  local red = 0
  local green = 0
  local blue = 0
  local pos1 = string.find(color, ",")
  if pos1 == nil then
    return alpha, red, green, blue
  end
  local pos2 = string.find(color, ",", pos1 + 1)
  if pos2 == nil then
    return alpha, red, green, blue
  end
  local pos3 = string.find(color, ",", pos2 + 1)
  if pos3 == nil then
    return alpha, red, green, blue
  end
  local alpha = nx_number(string.sub(color, 1, pos1 - 1))
  local red = nx_number(string.sub(color, pos1 + 1, pos2 - 1))
  local green = nx_number(string.sub(color, pos2 + 1, pos3 - 1))
  local blue = nx_number(string.sub(color, pos3 + 1))
  return alpha, red, green, blue
end
function get_color(default_color, notify_script, notify_function, notify_context)
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_test\\form_set_color.xml")
  local a, r, g, b = parse_color(default_color)
  dialog.alpha = a
  dialog.red = r
  dialog.green = g
  dialog.blue = b
  dialog.notify_script = notify_script
  dialog.notify_function = notify_function
  dialog.notify_context = notify_context
  dialog:ShowModal()
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  if "cancel" == res then
    return res, a, r, g, b
  end
  return res, alpha, red, green, blue
end
