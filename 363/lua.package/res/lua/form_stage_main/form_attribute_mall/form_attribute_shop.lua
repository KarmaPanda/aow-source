require("tips_data")
require("tips_game")
require("util_gui")
require("util_functions")
FORM_ATTRIBUTE_MALL = "form_stage_main\\form_attribute_mall\\form_attribute_shop"
FORM_EXCHANGE_MALL = "form_stage_main\\form_attribute_mall\\form_attribute_exchange"
function on_main_form_init(form)
  form.Fixed = false
  form.jyz_step = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_cbtn_tmp_back1_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  cbtn.Checked = false
  show_exchange_item_dialog(cbtn.index)
end
function on_rbtn_1_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  show_exchange_info(form, 1)
end
function on_rbtn_2_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  show_exchange_info(form, 2)
end
function on_rbtn_3_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  show_exchange_info(form, 3)
end
function on_rbtn_4_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  show_exchange_info(form, 4)
end
function on_rbtn_5_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  show_exchange_info(form, 5)
end
function on_rbtn_6_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  show_exchange_info(form, 6)
end
function on_imagegrid_eh_select_changed(self, index)
  show_exchange_item_dialog(self.index)
end
function on_imagegrid_eh_mousein_grid(self, index)
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(self.item_id)
    item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(self.item_id), "ItemType", "0")
    nx_execute("tips_game", "show_goods_tip", item, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 40, 40, self.ParentForm)
  end
end
function on_imagegrid_eh_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_btn_return_click(btn)
  local mallform = btn.ParentForm
  mallform.Visible = false
  mallform:Close()
end
function add_exchange_item_info(form, index, col, groupbox_sub, id, item_id, exchange_type, item_desc, is_valid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local cbtn_back = create_ctrl("CheckButton", "cbtn_exchange_back_" .. nx_string(index), form.cbtn_tmp_back1, groupbox_sub)
  local imagegrid = create_ctrl("ImageGrid", "imagegrid_exchange_" .. nx_string(index), form.imagegrid_eh1, groupbox_sub)
  local mltbox_exchange = create_ctrl("MultiTextBox", "mltbox_exchange_" .. nx_string(index), form.mltbox_exchange, groupbox_sub)
  local mltbox_name = create_ctrl("MultiTextBox", "mltbox_tmp_name_" .. nx_string(index), form.mltbox_tmp_name1, groupbox_sub)
  local mltbox_desc = create_ctrl("MultiTextBox", "mltbox_tmp_desc_" .. nx_string(index), form.mltbox_tmp_desc1, groupbox_sub)
  nx_bind_script(cbtn_back, nx_current())
  nx_callback(cbtn_back, "on_click", "on_cbtn_tmp_back1_click")
  local photo = get_item_info(item_id, "photo")
  imagegrid:AddItem(0, photo, "", 1, -1)
  imagegrid.RowNum = 1
  imagegrid.ClomnNum = 1
  imagegrid.GridWidth = imagegrid.Width - 10
  imagegrid.GridHeight = imagegrid.Height - 10
  imagegrid.DrawMode = "Expand"
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_eh_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_eh_mouseout_grid")
  nx_callback(imagegrid, "on_select_changed", "on_imagegrid_eh_select_changed")
  imagegrid.item_id = item_id
  imagegrid.index = nx_int(id)
  if not is_valid then
    cbtn_back.Enabled = false
    imagegrid:ChangeItemImageToBW(0, true)
    imagegrid.BackImage = "gui\\special\\shitu\\huikuang.png"
    mltbox_name.TextColor = "255,80,80,80"
    mltbox_desc.TextColor = "255,80,80,80"
    mltbox_exchange.TextColor = "255,80,80,80"
  end
  mltbox_name:Clear()
  mltbox_name.Transparent = true
  mltbox_name:AddHtmlText(gui.TextManager:GetText(nx_string(item_id)), -1)
  local posx = (mltbox_name.Width - mltbox_name:GetContentWidth()) / 2
  mltbox_name.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
  mltbox_desc:Clear()
  mltbox_desc.Transparent = true
  mltbox_desc:AddHtmlText(gui.TextManager:GetText(exchange_type), -1)
  posx = (mltbox_desc.Width - mltbox_desc:GetContentWidth()) / 2
  mltbox_desc.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
  mltbox_exchange:Clear()
  mltbox_exchange.Transparent = true
  mltbox_exchange:AddHtmlText(gui.TextManager:GetText(item_desc), -1)
  posx = (mltbox_exchange.Width - mltbox_exchange:GetContentWidth()) / 2
  mltbox_exchange.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
  cbtn_back.index = nx_int(id)
end
function show_exchange_info(form, category)
  local exchange_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\AttributeMall\\AttributeMall.ini")
  if not nx_is_valid(exchange_ini) then
    return 0
  end
  form.groupscrollbox_1.IsEditMode = true
  form.groupscrollbox_1:DeleteAll()
  local section_count = exchange_ini:GetSectionCount()
  local index = 0
  local groupbox
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local cur_main_game_step = switch_manager:GetMainGameStep()
  for i = 1, section_count do
    local id = exchange_ini:GetSectionByIndex(i - 1)
    local exchange_category = exchange_ini:ReadInteger(i - 1, "Category", 0)
    local item_id = exchange_ini:ReadString(i - 1, "ItemID", "")
    local exchange_type = exchange_ini:ReadString(i - 1, "ExchangeType", "")
    local item_desc = exchange_ini:ReadString(i - 1, "ItemDesc", "")
    local condition_id = exchange_ini:ReadInteger(i - 1, "ConditionID", 0)
    local step = exchange_ini:ReadInteger(i - 1, "JyzStep", 0)
    if nx_number(category) == nx_number(exchange_category) and nx_int(step) <= nx_int(cur_main_game_step) then
      index = index + 1
      local col = index % 4
      local groupbox_sub
      if col == 1 then
        groupbox = create_ctrl("GroupBox", "gbox_exchange_" .. nx_string(index), form.groupbox_template, form.groupscrollbox_1)
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh1, groupbox)
      elseif col == 2 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh2, groupbox)
      elseif col == 3 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh3, groupbox)
      else
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh4, groupbox)
      end
      add_exchange_item_info(form, index, col, groupbox_sub, id, item_id, exchange_type, item_desc, true)
    end
  end
  for i = 1, section_count do
    local id = exchange_ini:GetSectionByIndex(i - 1)
    local exchange_category = exchange_ini:ReadInteger(i - 1, "Category", 0)
    local item_id = exchange_ini:ReadString(i - 1, "ItemID", "")
    local exchange_type = exchange_ini:ReadString(i - 1, "ExchangeType", "")
    local item_desc = exchange_ini:ReadString(i - 1, "ItemDesc", "")
    local condition_id = exchange_ini:ReadInteger(i - 1, "ConditionID", 0)
    local step = exchange_ini:ReadInteger(i - 1, "JyzStep", 0)
    if nx_number(category) == nx_number(exchange_category) and nx_int(step) > nx_int(cur_main_game_step) then
      index = index + 1
      local col = index % 4
      local groupbox_sub
      if col == 1 then
        groupbox = create_ctrl("GroupBox", "gbox_exchange_" .. nx_string(index), form.groupbox_template, form.groupscrollbox_1)
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh1, groupbox)
      elseif col == 2 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh2, groupbox)
      elseif col == 3 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh3, groupbox)
      else
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh4, groupbox)
      end
      add_exchange_item_info(form, index, col, groupbox_sub, id, item_id, exchange_type, item_desc, false)
    end
  end
  form.groupscrollbox_1.IsEditMode = false
  form.groupscrollbox_1:ResetChildrenYPos()
end
function show_exchange_item_dialog(index)
  local form = util_show_form(nx_string(FORM_EXCHANGE_MALL), true)
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute(nx_string(FORM_EXCHANGE_MALL), "show_exchange_item_info", form, index)
end
function open_mall(form_path, mall_type)
  local mallform = nx_value(FORM_ATTRIBUTE_MALL)
  if not nx_is_valid(mallform) then
    mallform = nx_execute("util_gui", "util_get_form", FORM_ATTRIBUTE_MALL, true, false)
    if not nx_is_valid(mallform) then
      return
    end
    mallform:Show()
  elseif mallform.Visible == true then
    mallform.Visible = false
    mallform:Close()
    return
  end
  show_exchange_info(mallform, 1)
end
function open_mall_by_group(form, mall_type)
  if not nx_is_valid(form) then
    return
  end
  show_exchange_info(form, mall_type)
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
function get_item_info(configid, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
