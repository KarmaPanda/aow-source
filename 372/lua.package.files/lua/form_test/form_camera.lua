require("util_functions")
require("player_state\\state_input")
require("player_state\\logic_const")
require("util_role_prop")
local camera_bind_target = false
local camera_in_free_camera = false
control_incamera_close_table = {}
function main_form_init(self)
  self.Fixed = false
  self.no_need_motion_alpha = true
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local scene = nx_value("game_scene")
  local camera = scene.camera
  show_current_prop(self, camera)
  return 1
end
function show_current_prop(form, camera)
  form.pos_x_edit.Text = nx_widestr(camera.PositionX)
  form.pos_y_edit.Text = nx_widestr(camera.PositionY)
  form.pos_z_edit.Text = nx_widestr(camera.PositionZ)
  form.dir_x_edit.Text = nx_widestr(camera.AngleX)
  form.dir_y_edit.Text = nx_widestr(camera.AngleY)
  form.dir_z_edit.Text = nx_widestr(camera.AngleZ)
  form.angle_edit.Text = nx_widestr(nx_int(camera.Fov * 360 / (math.pi * 2) + 0.01))
  form.near_plane_edit.Text = nx_widestr(camera.NearPlane)
  form.far_plane_edit.Text = nx_widestr(camera.FarPlane)
  if camera.AllowControl then
    form.cbtn_allow_control.Checked = true
    form.speed_edit.Text = nx_widestr(camera.move_speed)
    form.drag_speed_edit.Text = nx_widestr(nx_decimals(camera.drag_speed, 2))
    form.yaw_speed_edit.Text = nx_widestr(camera.yaw_speed)
  else
    form.cbtn_allow_control.Checked = false
    form.speed_edit.Text = nx_widestr("10.0")
    form.drag_speed_edit.Text = nx_widestr("0.1")
    form.yaw_speed_edit.Text = nx_widestr(nx_decimals(math.pi / 4, 2))
  end
  if camera_bind_target then
    form.cbtn_camera_target.Checked = true
  else
    form.cbtn_camera_target.Checked = false
  end
  if camera_in_free_camera then
    form.cbtn_allow_control.Checked = true
  else
    form.cbtn_allow_control.Checked = false
  end
  local close_form_num = table.getn(control_incamera_close_table)
  if 0 == close_form_num then
    form.cbtn_hide_form.Checked = false
  else
    form.cbtn_hide_form.Checked = true
  end
  local scene = nx_value("game_scene")
  if nx_find_custom(scene, "player_show") and not scene.player_show then
    form.cbtn_hide_player.Checked = true
  else
    form.cbtn_hide_player.Checked = false
  end
  allow_control_enable(form, camera.AllowControl)
end
function create_camera()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    nx_msgbox(get_msg_str("msg_424"))
    return
  end
  local camera = scene:Create("Camera")
  camera.Fov = 0.125 * math.pi * 2
  nx_bind_logic(camera, "FreeCamera")
  camera:SetPosition(512, 5, 512)
  camera:SetAngle(0, 0, 0)
  camera.allow_wasd = true
  camera.move_speed = 10
  camera.drag_speed = 0.1
  camera.yaw_speed = math.pi / 4
  camera.NearPlane = 0.1
  camera.FarPlane = 2000
  camera.AllowControl = true
  camera:Load()
  scene:AddObject(camera, 0)
  nx_set_value("control_camera", camera)
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetPlayer()
  if nx_is_valid(role) then
    emit_player_input(role, PLAYER_INPUT_LOGIC, LOGIC_BEGIN_FREE_CAMERA)
  end
end
function ok_btn_click(self)
  local scene = nx_value("game_scene")
  local form = self.Parent
  local fov_angle = nx_number(form.angle_edit.Text)
  local near_plane = nx_number(form.near_plane_edit.Text)
  local far_plane = nx_number(form.far_plane_edit.Text)
  if fov_angle < 10 or 180 < fov_angle then
    form_msgbox("\202\211\189\199\211\166\206\17010\181\189180\182\200")
    return 0
  end
  if near_plane < 0.01 or 1 < near_plane then
    form_msgbox("\201\227\207\241\187\250\189\252\178\195\188\244\195\230\211\166\206\1700.01\181\1891.0")
    return 0
  end
  if far_plane < 1000 or 2000 < far_plane then
    form_msgbox("\201\227\207\241\187\250\212\182\178\195\188\244\195\230\211\166\206\1701000\181\1892000")
    return 0
  end
  if form.cbtn_allow_control.Checked then
    local new_camera = nx_value("control_camera")
    if not nx_is_valid(new_camera) then
      scene.old_camera = scene.camera
      scene:RemoveObject(scene.old_camera)
      create_camera()
      new_camera = nx_value("control_camera")
      new_camera:SetPosition(scene.old_camera.PositionX, scene.old_camera.PositionY, scene.old_camera.PositionZ)
      new_camera:SetAngle(scene.old_camera.AngleX, scene.old_camera.AngleY, scene.old_camera.AngleZ)
      camera_in_free_camera = true
    end
    new_camera = nx_value("control_camera")
    local speed = nx_number(form.speed_edit.Text)
    local drag_speed = nx_number(form.drag_speed_edit.Text)
    local yaw_speed = nx_number(form.yaw_speed_edit.Text)
    if speed < 1 or 200 < speed then
      form_msgbox("\201\227\207\241\187\250\210\198\182\175\203\217\182\200\211\166\206\1701\181\189200\195\215\195\191\195\235")
      return 0
    end
    if drag_speed < 0.01 or 1 < drag_speed then
      form_msgbox("\201\227\207\241\187\250\205\207\215\167\203\217\182\200\211\166\206\1700.01\181\1891.0")
      return 0
    end
    new_camera.move_speed = speed
    new_camera.drag_speed = drag_speed
    new_camera.yaw_speed = yaw_speed
    new_camera.Fov = fov_angle / 360 * math.pi * 2
    new_camera.NearPlane = near_plane
    new_camera.FarPlane = far_plane
    scene.game_control.AllowControl = false
    scene.old_camera.AllowControl = false
    new_camera.AllowControl = true
  else
    local new_camera = nx_value("control_camera")
    if nx_is_valid(new_camera) then
      scene:RemoveObject(new_camera)
      scene:Delete(new_camera)
      local game_visual = nx_value("game_visual")
      local role = game_visual:GetPlayer()
      if nx_is_valid(role) then
        emit_player_input(role, PLAYER_INPUT_LOGIC, LOGIC_END_FREE_CAMERA)
      end
      camera_in_free_camera = false
    end
    if nx_find_custom(scene, "old_camera") and nx_is_valid(scene.old_camera) then
      scene:AddObject(scene.old_camera, 0)
      scene.camera = scene.old_camera
    end
    scene.game_control.AllowControl = true
  end
  form:Close()
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_destroy(form)
  return 1
end
function on_cbtn_allow_control_checked_changed(self)
  local form = self.ParentForm
  allow_control_enable(form, self.Checked)
end
function allow_control_enable(form, enable)
  if enable then
    form.speed_edit.Enabled = true
    form.drag_speed_edit.Enabled = true
    form.yaw_speed_edit.Enabled = true
  else
    form.speed_edit.Enabled = false
    form.drag_speed_edit.Enabled = false
    form.yaw_speed_edit.Enabled = false
  end
end
function form_msgbox(msg)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text(msg))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" or res == "cancel" then
    return
  end
end
function on_cbtn_hide_player_checked_changed(cbtn)
  local scene = nx_value("game_scene")
  if cbtn.Checked then
    scene.player_show = false
    nx_execute("console", "hide_player")
  else
    scene.player_show = true
    nx_execute("console", "show_player")
  end
end
function on_cbtn_lock_camera_checked_changed(cbtn)
  if cbtn.Checked then
    nx_execute("console", "camera_pause")
  else
    nx_execute("console", "camera_move")
  end
end
function on_cbtn_camera_target_checked_changed(cbtn)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if cbtn.Checked then
    local select_object = nx_value("select_object")
    local vis_target = game_visual:GetSceneObj(nx_string(select_object))
    if nx_is_valid(vis_target) then
      game_control.Target = vis_target
      game_control.TargetMode = 1
    end
    camera_bind_target = true
  else
    local role = nx_value("role")
    if nx_is_valid(role) then
      game_control.Target = role
      game_control.TargetMode = 0
    end
    camera_bind_target = false
  end
end
function on_btn_show_track_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_test\\form_camera_track")
end
function on_cbtn_hide_form_checked_changed(cbtn)
  local gui = nx_value("gui")
  if cbtn.Checked then
    local childlist = gui.Desktop:GetChildControlList()
    for i = table.maxn(childlist), 1, -1 do
      local control = childlist[i]
      if nx_is_valid(control) and nx_is_kind(control, "Form") and control.Visible then
        local name = nx_script_name(control)
        if name ~= "form_test\\form_camera" then
          control.Visible = false
          table.insert(control_incamera_close_table, control)
        else
        end
      end
    end
    if nx_find_custom(gui.Desktop, "groupbox_4") then
      local temp_control = gui.Desktop.groupbox_4
      if nx_is_valid(temp_control) then
        temp_control.Visible = false
      end
    end
    if nx_find_custom(gui.Desktop, "groupbox_5") then
      temp_control = gui.Desktop.groupbox_5
      if nx_is_valid(temp_control) then
        temp_control.Visible = false
      end
    end
    if nx_find_custom(gui.Desktop, "btn_system") then
      temp_control = gui.Desktop.btn_system
      if nx_is_valid(temp_control) then
        temp_control.Visible = false
      end
    end
    if nx_find_custom(gui.Desktop, "btn_research") then
      temp_control = gui.Desktop.btn_research
      if nx_is_valid(temp_control) then
        temp_control.Visible = false
      end
    end
  else
    for i = table.maxn(control_incamera_close_table), 1, -1 do
      local control = control_incamera_close_table[i]
      control.Visible = true
      table.remove(control_incamera_close_table, i)
    end
    local bIsNewJHModule = is_newjhmodule()
    if not bIsNewJHModule and nx_find_custom(gui.Desktop, "groupbox_4") then
      local temp_control = gui.Desktop.groupbox_4
      if nx_is_valid(temp_control) then
        temp_control.Visible = true
      end
    end
    if nx_find_custom(gui.Desktop, "groupbox_5") then
      temp_control = gui.Desktop.groupbox_5
      if nx_is_valid(temp_control) then
        temp_control.Visible = true
      end
    end
    if nx_find_custom(gui.Desktop, "btn_system") then
      temp_control = gui.Desktop.btn_system
      if nx_is_valid(temp_control) then
        temp_control.Visible = true
      end
    end
    if nx_find_custom(gui.Desktop, "btn_research") then
      temp_control = gui.Desktop.btn_research
      if nx_is_valid(temp_control) then
        temp_control.Visible = true
      end
    end
  end
end
function set_camera_target(obj)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local game_control = scene.game_control
  game_control.TargetMode = 1
  game_control.Target = obj
end
function set_camera_target_by_name(name)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local game_control = scene.game_control
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local scene_obj = game_client:GetScene()
  local scene_obj_table = scene_obj:GetSceneObjList()
  for i, val in ipairs(scene_obj_table) do
    if not nx_is_valid(val) then
      return
    end
    if nx_ws_equal(nx_widestr(name), nx_widestr(val:QueryProp("Name"))) or nx_ws_equal(nx_widestr(name), nx_widestr(util_text(val:QueryProp("ConfigID")))) then
      local target_obj = game_visual:GetSceneObj(val.Ident)
      if nx_is_valid(target_obj) then
        game_control.TargetMode = 1
        game_control.Target = target_obj
      end
    end
  end
end
function reset_camera_target()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local game_control = scene.game_control
  game_control.TargetMode = 0
end
