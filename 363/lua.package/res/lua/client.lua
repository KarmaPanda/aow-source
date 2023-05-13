require("util_gui")
require("form_stage_main\\switch\\url_define")
require("form_stage_login\\form_login_phone")
require("gameinfo_collector")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function get_game_sock()
  local sock = nx_value("game_sock")
  local bcreate = false
  if nx_is_valid(sock) then
    bcreate = sock.ready ~= nil and sock.ready ~= false
  end
  if not bcreate then
    if not nx_is_valid(sock) then
      sock = nx_create("GameWinSock")
    end
    sock:LoadEncodeDll("FxCli.dll")
    nx_bind_script(sock, "game_sock", "game_sock_init")
    local client = nx_value("game_client")
    client:ClearAll()
    sock.Receiver.Client = client
    local game_msg_handler = nx_create("GameMessageHandler", sock.Receiver)
    game_msg_handler.GameClient = nx_value("game_client")
    game_msg_handler.GameVisual = nx_value("game_visual")
    game_msg_handler.DataBinder = nx_value("data_binder")
    game_msg_handler.SkillEffect = nx_value("skill_effect")
    game_msg_handler.SceneObj = nx_value("scene_obj")
    sock.Receiver.GameMsgHandler = game_msg_handler
    nx_bind_script(game_msg_handler, "custom_handler", "custom_handler_init")
    nx_set_value("game_sock", sock)
    sock.ready = true
    nx_set_value("game_msg_handler", game_msg_handler)
  end
  return sock
end
function version_test()
  return true
end
function login_game(addr, port, area_addr, area_port, account, password, validate, verify, niudun, login_shoujiniudun, login_qr)
  local world = nx_value("world")
  if world.RetailVersion and nx_value("version_np") == nil then
    nx_msgbox("FxGame.exe Version Error")
    nx_quit()
    return
  end
  local sock = get_game_sock()
  local sender = sock.Sender
  local receiver = sock.Receiver
  sock.try_reconnect = false
  sender.try_reconnect = false
  receiver.try_reconnect = false
  local gui = nx_value("gui")
  local dialog = util_get_form("form_common\\form_connect", true, false)
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  console_log("area_addr=" .. nx_string(area_addr) .. " area_port=" .. nx_string(area_port) .. " addr=" .. addr .. " port=" .. port)
  nx_log("area_addr=" .. nx_string(area_addr) .. " area_port=" .. nx_string(area_port) .. " addr=" .. addr .. " port=" .. port)
  if area_addr ~= "" and area_port ~= "" then
    local res = get_server_status(area_addr, area_port)
    if not res then
      console_log("lister connect failed")
      nx_log("lister connect failed")
      dialog.lbl_connect.Text = gui.TextManager:GetFormatText("ui_connect_failed")
      dialog.event_name = "connect_failed"
      dialog.btn_return.Visible = true
      dialog.btn_cancel.Visible = false
      dialog.lbl_4.Height = dialog.lbl_4.Height - dialog.lbl_6.Height
      dialog.lbl_xian.Visible = true
      dialog.lbl_6.Visible = true
      dialog:ShowModal()
      nx_wait_event(100000000, dialog, dialog.event_name)
      dialog:Close()
      gui:Delete(dialog)
      nx_gen_event(nx_null(), "login_game", "failed")
      return false
    end
  end
  receiver:ClearAll()
  nx_pause(0)
  if sock.Connected then
    sock:Disconnect()
    console_log("Disconnect...")
    nx_pause(3)
  end
  sock.address = addr
  sock.port = port
  sock:Connect(nx_string(addr), nx_int(port))
  console_log("connect to server")
  nx_log("connect to server")
  if nx_is_valid(dialog) then
    dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
    dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
    dialog.btn_return.Visible = false
    dialog.btn_cancel.Visible = true
    dialog.lbl_connect.Text = gui.TextManager:GetFormatText("ui_connect")
    dialog.event_name = "event_connect"
    dialog.lbl_4.Height = dialog.lbl_4.Height + dialog.lbl_6.Height
    dialog.lbl_6.Visible = false
    dialog.lbl_xian.Visible = false
    dialog:ShowModal()
  else
    return false
  end
  local res, code = nx_wait_event(30, sock, "event_connect")
  local bfailed = false
  local log = ""
  local info_stringid = ""
  if res == nil then
    bfailed = true
    log = "connect time out"
    info_stringid = "ui_connect_timeout"
  elseif res == "failed" then
    bfailed = true
    log = "connect faile"
    if code ~= nil then
      info_stringid = "login_errcode_" .. nx_string(code)
    else
      info_stringid = "ui_connect_failed"
    end
  elseif res == "closed" then
    bfailed = true
    log = "server closed"
    info_stringid = "ui_connect_closed"
  elseif res == "cancel" then
    bfailed = true
    log = "connect cancel"
    info_stringid = "ui_connect_cancel"
  end
  if bfailed then
    console_log(log)
    nx_log(log)
    sock:Disconnect()
    if need_pre_server() then
      nx_gen_event(nx_null(), "login_game", "failed")
      return false
    end
    gui.TextManager:Format_SetIDName(info_stringid)
    if code ~= nil then
      gui.TextManager:Format_AddParam(nx_int(code))
    end
    dialog.lbl_connect.Text = gui.TextManager:GetFormatText("ui_g_connect_server_failed")
    dialog.event_name = "connect_failed"
    dialog.btn_return.Visible = true
    dialog.btn_cancel.Visible = false
    dialog.lbl_4.Height = dialog.lbl_4.Height - dialog.lbl_6.Height
    dialog.lbl_xian.Visible = true
    dialog.lbl_6.Visible = true
    nx_wait_event(100000000, dialog, dialog.event_name)
    dialog:Close()
    gui:Delete(dialog)
    nx_gen_event(nx_null(), "login_game", "failed")
    return false
  end
  if login_qr then
    dialog:Close()
  end
  local is_normal_login = false
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    game_config.card_no = ""
    game_config.rechoose_role = false
    game_config.is_cross_ready = false
  end
  if validate ~= nil and nx_string(validate) ~= "" then
    get_card_no(nx_string(validate))
    local ev = "9YIN-ADPARLOR-2"
    local split_pos = nx_function("ext_ws_find", nx_widestr(validate), nx_widestr(ev))
    local url = ""
    if -1 ~= split_pos then
      local info_lst = util_split_string(validate, "|")
      url = "http://fbads.adparlor.com/s2sconversion.php?subid=" .. info_lst[table.getn(info_lst) - 1]
      local validate_lst = util_split_string(validate, "$")
      validate = validate_lst[1]
      game_config.login_validate = nx_string(validate_lst[1])
    end
    nx_log("validate = " .. validate)
    nx_set_value("request_url", url)
    if niudun ~= nil and nx_string(niudun) ~= "" then
      sender:LoginByString(nx_string(account), nx_string(validate) .. "$" .. nx_string(niudun))
    else
      sender:LoginByString(nx_string(account), nx_string(validate))
    end
  else
    get_card_no("")
    local game_config_info = nx_value("game_config_info")
    if niudun ~= nil and nx_string(niudun) ~= "" then
      sender:LoginByShield(nx_string(account), nx_string(password), nx_string(niudun))
    elseif login_shoujiniudun ~= nil and nx_string(login_shoujiniudun) ~= "" then
      sender:LoginByMobileShield(nx_string(account), nx_string(password), nx_string(login_shoujiniudun))
    elseif game_config_info.ReconKey ~= nil and nx_string(game_config_info.ReconKey) ~= "" and game_config.phone_lock == 1 then
      sender:LoginByPhone(nx_string(account), nx_string(password), nx_string(game_config_info.ReconKey))
    elseif login_qr ~= nil and nx_boolean(login_qr) then
      sender:LoginByQR()
    else
      is_normal_login = true
      sender:Login(nx_string(account), nx_string(password))
    end
  end
  sock.account = nx_string(account)
  if login_qr ~= nil and nx_boolean(login_qr) then
    local isfailed = true
    local res_qr, qrcode = nx_wait_event(30, receiver, "event_qr")
    if res_qr == "succeed" then
      local form_login = nx_value("form_stage_login\\form_login")
      if nx_is_valid(form_login) then
        form_login.qrcode_show.CodeInfo = nx_widestr(qrcode)
        form_login.groupbox_qr.Visible = true
        res, code = nx_wait_event(100000000, receiver, "event_login")
        if res ~= "cancel" then
          isfailed = false
        end
      end
    elseif res_qr ~= "cancel" then
      local dialog = util_get_form("form_common\\form_connect", true, false)
      if nx_is_valid(dialog) then
        dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
        dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
        dialog.btn_return.Visible = true
        dialog.btn_cancel.Visible = false
        dialog.lbl_connect.Text = nx_widestr(gui.TextManager:GetFormatText("ui_qrfail"))
        dialog.event_name = "event_qrfail"
        dialog:ShowModal()
      end
    end
    if isfailed then
      sock:Disconnect()
      nx_gen_event(nx_null(), "login_game", "failed")
      return false
    end
  else
    sock.account = nx_string(account)
    console_log("login...")
    nx_log("login...")
    dialog.lbl_connect.Text = nx_string("")
    dialog.info_mltbox.HtmlText = gui.TextManager:GetFormatText("ui_login")
    dialog.event_name = "event_login"
    res, code = nx_wait_event(60, receiver, "event_login")
  end
  if res == "queue" then
    if need_pre_normal_server() then
      nx_gen_event(nx_null(), "login_game", "queue")
      return false
    end
    console_log("login success queue")
    if nx_is_valid(dialog) then
      dialog:Close()
    end
    local form_queue = util_get_form("form_common\\form_queue", false)
    if nx_is_valid(form_queue) and form_queue.on_queue then
      res = nx_wait_event(100000000, form_queue, "form_common\\form_queue")
      if res == nil or res ~= "succeed" then
        gui:Delete(dialog)
        sock:Disconnect()
        nx_gen_event(nx_null(), "login_game", "failed")
        return false
      end
    else
      dialog:ShowModal()
      res = "cancel"
    end
  end
  if res == nil then
    bfailed = true
    log = "login time out"
    info_stringid = "ui_login_timeout"
    if nx_is_valid(dialog) then
      dialog:Close()
      gui:Delete(dialog)
    end
    console_log("login time out")
    nx_log("login time out")
    nx_gen_event(nx_null(), "login_game", "timeout")
    return false
  elseif res == "failed" then
    console_log("login failed")
    nx_log("login failed" .. " - " .. nx_string(code))
    if need_pre_server() or need_pre_normal_server() then
      nx_gen_event(nx_null(), "login_game", "failed")
      return false
    end
    if code ~= nil then
      if code == 51007 then
        sock:Disconnect()
        local form_mb = util_get_form("form_stage_login\\form_login_mibao", true)
        if nx_is_valid(form_mb) then
          if nx_is_valid(dialog) then
            dialog:Close()
            gui:Delete(dialog)
          end
          form_mb.pswd = password
          form_mb.Visible = true
          form_mb:ShowModal()
          sock:Connect(nx_string(addr), nx_int(port))
          nx_pause(0.5)
          sender:GetVerify()
          nx_gen_event(nx_null(), "login_game", "failed")
          return false
        end
      elseif code == 51094 then
        console_log("login request shoujiniudun")
        nx_log("login request shoujiniudun")
        sock:Disconnect()
        local form_validate = util_get_form("form_stage_login\\form_login_woniuke", true)
        if nx_is_valid(form_validate) then
          dialog:Close()
          gui:Delete(dialog)
          form_validate.pswd = password
          form_validate.validate = validate
          form_validate.type = 1
          nx_execute("form_stage_login\\form_login_woniuke", "resize")
          form_validate.Visible = true
          form_validate:ShowModal()
          nx_gen_event(nx_null(), "login_game", "failed")
          return false
        end
      elseif code == 51091 then
        console_log("login request niudun")
        nx_log("login request niudun")
        sock:Disconnect()
        local form_validate = util_get_form("form_stage_login\\form_login_woniuke", true)
        if nx_is_valid(form_validate) then
          dialog:Close()
          gui:Delete(dialog)
          form_validate.pswd = password
          form_validate.validate = validate
          form_validate.type = 0
          nx_execute("form_stage_login\\form_login_woniuke", "resize")
          form_validate.Visible = true
          form_validate:ShowModal()
          nx_gen_event(nx_null(), "login_game", "failed")
          return false
        end
      elseif code == 51098 then
        sock:Disconnect()
        local form_validate = util_get_form("form_stage_login\\form_login_phone", true)
        if nx_is_valid(form_validate) then
          dialog:Close()
          gui:Delete(dialog)
          form_validate.pswd = password
          form_validate.validate = validate
          nx_execute("form_stage_login\\form_login_phone", "resize")
          form_validate.Visible = true
          form_validate:ShowModal()
          nx_gen_event(nx_null(), "login_game", "failed")
          return false
        end
      elseif code == 51093 or code == 51011 then
        dialog.btn_url.Visible = true
      elseif code == 51089 then
        dialog.btn_51089.Visible = true
      end
    end
    bfailed = true
    log = "login failed" .. " - " .. nx_string(code)
    if code ~= nil then
      info_stringid = "login_errcode_" .. nx_string(code)
    else
      info_stringid = "ui_login_failed"
    end
  elseif res == "cancel" then
    bfailed = true
    log = "login cancel"
    info_stringid = "ui_login_cancel"
  end
  if bfailed then
    console_log(log)
    nx_log(log)
    sock:Disconnect()
    if need_pre_server() or need_pre_normal_server() then
      nx_gen_event(nx_null(), "login_game", "failed")
      return false
    end
    if code ~= nil and code == 51002 then
      local form_login = nx_value("form_stage_login\\form_login")
      if nx_is_valid(form_login) then
        form_login.login_num = form_login.login_num + 1
        if form_login.login_num >= 10 then
          local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
          if nx_is_valid(dialog) then
            dialog.cancel_btn.Visible = false
            dialog.mltbox_info.HtmlText = gui.TextManager:GetText("ui_mima_tips")
            dialog.ok_btn.Text = gui.TextManager:GetText("ui_exitgame")
            dialog:ShowModal()
            local res = nx_wait_event(100000000, dialog, "breakconnect_confirm_return")
            nx_execute("main", "direct_exit_game")
            return false
          end
        end
      end
    end
    gui.TextManager:Format_SetIDName(info_stringid)
    if code ~= nil then
      gui.TextManager:Format_AddParam(nx_int(code))
    end
    if code == 51099 or code == 51100 then
      local phone_number = get_phone()
      gui.TextManager:Format_AddParam(phone_number)
    end
    dialog.info_mltbox.HtmlText = gui.TextManager:Format_GetText()
    if code == 51087 then
      dialog.info_mltbox.Visible = true
      dialog.lbl_connect.Visible = false
      dialog.info_mltbox.HtmlText = gui.TextManager:Format_GetText()
      dialog.btn_return.Text = gui.TextManager:GetText("ui_51087_submit")
    end
    dialog.btn_return.Visible = true
    dialog.btn_cancel.Visible = false
    dialog.lbl_4.Height = dialog.lbl_4.Height - dialog.lbl_6.Height
    dialog.lbl_xian.Visible = true
    dialog.lbl_6.Visible = true
    dialog.event_name = "login_failed"
    nx_wait_event(100000000, dialog, dialog.event_name)
    if code == 51087 then
      local switch_manager = nx_value("SwitchManager")
      if nx_is_valid(switch_manager) then
        switch_manager:OpenUrl(URL_TYPE_IP_LIMIT)
      end
    elseif code == 51090 then
      local form_validate = util_get_form("form_stage_login\\form_login_woniuke", true)
      if nx_is_valid(form_validate) then
        form_validate.pswd = password
        form_validate.validate = validate
        form_validate.type = 0
        nx_execute("form_stage_login\\form_login_woniuke", "resize")
        form_validate.Visible = true
        form_validate:ShowModal()
      end
    elseif code == 51097 then
      local form_validate = util_get_form("form_stage_login\\form_login_woniuke", true)
      if nx_is_valid(form_validate) then
        form_validate.pswd = password
        form_validate.validate = validate
        form_validate.type = 1
        nx_execute("form_stage_login\\form_login_woniuke", "resize")
        form_validate.Visible = true
        form_validate:ShowModal()
      end
    elseif code == 65101 then
      local switch_manager = nx_value("SwitchManager")
      local game_config = nx_value("game_config")
      if nx_is_valid(switch_manager) and get_operators_name() == OPERATORS_TYPE_SNDA then
        nx_log("login failed info is: get_operators_name() = " .. nx_string(get_operators_name()) .. ", game_config.card_no = " .. game_config.card_no)
        switch_manager:OpenUrl(URL_TYPE_SNDA_UNENTHRALL)
      end
    end
    if not nx_is_valid(dialog) then
      return
    end
    dialog:Close()
    gui:Delete(dialog)
    nx_gen_event(nx_null(), "login_game", "failed")
    local form_login = nx_value("form_stage_login\\form_login")
    if nx_is_valid(form_login) and nx_find_custom(form_login, "sdo_login_show") then
      nx_execute("form_stage_login\\form_login", "set_sdo_login_dialog", form_login, form_login.sdo_login_show)
    end
    return false
  end
  local sdo_login_interface = nx_value("SdoLoginInterface")
  if nx_is_valid(sdo_login_interface) then
  end
  local is_need_login_note = nx_execute("form_stage_login\\form_login_note", "is_need_login_note")
  if is_need_login_note and is_normal_login then
    nx_execute("form_stage_login\\form_login_note", "show_login_note_form")
  end
  nx_gen_event(nx_null(), "login_game", "succeed")
  local checkads = nx_value("checkads")
  if nx_is_valid(checkads) then
    local filepath = util_get_account_path() .. "adfilters.ini"
    checkads:LoadResource(filepath)
  end
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    game_config.login_password = "xxxxxxxxxxxxxxxxxxxxxxxxxx"
    game_config.login_password = ""
    game_config.login_validate = ""
    game_config.login_verify = ""
    game_config.login_shoujiniudun = ""
    game_config.login_niudun = "xxxxxxxxxxxxxxxxxxxxxxxxxx"
    game_config.login_niudun = ""
  end
  if nx_is_valid(dialog) then
    dialog:Close()
    gui:Delete(dialog)
  end
  return true
end
function confirm_to_exit_game()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.cancel_btn.Visible = false
  dialog.ok_btn.Left = dialog.cancel_btn.Left
  dialog.mltbox_info.HtmlText = gui.TextManager:GetText("ui_net_close_info")
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_exitgame")
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "breakconnect_confirm_return")
  nx_execute("main", "direct_exit_game")
end
function exit_game_param(errorcode, info, extra)
  local game_sock = nx_value("game_sock")
  local error_msg = nx_value("ErrorMsg")
  if not game_sock.ready then
    local text = "[" .. errorcode .. "]" .. error_msg:GetErrMsg(info) .. extra
    nx_msgbox(text)
    nx_execute("main", "direct_exit_game")
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.cancel_btn.Visible = false
  dialog.mltbox_info.HtmlText = nx_widestr("[") .. nx_widestr(errorcode) .. nx_widestr("]") .. nx_widestr(error_msg:GetErrMsg(info)) .. nx_widestr(extra)
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_exitgame")
  dialog:ShowModal()
  local world = nx_value("world")
  if nx_is_valid(world) and nx_find_property(world, "MainScene") and nx_is_valid(world.MainScene) and nx_find_custom(world.MainScene, "game_control") then
    local game_control = world.MainScene.game_control
    if nx_is_valid(game_control) and nx_find_property(game_control, "AllowControl") then
      game_control.AllowControl = false
    end
  end
  local res = nx_wait_event(100000000, dialog, "breakconnect_confirm_return")
  nx_execute("main", "direct_exit_game")
end
function choose_role(index)
  nx_log("flow client choose_role begin")
  local sock = nx_value("game_sock")
  local gui = nx_value("gui")
  local receiver = sock.Receiver
  if not nx_is_valid(sock) then
    nx_gen_event(nx_null(), "choose_role", "failed")
    return false
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    nx_log("[choose role] game config failed.")
    return false
  end
  local receiver = sock.Receiver
  nx_pause(0)
  local role_name = receiver:GetRoleName(index)
  if nx_ws_length(role_name) == "" then
    nx_gen_event(nx_null(), "choose_role", "failed")
    nx_log("flow choose_role failed role_name = empty")
    return false
  end
  local world = nx_value("world")
  if world.land_scene_info ~= "" then
    sock.Sender:ChooseRoleAndScene(nx_widestr(role_name), nx_string(world.land_scene_info))
  else
    sock.Sender:ChooseRole(nx_widestr(role_name))
  end
  nx_log("flow Choose Role...")
  local dialog = util_get_form("form_common\\form_connect", true, false)
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.btn_return.Visible = false
  dialog.btn_cancel.Visible = true
  dialog.info_mltbox.HtmlText = gui.TextManager:GetFormatText("ui_choose_role")
  dialog.event_name = "event_entry"
  dialog.lbl_4.Height = dialog.lbl_4.Height + dialog.lbl_6.Height
  dialog.lbl_6.Visible = false
  dialog.lbl_xian.Visible = false
  dialog:ShowModal()
  local res, code = nx_wait_event(30, receiver, "event_entry")
  local bfailed = false
  local log = ""
  local info_stringid = ""
  if res == nil then
    bfailed = true
    log = "Choose Role time out"
    info_stringid = "ui_choose_role_timeout"
    if game_config.switch_server and not game_config.rechoose_role then
      nx_log("[choose role] choose role time out.")
      game_config.rechoose_role = true
      choose_role(index)
      return false
    end
  elseif res == "failed" then
    bfailed = true
    log = "Choose Role failed"
    if code ~= nil then
      info_stringid = nx_string(code)
    else
      info_stringid = "ui_choose_role_failed"
    end
  elseif res == "cancel" then
    bfailed = true
    log = "cancel choose role"
    info_stringid = "ui_choose_role_cancel"
  end
  if bfailed then
    if not nx_is_valid(dialog) then
      return false
    end
    nx_log("flow " .. log)
    gui.TextManager:Format_SetIDName(info_stringid)
    if code ~= nil then
      gui.TextManager:Format_AddParam(nx_int(code))
    end
    local info = gui.TextManager:Format_GetText()
    dialog.info_mltbox.HtmlText = info
    dialog.btn_return.Visible = true
    dialog.btn_cancel.Visible = false
    dialog.lbl_4.Height = dialog.lbl_4.Height - dialog.lbl_6.Height
    dialog.lbl_xian.Visible = true
    dialog.lbl_6.Visible = true
    dialog.event_name = "choose_role_failed"
    nx_wait_event(100000000, dialog, dialog.event_name)
    dialog:Close()
    gui:Delete(dialog)
    nx_gen_event(nx_null(), "choose_role", "failed")
    nx_log("flow choose_role failed receiver event_entry")
    if game_config.switch_server and game_config.rechoose_role then
      nx_log("[choose role] relogin.")
      nx_execute("stage", "set_current_stage", "login")
      nx_execute("client", "close_connect")
    end
    return false
  end
  nx_gen_event(nx_null(), "choose_role", "succeed")
  if nx_is_valid(dialog) then
    dialog:Close()
    gui:Delete(dialog)
  end
  nx_log("flow choose role succeed")
  return true
end
function delete_role(index)
  local sock = nx_value("game_sock")
  local gui = nx_value("gui")
  if not nx_is_valid(sock) then
    nx_gen_event(nx_null(), "delete_role", "failed")
    return false
  end
  local receiver = sock.Receiver
  nx_pause(0)
  local role_name = receiver:GetRoleName(index)
  if nx_ws_length(role_name) == "" then
    nx_gen_event(nx_null(), "delete_role", "failed")
    return
  end
  sock.Sender:DeleteRole(nx_widestr(role_name))
  nx_log("Delete Role..." .. nx_string(role_name))
  local dialog = util_get_form("form_common\\form_connect", true, false)
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.btn_return.Visible = false
  dialog.btn_cancel.Visible = true
  dialog.info_mltbox.HtmlText = gui.TextManager:GetFormatText("ui_delete_role")
  dialog.event_name = "event_login"
  dialog.lbl_4.Height = dialog.lbl_4.Height + dialog.lbl_6.Height
  dialog.lbl_6.Visible = false
  dialog.lbl_xian.Visible = false
  dialog:ShowModal()
  local res, code = nx_wait_event(30, receiver, "event_login")
  local bfailed = false
  local log = ""
  local info_stringid = ""
  if res == nil then
    bfailed = true
    log = "Delete Role time out"
    info_stringid = "ui_delete_role_timeout"
  elseif res == "failed" then
    bfailed = true
    log = "Delete Role failed"
    if code ~= nil then
      info_stringid = nx_string(code)
    else
      info_stringid = "ui_delete_role_failed"
    end
  elseif res == "cancel" then
    bfailed = true
    log = "Delete Role cancel"
    info_stringid = "ui_delete_role_cancel"
  end
  if bfailed then
    console_log(log)
    gui.TextManager:Format_SetIDName(info_stringid)
    if code ~= nil then
      gui.TextManager:Format_AddParam(nx_int(code))
    end
    local info = gui.TextManager:Format_GetText()
    dialog.info_mltbox.HtmlText = info
    dialog.btn_return.Visible = true
    dialog.btn_cancel.Visible = false
    dialog.event_name = "delete_role_failed"
    nx_wait_event(100000000, dialog, dialog.event_name)
    dialog:Close()
    gui:Delete(dialog)
    nx_gen_event(nx_null(), "delete_role", "failed")
    return false
  end
  nx_gen_event(nx_null(), "delete_role", "succeed")
  dialog:Close()
  gui:Delete(dialog)
  nx_execute("form_stage_create\\form_face_edit", "init_face_data")
  nx_log("flow delete role succeed")
  return true
end
function create_role(index, name, sex, stand, character, favorite, book, photo, face, impress, hair, cloth, pants, shoes, school)
  local sock = nx_value("game_sock")
  local gui = nx_value("gui")
  local ClientDataFetch = nx_value("ClientDataFetch")
  if not nx_is_valid(sock) then
    nx_gen_event(nx_null(), "create_role", "failed")
    return false
  end
  if school == nil then
    school = ""
  end
  local receiver = sock.Receiver
  nx_pause(0)
  sock.Sender:CreateRole(index, name, index, sex, stand, character, favorite, book, photo, face, impress, hair, cloth, pants, shoes, school)
  nx_log("Create Role..." .. nx_string(name))
  GTP_set_collector_time(GTP_LUA_FUNC_CREATE_ROLE, false, true)
  local dialog = util_get_form("form_common\\form_connect", true, false)
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.btn_return.Visible = false
  dialog.btn_cancel.Visible = true
  dialog.info_mltbox.HtmlText = gui.TextManager:GetFormatText("ui_create_role")
  dialog.event_name = "event_login"
  dialog.lbl_4.Height = dialog.lbl_4.Height + dialog.lbl_6.Height
  dialog.lbl_6.Visible = false
  dialog.lbl_xian.Visible = false
  dialog:ShowModal()
  local res, code = nx_wait_event(30, receiver, "event_login")
  local bfailed = false
  local log = ""
  local info_stringid = ""
  if res == nil then
    bfailed = true
    log = "Create Role time out"
    info_stringid = "ui_create_role_timeout"
  elseif res == "failed" then
    bfailed = true
    log = "Create Role failed"
    if code ~= nil then
      info_stringid = nx_string(code)
      if nx_int(code) == nx_int(0) then
        info_stringid = "ui_create_role_failed_scene"
      elseif nx_int(code) == nx_int(2) then
        info_stringid = "ui_create_role_name_illegality"
      elseif nx_int(code) > nx_int(0) and nx_int(code) < nx_int(28) then
        if nx_string(school) == nx_string("school_mingjiao") then
          info_stringid = 21
        elseif nx_string(school) == nx_string("school_tianshan") then
          info_stringid = 22
        end
        info_stringid = "ui_CreateRole_" .. info_stringid
      end
    else
      info_stringid = "ui_create_role_failed"
    end
  elseif res == "cancel" then
    bfailed = true
    log = "Create Role cancel"
    info_stringid = "ui_create_role_cancel"
  end
  if bfailed then
    console_log(log)
    gui.TextManager:Format_SetIDName(info_stringid)
    if code ~= nil then
      gui.TextManager:Format_AddParam(nx_int(code))
    end
    local info = gui.TextManager:Format_GetText()
    dialog.info_mltbox.HtmlText = info
    dialog.btn_return.Visible = true
    dialog.btn_cancel.Visible = false
    if nx_int(code) == nx_int(17) then
      dialog.lbl_4.Height = dialog.lbl_4.Height - dialog.lbl_6.Height
      dialog.lbl_6.Visible = true
      dialog.lbl_xian.Visible = true
      dialog.btn_single_vip.Visible = true
    end
    dialog.event_name = "create_role_failed"
    nx_wait_event(100000000, dialog, dialog.event_name)
    if nx_is_valid(dialog) then
      dialog:Close()
      gui:Delete(dialog)
    end
    nx_gen_event(nx_null(), "create_role", "failed")
    if nx_is_valid(ClientDataFetch) then
      ClientDataFetch:SendActInfo(3, 0)
    end
    nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_CREATE_ROLE, name, false)
    return false
  end
  nx_gen_event(nx_null(), "create_role", "succeed")
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_custom(game_config, "freshman_btn_show") then
    game_config.freshman_btn_show = true
  end
  if nx_is_valid(dialog) then
    dialog:Close()
    if nx_is_valid(dialog) then
      gui:Delete(dialog)
    end
  end
  nx_log("flow create role succeed")
  if nx_is_valid(ClientDataFetch) then
    ClientDataFetch:SendActInfo(3, 1)
  end
  local generic_http_client = nx_create("GenericHTTPClient")
  local url = nx_value("request_url")
  if nil ~= url and "" ~= url and nx_is_valid(generic_http_client) then
    generic_http_client:Request(url, 1, "MERONG(0.9/;p)")
    nx_set_value("request_url", nil)
    nx_destroy(generic_http_client)
    nx_log("OK request_url = " .. url)
  else
    nx_destroy(generic_http_client)
    nx_log("no request_url")
  end
  nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_CREATE_ROLE, name, true)
  return true
end
function close_connect()
  local sock = get_game_sock()
  local sender = sock.Sender
  local receiver = sock.Receiver
  receiver:ClearAll()
  if sock.Connected then
    sock:Disconnect()
    console_log("Disconnect...")
  end
end
function get_server_status(addr, port)
  local text_sock = nx_value("text_sock")
  if text_sock.Connected then
    text_sock:Disconnect()
  end
  text_sock:Connect(nx_string(addr), nx_int(port))
  local res = nx_wait_event(15, text_sock, "event_connect")
  if res == nil or res == "failed" or res == "closed" then
    text_sock:Disconnect()
    return false
  end
  text_sock:Send("svrlist")
  local res = nx_wait_event(15, text_sock, "event_svr_info")
  if res == nil then
    text_sock:Disconnect()
    return false
  end
  local data = text_sock:DecodeText(nx_string(res))
  table.remove(data, 1)
  text_sock:Disconnect()
  return true, data
end
function get_card_no(validate)
  local game_config = nx_value("game_config")
  local info_lst = util_split_string(validate, ",")
  if table.getn(info_lst) == 0 then
    game_config.card_no = "1"
    return nx_string("1_")
  end
  local value = string.sub(info_lst[1], 1, 1)
  local id = "1_"
  if nx_string("@") == nx_string(value) then
    local size = string.len(info_lst[1])
    value = string.sub(info_lst[1], 2, size)
    id = value
  elseif nx_string("#") == nx_string(value) then
    local size = string.len(info_lst[1])
    value = string.sub(info_lst[1], 2, size)
    id = "186"
  elseif nx_string("") == nx_string(value) then
    id = nx_string("1_")
    value = id
  else
    id = info_lst[1]
    value = info_lst[1]
  end
  game_config.card_no = id
  return nx_string(value) .. nx_string("_")
end
function need_pre_server()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return false
  end
  if not game_config.switch_server then
    return false
  end
  return true
end
function get_version()
  return "NA90819@.*364"
end
function need_pre_normal_server()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return false
  end
  return game_config.switch_normal_server
end
