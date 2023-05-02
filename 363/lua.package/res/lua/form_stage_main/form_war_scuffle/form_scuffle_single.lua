require("util_gui")
require("util_functions")
require("role_composite")
require("game_object")
require("scene")
require("custom_sender")
local CLIENT_CUSTOMMSG_LUAN_DOU = 784
local FORM_SCUFFLE_SINGLE = "form_stage_main\\form_war_scuffle\\form_scuffle_single"
local LuanDouClientMsg_RequestScoreUI = 104
function main_form_init(self)
  self.Fixed = true
  self.Actor2 = nx_null()
end
function on_main_form_open(self)
  local player = get_client_player()
  if nx_is_valid(player) then
    local name = player:QueryProp("Name")
    self.lbl_name.Text = nx_widestr(name)
    self.lbl_school.Text = get_school_name(player)
  end
  show_role_model(self)
  custom_request_my_achievement()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  if nx_find_custom(self, "Actor2") and nx_is_valid(self.Actor2) then
    self.scenebox_1.Scene:Delete(self.Actor2)
  end
  nx_execute("scene", "delete_scene", self.scenebox_1.Scene)
  nx_destroy(self)
end
function on_btn_person_rank_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_rank_path = "form_stage_main\\form_rank\\form_rank_main"
  local form_rank = nx_value(form_rank_path)
  if not nx_is_valid(form_rank) then
    form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_rank\\form_rank_main", true, false)
  end
  if not nx_is_valid(form_rank) then
    return
  end
  form_rank:Show()
  form_rank.Visible = true
  local rank_name = util_text("rank_5_guild_choswar_playerscroe")
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form_rank, rank_name)
end
function on_btn_guild_rank_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_rank_path = "form_stage_main\\form_rank\\form_rank_main"
  local form_rank = nx_value(form_rank_path)
  if not nx_is_valid(form_rank) then
    form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_rank\\form_rank_main", true, false)
  end
  if not nx_is_valid(form_rank) then
    return
  end
  form_rank:Show()
  form_rank.Visible = true
  local rank_name = util_text("rank_5_guild_choswar_guildscroe")
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form_rank, rank_name)
end
function custom_request_my_achievement()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_RequestScoreUI))
end
function rec_player_achievement(...)
  local form = nx_value(FORM_SCUFFLE_SINGLE)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(#arg) < nx_int(10) then
    return
  end
  form.lbl_attend_num.Text = nx_widestr(arg[1])
  form.lbl_win_num.Text = nx_widestr(arg[2])
  form.lbl_score.Text = nx_widestr(arg[3])
  form.lbl_kill.Text = nx_widestr(arg[4])
  form.lbl_assist.Text = nx_widestr(arg[5])
  form.lbl_rank.Text = nx_widestr(arg[6])
  form.lbl_guild_player_num.Text = nx_widestr(arg[7])
  form.lbl_guild_attend_num.Text = nx_widestr(arg[8])
  form.lbl_guild_kill.Text = nx_widestr(arg[9])
  form.lbl_guild_score.Text = nx_widestr(arg[10])
end
function show_role_model(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.Actor2) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_1)
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local role_actor2 = role_composite:CreateSceneObjectWithSubModel(form.scenebox_1.Scene, client_player, false, false, false)
  if not nx_is_valid(role_actor2) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:SetRoleClientIdent(role_actor2, client_player.Ident)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_1, role_actor2)
  form.Actor2 = role_actor2
  role_composite:PlayerVisPropChange(role_actor2, client_player, "Weapon")
  role_composite:PlayerVisPropChange(role_actor2, client_player, "ShotWeapon")
  local form_logic = nx_value("form_rp_arm_logic")
  if nx_is_valid(form_logic) then
    form_logic:ChangeActionByWeapon()
  end
  return
end
function get_role_face(role_actor2)
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function get_client_player()
  local client_player
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return client_player
  end
  client_player = client:GetPlayer()
  return client_player
end
function get_school_name(client_player)
  local text = nx_widestr("")
  if not nx_is_valid(client_player) then
    return text
  end
  if client_player:FindProp("School") and nx_string(client_player:QueryProp("School")) ~= nx_string("") then
    text = util_text(client_player:QueryProp("School"))
  elseif client_player:FindProp("Force") and nx_string(client_player:QueryProp("Force")) ~= nx_string("") then
    text = util_text(client_player:QueryProp("Force"))
  elseif client_player:FindProp("NewSchool") and nx_string(client_player:QueryProp("NewSchool")) ~= nx_string("") then
    text = util_text(client_player:QueryProp("NewSchool"))
  else
    text = util_text("school_wumenpai")
  end
  return text
end
