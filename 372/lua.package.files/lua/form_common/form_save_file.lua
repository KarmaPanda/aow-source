function util_save_file(ext)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return nx_null()
    end
    form.ext = ext
    form:Show()
  end
  form.ext = ext
  return form
end
function util_save_file_with_abspath(ext, open_path)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return nx_null()
    end
    form.ext = ext
    form.path = open_path
    form:Show()
  end
  form.ext = ext
  return form
end
function main_form_init(self)
  self.Fixed = false
  self.path = nx_resource_path()
  self.ext = "*.*"
  self.file_name_ext = ""
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
  local dotext = self.ext
  local showext = string.sub(dotext, 2, string.len(dotext))
  self.lbl_ext.Text = nx_widestr(showext)
  return 1
end
function on_main_form_close(self)
  nx_gen_event(self, "save_file_return", "cancel")
  if nx_is_valid(self) then
    nx_destroy(self)
  end
  return 1
end
function ok_btn_click(self)
  local form = self.ParentForm
  local path = get_edit_path(form)
  nx_gen_event(form, "save_file_return", "ok", path, form.file_name_ext)
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, "save_file_return", "cancel")
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
function show_all_dirs(node, path, ext)
  if 1 == node.Mark then
    return
  end
  local fs = nx_create("FileSearch")
  fs:SearchDir(path)
  local num_dir = fs:GetDirCount()
  local dir_table = fs:GetDirList()
  fs:SearchFile(path, ext)
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
  show_all_dirs(node, form.path, form.ext)
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
function get_edit_path(form)
  local node = form.path_tree.SelectNode
  if 1 == node.Mark then
    return get_node_path(node)
  else
    local dir = get_node_path(node)
    local dotext = form.ext
    local showext = string.sub(dotext, 2, string.len(dotext))
    local path = dir .. nx_string(form.file_name_edit.Text) .. showext
    return path
  end
end
function path_select_changed(self, node)
  local path = get_node_path(node)
  self.Parent.name_edit.Text = nx_widestr(path)
  if 1 == node.Mark then
    local str_NodeText = nx_string(node.Text)
    self.Parent.file_name_ext = str_NodeText
    local i = 0
    local index = 1
    while true do
      i = string.find(str_NodeText, "%.", i + 1)
      if i == nil then
        break
      end
      index = i
    end
    local filename = string.sub(str_NodeText, 1, index - 1)
    self.Parent.file_name_edit.Text = nx_widestr(filename)
  end
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
    local form = self.ParentForm
    show_all_dirs(node, path, form.ext)
  end
  return 1
end
function on_path_tree_expand_changed(self, node)
  if node.Expand then
    path_select_double_click(self, node)
  end
end
