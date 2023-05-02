function need_add_node(dir, find_str)
  if find_str == "" then
    return true
  end
  if nil == string.find(dir, find_str) then
    return false
  end
  return true
end
function depth_first_search(node, filter, filter_node_list)
  if need_add_node(nx_string(node.Text), filter) then
    local child = filter_node_list:CreateChild("")
    node.useful_node = true
    child.obj = node
  end
  local count = node:GetNodeCount()
  local node_list = node:GetNodeList()
  for i = 1, count do
    depth_first_search(node_list[i], filter, filter_node_list)
  end
  return 1
end
function make_expand_and_parent(node)
  if not nx_is_valid(node) then
    return 0
  end
  node.Expand = true
  node.useful_node = true
  local parent_node = node.ParentNode
  if nx_is_valid(parent_node) then
    make_expand_and_parent(parent_node)
  end
  return 1
end
function make_close_and_child(node)
  node.Expand = false
  node.useful_node = true
  local count = node:GetNodeCount()
  local node_list = node:GetNodeList()
  for i = 1, count do
    make_close_and_child(node_list[i])
  end
  return 1
end
local function clear_none_useful_node(node)
  if not nx_is_valid(node) then
    return 0
  end
  if not nx_find_custom(node, "useful_node") or not node.useful_node then
    local parent_node = node.ParentNode
    if nx_is_valid(parent_node) then
      parent_node:RemoveNode(node)
    end
  end
  if nx_is_valid(node) then
    local count = node:GetNodeCount()
    local node_list = node:GetNodeList()
    for i = 1, count do
      clear_none_useful_node(node_list[i])
    end
  end
  return 1
end
function set_filter(root_node, filter)
  if filter ~= "" then
    local filter_node_list = nx_create("ArrayList", nx_current())
    depth_first_search(root_node, filter, filter_node_list)
    local filter_node_count = filter_node_list:GetChildCount()
    for i = 0, filter_node_count - 1 do
      local child = filter_node_list:GetChildByIndex(i)
      make_expand_and_parent(child.obj.ParentNode, filter)
      local count = child.obj:GetNodeCount()
      local node_list = child.obj:GetNodeList()
      for j = 1, count do
        make_close_and_child(node_list[j])
      end
    end
    clear_none_useful_node(root_node)
    nx_destroy(filter_node_list)
  end
  return 1
end
function set_filter_by_tree(node, data_tree, filter_str)
  local data_item_list = data_tree:GetChildList()
  for i = 1, table.getn(data_item_list) do
    local data_item = data_item_list[i]
    local child_count = data_item:GetChildCount()
    if child_count ~= 0 or need_add_node(string.lower(data_item.Name), filter_str) then
      local child_node = node:CreateNode(nx_widestr(data_item.Name))
      set_filter_by_tree(child_node, data_item, filter_str)
    end
  end
  return 1
end
function update_tree_scrollbar_pos(tree, node)
  local root_node = tree.RootNode
  local expand_node_list = tree:GetAllNodeList()
  local all_expand_count = table.getn(expand_node_list)
  if all_expand_count == 0 then
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
  tree.VScrollBar.Value = pre_num
  return 1
end
