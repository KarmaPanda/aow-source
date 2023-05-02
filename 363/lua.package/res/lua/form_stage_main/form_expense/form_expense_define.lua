require("share\\client_custom_define")
require("util_functions")
G_PRIZE_ITEM_ROWS = 4
G_PRIZE_ITEM_COLS = 4
G_FORM_CONSUME_BACK_MAIN = "form_stage_main\\form_expense\\form_expense_back"
G_FORM_CONSUME_BACK_PRIZE = "form_stage_main\\form_expense\\form_expense_box"
G_CBM_TACK = 1
G_CBM_QUERY = 2
G_CBS_NONE = 0
G_CBS_TAKED = 1
function lua_sendmsg_to_server(...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CONSUME_BACK), unpack(arg))
  end
end
function lua_sysinfo(strid, ...)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_format_string(strid, unpack(arg)), 2)
  end
end
