require("share\\view_define")
require("util_functions")
require("util_gui")
require("goods_grid")
require("const_define")
require("define\\object_type_define")
function GetSex(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man1"
  else
    ret_str = "ui_woman1"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex1(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man1"
  else
    ret_str = "ui_woman1"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex2(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man2"
  else
    ret_str = "ui_woman2"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex3(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man3"
  else
    ret_str = "ui_woman3"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex4(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man4"
  else
    ret_str = "ui_woman4"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex5(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man5"
  else
    ret_str = "ui_woman5"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex6(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man6"
  else
    ret_str = "ui_woman6"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex7(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man7"
  else
    ret_str = "ui_woman7"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex8(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man8"
  else
    ret_str = "ui_woman8"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex9(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man9"
  else
    ret_str = "ui_woman9"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetSex10(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  if nx_int(player:QueryProp("Sex")) == nx_int(0) then
    ret_str = "ui_man10"
  else
    ret_str = "ui_woman10"
  end
  return gui.TextManager:GetText(nx_string(ret_str))
end
function GetPlayerName(player, npc)
  if not nx_is_valid(player) then
    return ""
  end
  return player:QueryProp("Name")
end
function get_position_and_rolename(player, npc)
  local gui = nx_value("gui")
  local ret_str = ""
  if not nx_is_valid(player) or not nx_is_valid(npc) then
    return ""
  end
  local guild_name = player:QueryProp("GuildName")
  if guild_name == "" or guild_name == nil or guild_name == 0 then
    return ""
  end
  local role_name = player:QueryProp("Name")
  local guild_title = player:QueryProp("GuildTitle")
  ret_str = gui.TextManager:GetText(nx_string(guild_title))
  local side = get_player_side(player)
  if side == 1 then
    npc_do_action_when_talk(npc, "ty_guild02")
  elseif side == 2 then
    npc_do_action_when_talk(npc, "ty_guild03")
  else
    return ""
  end
  return ret_str .. role_name
end
function npc_do_action_when_talk(npc, acion_name)
  if not nx_is_valid(npc) then
    return
  end
  local action_module = nx_value("action_module")
  local game_visual = nx_value("game_visual")
  local actor2 = game_visual:GetSceneObj(nx_string(npc.Ident))
  if not nx_is_valid(actor2) then
    return
  end
  if nx_is_valid(action_module) then
    while not actor2.LoadFinish do
      nx_pause(0.1)
      if not nx_is_valid(actor2) then
        return
      end
    end
    action_module:DoAction(actor2, acion_name)
  end
end
function get_player_side(player)
  if not nx_is_valid(player) then
    return 0
  end
  if not nx_find_property(player, "GuildWarDomainID") or not nx_find_property(player, "GuildWarSide") then
    return 3
  end
  local main_side = player:QueryProp("GuildWarSide")
  local domain_id = player:QueryProp("GuildWarDomainID")
  if main_side == 1 and 0 < domain_id then
    return 1
  elseif main_side == 2 and 0 < domain_id then
    return 2
  end
  return 0
end
