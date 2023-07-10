function main_form_init(self)
  self.Fixed = false
  self.path = nx_resource_path()
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.name_edit.ReadOnly = true
  self.name_edit.Text = nx_widestr(self.path)
  self.path_tree:CreateRootNode(nx_widestr("\206\210\181\196\181\231\196\212"))
  self.path_tree.SelectNode = update_path_tree(self)
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  local path = get_select_path(form)
  form:Close()
  nx_gen_event(form, "filepath_return", "ok", path)
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "filepath_return", "cancel")
  nx_destroy(form)
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  nx_gen_event(form, "filepath_return", "cancel")
  nx_destroy(form)
end
function show_all_drives(root)
  local fs = nx_create("FileSearch")
  local drive_table = fs:GetDriveList()
  local num = table.getn(drive_table)
  for i = 1, num do
    local drive = drive_table[i]
    local node = root:CreateNode(nx_widestr(drive))
  end
  nx_destroy(fs)
  root.Expand = true
  return 1
end
function show_all_dirs(node, path)
  local fs = nx_create("FileSearch")
  fs:SearchDir(path)
  local num = fs:GetDirCount()
  local dir_table = fs:GetDirList()
  for i = 1, num do
    local dir = dir_table[i]
    if not string.find(dir, ".svn") then
      local child = node:CreateNode(nx_widestr(dir))
      child.Font = "font_sns_event"
    end
  end
  nx_destroy(fs)
  node.Expand = true
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
    if not string.find(dir, ".svn") then
      node:ClearNode()
      local child = node:CreateNode(nx_widestr(dir))
      node.Expand = true
      node.Font = "font_sns_event"
      node = child
      start = pos + 1
      pos = string.find(path, "\\", start)
    end
  end
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
function path_select_changed(self, node)
  local path = get_node_path(node)
  self.Parent.name_edit.Text = nx_widestr(path)
  return 1
end
function path_select_double_click(self, node)
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
