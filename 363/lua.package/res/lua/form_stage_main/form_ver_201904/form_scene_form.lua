require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_ver_201904\\form_scene_form"
function form_main_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  on_gui_size_change()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_leave_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_scene_form_confirm")))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_ver_201904(nx_int(0))
  end
end
function on_gui_size_change()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 1
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = gui.Width - form.Width
    form.Top = 0
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_server_msg(scene_id, ui)
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.mltbox_ui:Clear()
  form.mltbox_ui:AddHtmlText(nx_widestr(util_text(ui)), -1)
end
