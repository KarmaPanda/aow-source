require("share\\logicstate_define")
require("define\\team_rec_define")
local TEAM_REC = "team_rec"
function get_team_work()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryProp("Name")
  local row = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(name))
  if row < 0 then
    return -1
  end
  local playerwork = nx_number(client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK))
  return playerwork
end
function get_team_type(client_player)
  if client_player == nil then
    local game_client = nx_value("game_client")
    client_player = game_client:GetPlayer()
  end
  if not nx_is_valid(client_player) then
    return -1
  end
  local captain_name = get_team_captain_name(client_player)
  if nx_ws_length(nx_widestr(captain_name)) < 1 then
    return -1
  end
  if client_player:FindProp("TeamType") then
    return nx_number(client_player:QueryProp("TeamType"))
  end
  return -1
end
function get_team_captain_name(client_player)
  if client_player == nil then
    local game_client = nx_value("game_client")
    client_player = game_client:GetPlayer()
  end
  if not nx_is_valid(client_player) then
    return nx_widestr("")
  end
  if client_player:FindProp("TeamCaptain") then
    return nx_widestr(client_player:QueryProp("TeamCaptain"))
  end
  return nx_widestr("")
end
function is_in_team(client_obj)
  if nx_is_valid(client_obj) then
    if not client_obj:FindProp("TeamCaptain") then
      return false
    end
    local captainname = client_obj:QueryProp("TeamCaptain")
    if not nx_ws_equal(nx_widestr(captainname), nx_widestr("")) then
      return true
    else
      return false
    end
  else
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return false
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return false
    end
    if not client_player:FindProp("TeamCaptain") then
      return false
    end
    local captainname = client_player:QueryProp("TeamCaptain")
    if not nx_ws_equal(nx_widestr(captainname), nx_widestr("")) then
      return true
    else
      return false
    end
  end
end
function is_team_captain(client_obj)
  if nx_is_valid(client_obj) then
    local TeamCaptain = client_obj:QueryProp("TeamCaptain")
    local Name = client_obj:QueryProp("Name")
    if nx_ws_equal(nx_widestr(TeamCaptain), nx_widestr(Name)) then
      return true
    else
      return false
    end
  else
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local TeamCaptain = client_player:QueryProp("TeamCaptain")
    local Name = client_player:QueryProp("Name")
    if nx_ws_equal(nx_widestr(TeamCaptain), nx_widestr(Name)) then
      return true
    else
      return false
    end
  end
end
function is_player_offline(game_player)
  if nx_is_valid(game_player) then
    local player_logicstate = game_player:QueryProp("LogicState")
    if nx_int(player_logicstate) == nx_int(LS_OFFLINEJOB) or nx_int(player_logicstate) == nx_int(LS_OFFLINE_LIFE) or nx_int(player_logicstate) == nx_int(LS_OFFLINE_WUXUE) or nx_int(player_logicstate) == nx_int(LS_OFFLINE_STALL) or nx_int(player_logicstate) == nx_int(LS_OFFLINE_TOGATHER) then
      return true
    else
      return false
    end
  end
  return true
end
function get_team_record(member_name, col)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  local row = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(member_name))
  if row < 0 then
    return nil
  end
  return client_player:QueryRecord(TEAM_REC, row, col)
end
function is_have_team(game_player)
  if game_player == nil then
    local game_client = nx_value("game_client")
    game_player = game_client:GetPlayer()
  end
  if not nx_is_valid(game_player) then
    return false
  end
  local team_id = game_player:QueryProp("TeamID")
  return nx_int(team_id) > nx_int(0)
end
function get_member_count(index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local count = 0
  local rows = client_player:GetRecordRows(TEAM_REC)
  local team_type = nx_number(get_team_type(client_player))
  if team_type == TYPE_NORAML_TEAM then
    count = nx_number(rows)
  elseif team_type == TYPE_LARGE_TEAM then
    for i = 0, rows - 1 do
      local playerpos = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_TEAMPOSITION)
      if playerpos ~= nil then
        local realpos = nx_int(playerpos / 10) + 1
        if nx_int(realpos) == nx_int(index) then
          count = count + 1
        end
      end
    end
  end
  return count
end
