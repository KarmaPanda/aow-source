local FORM_COMMON_SELF_ADD_NOTICE = "form_stage_main\\form_common_self_add_notice"
local last_time = 0
require("util_functions")
require("define\\gamehand_type")
require("define\\team_sign_define")
require("define\\team_rec_define")
local CLIENT_SUBMSG_CANCEL_WATI_RANDOM_CLONE = 1
local CLIENT_SUBMSG_CAPTAIN_CANCEL_WAIT = 3
function main_form_init(self)
  self.Fixed = false
  self.Visible = true
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Visible = true
  self.lbl_2.Visible = true
  self.lbl_2.Text = nx_widestr(-1)
  self.groupbox_big.Visible = true
  self.groupbox_min.Visible = false
  self.btn_down.Visible = false
  self.btn_up.Visible = true
  self.btn_1.Visible = true
  return 1
end
function main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(self) then
    timer:UnRegister(nx_current(), "self_add_heart", self)
  end
  nx_destroy(self)
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "self_add_heart", form)
    end
    nx_execute("custom_sender", "custom_random_clone", nx_int(CLIENT_SUBMSG_CANCEL_WATI_RANDOM_CLONE))
    form:Close()
  end
end
function show_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_self_add_notice", true, false)
  if nx_is_valid(form) then
    form:Show()
    nx_set_value(FORM_COMMON_SELF_ADD_NOTICE, form)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(1000, -1, nx_current(), "self_add_heart", form, -1, -1)
    end
  end
end
function close_form()
  local form = nx_value(FORM_COMMON_SELF_ADD_NOTICE)
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "self_add_heart", form)
    end
    form:Close()
  end
end
function self_add_heart(form)
  if nx_is_valid(form) then
    local msg_delay = nx_value("MessageDelay")
    local num = nx_int(form.lbl_2.Text)
    if num == nx_int(-1) then
      form.lbl_2.Text = nx_widestr(0)
      last_time = msg_delay:GetServerNowTime()
    else
      cur_time = msg_delay:GetServerNowTime()
      live_time = (nx_int64(cur_time) - nx_int64(last_time)) / 1000
      form.lbl_2.Text = nx_widestr(get_format_time_text(live_time))
      if live_time < 60 then
        form.lbl_s.Text = nx_widestr(nx_int(live_time))
        form.lbl_m.Text = nx_widestr(nx_int(0))
        form.lbl_h.Text = nx_widestr(nx_int(0))
      elseif live_time < 3600 then
        local min = nx_int(live_time / 60)
        local sec = nx_int(live_time) - nx_int(60 * min)
        form.lbl_s.Text = nx_widestr(nx_int(sec))
        form.lbl_m.Text = nx_widestr(nx_int(min))
        form.lbl_h.Text = nx_widestr(nx_int(0))
      else
        local hour = nx_int(live_time / 3600)
        local min = nx_int((nx_int(live_time) - nx_int(3600 * hour)) / 60)
        local sec = nx_int(live_time) - nx_int(60 * min) - nx_int(3600 * hour)
        form.lbl_s.Text = nx_widestr(nx_int(sec))
        form.lbl_m.Text = nx_widestr(nx_int(min))
        form.lbl_h.Text = nx_widestr(nx_int(hour))
      end
    end
  end
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
function close_form_self_add(form)
  if nx_is_valid(form) then
    form.Close()
  end
end
function on_btn_down_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.groupbox_big.Visible = true
    form.groupbox_min.Visible = false
    form.btn_down.Visible = false
    form.btn_up.Visible = true
    form.Height = form.groupbox_big.Height + form.groupbox_min.Top + form.groupbox_min.Height
  end
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.groupbox_big.Visible = false
    form.groupbox_min.Visible = true
    form.btn_down.Visible = true
    form.btn_up.Visible = false
    form.Height = form.groupbox_min.Height + form.groupbox_min.Top
  end
end
