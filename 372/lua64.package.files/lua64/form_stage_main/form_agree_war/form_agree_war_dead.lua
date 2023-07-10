require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_agree_war\\form_agree_war_dead"
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_lbl_time", self, -1, -1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_lbl_time", self)
  end
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function on_btn_relive_near_click(btn)
  custom_agree_war(nx_int(4), nx_int(0))
end
function on_btn_relive_local_click(btn)
  custom_agree_war(nx_int(4), nx_int(1))
end
function on_update_lbl_time(form)
  if not nx_is_valid(form) then
    return
  end
  local time = nx_number(form.lbl_time.Text)
  if time <= 0 then
    return
  end
  form.lbl_time.Text = nx_widestr(time - 1)
end
function open_form(left_time, relive_num)
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    return
  end
  form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
    form.lbl_time.Text = nx_widestr(left_time)
    form.lbl_3.Text = nx_widestr(relive_num)
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
