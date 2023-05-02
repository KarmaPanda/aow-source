require("form_stage_main\\form_relation\\relation_define")
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
require("util_gui")
require("util_functions")
require("game_object")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function InitInfo(is_success, player_name, player_title, player_level, player_photo, player_pk_step, player_scene, player_school, player_guild, player_guild_pos, player_sh)
  local gui = nx_value("gui")
  local searchForm = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", false, false)
  if nx_is_valid(searchForm) then
    searchForm:Close()
  end
  if nx_number(is_success) == -1 then
    return
  end
  if nx_number(is_success) == 1 then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_player_info", true, false)
    dialog.PlayerName = player_name
    local _, relation = nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "get_relation_type_by_name", player_name)
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    dialog:Show()
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
  else
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    dialog.cancel_btn.Visible = false
    local text = gui.TextManager:GetText("ui_sns_search_chazhao_no_result")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
  end
end
function on_main_form_close(self)
  self.Visible = false
  nx_destroy(self)
end
function on_btn_add_player_click(self)
  local form = self.ParentForm
  local name = nx_widestr(form.lbl_name.Text)
  if name == "" then
    return
  end
  sender_message(SUB_MSG_RELATION_ADD_APPLY, name, RELATION_TYPE_FRIEND, nx_int(-1))
  form:Close()
  return 1
end
function on_btn_attion_click(btn)
  local form = btn.ParentForm
  local name = nx_widestr(form.lbl_name.Text)
  if name == "" then
    return
  end
  sender_message(SUB_MSG_RELATION_ATTENTION_ADD, nx_widestr(name), RELATION_TYPE_ATTENTION, nx_int(-1))
  form:Close()
  return 1
end
function on_btn_filter_click(btn)
  local form = btn.ParentForm
  local name = nx_widestr(form.lbl_name.Text)
  if name == "" then
    return
  end
  sender_message(SUB_MSG_RELATION_ADD_SELF, nx_widestr(name), RELATION_TYPE_FLITER, nx_int(-1))
  form:Close()
  return 1
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function sender_message(submsg, name, relation_new, relation_old)
  nx_execute("custom_sender", "custom_add_relation", submsg, name, relation_new, relation_old)
end
