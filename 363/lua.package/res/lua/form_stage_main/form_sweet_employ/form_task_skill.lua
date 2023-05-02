require("util_gui")
require("tips_data")
require("util_functions")
require("util_static_data")
local FORM_TASK_SKILL = "form_stage_main\\form_sweet_employ\\form_task_skill"
local INI_SKILL = "share\\Skill\\skill_new.ini"
local INI_SKILL_VAR_PROP = "share\\Skill\\skill_normal_varprop.ini"
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
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 1.5
end
function change_form_size()
  local form = nx_value(FORM_TASK_SKILL)
  if not nx_is_valid(form) then
    return
  end
  set_form_pos(form)
end
function set_form_data(form)
  set_grid_data(form)
end
function set_grid_data(form)
  local grid = form.grid_skill
  grid:Clear()
  local skill_id = "skill_sweetemploy_01"
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
    return
  end
  local hit_shape, target_shape = get_skill_info(skill_id)
  nx_execute("game_effect", "add_ground_pick_effect", hit_shape * 2, target_shape)
end
function get_skill_info(skill_id)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return 0, 0
  end
  local level = 1
  local static_data = nx_int(get_ini_prop(INI_SKILL, skill_id, "StaticData", "0"))
  local min_var_prop_no = nx_int(skill_static_query(static_data, "MinVarPropNo"))
  local max_var_prop_no = nx_int(skill_static_query(static_data, "MaxVarPropNo"))
  local var_prop_no = min_var_prop_no + level - 1
  local hit_shape_no = nx_number(get_ini_prop(INI_SKILL_VAR_PROP, nx_string(var_prop_no), "HitShapePkg", "-1"))
  local target_shape_no = nx_number(get_ini_prop(INI_SKILL_VAR_PROP, nx_string(var_prop_no), "TargetShapePkg", "-1"))
  local hit_shape = data_query:Query(STATIC_DATA_SKILL_HITSHAPE, nx_number(hit_shape_no), "HitShapePara2")
  local target_shape = data_query:Query(STATIC_DATA_SKILL_TARGETSHAPE, nx_number(target_shape_no), "TargetShapePara2")
  return hit_shape, target_shape
end
function use_task_skill()
  local form = util_get_form(FORM_TASK_SKILL)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_skill
  if not nx_find_custom(grid, "skill_id") then
    return
  end
  local skill_id = grid.skill_id
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local decal = nx_value("ground_pick_decal")
  if not nx_is_valid(decal) then
    return
  end
  nx_execute("custom_sender", "custom_offline_employ", nx_int(17), skill_id, decal.PosX, decal.PosY, decal.PosZ)
  nx_set_custom(grid, "skill_id", nx_string(""))
end
