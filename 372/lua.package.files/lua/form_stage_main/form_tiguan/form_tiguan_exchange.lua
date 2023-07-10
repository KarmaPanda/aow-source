require("util_functions")
require("share\\client_custom_define")
require("util_gui")
require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("share\\view_define")
require("util_static_data")
require("define\\sysinfo_define")
require("tips_data")
function on_main_form_init(form)
  form.Fixed = false
  form.cur_gbox_count = 0
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
  form.guan_exchange_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_EXCHANGE_INI)
  if not nx_is_valid(form.guan_exchange_ini) then
    return 0
  end
  form.tool_item_ini = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  if not nx_is_valid(form.tool_item_ini) then
    return 0
  end
  form.aotu_change1 = form.Height
  form.aotu_change2 = form.groupscrollbox_1.Height
  form.aotu_change3 = form.lbl_2.Top
  form.aotu_change4 = form.btn_exchange1.Top
  form.aotu_change5 = form.fipt_1.Top
  form.aotu_change6 = form.lbl_3.Top
  form.aotu_change7 = form.btn_exchange2.Top
  form.aotu_change8 = form.btn_exchange3.Top
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
function show_exchange_item_info(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local exchange_ini = form.guan_exchange_ini
  if not nx_is_valid(exchange_ini) then
    return 0
  end
  local tool_item_ini = form.tool_item_ini
  if not nx_is_valid(tool_item_ini) then
    return 0
  end
  local share_exchange_ini = nx_execute("util_functions", "get_ini", "share\\War\\tiguan_danshua_exchange.ini")
  form.groupscrollbox_1:DeleteAll()
  local section_count = exchange_ini:GetSectionCount()
  if index > section_count then
    return 0
  end
  local SectionName = exchange_ini:GetSectionByIndex(index)
  local sub_item_id = exchange_ini:ReadString(index, "SubItemID", "")
  local item_list = util_split_string(nx_string(sub_item_id), ",")
  local item_count = table.getn(item_list)
  local exchange_type = exchange_ini:ReadInteger(index, "ExchangeType", 0)
  local count_type = exchange_ini:ReadInteger(index, "CountType", 0)
  local sub_item_desc = exchange_ini:ReadString(index, "SubItemDesc", "")
  local sub_desc_list = util_split_string(nx_string(sub_item_desc), ",")
  local desc_count = table.getn(sub_desc_list)
  local item_index = exchange_ini:ReadString(index, "Index", "")
  local item_index_list = util_split_string(nx_string(item_index), ",")
  local item_index_count = table.getn(item_index_list)
  if item_count ~= item_index_count then
    return
  end
  for i = 1, item_count do
    local groupbox = create_ctrl("GroupBox", "gbox_exchange_" .. nx_string(i), form.groupbox_template, form.groupscrollbox_1)
    local cbtn_select_other = create_ctrl("CheckButton", "cbtn_exchange_select_other_" .. nx_string(i), form.cbtn_1, groupbox)
    local cbtn_select = create_ctrl("CheckButton", "cbtn_exchange_select_" .. nx_string(i), form.cbtn_tmp_select, groupbox)
    local lbl_name = create_ctrl("Label", "lbl_exchange_name_" .. nx_string(i), form.lbl_tmp_name, groupbox)
    local imagegrid = create_ctrl("ImageGrid", "imagegrid_tmp_pic_" .. nx_string(i), form.imagegrid_tmp_pic, groupbox)
    local lbl_score = create_ctrl("Label", "lbl_exchange_score_" .. nx_string(i), form.lbl_tmp_score, groupbox)
    cbtn_select.sort_id = i
    cbtn_select.item_index = nx_int(item_index_list[i])
    nx_bind_script(cbtn_select, nx_current())
    nx_callback(cbtn_select, "on_click", "on_cbtn_select_click")
    local photo = get_item_info(item_list[i], "photo")
    imagegrid:AddItem(0, photo, "", 1, -1)
    imagegrid.RowNum = 1
    imagegrid.ClomnNum = 1
    imagegrid.GridWidth = imagegrid.Width - 10
    imagegrid.GridHeight = imagegrid.Height - 10
    imagegrid.DrawMode = "Expand"
    imagegrid.item_id = item_list[i]
    nx_bind_script(imagegrid, nx_current())
    nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_eh_mousein_grid")
    nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_eh_mouseout_grid")
    lbl_name.Text = gui.TextManager:GetText(nx_string(item_list[i]))
    if sub_desc_list[i] ~= nil then
      lbl_score.Text = gui.TextManager:GetText(nx_string(sub_desc_list[i]))
    end
    local bind_index = share_exchange_ini:FindSectionIndex(nx_string(item_index_list[i]))
    if 0 <= bind_index then
      local bind_type = share_exchange_ini:ReadInteger(bind_index, "Bind", 0)
      if 0 < bind_type then
        local lbl_bind = create_ctrl("Label", "lbl_exchange_bind_" .. nx_string(i), form.lbl_tmp_bind, groupbox)
        if count_type == 3 then
          lbl_bind.Text = gui.TextManager:GetText("ui_takefree")
        end
      end
    end
    if i == 1 then
      cbtn_select.Checked = true
      cbtn_select_other.Checked = true
    end
  end
  if 0 < item_count then
    local h = form.groupbox_template.Height
    form.Height = form.aotu_change1 + h * nx_number(item_count)
    form.groupscrollbox_1.Height = form.aotu_change2 + h * nx_number(item_count)
    form.lbl_2.Top = form.aotu_change3 + h * nx_number(item_count)
    form.btn_exchange1.Top = form.aotu_change4 + h * nx_number(item_count)
    form.fipt_1.Top = form.aotu_change5 + h * nx_number(item_count)
    form.lbl_3.Top = form.aotu_change6 + h * nx_number(item_count)
    form.btn_exchange2.Top = form.aotu_change7 + h * nx_number(item_count)
    form.btn_exchange3.Top = form.aotu_change8 + h * nx_number(item_count)
  end
  if count_type == 1 then
    form.btn_exchange1.Visible = false
    form.btn_exchange3.Visible = false
    form.fipt_1.Visible = true
    form.lbl_3.Visible = true
    form.btn_exchange2.Visible = true
    form.lbl_1.Text = gui.TextManager:GetText("ui_wupingduihuan")
  elseif count_type == 2 then
    form.btn_exchange1.Visible = true
    form.btn_exchange3.Visible = false
    form.fipt_1.Visible = false
    form.lbl_3.Visible = false
    form.btn_exchange2.Visible = false
    form.lbl_1.Text = gui.TextManager:GetText("ui_wupingduihuan")
  else
    form.btn_exchange1.Visible = false
    form.btn_exchange3.Visible = true
    form.fipt_1.Visible = false
    form.lbl_3.Visible = false
    form.btn_exchange2.Visible = false
    form.lbl_1.Text = gui.TextManager:GetText("ui_duihua_wuping")
  end
  form.cur_gbox_count = item_count
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
function exchage_item(form, count)
  local itemIndex = -1
  local selectItem = -1
  for i = 1, form.cur_gbox_count do
    local gbox = form.groupscrollbox_1:Find("gbox_exchange_" .. nx_string(i))
    if nx_is_valid(gbox) then
      local cbtn_select = gbox:Find("cbtn_exchange_select_" .. nx_string(i))
      if nx_is_valid(cbtn_select) and cbtn_select.Checked then
        itemIndex = cbtn_select.item_index
        selectItem = cbtn_select.sort_id
      end
    end
  end
  if selectItem == -1 or itemIndex == -1 then
    local text = get_desc_by_id("ui_cannotexchange")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
  else
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_EXCHANGE, nx_int(itemIndex), nx_int(count))
    local flick = get_flick_item_index()
    if nx_number(flick) == nx_number(itemIndex) then
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_EXCHANGE_QUERY, flick)
    end
    form:Close()
  end
end
function on_btn_exchange1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  exchage_item(form, 1)
end
function on_btn_exchange2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local exchange_count = nx_number(form.fipt_1.Text)
  if exchange_count <= 0 then
    local text = get_desc_by_id("ui_tiguan_count_not_enough")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  exchage_item(form, nx_int(exchange_count))
end
function on_btn_exchange3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  exchage_item(form, 1)
end
function get_desc_by_id(text_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  return gui.TextManager:GetText(nx_string(text_id))
end
function get_flick_item_index()
  local tiguan_one_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(tiguan_one_ini) then
    return -1
  end
  local keep_index = tiguan_one_ini:FindSectionIndex("expand_node")
  local flicker = tiguan_one_ini:ReadInteger(keep_index, "flicker", -1)
  return flicker
end
