require("util_functions")
require("define\\gamehand_type")
local SCENE_CFG_FILE = "ini\\scenes.ini"
local SCENE_DES_FILE = "ini\\ui\\clonescene\\clonescenedesc.ini"
local CDT_NORMAL_FILE = "share\\Rule\\condition.ini"
local MAX_RESET_COUNT = 7
local CLONE_SAVE_REC = "clone_rec_save"
local CLONE_INFO = {
  "ui_clonerec_dif01",
  "ui_clonerec_dif02",
  "ui_clonerec_dif03",
  "ui_clonerec_dif04"
}
local CLONE_LEVEL = {
  "ui_clonerec_dif11",
  "ui_clonerec_dif12",
  "ui_clonerec_dif13",
  "ui_clonerec_dif10"
}
local LEVEL_COLOR = {
  "255,50,150,50",
  "255,150,150,50",
  "255,150,50,50"
}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
  form.grid_clone:SetColAlign(20, "left")
  form.grid_clone:SetColWidth(0, 200)
  form.grid_clone:SetColWidth(1, 120)
  form.grid_clone:SetColWidth(2, 80)
  form.grid_clone:SetColWidth(3, 40)
  form.grid_clone:SetColWidth(4, 120)
  show_clone_list(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function show_clone_list(form)
  local gui = nx_value("gui")
  form.grid_clone:ClearRow()
  form.grid_clone:ClearSelect()
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    return 0
  end
  local player_powerlevel = get_player_powerlevel()
  local sec_count = scene_ini:GetSectionCount()
  for i = 1, 4 do
    for j = 0, sec_count - 1 do
      local id = scene_ini:GetSectionByIndex(j)
      local name = scene_ini:ReadString(j, "Name", "")
      local location = scene_ini:ReadString(j, "LocationScene", "")
      local switch_point = scene_ini:ReadString(j, "SwitchPoint", "")
      local player_num = scene_ini:ReadString(j, "MaxPlayers" .. i, "")
      local EntryLimited = scene_ini:ReadString(j, "EntryLimited" .. i, "")
      local scene_powerlevel = get_clone_scene_powerlevel(EntryLimited)
      local level_info = get_diff_level_info(player_powerlevel, scene_powerlevel)
      local level_desc = get_diff_level_desc(player_powerlevel, scene_powerlevel)
      if nx_number(player_powerlevel) >= nx_number(scene_powerlevel) then
        local row = form.grid_clone:InsertRow(-1)
        form.grid_clone:SetGridText(row, 0, gui.TextManager:GetText(name) .. gui.TextManager:GetText(CLONE_INFO[i]))
        form.grid_clone:SetGridText(row, 1, gui.TextManager:GetText(location))
        form.grid_clone:SetGridText(row, 2, nx_widestr(switch_point))
        form.grid_clone:SetGridText(row, 3, nx_widestr(player_num))
        form.grid_clone:SetGridText(row, 4, gui.TextManager:GetText(level_desc))
      end
    end
  end
end
function get_player_powerlevel()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local power_level = player:QueryProp("PowerLevel")
  return power_level
end
function get_player_reset_clone_count()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local reset_count = player:QueryProp("ResetCount")
  local remain_count = MAX_RESET_COUNT - reset_count
  return remain_count
end
function get_clone_scene_powerlevel(limit_id)
  local condition_ini = nx_execute("util_functions", "get_ini", CDT_NORMAL_FILE)
  if not nx_is_valid(condition_ini) then
    return 0
  end
  local sec_index = condition_ini:FindSectionIndex(nx_string(limit_id))
  if sec_index < 0 then
    return 0
  end
  local limit_min = condition_ini:ReadString(sec_index, "min", "")
  if limit_min == "" or limit_min == nil then
    return 0
  end
  return limit_min
end
function get_diff_level_color(player_powerlevel, clonescene_powerlevel)
  if player_powerlevel == nil or clonescene_powerlevel == nil then
    return LEVEL_COLOR[1]
  end
  local diff_powerlevel = nx_number(player_powerlevel - clonescene_powerlevel)
  if diff_powerlevel < 0 or 10 < diff_powerlevel then
    return LEVEL_COLOR[1]
  end
  if 7 < diff_powerlevel then
    return LEVEL_COLOR[1]
  elseif 5 < diff_powerlevel then
    return LEVEL_COLOR[2]
  else
    return LEVEL_COLOR[3]
  end
end
function get_diff_level_info(player_powerlevel, clonescene_powerlevel)
  if player_powerlevel == nil or clonescene_powerlevel == nil then
    return CLONE_INFO[1]
  end
  local diff_powerlevel = nx_number(player_powerlevel - clonescene_powerlevel)
  if diff_powerlevel < 0 or 10 < diff_powerlevel then
    return CLONE_INFO[1]
  end
  if 7 < diff_powerlevel then
    return CLONE_INFO[1]
  elseif 5 < diff_powerlevel then
    return CLONE_INFO[2]
  else
    return CLONE_INFO[3]
  end
end
function get_diff_level_desc(player_powerlevel, clonescene_powerlevel)
  if player_powerlevel == nil or clonescene_powerlevel == nil then
    return CLONE_LEVEL[4]
  end
  local diff_powerlevel = nx_number(player_powerlevel - clonescene_powerlevel)
  if diff_powerlevel < 0 or 10 < diff_powerlevel then
    return CLONE_LEVEL[4]
  end
  if 7 < diff_powerlevel then
    return CLONE_LEVEL[1]
  elseif 5 < diff_powerlevel then
    return CLONE_LEVEL[2]
  else
    return CLONE_LEVEL[3]
  end
end
