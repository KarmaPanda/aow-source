function on_main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
end
function on_main_form_clost(self)
  nx_destroy(self)
end
function on_btn_add_invite_guild_click(btn)
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local self_guild = player_obj:QueryProp("GuildName")
  if nx_widestr(self_guild) == nx_widestr("") and nx_widestr(self_guild) == nx_widestr("0") then
    return
  end
  local form = btn.ParentForm
  form:Close()
  nx_execute("custom_sender", "custom_guild_invite_member", nx_widestr(form.sender_name))
end
function on_btn_team_request_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("custom_sender", "custom_team_invite", nx_string(form.sender_name))
end
function on_btn_friend_request_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", nx_string(form.sender_name))
end
function on_btn_add_attention_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", nx_string(form.sender_name))
end
function on_btn_add_chat_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.sender_name))
end
function on_btn_add_blacklist_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_filter", nx_string(form.sender_name))
end
function on_btn_search_guild_click(btn)
  local form = btn.ParentForm
  local sname = form.sender_name
  form:Close()
  nx_execute("custom_sender", "custom_send_get_player_game_info", sname)
end
function on_btn_send_mail_click(self)
  local form = self.ParentForm
  local sname = form.sender_name
  form:Close()
  nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
  local form_send_mail = nx_value("form_stage_main\\form_mail\\form_mail_send")
  if nx_is_valid(form_send_mail) then
    form_send_mail.targetname.Text = nx_widestr(sname)
  end
end
