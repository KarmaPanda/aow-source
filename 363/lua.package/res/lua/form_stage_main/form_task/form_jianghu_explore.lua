require("util_gui")
require("custom_sender")
require("util_functions")
require("menu_game")
require("define\\object_type_define")
require("share\\view_define")
require("form_stage_main\\form_task\\task_define")
require("share\\npc_type_define")
require("form_stage_main\\switch\\switch_define")
require("tips_data")
require("util_static_data")
local youli_page_num = 3
local juqing_page_num = 3
local table_prize_btn = {}
local jh_client_explore_msg_get_prize = 1
function main_form_init(self)
  self.Fixed = false
  self.yl_max_page = 1
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return 1
  end
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.groupbox_youli.Visible = true
  form.groupbox_daoju.Visible = false
  form.groupbox_juqing.Visible = false
  form.groupbox_prize.Visible = false
  local cur_scene_id = get_scene_id()
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local table_haogan = jhmgr:GetJhHaoganduInfo(cur_scene_id)
  local table_count = table.getn(table_haogan)
  form.cur_yl_page = 1
  form.cur_jq_page = 1
  form.yl_max_page = get_max_page(table_count / 5, youli_page_num)
  form.rbtn_youli.Checked = true
  show_youli_left(form)
  show_youli_right(form, form.cur_yl_page, youli_page_num)
  table_prize_btn = {
    form.btn_prize_1,
    form.btn_prize_2,
    form.btn_prize_3,
    form.btn_prize_4,
    form.btn_prize_5,
    form.btn_prize_6,
    form.btn_prize_7,
    form.btn_prize_8,
    form.btn_prize_9,
    form.btn_prize_10,
    form.btn_prize_11,
    form.btn_prize_12,
    form.btn_prize_13,
    form.btn_prize_14,
    form.btn_prize_15
  }
  for i = 1, table.getn(table_prize_btn) do
    table_prize_btn[i].tour_level = 0
    table_prize_btn[i].prize_level = 0
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIANGHU_MEET), nx_int(CUSTOMMSG_JIANGHU_MEET_CAN_GET))
  end
  local tab_scene_name = jhmgr:GetJhSceneName(cur_scene_id)
  form.lbl_jh_scene.Text = util_text("ui_jh_jhts_" .. nx_string(tab_scene_name[1]))
  form.lbl_item_kuang.Visible = false
  bind_record_call_back(form)
  set_item_info(form)
  open_form_by_type(2)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_quit_click(form)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_task\\form_jianghu_explore")
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function show_youli_left(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local cur_scene_id = get_scene_id()
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local table_youli = jhmgr:GetJhYouliInfo(cur_scene_id)
  local youli = table_youli[1]
  local youli_detail = table_youli[2]
  local youlizhi_title = table_youli[3]
  if table.getn(table_youli) > 0 then
    form.lbl_youli.Text = util_text(nx_string(youli))
    form.mltbox_youlidetail.HtmlText = util_text(nx_string(youli_detail))
    form.lbl_youlizhi.Text = util_text(nx_string(youlizhi_title))
  end
  local tab_scene_info = jhmgr:GetTourRenownConfig(cur_scene_id)
  local tour_config = tab_scene_info[1]
  local renown_config = tab_scene_info[2]
  local row = 0
  local tour_point = 0
  local tour_level = 0
  local tour_date = 0
  local tour_date_point = 0
  if client_player:FindRecord("JHTour_Record") then
    row = client_player:FindRecordRow("JHTour_Record", 0, nx_string(tour_config))
    if 0 <= row then
      tour_point = client_player:QueryRecord("JHTour_Record", row, 1)
      tour_level = client_player:QueryRecord("JHTour_Record", row, 2)
      tour_date = client_player:QueryRecord("JHTour_Record", row, 3)
      local now_time = os.time()
      local now_time = os.date("*t", now_time)
      local now_date = now_time.year * 10000 + now_time.month * 100 + now_time.day
      if tour_date == now_date then
        tour_date_point = client_player:QueryRecord("JHTour_Record", row, 4)
      end
    end
  end
  if nx_int(tour_level) == nx_int(0) then
    tour_level = 1
  end
  form.lbl_cur_youlizhi.Text = nx_widestr(nx_int(tour_point))
  form.lbl_tour_stage.Text = util_text("ui_youli_" .. nx_string(nx_int(tour_level)))
  local tab_tour_need_point = jhmgr:GetJhTourMaxPoint(nx_int(tour_level + 1))
  form.pbar_tour_max_point.Maximum = nx_int(tab_tour_need_point[1])
  form.pbar_tour_max_point.Value = nx_int(tour_point)
  local renown_point = 0
  local renown_level = 0
  if client_player:FindRecord("JHRenown_Record") then
    row = client_player:FindRecordRow("JHRenown_Record", 0, nx_string(renown_config))
    if 0 <= row then
      renown_point = client_player:QueryRecord("JHRenown_Record", row, 1)
      renown_level = client_player:QueryRecord("JHRenown_Record", row, 2)
    end
  end
  form.lbl_cur_renown_point.Text = nx_widestr(nx_int(renown_point))
  if nx_int(renown_level) == nx_int(0) then
    renown_level = 1
  end
  form.lbl_fav_stage.Text = util_text("ui_" .. nx_string(renown_config) .. "_" .. nx_string(renown_level))
  form.lbl_today_youli_point.Text = nx_widestr(nx_int(tour_date_point))
  local renown_need_point = jhmgr:GetJhRenownMaxPoint(nx_int(renown_level + 1))
  form.pbar_renown_maxpoint.Maximum = nx_int(renown_need_point[1])
  form.pbar_renown_maxpoint.Value = nx_int(renown_point)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JH_EXPLORE), nx_int(2), tour_config)
end
function show_youli_right(form, cur_page, page_num)
  show_youli_page(form)
  local tab_gropbox_yl = {
    form.groupbox_haogan1,
    form.groupbox_haogan2,
    form.groupbox_haogan3
  }
  for i = 1, table.getn(tab_gropbox_yl) do
    tab_gropbox_yl[i].Visible = false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local cur_scene_id = get_scene_id()
  local table_haogan = jhmgr:GetJhHaoganduInfo(cur_scene_id)
  local table_count = table.getn(table_haogan)
  local tab_yl_right = {
    {
      form.lbl_pai1,
      form.pbar_1,
      form.mltbox_haogan1,
      form.lbl_fav_stage_1,
      form.lbl_fav_pic_1
    },
    {
      form.lbl_pai2,
      form.pbar_2,
      form.mltbox_haogan2,
      form.lbl_fav_stage_2,
      form.lbl_fav_pic_2
    },
    {
      form.lbl_pai3,
      form.pbar_3,
      form.mltbox_haogan3,
      form.lbl_fav_stage_3,
      form.lbl_fav_pic_3
    }
  }
  local start_pos = (cur_page - 1) * page_num + 1
  local end_pos = cur_page * page_num
  local index = 1
  local num = 6
  for i = 1, table_count / num do
    if i >= start_pos and i <= end_pos then
      local fav_config = table_haogan[(i - 1) * num + 1]
      local shili = table_haogan[(i - 1) * num + 2]
      tab_yl_right[index][1].Text = util_text(nx_string(shili))
      tab_yl_right[index][1].ForeColor = nx_string(table_haogan[(i - 1) * num + 6])
      local fav_point = 0
      local fav_level = 1
      tab_yl_right[index][2].Maximum = nx_int(table_haogan[(i - 1) * num + 3])
      if client_player:FindRecord("JHFavorable_Record") then
        local row = client_player:FindRecordRow("JHFavorable_Record", 0, fav_config)
        if 0 <= row then
          fav_point = client_player:QueryRecord("JHFavorable_Record", row, 1)
          fav_level = client_player:QueryRecord("JHFavorable_Record", row, 2)
        end
      end
      tab_yl_right[index][2].Value = nx_int(fav_point)
      tab_yl_right[index][3].HtmlText = util_text(nx_string(table_haogan[(i - 1) * num + 4]))
      local tab_scene_name = jhmgr:GetJhSceneName(cur_scene_id)
      tab_yl_right[index][4].Text = util_text("ui_impression_" .. nx_string(tab_scene_name[1]) .. "_" .. nx_string(fav_level))
      tab_yl_right[index][5].BackImage = nx_string(table_haogan[(i - 1) * num + 5])
      tab_gropbox_yl[index].Visible = true
      index = index + 1
    end
  end
end
function show_juqing_left(form)
  local tab_juqing_left = {
    form.btn_jq_left_1,
    form.btn_jq_left_2,
    form.btn_jq_left_3,
    form.btn_jq_left_4
  }
  for j = 1, table.getn(tab_juqing_left) do
    tab_juqing_left[j].Visible = false
  end
  local cur_scene_id = get_scene_id()
  local tab = get_juqing_info(form, cur_scene_id)
  if table.getn(tab) == 0 then
    form.cur_uid = -1
    form.cur_status = 0
    form.jq_max_page = 1
  end
  local index = 1
  for i = 1, table.getn(tab), 2 do
    local uid = tab[i]
    local status = tab[i + 1]
    if i == 1 then
      form.cur_uid = uid
      form.cur_status = status
    end
    local j = nx_number(nx_int(i / 2 + 1))
    if j > table.getn(tab_juqing_left) then
      return
    end
    tab_juqing_left[j].uid = uid
    tab_juqing_left[j].status = status
    tab_juqing_left[j].Visible = true
    if nx_int(status) == nx_int(0) then
      tab_juqing_left[j].Text = util_text("ui_cur_jhtour_stage")
    else
      tab_juqing_left[j].Text = util_text("ui_jhtour_end_" .. nx_string(index))
      index = index + 1
    end
  end
end
function show_juqing_right(form, cur_page, page_num)
  local status = form.cur_status
  if status == 0 then
    show_juqing_detail(form, cur_page, page_num)
  elseif status == 1 then
    show_juqing_end(form)
  end
end
function show_juqing_detail(form, cur_page, page_num)
  form.groupscrollbox_juqing_right.Visible = true
  form.groupbox_ending.Visible = false
  local tab_juqing_group = {
    form.groupbox_juqing1,
    form.groupbox_juqing2,
    form.groupbox_juqing3
  }
  for i = 1, table.getn(tab_juqing_group) do
    tab_juqing_group[nx_number(nx_int(i))].Visible = false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local juqing_count, table_juqing_index = get_same_juqing_info(form.cur_uid)
  form.jq_max_page = get_max_page(juqing_count, page_num)
  show_juqing_page(form)
  local tab_juqing_right = {
    {
      form.lbl_youli_config1,
      form.lbl_youli_value1,
      form.lbl_fav_config1,
      form.lbl_fav_value1,
      form.lbl_fav_config2,
      form.lbl_fav_value2,
      form.lbl_fav_config3,
      form.lbl_fav_value3,
      form.lbl_scene1,
      form.lbl_npc1,
      form.lbl_dialog1,
      form.lbl_item1,
      form.lbl_date1
    },
    {
      form.lbl_youli_config2,
      form.lbl_youli_value2,
      form.lbl_fav_config4,
      form.lbl_fav_value4,
      form.lbl_fav_config5,
      form.lbl_fav_value5,
      form.lbl_fav_config6,
      form.lbl_fav_value6,
      form.lbl_scene2,
      form.lbl_npc2,
      form.lbl_dialog2,
      form.lbl_item2,
      form.lbl_date2
    },
    {
      form.lbl_youli_config3,
      form.lbl_youli_value3,
      form.lbl_fav_config7,
      form.lbl_fav_value7,
      form.lbl_fav_config8,
      form.lbl_fav_value8,
      form.lbl_fav_config9,
      form.lbl_fav_value9,
      form.lbl_scene3,
      form.lbl_npc3,
      form.lbl_dialog3,
      form.lbl_item3,
      form.lbl_date3
    }
  }
  for i = 1, table.getn(tab_juqing_right) do
    for j = 1, table.getn(tab_juqing_right[i]) do
      tab_juqing_right[i][j].Visible = false
    end
  end
  local tab_fav_heart = {
    {
      form.lbl_fav_heart_1,
      form.lbl_fav_heart_2,
      form.lbl_fav_heart_3
    },
    {
      form.lbl_fav_heart_4,
      form.lbl_fav_heart_5,
      form.lbl_fav_heart_6
    },
    {
      form.lbl_fav_heart_7,
      form.lbl_fav_heart_8,
      form.lbl_fav_heart_9
    }
  }
  for i = 1, table.getn(tab_fav_heart) do
    for j = 1, table.getn(tab_fav_heart[i]) do
      tab_fav_heart[i][j].Visible = false
    end
  end
  if juqing_count == 0 then
    form.lbl_juqing_divide_1.Visible = false
    form.lbl_juqing_divide_2.Visible = false
    form.btn_jq_last.Visible = false
    form.btn_jq_last.Visible = false
    form.btn_jq_next.Visible = false
    form.ipt_jq_page.Visible = false
    form.ipt_jq_max_page.Visible = false
    form.lbl_page_devide_1.Visible = false
    form.groupscrollbox_juqing_right.BackImage = "gui\\special\\sns_new\\jh_explore\\juqing\\wkq.png"
    form.btn_item_course.Visible = false
    return
  else
    form.groupscrollbox_juqing_right.BackImage = "gui\\special\\sns_new\\jh_explore\\youlidadi.png"
  end
  local begin_pos = (cur_page - 1) * page_num + 1
  local end_pos = cur_page * page_num
  local index = 1
  for i = 1, juqing_count do
    if i >= begin_pos and i <= end_pos then
      local table_plot = jhmgr:GetJhPlotInfo(table_juqing_index[i])
      if table.getn(table_plot) >= 4 then
        local control_name = tab_juqing_right[index][1]
        local control_value = tab_juqing_right[index][2]
        control_name.Visible = true
        control_name.Text = util_text(nx_string(table_plot[3]))
        control_value.Visible = true
        control_value.Text = nx_widestr(table_plot[4])
        tab_juqing_right[index][9].Visible = true
        tab_juqing_right[index][9].Text = util_text(nx_string(table_plot[1]))
        tab_juqing_right[index][10].Visible = true
        tab_juqing_right[index][10].Text = util_text(nx_string(table_plot[5]))
        tab_juqing_right[index][11].Visible = true
        tab_juqing_right[index][11].Text = util_text(nx_string(table_plot[6]))
        tab_juqing_right[index][12].Visible = true
        tab_juqing_right[index][12].Text = util_text(nx_string(table_plot[7]))
      end
      local table_fav = jhmgr:GetJhFavorableInfo(table_juqing_index[i])
      local rows = table.getn(table_fav)
      if 6 < rows then
        rows = 6
      end
      local k = 1
      for j = 1, rows, 2 do
        local control_name = tab_juqing_right[index][j + 2]
        local control_value = tab_juqing_right[index][j + 3]
        control_name.Visible = true
        control_name.Text = util_text(nx_string(table_fav[j]))
        control_value.Visible = true
        control_value.Text = nx_widestr(table_fav[j + 1])
        tab_fav_heart[index][k].Visible = true
        k = k + 1
      end
      if client_player:FindRecord("JHExplore_Record") then
        local row = client_player:FindRecordRow("JHExplore_Record", 2, table_juqing_index[i])
        if 0 <= row then
          local finish_date = client_player:QueryRecord("JHExplore_Record", row, 4)
          local t = os.date("*t", finish_date)
          local show_date = nx_widestr(t.year) .. nx_widestr("/") .. nx_widestr(t.month) .. nx_widestr("/") .. nx_widestr(t.day)
          tab_juqing_right[index][13].Visible = true
          tab_juqing_right[index][13].Text = nx_widestr(show_date)
        end
      end
      tab_juqing_group[index].Visible = true
      index = index + 1
    end
  end
end
function show_juqing_end(form)
  form.groupscrollbox_juqing_right.Visible = false
  form.groupbox_ending.Visible = true
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local juqing_count, table_juqing_index = get_same_juqing_info(form.cur_uid)
  local sum_hangandu = 0
  local sum_youlizhi = 0
  for i = 1, juqing_count do
    local table_fav = jhmgr:GetJhFavorableInfo(table_juqing_index[i])
    for j = 1, table.getn(table_fav), 2 do
      sum_hangandu = sum_hangandu + table_fav[j + 1]
    end
    local table_plot = jhmgr:GetJhPlotInfo(table_juqing_index[i])
    sum_youlizhi = sum_youlizhi + table_plot[4]
  end
  form.lbl_sum_youlizhi.Text = nx_widestr(nx_int(sum_youlizhi))
  form.lbl_sum_haogandu.Text = nx_widestr(nx_int(sum_hangandu))
  local explore_id = get_juqing_end_explore_id(form.cur_uid)
  local tab_end_info = jhmgr:GetJhPlotInfo(explore_id)
  local end_title = tab_end_info[8]
  local end_content = tab_end_info[9]
  local end_image = tab_end_info[10]
  form.lbl_end_title.BackImage = nx_string(end_title)
  form.mltbox_end_content.HtmlText = util_text(nx_string(end_content))
  form.lbl_end_pic.BackImage = nx_string(end_image)
end
function show_prize_right(form)
  local table_prize_show = {
    [1] = {
      unactivate = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_wjh.png",
      unprize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_out.png",
      prize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_jy.png",
      on = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_on.png",
      down = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_down.png"
    },
    [2] = {
      unactivate = "gui\\special\\sns_new\\jh_explore\\baoxiang\\zj_wjh.png",
      unprize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\zj_out.png",
      prize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\zj_jy.png",
      on = "gui\\special\\sns_new\\jh_explore\\baoxiang\\zj_on.png",
      down = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_down.png"
    },
    [3] = {
      unactivate = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_wjh.png",
      unprize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_out.png",
      prize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_jy.png",
      on = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_on.png",
      down = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_down.png"
    }
  }
  for i = 1, table.getn(table_prize_btn) do
    table_prize_btn[i].Visible = false
  end
  local table_tour_level = {
    form.lbl_tour_level_1,
    form.lbl_tour_level_2,
    form.lbl_tour_level_3,
    form.lbl_tour_level_4,
    form.lbl_tour_level_5,
    form.lbl_tour_level_6,
    form.lbl_tour_level_7,
    form.lbl_tour_level_8,
    form.lbl_tour_level_9,
    form.lbl_tour_level_10,
    form.lbl_tour_level_11,
    form.lbl_tour_level_12,
    form.lbl_tour_level_13,
    form.lbl_tour_level_14,
    form.lbl_tour_level_15
  }
  for i = 1, table.getn(table_tour_level) do
    table_tour_level[i].Visible = false
  end
  local table_tour_max_point = {
    form.lbl_maxpoint_1,
    form.lbl_maxpoint_2,
    form.lbl_maxpoint_3,
    form.lbl_maxpoint_4,
    form.lbl_maxpoint_5,
    form.lbl_maxpoint_6,
    form.lbl_maxpoint_7,
    form.lbl_maxpoint_8,
    form.lbl_maxpoint_9,
    form.lbl_maxpoint_10,
    form.lbl_maxpoint_11,
    form.lbl_maxpoint_12,
    form.lbl_maxpoint_13,
    form.lbl_maxpoint_14,
    form.lbl_maxpoint_15
  }
  for i = 1, table.getn(table_tour_max_point) do
    table_tour_max_point[i].Visible = false
  end
  local table_unprize_ani = {
    form.ani_1,
    form.ani_2,
    form.ani_3,
    form.ani_4,
    form.ani_5,
    form.ani_6,
    form.ani_7,
    form.ani_8,
    form.ani_9,
    form.ani_10,
    form.ani_11,
    form.ani_12,
    form.ani_13,
    form.ani_14,
    form.ani_15
  }
  for i = 1, table.getn(table_unprize_ani) do
    table_unprize_ani[i].Visible = false
  end
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local cur_scene_id = get_scene_id()
  local tab_scene_info = jhmgr:GetTourRenownConfig(cur_scene_id)
  local tour_config = tab_scene_info[1]
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local tab_prizeinfo = jhmgr:GetJhTourPrizeInfo(tour_config)
  local gui = nx_value("gui")
  local index = 1
  for i = 1, table.getn(tab_prizeinfo), 3 do
    local prize_level = tab_prizeinfo[i + 2]
    local tour_level = tab_prizeinfo[i]
    table_prize_btn[index].tour_level = tour_level
    table_prize_btn[index].prize_level = prize_level
    table_prize_btn[index].Visible = true
    table_tour_level[index].Visible = true
    local tab_tour_need_point = jhmgr:GetJhTourMaxPoint(tour_level)
    table_tour_max_point[index].Visible = true
    table_tour_max_point[index].Text = nx_widestr(nx_int(tab_tour_need_point[1]))
    local isPrized = 1
    local isActivated = 0
    isPrized, isActivated = checkPrizeStatus(tour_config, tour_level)
    if isActivated == 0 then
      table_prize_btn[index].NormalImage = table_prize_show[prize_level].unprize
      local tab_scene_name = jhmgr:GetJhSceneName(cur_scene_id)
      table_prize_btn[index].HintText = gui.TextManager:GetFormatText("ui_jh_prize_" .. nx_string(tab_scene_name[1]) .. "_" .. tour_level)
      table_prize_btn[index].Enabled = false
      table_unprize_ani[index].Visible = false
    elseif isPrized == 0 then
      table_prize_btn[index].NormalImage = table_prize_show[prize_level].unprize
      table_prize_btn[index].FocusImage = table_prize_show[prize_level].on
      table_prize_btn[index].PushImage = table_prize_show[prize_level].down
      table_prize_btn[index].HintText = nx_widestr("")
      table_prize_btn[index].Enabled = true
      table_unprize_ani[index].Visible = true
    else
      table_prize_btn[index].NormalImage = table_prize_show[prize_level].prize
      table_prize_btn[index].HintText = nx_widestr("")
      table_prize_btn[index].Enabled = false
      table_unprize_ani[index].Visible = false
    end
    index = index + 1
  end
end
function on_btn_prize_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local cur_scene_id = get_scene_id()
  local tab_scene_info = jhmgr:GetTourRenownConfig(cur_scene_id)
  local tour_config = tab_scene_info[1]
  nx_execute("custom_sender", "custom_get_tourprize", nx_int(jh_client_explore_msg_get_prize), nx_string(tour_config), nx_int(btn.tour_level))
  local table_prize_show = {
    [1] = {
      unactivate = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_wjh.png",
      unprize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_out.png",
      prize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_jy.png",
      on = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_on.png",
      down = "gui\\special\\sns_new\\jh_explore\\baoxiang\\pt_down.png"
    },
    [2] = {
      unactivate = "gui\\special\\sns_new\\jh_explore\\baoxiang\\zj_wjh.png",
      unprize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\zj_out.png",
      prize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\zj_jy.png",
      on = "gui\\special\\sns_new\\jh_explore\\baoxiang\\zj_on.png",
      down = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_down.png"
    },
    [3] = {
      unactivate = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_wjh.png",
      unprize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_out.png",
      prize = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_jy.png",
      on = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_on.png",
      down = "gui\\special\\sns_new\\jh_explore\\baoxiang\\gj_down.png"
    }
  }
  local table_unprize_ani = {
    form.ani_1,
    form.ani_2,
    form.ani_3,
    form.ani_4,
    form.ani_5,
    form.ani_6,
    form.ani_7,
    form.ani_8,
    form.ani_9,
    form.ani_10,
    form.ani_11,
    form.ani_12,
    form.ani_13,
    form.ani_14,
    form.ani_15
  }
  table_prize_btn[btn.tour_level - 1].NormalImage = table_prize_show[btn.prize_level].down
  table_prize_btn[btn.tour_level - 1].Enabled = false
  table_unprize_ani[btn.tour_level - 1].Visible = false
end
function on_rbtn_youli_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.rbtn_juqing.Checked = false
  form.rbtn_prize.Checked = false
  form.rbtn_daoju.Checked = false
  form.groupbox_youli.Visible = true
  form.groupbox_daoju.Visible = false
  form.groupbox_juqing.Visible = false
  form.groupbox_prize.Visible = false
  form.cur_yl_page = 1
  show_youli_left(form)
  show_youli_right(form, form.cur_yl_page, youli_page_num)
end
function on_rbtn_daoju_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.rbtn_youli.Checked = false
  form.rbtn_juqing.Checked = false
  form.rbtn_prize.Checked = false
  form.groupbox_youli.Visible = false
  form.groupbox_daoju.Visible = true
  form.groupbox_juqing.Visible = false
  form.groupbox_prize.Visible = false
end
function on_rbtn_juqing_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.rbtn_youli.Checked = false
  form.rbtn_daoju.Checked = false
  form.rbtn_prize.Checked = false
  form.groupbox_youli.Visible = false
  form.groupbox_daoju.Visible = false
  form.groupbox_juqing.Visible = true
  form.groupbox_prize.Visible = false
  show_juqing_left(form)
  form.cur_jq_page = 1
  show_juqing_right(form, nx_int(form.cur_jq_page), nx_int(juqing_page_num))
end
function on_rbtn_prize_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.rbtn_youli.Checked = false
  form.rbtn_daoju.Checked = false
  form.rbtn_juqing.Checked = false
  form.groupbox_youli.Visible = false
  form.groupbox_daoju.Visible = false
  form.groupbox_juqing.Visible = false
  form.groupbox_prize.Visible = true
  show_prize_right(form)
end
function on_btn_show_jq_detail_click(btn)
  local form = btn.ParentForm
  form.cur_jq_page = 1
  show_juqing_detail(form, 1, juqing_page_num)
end
function on_btn_jq_left_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_uid = form.btn_jq_left_1.uid
  if form.cur_status == 1 then
    show_juqing_end(form)
  else
    show_juqing_detail(form, 1, juqing_page_num)
  end
end
function on_btn_jq_left_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_uid = form.btn_jq_left_2.uid
  show_juqing_end(form)
end
function on_btn_jq_left_3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_uid = form.btn_jq_left_3.uid
  show_juqing_end(form)
end
function on_btn_jq_left_4_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_uid = form.btn_jq_left_4.uid
  show_juqing_end(form)
end
function on_btn_jq_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.cur_jq_page) >= nx_int(form.jq_max_page) then
    form.cur_jq_page = form.jq_max_page
  else
    form.cur_jq_page = form.cur_jq_page + 1
  end
  show_juqing_detail(form, nx_int(form.cur_jq_page), juqing_page_num)
end
function on_btn_jq_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.cur_jq_page) <= nx_int(1) then
    form.cur_jq_page = 1
  else
    form.cur_jq_page = form.cur_jq_page - 1
  end
  show_juqing_detail(form, nx_int(form.cur_jq_page), juqing_page_num)
end
function on_btn_yl_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.cur_yl_page) >= nx_int(form.yl_max_page) then
    form.cur_yl_page = form.yl_max_page
  else
    form.cur_yl_page = form.cur_yl_page + 1
  end
  show_youli_right(form, nx_int(form.cur_yl_page), youli_page_num)
end
function on_btn_yl_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.cur_yl_page) <= nx_int(1) then
    form.cur_yl_page = 1
  else
    form.cur_yl_page = form.cur_yl_page - 1
  end
  show_youli_right(form, nx_int(form.cur_yl_page), youli_page_num)
end
function on_btn_jiangli_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = gui.TextManager:GetText("ui_jianghu_award")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIANGHU_MEET), nx_int(CUSTOMMSG_JIANGHU_MEET_AWARD))
  else
    return
  end
end
function on_btn_item_course_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.lbl_item_kuang.Visible = false
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_jianghu_item_course", true, false)
  dialog:ShowModal()
end
function is_jh_scene()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not player:FindProp("CurJHSceneConfigID") then
    return false
  end
  local jh_scene = player:QueryProp("CurJHSceneConfigID")
  if jh_scene == nil or jh_scene == "" then
    return false
  end
  return true
end
function bind_record_call_back(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("JHTour_Record", form, "form_stage_main\\form_task\\form_jianghu_explore", "on_jhtour_record_change")
    databinder:AddTableBind("JHRenown_Record", form, "form_stage_main\\form_task\\form_jianghu_explore", "on_jhrenown_record_change")
    databinder:AddTableBind("JHFavorable_Record", form, "form_stage_main\\form_task\\form_jianghu_explore", "on_jhfavorable_record_change")
    databinder:AddTableBind("JHExplore_Record", form, "form_stage_main\\form_task\\form_jianghu_explore", "on_jhexplore_record_change")
  end
end
function on_jhexplore_record_change(self, recordname, optype, row, clomn)
  if not is_jh_scene() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_jianghu_explore", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  if not client_player:FindRecord("JHExplore_Record") then
    return 0
  end
  if optype == "add" or optype == "update" or optype == "del" or optype == "clear" then
    show_juqing_left(form)
    show_juqing_right(form, nx_int(form.cur_jq_page), nx_int(juqing_page_num))
  end
end
function on_jhtour_record_change(self, recordname, optype, row, clomn)
  if not is_jh_scene() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_jianghu_explore", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  if not client_player:FindRecord("JHTour_Record") then
    return 0
  end
  if optype == "add" or optype == "update" or optype == "del" or optype == "clear" then
    show_youli_left(form)
  end
end
function on_jhrenown_record_change(self, recordname, optype, row, clomn)
  if not is_jh_scene() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_jianghu_explore", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  if not client_player:FindRecord("JHRenown_Record") then
    return 0
  end
  if optype == "add" or optype == "update" or optype == "del" or optype == "clear" then
    show_youli_left(form)
  end
end
function on_jhfavorable_record_change(self, recordname, optype, row, clomn)
  if not is_jh_scene() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_jianghu_explore", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  if not client_player:FindRecord("JHFavorable_Record") then
    return 0
  end
  if optype == "add" or optype == "update" or optype == "del" or optype == "clear" then
    show_youli_right(form, form.cur_yl_page, youli_page_num)
  end
end
function get_juqing_end_explore_id(cur_uid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("JHExplore_Record") then
    return 0
  end
  local explore_id = 0
  local rows = client_player:GetRecordRows("JHExplore_Record")
  for i = 0, rows do
    local uid = client_player:QueryRecord("JHExplore_Record", i, 1)
    if nx_string(uid) == nx_string(cur_uid) then
      explore_id = client_player:QueryRecord("JHExplore_Record", i, 2)
    end
  end
  return explore_id
end
function get_same_juqing_info(cur_uid)
  local count = 0
  local table_index = {}
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return count, table_index
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return count, table_index
  end
  if not client_player:FindRecord("JHExplore_Record") then
    return count, table_index
  end
  local rows = client_player:GetRecordRows("JHExplore_Record")
  for i = 0, rows do
    local uid = client_player:QueryRecord("JHExplore_Record", i, 1)
    local index = client_player:QueryRecord("JHExplore_Record", i, 2)
    if nx_string(uid) == nx_string(cur_uid) then
      count = count + 1
      table.insert(table_index, index)
    end
  end
  return count, table_index
end
function get_juqing_info(form, cur_scene_id)
  local tab = {}
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return tab
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return tab
  end
  if not client_player:FindRecord("JHExplore_Record") then
    return tab
  end
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return tab
  end
  local compare_uid = ""
  local rows = client_player:GetRecordRows("JHExplore_Record")
  for i = 0, rows do
    local scene_name = client_player:QueryRecord("JHExplore_Record", i, 0)
    local tab_scene_name = jhmgr:GetJhSceneName(cur_scene_id)
    if nx_string(scene_name) == nx_string(tab_scene_name[1]) then
      local uid = client_player:QueryRecord("JHExplore_Record", i, 1)
      if nx_string(uid) ~= nx_string(compare_uid) then
        compare_uid = uid
        table.insert(tab, uid)
        local status = client_player:QueryRecord("JHExplore_Record", i, 3)
        table.insert(tab, status)
      end
    end
  end
  return tab
end
function show_youli_page(form)
  form.lbl_yl_page.Text = nx_widestr(nx_int(form.cur_yl_page))
  form.lbl_yl_max_page.Text = nx_widestr(nx_int(form.yl_max_page))
end
function show_juqing_page(form)
  form.ipt_jq_page.Text = nx_widestr(nx_int(form.cur_jq_page))
  form.ipt_jq_max_page.Text = nx_widestr(nx_int(form.jq_max_page))
end
function get_max_page(item_num, page_num)
  local max_page = 1
  if nx_int(page_num) == nx_int(0) then
    return 1
  end
  max_page = nx_int(item_num) / nx_int(page_num)
  if max_page == 0 then
    max_page = 1
  end
  local temp = nx_int(item_num) - nx_int(max_page) * nx_int(page_num)
  if nx_int(temp) > nx_int(0) then
    max_page = max_page + 1
  end
  return max_page
end
function checkPrizeStatus(tour_config, tour_level)
  local isPrized = 1
  local isActivated = 0
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return isPrized, isActivated
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return isPrized, isActivated
  end
  if not client_player:FindRecord("JHTour_Prize_Rec") then
    return isPrized, isActivated
  end
  local rows = client_player:GetRecordRows("JHTour_Prize_Rec")
  for i = 0, rows do
    local config = client_player:QueryRecord("JHTour_Prize_Rec", i, 0)
    local level = client_player:QueryRecord("JHTour_Prize_Rec", i, 1)
    if tour_config == config and tour_level == level then
      isActivated = 1
      isPrized = client_player:QueryRecord("JHTour_Prize_Rec", i, 2)
      return isPrized, isActivated
    end
  end
  return isPrized, isActivated
end
function refresh_btn_jiangli(type, ...)
  if nx_number(type) ~= SERVER_SUB_CUSTOMMSG_JH_AWARD_CAN_GET then
    return 0
  end
  local form = util_get_form("form_stage_main\\form_task\\form_jianghu_explore", false)
  if not nx_is_valid(form) then
    return 0
  end
  local can_get = nx_number(arg[1])
  if can_get == 1 then
    form.btn_jiangli.Enabled = true
  else
    form.btn_jiangli.Enabled = false
  end
end
function open_form_by_type(type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_jianghu_explore", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  if nx_int(type) == nx_int(1) then
    form.groupbox_youli.Visible = true
    form.groupbox_daoju.Visible = false
    form.groupbox_juqing.Visible = false
    form.groupbox_prize.Visible = false
    form.rbtn_youli.Checked = true
    form.rbtn_daoju.Checked = false
    form.rbtn_juqing.Checked = false
    form.rbtn_prize.Checked = false
  elseif nx_int(type) == nx_int(2) then
    form.groupbox_youli.Visible = false
    form.groupbox_daoju.Visible = true
    form.groupbox_juqing.Visible = false
    form.groupbox_prize.Visible = false
    form.rbtn_youli.Checked = false
    form.rbtn_daoju.Checked = true
    form.rbtn_juqing.Checked = false
    form.rbtn_prize.Checked = false
  elseif nx_int(type) == nx_int(3) then
    form.groupbox_youli.Visible = false
    form.groupbox_daoju.Visible = false
    form.groupbox_juqing.Visible = true
    form.groupbox_prize.Visible = false
    form.rbtn_youli.Checked = false
    form.rbtn_daoju.Checked = false
    form.rbtn_juqing.Checked = true
    form.rbtn_prize.Checked = false
  else
    form.groupbox_youli.Visible = false
    form.groupbox_daoju.Visible = false
    form.groupbox_juqing.Visible = false
    form.groupbox_prize.Visible = true
    form.rbtn_youli.Checked = false
    form.rbtn_daoju.Checked = false
    form.rbtn_juqing.Checked = false
    form.rbtn_prize.Checked = true
  end
end
function update_today_youli(...)
  local tour_config = arg[1]
  local now_time = arg[2]
  local tour_date_point = 0
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("JHTour_Record") then
    return
  end
  local row = client_player:FindRecordRow("JHTour_Record", 0, nx_string(tour_config))
  if 0 <= row then
    tour_date = client_player:QueryRecord("JHTour_Record", row, 3)
    now_time = os.date("*t", now_time)
    local now_date = now_time.year * 10000 + now_time.month * 100 + now_time.day
    if tour_date == now_date then
      tour_date_point = client_player:QueryRecord("JHTour_Record", row, 4)
    end
  end
  form.lbl_today_youli_point.Text = nx_widestr(nx_int(tour_date_point))
end
local FORM_EXPLORE = "form_stage_main\\form_task\\form_jianghu_explore"
local INI_CLUE = "share\\Rule\\JHExplore\\jh_explore_item.ini"
local INI_PROGRESS = "share\\Rule\\JHExplore\\jh_item_progress.ini"
local PHOTO_DEFAULT = "gui\\special\\sns_new\\jh_explore\\djlc\\wh.png"
local NAME_DEFAULT = "???"
local PHOTO_CLUE_DEFAULT = "gui\\special\\sns_new\\jh_explore\\daoju\\jhxx1.png"
local PHOTO_CLUE_UNOPEN = "gui\\special\\sns_new\\jh_explore\\daoju\\jhxx1.png"
local PHOTO_CLUE_OPEN = "gui\\special\\sns_new\\jh_explore\\daoju\\jhxx2.png"
local ANIMATION_LIGHT = "newworld_item01_click"
local REC_EXPLORE = "JHExplore_Record"
local REC_CLUE = "explore_item_rec"
local STATUS_DOING = 0
local STATUS_COMPLETE = 1
local COUNT_PER_PAGE = 4
local COUNT_PER_ROW = 3
local table_item = {}
local table_clue = {}
local table_clue_id = {}
local table_mltbox_clue = {}
function set_item_info(form)
  get_item_info()
  set_default_item_page(form)
  set_default_select_pos(form)
  set_item_show(form)
  set_item_light(form)
  set_item_desc(form)
  get_clue_info()
  set_clue_show(form)
  set_item_progress(form)
end
function set_item_show(form)
  set_page_turn(form)
  set_default_item_label(form)
  set_item_label(form)
end
function get_item_info()
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  table_item = {}
  local explorer = nx_value("JianghuExploreModule")
  if not nx_is_valid(explorer) then
    return
  end
  explorer:LoadResource(nx_resource_path() .. "share\\")
  local table_scene_name = explorer:GetJhSceneName(get_scene_id())
  if not player:FindRecord(REC_EXPLORE) then
    return
  end
  local rows = player:GetRecordRows(REC_EXPLORE)
  for i = 0, rows - 1 do
    local explore_scene_name = player:QueryRecord(REC_EXPLORE, i, 0)
    if nx_string(table_scene_name[1]) == nx_string(explore_scene_name) then
      local status = player:QueryRecord(REC_EXPLORE, i, 3)
      if nx_int(status) == nx_int(STATUS_DOING) then
        local explore_id = player:QueryRecord(REC_EXPLORE, i, 2)
        local table_info = explorer:GetJhPlotInfo(explore_id)
        local item_id = table_info[7]
        if nx_string(item_id) ~= nx_string("") then
          table.insert(table_item, item_id)
        end
      end
    end
  end
end
function set_default_item_page(form)
  local total_page = 1
  local count = table.getn(table_item)
  if nx_int(count) == nx_int(0) then
    total_page = 1
  else
    local base_page = nx_int(count / COUNT_PER_PAGE)
    if count % COUNT_PER_PAGE == 0 then
      total_page = base_page
    else
      total_page = base_page + 1
    end
  end
  nx_set_custom(form, "total_page", nx_int(total_page))
  nx_set_custom(form, "cur_page", nx_int(total_page))
  form.lbl_cur_page.Text = nx_widestr(form.cur_page)
  form.lbl_total_page.Text = nx_widestr(form.total_page)
end
function set_page_turn(form)
  form.btn_prev.Visible = true
  form.btn_next.Visible = true
  if not nx_find_custom(form, "cur_page") or not nx_find_custom(form, "total_page") then
    return
  end
  local cur_page = form.cur_page
  if nx_int(cur_page) == nx_int(1) then
    form.btn_prev.Visible = false
  end
  local total_page = form.total_page
  if nx_int(cur_page) == nx_int(total_page) then
    form.btn_next.Visible = false
  end
end
function set_item_label(form)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if not nx_find_custom(form, "cur_page") then
    return
  end
  local cur_page = form.cur_page
  local count = table.getn(table_item)
  if nx_int(count) <= nx_int(0) then
    return
  end
  local start_pos = (cur_page - 1) * COUNT_PER_PAGE + 1
  if nx_int(start_pos) < nx_int(1) or nx_int(start_pos) > nx_int(count) then
    return
  end
  local end_pos = math.min(start_pos + COUNT_PER_PAGE, count)
  if nx_int(start_pos) < nx_int(1) or nx_int(start_pos) > nx_int(count) then
    return
  end
  local table_part_item = {}
  for i = start_pos, end_pos do
    table.insert(table_part_item, table_item[i])
  end
  local part_count = table.getn(table_part_item)
  for i = 1, part_count do
    item_id = table_part_item[i]
    local photo = item_query:GetItemPropByConfigID(item_id, "Photo")
    local name = util_text(nx_string(item_id))
    local name_photo = nx_string("lbl_photo0") .. nx_string(i)
    local name_name = nx_string("lbl_name0") .. nx_string(i)
    local ctrl_photo = form.gb_item_list:Find(name_photo)
    local ctrl_name = form.gb_item_list:Find(name_name)
    if not nx_is_valid(ctrl_photo) or not nx_is_valid(ctrl_name) then
      return
    end
    ctrl_photo.BackImage = nx_string(photo)
    ctrl_name.Text = nx_widestr(name)
    nx_set_custom(ctrl_name, "item_id", nx_string(item_id))
  end
end
function set_default_item_label(form)
  for i = 1, COUNT_PER_PAGE do
    local name_photo = nx_string("lbl_photo0") .. nx_string(i)
    local name_border = nx_string("lbl_border0") .. nx_string(i)
    local name_name = nx_string("lbl_name0") .. nx_string(i)
    local ctrl_photo = form.gb_item_list:Find(name_photo)
    local ctrl_border = form.gb_item_list:Find(name_border)
    local ctrl_name = form.gb_item_list:Find(name_name)
    if not (nx_is_valid(ctrl_photo) and nx_is_valid(ctrl_border)) or not nx_is_valid(ctrl_name) then
      return
    end
    ctrl_photo.BackImage = nx_string(PHOTO_DEFAULT)
    ctrl_border.BackImage = nx_string("")
    ctrl_name.Text = nx_widestr(NAME_DEFAULT)
    nx_set_custom(ctrl_name, "item_id", nx_string(""))
  end
end
function set_prev_page(form)
  if not nx_find_custom(form, "cur_page") then
    return
  end
  local cur_page = form.cur_page
  cur_page = math.max(1, cur_page - 1)
  nx_set_custom(form, "cur_page", nx_int(cur_page))
  form.lbl_cur_page.Text = nx_widestr(form.cur_page)
end
function set_next_page(form)
  if not nx_find_custom(form, "cur_page") or not nx_find_custom(form, "total_page") then
    return
  end
  local cur_page = form.cur_page
  local total_page = form.total_page
  cur_page = math.min(total_page, cur_page + 1)
  nx_set_custom(form, "cur_page", nx_int(cur_page))
  form.lbl_cur_page.Text = nx_widestr(form.cur_page)
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_prev_page(form)
  set_item_show(form)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_next_page(form)
  set_item_show(form)
end
function set_default_select_pos(form)
  local pos_select = 0
  local count = table.getn(table_item)
  if nx_int(count) ~= nx_int(0) then
    pos_select = count % COUNT_PER_PAGE
    if nx_int(pos_select) == nx_int(0) then
      pos_select = COUNT_PER_PAGE
    end
  end
  nx_set_custom(form, "pos_select", nx_int(pos_select))
end
function set_select_pos(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pos_select = nx_int(lbl.DataSource)
  nx_set_custom(form, "pos_select", nx_int(pos_select))
end
function clear_select_pos(form)
  nx_set_custom(form, "pos_select", nx_int(0))
end
function on_item_click(lbl)
  if not can_select_item(lbl) then
    return
  end
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_select_pos(lbl)
  set_item_show(form)
  set_item_light(form)
  set_item_desc(form)
  set_clue_show(form)
end
function can_select_item(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local pos_select = nx_int(lbl.DataSource)
  local name_name = nx_string("lbl_name0") .. nx_string(pos_select)
  local ctrl_name = form.gb_item_list:Find(name_name)
  if not nx_is_valid(ctrl_name) then
    return false
  end
  if not nx_find_custom(ctrl_name, "item_id") then
    return false
  end
  local item_id = ctrl_name.item_id
  if string.len(item_id) == 0 then
    return false
  end
  return true
end
function set_item_desc(form)
  local lbl = form.lbl_item_name
  if not nx_is_valid(lbl) then
    return
  end
  local mltbox = form.mltbox_item_desc
  if not nx_is_valid(mltbox) then
    return
  end
  lbl.Text = nx_widestr("")
  mltbox.HtmlText = nx_widestr("")
  local item_id = get_select_item(form)
  if string.len(item_id) == 0 then
    return
  end
  local desc_item = nx_string("desc_") .. nx_string(item_id) .. nx_string("_0")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local name = gui.TextManager:GetText(item_id)
  if string.len(nx_string(name)) == 0 then
    return
  end
  lbl.Text = nx_widestr(name)
  local content = gui.TextManager:GetText(desc_item)
  if string.len(nx_string(content)) == 0 then
    return
  end
  mltbox.HtmlText = nx_widestr(content)
end
function set_item_light(form)
  if not nx_find_custom(form, "pos_select") then
    return
  end
  local pos_select = form.pos_select
  local name_border = nx_string("lbl_border0") .. nx_string(pos_select)
  local ctrl_border = form.gb_item_list:Find(name_border)
  if not nx_is_valid(ctrl_border) then
    return
  end
  ctrl_border.BackImage = nx_string(ANIMATION_LIGHT)
end
function get_clue_info()
  local ini = get_ini(INI_CLUE)
  if not nx_is_valid(ini) then
    return
  end
  table_clue_id = {}
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local table_part_clue = {}
    local item_id = ini:GetSectionByIndex(i)
    local index = ini:ReadInteger(i, "index", 0)
    local clue_count = ini:GetSectionItemCount(i)
    for j = 1, clue_count - 1 do
      local clue_id = ini:GetSectionItemValue(i, j)
      if string.len(clue_id) ~= 0 then
        local clue_index = index * 100 + j
        table.insert(table_part_clue, j, nx_string(clue_index))
        table_clue_id[nx_number(clue_index)] = nx_string(clue_id)
      end
    end
    table_clue[nx_string(item_id)] = table_part_clue
  end
end
function set_clue_show(form)
  set_default_clue_mltbox(form)
  set_clue_mltbox(form)
end
function get_select_item(form)
  if not nx_find_custom(form, "pos_select") then
    return ""
  end
  local pos_select = form.pos_select
  local name_name = nx_string("lbl_name0") .. nx_string(pos_select)
  local ctrl_name = form.gb_item_list:Find(name_name)
  if not nx_is_valid(ctrl_name) then
    return ""
  end
  if not nx_find_custom(ctrl_name, "item_id") then
    return ""
  end
  local item_id = ctrl_name.item_id
  return item_id
end
function set_default_clue_mltbox(form)
  local item_id = get_select_item(form)
  if string.len(item_id) == 0 then
    return
  end
  if table_clue[item_id] == nil then
    return
  end
  local table_part_clue = table_clue[item_id]
  local count = table.getn(table_part_clue)
  if nx_int(count) < nx_int(0) then
    return
  end
  add_clue(form, count)
end
function add_clue(form, count)
  form.gsb_clue:DeleteAll()
  table_mltbox_clue = {}
  nx_set_custom(form.gsb_clue, "row_count", nx_int(0))
  local row = nx_number(0)
  if nx_int(count % COUNT_PER_ROW) ~= nx_int(0) then
    row = nx_number(count / COUNT_PER_ROW + 1)
  else
    row = nx_number(count / COUNT_PER_ROW)
  end
  if nx_int(count) == nx_int(0) then
    row = nx_number(1)
  end
  form.gsb_clue.IsEditMode = true
  for i = 1, row do
    local gb_clue = create_gb_clue(form, i)
    if nx_is_valid(gb_clue) then
      add_gb_to_gsb(gb_clue, form.gsb_clue)
    end
  end
  form.gsb_clue.IsEditMode = false
end
function add_gb_to_gsb(gb, gsb)
  if not nx_find_custom(gsb, "row_count") then
    return
  end
  gb.Left = 8
  gb.Top = (gb.Height + 25) * gsb.row_count + -2
  gsb:Add(gb)
  local count = gsb.row_count + 1
  nx_set_custom(gsb, "row_count", nx_int(count))
end
function create_gb_clue(form, index_gb)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local gb_clue = gui:Create("GroupBox")
  gb_clue.Width = 543
  gb_clue.Height = 235
  gb_clue.BackColor = "0,255,255,255"
  gb_clue.NoFrame = true
  gb_clue.DrawMode = "FitWindow"
  gb_clue.BackImage = nx_string("")
  gb_clue.Name = "gb_clue_" .. nx_string(index_gb)
  for i = 1, COUNT_PER_ROW do
    local mltbox_clue = create_mltbox_clue(form, index_gb, i)
    if nx_is_valid(mltbox_clue) then
      gb_clue:Add(mltbox_clue)
      table.insert(table_mltbox_clue, mltbox_clue)
    end
  end
  return gb_clue
end
function create_mltbox_clue(form, index_gb, index_mltbox)
  local gui = nx_value("gui")
  local mltbox_clue = gui:Create("MultiTextBox")
  mltbox_clue.NoFrame = "True"
  mltbox_clue.Left = -2 + (index_mltbox - 1) * 180
  mltbox_clue.Top = 0
  mltbox_clue.Width = 177
  mltbox_clue.Height = 225
  mltbox_clue.TextColor = "255,94,73,57"
  mltbox_clue.HtmlText = nx_widestr("")
  mltbox_clue.ViewRect = "30,31,150,210"
  mltbox_clue.Font = "font_sns_list"
  mltbox_clue.ForeColor = "255,128,101,74"
  mltbox_clue.Align = "Center"
  mltbox_clue.Transparent = true
  mltbox_clue.DrawMode = "Tile"
  mltbox_clue.BackImage = nx_string(PHOTO_CLUE_DEFAULT)
  mltbox_clue.Name = "mltbox_clue_" .. nx_string(index_gb) .. "_" .. nx_string(index_mltbox)
  return mltbox_clue
end
function set_clue_mltbox(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_id = get_select_item(form)
  if string.len(item_id) == 0 then
    return
  end
  if table_clue[item_id] == nil then
    return
  end
  local table_part_clue = table_clue[item_id]
  local count = table.getn(table_part_clue)
  for i = 1, count do
    local clue_index = nx_int(table_part_clue[i])
    if nx_int(clue_index) < nx_int(0) then
      return
    end
    local clue_id = nx_string(table_clue_id[nx_number(clue_index)])
    if string.len(clue_id) == 0 then
      return
    end
    local mltbox = table_mltbox_clue[i]
    if not nx_is_valid(mltbox) then
      return
    end
    if is_get_clue(clue_index) then
      local desc_clue = nx_string("desc_") .. nx_string(clue_id) .. nx_string("_a")
      local desc = gui.TextManager:GetText(desc_clue)
      if string.len(nx_string(desc)) == 0 then
        return
      end
      mltbox.HtmlText = nx_widestr(desc)
      mltbox.BackImage = nx_string(PHOTO_CLUE_OPEN)
    else
      mltbox.BackImage = nx_string(PHOTO_CLUE_UNOPEN)
    end
  end
end
function is_get_clue(clue_index)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return false
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindRecord(REC_CLUE) then
    return false
  end
  local row = player:FindRecordRow(REC_CLUE, 0, clue_index)
  if nx_int(row) >= nx_int(0) then
    return true
  end
  return false
end
function set_item_progress(form)
  local count = table.getn(table_item)
  if nx_int(count) <= nx_int(0) then
    form.pbar_item.Value = 0
    form.ani_role.Visible = false
    form.lbl_role.Visible = false
  else
    local item_id = nx_string(table_item[1])
    local total_count, bgimage = get_progress_info(item_id)
    if nx_int(total_count) <= nx_int(0) then
      return
    end
    local interval = nx_float(form.pbar_item.Width / total_count)
    form.pbar_item.Value = count
    form.pbar_item.Maximum = total_count
    form.ani_role.Visible = true
    form.ani_role.Left = form.pbar_item.Left + count * interval - form.ani_role.Width
    form.lbl_role.Visible = true
    form.lbl_role.Left = form.ani_role.Left
  end
end
function get_progress_info(item_id)
  local ini = get_ini(INI_PROGRESS)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string(item_id))
  if nx_int(index) < nx_int(0) then
    return
  end
  local count = ini:ReadInteger(index, "count", 0)
  local bgimage = ini:ReadString(index, "bgimage", "")
  return count, bgimage
end
