require("theme")
require("form_task\\tool")
require("form_task\\task_public_func")
require("form_task\\form_task")
function menu_operation_task_init(self)
  nx_callback(self, "on_add_task_line_click", "menu_add_task_line_click")
  nx_callback(self, "on_delete_task_line_click", "menu_delete_task_line_click")
  nx_callback(self, "on_add_task_chapter_click", "menu_add_task_chapter_click")
  nx_callback(self, "on_delete_task_chapter_click", "menu_delete_task_chapter_click")
  nx_callback(self, "on_add_task_parter_click", "menu_add_task_parter_click")
  nx_callback(self, "on_modify_task_parter_name_click", "menu_modify_task_parter_name_click")
  nx_callback(self, "on_delete_task_parter_click", "menu_delete_task_parter_click")
  nx_callback(self, "on_add_task_detail_click", "menu_add_task_detail_click")
  nx_callback(self, "on_insert_task_detail_click", "menu_insert_task_detail_click")
  nx_callback(self, "on_delete_task_detail_click", "menu_delete_task_detail_click")
  nx_callback(self, "on_add_file_click", "menu_add_file_click")
  nx_callback(self, "on_revert_file_click", "menu_revert_file_click")
  nx_callback(self, "on_lock_file_click", "menu_lock_file_click")
  nx_callback(self, "on_unlock_file_click", "menu_unlock_file_click")
  nx_callback(self, "on_submit_file_click", "menu_submit_file_click")
  nx_callback(self, "on_write_file_click", "menu_write_file_click")
  nx_callback(self, "on_update_file_click", "menu_update_file_click")
  nx_callback(self, "on_merge_file_click", "menu_merge_file_click")
  nx_callback(self, "on_lock_npc_file_click", "menu_lock_npc_file_click")
  nx_callback(self, "on_unlock_npc_file_click", "menu_unlock_npc_file_click")
  nx_callback(self, "on_submit_npc_file_click", "menu_submit_npc_file_click")
  nx_callback(self, "on_save_chapter_npc_click", "menu_save_chapter_npc_click")
  nx_callback(self, "on_save_task_line_npc_click", "menu_save_task_line_npc_click")
  nx_callback(self, "on_save_task_npc_click", "menu_save_task_npc_click")
  nx_callback(self, "on_relate_task_click", "menu_relate_task_click")
  nx_callback(self, "on_set_version_click", "menu_set_version_click")
  return 1
end
function menu_add_task_line_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "add_task_line", self.visual)
  return 1
end
function menu_delete_task_line_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "delete_task_line", self.visual)
  return 1
end
function menu_add_task_chapter_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "add_task_chapter", self.visual)
  return 1
end
function menu_delete_task_chapter_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "delete_task_chapter", self.visual)
  return 1
end
function menu_add_task_parter_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "add_task_parter", self.visual)
  return 1
end
function menu_modify_task_parter_name_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "change_task_parter_name", self.visual)
  return 1
end
function menu_delete_task_parter_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "delete_task_parter", self.visual)
  return 1
end
function menu_add_task_detail_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "insert_task_detail", self.visual)
  return 1
end
function menu_insert_task_detail_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "insert_task_detail", self.visual.ParentNode, self.visual)
  return 1
end
function menu_delete_task_detail_click(self)
  delete_right_button_menu()
  nx_execute("form_task\\form_work_dir", "delete_task_detail", self.visual)
  return 1
end
function produce_file_list(node)
  local work_path = nx_value("work_path")
  local child_list = node:GetChildList()
  local client_file = ""
  local question_file = ""
  local server_file = ""
  for i = 1, table.getn(child_list) do
    if child_list[i].flag == "client_file" then
      if client_file == "" then
        client_file = nx_resource_path() .. child_list[i].file_name
      else
        client_file = client_file .. "*" .. nx_resource_path() .. child_list[i].file_name
      end
    elseif child_list[i].flag == "question_file" then
      if question_file == "" then
        question_file = work_path .. child_list[i].file_name
      else
        question_file = question_file .. "*" .. work_path .. child_list[i].file_name
      end
    elseif child_list[i].flag == "server_file" then
      if server_file == "" then
        server_file = work_path .. child_list[i].file_name
      else
        server_file = server_file .. "*" .. work_path .. child_list[i].file_name
      end
    end
  end
  return client_file, question_file, server_file
end
function menu_add_file_click(self)
  delete_right_button_menu()
  if nx_is_valid(self.visual) and nx_is_valid(self.visual.sect_node) then
    local client_file, question_file, server_file = produce_file_list(self.visual.sect_node)
    if client_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_add", client_file)
    end
    if question_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_add", question_file)
    end
    if server_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_add", server_file)
    end
  end
  return 1
end
function menu_revert_file_click(self)
  delete_right_button_menu()
  if nx_is_valid(self.visual) and nx_is_valid(self.visual.sect_node) then
    local client_file, question_file, server_file = produce_file_list(self.visual.sect_node)
    if client_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_revert", client_file)
    end
    if question_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_revert", question_file)
    end
    if server_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_revert", server_file)
    end
  end
  return 1
end
function menu_lock_file_click(self)
  delete_right_button_menu()
  if nx_is_valid(self.visual) and nx_is_valid(self.visual.sect_node) then
    local client_file, question_file, server_file = produce_file_list(self.visual.sect_node)
    if client_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_lock", client_file)
    end
    if question_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_lock", question_file)
    end
    if server_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_lock", server_file)
    end
  end
  return 1
end
function menu_unlock_file_click(self)
  delete_right_button_menu()
  if nx_is_valid(self.visual) and nx_is_valid(self.visual.sect_node) then
    local client_file, question_file, server_file = produce_file_list(self.visual.sect_node)
    if client_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_unlock", client_file)
    end
    if question_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_unlock", question_file)
    end
    if server_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_unlock", server_file)
    end
  end
  return 1
end
function menu_submit_file_click(self)
  delete_right_button_menu()
  if nx_is_valid(self.visual) and nx_is_valid(self.visual.sect_node) then
    local client_file, question_file, server_file = produce_file_list(self.visual.sect_node)
    if client_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_commit", client_file)
    end
    if question_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_commit", question_file)
    end
    if server_file ~= "" then
      nx_execute("form_task\\public_svn", "svn_commit", server_file)
    end
  end
  return 1
end
function menu_write_file_click(self)
  delete_right_button_menu()
  local work_path = nx_value("work_path")
  if nx_is_valid(self.visual) and nx_is_valid(self.visual.sect_node) then
    local child_list = self.visual.sect_node:GetChildList()
    for i = 1, table.getn(child_list) do
      if child_list[i].flag == "client_file" then
        set_file_archive(nx_resource_path() .. child_list[i].file_name)
      elseif child_list[i].flag == "question_file" then
        set_file_archive(work_path .. child_list[i].file_name)
      elseif child_list[i].flag == "server_file" then
        set_file_archive(work_path .. child_list[i].file_name)
      end
    end
  end
  return 1
end
function menu_update_file_click(self)
  delete_right_button_menu()
  local res = ask_for_save()
  if not res then
    return 0
  end
  nx_msgbox("\212\218\189\211\207\194\192\180\181\196SVN\184\252\208\194\180\176\191\218\182\188\185\216\177\213\186\243\163\172\177\216\208\235\211\210\188\252\178\162\181\227\187\247\186\207\178\162\206\196\188\254(Merge)\163\172\183\241\212\242\206\180\204\225\189\187\202\253\190\221\189\171\182\170\202\167\163\161")
  if nx_is_valid(self.visual) and nx_is_valid(self.visual.sect_node) then
    local client_file, question_file, server_file = produce_file_list(self.visual.sect_node)
    if client_file ~= "" then
      local str_list = nx_function("ext_split_string", client_file, "*")
      client_file = ""
      for i = 1, table.getn(str_list) do
        if seperate_modefy_to_tempfile(str_list[i]) then
          if client_file == "" then
            client_file = str_list[i]
          else
            client_file = client_file .. "*" .. str_list[i]
          end
        end
      end
      if client_file ~= "" then
        nx_execute("form_task\\public_svn", "svn_update", client_file)
      end
    end
    if question_file ~= "" then
      local str_list = nx_function("ext_split_string", question_file, "*")
      question_file = ""
      for i = 1, table.getn(str_list) do
        if seperate_modefy_to_tempfile(str_list[i]) then
          if question_file == "" then
            question_file = str_list[i]
          else
            question_file = question_file .. "*" .. str_list[i]
          end
        end
      end
      if question_file ~= "" then
        nx_execute("form_task\\public_svn", "svn_update", question_file)
      end
    end
    if server_file ~= "" then
      local str_list = nx_function("ext_split_string", server_file, "*")
      server_file = ""
      for i = 1, table.getn(str_list) do
        if seperate_modefy_to_tempfile(str_list[i]) then
          if server_file == "" then
            server_file = str_list[i]
          else
            server_file = server_file .. "*" .. str_list[i]
          end
        end
      end
      if server_file ~= "" then
        nx_execute("form_task\\public_svn", "svn_update", server_file)
      end
    end
  end
  return 1
end
function menu_merge_file_click(self)
  delete_right_button_menu()
  local work_path = nx_value("work_path")
  if nx_is_valid(self.visual) and nx_is_valid(self.visual.sect_node) then
    local child_list = self.visual.sect_node:GetChildList()
    for i = 1, table.getn(child_list) do
      if child_list[i].flag == "client_file" then
        merge_tempfile_to_file(nx_resource_path() .. child_list[i].file_name)
      elseif child_list[i].flag == "question_file" then
        merge_tempfile_to_file(work_path .. child_list[i].file_name)
      elseif child_list[i].flag == "server_file" then
        merge_tempfile_to_file(work_path .. child_list[i].file_name)
      end
    end
  end
  nx_msgbox("\199\235\214\216\208\194\180\242\191\170\200\206\206\241\177\224\188\173\198\247\163\172\200\183\177\163\202\253\190\221\213\253\200\183\163\172\203\249\215\247\208\222\184\196\178\187\187\225\182\170\202\167\163\161")
  nx_execute("form_task\\form_task", "open_or_close_task_form")
  return 1
end
function produce_npc_file_list()
  local file_name = ""
  local work_path = nx_value("work_path")
  nx_execute("form_task\\tool", "load_npc_config")
  local npctype_ini_config = nx_value("npctype_ini_config")
  if nx_is_valid(npctype_ini_config) then
    local file_list = npctype_ini_config:GetChild("file")
    if nx_is_valid(file_list) then
      local file_table = file_list:GetChildList()
      local file_count = table.getn(file_table)
      for i = 1, file_count do
        if file_name == "" then
          file_name = work_path .. file_table[i].value
        else
          file_name = file_name .. "*" .. work_path .. file_table[i].value
        end
      end
    end
  end
  return file_name
end
function menu_lock_npc_file_click(self)
  delete_right_button_menu()
  local file_name = produce_npc_file_list()
  if file_name ~= "" then
    nx_execute("form_task\\public_svn", "svn_lock", file_name)
  end
  return 1
end
function menu_unlock_npc_file_click(self)
  delete_right_button_menu()
  local file_name = produce_npc_file_list()
  if file_name ~= "" then
    nx_execute("form_task\\public_svn", "svn_unlock", file_name)
  end
  return 1
end
function menu_submit_npc_file_click(self)
  delete_right_button_menu()
  local file_name = produce_npc_file_list()
  if file_name ~= "" then
    nx_execute("form_task\\public_svn", "svn_commit", file_name)
  end
  return 1
end
local get_tmp_data_table = function()
  local task_npc_info = {}
  local ini = nx_create("IniDocument")
  local work_path = nx_value("work_path")
  ini.FileName = work_path .. COMMON_NPC
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 1
  end
  local sect_list = ini:GetSectionList()
  local sect_count = table.getn(sect_list)
  for i = 1, sect_count do
    local sect_name = sect_list[i]
    local prop_list = {
      "@TaskCanSubmit",
      "@TaskCanAccept"
    }
    for j = 1, table.getn(prop_list) do
      local prop = prop_list[j]
      local value_list = ini:GetItemValueList(sect_name, prop)
      for k = 1, table.getn(value_list) do
        if nil == task_npc_info[value_list[k]] then
          task_npc_info[value_list[k]] = {}
        end
        if nil == task_npc_info[value_list[k]][prop] then
          task_npc_info[value_list[k]][prop] = {}
        end
        local npc_list = task_npc_info[value_list[k]][prop]
        local count = table.getn(npc_list)
        npc_list[count + 1] = sect_name
      end
    end
  end
  nx_destroy(ini)
  return task_npc_info
end
function check_common_npc_config(ini, task_id, prop, old_npc_id, new_npc_id)
  if old_npc_id == new_npc_id then
    return 0
  end
  if old_npc_id ~= "" and old_npc_id ~= nil and ini:FindSection(old_npc_id) then
    local value_list = ini:GetItemValueList(old_npc_id, prop)
    while ini:DeleteItem(old_npc_id, prop) do
    end
    for j = 1, table.getn(value_list) do
      if value_list[j] ~= task_id then
        ini:AddString(old_npc_id, prop, value_list[j])
      end
    end
  end
  if new_npc_id ~= "" and new_npc_id ~= nil and ini:FindSection(new_npc_id) then
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
  return 1
end
local save_task_node_npc = function(ini, task_npc_info, task_info)
  if not nx_find_custom(task_info, "AcceptNpc") or not nx_find_custom(task_info, "SubmitNpc") then
    nx_execute("form_task\\form_task_info", "load_task_item", task_info)
  end
  local accept_npc = nx_custom(task_info, "AcceptNpc")
  local submit_npc = nx_custom(task_info, "SubmitNpc")
  local accept_npc_exist = false
  local submit_npc_exist = false
  if nil ~= task_npc_info[task_info.ID] then
    if nil ~= task_npc_info[task_info.ID]["@TaskCanSubmit"] then
      local npc_list = task_npc_info[task_info.ID]["@TaskCanSubmit"]
      local count = table.getn(npc_list)
      if 2 <= count then
        nx_msgbox("Error : @TaskCanSubmit=" .. task_info.ID .. "  \179\246\207\214\182\224\180\206")
      end
      for k = 1, count do
        if npc_list[k] == submit_npc then
          submit_npc_exist = true
        else
          check_common_npc_config(ini, task_info.ID, "@TaskCanSubmit", npc_list[k], "")
        end
      end
    end
    if nil ~= task_npc_info[task_info.ID]["@TaskCanAccept"] then
      local npc_list = task_npc_info[task_info.ID]["@TaskCanAccept"]
      local count = table.getn(npc_list)
      if 2 <= count then
        nx_msgbox("Error : @TaskCanAccept=" .. task_info.ID .. "  \179\246\207\214\182\224\180\206")
      end
      for k = 1, count do
        if npc_list[k] == accept_npc then
          accept_npc_exist = true
        else
          check_common_npc_config(ini, task_info.ID, "@TaskCanAccept", npc_list[k], "")
        end
      end
    end
  end
  if not submit_npc_exist then
    check_common_npc_config(ini, task_info.ID, "@TaskCanSubmit", "", submit_npc)
  end
  if not accept_npc_exist then
    check_common_npc_config(ini, task_info.ID, "@TaskCanAccept", "", accept_npc)
  end
  return 1
end
function menu_save_chapter_npc_click(self)
  local work_path = nx_value("work_path")
  local ini = nx_create("IniDocument")
  ini.FileName = work_path .. COMMON_NPC
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  delete_right_button_menu()
  local task_npc_info = get_tmp_data_table()
  local node = self.visual
  local task_parter_count = node:GetNodeCount()
  local task_parter_list = node:GetNodeList()
  for i = 1, task_parter_count do
    local task_parter_node = task_parter_list[i]
    local task_detail_count = task_parter_node:GetNodeCount()
    local task_detail_list = task_parter_node:GetNodeList()
    for j = 1, task_detail_count do
      local detail_node = task_detail_list[j]
      local task_info = detail_node.task_info
      save_task_node_npc(ini, task_npc_info, task_info)
    end
  end
  ini:SaveToFile()
  nx_destroy(ini)
  return 1
end
function menu_save_task_line_npc_click(self)
  local work_path = nx_value("work_path")
  local ini = nx_create("IniDocument")
  ini.FileName = work_path .. COMMON_NPC
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  delete_right_button_menu()
  local task_npc_info = get_tmp_data_table()
  local play_node = self.visual
  local task_chapter_count = play_node:GetNodeCount()
  local task_chapter_list = play_node:GetNodeList()
  for i = 1, task_chapter_count do
    local task_chapter = task_chapter_list[i]
    local task_parter_count = task_chapter:GetNodeCount()
    local task_parter_list = task_chapter:GetNodeList()
    for j = 1, task_parter_count do
      local task_parter_node = task_parter_list[j]
      local task_detail_count = task_parter_node:GetNodeCount()
      local task_detail_list = task_parter_node:GetNodeList()
      for k = 1, task_detail_count do
        local detail_node = task_detail_list[k]
        local task_info = detail_node.task_info
        save_task_node_npc(ini, task_npc_info, task_info)
      end
    end
  end
  ini:SaveToFile()
  nx_destroy(ini)
  return 1
end
function menu_save_task_npc_click(self)
  local work_path = nx_value("work_path")
  local ini = nx_create("IniDocument")
  ini.FileName = work_path .. COMMON_NPC
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 0
  end
  delete_right_button_menu()
  local task_npc_info = get_tmp_data_table()
  local root_node = self.visual
  local play_count = root_node:GetNodeCount()
  local play_list = root_node:GetNodeList()
  for i = 1, play_count do
    local play_node = play_list[i]
    local task_chapter_count = play_node:GetNodeCount()
    local task_chapter_list = play_node:GetNodeList()
    for j = 1, task_chapter_count do
      local task_chapter = task_chapter_list[j]
      local task_parter_count = task_chapter:GetNodeCount()
      local task_parter_list = task_chapter:GetNodeList()
      for m = 1, task_parter_count do
        local task_parter_node = task_parter_list[m]
        local task_detail_count = task_parter_node:GetNodeCount()
        local task_detail_list = task_parter_node:GetNodeList()
        for n = 1, task_detail_count do
          local detail_node = task_detail_list[n]
          local task_info = detail_node.task_info
          save_task_node_npc(ini, task_npc_info, task_info)
        end
      end
    end
  end
  ini:SaveToFile()
  nx_destroy(ini)
  return 1
end
function menu_relate_task_click(self)
  delete_right_button_menu()
  local task_id = nx_string(self.visual.Text)
  nx_execute("form_task\\form_task", "relate_task", task_id)
  return 1
end
function menu_set_version_click(self)
  delete_right_button_menu()
  local gui = nx_value("gui")
  local set_version_form = nx_value("set_version_form")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_version.xml")
  nx_set_value("set_version_form", dialog)
  dialog:ShowModal()
  return 1
end
function right_click(kind, x, y, visual)
  delete_right_button_menu()
  local gui = nx_value("gui")
  local operation_menu = CREATE_CONTROL("Menu")
  operation_menu.Left = x
  operation_menu.Top = y
  operation_menu.Width = 80
  operation_menu.ItemWidth = 60
  operation_menu.NoFrame = false
  operation_menu.BackColor = "255,255,255,255"
  if "Task" == kind then
    operation_menu:CreateItem("add_task_line", nx_widestr("\212\246\188\211\214\247\214\167\207\223"))
    operation_menu:CreateItem("s1", nx_widestr("-"))
    operation_menu:CreateItem("save_task_npc", nx_widestr("\177\163\180\230NPC\206\196\188\254"))
    nx_bind_script(operation_menu, nx_current(), "menu_operation_task_init")
  elseif "TaskLine" == kind then
    operation_menu:CreateItem("add_task_chapter", nx_widestr("\212\246\188\211\213\194\189\218"))
    operation_menu:CreateItem("s1", nx_widestr("-"))
    operation_menu:CreateItem("delete_task_line", nx_widestr("\201\190\179\253\214\247\214\167\207\223"))
    operation_menu:CreateItem("s2", nx_widestr("-"))
    operation_menu:CreateItem("save_task_line_npc", nx_widestr("\177\163\180\230NPC\206\196\188\254"))
    nx_bind_script(operation_menu, nx_current(), "menu_operation_task_init")
  elseif "TaskChapter" == kind then
    operation_menu:CreateItem("add_task_parter", nx_widestr("\212\246\188\211\213\194\187\216"))
    operation_menu:CreateItem("s1", nx_widestr("-"))
    operation_menu:CreateItem("delete_task_chapter", nx_widestr("\201\190\179\253\213\194\189\218"))
    operation_menu:CreateItem("s2", nx_widestr("-"))
    operation_menu:CreateItem("lock_npc_file", nx_widestr("\203\248\182\168NPC\206\196\188\254(lock)"))
    operation_menu:CreateItem("save_chapter_npc", nx_widestr("\177\163\180\230NPC\206\196\188\254"))
    operation_menu:CreateItem("unlock_npc_file", nx_widestr("\202\205\183\197NPC\206\196\188\254(unlock)"))
    operation_menu:CreateItem("submit_npc_file", nx_widestr("\204\225\189\187NPC\206\196\188\254(commit)"))
    nx_bind_script(operation_menu, nx_current(), "menu_operation_task_init")
  elseif "TaskParter" == kind then
    operation_menu:CreateItem("add_task_detail", nx_widestr("\212\246\188\211\200\206\206\241"))
    operation_menu:CreateItem("s1", nx_widestr("-"))
    operation_menu:CreateItem("modify_task_parter_name", nx_widestr("\208\222\184\196\213\194\187\216\195\251\215\214"))
    operation_menu:CreateItem("delete_task_parter", nx_widestr("\201\190\179\253\213\194\187\216"))
    operation_menu:CreateItem("s2", nx_widestr("-"))
    operation_menu:CreateItem("set_version", nx_widestr("\201\232\214\195\176\230\177\190\186\197"))
    nx_bind_script(operation_menu, nx_current(), "menu_operation_task_init")
  elseif "TaskDetail" == kind then
    operation_menu:CreateItem("add_file", nx_widestr("\212\246\188\211\206\196\188\254(add)"))
    operation_menu:CreateItem("revert_file", nx_widestr("\200\161\207\251\178\217\215\247(revert)"))
    operation_menu:CreateItem("lock_file", nx_widestr("\203\248\182\168\206\196\188\254(lock)"))
    operation_menu:CreateItem("unlock_file", nx_widestr("\202\205\183\197\206\196\188\254(unlock)"))
    operation_menu:CreateItem("submit_file", nx_widestr("\204\225\189\187\206\196\188\254(commit)"))
    operation_menu:CreateItem("s1", nx_widestr("-"))
    operation_menu:CreateItem("write_file", nx_widestr("\202\185\206\196\188\254\191\201\208\180"))
    operation_menu:CreateItem("update_file", nx_widestr("\184\252\208\194\206\196\188\254(update)"))
    operation_menu:CreateItem("merge_file", nx_widestr("\186\207\178\162\206\196\188\254(merge)"))
    operation_menu:CreateItem("s2", nx_widestr("-"))
    operation_menu:CreateItem("lock_npc_file", nx_widestr("\203\248\182\168NPC\206\196\188\254(lock)"))
    operation_menu:CreateItem("unlock_npc_file", nx_widestr("\202\205\183\197NPC\206\196\188\254(unlock)"))
    operation_menu:CreateItem("submit_npc_file", nx_widestr("\204\225\189\187NPC\206\196\188\254(commit)"))
    operation_menu:CreateItem("s3", nx_widestr("-"))
    operation_menu:CreateItem("insert_task_detail", nx_widestr("\178\229\200\235\200\206\206\241"))
    operation_menu:CreateItem("delete_task_detail", nx_widestr("\201\190\179\253\200\206\206\241"))
    operation_menu:CreateItem("s4", nx_widestr("-"))
    operation_menu:CreateItem("relate_task", nx_widestr("\185\216\193\170\181\189\182\212\187\176"))
    operation_menu:CreateItem("set_version", nx_widestr("\201\232\214\195\176\230\177\190\186\197"))
    nx_bind_script(operation_menu, nx_current(), "menu_operation_task_init")
  end
  gui.Desktop:Add(operation_menu)
  nx_set_value("operation_menu", operation_menu)
  operation_menu.visual = visual
  return 1
end
function delete_right_button_menu()
  local gui = nx_value("gui")
  local operation_menu = nx_value("operation_menu")
  if nx_is_valid(operation_menu) then
    gui.Desktop:Remove(operation_menu)
  end
  return 1
end
