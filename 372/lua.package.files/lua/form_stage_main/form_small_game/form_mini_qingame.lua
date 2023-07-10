require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("util_functions")
require("gui")
local key = {
  "",
  "",
  "",
  ""
}
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  form.dialog = nil
  form.gamestart = false
  game_init(form)
  change_form_size()
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    form.t_music = scene_music_play_manager:GetGameMusicName()
    scene_music_play_manager:StopGameMusic(0)
  end
  if form.gamestart then
    return
  end
  nx_execute("form_stage_main\\form_small_game\\form_qingame", "play_music", form.t_musicid, form.t_starttime, false, false)
  local QinGame = nx_value("QinGame")
  if not nx_is_valid(QinGame) then
    return 0
  end
  if not QinGame:RegistMaterSchedule() then
    return 0
  end
  form.groupbox_life.Visible = true
  form.groupbox_pbar.Visible = true
  form.gamestart = true
  show_hide_skill_form(false)
end
function on_main_form_close(form)
  form.dialog = nil
  nx_execute("form_stage_main\\form_small_game\\form_qingame", "play_music", form.t_music, 0, true, true)
  nx_destroy(form)
  local skill_form = nx_value("form_stage_main\\form_small_game\\form_mini_qingame_skill")
  if nx_is_valid(skill_form) then
    skill_form:Close()
  end
  show_hide_skill_form(true)
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function on_btn_help_click(btn)
  nx_execute("form_stage_main\\form_help\\form_help_AllGui_New", "init_help_form", "ini\\ui\\life\\help_qs.ini")
end
function game_init(form)
  local QinGame = nx_value("QinGame")
  if not nx_is_valid(QinGame) then
    return 0
  end
  GameInfo = QinGame:GetGameInfo()
  if GameInfo[1] ~= true then
    return 0
  end
  local gui = nx_value("gui")
  form.t_life = GameInfo[2]
  set_life_backimage(form.t_life)
  form.groupbox_life.Visible = false
  local porduct_item = GameInfo[4]
  form.lbl_title.Text = gui.TextManager:GetFormatText(porduct_item)
  form.mltbox_desc:AddHtmlText(gui.TextManager:GetFormatText("desc_" .. porduct_item), nx_int(-1))
  form.t_musicid = GameInfo[5]
  form.t_victory = GameInfo[6]
  form.t_lost = GameInfo[7]
  form.t_aolerance = GameInfo[8]
  form.t_starttime = GameInfo[9]
  form.t_speed = GameInfo[10] * 2
  set_move_backimage(1, GameInfo[19], GameInfo[11], GameInfo[12])
  set_move_backimage(2, GameInfo[19], GameInfo[13], GameInfo[14])
  set_move_backimage(3, GameInfo[19], GameInfo[15], GameInfo[16])
  set_move_backimage(4, GameInfo[19], GameInfo[17], GameInfo[18])
  form.pbar_qingame.Value = 0
  form.groupbox_pbar.Visible = false
  form.lbl_1_special.Visible = false
  form.lbl_2_special.Visible = false
  form.lbl_3_special.Visible = false
  form.lbl_4_special.Visible = false
  local skill_pos = nx_int(GameInfo[20])
  if skill_pos <= nx_int(0) then
    form.lbl_flag.Visible = false
  else
    form.lbl_flag.Visible = true
    form.lbl_flag.Top = (form.pbar_qingame.Height - 20) / 100 * skill_pos + form.pbar_qingame.Top + 10 - form.lbl_flag.Height / 2
  end
  return 1
end
function open_qingame_skill_form(qinpuid, key1, key2, key3, key4)
  key[1] = nx_string(key1)
  key[2] = nx_string(key2)
  key[3] = nx_string(key3)
  key[4] = nx_string(key4)
end
function set_move_backimage(index, path, key, bDirectoryIsRight)
  local group = get_step_group(index)
  if not nx_is_valid(group) then
    return
  end
  if path == "" then
    group.Visible = false
  end
  for i = 0, 10 do
    local lbl = get_move_lbl(group, index, i)
    if not nx_is_valid(lbl) then
      break
    end
    lbl.bDirectoryIsRight = bDirectoryIsRight
    lbl.BackImage = path
    set_dot_init(index, lbl)
  end
  local lbl_backKey = get_move_lbl(group, index, "back_key")
  if not nx_is_valid(lbl_backKey) then
    return
  end
  lbl_backKey.BackImage = "gui\\mainform\\smallgame\\qin_game\\mini\\" .. nx_string(key) .. ".png"
  if not bDirectoryIsRight then
    local lbl_backImage = get_move_lbl(group, index, "back_image")
    local lbl_special = get_move_lbl(group, index, "special")
    if not nx_is_valid(lbl_special) or not nx_is_valid(lbl_backImage) then
      return
    end
    lbl_backImage.Left = 55
    lbl_special.Left = 42
    lbl_backKey.Left = 55
  end
end
function get_step_group(index)
  local form = get_form()
  if not nx_is_valid(form) then
    return nx_null()
  end
  if index == 1 then
    return form.groupbox_1
  elseif index == 2 then
    return form.groupbox_2
  elseif index == 3 then
    return form.groupbox_3
  elseif index == 4 then
    return form.groupbox_4
  end
  return nx_null()
end
function get_move_lbl(group, groupindex, lblindex)
  local name = "lbl_" .. nx_string(groupindex) .. "_" .. nx_string(lblindex)
  local lbl = group:Find(name)
  if nx_is_valid(lbl) then
    return lbl
  end
  return nx_null()
end
function set_move_x_pos(lbltype, groupindex, lblindex)
  local group = get_step_group(groupindex)
  if not nx_is_valid(group) then
    return
  end
  local lbl = get_move_lbl(group, groupindex, lblindex)
  local lbl_backImage = get_move_lbl(group, groupindex, "back_image")
  if not nx_is_valid(lbl) or not nx_is_valid(lbl_backImage) then
    return
  end
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  lbl.Visible = true
  if lbl.bDirectoryIsRight then
    lbl.Left = lbl.Left + form.t_speed
  else
    lbl.Left = lbl.Left - form.t_speed
  end
  local back_l = lbl_backImage.Left + 3 - form.t_aolerance
  local back_r = lbl_backImage.Left + lbl_backImage.Width - 3 + form.t_aolerance
  local lbl__l = lbl.Left
  local lbl__r = lbl.Left + lbl.Width
  if back_l <= lbl__r and back_r >= lbl__l then
    local QinGame = nx_value("QinGame")
    if not nx_is_valid(QinGame) then
      return 0
    end
    QinGame:RangeWarn(1, groupindex, lblindex)
    shortcut(key[groupindex])
  elseif lbl.bDirectoryIsRight and 373 < lbl__l or not lbl.bDirectoryIsRight and lbl__r < 27 then
    set_dot_init(groupindex, lbl)
    local QinGame = nx_value("QinGame")
    if not nx_is_valid(QinGame) then
      return 0
    end
    QinGame:RangeWarn(-2, groupindex, lblindex)
  elseif lbl.bDirectoryIsRight and back_r < lbl__l or not lbl.bDirectoryIsRight and back_l > lbl__r then
    local QinGame = nx_value("QinGame")
    if not nx_is_valid(QinGame) then
      return 0
    end
    QinGame:RangeWarn(-1, groupindex, lblindex)
  end
end
function set_dot_init(index, lbl)
  lbl.Visible = false
  lbl.Top = -2
  if lbl.bDirectoryIsRight then
    lbl.Left = 0
  else
    lbl.Left = 359
  end
end
function press_key_down(groupindex)
  nx_execute("form_stage_main\\form_small_game\\form_qingame", "play_sound", "sound_qingame", "snd\\action\\minigame\\qinshi\\7112_1.wav")
  local group = get_step_group(groupindex)
  if not nx_is_valid(group) then
    return
  end
  local lbl_backImage = get_move_lbl(group, groupindex, "back_image")
  if not nx_is_valid(lbl_backImage) then
    return
  end
  lbl_backImage.BackImage = string.gsub(lbl_backImage.BackImage, "out.png", "down.png")
  nx_execute("form_stage_main\\form_small_game\\form_mini_qingame", "press_key_down_end", lbl_backImage)
end
function press_key_down_end(lbl_backImage)
  nx_pause(1)
  if nx_is_valid(lbl_backImage) then
    lbl_backImage.BackImage = string.gsub(lbl_backImage.BackImage, "down.png", "out.png")
  end
end
function play_game_cartoon(groupindex, lblindex)
  local group = get_step_group(groupindex)
  if not nx_is_valid(group) then
    return
  end
  local lbl = get_move_lbl(group, groupindex, lblindex)
  local lbl_flag = get_move_lbl(group, groupindex, "special")
  if not nx_is_valid(lbl) or not nx_is_valid(lbl_flag) then
    return
  end
  set_dot_init(groupindex, lbl)
  lbl_flag.Visible = true
  lbl_flag:Stop()
  lbl_flag:Play()
end
function change_form_size()
  local self = nx_value("form_stage_main\\form_small_game\\form_mini_qingame")
  if nx_is_valid(self) then
    local gui = nx_value("gui")
    self.AbsLeft = gui.Width - self.Width
    self.AbsTop = gui.Height - self.Height
  end
end
function get_form()
  local form = nx_value("form_stage_main\\form_small_game\\form_mini_qingame")
  if not nx_is_valid(form) then
    nx_execute("form_stage_main\\form_small_game\\form_qingame", "CloseGame")
    return nx_null()
  end
  return form
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function close_game_by_esc()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_small_game\\form_mini_qingame", "show_close_dialog", form)
end
function direct_close_form()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function show_close_dialog(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_smallgametc"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  form.dialog = dialog
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("form_stage_main\\form_small_game\\form_qingame", "CloseGame")
  end
end
function show_game_result(result)
  for i = 1, table.getn(key) do
    key[i] = ""
  end
  local form = nx_value("form_stage_main\\form_small_game\\form_mini_qingame")
  if not nx_is_valid(form) then
    return
  end
  if not form.gamestart then
    form:Close()
    return
  end
  if nx_is_valid(form.dialog) then
    form.dialog:Close()
    form.dialog = nil
  end
  form.gamestart = false
  form.groupbox_qingame.Visible = false
  if 0 < result then
    nx_execute("form_stage_main\\form_small_game\\form_qingame", "play_music", "life_game_win", 0, false, false)
  else
    nx_execute("form_stage_main\\form_small_game\\form_qingame", "play_music", "life_game_lose", 0, false, false)
  end
  nx_execute("form_stage_main\\form_small_game\\form_mini_qingame", "show_game_result_end", form)
end
function show_game_result_end(form)
  nx_pause(2)
  if nx_is_valid(form) then
    form:Close()
  end
end
function reduce_life()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  if form.t_life > 0 then
    form.t_life = form.t_life - 1
    set_life_backimage(form.t_life)
  end
end
function shortcut(key)
  if key == "" then
    return
  end
  if key == "Space" then
    return
  end
  local QinGame = nx_value("QinGame")
  if not nx_is_valid(QinGame) then
    return 0
  end
  QinGame:SetShortCut(key)
end
function set_pbar_value(value)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form.pbar_qingame.Value = value
end
function set_life_backimage(life)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local group = form.groupbox_life
  for i = 1, life do
    local name = "lbl_life_" .. nx_string(6 - i)
    local lbl = group:Find(name)
    if not nx_is_valid(lbl) then
      break
    end
    lbl.BackImage = "gui\\mainform\\smallgame\\qin_game\\mini\\life_" .. nx_string(life) .. ".png"
  end
  for i = 1, 5 - life do
    local name = "lbl_life_" .. nx_string(i)
    local lbl = group:Find(name)
    if not nx_is_valid(lbl) then
      break
    end
    lbl.BackImage = "gui\\mainform\\smallgame\\qin_game\\mini\\life_0.png"
  end
end
function get_control_x_pos(obj)
  if not nx_is_valid(obj) then
    return 0
  end
  return obj.Left + obj.Width / 2
end
function show_hide_skill_form(show)
  local shortcut_form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_form) then
    return
  end
  shortcut_form.Visible = show
  if true == show then
    local itemskill_shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
    if nx_is_valid(itemskill_shortcut_grid) and itemskill_shortcut_grid.Visible == true then
      shortcut_form.Visible = false
    end
    local buff_common_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_buff_common")
    if nx_is_valid(buff_common_grid) and buff_common_grid.Visible == true and buff_common_grid.isclose_shortgrid == 0 then
      shortcut_form.Visible = false
    end
  end
end
function set_progress_bar_flag(height)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local skill_pos = nx_int(height)
  if skill_pos <= nx_int(0) then
    form.lbl_flag.Visible = false
  else
    form.lbl_flag.Visible = true
    form.lbl_flag.Top = (form.pbar_qingame.Height - 20) / 100 * skill_pos + form.pbar_qingame.Top + 10 - form.lbl_flag.Height / 2
  end
end
