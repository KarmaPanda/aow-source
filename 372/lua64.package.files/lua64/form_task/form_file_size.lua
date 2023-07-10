local TASK_DIR = "ini\\Task\\"
local FILE = 1
local DIR = 2
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  init_form(self)
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function close_button_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
local function build_tree(node, file_search)
  file_search:SearchFile(node.dir, "*")
  local file_table = file_search:GetFileList()
  local file_count = table.getn(file_table)
  for i = 1, file_count do
    if file_table[i] ~= ".svn" then
      local child_node = node:CreateNode(nx_widestr(file_table[i]))
      child_node.Text = nx_widestr(file_table[i])
      child_node.dir = node.dir
      child_node.type = FILE
    end
  end
  file_search:SearchDir(node.dir)
  local dir_table = file_search:GetDirList()
  local dir_count = table.getn(dir_table)
  for i = 1, dir_count do
    if dir_table[i] ~= ".svn" then
      local child_node = node:CreateNode(nx_widestr(dir_table[i]))
      child_node.Text = nx_widestr(dir_table[i])
      child_node.dir = node.dir .. dir_table[i] .. "\\"
      child_node.type = DIR
      build_tree(child_node, file_search)
    end
  end
end
function init_form(form)
  local work_path = nx_value("work_path")
  local root = form.file_tree:CreateRootNode(nx_widestr(TASK_DIR))
  root.dir = work_path .. TASK_DIR
  root.type = DIR
  local file_search = nx_create("FileSearch")
  build_tree(root, file_search)
  root.Expand = true
  nx_destroy(file_search)
  return 1
end
local function get_node_size(node)
  if node.type == FILE then
    local file_size = nx_function("ext_get_file_size", node.dir .. nx_string(node.Text))
    return file_size, 1
  elseif node.type == DIR then
    local node_list = node:GetNodeList()
    local node_count = node:GetNodeCount()
    local sum = 0
    local num = 0
    for i = 1, node_count do
      local child_sum, child_num = get_node_size(node_list[i])
      sum = sum + child_sum
      num = num + child_num
    end
    return sum, num
  end
  return 0, 0
end
function file_tree_select_changed(self, node)
  local form = self.Parent
  local sum, num = get_node_size(node)
  local kb = nx_decimals(sum / 1024, 1)
  local mb = nx_decimals(kb / 1024, 2)
  if 1024 > nx_number(kb) then
    form.info_label.Text = nx_widestr(kb) .. nx_widestr(" KB")
  else
    form.info_label.Text = nx_widestr(mb) .. nx_widestr(" MB")
  end
  form.file_num_label.Text = nx_widestr(num)
  return 1
end
