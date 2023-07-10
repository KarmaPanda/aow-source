require("const_define")
require("util_functions")
require("custom_sender")
require("util_gui")
require("tips_data")
require("role_composite")
require("share\\client_custom_define")
require("define\\request_type")
function main_form_init(form)
  form.Fixed = false
  form.pack_id = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
end
function on_main_form_close(form)
  form.pack_id = ""
  nx_destroy(form)
end
function on_btn_open_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_get_newpacket(nx_string(form.pack_id))
end
function on_btn_close_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_server_msg(...)
  local form = util_get_form("form_stage_main\\form_hongbao\\form_hongbao_receive", true, false)
  if not nx_is_valid(form) then
    return
  end
  local name = nx_widestr(arg[1])
  local bless = nx_widestr(arg[2])
  form.pack_id = nx_string(arg[3])
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_hongbao_receive_info")
  gui.TextManager:Format_AddParam(nx_widestr(name))
  gui.TextManager:Format_AddParam(nx_widestr(bless))
  local text = gui.TextManager:Format_GetText()
  form.mltbox_info:Clear()
  form.mltbox_info:AddHtmlText(nx_widestr(text), -1)
  form.Visible = true
  form:Show()
end
