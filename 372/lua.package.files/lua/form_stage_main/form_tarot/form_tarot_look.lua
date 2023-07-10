require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_tarot\\form_tarot_look"
local image_path = "gui\\language\\ChineseS\\tarot"
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_form()
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
function on_btn_close_click(btn)
  close_form()
end
function on_btn_card_try_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_TAROT) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "sys_tarot_005")
    return
  end
  nx_execute("form_stage_main\\form_tarot\\form_tarot_main", "open_form")
  close_form()
end
function look(player_name, id)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_TAROT) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "sys_tarot_005")
    return
  end
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
  end
  form:Show()
  form.Visible = true
  form.lbl_card_pname.Text = nx_widestr(player_name)
  local id_path = string.format("%02d", id)
  form.lbl_card_main.BackImage = image_path .. "\\" .. id_path .. ".png"
end
function a(info)
  nx_msgbox(nx_string(info))
end
