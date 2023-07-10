require("define\\object_type_define")
require("player_state\\state_input")
require("player_state\\logic_const")
require("role_composite")
require("share\\npc_type_define")
require("util_functions")
require("util_gui")
function movie_scene_start()
  local form = nx_value("form_stage_main\\form_movie_effect")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_movie_effect", true, false)
    nx_set_value("form_stage_main\\form_movie_effect", form)
  end
  util_show_form("form_stage_main\\form_movie_effect", true)
end
function movie_scene_end()
  nx_execute(nx_current(), "end_movie")
end
local control_table = {}
function clear_control_table()
  control_table = {}
end
function main_form_init(self)
  self.Fixed = true
  self.esc_key = false
end
function on_main_form_open(form)
  clear_control_table()
  if not init_movie(form) then
    end_movie()
    return
  end
  nx_execute(nx_current(), "down_black_movie", form)
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_movie_effect", nx_null())
end
function init_movie(form)
  local ret = true
  hide_control()
  ret = on_size_change(form)
  form.esc_key = false
  return ret
end
local atanValueMax = 1.57079632685
function get_down_black_distance(sec, maxValue)
  return maxValue / 2 - sec * 100
end
function down_black_movie(form)
  if not nx_is_valid(form) then
    return
  end
  set_control_before_black(form)
  while true do
    local sec = nx_pause(0.01)
    if not nx_is_valid(form) then
      return
    end
    local distancetomove = get_down_black_distance(sec, form.mltbox_down.Height + 1)
    form.mltbox_up.Top = nx_int(form.mltbox_up.Top + distancetomove)
    form.mltbox_down.Top = nx_int(form.mltbox_down.Top - distancetomove)
    if form.mltbox_up.Top >= 0 or form.mltbox_down.Top <= -form.mltbox_down.Height then
      form.mltbox_up.Top = 0
      form.mltbox_down.Top = -form.mltbox_down.Height
      break
    end
  end
end
function hide_control()
  local gui = nx_value("gui")
  local childlist = gui.Desktop:GetChildControlList()
  for i = 1, table.maxn(childlist) do
    local control = childlist[i]
    if nx_is_valid(control) and nx_script_name(control) ~= "form_stage_main\\form_movie_effect" and nx_script_name(control) ~= "form_stage_main\\form_skill_movie" and nx_script_name(control) ~= "form_stage_main\\form_main\\form_main_fightvs_skill" and control.Visible == true then
      control.Visible = false
      table.insert(control_table, control)
    end
  end
end
function add_hide_control(control)
  if nx_is_valid(control) then
    if control.Visible == true then
      control.Visible = false
    end
    table.insert(control_table, control)
  end
end
function show_control()
  for count = 1, table.getn(control_table) do
    if nx_is_valid(control_table[count]) and can_show_control(control_table[count]) and nx_script_name(control_table[count]) ~= "form_stage_main\\form_main\\form_main_fightvs_alone_ex" and nx_script_name(control_table[count]) ~= "form_stage_main\\form_main\\form_main_fightvs_alone" then
      control_table[count].Visible = true
    end
  end
end
function can_show_control(control)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(control) or not nx_is_valid(player) then
    return false
  end
  return true
end
function on_size_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.mltbox_up.Width = gui.Width
  form.mltbox_down.Width = gui.Width
  local dHeight = gui.Height / 8
  form.mltbox_up.AbsTop = 0
  form.mltbox_up.Height = dHeight
  form.mltbox_down.AbsTop = gui.Height - dHeight
  form.mltbox_down.Height = dHeight
  local sWidth = 5
  local sHeight = 2
  local viewLeft = sWidth
  local viewTop = sHeight
  local viewWidth = form.mltbox_up.Width - 2 * sWidth
  local viewHeight = form.mltbox_up.Height - 2 * sHeight
  local viewRectStr = viewLeft .. "," .. viewTop .. "," .. viewWidth .. "," .. viewHeight
  form.mltbox_up.ViewRect = viewRectStr
  form.mltbox_down.ViewRect = viewRectStr
  return true
end
function set_control_before_black(form)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_up.VAnchor = "Top"
  form.mltbox_down.VAnchor = "Bottom"
  form.mltbox_up.Top = -form.mltbox_up.Height
  form.mltbox_down.Top = 0
end
function clear_movie_text()
  local form_movie_effect = nx_value("form_stage_main\\form_movie_effect")
  if not nx_is_valid(form_movie_effect) then
    return
  end
  if nx_running(nx_current(), "form_movie_tick") then
    nx_kill(nx_current(), "form_movie_tick")
  end
  form_movie_effect.mltbox_down:Clear()
end
function end_movie()
  local form_movie_effect = nx_value("form_stage_main\\form_movie_effect")
  if not nx_is_valid(form_movie_effect) then
    return
  end
  clear_movie_text()
  while true do
    local sec = nx_pause(0.01)
    if not nx_is_valid(form_movie_effect) then
      return
    end
    local distancetomove = sec * 100
    form_movie_effect.mltbox_up.Top = nx_int(form_movie_effect.mltbox_up.Top - distancetomove)
    form_movie_effect.mltbox_down.Top = nx_int(form_movie_effect.mltbox_down.Top + distancetomove)
    if form_movie_effect.mltbox_up.Top <= -form_movie_effect.mltbox_up.Height or form_movie_effect.mltbox_down.Top >= 0 then
      form_movie_effect.mltbox_up.Top = -form_movie_effect.mltbox_up.Height
      form_movie_effect.mltbox_down.Top = 0
      break
    end
  end
  show_control()
  form_movie_effect:Close()
  nx_gen_event(nx_null(), "form_movie_effect_end")
end
function getCameraOnlyYawDistance()
  return 5
end
function getCameraOnlyYawPitch()
  return 0.2
end
function getCameraOnlyYawDeflect()
  return 0.3
end
