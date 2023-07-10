require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
local PAGE_COUNT = 12
local deed_table = {
  "ui_worldwar_deed_one",
  "ui_worldwar_deed_two",
  "ui_worldwar_deed_three",
  "ui_worldwar_deed_four",
  "ui_worldwar_deed_five",
  "ui_worldwar_deed_six"
}
function main_form_init(form)
  form.Fixed = true
  form.page_index = 1
  form.max_index = 1
  form.selected_side = 1
end
function on_main_form_open(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local side = client_player:QueryProp("WorldWarForce")
  form.selected_side = side
  local gui = nx_value("gui")
  if nx_is_valid(gui) == false then
    return
  end
  form.textgrid_player_rank:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_worldwar_rank_0")))
  form.textgrid_player_rank:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_worldwar_rank_1")))
  form.textgrid_player_rank:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_worldwar_rank_3")))
  form.textgrid_player_rank:SetColTitle(4, nx_widestr(gui.TextManager:GetText("ui_worldwar_rank_4")))
  form.textgrid_player_rank:SetColTitle(5, nx_widestr(gui.TextManager:GetText("ui_lxc_duobao")))
  form.textgrid_player_rank:SetColTitle(6, nx_widestr(gui.TextManager:GetText("ui_lxc_zhaomuhero")))
  form.textgrid_player_rank:SetColTitle(7, nx_widestr(gui.TextManager:GetText("ui_lxc_killhero")))
  form.textgrid_player_rank:SetColTitle(8, nx_widestr(gui.TextManager:GetText("ui_lxc_playerjf")))
  form.textgrid_player_rank:SetColTitle(9, nx_widestr(gui.TextManager:GetText("ui_worldwar_rank_11")))
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  if form.page_index <= 1 then
    btn.Enabled = false
    return
  end
  form.btn_next.Enabled = true
  request_page_info(form, form.page_index - 1)
  if form.page_index == 1 then
    btn.Enabled = false
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if form.page_index >= form.max_index then
    btn.Enabled = false
    return
  end
  form.btn_pre.Enabled = true
  request_page_info(form, form.page_index + 1)
  if form.page_index == form.max_index then
    btn.Enabled = false
  end
end
function send_world_war_custom_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(sub_msg), unpack(arg))
end
function request_page_info(form, page_index)
  if page_index <= 0 then
    return
  end
  form.page_index = page_index
  local from = (page_index - 1) * PAGE_COUNT + 1
  send_world_war_custom_msg(CLIENT_WORLDWAR_STAT_INFO2, nx_int(from), nx_int(from + PAGE_COUNT - 1))
end
function update_ranking_info(isTraitor, score1, score2, score3, score4, nums1, nums2, nums3, nums4, rows, ...)
  local count = #arg
  local playerInfoSize = 9
  local gui = nx_value("gui")
  if nx_is_valid(gui) == false then
    return
  end
  if count < playerInfoSize or math.mod(count, playerInfoSize) ~= 0 then
    return
  end
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_lingxiao_ranking")
  local form_world_war_result_tips = nx_value("form_stage_main\\form_world_war\\form_world_war_result_tips")
  if nx_is_valid(form_world_war_result_tips) then
    form_world_war_result_tips:Close()
  end
  local form_world_war_lingxiao_stat = util_show_form("form_stage_main\\form_world_war\\form_world_war_lingxiao_stat", true)
  form = nx_value("form_stage_main\\form_world_war\\form_world_war_lingxiao_ranking")
  if not nx_is_valid(form_world_war_lingxiao_stat) or not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_world_war\\form_world_war_lingxiao_stat", "hide_all_sub_form", form_world_war_lingxiao_stat)
  if nx_find_custom(form_world_war_lingxiao_stat, "form_lingxiao_ranking") and nx_is_valid(form_world_war_lingxiao_stat.form_lingxiao_ranking) then
    if not form_world_war_lingxiao_stat.rbtn_tab_3.Checked then
      form_world_war_lingxiao_stat.rbtn_tab_3.Checked = true
      form_world_war_lingxiao_stat.WorldWarEnd = true
    end
    form_world_war_lingxiao_stat.form_lingxiao_ranking.Visible = true
  end
  nx_execute("form_stage_main\\form_world_war\\form_world_war_lingxiao_stat", "update_force_info", score1, score2, score3, score4, nums1, nums2, nums3, nums4)
  nx_execute("form_stage_main\\form_world_war\\form_world_war_lingxiao_stat", "hide_traitor", isTraitor)
  form.max_index = math.ceil(rows / PAGE_COUNT)
  if 0 >= form.max_index then
    form.max_index = 1
  end
  form.ipt_1.Text = nx_widestr(form.page_index)
  form.textgrid_player_rank:ClearRow()
  form.textgrid_self_rank:ClearRow()
  local row = form.textgrid_self_rank:InsertRow(-1)
  form.textgrid_self_rank:SetGridText(row, 0, nx_widestr(arg[1]))
  form.textgrid_self_rank:SetGridText(row, 1, nx_widestr(arg[2]))
  local school = gui.TextManager:GetText(nx_string(arg[3]))
  if arg[3] == "" and arg[1] ~= "" then
    school = gui.TextManager:GetText("ui_task_school_null")
  end
  form.textgrid_self_rank:SetGridText(row, 3, nx_widestr(arg[4]))
  form.textgrid_self_rank:SetGridText(row, 4, nx_widestr(arg[5]))
  form.textgrid_self_rank:SetGridText(row, 5, nx_widestr(arg[6]))
  form.textgrid_self_rank:SetGridText(row, 6, nx_widestr(arg[7]))
  form.textgrid_self_rank:SetGridText(row, 7, nx_widestr(arg[8]))
  form.textgrid_self_rank:SetGridText(row, 8, nx_widestr(arg[9]))
  if 5 >= nx_number(arg[1]) and 1 <= nx_number(arg[1]) then
    form.textgrid_self_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[1])))
  end
  if nx_number(arg[1]) <= 10 and 6 <= nx_number(arg[1]) then
    form.textgrid_self_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[2])))
  end
  if nx_number(arg[1]) <= 20 and nx_number(arg[1]) >= 11 then
    form.textgrid_self_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[3])))
  end
  if nx_number(arg[1]) <= 30 and nx_number(arg[1]) >= 21 then
    form.textgrid_self_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[4])))
  end
  if nx_number(arg[1]) <= 40 and nx_number(arg[1]) >= 31 then
    form.textgrid_self_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[5])))
  end
  if nx_number(arg[1]) <= 48 and nx_number(arg[1]) >= 41 then
    form.textgrid_self_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[6])))
  end
  for i = 1, count / playerInfoSize - 1 do
    row = form.textgrid_player_rank:InsertRow(-1)
    form.textgrid_player_rank:SetGridText(row, 0, nx_widestr(arg[i * playerInfoSize + 1]))
    form.textgrid_player_rank:SetGridText(row, 1, nx_widestr(arg[i * playerInfoSize + 2]))
    school = gui.TextManager:GetText(nx_string(arg[i * playerInfoSize + 3]))
    if arg[i * playerInfoSize + 3] == "" then
      school = gui.TextManager:GetText("ui_task_school_null")
    end
    form.textgrid_player_rank:SetGridText(row, 3, nx_widestr(arg[i * playerInfoSize + 4]))
    form.textgrid_player_rank:SetGridText(row, 4, nx_widestr(arg[i * playerInfoSize + 5]))
    form.textgrid_player_rank:SetGridText(row, 5, nx_widestr(arg[i * playerInfoSize + 6]))
    form.textgrid_player_rank:SetGridText(row, 6, nx_widestr(arg[i * playerInfoSize + 7]))
    form.textgrid_player_rank:SetGridText(row, 7, nx_widestr(arg[i * playerInfoSize + 8]))
    form.textgrid_player_rank:SetGridText(row, 8, nx_widestr(arg[i * playerInfoSize + 9]))
    if 5 >= nx_number(arg[i * playerInfoSize + 1]) and 1 <= nx_number(arg[i * playerInfoSize + 1]) then
      form.textgrid_player_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[1])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 10 and 6 <= nx_number(arg[i * playerInfoSize + 1]) then
      form.textgrid_player_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[2])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 20 and nx_number(arg[i * playerInfoSize + 1]) >= 11 then
      form.textgrid_player_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[3])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 30 and nx_number(arg[i * playerInfoSize + 1]) >= 21 then
      form.textgrid_player_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[4])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 40 and nx_number(arg[i * playerInfoSize + 1]) >= 31 then
      form.textgrid_player_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[5])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 48 and nx_number(arg[i * playerInfoSize + 1]) >= 41 then
      form.textgrid_player_rank:SetGridText(row, 9, nx_widestr(gui.TextManager:GetText(deed_table[6])))
    end
  end
end
