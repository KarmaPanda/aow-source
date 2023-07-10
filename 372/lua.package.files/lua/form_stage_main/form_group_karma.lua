require("util_gui")
require("util_functions")
require("custom_sender")
local TYPE_SCHOOL = 10
local TYPE_FAMILY = 11
local TYPE_GOV = 12
local TYPE_GROUP = 13
local TYPE_COMMON = 14
local MaxCharacterValue = 20
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  init_form(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function init_form(form)
  local root_node = form.tree_group.RootNode
  if not nx_is_valid(root_node) then
    root_node = form.tree_group:CreateRootNode(nx_widestr(""))
  end
  root_node.Mark = nx_int(-1)
  create_main_node(form, root_node, util_text("ui_groupkarma_menpai"), nx_int(TYPE_SCHOOL))
  create_main_node(form, root_node, util_text("ui_groupkarma_wulin"), nx_int(TYPE_FAMILY))
  create_main_node(form, root_node, util_text("ui_groupkarma_chaoting"), nx_int(TYPE_GOV))
  create_main_node(form, root_node, util_text("ui_groupkarma_jianghu"), nx_int(TYPE_GROUP))
  create_main_node(form, root_node, util_text("ui_groupkarma_shijing"), nx_int(TYPE_COMMON))
  add_group(form)
  root_node:ExpandAll()
  add_group_info(form, nx_int(1))
  add_npc(form, nx_int(1))
end
function create_main_node(form, root_node, text, mark)
  local main_node = root_node:CreateNode(nx_widestr(text))
  main_node.Mark = nx_int(mark)
  main_node.Font = "font_treeview"
  main_node.ForeColor = "255,255,153,0"
  main_node.ItemHeight = 30
  main_node.NodeBackImage = "gui\\common\\treeview\\tree_1_out.png"
  main_node.NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png"
  main_node.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
  main_node.ExpandCloseOffsetX = 0
  main_node.ExpandCloseOffsetY = 6
  main_node.TextOffsetX = 10
  main_node.TextOffsetY = 7
  main_node.NodeOffsetY = -5
  if nx_int(mark) == nx_int(TYPE_SCHOOL) then
    create_sub_node(form, main_node, util_text("ui_groupkarma_menpai_1"), nx_int(1))
    create_sub_node(form, main_node, util_text("ui_groupkarma_menpai_2"), nx_int(2))
    create_sub_node(form, main_node, util_text("ui_groupkarma_menpai_3"), nx_int(3))
    create_sub_node(form, main_node, util_text("ui_groupkarma_menpai_4"), nx_int(4))
    create_sub_node(form, main_node, util_text("ui_groupkarma_menpai_5"), nx_int(5))
    create_sub_node(form, main_node, util_text("ui_groupkarma_menpai_6"), nx_int(6))
    create_sub_node(form, main_node, util_text("ui_groupkarma_menpai_7"), nx_int(7))
    create_sub_node(form, main_node, util_text("ui_groupkarma_menpai_8"), nx_int(8))
  end
end
function create_sub_node(form, main_node, text, mark)
  local sub_node = main_node:CreateNode(nx_widestr(text))
  sub_node.Mark = nx_int(mark)
  sub_node.Font = "font_text"
  sub_node.NodeImageOffsetX = 30
  sub_node.TextOffsetX = 10
  sub_node.TextOffsetY = 2
  sub_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
  sub_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
  sub_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
end
function create_sub_node_2(form, main_node, text, mark)
  local sub_node = main_node:CreateNode(nx_widestr(text))
  sub_node.Mark = nx_int(mark)
  sub_node.Font = "font_text"
  sub_node.NodeImageOffsetX = 30
  sub_node.TextOffsetX = 30
  sub_node.TextOffsetY = 2
  sub_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
  sub_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
  sub_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
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
      if nx_int(type) >= nx_int(1) and nx_int(type) <= nx_int(8) then
        local node_school = root_node:FindNodeByMark(nx_int(TYPE_SCHOOL))
        if nx_is_valid(node_school) then
          main_node = node_school:FindNodeByMark(nx_int(type))
        end
      else
        main_node = root_node:FindNodeByMark(nx_int(type))
      end
      if nx_is_valid(main_node) then
        create_sub_node_2(form, main_node, util_text("group_karma_" .. nx_string(id)), nx_int(id))
      end
    end
  end
end
function on_tree_group_select_changed(tree, node)
  local form = tree.ParentForm
  if not is_group(node, node.Mark) then
    return false
  end
  add_group_info(form, nx_int(node.Mark))
  add_npc(form, nx_int(node.Mark))
end
function add_group_info(form, group_id)
  form.lbl_name.Text = nx_widestr(util_text("group_karma_" .. nx_string(group_id)))
  form.mltbox_desc.HtmlText = nx_widestr(util_text("group_karma_desc_" .. nx_string(group_id)))
  local karma = get_group_karma(group_id)
  if karma == nil then
    form.pbar_karma.Value = 0
    form.lbl_karma.Text = nx_widestr(util_text("ui_weijihuo"))
  else
    form.pbar_karma.Value = nx_int(karma) + nx_int(100000)
    form.lbl_karma.Text = nx_widestr(karma)
  end
  show_character(form, group_id)
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
  local karma_base = nx_int64(client_player:QueryRecord("GroupKarmaRec", row, 2))
  local karma_ex = client_player:QueryRecord("GroupKarmaRec", row, 3)
  return nx_int(karma_base) + nx_int(karma_ex)
end
function show_character(form, id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local strInfo = karmamgr:GetGroupInfo(id)
  local table_info = util_split_string(nx_string(strInfo), ",")
  local num = table.getn(table_info)
  if nx_number(num) ~= 6 then
    return
  end
  local CharacterFlag, CharacterValue = get_character(table_info[3], table_info[4], table_info[5], table_info[6])
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
  for i = 1, npc_num do
    local table_npc_info = util_split_string(nx_string(table_npc[i]), ",")
    local num = table.getn(table_npc_info)
    if nx_number(num) == 5 then
      local gb_npc = gui:Create("GroupBox")
      gb_npc.AutoSize = false
      gb_npc.Width = 120
      gb_npc.Height = 60
      gb_npc.BackImage = "gui\\common\\form_back\\bg_list3.png"
      gb_npc.DrawMode = "Expand"
      gb_npc.Name = nx_string(table_npc_info[1])
      gb_npc.Scene = nx_string(table_npc_info[2])
      gb_npc.Level = nx_string(table_npc_info[3])
      local lbl_npc = gui:Create("Label")
      lbl_npc.AutoSize = false
      lbl_npc.Width = 120
      lbl_npc.Height = 30
      lbl_npc.Align = "Center"
      lbl_npc.Font = "Default"
      lbl_npc.Name = "lbl_" .. nx_string(table_npc_info[1])
      local name_title = util_text(nx_string(table_npc_info[1]) .. "_1")
      if nx_string(name_title) == nx_string(table_npc_info[1]) .. "_1" then
        lbl_npc.Text = nx_widestr(util_text(nx_string(table_npc_info[1])))
      else
        lbl_npc.Text = nx_widestr(util_text(nx_string(table_npc_info[1]))) .. nx_widestr("(") .. nx_widestr(name_title) .. nx_widestr(")")
      end
      gb_npc:Add(lbl_npc)
      local lbl_karma = gui:Create("Label")
      lbl_karma.AutoSize = false
      lbl_karma.Width = 120
      lbl_karma.Height = 30
      lbl_karma.Align = "Center"
      lbl_karma.Font = "Default"
      lbl_karma.Name = "lbl_karma_" .. nx_string(table_npc_info[1])
      lbl_karma.Text = nx_widestr(util_text("ui_weijihuo"))
      gb_npc:Add(lbl_karma)
      lbl_karma.Top = 30
      nx_bind_script(gb_npc, nx_current())
      nx_callback(gb_npc, "on_get_capture", "on_gb_get_capture")
      nx_callback(gb_npc, "on_lost_capture", "on_gb_lost_capture")
      form.groupbox_npc:Add(gb_npc)
      gb_npc.Left = nx_number(table_npc_info[4])
      gb_npc.Top = nx_number(table_npc_info[5])
      custom_query_npc_karma(nx_string(table_npc_info[1]), nx_int(table_npc_info[2]), nx_int(id))
    end
  end
  add_relation(form, id)
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
  lbl_line.BackImage = "gui\\common\\scrollbar\\bg_scrollbar.png"
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
function on_gb_get_capture(gb)
  local lbl_npc = gb:Find("lbl_" .. nx_string(gb.Name))
  if not nx_is_valid(lbl_npc) then
    return
  end
  local lbl_karma = gb:Find("lbl_karma_" .. nx_string(gb.Name))
  if not nx_is_valid(lbl_karma) then
    return
  end
  lbl_npc.ForeColor = "255,255,0,0"
  lbl_karma.ForeColor = "255,255,0,0"
  local npc_id = gb.Name
  local scene = gb.Scene
  local level = gb.Level
  custom_query_npc_karma(nx_string(npc_id), nx_int(scene), nx_int(-1))
end
function on_gb_lost_capture(gb)
  local lbl_npc = gb:Find("lbl_" .. nx_string(gb.Name))
  if not nx_is_valid(lbl_npc) then
    return
  end
  local lbl_karma = gb:Find("lbl_karma_" .. nx_string(gb.Name))
  if not nx_is_valid(lbl_karma) then
    return
  end
  lbl_npc.ForeColor = "255,0,0,0"
  lbl_karma.ForeColor = "255,0,0,0"
end
function update_npc_karma(npc_id, karma)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_group_karma", true, false)
  if not form.Visible then
    return
  end
  local gb_npc = form.groupbox_npc:Find(nx_string(npc_id))
  if not nx_is_valid(gb_npc) then
    return
  end
  local lbl_karma = gb_npc:Find("lbl_karma_" .. nx_string(npc_id))
  if not nx_is_valid(lbl_karma) then
    return
  end
  if nx_number(karma) < nx_number(0) then
    lbl_karma.Text = nx_widestr("(") .. nx_widestr(util_text("ui_weijihuo")) .. nx_widestr(")")
  else
    lbl_karma.Text = nx_widestr("(") .. nx_widestr(karma) .. nx_widestr(")")
  end
end
function on_entry(flag)
  if nx_number(flag) <= nx_number(0) then
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  karmamgr:InitSyncNpcList()
end
