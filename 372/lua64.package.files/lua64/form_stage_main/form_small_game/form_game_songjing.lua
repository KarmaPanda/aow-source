require("util_functions")
require("util_gui")
local FORM_SONG_JING = "form_stage_main\\form_small_game\\form_game_songjing"
local CLIENT_SUBMSG_SJ_SCORE = 1
local CLIENT_SUBMSG_SJ_END = 2
local SERVER_SUBMSG_SJ_BEGIN = 1
local SERVER_SUBMSG_SJ_END = 2
local SERVER_SUBMSG_SJ_JOIN_SUCCEED = 3
local SJ_OFFSET_TIME = 100
function on_server_msg(sub_msg, ...)
  if sub_msg == nil then
    return
  end
  if nx_int(sub_msg) == nx_int(SERVER_SUBMSG_SJ_JOIN_SUCCEED) then
    local form = nx_value(FORM_SONG_JING)
    if not nx_is_valid(form) then
      form = util_get_form(FORM_SONG_JING, true, false)
    end
    form:ShowModal()
  end
  if nx_int(sub_msg) == nx_int(SERVER_SUBMSG_SJ_BEGIN) then
    local form = nx_value(FORM_SONG_JING)
    if not nx_is_valid(form) then
      form = util_get_form(FORM_SONG_JING, true, false)
      if not nx_is_valid(form) then
        return
      end
      form.musicid = arg[1]
      form:ShowModal()
    else
      form.musicid = arg[1]
      start_game(form)
    end
  end
  if nx_int(sub_msg) == nx_int(SERVER_SUBMSG_SJ_END) then
    local form = nx_value(FORM_SONG_JING)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  nx_execute("gui", "gui_close_allsystem_form", 2)
  change_form_size()
  local SongJingGame = nx_value("SongJingGame")
  if not nx_is_valid(SongJingGame) then
    SongJingGame = nx_create("SongJingGame")
    nx_set_value("SongJingGame", SongJingGame)
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  form.sound_volume = game_config.sound_volume
  form.area_music_volume = game_config.area_music_volume
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:SetAllVolume(0)
  end
  if nx_find_custom(game_visual, "area_music") and nx_is_valid(game_visual.area_music) then
    game_visual.area_music.Volume = 0
  end
  local form_offline = nx_value("form_stage_main\\form_offline\\form_offline")
  if nx_is_valid(form_offline) then
    form_offline:Close()
  end
end
function start_game(form)
  if not nx_is_valid(form) then
    return
  end
  local SongJingGame = nx_value("SongJingGame")
  if not nx_is_valid(SongJingGame) then
    return
  end
  if not SongJingGame:StartGame(form.musicid) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_songjing_08"), 2)
    end
    nx_execute("custom_sender", "custom_song_jing_request", CLIENT_SUBMSG_SJ_END)
    form:Close()
    return
  end
  local music_title = SongJingGame:GetMusicTitle()
  form.lbl_title.Text = util_text(nx_string(music_title))
end
function on_main_form_close(form)
  nx_execute("gui", "gui_open_closedsystem_form")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) and nx_find_custom(form, "sound_volume") then
    voice_manager:SetAllVolume(form.sound_volume)
  end
  if nx_find_custom(game_visual, "area_music") and nx_find_custom(form, "area_music_volume") and nx_is_valid(game_visual.area_music) then
    game_visual.area_music.Volume = form.area_music_volume
  end
  local SongJingGame = nx_value("SongJingGame")
  if nx_is_valid(SongJingGame) then
    nx_destroy(SongJingGame)
  end
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  nx_execute("custom_sender", "custom_song_jing_request", CLIENT_SUBMSG_SJ_END)
  util_show_form(FORM_SONG_JING, false)
  local form = nx_value(FORM_SONG_JING)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function change_form_size()
  local form = nx_value(FORM_SONG_JING)
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    form.Left = 0
    form.Top = 0
    form.Width = gui.Desktop.Width
    form.Height = gui.Desktop.Height
    form.lbl_1.Width = form.Width
    form.lbl_3.Width = form.Width
    form.lbl_4.Width = form.Width
  end
end
function on_btn_offset_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  local SongJingGame = nx_value("SongJingGame")
  if not nx_is_valid(SongJingGame) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  local offset = 0
  ini.FileName = account .. "\\form_main.ini"
  if ini:LoadFromFile() then
    offset = ini:ReadInteger("minigame_song_jing", "offset", 0)
  end
  if btn.DataSource == "forward" then
    offset = offset + SJ_OFFSET_TIME
  elseif btn.DataSource == "backward" then
    offset = offset - SJ_OFFSET_TIME
  else
    nx_destroy(ini)
    return
  end
  if nx_int(offset) > nx_int(2000) then
    offset = 2000
  elseif nx_int(offset) < nx_int(-2000) then
    offset = -2000
  end
  show_offset_msg(offset)
  SongJingGame:SetLyricOffset(nx_int(offset))
  ini:WriteString("minigame_song_jing", "offset", nx_string(offset))
  ini:SaveToFile()
  nx_destroy(ini)
end
function show_offset_msg(offset)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local offset_sec = offset / 1000
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if offset < 0 then
    offset_sec = offset_sec * -1
    gui.TextManager:Format_SetIDName("sys_songjing_11")
  elseif 0 <= offset then
    gui.TextManager:Format_SetIDName("sys_songjing_10")
  end
  gui.TextManager:Format_AddParam(nx_float(offset_sec))
  local str = gui.TextManager:Format_GetText()
  SystemCenterInfo:ShowSystemCenterInfo(str, 2)
end
function is_in_minigame_song_jing()
  local SongJingForm = nx_value("form_stage_main\\form_small_game\\form_game_songjing")
  if nx_is_valid(SongJingForm) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_songjing_12"), 2)
    end
    return true
  end
  return false
end
