function main_form_init(self)
  self.Fixed = false
  self.no_need_motion_alpha = true
  return 1
end
function get_role()
  local role = nx_value("role")
  if not nx_is_valid(role) then
    local select = nx_value("visual_select")
    if nx_is_valid(select) then
      role = select.visual
    end
  else
    local actor_role = role:GetLinkObject("actor_role")
    if nx_is_valid(actor_role) and nx_name(role) == "Actor2" then
      return actor_role
    end
  end
  if not nx_is_valid(role) then
    return nil
  end
  if nx_name(role) ~= "Actor2" then
    return nil
  end
  return role
end
function init_action_control(role)
  local ctrl = nx_create("ActionControl")
  ctrl:AddParameter("speed", 0.5)
  ctrl:AddCommand("start")
  ctrl:AddCommand("stop")
  ctrl:AddState("idle", "", true, 1, true)
  ctrl:AddState("run", "", true, 1, false)
  ctrl:AddState("idle_to_run", "run", false, 1, true)
  ctrl:AddState("run_to_idle", "idle", false, 1, true)
  ctrl:AddStateNode("idle", "root", "", "", "stand", "", "")
  ctrl:AddStateNode("idle_to_run", "root", "", "", "runstart", "", "")
  ctrl:AddStateNode("run", "root", "", "blend", "", "speed", "footstep")
  ctrl:AddStateNode("run", "a1", "root", "", "walk", "", "")
  ctrl:AddStateNode("run", "a2", "root", "", "run", "", "")
  ctrl:AddStateNode("run_to_idle", "root", "", "queue", "", "", "")
  ctrl:AddStateNode("run_to_idle", "a1", "root", "", "runend", "", "")
  ctrl:AddStateNode("run_to_idle", "a2", "root", "", "standfree02", "", "")
  ctrl:AddStateConvert("idle", "start", "idle_to_run")
  ctrl:AddStateConvert("run", "stop", "run_to_idle")
  ctrl:AddState("tleft", "runturnleft", true, 1, true)
  ctrl:AddState("tright", "runturnright", true, 1, true)
  ctrl:AddStateNode("tleft", "root", "", "", "runturnleft", "", "")
  ctrl:AddStateNode("tright", "root", "", "", "runturnright", "", "")
  role.ActionControl = ctrl
  return ctrl
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local role = get_role()
  if nx_is_valid(role) then
    local action_table = role:GetActionList()
    for i = 1, table.getn(action_table) do
      self.action_list:AddString(nx_widestr(action_table[i]))
    end
    local control = role.ActionControl
    if not nx_is_valid(control) then
      control = init_action_control(role)
    end
    local speed = control:GetParameterValue("speed")
    self.param_edit.Text = nx_widestr(speed)
    nx_execute(nx_current(), "show_blend_list", self, role)
  end
  return 1
end
function close_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "test_action_return", "cancel")
  nx_destroy(form)
  return 1
end
function action_list_select_changed(self)
  local form = self.Parent
  local action = nx_string(self.SelectString)
  if action == "" then
    return 0
  end
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  local frame_num = role:GetActionFrame(action)
  form.start_frame_edit.Text = nx_widestr(3)
  form.end_frame_edit.Text = nx_widestr(3 + frame_num)
  form.frame_edit.Text = nx_widestr(3)
  form.speed_edit.Text = nx_widestr(1)
  return 1
end
function action_list_select_double_click(self)
  return 1
end
function frame_track_value_changed(self)
  local form = self.Parent
  local action = nx_string(form.action_list.SelectString)
  if action == "" then
    return 0
  end
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  if nx_running(nx_current(), "play_action") then
    return 0
  end
  local frame_num = role:GetActionFrame(action)
  local frame = math.floor(self.Value / 1000 * (frame_num + 3))
  form.frame_edit.Text = nx_widestr(frame)
  if not role:IsActionBlended(action) then
    role:ClearBlendAction()
    role:BlendAction(action, true, false)
    role:SetBlendActionPause(action, true)
  end
  if frame == frame_num + 3 then
    role:SetCurrentFrameFloat(action, frame - 0.001)
  else
    role:SetCurrentFrame(action, frame)
  end
  return 1
end
function play_btn_click(self)
  local form = self.Parent
  local action = nx_string(form.action_list.SelectString)
  if action == "" then
    return 0
  end
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  if nx_running(nx_current(), "play_action") then
    return 0
  end
  role.play_action_name = action
  role.play_action_frame = 3
  role:ClearBlendAction()
  role:BlendAction(action, true, false)
  local speed = nx_number(form.speed_edit.Text)
  if 0.01 <= speed and speed <= 100 then
    role:SetBlendActionSpeed(action, speed)
  end
  nx_execute(nx_current(), "play_action", form, role)
  return 1
end
function pause_btn_click(self)
  local form = self.Parent
  local action = nx_string(form.action_list.SelectString)
  if action == "" then
    return 0
  end
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  if not nx_running(nx_current(), "play_action") then
    return 0
  end
  local pause = role:GetBlendActionPause(action)
  role:SetBlendActionPause(action, not pause)
  return 1
end
function stop_btn_click(self)
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  role:ClearBlendAction()
  return 1
end
function speed_edit_changed(self)
  local form = self.Parent
  local action = nx_string(form.action_list.SelectString)
  if action == "" then
    return 0
  end
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  local speed = nx_number(self.Text)
  role:SetBlendActionSpeed(action, speed)
  return 1
end
function play_action(form, role)
  while true do
    local seconds = nx_pause(0)
    if not nx_is_valid(form) or not nx_is_valid(role) then
      return false
    end
    local action = role.play_action_name
    if not role:IsActionBlended(action) then
      return false
    end
    local frame_num = role:GetActionFrame(action)
    local cur_frame = role:GetCurrentFrameFloat(action)
    form.frame_edit.Text = nx_widestr(nx_decimals(cur_frame, 1))
    form.frame_track.Enabled = false
    form.frame_track.Value = cur_frame / (frame_num + 3) * 1000
    form.frame_track.Enabled = true
    role.play_action_frame = math.floor(cur_frame)
  end
  return true
end
function show_blend_list(form, role)
  local blend_list = form.blend_list
  while true do
    local seconds = nx_pause(0)
    if not nx_is_valid(form) or not nx_is_valid(role) then
      return false
    end
    blend_list:BeginUpdate()
    blend_list:ClearString()
    local blend_table = role:GetActionBlendList()
    nx_log(nx_string(table.getn(blend_table)) .. " blend actions")
    for i = 1, table.getn(blend_table) do
      local action_name = blend_table[i]
      local frame = role:GetCurrentFrameFloat(action_name)
      local speed = role:GetBlendActionSpeed(action_name)
      local weight = role:GetBlendActionWeight(action_name)
      local info = action_name .. "," .. nx_decimals(speed, 3) .. "," .. nx_decimals(weight, 3) .. "," .. nx_decimals(frame, 2)
      blend_list:AddString(nx_widestr(info))
      nx_log(info)
    end
    blend_list:EndUpdate()
  end
  return true
end
function start_btn_click(self)
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  local control = role.ActionControl
  if not nx_is_valid(control) then
    return 0
  end
  if control.State == "" then
    control.State = "idle"
  end
  control:EmitCommand("start")
  return 1
end
function end_btn_click(self)
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  local control = role.ActionControl
  if not nx_is_valid(control) then
    return 0
  end
  control:EmitCommand("stop")
  return 1
end
function param_edit_changed(self)
  local role = get_role()
  if not nx_is_valid(role) then
    return 0
  end
  local control = role.ActionControl
  if not nx_is_valid(control) then
    return 0
  end
  local speed = nx_number(self.Text)
  control:SetParameterValue("speed", speed)
  return 1
end
