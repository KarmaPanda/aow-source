GTP_LUA_FUNC_ACTIVATE_N_LAUNCH = 0
GTP_LUA_FUNC_LOAD_RESOURCE = 1
GTP_LUA_FUNC_LOGIN = 2
GTP_LUA_FUNC_CREATE_ROLE = 3
GTP_LUA_FUNC_INTO_GAME = 4
GTP_LUA_FUNC_SET_SCENE = 5
GTP_LUA_FUNC_EXIT = 6
GTP_LUA_FUNC_UPLOAD_CRASH_LOG = 7
GTP_LUA_FUNC_UPLOAD_COMPRESSED_CRASH_LOG = 8
GTP_LUA_FUNC_UNDEFINE = 9
function GTP_init_game_info_collector()
  local GameInfoCollector = nx_create("GameInfoCollector")
  if nx_is_valid(GameInfoCollector) then
    nx_set_value("GameInfoCollector", GameInfoCollector)
  end
end
function GTP_set_collector_time(func_index, b_start, b_replace)
  local index = nx_int(func_index)
  if index >= nx_int(GTP_LUA_FUNC_ACTIVATE) and index < nx_int(GTP_LUA_FUNC_UNDEFINE) then
    local GameInfoCollector = nx_value("GameInfoCollector")
    if not nx_is_valid(GameInfoCollector) then
      return
    end
    GameInfoCollector:SetGTPTime(index, nx_boolean(b_start), nx_boolean(b_replace))
  end
end
function GTP_call_func(func_index, ...)
  local index = nx_int(func_index)
  if index < nx_int(GTP_LUA_FUNC_ACTIVATE) and index >= nx_int(GTP_LUA_FUNC_UNDEFINE) then
    return
  end
  local GameInfoCollector = nx_value("GameInfoCollector")
  if not nx_is_valid(GameInfoCollector) then
    return
  end
  local arg_count = nx_int(table.getn(arg))
  if index == nx_int(GTP_LUA_FUNC_ACTIVATE_N_LAUNCH) then
    GameInfoCollector:GTPActivateNLaunch()
  elseif index == nx_int(GTP_LUA_FUNC_LOAD_RESOURCE) then
    if arg_count ~= nx_int(1) then
      return
    end
    GameInfoCollector:GTPLoadResource(nx_boolean(arg[1]))
  elseif index == nx_int(GTP_LUA_FUNC_LOGIN) then
    if arg_count ~= nx_int(5) then
      return
    end
    local role_name = ""
    local game_sock = nx_value("game_sock")
    if nx_is_valid(game_sock) then
      role_name = game_sock.Receiver:GetRoleName(0)
    end
    GameInfoCollector:GTPLogin(nx_string(arg[1]), nx_string(role_name), nx_int(arg[3]), nx_string(arg[4]), nx_boolean(arg[5]))
  elseif index == nx_int(GTP_LUA_FUNC_CREATE_ROLE) then
    if arg_count ~= nx_int(2) then
      return
    end
    GameInfoCollector:GTPCreateRole(nx_string(arg[1]), nx_boolean(arg[2]))
  elseif index == nx_int(GTP_LUA_FUNC_INTO_GAME) then
    GameInfoCollector:GTPIntoGame()
  elseif index == nx_int(GTP_LUA_FUNC_SET_SCENE) then
    if arg_count ~= nx_int(1) then
      return
    end
    GameInfoCollector:GTPSetScene(nx_string(arg[1]))
  elseif index == nx_int(GTP_LUA_FUNC_EXIT) then
    GameInfoCollector:GTPExit()
  end
end
function GTP_reset_specific_time(func_index)
  local GameInfoCollector = nx_value("GameInfoCollector")
  if nx_is_valid(GameInfoCollector) then
    GameInfoCollector:ResetSpecificTime(nx_int(func_index))
  end
end
function GTP_start_game()
  local GameInfoCollector = nx_value("GameInfoCollector")
  if nx_is_valid(GameInfoCollector) then
    GameInfoCollector:GTPStartGame()
    local game_config = nx_value("game_config")
    local SwitchManager = nx_value("SwitchManager")
    if nx_is_valid(game_config) and nx_is_valid(SwitchManager) then
      local server_id = SwitchManager:GetServiceID()
      GameInfoCollector:GTPEnterGame(nx_string(game_config.login_addr), nx_string(server_id), 0)
    end
  end
end
