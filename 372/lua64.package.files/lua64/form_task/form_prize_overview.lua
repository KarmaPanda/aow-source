require("form_task\\common")
require("form_task\\form_task")
require("form_task\\tool")
local PRIZE = "Prize"
local PRIZE_NAME = "\189\177\192\248\215\220\177\237"
local PRIZE_TITLE = "prize_title_info"
local PRIZE_CONFIG = "prize_info"
local EXTRA_PRIZE = "extraPrize"
local EXTRA_PRIZE_NAME = "\182\238\205\226\189\177\192\248\215\220\177\237"
local EXTRA_PRIZE_TITLE = "extra_prize_title_info"
local EXTRA_PRIZE_CONFIG = "extra_prize_info"
function main_form_init(self)
  self.Fixed = false
  self.cur_editor_row = -1
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  if self.type == PRIZE then
    self.form_title_lbl.Text = nx_widestr(PRIZE_NAME)
    update_overview(self, PRIZE, PRIZE_TITLE, PRIZE_CONFIG)
  elseif self.type == EXTRA_PRIZE then
    self.form_title_lbl.Text = nx_widestr(EXTRA_PRIZE_NAME)
    update_overview(self, EXTRA_PRIZE, EXTRA_PRIZE_TITLE, EXTRA_PRIZE_CONFIG)
  end
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function close_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function load_info(type, title_info_name, info_name)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return false
  end
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return false
  end
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild(type)
    if nx_is_valid(child) then
      local textgrid = nx_create("TextGrid")
      textgrid.FileName = work_path .. child.file_name
      if not textgrid:LoadFromFile(2) then
        nx_destroy(textgrid)
        nx_msgbox("\188\211\212\216\206\196\188\254\202\167\176\220 " .. work_path .. child.file_name)
        return false
      end
      local title_info = nx_value(title_info_name)
      if not nx_is_valid(title_info) then
        title_info = nx_create("ArrayList", title_info_name)
        nx_set_value(title_info_name, title_info)
      else
        title_info:ClearChild()
      end
      if textgrid.ColCount > 0 then
        for j = 0, textgrid.ColCount - 1 do
          local title = textgrid:GetColName(j)
          if title ~= "" then
            local child_node = title_info:CreateChild(title)
          end
        end
      end
      local config = nx_value(info_name)
      if not nx_is_valid(config) then
        config = nx_create("ArrayList", info_name)
        nx_set_value(info_name, config)
      else
        config:ClearChild()
      end
      for i = 0, textgrid.RowCount - 1 do
        local id = textgrid:GetValueString(nx_int(i), "ID")
        if "" ~= id then
          local value = textgrid:GetValueString(nx_int(i), "ID")
          local result, error = is_in_range(value, child)
          if result then
            local item = config:GetChild(id)
            if nx_is_valid(item) then
              nx_msgbox("\189\177\192\248\177\237\214\216\184\180ID: " .. id)
            else
              item = config:CreateChild(id)
              item.ID = id
              for j = 1, textgrid.ColCount - 1 do
                local prop = textgrid:GetColName(j)
                local value = textgrid:GetValueString(nx_int(i), nx_int(j))
                nx_set_custom(item, prop, value)
              end
            end
          end
        end
      end
      nx_destroy(textgrid)
    else
      nx_msgbox("\206\180\197\228\214\195" .. type .. "\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  else
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
  end
  return 1
end
function update_overview(form, type, title_info_name, config_info_name)
  local grid = form.prize_grid
  grid:ClearRow()
  grid.type = type
  grid.title_info = title_info_name
  grid.config_info = config_info_name
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    if nx_is_valid(task_form.sect_node) then
      local child = task_form.sect_node:GetChild(type)
      if nx_is_valid(child) then
        local title_info = nx_value(title_info_name)
        if not nx_is_valid(title_info) then
          return 0
        end
        local prop_list = title_info:GetChildList()
        local prop_count = table.getn(prop_list)
        grid.ColCount = prop_count
        for j = 1, prop_count do
          grid:SetColTitle(j - 1, nx_widestr(prop_list[j].Name))
        end
        local config = nx_value(config_info_name)
        if not nx_is_valid(config) then
          return 0
        end
        local item_list = config:GetChildList()
        for i = 1, table.getn(item_list) do
          local item = item_list[i]
          local row = grid:InsertRow(-1)
          local id = nx_custom(item, "ID")
          local is_title_change = false
          for j = 1, prop_count do
            local value = nx_custom(item, prop_list[j].Name)
            if value == nil then
              value = ""
            end
            if prop_list[j].Name == "Title" then
              local gui = nx_value("gui")
              local new_value = nx_string(gui.TextManager:GetText("title_" .. id))
              if value ~= new_value then
                value = new_value
                is_title_change = true
                nx_set_custom(item, prop_list[j].Name, new_value)
              end
            end
            grid:SetGridText(row, j - 1, nx_widestr(value))
          end
          if is_title_change then
            set_change(item, grid.type)
          end
        end
      else
        nx_msgbox("\206\180\197\228\214\195" .. type .. "\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
      end
    else
      nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  end
  return 1
end
function load_prize_info()
  load_info(PRIZE, PRIZE_TITLE, PRIZE_CONFIG)
  return 1
end
function load_extra_prize_info()
  load_info(EXTRA_PRIZE, EXTRA_PRIZE_TITLE, EXTRA_PRIZE_CONFIG)
  return 1
end
function save_prize_info()
  return save_info(PRIZE)
end
function save_extra_prize_info()
  return save_info(EXTRA_PRIZE)
end
function btn_up_click(self)
  local form = self.Parent
  local grid = form.prize_grid
  sort(grid, "up")
  form.cur_editor_row = -1
  return 1
end
function btn_down_click(self)
  local form = self.Parent
  local grid = form.prize_grid
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
  local grid = form.prize_grid
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
  local child = task_form.sect_node:GetChild(grid.type)
  if nx_is_valid(child) then
    local result, error = is_in_range(name, child)
    if not result then
      nx_msgbox("\203\162\185\214ID " .. error)
      return 0
    end
  else
    nx_msgbox("\206\180\197\228\214\195" .. grid.type .. "\206\196\188\254, \199\235\188\236\178\233task_type.ini\206\196\188\254")
    return 0
  end
  local config = nx_value(grid.config_info)
  if not nx_is_valid(config) then
    return 0
  end
  if config:FindChild(name) then
    nx_msgbox("ID\214\216\184\180!")
    return 0
  end
  local item = config:CreateChild(name)
  item.ID = name
  set_change(item, grid.type)
  local row = grid:InsertRow(-1)
  grid:SetGridText(row, 0, nx_widestr(name))
  grid:SelectRow(row)
  if grid.type == PRIZE then
    local gui = nx_value("gui")
    local title = nx_string(gui.TextManager:GetText("title_" .. name))
    item.Title = title
    grid:SetGridText(row, 1, nx_widestr(title))
  end
  return 1
end
function btn_delete_click(self)
  local form = self.Parent
  local grid = form.prize_grid
  local index = grid.RowSelectIndex
  if index == -1 then
    return 0
  end
  local id = nx_string(grid:GetGridText(index, 0))
  if not show_confirm_box("\202\199\183\241\201\190\179\253" .. id) then
    return 0
  end
  local config = nx_value(grid.config_info)
  local item = config:GetChild(id)
  if nx_is_valid(item) then
    set_change(item, grid.type)
    config:RemoveChildByID(item)
    grid:DeleteRow(index)
  end
  return 1
end
function prize_grid_select_row(grid, row)
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
  local config = nx_value(grid.config_info)
  if not nx_is_valid(config) then
    return 0
  end
  local id = nx_string(grid:GetGridText(row, 0))
  local item = config:GetChild(id)
  if not nx_is_valid(item) then
    return 0
  end
  for i = 1, grid.ColCount - 1 do
    local ctrl = grid:GetGridControl(row, i)
    if nx_is_valid(ctrl) then
      local new_value = nx_string(ctrl.Text)
      grid:SetGridText(row, i, nx_widestr(new_value))
      local prop = nx_string(grid:GetColTitle(i))
      local old_value = nx_custom(item, prop)
      nx_set_custom(item, prop, new_value)
      grid:ClearGridControl(row, i)
      if old_value ~= new_value then
        set_change(item, grid.type)
      end
    end
  end
  form.cur_editor_row = -1
  return 1
end
function prize_grid_double_click_grid(grid, row)
  local form = grid.Parent
  if form.cur_editor_row == row then
    return 0
  end
  local gui = nx_value("gui")
  local start = 1
  if grid.type == PRIZE then
    start = 2
  end
  for i = start, grid.ColCount - 1 do
    local edit_ctrl = gui:Create("Edit")
    edit_ctrl.BackColor = EDIT_COLOR
    nx_bind_script(edit_ctrl, nx_current())
    nx_callback(edit_ctrl, "on_enter", "edit_enter")
    edit_ctrl.Text = grid:GetGridText(row, i)
    grid:SetGridControl(row, i, edit_ctrl)
  end
  form.cur_editor_row = row
  return 1
end
function id_key_edit_changed(self)
  local form = self.Parent
  local grid = form.prize_grid
  for i = 0, grid.RowCount - 1 do
    if grid:GetGridText(i, 0) == self.Text then
      grid:SelectRow(i)
      return 1
    end
  end
  return 0
end
function save_info(type)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return false
  end
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild(type)
    if nx_is_valid(child) then
      local work_path = nx_value("work_path")
      local config
      if type == PRIZE then
        config = nx_value(PRIZE_CONFIG)
      elseif type == EXTRA_PRIZE then
        config = nx_value(EXTRA_PRIZE_CONFIG)
      end
      if not nx_is_valid(config) then
        nx_msgbox("\177\163\180\230\200\206\206\241\202\167\176\220")
        return 0
      end
      local changes_list = nx_value("changes_list")
      if nx_is_valid(changes_list) then
        local change_item = changes_list:GetChild(type)
        if nx_is_valid(change_item) then
          local child_list = change_item:GetChildList()
          for i = 1, table.getn(child_list) do
            local item = child_list[i].info
            local id = child_list[i].Name
            local textgrid = nx_create("TextGrid")
            textgrid.FileName = work_path .. child.file_name
            textgrid:LoadFromFile(2)
            local index = textgrid:FindRowIndexs(nx_int(0), id)
            if 0 < table.getn(index) then
              if not nx_is_valid(item) then
                textgrid:RemoveRowByIndex(nx_int(index[1]))
              else
                for j = 1, textgrid.ColCount - 1 do
                  local prop = textgrid:GetColName(j)
                  local value = nx_custom(item, prop)
                  if nil == value then
                    value = ""
                  end
                  textgrid:SetValueString(nx_int(index[1]), prop, value)
                end
              end
            elseif nx_is_valid(item) then
              local row = textgrid:AddRow(item.ID)
              for j = 1, textgrid.ColCount - 1 do
                local prop = textgrid:GetColName(j)
                local value = nx_custom(item, prop)
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
            change_item:RemoveChildByID(child_list[i])
          end
        end
      end
    else
      nx_msgbox("\206\180\197\228\214\195" .. grid.type .. "\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
    end
  else
    nx_msgbox("\206\180\197\228\214\195\206\196\188\254\163\172\199\235\188\236\178\233task_type.ini\206\196\188\254")
  end
  return 1
end
