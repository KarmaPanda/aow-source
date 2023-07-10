require("util_gui")
require("share\\client_custom_define")
local table_check_box = {}
local table_selected = {}
local gossip_page = 1
local gossip_page_number = 1
local bool_delete = false
local table_radio_page = {}
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  table_radio_page = {}
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.groupscrollbox_bagua.Visible = false
  form.btn_share.Visible = false
  form.btn_delete.Visible = false
  table_radio_page = {
    form.rbtn_page_1,
    form.rbtn_page_2,
    form.rbtn_page_3,
    form.rbtn_page_4,
    form.rbtn_page_5,
    form.rbtn_page_6,
    form.rbtn_page_7,
    form.rbtn_page_8,
    form.rbtn_page_9,
    form.rbtn_page_10
  }
  nx_execute("custom_sender", "custom_show_npc_friend")
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_click(rbtn)
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  if 0 == rbtn.TabIndex then
    form.groupscrollbox_desc.Visible = true
    form.groupscrollbox_bagua.Visible = false
    form.btn_share.Visible = false
    form.btn_delete.Visible = false
    remove_group_karma()
  elseif 1 == rbtn.TabIndex then
    if form.rbtn_page_1.Checked then
      show_gossip_info(form, true, 1)
    else
      form.rbtn_page_1.Checked = true
    end
    remove_group_karma()
  elseif 2 == rbtn.TabIndex then
    form.groupscrollbox_desc.Visible = false
    form.groupscrollbox_bagua.Visible = false
    form.btn_share.Visible = false
    form.btn_delete.Visible = false
    add_group_karma(form)
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function add_group_karma(form)
  local form_group_karma = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_group_karma", true, false)
  form:Add(form_group_karma)
  form_group_karma.Left = form.groupscrollbox_bagua.Left - 1
  form_group_karma.Top = form.groupscrollbox_bagua.Top - 1
end
function remove_group_karma()
  local form_group_karma = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_group_karma", true, false)
  form_group_karma:Close()
end
function show_npc_friend(data)
  if data == nil or data == "" then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_karma", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.groupscrollbox_desc.IsEditMode = true
  form.groupscrollbox_desc:DeleteAll()
  local photo = "photo"
  local name = "name"
  local degree = "degree"
  local city = "city"
  local character = "character"
  local relation = "relation"
  local fangle = "fangle"
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local game_client = nx_value("game_client")
  local game_scene = game_client:GetScene()
  city = util_text(nx_string(game_scene:QueryProp("ConfigID")))
  add_groupbox_menu(form)
  local npc_list = util_split_string(nx_string(data), ";")
  if table.getn(npc_list) <= 0 then
    return
  end
  for i = 1, table.getn(npc_list) do
    local sub_list = util_split_string(nx_string(npc_list[i]), ",")
    if table.getn(sub_list) == 3 then
      name = util_text(nx_string(sub_list[1]))
      if not ItemQuery:FindItemByConfigID(nx_string(sub_list[1])) then
        return
      end
      photo = ItemQuery:GetItemPropByConfigID(nx_string(sub_list[1]), nx_string("Photo"))
      degree = nx_string(sub_list[1]) .. "_1"
      if nx_widestr(util_text(degree)) ~= nx_widestr(degree) then
        degree = util_text(nx_string(degree))
      else
        degree = util_text(nx_string("ui_karma_none"))
      end
      relation = sub_list[2]
      character = util_text(nx_string("desc_matchingpack_" .. sub_list[3]))
      fangle = get_fangle_desc(sub_list[3], relation)
      if fangle ~= "" then
        fangle = util_text(nx_string(fangle))
      end
    end
    add_npc_info_groupbox(form, i, photo, name, degree, city, character, relation, fangle)
  end
  form.Visable = true
  form:Show()
  form.groupscrollbox_desc:ResetChildrenYPos()
  form.groupscrollbox_desc.IsEditMode = false
end
function add_npc_info_groupbox(form, index, photo, name, degree, city, character, relation, fangle_desc)
  if nx_number(relation) == 100000 then
    return
  end
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  form.groupscrollbox_desc:Add(groupbox)
  groupbox.AutoSize = false
  groupbox.Name = "groupbox_info_" .. nx_string(index)
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Left = 3
  groupbox.Top = 35 + (index - 1) * 85
  groupbox.Width = 630
  groupbox.Height = 80
  local label_line = gui:Create("Label")
  groupbox:Add(label_line)
  label_line.Name = "label_line" .. nx_string(index)
  label_line.Left = 12
  label_line.Top = 70
  label_line.Width = 615
  label_line.Height = 3
  label_line.DrawMode = "Expand"
  label_line.BackImage = nx_string("gui\\common\\form_line\\line_bg2.png")
  local label_photo = gui:Create("Label")
  groupbox:Add(label_photo)
  label_photo.Name = "label_photo" .. nx_string(index)
  label_photo.Left = 20
  label_photo.Top = 10
  label_photo.Width = 48
  label_photo.Height = 48
  label_photo.DrawMode = "FitWindow"
  label_photo.BackImage = nx_string(photo)
  local label_name = gui:Create("Label")
  groupbox:Add(label_name)
  label_name.Name = "label_name" .. nx_string(index)
  label_name.Left = 88
  label_name.Top = 30
  label_name.Width = 70
  label_name.Height = 16
  label_name.Align = "Center"
  label_name.Text = nx_widestr(name)
  label_name.ForeColor = "255,76,61,44"
  label_name.Font = "font_text_title1"
  local label_degree = gui:Create("Label")
  groupbox:Add(label_degree)
  label_degree.Name = "label_degree" .. nx_string(index)
  label_degree.Left = 168
  label_degree.Top = 30
  label_degree.Width = 70
  label_degree.Height = 16
  label_degree.Align = "Center"
  label_degree.Text = nx_widestr(degree)
  label_degree.ForeColor = "255,76,61,44"
  label_degree.Font = "font_text_title1"
  local label_city = gui:Create("Label")
  groupbox:Add(label_city)
  label_city.Name = "label_city" .. nx_string(index)
  label_city.Left = 248
  label_city.Top = 30
  label_city.Width = 70
  label_city.Height = 16
  label_city.Align = "Center"
  label_city.Text = nx_widestr(city)
  label_city.ForeColor = "255,76,61,44"
  label_city.Font = "font_text_title1"
  local label_character = gui:Create("Label")
  groupbox:Add(label_character)
  label_character.Name = "label_character" .. nx_string(index)
  label_character.Left = 328
  label_character.Top = 30
  label_character.Width = 70
  label_character.Height = 16
  label_character.Align = "Center"
  label_character.Text = nx_widestr(character)
  label_character.ForeColor = "255,76,61,44"
  label_character.Font = "font_text_title1"
  local groupbox_relation = gui:Create("GroupBox")
  groupbox:Add(groupbox_relation)
  groupbox_relation.AutoSize = false
  groupbox_relation.Name = "groupbox_relation" .. nx_string(index)
  groupbox_relation.BackColor = "0,0,0,0"
  groupbox_relation.NoFrame = true
  groupbox_relation.Left = 375
  groupbox_relation.Top = 0
  local label_fstip = gui:Create("ProgressBar")
  label_fstip.Name = "prog_karma" .. nx_string(index)
  label_fstip.Left = 0
  label_fstip.Top = 5
  label_fstip.DrawMode = "FitWindow"
  label_fstip.AutoSize = true
  label_fstip.BackImage = "gui\\mainform\\NPC\\bg_2.png"
  label_fstip.ProgressImage = "gui\\mainform\\NPC\\bg_1.png"
  local label_face = gui:Create("Label")
  label_face.Name = "label_karma" .. nx_string(index)
  label_face.Left = 55
  label_face.Top = 0
  label_face.AutoSize = true
  label_face.BackImage = "gui\\mainform\\NPC\\Level_4.png"
  label_face.DrawMode = "Tile"
  groupbox_relation.Width = label_fstip.Width + 20
  groupbox_relation.Height = 70
  label_fstip.Left = (groupbox_relation.Width - label_fstip.Width) / 2
  groupbox_relation:Add(label_fstip)
  groupbox_relation:Add(label_face)
  local karma_value = nx_int(relation)
  set_karma_groupbox(label_fstip, label_face, karma_value)
  local MultiTextBox_fangle_desc = gui:Create("MultiTextBox")
  groupbox:Add(MultiTextBox_fangle_desc)
  MultiTextBox_fangle_desc.Name = "MultiTextBox_fangle_desc" .. nx_string(index)
  MultiTextBox_fangle_desc.Left = 522
  MultiTextBox_fangle_desc.Top = 0
  MultiTextBox_fangle_desc.Width = 100
  MultiTextBox_fangle_desc.Height = 80
  MultiTextBox_fangle_desc.HAlign = "Center"
  MultiTextBox_fangle_desc.VAlign = "Center"
  MultiTextBox_fangle_desc.ViewRect = "2,2,100,80"
  MultiTextBox_fangle_desc.HtmlText = nx_widestr(fangle_desc)
  MultiTextBox_fangle_desc.MouseInBarColor = "0,0,0,0"
  MultiTextBox_fangle_desc.SelectBarColor = "0,0,0,0"
  MultiTextBox_fangle_desc.TextColor = "255,255,255,255"
  MultiTextBox_fangle_desc.Font = "font_sns_event"
  MultiTextBox_fangle_desc.TransParent = true
  MultiTextBox_fangle_desc.NoFrame = true
end
function set_karma_groupbox(label_fstip, label_face, karma_value)
  if not nx_is_valid(label_fstip) then
    return
  end
  if not nx_is_valid(label_face) then
    return
  end
  local photo = ""
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("Karma")
  if sec_index < 0 then
    sec_index = "0"
  end
  local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(GroupMsgData)) do
    local stepData = util_split_string(GroupMsgData[i], ",")
    if nx_int(stepData[1]) <= nx_int(karma_value) and nx_int(karma_value) <= nx_int(stepData[2]) then
      photo = nx_string(stepData[4])
    end
  end
  local KarmaMaxValue = 200000
  local index_max = ini:FindSectionIndex("KarmaValue")
  if 0 <= index_max then
    KarmaMaxValue = ini:GetSectionItemValue(index_max, nx_string("MaxValue"))
  end
  label_fstip.Minimum = 0
  label_fstip.Maximum = nx_int(KarmaMaxValue)
  label_fstip.Value = nx_int(KarmaMaxValue) / 2 + nx_int(karma_value)
  if photo == "" then
    return
  end
  label_face.BackImage = photo
  local radio = nx_number(label_fstip.Value) / nx_number(label_fstip.Maximum)
  local radius = (label_fstip.Width + 10) / 2
  local diff = radio - 0.5
  local edge = math.abs(diff) * radius * 2
  local height = math.pow(radius * radius - edge * edge, 0.5)
  local top = label_fstip.Top + (radius - height)
  local left = label_fstip.Left + label_fstip.Width * radio
  label_face.Left = left - label_face.Width / 2
  label_face.Top = top - label_face.Height / 2 + 5
  if 0 > label_face.Left then
    label_face.Left = 0
  end
  if label_face.Left > label_fstip.Width - 13 then
    label_face.Left = label_fstip.Width - 13
  end
  if label_face.Top > 75 - label_face.Height then
    label_face.Top = 75 - label_face.Height
  end
end
function add_groupbox_menu(form)
  local gui = nx_value("gui")
  local groupbox_menu = gui:Create("GroupBox")
  form.groupscrollbox_desc:Add(groupbox_menu)
  groupbox_menu.AutoSize = false
  groupbox_menu.Name = "groupbox_menu"
  groupbox_menu.BackColor = "0,0,0,0"
  groupbox_menu.NoFrame = true
  groupbox_menu.Left = 4
  groupbox_menu.Top = 0
  groupbox_menu.Width = 630
  groupbox_menu.Height = 40
  local label_line = gui:Create("Label")
  groupbox_menu:Add(label_line)
  label_line.Name = "label_line" .. nx_string(index)
  label_line.Left = 10
  label_line.Top = 33
  label_line.Width = 615
  label_line.Height = 3
  label_line.DrawMode = "Expand"
  label_line.BackImage = nx_string("gui\\common\\form_line\\line_bg2.png")
  local label_1 = gui:Create("Label")
  groupbox_menu:Add(label_1)
  label_1.Name = "groupbox_menu_1"
  label_1.Left = 15
  label_1.Top = 16
  label_1.Width = 54
  label_1.Height = 16
  label_1.Align = "Center"
  label_1.Text = nx_widestr(util_text("ui_karma_photo"))
  label_1.ForeColor = "255,76,61,44"
  label_1.Font = "font_text_title1"
  local label_2 = gui:Create("Label")
  groupbox_menu:Add(label_2)
  label_2.Name = "groupbox_menu_2"
  label_2.Left = 95
  label_2.Top = 16
  label_2.Width = 54
  label_2.Height = 16
  label_2.Align = "Center"
  label_2.Text = nx_widestr(util_text("ui_karma_name"))
  label_2.ForeColor = "255,76,61,44"
  label_2.Font = "font_text_title1"
  local label_3 = gui:Create("Label")
  groupbox_menu:Add(label_3)
  label_3.Name = "groupbox_menu_3"
  label_3.Left = 175
  label_3.Top = 16
  label_3.Width = 54
  label_3.Height = 16
  label_3.Align = "Center"
  label_3.Text = nx_widestr(util_text("ui_karma_degree"))
  label_3.ForeColor = "255,76,61,44"
  label_3.Font = "font_text_title1"
  local label_4 = gui:Create("Label")
  groupbox_menu:Add(label_4)
  label_4.Name = "groupbox_menu_4"
  label_4.Left = 255
  label_4.Top = 16
  label_4.Width = 54
  label_4.Height = 16
  label_4.Align = "Center"
  label_4.Text = nx_widestr(util_text("ui_karma_city"))
  label_4.ForeColor = "255,76,61,44"
  label_4.Font = "font_text_title1"
  local label_5 = gui:Create("Label")
  groupbox_menu:Add(label_5)
  label_5.Name = "groupbox_menu_5"
  label_5.Left = 335
  label_5.Top = 16
  label_5.Width = 54
  label_5.Height = 16
  label_5.Align = "Center"
  label_5.Text = nx_widestr(util_text("ui_karma_xingge"))
  label_5.ForeColor = "255,76,61,44"
  label_5.Font = "font_text_title1"
  local label_6 = gui:Create("Label")
  groupbox_menu:Add(label_6)
  label_6.Name = "groupbox_menu_6"
  label_6.Left = 420
  label_6.Top = 16
  label_6.Width = 54
  label_6.Height = 16
  label_6.Align = "Center"
  label_6.Text = nx_widestr(util_text("ui_karma_relation"))
  label_6.ForeColor = "255,76,61,44"
  label_6.Font = "font_text_title1"
  local label_7 = gui:Create("Label")
  groupbox_menu:Add(label_7)
  label_7.Name = "groupbox_menu_7"
  label_7.Left = 535
  label_7.Top = 16
  label_7.Width = 54
  label_7.Height = 16
  label_7.Align = "Center"
  label_7.Text = nx_widestr(util_text("ui_karma_news"))
  label_7.ForeColor = "255,76,61,44"
  label_7.Font = "font_text_title1"
end
function get_fangle_desc(characte_num, karma_value)
  local characte_str = ""
  local relation_str = ""
  if nx_number(characte_num) == 1 then
    characte_str = "Xiay"
  elseif nx_number(characte_num) == 2 then
    characte_str = "Yind"
  elseif nx_number(characte_num) == 3 then
    characte_str = "Haos"
  elseif nx_number(characte_num) == 4 then
    characte_str = "Tanc"
  elseif nx_number(characte_num) == 5 then
    characte_str = "Zhuany"
  elseif nx_number(characte_num) == 6 then
    characte_str = "Haose"
  elseif nx_number(characte_num) == 7 then
    characte_str = "Xius"
  elseif nx_number(characte_num) == 8 then
    characte_str = "Shij"
  elseif nx_number(characte_num) == 9 then
    characte_str = "Shanl"
  elseif nx_number(characte_num) == 10 then
    characte_str = "Shix"
  elseif nx_number(characte_num) == 11 then
    characte_str = "Congh"
  elseif nx_number(characte_num) == 12 then
    characte_str = "Nud"
  elseif nx_number(characte_num) == 13 then
    characte_str = "Qinf"
  elseif nx_number(characte_num) == 14 then
    characte_str = "Lans"
  end
  karma_value = 200000 - nx_int(karma_value)
  karma_value = nx_number(karma_value)
  if 0 <= karma_value and karma_value < 40000 then
    relation_str = "Zengw"
  elseif 40000 <= karma_value and karma_value < 80000 then
    relation_str = "Taoy"
  elseif 80000 <= karma_value and karma_value < 100000 then
    relation_str = "Fang"
  elseif 100000 < karma_value and karma_value < 120000 then
    relation_str = "Haoq"
  elseif 120000 <= karma_value and karma_value < 160000 then
    relation_str = "Xih"
  elseif 160000 <= karma_value and karma_value <= 200000 then
    relation_str = "Yangm"
  end
  local index = math.random(5)
  return "News_" .. nx_string(characte_str) .. "_" .. nx_string(relation_str) .. "_00" .. nx_string(index)
end
function on_rbtn_page_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  gossip_page = rbtn.TabIndex + 1
  form.mltbox_bagua_info.Visible = true
  form.groupbox_check_box.Visible = true
  form.btn_left.Enabled = true
  form.btn_right.Enabled = true
  show_gossip_info(form, true, gossip_page)
end
function show_gossip_info(form, refresh, page)
  if not nx_is_valid(form) then
    return
  end
  form.groupscrollbox_desc.Visible = false
  form.groupscrollbox_bagua.Visible = true
  form.btn_share.Visible = true
  form.btn_delete.Visible = true
  form.btn_left.Visible = false
  form.btn_right.Visible = false
  for i = 1, table.getn(table_radio_page) do
    if table_radio_page[i] ~= nil then
      table_radio_page[i].Visible = false
    end
  end
  local groupbox = form.groupbox_check_box
  if not nx_is_valid(groupbox) then
    return
  end
  local groupbox_lbl_tips = form.groupbox_lbl_tips
  if not nx_is_valid(groupbox_lbl_tips) then
    return
  end
  local groupbox_index = form.groupbox_index
  if not nx_is_valid(groupbox_index) then
    return
  end
  local mltbox = form.mltbox_bagua_info
  if not nx_is_valid(mltbox) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  mltbox:Clear()
  groupbox:DeleteAll()
  groupbox_lbl_tips:DeleteAll()
  groupbox_index:DeleteAll()
  local table_remove = {}
  local rows = client_player:GetRecordRows("Gossip_Record")
  if rows < 1 then
    return
  end
  local gui = nx_value("gui")
  local mltbox_count = 0
  table_check_box = {}
  local page_number = nx_int((rows - 1) / 10) + 1
  if bool_delete then
    table_remove = table_selected
    page_number = nx_int((rows - table.getn(table_remove) - 1) / 10) + 1
    bool_delete = false
  end
  local start_index = (page - 1) * 10
  local final_index = 0
  if page < page_number then
    final_index = page * 10
  elseif page == page_number then
    final_index = rows
  else
    return
  end
  if 1 == gossip_page then
    final_index = final_index + table.getn(table_remove)
  end
  if rows < final_index then
    final_index = rows
  end
  local control_top = 0
  local control_number = 0
  local show_number = start_index
  for i = start_index, final_index - 1 do
    local bagua_id = client_player:QueryRecord("Gossip_Record", i, 0)
    if not data_exist(table_remove, bagua_id) then
      local check_box = gui:Create("CheckButton")
      local check_box_name = "check_box_" .. nx_string(table.getn(table_check_box))
      check_box.Name = check_box_name
      check_box.Left = 0
      check_box.Width = 16
      check_box.Height = 16
      check_box.AutoSize = "True"
      check_box.DrawMode = "Title"
      check_box.CheckedImage = nx_string("gui\\common\\checkbutton\\cbtn_2_down.png")
      check_box.NormalImage = nx_string("gui\\common\\checkbutton\\cbtn_2_out.png")
      check_box.FocusImage = nx_string("gui\\common\\checkbutton\\cbtn_2_on.png")
      groupbox:Add(check_box)
      local rbtn_tips = gui:Create("RadioButton")
      rbtn_tips.Name = "rbtn_tips" .. nx_string(show_number)
      rbtn_tips.Left = 0
      rbtn_tips.Top = control_top + control_number * 32
      rbtn_tips.Width = 35
      rbtn_tips.Height = 32
      rbtn_tips.DrawMode = "Title"
      rbtn_tips.BackImage = nx_string("gui\\special\\karma\\shengluehao.png")
      rbtn_tips.Transparent = false
      rbtn_tips.TabIndex = control_number
      nx_bind_script(rbtn_tips, nx_current(), "")
      nx_callback(rbtn_tips, "on_get_capture", "on_rbtn_tips_get_capture")
      nx_callback(rbtn_tips, "on_lost_capture", "on_rbtn_tips_lost_capture")
      groupbox_lbl_tips:Add(rbtn_tips)
      form:ToFront(rbtn_tips)
      local label_index = gui:Create("Label")
      label_index.Name = "label_index" .. nx_string(show_number)
      label_index.Left = 0
      label_index.Top = control_top + control_number * 32
      label_index.Width = 54
      label_index.Height = 32
      label_index.Align = "Center"
      label_index.Text = nx_widestr(nx_string(show_number + 1))
      label_index.ForeColor = "255,76,61,44"
      groupbox_index:Add(label_index)
      show_number = show_number + 1
      control_number = control_number + 1
      local bagua_info = gui.TextManager:GetText(bagua_id)
      mltbox:AddHtmlText(nx_widestr(bagua_info), show_number)
      mltbox_count = mltbox_count + 1
      table.insert(table_check_box, bagua_id)
    end
  end
  gossip_page_number = page_number
  gossip_page = page
  set_bagua_control_position(form, table.getn(table_check_box), page_number, page, mltbox_count)
  form.SelectMltbox = mltbox
  form.SelectIndex = mltbox_count
end
function set_bagua_control_position(form, rows, page_number, page, line_count)
  form.groupscrollbox_bagua.IsEditMode = true
  local groupbox = form.groupbox_check_box
  if 1 < page_number then
    form.btn_left.Visible = true
    form.btn_right.Visible = true
  end
  set_control_check_mlt_position(groupbox, rows, page_number, page, line_count)
  set_page_control_position(form, page_number)
  form.groupscrollbox_bagua.IsEditMode = false
end
function set_control_check_mlt_position(groupbox, rows, page_number, page, line_count)
  if page_number < page then
    return
  end
  local top = 10
  local row_space = 32
  for i = 0, line_count - 1 do
    local check_box_name = "check_box_" .. nx_string(i)
    local control = groupbox:Find(check_box_name)
    if nx_is_valid(control) then
      control.Top = top + i * row_space
    end
  end
end
function set_page_control_position(form, page_number)
  local control_width = page_number * (form.rbtn_page_1.Width + 5) + 2 * form.btn_left.Width
  local left_btn_left = nx_int((form.groupbox_page.Width - control_width) / 2)
  local left_radio = left_btn_left + form.btn_left.Width + 10
  form.btn_left.Left = left_btn_left
  for i = 1, page_number do
    if table_radio_page[i] ~= nil then
      table_radio_page[i].Visible = true
      table_radio_page[i].Left = left_radio
      left_radio = left_radio + table_radio_page[i].Width + 5
    end
  end
  form.btn_right.Left = left_radio + 5
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  local page = gossip_page - 1
  if 0 < page and table_radio_page[gossip_page - 1] ~= nil then
    table_radio_page[gossip_page - 1].Checked = true
  end
end
function on_btn_right_click(btn)
  if gossip_page >= gossip_page_number then
    return
  end
  local form = btn.ParentForm
  if table_radio_page[gossip_page + 1] ~= nil then
    table_radio_page[gossip_page + 1].Checked = true
  end
end
function on_btn_select_all_click(btn)
  local form = btn.ParentForm
  local check_box_number = table.getn(table_check_box)
  if check_box_number < 1 then
    return
  end
  local groupbox = form.groupbox_check_box
  local all_selected = check_data_all_selected(form)
  if all_selected == true then
    for i = 0, check_box_number - 1 do
      local check_box_name = "check_box_" .. nx_string(i)
      local control = groupbox:Find(check_box_name)
      if nx_is_valid(control) then
        control.Checked = false
      end
    end
  elseif all_selected == false then
    for i = 0, check_box_number - 1 do
      local check_box_name = "check_box_" .. nx_string(i)
      local control = groupbox:Find(check_box_name)
      if nx_is_valid(control) then
        control.Checked = true
      end
    end
  end
end
function on_btn_share_click(btn)
  local form = btn.ParentForm
  get_selected_check_box(form)
  if table.getn(table_selected) < 1 then
    return
  end
  share_gossip_info()
  if 1 == gossip_page then
    show_gossip_info(form, true, 1)
  else
    form.rbtn_page_1.Checked = true
  end
end
function on_btn_delete_click(btn)
  local form = btn.ParentForm
  get_selected_check_box(form)
  if table.getn(table_selected) < 1 then
    return
  end
  delete_gossip_info()
  bool_delete = true
  if 1 == gossip_page then
    show_gossip_info(form, false, 1)
  else
    form.rbtn_page_1.Checked = true
  end
end
function share_gossip_info()
  local bagua_id = ""
  local selected_number = table.getn(table_selected)
  if 1 <= selected_number then
    bagua_id = table_selected[1]
  end
  for i = 2, selected_number do
    bagua_id = table_selected[i] .. "|" .. bagua_id
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_share_gossip_info", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.name_edit.Text = gui.TextManager:GetText("ui_input")
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_search_return")
  if res == "ok" then
    if nx_string(text) == "" then
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BAGUA), 1, nx_widestr(text), bagua_id)
  end
end
function delete_gossip_info()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText(nx_string("ui_gossip_del")))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    table_selected = {}
    return
  end
  local bagua_id = ""
  local selected_number = table.getn(table_selected)
  if 1 <= selected_number then
    bagua_id = table_selected[1]
  end
  for i = 2, selected_number do
    bagua_id = table_selected[i] .. "|" .. bagua_id
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BAGUA), 2, "", bagua_id)
end
function get_selected_check_box(form)
  table_selected = {}
  local groupbox = form.groupbox_check_box
  if not nx_is_valid(groupbox) then
    return
  end
  local check_box_number = table.getn(table_check_box)
  if check_box_number < 1 then
    return
  end
  for i = 0, check_box_number - 1 do
    local check_box_name = "check_box_" .. nx_string(i)
    local control = groupbox:Find(check_box_name)
    if nx_is_valid(control) and control.Checked then
      table.insert(table_selected, table_check_box[i + 1])
    end
  end
  return
end
function check_data_all_selected(form)
  local check_box_number = table.getn(table_check_box)
  if check_box_number < 1 then
    return
  end
  local groupbox = form.groupbox_check_box
  for i = 0, check_box_number - 1 do
    local check_box_name = "check_box_" .. nx_string(i)
    local control = groupbox:Find(check_box_name)
    if nx_is_valid(control) and control.Checked == false then
      return false
    end
  end
  return true
end
function data_exist(table_data, data)
  if table.getn(table_data) < 1 then
    return false
  end
  for i, gossip_id in pairs(table_data) do
    if nx_string(data) == nx_string(gossip_id) then
      return true
    end
  end
  return false
end
function on_rbtn_tips_get_capture(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local x = rbtn.AbsLeft
  local y = rbtn.AbsTop
  local mltbox = form.mltbox_bagua_info
  local item_text = mltbox:GetHtmlItemText(nx_int(rbtn.TabIndex))
  local tip_text = nx_widestr(item_text)
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_rbtn_tips_lost_capture(rbtn)
  nx_execute("tips_game", "hide_tip")
end
function show_karma_groupbox(Repute, npc_ident)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_scene_obj = game_visual:GetSceneObj(nx_string(npc_ident))
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  if not nx_find_custom(visual_scene_obj, "balloon_name") then
    return
  end
  local ball = visual_scene_obj.balloon_name
  if not nx_is_valid(ball) then
    return
  end
  local groupbox_karma = ball.Control:Find("groupbox_karma")
  if not nx_is_valid(groupbox_karma) then
    return
  end
  groupbox_karma.Visible = true
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshDataAndPos(visual_scene_obj, false)
  end
end
