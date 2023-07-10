require("tips_data")
require("tips_game")
require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
local FORM_ATTRIBUTE_MALL_TG = "form_stage_main\\form_attribute_mall\\form_attribute_shop_tiguan"
local FORM_EXCHANGE_MALL = "form_stage_main\\form_attribute_mall\\form_attribute_exchange"
local count_no_99 = 13
function on_main_form_init(form)
  form.Fixed = true
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.main_index = 0
  auto_rbtn(form)
  form.rbtn_main_1.Checked = true
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("TGChallengeValue", "int", form, FORM_ATTRIBUTE_MALL_TG, "on_TGChallengeValue_changed")
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("TGChallengeValue", form)
  end
  nx_destroy(form)
end
function open_form()
  local form = util_get_form(FORM_ATTRIBUTE_MALL_TG, true)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
end
function close_form()
  local form = util_get_form(FORM_ATTRIBUTE_MALL_TG, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_rbtn_main_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local main_index = nx_int(rbtn.DataSource)
    form.main_index = main_index
    form.rbtn_sub_1.Checked = true
  end
end
function on_rbtn_sub_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local sub_index = nx_int(rbtn.DataSource)
    local real_index = nx_int(form.main_index) + nx_int(sub_index)
    show_exchange_info(form, real_index)
    nx_execute("custom_sender", "custom_attr_mall", 1, nx_int(real_index))
  end
end
function auto_rbtn(form)
  local count = nx_number(form.gsb_1.DataSource)
  local switch_manager = nx_value("SwitchManager")
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_TIGUAN_SHOP99) then
    count = count_no_99
  end
  for i = 1, count do
    local rbtn = create_ctrl("RadioButton", "rbtn_sub_" .. nx_string(i), form.rbtn_mod, form.gsb_1)
    rbtn.Left = form.rbtn_mod.Left
    rbtn.Top = form.rbtn_mod.Top + 32 * (i - 1)
    rbtn.DataSource = nx_string(nx_number(form.rbtn_mod.DataSource) + i - 1)
    rbtn.Text = nx_widestr(util_text("ui_shop_tg_sub_" .. nx_string(i)))
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_checked_changed", "on_rbtn_sub_checked_changed")
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1.Height = form.gsb_1.Height
  form.rbtn_mod.Visible = false
end
function on_TGChallengeValue_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("TGChallengeValue")
  if nx_number(value) < 0 then
    value = 0
  end
  local max_value = get_ini_prop_maxvalue("TGChallengeValue")
  form.lbl_weekCount.Text = nx_widestr(value) .. nx_widestr("/") .. nx_widestr(max_value)
end
function get_ini_prop_maxvalue(prop)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\common_inc_prop_value\\PropIncEffect.ini")
  if not nx_is_valid(ini) then
    return
  end
  if not ini:FindSection(nx_string(prop)) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(prop))
  if sec_index < 0 then
    return
  end
  return ini:ReadInteger(sec_index, "max_value", 0)
end
function on_cbtn_tmp_back1_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  cbtn.Checked = false
  show_exchange_item_dialog(cbtn.index)
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
function add_exchange_item_info(form, index, col, groupbox_sub, id, item_id, limit_desc, item_desc, condition_desc, is_valid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  groupbox_sub.id = id
  local lbl_1 = create_ctrl("Label", "lbl_1_" .. nx_string(index), form.lbl_1, groupbox_sub)
  local cbtn_back = create_ctrl("CheckButton", "cbtn_exchange_back_" .. nx_string(index), form.cbtn_tmp_back1, groupbox_sub)
  local imagegrid = create_ctrl("ImageGrid", "imagegrid_exchange_" .. nx_string(index), form.imagegrid_eh1, groupbox_sub)
  local mltbox_exchange = create_ctrl("MultiTextBox", "mltbox_exchange_" .. nx_string(index), form.mltbox_exchange, groupbox_sub)
  local mltbox_name = create_ctrl("MultiTextBox", "mltbox_tmp_name_" .. nx_string(index), form.mltbox_tmp_name1, groupbox_sub)
  local mltbox_desc = create_ctrl("MultiTextBox", "mltbox_tmp_desc_" .. nx_string(index), form.mltbox_tmp_desc1, groupbox_sub)
  local mltbox_desc2 = create_ctrl("MultiTextBox", "mltbox_tmp_desc2_" .. nx_string(index), form.mltbox_tmp_desc2, groupbox_sub)
  local lbl_2 = create_ctrl("Label", "lbl_2_" .. nx_string(index), form.lbl_2, groupbox_sub)
  local lbl_3 = create_ctrl("Label", "lbl_3_" .. nx_string(index), form.lbl_3, groupbox_sub)
  local lbl_4 = create_ctrl("Label", "lbl_4_" .. nx_string(index), form.lbl_4, groupbox_sub)
  nx_bind_script(cbtn_back, nx_current())
  nx_callback(cbtn_back, "on_click", "on_cbtn_tmp_back1_click")
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  imagegrid:AddItem(0, photo, "", 1, -1)
  imagegrid.RowNum = 1
  imagegrid.ClomnNum = 1
  imagegrid.GridWidth = imagegrid.Width - 10
  imagegrid.GridHeight = imagegrid.Height - 10
  imagegrid.DrawMode = "Expand"
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_eh_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_eh_mouseout_grid")
  imagegrid.item_id = item_id
  imagegrid.index = nx_int(id)
  if not is_valid then
    cbtn_back.Enabled = false
    imagegrid:ChangeItemImageToBW(0, true)
    groupbox_sub.BackImage = "gui\\guild\\guild_battle\\kuang_forbid.png"
    mltbox_name.TextColor = "255,80,80,80"
    mltbox_desc.TextColor = "255,80,80,80"
    mltbox_desc2.TextColor = "255,80,80,80"
    mltbox_exchange.TextColor = "255,80,80,80"
    lbl_2.ForeColor = "255,80,80,80"
    lbl_3.ForeColor = "255,80,80,80"
    lbl_4.ForeColor = "255,80,80,80"
  else
    nx_callback(imagegrid, "on_select_changed", "on_imagegrid_eh_select_changed")
  end
  mltbox_name:Clear()
  mltbox_name.Transparent = true
  mltbox_name:AddHtmlText(gui.TextManager:GetText(nx_string(item_id)), -1)
  local posx = (mltbox_name.Width - mltbox_name:GetContentWidth()) / 2
  mltbox_name.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
  mltbox_desc:Clear()
  mltbox_desc.Transparent = true
  mltbox_desc:AddHtmlText(limit_desc, -1)
  posx = (mltbox_desc.Width - mltbox_desc:GetContentWidth()) / 2
  mltbox_desc.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
  mltbox_desc2:Clear()
  mltbox_desc2.Transparent = true
  mltbox_desc2:AddHtmlText(condition_desc, -1)
  posx = (mltbox_desc2.Width - mltbox_desc2:GetContentWidth()) / 2
  mltbox_desc2.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
  mltbox_exchange:Clear()
  mltbox_exchange.Transparent = true
  mltbox_exchange:AddHtmlText(item_desc, -1)
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
  local attribute_mall_manager = nx_value("AttributeMallManager")
  if not nx_is_valid(attribute_mall_manager) then
    return
  end
  local tab_info = attribute_mall_manager:GetMallInfo(category)
  local item_count = nx_number(tab_info[1])
  for i = 1, item_count do
    local id = tab_info[(i - 1) * 13 + 2]
    local exchange_category = tab_info[(i - 1) * 13 + 3]
    local item_id = tab_info[(i - 1) * 13 + 4]
    local cost_type = tab_info[(i - 1) * 13 + 5]
    local item_desc = tab_info[(i - 1) * 13 + 6]
    local cost_attr = tab_info[(i - 1) * 13 + 7]
    local cost_id = tab_info[(i - 1) * 13 + 8]
    local cost_num = tab_info[(i - 1) * 13 + 9]
    local condition_id = tab_info[(i - 1) * 13 + 10]
    local step = tab_info[(i - 1) * 13 + 11]
    local limit_num = tab_info[(i - 1) * 13 + 12]
    local date_type = tab_info[(i - 1) * 13 + 13]
    if nx_number(category) == nx_number(exchange_category) and nx_int(step) <= nx_int(cur_main_game_step) then
      local item_desc = util_text(item_desc)
      if nx_widestr(item_desc) == nx_widestr("") then
        if nx_number(cost_type) == 1 then
          item_desc = util_format_string("ui_mall_item_desc_1", cost_attr, nx_number(cost_num))
        elseif nx_number(cost_type) == 2 then
          item_desc = util_format_string("ui_mall_item_desc_2", nx_number(cost_num))
        elseif nx_number(cost_type) == 3 then
          item_desc = util_format_string("ui_mall_item_desc_3", cost_id, nx_number(cost_num))
        elseif nx_number(cost_type) == 4 then
          item_desc = util_format_string("ui_mall_item_desc_4")
        end
      end
      local limit_desc = util_text("ui_mall_limit_0")
      if 0 < nx_number(limit_num) and 0 < nx_number(date_type) then
        limit_desc = util_format_string("ui_mall_limit2_" .. nx_string(date_type), nx_number(limit_num), nx_number(limit_num))
      end
      local condition_desc = util_text("ui_mall_condition_0")
      if 0 < nx_number(condition_id) then
        condition_desc = util_text("desc_condition_" .. nx_string(condition_id))
      end
      index = index + 1
      local col = index % 3
      local groupbox_sub
      if col == 1 then
        groupbox = create_ctrl("GroupBox", "gbox_exchange_" .. nx_string(index), form.groupbox_template, form.groupscrollbox_1)
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh1, groupbox)
      elseif col == 2 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh2, groupbox)
      else
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh3, groupbox)
      end
      groupbox_sub.limit_num = limit_num
      groupbox_sub.date_type = date_type
      add_exchange_item_info(form, index, col, groupbox_sub, id, item_id, limit_desc, item_desc, condition_desc, true)
    end
  end
  for i = 1, item_count do
    local id = tab_info[(i - 1) * 13 + 2]
    local exchange_category = tab_info[(i - 1) * 13 + 3]
    local item_id = tab_info[(i - 1) * 13 + 4]
    local cost_type = tab_info[(i - 1) * 13 + 5]
    local item_desc = tab_info[(i - 1) * 13 + 6]
    local cost_attr = tab_info[(i - 1) * 13 + 7]
    local cost_id = tab_info[(i - 1) * 13 + 8]
    local cost_num = tab_info[(i - 1) * 13 + 9]
    local condition_id = tab_info[(i - 1) * 13 + 10]
    local step = tab_info[(i - 1) * 13 + 11]
    local limit_num = tab_info[(i - 1) * 13 + 12]
    local date_type = tab_info[(i - 1) * 13 + 13]
    if nx_number(category) == nx_number(exchange_category) and nx_int(step) > nx_int(cur_main_game_step) then
      local item_desc = util_text(item_desc)
      if nx_widestr(item_desc) == nx_widestr("") then
        if nx_number(cost_type) == 1 then
          item_desc = util_format_string("ui_mall_item_desc_1", cost_attr, nx_number(cost_num))
        elseif nx_number(cost_type) == 2 then
          item_desc = util_format_string("ui_mall_item_desc_2", nx_number(cost_num))
        elseif nx_number(cost_type) == 3 then
          item_desc = util_format_string("ui_mall_item_desc_3", cost_id, nx_number(cost_num))
        elseif nx_number(cost_type) == 4 then
          item_desc = util_format_string("ui_mall_item_desc_4")
        end
      end
      local limit_desc = util_text("ui_mall_limit_0")
      if 0 < nx_number(limit_num) and 0 < nx_number(date_type) then
        limit_desc = util_format_string("ui_mall_limit2_" .. nx_string(date_type), nx_number(limit_num), nx_number(limit_num))
      end
      local condition_desc = util_text("ui_mall_condition_0")
      if 0 < nx_number(condition_id) then
        condition_desc = util_text("desc_condition_" .. nx_string(condition_id))
      end
      index = index + 1
      local col = index % 3
      local groupbox_sub
      if col == 1 then
        groupbox = create_ctrl("GroupBox", "gbox_exchange_" .. nx_string(index), form.groupbox_template, form.groupscrollbox_1)
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh1, groupbox)
      elseif col == 2 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh2, groupbox)
      else
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh3, groupbox)
      end
      groupbox_sub.limit_num = limit_num
      groupbox_sub.date_type = date_type
      add_exchange_item_info(form, index, col, groupbox_sub, id, item_id, limit_desc, item_desc, condition_desc, false)
    end
  end
  form.groupscrollbox_1.IsEditMode = false
  form.groupscrollbox_1:ResetChildrenYPos()
end
function show_exchange_item_dialog(index)
  nx_execute(FORM_EXCHANGE_MALL, "close_form")
  local form = util_show_form(nx_string(FORM_EXCHANGE_MALL), true)
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute(nx_string(FORM_EXCHANGE_MALL), "show_exchange_item_info", form, index)
end
function on_update_type(...)
  local type = nx_number(arg[1])
  local item_count = nx_number(arg[2])
  for i = 1, item_count do
    local index = nx_number(arg[3 + (i - 1) * 2])
    local cur_count = nx_number(arg[4 + (i - 1) * 2])
    update_control_info(index, cur_count)
  end
end
function on_update_item(...)
  local index = nx_number(arg[1])
  local cur_count = nx_number(arg[2])
  update_control_info(index, cur_count)
end
function update_control_info(index, count)
  local form = util_get_form(FORM_ATTRIBUTE_MALL_TG, false, false)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 1000 do
    local row_control = form.groupscrollbox_1:Find("gbox_exchange_" .. nx_string(math.floor((i - 1) / 3) * 3 + 1))
    if not nx_is_valid(row_control) then
      return
    end
    local col_index = i
    local col_control = row_control:Find("gbox_exchange_sub_" .. nx_string(col_index))
    if nx_is_valid(col_control) and nx_number(col_control.id) == nx_number(index) then
      local mltbox_desc = col_control:Find("mltbox_tmp_desc_" .. nx_string(col_index))
      if nx_is_valid(mltbox_desc) then
        local exchange_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\AttributeMall\\AttributeMall.ini")
        if not nx_is_valid(exchange_ini) then
          return false
        end
        local limit_num = col_control.limit_num
        local date_type = col_control.date_type
        local limit_desc = util_text("ui_mall_limit_0")
        if nx_number(limit_num) > 0 and nx_number(date_type) > 0 then
          if count >= nx_number(limit_num) then
            limit_desc = util_format_string("ui_mall_limit_" .. nx_string(date_type), nx_number(limit_num) - count, nx_number(limit_num))
          else
            limit_desc = util_format_string("ui_mall_limit2_" .. nx_string(date_type), nx_number(limit_num) - count, nx_number(limit_num))
          end
        end
        mltbox_desc:Clear()
        mltbox_desc.Transparent = true
        mltbox_desc:AddHtmlText(nx_widestr(limit_desc), -1)
        local posx = (mltbox_desc.Width - mltbox_desc:GetContentWidth()) / 2
        mltbox_desc.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
      end
    end
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
function a(info)
  nx_msgbox(nx_string(info))
end
