require("form_task\\task_public_func")
require("form_task\\common")
require("form_task\\tool")
require("theme")
function main_form_init(self)
  self.Fixed = false
  self.LimitInScreen = false
  self.work_dir_form = nil
  self.log_form = nil
  self.props_edit_form = nil
  self.task_info_form = nil
  self.monster_list_form = nil
  self.tool_list_form = nil
  self.subtask_process_form = nil
  self.task_info = nil
  self.sect_node = nil
  self.msg_str = ""
  local min_max_close_com = nx_execute("form_task\\minimize_manager", "create_min_max_close_component", self, true, false, true, "Right")
  local min_btn = min_max_close_com.min_btn
  local max_btn = min_max_close_com.max_btn
  local close_btn = min_max_close_com.close_btn
  min_btn.name = "\200\206\206\241\177\224\188\173\198\247"
  self.min_btn = min_btn
  nx_bind_script(close_btn, nx_current())
  nx_callback(close_btn, "on_click", "btn_close_click")
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.lbl_info.Text = nx_widestr("\204\249\201\207\163\186\202\185\211\195\177\224\188\173\198\247\202\177\211\246\181\189\200\206\186\206\206\202\204\226\163\172\200\231\200\231\186\206\178\217\215\247\163\172\177\224\188\173\198\247\211\208BUG\181\200\163\172\191\201\210\212\180\242\191\170\189\231\195\230\201\207\181\196\202\185\211\195\203\181\195\247\163\172\178\233\209\175\187\242\204\225\206\202\163\172\206\202\204\226\187\225\190\161\191\236\180\240\184\180\181\196\163\161")
  self.btn_save.Enabled = false
  enable_form(self, false)
  nx_pause(0.1)
  gui.TextManager:Clear()
  gui.TextManager:LoadFiles("text\\ChineseS\\")
  local work_path = nx_function("ext_get_full_path", "..\\..\\..\\02_Server\\Cons\\Res")
  if not nx_path_exists(work_path) then
    work_path = nx_function("ext_get_full_path", "..\\..\\02_Server\\Res")
    if not nx_path_exists(work_path) then
      work_path = ""
    end
  end
  nx_set_value("work_path", work_path)
  self.rbtn_task_edit.Checked = true
  local text_undo_mgr = nx_create("UndoManager")
  nx_bind_script(text_undo_mgr, "form_task\\undo", "undo_init")
  nx_set_value("text_undo_mgr", text_undo_mgr)
  nx_execute("form_task\\form_log", "create_log_memory")
  enable_form(self, true)
  return 1
end
function main_form_close(self)
  local monster_overview_form = nx_value("monster_overview_form")
  if nx_is_valid(monster_overview_form) then
    monster_overview_form:Close()
  end
  local tool_overview_form = nx_value("tool_overview_form")
  if nx_is_valid(tool_overview_form) then
    tool_overview_form:Close()
  end
  local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
  if nx_is_valid(form_subtask_overview) then
    form_subtask_overview:Close()
  end
  local path_overview_form = nx_value("path_overview_form")
  if nx_is_valid(path_overview_form) then
    path_overview_form:Close()
  end
  local prize_form = nx_value("prize_form")
  if nx_is_valid(prize_form) then
    prize_form:Close()
  end
  local extra_prize_form = nx_value("extra_prize_form")
  if nx_is_valid(extra_prize_form) then
    extra_prize_form:Close()
  end
  local text_form = nx_value("text_form")
  if nx_is_valid(text_form) then
    text_form:Close()
  end
  free_memory()
  if self.msg_str ~= "" then
    nx_gen_event(self, self.msg_str, "cancel")
  end
  nx_destroy(self)
  local content_form = nx_value("content_form")
  if nx_is_valid(content_form) then
    content_form.content_tree.SelectNode = content_form.content_tree.RootNode
  end
  local text_undo_mgr = nx_value("text_undo_mgr")
  if nx_is_valid(text_undo_mgr) then
    nx_destroy(text_undo_mgr)
  end
  nx_execute("form_task\\form_log", "destroy_log_memory")
  return 1
end
function open_or_close_task_form()
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    nx_execute("form_task\\minimize_manager", "delete", task_form)
    btn_close_click(task_form.min_max_close_component.close_btn)
    return 1
  end
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_task.xml")
  nx_set_value("task_form", dialog)
  dialog:Show()
  return 1
end
function show_task_form(msg_str)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    local gui = nx_value("gui")
    task_form = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_task.xml")
    nx_set_value("task_form", task_form)
    task_form:Show()
  elseif not task_form.Visible then
    task_form.Visible = true
    nx_execute("form_task\\minimize_manager", "delete", task_form)
  end
  task_form.msg_str = msg_str
  return task_form
end
function relate_task(task_id)
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) and task_form.msg_str ~= "" then
    local ctrl = task_form.min_btn
    if nx_is_valid(ctrl) then
      nx_execute("form_task\\minimize_manager", "default_process_min_btn_method", ctrl)
    end
    nx_gen_event(task_form, task_form.msg_str, "ok", task_id)
  end
  return 1
end
function btn_close_click(self)
  local gui = nx_value("gui")
  local form = self.Parent.Parent
  if is_changed() then
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_yes_no_cancel.xml")
    dialog.info_label.Text = nx_widestr("\206\196\188\254\210\209\190\173\184\196\182\175\202\199\183\241\208\232\210\170\177\163\180\230\163\191")
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "yes_no_cancel_return")
    if "cancel" == res then
      return 1
    elseif "yes" == res then
      save_changes()
    end
  end
  form:Close()
  return 1
end
function ask_for_save()
  local gui = nx_value("gui")
  if is_changed() then
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_yes_no_cancel.xml")
    dialog.info_label.Text = nx_widestr("\206\196\188\254\210\209\190\173\184\196\182\175\202\199\183\241\208\232\210\170\177\163\180\230\163\191")
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "yes_no_cancel_return")
    if "yes" == res then
      save_changes()
      return true
    else
      return false
    end
  end
  return true
end
function rbtn_props_edit_checked(self)
  local form = self.Parent
  if self.Checked == true then
    if nx_is_valid(form.work_dir_form) then
      form.work_dir_form.Visible = false
    end
    if nx_is_valid(form.task_info_form) then
      form.task_info_form.Visible = false
    end
    if nx_is_valid(form.monster_list_form) then
      form.monster_list_form.Visible = false
    end
    if nx_is_valid(form.tool_list_form) then
      form.tool_list_form.Visible = false
    end
    if nx_is_valid(form.subtask_process_form) then
      form.subtask_process_form.Visible = false
    end
    if nx_is_valid(form.log_form) then
      form.log_form.Visible = false
    end
    show_props_edit_form(form)
  elseif nx_is_valid(form.props_edit_form) then
    form.props_edit_form.Visible = false
  end
end
function rbtn_task_edit_checked_changed(self)
  local form = self.Parent
  if self.Checked == true then
    show_work_dir_form(form)
    show_log_form(form)
    show_task_info_form(form)
    show_monster_list_form(form)
    show_tool_list_form(form)
    show_subtask_process_form(form)
  else
    if nx_is_valid(form.work_dir_form) then
      form.work_dir_form.Visible = false
    end
    if nx_is_valid(form.task_info_form) then
      form.task_info_form.Visible = false
    end
    if nx_is_valid(form.monster_list_form) then
      form.monster_list_form.Visible = false
    end
    if nx_is_valid(form.tool_list_form) then
      form.tool_list_form.Visible = false
    end
    if nx_is_valid(form.subtask_process_form) then
      form.subtask_process_form.Visible = false
    end
    if nx_is_valid(form.log_form) then
      form.log_form.Visible = false
    end
  end
  return 1
end
function show_props_edit_form(form)
  local gui = nx_value("gui")
  if nx_is_valid(form.props_edit_form) then
    form.props_edit_form.Visible = true
  else
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_props_edit.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 10
      dialog.Top = 52
      form.props_edit_form = dialog
    end
  end
end
function show_work_dir_form(form)
  local gui = nx_value("gui")
  if nx_is_valid(form.work_dir_form) then
    form.work_dir_form.Visible = true
  else
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_work_dir.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 10
      dialog.Top = 22
      form.work_dir_form = dialog
    end
  end
  return 1
end
function show_log_form(form)
  local gui = nx_value("gui")
  if nx_is_valid(form.log_form) then
    form.log_form.Visible = true
  else
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_log.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 10
      dialog.Top = 430
      form.log_form = dialog
    end
  end
  return 1
end
function show_task_info_form(form)
  local gui = nx_value("gui")
  if nx_is_valid(form.task_info_form) then
    form.task_info_form.Visible = true
  else
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_task_info.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 184
      dialog.Top = 32
      form.task_info_form = dialog
    end
  end
  return 1
end
function show_monster_list_form(form)
  local gui = nx_value("gui")
  if nx_is_valid(form.monster_list_form) then
    form.monster_list_form.Visible = true
  else
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_monster_list.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 184
      dialog.Top = 430
      form.monster_list_form = dialog
    end
  end
  return 1
end
function show_tool_list_form(form)
  local gui = nx_value("gui")
  if nx_is_valid(form.tool_list_form) then
    form.tool_list_form.Visible = true
  else
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_tool_list.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 548
      dialog.Top = 430
      form.tool_list_form = dialog
    end
  end
  return 1
end
function show_subtask_process_form(form)
  local gui = nx_value("gui")
  if nx_is_valid(form.subtask_process_form) then
    form.subtask_process_form.Visible = true
  else
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_subtask_process.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 916
      dialog.Top = 15
      form.subtask_process_form = dialog
    end
  end
end
function get_child_by_id(task_id)
  if task_id == "" then
    return nil
  end
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    return nil
  end
  local task_item_list = task_config:GetChildList()
  for i = 1, table.getn(task_item_list) do
    local task_item = task_item_list[i]:GetChild(task_id)
    if nx_is_valid(task_item) then
      return task_item
    end
  end
  return nil
end
function get_monster_item_by_id(monster_id)
  local monster_config = nx_value("monster_config")
  if nx_is_valid(monster_config) then
    local monster_item = monster_config:GetChild(monster_id)
    if nx_is_valid(monster_item) then
      return monster_item
    end
  end
  return nil
end
function get_tool_item_by_id(tool_id)
  local tool_config = nx_value("tool_config")
  if nx_is_valid(tool_config) then
    local tool_item = tool_config:GetChild(tool_id)
    if nx_is_valid(tool_item) then
      return tool_item
    end
  end
  return nil
end
function get_path_item_by_id(path_id)
  local path_config = nx_value("path_config")
  if nx_is_valid(path_config) then
    local path_item = path_config:GetChild(path_id)
    if nx_is_valid(path_item) then
      return path_item
    end
  end
  return nil
end
function set_change(object, type)
  local form = nx_value("task_form")
  if nx_is_valid(form) then
    form.btn_save.Enabled = true
    local changes_list = nx_value("changes_list")
    if not nx_is_valid(changes_list) then
      changes_list = nx_create("ArrayList", "changes_list")
      nx_set_value("changes_list", changes_list)
    end
    local item = changes_list:GetChild(type)
    if not nx_is_valid(item) then
      item = changes_list:CreateChild(type)
    end
    local child
    if "object" == nx_type(object) then
      child = item:GetChild(object.Name)
      if not nx_is_valid(child) then
        child = item:CreateChild(object.Name)
      end
      child.file_name = nx_custom(object, "file_name")
    else
      child = item:CreateChild("")
    end
    child.info = object
  end
  return 1
end
function is_changed()
  local form = nx_value("task_form")
  if nx_is_valid(form) then
    return form.btn_save.Enabled
  end
  return false
end
function set_unchanged()
  local changes_list = nx_value("changes_list")
  if nx_is_valid(changes_list) then
    changes_list:ClearChild()
  end
  local form = nx_value("task_form")
  if nx_is_valid(form) then
    form.btn_save.Enabled = false
  end
  return 1
end
function free_memory()
  local tasktype_config = nx_value("tasktype_config")
  if nx_is_valid(tasktype_config) then
    nx_destroy(tasktype_config)
  end
  local task_config = nx_value("task_config")
  if nx_is_valid(task_config) then
    nx_destroy(task_config)
  end
  local monster_config = nx_value("monster_config")
  if nx_is_valid(monster_config) then
    nx_destroy(monster_config)
  end
  local monster_title_info = nx_value("monster_title_info")
  if nx_is_valid(monster_title_info) then
    nx_destroy(monster_title_info)
  end
  local tool_config = nx_value("tool_config")
  if nx_is_valid(tool_config) then
    nx_destroy(tool_config)
  end
  local tool_title_info = nx_value("tool_title_info")
  if nx_is_valid(tool_title_info) then
    nx_destroy(tool_title_info)
  end
  local prize_info = nx_value("prize_info")
  if nx_is_valid(prize_info) then
    nx_destroy(prize_info)
  end
  local prize_title_info = nx_value("prize_title_info")
  if nx_is_valid(prize_title_info) then
    nx_destroy(prize_title_info)
  end
  local extra_prize_info = nx_value("extra_prize_info")
  if nx_is_valid(extra_prize_info) then
    nx_destroy(extra_prize_info)
  end
  local extra_prize_title_info = nx_value("extra_prize_title_info")
  if nx_is_valid(extra_prize_title_info) then
    nx_destroy(extra_prize_title_info)
  end
  local changes_list = nx_value("changes_list")
  if nx_is_valid(changes_list) then
    nx_destroy(changes_list)
  end
  local changes_list_subtask = nx_value("changes_list_subtask")
  if nx_is_valid(changes_list_subtask) then
    nx_destroy(changes_list_subtask)
  end
  local subtask_info = nx_value("subtask_info")
  if nx_is_valid(subtask_info) then
    nx_destroy(subtask_info)
  end
  local subtask_process_info = nx_value("subtask_process_info")
  if nx_is_valid(subtask_process_info) then
    nx_destroy(subtask_process_info)
  end
  local subtask_title_info = nx_value("subtask_title_info")
  if nx_is_valid(subtask_title_info) then
    nx_destroy(subtask_title_info)
  end
  local task_seperate = nx_value("task_seperate")
  if nx_is_valid(task_seperate) then
    nx_destroy(task_seperate)
  end
  local question_contend = nx_value("question_contend")
  if nx_is_valid(question_contend) then
    nx_destroy(question_contend)
  end
  local text_files = nx_value("text_files")
  if nx_is_valid(text_files) then
    nx_destroy(text_files)
  end
  local text_changes_list = nx_value("text_changes_list")
  if nx_is_valid(text_changes_list) then
    nx_destroy(text_changes_list)
  end
  local default_params_setting = nx_value("default_params_setting")
  if nx_is_valid(default_params_setting) then
    nx_destroy(default_params_setting)
  end
  return 1
end
function create_control(self, row, col)
  local gui = nx_value("gui")
  if col == 2 then
    local ctrl = CREATE_CONTROL("Edit")
    ctrl.Width = self:GetColWidth(col)
    ctrl.Text = self:GetGridText(row, col)
    ctrl.BackColor = EDIT_COLOR
    nx_bind_script(ctrl, nx_current())
    nx_callback(ctrl, "on_enter", "edit_lost_capture")
    nx_callback(ctrl, "on_lost_focus", "edit_lost_capture")
    self:SetGridControl(row, col, ctrl)
    gui.Focused = ctrl
    self.cur_select_row = row
    self.cur_select_col = col
  end
  return 1
end
function edit_lost_capture(self)
  local gui = nx_value("gui")
  local form = self.Parent.Parent.Parent
  local grid = self.Parent
  local cur_select_row = grid.cur_select_row
  local cur_select_col = grid.cur_select_col
  local old = grid:GetGridControl(cur_select_row, cur_select_col)
  if nx_is_valid(old) then
    local name = nx_string(grid:GetGridText(cur_select_row, 0))
    local new_value = nx_string(old.Text)
    if grid.Name == "grid_main_info" or grid.Name == "grid_more_info" then
      local task_info = form.task_info
      if nx_is_valid(task_info) then
        local old_value = nx_custom(task_info, name)
        grid:ClearGridControl(cur_select_row, cur_select_col)
        if new_value ~= old_value then
          if name == "RefreshMonster" then
            local ret = ask_form_create_new_item("RefreshMonster", new_value)
            if not ret then
              return 0
            end
          elseif name == "TaskItemList" then
            local ret = ask_form_create_new_item("TaskItem", new_value)
            if not ret then
              return 0
            end
          end
          nx_set_custom(task_info, name, new_value)
          grid:SetGridText(cur_select_row, cur_select_col, nx_widestr(new_value))
          if name == "RefreshMonster" then
            nx_execute("form_task\\form_monster_list", "update_monster_list", form.monster_list_form, form.task_info)
          end
          if name == "TaskItemList" then
            nx_execute("form_task\\form_tool_list", "update_tool_list", form.tool_list_form, form.task_info)
          end
          set_change(task_info, TASK)
          set_modify_task_info("modify_task_info", task_info.ID, name, old_value, new_value)
        end
      end
    elseif grid.Name == "grid_monster_list" then
      local monster_id = nx_string(grid.ID)
      local monster_item = get_monster_item_by_id(monster_id)
      if nx_is_valid(monster_item) then
        local old_value = nx_custom(monster_item, name)
        nx_set_custom(monster_item, name, new_value)
        grid:SetGridText(cur_select_row, cur_select_col, nx_widestr(new_value))
        grid:ClearGridControl(cur_select_row, cur_select_col)
        if new_value ~= old_value then
          local monster_overview_form = nx_value("monster_overview_form")
          if nx_is_valid(monster_overview_form) then
            nx_execute("form_task\\form_monster_overview", "update_monster_overview", monster_overview_form)
          end
          set_change(monster_item, MONSTER)
          set_modify_monster_info(grid.Name, monster_id, name, old_value, new_value)
        end
      end
    elseif grid.Name == "grid_tool_list" then
      local tool_id = nx_string(grid.ID)
      local tool_item = get_tool_item_by_id(tool_id)
      if nx_is_valid(tool_item) then
        local old_value = nx_custom(tool_item, name)
        nx_set_custom(tool_item, name, new_value)
        grid:SetGridText(cur_select_row, cur_select_col, nx_widestr(new_value))
        grid:ClearGridControl(cur_select_row, cur_select_col)
        local prop = nx_string(grid:GetGridText(cur_select_row, 0))
        if "ItemId" == prop then
          local photo = nx_execute("form_task\\form_tool_list", "get_picture_by_id", new_value)
          grid.picture.Image = photo
        end
        if new_value ~= old_value then
          local tool_overview_form = nx_value("tool_overview_form")
          if nx_is_valid(tool_overview_form) then
            nx_execute("form_task\\form_tool_overview", "update_tool_overview", tool_overview_form)
          end
          set_change(tool_item, TOOL)
          set_modify_tool_info(grid.Name, tool_id, name, old_value, new_value)
        end
      end
    end
  end
  return 1
end
function btn_save_click(self)
  save_changes()
  return 1
end
function save_changes()
  local b_success = true
  if 0 == nx_execute("form_task\\form_task_info", "save_task_info") then
    b_success = false
  end
  if 0 == nx_execute("form_task\\form_subtask_process", "save_subfunction_info") then
    b_success = false
  end
  if 0 == nx_execute("form_task\\form_prize_overview", "save_prize_info") then
    b_success = false
  end
  if 0 == nx_execute("form_task\\form_prize_overview", "save_extra_prize_info") then
    b_success = false
  end
  if 0 == nx_execute("form_task\\form_monster_overview", "save_monster_info") then
    b_success = false
  end
  if 0 == nx_execute("form_task\\form_tool_overview", "save_tool_info") then
    b_success = false
  end
  if 0 == nx_execute("form_task\\form_subtask_overview", "save_btn_click") then
    b_success = false
  end
  if 0 == nx_execute("form_task\\form_text", "save_text_form") then
    b_success = false
  end
  if 0 == nx_execute("form_task\\form_path_overview", "save_path_info") then
    b_success = false
  end
  local form = nx_value("task_form")
  if nx_is_valid(form) and form.btn_save.Enabled then
    form.btn_save.Enabled = not b_success
  end
  return 1
end
function get_seperate_item(sect_name, prop)
  local task_seperate = nx_value("task_seperate")
  if nx_is_valid(task_seperate) then
    local sect = task_seperate:GetChild(sect_name)
    if nx_is_valid(sect) then
      local item = sect:GetChild(prop)
      return item
    end
  end
  return nil
end
function btn_change_click(self)
  nx_execute("form_task\\form_files_transformer", "open_files_transformer_form")
end
function is_text_in_range(data, sect_node)
  return true
end
function is_in_range(data, rules)
  if rules:GetChildCount() <= 0 then
    return true
  end
  local child = rules:GetChild("ID")
  if nx_is_valid(child) then
    if is_num_in_range(data, child.rule) then
      return true
    else
      return false, " \177\216\208\235\212\218" .. child.rule .. "\214\174\188\228"
    end
  end
  local child = rules:GetChild("CID")
  if nx_is_valid(child) then
    local str_list = nx_function("ext_split_string", data, "-")
    if table.getn(str_list) == 2 then
      if 0 >= nx_number(str_list[1]) or 0 >= nx_number(str_list[2]) then
        return false, " \177\216\208\235\202\199Num-Num\184\241\202\189"
      elseif is_num_in_range(nx_number(str_list[2]), child.rule) then
        return true
      else
        return false, " \211\210\178\224\202\253\215\214\177\216\208\235\212\218" .. child.rule .. "\214\174\188\228"
      end
    else
      return false, " \177\216\208\235\202\199Num-Num\184\241\202\189"
    end
  end
  local id_type, position = get_id_type(get_string_before_number(data))
  if id_type ~= nil then
    local child = rules:GetChild(id_type)
    if nx_is_valid(child) then
      if is_num_in_range(get_compare_number(data, position), child.rule) then
        return true
      elseif position == "left" then
        return false, " \215\243\178\224\202\253\215\214\177\216\208\235\212\218" .. child.rule .. "\214\174\188\228"
      else
        return false, " \211\210\178\224\202\253\215\214\177\216\208\235\212\218" .. child.rule .. "\214\174\188\228"
      end
    end
  end
  return false, " \206\222\208\167\199\176\215\186"
end
function is_num_in_range(num, range)
  if "" == num then
    return false
  end
  if nil == range then
    return false
  end
  if "*" == range then
    return true
  end
  local str_list = nx_function("ext_split_string", range, "-")
  if table.getn(str_list) == 2 and nx_number(str_list[1]) <= nx_number(num) and nx_number(num) <= nx_number(str_list[2]) then
    return true
  end
  return false
end
function get_compare_number(str, position)
  local begin_index = 0
  local end_index = 0
  local len = string.len(str)
  if position == "left" then
    for i = 1, len do
      local ch = string.sub(str, i, i)
      if "0" <= ch and ch <= "9" then
        if begin_index == 0 then
          begin_index = i
          end_index = i
        else
          end_index = i
        end
      elseif end_index ~= 0 then
        break
      end
    end
  elseif position == "right" then
    for i = len, 1, -1 do
      local ch = string.sub(str, i, i)
      if "0" <= ch and ch <= "9" then
        if end_index == 0 then
          end_index = i
          begin_index = i
        else
          begin_index = i
        end
      elseif begin_index ~= 0 then
        break
      end
    end
  end
  if begin_index ~= 0 and end_index ~= 0 then
    return string.sub(str, begin_index, end_index)
  end
  return ""
end
function get_id_type(data)
  local work_path = nx_value("work_path")
  local form = nx_value("files_transformer_form")
  local pre_config = nx_value("pre_config")
  if not nx_is_valid(pre_config) then
    pre_config = nx_create("ArrayList", "pre_config")
    nx_set_value("pre_config", pre_config)
    local textgrid = nx_create("TextGrid")
    textgrid.FileName = work_path .. "ini\\Task\\pre_file.txt"
    if textgrid:LoadFromFile(2) then
      for k = 0, textgrid.RowCount - 1 do
        local pre = textgrid:GetValueString(nx_int(k), "pre")
        if pre ~= "" then
          local child = pre_config:CreateChild(pre)
          child.prop = textgrid:GetValueString(nx_int(k), "prop")
          child.position = textgrid:GetValueString(nx_int(k), "position")
          child.filename = textgrid:GetValueString(nx_int(k), "filename")
        end
      end
    end
    nx_destroy(textgrid)
  end
  local child = pre_config:GetChild(data)
  if nx_is_valid(child) then
    return child.prop, child.position, child.filename
  end
  return nil, nil, nil
end
function get_string_before_number(str)
  local len = string.len(str)
  for i = 1, len do
    local ch = string.sub(str, i, i)
    if "0" <= ch and ch <= "9" then
      return string.sub(str, 1, i - 1)
    end
  end
  return str
end
function get_used_task_id(prop, id)
  local task_id = ""
  local task_config = nx_value("task_config")
  if nx_is_valid(task_config) then
    local task_item_list = task_config:GetChildList()
    for i = 1, table.getn(task_item_list) do
      local task_item = task_item_list[i]
      if nx_is_valid(task_item) then
        local task_child_list = task_item:GetChildList()
        for j = 1, table.getn(task_child_list) do
          local task_child = task_child_list[j]
          local value = nx_custom(task_child, prop)
          if nil ~= value then
            local id_list = nx_function("ext_split_string", value, SPLIT_CHAR)
            local is_exist = false
            for k = 1, table.getn(id_list) do
              if id_list[k] == id then
                is_exist = true
              end
            end
            if is_exist then
              if task_id == "" then
                task_id = task_child.Name
              else
                task_id = task_id .. ";" .. task_child.Name
              end
            end
          end
        end
      end
    end
  end
  return task_id
end
function log_btn_click(self)
  local log_form = nx_value("log_form")
  if nx_is_valid(log_form) then
    log_form:Show()
    log_form.Parent:ToFront(log_form)
    return 0
  end
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_log.xml")
  dialog:Show()
  nx_set_value("log_form", dialog)
  return 1
end
function ask_form_create_new_item(type, value)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return false
  end
  if not nx_is_valid(task_form.sect_node) then
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    return false
  end
  if nil ~= value and "" ~= value then
    local str_list = nx_function("ext_split_string", value, SPLIT_CHAR)
    for i = 1, table.getn(str_list) do
      local item
      if type == "RefreshMonster" then
        item = get_monster_item_by_id(str_list[i])
      elseif type == "TaskItem" then
        item = get_tool_item_by_id(str_list[i])
      elseif type == "ConvoyPoint" then
        item = get_path_item_by_id(str_list[i])
      end
      if not nx_is_valid(item) then
        local message
        if type == "RefreshMonster" then
          message = "\202\199\183\241\208\194\189\168\203\162\185\214ID\163\186" .. str_list[i]
        elseif type == "TaskItem" then
          message = "\202\199\183\241\208\194\189\168\183\162\183\197\181\192\190\223ID\163\186" .. str_list[i]
        elseif type == "ConvoyPoint" then
          message = "\202\199\183\241\208\194\189\168\187\164\203\205\194\183\190\182ID\163\186" .. str_list[i] .. "\163\172\178\162\199\210\207\181\205\179\187\225\196\172\200\207\208\194\189\168\210\187\184\246\181\227"
        end
        local res = show_confirm_box(message)
        if res then
          local child = task_form.sect_node:GetChild(type)
          if nx_is_valid(child) then
            local result, error = is_in_range(str_list[i], child)
            if not result then
              nx_msgbox("ID " .. error)
              return false
            end
          else
            nx_msgbox("\206\180\197\228\214\195" .. type .. "\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
            return false
          end
          if type == "RefreshMonster" then
            nx_execute("form_task\\form_monster_list", "create_new_monster_item", str_list[i])
          elseif type == "TaskItem" then
            nx_execute("form_task\\form_tool_list", "create_new_tool_item", str_list[i])
          elseif type == "ConvoyPoint" then
            nx_execute("form_task\\form_path_overview", "create_new_path_info", str_list[i])
            nx_execute("form_task\\form_path_overview", "show_path_overview_form", str_list[i])
          end
        else
          return false
        end
      end
    end
  end
  return true
end
function ask_form_delete_old_item(type, value)
  if nil ~= value and "" ~= value then
    local message
    if type == "ConvoyPoint" then
      message = "\202\199\183\241\201\190\179\253\187\164\203\205\194\183\190\182ID\163\186" .. value
    end
    local res = show_confirm_box(message)
    if res then
      if type == "ConvoyPoint" then
        nx_execute("form_task\\form_path_overview", "delete_path_item", value)
      end
    else
      return false
    end
  end
  return true
end
function show_confirm_box(title)
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_yes_no_cancel.xml")
  dialog.info_label.Text = nx_widestr(title)
  dialog.cancel_btn.Visible = false
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "yes_no_cancel_return")
  if res == "yes" then
    return true
  end
  return false
end
function btn_general_testcase_click(self)
  general_by_task_type_ini()
  return true
end
function btn_general_testcase2_click(self)
  return general_npc_text()
end
local get_file_path = function(item, prop)
  local child_item = item:GetChild(prop)
  if not nx_is_valid(child_item) then
    return ""
  end
  return child_item.file_name
end
function general_npc_text()
  local tasktype_config = nx_value("tasktype_config")
  if not nx_is_valid(tasktype_config) then
    return false
  end
  local work_path = nx_value("work_path")
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = work_path .. "ini\\Task\\Task\\test_npc.txt"
  if not textgrid:LoadFromFile(2) then
    nx_msgbox("\180\242\191\170\206\196\188\254(" .. textgrid.FileName .. ")\202\167\176\220")
    nx_destroy(textgrid)
    return false
  end
  textgrid:RemoveAllCell()
  textgrid:AddRow("\200\206\206\241\177\224\186\197", "\189\211\200\206\206\241npc", "npc\195\251\179\198", "\189\187\200\206\206\241npc", "npc\195\251\179\198", "\215\211\200\206\206\241npc", "npc\195\251\179\198")
  local child_list = tasktype_config:GetChildList()
  local task_textgrid = nx_create("TextGrid")
  local subfunction_textgrid = nx_create("TextGrid")
  local huntlist_textgrid = nx_create("TextGrid")
  local collectlist_textgrid = nx_create("TextGrid")
  local interactive_textgrid = nx_create("TextGrid")
  local storytask_textgrid = nx_create("TextGrid")
  local question_textgrid = nx_create("TextGrid")
  local useitemlist_textgrid = nx_create("TextGrid")
  local convoy_textgrid = nx_create("TextGrid")
  local gui = nx_value("gui")
  for i = 1, table.getn(child_list) do
    local task_file = get_file_path(child_list[i], "Task")
    local subfunction_file = get_file_path(child_list[i], "SubFunction")
    local huntlist_file = get_file_path(child_list[i], "HuntList")
    local collectlist_file = get_file_path(child_list[i], "CollectList")
    local interactivelist_file = get_file_path(child_list[i], "InteractiveList")
    local storytask_file = get_file_path(child_list[i], "StoryTaskList")
    local question_file = get_file_path(child_list[i], "Question")
    local useitemlist_file = get_file_path(child_list[i], "UseItemList")
    local convoy_file = get_file_path(child_list[i], "Convoy")
    task_textgrid:Dispose()
    subfunction_textgrid:Dispose()
    huntlist_textgrid:Dispose()
    collectlist_textgrid:Dispose()
    interactive_textgrid:Dispose()
    storytask_textgrid:Dispose()
    question_textgrid:Dispose()
    convoy_textgrid:Dispose()
    task_textgrid.FileName = work_path .. task_file
    subfunction_textgrid.FileName = work_path .. subfunction_file
    huntlist_textgrid.FileName = work_path .. huntlist_file
    collectlist_textgrid.FileName = work_path .. collectlist_file
    interactive_textgrid.FileName = work_path .. interactivelist_file
    storytask_textgrid.FileName = work_path .. storytask_file
    question_textgrid.FileName = work_path .. question_file
    convoy_textgrid.FileName = work_path .. convoy_file
    subfunction_textgrid:LoadFromFile(2)
    huntlist_textgrid:LoadFromFile(2)
    collectlist_textgrid:LoadFromFile(2)
    interactive_textgrid:LoadFromFile(2)
    storytask_textgrid:LoadFromFile(2)
    question_textgrid:LoadFromFile(2)
    convoy_textgrid:LoadFromFile(2)
    if task_textgrid:LoadFromFile(2) then
      for j = 0, task_textgrid.RowCount - 1 do
        local id = task_textgrid:GetValueString(nx_int(j), "ID")
        local acceptnpc = task_textgrid:GetValueString(nx_int(j), "AcceptNpc")
        local submitnpc = task_textgrid:GetValueString(nx_int(j), "SubmitNpc")
        local row = textgrid:AddRow(id)
        textgrid:SetValueString(nx_int(row), "AcceptNpc", acceptnpc)
        textgrid:SetValueString(nx_int(row), "AcceptNpcName", nx_string(gui.TextManager:GetText(nx_string(acceptnpc))))
        textgrid:SetValueString(nx_int(row), "SubmitNpc", submitnpc)
        textgrid:SetValueString(nx_int(row), "SubmitNpcName", nx_string(gui.TextManager:GetText(nx_string(submitnpc))))
        local npc_list = {}
        local flag = {}
        for k = 0, subfunction_textgrid.RowCount - 1 do
          local sub_id = subfunction_textgrid:GetValueString(nx_int(k), "ID")
          if id == sub_id then
            local type = subfunction_textgrid:GetValueString(nx_int(k), "Type")
            local typeid = subfunction_textgrid:GetValueString(nx_int(k), "TypeID")
            local tmp_textgrid, col_list
            if type == "hunter" then
              tmp_textgrid = huntlist_textgrid
              col_list = {
                "NpcId",
                "RefreshMonster"
              }
            elseif type == "collect" then
              tmp_textgrid = collectlist_textgrid
              col_list = {
                "NpcId",
                "RefreshMonster"
              }
            elseif type == "interact" then
              tmp_textgrid = interactive_textgrid
              col_list = {"NpcId"}
            elseif type == "story" then
              tmp_textgrid = storytask_textgrid
              col_list = {"NpcId"}
            elseif type == "question" then
              tmp_textgrid = question_textgrid
              col_list = {
                "QuestionNpc"
              }
            elseif type == "convoy" then
              tmp_textgrid = convoy_textgrid
              col_list = {"NpcId", "HideNpcID"}
            end
            if tmp_textgrid ~= nil then
              local col_count = table.getn(col_list)
              for m = 0, tmp_textgrid.RowCount - 1 do
                if typeid == tmp_textgrid:GetValueString(nx_int(m), "ID") then
                  for n = 1, col_count do
                    local val = tmp_textgrid:GetValueString(nx_int(m), col_list[n])
                    if val ~= "" then
                      local val_list = nx_function("ext_split_string", val, ";")
                      local val_count = table.getn(val_list)
                      for k = 1, val_count do
                        if flag[val_list[k]] == nil then
                          table.insert(npc_list, val_list[k])
                          flag[val_list[k]] = 1
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
        local npc_count = table.getn(npc_list)
        if 0 < npc_count then
          local npc_id = npc_list[1]
          local npc_name = get_npc_name(npc_list[1])
          for k = 2, npc_count do
            npc_id = npc_id .. ";" .. npc_list[k]
            npc_name = npc_name .. ";" .. get_npc_name(npc_list[k])
          end
          textgrid:SetValueString(nx_int(row), "NpcId", npc_id)
          textgrid:SetValueString(nx_int(row), "NpcName", npc_name)
        end
      end
    end
  end
  nx_destroy(task_textgrid)
  nx_destroy(subfunction_textgrid)
  nx_destroy(huntlist_textgrid)
  nx_destroy(collectlist_textgrid)
  nx_destroy(interactive_textgrid)
  nx_destroy(storytask_textgrid)
  nx_destroy(question_textgrid)
  nx_destroy(convoy_textgrid)
  if not textgrid:SaveToFile() then
    nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
  end
  nx_destroy(textgrid)
  return true
end
function general_by_task_type_ini()
  local tasktype_config = nx_value("tasktype_config")
  if not nx_is_valid(tasktype_config) then
    return false
  end
  local work_path = nx_value("work_path")
  local target_file = work_path .. TEST_CASE_TXT
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = target_file
  if not textgrid:LoadFromFile(2) then
    nx_msgbox("\180\242\191\170\206\196\188\254(" .. textgrid.FileName .. ")\202\167\176\220")
    nx_destroy(textgrid)
    return false
  end
  textgrid:RemoveAllCell()
  textgrid:AddRow("\200\206\206\241\177\224\186\197", "\200\206\206\241\195\251\179\198", "\189\211\200\206\206\241npc", "npc\195\251\179\198", "\189\187\200\206\206\241npc", "npc\195\251\179\198", "\200\206\206\241\203\249\212\218\179\161\190\176", "\200\206\206\241\195\232\202\246", "\200\206\206\241\196\191\177\234", "\200\206\206\241\205\234\179\201", "\191\201\179\208\189\211\200\206\206\241\178\203\181\165\163\168\215\214\202\253\178\187\179\172\185\25328\163\172\176\252\192\168\177\234\181\227\163\169", "\210\209\205\234\179\201\200\206\206\241\178\203\181\165\163\168\215\214\202\253\178\187\179\172\185\25328\163\172\176\252\192\168\177\234\181\227\163\169", "\200\206\206\241\195\232\202\246\182\212\187\176\209\161\207\238\163\168\215\214\202\253\178\187\179\172\185\25328\163\172\176\252\192\168\177\234\181\227\163\169")
  local child_list = tasktype_config:GetChildList()
  for i = 1, table.getn(child_list) do
    local item = child_list[i]:GetChild("Task")
    if nx_is_valid(item) then
      local file_name = nx_custom(item, "file_name")
      if nil ~= file_name then
        local task_textgrid = nx_create("TextGrid")
        task_textgrid.FileName = work_path .. file_name
        if not task_textgrid:LoadFromFile(2) then
          nx_msgbox("\180\242\191\170\206\196\188\254(" .. task_textgrid.FileName .. ")\202\167\176\220")
        else
          local row = textgrid:AddRow(child_list[i].Name .. "-------------------------------------------------")
          local searchid = ""
          for j = 0, task_textgrid.RowCount - 1 do
            searchid = geberal_each_task_testcase(textgrid, task_textgrid, j, searchid)
          end
        end
        nx_destroy(task_textgrid)
      end
    end
  end
  for i = 1, table.getn(child_list) do
    local item = child_list[i]:GetChild("Prize")
    if nx_is_valid(item) then
      local file_name = nx_custom(item, "file_name")
      if nil ~= file_name then
        local prize_textgrid = nx_create("TextGrid")
        prize_textgrid.FileName = work_path .. file_name
        if not prize_textgrid:LoadFromFile(2) then
          nx_msgbox("\180\242\191\170\206\196\188\254(" .. prize_textgrid.FileName .. ")\202\167\176\220")
        else
          for j = 0, prize_textgrid.RowCount - 1 do
            geberal_each_prize_testcase(textgrid, prize_textgrid, j)
          end
        end
        nx_destroy(prize_textgrid)
      end
    end
  end
  if not textgrid:SaveToFile() then
    nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
  end
  nx_destroy(textgrid)
  return true
end
function general_without_task_type_ini()
  local work_path = nx_value("work_path")
  local task_file_dir = work_path .. "ini\\Task\\Task\\Task\\"
  local target_file = work_path .. TEST_CASE_TXT
  local fs = nx_create("FileSearch")
  if not nx_is_valid(fs) then
    return false
  end
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = target_file
  if not textgrid:LoadFromFile(2) then
    nx_msgbox("\180\242\191\170\206\196\188\254(" .. textgrid.FileName .. ")\202\167\176\220")
  else
    textgrid:RemoveAllCell()
    fs:SearchFile(task_file_dir, "*.txt")
    local file_table = fs:GetFileList()
    for i = 1, table.getn(file_table) do
      if nil ~= string.find(file_table[i], "task_") then
        local task_textgrid = nx_create("TextGrid")
        task_textgrid.FileName = task_file_dir .. file_table[i]
        if not task_textgrid:LoadFromFile(2) then
          nx_msgbox("\180\242\191\170\206\196\188\254(" .. task_textgrid.FileName .. ")\202\167\176\220")
        else
          for j = 0, task_textgrid.RowCount - 1 do
            geberal_each_task_testcase(textgrid, task_textgrid, j)
          end
        end
        nx_destroy(task_textgrid)
      end
    end
    nx_destroy(fs)
    if not textgrid:SaveToFile() then
      nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
    end
  end
  nx_destroy(textgrid)
  return true
end
local add_extra_info = function(str)
  if str == "" then
    return str
  end
  local str_list = nx_function("ext_split_string", str, ";")
  local res = ""
  local gui = nx_value("gui")
  for i = 1, table.getn(str_list) do
    local desc = nx_string(gui.TextManager:GetText("desc_condition_" .. str_list[i]))
    res = res .. str_list[i] .. "=" .. desc .. ";"
  end
  return string.sub(res, 1, string.len(res) - 1)
end
function geberal_each_task_testcase(target_textgrid, task_textgrid, index, last_searchid)
  local gui = nx_value("gui")
  local id = task_textgrid:GetValueString(nx_int(index), "ID")
  if id == "" then
    return last_searchid
  end
  local searchid = task_textgrid:GetValueString(nx_int(index), "SearchID")
  if last_searchid ~= nil and searchid ~= last_searchid then
    local row = target_textgrid:AddRow("\181\218" .. string.sub(searchid, 4, 5) .. "\213\194 \181\218" .. string.sub(searchid, 6, 7) .. "\187\216---------------------------")
  end
  local title = task_textgrid:GetValueString(nx_int(index), "Title")
  local title_id = task_textgrid:GetValueString(nx_int(index), "TitleId")
  local acceptnpc = task_textgrid:GetValueString(nx_int(index), "AcceptNpc")
  local submitnpc = task_textgrid:GetValueString(nx_int(index), "SubmitNpc")
  local acceptsceneid = task_textgrid:GetValueString(nx_int(index), "AcceptSceneID")
  local acceptdialogid = task_textgrid:GetValueString(nx_int(index), "AcceptDialogId")
  local tasktargetid = task_textgrid:GetValueString(nx_int(index), "TaskTargetId")
  local completedialogid = task_textgrid:GetValueString(nx_int(index), "CompleteDialogId")
  local canacceptmenu = task_textgrid:GetValueString(nx_int(index), "CanAcceptMenu")
  local completemenu = task_textgrid:GetValueString(nx_int(index), "CompleteMenu")
  local line = task_textgrid:GetValueString(nx_int(index), "Line")
  local cangiveup = task_textgrid:GetValueString(nx_int(index), "CanGiveup")
  local sharetype = task_textgrid:GetValueString(nx_int(index), "ShareType")
  local repeattype = task_textgrid:GetValueString(nx_int(index), "RepeatType")
  local repeatperiod = task_textgrid:GetValueString(nx_int(index), "RepeatPeriod")
  local countdaylimit = task_textgrid:GetValueString(nx_int(index), "CountDayLimit")
  local acceptlimit = task_textgrid:GetValueString(nx_int(index), "AcceptLimit")
  local submitlimit = task_textgrid:GetValueString(nx_int(index), "SubmitLimit")
  local reputationlimit = task_textgrid:GetValueString(nx_int(index), "ReputationLimit")
  local context
  local str_list = nx_function("ext_split_string", nx_string(acceptdialogid), ";")
  if str_list[1] ~= nil then
    context = str_list[1]
  else
    context = ""
  end
  if str_list[2] ~= nil then
    menu = str_list[2]
  else
    menu = ""
  end
  acceptlimit = add_extra_info(nx_string(acceptlimit))
  submitlimit = add_extra_info(nx_string(submitlimit))
  local row = target_textgrid:AddRow(id)
  target_textgrid:SetValueString(nx_int(row), "Title", title)
  target_textgrid:SetValueString(nx_int(row), "TitleId", nx_string(gui.TextManager:GetText(nx_string(title_id))))
  target_textgrid:SetValueString(nx_int(row), "AcceptNpc", acceptnpc)
  target_textgrid:SetValueString(nx_int(row), "AcceptNpcName", nx_string(gui.TextManager:GetText(nx_string(acceptnpc))))
  target_textgrid:SetValueString(nx_int(row), "SubmitNpc", submitnpc)
  target_textgrid:SetValueString(nx_int(row), "SubmitNpcName", nx_string(gui.TextManager:GetText(nx_string(submitnpc))))
  target_textgrid:SetValueString(nx_int(row), "Scene", acceptsceneid)
  target_textgrid:SetValueString(nx_int(row), "context", nx_string(gui.TextManager:GetText(context)))
  target_textgrid:SetValueString(nx_int(row), "target", nx_string(gui.TextManager:GetText(nx_string(tasktargetid))))
  target_textgrid:SetValueString(nx_int(row), "complete", nx_string(gui.TextManager:GetText(nx_string(completedialogid))))
  target_textgrid:SetValueString(nx_int(row), "CanAcceptMenu", nx_string(gui.TextManager:GetText(nx_string(canacceptmenu))))
  target_textgrid:SetValueString(nx_int(row), "CompleteMenu", nx_string(gui.TextManager:GetText(nx_string(completemenu))))
  target_textgrid:SetValueString(nx_int(row), "menu", nx_string(gui.TextManager:GetText(menu)))
  target_textgrid:SetValueString(nx_int(row), "Line", nx_string(line))
  target_textgrid:SetValueString(nx_int(row), "CanGiveup", nx_string(cangiveup))
  target_textgrid:SetValueString(nx_int(row), "ShareType", nx_string(sharetype))
  target_textgrid:SetValueString(nx_int(row), "RepeatType", nx_string(repeattype))
  target_textgrid:SetValueString(nx_int(row), "RepeatPeriod", nx_string(repeatperiod))
  target_textgrid:SetValueString(nx_int(row), "CountDayLimit", nx_string(countdaylimit))
  target_textgrid:SetValueString(nx_int(row), "AcceptLimit", nx_string(acceptlimit))
  target_textgrid:SetValueString(nx_int(row), "SubmitLimit", nx_string(submitlimit))
  target_textgrid:SetValueString(nx_int(row), "ReputationLimit", nx_string(reputationlimit))
  return searchid
end
function geberal_each_prize_testcase(target_textgrid, task_textgrid, index)
  local gui = nx_value("gui")
  local id = task_textgrid:GetValueString(nx_int(index), "ID")
  local faculty = task_textgrid:GetValueString(nx_int(index), "Faculty")
  local capitaltype1 = task_textgrid:GetValueString(nx_int(index), "CapitalType1")
  local reputename1 = task_textgrid:GetValueString(nx_int(index), "ReputeName1")
  local reputecount1 = task_textgrid:GetValueString(nx_int(index), "ReputeCount1")
  local dropid = task_textgrid:GetValueString(nx_int(index), "DropID")
  local prizeitemtype = task_textgrid:GetValueString(nx_int(index), "PrizeItemType")
  local item1 = task_textgrid:GetValueString(nx_int(index), "Item1")
  local text1 = nx_string(gui.TextManager:GetText(nx_string(item1)))
  local num1 = task_textgrid:GetValueString(nx_int(index), "Num1")
  local item2 = task_textgrid:GetValueString(nx_int(index), "Item2")
  local text2 = nx_string(gui.TextManager:GetText(nx_string(item2)))
  local num2 = task_textgrid:GetValueString(nx_int(index), "Num2")
  local item3 = task_textgrid:GetValueString(nx_int(index), "Item3")
  local text3 = nx_string(gui.TextManager:GetText(nx_string(item3)))
  local num3 = task_textgrid:GetValueString(nx_int(index), "Num3")
  local item4 = task_textgrid:GetValueString(nx_int(index), "Item4")
  local text4 = nx_string(gui.TextManager:GetText(nx_string(item4)))
  local num4 = task_textgrid:GetValueString(nx_int(index), "Num4")
  local livegroove = task_textgrid:GetValueString(nx_int(index), "LiveGroove")
  local livegroovecount = task_textgrid:GetValueString(nx_int(index), "LiveGrooveCount")
  local addprize = task_textgrid:GetValueString(nx_int(index), "AddPrize")
  local isgive = task_textgrid:GetValueString(nx_int(index), "IsGive")
  if nx_string(isgive) == "1" and nx_string(addprize) ~= "" then
    local work_path = nx_value("work_path")
    local extra_textgrid = nx_create("TextGrid")
    extra_textgrid.FileName = work_path .. "ini\\Task\\Task\\Prize\\extraPrize.txt"
    if extra_textgrid:LoadFromFile(2) then
      faculty = faculty .. "/" .. extra_textgrid:GetValueString(nx_int(index), "Faculty")
      capitaltype1 = capitaltype1 .. "/" .. extra_textgrid:GetValueString(nx_int(index), "CapitalType1")
      reputename1 = reputename1 .. "/" .. extra_textgrid:GetValueString(nx_int(index), "ReputeName1")
      reputecount1 = reputecount1 .. "/" .. extra_textgrid:GetValueString(nx_int(index), "ReputeCount1")
      dropid = dropid .. "/" .. extra_textgrid:GetValueString(nx_int(index), "DropID")
      prizeitemtype = prizeitemtype .. "/" .. extra_textgrid:GetValueString(nx_int(index), "PrizeItemType")
      local extra_item1 = extra_textgrid:GetValueString(nx_int(index), "Item1")
      item1 = item1 .. "/" .. extra_item1
      text1 = text1 .. "/" .. nx_string(gui.TextManager:GetText(nx_string(extra_item1)))
      num1 = num1 .. "/" .. extra_textgrid:GetValueString(nx_int(index), "Num1")
      local extra_item2 = extra_textgrid:GetValueString(nx_int(index), "Item2")
      item2 = item2 .. "/" .. extra_item2
      text2 = text2 .. "/" .. nx_string(gui.TextManager:GetText(nx_string(extra_item2)))
      num2 = num2 .. "/" .. extra_textgrid:GetValueString(nx_int(index), "Num2")
      local extra_item3 = extra_textgrid:GetValueString(nx_int(index), "Item3")
      item3 = item3 .. "/" .. extra_item3
      text3 = text3 .. "/" .. nx_string(gui.TextManager:GetText(nx_string(extra_item3)))
      num3 = num3 .. "/" .. extra_textgrid:GetValueString(nx_int(index), "Num3")
      local extra_item4 = extra_textgrid:GetValueString(nx_int(index), "Item4")
      item4 = item4 .. "/" .. extra_item4
      text4 = text4 .. "/" .. nx_string(gui.TextManager:GetText(nx_string(extra_item4)))
      num4 = num4 .. "/" .. extra_textgrid:GetValueString(nx_int(index), "Num4")
      livegroove = livegroove .. "/" .. extra_textgrid:GetValueString(nx_int(index), "LiveGroove")
      livegroovecount = livegroovecount .. "/" .. extra_textgrid:GetValueString(nx_int(index), "LiveGrooveCount")
    end
    nx_destroy(extra_textgrid)
  end
  local row = -1
  for i = 0, target_textgrid.RowCount - 1 do
    local id_val = target_textgrid:GetValueString(nx_int(i), "ID")
    if id_val == id then
      row = i
      break
    end
  end
  if row ~= -1 then
    target_textgrid:SetValueString(nx_int(row), "Faculty", faculty)
    target_textgrid:SetValueString(nx_int(row), "CapitalType1", capitaltype1)
    target_textgrid:SetValueString(nx_int(row), "ReputeName1", reputename1)
    target_textgrid:SetValueString(nx_int(row), "ReputeCount1", reputecount1)
    target_textgrid:SetValueString(nx_int(row), "DropID", dropid)
    target_textgrid:SetValueString(nx_int(row), "PrizeItemType", prizeitemtype)
    target_textgrid:SetValueString(nx_int(row), "Item1", item1 .. "(" .. text1 .. ")")
    target_textgrid:SetValueString(nx_int(row), "Num1", num1)
    target_textgrid:SetValueString(nx_int(row), "Item2", item2 .. "(" .. text2 .. ")")
    target_textgrid:SetValueString(nx_int(row), "Num2", num2)
    target_textgrid:SetValueString(nx_int(row), "Item3", item3 .. "(" .. text3 .. ")")
    target_textgrid:SetValueString(nx_int(row), "Num3", num3)
    target_textgrid:SetValueString(nx_int(row), "Item4", item4 .. "(" .. text4 .. ")")
    target_textgrid:SetValueString(nx_int(row), "Num4", num4)
    target_textgrid:SetValueString(nx_int(row), "LiveGroove", liveGroove)
    target_textgrid:SetValueString(nx_int(row), "LiveGrooveCount", liveGrooveCount)
    target_textgrid:SetValueString(nx_int(row), "AddPrize", addprize)
    target_textgrid:SetValueString(nx_int(row), "IsGive", isgive)
  end
end
function btn_context_click(self)
  local gui = nx_value("gui")
  local read_me_form = nx_value("read_me_form")
  if not nx_is_valid(read_me_form) then
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_read_me.xml")
    dialog:ShowModal()
    nx_set_value("read_me_form", dialog)
  end
  return 1
end
function btn_modify_column_click(self)
  local gui = nx_value("gui")
  local work_path = nx_value("work_path")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_input.xml")
  dialog.lbl_2.Text = nx_widestr("\202\228\200\235\193\208\195\251")
  dialog.input_edit.OnlyDigit = false
  dialog.allow_empty = false
  dialog:ShowModal()
  local res, name = nx_wait_event(100000000, dialog, "form_input_return")
  if res == "ok" then
    local tasktype_config = nx_value("tasktype_config")
    if nx_is_valid(tasktype_config) then
      local child_list = tasktype_config:GetChildList()
      for i = 1, table.getn(child_list) do
        local item = child_list[i]:GetChild("Task")
        if nx_is_valid(item) then
          local file_name = nx_custom(item, "file_name")
          if nil ~= file_name then
            local textgrid = nx_create("TextGrid")
            textgrid.FileName = work_path .. file_name
            if not textgrid:LoadFromFile(2) then
              nx_msgbox("\182\193\200\161\206\196\188\254(" .. work_path .. file_name .. ")\202\167\176\220")
            end
            local index = textgrid:GetColIndex(name)
            if 0 <= index then
            else
              local pre_col_count = textgrid.ColCount
              textgrid:AddColumns(1)
              if not textgrid:SetColName(nx_int(pre_col_count), name) then
                nx_msgbox(textgrid.FileName .. " - \193\208\195\251\212\246\188\211\202\167\176\220")
              elseif not textgrid:SaveToFile() then
                nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
              end
            end
            nx_destroy(textgrid)
          end
        end
      end
    end
  end
  return 1
end
function btn_text_click(self)
  general_task_text()
  general_subfunction_text("HuntList")
  general_subfunction_text("CollectList")
  general_subfunction_text("Convoy")
  general_subfunction_text("InteractiveList")
  general_subfunction_text("UseItemList")
  general_subfunction_text("Question")
  general_subfunction_text("StoryTaskList")
  general_subfunction_text("questions")
  return 1
end
function general_task_text()
  local gui = nx_value("gui")
  local tasktype_config = nx_value("tasktype_config")
  if not nx_is_valid(tasktype_config) then
    return false
  end
  local work_path = nx_value("work_path")
  local target_file = work_path .. TASK_TEXT_TXT
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = target_file
  if not textgrid:LoadFromFile(2) then
    nx_msgbox("\180\242\191\170\206\196\188\254(" .. textgrid.FileName .. ")\202\167\176\220")
    nx_destroy(textgrid)
    return false
  end
  textgrid:RemoveAllCell()
  textgrid:AddRow("\200\206\206\241\195\251", "\200\206\206\241\195\251", "\200\206\206\241\195\232\202\246", "\200\206\206\241\195\232\202\246", "\200\206\206\241\196\191\177\234", "\200\206\206\241\196\191\177\234", "\206\222\200\206\206\241\204\225\202\190", "\206\222\200\206\206\241\204\225\202\190", "\206\222\178\189\214\232\206\196\177\190", "\206\222\178\189\214\232\206\196\177\190", "\189\211\202\220\182\212\187\176", "\189\211\202\220\182\212\187\176", "\189\211\202\220\206\196\177\190", "\189\211\202\220\206\196\177\190", "\205\234\179\201\182\212\187\176", "\205\234\179\201\182\212\187\176", "\205\234\179\201\206\196\177\190", "\205\234\179\201\206\196\177\190")
  local child_list = tasktype_config:GetChildList()
  for i = 1, table.getn(child_list) do
    local item = child_list[i]:GetChild("Task")
    if nx_is_valid(item) then
      local file_name = nx_custom(item, "file_name")
      if nil ~= file_name then
        local task_textgrid = nx_create("TextGrid")
        task_textgrid.FileName = work_path .. file_name
        if not task_textgrid:LoadFromFile(2) then
          nx_msgbox("\180\242\191\170\206\196\188\254(" .. task_textgrid.FileName .. ")\202\167\176\220")
        else
          for j = 0, task_textgrid.RowCount - 1 do
            local titleid = task_textgrid:GetValueString(nx_int(j), "TitleId")
            local contextid = task_textgrid:GetValueString(nx_int(j), "ContextId")
            local tasktargetid = task_textgrid:GetValueString(nx_int(j), "TaskTargetId")
            local linenextinfo = task_textgrid:GetValueString(nx_int(j), "LineNextInfo")
            local submitnpcex = task_textgrid:GetValueString(nx_int(j), "SubmitNpcEx")
            local acceptdialogid = task_textgrid:GetValueString(nx_int(j), "AcceptDialogId")
            local canacceptmenu = task_textgrid:GetValueString(nx_int(j), "CanAcceptMenu")
            local completedialogid = task_textgrid:GetValueString(nx_int(j), "CompleteDialogId")
            local completemenu = task_textgrid:GetValueString(nx_int(j), "CompleteMenu")
            local row = textgrid:AddRow(titleid)
            textgrid:SetValueString(nx_int(row), "CTitleId", nx_string(gui.TextManager:GetText(titleid)))
            textgrid:SetValueString(nx_int(row), "ContextId", contextid)
            textgrid:SetValueString(nx_int(row), "CContextId", nx_string(gui.TextManager:GetText(contextid)))
            textgrid:SetValueString(nx_int(row), "TaskTargetId", tasktargetid)
            textgrid:SetValueString(nx_int(row), "CTaskTargetId", nx_string(gui.TextManager:GetText(tasktargetid)))
            textgrid:SetValueString(nx_int(row), "LineNextInfo", linenextinfo)
            textgrid:SetValueString(nx_int(row), "CLineNextInfo", nx_string(gui.TextManager:GetText(linenextinfo)))
            textgrid:SetValueString(nx_int(row), "SubmitNpcEx", submitnpcex)
            textgrid:SetValueString(nx_int(row), "CSubmitNpcEx", nx_string(gui.TextManager:GetText(submitnpcex)))
            textgrid:SetValueString(nx_int(row), "AcceptDialogId", acceptdialogid)
            local str_list = util_split_string(acceptdialogid, ";")
            local value = ""
            for k = 1, table.getn(str_list) do
              if value == "" then
                value = nx_string(gui.TextManager:GetText(str_list[k]))
              else
                value = value .. "/" .. nx_string(gui.TextManager:GetText(str_list[k]))
              end
            end
            textgrid:SetValueString(nx_int(row), "CAcceptDialogId", value)
            textgrid:SetValueString(nx_int(row), "CanAcceptMenu", canacceptmenu)
            local str_list = util_split_string(canacceptmenu, ";")
            local value = ""
            for k = 1, table.getn(str_list) do
              if value == "" then
                value = nx_string(gui.TextManager:GetText(str_list[k]))
              else
                value = value .. "/" .. nx_string(gui.TextManager:GetText(str_list[k]))
              end
            end
            textgrid:SetValueString(nx_int(row), "CCanAcceptMenu", value)
            textgrid:SetValueString(nx_int(row), "CompleteDialogId", completedialogid)
            local str_list = util_split_string(completedialogid, ";")
            local value = ""
            for k = 1, table.getn(str_list) do
              if value == "" then
                value = nx_string(gui.TextManager:GetText(str_list[k]))
              else
                value = value .. "/" .. nx_string(gui.TextManager:GetText(str_list[k]))
              end
            end
            textgrid:SetValueString(nx_int(row), "CCompleteDialogId", value)
            textgrid:SetValueString(nx_int(row), "CompleteMenu", completemenu)
            local str_list = util_split_string(completemenu, ";")
            local value = ""
            for k = 1, table.getn(str_list) do
              if value == "" then
                value = nx_string(gui.TextManager:GetText(str_list[k]))
              else
                value = value .. "/" .. nx_string(gui.TextManager:GetText(str_list[k]))
              end
            end
            textgrid:SetValueString(nx_int(row), "CCompleteMenu", value)
          end
        end
        nx_destroy(task_textgrid)
      end
    end
  end
  if not textgrid:SaveToFile() then
    nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
  end
  nx_destroy(textgrid)
  return true
end
function general_subfunction_text(subfunction_type)
  local gui = nx_value("gui")
  local tasktype_config = nx_value("tasktype_config")
  if not nx_is_valid(tasktype_config) then
    return false
  end
  local work_path = nx_value("work_path")
  local target_file
  if "HuntList" == subfunction_type then
    target_file = work_path .. HUNTER_TEXT_TXT
  elseif "CollectList" == subfunction_type then
    target_file = work_path .. COLLECT_TEXT_TXT
  elseif "Convoy" == subfunction_type then
    target_file = work_path .. CONVOY_TEXT_TXT
  elseif "InteractiveList" == subfunction_type then
    target_file = work_path .. INTERACTIVE_TEXT_TXT
  elseif "UseItemList" == subfunction_type then
    target_file = work_path .. USEITEM_TEXT_TXT
  elseif "StoryTaskList" == subfunction_type then
    target_file = work_path .. STORY_TEXT_TXT
  elseif "Question" == subfunction_type then
    target_file = work_path .. QUESTION_TEXT_TXT
  elseif "questions" == subfunction_type then
    target_file = work_path .. QUESTIONS_TEXT_TXT
  end
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = target_file
  if not textgrid:LoadFromFile(2) then
    nx_msgbox("\180\242\191\170\206\196\188\254(" .. textgrid.FileName .. ")\202\167\176\220")
    nx_destroy(textgrid)
    return false
  end
  textgrid:RemoveAllCell()
  if "HuntList" == subfunction_type then
    textgrid:AddRow("\193\212\201\177\215\183\215\217", "\193\212\201\177\215\183\215\217", "\199\208\180\232\177\234\204\226", "\199\208\180\232\177\234\204\226", "\199\208\180\232\178\203\181\165", "\199\208\180\232\178\203\181\165")
  elseif "CollectList" == subfunction_type then
    textgrid:AddRow("\178\201\188\175\215\183\215\217", "\178\201\188\175\215\183\215\217")
  elseif "Convoy" == subfunction_type then
    textgrid:AddRow("\187\164\203\205\215\183\215\217", "\187\164\203\205\215\183\215\217")
  elseif "InteractiveList" == subfunction_type then
    textgrid:AddRow("\189\187\187\165\215\183\215\217", "\189\187\187\165\215\183\215\217", "\182\212\187\176", "\182\212\187\176", "\200\183\182\168", "\200\183\182\168")
  elseif "UseItemList" == subfunction_type then
    textgrid:AddRow("\202\185\211\195\181\192\190\223\215\183\215\217", "\202\185\211\195\181\192\190\223\215\183\215\217")
  elseif "StoryTaskList" == subfunction_type then
    textgrid:AddRow("\185\202\202\194ID", "\185\202\202\194\215\183\215\217", "\185\202\202\194\215\183\215\217", "\185\202\202\194\200\235\191\218", "\185\202\202\194\200\235\191\218", "\185\202\202\194\196\218\200\221", "\185\202\202\194\196\218\200\221", "\185\202\202\194\204\226\196\191", "\185\202\202\194\204\226\196\191")
  elseif "Question" == subfunction_type then
    textgrid:AddRow("\180\240\204\226\215\183\215\217", "\180\240\204\226\215\183\215\217", "\180\240\204\226\200\235\191\218", "\180\240\204\226\200\235\191\218")
  elseif "questions" == subfunction_type then
    textgrid:AddRow("\204\226\196\191ID", "\180\240\176\1841", "\180\240\176\1841", "\180\240\176\1842", "\180\240\176\1842", "\180\240\176\1843", "\180\240\176\1843", "\180\240\176\1844", "\180\240\176\1844", "\180\240\176\1845", "\180\240\176\1845", "\180\240\176\1846", "\180\240\176\1846", "\180\240\176\1847", "\180\240\176\1847", "\180\240\176\1848", "\180\240\176\1848", "\180\240\176\1849", "\180\240\176\1849", "\180\240\176\18410", "\180\240\176\18410")
  end
  local child_list = tasktype_config:GetChildList()
  for i = 1, table.getn(child_list) do
    local item = child_list[i]:GetChild(subfunction_type)
    if nx_is_valid(item) then
      local file_name = nx_custom(item, "file_name")
      if nil ~= file_name then
        local subfunction_textgrid = nx_create("TextGrid")
        subfunction_textgrid.FileName = work_path .. file_name
        if not subfunction_textgrid:LoadFromFile(2) then
          nx_msgbox("\180\242\191\170\206\196\188\254(" .. subfunction_textgrid.FileName .. ")\202\167\176\220")
        else
          for j = 0, subfunction_textgrid.RowCount - 1 do
            if "HuntList" == subfunction_type then
              local id = nx_string(subfunction_textgrid:GetValueString(nx_int(j), "ID"))
              if id ~= "" then
                local hunter_trackinfo = subfunction_textgrid:GetValueString(nx_int(j), "TrackInfo")
                local qiecuotitle = subfunction_textgrid:GetValueString(nx_int(j), "QiecuoTitle")
                local qiecuomenu = subfunction_textgrid:GetValueString(nx_int(j), "QiecuoMenu")
                local row = textgrid:AddRow(hunter_trackinfo)
                textgrid:SetValueString(nx_int(row), "Chunter_TrackInfo", nx_string(gui.TextManager:GetText(hunter_trackinfo)))
                textgrid:SetValueString(nx_int(row), "QiecuoTitle", nx_string(qiecuotitle))
                textgrid:SetValueString(nx_int(row), "CQiecuoTitle", nx_string(gui.TextManager:GetText(qiecuotitle)))
                textgrid:SetValueString(nx_int(row), "QiecuoMenu", nx_string(qiecuomenu))
                textgrid:SetValueString(nx_int(row), "CQiecuoMenu", nx_string(gui.TextManager:GetText(qiecuomenu)))
              end
            elseif "CollectList" == subfunction_type then
              local id = nx_string(subfunction_textgrid:GetValueString(nx_int(j), "ID"))
              if id ~= "" then
                local collect_trackinfo = nx_string(subfunction_textgrid:GetValueString(nx_int(j), "TrackInfo"))
                local row = textgrid:AddRow(collect_trackinfo)
                textgrid:SetValueString(nx_int(row), "Ccollect_TrackInfo", nx_string(gui.TextManager:GetText(collect_trackinfo)))
              end
            elseif "Convoy" == subfunction_type then
              local id = subfunction_textgrid:GetValueString(nx_int(j), "ID")
              if id ~= "" then
                local convoy_trackinfo = subfunction_textgrid:GetValueString(nx_int(j), "TrackInfo")
                local row = textgrid:AddRow(convoy_trackinfo)
                textgrid:SetValueString(nx_int(row), "Cconvoy_TrackInfo", nx_string(gui.TextManager:GetText(convoy_trackinfo)))
              end
            elseif "InteractiveList" == subfunction_type then
              local id = subfunction_textgrid:GetValueString(nx_int(j), "ID")
              if id ~= "" then
                local interact_trackinfo = subfunction_textgrid:GetValueString(nx_int(j), "TrackInfo")
                local dialogid = subfunction_textgrid:GetValueString(nx_int(j), "DialogID")
                local okmenu = subfunction_textgrid:GetValueString(nx_int(j), "OkMenu")
                local row = textgrid:AddRow(interact_trackinfo)
                textgrid:SetValueString(nx_int(row), "Cinteract_TrackInfo", nx_string(gui.TextManager:GetText(interact_trackinfo)))
                textgrid:SetValueString(nx_int(row), "DialogID", dialogid)
                textgrid:SetValueString(nx_int(row), "CDialogID", nx_string(gui.TextManager:GetText(dialogid)))
                textgrid:SetValueString(nx_int(row), "OkMenu", okmenu)
                textgrid:SetValueString(nx_int(row), "COkMenu", nx_string(gui.TextManager:GetText(okmenu)))
              end
            elseif "UseItemList" == subfunction_type then
              local id = subfunction_textgrid:GetValueString(nx_int(j), "ID")
              if id ~= "" then
                local useitem_trackinfoid = subfunction_textgrid:GetValueString(nx_int(j), "TrackInfoID")
                local row = textgrid:AddRow(useitem_trackinfoid)
                textgrid:SetValueString(nx_int(row), "Cuseitem_TrackInfoID", nx_string(gui.TextManager:GetText(useitem_trackinfoid)))
              end
            elseif "StoryTaskList" == subfunction_type then
              local id = subfunction_textgrid:GetValueString(nx_int(j), "ID")
              if id ~= "" then
                local story_trackinfoid = subfunction_textgrid:GetValueString(nx_int(j), "TrackInfoID")
                local contextid = subfunction_textgrid:GetValueString(nx_int(j), "contextId")
                local titleid = subfunction_textgrid:GetValueString(nx_int(j), "titleId")
                local row = textgrid:AddRow(id)
                textgrid:SetValueString(nx_int(row), "story_TrackInfoID", story_trackinfoid)
                textgrid:SetValueString(nx_int(row), "Cstory_TrackInfoID", nx_string(gui.TextManager:GetText(story_trackinfoid)))
                textgrid:SetValueString(nx_int(row), "story_menu", "story_menu_" .. id)
                textgrid:SetValueString(nx_int(row), "Cstory_menu", nx_string(gui.TextManager:GetText("story_menu_" .. id)))
                textgrid:SetValueString(nx_int(row), "contextId", contextid)
                textgrid:SetValueString(nx_int(row), "CcontextId", nx_string(gui.TextManager:GetText(contextid)))
                textgrid:SetValueString(nx_int(row), "titleId", titleid)
                textgrid:SetValueString(nx_int(row), "CtitleId", nx_string(gui.TextManager:GetText(titleid)))
              end
            elseif "Question" == subfunction_type then
              local id = subfunction_textgrid:GetValueString(nx_int(j), "ID")
              if id ~= "" then
                local question_trackinfoid = nx_string(subfunction_textgrid:GetValueString(nx_int(j), "TrackInfoID"))
                local row = textgrid:AddRow(question_trackinfoid)
                textgrid:SetValueString(nx_int(row), "Cquestion_TrackInfoID", nx_string(gui.TextManager:GetText(question_trackinfoid)))
                textgrid:SetValueString(nx_int(row), "quest_menu", "quest_menu_" .. id)
                textgrid:SetValueString(nx_int(row), "Cquest_menu", nx_string(gui.TextManager:GetText("quest_menu_" .. id)))
              end
            elseif "questions" == subfunction_type then
              local id = subfunction_textgrid:GetValueString(nx_int(j), "ID")
              if id ~= "" then
                local answer1 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText1")
                local answer2 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText2")
                local answer3 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText3")
                local answer4 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText4")
                local answer5 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText5")
                local answer6 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText6")
                local answer7 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText7")
                local answer8 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText8")
                local answer9 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText9")
                local answer10 = subfunction_textgrid:GetValueString(nx_int(j), "ZZAnswerText10")
                local row = textgrid:AddRow(id)
                textgrid:SetValueString(nx_int(row), "ZZAnswerText1", answer1)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText1", nx_string(gui.TextManager:GetText(answer1)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText2", answer2)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText2", nx_string(gui.TextManager:GetText(answer2)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText3", answer3)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText3", nx_string(gui.TextManager:GetText(answer3)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText4", answer4)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText4", nx_string(gui.TextManager:GetText(answer4)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText5", answer5)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText5", nx_string(gui.TextManager:GetText(answer5)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText6", answer6)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText6", nx_string(gui.TextManager:GetText(answer6)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText7", answer7)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText7", nx_string(gui.TextManager:GetText(answer7)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText8", answer8)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText8", nx_string(gui.TextManager:GetText(answer8)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText9", answer9)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText9", nx_string(gui.TextManager:GetText(answer9)))
                textgrid:SetValueString(nx_int(row), "ZZAnswerText10", answer10)
                textgrid:SetValueString(nx_int(row), "CZZAnswerText10", nx_string(gui.TextManager:GetText(answer10)))
              end
            end
          end
        end
        nx_destroy(subfunction_textgrid)
      end
    end
  end
  if not textgrid:SaveToFile() then
    nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
  end
  nx_destroy(textgrid)
  return true
end
local TASK_CITE_1 = "share\\Task\\Task\\task_sl_cite.ini"
local TASK_CITE_2 = "share\\Task\\Task\\task_drama_cite.ini"
local TASK_CITE_3 = "share\\Task\\Task\\task_guide_cite.ini"
local CONDITION_INFO = "share\\Rule\\condition.ini"
function generate_simple_data_button_click(self)
  generate_simple_data()
  local task_form = nx_value("task_form")
  local root_node = task_form.work_dir_form.task_list.RootNode
  local task_cite_list = {
    TASK_CITE_1,
    TASK_CITE_2,
    TASK_CITE_3
  }
  local condition_ini = nx_create("IniDocument")
  condition_ini.FileName = nx_resource_path() .. CONDITION_INFO
  condition_ini:LoadFromFile()
  for cite_index = 1, table.getn(task_cite_list) do
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. task_cite_list[cite_index]
    ini:LoadFromFile()
    local sect_list = ini:GetSectionList()
    local sect_count = ini:GetSectionCount()
    for i = 1, sect_count do
      ini:DeleteSection(sect_list[i])
    end
    local play_count = root_node:GetNodeCount()
    local play_list = root_node:GetNodeList()
    for i = 1, play_count do
      local play_node = play_list[i]
      local task_chapter_count = play_node:GetNodeCount()
      local task_chapter_list = play_node:GetNodeList()
      for j = 1, task_chapter_count do
        local task_chapter = task_chapter_list[j]
        local task_parter_count = task_chapter:GetNodeCount()
        local task_parter_list = task_chapter:GetNodeList()
        for m = 1, task_parter_count do
          local task_parter_node = task_parter_list[m]
          local task_detail_count = task_parter_node:GetNodeCount()
          local task_detail_list = task_parter_node:GetNodeList()
          for n = 1, task_detail_count do
            local detail_node = task_detail_list[n]
            local task_info = detail_node.task_info
            if (task_info.Line == "5" or task_info.Line == "7") and task_cite_list[cite_index] == TASK_CITE_1 and ini:AddSection(task_info.ID) then
              ini:AddString(task_info.ID, "TitleId", task_info.TitleId)
              ini:AddString(task_info.ID, "Line", task_info.Line)
              ini:AddString(task_info.ID, "AcceptNpc", task_info.AcceptNpc)
              ini:AddString(task_info.ID, "AcceptSceneID", task_info.AcceptSceneID)
              ini:AddString(task_info.ID, "AcceptArea", task_info.AcceptArea)
              ini:AddString(task_info.ID, "AcceptDialogId", task_info.ContextId)
              str_list = nx_function("ext_split_string", task_info.AcceptLimit, ";")
              local min = "0"
              if 1 <= table.getn(str_list) and condition_ini:FindSection(str_list[1]) then
                local para2 = condition_ini:ReadString(str_list[1], "Para2", "")
                if para2 == "repute_jianghu" then
                  min = condition_ini:ReadString(str_list[1], "min", "0")
                end
              end
              ini:AddString(task_info.ID, "AcceptRepLimit", min)
            end
            if (task_info.Line == "1" or task_info.Line == "4") and task_cite_list[cite_index] == TASK_CITE_2 and ini:AddSection(task_info.ID) then
              ini:AddString(task_info.ID, "Line", task_info.Line)
              ini:AddString(task_info.ID, "DramaName", get_drama_name(play_node.num))
              ini:AddString(task_info.ID, "Chapter", nx_string(nx_number(task_chapter.num)))
              ini:AddString(task_info.ID, "Round", nx_string(nx_number(task_parter_node.num)))
              local next_task_limit = nx_string(task_info.NextTaskLimit)
              local value_list = nx_function("ext_split_string", next_task_limit, ";")
              if 1 < table.getn(value_list) then
                next_task_limit = value_list[1]
              end
              ini:AddString(task_info.ID, "NextTaskLimit", next_task_limit)
            end
            if task_info.Line == "9" and task_cite_list[cite_index] == TASK_CITE_3 and ini:AddSection(task_info.ID) then
              ini:AddString(task_info.ID, "TitleId", task_info.TitleId)
              ini:AddString(task_info.ID, "Line", task_info.Line)
              ini:AddString(task_info.ID, "AcceptNpc", task_info.AcceptNpc)
              ini:AddString(task_info.ID, "AcceptSceneID", task_info.AcceptSceneID)
              ini:AddString(task_info.ID, "AcceptDialogId", task_info.ContextId)
              ini:AddString(task_info.ID, "DramaName", "")
              ini:AddString(task_info.ID, "PrizeDesc", "")
            end
          end
        end
      end
    end
    if not ini:SaveToFile() then
      nx_msgbox(ini.FileName .. "\177\163\180\230\202\167\176\220!")
    end
    nx_destroy(ini)
  end
  nx_destroy(condition_ini)
  return true
end
local TASK_CITE_3 = "share\\Task\\Task\\task_zx_cite.ini"
local TASK_FILE_PATH = "ini\\Task\\Task\\Task\\"
function generate_simple_data()
  local fs = nx_create("FileSearch")
  if not nx_is_valid(fs) then
    return false
  end
  local work_path = nx_value("work_path")
  fs:SearchFile(work_path .. TASK_FILE_PATH, "*.txt")
  local file_table = fs:GetFileList()
  local tmp_data = nx_create("ArrayList", nx_current())
  for i = 1, table.getn(file_table) do
    local textgrid = nx_create("TextGrid")
    textgrid.FileName = work_path .. TASK_FILE_PATH .. file_table[i]
    if textgrid:LoadFromFile(2) then
      for row = 0, textgrid.RowCount - 1 do
        local id = textgrid:GetValueString(nx_int(row), "ID")
        local item = tmp_data:CreateChild(id)
        local title_id = textgrid:GetValueString(nx_int(row), "TitleId")
        local child = item:CreateChild("TitleId")
        child.value = title_id
        local line = textgrid:GetValueString(nx_int(row), "Line")
        child = item:CreateChild("Line")
        child.value = line
        local accept_npc = textgrid:GetValueString(nx_int(row), "AcceptNpc")
        child = item:CreateChild("AcceptNpc")
        child.value = accept_npc
        local next_task_limit = textgrid:GetValueString(nx_int(row), "NextTaskLimit")
        local value_list = nx_function("ext_split_string", next_task_limit, ";")
        child = item:CreateChild("NextTaskLimit")
        if 1 <= table.getn(value_list) then
          child.value = value_list[1]
        else
          child.value = next_task_limit
        end
        local accept_scene_id = textgrid:GetValueString(nx_int(row), "AcceptSceneID")
        child = item:CreateChild("AcceptSceneID")
        child.value = accept_scene_id
        local context_id = textgrid:GetValueString(nx_int(row), "ContextId")
        child = item:CreateChild("ContextId")
        child.value = context_id
      end
    end
    nx_destroy(textgrid)
  end
  nx_destroy(fs)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. TASK_CITE_3
  ini:LoadFromFile()
  local sect_list = ini:GetSectionList()
  local sect_count = ini:GetSectionCount()
  for i = 1, sect_count do
    ini:DeleteSection(sect_list[i])
  end
  local tmp_list = tmp_data:GetChildList()
  local tmp_count = table.getn(tmp_list)
  for i = 1, tmp_count do
    local id = tmp_list[i].Name
    local line = tmp_list[i]:GetChild("Line")
    if nx_is_valid(line) and (line.value == "1" or line.value == "4") then
      local next_id = tmp_list[i]:GetChild("NextTaskLimit")
      if nx_is_valid(next_id) and tmp_data:FindChild(next_id.value) then
        local next_item = tmp_data:GetChild(next_id.value)
        if nx_is_valid(next_item) then
          ini:AddSection(id)
          local child = next_item:GetChild("TitleId")
          if nx_is_valid(child) then
            ini:WriteString(id, "TitleId", child.value)
          end
          child = next_item:GetChild("Line")
          if nx_is_valid(child) then
            ini:WriteString(id, "Line", child.value)
          end
          child = next_item:GetChild("AcceptNpc")
          if nx_is_valid(child) then
            ini:WriteString(id, "AcceptNpc", child.value)
          end
          child = next_item:GetChild("ContextId")
          if nx_is_valid(child) then
            ini:WriteString(id, "AcceptDialogId", child.value)
          end
          child = next_item:GetChild("AcceptSceneID")
          if nx_is_valid(child) then
            ini:WriteString(id, "AcceptSceneID", child.value)
          end
          ini:WriteString(id, "NextTaskLimit", next_id.value)
        end
      end
    end
  end
  if not ini:SaveToFile() then
    nx_msgbox(TASK_CITE_3 .. "\177\163\180\230\202\167\176\220")
  end
  nx_destroy(tmp_data)
  nx_destroy(ini)
  return true
end
function enable_form(form, enabled)
  local child_list = form:GetChildControlList()
  for i = 1, table.getn(child_list) do
    if child_list[i].Name ~= "btn_save" and child_list[i].Name ~= "rbtn_task_edit" then
      child_list[i].Enabled = enabled
    end
  end
  if nx_find_custom(form, "min_max_close_component") then
    form.min_max_close_component.min_btn.Enabled = enabled
    form.min_max_close_component.max_btn.Enabled = enabled
    form.min_max_close_component.close_btn.Enabled = enabled
  end
  return 1
end
function file_size_button_click(self)
  local gui = nx_value("gui")
  local file_size_form = nx_value("form_file_size")
  if not nx_is_valid(file_size_form) then
    file_size_form = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_file_size.xml")
    file_size_form:Show()
    nx_set_value("form_file_size", file_size_form)
  end
  file_size_form.Parent:ToFront(file_size_form)
  return 1
end
