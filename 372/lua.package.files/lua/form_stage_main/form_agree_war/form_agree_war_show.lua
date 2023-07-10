require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_agree_war\\form_agree_war_show"
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function on_btn_1_click(btn)
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_req", "open_form")
  close_form()
end
function on_btn_2_click(btn)
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_main", "open_form")
  close_form()
end
function on_btn_close_click(btn)
  close_form()
end
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_AGREE_WAR) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_switch_close"))
    return
  end
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    return
  end
  form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
