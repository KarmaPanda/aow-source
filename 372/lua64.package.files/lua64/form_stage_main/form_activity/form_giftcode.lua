require("util_functions")
local CLIENT_CUSTOMMSG_ACTIVITY_MANAGE = 182
local CLIENT_SUBMSG_REQUEST_TAKE_PRIZE = 2
function on_main_form_init(self)
  self.Fixed = false
  self.card_type = ""
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
  if nx_int(count) ~= nx_int(6) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "9992")
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_TAKE_PRIZE), nx_string(code))
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(...)
  local type = arg[1]
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_enthrall\\form_giftcode", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.mltbox_2.Visible = false
  form.mltbox_1.Visible = true
end
