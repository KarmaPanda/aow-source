require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("share\\static_data_type")
require("form_stage_main\\switch\\switch_define")
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_SHIJIA_UI) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local form = nx_value("form_stage_main\\form_shijia\\form_shijia_guide")
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form("form_stage_main\\form_shijia\\form_shijia_guide", true)
  end
end
function on_main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local groupbox = self.groupbox_all
  local form_info = util_get_form("form_stage_main\\form_shijia\\form_shijia_info", true, false)
  if nx_is_valid(form_info) then
    form_info.Left = 0
    form_info.Top = 0
    groupbox:Add(form_info)
    self.form_info = form_info
  end
  local form_detail = util_get_form("form_stage_main\\form_shijia\\form_shijia_detail", true, false)
  if nx_is_valid(form_detail) then
    form_detail.Left = 0
    form_detail.Top = 0
    groupbox:Add(form_detail)
    self.form_detail = form_detail
  end
  local form_play = util_get_form("form_stage_main\\form_shijia\\form_shijia_play", true, false)
  if nx_is_valid(form_play) then
    form_play.Left = 0
    form_play.Top = 0
    groupbox:Add(form_play)
    self.form_play = form_play
  end
  local form_achieve = util_get_form("form_stage_main\\form_shijia\\form_shijia_achievement", true, false)
  if nx_is_valid(form_achieve) then
    form_achieve.Left = 0
    form_achieve.Top = 0
    groupbox:Add(form_achieve)
    self.form_achieve = form_achieve
  end
  local form_origin = util_get_form("form_stage_main\\form_shijia\\form_shijia_origin", true, false)
  if nx_is_valid(form_origin) then
    form_origin.Left = 0
    form_origin.Top = 0
    groupbox:Add(form_origin)
    self.form_origin = form_origin
  end
  local form_task = util_get_form("form_stage_main\\form_shijia\\form_shijia_task", true, false)
  if nx_is_valid(form_task) then
    form_task.Left = 0
    form_task.Top = 0
    groupbox:Add(form_task)
    self.form_task = form_task
  end
  self.rbtn_info.Checked = true
end
function on_main_form_close(self)
  if nx_find_custom(self, "form_info") and nx_is_valid(self.form_info) then
    self.form_info:Close()
  end
  if nx_find_custom(self, "form_detail") and nx_is_valid(self.form_detail) then
    self.form_detail:Close()
  end
  if nx_find_custom(self, "form_play") and nx_is_valid(self.form_play) then
    self.form_play:Close()
  end
  if nx_find_custom(self, "form_achieve") and nx_is_valid(self.form_achieve) then
    self.form_achieve:Close()
  end
  if nx_find_custom(self, "form_origin") and nx_is_valid(self.form_origin) then
    self.form_origin:Close()
  end
  if nx_find_custom(self, "form_task") and nx_is_valid(self.form_task) then
    self.form_task:Close()
  end
  nx_destroy(self)
end
function on_rbtn_checked_changed(self)
  local form = self.ParentForm
  if form.rbtn_info.Checked and nx_id_equal(self, form.rbtn_info) then
    form.form_info.Visible = true
    form.form_detail.Visible = false
    form.form_play.Visible = false
    form.form_achieve.Visible = false
    form.form_origin.Visible = false
    form.form_task.Visible = false
  elseif form.rbtn_detail.Checked and nx_id_equal(self, form.rbtn_detail) then
    form.form_info.Visible = false
    form.form_detail.Visible = true
    form.form_play.Visible = false
    form.form_achieve.Visible = false
    form.form_origin.Visible = false
    form.form_task.Visible = false
  elseif form.rbtn_play.Checked and nx_id_equal(self, form.rbtn_play) then
    form.form_info.Visible = false
    form.form_detail.Visible = false
    form.form_play.Visible = true
    form.form_achieve.Visible = false
    form.form_origin.Visible = false
    form.form_task.Visible = false
    nx_execute("custom_sender", "custom_shijia_trains", nx_int(1), nx_int(0))
    local form_play = form.form_play
    if nx_is_valid(form_play) then
      local rbtn = form_play.select_rbtn
      if nx_is_valid(rbtn) then
        rbtn.Checked = true
        nx_execute("form_stage_main\\form_shijia\\form_shijia_play", "on_rbtn_checked_changed", rbtn)
      end
    end
  elseif form.rbtn_achieve.Checked and nx_id_equal(self, form.rbtn_achieve) then
    form.form_info.Visible = false
    form.form_detail.Visible = false
    form.form_play.Visible = false
    form.form_achieve.Visible = true
    form.form_origin.Visible = false
    form.form_task.Visible = false
    local form_achievement = form.form_achieve
    if nx_is_valid(form_achievement) then
      local tree = form_achievement.tree_ex1
      local select_node = form_achievement.node
      if nx_is_valid(tree) and nx_is_valid(select_node) then
        nx_execute("form_stage_main\\form_shijia\\form_shijia_achievement", "on_tree_ex1_select_changed", tree, select_node)
      end
    end
  elseif form.rbtn_origin.Checked and nx_id_equal(self, form.rbtn_origin) then
    form.form_info.Visible = false
    form.form_detail.Visible = false
    form.form_play.Visible = false
    form.form_achieve.Visible = false
    form.form_origin.Visible = true
    form.form_task.Visible = false
  elseif form.rbtn_task.Checked and nx_id_equal(self, form.rbtn_task) then
    form.form_info.Visible = false
    form.form_detail.Visible = false
    form.form_play.Visible = false
    form.form_achieve.Visible = false
    form.form_origin.Visible = false
    form.form_task.Visible = true
  end
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
end
