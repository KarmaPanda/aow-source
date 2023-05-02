require("util_functions")
require("const_define")
require("custom_handler")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
  self.esc_key = false
  self.movie_id = 0
end
function main_form_open(form)
  change_form_size()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  form.music_volume = game_config.music_volume
  form.sound_volume = game_config.sound_volume
  form.area_music_volume = game_config.area_music_volume
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:SetMusicVolume(0)
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:SetAllVolume(0)
  end
  if nx_find_custom(game_visual, "area_music") and nx_is_valid(game_visual.area_music) then
    game_visual.area_music.Volume = 0
  end
end
function change_form_size()
  local form = nx_value("form_common\\form_play_video")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  form.Width = desktop.Width
  form.Height = desktop.Height
  form.vid_poem.Left = 0
  form.vid_poem.Top = 0
  form.vid_poem.Width = form.Width
  form.vid_poem.Height = form.Height
  desktop:ToFront(form)
end
function main_form_close(form)
  nx_execute("custom_sender", "custom_movie_end", form.movie_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:SetMusicVolume(form.music_volume)
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:SetAllVolume(form.sound_volume)
  end
  if nx_find_custom(game_visual, "area_music") and nx_is_valid(game_visual.area_music) then
    game_visual.area_music.Volume = form.area_music_volume
  end
  nx_destroy(form)
end
function get_video_path(movie_id)
  local movie_ini = nx_execute("util_functions", "get_ini", "share\\Task\\Movie\\Movie.ini")
  if not nx_is_valid(movie_ini) then
    return ""
  end
  local sec_index = movie_ini:FindSectionIndex(nx_string(movie_id))
  local movie_name = ""
  if 0 <= sec_index then
    movie_name = movie_ini:ReadString(sec_index, "MovieName", "")
  end
  return movie_name
end
function play_video(movie_id)
  local form = nx_execute("util_gui", "util_get_form", "form_common\\form_play_video", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.movie_id = movie_id
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local file_path = get_video_path(movie_id)
  if file_path == "" then
    nx_execute("custom_sender", "custom_movie_end", movie_id)
  end
  form.vid_poem.Loop = false
  form.vid_poem.AutoPlay = false
  form.vid_poem.Video = file_path
  if game_config.music_enable == true then
    form.vid_poem.Volume = game_config.music_volume * 10000
  else
    form.vid_poem.Volume = 0
  end
  local res = form.vid_poem:Play()
  if not res then
    nx_execute("custom_sender", "custom_movie_end", movie_id)
  end
  form.btn_close.Visible = false
  local ini = nx_execute("util_functions", "get_ini", "ini\\quest\\videojump.ini")
  if not nx_is_valid(ini) then
    return
  end
  local value = 0
  if ini:FindSection("select_close") then
    local section_index = ini:FindSectionIndex("select_close")
    if section_index < 0 then
      return
    end
    local item_count = ini:GetSectionItemCount(section_index)
    if item_count < 1 then
      return
    end
    for i = 0, item_count - 1 do
      local sec_name = ini:GetSectionItemKey(section_index, i)
      if nx_int(sec_name) == nx_int(movie_id) then
        value = ini:GetSectionItemValue(section_index, i)
        if nx_int(value) == nx_int(1) then
          form.btn_close.Visible = true
        else
          form.btn_close.Visible = false
        end
      end
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_movie_end", form.movie_id)
end
function on_vid_poem_play_finish(video)
  local form = video.ParentForm
  nx_execute("custom_sender", "custom_movie_end", form.movie_id)
end
