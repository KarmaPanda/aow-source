require("custom_sender")
require("util_gui")
local ST_FUNCTION_NEW_GUILDWAR = 219
local ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS = 789
function main_form_init(self)
  self.Fixed = true
  self.pos_list = nx_call("util_gui", "get_arraylist", nx_current() .. "_pos_list")
  self.selected = -1
  self.max_pos = -1
  self.is_captain = false
  self.can_chat = false
  self.can_accept = false
  self.can_appoint = false
  self.can_fire = false
  self.can_notice = false
  self.can_purpose = false
  self.can_storage = false
  self.authority_changed = false
  self.can_choose_point = false
  self.can_delete_point = false
  self.can_use_capital = false
  self.can_receive_custom_clothes = false
  self.can_dkp = false
  self.can_guild_war = false
end
function on_main_form_open(self)
  self.grp_pos.Visible = true
  self.groupbox_2.Visible = true
  self.cbtn_guild_war.Visible = false
  self.lbl_15.Visible = false
  self.lbl_17.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
      self.cbtn_guild_war.Visible = true
      self.lbl_17.Visible = true
    end
    if not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
      self.btn_plus.Visible = false
      self.btn_plus.Enabled = false
    end
  end
  return 1
end
function on_recv_position(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
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
function refresh_position()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  local cur_member = 0
  local max_member = 0
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
      cur_member = cur_member + pos_obj.cur_num
      max_member = max_member + pos_obj.max_num
    else
      btn.Visible = false
    end
  end
  form.lbl_10.Text = nx_widestr(nx_string(cur_member) .. "/" .. nx_string(max_member))
  if 0 > form.selected then
    form.selected = 1
  end
  form.rbtn_1.Checked = true
  refresh_authority(form.selected)
end
function refresh_authority(select)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
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
  set_can_click(form)
end
function on_btn_modify_click(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  if nx_int(form.selected) > nx_int(0) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_change_position_name", "on_change_position_name", nx_int(form.selected))
  end
end
function on_btn_ok_click(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  if form.authority_changed then
    custom_request_guild_set_authority(nx_int(form.selected), nx_int(form.can_chat), nx_int(form.can_accept), nx_int(form.can_appoint), nx_int(form.can_fire), nx_int(form.can_notice), nx_int(form.can_purpose), nx_int(form.can_storage), nx_int(form.can_choose_point), nx_int(form.can_delete_point), nx_int(form.can_use_capital), nx_int(form.can_receive_custom_clothes), nx_int(form.can_dkp), nx_int(form.can_guild_war))
  end
end
function on_btn_cancel_click(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  refresh_authority(form.selected)
end
function on_cbtn_chat_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_chat = btn.Checked
  form.authority_changed = true
end
function on_cbtn_accept_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_accept = btn.Checked
  form.authority_changed = true
end
function on_cbtn_appoint_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_appoint = btn.Checked
  form.authority_changed = true
end
function on_cbtn_fire_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_fire = btn.Checked
  form.authority_changed = true
end
function on_cbtn_notice_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_notice = btn.Checked
  form.authority_changed = true
end
function on_cbtn_purpose_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_purpose = btn.Checked
  form.authority_changed = true
end
function on_cbtn_storage_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_storage = btn.Checked
  form.authority_changed = true
end
function on_cbtn_choose_point_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_choose_point = btn.Checked
  form.authority_changed = true
end
function on_cbtn_delete_pointe_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_delete_point = btn.Checked
  form.authority_changed = true
end
function on_cbtn_can_dkp_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_dkp = btn.Checked
  form.authority_changed = true
end
function on_cbtn_guild_war_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  form.can_guild_war = btn.Checked
  form.authority_changed = true
end
function on_cbtn_use_capital_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.can_use_capital = btn.Checked
  form.authority_changed = true
end
function on_rbtn_checked_changed(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position")
  if not nx_is_valid(form) then
    return 0
  end
  if btn.Checked and nx_int(btn.DataSource) >= nx_int(0) then
    form.selected = nx_int(btn.DataSource)
    refresh_authority(form.selected)
  end
end
function on_main_form_close(self)
  self.pos_list:ClearChild()
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
function set_can_click(form)
  if not nx_is_valid(form) then
    return
  end
  form.pic_cover.Visible = not form.is_captain
end
function on_btn_plus_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_prosperity", "open_form")
end
