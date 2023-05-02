require("util_functions")
NONE = 0
ONE_ICON = 1
TWO_ICON = 2
THREE_ICON = 3
function refresh_npc_headinfo(control, client_scene_obj)
  if nx_name(control) ~= nx_string("MultiTextBox") then
    return
  end
  local HightCount = 0
  local Space_dis = {
    [NONE] = "",
    [ONE_ICON] = "            ",
    [TWO_ICON] = "         ",
    [THREE_ICON] = "       "
  }
  control:Clear()
  local icon_count = 0
  local photo_text = ""
  local beg_photopath = "<img src=\"gui\\job\\wan.png\"/>"
  local suangua_photopath = "<img src=\"gui\\job\\suangua.png\"/>"
  if isShowBegIcon(client_scene_obj) then
    icon_count = icon_count + 1
    photo_text = photo_text .. beg_photopath
  end
  if isShowSuanguaIcon(client_scene_obj) then
    icon_count = icon_count + 1
    photo_text = photo_text .. suangua_photopath
  end
  if nx_string(photo_text) ~= nx_string("") then
    HightCount = HightCount + 1
    photo_text = Space_dis[icon_count] .. photo_text
    control:AddHtmlText(nx_widestr(photo_text), -1)
  end
  local game_client = nx_value("game_client")
  local client_self = game_client:GetPlayer()
  local gui = nx_value("gui")
  local info_str = client_scene_obj:QueryProp("IDCard")
  local info_lst = util_split_string(info_str, ",")
  local fname = info_lst[1]
  local sname = info_lst[2]
  local configid = client_scene_obj:QueryProp("ConfigID")
  local nameid = nx_string(configid) .. "_1"
  local nametext = gui.TextManager:GetText(nx_string(nameid))
  local fight = nx_value("fight")
  local can_attack = fight:CanAttackNpc(client_self, client_scene_obj)
  local show_name_1 = ""
  local show_name_2 = ""
  if nx_string(nametext) ~= nx_string(nameid) and nx_string(nametext) ~= nx_string("") then
    show_name_2 = "(" .. nx_string(nametext) .. ")"
    show_name_1 = nx_string(gui.TextManager:GetText(nx_string(configid)))
    HightCount = HightCount + 2
  elseif nx_string(fname) ~= nx_string("null") and nx_string(fname) ~= nx_string("0") and nx_string(fname) ~= nx_string("nil") and nx_string(sname) ~= nx_string("nil") and nx_string(sname) ~= nx_string("null") and nx_string(sname) ~= nx_string("0") then
    show_name_1 = nx_string(gui.TextManager:GetText(nx_string(fname))) .. nx_string(gui.TextManager:GetText(nx_string(sname)))
    show_name_2 = "(" .. nx_string(gui.TextManager:GetText(nx_string(configid))) .. ")"
    HightCount = HightCount + 2
  else
    show_name_1 = nx_string(gui.TextManager:GetText(nx_string(configid)))
    HightCount = HightCount + 1
  end
  local callname = ""
  local b_has_IDCard = false
  if client_scene_obj:FindProp("IDCard") then
    b_has_IDCard = true
  else
    b_has_IDCard = false
  end
  if b_has_IDCard then
    callname = gui.TextManager:GetText(nx_string(info_lst[5]))
    if nx_string(callname) == nx_string(info_lst[5]) or info_lst[5] == nil or nx_string(info_lst[5]) == nx_string("null") then
      callname = ""
    end
  elseif client_scene_obj:FindProp("Call") then
    local callid = nx_string(client_scene_obj:QueryProp("Call"))
    callname = gui.TextManager:GetText(nx_string(callid))
    if callid == nx_string("") or nx_string(callname) == nx_string(callid) then
      callname = ""
    end
  end
  if can_attack then
    if nx_string(callname) ~= nx_string("") then
      show_name_1 = "<center><font color=\"#ff0000\">" .. nx_string(callname) .. nx_string(show_name_1) .. "</font></center>"
    else
      show_name_1 = "<center><font color=\"#ff0000\">" .. nx_string(show_name_1) .. "</font></center>"
    end
    control:AddHtmlText(nx_widestr(show_name_1), -1)
    if nx_string(show_name_2) ~= nx_string("") then
      control:AddHtmlText(nx_widestr("<center><font color=\"#ff0000\">" .. show_name_2 .. "</font></center>"), -1)
    end
  else
    if nx_string(callname) ~= nx_string("") then
      show_name_1 = "<center><font color=\"#ffd22e\">" .. nx_string(callname) .. nx_string(show_name_1) .. "</font></center>"
    else
      show_name_1 = "<center><font color=\"#ffd22e\">" .. nx_string(show_name_1) .. "</font></center>"
    end
    control:AddHtmlText(nx_widestr(show_name_1), -1)
    if nx_string(show_name_2) ~= nx_string("") then
      control:AddHtmlText(nx_widestr("<center><font color=\"#ffd22e\">" .. show_name_2 .. "</font></center>"), -1)
    end
  end
  if nx_int(HightCount) == nx_int(1) then
    nx_set_property(control, "Height", 100)
  elseif nx_int(HightCount) == nx_int(2) then
    nx_set_property(control, "Height", 110)
  elseif nx_int(HightCount) == nx_int(3) then
    nx_set_property(control, "Height", 150)
  end
end
function refresh_npc_name()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  local client_scene_obj = game_client:GetSceneObj(nx_string(client_player:QueryProp("LastObject")))
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    local game_visual = nx_value("game_visual")
    if nx_find_property(client_scene_obj, "Ident") then
      local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
      head_game:RefreshAll(visual_scene_obj)
    end
  end
end
function isHaveBegRecord(client_player, client_scene_obj)
  local player_name = client_player:QueryProp("Name")
  local row = client_scene_obj:GetRecordRows("beg_rec")
  for r = 0, row - 1 do
    local record = client_scene_obj:QueryRecord("beg_rec", r, 0)
    if nx_string(record) == nx_string(player_name) then
      return true
    end
  end
  return false
end
function isHaveSuanguaRecord(client_player, client_scene_obj)
  local player_name = client_player:QueryProp("Name")
  local row = client_scene_obj:GetRecordRows("Suangua_rec")
  for r = 0, row - 1 do
    local record = client_scene_obj:QueryRecord("Suangua_rec", r, 0)
    if nx_string(record) == nx_string(player_name) then
      return true
    end
  end
  return false
end
function isShowBegIcon(client_scene_obj)
  local HaveBegImageFlag = false
  local NpcConfigID = client_scene_obj:QueryProp("ConfigID")
  local NpcCanBegFlag = client_scene_obj:QueryProp("CanBegFlag")
  local NpcBegLevel = client_scene_obj:QueryProp("BegLevel")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local NpcName = gui.TextManager:GetFormatText(nx_string(NpcConfigID))
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow("job_rec", 0, "sh_qg", 0)
  local level
  if row < 0 then
    HaveBegImageFlag = false
  else
    level = client_player:QueryRecord("job_rec", row, 1)
  end
  if nx_int(NpcCanBegFlag) == nx_int(1) and 0 <= row and 0 <= nx_float(level) - nx_float(NpcBegLevel) then
    HaveBegImageFlag = true
  end
  if isHaveBegRecord(client_player, client_scene_obj) then
    HaveBegImageFlag = false
  end
  return HaveBegImageFlag
end
function isShowSuanguaIcon(client_scene_obj)
  local return_val = false
  local NpcConfigID = client_scene_obj:QueryProp("ConfigID")
  local NpcCanSuanguaFlag = client_scene_obj:QueryProp("CanSuanguaFlag")
  local NpcSuanguaLevel = client_scene_obj:QueryProp("SuanguaLevel")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local NpcName = gui.TextManager:GetFormatText(nx_string(NpcConfigID))
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow("job_rec", 0, "sh_gs", 0)
  local level
  if row < 0 then
    return_val = false
  else
    level = client_player:QueryRecord("job_rec", row, 1)
  end
  if nx_int(NpcCanSuanguaFlag) == nx_int(1) and 0 <= row and 0 <= nx_float(level) - nx_float(NpcSuanguaLevel) then
    return_val = true
  end
  if isHaveSuanguaRecord(client_player, client_scene_obj) then
    return_val = false
  end
  return return_val
end
