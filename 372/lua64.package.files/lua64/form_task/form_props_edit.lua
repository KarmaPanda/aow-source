require("form_task\\common")
require("form_task\\public_svn")
require("form_task\\task_public_func")
require("theme")
require("form_task\\tool")
local CurEditorRow = -1
local CurEditorGrid
local ini_table = {
  create_item_config = "editor\\ini\\new_item_config.ini"
}
function open_props_edit_form()
  local form_prop_edit = nx_value("prop_edit_form")
  if nx_is_valid(form_prop_edit) then
    return form_prop_edit
  end
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_props_edit.xml")
  nx_set_value("form_prop_edit", dialog)
  dialog:Show()
  return 1
end
function open_props_edit_form()
  local form_prop_edit = nx_value("prop_edit_form")
  if nx_is_valid(form_prop_edit) then
    return form_prop_edit
  end
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_props_edit.xml")
  nx_set_value("form_prop_edit", dialog)
  dialog:Show()
  return 1
end
function main_form_open(self)
  local basis_props = self.props_basis
  init_res(self)
  init_text_grid(self)
  init_combobox_all_pack(self)
  self.btn_ok.Enabled = false
  nx_set_custom(self.textgrid_public, "edit_callback", "edit_enter_public_grid")
  self.menu_right_click.Visible = false
  btn_enabled(self, false)
  self.Fixed = false
  return 1
end
function main_form_close(self)
  local itme_logic_ini = nx_value("itme_logic_ini")
  local itme_task_ini = nx_value("itme_task_ini")
  local itme_task_ini = nx_value("itme_func_ini")
  local content_form = nx_value("content_form")
  if nx_is_valid(content_form) then
    content_form.content_tree.SelectNode = content_form.content_tree.RootNode
  end
  if nx_is_valid(itme_logic_ini) then
    nx_destroy(itme_logic_ini)
  end
  if nx_is_valid(itme_task_ini) then
    nx_destroy(itme_task_ini)
  end
  if nx_is_valid(itme_func_ini) then
    nx_destroy(itme_func_ini)
  end
  nx_destroy(self)
  return 1
end
function btn_close_form_click(self)
  local form = self.Parent
  if not (ask_save_file("itme_logic_ini") and ask_save_file("itme_task_ini")) or not ask_save_file("itme_func_ini") then
    return 1
  end
  local root_node = form.props_tree.RootNode
  local node_list = {}
  if nx_is_valid(root_node) then
    node_list = root_node:GetNodeList()
  end
  for i, node in pairs(node_list) do
    if not ask_save_file(nx_string(node.Mark)) then
      return 1
    end
  end
  self.Parent:Close()
  return 1
end
function ask_save_file(name)
  local node = get_global_ini_data(name)
  if nx_find_custom(node, "Edit") and nx_string(nx_custom(node, "Edit")) == "true" then
    local path = get_config_prop(name, "IniPath")
    local res = ask("\206\196\188\254" .. path .. "\210\209\190\173\184\196\182\175\202\199\183\241\208\232\210\170\177\163\180\230\163\191")
    if res == "yes" then
      save_to_file(name)
    elseif res == "cancel" then
      return false
    end
  end
  nx_set_custom(node, "Edit", false)
  return true
end
function btn_enabled(form, enabled)
  form.props_basis.Enabled = enabled
  form.props_image.Enabled = enabled
  form.prop_name_text.Enabled = enabled
  form.prop_desc_text.Enabled = enabled
  form.redit_desc.Enabled = enabled
  form.ipt_name.Enabled = enabled
  form.public_pack.Enabled = enabled
  form.combobox_all_pack.Enabled = enabled
  form.combobox_desc.Enabled = enabled
  return 1
end
function get_txt_data(key, value)
  local all_list = {}
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = nx_resource_path() .. "editor\\ini\\prop_config.txt"
  if not textgrid:LoadFromFile(2) then
    nx_destroy(textgrid)
    return all_list
  end
  for i = 0, textgrid.RowCount - 1 do
    local buf = textgrid:GetValueString(nx_int(i), key)
    if nx_string(buf) == nx_string(value) then
      local value_list = {}
      local name = textgrid:GetValueString(nx_int(i), "Name")
      value_list.Name = nx_string(name)
      local id = textgrid:GetValueString(nx_int(i), "ID")
      value_list.ID = nx_string(id)
      local desc = textgrid:GetValueString(nx_int(i), "Desc")
      value_list.Desc = nx_string(desc)
      local tips = textgrid:GetValueString(nx_int(i), "Tips")
      value_list.Tips = nx_string(tips)
      local back_color = textgrid:GetValueString(nx_int(i), "BackColor")
      if nx_string(back_color) == "" then
        back_color = "255,134,143,152"
      end
      value_list.BackColor = nx_string(back_color)
      all_list[table.getn(all_list) + 1] = value_list
    end
  end
  nx_destroy(textgrid)
  return all_list
end
function get_config_ini_data(name)
  local ini_data = nx_value(name)
  if not nx_is_valid(ini_data) then
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. "editor\\ini\\prop_config.ini"
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return nil
    end
    ini_data = nx_create("ArrayList", name)
    read_ini_to_data(ini, ini_data, "", "Desc")
    local section_list = ini:GetSectionList()
    for k, sect in pairs(section_list) do
      local item_value_list = ini:GetItemValueList(sect, "Desc")
      local node = ini_data:GetChild(nx_string(sect))
      for i, desc in pairs(item_value_list) do
        local c_node = node:CreateChild("Desc_" .. nx_string(i - 1))
        local tuple = util_split_string(desc, ",")
        for j, value in pairs(tuple) do
          nx_set_custom(c_node, nx_string(j), value)
        end
      end
    end
    nx_set_value(name, ini_data)
    nx_destroy(ini)
  end
  return ini_data
end
function get_config_prop(name, prop)
  local config_data = get_config_ini_data("config_ini")
  local node = config_data:GetChild(name)
  if nx_is_valid(node) then
    local value = nx_custom(node, prop)
    return nx_string(value)
  end
  return ""
end
function get_config_desc_info(item_type, props_id, index)
  local config_data = get_config_ini_data("config_ini")
  local node = config_data:GetChild(item_type)
  local child_list = node:GetChildList()
  local desc_info = {
    "",
    "",
    "",
    ""
  }
  local c_node = node:GetChild(index)
  if nx_is_valid(c_node) then
    local last_desc = nx_custom(c_node, "1")
    local next_desc = nx_custom(c_node, "2")
    local path_desc = nx_custom(c_node, "3")
    local desc_id = nx_string(last_desc) .. props_id .. nx_string(next_desc)
    desc_info = {
      last_desc,
      next_desc,
      path_desc,
      desc_id
    }
    return desc_info
  end
  return desc_info
end
function get_txt_prop_info(key1, name, key2, id, prop)
  local config = get_txt_data(key1, name)
  for i, props in pairs(config) do
    if props[key2] == id then
      return props[prop]
    end
  end
  return ""
end
function get_ini(path, is_client)
  local ini = nx_create("IniDocument")
  if not is_client then
    ini.FileName = get_work_path() .. path
  else
    ini.FileName = nx_resource_path() .. path
  end
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return nil
  end
  return ini
end
function get_global_ini_data(name)
  local ini_data = nx_value(name)
  if not nx_is_valid(ini_data) then
    local ini = nx_create("IniDocument")
    local path = get_config_prop(name, "IniPath")
    ini.FileName = get_work_path() .. path
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return nil
    end
    ini_data = nx_create("ArrayList", name)
    read_ini_to_data(ini, ini_data)
    nx_set_value(name, ini_data)
    nx_destroy(ini)
  end
  ini_data = nx_value(name)
  return ini_data
end
function get_ini_item_list(name, section)
  local node = get_global_ini_data(name)
  local c_node = node:GetChild(section)
  local item_list = {}
  if nx_is_valid(c_node) then
    item_list = nx_custom_list(c_node)
  end
  return item_list
end
function get_ini_sect_list(name)
  local node = get_global_ini_data(name)
  local sect_list = node:GetChildList()
  return sect_list
end
function create_section(name, section)
  local node = get_global_ini_data(name)
  if not node:FindChild(section) then
    node:CreateChild(section)
  end
end
function get_ini_data(name, section, key)
  local node = get_global_ini_data(name)
  local c_node = node:GetChild(section)
  if nx_is_valid(c_node) and nx_find_custom(c_node, key) then
    return nx_string(nx_custom(c_node, key))
  end
  return ""
end
function set_ini_data(name, section, key, value)
  local node = get_global_ini_data(name)
  nx_set_custom(node, "Edit", "true")
  local c_node = node:GetChild(nx_string(section))
  if nx_is_valid(c_node) then
    nx_set_custom(c_node, nx_string(key), nx_string(value))
    nx_set_custom(c_node, "Edit", "true")
  end
end
function read_ini_to_data(ini, ini_data, remove_sect, remove_key)
  local section_list = ini:GetSectionList()
  for i, sect in pairs(section_list) do
    if remove_sect ~= sect then
      local item_list = ini:GetItemList(sect)
      local node = ini_data:CreateChild(sect)
      for j, key in pairs(item_list) do
        if remove_key ~= key then
          local value = ini:ReadString(sect, key, "")
          nx_set_custom(node, key, value)
        end
      end
    end
  end
end
function init_res(form)
  local config = get_txt_data("Type", "ToolItem")
  local config_ini = get_ini(ini_table.create_item_config, true)
  local section_list = config_ini:GetSectionList()
  for i, sect in pairs(section_list) do
    local path = get_config_prop(sect, "IniPath")
    local ini = get_ini(path, false)
    if nx_is_valid(ini) then
      load_props_item(form, ini, sect)
      nx_destroy(ini)
    end
  end
  return 1
end
function init_text_grid(form)
  local props_image = form.props_image
  props_image:ClearRow()
  props_image:InsertRow(-1)
  props_image:SetGridText(0, 0, nx_widestr("Photo"))
  props_image:SetGridText(0, 1, nx_widestr("\181\192\190\223\205\188\177\234"))
  nx_set_custom(props_image, "res", "")
  local prop_name_text = form.prop_name_text
  prop_name_text:ClearRow()
  prop_name_text:InsertRow(-1)
  prop_name_text:SetGridText(0, 0, nx_widestr("\195\251\179\198\206\196\177\190\177\237"))
  nx_set_custom(prop_name_text, "res", "")
  local prop_desc_text = form.prop_desc_text
  prop_desc_text:ClearRow()
  prop_desc_text:InsertRow(-1)
  prop_desc_text:SetGridText(0, 0, nx_widestr("\203\181\195\247\206\196\177\190\177\237"))
  nx_set_custom(prop_desc_text, "res", "")
  local Image = form.image
  Image.Text = nx_widestr("")
  return 1
end
function init_combobox_all_pack(form)
  local config_data = get_config_ini_data("config_ini")
  local child_list = config_data:GetChildList()
  local drop_list_box = form.combobox_all_pack.DropListBox
  local input_edit = form.combobox_all_pack.InputEdit
  drop_list_box:ClearString()
  input_edit.Text = nx_widestr("")
  for i, node in pairs(child_list) do
    if nx_custom(node, "Type") == "Pack" then
      local value = nx_custom(node, "Name")
      drop_list_box:AddString(nx_widestr(value))
      nx_set_custom(drop_list_box, nx_string(drop_list_box.ItemCount - 1), node.Name)
    end
  end
end
function load_props_item(form, ini, load_type)
  local props_tree = form.props_tree
  local root_node = props_tree.RootNode
  if not nx_is_valid(root_node) then
    root_node = props_tree:CreateRootNode(nx_widestr("\200\206\206\241\181\192\190\223"))
  end
  root_node.max_player = 0
  root_node.ImageIndex = -1
  local sect_list = ini:GetSectionList()
  for i, sect in pairs(sect_list) do
    local item_type = ini:ReadString(nx_string(sect), "ItemType", "")
    if item_type == load_type then
      local name = ini:ReadString(nx_string(sect), "Name", "")
      create_item_node(root_node, item_type, sect, name, item_type)
    end
  end
  root_node.Expand = true
  return 1
end
function create_item_node(root_node, item_type, id, name, item_type)
  local node = root_node:FindNodeByMark(nx_int(item_type))
  if not nx_is_valid(node) then
    local item_name = get_config_prop(item_type, "Name")
    node = root_node:CreateNode(nx_widestr(item_name .. ":" .. item_type))
    node.Mark = nx_int(item_type)
  end
  local c_node = node:CreateNode(nx_widestr(name .. ":" .. id))
  return c_node
end
function props_tree_select_changed(self, node, old_node)
  local form = self.Parent
  local props_basis = form.props_basis
  form.menu_right_click.Visible = false
  local props_id = get_cur_edid(node)
  local item
  if node.Level == 2 then
    local items = get_global_ini_data(nx_string(node.ParentNode.Mark))
    item = items:GetChild(nx_string(props_id))
    refresh_panel(node, form, item, props_id, nx_custom(item, "ItemType"))
    btn_enabled(form, true)
  else
    item = nx_create("ArrayList", nx_current())
    refresh_panel(node, form, item, props_id, "nil")
    btn_enabled(form, false)
    nx_destroy(item)
  end
  return 1
end
function props_tree_right_click(self, node)
  local gui = nx_value("gui")
  local form = self.Parent
  self.SelectNode = node
  local new_node = form.props_tree.SelectNode
  local mark = "item_type"
  if new_node.Level == 2 then
    mark = "item"
  end
  local x, y = gui:GetCursorPosition()
  operation_menu(form, x - form.AbsLeft, y - form.AbsTop, mark)
  return 1
end
function operation_menu(form, x, y, mark)
  local gui = nx_value("gui")
  form.menu_right_click.Visible = true
  form.menu_right_click.Left = x + 10
  form.menu_right_click.Top = y + 10
  form.menu_right_click.Width = 80
  form.menu_right_click.ItemWidth = 60
  form.menu_right_click.NoFrame = false
  form.menu_right_click.BackColor = "255,255,255,255"
  form.menu_right_click:DeleteAllItem()
  if mark == "item" then
    form.menu_right_click:CreateItem("del_item", nx_widestr("\201\190\179\253"))
    form.menu_right_click:CreateItem("cancel_item", nx_widestr("\200\161\207\251"))
  elseif mark == "item_type" then
    form.menu_right_click:CreateItem("del_item", nx_widestr("\201\190\179\253"))
    form.menu_right_click:CreateItem("create_item", nx_widestr("\208\194\189\168\210\187\184\246\181\192\190\223"))
    form.menu_right_click:CreateItem("svn_lock", nx_widestr("\203\248\182\168SVN"))
    form.menu_right_click:CreateItem("svn_unlock", nx_widestr("\189\226\203\248SVN"))
    form.menu_right_click:CreateItem("svn_commit", nx_widestr("\204\225\189\187SVN"))
    form.menu_right_click:CreateItem("cancel_item", nx_widestr("\200\161\207\251"))
  end
  nx_bind_script(form.menu_right_click, nx_current(), "menu_operation_task_init")
end
function menu_operation_task_init(self)
  nx_callback(self, "on_del_item_click", "menu_del_item_click")
  nx_callback(self, "on_cancel_item_click", "menu_cancel_item_click")
  nx_callback(self, "on_create_item_click", "menu_create_item_click")
  nx_callback(self, "on_svn_lock_click", "menu_svn_lock_click")
  nx_callback(self, "on_svn_unlock_click", "menu_svn_unlock_click")
  nx_callback(self, "on_svn_commit_click", "menu_svn_commit_click")
end
function menu_create_item_click(self)
  local form = self.Parent
  local node = form.props_tree.SelectNode
  if node.Level == 1 then
    set_item_type(form, node.Mark, true, true)
  else
    set_item_type(form, "", true, false)
  end
  self.Visible = false
  return 1
end
function menu_del_item_click(self)
  local form = self.Parent
  local node = form.props_tree.SelectNode
  if node.Level == 2 then
    set_ini_data(nx_string(node.ParentNode.Mark), get_cur_edid(node), "Del", "true")
  else
    set_ini_data(nx_string(node.Mark), get_cur_edid(node), "Del", "true")
  end
  local node_parent = node.ParentNode
  node_parent:RemoveNode(node)
  self.Visible = false
  return 1
end
function menu_svn_lock_click(self)
  local form = self.Parent
  local node = form.props_tree.SelectNode
  local path = get_config_prop(nx_string(node.Mark), "IniPath")
  svn_lock_ini(path, false)
  self.Visible = false
  return 1
end
function menu_svn_unlock_click(self)
  local form = self.Parent
  local node = form.props_tree.SelectNode
  local path = get_config_prop(nx_string(node.Mark), "IniPath")
  svn_unlock_ini(path, false)
  self.Visible = false
  return 1
end
function menu_svn_commit_click(self)
  local form = self.Parent
  local node = form.props_tree.SelectNode
  local path = get_config_prop(nx_string(node.Mark), "IniPath")
  svn_commit_ini(path, false)
  self.Visible = false
  return 1
end
function menu_cancel_item_click(self)
  self.Visible = false
end
function refresh_panel(node, form, item, props_id, item_type)
  refresh_props_basis(node, form, item, item_type)
  refresh_text_grid(node, form, item, props_id)
  refresh_grid_data(form.public_pack, name, item, props_id)
end
function refresh_props_basis(node, form, item, item_type)
  local config = get_txt_data("Name", item_type)
  local count = table.getn(config)
  local props_basis = form.props_basis
  props_basis_insert_row(props_basis, item_type)
  for i = 1, count do
    local buffer = nx_custom(item, config[i].ID)
    if nx_string(buffer) ~= "nil" then
      props_basis:SetGridText(i - 1, 2, nx_widestr(buffer))
    else
      props_basis:SetGridText(i - 1, 2, nx_widestr(""))
    end
  end
  return 1
end
function refresh_grid_data(grid, name, item)
  grid:ClearRow()
  local config_data = get_config_ini_data("config_ini")
  local child_list = config_data:GetChildList()
  for i, node in pairs(child_list) do
    if nx_custom(node, "Type") == "Pack" then
      local pack = nx_custom(node, "ItemProp")
      if nx_find_custom(item, pack) and nx_custom(item, pack) ~= "" then
        local text = nx_custom(node, "Name")
        add_pack_to_grid(grid, text, node.Name, item, pack)
      end
    end
  end
end
function add_pack_to_grid(grid, text, name, item, pack)
  local row = grid:InsertRow(-1)
  local id = nx_custom(item, pack)
  local item_type = nx_custom(item, "ItemType")
  local config = get_txt_data("Name", name)
  local count = table.getn(config)
  local color = get_txt_prop_info("Name", nx_string(item_type), "ID", pack, "BackColor")
  set_row_info(grid, row, text, "", "", color)
  row = grid:InsertRow(-1)
  set_row_info(grid, row, "ID", text .. "ID", id, color)
  for i = 1, count do
    local key = config[i].ID
    local value = get_ini_data(name, nx_string(id), key)
    if value ~= "" then
      row = grid:InsertRow(-1)
      set_row_info(grid, row, key, config[i].Desc, value, color)
    end
  end
  grid:InsertRow(-1)
end
function set_row_info(grid, row, col_1, col_2, col_3, color)
  grid:SetGridText(row, 0, nx_widestr(col_1))
  grid:SetGridText(row, 1, nx_widestr(col_2))
  grid:SetGridText(row, 2, nx_widestr(col_3))
  grid:SetGridBackColor(row, 0, color)
  grid:SetGridBackColor(row, 1, color)
  grid:SetGridBackColor(row, 2, color)
end
function props_basis_insert_row(props_basis, item_type)
  local config = get_txt_data("Name", item_type)
  local count = table.getn(config)
  props_basis:ClearRow()
  for i = 1, count do
    props_basis:InsertRow(-1)
    props_basis:SetGridText(i - 1, 0, nx_widestr(config[i].ID))
    props_basis:SetGridText(i - 1, 1, nx_widestr(config[i].Desc))
    props_basis:SetGridBackColor(i - 1, 0, config[i].BackColor)
    props_basis:SetGridBackColor(i - 1, 1, config[i].BackColor)
    props_basis:SetGridBackColor(i - 1, 2, config[i].BackColor)
  end
  props_basis:SetColTitle(0, nx_widestr("\215\220\177\237"))
  nx_set_custom(props_basis, "res", item_type)
  nx_set_custom(props_basis, "edit_callback", "edit_enter")
  return 1
end
function set_item_type(form, text, visible, read_only)
  form.ipt_item_type.Text = nx_widestr(text)
  form.groupbox_create_box.Visible = visible
  form.ipt_item_type.ReadOnly = read_only
end
function ipt_item_type_changed(self)
  local form = self.Parent.Parent
  local ini = get_ini(ini_table.create_item_config, true)
  form.groupbox_prop_list:DeleteAll()
  form.groupbox_prop_list.Parent.Height = 125
  form.btn_ok.Enabled = false
  if ini:FindSection(nx_string(self.Text)) then
    local item_list = ini:GetItemList(nx_string(self.Text), "e")
    local top = 8
    for i, sect in pairs(item_list) do
      local def = ini:ReadString(nx_string(self.Text), sect, "")
      create_control(form, form.groupbox_prop_list, sect, top, def)
      top = 30 + top
    end
    form.btn_ok.Enabled = true
  end
  nx_destroy(ini)
end
function create_control(form, parent, text, top, def)
  local gui = nx_value("gui")
  local lbl = gui:Create("Label")
  local ipt = gui:Create("Edit")
  lbl.Text = nx_widestr(text)
  lbl.ForeColor = "255,255,0,0"
  lbl.Left = 32
  lbl.Top = top
  ipt.Text = nx_widestr(def)
  ipt.Left = 120
  ipt.Top = top
  ipt.Width = 170
  ipt.mark = nx_string(text)
  parent:Add(lbl)
  parent:Add(ipt)
  parent.Height = top + lbl.Height + 20
  parent.Parent.Height = top + lbl.Height + parent.Top + 20 + 36
end
function btn_ok_click(self)
  local form = self.Parent.Parent
  local child_control_table = form.groupbox_prop_list:GetChildControlList()
  local child_control_count = table.getn(child_control_table)
  if nx_ws_equal(form.ipt_item_type.Text, nx_widestr("")) or nx_ws_equal(form.ipt_item_id.Text, nx_widestr("")) then
    nx_msgbox("\211\208\177\216\204\238\207\238\195\187\211\208\204\238\208\180")
    return 0
  end
  for i = 1, child_control_count do
    local child = child_control_table[i]
    if "Edit" == nx_name(child) and nx_ws_equal(child.Text, nx_widestr("")) then
      nx_msgbox("\211\208\177\216\204\238\207\238\195\187\211\208\204\238\208\180")
      return 0
    end
  end
  local props_tree = form.props_tree
  local root_node = props_tree.RootNode
  local props_id = nx_string(form.ipt_item_id.Text)
  local item_type = nx_string(form.ipt_item_type.Text)
  if examine_id(item_type, nx_string(form.ipt_item_id.Text)) then
    nx_msgbox("\179\246\207\214\214\216\184\180\181\196ID")
    return 0
  end
  local node = create_item_node(root_node, item_type, props_id, "", item_type)
  local items = get_global_ini_data(item_type)
  local item = items:CreateChild(props_id)
  for i = 1, child_control_count do
    local child = child_control_table[i]
    if "Edit" == nx_name(child) and child.mark ~= "ID" then
      set_ini_data(item_type, props_id, child.mark, child.Text)
    end
  end
  set_ini_data(item_type, props_id, "ItemType", item_type)
  node.ParentNode.Expand = true
  props_tree.SelectNode = node
  self.Parent.Visible = false
  return 1
end
function btn_cancel_click(self)
  self.Parent.Visible = false
end
function ipt_find_node_changed(self)
  local filter = nx_string(self.Text)
  local form = self.Parent
  local root_node = form.props_tree.RootNode
  set_filter(root_node, filter)
end
function refresh_text_grid(node, form, item, props_id)
  local buffer = nx_custom(item, "Photo")
  form.image.BackImage = ""
  form.image.BackImage = nx_string(buffer)
  local props_image = form.props_image
  props_image:SetGridText(0, 2, nx_widestr(buffer))
  local gui = nx_value("gui")
  local name = gui.TextManager:GetFormatText(props_id)
  local prop_name_text = form.prop_name_text
  prop_name_text:SetGridText(0, 1, nx_widestr(props_id))
  local ipt_name = form.ipt_name
  ipt_name.Text = nx_widestr(name)
  form.redit_desc.Text = nx_widestr(" ")
  local combobox_desc = form.combobox_desc
  local drop_list_box = combobox_desc.DropListBox
  local input_edit = combobox_desc.InputEdit
  drop_list_box:ClearString()
  input_edit.Text = nx_widestr("")
  if not nx_find_custom(item, "ItemType") then
    return 1
  end
  local config_data = get_config_ini_data("config_ini")
  local item_type = nx_custom(item, "ItemType")
  local node = config_data:GetChild(item_type)
  local child_list = node:GetChildList()
  for i, c_node in pairs(child_list) do
    local last_desc = nx_custom(c_node, "1")
    local next_desc = nx_custom(c_node, "2")
    local desc_id = nx_string(last_desc) .. props_id .. nx_string(next_desc)
    drop_list_box:AddString(nx_widestr(desc_id))
  end
  input_edit.Text = drop_list_box:GetString(0)
  local desc = gui.TextManager:GetFormatText(nx_string(input_edit.Text))
  form.redit_desc.Text = nx_widestr(desc)
  return 1
end
function combobox_desc_selected(self)
  local form = self.Parent
  local gui = nx_value("gui")
  local input_edit = self.InputEdit
  local desc = gui.TextManager:GetFormatText(nx_string(input_edit.Text))
  form.redit_desc.Text = nx_widestr(desc)
end
function combobox_all_pack_selected(self)
  local form = self.Parent
  local name = get_cur_select_pack(form)
  refresh_public_grid(form, name)
  form.groupbox_public.Visible = true
end
function props_image_double_click_grid(grid, row)
  local form = grid.Parent
  local node = form.props_tree.SelectNode
  if not grid.Enabled or not nx_is_valid(node) then
    return 1
  end
  local res, new_name = open_pict_file(nx_resource_path(), "*.png")
  if res == "ok" then
    grid:SetGridText(0, 2, nx_widestr(new_name))
    local form = grid.Parent.Parent
    form.image.BackImage = ""
    form.image.BackImage = nx_string(new_name)
    set_ini_data(nx_string(node.ParentNode.Mark), get_cur_edid(node), "Photo", new_name)
  end
end
function grid_right_select_grid(grid, row, col)
  if not grid.Enabled or not nx_find_custom(grid, "res") then
    return 1
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  x = x + 10
  y = y + 10
  local info = get_txt_prop_info("Name", nx_custom(grid, "res"), "ID", nx_string(grid:GetGridText(row, 0)), "Tips")
  if info ~= "" then
    nx_execute("form_task\\form_tips", "show_tips", x, y, info)
  end
end
function grid_info_mousein_row_changed(grid, row)
  nx_execute("form_task\\form_tips", "close_tips")
  return 1
end
function double_click_grid(grid, row)
  if not grid.Enabled or not nx_find_custom(grid, "edit_callback") then
    return 1
  end
  local form = grid.Parent
  CurEditorRow = row
  local callback = nx_string(nx_custom(grid, "edit_callback"))
  create_edit(grid, CurEditorRow, grid.ColCount - 1, callback, true)
  CurEditorGrid = grid
  return 1
end
function double_click_public_grid(grid, row)
  edit_pack(grid, row)
end
function textgrid_public_select_row(grid, row)
  if nx_is_valid(CurEditorGrid) then
    local id = grid:GetGridText(CurEditorRow, 0)
    local name = nx_custom(grid, "res")
    create_section(nx_string(name), nx_string(id))
    cur_clear_edit(CurEditorGrid, CurEditorRow, true, id, false)
  end
end
function cur_clear_edit(grid, row, is_set, id, is_row)
  if not nx_is_valid(grid) or row == -1 then
    return -1
  end
  for i = 0, grid.ColCount do
    local control = grid:GetGridControl(row, i)
    local old_value = grid:GetGridText(row, i)
    if nx_is_valid(control) then
      if is_set == true and not nx_ws_equal(old_value, control.Text) then
        grid:SetGridText(row, i, control.Text)
        if is_row == true then
          set_ini_data(nx_string(nx_custom(grid, "res")), id, grid:GetGridText(row, 0), nx_string(control.Text))
        else
          set_ini_data(nx_string(nx_custom(grid, "res")), id, grid:GetColTitle(i), nx_string(control.Text))
        end
        nx_set_custom(grid, "changed", "true")
      end
      grid:ClearGridControl(row, i)
    end
  end
  return 1
end
function create_edit(grid, row, edit_col, callback, is_lost_focus)
  local gui = nx_value("gui")
  local edit_ctrl = CREATE_CONTROL("Edit")
  edit_ctrl.BackColor = "255,65,75,86"
  nx_bind_script(edit_ctrl, nx_current())
  nx_callback(edit_ctrl, "on_enter", callback)
  edit_ctrl.Text = grid:GetGridText(row, edit_col)
  grid:SetGridControl(row, edit_col, edit_ctrl)
  if is_lost_focus ~= nil and is_lost_focus == true then
    gui.Focused = edit_ctrl
    nx_callback(edit_ctrl, "on_lost_focus", callback)
  end
  return 1
end
function edit_enter(self)
  local grid = self.Parent
  local form = grid.Parent.Parent
  local node = form.props_tree.SelectNode
  cur_clear_edit(CurEditorGrid, CurEditorRow, true, get_cur_edid(node), true)
  local props_id = get_cur_edid(node)
  local items = get_global_ini_data(nx_string(node.ParentNode.Mark))
  local item = items:GetChild(props_id)
  if not nx_is_valid(item) then
    item = nx_create("ArrayList", nx_current())
    refresh_panel(node, form, item, props_id, "nil")
    nx_destroy(item)
  else
    refresh_panel(node, form, item, props_id, nx_custom(item, "ItemType"))
  end
  CurEditorGrid = nil
  return 1
end
function ipt_name_enter(self)
  local form = self.Parent
  local node = form.props_tree.SelectNode
  local gui = nx_value("gui")
  local props_id = get_cur_edid(node)
  local name = gui.TextManager:GetFormatText(props_id)
  if name == nx_string(self.Text) then
    return 1
  end
  set_ini_data(nx_string(node.ParentNode.Mark), props_id, "IdresName", self.Text)
end
function redit_desc_lost_focus(self)
  if not nx_find_custom(self, "changed") or nx_custom(self, "changed") ~= "true" then
    return 1
  end
  nx_set_custom(self, "changed", true)
  local form = self.Parent.Parent
  local node = form.props_tree.SelectNode
  local props_id = get_cur_edid(node)
  local combobox_desc = form.combobox_desc
  local drop_list_box = combobox_desc.DropListBox
  local input_edit = combobox_desc.InputEdit
  local index = drop_list_box:FindString(input_edit.Text)
  if index == -1 then
    return 1
  end
  set_ini_data(nx_string(node.ParentNode.Mark), props_id, nx_string("Desc_" .. nx_string(index)), self.Text)
  return 1
end
function redit_desc_changed(self)
  nx_set_custom(self, "changed", "true")
end
function select_row(grid, row)
  local form = grid.Parent
  refresh_select_grid_row(form, grid)
  return 1
end
function refresh_select_grid_row(form, grid)
  local props_basis = form.props_basis
  local props_image = form.props_image
  local prop_name_text = form.prop_name_text
  local prop_desc_text = form.prop_desc_text
  local public_pack = form.public_pack
  if not nx_id_equal(props_basis, grid) then
    props_basis:ClearSelect()
  end
  if not nx_id_equal(props_image, grid) then
    props_image:ClearSelect()
  end
  if not nx_id_equal(prop_name_text, grid) then
    prop_name_text:ClearSelect()
  end
  if not nx_id_equal(prop_desc_text, grid) then
    prop_desc_text:ClearSelect()
  end
  if not nx_id_equal(public_pack, grid) then
    public_pack:ClearSelect()
  end
  return 1
end
function edit_enter_public_grid(self)
  local grid = self.Parent
  local id = grid:GetGridText(CurEditorRow, 0)
  local name = nx_custom(grid, "res")
  create_section(nx_string(name), nx_string(id))
  cur_clear_edit(CurEditorGrid, CurEditorRow, true, id, false)
  CurEditorGrid = nil
  CurEditorRow = -1
  return 1
end
function edit_pack(grid, row)
  local ColCount = grid.ColCount - 1
  for i = 1, ColCount do
    create_edit(grid, row, i, "edit_enter_public_grid", false)
  end
  CurEditorGrid = grid
  CurEditorRow = row
end
function svn_lock_ini(value, in_table)
  local path = ""
  if in_table then
    path = nx_resource_path() .. value
  else
    path = get_work_path() .. value
  end
  svn_lock(path)
end
function svn_commit_ini(value, in_table)
  local path = ""
  if in_table then
    path = nx_resource_path() .. value
  else
    path = get_work_path() .. value
  end
  svn_commit(path)
end
function svn_unlock_ini(value, in_table)
  local path = ""
  if in_table then
    path = nx_resource_path() .. value
  else
    path = get_work_path() .. value
  end
  svn_unlock(path)
end
function btn_save_click(self)
  local form = self.Parent
  local root_node = form.props_tree.RootNode
  local node_list = root_node:GetNodeList()
  for i, t_node in pairs(node_list) do
    save_to_file(nx_string(t_node.Mark))
    local node = get_global_ini_data(nx_string(t_node.Mark))
    nx_set_custom(node, "Edit", false)
  end
end
function btn_public_save_click(self)
  local form = self.Parent.Parent
  local name = nx_custom(form.textgrid_public, "res")
  save_to_file(name)
  return 1
end
local TYPE_NO = 0
local TYPE_INI = 1
local TYPE_IDRES_NAME = 2
local TYPE_IDRES_DESC = 3
function save_to_file(name)
  local node_list = get_ini_sect_list(name)
  local is_save = false
  local path = get_config_prop(name, "IniPath")
  local ini = get_ini(path, false)
  if not nx_is_valid(ini) then
    return 0
  end
  for i, node in pairs(node_list) do
    if nx_find_custom(node, "Edit") and nx_string(nx_custom(node, "Edit")) == "true" then
      nx_set_custom(node, "Edit", "false")
      if nx_find_custom(node, "Del") and nx_string(nx_custom(node, "Del") == true) then
        is_save = true
        ini:DeleteSection(node.Name)
      else
        local prop_list = nx_custom_list(node)
        for i, prop in pairs(prop_list) do
          local res = is_save_prop(prop)
          if res == TYPE_INI then
            ini:WriteString(node.Name, prop, nx_string(nx_custom(node, prop)))
            is_save = true
          elseif res == TYPE_IDRES_NAME then
            local path = get_config_prop(name, "IdresName")
            if not save_into_file(path, node.Name, nx_string(nx_custom(node, prop))) then
              add_into_file(path, node.Name, nx_string(nx_custom(node, prop)))
            end
          elseif res == TYPE_IDRES_DESC then
            local desc_info = get_config_desc_info(name, node.Name, prop)
            if not save_into_file(desc_info[3], desc_info[4], nx_string(nx_custom(node, prop))) then
              add_into_file(desc_info[3], desc_info[4], nx_string(nx_custom(node, prop)))
            end
          end
        end
      end
    end
  end
  ini:SaveToFile()
  nx_destroy(ini)
end
function is_save_prop(prop)
  if prop == "Del" or prop == "" or prop == "Edit" then
    return TYPE_NO
  elseif prop == "IdresName" then
    return TYPE_IDRES_NAME
  elseif need_add_node(prop, "Desc_") then
    return TYPE_IDRES_DESC
  end
  return TYPE_INI
end
function find_public_pack_index(form, grid, id)
  local count = grid.RowCount - 1
  local value = nx_widestr("")
  for i = 1, count do
    value = grid:GetGridText(i, 0)
    if nx_ws_equal(id, value) then
      return i
    end
  end
  return -1
end
function get_cur_edid(node)
  if not nx_is_valid(node) then
    return ""
  end
  local tuple = util_split_string(nx_string(node.Text), ":")
  local props_id = tuple[2]
  return props_id
end
function get_cur_select_pack(form)
  local drop_list_box = form.combobox_all_pack.DropListBox
  local select_index = drop_list_box.SelectIndex
  local name = nx_custom(drop_list_box, nx_string(select_index))
  return nx_string(name)
end
function examine_id(name, id)
  local node = get_global_ini_data(name)
  if node:FindChild(id) then
    return true
  end
  return false
end
function refresh_public_grid(form, name)
  local grid = form.textgrid_public
  recovery_public_grid(form, form.textgrid_public)
  set_prop_public_grid(form, form.textgrid_public, name)
  set_data_public_grid(form, form.textgrid_public, name)
end
function recovery_public_grid(form, grid)
  grid.ColCount = 0
  grid.RowCount = 0
end
local MAX_COL = 800
local MIN_COL = 550
local MAX_ROW = 500
local MIN_ROW = 301
local SCROLLBAR = 20
local MAX_BTN = 6
function set_prop_public_grid(form, grid, name)
  local col = table.getn(get_ini_item_list(name, "-1"))
  local row = table.getn(get_ini_sect_list(name))
  grid.ColCount = col + 1
  grid.RowCount = row
  grid.ColWidth = 100
  if grid.ColCount * grid.ColWidth > MAX_COL then
    grid.Width = MAX_COL
    grid.Parent.Width = MAX_COL + 48
  elseif grid.ColCount * grid.ColWidth < MIN_COL then
    grid.ColWidth = nx_int(MIN_COL / grid.ColCount) - 1
    grid.Width = grid.ColCount * grid.ColWidth + SCROLLBAR
    grid.Parent.Width = MIN_COL + 48
  else
    grid.Width = grid.ColCount * grid.ColWidth + SCROLLBAR
    grid.Parent.Width = grid.ColCount * grid.ColWidth + SCROLLBAR + 48
  end
  if grid.RowHeight * row > MAX_ROW then
    grid.Height = MAX_ROW
    grid.Parent.Height = MAX_ROW + 70
  else
    grid.Height = grid.RowHeight * grid.RowCount + grid.RowHeight + SCROLLBAR
    grid.Parent.Height = grid.RowHeight * grid.RowCount + grid.RowHeight + SCROLLBAR + 70
  end
  local item_list = get_ini_item_list(name, "-1")
  grid:SetColTitle(0, nx_widestr("ID"))
  for i, key in pairs(item_list) do
    grid:SetColTitle(i, nx_widestr(key))
  end
  form.btn_create.Left = 14
  form.btn_transfer.Left = grid.Parent.Width / MAX_BTN + 14
  form.btn_svn_lock.Left = grid.Parent.Width / MAX_BTN * 2 + 14
  form.btn_svn_unlock.Left = grid.Parent.Width / MAX_BTN * 3 + 14
  form.btn_svn_commit.Left = grid.Parent.Width / MAX_BTN * 4 + 14
  form.btn_public_save.Left = grid.Parent.Width / MAX_BTN * 5 + 14
  return 1
end
function set_data_public_grid(form, grid, name)
  local sections = get_ini_sect_list(name)
  local buffer = ""
  for i, sect in pairs(sections) do
    grid:SetGridText(i - 1, 0, nx_widestr(nx_string(sect.Name)))
    for j = 1, grid.ColCount do
      buffer = get_ini_data(name, nx_string(sect.Name), nx_string(grid:GetColTitle(j)))
      grid:SetGridText(i - 1, j, nx_widestr(buffer))
    end
  end
  nx_set_custom(form.textgrid_public, "res", name)
end
function btn_create_click(self)
  local form = self.Parent.Parent
  local grid = form.textgrid_public
  local left = grid.AbsLeft
  local top = grid.AbsTop + grid.Height - 30
  local res, name = show_input_box(left, top, "\202\228\200\235\208\194\189\168\176\252\181\196ID")
  if res ~= "ok" then
    return 0
  end
  local IsAdd = find_public_pack_index(form, grid, nx_widestr(name))
  if IsAdd ~= -1 then
    nx_msgbox(" (*^__^*) \206\251\206\251\161\173\161\173 ID \214\216\184\180\193\203 \187\185\202\199\184\196\193\203\176\201")
    grid:SelectRow(IsAdd)
    return -1
  end
  grid:InsertRow(-1)
  edit_pack(form.textgrid_public, grid.RowCount - 1)
  grid:SetGridText(grid.RowCount - 1, 0, nx_widestr(name))
end
function btn_close_click(self)
  self.Parent.Visible = false
  return 1
end
function btn_transfer_click(self)
  local form = self.Parent.Parent
  if not nx_find_custom(form.textgrid_public, "res") then
    return 0
  end
  local node = form.props_tree.SelectNode
  local select_row = form.textgrid_public.RowSelectIndex
  local id = form.textgrid_public:GetGridText(select_row, 0)
  local props_id = get_cur_edid(node)
  local res = nx_custom(form.textgrid_public, "res")
  if res == "itme_task_ini" then
    set_ini_data(nx_string(node.ParentNode.Mark), props_id, "TaskPack", nx_string(id))
  elseif res == "itme_logic_ini" then
    set_ini_data(nx_string(node.ParentNode.Mark), props_id, "LogicPack", nx_string(id))
  elseif res == "itme_func_ini" then
    set_ini_data(nx_string(node.ParentNode.Mark), props_id, "FuncPack", nx_string(id))
  end
  local items = get_global_ini_data(nx_string(node.ParentNode.Mark))
  local item = items:GetChild(props_id)
  refresh_panel(form.props_tree.SelectNode, form, item, item.Name, nx_custom(item, "ItemType"))
end
function btn_svn_lock_click(self)
  local form = self.Parent.Parent
  if nx_find_custom(form.textgrid_public, "res") then
    local value = nx_custom(form.textgrid_public, "res")
    local path = get_config_prop(value, "IniPath")
    svn_lock_ini(path, false)
  end
end
function btn_svn_unlock_click(self)
  local form = self.Parent.Parent
  if nx_find_custom(form.textgrid_public, "res") then
    local value = nx_custom(form.textgrid_public, "res")
    local path = get_config_prop(value, "IniPath")
    svn_unlock_ini(path, false)
  end
end
function btn_svn_commit_click(self)
  local form = self.Parent.Parent
  if nx_find_custom(form.textgrid_public, "res") then
    local value = nx_custom(form.textgrid_public, "res")
    local path = get_config_prop(value, "IniPath")
    svn_commit_ini(path, false)
  end
end
function show_input_box(left, top, title)
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_input.xml")
  dialog.lbl_2.Text = nx_widestr(title)
  dialog.input_edit.OnlyDigit = false
  dialog.allow_empty = false
  dialog:ShowModal()
  local res, name = nx_wait_event(100000000, dialog, "form_input_return")
  return res, name
end
function save_into_file(file_name, key, value)
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = nx_resource_path() .. file_name
  if not textgrid:LoadFromFile(2) then
    nx_destroy(textgrid)
    nx_msgbox("\182\193\200\161\206\196\188\254(" .. nx_resource_path() .. file_name .. ")\202\167\176\220")
    return true
  end
  for i = 0, textgrid.RowCount - 1 do
    local key_value = textgrid:GetValueString(nx_int(i), nx_int(0))
    local begin_index, end_index = string.find(key_value, "=")
    if nil ~= begin_index and 1 ~= begin_index then
      local key_ins = string.sub(key_value, 1, begin_index - 1)
      if string.lower(key) == string.lower(key_ins) then
        textgrid:SetValueString(nx_int(i), nx_int(0), key_ins .. "=" .. value)
        textgrid:SaveToFile()
        nx_destroy(textgrid)
        return true
      end
    end
  end
  nx_destroy(textgrid)
  return false
end
function add_into_file(file_name, key, value)
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = nx_resource_path() .. file_name
  if not textgrid:LoadFromFile(2) then
    nx_destroy(textgrid)
    nx_msgbox("\182\193\200\161\206\196\188\254(" .. nx_resource_path() .. file_name .. ")\202\167\176\220")
    return true
  end
  local row = textgrid:AddRow(key .. "=" .. value)
  textgrid:SaveToFile()
  nx_destroy(textgrid)
  return false
end
