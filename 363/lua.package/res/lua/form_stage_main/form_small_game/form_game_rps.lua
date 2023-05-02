require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
GameStart = false
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function game_init(form)
  local timer = nx_value(GAME_TIMER)
  form.lbl_computer_action.curpic = 0
  form.lbl_res.Text = nx_widestr("")
  timer:Register(100, -1, "form_stage_main\\form_small_game\\form_game_rps", "on_update_time", form, 1, -1)
  form.lbl_turn_info.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(0)
  return 1
end
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.CanChoice = true
  game_init(form)
  change_form_size()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rps")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_backImage.BlendAlpha = form.groupbox_backImage.BlendAlpha - delta
end
function close_game_form()
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_game_rps")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function show_close_dialog(form)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_smallgametc"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" and nx_is_valid(form) then
    local RockPaperScissorsGame = nx_value("RockPaperScissorsGame")
    RockPaperScissorsGame:SendGameLeave()
    GameStart = false
    RockPaperScissorsGame:Close()
  end
end
function on_update_time(form, speed)
  form.lbl_computer_action.curpic = form.lbl_computer_action.curpic + 1
  if form.lbl_computer_action.curpic > 3 then
    form.lbl_computer_action.curpic = 1
  end
  showcomputeraction(form, form.lbl_computer_action.curpic)
end
function change_form_size()
  local self = nx_value("form_stage_main\\form_small_game\\form_game_rps")
  if nx_is_valid(self) then
    local gui = nx_value("gui")
    self.AbsLeft = 0
    self.AbsTop = 0
    self.Width = gui.Width
    self.Height = gui.Height
    self.groupbox_backImage.Width = gui.Width
    self.groupbox_backImage.Height = gui.Height
    self.groupbox_back.AbsLeft = (gui.Width - self.groupbox_back.Width) / 2
    self.groupbox_back.AbsTop = (gui.Height - self.groupbox_back.Height) / 5 * 2
  end
end
function showcomputeraction(form, index)
  if index == 1 then
    form.lbl_computer_action.BackImage = "gui\\special\\caiquan\\2.png"
  elseif index == 2 then
    form.lbl_computer_action.BackImage = "gui\\special\\caiquan\\1.png"
  elseif index == 3 then
    form.lbl_computer_action.BackImage = "gui\\special\\caiquan\\3.png"
  end
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_rps", "on_update_time", form)
end
function showResult(form, res)
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  Label.AutoSize = true
  Label.Name = "lab_res"
  local filename = "snd\\action\\minigame\\forge\\7110_5.wav"
  if res == 1 then
    Label.BackImage = "gui\\language\\ChineseS\\minigame\\victory.png"
  else
    Label.BackImage = "gui\\language\\ChineseS\\minigame\\lost.png"
    filename = "snd\\action\\minigame\\forge\\7110_6.wav"
  end
  Label.AbsTop = (form.Height - Label.Height) / 2
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
  play_sound(filename)
  local timer = nx_value(GAME_TIMER)
  timer:Register(2500, -1, "form_stage_main\\form_small_game\\form_game_rps", "auto_close_form", form, 0, -1)
end
function auto_close_form(form, level)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_rps", "auto_close_form", form)
  close_game_form()
end
function play_sound(filename)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound("sound_qingame") then
    gui:AddSound("sound_qingame", nx_resource_path() .. filename)
  end
  gui:PlayingSound("sound_qingame")
end
function on_server_msg(...)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rps")
  local timer = nx_value(GAME_TIMER)
  local res = arg[1]
  local computerres = arg[2]
  local CurTurn = arg[3]
  local WinTurn = arg[4]
  form.lbl_computer_action.curpic = computerres
  showcomputeraction(form, computerres)
  form.lbl_turn_info.Text = nx_widestr(WinTurn) .. nx_widestr("/") .. nx_widestr(CurTurn)
  if CurTurn < 3 then
    timer:Register(3000, -1, "form_stage_main\\form_small_game\\form_game_rps", "on_show_turn_res", form, 1, -1)
  else
    showResult(form, 1)
  end
end
function on_show_turn_res(form, speed)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_rps", "on_show_turn_res", form)
  form.CanChoice = true
  form.lbl_computer_action.curpic = 0
  timer:Register(100, -1, "form_stage_main\\form_small_game\\form_game_rps", "on_update_time", form, 1, -1)
  form.lbl_res.Text = nx_widestr("")
end
function on_btn_Rock_click(btn)
  on_choose_click(btn, 1)
end
function on_btn_Scissors_click(btn)
  on_choose_click(btn, 2)
end
function on_btn_Paper_click(btn)
  on_choose_click(btn, 3)
end
function on_choose_click(btn, playerres)
  local form = btn.ParentForm
  if form.CanChoice == false then
    return
  end
  form.CanChoice = false
  stop_timer(form)
  local RockPaperScissorsGame = nx_value("RockPaperScissorsGame")
  RockPaperScissorsGame:SendPlayerChoiceMsg(playerres)
end
