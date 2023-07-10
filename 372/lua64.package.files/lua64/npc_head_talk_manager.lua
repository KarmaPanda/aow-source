require("share\\view_define")
require("util_functions")
require("util_gui")
require("goods_grid")
require("const_define")
require("define\\object_type_define")
MAX_DIS = 999
NORMAL_SPEAK_DIS = 45
SPRING_SPEAK_DIS = 12
function init(manager)
  nx_callback(manager, "on_npc_normal_talk", "on_npc_normal_talk")
  nx_callback(manager, "on_npc_spring_talk", "on_npc_spring_talk")
end
function on_npc_normal_talk(manage, ident, talk_id)
  local game_client = nx_value("game_client")
  local client_scene_obj = game_client:GetSceneObj(nx_string(ident))
  if not nx_is_valid(client_scene_obj) then
    local npc_head_talk_manager = nx_value("npc_head_talk_manager")
    if nx_is_valid(npc_head_talk_manager) then
      npc_head_talk_manager:DelNpcFormNormalList(nx_string(ident))
    end
    return
  end
  if client_scene_obj:FindProp("Dead") then
    local dead = client_scene_obj:QueryProp("Dead")
    if nx_int(dead) > nx_int(0) then
      return
    end
  end
  local config = client_scene_obj:QueryProp("ConfigID")
  local gui = nx_value("gui")
  local wide_str = gui.TextManager:GetText(nx_string(talk_id) .. nx_string(config))
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowChatTextOnHead(client_scene_obj, wide_str, 5000)
  end
end
function on_npc_spring_talk(manage, ident)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local client_scene_obj = game_client:GetSceneObj(ident)
  local npc_head_talk_manager = nx_value("npc_head_talk_manager")
  if not nx_is_valid(client_scene_obj) then
    npc_head_talk_manager:DelNpcFormSpringList(ident)
    return
  end
  if client_scene_obj:FindProp("Dead") then
    local dead = client_scene_obj:QueryProp("Dead")
    if nx_int(dead) > nx_int(0) then
      return
    end
  end
  local npc_configid = client_scene_obj:QueryProp("ConfigID")
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument("ini\\ui\\npcheadtalk\\npc_head_talk.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(npc_configid))
  if sec_index < 0 then
    return
  end
  local talkinfo = ini:ReadString(sec_index, "HeadSpringSay", "")
  local str_lst = util_split_string(talkinfo, ",")
  for i = 1, table.getn(str_lst) do
    if ExeNpcHeadTalkRule(client_scene_obj, player, nx_string(str_lst[i])) then
      npc_head_talk_manager:ForbidNpcNormalTalk(client_scene_obj.Ident)
      return
    end
  end
end
function ExeNpcHeadTalkRule(npc, player, rule)
  local gui = nx_value("gui")
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  if rule == "" or rule == nil then
    return false
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument("ini\\ui\\npcheadtalk\\head_talk_info.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(rule))
  if sec_index < 0 then
    return false
  end
  local talk_rule = ini:ReadString(sec_index, "rule", "")
  local talk_uiArg = ini:ReadString(sec_index, "UiArg", "")
  local talk_string = ini:ReadString(sec_index, "uistring", "")
  local find_and = string.find(talk_rule, "&")
  local find_or = string.find(talk_rule, "|")
  local result = false
  if find_and ~= nil then
    result = true
    local str_lst = util_split_string(talk_rule, "&")
    for i = 1, table.getn(str_lst) do
      if not ExeRuleFunc(npc, player, nx_string(str_lst[i])) then
        result = false
        break
      end
    end
  elseif find_or ~= nil then
    result = false
    local str_lst = util_split_string(talk_rule, "|")
    for i = 1, table.getn(str_lst) do
      if ExeRuleFunc(npc, player, nx_string(str_lst[i])) then
        result = true
        break
      end
    end
  else
    result = ExeRuleFunc(npc, player, nx_string(talk_rule))
  end
  if result == true then
    local arg_type = string.find(talk_uiArg, "@")
    local arg_string = ""
    if arg_type ~= "" and arg_type ~= nil then
    else
      arg_string = nx_execute("npc_normal_talk_arg_func", nx_string(talk_uiArg), player, npc)
    end
    local configid = npc:QueryProp("ConfigID")
    local uistr = nx_string(talk_string) .. nx_string(configid)
    local wide_str = gui.TextManager:GetFormatText(nx_string(uistr), nx_string(arg_string))
    local head_game = nx_value("HeadGame")
    if nx_is_valid(head_game) then
      head_game:ShowChatTextOnHead(npc, wide_str, 5000)
    end
  end
  return result
end
function ExeRuleFunc(npc, player, func)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  if func == "" or func == nil then
    return false
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument("ini\\ui\\npcheadtalk\\head_talk_rule.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(func))
  if sec_index < 0 then
    return false
  end
  local rule_func = ini:ReadString(sec_index, "function", "")
  local fule_func_arg = ini:ReadString(sec_index, "args", "")
  local arg_lst = util_split_string(fule_func_arg, ",")
  local result = false
  if table.getn(arg_lst) == 0 then
    result = nx_execute("npc_normal_talk_func", nx_string(rule_func), npc, player)
  elseif table.getn(arg_lst) == 1 then
    result = nx_execute("npc_normal_talk_func", nx_string(rule_func), npc, player, arg_lst[1])
  elseif table.getn(arg_lst) == 2 then
    result = nx_execute("npc_normal_talk_func", nx_string(rule_func), npc, player, arg_lst[1], arg_lst[2])
  elseif table.getn(arg_lst) == 3 then
    result = nx_execute("npc_normal_talk_func", nx_string(rule_func), npc, player, arg_lst[1], arg_lst[2], arg_lst[3])
  end
  return result
end
function TeamNpcCanTalk(npc)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument("ini\\ui\\npcheadtalk\\npc_head_talk.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local npc_configid = npc:QueryProp("ConfigID")
  local sec_index = ini:FindSectionIndex(nx_string(npc_configid))
  if sec_index < 0 then
    return 0
  end
  local Teammate_Str = ini:ReadString(sec_index, "Teammate", "")
  if Teammate_Str == "" then
    return 1
  end
  local Teammate = util_split_string(Teammate_Str, ",")
  if table.getn(Teammate) < 2 then
    return 1
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return 0
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, configid in pairs(Teammate) do
    local findflg = false
    for j, client_obj in pairs(client_obj_lst) do
      if client_obj:QueryProp("ConfigID") == configid then
        local distance = get_distance(player, client_obj)
        if nx_float(distance) > nx_float(NORMAL_SPEAK_DIS) then
          return 0
        else
          findflg = 1
          break
        end
      end
    end
    if findflg == false then
      return 0
    end
  end
  return 1
end
