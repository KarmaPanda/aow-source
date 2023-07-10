require("utils")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\switch\\switch_define")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_match\\form_guild_union"
local CTS_MGU_ENTER_WAR = 100
local CTS_MGU_REQUEST_DATA = 101
local STC_MGU_SEND_BASE_DATA = 100
local STC_MGU_SEND_WAE_INFO = 101
local GUILDUNION_RANK_PERSON = "rank_guj_geren_002"
local GUILDUNION_RANK_WEEK = "rank_guj_banghui_001"
local GUILDUNION_RANK_SEASON = "rank_guj_banghui_002"
local GUILDUNION_BATTLE_INDEX = "guild_union_battle_"
local SERVER_USE_CAHCE = 1
local SERVER_CLEAR_CAHCE = 2
local SERVER_NEW_DATA = 3
local SUB_CLIENT_CHECK = 1
local SUB_CLIENT_QUERY = 2
local TYPE_PLAYER = 1
local TYPE_GUILD = 2
local COL_COUNT = 7
local GRID_INIT_OPER = 0
local GRID_UPDATE_OPER = 1
local POWER_WEI = 1
local POWER_WU = 2
local BATTLE_TOTAL_WAR_NUM = 4
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local battle_cache_list = nx_value("Cache_Battle_Info")
  if not nx_is_valid(battle_cache_list) then
    form.battle_cache_list = nx_call("util_gui", "get_global_arraylist", "Cache_Battle_Info")
    init_battle_cache(form.battle_cache_list)
  else
    form.battle_cache_list = battle_cache_list
  end
  local rank_cache_list = nx_value("Cache_GuildUnion_Rank")
  if not nx_is_valid(rank_cache_list) then
    form.rank_cache_list = nx_call("util_gui", "get_global_arraylist", "Cache_GuildUnion_Rank")
    init_rank_cache(form.rank_cache_list)
  else
    form.rank_cache_list = rank_cache_list
  end
  custom_match_sanmeng(CTS_MGU_REQUEST_DATA)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_form()
  if util_is_lockform_visible(FORM_NAME) then
    util_auto_show_hide_form_lock(FORM_NAME)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MATCH_GUILDUNION) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_gujbhls_022"))
    return
  end
  util_auto_show_hide_form(FORM_NAME)
end
function on_btn_jw_click(btn)
  custom_match_sanmeng(CTS_MGU_ENTER_WAR)
end
function on_rbtn_jbxx_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_dzxx.Checked = false
  form.rbtn_phb.Checked = false
  form.groupbox_jbxx.Visible = true
  form.groupbox_dzxx.Visible = false
  form.groupbox_phb.Visible = false
end
function on_rbtn_dzxx_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_jbxx.Checked = false
  form.rbtn_phb.Checked = false
  form.groupbox_jbxx.Visible = false
  form.groupbox_dzxx.Visible = true
  form.groupbox_phb.Visible = false
  SetBattleGridData(form.textgrid_battle, GRID_INIT_OPER, 0, 0)
  Show_battle_info(form)
end
function on_rbtn_phb_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_jbxx.Checked = false
  form.rbtn_dzxx.Checked = false
  form.groupbox_jbxx.Visible = false
  form.groupbox_dzxx.Visible = false
  form.groupbox_phb.Visible = true
  form.rbtn_pr.Checked = true
  form.rbtn_gr.Checked = false
  form.rbtn_gmr.Checked = false
  form.groupbox_pr.Visible = true
  form.groupbox_gr.Visible = false
  form.groupbox_gmr.Visible = false
end
function on_rbtn_pr_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_pr.Visible = true
  form.groupbox_gr.Visible = false
  form.groupbox_gmr.Visible = false
  request_query(form, GUILDUNION_RANK_PERSON)
  refresh_rank(form)
end
function on_rbtn_gr_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_pr.Visible = false
  form.groupbox_gr.Visible = true
  form.groupbox_gmr.Visible = false
  request_query(form, GUILDUNION_RANK_WEEK)
  refresh_rank(form)
end
function on_rbtn_gmr_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_pr.Visible = false
  form.groupbox_gr.Visible = false
  form.groupbox_gmr.Visible = true
  request_query(form, GUILDUNION_RANK_SEASON)
  refresh_rank(form)
end
function on_btn_findme_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "self_row") or form.self_row < 0 then
    return
  end
  local rank_gird
  if form.groupbox_gr.Visible == true then
    rank_gird = form.textgrid_gr
  elseif form.groupbox_gmr.Visible == true then
    rank_gird = form.textgrid_gmr
  elseif form.groupbox_pr.Visible == true then
    rank_gird = form.textgrid_pr
  else
    return
  end
  rank_gird:SelectRow(form.self_row)
end
function on_server_msg(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(STC_MGU_SEND_BASE_DATA) then
    show_guild_base_info(unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_MGU_SEND_WAE_INFO) then
    on_set_battle_cache(arg[1])
  end
end
function show_guild_base_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local guild_name = arg[1]
  local guild_leader = arg[2]
  local guild_power = arg[3]
  local domain_id = arg[4]
  local online_num = arg[5]
  local total_num = arg[6]
  local guild_level = arg[7]
  local war_integral = arg[8]
  local guild_integral = arg[9]
  local guild_match_inte = arg[10]
  form.lbl_gn.Text = nx_widestr(guild_name)
  form.lbl_ln.Text = nx_widestr(guild_leader)
  local text_power_name = nx_widestr(util_text("ui_sanmeng_" .. nx_string(guild_power)))
  form.lbl_sl.Text = text_power_name
  local text_domain_name = nx_widestr(util_text("ui_dipan_" .. nx_string(domain_id)))
  form.lbl_dn.Text = text_domain_name
  form.lbl_oln.Text = nx_widestr(online_num)
  form.lbl_tn.Text = nx_widestr(total_num)
  form.lbl_gl.Text = nx_widestr(guild_level)
  form.lbl_wi.Text = nx_widestr(war_integral)
  form.lbl_gwi.Text = nx_widestr(guild_integral)
  form.lbl_gmi.Text = nx_widestr(guild_match_inte)
end
function on_set_battle_cache(battle_info_string)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  Clear_battle_cache(form.battle_cache_list)
  Set_battle_cache(form.battle_cache_list, battle_info_string)
  return
end
function init_rank_cache(cache_list)
  if not nx_is_valid(cache_list) then
    return
  end
  cache_list:ClearChild()
  local child = cache_list:CreateChild(GUILDUNION_RANK_PERSON)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
  child = cache_list:CreateChild(GUILDUNION_RANK_WEEK)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
  child = cache_list:CreateChild(GUILDUNION_RANK_SEASON)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
end
function init_battle_cache(cache_list)
  if not nx_is_valid(cache_list) then
    return
  end
  cache_list:ClearChild()
  for num = 1, BATTLE_TOTAL_WAR_NUM do
    local child_name = GUILDUNION_BATTLE_INDEX .. nx_string(num)
    local child_cache = get_cache(cache_list, child_name)
    if not nx_is_valid(child_cache) then
      local child_cache = cache_list:CreateChild(child_name)
      if nx_is_valid(child_cache) then
        child_cache.battle_string = nx_widestr("")
      end
    end
  end
end
function Set_battle_cache(cache_list, list_value)
  if not nx_is_valid(cache_list) then
    return
  end
  local string_table = util_split_wstring(nx_widestr(list_value), ",")
  local value_num = table.getn(string_table) / 4
  for num = 0, value_num - 1 do
    local value_war_index = string_table[num * 4 + 3]
    local child_name = GUILDUNION_BATTLE_INDEX .. nx_string(value_war_index)
    local child_cache = get_cache(cache_list, nx_string(child_name))
    if nx_is_valid(child_cache) then
      child_cache.battle_string = child_cache.battle_string .. nx_widestr(string_table[num * 4 + 1]) .. nx_widestr(",")
      child_cache.battle_string = child_cache.battle_string .. nx_widestr(string_table[num * 4 + 2]) .. nx_widestr(",")
      child_cache.battle_string = child_cache.battle_string .. nx_widestr(string_table[num * 4 + 3]) .. nx_widestr(",")
      child_cache.battle_string = child_cache.battle_string .. nx_widestr(string_table[num * 4 + 4]) .. nx_widestr(",")
    end
  end
end
function Clear_battle_cache(cache_list)
  if not nx_is_valid(cache_list) then
    return
  end
  for num = 1, BATTLE_TOTAL_WAR_NUM do
    local child_name = GUILDUNION_BATTLE_INDEX .. nx_string(num)
    local child_cache = get_cache(cache_list, child_name)
    if nx_is_valid(child_cache) then
      child_cache.battle_string = nx_widestr("")
    end
  end
end
function get_cache(cache_list, cache_name)
  if not nx_is_valid(cache_list) then
    return
  end
  local obj = cache_list:GetChild(nx_string(cache_name))
  if not nx_is_valid(obj) then
    return
  end
  return obj
end
function Show_battle_info(form)
  form.textgrid_battle:BeginUpdate()
  form.textgrid_battle:ClearRow()
  local wei_row = 0
  local wu_row = 0
  for i = 1, BATTLE_TOTAL_WAR_NUM do
    local child_name = GUILDUNION_BATTLE_INDEX .. nx_string(i)
    local child_cache = get_cache(form.battle_cache_list, child_name)
    if nx_is_valid(child_cache) then
      local value_table = util_split_wstring(nx_widestr(child_cache.battle_string), ",")
      local value_num = table.getn(value_table) / 4
      if 0 < value_num and (wei_row ~= 0 or wu_row ~= 0) then
        local cur_power_index = 1
        if wei_row < wu_row then
          cur_power_index = 2
        end
        for num = 0, 2 do
          wei_row, wu_row = SetBattleGridData(form.textgrid_battle, GRID_UPDATE_OPER, wei_row, wu_row, nx_widestr(" "), nx_widestr(" "), nx_int(1), nx_int(cur_power_index))
        end
        if wei_row < wu_row then
          wei_row = wu_row
        else
          wu_row = wei_row
        end
      end
      for num = 0, value_num - 1 do
        wei_row, wu_row = SetBattleGridData(form.textgrid_battle, GRID_UPDATE_OPER, wei_row, wu_row, value_table[num * 4 + 1], value_table[num * 4 + 2], value_table[num * 4 + 3], value_table[num * 4 + 4])
      end
    end
  end
  form.textgrid_battle:EndUpdate()
end
function SetBattleGridData(grid, oper_type, wei_row, wu_row, ...)
  if not nx_is_valid(grid) then
    return wei_row, wu_row
  end
  if oper_type == GRID_INIT_OPER then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local width = grid.Width
    grid:SetColWidth(0, width * 0.16176470588235295)
    grid:SetColWidth(1, width * 0.20588235294117646)
    grid:SetColWidth(2, width * 0.23529411764705882)
    grid:SetColWidth(3, width * 0.20588235294117646)
    grid:SetColWidth(4, width * 0.16176470588235295)
    grid:SetColTitle(0, nx_widestr(gui.TextManager:GetFormatText("ui_gujbhls_024")))
    grid:SetColTitle(1, nx_widestr(gui.TextManager:GetFormatText("ui_gujbhls_025")))
    grid:SetColTitle(2, nx_widestr(util_text("")))
    grid:SetColTitle(3, nx_widestr(gui.TextManager:GetFormatText("ui_gujbhls_025")))
    grid:SetColTitle(4, nx_widestr(gui.TextManager:GetFormatText("ui_gujbhls_024")))
  elseif oper_type == GRID_UPDATE_OPER then
    local server_name = arg[1]
    local guild_name = arg[2]
    local battle_index = nx_int(arg[3])
    local power_index = nx_int(arg[4])
    local form = grid.ParentForm
    if not nx_is_valid(form) then
      return
    end
    local row_num = -1
    local is_insert_row = false
    if power_index == nx_int(POWER_WEI) then
      if wu_row <= wei_row and 0 < wei_row or wei_row == 0 and wu_row == 0 then
        is_insert_row = true
      end
      row_num = wei_row
      wei_row = wei_row + 1
    elseif power_index == nx_int(POWER_WU) then
      if wu_row >= wei_row and 0 < wu_row or wei_row == 0 and wu_row == 0 then
        is_insert_row = true
      end
      row_num = wu_row
      wu_row = wu_row + 1
    end
    if is_insert_row == true then
      row_num = grid:InsertRow(nx_int(row_num))
    end
    if row_num < 0 then
      return wei_row, wu_row
    end
    local col_num = power_index * 4 - 4
    local col_num_1 = power_index * 2 - 1
    grid:SetGridText(row_num, col_num, nx_widestr(server_name))
    grid:SetGridText(row_num, col_num_1, nx_widestr(guild_name))
  end
  return wei_row, wu_row
end
function refresh_rank(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rank_name, key_name, rank_gird
  if form.groupbox_gr.Visible == true then
    rank_name = GUILDUNION_RANK_WEEK
    rank_gird = form.textgrid_gr
    key_name = client_player:QueryProp("GuildName")
  elseif form.groupbox_gmr.Visible == true then
    rank_name = GUILDUNION_RANK_SEASON
    rank_gird = form.textgrid_gmr
    key_name = client_player:QueryProp("GuildName")
  elseif form.groupbox_pr.Visible == true then
    rank_name = GUILDUNION_RANK_PERSON
    rank_gird = form.textgrid_pr
    key_name = client_player:QueryProp("Name")
  else
    return
  end
  local rank_string
  local rank_obj = get_cache(form.rank_cache_list, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  rank_string = rank_obj.rank_string
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
  if nx_int(rank_type) == nx_int(TYPE_PLAYER) then
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
      rank_gird:SetGridText(row, index, nx_widestr(string_table[begin_index]))
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
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) then
      local school_name = rank_gird:GetGridText(row, 5)
      if nx_ws_equal(nx_widestr(school_name), nx_widestr("")) == false then
        rank_gird:SetGridText(row, 5, nx_widestr(gui.TextManager:GetFormatText(nx_string(school_name))))
      end
    end
  end
  if nx_int(form.self_row) >= nx_int(0) then
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridForeColor(form.self_row, index, "255,255,0,0")
    end
  end
  rank_gird:SetGridText(0, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_first")))
  rank_gird:SetGridText(1, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_second")))
  rank_gird:SetGridText(2, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_third")))
  rank_gird:EndUpdate()
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
function on_handler_rank_data(...)
  if table.getn(arg) < 2 then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  local sub_cmd = arg[1]
  local rank_name = arg[2]
  if rank_name == nil or nx_string(rank_name) == nx_string("") then
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_CLEAR_CAHCE) then
    on_clear_cache(form, rank_name)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_USE_CAHCE) then
    on_use_cache(form, rank_name)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_NEW_DATA) then
    local rank_rows = arg[3]
    local publish_time = arg[4]
    local rank_string = arg[5]
    on_set_cache(form, rank_name, rank_rows, publish_time, rank_string)
    on_use_cache(form, rank_name)
    return
  end
  return true
end
function on_clear_cache(form, rank_name)
  local rank_obj = get_cache(form.rank_cache_list, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  rank_obj.total_rows = 0
  rank_obj.publish_time = -1
  rank_obj.rank_string = "null"
  return
end
function on_use_cache(form, rank_name)
  local rank_obj = get_cache(form.rank_cache_list, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
end
function on_set_cache(form, rank_name, rank_rows, publish_time, rank_string)
  local rank_obj = get_cache(form.rank_cache_list, rank_name)
  if nx_is_valid(rank_obj) then
    rank_obj.total_rows = rank_rows
    rank_obj.publish_time = publish_time
    rank_obj.rank_string = rank_string
  end
  return
end
function request_query(form, rank_name)
  if not nx_is_valid(form) then
    return
  end
  if rank_name == nil then
    return
  end
  local rank_obj = get_cache(form.rank_cache_list, rank_name)
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
