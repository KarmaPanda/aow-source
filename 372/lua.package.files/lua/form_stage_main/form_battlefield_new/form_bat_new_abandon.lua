require("util_gui")
require("util_functions")
require("util_static_data")
require("custom_sender")
require("share\\client_custom_define")
require("define\\sysinfo_define")
require("form_stage_main\\form_tvt\\define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local CLIENT_SUB_REQUEST_ABANDON = 513
local CLIENT_SUB_REQUEST_TEAM_NUM = 512
local FORM_NAME = "form_stage_main\\form_battlefield_new\\form_bat_new_abandon"
function main_form_init(self)
  self.Fixed = false
end
function open_test()
  open_form()
end
function open_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
    form:Show()
  else
    util_show_form(FORM_NAME, true)
  end
end
function close_form()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = gui.Width - self.Width
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  custom_request_balance_team()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_abandon_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_REQUEST_ABANDON))
end
function on_btn_no_abandon_click(btn)
  close_form()
end
function custom_request_balance_team()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_REQUEST_TEAM_NUM))
end
function updata_abandon_state(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local team_info = nx_int(arg[1])
  local player_abandon = nx_int(arg[2])
  local abandon_num = nx_int(arg[3])
  form.lbl_abandon_num.Text = nx_widestr(nx_string(abandon_num) .. nx_string("/" .. nx_string(team_info)))
  if player_abandon == nx_int(1) then
    form.btn_abandon.Enabled = false
  end
end
function updata_abandon_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local abandon_num = nx_int(arg[1])
  local team_num = nx_int(arg[2])
  form.lbl_abandon_num.Text = nx_widestr(nx_string(abandon_num) .. nx_string("/" .. nx_string(team_num)))
end
