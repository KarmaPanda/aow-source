require("custom_sender")
local m_GamblePath_Msg = "form_stage_main\\form_huashan\\form_gamble_main_msg"
local m_GamblePath_Form = {
  [1] = "form_stage_main\\form_huashan\\form_gamble_main_huashan",
  [2] = "form_stage_main\\form_huashan\\form_gamble_main_gold"
}
Gamble_CToS_QueryNowGamble = 0
Gamble_CToS_BuyOneGamble = 1
Gamble_CToS_QueryHistory = 2
Gamble_CToS_QueryPlayerMsg = 3
Gamble_CToS_QueryMyGamble = 4
Gamble_CToS_RefrestProject = 5
local m_GambleFunc_Name = {
  [0] = "on_server_msg_Gamble_SToC_QueryNowGamble",
  [1] = "on_server_msg_Gamble_SToC_BuySuccess",
  [2] = "on_server_msg_Gamble_SToC_QueryHistory",
  [3] = "on_server_msg_Gamble_SToC_QueryPlayerMsg",
  [4] = "on_server_msg_Gamble_SToC_QueryMyGamble",
  [5] = "on_server_msg_Gamble_SToC_RefrestProject"
}
function on_custom_msg(child_msg_id, ...)
  local child_msg_id = nx_number(child_msg_id)
  if child_msg_id < 0 then
    return
  end
  nx_execute("custom_sender", "custom_request_gamble", nx_int(child_msg_id), unpack(arg))
end
function on_server_msg(child_msg_id, itype, ...)
  local child_msg_id = nx_number(child_msg_id)
  local itype = nx_number(itype)
  local path = m_GamblePath_Form[itype]
  if nil == path or "" == path then
    return
  end
  local form = nx_value(path)
  if not nx_is_valid(form) then
    return
  end
  local func = m_GambleFunc_Name[child_msg_id]
  if nil == func or "" == func then
    return
  end
  if not nx_find_script(path, func) then
    return
  end
  nx_execute(path, func, form, unpack(arg))
end
