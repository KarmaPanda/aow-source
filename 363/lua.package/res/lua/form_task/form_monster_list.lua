require("form_task\\common")
require("form_task\\form_task")
require("form_task\\tool")
function main_form_open(self)
  return 1
end
function create_new_monster_item(monster_id)
  local monster_config = nx_value("monster_config")
  if nx_is_valid(monster_config) then
    local monster_item = monster_config:CreateChild(monster_id)
    if monster_config:GetChildCount() > 1 then
      local first_child = monster_config:GetChildByIndex(0)
      local property_list = nx_custom_list(first_child)
      for i = 1, table.getn(property_list) do
        if property_list[i] ~= "ID" then
          nx_set_custom(monster_item, property_list[i], "")
        end
      end
    end
    monster_item.ID = monster_id
    set_change(monster_item, MONSTER)
    local monster_overview_form = nx_value("monster_overview_form")
    if nx_is_valid(monster_overview_form) then
      nx_execute("form_task\\form_monster_overview", "update_monster_overview", monster_overview_form)
      select_grid_by_key(monster_overview_form.grid_monster_list, monster_id)
    end
    return monster_item
  end
  return nil
end
function update_monster_list(form, task_info)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if not nx_is_valid(task_form.sect_node) then
    return 0
  end
  local control_box = form.ctrlbox_monster_list
  control_box.ScrollSmooth = true
  control_box:ClearControl()
  if not nx_is_valid(task_info) then
    return 0
  end
  local task_id = task_info.ID
  local value = nx_custom(task_info, "RefreshMonster")
  if nil ~= value and "" ~= value then
    local str_list = nx_function("ext_split_string", value, SPLIT_CHAR)
    for i = 1, table.getn(str_list) do
      local monster_item = get_monster_item_by_id(str_list[i])
      if not nx_is_valid(monster_item) then
        local res = show_confirm_box("\202\199\183\241\208\194\189\168\203\162\185\214ID\163\186" .. str_list[i])
        if res then
          local child = task_form.sect_node:GetChild("RefreshMonster")
          if nx_is_valid(child) then
            local result, error = is_in_range(str_list[i], child)
            if not result then
              nx_msgbox("\203\162\185\214ID " .. error)
              return 0
            end
          else
            nx_msgbox("\206\180\197\228\214\195RefreshMonster\206\196\188\254")
            return 0
          end
          monster_item = create_new_monster_item(str_list[i])
        end
      end
      add_item_into_controlbox(control_box, monster_item)
    end
  end
  local subtask_pro_info = nx_value("subtask_process_info")
  if nx_is_valid(subtask_pro_info) then
    local task_step_info = subtask_pro_info:GetChild(task_id)
    if nx_is_valid(task_step_info) then
      local task_step_info_list = task_step_info:GetChildList()
      for i = 1, table.getn(task_step_info_list) do
        local step_info = task_step_info_list[i]
        local subtask_info = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", step_info.type, step_info.subfunction)
        if nx_is_valid(subtask_info) then
          local subtask_list = subtask_info:GetChildList()
          for j = 1, table.getn(subtask_list) do
            local item = subtask_list[j]:GetChild("RefreshMonster")
            if nx_is_valid(item) then
              local value = item.item_name
              if nil ~= value and "" ~= value then
                local str_list = nx_function("ext_split_string", value, SPLIT_CHAR)
                for i = 1, table.getn(str_list) do
                  local monster_item = get_monster_item_by_id(str_list[i])
                  if not nx_is_valid(monster_item) then
                    local res = show_confirm_box("\202\199\183\241\208\194\189\168\203\162\185\214ID\163\186" .. str_list[i])
                    if res then
                      local child = task_form.sect_node:GetChild("RefreshMonster")
                      if nx_is_valid(child) then
                        local result, error = is_in_range(str_list[i], child)
                        if not result then
                          nx_msgbox("\203\162\185\214ID " .. error)
                          return 0
                        end
                      else
                        nx_msgbox("\206\180\197\228\214\195RefreshMonster\206\196\188\254")
                        return 0
                      end
                      monster_item = create_new_monster_item(str_list[i])
                    end
                  end
                  add_item_into_controlbox(control_box, monster_item)
                end
              end
            end
          end
        end
      end
    end
  end
  return 1
end
function add_item_into_controlbox(control_box, monster_info)
  local gui = nx_value("gui")
  if not nx_is_valid(monster_info) then
    return 0
  end
  local grid = CREATE_CONTROL("Grid")
  grid.Name = "grid_monster_list"
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_double_click_grid", "grid_double_click_grid")
  nx_callback(grid, "on_right_select_grid", "grid_right_select")
  nx_callback(grid, "on_mousein_row_changed", "grid_mousein_row_changed")
  grid.ColCount = MONSTER_COL_COUNT
  grid.ColWidth = MONSTER_COL_WIDTH
  grid.BackColor = MONSTER_BACK_COLOR
  grid.RowHeaderVisible = true
  grid.HeaderBackColor = MONSTER_HEAD_COLOR
  grid.SelectBackColor = MONSTER_SELECT_COLOR
  grid:SetColTitle(0, nx_widestr("\203\162\185\214\177\237"))
  local monster_title_info = nx_value("monster_title_info")
  if nx_is_valid(monster_title_info) then
    local prop_list = monster_title_info:GetChildList()
    local prop_count = table.getn(prop_list)
    for j = 1, prop_count do
      local row = grid:InsertRow(-1)
      grid:SetGridText(row, 0, nx_widestr(prop_list[j].Name))
      local item = get_seperate_item(MONSTER, prop_list[j].Name)
      if nx_is_valid(item) then
        local desc = nx_custom(item, "desc")
        if nil ~= desc then
          grid:SetGridText(row, 1, nx_widestr(desc))
        end
      end
      local value = nx_custom(monster_info, prop_list[j].Name)
      if nil == value then
        value = ""
      end
      grid:SetGridText(row, 2, nx_widestr(value))
      if "ID" == prop_list[j].Name then
        grid.ID = value
      end
    end
  end
  grid.Width = grid.ColWidth * grid.ColCount + 18
  grid.Height = grid.RowHeight * grid.RowCount + grid.RowHeight
  grid.ColCount = MONSTER_COL_COUNT
  control_box:AddControl(grid)
  return 1
end
function grid_double_click_grid(self, row, col)
  local prop = nx_string(self:GetGridText(row, 0))
  if "ID" == prop then
    return 0
  end
  create_control(self, row, col)
  return 1
end
function grid_mousein_row_changed(grid, new_row)
  nx_execute("form_task\\form_tips", "close_tips")
  return 1
end
function grid_right_select(grid, new_row, new_col)
  local gui = nx_value("gui")
  nx_execute("form_task\\form_tips", "close_tips")
  local info = ""
  if 0 <= new_row then
    local name = nx_string(grid:GetGridText(new_row, 0))
    local item = get_seperate_item(MONSTER, name)
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
function btn_show_all_click(self)
  local gui = nx_value("gui")
  local monster_overview_form = nx_value("monster_overview_form")
  if nx_is_valid(monster_overview_form) then
    monster_overview_form.Parent:ToFront(monster_overview_form)
    return 1
  end
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_monster_overview.xml")
  nx_set_value("monster_overview_form", dialog)
  dialog:Show()
  return 1
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
