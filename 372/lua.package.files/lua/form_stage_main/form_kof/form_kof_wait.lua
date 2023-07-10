require("util_gui")
require("util_functions")
require("form_stage_main\\form_kof\\kof_util")
local FORM_NAME = "form_stage_main\\form_kof\\form_kof_wait"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.wait_time = 0
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_time", form)
    game_timer:Register(1000, -1, nx_current(), "update_time", form, -1, -1)
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_time", self)
  end
  nx_destroy(self)
end
function update_time(form)
  form.wait_time = form.wait_time + 1
  form.lbl_time.Text = nx_widestr(form.wait_time)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_cancel_click(btn)
  custom_kof(CTS_SUB_KOF_CANCEL)
  close_form()
end
function on_btn_main_click(btn)
  nx_execute("form_stage_main\\form_kof\\form_kof_apply", "open_form")
end
function on_btn_power_click(btn)
  nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "open_form")
end
