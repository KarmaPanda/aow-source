require("util_gui")
require("util_functions")
function getIniValueEx(level)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\stall.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\Rule\\stall.ini " .. get_msg_str("msg_120"))
    return 0, 0, 0
  end
  local section_name = "Rank_" .. nx_string(level)
  if not ini:FindSection(nx_string(section_name)) then
    return 0, 0, 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(section_name))
  if sec_index < 0 then
    return 0, 0, 0
  end
  local lev = ini:ReadString(sec_index, "Level", "0")
  if nx_int(lev) == nx_int(level) then
    local SellCount = ini:ReadString(sec_index, "SellCount", "0")
    local BuyCount = ini:ReadString(sec_index, "BuyCount", "0")
    local Gold = ini:ReadString(sec_index, "Gold", "0")
    return nx_int64(SellCount), nx_int64(BuyCount), nx_int64(Gold)
  end
  return 0, 0, 0
end
function getIniRuleValue(key)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\stall.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\Rule\\stall.ini " .. get_msg_str("msg_120"))
    return 0
  end
  local section_name = "Rule"
  if not ini:FindSection(nx_string(section_name)) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(section_name))
  if sec_index < 0 then
    return 0
  end
  local value = ini:ReadString(sec_index, key, "0")
  return value
end
