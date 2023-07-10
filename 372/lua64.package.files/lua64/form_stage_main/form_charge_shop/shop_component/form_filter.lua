require("util_gui")
require("util_functions")
require("form_stage_main\\form_charge_shop\\shop_util")
local g_form_name = "form_stage_main\\form_charge_shop\\shop_component\\form_filter"
local g_max_option = 7
local FT_FILTER = 0
local FT_SEARCH = 1
local FT_FAV = 2
local FT_SPECIAL = 3
local g_special_name = {
  [-1] = "ui_shop_special_0",
  [1] = "ui_shop_special_1",
  [2] = "ui_shop_special_2",
  [3] = "ui_shop_special_3",
  [4] = "ui_shop_special_4",
  [5] = "ui_shop_special_5",
  [6] = "ui_shop_special_6",
  [7] = "ui_shop_special_7"
}
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  local g_shop_sex_items = {
    [0] = form.rbtn_man,
    [1] = form.rbtn_female,
    [2] = form.rbtn_all
  }
  for index, item in pairs(g_shop_sex_items) do
    nx_set_custom(item, "item_sex", index)
  end
  g_shop_sex_items[2].Checked = true
  local box = form.combobox_special.DropListBox
  box:ClearString()
  for _, str in pairs(g_special_name) do
    box:AddString(util_format_string(str))
  end
  form.combobox_special.InputEdit.Text = util_format_string(g_special_name[-1])
  form.combobox_special.DropDownWidth = 100
  box.Left = -40
end
function on_main_form_close(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_select_shop(type)
  local g_shop_type = {
    [CHARGE_VIPCARD_SHOP] = 4,
    [CHARGE_GATHER_SHOP] = 4,
    [CHARGE_NORMAL_SHOP] = 4,
    [CHARGE_OTHER_ITEM_SHOP] = 4,
    [CHARGE_MOUNT_SHOP] = 3,
    [CHARGE_INTERACTIVE_SHOP] = 4,
    [CHARGE_ARTEQUIP_SHOP] = 2,
    [CHARGE_GUILD_SHOP] = 5,
    [CHARGE_BAG_SHOP] = 4,
    [CHARGE_FIGHT_ITEM] = 4,
    [CHARGE_GUASHI_ITEM] = 4,
    [-1] = 2
  }
  local shopmgr = nx_value("ChargeShop")
  if not nx_is_valid(shopmgr) then
    return
  end
  if type == -1 then
    type = shopmgr.DefShopType
  else
    type = g_shop_type[type]
  end
  if type == nil then
    type = shopmgr.DefShopType
  end
  shopmgr:SetFilterInfo("filter_type", FT_FILTER, 0)
  shopmgr:SetFilterInfo("shop_type", type, 0)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local shop_item
  local g_shop_type_items = {
    [1] = form.rbtn_shop_type_1,
    [2] = form.rbtn_shop_type_2,
    [3] = form.rbtn_shop_type_3,
    [4] = form.rbtn_shop_type_4,
    [5] = form.rbtn_shop_type_5
  }
  for index, item in pairs(g_shop_type_items) do
    local temp = nx_custom(item, "type")
    if temp == type then
      shop_item = item
    end
  end
  if not nx_is_valid(shop_item) then
    return
  end
  if shop_item.Visible == false then
    return
  end
  local rbtn = shop_item
  if rbtn.Checked == false then
    rbtn.Checked = true
  end
end
function on_search_text_changed(ipt)
end
function on_special_selected(combox)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  local form = combox.ParentForm
  local select_str = combox.DropListBox.SelectString
  local special_type = -2
  for i, str in pairs(g_special_name) do
    if nx_ws_equal(select_str, util_format_string(str)) then
      special_type = i
      break
    end
  end
  mgr:SetFilterInfo("filter_type", FT_SPECIAL, 0)
  mgr:SetFilterInfo("special_type", special_type, 1)
end
function on_search_click(btn)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:SetFilterInfo("filter_type", FT_SEARCH, 0)
  mgr:SetFilterInfo("search_name", btn.ParentForm.ipt_search.Text, 1)
end
function on_class_changed(rbtn)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  if rbtn.Checked then
    local form = rbtn.ParentForm
    mgr:SetFilterInfo("filter_type", FT_FILTER, 0)
    local shop_type = nx_custom(rbtn, "type")
    if form.rbtn_item_type_0.Checked then
      mgr:SetFilterInfo("shop_type", shop_type, 1)
    else
      mgr:SetFilterInfo("shop_type", shop_type, 0)
      form.rbtn_item_type_0.Checked = true
    end
    rbtn.ParentForm.groupbox_cloth.Visible = shop_type == 2
  end
end
function on_type_changed(rbtn)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  if rbtn.Checked then
    mgr:SetFilterInfo("filter_type", FT_FILTER, 0)
    local item_type = nx_custom(rbtn, "type")
    mgr:SetFilterInfo("item_type", item_type, 1)
  end
end
function on_sex_changed(rbtn)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  if rbtn.Checked then
    mgr:SetFilterInfo("filter_type", FT_FILTER, 0)
    local sex_type = nx_custom(rbtn, "item_sex")
    mgr:SetFilterInfo("sex_type", sex_type, 1)
  end
end
function filter_favrate()
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:SetFilterInfo("filter_type", FT_FAV, 1)
end
function on_money_type_changed(money_type)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:SetFilterInfo("filter_type", FT_FILTER, 0)
  mgr:SetFilterInfo("money_type", money_type, 0)
  if money_type == -1 then
    return
  end
  local form = nx_value(g_form_name)
  if nx_is_valid(form) then
    local shop_rbtn = form.rbtn_shop_type_1
    if shop_rbtn.Checked then
      local shop_type = nx_custom(shop_rbtn, "type")
      mgr:SetFilterInfo("shop_type", shop_type, 0)
      local item_rbtn = form.rbtn_item_type_0
      local item_type = nx_custom(item_rbtn, "type")
      if item_rbtn.Checked then
        mgr:SetFilterInfo("item_type", item_type, 1)
      else
        item_rbtn.Checked = true
      end
    else
      shop_rbtn.Checked = true
    end
  end
end
function reset_shop_lab_name(count, ...)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local g_item_type_items = {
    [0] = form.rbtn_item_type_0,
    [1] = form.rbtn_item_type_1,
    [2] = form.rbtn_item_type_2,
    [3] = form.rbtn_item_type_3,
    [4] = form.rbtn_item_type_4,
    [5] = form.rbtn_item_type_5,
    [6] = form.rbtn_item_type_6,
    [7] = form.rbtn_item_type_7
  }
  for _, item in pairs(g_item_type_items) do
    item.Visible = false
  end
  if count > table.getn(g_item_type_items) then
    count = table.getn(g_item_type_items)
  end
  for i = 0, count - 1 do
    local type = arg[2 * i + 1]
    local str = arg[2 * i + 2]
    local rbtn = g_item_type_items[i]
    if type ~= nil and str ~= nil and 0 < string.len(str) then
      rbtn.Text = util_format_string(str)
      nx_set_custom(rbtn, "type", type)
      rbtn.Visible = true
    end
  end
end
function reset_money_shop_name(count, ...)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local g_shop_type_items = {
    [1] = form.rbtn_shop_type_1,
    [2] = form.rbtn_shop_type_2,
    [3] = form.rbtn_shop_type_3,
    [4] = form.rbtn_shop_type_4,
    [5] = form.rbtn_shop_type_5
  }
  for _, item in pairs(g_shop_type_items) do
    item.Visible = false
  end
  if count > table.getn(g_shop_type_items) then
    count = table.getn(g_shop_type_items)
  end
  for i = 0, count - 1 do
    local type = arg[2 * i + 1]
    local str = arg[2 * i + 2]
    local rbtn = g_shop_type_items[i + 1]
    if type ~= nil and str ~= nil and 0 < string.len(str) then
      rbtn.Text = util_format_string(str)
      nx_set_custom(rbtn, "type", type)
      rbtn.Visible = true
    end
  end
end
