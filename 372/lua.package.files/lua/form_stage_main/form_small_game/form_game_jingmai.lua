require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
require("gui")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("share\\itemtype_define")
require("tips_data")
local level = 0
local game_chance = 3
local game_total_time = 1000
local game_time_now = 0
local action_range = 1000
local action_time = 1000
local cur_action_time = 0
local helptext = "@ui_smallgame_wwwq_qie"
local jingmai = ""
local maxuewei = 0
local cur_index = 0
local MoveTime = 200
local GameStart = false
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
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_game_jingmai")
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
    local JingmaiGame = nx_value("JingmaiGame")
    JingmaiGame:SendGameResult(0)
    JingmaiGame:Close()
    GameStart = false
  end
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function game_init(form)
  local JingmaiGame = nx_value("JingmaiGame")
  local index = JingmaiGame:GetGameDiff()
  local gui = nx_value("gui")
  local file_name = "share\\Life\\JingmaiGame.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string(index))
  if sec_index < 0 then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  level = sec_index
  jingmai = ini:ReadString(sec_index, "Jinmai", "")
  game_chance = ini:ReadInteger(sec_index, "Life", 3)
  game_total_time = ini:ReadInteger(sec_index, "Time", 1000)
  game_time_now = 0
  action_range = ini:ReadInteger(sec_index, "ActionRange", 1000)
  action_time = ini:ReadInteger(sec_index, "ActionTime", 1000)
  MoveTime = ini:ReadInteger(sec_index, "MoveTime", 200)
  victory = "gui\\language\\ChineseS\\minigame\\victory.png"
  lost = "gui\\language\\ChineseS\\minigame\\lost.png"
  local groupbox = form.groupbox_back
  for i = 1, 5 do
    local lblname = "lbllife_" .. i
    local lbl = groupbox:Find(lblname)
    lbl.BackImage = "gui\\mainform\\smallgame\\life_down.png"
    lbl.Visible = false
  end
  baseleft = form.pbar_JingmaiGame.Left
  basetop = form.pbar_JingmaiGame.Top
  form.groupbox_xuewei.BackImage = JINGMAI_BACKIMAGE_DIR .. nx_string(jingmai) .. ".png"
  local xuewei_list = wuxue_query:GetItemNames(WUXUE_JINGMAI, nx_string(jingmai))
  maxuewei = table.getn(xuewei_list)
  for i = 1, table.getn(xuewei_list) do
    local xuewei_id = xuewei_list[i]
    local pos_x, pos_y = jingmai_query:GetXueWeiPos(nx_string(jingmai), i - 1)
    local btn_wuewei = gui:Create("Button")
    if nx_is_valid(btn_wuewei) then
      btn_wuewei.Left = nx_int(pos_x)
      btn_wuewei.Top = nx_int(pos_y)
      btn_wuewei.AutoSize = true
    end
    btn_wuewei.NormalImage = JINGMAI_XUEWEI_OPEN
    btn_wuewei.FocusImage = JINGMAI_XUEWEI_OPEN
    btn_wuewei.PushImage = JINGMAI_XUEWEI_SELECT
    btn_wuewei.IsRed = false
    btn_wuewei.Name = nx_string(i)
    form.groupbox_xuewei:Add(btn_wuewei)
    form.groupbox_xuewei:ToFront(btn_wuewei)
    nx_bind_script(btn_wuewei, nx_current())
    nx_callback(btn_wuewei, "on_click", "on_btn_xuewei_click")
  end
  cur_index = 1
end
function on_btn_startgame_click(btn)
  if GameStart == false then
    local timer = nx_value(GAME_TIMER)
    local groupbox = btn.Parent
    local form = groupbox.Parent
    nx_execute(nx_current(), "on_update_time", form, level)
    timer:Register(MoveTime, -1, nx_current(), "on_update_time", form, level, -1)
    GameStart = true
    btn.Visible = false
    for i = 1, game_chance do
      local lblname = "lbllife_" .. i
      local lbl = groupbox:Find(lblname)
      lbl.BackImage = "gui\\mainform\\smallgame\\life_on.png"
      lbl.Visible = true
    end
    cur_action_time = 0
  end
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_jingmai")
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
    nx_bind_script(button, nx_current())
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
  local self = nx_value("form_stage_main\\form_small_game\\form_game_jingmai")
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
  local gui = nx_value("gui")
  local photo = "cur\\wang1.ani"
  local cantphoto = "cur\\wang1.ani"
  gui.GameHand:SetHand("jingmaigame", photo, nx_string(jobid), photo, cantphoto, "")
end
function on_btn_xuewei_click(button)
  if GameStart == false then
    return
  end
  if button.IsRed == true then
    button.NormalImage = JINGMAI_XUEWEI_OPEN
    button.FocusImage = JINGMAI_XUEWEI_OPEN
    button.PushImage = JINGMAI_XUEWEI_SELECT
    button.IsRed = false
  else
    reduceChance(button.ParentForm)
  end
end
function reduceChance(form)
  local lbl = form.groupbox_back:Find("lbllife_" .. game_chance)
  lbl.BackImage = "gui\\mainform\\smallgame\\life_down.png"
  game_chance = game_chance - 1
  if game_chance <= 0 then
    local JingmaiGame = nx_value("JingmaiGame")
    stop_timer(form)
    JingmaiGame:SendGameResult(0)
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
  game_time_now = game_time_now + MoveTime
  cur_action_time = cur_action_time + MoveTime
  form.pbar_JingmaiGame.Value = 100 - (game_total_time - game_time_now) * 100 / game_total_time
  local Delta = form.pbar_JingmaiGame.Value * 85 / 100 * 3.1415926 / 100 + 0.392699075
  local r = form.pbar_JingmaiGame.Width / 2
  form.lbl_action.Left = baseleft + r - r * math.cos(Delta - 0.05) - 25
  form.lbl_action.Top = basetop + r - r * math.sin(Delta - 0.1) - 15
  if game_total_time <= game_time_now then
    local JingmaiGame = nx_value("JingmaiGame")
    stop_timer(form)
    JingmaiGame:SendGameResult(1)
    showResult(form, 1)
    GameStart = false
    return
  end
  local button = form.groupbox_xuewei:Find(nx_string(cur_index))
  if button.IsRed == false then
    button.NormalImage = JINGMAI_XUEWEI_OPEN
    button.FocusImage = JINGMAI_XUEWEI_OPEN
    button.PushImage = JINGMAI_XUEWEI_SELECT
  end
  cur_index = cur_index + 1
  if cur_index > maxuewei then
    cur_index = 1
  end
  button = form.groupbox_xuewei:Find(nx_string(cur_index))
  if button.IsRed == true then
    reduceChance(form)
    button.IsRed = false
  end
  button.NormalImage = "gui\\mainform\\smallgame\\zmgreen_out.png"
  button.FocusImage = "gui\\mainform\\smallgame\\zmgreen_on.png"
  button.PushImage = "gui\\mainform\\smallgame\\zmgreen_down.png"
  if nx_int(cur_action_time) > nx_int(action_time) then
    cur_action_time = 0
    button.NormalImage = "gui\\mainform\\smallgame\\jmred_out.png"
    button.FocusImage = "gui\\mainform\\smallgame\\jmred_on.png"
    button.PushImage = "gui\\mainform\\smallgame\\jmred_down.png"
    button.IsRed = true
  end
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
