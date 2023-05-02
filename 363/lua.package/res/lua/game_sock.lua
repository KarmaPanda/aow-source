require("util_functions")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(nx_string(info))
  end
end
function game_sock_init(self)
  nx_callback(self, "on_connected", "game_sock_connected")
  nx_callback(self, "on_connect_fail", "game_sock_connect_fail")
  nx_callback(self, "on_close", "game_sock_close")
  self.Sender.last_send = -1
  self.Sender.last_stop_x = 0
  self.Sender.last_stop_y = 0
  self.Sender.last_stop_z = 0
  self.Sender.last_stop_orient = 0
  self.cant_reconnect = false
  self.try_reconnect = false
  self.reconnect_count = 0
  self.error_code = 0
  return 1
end
function game_sock_connected(self)
  console_log(util_text("ui_ConnectOk"))
  nx_log("on_connected")
  if try_reconnect_connected(self) then
    return 1
  end
  nx_gen_event(self, "event_connect", "succeed")
  return 1
end
function game_sock_connect_fail(self)
  console_log(util_text("ui_ConnectFailed"))
  nx_log("on_connect_fail")
  if try_reconnect_connectfailed(self) then
    return 1
  end
  nx_gen_event(self, "event_connect", "failed")
  return 1
end
function game_sock_close(self)
  local gui = nx_value("gui")
  gui.gui_close_allsystem_value = 0
  console_log(util_text("ui_ConnectionClose"))
  nx_log("on_close")
  local game_config = nx_value("game_config")
  if game_config.switch_server then
    start_switch_server()
    return 1
  end
  if game_config.switch_normal_server or game_config.back_normal_server then
    start_switch_server()
    return 1
  end
  if is_try_reconnect(self) then
    return 1
  end
  nx_gen_event(self, "event_connect", "closed")
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    local scenario_manager = nx_value("scenario_npc_manager")
    if nx_is_valid(scenario_manager) then
      scenario_manager:StopScenario()
    end
  end
  local stage = nx_value("stage")
  if stage == "main" then
    nx_execute("form_stage_main\\form_movie_new", "close_movie_form")
  end
  if stage == "roles" or stage == "create" or stage == "main" then
    console_log("cur_stage = " .. stage)
    ShowMovieSaveForm()
    local gui = nx_value("gui")
    local ClientDataFetch = nx_value("ClientDataFetch")
    if nx_is_valid(ClientDataFetch) then
      ClientDataFetch:SendRequest(14, 0, 0, "")
    end
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
    if not nx_is_valid(dialog) then
      return
    end
    local game_test = false
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_test = game_visual.GameTest
    end
    dialog.cancel_btn.Visible = false
    dialog.mltbox_info.HtmlText = gui.TextManager:GetText("ui_net_close_info")
    if game_test then
      dialog.ok_btn.Text = gui.TextManager:GetText("ui_net_close_reboot")
    else
      dialog.ok_btn.Text = gui.TextManager:GetText("ui_exitgame")
    end
    if stage == "main" then
      local error_code = self.error_code
      if nx_int(20116) ~= nx_int(error_code) and nx_int(20122) ~= nx_int(error_code) and nx_int(51004) ~= nx_int(error_code) then
        dialog.mltbox_info.HtmlText = gui.TextManager:GetText("ui_net_close_wait")
        self.cant_reconnect = false
        self.try_reconnect = true
        self.reconnect_count = 0
        self.dialog = dialog
        nx_set_value("player_ready", false)
        nx_set_value("scene_ready", false)
        local world = nx_value("world")
        local game_control = world.MainScene.game_control
        if nx_is_valid(game_control) then
          game_control.AllowControl = false
        end
        nx_execute(nx_current(), "try_reconnect1_server", self)
      end
    end
    dialog.ok_btn.Left = dialog.cancel_btn.Left
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "breakconnect_confirm_return")
    nx_kill(nx_current(), "try_reconnect1_server", self)
    if game_test then
      nx_execute("gui", "on_sock_close")
      nx_execute("stage", "set_current_stage", "login")
    else
      nx_execute("main", "direct_exit_game")
    end
  end
  return 1
end
function ShowMovieSaveForm()
  local MovieSaver = nx_value("MovieSaverModule")
  if not nx_is_valid(MovieSaver) then
    return
  end
  local bRet = MovieSaver:IsRecording()
  if bRet == true then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_movie_save", true, false)
    dialog:ShowModal()
    nx_wait_event(100000000, dialog, "MovieSaver")
  end
end
function try_reconnect_connected(self)
  if nx_find_custom(self, "try_reconnect") and self.try_reconnect then
    local game_client = nx_value("game_client")
    game_client:ClearAll()
    game_client.need_reload_main_form = true
    try_reconnect2_login(self)
    return true
  end
  return false
end
function try_reconnect_connectfailed(self)
  if nx_find_custom(self, "try_reconnect") and self.try_reconnect and not self.cant_reconnect then
    nx_execute(nx_current(), "try_reconnect1_server", self)
    return true
  end
  return false
end
function is_try_reconnect(self)
  if self.try_reconnect then
    try_reconnect1_server(self)
    return true
  end
  return false
end
function try_reconnect1_server(self)
  console_log("try_reconnect_server")
  self.try_reconnect = true
  if self.Connected then
    self:Disconnect()
    console_log("Disconnect...")
  end
  if not nx_find_custom(self, "reconnect_count") then
    self.reconnect_count = 0
  end
  self.reconnect_count = self.reconnect_count + 1
  if self.reconnect_count > 3 then
    self.cant_reconnect = true
    reconnect_failed(true)
    return
  end
  local time = 0
  if self.reconnect_count == 1 then
    time = 25
  else
    time = math.random(5) + 10
  end
  console_log("random_time = " .. nx_string(time))
  nx_pause(time)
  self:Connect(nx_string(self.address), nx_int(self.port))
end
function try_reconnect2_login(self)
  console_log("try_reconnect_login")
  local sender = self.Sender
  if nx_is_valid(sender) then
    sender.try_reconnect = true
    local receiver = self.Receiver
    receiver.try_reconnect = true
    local game_config = nx_value("game_config_info")
    console_log("reconnect account=" .. nx_string(self.account) .. " game_config_info=" .. nx_string(game_config.ReconKey))
    sender:LoginReconnect(nx_string(self.account), nx_string(game_config.ReconKey))
  end
end
function reconnect_success()
  console_log("if reconnect then success")
  local sock = nx_value("game_sock")
  if not sock.Connected then
    return
  end
  if nx_find_custom(sock, "dialog") and nx_is_valid(sock.dialog) then
    sock.dialog:Close()
    if nx_is_valid(sock.dialog) then
      nx_destroy(sock.dialog)
    end
  end
  local world = nx_value("world")
  if nx_find_custom(world.MainScene, "game_control") then
    local game_control = world.MainScene.game_control
    if nx_is_valid(game_control) then
      game_control.AllowControl = true
    end
  end
  sock.cant_reconnect = false
  sock.try_reconnect = false
  sock.reconnect_count = 0
  sock.Sender.try_reconnect = false
  sock.Receiver.try_reconnect = false
  nx_kill(nx_current(), "game_sock_close", sock)
end
function reconnect_failed(self_call)
  console_log("reconnect_failed")
  local sock = nx_value("game_sock")
  if sock.Connected then
    sock:Disconnect()
    console_log("Disconnect...")
  end
  sock.cant_reconnect = true
  sock.try_reconnect = false
  sock.Sender.try_reconnect = false
  sock.Receiver.try_reconnect = false
  if self_call == nil or not self_call then
    nx_kill(nx_current(), "try_reconnect1_server", sock)
  end
  if nx_find_custom(sock, "dialog") and nx_is_valid(sock.dialog) then
    local gui = nx_value("gui")
    sock.dialog.mltbox_info.HtmlText = gui.TextManager:GetText("ui_net_reconnect_failed")
  end
end
function cross_server_ready()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_log("[cross server ready] game config.")
    return
  end
  if game_config.res_login then
    nx_log("[cross server ready] res login.")
    return
  end
  if not game_config.switch_server then
    nx_log("[cross server ready] switch server.")
    return
  end
  game_config.res_login = false
  nx_log("[cross server ready] cross server.")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_close_scene", true, false)
  if nx_is_valid(dialog) then
    dialog.mode = "close"
    dialog:ShowModal()
    local res = nx_wait_event(100000000, nx_null(), "login_game")
    if nx_is_valid(dialog) then
      nx_log("[cross server ready] login_game result is " .. nx_string(res))
      dialog:Close()
      nx_destroy(dialog)
    end
    if res == "failed" then
      game_config.switch_server = false
      game_config.switch_ip = ""
      game_config.switch_port = 0
      local game_info = nx_value("game_config_info")
      nx_log("[CROSS SRV]login falied return normal")
      nx_log("[cross failed]return normal:" .. nx_string(game_config.login_addr) .. ":" .. nx_string(game_config.login_port))
      game_config.ret_normal_server = true
      nx_execute("client", "login_game", game_config.login_addr, game_config.login_port, "", "", game_config.login_account, "", game_info.ReconKey, "", "")
    elseif res == "timeout" then
      nx_log("login game time out")
      if game_config.is_login_switch_server then
        game_config.is_login_switch_server = false
        game_config.is_cross_ready = true
        start_switch_server()
      else
        nx_execute("stage", "set_current_stage", "login")
        nx_execute("client", "close_connect")
      end
    else
      nx_log("[cross server ready] reset switch info")
    end
  else
    nx_log("[cross server ready] close scene.")
  end
end
function start_switch_server()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(3000, 1, "game_sock", "on_delay_connect", game_config, -1, -1)
  end
end
function on_delay_connect(game_config)
  if not nx_is_valid(game_config) then
    return
  end
  nx_log("on_delay_connect")
  if not game_config.switch_server and not game_config.switch_normal_server and not game_config.back_normal_server then
    return
  end
  local game_info = nx_value("game_config_info")
  if not game_config.back_normal_server then
    nx_log("before" .. " - " .. nx_string(ip) .. ":" .. nx_string(port))
    local res, ip, port = get_crossserver_info(game_config.switch_ip, game_config.switch_port)
    nx_log("after" .. " - " .. nx_string(res) .. ":" .. nx_string(ip) .. ":" .. nx_string(port))
    if res then
      game_config.switch_ip = ip
      game_config.switch_port = port
    end
  end
  nx_log(" - " .. nx_string(game_config.switch_ip) .. ":" .. nx_string(game_config.switch_port))
  if game_config.is_cross_ready then
    nx_execute("game_sock", "cross_server_ready")
    game_config.is_cross_ready = false
    nx_log("is_cross_ready true")
  end
  local game_sock = nx_value("game_sock")
  if nx_is_valid(game_sock) then
    game_sock:Disconnect()
  end
  nx_execute("client", "login_game", game_config.switch_ip, game_config.switch_port, "", "", game_config.login_account, "", game_info.ReconKey, "", "")
end
function login_normal_server()
  if not nx_is_valid(game_config) then
    return
  end
  local game_info = nx_value("game_config_info")
  if not nx_is_valid(game_info) then
    return
  end
  game_config.switch_server = true
  nx_execute("client", "login_game", game_config.login_addr, game_config.login_port, "", "", game_config.login_account, "", game_info.ReconKey, "", "")
end
function get_crossserver_info(addr, port)
  local text_sock = nx_value("text_sock")
  if text_sock.Connected then
    text_sock:Disconnect()
  end
  text_sock:Connect(nx_string(addr), nx_int(port))
  local res = nx_wait_event(5, text_sock, "event_connect")
  if res == nil or res == "failed" or res == "closed" then
    text_sock:Disconnect()
    return false
  end
  text_sock:Send("svrlist")
  local res = nx_wait_event(5, text_sock, "event_svr_info")
  if res == nil then
    text_sock:Disconnect()
    return false
  end
  local data = text_sock:DecodeText(nx_string(res))
  text_sock:Disconnect()
  table.remove(data, 1)
  local size = table.getn(data) / 4
  if size < 1 then
    return false
  end
  local min_status = 99999
  local index = -1
  for i = 1, size do
    local cur_status = data[i * 4]
    if nx_int(cur_status) < nx_int(min_status) then
      min_status = cur_status
      index = i
    end
  end
  if index <= 0 then
    return false
  end
  return true, data[index * 4 - 2], data[index * 4 - 1]
end
local NEED_DEL_FORM = {
  "form_stage_main\\form_market\\form_market",
  "form_stage_main\\form_offline\\form_offline_prize",
  "form_stage_main\\form_die",
  "form_stage_main\\form_wuxue\\form_team_faculty_member",
  "form_stage_main\\form_die_battlefield",
  "form_stage_main\\form_hurt_danger",
  "form_stage_main\\form_main\\form_main_shortcut_ride",
  "form_stage_main\\form_stall\\form_stallbusiness",
  "form_stage_main\\form_chat_system\\form_chat_window",
  "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild"
}
function close_moreform()
  nx_execute("form_stage_main\\form_single_notice", "remove_item", nx_number(1), nx_number(111), "ui_guildglobalwar_fight")
  nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_tips", "close_form")
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_h", "close_form")
  nx_execute("form_stage_main\\form_main\\form_main_request", "clear_item")
  nx_execute("form_stage_main\\form_main\\form_main_team", "hide_team_panel")
  nx_execute("form_stage_main\\form_main\\form_main", "close_moreform")
  local form_sel = nx_value("form_stage_main\\form_main\\form_main_select")
  if nx_is_valid(form_sel) then
    form_sel.Visible = false
  end
  nx_execute("form_stage_main\\form_webexchange\\form_exchange_main", "on_close_click")
  local form_single = nx_value("form_stage_main\\form_main\\form_main_tiny_single")
  if nx_is_valid(form_single) then
    nx_execute("form_stage_main\\form_main\\form_main_tiny_single", "refresh_all_form")
  end
  local count = table.getn(NEED_DEL_FORM)
  for i = 1, count do
    local del_form = nx_value(NEED_DEL_FORM[i])
    if nx_is_valid(del_form) then
      del_form.Visible = false
      del_form:Close()
    end
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local right_level = 0
  if client_player:FindProp("NetBarRight") then
    right_level = client_player:QueryProp("NetBarRight")
  end
  local form_main_player = nx_value("form_stage_main\\form_main\\form_main_player")
  if not nx_is_valid(form_main_player) then
    return
  end
  if not nx_find_custom(form_main_player, "btn_netbar_woniu") then
    return
  end
  local btn = form_main_player.btn_netbar_woniu
  if 0 < right_level then
    btn.Visible = not btn.Visible
  else
    btn.Visible = false
  end
end
function cross_normal_server_ready()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_log("[cross normal server ready] game config.")
    return
  end
  if game_config.res_login then
    nx_log("[cross normal server ready] res login.")
    return
  end
  if not game_config.switch_normal_server then
    nx_log("[cross normal server ready] switch normal server.")
    return
  end
  game_config.res_login = false
  nx_log("[cross normal server ready] cross server.")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_close_scene", true, false)
  if nx_is_valid(dialog) then
    dialog.mode = "close"
    dialog:ShowModal()
    local res = nx_wait_event(100000000, nx_null(), "login_game")
    if nx_is_valid(dialog) then
      nx_log("[cross normal server ready] login_game result is " .. nx_string(res))
      dialog:Close()
      nx_destroy(dialog)
    end
    if res == "failed" or res == "queue" then
      game_config.switch_normal_server = false
      game_config.switch_ip = ""
      game_config.switch_port = 0
      local game_info = nx_value("game_config_info")
      nx_log("[cross normal failed]return normal:" .. nx_string(game_config.login_addr) .. ":" .. nx_string(game_config.login_port))
      game_config.ret_normal_server = true
      nx_execute("client", "login_game", game_config.login_addr, game_config.login_port, "", "", game_config.login_account, "", game_info.ReconKey, "", "")
    elseif res == "timeout" then
      nx_log("[cross normal server ready]login game time out")
      if game_config.is_login_switch_server then
        game_config.is_login_switch_server = false
        game_config.is_cross_ready = true
        start_switch_server()
      else
        game_config.switch_normal_server = false
        game_config.switch_ip = ""
        game_config.switch_port = 0
        local game_info = nx_value("game_config_info")
        nx_log("[cross normal timeout]return normal:" .. nx_string(game_config.login_addr) .. ":" .. nx_string(game_config.login_port))
        game_config.ret_normal_server = true
        nx_execute("client", "login_game", game_config.login_addr, game_config.login_port, "", "", game_config.login_account, "", game_info.ReconKey, "", "")
      end
    else
      nx_log("[cross normal server ready] reset switch info")
      local sock = nx_value("game_sock")
      local res, code = nx_wait_event(90, sock.Receiver, "event_login")
      local bfailed = false
      local log = ""
      local info_stringid = ""
      if res == nil then
        bfailed = true
        log = "Create Role time out"
      elseif res == "failed" then
        bfailed = true
        log = "Create Role failed " .. code
      elseif res == "cancel" then
        bfailed = true
        log = "Create Role cancel"
        info_stringid = "ui_create_role_cancel"
      end
      if bfailed then
        nx_log(log)
        local gui = nx_value("gui")
        gui.TextManager:Format_SetIDName(info_stringid)
        if code ~= nil then
          gui.TextManager:Format_AddParam(nx_int(code))
        end
        local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_connect", true, false)
        local info = gui.TextManager:Format_GetText()
        dialog.info_mltbox.HtmlText = info
        dialog.btn_return.Visible = true
        dialog.btn_cancel.Visible = false
        if nx_int(code) == nx_int(17) then
          dialog.lbl_4.Height = dialog.lbl_4.Height - dialog_lbl_6.Height
          dialog.lbl_6.Visible = true
          dialog.lbl_xian.Visible = true
          dialog.btn_single_vip.Visible = true
        end
        dialog.event_name = "create_role_failed"
        if nx_is_valid(dialog) then
          dialog:Close()
          gui:Delete(dialog)
        end
        nx_gen_event(nx_null(), "create_role", "failed")
        if nx_is_valid(ClientDataFetch) then
          ClientDataFetch:SendActInfo(3, 0)
        end
        nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_CREATE_ROLE, name, false)
        game_config.switch_normal_server = false
        game_config.switch_ip = ""
        game_config.switch_port = 0
        local game_info = nx_value("game_config_info")
        nx_log("[cross normal create failed]return normal:" .. nx_string(game_config.login_addr) .. ":" .. nx_string(game_config.login_port))
        game_config.back_normal_server = true
        nx_execute("client", "login_game", game_config.login_addr, game_config.login_port, "", "", game_config.login_account, "", game_info.ReconKey, "", "")
        return false
      end
    end
  else
    nx_log("[cross normal server ready] no close scene.")
  end
end
