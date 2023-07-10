require("const_define")
function start_ping(ip_address, port, sendstring, timeout)
  local fxping = nx_value("FxPing")
  if not nx_is_valid(fxping) then
    fxping = nx_create("FxPing")
  end
  if not nx_is_valid(fxping) then
    return
  end
  fxping.IPAddress = ip_address
  fxping.SendString = "ping"
  fxping.do_ping = false
  fxping.is_end = false
  nx_bind_script(fxping, "net_ping", "net_ping_init", fxping)
end
function stop_ping()
  local fxping = nx_value("FxPing")
  if not nx_is_valid(fxping) then
    return
  end
  nx_destroy(fxping)
end
function net_ping_init(fxping)
  nx_callback(fxping, "on_ping_end", "on_ping_end")
end
function on_ping_end(fxping, ipaddress, pingvalue)
  if 200 < pingvalue then
    pingvalue = 0
  else
    pingvalue = 100 - pingvalue / 2
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "set_net_quality", pingvalue)
end
