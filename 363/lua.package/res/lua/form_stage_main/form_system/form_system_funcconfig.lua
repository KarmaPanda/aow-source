require("share\\view_define")
require("util_functions")
require("util_gui")
require("define\\camera_mode")
require("define\\control_mode_define")
require("define\\fight_operate_mode_define")
require("control_set")
local ScrollBar_Default = 100
local CLIENT_SET_PARRY = 2
function main_form_init(self)
  self.Fixed = false
  self.parry_type = 0
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  set_form_pos(self)
  init_camera_set_show(self)
  initial_mousekey_set(self)
  initial_keyboard_set(self)
  init_parry_type(self)
  self.lbl_parry_1.Visible = false
  self.rbtn_parry_1.Visible = false
  local auto_path = GetIniInfo("autopath_useskill")
  if nx_int(auto_path) == nx_int(1) then
    self.cbtn_autopath_outofrange.Checked = true
  else
    self.cbtn_autopath_outofrange.Checked = false
  end
  local auto_shotweapon = GetIniInfo("auto_equip_shotweapon")
  if nx_int(auto_shotweapon) == nx_int(1) then
    self.cbtn_shotweapon.Checked = true
  else
    self.cbtn_shotweapon.Checked = false
  end
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_system\\form_system_funcconfig", nx_null())
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  return 1
end
function init_camera_set_show(form)
  local camera_mode = GetIniInfo("camera_value")
  local deflect_pos = nx_int(GetIniInfo("camera_angle")) + ScrollBar_Default
  if nx_int(camera_mode) == nx_int(CONTROL_MODE_NORMAL) then
    form.tbar_1.Enabled = true
    form.tbar_1.Value = deflect_pos
    form.rbtn_joystick.Checked = false
    form.rbtn_mousehelp.Checked = true
    show_form_keyboard_mode(form)
  elseif nx_int(camera_mode) == nx_int(GAME_CAMERA_BINDPOS) then
    form.tbar_1.Enabled = true
    form.tbar_1.Value = deflect_pos
    form.rbtn_joystick.Checked = true
    form.rbtn_mousehelp.Checked = false
    show_form_joystick_mode(form)
  else
    form.tbar_1.Enabled = true
    form.tbar_1.Value = deflect_pos
    form.rbtn_joystick.Checked = false
    form.rbtn_mousehelp.Checked = true
    show_form_keyboard_mode(form)
  end
  local max_camera_dis = GetIniInfo("max_camera_dis")
  if nx_float(max_camera_dis) < nx_float(5) then
    form.tbar_camera_dis.Value = 5
  elseif nx_float(max_camera_dis) > nx_float(35) then
    form.tbar_camera_dis.Value = 35
  else
    form.tbar_camera_dis.Value = nx_float(max_camera_dis)
  end
end
function initial_mousekey_set(form)
  local lm_mode_set = GetIniInfo("lmouse_normal_mode")
  if nx_int(lm_mode_set) == nx_int(0) then
    form.rbtn_lmouse_move.Checked = true
    form.rbtn_lmouse_view.Checked = false
  elseif nx_int(lm_mode_set) == nx_int(1) then
    form.rbtn_lmouse_move.Checked = false
    form.rbtn_lmouse_view.Checked = true
  else
    form.rbtn_lmouse_move.Checked = true
    form.rbtn_lmouse_view.Checked = false
  end
  local rm_mode_set = GetIniInfo("mr_rotate_mode")
  if nx_int(rm_mode_set) == nx_int(0) then
    form.rbtn_mouse_use1.Checked = true
  elseif nx_int(rm_mode_set) == nx_int(1) then
    form.rbtn_mouse_use1.Checked = false
  else
    form.rbtn_mouse_use1.Checked = true
  end
  local lmouse_fight_set = GetIniInfo("lmouse_fight_mode")
  if nx_int(lmouse_fight_set) == nx_int(1) then
    form.rbtn_select_fight.Checked = true
    form.rbtn_fight.Checked = false
    form.rbtn_nofight.Checked = false
  elseif nx_int(lmouse_fight_set) == nx_int(2) then
    form.rbtn_select_fight.Checked = false
    form.rbtn_fight.Checked = true
    form.rbtn_nofight.Checked = false
  elseif nx_int(lmouse_fight_set) == nx_int(0) then
    form.rbtn_select_fight.Checked = false
    form.rbtn_fight.Checked = false
    form.rbtn_nofight.Checked = true
  end
  local rmouse_lock_set = GetIniInfo("rmouse_lock_mode")
  if nx_int(rmouse_lock_set) == nx_int(1) then
    form.cbtn_lock.Checked = true
  else
    form.cbtn_lock.Checked = false
  end
end
function initial_keyboard_set(form)
  local admove_set = GetIniInfo("admove_mode")
  if nx_int(admove_set) == nx_int(0) then
    form.rbtn_admove.Checked = true
    form.rbtn_adchangedir.Checked = false
  elseif nx_int(admove_set) == nx_int(1) then
    form.rbtn_admove.Checked = false
    form.rbtn_adchangedir.Checked = true
  else
    form.rbtn_admove.Checked = true
    form.rbtn_adchangedir.Checked = false
  end
end
function init_parry_type(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local parry_type = client_player:QueryProp("ParryType")
  if nx_int(parry_type) < nx_int(0) or nx_int(parry_type) > nx_int(2) then
    return
  end
  form.parry_type = parry_type
  local rbtn = form.groupbox_parry:Find("rbtn_parry_" .. nx_string(parry_type))
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Checked = true
end
function show_form_joystick_mode(form)
  form.lbl_main1.Height = 340
  form.lbl_7.Height = form.lbl_main1.Height - 60
  form.lbl_8.Top = form.lbl_main1.Height - 20
  form.lbl_23.Top = form.lbl_main1.Height - 10
  form.lbl_22.Height = form.lbl_main1.Height - 30
  form.groupbox_2.Top = form.lbl_main1.Height - 13
  form.groupbox_mouse.Visible = false
end
function show_form_keyboard_mode(form)
  form.lbl_main1.Height = 500
  form.lbl_7.Height = form.lbl_main1.Height - 60
  form.lbl_8.Top = form.lbl_main1.Height - 20
  form.lbl_23.Top = form.lbl_main1.Height - 10
  form.lbl_22.Height = form.lbl_main1.Height - 30
  form.groupbox_2.Top = form.lbl_main1.Height - 13
  form.groupbox_mouse.Visible = true
end
function on_ScrollBar_CAngle_value_changed(ProBar)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local normal_camera = game_control:GetCameraController(CONTROL_MODE_NORMAL)
  if nx_is_valid(normal_camera) then
    normal_camera.DeflectAngle = nx_int(ProBar.Value) - ScrollBar_Default
  end
  local bindpos_camera = game_control:GetCameraController(GAME_CAMERA_BINDPOS)
  if nx_is_valid(bindpos_camera) then
    bindpos_camera.DeflectAngle = nx_int(ProBar.Value) - ScrollBar_Default
  end
  local scene_camera = game_control:GetCameraController(GAME_CAMERA_MOVIESCENE)
  if nx_is_valid(scene_camera) then
    scene_camera.DeflectAngle = nx_int(ProBar.Value) - ScrollBar_Default
  end
end
function on_rbtn_parry_checked_changed(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  if self.Checked then
    form.parry_type = nx_int(self.DataSource)
  end
end
function on_rbtn_rmouse_rotate_changed(rbtn)
  local form = rbtn.ParentForm
  if form.rbtn_mouse_use1.Checked == true then
    SetIniInfo("mr_rotate_mode", "0")
  else
    SetIniInfo("mr_rotate_mode", "1")
  end
end
function on_cbtn_lock_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if form.cbtn_lock.Checked == true then
    SetIniInfo("rmouse_lock_mode", "1")
  else
    SetIniInfo("rmouse_lock_mode", "0")
  end
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_joystick.Checked == true then
    SetIniInfo("camera_value", nx_string(GAME_CAMERA_BINDPOS))
  else
    SetIniInfo("camera_value", nx_string(GAME_CAMERA_NORMAL))
  end
  SetIniInfo("camera_angle", nx_string(form.tbar_1.Value - ScrollBar_Default))
  if form.rbtn_mouse_use1.Checked == false then
    SetIniInfo("mr_rotate_mode", "1")
  else
    SetIniInfo("mr_rotate_mode", "0")
  end
  if form.rbtn_lmouse_move.Checked == true then
    SetIniInfo("lmouse_normal_mode", "0")
  else
    SetIniInfo("lmouse_normal_mode", "1")
  end
  if form.cbtn_lock.Checked == true then
    SetIniInfo("rmouse_lock_mode", "1")
  else
    SetIniInfo("rmouse_lock_mode", "0")
  end
  if form.cbtn_shotweapon.Checked == true then
    SetIniInfo("auto_equip_shotweapon", "1")
    nx_execute("custom_sender", "custom_auto_equip_shotweapon", nx_int(1))
  else
    SetIniInfo("auto_equip_shotweapon", "0")
    nx_execute("custom_sender", "custom_auto_equip_shotweapon", nx_int(0))
  end
  save_and_set_camera_max_dis(form)
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  end
  nx_execute("custom_sender", "custom_active_parry", nx_int(CLIENT_SET_PARRY), nx_int(form.parry_type))
  form:Close()
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.CameraMode = nx_int(GetIniInfo("camera_value"))
  local deflect_pos = nx_int(GetIniInfo("camera_angle"))
  local normal_camera = game_control:GetCameraController(CONTROL_MODE_NORMAL)
  if nx_is_valid(normal_camera) then
    normal_camera.DeflectAngle = nx_int(deflect_pos)
  end
  local bindpos_camera = game_control:GetCameraController(GAME_CAMERA_BINDPOS)
  if nx_is_valid(bindpos_camera) then
    bindpos_camera.DeflectAngle = nx_int(form.tbar_1.Value) - ScrollBar_Default
  end
  local scene_camera = game_control:GetCameraController(GAME_CAMERA_MOVIESCENE)
  if nx_is_valid(scene_camera) then
    scene_camera.DeflectAngle = nx_int(form.tbar_1.Value) - ScrollBar_Default
  end
  form:Close()
end
function on_btn_reset_click(btn)
  local form = btn.ParentForm
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.CameraMode = GAME_CAMERA_NORMAL
  local deflect_pos = nx_int(GetIniInfo("camera_angle"))
  local normal_camera = game_control:GetCameraController(CONTROL_MODE_NORMAL)
  if nx_is_valid(normal_camera) then
    normal_camera.DeflectAngle = 0
  end
  local scene_camera = game_control:GetCameraController(GAME_CAMERA_MOVIESCENE)
  if nx_is_valid(scene_camera) then
    scene_camera.DeflectAngle = 0
  end
  form.tbar_1.Enabled = true
  form.tbar_1.Value = ScrollBar_Default
  form.rbtn_mouse_use1.Checked = true
  form.cbtn_lock.Checked = false
  form.rbtn_joystick.Checked = false
  form.rbtn_mousehelp.Checked = true
  form.rbtn_lmouse_move.Checked = true
  form.rbtn_lmouse_view.Checked = false
  form.rbtn_parry_0.Checked = true
  form.cbtn_shotweapon.Checked = false
  SetIniInfo("camera_value", nx_string(GAME_CAMERA_NORMAL))
  SetIniInfo("camera_angle", nx_string("0"))
  SetIniInfo("lmouse_normal_mode", "0")
  SetIniInfo("mr_rotate_mode", "0")
  SetIniInfo("game_control_mode", "0")
  SetIniInfo("auto_equip_shotweapon", "0")
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  end
end
function on_rbtn_joystick_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.CameraMode = GAME_CAMERA_BINDPOS
  game_control.FightOperateMode = FIGHT_OPERATE_MODE_JOYSTICK
  local form = rbtn.ParentForm
  SetIniInfo("game_control_mode", "1")
  show_form_joystick_mode(rbtn.ParentForm)
end
function on_rbtn_mousehelp_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked == false then
    return
  end
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.CameraMode = GAME_CAMERA_NORMAL
  game_control.FightOperateMode = FIGHT_OPERATE_MODE_NORMAL
  SetIniInfo("game_control_mode", "0")
  show_form_keyboard_mode(rbtn.ParentForm)
end
function on_rbtn_admove_checked_changed(rbtn)
  if rbtn.Checked then
    SetIniInfo("admove_mode", "0")
  end
end
function on_rbtn_adchangedir_checked_changed(rbtn)
  if rbtn.Checked then
    SetIniInfo("admove_mode", "1")
  end
end
function on_rbtn_lmouse_move_checked_changed(rbtn)
  if rbtn.Checked then
    SetIniInfo("lmouse_normal_mode", "0")
    local scene = nx_value("game_scene")
    local game_control = scene.game_control
    game_control.MLKeySlideCamera = false
  end
end
function on_rbtn_lmouse_view_checked_changed(rbtn)
  if rbtn.Checked then
    SetIniInfo("lmouse_normal_mode", "1")
    local scene = nx_value("game_scene")
    local game_control = scene.game_control
    game_control.MLKeySlideCamera = true
  end
end
function on_rbtn_select_fight_checked_changed(rbtn)
  if rbtn.Checked then
    SetIniInfo("lmouse_fight_mode", "1")
  end
end
function on_rbtn_fight_checked_changed(rbtn)
  if rbtn.Checked then
    SetIniInfo("lmouse_fight_mode", "2")
  end
end
function on_rbtn_nofight_checked_changed(rbtn)
  if rbtn.Checked then
    SetIniInfo("lmouse_fight_mode", "0")
  end
end
function on_tbar_camera_dis_value_changed(tbar)
end
function save_and_set_camera_max_dis(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local role = game_visual:GetPlayer()
  if not nx_is_valid(role) or not nx_find_custom(role, "scene") then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) or not nx_find_custom(scene, "game_control") then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local normal_camera = game_control:GetCameraController(GAME_CAMERA_NORMAL)
  normal_camera.MaxDistance = nx_float(form.tbar_camera_dis.Value)
  local bindpos_camera = game_control:GetCameraController(GAME_CAMERA_BINDPOS)
  bindpos_camera.MaxDistance = nx_float(form.tbar_camera_dis.Value)
  SetIniInfo("max_camera_dis", nx_float(form.tbar_camera_dis.Value))
end
function on_cbtn_autopath_outofrange_checked_changed(rbtn)
  if rbtn.Checked then
    SetIniInfo("autopath_useskill", "1")
  else
    SetIniInfo("autopath_useskill", "0")
  end
end
function auto_shotweapon_setting(Flag)
  SetIniInfo("auto_equip_shotweapon", nx_string(Flag))
end
function on_cbtn_shotweapon_checked_changed(self)
  if self.Checked then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
