require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_league_matches\\form_lm_invite"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  nx_destroy(self)
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
function on_btn_go_click(btn)
  custom_league_matches(1)
end
function on_btn_close_click(btn)
  close_form()
end
