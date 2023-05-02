require("util_gui")
local NPC_FRIEND = 0
local NPC_BUDDY = 1
local NPC_ATTENTION = 2
local NPC_ALL = 1000
function main_form_init(form)
  form.Fixed = true
  form.scene_id = 1000
  form.relation = NPC_ALL
  return 1
end
function on_main_form_open(form)
  local VScrollBar = form.groupscrollbox_list.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 40
  set_combobox_show(form)
  local databinder = nx_value("data_binder")
  databinder:AddTableBind("rec_npc_relation", form, "form_stage_main\\form_relation\\form_enchou_npc_list", "rec_changed")
  databinder:AddTableBind("rec_npc_attention", form, "form_stage_main\\form_relation\\form_enchou_npc_list", "rec_changed")
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function show_relation_npc_list(form)
  local scene_id_value = form.scene_id
  local relation_value = form.relation
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord("rec_npc_relation") and not player:FindRecord("rec_npc_attention") then
    return
  end
  form.groupscrollbox_list:DeleteAll()
  form.groupscrollbox_list.IsEditMode = true
  local relation_npc_num = 0
  local rows = player:GetRecordRows("rec_npc_relation")
  for i = 0, rows - 1 do
    local npc_id = player:QueryRecord("rec_npc_relation", i, 0)
    local scene_id = player:QueryRecord("rec_npc_relation", i, 1)
    local karam = player:QueryRecord("rec_npc_relation", i, 2)
    local relation = player:QueryRecord("rec_npc_relation", i, 3)
    if nx_number(relation) ~= nx_number(NPC_FRIEND) and nx_number(relation) ~= nx_number(NPC_BUDDY) and 0 <= player:FindRecordRow("rec_npc_attention", 0, nx_string(npc_id), 0) then
      relation = NPC_ATTENTION
    end
    if (nx_number(scene_id_value) == nx_number(1000) or nx_number(scene_id_value) == nx_number(scene_id)) and (nx_number(relation_value) == nx_number(NPC_ALL) or nx_number(relation_value) == nx_number(relation)) then
      local gb_npc = add_gb_npc(form, scene_id, npc_id, relation, karam)
      gb_npc.Left = 0
      gb_npc.Top = gb_npc.Height * relation_npc_num
      form.groupscrollbox_list:Add(gb_npc)
      relation_npc_num = relation_npc_num + 1
    end
  end
  if nx_number(relation_value) ~= nx_number(NPC_ATTENTION) and nx_number(relation_value) ~= nx_number(NPC_ALL) then
    return
  end
  local attention_npc_num = 0
  local rows = player:GetRecordRows("rec_npc_attention")
  for i = 0, rows - 1 do
    local npc_id = player:QueryRecord("rec_npc_attention", i, 0)
    local scene_id = player:QueryRecord("rec_npc_attention", i, 1)
    if 0 > player:FindRecordRow("rec_npc_relation", 0, nx_string(npc_id), 0) and (nx_number(scene_id_value) == nx_number(1000) or nx_number(scene_id_value) == nx_number(scene_id)) then
      local gb_npc = add_gb_npc(form, scene_id, npc_id, NPC_ATTENTION, 0)
      gb_npc.Left = 0
      gb_npc.Top = gb_npc.Height * (relation_npc_num + attention_npc_num)
      form.groupscrollbox_list:Add(gb_npc)
      attention_npc_num = attention_npc_num + 1
    end
  end
  form.groupscrollbox_list:ResetChildrenYPos()
  form.groupscrollbox_list.IsEditMode = false
end
function add_gb_npc(form, scene_id, npc_id, relation, karma)
  local gui = nx_value("gui")
  local gb_npc = gui:Create("GroupBox")
  gb_npc.Width = 670
  gb_npc.Height = 38
  gb_npc.NoFrame = true
  gb_npc.DrawMode = "FitWindow"
  gb_npc.BackImage = "gui\\special\\tiguan\\tiguan_rank_bar_2.png"
  gb_npc.Name = "gb_npc_" .. nx_string(npc_id)
  gb_npc.npc_id = npc_id
  gb_npc.scene_id = scene_id
  local lbl_scene = gui:Create("Label")
  lbl_scene.Name = "lbl_scene_" .. nx_string(npc_id)
  lbl_scene.Left = form.lbl_scene.Left
  lbl_scene.Top = 8
  lbl_scene.Width = 102
  lbl_scene.Height = 22
  lbl_scene.Text = util_text("ui_scene_" .. nx_string(scene_id))
  lbl_scene.Font = "font_sns_event_mid"
  lbl_scene.ForeColor = "150,76,61,44"
  lbl_scene.Align = "Center"
  lbl_scene.LblLimitWidth = true
  gb_npc:Add(lbl_scene)
  local lbl_name = gui:Create("Label")
  lbl_name.Name = "lbl_name_" .. nx_string(npc_id)
  lbl_name.Left = form.lbl_name.Left
  lbl_name.Top = 8
  lbl_name.Width = 78
  lbl_name.Height = 22
  lbl_name.Text = util_text(nx_string(npc_id))
  lbl_name.Font = "font_sns_event_mid"
  lbl_name.ForeColor = "150,76,61,44"
  lbl_name.Align = "Center"
  lbl_name.LblLimitWidth = true
  gb_npc:Add(lbl_name)
  local lbl_xiae = gui:Create("Label")
  lbl_xiae.Name = "lbl_xiae_" .. nx_string(npc_id)
  lbl_xiae.Left = form.lbl_xiae.Left
  lbl_xiae.Top = 8
  lbl_xiae.Width = 70
  lbl_xiae.Height = 22
  lbl_xiae.Font = "font_sns_event_mid"
  lbl_xiae.ForeColor = "150,76,61,44"
  lbl_xiae.Align = "Center"
  lbl_xiae.LblLimitWidth = true
  lbl_xiae.Text = util_text(nx_string("ui_sns_npcinfo_noinfo1"))
  local ItemQuery = nx_value("ItemQuery")
  if nx_is_valid(ItemQuery) then
    local Flag = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Character"))
    if nx_number(Flag) == nx_number(1) then
      lbl_xiae.Text = util_text("ui_xiashi")
    elseif nx_number(Flag) == nx_number(2) then
      lbl_xiae.Text = util_text("ui_eren")
    elseif nx_number(Flag) == nx_number(3) then
      lbl_xiae.Text = util_text("ui_xie")
    elseif nx_number(Flag) == nx_number(4) then
      lbl_xiae.Text = util_text("ui_kuang")
    end
  end
  gb_npc:Add(lbl_xiae)
  local lbl_shili = gui:Create("Label")
  lbl_shili.Name = "lbl_shili_" .. nx_string(npc_id)
  lbl_shili.Left = form.lbl_shili.Left
  lbl_shili.Top = 8
  lbl_shili.Width = 70
  lbl_shili.Height = 22
  lbl_shili.Font = "font_sns_event_mid"
  lbl_shili.ForeColor = "150,76,61,44"
  lbl_shili.Align = "Center"
  lbl_shili.LblLimitWidth = true
  lbl_shili.Text = util_text("ui_sns_npcinfo_noinfo2")
  local karmamgr = nx_value("Karma")
  if nx_is_valid(karmamgr) then
    local shili_id = karmamgr:GetGroupKarma(nx_string(npc_id))
    if nx_string(shili_id) ~= "" then
      lbl_shili.Text = util_text("group_karma_" .. nx_string(shili_id))
    end
  end
  gb_npc:Add(lbl_shili)
  local lbl_relation = gui:Create("Label")
  lbl_relation.Name = "lbl_relation_" .. nx_string(npc_id)
  lbl_relation.Left = form.lbl_relaiton.Left
  lbl_relation.Top = 8
  lbl_relation.Width = 110
  lbl_relation.Height = 22
  lbl_relation.Font = "font_sns_event_mid"
  lbl_relation.ForeColor = "150,76,61,44"
  lbl_relation.Align = "Center"
  lbl_relation.LblLimitWidth = true
  lbl_relation.Text = util_text("ui_sns_npcinfo_noinfo2")
  if nx_number(relation) == nx_number(NPC_FRIEND) then
    lbl_relation.Text = util_text("ui_haoyou_01")
  elseif nx_number(relation) == nx_number(NPC_BUDDY) then
    lbl_relation.Text = util_text("ui_zhiyou_01")
  elseif nx_number(relation) == nx_number(NPC_ATTENTION) then
    lbl_relation.Text = util_text("ui_guanzhu_01")
  end
  gb_npc:Add(lbl_relation)
  local lbl_karma = gui:Create("Label")
  lbl_karma.Name = "lbl_karma_" .. nx_string(npc_id)
  lbl_karma.Left = form.lbl_yinxiang.Left
  lbl_karma.Top = 8
  lbl_karma.Width = 102
  lbl_karma.Height = 22
  lbl_karma.Font = "font_sns_event_mid"
  lbl_karma.ForeColor = "150,76,61,44"
  lbl_karma.Align = "Center"
  lbl_karma.LblLimitWidth = true
  local karma_name = nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "get_karma_name", karma, false)
  lbl_karma.Text = karma_name
  gb_npc:Add(lbl_karma)
  local lbl_his_top = gui:Create("Label")
  lbl_his_top.Name = "lbl_his_top_" .. nx_string(npc_id)
  lbl_his_top.Left = form.lbl_his_top.Left
  lbl_his_top.Top = 8
  lbl_his_top.Width = 102
  lbl_his_top.Height = 22
  lbl_his_top.Font = "font_sns_event_mid"
  lbl_his_top.ForeColor = "150,76,61,44"
  lbl_his_top.Align = "Center"
  lbl_his_top.LblLimitWidth = true
  lbl_his_top.Text = karma_name
  gb_npc:Add(lbl_his_top)
  local lbl_his_low = gui:Create("Label")
  lbl_his_low.Name = "lbl_his_low_" .. nx_string(npc_id)
  lbl_his_low.Left = form.lbl_his_bot.Left
  lbl_his_low.Top = 8
  lbl_his_low.Width = 70
  lbl_his_low.Height = 22
  lbl_his_low.Font = "font_sns_event_mid"
  lbl_his_low.ForeColor = "150,76,61,44"
  lbl_his_low.Align = "Center"
  lbl_his_low.LblLimitWidth = true
  lbl_his_low.Text = karma_name
  gb_npc:Add(lbl_his_low)
  local special_num = 0
  local is_prize_npc = true
  if is_prize_npc then
    local lbl_prize = gui:Create("Label")
    lbl_prize.Name = "lbl_prize_" .. nx_string(npc_id)
    lbl_prize.Left = form.lbl_func.Left + special_num * 24
    lbl_prize.Top = 8
    lbl_prize.Width = 22
    lbl_prize.Height = 22
    lbl_prize.DrawMode = "FitWindow"
    lbl_prize.BackImage = "gui\\special\\sns_new\\btn_enchou_price\\money1_on.png"
    lbl_prize.HintText = util_text("tips_npcfunc_award")
    lbl_prize.Transparent = false
    gb_npc:Add(lbl_prize)
    special_num = special_num + 1
  end
  local is_avenge_npc = nx_execute("form_stage_main\\form_relation\\form_avenge_search", "is_avenge_npc", nx_string(npc_id))
  if is_avenge_npc then
    local lbl_avenge = gui:Create("Label")
    lbl_avenge.Name = "lbl_avenge_" .. nx_string(npc_id)
    lbl_avenge.Left = form.lbl_func.Left + special_num * 24
    lbl_avenge.Top = 8
    lbl_avenge.Width = 22
    lbl_avenge.Height = 22
    lbl_avenge.DrawMode = "FitWindow"
    lbl_avenge.BackImage = "gui\\special\\karma\\avenge.png"
    lbl_avenge.HintText = util_text("tips_npcfunc_avenge")
    lbl_avenge.Transparent = false
    gb_npc:Add(lbl_avenge)
    special_num = special_num + 1
  end
  local is_baowu_npc = is_zhibao_npc(npc_id)
  if is_baowu_npc then
    local lbl_baowu = gui:Create("Label")
    lbl_baowu.Name = "lbl_baowu_" .. nx_string(npc_id)
    lbl_baowu.Left = form.lbl_func.Left + special_num * 24
    lbl_baowu.Top = 8
    lbl_baowu.Width = 22
    lbl_baowu.Height = 22
    lbl_baowu.DrawMode = "FitWindow"
    lbl_baowu.BackImage = "gui\\special\\btn_main\\btn_zhibao_out.png"
    lbl_baowu.HintText = util_text("tips_npcfunc_zhibao")
    lbl_baowu.Transparent = false
    gb_npc:Add(lbl_baowu)
    special_num = special_num + 1
  end
  nx_bind_script(gb_npc, nx_current())
  nx_callback(gb_npc, "on_left_double_click", "on_gb_npc_left_double_click")
  nx_callback(gb_npc, "on_right_click", "on_gb_npc_right_click")
  nx_callback(gb_npc, "on_get_capture", "on_gb_npc_get_capture")
  nx_callback(gb_npc, "on_lost_capture", "on_gb_npc_lost_capture")
  return gb_npc
end
function on_gb_npc_left_double_click(self)
end
function on_gb_npc_right_click(self, x, y)
  if not nx_find_custom(self, "npc_id") or not nx_find_custom(self, "scene_id") then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "select_npc_karma_list", "select_npc_karma_list")
  nx_execute("menu_game", "menu_recompose", menu_game, nx_string(self.npc_id))
  menu_game.npc_id = nx_string(self.npc_id)
  menu_game.scene_id = nx_string(self.scene_id)
  gui:TrackPopupMenu(menu_game, x, y)
end
function on_gb_npc_get_capture(self)
  self.BackImage = "gui\\special\\tiguan\\tiguan_rank_bar_1.png"
end
function on_gb_npc_lost_capture(self)
  self.BackImage = "gui\\special\\tiguan\\tiguan_rank_bar_2.png"
end
function get_scene_list()
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local rec_list = {
    "rec_npc_relation",
    "rec_npc_attention"
  }
  local scene_list = {}
  local index = 1
  for k = 1, 2 do
    if player:FindRecord(rec_list[k]) then
      local rows = player:GetRecordRows(rec_list[k])
      for i = 0, rows - 1 do
        local scene_id = player:QueryRecord(rec_list[k], i, 1)
        local is_dif = true
        for j = 1, table.getn(scene_list) do
          if scene_id == scene_list[j] then
            is_dif = false
            break
          end
        end
        if is_dif then
          scene_list[index] = scene_id
          index = index + 1
        end
      end
    end
  end
  return scene_list
end
function is_zhibao_npc(npc_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\Karma\\zhibao_npc.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local section_count = ini:GetSectionCount()
  for i = 0, section_count do
    local item_count = ini:GetSectionItemCount(i)
    for j = 0, item_count do
      local value = ini:GetSectionItemValue(i, j)
      if nx_string(npc_id) == nx_string(value) then
        return true
      end
    end
  end
  return false
end
function set_combobox_show(form)
  local form_enchou = nx_value("form_stage_main\\form_relation\\form_relation_enchou")
  if not nx_is_valid(form_enchou) then
    return
  end
  local relation = {
    "ui_map_scene_filter_all",
    "ui_haoyou_01",
    "ui_zhiyou_01",
    "ui_guanzhu_01"
  }
  form_enchou.cbb_relation.DropListBox:ClearString()
  for i = 1, 4 do
    form_enchou.cbb_relation.DropListBox:AddString(util_text(relation[i]))
  end
  nx_bind_script(form_enchou.cbb_relation, nx_current())
  nx_callback(form_enchou.cbb_relation, "on_selected", "on_cbb_relation_selected")
  local relation_text = util_text("ui_map_scene_filter_all")
  if nx_number(form.relation) ~= nx_number(1000) then
    relation_text = util_text(relation[form.relation + 2])
  end
  form_enchou.cbb_relation.InputEdit.Text = relation_text
  local scene_list = get_scene_list()
  local scene_num = table.getn(scene_list)
  form_enchou.cbb_scene.DropListBox:ClearString()
  form_enchou.cbb_scene.DropListBox:AddString(util_text("ui_map_scene_filter_all"))
  for i = 1, scene_num do
    form_enchou.cbb_scene.DropListBox:AddString(util_text("ui_scene_" .. nx_string(scene_list[i])))
  end
  nx_bind_script(form_enchou.cbb_scene, nx_current())
  nx_callback(form_enchou.cbb_scene, "on_selected", "on_cbb_scene_selected")
  form_enchou.cbb_scene.DropListBox.SelectIndex = 0
  local scene_text = util_text("ui_map_scene_filter_all")
  if nx_number(form.scene_id) ~= nx_number(1000) then
    scene_text = util_text("ui_scene_" .. nx_string(form.scene_id))
  end
  form_enchou.cbb_scene.InputEdit.Text = scene_text
  show_relation_npc_list(form)
end
function on_cbb_scene_selected(cbb)
  local form = nx_value("form_stage_main\\form_relation\\form_enchou_npc_list")
  if not nx_is_valid(form) then
    return
  end
  local index = cbb.DropListBox.SelectIndex
  local scene_id = 1000
  if 0 < index then
    local scene_list = get_scene_list()
    scene_id = scene_list[index]
  end
  form.scene_id = scene_id
  show_relation_npc_list(form)
end
function on_cbb_relation_selected(cbb)
  local form = nx_value("form_stage_main\\form_relation\\form_enchou_npc_list")
  local index = cbb.DropListBox.SelectIndex
  local relation = NPC_ALL
  if 0 < index then
    relation = index - 1
  end
  form.relation = relation
  show_relation_npc_list(form)
end
function rec_changed(form, recordname, optype, row, clomn)
  show_relation_npc_list(form)
end
