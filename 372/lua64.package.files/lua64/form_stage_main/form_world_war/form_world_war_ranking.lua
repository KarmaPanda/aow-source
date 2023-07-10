require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
local school_image = {
  school_shaolin = "gui\\special\\school_head\\sl.png",
  school_wudang = "gui\\special\\school_head\\wd.png",
  school_gaibang = "gui\\special\\school_head\\gb.png",
  school_tangmen = "gui\\special\\school_head\\tm.png",
  school_emei = "gui\\special\\school_head\\em.png",
  school_jinyiwei = "gui\\special\\school_head\\jy.png",
  school_jilegu = "gui\\special\\school_head\\jl.png",
  school_junzitang = "gui\\special\\school_head\\jz.png",
  ui_None = "gui\\special\\school_head\\wmp.png",
  force_jinzhen = "gui\\special\\HW_force_head\\shililogo\\jinzhen02.png",
  force_taohua = "gui\\special\\HW_force_head\\shililogo\\taohua02.png",
  force_wanshou = "gui\\special\\HW_force_head\\shililogo\\wanshou02.png",
  force_wugen = "gui\\special\\HW_force_head\\shililogo\\wugen02.png",
  force_xujia = "gui\\special\\HW_force_head\\shililogo\\xujia02.png",
  force_yihua = "gui\\special\\HW_force_head\\shililogo\\yihua02.png"
}
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
  local rbtn_name = "rbtn_side_" .. nx_string(side)
  local rbtn = form.groupbox_choose_side:Find(rbtn_name)
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
    on_rbtn_side_checked_changed(rbtn)
  end
  form.textgrid_player_rank.ColCount = 12
  form.textgrid_self_rank.ColCount = 12
  form.textgrid_player_rank.ColWidths = "30,108,60,60,60,60,62,62,62,60,60,60"
  form.textgrid_self_rank.ColWidths = "30,108,60,60,60,60,62,62,62,60,60,60"
  form.textgrid_player_rank:SetColTitle(0, nx_widestr(util_text("ui_worldwar_rank_0")))
  form.textgrid_player_rank:SetColTitle(1, nx_widestr(util_text("ui_worldwar_rank_1")))
  form.textgrid_player_rank:SetColTitle(2, nx_widestr(util_text("ui_worldwar_rank_2")))
  form.textgrid_player_rank:SetColTitle(3, nx_widestr(util_text("ui_worldwar_rank_3")))
  form.textgrid_player_rank:SetColTitle(4, nx_widestr(util_text("ui_worldwar_rank_4")))
  form.textgrid_player_rank:SetColTitle(5, nx_widestr(util_text("ui_worldwar_rank_5")))
  form.textgrid_player_rank:SetColTitle(6, nx_widestr(util_text("ui_worldwar_rank_6")))
  form.textgrid_player_rank:SetColTitle(7, nx_widestr(util_text("ui_worldwar_rank_7")))
  form.textgrid_player_rank:SetColTitle(8, nx_widestr(util_text("ui_worldwar_rank_8")))
  form.textgrid_player_rank:SetColTitle(9, nx_widestr(util_text("ui_worldwar_rank_9")))
  form.textgrid_player_rank:SetColTitle(10, nx_widestr(util_text("ui_worldwar_rank_10")))
  form.textgrid_player_rank:SetColTitle(11, nx_widestr(util_text("ui_worldwar_rank_11")))
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_rbtn_side_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.selected_side = rbtn.DataSource
  form.page_index = 1
  form.btn_next.Enabled = true
  send_world_war_custom_msg(CLIENT_WORLDWAR_STAT_INFO, nx_int(form.selected_side), nx_int(1), nx_int(PAGE_COUNT))
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
  send_world_war_custom_msg(CLIENT_WORLDWAR_STAT_INFO, nx_int(form.selected_side), nx_int(from), nx_int(from + PAGE_COUNT - 1))
end
function update_ranking_info(rows, ...)
  local count = #arg
  local playerInfoSize = 22
  if count < playerInfoSize or math.mod(count, playerInfoSize) ~= 0 then
    return
  end
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_ranking")
  local form_world_war_result_tips = nx_value("form_stage_main\\form_world_war\\form_world_war_result_tips")
  if nx_is_valid(form_world_war_result_tips) then
    form_world_war_result_tips:Close()
  end
  if not nx_is_valid(form) then
    local form_world_war_stat = util_show_form("form_stage_main\\form_world_war\\form_world_war_stat", true)
    form = nx_value("form_stage_main\\form_world_war\\form_world_war_ranking")
    if not nx_is_valid(form_world_war_stat) or not nx_is_valid(form) then
      return
    end
    nx_execute("form_stage_main\\form_world_war\\form_world_war_stat", "hide_all_sub_form", form_world_war_stat)
    if nx_find_custom(form_world_war_stat, "form_ranking") and nx_is_valid(form_world_war_stat.form_ranking) then
      form_world_war_stat.form_ranking.Visible = true
    end
  end
  form.max_index = math.ceil(rows / PAGE_COUNT)
  if 0 >= form.max_index then
    form.max_index = 1
  end
  form.lbl_page.Text = nx_widestr(form.page_index) .. nx_widestr("/") .. nx_widestr(form.max_index)
  form.textgrid_player_rank:ClearRow()
  form.textgrid_self_rank:ClearRow()
  local row = form.textgrid_self_rank:InsertRow(-1)
  form.textgrid_self_rank:SetGridText(row, 0, nx_widestr(arg[1]))
  form.textgrid_self_rank:SetGridText(row, 1, nx_widestr(arg[2]))
  local school = util_text(nx_string(arg[3]))
  if arg[3] == "" then
    school = util_text("ui_task_school_null")
  end
  local label = create_school_image_control(arg[3])
  if label ~= nil then
    form.textgrid_self_rank:SetGridControl(row, 2, label)
  end
  form.textgrid_self_rank:SetGridText(row, 3, nx_widestr(arg[4]))
  form.textgrid_self_rank:SetGridText(row, 4, nx_widestr(arg[5]))
  form.textgrid_self_rank:SetGridText(row, 5, nx_widestr(arg[6]))
  form.textgrid_self_rank:SetGridText(row, 6, nx_widestr(arg[7]))
  form.textgrid_self_rank:SetGridText(row, 7, nx_widestr(arg[8]))
  form.textgrid_self_rank:SetGridText(row, 8, nx_widestr(arg[9]))
  form.textgrid_self_rank:SetGridText(row, 9, nx_widestr(arg[12] + arg[13] + arg[14] + arg[15] + arg[16]))
  form.textgrid_self_rank:SetGridText(row, 10, nx_widestr(arg[11]))
  if 5 >= nx_number(arg[1]) and 1 <= nx_number(arg[1]) then
    form.textgrid_self_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[1])))
  end
  if 10 >= nx_number(arg[1]) and 6 <= nx_number(arg[1]) then
    form.textgrid_self_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[2])))
  end
  if nx_number(arg[1]) <= 20 and 11 <= nx_number(arg[1]) then
    form.textgrid_self_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[3])))
  end
  if nx_number(arg[1]) <= 30 and nx_number(arg[1]) >= 21 then
    form.textgrid_self_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[4])))
  end
  if nx_number(arg[1]) <= 40 and nx_number(arg[1]) >= 31 then
    form.textgrid_self_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[5])))
  end
  if nx_number(arg[1]) <= 48 and nx_number(arg[1]) >= 41 then
    form.textgrid_self_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[6])))
  end
  for i = 1, count / playerInfoSize - 1 do
    row = form.textgrid_player_rank:InsertRow(-1)
    form.textgrid_player_rank:SetGridText(row, 0, nx_widestr(arg[i * playerInfoSize + 1]))
    form.textgrid_player_rank:SetGridText(row, 1, nx_widestr(arg[i * playerInfoSize + 2]))
    school = util_text(nx_string(arg[i * playerInfoSize + 3]))
    if arg[i * playerInfoSize + 3] == "" then
      school = util_text("ui_task_school_null")
    end
    local label = create_school_image_control(arg[i * playerInfoSize + 3])
    if label ~= nil then
      form.textgrid_player_rank:SetGridControl(row, 2, label)
    end
    form.textgrid_player_rank:SetGridText(row, 3, nx_widestr(arg[i * playerInfoSize + 4]))
    form.textgrid_player_rank:SetGridText(row, 4, nx_widestr(arg[i * playerInfoSize + 5]))
    form.textgrid_player_rank:SetGridText(row, 5, nx_widestr(arg[i * playerInfoSize + 6]))
    form.textgrid_player_rank:SetGridText(row, 6, nx_widestr(arg[i * playerInfoSize + 7]))
    form.textgrid_player_rank:SetGridText(row, 7, nx_widestr(arg[i * playerInfoSize + 8]))
    form.textgrid_player_rank:SetGridText(row, 8, nx_widestr(arg[i * playerInfoSize + 9]))
    form.textgrid_player_rank:SetGridText(row, 9, nx_widestr(arg[i * playerInfoSize + 12] + arg[i * playerInfoSize + 13] + arg[i * playerInfoSize + 14] + arg[i * playerInfoSize + 15] + arg[i * playerInfoSize + 16]))
    form.textgrid_player_rank:SetGridText(row, 10, nx_widestr(arg[i * playerInfoSize + 11]))
    if 5 >= nx_number(arg[i * playerInfoSize + 1]) and 1 <= nx_number(arg[i * playerInfoSize + 1]) then
      form.textgrid_player_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[1])))
    end
    if 10 >= nx_number(arg[i * playerInfoSize + 1]) and 6 <= nx_number(arg[i * playerInfoSize + 1]) then
      form.textgrid_player_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[2])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 20 and 11 <= nx_number(arg[i * playerInfoSize + 1]) then
      form.textgrid_player_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[3])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 30 and nx_number(arg[i * playerInfoSize + 1]) >= 21 then
      form.textgrid_player_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[4])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 40 and nx_number(arg[i * playerInfoSize + 1]) >= 31 then
      form.textgrid_player_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[5])))
    end
    if nx_number(arg[i * playerInfoSize + 1]) <= 48 and nx_number(arg[i * playerInfoSize + 1]) >= 41 then
      form.textgrid_player_rank:SetGridText(row, 11, nx_widestr(util_text(deed_table[6])))
    end
  end
end
function create_school_image_control(school_name)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local label = gui:Create("Label")
    label.AutoSize = true
    label.DrawMode = "Center"
    label.BackImage = school_image[school_name]
    return label
  end
  return nil
end
