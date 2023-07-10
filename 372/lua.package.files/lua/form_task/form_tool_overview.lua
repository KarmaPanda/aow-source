require("form_task\\task_public_func")
require("form_task\\common")
require("form_task\\form_task")
require("form_task\\tool")
function main_form_init(self)
  self.Fixed = false
  self.cur_editor_row = -1
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  update_tool_overview(self)
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function load_tool_info(form)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return false
  end
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return false
  end
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild("TaskItem")
    if nx_is_valid(child) then
      local textgrid = nx_create("TextGrid")
      textgrid.FileName = work_path .. child.file_name
      if not textgrid:LoadFromFile(2) then
        nx_destroy(textgrid)
        nx_msgbox("\188\211\212\216\206\196\188\254\202\167\176\220 " .. work_path .. child.file_name)
        return false
      end
      local tool_config = nx_value("tool_config")
      if not nx_is_valid(tool_config) then
        tool_config = nx_create("ArrayList", "tool_config")
        nx_set_value("tool_config", tool_config)
      else
        tool_config:ClearChild()
      end
      local tool_title_info = nx_value("tool_title_info")
      if not nx_is_valid(tool_title_info) then
        tool_title_info = nx_create("ArrayList", "tool_title_info")
        nx_set_value("tool_title_info", tool_title_info)
      else
        tool_title_info:ClearChild()
      end
      if textgrid.ColCount > 0 then
        for j = 0, textgrid.ColCount - 1 do
          local title = textgrid:GetColName(j)
          if title ~= "" then
            tool_title_info:CreateChild(title)
          end
        end
      end
      for i = 0, textgrid.RowCount - 1 do
        local id = nx_string(textgrid:GetValueString(nx_int(i), "ID"))
        if "" ~= id then
          local value = nx_string(textgrid:GetValueString(nx_int(i), "ID"))
          local result, error = is_in_range(value, child)
          if result then
            local tool_item = tool_config:GetChild(id)
            if nx_is_valid(tool_item) then
              nx_msgbox("\181\192\190\223\177\237\214\216\184\180ID: " .. id)
            else
              tool_item = tool_config:CreateChild(id)
              tool_item.ID = id
              for j = 1, textgrid.ColCount - 1 do
                local prop = textgrid:GetColName(j)
                local value = nx_string(textgrid:GetValueString(nx_int(i), nx_int(j)))
                nx_set_custom(tool_item, prop, value)
              end
              local old_task_id = nx_custom(tool_item, "TaskID")
              local task_id = get_used_task_id("TaskItemList", id)
              if old_task_id ~= task_id then
                nx_set_custom(tool_item, "TaskID", task_id)
                set_change(tool_item, TOOL)
              end
            end
          end
        end
      end
      nx_destroy(textgrid)
    else
      nx_msgbox("\206\180\197\228\214\195TaskItem\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  else
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
  end
  return true
end
function save_tool_info()
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return false
  end
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild("TaskItem")
    if nx_is_valid(child) then
      local work_path = nx_value("work_path")
      local tool_config = nx_value("tool_config")
      if not nx_is_valid(tool_config) then
        nx_msgbox("\177\163\180\230\200\206\206\241\202\167\176\220")
        return 0
      end
      local changes_list = nx_value("changes_list")
      if nx_is_valid(changes_list) then
        local item = changes_list:GetChild(TOOL)
        if nx_is_valid(item) then
          local child_list = item:GetChildList()
          for i = 1, table.getn(child_list) do
            local tool_item = child_list[i].info
            local id = child_list[i].Name
            local textgrid = nx_create("TextGrid")
            textgrid.FileName = work_path .. child.file_name
            textgrid:LoadFromFile(2)
            local index = textgrid:FindRowIndexs(nx_int(0), id)
            if 0 < table.getn(index) then
              if not nx_is_valid(tool_item) then
                textgrid:RemoveRowByIndex(nx_int(index[1]))
              else
                for j = 1, textgrid.ColCount - 1 do
                  local prop = textgrid:GetColName(j)
                  local value = nx_custom(tool_item, prop)
                  if nil == value then
                    value = ""
                  end
                  textgrid:SetValueString(nx_int(index[1]), prop, value)
                end
              end
            elseif nx_is_valid(tool_item) then
              local row = textgrid:AddRow(tool_item.ID)
              for j = 1, textgrid.ColCount - 1 do
                local prop = textgrid:GetColName(j)
                local value = nx_custom(tool_item, prop)
                if nil == value then
                  value = ""
                end
                textgrid:SetValueString(nx_int(row), prop, value)
              end
            end
            if not textgrid:SaveToFile() then
              nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
              nx_destroy(textgrid)
              return 0
            end
            nx_destroy(textgrid)
            item:RemoveChildByID(child_list[i])
          end
        end
      end
    else
      nx_msgbox("\206\180\197\228\214\195TaskItem\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  else
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
  end
  return 1
end
function btn_close_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function update_tool_overview(form)
  local grid = form.grid_tool_list
  grid:ClearRow()
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    if nx_is_valid(task_form.sect_node) then
      local child = task_form.sect_node:GetChild("TaskItem")
      if nx_is_valid(child) then
        local tool_title_info = nx_value("tool_title_info")
        if nx_is_valid(tool_title_info) then
          local prop_list = tool_title_info:GetChildList()
          local prop_count = table.getn(prop_list)
          grid.ColCount = prop_count
          for j = 1, prop_count do
            grid:SetColTitle(j - 1, nx_widestr(prop_list[j].Name))
          end
        end
        local tool_config = nx_value("tool_config")
        if not nx_is_valid(tool_config) then
          return 0
        end
        local tool_item_list = tool_config:GetChildList()
        for i = 1, table.getn(tool_item_list) do
          local tool_item = tool_item_list[i]
          add_item_into_overview(form.grid_tool_list, tool_item, "tool")
        end
      else
        nx_msgbox("\206\180\197\228\214\195TaskItem\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
      end
    else
      nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  end
  return 1
end
function btn_up_click(self)
  local form = self.Parent
  local grid = form.grid_tool_list
  sort(grid, "up")
  form.cur_editor_row = -1
  return 1
end
function btn_down_click(self)
  local form = self.Parent
  local grid = form.grid_tool_list
  sort(grid, "down")
  form.cur_editor_row = -1
  return 1
end
function btn_add_click(self)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if not nx_is_valid(task_form.sect_node) then
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
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
  local child = task_form.sect_node:GetChild("TaskItem")
  if nx_is_valid(child) then
    local result, error = is_in_range(name, child)
    if not result then
      nx_msgbox("\183\162\183\197\181\192\190\223ID " .. error)
      return 0
    end
  else
    nx_msgbox("\206\180\197\228\214\195TaskItem\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    return 0
  end
  local tool_config = nx_value("tool_config")
  if not nx_is_valid(tool_config) then
    return 0
  end
  if tool_config:FindChild(name) then
    nx_msgbox("ID\214\216\184\180!")
    return 0
  end
  local tool_item = tool_config:CreateChild(name)
  tool_item.ID = name
  set_change(tool_item, TOOL)
  local grid = form.grid_tool_list
  local row = grid:InsertRow(-1)
  grid:SetGridText(row, 0, nx_widestr(name))
  grid:SelectRow(row)
  return 1
end
function btn_delete_click(self)
  local form = self.Parent
  local grid = form.grid_tool_list
  local index = grid.RowSelectIndex
  if index == -1 then
    return 0
  end
  local id = nx_string(grid:GetGridText(index, 0))
  if not show_confirm_box("\202\199\183\241\201\190\179\253" .. id) then
    return 0
  end
  local tool_config = nx_value("tool_config")
  local tool_item = tool_config:GetChild(id)
  if nx_is_valid(tool_item) then
    set_change(tool_item, TOOL)
    tool_config:RemoveChildByID(tool_item)
    grid:DeleteRow(index)
  end
  return 1
end
function grid_tool_list_double_click_grid(grid, row)
  local form = grid.Parent
  if form.cur_editor_row == row then
    return 0
  end
  local gui = nx_value("gui")
  for i = 1, grid.ColCount - 1 do
    local edit_ctrl = CREATE_CONTROL("Edit")
    edit_ctrl.BackColor = EDIT_COLOR
    nx_bind_script(edit_ctrl, nx_current())
    nx_callback(edit_ctrl, "on_enter", "edit_enter")
    edit_ctrl.Text = grid:GetGridText(row, i)
    grid:SetGridControl(row, i, edit_ctrl)
  end
  form.cur_editor_row = row
  return 1
end
function grid_tool_list_select_row(grid, row)
  local form = grid.Parent
  if form.cur_editor_row == row then
    return 0
  end
  leave_changes_effective(grid)
end
function edit_enter(self)
  local grid = self.Parent
  leave_changes_effective(grid)
  return 1
end
function leave_changes_effective(grid)
  local form = grid.Parent
  local row = form.cur_editor_row
  if row == -1 then
    return 0
  end
  local tool_config = nx_value("tool_config")
  if not nx_is_valid(tool_config) then
    return 0
  end
  local id = nx_string(grid:GetGridText(row, 0))
  local tool_item = tool_config:GetChild(id)
  if not nx_is_valid(tool_item) then
    return 0
  end
  for i = 1, grid.ColCount - 1 do
    local ctrl = grid:GetGridControl(row, i)
    if nx_is_valid(ctrl) then
      local new_value = nx_string(ctrl.Text)
      grid:SetGridText(row, i, nx_widestr(new_value))
      local prop = nx_string(grid:GetColTitle(i))
      local old_value = nx_custom(tool_item, prop)
      nx_set_custom(tool_item, prop, new_value)
      grid:ClearGridControl(row, i)
      if old_value ~= new_value then
        set_change(tool_item, TOOL)
        set_modify_tool_info("grid_tool_overview", id, prop, old_value, new_value)
      end
    end
  end
  form.cur_editor_row = -1
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    nx_execute("form_task\\form_tool_list", "update_tool_list", task_form.tool_list_form, task_form.task_info)
  end
  return 1
end
function id_key_edit_changed(self)
  local form = self.Parent
  local grid = form.grid_tool_list
  for i = 0, grid.RowCount - 1 do
    if grid:GetGridText(i, 0) == self.Text then
      grid:SelectRow(i)
      return 1
    end
  end
  return 0
end
