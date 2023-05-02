require("custom_sender")
require("util_functions")
require("util_gui")
require("share\\client_custom_define")
local SUB_CUSTOMMSG_REQUEST_YUNBIAO_DATA = 69
local GUILD_INTERACT_ESCORT_NORMAL = 1
local GUILD_INTERACT_ESCORT_PROBABILITY = 2
local GUILD_INTERACT_ESCORT_GOLDEN = 3
local GUILD_INTERACT_ESCORT_SZGOLDEN = 4
function main_form_init(self)
  self.Fixed = true
  self.type_common_max = 0
  self.type_rand_max = 0
  self.type_gold_max = 0
  self.type_szgold_max = 0
  self.guild_level = 0
end
function on_main_form_open(form)
  form.lbl_common.Text = nx_widestr("")
  form.lbl_rand.Text = nx_widestr("")
  form.lbl_gold.Text = nx_widestr("")
  form.lbl_szgold.Text = nx_widestr("")
  send_res_data()
  return 1
end
function on_recv_yunbiao_info(guild_level, ...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_activity")
  if not nx_is_valid(form) then
    return
  end
  get_guild_max_times(form, guild_level)
  init_info(form)
  local size = table.getn(arg)
  if size <= 0 or size % 2 ~= 0 then
    return 0
  end
  local rows = size / 2
  for i = 1, rows do
    local base = (i - 1) * 2
    local yb_type = nx_string(arg[base + 1])
    local times = nx_int(arg[base + 2])
    reset_info(form, yb_type, nx_int(times))
  end
end
function init_info(form)
  form.lbl_common.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.type_common_max)
  form.lbl_rand.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.type_rand_max)
  form.lbl_gold.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.type_gold_max)
  form.lbl_szgold.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.type_szgold_max)
end
function reset_info(form, yb_type, times)
  if not nx_is_valid(form) then
    return false
  end
  if nx_int(yb_type) == nx_int(GUILD_INTERACT_ESCORT_NORMAL) then
    form.lbl_common.Text = nx_widestr(times) .. nx_widestr("/") .. nx_widestr(form.type_common_max)
  elseif nx_int(yb_type) == nx_int(GUILD_INTERACT_ESCORT_PROBABILITY) then
    form.lbl_rand.Text = nx_widestr(times) .. nx_widestr("/") .. nx_widestr(form.type_rand_max)
  elseif nx_int(yb_type) == nx_int(GUILD_INTERACT_ESCORT_GOLDEN) then
    form.lbl_gold.Text = nx_widestr(times) .. nx_widestr("/") .. nx_widestr(form.type_gold_max)
  elseif nx_int(yb_type) == nx_int(GUILD_INTERACT_ESCORT_SZGOLDEN) then
    form.lbl_szgold.Text = nx_widestr(times) .. nx_widestr("/") .. nx_widestr(form.type_szgold_max)
  end
end
function send_res_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_YUNBIAO_DATA))
end
function get_guild_max_times(form, guild_level)
  if guild_level == 0 then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Guild\\guild_interact.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section
  for i = 1, 4 do
    local index = ini:FindSectionIndex(nx_string(i))
    local value = ini:GetSectionItemValue(index, guild_level - 1)
    local args = util_split_string(value, ",")
    local max_times = nx_int(args[2])
    if i == 1 then
      form.type_common_max = max_times
    elseif i == 2 then
      form.type_rand_max = max_times
    elseif i == 3 then
      form.type_gold_max = max_times
    elseif i == 4 then
      form.type_szgold_max = max_times
    end
  end
end
