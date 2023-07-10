require("util_functions")
require("util_gui")
require("share\\client_custom_define")
local YY_TASK_MSG_ACCEPT = 0
local YY_TASK_MSG_SUBMIT = 1
local PRIZE_CODE_GIFT = 3
local YYTASK_BACK_OPEN_TALK = 0
local YYTASK_BACK_SEND_COM = 1
local BACK_PRIZE_CODE_GIFT = 2
function on_main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("UnenthrallModule")
    nx_set_value("UnenthrallModule", mgr)
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_YY_TASK), PRIZE_CODE_GIFT, nx_string(form.ipt_code.Text))
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(...)
  local account = arg[1]
  local address = arg[2]
  local server = arg[3]
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_enthrall\\form_prizecode", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.account = nx_widestr(account)
  form.address = nx_widestr(address)
  form.server = nx_widestr(server)
end
