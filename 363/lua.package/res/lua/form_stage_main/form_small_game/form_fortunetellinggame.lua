require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
local game_time_now = 0
local index1 = 0
local index2 = 0
local index3 = 0
local roundindex1 = 0
local roundindex2 = 0
local roundindex3 = 0
local speed1 = 0
local speed2 = 0
local speed3 = 0
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function change_form_size()
  local self = nx_value("form_stage_main\\form_small_game\\form_fortunetellinggame")
  if nx_is_valid(self) then
    local gui = nx_value("gui")
    self.AbsLeft = 0
    self.AbsTop = 0
    self.Width = gui.Width
    self.Height = gui.Height
    self.groupbox_backImage.Width = gui.Width
    self.groupbox_backImage.Height = gui.Height
    self.groupbox_fortunetellinggame.AbsLeft = (gui.Width - self.groupbox_fortunetellinggame.Width) / 2
    self.groupbox_fortunetellinggame.AbsTop = (gui.Height - self.groupbox_fortunetellinggame.Height) / 5 * 2
  end
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_fortunetellinggame")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_backImage.BlendAlpha = form.groupbox_backImage.BlendAlpha - delta
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
    local FortuneTellingGame = nx_value("FortuneTellingGame")
    FortuneTellingGame:SendGameResult(0)
    FortuneTellingGame:Close()
  end
end
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_close(form)
  nx_execute("gui", "gui_open_closedsystem_form")
  nx_destroy(form)
end
function close_game_form()
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_fortunetellinggame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function on_btn_jiegua_click(btn)
  local FortuneTellingGame = nx_value("FortuneTellingGame")
  FortuneTellingGame:SendGameResult(1)
  FortuneTellingGame:Close()
end
function game_init(form)
  game_time_now = 0
  local FortuneTellingGame = nx_value("FortuneTellingGame")
  GameInfo = FortuneTellingGame:GetGameInfo()
  index1 = GameInfo[1]
  roundindex1 = GameInfo[2] * 6.28 + 0.785 * (index1 - 1)
  index2 = GameInfo[3]
  roundindex2 = GameInfo[4] * 6.28 + 1.57 * (4 - (index2 - 1))
  index3 = GameInfo[5]
  roundindex3 = GameInfo[6] * 6.28 + 3.14 * (index3 - 1)
  speed1 = roundindex1 / 90
  speed2 = roundindex2 / 90
  speed3 = roundindex3 / 90
  console_log("roundindex1" .. roundindex1)
  console_log("roundindex2" .. roundindex2)
  console_log("roundindex3" .. roundindex3)
  console_log("speed1:" .. speed1)
  console_log("speed2:" .. speed2)
  console_log("speed3:" .. speed3)
  form.btn_jiegua.Visible = false
  return 1
end
function on_btn_start_click(self)
  local FortuneTellingGame = nx_value("FortuneTellingGame")
  FortuneTellingGame:SendStartMsg()
  local form = self.ParentForm
  local timer = nx_value(GAME_TIMER)
  nx_execute(nx_current(), "on_update_time", form, 1)
  timer:Register(40, -1, nx_current(), "on_update_time", form, 1, -1)
  self.Visible = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  change_form_size()
  game_init(self)
  nx_execute("gui", "gui_close_allsystem_form")
end
function ReduceSpeed(speed)
  speed = speed - speed / 90
  if speed < 0 then
    speed = 0
  elseif speed < 0.01 then
    speed = 0.01
  end
  return speed
end
function on_update_time(form, level)
  game_time_now = game_time_now + 40
  speed1 = ReduceSpeed(speed1)
  speed2 = ReduceSpeed(speed2)
  speed3 = ReduceSpeed(speed3)
  local tempflag = 0
  local lbl3 = form.groupbox_fortunetellinggame:Find("lbl_round3")
  if 0 <= roundindex3 - speed3 then
    lbl3.AngleZ = lbl3.AngleZ + speed3
    roundindex3 = roundindex3 - speed3
  else
    lbl3.AngleZ = lbl3.AngleZ + roundindex3
    roundindex3 = 0
    tempflag = tempflag + 1
  end
  local lbl2 = form.groupbox_fortunetellinggame:Find("lbl_round2")
  if 0 <= roundindex2 - speed2 then
    lbl2.AngleZ = lbl2.AngleZ - speed2
    roundindex2 = roundindex2 - speed2
  else
    lbl2.AngleZ = lbl2.AngleZ + roundindex2
    roundindex2 = 0
    tempflag = tempflag + 10
  end
  local lbl1 = form.groupbox_fortunetellinggame:Find("lbl_round1")
  if 0 <= roundindex1 - speed1 then
    lbl1.AngleZ = lbl1.AngleZ + speed1
    roundindex1 = roundindex1 - speed1
  else
    lbl1.AngleZ = lbl1.AngleZ + roundindex1
    roundindex1 = 0
    tempflag = tempflag + 100
  end
  if tempflag == 111 then
    if form.btn_jiegua.Visible == false then
      nx_execute("custom_sender", "custom_canopen_fortunetelling")
    end
    form.btn_jiegua.Visible = true
  end
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
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
    button.NormalImage = "gui\\language\\ChineseS\\tc-out.png"
    button.FocusImage = "gui\\language\\ChineseS\\tc-on.png"
    button.PushImage = "gui\\language\\ChineseS\\tc-down.png"
    button.AbsLeft = groupboxhelp.Width - button.Width - 30
    button.AbsTop = 30
    nx_bind_script(button, nx_current(), "")
    nx_callback(button, "on_click", "on_close_helpbox")
    local gui = nx_value("gui")
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
    multitextbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_smallgame_bz_gs"))
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
