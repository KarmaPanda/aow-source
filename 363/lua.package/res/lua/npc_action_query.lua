state_list = {
  "base",
  "feeling",
  "fight",
  "hurt",
  "skill"
}
MAX_STATE = 5
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function get_weaponmode_action(weaponmode, action)
  if weaponmode == nil or action == nil then
    return ""
  end
  local file_name = "share\\Rule\\weaponmode.ini"
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return ""
  end
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSection(weaponmode)
  if sec_index < 0 then
    return ""
  end
  local templatename = ini:ReadString(sec_index, "template", "")
  if nx_string(templatename) == "" then
    return ""
  end
  for i = 1, MAX_STATE do
    local file_name = ini:ReadString(sec_index, state_list[i], "")
    local real_action = find_action(templatename, state_list[i], file_name, action)
    if real_action ~= nil and real_action ~= "" then
      return real_action
    end
  end
  return ""
end
function find_action(templatename, key, value, action)
  local file_name = "obj\\actionlibrary\\" .. templatename .. "\\" .. key .. "\\" .. value
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return nil
  end
  local ini = IniManager:LoadIniToManager(file_name)
  if not nx_is_valid(ini) then
    return nil
  end
  local sec_index = ini:FindSection("Action")
  if sec_index < 0 then
    return nil
  end
  local keys_count = ini:GetSectionItemCount(sec_index)
  for i = 1, keys_count do
    local value = ini:GetSectionItemValue(sec_index, i - 1)
    if nx_string(key) == nx_string(action) then
      return value
    end
  end
  return nil
end
function get_npc_weapon_mode_action(role, action_name)
  local game_visual = nx_value("game_visual")
  local weapon_mode = game_visual:QueryRoleWeaponMode(role)
  if weapon_mode == "!" then
    return action_name
  end
  local role_type = game_visual:QueryRoleType(role)
  if role_type == 4 then
    local wm_action = ""
    if action_name == "stand" or action_name == "run" then
      local ls = game_visual:QueryRoleLogicState(role)
      if nx_number(ls) == nx_number(1) then
        action_name = "fi_" .. action_name
      end
      if nx_number(ls) == nx_number(2) then
        action_name = "grd_" .. action_name
      end
    end
    if 1 < string.len(weapon_mode) then
      wm_action = get_weaponmode_action(nx_string(weapon_mode), nx_string(action_name))
      if string.len(wm_action) > 0 then
        return wm_action
      end
    end
  end
  return action_name
end
function get_weaponmode_action_lst(weaponmode)
  action_list = {}
  if weaponmode == nil then
    return action_list
  end
  local file_name = "share\\Rule\\weaponmode.ini"
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return action_list
  end
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  if not nx_is_valid(ini) then
    return action_list
  end
  local sec_index = ini:FindSection(weaponmode)
  if sec_index < 0 then
    return action_list
  end
  local templatename = ini:ReadString(sec_index, "template", "")
  if nx_string(templatename) == "" then
    return action_list
  end
  local count = 1
  for i = 1, MAX_STATE do
    local file_name = ini:ReadString(sec_index, state_list[i], "")
    local action_lst = get_action_lst(templatename, state_list[i], file_name)
    for j = 1, table.getn(action_lst) do
      action_list[count] = action_lst[j]
      count = count + 1
    end
  end
  return action_list
end
function get_action_lst(templatename, state, action)
  local action_lst = {}
  local file_name = "obj\\actionlibrary\\" .. templatename .. "\\" .. state .. "\\" .. action
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return action_lst
  end
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  if not nx_is_valid(ini) then
    return action_lst
  end
  local sec_index = ini:FindSection("Action")
  if sec_index < 0 then
    return action_lst
  end
  local keys_count = ini:GetSectionItemCount(sec_index)
  for i = 1, keys_count do
    action_lst[i] = ini:GetSectionItemKey(sec_index, i - 1)
  end
  return action_lst
end
function is_weaponmode_spec(weaponmode)
  if weaponmode == nil then
    return false
  end
  local file_name = "share\\Rule\\weaponmode.ini"
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return false
  end
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(weaponmode)
  if sec_index < 0 then
    return false
  end
  local spec = ini:ReadInteger(sec_index, "spec", 0)
  if nx_number(spec) == 0 then
    return false
  end
  return true
end
