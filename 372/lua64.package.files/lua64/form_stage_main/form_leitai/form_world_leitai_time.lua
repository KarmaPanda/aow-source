local LEITAI_STATUS_READY = 1
local LEITAI_STATUS_READY_CONFIRMING = 2
local LEITAI_STATUS_PREPARING = 3
local LEITAI_STATUS_GAMEING = 4
local LEITAI_STATUS_FINISHED = 5
local CONTROL_SCAL_WIDTH = 24
local CONTROL_SCAL_HEIGHT = 25
local FORM_MOVE_HEIGHT = 10
require("util_gui")
local FORM_WORLD_LEITAI_TIME = "form_stage_main\\form_leitai\\form_world_leitai_time"
local world_leitai_prepare_state = 0
local world_leitai_game_state = 1
function main_form_init(self)
  self.Fixed = false
  self.form_width = self.Width
  self.form_height = self.Height
  self.form_left = self.Left
  self.form_top = self.Top
end
function on_main_form_open(self)
  local form = self.ParentForm
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
    timer:Register(1000, -1, nx_current(), "on_timer", self, -1, -1)
  end
  self.btn_close_left = form.btn_close.Left
  self.btn_close_top = form.btn_close.Top
  self.btn_close_width = form.btn_close.Width
  self.btn_close_height = form.btn_close.Height
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
  end
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_show_time_form(...)
  local form = util_get_form(FORM_WORLD_LEITAI_TIME, true)
  if not nx_is_valid(form) then
    return
  end
  form.leitai_state = arg[2]
  form.time = arg[3]
  if nx_int(form.time) <= nx_int(0) then
    form:Close()
    return
  end
  local gui = nx_value("gui")
  local challenge_text = gui.TextManager:GetFormatText("ui_world_leitai_challenge_name", nx_string(arg[4]))
  form.lbl_challenger_name.Text = nx_widestr(challenge_text)
  challenge_text = gui.TextManager:GetFormatText("ui_world_leitai_player_score") .. nx_widestr(arg[5])
  form.lbl_challenger_score.Text = nx_widestr(challenge_text)
  local be_challenge_text = gui.TextManager:GetFormatText("ui_world_leitai_be_challenge_name", nx_string(arg[6]))
  form.lbl_be_challenge_name.Text = nx_widestr(be_challenge_text)
  be_challenge_text = gui.TextManager:GetFormatText("ui_world_leitai_player_score") .. nx_widestr(arg[7])
  form.lbl_be_challenger_score.Text = nx_widestr(be_challenge_text)
  form.Visible = true
  form:Show()
end
function on_timer(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  form.time = nx_number(form.time) - 1
  if form.time < 1 then
    form.lbl_info.Text = nx_widestr("")
    form.Visible = false
    form:Close()
  else
    local info = gui.TextManager:GetFormatText("ui_world_leitai_time_" .. nx_string(form.leitai_state), nx_int(form.time))
    form.lbl_info.Text = nx_widestr(info)
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if form.lbl_info.Visible == true then
    set_show_or_hide(self, false)
  else
    set_show_or_hide(self, true)
  end
end
function set_show_or_hide(self, flag)
  local form = self.ParentForm
  if flag == false then
    form.Left = form.Left + form.Width - CONTROL_SCAL_WIDTH
    form.Width = CONTROL_SCAL_WIDTH
    form.Height = CONTROL_SCAL_HEIGHT + FORM_MOVE_HEIGHT
    form.Top = form.Top - FORM_MOVE_HEIGHT
    form.btn_close.Left = 0
    form.btn_close.Top = FORM_MOVE_HEIGHT
    form.btn_close.Width = CONTROL_SCAL_WIDTH
    form.btn_close.Height = CONTROL_SCAL_HEIGHT
    form.BlendColor = "0,0,0,0"
    form.btn_close.NormalImage = "gui\\guild\\guildwar\\zhujiemian_xiala_suo_up.png"
    form.btn_close.FocusImage = "gui\\guild\\guildwar\\zhujiemian_xiala_suo_over.png"
    form.btn_close.PushImage = "gui\\guild\\guildwar\\zhujiemian_xiala_suo_down.png"
  else
    form.Width = form.form_width
    form.Height = form.form_height
    form.Left = form.Left - form.form_width + CONTROL_SCAL_WIDTH
    form.Top = form.Top + FORM_MOVE_HEIGHT
    form.btn_close.Left = form.btn_close_left
    form.btn_close.Top = form.btn_close_top
    form.btn_close.Width = form.btn_close_width
    form.btn_close.Height = form.btn_close_height
    form.BlendColor = "255,255,255,255"
    form.btn_close.NormalImage = "gui\\guild\\guildwar\\zhujiemian_xiala_shang_up.png"
    form.btn_close.FocusImage = "gui\\guild\\guildwar\\zhujiemian_xiala_shang_over.png"
    form.btn_close.PushImage = "gui\\guild\\guildwar\\zhujiemian_xiala_shang_down.png"
  end
  form.lbl_info.Visible = flag
  form.lbl_line.Visible = flag
end
