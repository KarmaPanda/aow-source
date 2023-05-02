function main_form_init(self)
  self.Fixed = false
  self.path = nx_resource_path()
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.name_edit.ReadOnly = true
  self.name_edit.Text = nx_widestr(self.path)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.path_tree:CreateRootNode(gui.TextManager:GetText("ui_camera_mycomputer"))
  self.path_tree.SelectNode = update_path_tree(self)
  return 1
end
function on_main_form_close(self)
  nx_gen_event(self, "choose_file_return", "cancel")
  if nx_is_valid(self) then
    nx_destroy(self)
  end
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  local path = ""
  path = get_select_path(form)
  if path == "" then
    nx_gen_event(form, "choose_file_return", "cancel")
  else
    nx_gen_event(form, "choose_file_return", "ok", path)
  end
  form:Close()
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, "choose_file_return", "cancel")
  form:Close()
end
function on_btn_close_click(btn)
  on_btn_cancel_click(btn)
end
function show_all_drives(root)
  local fs = nx_create("FileSearch")
  local drive_table = fs:GetDriveList()
  local num = table.getn(drive_table)
  for i = 1, num do
    local drive = drive_table[i]
    local node = root:CreateNode(nx_widestr(drive))
    node.Mark = 0
  end
  nx_destroy(fs)
  root.Expand = true
  return 1
end
function show_all_dirs(node, path)
  if 1 == node.Mark then
    return
  end
  local fs = nx_create("FileSearch")
  fs:SearchDir(path)
  local num_dir = fs:GetDirCount()
  local dir_table = fs:GetDirList()
  fs:SearchFile(path, "*.9ycs")
  local num_file = fs:GetFileCount()
  local file_table = fs:GetFileList()
  for i = 1, num_dir do
    local dir = dir_table[i]
    local child = node:CreateNode(nx_widestr(dir))
    child.Font = "font_sns_event"
    child.Mark = 0
  end
  for i = 1, num_file do
    local file = file_table[i]
    local child = node:CreateNode(nx_widestr(file))
    child.Mark = 1
  end
  nx_destroy(fs)
  node.Expand = true
  node.Font = "font_sns_event"
  return 1
end
function update_path_tree(form)
  local path = nx_string(form.name_edit.Text)
  local tree = form.path_tree
  tree:BeginUpdate()
  local node = tree.RootNode
  local start = 1
  local pos = string.find(path, "\\", start)
  while pos ~= nil do
    local dir = string.sub(path, start, pos - 1)
    node:ClearNode()
    local child = node:CreateNode(nx_widestr(dir))
    node.Expand = true
    node.Font = "font_sns_event"
    node.Mark = 0
    node = child
    start = pos + 1
    pos = string.find(path, "\\", start)
  end
  node.Mark = 0
  show_all_dirs(node, form.path)
  tree:EndUpdate()
  return node
end
function get_node_path(node)
  if not nx_is_valid(node) then
    return ""
  end
  if node.Level == 0 then
    return ""
  end
  local path = nx_string(node.Text)
  if 0 == node.Mark then
    path = path .. "\\"
  end
  local parent = node.ParentNode
  if nx_is_valid(parent) then
    path = get_node_path(parent) .. path
  end
  return path
end
function get_select_path(form)
  local node = form.path_tree.SelectNode
  if 1 == node.Mark then
    return get_node_path(node)
  else
    return ""
  end
end
function path_select_changed(self, node)
  local path = get_node_path(node)
  self.Parent.name_edit.Text = nx_widestr(path)
  return 1
end
function path_select_double_click(self, node)
  if 1 == node.Mark then
    return
  end
  local path = get_node_path(node)
  local parent = node.ParentNode
  if not nx_is_null(parent) then
    local num = parent:GetNodeCount()
    local child_table = parent:GetNodeList()
    for i = 1, num do
      local child = child_table[i]
      if not nx_id_equal(child, node) then
        parent:RemoveNode(child)
      end
    end
  end
  node:ClearNode()
  if nx_is_null(parent) then
    show_all_drives(node)
  else
    show_all_dirs(node, path)
  end
  return 1
end
function on_path_tree_expand_changed(self, node)
  if node.Expand then
    path_select_double_click(self, node)
  end
end
