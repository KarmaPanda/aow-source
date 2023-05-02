require("form_task\\task_public_func")
require("form_task\\common")
require("form_task\\form_task")
require("form_task\\tool")
function main_form_init(self)
  self.Fixed = false
  self.search_id = ""
  self.cur_editor_row = -1
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  update_path_overview(self)
  return 1
end
function main_form_close(self)
  local path_config = nx_value("path_config")
  if nx_is_valid(path_config) then
    local item_list = path_config:GetChildList()
    for i = 1, table.getn(item_list) do
      if item_list[i]:GetChildCount() <= 0 then
        nx_msgbox("\194\183\190\182ID:" .. item_list[i].Name .. "\195\187\211\208\194\183\190\182\181\227")
      end
    end
  end
  nx_destroy(self)
  return 1
end
function btn_close_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function btn_up_click(self)
  local form = self.Parent
  local grid = form.grid_path_list
  sort(grid, "up")
  form.cur_editor_row = -1
  return 1
end
function btn_down_click(self)
  local form = self.Parent
  local grid = form.grid_path_list
  sort(grid, "down")
  form.cur_editor_row = -1
  return 1
end
function load_path_info()
  local work_path = nx_value("work_path")
  if "" == work_path then
    return false
  end
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return false
  end
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild("ConvoyPoint")
    if nx_is_valid(child) then
      local textgrid = nx_create("TextGrid")
      textgrid.FileName = work_path .. child.file_name
      if not textgrid:LoadFromFile(2) then
        nx_destroy(textgrid)
        nx_msgbox("\188\211\212\216\206\196\188\254\202\167\176\220 " .. work_path .. child.file_name)
        return false
      end
      local path_config = nx_value("path_config")
      if not nx_is_valid(path_config) then
        path_config = nx_create("ArrayList", "path_config")
        nx_set_value("path_config", path_config)
      else
        path_config:ClearChild()
      end
      local path_title_info = nx_value("path_title_info")
      if not nx_is_valid(path_title_info) then
        path_title_info = nx_create("ArrayList", "path_title_info")
        nx_set_value("path_title_info", path_title_info)
      else
        path_title_info:ClearChild()
      end
      if textgrid.ColCount > 0 then
        for j = 0, textgrid.ColCount - 1 do
          local title = textgrid:GetColName(j)
          if title ~= "" then
            local child_node = path_title_info:CreateChild(title)
          end
        end
      end
      for i = 0, textgrid.RowCount - 1 do
        local id = textgrid:GetValueString(nx_int(i), "ID")
        if "" ~= id then
          local value = textgrid:GetValueString(nx_int(i), "ID")
          local result, error = is_in_range(value, child)
          if result then
            local path_item = path_config:GetChild(id)
            if not nx_is_valid(path_item) then
              path_item = path_config:CreateChild(id)
            end
            local path_info = path_item:CreateChild(id)
            path_info.ID = id
            for j = 1, textgrid.ColCount - 1 do
              local prop = textgrid:GetColName(j)
              local value = textgrid:GetValueString(nx_int(i), nx_int(j))
              nx_set_custom(path_info, prop, value)
            end
          end
        end
      end
      nx_destroy(textgrid)
    else
      nx_msgbox("\206\180\197\228\214\195ConvoyPoint\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  else
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
  end
  return 1
end
function update_path_overview(form)
  local grid = form.grid_path_list
  grid:ClearRow()
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    if nx_is_valid(task_form.sect_node) then
      local child = task_form.sect_node:GetChild("ConvoyPoint")
      if nx_is_valid(child) then
        local path_title_info = nx_value("path_title_info")
        if nx_is_valid(path_title_info) then
          local prop_list = path_title_info:GetChildList()
          local prop_count = table.getn(prop_list)
          grid.ColCount = prop_count
          for j = 1, prop_count do
            grid:SetColTitle(j - 1, nx_widestr(prop_list[j].Name))
          end
        end
        local path_config = nx_value("path_config")
        if not nx_is_valid(path_config) then
          return 0
        end
        if form.search_id ~= "" then
          local path_item = path_config:GetChild(form.search_id)
          if nx_is_valid(path_item) then
            local path_info_list = path_item:GetChildList()
            for j = 1, table.getn(path_info_list) do
              add_item_into_overview(form.grid_path_list, path_info_list[j], "path")
            end
          end
        else
          local path_item_list = path_config:GetChildList()
          for i = 1, table.getn(path_item_list) do
            local path_item = path_item_list[i]
            if nx_is_valid(path_item) then
              local path_info_list = path_item:GetChildList()
              for j = 1, table.getn(path_info_list) do
                add_item_into_overview(form.grid_path_list, path_info_list[j], "path")
              end
            end
          end
        end
      else
        nx_msgbox("\206\180\197\228\214\195ConvoyPoint\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
      end
    else
      nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  end
  return 1
end
function save_path_info()
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return false
  end
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild("ConvoyPoint")
    if nx_is_valid(child) then
      local work_path = nx_value("work_path")
      local path_config = nx_value("path_config")
      if not nx_is_valid(path_config) then
        nx_msgbox("\177\163\180\230\200\206\206\241\202\167\176\220")
        return 0
      end
      local changes_list = nx_value("changes_list")
      if nx_is_valid(changes_list) then
        local item = changes_list:GetChild(PATH)
        if nx_is_valid(item) then
          local child_list = item:GetChildList()
          for i = 1, table.getn(child_list) do
            local path_item = child_list[i].info
            local id = child_list[i].Name
            local textgrid = nx_create("TextGrid")
            textgrid.FileName = work_path .. child.file_name
            if not textgrid:LoadFromFile(2) then
              nx_destroy(textgrid)
              nx_msgbox("\188\211\212\216\206\196\188\254\202\167\176\220" .. work_path .. child.file_name)
              return 0
            end
            local index = textgrid:FindRowIndexs(nx_int(0), id)
            if 0 < table.getn(index) then
              for k = table.getn(index), 1, -1 do
                textgrid:RemoveRowByIndex(nx_int(index[k]))
              end
            end
            if nx_is_valid(path_item) then
              local path_info_list = path_item:GetChildList()
              for k = 1, table.getn(path_info_list) do
                local path_info = path_info_list[k]
                local row = textgrid:AddRow(id)
                for j = 1, textgrid.ColCount - 1 do
                  local prop = textgrid:GetColName(j)
                  local value = nx_custom(path_info, prop)
                  if nil == value then
                    value = ""
                  end
                  textgrid:SetValueString(nx_int(row), prop, value)
                end
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
      nx_msgbox("\206\180\197\228\214\195ConvoyPoint\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  else
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
  end
  return 1
end
function grid_path_list_double_click_grid(grid, row)
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
function grid_path_list_select_grid(grid, row)
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
  local path_config = nx_value("path_config")
  if not nx_is_valid(path_config) then
    return 0
  end
  local id = nx_string(grid:GetGridText(row, 0))
  local path_item = path_config:GetChild(id)
  if not nx_is_valid(path_item) then
    return 0
  end
  local index = get_previous_same_value(grid, form.cur_editor_row)
  local path_info = path_item:GetChildByIndex(index)
  if nx_is_valid(path_info) then
    for i = 1, grid.ColCount - 1 do
      local ctrl = grid:GetGridControl(row, i)
      if nx_is_valid(ctrl) then
        local new_value = nx_string(ctrl.Text)
        grid:SetGridText(row, i, nx_widestr(new_value))
        local prop = nx_string(grid:GetColTitle(i))
        local old_value = nx_custom(path_info, prop)
        nx_set_custom(path_info, prop, new_value)
        grid:ClearGridControl(row, i)
        if old_value ~= new_value then
          set_change(path_item, PATH)
        end
      end
    end
  end
  form.cur_editor_row = -1
  return 1
end
function id_key_edit_changed(self)
  local form = self.Parent
  local grid = form.grid_path_list
  for i = 0, grid.RowCount - 1 do
    if grid:GetGridText(i, 0) == self.Text then
      grid:SelectRow(i)
      return 1
    end
  end
  return 0
end
function show_path_overview_form(path_id)
  local gui = nx_value("gui")
  local path_overview_form = nx_value("path_overview_form")
  if nx_is_valid(path_overview_form) then
    path_overview_form:Close()
  end
  path_overview_form = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_path_overview.xml")
  path_overview_form.search_id = path_id
  nx_set_value("path_overview_form", path_overview_form)
  path_overview_form:Show()
  return 1
end
function delete_path_item(path_id)
  local path_config = nx_value("path_config")
  if not nx_is_valid(path_config) then
    return 0
  end
  local path_item = path_config:GetChild(path_id)
  if nx_is_valid(path_item) then
    set_change(path_item, PATH)
    path_config:RemoveChildByID(path_item)
  end
  return 1
end
function create_new_path_info(path_id)
  local path_config = nx_value("path_config")
  if not nx_is_valid(path_config) then
    return 0
  end
  local task_form = nx_value("task_form")
  local path_item = path_config:GetChild(path_id)
  if not nx_is_valid(path_item) then
    path_item = path_config:CreateChild(path_id)
  end
  local path_info = path_item:CreateChild(path_id)
  path_info.ID = path_id
  path_info.TalkID = ""
  local path_info_count = path_item:GetChildCount()
  set_change(path_item, PATH)
  return 1
end
function get_path_info(path_id)
  local path_config = nx_value("path_config")
  if not nx_is_valid(path_config) then
    return nil
  end
  return path_config:GetChild(path_id)
end
function btn_add_click(self)
  local form = self.Parent
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if not nx_is_valid(task_form.sect_node) then
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    return 0
  end
  if form.search_id ~= "" then
    create_new_path_info(form.search_id)
  else
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
    local child = task_form.sect_node:GetChild("ConvoyPoint")
    if nx_is_valid(child) then
      local result, error = is_in_range(name, child)
      if not result then
        nx_msgbox("\203\162\185\214ID " .. error)
        return 0
      end
    else
      nx_msgbox("\206\180\197\228\214\195ConvoyPoint\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
      return 0
    end
    local path_config = nx_value("path_config")
    if not nx_is_valid(path_config) then
      return 0
    end
    local path_item = path_config:GetChild(name)
    if not nx_is_valid(path_item) then
      nx_msgbox("\180\203\194\183\190\182\178\187\180\230\212\218\163\172\199\235\180\211\187\164\203\205\215\211\185\166\196\220\201\207\208\194\189\168")
      return 0
    end
    create_new_path_info(name)
  end
  update_path_overview(form)
  return 1
end
function btn_delete_click(self)
  local form = self.Parent
  local grid = form.grid_path_list
  local row = grid.RowSelectIndex
  if row == -1 then
    return 0
  end
  local id = nx_string(grid:GetGridText(row, 0))
  if not show_confirm_box("\202\199\183\241\201\190\179\253" .. id) then
    return 0
  end
  local path_config = nx_value("path_config")
  if not nx_is_valid(path_config) then
    return 0
  end
  local path_item = path_config:GetChild(id)
  if not nx_is_valid(path_item) then
    return 0
  end
  if path_item:GetChildCount() <= 1 then
    nx_msgbox("\194\183\190\182\189\218\181\227\178\187\196\220\201\217\211\2181\184\246\163\172\200\231\208\232\201\190\179\253\184\195\194\183\190\182\163\172\214\187\196\220\180\211\187\164\203\205\215\211\185\166\196\220\180\166\201\190\179\253")
    return 0
  end
  local index = get_previous_same_value(grid, grid.RowSelectIndex)
  if not path_item:RemoveChildByIndex(index) then
    nx_msgbox("\201\190\179\253\180\237\206\243")
    return 0
  end
  set_change(path_item, PATH)
  update_path_overview(form)
  return 1
end
