require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("util_gui")
MAX_STATION_TASK_TYPE = 3
MAX_STATION_TASK_DIFF = 3
CLIENT_CUSTOMMSG_SUB_START = 1
CLIENT_CUSTOMMSG_SUB_GIVEUP = 2
CLIENT_CUSTOMMSG_SUB_SHOW_TRACE = 3
CLIENT_CUSTOMMSG_SUB_CLOSE_TRACE = 4
CLIENT_CUSTOMMSG_SUB_QUERY_TASK_INFO = 5
CLIENT_CUSTOMMSG_SUB_QUERY_INFO = 6
local diff_max_count = {}
local station_prize_table = {}
local station_domain_table = {}
local station_prize_rank_table = {}
local station_prize_config_table_id = {}
local station_prize_config_table_photo = {}
function open_form(form)
  custom_send_guild_station_activity(CLIENT_CUSTOMMSG_SUB_QUERY_INFO)
  return true
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local helper_form = nx_value("helper_form")
  if helper_form then
    custom_send_guild_station_activity(CLIENT_CUSTOMMSG_SUB_QUERY_TASK_INFO, 1)
  end
  form.select_diff = 1
  form.taskstart = false
  form.taskdiff = 1
  form.querydiff = 1
  form.starttime = 0
  form.timedown = 0
  form.btn_2.Visible = true
  form.btn_3.Visible = false
  form.btn_open.Visible = true
  form.btn_1.Visible = false
  if 0 == is_captain() then
    form.btn_1.Enabled = false
    form.btn_open.Enabled = false
  end
  form.textgrid.Visible = true
  load_resource()
end
function on_main_form_close(form)
  remove_timer(form, "on_update_starttime")
  remove_timer(form, "on_update_timedown")
  nx_destroy(form)
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Name == "rbtn_guild1" then
    form.select_diff = 1
  elseif rbtn.Name == "rbtn_guild2" then
    form.select_diff = 2
  elseif rbtn.Name == "rbtn_guild3" then
    form.select_diff = 3
  end
  if nx_int(form.select_diff) == nx_int(form.querydiff) then
    return
  end
  custom_send_guild_station_activity(CLIENT_CUSTOMMSG_SUB_QUERY_TASK_INFO, form.select_diff)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_open_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_send_guild_station_activity(CLIENT_CUSTOMMSG_SUB_START, form.select_diff)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_open.Visible = true
  form.btn_1.Visible = false
  remove_timer(form, "on_update_starttime")
  custom_send_guild_station_activity(CLIENT_CUSTOMMSG_SUB_GIVEUP, form.select_diff)
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_2.Visible = false
  form.btn_3.Visible = true
  custom_send_guild_station_activity(CLIENT_CUSTOMMSG_SUB_SHOW_TRACE, form.select_diff)
end
function on_btn_3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_2.Visible = true
  form.btn_3.Visible = false
  custom_send_guild_station_activity(CLIENT_CUSTOMMSG_SUB_CLOSE_TRACE, form.select_diff)
end
function on_imagegrid_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_guildstation_msg(...)
  local submsg = nx_int(arg[1])
  if nx_int(submsg) == nx_int(1) then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_task", true, false)
    if not nx_is_valid(form) then
      return false
    end
    form:Show()
    form.taskdiff = nx_int(arg[2])
    form.querydiff = nx_int(arg[3])
    if nx_int(form.taskdiff) > nx_int(0) then
      form.btn_open.Visible = false
      form.btn_1.Visible = true
    end
    if nx_int(form.select_diff) == nx_int(1) and nx_int(1) == nx_int(form.querydiff) and form.rbtn_guild1.Checked == false then
      form.rbtn_guild1.Checked = true
    elseif nx_int(2) == nx_int(form.querydiff) and form.rbtn_guild2.Checked == false then
      form.rbtn_guild2.Checked = true
    elseif nx_int(3) == nx_int(form.querydiff) and form.rbtn_guild3.Checked == false then
      form.rbtn_guild3.Checked = true
    end
    if nx_int(0) < nx_int(form.taskdiff) and nx_int(form.querydiff) ~= nx_int(form.taskdiff) then
      form.btn_1.Enabled = false
      form.btn_2.Enabled = false
      form.btn_3.Enabled = false
      form.btn_open.Enabled = false
    else
      form.btn_1.Enabled = true
      form.btn_2.Enabled = true
      form.btn_3.Enabled = true
      form.btn_open.Enabled = true
    end
    if 0 == is_captain() then
      form.btn_1.Enabled = false
      form.btn_open.Enabled = false
    end
    local escort_count = nx_int(arg[4])
    local killmonster1 = nx_int(arg[5])
    local killmonster2 = nx_int(arg[6])
    form.starttime = nx_int(arg[7])
    form.timedown = nx_int(arg[8])
    form.taskstart = true
    local leasttasktime = nx_int(arg[9])
    form.mltbox_38_L.HtmlText = nx_widestr(util_text("ui_guild_war_task_rank_" .. nx_string(form.querydiff)))
    form.lbl_least_time.Text = nx_widestr(get_format_time_text(leasttasktime))
    form.lbl_timedown.Text = nx_widestr(get_format_time_text(form.timedown))
    if nx_int(form.starttime) >= nx_int(0) then
      form.lbl_task_time.Text = nx_widestr(get_format_time_text(form.starttime))
      add_timer(form, 1000, -1, nx_current(), "on_update_starttime")
    else
      remove_timer(form, "on_update_starttime")
      form.lbl_task_time.Text = nx_widestr(get_format_time_text(0))
    end
    add_timer(form, 1000, -1, nx_current(), "on_update_timedown")
    local max_escount_count = get_max_type_count(form.querydiff, 1)
    local max_killmonster1 = get_max_type_count(form.querydiff, 2)
    local max_killmonster2 = get_max_type_count(form.querydiff, 3)
    form.lbl_escortcount.Text = nx_widestr(escort_count) .. nx_widestr("/") .. nx_widestr(max_escount_count)
    form.lbl_killmonster1.Text = nx_widestr(killmonster1) .. nx_widestr("/") .. nx_widestr(max_killmonster1)
    form.lbl_killmonster2.Text = nx_widestr(killmonster2) .. nx_widestr("/") .. nx_widestr(max_killmonster2)
    local rank_info_begin_pos = 9
    local count = (table.getn(arg) - rank_info_begin_pos) / 2
    form.textgrid.cur_editor_row = -1
    form.textgrid.current_task_id = ""
    form.textgrid.CanSelectRow = false
    for i = 1, form.textgrid.ColCount do
      form.textgrid:SetColAlign(i - 1, "center")
    end
    form.textgrid:BeginUpdate()
    form.textgrid:ClearRow()
    for index = 1, count do
      local row = form.textgrid:InsertRow(-1)
      if nx_int(row) < nx_int(0) then
        return
      end
      local guildname = nx_widestr(arg[rank_info_begin_pos + 2 * (index - 1) + 1])
      local time = nx_int(arg[rank_info_begin_pos + 2 * (index - 1) + 2])
      form.textgrid:SetGridText(row, 0, nx_widestr(index))
      local item = get_prize(form.querydiff, index)
      local image_grid = create_image(item)
      if nx_is_valid(image_grid) then
        form.textgrid:SetGridControl(row, 1, image_grid)
      end
      form.textgrid:SetGridText(row, 2, nx_widestr(guildname))
      form.textgrid:SetGridText(row, 3, nx_widestr(get_format_time_text(time)))
    end
    form.textgrid.Visible = true
    form.textgrid:EndUpdate()
  elseif nx_int(submsg) == nx_int(2) then
    show_station_domain_form(unpack(arg))
  elseif nx_int(submsg) == nx_int(3) then
    remove_timer(form, "on_update_starttime")
    remove_timer(form, "on_update_timedown")
    local max_escount_count = get_max_type_count(form.select_diff, 1)
    local max_killmonster1 = get_max_type_count(form.select_diff, 2)
    local max_killmonster2 = get_max_type_count(form.select_diff, 3)
    form.lbl_escortcount.Text = nx_widestr(escort_count) .. nx_widestr("/") .. nx_widestr(max_escount_count)
    form.lbl_killmonster1.Text = nx_widestr(killmonster1) .. nx_widestr("/") .. nx_widestr(max_killmonster1)
    form.lbl_killmonster2.Text = nx_widestr(killmonster2) .. nx_widestr("/") .. nx_widestr(max_killmonster2)
    form.lbl_timedown.Text = nx_widestr(get_format_time_text(0))
    form.lbl_least_time.Text = nx_widestr(get_format_time_text(0))
    form.lbl_task_time.Text = nx_widestr(get_format_time_text(0))
  end
end
function get_format_time_text(time)
  if nx_int(time) < nx_int(0) then
    time = 0
  end
  local format_time = ""
  local hour = nx_int(time / 3600)
  local min = nx_int(math.mod(nx_number(time), 3600) / 60)
  local sec = nx_int(math.mod(nx_number(time), 60))
  format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  return nx_string(format_time)
end
function add_timer(form, ms, count, formname, func)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), func, form)
    timer:Register(ms, count, nx_current(), func, form, -1, -1)
  end
end
function remove_timer(form, func)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), func, form)
  end
end
function on_update_starttime(form)
  form.starttime = form.starttime + 1
  local text = get_format_time_text(form.starttime)
  form.lbl_task_time.Text = nx_widestr(text)
end
function on_update_timedown(form)
  form.timedown = form.timedown - 1
  if nx_int(form.timedown) < nx_int(0) then
    remove_timer(form, "on_update_timedown")
    form.lbl_timedown.Text = nx_widestr("00:00:00")
    return
  end
  local text = get_format_time_text(form.timedown)
  form.lbl_timedown.Text = nx_widestr(text)
end
function get_max_type_count(diff, type)
  if nx_int(diff) <= nx_int(0) or nx_int(diff) > nx_int(table.getn(diff_max_count)) then
    return 0
  end
  if nx_int(type) <= nx_int(0) or nx_int(type) > nx_int(MAX_STATION_TASK_TYPE) then
    return 0
  end
  local tbl = diff_max_count[diff]
  return nx_int(tbl[type + 1])
end
function get_prize(diff, rank)
  if nx_int(diff) <= nx_int(0) or nx_int(diff) > nx_int(table.getn(station_prize_table)) then
    return ""
  end
  local tbl = station_prize_table[diff]
  if nx_int(rank) <= nx_int(0) or nx_int(rank) > nx_int(table.getn(tbl)) then
    return ""
  end
  return nx_string(tbl[rank])
end
function get_rank_prize(rank)
  if nx_int(rank) <= nx_int(0) or nx_int(rank) > nx_int(table.getn(station_prize_rank_table)) then
    return ""
  end
  return nx_string(station_prize_rank_table[rank])
end
function get_domain_rank(diff, rank)
  if nx_int(diff) <= nx_int(0) or nx_int(diff) > nx_int(table.getn(station_domain_table)) then
    return 0
  end
  local tbl = station_prize_table[diff]
  if nx_int(rank) <= nx_int(0) or nx_int(rank) > nx_int(table.getn(tbl)) then
    return 0
  end
  return nx_string(tbl[rank])
end
function get_prize_photo(id)
  for index = 1, table.getn(station_prize_config_table_id) do
    if nx_string(id) == nx_string(station_prize_config_table_id[index]) then
      return nx_string(station_prize_config_table_photo[index])
    end
  end
  return ""
end
function load_resource()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\guildstationactivecfg.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("FinishCondition")
  local key_count = ini:GetSectionItemCount(sec_index)
  if nx_int(sec_index) >= nx_int(0) then
    for i = 1, key_count do
      local id = nx_string(ini:GetSectionItemValue(sec_index, i - 1))
      local count_table = util_split_string(nx_string(id), ",")
      table.insert(diff_max_count, count_table)
    end
  end
  sec_index = ini:FindSectionIndex("prize")
  if nx_int(sec_index) >= nx_int(0) then
    local key_count = ini:GetSectionItemCount(sec_index)
    for i = 1, key_count do
      local id = nx_string(ini:GetSectionItemValue(sec_index, i - 1))
      local tbl = util_split_string(nx_string(id), ";")
      table.insert(station_prize_table, tbl)
    end
  end
  sec_index = ini:FindSectionIndex("Domain")
  if nx_int(sec_index) >= nx_int(0) then
    local key_count = ini:GetSectionItemCount(sec_index)
    for i = 1, key_count do
      local id = nx_string(ini:GetSectionItemValue(sec_index, i - 1))
      local tbl = util_split_string(nx_string(id), ",")
      table.insert(station_domain_table, tbl)
    end
  end
  sec_index = ini:FindSectionIndex("PrizeConfig")
  if nx_int(sec_index) >= nx_int(0) then
    local key_count = ini:GetSectionItemCount(sec_index)
    for i = 1, key_count do
      local value = nx_string(ini:GetSectionItemValue(sec_index, i - 1))
      local key = nx_string(ini:GetSectionItemKey(sec_index, i - 1))
      table.insert(station_prize_config_table_id, key)
      table.insert(station_prize_config_table_photo, value)
    end
  end
end
function load_prize_source()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\guildstationactivecfg.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("prize")
  local key_count = ini:GetSectionItemCount(sec_index)
  if nx_int(sec_index) >= nx_int(0) then
    for i = key_count, 1, -1 do
      local id = nx_string(ini:GetSectionItemValue(sec_index, i - 1))
      local tbl = util_split_string(nx_string(id), ";")
      for j = table.getn(tbl), 1, -1 do
        table.insert(station_prize_rank_table, tbl[j])
      end
    end
  end
  sec_index = ini:FindSectionIndex("PrizeConfig")
  if nx_int(sec_index) >= nx_int(0) then
    local key_count = ini:GetSectionItemCount(sec_index)
    for i = 1, key_count do
      local value = nx_string(ini:GetSectionItemValue(sec_index, i - 1))
      local key = nx_string(ini:GetSectionItemKey(sec_index, i - 1))
      table.insert(station_prize_config_table_id, key)
      table.insert(station_prize_config_table_photo, value)
    end
  end
end
function create_image(item_info)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_list = util_split_string(nx_string(item_info), ",")
  local count = table.getn(item_list)
  if nx_number(0) >= nx_number(count) then
    return
  end
  local image_grid = gui:Create("ImageGrid")
  if not nx_is_valid(image_grid) then
    return
  end
  image_grid.BackColor = "0,255,255,255"
  image_grid.MouseInColor = "0,255,255,255"
  image_grid.SelectColor = "0,255,255,255"
  image_grid.ClomnNum = count
  image_grid.FitGrid = true
  image_grid.NoFrame = true
  image_grid.GridHeight = 28
  image_grid.GridWidth = 24
  image_grid.ViewRect = "0,0," .. nx_string(count * 24) .. ",24"
  nx_bind_script(image_grid, nx_current())
  nx_callback(image_grid, "on_mousein_grid", "on_imagegrid_mousein_grid")
  nx_callback(image_grid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
  for i = 1, count do
    local item_id = nx_string(item_list[i])
    local photo = get_prize_photo(item_id)
    if photo ~= nil and photo ~= "" then
      image_grid:AddItem(i - 1, photo, nx_widestr(item_id), 1, -1)
    end
  end
  return image_grid
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text(nx_string(prize_id) .. "_tips")), x, y)
end
function show_station_domain_form(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_domain", true, false)
  if not nx_is_valid(form) then
    return false
  end
  form:Show()
  form.textgrid:BeginUpdate()
  form.textgrid:ClearRow()
  local domain_info_begin_pos = 1
  local count = (table.getn(arg) - domain_info_begin_pos) / 2
  for index = 1, count do
    local row = form.textgrid:InsertRow(-1)
    if nx_int(row) < nx_int(0) then
      return
    end
    local guildname = nx_widestr(arg[domain_info_begin_pos + 2 * (index - 1) + 1])
    local domain_id = nx_int(arg[domain_info_begin_pos + 2 * (index - 1) + 2])
    local domain_text = nx_widestr(util_text("ui_dipan_" .. nx_string(domain_id)))
    form.textgrid:SetGridText(row, 0, nx_widestr(index))
    form.textgrid:SetGridText(row, 1, nx_widestr(domain_text))
    local item = get_rank_prize(index)
    local image_grid = create_image(item)
    if nx_is_valid(image_grid) then
      form.textgrid:SetGridControl(row, 2, image_grid)
    end
    form.textgrid:SetGridText(row, 3, nx_widestr(guildname))
  end
  form.textgrid.Visible = true
  form.textgrid:EndUpdate()
end
function is_captain()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_captain = client_player:QueryProp("IsGuildCaptain")
  if nx_int(is_captain) ~= nx_int(2) then
    return 0
  end
  return 1
end
