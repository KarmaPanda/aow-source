require("util_gui")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_form_open(self)
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  set_control_value(self.music_check, game_config.music_enable)
  set_control_value(self.sound_check, game_config.sound_enable)
  set_control_value(self.area_music_check, game_config.area_music_enable)
  set_control_value(self.music_volume_track, game_config.music_volume * 100)
  set_control_value(self.sound_volume_track, game_config.sound_volume * 100)
  set_control_value(self.area_music_volume_track, game_config.area_music_volume * 100)
end
function on_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_system\\form_system_music_setting", nx_null())
end
function on_close_btn_click(self)
  util_show_form("form_stage_main\\form_system\\form_system_music_setting", false)
end
function on_ok_btn_click(self)
  util_show_form("form_stage_main\\form_system\\form_system_music_setting", false)
end
function set_music_enable(enable)
  local scene = get_cur_main_scene()
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return false
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if not nx_is_valid(scene_music_play_manager) then
    return false
  end
  scene_music_play_manager:SetMusicEnable(enable)
  nx_execute("game_config", "set_logic_sound_enable", scene, 2, enable)
  return true
end
function on_music_check_checked_changed(self)
  local game_config = nx_value("game_config")
  game_config.music_enable = self.Checked
  set_music_enable(game_config.music_enable)
  return 1
end
function music_control()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  game_config.music_enable = not game_config.music_enable
  set_music_enable(game_config.music_enable)
end
function yinxiao_control()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  game_config.sound_enable = not game_config.sound_enable
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_sound_enable", scene, game_config.sound_enable)
  nx_execute("game_config", "set_logic_sound_enable", scene, 1, game_config.sound_enable)
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    if game_config.sound_enable then
      voice_manager:SetAllVolume(game_config.sound_volume)
    else
      voice_manager:SetAllVolume(0)
    end
  end
end
function on_sound_check_checked_changed(self)
  local game_config = nx_value("game_config")
  game_config.sound_enable = self.Checked
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_sound_enable", scene, game_config.sound_enable)
  nx_execute("game_config", "set_logic_sound_enable", scene, 1, game_config.sound_enable)
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    if game_config.sound_enable then
      voice_manager:SetAllVolume(game_config.sound_volume)
    else
      voice_manager:SetAllVolume(0)
    end
  end
  return 1
end
function on_area_music_check_checked_changed(self)
  local scene = get_cur_main_scene()
  local game_config = nx_value("game_config")
  game_config.area_music_enable = self.Checked
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if not nx_find_custom(game_visual, "area_music") then
    return
  end
  local music = game_visual.area_music
  if game_config.area_music_enable then
    if nx_is_valid(music) then
      music.Volume = game_config.area_music_volume
      music:Play(1)
    end
  elseif nx_is_valid(music) then
    music.Volume = 0
    music:Stop(1)
  end
  nx_execute("game_config", "set_logic_sound_enable", scene, 0, game_config.area_music_enable)
end
function on_music_volume_track_value_changed(self)
  local game_config = nx_value("game_config")
  game_config.music_volume = self.Value * 0.01
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:SetMusicVolume(game_config.music_volume)
  end
  return 1
end
function inc_music_volume()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  if game_config.music_volume > 1 then
    game_config.music_volume = 1
    return
  end
  game_config.music_volume = game_config.music_volume + 0.1
  if game_config.music_volume > 1 then
    game_config.music_volume = 1
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:SetMusicVolume(game_config.music_volume)
  end
end
function dec_music_volume()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  if game_config.music_volume < 0 then
    game_config.music_volume = 0
    return
  end
  game_config.music_volume = game_config.music_volume - 0.1
  if game_config.music_volume < 0 then
    game_config.music_volume = 0
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:SetMusicVolume(game_config.music_volume)
  end
end
function on_sound_volume_track_value_changed(self)
  local game_config = nx_value("game_config")
  game_config.sound_volume = self.Value * 0.01
  local scene = get_cur_main_scene()
  nx_execute("game_config", "set_sound_volume", scene, game_config.sound_volume)
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:SetAllVolume(game_config.sound_volume)
  end
  return 1
end
function on_area_music_volume_track_value_changed(self)
  local game_config = nx_value("game_config")
  game_config.area_music_volume = self.Value * 0.01
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_find_custom(game_visual, "area_music") and nx_is_valid(game_visual.area_music) then
    game_visual.area_music.Volume = game_config.area_music_volume
  end
end
function get_cur_main_scene()
  local world = nx_value("world")
  return world.MainScene
end
function set_control_value(control, value)
  local name = nx_name(control)
  if name == "CheckButton" then
    control.Enabled = false
    control.Checked = value
    control.Enabled = true
  elseif name == "TrackBar" then
    control.Enabled = false
    control.Value = value
    control.Enabled = true
  elseif name == "Label" then
    control.Enabled = false
    control.Text = nx_widestr(value)
    control.Enabled = true
  end
end
