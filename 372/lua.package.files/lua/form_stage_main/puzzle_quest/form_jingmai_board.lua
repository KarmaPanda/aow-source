function board_init(self)
  self.Fixed = false
end
function on_pbar_fill_get_capture(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form = nx_value(nx_current())
  local jewel_game_manager = nx_value("jewel_game_manager")
  local next_gate = client_player:QueryProp("CurGate") + 1
  local cur_level = client_player:QueryProp("CurLevel")
  local next_max_gate_faculty = client_player:QueryProp("TotalFillValue")
  if next_max_gate_faculty <= 0 then
    next_max_gate_faculty = jewel_game_manager:GetFacultyGateFillValue(nx_string(form.wuxue_name), nx_number(cur_level), nx_number(next_gate))
  end
  local tip_text = nx_widestr(nx_string(client_player:QueryProp("CurFillValue")) .. "/" .. nx_string(next_max_gate_faculty))
  nx_execute("tips_game", "show_text_tip", tip_text, form.pbar_fill.AbsLeft, form.pbar_fill.AbsTop, 0, form)
end
function on_pbar_fill_lost_capture(self)
  local form = nx_value(nx_current())
  nx_execute("tips_game", "hide_tip", form)
end
