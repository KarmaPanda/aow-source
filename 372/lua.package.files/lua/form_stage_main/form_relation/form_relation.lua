require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
local FRIEND_TYPE = 1
local BUDDY_TYPE = 2
local BROTHER_TYPE = 3
local ENEMY_TYPE = 4
local BLOOD_TYPE = 5
local FILTER_TYPE = 6
local GUANZHU_TYPE = 7
local SUB_MSG_RELATION_ADD_APPLY = 1
local SUB_MSG_RELATION_ADD_CONFIRM = 2
local SUB_MSG_RELATION_ADD_CANCEL = 3
local SUB_MSG_RELATION_ADD_SELF = 4
local SUB_MSG_RELATION_ADD_BOTH = 5
local SUB_MSG_RELATION_REMOVE_SELF = 6
local SUB_MSG_RELATION_REMOVE_BOTH = 7
local SUB_MSG_RELATION_ATTENTION_ADD = 8
local SUB_MSG_RELATION_ATTENTION_REMOVE = 9
local SUB_MSG_RELATION_ADD_ENEMY = 10
local RELATION_TYPE_FRIEND = 0
local RELATION_TYPE_BUDDY = 1
local RELATION_TYPE_BROTHER = 2
local RELATION_TYPE_ENEMY = 3
local RELATION_TYPE_BLOOD = 4
local RELATION_TYPE_ATTENTION = 5
local RELATION_TYPE_ACQUAINT = 6
local RELATION_TYPE_FANS = 7
local RELATION_TYPE_FLITER = 8
local RELATION_TYPE_STRANGER = 9
function main_form_init(self)
  self.Fixed = true
  self.form_friend_list = nil
  self.isinit_form_friend_list = false
  self.form_friend_model_list = nil
  self.isinit_form_friend_model_list = false
  return 1
end
function main_form_open(self)
  InitPlayerListForm(self)
  return 1
end
function main_form_close(self)
  self.Visible = false
  if self.isinit_form_friend_list and nx_is_valid(self.form_friend_list) then
    nx_destroy(self.form_friend_list)
  end
  if self.isinit_form_friend_model_list and nx_is_valid(self.form_friend_model_list) then
    self.form_friend_model_list:Close()
  end
  nx_destroy(self)
  return 1
end
function on_size_change()
  local form = nx_value("form_stage_main\\form_relation\\form_relation")
  if nx_is_valid(form) then
    turn_to_full_screen(form)
  end
end
function turn_to_full_screen(self)
  local form = self
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.groupbox_playerlist.Left = 0
  form.groupbox_playerlist.Top = 80
  form.groupbox_playerlist.Width = form.Width
  form.groupbox_playerlist.Height = form.Height - 130
  form.groupbox_iteminfo.Left = form.Width - 600
  form.groupbox_iteminfo.Top = form.Height - 200
  form.add_btn.Left = form.Width - 500
  form.add_btn.Top = form.Height - 50
  form.btn_add_guanzhu.Left = form.Width - 400
  form.btn_add_guanzhu.Top = form.Height - 50
  form.btn_add_chouren.Left = form.Width - 300
  form.btn_add_chouren.Top = form.Height - 50
  form.btn_add_filter.Left = form.Width - 200
  form.btn_add_filter.Top = form.Height - 50
  form.cancel_btn.Left = form.Width - 100
  form.cancel_btn.Top = form.Height - 50
  if form.isinit_form_friend_list and nx_is_valid(form.form_friend_list) then
    form.form_friend_list.Left = 10
    form.form_friend_list.Top = 20
    form.form_friend_list.Height = form.Height - 170
    form.form_friend_list.groupbox_page.Top = form.Height - 220
  end
  if form.isinit_form_friend_model_list and nx_is_valid(form.form_friend_model_list) then
    form.form_friend_model_list.Left = 250
    form.form_friend_model_list.Top = 20
    form.form_friend_model_list.Width = form.Width - 300
    form.form_friend_model_list.Height = form.Height - 220
    form.form_friend_model_list.scenebox.Left = 0
    form.form_friend_model_list.scenebox.Top = 0
    form.form_friend_model_list.scenebox.Width = form.form_friend_model_list.Width
    form.form_friend_model_list.scenebox.Height = form.form_friend_model_list.Height
  end
end
function update_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_checked_changed(btn, playerType)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked == true and nx_is_valid(form.form_friend_list) then
    form.form_friend_list.PlayerType = playerType
    nx_execute("form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist", form.form_friend_list)
  end
end
function on_rbtn_friend_checked_changed(btn)
  on_rbtn_checked_changed(btn, FRIEND_TYPE)
end
function on_relation_add(name, relation, relation_old)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("ui_menu_friend_confirm_add", nx_widestr(name))
  nx_execute("form_stage_main\\form_relation\\form_relation_confirm", "show_common_text", dialog, text)
  nx_execute("form_stage_main\\form_relation\\form_relation_confirm", "get_arrest_flag", dialog, nx_widestr(name))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "relation_confirm_return")
  if res == "ok" then
    sender_message(nx_int(SUB_MSG_RELATION_ADD_ENEMY), nx_widestr(name), nx_int(RELATION_TYPE_ENEMY), nx_int(-1))
  elseif res == "ok_publish" then
    sender_message(nx_int(SUB_MSG_RELATION_ADD_ENEMY), nx_widestr(name), nx_int(RELATION_TYPE_ENEMY), nx_int(-1))
    nx_execute("form_stage_main\\form_arrest\\form_publish_arrest", "on_add_publish", name)
  elseif res == "ok_add_money" then
    nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "add_money", name)
  end
end
function on_rbtn_zhiyou_checked_changed(btn)
  on_rbtn_checked_changed(btn, BUDDY_TYPE)
end
function on_rbtn_xiongdi_checked_changed(btn)
  on_rbtn_checked_changed(btn, BROTHER_TYPE)
end
function on_rbtn_chouren_checked_changed(btn)
  on_rbtn_checked_changed(btn, ENEMY_TYPE)
end
function on_rbtn_xuechou_checked_changed(btn)
  on_rbtn_checked_changed(btn, BLOOD_TYPE)
end
function on_rbtn_guanzhu_checked_changed(btn)
  on_rbtn_checked_changed(btn, GUANZHU_TYPE)
end
function on_rbtn_blacklist_checked_changed(btn)
  on_rbtn_checked_changed(btn, FILTER_TYPE)
end
function on_cancel_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function interface_add_friend(name)
  sender_message(SUB_MSG_RELATION_ADD_APPLY, nx_widestr(name), RELATION_TYPE_FRIEND, nx_int(-1))
end
function interface_add_chouren(name)
  sender_message(SUB_MSG_RELATION_ADD_ENEMY, nx_widestr(name), RELATION_TYPE_ENEMY, nx_int(-1))
end
function interface_add_filter(name)
  sender_message(SUB_MSG_RELATION_ADD_SELF, nx_widestr(name), RELATION_TYPE_FLITER, nx_int(-1))
end
function interface_add_attention(name)
  sender_message(SUB_MSG_RELATION_ATTENTION_ADD, nx_widestr(name), RELATION_TYPE_ATTENTION, nx_int(-1))
end
function on_add_btn_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_add"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" and name ~= "" then
    sender_message(nx_int(SUB_MSG_RELATION_ADD_APPLY), nx_widestr(name), nx_int(RELATION_TYPE_FRIEND), nx_int(-1))
  end
end
function on_btn_add_chouren_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_add_chouren"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" and name ~= "" then
    sender_message(nx_int(SUB_MSG_RELATION_ADD_SELF), nx_widestr(name), nx_int(RELATION_TYPE_ENEMY), nx_int(-1))
  end
end
function on_btn_add_filter_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_add_filter"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" and name ~= "" then
    sender_message(nx_int(SUB_MSG_RELATION_ADD_SELF), nx_widestr(name), nx_int(RELATION_TYPE_FLITER), nx_int(-1))
  end
end
function on_btn_add_guanzhu_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_add_guanzhu"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" and name ~= "" then
    sender_message(nx_int(SUB_MSG_RELATION_ATTENTION_ADD), nx_widestr(name), nx_int(RELATION_TYPE_ATTENTION), nx_int(-1))
  end
end
function InitPlayerListForm(form)
  local form_friend_list = util_get_form("form_stage_main\\form_relation\\form_friend_list", true, false)
  if form.groupbox_playerlist:Add(form_friend_list) then
    form.isinit_form_friend_list = true
    form.form_friend_list = form_friend_list
    form.form_friend_list.Visible = true
    form.form_friend_list.Fixed = false
    form.form_friend_list.Left = 10
    form.form_friend_list.Top = 20
    form.form_friend_list.Height = form.Height - 170
    form.form_friend_list.groupbox_page.Top = form.Height - 220
  end
end
function InitPlayerModelListForm(form)
  local form_friend_model_list = util_get_form("form_stage_main\\form_relationship", true, false)
  if form.groupbox_playerlist:Add(form_friend_model_list) then
    form.isinit_form_friend_model_list = true
    form.form_friend_model_list = form_friend_model_list
    form.form_friend_model_list.Visible = true
    form.form_friend_model_list.Fixed = false
    form.form_friend_model_list.Left = 250
    form.form_friend_model_list.Top = 20
    form.form_friend_model_list.Width = form.Width - 300
    form.form_friend_model_list.Height = form.Height - 220
    form.form_friend_model_list.scenebox.Left = 0
    form.form_friend_model_list.scenebox.Top = 0
    form.form_friend_model_list.scenebox.Width = form.form_friend_model_list.Width
    form.form_friend_model_list.scenebox.Height = form.form_friend_model_list.Height
  end
end
function show_players_model(form)
  local role = nx_value("main_player")
  if not nx_is_valid(role) then
    return
  end
  local actor_role = role:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    actor_role = role
  end
  form.scenebox_players.Scene.camera.Fov = math.pi * 0.4
  form.scenebox_players.Scene.camera:SetPosition(0, 0.9, 3.2)
  form.scenebox_players.Scene.camera:YawAngle(math.pi)
  show_role_model(form.scenebox_players.Scene, actor_role, 0, 0.9, 1, 1)
end
function sender_message(submsg, name, relation_new, relation_old)
  nx_execute("custom_sender", "custom_add_relation", submsg, name, relation_new, relation_old)
end
function show_role_model(scene, actor, x, y, z, orient)
  nx_execute("form_stage_main\\form_relationship", "show_role_model", scene, actor, x, y, z, orient)
end
