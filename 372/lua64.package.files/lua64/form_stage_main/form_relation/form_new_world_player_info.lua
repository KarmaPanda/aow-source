require("util_gui")
require("util_functions")
require("form_stage_main\\form_relation\\relation_define")
local FORM_NAME = "form_stage_main\\form_relation\\form_new_world_player_info"
local CLIENT_MSG_JHPK_TRANS = 1
local CLIENT_MSG_JHPK_CALLUP = 2
local CLIENT_MSG_JHPK_REJECT_REQUEST = 10
function main_form_init(self)
  self.Fixed = false
  self.PlayerName = ""
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(self)
  self.Visible = false
  nx_destroy(self)
end
function reset_scene()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function on_btn_chat_click(btn)
  scene_jhpk_chat(nx_widestr(btn.ParentForm.PlayerName))
end
function on_btn_goto_click(btn)
  scene_jhpk_goto(nx_widestr(btn.ParentForm.PlayerName))
end
function on_btn_bund_click(btn)
  scene_jhpk_bund(nx_widestr(btn.ParentForm.PlayerName))
end
function on_btn_callup_click(btn)
  scene_jhpk_callup(nx_widestr(btn.ParentForm.PlayerName))
end
function on_btn_copyname_click(btn)
  nx_function("ext_copy_wstr", nx_widestr(btn.ParentForm.PlayerName))
end
function on_be_bund(friend_name, enemy_name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_systemfriends_04", nx_widestr(friend_name), nx_widestr(enemy_name)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    nx_execute("custom_sender", "custom_send_scene_jhpk", CLIENT_MSG_JHPK_REJECT_REQUEST, nx_widestr(friend_name))
    return
  end
  nx_execute("custom_sender", "custom_add_relation", nx_int(10), nx_widestr(enemy_name), nx_int(3), nx_int(0))
end
function on_be_callup(name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_systemfriends_11", nx_widestr(name)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  scene_jhpk_goto(nx_widestr(name))
end
function on_look_up_jhpk_msg(player_name, player_level, player_photo, player_scene, player_school, player_guild, zone)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(dialog) then
    return
  end
  gui.Desktop:ToFront(dialog)
  dialog.PlayerName = player_name
  dialog.player_scene = player_scene
  local _, relation = nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "get_relation_type_by_name", player_name)
  dialog:Show()
  dialog.btn_goto.Enabled = true
  dialog.btn_bund.Enabled = true
  dialog.btn_callup.Enabled = true
  if relation == RELATION_TYPE_ENEMY or relation == RELATION_TYPE_BLOOD or relation == RELATION_TYPE_ATTENTION or relation == RELATION_TYPE_ACQUAINT or relation == RELATION_TYPE_FANS or relation == RELATION_TYPE_FLITER or relation == RELATION_TYPE_STRANGER then
    dialog.btn_goto.Enabled = false
    dialog.btn_bund.Enabled = false
    dialog.btn_callup.Enabled = false
  end
  local player_relation = "ui_wu"
  if relation == RELATION_TYPE_FRIEND then
    player_relation = "ui_menu_friend_item_haoyou"
  elseif relation == RELATION_TYPE_BUDDY then
    player_relation = "ui_menu_friend_item_zhiyou"
  elseif relation == RELATION_TYPE_ENEMY then
    player_relation = "ui_menu_friend_item_chouren"
  elseif relation == RELATION_TYPE_BLOOD then
    player_relation = "ui_menu_friend_item_xuechou"
  elseif relation == RELATION_TYPE_ATTENTION then
    player_relation = "ui_menu_friend_item_guanzhu"
  end
  player_relation = util_text(player_relation)
  dialog.lbl_name.Text = nx_widestr(player_name)
  dialog.lbl_photo.BackImage = player_photo
  dialog.lbl_school_text.Text = nx_widestr(player_school)
  dialog.lbl_guild_text.Text = nx_widestr(player_guild)
  dialog.lbl_guanxi_text.Text = nx_widestr(player_relation)
  dialog.lbl_shili_text.Text = nx_widestr(player_level)
  dialog.lbl_zone_text.Text = nx_widestr(zone)
  dialog.lbl_scene_text.Text = nx_widestr(gui.TextManager:GetText(player_scene))
end
function scene_jhpk_goto(target_name)
  nx_execute("custom_sender", "custom_send_scene_jhpk", CLIENT_MSG_JHPK_TRANS, nx_widestr(target_name))
end
function scene_jhpk_callup(target_name)
  nx_execute("custom_sender", "custom_send_scene_jhpk", CLIENT_MSG_JHPK_CALLUP, nx_widestr(target_name))
end
function scene_jhpk_chat(target_name)
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(target_name))
end
function scene_jhpk_bund(target_name)
  nx_execute("form_stage_main\\form_relation\\form_scene_jhpk_relation", "custom_jhpk_bund", nx_widestr(target_name))
end
