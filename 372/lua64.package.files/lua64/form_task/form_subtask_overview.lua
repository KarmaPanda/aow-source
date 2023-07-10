require("form_task\\common")
require("form_task\\tool")
require("form_task\\form_task")
require("form_task\\task_public_func")
local SUBTASK_INFO = "subtask_info"
local SUBTASK_TITLE_INFO = "subtask_title_info"
function clear_subtask_overview_memory()
  local subtask_info = nx_value(SUBTASK_INFO)
  if nx_is_valid(subtask_info) then
    subtask_info:ClearChild()
    nx_destroy(subtask_info)
  end
  return 1
end
function get_subtask_info(type, id)
  local subtask_info = nx_value(SUBTASK_INFO)
  if nx_is_valid(subtask_info) and subtask_info:FindChild(type) then
    local type_list = subtask_info:GetChild(type)
    if type_list:FindChild(id) then
      return type_list:GetChild(id)
    end
  end
  return nil
end
function create_subtask_info(type, id)
  local subtask_info = nx_value(SUBTASK_INFO)
  local subtask_title_info = nx_value(SUBTASK_TITLE_INFO)
  if nx_is_valid(subtask_info) and subtask_info:FindChild(type) then
    local type_list = subtask_info:GetChild(type)
    local id_sect
    if type_list:FindChild(id) then
      id_sect = type_list:GetChild(id)
    else
      id_sect = type_list:CreateChild(id)
    end
    if subtask_title_info:FindChild(type) then
      local title_list = subtask_title_info:GetChild(type)
      local title_list_count = title_list:GetChildCount()
      local item_struct = id_sect:CreateChild(id)
      for i = 0, title_list_count - 1 do
        local title_item = title_list:GetChildByIndex(i)
        local item = item_struct:CreateChild(title_item.item_name)
        if "ID" == nx_string(item.Name) then
          item.item_name = id
        else
          item.item_name = ""
        end
      end
      return id_sect
    end
  end
  return nil
end
function key_to_title(key)
  if type_list[key] == nil then
    return ""
  end
  return string.sub(type_list[key][3], 0, string.len(type_list[key][3]) - 2)
end
local load_text = function(type_info, type_title_info, node)
  local file_name = node.file_name
  local text_grid = nx_create("TextGrid")
  local work_path = nx_value("work_path")
  text_grid.FileName = work_path .. file_name
  if not text_grid:LoadFromFile(2) then
    nx_destroy(text_grid)
    return 0
  end
  local row_count = text_grid.RowCount
  local col_count = text_grid.ColCount
  if 0 < col_count then
    for i = 0, col_count - 1 do
      local title = text_grid:GetColName(i)
      local item = type_title_info:CreateChild("")
      item.item_name = title
    end
  end
  for i = 0, row_count - 1 do
    local id = text_grid:GetValueString(nx_int(i), nx_int(0))
    if id ~= "" then
      local value = text_grid:GetValueString(nx_int(i), "ID")
      local result = is_in_range(value, node)
      if result then
        local id_name = text_grid:GetColName(0)
        local id_sect
        if type_info:FindChild(id) then
          id_sect = type_info:GetChild(id)
        else
          id_sect = type_info:CreateChild(id)
        end
        local sect = id_sect:CreateChild(id)
        local item
        item = sect:CreateChild(id_name)
        item.item_name = id
        for j = 1, col_count - 1 do
          local item_name = text_grid:GetColName(j)
          item = sect:CreateChild(item_name)
          item.item_name = text_grid:GetValueString(nx_int(i), nx_int(j))
        end
      end
    end
  end
  nx_destroy(text_grid)
  return 1
end
function load_resource()
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  local subtask_info = get_new_global_list(SUBTASK_INFO)
  local subtask_title_info = get_new_global_list(SUBTASK_TITLE_INFO)
  for i = 1, table.getn(type_list_key) do
    local key = type_list_key[i]
    local type_info = subtask_info:CreateChild(key)
    local type_title_info = subtask_title_info:CreateChild(key)
    if nx_is_valid(task_form.sect_node) then
      local child = task_form.sect_node:GetChild(type_list[key][1])
      if nx_is_valid(child) then
        load_text(type_info, type_title_info, child)
      end
    end
  end
  return 1
end
function update_subtask_grid(grid, type)
  grid.Parent.cur_editor_row = -1
  grid:ClearSelect()
  grid:ClearRow()
  grid.ColCount = 1
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) and nx_is_valid(task_form.sect_node) then
    local subtask_info = nx_value(SUBTASK_INFO)
    local subtask_title_info = nx_value(SUBTASK_TITLE_INFO)
    if nx_is_valid(subtask_info) and nx_is_valid(subtask_title_info) then
      local type_info = subtask_info:GetChild(type)
      local title_list = subtask_title_info:GetChild(type)
      if nx_is_valid(title_list) then
        local title_list_count = title_list:GetChildCount()
        grid.ColWidth = GRID_COL_WIDTH
        grid.ColCount = title_list_count
        for i = 0, title_list_count - 1 do
          local title_item = title_list:GetChildByIndex(i)
          grid:SetColTitle(i, nx_widestr(title_item.item_name))
        end
      end
      if nx_is_valid(type_info) then
        local type_info_count = type_info:GetChildCount()
        for i = 0, type_info_count - 1 do
          local type_info_item = type_info:GetChildByIndex(i)
          local item_count = type_info_item:GetChildCount()
          for j = 0, item_count - 1 do
            local id_item = type_info_item:GetChildByIndex(j)
            local id_item_count = id_item:GetChildCount()
            row = grid:InsertRow(-1)
            for k = 0, id_item_count - 1 do
              local item = id_item:GetChildByIndex(k)
              if item.Name == "TaskID" then
                local id = id_item:GetChildByIndex(0).item_name
                local task_id_list
                task_id_list = nx_execute("form_task\\form_subtask_process", "get_use_subtask_task_id", type, id)
                if item.item_name ~= task_id_list then
                  item.item_name = task_id_list
                  nx_execute("form_task\\form_task", "set_change", id, type)
                end
              end
              grid:SetGridText(row, k, nx_widestr(item.item_name))
            end
          end
        end
      end
    end
  end
  return 1
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  for i = 1, table.getn(type_list_key) do
    local key = type_list_key[i]
    local ctl = self:Find(key .. "_rb")
    if nx_is_valid(ctl) then
      ctl.key = key
      ctl.select_index = -1
    end
  end
  self.grid_type = self.hunter_rb.key
  self.sort_up_btn.sort_type = "up"
  self.sort_down_btn.sort_type = "down"
  self.cur_editor_row = -1
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.hunter_rb.Checked = true
  update_subtask_grid(self.overview_grid, self.hunter_rb.key)
  self.save_btn.Visible = false
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function close_btn_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function grid_changed_rb_click(self)
  local form = self.Parent
  local grid = self.Parent.overview_grid
  if self.Checked and self.key ~= form.grid_type then
    local ctl = form:Find(form.grid_type .. "_rb")
    ctl.select_index = grid.RowSelectIndex
    local subtask_info = nx_value(SUBTASK_INFO)
    if not nx_is_valid(subtask_info) then
      return 0
    end
    if subtask_info:FindChild(form.grid_type) then
      local sect = subtask_info:GetChild(form.grid_type)
      sect:ClearChild()
      local row_count = grid.RowCount
      local col_count = grid.ColCount
      for i = 0, row_count - 1 do
        local id = nx_string(grid:GetGridText(i, 0))
        local id_sect
        if sect:FindChild(id) then
          id_sect = sect:GetChild(id)
        else
          id_sect = sect:CreateChild(id)
        end
        local subtask = id_sect:CreateChild(id)
        for j = 0, col_count - 1 do
          local key = grid:GetColTitle(j)
          local item = subtask:CreateChild(nx_string(key))
          item.item_name = nx_string(grid:GetGridText(i, j))
        end
      end
    end
    form.grid_type = self.key
    form.cur_editor_row = -1
    update_subtask_grid(grid, self.key)
    grid:SelectRow(self.select_index)
  end
  return 1
end
function add_btn_click(self)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if not nx_is_valid(task_form.sect_node) then
    return 0
  end
  local form = self.Parent
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_input.xml")
  dialog.allow_empty = false
  dialog.Left = self.Left + form.Left
  dialog.Top = self.Top + form.Top - dialog.Height
  dialog:ShowModal()
  local res, name = nx_wait_event(100000000, dialog, "form_input_return")
  if res == "cancel" then
    return 0
  end
  local child = task_form.sect_node:GetChild(type_list[form.grid_type][1])
  if nx_is_valid(child) then
    local result, error = is_in_range(name, child)
    if not result then
      nx_msgbox("ID " .. error)
      return 0
    end
  end
  local subtask_title_info = nx_value(SUBTASK_TITLE_INFO)
  local title_info
  if subtask_title_info:FindChild(form.grid_type) then
    title_info = subtask_title_info:GetChild(form.grid_type)
    if title_info:GetChildCount() == 0 then
      return 0
    end
  else
    return 0
  end
  local subtask_info = nx_value(SUBTASK_INFO)
  local type_info = subtask_info:GetChild(form.grid_type)
  local id_sect
  if type_info:FindChild(name) then
    if form.grid_type == "question" or form.grid_type == "story" then
      id_sect = type_info:GetChild(name)
    else
      nx_msgbox("ID:" .. name .. "\210\209\190\173\180\230\212\218")
      return 0
    end
  else
    id_sect = type_info:CreateChild(name)
  end
  local sect = id_sect:CreateChild(name)
  for i = 0, title_info:GetChildCount() - 1 do
    local item
    local title_item = title_info:GetChildByIndex(i)
    if i == 0 then
      item = sect:CreateChild("ID")
      item.item_name = name
    else
      item = sect:CreateChild(title_item.item_name)
      item.item_name = ""
    end
  end
  local grid = self.Parent.overview_grid
  local row = grid:InsertRow(-1)
  grid:SelectRow(row)
  grid:SetGridText(row, 0, nx_widestr(name))
  nx_execute("form_task\\form_task", "set_change", name, form.grid_type)
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) and nx_is_valid(task_form.subtask_process_form) then
    nx_execute("form_task\\form_subtask_process", "update_subtask_process_view", task_form.subtask_process_form)
  end
  return 1
end
function delete_btn_click(self)
  local form = self.Parent
  local grid = form.overview_grid
  local index = grid.RowSelectIndex
  if index == -1 then
    return 0
  end
  local id = nx_string(grid:GetGridText(index, 0))
  if not show_confirm_box("\202\199\183\241\201\190\179\253" .. id) then
    return 0
  end
  local subtask_info = nx_value(SUBTASK_INFO)
  local type_info = subtask_info:GetChild(form.grid_type)
  if type_info:FindChild(id) then
    local id_sect = type_info:GetChild(id)
    id_sect:RemoveChildByIndex(get_previous_same_value(grid, index))
    if id_sect:GetChildCount() == 0 then
      type_info:RemoveChild(id)
    end
  end
  grid:DeleteRow(index)
  nx_execute("form_task\\form_task", "set_change", id, form.grid_type)
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) and nx_is_valid(task_form.subtask_process_form) then
    nx_execute("form_task\\form_subtask_process", "update_subtask_process_view", task_form.subtask_process_form)
  end
  return 1
end
local is_overview_table_type = function(type_name)
  for i = 1, table.getn(type_list_key) do
    if type_list_key[i] == type_name then
      return true
    end
  end
  return false
end
function save_btn_click(self)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  local work_path = nx_value("work_path")
  local subtask_info = nx_value(SUBTASK_INFO)
  local changes_list = nx_value("changes_list")
  if nx_is_valid(changes_list) and 0 < changes_list:GetChildCount() then
    for i = 0, changes_list:GetChildCount() - 1 do
      local changes_list_item = changes_list:GetChildByIndex(i)
      local type = changes_list_item.Name
      if nx_is_valid(task_form.sect_node) and is_overview_table_type(type) then
        local child = task_form.sect_node:GetChild(type_list[type][1])
        if nx_is_valid(child) then
          local text_grid = nx_create("TextGrid")
          text_grid.FileName = work_path .. child.file_name
          local type_info = subtask_info:GetChild(type)
          if text_grid:LoadFromFile(2) then
            for j = 0, changes_list_item:GetChildCount() - 1 do
              local item = changes_list_item:GetChildByIndex(j)
              local id = item.info
              text_grid:RemoveRowByKey(0, id)
              local id_sect = type_info:GetChild(id)
              if nx_is_valid(id_sect) then
                local id_sect_count = id_sect:GetChildCount()
                for m = 0, id_sect_count - 1 do
                  local item = id_sect:GetChildByIndex(m)
                  if nx_is_valid(item) then
                    local new_row = text_grid:AddRow(id)
                    for k = 1, item:GetChildCount() - 1 do
                      local name = item:GetChildByIndex(k).Name
                      local value = item:GetChildByIndex(k).item_name
                      text_grid:SetValueString(nx_int(new_row), name, value)
                    end
                  end
                end
              end
            end
            if not text_grid:SaveToFile() then
              nx_msgbox(text_grid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
              nx_destroy(text_grid)
              return 0
            end
          end
          nx_destroy(text_grid)
        end
      end
    end
  end
  return 1
end
local function level_selected_row(grid, cur_editor_row)
  local form = grid.Parent
  local subtask_info = nx_value(SUBTASK_INFO)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if not nx_is_valid(task_form.sect_node) then
    return 0
  end
  local type_info = subtask_info:GetChild(form.grid_type)
  local id = nx_string(grid:GetGridText(cur_editor_row, 0))
  local id_sect = type_info:GetChild(id)
  local index = get_previous_same_value(grid, cur_editor_row)
  local sect = id_sect:GetChildByIndex(index)
  local is_changed = false
  for i = 1, grid.ColCount - 1 do
    local ctl = grid:GetGridControl(cur_editor_row, i)
    local old_value = grid:GetGridText(cur_editor_row, i)
    local new_value = ctl.Text
    grid:ClearGridControl(cur_editor_row, i)
    if new_value ~= old_value then
      local title = nx_string(grid:GetColTitle(i))
      local ret = true
      if title == "RefreshMonster" then
        ret = ask_form_create_new_item("RefreshMonster", nx_string(new_value))
      elseif title == "TaskItemList" then
        ret = ask_form_create_new_item("TaskItem", nx_string(new_value))
      elseif string.find(title, "questid") then
        local child = task_form.sect_node:GetChild("questions")
        ret, error = is_in_range(nx_string(new_value), child)
        if not ret then
          nx_msgbox("\206\202\204\226ID " .. nx_string(new_value) .. " " .. error)
        end
      elseif title == "PathID" then
        ret = ask_form_delete_old_item("ConvoyPoint", nx_string(old_value))
        ret = ret and ask_form_create_new_item("ConvoyPoint", nx_string(new_value))
      end
      if ret then
        is_changed = true
        grid:SetGridText(cur_editor_row, i, new_value)
        local item = sect:GetChild(title)
        item.item_name = nx_string(new_value)
        set_modify_subtask_overview("grid_subtask_overview", form.grid_type, id, title, index, nx_string(old_value), item.item_name)
      end
    end
  end
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) and nx_is_valid(task_form.subtask_process_form) then
    nx_execute("form_task\\form_subtask_process", "update_subtask_process_view", task_form.subtask_process_form)
  end
  if is_changed then
    nx_execute("form_task\\form_task", "set_change", id, form.grid_type)
  end
  return 1
end
function overview_grid_select_row(self, row)
  local form = self.Parent
  local grid = form.overview_grid
  if form.cur_editor_row == row then
    return 0
  elseif form.cur_editor_row ~= -1 then
    level_selected_row(grid, form.cur_editor_row)
    form.cur_editor_row = -1
  end
  return 1
end
function overview_grid_double_click_grid(self, row, col)
  local form = self.Parent
  local grid = form.overview_grid
  if form.cur_editor_row == row then
    return 0
  elseif form.cur_editor_row ~= -1 then
    level_selected_row(grid, form.cur_editor_row)
  end
  form.cur_editor_row = row
  local gui = nx_value("gui")
  for i = 1, grid.ColCount - 1 do
    local edit_ctrl = CREATE_CONTROL("Edit")
    edit_ctrl.Text = grid:GetGridText(row, i)
    edit_ctrl.BackColor = EDIT_COLOR
    grid:SetGridControl(row, i, edit_ctrl)
    edit_ctrl.grid = grid
    edit_ctrl.row = form.cur_editor_row
    nx_bind_script(edit_ctrl, nx_current())
    nx_callback(edit_ctrl, "on_enter", "on_input_enter")
  end
  return 1
end
function on_input_enter(self)
  local grid = self.grid
  local cur_editor_row = self.row
  level_selected_row(grid, cur_editor_row)
  grid:ClearSelect()
  grid.Parent.cur_editor_row = -1
  return 1
end
function sort_btn_click(self)
  local form = self.Parent
  sort(form.overview_grid, self.sort_type)
  form.cur_editor_row = -1
  return 1
end
function id_key_edit_changed(self)
  local form = self.Parent
  local grid = form.overview_grid
  for i = 0, grid.RowCount - 1 do
    if grid:GetGridText(i, 0) == self.Text then
      grid:SelectRow(i)
      return 1
    end
  end
  return 0
end
