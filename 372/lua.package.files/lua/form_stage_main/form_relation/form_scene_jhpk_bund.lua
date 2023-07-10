require("utils")
require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_relation\\form_scene_jhpk_bund"
local CUSTOM_SUB_JHPK_CHANGE_FRIEND = 4
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function ok_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local text_name = nx_widestr(form.ipt_name.Text)
  if nx_ws_length(text_name) <= 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "sns_new_07")
    return
  end
  nx_execute("custom_sender", "custom_send_scene_jhpk", CUSTOM_SUB_JHPK_CHANGE_FRIEND, nx_widestr(text_name))
  form:Close()
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function custom_jhpk_item_bund()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:Show()
end
