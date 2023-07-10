require("playsnail\\playsnail_define")
local PATH_PLAYSNAIL_CONFIG = "updater\\updater_cfg\\url_config.ini"
function SendMsg(msg)
  local curlLogic = nx_value("CurlLogic")
  if not nx_is_valid(curlLogic) then
    return false
  end
  local bRet = curlLogic:HttpGet(msg)
  return bRet
end
function FormatMainMsg()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return ""
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return ""
  end
  local strCmdMain = GetCfgItem("playsnail", "cmd_main")
  if string.len(nx_string(strCmdMain)) <= 0 then
    return ""
  end
  local nAID = nx_int(GetPlayerProp("AccountIDPlaysnail"))
  local nSystemID = nx_int(1)
  local nGameID = nx_int(10)
  local nServerID = nx_int(game_config.server_id)
  local nTime = nx_int64(msg_delay:GetServerSecond())
  local strKey = "playsnail"
  local strInfo = nx_string(nAID) .. nx_string(nSystemID) .. nx_string(nGameID) .. nx_string(nServerID) .. nx_string(nTime) .. nx_string(strKey)
  local strSign = nx_function("ext_md5_string", strInfo)
  strSign = string.upper(nx_string(strSign))
  local strMsg = nx_string(strCmdMain) .. "?aId=" .. nx_string(nAID) .. "&systemId=1&gameId=10&serverId=" .. nx_string(nServerID) .. "&time=" .. nx_string(nTime) .. "&mime=obj&sign=" .. nx_string(strSign)
  return strMsg
end
function FormatTaskMsg(nTaskID, nServerID, nAccount)
  local strCmdTask = GetCfgItem("playsnail", "cmd_task")
  if string.len(nx_string(strCmdTask)) <= 0 then
    return ""
  end
  local strTaskID = nx_string(nTaskID)
  local strServerID = nx_string(nServerID)
  local strGameID = "10"
  local strKey = "Z*)21sdf"
  local strInfo = nx_string(strTaskID) .. nx_string(strGameID) .. nx_string(strServerID) .. nx_string(nAccount) .. nx_string(strKey)
  local strSign = nx_function("ext_md5_string", strInfo)
  local strMsg = nx_string(strCmdTask) .. "?aId=" .. nx_string(nAccount) .. "&taskId=" .. strTaskID .. "&gameId=10&serverId=" .. nx_string(strServerID) .. "&sign=" .. nx_string(strSign)
  return strMsg
end
function SubmitTask(nTaskID, nServerID, nAccount)
  local strMsg = FormatTaskMsg(nTaskID, nServerID, nAccount)
  local bRet = SendMsg(strMsg)
  return bRet
end
function GetPlayerProp(prop)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return ""
  end
  if not game_player:FindProp(nx_string(prop)) then
    return ""
  end
  return game_player:QueryProp(nx_string(prop))
end
function GetCfgItem(section, key)
  local workPath = nx_work_path()
  if string.sub(workPath, string.len(workPath)) == "\\" then
    workPath = string.sub(workPath, 1, string.len(workPath) - 1)
  end
  local rootPath, s = nx_function("ext_split_file_path", workPath)
  local fileName = rootPath .. PATH_PLAYSNAIL_CONFIG
  local ini = nx_create("IniDocumentUtf8")
  ini.FileName = fileName
  local value = nx_widestr("")
  if ini:LoadFromFile() then
    value = ini:ReadString(nx_widestr(section), nx_widestr(key), nx_widestr(""))
  end
  nx_destroy(ini)
  return value
end
