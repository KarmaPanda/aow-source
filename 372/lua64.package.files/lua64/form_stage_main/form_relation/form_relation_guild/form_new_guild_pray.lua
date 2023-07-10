require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\switch\\switch_define")
require("share\\client_custom_define")
local FORM_PRAY = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_pray"
local CLIENT_MSG_LUCK_PRAY = 0
local CLIENT_MSG_OPEN_GUILD_PRAY = 1
local CLIENT_MSG_LUCK_JITIAN = 2
local GUILD_LUCK_VALUE_PRE = 12
local DATA_COL_NUM = 4
local ST_FUNCTION_GUILD_LUCK_JITIAN = 640
function main_form_init(self)
  self.Fixed = true
  self.max_guild_luck = 0
  self.pray_luck_consume = 0
  self.guild_luck_value = 0
  self.self_row = -1
  self.sort_week_value = nx_widestr("")
  self.sort_total_value = nx_widestr("")
end
function on_main_form_open(self)
  init_rank_grid(self)
  guild_luck_hide(self)
  load_guild_luck_pray_ini(self)
  request_pray_form_info()
  self.rbtn_guild_luck.Checked = true
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function request_pray_form_info()
  custom_guild_luck_pray(CLIENT_MSG_OPEN_GUILD_PRAY)
end
function on_rbtn_guild_luck_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_guild_rank.Visible = false
    form.groupbox_guild_pray.Visible = true
  end
end
function on_rbtn_guild_pray_checked_changed(rbtn)
end
function on_rbtn_week_rank_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    split_work_value_rank_data(form, form.sort_week_value)
  end
end
function on_rbtn_total_rank_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    split_work_value_rank_data(form, form.sort_total_value)
  end
end
function on_btn_find_self_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.self_row) >= nx_int(0) then
    form.textgrid_work_value:SelectRow(form.self_row)
  end
end
function on_btn_jitian_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(nx_int(ST_FUNCTION_GUILD_LUCK_JITIAN)) then
    return
  end
  if nx_int(form.guild_luck_value) < nx_int(form.pray_luck_consume) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19929"), 2)
    end
    return
  end
  custom_guild_luck_pray(CLIENT_MSG_LUCK_JITIAN)
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
  form.lbl_28.Text = nx_widestr(form.max_guild_luck)
  form.pray_luck_consume = ini:ReadInteger(sec_count, "pray_luck_consume", 7000)
end
function guild_luck_show(form, guild_luck_value)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.max_guild_luck) <= nx_int(0) then
    return
  end
  local pr_num = GUILD_LUCK_VALUE_PRE * guild_luck_value / form.max_guild_luck
  if pr_num <= 0 then
    return
  end
  for i = 1, pr_num do
    local lbl_name = "lbl_pr_" .. nx_string(i)
    local lbl = form.groupbox_guild_luck:Find(lbl_name)
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
    local lbl_name = "lbl_pr_" .. nx_string(i)
    local lbl = form.groupbox_guild_luck:Find(lbl_name)
    if not nx_is_valid(lbl) then
      return
    end
    lbl.Visible = false
  end
end
function init_rank_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local grid = form.textgrid_work_value
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid:ClearRow()
  grid.ColCount = DATA_COL_NUM - 1
  grid:EndUpdate()
end
function split_work_value_rank_data(form, str_guild_work)
end
function on_server_msg(...)
  local form = nx_value(FORM_PRAY)
  if not nx_is_valid(form) then
    return
  end
  local GuildManager = nx_value("GuildManager")
  if not nx_is_valid(GuildManager) then
    return
  end
  if table.getn(arg) < 8 then
    return
  end
  local guild_luck_value = arg[1]
  form.guild_luck_value = guild_luck_value
  form.lbl_number.Text = nx_widestr(form.guild_luck_value)
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
  local guildwarmanager = nx_value("GuildWarManager")
  if not nx_is_valid(guildwarmanager) then
    return
  end
  guild_luck_show(form, guild_luck_value)
end
