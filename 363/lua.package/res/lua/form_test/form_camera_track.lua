require("util_functions")
require("player_state\\state_input")
require("player_state\\logic_const")
local camera_pos_tab = {}
function main_form_init(self)
  self.Fixed = false
  self.no_need_motion_alpha = true
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  show_current_prop(self)
  nx_set_value("form_camera_track", self)
  return 1
end
function on_main_form_close(form)
  nx_set_value("form_camera_track", nx_null())
  nx_destroy(form)
  return 1
end
function show_current_prop(form)
  local scene = nx_value("game_scene")
  local camera = scene.camera
  form.pos_x_edit.Text = nx_widestr(camera.PositionX)
  form.pos_y_edit.Text = nx_widestr(camera.PositionY)
  form.pos_z_edit.Text = nx_widestr(camera.PositionZ)
  form.dir_x_edit.Text = nx_widestr(camera.AngleX)
  form.dir_y_edit.Text = nx_widestr(camera.AngleY)
  form.dir_z_edit.Text = nx_widestr(camera.AngleZ)
  if nx_find_custom(scene, "free_camera") and scene.free_camera == 1 then
    form.cbtn_free_camera.Checked = true
  else
    form.cbtn_free_camera.Checked = false
  end
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
  local form = self.Parent
  stop_look_camera_pos_info(form)
  clear_camera_pos_info(form)
  form:Close()
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  stop_look_camera_pos_info(form)
  clear_camera_pos_info(form)
  form:Close()
  return 1
end
function on_cbtn_free_camera_checked_changed(cbtn)
  local scene = nx_value("game_scene")
  if cbtn.Checked == true then
    local new_camera = nx_value("control_camera")
    if not nx_is_valid(new_camera) then
      scene.old_camera = scene.camera
      scene:RemoveObject(scene.old_camera)
      create_camera()
      new_camera = nx_value("control_camera")
      new_camera:SetPosition(scene.old_camera.PositionX, scene.old_camera.PositionY, scene.old_camera.PositionZ)
      new_camera:SetAngle(scene.old_camera.AngleX, scene.old_camera.AngleY, scene.old_camera.AngleZ)
    end
    new_camera = nx_value("control_camera")
    local speed = 10
    local drag_speed = 0.5
    local yaw_speed = 0.5
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
    new_camera.Fov = 0.14166666666666666 * math.pi * 2
    new_camera.NearPlane = 0.1
    new_camera.FarPlane = 100
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
    end
    if nx_find_custom(scene, "old_camera") and nx_is_valid(scene.old_camera) then
      scene:AddObject(scene.old_camera, 0)
      scene.camera = scene.old_camera
    end
    scene.game_control.AllowControl = true
  end
end
function on_btn_updata_pos_click(btn)
  local form = btn.ParentForm
  local scene = nx_value("game_scene")
  if form.cbtn_free_camera.Checked == true then
    local camera = nx_value("control_camera")
    form.pos_x_edit.Text = nx_widestr(camera.PositionX)
    form.pos_y_edit.Text = nx_widestr(camera.PositionY)
    form.pos_z_edit.Text = nx_widestr(camera.PositionZ)
    form.dir_x_edit.Text = nx_widestr(camera.AngleX)
    form.dir_y_edit.Text = nx_widestr(camera.AngleY)
    form.dir_z_edit.Text = nx_widestr(camera.AngleZ)
  else
    local camera = scene.camera
    form.pos_x_edit.Text = nx_widestr(camera.PositionX)
    form.pos_y_edit.Text = nx_widestr(camera.PositionY)
    form.pos_z_edit.Text = nx_widestr(camera.PositionZ)
    form.dir_x_edit.Text = nx_widestr(camera.AngleX)
    form.dir_y_edit.Text = nx_widestr(camera.AngleY)
    form.dir_z_edit.Text = nx_widestr(camera.AngleZ)
  end
end
function on_btn_goto_click(btn)
  local form = btn.ParentForm
  if form.cbtn_free_camera.Checked ~= true then
    nx_msgbox(get_msg_str("msg_425"))
    return
  end
  new_camera = nx_value("control_camera")
  new_camera:SetPosition(nx_float(form.pos_x_edit.Text), nx_float(form.pos_y_edit.Text), nx_float(form.pos_z_edit.Text))
  new_camera:SetAngle(nx_float(form.dir_x_edit.Text), nx_float(form.dir_y_edit.Text), nx_float(form.dir_z_edit.Text))
end
function on_btn_start_look_click(btn)
  if nx_running(nx_current(), "cyc_look_camera_pos") then
    nx_kill(nx_current(), "cyc_look_camera_pos")
  end
  nx_execute(nx_current(), "cyc_look_camera_pos")
end
function on_btn_end_look_click(btn)
  stop_look_camera_pos_info(btn.ParentForm)
end
function on_btn_clear_look_click(btn)
  local form = btn.ParentForm
  clear_camera_pos_info(form)
end
function cyc_look_camera_pos()
  local form = nx_value("form_camera_track")
  while true do
    if not nx_is_valid(form) then
      return
    end
    local freq_time = nx_float(form.fipt_freq.Text)
    nx_pause(nx_float(freq_time))
    look_camera_pos(form)
  end
end
function look_camera_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local scene = nx_value("game_scene")
  local camera
  if form.cbtn_free_camera.Checked == true then
    camera = nx_value("control_camera")
  else
    camera = scene.camera
  end
  local text = " pos_x=" .. string.format("%.3f", camera.PositionX) .. " pos_x=" .. string.format("%.3f", camera.PositionY) .. " pos_x=" .. string.format("%.3f", camera.PositionZ) .. " dir_x=" .. string.format("%.3f", camera.AngleX) .. " dir_y=" .. string.format("%.3f", camera.AngleY) .. " dir_z=" .. string.format("%.3f", camera.AngleZ)
  form.mltbox_camera_pos:AddHtmlText(nx_widestr(text), -1)
  local effect_model = scene:Create("EffectModel")
  effect_model:CreateFromIni("ini\\effect\\model.ini", "npcitem002", false)
  if not nx_is_valid(effect_model) then
    scene:Delete(effect_model)
    return
  end
  effect_model.Loop = true
  local terrain = scene.terrain
  terrain:AddVisual("", effect_model)
  terrain:RelocateVisual(effect_model, camera.PositionX, camera.PositionY, camera.PositionZ)
  effect_model:SetAngle(camera.AngleX, camera.AngleY, camera.AngleZ)
  table.insert(camera_pos_tab, effect_model)
end
function stop_look_camera_pos_info(form)
  if nx_running(nx_current(), "cyc_look_camera_pos") then
    nx_kill(nx_current(), "cyc_look_camera_pos")
  end
end
function clear_camera_pos_info(form)
  form.mltbox_camera_pos:Clear()
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  while table.getn(camera_pos_tab) > 0 do
    local effect_model = table.remove(camera_pos_tab)
    if nx_is_valid(effect_model) then
      terrain:RemoveVisual(effect_model)
      scene:Delete(effect_model)
    end
  end
end
