require("util_functions")
require("util_gui")
local FORM = "form_stage_main\\form_shijia\\form_shijia_task"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local rbtn = form.rbtn_1
  if not nx_is_valid(rbtn) then
    return
  end
  local form_logic = nx_value("form_shijia_task")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_shijia_task")
  if nx_is_valid(form_logic) then
    nx_set_value("form_shijia_task", form_logic)
  end
  rbtn.Checked = true
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local form_logic = nx_value("form_shijia_task")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_destroy(form)
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_logic = nx_value("form_shijia_task")
  if not nx_is_valid(form_logic) then
    return
  end
  local id = nx_int(rbtn.DataSource)
  if id >= nx_int(1) and id <= nx_int(4) then
    form_logic:InitSJTaskUI(nx_int(id))
  end
end
function on_imagegrid_mousein_grid(grid, index)
  local grid_id = grid.DataSource
  local form_logic = nx_value("form_shijia_task")
  if nx_is_valid(form_logic) then
    local form = grid.ParentForm
    if not nx_is_valid(form) then
      return
    end
    local x = grid.AbsLeft
    local y = grid.AbsTop
    local config_id = form_logic:GetTaskPrize(nx_string(grid_id))
    if config_id ~= "" then
      nx_execute("tips_game", "show_tips_by_config", config_id, x, y, grid.ParentForm)
    end
  end
end
function on_imagegrid_mouseout_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
