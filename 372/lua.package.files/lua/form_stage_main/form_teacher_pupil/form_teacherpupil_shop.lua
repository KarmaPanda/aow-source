require("util_functions")
require("util_gui")
require("tips_game")
require("form_stage_main\\form_teacher_pupil\\teacherpupil_define")
require("form_stage_main\\form_teacher_pupil\\form_teacherpupil_func")
require("share\\view_define")
require("util_static_data")
require("define\\sysinfo_define")
require("tips_data")
function on_main_form_init(form)
  form.Fixed = true
  form.jyz_step = 0
end
function on_main_form_open(form)
  local shitu_value = get_shitu_value()
  form.lbl_value.Text = nx_widestr(shitu_value)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("ShiTu_Point", "int", form, nx_current(), "on_shitu_value_changed")
  end
  nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_GAME_STEP)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("ShiTu_Point", form)
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
  local shitu_flag = get_shitu_flag()
  if nx_int(shitu_flag) == nx_int(Junior_fellow_apprentice) then
    show_exchange_info(form, 2)
  elseif nx_int(shitu_flag) == nx_int(Senior_fellow_apprentice) then
    show_exchange_info(form, 3)
  else
    ShowTipDialog(util_text("ui_shitudengji_01"))
  end
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
  nx_execute(FORM_MSG, "show_main_page")
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
  mltbox_name:AddHtmlText(gui.TextManager:GetText(nx_string(item_id)), -1)
  local posx = (mltbox_name.Width - mltbox_name:GetContentWidth()) / 2
  mltbox_name.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
  mltbox_desc:Clear()
  mltbox_desc:AddHtmlText(gui.TextManager:GetText(exchange_type), -1)
  posx = (mltbox_desc.Width - mltbox_desc:GetContentWidth()) / 2
  mltbox_desc.ViewRect = nx_string(nx_int(posx)) .. ",0,150,66"
  mltbox_exchange:Clear()
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
  local index = 0
  local groupbox
  for i = 1, section_count do
    local id = exchange_ini:GetSectionByIndex(i - 1)
    local exchange_category = exchange_ini:ReadInteger(i - 1, "Category", 0)
    local item_id = exchange_ini:ReadString(i - 1, "ItemID", "")
    local exchange_type = exchange_ini:ReadString(i - 1, "ExchangeType", "")
    local item_desc = exchange_ini:ReadString(i - 1, "ItemDesc", "")
    local condition_id = exchange_ini:ReadInteger(i - 1, "ConditionID", 0)
    local step = exchange_ini:ReadInteger(i - 1, "JyzStep", 0)
    if nx_number(category) == nx_number(exchange_category) and nx_int(step) <= nx_int(form.jyz_step) then
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
    if nx_number(category) == nx_number(exchange_category) and nx_int(step) > nx_int(form.jyz_step) then
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
  local form = util_show_form(nx_string(FORM_EXCHANGE), true)
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute(nx_string(FORM_EXCHANGE), "show_exchange_item_info", form, index)
end
function on_shitu_value_changed(form)
  local shitu_value = get_shitu_value()
  form.lbl_value.Text = nx_widestr(shitu_value)
end
function on_server_msg(submsg, ...)
  if nx_int(submsg) == nx_int(TP_STC_GAME_STEP) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    form.jyz_step = nx_int(arg[1])
    show_exchange_info(form, 1)
  end
end
