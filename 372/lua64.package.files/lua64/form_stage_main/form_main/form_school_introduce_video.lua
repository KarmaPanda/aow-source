require("util_gui")
function main_form_init(self)
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
end
function on_main_form_close(self)
  local world = nx_value("world")
  if nx_is_valid(world) then
    local video_player = nx_value("video_player")
    if nx_is_valid(video_player) then
      world:Delete(video_player)
    end
  end
  local form = nx_value("form_stage_main\\form_main\\form_school_introduce")
  if nx_is_valid(form) then
    form.lbl_back.Visible = false
  end
  nx_destroy(self)
end
function on_btn_1_click(btn)
  btn.ParentForm:Close()
end
function show_school_video(video_path)
  local dialog = util_get_form(nx_current(), true, false)
  if not nx_is_valid(dialog) then
    return
  end
  load_video(video_path)
  play_video(dialog.pic_1)
  dialog:ShowModal()
end
function on_size_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function load_video(video_path)
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return
  end
  local video_player = nx_value("video_player")
  if nx_is_valid(video_player) then
    world:Delete(video_player)
  end
  video_player = world:Create("VideoTex")
  if not nx_is_valid(video_player) then
    return
  end
  nx_set_value("video_player", video_player)
  video_player.Name = nx_function("ext_gen_unique_name") .. ".dds"
  if not video_player:LoadVideo(video_path, true) then
    return
  end
end
function play_video(pic)
  local video_player = nx_value("video_player")
  if not nx_is_valid(video_player) then
    return
  end
  pic.Image = video_player.Name
  video_player:Play()
  video_player.state = "play"
  video_player.Loop = true
end
function clear()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
