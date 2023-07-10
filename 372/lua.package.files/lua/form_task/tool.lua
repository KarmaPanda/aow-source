require("form_task\\common")
function sort(grid, type)
  if not nx_is_valid(grid) then
    return 0
  end
  local row_count = grid.RowCount
  local col_count = grid.ColCount
  local tmp_grid = {}
  local index_table = {}
  for i = 0, row_count - 1 do
    tmp_grid[i + 1] = {}
    for j = 0, col_count - 1 do
      tmp_grid[i + 1][j + 1] = grid:GetGridText(i, j)
    end
    index_table[i + 1] = {}
    index_table[i + 1].id = nx_number(tmp_grid[i + 1][1])
    index_table[i + 1].number = i + 1
  end
  for i = 1, row_count do
    for j = i + 1, row_count do
      local is_swap = false
      if type == "up" and index_table[i].id > index_table[j].id then
        is_swap = true
      end
      if type == "down" and index_table[i].id < index_table[j].id then
        is_swap = true
      end
      if index_table[i].id == index_table[j].id and index_table[i].number > index_table[j].number then
        is_swap = true
      end
      if is_swap then
        local tmp = index_table[i]
        index_table[i] = index_table[j]
        index_table[j] = tmp
      end
    end
  end
  grid:ClearRow()
  for i = 1, row_count do
    local index = index_table[i].number
    local new_row = grid:InsertRow(-1)
    for j = 0, col_count - 1 do
      grid:SetGridText(new_row, j, tmp_grid[index][j + 1])
    end
  end
  return 1
end
function select_grid_by_key(grid, val, number)
  if number == nil then
    number = 1
  end
  for i = 0, grid.RowCount - 1 do
    if grid:GetGridText(i, 0) == nx_widestr(val) then
      if number == 1 then
        grid:SelectRow(i)
        return 1
      else
        number = number - 1
      end
    end
  end
  grid:ClearSelect()
  return 0
end
function get_previous_same_value(grid, row)
  local key = grid:GetGridText(row, 0)
  local ret = 0
  for i = 0, row - 1 do
    if grid:GetGridText(i, 0) == key then
      ret = ret + 1
    end
  end
  return ret
end
function load_npc_config()
  local work_path = nx_value("work_path")
  local npctype_ini_config = nx_value("npctype_ini_config")
  if not nx_is_valid(npctype_ini_config) then
    npctype_ini_config = nx_create("ArrayList", "npctype_ini_config")
    nx_set_value("npctype_ini_config", npctype_ini_config)
    local ini = nx_create("IniDocument")
    ini.FileName = work_path .. NPC_TYPE_INI
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return 0
    end
    local sect_list = ini:GetSectionList()
    local sect_count = table.getn(sect_list)
    for i = 1, sect_count do
      local sect_name = sect_list[i]
      if sect_name == "file" then
        local sect = npctype_ini_config:CreateChild(sect_name)
        local item_list = ini:GetItemList(sect_name)
        local item_count = table.getn(item_list)
        for j = 1, item_count do
          local item_name = item_list[j]
          local item = sect:CreateChild(item_name)
          item.value = ini:ReadString(sect_name, item_name, "")
        end
      end
    end
    nx_destroy(ini)
  end
  local npc_config = nx_value("npc_config")
  if not nx_is_valid(npc_config) then
    npc_config = nx_create("ArrayList", "npc_config")
    nx_set_value("npc_config", npc_config)
    local file_list = npctype_ini_config:GetChild("file")
    if nx_is_valid(file_list) then
      local text_grid = nx_create("TextGrid")
      local file_table = file_list:GetChildList()
      local file_count = table.getn(file_table)
      for i = 1, file_count do
        text_grid.FileName = work_path .. file_table[i].value
        text_grid:Dispose()
        if text_grid:LoadFromFile(2) then
          local row_count = text_grid.RowCount
          for j = 0, row_count - 1 do
            local id = nx_string(text_grid:GetValueString(nx_int(j), "ID"))
            if id ~= "" then
              local visual_item = npc_config:GetChild(id)
              if not nx_is_valid(visual_item) then
                visual_item = npc_config:CreateChild(id)
              end
              visual_item.file_name = file_table[i].value
              visual_item.desc_name = nx_string(text_grid:GetValueString(nx_int(j), "Name"))
              visual_item.convoy_type = nx_string(text_grid:GetValueString(nx_int(j), "ConvoyType"))
              visual_item.target_pos_x = nx_string(text_grid:GetValueString(nx_int(j), "TargetPosX"))
              visual_item.target_pos_z = nx_string(text_grid:GetValueString(nx_int(j), "TargetPosZ"))
            end
          end
        end
      end
      nx_destroy(text_grid)
    end
  end
  return 1
end
function put_log(msg)
  local log_memory = nx_value("log_memory")
  if nx_is_valid(log_memory) then
    local form = nx_value("task_form")
    if nx_is_valid(form.log_form) then
      local curr_undo_pos = form.log_form.log_list.curr_undo_pos
      local count = log_memory:GetChildCount()
      for i = count - 1, curr_undo_pos, -1 do
        log_memory:RemoveChildByIndex(i)
      end
      local item = log_memory:CreateChild("")
      item.info = msg
    end
  end
  return 1
end
function get_npc_name(id)
  local gui = nx_value("gui")
  return nx_string(gui.TextManager:GetText(id))
end
function check_npc_config(task_id, prop, old_npc_id, new_npc_id)
  if old_npc_id == new_npc_id then
    return 0
  end
  local work_path = nx_value("work_path")
  load_npc_config()
  local npc_config = nx_value("npc_config")
  if nx_is_valid(npc_config) then
    if old_npc_id ~= "" and old_npc_id ~= nil then
      local old_npc = npc_config:GetChild(old_npc_id)
      if nx_is_valid(old_npc) then
        local ini = nx_create("IniDocument")
        ini.FileName = work_path .. old_npc.file_name
        if ini:LoadFromFile() and ini:FindSection(old_npc_id) then
          local value_list = ini:GetItemValueList(old_npc_id, prop)
          while ini:DeleteItem(old_npc_id, prop) do
          end
          for j = 1, table.getn(value_list) do
            if value_list[j] ~= task_id then
              ini:AddString(old_npc_id, prop, value_list[j])
            end
          end
        end
        ini:SaveToFile()
        nx_destroy(ini)
      end
    end
    if new_npc_id ~= "" and new_npc_id ~= nil then
      local new_npc = npc_config:GetChild(new_npc_id)
      if nx_is_valid(new_npc) then
        local ini = nx_create("IniDocument")
        ini.FileName = work_path .. new_npc.file_name
        if ini:LoadFromFile() and ini:FindSection(new_npc_id) then
          local value_list = ini:GetItemValueList(new_npc_id, prop)
          local b_find = false
          for j = 1, table.getn(value_list) do
            if value_list[j] == task_id then
              b_find = true
            end
          end
          if not b_find then
            ini:AddString(new_npc_id, prop, task_id)
          end
        end
        ini:SaveToFile()
        nx_destroy(ini)
      end
    end
  end
  return 1
end
function get_npc_property(id, pro_name)
  load_npc_config()
  local npc_config = nx_value("npc_config")
  local visual_item = npc_config:GetChild(id)
  if nx_is_valid(visual_item) then
    return nx_custom(visual_item, pro_name)
  end
  return ""
end
local SCENE_INFO = "ini\\Task\\SceneInfo.ini"
function get_scene_info_by_number(number)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return ""
  end
  local ini = nx_create("IniDocument")
  ini.FileName = work_path .. SCENE_INFO
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return ""
  end
  local ret = ""
  if ini:FindSection(nx_string(number)) then
    ret = ini:ReadString(nx_string(number), "name", "")
  end
  nx_destroy(ini)
  return ret
end
local DRAMA_INFO = "ini\\Task\\DramaNameInfo.ini"
function get_drama_name(number)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return ""
  end
  local ini = nx_create("IniDocument")
  ini.FileName = work_path .. DRAMA_INFO
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return ""
  end
  local ret = ""
  if ini:FindSection(nx_string(number)) then
    ret = ini:ReadString(nx_string(number), "name", "")
  end
  nx_destroy(ini)
  return ret
end
function set_modify_task_info(type, task_id, name, old_value, new_value)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  put_log("\192\224\208\205: \214\247\177\237\208\222\184\196" .. ",\200\206\206\241ID: " .. task_id .. ",\215\214\182\206: " .. name .. ",\190\201\181\196\214\181: " .. old_value .. ",\208\194\181\196\214\181: " .. new_value)
  local unique_name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand(type)
  text_undo_mgr:AddUndoParam(unique_name, type, task_id, name, old_value)
  text_undo_mgr:AddRedoParam(unique_name, type, task_id, name, new_value)
  text_undo_mgr:EndCommand()
  return 1
end
function set_modify_monster_info(type, monster_id, name, old_value, new_value)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  put_log("\192\224\208\205: \203\162\185\214\177\237\208\222\184\196" .. ",\185\214\206\239ID: " .. monster_id .. ",\215\214\182\206: " .. name .. ",\190\201\181\196\214\181: " .. nx_string(old_value) .. ",\208\194\181\196\214\181: " .. new_value)
  local unique_name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand(type)
  text_undo_mgr:AddUndoParam(unique_name, type, monster_id, name, old_value)
  text_undo_mgr:AddRedoParam(unique_name, type, monster_id, name, new_value)
  text_undo_mgr:EndCommand()
  return 1
end
function set_modify_tool_info(type, tool_id, name, old_value, new_value)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  put_log("\192\224\208\205: \181\192\190\223\177\237\208\222\184\196" .. ",\181\192\190\223ID: " .. tool_id .. ",\215\214\182\206: " .. name .. ",\190\201\181\196\214\181: " .. nx_string(old_value) .. ",\208\194\181\196\214\181: " .. new_value)
  local unique_name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand(type)
  text_undo_mgr:AddUndoParam(unique_name, type, tool_id, name, old_value)
  text_undo_mgr:AddRedoParam(unique_name, type, tool_id, name, new_value)
  text_undo_mgr:EndCommand()
  return 1
end
function set_add_or_delete_info(type, id)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  local type_text = ""
  if type == "monster_overview_add" then
    type_text = "\185\214\206\239\215\220\177\237 \212\246\188\211"
  elseif type == "monster_overview_delete" then
    type_text = "\185\214\206\239\215\220\177\237 \188\245\201\217"
  end
  put_log("\192\224\208\205: " .. type_text .. ",ID: " .. id)
  local unique_name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand(type)
  text_undo_mgr:AddUndoParam(unique_name, id)
  text_undo_mgr:AddRedoParam(unique_name, id)
  text_undo_mgr:EndCommand()
  return 1
end
function set_modify_subtask_overview(type_name, type, id, name, number, old_value, new_value)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  put_log("\192\224\208\205: \208\222\184\196\215\211\200\206\206\241\215\220\177\237" .. ",\215\211\200\206\206\241ID: " .. id .. ",\215\214\182\206: " .. name .. ",\181\218\188\184\184\246: " .. number .. ",\190\201\181\196\214\181: " .. old_value .. ",\208\194\181\196\214\181: " .. new_value)
  local unique_name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand(type_name)
  text_undo_mgr:AddUndoParam(unique_name, type, id, name, number, old_value)
  text_undo_mgr:AddRedoParam(unique_name, type, id, name, number, new_value)
  text_undo_mgr:EndCommand()
  return 1
end
function set_text_form(is_show, mode)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  put_log("\192\224\208\205:\180\242\191\170\186\205\185\216\177\213\206\196\177\190\177\224\188\173\198\247" .. ",\202\199\183\241\207\212\202\190: " .. nx_string(is_show) .. ",\214\214\192\224: " .. nx_string(mode))
  local name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand("show_or_close_text_form")
  text_undo_mgr:AddUndoParam(name, not is_show, mode)
  text_undo_mgr:AddRedoParam(name, is_show, mode)
  text_undo_mgr:EndCommand()
  return 1
end
function set_modify_text(key, old_value, new_value, controlbox_name)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  put_log("\192\224\208\205:\208\222\184\196\210\235\206\196" .. ",\185\216\188\252\215\214: " .. key .. ",\190\201\181\196\214\181: " .. old_value .. ",\208\194\181\196\214\181: " .. new_value .. ",\206\187\214\195: " .. controlbox_name)
  local name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand("modify_text")
  text_undo_mgr:AddUndoParam(name, key, old_value, controlbox_name)
  text_undo_mgr:AddRedoParam(name, key, new_value, controlbox_name)
  text_undo_mgr:EndCommand()
  return 1
end
function set_modify_questions(question_id, prop, old_value, new_value)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  put_log("\192\224\208\205:\208\222\184\196\206\202\204\226\177\237" .. ",\206\202\204\226ID: " .. question_id .. ",\215\214\182\206: " .. prop .. ",\190\201\181\196\214\181: " .. old_value .. ",\208\194\181\196\214\181: " .. new_value)
  local name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand("modify_questions")
  text_undo_mgr:AddUndoParam(name, question_id, prop, old_value)
  text_undo_mgr:AddRedoParam(name, question_id, prop, new_value)
  text_undo_mgr:EndCommand()
  return 1
end
function set_modify_process(task_id, row, old_order, old_type, old_id, new_order, new_type, new_id)
  local text_undo_mgr = nx_value("text_undo_mgr")
  if not nx_is_valid(text_undo_mgr) then
    return 0
  end
  put_log("\178\217\215\247\192\224\208\205:\208\222\184\196\200\206\206\241\178\189\214\232" .. ",\200\206\206\241ID: " .. task_id .. ",\208\208: " .. nx_string(row) .. ",\190\201\181\196Order: " .. old_order .. ",\190\201\181\196Type: " .. old_type .. ",\190\201\181\196Id: " .. old_id .. ",\208\194\181\196Order: " .. new_order .. ",\208\194\181\196Type: " .. new_type .. ",\208\194\181\196Id: " .. new_id)
  local name = nx_function("ext_gen_unique_name")
  text_undo_mgr:BeginCommand("modify_process")
  text_undo_mgr:AddUndoParam(name, task_id, row, old_order, old_type, old_id)
  text_undo_mgr:AddRedoParam(name, task_id, row, new_order, new_type, new_id)
  text_undo_mgr:EndCommand()
  return 1
end
