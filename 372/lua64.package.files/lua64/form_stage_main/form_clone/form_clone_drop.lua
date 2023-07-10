require("custom_sender")
require("util_functions")
require("util_gui")
local CLONE_DROP_INI = "ini\\ui\\clonescene\\clonedrop.ini"
local MAX_RESET_COUNT = 7
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.gpsb_items:DeleteAll()
  form:Close()
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    show_clone_drop_info(form.clone_id, rbtn.DataSource)
  end
end
function on_cbtn_title_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_find_custom(cbtn, "gbox_items") then
    return 0
  end
  if not nx_find_custom(cbtn, "min_height") then
    return 0
  end
  if not nx_find_custom(cbtn, "max_height") then
    return 0
  end
  if not cbtn.Checked then
    cbtn.gbox_items.Height = cbtn.max_height
  else
    cbtn.gbox_items.Height = cbtn.min_height
  end
  form.gpsb_items:ResetChildrenYPos()
end
function show_clone_drop_info(clone_id, select_index)
  local mainform = nx_value("form_stage_main\\form_clone\\form_clone_main")
  if not nx_is_valid(mainform) then
    return
  end
  local form = util_get_form("form_stage_main\\form_clone\\form_clone_drop", true)
  form.AbsTop = mainform.AbsTop + 7
  form.AbsLeft = mainform.AbsLeft + mainform.Width
  form.clone_id = clone_id
  if nx_number(select_index) == 1 then
    local check_rbtn = form.groupbox_check:Find("rbtn_" .. nx_string(select_index))
    if nx_is_valid(check_rbtn) then
      check_rbtn.Checked = true
    end
  end
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return
  end
  local clone_drop_ini = nx_execute("util_functions", "get_ini", CLONE_DROP_INI)
  if not nx_is_valid(clone_drop_ini) then
    return
  end
  local sec_index_1 = clone_drop_ini:FindSectionIndex(nx_string(clone_id))
  form.gpsb_items:DeleteAll()
  local treasures_list = clone_drop_ini:GetItemValueList(sec_index_1, "Treasure" .. nx_string(select_index))
  for i = 1, table.getn(treasures_list) do
    local treasure_tab = util_split_string(treasures_list[i], ",")
    local gbox_items = nx_null()
    local cbtn_title = nx_null()
    if table.getn(treasure_tab) > 0 then
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
  form.Visible = true
  form:Show()
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
function open_drop_form()
  local form_clone_drop = nx_value("form_stage_main\\form_clone\\form_clone_drop")
  if nx_is_valid(form_clone_drop) then
    util_show_form("form_stage_main\\form_clone\\form_clone_drop", false)
  else
    util_show_form("form_stage_main\\form_clone\\form_clone_drop", true)
  end
end
