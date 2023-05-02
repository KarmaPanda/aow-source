require("util_gui")
function main_form_init(form)
end
function on_main_form_open(form)
  form.groupbox_1.Visible = true
  form.btn_reel.Visible = false
  form.btn_reel1.Visible = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function init_info(npcid, self)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_gameObject = game_client:GetSceneObj(npcid)
  local configid = client_gameObject:QueryProp("ConfigID")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(configid))
  if not bExist then
    return
  end
  local byname_id = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("Call"))
  if byname_id == "" then
    self.lbl_byname.Text = byname_id
  else
    self.lbl_byname.Text = gui.TextManager:GetText(byname_id)
  end
  self.lbl_name.Text = gui.TextManager:GetText(configid)
  local identity_id = nx_string(configid .. "_1")
  local identity = gui.TextManager:GetText(identity_id)
  if nx_ws_equal(identity, nx_widestr(identity_id)) then
    identity = ""
  end
  self.lbl_identity.Text = identity
  local stroy_id = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("Story"))
  if stroy_id == "" then
    self.Visible = false
    self.lbl_byname.Text = stroy_id
  else
    self.Visible = true
    self.mltbox_story.HtmlText = nx_widestr("<center>   ") .. gui.TextManager:GetText(stroy_id) .. nx_widestr("</center>")
  end
  local karmamatchingid = nx_string(client_gameObject:QueryProp("KarmaMatchingID"))
  local character_id = nx_string("desc_matchingpack_") .. karmamatchingid
  if karmamatchingid == nx_string(0) then
    self.lbl_character.Text = karmamatchingid
  else
    self.lbl_character.Text = gui.TextManager:GetText(character_id)
  end
end
function on_btn_reel_click(self)
  local form = nx_value("form_stage_main\\form_talk_npc_worldview")
  if nx_is_valid(form) then
    form.groupbox_1.Visible = true
    form.btn_reel.Visible = false
    form.btn_reel1.Visible = true
  end
end
function on_btn_reel1_click(self)
  local form = nx_value("form_stage_main\\form_talk_npc_worldview")
  if nx_is_valid(form) then
    form.groupbox_1.Visible = false
    form.btn_reel.Visible = true
    form.btn_reel1.Visible = false
  end
end
function is_have_story(npcid)
  local game_client = nx_value("game_client")
  local client_gameObject = game_client:GetSceneObj(npcid)
  local configid = client_gameObject:QueryProp("ConfigID")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(configid))
  if not bExist then
    return false
  end
  local stroy_id = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("Story"))
  if stroy_id ~= "" then
    return true
  end
  return false
end
