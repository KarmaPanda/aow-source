NODE_WUXUE_PROP = {
  [1] = {
    ForeColor = "255,220,198,160",
    NodeBackImage = "gui\\common\\treeview\\tree_1_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png",
    Font = "font_text_title1",
    ItemHeight = 33,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 3,
    ExpandCloseOffsetY = 5,
    TextOffsetX = 25,
    TextOffsetY = 6
  },
  [2] = {
    ForeColor = "255,181,154,128",
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    Font = "font_text_title1",
    ItemHeight = 30,
    NodeOffsetY = 0,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 5,
    TextOffsetX = 30,
    TextOffsetY = 6
  }
}
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local INI_FILE_FACULTY = "share\\Faculty\\WuXueLevelInfo.ini"
function main_form_init(form)
  form.Fixed = false
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.rbtn_type_tl.Checked = true
  form.rbtn_type_ng.Checked = false
  form.gbox_tl.Visibe = true
  form.gbox_ng.Visibe = false
  form.max_faculty = nx_number(get_player_prop("Faculty"))
  form.cur_faculty = form.max_faculty
  form.lbl_faculty_value.Text = nx_widestr(form.cur_faculty)
  form.lbl_max_faculty.Text = nx_widestr(form.max_faculty)
  form.lbl_need_faculty.Text = nx_widestr(form.max_faculty - form.cur_faculty)
  load_all_tl(form)
  load_all_ng(form)
  nx_execute("custom_sender", "custom_ws_check_test_server_open")
  return 1
end
function main_form_close(form)
  local wuxue_list = nx_call("util_gui", "get_arraylist", "wuxue_list")
  if nx_is_valid(wuxue_list) then
    nx_destroy(wuxue_list)
  end
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_info_checked_changed(self)
  local form = self.ParentForm
end
function load_all_tl(form)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local root = form.tree_tl:CreateRootNode(nx_widestr(""))
  local learned_tl_count = 0
  form.tree_tl:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_SKILL)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local type_node
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_SKILL, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      if check_taolu_is_learn(sub_type_name) then
        if not nx_is_valid(type_node) then
          type_node = root:CreateNode(gui.TextManager:GetText(type_name))
          set_wuxue_node_prop(type_node, 1)
        end
        local sub_type_node = type_node:CreateNode(gui.TextManager:GetText(sub_type_name))
        if nx_is_valid(sub_type_node) then
          sub_type_node.type_name = sub_type_name
          sub_type_node.selected = false
          set_wuxue_node_prop(sub_type_node, 2)
        end
        learned_tl_count = learned_tl_count + 1
      end
    end
  end
  form.lbl_tlcount.Text = nx_widestr(learned_tl_count)
  root.Expand = true
  form.tree_tl:EndUpdate()
end
function load_all_ng(form)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local root = form.tree_ng:CreateRootNode(nx_widestr(""))
  local learned_ng_count = 0
  form.tree_ng:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_NEIGONG)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local type_node
    local sub_type_tab = wuxue_query:GetItemNames(WUXUE_NEIGONG, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local sub_type = wuxue_query:GetLearnID_NeiGong(sub_type_name)
      if nx_is_valid(sub_type) then
        if not nx_is_valid(type_node) then
          type_node = root:CreateNode(gui.TextManager:GetText(type_name))
          set_wuxue_node_prop(type_node, 1)
        end
        local sub_type_node = type_node:CreateNode(gui.TextManager:GetText(sub_type_name))
        if nx_is_valid(sub_type_node) then
          sub_type_node.type_name = sub_type_name
          sub_type_node.selected = false
          set_wuxue_node_prop(sub_type_node, 2)
        end
        learned_ng_count = learned_ng_count + 1
      end
    end
  end
  form.lbl_ngcount.Text = nx_widestr(learned_ng_count)
  root.Expand = true
  form.tree_ng:EndUpdate()
end
function on_grid_photo_mousein_grid(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if not nx_is_valid(item_data) then
    return 0
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = false
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft() + 10, grid:GetMouseInItemTop() + 10, 32, 32, grid.ParentForm)
end
function on_grid_photo_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_rbtn_type_checked_changed(self)
  local form = self.ParentForm
  form.gbox_tl.Visible = form.rbtn_type_tl.Checked
  form.gbox_ng.Visible = form.rbtn_type_ng.Checked
end
function on_tree_tl_left_click(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_find_custom(cur_node, "type_name") then
    return 0
  end
  if not nx_find_custom(cur_node, "selected") then
    return 0
  end
  if not cur_node.selected then
    add_one_tl(form, cur_node.type_name)
    cur_node.selected = true
  end
end
function on_tree_ng_left_click(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_find_custom(cur_node, "type_name") then
    return 0
  end
  if not nx_find_custom(cur_node, "selected") then
    return 0
  end
  if not cur_node.selected then
    add_one_ng(form, cur_node.type_name)
    cur_node.selected = true
  end
end
function on_grid_photo_select_changed(self, index)
  local form = self.ParentForm
  local wuxue_list = nx_call("util_gui", "get_arraylist", "wuxue_list")
  if not nx_is_valid(wuxue_list) then
    return false
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local item_data = GoodsGrid:GetItemData(self, index)
  if not nx_is_valid(item_data) then
    return 0
  end
  local wuxue_id = item_data.ConfigID
  local wuxue_child = wuxue_list:GetChild(wuxue_id)
  if not nx_is_valid(wuxue_child) then
    return 0
  end
  if wuxue_child.cur_level < wuxue_child.max_level then
    local level_child = wuxue_child:GetChild(nx_string(wuxue_child.cur_level))
    if not nx_is_valid(level_child) then
      return 0
    end
    if form.cur_faculty >= level_child.faculty then
      wuxue_child.cur_level = nx_number(wuxue_child.cur_level) + 1
      self:SetItemNumber(index, nx_int(wuxue_child.cur_level))
      form.cur_faculty = form.cur_faculty - nx_number(level_child.faculty)
      form.lbl_faculty_value.Text = nx_widestr(form.cur_faculty)
      form.lbl_need_faculty.Text = nx_widestr(form.max_faculty - form.cur_faculty)
      item_data.Level = nx_int(wuxue_child.cur_level)
      level_child = wuxue_child:GetChild(nx_string(wuxue_child.cur_level))
      if nx_is_valid(level_child) then
        item_data.TotalFillValue = nx_int(level_child.faculty)
      else
        item_data.TotalFillValue = nx_int(0)
      end
      nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft() + 10, self:GetMouseInItemTop() + 10, 32, 32, self.ParentForm)
    end
  end
end
function on_grid_photo_rightclick_grid(self, index)
  local form = self.ParentForm
  local wuxue_list = nx_call("util_gui", "get_arraylist", "wuxue_list")
  if not nx_is_valid(wuxue_list) then
    return false
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local item_data = GoodsGrid:GetItemData(self, index)
  if not nx_is_valid(item_data) then
    return 0
  end
  local wuxue_id = item_data.ConfigID
  local wuxue_child = wuxue_list:GetChild(wuxue_id)
  if not nx_is_valid(wuxue_child) then
    return 0
  end
  if wuxue_child.cur_level > wuxue_child.min_level then
    local level_child = wuxue_child:GetChild(nx_string(wuxue_child.cur_level - 1))
    if not nx_is_valid(level_child) then
      return 0
    end
    wuxue_child.cur_level = nx_number(wuxue_child.cur_level) - 1
    self:SetItemNumber(index, nx_int(wuxue_child.cur_level))
    form.cur_faculty = form.cur_faculty + nx_number(level_child.faculty)
    form.lbl_faculty_value.Text = nx_widestr(form.cur_faculty)
    form.lbl_need_faculty.Text = nx_widestr(form.max_faculty - form.cur_faculty)
    item_data.Level = nx_int(wuxue_child.cur_level)
    level_child = wuxue_child:GetChild(nx_string(wuxue_child.cur_level))
    if nx_is_valid(level_child) then
      item_data.TotalFillValue = nx_int(level_child.faculty)
    else
      item_data.TotalFillValue = nx_int(0)
    end
    nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft() + 10, self:GetMouseInItemTop() + 10, 32, 32, self.ParentForm)
  end
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.lbl_faculty_value.Text) < nx_int(0) then
    return
  end
  local wuxue_list = nx_call("util_gui", "get_arraylist", "wuxue_list")
  if not nx_is_valid(wuxue_list) then
    return 0
  end
  local arg_list = {}
  local wuxue_tab = wuxue_list:GetChildList()
  for i = 1, table.getn(wuxue_tab) do
    local wuxue_child = wuxue_tab[i]
    local min_level = nx_int(wuxue_child.min_level)
    local cur_level = nx_int(wuxue_child.cur_level)
    if min_level ~= cur_level then
      table.insert(arg_list, wuxue_child.Name)
      table.insert(arg_list, cur_level)
    end
  end
  local need_faculty = form.max_faculty - form.cur_faculty
  if nx_int(need_faculty) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_set_wuxue_leave", nx_int(need_faculty), unpack(arg_list))
end
function on_btn_reset_click(self)
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local text = nx_widestr(util_text("ui_reset_wuxue_faculty"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_reset_wuxue_faculty")
  end
end
function add_one_tl(form, tl_name)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local gbox_item = create_ctrl("GroupBox", form.gbox_item_src)
  local lbl_name = create_ctrl("Label", form.lbl_name_src)
  local grid_wuxue = create_ctrl("ImageGrid", form.grid_wuxue_src)
  if not (nx_is_valid(gbox_item) and nx_is_valid(lbl_name)) or not nx_is_valid(grid_wuxue) then
    return 0
  end
  nx_bind_script(grid_wuxue, nx_current())
  nx_callback(grid_wuxue, "on_select_changed", "on_grid_photo_select_changed")
  nx_callback(grid_wuxue, "on_rightclick_grid", "on_grid_photo_rightclick_grid")
  nx_callback(grid_wuxue, "on_mousein_grid", "on_grid_photo_mousein_grid")
  nx_callback(grid_wuxue, "on_mouseout_grid", "on_grid_photo_mouseout_grid")
  lbl_name.Text = nx_widestr(gui.TextManager:GetText(tl_name))
  gbox_item:Add(lbl_name)
  gbox_item:Add(grid_wuxue)
  form.gpsb_items:Add(gbox_item)
  form.gpsb_items:ResetChildrenYPos()
  local add_index = 0
  local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, tl_name)
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local item = wuxue_query:GetLearnID_Skill(item_name)
    if nx_is_valid(item) then
      add_one_wuxue(WUXUE_SKILL, item)
      add_grid_data(grid_wuxue, add_index, item, VIEWPORT_SKILL)
      add_index = add_index + 1
    end
  end
end
function add_one_ng(form, ng_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local item = wuxue_query:GetLearnID_NeiGong(ng_name)
  if nx_is_valid(item) then
    add_one_wuxue(WUXUE_NEIGONG, item)
    show_select_ng(form)
  end
end
function add_grid_data(grid, index, item, view_id)
  if not nx_is_valid(grid) then
    return 0
  end
  if not nx_is_valid(item) then
    return 0
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  grid:SetBindIndex(index, nx_int(item.Ident))
  grid.typeid = view_id
  grid.canselect = false
  local prop_table = {}
  local proplist = item:GetPropList()
  for i, prop in pairs(proplist) do
    prop_table[prop] = item:QueryProp(prop)
  end
  prop_table.Amount = item:QueryProp("Level")
  local item_data = nx_create("ArrayList", nx_current())
  for prop, value in pairs(prop_table) do
    nx_set_custom(item_data, prop, value)
  end
  GoodsGrid:GridAddItem(grid, index, item_data)
end
function create_ctrl(ctrl_name, refer_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  return ctrl
end
function show_select_ng(form)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  local wuxue_list = nx_call("util_gui", "get_arraylist", "wuxue_list")
  if not nx_is_valid(wuxue_list) then
    return false
  end
  GoodsGrid:GridClear(form.grid_wuxue)
  local add_count = 0
  local wuxue_tab = wuxue_list:GetChildList()
  for i = 1, table.getn(wuxue_tab) do
    local wuxue_child = wuxue_tab[i]
    if wuxue_child.wuxue_type == WUXUE_NEIGONG then
      local item = wuxue_query:GetLearnID_NeiGong(wuxue_child.Name)
      if nx_is_valid(item) then
        add_grid_data(form.grid_wuxue, add_count, item, VIEWPORT_NEIGONG)
        local item_data = GoodsGrid:GetItemData(form.grid_wuxue, add_count)
        if nx_is_valid(item_data) then
          item_data.Level = wuxue_child.cur_level
          form.grid_wuxue:SetItemNumber(add_count, wuxue_child.cur_level)
        end
        add_count = add_count + 1
      end
    end
  end
  return true
end
function add_one_wuxue(wuxue_type, wuxue_item)
  if not nx_is_valid(wuxue_item) then
    return false
  end
  local wuxue_list = nx_call("util_gui", "get_arraylist", "wuxue_list")
  if not nx_is_valid(wuxue_list) then
    return false
  end
  local wuxue_name = wuxue_item:QueryProp("ConfigID")
  local wuxue_level = wuxue_item:QueryProp("Level")
  local max_level = wuxue_item:QueryProp("MaxLevel")
  if wuxue_list:FindChild(nx_string(wuxue_name)) then
    return false
  end
  local ini = nx_call("util_functions", "get_ini", INI_FILE_FACULTY)
  if not nx_is_valid(ini) then
    return false
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_name))
  if index < 0 then
    return false
  end
  local wuxue_child = wuxue_list:CreateChild(nx_string(wuxue_name))
  if not nx_is_valid(wuxue_child) then
    return false
  end
  local level_tab = ini:GetItemValueList(index, "r")
  wuxue_child.wuxue_type = wuxue_type
  wuxue_child.min_level = nx_number(wuxue_level)
  wuxue_child.cur_level = wuxue_child.min_level
  wuxue_child.max_level = nx_number(max_level)
  for i = 1, table.getn(level_tab) do
    local data_tab = util_split_string(nx_string(level_tab[i]), ",")
    if table.getn(data_tab) < 3 then
      wuxue_list:RemoveChildByID(wuxue_child)
      return false
    end
    if wuxue_child:FindChild(nx_string(data_tab[1])) then
      wuxue_list:RemoveChildByID(wuxue_child)
      return false
    end
    local level_child = wuxue_child:CreateChild(nx_string(data_tab[1]))
    if nx_is_valid(level_child) then
      level_child.faculty = nx_number(data_tab[2])
    end
  end
  return true
end
function set_wuxue_node_prop(node, index)
  if not nx_is_valid(node) then
    return 0
  end
  if 0 > nx_number(index) or nx_number(index) > table.getn(NODE_WUXUE_PROP) then
    return 0
  end
  for prop_name, value in pairs(NODE_WUXUE_PROP[nx_number(index)]) do
    nx_set_property(node, nx_string(prop_name), value)
  end
end
function on_rec_test_server(...)
  local form = nx_value("form_stage_main\\form_wuxue\\form_wuxue_simulator")
  if not nx_is_valid(form) or table.getn(arg) < 1 then
    return
  end
  form.btn_reset.Visible = arg[1] == 0
end
