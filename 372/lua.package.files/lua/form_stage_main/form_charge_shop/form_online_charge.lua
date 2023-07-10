require("util_gui")
require("form_stage_main\\switch\\url_define")
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_info(form)
  return 1
end
function on_main_form_close(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
  return 1
end
function on_btn_charge_click()
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function init_info(form)
  local gui = nx_value("gui")
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(gui.TextManager:GetText("ui_addmoney_0"), nx_int(0))
  form.mltbox_charge_info:Clear()
  form.mltbox_charge_info:AddHtmlText(gui.TextManager:GetText("ui_addmoney_2"), nx_int(0))
  form.mltbox_get_yinka:Clear()
  form.mltbox_get_yinka:AddHtmlText(gui.TextManager:GetText("ui_addmoney_4"), nx_int(0))
  local phone_number = get_phone()
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_addmoney_5")
  gui.TextManager:Format_AddParam(phone_number)
  local text = gui.TextManager:Format_GetText()
  form.mltbox_kehu:Clear()
  form.mltbox_kehu:AddHtmlText(text, nx_int(0))
  form.mltbox_enter_9y_if:Clear()
  form.mltbox_enter_9y_if:AddHtmlText(gui.TextManager:GetText("ui_addmoney_6"), nx_int(0))
end
function on_buy_capital_click(btn)
  nx_execute("form_stage_main\\form_consign\\form_buy_capital", "show_hide_buy_capital_form")
end
function on_consign_click(btn)
end
function get_phone()
  local path = nx_work_path()
  if string.sub(path, string.len(path)) == "\\" then
    path = string.sub(path, 1, string.len(path) - 1)
  end
  local root_path, s1 = nx_function("ext_split_file_path", path)
  local file_name = root_path .. "updater\\updater_cfg\\url_config.ini"
  local ini = nx_create("IniDocumentUtf8")
  ini.FileName = file_name
  local phone_number = nx_widestr("")
  if ini:LoadFromFile() then
    phone_number = ini:ReadString(nx_widestr("ChargePhone"), nx_widestr("phone"), nx_widestr(""))
  end
  nx_destroy(ini)
  return phone_number
end
