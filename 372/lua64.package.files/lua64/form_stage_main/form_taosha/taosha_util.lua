require("util_gui")
require("util_functions")
require("custom_sender")
require("define\\team_rec_define")
local taosha_player_prop_player_state = "TaoShaPlayerState"
local TEAM_REC = "team_rec"
local cur_see_teammate_name = ""
function request_quit_taosha()
  custom_taosha(nx_int(102))
end
function get_player_taosha_state()
  local player = get_player()
  if not nx_is_valid(player) then
    return nx_int(0)
  end
  if not player:FindProp(taosha_player_prop_player_state) then
    return nx_int(0)
  end
  return nx_int(player:QueryProp(taosha_player_prop_player_state))
end
function is_in_taosha_scene()
  return get_player_taosha_state() > nx_int(0)
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function get_next_teammate_name(see_name)
  local player = get_player()
  if not nx_is_valid(player) then
    return nx_widestr("")
  end
  local rows = player:GetRecordRows(TEAM_REC)
  if rows <= 1 then
    return nx_widestr("")
  end
  local self_name = nx_widestr(player:QueryProp("Name"))
  local cur_see_row = -1
  for row = 0, rows - 1 do
    local name = player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_NAME)
    if nx_widestr(name) == nx_widestr(see_name) then
      cur_see_row = row
      break
    end
  end
  local next_see_row = cur_see_row + 1
  for i = 1, rows do
    if rows <= next_see_row then
      next_see_row = 0
    end
    if next_see_row == cur_see_row then
      break
    end
    local name = player:QueryRecord(TEAM_REC, next_see_row, TEAM_REC_COL_NAME)
    if nx_widestr(name) ~= nx_widestr(self_name) and nx_widestr(name) ~= nx_widestr(see_name) then
      return nx_widestr(name)
    end
    next_see_row = next_see_row + 1
  end
  return nx_widestr("")
end
function see_teammate()
  local next_teammate_name = get_next_teammate_name(nx_widestr(cur_see_teammate_name))
  custom_taosha(nx_int(108), next_teammate_name)
  cur_see_teammate_name = next_teammate_name
end
function see_other()
  custom_taosha(nx_int(108), nx_widestr(""))
end
function clear_see_state()
  nx_execute("form_stage_main\\form_taosha\\see_util", "stop_see")
  cur_see_teammate_name = ""
end
function has_teammate()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  local rows = player:GetRecordRows(TEAM_REC)
  return 1 < rows
end
function confirm_quit()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = util_format_string("sys_activity_918_05")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    request_quit_taosha()
    return true
  end
  return false
end
function reset_scene()
  nx_execute("form_stage_main\\form_taosha\\form_taosha_awards", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_notice", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_rank1", "close_form")
  nx_execute("form_stage_main\\form_taosha\\see_util", "reset_scene")
  local taoShaManager = nx_value("TaoShaManager")
  if nx_is_valid(taoShaManager) then
    taoShaManager:ReleaseResource()
  end
end
function is_dead()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("Dead") then
    return false
  end
  local dead = nx_int(player:QueryProp("Dead"))
  return dead == nx_int(1)
end
function game_key_down(gui, key, shift, ctrl)
  if shift or ctrl then
    return
  end
  if key == "SPACE" or key == "Space" then
    if not is_dead() then
      return
    end
    nx_execute("form_stage_main\\form_taosha\\form_taosha_awards", "on_btn_see_click")
    return
  end
end
function show_snow_warn_animation()
  local gui = nx_value("gui")
  local animation_1_left = gui.Width / 12
  local animation_1_top = gui.Height / 5
  local animation_1 = show_animation("suoquan_1", animation_1_left, gui.Height / 5)
  local animation_2 = show_animation("second_ten", animation_1_left + 128, animation_1_top + 53)
end
function show_animation(ani_name, left, top)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = nx_string(ani_name)
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = left
  animation.Top = top
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "end_animation")
  animation:Play()
  return animation
end
function end_animation(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
