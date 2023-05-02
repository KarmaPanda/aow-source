require("share\\server_custom_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
end
function form_open(btn_tvt)
  if not nx_is_valid(btn_tvt) then
    return
  end
  local form_page_tvt = nx_value("form_stage_main\\form_main\\form_main_page_tvt")
  if not nx_is_valid(form_page_tvt) then
    form_page_tvt = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_page_tvt", true, false)
  end
  form_page_tvt.Visible = true
  local gui = nx_value("gui")
  local width = gui.Desktop.Width
  local height = gui.Desktop.Height
  form_page_tvt.Left = (width - form_page_tvt.Width) / 2
  form_page_tvt.Top = (height - form_page_tvt.Height) / 2
  form_page_tvt:Show()
  local btn_tvt_type
  for i = TIPSTYPE_TVT_JINDI, TIPSTYPE_TVT_YUNBIAO do
    btn_tvt_type = form_page_tvt.groupbox_1:Find("cbtn_" .. nx_string(i))
    if nx_is_valid(btn_tvt_type) then
      local prop_value = nx_custom(btn_tvt, "tvt_type_" .. nx_string(i))
      btn_tvt_type.Checked = nx_custom(btn_tvt, "tvt_type_" .. nx_string(i))
    end
  end
end
function on_btn_no_click(btn)
  local form_tvt = btn.ParentForm
  if nx_is_valid(form_tvt) then
    form_tvt.Visible = false
  end
end
function on_btn_yes_click(btn)
  local form_system = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  if not nx_is_valid(form_system) then
    return
  end
  local form_page_tvt = btn.ParentForm
  local btn_tvt = form_system.btn_tvt
  local btn_tvt_type
  form_system.tvt_list:ShowKeyItems(-1)
  for i = TIPSTYPE_TVT_JINDI, TIPSTYPE_TVT_YUNBIAO do
    btn_tvt_type = form_page_tvt.groupbox_1:Find("cbtn_" .. i)
    if nx_is_valid(btn_tvt_type) then
      local b_btn_checked = btn_tvt_type.Checked
      nx_set_custom(btn_tvt, "tvt_type_" .. i, b_btn_checked)
      if b_btn_checked then
        form_system.tvt_list:ShowKeyItems(i)
      end
    end
  end
  form_system.tvt_list:ShowKeyItems(100)
  form_page_tvt.Visible = false
end
