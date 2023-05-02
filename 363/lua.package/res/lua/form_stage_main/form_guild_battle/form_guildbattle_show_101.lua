require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_guild_battle\\form_guildbattle_show_101"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(10000, -1, FORM_NAME, "timer_ui", self, -1, -1)
  end
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_string(FORM_NAME), "timer_ui", self)
  end
  nx_destroy(self)
end
function open_form(war_type)
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function timer_ui(form)
  if nx_is_valid(form) then
    form:Close()
  end
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
