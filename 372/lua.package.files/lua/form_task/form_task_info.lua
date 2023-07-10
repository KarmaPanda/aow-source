require("form_task\\common")
require("form_task\\tool")
require("form_task\\form_task")
function main_form_open(self)
  load_task_config_ini()
  update_task_info(self, nil)
  return 1
end
function load_task_config_ini()
  local work_path = nx_value("work_path")
  if "" == work_path then
    return false
  end
  local text_grid = nx_create("TextGrid")
  text_grid.FileName = work_path .. TASK_CONFIG_INI
  if not text_grid:LoadFromFile(2) then
    nx_destroy(text_grid)
    return 0
  end
  local task_seperate = nx_value("task_seperate")
  if not nx_is_valid(task_seperate) then
    task_seperate = nx_create("ArrayList", "task_seperate")
    nx_set_value("task_seperate", task_seperate)
  else
    task_seperate:ClearChild()
  end
  local row_count = text_grid.RowCount
  local col_count = text_grid.ColCount
  for i = 0, row_count - 1 do
    local model, id, desc, info, name
    for j = 0, col_count - 1 do
      local value = text_grid:GetValueString(nx_int(i), nx_int(j))
      if text_grid:GetColName(j) == "Model" then
        model = value
      elseif text_grid:GetColName(j) == "ID" then
        id = value
      elseif text_grid:GetColName(j) == "Desc" then
        desc = value
      elseif text_grid:GetColName(j) == "Tips" then
        info = value
      elseif text_grid:GetColName(j) == "Name" then
        name = value
      end
    end
    local sect
    if task_seperate:FindChild(model) then
      sect = task_seperate:GetChild(model)
    else
      sect = task_seperate:CreateChild(model)
    end
    local item = sect:CreateChild(id)
    item.desc = desc
    item.info = info
    item.name = name
  end
  nx_destroy(text_grid)
  return 1
end
function load_task_item(task_info)
  local work_path = nx_value("work_path")
  if not nx_is_valid(task_info) then
    return 0
  end
  local task_id = task_info.ID
  if task_info.loaded == false then
    local textgrid = nx_create("TextGrid")
    textgrid.FileName = work_path .. task_info.file_name
    if not textgrid:LoadFromFile(2) then
      nx_msgbox("\188\211\212\216\200\206\206\241\202\167\176\220")
      nx_destroy(textgrid)
      return 0
    end
    local index = textgrid:FindRowIndexs(nx_int(0), task_id)
    if 0 < table.getn(index) then
      for i = 1, textgrid.ColCount - 1 do
        local prop = textgrid:GetColName(i)
        local value = textgrid:GetValueString(nx_int(index[1]), nx_int(i))
        nx_set_custom(task_info, prop, value)
      end
    end
    task_info.loaded = true
    nx_destroy(textgrid)
  end
  return 1
end
function save_task_info()
  local work_path = nx_value("work_path")
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    nx_msgbox("\177\163\180\230\200\206\206\241\202\167\176\220")
    return 0
  end
  local changes_list = nx_value("changes_list")
  if nx_is_valid(changes_list) then
    local item = changes_list:GetChild(TASK)
    if nx_is_valid(item) then
      local child_list = item:GetChildList()
      for i = 1, table.getn(child_list) do
        local task_info = child_list[i].info
        local id = child_list[i].Name
        local textgrid = nx_create("TextGrid")
        textgrid.FileName = work_path .. child_list[i].file_name
        textgrid:LoadFromFile(2)
        local index = textgrid:FindRowIndexs(nx_int(0), id)
        if 0 < table.getn(index) then
          if not nx_is_valid(task_info) then
            local submitnpc_value = nx_string(textgrid:GetValueString(nx_int(index[1]), "SubmitNpc"))
            local acceptnpc_value = nx_string(textgrid:GetValueString(nx_int(index[1]), "AcceptNpc"))
            textgrid:RemoveRowByIndex(nx_int(index[1]))
            check_npc_config(id, "@TaskCanSubmit", submitnpc_value, "")
            check_npc_config(id, "@TaskCanAccept", acceptnpc_value, "")
          else
            for j = 1, textgrid.ColCount - 1 do
              local prop = textgrid:GetColName(j)
              local old_value = nx_string(textgrid:GetValueString(nx_int(index[1]), nx_int(j)))
              local value = nx_custom(task_info, prop)
              if nil == value then
                value = ""
              end
              textgrid:SetValueString(nx_int(index[1]), prop, value)
              if prop == "SubmitNpc" then
                check_npc_config(task_info.ID, "@TaskCanSubmit", old_value, value)
              elseif prop == "AcceptNpc" then
                check_npc_config(task_info.ID, "@TaskCanAccept", old_value, value)
              end
            end
          end
        elseif nx_is_valid(task_info) then
          local next_index = get_after_index(task_info, textgrid)
          local row = textgrid:InsertRow(nx_int(next_index), task_info.ID)
          for j = 1, textgrid.ColCount - 1 do
            local prop = textgrid:GetColName(j)
            local value = nx_custom(task_info, prop)
            if nil == value then
              value = ""
            end
            textgrid:SetValueString(nx_int(row), prop, value)
            if prop == "SubmitNpc" then
              check_npc_config(task_info.ID, "@TaskCanSubmit", "", value)
            elseif prop == "AcceptNpc" then
              check_npc_config(task_info.ID, "@TaskCanAccept", "", value)
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
  return 1
end
function get_after_index(task_info, textgrid)
  local task_config = nx_value("task_config")
  if nx_is_valid(task_config) then
    local task_item = task_config:GetChild(task_info.SearchID)
    if nx_is_valid(task_item) then
      local index = task_item:GetChildIndex(task_info.Name)
      local next_task_info = nx_null()
      if index < task_item:GetChildCount() - 1 then
        next_task_info = task_item:GetChildByIndex(index + 1)
      end
      if not nx_is_valid(next_task_info) then
        index = task_config:GetChildIndex(task_item.Name)
        while index < task_config:GetChildCount() - 1 do
          index = index + 1
          local next_item = task_config:GetChildByIndex(index)
          if nx_is_valid(next_item) and next_item:GetChildCount() > 0 then
            next_task_info = next_item:GetChildByIndex(0)
            break
          end
        end
      end
      if nx_is_valid(next_task_info) then
        local index_list = textgrid:FindRowIndexs(nx_int(0), next_task_info.ID)
        if 0 < table.getn(index_list) then
          return index_list[1]
        else
          return get_after_index(next_task_info, textgrid)
        end
      end
    end
  end
  return textgrid.RowCount
end
function update_task_info(form, task_info)
  local main_info_grid = form.grid_main_info
  local more_info_grid = form.grid_more_info
  local task_seperate = nx_value("task_seperate")
  main_info_grid:ClearRow()
  more_info_grid:ClearRow()
  main_info_grid:SetColTitle(0, nx_widestr("\215\220\177\237"))
  more_info_grid:SetColTitle(0, nx_widestr("\184\223\188\182\207\238"))
  if nx_is_valid(task_info) and nx_is_valid(task_seperate) then
    local sect = task_seperate:GetChild(MAIN)
    if nx_is_valid(sect) then
      local item_list = sect:GetChildList()
      for i = 1, table.getn(item_list) do
        local child = item_list[i]
        if nx_is_valid(child) then
          local value = nx_custom(task_info, child.Name)
          if "NULL" == child.Name then
            local row = main_info_grid:InsertRow(-1)
          else
            local row = main_info_grid:InsertRow(-1)
            main_info_grid:SetGridText(row, 0, nx_widestr(child.Name))
            if nx_find_custom(child, "desc") then
              main_info_grid:SetGridText(row, 1, nx_widestr(child.desc))
            end
            if value == nil then
              value = ""
              nx_set_custom(task_info, child.Name, value)
            end
            main_info_grid:SetGridText(row, 2, nx_widestr(value))
          end
        end
      end
    end
  end
  if nx_is_valid(task_info) and nx_is_valid(task_seperate) then
    local sect = task_seperate:GetChild(FURTHER)
    if nx_is_valid(sect) then
      local item_list = sect:GetChildList()
      for i = 1, table.getn(item_list) do
        local child = item_list[i]
        if nx_is_valid(child) then
          local value = nx_custom(task_info, child.Name)
          if "NULL" == child.Name then
            local row = more_info_grid:InsertRow(-1)
          else
            local row = more_info_grid:InsertRow(-1)
            more_info_grid:SetGridText(row, 0, nx_widestr(child.Name))
            if nx_find_custom(child, "desc") then
              more_info_grid:SetGridText(row, 1, nx_widestr(child.desc))
            end
            if value == nil then
              value = ""
              nx_set_custom(task_info, child.Name, value)
            end
            more_info_grid:SetGridText(row, 2, nx_widestr(value))
          end
        end
      end
    end
  end
  return 1
end
function grid_main_info_double_click_grid(self, row, col)
  local prop = nx_string(self:GetGridText(row, 0))
  if "ID" == prop or "" == prop then
    return 0
  end
  create_control(self, row, col)
  return 1
end
function grid_more_info_double_click_grid(self, row, col)
  local prop = nx_string(self:GetGridText(row, 0))
  if "ID" == prop or "" == prop then
    return 0
  end
  create_control(self, row, col)
  return 1
end
function grid_more_info_mousein_row_changed(grid, row)
  nx_execute("form_task\\form_tips", "close_tips")
  return 1
end
function grid_main_info_mousein_row_changed(grid, row)
  nx_execute("form_task\\form_tips", "close_tips")
  return 1
end
function grid_main_info_right_select_grid(grid, new_row, new_col)
  set_hinttext(grid, new_row, MAIN)
  return 1
end
function grid_more_info_right_select_grid(grid, new_row, new_col)
  set_hinttext(grid, new_row, FURTHER)
  return 1
end
function set_hinttext(grid, new_row, sect_name)
  local gui = nx_value("gui")
  nx_execute("form_task\\form_tips", "close_tips")
  local info = ""
  if 0 <= new_row then
    local name = nx_string(grid:GetGridText(new_row, 0))
    local item = get_seperate_item(sect_name, name)
    if nx_is_valid(item) then
      info = nx_custom(item, "info")
      if nil == info then
        info = ""
      end
      if nx_find_custom(item, "name") and (item.name == "true" or item.name == "1") then
        local value = nx_string(grid:GetGridText(new_row, 2))
        info = nx_string(gui.TextManager:GetText(value)) .. SPLIT_LINE .. info
      end
    end
  end
  local x, y = gui:GetCursorPosition()
  nx_execute("form_task\\form_tips", "show_tips", x + 10, y + 10, info)
  return 1
end
function btn_text_click(self)
  local form = self.Parent.Parent
  local text_form = show_text_form(form)
  if nx_is_valid(text_form) then
    set_text_form(true, true)
  end
end
function show_text_form(task_form)
  if not nx_is_valid(task_form.task_info) then
    return nil
  end
  local gui = nx_value("gui")
  local text_form = nx_value("text_form")
  if nx_is_valid(text_form) then
    return nil
  end
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_text.xml")
  dialog.task_info = task_form.task_info
  dialog:ShowModal()
  nx_set_value("text_form", dialog)
  return dialog
end
function btn_prize_click(self)
  local form = self.Parent.Parent
  local gui = nx_value("gui")
  local prize_form = nx_value("prize_form")
  if nx_is_valid(prize_form) then
    prize_form.Parent:ToFront(prize_form)
    return 1
  end
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_prize_overview.xml")
  dialog.type = "Prize"
  dialog.task_info = form.task_info
  dialog:Show()
  nx_set_value("prize_form", dialog)
  return 1
end
function btn_extra_prize_click(self)
  local form = self.Parent.Parent
  local gui = nx_value("gui")
  local extra_prize_form = nx_value("extra_prize_form")
  if nx_is_valid(extra_prize_form) then
    extra_prize_form.Parent:ToFront(extra_prize_form)
    return 1
  end
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_prize_overview.xml")
  dialog.type = "extraPrize"
  dialog.task_info = form.task_info
  dialog:Show()
  nx_set_value("extra_prize_form", dialog)
  return 1
end
