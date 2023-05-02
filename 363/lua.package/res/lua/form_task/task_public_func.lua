require("form_task\\common")
require("form_task\\public_svn")
function add_item_into_overview(grid, item, type)
  if nx_is_valid(item) then
    local row = grid:InsertRow(-1)
    local title_info
    if type == "monster" then
      title_info = nx_value("monster_title_info")
    elseif type == "tool" then
      title_info = nx_value("tool_title_info")
    elseif type == "path" then
      title_info = nx_value("path_title_info")
    end
    if nx_is_valid(title_info) then
      local prop_list = title_info:GetChildList()
      local prop_count = table.getn(prop_list)
      for i = 1, prop_count do
        local value = nx_custom(item, prop_list[i].Name)
        if value == nil then
          value = ""
        end
        grid:SetGridText(row, i - 1, nx_widestr(value))
      end
    end
  end
  return 1
end
function ask(ask_info)
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_yes_no_cancel.xml")
  dialog.info_label.Text = nx_widestr(ask_info)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "yes_no_cancel_return")
  return res
end
function open_pict_file(path, ext)
  local dialog = nx_value("pictfile_form")
  if not nx_is_valid(dialog) then
    local gui = nx_value("gui")
    dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_pictfile.xml")
    dialog.path = path
    dialog.ext = ext
    nx_set_value("pictfile_form", dialog)
  end
  dialog:ShowModal()
  local res, new_name = nx_wait_event(100000000, dialog, "pictfile_return")
  return res, new_name
end
function util_split_string(szbuffer, splits)
  if szbuffer == nil then
    return {}
  end
  return nx_function("ext_split_string", szbuffer, splits)
end
function get_work_path()
  local work_path = nx_function("ext_get_full_path", "..\\..\\..\\02_Server\\Cons\\Res")
  if not nx_path_exists(work_path) then
    work_path = nx_function("ext_get_full_path", "..\\..\\02_Server\\Res")
    if not nx_path_exists(work_path) then
      work_path = ""
    end
  end
  return work_path
end
function get_new_global_list(global_list_name)
  local global_list = nx_value(global_list_name)
  if not nx_is_valid(global_list) then
    global_list = nx_create("ArrayList", global_list_name)
    nx_set_value(global_list_name, global_list)
  else
    global_list:ClearChild()
  end
  return global_list
end
function set_file_archive(full_file_name)
  local file_attr = nx_function("ext_get_file_attributes", full_file_name)
  local res = nx_function("ext_set_file_attributes", full_file_name, nx_function("ext_bit_band", file_attr, 4294967294))
  return res
end
function seperate_modefy_to_tempfile(full_file_name)
  if not nx_file_exists(full_file_name) then
    nx_msgbox(full_file_name .. "\206\196\188\254\178\187\180\230\212\218\163\172\199\235\200\183\200\207")
    return false
  end
  local path_name, file_name = nx_function("ext_split_file_path", full_file_name)
  local res = get_file_svn_status(file_name, path_name)
  if res == LOCKED then
    return true
  end
  if res == NONE then
    return false
  end
  if res == NEWEST then
    return true
  end
  if res == MODIFY or res == ADD then
    local new_path = path_name .. "tmp\\"
    if not nx_path_exists(new_path) then
      nx_path_create(new_path)
    end
    local modify_name = new_path .. file_name .. ".modify"
    local base_name = new_path .. file_name .. ".base"
    nx_function("ext_copy_file", full_file_name, modify_name)
    nx_function("ext_copy_file", path_name .. ".svn\\text-base\\" .. file_name .. ".svn-base", base_name)
    nx_function("ext_copy_file", path_name .. ".svn\\text-base\\" .. file_name .. ".svn-base", full_file_name)
    set_file_archive(base_name)
    set_file_archive(modify_name)
    return true
  elseif res == DELETE then
    nx_msgbox(full_file_name .. "\206\196\188\254\177\187\214\180\208\208\193\203SVN\201\190\179\253\178\217\215\247")
    return false
  end
  nx_msgbox(full_file_name .. "\206\196\188\254\215\180\204\172\178\187\213\253\200\183:" .. nx_string(res))
  return false
end
function merge_tempfile_to_file(full_file_name)
  if not nx_file_exists(full_file_name) then
    nx_msgbox(full_file_name .. "\206\196\188\254\178\187\180\230\212\218\163\172\199\235\200\183\200\207")
    return 1
  end
  local path_name, file_name = nx_function("ext_split_file_path", full_file_name)
  local res = get_file_svn_status(file_name, path_name)
  if res == LOCKED then
    return 1
  end
  if res == NONE then
    return 1
  end
  if res ~= NEWEST then
    return 1
  end
  local new_path = path_name .. "tmp\\"
  if not nx_path_exists(new_path) then
    return 1
  end
  local modify_name = new_path .. file_name .. ".modify"
  local base_name = new_path .. file_name .. ".base"
  if not nx_file_exists(modify_name) then
    delete_backup_dir(new_path, file_name)
    return 1
  end
  if not nx_file_exists(base_name) then
    nx_msgbox("\210\236\179\163\163\172\199\235\193\170\207\181\206\172\187\164\200\203\212\177\161\163 \178\187\180\230\212\218" .. base_name)
    return 0
  end
  set_file_archive(full_file_name)
  if not merge_file(base_name, modify_name, full_file_name) then
    return 0
  end
  delete_backup_dir(new_path, file_name)
  return 1
end
function create_modfied_node(id, first_textgrid, first_index_list, second_textgrid, second_index_list, node_list)
  if table.getn(second_index_list) <= 0 then
    child = node_list:CreateChild(id)
    child.op = "delete"
  elseif table.getn(first_index_list) ~= table.getn(second_index_list) then
    child = node_list:CreateChild(id)
    child.op = "modify"
  else
    local diff = false
    for i = 1, table.getn(first_index_list) do
      for j = 0, first_textgrid.ColCount - 1 do
        local first_value = first_textgrid:GetValueString(nx_int(first_index_list[i]), nx_int(j))
        local second_value = second_textgrid:GetValueString(nx_int(second_index_list[i]), nx_int(j))
        if first_value ~= second_value then
          diff = true
          break
        end
      end
      if diff then
        break
      end
    end
    if diff then
      child = node_list:CreateChild(id)
      child.op = "modify"
    end
  end
  return true
end
function merge_file(base_file, modify_file, newest_file)
  local base_textgrid = nx_create("TextGrid")
  base_textgrid.FileName = base_file
  if not base_textgrid:LoadFromFile(2) then
    nx_destroy(base_textgrid)
    nx_msgbox("\182\193\200\161\206\196\188\254(" .. base_file .. ")\202\167\176\220")
    return false
  end
  local modify_textgrid = nx_create("TextGrid")
  modify_textgrid.FileName = modify_file
  if not modify_textgrid:LoadFromFile(2) then
    nx_destroy(modify_textgrid)
    nx_msgbox("\182\193\200\161\206\196\188\254(" .. modify_file .. ")\202\167\176\220")
    return false
  end
  local newest_textgrid = nx_create("TextGrid")
  newest_textgrid.FileName = newest_file
  if not newest_textgrid:LoadFromFile(2) then
    nx_destroy(newest_textgrid)
    nx_msgbox("\182\193\200\161\206\196\188\254(" .. newest_file .. ")\202\167\176\220")
    return false
  end
  local modify_list = get_new_global_list("modify_list")
  local update_list = get_new_global_list("update_list")
  local conflict_list = get_new_global_list("conflict_list")
  for k = 0, base_textgrid.RowCount - 1 do
    local id = nx_string(base_textgrid:GetValueString(nx_int(k), nx_int(0)))
    if id ~= "" and not modify_list:FindChild(id) and not update_list:FindChild(id) then
      local base_index_list = base_textgrid:FindRowIndexs(nx_int(0), id)
      local modify_index_list = modify_textgrid:FindRowIndexs(nx_int(0), id)
      local newest_index_list = newest_textgrid:FindRowIndexs(nx_int(0), id)
      create_modfied_node(id, base_textgrid, base_index_list, modify_textgrid, modify_index_list, modify_list)
      create_modfied_node(id, base_textgrid, base_index_list, newest_textgrid, newest_index_list, update_list)
    end
  end
  for k = 0, modify_textgrid.RowCount - 1 do
    local id = nx_string(modify_textgrid:GetValueString(nx_int(k), nx_int(0)))
    if id ~= "" and not modify_list:FindChild(id) then
      local base_index_list = base_textgrid:FindRowIndexs(nx_int(0), id)
      local modify_index_list = modify_textgrid:FindRowIndexs(nx_int(0), id)
      if 0 >= table.getn(base_index_list) then
        child = modify_list:CreateChild(id)
        child.op = "add"
      end
    end
  end
  for k = 0, newest_textgrid.RowCount - 1 do
    local id = nx_string(newest_textgrid:GetValueString(nx_int(k), nx_int(0)))
    if id ~= "" and not update_list:FindChild(id) then
      local base_index_list = base_textgrid:FindRowIndexs(nx_int(0), id)
      local newest_index_list = newest_textgrid:FindRowIndexs(nx_int(0), id)
      if 0 >= table.getn(base_index_list) then
        child = update_list:CreateChild(id)
        child.op = "add"
      end
    end
  end
  local list = modify_list:GetChildList()
  for k = 1, table.getn(list) do
    if list[k].op == "delete" then
      local child = update_list:GetChild(list[k].Name)
      if not nx_is_valid(child) then
        newest_textgrid:RemoveRowByKey(nx_int(0), list[k].Name)
      elseif child.op == "delete" then
      elseif not conflict_list:FindChild(list[k].Name) then
        conflict_list:CreateChild(list[k].Name)
      end
    end
  end
  for k = 1, table.getn(list) do
    if list[k].op == "add" then
      local child = update_list:GetChild(list[k].Name)
      if not nx_is_valid(child) then
        local modify_index_list = modify_textgrid:FindRowIndexs(nx_int(0), list[k].Name)
        for i = 1, table.getn(modify_index_list) do
          local row = newest_textgrid:AddRow(list[k].Name)
          for j = 0, newest_textgrid.ColCount - 1 do
            local value = modify_textgrid:GetValueString(nx_int(modify_index_list[i]), nx_int(j))
            newest_textgrid:SetValueString(nx_int(row), nx_int(j), value)
          end
        end
      elseif not conflict_list:FindChild(list[k].Name) then
        conflict_list:CreateChild(list[k].Name)
      end
    end
  end
  for k = 1, table.getn(list) do
    if list[k].op == "modify" then
      local child = update_list:GetChild(list[k].Name)
      if not nx_is_valid(child) then
        local newest_index_list = newest_textgrid:FindRowIndexs(nx_int(0), list[k].Name)
        local index = newest_index_list[1] - 1
        newest_textgrid:RemoveRowByKey(nx_int(0), list[k].Name)
        local modify_index_list = modify_textgrid:FindRowIndexs(nx_int(0), list[k].Name)
        for i = 1, table.getn(modify_index_list) do
          index = index + 1
          local row = newest_textgrid:InsertRow(nx_int(index), nx_widestr(list[k].Name))
          for j = 1, newest_textgrid.ColCount - 1 do
            local value = modify_textgrid:GetValueString(nx_int(modify_index_list[i]), nx_int(j))
            newest_textgrid:SetValueString(nx_int(row), nx_int(j), value)
          end
        end
      elseif not conflict_list:FindChild(list[k].Name) then
        conflict_list:CreateChild(list[k].Name)
      end
    end
  end
  local list = conflict_list:GetChildList()
  for k = 1, table.getn(list) do
    local newest_index_list = newest_textgrid:FindRowIndexs(nx_int(0), list[k].Name)
    local newest_index_count = table.getn(newest_index_list)
    for i = 1, newest_index_count do
      newest_textgrid:SetValueString(nx_int(newest_index_list[i]), nx_int(0), "svn>>>>>" .. list[k].Name)
    end
    local index
    if 0 < newest_index_count then
      index = newest_index_list[newest_index_count]
    else
      index = newest_textgrid.RowCount - 1
    end
    local modify_index_list = modify_textgrid:FindRowIndexs(nx_int(0), list[k].Name)
    for i = 1, table.getn(modify_index_list) do
      index = index + 1
      local row = newest_textgrid:InsertRow(nx_int(index), "mine<<<<<" .. list[k].Name)
      for j = 1, modify_textgrid.ColCount - 1 do
        local value = modify_textgrid:GetValueString(nx_int(modify_index_list[i]), nx_int(j))
        newest_textgrid:SetValueString(nx_int(row), nx_int(j), value)
      end
    end
  end
  if 0 < table.getn(list) then
    nx_msgbox(newest_file .. "\206\196\188\254\211\208\179\229\205\187\163\172\199\235\207\200\180\242\191\170\180\203\206\196\188\254\189\226\190\246\179\229\205\187\163\172\212\217\214\216\208\194\180\242\191\170\200\206\206\241\177\224\188\173\198\247!")
  end
  newest_textgrid:SaveToFile()
  nx_destroy(base_textgrid)
  nx_destroy(modify_textgrid)
  nx_destroy(newest_textgrid)
  return true
end
function delete_backup_dir(path_name, file_name)
  nx_file_delete(path_name .. file_name .. ".modify")
  nx_file_delete(path_name .. file_name .. ".base")
  nx_path_delete(path_name)
  return true
end
