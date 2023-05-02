require("util_gui")
require("form_stage_main\\form_relation\\relation_define")
function main_form_init(self)
  self.Fixed = false
  self.npc_id = ""
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function show_npc_info(npc_id, scene_id, rank, relation)
  if npc_id == "" then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_npc_karma", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.npc_id = npc_id
  local name, origin, photo, character_str, shili_str, scene_str = get_npc_info(npc_id)
  form.lbl_name.Text = name
  form.lbl_shenfen.Text = origin
  form.lbl_photo.BackImage = photo
  local text
  if rank == nil or relation == nil then
    text = nx_widestr(util_text(nx_string("ui_karma_unknow")))
  elseif rank ~= nil and relation ~= nil then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    gui.TextManager:Format_SetIDName(nx_string("ui_karma_show"))
    gui.TextManager:Format_AddParam(nx_string(relation))
    gui.TextManager:Format_AddParam(nx_int(rank))
    text = gui.TextManager:Format_GetText()
  end
  form.mltbox_neirong:Clear()
  form.mltbox_neirong:AddHtmlText(nx_widestr(text), -1)
  form:Show()
end
function get_npc_info(npc_id)
  local name, origin, photo, character_str, shili_str, scene_str
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  name = nx_widestr(util_text(nx_string(npc_id)))
  origin = npc_id .. "_1"
  local gui = nx_value("gui")
  if gui.TextManager:IsIDName(nx_string(origin)) then
    origin = nx_widestr(util_text(nx_string(origin)))
  else
    origin = nx_widestr(util_text(nx_string("ui_karma_none")))
  end
  photo = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Photo"))
  if photo == "" then
    photo = "gui\\special\\sns_new\\sns_head\\common_head.png"
  end
  local Flag = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Character"))
  if nx_number(Flag) == nx_number(1) then
    character_str = nx_widestr(util_text("ui_xiashi"))
  elseif nx_number(Flag) == nx_number(2) then
    character_str = nx_widestr(util_text("ui_eren"))
  elseif nx_number(Flag) == nx_number(3) then
    character_str = nx_widestr(util_text("ui_xie"))
  elseif nx_number(Flag) == nx_number(4) then
    character_str = nx_widestr(util_text("ui_kuang"))
  else
    character_str = nx_widestr(util_text(nx_string("ui_sns_npcinfo_noinfo1")))
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local shili_id = karmamgr:GetGroupKarma(nx_string(npc_id))
  if nx_string(shili_id) ~= "" then
    shili_str = nx_widestr(util_text("group_karma_" .. nx_string(shili_id)))
  else
    shili_str = nx_widestr(util_text("ui_sns_npcinfo_noinfo2"))
  end
  scene_str = "ui_scene_" .. nx_string(get_scene_id(npc_id))
  if util_text(nx_string(scene_str)) ~= nx_string(scene_str) then
    scene_str = nx_widestr(util_text(nx_string(scene_str)))
  else
    scene_str = nx_widestr(util_text(nx_string("ui_sns_npcinfo_noinfo1")))
  end
  return name, origin, photo, character_str, shili_str, scene_str
end
function get_scene_id(npc_id)
  if nx_string(npc_id) == "" then
    return -1
  end
  local form_fujin = nx_value("form_stage_main\\form_relation\\form_relation_fujin")
  if nx_is_valid(form_fujin) then
    local scene_id = nx_execute("form_stage_main\\form_relation\\form_friend_list", "get_scene_id")
    return scene_id
  end
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) then
    if not nx_find_custom(form_renmai.form_friend_list, "relation") then
      return -1
    end
    local relation = form_renmai.form_friend_list.relation
    return get_scene_id_by_relation(relation, npc_id)
  end
  local form_shili = nx_value("form_stage_main\\form_relation\\form_relation_shili")
  if nx_is_valid(form_shili) then
    local groupbox_npc = form_shili.groupbox_npc
    local gb_select_npc = groupbox_npc:Find(npc_id)
    if nx_is_valid(gb_select_npc) and nx_find_custom(gb_select_npc, "Scene") then
      return nx_int(gb_select_npc.Scene)
    end
  end
  return -1
end
function get_scene_id_by_relation(relation, npc_id)
  local table_name = {
    "rec_npc_relation",
    "rec_npc_attention"
  }
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return -1
  end
  local index = 1
  if nx_number(relation) == nx_number(2) then
    index = 2
  end
  if not player:FindRecord(table_name[index]) then
    return -1
  end
  local row = player:FindRecordRow(table_name[index], 0, nx_string(npc_id), 0)
  if row < 0 then
    return -1
  end
  local scene_id = nx_int(player:QueryRecord(table_name[index], row, 1))
  return scene_id
end
function on_main_form_close(self)
  self.Visible = false
  nx_destroy(self)
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function on_btn_copyname_click(btn)
  local npc_id = btn.ParentForm.npc_id
  nx_function("ext_copy_wstr", nx_widestr(util_text(nx_string(npc_id))))
end
