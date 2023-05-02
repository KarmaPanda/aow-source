require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\static_data_type")
require("share\\itemtype_define")
require("define\\tip_define")
require("util_static_data")
require("tips_data")
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  form.groupbox_chase.Visible = true
  form.groupbox_guild_war.Visible = false
  form.groupbox_crosswar.Visible = false
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function close_form()
  local form = nx_value("form_stage_main\\form_card\\form_card_skill")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_chase_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_chase.Visible = true
    form.groupbox_guild_war.Visible = false
    form.groupbox_crosswar.Visible = false
  end
end
function on_rbtn_guild_war_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_chase.Visible = false
    form.groupbox_guild_war.Visible = true
    form.groupbox_crosswar.Visible = false
  end
end
function on_rbtn_crosswar_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_chase.Visible = false
    form.groupbox_guild_war.Visible = false
    form.groupbox_crosswar.Visible = true
  end
end
function on_btn_crosswar_click(btn)
  local ST_GUILD_CROSS_WAR_AWITCH = 263
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_GUILD_CROSS_WAR_AWITCH) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("11781"))
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_join", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:Show()
end
function on_btn_member_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_captain = client_player:QueryProp("IsGuildCaptain")
  if nx_int(is_captain) ~= nx_int(2) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1000397"))
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_info_1", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:Show()
end
function open_chase_info()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_info")
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_chase.Checked = true
end
function open_guildwar_info()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_info")
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_guild_war.Checked = true
end
function on_btn_global_war_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and not switch_manager:CheckSwitchEnable(906) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("desc_events_250"))
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild", "open_form")
  nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_domain", "open_form_for_browse")
end
