require("util_functions")
require("util_gui")
require("share\\client_custom_define")
local form_name = "form_stage_main\\form_freshman\\form_freshman_jiayuan"
function on_main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  self:Close()
  nx_destroy(self)
end
function open_form()
  util_show_form(form_name, true)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_old_click(btn)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FRESHMAN_JIAYUAN), nx_string("btn_old"))
  end
end
function on_btn_new_click(btn)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FRESHMAN_JIAYUAN), nx_string("btn_new"))
  end
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
