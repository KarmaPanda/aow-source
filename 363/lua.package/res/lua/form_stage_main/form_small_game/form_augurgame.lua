require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
local game_time_now = 0
function change_form_size()
  local self = nx_value("form_stage_main\\form_small_game\\form_augurgame")
  if nx_is_valid(self) then
    local gui = nx_value("gui")
    self.AbsLeft = 0
    self.AbsTop = 0
    self.Width = gui.Width
    self.Height = gui.Height
    self.groupbox_backImage.Width = gui.Width
    self.groupbox_backImage.Height = gui.Height
    self.groupbox_show.AbsLeft = (gui.Width - self.groupbox_show.Width) / 2
    self.groupbox_show.AbsTop = (gui.Height - self.groupbox_show.Height) / 5 * 2
    self.lbl_ShowCartoon.Left = (self.groupbox_show.Width - self.lbl_ShowCartoon.Width) / 2
    self.lbl_ShowCartoon.Top = (self.groupbox_show.Height - self.lbl_ShowCartoon.Height) / 2
  end
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_augurgame")
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
    local AugurGame = nx_value("AugurGame")
    AugurGame:SendGameResult()
    GameStart = false
    AugurGame:Close()
  end
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
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
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_augurgame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function on_btn_close_click(btn)
  local AugurGame = nx_value("AugurGame")
  AugurGame:SendGameResult()
  AugurGame:Close()
end
function game_init(form)
  game_time_now = 0
  form.btn_close.Visible = false
  return 1
end
function start_augur()
  local form = nx_value("form_stage_main\\form_small_game\\form_augurgame")
  if nx_is_valid(form) then
    local timer = nx_value(GAME_TIMER)
    nx_execute(nx_current(), "on_update_time", form, 1)
    timer:Register(40, -1, nx_current(), "on_update_time", form, 1, -1)
  end
end
function end_augur(index)
  local form = nx_value("form_stage_main\\form_small_game\\form_augurgame")
  if nx_is_valid(form) then
    stop_timer(form)
    form.lbl_showresult.Text = nx_widestr(index)
    form.btn_close.Visible = true
    local AugurGame = nx_value("AugurGame")
    AugurGame:SendGameResult()
    AugurGame:Close()
  end
end
function on_close_helpbox(self)
  groupbox = self.Parent
  groupbox.Visible = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  game_init(self)
  change_form_size()
  nx_execute("gui", "gui_close_allsystem_form")
end
function on_update_time(form, level)
  game_time_now = game_time_now + 40
  if math.random(4) > 1 then
    form.lbl_ShowCartoon.Left = (form.groupbox_show.Width - form.lbl_ShowCartoon.Width) / 2 + math.random(3)
  else
    form.lbl_ShowCartoon.Left = (form.groupbox_show.Width - form.lbl_ShowCartoon.Width) / 2 - math.random(3)
  end
  if math.random(4) > 1 then
    form.lbl_ShowCartoon.Top = (form.groupbox_show.Height - form.lbl_ShowCartoon.Height) / 2 + math.random(3)
  else
    form.lbl_ShowCartoon.Top = (form.groupbox_show.Height - form.lbl_ShowCartoon.Height) / 2 - math.random(3)
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
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
