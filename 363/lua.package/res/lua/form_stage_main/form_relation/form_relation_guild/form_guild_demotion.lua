require("custom_sender")
require("util_functions")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\capital_funs")
local SUB_CUSTOMMSG_REQUEST_DEGRADE_INFO = 73
local ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS = 789
local ini_degrade_tab = {}
local MAX_GUILD_LEVEL = 5
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  form.lbl__dif_hotness.Text = nx_widestr("")
  form.lbl_dif_money.Text = nx_widestr("")
  send_res_data()
  degrade_info_ini()
  show_degrade_info(form)
  return 1
end
function send_res_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DEGRADE_INFO))
end
function on_recv_degrade_info(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_demotion")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size < 2 then
    return
  end
  local dif_mopney = nx_int64(arg[1])
  local dif_hotness = nx_int64(arg[2])
  local gui = nx_value("gui")
  if nx_int64(dif_mopney) > nx_int64(0) then
    local money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int64(dif_mopney)))
    form.lbl_dif_money.ForeColor = "255,0,0,255"
    form.lbl_dif_money.Text = nx_widestr(money)
  else
    form.lbl_dif_money.ForeColor = "255,255,0,0"
    local temp_money = nx_int64(dif_mopney) * nx_int(-1)
    local money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int64(temp_money)))
    form.lbl_dif_money.Text = nx_widestr("-") .. nx_widestr(money)
  end
  if nx_int64(dif_hotness) > nx_int64(0) then
    form.lbl__dif_hotness.ForeColor = "255,0,0,255"
  else
    form.lbl__dif_hotness.ForeColor = "255,255,0,0"
  end
  form.lbl__dif_hotness.Text = nx_widestr(dif_hotness)
end
function show_degrade_info(form)
  for i = 1, nx_number(MAX_GUILD_LEVEL) do
    if ini_degrade_tab[i] ~= nil then
      local lbl_daly_hotness = form.groupbox_1:Find("lbl_daly_hotness_" .. nx_string(i))
      if nx_is_valid(lbl_daly_hotness) then
        lbl_daly_hotness.Text = nx_widestr(ini_degrade_tab[i].dailycosthotness)
      end
      local lbl_daly_money = form.groupbox_1:Find("lbl_daly_money_" .. nx_string(i))
      if nx_is_valid(lbl_daly_money) then
        lbl_daly_money.Text = get_captial_text(ini_degrade_tab[i].dailycostcapital)
      end
      local lbl_min_hotness = form.groupbox_1:Find("lbl_min_hotness_" .. nx_string(i))
      if nx_is_valid(lbl_min_hotness) then
        lbl_min_hotness.Text = nx_widestr(ini_degrade_tab[i].minhotness)
      end
      local lbl_min_money = form.groupbox_1:Find("lbl_min_money_" .. nx_string(i))
      if nx_is_valid(lbl_min_money) then
        lbl_min_money.Text = get_captial_text(ini_degrade_tab[i].minmoney)
      end
    end
  end
end
function degrade_info_ini()
  local file = "share\\Guild\\guild_limit_cost.ini"
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    file = "share\\Guild\\guild_limit_cost_plus.ini"
  end
  local ini = nx_execute("util_functions", "get_ini", file)
  if not nx_is_valid(ini) then
    return
  end
  ini_degrade_tab = {}
  local section_count = ini:GetSectionCount()
  if section_count <= 0 then
    return
  end
  for i = nx_number(0), nx_number(section_count - 1) do
    local section = nx_number(ini:GetSectionByIndex(i))
    local item_count = nx_number(ini:GetSectionItemCount(i))
    if 0 < item_count then
      local str_info = nx_string(ini:GetSectionItemValue(i, 0))
      local str_list = util_split_string(str_info, ",")
      local tab = {}
      tab.dailycostcapital = str_list[2]
      tab.dailycosthotness = str_list[5]
      tab.minmoney = str_list[6]
      tab.minhotness = str_list[7]
      table.insert(ini_degrade_tab, section, tab)
    end
  end
end
