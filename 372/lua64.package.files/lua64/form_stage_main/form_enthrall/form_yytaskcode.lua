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
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local code = nx_string(form.ipt_code.Text)
  local count = string.len(nx_string(code))
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_YY_TASK), 4, nx_string(form.ipt_code.Text))
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(...)
  local sub_id = arg[1]
  if sub_id == YYTASK_BACK_OPEN_TALK then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_enthrall\\form_yytaskcode", true, false)
    if not nx_is_valid(form) then
      return
    end
    form:Show()
  elseif sub_id == YYTASK_BACK_SEND_COM then
    local code_A = arg[2]
    local account = arg[3]
    local address = arg[4]
    local server = arg[5]
    local mgr = nx_value("UnenthrallModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("UnenthrallModule")
      nx_set_value("UnenthrallModule", mgr)
    end
    local ret_tab = mgr:CardCodeConfirm(nx_widestr(account), nx_widestr(server), nx_widestr(address), nx_widestr(code_A))
    local ret = ret_tab[1]
    if nx_int(ret) == nx_int(1) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "91107")
    elseif nx_int(ret) == nx_int(52063) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "91108")
    elseif nx_int(ret) == nx_int(52016) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_cardcode_cant_get_same_type")
    else
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_cardcode_failed")
    end
    if nx_int(ret) ~= nx_int(1) then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return 0
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_YY_TASK), YY_TASK_MSG_SUBMIT)
    end
  elseif sub_id == BACK_PRIZE_CODE_GIFT then
    local account = arg[2]
    local address = arg[3]
    local server = arg[4]
    local code_id = arg[5]
    local mgr = nx_value("UnenthrallModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("UnenthrallModule")
      nx_set_value("UnenthrallModule", mgr)
    end
    local ret_tab = mgr:CardCodeConfirm(nx_widestr(account), nx_widestr(server), nx_widestr(address), nx_widestr(code_id))
    local ret = ret_tab[1]
    if nx_int(ret) == nx_int(1) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_cardcode_success")
    elseif nx_int(ret) == nx_int(52063) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_cardcode_have_get_prize")
    elseif nx_int(ret) == nx_int(52016) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_cardcode_cant_get_same_type")
    else
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_cardcode_failed")
    end
  end
end
