require("util_functions")
require("util_gui")
local IMAGE_INFO = "ini\\ui\\freshman\\image_info.ini"
local FRESHMAN_NODE = "ini\\ui\\freshman\\freshman_node.ini"
local CHILD_FORM_NAME = "form_stage_main\\form_freshman\\form_freshman_particularize"
local FRESHMAN_PROMPT = "form_stage_main\\form_freshman\\form_freshman_prompt"
local special_list = {
  "lilianyindao",
  "zuowangongxiulian",
  "wuguanyindao",
  "dazuotiaoxi",
  "qinggongyindao",
  "anqiyindao",
  "neixiuyindao"
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
function util_open_form(name, first_flag)
  local data_list = util_split_string(name, ",")
  local node_name = data_list[table.getn(data_list)]
  load_help_info()
  local tree_info_list = get_global_list("freshman_tree_info")
  local condition_mgr = nx_value("ConditionManager")
  local client_player = get_player()
  refresh_node_info(condition_mgr, client_player, tree_info_list)
  for i, special_name in ipairs(special_list) do
    if special_name == node_name then
      local node = find_node(tree_info_list, node_name)
      if nx_is_valid(node) then
        local node_mark = get_node_mark(node)
        nx_execute(FRESHMAN_PROMPT, "util_open_freshman_prompt", node_mark)
        node.is_open = true
        node.is_recommend = true
      else
        nx_execute(FRESHMAN_PROMPT, "util_open_freshman_prompt", node_name)
      end
      return true
    end
  end
  if nil ~= node_name and "" ~= node_name then
    local node = find_node(tree_info_list, node_name)
    if nx_is_valid(node) then
      node.is_open = true
      node.is_recommend = true
    end
  end
  local mark_node = nx_null()
  local node = find_node(tree_info_list, "crjh1")
  local localtime64 = client_player:QueryProp("VipCreateTime")
  local create_time = nx_function("ext_get_localtime", localtime64)
  local repute_jianghu = get_player_repute_record_jianghu(client_player)
  if nx_int(create_time) < nx_int(20120525) or 700 <= repute_jianghu then
    util_show_form(nx_current(), true)
  elseif nx_is_valid(node) then
    child_list = node:GetChildList()
    local count = table.getn(child_list)
    for i, child in ipairs(child_list) do
      if not child.is_open then
        local mark = get_node_mark(mark_node)
        nx_execute(CHILD_FORM_NAME, "util_open_fresman_info", mark, first_flag)
        return true
      elseif count == i then
        local mark = get_node_mark(child)
        if check_node_valid(child.mark_name) then
          nx_execute(CHILD_FORM_NAME, "util_open_fresman_info", mark, first_flag)
          return true
        end
      end
      mark_node = child
    end
  end
  util_show_form(nx_current(), true)
  return true
end
function add_freshman_node(name)
  local data_list = util_split_string(name, ",")
  local node_name = data_list[table.getn(data_list)]
  for i, special_name in ipairs(special_list) do
    if special_name == node_name then
      nx_execute(FRESHMAN_PROMPT, "util_open_freshman_prompt", node_name)
      return true
    end
  end
  load_help_info()
  local tree_info_list = get_global_list("freshman_tree_info")
  local node = find_node(tree_info_list, node_name)
  if not nx_is_valid(node) then
    return false
  end
  node.is_open = true
  node.is_recommend = true
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    refresh_grid(form)
  end
  return true
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  load_help_info()
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("PromptFreshmanRecStr", "string", form, nx_current(), "refresh_grid")
  end
  refresh_grid(form)
  local tree_info_list = get_global_list("freshman_tree_info")
  set_node_expand(form, tree_info_list)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function clear()
  local freshman_tree_info = get_global_list("freshman_tree_info")
  nx_set_value("freshman_tree_info", nx_null())
  nx_destroy(freshman_tree_info)
end
function set_ent_property(source_node, target_node)
  if not nx_is_valid(source_node) or not nx_is_valid(target_node) then
    return
  end
  local prop_list = nx_property_list(source_node)
  for i, prop in ipairs(prop_list) do
    local value = nx_property(target_node, prop)
    local custom_type = nx_type(value)
    if "number" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_number(nx_property(source_node, prop)))
    elseif "string" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_property(source_node, prop))
    elseif "boolean" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_boolean(nx_property(source_node, prop)))
    end
  end
end
function load_help_info()
  local freshman_tree_info = nx_value("freshman_tree_info")
  if nx_is_valid(freshman_tree_info) and nx_int(freshman_tree_info:GetChildCount()) > nx_int(0) then
    return false
  end
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. FRESHMAN_NODE
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local item_list = ini:GetItemValueList("root", "node")
  local tree_info_list = get_new_global_list("freshman_tree_info")
  local condition_mgr = nx_value("ConditionManager")
  local client_player = get_player()
  tree_info_list.is_open = true
  tree_info_list.condition = 0
  create_node(condition_mgr, client_player, tree_info_list, ini, "root")
  nx_destroy(ini)
  return true
end
function create_node(condition_mgr, client_player, parent_node, ini, parent_item)
  local item_list = ini:GetItemValueList(parent_item, "node")
  for i, item in ipairs(item_list) do
    local is_open, name, condition = get_coincidence_info(condition_mgr, client_player, item)
    if "" ~= name then
      local node = parent_node:CreateChild(nx_string(name))
      node.parent_node = parent_node
      node.mark_name = node.Name
      node.is_open = check_node_is_open(node.mark_name)
      node.condition = condition
      node.expand = true
      node.is_recommend = false
      create_node(condition_mgr, client_player, node, ini, nx_string(name))
    end
  end
end
function get_coincidence_info(condition_mgr, client_player, content_info)
  local content_list = util_split_string(content_info, ";")
  for i, info in ipairs(content_list) do
    local info_list = util_split_string(info, ",")
    local count = table.getn(info_list)
    if nx_int(1) == nx_int(count) then
      return true, info_list[1], 0
    elseif nx_int(2) == nx_int(count) then
      local condition = nx_int(info_list[1])
      local is_open = condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(condition))
      return is_open, info_list[2], condition
    end
  end
  return false, ""
end
function get_grid_team(form, space)
  local gui = nx_value("gui")
  local child_list = form.groupbox_template:GetChildControlList()
  local group_box = gui:Create("GroupBox")
  local count = table.getn(form.groupbox_main:GetChildControlList())
  form.groupbox_main:Add(group_box)
  set_ent_property(form.groupbox_template, group_box)
  group_box.name = "group_box" .. nx_string(count)
  group_box.mark_name = space
  for i, child in ipairs(child_list) do
    local control = gui:Create(nx_name(child))
    set_ent_property(child, control)
    control.Name = space .. nx_name(child) .. child.DataSource
    control.mark_name = space
    group_box:Add(control)
  end
  return group_box
end
function refresh_node_info(condition_mgr, client_player, parent_node)
  local child_list = parent_node:GetChildList()
  for i, child in ipairs(child_list) do
    child.is_open = condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(child.condition))
    refresh_node_info(condition_mgr, client_player, child)
  end
  if nx_find_custom(parent_node, "condition") and nx_find_custom(parent_node, "mark_name") then
    parent_node.is_open = check_node_is_open(parent_node.mark_name)
  end
end
function create_grid_team(form, node)
  local child_list = node:GetChildList()
  local gui = nx_value("gui")
  local top = 0
  for i, child in ipairs(child_list) do
    local count = child:GetChildCount()
    local group_box = get_grid_team(form, child.mark_name)
    group_box.Left = 0
    group_box.Top = top
    if not child.expand then
      group_box.Height = form.groupbox_lbl_template.Height
    end
    group_box.expand = child.expand
    top = group_box.Height + top
    local child_group_box = get_group_control(group_box, child.mark_name, "GroupBox")
    create_btn_team(form, child_group_box, child)
  end
  local groupbox_template = form.groupbox_template
  form.scroll_bar_info.Maximum = top
end
function create_btn_team(form, group_box, parent_node)
  local group_box_btn_template = form.groupbox_group_template
  local child_list = group_box_btn_template:GetChildControlList()
  local gui = nx_value("gui")
  local btn_list = {}
  for i, child in ipairs(child_list) do
    local node = parent_node:GetChildByIndex(nx_int(i - 1))
    if not nx_is_valid(node) then
      btn_list_sort(btn_list)
      return
    end
    local control = gui:Create(nx_name(child))
    local text = gui.TextManager:GetText("ui_" .. node.mark_name)
    set_ent_property(child, control)
    control.Name = nx_name(child) .. nx_string(i)
    control.mark_name = node.mark_name
    control.is_open = node.is_open
    control.Enabled = node.is_open
    nx_bind_script(control, nx_current())
    nx_callback(control, "on_click", "on_btn_main_click")
    control.Text = nx_widestr(text)
    control.lbl_recommend = nx_null()
    control.lbl_finish = nx_null()
    group_box:Add(control)
    if not check_node_valid(control.mark_name) then
      local lbl_finish = gui:Create("Label")
      set_ent_property(form.lbl_finish, lbl_finish)
      lbl_finish.Name = control.mark_name .. "_Label_recommend"
      lbl_finish.Left = control.Left + control.Width - 20
      lbl_finish.Top = control.Top
      group_box:Add(lbl_finish)
      control.lbl_finish = lbl_finish
    elseif node.is_recommend then
      local lbl_recommend = gui:Create("Label")
      set_ent_property(form.lbl_recommend, lbl_recommend)
      lbl_recommend.Name = control.mark_name .. "_Label_recommend"
      lbl_recommend.Left = control.Left - 4
      lbl_recommend.Top = control.Top - 4
      group_box:Add(lbl_recommend)
      control.lbl_recommend = lbl_recommend
    end
    btn_list[i] = control
  end
  btn_list_sort(btn_list)
end
function set_grid_info_from_ini(form)
  local ini_manager = nx_value("IniManager")
  local gui = nx_value("gui")
  if not nx_is_valid(ini_manager) then
    return false
  end
  local ini = nx_null()
  if not ini_manager:IsIniLoadedToManager(IMAGE_INFO) then
    ini = ini_manager:LoadIniToManager(IMAGE_INFO)
  else
    ini_manager:UnloadIniFromManager(IMAGE_INFO)
    ini = ini_manager:LoadIniToManager(IMAGE_INFO)
  end
  if not nx_is_valid(ini) then
    return false
  end
  local parent_list = form.groupbox_main:GetChildControlList()
  for i, parent in ipairs(parent_list) do
    local group_box = get_group_control(parent, parent.mark_name, "GroupBox")
    if nx_is_valid(group_box) then
      local child_list = group_box:GetChildControlList()
      for j, child in ipairs(child_list) do
        if "Button" == nx_name(child) then
          local index = ini:FindSectionIndex(child.mark_name)
          if -1 ~= index then
            child.normal_image = ini:ReadString(index, "normal_image", "")
            child.focus_image = ini:ReadString(index, "focus_image", "")
            child.push_image = ini:ReadString(index, "push_image", "")
            child.disable_image = ini:ReadString(index, "disable_image", "")
            if j == 1 then
              set_image_info(child)
            end
          end
        end
      end
    end
    local btn = get_group_control(parent, parent.mark_name, "Button" .. "title")
    if nx_is_valid(btn) then
      local text = gui.TextManager:GetText("ui_" .. btn.mark_name)
      btn.Text = nx_widestr(text)
      btn.expand = parent.expand
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_grid_zoom_btn_click")
    end
    btn = get_group_control(parent, parent.mark_name, "Button" .. "image")
    if nx_is_valid(btn) then
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_main_image_click")
    end
  end
end
function find_node(root_node, find_mark, type_info)
  local node_list = {}
  if nil == type_info or "ArrayList" == type_info then
    node_list = root_node:GetChildList()
  elseif "TreeViewEx" == type_info or "TreeView" == type_info then
    node_list = root_node:GetNodeList()
  end
  for i, node in ipairs(node_list) do
    if nx_string(node.mark_name) == nx_string(find_mark) then
      return node
    else
      local node_find = find_node(node, find_mark, type_info)
      if nx_is_valid(node_find) then
        return node_find
      end
    end
  end
  return nil
end
function get_group_control(group_box, space, type_info)
  if nil == space or "" == space or nil == type_info or "" == type_info then
    return nx_null()
  end
  return group_box:Find(space .. type_info)
end
function on_btn_main_click(self)
  set_image_info(self)
  local group_box = self.Parent.Parent
  local form = group_box.ParentForm
  open_freshman_prompt(form, self.mark_name)
end
function on_btn_main_image_click(self)
  local mark_name = self.mark_name
  local parent = self.Parent
  local form = self.ParentForm
  if nil == mark_name or "" == mark_name or parent.mark_name == mark_name then
    return 1
  end
  open_freshman_prompt(form, mark_name)
  return 1
end
function set_image_info(self)
  local group_box = self.Parent.Parent
  local btn = get_group_control(group_box, group_box.mark_name, "Button" .. "image")
  if not nx_is_valid(btn) then
    return
  end
  btn.NormalImage = self.normal_image
  btn.FocusImage = self.focus_image
  btn.PushImage = self.push_image
  btn.DisableImage = self.disable_image
  btn.Enabled = self.is_open
  btn.mark_name = self.mark_name
end
function open_freshman_prompt(form, mark_name)
  local tree_info_list = get_global_list("freshman_tree_info")
  local node = find_node(tree_info_list, mark_name)
  if not nx_is_valid(node) then
    return 1
  end
  local child_list = node:GetChildList()
  form.Visible = false
  for i, child in ipairs(child_list) do
    if child.is_open then
      nx_execute(CHILD_FORM_NAME, "util_open_fresman_info", get_node_mark(child))
      main_form_change(false)
      return 1
    end
  end
  nx_execute(CHILD_FORM_NAME, "util_open_fresman_info", get_node_mark(node))
  main_form_change(false)
end
function refresh_grid(form)
  form.groupbox_main:DeleteAll()
  local tree_info_list = get_global_list("freshman_tree_info")
  local condition_mgr = nx_value("ConditionManager")
  local client_player = get_player()
  refresh_node_info(condition_mgr, client_player, tree_info_list)
  create_grid_team(form, tree_info_list)
  set_grid_info_from_ini(form)
  form.groupbox_main:ResetChildrenYPos()
end
function btn_list_sort(btn_list)
  local flag = 1
  local top = 1
  local left = 1
  for i, btn in ipairs(btn_list) do
    if btn.Enabled then
      local o_btn = btn_list[flag]
      local lbl_finish = nx_null()
      local lbl_recommend = nx_null()
      left = btn.Left
      top = btn.Top
      btn.Left = o_btn.Left
      btn.Top = o_btn.Top
      o_btn.Left = left
      o_btn.Top = top
      btn_list[flag] = btn
      btn_list[i] = o_btn
      if nx_find_custom(btn, "lbl_finish") and nx_is_valid(btn.lbl_finish) then
        btn.lbl_finish.Left = btn.Left + btn.Width - 20
        btn.lbl_finish.Top = btn.Top
      end
      if nx_find_custom(btn, "lbl_recommend") and nx_is_valid(btn.lbl_recommend) then
        btn.lbl_recommend.Left = btn.Left - 4
        btn.lbl_recommend.Top = btn.Top - 4
      end
      if nx_find_custom(o_btn, "lbl_finish") and nx_is_valid(o_btn.lbl_finish) then
        o_btn.lbl_finish.Left = o_btn.Left + o_btn.Width - 20
        o_btn.lbl_finish.Top = o_btn.Top
      end
      if nx_find_custom(o_btn, "lbl_recommend") and nx_is_valid(o_btn.lbl_recommend) then
        o_btn.lbl_recommend.Left = o_btn.Left - 4
        o_btn.lbl_recommend.Top = o_btn.Top - 4
      end
      flag = i + 1
    end
  end
end
function main_form_change(vis)
  local main_form = nx_value(nx_current())
  local child_form = nx_value(CHILD_FORM_NAME)
  if not nx_is_valid(main_form) then
    return 1
  end
  if vis then
    main_form.Visible = vis
    if nx_is_valid(child_form) then
      child_form.Visible = not vis
      main_form.Left = child_form.Left
      main_form.Top = child_form.Top
    end
  else
    main_form.Visible = vis
    if nx_is_valid(child_form) then
      child_form.Visible = not vis
      child_form.Left = main_form.Left
      child_form.Top = main_form.Top
    end
  end
end
function check_node_valid(node_name)
  local index = get_node_indx(node_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(-1) == nx_int(index) then
    return false
  end
  local str_rec = client_player:QueryProp("FinishFreshmanRecStr")
  local value = nx_function("get_str_rec_flag", str_rec, index - 1)
  return not value
end
function check_node_is_open(node_name)
  local index = get_node_indx(node_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(-1) == nx_int(index) then
    return false
  end
  local str_rec = client_player:QueryProp("PromptFreshmanRecStr")
  local value = nx_function("get_str_rec_flag", str_rec, index - 1)
  return value
end
function get_node_indx(node_name)
  local ini_doc = nx_call("util_functions", "get_ini", "share\\Rule\\Freshman.ini")
  if not nx_is_valid(ini_doc) then
    return
  end
  local size = ini_doc:GetSectionCount() - 1
  for n_index = 0, size do
    if node_name == ini_doc:GetSectionItemValue(n_index, 0) then
      return nx_number(ini_doc:GetSectionByIndex(n_index))
    end
  end
  return -1
end
function get_node_mark(node)
  local child_list = node:GetChildList()
  local condition_mgr = nx_value("ConditionManager")
  local client_player = get_player()
  for i, child in ipairs(child_list) do
    if 0 ~= child.condition then
      local is_open = condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(child.condition))
      if is_open then
        child.is_open = check_node_is_open(child.mark_name)
        return child.mark_name
      end
    else
      return child.mark_name
    end
  end
  return node.mark_name
end
function on_grid_zoom_btn_click(self)
  local form = self.Parent.Parent.ParentForm
  self.expand = not self.expand
  if self.expand then
    self.Parent.Height = form.groupbox_template.Height
  else
    self.Parent.Height = self.Height
  end
  local tree_info_list = get_global_list("freshman_tree_info")
  local node = find_node(tree_info_list, self.mark_name)
  if nx_is_valid(node) then
    node.expand = self.expand
  end
  form.groupbox_main:ResetChildrenYPos()
end
function set_node_expand(form, node)
  local parent_list = node:GetChildList()
  for i, parent in ipairs(parent_list) do
    local child_list = parent:GetChildList()
    local size = table.getn(child_list)
    local expand = true
    local is_total_finish = false
    for j = 1, size - 1 do
      local node_a = child_list[j]
      local node_b = child_list[j + 1]
      local child_a = check_node_valid(node_a.mark_name)
      expand = expand and node_a.is_open == node_b.is_open or false
      if node_a.is_open and child_a then
        expand = false
      end
      if node_a.is_open and not child_a then
        is_total_finish = true
      else
        is_total_finish = false
      end
    end
    if expand then
    end
    parent.is_total_finish = is_total_finish
    parent.expand = not expand
  end
  set_grid_expand(form)
end
function set_grid_expand(form)
  local parent = form.groupbox_main
  local child_list = parent:GetChildControlList()
  local tree_info_list = get_global_list("freshman_tree_info")
  local node_list = tree_info_list:GetChildList()
  local lbl_total_finish = form.lbl_total_finish
  local gui = nx_value("gui")
  for i, child in ipairs(child_list) do
    local node = node_list[i]
    local btn = get_group_control(child, child.mark_name, "Button" .. "title")
    if node.expand then
      child.Height = form.groupbox_template.Height
    else
      child.Height = btn.Height
    end
    if node.is_total_finish then
      local control = gui:Create(nx_name(lbl_total_finish))
      set_ent_property(lbl_total_finish, control)
      control.Left = btn.Left
      control.Top = btn.Top
      child:Add(control)
    end
    btn.expand = node.expand
  end
  form.groupbox_main:ResetChildrenYPos()
end
function get_player_repute_record_jianghu(client_player)
  if not nx_is_valid(client_player) then
    return 0
  end
  local rows = client_player:FindRecordRow("Repute_Record", 0, nx_string("repute_jianghu"), 0)
  if -1 == rows then
    return 0
  end
  return client_player:QueryRecord("Repute_Record", rows, 1)
end
