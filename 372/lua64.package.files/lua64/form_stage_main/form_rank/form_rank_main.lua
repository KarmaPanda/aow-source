require("util_gui")
require("util_functions")
require("share\\client_custom_define")
local RANK_NODE_BEGIN = 1
local RANK_NODE_WUXUE = 1
local RANK_NODE_XIAYI = 2
local RANK_NODE_LIFE = 3
local RANK_NODE_CLONE = 4
local RANK_NODE_GUILD = 5
local RANK_NODE_KILLER = 6
local RANK_NODE_BATTLE = 7
local RANK_NODE_ACTIVE = 8
local RANK_NODE_JIUYINZHI = 9
local RANK_NODE_TEACH = 10
local RANK_NODE_SPEAK = 11
local RANK_NODE_MARRY = 12
local RANK_NODE_WORLDWAR = 13
local RANK_NODE_MATCH = 14
local RANK_NODE_YANXIU = 15
local RANK_NODE_HOME = 16
local RANK_NODE_END = 17
local RANK_SHOW_NODE = {
  RANK_NODE_YANXIU,
  RANK_NODE_WUXUE,
  RANK_NODE_XIAYI,
  RANK_NODE_LIFE,
  RANK_NODE_CLONE,
  RANK_NODE_GUILD,
  RANK_NODE_KILLER,
  RANK_NODE_BATTLE,
  RANK_NODE_ACTIVE,
  RANK_NODE_TEACH,
  RANK_NODE_SPEAK,
  RANK_NODE_MARRY,
  RANK_NODE_MATCH,
  RANK_NODE_HOME
}
local STAT_SELF_PROP = 1
local STAT_LIFE_LEVEL = 2
local STAT_LIFE_FORMULA = 3
local STAT_CLONE_SCORE = 4
local STAT_CLONE_COUNT = 5
local STAT_KILLER_SCORE = 8
local STAT_KILLER_COUNT = 9
local STAT_SUPER_NEIGONG = 10
local STAT_SUPER_POINT = 11
local STAT_MARRY_RANK = 12
local SUB_CLIENT_CHECK = 1
local SUB_CLIENT_QUERY = 2
local SUB_CLIENT_TITLE = 10
local SUB_CLIENT_RANK_NO = 11
local SERVER_OPEN_HORSE_RACE_RANK = 0
local SERVER_USE_CAHCE = 1
local SERVER_CLEAR_CAHCE = 2
local SERVER_NEW_DATA = 3
local RANK_NO_NAME = 4
local TYPE_PLAYER = 1
local TYPE_GUILD = 2
local TYPE_LEITAI = 3
local TYPE_LEITAI_GAME = 4
local COL_COUNT = 7
local self_form_name = "form_stage_main\\form_rank\\form_rank_main"
local HORSE_RACE_DAILY_RANK_NAME = "rank_9_horserace"
local GUILD_KUAFU_GUILD_JIFEN_RANK_NAME = "rank_5_guild_kuafu_guild_jf"
local GUILD_KUAFU_PLAYER_JIFEN_RANK_NAME = "rank_5_guild_kuafu_player_jf"
local SANMENG_RANK1 = "rank_smzb_banghui_001"
local SANMENG_RANK2 = "rank_smzb_banghui_002"
local SANMENG_RANK3 = "rank_smzb_geren_002"
local GUILDUNION_RANK_PERSON = "rank_guj_geren_002"
local GUILDUNION_RANK_WEEK = "rank_guj_banghui_001"
local GUILDUNION_RANK_SEASON = "rank_guj_banghui_002"
local PAWN_TICKET_RANK_NAME = "rank_9_ContributePawnTicket"
local CONT_WISH_RANK_NAME = "rank_9_ContributeWish"
NODE_PROP = {
  first = {
    ForeColor = "255,220,198,160",
    NodeBackImage = "gui\\common\\treeview\\tree_1_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  second = {
    ForeColor = "255,181,154,128",
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    ItemHeight = 22,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 3,
    Font = "font_treeview"
  }
}
function open_form()
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_join", "close_form")
  util_auto_show_hide_form(nx_current())
end
function main_form_init(self)
  self.Fixed = false
  self.rank_name = ""
  self.rank_rows = 0
  self.self_row = -1
  self.rank_string = ""
  local cache_list = nx_value("Cache_Rank")
  if not nx_is_valid(cache_list) then
    self.cache_list = nx_call("util_gui", "get_global_arraylist", "Cache_Rank")
    init_rank_cache(self.cache_list)
  else
    self.cache_list = cache_list
  end
end
function on_main_form_open(self)
  create_rank_tree(self)
  self.lbl_wait.Visible = false
  self.lbl_connect.Visible = false
  self.btn_search.Enabled = false
  self.btn_title.Enabled = false
  self.lbl_search_flash.Visible = false
  self.lbl_title_flash.Visible = false
  auto_select_first(self.tree_rank)
  return 1
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  util_show_form("form_stage_main\\form_rank\\form_rank_prize", false)
  nx_destroy(self)
  return
end
function close_form()
  local form = nx_value(self_form_name)
  if nx_is_valid(form) then
    form:Close()
  end
end
function create_rank_tree(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local rank_tree = form.tree_rank
  local root = rank_tree:CreateRootNode(nx_widestr(gui.TextManager:GetFormatText("ui_world_rank")))
  rank_tree:BeginUpdate()
  local second_root
  for i = RANK_NODE_BEGIN, table.getn(RANK_SHOW_NODE) do
    local second_name = gui.TextManager:GetFormatText("ui_rank_node_" .. RANK_SHOW_NODE[i])
    second_root = root:CreateNode(nx_widestr(second_name))
    second_root.rank_type = RANK_SHOW_NODE[i]
    set_node_prop(second_root, "first")
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return
  end
  local count = ini:GetSectionCount()
  for i = 1, count do
    local rank_name = ini:GetSectionByIndex(i - 1)
    if is_world_rank(rank_name) then
      local tree_node = get_rank_prop(rank_name, "TreeNode")
      if nx_string(tree_node) == nx_string("") then
        return
      end
      local second_name = gui.TextManager:GetFormatText("ui_rank_node_" .. tree_node)
      local second_root = root:FindNode(nx_widestr(second_name))
      if nx_is_valid(second_root) then
        local thrid_name = gui.TextManager:GetFormatText("ui_" .. rank_name)
        local thrid_root = second_root:CreateNode(nx_widestr(thrid_name))
        thrid_root.rank_name = rank_name
        set_node_prop(thrid_root, "second")
      end
    end
  end
  root.Expand = true
  rank_tree.IsNoDrawRoot = true
  rank_tree:EndUpdate()
  return
end
function on_tree_rank_select_changed(self, cur_node, pre_node)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(cur_node, "rank_name") then
    return
  end
  if nx_string(cur_node.rank_name) == nx_string(form.rank_name) then
    return
  end
  util_show_form("form_stage_main\\form_rank\\form_rank_prize", false)
  request_query(form, cur_node.rank_name)
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_time_refresh", form)
end
function on_btn_search_click(self)
  local form = self.Parent
  if nx_int(form.self_row) >= nx_int(0) then
    form.textgrid_rank:SelectRow(form.self_row)
  end
end
function on_btn_title_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.self_row) >= nx_int(0) then
    send_query_rank(SUB_CLIENT_TITLE, form.rank_name, 0)
    form.lbl_title_flash.Visible = false
  end
end
function on_select_row_click(self, row)
  local form = self.Parent
  form.textgrid_rank:ClearSelect()
end
function on_right_select_grid(self, row, col)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local name = self:GetGridText(row, 2)
  if name == nil or nx_string(name) == "" then
    return
  end
  local rank_type = get_rank_prop(form.rank_name, "Type")
  if nx_int(rank_type) == nx_int(2) then
    return
  end
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "rank", "rank")
  nx_execute("menu_game", "menu_recompose", menu_game, name)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
function on_btn_prize_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_prize = util_get_form("form_stage_main\\form_rank\\form_rank_prize", true, false)
  if not nx_is_valid(form_prize) then
    return
  end
  form_prize.mltbox_prize.HtmlText = nx_widestr(util_text("ui_" .. nx_string(form.rank_name) .. "_prize"))
  util_show_form("form_stage_main\\form_rank\\form_rank_prize", true)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form_prize)
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local tree_node = get_rank_prop(form.rank_name, "TreeNode")
  local tree_node_name = gui.TextManager:GetFormatText("ui_rank_node_" .. tree_node)
  local thrid_name = gui.TextManager:GetFormatText("ui_" .. form.rank_name)
  form.lbl_rankname_bg.Text = nx_widestr(thrid_name)
  form.lbl_info.Text = nx_widestr(gui.TextManager:GetFormatText(form.rank_name .. "_desc"))
  form.lbl_publish_time.Text = nx_widestr(gui.TextManager:GetFormatText(form.rank_name .. "_publish_time"))
  refresh_rank(form, form.rank_name, form.rank_string)
  form.tree_rank.Enabled = true
  form.lbl_wait.Visible = false
  form.lbl_connect.Visible = false
  return
end
function refresh_rank(form, rank_name, rank_string)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local rank_gird = form.textgrid_rank
  rank_gird:BeginUpdate()
  rank_gird:ClearRow()
  rank_gird.ColCount = COL_COUNT
  rank_gird.ColWidths = nx_string(get_rank_prop(rank_name, "ColWide"))
  rank_gird.HeaderBackColor = "0,255,255,255"
  local col_list = nx_function("ext_split_string", get_rank_prop(rank_name, "ColName"), ",")
  if table.getn(col_list) ~= COL_COUNT then
    return
  end
  for i = 1, COL_COUNT do
    local head_name = gui.TextManager:GetFormatText(col_list[i])
    rank_gird:SetColTitle(i - 1, nx_widestr(head_name))
  end
  local rank_type = get_rank_prop(rank_name, "Type")
  local main_type = get_rank_prop(rank_name, "MainType")
  local string_table = util_split_wstring(nx_widestr(rank_string), ",")
  form.self_row = -1
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local key_name = ""
  if nx_int(rank_type) == nx_int(TYPE_PLAYER) or nx_int(rank_type) == nx_int(TYPE_LEITAI) or nx_int(rank_type) == nx_int(TYPE_LEITAI_GAME) then
    key_name = client_player:QueryProp("Name")
  elseif nx_int(rank_type) == nx_int(TYPE_GUILD) then
    key_name = client_player:QueryProp("GuildName")
  end
  local begin_index = 1
  for row = 0, 99 do
    if begin_index + COL_COUNT > table.getn(string_table) then
      break
    end
    rank_gird:InsertRow(-1)
    for index = 0, COL_COUNT - 1 do
      if nx_string(rank_name) == "rank_lx_ssb" and index == 6 then
      else
        rank_gird:SetGridText(row, index, nx_widestr(string_table[begin_index]))
      end
      begin_index = begin_index + 1
    end
    local temp_name = rank_gird:GetGridText(row, 2)
    if nx_ws_equal(nx_widestr(key_name), nx_widestr(temp_name)) then
      form.self_row = row
    end
    local last_test, last_color = get_last_no(rank_gird:GetGridText(row, 0), rank_gird:GetGridText(row, 1))
    rank_gird:SetGridText(row, 1, nx_widestr(last_test))
    rank_gird:SetGridForeColor(row, 1, last_color)
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) then
      local player_name = rank_gird:GetGridText(row, 2)
      if nx_ws_equal(nx_widestr(player_name), nx_widestr("")) == false then
        local str_len = string.len(nx_string(player_name))
        if nx_number(str_len) > 5 then
          local sub_str = string.sub(nx_string(player_name), -5, -1)
          if nx_string(sub_str) == "(npc)" then
            local npc_name = nx_string(string.sub(nx_string(player_name), 1, -6))
            local show_name = nx_widestr(gui.TextManager:GetFormatText(npc_name))
            rank_gird:SetGridText(row, 2, show_name)
          end
        end
      end
    end
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) or nx_int(rank_type) == nx_int(TYPE_LEITAI) or nx_int(rank_type) == nx_int(TYPE_LEITAI_GAME) then
      local school_name = rank_gird:GetGridText(row, 5)
      if nx_ws_equal(nx_widestr(school_name), nx_widestr("")) == false then
        rank_gird:SetGridText(row, 5, nx_widestr(gui.TextManager:GetFormatText(nx_string(school_name))))
      end
    end
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) and nx_int(main_type) == nx_int(STAT_LIFE_LEVEL) then
      show_life_title(rank_name, rank_gird, row)
    end
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) and nx_int(main_type) == nx_int(STAT_MARRY_RANK) then
      show_marry_title(rank_name, rank_gird, row)
    end
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) then
      show_batwin_ratio(rank_name, rank_gird, row)
    end
    if nx_string(rank_name) == "rank_17_ManyRevengeIntegral" then
      local title_info = rank_gird:GetGridText(row, 6)
      local list = util_split_wstring(nx_widestr(title_info), nx_widestr("-"))
      local counts = table.getn(list)
      local title_name = nx_widestr("")
      local player_num = nx_int(0)
      local title_id = nx_int(0)
      local sworn_title = nx_widestr("")
      if 3 <= counts then
        title_name = nx_widestr(list[1])
        player_num = nx_int(list[2])
        title_id = nx_int(list[3])
        sworn_title = nx_widestr(gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(title_id), nx_widestr(title_name)))
      end
      rank_gird:SetGridText(row, 2, nx_widestr(sworn_title))
    end
    if nx_string(rank_name) == "rank_8_huashanlunjian" then
      local flag = rank_gird:GetGridText(row, 4)
      rank_gird:SetGridText(row, 4, nx_widestr(util_text("CharacterFlag_" .. nx_string(flag))))
    end
    if nx_string(rank_name) == "rank_12_marry_guest" then
      local price = nx_int(rank_gird:GetGridText(row, 3))
      local expend_text = nx_execute("util_functions", "trans_capital_string", nx_int(price))
      rank_gird:SetGridText(row, 3, nx_widestr(expend_text))
    end
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) and nx_int(main_type) == nx_int(STAT_SELF_PROP) then
      show_used_faculty(rank_name, rank_gird, row)
    end
  end
  if nx_int(form.self_row) >= nx_int(0) then
    form.btn_search.Enabled = true
    form.lbl_search_flash.Visible = true
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridForeColor(form.self_row, index, "255,255,0,0")
    end
    if nx_int(form.self_row) < nx_int(3) then
      if nx_int(rank_type) == nx_int(TYPE_GUILD) then
        form.btn_title.Enabled = false
        form.lbl_title_flash.Visible = false
      else
        form.btn_title.Enabled = true
        local title_id = get_rank_title_id(rank_name, form.self_row + 1)
        if check_have_title(title_id) then
          form.lbl_title_flash.Visible = false
        else
          form.lbl_title_flash.Visible = true
        end
      end
    end
  end
  if nx_string(rank_name) == "rank_12_marry_man" or nx_string(rank_name) == "rank_12_marry_women" then
    form.btn_title.Enabled = false
    form.lbl_title_flash.Visible = false
  end
  for index = 0, COL_COUNT - 1 do
    rank_gird:SetGridForeColor(0, index, "255,150,0,150")
    rank_gird:SetGridForeColor(1, index, "255,255,120,0")
    rank_gird:SetGridForeColor(2, index, "255,0,0,255")
  end
  if nx_string(rank_name) == "rank_lx_ssb" then
    rank_gird:SetGridText(0, 0, gui.TextManager:GetFormatText(nx_string("ui_linxiao_phb_01")))
    rank_gird:SetGridText(1, 0, gui.TextManager:GetFormatText(nx_string("ui_linxiao_phb_02")))
    rank_gird:SetGridText(2, 0, gui.TextManager:GetFormatText(nx_string("ui_linxiao_phb_03")))
    rank_gird:SetGridText(3, 0, gui.TextManager:GetFormatText(nx_string("ui_linxiao_phb_04")))
    rank_gird:SetGridText(4, 0, gui.TextManager:GetFormatText(nx_string("ui_linxiao_phb_05")))
    rank_gird:SetGridText(5, 0, gui.TextManager:GetFormatText(nx_string("ui_linxiao_phb_06")))
    rank_gird:SetGridText(6, 0, gui.TextManager:GetFormatText(nx_string("ui_linxiao_phb_07")))
    rank_gird:SetGridText(0, 6, nx_widestr(250))
    rank_gird:SetGridText(1, 6, nx_widestr(225))
    rank_gird:SetGridText(2, 6, nx_widestr(225))
    rank_gird:SetGridText(3, 6, nx_widestr(203))
    rank_gird:SetGridText(4, 6, nx_widestr(203))
    rank_gird:SetGridText(5, 6, nx_widestr(203))
    rank_gird:SetGridText(6, 6, nx_widestr(203))
  else
    rank_gird:SetGridText(0, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_first")))
    rank_gird:SetGridText(1, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_second")))
    rank_gird:SetGridText(2, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_third")))
  end
  rank_gird:EndUpdate()
end
function request_query(form, rank_name)
  if not nx_is_valid(form) then
    return
  end
  if rank_name == nil then
    return
  end
  form.tree_rank.Enabled = false
  form.lbl_wait.Visible = true
  form.lbl_connect.Visible = true
  form.btn_search.Enabled = false
  form.btn_title.Enabled = false
  form.lbl_search_flash.Visible = false
  form.lbl_title_flash.Visible = false
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
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_RANK), nx_int(sub_cmd), nx_string(rank_name), nx_int64(publish_time))
end
function receive_data(...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_cmd = arg[1]
  if nx_int(sub_cmd) == nx_int(SERVER_OPEN_HORSE_RACE_RANK) then
    nx_execute("form_stage_main\\form_rank\\form_horse_race_rank_main", "open_form")
    return
  end
  if table.getn(arg) < 2 then
    return
  end
  local rank_name = arg[2]
  if rank_name == nil or nx_string(rank_name) == nx_string("") then
    return
  end
  if rank_name == HORSE_RACE_DAILY_RANK_NAME then
    nx_execute("form_stage_main\\form_rank\\form_horse_race_rank_main", "receive_data", unpack(arg))
    return
  end
  if rank_name == GUILD_KUAFU_GUILD_JIFEN_RANK_NAME then
    local form1 = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
    if nx_is_valid(form1) and form1.Visible then
      nx_execute("form_stage_main\\form_guild_war\\form_guild_war_join", "receive_data", unpack(arg))
      return
    end
  end
  if rank_name == SANMENG_RANK1 or rank_name == SANMENG_RANK2 or rank_name == SANMENG_RANK3 then
    local form = nx_value("form_stage_main\\form_match\\form_match_sanmeng")
    if nx_is_valid(form) and form.Visible then
      nx_execute("form_stage_main\\form_match\\form_match_sanmeng", "on_handler_rank_data", unpack(arg))
      return
    end
  end
  if rank_name == GUILDUNION_RANK_PERSON or rank_name == GUILDUNION_RANK_WEEK or rank_name == GUILDUNION_RANK_SEASON then
    local form = nx_value("form_stage_main\\form_match\\form_guild_union")
    if nx_is_valid(form) and form.Visible then
      nx_execute("form_stage_main\\form_match\\form_guild_union", "on_handler_rank_data", unpack(arg))
      return
    end
  end
  if rank_name == GUILD_KUAFU_PLAYER_JIFEN_RANK_NAME then
    local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_guild_war\\form_guild_war_join", "receive_data", unpack(arg))
      return
    end
  end
  local RANK_NAME_TIGUAN_DUAL_PLAY = "rank_srltzbs_geren_001"
  if rank_name == RANK_NAME_TIGUAN_DUAL_PLAY then
    local form = nx_value("form_stage_main\\form_tiguan\\form_tiguan_dual_play")
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_tiguan\\form_tiguan_dual_play", "on_rank_data_changed", unpack(arg))
      return
    end
  end
  if rank_name == PAWN_TICKET_RANK_NAME or rank_name == CONT_WISH_RANK_NAME then
    return
  end
  if nx_int(sub_cmd) == nx_int(RANK_NO_NAME) then
    local rank_name = arg[2]
    if rank_name == "rank_1_khbd" or rank_name == "rank_1_xxdf" then
      nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "on_server_wudu_msg", unpack(arg))
    end
  end
  local form = nx_execute("util_gui", "util_get_form", self_form_name, true, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_CLEAR_CAHCE) then
    on_clear_cache(form, rank_name)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_USE_CAHCE) then
    on_use_cache(form, rank_name, page_index)
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
function on_use_cache(form, rank_name, page_index)
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
  refresh_form(form)
end
function query_name_by_rank_no(rank_name, rank_no)
  if nx_string(rank_name) == nx_string("") or nx_int(rank_no) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_send_world_rank_query_no", nx_int(SUB_CLIENT_RANK_NO), nx_string(rank_name), nx_int(rank_no))
end
function is_world_rank(rank_name)
  local bWorldRank = true
  if rank_name == HORSE_RACE_DAILY_RANK_NAME then
    bWorldRank = false
  end
  if rank_name == PAWN_TICKET_RANK_NAME or rank_name == CONT_WISH_RANK_NAME then
    bWorldRank = false
  end
  return bWorldRank
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
  local sec_count = ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local rank_name = ini:GetSectionByIndex(i)
    if is_world_rank(rank_name) then
      child = cache_list:CreateChild(rank_name)
      if nx_is_valid(child) then
        child.total_rows = 0
        child.publish_time = -1
        child.rank_string = "null"
      end
    end
  end
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
function get_rank_prop(rank_name, prop)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(rank_name))
  if sec_index < 0 then
    return ""
  end
  return ini:ReadString(sec_index, nx_string(prop), "")
end
function get_last_no(cur_no, last_no)
  local text = ""
  local color = "255,255,255,255"
  if nx_int(cur_no) <= nx_int(0) then
    return text, color
  end
  local gui = nx_value("gui")
  if nx_int(last_no) <= nx_int(0) then
    text = gui.TextManager:GetFormatText("ui_rank_change_new")
    color = "255,255,0,0"
    return text, color
  end
  if nx_int(cur_no) == nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_no")
    color = "255,0,0,0"
    return text, color
  end
  if nx_int(cur_no) < nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_up")
    text = nx_string(text) .. nx_string(nx_int(last_no) - nx_int(cur_no))
    color = "255,0,255,0"
    return text, color
  end
  if nx_int(cur_no) > nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_down")
    text = nx_string(text) .. nx_string(nx_int(cur_no) - nx_int(last_no))
    color = "255,255,0,0"
    return text, color
  end
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function auto_select_first(tree)
  local temp_node = tree.RootNode
  while nx_is_valid(temp_node) do
    local sub_node_tab = temp_node:GetNodeList()
    if table.getn(sub_node_tab) > 0 then
      temp_node.Expand = true
      temp_node = sub_node_tab[1]
    else
      tree.SelectNode = temp_node
      break
    end
  end
end
function set_select_node_state(form, rank_name)
  local temp_node_tab = {}
  local select_node = nx_null()
  local root_node = form.tree_rank.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local sub_node_tab = root_node:GetNodeList()
  for i = 1, table.getn(sub_node_tab) do
    local node_tab = sub_node_tab[i]:GetNodeList()
    temp_node_tab[i] = sub_node_tab[i]
    local find = false
    for j = 1, table.getn(node_tab) do
      if nx_string(node_tab[j].rank_name) == nx_string(rank_name) then
        select_node = node_tab[j]
        request_query(form, nx_string(rank_name))
        find = true
        break
      end
    end
    if find then
      break
    end
  end
  for i = 1, table.getn(temp_node_tab) do
    temp_node_tab[i].Expand = i == table.getn(temp_node_tab)
  end
  if nx_is_valid(select_node) then
    form.tree_rank.SelectNode = select_node
  end
end
function get_rank_title_id(rank_name, rank_no)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_title.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(rank_name))
  if sec_index < 0 then
    return ""
  end
  local title_list = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
  local title_info = title_list[rank_no]
  local info_list = util_split_string(title_info, ",")
  if table.getn(info_list) < 3 then
    return ""
  end
  return info_list[2]
end
function check_have_title(rank_id)
  if rank_id == "" then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if 0 <= client_player:FindRecordRow("title_rec", 0, nx_int(rank_id), 0) then
    return true
  else
    return false
  end
end
function show_life_title(rank_name, grid, row)
  if not nx_is_valid(grid) or rank_name == nil then
    return 0
  end
  local life_level = grid:GetGridText(row, 3)
  local life_title = ""
  if rank_name == "rank_3_tj" then
    life_title = "role_title_121" .. nx_string(life_level)
  elseif rank_name == "rank_3_cf" then
    life_title = "role_title_126" .. nx_string(life_level)
  elseif rank_name == "rank_3_jq" then
    life_title = "role_title_127" .. nx_string(life_level)
  elseif rank_name == "rank_3_cs" then
    life_title = "role_title_130" .. nx_string(life_level)
  elseif rank_name == "rank_3_ds" then
    life_title = "role_title_129" .. nx_string(life_level)
  elseif rank_name == "rank_3_ys" then
    life_title = "role_title_128" .. nx_string(life_level)
  elseif rank_name == "rank_3_kg" then
    life_title = "role_title_120" .. nx_string(life_level)
  elseif rank_name == "rank_3_yf" then
    life_title = "role_title_122" .. nx_string(life_level)
  elseif rank_name == "rank_3_lh" then
    life_title = "role_title_125" .. nx_string(life_level)
  elseif rank_name == "rank_3_nf" then
    life_title = "role_title_124" .. nx_string(life_level)
  elseif rank_name == "rank_3_qf" then
    life_title = "role_title_123" .. nx_string(life_level)
  elseif rank_name == "rank_3_qs" then
    life_title = "role_title_131" .. nx_string(life_level)
  elseif rank_name == "rank_3_qis" then
    life_title = "role_title_132" .. nx_string(life_level)
  elseif rank_name == "rank_3_hs" then
    life_title = "role_title_134" .. nx_string(life_level)
  elseif rank_name == "rank_3_ss" then
    life_title = "role_title_133" .. nx_string(life_level)
  elseif rank_name == "rank_3_gs" then
    life_title = "role_title_136" .. nx_string(life_level)
  elseif rank_name == "rank_3_qg" then
    life_title = "role_title_135" .. nx_string(life_level)
  end
  if life_title ~= "" then
    grid:SetGridText(row, 3, nx_widestr(util_text(life_title)))
  end
end
function show_marry_title(rank_name, grid, row)
  if not nx_is_valid(grid) or rank_name == nil then
    return 0
  end
  local marry_level = grid:GetGridText(row, 3)
  if nx_int(marry_level) > nx_int(6) then
    marry_level = 6
  end
  local marry_title = ""
  if rank_name == "rank_12_marry_man" then
    marry_title = "man_title_" .. nx_string(marry_level)
  elseif rank_name == "rank_12_marry_women" then
    marry_title = "woman_title_" .. nx_string(marry_level)
  end
  if marry_title ~= "" then
    grid:SetGridText(row, 3, nx_widestr(util_text(marry_title)))
  end
end
function show_batwin_ratio(rank_name, grid, row)
  if not nx_is_valid(grid) or rank_name == nil then
    return
  end
  local main_info = get_rank_prop(rank_name, "MainInfo")
  if nx_string(main_info) == "BatWinRatio" then
    local ratio = grid:GetGridText(row, 3)
    local txt = nx_widestr(nx_number(ratio) / 10) .. nx_widestr("%")
    grid:SetGridText(row, 3, nx_widestr(txt))
  end
  local sub_info = get_rank_prop(rank_name, "SubInfo")
  if nx_string(sub_info) == "BatWinRatio" then
    local ratio = grid:GetGridText(row, 4)
    local txt = nx_widestr(nx_number(ratio) / 10) .. nx_widestr("%")
    grid:SetGridText(row, 4, nx_widestr(txt))
  end
end
function show_used_faculty(rank_name, grid, row)
  if not nx_is_valid(grid) or rank_name == nil then
    return
  end
  local main_info = get_rank_prop(rank_name, "MainInfo")
  if nx_string(main_info) == "NeigongUseValue" or nx_string(main_info) == "SkillUseValue" then
    local faculty = grid:GetGridText(row, 3)
    local yi = math.floor(nx_number(faculty) / 10000)
    local wan = math.floor(nx_number(faculty) % 10000)
    local text = nx_widestr("")
    if nx_int(yi) > nx_int(0) then
      text = nx_widestr(yi) .. nx_widestr(util_text("ui_rank_yi"))
    end
    if nx_int(wan) > nx_int(0) then
      text = nx_widestr(text) .. nx_widestr(wan) .. nx_widestr(util_text("ui_rank_wan"))
    end
    grid:SetGridText(row, 3, nx_widestr(text))
  end
end
