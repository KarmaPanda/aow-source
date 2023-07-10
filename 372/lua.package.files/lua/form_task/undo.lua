require("form_task\\tool")
function undo_init(self)
  nx_callback(self, "on_changed", "undo_changed")
  nx_callback(self, "on_undo_modify_task_info", "do_task_info")
  nx_callback(self, "on_redo_modify_task_info", "do_task_info")
  nx_callback(self, "on_undo_grid_monster_list", "undo_grid_monster_list")
  nx_callback(self, "on_redo_grid_monster_list", "redo_grid_monster_list")
  nx_callback(self, "on_undo_grid_monster_overview", "undo_grid_monster_overview")
  nx_callback(self, "on_redo_grid_monster_overview", "redo_grid_monster_overview")
  nx_callback(self, "on_undo_monster_overview_add", "undo_monster_overview_add")
  nx_callback(self, "on_redo_monster_overview_add", "redo_monster_overview_add")
  nx_callback(self, "on_undo_monster_overview_delete", "undo_monster_overview_delete")
  nx_callback(self, "on_redo_monster_overview_delete", "redo_monster_overview_delete")
  nx_callback(self, "on_undo_grid_tool_list", "undo_grid_tool_list")
  nx_callback(self, "on_redo_grid_tool_list", "redo_grid_tool_list")
  nx_callback(self, "on_undo_grid_tool_overview", "undo_grid_tool_overview")
  nx_callback(self, "on_redo_grid_tool_overview", "redo_grid_tool_overview")
  nx_callback(self, "on_undo_grid_subtask_overview", "undo_grid_subtask_overview")
  nx_callback(self, "on_redo_grid_subtask_overview", "redo_grid_subtask_overview")
  nx_callback(self, "on_undo_modify_text", "modify_text")
  nx_callback(self, "on_redo_modify_text", "modify_text")
  nx_callback(self, "on_undo_show_or_close_text_form", "show_or_close_text_form")
  nx_callback(self, "on_redo_show_or_close_text_form", "show_or_close_text_form")
  nx_callback(self, "on_undo_modify_questions", "modify_questions")
  nx_callback(self, "on_redo_modify_questions", "modify_questions")
  nx_callback(self, "on_undo_modify_text_task", "modify_text_task")
  nx_callback(self, "on_redo_modify_text_task", "modify_text_task")
  nx_callback(self, "on_undo_grid_subtask_process_task_info", "undo_grid_subtask_process_task_info")
  nx_callback(self, "on_redo_grid_subtask_process_task_info", "redo_grid_subtask_process_task_info")
  nx_callback(self, "on_undo_modify_process", "modify_process")
  nx_callback(self, "on_redo_modify_process", "modify_process")
  return 1
end
function undo_changed(self)
  local undo_count = self.UndoCount
  local form = nx_value("task_form")
  if nx_is_valid(form.log_form) then
    form.log_form.log_list.curr_undo_pos = undo_count
    nx_execute("form_task\\form_log", "update", form.log_form.log_list)
  end
  return 1
end
local set_grid_main_and_more_info = function(type, task_id, name, value)
  local form = nx_value("task_form")
  if form.task_info.ID == task_id then
    nx_set_custom(form.task_info, name, value)
    nx_execute("form_task\\form_task_info", "update_task_info", form.task_info_form, form.task_info)
    select_grid_by_key(form.task_info_form.grid_main_info, name)
    select_grid_by_key(form.task_info_form.grid_more_info, name)
    nx_execute("form_task\\form_monster_list", "update_monster_list", form.monster_list_form, form.task_info)
    nx_execute("form_task\\form_tool_list", "update_tool_list", form.tool_list_form, form.task_info)
    local text_form = nx_value("text_form")
    if nx_is_valid(text_form) then
      nx_execute("form_task\\form_text", "show_other_place", name)
    end
  else
  end
  return 1
end
function do_task_info(self, type, task_id, name, value)
  return set_grid_main_and_more_info(type, task_id, name, value)
end
local set_grid_monster_list_info = function(type, monster_id, name, value)
  local monster_item = nx_execute("form_task\\form_task", "get_monster_item_by_id", monster_id)
  if nx_is_valid(monster_item) then
    nx_set_custom(monster_item, name, value)
    local form = nx_value("task_form")
    nx_execute("form_task\\form_monster_list", "update_monster_list", form.monster_list_form, form.task_info)
    local monster_overview_form = nx_value("monster_overview_form")
    if nx_is_valid(monster_overview_form) then
      nx_execute("form_task\\form_monster_overview", "update_monster_overview", monster_overview_form)
    elseif type == "grid_monster_overview" then
      nx_execute("form_task\\form_monster_list", "btn_show_all_click", nil)
      monster_overview_form = nx_value("monster_overview_form")
    end
    if type == "grid_monster_overview" then
      select_grid_by_key(monster_overview_form.grid_monster_list, monster_id)
    end
  end
  return 1
end
function undo_grid_monster_list(self, type, monster_id, name, value)
  return set_grid_monster_list_info(type, monster_id, name, value)
end
function redo_grid_monster_list(self, type, monster_id, name, value)
  return set_grid_monster_list_info(type, monster_id, name, value)
end
function undo_grid_monster_overview(self, type, monster_id, name, value)
  return set_grid_monster_list_info(type, monster_id, name, value)
end
function redo_grid_monster_overview(self, type, monster_id, name, value)
  return set_grid_monster_list_info(type, monster_id, name, value)
end
local set_grid_tool_list_info = function(type, tool_id, name, value)
  local tool_item = nx_execute("form_task\\form_task", "get_tool_item_by_id", tool_id)
  if nx_is_valid(tool_item) then
    nx_set_custom(tool_item, name, value)
    local form = nx_value("task_form")
    nx_execute("form_task\\form_tool_list", "update_tool_list", form.tool_list_form, form.task_info)
    local tool_overview_form = nx_value("tool_overview_form")
    if nx_is_valid(tool_overview_form) then
      nx_execute("form_task\\form_tool_overview", "update_tool_overview", tool_overview_form)
    elseif type == "grid_tool_overview" then
      nx_execute("form_task\\form_tool_list", "btn_show_all_click", nil)
      tool_overview_form = nx_value("tool_overview_form")
    end
    if type == "grid_tool_overview" then
      select_grid_by_key(tool_overview_form.grid_tool_list, tool_id)
    end
  end
  return 1
end
function undo_grid_tool_list(self, type, tool_id, name, value)
  return set_grid_tool_list_info(type, tool_id, name, value)
end
function redo_grid_tool_list(self, type, tool_id, name, value)
  return set_grid_tool_list_info(type, tool_id, name, value)
end
function undo_grid_tool_overview(self, type, tool_id, name, value)
  return set_grid_tool_list_info(type, tool_id, name, value)
end
function redo_grid_tool_overview(self, type, tool_id, name, value)
  return set_grid_tool_list_info(type, tool_id, name, value)
end
local set_grid_process_overview_info = function(type, id, name, number, value, is_show_form)
  local subtask_info = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", type, id)
  if nx_is_valid(subtask_info) then
    local item = subtask_info:GetChildByIndex(number)
    if nx_is_valid(item) then
      local child = item:GetChild(name)
      child.item_name = value
      local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
      if not nx_is_valid(form_subtask_overview) and is_show_form then
        nx_execute("form_task\\form_subtask_process", "subtask_overview_btn_click", nil)
        form_subtask_overview = nx_value("form_task\\form_subtask_overview")
      end
      if nx_is_valid(form_subtask_overview) then
        local ctl = form_subtask_overview:Find(type .. "_rb")
        ctl.Checked = true
        nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, type)
        select_grid_by_key(form_subtask_overview.overview_grid, id)
      end
      local task_form = nx_value("task_form")
      nx_execute("form_task\\form_subtask_process", "update_subtask_process_view", task_form.subtask_process_form)
      local text_form = nx_value("text_form")
      if nx_is_valid(text_form) then
        nx_execute("form_task\\form_text", "show_other_place", name)
      end
    else
      return 0
    end
  else
    return 0
  end
  return 1
end
function undo_grid_subtask_overview(self, type, id, name, number, vlaue)
  local ret = set_grid_process_overview_info(type, id, name, number, vlaue, true)
  if ret == 0 then
    nx_msgbox("\178\189\214\232\215\220\177\237 Undo\180\237\206\243!")
  end
  return ret
end
function redo_grid_subtask_overview(self, type, id, name, number, vlaue)
  local ret = set_grid_process_overview_info(type, id, name, number, vlaue, true)
  if ret == 0 then
    nx_msgbox("\178\189\214\232\215\220\177\237 Redo\180\237\206\243!")
  end
  return ret
end
function undo_grid_subtask_process_task_info(self, type, id, name, number, vlaue)
  return set_grid_process_overview_info(type, id, name, number, vlaue, false)
end
function redo_grid_subtask_process_task_info(self, type, id, name, number, vlaue)
  return set_grid_process_overview_info(type, id, name, number, vlaue, false)
end
function undo_monster_overview_add(self, id)
  local monster_overview_form = nx_value("monster_overview_form")
  if not nx_is_valid(monster_overview_form) then
    nx_execute("form_task\\form_monster_list", "btn_show_all_click", nil)
    monster_overview_form = nx_value("monster_overview_form")
  end
  local monster_config = nx_value("monster_config")
  local monster_item = monster_config:GetChild(id)
  if nx_is_valid(monster_item) then
    monster_config:RemoveChildByID(monster_item)
  end
  local grid = monster_overview_form.grid_monster_list
  for i = 0, grid.RowCount - 1 do
    if grid:GetGridText(i, 0) == nx_widestr(id) then
      grid:DeleteRow(i)
      break
    end
  end
  return 1
end
function redo_monster_overview_add(self, id)
  local monster_overview_form = nx_value("monster_overview_form")
  if not nx_is_valid(monster_overview_form) then
    nx_execute("form_task\\form_monster_list", "btn_show_all_click", nil)
    monster_overview_form = nx_value("monster_overview_form")
  end
  local monster_config = nx_value("monster_config")
  if monster_config:FindChild(id) then
    nx_msgbox("ID\214\216\184\180!")
    return 0
  end
  local monster_item = monster_config:CreateChild(id)
  monster_item.ID = id
  nx_execute("form_task\\form_monster_overview", "update_monster_overview", monster_overview_form)
  select_grid_by_key(monster_overview_form.grid_monster_list, id)
  return 1
end
function undo_monster_overview_delete(self, type)
  return redo_monster_overview_add(self, type)
end
function redo_monster_overview_delete(self, type)
  return undo_monster_overview_add(self, type)
end
function modify_text(name, key, value, controlbox_name)
  local text_form = nx_value("text_form")
  if not nx_is_valid(text_form) then
    return 0
  end
  local text_files = nx_value("text_files")
  if not nx_is_valid(text_files) then
    return 0
  end
  local child = nx_execute("form_task\\form_text", "get_node", text_files, key)
  if nx_is_valid(child) then
    child.value = value
    nx_execute("form_task\\form_text", "update_other_place", key, value)
    if controlbox_name == "ctrlbox_form_text" or controlbox_name == "ctrlbox_track_text" then
      text_form.rbtn_form_text.Checked = true
    else
      text_form.rbtn_dialog_text.Checked = true
    end
  end
  return 1
end
function show_or_close_text_form(name, is_show, mode)
  if is_show then
    local task_form = nx_value("task_form")
    if not nx_is_valid(task_form) then
      return 0
    end
    local text_form = nx_execute("form_task\\form_task_info", "show_text_form", task_form)
    if nx_is_valid(text_form) then
      if mode then
        text_form.rbtn_form_text.Checked = true
      else
        text_form.rbtn_dialog_text.Checked = true
      end
    end
  else
    local text_form = nx_value("text_form")
    if nx_is_valid(text_form) then
      text_form:Close()
    end
  end
  return 1
end
function modify_questions(name, question_id, prop, value)
  local text_form = nx_value("text_form")
  if not nx_is_valid(text_form) then
    return 0
  end
  local question_contend = nx_value("question_contend")
  if not nx_is_valid(question_contend) then
    return 0
  end
  local question = question_contend:GetChild(question_id)
  if nx_is_valid(question) then
    local child = question:GetChild(prop)
    if nx_is_valid(child) then
      child.item_name = value
      local control_box = text_form.dialog_text_form.ctrlbox_step_text
      nx_execute("form_task\\form_text", "load_process_dialog_text", text_form, control_box)
      text_form.rbtn_dialog_text.Checked = true
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
    end
  end
  return 1
end
function modify_process(self, task_id, row, order, type, id)
  local subtask_pro_info = nx_value("subtask_process_info")
  local subtask_info = subtask_pro_info:GetChild(task_id)
  local item = subtask_info:GetChildByIndex(row)
  item.order = order
  item.type = type
  item.subfunction = id
  local form = nx_value("task_form")
  if form.task_info.ID == task_id then
    nx_execute("form_task\\form_subtask_process", "update_subtask_process", form.subtask_process_form, form.task_info)
  end
  return 1
end
