require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_guild_battle\\form_guildbattle_1_1"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  local form_notice = nx_value("form_stage_main\\form_main\\form_notice_shortcut")
  if nx_is_valid(form_notice) then
    self.Left = form_notice.Left
    self.Top = form_notice.Top + form_notice.Height
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(50000, -1, FORM_NAME, "timer_ui", self, -1, -1)
  end
  custom_request_guildplnum()
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_string(FORM_NAME), "timer_ui", self)
  end
  nx_destroy(self)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function timer_ui(form)
  custom_request_guildplnum()
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_server_msg(war_type, ...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local self_num = nx_int(arg[1])
  local target_num = nx_int(arg[2])
  local max_num = nx_int(arg[3])
  form.lbl_chase_count_2.Text = nx_widestr(self_num) .. nx_widestr("/") .. nx_widestr(max_num)
  form.lbl_chase_count_1.Text = nx_widestr(target_num) .. nx_widestr("/") .. nx_widestr(max_num)
end
