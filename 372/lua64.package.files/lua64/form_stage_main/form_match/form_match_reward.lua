require("custom_sender")
require("util_functions")
require("util_gui")
local REWAED_INFO = "ini\\ui\\match\\match_reward.ini"
local FORM_REWAED = "form_stage_main\\form_match\\form_match_reward"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
end
function open_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_REWAED, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
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
end
function show_match_reward_info()
  local mainform = nx_value("form_stage_main\\form_match\\form_match")
  if not nx_is_valid(mainform) then
    return
  end
  local form = util_get_form(FORM_REWAED, true)
  form.AbsTop = mainform.AbsTop - 8
  form.AbsLeft = mainform.AbsLeft + mainform.Width - 150
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return
  end
  local reward_ini = nx_execute("util_functions", "get_ini", REWAED_INFO)
  if not nx_is_valid(reward_ini) then
    return
  end
  local sec_index_1 = reward_ini:FindSectionIndex("MatchReward")
  form.gpsb_items:DeleteAll()
  local count = reward_ini:GetSectionItemCount(sec_index_1)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 0, count - 1 do
    local reward_info = reward_ini:GetSectionItemValue(sec_index_1, i)
    local reward_table = util_split_string(nx_string(reward_info), ",")
    local reward_dec = nx_string(reward_table[1])
    local reward_id = nx_string(reward_table[2])
    local gbox_items = nx_null()
    local gbox_item = nx_null()
    gbox_items = create_ctrl("GroupBox", "gbox_items_" .. reward_id, form.gbox_items, form.gpsb_items)
    gbox_item = create_ctrl("GroupBox", "gbox_item_" .. reward_id, form.gbox_item1, gbox_items)
    local mltbox_name = create_ctrl("MultiTextBox", "lbl_name_" .. reward_id, form.mltbox_item_name, gbox_item)
    mltbox_name.HtmlText = get_desc_by_id(reward_dec)
    local grid_photo = create_ctrl("ImageGrid", "grid_photo_" .. reward_id, form.grid_item_photo, gbox_item)
    nx_bind_script(grid_photo, nx_current())
    nx_callback(grid_photo, "on_mousein_grid", "on_grid_item_photo_mousein_grid")
    nx_callback(grid_photo, "on_mouseout_grid", "on_grid_item_photo_mouseout_grid")
    grid_photo.item_id = reward_id
    local photo = itemQuery:GetItemPropByConfigID(reward_id, "Photo")
    grid_photo:AddItem(0, nx_string(photo), nx_widestr(reward_id), nx_int(1), -1)
    gbox_items.Top = gbox_items.Height * i
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
