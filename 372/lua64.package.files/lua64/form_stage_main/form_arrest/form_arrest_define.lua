require("share\\capital_define")
WEN_TO_DING = 1000000
WEN_TO_LIANG = 1000
ARREST_CUSTOMMSG_APPLY_POLICE = 0
ARREST_CUSTOMMSG_PUBLIC_ARREST = 1
ARREST_CUSTOMMSG_ACCEPT_ARREST = 2
ARREST_CUSTOMMSG_ADD_MONEY = 3
ARREST_CUSTOMMSG_RECOVER_ARREST = 4
ARREST_CUSTOMMSG_GIVEUP_ARREST = 5
ARREST_CUSTOMMSG_QUERY_ARREST = 6
ARREST_CUSTOMMSG_QUERY_BY_SORT = 7
ARREST_CUSTOMMSG_SEARCH_ARREST = 8
ARREST_CUSTOMMSG_ARREST_ACCUSE = 9
ARREST_CUSTOMMSG_ARREST_VISIT = 10
arrest_detail_publish = 0
arrest_detail_add_reward = 1
arrest_detail_accept = 2
arrest_detail_publish_manger = 3
arrest_detail_accept_manger = 4
arrest_detail_wanted_manger = 5
arrest_detail_all = 6
arrest_tocustom_show_apply = 0
arrest_tocustom_show_pulish = 1
arrest_tocustom_show_accept = 2
arrest_tocustom_show_reward = 3
arrest_tocustom_show_detail = 4
arrest_tocustom_show_visit = 5
arrest_tocustom_show_query = 6
arrest_tocustom_show_pulish_confirm = 7
arrest_tocustom_show_reward_confirm = 8
arrest_min_money = 0
arrest_unit_money = 1
arrest_be_wanted_rate = 1
arrest_max_tasknum = 5
arrest_police_tipPK1 = 0
arrest_police_tipPK2 = 0
arrest_police_tipPK3 = 0
arrest_police_MaxPK = 0
arrest_police_need_money = 0
arrest_prison_div = 1
arrest_max_prison = 1
local have_read_ini = false
function get_arrest_ini()
  if have_read_ini == true then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\ArrestWarrant.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("Arrest")
  if sec_index < 0 then
    return
  end
  arrest_min_money = ini:ReadInteger(sec_index, "MinMoney", 0)
  arrest_unit_money = ini:ReadInteger(sec_index, "UnitMoney", 1)
  arrest_max_tasknum = ini:ReadInteger(sec_index, "MaxTaskNum", 5)
  sec_index = ini:FindSectionIndex("Police")
  if sec_index < 0 then
    return
  end
  arrest_police_tipPK1 = ini:ReadInteger(sec_index, "TipPK1", 0)
  arrest_police_tipPK2 = ini:ReadInteger(sec_index, "TipPK2", 0)
  arrest_police_tipPK3 = ini:ReadInteger(sec_index, "TipPK3", 0)
  arrest_police_MaxPK = ini:ReadInteger(sec_index, "MaxPK", 0)
  arrest_police_need_money = ini:ReadInteger(sec_index, "NeedMoney", 0)
  sec_index = ini:FindSectionIndex("Wanted")
  if sec_index < 0 then
    return
  end
  arrest_prison_div = ini:ReadInteger(sec_index, "PrisonDivisor", 1)
  arrest_max_prison = ini:ReadInteger(sec_index, "MaxPrison", 0)
  arrest_be_wanted_rate = ini:ReadInteger(sec_index, "BeWantedRate", 1)
  have_read_ini = true
  return
end
function get_arrest_publish_need_info()
  return arrest_min_money, arrest_unit_money, arrest_be_wanted_rate, arrest_max_tasknum
end
function get_arrest_add_need_info()
  return arrest_unit_money, arrest_prison_div, arrest_max_prison, arrest_be_wanted_rate
end
function get_arrest_receive_need_info()
  return arrest_unit_money, arrest_prison_div, arrest_max_prison, arrest_be_wanted_rate
end
function get_arrest_manage_need_info()
  return arrest_unit_money, arrest_prison_div, arrest_max_prison
end
function get_arrest_apply_police_need_info()
  return arrest_police_need_money, arrest_police_tipPK1
end
function format_money_info(ding, liang, wen)
  return nx_widestr(ding) .. nx_widestr(util_text("ui_Ding")) .. nx_widestr(liang) .. nx_widestr(util_text("ui_liang")) .. nx_widestr(wen) .. nx_widestr(util_text("ui_wen"))
end
function money_break(wen)
  local money_ding = nx_int(wen / WEN_TO_DING)
  local money_liang = nx_int(wen / WEN_TO_LIANG) - money_ding * 1000
  local money_wen = nx_int(wen) - money_ding * WEN_TO_DING - money_liang * WEN_TO_LIANG
  return money_ding, money_liang, money_wen
end
function money_info(wen)
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return 0
  end
  local format_money = mgr:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(wen))
  return format_money
end
