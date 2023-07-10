require("util_gui")
require("tips_data")
require("util_functions")
require("util_static_data")
local INI_SKILL = "share\\Skill\\skill_new.ini"
local FORM_JHPK_SKILL = "form_stage_main\\form_relation\\form_scene_jhpk_skill"
local CUSTOM_SUB_JHPK_CHENK_USESKILL = 9
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_pos(form)
  set_form_data(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 1
  form.Top = (gui.Height - form.Height) / 1.5
end
function change_form_size()
  local form = nx_value(FORM_JHPK_SKILL)
  if not nx_is_valid(form) then
    return
  end
  set_form_pos(form)
end
function set_form_data(form)
  set_grid_data(form)
end
function set_grid_data(form)
  local grid = form.grid_skill_first
  grid:Clear()
  local skill_id = "skill_jhpk_01"
  local photo = skill_static_query_by_id(skill_id, "Photo")
  local cool_type = skill_static_query_by_id(skill_id, "CoolDownCategory")
  local cool_team = skill_static_query_by_id(skill_id, "CoolDownTeam")
  grid:AddItem(0, photo, nx_widestr(skill_id), 1, -1)
  grid:SetBindIndex(0, 1)
  if nx_number(cool_type) > nx_number(0) then
    grid:SetCoolType(0, nx_int(cool_type))
  end
  if nx_number(cool_team) > nx_number(0) then
    grid:SetCoolTeam(0, nx_int(cool_team))
  end
end
function on_grid_skill_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local skill_id = grid:GetItemName(index)
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if not nx_is_valid(item) then
    return
  end
  item.is_static = true
  item.ConfigID = nx_string(skill_id)
  item.ItemType = get_ini_prop(INI_SKILL, skill_id, "ItemType", "0")
  item.Level = 1
  item.static_skill_level = 1
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 40, 40, grid.ParentForm)
end
function on_grid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_grid_skill_select_changed(grid, index)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if gui.CoolManager:IsCooling(nx_int(12589), nx_int(-1)) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("9009"), 2)
    return
  end
  if grid:IsEmpty(index) then
    return
  end
  local skill_id = grid:GetItemName(index)
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  nx_set_custom(grid, "skill_id", nx_string(skill_id))
  local target_type = skill_static_query_by_id(skill_id, "TargetType")
  if nx_int(target_type) ~= nx_int(1) then
    nx_execute("custom_sender", "custom_send_scene_jhpk", CUSTOM_SUB_JHPK_CHENK_USESKILL, nx_string(skill_id))
  end
end
function reset_scene()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value(FORM_JHPK_SKILL)
  if check_jhscene() then
    if nx_is_valid(form) then
      return
    end
    form = nx_execute("util_gui", "util_get_form", FORM_JHPK_SKILL, true, false)
    if nx_is_valid(form) then
      form:Show()
      form.Visible = true
      return
    end
  end
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
  end
end
function check_jhscene()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not player:FindProp("CurJHSceneConfigID") then
    return false
  end
  local jh_scene = player:QueryProp("CurJHSceneConfigID")
  if jh_scene == nil or jh_scene == "" then
    return false
  end
  return true
end
