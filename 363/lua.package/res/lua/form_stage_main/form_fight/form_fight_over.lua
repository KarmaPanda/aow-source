require("utils")
require("util_gui")
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  init_form_data(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_main_form_shut(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_arena_leave")
  form:Close()
end
function init_form_data(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local player_name_a = client_scene:QueryProp("PlayerA")
  local player_name_b = client_scene:QueryProp("PlayerB")
  local player_name_gm = client_scene:QueryProp("PlayerGM")
  local WinRound = client_scene:QueryProp("WinRound")
  local TotalRound = client_scene:QueryProp("TotalRound")
  form.lbl_player_1.Text = nx_widestr(player_name_a)
  form.lbl_player_2.Text = nx_widestr(player_name_b)
end
