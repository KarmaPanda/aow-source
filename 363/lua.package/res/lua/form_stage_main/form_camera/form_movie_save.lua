require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
FPS_MIN = 8
FPS_MAX = 20
Quality_Low = 6000
Quality_Mid = 8000
Quality_High = 10000
MOVIE_FPS = 10
MOVIE_QUALITY = 8000
MOVIE_SIZE_X = 800
MOVIE_SIZE_Y = 600
DEFAULT_DIR = "D:\\"
DEFAULT_FN = "9y-Video"
DEFAULT_X = 0
DEFAULT_Y = 0
DEFAULT_W = 1280
DEFAULT_H = 1024
RESOLUTION_0 = "320*240"
RESOLUTION_1 = "640*480"
RESOLUTION_2 = "800*600"
RESOLUTION_3 = "1024*768"
RESOLUTION_4 = "1280*1024"
RESOLUTION_5 = "1400*1050"
RESOLUTION_6 = "1600*1200"
RESOLUTION_7 = "2048*1536"
local Video_Path = DEFAULT_DIR
local Video_Resolution = ""
local Video_Quality = ""
local Video_fps = ""
local Video_config_Succeed = false
function main_form_init(form)
  form.Fixed = false
  form.cloneid = nil
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  init_movie_ui(form)
  load_moive_config(form)
end
function on_main_form_close(form)
  Video_fps = nx_string(form.fps.Text)
  Video_Quality = nx_string(form.combobox_quality.Text)
  Video_Resolution = nx_string(form.combobox_size.Text)
  Save_movie_config(true)
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function ok_btn_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not can_movie(form) then
    return
  end
  if form.groupbox_1.Visible and not form.groupbox_2.Visible and not form.groupbox_3.Visible then
    local MovieSaver = nx_value("MovieSaverModule")
    if not nx_is_valid(MovieSaver) then
      return
    end
    if not MovieSaver:IsRecording() then
      local type = 0
      local fps = nx_int(form.fps.Text)
      local Quality = nx_int(form.combobox_quality.Text)
      local sizeX, sizeY = get_resolution(form)
      local dir = form.dir.Text
      local fn = nx_widestr(nx_string(DEFAULT_FN))
      local res
      if form.rbtn_2.Checked == true then
        res = MovieSaver:StartMovie(false, dir, fn, fps, Quality, sizeX, sizeY)
      else
        local x = nx_int(form.begin_x.Text)
        local y = nx_int(form.begin_y.Text)
        local w = nx_int(form.end_x.Text) - x
        local h = nx_int(form.end_y.Text) - y
        res = MovieSaver:StartMovie(true, dir, fn, fps, Quality, sizeX, sizeY, x, y, w, h)
      end
      if not res[1] then
        ShowTipDialog(util_text("ui_movie_faile"))
      end
    else
      MovieSaver:Stop()
      nx_gen_event(form, "MovieSaver", "save")
    end
  elseif not form.groupbox_1.Visible and form.groupbox_2.Visible and form.groupbox_3.Visible then
    local game_config_info = nx_value("game_config_info")
    if 0 >= game_config_info.story_record then
      util_set_property_key(game_config_info, "story_record", 1)
      nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
    end
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      local text = gui.TextManager:GetText("sys_movie_save")
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      end
    end
  end
  form:Close()
end
function can_movie(form)
  local dir = form.dir.Text
  if nx_ws_length(nx_widestr(dir)) <= 0 or not nx_function("ext_is_exist_directory", nx_string(dir)) then
    ShowTipDialog(util_text("ui_movie_lujing_clue"))
    return false
  end
  local fps = nx_int(form.fps.Text)
  if nx_int(FPS_MIN) > nx_int(fps) or nx_int(FPS_MAX) < nx_int(fps) then
    ShowTipDialog(util_text("ui_movie_zhenlv"))
    return false
  end
  local Quality = nx_int(form.combobox_quality.Text)
  if nx_int(Quality_Low) > nx_int(Quality) or nx_int(Quality_High) < nx_int(Quality) then
    ShowTipDialog(util_text("ui_movie_hmzl_clue"))
    return false
  end
  local res = form.combobox_size.Text
  if nx_ws_length(nx_widestr(res)) <= 0 then
    ShowTipDialog(util_text("ui_movie_fbl_clue"))
    return false
  end
  local sizeX, sizeY = get_resolution(form)
  if nx_int(0) >= nx_int(sizeX) or nx_int(0) >= nx_int(sizeY) then
    ShowTipDialog(util_text("ui_movie_fbl_clue"))
    return false
  end
  return true
end
function cancel_btn_click(self)
  local form = self.ParentForm
  local MovieSaver = nx_value("MovieSaverModule")
  if not nx_is_valid(MovieSaver) then
    form:Close()
    return
  end
  if form.groupbox_1.Visible and not form.groupbox_2.Visible and not form.groupbox_3.Visible and MovieSaver:IsRecording() then
    MovieSaver:Stop()
    nx_gen_event(form, "MovieSaver", "save")
  end
  form:Close()
end
function fresh_bar_pos(pos)
  local form = nx_value("form_stage_main\\form_camera\\form_movie_save")
  form.bar.Value = pos
end
function get_resolution(form, resolution)
  local res
  if resolution ~= nil then
    res = resolution
  else
    res = form.combobox_size.Text
  end
  if nx_string(RESOLUTION_0) == nx_string(res) then
    return 320, 240
  elseif nx_string(RESOLUTION_1) == nx_string(res) then
    return 640, 480
  elseif nx_string(RESOLUTION_2) == nx_string(res) then
    return 800, 600
  elseif nx_string(RESOLUTION_3) == nx_string(res) then
    return 1024, 768
  elseif nx_string(RESOLUTION_4) == nx_string(res) then
    return 1280, 1024
  elseif nx_string(RESOLUTION_5) == nx_string(res) then
    return 1400, 1050
  elseif nx_string(RESOLUTION_6) == nx_string(res) then
    return 1600, 1200
  elseif nx_string(RESOLUTION_7) == nx_string(res) then
    return 2048, 1536
  end
  return 800, 600
end
function on_rbtn_checked_changed(self)
  local rbtn_name = self.Name
  local Checked = self.Checked
  if nx_string(rbtn_name) == nx_string("rbtn_1") and Checked == true then
    util_show_form("form_stage_main\\form_camera\\form_movie_cap_rect", true)
  elseif nx_string(rbtn_name) == nx_string("rbtn_2") and Checked == true then
    util_show_form("form_stage_main\\form_camera\\form_movie_cap_rect", false)
  end
end
function init_movie_ui(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 - 100
  form.Top = (gui.Height - form.Height) / 2 - 50
  form.combobox_size.DropListBox:AddString(nx_widestr(RESOLUTION_0))
  form.combobox_size.DropListBox:AddString(nx_widestr(RESOLUTION_1))
  form.combobox_size.DropListBox:AddString(nx_widestr(RESOLUTION_2))
  form.combobox_size.DropListBox:AddString(nx_widestr(RESOLUTION_3))
  form.combobox_size.DropListBox:AddString(nx_widestr(RESOLUTION_4))
  form.combobox_size.DropListBox:AddString(nx_widestr(RESOLUTION_5))
  form.combobox_size.DropListBox:AddString(nx_widestr(RESOLUTION_6))
  form.combobox_size.DropListBox:AddString(nx_widestr(RESOLUTION_7))
  form.combobox_quality.DropListBox:AddString(nx_widestr(Quality_Low))
  form.combobox_quality.DropListBox:AddString(nx_widestr(Quality_Mid))
  form.combobox_quality.DropListBox:AddString(nx_widestr(Quality_High))
  form.fps.Text = nx_widestr(MOVIE_FPS)
  form.combobox_quality.Text = nx_widestr(MOVIE_QUALITY)
  form.combobox_size.Text = nx_widestr(RESOLUTION_2)
  form.dir.Text = nx_widestr(Video_Path)
  form.filename = nx_widestr(DEFAULT_DIR)
  form.begin_x.Text = nx_widestr(DEFAULT_X)
  form.begin_y.Text = nx_widestr(DEFAULT_Y)
  form.end_x.Text = nx_widestr(DEFAULT_W)
  form.end_y.Text = nx_widestr(DEFAULT_H)
  local MovieSaver = nx_value("MovieSaverModule")
  if not nx_is_valid(MovieSaver) then
    return
  end
  if form.groupbox_1.Visible and not form.groupbox_2.Visible and not form.groupbox_3.Visible then
    if not MovieSaver:IsRecording() then
      form.btn_video.Text = nx_widestr(util_text("ui_movie_12"))
    else
      form.btn_video.Text = nx_widestr(util_text("ui_movie_13"))
    end
  end
end
function load_moive_config(form)
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    Video_config_Succeed = false
    return
  end
  ini.FileName = "system_set.ini"
  if not ini:LoadFromFile() then
    Video_config_Succeed = false
    nx_destroy(ini)
    return
  end
  if not ini:FindSection("MovieSaver") then
    Video_config_Succeed = false
    return
  end
  Video_Path = ini:ReadString("MovieSaver", "Video_Path", nx_string(DEFAULT_DIR))
  Video_Resolution = ini:ReadString("MovieSaver", "Resolution", nx_string(RESOLUTION_2))
  Video_fps = ini:ReadInteger("MovieSaver", "Fps", MOVIE_FPS)
  Video_Quality = ini:ReadInteger("MovieSaver", "Quality", MOVIE_QUALITY)
  Video_config_Succeed = true
  nx_destroy(ini)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(Video_Resolution) == "" then
    Video_Resolution = RESOLUTION_2
  end
  if nx_int(FPS_MIN) > nx_int(Video_fps) or nx_int(FPS_MAX) < nx_int(Video_fps) then
    Video_fps = MOVIE_FPS
  end
  if nx_int(Quality_Low) > nx_int(Video_Quality) or nx_int(Quality_High) < nx_int(Video_Quality) then
    Video_Quality = Quality_Mid
  end
  if nx_string(Video_Path) == "" then
    Video_Path = DEFAULT_DIR
  end
  form.fps.Text = nx_widestr(nx_int(Video_fps))
  form.combobox_quality.Text = nx_widestr(nx_int(Video_Quality))
  form.combobox_size.Text = nx_widestr(Video_Resolution)
  form.dir.Text = nx_widestr(Video_Path)
end
function Save_movie_config(bNeedSave)
  if not Video_config_Succeed and not bNeedSave then
    return
  end
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = "system_set.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  ini:WriteString("MovieSaver", "Video_Path", nx_string(Video_Path))
  ini:WriteString("MovieSaver", "Fps", nx_string(Video_fps))
  ini:WriteString("MovieSaver", "Quality", nx_string(Video_Quality))
  ini:WriteString("MovieSaver", "Resolution", nx_string(Video_Resolution))
  ini:SaveToFile()
  nx_destroy(ini)
end
function on_btn_browse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_file\\form_filepath", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.path = Video_Path
  dialog:ShowModal()
  local res, filepath = nx_wait_event(100000000, dialog, "filepath_return")
  if res == "cancel" then
    return 0
  end
  form.dir.Text = nx_widestr(filepath)
  Video_Path = filepath
  return 1
end
function on_btn_default_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.fps.Text = nx_widestr(nx_int(MOVIE_FPS))
  form.combobox_quality.Text = nx_widestr(nx_int(MOVIE_QUALITY))
  form.combobox_size.Text = nx_widestr(RESOLUTION_2)
  form.dir.Text = nx_widestr(DEFAULT_DIR)
end
function ShowMovieForm()
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_movie_save", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local res, filepath = nx_wait_event(100000000, dialog, "MovieSaver")
  if res == "cancel" then
    return 0
  end
end
function ShowTipDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function on_btn_video_get_capture(btn)
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_movie_tip")), btn.AbsLeft + 5, btn.AbsTop + 5, 0, btn.ParentForm)
end
function on_btn_video_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_btn_select_story_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_movie_select", true)
  local cloneid
  local form = btn.ParentForm
  if nx_is_valid(form) and nx_find_custom(form, "cloneid") then
    cloneid = form.cloneid
  end
  if nx_find_custom(dialog, "cloneid") then
    dialog.cloneid = cloneid
  end
  util_show_form("form_stage_main\\form_camera\\form_movie_select", true)
end
function on_btn_story_review_click(btn)
  local default_path = nx_value("default_path")
  local dialog = nx_execute("form_common\\form_open_file", "util_open_file", "*.avi", default_path)
  local result, file_path, file_name = nx_wait_event(100000000, dialog, "open_file_return")
  if nil ~= file_name and "" ~= file_name then
    local path = string.sub(file_path, 1, -(string.len(file_name) + 1))
    nx_set_value("default_path", path)
  end
  if "ok" == result then
    nx_execute("form_stage_main\\form_camera\\form_movie_play", "movie_play", file_path)
  end
end
function clone_story_begin_record(fn)
  local MovieSaver = nx_value("MovieSaverModule")
  if nx_is_valid(MovieSaver) then
    if MovieSaver:IsRecording() then
      MovieSaver:Stop()
    end
    local ini = nx_create("IniDocument")
    if not nx_is_valid(ini) then
      return
    end
    ini.FileName = "system_set.ini"
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return
    end
    if not ini:FindSection("MovieSaver") then
      return
    end
    local dir = ini:ReadString("MovieSaver", "Video_Path", nx_string(DEFAULT_DIR))
    local fps = ini:ReadInteger("MovieSaver", "Fps", MOVIE_FPS)
    local Quality = ini:ReadInteger("MovieSaver", "Quality", MOVIE_QUALITY)
    local resolution = ini:ReadString("MovieSaver", "Resolution", nx_string(RESOLUTION_2))
    nx_destroy(ini)
    if nx_string(dir) == "" then
      dir = DEFAULT_DIR
    end
    if nx_int(FPS_MIN) > nx_int(fps) or nx_int(FPS_MAX) < nx_int(fps) then
      fps = nx_int(MOVIE_FPS)
    end
    if nx_int(Quality_Low) > nx_int(Quality) or nx_int(Quality_High) < nx_int(Quality) then
      Quality = nx_int(Quality_Mid)
    end
    if nx_string(resolution) == "" then
      resolution = RESOLUTION_2
    end
    local sizeX, sizeY = get_resolution(form, resolution)
    local res = MovieSaver:StartMovie(false, nx_widestr(dir), nx_widestr(fn), fps, Quality, sizeX, sizeY)
    if not res[1] then
      ShowTipDialog(util_text("ui_movie_faile"))
    end
  end
end
function clone_story_begin_record_in_scenario()
  local game_config_info = nx_value("game_config_info")
  if 1 <= game_config_info.story_record then
    local fn = nx_widestr("movie")
    local form_movie_new = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_movie_new", false, false)
    if nx_is_valid(form_movie_new) then
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        fn = gui.TextManager:GetText(form_movie_new.movie_name_ui)
      end
      local result = false
      local ini = nx_create("IniDocument")
      ini.FileName = "story_record.ini"
      if ini:LoadFromFile() then
        local count = ini:GetSectionCount()
        for i = 1, count do
          if ini:FindSection(nx_string(i)) then
            local id = ini:ReadInteger(nx_string(i), "ID", 0)
            if nx_string(form_movie_new.movie_number) == nx_string(id) then
              local state = ini:ReadInteger(nx_string(i), "State", 0)
              if 1 <= state then
                ini:WriteInteger(nx_string(i), "State", 0)
                ini:SaveToFile()
                result = true
                break
              end
            end
          end
        end
      end
      nx_destroy(ini)
      if result then
        clone_story_begin_record(fn)
      end
    end
  end
end
function clone_story_end_record()
  local MovieSaver = nx_value("MovieSaverModule")
  if nx_is_valid(MovieSaver) and MovieSaver:IsRecording() then
    MovieSaver:Stop()
  end
end
