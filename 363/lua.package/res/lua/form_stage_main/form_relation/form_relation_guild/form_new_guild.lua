require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
require("form_stage_main\\form_tvt\\define")
require("form_stage_main\\form_relation\\relation_define")
require("form_stage_main\\switch\\switch_define")
local FORM_PATH = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild"
local FORM_GUILD_INTRO_TOTAL = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_intro_total"
local FORM_GUILD_LEVELUP = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup"
local FORM_GUILD_ACTIVITY = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_activity"
local FORM_GUILD_MANAGE = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_manage"
local FORM_GUILD_WAR_INFO = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info"
local ST_FUNCTION_NEW_GUILD_FORM = 967
local CLOSE_GUILD_FORM_TIPS = "fsi_10"
function open_form()
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and not switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILD_FORM) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(CLOSE_GUILD_FORM_TIPS), 2)
    end
    return
  end
  if is_in_guild() then
    util_auto_show_hide_form(nx_current())
  elseif nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("19025"), 2)
  end
end
function auto_show_hide_form_new_guild(show)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and not switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILD_FORM) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(CLOSE_GUILD_FORM_TIPS), 2)
    end
    return
  end
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    form:Close()
  else
    util_show_form(FORM_PATH, true)
  end
  local form = nx_value(FORM_PATH)
  ui_show_attached_form(form)
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local groupbox = form.groupbox_all
  if not nx_is_valid(groupbox) then
    return
  end
  local form_intro_total = util_get_form(FORM_GUILD_INTRO_TOTAL, true, false)
  if nx_is_valid(form_intro_total) then
    form_intro_total.Visible = true
    form_intro_total.Fixed = true
    form_intro_total.Left = 4
    form_intro_total.Top = 0
    groupbox:Add(form_intro_total)
    form.form_intro_total = form_intro_total
  end
  local form_levelup = util_get_form(FORM_GUILD_LEVELUP, true, false)
  if nx_is_valid(form_levelup) then
    form_levelup.Visible = false
    form_levelup.Fixed = true
    form_levelup.Left = 4
    form_levelup.Top = 0
    groupbox:Add(form_levelup)
    form.form_levelup = form_levelup
  end
  form.rbtn_info.Checked = true
  custom_request_guild_authority()
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("GuildName", "wstring", form, nx_current(), "on_guild_name_change")
  end
  ui_show_attached_form(form)
  local timer = nx_value(GAME_TIMER)
  timer:Register(100, -1, nx_current(), "on_delay_open_1", form, -1, -1)
  timer:Register(200, -1, nx_current(), "on_delay_open_2", form, -1, -1)
end
function on_delay_open_1(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_delay_open_1", form)
  local groupbox = form.groupbox_all
  if not nx_is_valid(groupbox) then
    return
  end
  local form_manage = util_get_form(FORM_GUILD_MANAGE, true, false)
  if nx_is_valid(form_manage) then
    form_manage.Visible = false
    form_manage.Fixed = true
    form_manage.Left = 4
    form_manage.Top = 0
    groupbox:Add(form_manage)
    form.form_manage = form_manage
  end
  local form_activity = util_get_form(FORM_GUILD_ACTIVITY, true, false)
  if nx_is_valid(form_activity) then
    form_activity.Visible = false
    form_activity.Fixed = true
    form_activity.Left = 4
    form_activity.Top = 0
    groupbox:Add(form_activity)
    form.form_activity = form_activity
  end
end
function on_delay_open_2(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_delay_open_2", form)
  local groupbox = form.groupbox_all
  if not nx_is_valid(groupbox) then
    return
  end
  local form_war_info = util_get_form(FORM_GUILD_WAR_INFO, true, false)
  if nx_is_valid(form_war_info) then
    form_war_info.Visible = false
    form_war_info.Fixed = true
    form_war_info.Left = 4
    form_war_info.Top = 0
    groupbox:Add(form_war_info)
    form.form_war_info = form_war_info
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_delay_open_1", form)
  timer:UnRegister(nx_current(), "on_delay_open_2", form)
  ui_destroy_attached_form(form)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_manage_disband", "close_time")
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("GuildName", nx_current())
  end
  local GuildManager = nx_value("GuildManager")
  if nx_is_valid(GuildManager) then
    GuildManager:EndTimer()
  end
  close_all_sub_page(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return false
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  hide_all_sub_page(form)
  if "rbtn_info" == rbtn.Name then
    if not nx_find_custom(form, "form_intro_total") or not nx_is_valid(form.form_intro_total) then
      local form_intro_total = util_get_form(FORM_GUILD_INTRO_TOTAL, true, false)
      if nx_is_valid(form_intro_total) then
        form_intro_total.Visible = true
        form_intro_total.Fixed = true
        form_intro_total.Left = 4
        form_intro_total.Top = 0
        form.groupbox_all:Add(form_intro_total)
        form.form_intro_total = form_intro_total
      end
    end
    form.form_intro_total.Visible = true
    form:ToFront(form.form_intro_total)
  end
  if "rbtn_construct" == rbtn.Name then
    if not nx_find_custom(form, "form_levelup") or not nx_is_valid(form.form_levelup) then
      local form_levelup = util_get_form(FORM_GUILD_LEVELUP, true, false)
      if nx_is_valid(form_levelup) then
        form_levelup.Visible = true
        form_levelup.Fixed = true
        form_levelup.Left = 4
        form_levelup.Top = 0
        form.groupbox_all:Add(form_levelup)
        form.form_levelup = form_levelup
      end
    end
    form.form_levelup.Visible = true
    form:ToFront(form.form_levelup)
  end
  if "rbtn_activity" == rbtn.Name then
    if not nx_find_custom(form, "form_activity") or not nx_is_valid(form.form_activity) then
      local form_activity = util_get_form(FORM_GUILD_ACTIVITY, true, false)
      if nx_is_valid(form_activity) then
        form_activity.Visible = true
        form_activity.Fixed = true
        form_activity.Left = 4
        form_activity.Top = 0
        form.groupbox_all:Add(form_activity)
        form.form_activity = form_activity
      end
    end
    form.form_activity.Visible = true
    form:ToFront(form.form_activity)
  end
  if "rbtn_manager" == rbtn.Name then
    if not nx_find_custom(form, "form_manage") or not nx_is_valid(form.form_manage) then
      local form_manage = util_get_form(FORM_GUILD_MANAGE, true, false)
      if nx_is_valid(form_manage) then
        form_manage.Visible = true
        form_manage.Fixed = true
        form_manage.Left = 4
        form_manage.Top = 0
        form.groupbox_all:Add(form_manage)
        form.form_manage = form_manage
      end
    end
    form.form_manage.Visible = true
    form:ToFront(form.form_manage)
  end
  if "rbtn_diplomacy" == rbtn.Name then
    if not nx_find_custom(form, "form_war_info") or not nx_is_valid(form.form_war_info) then
      local form_war_info = util_get_form(FORM_GUILD_WAR_INFO, true, false)
      if nx_is_valid(form_war_info) then
        form_war_info.Visible = true
        form_war_info.Fixed = true
        form_war_info.Left = 4
        form_war_info.Top = 0
        form.groupbox_all:Add(form_war_info)
        form.form_war_info = form_war_info
      end
    end
    form.form_war_info.Visible = true
    form:ToFront(form.form_war_info)
  end
  form.lbl_1.Text = rbtn.Text
  return
end
function on_btn_help_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function hide_all_sub_page(form)
  if not nx_is_valid(form) then
    return false
  end
  if nx_find_custom(form, "form_intro_total") and nx_is_valid(form.form_intro_total) then
    form.form_intro_total.Visible = false
  end
  if nx_find_custom(form, "form_levelup") and nx_is_valid(form.form_levelup) then
    form.form_levelup.Visible = false
  end
  if nx_find_custom(form, "form_activity") and nx_is_valid(form.form_activity) then
    form.form_activity.Visible = false
  end
  if nx_find_custom(form, "form_manage") and nx_is_valid(form.form_manage) then
    form.form_manage.Visible = false
  end
  if nx_find_custom(form, "form_war_info") and nx_is_valid(form.form_war_info) then
    form.form_war_info.Visible = false
  end
  return true
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function close_all_sub_page(form)
  if not nx_is_valid(form) then
    return false
  end
  if nx_find_custom(form, "form_intro_total") and nx_is_valid(form.form_intro_total) then
    form.form_intro_total:Close()
  end
  if nx_find_custom(form, "form_levelup") and nx_is_valid(form.form_levelup) then
    form.form_levelup:Close()
  end
  if nx_find_custom(form, "form_activity") and nx_is_valid(form.form_activity) then
    form.form_activity:Close()
  end
  if nx_find_custom(form, "form_manage") and nx_is_valid(form.form_manage) then
    form.form_manage:Close()
  end
  if nx_find_custom(form, "form_war_info") and nx_is_valid(form.form_war_info) then
    form.form_war_info:Close()
  end
  return true
end
function is_in_guild()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("GuildName") then
    local guild_name = client_player:QueryProp("GuildName")
    if nx_widestr(guild_name) ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function open_cross_station_war()
  local form = util_get_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.rbtn_diplomacy.Checked = true
  local from_war_info = form.form_war_info
  if nx_is_valid(from_war_info) then
    from_war_info.rbtn_cross_station_war.Checked = true
  end
end
function open_guild_suits()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_2) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_2_SUIT) then
    return
  end
  local form = util_get_form(FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_activity.Checked = true
  nx_execute(FORM_GUILD_ACTIVITY, "open_form")
end
function open_guild_level_up()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_2) then
    return
  end
  local form = util_get_form(FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_construct.Checked = true
  nx_execute(FORM_GUILD_LEVELUP, "open_form")
end
function open_guild_championwar_desc()
  if is_in_guild() then
    local form = util_get_form(FORM_PATH, true)
    if not nx_is_valid(form) then
      return
    end
    form:Show()
    form.Visible = true
    form.rbtn_diplomacy.Checked = true
    local from_war_info = form.form_war_info
    if nx_is_valid(from_war_info) then
      from_war_info.rbtn_champion_war.Checked = true
      from_war_info.rbtn_cw_4.Checked = true
    end
  end
end
function open_guild_championwar_sc()
  if is_in_guild() then
    local form = util_get_form(FORM_PATH, true)
    if not nx_is_valid(form) then
      return
    end
    form:Show()
    form.Visible = true
    form.rbtn_diplomacy.Checked = true
    local from_war_info = form.form_war_info
    if nx_is_valid(from_war_info) then
      from_war_info.rbtn_champion_war.Checked = true
      from_war_info.rbtn_cw_1.Checked = true
    end
  end
end
function on_sync_member_list()
  local member_form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_member")
  if not nx_is_valid(member_form) then
    return
  end
  if not nx_find_custom(member_form, "btn_online") then
    return
  end
  if not nx_find_custom(member_form, "pageno_member") then
    return
  end
  if member_form.btn_online.Checked then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_member", "request_member_list", member_form.pageno_member)
  else
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_member", "request_online_member_list", member_form.pageno_member)
  end
end
function on_sync_candidate_list()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_member")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "pageno_candidate") then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_member", "request_candidate_list", form.pageno_candidate)
end
function on_guild_name_change(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("GuildName") then
    local guild_name = client_player:QueryProp("GuildName")
    if nx_widestr(guild_name) == nx_widestr("") then
      form:Close()
    end
  end
end
function switch_to_sub_form(top_rbtn_name, sub_form_name, sub_rbtn_name)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and not switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILD_FORM) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(CLOSE_GUILD_FORM_TIPS), 2)
    end
    return
  end
  if is_in_guild() then
    if not util_is_form_visible(nx_current()) then
      util_auto_show_hide_form(nx_current())
    end
  else
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19025"), 2)
    end
    return
  end
  local main_form = nx_value(nx_current())
  if not nx_is_valid(main_form) then
    return
  end
  local top_rbtn = nx_custom(main_form, nx_string(top_rbtn_name))
  if not nx_is_valid(top_rbtn) then
    return
  end
  local sub_form = nx_value(sub_form_name)
  if not nx_is_valid(sub_form) then
    return
  end
  local sub_rbtn = nx_custom(sub_form, nx_string(sub_rbtn_name))
  if not nx_is_valid(sub_rbtn) then
    return
  end
  sub_rbtn.Checked = true
  top_rbtn.Checked = true
end
