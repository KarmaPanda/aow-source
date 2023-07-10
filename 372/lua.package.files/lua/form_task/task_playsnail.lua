function notice_playsnail(nTaskID, nServerID, nAccount)
  local httpClient = nx_value("GenericHTTPClient")
  if not nx_is_valid(httpClient) then
    return false
  end
  local strTaskID = nx_string(nTaskID)
  local strServerID = nx_string(nServerID)
  local strGameID = "10"
  local strKey = "Z*)21sdf"
  local strInfo = nx_string(strTaskID) .. nx_string(strGameID) .. nx_string(strServerID) .. nx_string(nAccount) .. nx_string(strKey)
  local strSign = nx_function("ext_md5_string", strInfo)
  local strMsg = "http://api.playsnail.com/taskcomplete.json?aId=" .. nx_string(nAccount) .. "&taskId=" .. strTaskID .. "&gameId=10&serverId=" .. nx_string(strServerID) .. "&sign=" .. nx_string(strSign)
  httpClient:Request(strMsg, 1, "MERONG(0.9/;p)")
end
