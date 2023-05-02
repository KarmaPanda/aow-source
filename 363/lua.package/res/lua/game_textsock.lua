require("util_functions")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(nx_string(info))
  end
end
function game_textsock_init(self)
  nx_callback(self, "on_receive", "game_textsock_receieve")
  nx_callback(self, "on_connected", "game_textsock_connected")
  nx_callback(self, "on_connect_fail", "game_textsock_connect_fail")
  nx_callback(self, "on_close", "game_textsock_close")
  return 1
end
function game_textsock_receieve(self, data)
  nx_log("on_receive")
  nx_gen_event(self, "event_svr_info", data)
  return 1
end
function game_textsock_connected(self)
  console_log(util_text("ui_ConnectOk"))
  nx_log("on_connected")
  nx_gen_event(self, "event_connect", "succeed")
  return 1
end
function game_textsock_connect_fail(self)
  console_log(util_text("ui_ConnectFailed"))
  nx_log("on_connect_fail")
  nx_gen_event(self, "event_connect", "failed")
  return 1
end
function game_textsock_close(self)
  console_log(util_text("ui_ConnectionClose"))
  nx_log("on_close")
  nx_gen_event(self, "event_connect", "closed")
  return 1
end
