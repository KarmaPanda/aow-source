require("tips_data")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_attribute_mall\\form_attribute_shop")
CLIENT_CUSTOMMSG_ATTRIBUTE_MALL = 187
SUB_MALL_EXCHANGE = 0
function on_main_form_init(form)
  form.Fixed = false
  form.cut_exchange_index = -1
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.exchange_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\AttributeMall\\AttributeMall.ini")
  if not nx_is_valid(form.exchange_ini) then
    return 0
  end
  form.aotu_change1 = form.Height
  form.aotu_change2 = form.groupscrollbox_1.Height
  form.aotu_change3 = form.lbl_2.Top
  form.aotu_change4 = form.btn_exchange1.Top
  form.aotu_change5 = form.fipt_1.Top
  form.aotu_change6 = form.lbl_3.Top
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function close_form()
  local form = util_get_form("form_stage_main\\form_attribute_mall\\form_attribute_exchange", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_exchange1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local count = nx_int(form.fipt_1.Text)
  if count > nx_int(0) then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ATTRIBUTE_MALL), nx_int(SUB_MALL_EXCHANGE), nx_int(form.cut_exchange_index), count)
  end
  form:Close()
end
function show_exchange_item_info(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local exchange_ini = form.exchange_ini
  if not nx_is_valid(exchange_ini) then
    return 0
  end
  form.groupscrollbox_1:DeleteAll()
  local sec_index = exchange_ini:FindSectionIndex(nx_string(index))
  if sec_index < 0 then
    return ""
  end
  local SectionName = exchange_ini:GetSectionByIndex(sec_index)
  local item_id = exchange_ini:ReadString(sec_index, "ItemID", "")
  local exchange_type = exchange_ini:ReadInteger(sec_index, "ExchangeType", 0)
  local count_type = exchange_ini:ReadInteger(sec_index, "CountType", 0)
  local item_desc = exchange_ini:ReadString(sec_index, "ItemDesc", "")
  local bind_type = exchange_ini:ReadInteger(sec_index, "Bind", 0)
  local cost_type = exchange_ini:ReadString(sec_index, "CostType", "")
  local cost_attr = exchange_ini:ReadString(sec_index, "CostAttr", "")
  local cost_id = exchange_ini:ReadString(sec_index, "CostID", "")
  local cost_num = exchange_ini:ReadString(sec_index, "CostNum", "")
  local groupbox = create_ctrl("GroupBox", "gbox_exchange_1", form.groupbox_template, form.groupscrollbox_1)
  local cbtn_select_other = create_ctrl("CheckButton", "cbtn_exchange_select_other_1", form.cbtn_1, groupbox)
  local cbtn_select = create_ctrl("CheckButton", "cbtn_exchange_select_1", form.cbtn_tmp_select, groupbox)
  local lbl_name = create_ctrl("Label", "lbl_exchange_name_1", form.lbl_tmp_name, groupbox)
  local imagegrid = create_ctrl("ImageGrid", "imagegrid_tmp_pic_1", form.imagegrid_tmp_pic, groupbox)
  local mltbox_score = create_ctrl("MultiTextBox", "lbl_exchange_score_1", form.lbl_tmp_score, groupbox)
  form.cut_exchange_index = nx_int(SectionName)
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  imagegrid:AddItem(0, photo, "", 1, -1)
  imagegrid.RowNum = 1
  imagegrid.ClomnNum = 1
  imagegrid.GridWidth = imagegrid.Width - 10
  imagegrid.GridHeight = imagegrid.Height - 10
  imagegrid.DrawMode = "Expand"
  imagegrid.item_id = item_id
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_eh_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_eh_mouseout_grid")
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
  lbl_name.Text = gui.TextManager:GetText(nx_string(item_id))
  mltbox_score:Clear()
  mltbox_score.Transparent = true
  mltbox_score:AddHtmlText(item_desc, -1)
  if 0 < bind_type then
    local lbl_bind = create_ctrl("Label", "lbl_exchange_bind_" .. nx_string(i), form.lbl_tmp_bind, groupbox)
    if count_type == 3 then
      lbl_bind.Text = gui.TextManager:GetText("ui_takefree")
    end
  end
  cbtn_select.Checked = true
  cbtn_select_other.Checked = true
  local h = form.groupbox_template.Height
  local item_count = 1
  form.Height = form.aotu_change1 + h * nx_number(item_count)
  form.groupscrollbox_1.Height = form.aotu_change2 + h * nx_number(item_count)
  form.lbl_2.Top = form.aotu_change3 + h * nx_number(item_count)
  form.btn_exchange1.Top = form.aotu_change4 + h * nx_number(item_count)
  form.fipt_1.Top = form.aotu_change5 + h * nx_number(item_count)
  form.lbl_3.Top = form.aotu_change6 + h * nx_number(item_count)
  if count_type == 1 then
    form.btn_exchange1.Visible = true
    form.fipt_1.Visible = true
    form.lbl_3.Visible = true
    form.lbl_1.Text = gui.TextManager:GetText("ui_wupingduihuan")
  elseif count_type == 2 then
    form.btn_exchange1.Visible = true
    form.fipt_1.Visible = false
    form.lbl_3.Visible = false
    form.lbl_1.Text = gui.TextManager:GetText("ui_wupingduihuan")
  else
    form.btn_exchange1.Visible = true
    form.fipt_1.Visible = false
    form.lbl_3.Visible = false
    form.lbl_1.Text = gui.TextManager:GetText("ui_duihua_wuping")
  end
  form.cut_exchange_index = index
  form.groupscrollbox_1:ResetChildrenYPos()
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
function on_cbtn_select_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  for i = 1, form.cur_gbox_count do
    local gbox = form.groupscrollbox_1:Find("gbox_exchange_" .. nx_string(i))
    if nx_is_valid(gbox) then
      local cbtn_select = gbox:Find("cbtn_exchange_select_" .. nx_string(i))
      if nx_is_valid(cbtn_select) and cbtn.sort_id ~= cbtn_select.sort_id then
        cbtn_select.Checked = false
      else
        cbtn_select.Checked = true
      end
      local cbtn_exchange_select_other = gbox:Find("cbtn_exchange_select_other_" .. nx_string(i))
      if nx_is_valid(cbtn_exchange_select_other) then
        cbtn_exchange_select_other.Checked = cbtn_select.Checked
      end
    end
  end
end
function get_desc_by_id(text_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  return gui.TextManager:GetText(nx_string(text_id))
end
