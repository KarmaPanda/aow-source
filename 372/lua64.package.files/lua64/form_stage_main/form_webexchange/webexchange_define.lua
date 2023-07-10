G_BOX_SIZE = 4
G_SILVER_BASE = 1000
G_FLAG_OPEN = 5
G_FLAG_CLOSE = 6
G_FLAG_SELL_ITEM = 7
G_GLAG_SELL_ROLE = 19
function sendserver_msg(type, ...)
  nx_execute("custom_sender", "custom_send_webexchange_msg", type, unpack(arg))
end
function show_tip(info, type)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  SystemCenterInfo:ShowSystemCenterInfo(info, type)
end
