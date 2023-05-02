require("util_gui")
CSM_PUBLISH = 1
CSM_BUY = 2
CSM_UNSELL = 3
CSM_QUERY = 4
CSM_QUERY_HISTORY = 7
local show_consign_form = 51
local show_buy_capital = 50
function OnServerMsg(self, ...)
  local cmd = nx_number(arg[1])
  if cmd == CSM_PUBLISH or cmd == CSM_BUY or cmd == CSM_UNSELL or cmd == CSM_QUERY or cmd == CSM_QUERY_HISTORY then
    nx_execute("form_stage_main\\form_consign\\form_consign", "on_server_msg", cmd, unpack(arg))
  elseif cmd == show_consign_form then
    nx_execute("form_stage_main\\form_consign\\form_consign", "auto_show_hide_form_consign")
  elseif cmd == show_buy_capital then
    nx_execute("form_stage_main\\form_consign\\form_buy_capital", "show_hide_buy_capital_form")
  end
end
