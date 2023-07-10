require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
require("gui")
local level = 0
local game_chance = 3
local game_total_time = 1000
local game_time_now = 0
local action_range = 2
local currentAction = 0
local currentActionTime = 0
local GameStep = 1
local GamestepTimeIndex = 1
local GamestepDataIndex = 1
local GameStart = false
local GameTimeData = {}
local GameStepData = {}
local ActionImageData = {}
local ActionSoundlist = {}
local helptext = ""
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(form)
  return 1
end
function on_main_form_close(form)
  nx_execute("gui", "gui_open_closedsystem_form")
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  nx_destroy(form)
end
function close_game_form()
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_forgegame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
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
    local ForgeGame = nx_value("ForgeGame")
    ForgeGame:SendGameResult(0)
    GameStart = false
    ForgeGame:Close()
  end
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function on_btn_startgame_click(btn)
  if GameStart == false then
    local timer = nx_value(GAME_TIMER)
    local groupbox = btn.Parent
    local form = groupbox.Parent
    nx_execute(nx_current(), "on_update_time", form, level)
    timer:Register(200, -1, nx_current(), "on_update_time", form, level, -1)
    GameStart = true
    btn.Visible = false
    for i = 1, game_chance do
      local lblname = "lbllife_" .. i
      local lbl = groupbox:Find(lblname)
      lbl.BackImage = "gui\\mainform\\smallgame\\life_on.png"
      lbl.Visible = true
    end
  end
end
function game_init(form)
  GameTimeData = {}
  GameStepData = {}
  ActionImageData = {}
  ActionSoundlist = {}
  local ForgeGame = nx_value("ForgeGame")
  GameInfo = ForgeGame:GetGameInfo()
  local res = GameInfo[1]
  if res ~= true then
    return 0
  end
  local index = GameInfo[2]
  local gui = nx_value("gui")
  local file_name = "share\\Life\\ForgeGame.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string(index))
  if sec_index < 0 then
    sec_index = "0"
  else
  end
  level = sec_index
  game_chance = ini:ReadInteger(sec_index, "life", 3)
  game_total_time = ini:ReadInteger(sec_index, "time", 1) * 1000
  game_time_now = 0
  action_range = ini:ReadInteger(sec_index, "timerange", 1)
  local groupbox = form.groupbox_back
  form.lbl_progresstip.BackImage = ini:ReadString(sec_index, "processtipimage", "")
  form.lbl_ProgressBackImage.BackImage = ini:ReadString(sec_index, "processbackimage", "")
  form.pbar_forgegame.ProgressImage = ini:ReadString(sec_index, "processimage", "")
  victory = ini:ReadString(sec_index, "victory", "")
  lost = ini:ReadString(sec_index, "lost", "")
  helptext = ini:ReadString(sec_index, "helptext", "")
  for i = 1, 5 do
    local lblname = "lbllife_" .. i
    local lbl = groupbox:Find(lblname)
    lbl.BackImage = "gui\\mainform\\smallgame\\life_down.png"
    lbl.Visible = false
  end
  form.lbl_action.BackImage = ""
  ActionImageData = ini:GetItemValueList(sec_index, nx_string("actionimage"))
  ActionSoundlist = ini:GetItemValueList(sec_index, nx_string("actionsound"))
  local photo = ini:ReadString(sec_index, "curani", "")
  if photo ~= "" then
    local gui = nx_value("gui")
    gui.GameHand:SetHand("forgegame", photo, nx_string(jobid), photo, photo, "")
  end
  local action = ini:ReadString(sec_index, "action", "")
  local action_lst = util_split_string(action, ",")
  for i, buf in pairs(action_lst) do
    console_log("GamestepTimeIndex")
    local value = nx_int(buf)
    if nx_int(value) > nx_int(0) then
      local btnname = "btnAction_" .. i
      local button = groupbox:Find(btnname)
      button.Name = nx_string(value)
      if nx_int(value) <= nx_int(table.getn(ActionImageData)) then
        button.NormalImage = nx_string(ActionImageData[nx_number(value)]) .. "_out.png"
        button.FocusImage = nx_string(ActionImageData[nx_number(value)]) .. "_on.png"
        button.PushImage = nx_string(ActionImageData[nx_number(value)]) .. "_down.png"
      else
        button.Text = nx_widestr(value)
      end
      button.AutoSize = true
      nx_bind_script(button, nx_current(), "")
      nx_callback(button, "on_click", "on_choose_click")
    end
  end
  local steplist = ini:GetItemValueList(sec_index, nx_string("step"))
  for i, buf in pairs(steplist) do
    local stepData = util_split_string(buf, ",")
    GameTimeData[i] = stepData[1]
  end
  GameStep = nx_int(GameInfo[3])
  GamestepTimeIndex = 1
  GamestepDataIndex = 4
  currentAction = 0
  currentActionTime = 0
  baseleft = form.pbar_forgegame.Left
  basetop = form.pbar_forgegame.Top
  return 1
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_forgegame")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_backImage.BlendAlpha = form.groupbox_backImage.BlendAlpha - delta
end
function on_btn_help_click(self)
  groupbox = self.Parent
  local groupboxhelp = groupbox:Find("groupbox_help")
  if not nx_is_valid(groupboxhelp) then
    local gui = nx_value("gui")
    groupboxhelp = gui:Create("GroupBox")
    groupboxhelp.AutoSize = true
    groupboxhelp.Name = "groupbox_help"
    groupboxhelp.BackImage = "gui\\language\\ChineseS\\minigame\\gamehelp.png"
    groupboxhelp.AbsLeft = (groupbox.Width - groupboxhelp.Width) / 2
    groupboxhelp.AbsTop = (groupbox.Height - groupboxhelp.Height) / 2
    local button = gui:Create("Button")
    local closebutton = groupbox:Find("btn_close")
    button.AutoSize = true
    button.NormalImage = closebutton.NormalImage
    button.FocusImage = closebutton.FocusImage
    button.PushImage = closebutton.PushImage
    button.AbsLeft = groupboxhelp.Width - button.Width - 30
    button.AbsTop = 30
    nx_bind_script(button, nx_current(), "")
    nx_callback(button, "on_click", "on_close_helpbox")
    local multitextbox = gui:Create("MultiTextBox")
    multitextbox.AutoSize = true
    multitextbox.AbsLeft = 40
    multitextbox.AbsTop = button.AbsTop + button.Height + 30
    multitextbox.Width = groupboxhelp.Width - 80
    multitextbox.Height = groupboxhelp.Height - 70 - button.Height
    multitextbox.MouseInBarColor = "0,0,0,0"
    multitextbox.ViewRect = nx_string("0,0," .. nx_string(multitextbox.Width) .. "," .. nx_string(multitextbox.Height))
    multitextbox.BackColor = "0,0,0,0"
    multitextbox.LineColor = "0,0,0,0"
    multitextbox.SelectBarColor = "0,0,0,0"
    multitextbox.TextColor = "255,0,0,0"
    multitextbox.HtmlText = nx_widestr(helptext)
    groupboxhelp:Add(multitextbox)
    groupboxhelp:Add(button)
    groupbox:Add(groupboxhelp)
  else
    groupboxhelp.Visible = true
  end
end
function on_close_helpbox(self)
  groupbox = self.Parent
  groupbox.Visible = false
end
function change_form_size()
  local self = nx_value("form_stage_main\\form_small_game\\form_forgegame")
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
function on_main_form_open(self)
  GameStart = false
  game_init(self)
  nx_execute("gui", "gui_close_allsystem_form")
  change_form_size()
end
function on_choose_click(self)
  local temp1 = nx_string(self.Name)
  if GameStart == true then
    local groupbox = self.Parent
    local form = groupbox.Parent
    local temp2 = nx_string(currentAction)
    if currentAction == 0 then
    else
      if temp1 == temp2 then
      else
        reduceChance(form)
      end
      form.lbl_action.BackImage = ""
      form.lbl_action.Text = nx_widestr("")
      currentAction = 0
      currentActionTime = 0
    end
  end
  if nx_int(temp1) <= nx_int(table.getn(ActionSoundlist)) then
    local game_visual = nx_value("game_visual")
    local visual_player = game_visual:GetPlayer()
    if not nx_is_valid(visual_player) then
      return
    end
    local filename = nx_string(ActionSoundlist[nx_number(temp1)])
    play_sound(filename)
  end
end
function reduceChance(form)
  local lbl = form.groupbox_back:Find("lbllife_" .. game_chance)
  lbl.BackImage = "gui\\mainform\\smallgame\\life_down.png"
  game_chance = game_chance - 1
  if game_chance <= 0 then
    local ForgeGame = nx_value("ForgeGame")
    stop_timer(form)
    ForgeGame:SendGameResult(0)
    showResult(form, 0)
    GameStart = false
  end
  return
end
function showResult(form, res)
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  form.groupbox_back.Visible = false
  Label.AutoSize = true
  Label.Name = "lab_res"
  local filename = "snd\\action\\minigame\\forge\\7110_5.wav"
  if res == 1 then
    Label.BackImage = victory
    Label.AbsTop = form.groupbox_back.AbsTop - Label.Height + 40
  else
    Label.BackImage = lost
    Label.AbsTop = (gui.Height - Label.Height) / 2
    filename = "snd\\action\\minigame\\forge\\7110_6.wav"
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(2500, -1, nx_current(), "auto_close_form", form, level, -1)
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
  play_sound(filename)
end
function play_sound(filename)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound(filename) then
    gui:AddSound(filename, nx_resource_path() .. filename)
  end
  gui:PlayingSound(filename)
end
function auto_close_form(form, level)
  console_log("end")
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "auto_close_form", form)
  close_game_form()
end
function on_update_time(form, level)
  game_time_now = game_time_now + 200
  form.pbar_forgegame.Value = 100 - (game_total_time - game_time_now) * 100 / game_total_time
  currentActionTime = currentActionTime + 200
  local Delta = form.pbar_forgegame.Value * 85 / 100 * 3.1415926 / 100 + 0.392699075
  local r = form.pbar_forgegame.Width / 2
  form.lbl_action.Left = baseleft + r - r * math.cos(Delta - 0.05) - 25
  form.lbl_action.Top = basetop + r - r * math.sin(Delta - 0.1) - 15
  if game_total_time <= game_time_now then
    local ForgeGame = nx_value("ForgeGame")
    stop_timer(form)
    ForgeGame:SendGameResult(1)
    showResult(form, 1)
    GameStart = false
    return
  end
  if nx_int(GameStep) > nx_int(0) and nx_int(game_time_now) >= nx_int(GameTimeData[GamestepTimeIndex] * 1000) then
    if currentAction ~= 0 then
      reduceChance(form)
    end
    GameStep = GameStep - 1
    if nx_int(GameInfo[GamestepDataIndex]) <= nx_int(table.getn(ActionImageData)) then
      form.lbl_action.BackImage = ActionImageData[nx_number(GameInfo[GamestepDataIndex])] .. ".png"
      form.lbl_action.Text = nx_widestr("")
    else
      form.lbl_action.BackImage = ""
      form.lbl_action.Text = nx_widestr(GameInfo[GamestepDataIndex])
    end
    currentAction = nx_int(GameInfo[GamestepDataIndex])
    GamestepDataIndex = GamestepDataIndex + 1
    GamestepTimeIndex = GamestepTimeIndex + 1
    currentActionTime = 0
    return
  end
  if currentAction ~= 0 and currentActionTime > action_range * 1000 then
    currentAction = 0
    currentActionTime = 0
    form.lbl_action.BackImage = ""
    form.lbl_action.Text = nx_widestr("")
    reduceChance(form)
  end
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
