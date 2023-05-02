require("custom_sender")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local GUILD_POSITION = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_position"
function main_form_init(self)
  self.Fixed = true
  self.pos_list = nx_call("util_gui", "get_arraylist", nx_current() .. "_pos_list")
  self.selected = -1
  self.max_pos = -1
  self.can_chat = false
  self.can_accept = false
  self.can_appoint = false
  self.can_fire = false
  self.can_notice = false
  self.can_purpose = false
  self.can_storage = false
  self.can_choose_point = false
  self.can_delete_point = false
  self.can_use_capital = false
  self.can_receive_custom_clothes = false
  self.can_dkp = false
  self.can_guild_war = false
  self.authority_changed = false
  self.invent_condition = false
  self.invite_ability = 0
end
function on_main_form_open(self)
  self.cbtn_guild_war.Visible = false
  self.lbl_17.Visible = false
  request_invent_condition()
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    self.cbtn_guild_war.Visible = true
    self.lbl_17.Visible = true
  end
  return 1
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  self.pos_list:ClearChild()
  nx_destroy(self)
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_position")
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked and nx_int(rbtn.DataSource) >= nx_int(0) then
    form.selected = nx_int(rbtn.DataSource)
    refresh_authority(form.selected)
  end
end
function refresh_authority(select)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return
  end
  pos_obj = form.pos_list:GetChild(nx_string(select))
  if nx_is_valid(pos_obj) then
    form.cbtn_chat.Checked = pos_obj.can_chat
    form.can_chat = pos_obj.can_chat
    form.cbtn_accept.Checked = pos_obj.can_accept
    form.can_accept = pos_obj.can_accept
    form.cbtn_appoint.Checked = pos_obj.can_appoint
    form.can_appoint = pos_obj.can_appoint
    form.cbtn_fire.Checked = pos_obj.can_fire
    form.can_fire = pos_obj.can_fire
    form.cbtn_notice.Checked = pos_obj.can_notice
    form.can_notice = pos_obj.can_notice
    form.cbtn_purpose.Checked = pos_obj.can_purpose
    form.can_purpose = pos_obj.can_purpose
    form.cbtn_storage.Checked = pos_obj.can_storage
    form.can_storage = pos_obj.can_storage
    form.cbtn_choose_point.Checked = pos_obj.can_choose_point
    form.can_choose_point = pos_obj.can_choose_point
    form.cbtn_delete_point.Checked = pos_obj.can_delete_point
    form.can_delete_point = pos_obj.can_delete_point
    form.cbtn_use_capital.Checked = pos_obj.can_use_capital
    form.can_use_capital = pos_obj.can_use_capital
    form.cbtn_receive_custom_clothes.Checked = pos_obj.can_receive_custom_clothes
    form.can_receive_custom_clothes = pos_obj.can_receive_custom_clothes
    form.cbtn_can_dkp.Checked = pos_obj.can_dkp
    form.can_dkp = pos_obj.can_dkp
    form.cbtn_guild_war.Checked = pos_obj.can_guild_war
    form.can_guild_war = pos_obj.can_guild_war
    form.authority_changed = false
  end
end
function on_cbtn_chat_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_chat = btn.Checked
  form.authority_changed = true
end
function on_cbtn_accept_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_accept = btn.Checked
  form.authority_changed = true
end
function on_cbtn_appoint_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_appoint = btn.Checked
  form.authority_changed = true
end
function on_cbtn_fire_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_fire = btn.Checked
  form.authority_changed = true
end
function on_cbtn_notice_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_notice = btn.Checked
  form.authority_changed = true
end
function on_cbtn_purpose_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_purpose = btn.Checked
  form.authority_changed = true
end
function on_cbtn_storage_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_storage = btn.Checked
  form.authority_changed = true
end
function on_cbtn_choose_point_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_choose_point = btn.Checked
  form.authority_changed = true
end
function on_cbtn_delete_pointe_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_delete_point = btn.Checked
  form.authority_changed = true
end
function on_cbtn_receive_custom_clothes_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_receive_custom_clothes = btn.Checked
  form.authority_changed = true
end
function on_cbtn_can_dkp_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_dkp = btn.Checked
  form.authority_changed = true
end
function on_cbtn_guild_war_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_guild_war = btn.Checked
  form.authority_changed = true
end
function on_cbtn_use_capital_checked_changed(btn)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  form.can_use_capital = btn.Checked
  form.authority_changed = true
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.authority_changed then
    custom_request_guild_set_authority(nx_int(form.selected), nx_int(form.can_chat), nx_int(form.can_accept), nx_int(form.can_appoint), nx_int(form.can_fire), nx_int(form.can_notice), nx_int(form.can_purpose), nx_int(form.can_storage), nx_int(form.can_choose_point), nx_int(form.can_delete_point), nx_int(form.can_use_capital), nx_int(form.can_receive_custom_clothes), nx_int(form.can_dkp), nx_int(form.can_guild_war))
  end
  if form.invent_condition then
    custom_request_guild_set_suggest(nx_int(form.invite_ability))
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  refresh_authority(form.selected)
  request_invent_condition()
end
function refresh_position()
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  for i = 1, 8 do
    local btn = form.grp_pos:Find("rbtn_" .. nx_string(i))
    if not nx_is_valid(btn) then
      break
    end
    local pos_obj = form.pos_list:GetChild(nx_string(i))
    if nx_is_valid(pos_obj) then
      if is_default_name(pos_obj.name) then
        local show_name = nx_widestr(util_text(nx_string(pos_obj.name))) .. nx_widestr(" ") .. nx_widestr(pos_obj.cur_num) .. nx_widestr("/") .. nx_widestr(pos_obj.max_num)
        btn.Text = nx_widestr(show_name)
      else
        local show_name = nx_string(pos_obj.name) .. " " .. nx_string(pos_obj.cur_num) .. "/" .. nx_string(pos_obj.max_num)
        btn.Text = nx_widestr(show_name)
      end
      btn.Visible = true
    else
      btn.Visible = false
    end
  end
  if 0 > form.selected then
    form.selected = 1
  end
  form.rbtn_1.Checked = true
  refresh_authority(form.selected)
end
function is_default_name(pos_name)
  if nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level1_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level2_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level3_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level4_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level5_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level6_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level7_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level8_name") then
    return true
  end
  return false
end
function on_recv_position(...)
  local form = nx_value(GUILD_POSITION)
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size ~= 18 then
    return 0
  end
  local pos_obj = nx_null()
  if not form.pos_list:FindChild(nx_string(arg[4])) then
    pos_obj = form.pos_list:CreateChild(nx_string(arg[4]))
  else
    pos_obj = form.pos_list:GetChild(nx_string(arg[4]))
  end
  pos_obj.name = nx_widestr(arg[1])
  pos_obj.cur_num = nx_int(arg[2])
  pos_obj.max_num = nx_int(arg[3])
  if nx_int(arg[4]) > nx_int(form.max_pos) then
    form.max_pos = nx_int(arg[4])
  end
  local begin_index = 5
  pos_obj.is_default = nx_int(arg[begin_index]) ~= nx_int(0)
  pos_obj.can_chat = nx_int(arg[begin_index + 1]) == nx_int(1)
  pos_obj.can_accept = nx_int(arg[begin_index + 2]) == nx_int(1)
  pos_obj.can_appoint = nx_int(arg[begin_index + 3]) == nx_int(1)
  pos_obj.can_fire = nx_int(arg[begin_index + 4]) == nx_int(1)
  pos_obj.can_notice = nx_int(arg[begin_index + 5]) == nx_int(1)
  pos_obj.can_purpose = nx_int(arg[begin_index + 6]) == nx_int(1)
  pos_obj.can_storage = nx_int(arg[begin_index + 7]) == nx_int(1)
  pos_obj.can_choose_point = nx_int(arg[begin_index + 8]) == nx_int(1)
  pos_obj.can_delete_point = nx_int(arg[begin_index + 9]) == nx_int(1)
  pos_obj.can_use_capital = nx_int(arg[begin_index + 10]) == nx_int(1)
  pos_obj.can_receive_custom_clothes = nx_int(arg[begin_index + 11]) == nx_int(1)
  pos_obj.can_dkp = nx_int(arg[begin_index + 12]) == nx_int(1)
  pos_obj.can_guild_war = nx_int(arg[begin_index + 13]) == nx_int(1)
  refresh_position()
end
function request_invent_condition()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  if guild_name == "" then
    return
  end
  nx_execute("custom_sender", "custom_request_join_suggest", guild_name)
end
function on_rbtn_invent_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.invite_ability = rbtn.DataSource
    form.invent_condition = true
  end
end
function on_msg(...)
  local form = util_get_form(GUILD_POSITION, false, false)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 2 then
    return
  end
  form.invite_ability = nx_int(arg[2])
  refresh_invent_condition(form)
end
function refresh_invent_condition(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.invite_ability) < nx_int(1) then
    form.invite_ability = 1
  end
  local rbtn = form.groupbox_1:Find("rbtn_level_" .. nx_string(form.invite_ability))
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Checked = true
  form.invent_condition = false
end
