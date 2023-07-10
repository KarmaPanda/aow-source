require("util_gui")
require("util_functions")
require("share\\view_define")
require("util_static_data")
FORM_NIGHT_FOREVER = "form_stage_main\\form_night_forever\\form_night_forever"
FORM_ACHIEVEMENT = "form_stage_main\\form_night_forever\\form_achievement"
local STALL_INFO_NUM = 6
local HIRE_SHOP_INFO_NUM = 5
local MARKET_NODE_ITEM = 1
local achievement_type_table = {}
NODE_PROP = {
  first = {
    ForeColor = "255,255,255,197",
    NodeBackImage = "gui\\commom_new\\special\\night\\00_btn1_out.png",
    NodeFocusImage = "gui\\commom_new\\special\\night\\00_btn1_on.png",
    NodeSelectImage = "gui\\commom_new\\special\\night\\00_btn1_down.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 5,
    TextOffsetY = 6,
    Font = "font_main"
  },
  second = {
    ForeColor = "255,255,255,197",
    NodeBackImage = "gui\\commom_new\\special\\night\\00_btn2_out.png",
    NodeFocusImage = "gui\\commom_new\\special\\night\\00_btn2_on.png",
    NodeSelectImage = "gui\\commom_new\\special\\night\\00_btn2_down.png",
    ItemHeight = 28,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 5,
    TextOffsetY = 5,
    Font = "font_main"
  },
  third = {
    ForeColor = "255,255,255,197",
    NodeBackImage = "gui\\commom_new\\btn\\main_btn2_out.png",
    NodeFocusImage = "gui\\commom_new\\btn\\main_btn2_on.png",
    NodeSelectImage = "gui\\commom_new\\btn\\main_btn2_down.png",
    ItemHeight = 28,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 10,
    TextOffsetY = 5,
    Font = "font_main"
  }
}
local sifter_tree_node_tab = {}
local ST_FUNCTION_MARKET_SIFTER = 637
local MAX_SELECT_SIFTER_NUMBER = 8
function open_form()
  util_auto_show_hide_form("form_stage_main\\form_night_forever\\form_achievement")
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  create_achievement_tree(self)
  self.combobox_itemname.Visible = true
  self.btn_search_key.Enabled = false
  self.groupbox_search.Visible = true
  self.ipt_search_key.Text = nx_widestr(util_text("ui_trade_search_key"))
  local AchievementManager = nx_value("AchievementManager")
  if not nx_is_valid(AchievementManager) then
    return
  end
  AchievementManager:LoadRes()
  show_achievement_info_list(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("AchievementPoints", "int", self, nx_current(), "refresh_achievement_points")
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("AchievementPoints", self)
  end
  nx_destroy(self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function refresh_achievement_points(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local achievement_points = client_player:QueryProp("AchievementPoints")
  self.lbl_value.Text = nx_widestr(achievement_points)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_tree_market_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(cur_node, "item_type") then
    form.item_type = nx_int(cur_node.item_type)
  else
    form.item_type = 0
  end
  fresh_tree(self, cur_node, pre_node)
  fresh_groupbox_achievement_type(form)
end
function fresh_tree(self, cur_node, pre_node)
  if not nx_is_valid(pre_node) then
    return
  end
  local cur_node_type = nx_custom(cur_node, "type")
  local pre_node_type = nx_custom(pre_node, "type")
  if cur_node_type == 1 then
    local parent_first_node = find_first_parent_node(pre_node)
    if not nx_id_equal(cur_node, parent_first_node) then
      unexpand_node(parent_first_node)
    end
  elseif cur_node_type == 2 then
    if 2 == nx_custom(pre_node, "type") then
      unexpand_node(pre_node)
    elseif 3 == nx_custom(pre_node, "type") then
      local parent_node = pre_node.ParentNode
      if nx_is_valid(parent_node) then
        unexpand_node(parent_node)
      end
    end
  end
end
function find_first_parent_node(node)
  if 1 == nx_custom(node, "type") then
    return node
  end
  local parent_node = node.ParentNode
  if nx_is_valid(parent_node) then
    if 1 == nx_custom(parent_node, "type") then
      return parent_node
    else
      return find_first_parent_node(parent_node)
    end
  else
    return node
  end
end
function unexpand_node(node)
  local node_type = nx_custom(node, "type")
  if node_type == 1 or node_type == 2 then
    local kids = node:GetNodeList()
    for _, child_node in ipairs(kids) do
      if nx_is_valid(child_node) then
        local child_node_type = nx_custom(child_node, "type")
        if child_node_type == 2 then
          unexpand_node(child_node)
        end
      end
    end
  end
  node.Expand = false
end
function fresh_groupbox_achievement_type(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_find_custom(form, "item_type") then
    local cbtn_name = "cbtn_achievement_" .. nx_string(form.item_type)
    if nx_find_custom(form, cbtn_name) then
      local cbtn = nx_custom(form, cbtn_name)
      if nx_is_valid(cbtn) then
        cbtn.Checked = true
        local gb = cbtn.Parent
        if nx_is_valid(gb) then
          local vertical_total = get_ctrl_total_height(form.gsb_1)
          local fous_pos = get_focus_ctrl_pos(form.gsb_1, gb.Name)
          local bar_value = nx_int(fous_pos) / (vertical_total - form.gsb_1.Height) * form.gsb_1.VScrollBar.Maximum
          if bar_value > form.gsb_1.VScrollBar.Maximum then
            bar_value = form.gsb_1.VScrollBar.Maximum
          end
          form.gsb_1.VScrollBar.Value = bar_value
        end
      end
    end
  end
end
function get_ctrl_total_height(ctrl)
  if not nx_is_valid(ctrl) then
    return 0
  end
  local total_height = 0
  for i = 0, ctrl:GetChildControlCount() do
    local child_ctrl = ctrl:GetChildControlByIndex(i)
    if nx_is_valid(child_ctrl) then
      total_height = total_height + child_ctrl.Height
    end
  end
  return total_height
end
function get_focus_ctrl_pos(parent_ctrl, child_ctrl_name)
  local form = parent_ctrl.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if nx_name(parent_ctrl) ~= "GroupScrollableBox" then
    return 0
  end
  local focus_ctrl_pos = 0
  for i = 0, parent_ctrl:GetChildControlCount() do
    local child_ctrl = form.gsb_1:GetChildControlByIndex(i)
    if nx_is_valid(child_ctrl) then
      if nx_string(child_ctrl.Name) == nx_string(child_ctrl_name) then
        return focus_ctrl_pos
      else
        focus_ctrl_pos = focus_ctrl_pos + child_ctrl.Height
      end
    end
  end
  return 0
end
function show_achievement_info_list(form)
  local ini = get_ini("share\\Rule\\Achievement\\player_achievement_task.ini")
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local AchievementManager = nx_value("AchievementManager")
  if not nx_is_valid(AchievementManager) then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.gsb_1.IsEditMode = true
  local sec_count = ini:GetSectionCount()
  for i = 1, sec_count do
    local achievement_type = ini:GetSectionByIndex(i - 1)
    local achievement_points = ini:ReadString(i - 1, "Value", "")
    local achievement_flag = ini:ReadString(i - 1, "Flag", "")
    local groupbox_1 = create_ctrl("GroupBox", "groupbox_achievement_type" .. nx_string(achievement_type), form.groupbox_achievement_type, form.gsb_1)
    if nx_is_valid(groupbox_1) then
      groupbox_1.type_index = achievement_type
      local cbtn = create_ctrl("CheckButton", "cbtn_achievement_" .. nx_string(achievement_type), form.cbtn_achievement, groupbox_1)
      if nx_is_valid(cbtn) then
        nx_bind_script(cbtn, nx_current())
        nx_callback(cbtn, "on_checked_changed", "on_cbtn_achievement_type_checked_changed")
        cbtn.DataSource = nx_string(achievement_type)
      end
      local lbl_title = create_ctrl("Label", "lbl_achievement_title_" .. nx_string(achievement_type), form.lbl_achievement_title, groupbox_1)
      local lbl_content = create_ctrl("Label", "lbl_achievement_content_" .. nx_string(achievement_type), form.lbl_achievement_content, groupbox_1)
      local title = "ui_achievement_type_title_" .. nx_string(achievement_type)
      if nx_is_valid(lbl_title) then
        lbl_title.Text = nx_widestr(gui.TextManager:GetFormatText(title))
      end
      local content = "ui_achievement_type_content_" .. nx_string(achievement_type)
      if nx_is_valid(lbl_content) then
        lbl_content.Text = nx_widestr(gui.TextManager:GetFormatText(content))
      end
      local state_img_ctrl = create_ctrl("Label", "lbl_achievement_state_img_" .. nx_string(achievement_type), form.lbl_achievement_state_img, groupbox_1)
      local finished_count = 0
      local goal_count = AchievementManager:FindGoalCountByType(nx_int(achievement_type))
      if client_player:FindRecord("AchievementBehaviorRec") then
        local rows = client_player:FindRecordRow("AchievementBehaviorRec", 0, nx_int(achievement_type))
        if nx_int(rows) >= nx_int(0) then
          finished_count = client_player:QueryRecord("AchievementBehaviorRec", rows, 1)
        end
      end
      if nx_int(finished_count) >= nx_int(goal_count) then
        state_img_ctrl.Visible = true
      else
        state_img_ctrl.Visible = false
      end
      local points_ctrl = create_ctrl("Label", "lbl_achievement_points_" .. nx_string(achievement_type), form.lbl_achievement_points, groupbox_1)
      if nx_is_valid(points_ctrl) then
        points_ctrl.Text = nx_widestr(nx_string(achievement_points))
      end
      local award_name_list = AchievementManager:FindAwardInfoByType(nx_int(achievement_type))
      if nx_int(table.getn(award_name_list)) > nx_int(0) then
        local image_grid = create_ctrl("ImageGrid", "imagegrid" .. nx_string(achievement_type), form.imagegrid, groupbox_1)
        if nx_is_valid(image_grid) then
          local photo = ItemsQuery:GetItemPropByConfigID(award_name_list[1], "Photo")
          image_grid:AddItem(0, photo, util_text(nx_string(award_name_list[1])), 1, -1)
          image_grid.item_config = nx_string(award_name_list[1])
          nx_bind_script(image_grid, nx_current())
          nx_callback(image_grid, "on_mousein_grid", "on_imagegrid_mousein_grid")
          nx_callback(image_grid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
        end
      end
      local flag_ctrl = create_ctrl("Label", "lbl_achievement_flag_" .. nx_string(achievement_type), form.lbl_achievement_flag, groupbox_1)
      if nx_is_valid(flag_ctrl) then
        flag_ctrl.BackImage = nx_string(achievement_flag)
      end
    end
    local groupbox_2 = create_ctrl("GroupBox", "groupbox_achievement_detail_dec" .. nx_string(achievement_type), form.groupbox_achievement_detail_dec, form.gsb_1)
    if nx_is_valid(groupbox_2) then
      groupbox_2.Height = 0
      groupbox_2.Visible = false
    end
  end
  form.gsb_1.IsEditMode = false
  form.groupbox_achievement_type.Visible = false
  form.gsb_1:ResetChildrenYPos()
end
function on_cbtn_achievement_type_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local AchievementManager = nx_value("AchievementManager")
  if not nx_is_valid(AchievementManager) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local index = cbtn.DataSource
  local gb_one = form.gsb_1:Find("groupbox_achievement_detail_dec" .. nx_string(index))
  if not nx_is_valid(gb_one) then
    return
  end
  local finished_count = 0
  local process_state = 0
  if client_player:FindRecord("AchievementBehaviorRec") then
    local rows = client_player:FindRecordRow("AchievementBehaviorRec", 0, nx_int(index))
    if nx_int(rows) >= nx_int(0) then
      finished_count = client_player:QueryRecord("AchievementBehaviorRec", rows, 1)
      process_state = client_player:QueryRecord("AchievementBehaviorRec", rows, 2)
    end
  end
  form.gsb_1.IsEditMode = true
  if cbtn.Checked then
    gb_one.Height = 80
    gb_one.Visible = true
    local title_ctrl_name = "lbl_state" .. nx_string(index)
    local lbl_goal_title = gb_one:Find(nx_string(title_ctrl_name))
    if not nx_is_valid(lbl_goal_title) then
      lbl_goal_title = create_ctrl("Label", title_ctrl_name, form.lbl_state, gb_one)
    end
    local goal_name_list = AchievementManager:FindGoalNameInfoByType(nx_int(index))
    local has_goal = 0
    if nx_int(table.getn(goal_name_list)) > nx_int(0) then
      has_goal = 1
    end
    local row = 0
    for i = 1, nx_number(table.getn(goal_name_list)) do
      row = nx_int(i / 5)
      local ctrl_name = "lbl_achievement_state" .. nx_string(i)
      local lbl_achievement_state = gb_one:Find(nx_string(ctrl_name))
      if not nx_is_valid(lbl_achievement_state) then
        lbl_achievement_state = create_ctrl("Label", ctrl_name, form.lbl_achievement_state, gb_one)
        if nx_is_valid(lbl_achievement_state) then
          lbl_achievement_state.Left = lbl_achievement_state.Left + (i - row * 4 - 1) * 150
          lbl_achievement_state.Top = lbl_achievement_state.Top + row * 50
          if 0 < process_state then
            local shift_value = nx_function("ext_bit_lshift", 1, i - 1)
            local result = nx_function("ext_bit_band", shift_value, process_state)
            if 0 < result then
              lbl_achievement_state.ForeColor = "255,255,255,255"
            end
          end
          lbl_achievement_state.Text = nx_widestr(util_text(nx_string(goal_name_list[i])))
        end
      end
    end
    local goal_count = AchievementManager:FindGoalCountByType(nx_int(index))
    if has_goal == 0 and 1 < goal_count then
      has_goal = 1
      local lbl_achievement_state = gb_one:Find("lbl_achievement_state_content")
      if not nx_is_valid(lbl_achievement_state) then
        lbl_achievement_state = create_ctrl("Label", "lbl_achievement_state_content", form.lbl_achievement_state, gb_one)
        local show_goal_count = nx_string(finished_count) .. "/" .. nx_string(goal_count)
        lbl_achievement_state.Text = nx_widestr(show_goal_count)
      end
    end
    if has_goal == 0 then
      gb_one.Height = 0
      gb_one.Visible = false
    end
    gb_one.Height = form.lbl_achievement_state.Top + row * 50 + 50
    diable_other_cbtn(form, nx_string(cbtn.Name))
  else
    gb_one.Height = 0
    gb_one.Visible = false
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1:ResetChildrenYPos()
end
function diable_other_cbtn(form, cbtn_name)
  local gb = nx_null()
  local cbtn_temp_name = ""
  for i = 0, form.gsb_1:GetChildControlCount() do
    gb = form.gsb_1:GetChildControlByIndex(i)
    if nx_is_valid(gb) and nx_find_custom(gb, "type_index") then
      cbtn_temp_name = "cbtn_achievement_" .. nx_string(gb.type_index)
      if nx_find_custom(form, nx_string(cbtn_temp_name)) then
        local cbtn_temp = nx_custom(form, nx_string(cbtn_temp_name))
        if nx_is_valid(cbtn_temp) and nx_string(cbtn_name) ~= nx_string(cbtn_temp_name) and cbtn_temp.Checked then
          cbtn_temp.Checked = false
        end
      end
    end
  end
end
function on_imagegrid_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  if not nx_find_custom(grid, "item_config") then
    return
  end
  if 3 < index then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", grid.item_config, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_ipt_search_key_get_focus(self)
  local gui = nx_value("gui")
  gui.hyperfocused = self
  if nx_string(self.Text) == nx_string(util_text("ui_trade_search_key")) then
    self.Text = ""
  end
end
function on_ipt_search_key_lost_focus(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(self.Text) == nx_string("") then
    self.Text = nx_widestr(util_text("ui_trade_search_key"))
  end
end
function on_ipt_search_key_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(self.Text) == nx_string("") then
    return
  end
  if nx_string(self.Text) == nx_string(util_text("ui_trade_search_key")) then
    return
  end
  local gui = nx_value("gui")
  local AchievementManager = nx_value("AchievementManager")
  if not nx_is_valid(AchievementManager) then
    return
  end
  form.combobox_itemname.DropListBox:ClearString()
  local search_table = AchievementManager:FindTypeByName(nx_widestr(self.Text))
  achievement_type_table = {}
  local achievement_type_info
  local value = {}
  for i = 1, nx_number(table.getn(search_table)) do
    achievement_type_info = ""
    achievement_type_info = util_split_wstring(search_table[i], nx_widestr(","))
    if table.getn(achievement_type_info) == 2 then
      form.combobox_itemname.DropListBox:AddString(nx_widestr(achievement_type_info[1]))
      value = {}
      value.type_name = achievement_type_info[1]
      value.item_type = achievement_type_info[2]
      table.insert(achievement_type_table, value)
    end
  end
  if not form.combobox_itemname.DroppedDown then
    form.combobox_itemname.DroppedDown = true
  end
end
function on_combobox_itemname_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local value = {}
  local index = form.combobox_itemname.DropListBox.SelectIndex
  if index < table.getn(achievement_type_table) then
    value = achievement_type_table[index + 1]
    form.type_info = value.item_type
  end
  form.ipt_search_key.Text = form.combobox_itemname.Text
  form.combobox_itemname.Text = nx_widestr("")
  local child_node = find_node_by_name(form.tree_achievement_type.RootNode, value.type_name)
  if not nx_is_valid(child_node) then
    return
  end
  form.tree_achievement_type.SelectNode = child_node
  child_node.Expand = true
  form.tree_achievement_type.RootNode:ExpandAll()
end
function find_node_by_name(parent_node, type_name)
  local nodes = parent_node:GetNodeList()
  local index = 0
  for _, node in ipairs(nodes) do
    if nx_widestr(node.Text) == nx_widestr(type_name) then
      if nx_is_valid(node) then
        return node
      end
    else
      local num = node:GetNodeCount()
      if nx_int(num) > nx_int(0) then
        local find_node = find_node_by_name(node, type_name)
        if nx_is_valid(find_node) then
          return find_node
        end
      end
    end
    index = index + 1
    if index == 100 then
      return nx_null()
    end
  end
end
function find_node_by_type(parent_node, type_index)
  local nodes = parent_node:GetNodeList()
  local index = 0
  for _, node in ipairs(nodes) do
    if nx_find_custom(node, "item_type") and nx_int(node.item_type) == nx_int(type_index) then
      if nx_is_valid(node) then
        return node
      end
    else
      local num = node:GetNodeCount()
      if nx_int(num) > nx_int(0) then
        local find_node = find_node_by_type(node, type_index)
        if nx_is_valid(find_node) then
          return find_node
        end
      end
    end
    index = index + 1
    if index == 100 then
      return nx_null()
    end
  end
end
function create_achievement_tree(form)
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_achievement_type:CreateRootNode(nx_widestr("Root"))
  form.tree_achievement_type:BeginUpdate()
  form.root = root
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\Achievement\\achievement_type.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_type_count = ini:GetSectionCount()
  for i = 0, sec_type_count - 1 do
    local sec_name = ini:GetSectionByIndex(i)
    local first_root = root:CreateNode(nx_widestr(util_text(sec_name)))
    set_node_prop(first_root, "first")
    first_root.type = 1
    local third_type_count = ini:GetSectionItemCount(i)
    for j = 0, third_type_count - 1 do
      local type_info = ini:GetSectionItemValue(i, j)
      local type_name = "ui_achievement_type_title_" .. nx_string(type_info)
      local second_root = first_root:CreateNode(nx_widestr(util_text(type_name)))
      second_root.item_type = type_info
      set_node_prop(second_root, "second")
      second_root.type = 2
      local ini_forth_type = nx_execute("util_functions", "get_ini", "share\\Rule\\Achievement\\achievement_sub_type.ini")
      if nx_is_valid(ini_forth_type) then
        local sec_index = ini_forth_type:FindSectionIndex(nx_string(type_info))
        if 0 <= sec_index then
          local count = ini_forth_type:GetSectionItemCount(sec_index)
          for k = 0, count - 1 do
            local sub_type_info = ini_forth_type:GetSectionItemValue(sec_index, k)
            local sub_type_name = "ui_achievement_type_title_" .. nx_string(sub_type_info)
            local third_root = second_root:CreateNode(nx_widestr(util_text(sub_type_name)))
            third_root.item_type = sub_type_info
            set_node_prop(third_root, "third")
            third_root.type = 3
          end
        end
      end
    end
  end
  root.Expand = true
  form.tree_achievement_type:EndUpdate()
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
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
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
