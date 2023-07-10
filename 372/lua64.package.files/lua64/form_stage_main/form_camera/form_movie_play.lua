function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.backup_absleft = form.AbsLeft
  form.backup_abstop = form.AbsTop
  form.backup_width = form.Width
  form.backup_height = form.Height
end
function on_main_form_close(form)
  local video_player = nx_value("video_player")
  if nx_is_valid(video_player) then
    video_player:Stop()
    video_player.state = "stop"
  end
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_play_tbar", form)
    end
    form.Visible = false
    nx_destroy(form)
  end
end
function on_btn_4_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_5_click(btn)
  local datasource = nx_string(btn.DataSource)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    change_player_size(form, datasource)
  end
end
function on_btn_3_click(btn)
  local video_player = nx_value("video_player")
  if nx_is_valid(video_player) then
    video_player:Play()
    video_player.state = "play"
  end
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_play_tbar", form)
      timer:Register(500, -1, nx_current(), "update_play_tbar", form, -1, -1)
    end
  end
end
function on_btn_2_click(btn)
  local video_player = nx_value("video_player")
  if nx_is_valid(video_player) then
    video_player:Stop()
    video_player.state = "stop"
  end
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_play_tbar", form)
    end
    local tbar = form.tbar_1
    local lbl = form.lbl_2
    tbar.Value = tbar.Minimum
    local mm2, ss2 = split_time_by_second(tbar.Maximum)
    lbl.Text = nx_widestr("00:00") .. nx_widestr("/" .. mm2 .. ":" .. ss2)
  end
end
function on_btn_1_click(btn)
  local video_player = nx_value("video_player")
  if nx_is_valid(video_player) then
    video_player:Pause()
    video_player.state = "pause"
  end
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_play_tbar", form)
    end
  end
end
function on_tbar_1_value_changed(tbar, value)
  local form = tbar.ParentForm
  if nx_is_valid(form) then
    local mm1, ss1 = split_time_by_second(tbar.Value)
    local mm2, ss2 = split_time_by_second(tbar.Maximum)
    local lbl = form.lbl_2
    lbl.Text = nx_widestr(mm1 .. ":" .. ss1) .. nx_widestr("/" .. mm2 .. ":" .. ss2)
  end
end
function movie_play(file_path)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_movie_play", true)
  if nx_is_valid(form) then
    local world = nx_value("world")
    local video_player = nx_value("video_player")
    if nx_is_valid(video_player) then
      world:Delete(video_player)
    end
    video_player = world:Create("VideoTex")
    nx_set_value("video_player", video_player)
    if nx_is_valid(video_player) then
      local video_name = file_path
      video_player.Name = nx_function("ext_gen_unique_name") .. ".dds"
      if video_player:LoadVideo(video_name, true) then
        form.pic_1.Image = video_player.Name
        video_player:Play()
        video_player.state = "play"
        video_player.Loop = false
      end
      local tbar = form.tbar_1
      tbar.Minimum = 0
      tbar.Maximum = video_player:GetStopPosition()
      tbar.Value = tbar.Minimum
    end
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_camera\\form_movie_play", true)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_play_tbar", form)
      timer:Register(500, -1, nx_current(), "update_play_tbar", form, -1, -1)
    end
  end
end
function split_time_by_second(second)
  second = math.floor(second)
  local mm = math.floor(second / 60)
  local ss = math.floor(second - mm * 60)
  if mm < 10 then
    mm = "0" .. mm
  end
  if ss < 10 then
    ss = "0" .. ss
  end
  return mm, ss
end
function update_play_tbar(form)
  if nx_is_valid(form) then
    local tbar = form.tbar_1
    local video_player = nx_value("video_player")
    if nx_is_valid(video_player) then
      local current_position = video_player:GetCurrentPosition()
      local stop_position = video_player:GetStopPosition()
      local diff_position = stop_position - current_position
      if diff_position < 0.5 then
        if not video_player.Loop then
          video_player:Stop()
          video_player.state = "stop"
          local timer = nx_value("timer_game")
          if nx_is_valid(timer) then
            timer:UnRegister(nx_current(), "update_play_tbar", form)
          end
        end
        tbar.Value = tbar.Minimum
      else
        local result, differ_tbar = differ_float(current_position, tbar.Value)
        if 0 == result then
          if video_player.Loop then
            if tbar.Maximum <= tbar.Value then
              tbar.Value = tbar.Minimum
            else
              video_player:SetCurrentPosition(tbar.Value)
            end
          else
            video_player:SetCurrentPosition(tbar.Value)
          end
        elseif 1 == result then
          if 1 == differ_tbar then
            tbar.Value = tbar.Value + 1
          elseif 1 < differ_tbar then
            video_player:SetCurrentPosition(tbar.Value)
          end
        end
      end
    end
  end
end
function change_player_size(form, flag)
  if nx_string("0") == flag then
    form.AbsLeft = 0
    form.AbsTop = 0
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.Width = gui.Desktop.Width
      form.Height = gui.Desktop.Height
    end
    form.btn_5.DataSource = nx_string("1")
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.btn_5.HintText = nx_widestr(gui.TextManager:GetText("tips_movie_play_zoomont"))
    end
  elseif nx_string("1") == flag then
    form.AbsLeft = form.backup_absleft
    form.AbsTop = form.backup_abstop
    form.Width = form.backup_width
    form.Height = form.backup_height
    form.btn_5.DataSource = nx_string("0")
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.btn_5.HintText = nx_widestr(gui.TextManager:GetText("tips_movie_play_zoomin"))
    end
  end
  form.lbl_1.Left = (form.Width - form.lbl_1.Width) / 2
  form.btn_4.Left = form.Width - 28
  form.btn_3.Top = form.Height - form.btn_3.Height - 8
  form.btn_1.Top = form.btn_3.Top
  form.btn_2.Top = form.btn_3.Top
  form.tbar_1.Top = form.btn_3.Top - form.tbar_1.Height - 18
  form.lbl_2.Top = form.tbar_1.Top + form.tbar_1.Height
  form.pic_1.Width = form.Width - 18
  form.pic_1.Height = form.tbar_1.Top - form.pic_1.Top - 6
  form.btn_5.Left = form.pic_1.Left + form.pic_1.Width - form.btn_5.Width
  form.tbar_1.Width = form.pic_1.Width
  form.lbl_2.Left = form.tbar_1.Left + form.tbar_1.Width - form.lbl_2.Width
  form.btn_3.Left = (form.Width - form.btn_3.Width - form.btn_1.Width - form.btn_2.Width - 4) / 2
  form.btn_1.Left = form.btn_3.Left + form.btn_3.Width + 2
  form.btn_2.Left = form.btn_1.Left + form.btn_1.Width + 2
end
function differ_float(value1, value2)
  local result = 2
  local differ = 0
  if value1 < value2 then
    result = 0
    differ = value2 - value1
  elseif value2 < value1 then
    result = 1
    differ = value1 - value2
  end
  local differ_int = math.floor(differ)
  local differ_dec = differ - differ_int
  if differ_dec < 0.5 then
    differ = differ_int
  else
    differ = differ_int + 1
  end
  return result, differ
end
