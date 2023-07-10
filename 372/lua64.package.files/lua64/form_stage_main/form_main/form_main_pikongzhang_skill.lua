require("util_gui")
require("util_functions")
require("util_static_data")
require("tips_data")
local FORM_MAIN_PIKONGZHANG_SKILL = "form_stage_main\\form_main\\form_main_pikongzhang_skill"
local CLIENT_SUBMSG_USE_SKILL = 1
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  on_size_change()
  local skill_list = get_global_arraylist("pikongzhang_skill_list")
  if not nx_is_valid(skill_list) then
    return 0
  end
  local skill_tab = skill_list:GetChildList()
  for i = 1, table.getn(skill_tab) do
    local skill_id = skill_tab[i].Name
    local photo = skill_static_query_by_id(skill_id, "Photo")
    local cooltype = skill_static_query_by_id(skill_id, "CoolDownCategory")
    local coolteam = skill_static_query_by_id(skill_id, "CoolDownTeam")
    form.grid_skill:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(skill_id), 0, i)
    if 0 < nx_number(cooltype) then
      form.grid_skill:SetCoolType(nx_int(i - 1), nx_int(cooltype))
    end
    if 0 < nx_number(coolteam) then
      form.grid_skill:SetCoolTeam(nx_int(i - 1), nx_int(coolteam))
    end
  end
end
function on_main_form_close(form)
  local skill_list = get_global_arraylist("pikongzhang_skill_list")
  if nx_is_valid(skill_list) then
    nx_destroy(skill_list)
  end
  local timer = nx_value("timer_game")
  timer:UnRegister(FORM_MAIN_PIKONGZHANG_SKILL, "on_delay_show_form_time", form)
  nx_destroy(form)
end
function on_size_change()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = nx_value(FORM_MAIN_PIKONGZHANG_SKILL)
  if nx_is_valid(form) then
    form.AbsTop = gui.Desktop.Height - 200
    form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  end
end
function on_grid_skill_select_changed(grid, index)
  local skill_id = nx_string(grid:GetItemName(index))
  if skill_id == "" then
    return 0
  end
  nx_execute("custom_sender", "custom_pikongzhang_activity", CLIENT_SUBMSG_USE_SKILL, skill_id)
  grid:SetSelectItemIndex(-1)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_grid_skill_mousein_grid(grid, index)
  local gui = nx_value("gui")
  local skill_id = nx_string(grid:GetItemName(index))
  if nx_string(skill_id) == "" then
    return 0
  end
  local skill_list = get_global_arraylist("pikongzhang_skill_list")
  if not nx_is_valid(skill_list) then
    return 0
  end
  local child = skill_list:GetChild(skill_id)
  if not nx_is_valid(child) then
    return 0
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if not nx_is_valid(item) then
    return 0
  end
  item.is_static = true
  item.ConfigID = nx_string(skill_id)
  item.ItemType = get_ini_prop("share\\Skill\\skill_new.ini", skill_id, "ItemType", "0")
  item.Level = child.level
  item.MaxLevel = 9
  item.static_skill_level = 1
  nx_execute("tips_game", "show_goods_tip", item, gui.Width - 10, gui.Height - 40, 40, 40, grid.ParentForm)
end
function on_grid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function open_form(...)
  local skill_list = get_global_arraylist("pikongzhang_skill_list")
  if not nx_is_valid(skill_list) then
    return 0
  end
  for i = 1, table.getn(arg) / 2 do
    local child = skill_list:CreateChild(nx_string(arg[i * 2 - 1]))
    if nx_is_valid(child) then
      child.level = arg[i * 2]
    end
  end
  local form = util_get_form(FORM_MAIN_PIKONGZHANG_SKILL, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    local timer = nx_value("timer_game")
    timer:UnRegister(FORM_MAIN_PIKONGZHANG_SKILL, "on_delay_show_form_time", form)
    timer:Register(5000, -1, FORM_MAIN_PIKONGZHANG_SKILL, "on_delay_show_form_time", form, -1, -1)
    return 0
  end
  util_show_form(FORM_MAIN_PIKONGZHANG_SKILL, true)
end
function close_form()
  local form = util_get_form(FORM_MAIN_PIKONGZHANG_SKILL, false)
  if not nx_is_valid(form) then
    return 0
  end
  form:Close()
end
function on_delay_show_form_time(form)
  if not nx_is_valid(form) then
    return 0
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return 0
  end
  util_show_form(FORM_MAIN_PIKONGZHANG_SKILL, true)
  local timer = nx_value("timer_game")
  timer:UnRegister(FORM_MAIN_PIKONGZHANG_SKILL, "on_delay_show_form_time", form)
end
