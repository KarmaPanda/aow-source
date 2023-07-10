require("form_stage_main\\form_wuxue\\form_wuxue_util")
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(form)
  form.Fixed = false
  form.FirstInflag = true
  form.cur_index = nil
  return 1
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Faculty", "int", form, FORM_WUXUE_MAIN, "prop_callback_faculty")
    databinder:AddRolePropertyBind("HuiPoint", "int", form, FORM_WUXUE_MAIN, "prop_callback_huipoint")
    databinder:AddRolePropertyBind("MaxHuiPoint", "int", form, FORM_WUXUE_MAIN, "prop_callback_huipoint")
  end
  if form.FirstInflag then
    load_all_sub_page(form)
    local faculty_form = util_get_form("form_stage_main\\form_wuxue\\form_faculty", true, false)
    if form:Add(faculty_form) then
      form.faculty_form = faculty_form
      form.faculty_form.Visible = false
      form.faculty_form.Fixed = true
      form.faculty_form.Left = 58
      form.faculty_form.Top = 44
    end
    local new_wuji_form = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", true, false)
    if form.groupbox_wuji:Add(new_wuji_form) then
      form.new_wuji_form = new_wuji_form
      form.new_wuji_form.Visible = false
      form.new_wuji_form.Fixed = true
      form.new_wuji_form.Left = 0
      form.new_wuji_form.Top = 0
    end
    form.FirstInflag = false
  end
  set_form_pos(form)
  set_radio_btns()
  switch_sub_page(WUXUE_SKILL)
  on_btn_wuxue_info_click(form.btn_wuxue_info)
  form.lbl_bg_2.Visible = false
  change_wuxue_btn(false)
  return 1
end
function on_main_form_close(form)
  local is_help = nx_custom(form, "is_help")
  if is_help == nil or is_help == false then
    form.Visible = false
  else
    form.is_help = false
    form.Visible = false
    nx_execute("form_stage_main\\form_helper\\form_move_win", "util_open_move_win", form.AbsLeft, form.AbsTop, form.Width, form.Height, "", "open_form_wuxue,btn_zhaoshi")
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("Faculty", form)
    databinder:DelRolePropertyBind("HuiPoint", form)
    databinder:DelRolePropertyBind("MaxHuiPoint", form)
  end
  free_all_sub_page(form)
  if nx_is_valid(form.faculty_form) then
    form.faculty_form:Close()
  end
  nx_execute("tips_game", "hide_tip")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "hide_skill_yu_xaun_gbox")
  nx_destroy(form)
end
function reset_scene()
  return
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    local is_help = nx_custom(form, "is_help")
    if is_help == true then
      form.is_help = false
      nx_execute("form_stage_main\\form_helper\\form_move_win", "util_open_move_win", form.AbsLeft, form.AbsTop, form.Width, form.Height, "", "open_form_wuxue,btn_zhaoshi")
    end
    form:Close()
  end
end
function on_rbtn_wuxue_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if self.Checked then
    self.ForeColor = FORE_COLOR_SELECT
    switch_sub_page(nx_number(self.DataSource))
  else
    self.ForeColor = FORE_COLOR_NORMAL
  end
end
function on_rbtn_skill_checked_changed(self)
  if not self.Checked then
    return 0
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_index ~= WUXUE_SKILL then
    return false
  end
  local child = form.subpage_array:GetChild(nx_string(WUXUE_SKILL))
  if not (nx_is_valid(child) and nx_is_valid(child.form)) or not nx_is_valid(child.rbtn) then
    return false
  end
  local form_wuji_new = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", false, false)
  if not nx_is_valid(form_wuji_new) then
    return false
  end
  if nx_number(self.DataSource) == 1 then
    child.form.gbox_list.Visible = true
    child.form.gbox_info.Visible = true
    child.form.gbox_forget_list.Visible = false
    child.form.gbox_forget_info.Visible = false
    form.lbl_bg_2.Visible = false
    if nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene") or nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene") or nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "is_in_luandou_scene") then
      form_wuji_new.Visible = false
    else
      form_wuji_new.Visible = true
    end
  else
    child.form.gbox_list.Visible = false
    child.form.gbox_info.Visible = false
    child.form.gbox_forget_list.Visible = true
    child.form.gbox_forget_info.Visible = true
    form.lbl_bg_2.Visible = true
    form_wuji_new.Visible = false
  end
end
function on_btn_wuxue_info_click(self)
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.faculty_form) then
    return
  end
  form.faculty_form.Visible = false
  set_radio_btns()
  show_wuxue_info(form, true)
  form.btn_wuxue_info.Visible = false
  form.btn_faculty_info.Visible = true
  if nx_int(form.cur_index) == nx_int(WUXUE_SKILL) then
    form.groupbox_1.Visible = true
    if form.rbtn_skill_1.Checked == true then
      form.lbl_bg_2.Visible = false
    else
      form.lbl_bg_2.Visible = true
    end
    local form_wuji_new = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", false, false)
    if nx_is_valid(form_wuji_new) then
      if form.rbtn_skill_1.Checked == true then
        if nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene") or nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene") or nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "is_in_luandou_scene") then
          form_wuji_new.Visible = false
        else
          form_wuji_new.Visible = true
        end
      else
        form_wuji_new.Visible = false
      end
    end
  end
end
function on_btn_faculty_info_click(self)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local form = self.Parent.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.faculty_form) then
    return
  end
  form.faculty_form.Visible = true
  hide_radio_btns()
  show_wuxue_info(form, false)
  form.btn_wuxue_info.Visible = true
  form.btn_faculty_info.Visible = false
  local form_wuji_new = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", false, false)
  if nx_is_valid(form_wuji_new) then
    form_wuji_new.Visible = false
  end
  form.groupbox_1.Visible = false
  form.lbl_bg_2.Visible = false
end
function prop_callback_faculty(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  form.lbl_faculty.Text = nx_widestr(prop_value)
end
function prop_callback_huipoint(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  local huipoint_cur = nx_number(get_player_prop("HuiPoint"))
  local huipoint_max = nx_number(get_player_prop("MaxHuiPoint"))
  form.lbl_huidian.Text = nx_widestr(huipoint_cur) .. nx_widestr("/") .. nx_widestr(huipoint_max)
  if 0 >= nx_number(huipoint_max) then
    form.gbox_info_1.Visible = false
  else
    form.gbox_info_1.Visible = true
  end
end
function on_btn_help_checked_changed(self)
  util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
  local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
  if nx_is_valid(form_help) then
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "wxsd,wuxuext02,taoluxt03,taoluzc04")
  end
end
function close_form()
  local form = nx_value(FORM_WUXUE_MAIN)
  if nx_is_valid(form) then
    form:Close()
  end
end
