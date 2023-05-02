require("utils")
require("util_gui")
require("const_define")
require("util_vip")
require("define\\team_rec_define")
require("share\\view_define")
require("custom_sender")
require("define\\shortcut_key_define")
require("form_stage_main\\switch\\switch_define")
require("util_role_prop")
require("tips_data")
require("form_stage_main\\form_tvt\\define")
local TEAM_REC = "team_rec"
local FILE_FORM_MAIN_PLAYER_CFG = "ini\\ui\\newjh\\main_player.ini"
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = true
  self.role_face = nx_null()
  self.bHaveReadOldCfg = false
  return 1
end
function on_main_form_open(self)
  self.no_need_motion_alpha = true
  self.lbl_xwzh.Visible = false
  self.name = ""
  self.origin = ""
  self.pbar_xiu.Maximum = 999
  local group = self.group_pk_state
  group.AbsLeft = self.AbsLeft - group.Width - 4
  self.btn_touxiang.Visible = false
  self.btn_xiulian.Visible = false
  self.pbar_xiu.Visible = false
  self.lbl_lian_fire.Visible = false
  self.lbl_lian_fire2.Visible = false
  self.ani_faculty.Visible = false
  self.ani_jingmai.Visible = false
  self.lbl_frame.Visible = false
  if not self.bHaveReadOldCfg then
    self.old_lbl_back_img = self.lbl_back.BackImage
    self.old_qg_back_img = self.pbar_qinggong.ProgressImage
    self.old_hp_low_img = self.pbar_state_hp.ProgressImage
    self.old_hp_img = self.pbar_hp.ProgressImage
    self.old_hp_resume_img = self.pbar_resume_hp.ProgressImage
    self.old_mp_low_img = self.pbar_state_mp.ProgressImage
    self.old_mp_img = self.pbar_state_mp.ProgressImage
    self.old_lbl_frame_img = self.lbl_frame.BackImage
    self.old_pos_qinggong_x = self.pbar_qinggong.Left
    self.old_pos_qinggong_y = self.pbar_qinggong.Top
    self.old_pos_qinggong_width = self.pbar_qinggong.Width
    self.old_pos_qinggong_height = self.pbar_qinggong.Height
    self.old_pos_lbl_nq1_x = self.lbl_nq1.Left
    self.old_pos_lbl_nq1_y = self.lbl_nq1.Top
    self.old_pos_lbl_nq1_width = self.lbl_nq1.Width
    self.old_pos_lbl_nq1_height = self.lbl_nq1.Height
    self.old_pos_lbl_nq2_x = self.lbl_nq2.Left
    self.old_pos_lbl_nq2_y = self.lbl_nq2.Top
    self.old_pos_lbl_nq2_width = self.lbl_nq2.Width
    self.old_pos_lbl_nq2_height = self.lbl_nq2.Height
    self.old_pos_lbl_nq3_x = self.lbl_nq3.Left
    self.old_pos_lbl_nq3_y = self.lbl_nq3.Top
    self.old_pos_lbl_nq3_width = self.lbl_nq3.Width
    self.old_pos_lbl_nq3_height = self.lbl_nq3.Height
    self.old_pos_lbl_nq4_x = self.lbl_nq4.Left
    self.old_pos_lbl_nq4_y = self.lbl_nq4.Top
    self.old_pos_lbl_nq4_width = self.lbl_nq4.Width
    self.old_pos_lbl_nq4_height = self.lbl_nq4.Height
    self.old_pos_lbl_nq5_x = self.lbl_nq5.Left
    self.old_pos_lbl_nq5_y = self.lbl_nq5.Top
    self.old_pos_lbl_nq5_width = self.lbl_nq5.Width
    self.old_pos_lbl_nq5_height = self.lbl_nq5.Height
    self.old_pos_jingmai_x = self.btn_jingmai.Left
    self.old_pos_jingmai_y = self.btn_jingmai.Top
    self.old_pos_jingmai_width = self.btn_jingmai.Width
    self.old_pos_jingmai_height = self.btn_jingmai.Height
    self.old_pos_jingmai_anim_x = self.ani_jingmai.Left
    self.old_pos_jingmai_anim_y = self.ani_jingmai.Top
    self.old_pos_jingmai_anim_width = self.ani_jingmai.Width
    self.old_pos_jingmai_anim_height = self.ani_jingmai.Height
    self.old_pos_touxiang_x = self.scenebox_1.Left
    self.old_pos_touxiang_y = self.scenebox_1.Top
    self.old_pos_touxiang_width = self.scenebox_1.Width
    self.old_pos_touxiang_height = self.scenebox_1.Height
    self.old_pos_hp_low_x = self.pbar_state_hp.Left
    self.old_pos_hp_low_y = self.pbar_state_hp.Top
    self.old_pos_hp_low_width = self.pbar_state_hp.Width
    self.old_pos_hp_low_height = self.pbar_state_hp.Height
    self.old_pos_hp_x = self.pbar_hp.Left
    self.old_pos_hp_y = self.pbar_hp.Top
    self.old_pos_hp_width = self.pbar_hp.Width
    self.old_pos_hp_height = self.pbar_hp.Height
    self.old_pos_hp_resume_x = self.pbar_resume_hp.Left
    self.old_pos_hp_resume_y = self.pbar_resume_hp.Top
    self.old_pos_hp_resume_width = self.pbar_resume_hp.Width
    self.old_pos_hp_resume_height = self.pbar_resume_hp.Height
    self.old_pos_mp_low_x = self.pbar_state_mp.Left
    self.old_pos_mp_low_y = self.pbar_state_mp.Top
    self.old_pos_mp_low_width = self.pbar_state_mp.Width
    self.old_pos_mp_low_height = self.pbar_state_mp.Height
    self.old_pos_mp_x = self.pbar_mp.Left
    self.old_pos_mp_y = self.pbar_mp.Top
    self.old_pos_mp_width = self.pbar_mp.Width
    self.old_pos_mp_height = self.pbar_mp.Height
    self.old_pos_lbl_frame_x = self.lbl_frame.Left
    self.old_pos_lbl_frame_y = self.lbl_frame.Top
    self.old_pos_lbl_frame_width = self.lbl_frame.Width
    self.old_pos_lbl_frame_height = self.lbl_frame.Height
    self.old_pos_pbar_sp_x = self.pbar_sp.Left
    self.old_pos_pbar_sp_y = self.pbar_sp.Top
    self.old_pos_pbar_sp_width = self.pbar_sp.Width
    self.old_pos_pbar_sp_height = self.pbar_sp.Height
    self.old_pos_lbl_a_nq1_x = self.lbl_a_nq1.Left
    self.old_pos_lbl_a_nq1_y = self.lbl_a_nq1.Top
    self.old_pos_lbl_a_nq1_width = self.lbl_a_nq1.Width
    self.old_pos_lbl_a_nq1_height = self.lbl_a_nq1.Height
    self.old_pos_lbl_a_nq2_x = self.lbl_a_nq2.Left
    self.old_pos_lbl_a_nq2_y = self.lbl_a_nq2.Top
    self.old_pos_lbl_a_nq2_width = self.lbl_a_nq2.Width
    self.old_pos_lbl_a_nq2_height = self.lbl_a_nq2.Height
    self.old_pos_lbl_a_nq3_x = self.lbl_a_nq3.Left
    self.old_pos_lbl_a_nq3_y = self.lbl_a_nq3.Top
    self.old_pos_lbl_a_nq3_width = self.lbl_a_nq3.Width
    self.old_pos_lbl_a_nq3_height = self.lbl_a_nq3.Height
    self.old_pos_lbl_a_nq4_x = self.lbl_a_nq4.Left
    self.old_pos_lbl_a_nq4_y = self.lbl_a_nq4.Top
    self.old_pos_lbl_a_nq4_width = self.lbl_a_nq4.Width
    self.old_pos_lbl_a_nq4_height = self.lbl_a_nq4.Height
    self.old_pos_lbl_a_nq5_x = self.lbl_a_nq5.Left
    self.old_pos_lbl_a_nq5_y = self.lbl_a_nq5.Top
    self.old_pos_lbl_a_nq5_width = self.lbl_a_nq5.Width
    self.old_pos_lbl_a_nq5_height = self.lbl_a_nq5.Height
    self.bHaveReadOldCfg = true
  end
  local client_player = get_player()
  self.pbar_hp.tge_value = 0
  self.pbar_hp.sat_value = 0
  self.pbar_hp.cur_value = 0
  self.pbar_hp.cur_ratio = 0.01
  self.pbar_hp.end_time = 2000
  self.pbar_hp.cur_time = 0
  self.pbar_resume_hp.tge_value = 0
  self.pbar_resume_hp.sat_value = 0
  self.pbar_resume_hp.cur_value = 0
  self.pbar_resume_hp.cur_ratio = 0.01
  self.pbar_resume_hp.cur_stage = 0
  self.pbar_resume_hp.Visible = false
  self.pbar_resume_hp.obj = client_player
  self.pbar_resume_hp.prop = "HP"
  self.pbar_resume_hp.end_time = 2000
  self.pbar_resume_hp.cur_time = 0
  self.pbar_mp.tge_value = 0
  self.pbar_mp.sat_value = 0
  self.pbar_mp.cur_value = 0
  self.pbar_mp.cur_ratio = 0.01
  self.pbar_mp.end_time = 2000
  self.pbar_mp.cur_time = 0
  self.pbar_sat.tge_value = 0
  self.pbar_sat.sat_value = 0
  self.pbar_sat.cur_value = 0
  self.pbar_sat.cur_ratio = 0.01
  self.pbar_sat.end_time = 2000
  self.pbar_sat.cur_time = 0
  self.pbar_ene.tge_value = 0
  self.pbar_ene.sat_value = 0
  self.pbar_ene.cur_value = 0
  self.pbar_ene.cur_ratio = 0.01
  self.pbar_ene.end_time = 2000
  self.pbar_ene.cur_time = 0
  self.lbl_a_nq1.Visible = false
  self.lbl_a_nq2.Visible = false
  self.lbl_a_nq3.Visible = false
  self.lbl_a_nq4.Visible = false
  self.lbl_a_nq5.Visible = false
  self.cbtn_ngpk.Visible = false
  self.lbl_fire_small.Visible = false
  self.lbl_fire_big.Visible = false
  self.groupbox_enthrall.Visible = false
  self.btn_YY.Enabled = false
  self.yy_query_time = 0
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(158) then
    self.btn_YY.Visible = true
  else
    self.btn_YY.Visible = false
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", self, nx_current(), "update_newjh_form_main_player")
    databinder:AddRolePropertyBind("DayActivityValue", "int", self, nx_current(), "check_actreward")
    databinder:AddRolePropertyBind("WeekActivityValue", "int", self, nx_current(), "check_actreward")
    databinder:AddTableBind("ActivityRewardRec", self, nx_current(), "check_actreward")
  end
  local asynor = nx_value("common_execute")
  asynor:AddExecute("HPResumeEx", self, nx_float(0), self.pbar_hp, self.pbar_mp, self.pbar_resume_hp, self.pbar_state_hp, self.pbar_state_mp)
  asynor:AddExecute("HPResumeEx", self, nx_float(0), self.pbar_ene, self.pbar_sat, nx_null(), nx_null(), nx_null())
  refresh_Vip_status(self)
  local form_main_player_logic = nx_value("form_main_player")
  if not nx_is_valid(form_main_player_logic) then
    form_main_player_logic = nx_create("form_main_player")
    nx_set_value("form_main_player", form_main_player_logic)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("UnenthrallTime", "int", self, nx_current(), "on_online_changed")
    databinder:AddRolePropertyBind("Face", "string", self, nx_current(), "on_refresh_role_face")
    databinder:AddRolePropertyBind("Hat", "string", self, nx_current(), "on_refresh_role_face")
    databinder:AddRolePropertyBind("Cloth", "string", self, nx_current(), "on_refresh_role_face")
    databinder:AddRolePropertyBind("Pants", "string", self, nx_current(), "on_refresh_role_face")
    databinder:AddRolePropertyBind("Shoes", "string", self, nx_current(), "on_refresh_role_face")
    databinder:AddRolePropertyBind("Hair", "string", self, nx_current(), "on_refresh_role_face")
    databinder:AddRolePropertyBind("ModifyFace", "string", self, nx_current(), "on_refresh_role_face")
    databinder:AddTableBind("RecvLetterRec", self.btn_3, nx_current(), "on_recv_letter")
    databinder:AddTableBind("RecvLetterRec", self.btn_1, nx_current(), "on_recv_letter")
    databinder:AddRolePropertyBind("NetBarRight", "int", self, nx_current(), "on_netbar_right_changed")
    databinder:AddRolePropertyBind("SnDaNetBarRight", "int", self, nx_current(), "on_netbar_right_changed")
    databinder:AddTableBind("vip_info_rec", self, nx_current(), "on_vip_info_rec_change")
    databinder:AddRolePropertyBind("ExpertPoint", "int", self, nx_current(), "on_point_changed")
    databinder:AddRolePropertyBind("RelaxationPoint", "int", self, nx_current(), "on_point_changed")
    databinder:AddRolePropertyBind("InSBKillBuff", "int", self, nx_current(), "on_refresh_role_face")
    databinder:AddRolePropertyBind("BodyScale", "float", self, nx_current(), "update_form_main_player")
  end
  self.groupbox_life.Visible = false
  on_team_update(self, nil, nil, nil, TEAM_REC_COL_TEAMWORK)
  on_btn_touxiang_click(self.btn_touxiang)
  hide_pk_help_arrow()
  refresh_role_changed()
  init_hide_player()
end
function refresh_role_changed()
  local form_main_player_logic = nx_value("form_main_player")
  if not nx_is_valid(form_main_player_logic) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("Force") and nx_string(client_player:QueryProp("Force")) ~= nx_string("") then
    client_force = client_player:QueryProp("Force")
    form_main_player_logic:UpdateTypeChanged(client_force)
  elseif client_player:FindProp("NewSchool") and nx_string(client_player:QueryProp("NewSchool")) ~= nx_string("") then
    client_newschool = client_player:QueryProp("NewSchool")
    form_main_player_logic:UpdateTypeChanged(client_newschool)
  else
    client_school = client_player:QueryProp("School")
    form_main_player_logic:UpdateTypeChanged(client_school)
  end
end
function on_vip_info_rec_change(self, recordname, optype, row, clomn)
  if clomn == VIR_STATUS then
    on_vip_status_change(self)
  end
end
function refresh_Vip_status(form)
  if nx_is_valid(form) then
    local vipstatus = false
    local game_client = nx_value("game_client")
    local player = game_client:GetPlayer()
    if is_vip(player, VT_NORMAL) then
      local vip_time = nx_number(get_vip_time(player, VT_NORMAL))
      if vip_time ~= 0 then
        vipstatus = true
      end
    end
    if vipstatus == false then
      form.btn_2.PushImage = "gui\\language\\ChineseS\\vip\\btn_vip_closed_down.png"
      form.btn_7.PushImage = "gui\\language\\ChineseS\\vip\\btn_vip_closed_down.png"
      form.btn_2.NormalImage = "gui\\language\\ChineseS\\vip\\btn_vip_closed_on.png"
      form.btn_7.NormalImage = "gui\\language\\ChineseS\\vip\\btn_vip_closed_on.png"
      form.btn_2.FocusImage = "gui\\language\\ChineseS\\vip\\btn_vip_closed_on.png"
      form.btn_7.FocusImage = "gui\\language\\ChineseS\\vip\\btn_vip_closed_on.png"
    else
      form.btn_2.PushImage = "gui\\mainform\\role\\btn_vip_down.png"
      form.btn_7.PushImage = "gui\\mainform\\role\\btn_vip_down.png"
      form.btn_2.NormalImage = "gui\\mainform\\role\\btn_vip_out.png"
      form.btn_7.NormalImage = "gui\\mainform\\role\\btn_vip_out.png"
      form.btn_2.FocusImage = "gui\\mainform\\role\\btn_vip_on.png"
      form.btn_7.FocusImage = "gui\\mainform\\role\\btn_vip_on.png"
    end
  end
end
function on_vip_status_change(form)
  refresh_Vip_status(form)
end
function on_main_form_shut(form)
  if nx_is_valid(form.role_face) then
    local world = nx_value("world")
    world:Delete(form.role_face)
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("Face", self)
    databinder:DelRolePropertyBind("PKMode", self)
    databinder:DelRolePropertyBind("TeamCaptain", self)
    databinder:DelRolePropertyBind("TeamType", self)
    databinder:DelRolePropertyBind("TeamPickMode", self)
    databinder:DelTableBind(TEAM_REC, self)
    databinder:DelTableBind("RecvLetterRec", self.btn_3)
    databinder:DelTableBind("RecvLetterRec", self.btn_1)
    databinder:DelTableBind("NetBarRight", self)
    databinder:DelTableBind("SnDaNetBarRight", self)
    databinder:DelTableBind("vip_info_rec", self)
    databinder:DelRolePropertyBind("DayActivityValue", self)
    databinder:DelRolePropertyBind("WeekActivityValue", self)
    databinder:DelRolePropertyBind("ActivityRewardRec", self)
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "hide_PK_mode", self)
  if nx_running(nx_current(), "hide_PK_mode") then
    nx_kill(nx_current(), "hide_PK_mode")
  end
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("HPResumeEx", self)
  if nx_is_valid(self.role_face) and nx_is_valid(self.scenebox_1.Scene) then
    self.scenebox_1.Scene:Delete(self.role_face)
  end
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if nx_is_valid(form) then
    on_main_form_close(form)
    on_main_form_open(form)
    form.pbar_resume_hp.Visible = false
  else
    util_show_form("form_stage_main\\form_main\\form_main_player", true)
  end
end
function get_pi(degree)
  return math.pi * degree / 180
end
function exe_refresh_role_face(form)
  local bShowTaohuaMask = false
  if nx_is_valid(form.role_face) then
    local world = nx_value("world")
    world:Delete(form.role_face)
    bShowTaohuaMask = true
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
    form.scenebox_1.Scene.RoundScene = true
  end
  local scene = form.scenebox_1.Scene
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return 1
  end
  local sex = client_player:QueryProp("Sex")
  local dr = sex == 0 and 0.55 or 0.5
  local dx = sex == 0 and 0.01 or 0
  local dh = sex == 0 and 1.67 or 1.58
  local fscale = 1
  if client_player:FindProp("BodyScale") then
    fscale = client_player:QueryProp("BodyScale")
  end
  dh = dh * fscale
  local role_actor2 = nx_execute("role_composite", "create_actor2", scene, "create_scene_obj_composite")
  nx_execute("role_composite", "create_scene_obj_composite_with_actor2", scene, role_actor2, client_player, false, "main_player")
  form.role_face = role_actor2
  local time_count = 0
  if not nx_is_valid(role_actor2) then
    return 1
  end
  while not role_actor2.LoadFinish do
    time_count = time_count + nx_pause(0.1)
  end
  if not nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_1, role_actor2) and nx_is_valid(form.role_face) then
    local world = nx_value("world")
    world:Delete(form.role_face)
  end
  if not nx_is_valid(role_actor2) then
    return 1
  end
  local actor_role = role_actor2:GetLinkObject("actor_role")
  time_count = 0
  if not nx_is_valid(actor_role) then
    while not nx_is_valid(actor_role) and time_count < 2 do
      actor_role = role_actor2:GetLinkObject("actor_role")
      time_count = time_count + nx_pause(0.1)
    end
  end
  if not nx_is_valid(actor_role) then
    return 1
  end
  while not actor_role.LoadFinish do
    time_count = time_count + nx_pause(0.1)
  end
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("logoin_stand_3", true, true)
  end
  local camera = form.scenebox_1.Scene.camera
  if nx_is_valid(camera) then
    camera:SetPosition(-dr * math.sin(get_pi(15)) + dx, dh, -dr * math.cos(get_pi(15)))
    camera:SetAngle(0, get_pi(15), 0)
  end
  if bShowTaohuaMask == true then
    if not nx_is_valid(client_player) then
      return
    end
    local mask = nx_custom(client_player, "taohua_mask")
    if mask == nil or mask == "" then
      return
    end
    local form_main_buff = nx_value("form_main_buff")
    if not nx_is_valid(form_main_buff) then
      return
    end
    form_main_buff:OnRefreshMaskFace(client_player, true)
  end
end
function on_refresh_role_face(form)
  if nx_running(nx_current(), "exe_refresh_role_face") then
    nx_kill(nx_current(), "exe_refresh_role_face")
  end
  nx_execute(nx_current(), "exe_refresh_role_face", form)
end
function on_refresh_role_head()
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(300, 1, nx_current(), "refresh_head_scenebox_time", form, -1, -1)
    end
  end
end
function refresh_head_scenebox_time(from)
  local self = nx_value("form_stage_main\\form_main\\form_main_player")
  if nx_is_valid(self) then
    if nx_running(nx_current(), "exe_refresh_role_face") then
      nx_kill(nx_current(), "exe_refresh_role_face")
    end
    nx_execute(nx_current(), "exe_refresh_role_face", self)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_head_scenebox_time", self)
  end
end
function clear()
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if nx_is_valid(form) then
    on_main_form_close(form)
  end
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function on_team_update(form, tablename, ttype, line, col)
  if col == TEAM_REC_COL_NAME or col == TEAM_REC_COL_TEAMWORK or nx_string(ttype) == nx_string("clear") or nx_string(ttype) == nx_string("del") or nx_string(ttype) == nx_string("add") then
    refresh_team_icon(form)
  end
end
function refresh_team_icon(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_team_icon", self)
    timer:Register(500, 1, nx_current(), "on_refresh_team_icon", self, -1, -1)
  end
end
function on_refresh_team_icon(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_team_icon", form)
  end
  local form_logic = nx_value("form_main_player")
  if nx_is_valid(form_logic) then
    form_logic:RefreshTeamIcon(form)
  end
end
function on_show_pk_list(btn)
  local form_player = btn.ParentForm
  form_player.group_pk_state.Visible = not form_player.group_pk_state.Visible
  if form_player.group_pk_state.Visible then
    refresh_PK_mode(form_player)
    nx_execute(nx_current(), "show_PK_mode")
    if form_player.lbl_pk_arrow.Visible then
      hide_pk_help_arrow()
    end
  else
    nx_execute(nx_current(), "hide_PK_mode", form_player)
  end
  show_charater(form_player)
end
function refresh_PK_mode(form)
  if not nx_is_valid(form) then
    return
  end
  if not form.group_pk_state.Visible then
    return
  end
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return
  end
  form.btn_pkstate1.Enabled = true
  form.btn_pkstate2.Enabled = true
  form.btn_pkstate3.Enabled = false
  form.btn_pkstate4.Enabled = false
  form.btn_pkstate3.Visible = false
  form.btn_pkstate4.Visible = false
  local fight = nx_value("fight")
  local isfreshman = fight:IsFreshman(game_player)
  if isfreshman then
    form.btn_pkstate2.Enabled = false
  end
  local pk_mode = PKMODE_PEACE
  if game_player:FindProp("PKMode") then
    pk_mode = nx_number(game_player:QueryProp("PKMode"))
  end
  if pk_mode == PKMODE_ARENA or pk_mode == PKMODE_CRAZYKILL then
    form.btn_pkstate1.Enabled = false
    form.btn_pkstate2.Enabled = false
  end
end
function on_pkstate_change(self)
  local pk_name = nx_string(self.Text)
  local pk_mode = nx_int(self.DataSource)
  local form = self.ParentForm
  nx_execute("custom_sender", "custom_set_pkmode", pk_mode)
end
function switch_pk_mode()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local now_pk_mode = nx_number(client_player:QueryProp("PKMode"))
  local PKMODE_PEACE = 1
  local PKMODE_FIGHT = 2
  local PKMODE_ARENA = 3
  local PKMODE_RED = 4
  if PKMODE_PEACE == now_pk_mode then
    nx_execute("custom_sender", "custom_set_pkmode", PKMODE_FIGHT)
  elseif PKMODE_FIGHT == now_pk_mode then
    nx_execute("custom_sender", "custom_set_pkmode", PKMODE_PEACE)
  end
end
function protectother_pk_mode()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local is_protectother = client_player:QueryProp("IsProtectOther")
  if nx_int(is_protectother) == nx_int(0) then
    nx_execute("custom_sender", "custom_set_pkprotect", nx_int(6), nx_int(1))
  else
    nx_execute("custom_sender", "custom_set_pkprotect", nx_int(6), nx_int(0))
  end
end
function on_pkprotect_change(self)
  local pk_protect = nx_int(self.DataSource)
  local checked = nx_int(self.Checked)
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if nx_is_valid(visual_player) then
    nx_execute("custom_sender", "custom_set_pkprotect", pk_protect, checked)
  end
end
function on_get_capture_pkmode(btn)
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("tips_pkmode_" .. nx_string(btn.DataSource)), btn.AbsLeft, btn.AbsTop - 40, 0, btn.ParentForm)
end
function on_get_capture_pkprotect(btn)
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("tips_pkprotect_" .. nx_string(btn.DataSource)), btn.AbsLeft, btn.AbsTop - 40, 0, btn.ParentForm)
end
function on_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_lbl_photo_click(lbl)
  local form_name = "form_stage_main\\form_main\\form_main_func_btns"
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    util_show_form(form_name, true)
  else
    form.Visible = not form.Visible
  end
end
function on_lbl_photo_left_double_click(lbl)
  nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
end
function on_btn_faculty_click(btn)
  local form = btn.ParentForm
  form.lbl_photo.Visible = false
  btn.Visible = false
  form.scenebox_1.Visible = false
  form.pbar_xiu.Visible = true
  form.pbar_xiu.ProgressImage = get_live_bar_backimage()
  form.btn_xiulian.Visible = true
  form.btn_touxiang.Visible = true
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  return 1
end
function on_btn_xiu_get_capture(self)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local livepoint = player:QueryProp("LiveGroove_1") + player:QueryProp("LiveGroove_2") + player:QueryProp("LiveGroove_3") + player:QueryProp("LiveGroove_4") + player:QueryProp("LiveGroove_5")
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("ui_main_player_taiji", nx_int(livepoint / 1000))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), self.AbsLeft + 10, self.AbsTop + 10)
end
function on_btn_xiu_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function show_PK_mode()
  if nx_running(nx_current(), "show_PK_mode") then
    return
  end
  if nx_running(nx_current(), "hide_PK_mode") then
    nx_kill(nx_current(), "hide_PK_mode")
  end
  local form_player = nx_value("form_stage_main\\form_main\\form_main_player")
  if not nx_is_valid(form_player) then
    return
  end
  local group = form_player.group_pk_state
  local origin_left = group.AbsLeft
  local target_left = form_player.AbsLeft + 4
  local distance = target_left - origin_left
  group.AbsLeft = target_left
  local timer = nx_value(GAME_TIMER)
  timer:Register(20000, 1, nx_current(), "hide_PK_mode", form_player, -1, -1)
end
function on_btn_xiulian_click(btn)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
  local form = util_get_form("form_stage_main\\form_wuxue\\form_wuxue", false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue", "on_btn_faculty_info_click", form.btn_faculty_info)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  return 1
end
function on_btn_touxiang_click(btn)
  local form = btn.ParentForm
  btn.Visible = false
  form.btn_xiulian.Visible = false
  form.pbar_xiu.Visible = false
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.btn_xiu.Visible = false
    form.btn_touxiang.Visible = false
    form.lbl_photo.Visible = false
    form.scenebox_1.Visible = true
    return 1
  end
  form.btn_xiu.Visible = true
  form.lbl_photo.Visible = false
  form.scenebox_1.Visible = true
  return 1
end
function refresh_form_livegroove_to_faculty()
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if not nx_is_valid(form) or not form.btn_touxiang.Visible then
    return 0
  end
  form.ani_faculty.Visible = true
  form.ani_faculty:Stop()
  form.ani_faculty:Play()
  return 1
end
function on_ani_faculty_animation_end(animation)
  animation.Visible = false
end
function hide_PK_mode(form_player)
  if nx_running(nx_current(), "hide_PK_mode") then
    return
  end
  if not nx_is_valid(form_player) then
    return
  end
  local group = form_player.group_pk_state
  group.Visible = true
  local origin_left = group.AbsLeft
  local target_left = form_player.AbsLeft - group.Width - 4
  local distance = target_left - origin_left
  local time_count = 0
  group.AbsLeft = target_left
  group.Visible = false
end
function on_btn_3_click(btn)
  btn.NormalImage = "gui\\mainform\\role\\btn_mail_out.png"
  nx_execute("form_stage_main\\form_mail\\form_mail", "auto_show_mail_form")
end
function on_btn_3_get_capture(btn)
  if not is_have_noread_mail() then
    return
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(format_info("ui_mail_noread")), btn.AbsLeft - 80, btn.AbsTop, 0, btn)
end
function on_btn_3_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn)
end
function is_have_noread_mail()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local rownum = client_player:GetRecordRows("RecvLetterRec")
  local read_flag = 9
  for row = 0, rownum - 1 do
    local is_read = client_player:QueryRecord("RecvLetterRec", row, read_flag)
    if nx_int(is_read) == nx_int(0) then
      return true
    end
  end
  return false
end
function on_recv_letter(btn, recordname, optype, row, clomn)
  if not nx_is_valid(btn) then
    return
  end
  if optype ~= "add" then
    return
  end
  local form_mail = nx_value("form_stage_main\\form_mail\\form_mail")
  if nx_is_valid(form_mail) and form_mail.Visible then
    return
  end
  if not is_have_noread_mail() then
    return
  end
  btn.NormalImage = "mail"
end
function format_info(strid, ...)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(strid)
  for i, para in pairs(arg) do
    local type = nx_type(para)
    if type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  return gui.TextManager:Format_GetText()
end
function on_btn_get_capture(btn)
  local _type = btn.DataSource
  local gui = nx_value("gui")
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return
  end
  local b_switch_41 = mgr:CheckSwitchEnable(ST_FUNCTION_VIP_JINGXIU_1)
  if _type == "7" then
    local game_client = nx_value("game_client")
    local player = game_client:GetPlayer()
    if not is_vip(player, VT_NORMAL) then
      nx_execute("tips_game", "show_text_tip", nx_widestr(format_info("ui_jhhy_3")), btn.AbsLeft - 80, btn.AbsTop, 0, btn)
    else
      local time = get_vip_time(player, VT_NORMAL)
      local show_txt = nx_widestr("")
      if b_switch_41 == true then
        if is_vip(player, VT_JINGXIU) then
          local str = nx_execute("form_stage_main\\form_vip_info", "format_time", get_vip_time(player, VT_NORMAL))
          local str_jingxiu = nx_execute("form_stage_main\\form_vip_info", "format_time", get_vip_time(player, VT_JINGXIU))
          show_txt = nx_widestr(format_info("ui_main_funcmenu_vip")) .. nx_widestr("<br>") .. str .. nx_widestr("<br>") .. nx_widestr(format_info("ui_buyvip_2")) .. nx_widestr("<br>") .. str_jingxiu
        else
          local str = nx_execute("form_stage_main\\form_vip_info", "format_time", get_vip_time(player, VT_NORMAL))
          show_txt = nx_widestr(format_info("ui_main_funcmenu_vip")) .. nx_widestr("<br>") .. str .. nx_widestr("<br>") .. nx_widestr(format_info("ui_buyvip_2")) .. nx_widestr("<br>") .. util_text("tips_zhizun_01")
        end
      else
        local str = nx_execute("form_stage_main\\form_vip_info", "format_time", get_vip_time(player, VT_NORMAL))
        show_txt = nx_widestr(format_info("ui_main_funcmenu_vip")) .. nx_widestr("<br>") .. str
      end
      nx_execute("tips_game", "show_text_tip", show_txt, btn.AbsLeft - 80, btn.AbsTop, 0, btn)
    end
  end
end
function on_btn_lost_capture(btn)
  local _type = btn.DataSource
  if _type == "7" then
    nx_execute("tips_game", "hide_tip", btn)
  end
end
function on_btn_7_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_vip_info")
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_ngskill_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local status = nx_number(player:QueryProp("NeigongPKStatus"))
  if cbtn.Checked then
    if status == 0 then
      cbtn.Checked = false
      nx_execute("custom_sender", "custom_send_new_neigong_pk_msg", 1)
    end
  elseif status == 1 and not cbtn.Checked then
    nx_execute("custom_sender", "custom_send_new_neigong_pk_msg", 2)
  end
end
function on_cbtn_ngpk_get_capture(cbtn)
  local tip = util_format_string("neigpk tips")
  nx_execute("tips_game", "show_text_tip", tip, cbtn.AbsLeft - 80, cbtn.AbsTop, 0, cbtn)
end
function on_cbtn_ngpk_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip", cbtn.ParentForm)
end
function on_online_changed(form)
  local ready = nx_value("player_ready")
  if not ready then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local online = player:QueryProp("UnenthrallTime")
  if online <= 0 then
    form.groupbox_enthrall.Visible = false
    nx_execute("form_stage_main\\form_enthrall\\enthrall", "on_online_zero")
    return
  end
  if not form.groupbox_enthrall.Visible then
    local left = 10800 - online / 1000
    form.lbl_enthrall.Text = nx_execute("util_functions", "util_format_string", "ui_fcm_time", nx_int(left / 3600), nx_int(math.mod(left, 3600) / 60), nx_int(math.mod(left, 60)))
  end
  form.groupbox_enthrall.Visible = true
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("UnenthrallModule")
    nx_set_value("UnenthrallModule", mgr)
  end
  if nx_is_valid(mgr) then
    mgr.OnlineTime = online
    mgr.Enthrall = true
  end
  nx_execute("form_stage_main\\form_enthrall\\enthrall", "on_online_changed", player, mgr, online)
end
function on_pbar_enthrall_get_capture(pbar)
end
function on_pbar_enthrall_lost_capture(pbar)
end
function on_panel_right_click(self)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "role", "role")
  nx_execute("menu_game", "menu_recompose", menu_game)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x + 25, y)
end
function on_btn_lian_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local FACULTY_STATE_CONVERT = 2
  local FACULTY_NORMAL = 1
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_state = client_player:QueryProp("FacultyState")
  local cur_style = client_player:QueryProp("FacultyStyle")
  if nx_int(cur_state) ~= nx_int(FACULTY_STATE_CONVERT) or nx_int(cur_style) ~= nx_int(FACULTY_NORMAL) then
    return
  end
  util_show_form("form_stage_main\\form_wuxue\\form_tips_faculty", true)
  local form_tips = util_get_form("form_stage_main\\form_wuxue\\form_tips_faculty")
  form.btn_lian.HintText = ""
  if nx_is_valid(form_tips) then
    form_tips.AbsLeft = self.AbsLeft + self.Width
    form_tips.AbsTop = self.AbsTop + self.Height
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_lian_lost_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  util_show_form("form_stage_main\\form_wuxue\\form_tips_faculty", false)
  form.btn_lian.HintText = nx_widestr(util_text("ui_train_title_0_tips"))
end
function on_btn_lian_click(self)
  util_auto_show_hide_form("form_stage_main\\form_wuxue\\form_wuxue_faculty")
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_pbar_state_hp_get_capture(progres)
  show_state_tips(progres, "HP", "ui_g_hp", "ui_state_hp")
end
function on_pbar_state_hp_lost_capture(progres)
  nx_execute("tips_game", "hide_tip")
end
function on_pbar_ene_get_capture(progres)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local ene = nx_number(client_player:QueryProp("Ene"))
  local maxene = nx_number(client_player:QueryProp("MaxEne"))
  local str = nx_widestr(gui.TextManager:GetText("ui_dangqiantilizhi"))
  local text = str .. nx_widestr(ene) .. nx_widestr("/") .. nx_widestr(maxene)
  local x, y = gui:GetCursorPosition()
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(text, x, y, -1, "0-0")
  end
end
function on_pbar_ene_lost_capture(progres)
  nx_execute("tips_game", "hide_tip")
end
function on_pbar_sat_get_capture(progres)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local sat = nx_number(client_player:QueryProp("Sat"))
  local maxsat = nx_number(client_player:QueryProp("MaxSat"))
  local str = nx_widestr(gui.TextManager:GetText("ui_dangqianbaoshidu"))
  local text = str .. nx_widestr(sat) .. nx_widestr("/") .. nx_widestr(maxsat)
  local x, y = gui:GetCursorPosition()
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
end
function on_pbar_sat_lost_capture(progres)
  nx_execute("tips_game", "hide_tip")
end
function on_pbar_state_mp_get_capture(progres)
  show_state_tips(progres, "MP", "ui_g_mp", "ui_state_mp")
end
function on_pbar_state_mp_lost_capture(progres)
  nx_execute("tips_game", "hide_tip")
end
function show_state_tips(progress_bar, prop, first_str_id, str_id)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(progress_bar) then
    return
  end
  local gui = nx_value("gui")
  local hp = nx_number(client_player:QueryProp(prop))
  local speed_prop1 = prop .. "HeartSpeed"
  local speed_prop2 = prop .. "HeartSpeedAdd"
  local up_prop1 = prop .. "UpSpeed"
  local up_prop2 = prop .. "UpSpeedAdd"
  local mul_prop = prop .. "ResumeMul"
  local once_mul_prop = prop .. "ResumeOnceMul"
  local once_add_prop = prop .. "ResumeOnceAdd"
  local text = nx_widestr(gui.TextManager:GetText(first_str_id)) .. nx_widestr(":") .. nx_widestr(hp) .. nx_widestr("/") .. nx_widestr(progress_bar.Maximum)
  local HeartSpeed = client_player:QueryProp(speed_prop1) + client_player:QueryProp(speed_prop2)
  HeartSpeed = HeartSpeed / 1000
  if HeartSpeed < 1 then
    HeartSpeed = 1
  end
  local resume_val = client_player:QueryProp(up_prop1) + client_player:QueryProp(up_prop2)
  if client_player:FindProp(mul_prop) then
    resume_val = resume_val * client_player:QueryProp(mul_prop)
  end
  if client_player:FindProp(once_mul_prop) then
    resume_val = resume_val * client_player:QueryProp(once_mul_prop)
  end
  if client_player:FindProp(once_add_prop) then
    resume_val = resume_val + client_player:QueryProp(once_add_prop)
  end
  if resume_val < 0 then
    resume_val = 0
  end
  local state_text = nx_widestr(gui.TextManager:GetFormatText(str_id, HeartSpeed, resume_val))
  text = text .. nx_widestr("<br>") .. state_text
  local x, y = gui:GetCursorPosition()
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
end
function on_btn_card_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_card\\form_card")
end
function on_btn_lilian_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_daily_live_point")
end
function on_btn_guild_chase_click(btn)
  local dialog_info = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_chase_info", true, false)
  local dialog_stat = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_chase_stat", true, false)
  if not nx_is_valid(dialog_info) or not nx_is_valid(dialog_stat) then
    return
  end
  dialog_info:Show()
  dialog_stat:Show()
  dialog_info.Left = dialog_stat.Left + dialog_stat.Width
  dialog_info.Top = dialog_stat.Top
end
function set_btn_guild_chase_enabled(...)
  if nx_int(table.getn(arg)) ~= nx_int(1) then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if not nx_is_valid(form) then
    return
  end
  local cur_normal_image = form.btn_guild_chase.NormalImage
  local cur_focus_image = form.btn_guild_chase.FocusImage
  if nx_int(0) == nx_int(arg[1]) then
    if nx_string(cur_normal_image) ~= nx_string("gui\\map\\minimap\\btn_guild_out.png") then
      form.btn_guild_chase.NormalImage = nx_string("gui\\map\\minimap\\btn_guild_out.png")
    end
    if nx_string(cur_focus_image) ~= nx_string("gui\\map\\minimap\\btn_guild_on.png") then
      form.btn_guild_chase.FocusImage = nx_string("gui\\map\\minimap\\btn_guild_on.png")
    end
  else
    if nx_string(cur_normal_image) ~= nx_string("guild_chase_icon") then
      form.btn_guild_chase.NormalImage = nx_string("guild_chase_icon")
    end
    if nx_string(cur_focus_image) ~= nx_string("guild_chase_icon") then
      form.btn_guild_chase.FocusImage = nx_string("guild_chase_icon")
    end
  end
end
function on_btn_guild_chase_get_capture(btn)
  if nx_is_valid(btn) then
    nx_execute("tips_game", "show_text_tip", nx_widestr(format_info("ui_guild_revenge_tips")), btn.AbsLeft - 80, btn.AbsTop, 0, btn)
  end
end
function on_btn_guild_chase_lost_capture(btn)
  if nx_is_valid(btn) then
    nx_execute("tips_game", "hide_tip", btn)
  end
end
function show_pk_help_arrow()
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_pk_arrow.Visible = true
end
function hide_pk_help_arrow()
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_pk_arrow.Visible = false
end
function get_cur_live_speed()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  local speed = 0
  if 0 < player:QueryProp("LiveGroove_1") then
    speed = speed + 10
  end
  if 0 < player:QueryProp("LiveGroove_2") then
    speed = speed + 20
  end
  if 0 < player:QueryProp("LiveGroove_3") then
    speed = speed + 50
  end
  if 0 < player:QueryProp("LiveGroove_4") then
    speed = speed + 100
  end
  if 0 < player:QueryProp("LiveGroove_5") then
    speed = speed + 200
  end
  local power = player:QueryProp("LiveSpeedPower")
  if nx_int(power) > nx_int(0) then
    speed = speed + speed * power / 100
  end
  local is_vip = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if not is_vip then
    speed = nx_number(nx_int(speed * 0.7))
  end
  return speed
end
function get_live_bar_backimage()
  local high_speed = "gui\\mainform\\role\\pbr_lilian_1.png"
  local mid_speed = "gui\\mainform\\role\\pbr_lilian_2.png"
  local low_speed = "gui\\mainform\\role\\pbr_lilian_3.png"
  local cur_speed = get_cur_live_speed()
  if cur_speed <= 100 then
    return low_speed
  elseif cur_speed <= 380 then
    return mid_speed
  else
    return high_speed
  end
end
function on_netbar_right_changed(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local right_level = 0
  if client_player:FindProp("NetBarRight") then
    right_level = client_player:QueryProp("NetBarRight")
  end
  local snda_level = 0
  if client_player:FindProp("SnDaNetBarRight") then
    snda_level = client_player:QueryProp("SnDaNetBarRight")
  end
  if right_level == 0 and snda_level == 0 then
    self.btn_netbar_woniu.Visible = false
    self.btn_netbar_snda_1.Visible = false
    self.btn_netbar_snda_2.Visible = false
  elseif 0 < right_level and snda_level == 0 then
    self.btn_netbar_woniu.Visible = true
    self.btn_netbar_snda_1.Visible = false
    self.btn_netbar_snda_2.Visible = false
  elseif right_level == 0 and 0 < snda_level then
    self.btn_netbar_woniu.Visible = false
    self.btn_netbar_snda_1.Visible = true
    self.btn_netbar_snda_2.Visible = false
  elseif 0 < right_level and 0 < snda_level then
    self.btn_netbar_woniu.Visible = true
    self.btn_netbar_snda_1.Visible = false
    self.btn_netbar_snda_2.Visible = true
  end
end
function on_btn_netbar_click(btn)
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  if flag then
    return
  end
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if flag_apex then
    return
  end
  local key = btn.DataSource
  if nx_string(key) == "1" then
    util_auto_show_hide_form("form_stage_main\\form_netbar\\form_netbar_woniu")
  elseif nx_string(key) == "2" then
    util_auto_show_hide_form("form_stage_main\\form_netbar\\form_netbar_snda")
  end
end
function on_btn_netbar_get_capture(btn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local tips = ""
  local key = btn.DataSource
  if nx_string(key) == "1" then
    tips = "tips_netbar_right_woniu"
  elseif nx_string(key) == "2" then
    tips = "tips_netbar_right_snda"
  end
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText(tips), btn.AbsLeft, btn.AbsTop - 40, 0, btn.ParentForm)
end
function on_btn_netbar_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_btn_jingmai_click(self)
  if is_balance_war_scene() then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JINGMAI))
  if nx_is_valid(view) then
    local viewobj_list = view:GetViewObjList()
    local count = table.maxn(viewobj_list)
    if nx_int(count) > nx_int(0) then
      util_auto_show_hide_form("form_stage_main\\form_wuxue\\form_wuxue_jingmai_infomation")
    end
  end
end
function on_btn_jingmai_get_capture(self)
  if is_balance_war_scene() then
    self.HintText = nx_widestr("")
    return
  end
  self.HintText = nx_widestr(util_text("tips_jingmai_info"))
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JINGMAI))
  if nx_is_valid(view) then
    local viewobj_list = view:GetViewObjList()
    local count = table.maxn(viewobj_list)
    if nx_int(count) > nx_int(0) then
      set_jingmaiinfo_tips(self)
    else
      self.HintText = nx_widestr("")
    end
  end
end
function play_zhenqi_aination()
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if not nx_is_valid(form) then
    return
  end
  form.ani_jingmai.Visible = true
  form.ani_jingmai:Stop()
  form.ani_jingmai:Play()
  return
end
function on_ani_jingmai_animation_end(animation)
  animation.Visible = false
end
function on_btn_open_keyset_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shortcut_key", true, false)
  if nx_is_valid(dialog) then
    dialog:ShowModal()
    dialog.rbtn_other.Checked = true
  end
end
function set_jingmaiinfo_tips(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return ""
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local curjingmai_name = nx_string(client_player:QueryProp("CurJingMai"))
  if curjingmai_name == nil or curjingmai_name == "0" or curjingmai_name == "" then
    btn.HintText = nx_widestr(util_text("tips_jingmai_info_1"))
  else
    local gui = nx_value("gui")
    local item = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_jingmai_infomation", "get_jingmai_item")
    if not nx_is_valid(item) then
      return
    end
    local level_faculty = item:QueryProp("TotalFillValue")
    local cur_fillvalue = item:QueryProp("CurFillValue")
    local Level = item:QueryProp("Level")
    local jingmai_name = nx_string(client_player:QueryProp("CurJingMai"))
    local MaxLevel = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "get_maxlevel_by_conditions", item)
    local jingmai_usevalue = client_player:QueryProp("JingMaiTotalLevel")
    btn.HintText = nx_widestr(gui.TextManager:GetFormatText("tips_jingmai_info", nx_widestr(cur_fillvalue), nx_widestr(level_faculty), nx_widestr(Level), nx_widestr(MaxLevel), nx_widestr(util_text(jingmai_name)), nx_widestr(jingmai_usevalue)))
  end
end
function on_btn_exp_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_tvt\\form_tvt_exchange")
end
function on_point_changed(form, prop_name, type, value)
  if nx_string(prop_name) == "ExpertPoint" then
    form.lbl_exp_point.Text = nx_widestr(math.floor(value / 1000))
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      form.ani_exp.Visible = true
      form.ani_exp.PlayMode = 0
      timer:Register(500, 1, nx_current(), "on_animation_end", form.ani_exp, -1, -1)
    end
  elseif nx_string(prop_name) == "RelaxationPoint" then
    form.lbl_rel_point.Text = nx_widestr(math.floor(value / 1000))
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      form.ani_rel.Visible = true
      form.ani_rel.PlayMode = 0
      timer:Register(500, 1, nx_current(), "on_animation_end", form.ani_rel, -1, -1)
    end
  end
end
function on_animation_end(ani)
  ani.Visible = false
end
function show_charater(form)
  nx_execute("form_stage_main\\form_relation\\form_relation_self", "show_self_shane_info", form)
end
function on_btn_xia_e_click(btn)
  nx_execute("form_stage_main\\form_redeem\\form_character_main", "open_form")
  local form = nx_value("form_stage_main\\form_redeem\\form_character_main")
  if nx_is_valid(form) then
    form.rbtn_2.Checked = true
  end
end
function on_btn_leave_school_type_click()
  nx_execute("form_stage_main\\form_main\\form_school_info", "open_form")
end
function on_btn_leave_school_type_get_capture(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_find_custom(client_player, "leave_school_all_text") and nx_find_custom(client_player, "leave_school_info") and nx_find_custom(client_player, "leave_force_info") and nx_find_custom(client_player, "leave_newschool_info") then
    show_leave_school_tips(client_player.leave_school_all_text, client_player.leave_school_info, client_player.leave_force_info, client_player.leave_newschool_info)
  else
    local name = client_player:QueryProp("Name")
    nx_execute("custom_sender", "custom_get_leave_school_info", 1, name)
  end
end
function on_btn_leave_school_type_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function show_leave_school_tips(text, leave_school_info, leave_force_info, leave_newschool_info)
  local gui = nx_value("gui")
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_is_valid(client_player) and nx_widestr(text) == nx_widestr("") then
    if client_player:FindProp("School") and nx_string(client_player:QueryProp("School")) ~= nx_string("") then
      text = util_text(client_player:QueryProp("School")) .. util_text("ui_pupil")
    elseif client_player:FindProp("Force") and nx_string(client_player:QueryProp("Force")) ~= nx_string("") then
      text = util_text(client_player:QueryProp("Force")) .. util_text("ui_pupil")
    elseif client_player:FindProp("NewSchool") and nx_string(client_player:QueryProp("NewSchool")) ~= nx_string("") then
      text = util_text(client_player:QueryProp("NewSchool")) .. util_text("ui_pupil")
    else
      text = util_text("school_wumenpai") .. util_text("ui_pupil")
    end
    nx_execute("tips_game", "show_text_tip", text, form.btn_leave_school_type.AbsLeft, form.btn_leave_school_type.AbsTop, 400, form)
    return
  end
  if not nx_find_custom(form.btn_leave_school_type, "leave_school_text") then
    return
  end
  local tips_text = nx_widestr("")
  if form.btn_leave_school_type.leave_school_text == nx_widestr("") then
    tips_text = nx_widestr("<font color=\"#FFB428\">") .. gui.TextManager:GetText("ui_jianghu") .. gui.TextManager:GetText("ui_pupil") .. nx_widestr("</font><br>") .. text
  else
    tips_text = nx_widestr("<font color=\"#FFB428\">") .. form.btn_leave_school_type.leave_school_text .. nx_widestr("</font><br>") .. text
  end
  tips_text = tips_text .. get_leave_school_cool_down_text(leave_school_info, leave_force_info, leave_newschool_info)
  if tips_text == nx_widestr("") then
    return
  end
  nx_execute("tips_game", "show_text_tip", tips_text, form.btn_leave_school_type.AbsLeft, form.btn_leave_school_type.AbsTop, 400, form)
end
function get_leave_school_cool_down_text(leave_school_info, leave_force_info, leave_newschool_info)
  local text = nx_widestr("")
  local gui = nx_value("gui")
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return nx_widestr("")
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  if nx_string(leave_school_info) ~= "" and nx_string(leave_school_info) ~= "nil" then
    local day = math.floor(30 - (cur_date_time - nx_double(leave_school_info)))
    if 0 <= day then
      if day == 0 then
        day = 1
      end
      text = text .. gui.TextManager:GetText("ui_count_down_0")
      gui.TextManager:Format_SetIDName("ui_count_down_2")
      gui.TextManager:Format_AddParam(nx_int(day))
      text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
    end
  end
  if nx_string(leave_force_info) ~= "" and nx_string(leave_force_info) ~= "nil" then
    local force_list = util_split_string(leave_force_info, ";")
    for i = 1, table.getn(force_list) do
      local force_name = util_split_string(force_list[i], ",")[1]
      local force_time = util_split_string(force_list[i], ",")[2]
      if nx_string(force_name) ~= "nil" then
        local day = math.floor(24 - (cur_date_time - nx_double(force_time)))
        if 0 <= day then
          if day == 0 then
            day = 1
          end
          text = text .. gui.TextManager:GetText("ui_count_down_1") .. gui.TextManager:GetText(force_name)
          gui.TextManager:Format_SetIDName("ui_count_down_2")
          gui.TextManager:Format_AddParam(nx_int(day))
          text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
        end
      end
    end
  end
  if nx_string(leave_newschool_info) ~= "" and nx_string(leave_newschool_info) ~= "nil" then
    local newschool_list = util_split_string(leave_newschool_info, ";")
    for i = 1, table.getn(newschool_list) do
      local newschool_name = util_split_string(newschool_list[i], ",")[1]
      local newschool_time = util_split_string(newschool_list[i], ",")[2]
      if nx_string(newschool_name) ~= "nil" then
        local day = math.floor(24 - (cur_date_time - nx_double(newschool_time)))
        if 0 <= day then
          if day == 0 then
            day = 1
          end
          text = text .. gui.TextManager:GetText("ui_count_down_1") .. gui.TextManager:GetText(newschool_name)
          gui.TextManager:Format_SetIDName("ui_count_down_2")
          gui.TextManager:Format_AddParam(nx_int(day))
          text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
        end
      end
    end
  end
  return text
end
function on_btn_YY_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(158) then
    return
  end
  local form_yy = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_auth_YY")
  if nx_is_valid(form_yy) and form_yy.Visible then
    form_yy:Close()
    return
  end
  local new_time = os.time()
  if nx_find_custom(btn.ParentForm, "yy_query_time") and new_time - btn.ParentForm.yy_query_time <= 3 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19892")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  btn.ParentForm.yy_query_time = new_time
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CLIENT_CUSTOMMSG_GUILD = 1014
  local SUB_CUSTOMMSG_GUILD_BIND_YY_QUERY = 99
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_QUERY), nx_int(1), guild_name)
end
function show_yy_btn(show)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") do
    nx_pause(0)
    stage_main_flag = nx_value("stage_main")
    loading_flag = nx_value("loading")
  end
  local form_player = nx_value("form_stage_main\\form_main\\form_main_player")
  if nx_is_valid(form_player) then
    if show == 1 then
      form_player.btn_YY.Enabled = true
    else
      form_player.btn_YY.Enabled = false
    end
  end
end
function on_btn_qinggong_count_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_wuxue\\form_qinggong_auto_fill")
end
function update_form_main_player(form)
  on_refresh_role_face(form)
end
function update_newjh_form_main_player(form)
  if not nx_is_valid(form) then
    return
  end
  if not (nx_is_valid(form.lbl_qinggong_count) and nx_is_valid(form.btn_qinggong_count) and nx_is_valid(form.lbl_lbl_back_1)) or not nx_is_valid(form.cbtn_qinggong_count) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.lbl_qinggong_count.Visible = true
    form.btn_qinggong_count.Visible = true
    form.cbtn_qinggong_count.Visible = true
    form.btn_netbar_snda_2.Visible = false
    form.btn_netbar_woniu.Visible = false
    form.btn_netbar_snda_1.Visible = false
    form.btn_YY.Visible = false
    form.btn_guild_chase.Visible = false
    form.btn_lilian.Visible = false
    form.btn_1.Visible = false
    form.btn_3.Visible = false
    form.btn_7.Visible = false
    form.btn_2.Visible = false
    form.btn_exp.Visible = false
    form.ani_exp.Visible = false
    form.btn_rel.Visible = false
    form.ani_rel.Visible = false
    form.btn_touxiang.Visible = false
    form.btn_xiu.Visible = false
    local lbl_back_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_back", "BackImage", "")
    form.lbl_back.BackImage = nx_string(lbl_back_bg)
    local lbl_back_1_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_lbl_back_1", "BackImage", "")
    form.lbl_lbl_back_1.BackImage = nx_string(lbl_back_1_bg)
    local pbar_state_hp_prog_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_hp", "ProgressImage", "")
    local pbar_state_hp_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_hp", "Left", "")
    local pbar_state_hp_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_hp", "Top", "")
    local pbar_state_hp_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_hp", "Width", "")
    local pbar_state_hp_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_hp", "Height", "")
    form.pbar_state_hp.ProgressImage = nx_string(pbar_state_hp_prog_img)
    form.pbar_state_hp.Left = nx_int(pbar_state_hp_left)
    form.pbar_state_hp.Top = nx_int(pbar_state_hp_top)
    form.pbar_state_hp.Width = nx_int(pbar_state_hp_width)
    form.pbar_state_hp.Height = nx_int(pbar_state_hp_height)
    local pbar_hp_prog_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_hp", "ProgressImage", "")
    form.pbar_hp.ProgressImage = nx_string(pbar_hp_prog_img)
    local pbar_resume_hp_prog_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_resume_hp", "ProgressImage", "")
    form.pbar_resume_hp.ProgressImage = nx_string(pbar_resume_hp_prog_img)
    local pbar_state_mp_prog_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_mp", "ProgressImage", "")
    form.pbar_state_mp.ProgressImage = nx_string(pbar_state_mp_prog_img)
    local pbar_mp_prog_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_mp", "ProgressImage", "")
    form.pbar_mp.ProgressImage = nx_string(pbar_mp_prog_img)
    local lbl_frame_bg = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_frame", "BackImage", "")
    form.lbl_frame.BackImage = nx_string(lbl_frame_bg)
    local pbar_qinggong_prog_img = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_qinggong", "ProgressImage", "")
    local pbar_qinggong_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_qinggong", "Width", "")
    local pbar_qinggong_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_qinggong", "Height", "")
    local pbar_qinggong_prog_mode = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_qinggong", "ProgressMode", "")
    form.pbar_qinggong.ProgressImage = nx_string(pbar_qinggong_prog_img)
    form.pbar_qinggong.Width = nx_int(pbar_qinggong_width)
    form.pbar_qinggong.Height = nx_int(pbar_qinggong_height)
    form.pbar_qinggong.ProgressMode = nx_string(pbar_qinggong_prog_mode)
    local lbl_nq1_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq1", "Left", "")
    local lbl_nq1_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq1", "Top", "")
    form.lbl_nq1.Left = nx_int(lbl_nq1_left)
    form.lbl_nq1.Top = nx_int(lbl_nq1_top)
    local lbl_nq2_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq2", "Left", "")
    local lbl_nq2_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq2", "Top", "")
    form.lbl_nq2.Left = nx_int(lbl_nq2_left)
    form.lbl_nq2.Top = nx_int(lbl_nq2_top)
    local lbl_nq3_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq3", "Left", "")
    local lbl_nq3_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq3", "Top", "")
    form.lbl_nq3.Left = nx_int(lbl_nq3_left)
    form.lbl_nq3.Top = nx_int(lbl_nq3_top)
    local lbl_nq4_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq4", "Left", "")
    local lbl_nq4_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq4", "Top", "")
    form.lbl_nq4.Left = nx_int(lbl_nq4_left)
    form.lbl_nq4.Top = nx_int(lbl_nq4_top)
    local lbl_nq5_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq5", "Left", "")
    local lbl_nq5_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_nq5", "Top", "")
    form.lbl_nq5.Left = nx_int(lbl_nq5_left)
    form.lbl_nq5.Top = nx_int(lbl_nq5_top)
    local pbar_sp_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_sp", "Left", "")
    local pbar_sp_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_sp", "Top", "")
    form.pbar_sp.Left = nx_int(pbar_sp_left)
    form.pbar_sp.Top = nx_int(pbar_sp_top)
    local lbl_a_nq1_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq1", "Left", "")
    local lbl_a_nq1_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq1", "Top", "")
    form.lbl_a_nq1.Top = nx_int(lbl_a_nq1_left)
    form.lbl_a_nq1.Left = nx_int(lbl_a_nq1_top)
    local lbl_a_nq2_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq2", "Left", "")
    local lbl_a_nq2_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq2", "Top", "")
    form.lbl_a_nq2.Left = nx_int(lbl_a_nq2_left)
    form.lbl_a_nq2.Top = nx_int(lbl_a_nq2_top)
    local lbl_a_nq3_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq3", "Left", "")
    local lbl_a_nq3_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq3", "Top", "")
    form.lbl_a_nq3.Left = nx_int(lbl_a_nq3_left)
    form.lbl_a_nq3.Top = nx_int(lbl_a_nq3_top)
    local lbl_a_nq4_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq4", "Left", "")
    local lbl_a_nq4_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq4", "Top", "")
    form.lbl_a_nq4.Left = nx_int(lbl_a_nq4_left)
    form.lbl_a_nq4.Top = nx_int(lbl_a_nq4_top)
    local lbl_a_nq5_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq5", "Left", "")
    local lbl_a_nq5_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_a_nq5", "Top", "")
    form.lbl_a_nq5.Left = nx_int(lbl_a_nq5_left)
    form.lbl_a_nq5.Top = nx_int(lbl_a_nq5_top)
    local btn_jingmai_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_jingmai", "Left", "")
    local btn_jingmai_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "btn_jingmai", "Top", "")
    form.btn_jingmai.Left = nx_int(btn_jingmai_left)
    form.btn_jingmai.Top = nx_int(btn_jingmai_top)
    local ani_jingmai_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "ani_jingmai", "Left", "")
    local ani_jingmai_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "ani_jingmai", "Top", "")
    form.ani_jingmai.Left = nx_int(ani_jingmai_left)
    form.ani_jingmai.Top = nx_int(ani_jingmai_top)
    local scenebox_1_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "scenebox_1", "Left", "")
    local scenebox_1_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "scenebox_1", "Top", "")
    local scenebox_1_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "scenebox_1", "Width", "")
    local scenebox_1_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "scenebox_1", "Height", "")
    form.scenebox_1.Left = nx_int(scenebox_1_left)
    form.scenebox_1.Top = nx_int(scenebox_1_top)
    form.scenebox_1.Width = nx_int(scenebox_1_width)
    form.scenebox_1.Height = nx_int(scenebox_1_height)
    local pbar_hp_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_hp", "Left", "")
    local pbar_hp_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_hp", "Top", "")
    local pbar_hp_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_hp", "Width", "")
    local pbar_hp_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_hp", "Height", "")
    form.pbar_hp.Left = nx_int(pbar_hp_left)
    form.pbar_hp.Top = nx_int(pbar_hp_top)
    form.pbar_hp.Width = nx_int(pbar_hp_width)
    form.pbar_hp.Height = nx_int(pbar_hp_height)
    local pbar_resume_hp_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_resume_hp", "Left", "")
    local pbar_resume_hp_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_resume_hp", "Top", "")
    local pbar_resume_hp_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_resume_hp", "Width", "")
    local pbar_resume_hp_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_resume_hp", "Height", "")
    form.pbar_resume_hp.Left = nx_int(pbar_resume_hp_left)
    form.pbar_resume_hp.Top = nx_int(pbar_resume_hp_top)
    form.pbar_resume_hp.Width = nx_int(pbar_resume_hp_width)
    form.pbar_resume_hp.Height = nx_int(pbar_resume_hp_height)
    local pbar_state_mp_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_mp", "Left", "")
    local pbar_state_mp_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_mp", "Top", "")
    local pbar_state_mp_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_mp", "Width", "")
    local pbar_state_mp_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_state_mp", "Height", "")
    form.pbar_state_mp.Left = nx_int(pbar_state_mp_left)
    form.pbar_state_mp.Top = nx_int(pbar_state_mp_top)
    form.pbar_state_mp.Width = nx_int(pbar_state_mp_width)
    form.pbar_state_mp.Height = nx_int(pbar_state_mp_height)
    local pbar_mp_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_mp", "Left", "")
    local pbar_mp_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_mp", "Top", "")
    local pbar_mp_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_mp", "Width", "")
    local pbar_mp_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "pbar_mp", "Height", "")
    form.pbar_mp.Left = nx_int(pbar_mp_left)
    form.pbar_mp.Top = nx_int(pbar_mp_top)
    form.pbar_mp.Width = nx_int(pbar_mp_width)
    form.pbar_mp.Height = nx_int(pbar_mp_height)
    local lbl_frame_left = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_frame", "Left", "")
    local lbl_frame_top = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_frame", "Top", "")
    local lbl_frame_width = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_frame", "Width", "")
    local lbl_frame_height = get_ini_prop(FILE_FORM_MAIN_PLAYER_CFG, "lbl_frame", "Height", "")
    form.lbl_frame.Left = nx_int(lbl_frame_left)
    form.lbl_frame.Top = nx_int(lbl_frame_top)
    form.lbl_frame.Width = nx_int(lbl_frame_width)
    form.lbl_frame.Height = nx_int(lbl_frame_height)
  else
    form.lbl_qinggong_count.Visible = false
    form.btn_qinggong_count.Visible = false
    form.cbtn_qinggong_count.Visible = false
    form.btn_netbar_snda_2.Visible = true
    form.btn_netbar_woniu.Visible = true
    form.btn_netbar_snda_1.Visible = true
    form.btn_YY.Visible = true
    form.btn_guild_chase.Visible = true
    form.btn_lilian.Visible = true
    form.btn_1.Visible = true
    form.btn_3.Visible = true
    form.btn_7.Visible = true
    form.btn_2.Visible = true
    form.btn_exp.Visible = true
    form.ani_exp.Visible = true
    form.btn_rel.Visible = true
    form.ani_rel.Visible = true
    form.btn_touxiang.Visible = true
    form.btn_xiu.Visible = true
    form.lbl_back.BackImage = form.old_lbl_back_img
    form.lbl_lbl_back_1.BackImage = form.old_lbl_back_img
    form.pbar_state_hp.ProgressImage = form.old_hp_low_img
    form.pbar_hp.ProgressImage = form.old_hp_img
    form.pbar_resume_hp.ProgressImage = form.old_hp_resume_img
    form.pbar_state_mp.ProgressImage = form.old_mp_low_img
    form.pbar_mp.ProgressImage = form.old_mp_img
    form.lbl_frame.BackImage = form.old_lbl_frame_img
    form.pbar_qinggong.ProgressImage = form.old_qg_back_img
    form.pbar_qinggong.Left = form.old_pos_qinggong_x
    form.pbar_qinggong.Top = form.old_pos_qinggong_y
    form.pbar_qinggong.Width = form.old_pos_qinggong_width
    form.pbar_qinggong.Height = form.old_pos_qinggong_height
    form.pbar_qinggong.ProgressMode = "BottomToTop"
    form.lbl_nq1.Top = form.old_pos_lbl_nq1_y
    form.lbl_nq2.Top = form.old_pos_lbl_nq2_y
    form.lbl_nq3.Top = form.old_pos_lbl_nq3_y
    form.lbl_nq4.Top = form.old_pos_lbl_nq4_y
    form.lbl_nq5.Top = form.old_pos_lbl_nq5_y
    form.pbar_sp.Top = form.old_pos_pbar_sp_y
    form.lbl_a_nq1.Top = form.old_pos_lbl_a_nq1_y
    form.lbl_a_nq2.Top = form.old_pos_lbl_a_nq2_y
    form.lbl_a_nq3.Top = form.old_pos_lbl_a_nq3_y
    form.lbl_a_nq4.Top = form.old_pos_lbl_a_nq4_y
    form.lbl_a_nq5.Top = form.old_pos_lbl_a_nq5_y
    form.lbl_nq1.Left = form.old_pos_lbl_nq1_x
    form.lbl_nq2.Left = form.old_pos_lbl_nq2_x
    form.lbl_nq3.Left = form.old_pos_lbl_nq3_x
    form.lbl_nq4.Left = form.old_pos_lbl_nq4_x
    form.lbl_nq5.Left = form.old_pos_lbl_nq5_x
    form.pbar_sp.Left = form.old_pos_pbar_sp_x
    form.lbl_a_nq1.Left = form.old_pos_lbl_a_nq1_x
    form.lbl_a_nq2.Left = form.old_pos_lbl_a_nq2_x
    form.lbl_a_nq3.Left = form.old_pos_lbl_a_nq3_x
    form.lbl_a_nq4.Left = form.old_pos_lbl_a_nq4_x
    form.lbl_a_nq5.Left = form.old_pos_lbl_a_nq5_x
    form.lbl_nq1.Width = form.old_pos_lbl_nq1_width
    form.lbl_nq2.Width = form.old_pos_lbl_nq2_width
    form.lbl_nq3.Width = form.old_pos_lbl_nq3_width
    form.lbl_nq4.Width = form.old_pos_lbl_nq4_width
    form.lbl_nq5.Width = form.old_pos_lbl_nq5_width
    form.lbl_nq1.Height = form.old_pos_lbl_nq1_height
    form.lbl_nq2.Height = form.old_pos_lbl_nq2_height
    form.lbl_nq3.Height = form.old_pos_lbl_nq3_height
    form.lbl_nq4.Height = form.old_pos_lbl_nq4_height
    form.lbl_nq5.Height = form.old_pos_lbl_nq5_height
    form.btn_jingmai.Left = form.old_pos_jingmai_x
    form.btn_jingmai.Top = form.old_pos_jingmai_y
    form.ani_jingmai.Left = form.old_pos_jingmai_width
    form.ani_jingmai.Top = form.old_pos_jingmai_height
    form.scenebox_1.Left = form.old_pos_touxiang_x
    form.scenebox_1.Top = form.old_pos_touxiang_y
    form.scenebox_1.Width = form.old_pos_touxiang_width
    form.scenebox_1.Height = form.old_pos_touxiang_height
    form.pbar_state_hp.Left = form.old_pos_hp_low_x
    form.pbar_state_hp.Top = form.old_pos_hp_low_y
    form.pbar_state_hp.Width = form.old_pos_hp_low_width
    form.pbar_state_hp.Height = form.old_pos_hp_low_height
    form.pbar_hp.Left = form.old_pos_hp_x
    form.pbar_hp.Top = form.old_pos_hp_y
    form.pbar_hp.Width = form.old_pos_hp_width
    form.pbar_hp.Height = form.old_pos_hp_height
    form.pbar_resume_hp.Left = form.old_pos_hp_resume_x
    form.pbar_resume_hp.Top = form.old_pos_hp_resume_y
    form.pbar_resume_hp.Width = form.old_pos_hp_resume_width
    form.pbar_resume_hp.Height = form.old_pos_hp_resume_height
    form.pbar_state_mp.Left = form.old_pos_mp_low_x
    form.pbar_state_mp.Top = form.old_pos_mp_low_y
    form.pbar_state_mp.Width = form.old_pos_mp_low_width
    form.pbar_state_mp.Height = form.old_pos_mp_low_height
    form.pbar_mp.Left = form.old_pos_mp_x
    form.pbar_mp.Top = form.old_pos_mp_y
    form.pbar_mp.Width = form.old_pos_mp_width
    form.pbar_mp.Height = form.old_pos_mp_height
    form.lbl_frame.Left = form.old_pos_lbl_frame_x
    form.lbl_frame.Top = form.old_pos_lbl_frame_y
    form.lbl_frame.Width = form.old_pos_lbl_frame_width
    form.lbl_frame.Height = form.old_pos_lbl_frame_height
  end
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("HPResumeEx", form)
  asynor:AddExecute("HPResumeEx", form, nx_float(0), form.pbar_hp, form.pbar_mp, form.pbar_resume_hp, form.pbar_state_hp, form.pbar_state_mp)
  asynor:AddExecute("HPResumeEx", form, nx_float(0), form.pbar_ene, form.pbar_sat, nx_null(), nx_null(), nx_null())
  return
end
function on_pbar_hunger_get_capture(pbar)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local prop = client_player:QueryProp("Hunger")
  if 100 <= prop then
    gui.TextManager:Format_SetIDName("ui_Hunger_2_tips")
  else
    gui.TextManager:Format_SetIDName("ui_Hunger_0_tips")
  end
  gui.TextManager:Format_AddParam(nx_int(prop))
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), pbar.AbsLeft, pbar.AbsTop, 0, pbar)
end
function on_pbar_hunger_lost_capture(pbar)
  nx_execute("tips_game", "hide_tip", pbar)
end
function on_pbar_temperature_get_capture(pbar)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local prop = client_player:QueryProp("Temperature")
  if -10000 < prop and prop < 10000 then
    gui.TextManager:Format_SetIDName("ui_Temperature_0_tips")
    gui.TextManager:Format_AddParam(nx_int(prop / 2500))
  elseif 10000 <= prop then
    gui.TextManager:Format_SetIDName("ui_Temperature_1_tips")
    gui.TextManager:Format_AddParam(nx_int(prop / 2500))
    gui.TextManager:Format_AddParam(nx_int(prop / 2500))
  elseif prop <= -10000 then
    gui.TextManager:Format_SetIDName("ui_Temperature_3_tips")
    gui.TextManager:Format_AddParam(nx_int(prop / 2500))
    gui.TextManager:Format_AddParam(nx_int(prop / 2500))
  end
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), pbar.AbsLeft, pbar.AbsTop, 0, pbar)
end
function on_pbar_temperature_lost_capture(pbar)
  nx_execute("tips_game", "hide_tip", pbar)
end
function on_pbar_thirsty_get_capture(pbar)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local prop = client_player:QueryProp("Thirsty")
  if 100 < prop then
    gui.TextManager:Format_SetIDName("ui_Thirsty_2_tips")
  else
    gui.TextManager:Format_SetIDName("ui_Thirsty_0_tips")
  end
  gui.TextManager:Format_AddParam(nx_int(prop))
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), pbar.AbsLeft, pbar.AbsTop, 0, pbar)
end
function on_pbar_thirsty_lost_capture(pbar)
  nx_execute("tips_game", "hide_tip", pbar)
end
function on_pbar_stamina_get_capture(pbar)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local prop = client_player:QueryProp("Stamina")
  if 10 < prop then
    gui.TextManager:Format_SetIDName("ui_Stamina_0_tips")
  else
    gui.TextManager:Format_SetIDName("ui_Stamina_1_tips")
  end
  gui.TextManager:Format_AddParam(nx_int(prop))
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), pbar.AbsLeft, pbar.AbsTop, 0, pbar)
end
function on_pbar_stamina_lost_capture(pbar)
  nx_execute("tips_game", "hide_tip", pbar)
end
function on_pbar_hp_get_capture(progres)
  show_state_tips(progres, "HP", "ui_g_hp", "ui_state_hp")
end
function on_pbar_hp_lost_capture(progres)
  nx_execute("tips_game", "hide_tip", progres)
end
function on_pbar_mp_get_capture(progres)
  show_state_tips(progres, "MP", "ui_g_mp", "ui_state_mp")
end
function on_pbar_mp_lost_capture(progres)
  nx_execute("tips_game", "hide_tip", progres)
end
function on_cbtn_qinggong_count_get_capture(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local fill_value = client_player:QueryProp("CurQGAutoFill")
  local max_value = client_player:QueryProp("QGAutoFillMax")
  local show_value = max_value - fill_value
  if show_value < 0 then
    show_value = 0
  end
  local x, y = gui:GetCursorPosition()
  gui.TextManager:Format_SetIDName("ui_qinggong_auto_fill")
  gui.TextManager:Format_AddParam(nx_int(show_value))
  local show_text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", show_text, x, y, 0, form)
end
function on_cbtn_qinggong_count_lost_capture(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute("tips_game", "hide_tip", form)
end
function get_client_player()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    return game_client:GetPlayer()
  end
  return nx_null()
end
function on_btn_dboact_click(btn)
  local flag = nx_execute("form_stage_main\\form_main\\form_main_request", "player_in_pingheng_war")
  if flag then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local is_open = switch_manager:CheckSwitchEnable(2138)
  if is_open then
    local form_merge = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tvt\\form_tvt_merge", true, false)
    form_merge:Show()
  else
    util_auto_show_hide_form("form_stage_main\\form_dbomall\\form_dboactreward")
  end
end
function check_actreward(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local center_x = form.btn_dboact.Left + form.btn_dboact.Width / 2
  local center_y = form.btn_dboact.Top + form.btn_dboact.Height / 2
  local is_can_get = nx_execute("form_stage_main\\form_dbomall\\form_dboactreward", "is_can_reward")
  if is_can_get then
    form.btn_dboact.NormalImage = "lottery_btn_huoyuedu_light"
    form.btn_dboact.FocusImage = "lottery_btn_huoyuedu_light"
    form.btn_dboact.PushImage = "lottery_btn_huoyuedu_light"
  else
    form.btn_dboact.NormalImage = "lottery_btn_huoyuedu"
    form.btn_dboact.FocusImage = "lottery_btn_huoyuedu"
    form.btn_dboact.PushImage = "lottery_btn_huoyuedu"
  end
end
function is_balance_war_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("InteractStatus") then
    return false
  end
  local interact_status = player:QueryProp("InteractStatus")
  return nx_int(interact_status) == nx_int(ITT_BALANCE_WAR)
end
function on_btn_hide_player_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_main_player = nx_value("form_main_player")
  if not nx_is_valid(form_main_player) then
    return
  end
  local hide_index = nx_number(btn.DataSource)
  if hide_index == nx_number(0) then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    if game_visual.HideNoAttackPlayer then
      form_main_player:HideNoAttackPlayer()
    end
    if game_visual.HidePlayer then
      form_main_player:HideOtherPlayer()
    end
  elseif hide_index == nx_number(1) then
    form_main_player:HideOtherPlayer()
  elseif hide_index == nx_number(2) then
    form_main_player:HideNoAttackPlayer()
  end
end
function init_hide_player()
  local form = nx_value("form_stage_main\\form_main\\form_main_player")
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local hide_no_attack = game_visual.HideNoAttackPlayer
  local hide_other = game_visual.HidePlayer
  if hide_other then
    form.btn_hide_other.NormalImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
    form.btn_hide_other.FocusImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
    form.btn_hide_other.PushImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
  else
    form.btn_hide_other.NormalImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
    form.btn_hide_other.FocusImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
    form.btn_hide_other.PushImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
  end
  if hide_no_attack then
    form.btn_hide_no_attack.NormalImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
    form.btn_hide_no_attack.FocusImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
    form.btn_hide_no_attack.PushImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
  else
    form.btn_hide_no_attack.NormalImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
    form.btn_hide_no_attack.FocusImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
    form.btn_hide_no_attack.PushImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
  end
  if not hide_no_attack and not hide_other then
    form.btn_no_hide.NormalImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
    form.btn_no_hide.FocusImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
    form.btn_no_hide.PushImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
  else
    form.btn_no_hide.NormalImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
    form.btn_no_hide.FocusImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
    form.btn_no_hide.PushImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
  end
end
