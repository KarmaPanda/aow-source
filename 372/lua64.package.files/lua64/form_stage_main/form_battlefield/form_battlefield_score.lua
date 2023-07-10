local FORM_BATTLEFIELD_SCORE = "form_stage_main\\form_battlefield\\form_battlefield_score"
local SIGN_IMAGE = {
  "gui\\language\\ChineseS\\battlefield\\battle_z.png",
  "gui\\language\\ChineseS\\battlefield\\battle_f.png"
}
local SHUZITUPIAN = {
  "gui\\special\\clone\\0.png",
  "gui\\special\\clone\\1.png",
  "gui\\special\\clone\\2.png",
  "gui\\special\\clone\\3.png",
  "gui\\special\\clone\\4.png",
  "gui\\special\\clone\\5.png",
  "gui\\special\\clone\\6.png",
  "gui\\special\\clone\\7.png",
  "gui\\special\\clone\\8.png",
  "gui\\special\\clone\\9.png"
}
function init_form(form)
  form.Fixed = true
  form.score_show = false
  form.jianqi_show = false
  form.countdiff_show = false
  form.help_show = false
end
function on_main_form_open(form)
  form.ani_1.Visible = false
  form.ani_2.Visible = false
  form.pbar_1.Visible = false
  form.pbar_2.Visible = false
  form.lbl_1.Visible = false
  form.lbl_2.Visible = false
  form.lbl_3.Visible = false
  form.lbl_4.Visible = false
  form.lbl_kill_diff_1.Visible = false
  form.lbl_kill_diff_2.Visible = false
  form.lbl_kill_diff_3.Visible = false
  form.lbl_kill_diff_4.Visible = false
  form.lbl_kill_diff_5.Visible = false
  form.pbar_1.Value = 0
  form.pbar_2.Value = 0
  form.btn_request_help.Visible = false
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_ani_1_animation_end(ani)
  local form = ani.ParentForm
  ani.Visible = false
end
function on_ani_2_animation_end(ani)
  local form = ani.ParentForm
  ani.Visible = false
end
function close_form(form)
  if form.score_show == false and form.jianqi_show == false and form.countdiff_show == false and form.help_show == false then
    form:Close()
  end
end
function DisplayScore(arg1, ...)
  local form = nx_null()
  local kill_count = nx_number(arg1)
  if kill_count < 0 then
    form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, false)
  else
    form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, true)
  end
  if not nx_is_valid(form) then
    return 0
  end
  if kill_count < 0 then
    form.score_show = false
    close_form(form)
    return 0
  end
  form.score_show = true
  nx_execute("util_gui", "util_show_form", FORM_BATTLEFIELD_SCORE, true)
  if 0 <= kill_count and kill_count <= 9 then
    form.lbl_1.Visible = true
    form.lbl_4.Left = form.lbl_1.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[kill_count + 1])
    form.lbl_4.Visible = true
  elseif 10 <= kill_count and kill_count <= 99 then
    form.lbl_1.Visible = true
    form.lbl_3.Left = form.lbl_1.Width
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_count / 10) + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_1.Width + form.lbl_3.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[kill_count % 10 + 1])
    form.lbl_4.Visible = true
  elseif 100 <= kill_count and kill_count <= 999 then
    form.lbl_1.Visible = true
    form.lbl_2.Left = form.lbl_1.Width
    form.lbl_2.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_count / 100) + 1])
    form.lbl_2.Visible = true
    form.lbl_3.Left = form.lbl_1.Width + form.lbl_2.Width
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_count % 100 / 10) + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_1.Width + form.lbl_2.Width + form.lbl_3.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[kill_count % 10 + 1])
    form.lbl_4.Visible = true
  end
end
function RefreshProgressBar(arg1, arg2, arg3, arg4, arg5, ...)
  local form = nx_null()
  local jq_max = nx_number(arg1)
  if jq_max < 0 then
    form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, false)
  else
    form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, true)
  end
  if not nx_is_valid(form) then
    return 0
  end
  if jq_max < 0 then
    form.jianqi_show = false
    close_form(form)
    return 0
  end
  form.jianqi_show = true
  nx_execute("util_gui", "util_show_form", FORM_BATTLEFIELD_SCORE, true)
  form.pbar_1.Visible = nx_number(arg2) > 0
  form.pbar_2.Visible = nx_number(arg3) > 0
  if form.pbar_2.Visible then
    form.pbar_1.Top = 30
    form.ani_1.Top = -19
  else
    form.pbar_1.Top = 50
    form.ani_1.Top = 1
  end
  local is_add_red = nx_int(arg2) > nx_int(form.pbar_1.Value)
  local is_add_blue = nx_int(arg3) > nx_int(form.pbar_2.Value)
  form.pbar_1.Maximum = nx_int(arg1)
  form.pbar_1.Value = nx_int(arg2)
  if nx_number(arg4) == 1 then
    form.ani_1.Visible = true
    form.ani_1.PlayMode = 2
    form.ani_1:Play()
  elseif is_add_red then
    create_jianqi_change_effect(form, 1)
  end
  form.pbar_2.Maximum = nx_int(arg1)
  form.pbar_2.Value = nx_int(arg3)
  if nx_number(arg5) == 1 then
    form.ani_2.Visible = true
    form.ani_2.PlayMode = 2
    form.ani_2:Play()
  elseif is_add_blue then
    create_jianqi_change_effect(form, 2)
  end
end
function RefreshKillCountDiff(arg1, arg2, ...)
  local form = nx_null()
  local kill_count_white = nx_number(arg1)
  local kill_count_black = nx_number(arg2)
  if kill_count_white < 0 and kill_count_black < 0 then
    form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, false)
  else
    form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, true)
  end
  if not nx_is_valid(form) then
    return 0
  end
  if kill_count_white < 0 and kill_count_black < 0 then
    form.countdiff_show = false
    close_form(form)
    return 0
  end
  form.countdiff_show = true
  nx_execute("util_gui", "util_show_form", FORM_BATTLEFIELD_SCORE, true)
  form.lbl_kill_diff_1.Visible = true
  form.lbl_kill_diff_2.Visible = false
  form.lbl_kill_diff_3.Visible = false
  form.lbl_kill_diff_4.Visible = false
  form.lbl_kill_diff_5.Visible = false
  local cur_left = form.lbl_kill_diff_1.Left + form.lbl_kill_diff_1.Width
  local count_diff = math.abs(kill_count_white - kill_count_black)
  local char_1 = nx_number(nx_int(count_diff % 10))
  local char_2 = nx_number(nx_int(count_diff % 100 / 10))
  local char_3 = nx_number(nx_int(count_diff / 100))
  local side = get_player_side()
  if 0 < table.getn(arg) then
    side = nx_number(arg[1])
  end
  if kill_count_white > kill_count_black then
    form.lbl_kill_diff_2.Visible = true
    form.lbl_kill_diff_2.Left = cur_left
    cur_left = cur_left + form.lbl_kill_diff_2.Width
    if nx_number(side) == 1 then
      form.lbl_kill_diff_2.BackImage = SIGN_IMAGE[1]
    else
      form.lbl_kill_diff_2.BackImage = SIGN_IMAGE[2]
    end
  elseif kill_count_white < kill_count_black then
    form.lbl_kill_diff_2.Visible = true
    if nx_number(side) == 1 then
      form.lbl_kill_diff_2.BackImage = SIGN_IMAGE[2]
    else
      form.lbl_kill_diff_2.BackImage = SIGN_IMAGE[1]
    end
    form.lbl_kill_diff_2.Left = cur_left
    cur_left = cur_left + form.lbl_kill_diff_2.Width
  end
  if 0 < char_3 then
    form.lbl_kill_diff_3.Visible = true
    form.lbl_kill_diff_3.BackImage = SHUZITUPIAN[char_3 + 1]
    form.lbl_kill_diff_3.Left = cur_left
    cur_left = cur_left + form.lbl_kill_diff_3.Width
  end
  if 0 < char_2 then
    form.lbl_kill_diff_4.Visible = true
    form.lbl_kill_diff_4.BackImage = SHUZITUPIAN[char_2 + 1]
    form.lbl_kill_diff_4.Left = cur_left
    cur_left = cur_left + form.lbl_kill_diff_4.Width
  end
  form.lbl_kill_diff_5.Visible = true
  form.lbl_kill_diff_5.BackImage = SHUZITUPIAN[char_1 + 1]
  form.lbl_kill_diff_5.Left = cur_left
  cur_left = cur_left + form.lbl_kill_diff_5.Width
end
function get_player_side()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local arena_side = 1
  if not nx_is_valid(client_player) then
    return arena_side
  end
  if client_player:FindProp("ArenaSide") then
    arena_side = client_player:QueryProp("ArenaSide")
  end
  return arena_side
end
function create_jianqi_change_effect(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local pbar = form.pbar_1
  local color = "255,24,145,63"
  if index == 2 then
    pbar = form.pbar_2
    color = "255,167,31,49"
  end
  local ani_path_pos_list = {}
  ani_path_pos_list[1] = {left = 0, top = 0}
  ani_path_pos_list[1].left = pbar.AbsLeft
  ani_path_pos_list[1].top = pbar.AbsTop + pbar.Height / 2
  ani_path_pos_list[3] = {left = 0, top = 0}
  ani_path_pos_list[3].left = pbar.AbsLeft + pbar.Width * pbar.Value / pbar.Maximum
  ani_path_pos_list[3].top = pbar.AbsTop + pbar.Height / 2
  ani_path_pos_list[2] = {left = 0, top = 0}
  ani_path_pos_list[2].left = math.random(math.min(ani_path_pos_list[1].left, ani_path_pos_list[3].left), math.max(ani_path_pos_list[1].left, ani_path_pos_list[3].left))
  ani_path_pos_list[2].top = math.random(math.min(ani_path_pos_list[1].top, ani_path_pos_list[3].top), math.max(ani_path_pos_list[1].top, ani_path_pos_list[3].top))
  local ani_path = gui:Create("AnimationPath")
  form:Add(ani_path)
  ani_path.AnimationImage = "gui\\animations\\path_effect\\star.dds"
  ani_path.SmoothPath = true
  ani_path.Loop = false
  ani_path.ClosePath = false
  ani_path.Color = color
  ani_path.CreateMinInterval = 5
  ani_path.CreateMaxInterval = 10
  ani_path.RotateSpeed = 2
  ani_path.BeginAlpha = 1
  ani_path.AlphaChangeSpeed = 1
  ani_path.BeginScale = 0.17
  ani_path.ScaleSpeed = 0
  ani_path.MaxTime = 1000
  ani_path.MaxWave = 0.05
  ani_path:ClearPathPoints()
  for i = 1, table.getn(ani_path_pos_list) do
    local ani_path_pos = ani_path_pos_list[i]
    ani_path:AddPathPoint(ani_path_pos.left, ani_path_pos.top)
  end
  ani_path:AddPathPointFinish()
  nx_bind_script(ani_path, nx_current())
  nx_callback(ani_path, "on_animation_end", "on_ani_path_end")
  ani_path:Play()
  return ani_path
end
function on_ani_path_end(self)
  local gui = nx_value("gui")
  if not nx_is_valid(self) then
    return 0
  end
  self.Visible = false
  gui:Delete(self)
end
function DisplayBtn(...)
  local form = nx_null()
  local display_state = nx_number(arg[1])
  if display_state == 0 then
    form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, false)
  elseif display_state == 1 then
    form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, true)
  end
  if not nx_is_valid(form) then
    return 0
  end
  if display_state == 0 then
    form.help_show = false
    close_form(form)
    return 0
  end
  form.help_show = true
  nx_execute("util_gui", "util_show_form", FORM_BATTLEFIELD_SCORE, true)
  if display_state == 1 then
    form.btn_request_help.Enabled = true
    form.btn_request_help.Visible = true
  end
end
function on_btn_request_help_click(btn)
  btn.Enabled = false
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_fight", "request_help")
end
function balance_war_open_score_form(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, true)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("util_gui", "util_show_form", FORM_BATTLEFIELD_SCORE, true)
  local win_score = nx_number(arg[1])
  refresh_balance_war_win_score(form, win_score)
  local kill_score = nx_number(arg[2])
  refresh_balance_war_kill_score(form, kill_score)
end
function hide_win()
  local form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_SCORE, true)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_kill_diff_1.Visible = false
  form.lbl_kill_diff_2.Visible = false
  form.lbl_kill_diff_3.Visible = false
  form.lbl_kill_diff_4.Visible = false
  form.lbl_kill_diff_5.Visible = false
  local top = form.lbl_kill_diff_1.Top
  form.lbl_1.Top = top
  form.lbl_2.Top = top
  form.lbl_3.Top = top
  form.lbl_4.Top = top
end
function refresh_balance_war_win_score(form, win_score)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_kill_diff_1.Visible = true
  form.lbl_kill_diff_1.HintText = nx_widestr("")
  form.lbl_kill_diff_3.BackImage = nx_widestr("")
  form.lbl_kill_diff_4.BackImage = nx_widestr("")
  form.lbl_kill_diff_5.BackImage = nx_widestr("")
  local cur_left = form.lbl_kill_diff_1.Left + form.lbl_kill_diff_1.Width
  if nx_int(win_score) < nx_int(0) then
    form.lbl_kill_diff_2.Visible = true
    form.lbl_kill_diff_2.BackImage = SIGN_IMAGE[2]
    win_score = math.abs(win_score)
    form.lbl_kill_diff_2.Left = cur_left
  elseif nx_int(win_score) > nx_int(0) then
    form.lbl_kill_diff_2.Visible = true
    form.lbl_kill_diff_2.BackImage = SIGN_IMAGE[1]
    form.lbl_kill_diff_2.Left = cur_left
  elseif nx_int(win_score) == nx_int(0) then
    form.lbl_kill_diff_5.Visible = true
    form.lbl_kill_diff_5.BackImage = SHUZITUPIAN[1]
    form.lbl_kill_diff_5.Left = cur_left
    return
  end
  if nx_int(win_score) >= nx_int(0) and nx_int(win_score) <= nx_int(9) then
    form.lbl_kill_diff_5.Left = form.lbl_kill_diff_2.Left + form.lbl_kill_diff_2.Width
    form.lbl_kill_diff_5.BackImage = nx_string(SHUZITUPIAN[nx_int(win_score) + 1])
    form.lbl_kill_diff_5.Visible = true
  elseif nx_int(win_score) >= nx_int(10) and nx_int(win_score) <= nx_int(99) then
    form.lbl_kill_diff_5.Left = form.lbl_kill_diff_2.Left + form.lbl_kill_diff_2.Width
    form.lbl_kill_diff_5.BackImage = nx_string(SHUZITUPIAN[nx_int(win_score / 10) + 1])
    form.lbl_kill_diff_5.Visible = true
    form.lbl_kill_diff_4.Left = form.lbl_kill_diff_5.Left + form.lbl_kill_diff_5.Width
    form.lbl_kill_diff_4.BackImage = nx_string(SHUZITUPIAN[nx_int(win_score % 10) + 1])
    form.lbl_kill_diff_4.Visible = true
  elseif nx_int(win_score) >= nx_int(100) and nx_int(win_score) <= nx_int(999) then
    form.lbl_kill_diff_5.Left = form.lbl_kill_diff_2.Left + form.lbl_kill_diff_2.Width
    form.lbl_kill_diff_5.BackImage = nx_string(SHUZITUPIAN[nx_int(win_score / 100) + 1])
    form.lbl_kill_diff_5.Visible = true
    form.lbl_kill_diff_4.Left = form.lbl_kill_diff_5.Left + form.lbl_kill_diff_5.Width
    form.lbl_kill_diff_4.BackImage = nx_string(SHUZITUPIAN[nx_int(win_score % 100 / 10) + 1])
    form.lbl_kill_diff_4.Visible = true
    form.lbl_kill_diff_3.Left = form.lbl_kill_diff_4.Left + form.lbl_kill_diff_4.Width
    form.lbl_kill_diff_3.BackImage = nx_string(SHUZITUPIAN[nx_int(win_score % 10) + 1])
    form.lbl_kill_diff_3.Visible = true
  end
end
function refresh_balance_war_kill_score(form, kill_score)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(kill_score) < nx_int(0) then
    return
  end
  form.lbl_2.BackImage = nx_widestr("")
  form.lbl_3.BackImage = nx_widestr("")
  form.lbl_4.BackImage = nx_widestr("")
  if nx_int(kill_score) >= nx_int(0) and nx_int(kill_score) <= nx_int(9) then
    form.lbl_1.Visible = true
    form.lbl_4.Left = form.lbl_1.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_score) + 1])
    form.lbl_4.Visible = true
  elseif nx_int(kill_score) >= nx_int(10) and nx_int(kill_score) <= nx_int(99) then
    form.lbl_1.Visible = true
    form.lbl_3.Left = form.lbl_1.Width
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_score / 10) + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_1.Width + form.lbl_3.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_score % 10) + 1])
    form.lbl_4.Visible = true
  elseif nx_int(kill_score) >= nx_int(100) and nx_int(kill_score) <= nx_int(999) then
    form.lbl_1.Visible = true
    form.lbl_2.Left = form.lbl_1.Width
    form.lbl_2.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_score / 100) + 1])
    form.lbl_2.Visible = true
    form.lbl_3.Left = form.lbl_1.Width + form.lbl_2.Width
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_score % 100 / 10) + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_1.Width + form.lbl_2.Width + form.lbl_3.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_score % 10) + 1])
    form.lbl_4.Visible = true
  end
end
function balance_war_close_form()
  local form = nx_value(FORM_BATTLEFIELD_SCORE)
  if nx_is_valid(form) then
    form:Close()
  end
end
