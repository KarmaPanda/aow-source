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
  local FindpicGame = nx_value("FindpicGame")
  GameInfo = FindpicGame:GetGameInfo()
  local res = GameInfo[1]
  if res ~= true then
    return 0
  end
  game_chance = GameInfo[2]
  speed = GameInfo[3]
  picrow = GameInfo[4]
  piccol = GameInfo[5]
  preparetime = GameInfo[6]
  console_log("picrow:" .. nx_string(picrow))
  console_log("piccol:" .. nx_string(piccol))
  local gui = nx_value("gui")
  form.pbar_show.ProgressImage = GameInfo[7]
  form.pbar_show.Value = 0
  form.pbar_show.AutoSize = true
  form.lbl_help.Visible = true
  form.mltbox_help.Visible = true
  form.groupbox_life.Visible = false
  form.lbl_tips.Visible = false
  GameStart = false
  CanOperate = false
  return 1
end
function on_btn_startgame_click(self)
  if GameStart == false then
    local form = self.Parent
    local gui = nx_value("gui")
    for i = 0, picrow - 1 do
      for j = 0, piccol - 1 do
        local button = gui:Create("Button")
        button.AutoSize = true
        local index = i * picrow + j
        button.Name = nx_string(index)
        button.index = index
        button.BackImage = GameInfo[8 + index]
        nx_bind_script(button, nx_current())
        nx_callback(button, "on_click", "on_choose_click")
        local top = 60 + i * (button.Height + 10)
        local left = 32 + j * (button.Width + 10)
        button.Left = left
        button.Top = top
        form:Add(button)
      end
    end
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq011_01.png"
    for i = 1, 5 do
      local lblname = "lbl_life" .. i
      local lbl = form.groupbox_life:Find(lblname)
      if nx_is_valid(lbl) then
        lbl.BackImage = ""
      end
    end
    for i = 1, game_chance do
      local lblname = "lbl_life" .. i
      local lbl = form.groupbox_life:Find(lblname)
      if nx_is_valid(lbl) then
        lbl.BackImage = "gui\\special\\life\\exp.png"
      end
    end
    form.groupbox_life.Visible = true
    form.lbl_tips.Visible = true
    local timer = nx_value(GAME_TIMER)
    timer:Register(preparetime * 1000, 1, nx_current(), "on_update__prepare_time", form, speed, -1)
    GameStart = true
    self.Visible = false
    form.lbl_help.Visible = false
    form.mltbox_help.Visible = false
  end
end
function on_update__prepare_time(form, speed)
  for i = 0, picrow - 1 do
    for j = 0, piccol - 1 do
      local index = i * picrow + j
      local button = form:Find(nx_string(index))
      if nx_is_valid(button) then
        button.BackImage = "yhg_findpic01"
      end
    end
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(700, 1, nx_current(), "on_prepare_show", form, speed, -1)
end
function on_prepare_show(form, speed)
  form.pbar_show.Visible = true
  for i = 0, picrow - 1 do
    for j = 0, piccol - 1 do
      local index = i * picrow + j
      local button = form:Find(nx_string(index))
      if nx_is_valid(button) then
        button.BackImage = "gui\\animations\\findpic\\yhg_pic005.png"
      end
    end
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(300, -1, nx_current(), "on_update_time", form, speed, -1)
  GameStart = true
  CanOperate = true
end
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  game_init(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_game_form()
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_findpic")
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
    local FindpicGame = nx_value("FindpicGame")
    FindpicGame:SendGameResult(-1)
    GameStart = false
    FindpicGame:Close()
  end
end
function on_update_time(form, speed)
  form.pbar_show.Value = form.pbar_show.Value + math.floor(speed / 5)
  if form.pbar_show.Value >= 100 then
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq047_01.png"
    gamefailed(form)
  end
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
function gamefailed(form)
  stop_timer(form)
  form.lbl_tips.BackImage = "gui\\animations\\face\\bq061_09.png"
  local FindpicGame = nx_value("FindpicGame")
  FindpicGame:SendGameResult(-1)
  GameStart = false
  showResult(form, 0)
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
  timer:Register(2500, 1, nx_current(), "auto_close_form", form, 0, -1)
end
function auto_close_form(form, level)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "auto_close_form", form)
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
function on_choose_click(self)
  console_log("GameStart:" .. nx_string(GameStart))
  console_log("button.Name:" .. nx_string(false))
  if GameStart == false then
    return
  end
  if CanOperate == false then
    return
  end
  local form = self.Parent
  local index = self.index
  local temp1 = nx_string(GameInfo[8 + index])
  local temp2 = nx_string(form.pbar_show.ProgressImage)
  if temp1 == temp2 then
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq055_01.png"
    local FindpicGame = nx_value("FindpicGame")
    if FindpicGame:CheckGameIndex(nx_int(self.Name)) then
      stop_timer(form)
      showResult(form, 1)
      FindpicGame:SendGameResult(nx_int(self.Name))
      GameStart = false
    end
  else
    local lbl = form.groupbox_life:Find("lbl_life" .. game_chance)
    lbl.BackImage = "gui\\animations\\tip\\Hole.png"
    game_chance = game_chance - 1
    if game_chance <= 0 then
      gamefailed(form)
      game_chance = 0
      return
    end
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq061_03.png"
  end
  CanOperate = false
  local timer = nx_value(GAME_TIMER)
  self.BackImage = "yhg_findpic02"
  timer:Register(700, 1, nx_current(), "on_update_show_card_1", self, speed, -1)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
function on_update_show_card_1(button, speed)
  local index = button.index
  button.BackImage = GameInfo[8 + index]
  local timer = nx_value(GAME_TIMER)
  timer:Register(700, 1, nx_current(), "on_update_show_card_2", button, speed, -1)
end
function on_update_show_card_2(button, speed)
  button.BackImage = "yhg_findpic01"
  local timer = nx_value(GAME_TIMER)
  timer:Register(700, 1, nx_current(), "on_update_show_card_3", button, speed, -1)
end
function on_update_show_card_3(button, speed)
  button.BackImage = "gui\\animations\\findpic\\yhg_pic005.png"
  CanOperate = true
  local timer = nx_value(GAME_TIMER)
  timer:Register(300, -1, nx_current(), "on_update_time", button.ParentForm, speed, -1)
end
