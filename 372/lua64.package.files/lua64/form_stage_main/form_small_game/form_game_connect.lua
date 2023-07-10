require("util_functions")
require("gui")
local file_name = "share\\Life\\ConnectGame.ini"
local last_select = -1
local select_image = ""
local normal_image = ""
local game_total_time = 1000
local game_time_now = 0
local max_btn = 1
local connectsound = ""
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(self)
  return 1
end
function change_form_size()
  local self = nx_value("form_stage_main\\form_small_game\\form_game_connect")
  if nx_is_valid(self) then
    local gui = nx_value("gui")
    self.AbsLeft = 0
    self.AbsTop = 0
    self.Width = gui.Width
    self.Height = gui.Height
    self.groupbox_backgroundImage.Width = gui.Width
    self.groupbox_backgroundImage.Height = gui.Height
    self.groupbox_backgroundImage.AbsLeft = 0
    self.groupbox_backgroundImage.AbsTop = 0
    self.groupbox_background.AbsLeft = (gui.Width - self.groupbox_background.Width) / 2
    self.groupbox_background.AbsTop = (gui.Height - self.groupbox_background.Height) / 2 - self.groupbox_background.Height / 10
  end
end
function on_main_form_open(self)
  game_init(self)
  nx_execute("gui", "gui_close_allsystem_form")
  change_form_size()
end
function on_main_form_close(self)
  nx_execute("gui", "gui_open_closedsystem_form")
  nx_destroy(self)
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_connect")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_backgroundImage.BlendAlpha = form.groupbox_backgroundImage.BlendAlpha - delta
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.Visible = false
  local timer = nx_value(GAME_TIMER)
  nx_execute(nx_current(), "on_update_time", form, 0)
  timer:Register(200, -1, nx_current(), "on_update_time", form, 0, -1)
  groupbox = btn.Parent
  for i = 1, max_btn do
    local button = groupbox:Find("btn_" .. i)
    if button.FocusImage ~= "" then
      console_log("button.FocusImage" .. nx_string(button.FocusImage))
      button.Visible = true
    end
  end
end
function on_update_time(form, level)
  game_time_now = game_time_now + 200
  form.pebar_connect.Value = 100 - (game_total_time - game_time_now) * 100 / game_total_time
  if game_total_time <= game_time_now then
    local ConnectGame = nx_value("ConnectGame")
    ConnectGame:SendError()
    stop_timer(form)
    showResult(form, 0)
    return
  end
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
function auto_close_form(form, level)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "auto_close_form", form)
  form:Close()
end
local victory = "gui\\language\\ChineseS\\minigame\\victory.png"
local lost = "gui\\language\\ChineseS\\minigame\\lost.png"
function showResult(form, res)
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  form.groupbox_background.Visible = false
  Label.AutoSize = true
  Label.Name = "lab_res"
  local filename = "snd\\action\\minigame\\forge\\7110_5.wav"
  if res == 1 then
    Label.BackImage = victory
    Label.AbsTop = form.groupbox_background.AbsTop - Label.Height + 40
  else
    Label.BackImage = lost
    Label.AbsTop = (gui.Height - Label.Height) / 2
    filename = "snd\\action\\minigame\\forge\\7110_6.wav"
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(2500, -1, nx_current(), "auto_close_form", form, 0, -1)
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return 0
  end
  local x = visual_player.PositionX
  local y = visual_player.PositionY
  local z = visual_player.PositionZ
  nx_execute("util_sound", "play_terrain_sound", filename, x, y, z)
end
function game_init(form)
  local gui = nx_value("gui")
  local ConnectGame = nx_value("ConnectGame")
  local index = ConnectGame:GetGameDiff()
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string(index))
  if sec_index < 0 then
    index = "default"
  end
  local groupbox = form.groupbox_background
  game_total_time = ini:ReadInteger(sec_index, "time", 1) * 1000
  form.lbl_back.BackImage = ini:ReadString(sec_index, "backpic", "")
  select_image = ini:ReadString(sec_index, "unkownflag", "")
  normal_image = ini:ReadString(sec_index, "unkownflag2", "")
  game_time_now = 0
  form.lbl_back.BackImage = ini:ReadString(sec_index, "backpic", "")
  form.lbl_progress.BackImage = ini:ReadString(sec_index, "progresspic", "")
  form.groupbox_background.Height = form.lbl_back.Height
  form.lbl_back.AbsLeft = (form.groupbox_background.Width - form.lbl_back.Width) / 2 + form.groupbox_background.AbsLeft
  connectsound = ini:ReadString(nx_string(index), "connectsound", "")
  form.btn_start.AbsTop = form.groupbox_background.AbsTop + form.groupbox_background.Height - form.btn_start.Height
  form.btn_start.AbsLeft = form.groupbox_background.AbsLeft + (form.groupbox_background.Width - form.btn_start.Width) / 2
  form.lbl_progress.AbsTop = form.groupbox_background.AbsTop + form.groupbox_background.Height - form.lbl_progress.Height
  form.lbl_progress.AbsLeft = (form.groupbox_background.Width - form.lbl_progress.Width) / 2 + form.groupbox_background.AbsLeft
  form.pebar_connect.AbsTop = form.lbl_progress.AbsTop + 4
  form.pebar_connect.AbsLeft = form.lbl_progress.AbsLeft + 21
  local i = 0
  while true do
    i = i + 1
    local pos = ini:ReadString(sec_index, "b" .. i, "")
    if pos == "" then
      max_btn = i - 1
      break
    end
    console_log("btn_" .. i)
    local button = gui:Create("Button")
    button.Name = "btn_" .. i
    button.Visible = false
    button.index = i
    button.lock = false
    button.DrawMode = "FitWindow"
    local info_lst = util_split_string(pos, ",")
    if 2 <= table.getn(info_lst) then
      button.Left = nx_int(info_lst[1])
      button.Top = nx_int(info_lst[2])
      button.BackImage = normal_image
      if button.Left ~= 0 then
        console_log("button.Left" .. nx_string(button.Left))
        console_log("button.Top" .. nx_string(button.Top))
      end
      button.AutoSize = true
      button.NormalImage = normal_image
      local value = ConnectGame:GetValueByIndex(i)
      button.FocusImage = ini:ReadString(sec_index, "flag" .. value, "")
      nx_bind_script(button, nx_current(), "")
      nx_callback(button, "on_click", "on_btn_click")
    end
    form.groupbox_background:Add(button)
  end
  return 1
end
function btnRight(btn, last_select)
  btn.lock = true
  btn.NormalImage = btn.FocusImage
  local button = btn.Parent:Find("btn_" .. last_select)
  button.lock = true
  button.NormalImage = button.FocusImage
  last_select = -1
end
function on_btn_click(btn)
  if btn.lock then
    return
  end
  if last_select == -1 then
    last_select = btn.index
    btn.NormalImage = select_image
  elseif last_select == btn.index then
    last_select = -1
    btn.NormalImage = normal_image
  else
    local ConnectGame = nx_value("ConnectGame")
    local res = ConnectGame:Check(btn.index, last_select)
    if res == 1 then
      btnRight(btn, last_select)
      last_select = -1
      local game_visual = nx_value("game_visual")
      local visual_player = game_visual:GetPlayer()
      if nx_is_valid(visual_player) then
        local x = visual_player.PositionX
        local y = visual_player.PositionY
        local z = visual_player.PositionZ
        nx_execute("util_sound", "play_terrain_sound", connectsound, x, y, z)
      end
    elseif res == 2 then
      btnRight(btn, last_select)
      form = btn.ParentForm
      showResult(form, 1)
      stop_timer(form)
      last_select = -1
    elseif res == -1 then
      local button = btn.Parent:Find("btn_" .. last_select)
      button.NormalImage = normal_image
      last_select = -1
    end
  end
end
function on_end_game(res)
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_game_connect")
  if not nx_is_valid(form_talk) then
    return
  end
  if res == 1 then
  elseif res == 2 then
  end
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
    multitextbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_smallgame_bz_qj"))
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
    form:Close()
    local ConnectGame = nx_value("ConnectGame")
    ConnectGame:SendError()
  end
end
function on_btn_close_click(self)
  show_close_dialog(self.ParentForm)
end
