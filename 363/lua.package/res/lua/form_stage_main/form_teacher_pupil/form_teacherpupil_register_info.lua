require("util_gui")
require("util_functions")
require("define\\request_type")
require("form_stage_main\\form_teacher_pupil\\teacherpupil_define")
function on_main_form_init(form)
  form.Fixed = false
  form.shitu_flag = 0
end
function on_main_form_open(self)
  self.redit_remark.Focus = true
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local cur_main_game_step = switch_manager:GetMainGameStep()
  local max_neigonglevel = get_neigong_level()
  if nx_int(max_neigonglevel) > nx_int(cur_main_game_step) then
    max_neigonglevel = cur_main_game_step
  end
  for i = 2, max_neigonglevel do
    if nx_int(self.shitu_flag) == nx_int(Senior_fellow_apprentice) then
      self.combobox_neigong.DropListBox:AddString(nx_widestr(util_text("ui_shixiong_" .. i)))
    else
      self.combobox_neigong.DropListBox:AddString(nx_widestr(util_text("ui_shidi_" .. i)))
    end
  end
  if nx_int(self.shitu_flag) == nx_int(Senior_fellow_apprentice) then
    self.combobox_neigong.Text = nx_widestr(util_text("ui_shixiong_2"))
  else
    self.combobox_neigong.Text = nx_widestr(util_text("ui_shidi_2"))
  end
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
  for i = 2, form.max_neigonglevel do
    if nx_int(form.shitu_flag) == nx_int(Senior_fellow_apprentice) then
      if nx_widestr(util_text("ui_shixiong_" .. i)) == nx_widestr(combox.Text) then
        form.neigong_level = i
      end
    elseif nx_widestr(util_text("ui_shidi_" .. i)) == nx_widestr(combox.Text) then
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
    nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_REGISTER, form.shitu_flag, ShiTuType_JingMai, nx_widestr(form.redit_remark.Text))
  else
    nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_REGISTER, form.shitu_flag, ShiTuType_NeiGong, form.neigong_level, nx_widestr(form.redit_remark.Text))
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
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\shitu\\teacherpupil.ini")
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
