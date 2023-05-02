require("role_composite")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
local FORM = "form_stage_main\\form_relation\\form_relation_fujin"
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  change_form_size()
  add_npc_list_form(self)
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("Gossip_Record", self.gsb_gossip, nx_current(), "add_gossip_list_form")
end
function on_main_form_close(self)
  local form_npc = nx_value("form_stage_main\\form_relation\\form_npc_info")
  if nx_is_valid(form_npc) then
    nx_destroy(form_npc)
  end
  local form_karma = nx_value("form_stage_main\\form_relation\\super_book_trace\\form_npc_karma")
  if nx_is_valid(form_karma) then
    nx_destroy(form_karma)
  end
  nx_destroy(self)
end
function show_form(flag)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  if flag then
    local form_fujin = nx_value(FORM)
    if not nx_is_valid(form_fujin) then
      local form_fujin = nx_execute("util_gui", "util_get_form", FORM, true, false)
      if nx_is_valid(form_fujin) then
        form:Add(form_fujin)
      end
    else
      form_fujin:Show()
      form_fujin.Visible = true
    end
  else
    local form_fujin = nx_value(FORM)
    if nx_is_valid(form_fujin) then
      form_fujin.Visible = false
    end
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local form_fujin = nx_execute("util_gui", "util_get_form", FORM, true, false)
  if nx_is_valid(form_fujin) then
    form_fujin.Left = 0
    form_fujin.Top = 0
    form_fujin.Width = form.Width
    form_fujin.Height = form.Height - form.groupbox_rbtn.Height
    if nx_find_custom(form_fujin, "form_friend_list") then
      form_fujin.form_friend_list.Left = form_fujin.Width - 360
      form_fujin.form_friend_list.Top = (form_fujin.Height - form_fujin.form_friend_list.Height) / 2 + 40
    end
  end
  local form_karma_prize = nx_value("form_stage_main\\form_relation\\form_npc_karma_prize_ex")
  if nx_is_valid(form_karma_prize) then
    nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "change_form_size", form_karma_prize)
  end
end
function on_relation_type_change_event(group_id, relation_type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_character.Visible = false
  form.groupbox_geren.Visible = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_sns_backbutton1")
  gui.TextManager:Format_AddParam(client_player:QueryProp("Name"))
  local text = gui.TextManager:Format_GetText()
  gui.TextManager:Format_SetIDName("ui_sns_backbutton22")
  gui.TextManager:Format_AddParam(nx_int(4))
  text = text .. gui.TextManager:Format_GetText()
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local relation_group = sns_manager:GetRelationGroup(group_id)
  local group_index
  if nx_find_custom(relation_group, "group_index") then
    group_index = relation_group.group_index
  end
  if group_index ~= RELATION_GROUP_FUJIN then
    return
  end
  form.form_friend_list.Visible = true
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "show_friends_list_page", RELATION_SUB_FUJIN_FUJIN)
  form.select_npcid = "all_npc"
  add_gossip_list_form()
  form.groupbox_gossip.Top = 111
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form_relationship) then
    return
  end
  text = nx_widestr(text)
  form_relationship.mltbox_title:Clear()
  form_relationship.mltbox_title:AddHtmlText(nx_widestr(text), nx_int(-1))
  nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "hide_form")
end
function on_focus_change_event(group_id, relation_type, index, npc_id)
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "show_form", form, nx_string(npc_id))
    form.select_npcid = nx_string(npc_id)
    add_gossip_list_form()
    form.groupbox_gossip.Top = 270
  end
  show_character(npc_id)
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form_relationship) then
    return
  end
  local text = form_relationship.mltbox_title:GetHtmlItemText(0)
  text = text .. nx_widestr(".") .. nx_widestr(util_text(nx_string(npc_id)))
  form_relationship.mltbox_title:Clear()
  form_relationship.mltbox_title:AddHtmlText(text, -1)
end
function add_npc_list_form(form)
  local form_friend_list = util_get_form("form_stage_main\\form_relation\\form_friend_list", true, false)
  if form:Add(form_friend_list) then
    form.form_friend_list = form_friend_list
    form.form_friend_list.Visible = true
    form.form_friend_list.Fixed = true
    form.form_friend_list.Left = form.Width - 360
    form.form_friend_list.Top = (form.Height - form.form_friend_list.Height) / 2 + 40
    form_friend_list.groupbox_radiobutton.Visible = false
    form_friend_list.groupbox_npc_radiobutton.Visible = true
  end
end
function update_nums()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local haoyou_num = get_relation_num(0)
  local zhiyou_num = get_relation_num(1)
  local guanzhu_num = get_guanzhu_num()
  local fujin_num = get_fujin_num()
  form.lbl_haoyou.Text = nx_widestr(haoyou_num)
  form.lbl_zhiyou.Text = nx_widestr(zhiyou_num)
  form.lbl_guanzhu.Text = nx_widestr(guanzhu_num)
  form.lbl_fujin.Text = nx_widestr(fujin_num)
end
function get_relation_num(relation)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return 0
  end
  local table_name = "rec_npc_relation"
  local num = 0
  if player:FindRecord(table_name) then
    local rows = player:GetRecordRows(table_name)
    if 0 < rows then
      for i = 0, rows - 1 do
        local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
        local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
        if nx_number(npc_relation) == relation then
          num = num + 1
        end
      end
    end
  end
  return num
end
function get_guanzhu_num()
  local table_name = "rec_npc_attention"
  local player = get_client_player()
  if not nx_is_valid(player) then
    return 0
  end
  if not player:FindRecord(table_name) then
    return 0
  end
  local rows = player:GetRecordRows(table_name)
  return rows
end
function get_fujin_num()
  local player = get_client_player()
  if not nx_is_valid(player) then
    return 0
  end
  local cur_scene = nx_execute("form_stage_main\\form_relation\\form_friend_list", "get_scene_id")
  local table_name = "rec_npc_relation"
  local num = 0
  if player:FindRecord(table_name) then
    local rows = player:GetRecordRows(table_name)
    if 0 < rows then
      for i = 0, rows - 1 do
        local scene = nx_int(player:QueryRecord(table_name, i, 1))
        local npc_relation = player:QueryRecord(table_name, i, 3)
        if nx_number(scene) == nx_number(cur_scene) then
          num = num + 1
        end
      end
    end
  end
  return num
end
function add_gossip_list_form()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  form.gsb_gossip:DeleteAll()
  if not client_player:FindRecord("Gossip_Record") then
    form.lbl_bg.Visible = false
    form.lbl_bg_num.Visible = false
    return
  end
  local rows = client_player:GetRecordRows("Gossip_Record")
  if rows <= 0 then
    form.lbl_bg.Visible = false
    form.lbl_bg_num.Visible = false
    return
  end
  form.gsb_gossip:DeleteAll()
  form.gsb_gossip.Visible = true
  local select_npcid = ""
  if nx_find_custom(form, "select_npcid") then
    select_npcid = form.select_npcid
  end
  if select_npcid ~= "" and select_npcid ~= "all_npc" then
    local row = client_player:FindRecordRow("Gossip_Record", 1, nx_string(select_npcid), 0)
    if 0 <= row then
      form.lbl_bg_num.Text = nx_widestr(1)
      form.lbl_bg.Visible = true
      form.lbl_bg_num.Visible = true
      local bg_id = client_player:QueryRecord("Gossip_Record", row, 0)
      add_gossip(form, bg_id, select_npcid, 0)
      form.gsb_gossip.IsEditMode = false
    else
      form.lbl_bg.Visible = false
      form.lbl_bg_num.Visible = false
      form.gsb_gossip.Visible = false
    end
    return
  end
  form.lbl_bg_num.Text = nx_widestr(rows)
  form.lbl_bg.Visible = true
  form.lbl_bg_num.Visible = true
  for i = 0, rows - 1 do
    local bg_id = client_player:QueryRecord("Gossip_Record", i, 0)
    local npc_id = client_player:QueryRecord("Gossip_Record", i, 1)
    add_gossip(form, bg_id, npc_id, i)
  end
  form.gsb_gossip.IsEditMode = false
end
function add_gossip(form, bg_id, npc_id, index)
  local gui = nx_value("gui")
  local groupbox_npc = gui:Create("GroupBox")
  groupbox_npc.Name = nx_string(i)
  groupbox_npc.Width = form.gsb_gossip.Width - 18
  groupbox_npc.Height = 70
  groupbox_npc.NoFrame = true
  groupbox_npc.BackImage = "gui\\special\\sns_new\\bg_event.png"
  groupbox_npc.DrawMode = "ExpandH"
  local lbl_npc = gui:Create("Label")
  lbl_npc.Name = "lbl_npc_" .. nx_string(i)
  lbl_npc.Width = 60
  lbl_npc.Height = 20
  lbl_npc.Top = 5
  lbl_npc.Left = 15
  lbl_npc.Font = "font_sns_event_mid"
  lbl_npc.ForeColor = "255,255,255,255"
  lbl_npc.Text = nx_widestr(util_text(nx_string(npc_id)))
  groupbox_npc:Add(lbl_npc)
  local lbl_npc_origin = gui:Create("Label")
  lbl_npc_origin.Name = "lbl_npc_origin_" .. nx_string(i)
  lbl_npc_origin.Width = lbl_npc.Width
  lbl_npc_origin.Height = lbl_npc.Height
  lbl_npc_origin.Top = lbl_npc.Top
  lbl_npc_origin.Left = lbl_npc.Left * 2 + lbl_npc.Width
  lbl_npc_origin.Font = "font_sns_list"
  lbl_npc_origin.ForeColor = "255,214,204,191"
  local origin = npc_id .. "_1"
  if gui.TextManager:IsIDName(origin) then
    origin = util_text(nx_string(origin))
  else
    origin = util_text(nx_string("ui_karma_none"))
  end
  lbl_npc_origin.Text = nx_widestr(origin)
  groupbox_npc:Add(lbl_npc_origin)
  local btn_share = gui:Create("Button")
  btn_share.Name = "btn_share_" .. nx_string(i)
  btn_share.Top = lbl_npc.Top
  btn_share.Left = lbl_npc_origin.Left + lbl_npc_origin.Width * 1.7
  btn_share.Font = "font_sns_list"
  btn_share.ForeColor = "255,214,204,191"
  btn_share.NormalImage = "gui\\language\\ChineseS\\sns_new\\btn_fx_out.png"
  btn_share.FocusImage = "gui\\language\\ChineseS\\sns_new\\btn_fx_on.png"
  btn_share.PushImage = "gui\\language\\ChineseS\\sns_new\\btn_fx_down.png"
  btn_share.AutoSize = true
  btn_share.DrawMode = "Tile"
  btn_share.DataSource = bg_id
  nx_bind_script(btn_share, nx_current())
  nx_callback(btn_share, "on_click", "on_btn_share_click")
  groupbox_npc:Add(btn_share)
  local btn_del = gui:Create("Button")
  btn_del.Name = "btn_del_" .. nx_string(i)
  btn_del.Top = lbl_npc.Top
  btn_del.Left = btn_share.Left + btn_share.Width * 1.1
  btn_del.Font = "font_sns_list"
  btn_del.ForeColor = "255,214,204,191"
  btn_del.Transparent = false
  btn_del.NormalImage = "gui\\language\\ChineseS\\sns_new\\btn_del_out.png"
  btn_del.FocusImage = "gui\\language\\ChineseS\\sns_new\\btn_del_on.png"
  btn_del.PushImage = "gui\\language\\ChineseS\\sns_new\\btn_del_down.png"
  btn_del.AutoSize = true
  btn_del.DataSource = bg_id
  nx_bind_script(btn_del, nx_current())
  nx_callback(btn_del, "on_click", "on_btn_del_click")
  groupbox_npc:Add(btn_del)
  local multi_text_box = gui:Create("MultiTextBox")
  multi_text_box.Name = "mltbox_" .. nx_string(i)
  multi_text_box.Width = groupbox_npc.Width
  multi_text_box.Height = groupbox_npc.Height - lbl_npc.Height
  multi_text_box.Top = lbl_npc.Height
  multi_text_box.DrawMode = "Expand"
  multi_text_box.LineColor = "0,0,0,0"
  multi_text_box.LineHeight = 5
  multi_text_box.Solid = false
  multi_text_box.AutoSize = false
  multi_text_box.HasVScroll = false
  multi_text_box.Font = "font_system_news"
  multi_text_box.TestTrans = false
  multi_text_box.TextColor = "255,214,204,191"
  multi_text_box.SelectBarColor = "0,0,0,0"
  multi_text_box.MouseInBarColor = "0,0,0,0"
  multi_text_box.BackColor = "0,255,255,255"
  multi_text_box.TransImage = true
  multi_text_box.ViewRect = "5,0,270,50"
  nx_bind_script(multi_text_box, nx_current())
  nx_callback(multi_text_box, "on_get_capture", "on_get_capture")
  nx_callback(multi_text_box, "on_lost_capture", "on_lost_capture")
  local gossip_info = gui.TextManager:GetText(bg_id)
  multi_text_box:AddHtmlText(nx_widestr(gossip_info), -1)
  groupbox_npc:Add(multi_text_box)
  groupbox_npc.Top = index * (groupbox_npc.Height + 10)
  form.gsb_gossip:Add(groupbox_npc)
end
function show_character(npc_id)
  local gui = nx_value("gui")
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local karma = 0
  local rows = client_player:FindRecordRow("rec_npc_relation", 0, nx_string(npc_id), 0)
  if 0 <= rows then
    karma = client_player:QueryRecord("rec_npc_relation", rows, 2)
  end
  local karma_text = get_relation_desc_by_karma(karma)
  form.lbl_relation.Text = nx_widestr(karma_text)
  local CharacterFlag = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Character")))
  add_karma_bar_info(form, karma)
  local Story = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Story"))
  local desc = gui.TextManager:GetText("ui_sns_npc_nomess")
  if "" ~= Story then
    desc = gui.TextManager:GetText(Story)
  end
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(nx_widestr(desc), -1)
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
  end
  form.groupbox_character.Visible = true
end
function get_relation_desc_by_karma(karma)
  local karma_text = ""
  if nx_int(karma) >= nx_int(-100000) and nx_int(karma) < nx_int(-80000) then
    karma_text = util_text("ui_karma_rela1")
  elseif nx_int(karma) >= nx_int(-80000) and nx_int(karma) < nx_int(-40000) then
    karma_text = util_text("ui_karma_rela2")
  elseif nx_int(karma) >= nx_int(-40000) and nx_int(karma) < nx_int(0) then
    karma_text = util_text("ui_karma_rela3")
  elseif nx_int(karma) == nx_int(0) then
    karma_text = util_text("ui_karma_rela4")
  elseif nx_int(karma) <= nx_int(40000) and nx_int(karma) > nx_int(0) then
    karma_text = util_text("ui_karma_rela5")
  elseif nx_int(karma) <= nx_int(80000) and nx_int(karma) > nx_int(40000) then
    karma_text = util_text("ui_karma_rela6")
  elseif nx_int(karma) <= nx_int(100000) and nx_int(karma) > nx_int(80000) then
    karma_text = util_text("ui_karma_rela7")
  end
  return karma_text
end
function add_karma_bar_info(form, value)
  local min_val, max_val, name, pic = get_karma_msg_config(value)
  form.lbl_karma_mark.BackImage = pic
  value = nx_int(value)
  local len = max_val - min_val
  local reality = value - min_val
  form.lbl_karma_mark.Left = form.lbl_karma_bar.Left + (reality / len * form.lbl_karma_bar.Width - form.lbl_karma_mark.Width / 2)
  form.lbl_karma_bar.HintText = nx_widestr(util_text("ui_presentkarma")) .. nx_widestr(util_text(name))
end
function on_get_capture(self)
  local str = self:GetHtmlItemText(0)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local mlt_box_desc = form:Find("mltbox_desc")
  if not nx_is_valid(mlt_box_desc) then
    mlt_box_desc = gui:Create("MultiTextBox")
    mlt_box_desc.Name = "mltbox_desc"
    form:Add(mlt_box_desc)
  end
  mlt_box_desc.Width = self.Width
  mlt_box_desc.Height = 2 * self.Height
  mlt_box_desc.Top = self.Height + self.AbsTop
  mlt_box_desc.Left = self.AbsLeft
  mlt_box_desc.DrawMode = "Expand"
  mlt_box_desc.LineColor = "0,0,0,0"
  mlt_box_desc.LineHeight = 10
  mlt_box_desc.HasVScroll = false
  mlt_box_desc.Font = "font_system_news"
  mlt_box_desc.TextColor = "255,204,204,204"
  mlt_box_desc.SelectBarColor = "0,0,0,0"
  mlt_box_desc.BackColor = "255,255,180,40"
  mlt_box_desc.ViewRect = "5,6,270,144"
  mlt_box_desc.BackImage = "gui\\common\\combobox\\bg_list1.png"
  mlt_box_desc:Clear()
  mlt_box_desc:AddHtmlText(nx_widestr(str), -1)
end
function on_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local mlt_box_desc = form:Find("mltbox_desc")
  if nx_is_valid(mlt_box_desc) then
    gui:Delete(mlt_box_desc)
  end
end
function on_btn_share_click(self)
  local bagua_id = self.DataSource
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_share_gossip_info", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.combobox_friend.Text = gui.TextManager:GetText("ui_input")
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_search_return")
  if res == "ok" then
    if nx_ws_equal(nx_widestr(text), nx_widestr("")) then
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BAGUA), 1, nx_widestr(text), bagua_id)
  end
end
function on_btn_del_click(self)
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
  local bagua_id = self.DataSource
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BAGUA), 2, "", bagua_id)
end
function on_rbtn_haoyou_checked_changed(self)
  if self.Checked then
    local sns_manager = nx_value(SnsManagerCacheName)
    local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_FUJIN)
    sns_manager:SetRelationType(group_id, 0)
    local form_fujin = nx_value("form_stage_main\\form_relation\\form_relation_fujin")
    if nx_is_valid(form_fujin) then
      form_fujin.lbl_relation_title.BackImage = "gui\\language\\ChineseS\\sns_new\\haoyou.png"
    end
  end
end
function on_rbtn_zhiyou_checked_changed(self)
  if self.Checked then
    local sns_manager = nx_value(SnsManagerCacheName)
    local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_FUJIN)
    sns_manager:SetRelationType(group_id, 1)
    local form_fujin = nx_value("form_stage_main\\form_relation\\form_relation_fujin")
    if nx_is_valid(form_fujin) then
      form_fujin.lbl_relation_title.BackImage = "gui\\language\\ChineseS\\sns_new\\zhiyou.png"
    end
  end
end
function on_rbtn_guanzhu_checked_changed(self)
  if self.Checked then
    local sns_manager = nx_value(SnsManagerCacheName)
    local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_FUJIN)
    sns_manager:SetRelationType(group_id, 2)
    local form_fujin = nx_value("form_stage_main\\form_relation\\form_relation_fujin")
    if nx_is_valid(form_fujin) then
      form_fujin.lbl_relation_title.BackImage = "gui\\language\\ChineseS\\sns_new\\guanzhu.png"
    end
  end
end
function on_rbtn_fujin_checked_changed(self)
  if self.Checked then
    local sns_manager = nx_value(SnsManagerCacheName)
    local group_id = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_FUJIN)
    sns_manager:SetRelationType(group_id, 3)
    local form_fujin = nx_value("form_stage_main\\form_relation\\form_relation_fujin")
    if nx_is_valid(form_fujin) then
      form_fujin.lbl_relation_title.BackImage = "gui\\language\\ChineseS\\sns_new\\fujin.png"
    end
  end
end
function show_tips_info(npc_id)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord("rec_npc_relation") then
    return
  end
  local index = player:FindRecordRow("rec_npc_relation", 0, npc_id, 0)
  if index < 0 then
    return
  end
  local scene_id = nx_int(player:QueryRecord("rec_npc_relation", index, 1))
  form.gsb_gossip.Visible = false
  form.lbl_bg.Visible = false
  form.lbl_bg_num.Visible = false
  form.groupbox_geren.Visible = true
  form.lbl_npc_name.Text = nx_widestr(util_text(nx_string(npc_id)))
  form.lbl_2.Text = nx_widestr(util_text("ui_scene_" .. nx_string(scene_id)))
  local relation = get_npc_relation(npc_id)
  if relation == 0 then
    form.lbl_6.Text = nx_widestr(util_text(nx_string("ui_haoyou_01")))
  elseif relation == 1 then
    form.lbl_6.Text = nx_widestr(util_text(nx_string("ui_zhiyou_01")))
  elseif relation == 2 then
    form.lbl_6.Text = nx_widestr(util_text(nx_string("ui_guanzhu_01")))
  else
    form.lbl_6.Text = nx_widestr(util_text(nx_string("ui_putong_01")))
  end
end
function get_news_fujin()
  local player = get_client_player()
  if not nx_is_valid(player) then
    return 0
  end
  local cur_scene = nx_execute("form_stage_main\\form_relation\\form_friend_list", "get_scene_id")
  local table_name = "rec_npc_relation"
  local num = 0
  if player:FindRecord(table_name) then
    local rows = player:GetRecordRows(table_name)
    if 0 < rows then
      for i = 0, rows - 1 do
        local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
        local scene = nx_int(player:QueryRecord(table_name, i, 1))
        local npc_relation = player:QueryRecord(table_name, i, 3)
        if nx_number(scene) == nx_number(cur_scene) then
          num = num + get_npc_news(npc_id)
        end
      end
    end
  end
  return num
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
