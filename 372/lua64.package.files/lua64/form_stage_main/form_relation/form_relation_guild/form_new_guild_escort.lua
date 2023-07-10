require("util_gui")
require("share\\client_custom_define")
require("custom_sender")
require("util_functions")
local GUILD_ESCORT = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_escort"
local INI_FILE = "ini\\Guild\\guild_escort_find.ini"
local DEBUG_MODE = true
local GUILD_INTERACT_ESCORT_NORMAL = 1
local GUILD_INTERACT_ESCORT_PROBABILITY = 2
local GUILD_INTERACT_ESCORT_GOLDEN = 3
local GUILD_INTERACT_ESCORT_SZGOLDEN = 4
local SUB_CUSTOMMSG_REQUEST_YUNBIAO_DATA = 69
function main_form_init(self)
  self.Fixed = true
  query_activity_data()
end
function on_main_form_open(self)
  self.lbl_common.Text = nx_widestr("")
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function query_activity_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_YUNBIAO_DATA))
end
function on_recv_yunbiao_info(guild_level, ...)
  local gui = nx_value("gui")
  local form = nx_value(GUILD_ESCORT)
  if not nx_is_valid(form) then
    return
  end
  get_guild_max_times(form, guild_level)
  init_info(form)
  local size = table.getn(arg)
  if size <= 0 or size % 2 ~= 0 then
    return 0
  end
  local rows = size / 2
  for i = 1, rows do
    local base = (i - 1) * 2
    local yb_type = nx_string(arg[base + 1])
    local times = nx_int(arg[base + 2])
    reset_info(form, yb_type, nx_int(times))
  end
end
function get_guild_max_times(form, guild_level)
  if guild_level == 0 then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Guild\\guild_interact.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section
  for i = 1, 4 do
    local index = ini:FindSectionIndex(nx_string(i))
    local value = ini:GetSectionItemValue(index, guild_level - 1)
    local args = util_split_string(value, ",")
    local max_times = nx_int(args[2])
    if i == 1 then
      form.type_common_max = max_times
    elseif i == 2 then
      form.type_rand_max = max_times
    elseif i == 3 then
      form.type_gold_max = max_times
    elseif i == 4 then
      form.type_szgold_max = max_times
    end
  end
end
function init_info(form)
  form.lbl_common.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.type_common_max)
  form.lbl_rand.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.type_rand_max)
  form.lbl_gold.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.type_gold_max)
  form.lbl_szgold.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.type_szgold_max)
end
function reset_info(form, yb_type, times)
  if not nx_is_valid(form) then
    return false
  end
  if nx_int(yb_type) == nx_int(GUILD_INTERACT_ESCORT_NORMAL) then
    form.lbl_common.Text = nx_widestr(times) .. nx_widestr("/") .. nx_widestr(form.type_common_max)
  elseif nx_int(yb_type) == nx_int(GUILD_INTERACT_ESCORT_PROBABILITY) then
    form.lbl_rand.Text = nx_widestr(times) .. nx_widestr("/") .. nx_widestr(form.type_rand_max)
  elseif nx_int(yb_type) == nx_int(GUILD_INTERACT_ESCORT_GOLDEN) then
    form.lbl_gold.Text = nx_widestr(times) .. nx_widestr("/") .. nx_widestr(form.type_gold_max)
  elseif nx_int(yb_type) == nx_int(GUILD_INTERACT_ESCORT_SZGOLDEN) then
    form.lbl_szgold.Text = nx_widestr(times) .. nx_widestr("/") .. nx_widestr(form.type_szgold_max)
  end
end
function on_btn_findnpc_click(btn)
  local scene_id = get_scene_id()
  if scene_id == nx_int(-1) then
    return
  end
  local IniManager = nx_value("IniManager")
  if not DEBUG_MODE then
    if not IniManager:IsIniLoadedToManager(INI_FILE) then
      IniManager:LoadIniToManager(INI_FILE)
    end
  else
    IniManager:UnloadIniFromManager(INI_FILE)
    IniManager:LoadIniToManager(INI_FILE)
  end
  local ini = IniManager:GetIniDocument(INI_FILE)
  if not nx_is_valid(ini) or ini == nil then
    return
  end
  local sect_index = ini:FindSectionIndex(nx_string(scene_id))
  if sect_index < 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_guild_escort_not_find_npc"))
    return
  end
  local x = ini:ReadFloat(sect_index, "x", 0)
  local y = ini:ReadFloat(sect_index, "y", 0)
  local z = ini:ReadFloat(sect_index, "z", 0)
  local o = ini:ReadFloat(sect_index, "o", 0)
  local path_finding = nx_value("path_finding")
  if not nx_is_valid(path_finding) then
    return
  end
  path_finding:FindPath(x, y, z, o)
end
function get_scene_id()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nx_int(-1)
  end
  local config_id = client_scene:QueryProp("ConfigID")
  local ini = nx_execute("util_functions", "get_ini", "ini\\scenes.ini")
  if not nx_is_valid(ini) then
    return nx_int(-1)
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local id = ini:GetSectionByIndex(i)
    local config = ini:ReadString(i, "Config", "")
    if nx_string(config) == nx_string(config_id) then
      return nx_int(id)
    end
  end
  return nx_int(-1)
end
