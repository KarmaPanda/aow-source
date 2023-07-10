function main_form_init(self)
  self.Fixed = false
  self.path = nx_resource_path()
  self.ext = "*.*"
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local combo = self.type_combo
  combo.Text = nx_widestr(self.ext)
  combo.DropListBox:AddString(nx_widestr(self.ext))
  if self.ext ~= "*.*" then
    combo.DropListBox:AddString(nx_widestr("*.*"))
  end
  update_path_tree(self)
  update_file_list(self)
  self.path_tree.SelectNode = self.path_tree.RootNode
  self.pict_width = self.sample_pict.Width
  self.pict_height = self.sample_pict.Height
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  local path = get_select_path(form)
  local file = nx_string(form.name_edit.Text)
  form:Close()
  nx_gen_event(form, "pictfile_return", "ok", path .. file)
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "pictfile_return", "cancel")
  nx_destroy(form)
  return 1
end
function update_path_node(form, node)
  local path = form.path .. get_node_path(node)
  node:ClearNode()
  local fs = nx_create("FileSearch")
  fs:SearchDirEx(path, "*")
  local dir_table = fs:GetDirList()
  for i = 1, table.getn(dir_table) do
    local dir = dir_table[i]
    local child = node:CreateNode(nx_widestr(dir))
    child.Expand = false
    child.update = false
    local dummy = child:CreateNode(nx_widestr("."))
  end
  nx_destroy(fs)
  node.update = true
  return 1
end
function update_path_tree(form)
  local tree = form.path_tree
  tree:BeginUpdate()
  local root = tree:CreateRootNode(nx_widestr("\215\202\212\180\196\191\194\188"))
  root.Expand = true
  root.update = false
  update_path_node(form, root)
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
function path_expand_changed(self, node)
  if not node.Expand then
    return 0
  end
  if node.update then
    return 0
  end
  local form = self.Parent
  form.path_tree:BeginUpdate()
  update_path_node(form, node)
  form.path_tree:EndUpdate()
  return 1
end
function file_select_changed(self, old)
  local form = self.Parent
  form.name_edit.Text = self.SelectString
  local file_name = get_select_path(form) .. nx_string(self.SelectString)
  local name, ext = nx_function("ext_split_file_name", file_name)
  if ext == "" then
    return 0
  end
  local pict = form.sample_pict
  pict.Image = form.path .. file_name
  local w = pict.ImageWidth
  local h = pict.ImageHeight
  if w > form.pict_width then
    w = form.pict_width
  end
  if h > form.pict_height then
    h = form.pict_height
  end
  form.sample_pict.NoFrame = true
  form.sample_pict.Width = w
  form.sample_pict.Height = h
  form.pictfile_label.Text = nx_widestr("\206\196\188\254\163\186" .. file_name)
  form.format_label.Text = nx_widestr("\185\230\184\241\163\186" .. nx_string(pict.ImageWidth) .. "X" .. nx_string(pict.ImageHeight) .. "," .. pict.ImageFormat)
  return 1
end
