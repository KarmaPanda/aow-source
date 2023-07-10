require("util_functions")
require("util_gui")
require("util_static_data")
local KAPAI_PRIZE_INI = "share\\Karma\\prestige_help.ini"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function init_form(form)
  local mainform = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(mainform) then
    return
  end
  if not nx_find_custom(form, "kapai_id") then
    return
  end
  form.AbsTop = mainform.AbsTop + 16
  form.AbsLeft = mainform.AbsLeft + mainform.Width
  local kapai_manager = nx_value("Kapai")
  local kapai_prize_ini = nx_execute("util_functions", "get_ini", KAPAI_PRIZE_INI)
  local gui = nx_value("gui")
  if not (nx_is_valid(kapai_prize_ini) and nx_is_valid(kapai_manager)) or not nx_is_valid(gui) then
    return
  end
  form.gpsb_items:DeleteAll()
  local type_table = kapai_manager:GetAllKapaiType()
  table.sort(type_table)
  local size = table.getn(type_table)
  for i = 1, size do
    local ctrl = form.groupbox_check:Find("rbtn_" .. nx_string(i))
    if nx_is_valid(ctrl) then
      ctrl.Text = nx_widestr(gui.TextManager:GetText("type_prestige_" .. nx_string(type_table[i])))
    end
  end
  local kapai_index = kapai_prize_ini:FindSectionIndex(nx_string(form.kapai_id))
  local item_count = kapai_prize_ini:GetSectionItemCount(kapai_index)
  for j = 0, item_count do
    local key = kapai_prize_ini:GetSectionItemKey(kapai_index, j)
    local value = kapai_prize_ini:GetSectionItemValue(kapai_index, j)
    local value_tab = util_split_string(nx_string(value), ",")
    if nx_string(key) ~= nx_string("") then
      local gbox_items = create_title(key, table.getn(value_tab))
      for k, val in ipairs(value_tab) do
        create_treasure(k, val, gbox_items)
      end
    end
  end
  form.gpsb_items:ResetChildrenYPos()
end
function create_title(key, num_table)
  local form = nx_value("form_stage_main\\form_origin\\form_kapai_drop")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or not nx_is_valid(form) then
    return
  end
  local gbox_items = nx_null()
  local cbtn_title = nx_null()
  gbox_items = create_ctrl("GroupBox", "gbox_items_" .. key, form.gbox_items, form.gpsb_items)
  cbtn_title = create_ctrl("CheckButton", "cbtn_title_" .. key, form.cbtn_item_title, gbox_items)
  cbtn_title.Text = nx_widestr(gui.TextManager:GetText(nx_string(key)))
  cbtn_title.gbox_items = gbox_items
  cbtn_title.min_height = cbtn_title.Height + cbtn_title.Top
  if num_table % 2 ~= 0 then
    cbtn_title.max_height = cbtn_title.Height + cbtn_title.Top + form.gbox_item1.Height * (nx_int(num_table / 2) + 1)
  else
    cbtn_title.max_height = cbtn_title.Height + cbtn_title.Top + form.gbox_item1.Height * nx_int(num_table / 2)
  end
  gbox_items.Height = cbtn_title.max_height
  nx_bind_script(cbtn_title, nx_current())
  nx_callback(cbtn_title, "on_checked_changed", "on_cbtn_title_checked_changed")
  return gbox_items
end
function create_treasure(k, val, gbox_items)
  local form = nx_value("form_stage_main\\form_origin\\form_kapai_drop")
  local itemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  if not (nx_is_valid(itemQuery) and nx_is_valid(form) and nx_is_valid(gbox_items)) or not nx_is_valid(gui) then
    return
  end
  local gbox_item = nx_null()
  if k % 2 ~= 0 then
    gbox_item = create_ctrl("GroupBox", "gbox_item_" .. val, form.gbox_item1, gbox_items)
  else
    gbox_item = create_ctrl("GroupBox", "gbox_item_" .. val, form.gbox_item2, gbox_items)
  end
  gbox_item.Top = form.cbtn_item_title.Height + form.gbox_item1.Height * nx_int((k - 1) / 2)
  local mltbox_name = create_ctrl("MultiTextBox", "lbl_name_" .. val, form.mltbox_item_name, gbox_item)
  local grid_photo = create_ctrl("ImageGrid", "grid_photo_" .. val, form.grid_item_photo, gbox_item)
  nx_bind_script(grid_photo, nx_current())
  nx_callback(grid_photo, "on_mousein_grid", "on_grid_item_photo_mousein_grid")
  nx_callback(grid_photo, "on_mouseout_grid", "on_grid_item_photo_mouseout_grid")
  grid_photo.item_id = val
  mltbox_name.HtmlText = nx_widestr(gui.TextManager:GetText(nx_string(val)))
  local photo = itemQuery:GetItemPropByConfigID(val, "Photo")
  if nx_string("") == nx_string(photo) then
    photo = item_query_ArtPack_by_id_Ex(val, "Photo")
  end
  grid_photo:AddItem(0, nx_string(photo), nx_widestr(val), nx_int(1), -1)
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
    show_kapai_prize_info(rbtn.DataSource)
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
function show_kapai_prize_info(kapai_id)
  local form = nx_value("form_stage_main\\form_origin\\form_kapai_drop")
  if not nx_is_valid(form) or not nx_find_custom(form, "kapai_id") then
    return
  end
  form.kapai_id = kapai_id
  init_form(form)
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
function open_form(kapai_id)
  local form = util_get_form("form_stage_main\\form_origin\\form_kapai_drop", true)
  form.kapai_id = kapai_id
  local check_rbtn = form.groupbox_check:Find("rbtn_" .. nx_string(kapai_id))
  if nx_is_valid(check_rbtn) then
    check_rbtn.Checked = true
  end
  init_form(form)
  form:Show()
  form.Visible = true
end
