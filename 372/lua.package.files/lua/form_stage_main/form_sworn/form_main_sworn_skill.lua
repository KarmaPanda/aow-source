require("util_gui")
require("tips_data")
require("role_composite")
require("util_functions")
require("util_role_prop")
require("util_static_data")
require("define\\sysinfo_define")
require("share\\client_custom_define")
local INI_SKILL = "share\\Skill\\skill_new.ini"
local FORM_SKILL = "form_stage_main\\form_sworn\\form_main_sworn_skill"
local SKILL_INDEX = 5
local CTS_SUB_MSG_SWORN_USE_SKILL = 5
function main_form_init(form)
  form.Fixed = false
  form.grid_skill = ""
  return 1
end
function on_main_form_open(form)
  set_form_pos(form)
  skill_refresh(form)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function close_form()
  local form = nx_value(FORM_SKILL)
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 1.4
end
function change_form_size()
  local form = nx_value(FORM_SKILL)
  if not nx_is_valid(form) then
    return
  end
  set_form_pos(form)
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
  local target_type = skill_static_query_by_id(skill_id, "TargetType")
  if nx_int(target_type) == nx_int(1) then
    form.grid_skill = skill_id
    local hit_shape, target_shape = get_skill_info(skill_id)
    nx_execute("game_effect", "add_ground_pick_effect", hit_shape * 2, target_shape)
  else
    nx_execute("custom_sender", "custom_sworn", nx_int(CTS_SUB_MSG_SWORN_USE_SKILL), nx_string(skill_id))
  end
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
function skill_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, SKILL_INDEX do
    local control_name = "grid_skill_" .. nx_string(i)
    local control = form:Find(control_name)
    if nx_is_valid(control) then
      control:Clear()
      local skill_id = "jiebai_ls_00" .. nx_string(i)
      local photo = skill_static_query_by_id(skill_id, "Photo")
      local cool_type = skill_static_query_by_id(skill_id, "CoolDownCategory")
      local cool_team = skill_static_query_by_id(skill_id, "CoolDownTeam")
      control:AddItem(0, photo, nx_widestr(skill_id), 1, -1)
      control:SetBindIndex(0, 1)
      if nx_number(cool_type) > nx_number(0) then
        control:SetCoolType(0, nx_int(cool_type))
      end
      if nx_number(cool_team) > nx_number(0) then
        control:SetCoolTeam(0, nx_int(cool_team))
      end
    end
  end
end
function open_form()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value(FORM_SKILL)
  if nx_is_valid(form) then
    return
  end
  form = nx_execute("util_gui", "util_get_form", FORM_SKILL, true, false)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
    return
  end
end
