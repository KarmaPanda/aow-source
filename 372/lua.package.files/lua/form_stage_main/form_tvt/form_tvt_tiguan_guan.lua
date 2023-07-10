require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("custom_sender")
local FORM_TVT_TIGUAN_GUAN = "form_stage_main\\form_tvt\\form_tvt_tiguan_guan"
local FORM_TVT_TIGUAN = "form_stage_main\\form_tvt\\form_tvt_tiguan"
local FORCE_NAME = "group_karma_"
function main_form_init(self)
  self.Fixed = false
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.rbtn_general.Checked = true
  self.gbox_general.Visible = true
  self.gbox_relation.Visible = false
  self.gbox_histroy.Visible = false
  return 1
end
function main_form_close(self)
  nx_execute("util_gui", "util_show_form", FORM_TVT_TIGUAN_GUAN, false)
end
function on_btn_close_click(self)
  hide_guan_info_form()
end
function on_rbtn_guan_checked_changed(self)
  local form = self.ParentForm
  form.gbox_general.Visible = form.rbtn_general.Checked
  form.gbox_relation.Visible = form.rbtn_relation.Checked
  form.gbox_histroy.Visible = form.rbtn_histroy.Checked
  form.gbox_treasure.Visible = form.rbtn_treasure.Checked
end
function on_cbtn_title_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(self, "gbox_items") then
    return 0
  end
  if not nx_find_custom(self, "min_height") then
    return 0
  end
  if not nx_find_custom(self, "max_height") then
    return 0
  end
  if not self.Checked then
    self.gbox_items.Height = self.max_height
  else
    self.gbox_items.Height = self.min_height
  end
  form.gpsb_items:ResetChildrenYPos()
  return 1
end
function on_grid_item_photo_mousein_grid(self, index)
  if not nx_find_custom(self, "item_id") then
    return 0
  end
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return 0
  end
  local item_type = itemQuery:GetItemPropByConfigID(self.item_id, "ItemType")
  nx_execute("tips_game", "show_tips_common", self.item_id, item_type, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), self.ParentForm)
end
function on_grid_item_photo_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function show_guan_info(guan_id)
  local form = util_get_form(FORM_TVT_TIGUAN_GUAN, false)
  if not nx_is_valid(form) then
    return 0
  end
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return 0
  end
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return 0
  end
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  local guan_share_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(guan_ui_ini) or not nx_is_valid(guan_share_ini) then
    return 0
  end
  local sec_index_1 = guan_ui_ini:FindSectionIndex(nx_string(guan_id))
  local sec_index_2 = guan_share_ini:FindSectionIndex(nx_string(guan_id))
  if 0 > nx_number(sec_index_1) or 0 > nx_number(sec_index_2) then
    return 0
  end
  local name_id = guan_ui_ini:ReadString(sec_index_1, "Name", "")
  form.lbl_name.Text = nx_widestr(get_desc_by_id(name_id))
  local cdt_id = guan_share_ini:ReadString(sec_index_2, "MemberConditionID", "")
  form.lbl_condition.Text = nx_widestr(get_desc_by_id(cdt_mgr:GetConditionDesc(nx_int(cdt_id))))
  if check_iscan_enter(cdt_id) then
    form.lbl_condition.ForeColor = "255,0,128,0"
  else
    form.lbl_condition.ForeColor = "255,255,0,0"
  end
  form.lbl_photo.BackImage = guan_ui_ini:ReadString(sec_index_1, "Photo", "")
  local location_id = guan_ui_ini:ReadString(sec_index_1, "Location", "")
  form.mltbox_location.HtmlText = nx_widestr(get_desc_by_id(location_id))
  local desc1_id = guan_ui_ini:ReadString(sec_index_1, "DetailDesc1", "")
  form.mltbox_info_1.HtmlText = nx_widestr(get_desc_by_id(desc1_id))
  local desc2_id = guan_ui_ini:ReadString(sec_index_1, "DetailDesc2", "")
  form.mltbox_info_2.HtmlText = nx_widestr(get_desc_by_id(desc2_id))
  local desc3_id = guan_ui_ini:ReadString(sec_index_1, "DetailDesc3", "")
  form.mltbox_info_3.HtmlText = nx_widestr(get_desc_by_id(desc3_id))
  local histroy_id = guan_ui_ini:ReadString(sec_index_1, "HistroyDesc", "")
  form.mltbox_histroy.HtmlText = nx_widestr(get_desc_by_id(histroy_id))
  local friends_id = guan_ui_ini:ReadString(sec_index_1, "FriendGroup", "")
  form.grid_friend:ClearSelect()
  form.grid_friend:ClearRow()
  local friend_tab = util_split_string(friends_id, ",")
  for i = 1, table.getn(friend_tab) do
    local name_id = FORCE_NAME .. nx_string(friend_tab[i])
    if i % 2 ~= 0 then
      form.grid_friend:InsertRow(-1)
      form.grid_friend:SetGridText((i - 1) / 2, 0, nx_widestr(get_desc_by_id(name_id)))
    else
      form.grid_friend:SetGridText((i - 1) / 2, 1, nx_widestr(get_desc_by_id(name_id)))
    end
  end
  local enemys_id = guan_ui_ini:ReadString(sec_index_1, "EnemyGroup", "")
  form.grid_enemy:ClearSelect()
  form.grid_enemy:ClearRow()
  local enemy_tab = util_split_string(enemys_id, ",")
  for i = 1, table.getn(enemy_tab) do
    local name_id = FORCE_NAME .. nx_string(enemy_tab[i])
    if i % 2 ~= 0 then
      form.grid_enemy:InsertRow(-1)
      form.grid_enemy:SetGridText((i - 1) / 2, 0, nx_widestr(get_desc_by_id(name_id)))
    else
      form.grid_enemy:SetGridText((i - 1) / 2, 1, nx_widestr(get_desc_by_id(name_id)))
    end
  end
  form.gpsb_items:DeleteAll()
  local treasures_list = guan_ui_ini:GetItemValueList(sec_index_1, "Treasure")
  for i = 1, table.getn(treasures_list) do
    local treasure_tab = util_split_string(treasures_list[i], ",")
    local gbox_items = nx_null()
    local cbtn_title = nx_null()
    if 0 < table.getn(treasure_tab) then
      gbox_items = create_ctrl("GroupBox", "gbox_items_" .. treasure_tab[1], form.gbox_items, form.gpsb_items)
      cbtn_title = create_ctrl("CheckButton", "cbtn_title_" .. treasure_tab[1], form.cbtn_item_title, gbox_items)
      cbtn_title.Text = nx_widestr(get_desc_by_id(treasure_tab[1]))
      cbtn_title.gbox_items = gbox_items
      cbtn_title.min_height = cbtn_title.Height + cbtn_title.Top
      cbtn_title.max_height = cbtn_title.Height + cbtn_title.Top + form.gbox_item1.Height * (table.getn(treasure_tab) / 2)
      gbox_items.Height = cbtn_title.max_height
      nx_bind_script(cbtn_title, nx_current())
      nx_callback(cbtn_title, "on_checked_changed", "on_cbtn_title_checked_changed")
    end
    for j = 2, table.getn(treasure_tab) do
      local item_id = treasure_tab[j]
      local gbox_item = nx_null()
      if (j - 1) % 2 ~= 0 then
        gbox_item = create_ctrl("GroupBox", "gbox_item_" .. item_id, form.gbox_item1, gbox_items)
      else
        gbox_item = create_ctrl("GroupBox", "gbox_item_" .. item_id, form.gbox_item2, gbox_items)
      end
      gbox_item.Top = form.cbtn_item_title.Height + form.gbox_item1.Height * nx_int((j - 2) / 2)
      local mltbox_name = create_ctrl("MultiTextBox", "lbl_name_" .. item_id, form.mltbox_item_name, gbox_item)
      local grid_photo = create_ctrl("ImageGrid", "grid_photo_" .. item_id, form.grid_item_photo, gbox_item)
      nx_bind_script(grid_photo, nx_current())
      nx_callback(grid_photo, "on_mousein_grid", "on_grid_item_photo_mousein_grid")
      nx_callback(grid_photo, "on_mouseout_grid", "on_grid_item_photo_mouseout_grid")
      grid_photo.item_id = item_id
      mltbox_name.HtmlText = get_desc_by_id(item_id)
      local photo = itemQuery:GetItemPropByConfigID(item_id, "Photo")
      grid_photo:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(1), -1)
    end
  end
  form.gpsb_items:ResetChildrenYPos()
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
  return ctrl
end
function get_desc_by_id(text_id)
  local gui = nx_value("gui")
  return gui.TextManager:GetText(nx_string(text_id))
end
function check_iscan_enter(conditions_id)
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local cdt_tab = util_split_string(nx_string(conditions_id), ";")
  for i = 1, table.getn(cdt_tab) do
    if not cdt_mgr:CanSatisfyCondition(player, player, nx_int(cdt_tab[i])) then
      return false
    end
  end
  return true
end
function show_guan_info_form(guan_id)
  local form_tvt_tiguan = util_get_form(FORM_TVT_TIGUAN, false)
  if not nx_is_valid(form_tvt_tiguan) then
    return 0
  end
  if nx_find_custom(form_tvt_tiguan, "form_guan_info") and nx_is_valid(form_tvt_tiguan.form_guan_info) then
    show_guan_info(guan_id)
    form_tvt_tiguan.Width = 1024
  else
    local form_guan_info = util_get_form(FORM_TVT_TIGUAN_GUAN, true)
    if nx_is_valid(form_guan_info) then
      show_guan_info(guan_id)
      if form_tvt_tiguan:Add(form_guan_info) then
        form_guan_info.Visible = true
        form_guan_info.Fixed = true
        form_guan_info.Top = 0
        form_guan_info.Left = 714
      end
      form_tvt_tiguan.Width = 1024
      nx_set_custom(form_tvt_tiguan, "form_guan_info", form_guan_info)
    end
  end
end
function hide_guan_info_form()
  local form_tvt_tiguan = util_get_form(FORM_TVT_TIGUAN, false)
  if nx_is_valid(form_tvt_tiguan) then
    form_tvt_tiguan.Width = 714
  end
end
