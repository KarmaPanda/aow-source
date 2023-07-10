VENDOR_AMD = 4098
VENDOR_INTEL = 32902
VENDOR_NVIDIA = 4318
function get_video_card_level(device_caps)
  local level = -1
  local index = 0
  local adapter = -1
  if nx_find_method(device_caps, "GetDeviceList") then
    local device_table = device_caps:GetDeviceList()
    local device_count = table.getn(device_table)
    for i = 1, device_count, 3 do
      local description = device_table[i]
      local vendor_id = device_table[i + 1]
      local device_id = device_table[i + 2]
      local l = nx_function("ext_get_device_level", nx_resource_path() .. "ini\\systemset\\video.ini", vendor_id, device_id)
      if level < l then
        level = l
        adapter = index
      end
      index = index + 1
    end
    if 0 <= adapter then
      local description = device_table[adapter * 3 + 1]
      local vendor_id = device_table[adapter * 3 + 2]
      local device_id = device_table[adapter * 3 + 3]
    end
  else
    level = nx_function("ext_get_device_level", nx_resource_path() .. "ini\\systemset\\video.ini", device_caps.VendorId, device_caps.DeviceId)
  end
  local mem_size = device_caps.TotalVideoMemory + device_caps.TotalAgpMemory
  if level < 0 then
    if not device_caps.SupportShaderModel30 then
      level = 0
    elseif mem_size < 200 then
      level = 0
    else
      level = 1
    end
    return level, "not_identify"
  end
  if mem_size < 200 then
    level = 0
  end
  if not device_caps.SupportShaderModel30 then
    level = 0
  end
  return level
end
function compare_video_card(device_caps)
  local error_msg = nx_value("ErrorMsg")
  if not nx_is_valid(error_msg) then
    return 0
  end
  local dx_device_list = device_caps:GetDeviceList()
  local win_device_list = device_caps:GetAllDeviceList()
  local dx_device_num = table.getn(dx_device_list)
  local win_device_num = table.getn(win_device_list)
  local max_dx_level = 0
  for dx_index = 1, dx_device_num, 3 do
    local dx_desc = dx_device_list[dx_index]
    local dx_vendor_id = dx_device_list[dx_index + 1]
    local dx_device_id = dx_device_list[dx_index + 2]
    local dx_level = nx_function("ext_get_device_level", nx_resource_path() .. "ini\\systemset\\video.ini", dx_vendor_id, dx_device_id)
    if max_dx_level < dx_level then
      max_dx_level = dx_level
    end
  end
  local max_win_level = 0
  local diff_data = ""
  for win_index = 1, win_device_num, 3 do
    local win_desc = win_device_list[win_index]
    local win_vendor_id = win_device_list[win_index + 1]
    local win_device_id = win_device_list[win_index + 2]
    local win_level = nx_function("ext_get_device_level", nx_resource_path() .. "ini\\systemset\\video.ini", win_vendor_id, win_device_id)
    if max_dx_level < win_level then
      diff_data = diff_data .. win_vendor_id .. "," .. win_device_id .. "," .. nx_string(win_level) .. "," .. win_desc .. ";"
    end
    if max_win_level < win_level then
      max_win_level = win_level
    end
  end
  if diff_data == "" then
    return max_win_level
  end
  return max_win_level
end
function set_may_device_level(level)
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return false
  end
  if level > world.may_device_level then
    world.may_device_level = level
  end
  return true
end
