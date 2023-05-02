require("util_gui")
require("util_functions")
require("define\\request_type")
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(self)
  self.redit_remark.Focus = true
  local max_neigonglevel = get_neigong_level()
  for i = 2, max_neigonglevel do
    self.combobox_neigong.DropListBox:AddString(nx_widestr(util_text("ui_shixiong_" .. i)))
  end
  self.combobox_neigong.Text = nx_widestr(util_text("ui_shixiong_2"))
  self.max_neigonglevel = max_neigonglevel
  self.neigong_level = 2
  self.btn_ok.Enabled = false
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_combobox_neigong_selected(combox)
  local form = combox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local max_neigonglevel = form.max_neigonglevel
  for i = 2, max_neigonglevel do
    if nx_widestr(util_text("ui_shixiong_" .. i)) == nx_widestr(combox.Text) then
      form.neigong_level = i
    end
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if form.redit_remark.Size - 1 > 20 then
    local systemcenterinfo = nx_value("SystemCenterInfo")
    if nx_is_valid(systemcenterinfo) then
      systemcenterinfo:ShowSystemCenterInfo(nx_widestr(util_text("ui_shitu_beizhu")), 2)
    end
    form:Close()
    return
  end
  if form.rbtn_jingmai.Checked then
    nx_execute("custom_sender", "custom_teacher_pupil", 1, 2, nx_widestr(form.redit_remark.Text))
  else
    nx_execute("custom_sender", "custom_teacher_pupil", 1, 1, nx_widestr(form.redit_remark.Text), form.neigong_level)
  end
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_jingmai_click(btn)
  btn.ParentForm.btn_ok.Enabled = true
end
function on_rbtn_neigong_click(btn)
  btn.ParentForm.btn_ok.Enabled = true
end
function get_neigong_level()
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\teacherpupil.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string("BaseConfig"))
  if index < 0 then
    return 0
  end
  local nOpenNeiGong = ini:ReadInteger(index, "OpenNeiGong", 0)
  return nOpenNeiGong
end
