require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_die_util")
local FORM_PATH = "form_stage_main\\form_die_balance_war"
function main_form_init(form)
end
function on_main_form_open(form)
  form.no_need_motion_alpha = true
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.revert = os.time() + 5
  form.LuaScript = nx_current()
  local asynor = nx_value("common_execute")
  asynor:AddExecute("relive_fresh_timer", form, nx_float(0.5))
  local form_load = nx_value("form_common\\form_loading")
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(form)
  else
    gui.Desktop:ToFront(form)
  end
end
function on_main_form_close(form)
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("relive_fresh_timer", form)
  local dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
  nx_destroy(form)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_PATH, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_relive_near_click(btn)
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_BALANCE_WAR)
end
function on_time_over()
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_BALANCE_WAR)
end