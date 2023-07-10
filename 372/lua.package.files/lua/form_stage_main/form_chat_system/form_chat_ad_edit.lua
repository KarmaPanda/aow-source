require("utils")
require("util_gui")
require("util_functions")
local FORM_CHAT_AD_EDIT = "form_stage_main\\form_chat_system\\form_chat_ad_edit"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "chat_ad_edit_return", "cancel", nx_widestr(""))
  form:Close()
end
function on_btnOk_click(btn)
  local form = btn.ParentForm
  local key_table = {}
  if str_trim(form.ipt_Key1.Text) ~= "" then
    local count = table.getn(key_table)
    key_table[count + 1] = nx_widestr(form.ipt_Key1.Text)
  end
  if str_trim(form.ipt_Key2.Text) ~= "" then
    local count = table.getn(key_table)
    key_table[count + 1] = nx_widestr(form.ipt_Key2.Text)
  end
  if str_trim(form.ipt_Key3.Text) ~= "" then
    local count = table.getn(key_table)
    key_table[count + 1] = nx_widestr(form.ipt_Key3.Text)
  end
  if str_trim(form.ipt_Key4.Text) ~= "" then
    local count = table.getn(key_table)
    key_table[count + 1] = nx_widestr(form.ipt_Key4.Text)
  end
  if str_trim(form.ipt_Key5.Text) ~= "" then
    local count = table.getn(key_table)
    key_table[count + 1] = nx_widestr(form.ipt_Key5.Text)
  end
  local szKeys = nx_widestr("")
  local nCount = table.getn(key_table)
  for i = 1, nCount do
    szKeys = szKeys .. key_table[i]
    if i < nCount then
      szKeys = szKeys .. nx_widestr(",")
    end
  end
  nx_gen_event(form, "chat_ad_edit_return", "ok", szKeys)
  form:Close()
end
function on_btnCancel_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "chat_ad_edit_return", "cancel", nx_widestr(""))
  form:Close()
end
function on_ipt_Key_changed(ipt)
  local content = nx_widestr(ipt.Text)
  local filters = {",", " "}
  for i = 1, table.getn(filters) do
    local mytable = util_split_wstring(content, filters[i])
    content = nx_widestr("")
    for j = 1, table.getn(mytable) do
      content = content .. nx_widestr(mytable[j])
    end
  end
  ipt.Text = nx_widestr(content)
  ipt.InputPos = nx_ws_length(ipt.Text)
end
function load_ad_keys(key_index, szKeys)
  local form = nx_value(FORM_CHAT_AD_EDIT)
  if not nx_is_valid(form) then
    return
  end
  form.key_index = nx_int(index)
  local key_table = util_split_wstring(szKeys, ",")
  for i = 1, table.getn(key_table) do
    local control = nx_custom(form, "ipt_Key" .. i)
    if nx_is_valid(control) then
      control.Text = nx_widestr(key_table[i])
    end
  end
end
function str_trim(str)
  str = nx_string(str)
  str = string.gsub(str, " ", "")
  str = string.gsub(str, "\161\161", "")
  str = string.gsub(str, "\t", "")
  return str
end
function change_form_size()
  local form = nx_value(FORM_CHAT_AD_EDIT)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
