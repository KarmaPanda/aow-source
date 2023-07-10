function main_form_init(self)
  self.Fixed = false
  self.path = ""
  self.ext = "*.*|*.ini|*.txt"
  return 1
end
local is_first_time = true
function main_form_open(self)
  if not is_first_time then
    return
  end
  is_first_time = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local combo = self.type_combo
  local str_list = nx_function("ext_split_string", self.ext, "|")
  for i = 1, table.getn(str_list) do
    combo.DropListBox:AddString(nx_widestr(str_list[i]))
  end
  update_path_tree(self)
  update_file_list(self)
  self.path_tree.SelectNode = self.path_tree.RootNode
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  local path = get_select_path(form)
  local file = nx_string(form.name_edit.Text)
  form:Close()
  nx_gen_event(form, "pictfile_return", "ok", path .. file)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "pictfile_return", "cancel")
  return 1
end
function update_path_tree_node(root, path)
  local fs = nx_create("FileSearch")
  fs:SearchDir(path)
  local num = fs:GetDirCount()
  local dir_table = fs:GetDirList()
  for i = 1, num do
    local dir = dir_table[i]
    if not string.find(dir, ".svn") then
      local node = root:CreateNode(nx_widestr(dir))
      node.Expand = false
      update_path_tree_node(node, path .. dir .. "\\")
    end
  end
  nx_destroy(fs)
  return 1
end
function update_path_tree(form)
  local tree = form.path_tree
  tree:BeginUpdate()
  local root = tree:CreateRootNode(nx_widestr("\215\202\212\180\196\191\194\188"))
  root.Expand = true
  update_path_tree_node(root, form.path)
  tree:EndUpdate()
  return 1
end
function get_node_path(node)
  if not nx_is_valid(node) then
    return ""
  end
  if node.Level == 0 then
    return ""
  end
  local path = nx_string(node.Text) .. "\\"
  local parent = node.ParentNode
  if nx_is_valid(parent) then
    path = get_node_path(parent) .. path
  end
  return path
end
function get_select_path(form)
  local node = form.path_tree.SelectNode
  return get_node_path(node)
end
function add_file_list(form, path, ext)
  local list = form.file_list
  local fs = nx_create("FileSearch")
  fs:SearchFile(path, ext)
  local file_table = fs:GetFileList()
  for i = 1, table.getn(file_table) do
    list:AddString(nx_widestr(file_table[i]))
  end
  nx_destroy(fs)
  return true
end
function update_file_list(form)
  local list = form.file_list
  list:BeginUpdate()
  list:ClearString()
  local path = form.path .. get_select_path(form)
  local ext = nx_string(form.type_combo.Text)
  local pos = string.find(ext, "|")
  while pos ~= nil do
    local file_ext = string.sub(ext, 1, pos - 1)
    if file_ext ~= "" then
      add_file_list(form, path, file_ext)
    end
    ext = string.sub(ext, pos + 1)
    pos = string.find(ext, "|")
  end
  if ext ~= "" then
    add_file_list(form, path, ext)
  end
  list:EndUpdate()
  return 1
end
function path_select_changed(self, node)
  update_file_list(self.Parent)
  return 1
end
function file_select_changed(self, old)
  local form = self.Parent
  form.name_edit.Text = self.SelectString
  return 1
end
function type_combo_selected(self)
  update_file_list(self.Parent)
end
