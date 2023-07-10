require("util_gui")
require("form_stage_main\\form_relation\\relation_define")
local R_SWORN = 1
local R_FRIEND = 2
local R_BUDDY = 3
local R_ATTENTION = 4
local R_ENEMY = 5
local R_BLOOD = 6
local R_FLITER = 7
local R_FANS = 8
function main_form_init(self)
  self.Fixed = false
  self.PlayerName = ""
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function get_scene_name(index)
  local map_query = nx_value("MapQuery")
  local gui = nx_value("gui")
  if nx_is_valid(map_query) then
    local scene_name = "scene_" .. map_query:GetSceneName(nx_string(index))
    if nx_string(scene_name) == nx_string(util_text(scene_name)) then
      return ""
    end
    return util_text(scene_name)
  end
  return ""
end
function on_main_form_close(self)
  self.Visible = false
  nx_destroy(self)
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function on_btn_mail_click(btn)
  btn.NormalImage = "gui\\mainform\\role\\btn_mail_out.png"
  nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
  local form_send_mail = nx_value("form_stage_main\\form_mail\\form_mail_send")
  if nx_is_valid(form_send_mail) then
    form_send_mail.targetname.Text = nx_widestr(btn.ParentForm.PlayerName)
  end
end
function on_btn_team_click(btn)
  nx_execute("custom_sender", "custom_team_invite", nx_widestr(btn.ParentForm.PlayerName))
end
function on_btn_chat_click(btn)
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(btn.ParentForm.PlayerName))
end
function on_btn_copyname_click(btn)
  nx_function("ext_copy_wstr", nx_widestr(btn.ParentForm.PlayerName))
end
function on_btn_guanzhu_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", nx_widestr(btn.ParentForm.PlayerName))
end
function on_btn_friend_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", nx_widestr(btn.ParentForm.PlayerName))
end
function on_look_up_msg(player_name, player_title, player_level, player_photo, player_pk_step, player_scene, player_school, player_guild, player_guild_pos, player_sh, player_vip, player_teacher, player_partner, sworn_info, zone)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local jh_scene = ""
  if player:FindProp("CurJHSceneConfigID") then
    jh_scene = player:QueryProp("CurJHSceneConfigID")
  end
  if nx_string(jh_scene) ~= nx_string("") then
    nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "on_look_up_jhpk_msg", player_name, player_level, player_photo, player_scene, player_school, player_guild, zone)
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_player_info", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  gui.Desktop:ToFront(dialog)
  dialog.PlayerName = player_name
  local _, relation = get_r_type_by_name(player_name)
  dialog:Show()
  local player_relation = "ui_wu"
  if relation == R_SWORN then
    player_relation = "ui_menu_friend_item_sworn"
  elseif relation == R_FRIEND then
    player_relation = "ui_menu_friend_item_haoyou"
  elseif relation == R_BUDDY then
    player_relation = "ui_menu_friend_item_zhiyou"
  elseif relation == R_ENEMY then
    player_relation = "ui_menu_friend_item_chouren"
  elseif relation == R_BLOOD then
    player_relation = "ui_menu_friend_item_xuechou"
  elseif relation == R_ATTENTION then
    player_relation = "ui_menu_friend_item_guanzhu"
  end
  player_relation = util_text(player_relation)
  dialog.lbl_name.Text = nx_widestr(player_name)
  dialog.lbl_photo.BackImage = player_photo
  dialog.lbl_menpai.Text = nx_widestr(player_school)
  dialog.lbl_bangpai.Text = nx_widestr(player_guild)
  dialog.lbl_guanxi.Text = nx_widestr(player_relation)
  dialog.lbl_chengwei.Text = nx_widestr(player_title)
  dialog.lbl_zhuangtai.Text = nx_widestr(gui.TextManager:GetText(player_scene))
  dialog.lbl_11.Text = nx_widestr(player_guild_pos)
  dialog.lbl_shili.Text = nx_widestr(player_level)
  dialog.lbl_shane.Text = nx_widestr(player_pk_step)
  dialog.mltbox_1:Clear()
  dialog.mltbox_1:AddHtmlText(nx_widestr(player_sh), -1)
  if nx_int(player_vip) == nx_int(1) then
    dialog.lbl_viper.Text = nx_widestr(util_text("ui_yes"))
  else
    dialog.lbl_viper.Text = nx_widestr(util_text("ui_no"))
  end
  if nx_widestr(player_teacher) == nx_widestr("") or player_teacher == nil then
    dialog.lbl_teacher.Text = nx_widestr(util_text("ui_wu"))
  else
    dialog.lbl_teacher.Text = nx_widestr(player_teacher)
  end
  if nx_widestr("") == nx_widestr(player_partner) or nil == player_partner then
    dialog.lbl_marry.Text = nx_widestr(util_text("ui_wu"))
  else
    dialog.lbl_marry.Text = nx_widestr(player_partner)
  end
  split_sworn_info(dialog, sworn_info)
end
function on_btn_add_filter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_filter", nx_widestr(form.PlayerName))
end
function on_btn_add_filter_native_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local karmamgr = nx_value("Karma")
  if nx_is_valid(karmamgr) then
    karmamgr:AddFilterNative(nx_widestr(form.PlayerName))
  end
end
function split_sworn_info(form, sworn_info)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_sworn_1.Text = nx_widestr("")
  form.lbl_sworn_2.Text = nx_widestr("")
  form.lbl_sworn_3.Text = nx_widestr("")
  form.lbl_sworn_4.Text = nx_widestr("")
  form.lbl_sworn_5.Text = nx_widestr("")
  local sworn_list = util_split_wstring(sworn_info, ",")
  if table.getn(sworn_list) == 0 then
    form.lbl_sworn_1.Text = nx_widestr(util_text("ui_sworn_none"))
  else
    for i = 1, table.getn(sworn_list) do
      local lab = form.groupbox_2:Find("lbl_sworn_" .. nx_string(i))
      if nx_is_valid(lab) and nx_widestr(sworn_list[i]) ~= nx_widestr("") then
        lab.Text = nx_widestr(sworn_list[i])
      end
    end
  end
end
function get_client_player()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    return game_client:GetPlayer()
  end
  return nx_null()
end
function get_r_type_by_name(player_name)
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    return false
  end
  local bFind = search_relation_result(client_role, "SwornRelationRec", player_name, SWORN_REC_COL_NAME)
  if bFind then
    return bFind, R_SWORN
  end
  if not bFind then
    bFind = search_relation_result(client_role, FRIEND_REC, player_name, FRIEND_REC_NAME)
    if bFind then
      return bFind, R_FRIEND
    end
  end
  if not bFind then
    bFind, uid = search_relation_result(client_role, BUDDY_REC, player_name, FRIEND_REC_NAME)
    if bFind then
      return bFind, R_BUDDY
    end
  end
  if not bFind then
    bFind = search_relation_result(client_role, ATTENTION_REC, player_name, FRIEND_REC_NAME)
    if bFind then
      return bFind, R_ATTENTION
    end
  end
  if not bFind then
    bFind = search_relation_result(client_role, ENEMY_REC, player_name, ENEMY_REC_NAME)
    if bFind then
      return bFind, R_ENEMY
    end
  end
  if not bFind then
    bFind = search_relation_result(client_role, BLOOD_REC, player_name, ENEMY_REC_NAME)
    if bFind then
      return bFind, R_BLOOD
    end
  end
  return false
end
function search_relation_result(player, table_name, key_name, rec_name_index)
  if not player:FindRecord(table_name) then
    return false
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local player_name = nx_widestr(player:QueryRecord(table_name, nx_int(i), nx_int(rec_name_index)))
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(key_name)) then
      return true
    end
  end
  return false
end
