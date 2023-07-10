function util_open_common(type_info)
  local form = nx_value(nx_current())
  local is_show, text = is_need_remind(type_info)
  if not is_show then
    return false
  end
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return nx_null()
    end
    form.type_info = type_info
    form.mltbox_info.HtmlText = nx_widestr(text)
    form.cbtn_info.Checked = false
    form.event_name = "common_wait_event"
    form:ShowModal()
  end
  form.type_info = type_info
  return true, form
end
function on_main_form_init(self)
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_jump_click(self)
  local form = self.ParentForm
  nx_gen_event(nx_null(), form.event_name, "jump")
  form:Close()
end
function on_btn_activate_click(self)
  nx_function("ext_open_url", "http://anquan.woniu.com")
end
function on_cbtn_info_checked_changed(cbtn)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\form\\common_form_info.ini"
  if not ini:LoadFromFile() then
    ini:SaveToFile()
  end
  local form = cbtn.ParentForm
  ini:WriteString(form.type_info, "show", nx_string(not cbtn.Checked))
  ini:SaveToFile()
  nx_destroy(ini)
end
function is_need_remind(type_info)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\form\\common_form_info.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local value = ini:ReadString(type_info, "show", "false")
  if nx_string(value) == nx_string("false") then
    nx_destroy(ini)
    return false
  else
    local text = ini:ReadString(type_info, "text", "no")
    nx_destroy(ini)
    return true, text
  end
  nx_destroy(ini)
  return false
end
