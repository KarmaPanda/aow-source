require("util_functions")
require("util_gui")
FORM_PATH = "form_stage_main\\form_match\\form_revenge_all_end"
SUB_FORM_PATH = "form_stage_main\\form_match\\form_revenge_sub_end"
MRBC_Step_Win = 14
MRBC_Step_WinCon = 15
MRBC_Step_Lost = 17
local score_icon = {
  [0] = "gui\\special\\tianti\\end\\0.png",
  [1] = "gui\\special\\tianti\\end\\1.png",
  [2] = "gui\\special\\tianti\\end\\2.png"
}
local level_icon = {
  [1] = "gui\\language\\ChineseS\\tianti\\icon_room_1.png",
  [2] = "gui\\language\\ChineseS\\tianti\\icon_room_2.png",
  [3] = "gui\\language\\ChineseS\\tianti\\icon_room_3.png",
  [4] = "gui\\language\\ChineseS\\tianti\\icon_room_4.png",
  [5] = "gui\\language\\ChineseS\\tianti\\icon_room_5.png",
  [6] = "gui\\language\\ChineseS\\tianti\\icon_room_6.png"
}
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local sub_form = nx_value(SUB_FORM_PATH)
  if nx_is_valid(sub_form) then
    sub_form.Left = 150
    sub_form.Top = (gui.Height - form.Height) / 2
    form.Left = gui.Width / 2 + 100
    form.Top = (gui.Height - form.Height) / 2
  else
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function open_form(...)
  local win_name = nx_widestr(arg[1])
  local win_school = nx_string(arg[2])
  local win_guild = nx_widestr(arg[3])
  local win_score = nx_number(arg[4])
  if 2 < win_score then
    win_score = 2
  end
  local lost_name = nx_widestr(arg[5])
  local lost_school = nx_string(arg[6])
  local lost_guild = nx_widestr(arg[7])
  local lost_score = nx_number(arg[8])
  if 2 < lost_score then
    lost_score = 2
  end
  local win_point = nx_string(arg[9])
  local add_point = 0
  if nx_int(win_point) > nx_int(0) then
    add_point = nx_string(arg[10])
  end
  util_show_form(FORM_PATH, true)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not player:FindProp("RevengeIntegral") or not player:FindRecord("MatchRankBase") then
    return
  end
  form.lbl_win_name.Text = nx_widestr(win_name)
  form.lbl_win_guild.Text = nx_widestr(win_guild)
  form.lbl_win_score.BackImage = score_icon[win_score]
  if nx_string(win_school) == "" then
    form.lbl_win_school.Text = nx_widestr(util_text("ui_Match_end_wmp"))
  else
    form.lbl_win_school.Text = nx_widestr(util_text(win_school))
  end
  form.lbl_lost_name.Text = nx_widestr(lost_name)
  form.lbl_lost_guild.Text = nx_widestr(lost_guild)
  form.lbl_lost_score.BackImage = score_icon[lost_score]
  if nx_string(lost_school) == "" then
    form.lbl_lost_school.Text = nx_widestr(util_text("ui_Match_end_wmp"))
  else
    form.lbl_lost_school.Text = nx_widestr(util_text(lost_school))
  end
  if nx_int(add_point) > nx_int(0) then
    form.lbl_add_point.Visible = true
    form.lbl_add_point.Text = nx_widestr(add_point)
    form.lbl_add_text.Visible = true
  else
    form.lbl_add_point.Visible = false
    form.lbl_add_point.Text = nx_widestr(add_point)
    form.lbl_add_text.Visible = false
  end
  local win_times = player:QueryRecord("MatchRankBase", nx_number(MRBC_Step_Win), 0)
  local lost_times = player:QueryRecord("MatchRankBase", nx_number(MRBC_Step_Lost), 0)
  local keep_win = player:QueryRecord("MatchRankBase", nx_number(MRBC_Step_WinCon), 0)
  if nx_widestr(win_name) == nx_widestr(player:QueryProp("Name")) then
    win_times = win_times + 1
    keep_win = keep_win + 1
  else
    lost_times = lost_times + 1
    keep_win = 0
  end
  local tianti_score = nx_number(player:QueryProp("RevengeIntegral")) + nx_number(player:QueryProp("DecBeforePoint")) + nx_number(win_point) + add_point
  form.lbl_tianti_score.Text = nx_widestr(nx_int(tianti_score))
  if nx_int(win_point) > nx_int(0) then
    form.lbl_win_point.ForeColor = "255,246,56,0"
    form.lbl_win_point.Text = nx_widestr("+") .. nx_widestr(math.abs(win_point))
  else
    form.lbl_win_point.ForeColor = "255,0,232,0"
    form.lbl_win_point.Text = nx_widestr("-") .. nx_widestr(math.abs(win_point))
  end
  form.lbl_win_times.Text = nx_widestr(win_times)
  form.lbl_win_rate.Text = nx_widestr(nx_int(win_times / (win_times + lost_times) * 100)) .. nx_widestr("%")
  form.lbl_keep_win.Text = nx_widestr(keep_win)
  local percent, level, level_max = GetScorePercent(keep_win)
  form.lbl_score_percent.Text = nx_widestr(percent) .. nx_widestr("%")
  for i = 1, level_max do
    local star = form.grp_star:Find("lbl_star_" .. nx_string(i))
    if not nx_is_valid(star) then
      return
    end
    if level >= i then
      star.Visible = true
    else
      star.Visible = false
    end
  end
  local score_level = GetScoreLevel(tianti_score)
  form.lbl_score_level.BackImage = level_icon[nx_number(score_level)]
end
function GetScorePercent(keep_win)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_Revenge.ini")
  if not nx_is_valid(ini) then
    return 0, 0, 0
  end
  local index = ini:FindSectionIndex("Rule")
  if index < 0 then
    return 0, 0, 0
  end
  local win_count = ini:ReadString(index, "wincount", "")
  local list = util_split_string(win_count, ";")
  for i = table.getn(list), 1, -1 do
    local sub_list = util_split_string(list[i], ",")
    if table.getn(sub_list) ~= 2 then
      return 0, 0, 0
    end
    if nx_int(keep_win) >= nx_int(sub_list[1]) then
      return nx_int(sub_list[2] * 100), i, table.getn(list)
    end
  end
  return 0, 0, table.getn(list)
end
function GetScoreLevel(score)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_Revenge.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex("Rule")
  if index < 0 then
    return 0
  end
  local score_level = ini:ReadString(index, "score_level", "")
  local list = util_split_string(score_level, ";")
  for i = table.getn(list), 1, -1 do
    local sub_list = util_split_string(list[i], ",")
    if table.getn(sub_list) ~= 2 then
      return 0
    end
    if nx_int(score) >= nx_int(sub_list[2]) then
      return nx_int(sub_list[1])
    end
  end
  return 0
end
