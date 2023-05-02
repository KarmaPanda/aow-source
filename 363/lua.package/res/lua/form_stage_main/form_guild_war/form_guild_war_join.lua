require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\static_data_type")
require("share\\itemtype_define")
require("define\\tip_define")
require("util_static_data")
require("tips_data")
require("util_functions")
require("role_composite")
local CLIENT_CUSTOMMSG_GUILD_CROSS_WAR = 776
local CTS_GCW_REQUEST_JOIN = 1
local CTS_GCW_REQUEST_ENTER = 2
local CTS_GCW_REQUEST_OPEN_FORM = 8
local CTS_GCW_TAKE_PRIZE = 9
local RD_GCW_BASE_INFO_DATA = 1
local RD_GCW_GUILD_INFO_DATA = 2
local RD_GCW_PLAYER_INFO_DATA = 3
local RD_GCW_EVENT_LOG_DATA = 4
local RD_GCW_GUILD_ACCOMPLISH_DATA = 5
local RD_GCW_PLAYER_ACCOMPLISH_DATA = 6
local SDT_GCW_BASE_INFO_DATA = 1
local SDT_GUILD_EVENT_LOG_DATA = 2
local SDT_GUILD_ACCOMPLISH_DATA = 3
local SDT_GUILD_SCORE_RANK_DATA = 4
local SDT_PLAYER_DATA = 5
local SDT_PLAYER_ACCOMPLISH_DATA = 6
local SDT_PLAYER_SCORE_RANK_DATA = 7
local SDT_PLAYER_TAKE_PRIZE = 8
local GCW_EVENT_WIN = 1
local GCW_EVENT_FAILED = 2
local GCW_EVENT_STEP_FOREWARD = 3
local ACCOMPLISH_PER_PAGE_NUM = 6
local COL_COUNT = 3
local RANK_DATA_COL_COUNT = 7
local ImagePath = "gui\\guild\\guild_kuafu\\"
local GUILD_KUAFU_GUILD_JIFEN_RANK_NAME = "rank_5_guild_kuafu_guild_jf"
local GUILD_KUAFU_PLAYER_JIFEN_RANK_NAME = "rank_5_guild_kuafu_player_jf"
local CLIENT_CUSTOMMSG_WORLD_RANK = 198
local SUB_CLIENT_CHECK = 1
local SUB_CLIENT_QUERY = 2
local SERVER_USE_CAHCE = 1
local SERVER_CLEAR_CAHCE = 2
local SERVER_NEW_DATA = 3
local GUILD_CAPTAIN_COUNT = 8
function on_main_form_init(self)
  self.Fixed = false
  self.page_index = 1
  self.max_page_index = 1
  self.guild_page_index = 1
  self.person_page_index = 1
  self.rank_name = ""
  self.rank_rows = 0
  self.self_row = -1
  self.rank_string = ""
  local cache_list = nx_value("Cache_Guild_war_Rank")
  if not nx_is_valid(cache_list) then
    self.cache_list = nx_call("util_gui", "get_global_arraylist", "Cache_Guild_war_Rank")
    init_rank_cache(self.cache_list)
  else
    self.cache_list = cache_list
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_BASE_INFO_DATA)
  show_self(self)
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "close_form")
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.page_index = 1
  form.max_page_index = 1
  form.guild_page_index = 1
  form.person_page_index = 1
  form:Close()
end
function close_form()
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form()
  local form = util_get_form("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_join", true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function on_btn_request_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_CROSS_WAR), nx_int(CTS_GCW_REQUEST_JOIN))
end
function on_btn_enter_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_CROSS_WAR), nx_int(CTS_GCW_REQUEST_ENTER))
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText("1000363")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(info, 2)
  end
end
function on_rec_guild_cross_war_score(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_join")
  if not nx_is_valid(form) then
    return
  end
  local score = arg[1]
  if nx_number(score) < nx_number(0) then
    score = 0
  end
  if nx_number(lbl_score) < nx_number(0) then
    form.lbl_score.Text = nx_widestr(0)
  else
    form.lbl_score.Text = nx_widestr(remain_money)
  end
end
function request_form_data(request_id, page_data, page_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  nx_execute("custom_sender", "custom_cross_guild_war", nx_int(request_id), nx_int(page_data), nx_int(page_index))
end
function manager_form_data(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  local data_index = nx_int(arg[1])
  if nx_int(data_index) == nx_int(SDT_GCW_BASE_INFO_DATA) then
    refresh_assign_form(unpack(arg))
    return 0
  end
  if nx_int(data_index) == nx_int(SDT_GUILD_EVENT_LOG_DATA) then
    refresh_guild_fight_result_log_form(unpack(arg))
    return 0
  end
  if nx_int(data_index) == nx_int(SDT_GUILD_ACCOMPLISH_DATA) then
    refresh_guild_accomplish_data(unpack(arg))
    return 0
  end
  if nx_int(data_index) == nx_int(SDT_PLAYER_DATA) then
    refresh_person_fight_result(unpack(arg))
    return 0
  end
  if nx_int(data_index) == nx_int(SDT_PLAYER_ACCOMPLISH_DATA) then
    refresh_person_accomplish_data(1, unpack(arg))
    return 0
  end
  if nx_int(data_index) == nx_int(SDT_PLAYER_TAKE_PRIZE) then
    show_lbl_accomplish_prize_state(unpack(arg))
    return 0
  end
end
function refresh_assign_form(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if table.getn(arg) < 9 then
    return 0
  end
  local guild_step = nx_int(arg[2])
  local guild_name = nx_string(arg[3])
  local guild_victory_times = nx_int(arg[4])
  local guild_score64 = nx_int64(arg[5])
  local guild_status = nx_int(arg[6])
  local guild_total_join_times = nx_int(arg[7])
  local guild_captain_level = nx_int(arg[8])
  local active_value = nx_int(arg[9])
  form.lbl_6.BackImage = ImagePath .. nx_string(guild_step) .. ".png"
  form.lbl_23.BackImage = ImagePath .. nx_string(guild_step) .. ".png"
  form.lbl_11.Text = nx_widestr(guild_name)
  form.lbl_28.Text = nx_widestr(guild_name)
  form.lbl_12.Text = nx_widestr(guild_victory_times)
  form.lbl_30.Text = nx_widestr(guild_victory_times)
  form.lbl_13.Text = nx_widestr(guild_score64)
  form.lbl_20.Text = nx_widestr(guild_score64)
  form.lbl_29.Text = nx_widestr(guild_total_join_times)
  local text_guild = "ui_guildwar_kuafu_zhuangtai_" .. nx_string(guild_status)
  form.lbl_4.Text = gui.TextManager:GetFormatText(text_guild)
  if 0 >= nx_number(guild_captain_level) then
    guild_captain_level = GUILD_CAPTAIN_COUNT
  end
  text_guild = "ui_guild_pos_level" .. nx_string(guild_captain_level) .. "_name"
  form.lbl_pos.Text = gui.TextManager:GetFormatText(text_guild)
  form.lbl_act.Text = nx_widestr(active_value)
end
function refresh_person_fight_result(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if table.getn(arg) < 8 then
    return 0
  end
  local join_times = nx_int(arg[2])
  local win_times = nx_int(arg[3])
  local score = nx_int(arg[4])
  local kill_count = nx_int(arg[5])
  local pull_flag_count = nx_int(arg[6])
  local singel_max_score = nx_int(arg[7])
  local singel_kill_count = nx_int(arg[8])
  form.lbl_62.Text = nx_widestr(join_times)
  form.lbl_63.Text = nx_widestr(win_times)
  form.lbl_64.Text = nx_widestr(score)
  form.lbl_66.Text = nx_widestr(kill_count)
  form.lbl_57.Text = nx_widestr(pull_flag_count)
  form.lbl_93.Text = nx_widestr(singel_max_score)
  form.lbl_95.Text = nx_widestr(singel_kill_count)
  refresh_person_accomplish_data(8, unpack(arg))
end
function refresh_guild_accomplish_data(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local cross_war_manager = nx_value("GuildCrossWarManager")
  if not nx_is_valid(cross_war_manager) then
    return
  end
  local lbl_count = nx_int(cross_war_manager:GetEffortSize(0)) - nx_int(ACCOMPLISH_PER_PAGE_NUM) * (form.guild_page_index - 1)
  if nx_int(lbl_count) <= nx_int(0) then
    return 0
  end
  if nx_int(lbl_count) > nx_int(ACCOMPLISH_PER_PAGE_NUM) then
    lbl_count = nx_int(ACCOMPLISH_PER_PAGE_NUM)
  end
  if table.getn(arg) < nx_number(lbl_count) + 1 then
    return 0
  end
  for i = 1, nx_number(lbl_count) do
    local para_value = nx_int(arg[i + 1])
    show_lbl_accomplish(form, gui, 0, form.guild_page_index - 1, "groupbox_guild", para_value, i)
  end
  if nx_int(lbl_count) < nx_int(ACCOMPLISH_PER_PAGE_NUM) then
    for j = nx_number(lbl_count + 1), nx_number(ACCOMPLISH_PER_PAGE_NUM) do
      hide_group_accomplish(form, "groupbox_guild", j)
    end
  end
  form.lbl_52.Text = nx_widestr(form.guild_page_index) .. nx_widestr("/") .. nx_widestr(get_accomplish_page_max(0))
end
function refresh_person_accomplish_data(index, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local cross_war_manager = nx_value("GuildCrossWarManager")
  if not nx_is_valid(cross_war_manager) then
    return
  end
  local lbl_count = nx_int(cross_war_manager:GetEffortSize(1)) - nx_int(ACCOMPLISH_PER_PAGE_NUM) * (form.person_page_index - 1)
  if nx_int(lbl_count) <= nx_int(0) then
    return 0
  end
  if nx_int(lbl_count) > nx_int(ACCOMPLISH_PER_PAGE_NUM) then
    lbl_count = nx_int(ACCOMPLISH_PER_PAGE_NUM)
  end
  if table.getn(arg) < nx_int(index) + nx_number(lbl_count) then
    return 0
  end
  for i = 1, nx_number(lbl_count) do
    local arg_index = nx_int(index) + i
    local para_value = nx_int(arg[arg_index])
    show_lbl_accomplish(form, gui, 1, form.person_page_index - 1, "groupbox_person", para_value, i)
  end
  if nx_int(lbl_count) < nx_int(ACCOMPLISH_PER_PAGE_NUM) then
    for j = nx_number(lbl_count + 1), nx_number(ACCOMPLISH_PER_PAGE_NUM) do
      hide_group_accomplish(form, "groupbox_person", j)
    end
  end
  form.lbl_35.Text = nx_widestr(form.person_page_index) .. nx_widestr("/") .. nx_widestr(get_accomplish_page_max(1))
end
function show_lbl_accomplish(form, gui, accomplish_id, page_index, group_type, para_value, lbl_id)
  local cross_war_manager = nx_value("GuildCrossWarManager")
  if not nx_is_valid(cross_war_manager) then
    return
  end
  local accomplish_key = cross_war_manager:GetEffortKey(nx_int(accomplish_id)) + lbl_id - 1
  local lbl_accomplish_id = nx_int(accomplish_key + page_index * ACCOMPLISH_PER_PAGE_NUM)
  local accomplish_table = {}
  accomplish_table = cross_war_manager:GetEffortData(nx_int(accomplish_id), nx_int(lbl_accomplish_id))
  local length = table.getn(accomplish_table)
  if length < 9 then
    return 0
  end
  local group_name = nx_string(group_type) .. "_group_" .. nx_string(lbl_id)
  local gb1 = form:Find(group_type)
  if not nx_is_valid(gb1) then
    return 0
  end
  local gb2 = gb1:Find(group_name)
  if not nx_is_valid(gb2) then
    return 0
  end
  gb2.Visible = true
  local lbl_name = nx_string(group_type) .. "_lbl_title_" .. nx_string(lbl_id)
  local lbl_control = gb2:Find(lbl_name)
  if not nx_is_valid(lbl_control) then
    return 0
  end
  local strText = accomplish_table[6]
  lbl_control.Text = gui.TextManager:GetFormatText(nx_string(strText))
  lbl_name = nx_string(group_type) .. "_lbl_content_" .. nx_string(lbl_id)
  lbl_control = gb2:Find(lbl_name)
  if not nx_is_valid(lbl_control) then
    return 0
  end
  strText = accomplish_table[7]
  lbl_control.Text = gui.TextManager:GetFormatText(nx_string(strText))
  lbl_name = nx_string(group_type) .. "_lbl_tips_" .. nx_string(lbl_id)
  lbl_control = gb2:Find(lbl_name)
  if not nx_is_valid(lbl_control) then
    return 0
  end
  strText = accomplish_table[8]
  lbl_control.Text = gui.TextManager:GetFormatText(nx_string(strText))
  lbl_name = nx_string(group_type) .. "_lbl_value_" .. nx_string(lbl_id)
  lbl_control = gb2:Find(lbl_name)
  if not nx_is_valid(lbl_control) then
    return 0
  end
  local para_max = accomplish_table[4]
  if nx_int(para_value) > nx_int(0) then
    if nx_int(para_max) > nx_int(0) then
      lbl_control.Text = nx_widestr(para_value) .. nx_widestr("/") .. nx_widestr(para_max)
    else
      lbl_control.Text = nx_widestr(para_value)
    end
  else
    lbl_control.Text = gui.TextManager:GetFormatText("ui_guild_war_kuafu_paiming_09")
  end
  lbl_name = nx_string(group_type) .. "_lbl_got_" .. nx_string(lbl_id)
  lbl_control = gb2:Find(lbl_name)
  if not nx_is_valid(lbl_control) then
    return 0
  end
  lbl_control.Visible = false
  if cross_war_manager:IsHaveGetPrize(nx_int(lbl_accomplish_id)) then
    lbl_control.Visible = true
  end
  local btn_name = nx_string(group_type) .. "_btn_" .. nx_string(lbl_id)
  local btn_control = gb2:Find(btn_name)
  if not nx_is_valid(btn_control) then
    return 0
  end
  btn_control.Enabled = true
  if lbl_control.Visible then
    btn_control.Enabled = false
  end
  btn_control.TabIndex = accomplish_table[9]
  local btn_quality_id = accomplish_table[3]
  btn_control.NormalImage = "gui\\guild\\guild_kuafu\\btn_" .. nx_string(btn_quality_id) .. "_out.png"
  btn_control.FocusImage = "gui\\guild\\guild_kuafu\\btn_" .. nx_string(btn_quality_id) .. "_on.png"
  btn_control.PushImage = "gui\\guild\\guild_kuafu\\btn_" .. nx_string(btn_quality_id) .. "_down.png"
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local config_id = accomplish_table[5]
  local imagegrid_name = nx_string(group_type) .. "_imagegrid_" .. nx_string(lbl_id)
  local imagegrid = gb2:Find(imagegrid_name)
  if not nx_is_valid(imagegrid) then
    return 0
  end
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(config_id), "Photo")
  imagegrid:Clear()
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    if nx_find_custom(imagegrid, "item_data") and nx_is_valid(imagegrid.item_data) then
      GoodsGrid:GridDelItem(imagegrid, imagegrid.item_data)
    end
    local item_data = nx_create("ArrayList", "item_data:" .. nx_current())
    item_data.ConfigID = config_id
    item_data.Count = 1
    item_data.item_type = 2102
    imagegrid.item_data = item_data
    GoodsGrid:GridAddItem(imagegrid, 0, item_data)
    imagegrid:SetBindIndex(0, 1)
  end
  imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), 0, 0)
end
function hide_group_accomplish(form, group_type, lbl_id)
  local group_name = nx_string(group_type) .. "_group_" .. nx_string(lbl_id)
  local guild_group_box
  if form.groupbox_guild.Visible then
    guild_group_box = form.groupbox_guild:Find(group_name)
  elseif form.groupbox_person.Visible then
    guild_group_box = form.groupbox_person:Find(group_name)
  end
  if not nx_is_valid(guild_group_box) then
    return 0
  end
  guild_group_box.Visible = false
end
function show_lbl_accomplish_prize_state(...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  local cross_war_manager = nx_value("GuildCrossWarManager")
  if not nx_is_valid(cross_war_manager) then
    return 0
  end
  if nx_int(table.getn(arg)) < nx_int(2) then
    return 0
  end
  local accomplish_id = nx_int(arg[2])
  local tab_index = nx_int(arg[3])
  local page_id, group_type
  if nx_int(accomplish_id) == nx_int(1) and form.groupbox_guild.Visible then
    group_type = "groupbox_guild"
    page_id = form.guild_page_index
    accomplish_id = 0
  end
  if nx_int(accomplish_id) == nx_int(2) and form.groupbox_person.Visible then
    group_type = "groupbox_person"
    page_id = form.person_page_index
    accomplish_id = 1
  end
  if nil == group_type then
    return 0
  end
  local gb1 = form:Find(group_type)
  if not nx_is_valid(gb1) then
    return 0
  end
  local accomplish_key = cross_war_manager:GetEffortKey(nx_int(accomplish_id))
  local i = tab_index - accomplish_key + 1 - ACCOMPLISH_PER_PAGE_NUM * (page_id - 1)
  local group_name = nx_string(group_type) .. "_group_" .. nx_string(i)
  local lbl_name = nx_string(group_type) .. "_lbl_got_" .. nx_string(i)
  local btn_name = nx_string(group_type) .. "_btn_" .. nx_string(i)
  local gb2 = gb1:Find(group_name)
  if not nx_is_valid(gb2) then
    return 0
  end
  local lbl_control = gb2:Find(lbl_name)
  if not nx_is_valid(lbl_control) then
    return 0
  end
  local btn_control = gb2:Find(btn_name)
  if not nx_is_valid(btn_control) then
    return 0
  end
  if nx_int(btn_control.TabIndex) == nx_int(tab_index) and gb2.Visible and not lbl_control.Visible then
    lbl_control.Visible = true
    btn_control.Enabled = false
    return 0
  end
end
function refresh_guild_fight_result_log_form(...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local index_arg = 2
  form.max_page_index = nx_int(arg[index_arg])
  index_arg = index_arg + 1
  local npage_index = nx_int(arg[index_arg])
  local count = (table.getn(arg) - index_arg) / 3
  if nx_int(count) == nx_int(0) then
    return 0
  end
  local log_grid = form.textgrid_1
  if not nx_is_valid(log_grid) then
    return 0
  end
  log_grid:BeginUpdate()
  log_grid:ClearRow()
  form.page_index = npage_index
  local row = 0
  for i = count, 1, -1 do
    row = log_grid:InsertRow(-1)
    local index = i * 3 + index_arg
    local score = nx_int(arg[index])
    local text_id = nx_int(arg[index - 1])
    local log_time = nx_function("get_log_time", nx_int64(arg[index - 2]))
    local time = string.sub(nx_string(log_time), 1, string.len(log_time) - 3)
    local textlog = nx_string(time)
    log_grid:SetGridText(row, 0, nx_widestr(textlog))
    if nx_int(text_id) == nx_int(GCW_EVENT_WIN) then
      textlog = gui.TextManager:GetFormatText("ui_guildwar_kuafu_rizhi_0", nx_int(score))
      log_grid:SetGridText(row, 1, nx_widestr(textlog))
    end
    if nx_int(text_id) == nx_int(GCW_EVENT_FAILED) then
      textlog = gui.TextManager:GetFormatText("ui_guildwar_kuafu_rizhi_1", nx_int(score))
      log_grid:SetGridText(row, 1, nx_widestr(textlog))
    end
    if nx_int(text_id) == nx_int(GCW_EVENT_STEP_FOREWARD) then
      local text_guild_status = "ui_guildwar_kuafu_rizhi_duanwei_" .. nx_string(score)
      textlog = gui.TextManager:GetFormatText(nx_string(text_guild_status))
      log_grid:SetGridText(row, 1, nx_widestr(textlog))
    end
  end
  log_grid:EndUpdate()
  form.lbl_54.Text = nx_widestr(form.page_index) .. nx_widestr("/") .. nx_widestr(form.max_page_index)
end
function refresh_rank(form, rank_name, rank_string)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local key_name = ""
  local rank_gird
  if rank_name == GUILD_KUAFU_GUILD_JIFEN_RANK_NAME then
    local groupbox_rank = form.groupbox_guild
    rank_gird = groupbox_rank:Find("textgrid_2")
    key_name = client_player:QueryProp("GuildName")
  elseif rank_name == GUILD_KUAFU_PLAYER_JIFEN_RANK_NAME then
    local groupbox_rank = form.groupbox_person
    rank_gird = groupbox_rank:Find("textgrid_4")
    key_name = client_player:QueryProp("Name")
  end
  if not nx_is_valid(rank_gird) then
    return 0
  end
  rank_gird:BeginUpdate()
  rank_gird:ClearRow()
  rank_gird.ColCount = COL_COUNT
  local string_table = util_split_wstring(nx_widestr(rank_string), ",")
  form.self_row = -1
  local begin_index = 1
  for row = 0, 99 do
    if begin_index + RANK_DATA_COL_COUNT > table.getn(string_table) then
      break
    end
    rank_gird:InsertRow(-1)
    local index = begin_index
    rank_gird:SetGridText(row, 0, nx_widestr(string_table[index]))
    index = begin_index + 2
    rank_gird:SetGridText(row, 1, nx_widestr(string_table[index]))
    index = begin_index + 3
    rank_gird:SetGridText(row, 2, nx_widestr(string_table[index]))
    begin_index = begin_index + RANK_DATA_COL_COUNT
    local temp_name = rank_gird:GetGridText(row, 2)
    if nx_ws_equal(nx_widestr(key_name), nx_widestr(temp_name)) then
      form.self_row = row
    end
  end
  if nx_int(form.self_row) >= nx_int(0) then
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridForeColor(form.self_row, index, "255,255,0,0")
    end
  end
  rank_gird:EndUpdate()
end
function on_btn_log_next_page_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if not form.groupbox_guild.Visible then
    return 0
  end
  local npage_index = form.page_index + 1
  if npage_index > form.max_page_index then
    return
  end
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_EVENT_LOG_DATA, nx_int(npage_index))
end
function on_btn_log_before_page_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  if not form.groupbox_guild.Visible then
    return 0
  end
  if nx_int(form.page_index) == nx_int(1) then
    return 0
  end
  local npage_index = form.page_index - 1
  if npage_index < 1 then
    return
  end
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_EVENT_LOG_DATA, nx_int(npage_index))
end
function on_btn_guild_accomplish_next_page(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  if not form.groupbox_guild.Visible then
    return 0
  end
  local page_max = get_accomplish_page_max(0)
  if nx_int(form.guild_page_index) >= nx_int(page_max) then
    return 0
  end
  form.guild_page_index = form.guild_page_index + 1
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_GUILD_ACCOMPLISH_DATA, nx_int(form.guild_page_index))
end
function on_btn_guild_accomplish_before_page(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  if not form.groupbox_guild.Visible then
    return 0
  end
  if nx_int(form.guild_page_index) == nx_int(1) then
    return 0
  end
  form.guild_page_index = form.guild_page_index - 1
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_GUILD_ACCOMPLISH_DATA, nx_int(form.guild_page_index))
end
function on_btn_person_accomplish_next_page(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  if not form.groupbox_person.Visible then
    return 0
  end
  local page_max = get_accomplish_page_max(1)
  if nx_int(form.person_page_index) >= nx_int(page_max) then
    return 0
  end
  form.person_page_index = form.person_page_index + 1
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_PLAYER_ACCOMPLISH_DATA, nx_int(form.person_page_index))
end
function on_btn_person_accomplish_before_page(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  if not form.groupbox_person.Visible then
    return 0
  end
  if nx_int(form.person_page_index) == nx_int(1) then
    return 0
  end
  form.person_page_index = form.person_page_index - 1
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_PLAYER_ACCOMPLISH_DATA, nx_int(form.person_page_index))
end
function on_btn_assign_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  if form.grpbox_cg.Visible then
    return 0
  end
  if not btn.Checked then
    return 0
  end
  form.groupbox_guild.Visible = false
  form.groupbox_person.Visible = false
  form.grpbox_cg.Visible = true
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_BASE_INFO_DATA)
  form.page_index = 1
  form.guild_page_index = 1
  form.person_page_index = 1
end
function on_btn_guild_fight_result_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  if form.groupbox_guild.Visible then
    return 0
  end
  if not btn.Checked then
    return 0
  end
  form.grpbox_cg.Visible = false
  form.groupbox_person.Visible = false
  form.groupbox_guild.Visible = true
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_GUILD_INFO_DATA)
  form.person_page_index = 1
  request_query(form, GUILD_KUAFU_GUILD_JIFEN_RANK_NAME)
end
function on_btn_person_fight_result_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  if form.groupbox_person.Visible then
    return 0
  end
  if not btn.Checked then
    return 0
  end
  form.grpbox_cg.Visible = false
  form.groupbox_guild.Visible = false
  form.groupbox_person.Visible = true
  request_form_data(CTS_GCW_REQUEST_OPEN_FORM, RD_GCW_PLAYER_INFO_DATA)
  form.page_index = 1
  form.guild_page_index = 1
  request_query(form, GUILD_KUAFU_PLAYER_JIFEN_RANK_NAME)
end
function show_self(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
  end
  local actor2 = create_scene_obj_composite(form.scenebox_1.Scene, client_player, false)
  util_add_model_to_scenebox(form.scenebox_1, actor2)
  local game_effect = nx_create("GameEffect")
  if nx_is_valid(game_effect) then
    nx_bind_script(game_effect, "game_effect", "game_effect_init", form.scenebox_1.Scene)
    form.scenebox_1.Scene.game_effect = game_effect
  end
  local terrain = form.scenebox_1.Scene:Create("Terrain")
  form.scenebox_1.Scene.terrain = terrain
end
function get_accomplish_page_max(type_id)
  local cross_war_manager = nx_value("GuildCrossWarManager")
  if not nx_is_valid(cross_war_manager) then
    return
  end
  local page_max = 0
  local lbl_count = nx_int(cross_war_manager:GetEffortSize(type_id)) / nx_int(ACCOMPLISH_PER_PAGE_NUM)
  local float_i = nx_number(lbl_count) - nx_int(lbl_count)
  if 0 < nx_number(float_i) then
    page_max = nx_int(lbl_count) + 1
  else
    page_max = nx_int(lbl_count)
  end
  return nx_int(page_max)
end
function on_btn_get_award_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if not nx_is_valid(form) then
    return 0
  end
  local cross_war_manager = nx_value("GuildCrossWarManager")
  if not nx_is_valid(cross_war_manager) then
    return
  end
  local group_type = 0
  if form.groupbox_guild.Visible then
    group_type = 1
  end
  if form.groupbox_person.Visible then
    group_type = 2
  end
  local btn_table_index = btn.TabIndex
  if cross_war_manager:IsCanGetPrizeHere(nx_int(group_type), nx_int(btn_table_index)) then
    if not show_confirm_info("ui_kuafu_item_xuanfukuang_03") then
      return 0
    end
    request_form_data(CTS_GCW_TAKE_PRIZE, nx_int(group_type), nx_int(btn_table_index))
  else
    show_confirm_info("ui_kuafu_item_xuanfukuang_04")
  end
end
function show_confirm_info(tip)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog:ShowModal()
    local text = nx_widestr(util_text(tip))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return false
    end
  end
  return true
end
function on_groupbox_person_get_capture(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  local groupbox_parent = grid.Parent
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, groupbox_parent.Left, groupbox_parent.Top, 32, 32, form)
  else
    nx_execute("tips_game", "hide_tip", form)
  end
end
function on_groupbox_person_lost_capture(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_groupbox_guild_get_capture(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  local groupbox_parent = grid.Parent
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, groupbox_parent.Left, groupbox_parent.Top, 32, 32, form)
  else
    nx_execute("tips_game", "hide_tip", form)
  end
end
function on_groupbox_guild_lost_capture(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function receive_data(...)
  if table.getn(arg) < 2 then
    return
  end
  local sub_cmd = arg[1]
  local rank_name = arg[2]
  if rank_name == nil or nx_string(rank_name) == nx_string("") then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_join", true, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_CLEAR_CAHCE) then
    on_clear_cache(form, rank_name)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_USE_CAHCE) then
    on_use_cache(form, rank_name)
    local timer = nx_value(GAME_TIMER)
    timer:Register(500, 1, nx_current(), "on_time_refresh", form, -1, -1)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_NEW_DATA) then
    local rank_rows = arg[3]
    local publish_time = arg[4]
    local rank_string = arg[5]
    on_set_cache(form, rank_name, rank_rows, publish_time, rank_string)
    on_use_cache(form, rank_name)
    local timer = nx_value(GAME_TIMER)
    timer:Register(500, 1, nx_current(), "on_time_refresh", form, -1, -1)
    return
  end
  return true
end
function on_clear_cache(form, rank_name)
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  rank_obj.total_rows = 0
  rank_obj.publish_time = -1
  rank_obj.rank_string = "null"
  return
end
function on_use_cache(form, rank_name)
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  form.rank_name = rank_name
  form.rank_rows = rank_obj.total_rows
  form.rank_string = rank_obj.rank_string
  return
end
function on_set_cache(form, rank_name, rank_rows, publish_time, rank_string)
  local rank_obj = get_cache(form, rank_name)
  if nx_is_valid(rank_obj) then
    rank_obj.total_rows = rank_rows
    rank_obj.publish_time = publish_time
    rank_obj.rank_string = rank_string
  end
  return
end
function on_time_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  refresh_rank(form, form.rank_name, form.rank_string)
end
function get_cache(form, rank_name)
  local cache = form.cache_list
  if not nx_is_valid(cache) then
    return
  end
  local obj = cache:GetChild(nx_string(rank_name))
  if not nx_is_valid(obj) then
    return
  end
  return obj
end
function init_rank_cache(cache_list)
  if not nx_is_valid(cache_list) then
    return
  end
  cache_list:ClearChild()
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return
  end
  child = cache_list:CreateChild(GUILD_KUAFU_GUILD_JIFEN_RANK_NAME)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
  child = cache_list:CreateChild(GUILD_KUAFU_PLAYER_JIFEN_RANK_NAME)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
end
function request_query(form, rank_name)
  if not nx_is_valid(form) then
    return
  end
  if rank_name == nil then
    return
  end
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  if rank_obj.rank_string ~= "null" then
    send_query_rank(SUB_CLIENT_CHECK, rank_name, rank_obj.publish_time)
  else
    send_query_rank(SUB_CLIENT_QUERY, rank_name, 0)
  end
end
function send_query_rank(sub_cmd, rank_name, publish_time)
  if sub_cmd == nil or rank_name == nil then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_RANK), nx_int(sub_cmd), nx_string(rank_name), nx_int(publish_time))
end
