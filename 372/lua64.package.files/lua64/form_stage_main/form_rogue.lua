require("util_gui")
require("util_functions")
require("custom_sender")
require("role_composite")
require("util_static_data")
local FORM_ROGUE = "form_stage_main\\form_rogue"
local ROGUE_CONFIG = "share\\War\\Rogue\\Rogue.ini"
local ROGUE_CLIENT_MSG_ALERT_CUR = 2
function main_form_init(self)
  self.Fixed = false
  self.alert_add = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "reduce_move_bar", form)
    game_timer:Register(1000, -1, nx_current(), "reduce_move_bar", form, -1, -1)
  end
end
function reduce_move_bar(form)
  if not nx_is_valid(form) then
    return
  end
  local move_bar = form.pbar_move
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_find_custom(client_player, "rogue_move_value") then
    client_player.begin_rogue = true
    client_player.rogue_move_value = 0
  end
  client_player.rogue_move_value = client_player.rogue_move_value - 0.5
  if client_player.rogue_move_value <= 0 then
    client_player.rogue_move_value = 0
  end
  move_bar.Value = client_player.rogue_move_value
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "reduce_move_bar", self)
  end
  nx_destroy(self)
end
function open_test()
  open_form(100, 200)
end
function open_form(...)
  local form = nx_value(FORM_ROGUE)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_ROGUE, true)
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  client_player.begin_rogue = true
  client_player.rogue_move_value = 0
  local form = nx_value(FORM_ROGUE)
  if not nx_is_valid(form) then
    return
  end
  form.pbar_move.Value = 0
  form.pbar_move.Maximum = nx_number(arg[1])
  form.pbar_alert.Maximum = nx_number(arg[2])
  form.pbar_alert.Value = nx_number(arg[3])
  nx_execute(nx_current(), "updata_move_bar")
end
function close_form(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  client_player.begin_rogue = false
  client_player.rogue_move_value = 0
  local form = nx_value(FORM_ROGUE)
  if nx_is_valid(form) then
    on_main_form_close(form)
  end
end
function updata_move_bar()
  nx_pause(0)
  local form = nx_value(FORM_ROGUE)
  if not nx_is_valid(form) then
    return
  end
  local move_bar = form.pbar_move
  local alert_bar = form.pbar_alert
  move_bar.HintText = util_text(nx_string(move_bar.Value) .. nx_string("/") .. nx_string(move_bar.Maximum))
  alert_bar.HintText = util_text(nx_string(alert_bar.Value) .. nx_string("/") .. nx_string(alert_bar.Maximum))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    nx_execute(nx_current(), "updata_move_bar")
    return
  end
  if not nx_find_custom(client_player, "rogue_move_value") then
    nx_execute(nx_current(), "updata_move_bar")
    return
  end
  local cur_move_value = nx_number(client_player.rogue_move_value)
  if cur_move_value >= move_bar.Maximum then
    cur_move_value = move_bar.Maximum
  end
  move_bar.Value = cur_move_value
  if move_bar.Value >= move_bar.Maximum then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROGUE), nx_int(ROGUE_CLIENT_MSG_ALERT_CUR))
  end
  nx_execute(nx_current(), "updata_move_bar")
end
function updata_max_alert_test()
  updata_max_alert(10, 200)
end
function updata_max_alert(...)
  local form = nx_value(FORM_ROGUE)
  if not nx_is_valid(form) then
    return
  end
  local bar_alert = form.pbar_alert
  bar_alert.Maximum = nx_number(arg[2])
  bar_alert.Value = nx_number(arg[1])
end
function updata_max_move(...)
  local form = nx_value(FORM_ROGUE)
  if not nx_is_valid(form) then
    return
  end
  local bar_move = form.pbar_move
  bar_move.Maximum = nx_number(arg[1])
end
function request_quit_rogue()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROGUE), nx_int(0))
end
function custom_rogue_msg(sub_msg, ...)
end
function on_btn_help_click(btn)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "open_form", "")
end
function a(info)
  nx_msgbox(nx_string(info))
end
