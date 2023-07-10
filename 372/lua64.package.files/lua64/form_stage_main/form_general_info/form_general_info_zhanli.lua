require("util_gui")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("form_stage_main\\form_general_info\\form_general_info_define")
require("const_define")
require("form_stage_main\\switch\\url_define")
para = 0.4
local FORM_QUERY_FRIEND = "form_stage_main\\form_general_info\\form_invrank_selfriend"
local GRID_ROW = 8
neigong_type = {}
neigong_type_count = {}
neigong_name = {}
neigong_obj = {}
skill_type = {}
skill_type_count = {}
skill_name = {}
skill_learn_count = {}
skill_all_count = {}
function on_main_form_init(form)
  form.Fixed = true
  form.query_type = 0
  form.sel_page = 0
  form.min_page = 0
  form.max_page = 0
end
function on_main_form_open(form)
  send_query_name_msg()
  send_query_data_msg()
  send_query_name_msg_ex()
  form.query_type = 0
  form.sel_page = 0
  form.min_page = 0
  form.max_page = 0
  form.rbtn_neigong.Checked = true
  form.groupbox_template.Visible = false
  form.groupbox_template_1.Visible = false
  hide_groupbox(form)
  form.rbtn_zhanli.Checked = true
  form.groupbox_gaoshou.Visible = false
  get_neigong_info()
  get_skill_info(form)
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    form_invrank_friend = nx_create("form_invrank_friend")
    nx_set_value("form_invrank_friend", form_invrank_friend)
  end
  form_invrank_friend.PlayerNum = 0
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if not nx_is_valid(form_general_info_bisai) then
    return
  end
  if not form_general_info_bisai:FindTitle(nx_int(form.btn_2.DataSource)) then
    form.btn_2.Enabled = false
  else
    form.btn_2.Enabled = true
  end
  if not form_general_info_bisai:FindTitle(nx_int(form.btn_4.DataSource)) then
    form.btn_4.Enabled = false
  else
    form.btn_4.Enabled = true
  end
  if not form_general_info_bisai:FindTitle(nx_int(form.btn_7.DataSource)) then
    form.btn_7.Enabled = false
  else
    form.btn_7.Enabled = true
  end
  if not form_general_info_bisai:FindTitle(nx_int(form.btn_9.DataSource)) then
    form.btn_9.Enabled = false
  else
    form.btn_9.Enabled = true
  end
  if not form_general_info_bisai:FindTitle(nx_int(form.btn_11.DataSource)) then
    form.btn_11.Enabled = false
  else
    form.btn_11.Enabled = true
  end
end
function on_main_form_close(form)
  local form_query_friend = nx_value(FORM_QUERY_FRIEND)
  if nx_is_valid(form_query_friend) then
    nx_destroy(form_query_friend)
  end
  local form_invrank_friend = nx_value("form_invrank_friend")
  if nx_is_valid(form_invrank_friend) then
    nx_destroy(form_invrank_friend)
  end
  local game_timer = nx_value(GAME_TIMER)
  if nx_is_valid(game_timer) then
    game_timer:UnRegister("form_stage_main\\form_general_info\\form_general_info_zhanli", "update_form", form)
  end
  nx_destroy(form)
end
function show_form(form)
  local form_zhanli = nx_value(FORM_ZHANLI)
  if not nx_is_valid(form_zhanli) then
    local form_zhanli = nx_execute("util_gui", "util_get_form", FORM_ZHANLI, true, false)
    if nx_is_valid(form_zhanli) then
      form.groupbox_main:Add(form_zhanli)
      form.groupbox_main:ToBack(form_zhanli)
      form_zhanli.Left = 0
      form_zhanli.Top = 0
    end
  else
    form_zhanli:Show()
    form_zhanli.Visible = true
  end
  if nx_is_valid(form_zhanli) then
    form_zhanli.groupbox_5.Visible = false
  end
  local form_invrank_friend = nx_value("form_invrank_friend")
  if nx_is_valid(form_invrank_friend) then
    form_invrank_friend.PlayerNum = 0
  end
end
function create_info_type_tree(form)
  local gui = nx_value("gui")
  local root = form.tree_info_type:CreateRootNode(nx_widestr("info_type"))
  root.Expand = true
  if not nx_is_valid(root) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\general_info\\general_info.ini")
  if not nx_is_valid(ini) then
    return
  end
  local select_node
  form.tree_info_type.node_1 = root:CreateNode(nx_widestr(""))
  set_main_node_style(form.tree_info_type.node_1)
  form.tree_info_type.node_1.Expand = true
  for i = 0, ini:GetSectionCount() - 1 do
    local section = ini:GetSectionByIndex(i)
    local title = ini:ReadString(i, "title", "")
    local type = ini:ReadString(i, "type", 0)
    local showtype = ini:ReadInteger(i, "showtype", 0)
    local rowinfo = ini:ReadString(i, "rowinfo", "")
    local image1 = ini:ReadString(i, "image1", "")
    local image2 = ini:ReadString(i, "image2", "")
    local text = ini:ReadString(i, "text", "")
    local desc = ini:ReadString(i, "desc", "")
    local tips = ini:ReadString(i, "tips", "")
    local node_name = "node_" .. type
    if nx_find_custom(form.tree_info_type, node_name) then
      local node = nx_custom(form.tree_info_type, node_name)
      if nx_is_valid(node) then
        local sub_node = node:CreateNode(gui.TextManager:GetText(title))
        set_sub_node_style(sub_node)
        sub_node.showtype = showtype
        sub_node.name = section
        sub_node.type = type
        if rowinfo ~= "" then
          sub_node.rowinfo = rowinfo
        end
        if section == "All" then
          select_node = sub_node
        end
        if image1 ~= "" then
          sub_node.image1 = image1
          sub_node.image2 = image2
          sub_node.text = text
          sub_node.desc = desc
          sub_node.tips = tips
        end
      end
    end
  end
  if nx_is_valid(select_node) then
    form.tree_info_type.SelectNode = select_node
  end
end
function set_main_node_style(node)
  node.Font = "font_btn"
  node.TextOffsetY = 4
  node.ItemHeight = 38
  node.NodeBackImage = "gui\\language\\ChineseS\\tianti\\btn_zhanli.png"
  node.NodeFocusImage = "gui\\language\\ChineseS\\tianti\\btn_zhanli.png"
  node.NodeSelectImage = "gui\\language\\ChineseS\\tianti\\btn_zhanli.png"
  node.ExpandCloseOffsetX = 133
  node.ExpandCloseOffsetY = 9
  node.NodeOffsetY = 3
end
function set_sub_node_style(node)
  node.Font = "font_text"
  node.NodeImageOffsetX = 30
  node.TextOffsetX = 56
  node.TextOffsetY = 5
  node.ItemHeight = 28
  node.NodeFocusImage = "gui\\special\\tianti\\strength\\btn_left_on.png"
  node.NodeSelectImage = "gui\\special\\tianti\\strength\\btn_left_down.png"
  node.NodeBackImage = "gui\\special\\tianti\\strength\\btn_left_out.png"
end
function hide_groupbox(form)
  for i = 1, 6 do
    local groupbox = form:Find("groupbox_" .. nx_string(i))
    if nx_is_valid(groupbox) then
      groupbox.Visible = false
    end
  end
  form.combobox_neigong.DroppedDown = false
  form.combobox_skill.DroppedDown = false
  form.lbl_loading.Visible = false
end
function on_tree_info_type_select_changed(tree)
  local node = tree.SelectNode
  local form = tree.ParentForm
  if not nx_is_valid(node) or not nx_is_valid(form) then
    return
  end
  if not (nx_find_custom(node, "name") and nx_find_custom(node, "showtype")) or not nx_find_custom(node, "type") then
    return
  end
  if node.type == "1" and nx_find_custom(node, "rowinfo") then
    if node.name == "All" then
      tree_select_general(form, node.rowinfo)
    else
      tree_select_type(form, node.name, node.rowinfo, node.image1, node.image2, node.text, node.desc, node.tips)
    end
  end
  if node.showtype == 4 then
    show_skill(form)
  end
  hide_groupbox(form)
  local groupbox = form:Find("groupbox_" .. nx_string(node.showtype))
  groupbox.Visible = true
  if node.showtype == 3 then
    if form.rbtn_xiangxi.Checked then
      form.rbtn_neigong.Checked = true
      form.rbtn_xiangxi.Checked = true
    else
      form.rbtn_xiangxi.Checked = true
      form.rbtn_neigong.Checked = true
    end
  end
end
function draw_view(form, r, offset, p1, p2, p3, p4, p5, p6, ...)
  local half_height = r * math.sin(math.pi * 0.3333333333333333)
  arg[1] = nx_int(r * (1 - p1) + offset)
  arg[2] = nx_int(half_height + offset)
  arg[3] = nx_int(r - r * p2 * math.cos(math.pi * 0.3333333333333333) + offset)
  arg[4] = nx_int(half_height - r * p2 * math.sin(math.pi * 0.3333333333333333) + offset)
  arg[5] = nx_int(r + r * p3 * math.cos(math.pi * 0.3333333333333333) + offset + 1)
  arg[6] = nx_int(half_height - r * p3 * math.sin(math.pi * 0.3333333333333333) + offset)
  arg[7] = nx_int(r * (1 + p4) + offset)
  arg[8] = nx_int(half_height + offset)
  arg[9] = nx_int(r + r * p5 * math.cos(math.pi * 0.3333333333333333) + offset)
  arg[10] = nx_int(half_height + r * p5 * math.sin(math.pi * 0.3333333333333333) + offset)
  arg[11] = nx_int(r - r * p6 * math.cos(math.pi * 0.3333333333333333) + offset + 1)
  arg[12] = nx_int(half_height + r * p6 * math.sin(math.pi * 0.3333333333333333) + offset)
  for i = 0, table.getn(arg) / 2 - 1 do
    local index = i * 2 + 1
  end
  draw_convex_polygon_box(form.groupbox_convex_polygon, unpack(arg))
end
function draw_convex_polygon_box(parent_control, ...)
  if not nx_is_valid(parent_control) then
    return
  end
  local count = table.getn(arg)
  if math.mod(count, 2) ~= 0 then
    return
  end
  local gui = nx_value("gui")
  local control = parent_control:Find("convex_polygon_box")
  if nx_is_valid(control) then
    gui:Delete(control)
  end
  local convex_polygon_box = gui:Create("ConvexPolygonBox")
  if not nx_is_valid(convex_polygon_box) then
    return
  end
  convex_polygon_box.Name = "convex_polygon_box"
  convex_polygon_box.BlendColor = "255,255,0,0"
  convex_polygon_box.Image = "gui\\special\\tianti\\strength\\area.png"
  convex_polygon_box.Enabled = false
  convex_polygon_box.NoFrame = false
  convex_polygon_box.Transparent = true
  convex_polygon_box.BorderWidth = 9
  parent_control:Add(convex_polygon_box)
  convex_polygon_box.Left = 0
  convex_polygon_box.Top = 0
  convex_polygon_box.Width = parent_control.Width
  convex_polygon_box.Height = parent_control.Height
  for i = 0, count / 2 - 1 do
    local index = i * 2 + 1
    convex_polygon_box:AddPoint(nx_int(arg[index]), nx_int(arg[index + 1]))
  end
end
function tree_select_general(form, rowinfo)
  local row_list = util_split_string(rowinfo, ",")
  for i = 1, table.getn(row_list) do
    if not nx_find_custom(form, "best_value" .. row_list[i]) then
      return
    end
    local best_value = nx_custom(form, "best_value" .. row_list[i])
    local value = get_self_value(nx_number(row_list[i]))
    local control_list = form.groupbox_zhanli:GetChildControlList()
    local pbar, label
    for j = 1, table.getn(control_list) do
      local item = control_list[j]
      if item.DataSource == nx_string(row_list[i]) then
        if nx_is_kind(item, "ProgressBar") then
          pbar = item
        elseif nx_is_kind(item, "Label") then
          label = item
        end
      end
    end
    if not nx_is_valid(pbar) or not nx_is_valid(label) then
      return
    end
    pbar.Maximum = best_value
    pbar.Value = value
    label.Visible = pbar.Value == best_value
  end
end
function server_msg_receive(...)
  local form = nx_value(FORM_ZHANLI)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, table.getn(row_data) do
    nx_set_custom(form, "best_value" .. nx_string(row_data[i]), nx_number(arg[i]))
  end
  create_info_type_tree(form)
  if nx_find_custom(form, "select_node") then
    form.tree_info_type.SelectNode = select_node
  end
end
function server_msg_name(...)
  local form = nx_value(FORM_ZHANLI)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < table.getn(name_data) then
    return
  end
  for i = 1, table.getn(name_data) do
    nx_set_custom(form, "best_name" .. nx_string(name_data[i]), nx_widestr(arg[i]))
  end
end
function server_msg_name_ex(...)
  local form = nx_value(FORM_ZHANLI)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < table.getn(last_week_name) then
    return
  end
  for i = 1, table.getn(last_week_name) do
    nx_set_custom(form, "last_week_best_name" .. nx_string(last_week_name[i]), nx_widestr(arg[i]))
  end
end
function get_self_value(row)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  return client_player:QueryRecord("MatchRankBase", nx_number(row), 0)
end
function tree_select_type(form, name, rowinfo, image1, image2, text, desc, tips, ...)
  local row_list = util_split_string(rowinfo, ",")
  local gui = nx_value("gui")
  if not nx_find_custom(form, "best_value" .. row_list[1]) then
    return
  end
  local best_value = nx_custom(form, "best_value" .. row_list[1])
  local self_value = get_self_value(nx_number(row_list[1]))
  form.pbar_type.ProgressImage = pbra_image[row_list[1]]
  form.pbar_type.Maximum = best_value
  form.pbar_type.Value = self_value
  form.pbar_type.DataSource = nx_string(row_list[1])
  form.lbl_type.BackImage = pbra_ani[row_list[1]]
  form.lbl_type.Visible = form.pbar_type.Value == best_value
  form.lbl_type_1.BackImage = image1
  form.lbl_type_2.BackImage = image2
  form.lbl_text.Text = util_text(text)
  form.lbl_text.Visible = form.pbar_type.Value == best_value
  form.lbl_tips.HintText = util_text(tips)
  form.mltbox_desc:Clear()
  local text = nx_widestr("")
  if name == "Equip" then
    gui.TextManager:Format_SetIDName(desc)
    gui.TextManager:Format_AddParam(get_self_value(MRBC_Equip_Damage_Skill))
    text = gui.TextManager:Format_GetText()
  elseif name == "Treasure" then
    gui.TextManager:Format_SetIDName(desc)
    gui.TextManager:Format_AddParam(get_self_value(MRBC_Treasure_Damage_Skill))
    text = gui.TextManager:Format_GetText()
  else
    text = util_text(desc)
  end
  form.mltbox_desc:AddHtmlText(text, -1)
  for i = 2, table.getn(row_list) do
    if not nx_find_custom(form, "best_value" .. row_list[1]) then
      return
    end
    local value = get_self_value(nx_number(row_list[i])) / nx_number(nx_custom(form, "best_value" .. row_list[i]))
    value = para + (1 - para) * value
    if 1 < value then
      value = 1
    end
    arg[i - 1] = value - 0.08
  end
  draw_view(form, 66, 8, unpack(arg))
  if table.getn(row_list) < 7 then
    return
  end
  form.lbl_15.HintText = nx_widestr(get_self_value(nx_number(row_list[2])))
  form.lbl_16.HintText = nx_widestr(get_self_value(nx_number(row_list[3])))
  form.lbl_17.HintText = nx_widestr(get_self_value(nx_number(row_list[4])))
  form.lbl_18.HintText = nx_widestr(get_self_value(nx_number(row_list[5])))
  form.lbl_19.HintText = nx_widestr(get_self_value(nx_number(row_list[6])))
  form.lbl_20.HintText = nx_widestr(get_self_value(nx_number(row_list[7])))
end
function send_query_data_msg(...)
  for i = 1, table.getn(row_data) do
    arg[i] = nx_int(row_data[i])
  end
  nx_execute("custom_sender", "custom_query_match_data", MDC_CTS_QueryRowValue, unpack(arg))
end
function send_query_name_msg(...)
  for i = 1, table.getn(name_data) do
    arg[i] = nx_int(name_data[i])
  end
  nx_execute("custom_sender", "custom_query_match_data", MDC_CTS_QueryRowName, unpack(arg))
end
function send_query_name_msg_ex(...)
  for i = 1, table.getn(last_week_name) do
    arg[i] = nx_int(last_week_name[i])
  end
  nx_execute("custom_sender", "custom_query_match_data", MDC_CTS_QueryRowNameEx, unpack(arg))
end
function on_rbtn_neigong_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked then
    form.groupbox_neigong.Visible = true
    form.groupbox_2.Visible = false
  end
end
function on_rbtn_xiangxi_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked then
    form.groupbox_neigong.Visible = false
    form.groupbox_2.Visible = true
  end
  if not nx_find_custom(form, "best_value" .. nx_string(MRBC_NeiGongNumber)) then
    return
  end
  local best_value = nx_custom(form, "best_value" .. nx_string(MRBC_NeiGongNumber))
  local value = get_self_value(nx_number(MRBC_NeiGongNumber))
  form.pbar_neigong.Maximum = best_value
  form.pbar_neigong.Value = value
end
function get_neigong_info()
  neigong_type = {}
  neigong_type_count = {}
  neigong_name = {}
  neigong_obj = {}
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local type_tab = wuxue_query:GetMainNames(WUXUE_NEIGONG)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local sub_type_tab = wuxue_query:GetItemNames(WUXUE_NEIGONG, type_name)
    local type_is_learn = false
    local type_count = 0
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local sub_type = wuxue_query:GetLearnID_NeiGong(sub_type_name)
      if nx_is_valid(sub_type) then
        type_is_learn = true
        type_count = type_count + 1
        neigong_name[table.getn(neigong_name) + 1] = sub_type_name
        neigong_obj[table.getn(neigong_obj) + 1] = sub_type
      end
    end
    if type_is_learn then
      neigong_type[table.getn(neigong_type) + 1] = type_name
      neigong_type_count[table.getn(neigong_type_count) + 1] = type_count
    end
  end
  local form = nx_value(FORM_ZHANLI)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, table.getn(neigong_type) do
    form.combobox_neigong.DropListBox:AddString(util_text(neigong_type[i]))
  end
  form.combobox_neigong.DropButton.Left = 90
  form.combobox_neigong.DropButton.Top = 2
  if 1 <= table.getn(neigong_type) then
    form.combobox_neigong.InputEdit.Text = util_text(neigong_type[1])
    form.combobox_neigong.DropListBox.SelectIndex = 0
    on_combobox_neigong_selected(form.combobox_neigong)
  end
end
function get_neigong_index(type_index, index)
  if type_index > table.getn(neigong_type_count) then
    return
  end
  local base_index = 0
  for i = 1, type_index - 1 do
    base_index = base_index + neigong_type_count[i]
  end
  return base_index + index
end
function on_combobox_neigong_selected(combobox)
  local form = combobox.ParentForm
  local select_index = combobox.DropListBox.SelectIndex
  if select_index < 0 or select_index >= table.getn(neigong_type) then
    return
  end
  clear_item(form.groupscrollbox_neigong)
  for i = 1, neigong_type_count[select_index + 1] do
    local neigong_index = get_neigong_index(select_index + 1, i)
    local item = get_neigong_new_item(form)
    item.lbl_name.Text = util_text(neigong_name[neigong_index])
    local obj = neigong_obj[neigong_index]
    if not nx_is_valid(obj) then
      return
    end
    item.lbl_level.Text = nx_widestr("(") .. nx_widestr(obj:QueryProp("Level")) .. nx_widestr("/") .. nx_widestr(obj:QueryProp("MaxLevel")) .. nx_widestr(")")
    if math.mod(i, 2) == 0 then
      item.BackImage = "gui\\special\\tianti\\strength\\bg_09.png"
    else
      item.BackImage = "gui\\special\\tianti\\strength\\bg_10.png"
    end
    set_buff_level(item, obj)
    form.groupscrollbox_neigong:Add(item)
    form.groupscrollbox_neigong.IsEditMode = false
    form.groupscrollbox_neigong:ResetChildrenYPos()
  end
end
function set_buff_level(item, obj)
  local static = obj:QueryProp("StaticData")
  local buff_level = obj:QueryProp("BufferLevel")
  local max_no = get_ini_key_data("share\\Skill\\NeiGong\\neigong_static.ini", nx_string(static), "MaxVarPropNo", "string")
  local max_buff_level = get_ini_key_data("share\\Skill\\NeiGong\\neigong_varprop.ini", max_no, "BufferLevel", "integer")
  local gui = nx_value("gui")
  for i = 1, max_buff_level do
    if i <= buff_level then
      local label = gui:Create("Label")
      label.BackImage = "gui\\special\\tianti\\strength\\icon_zhuzi_02.png"
      label.Left = -2 + (i - 1) * 28
      label.Top = -3
      label.AutoSize = true
      label.DrawMode = "Tile"
      item.groupbox_backImage:Add(label)
      if i ~= buff_level then
        local label_1 = gui:Create("Label")
        label_1.BackImage = "gui\\special\\tianti\\strength\\icon_zhuzi_03.png"
        label_1.Left = 18 + (i - 1) * 28
        label_1.Top = -3
        label_1.AutoSize = true
        label_1.DrawMode = "Tile"
        item.groupbox_backImage:Add(label_1)
      end
    else
      local label = gui:Create("Label")
      label.BackImage = "gui\\special\\tianti\\strength\\icon_zhuzi_01.png"
      label.Left = -2 + (i - 1) * 28
      label.Top = -3
      label.AutoSize = true
      label.DrawMode = "Tile"
      item.groupbox_backImage:Add(label)
    end
  end
  item.groupbox_backImage.Width = (max_buff_level - 1) * 31 + 14
end
function get_neigong_new_item(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_template
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return
  end
  item.canremove = true
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  item.BackImage = tpl_item.BackImage
  item.DrawMode = tpl_item.DrawMode
  item.AutoSize = item.AutoSize
  local tpl_lbl = tpl_item:Find("lbl_name")
  if nx_is_valid(tpl_lbl) then
    local lbl_name = gui:Create("Label")
    lbl_name.Left = tpl_lbl.Left
    lbl_name.Top = tpl_lbl.Top
    lbl_name.Width = tpl_lbl.Width
    lbl_name.Height = tpl_lbl.Height
    lbl_name.BackImage = tpl_lbl.BackImage
    lbl_name.DrawMode = tpl_lbl.DrawMode
    lbl_name.AutoSize = tpl_lbl.AutoSize
    lbl_name.Font = tpl_lbl.Font
    lbl_name.ForeColor = tpl_lbl.ForeColor
    lbl_name.Align = tpl_lbl.Align
    item:Add(lbl_name)
    item.lbl_name = lbl_name
  end
  local tpl_lbl_1 = tpl_item:Find("lbl_level")
  if nx_is_valid(tpl_lbl_1) then
    local lbl_level = gui:Create("Label")
    lbl_level.Left = tpl_lbl_1.Left
    lbl_level.Top = tpl_lbl_1.Top
    lbl_level.Width = tpl_lbl_1.Width
    lbl_level.Height = tpl_lbl_1.Height
    lbl_level.BackImage = tpl_lbl_1.BackImage
    lbl_level.DrawMode = tpl_lbl_1.DrawMode
    lbl_level.AutoSize = tpl_lbl_1.AutoSize
    lbl_level.Font = tpl_lbl_1.Font
    lbl_level.ForeColor = tpl_lbl_1.ForeColor
    lbl_level.Align = tpl_lbl_1.Align
    lbl_level.HintText = tpl_lbl_1.HintText
    lbl_level.Transparent = tpl_lbl_1.Transparent
    item:Add(lbl_level)
    item.lbl_level = lbl_level
  end
  local tpl_groupbox = tpl_item:Find("groupbox_backImage")
  if nx_is_valid(tpl_groupbox) then
    local groupbox_backImage = gui:Create("GroupBox")
    groupbox_backImage.Left = tpl_groupbox.Left
    groupbox_backImage.Top = tpl_groupbox.Top
    groupbox_backImage.Width = tpl_groupbox.Width
    groupbox_backImage.Height = tpl_groupbox.Height
    groupbox_backImage.BackColor = tpl_groupbox.BackColor
    groupbox_backImage.NoFrame = tpl_groupbox.NoFrame
    groupbox_backImage.BackImage = tpl_groupbox.BackImage
    groupbox_backImage.DrawMode = tpl_groupbox.DrawMode
    groupbox_backImage.AutoSize = tpl_groupbox.AutoSize
    groupbox_backImage.Transparent = tpl_groupbox.Transparent
    groupbox_backImage.HintText = tpl_groupbox.HintText
    item:Add(groupbox_backImage)
    item.groupbox_backImage = groupbox_backImage
  end
  return item
end
function clear_item(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local gui = nx_value("gui")
  local child_table = groupbox:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_find_custom(child, "canremove") and child.canremove then
      groupbox:Remove(child)
      gui:Delete(child)
      groupbox.IsEditMode = false
      groupbox:ResetChildrenYPos()
    end
  end
end
function get_skill_info(form)
  skill_type = {}
  skill_type_count = {}
  skill_name = {}
  skill_learn_count = {}
  skill_all_count = {}
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local type_tab = wuxue_query:GetMainNames(WUXUE_SKILL)
  local learned_tl_count = 0
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_SKILL, type_name)
    local is_learn = false
    local type_count = 0
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local type_taolu_count, learn_taolu = get_taolu_learn_count(sub_type_name)
      if 0 < nx_number(learn_taolu) then
        is_learn = true
        type_count = type_count + 1
        skill_name[table.getn(skill_name) + 1] = sub_type_name
        skill_learn_count[table.getn(skill_learn_count) + 1] = learn_taolu
        skill_all_count[table.getn(skill_all_count) + 1] = type_taolu_count
        learned_tl_count = learned_tl_count + 1
      end
    end
    if is_learn then
      skill_type[table.getn(skill_type) + 1] = type_name
      skill_type_count[table.getn(skill_type_count) + 1] = type_count
    end
  end
  form.learned_tl_count = learned_tl_count
  for i = 1, table.getn(skill_type) do
    form.combobox_skill.DropListBox:AddString(util_text(skill_type[i]))
  end
  form.combobox_skill.DropButton.Left = 90
  form.combobox_skill.DropButton.Top = 2
  if 1 <= table.getn(skill_type) then
    form.combobox_skill.InputEdit.Text = util_text(skill_type[1])
    form.combobox_skill.DropListBox.SelectIndex = 0
    on_combobox_skill_selected(form.combobox_skill)
  end
end
function get_taolu_learn_count(taolu_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0, 0
  end
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return 0, 0
  end
  local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, nx_string(taolu_name))
  local count = 0
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    if item_name == NORMAL_ATTACK_ID then
      item_name = fight:GetNormalAttackSkillID()
    elseif item_name == ANQI_ATTACK_ID then
      item_name = fight:GetNormalAnqiAttackSkillID(false)
    end
    local skill = wuxue_query:GetLearnID_Skill(item_name)
    if nx_is_valid(skill) then
      count = count + 1
    end
  end
  return table.getn(item_tab), count
end
function get_skill_new_item(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_template_1
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return
  end
  item.canremove = true
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  item.BackImage = tpl_item.BackImage
  item.DrawMode = tpl_item.DrawMode
  item.AutoSize = item.AutoSize
  local tpl_lbl = tpl_item:Find("lbl_name_1")
  if nx_is_valid(tpl_lbl) then
    local lbl_name = gui:Create("Label")
    lbl_name.Left = tpl_lbl.Left
    lbl_name.Top = tpl_lbl.Top
    lbl_name.Width = tpl_lbl.Width
    lbl_name.Height = tpl_lbl.Height
    lbl_name.BackImage = tpl_lbl.BackImage
    lbl_name.DrawMode = tpl_lbl.DrawMode
    lbl_name.AutoSize = tpl_lbl.AutoSize
    lbl_name.Font = tpl_lbl.Font
    lbl_name.ForeColor = tpl_lbl.ForeColor
    lbl_name.Align = tpl_lbl.Align
    item:Add(lbl_name)
    item.lbl_name = lbl_name
  end
  local tpl_lbl_1 = tpl_item:Find("lbl_count_1")
  if nx_is_valid(tpl_lbl_1) then
    local lbl_count = gui:Create("Label")
    lbl_count.Left = tpl_lbl_1.Left
    lbl_count.Top = tpl_lbl_1.Top
    lbl_count.Width = tpl_lbl_1.Width
    lbl_count.Height = tpl_lbl_1.Height
    lbl_count.BackImage = tpl_lbl_1.BackImage
    lbl_count.DrawMode = tpl_lbl_1.DrawMode
    lbl_count.AutoSize = tpl_lbl_1.AutoSize
    lbl_count.Font = tpl_lbl_1.Font
    lbl_count.ForeColor = tpl_lbl_1.ForeColor
    lbl_count.Align = tpl_lbl_1.Align
    lbl_count.Transparent = lbl_count.Transparent
    lbl_count.HintText = lbl_count.HintText
    item:Add(lbl_count)
    item.lbl_count = lbl_count
  end
  return item
end
function show_skill(form)
  if not nx_find_custom(form, "learned_tl_count") or not nx_find_custom(form, "best_value" .. nx_string(MRBC_TaoLuNumber)) then
    return
  end
  local value = form.learned_tl_count
  local best_value = nx_custom(form, "best_value" .. nx_string(MRBC_TaoLuNumber))
  form.pbar_skill.Value = value
  form.pbar_skill.Maximum = best_value
end
function get_taolu_index(type_index, index)
  if type_index > table.getn(skill_type_count) then
    return
  end
  local base_index = 0
  for i = 1, type_index - 1 do
    base_index = base_index + skill_type_count[i]
  end
  return base_index + index
end
function on_combobox_skill_selected(combobox)
  local form = combobox.ParentForm
  local select_index = combobox.DropListBox.SelectIndex
  if select_index < 0 or select_index >= table.getn(skill_type) then
    return
  end
  clear_item(form.groupscrollbox_skill)
  for i = 1, skill_type_count[select_index + 1] do
    local skill_index = get_taolu_index(select_index + 1, i)
    local item = get_skill_new_item(form)
    item.lbl_name.Text = util_text(skill_name[skill_index])
    item.lbl_count.Text = nx_widestr(skill_learn_count[skill_index]) .. nx_widestr("/") .. nx_widestr(skill_all_count[skill_index])
    if math.mod(i, 2) == 0 then
      item.BackImage = "gui\\special\\tianti\\strength\\bg_07.png"
    else
      item.BackImage = "gui\\special\\tianti\\strength\\bg_08.png"
    end
    form.groupscrollbox_skill:Add(item)
    form.groupscrollbox_skill.IsEditMode = false
    form.groupscrollbox_skill:ResetChildrenYPos()
  end
end
function on_pbar_get_capture(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "best_name" .. self.DataSource) then
    return
  end
  if not nx_find_custom(form, "best_value" .. self.DataSource) then
    return
  end
  local name = nx_custom(form, "best_name" .. self.DataSource)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_tianti_035")
  gui.TextManager:Format_AddParam(name)
  gui.TextManager:Format_AddParam(nx_int(nx_custom(form, "best_value" .. self.DataSource)))
  gui.TextManager:Format_AddParam(nx_int(self.Value))
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 0, form)
end
function on_pbar_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_pbar_neigong_get_capture(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "best_name" .. self.DataSource) then
    return
  end
  if not nx_find_custom(form, "best_value" .. self.DataSource) then
    return
  end
  local name = nx_custom(form, "best_name" .. self.DataSource)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_tianti_036")
  gui.TextManager:Format_AddParam(name)
  gui.TextManager:Format_AddParam(nx_int(nx_custom(form, "best_value" .. self.DataSource)))
  gui.TextManager:Format_AddParam(nx_int(self.Value))
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 0, form)
end
function on_pbar_neigong_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_pbar_skill_get_capture(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "best_name" .. self.DataSource) then
    return
  end
  if not nx_find_custom(form, "best_value" .. self.DataSource) then
    return
  end
  local name = nx_custom(form, "best_name" .. self.DataSource)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_tianti_037")
  gui.TextManager:Format_AddParam(name)
  gui.TextManager:Format_AddParam(nx_int(nx_custom(form, "best_value" .. self.DataSource)))
  gui.TextManager:Format_AddParam(nx_int(self.Value))
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 0, form)
end
function on_pbar_skill_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_show_friend_click(btn)
  local form = btn.ParentForm
  local gb_friend = form.groupbox_5
  gb_friend.Visible = not gb_friend.Visible
  form.query_type = 0
  if gb_friend.Visible then
    form.query_type = 3
    on_set_groupbox_vis(form, false)
    form.lbl_loading.Visible = false
    init_grid(form.textgrid_rank)
    on_update_grid_info(form, form.sel_page)
    on_btn_friend_click(form.btn_friend)
  else
    local form_sel_friend = nx_value(FORM_QUERY_FRIEND)
    if nx_is_valid(form_sel_friend) then
      form_sel_friend.Visible = false
      form_sel_friend:Close()
    end
    on_tree_info_type_select_changed(form.tree_info_type)
  end
end
function init_grid(grid)
  if not nx_is_valid(grid) then
    return
  end
  local gui = nx_value("gui")
  local rank_gird = grid
  rank_gird:ClearRow()
  rank_gird.ColCount = 3
  rank_gird:SetColWidth(0, rank_gird.Width / 5)
  rank_gird:SetColWidth(1, rank_gird.Width / 5 * 2)
  rank_gird:SetColWidth(2, rank_gird.Width / 5 * 2)
  local text = gui.TextManager:GetText("ui_tianti_number")
  rank_gird:SetColTitle(0, text)
  text = gui.TextManager:GetText("ui_tianti_name")
  rank_gird:SetColTitle(1, text)
  text = gui.TextManager:GetText("ui_tianti_grade")
  rank_gird:SetColTitle(2, text)
end
function on_update_grid_info(form, page)
  if not nx_is_valid(form) then
    return
  end
  if page <= 0 then
    return
  end
  if form.query_type ~= 3 then
    return
  end
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    return
  end
  local rank_gird = form.textgrid_rank
  init_grid(rank_gird)
  local count = form_invrank_friend.PlayerNum
  if count <= 0 then
    return
  end
  local begin_index = (page - 1) * GRID_ROW
  local end_index = page * GRID_ROW
  form.lbl_page.Text = nx_widestr(page)
  rank_gird:BeginUpdate()
  for i = begin_index, end_index - 1 do
    local name = form_invrank_friend:GetRankPlayerName(i)
    local score = form_invrank_friend:GetRankPlayerScore(i)
    if 0 <= score and nx_widestr(name) ~= nx_widestr("") then
      local row = rank_gird:InsertRow(-1)
      rank_gird:SetGridText(row, 0, nx_widestr(i + 1))
      rank_gird:SetGridText(row, 1, nx_widestr(name))
      rank_gird:SetGridText(row, 2, nx_widestr(score))
    end
  end
  rank_gird:EndUpdate()
end
function on_btn_page_pre_click(btn)
  local form = btn.ParentForm
  if form.sel_page == 0 then
    return
  end
  local page = form.sel_page
  page = page - 1
  if page <= 1 then
    btn.Enabled = false
  end
  if form.sel_page == form.max_page then
    form.btn_page_after.Enabled = true
  end
  form.sel_page = page
  on_update_grid_info(form, page)
end
function on_btn_page_after_click(btn)
  local form = btn.ParentForm
  if form.sel_page == 0 then
    return
  end
  local page = form.sel_page
  page = page + 1
  if page >= form.max_page then
    btn.Enabled = false
  end
  if form.sel_page == form.min_page then
    form.btn_page_pre.Enabled = true
  end
  form.sel_page = page
  on_update_grid_info(form, page)
end
function on_set_groupbox_vis(form, visble)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = visble
  form.groupbox_2.Visible = visble
  form.groupbox_3.Visible = visble
  form.groupbox_4.Visible = visble
end
function on_refesh_firend(player_name, zhanli)
  local form = nx_value("form_stage_main\\form_general_info\\form_general_info_zhanli")
  if not nx_is_valid(form) then
    return
  end
  if form.Visible ~= true then
    return
  end
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    return
  end
  if form_invrank_friend.UpdateForm ~= true then
    return
  end
  form_invrank_friend:AddPlayerZhanLi(player_name, zhanli)
end
function on_query_friend_rank(query_rec, playerNameList)
  local form = nx_value("form_stage_main\\form_general_info\\form_general_info_zhanli")
  if not nx_is_valid(form) then
    return
  end
  if form.Visible ~= true then
    return
  end
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("MatchRankBase") then
    return
  end
  local game_timer = nx_value(GAME_TIMER)
  if not nx_is_valid(game_timer) then
    return
  end
  local num = client_player:QueryRecord("MatchRankBase", 93, 0)
  local name = client_player:QueryProp("Name")
  form_invrank_friend:AddPlayerZhanLi(name, num)
  form_invrank_friend.UpdateForm = true
  form.lbl_loading.Visible = true
  game_timer:Register(15000, 1, nx_current(), "update_form", form, -1, -1)
  nx_execute("custom_sender", "custom_query_friend_rank", "1", query_rec, playerNameList)
end
function update_form(form)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible ~= true then
    return
  end
  form.lbl_loading.Visible = false
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    return
  end
  form_invrank_friend.UpdateForm = false
  if form_invrank_friend.PlayerNum <= 0 then
    return
  end
  form_invrank_friend:SortZhanLi()
  local num = form_invrank_friend.PlayerNum
  local page_num = num / GRID_ROW
  local page_mod = num % GRID_ROW
  if page_mod == 0 then
    form.max_page = page_num
  else
    form.max_page = page_num + 1
  end
  form.sel_page = 1
  form.min_page = 1
  form.btn_page_after.Enabled = true
  if num <= GRID_ROW then
    form.btn_page_after.Enabled = false
  end
  form.btn_page_pre.Enabled = false
  on_update_grid_info(form, 1)
end
function on_btn_friend_click(btn)
  local form = btn.ParentForm
  if form.query_type ~= 3 then
    return
  end
  local form_query_friend = nx_execute("util_gui", "util_get_form", FORM_QUERY_FRIEND, true, false)
  if nx_is_valid(form_query_friend) then
    form_query_friend.AbsLeft = form.groupbox_5.AbsLeft - 10
    form_query_friend.AbsTop = form.groupbox_5.AbsTop + form.groupbox_5.Height / 3
    form_query_friend:Show()
    form_query_friend.Visible = true
    nx_execute(FORM_QUERY_FRIEND, "refresh_form", form_query_friend, form.query_type)
  end
end
function on_textgrid_rank_right_select_grid(grid, row, col)
  local form = grid.ParentForm
  local player_name = grid:GetGridText(row, 1)
  if nx_widestr(player_name) == nx_widestr("") then
    return
  end
  form.sel_player = player_name
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  form.groupbox_6.AbsLeft = x
  form.groupbox_6.AbsTop = y
  form.groupbox_6.Visible = true
end
function on_textgrid_rank_select_grid(grid)
  local form = grid.ParentForm
  form.groupbox_6.Visible = false
end
function on_btn_4_click(btn)
  nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "show_ws")
end
function on_btn_chat_click(btn)
  local form = btn.ParentForm
  if nx_widestr(form.sel_player) == nx_widestr("") then
    return
  end
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.sel_player))
  form.groupbox_6.Visible = false
end
function on_btn_email_click(btn)
  local form = btn.ParentForm
  if nx_widestr(form.sel_player) == nx_widestr("") then
    return
  end
  nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
  local form_send_mail = nx_value("form_stage_main\\form_mail\\form_mail_send")
  if nx_is_valid(form_send_mail) then
    form_send_mail.targetname.Text = nx_widestr(form.sel_player)
  end
  form.groupbox_6.Visible = false
end
function on_btn_look_click(btn)
  local form = btn.ParentForm
  if nx_widestr(form.sel_player) == nx_widestr("") then
    return
  end
  nx_execute("custom_sender", "custom_send_get_player_game_info", form.sel_player)
  form.groupbox_6.Visible = false
end
function on_rbtn_zhanli_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  form.groupbox_zhanli.Visible = true
  form.groupbox_gaoshou.Visible = false
end
function on_rbtn_gaoshou_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  if not nx_find_custom(form, "last_week_best_name93") then
    return
  end
  if not nx_find_custom(form, "last_week_best_name94") then
    return
  end
  if not nx_find_custom(form, "last_week_best_name95") then
    return
  end
  if not nx_find_custom(form, "last_week_best_name96") then
    return
  end
  if not nx_find_custom(form, "last_week_best_name97") then
    return
  end
  form.lbl_gaoshou_name_93.Text = nx_custom(form, "last_week_best_name93")
  form.lbl_gaoshou_name_94.Text = nx_custom(form, "last_week_best_name94")
  form.lbl_gaoshou_name_95.Text = nx_custom(form, "last_week_best_name95")
  form.lbl_gaoshou_name_96.Text = nx_custom(form, "last_week_best_name96")
  form.lbl_gaoshou_name_97.Text = nx_custom(form, "last_week_best_name97")
  form.groupbox_zhanli.Visible = false
  form.groupbox_gaoshou.Visible = true
end
function on_btn_yulan_click(self)
  local form = self.ParentForm
  if self.DataSource == "" then
    return
  end
  nx_execute("custom_sender", "custom_set_title", nx_int(self.DataSource))
end
function on_btn_find_click(self)
  local form = self.ParentForm
  if self.DataSource == "" then
    return
  end
  local label = nx_custom(form, "lbl_gaoshou_name_" .. self.DataSource)
  if nx_is_valid(label) then
    nx_execute("custom_sender", "custom_send_get_player_game_info", nx_widestr(label.Text))
  end
end
function get_client_player()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    return game_client:GetPlayer()
  end
  return nx_null()
end
function on_btn_wycx_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(URL_TYPE_REVENGE_URL)
end
