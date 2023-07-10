local LEITAI_STATUS_READY = 1
local LEITAI_STATUS_READY_CONFIRMING = 2
local LEITAI_STATUS_PREPARING = 3
local LEITAI_STATUS_GAMEING = 4
local LEITAI_STATUS_FINISHED = 5
local CONTROL_SCAL_WIDTH = 24
local CONTROL_SCAL_HEIGHT = 25
local FORM_MOVE_HEIGHT = 10
require("util_gui")
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
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_timer(self)
  self.time = nx_number(self.time) - 1
  if self.time < 1 then
    self:Close()
  elseif self.time < 0 then
    self.lbl_info.Text = nx_widestr("")
  else
    fix_time(self, self.status, self.time)
  end
end
function process_leitai_time(status, time)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    util_show_form(nx_current(), true)
    form = nx_value(nx_current())
  end
  form.status = status
  local message_delay = nx_value("MessageDelay")
  local now = message_delay:GetServerNowTime()
  form.time = nx_number(nx_int((time - now) / 1000))
  fix_time(form, status, time)
end
function fix_time(form, status, time)
  if nx_int(status) == nx_int(1) or nx_int(status) == nx_int(2) then
    form.ParentForm:Close()
    return
  end
  local gui = nx_value("gui")
  local info = gui.TextManager:GetFormatText("ui_leitai_info" .. nx_string(status), nx_int(form.time))
  form.lbl_info.Text = nx_widestr(info)
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
