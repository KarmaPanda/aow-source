local MAX_SQR_DISPLACE = 10000
local SYS_SQR_DISPLACE = 6400
function init(form)
  form.Fixed = false
  form.step = 0.1
  form.sqr_displace = 0
  form.fir_sys = false
end
function on_main_form_open(form)
  form.edit_name.Text = nx_widestr(form.camera_name)
  form.fipt_x.Text = nx_widestr(form.pos_x)
  form.fipt_y.Text = nx_widestr(form.pos_y)
  form.fipt_z.Text = nx_widestr(form.pos_z)
  form.fipt_angle_x.Text = nx_widestr(form.angle_x)
  form.fipt_angle_y.Text = nx_widestr(form.angle_y)
  form.fipt_angle_z.Text = nx_widestr(form.angle_z)
  if form.move_mode == "accelerate" then
    form.rbtn_accelerate.Checked = true
  elseif "decelerate" == form.move_mode then
    form.rbtn_decelerate.Checked = true
  elseif "direct" == form.move_mode then
    form.rbtn_direct.Checked = true
  else
    form.rbtn_smooth.Checked = true
  end
  form.fipt_step.Text = nx_widestr(form.step)
  form.fipt_x.Format = nx_widestr("%.2f")
  form.fipt_y.Format = nx_widestr("%.2f")
  form.fipt_z.Format = nx_widestr("%.2f")
  form.fipt_angle_x.Format = nx_widestr("%.2f")
  form.fipt_angle_y.Format = nx_widestr("%.2f")
  form.fipt_angle_z.Format = nx_widestr("%.2f")
  form.fipt_step.Format = nx_widestr("%.2f")
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister("form_stage_main\\form_camera\\form_save_camera_edit_point", "refresh_systeminfo", form)
    timer:Register(5000, -1, "form_stage_main\\form_camera\\form_save_camera_edit_point", "refresh_systeminfo", form, -1, -1)
  end
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister("form_stage_main\\form_camera\\form_save_camera_edit_point", "refresh_systeminfo", form)
  end
  nx_gen_event(form, "camera_point_edit_return", "cancel")
  if not nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "camera_point_edit_return", "cancel")
  form:Close()
end
function on_pos_changed(self)
  local form = self.ParentForm
  local obj = form.edit_camera
  if not nx_is_valid(obj) then
    return
  end
  local form = self.ParentForm
  local x = nx_string(form.fipt_x.Text)
  local y = nx_string(form.fipt_y.Text)
  local z = nx_string(form.fipt_z.Text)
  nx_execute("form_stage_main\\form_camera\\form_save_camera", "relocate_obj", obj, x, y, z)
end
function on_angle_changed(self)
  local form = self.ParentForm
  local obj = form.edit_camera
  if not nx_is_valid(obj) then
    return
  end
  local form = self.ParentForm
  local x = nx_string(form.fipt_angle_x.Text)
  local y = nx_string(form.fipt_angle_y.Text)
  local z = nx_string(form.fipt_angle_z.Text)
  nx_execute("form_stage_main\\form_camera\\form_save_camera", "reangle_obj", obj, x, y, z)
end
function set_step_drag(form)
  form.fipt_x.DragStep = form.step
  form.fipt_y.DragStep = form.step
  form.fipt_z.DragStep = form.step
  form.fipt_angle_x.DragStep = form.step
  form.fipt_angle_y.DragStep = form.step
  form.fipt_angle_z.DragStep = form.step
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  local role = nx_value("role")
  if nx_is_valid(role) then
    local self_x = role.PositionX
    local self_y = role.PositionY
    local self_z = role.PositionZ
    local sqr_displace = (self_x - nx_number(form.fipt_x.Text)) * (self_x - nx_number(form.fipt_x.Text)) + (self_y - nx_number(form.fipt_y.Text)) * (self_y - nx_number(form.fipt_y.Text)) + (self_z - nx_number(form.fipt_z.Text)) * (self_z - nx_number(form.fipt_z.Text))
    if sqr_displace > MAX_SQR_DISPLACE then
      form.fipt_x.Text = nx_widestr(form.pos_x)
      form.fipt_y.Text = nx_widestr(form.pos_y)
      form.fipt_z.Text = nx_widestr(form.pos_z)
      form.fipt_x.Format = nx_widestr("%.2f")
      form.fipt_y.Format = nx_widestr("%.2f")
      form.fipt_z.Format = nx_widestr("%.2f")
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        local text = gui.TextManager:GetText("845002")
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(text, 2)
        end
      end
      return
    end
  end
  form.pos_x = nx_number(form.fipt_x.Text)
  form.pos_y = nx_number(form.fipt_y.Text)
  form.pos_z = nx_number(form.fipt_z.Text)
  form.angle_x = nx_number(form.fipt_angle_x.Text)
  form.angle_y = nx_number(form.fipt_angle_y.Text)
  form.angle_z = nx_number(form.fipt_angle_z.Text)
  local form_camera_pointinfo = nx_value("form_stage_main\\form_camera\\form_save_camera")
  form_camera_pointinfo.pos_x = form.pos_x
  form_camera_pointinfo.pos_y = form.pos_y
  form_camera_pointinfo.pos_z = form.pos_z
  form_camera_pointinfo.angle_x = form.angle_x
  form_camera_pointinfo.angle_y = form.angle_y
  form_camera_pointinfo.angle_z = form.angle_z
  form_camera_pointinfo.move_mode = form.move_mode
  nx_gen_event(form, "camera_point_edit_return", "save")
  form:Close()
end
function on_btn_get_pos_click(btn)
  local form = btn.ParentForm
  local camera = nx_value("control_camera")
  if nx_is_valid(camera) then
    local role = nx_value("role")
    if nx_is_valid(role) then
      local self_x = role.PositionX
      local self_y = role.PositionY
      local self_z = role.PositionZ
      local sqr_displace = (self_x - camera.PositionX) * (self_x - camera.PositionX) + (self_y - camera.PositionY) * (self_y - camera.PositionY) + (self_z - camera.PositionZ) * (self_z - camera.PositionZ)
      if sqr_displace > MAX_SQR_DISPLACE then
        local gui = nx_value("gui")
        if nx_is_valid(gui) then
          local text = gui.TextManager:GetText("845003")
          local SystemCenterInfo = nx_value("SystemCenterInfo")
          if nx_is_valid(SystemCenterInfo) then
            SystemCenterInfo:ShowSystemCenterInfo(text, 2)
          end
        end
        return
      end
    end
    form.fipt_x.Text = nx_widestr(camera.PositionX)
    form.fipt_y.Text = nx_widestr(camera.PositionY)
    form.fipt_z.Text = nx_widestr(camera.PositionZ)
    form.fipt_angle_x.Text = nx_widestr(camera.AngleX)
    form.fipt_angle_y.Text = nx_widestr(camera.AngleY)
    form.fipt_angle_z.Text = nx_widestr(camera.AngleZ)
    form.fipt_x.Format = nx_widestr("%.2f")
    form.fipt_y.Format = nx_widestr("%.2f")
    form.fipt_z.Format = nx_widestr("%.2f")
    form.fipt_angle_x.Format = nx_widestr("%.2f")
    form.fipt_angle_y.Format = nx_widestr("%.2f")
    form.fipt_angle_z.Format = nx_widestr("%.2f")
  else
    return
  end
end
function on_rbtn_smooth_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.move_mode = "smooth"
  end
end
function on_rbtn_accelerate_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.move_mode = "accelerate"
  end
end
function on_rbtn_decelerate_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.move_mode = "decelerate"
  end
end
function on_rbtn_direct_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.move_mode = "direct"
  end
end
function on_btn_deX_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_x.Text)
  value = value - form.step
  form.fipt_x.Text = nx_widestr(value)
end
function on_btn_deY_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_y.Text)
  value = value - form.step
  form.fipt_y.Text = nx_widestr(value)
end
function on_btn_deZ_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_z.Text)
  value = value - form.step
  form.fipt_z.Text = nx_widestr(value)
end
function on_btn_deAX_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_angle_x.Text)
  value = value - form.step
  form.fipt_angle_x.Text = nx_widestr(value)
end
function on_btn_deAY_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_angle_y.Text)
  value = value - form.step
  form.fipt_angle_y.Text = nx_widestr(value)
end
function on_btn_deAZ_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_angle_z.Text)
  value = value - form.step
  form.fipt_angle_z.Text = nx_widestr(value)
end
function on_btn_inX_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_x.Text)
  value = value + form.step
  form.fipt_x.Text = nx_widestr(value)
end
function on_btn_inY_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_y.Text)
  value = value + form.step
  form.fipt_y.Text = nx_widestr(value)
end
function on_btn_inZ_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_z.Text)
  value = value + form.step
  form.fipt_z.Text = nx_widestr(value)
end
function on_btn_inAX_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_angle_x.Text)
  value = value + form.step
  form.fipt_angle_x.Text = nx_widestr(value)
end
function on_btn_inAY_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_angle_y.Text)
  value = value + form.step
  form.fipt_angle_y.Text = nx_widestr(value)
end
function on_btn_inAZ_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_angle_z.Text)
  value = value + form.step
  form.fipt_angle_z.Text = nx_widestr(value)
end
function on_btn_deStep_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_step.Text)
  value = value / 10
  if value < 0.01 then
    value = 0.01
  end
  form.fipt_step.Text = nx_widestr(value)
  form.step = value
  set_step_drag(form)
end
function on_btn_inStep_click(btn)
  local form = btn.ParentForm
  local value = nx_number(form.fipt_step.Text)
  value = value * 10
  if 10 < value then
    value = 10
  end
  form.fipt_step.Text = nx_widestr(value)
  form.step = value
  set_step_drag(form)
end
function on_fipt_step_changed(self)
  local form = self.ParentForm
  local value = nx_number(form.fipt_step.Text)
  form.step = value
  set_step_drag(form)
end
function on_mouse_wheel_is_overstep()
  local form = nx_value("form_stage_main\\form_camera\\form_save_camera_edit_point")
  if nx_is_valid(form) then
    local camera = nx_value("control_camera")
    if nx_is_valid(camera) then
      local role = nx_value("role")
      if nx_is_valid(role) then
        local self_x = role.PositionX
        local self_y = role.PositionY
        local self_z = role.PositionZ
        local sqr_displace = (self_x - camera.PositionX) * (self_x - camera.PositionX) + (self_y - camera.PositionY) * (self_y - camera.PositionY) + (self_z - camera.PositionZ) * (self_z - camera.PositionZ)
        if sqr_displace > MAX_SQR_DISPLACE then
          camera:SetPosition(form.pos_x, form.pos_y, form.pos_z)
          form.fir_sys = false
        elseif sqr_displace > SYS_SQR_DISPLACE then
          if not form.fir_sys then
            local gui = nx_value("gui")
            if nx_is_valid(gui) then
              local text = gui.TextManager:GetText("845004")
              local SystemCenterInfo = nx_value("SystemCenterInfo")
              if nx_is_valid(SystemCenterInfo) then
                SystemCenterInfo:ShowSystemCenterInfo(text, 2)
              end
            end
            form.fir_sys = true
          end
        else
          form.fir_sys = false
        end
        form.sqr_displace = sqr_displace
      end
    end
  end
end
function refresh_systeminfo(form)
  if MAX_SQR_DISPLACE >= form.sqr_displace and SYS_SQR_DISPLACE < form.sqr_displace then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      local text = gui.TextManager:GetText("845004")
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      end
    end
  end
end
