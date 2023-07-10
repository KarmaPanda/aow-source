require("util_gui")
require("util_functions")
require("form_stage_main\\form_die_util")
require("custom_sender")
local RELIVE_SANMENG_FRONT = 1
local RELIVE_SANMENG_BACK = 2
local FORM_PATH = "form_stage_main\\form_die_sanmeng"
function main_form_init(form)
  form.Fixed = false
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.no_need_motion_alpha = true
  form.revert = os.time() + 180
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
function main_form_close(form)
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
function on_btn_relive_front_click(self)
  nx_execute(nx_current(), "show_ok_dialog", self.ParentForm, RELIVE_TYPE_SANMENG, RELIVE_SANMENG_FRONT)
end
function on_btn_relive_back_click(self)
  nx_execute(nx_current(), "show_ok_dialog", self.ParentForm, RELIVE_TYPE_SANMENG, RELIVE_SANMENG_BACK)
end
function show_ok_dialog(form, relive_type, relive_index)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  local dialog = util_get_form("form_stage_main\\form_relive_ok", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local str = get_confirm_info(relive_type, nx_int(relive_index))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(str), -1)
  dialog.lbl_remain_count.Visible = false
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    local safe_mode = 0
    nx_execute("custom_sender", "custom_relive", relive_type, safe_mode, relive_index)
  end
end
