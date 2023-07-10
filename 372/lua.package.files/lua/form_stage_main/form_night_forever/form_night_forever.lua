require("util_gui")
require("util_functions")
require("share\\view_define")
require("util_static_data")
FORM_NIGHT_FOREVER = "form_stage_main\\form_night_forever\\form_night_forever"
FORM_ACHIEVEMENT = "form_stage_main\\form_night_forever\\form_achievement"
FORM_NIGHT_FOREVER_EIGHTSCHOOL = "form_stage_main\\form_night_forever\\form_night_forever_eightschool"
FORM_NIGHT_FOREVER_STORY = "form_stage_main\\form_night_forever\\form_story"
local ST_FUNCTION_NEW_GHOSTCITY = 1087
sub_form_talbe = {
  [2] = "form_stage_main\\form_night_forever\\form_story",
  [3] = "form_stage_main\\form_night_forever\\form_night_forever_eightschool",
  [4] = "form_stage_main\\form_night_forever\\form_five_sky",
  [5] = "form_stage_main\\form_night_forever\\form_fin_main",
  [7] = "form_stage_main\\form_attribute_mall\\form_attribute_shop_night",
  [8] = "form_stage_main\\form_night_forever\\form_ghost_city"
}
function open_form()
  util_auto_show_hide_form(FORM_NIGHT_FOREVER)
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.rbtn_1.Checked = true
  self.form_more = nil
  self.gb_more.Visible = false
  fix_width()
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GHOSTCITY) then
      self.rbtn_8.Visible = true
    else
      self.rbtn_8.Visible = false
    end
  end
end
function on_main_form_close(self)
  hide_more()
  nx_destroy(self)
end
function show_more(form_more)
  local form = nx_execute("util_gui", "util_get_form", FORM_NIGHT_FOREVER, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.gb_more.Width = form_more.Width
  form.gb_more:Add(form_more)
  form_more.Left = 0
  form_more.Top = 0
  form.form_more = form_more
  form.gb_more.Visible = true
  fix_width()
end
function hide_more()
  local form = nx_execute("util_gui", "util_get_form", FORM_NIGHT_FOREVER, false, false)
  if not nx_is_valid(form) then
    return
  end
  if form.form_more ~= nil and nx_is_valid(form.form_more) then
    form.form_more:Close()
  end
  form.form_more = nil
  form.gb_more.Visible = false
  fix_width()
end
function fix_width()
  local form = nx_execute("util_gui", "util_get_form", FORM_NIGHT_FOREVER, false, false)
  if not nx_is_valid(form) then
    return
  end
  if form.gb_more.Visible then
    form.Width = form.lbl_1.Width + form.gb_more.Width
  else
    form.Width = form.lbl_1.Width
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_checked_changed(ctrl)
  local form = ctrl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if ctrl.Checked then
    if nx_int(ctrl.DataSource) == nx_int(1) then
      if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
        form.sub_form:Close()
        form.sub_form = nil
      end
      form.groupbox_main_info.Visible = true
    else
      form.groupbox_main_info.Visible = false
      local form_sub = nx_execute("util_gui", "util_get_form", sub_form_talbe[nx_number(ctrl.DataSource)], true, false)
      if not nx_is_valid(form_sub) then
        return
      end
      add_sub_form(form_sub)
    end
    form.lbl_achievement.Text = gui.TextManager:GetFormatText("ui_nf_" .. nx_string(ctrl.DataSource))
  end
end
function add_sub_form(sub_scene)
  if not nx_is_valid(sub_scene) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NIGHT_FOREVER, true, false)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    form.Visible = true
  end
  form:Show()
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    if nx_string(form.sub_form.Name) == nx_string(sub_scene.Name) then
      return
    end
    form.sub_form:Close()
    form.sub_form = nil
  end
  form.groupbox_main_info.Visible = false
  form.groupbox_child_page:Add(sub_scene)
  form.sub_form = sub_scene
  sub_scene.Top = 0
  sub_scene.Left = 0
  sub_scene.Visible = true
end
function open_nf_sub_form(sub_index)
  local form = nx_execute("util_gui", "util_get_form", FORM_NIGHT_FOREVER, true, false)
  if not nx_is_valid(form) then
    return nx_null()
  end
  form.Visible = true
  form:Show()
  local rbtn_name = "rbtn_" .. nx_string(sub_index)
  if nx_find_custom(form, rbtn_name) then
    local rbtn_selected = nx_custom(form, rbtn_name)
    if nx_is_valid(rbtn_selected) then
      rbtn_selected.Checked = true
    end
  end
  return form
end
function get_nf_sub_form(sub_name)
  local form = nx_execute("util_gui", "util_get_form", FORM_NIGHT_FOREVER, true, false)
  if not nx_is_valid(form) then
    return nx_null()
  end
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) and nx_string(form.sub_form.Name) == nx_string(sub_name) then
    return form.sub_form
  end
  return nx_null()
end
