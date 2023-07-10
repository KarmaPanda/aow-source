require("utils")
require("util_gui")
require("util_functions")
require("util_vip")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  set_form_pos(form)
  form.show = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Faculty", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("HoldFaculty", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveSpeedPower", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_1", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_2", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_3", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_4", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_5", "int", form, nx_current(), "prop_callback_refresh")
  end
  refresh_form(form)
  form.show = true
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return 1
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local faculty = player:QueryProp("Faculty")
  local hold_faculty = player:QueryProp("HoldFaculty")
  local speed_power = player:QueryProp("LiveSpeedPower")
  local livepoint = player:QueryProp("LiveGroove_1") + player:QueryProp("LiveGroove_2") + player:QueryProp("LiveGroove_3") + player:QueryProp("LiveGroove_4") + player:QueryProp("LiveGroove_5")
  form.mltbox_livepoint.Left = (form.Width - form.mltbox_livepoint.Width) / 2
  form.mltbox_livepoint.Top = form.pbar_livepoint.Top + form.pbar_livepoint.Height / 2
  form.mltbox_livepoint.Visible = false
  form.mltbox_holdfaculty.Left = (form.Width - form.mltbox_holdfaculty.Width) / 2
  form.mltbox_holdfaculty.Top = form.btn_holdfaculty.Top + form.btn_holdfaculty.Height / 2 - form.mltbox_holdfaculty.Height
  form.mltbox_holdfaculty.Visible = false
  form.mltbox_faculty.Left = (form.Width - form.mltbox_faculty.Width) / 2
  form.mltbox_faculty.Top = form.btn_faculty.Top + form.btn_faculty.Height / 2 - form.mltbox_faculty.Height
  form.mltbox_faculty.Visible = false
  form.pbar_livepoint.Maximum = 999
  form.pbar_livepoint.Value = livepoint / 1000
  local livepointText = nx_int(livepoint / 1000)
  form.lbl_lilian_num.Text = nx_widestr(nx_string(livepointText) .. "/999")
  for i = 1, 5 do
    local pbar = form:Find("pbar_livegroove_" .. nx_string(i))
    if nx_is_valid(pbar) then
      local livegroove = player:QueryProp("LiveGroove_" .. nx_string(i))
      pbar.Maximum = 999
      pbar.Value = livegroove / 1000
    end
  end
  local is_vip = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  local speed = 0
  if player:QueryProp("LiveGroove_1") > 0 then
    speed = speed + 10
  end
  if player:QueryProp("LiveGroove_2") > 0 then
    speed = speed + 20
  end
  if player:QueryProp("LiveGroove_3") > 0 then
    speed = speed + 50
  end
  if player:QueryProp("LiveGroove_4") > 0 then
    speed = speed + 100
  end
  if player:QueryProp("LiveGroove_5") > 0 then
    speed = speed + 200
  end
  local power = player:QueryProp("LiveSpeedPower")
  if nx_int(power) > nx_int(0) then
    speed = speed + speed * power / 100
  end
  if not is_vip then
    speed = nx_number(nx_int(speed * 0.7))
  end
  nx_set_value("lilanspeed", speed)
  nx_set_value("faculty", faculty)
  nx_set_value("hold_faculty", hold_faculty)
end
function prop_callback_refresh(form, PropName, PropType, Value)
  if not nx_is_valid(form) then
    return 1
  end
  if form.show == true then
    refresh_form(form)
  end
  return 1
end
function on_btn_colse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_seevipinfo_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  util_show_form("form_stage_main\\form_vip_info", true)
end
function on_btn_convert_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_wuxue\\form_holdfaculty_buy")
end
function on_btn_return_click(self)
  local form_wuxue = util_get_form("form_stage_main\\form_wuxue\\form_wuxue", false)
  if not nx_is_valid(form_wuxue) then
    return
  end
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue", "on_btn_wuxue_info_click", form_wuxue.btn_wuxue_info)
end
function on_btn_lilian_help_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_livepoint.Visible = true
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_lilian_help_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_livepoint.Visible = false
end
function on_btn_holdfaculty_help_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_holdfaculty.Visible = true
end
function on_btn_holdfaculty_help_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_holdfaculty.Visible = false
end
function on_btn_faculty_help_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_faculty.Visible = true
end
function on_btn_faculty_help_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_faculty.Visible = false
end
function on_pbar_livepoint_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local speed = nx_value("lilanspeed")
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("ui_faculty_turnspeed", nx_int(speed))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.pbar_livepoint.AbsLeft + 20, form.pbar_livepoint.AbsTop)
end
function on_pbar_livepoint_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip")
end
function on_btn_faculty_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local faculty = nx_value("faculty")
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("ui_faculty_facultyvalue", nx_int(faculty))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.btn_faculty.AbsLeft, form.btn_faculty.AbsTop)
end
function on_btn_faculty_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip")
end
function on_btn_holdfaculty_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local hold_faculty = nx_value("hold_faculty")
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("ui_faculty_holdvalue", nx_int(hold_faculty))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.btn_holdfaculty.AbsLeft, form.btn_holdfaculty.AbsTop)
end
function on_btn_holdfaculty_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip")
end
function on_btn_lilian_help_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_pbar_livegroove_1_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local livepoint = player:QueryProp("LiveGroove_1")
  local speed = 0
  if player:QueryProp("LiveGroove_1") > 0 then
    speed = 10
  end
  local power = player:QueryProp("LiveSpeedPower")
  if nx_int(power) > nx_int(0) then
    speed = speed + speed * power / 100
  end
  local is_vip = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if not is_vip then
    speed = nx_number(nx_int(speed * 0.7))
  end
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("tips_faculty_livegroove_1", nx_int(livepoint / 1000), nx_int(speed))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.pbar_livegroove_1.AbsLeft + 20, form.pbar_livegroove_1.AbsTop)
end
function on_pbar_livegroove_2_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local livepoint = player:QueryProp("LiveGroove_2")
  local speed = 0
  if player:QueryProp("LiveGroove_2") > 0 then
    speed = 20
  end
  local power = player:QueryProp("LiveSpeedPower")
  if nx_int(power) > nx_int(0) then
    speed = speed + speed * power / 100
  end
  local is_vip = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if not is_vip then
    speed = nx_number(nx_int(speed * 0.7))
  end
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("tips_faculty_livegroove_2", nx_int(livepoint / 1000), nx_int(speed))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.pbar_livegroove_2.AbsLeft + 20, form.pbar_livegroove_2.AbsTop)
end
function on_pbar_livegroove_3_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local livepoint = player:QueryProp("LiveGroove_3")
  local speed = 0
  if player:QueryProp("LiveGroove_3") > 0 then
    speed = 50
  end
  local power = player:QueryProp("LiveSpeedPower")
  if nx_int(power) > nx_int(0) then
    speed = speed + speed * power / 100
  end
  local is_vip = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if not is_vip then
    speed = nx_number(nx_int(speed * 0.7))
  end
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("tips_faculty_livegroove_3", nx_int(livepoint / 1000), nx_int(speed))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.pbar_livegroove_3.AbsLeft + 20, form.pbar_livegroove_3.AbsTop)
end
function on_pbar_livegroove_4_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local livepoint = player:QueryProp("LiveGroove_4")
  local speed = 0
  if player:QueryProp("LiveGroove_4") > 0 then
    speed = 100
  end
  local power = player:QueryProp("LiveSpeedPower")
  if nx_int(power) > nx_int(0) then
    speed = speed + speed * power / 100
  end
  local is_vip = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if not is_vip then
    speed = nx_number(nx_int(speed * 0.7))
  end
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("tips_faculty_livegroove_4", nx_int(livepoint / 1000), nx_int(speed))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.pbar_livegroove_4.AbsLeft + 20, form.pbar_livegroove_4.AbsTop)
end
function on_pbar_livegroove_5_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local livepoint = player:QueryProp("LiveGroove_5")
  local speed = 0
  if player:QueryProp("LiveGroove_5") > 0 then
    speed = 200
  end
  local power = player:QueryProp("LiveSpeedPower")
  if nx_int(power) > nx_int(0) then
    speed = speed + speed * power / 100
  end
  local is_vip = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if not is_vip then
    speed = nx_number(nx_int(speed * 0.7))
  end
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("tips_faculty_livegroove_5", nx_int(livepoint / 1000), nx_int(speed))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.pbar_livegroove_5.AbsLeft + 20, form.pbar_livegroove_5.AbsTop)
end
