require("form_task\\common")
require("form_task\\public_svn")
require("form_task\\form_task")
function main_form_open(self)
  load_task_type_ini(self)
  load_task_info(self)
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function load_task_type_ini(form)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return false
  end
  local ini = nx_create("IniDocument")
  ini.FileName = work_path .. TASK_TYPE_INI
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local tasktype_config = nx_value("tasktype_config")
  if not nx_is_valid(tasktype_config) then
    tasktype_config = nx_create("ArrayList", "tasktype_config")
    nx_set_value("tasktype_config", tasktype_config)
  else
    tasktype_config:ClearChild()
  end
  local sect_list = ini:GetSectionList()
  local sect_count = table.getn(sect_list)
  for i = 1, sect_count do
    local sect_name = sect_list[i]
    if nil == string.find(sect_name, "file") then
      local sect = tasktype_config:CreateChild(sect_name)
      local item_list = ini:GetItemList(sect_name)
      local item_count = table.getn(item_list)
      for j = 1, item_count do
        local item_name = item_list[j]
        local item = sect:CreateChild(item_name)
        item.flag = "data"
        item.value = ini:ReadString(sect_name, item_name, "")
      end
    end
  end
  for i = 1, sect_count do
    local sect_name = sect_list[i]
    local b_index, e_index = string.find(sect_name, "file")
    if nil ~= b_index then
      local num = string.sub(sect_name, 1, b_index - 1)
      local child_list = tasktype_config:GetChildList()
      for j = 1, table.getn(child_list) do
        if 1 == string.find(child_list[j].Name, num, 1, true) then
          local item_list = ini:GetItemList(sect_name)
          for k = 1, table.getn(item_list) do
            local item_name = item_list[k]
            local item = child_list[j]:CreateChild(item_name)
            if nil ~= string.find(item_name, "text") then
              item.flag = "client_file"
            elseif nil ~= string.find(item_name, "questions") or nil ~= string.find(item_name, "questiongroup") then
              item.flag = "question_file"
            else
              item.flag = "server_file"
            end
            local value = ini:ReadString(sect_name, item_name, "")
            local list = nx_function("ext_split_string", value, SPLIT_CHAR)
            if table.getn(list) > 0 then
              item.file_name = list[1]
            end
            for n = 3, table.getn(list), 2 do
              local child = item:CreateChild(list[n - 1])
              child.rule = list[n]
            end
          end
        end
      end
    end
  end
  nx_destroy(ini)
  return true
end
function clear_task_config()
  local task_config = nx_value("task_config")
  if nx_is_valid(task_config) then
    local item_list = task_config:GetChildList()
    for i = 1, table.getn(item_list) do
      local child_list = item_list[i]:GetChildList()
      for j = 1, table.getn(child_list) do
        child_list[j].loaded = false
      end
    end
  end
end
function load_task_info(form)
  local gui = nx_value("gui")
  local work_path = nx_value("work_path")
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    task_config = nx_create("ArrayList", "task_config")
    nx_set_value("task_config", task_config)
  end
  task_config:ClearChild()
  local tasktype_config = nx_value("tasktype_config")
  if not nx_is_valid(tasktype_config) then
    return 0
  end
  local imagelist = gui:CreateImageList()
  for _, item in pairs(SVN_LIST) do
    imagelist:AddImage(item)
  end
  form.task_list.ImageList = imagelist
  local root_node = form.task_list:CreateRootNode(nx_widestr("\200\206\206\241"))
  root_node.max_player = 0
  root_node.ImageIndex = -1
  root_node.sect_node = nil
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
        for k = 0, textgrid.RowCount - 1 do
          local id = nx_string(textgrid:GetValueString(nx_int(k), "ID"))
          if "" ~= id then
            local searchid = nx_string(textgrid:GetValueString(nx_int(k), "SearchID"))
            local task_item = task_config:GetChild(searchid)
            if not nx_is_valid(task_item) then
              task_item = task_config:CreateChild(searchid)
            end
            local task_child = task_item:GetChild(id)
            if nx_is_valid(task_child) then
              nx_msgbox("\205\172\210\187\184\246\213\194\187\216\211\208\214\216\184\180\200\206\206\241ID:" .. id)
            else
              task_child = task_item:CreateChild(id)
              task_child.file_name = file_name
              task_child.ID = id
              task_child.SearchID = searchid
              task_child.loaded = false
              task_child.RefreshMonster = nx_string(textgrid:GetValueString(nx_int(k), "RefreshMonster"))
              task_child.TaskItemList = nx_string(textgrid:GetValueString(nx_int(k), "TaskItemList"))
              task_child.TitleId = nx_string(textgrid:GetValueString(nx_int(k), "TitleId"))
              task_child.Line = nx_string(textgrid:GetValueString(nx_int(k), "Line"))
              task_child.AcceptNpc = nx_string(textgrid:GetValueString(nx_int(k), "AcceptNpc"))
              task_child.AcceptSceneID = nx_string(textgrid:GetValueString(nx_int(k), "AcceptSceneID"))
              task_child.AcceptArea = nx_string(textgrid:GetValueString(nx_int(k), "AcceptArea"))
              task_child.AcceptLimit = nx_string(textgrid:GetValueString(nx_int(k), "AcceptLimit"))
              task_child.AcceptDialogId = nx_string(textgrid:GetValueString(nx_int(k), "AcceptDialogId"))
              task_child.ContextId = nx_string(textgrid:GetValueString(nx_int(k), "ContextId"))
              task_child.NextTaskLimit = nx_string(textgrid:GetValueString(nx_int(k), "NextTaskLimit"))
            end
          end
        end
        nx_destroy(textgrid)
      end
    end
  end
  for i = 1, table.getn(child_list) do
    local p_list = nx_function("ext_split_string", child_list[i].Name, "_")
    local play_node = root_node:CreateNode(nx_widestr(p_list[2]))
    play_node.num = p_list[1]
    play_node.max_chapter = 0
    play_node.ImageIndex = -1
    play_node.sect_node = child_list[i]
    if nx_number(p_list[1]) > root_node.max_player then
      root_node.max_player = nx_number(p_list[1])
    end
    local item_list = child_list[i]:GetChildList()
    for j = 1, table.getn(item_list) do
      local flag = nx_custom(item_list[j], "flag")
      if "data" == flag then
        local c_list = nx_function("ext_split_string", item_list[j].Name, "_")
        local chapter_node = play_node:CreateNode(nx_widestr(c_list[2]))
        chapter_node.num = c_list[1]
        chapter_node.max_parter = 0
        chapter_node.ImageIndex = -1
        chapter_node.sect_node = child_list[i]
        if nx_number(c_list[1]) > play_node.max_chapter then
          play_node.max_chapter = nx_number(c_list[1])
        end
        local str_list = nx_function("ext_split_string", item_list[j].value, SPLIT_CHAR)
        for k = 1, table.getn(str_list) do
          local s_list = nx_function("ext_split_string", str_list[k], "_")
          if 1 < table.getn(s_list) then
            local parter_node = chapter_node:CreateNode(nx_widestr(s_list[2]))
            parter_node.num = s_list[1]
            parter_node.ImageIndex = -1
            parter_node.sect_node = child_list[i]
            if nx_number(s_list[1]) > chapter_node.max_parter then
              chapter_node.max_parter = nx_number(s_list[1])
            end
            local search_id = SEARCHID_BEGIN .. p_list[1] .. c_list[1] .. s_list[1]
            local task_item_list = task_config:GetChild(search_id)
            if nx_is_valid(task_item_list) then
              local task_child_list = task_item_list:GetChildList()
              for n = 1, table.getn(task_child_list) do
                local child = child_list[i]:GetChild("Task")
                if nx_is_valid(child) then
                  local result, error = is_in_range(task_child_list[n].ID, child)
                  if result then
                    local task_node = parter_node:CreateNode(nx_widestr(task_child_list[n].ID))
                    task_node.searchid = search_id
                    task_node.task_info = task_child_list[n]
                    task_node.sect_node = child_list[i]
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  root_node.Expand = true
  return 1
end
function task_list_select_changed(self, node)
  local form = self.Parent.Parent
  local gui = nx_value("gui")
  nx_execute("form_task\\menu_operation", "delete_right_button_menu")
  if form.sect_node == nil or node.sect_node == nil or not nx_id_equal(form.sect_node, node.sect_node) then
    if is_changed() then
      local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_yes_no_cancel.xml")
      dialog.info_label.Text = nx_widestr("\206\196\188\254\210\209\190\173\184\196\182\175\202\199\183\241\208\232\210\170\177\163\180\230\163\191")
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "yes_no_cancel_return")
      if "yes" == res then
        save_changes()
      else
        set_unchanged()
      end
    end
    clear_task_config()
    form.sect_node = node.sect_node
    nx_execute("form_task\\form_monster_overview", "load_monster_info")
    nx_execute("form_task\\form_tool_overview", "load_tool_info")
    nx_execute("form_task\\form_prize_overview", "load_prize_info")
    nx_execute("form_task\\form_prize_overview", "load_extra_prize_info")
    nx_execute("form_task\\form_subtask_process", "load_res")
    nx_execute("form_task\\form_subtask_overview", "load_resource")
    nx_execute("form_task\\form_path_overview", "load_path_info")
  end
  if nx_find_custom(node, "task_info") then
    form.task_info = node.task_info
    nx_execute("form_task\\form_task_info", "load_task_item", form.task_info)
  else
    form.task_info = nil
  end
  nx_execute("form_task\\form_task_info", "update_task_info", form.task_info_form, form.task_info)
  nx_execute("form_task\\form_monster_list", "update_monster_list", form.monster_list_form, form.task_info)
  local monster_overview_form = nx_value("monster_overview_form")
  if nx_is_valid(monster_overview_form) then
    nx_execute("form_task\\form_monster_overview", "update_monster_overview", monster_overview_form)
  end
  nx_execute("form_task\\form_tool_list", "update_tool_list", form.tool_list_form, form.task_info)
  local tool_overview_form = nx_value("tool_overview_form")
  if nx_is_valid(tool_overview_form) then
    nx_execute("form_task\\form_tool_overview", "update_tool_overview", tool_overview_form)
  end
  nx_execute("form_task\\form_subtask_process", "update_subtask_process", form.subtask_process_form, form.task_info)
  local form_subtask_overview = nx_value("form_task\\form_subtask_overview")
  if nx_is_valid(form_subtask_overview) then
    nx_execute("form_task\\form_subtask_overview", "update_subtask_grid", form_subtask_overview.overview_grid, form_subtask_overview.grid_type)
  end
  return 1
end
function task_list_right_click(self, node)
  local gui = nx_value("gui")
  local form = self.Parent
  local x, y = gui:GetCursorPosition()
  if nx_id_equal(node, self.RootNode) then
    nx_execute("form_task\\menu_operation", "right_click", "Task", x, y, node)
  elseif nx_is_valid(node.ParentNode) and nx_id_equal(node.ParentNode, self.RootNode) then
    nx_execute("form_task\\menu_operation", "right_click", "TaskLine", x, y, node)
  elseif nx_is_valid(node.ParentNode) and nx_is_valid(node.ParentNode.ParentNode) and nx_id_equal(node.ParentNode.ParentNode, self.RootNode) then
    nx_execute("form_task\\menu_operation", "right_click", "TaskChapter", x, y, node)
  elseif nx_is_valid(node.ParentNode) and nx_is_valid(node.ParentNode.ParentNode) and nx_is_valid(node.ParentNode.ParentNode.ParentNode) and nx_id_equal(node.ParentNode.ParentNode.ParentNode, self.RootNode) then
    nx_execute("form_task\\menu_operation", "right_click", "TaskParter", x, y, node)
  elseif nx_is_valid(node.ParentNode) and nx_is_valid(node.ParentNode.ParentNode) and nx_is_valid(node.ParentNode.ParentNode.ParentNode) and nx_is_valid(node.ParentNode.ParentNode.ParentNode.ParentNode) and nx_id_equal(node.ParentNode.ParentNode.ParentNode.ParentNode, self.RootNode) then
    nx_execute("form_task\\menu_operation", "right_click", "TaskDetail", x, y, node)
  end
  return 1
end
function show_input_box(title)
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_input.xml")
  dialog.lbl_2.Text = nx_widestr(title)
  dialog.input_edit.OnlyDigit = false
  dialog.allow_empty = false
  dialog:ShowModal()
  local res, name = nx_wait_event(100000000, dialog, "form_input_return")
  return res, name
end
function add_task_line(node)
  local form = nx_value("task_form")
  if not nx_is_valid(form) then
    return 0
  end
  local res, task_player = show_input_box("\208\194\189\168\214\247\214\167\207\223\200\206\206\241")
  if res == "ok" then
    node.max_player = node.max_player + 1
    local new_task_player = string.format("%02d", node.max_player) .. "_" .. task_player
    local work_path = nx_value("work_path")
    if "" == work_path then
      return false
    end
    local ini = nx_create("IniDocument")
    ini.FileName = work_path .. TASK_TYPE_INI
    ini:LoadFromFile()
    ini:AddSection(new_task_player)
    ini:SaveToFile()
    nx_destroy(ini)
    local tasktype_config = nx_value("tasktype_config")
    if not nx_is_valid(tasktype_config) then
      nx_msgbox("\204\237\188\211\179\246\180\237")
      return 0
    end
    tasktype_config:CreateChild(new_task_player)
    local new_node = node:CreateNode(nx_widestr(task_player))
    new_node.max_chapter = 0
    new_node.num = string.format("%02d", node.max_player)
    new_node.sect_node = nil
    new_node.ImageIndex = -1
  end
  return 1
end
function add_task_chapter(node)
  local form = nx_value("task_form")
  if not nx_is_valid(form) then
    return 0
  end
  local task_player = nx_string(node.Text)
  local new_task_player = node.num .. "_" .. task_player
  local res, task_chapter = show_input_box("\208\194\189\168\213\194\189\218\200\206\206\241")
  if res == "ok" then
    node.max_chapter = node.max_chapter + 1
    local new_task_chapter = string.format("%02d", node.max_chapter) .. "_" .. task_chapter
    local work_path = nx_value("work_path")
    if "" == work_path then
      return false
    end
    local ini = nx_create("IniDocument")
    ini.FileName = work_path .. TASK_TYPE_INI
    ini:LoadFromFile()
    ini:WriteString(new_task_player, new_task_chapter, "")
    ini:SaveToFile()
    nx_destroy(ini)
    local tasktype_config = nx_value("tasktype_config")
    if not nx_is_valid(tasktype_config) then
      nx_msgbox("\204\237\188\211\179\246\180\237")
      return 0
    end
    local sect = tasktype_config:GetChild(new_task_player)
    if nx_is_valid(sect) then
      sect:CreateChild(new_task_chapter)
    else
      nx_msgbox("\204\237\188\211\202\167\176\220")
      return 0
    end
    local new_node = node:CreateNode(nx_widestr(task_chapter))
    new_node.max_parter = 0
    new_node.num = string.format("%02d", node.max_chapter)
    new_node.sect_node = node.sect_node
    new_node.ImageIndex = -1
  end
  return 1
end
function change_task_parter_name(node)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return 0
  end
  local res, name = show_input_box("\202\228\200\235\213\194\187\216\195\251\215\214")
  if res == "ok" then
    local task_parter = nx_string(node.Text)
    local task_player = node.ParentNode.ParentNode
    local task_chapter = node.ParentNode
    local new_task_player = task_player.num .. "_" .. nx_string(task_player.Text)
    local new_task_chapter = task_chapter.num .. "_" .. nx_string(task_chapter.Text)
    local ini = nx_create("IniDocument")
    ini.FileName = work_path .. TASK_TYPE_INI
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return 0
    end
    local item_value = ini:ReadString(new_task_player, new_task_chapter, "")
    local new_value = ""
    local pos = string.find(item_value, task_parter)
    if pos ~= nil then
      local pre_value = string.sub(item_value, 1, pos - 1)
      local aft_value = string.sub(item_value, pos + string.len(task_parter), string.len(item_value))
      new_value = pre_value .. name .. aft_value
    end
    ini:WriteString(new_task_player, new_task_chapter, new_value)
    ini:SaveToFile()
    nx_destroy(ini)
    local tasktype_config = nx_value("tasktype_config")
    local sect = tasktype_config:GetChild(new_task_player)
    if nx_is_valid(sect) then
      local item = sect:GetChild(new_task_chapter)
      if nx_is_valid(item) then
        item.value = new_value
      end
    end
    node.Text = nx_widestr(name)
  end
  return 1
end
function add_task_parter(node)
  local form = nx_value("task_form")
  if not nx_is_valid(form) then
    return 0
  end
  local task_player = nx_string(node.ParentNode.Text)
  local new_task_player = node.ParentNode.num .. "_" .. task_player
  local task_chapter = nx_string(node.Text)
  local new_task_chapter = node.num .. "_" .. task_chapter
  local res, task_parter = show_input_box("\208\194\189\168\213\194\187\216\200\206\206\241")
  if res == "ok" then
    node.max_parter = node.max_parter + 1
    local new_task_parter = string.format("%02d", node.max_parter) .. "_" .. task_parter
    local work_path = nx_value("work_path")
    if "" == work_path then
      return false
    end
    local ini = nx_create("IniDocument")
    ini.FileName = work_path .. TASK_TYPE_INI
    ini:LoadFromFile()
    local item_value = ini:ReadString(new_task_player, new_task_chapter, "")
    if item_value == "" then
      item_value = new_task_parter
    else
      item_value = item_value .. SPLIT_CHAR .. new_task_parter
    end
    ini:WriteString(new_task_player, new_task_chapter, item_value)
    ini:SaveToFile()
    nx_destroy(ini)
    local tasktype_config = nx_value("tasktype_config")
    if not nx_is_valid(tasktype_config) then
      nx_msgbox("\204\237\188\211\179\246\180\237")
      return 0
    end
    local sect = tasktype_config:GetChild(new_task_player)
    if nx_is_valid(sect) then
      local item = sect:GetChild(new_task_chapter)
      if nx_is_valid(item) then
        item.value = item_value
      else
        nx_msgbox("\204\237\188\211\202\167\176\2201")
        return 0
      end
    else
      nx_msgbox("\204\237\188\211\202\167\176\2202")
      return 0
    end
    local new_node = node:CreateNode(nx_widestr(task_parter))
    new_node.num = string.format("%02d", node.max_parter)
    new_node.sect_node = node.sect_node
    new_node.ImageIndex = -1
  end
  return 1
end
function insert_task_detail(node, task_node)
  local form = nx_value("task_form")
  if not nx_is_valid(form) then
    return 0
  end
  local res, task_id = show_input_box("\208\194\189\168\200\206\206\241")
  if res == "ok" then
    local task_config = nx_value("task_config")
    if not nx_is_valid(task_config) then
      nx_msgbox("\204\237\188\211\179\246\180\2371")
      return 0
    end
    if not nx_is_valid(node.sect_node) then
      nx_msgbox("\206\180\197\228\214\195\206\196\188\254")
      return 0
    end
    local child = node.sect_node:GetChild("Task")
    if not nx_is_valid(child) then
      nx_msgbox("\206\180\197\228\214\195Task\206\196\188\254")
      return 0
    end
    local file_name = child.file_name
    local result, error = is_in_range(task_id, child)
    if not result then
      nx_msgbox("\200\206\206\241ID " .. error)
      return 0
    end
    local b_exist = false
    local item_list = task_config:GetChildList()
    for i = 1, table.getn(item_list) do
      local child = item_list[i]:GetChild(task_id)
      if nx_is_valid(child) then
        b_exist = true
        break
      end
    end
    if b_exist then
      nx_msgbox("\200\206\206\241ID(" .. task_id .. ")\214\216\184\180\163\172\180\180\189\168\202\167\176\220")
      return 0
    end
    local searchid = SEARCHID_BEGIN .. node.ParentNode.ParentNode.num .. node.ParentNode.num .. node.num
    local task_item = task_config:GetChild(searchid)
    if not nx_is_valid(task_item) then
      task_item = task_config:CreateChild(searchid)
    end
    local task_child
    if task_node ~= nil then
      local index = task_item:GetChildIndex(nx_string(task_node.Text))
      task_child = task_item:InsertNewChild(task_id, index)
    else
      task_child = task_item:CreateChild(task_id)
    end
    task_child.file_name = file_name
    task_child.ID = task_id
    task_child.SearchID = searchid
    task_child.loaded = false
    set_change(task_child, TASK)
    local new_node
    if task_node ~= nil then
      new_node = nx_create("TreeNode")
      new_node.Text = nx_widestr(task_id)
      node:InsertBeforeNode(new_node, task_node)
    else
      new_node = node:CreateNode(nx_widestr(task_id))
    end
    new_node.searchid = searchid
    new_node.task_info = task_child
    new_node.sect_node = node.sect_node
  end
  return 1
end
function delete_task_line(node)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return 0
  end
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    return 0
  end
  local file_name = ""
  local state = false
  local new_task_player = node.num .. "_" .. nx_string(node.Text)
  local res = show_confirm_box("\202\199\183\241\201\190\179\253\214\247\214\167\207\223\200\206\206\241 " .. nx_string(node.Text) .. " \188\176\198\228\207\194\203\249\211\208\200\206\206\241?")
  if res then
    local node_list = node:GetNodeList()
    for i = 1, table.getn(node_list) do
      child_list = node_list[i]:GetNodeList()
      for j = 1, table.getn(child_list) do
        task_list = child_list[j]:GetNodeList()
        for k = 1, table.getn(task_list) do
          local node = task_list[k]
          local task_id = nx_string(node.Text)
          local searchid = SEARCHID_BEGIN .. node.ParentNode.ParentNode.ParentNode.num .. node.ParentNode.ParentNode.num .. node.ParentNode.num
          local task_item = task_config:GetChild(searchid)
          local task_child = task_item:GetChild(task_id)
          if not nx_is_valid(task_child) then
            nx_msgbox("\195\187\211\208\213\210\181\189\211\208\208\167\200\206\206\241ID")
            return 0
          end
          nx_execute("form_task\\form_subtask_process", "delete_task_subfunction", task_id)
          set_change(task_child, TASK)
          task_item:RemoveChildByID(task_child)
        end
      end
    end
    local ini = nx_create("IniDocument")
    ini.FileName = work_path .. TASK_TYPE_INI
    ini:LoadFromFile()
    ini:DeleteSection(new_task_player)
    ini:SaveToFile()
    nx_destroy(ini)
    node.ParentNode:RemoveNode(node)
  end
  return 1
end
function delete_task_chapter(node)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return 0
  end
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    return 0
  end
  local file_name = ""
  local state = false
  local new_task_player = node.ParentNode.num .. "_" .. nx_string(node.ParentNode.Text)
  local new_task_chapter = node.num .. "_" .. nx_string(node.Text)
  local res = show_confirm_box("\202\199\183\241\201\190\179\253\213\194\189\218 " .. nx_string(node.Text) .. " \188\176\198\228\207\194\203\249\211\208\200\206\206\241?")
  if res then
    local node_list = node:GetNodeList()
    for i = 1, table.getn(node_list) do
      child_list = node_list[i]:GetNodeList()
      for j = 1, table.getn(child_list) do
        local node = child_list[j]
        local task_id = nx_string(node.Text)
        local searchid = SEARCHID_BEGIN .. node.ParentNode.ParentNode.ParentNode.num .. node.ParentNode.ParentNode.num .. node.ParentNode.num
        local task_item = task_config:GetChild(searchid)
        local task_child = task_item:GetChild(task_id)
        if not nx_is_valid(task_child) then
          nx_msgbox("\195\187\211\208\213\210\181\189\211\208\208\167\200\206\206\241ID")
          return 0
        end
        nx_execute("form_task\\form_subtask_process", "delete_task_subfunction", task_id)
        set_change(task_child, TASK)
        task_item:RemoveChildByID(task_child)
      end
    end
    local ini = nx_create("IniDocument")
    ini.FileName = work_path .. TASK_TYPE_INI
    ini:LoadFromFile()
    ini:DeleteItem(new_task_player, new_task_chapter)
    ini:SaveToFile()
    nx_destroy(ini)
    node.ParentNode:RemoveNode(node)
  end
  return 1
end
function delete_task_parter(node)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return 0
  end
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    return 0
  end
  local file_name = ""
  local state = false
  local new_task_player = node.ParentNode.ParentNode.num .. "_" .. nx_string(node.ParentNode.ParentNode.Text)
  local new_task_chapter = node.ParentNode.num .. "_" .. nx_string(node.ParentNode.Text)
  local new_task_parter = node.num .. "_" .. nx_string(node.Text)
  local res = show_confirm_box("\202\199\183\241\201\190\179\253\213\194\187\216 " .. nx_string(node.Text) .. " \188\176\198\228\207\194\203\249\211\208\200\206\206\241?")
  if res then
    local node_list = node:GetNodeList()
    for i = 1, table.getn(node_list) do
      local node = node_list[i]
      local task_id = nx_string(node.Text)
      local searchid = SEARCHID_BEGIN .. node.ParentNode.ParentNode.ParentNode.num .. node.ParentNode.ParentNode.num .. node.ParentNode.num
      local task_item = task_config:GetChild(searchid)
      local task_child = task_item:GetChild(task_id)
      if not nx_is_valid(task_child) then
        nx_msgbox("\195\187\211\208\213\210\181\189\211\208\208\167\200\206\206\241ID")
        return 0
      end
      nx_execute("form_task\\form_subtask_process", "delete_task_subfunction", task_id)
      set_change(task_child, TASK)
      task_item:RemoveChildByID(task_child)
    end
    local ini = nx_create("IniDocument")
    ini.FileName = work_path .. TASK_TYPE_INI
    ini:LoadFromFile()
    local item_value = ini:ReadString(new_task_player, new_task_chapter, "")
    local begin_index, end_index = string.find(item_value, new_task_parter)
    if begin_index == nil then
      nx_msgbox("\201\190\179\253\179\246\180\237\163\172\195\187\211\208\213\210\181\189" .. new_task_parter)
      return 0
    end
    local result_value = ""
    if 1 < begin_index then
      result_value = string.sub(item_value, 1, begin_index - 2)
    end
    if end_index < string.len(item_value) then
      if result_value == "" then
        result_value = string.sub(item_value, end_index + 2, string.len(item_value))
      else
        result_value = result_value .. string.sub(item_value, end_index + 1, string.len(item_value))
      end
    end
    ini:WriteString(new_task_player, new_task_chapter, result_value)
    ini:SaveToFile()
    nx_destroy(ini)
    node.ParentNode:RemoveNode(node)
  end
  return 1
end
function delete_task_detail(node)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return 0
  end
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    return 0
  end
  local res = show_confirm_box("\202\199\183\241\201\190\179\253\200\206\206\241ID " .. nx_string(node.Text) .. " ?")
  if res then
    local task_id = nx_string(node.Text)
    local searchid = SEARCHID_BEGIN .. node.ParentNode.ParentNode.ParentNode.num .. node.ParentNode.ParentNode.num .. node.ParentNode.num
    local task_item = task_config:GetChild(searchid)
    local task_child = task_item:GetChild(task_id)
    if not nx_is_valid(task_child) then
      nx_msgbox("\201\190\179\253\202\167\176\220")
      return 0
    end
    nx_execute("form_task\\form_subtask_process", "delete_task_subfunction", task_id)
    set_change(task_child, TASK)
    task_item:RemoveChildByID(task_child)
    node.ParentNode:RemoveNode(node)
  end
  return 1
end
function task_list_expand_changed(self, node)
  search_child_node(node)
  return 1
end
function search_child_node(node)
  local work_path = nx_value("work_path")
  local node_list = node:GetNodeList()
  for i = 1, table.getn(node_list) do
    if nx_find_custom(node_list[i], "task_info") then
      local file_path, file_name = nx_function("ext_split_file_path", work_path .. node_list[i].task_info.file_name)
      node_list[i].ImageIndex = get_file_svn_status(file_name, file_path)
    else
      search_child_node(node_list[i])
    end
  end
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
local function open_parent_node(node)
  if not nx_is_valid(node) then
    return 0
  end
  if not node.Expand then
    node.Expand = true
    task_list_expand_changed(nil, node)
  end
  open_parent_node(node.ParentNode)
  return 1
end
local fix_scroll_position = function(tree, node)
  local root_node = tree.RootNode
  local expand_node_list = tree:GetAllNodeList()
  local all_expand_count = table.getn(expand_node_list)
  if all_expand_count == 0 then
    return 0
  end
  local max = tree.VScrollBar.Maximum
  local min = tree.VScrollBar.Minimum
  if max - min < 1.0E-4 then
    return 0
  end
  local pre_num = 0
  for i = 1, all_expand_count do
    if not nx_id_equal(node, expand_node_list[i]) then
      pre_num = pre_num + 1
    else
      break
    end
  end
  tree.VScrollBar.Value = pre_num / all_expand_count * (max - min)
  return 1
end
function search_key_edit_enter(self)
  local form = self.Parent
  local key = nx_string(self.Text)
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    return 0
  end
  local aim_parter
  local task_config = nx_value("task_config")
  if nx_is_valid(task_config) then
    local item_list = task_config:GetChildList()
    for i = 1, table.getn(item_list) do
      local child_list = item_list[i]:GetChildList()
      for j = 1, table.getn(child_list) do
        if child_list[j].ID == key then
          aim_parter = child_list[j]
          break
        end
      end
      if aim_parter ~= nil then
        break
      end
    end
  end
  if aim_parter ~= nil then
    local search_id = aim_parter.SearchID
    local root_node = form.task_list.RootNode
    local play_list = root_node:GetNodeList()
    for i = 1, table.getn(play_list) do
      local scene_list = play_list[i]:GetNodeList()
      for j = 1, table.getn(scene_list) do
        local chapter_list = scene_list[j]:GetNodeList()
        for m = 1, table.getn(chapter_list) do
          local task_list = chapter_list[m]:GetNodeList()
          for n = 1, table.getn(task_list) do
            local task = task_list[n]
            if task.searchid == search_id and task.Text == nx_widestr(key) then
              open_parent_node(task)
              form.task_list.SelectNode = task
              fix_scroll_position(form.task_list, task)
              return 1
            end
          end
        end
      end
    end
  end
  nx_msgbox("\178\187\180\230\212\218\200\206\206\241:" .. key)
  return 1
end
function is_exist_task_id(task_id)
  local b_exist = false
  local task_config = nx_value("task_config")
  if not nx_is_valid(task_config) then
    return false
  end
  local item_list = task_config:GetChildList()
  for i = 1, table.getn(item_list) do
    local child = item_list[i]:GetChild(task_id)
    if nx_is_valid(child) then
      b_exist = true
      break
    end
  end
  return b_exist
end
