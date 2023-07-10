require("util_gui")
require("util_functions")
require("share\\client_custom_define")
local RANK_NODE_BEGIN = 1
local RANK_NODE_HORSERACE = 1
local RANK_NODE_END = 2
local SUB_CLIENT_CHECK = 1
local SUB_CLIENT_QUERY = 2
local SERVER_USE_CAHCE = 1
local SERVER_CLEAR_CAHCE = 2
local SERVER_NEW_DATA = 3
local TYPE_HORSE_RACE_DAILY = 1
local COL_COUNT = 7
local SERVER_COL_COUNT = 7
local self_form_name = "form_stage_main\\form_rank\\form_horse_race_rank_main"
local HORSE_RACE_DAILY_RANK_NAME = "rank_9_horserace"
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
  util_auto_show_hide_form(nx_current())
end
function main_form_init(self)
  self.Fixed = false
  self.rank_name = ""
  self.rank_rows = 0
  self.self_row = -1
  self.rank_string = ""
  local cache_list = nx_value("Cache_HorseRace_Rank")
  if not nx_is_valid(cache_list) then
    self.cache_list = nx_call("util_gui", "get_global_arraylist", "Cache_HorseRace_Rank")
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
  self.lbl_search_flash.Visible = false
  auto_select_first(self.tree_rank)
  return 1
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
  return
end
function create_rank_tree(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local rank_tree = form.tree_rank
  local root = rank_tree:CreateRootNode(nx_widestr(gui.TextManager:GetFormatText("ui_horse_race_rank")))
  rank_tree:BeginUpdate()
  local second_root
  for i = RANK_NODE_BEGIN, RANK_NODE_END - 1 do
    local second_name = gui.TextManager:GetFormatText("ui_horse_race_node_" .. i)
    second_root = root:CreateNode(nx_widestr(second_name))
    second_root.rank_type = i
    set_node_prop(second_root, "first")
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return
  end
  local count = ini:GetSectionCount()
  for i = 1, count do
    local rank_name = ini:GetSectionByIndex(i - 1)
    if is_horse_race_rank(rank_name) then
      local tree_node = get_rank_prop(rank_name, "TreeNode")
      if nx_string(tree_node) == nx_string("") then
        return
      end
      local second_name = gui.TextManager:GetFormatText("ui_horse_race_node_" .. tree_node)
      local second_root = root:FindNode(nx_widestr(second_name))
      if nx_is_valid(second_root) then
        local thrid_name = gui.TextManager:GetFormatText("ui_node_" .. rank_name)
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
function on_select_row_click(self, row)
  local form = self.Parent
  form.textgrid_rank:ClearSelect()
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local tree_node = get_rank_prop(form.rank_name, "TreeNode")
  local tree_node_name = gui.TextManager:GetFormatText("ui_horse_race_node_" .. tree_node)
  local thrid_name = gui.TextManager:GetFormatText(nx_string("ui_node_" .. form.rank_name))
  form.lbl_rankname_bg.Text = nx_widestr(thrid_name)
  form.lbl_info.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(form.rank_name .. "_desc")))
  form.lbl_publish_time.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(form.rank_name .. "_publish_time")))
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
  if nx_int(rank_type) ~= nx_int(RANK_NODE_HORSERACE) then
    return
  end
  local string_table = util_split_wstring(nx_widestr(rank_string), ",")
  form.self_row = -1
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local key_name = client_player:QueryProp("Name")
  local begin_index = 1
  for row = 0, 99 do
    if begin_index + SERVER_COL_COUNT > table.getn(string_table) then
      break
    end
    rank_gird:InsertRow(-1)
    for index = 0, SERVER_COL_COUNT - 1 do
      if index < 3 then
        rank_gird:SetGridText(row, index, nx_widestr(string_table[begin_index]))
      elseif index < 4 then
        local nTime = nx_int(math.abs(nx_number(string_table[begin_index])))
        local nMinute = math.floor(nTime / 60)
        local nSecond = nTime - nMinute * 60
        local timeText = nx_widestr(nMinute) .. gui.TextManager:GetFormatText("ui_horserace_minute") .. nx_widestr(nSecond) .. gui.TextManager:GetFormatText("ui_horserace_second")
        rank_gird:SetGridText(row, index, nx_widestr(timeText))
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
  end
  if nx_int(form.self_row) >= nx_int(0) then
    form.btn_search.Enabled = true
    form.lbl_search_flash.Visible = true
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridForeColor(form.self_row, index, "255,255,0,0")
    end
  end
  for index = 0, COL_COUNT - 1 do
    rank_gird:SetGridForeColor(0, index, "255,150,0,150")
    rank_gird:SetGridForeColor(1, index, "255,255,120,0")
    rank_gird:SetGridForeColor(2, index, "255,0,0,255")
  end
  rank_gird:SetGridText(0, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_first")))
  rank_gird:SetGridText(1, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_second")))
  rank_gird:SetGridText(2, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_third")))
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
  form.lbl_search_flash.Visible = false
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
  if table.getn(arg) < 2 then
    return
  end
  local sub_cmd = arg[1]
  local rank_name = arg[2]
  if rank_name == nil or nx_string(rank_name) == nx_string("") then
    return
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
function is_horse_race_rank(rank_name)
  local bHorseRaceRank = false
  if rank_name == HORSE_RACE_DAILY_RANK_NAME then
    bHorseRaceRank = true
  end
  return bHorseRaceRank
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
    if is_horse_race_rank(rank_name) then
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
