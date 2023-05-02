require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\form_relation\\relation_define")
local SHARE_CHANGGUAN_INI = "share\\War\\tiguan.ini"
local CHANGGUAN_UI_INI = "ini\\ui\\tiguan\\changguan.ini"
local TYPE_SCHOOL = 10
local TYPE_FAMILY = 11
local TYPE_GOV = 12
local TYPE_GROUP = 13
local TYPE_COMMON = 14
local MaxCharacterValue = 20
function init_shili(form)
  local root_node = form.tree_group.RootNode
  root_node = form.tree_group:CreateRootNode(nx_widestr(""))
  root_node.Mark = nx_int(-1)
  create_main_node(form, root_node, nx_widestr(util_text("ui_groupkarma_menpai")), nx_int(TYPE_SCHOOL))
  create_main_node(form, root_node, nx_widestr(util_text("ui_groupkarma_chaoting")), nx_int(TYPE_GOV))
  create_main_node(form, root_node, nx_widestr(util_text("ui_groupkarma_wulin")), nx_int(TYPE_FAMILY))
  create_main_node(form, root_node, nx_widestr(util_text("ui_groupkarma_jianghu")), nx_int(TYPE_GROUP))
  create_main_node(form, root_node, nx_widestr(util_text("ui_groupkarma_shijing")), nx_int(TYPE_COMMON))
  add_group(form)
  root_node:ExpandAll()
end
function create_main_node(form, root_node, text, mark)
  local main_node = root_node:CreateNode(nx_widestr(text))
  main_node.Mark = nx_int(mark)
  main_node.Font = "font_btn"
  main_node.type_string = nx_string(main_type) .. "-0"
  main_node.TextOffsetY = 4
  main_node.ItemHeight = 26
  main_node.NodeBackImage = "gui\\special\\sns_new\\tree_2_out.png"
  main_node.NodeFocusImage = "gui\\special\\sns_new\\tree_2_on.png"
  main_node.NodeSelectImage = "gui\\special\\sns_new\\tree_2_on.png"
  main_node.ExpandCloseOffsetX = 228
  main_node.ExpandCloseOffsetY = 8
  main_node.NodeOffsetY = 3
end
function create_sub_node(form, main_node, text, mark)
  local sub_node = main_node:CreateNode(nx_widestr(text))
  sub_node.Mark = nx_int(mark)
  sub_node.Font = "font_text"
  sub_node.NodeImageOffsetX = 30
  sub_node.TextOffsetX = 10
  sub_node.TextOffsetY = 2
  sub_node.NodeBackImage = "gui\\special\\sns_new\\tree_2_out.png"
  sub_node.NodeFocusImage = "gui\\special\\sns_new\\tree_2_on.png"
  sub_node.NodeSelectImage = "gui\\special\\sns_new\\tree_2_on.png"
end
function create_sub_node_2(form, main_node, text, mark)
  local sub_node = main_node:CreateNode(nx_widestr(text))
  sub_node.Mark = nx_int(mark)
  sub_node.Font = "font_text"
  sub_node.ForeColor = "255,255,255,255"
  sub_node.TextOffsetX = 15
  sub_node.TextOffsetY = 4
  sub_node.ItemHeight = 24
  sub_node.NodeOffsetY = 3
  sub_node.NodeFocusImage = "gui\\special\\sns_new\\tree_2_on.png"
  sub_node.NodeSelectImage = "gui\\special\\sns_new\\tree_2_on.png"
end
function add_group(form)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local strList = karmamgr:GetGroupList()
  local table_list = util_split_string(nx_string(strList), ";")
  local group_num = table.getn(table_list)
  if nx_number(group_num) <= 0 then
    return
  end
  local root_node = form.tree_group.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  for i = 1, group_num do
    local table_group = util_split_string(nx_string(table_list[i]), ",")
    if table.getn(table_group) == 2 then
      local id = table_group[1]
      local type = table_group[2]
      local main_node = nx_null()
      if nx_int(id) >= nx_int(SHILI_MIN) and nx_int(id) <= nx_int(SHILI_MAX) and is_relation_shili(id) then
        main_node = root_node:FindNodeByMark(nx_int(type))
        if nx_is_valid(main_node) then
          local news_num_text = ""
          local num = get_shili_news(id)
          if nx_number(num) ~= nx_number(0) then
            news_num_text = "  (" .. nx_string(num) .. ")"
          end
          create_sub_node_2(form, main_node, nx_widestr(util_text("group_karma_" .. nx_string(id))) .. nx_widestr(news_num_text), nx_int(id))
        end
      end
    end
  end
end
function add_group_info(form, group_id)
  form.lbl_name.Text = nx_widestr(util_text("group_karma_" .. nx_string(group_id)))
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local strInfo = karmamgr:GetGroupInfo(group_id)
  local table_info = util_split_string(nx_string(strInfo), ",")
  local scene_id = table_info[7]
  local tiguan_id = table_info[8]
  if nx_int(tiguan_id) ~= nx_int(0) then
    add_tiguan_info(form, tiguan_id)
    form.groupbox_tiguan.Visible = true
    send_msg_to_get_tiguan_info(tiguan_id)
  else
    form.lbl_png.BackImage = "gui\\special\\tiguan\\noloading.png"
    if 1 <= group_id and group_id <= 8 then
      form.lbl_png.BackImage = "gui\\special\\tiguan\\school_0" .. nx_string(group_id) .. ".png"
    end
    form.lbl_addr.Text = nx_widestr(util_text("ui_scene_" .. nx_string(scene_id)))
    form.groupbox_tiguan.Visible = false
  end
  form.mltbox_desc_ex.HtmlText = nx_widestr(util_text("group_karma_desc_" .. nx_string(group_id)))
  local karma = get_group_karma(group_id)
  form.lbl_haogandu.HintText = nx_widestr(util_text("desc_sns_groupkarma"))
  if karma == nil then
    form.lbl_gorup_karma.Text = get_karma_name(0, true)
    add_karma_shili_bar_info(form, 0, true)
  else
    form.lbl_gorup_karma.Text = get_karma_name(karma, true)
    add_karma_shili_bar_info(form, karma, true)
  end
  show_character(form, group_id)
  show_shili_news(form, group_id)
  add_npc(form, group_id)
  add_relation(form, group_id)
  form.groupbox_geren.Visible = false
  form.groupbox_desc.Visible = true
  nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "hide_form")
end
function send_msg_to_get_tiguan_info(tiguan_id)
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local player = game_client:GetPlayer()
    if nx_is_valid(player) then
      nx_execute("custom_sender", "custom_get_tiguan_one_info", nx_object(player.Ident), nx_int(tiguan_id))
    end
  end
end
function show_tiguan_count(type, ...)
  if type ~= 0 or table.getn(arg) < 4 then
    return 0
  end
  local form_shili = nx_value("form_stage_main\\form_relation\\form_relation_shili")
  if not nx_is_valid(form_shili) then
    return
  end
  if form_shili.groupbox_tiguan.Visible == false then
    return
  end
  local can_switch = nx_number(arg[1])
  local guan_id = nx_string(arg[2])
  local success_count = nx_number(arg[3])
  local today_count = nx_number(arg[4])
  local npc_info = nx_string(arg[5])
  form_shili.lbl_all_count.Text = nx_widestr(success_count)
  local LimitCountPerDay = 10
  if nx_find_custom(form_shili, "limit_count") then
    LimitCountPerDay = form_shili.limit_count
  end
  form_shili.lbl_today_count.Text = nx_widestr(today_count .. "/" .. nx_string(LimitCountPerDay))
end
function add_npc_info(form, npc_id, scene_id)
  form.lbl_npc_name.Text = nx_widestr(util_text(nx_string(npc_id)))
  form.lbl_npcaddr.Text = nx_widestr(util_text("ui_scene_" .. nx_string(scene_id)))
  local relation = get_npc_relation(npc_id)
  if relation == 0 then
    form.lbl_relation.Text = nx_widestr(util_text(nx_string("ui_haoyou_01")))
  elseif relation == 1 then
    form.lbl_relation.Text = nx_widestr(util_text(nx_string("ui_zhiyou_01")))
  elseif relation == 2 then
    form.lbl_relation.Text = nx_widestr(util_text(nx_string("ui_guanzhu_01")))
  else
    form.lbl_relation.Text = nx_widestr(util_text(nx_string("ui_putong_01")))
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local Story = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Story"))
  local desc = util_text("ui_sns_npc_nomess")
  if "" ~= Story then
    desc = util_text(Story)
  end
  form.mltbox_desc_ex.HtmlText = nx_widestr(desc)
  local karma = get_npc_karma(npc_id)
  form.lbl_haogandu.HintText = nx_widestr(util_text("desc_sns_npckarma"))
  if karma == nil then
    form.lbl_gorup_karma.Text = get_karma_name(0, false)
    add_karma_npc_bar_info(form, 0, false)
  else
    form.lbl_gorup_karma.Text = get_karma_name(karma, false)
    add_karma_npc_bar_info(form, karma, false)
  end
  local CharacterFlag = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Character")))
  show_character_info(form, CharacterFlag, 100)
  form.lbl_news.Visible = false
  form.lbl_news_num.Visible = false
  form.groupbox_geren.Visible = true
  form.groupbox_desc.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "show_form", form, nx_string(npc_id))
end
function add_karma_shili_bar_info(form, value, grouped)
  local min_val, max_val, name, pic = get_karma_msg_config(value, grouped)
  form.lbl_karma_mark.BackImage = pic
  form.lbl_karma_shili_bar.Visible = true
  form.lbl_karma_npc_bar.Visible = false
  value = nx_int(value)
  local len = max_val - min_val
  local reality = value - min_val
  form.lbl_karma_mark.Left = form.lbl_karma_shili_bar.Left + (reality / len * form.lbl_karma_shili_bar.Width - form.lbl_karma_mark.Width / 2)
  form.lbl_karma_shili_bar.HintText = nx_widestr(util_text("ui_presentkarma")) .. nx_widestr(util_text(name))
end
function add_karma_npc_bar_info(form, value, grouped)
  local min_val, max_val, name, pic = get_karma_msg_config(value, grouped)
  form.lbl_karma_mark.BackImage = pic
  form.lbl_karma_shili_bar.Visible = false
  form.lbl_karma_npc_bar.Visible = true
  value = nx_int(value)
  local len = max_val - min_val
  local reality = value - min_val
  form.lbl_karma_mark.Left = form.lbl_karma_npc_bar.Left + (reality / len * form.lbl_karma_npc_bar.Width - form.lbl_karma_mark.Width / 2)
  form.lbl_karma_npc_bar.HintText = nx_widestr(util_text("ui_presentkarma")) .. nx_widestr(util_text(name))
end
function get_karma_name(value, grouped)
  value = nx_int(value)
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return nx_widestr("")
  end
  local sec_index = -1
  if grouped then
    sec_index = ini:FindSectionIndex("GroupKarma")
  else
    sec_index = ini:FindSectionIndex("Karma")
  end
  ini:FindSectionIndex("GroupKarma")
  if sec_index < 0 then
    return nx_widestr("")
  end
  local gui = nx_value("gui")
  local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(GroupMsgData)) do
    local stepData = util_split_string(GroupMsgData[i], ",")
    if value >= nx_int(stepData[1]) and value <= nx_int(stepData[2]) then
      return gui.TextManager:GetText(nx_string(stepData[3]))
    end
  end
  return nx_widestr("")
end
function is_group(node, mark)
  local level = node.Level
  if nx_number(level) == nx_number(3) then
    return true
  end
  if nx_number(level) == nx_number(2) and (nx_number(mark) < nx_number(1) or nx_number(mark) > nx_number(8)) then
    return true
  end
  return false
end
function get_group_karma(group_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  if not client_player:FindRecord("GroupKarmaRec") then
    return nil
  end
  local row = client_player:FindRecordRow("GroupKarmaRec", 0, nx_int(group_id), 0)
  if row < 0 then
    return nil
  end
  local karma_value = nx_int64(client_player:QueryRecord("GroupKarmaRec", row, 1))
  return nx_int(karma_value)
end
function show_character(form, id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local strInfo = karmamgr:GetGroupInfo(id)
  local table_info = util_split_string(nx_string(strInfo), ",")
  local num = table.getn(table_info)
  if nx_number(num) < 6 then
    return
  end
  local CharacterFlag, CharacterValue = get_karma_character(table_info[3], table_info[4], table_info[5], table_info[6])
  show_character_info(form, CharacterFlag, CharacterValue)
end
function show_character_info(form, CharacterFlag, CharacterValue)
  local gui = nx_value("gui")
  form.lbl_kuang.Top = 40
  form.lbl_kuang.Left = 87
  form.lbl_xie.Top = 40
  form.lbl_xie.Left = 58
  if CharacterFlag == 0 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
  elseif CharacterFlag == 1 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = true
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_colour.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xia_bar.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 2 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_e.png"
    form.lbl_e_bar.Visible = true
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_colour.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_e_bar.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 3 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_kuang.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = true
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_colour.png"
    form.lbl_kuang.Top = 16
    form.lbl_kuang.Left = 72
    form.lbl_kuang_bar.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_kuang_bar.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 4 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xie.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = true
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_colour.png"
    form.lbl_xie.Top = 16
    form.lbl_xie.Left = 72
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xie_bar.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_xie_bar.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  end
end
function get_player_character(justice, evil, freejustice, freeevil)
  return get_character(justice, evil, freejustice, freeevil)
end
function get_karma_character(shan_e, kuang_xie)
  shan_e = nx_number(shan_e)
  kuang_xie = nx_number(kuang_xie)
  local justice = 0
  local evil = 0
  local freejustice = 0
  local freeevil = 0
  if shan_e == 0 then
    justice = 0
    evil = 0
  elseif 0 < shan_e then
    justice = shan_e
    evil = 0
  elseif shan_e < 0 then
    justice = 0
    evil = shan_e * -1
  end
  if kuang_xie == 0 then
    freejustice = 0
    freeevil = 0
  elseif 0 < kuang_xie then
    freejustice = kuang_xie
    freeevil = 0
  elseif kuang_xie < 0 then
    freejustice = 0
    freeevil = kuang_xie * -1
  end
  return get_character(justice, evil, freejustice, freeevil)
end
function get_character(justice, evil, freejustice, freeevil)
  if nx_int(justice) == nx_int(evil) then
    if nx_int(freejustice) > nx_int(freeevil) then
      return 3, nx_int(freejustice)
    elseif nx_int(freeevil) > nx_int(freejustice) then
      return 4, nx_int(freeevil)
    end
    return 0, nx_int(0)
  end
  if nx_int(justice) > nx_int(evil) then
    if nx_int(justice) >= nx_int(freejustice) then
      return 1, nx_int(justice)
    else
      return 3, nx_int(freejustice)
    end
  end
  if nx_int(evil) > nx_int(justice) then
    if nx_int(evil) >= nx_int(freeevil) then
      return 2, nx_int(evil)
    else
      return 4, nx_int(freeevil)
    end
  end
  return 0, nx_int(0)
end
function add_npc(form, id)
  local gui = nx_value("gui")
  form.groupbox_npc:DeleteAll()
  form.groupbox_npc.group_id = id
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local strNpcList = karmamgr:GetGroupNpc(nx_int(id))
  local table_npc = util_split_string(nx_string(strNpcList), ";")
  local npc_num = table.getn(table_npc)
  if nx_number(npc_num) <= 0 then
    return
  end
  local gb_width = 0
  local gb_height = 0
  for i = 1, npc_num do
    local table_npc_info = util_split_string(nx_string(table_npc[i]), ",")
    local num = table.getn(table_npc_info)
    if nx_number(num) >= 5 then
      local gb_npc = gui:Create("GroupBox")
      gb_npc.Width = 180
      gb_npc.Height = 65
      gb_npc.BackColor = "0,0,0,0"
      gb_npc.NoFrame = true
      gb_npc.Name = nx_string(table_npc_info[1])
      gb_npc.Scene = nx_string(table_npc_info[3])
      gb_npc.Level = nx_string(table_npc_info[2])
      local CharacterFlag = ItemQuery:GetItemPropByConfigID(nx_string(table_npc_info[1]), nx_string("Character"))
      local lbl_xia = gui:Create("Label")
      lbl_xia.AutoSize = true
      lbl_xia.Left = -2
      lbl_xia.Top = 2
      if nx_number(CharacterFlag) == nx_number(1) then
        lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_colour.png"
      elseif nx_number(CharacterFlag) == nx_number(2) then
        lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_colour.png"
      elseif nx_number(CharacterFlag) == nx_number(3) then
        lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_colour.png"
      elseif nx_number(CharacterFlag) == nx_number(4) then
        lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_colour.png"
      else
        lbl_xia.Width = 23
      end
      gb_npc:Add(lbl_xia)
      local lbl_head = gui:Create("Label")
      lbl_head.AutoSize = true
      lbl_head.Left = lbl_xia.Width - 15
      lbl_head.Top = 12
      lbl_head.BackImage = "gui\\mainform\\icon_skill.png"
      gb_npc:Add(lbl_head)
      local ItemQuery = nx_value("ItemQuery")
      if not nx_is_valid(ItemQuery) then
        return
      end
      local photo = ItemQuery:GetItemPropByConfigID(nx_string(table_npc_info[1]), nx_string("Photo"))
      if photo == "" then
        photo = "gui\\special\\sns_new\\sns_head\\common_head.png"
      end
      local lbl_head_pic = gui:Create("Label")
      lbl_head_pic.Top = 2
      lbl_head_pic.Left = lbl_head.Left + 2
      lbl_head_pic.Width = 44
      lbl_head_pic.Height = 46
      lbl_head_pic.BackImage = photo
      lbl_head_pic.DrawMode = "FitWindow"
      lbl_head_pic.Transparent = false
      lbl_head_pic.ClickEvent = true
      nx_bind_script(lbl_head_pic, nx_script_name(form))
      gb_npc:Add(lbl_head_pic)
      local lbl_karma_fstip = gui:Create("Label")
      lbl_karma_fstip.Top = 30
      lbl_karma_fstip.Left = lbl_xia.Width - 16
      lbl_karma_fstip.Width = 50
      lbl_karma_fstip.Height = 27
      lbl_karma_fstip.BackImage = "gui\\special\\sns_new\\icon_feeling.png"
      gb_npc:Add(lbl_karma_fstip)
      local lbl_karma_face = gui:Create("Label")
      lbl_karma_face.Top = 45
      lbl_karma_face.Left = 28
      lbl_karma_face.Width = 14
      lbl_karma_face.Height = 18
      lbl_karma_face.BackImage = "gui\\special\\sns_new\\icon_feeling_tou.png"
      lbl_karma_face.DrawMode = "FitWindow"
      gb_npc:Add(lbl_karma_face)
      local karma_value = get_npc_karma(nx_string(table_npc_info[1]))
      if karma_value == nil then
        karma_value = 0
      end
      nx_execute("form_stage_main\\form_relationship", "set_karma_groupbox", lbl_karma_fstip, lbl_karma_face, karma_value)
      local btn_npc = gui:Create("Button")
      btn_npc.Name = "btn_npc" .. nx_string(table_npc_info[1])
      btn_npc.Left = lbl_head.Left + lbl_head.Width - 5
      btn_npc.Top = 2
      btn_npc.Width = 126
      btn_npc.Height = 55
      btn_npc.NormalImage = ""
      btn_npc.FocusImage = "gui\\special\\sns_new\\bg_event_on.png"
      btn_npc.PushImage = "gui\\special\\sns_new\\bg_event_on.png"
      btn_npc.DrawMode = "FitWindow"
      btn_npc.LineColor = "0,0,0,0"
      btn_npc.BackColor = "0,0,0,0"
      nx_bind_script(btn_npc, nx_script_name(form))
      nx_callback(btn_npc, "on_right_click", "on_btn_npc_right_click")
      gb_npc:Add(btn_npc)
      local gb_npc_info = gui:Create("GroupBox")
      gb_npc_info.Top = 5
      gb_npc_info.Left = lbl_head.Left + lbl_head.Width
      gb_npc_info.Width = 116
      gb_npc_info.Height = 48
      gb_npc_info.BackImage = "gui\\special\\sns_new\\bg_event.png"
      gb_npc_info.DrawMode = "Expand"
      gb_npc_info.Transparent = true
      gb_npc_info.Name = "gb_npc_info" .. nx_string(table_npc_info[1])
      local lbl_npc_name = gui:Create("Label")
      lbl_npc_name.Name = "lbl_npc_name" .. nx_string(table_npc_info[1])
      lbl_npc_name.Left = 4
      lbl_npc_name.Top = 2
      lbl_npc_name.Width = 65
      lbl_npc_name.Height = 20
      lbl_npc_name.Text = nx_widestr(util_text(nx_string(table_npc_info[1])))
      lbl_npc_name.Font = "font_sns_main_1"
      lbl_npc_name.ForeColor = "255,255,255,255"
      lbl_npc_name.Transparent = true
      gb_npc_info:Add(lbl_npc_name)
      local lbl_npc_title = gui:Create("Label")
      lbl_npc_title.Name = "lbl_npc_title" .. nx_string(table_npc_info[1])
      lbl_npc_title.Left = 4
      lbl_npc_title.Top = 24
      lbl_npc_title.Width = 65
      lbl_npc_title.Height = 20
      lbl_npc_title.Font = "font_sns_main_1"
      lbl_npc_title.ForeColor = "255,214,204,191"
      lbl_npc_title.Transparent = true
      if nx_string(util_text(nx_string(table_npc_info[1]) .. "_1")) ~= nx_string(table_npc_info[1]) .. "_1" then
        lbl_npc_title.Text = nx_widestr(util_text(nx_string(table_npc_info[1]) .. "_1"))
      end
      gb_npc_info:Add(lbl_npc_title)
      local npc_news_num = get_npc_news(table_npc_info[1])
      local lbl_news_num = gui:Create("Label")
      lbl_news_num.Name = "lbl_news_num_" .. nx_string(table_npc_info[1])
      lbl_news_num.Top = 25
      lbl_news_num.Left = lbl_npc_title.Width + 10
      lbl_news_num.AutoSize = true
      lbl_news_num.BackImage = "gui\\special\\sns_new\\btn_enchou_price\\icon_prompt_03.png"
      lbl_news_num.Text = nx_widestr(npc_news_num)
      lbl_news_num.Align = "Center"
      lbl_news_num.Font = "font_system_news"
      lbl_news_num.ForeColor = "255,255,255,255"
      gb_npc_info:Add(lbl_news_num)
      if npc_news_num == nx_int(0) then
        lbl_news_num.Visible = false
      end
      local lbl_is_friend = gui:Create("Label")
      lbl_is_friend.AutoSize = false
      lbl_is_friend.Name = "lbl_is_friend" .. nx_string(table_npc_info[1])
      lbl_is_friend.Left = lbl_npc_title.Width + 10
      lbl_is_friend.Top = 2
      lbl_is_friend.Width = 35
      lbl_is_friend.Height = 20
      lbl_is_friend.Align = "Right"
      lbl_is_friend.Font = "font_sns_main_2"
      lbl_is_friend.ForeColor = "255,214,204,191"
      lbl_is_friend.Transparent = true
      local relation = get_npc_relation(table_npc_info[1])
      if relation == 0 then
        lbl_is_friend.Text = nx_widestr(util_text(nx_string("ui_haoyou_01")))
      elseif relation == 1 then
        lbl_is_friend.Text = nx_widestr(util_text(nx_string("ui_zhiyou_01")))
      elseif relation == 2 then
        lbl_is_friend.Text = nx_widestr(util_text(nx_string("ui_guanzhu_01")))
      else
        lbl_is_friend.Text = nx_widestr(util_text(nx_string("ui_putong_01")))
      end
      gb_npc_info:Add(lbl_is_friend)
      gb_npc:Add(gb_npc_info)
      local lbl_select = gui:Create("Label")
      lbl_select.Name = "lbl_select" .. nx_string(table_npc_info[1])
      lbl_select.Left = lbl_head.Left + lbl_head.Width - 5
      lbl_select.Top = 2
      lbl_select.Width = 126
      lbl_select.Height = 55
      lbl_select.BackImage = ""
      lbl_select.DrawMode = "FitWindow"
      gb_npc:Add(lbl_select)
      if nx_int(id) <= nx_int(SHILI_MAX) then
        if relation == -2 then
          lbl_xia.Visible = false
          lbl_head_pic.BackImage = "gui\\special\\sns_new\\sns_head\\unco_head.png"
          lbl_karma_fstip.Visible = false
          lbl_karma_face.Visible = false
        else
          nx_callback(btn_npc, "on_left_double_click", "on_btn_npc_left_double_click")
          nx_callback(lbl_head_pic, "on_left_double_click", "on_btn_npc_left_double_click")
        end
      else
        local is_jindi = nx_execute("form_stage_main\\form_relation\\form_clone_describe", "get_show_clonenpc_model", nx_int(id))
        if is_jindi == false then
          lbl_xia.Visible = false
          lbl_head_pic.BackImage = "gui\\special\\sns_new\\sns_head\\unco_head.png"
          lbl_karma_fstip.Visible = false
          lbl_karma_face.Visible = false
        else
          nx_callback(btn_npc, "on_left_double_click", "on_btn_npc_left_double_click")
          nx_callback(lbl_head_pic, "on_left_double_click", "on_btn_npc_left_double_click")
        end
      end
      gb_npc.selected = false
      nx_bind_script(gb_npc, nx_script_name(form))
      nx_callback(gb_npc, "on_get_capture", "on_gb_get_capture")
      nx_callback(gb_npc, "on_lost_capture", "on_gb_lost_capture")
      nx_callback(gb_npc, "on_left_double_click", "on_gb_left_double_click")
      form.groupbox_npc:Add(gb_npc)
      gb_npc.Left = nx_number(table_npc_info[4])
      gb_npc.Top = nx_number(table_npc_info[5])
      gb_width = math.max(gb_width, nx_number(table_npc_info[4]) + gb_npc.Width)
      gb_height = math.max(gb_height, nx_number(table_npc_info[5]) + gb_npc.Height)
    end
  end
  form.groupbox_npc.Width = gb_width
  form.groupbox_npc.Height = gb_height
  form.groupbox_npc.Left = -form.groupbox_npc.Width
end
function add_relation(form, id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local strRelation = karmamgr:GetNpcRelation(nx_int(id))
  local table_relation = util_split_string(nx_string(strRelation), "|")
  local num = table.getn(table_relation)
  if nx_number(num) <= 0 then
    return
  end
  for i = 1, num do
    local table_para = util_split_string(nx_string(table_relation[i]), "/")
    local para_num = table.getn(table_para)
    if nx_number(para_num) == 3 then
      local relation = table_para[1]
      local relation_pos = table_para[2]
      local line_pos = table_para[3]
      add_line(form, nx_string(line_pos))
    end
  end
end
function add_line(form, strLine)
  local table_pos = util_split_string(nx_string(strLine), ";")
  local num = table.getn(table_pos)
  if nx_number(num) <= 0 then
    return
  end
  local table_x = {}
  local table_y = {}
  for i = 1, num do
    local table_xy = util_split_string(nx_string(table_pos[i]), ",")
    if table.getn(table_xy) == 2 then
      table.insert(table_x, table_xy[1])
      table.insert(table_y, table_xy[2])
    end
  end
  local num_x = table.getn(table_x)
  local num_y = table.getn(table_y)
  if nx_number(num_x) ~= nx_number(num_y) then
    return
  end
  for j = 1, num_x do
    if 1 < j then
      format_line(form, table_x[j - 1], table_y[j - 1], table_x[j], table_y[j])
    end
  end
end
function format_line(form, x1, y1, x2, y2)
  local gui = nx_value("gui")
  local add_complete = false
  local lbl_line = gui:Create("Label")
  lbl_line.AutoSize = false
  lbl_line.BackImage = "gui\\special\\sns_new\\line_relation1.png"
  lbl_line.DrawMode = "ExpandH"
  lbl_line.Width = 2
  lbl_line.Height = 2
  if nx_number(x1) == nx_number(x2) then
    lbl_line.Height = math.abs(nx_number(y2) - nx_number(y1))
    form.groupbox_npc:Add(lbl_line)
    lbl_line.Left = nx_number(x1)
    if nx_number(y1) > nx_number(y2) then
      lbl_line.Top = nx_number(y2)
    else
      lbl_line.Top = nx_number(y1)
    end
    add_complete = true
  else
    lbl_line.Width = math.abs(nx_number(x2) - nx_number(x1)) + nx_number(lbl_line.Height)
    form.groupbox_npc:Add(lbl_line)
    lbl_line.Top = nx_number(y1)
    if nx_number(x1) > nx_number(x2) then
      lbl_line.Left = nx_number(x2)
    else
      lbl_line.Left = nx_number(x1)
    end
    add_complete = true
  end
  if not add_complete then
    nx_destroy(lbl_line)
  end
end
function get_npc_karma(npc_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  if not client_player:FindRecord("rec_npc_relation") then
    return nil
  end
  local row = client_player:FindRecordRow("rec_npc_relation", 0, npc_id, 0)
  if row < 0 then
    return nil
  end
  local karma = nx_int(client_player:QueryRecord("rec_npc_relation", row, 2))
  return karma
end
function add_tiguan_info(form, tiguan_id)
  local gui = nx_value("gui")
  local changguanini = nx_execute("util_functions", "get_ini", nx_string(CHANGGUAN_UI_INI))
  local sharecgini = nx_execute("util_functions", "get_ini", nx_string(SHARE_CHANGGUAN_INI))
  if not nx_is_valid(changguanini) or not nx_is_valid(sharecgini) then
    return
  end
  local section_index_1 = changguanini:FindSectionIndex(nx_string(tiguan_id))
  local section_index_2 = sharecgini:FindSectionIndex(nx_string(tiguan_id))
  if section_index_1 < 0 or section_index_2 < 0 then
    return
  end
  local name = util_text("ui_tiguan_name_" .. tiguan_id)
  local photo = changguanini:ReadString(section_index_1, "Photo", "")
  form.lbl_png.BackImage = photo
  local address = util_text("ui_tiguan_addr_" .. tiguan_id)
  form.lbl_addr.Text = nx_widestr(address)
  form.lbl_12.Visible = false
  form.lbl_lev.Visible = false
  local minplayer = sharecgini:ReadString(section_index_2, "MinPlayerCount", "")
  local maxplayer = sharecgini:ReadString(section_index_2, "MaxPlayerCount", "")
  local condition = sharecgini:ReadString(section_index_2, "MemberConditionID", "")
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return 0
  end
  form.mltbox_cdt:Clear()
  local cdt_tab = util_split_string(nx_string(condition), ";")
  for j = 1, table.getn(cdt_tab) do
    local condition_desc = util_text(nx_string(cdt_mgr:GetConditionDesc(nx_int(cdt_tab[j]))))
    if check_iscan_enter(condition) then
      form.mltbox_cdt:AddHtmlText(nx_widestr("<font color=\"#008000\">") .. nx_widestr(condition_desc) .. nx_widestr("</font>"), -1)
    else
      form.mltbox_cdt:AddHtmlText(nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(condition_desc) .. nx_widestr("</font>"), -1)
    end
  end
  local counttxt = gui.TextManager:GetFormatText("ui_tiguan_players_const", nx_int(minplayer))
  if minplayer ~= maxplayer then
    counttxt = gui.TextManager:GetFormatText("ui_tiguan_players_minmax", nx_int(minplayer), nx_int(maxplayer))
  end
  form.lbl_count.Text = nx_widestr(counttxt)
  local difficult = sharecgini:ReadString(section_index_2, "Difficult", "")
  form.lbl_diff.Text = nx_widestr(difficult)
  local LimitCountPerDay = sharecgini:ReadString(section_index_2, "LimitCountPerDay", "")
  form.limit_count = LimitCountPerDay
end
function check_iscan_enter(conditions_id)
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local cdt_tab = util_split_string(nx_string(conditions_id), ";")
  for i = 1, table.getn(cdt_tab) do
    if not cdt_mgr:CanSatisfyCondition(player, player, nx_int(cdt_tab[i])) then
      return false
    end
  end
  return true
end
function get_npc_relation(npc_id)
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return -2
  end
  if not player:FindRecord("rec_npc_relation") and not player:FindRecord("rec_npc_attention") then
    return -2
  end
  local rows_1 = player:GetRecordRows("rec_npc_relation")
  local rows_2 = player:GetRecordRows("rec_npc_attention")
  if rows_1 == 0 and rows_2 == 0 then
    return -2
  end
  local row = player:FindRecordRow("rec_npc_relation", 0, nx_string(npc_id), 0)
  if 0 <= row then
    local relation = player:QueryRecord("rec_npc_relation", row, 3)
    if relation ~= 0 and relation ~= 1 then
      if 0 <= player:FindRecordRow("rec_npc_attention", 0, nx_string(npc_id), 0) then
        return 2
      else
        return -1
      end
    else
      return relation
    end
  end
  if 0 <= player:FindRecordRow("rec_npc_attention", 0, nx_string(npc_id), 0) then
    return 2
  end
  return -2
end
function show_shili_news(form, shili_id)
  if not nx_is_valid(form) then
    return
  end
  local news_count = get_shili_news(shili_id)
  if nx_int(news_count) == nx_int(0) then
    form.lbl_news.Visible = false
    form.lbl_news_num.Visible = false
  else
    form.lbl_news.Visible = true
    form.lbl_news_num.Visible = true
    form.lbl_news_num.Text = nx_widestr("" .. news_count)
  end
end
function show_npc_news(form, npc_id)
  if not nx_is_valid(form) then
    return
  end
  local news_count = get_npc_news(npc_id)
  if nx_int(news_count) == nx_int(0) then
    form.lbl_news.Visible = false
    form.lbl_news_num.Visible = false
  else
    form.lbl_news.Visible = true
    form.lbl_news_num.Visible = true
    form.lbl_news_num.Text = nx_widestr("" .. nx_string(news_count))
  end
end
function refersh_npc_news_num(form_shili, shili_id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local strNpcList = karmamgr:GetGroupNpc(nx_int(shili_id))
  local table_npc = util_split_string(nx_string(strNpcList), ";")
  local npc_num = table.getn(table_npc)
  if nx_number(npc_num) == nx_number(0) then
    return
  end
  for i = 1, npc_num do
    local table_npc_info = util_split_string(nx_string(table_npc[i]), ",")
    local npc_id = table_npc_info[1]
    local npc_news_num = get_npc_news(npc_id)
    local gb_npc = form_shili.groupbox_npc:Find(nx_string(npc_id))
    if nx_is_valid(gb_npc) then
      local gb_npc_info = gb_npc:Find("gb_npc_info" .. npc_id)
      if nx_is_valid(gb_npc_info) then
        local lbl_npc_news_num = gb_npc_info:Find("lbl_news_num_" .. npc_id)
        if nx_is_valid(lbl_npc_news_num) then
          if nx_number(npc_news_num) < nx_number(1) then
            lbl_npc_news_num.Visible = false
          else
            lbl_npc_news_num.Visible = true
            lbl_npc_news_num.Text = nx_widestr("" .. nx_string(npc_news_num))
          end
        end
      end
    end
  end
end
function get_shili_news(shili_id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return 0
  end
  local strNpcList = karmamgr:GetGroupNpc(nx_int(shili_id))
  local table_npc = util_split_string(nx_string(strNpcList), ";")
  local npc_num = table.getn(table_npc)
  if nx_number(npc_num) == nx_number(0) then
    return 0
  end
  local news_count = 0
  for i = 1, npc_num do
    local table_npc_info = util_split_string(nx_string(table_npc[i]), ",")
    local count = get_npc_news(table_npc_info[1])
    news_count = news_count + count
  end
  return news_count
end
function get_npc_news(npc_id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return 0
  end
  local res_list = karmamgr:GetNpcPrize(nx_string(npc_id))
  local news_count = nx_number(table.getn(res_list)) / 3
  return nx_int(news_count)
end
function is_relation_shili(shili_id)
  if nx_execute("form_stage_main\\form_relationship", "is_unopened_shili", shili_id) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindRecord("GroupKarmaRec") then
    local row = client_player:FindRecordRow("GroupKarmaRec", 0, nx_int(shili_id), 0)
    if 0 <= row then
      return true
    end
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return false
  end
  local npc_list_id = karmamgr:GetActiveGroupNpcNameList(nx_int(shili_id))
  if 0 < table.getn(npc_list_id) then
    return true
  end
  return false
end
