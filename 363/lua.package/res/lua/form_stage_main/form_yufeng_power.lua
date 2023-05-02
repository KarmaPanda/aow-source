require("util_gui")
require("util_functions")
require("custom_sender")
require("role_composite")
require("util_static_data")
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 1.5
  return 1
end
function on_main_form_open(form)
  form.Visible = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function server_open_power_skin(form, max_value)
  form.pbar_power.Maximum = max_value
  form.pbar_power.Value = 0
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  client_player.begin_wind_power = true
  client_player.power_time = 0
  form.lbl_liang.Visible = false
  form.lbl_end.Visible = false
  form.lbl_texiao.Visible = false
  nx_execute(nx_current(), "refresh_power")
end
function server_close_power_skin(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  client_player.begin_wind_power = false
  client_player.power_time = 0
  form:Close()
end
function refresh_power()
  nx_pause(0)
  local form = nx_value("form_stage_main\\form_yufeng_power")
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local progress_bar = form.pbar_power
  local lbl_bar = form.lbl_jt
  local min_left = progress_bar.Left
  local current_power = nx_number(client_player.power_time)
  if current_power >= progress_bar.Maximum then
    current_power = progress_bar.Maximum
  end
  progress_bar.Value = current_power
  lbl_bar.Left = min_left + current_power * progress_bar.Width / progress_bar.Maximum - lbl_bar.Width + 10
  if current_power >= progress_bar.Maximum then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WIND_HOLD_POWER_END))
    lbl_bar.Visible = false
    progress_bar.Visible = false
    form.lbl_liang.Visible = true
    form.lbl_end.Visible = true
    form.lbl_texiao.Visible = true
    nx_pause(2)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
    return
  end
  nx_execute(nx_current(), "refresh_power")
end
