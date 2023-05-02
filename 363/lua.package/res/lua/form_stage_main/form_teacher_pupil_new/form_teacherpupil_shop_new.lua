require("tips_data")
require("tips_game")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_teacher_pupil_new\\teacherpupil_define_new")
require("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_func_new")
function on_main_form_init(form)
  form.Fixed = true
  form.jyz_step = 0
end
function on_main_form_open(form)
  local shitu_value = get_shitu_value()
  form.lbl_value.Text = nx_widestr(shitu_value)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("NewShiTuValue", "int", form, nx_current(), "on_shitu_value_changed")
  end
  nx_execute("custom_sender", CUSTOM_MSG_FUN, NT_CTS_GAME_STEP)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("NewShiTuValue", form)
  end
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
  nx_execute(FORM_MSG_NEW, "show_main_page")
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
  local exchange_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\shitu\\shitu_shop.ini")
  if not nx_is_valid(exchange_ini) then
    return 0
  end
  form.groupscrollbox_1.IsEditMode = true
  form.groupscrollbox_1:DeleteAll()
  local section_count = exchange_ini:GetSectionCount()
  local groupbox
  local grid_index = 0
  for index = 0, section_count - 1 do
    local id = exchange_ini:GetSectionByIndex(index)
    local exchange_category = exchange_ini:ReadInteger(index, "Category", 0)
    local item_id = exchange_ini:ReadString(index, "ItemID", "")
    local exchange_type = exchange_ini:ReadString(index, "ExchangeType", "")
    local item_desc = exchange_ini:ReadString(index, "ItemDesc", "")
    local condition_id = exchange_ini:ReadInteger(index, "ConditionID", 0)
    local step = exchange_ini:ReadInteger(index, "JyzStep", 0)
    if nx_number(category) == nx_number(exchange_category) and nx_int(step) <= nx_int(form.jyz_step) then
      local row_index = nx_int(grid_index / 4)
      local col = grid_index % 4
      grid_index = grid_index + 1
      local groupbox_sub
      if col == 0 then
        groupbox = create_ctrl("GroupBox", "gbox_exchange_" .. nx_string(row_index), form.groupbox_template, form.groupscrollbox_1)
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh1, groupbox)
      elseif col == 1 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh2, groupbox)
      elseif col == 2 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh3, groupbox)
      else
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh4, groupbox)
      end
      add_exchange_item_info(form, index, col, groupbox_sub, id, item_id, exchange_type, item_desc, true)
    end
  end
  for index = 0, section_count - 1 do
    local id = exchange_ini:GetSectionByIndex(index)
    local exchange_category = exchange_ini:ReadInteger(index, "Category", 0)
    local item_id = exchange_ini:ReadString(index, "ItemID", "")
    local exchange_type = exchange_ini:ReadString(index, "ExchangeType", "")
    local item_desc = exchange_ini:ReadString(index, "ItemDesc", "")
    local condition_id = exchange_ini:ReadInteger(index, "ConditionID", 0)
    local step = exchange_ini:ReadInteger(index, "JyzStep", 0)
    if nx_number(category) == nx_number(exchange_category) and nx_int(step) > nx_int(form.jyz_step) then
      local row_index = nx_int(grid_index / 4)
      local col = grid_index % 4
      grid_index = grid_index + 1
      local groupbox_sub
      if col == 0 then
        groupbox = create_ctrl("GroupBox", "gbox_exchange_" .. nx_string(row_index), form.groupbox_template, form.groupscrollbox_1)
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh1, groupbox)
      elseif col == 1 then
        groupbox_sub = create_ctrl("GroupBox", "gbox_exchange_sub_" .. nx_string(index), form.groupbox_template_eh2, groupbox)
      elseif col == 2 then
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
  local form = util_show_form(nx_string(FORM_EXCHANGE_NEW), true)
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute(nx_string(FORM_EXCHANGE_NEW), "show_exchange_item_info", form, index)
end
function on_shitu_value_changed(form)
  if not nx_is_valid(form) then
    return
  end
  local shitu_value = get_shitu_value()
  form.lbl_value.Text = nx_widestr(shitu_value)
end
function update_control_info(index, count)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = nx_value(FORM_SHOP_NEW)
  if not nx_is_valid(form) then
    return 0
  end
  for i = 0, 1000 do
    local row_control = form.groupscrollbox_1:Find("gbox_exchange_" .. nx_string(i))
    if not nx_is_valid(row_control) then
      return 0
    end
    local col_index = index
    local col_control = row_control:Find("gbox_exchange_sub_" .. nx_string(col_index))
    if nx_is_valid(col_control) then
      local mltbox_desc = col_control:Find("mltbox_tmp_desc_" .. nx_string(col_index))
      if nx_is_valid(mltbox_desc) then
        local exchange_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\shitu\\shitu_shop.ini")
        if not nx_is_valid(exchange_ini) then
          return false
        end
        local count_type = exchange_ini:ReadInteger(index, "CountType", 0)
        if count_type ~= 1 then
          return false
        end
        local exchange_type = exchange_ini:ReadString(index, "ExchangeType", "")
        if "" == exchange_type then
          return false
        end
        gui.TextManager:Format_SetIDName(exchange_type)
        gui.TextManager:Format_AddParam(count)
        local text = gui.TextManager:Format_GetText()
        mltbox_desc:Clear()
        mltbox_desc.Transparent = true
        mltbox_desc:AddHtmlText(nx_widestr(text), -1)
        local posx = (mltbox_desc.Width - mltbox_desc:GetContentWidth()) / 2
        mltbox_desc.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
      end
    end
  end
  return true
end
function on_server_msg(submsg, ...)
  if nx_int(submsg) == nx_int(NT_STC_RET_GAME_STEP) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    form.jyz_step = nx_int(arg[1])
    show_exchange_info(form, 1)
    nx_execute("custom_sender", CUSTOM_MSG_FUN, NT_CTS_EXCHANGE_COUNT_INFO)
  end
  if nx_int(submsg) == nx_int(NT_STC_RET_EXCHANGE_COUNT_INFO) then
    local total_count = table.getn(arg)
    for index = 0, total_count - 1 do
      local count = nx_int(arg[index + 1])
      update_control_info(index, count)
    end
  end
  if nx_int(submsg) == nx_int(NT_STC_RET_EXCHANGE_UPDATE) then
    local index = nx_int(arg[1])
    local count = nx_int(arg[2])
    update_control_info(index, count)
  end
end
