require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_task\\form_task_main")
require("form_stage_main\\form_task\\task_define")
require("form_stage_main\\form_attribute_mall\\form_attribute_shop")
local FORM_GUILF_PRAY = "form_stage_main\\form_relation\\form_relation_guild\\form_guild_pray"
local CLIENT_MSG_LUCK_PRAY = 0
local CLIENT_MSG_OPEN_GUILD_PRAY = 1
local CLIENT_MSG_LUCK_JITIAN = 2
local CLIENT_MSG_ACCEPT_LUCK_TASK = 3
local CLIENT_MSG_SUBMIT_LUCK_TASK = 4
local GUILD_LUCK_VALUE_PRE = 12
local DATA_COL_NUM = 4
local ST_FUNCTION_GUILD_LUCK_JITIAN = 640
local achieve_lbl_back_pix1 = 47
local achieve_lbl_back_pix2 = 55
local achieve_rank_interval = 2
local achieve_quanfu_height = 2
function main_form_init(self)
  self.Fixed = true
  self.max_guild_luck = 0
  self.pray_luck_consume = 0
  self.guild_luck_value = 0
  self.pray_fight_time = 0
  self.domain_id = 0
  self.self_row = -1
  self.sort_week_value = nx_widestr("")
  self.sort_total_value = nx_widestr("")
end
function on_main_form_open(form)
  form.rbtn_guild_luck.Checked = true
  init_grid(form)
  guild_luck_hide(form)
  load_guild_luck_pray_ini(form)
  request_pray_form_info()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function close_form()
  local form = nx_value(FORM_GUILF_PRAY)
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_pray_fight_time", form)
      timer:UnRegister(nx_current(), "on_update_pray_fight_time", form)
    end
    form:Close()
  end
end
function on_rbtn_guild_luck_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_guild_luck.Visible = true
    form.groupbox_guild_work.Visible = false
    form.groupbox_guild_pray.Visible = false
  end
end
function on_rbtn_guild_work_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_guild_work.Visible = true
    form.groupbox_guild_luck.Visible = false
    form.groupbox_guild_pray.Visible = false
  end
end
function on_rbtn_guild_pray_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_guild_pray.Visible = true
    form.groupbox_guild_luck.Visible = false
    form.groupbox_guild_work.Visible = false
  end
end
function on_rbtn_week_rank_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    split_work_value_rank_data(form, form.sort_week_value)
  end
end
function on_rbtn_total_rank_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    split_work_value_rank_data(form, form.sort_total_value)
  end
end
function on_btn_find_self_click(btn)
  local form = btn.ParentForm
  if nx_int(form.self_row) >= nx_int(0) then
    form.textgrid_work_value:SelectRow(form.self_row)
  end
end
function request_pray_form_info()
  custom_guild_luck_pray(CLIENT_MSG_OPEN_GUILD_PRAY)
end
function on_btn_pray_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local guildwarmanager = nx_value("GuildWarManager")
  if not nx_is_valid(guildwarmanager) then
    return
  end
  if form.guild_luck_value < form.pray_luck_consume then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19929"), 2)
    end
    return
  end
  custom_guild_luck_pray(CLIENT_MSG_LUCK_JITIAN)
end
function on_btn_boss_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local guildwarmanager = nx_value("GuildWarManager")
  if not nx_is_valid(guildwarmanager) then
    return
  end
  local format_str = "ui_guild_pray_ok_001"
  if form.domain_id > 0 then
    local domain_level = guildwarmanager:GetDomainLevel(form.domain_id)
    if domain_level == 1 then
      format_str = "ui_guild_pray_ok_002"
    elseif domain_level == 2 then
      format_str = "ui_guild_pray_ok_003"
    elseif domain_level == 3 then
      format_str = "ui_guild_pray_ok_004"
    end
  end
  local info = util_format_string(format_str)
  local res = util_form_confirm("", info)
  if res == "ok" then
    custom_guild_luck_pray(CLIENT_MSG_LUCK_PRAY)
  end
end
function on_server_msg(...)
  local form = nx_value(FORM_GUILF_PRAY)
  if not nx_is_valid(form) then
    return
  end
  local GuildManager = nx_value("GuildManager")
  if not nx_is_valid(GuildManager) then
    return
  end
  local size = table.getn(arg)
  if size < 8 then
    return
  end
  local guild_luck_value = arg[1]
  local pray_fight_time = arg[2]
  form.domain_id = arg[3]
  local jitian_time = arg[4]
  local pray_flag = arg[5]
  local player_week_work_value = arg[6]
  local player_total_work_value = arg[7]
  local str_guild_work = arg[8]
  form.sort_week_value = nx_string(GuildManager:SortStringByTwoElement(DATA_COL_NUM, 1, 3, str_guild_work))
  form.sort_total_value = nx_string(GuildManager:SortStringByTwoElement(DATA_COL_NUM, 2, 3, str_guild_work))
  form.rbtn_week_rank.Checked = true
  guild_luck_show(form, guild_luck_value)
  guild_luck_pray_fight_time(form, pray_fight_time)
  if form.domain_id <= 0 or jitian_time <= 0 or pray_flag == 1 then
    form.btn_boss.NormalImage = "gui\\common\\button\\btn_normal_forbid1.png"
    form.btn_boss.FocusImage = "gui\\common\\button\\btn_normal_forbid2.png"
    form.btn_boss.PushImage = "gui\\common\\button\\btn_normal_forbid.png"
  end
end
function split_work_value_rank_data(form, str_guild_work, sort_type)
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
  if not nx_is_valid(form.textgrid_work_value) then
    return
  end
  local rank_data = util_split_string(str_guild_work, ",")
  local count = table.getn(rank_data)
  if 0 < count then
    count = count - 1
  end
  if count <= 0 then
    return
  end
  if count < DATA_COL_NUM or math.mod(count, DATA_COL_NUM) ~= 0 then
    return
  end
  local key_name = client_player:QueryProp("Name")
  form.self_row = -1
  local player_num = count / DATA_COL_NUM
  form.textgrid_work_value:BeginUpdate()
  form.textgrid_work_value:ClearRow()
  local begin_index = DATA_COL_NUM
  for row = 0, player_num - 1 do
    if count < begin_index then
      break
    end
    form.textgrid_work_value:InsertRow(-1)
    local index = begin_index - 3
    form.textgrid_work_value:SetGridText(row, 0, nx_widestr(rank_data[index]))
    index = begin_index - 2
    form.textgrid_work_value:SetGridText(row, 1, nx_widestr(rank_data[index]))
    index = begin_index - 1
    form.textgrid_work_value:SetGridText(row, 2, nx_widestr(rank_data[index]))
    begin_index = begin_index + DATA_COL_NUM
    local temp_name = form.textgrid_work_value:GetGridText(row, 0)
    if nx_ws_equal(nx_widestr(key_name), nx_widestr(temp_name)) then
      form.self_row = row
    end
  end
  form.textgrid_work_value:EndUpdate()
end
function guild_luck_show(form, guild_luck_value)
  if not nx_is_valid(form) then
    return
  end
  if form.max_guild_luck <= 0 then
    return
  end
  form.guild_luck_value = guild_luck_value
  form.lbl_number.Text = nx_widestr(form.guild_luck_value)
  local pr_num = nx_int(GUILD_LUCK_VALUE_PRE * guild_luck_value / form.max_guild_luck)
  if pr_num <= nx_int(0) then
    return
  end
  for i = 1, nx_number(pr_num) do
    local lal_name = "lbl_pr_" .. nx_string(i)
    local lbl = form.groupbox_guild_luck:Find(lal_name)
    if not nx_is_valid(lbl) then
      return
    end
    lbl.Visible = true
  end
end
function guild_luck_hide(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, GUILD_LUCK_VALUE_PRE do
    local lal_name = "lbl_pr_" .. nx_string(i)
    local lbl = form.groupbox_guild_luck:Find(lal_name)
    if not nx_is_valid(lbl) then
      return
    end
    lbl.Visible = false
  end
end
function guild_luck_pray_fight_time(form, pray_fight_time)
  if not nx_is_valid(form) then
    return
  end
  if pray_fight_time <= 0 then
    form.lbl_last_time.Text = nx_widestr("")
    return
  end
  form.pray_fight_time = pray_fight_time
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_pray_fight_time", form)
    timer:Register(1000, -1, nx_current(), "on_update_pray_fight_time", form, -1, -1)
  end
end
function on_update_pray_fight_time(form, param1, param2)
  form.pray_fight_time = nx_number(form.pray_fight_time) - 1
  if form.pray_fight_time < 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_pray_fight_time", form)
    end
  else
    form.lbl_last_time.Text = get_format_time_text(form.pray_fight_time)
  end
end
function get_format_time_text(count_time)
  local format_time = nx_widestr("")
  if nx_number(count_time) >= 3600 then
    local hour = nx_int(count_time / 3600)
    local min = nx_int(math.mod(count_time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(count_time, 3600), 60))
    format_time = nx_widestr(string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec)))
  elseif nx_number(count_time) >= 60 then
    local min = nx_int(count_time / 60)
    local sec = nx_int(math.mod(count_time, 60))
    format_time = nx_widestr(string.format("00:%02d:%02d", nx_number(min), nx_number(sec)))
  else
    local sec = nx_int(count_time)
    format_time = nx_widestr(string.format("00:00:%02d", nx_number(sec)))
  end
  return format_time
end
function load_guild_luck_pray_ini(form)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(nx_int(ST_FUNCTION_GUILD_LUCK_JITIAN)) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Guild\\GuildLuck\\guild_luck_pray.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("GuildLuck")
  if sec_count < 0 then
    return
  end
  form.max_guild_luck = ini:ReadInteger(sec_count, "max_guild_luck", 7000)
  form.pray_luck_consume = ini:ReadInteger(sec_count, "pray_luck_consume", 7000)
end
function init_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local grid = form.textgrid_work_value
  grid:BeginUpdate()
  grid:ClearRow()
  grid.ColCount = DATA_COL_NUM - 1
  grid:EndUpdate()
end
function show_guild_luck_task(...)
  local form = nx_value(FORM_GUILF_PRAY)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 1 then
    return
  end
  local table_task_info = util_split_string(nx_string(arg[1]), ";")
  local count = table.getn(table_task_info)
  if count <= 0 or (count - 1) % 9 ~= 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local TaskManager = nx_value("TaskManager")
  if not nx_is_valid(TaskManager) then
    return
  end
  form.groupscrollbox_task.IsEditMode = true
  form.groupscrollbox_task:DeleteAll()
  for i = 1, count - 1, 9 do
    local task_id = table_task_info[i]
    local luck_value = table_task_info[i + 1]
    local task_scene = table_task_info[i + 2]
    local state = table_task_info[i + 3]
    local cur_pr = table_task_info[i + 4]
    local max_pr = table_task_info[i + 5]
    local title = table_task_info[i + 6]
    local context = table_task_info[i + 7]
    local prize = table_task_info[i + 8]
    local groupbox_one = create_ctrl("GroupBox", "groupbox_reward_" .. nx_string(task_id), form.groupbox_reward, form.groupscrollbox_task)
    if nx_is_valid(groupbox_one) then
      local cbtn_task_select = create_ctrl("CheckButton", "cbtn_task_select_" .. nx_string(task_id), form.cbtn_task_select, groupbox_one)
      if not nx_is_valid(cbtn_task_select) then
        return
      end
      nx_bind_script(cbtn_task_select, nx_current())
      nx_callback(cbtn_task_select, "on_checked_changed", "on_cbtn_task_checked_changed")
      groupbox_one.Height = cbtn_task_select.Height + achieve_rank_interval
      local btn_task_get = create_ctrl("Button", "btn_task_get_" .. nx_string(task_id), form.btn_task_get, groupbox_one)
      if not nx_is_valid(btn_task_get) then
        return
      end
      btn_task_get.task_id = task_id
      btn_task_get.task_state = state
      btn_task_get.task_scene = task_scene
      nx_bind_script(btn_task_get, nx_current())
      nx_callback(btn_task_get, "on_click", "on_btn_task_get_click")
      local lbl_task_name = create_ctrl("Label", "lbl_task_name_" .. nx_string(task_id), form.lbl_task_name, groupbox_one)
      if not nx_is_valid(lbl_task_name) then
        return
      end
      local lbl_task_pr = create_ctrl("Label", "lbl_task_pr_" .. nx_string(task_id), form.lbl_task_pr, groupbox_one)
      if not nx_is_valid(lbl_task_pr) then
        return
      end
      local lbl_task_desc = create_ctrl("Label", "lbl_task_desc_" .. nx_string(task_id), form.lbl_task_desc, groupbox_one)
      if not nx_is_valid(lbl_task_desc) then
        return
      end
      local lbl_task_luck = create_ctrl("Label", "lbl_task_luck_" .. nx_string(task_id), form.lbl_task_luck, groupbox_one)
      if not nx_is_valid(lbl_task_luck) then
        return
      end
      local lbl_task_luck_value = create_ctrl("Label", "lbl_task_luck_value_" .. nx_string(task_id), form.lbl_task_luck_value, groupbox_one)
      if not nx_is_valid(lbl_task_luck_value) then
        return
      end
      local imagegrid_task = create_ctrl("ImageGrid", "imagegrid_task_" .. nx_string(task_id), form.imagegrid_task, groupbox_one)
      if not nx_is_valid(imagegrid_task) then
        return
      end
      imagegrid_task:Clear()
      nx_bind_script(imagegrid_task, nx_current())
      nx_callback(imagegrid_task, "on_mousein_grid", "on_imagegrid_task_mousein_grid")
      nx_callback(imagegrid_task, "on_mouseout_grid", "on_imagegrid_task_mouseout_grid")
      local mltbox_desc = create_ctrl("MultiTextBox", "mltbox_desc_" .. nx_string(task_id), form.mltbox_desc, groupbox_one)
      if not nx_is_valid(mltbox_desc) then
        return
      end
      state_task_btn(btn_task_get, state)
      show_tesk_reward(imagegrid_task, prize)
      lbl_task_name.Text = gui.TextManager:GetText(title)
      lbl_task_pr.Text = nx_widestr(nx_string(cur_pr) .. "/" .. nx_string(max_pr))
      mltbox_desc.HtmlText = gui.TextManager:GetText(context)
      lbl_task_luck_value.Text = nx_widestr(luck_value)
    end
  end
  form.groupscrollbox_task.IsEditMode = false
  form.groupscrollbox_task:ResetChildrenYPos()
end
function state_task_btn(btn, state)
  if not nx_is_valid(btn) then
    return
  end
  if nx_number(state) == nx_number(0) then
    btn.Enabled = true
    btn.Text = util_text("ui_guild_task_btn_3")
  elseif nx_number(state) == nx_number(1) then
    btn.Enabled = true
    btn.Text = util_text("ui_guild_task_btn_1")
  elseif nx_number(state) == nx_number(3) then
    btn.Enabled = false
    btn.Text = util_text("ui_guild_task_btn_2")
  elseif nx_number(state) == nx_number(4) then
    btn.Enabled = false
    btn.Text = util_text("ui_guild_task_btn_4")
  else
    btn.Enabled = false
    btn.Text = util_text("ui_guild_task_btn_5")
  end
end
function show_tesk_reward(imagegrid_task, task_reward)
  if not nx_is_valid(imagegrid_task) then
    return
  end
  local table_prize_info = util_split_string(task_reward, ",")
  if nx_number(table.getn(table_prize_info)) <= nx_number(TASK_PRIZE_NUM) then
    return
  end
  local index = 0
  for i = 11, 18, 2 do
    if nx_string(table_prize_info[i]) ~= "0" then
      local id = table_prize_info[i]
      local num = table_prize_info[i + 1]
      local photo = get_icon(0, nx_string(id))
      local flag_add = imagegrid_task:AddItem(index, nx_string(photo), nx_widestr(id), nx_int(num), 0)
      if flag_add then
        index = index + 1
      end
    end
  end
end
function on_imagegrid_task_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_task_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_task_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gbox = cbtn.Parent
  if not nx_is_valid(gbox) then
    return
  end
  local lbl_task_desc = form.lbl_task_desc
  if cbtn.Checked then
    gbox.Height = form.lbl_task_desc.Height + cbtn.Height + achieve_rank_interval + achieve_quanfu_height
    lbl_task_desc.Top = achieve_lbl_back_pix1
    lbl_task_desc.Height = lbl_task_desc.Height
  else
    gbox.Height = cbtn.Height + achieve_rank_interval
    lbl_task_desc.Top = achieve_lbl_back_pix2
  end
  form.groupscrollbox_task:ResetChildrenYPos()
end
function on_btn_task_get_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  if nx_number(btn.task_id) <= nx_number(0) then
    return
  end
  if nx_number(btn.task_state) == nx_number(0) then
    custom_guild_luck_pray(CLIENT_MSG_SUBMIT_LUCK_TASK, nx_int(btn.task_id))
  elseif nx_number(btn.task_state) == nx_number(1) then
    if nx_number(btn.task_scene) > nx_number(0) then
      local res = util_form_confirm("", util_format_string("ui_guildluck_chuansong"))
      if res == "ok" then
        custom_guild_luck_pray(CLIENT_MSG_ACCEPT_LUCK_TASK, nx_int(btn.task_id))
      end
    else
      custom_guild_luck_pray(CLIENT_MSG_ACCEPT_LUCK_TASK, nx_int(btn.task_id))
    end
  end
end
