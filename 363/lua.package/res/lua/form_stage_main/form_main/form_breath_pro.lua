function console_log_down(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Out(info)
  end
end
function main_form_init(self)
  self.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(self)
  change_form_size()
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurUnderWaterValue", "float", self, nx_current(), "on_cur_under_water_value_changed")
  end
end
function change_form_size()
  local self = nx_value("form_stage_main\\form_main\\form_breath_pro")
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  self.Top = desktop.Height * 0.65
  self.Left = (desktop.Width - self.Width) / 2
end
function begin_easy_progress()
  local progress_form = nx_null()
  if nx_find_value("Easy_ProgressBar") then
    progress_form = nx_value("Easy_ProgressBar")
  end
  local scale = 100
  if not nx_is_valid(progress_form) then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_main\\form_breath_pro")
    progress_form = nx_value("form_stage_main\\form_main\\form_breath_pro")
    if not nx_is_valid(progress_form) then
      return
    end
    local progress = progress_form.pbar_1
    local MAX_Length = 82 * scale
    progress.Minimum = 0
    progress.Maximum = MAX_Length
    progress.Value = MAX_Length
    nx_set_value("Easy_ProgressBar", progress_form)
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local cur_real_value = client_player:QueryProp("CurUnderWaterValue")
  progress_form.pbar_1.Value = cur_real_value * scale
  progress_form:Show()
  progress_form.Visible = true
  progress_form.pbar_1.Visible = true
  if nx_int(cur_real_value) >= nx_int(82) then
    if not nx_running(nx_current(), "do_lasting_op") then
      nx_execute(nx_current(), "do_lasting_op")
    end
  elseif nx_running(nx_current(), "do_lasting_op") then
    nx_kill(nx_current(), "do_lasting_op")
  end
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("change_alpha", progress_form)
  asynor:AddExecute("change_alpha", progress_form, nx_float(0.2), nx_int(255), nx_int(40))
end
function do_loading()
  local progress_form = nx_value("Easy_ProgressBar")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(progress_form) or not nx_is_valid(client_player) then
    return
  end
  local progress = progress_form.pbar_1
  local scale = 100
  local MAX_Length = 82 * scale
  local curvalue = progress.Value
  local sync_speed = 1
  while true do
    local sep = nx_pause(0)
    if not nx_is_valid(progress_form) or not nx_is_valid(client_player) then
      return
    end
    progress = progress_form.pbar_1
    if not client_player:FindProp("UnderWaterSpeed") or not client_player:FindProp("CurUnderWaterValue") then
      delete_easy_progress()
      return
    end
    local underwater_speed = client_player:QueryProp("UnderWaterSpeed")
    local cur_real_value = client_player:QueryProp("CurUnderWaterValue")
    underwater_speed = nx_number(underwater_speed) * scale
    sync_speed = 1
    local distance = nx_number(cur_real_value) * scale - nx_number(curvalue)
    if math.abs(distance) > nx_number(7) * scale then
      if nx_number(underwater_speed) < nx_number(0) then
        if nx_number(distance) < nx_number(0) then
          sync_speed = 1.3
        elseif nx_number(distance) > nx_number(0) then
          sync_speed = 0.7
        end
      elseif nx_number(underwater_speed) > nx_number(0) then
        if nx_number(distance) < nx_number(0) then
          sync_speed = 0.7
        elseif nx_number(distance) > nx_number(0) then
          sync_speed = 1.3
        end
      end
    end
    if not nx_find_custom(progress, "time") then
      progress.time = 0
    end
    if nx_int(cur_real_value) == nx_int(82) then
      progress.time = nx_number(progress.time) + nx_number(sep)
    else
      progress.time = 0
    end
    local change_value = nx_number(sep) * nx_number(underwater_speed) * nx_number(sync_speed)
    curvalue = nx_number(curvalue) + nx_number(change_value)
    if nx_int(curvalue) < nx_int(0) then
      curvalue = 0
    elseif nx_int(curvalue) > nx_int(MAX_Length) then
      curvalue = nx_int(MAX_Length)
    end
    progress.Value = curvalue
    if nx_number(progress.time) >= nx_number(1.8) and client_player:FindProp("CurBreathState") then
      local cur_state = client_player:QueryProp("CurBreathState")
      if nx_int(cur_state) == nx_int(0) then
        local asynor = nx_value("common_execute")
        asynor:RemoveExecute("change_alpha", progress_form)
        asynor:AddExecute("change_alpha", progress_form, nx_float(0.2), nx_int(10), nx_int(-40))
        return
      end
    end
  end
end
function end_easy_progress()
  if nx_running(nx_current(), "do_lasting_op") then
    nx_kill(nx_current(), "do_lasting_op")
  end
  delete_easy_progress()
end
function delete_easy_progress()
  local gui = nx_value("gui")
  local progress_form = nx_value("Easy_ProgressBar")
  if nx_is_valid(progress_form) then
    progress_form.Visible = false
  end
end
function on_cur_under_water_value_changed()
  local scale = 100
  progress_form = nx_value("form_stage_main\\form_main\\form_breath_pro")
  if not nx_is_valid(progress_form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local cur_real_value = client_player:QueryProp("CurUnderWaterValue")
  progress_form.pbar_1.Value = cur_real_value * scale
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("change_alpha", progress_form)
  asynor:AddExecute("change_alpha", progress_form, nx_float(0.2), nx_int(255), nx_int(40))
  if nx_int(cur_real_value) >= nx_int(82) then
    if not nx_running(nx_current(), "do_lasting_op") then
      nx_execute(nx_current(), "do_lasting_op")
    end
  elseif nx_running(nx_current(), "do_lasting_op") then
    nx_kill(nx_current(), "do_lasting_op")
  end
end
function do_lasting_op()
  progress_form = nx_value("form_stage_main\\form_main\\form_breath_pro")
  if not nx_is_valid(progress_form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  while true do
    local sep = nx_pause(0)
    if not nx_is_valid(progress_form) or not nx_is_valid(client_player) then
      return
    end
    progress = progress_form.pbar_1
    if not client_player:FindProp("UnderWaterSpeed") or not client_player:FindProp("CurUnderWaterValue") then
      delete_easy_progress()
      return
    end
    if not nx_find_custom(progress, "time") then
      progress.time = 0
    end
    local cur_real_value = client_player:QueryProp("CurUnderWaterValue")
    if nx_int(cur_real_value) == nx_int(82) then
      progress.time = nx_number(progress.time) + nx_number(sep)
    else
      progress.time = 0
    end
    if nx_number(progress.time) >= nx_number(1.8) and client_player:FindProp("CurBreathState") then
      local cur_state = client_player:QueryProp("CurBreathState")
      if nx_int(cur_state) == nx_int(0) then
        local asynor = nx_value("common_execute")
        asynor:RemoveExecute("change_alpha", progress_form)
        asynor:AddExecute("change_alpha", progress_form, nx_float(0.2), nx_int(10), nx_int(-40))
        return
      end
    end
  end
end
