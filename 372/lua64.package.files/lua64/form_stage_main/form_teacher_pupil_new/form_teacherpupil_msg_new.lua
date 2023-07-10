require("util_gui")
require("util_functions")
require("form_stage_main\\form_teacher_pupil_new\\teacherpupil_define_new")
require("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_func_new")
function open_form()
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "custom_open_limite_form", nx_int(4))
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_rbtn_index_info(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  if nx_string(rbtn.Name) == "rbtn_1" then
    form.mltbox_info.HtmlText = util_text("ui_shitu_09")
    return
  elseif nx_string(rbtn.Name) == "rbtn_2" then
    form.mltbox_info.HtmlText = util_text("ui_shitu_07")
    return
  elseif nx_string(rbtn.Name) == "rbtn_3" then
    form.mltbox_info.HtmlText = util_text("ui_shitu_08")
    return
  elseif nx_string(rbtn.Name) == "rbtn_9" then
    form.mltbox_info.HtmlText = util_text("ui_nstprize")
    return
  end
  if nx_find_custom(rbtn, "subform_id") then
    show_page(form, rbtn.subform_id)
  end
end
function open_subform(form, subform_path, subform_id)
  local subform = nx_value(subform_path)
  if not nx_is_valid(subform) then
    subform = nx_execute("util_gui", "util_get_form", subform_path, true, false)
    if not nx_is_valid(subform) then
      return
    end
  elseif subform.Visible == true then
    return
  end
  subform.Left = form.groupbox_msginfo.Left
  subform.Top = form.groupbox_msginfo.Top
  subform.subform_id = subform_id
  local is_load = form:Add(subform)
  if not is_load then
    return
  end
  form.groupbox_1.Visible = false
  subform.Visible = true
  subform:Show()
end
function close_subform(subform_path)
  local subform = nx_value(subform_path)
  if not nx_is_valid(subform) then
    return
  end
  subform.Visible = false
  subform:Close()
end
function cloase_register_form()
  close_subform(FORM_REGISTER_NEW)
end
function close_teacherpupil_form()
  close_subform(FORM_MY_TEACHER_NEW)
end
function close_teacherpupil_shop_form()
  close_subform(FORM_SHOP_NEW)
end
function show_page(form, subform_id)
  if nx_int(SUB_FORM_PUPIL_REGISTER) ~= nx_int(subform_id) or nx_int(SUB_FORM_TEACHER_REGISTER) ~= nx_int(subform_id) then
    cloase_register_form()
  end
  if nx_int(SUB_FORM_MY_TEACHER) ~= nx_int(subform_id) and nx_int(SUB_FORM_MY_PUPIL) ~= nx_int(subform_id) then
    close_teacherpupil_form()
  end
  if nx_int(SUB_FORM_SHOP) ~= nx_int(subform_id) then
    close_teacherpupil_shop_form()
  end
  if nx_int(SUB_FORM_MAIN) == nx_int(subform_id) then
    form.groupbox_1.Visible = true
  elseif nx_int(SUB_FORM_PUPIL_REGISTER) == nx_int(subform_id) or nx_int(SUB_FORM_TEACHER_REGISTER) == nx_int(subform_id) then
    open_subform(form, FORM_REGISTER_NEW, subform_id)
  elseif nx_int(SUB_FORM_MY_TEACHER) == nx_int(subform_id) or nx_int(SUB_FORM_MY_PUPIL) == nx_int(subform_id) then
    open_subform(form, FORM_MY_TEACHER_NEW, subform_id)
  elseif nx_int(SUB_FORM_SHOP) == nx_int(subform_id) then
    open_subform(form, FORM_SHOP_NEW, subform_id)
  end
  if nx_int(SUB_FORM_MAIN) == nx_int(subform_id) then
    form.groupbox_msginfo.Visible = true
  else
    form.groupbox_msginfo.Visible = false
  end
end
function show_main_page()
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_8.Checked = true
  show_page(form, SUB_FORM_MAIN)
end
function show_main_reg_shixiong_page()
  open_form()
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_4.Checked = true
end
function init_rbtn_index_info(form)
  if not nx_is_valid(form) then
    return false
  end
  form.rbtn_4.subform_id = SUB_FORM_TEACHER_REGISTER
  form.rbtn_5.subform_id = SUB_FORM_PUPIL_REGISTER
  set_shixiongdi_rbtn_index(form.rbtn_6)
  form.rbtn_7.subform_id = SUB_FORM_SHOP
  return true
end
function set_shixiongdi_rbtn_index(rbtn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local rbtn_name = ""
  local shitu_flag = get_shitu_flag()
  rbtn.Enabled = true
  if nx_int(shitu_flag) == nx_int(0) then
    rbtn_name = gui.TextManager:GetFormatText("ui_shituwu_001")
    rbtn.Text = nx_widestr(rbtn_name)
    rbtn.subform_id = SUB_FORM_NOTHING
    rbtn.Enabled = false
  end
  if nx_int(shitu_flag) == nx_int(Senior_fellow_apprentice) then
    rbtn_name = gui.TextManager:GetFormatText("ui_wodeshidi")
    rbtn.Text = nx_widestr(rbtn_name)
    rbtn.subform_id = SUB_FORM_MY_PUPIL
  end
  if nx_int(shitu_flag) == nx_int(Junior_fellow_apprentice) then
    rbtn_name = gui.TextManager:GetFormatText("ui_wodeshixiong")
    rbtn.Text = nx_widestr(rbtn_name)
    rbtn.subform_id = SUB_FORM_MY_TEACHER
  end
  return true
end
function close_form()
  local form = nx_value("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_msg_new")
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_teacher_pupil_form()
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
