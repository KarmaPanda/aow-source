require("custom_sender")
function client_request_leave_yhg_td()
  local text = ""
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    text = gui.TextManager:GetText("ui_yhg_taofa_leave")
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" == result then
    nx_execute("custom_sender", "custom_yhg_td_request_leave")
  end
end
