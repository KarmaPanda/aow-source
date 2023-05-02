require("util_functions")
require("define\\camera_mode")
require("define\\control_mode_define")
local ScrollBar_Default = 100
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  init_ui_content(form)
end
function on_main_form_close(form)
  update_operate(form)
  nx_destroy(form)
end
function on_btn_ok_click(form)
  save_to_file(form)
end
function on_btn_cancel_click(form)
  form:Close()
end
function on_btn_apply_click(form)
  save_to_file(form)
end
function on_btn_default_click(form)
  recover_to_default(form)
end
function on_switchto_3dmode(form)
  form.cbtn_lock_45view.Visible = false
  form.lbl_lock_45view.Visible = false
end
function on_switchto_25dmode(form)
  form.cbtn_lock_45view.Visible = true
  form.lbl_lock_45view.Visible = true
end
function on_tbar_range_value_changed(bar)
  local form = bar.ParentForm
  form.pbar_range.Value = bar.Value
end
function on_tbar_centre_value_changed(bar)
  local form = bar.ParentForm
  form.pbar_centre.Value = bar.Value
  if nx_find_custom(bar, "is_enabled") and not bar.is_enabled then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  set_camera_Angle(nx_int(bar.Value) - ScrollBar_Default)
end
function on_cbtn_lock_45view_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.tbar_range.Value = 25
  else
    form.tbar_range.Value = 15
  end
end
function init_ui_content(form)
  local game_config = nx_value("game_config")
  local game_config_info = nx_value("game_config_info")
  local mode = util_get_property_key(game_config_info, "operate_control_mode", 0)
  if nx_int(mode) == nx_int(0) then
    form.cbtn_lock_45view.Visible = false
    form.lbl_lock_45view.Visible = false
  else
    form.cbtn_lock_45view.Visible = true
    form.lbl_lock_45view.Visible = true
  end
  local max_camera_dis = game_config_info.max_camera_dis
  if nx_float(max_camera_dis) < nx_float(5) then
    form.tbar_range.Value = 5
  elseif nx_float(max_camera_dis) > nx_float(35) then
    form.tbar_range.Value = 35
  else
    form.tbar_range.Value = nx_float(max_camera_dis)
  end
  key = util_get_property_key(game_config_info, "lock_camera", 0)
  form.cbtn_lock_45view.Checked = nx_string(key) == nx_string("1") and true or false
  local key = util_get_property_key(game_config_info, "camera_angle", 100)
  local deflect_pos = nx_int(key)
  local cur_deflect = nx_int(get_camera_Angle()) + ScrollBar_Default
  form.tbar_centre.is_enabled = false
  form.tbar_centre.Value = deflect_pos == cur_deflect and deflect_pos or cur_deflect
  form.tbar_centre.is_enabled = true
  local key = util_get_property_key(game_config_info, "play_movie_camera", 0)
  form.cbtn_play_movie_camera.Checked = nx_string(key) == nx_string("1") and true or false
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  local operate_mode = util_get_property_key(game_config_info, "operate_control_mode", 0)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local role = game_visual:GetPlayer()
    if nx_is_valid(role) and nx_find_custom(role, "scene") then
      local scene = role.scene
      if nx_is_valid(scene) and nx_find_custom(scene, "game_control") then
        local game_control = scene.game_control
        if nx_is_valid(game_control) then
          local normal_camera = game_control:GetCameraController(GAME_CAMERA_NORMAL)
          normal_camera.MaxDistance = nx_float(form.tbar_range.Value)
          local bindpos_camera = game_control:GetCameraController(GAME_CAMERA_BINDPOS)
          bindpos_camera.MaxDistance = nx_float(form.tbar_range.Value)
          game_config_info.max_camera_dis = form.tbar_range.Value
          local camera_control = game_control:GetCameraController(GAME_CAMERA_NORMAL)
          if nx_string(operate_mode) ~= nx_string("0") then
            util_set_property_key(game_config_info, "lock_camera", nx_int(form.cbtn_lock_45view.Checked and "1" or "0"))
            camera_control.LockCamera = form.cbtn_lock_45view.Checked
            if form.cbtn_lock_45view.Checked then
              camera_control.CurPitchAngle = 0.4
              camera_control.CurDistance = form.tbar_range.Value / 2
            end
          else
            util_set_property_key(game_config_info, "lock_camera", 0)
            camera_control.LockCamera = false
          end
        end
      end
    end
  end
  game_config_info.camera_angle = nx_int(form.tbar_centre.Value)
  util_set_property_key(game_config_info, "play_movie_camera", nx_int(form.cbtn_play_movie_camera.Checked and "1" or "0"))
  if form.cbtn_play_movie_camera.Checked then
    form.tbar_centre.Enabled = true
    form.tbar_centre.Value = ScrollBar_Default
  end
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
end
function recover_to_default(form)
  local game_config_info = nx_value("game_config_info")
  form.tbar_range.Enabled = true
  form.tbar_range.Value = 15
  form.cbtn_lock_45view.Checked = false
  form.tbar_centre.Enabled = true
  form.tbar_centre.Value = ScrollBar_Default
  form.cbtn_play_movie_camera.Checked = true
  set_camera_Angle(0)
end
function update_operate(form)
  local game_config_info = nx_value("game_config_info")
  local change_value = nx_int(form.tbar_centre.Value)
  local cur_value = game_config_info.camera_angle
  if nx_number(cur_value) ~= nx_number(change_value) then
    set_camera_Angle(cur_value - ScrollBar_Default)
  end
end
function get_camera_Angle()
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  local normal_camera = game_control:GetCameraController(GAME_CAMERA_NORMAL)
  if nx_is_valid(normal_camera) then
    return normal_camera.DeflectAngle
  end
  local bindpos_camera = game_control:GetCameraController(GAME_CAMERA_BINDPOS)
  if nx_is_valid(bindpos_camera) then
    return bindpos_camera.DeflectAngle
  end
  local scene_camera = game_control:GetCameraController(GAME_CAMERA_MOVIESCENE)
  if nx_is_valid(scene_camera) then
    return scene_camera.DeflectAngle
  end
  return 0
end
function set_camera_Angle(value)
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  local normal_camera = game_control:GetCameraController(GAME_CAMERA_NORMAL)
  if nx_is_valid(normal_camera) then
    normal_camera.DeflectAngle = value
  end
  local bindpos_camera = game_control:GetCameraController(GAME_CAMERA_BINDPOS)
  if nx_is_valid(bindpos_camera) then
    bindpos_camera.DeflectAngle = value
  end
  local scene_camera = game_control:GetCameraController(GAME_CAMERA_MOVIESCENE)
  if nx_is_valid(scene_camera) then
    scene_camera.DeflectAngle = value
  end
end
