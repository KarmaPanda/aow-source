require("form_task\\common")
require("form_task\\tool")
require("form_task\\form_task")
local SUBTASK_PROCESS_INFO = "subtask_process_info"
function main_form_init(self)
  return 1
end
function main_form_open(self)
  self.process_list_grid:SetColTitle(0, nx_widestr("Order"))
  self.process_list_grid:SetColTitle(1, nx_widestr("Type"))
  self.process_list_grid:SetColTitle(2, nx_widestr("\178\189\214\232ID"))
  self.process_list_grid:SetColTitle(3, nx_widestr("Desc"))
  self.process_list_grid.cur_editor_row = -1
  self.process_list_grid.current_task_id = ""
  return 1
end
function subtask_overview_btn_click(self)
  local gui = nx_value("gui")
  local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
  if not nx_is_valid(form_subtask_overview) then
    form_subtask_overview = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_subtask_overview.xml")
    nx_set_value("form_task\\form_subtask_overview", form_subtask_overview)
    form_subtask_overview:Show()
  else
    form_subtask_overview.Parent:ToFront(form_subtask_overview)
  end
  return 1
end
local util_split_string = function(szbuffer, splits)
  if szbuffer == nil then
    return {}
  end
  return nx_function("ext_split_string", szbuffer, splits)
end
function load_res()
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  local subtask_pro_info = nx_value(SUBTASK_PROCESS_INFO)
  if nx_is_valid(subtask_pro_info) then
    subtask_pro_info:ClearChild()
  else
    subtask_pro_info = nx_create("ArrayList", SUBTASK_PROCESS_INFO)
    nx_set_value(SUBTASK_PROCESS_INFO, subtask_pro_info)
  end
  local work_path = nx_value("work_path")
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild("SubFunction")
    if nx_is_valid(child) then
      local text_grid = nx_create("TextGrid")
      text_grid.FileName = work_path .. child.file_name
      if not text_grid:LoadFromFile(2) then
        nx_destroy(text_grid)
        return 0
      end
      local row_count = text_grid.RowCount
      local col_count = text_grid.ColCount
      for i = 0, row_count - 1 do
        local task_id = nx_string(text_grid:GetValueString(nx_int(i), nx_int(0)))
        if task_id ~= "" then
          local value = text_grid:GetValueString(nx_int(i), "ID")
          local result = is_in_range(value, child)
          if result then
            local type = ""
            local subfunction = ""
            local order = ""
            for j = 1, col_count - 1 do
              local type_name = text_grid:GetColName(j)
              local val = text_grid:GetValueString(nx_int(i), nx_int(j))
              if type_name == "Type" then
                type = val
              elseif type_name == "TypeID" then
                subfunction = val
              elseif type_name == "Order" then
                order = val
              end
            end
            local task_step_info
            if subtask_pro_info:FindChild(task_id) then
              task_step_info = subtask_pro_info:GetChild(task_id)
            else
              task_step_info = subtask_pro_info:CreateChild(task_id)
            end
            local info = task_step_info:CreateChild("")
            info.type = type
            info.subfunction = subfunction
            info.order = order
          end
        end
        local is_exist = nx_execute("form_task\\form_work_dir", "is_exist_task_id", task_id)
        if not is_exist then
          delete_task_subfunction(task_id)
        end
      end
      nx_destroy(text_grid)
    end
  end
  return 1
end
function get_process_number(grid, row)
  local ret = 1
  if nx_widestr("") == grid:GetGridText(row, 0) then
    return -2
  end
  local row_num = nx_number(grid:GetGridText(row, 0))
  local arraylist = nx_create("ArrayList", "arraylist")
  for i = 0, grid.RowCount - 1 do
    if row ~= i then
      local str = nx_string(grid:GetGridText(i, 0))
      if not arraylist:FindChild(str) and str ~= "" then
        arraylist:CreateChild(str)
      end
    end
  end
  for i = 0, arraylist:GetChildCount() - 1 do
    local num = nx_number(arraylist:GetChildByIndex(i).Name)
    if row_num > num and num ~= -1 then
      ret = ret + 1
    end
  end
  if row_num == -1 then
    ret = -1
  end
  nx_destroy(arraylist)
  return ret
end
local create_grid = function(col_width, index, type, info_struct)
  local gui = nx_value("gui")
  local grid = CREATE_CONTROL("Grid")
  grid.RowHeaderVisible = true
  grid.ColWidth = col_width
  grid.ColCount = 3
  grid.BackColor = SUBFUNCTION_BACK_COLOR
  grid.SelectBackColor = SUBFUNCTION_SELECT_COLOR
  grid.HeaderBackColor = SUBFUNCTION_HEAD_COLOR
  local title = nx_execute("form_task\\form_subtask_overview", "key_to_title", type)
  if title == "" then
    return grid
  end
  if nx_is_valid(info_struct) then
    local step_tip = nx_string(index)
    if index == -2 then
      step_tip = "\206\222"
    end
    if index == -1 then
      step_tip = "\203\230\187\250"
    end
    grid:SetColTitle(0, nx_widestr(title .. "(\178\189\214\232:" .. nx_string(step_tip) .. ")"))
    local row
    local b_valid = false
    local question_info
    local item_count = info_struct:GetChildCount()
    for i = 0, item_count - 1 do
      local sect = info_struct:GetChildByIndex(i)
      local sect_count = sect:GetChildCount()
      if i ~= 0 then
        row = grid:InsertRow(-1)
        for j = 0, 2 do
          grid:SetGridBackColor(row, j, ID_FORE_COLOR)
        end
      end
      local task_seperate = nx_value("task_seperate")
      if nx_is_valid(task_seperate) and task_seperate:FindChild(type) then
        local type_item = task_seperate:GetChild(type)
        local type_item_count = type_item:GetChildCount()
        for j = 0, type_item_count - 1 do
          local item = type_item:GetChildByIndex(j)
          if item.Name ~= "NULL" then
            for k = 0, sect_count - 1 do
              local sect_item = sect:GetChildByIndex(k)
              if sect_item.Name == item.Name then
                row = grid:InsertRow(-1)
                grid:SetGridText(row, 0, nx_widestr(item.Name))
                grid:SetGridText(row, 1, nx_widestr(item.desc))
                grid:SetGridText(row, 2, nx_widestr(sect_item.item_name))
                local tag = nx_create("ArrayList", nx_current())
                tag.number = i
                grid:SetGridTag(row, 2, tag)
                break
              end
            end
          end
        end
      end
      if "question" == type then
        prop = sect:GetChild("QuestionID")
        question_info = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", "questiongroup", prop.item_name)
        if nx_is_valid(question_info) then
          local question_list = question_info:GetChildList()
          for m = 1, table.getn(question_list) do
            local question_item = question_list[m]
            if nx_is_valid(question_item) then
              local questions = question_item:GetChildList()
              for n = 1, table.getn(questions) do
                if "" ~= questions[n].item_name and "ID" ~= questions[n].Name then
                  local row = grid:InsertRow(-1)
                  grid:SetGridText(row, 0, nx_widestr(questions[n].Name))
                  grid:SetGridText(row, 2, nx_widestr(questions[n].item_name))
                  local tag = nx_create("ArrayList", nx_current())
                  tag.question_item = question_item
                  tag.type = "questiongroup"
                  tag.id = prop.item_name
                  grid:SetGridTag(row, 2, tag)
                end
              end
              b_valid = true
            end
          end
        end
      end
    end
    if b_valid then
      row = grid:InsertRow(-1)
      local add_btn = CREATE_CONTROL("Button")
      add_btn.Text = nx_widestr(ADD_NEW_QUESTION_BTN_TITLE)
      grid:SetGridControl(row, 0, add_btn)
      add_btn.question_info = question_info
      nx_bind_script(add_btn, nx_current())
      nx_callback(add_btn, "on_click", "add_new_questiongroup_btn_click")
      local delete_btn = CREATE_CONTROL("Button")
      delete_btn.Text = nx_widestr(DELETE_LAST_QUESTION_BTN_TITLE)
      grid:SetGridControl(row, 1, delete_btn)
      delete_btn.type = "questiongroup"
      delete_btn.question_info = question_info
      nx_bind_script(delete_btn, nx_current())
      nx_callback(delete_btn, "on_click", "delete_last_questiongroup_btn_click")
    end
    if "story" == type then
      row = grid:InsertRow(-1)
      local add_btn = CREATE_CONTROL("Button")
      add_btn.Text = nx_widestr(ADD_SAME_ID_BTN_TITLE)
      grid:SetGridControl(row, 0, add_btn)
      local delete_btn = CREATE_CONTROL("Button")
      delete_btn.Text = nx_widestr(DELETE_SAME_ID_BTN_TITLE)
      grid:SetGridControl(row, 1, delete_btn)
      add_btn.type = type
      add_btn.id = info_struct.Name
      delete_btn.type = type
      delete_btn.id = info_struct.Name
      nx_bind_script(add_btn, nx_current())
      nx_callback(add_btn, "on_click", "on_add_same_id_btn_click")
      nx_bind_script(delete_btn, nx_current())
      nx_callback(delete_btn, "on_click", "on_delete_same_id_btn_click")
    end
    nx_bind_script(grid, nx_current())
    nx_callback(grid, "on_double_click_grid", "on_double_click_view_gird")
    nx_callback(grid, "on_right_select_grid", "grid_view_grid_right_select_grid")
    nx_callback(grid, "on_mousein_row_changed", "grid_mousein_row_changed")
  else
    grid:SetColTitle(0, nx_widestr(title .. ": id\178\187\180\230\212\218"))
  end
  return grid
end
local update_add_and_delete_info = function(type)
  local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
  if nx_is_valid(form_subtask_overview) then
    nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, type)
  end
  local task_form = nx_value("task_form")
  local subtask_process_form = task_form.subtask_process_form
  update_subtask_process(subtask_process_form, subtask_process_form.task_info)
  local text_form = nx_value("text_form")
  if nx_is_valid(text_form) then
    nx_execute("form_task\\form_text", "load_process_dialog_text", text_form, text_form.dialog_text_form.ctrlbox_step_text)
    nx_execute("form_task\\form_text", "load_trace_text", text_form, text_form.main_text_form.ctrlbox_track_text)
    if text_form.rbtn_code.Checked then
      nx_execute("form_task\\form_text", "rbtn_code_checked_changed", text_form.rbtn_code)
    else
      nx_execute("form_task\\form_text", "rbtn_preview_checked_changed", text_form.rbtn_preview)
    end
  end
  return 1
end
function on_delete_same_id_btn_click(self)
  local type = self.type
  local id = self.id
  local subtask_info = nx_value("subtask_info")
  local type_info = subtask_info:GetChild(type)
  if type_info:FindChild(id) then
    local id_sect = type_info:GetChild(id)
    local id_sect_count = id_sect:GetChildCount()
    if 1 < id_sect_count then
      id_sect:RemoveChildByIndex(id_sect_count - 1)
    elseif id_sect_count == 1 then
      type_info:RemoveChild(id)
    end
  end
  local gui = nx_value("gui")
  gui:Delete(self)
  update_add_and_delete_info(type)
  nx_execute("form_task\\form_task", "set_change", id, type)
  return 1
end
function on_add_same_id_btn_click(self)
  local type = self.type
  local id = self.id
  nx_execute("form_task\\form_subtask_overview", "create_subtask_info", type, id)
  local gui = nx_value("gui")
  gui:Delete(self)
  update_add_and_delete_info(type)
  nx_execute("form_task\\form_task", "set_change", id, type)
  return 1
end
function add_new_questiongroup_btn_click(self)
  local question_info = self.question_info
  local grid = self.Parent
  local prop = nx_string(grid:GetGridText(grid.RowCount - 2, 0))
  local index = 0
  local begin_index, end_index = string.find(prop, "questid")
  if begin_index ~= nil then
    index = nx_number(string.sub(prop, end_index + 1, string.len(prop)))
  end
  local new_prop = "questid" .. nx_string(index + 1)
  local question_list = question_info:GetChildList()
  for m = 1, table.getn(question_list) do
    local question_item = question_list[m]
    if nx_is_valid(question_item) then
      local questions = question_item:GetChild(new_prop)
      if nx_is_valid(questions) then
        local row = grid:InsertRow(grid.RowCount - 1)
        grid:SetGridText(row, 0, nx_widestr(new_prop))
        grid:SetGridText(row, 2, nx_widestr(questions.item_name))
        local tag = nx_create("ArrayList", nx_current())
        tag.question_item = question_item
        tag.type = "questiongroup"
        tag.id = question_info.Name
        grid:SetGridTag(row, 2, tag)
        grid.Height = grid.Height + grid.RowHeight
      end
    end
  end
  return 1
end
function delete_last_questiongroup_btn_click(self)
  local type = self.type
  local question_info = self.question_info
  local grid = self.Parent
  local prop = nx_string(grid:GetGridText(grid.RowCount - 2, 0))
  local value = nx_string(grid:GetGridText(grid.RowCount - 2, 2))
  local begin_index, end_index = string.find(prop, "questid")
  if begin_index ~= nil then
    local question_list = question_info:GetChildList()
    for m = 1, table.getn(question_list) do
      local question_item = question_list[m]
      if nx_is_valid(question_item) then
        local questions = question_item:GetChild(prop)
        if nx_is_valid(questions) then
          questions.item_name = ""
          grid:DeleteRow(grid.RowCount - 2)
          grid.Height = grid.Height - grid.RowHeight
          local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
          if nx_is_valid(form_subtask_overview) and form_subtask_overview.Visible and form_subtask_overview.grid_type == type then
            nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, type)
            select_grid_by_key(form_subtask_overview.overview_grid, question_info.Name)
          end
          if value ~= "" then
            nx_execute("form_task\\form_task", "set_change", question_info.Name, type)
          end
        end
      end
    end
  end
end
function grid_mousein_row_changed(self, row)
  nx_execute("form_task\\form_tips", "close_tips")
  return 1
end
function grid_view_grid_right_select_grid(grid, new_row, new_col)
  local gui = nx_value("gui")
  nx_execute("form_task\\form_tips", "close_tips")
  local info = ""
  if 0 <= new_row then
    local name = nx_string(grid:GetGridText(new_row, 0))
    local item = nx_execute("form_task\\form_task", "get_seperate_item", grid.grid_type, name)
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
function on_double_click_view_gird(self, row, col)
  local gui = nx_value("gui")
  if self:GetGridText(row, 0) == nx_widestr("") then
    return 0
  end
  if col == 2 and self:GetGridText(row, 0) ~= nx_widestr("ID") then
    local edit_ctl = CREATE_CONTROL("Edit")
    edit_ctl.Text = self:GetGridText(row, col)
    edit_ctl.BackColor = EDIT_COLOR
    self:SetGridControl(row, col, edit_ctl)
    edit_ctl.grid = self
    edit_ctl.row = row
    gui.Focused = edit_ctl
    nx_bind_script(edit_ctl, nx_current())
    nx_callback(edit_ctl, "on_lost_focus", "view_grid_edit_ctl_on_lost_focus")
    nx_callback(edit_ctl, "on_enter", "view_grid_edit_ctl_on_lost_focus")
  end
  return 1
end
function update_refreshmonster_and_taskitemlist_form()
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    nx_execute("form_task\\form_monster_list", "update_monster_list", task_form.monster_list_form, task_form.task_info)
    nx_execute("form_task\\form_tool_list", "update_tool_list", task_form.tool_list_form, task_form.task_info)
  end
end
function view_grid_edit_ctl_on_lost_focus(self)
  local grid = self.grid
  local row = self.row
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if not nx_is_valid(task_form.sect_node) then
    return 0
  end
  local ctl = grid:GetGridControl(row, 2)
  if nx_is_valid(ctl) then
    local modify_key = nx_string(grid:GetGridText(row, 0))
    local modify_value = nx_string(ctl.Text)
    grid:ClearGridControl(row, 2)
    local info_struct = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", grid.grid_type, grid.grid_id)
    local tag = grid:GetGridTag(row, 2)
    if nx_find_custom(tag, "number") then
      local number = tag.number
      local sect = info_struct:GetChildByIndex(number)
      local item = sect:GetChild(modify_key)
      if nx_is_valid(item) and item.item_name ~= modify_value then
        if modify_key == "RefreshMonster" then
          local ret = ask_form_create_new_item("RefreshMonster", modify_value)
          if not ret then
            return 0
          end
        elseif modify_key == "TaskItemList" then
          local ret = ask_form_create_new_item("TaskItem", modify_value)
          if not ret then
            return 0
          end
        elseif modify_key == "PathID" then
          local ret = ask_form_delete_old_item("ConvoyPoint", item.item_name)
          if not ret then
            return 0
          end
          local ret = ask_form_create_new_item("ConvoyPoint", modify_value)
          if not ret then
            return 0
          end
        end
        grid:SetGridText(row, 2, nx_widestr(modify_value))
        set_modify_subtask_overview("grid_subtask_process_task_info", grid.grid_type, grid.grid_id, modify_key, number, item.item_name, modify_value)
        item.item_name = modify_value
        local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
        if nx_is_valid(form_subtask_overview) and form_subtask_overview.Visible and form_subtask_overview.grid_type == grid.grid_type then
          nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, grid.grid_type)
          select_grid_by_key(form_subtask_overview.overview_grid, grid.grid_id)
        end
        if modify_key == "RefreshMonster" or modify_key == "TaskItemList" then
          update_refreshmonster_and_taskitemlist_form()
        end
        nx_execute("form_task\\form_task", "set_change", grid.grid_id, grid.grid_type)
        if "QuestionID" == modify_key then
          if "" ~= modify_value then
            local info_array_list = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", "questiongroup", modify_value)
            if not nx_is_valid(info_array_list) then
              local gui = nx_value("gui")
              local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_yes_no_cancel.xml")
              dialog.info_label.Text = nx_widestr("\202\199\183\241\208\194\189\168\204\226\215\233?")
              dialog:ShowModal()
              local res = nx_wait_event(100000000, dialog, "yes_no_cancel_return")
              if "yes" == res then
                nx_execute("form_task\\form_subtask_overview", "create_subtask_info", "questiongroup", modify_value)
                local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
                if nx_is_valid(form_subtask_overview) and form_subtask_overview.Visible and form_subtask_overview.grid_type == "questiongroup" then
                  nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, "questiongroup")
                end
                nx_execute("form_task\\form_task", "set_change", modify_value, "questiongroup")
              end
            end
          end
          if nx_is_valid(task_form.subtask_process_form) then
            nx_execute("form_task\\form_subtask_process", "update_subtask_process_view", task_form.subtask_process_form)
          end
        end
      end
    elseif nx_find_custom(tag, "question_item") then
      local question_item = tag.question_item
      local item = question_item:GetChild(modify_key)
      if nx_is_valid(item) and item.item_name ~= modify_value then
        if string.find(modify_key, "questid") then
          local child = task_form.sect_node:GetChild("questions")
          local result, error = is_in_range(modify_value, child)
          if not result then
            nx_msgbox("\206\202\204\226ID " .. modify_value .. " " .. error)
            return false
          end
        end
        item.item_name = modify_value
        grid:SetGridText(row, 2, nx_widestr(modify_value))
        local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
        if nx_is_valid(form_subtask_overview) and form_subtask_overview.Visible and form_subtask_overview.grid_type == tag.type then
          nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, tag.type)
          select_grid_by_key(form_subtask_overview.overview_grid, tag.id)
        end
        nx_execute("form_task\\form_task", "set_change", tag.id, tag.type)
      end
    end
  end
  return 1
end
function update_subtask_process_view(form)
  local list_grid = form.process_list_grid
  local view_controlbox = form.process_view_ctlbox
  view_controlbox:ClearControl()
  for i = 0, list_grid.RowCount - 1 do
    local type = nx_string(list_grid:GetGridText(i, 1))
    local id = nx_string(list_grid:GetGridText(i, 2))
    local info_struct = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", type, id)
    local col_width = list_grid.ColWidth * list_grid.ColCount / 3
    local new_grid = create_grid(col_width, get_process_number(list_grid, i), type, info_struct)
    local rel_order = get_process_number(list_grid, i)
    local step_tip = nx_string(rel_order)
    if rel_order == -2 then
      step_tip = "\206\222"
    end
    if rel_order == -1 then
      step_tip = "\203\230\187\250"
    end
    if nx_is_valid(new_grid) then
      new_grid.HeaderRowHeight = new_grid.RowHeight
      new_grid.Height = new_grid.RowHeight * new_grid.RowCount + new_grid.HeaderRowHeight
      new_grid.Width = list_grid.Width
      new_grid.grid_id = id
      new_grid.grid_type = type
      new_grid.progress = i
      view_controlbox:AddControl(new_grid)
    end
  end
  view_controlbox.ScrollSmooth = true
  return 1
end
function update_subtask_process(form, task_info)
  local grid = form.process_list_grid
  grid.cur_editor_row = -1
  grid:ClearRow()
  update_subtask_process_view(form)
  if not nx_is_valid(task_info) then
    grid.current_task_id = ""
    return 0
  end
  form.task_info = task_info
  local task_id = task_info.ID
  grid.current_task_id = task_id
  local subtask_pro_info = nx_value(SUBTASK_PROCESS_INFO)
  if not nx_is_valid(subtask_pro_info) then
    return 0
  end
  local task_step_info = subtask_pro_info:GetChild(task_id)
  if not nx_is_valid(task_step_info) then
    return 0
  end
  local task_step_info_count = task_step_info:GetChildCount()
  local row
  for i = 0, task_step_info_count - 1 do
    local info = task_step_info:GetChildByIndex(i)
    row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(info.order))
    grid:SetGridText(row, 1, nx_widestr(info.type))
    grid:SetGridText(row, 2, nx_widestr(info.subfunction))
    local desc = nx_execute("form_task\\form_subtask_overview", "key_to_title", info.type)
    grid:SetGridText(row, 3, nx_widestr(desc))
  end
  grid:ClearSelect()
  update_subtask_process_view(form)
  return 1
end
local function update_globle(grid, task_id)
  local subtask_pro_info = nx_value(SUBTASK_PROCESS_INFO)
  local subtask_info = subtask_pro_info:GetChild(task_id)
  subtask_info:ClearChild()
  for i = 0, grid.RowCount - 1 do
    local order = nx_string(grid:GetGridText(i, 0))
    local type = nx_string(grid:GetGridText(i, 1))
    local subfunction = nx_string(grid:GetGridText(i, 2))
    local item = subtask_info:CreateChild(nx_string(i))
    item.order = order
    item.type = type
    item.subfunction = subfunction
  end
  return 1
end
local function level_process_list_selected_row(grid, row)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if not nx_is_valid(task_form.sect_node) then
    return 0
  end
  local is_changed = false
  local pre_type = nx_string(grid:GetGridText(row, 1))
  local pre_id = nx_string(grid:GetGridText(row, 2))
  local edit_type = nx_string(grid:GetGridControl(row, 1).Text)
  local edit_id = nx_string(grid:GetGridControl(row, 2).Text)
  local info_struct = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", edit_type, edit_id)
  local pre_info_struct = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", pre_type, pre_id)
  local old_order = nx_string(grid:GetGridText(row, 0))
  local old_type = nx_string(grid:GetGridText(row, 1))
  local old_id = nx_string(grid:GetGridText(row, 2))
  if not nx_is_valid(info_struct) then
    local gui = nx_value("gui")
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_yes_no_cancel.xml")
    local msg_info = ""
    if edit_id == "" or edit_type == "" then
      msg_info = ""
      if edit_id == "" then
        msg_info = msg_info .. "ID\206\222\208\167"
      end
      if edit_type == "" then
        msg_info = msg_info .. " Type\206\222\208\167"
      end
      dialog.yes_btn.Enabled = false
    else
      local child = task_form.sect_node:GetChild(type_list[edit_type][1])
      if nx_is_valid(child) then
        msg_info = "\202\199\183\241\208\194\189\168\215\211\185\166\196\220ID?"
        local result, error = is_in_range(edit_id, child)
        if not result then
          msg_info = "\215\211\185\166\196\220ID " .. error
        end
      else
        return 0
      end
    end
    dialog.info_label.Text = nx_widestr(msg_info)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "yes_no_cancel_return")
    if "cancel" == res then
      return 0
    elseif "yes" == res then
      nx_execute("form_task\\form_subtask_overview", "create_subtask_info", edit_type, edit_id)
      local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
      if nx_is_valid(form_subtask_overview) and form_subtask_overview.Visible and form_subtask_overview.grid_type == edit_type then
        nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, edit_type)
      end
      nx_execute("form_task\\form_task", "set_change", edit_id, edit_type)
    else
      for i = 0, 2 do
        grid:ClearGridControl(row, i)
      end
      if not nx_is_valid(pre_info_struct) then
        grid:DeleteRow(row)
      end
      is_changed = true
    end
  end
  local new_order_ctl = grid:GetGridControl(row, 0)
  local new_type_ctl = grid:GetGridControl(row, 1)
  local new_id_ctl = grid:GetGridControl(row, 2)
  if nx_is_valid(new_order_ctl) and nx_is_valid(new_type_ctl) and nx_is_valid(new_id_ctl) then
    local new_order = nx_string(new_order_ctl.Text)
    local new_type = nx_string(new_type_ctl.Text)
    local new_id = nx_string(new_id_ctl.Text)
    if 0 > nx_number(new_order) and nx_number(new_order) ~= -1 then
      new_order = ""
    end
    if old_order ~= new_order or old_type ~= new_type or old_id ~= new_id then
      is_changed = true
      grid:SetGridText(row, 0, nx_widestr(new_order))
      grid:SetGridText(row, 1, nx_widestr(new_type))
      grid:SetGridText(row, 2, nx_widestr(new_id))
      if old_type ~= "" then
        set_modify_process(grid.current_task_id, row, old_order, old_type, old_id, new_order, new_type, new_id)
      end
    end
    for i = 0, 2 do
      grid:ClearGridControl(row, i)
    end
  end
  update_globle(grid, grid.current_task_id)
  update_refreshmonster_and_taskitemlist_form()
  local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
  if nx_is_valid(form_subtask_overview) then
    nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, form_subtask_overview.grid_type)
  end
  update_subtask_process_view(grid.Parent)
  if is_changed then
    nx_execute("form_task\\form_task", "set_change", grid.current_task_id, SUBTASK_PROCESS_INFO)
  end
  return 1
end
function process_list_grid_select_row(self, row)
  if self.cur_editor_row == row then
    return 0
  elseif self.cur_editor_row ~= -1 then
    ret = level_process_list_selected_row(self, self.cur_editor_row)
    if ret == 0 then
      return 0
    end
  end
  self.cur_editor_row = -1
  return 1
end
function on_input_enter(self)
  local grid, row
  if nx_find_custom(self, "grid") then
    grid = self.grid
    row = self.row
  else
    grid = self.Parent.grid
    row = self.Parent.row
  end
  local ret = level_process_list_selected_row(grid, row)
  if ret == 0 then
    return 0
  end
  grid:ClearSelect()
  grid.cur_editor_row = -1
  return 1
end
function process_list_grid_double_click_grid(self, row, col)
  if self.cur_editor_row == row then
    return 0
  elseif self.cur_editor_row ~= -1 then
    local ret = level_process_list_selected_row(self, self.cur_editor_row)
    if ret == 0 then
      return 0
    end
  end
  local gui = nx_value("gui")
  for i = 0, self.ColCount - 1 do
    if i == 0 or i == 2 then
      local edit_ctl = CREATE_CONTROL("Edit")
      edit_ctl.Text = self:GetGridText(row, i)
      edit_ctl.BackColor = EDIT_COLOR
      if i == 0 then
        edit_ctl.OnlyDigit = true
      end
      self:SetGridControl(row, i, edit_ctl)
      edit_ctl.grid = self
      edit_ctl.row = row
      if col == i then
        gui.Focused = edit_ctl
      end
      nx_bind_script(edit_ctl, nx_current())
      nx_callback(edit_ctl, "on_enter", "on_input_enter")
    elseif i == 1 then
      local subtask_title_info = nx_value("subtask_title_info")
      local title_list = subtask_title_info:GetChildList()
      local title_count = table.getn(title_list)
      local combo_box = CREATE_CONTROL("ComboBox")
      for i = 1, title_count do
        if 0 < title_list[i]:GetChildCount() and "questiongroup" ~= title_list[i].Name then
          combo_box.DropListBox:AddString(nx_widestr(title_list[i].Name))
        end
      end
      combo_box.DropDownHeight = title_count * 10
      combo_box.InputEdit.Text = self:GetGridText(row, 1)
      combo_box.InputEdit.ReadOnly = true
      combo_box.InputEdit.BackColor = EDIT_COLOR
      combo_box.DropListBox.BackColor = EDIT_COLOR
      combo_box.DropListBox.Height = 80
      self:SetGridControl(row, i, combo_box)
      combo_box.grid = self
      combo_box.row = row
      if col == i then
        gui.Focused = combo_box.InputEdit
      end
      nx_bind_script(combo_box.InputEdit, nx_current())
      nx_callback(combo_box.InputEdit, "on_enter", "on_input_enter")
      nx_bind_script(combo_box, nx_current())
      nx_callback(combo_box, "on_selected", "on_combo_select_changed")
    end
  end
  self.cur_editor_row = row
  return 1
end
function on_combo_select_changed(self)
  local grid = self.grid
  local type = nx_string(self.Text)
  local desc = nx_execute("form_task\\form_subtask_overview", "key_to_title", type)
  grid:SetGridText(self.row, 3, nx_widestr(desc))
  local ctl = grid:GetGridControl(self.row, 2)
  ctl.Text = nx_widestr("")
  return 1
end
function sort_btn_click(self)
  local form = self.Parent
  local process_list_grid = form.process_list_grid
  local temp_list = {}
  local index = 1
  for i = 0, process_list_grid.RowCount - 1 do
    local data = {}
    data.order = process_list_grid:GetGridText(i, 0)
    data.type = process_list_grid:GetGridText(i, 1)
    data.pro_id = process_list_grid:GetGridText(i, 2)
    data.desc = process_list_grid:GetGridText(i, 3)
    temp_list[index] = data
    index = index + 1
  end
  for i = 1, index - 1 do
    for j = i + 1, index - 1 do
      if nx_number(temp_list[i].order) > nx_number(temp_list[j].order) then
        local temp = temp_list[i]
        temp_list[i] = temp_list[j]
        temp_list[j] = temp
      end
    end
  end
  for i = 0, process_list_grid.RowCount - 1 do
    process_list_grid:SetGridText(i, 0, temp_list[i + 1].order)
    process_list_grid:SetGridText(i, 1, temp_list[i + 1].type)
    process_list_grid:SetGridText(i, 2, temp_list[i + 1].pro_id)
    process_list_grid:SetGridText(i, 3, temp_list[i + 1].desc)
  end
  update_subtask_process_view(form)
  return 1
end
function add_subtask_process_btn_click(self)
  local form = self.Parent
  local process_list_grid = form.process_list_grid
  if process_list_grid.current_task_id == "" then
    return 0
  end
  if process_list_grid.cur_editor_row ~= -1 then
    return 0
  end
  local subtask_pro_info = nx_value(SUBTASK_PROCESS_INFO)
  local task_id = process_list_grid.current_task_id
  local subtask_info = subtask_pro_info:GetChild(process_list_grid.current_task_id)
  if subtask_pro_info:FindChild(task_id) then
    subtask_info = subtask_pro_info:GetChild(task_id)
  else
    subtask_info = subtask_pro_info:CreateChild(task_id)
  end
  local row = process_list_grid:InsertRow(-1)
  process_list_grid_double_click_grid(process_list_grid, row)
  process_list_grid:SelectRow(row)
  return 1
end
function del_subtask_process_btn_click(self)
  local form = self.Parent
  local process_list_grid = form.process_list_grid
  if process_list_grid.current_task_id == "" then
    return 0
  end
  local row = process_list_grid.RowSelectIndex
  local subtask_pro_info = nx_value(SUBTASK_PROCESS_INFO)
  local subtask_info = subtask_pro_info:GetChild(process_list_grid.current_task_id)
  if not nx_is_valid(subtask_info) then
    return 0
  end
  if not show_confirm_box("\202\199\183\241\201\190\179\253\163\191") then
    return 0
  end
  for i = 0, subtask_info:GetChildCount() - 1 do
    local info = subtask_info:GetChildByIndex(i)
    local del_order = nx_string(process_list_grid:GetGridText(row, 0))
    local del_type = nx_string(process_list_grid:GetGridText(row, 1))
    local del_subfunction = nx_string(process_list_grid:GetGridText(row, 2))
    if info.type == del_type and info.subfunction == del_subfunction and info.order == del_order then
      subtask_info:RemoveChildByIndex(i)
      process_list_grid:DeleteRow(row)
      process_list_grid.cur_editor_row = -1
      nx_execute("form_task\\form_task", "set_change", process_list_grid.current_task_id, SUBTASK_PROCESS_INFO)
      update_subtask_process_view(form)
      update_refreshmonster_and_taskitemlist_form()
      break
    end
  end
  return 1
end
function save_subfunction_info()
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild("SubFunction")
    if nx_is_valid(child) then
      local work_path = nx_value("work_path")
      local text_grid = nx_create("TextGrid")
      text_grid.FileName = work_path .. child.file_name
      if not text_grid:LoadFromFile(2) then
        nx_destroy(text_grid)
        return 0
      end
      local changes_list = nx_value("changes_list")
      if nx_is_valid(changes_list) and changes_list:FindChild(SUBTASK_PROCESS_INFO) then
        local subtask_pro_info = nx_value(SUBTASK_PROCESS_INFO)
        local changed_subtask_process_info = changes_list:GetChild(SUBTASK_PROCESS_INFO)
        local list = changed_subtask_process_info:GetChildList()
        for i = 1, table.getn(list) do
          local task_id = list[i].info
          if subtask_pro_info:FindChild(task_id) then
            local subtask_info = subtask_pro_info:GetChild(task_id)
            text_grid:RemoveRowByKey(0, task_id)
            for j = 0, subtask_info:GetChildCount() - 1 do
              local info = subtask_info:GetChildByIndex(j)
              local type = info.type
              local subfunction = info.subfunction
              local order = info.order
              local new_row = text_grid:AddRow(task_id)
              text_grid:SetValueString(nx_int(new_row), "Type", type)
              text_grid:SetValueString(nx_int(new_row), "TypeID", subfunction)
              text_grid:SetValueString(nx_int(new_row), "Order", order)
            end
          else
            text_grid:RemoveRowByKey(0, task_id)
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
  return 1
end
function get_use_subtask_task_id(type, id)
  local subtask_pro_info = nx_value(SUBTASK_PROCESS_INFO)
  local subtask_pro_info_count = subtask_pro_info:GetChildCount()
  local used_task_id_list = ""
  for i = 0, subtask_pro_info_count - 1 do
    local subtask_info = subtask_pro_info:GetChildByIndex(i)
    local subtask_info_count = subtask_info:GetChildCount()
    for j = 0, subtask_info_count - 1 do
      local item = subtask_info:GetChildByIndex(j)
      if item.type == type and item.subfunction == id then
        used_task_id_list = used_task_id_list .. "," .. subtask_info.Name
      end
    end
  end
  local len = string.len(used_task_id_list)
  return string.sub(used_task_id_list, 2, len)
end
function convoypoint_btn_click(self)
  nx_execute("form_task\\form_path_overview", "show_path_overview_form", "")
  return 1
end
function delete_task_subfunction(task_id)
  local subtask_pro_info = nx_value(SUBTASK_PROCESS_INFO)
  if nx_is_valid(subtask_pro_info) then
    subtask_pro_info:RemoveChild(task_id)
    nx_execute("form_task\\form_task", "set_change", task_id, SUBTASK_PROCESS_INFO)
  end
  return 1
end
