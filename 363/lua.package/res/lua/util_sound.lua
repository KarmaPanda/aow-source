require("const_define")
local ITEM_SOUNT_INI = "ini\\sound\\itemsound.ini"
function play_link_sound(name, target, x, y, z, volume, distance, loop, path, ogg)
  if not nx_is_valid(target) then
    return 0
  end
  if name == nil or name == "" then
    return 0
  end
  local game_config = nx_value("game_config")
  if not game_config.sound_enable or game_config.sound_volume == 0 then
    return 0
  end
  local filename = ""
  if path == nil or path == "" then
    filename = "snd\\action\\" .. name .. ".wav"
    path = ""
  else
    filename = path .. name
  end
  if is_empty_file(filename) then
    return 0
  end
  if distance == nil then
    distance = 5
  else
    distance = nx_number(distance)
  end
  if volume == nil then
    volume = 1
  else
    volume = nx_number(volume)
    if volume == nil then
      volume = 1
    elseif volume < 0 or 1 < volume then
      volume = 1
    end
  end
  if loop == nil then
    loop = false
  end
  if ogg == nil then
    ogg = false
  end
  return nx_function("ext_play_link_sound", name, target, x, y, z, distance, loop, path, ogg)
end
function delete_sound(sound)
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) and nx_is_valid(sound) then
    scene:Delete(sound)
  end
end
function play_terrain_sound(name, x, y, z, loop)
  if is_empty_file(name) then
    return 0
  end
  nx_function("ext_play_terrain_sound", name, x, y, z, loop)
end
function play_action_sound(name, x, y, z)
  if name == nil or name == "" then
    return
  end
  local filename = "snd\\action\\" .. name .. ".wav"
  play_terrain_sound(filename, x, y, z, false)
end
function console_log_down(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Out(info)
  end
end
function do_sound_func(cur_obj, sound_name)
  local asynor = nx_value("common_execute")
  if nx_is_valid(timer) then
    asynor:RemoveExecute("do_sound", cur_obj)
    asynor:AddExecute("do_sound", cur_obj, nx_float(0.04))
    if sound_name ~= nil and sound_name ~= "" then
      cur_obj.sound = nx_execute("util_sound", "play_link_sound", nx_string(sound_name), cur_obj, 0, 0, 0, 1, 5, true)
    end
  end
end
function del_sound(obj)
  if nx_find_custom(obj, "sound") then
    nx_execute("util_sound", "delete_sound", obj.sound)
  end
end
function play_item_sound(item)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if not nx_is_valid(item) then
    return 0
  end
  local texture_type = item:QueryProp("TextureType")
  if nx_string(texture_type) == "" or texture_type == nil then
    return 0
  end
  local itemsound_ini = nx_execute("util_functions", "get_ini", ITEM_SOUNT_INI)
  if not nx_is_valid(itemsound_ini) then
    return 0
  end
  local index = itemsound_ini:FindSectionIndex(nx_string(texture_type))
  if index < 0 then
    return 0
  end
  local sound_file = itemsound_ini:ReadString(index, "Sound", "")
  if is_empty_file(sound_file) then
    return 0
  end
  local sound_name = "item_sound_" .. nx_string(texture_type)
  if not gui:FindSound(sound_name) then
    gui:AddSound(sound_name, nx_resource_path() .. sound_file)
  end
  gui:PlayingSound(sound_name)
end
function play_captial_sound()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local itemsound_ini = nx_execute("util_functions", "get_ini", ITEM_SOUNT_INI)
  if not nx_is_valid(itemsound_ini) then
    return 0
  end
  local index = itemsound_ini:FindSectionIndex("0")
  if index < 0 then
    return 0
  end
  local sound_file = itemsound_ini:ReadString(index, "Sound", "")
  if is_empty_file(sound_file) then
    return 0
  end
  if not gui:FindSound("item_sound_0") then
    gui:AddSound("item_sound_0", nx_resource_path() .. sound_file)
  end
  gui:PlayingSound("item_sound_0")
end
function is_empty_file(file_name)
  if file_name == nil or file_name == "" then
    return true
  end
  if string.find(file_name, "\\%.wav") ~= nil then
    return true
  end
  return false
end
