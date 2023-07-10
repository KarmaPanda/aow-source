require("utils")
require("util_functions")
require("util_gui")
require("util_vip")
require("util_static_data")
require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("define\\sysinfo_define")
require("tips_data")
require("role_composite")
local ACHIEVE_TYPE_QUANFU = 0
local ACHIEVE_TYPE_GUANJIA = 1
local ACHIEVE_TYPE_BOSS = 2
local ACHIEVE_TYPE_BOSSJIA = 3
local ACHIEVE_TYPE_GUANC = 4
local ACHIEVE_TYPE_HPDOWN = 5
local ACHIEVE_TYPE_HPUP = 6
local ACHIEVE_TYPE_TIMES = 7
local ACHIEVE_TYPE_ALLKILL = 8
local ACHIEVE_TYPE_ONLYBOSS = 9
local ACHIEVE_TYPE_BOSSFIGHT = 10
local TG_APPRAISE_LEVEL_0 = 0
local TG_APPRAISE_LEVEL_1 = 1
local TG_APPRAISE_LEVEL_2 = 2
local TG_APPRAISE_LEVEL_3 = 3
local TG_APPRAISE_LEVEL_MAX = 4
local TG_CHALLENGE_TASK_TYPE_0 = 0
local TG_CHALLENGE_TASK_TYPE_1 = 1
local TG_CHALLENGE_TASK_TYPE_2 = 2
local common_array_time = 5
local tiguan_level_max = 5
local tiguan_arrest_max = 9
local tiguan_challenge_task_max = 9
local achieve_level_max = 6
local achieve_lbl_back_pix1 = 47
local achieve_lbl_back_pix2 = 55
local achieve_rank_interval = 2
local achieve_quanfu_height = 80
local exchange_type_max = 6
local rank_col_count = 18
local rank_default_fore_color = "255,128,101,74"
local rank_select_fore_color = "255,78,63,47"
local rank_player_fore_color = "255,207,63,12"
local rank_col_guan_name = 0
local rank_col_level_name = 1
local rank_col_apply_control = 2
local rank_col_apply_num = 3
local rank_col_player_name = 4
local rank_col_title = 5
local rank_col_award_1 = 6
local rank_col_last_week = 7
local rank_col_my_score = 8
local rank_col_next_week = 9
local rank_col_rule_is_get = 10
local rank_col_rule_level = 11
local rank_col_rule_guan_id = 12
local rank_col_rule_sort = 13
local rank_col_rule_award = 14
local rank_col_rule_last = 15
local rank_col_rule_best = 16
local rank_col_rule_time = 17
local arrest_condition = {
  [1] = "",
  [2] = "",
  [3] = "",
  [4] = "",
  [5] = "",
  [6] = ""
}
local challenge_limit = {
  [1] = 7,
  [2] = 7,
  [3] = 6,
  [4] = 6,
  [5] = 6,
  [6] = 6
}
local arrest_reward_desc_jia = {
  [1] = "ui_chuangguanjiangli1",
  [2] = "ui_chuangguanjiangli2",
  [3] = "ui_chuangguanjiangli3",
  [4] = "ui_chuangguanjiangli4",
  [5] = "ui_chuangguanjiangli5",
  [6] = "ui_chuangguanjiangli6"
}
local arrest_reward_desc = {
  [1] = "ui_chuangguanjiangli1_1",
  [2] = "ui_chuangguanjiangli2_1",
  [3] = "ui_chuangguanjiangli3_1",
  [4] = "ui_chuangguanjiangli4_1",
  [5] = "ui_chuangguanjiangli5_1",
  [6] = "ui_chuangguanjiangli6_1"
}
local guan_level_text = {
  [1] = "ui_dengji1",
  [2] = "ui_dengji2",
  [3] = "ui_dengji3",
  [4] = "ui_dengji4",
  [5] = "ui_dengji5",
  [6] = "ui_dengji6"
}
local arrest_level_image = {
  [1] = "gui\\language\\ChineseS\\tiguan\\level_1.png",
  [2] = "gui\\language\\ChineseS\\tiguan\\level_2.png",
  [3] = "gui\\language\\ChineseS\\tiguan\\level_3.png",
  [4] = "gui\\language\\ChineseS\\tiguan\\level_4.png"
}
local arrest_boss_desc = {
  [1] = "ui_dantongji_1",
  [2] = "ui_dantongji_2",
  [3] = "ui_dantongji_3",
  [4] = "ui_dantongji_4",
  [5] = "ui_dantongji_5",
  [6] = "ui_dantongji_6"
}
local arrest_boss_double_desc = {
  [1] = "ui_dantongji_1_1",
  [2] = "ui_dantongji_2_1",
  [3] = "ui_dantongji_3_1",
  [4] = "ui_dantongji_4_1",
  [5] = "ui_dantongji_5_1",
  [6] = "ui_dantongji_6_1"
}
local arrest_keep_desc = {
  [1] = "ui_dangcilevel_1",
  [2] = "ui_dangcilevel_2",
  [3] = "ui_dangcilevel_3",
  [4] = "ui_dangcilevel_4",
  [5] = "ui_dangcilevel_5",
  [6] = "ui_dangcilevel_6"
}
local arrest_time_back_color = {
  [1] = "255,0,0,0",
  [2] = "255,128,64,100",
  [3] = "255,0,128,64",
  [4] = "255,255,0,0",
  [5] = "255,250,250,250",
  [6] = "255,250,0,250"
}
local arrest_time_tips_info = {
  [1] = "ui_tiguan_time_info2",
  [2] = "ui_tiguan_time_info3",
  [3] = "ui_tiguan_time_info4",
  [4] = "ui_tiguan_time_info5",
  [5] = "ui_tiguan_time_info5",
  [6] = "ui_tiguan_time_info5"
}
local guan_danci_name = {
  [1] = "ui_dengji1",
  [2] = "ui_dengji2",
  [3] = "ui_dengji3",
  [4] = "ui_dengji4",
  [5] = "ui_dengji5",
  [6] = "ui_dengji6"
}
local rank_col_list = {
  [1] = "ui_tiguan_one_rank_1",
  [2] = "ui_tiguan_one_rank_2",
  [3] = "ui_tiguan_one_rank_3",
  [4] = "ui_tiguan_one_rank_4",
  [5] = "ui_tiguan_one_rank_5",
  [6] = "ui_tiguan_one_rank_6",
  [7] = "ui_tiguan_one_rank_7",
  [8] = "ui_tiguan_one_rank_8",
  [9] = "ui_tiguan_one_rank_9",
  [10] = "ui_tiguan_one_rank_10"
}
local rank_apply_text_id_1 = "ui_rank_canjiaanniu1"
local rank_apply_text_id_2 = "ui_rank_canjiaanniu2"
local time_text_id = {
  [1] = "ui_tiaozhanjishijieguo1",
  [2] = "ui_tiaozhanjishijieguo2"
}
local achieve_data = {
  [1] = {
    [1] = 0,
    [2] = 0
  },
  [2] = {
    [1] = 0,
    [2] = 0
  },
  [3] = {
    [1] = 0,
    [2] = 0
  }
}
function on_main_form_init(form)
  form.Fixed = false
  form.guan_ui_ini = nx_null()
  form.guan_npc_ini = nx_null()
  form.cur_tiguan_level = 1
  form.cur_tiguan_count = 0
  form.cur_time = 0
  form.cur_level_limit = 0
  form.all_kill_guan_id = 0
  form.free_appoint = 0
  form.boss_count_all = 0
  form.turn_out = false
  form.reset_times = 0
  form.is_in_double = 0
  form.day_defeat = 0
  form.award_time = 0
  form.award_max_time = 15
  form.can_apply = 0
  form.friend_card_count = 0
  form.easy_type = 0
  form.cur_achieve_level = 1
  form.bSendAchievement = false
  form.cur_exchange_category = 1
  form.flick_item_count = 0
  form.rank_rows = 0
  form.rank_capture_row = -1
  form.rank_capture_col = -1
  form.rank_select_guanid = -1
  form.rank_sort_col = -1
  form.bSendRankQuest = false
  form.rank_apply_guanid = 0
  form.rank_repeat_time = 0
end
function on_main_form_open(form)
  set_rbtn_type(form)
  form.rbtn_level_1.bNotice = true
  form.lbl_flicker.Visible = false
  form.btn_start.Enabled = false
  form.btn_allkill.Enabled = false
  form.btn_rank_get.Enabled = false
  form.lbl_double_image.Visible = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  form.player_name = client_player:QueryProp("Name")
  form.guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(form.guan_ui_ini) then
    return 0
  end
  form.guan_achieve_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ACHIEVE_INI)
  if not nx_is_valid(form.guan_achieve_ini) then
    return 0
  end
  form.guan_exchange_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_EXCHANGE_INI)
  if not nx_is_valid(form.guan_exchange_ini) then
    return 0
  end
  init_arrest_achieve_one(form)
  init_rank_info(form)
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_FORM_INIT)
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_RANK_INFO)
  local flick = get_flick_item_index()
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_EXCHANGE_QUERY, flick)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.rbtn_1.Checked = true
  form.rbtn_achieve_1.Checked = true
  form.rbtn_level_1.Checked = true
  form.rbtn_skill_1.Checked = true
  refresh_time_info()
  refresh_attack_boss_times()
  refresh_challenge_info()
  refresh_exchange_tree(form)
  default_set(form)
end
function default_set(form)
  form.rbtn_level_5.Visible = false
end
function set_rbtn_type(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.rbtn_1.tiguan_type = 1
  form.rbtn_2.tiguan_type = 2
  form.rbtn_3.tiguan_type = 3
  form.rbtn_4.tiguan_type = 4
  form.rbtn_5.tiguan_type = 5
  for i = 1, tiguan_level_max do
    local rbtn_level = form.groupbox_1:Find("rbtn_level_" .. nx_string(i))
    if rbtn_level ~= nil then
      rbtn_level.tiguan_level = i
      rbtn_level.bNotice = false
    end
  end
  for i = 1, tiguan_arrest_max do
    local gbox = form.groupbox_2:Find("groupbox_arrestboss" .. nx_string(i))
    if gbox ~= nil then
      gbox.guan_id = 0
      gbox.guan_index = i - 1
      local btn_reset = gbox:Find("btn_reset" .. nx_string(i))
      if btn_reset ~= nil then
        btn_reset.Visible = false
      end
      local btn_choice = gbox:Find("btn_choice" .. nx_string(i))
      if btn_choice ~= nil then
        btn_choice.Visible = false
      end
    end
  end
  for i = 1, achieve_level_max do
    local rbtn_achieve = form.groupbox_3:Find("rbtn_achieve_" .. nx_string(i))
    if rbtn_achieve ~= nil then
      rbtn_achieve.achieve_level = i
    end
  end
  for i = 1, exchange_type_max do
    local rbtn_exchange_type = form.groupbox_exchange:Find("rbtn_exchange_type_" .. nx_string(i))
    if rbtn_exchange_type ~= nil then
      rbtn_exchange_type.exchange_category = i
    end
  end
  form.btn_rank_1.sort_id = rank_col_rule_level
  form.btn_rank_1.default_sort_id = rank_col_rule_sort
  form.btn_rank_1.click_times = 0
  form.btn_rank_1.colour_col = 1
  form.btn_rank_1.bGreater = false
  form.btn_rank_2.sort_id = rank_col_rule_award
  form.btn_rank_2.default_sort_id = rank_col_rule_sort
  form.btn_rank_2.click_times = 0
  form.btn_rank_2.colour_col = rank_col_award_1
  form.btn_rank_2.bGreater = true
  form.btn_rank_3.sort_id = rank_col_rule_last
  form.btn_rank_3.default_sort_id = rank_col_rule_sort
  form.btn_rank_3.click_times = 0
  form.btn_rank_3.colour_col = rank_col_next_week
  form.btn_rank_3.bGreater = true
  form.rbtn_skill_1.skill_type = 1
  form.rbtn_skill_2.skill_type = 2
end
function init_arrest_achieve_one(form)
  local tiguan_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(tiguan_ini) then
    return 0
  end
  local guan_ui_ini = form.guan_ui_ini
  if not nx_is_valid(guan_ui_ini) then
    return 0
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  for i = 1, tiguan_level_max do
    local array_name = "tiguan_arrest" .. nx_string(i)
    local is_exist = common_array:FindArray(array_name)
    if not is_exist then
      common_array:AddArray(array_name, nx_current(), common_array_time, false)
    end
    for j = 1, tiguan_arrest_max do
      local child_name = "arrest_data" .. nx_string(j)
      common_array:RemoveChild(array_name, child_name)
      common_array:AddChild(array_name, child_name, "")
    end
  end
  for i = 1, tiguan_level_max do
    for j = 1, tiguan_challenge_task_max do
      local array_name = "guan" .. nx_string(i) .. "sub" .. nx_string(j)
      local is_exist = common_array:FindArray(array_name)
      if not is_exist then
        common_array:AddArray(array_name, nx_current(), common_array_time, false)
      end
      common_array:RemoveChild(array_name, "value1")
      common_array:AddChild(array_name, "value1", 0)
      common_array:RemoveChild(array_name, "value7")
      common_array:AddChild(array_name, "value7", 0)
    end
  end
  local section_count = tiguan_ini:GetSectionCount()
  for i = 1, section_count do
    local Section = tiguan_ini:GetSectionByIndex(i - 1)
    local Level = tiguan_ini:ReadInteger(i - 1, "Level", 0)
    local OpenPublic = tiguan_ini:ReadInteger(i - 1, "OpenPublic", 0)
    local SectionIndex = guan_ui_ini:FindSectionIndex(nx_string(Section))
    local GuanName = get_desc_by_id(guan_ui_ini:ReadString(SectionIndex, "Name", ""))
    local guan_id = nx_string(Section)
    local array_name = "tiguan" .. nx_string(Section)
    local is_exist = common_array:FindArray(array_name)
    if not is_exist then
      common_array:AddArray(array_name, nx_current(), common_array_time, false)
    end
    common_array:RemoveChild(array_name, "guan_name")
    common_array:AddChild(array_name, "guan_name", nx_widestr(GuanName))
    common_array:RemoveChild(array_name, "guan_level")
    common_array:AddChild(array_name, "guan_level", nx_number(Level))
    common_array:RemoveChild(array_name, "first_player_name")
    common_array:AddChild(array_name, "first_player_name", nx_widestr(""))
    common_array:RemoveChild(array_name, "first_time")
    common_array:AddChild(array_name, "first_time", nx_double(0))
    common_array:RemoveChild(array_name, "guan_open")
    common_array:AddChild(array_name, "guan_open", nx_number(OpenPublic))
    common_array:RemoveChild(array_name, "guan_appraise")
    common_array:AddChild(array_name, "guan_appraise", 0)
    common_array:RemoveChild(array_name, "boss_value")
    common_array:AddChild(array_name, "boss_value", 0)
    common_array:RemoveChild(array_name, "boss_appraise")
    common_array:AddChild(array_name, "boss_appraise", 0)
  end
end
function on_main_form_close(form)
  clear_tiguan_record()
  on_close_exchange_form()
  on_close_select_boss_form()
  on_close_select_friend_form()
  nx_destroy(form)
end
function on_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_tiguan_one(type, ...)
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if not form.Visible then
    return 0
  end
  if nx_number(type) == SERVER_MSG_DS_INIT_FORM then
    if table.getn(arg) < 11 then
      return 0
    end
    for i = 1, tiguan_level_max do
      reset_arrest_info(i)
      local rbtn_level = form.groupbox_1:Find("rbtn_level_" .. nx_string(i))
      if rbtn_level ~= nil then
        rbtn_level.bNotice = false
      end
    end
    form.cur_level_limit = nx_number(arg[1])
    form.cur_time = nx_number(arg[2])
    form.lbl_score.Text = nx_widestr(arg[3])
    form.day_defeat = nx_widestr(arg[4])
    form.reset_times = nx_number(arg[5])
    form.free_appoint = nx_number(arg[6])
    form.award_time = nx_number(arg[7])
    if 0 < nx_number(arg[8]) then
      form.btn_double_model.Enabled = true
    else
      form.btn_double_model.Enabled = false
    end
    form.is_in_double = nx_number(arg[9])
    form.rank_apply_guanid = nx_number(arg[10])
    form.award_max_time = nx_number(arg[11])
    form.friend_card_count = nx_number(arg[12])
    if nx_widestr(arg[13]) ~= nx_widestr("") then
      form.btn_invite_friend.Text = nx_widestr(arg[13])
    end
    form.easy_type = nx_number(arg[14])
    if nx_number(arg[14]) == 0 then
      form.btn_easy.Enabled = true
    end
    refresh_time_info()
    refresh_arrest_desc(form)
    refresh_day_defeat(form.day_defeat)
    refresh_attack_boss_times()
    refresh_challenge_info()
    refresh_rank_flicker(form)
    refresh_exchange_flicker(form)
  elseif nx_number(type) == SERVER_MSG_DS_ARREST_INFO then
    if table.getn(arg) < 1 then
      return 0
    end
    local guan_level = nx_number(arg[1])
    if guan_level > tiguan_level_max then
      return 0
    end
    local info_count = (table.getn(arg) - 1) / 2
    challenge_limit[guan_level] = nx_number(info_count)
    for i = 1, info_count do
      local array_name = "tiguan_arrest" .. nx_string(guan_level)
      local child_name = "arrest_data" .. nx_string(i)
      local value = nx_string(arg[2 + (i - 1) * 2]) .. "," .. nx_string(arg[3 + (i - 1) * 2])
      set_tiguan_record(array_name, child_name, value)
    end
    refresh_arrest_info()
  elseif nx_number(type) == SERVER_MSG_DS_TODAY_INFO then
    if table.getn(arg) < 2 then
      return 0
    end
    local guan_level = nx_number(arg[1])
    if guan_level > tiguan_level_max or guan_level < 1 then
      return 0
    end
    reset_arrest_info(guan_level)
    local group_count = 7
    local info_count = (table.getn(arg) - 1) / group_count
    local index = 0
    for i = 1, info_count do
      local array_name = "guan" .. nx_string(guan_level) .. "sub" .. nx_string(i)
      set_tiguan_record(array_name, "value1", nx_string(arg[2 + index * group_count]))
      set_tiguan_record(array_name, "value2", nx_string(arg[3 + index * group_count]))
      set_tiguan_record(array_name, "value3", nx_string(arg[4 + index * group_count]))
      set_tiguan_record(array_name, "value4", 0)
      set_tiguan_record(array_name, "value5", 0)
      set_tiguan_record(array_name, "value6", nx_number(arg[5 + index * group_count]))
      set_tiguan_record(array_name, "value7", 2)
      set_tiguan_record(array_name, "value8", nx_number(arg[6 + index * group_count]))
      set_tiguan_record(array_name, "value9", nx_number(arg[7 + index * group_count]))
      set_tiguan_record(array_name, "value10", nx_number(arg[8 + index * group_count]))
      index = index + 1
    end
    refresh_challenge_info()
    refresh_arrest_info()
  elseif nx_number(type) == SERVER_MSG_DS_RANDOM_INFO then
    if table.getn(arg) < 2 then
      return 0
    end
    local guan_level = nx_number(arg[1])
    if guan_level > tiguan_level_max or guan_level < 1 then
      return 0
    end
    for i = 1, tiguan_challenge_task_max do
      local array_name = "guan" .. nx_string(guan_level) .. "sub" .. nx_string(i)
      local is_complete = nx_number(get_tiguan_record(array_name, "value7"))
      if is_complete == 1 or is_complete == 0 then
        local array_name = "guan" .. nx_string(guan_level) .. "sub" .. nx_string(i)
        set_tiguan_record(array_name, "value1", nx_string(arg[2]))
        set_tiguan_record(array_name, "value2", nx_string(arg[3]))
        set_tiguan_record(array_name, "value3", nx_string(arg[4]))
        set_tiguan_record(array_name, "value4", nx_string(arg[5]))
        set_tiguan_record(array_name, "value5", 1)
        set_tiguan_record(array_name, "value6", 0)
        set_tiguan_record(array_name, "value7", 1)
        set_tiguan_record(array_name, "value8", 0)
        set_tiguan_record(array_name, "value9", 0)
        set_tiguan_record(array_name, "value10", 0)
        break
      end
    end
    refresh_challenge_info()
  elseif nx_number(type) == ERVER_MSG_DS_APPOINT_BOSS then
    if table.getn(arg) < 3 then
      return 0
    end
    local guan_id = nx_string(arg[1])
    local boss_index = nx_string(arg[2])
    form.free_appoint = nx_number(arg[3])
    for i = 1, tiguan_level_max do
      for j = 1, tiguan_challenge_task_max do
        local array_name = "guan" .. nx_string(i) .. "sub" .. nx_string(j)
        local is_complete = nx_number(get_tiguan_record(array_name, "value7"))
        local record_guan_id = nx_number(get_tiguan_record(array_name, "value1"))
        if is_complete == 1 and record_guan_id == nx_number(guan_id) then
          local array_name = "guan" .. nx_string(i) .. "sub" .. nx_string(j)
          set_tiguan_record(array_name, "value2", nx_string(boss_index))
          set_tiguan_record(array_name, "value5", 1)
        end
      end
    end
    refresh_challenge_info()
  elseif nx_number(type) == SERVER_MSG_DS_BOSS_NOTE then
    if table.getn(arg) < 3 then
      return 0
    end
    local rows = 3
    local info_count = table.getn(arg) / rows
    for i = 1, info_count do
      local tiguan_id = nx_string(arg[1 + (i - 1) * rows])
      local boss_value = nx_number(arg[2 + (i - 1) * rows])
      local boss_appraise = nx_number(arg[3 + (i - 1) * rows])
      set_achieve_record(tiguan_id, "boss_value", boss_value)
      set_achieve_record(tiguan_id, "boss_appraise", boss_appraise)
    end
    form.boss_count_all = CalculateLevelGuanBossCount(form.cur_tiguan_level)
    refresh_attack_boss_times()
    refresh_arrest_info()
  elseif nx_number(type) == SERVER_MSG_DS_DIS_CONDITION then
    if table.getn(arg) < 2 then
      return 0
    end
    local guan_level = nx_number(arg[1])
    if guan_level <= 0 or guan_level > tiguan_level_max then
      return 0
    end
    local condition_count = table.getn(arg) - 1
    local condition_text = nx_string(arg[2])
    for i = 2, condition_count do
      condition_text = condition_text .. "," .. nx_string(arg[i + 1])
    end
    arrest_condition[guan_level] = condition_text
    refresh_challenge_info()
  elseif nx_number(type) == SERVER_MSG_DS_ALTER_ALLY then
    if table.getn(arg) < 1 then
      return 0
    end
    form.btn_invite_friend.Text = nx_widestr(arg[1])
  elseif nx_number(type) == SERVER_MSG_DS_ACHIEVE_INFO then
    local achieve_count = nx_number(table.getn(arg) / 2)
    if achieve_data == nil then
      return 0
    end
    for i = 1, achieve_count do
      achieve_data[i][1] = nx_number(arg[(i - 1) * 2 + 1])
      achieve_data[i][2] = nx_number(arg[i * 2])
    end
    show_achieve_info(form)
  elseif nx_number(type) == SERVER_MSG_DS_LEAD_ACHIEVE then
    if table.getn(arg) < 1 then
      return 0
    end
    local tiguan_manager = nx_value("tiguan_manager")
    if not nx_is_valid(tiguan_manager) then
      return 0
    end
    if achieve_data == nil then
      return 0
    end
    local achieve_index = nx_number(arg[1])
    local rows = nx_number(nx_int(achieve_index / 32)) + 1
    local cols = achieve_index % 32
    if 3 < rows or rows <= 0 then
      return 0
    end
    local num = tiguan_manager:CheckBitFlag(nx_number(achieve_data[rows][2]), cols)
    if nx_number(num) == 0 then
      achieve_data[rows][2] = tiguan_manager:SetBitFlag(nx_number(achieve_data[rows][2]), cols)
    end
    show_achieve_info(form)
  elseif nx_number(type) == SERVER_MSG_DS_FIRST_DEFEAT_INFO then
    if table.getn(arg) < 2 then
      return 0
    end
    local rows = 3
    local count = (table.getn(arg) - 1) / rows
    for i = 0, count - 1 do
      local guan_id = nx_string(arg[2 + i * rows])
      set_achieve_record(guan_id, "first_player_name", nx_widestr(arg[3 + i * rows]))
      set_achieve_record(guan_id, "first_time", nx_double(arg[4 + i * rows]))
    end
    show_achieve_info(form)
  elseif nx_number(type) == SERVER_MSG_DS_EXCHANGE_SUC then
    if table.getn(arg) < 1 then
      return 0
    end
    form.lbl_score.Text = nx_widestr(arg[1])
  elseif nx_number(type) == SERVER_MSG_DS_EXCHANGE_NUM then
    if table.getn(arg) < 2 then
      return 0
    end
    form.flick_item_count = nx_number(arg[2])
    refresh_exchange_tree(form)
    refresh_exchange_flicker(form)
  elseif nx_number(type) == SERVER_MSG_DS_RANK_INFO then
    local count = table.getn(arg)
    if count < 6 then
      return 0
    end
    refresh_rank_info(arg)
    refresh_rank_flicker(form)
  elseif nx_number(type) == SERVER_MSG_DS_LEVEL_APPRAISE then
    local count = table.getn(arg)
    if count < 3 then
      return 0
    end
    local rows = 2
    local count = (table.getn(arg) - 1) / 2
    for i = 0, count - 1 do
      local guan_id = nx_string(arg[2 + i * rows])
      set_achieve_record(guan_id, "guan_appraise", nx_number(arg[3 + i * rows]))
    end
  elseif nx_number(type) == SERVER_MSG_DS_REGIST_RANK then
    if table.getn(arg) < 1 then
      return 0
    end
    form.rank_apply_guanid = nx_number(arg[1])
    refresh_rank_apply(form)
    refresh_rank_flicker(form)
  elseif nx_number(type) == SERVER_MSG_DS_REGIST_NUM then
    if table.getn(arg) < 2 then
      return 0
    end
    refresh_rank_apply_persion_count(form, arg)
  elseif nx_number(type) == SERVER_MSG_DS_REMAIN_INVITE then
    if table.getn(arg) < 1 then
      return 0
    end
    form.friend_card_count = nx_number(arg[1])
    refresh_attack_boss_times()
  elseif nx_number(type) == SERVER_MSG_DS_SWITCH_EXCHANGE then
    form.rbtn_3.Checked = true
    auto_select_tanlanquan(form.tree_exchange)
  elseif nx_number(type) == SERVER_MSG_DS_CLOSE_FORM then
    form:Close()
  end
end
function on_rbtn_checked_changed(btn)
  if not btn.Checked then
    return 0
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  on_close_exchange_form()
  on_close_select_boss_form()
  on_close_select_friend_form()
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = false
  form.groupbox_3.Visible = false
  form.groupscrollbox_1.Visible = false
  form.groupscrollbox_2.Visible = false
  form.groupscrollbox_3.Visible = false
  form.groupbox_rank.Visible = false
  form.groupbox_exchange.Visible = false
  form.lbl_reward_backimage.Visible = false
  form.lbl_reward_scrback.Visible = false
  form.lbl_exchange_backimage.Visible = false
  form.lbl_exchange_scrback.Visible = false
  form.lbl_exchange_back.Visible = false
  form.mltbox_remainder.Visible = false
  form.lbl_bian.Visible = false
  form.groupbox_skill.Visible = false
  form.groupbox_friend.Visible = false
  if btn.tiguan_type == 1 then
    form.groupbox_1.Visible = true
    form.groupbox_2.Visible = true
    form.mltbox_remainder.Visible = true
    form.groupbox_friend.Visible = true
    set_guan_level_limit(form, tiguan_level_max)
  elseif btn.tiguan_type == 2 then
    form.groupbox_3.Visible = true
    form.groupscrollbox_1.Visible = true
    form.lbl_reward_backimage.Visible = true
    form.lbl_reward_scrback.Visible = true
    if not form.bSendAchievement then
      form.bSendAchievement = true
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_ACHIEVE_INFO)
      for i = 1, tiguan_level_max do
        nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_FIRST_DEFEAT_INFO, nx_number(i))
        nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_LEVEL_APPRAISE, nx_number(i))
        nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_BOSS_NOTE, nx_number(i))
      end
    end
  elseif btn.tiguan_type == 3 then
    form.groupscrollbox_2.Visible = true
    form.lbl_exchange_backimage.Visible = true
    form.lbl_exchange_scrback.Visible = true
    form.lbl_score_text.Visible = true
    form.groupbox_exchange.Visible = true
    form.lbl_exchange_back.Visible = true
    form.lbl_bian.Visible = true
  elseif btn.tiguan_type == 4 then
    form.groupbox_rank.Visible = true
    if not form.bSendRankQuest then
      form.bSendRankQuest = true
    end
  else
    form.groupbox_skill.Visible = true
    if not form.rbtn_skill_2.Checked then
      form.rbtn_skill_1 = true
    else
      refresh_skill_info(form)
    end
  end
end
function set_guan_level_limit(form, level_max)
  for i = 1, tiguan_level_max do
    local rbtn_level = form.groupbox_1:Find("rbtn_level_" .. nx_string(i))
    if rbtn_level ~= nil then
      if rbtn_level.tiguan_level <= nx_number(level_max) then
        rbtn_level.Enabled = true
      else
        rbtn_level.Enabled = false
      end
    end
  end
end
function on_rbtn_level_checked_changed(btn)
  if not btn.Checked then
    return 0
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  on_close_select_boss_form()
  on_close_select_friend_form()
  form.cur_tiguan_level = btn.tiguan_level
  if not btn.bNotice then
    btn.bNotice = true
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_LEVEL_INFO, nx_number(btn.tiguan_level))
  end
  form.boss_count_all = CalculateLevelGuanBossCount(form.cur_tiguan_level)
  refresh_attack_boss_times()
  refresh_arrest_info()
  refresh_challenge_info()
  refresh_arrest_desc(form)
end
function refresh_attack_boss_times()
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  gui.TextManager:Format_SetIDName("ui_jibai")
  gui.TextManager:Format_AddParam(nx_string(guan_level_text[nx_number(form.cur_tiguan_level)]))
  gui.TextManager:Format_AddParam(nx_int(form.boss_count_all))
  form.mltbox_attacktimes:Clear()
  form.mltbox_attacktimes:AddHtmlText(gui.TextManager:Format_GetText(), -1)
  gui.TextManager:Format_SetIDName("ui_mengyou_times")
  gui.TextManager:Format_AddParam(nx_int(form.friend_card_count))
  form.mltbox_friend_card:Clear()
  form.mltbox_friend_card:AddHtmlText(gui.TextManager:Format_GetText(), -1)
  local auto_invite = get_danshua_auto_invite()
  if auto_invite == 0 then
    form.cbtn_invite.Checked = false
    form.cbtn_invite_2.Checked = false
  else
    form.cbtn_invite.Checked = true
    form.cbtn_invite_2.Checked = true
  end
end
function refresh_day_defeat(defeat_times)
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local defeat_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(defeat_ini) then
    return 0
  end
  local defeat_index = -1
  if form.easy_type == 0 then
    defeat_index = defeat_ini:FindSectionIndex("day_defeat")
  else
    defeat_index = defeat_ini:FindSectionIndex("day_defeat_practice")
  end
  if defeat_index < 0 then
    return 0
  end
  local defeat_tab = defeat_ini:GetItemValueList(defeat_index, "r")
  local defeat_count = table.getn(defeat_tab)
  for i = 1, defeat_count do
    local defeat_info = util_split_string(nx_string(defeat_tab[i]), ",")
    if table.getn(defeat_info) >= 3 then
      local min_times = nx_number(defeat_info[1])
      local max_times = nx_number(defeat_info[2])
      if min_times <= nx_number(defeat_times) and max_times >= nx_number(defeat_times) then
        local text_desc = gui.TextManager:GetText(nx_string(defeat_info[3]))
        form.mltbox_day_defeat:Clear()
        form.mltbox_day_defeat:AddHtmlText(text_desc, -1)
      end
    end
  end
  gui.TextManager:Format_SetIDName("ui_danshua_defeat_times")
  gui.TextManager:Format_AddParam(nx_int(defeat_times))
  defeat_times_text = gui.TextManager:Format_GetText()
  form.mltbox_defeat_times:Clear()
  form.mltbox_defeat_times:AddHtmlText(defeat_times_text, -1)
end
function refresh_time_info()
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local nTime = form.cur_time
  if 0 > nx_number(nTime) then
    nTime = 0
  end
  local time_hours = nx_int(nTime / 3600)
  local time_min = nx_int((nTime - time_hours * 3600) / 60)
  local time_sec = nx_int(nTime - time_hours * 3600 - time_min * 60)
  local time_text = nx_widestr("")
  gui.TextManager:Format_SetIDName("ui_danshengyu")
  gui.TextManager:Format_AddParam(nx_int(time_hours))
  gui.TextManager:Format_AddParam(nx_int(time_min))
  gui.TextManager:Format_AddParam(nx_int(time_sec))
  time_text = gui.TextManager:Format_GetText()
  form.mltbox_remainder:Clear()
  form.mltbox_remainder:AddHtmlText(time_text, -1)
  form.pbar_time.Maximum = nx_number(form.award_max_time / 60)
  form.pbar_time.Value = nx_int(form.award_time / 60)
  if form.cur_level_limit < table.getn(arrest_time_back_color) then
    form.pbar_time.BackColor = arrest_time_back_color[form.cur_level_limit]
  end
  form.lbl_time_text.Text = nx_widestr(form.pbar_time.Value) .. nx_widestr("/") .. nx_widestr(form.pbar_time.Maximum)
end
function refresh_arrest_desc(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local level = nx_number(form.cur_tiguan_level)
  if level < 1 or level > tiguan_level_max then
    return 0
  end
  if form.is_in_double ~= 0 then
    local html_text = gui.TextManager:GetText(arrest_boss_double_desc[nx_number(level)])
    form.mltbox_shuoming:Clear()
    form.mltbox_shuoming:AddHtmlText(html_text, -1)
    form.lbl_double_image.Visible = true
  else
    local html_text = gui.TextManager:GetText(arrest_boss_desc[nx_number(level)])
    form.mltbox_shuoming:Clear()
    form.mltbox_shuoming:AddHtmlText(html_text, -1)
    form.lbl_double_image.Visible = false
  end
end
function refresh_arrest_info()
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local ui_ini = form.guan_ui_ini
  if not nx_is_valid(ui_ini) then
    return 0
  end
  clear_arrest_info(form)
  local level = nx_number(form.cur_tiguan_level)
  if level < 1 or level > tiguan_level_max then
    return 0
  end
  form.mltbox_arrest1:Clear()
  form.mltbox_arrest2:Clear()
  for i = 1, tiguan_arrest_max do
    local html_text = nx_widestr("")
    local guan_name = nx_widestr("")
    local guan_id = nx_string(get_arrest_data(level, i, 1))
    local boss_id = nx_string(get_arrest_data(level, i, 2))
    if guan_id ~= "" and boss_id ~= "" then
      local index = ui_ini:FindSectionIndex(guan_id)
      if 0 <= index then
        guan_name = get_desc_by_id(ui_ini:ReadString(index, "Name", ""))
      end
      local boss_name = gui.TextManager:GetText(boss_id)
      local nBeComplete = 0
      for j = 1, tiguan_challenge_task_max do
        local array_name = "guan" .. nx_string(level) .. "sub" .. nx_string(j)
        local record_guan_id = nx_number(get_tiguan_record(array_name, "value1"))
        local record_boss_index = nx_number(get_tiguan_record(array_name, "value2"))
        local is_complete = nx_number(get_tiguan_record(array_name, "value7"))
        if is_complete == TG_CHALLENGE_TASK_TYPE_2 and record_guan_id == nx_number(guan_id) then
          local boss_id_temp = get_boss_id(record_guan_id, record_boss_index)
          if boss_id_temp == boss_id then
            nBeComplete = 1
            break
          end
        end
      end
      if nBeComplete == 1 then
        html_text = html_text .. nx_widestr("<font color=\"#6c5644\">") .. guan_name .. gui.TextManager:GetText("ui_tiaozhan_5") .. nx_widestr("</font>") .. nx_widestr("<font color=\"#8c2e0e\">") .. boss_name .. nx_widestr("</font>")
      else
        html_text = html_text .. guan_name .. gui.TextManager:GetText("ui_tiaozhan_5") .. boss_name
      end
      local boss_level_count = get_boss_arrest_level_by_id(guan_id, boss_id)
      for i = 1, boss_level_count do
        html_text = html_text .. nx_widestr("<img src=\"knife" .. "\" only=\"line\" valign=\"center\"/>")
      end
      if i <= 4 then
        form.mltbox_arrest1:AddHtmlText(html_text, -1)
      else
        form.mltbox_arrest2:AddHtmlText(html_text, -1)
      end
    end
  end
end
function refresh_challenge_condition(form, level)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local tiguan_one_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(tiguan_one_ini) then
    return 0
  end
  if nx_number(level) <= form.cur_level_limit then
    form.groupbox_keep_all.Visible = false
  else
    form.groupbox_keep_all.Visible = true
    form.mltbox_1:Clear()
    local keep_index = tiguan_one_ini:FindSectionIndex("arrest_condition")
    local item_name = "condition" .. nx_string(level)
    local condition_str = tiguan_one_ini:ReadString(keep_index, item_name, "")
    local sort_index = tiguan_one_ini:FindSectionIndex("condition_sort")
    local sort_str = tiguan_one_ini:ReadString(sort_index, item_name, "")
    if condition_str ~= "" then
      local condition_tab = util_split_string(condition_str, ",")
      local condition_count = table.getn(condition_tab)
      if condition_count <= 0 then
        return 0
      end
      local sort_tab = util_split_string(sort_str, ",")
      local sort_count = table.getn(sort_tab)
      if sort_count <= 0 then
        return 0
      end
      local server_condition_tab = util_split_string(arrest_condition[level], ",")
      local server_condition_count = table.getn(server_condition_tab)
      for i = 1, condition_count do
        local html_text = gui.TextManager:GetText(condition_tab[i])
        for j = 1, server_condition_count do
          local share_id = nx_number(server_condition_tab[j])
          if sort_count >= share_id and nx_number(sort_tab[share_id]) == i then
            html_text = nx_widestr("<font color=\"#eb7272\">") .. html_text .. nx_widestr("</font>")
            break
          end
        end
        form.mltbox_1:AddHtmlText(html_text, -1)
      end
    end
  end
end
function refresh_challenge_info()
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local ui_ini = form.guan_ui_ini
  if not nx_is_valid(ui_ini) then
    return 0
  end
  local append_cdt_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_APPEND_CDT_INI)
  if not nx_is_valid(append_cdt_ini) then
    return 0
  end
  clear_challenge_gbox()
  local level = nx_number(form.cur_tiguan_level)
  if level < 1 or level > tiguan_level_max then
    return 0
  end
  gui.TextManager:Format_SetIDName("ui_oneweekand")
  gui.TextManager:Format_AddParam(nx_int(form.reset_times))
  form.btn_reset_start.Text = gui.TextManager:Format_GetText()
  if 0 < form.reset_times and nx_number(level) <= form.cur_level_limit then
    form.btn_reset_start.Enabled = true
  else
    form.btn_reset_start.Enabled = false
  end
  refresh_challenge_condition(form, level)
  local append_index = append_cdt_ini:FindSectionIndex("1")
  if append_index < 0 then
    return 0
  end
  local append_tab = append_cdt_ini:GetItemValueList(append_index, "r")
  form.cur_tiguan_count = 0
  local task_count = 0
  for i = 1, tiguan_challenge_task_max do
    local gbox = form.groupbox_2:Find("groupbox_arrestboss" .. nx_string(i))
    if gbox ~= nil then
      local array_name = "guan" .. nx_string(level) .. "sub" .. nx_string(i)
      local record_guan_id = nx_number(get_tiguan_record(array_name, "value1"))
      local record_boss_index = nx_number(get_tiguan_record(array_name, "value2"))
      local record_task_id = nx_number(get_tiguan_record(array_name, "value3"))
      local record_reset_spent = nx_number(get_tiguan_record(array_name, "value4"))
      local record_show = nx_number(get_tiguan_record(array_name, "value5"))
      local record_complete = nx_number(get_tiguan_record(array_name, "value7"))
      local record_appraise = nx_number(get_tiguan_record(array_name, "value8"))
      local record_times = nx_number(get_tiguan_record(array_name, "value10"))
      if record_complete ~= 0 then
        local guan_name_text = nx_widestr("")
        gbox.guan_id = record_guan_id
        task_count = task_count + 1
        local index = ui_ini:FindSectionIndex(nx_string(record_guan_id))
        if 0 <= index then
          guan_name_text = get_desc_by_id(ui_ini:ReadString(index, "Name", ""))
        end
        local boss_name_text = nx_widestr("")
        local boss_id = get_boss_id(nx_string(record_guan_id), nx_number(record_boss_index))
        if record_complete == 2 then
          boss_name_text = gui.TextManager:GetText(boss_id)
        elseif FindBossBeArrest(boss_id, level) then
          boss_name_text = nx_widestr("<font color=\"#ff0000\">") .. gui.TextManager:GetText(boss_id) .. nx_widestr("</font>")
        else
          boss_name_text = gui.TextManager:GetText(boss_id)
        end
        local mltbox_arrestboos = gbox:Find("mltbox_arrestboos" .. nx_string(i))
        if mltbox_arrestboos ~= nil then
          mltbox_arrestboos:Clear()
          mltbox_arrestboos:AddHtmlText(guan_name_text, -1)
          local posx = (mltbox_arrestboos.Width - mltbox_arrestboos:GetContentWidth()) / 2
          mltbox_arrestboos.ViewRect = nx_string(nx_int(posx)) .. ",0,220,22"
        end
        local mltbox_boss_name = gbox:Find("mltbox_boss_name" .. nx_string(i))
        if mltbox_boss_name ~= nil then
          mltbox_boss_name:Clear()
          mltbox_boss_name:AddHtmlText(boss_name_text, -1)
        end
        local gbox_quantou = gbox:Find("groupbox_arrest_quantou" .. nx_string(i))
        if gbox_quantou == nil or record_complete == 2 then
        else
          local boss_level = nx_number(get_boss_arrest_level(nx_string(record_guan_id), nx_number(record_boss_index)))
          local mltbox_boss_name = gbox:Find("mltbox_boss_name" .. nx_string(i))
          if mltbox_boss_name ~= nil then
            local quantou_left = mltbox_boss_name.Left + mltbox_boss_name:GetContentWidth() + 2
            gbox_quantou.Left = quantou_left
            for j = 1, boss_level do
              local lbl_arrest_quantou = create_ctrl("Label", "lbl_arrest_quantou_" .. nx_string(i) .. "_" .. nx_string(j), form.lbl_quantou, gbox_quantou)
              lbl_arrest_quantou.Left = 10 + (boss_level - j) * 15
              lbl_arrest_quantou.Top = 0
            end
          end
        end
        local mltbox_score_and_time = gbox:Find("mltbox_score_and_time" .. nx_string(i))
        local lbl_shijian = gbox:Find("lbl_shijian" .. nx_string(i))
        if mltbox_score_and_time ~= nil and lbl_shijian ~= nil then
          if record_complete == 2 then
            local time_sec = nx_int(record_times)
            local mins = nx_int(time_sec / 60)
            local secs = nx_int(time_sec - mins * 60)
            gui.TextManager:Format_SetIDName(time_text_id[2])
            gui.TextManager:Format_AddParam(nx_int(mins))
            gui.TextManager:Format_AddParam(nx_int(secs))
            local show_time_text = gui.TextManager:Format_GetText()
            mltbox_score_and_time:Clear()
            mltbox_score_and_time:AddHtmlText(show_time_text, -1)
            lbl_shijian.Visible = true
          else
            mltbox_score_and_time:Clear()
          end
        end
        if record_complete == 1 then
          local lbl_arresttask = gbox:Find("lbl_arresttask" .. nx_string(i))
          if lbl_arresttask ~= nil and record_task_id < table.getn(append_tab) then
            local append_info = util_split_string(nx_string(append_tab[nx_int(record_task_id) + 1]), ",")
            if table.getn(append_info) == 5 then
              local task_text_id = "ui_tiguan_random_challenge_" .. nx_string(append_info[1])
              local arg1 = nx_int(append_info[2])
              if nx_number(append_info[1]) == 3 then
                arg1 = nx_int(arg1 / 60)
              end
              lbl_arresttask.Text = gui.TextManager:GetFormatText(task_text_id, arg1)
            end
          end
          form.all_kill_guan_id = nx_number(record_guan_id)
        else
          local level_image_index = record_appraise + 1
          if level_image_index <= TG_APPRAISE_LEVEL_MAX and 0 < level_image_index then
            local lbl_level = gbox:Find("lbl_level" .. nx_string(i))
            if lbl_level ~= nil then
              lbl_level.BackImage = arrest_level_image[level_image_index]
              lbl_level.Visible = true
            end
          end
        end
        local btn_reset = gbox:Find("btn_reset" .. nx_string(i))
        if btn_reset ~= nil then
          if record_complete == 2 then
            btn_reset.Visible = false
          else
            btn_reset.Visible = true
            btn_reset.spent_money = nx_int(record_reset_spent / 1000)
            form.cur_tiguan_count = -1
            form.btn_start.Enabled = true
            form.btn_allkill.Enabled = true
          end
        end
        local btn_choice = gbox:Find("btn_choice" .. nx_string(i))
        if btn_choice ~= nil then
          if record_complete == 2 then
            btn_choice.Visible = false
          else
            btn_choice.Visible = true
          end
        end
        local lbl_keep = gbox:Find("lbl_keep" .. nx_string(i))
        if lbl_keep ~= nil then
          if record_show == 1 then
            if form.turn_out then
              form.turn_out = false
              local timer = nx_value("timer_game")
              if nx_is_valid(timer) then
                lbl_keep.keep_BlendAlpha = 255
                timer:UnRegister(nx_current(), "refresh_turn_info", lbl_keep)
                timer:Register(50, 23, nx_current(), "refresh_turn_info", lbl_keep, -1, -1)
              end
            else
              lbl_keep.Visible = false
            end
          else
            lbl_keep.Visible = false
          end
        end
        local lbl_math = gbox:Find("lbl_math" .. nx_string(i))
        if lbl_math ~= nil then
          lbl_math.Visible = false
        end
        local lbl_easy = gbox:Find("lbl_easy" .. nx_string(i))
        if lbl_easy ~= nil then
          if form.easy_type ~= 0 then
            lbl_easy.Visible = true
          else
            lbl_easy.Visible = false
          end
        end
      else
        local lbl_easy = gbox:Find("lbl_easy" .. nx_string(i))
        if lbl_easy ~= nil then
          if form.easy_type ~= 0 then
            lbl_easy.Visible = true
          else
            lbl_easy.Visible = false
          end
        end
      end
    end
  end
  if form.cur_tiguan_count ~= -1 then
    form.cur_tiguan_count = task_count
  end
  if nx_number(level) > form.cur_level_limit then
    form.btn_start.Enabled = false
    form.btn_allkill.Enabled = false
  end
  refresh_flicker(form)
end
function refresh_flicker(form)
  local level = nx_number(form.cur_tiguan_level)
  if level > tiguan_level_max then
    return 0
  end
  if 0 > form.reset_times then
    return 0
  end
  form.lbl_flicker.Visible = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local cur_guan_id = client_player:QueryProp("CurGuanID")
  for i = 1, tiguan_arrest_max do
    local gbox = form.groupbox_2:Find("groupbox_arrestboss" .. nx_string(i))
    if gbox ~= nil then
      local cbtn_arrestboss = gbox:Find("cbtn_arrestboss" .. nx_string(i))
      if cbtn_arrestboss ~= nil then
        local guan_sort = nx_number(cbtn_arrestboss.Parent.guan_index + 1)
        if nx_int(form.cur_tiguan_count) == nx_int(guan_sort - 1) and level <= nx_number(form.cur_level_limit) and form.cur_tiguan_count < challenge_limit[level] and nx_number(cur_guan_id) == 0 then
          form.lbl_flicker.Visible = true
          form.lbl_flicker.Left = cbtn_arrestboss.Parent.Left - 11
          form.lbl_flicker.Top = cbtn_arrestboss.Parent.Top - 10
        end
      end
    end
  end
end
function clear_arrest_info(form)
  form.groupbox_tongji_quantou1.IsEditMode = true
  form.groupbox_tongji_quantou1:DeleteAll()
  form.groupbox_tongji_quantou1.IsEditMode = false
  form.groupbox_tongji_quantou2.IsEditMode = true
  form.groupbox_tongji_quantou2:DeleteAll()
  form.groupbox_tongji_quantou2.IsEditMode = false
end
function clear_challenge_gbox()
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return 0
  end
  form.btn_start.Enabled = false
  form.btn_allkill.Enabled = false
  form.groupbox_keep_all.Visible = true
  for i = 1, 9 do
    local gbox = form.groupbox_2:Find("groupbox_arrestboss" .. nx_string(i))
    if gbox ~= nil then
      local mltbox_arrestboos = gbox:Find("mltbox_arrestboos" .. nx_string(i))
      if mltbox_arrestboos ~= nil then
        mltbox_arrestboos:Clear()
      end
      local mltbox_boss_name = gbox:Find("mltbox_boss_name" .. nx_string(i))
      if mltbox_boss_name ~= nil then
        mltbox_boss_name:Clear()
      end
      local lbl_arresttask = gbox:Find("lbl_arresttask" .. nx_string(i))
      if lbl_arresttask ~= nil then
        lbl_arresttask.Text = nx_widestr("")
      end
      local btn_reset = gbox:Find("btn_reset" .. nx_string(i))
      if btn_reset ~= nil then
        btn_reset.Visible = false
      end
      local imagegrid_arrest = gbox:Find("imagegrid_arrest" .. nx_string(i))
      if imagegrid_arrest ~= nil then
        imagegrid_arrest.Visible = false
      end
      local gbox_quantou = gbox:Find("groupbox_arrest_quantou" .. nx_string(i))
      if gbox_quantou ~= nil then
        gbox_quantou.IsEditMode = true
        gbox_quantou:DeleteAll()
        gbox_quantou.IsEditMode = false
      end
      local lbl_shijian = gbox:Find("lbl_shijian" .. nx_string(i))
      if lbl_shijian ~= nil then
        lbl_shijian.Visible = false
      end
      local lbl_keep = gbox:Find("lbl_keep" .. nx_string(i))
      if lbl_keep ~= nil then
        lbl_keep.Visible = true
        lbl_keep.BlendColor = "255,255,255,255"
        timer:UnRegister(nx_current(), "refresh_turn_info", lbl_keep)
      end
      local lbl_math = gbox:Find("lbl_math" .. nx_string(i))
      if lbl_math ~= nil then
        lbl_math.Visible = true
      end
      local btn_choice = gbox:Find("btn_choice" .. nx_string(i))
      if btn_choice ~= nil then
        btn_choice.Visible = false
      end
      local lbl_level = gbox:Find("lbl_level" .. nx_string(i))
      if lbl_level ~= nil then
        lbl_level.Visible = false
      end
      gbox.guan_id = 0
    end
  end
end
function set_groupbox_arrestboss_visible(form, visible)
  for i = 1, 9 do
    local gbox = form.groupbox_2:Find("groupbox_arrestboss" .. nx_string(i))
    if gbox ~= nil then
      gbox.Visible = visible
    end
  end
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local auto_invite = get_danshua_auto_invite()
  on_close_select_boss_form()
  on_close_select_friend_form()
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_BEGIN, nx_number(form.cur_tiguan_level), auto_invite)
end
function on_btn_allkill_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  on_close_select_boss_form()
  on_close_select_friend_form()
  local danshua_ini = nx_execute("util_functions", "get_ini", SHARE_TIGUAN_DANSHUA_INI)
  if not nx_is_valid(danshua_ini) then
    return nil
  end
  local spent_money = 0
  local spent_time = 0
  local guan_id = form.all_kill_guan_id
  if guan_id <= 0 then
    return
  end
  local append_index = danshua_ini:FindSectionIndex("DirectFinish")
  if append_index < 0 then
    return 0
  end
  local append_tab = danshua_ini:GetItemValueList(append_index, "r")
  local tab_count = table.getn(append_tab)
  for i = 1, tab_count do
    local append_info = util_split_string(nx_string(append_tab[i]), ",")
    if table.getn(append_info) >= 3 and nx_number(append_info[1]) == guan_id then
      spent_time = nx_number(append_info[2])
      spent_money = nx_number(append_info[3]) / 1000
    end
  end
  local cur_tiguan_level = form.cur_tiguan_level
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = nx_widestr("")
  if 1000 < spent_money then
    gui.TextManager:Format_SetIDName("ui_allskill_23")
    gui.TextManager:Format_AddParam(nx_int(spent_money / 1000))
    gui.TextManager:Format_AddParam(nx_int(spent_money % 1000))
    text = gui.TextManager:Format_GetText()
  else
    gui.TextManager:Format_SetIDName("ui_allskill_2")
    gui.TextManager:Format_AddParam(nx_int(spent_money))
    text = gui.TextManager:Format_GetText()
  end
  local nMins = nx_int(spent_time / 60)
  if 0 < nx_number(nMins) then
    text = text .. nx_widestr(nMins) .. gui.TextManager:GetText("ui_allskill_21")
  end
  local nSecs = nx_int(spent_time % 60)
  if 0 < nx_number(nSecs) then
    text = text .. nx_widestr(nSecs) .. gui.TextManager:GetText("ui_allskill_22")
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_DIRECT_FINISH, nx_number(cur_tiguan_level))
  else
    return
  end
end
function on_btn_reset_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if is_player_in_guan() then
    return 0
  end
  on_close_select_boss_form()
  on_close_select_friend_form()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.lbl_1.Text = gui.TextManager:GetText("ui_oneweek")
  local text = nx_widestr("")
  gui.TextManager:Format_SetIDName("ui_tiguan_benzhouketicishu")
  gui.TextManager:Format_AddParam(nx_int(form.reset_times))
  text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_OFFSET_OMIT)
  else
    return
  end
end
function on_btn_invite_friend_click(btn)
  util_auto_show_hide_form(FORM_TIGUAN_FRIEND)
end
function on_btn_easy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if is_player_in_guan() then
    return 0
  end
  on_close_select_boss_form()
  on_close_select_friend_form()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.lbl_1.Text = gui.TextManager:GetText("ui_easy_exp_1")
  local text = gui.TextManager:GetText("ui_easy_exp_2")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_PRACTICE_MODEL)
  else
    return
  end
end
function on_btn_reset_start_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if 0 >= form.reset_times then
    local x, y = gui:GetCursorPosition()
    local show_text = gui.TextManager:GetText("ui_tiguan_chongzhicishu0")
    nx_execute("tips_game", "show_text_tip", show_text, x, y, 0, form)
  end
end
function on_btn_reset_start_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_double_model_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if is_player_in_guan() then
    return 0
  end
  on_close_select_boss_form()
  on_close_select_friend_form()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = gui.TextManager:GetText("ui_double_explane")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_DOUBLE_MODEL)
    if nx_is_valid(btn) then
      btn.Enabled = false
    end
  end
end
function on_cbtn_invite_2_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.cbtn_invite.Checked = cbtn.Checked
  local val = 0
  if cbtn.Checked then
    val = 1
  end
  nx_set_value("danshua_auto_invite", val)
end
function get_danshua_auto_invite()
  if not nx_find_value("danshua_auto_invite") then
    return 0
  end
  return nx_value("danshua_auto_invite")
end
function on_btn_double_model_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local x, y = gui:GetCursorPosition()
  if not form.btn_double_model.Enabled then
    local show_text = gui.TextManager:GetText("ui_tiguan_double_mode_1")
    nx_execute("tips_game", "show_text_tip", show_text, x, y, 0, form)
  end
end
function on_btn_double_model_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_cbtn_arrestboss_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if nx_int(form.cur_tiguan_count) == nx_int(cbtn.Parent.guan_index) and nx_number(form.cur_tiguan_level) <= nx_number(form.cur_level_limit) then
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_RANDOM, nx_number(form.cur_tiguan_level), 0)
    form.turn_out = true
  end
end
function on_cbtn_arrestboss_get_capture(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local guan_sort = nx_number(cbtn.Parent.guan_index + 1)
  local level = nx_number(form.cur_tiguan_level)
  if level > tiguan_level_max then
    return 0
  end
  local x, y = gui:GetCursorPosition()
  local nguan_id = cbtn.Parent.guan_id
  if nguan_id ~= 0 then
    local array_name = "guan" .. nx_string(level) .. "sub" .. nx_string(guan_sort)
    local record_complete = nx_number(get_tiguan_record(array_name, "value7"))
    local record_appraise = nx_number(get_tiguan_record(array_name, "value8"))
    local boss_value = nx_number(get_achieve_record(nguan_id, "boss_value"))
    if record_complete == 1 then
      show_boss_tips(nx_string(nguan_id), boss_value, x, y - 10)
    elseif record_complete == 2 then
      if record_appraise >= TG_APPRAISE_LEVEL_3 then
        show_reward_tips(gui.TextManager:GetText(arrest_reward_desc_jia[level]), x, y - 10)
      else
        show_reward_tips(gui.TextManager:GetText(arrest_reward_desc[level]), x, y - 10)
      end
    end
  end
end
function on_cbtn_arrestboss_lost_capture(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_reset_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local cur_tiguan_level = form.cur_tiguan_level
  local text = nx_widestr("")
  if btn.spent_money > 1000 then
    gui.TextManager:Format_SetIDName("ui_exchange_dialog_text1")
    gui.TextManager:Format_AddParam(nx_int(btn.spent_money / 1000))
    gui.TextManager:Format_AddParam(nx_int(btn.spent_money % 1000))
    text = gui.TextManager:Format_GetText()
  else
    gui.TextManager:Format_SetIDName("ui_exchange_dialog_text")
    gui.TextManager:Format_AddParam(nx_int(btn.spent_money))
    text = gui.TextManager:Format_GetText()
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_RANDOM, nx_number(cur_tiguan_level), 1)
  else
    return
  end
end
function on_btn_choice_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local select_boss_item_id = get_item_id_for_choice_boss(form.cur_tiguan_level)
  local item_count = goods_grid:GetItemCount(select_boss_item_id)
  if item_count <= 0 and 0 >= form.free_appoint and select_boss_item_id ~= "" then
    local item_name = gui.TextManager:GetText(select_boss_item_id)
    gui.TextManager:Format_SetIDName("ui_resethint2")
    gui.TextManager:Format_AddParam(nx_string(item_name))
    local text = gui.TextManager:Format_GetText()
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
  else
    local nguan_id = btn.Parent.guan_id
    local form_tiguan_choice_boss = util_show_form(FORM_TIGUAN_CHOICE_BOSS, true)
    if not nx_is_valid(form_tiguan_choice_boss) then
      return 0
    end
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_choice_boss", "show_choice_boss_info", form.cur_tiguan_level, nguan_id, form.free_appoint)
  end
end
function show_boss_tips(guan_id, boss_value, pos_x, pos_y)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local ui_ini = form.guan_ui_ini
  if not nx_is_valid(ui_ini) then
    return 0
  end
  local show_text = nx_widestr("")
  local guan_name = nx_widestr("")
  local index_ui = ui_ini:FindSectionIndex(nx_string(guan_id))
  if 0 <= index_ui then
    guan_name = get_desc_by_id(ui_ini:ReadString(index_ui, "Name", ""))
  end
  show_text = nx_widestr(guan_name) .. nx_widestr("<br>")
  if boss_value <= 0 then
    local boss_list = get_boss_id_list(nx_string(guan_id))
    if boss_list ~= nil then
      local boss_count = table.getn(boss_list)
      for i = 1, boss_count do
        local boss_id = nx_string(boss_list[i])
        show_text = show_text .. nx_widestr("<font color=\"#888888\">") .. gui.TextManager:GetText(boss_id) .. nx_widestr("</font><br>")
      end
    end
  else
    local tiguan_manager = nx_value("tiguan_manager")
    if not nx_is_valid(tiguan_manager) then
      return 0
    end
    local boss_list = get_boss_id_list(nx_string(guan_id))
    if boss_list ~= nil then
      local boss_count = table.getn(boss_list)
      for i = 1, boss_count do
        local boss_id = nx_string(boss_list[i])
        local info = tiguan_manager:bit_and(nx_number(boss_value), 2 ^ i)
        if 0 < info then
          show_text = show_text .. nx_widestr("<font color=\"#FFFFFF\">") .. gui.TextManager:GetText(boss_id) .. nx_widestr("</font><br>")
        else
          show_text = show_text .. nx_widestr("<font color=\"#888888\">") .. gui.TextManager:GetText(boss_id) .. nx_widestr("</font><br>")
        end
      end
    end
  end
  nx_execute("tips_game", "show_text_tip", show_text, pos_x, pos_y, 0, form)
end
function show_reward_tips(show_text, pos_x, pos_y)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute("tips_game", "show_text_tip", show_text, pos_x, pos_y, 0, form)
end
function refresh_turn_info(self)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return 0
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  self.keep_BlendAlpha = self.keep_BlendAlpha - 10
  self.BlendColor = nx_string(self.keep_BlendAlpha) .. ",255,255,255"
  if self.keep_BlendAlpha <= 30 then
    self.Visible = false
    self.keep_BlendAlpha = 255
    self.BlendColor = "255,255,255,255"
    form.lbl_flicker.Visible = false
    timer:UnRegister(nx_current(), "refresh_turn_info", self)
  end
end
function on_pbar_time_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if 0 >= form.cur_level_limit or form.cur_level_limit > tiguan_level_max then
    return 0
  end
  local x, y = gui:GetCursorPosition()
  if form.pbar_time.Value == form.pbar_time.Maximum then
    local show_text = gui.TextManager:GetText("ui_tiguan_time_info6")
    nx_execute("tips_game", "show_text_tip", show_text, x, y, 0, form)
  else
    local show_text = nx_widestr("")
    local mins = form.award_max_time / 60
    if mins == 15 then
      show_text = gui.TextManager:GetText(arrest_time_tips_info[1])
    elseif mins == 20 then
      show_text = gui.TextManager:GetText(arrest_time_tips_info[2])
    elseif mins == 27 then
      show_text = gui.TextManager:GetText(arrest_time_tips_info[3])
    elseif mins == 35 then
      show_text = gui.TextManager:GetText(arrest_time_tips_info[4])
    end
    if show_text ~= nx_widestr("") then
      nx_execute("tips_game", "show_text_tip", show_text, x, y, 0, form)
    end
  end
end
function on_pbar_time_lost_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_rbtn_achieve_checked_changed(cbtn)
  if not cbtn.Checked then
    return 0
  end
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.cur_achieve_level = cbtn.achieve_level
  show_achieve_info(form)
end
function show_achieve_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if achieve_data == nil then
    return 0
  end
  local achieve_ini = form.guan_achieve_ini
  if not nx_is_valid(achieve_ini) then
    return 0
  end
  local ui_ini = form.guan_ui_ini
  if not nx_is_valid(ui_ini) then
    return 0
  end
  local tiguan_manager = nx_value("tiguan_manager")
  if not nx_is_valid(tiguan_manager) then
    return 0
  end
  local level = form.cur_achieve_level
  form.groupscrollbox_1.IsEditMode = true
  form.groupscrollbox_1:DeleteAll()
  local section_count = achieve_ini:GetSectionCount()
  local achieve_id_max = 95
  for i = 1, section_count do
    local reward_type = achieve_ini:ReadInteger(i - 1, "Type", 0)
    local reward_level = achieve_ini:ReadInteger(i - 1, "Level", 0)
    local name_text_id = achieve_ini:ReadString(i - 1, "AchieveName", "")
    local reward_str = achieve_ini:ReadString(i - 1, "RewardStr", "")
    local achieve_desc = achieve_ini:ReadString(i - 1, "AchieveDesc", "")
    local quanfu_level = achieve_ini:ReadInteger(i - 1, "QuanfuLevel", 0)
    local id = achieve_ini:ReadInteger(i - 1, "Index", 0)
    if reward_type == ACHIEVE_TYPE_QUANFU then
      if level == reward_level then
        local groupbox_one = create_ctrl("GroupBox", "groupbox_reward_info_0" .. nx_string(reward_level), form.groupbox_reward, form.groupscrollbox_1)
        if nx_is_valid(groupbox_one) then
          local cbtn_reward_select = create_ctrl("CheckButton", "cbtn_reward_info_0", form.cbtn_reward_select, groupbox_one)
          cbtn_reward_select.reward_id = 0
          cbtn_reward_select.reward_type = ACHIEVE_TYPE_QUANFU
          nx_bind_script(cbtn_reward_select, nx_current())
          nx_callback(cbtn_reward_select, "on_checked_changed", "on_cbtn_reward_checked_changed")
          groupbox_one.Height = cbtn_reward_select.Height + achieve_rank_interval
          local lbl_reward_quanfu_name1 = create_ctrl("Label", "lbl_reward_quanfu_name_1", form.lbl_reward_quanfu_name1, groupbox_one)
          local lbl_reward_quanfu_name2 = create_ctrl("Label", "lbl_reward_quanfu_name_2", form.lbl_reward_quanfu_name2, groupbox_one)
          lbl_reward_quanfu_name2.Text = gui.TextManager:GetText(name_text_id)
          local lbl_reward_back = create_ctrl("Label", "lbl_reward_back_0", form.lbl_reward_back, groupbox_one)
          lbl_reward_back.Top = achieve_lbl_back_pix2
          lbl_reward_back.Height = lbl_reward_back.Height + achieve_quanfu_height
          local mltbox_quanfu_reward_desc = create_ctrl("MultiTextBox", "mltbox_quanfu_reward_desc_0", form.mltbox_quanfu_reward_desc, groupbox_one)
          mltbox_quanfu_reward_desc:Clear()
          mltbox_quanfu_reward_desc:AddHtmlText(gui.TextManager:GetText(achieve_desc), -1)
          local lbl_reward_quanfu_jl = create_ctrl("Label", "lbl_reward_quanfu_jl_0", form.lbl_reward_quanfu_jl, groupbox_one)
          local lbl_reward_quanfu_info = create_ctrl("Label", "lbl_reward_quanfu_info_0", form.lbl_reward_quanfu_info, groupbox_one)
          lbl_reward_quanfu_info.Text = gui.TextManager:GetText(reward_str)
          local mltbox_reward_info1 = create_ctrl("MultiTextBox", "mltbox_reward_info_0", form.mltbox_reward_info1, groupbox_one)
          local mltbox_reward_info2 = create_ctrl("MultiTextBox", "mltbox_reward_info_1", form.mltbox_reward_info2, groupbox_one)
          local mltbox_reward_info3 = create_ctrl("MultiTextBox", "mltbox_reward_info_2", form.mltbox_reward_info3, groupbox_one)
          local mltbox_reward_info4 = create_ctrl("MultiTextBox", "mltbox_reward_info_3", form.mltbox_reward_info4, groupbox_one)
          local mltbox_reward_info5 = create_ctrl("MultiTextBox", "mltbox_reward_info_4", form.mltbox_reward_info5, groupbox_one)
          local mltbox_reward_info6 = create_ctrl("MultiTextBox", "mltbox_reward_info_5", form.mltbox_reward_info6, groupbox_one)
          local quanfu_section_count = ui_ini:GetSectionCount()
          local qu_index = 1
          for i = 1, quanfu_section_count do
            local quanfu_section = ui_ini:GetSectionByIndex(i - 1)
            local quanfu_guan_id = nx_string(quanfu_section)
            local cur_guan_name = get_achieve_record(quanfu_guan_id, "guan_name")
            local cur_guan_level = get_achieve_record(quanfu_guan_id, "guan_level")
            local cur_first_player_name = get_achieve_record(quanfu_guan_id, "first_player_name")
            local cur_first_time = get_achieve_record(quanfu_guan_id, "first_time")
            local cur_guan_open = get_achieve_record(quanfu_guan_id, "guan_open")
            if cur_guan_level == nx_number(quanfu_level) and cur_guan_open == 1 then
              if 4 < qu_index then
                mltbox_reward_info4:AddHtmlText(nx_widestr(cur_guan_name), -1)
                if nx_widestr(cur_first_player_name) ~= nx_widestr("") then
                  mltbox_reward_info5:AddHtmlText(nx_widestr(cur_first_player_name), -1)
                else
                  mltbox_reward_info5:AddHtmlText(nx_widestr("--"), -1)
                end
                if nx_number(cur_first_time) ~= 0 then
                  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", cur_first_time)
                  local data_str = nx_string(year) .. "-" .. nx_string(month) .. "-" .. nx_string(day)
                  mltbox_reward_info6:AddHtmlText(nx_widestr(data_str), -1)
                else
                  mltbox_reward_info6:AddHtmlText(nx_widestr("--"), -1)
                end
              else
                mltbox_reward_info1:AddHtmlText(nx_widestr(cur_guan_name), -1)
                if nx_widestr(cur_first_player_name) ~= nx_widestr("") then
                  mltbox_reward_info2:AddHtmlText(nx_widestr(cur_first_player_name), -1)
                else
                  mltbox_reward_info2:AddHtmlText(nx_widestr("--"), -1)
                end
                if nx_number(cur_first_time) ~= 0 then
                  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", cur_first_time)
                  local data_str = nx_string(year) .. "-" .. nx_string(month) .. "-" .. nx_string(day)
                  mltbox_reward_info3:AddHtmlText(nx_widestr(data_str), -1)
                else
                  mltbox_reward_info3:AddHtmlText(nx_widestr("--"), -1)
                end
              end
              qu_index = qu_index + 1
            end
          end
        end
      end
    elseif level == reward_level and achieve_id_max >= nx_number(id) then
      local data1 = nx_int(nx_int(id) / 32) + 1
      local data2 = nx_number(id) - (data1 - 1) * 32
      local nComplete = tiguan_manager:CheckBitFlag(nx_number(achieve_data[data1][1]), data2)
      local nGet = tiguan_manager:CheckBitFlag(nx_number(achieve_data[data1][2]), data2)
      local groupbox = create_ctrl("GroupBox", "groupbox_reward_info_" .. nx_string(id), form.groupbox_reward, form.groupscrollbox_1)
      if nx_is_valid(groupbox) then
        local cbtn_reward_select = create_ctrl("CheckButton", "cbtn_reward_info_" .. nx_string(id), form.cbtn_reward_select, groupbox)
        cbtn_reward_select.reward_id = id
        cbtn_reward_select.reward_type = reward_type
        nx_bind_script(cbtn_reward_select, nx_current())
        nx_callback(cbtn_reward_select, "on_checked_changed", "on_cbtn_reward_checked_changed")
        groupbox.Height = cbtn_reward_select.Height + achieve_rank_interval
        local btn_get = create_ctrl("Button", "btn_get_reward_" .. nx_string(id), form.btn_reward_get, groupbox)
        nx_bind_script(btn_get, nx_current())
        nx_callback(btn_get, "on_click", "on_btn_get_reward_click")
        btn_get.reward_id = id
        if nx_number(nGet) == 0 and 0 < nx_number(nComplete) then
          btn_get.Enabled = true
        else
          btn_get.Enabled = false
        end
        local mltbox_reward_name = create_ctrl("MultiTextBox", "mltbox_reward_name_" .. nx_string(id), form.mltbox_reward_name, groupbox)
        local reward_name_text = gui.TextManager:GetText(name_text_id)
        local lbl_reward_item = create_ctrl("Label", "lbl_reward_" .. nx_string(id), form.lbl_reward_item, groupbox)
        lbl_reward_item.Text = gui.TextManager:GetText(reward_str)
        local lbl_reward_back = create_ctrl("Label", "lbl_reward_back_" .. nx_string(id), form.lbl_reward_back, groupbox)
        lbl_reward_back.Top = achieve_lbl_back_pix2
        local mltbox_reward_desc = create_ctrl("MultiTextBox", "mltbox_reward_desc_" .. nx_string(id), form.mltbox_reward_desc, groupbox)
        mltbox_reward_desc:AddHtmlText(gui.TextManager:GetText(achieve_desc), -1)
        local lbl_reward_jl = create_ctrl("Label", "lbl_reward_jl_" .. nx_string(id), form.lbl_reward_jl, groupbox)
        if 0 < nx_number(nComplete) then
          local lbl_reward_complete = create_ctrl("Label", "lbl_reward_complete_" .. nx_string(id), form.lbl_reward_complete, groupbox)
        end
        local achieve_reward_count = 0
        if reward_type == ACHIEVE_TYPE_GUANJIA then
          local guanid_str = achieve_ini:ReadString(i - 1, "GuanIDStr", "")
          local guanid_list = util_split_string(nx_string(guanid_str), ",")
          local guanid_count = table.getn(guanid_list)
          for j = 1, guanid_count do
            local index = ui_ini:FindSectionIndex(nx_string(guanid_list[j]))
            if 0 <= index then
              local guan_id = nx_string(guanid_list[j])
              local lbl_reward_other = form.groupbox_reward:Find("lbl_reward_other" .. nx_string(j))
              if nx_is_valid(lbl_reward_other) then
                local lbl_reward_other_copy = create_ctrl("Label", "lbl_reward_other" .. nx_string(j), lbl_reward_other, groupbox)
                lbl_reward_other_copy.Text = get_desc_by_id(ui_ini:ReadString(index, "Name", ""))
              end
              local lbl_reward_image = form.groupbox_reward:Find("lbl_reward_image" .. nx_string(j))
              if nx_is_valid(lbl_reward_image) then
                local lbl_reward_image_copy = create_ctrl("Label", "lbl_reward_image" .. nx_string(j), lbl_reward_image, groupbox)
                local guan_appraise = get_achieve_record(guan_id, "guan_appraise")
                if reward_type == ACHIEVE_TYPE_GUANJIA then
                  if guan_appraise >= TG_APPRAISE_LEVEL_3 then
                    achieve_reward_count = achieve_reward_count + 1
                    lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
                  else
                    lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_on.png"
                  end
                elseif 0 < guan_appraise then
                  achieve_reward_count = achieve_reward_count + 1
                  lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
                else
                  lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_on.png"
                end
              end
            end
          end
          if 0 <= achieve_reward_count then
            local reward_count_text = nx_widestr("(") .. nx_widestr(achieve_reward_count) .. nx_widestr("/") .. nx_widestr(guanid_count) .. nx_widestr(")")
            reward_name_text = reward_name_text .. reward_count_text
          end
        elseif reward_type == ACHIEVE_TYPE_BOSS or reward_type == ACHIEVE_TYPE_BOSSJIA then
          local guanid_str = achieve_ini:ReadString(i - 1, "GuanIDStr", "")
          local guanid_list = util_split_string(nx_string(guanid_str), ",")
          local guanid_count = table.getn(guanid_list)
          if 1 <= guanid_count then
            local guan_id = nx_string(guanid_list[1])
            local bossid_list = get_boss_id_list(guan_id)
            if bossid_list ~= nil then
              local boss_count = table.getn(bossid_list)
              for j = 1, boss_count do
                local boss_id = nx_string(bossid_list[j])
                local lbl_reward_other = form.groupbox_reward:Find("lbl_reward_other" .. nx_string(j))
                if nx_is_valid(lbl_reward_other) then
                  local lbl_reward_other_copy = create_ctrl("Label", "lbl_reward_other" .. nx_string(j), lbl_reward_other, groupbox)
                  lbl_reward_other_copy.Text = gui.TextManager:GetText(boss_id)
                end
                local lbl_reward_image = form.groupbox_reward:Find("lbl_reward_image" .. nx_string(j))
                if nx_is_valid(lbl_reward_image) then
                  local lbl_reward_image_copy = create_ctrl("Label", "lbl_reward_image" .. nx_string(j), lbl_reward_image, groupbox)
                  if reward_type == ACHIEVE_TYPE_BOSSJIA then
                    lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_on.png"
                    local boss_value = get_achieve_record(guan_id, "boss_value")
                    local boss_appraise = get_achieve_record(guan_id, "boss_appraise")
                    local bExistBoss = tiguan_manager:bit_and(nx_number(boss_value), 2 ^ j)
                    local bAppraise = tiguan_manager:bit_and(nx_number(boss_appraise), 2 ^ j)
                    if 0 < bExistBoss and 0 < bAppraise then
                      achieve_reward_count = achieve_reward_count + 1
                      lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
                    end
                  else
                    local boss_value = get_achieve_record(guan_id, "boss_value")
                    local bExistBoss = tiguan_manager:bit_and(nx_number(boss_value), 2 ^ j)
                    if 0 < bExistBoss then
                      achieve_reward_count = achieve_reward_count + 1
                      lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
                    else
                      lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_on.png"
                    end
                  end
                end
              end
              if 0 <= achieve_reward_count then
                local reward_count_text = nx_widestr("(") .. nx_widestr(achieve_reward_count) .. nx_widestr("/") .. nx_widestr(boss_count) .. nx_widestr(")")
                reward_name_text = reward_name_text .. reward_count_text
              end
            end
          end
        else
          if reward_type == ACHIEVE_TYPE_GUANC then
            local guanid_str = achieve_ini:ReadString(i - 1, "GuanIDStr", "")
            local guanid_list = util_split_string(nx_string(guanid_str), ",")
            local guanid_count = table.getn(guanid_list)
            local achieve_id_str = achieve_ini:ReadString(i - 1, "AchieveID", "")
            local achieve_id_list = util_split_string(nx_string(achieve_id_str), ",")
            local achieve_id_count = table.getn(achieve_id_list)
            if nx_number(achieve_id_count) == nx_number(guanid_count) then
              for j = 1, achieve_id_count do
                local index = ui_ini:FindSectionIndex(nx_string(guanid_list[j]))
                if 0 <= index then
                  local guan_id = nx_string(guanid_list[j])
                  local lbl_reward_other = form.groupbox_reward:Find("lbl_reward_other" .. nx_string(j))
                  if nx_is_valid(lbl_reward_other) then
                    local lbl_reward_other_copy = create_ctrl("Label", "lbl_reward_other" .. nx_string(j), lbl_reward_other, groupbox)
                    lbl_reward_other_copy.Text = get_desc_by_id(ui_ini:ReadString(index, "Name", ""))
                  end
                  local lbl_reward_image = form.groupbox_reward:Find("lbl_reward_image" .. nx_string(j))
                  if nx_is_valid(lbl_reward_image) then
                    local lbl_reward_image_copy = create_ctrl("Label", "lbl_reward_image" .. nx_string(j), lbl_reward_image, groupbox)
                    if 0 < nx_number(IsCompleteAchieve(achieve_id_list[j])) then
                      achieve_reward_count = achieve_reward_count + 1
                      lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
                    else
                      lbl_reward_image_copy.BackImage = "gui\\common\\checkbutton\\cbtn_5_on.png"
                    end
                  end
                end
              end
              if 0 <= achieve_reward_count then
                local reward_count_text = nx_widestr("(") .. nx_widestr(achieve_reward_count) .. nx_widestr("/") .. nx_widestr(guanid_count) .. nx_widestr(")")
                reward_name_text = reward_name_text .. reward_count_text
              end
            end
          else
          end
        end
        mltbox_reward_name:Clear()
        mltbox_reward_name:AddHtmlText(reward_name_text, -1)
      end
    end
  end
  form.groupscrollbox_1.IsEditMode = false
  form.groupscrollbox_1:ResetChildrenYPos()
end
function on_btn_get_reward_click(btn)
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_ACHIEVE_AWARD, nx_int(btn.reward_id))
  btn.Enabled = false
end
function on_cbtn_reward_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gbox = cbtn.Parent
  if not nx_is_valid(gbox) then
    return 0
  end
  local lbl_reward_back = gbox:Find("lbl_reward_back_" .. nx_string(cbtn.reward_id))
  local reward_type = cbtn.reward_type
  if reward_type == ACHIEVE_TYPE_GUANJIA or reward_type == ACHIEVE_TYPE_GUANC or reward_type == ACHIEVE_TYPE_BOSS or reward_type == ACHIEVE_TYPE_BOSSJIA then
    if cbtn.Checked then
      gbox.Height = form.lbl_reward_back.Height + cbtn.Height + achieve_rank_interval
      lbl_reward_back.Top = achieve_lbl_back_pix1
    else
      gbox.Height = cbtn.Height + achieve_rank_interval
      lbl_reward_back.Top = achieve_lbl_back_pix2
    end
  elseif reward_type == ACHIEVE_TYPE_QUANFU then
    if cbtn.Checked then
      gbox.Height = form.lbl_reward_back.Height + cbtn.Height + achieve_rank_interval + achieve_quanfu_height
      lbl_reward_back.Top = achieve_lbl_back_pix1
      lbl_reward_back.Height = lbl_reward_back.Height
    else
      gbox.Height = cbtn.Height + achieve_rank_interval
      lbl_reward_back.Top = achieve_lbl_back_pix2
    end
  else
    local back_height = 59
    if cbtn.Checked then
      gbox.Height = form.lbl_reward_back.Height + cbtn.Height + achieve_rank_interval - back_height
      lbl_reward_back.Top = achieve_lbl_back_pix1
      lbl_reward_back.Height = lbl_reward_back.Height - back_height
    else
      gbox.Height = cbtn.Height + achieve_rank_interval
      lbl_reward_back.Top = achieve_lbl_back_pix2
      lbl_reward_back.Height = lbl_reward_back.Height + back_height
    end
  end
  form.groupscrollbox_1:ResetChildrenYPos()
end
function exchange_condition(player, condition_manager, item_index_str)
  if not nx_is_valid(player) then
    return false
  end
  if not nx_is_valid(condition_manager) then
    return false
  end
  local exchange_share_ini = nx_execute("util_functions", "get_ini", SHARE_TIGUAN_EXCHANGE)
  if not nx_is_valid(exchange_share_ini) then
    return false
  end
  local item_index_tab = util_split_string(item_index_str, ",")
  local count = table.getn(item_index_tab)
  if count <= 0 then
    return true
  end
  local sec_index = exchange_share_ini:FindSectionIndex(item_index_tab[1])
  if sec_index < 0 then
    return true
  end
  local condition_id = exchange_share_ini:ReadInteger(sec_index, "Condition", 0)
  local b_ok = condition_manager:CanSatisfyCondition(player, player, condition_id)
  return b_ok
end
function show_exchange_info(form, category)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return 0
  end
  local exchange_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_EXCHANGE_INI)
  if not nx_is_valid(exchange_ini) then
    return 0
  end
  local tool_item_ini = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  if not nx_is_valid(tool_item_ini) then
    return 0
  end
  local ficker_item_index = get_flick_item_index()
  form.groupscrollbox_2.IsEditMode = true
  form.groupscrollbox_2:DeleteAll()
  local section_count = exchange_ini:GetSectionCount()
  local j = 1
  local groupbox
  for i = 1, section_count do
    local SectionName = exchange_ini:GetSectionByIndex(i - 1)
    local exchange_category = exchange_ini:ReadInteger(i - 1, "Category", "")
    local item_id = exchange_ini:ReadString(i - 1, "ItemID", "")
    local exchange_type = exchange_ini:ReadString(i - 1, "ExchangeType", "")
    local item_desc = exchange_ini:ReadString(i - 1, "ItemDesc", "")
    local index_str = exchange_ini:ReadString(i - 1, "Index", "")
    if nx_number(category) == nx_number(exchange_category) and exchange_condition(player, condition_manager, index_str) then
      local col = j % 4
      j = j + 1
      local groupbox_sub
      if col == 1 then
        groupbox = create_ctrl("GroupBox", "gbox_exchange_" .. nx_string(i), form.groupbox_template, form.groupscrollbox_2)
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(i), form.groupbox_template_eh1, groupbox)
      elseif col == 2 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(i), form.groupbox_template_eh2, groupbox)
      elseif col == 3 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(i), form.groupbox_template_eh3, groupbox)
      else
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(i), form.groupbox_template_eh4, groupbox)
      end
      local mltbox_name = create_ctrl("MultiTextBox", "mltbox_tmp_name_" .. nx_string(i), form.mltbox_tmp_name1, groupbox_sub)
      local mltbox_desc = create_ctrl("MultiTextBox", "mltbox_tmp_desc_" .. nx_string(i), form.mltbox_tmp_desc1, groupbox_sub)
      local mltbox_exchange = create_ctrl("MultiTextBox", "mltbox_exchange_" .. nx_string(i), form.mltbox_exchange, groupbox_sub)
      local cbtn_back = create_ctrl("CheckButton", "cbtn_exchange_back_" .. nx_string(i), form.cbtn_tmp_back1, groupbox_sub)
      local imagegrid = create_ctrl("ImageGrid", "imagegrid_exchange_" .. nx_string(i), form.imagegrid_eh1, groupbox_sub)
      if nx_number(ficker_item_index) == nx_number(index_str) and form.flick_item_count == 0 then
        local lbl_tmp_flicker = create_ctrl("Label", "lbl_tmp_flicker1_" .. nx_string(i), form.lbl_tmp_flicker1, groupbox_sub)
      end
      nx_bind_script(cbtn_back, nx_current())
      nx_callback(cbtn_back, "on_click", "on_cbtn_tmp_back1_click")
      local photo = get_item_info(item_id, "photo")
      imagegrid:AddItem(0, photo, "", 1, -1)
      imagegrid.RowNum = 1
      imagegrid.ClomnNum = 1
      imagegrid.GridWidth = imagegrid.Width - 10
      imagegrid.GridHeight = imagegrid.Height - 10
      imagegrid.DrawMode = "Expand"
      nx_bind_script(imagegrid, nx_current())
      nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_eh_mousein_grid")
      nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_eh_mouseout_grid")
      nx_callback(imagegrid, "on_select_changed", "on_imagegrid_eh_select_changed")
      imagegrid.item_id = item_id
      imagegrid.index = i - 1
      mltbox_name:Clear()
      mltbox_name:AddHtmlText(gui.TextManager:GetText(nx_string(item_id)), -1)
      local posx = (mltbox_name.Width - mltbox_name:GetContentWidth()) / 2
      mltbox_name.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
      mltbox_desc:Clear()
      mltbox_desc:AddHtmlText(gui.TextManager:GetText(exchange_type), -1)
      posx = (mltbox_desc.Width - mltbox_desc:GetContentWidth()) / 2
      mltbox_desc.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
      mltbox_exchange:Clear()
      mltbox_exchange:AddHtmlText(gui.TextManager:GetText(item_desc), -1)
      posx = (mltbox_exchange.Width - mltbox_exchange:GetContentWidth()) / 2
      mltbox_exchange.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
      cbtn_back.index = i - 1
    end
  end
  form.groupscrollbox_2.IsEditMode = false
  form.groupscrollbox_2:ResetChildrenYPos()
end
function on_imagegrid_eh_select_changed(self, index)
  show_exchange_item_dialog(self.index)
end
function on_imagegrid_eh_mousein_grid(self, index)
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(self.item_id)
    item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(self.item_id), "ItemType", "0")
    nx_execute("tips_game", "show_goods_tip", item, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 40, 40, self.ParentForm)
  end
end
function on_imagegrid_eh_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function refresh_exchange_tree(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return 0
  end
  local defeat_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(defeat_ini) then
    return 0
  end
  form.tree_exchange:BeginUpdate()
  local exchange_root = form.tree_exchange:CreateRootNode(nx_widestr("root"))
  exchange_root.category = -1
  local index1 = defeat_ini:FindSectionIndex("node_first")
  local node_first_str = defeat_ini:GetItemValueList(index1, "node")
  local first_count = table.getn(node_first_str)
  if first_count <= 0 then
    return 0
  end
  for i = 1, first_count do
    local data_tab = util_split_string(nx_string(node_first_str[i]), ",")
    local par_count = table.getn(data_tab)
    if par_count < 3 then
      return
    end
    local node_name = gui.TextManager:GetText(nx_string(data_tab[2]))
    local condition_id = nx_number(data_tab[3])
    if condition_manager:CanSatisfyCondition(player, player, condition_id) then
      local first_node = exchange_root:CreateNode(node_name)
      first_node.Mark = nx_int(i)
      set_node_prop(first_node, 1)
      first_node.category = nx_number(data_tab[1])
    end
  end
  local index2 = defeat_ini:FindSectionIndex("node_second")
  local node_second_str = defeat_ini:GetItemValueList(index2, "node")
  local second_count = table.getn(node_second_str)
  if first_count < second_count then
    second_count = first_count
  end
  for i = 1, second_count do
    local data_tab = util_split_string(nx_string(node_second_str[i]), ",")
    local sub_count = table.getn(data_tab) / 3
    for j = 1, sub_count do
      local node_name = gui.TextManager:GetText(data_tab[j * 3 - 1])
      local category = nx_number(data_tab[j * 3 - 2])
      local condition_id = nx_number(data_tab[j * 3])
      if condition_manager:CanSatisfyCondition(player, player, condition_id) then
        local first_node = exchange_root:FindNodeByMark(i)
        if nx_is_valid(first_node) then
          local second_node = first_node:CreateNode(node_name)
          second_node.category = category
          set_node_prop(second_node, 2)
        end
      end
    end
  end
  exchange_root.Expand = true
  auto_select_first(form.tree_exchange)
  form.tree_exchange.IsNoDrawRoot = true
  form.tree_exchange:EndUpdate()
end
function on_tree_exchange_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cur_node.category == 0 then
    return 0
  end
  form.cur_exchange_category = cur_node.category
  show_exchange_info(form, cur_node.category)
end
function auto_select_tanlanquan(tree)
  local expand_index = nx_number(5)
  local root_node = tree.RootNode
  local temp_node = tree.RootNode
  if nx_is_valid(root_node) then
    local sub_node_tab = root_node:GetNodeList()
    if expand_index <= table.getn(sub_node_tab) then
      local sub_node = sub_node_tab[expand_index]
      temp_node = sub_node
      sub_node.Expand = true
      local temp_node_tab = sub_node:GetNodeList()
      if table.getn(temp_node_tab) > 0 then
        temp_node = temp_node_tab[1]
      else
        tree.SelectNode = temp_node
      end
    end
  end
  if temp_node.category == -1 then
    return 0
  end
  show_exchange_info(tree.ParentForm, temp_node.category)
end
function auto_select_first(tree)
  local expand_index = nx_number(get_aotu_expand_node())
  local root_node = tree.RootNode
  local temp_node = tree.RootNode
  if nx_is_valid(root_node) then
    local sub_node_tab = root_node:GetNodeList()
    if expand_index <= table.getn(sub_node_tab) then
      local sub_node = sub_node_tab[expand_index]
      temp_node = sub_node
      sub_node.Expand = true
      local temp_node_tab = sub_node:GetNodeList()
      if table.getn(temp_node_tab) > 0 then
        temp_node = temp_node_tab[1]
      else
        tree.SelectNode = temp_node
      end
    end
  end
  if temp_node.category == -1 then
    return 0
  end
  show_exchange_info(tree.ParentForm, temp_node.category)
end
function show_exchange_item_dialog(index)
  local form_tiguan_exchange = util_show_form(FORM_TIGUAN_EXCHANGE, true)
  if not nx_is_valid(form_tiguan_exchange) then
    return 0
  end
  nx_execute("form_stage_main\\form_tiguan\\form_tiguan_exchange", "show_exchange_item_info", form_tiguan_exchange, index)
end
function on_cbtn_tmp_back1_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  cbtn.Checked = false
  show_exchange_item_dialog(cbtn.index)
end
function on_rbtn_exchange_type_checked_changed(btn)
  if not btn.Checked then
    return 0
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  on_close_exchange_form()
  form.cur_exchange_category = btn.exchange_category
  show_exchange_info(form, btn.exchange_category)
end
function refresh_exchange_flicker(form)
  if nx_number(form.flick_item_count) == 0 then
    form.lbl_exchange_flicker.Visible = true
  else
    form.lbl_exchange_flicker.Visible = false
  end
end
function init_rank_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  form.textgrid_rank:BeginUpdate()
  form.textgrid_rank:ClearRow()
  form.textgrid_rank.ColCount = rank_col_count
  form.textgrid_rank.HeaderBackColor = "0,255,255,255"
  for i = 1, rank_col_count do
    local head_name = gui.TextManager:GetFormatText(rank_col_list[i])
    form.textgrid_rank:SetColTitle(i - 1, nx_widestr(head_name))
  end
  form.textgrid_rank:EndUpdate()
end
function refresh_rank_info(arg)
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local tiguan_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(tiguan_ini) then
    return 0
  end
  local tiguan_award_ini = nx_execute("util_functions", "get_ini", SHARE_TIGUAN_AWARD_INI)
  if not nx_is_valid(tiguan_award_ini) then
    return 0
  end
  local guan_ui_ini = form.guan_ui_ini
  if not nx_is_valid(guan_ui_ini) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local tiguan_one_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(tiguan_one_ini) then
    return 0
  end
  local reward_index = tiguan_one_ini:FindSectionIndex("rank_reward")
  if reward_index < 0 then
    return 0
  end
  local title_index = tiguan_one_ini:FindSectionIndex("rank_title")
  if title_index < 0 then
    return 0
  end
  local msg_count = 9
  form.textgrid_rank:BeginUpdate()
  local count = table.getn(arg)
  if msg_count > count then
    return 0
  end
  local arg_count = nx_int(count / msg_count)
  local row_count = form.textgrid_rank.RowCount
  local row_index = row_count
  for i = 0, arg_count - 1 do
    local nIndex1 = tiguan_ini:FindSectionIndex(nx_string(arg[1 + i * msg_count]))
    local nLevel = tiguan_ini:ReadInteger(nIndex1, "Level", 0)
    local LevelName = get_desc_by_id(guan_danci_name[nx_number(nLevel)])
    local nIndex2 = guan_ui_ini:FindSectionIndex(nx_string(arg[1 + i * msg_count]))
    local GuanName = get_desc_by_id(guan_ui_ini:ReadString(nIndex2, "Name", ""))
    local award_section = "week_rank_" .. nx_string(arg[1 + i * msg_count])
    local nIndex3 = tiguan_award_ini:FindSectionIndex(award_section)
    local title_id = tiguan_award_ini:ReadInteger(nIndex3, "title", 0)
    local title_text = gui.TextManager:GetText("role_title_" .. title_id)
    local str_award_item = tiguan_award_ini:ReadString(nIndex3, "item", "")
    local award_item_list = util_split_string(nx_string(str_award_item), ",")
    local award_item_count = table.getn(award_item_list)
    local award_time_name = ""
    local award_item_id = ""
    if 0 < award_item_count then
      award_time_name = gui.TextManager:GetText(award_item_list[1])
      award_item_id = award_item_list[1]
    end
    local title_key = "guan" .. nx_string(arg[1 + i * msg_count])
    local title_pic_str = tiguan_one_ini:ReadString(title_index, title_key, "")
    local reward_key = "guan" .. nx_string(arg[1 + i * msg_count])
    local reward_pic_str = tiguan_one_ini:ReadString(reward_index, reward_key, "")
    form.textgrid_rank:InsertRow(-1)
    form.textgrid_rank:SetGridText(row_index, 0, nx_widestr(GuanName))
    form.textgrid_rank:SetGridText(row_index, 1, nx_widestr(LevelName))
    create_rank_apply_control(form, row_index, 2, arg[1 + i * msg_count])
    form.textgrid_rank:SetGridText(row_index, 3, nx_widestr(0))
    if nx_widestr(arg[2 + i * msg_count]) ~= nx_widestr("") then
      form.textgrid_rank:SetGridText(row_index, 4, nx_widestr(arg[2 + i * msg_count]))
    else
      form.textgrid_rank:SetGridText(row_index, 4, nx_widestr("--"))
    end
    create_rank_title_pic(form, row_index, 5, title_pic_str, title_text)
    if nx_number(arg[5 + i * msg_count]) ~= 0 then
      create_rank_grid_control(form, row_index, 6, reward_pic_str, nx_int(arg[5 + i * msg_count]), award_item_id)
    else
      form.textgrid_rank:SetGridText(row_index, 6, nx_widestr("--"))
    end
    if nx_number(arg[3 + i * msg_count]) ~= 0 then
      form.textgrid_rank:SetGridText(row_index, 7, nx_widestr(arg[3 + i * msg_count]))
    else
      form.textgrid_rank:SetGridText(row_index, 7, nx_widestr("--"))
    end
    if nx_number(arg[4 + i * msg_count]) ~= 0 then
      form.textgrid_rank:SetGridText(row_index, 8, nx_widestr(arg[4 + i * msg_count]))
    else
      form.textgrid_rank:SetGridText(row_index, 8, nx_widestr("--"))
    end
    if nx_number(arg[4 + i * msg_count]) >= 160 then
      form.can_apply = 1
    end
    create_rank_grid_control(form, row_index, 9, reward_pic_str, nx_int(arg[6 + i * msg_count]), award_item_id)
    form.textgrid_rank:SetGridText(row_index, 10, nx_widestr(arg[7 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 11, nx_widestr(nLevel))
    form.textgrid_rank:SetGridText(row_index, 12, nx_widestr(arg[1 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 13, nx_widestr(row_index))
    form.textgrid_rank:SetGridText(row_index, 14, nx_widestr(arg[5 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 15, nx_widestr(arg[6 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 16, nx_widestr(arg[8 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 17, nx_widestr(arg[9 + i * msg_count]))
    for j = 0, rank_col_count - 1 do
      form.textgrid_rank:SetGridForeColor(row_index, j, rank_default_fore_color)
    end
    if form.player_name == form.textgrid_rank:GetGridText(row_index, 2) then
      for j = 0, form.textgrid_rank.ColCount - 1 do
        form.textgrid_rank:SetGridForeColor(row_index, j, rank_player_fore_color)
      end
    end
    row_index = row_index + 1
  end
  refresh_rank_color(form)
  refresh_rank_apply(form)
  form.textgrid_rank:EndUpdate()
end
function refresh_rank_flicker(form)
  if nx_number(form.rank_apply_guanid) == 0 and form.can_apply == 1 then
    form.lbl_rank_flicker.Visible = true
  else
    form.lbl_rank_flicker.Visible = false
  end
end
function refresh_rank_apply(form)
  local message_delay = nx_value("MessageDelay")
  if not nx_is_valid(message_delay) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  tm = os.date("*t", message_delay:GetServerSecond())
  local in_time = true
  if nx_number(tm.wday) == 2 and nx_number(tm.hour) >= 5 and nx_number(tm.hour) <= 6 then
    in_time = false
  end
  local row_count = form.textgrid_rank.RowCount
  for i = 0, row_count - 1 do
    local guan_id = nx_number(form.textgrid_rank:GetGridText(i, rank_col_rule_guan_id))
    local groupbox = form.textgrid_rank:GetGridControl(i, rank_col_apply_control)
    if nx_is_valid(groupbox) then
      local cbtn = groupbox:Find("btn_rank_apply_crt" .. nx_string(guan_id))
      if nx_is_valid(cbtn) then
        if in_time then
          cbtn.Enabled = true
        else
          cbtn.Enabled = false
        end
        if form.rank_apply_guanid == guan_id then
          cbtn.NormalImage = form.btn_rank_apply_yes.NormalImage
          cbtn.FocusImage = form.btn_rank_apply_yes.FocusImage
          cbtn.PushImage = form.btn_rank_apply_yes.PushImage
          cbtn.DisableImage = form.btn_rank_apply_yes.DisableImage
          cbtn.Text = nx_widestr("    ") .. gui.TextManager:GetText(rank_apply_text_id_2)
        else
          cbtn.NormalImage = form.btn_rank_apply_no.NormalImage
          cbtn.FocusImage = form.btn_rank_apply_no.FocusImage
          cbtn.PushImage = form.btn_rank_apply_no.PushImage
          cbtn.DisableImage = form.btn_rank_apply_no.DisableImage
          cbtn.Text = nx_widestr("    ") .. gui.TextManager:GetText(rank_apply_text_id_1)
        end
      end
    end
  end
end
function refresh_rank_apply_persion_count(form, arg)
  local arg_count = table.getn(arg)
  if arg_count < 2 then
    return 0
  end
  local count = nx_number(arg_count / 2)
  for i = 1, count do
    local guan_id = nx_number(arg[i * 2 - 1])
    local apply_count = nx_number(arg[i * 2])
    local row_count = form.textgrid_rank.RowCount
    for j = 0, row_count - 1 do
      local rank_guan_id = nx_number(form.textgrid_rank:GetGridText(j, rank_col_rule_guan_id))
      if nx_number(guan_id) == nx_number(rank_guan_id) then
        form.textgrid_rank:SetGridText(j, rank_col_apply_num, nx_widestr(apply_count))
      end
    end
  end
end
function create_rank_grid_control(form, row, col, pic, count, item_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Name = "groupbox_rank_reward_" .. nx_string(row) .. "_" .. nx_string(col)
  local grid_item = gui:Create("ImageGrid")
  groupbox:Add(grid_item)
  grid_item.BackImage = pic
  grid_item.Width = form.imagegrid_rank_reward_item.Width
  grid_item.Height = form.imagegrid_rank_reward_item.Height
  grid_item.Top = form.imagegrid_rank_reward_item.Top
  grid_item.Left = form.imagegrid_rank_reward_item.Left
  grid_item.Name = "imagegrid_rank_reward_item_" .. nx_string(row) .. "_" .. nx_string(col)
  grid_item.DrawMode = form.imagegrid_rank_reward_item.DrawMode
  grid_item.SelectColor = form.imagegrid_rank_reward_item.SelectColor
  grid_item.MouseInColor = form.imagegrid_rank_reward_item.MouseInColor
  grid_item.NoFrame = form.imagegrid_rank_reward_item.NoFrame
  grid_item.item_id = item_id
  nx_bind_script(grid_item, nx_current())
  nx_callback(grid_item, "on_get_capture", "on_imagegrid_rank_reward_item_get_capture")
  nx_callback(grid_item, "on_lost_capture", "on_imagegrid_rank_reward_item_lost_capture")
  local label_name = gui:Create("Label")
  groupbox:Add(label_name)
  label_name.Width = form.lbl_rank_reward_name.Width
  label_name.Height = form.lbl_rank_reward_name.Height
  label_name.Top = form.lbl_rank_reward_name.Top
  label_name.Left = form.lbl_rank_reward_name.Left
  label_name.Text = nx_widestr("X") .. nx_widestr(count)
  label_name.ForeColor = form.lbl_rank_reward_name.ForeColor
  label_name.Name = "lbl_rank_reward_name"
  form.textgrid_rank:SetGridControl(row, col, groupbox)
end
function create_rank_apply_control(form, row, col, guan_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Name = "groupbox_rank_apply_" .. nx_string(guan_id)
  local btn = gui:Create("Button")
  groupbox:Add(btn)
  btn.Name = "btn_rank_apply_crt" .. nx_string(guan_id)
  btn.Text = nx_widestr("    ") .. gui.TextManager:GetText(rank_apply_text_id_1)
  btn.ForeColor = form.btn_rank_apply_no.ForeColor
  btn.Font = form.btn_rank_apply_no.Font
  btn.Width = form.btn_rank_apply_no.Width
  btn.Height = form.btn_rank_apply_no.Height
  btn.Top = form.btn_rank_apply_no.Top
  btn.Left = form.btn_rank_apply_no.Left + 20
  btn.NormalImage = form.btn_rank_apply_no.NormalImage
  btn.FocusImage = form.btn_rank_apply_no.FocusImage
  btn.PushImage = form.btn_rank_apply_no.PushImage
  btn.DisableImage = form.btn_rank_apply_no.DisableImage
  btn.DrawMode = form.btn_rank_apply_no.DrawMode
  btn.SelectColor = "0,0,0,0"
  btn.DataSource = nx_string(guan_id)
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "on_btn_rank_apply_click")
  if form.rank_apply_guanid == nx_number(guan_id) then
    btn.NormalImage = form.btn_rank_apply_yes.NormalImage
    btn.FocusImage = form.btn_rank_apply_yes.FocusImage
    btn.PushImage = form.btn_rank_apply_yes.PushImage
    btn.DisableImage = form.btn_rank_apply_yes.DisableImage
    btn.Text = nx_widestr("    ") .. gui.TextManager:GetText(rank_apply_text_id_2)
  end
  form.textgrid_rank:SetGridControl(row, col, groupbox)
end
function create_rank_title_pic(form, row, col, pic, title_text)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Name = "groupbox_rank_title_" .. nx_string(row)
  local grid_item = gui:Create("ImageGrid")
  groupbox:Add(grid_item)
  grid_item.Name = "imagegrid_rank_title_" .. nx_string(row)
  grid_item.BackImage = pic
  grid_item.Width = form.imagegrid_rank_title.Width
  grid_item.Height = form.imagegrid_rank_title.Height
  grid_item.Top = form.imagegrid_rank_title.Top
  grid_item.Left = form.imagegrid_rank_title.Left
  grid_item.DrawMode = form.imagegrid_rank_title.DrawMode
  grid_item.SelectColor = form.imagegrid_rank_title.SelectColor
  grid_item.MouseInColor = form.imagegrid_rank_title.MouseInColor
  grid_item.NoFrame = form.imagegrid_rank_title.NoFrame
  grid_item.title_text = title_text
  nx_bind_script(grid_item, nx_current())
  nx_callback(grid_item, "on_get_capture", "on_imagegrid_rank_title_item_get_capture")
  nx_callback(grid_item, "on_lost_capture", "on_imagegrid_rank_title_item_lost_capture")
  form.textgrid_rank:SetGridControl(row, col, groupbox)
end
function refresh_rank_color(form)
  local row_count = form.textgrid_rank.RowCount
  for i = 0, row_count - 1 do
    local guan_id = nx_number(form.textgrid_rank:GetGridText(i, rank_col_rule_guan_id))
    if form.rank_select_guanid == guan_id then
      for j = 0, form.textgrid_rank.ColCount - 1 do
        form.textgrid_rank:SetGridForeColor(i, j, rank_select_fore_color)
      end
    elseif form.player_name == form.textgrid_rank:GetGridText(i, rank_col_player_name) then
      for j = 0, form.textgrid_rank.ColCount - 1 do
        form.textgrid_rank:SetGridForeColor(i, j, rank_player_fore_color)
      end
    else
      for j = 0, form.textgrid_rank.ColCount - 1 do
        form.textgrid_rank:SetGridForeColor(i, j, rank_default_fore_color)
      end
      if form.rank_sort_col ~= -1 then
        form.textgrid_rank:SetGridForeColor(i, form.rank_sort_col, rank_select_fore_color)
      end
    end
    local groupbox1 = form.textgrid_rank:GetGridControl(i, rank_col_award_1)
    if nx_is_valid(groupbox1) then
      local lable_name = groupbox1:Find("lbl_rank_reward_name")
      local color = form.textgrid_rank:GetGridForeColor(i, rank_col_award_1)
      if nx_is_valid(lable_name) then
        lable_name.ForeColor = color
      end
    end
    local groupbox2 = form.textgrid_rank:GetGridControl(i, rank_col_next_week)
    if nx_is_valid(groupbox2) then
      local lable_name = groupbox2:Find("lbl_rank_reward_name")
      local color = form.textgrid_rank:GetGridForeColor(i, rank_col_next_week)
      if nx_is_valid(lable_name) then
        lable_name.ForeColor = color
      end
    end
  end
end
function on_textgrid_rank_select_row(self, row)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local get_text = form.textgrid_rank:GetGridText(row, rank_col_rule_is_get)
  if form.player_name == self:GetGridText(row, rank_col_player_name) and nx_number(get_text) == 0 then
    form.btn_rank_get.Enabled = true
  else
    form.btn_rank_get.Enabled = false
  end
  form.rank_select_guanid = nx_number(form.textgrid_rank:GetGridText(row, rank_col_rule_guan_id))
  refresh_rank_color(form)
end
function on_btn_rank_get_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local row = form.textgrid_rank.RowSelectIndex
  if 0 <= row then
    local guan_id = form.textgrid_rank:GetGridText(row, rank_col_rule_guan_id)
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_RANK_AWARD, nx_number(guan_id))
    btn.Enabled = false
    form.textgrid_rank:SetGridText(row, rank_col_rule_is_get, nx_widestr(1))
  end
end
function on_btn_rank_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.textgrid_rank:ClearSelect()
  form.btn_rank_get.Enabled = false
  form.rank_select_guanid = -1
  if btn.click_times % 2 == 0 then
    form.textgrid_rank:SortRowsByInt(btn.sort_id, btn.bGreater)
    form.rank_sort_col = btn.colour_col
  else
    form.textgrid_rank:SortRowsByInt(btn.default_sort_id, false)
    form.rank_sort_col = -1
  end
  btn.click_times = btn.click_times + 1
  refresh_rank_color(form)
end
function on_textgrid_rank_mousein_row_changed(self, new_row, old_row)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rank_capture_row = new_row
  refresh_rank_tips_info(self)
end
function on_textgrid_rank_mousein_col_changed(self, new_col, old_col)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rank_capture_col = new_col
  refresh_rank_tips_info(self)
end
function on_textgrid_rank_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function refresh_rank_tips_info(rank_grid)
  local form = rank_grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local show_tips = false
  local grid_text = nx_widestr("0")
  local show_add = nx_widestr("")
  if 0 <= form.rank_capture_row then
    if form.rank_capture_col == rank_col_last_week then
      grid_text = form.textgrid_rank:GetGridText(form.rank_capture_row, rank_col_rule_best)
      show_add = gui.TextManager:GetText("ui_tipsshuoming1")
      show_tips = true
    elseif form.rank_capture_col == rank_col_my_score then
      grid_text = form.textgrid_rank:GetGridText(form.rank_capture_row, rank_col_rule_time)
      show_add = gui.TextManager:GetText("ui_tipsshuoming2")
      show_tips = true
    else
      show_tips = false
    end
  else
    show_tips = false
  end
  if show_tips then
    local x, y = gui:GetCursorPosition()
    if grid_text ~= nx_widestr("0") then
      local times = nx_number(grid_text)
      local hours = nx_int(times / 3600)
      local mins = nx_int((times - hours * 3600) / 60)
      local secs = nx_int(times - hours * 3600 - mins * 60)
      local show_text = nx_widestr("")
      if hours > nx_int(0) then
        gui.TextManager:Format_SetIDName(time_text_id[1])
        gui.TextManager:Format_AddParam(nx_int(hours))
        gui.TextManager:Format_AddParam(nx_int(mins))
        gui.TextManager:Format_AddParam(nx_int(secs))
        show_text = gui.TextManager:Format_GetText()
      else
        gui.TextManager:Format_SetIDName(time_text_id[2])
        gui.TextManager:Format_AddParam(nx_int(mins))
        gui.TextManager:Format_AddParam(nx_int(secs))
        show_text = gui.TextManager:Format_GetText()
      end
      nx_execute("tips_game", "show_text_tip", show_add .. show_text, x, y, 0, form)
    else
      nx_execute("tips_game", "hide_tip", form)
    end
  else
    nx_execute("tips_game", "hide_tip", form)
  end
end
function on_imagegrid_rank_reward_item_get_capture(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local x, y = gui:GetCursorPosition()
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(self.item_id)
    item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(self.item_id), "ItemType", "0")
    nx_execute("tips_game", "show_goods_tip", item, x, y, 40, 40, self.ParentForm)
  end
end
function on_imagegrid_rank_reward_item_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_imagegrid_rank_title_item_get_capture(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(self.title_text), x, y, 0, self.ParentForm)
end
function on_imagegrid_rank_title_item_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_btn_rank_apply_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local apply_time_val = nx_number(os.time()) - form.rank_repeat_time
  if apply_time_val < 2 then
    local repeat_show_text = gui.TextManager:GetText("ui_rank_baoming8")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(repeat_show_text, CENTERINFO_PERSONAL_NO)
    end
    return 0
  end
  form.rank_repeat_time = nx_number(os.time())
  local guan_id = nx_number(btn.DataSource)
  if nx_number(form.rank_apply_guanid) ~= guan_id then
    local applyer_1 = 40
    local applyer_2 = 50
    local guan_id = nx_number(btn.DataSource)
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return 0
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local apply_count = get_apply_count(form, guan_id)
    if applyer_2 <= nx_number(apply_count) then
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_APPLY_RANK, guan_id, 0)
    elseif applyer_1 <= nx_number(apply_count) then
      local text = gui.TextManager:GetText("ui_tiguan_rank_apply_2")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" then
        nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_APPLY_RANK, guan_id, 1)
      end
    else
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_APPLY_RANK, guan_id, 0)
    end
  else
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_CANCE_RANK, guan_id)
  end
end
function get_apply_count(form, guan_id)
  local apply_count = 0
  local row_count = form.textgrid_rank.RowCount
  for i = 0, row_count - 1 do
    local rank_guan_id = nx_number(form.textgrid_rank:GetGridText(i, rank_col_rule_guan_id))
    if guan_id == rank_guan_id then
      apply_count = nx_number(form.textgrid_rank:GetGridText(i, rank_col_apply_num))
      break
    end
  end
  return apply_count
end
function on_rbtn_skill_checked_changed(cbtn)
  if not cbtn.Checked then
    return 0
  end
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.groupbox_skill_introduce.Visible = false
  form.groupscrollbox_3.Visible = false
  if cbtn.skill_type == 1 then
    form.groupbox_skill_introduce.Visible = true
    form.imagegrid_1:AddItem(0, SKILL_BACKIMAGE, "", 1, -1)
  else
    form.groupscrollbox_3.Visible = true
    refresh_skill_info(form)
  end
end
function refresh_skill_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local tiguan_one_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(tiguan_one_ini) then
    return 0
  end
  local index = tiguan_one_ini:FindSectionIndex("skill")
  if index < 0 then
    return 0
  end
  form.groupscrollbox_3.IsEditMode = true
  form.groupscrollbox_3:DeleteAll()
  local skill_tab = tiguan_one_ini:GetItemValueList(index, "r")
  local count = table.getn(skill_tab)
  local j = 1
  local groupbox
  for i = 1, count do
    local append_info = util_split_string(nx_string(skill_tab[i]), ",")
    if table.getn(append_info) == 3 then
      local col = j % 6
      j = j + 1
      local groupbox_sub
      if col == 1 then
        groupbox = create_ctrl("GroupBox", "gbox_skill_eh_" .. nx_string(i), form.groupbox_5, form.groupscrollbox_3)
        groupbox_sub = create_ctrl("GroupBox", "groupbox_skill_sub_" .. nx_string(i), form.groupbox_skill_tmp_eh1, groupbox)
      elseif col == 2 then
        groupbox_sub = create_ctrl("GroupBox", "groupbox_skill_sub_" .. nx_string(i), form.groupbox_skill_tmp_eh2, groupbox)
      elseif col == 3 then
        groupbox_sub = create_ctrl("GroupBox", "groupbox_skill_sub_" .. nx_string(i), form.groupbox_skill_tmp_eh3, groupbox)
      elseif col == 4 then
        groupbox_sub = create_ctrl("GroupBox", "groupbox_skill_sub_" .. nx_string(i), form.groupbox_skill_tmp_eh4, groupbox)
      elseif col == 5 then
        groupbox_sub = create_ctrl("GroupBox", "groupbox_skill_sub_" .. nx_string(i), form.groupbox_skill_tmp_eh5, groupbox)
      else
        groupbox_sub = create_ctrl("GroupBox", "groupbox_skill_sub_" .. nx_string(i), form.groupbox_skill_tmp_eh6, groupbox)
      end
      local cbtn_back = create_ctrl("CheckButton", "cbtn_skill_sub_back_" .. nx_string(i), form.cbtn_skill_tmp_back1, groupbox_sub)
      local imagegrid = create_ctrl("ImageGrid", "imagegrid_skill_sub_eh_" .. nx_string(i), form.imagegrid_skill_tmp_eh1, groupbox_sub)
      local mltbox_skill_tmp_name = create_ctrl("MultiTextBox", "mltbox_skill_tmp_name_" .. nx_string(i), form.mltbox_skill_tmp_name, groupbox_sub)
      nx_bind_script(cbtn_back, nx_current())
      nx_callback(cbtn_back, "on_click", "on_cbtn_skill_back_click")
      imagegrid:AddItem(0, append_info[2], "", 1, -1)
      imagegrid.RowNum = 1
      imagegrid.ClomnNum = 1
      imagegrid.GridWidth = imagegrid.Width - 10
      imagegrid.GridHeight = imagegrid.Height - 10
      imagegrid.DrawMode = "Expand"
      nx_bind_script(imagegrid, nx_current())
      nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_skill_eh_mousein_grid")
      nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_skill_eh_mouseout_grid")
      imagegrid.skill_id = append_info[1]
      mltbox_skill_tmp_name:Clear()
      mltbox_skill_tmp_name:AddHtmlText(gui.TextManager:GetText(nx_string(append_info[3])), -1)
      posx = (mltbox_skill_tmp_name.Width - mltbox_skill_tmp_name:GetContentWidth()) / 2
      mltbox_skill_tmp_name.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
    end
  end
  form.groupscrollbox_3.IsEditMode = false
  form.groupscrollbox_3:ResetChildrenYPos()
  form.groupscrollbox_3.Visible = true
end
function on_cbtn_skill_back_click(cbtn)
  cbtn.Checked = false
end
function on_imagegrid_skill_eh_mousein_grid(self, index)
  local config_id = self.skill_id
  local ITEMTYPE_ZHAOSHI = 1000
  if config_id ~= "" then
    local IniManager = nx_value("IniManager")
    local ini = IniManager:LoadIniToManager("share\\Skill\\skill_new.ini")
    if not nx_is_valid(ini) then
      return
    end
    local index = ini:FindSectionIndex(nx_string(config_id))
    if nx_number(index) < 0 then
      return
    end
    local static_data = ini:ReadString(index, "StaticData", "")
    local item_data = nx_execute("tips_game", "get_tips_ArrayList")
    item_data.ConfigID = nx_string(config_id)
    item_data.ItemType = nx_int(ITEMTYPE_ZHAOSHI)
    item_data.Level = 1
    item_data.SkillMaxLevel = 1
    item_data.StaticData = nx_int(static_data)
    nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
  end
end
function on_imagegrid_skill_eh_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function open_form()
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "custom_open_limite_form", nx_int(2))
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tiguan\\form_tiguan_one", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_npc_talk(guan_id, npc_name)
  local changguanini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if nx_is_valid(changguanini) then
    local index = changguanini:FindSectionIndex(nx_string(guan_id))
    if 0 <= index then
      local grps = changguanini:GetItemValueList(index, "Group")
      for i = 1, table.getn(grps) do
        local data_tab = util_split_string(nx_string(grps[i]), ",")
        if nx_string(data_tab[2]) == nx_string(npc_name) then
          return data_tab[1]
        end
      end
    end
  end
  return
end
function get_boss_arrest_level_by_id(guan_id, boss_id)
  local ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(guan_id))
  if index < 0 then
    return 0
  end
  local boss_list = ini:ReadString(index, "BossList", "")
  local boss_tab = util_split_string(boss_list, ";")
  local boss_count = table.getn(boss_tab)
  local boss_index = 0
  for i = 1, boss_count do
    if nx_string(boss_tab[i]) == nx_string(boss_id) then
      boss_index = nx_number(i)
      break
    end
  end
  if boss_index ~= 0 then
    return get_boss_arrest_level(guan_id, boss_index)
  else
    return 0
  end
end
function get_boss_arrest_level(guan_id, boss_index)
  local ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(ini) then
    return ""
  end
  boss_index = nx_number(boss_index)
  local sec_index = ini:FindSectionIndex(nx_string(guan_id))
  local str_id = ini:ReadString(sec_index, "BossLevel", "")
  local level_tab = util_split_string(str_id, ",")
  if boss_index < 1 or boss_index > table.getn(level_tab) then
    return 0
  end
  return level_tab[boss_index]
end
function get_boss_id(guan_id, boss_index)
  local ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(guan_id))
  local str_id = ini:ReadString(sec_index, "BossList", "")
  local id_tab = util_split_string(str_id, ";")
  if boss_index < 1 or boss_index > table.getn(id_tab) then
    return ""
  end
  return id_tab[boss_index]
end
function get_boss_id_list(guan_id)
  local ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(ini) then
    return nil
  end
  local sec_index = ini:FindSectionIndex(nx_string(guan_id))
  local str_id = ini:ReadString(sec_index, "BossList", "")
  return util_split_string(str_id, ";")
end
function CalculateGuanBossCount(guan_id)
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local ui_ini = form.guan_ui_ini
  if not nx_is_valid(ui_ini) then
    return 0
  end
  guan_id = nx_string(guan_id)
  local boss_value = nx_number(get_achieve_record(guan_id, "boss_value"))
  local boss_count_all = 0
  if 0 < boss_value then
    local tiguan_manager = nx_value("tiguan_manager")
    if not nx_is_valid(tiguan_manager) then
      return 0
    end
    local boss_list = get_boss_id_list(nx_string(guan_id))
    if boss_list ~= nil then
      local boss_count = table.getn(boss_list)
      for i = 1, boss_count do
        local boss_id = nx_string(boss_list[i])
        local info = tiguan_manager:bit_and(nx_number(boss_value), 2 ^ i)
        if 0 < info then
          boss_count_all = boss_count_all + 1
        end
      end
    end
  end
  return boss_count_all
end
function CalculateLevelGuanBossCount(guan_level)
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local tiguan_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(tiguan_ini) then
    return 0
  end
  local guan_ui_ini = form.guan_ui_ini
  if not nx_is_valid(guan_ui_ini) then
    return 0
  end
  local boss_count_all = 0
  local section_count = tiguan_ini:GetSectionCount()
  for i = 1, section_count do
    local Section = tiguan_ini:GetSectionByIndex(i - 1)
    local Level = tiguan_ini:ReadInteger(i - 1, "Level", 0)
    local guan_id = nx_string(Section)
    if nx_number(get_achieve_record(guan_id, "boss_value")) ~= 0 and nx_number(guan_level) == nx_number(Level) then
      boss_count_all = boss_count_all + CalculateGuanBossCount(guan_id)
    end
  end
  return boss_count_all
end
function FindBossBeBeat(guan_id, boss_id)
  local form = util_get_form(FORM_TIGUAN_ONE, false)
  if not nx_is_valid(form) then
    return false
  end
  local ui_ini = form.guan_ui_ini
  if not nx_is_valid(ui_ini) then
    return false
  end
  guan_id = nx_string(guan_id)
  local bBeatBoss = false
  local boss_value = nx_number(get_achieve_record(guan_id, "boss_value"))
  if 0 < boss_value then
    local tiguan_manager = nx_value("tiguan_manager")
    if not nx_is_valid(tiguan_manager) then
      return 0
    end
    local boss_list = get_boss_id_list(nx_string(guan_id))
    if boss_list ~= nil then
      local boss_count = table.getn(boss_list)
      for i = 1, boss_count do
        local ini_boss_id = nx_string(boss_list[i])
        local info = tiguan_manager:bit_and(nx_number(boss_value), 2 ^ i)
        if 0 < info and ini_boss_id == nx_string(boss_id) then
          bBeatBoss = true
        end
      end
    end
  end
  return bBeatBoss
end
function FindBossBeArrest(boss_id, level)
  if nx_number(level) > nx_number(tiguan_level_max) then
    return false
  end
  local bExist = false
  for i = 1, tiguan_arrest_max do
    local record_boss_id = nx_string(get_arrest_data(level, i, 2))
    if record_boss_id == nx_string(boss_id) and record_boss_id ~= "" then
      bExist = true
    end
  end
  return bExist
end
function IsCompleteAchieve(achieve_id)
  if achieve_data == nil then
    return 0
  end
  local tiguan_manager = nx_value("tiguan_manager")
  if not nx_is_valid(tiguan_manager) then
    return 0
  end
  local achieve_index = nx_number(achieve_id)
  local rows = nx_number(nx_int(achieve_index / 32)) + 1
  local cols = achieve_index % 32
  if 3 < rows or rows <= 0 then
    return 0
  end
  local num = tiguan_manager:CheckBitFlag(nx_number(achieve_data[rows][1]), cols)
  return num
end
function set_tiguan_record(array_name, child_name, value)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  array_name = nx_string(array_name)
  child_name = nx_string(child_name)
  local is_exist = common_array:FindArray(array_name)
  if not is_exist then
    common_array:AddArray(array_name, nx_current(), common_array_time, false)
  end
  common_array:RemoveChild(array_name, child_name)
  common_array:AddChild(array_name, child_name, value)
end
function get_tiguan_record(array_name, child_name)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return ""
  end
  array_name = nx_string(array_name)
  child_name = nx_string(child_name)
  local is_exist = common_array:FindArray(array_name)
  if is_exist then
    local value = common_array:FindChild(array_name, child_name)
    if value ~= nil then
      return value
    end
  end
  return ""
end
function get_arrest_data(array_level, child_index, data_index)
  local str_data = get_tiguan_record("tiguan_arrest" .. nx_string(array_level), "arrest_data" .. nx_string(child_index))
  local data_tab = util_split_string(str_data, ",")
  local data_count = table.getn(data_tab)
  data_index = nx_number(data_index)
  if data_count < data_index or data_index <= 0 then
    return ""
  end
  return data_tab[data_index]
end
function set_achieve_record(guan_id, name, value)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  local array_name = "tiguan" .. nx_string(guan_id)
  local is_exist = common_array:FindArray(array_name)
  if not is_exist then
    common_array:AddArray(array_name, nx_current(), common_array_time, false)
  end
  common_array:RemoveChild(array_name, nx_string(name))
  common_array:AddChild(array_name, nx_string(name), value)
end
function get_achieve_record(guan_id, name)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return ""
  end
  local array_name = "tiguan" .. nx_string(guan_id)
  local is_exist = common_array:FindArray(array_name)
  if is_exist then
    local value = common_array:FindChild(array_name, nx_string(name))
    if value ~= nil then
      return value
    end
  end
  return ""
end
function clear_tiguan_record()
  local tiguan_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(tiguan_ini) then
    return 0
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  for i = 1, tiguan_level_max do
    local array_name = "tiguan_arrest" .. nx_string(i)
    local is_exist = common_array:FindArray(array_name)
    if not is_exist then
      common_array:RemoveArray(array_name)
    end
  end
  for i = 1, tiguan_level_max do
    for j = 1, tiguan_challenge_task_max do
      local array_name = "guan" .. nx_string(i) .. "sub" .. nx_string(j)
      local is_exist = common_array:FindArray(array_name)
      if not is_exist then
        common_array:RemoveArray(array_name)
      end
    end
  end
  local section_count = tiguan_ini:GetSectionCount()
  for i = 1, section_count do
    local Section = tiguan_ini:GetSectionByIndex(i - 1)
    local array_name = "tiguan" .. nx_string(Section)
    common_array:RemoveArray(array_name)
  end
end
function reset_arrest_info(level)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  if nx_number(level) > tiguan_level_max or level <= 0 then
    return 0
  end
  for j = 1, tiguan_challenge_task_max do
    local array_name = "guan" .. nx_string(level) .. "sub" .. nx_string(j)
    local is_exist = common_array:FindArray(array_name)
    if not is_exist then
      common_array:AddArray(array_name, nx_current(), common_array_time, false)
    end
    common_array:RemoveChild(array_name, "value1")
    common_array:AddChild(array_name, "value1", 0)
    common_array:RemoveChild(array_name, "value7")
    common_array:AddChild(array_name, "value7", 0)
  end
end
function get_flick_item_index()
  local tiguan_one_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(tiguan_one_ini) then
    return -1
  end
  local keep_index = tiguan_one_ini:FindSectionIndex("expand_node")
  local flicker = tiguan_one_ini:ReadInteger(keep_index, "flicker", -1)
  return flicker
end
function get_aotu_expand_node()
  local tiguan_one_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(tiguan_one_ini) then
    return -1
  end
  local keep_index = tiguan_one_ini:FindSectionIndex("expand_node")
  local expand = tiguan_one_ini:ReadInteger(keep_index, "expand", -1)
  return expand
end
