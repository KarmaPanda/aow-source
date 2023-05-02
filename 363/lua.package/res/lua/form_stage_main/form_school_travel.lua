require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
require("define\\new_note_define")
require("form_stage_main\\switch\\switch_define")
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_SCHOOL_TRAVEL) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local rec_name = "new_note_rec"
  if not player:FindRecord(rec_name) then
    return
  end
  local row_school = -1
  local row_force = -1
  local row_newschool = -1
  row_school = player:FindRecordRow(rec_name, NOTE_COL_TYPE, NEW_NOTE_JOIN_SCHOOL, 0)
  row_force = player:FindRecordRow(rec_name, NOTE_COL_TYPE, NEW_NOTE_JOIN_FORCE, 0)
  row_newschool = player:FindRecordRow(rec_name, NOTE_COL_TYPE, NEW_NOTE_JOIN_NEWSCHOOL, 0)
  if row_school < 0 and row_force < 0 and row_newschool < 0 then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_schoolchange_001")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_school_travel")
end
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.select_school = ""
  return 1
end
function on_main_form_get_capture(self)
  self.groupbox_func.Visible = false
end
function main_form_open(self)
  local form_logic = nx_value("form_school_travel")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_school_travel")
  nx_set_value("form_school_travel", form_logic)
  self.groupbox_func.Visible = false
  self.groupbox_travel.Visible = false
  form_logic:Load()
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("School", "string", self, nx_current(), "on_update_School")
    databinder:AddRolePropertyBind("Force", "string", self, nx_current(), "on_update_Force")
    databinder:AddRolePropertyBind("NewSchool", "string", self, nx_current(), "on_update_NewSchool")
  end
  return 1
end
function main_form_close(self)
  local form_logic = nx_value("form_school_travel")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_destroy(self)
  return 1
end
function on_update_School(form)
  local form_logic = nx_value("form_school_travel")
  if not nx_is_valid(form_logic) then
    return
  end
  local school = form_logic:GetPlayerSchool()
  local desc_id = form_logic:GetSchoolDes(school)
  local text = util_text(desc_id)
  local mltbox = form.mltbox_des
  mltbox:Clear()
  mltbox:AddHtmlText(text, -1)
  form.lbl_ani.BackImage = form_logic:GetSchoolAni(school)
  update_school(form)
end
function on_update_Force(form)
  update_school(form)
end
function on_update_NewSchool(form)
  update_school(form)
end
function update_school(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_school_imp", form)
    timer:Register(100, 1, nx_current(), "update_school_imp", form, -1, -1)
  end
end
function update_school_imp(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "update_school_imp", form)
  local form_logic = nx_value("form_school_travel")
  if nx_is_valid(form_logic) then
    form_logic:Update(form)
  end
end
function on_btn_school_click(self)
  local form = self.ParentForm
  local gbx = form.groupbox_func
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sex = client_player:QueryProp("Sex")
  if sex == 0 then
    if self.DataSource == "school_emei" or self.DataSource == "force_yihua" or self.DataSource == "newschool_shenshui" then
      gbx.Visible = false
      return
    end
  elseif self.DataSource == "school_shaolin" or self.DataSource == "force_wugen" or self.DataSource == "newschool_damo" then
    gbx.Visible = false
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if "newschool_wuxian" == self.DataSource and not switch_manager:CheckSwitchEnable(ST_FUNCTION_WXJ_SCHOOL_TRAVEL) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_02")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  if "newschool_damo" == self.DataSource and not switch_manager:CheckSwitchEnable(ST_FUNCTION_DMP_SCHOOL_TRAVEL) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_03")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  if "school_mingjiao" == self.DataSource and not switch_manager:CheckSwitchEnable(ST_FUNCTION_MINGJIAO) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_04")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  if "school_tianshan" == self.DataSource and not switch_manager:CheckSwitchEnable(ST_FUNCTION_TIANSHAN) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_05")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local form_logic = nx_value("form_school_travel")
  if not nx_is_valid(form_logic) then
    return
  end
  local school = form_logic:GetPlayerSchool()
  if school == self.DataSource then
    return
  end
  if form.select_school == self.DataSource and gbx.Visible then
    gbx.Visible = false
    return
  end
  form.btn_go.Enabled = true
  local school_extinct = nx_value("SchoolExtinct")
  if nx_is_valid(school_extinct) and school_extinct:IsSchoolExtincted(self.DataSource) then
    form.btn_go.Enabled = false
  end
  gbx.Visible = true
  gbx.AbsLeft = self.AbsLeft + self.Width / 3 * 1.5
  gbx.AbsTop = self.AbsTop + self.Height / 3 * 1.5
  form.select_school = self.DataSource
end
function on_btn_go_click(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "select_school") then
    return
  end
  form.groupbox_func.Visible = false
  nx_execute("form_stage_main\\form_school_convert", "show_school", form.select_school)
end
function on_btn_view_click(self)
  local form = self.ParentForm
  local school_name = form.select_school
  nx_execute("form_stage_main\\form_main\\form_school_introduce", "show_school", school_name)
  form.groupbox_func.Visible = false
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_expand_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_travel
  groupbox.Visible = not groupbox.Visible
end
