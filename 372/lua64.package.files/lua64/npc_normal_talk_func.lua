require("share\\view_define")
require("util_functions")
require("util_gui")
require("goods_grid")
require("const_define")
require("define\\object_type_define")
function SexPair(npc, player, sex)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  if sex == "" or not sex == nil then
    return false
  end
  local playersex = player:QueryProp("Sex")
  if nx_int(sex) == nx_int(playersex) then
    return true
  else
    return false
  end
end
function PlayerPropLessThen(npc, player, PropName, PropVal)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  local value = player:QueryProp(nx_string(PropName))
  local type = nx_type(value)
  if type == "boolean" then
    return nx_boolean(value) == nx_boolean(PropVal)
  elseif type == "number" then
    return nx_number(value) <= nx_number(PropVal)
  elseif type == "string" then
    return false
  elseif type == "widestr" then
    return false
  elseif type == "int" then
    return nx_int(value) <= nx_int(PropVal)
  elseif type == "int64" then
    return nx_int64(value) <= nx_int64(PropVal)
  elseif type == "float" then
    return nx_float(value) <= nx_float(PropVal)
  elseif type == "double" then
    return nx_double(value) <= nx_double(PropVal)
  elseif type == "object" then
    return false
  end
  return false
end
function ReocrdValueFind(npc, player, RecordName, col, value)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  if not player:FindRecord(nx_string(RecordName)) then
    return false
  end
  local row_num = player:GetRecordRows(nx_string(RecordName))
  for i = 0, row_num - 1 do
    local item_value = player:QueryRecord(nx_string(RecordName), i, nx_int(col))
    if nx_string(item_value) == nx_string(value) then
      return true
    end
  end
  return false
end
function IsHaveTask(npc, player, taskid)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  if not player:FindRecord("Task_Accepted") then
    return false
  end
  local row_num = player:GetRecordRows("Task_Accepted")
  for i = 0, row_num - 1 do
    local id = player:QueryRecord("Task_Accepted", i, 0)
    if nx_string(taskid) == nx_string(id) then
      return true
    end
  end
  return false
end
function IsCompleteTask(npc, player, taskid)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  if not player:FindRecord("Task_Accepted") then
    return false
  end
  local row_num = player:GetRecordRows("Task_Accepted")
  for i = 0, row_num - 1 do
    local id = player:QueryRecord("Task_Accepted", i, 0)
    if nx_string(taskid) == nx_string(id) then
      local task_name = player:QueryRecord("Task_Accepted", i, 5)
      if string.find(task_name, "(@0)") ~= nil then
        return true
      else
        return false
      end
    end
  end
  return false
end
function RandomResult(npc, player, probability)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  local rand_val = math.random(100)
  if tonumber(probability) > tonumber(rand_val) then
    return true
  else
    return false
  end
end
function repute_jianghule_lessthen(npc, player, value)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  local rows = player:FindRecordRow("Repute_Record", 0, "repute_jianghu", 0)
  if 0 <= rows then
    local repute_value = player:QueryRecord("Repute_Record", rows, 1)
    if nx_int(repute_value) <= nx_int(value) then
      return true
    else
      return false
    end
  end
  return false
end
function is_guild_captain(npc, player)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  local is_dead = npc:QueryProp("Dead")
  if 0 < is_dead then
    return false
  end
  local guild_name = player:QueryProp("GuildName")
  if guild_name == "" or guild_name == 0 then
    return false
  end
  local is_captain = nx_int(player:QueryProp("IsGuildCaptain"))
  if nx_int(is_captain) ~= nx_int(2) then
    return true
  end
  return false
end
function is_domain_state(npc, player, value)
  if not nx_is_valid(npc) or not nx_is_valid(player) then
    return false
  end
  local guild_name = player:QueryProp("GuildName")
  if guild_name == "" then
    return false
  end
  if not nx_find_property(player, "GuildWarDomainID") or not nx_find_property(player, "GuildWarSide") then
    return false
  end
  local main_side = player:QueryProp("GuildWarSide")
  local domain_id = player:QueryProp("GuildWarDomainID")
  if nx_int(value) == nx_int(0) then
    if nx_int(main_side) == nx_int(0) and nx_int(domain_id) == nx_int(0) then
      return true
    end
  elseif nx_int(value) == nx_int(1) and nx_int(main_side) == nx_int(1) and nx_int(domain_id) > nx_int(0) then
    return true
  end
  return false
end
