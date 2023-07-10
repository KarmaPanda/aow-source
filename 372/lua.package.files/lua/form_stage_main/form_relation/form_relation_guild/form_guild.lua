require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
require("form_stage_main\\form_tvt\\define")
require("form_stage_main\\form_relation\\relation_define")
local CONTROL_SPACE = 20
local ST_FUNCTION_GUILD_LUCK_JITIAN = 640
local ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS = 789
function open_form()
  if is_in_guild() then
    util_auto_show_hide_form(nx_current())
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19025"), 2)
    end
  end
end
function auto_show_hide_form_guild(show)
  local skin_path = "form_stage_main\\form_relation\\form_relation_guild\\form_guild"
  local form = nx_value(skin_path)
  if nx_is_valid(form) then
    form:Close()
  else
    util_show_form(skin_path, true)
  end
  local form = nx_value(skin_path)
  ui_show_attached_form(form)
end
function main_form_init(self)
  self.Fixed = false
  self.FirstOpen = true
  self.NoticeAuth = true
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  resize_form_size(self)
  if self.FirstOpen then
    local page_notice = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_notice", true, false)
    if self.groupbox_notice:Add(page_notice) then
      self.page_notice = page_notice
      self.page_notice.Visible = true
      self.page_notice.Fixed = true
      self.page_notice.Left = 10
      self.page_notice.Top = 5
    end
    local page_member = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", true, false)
    if self.groupbox_bg_out:Add(page_member) then
      self.page_member = page_member
      self.page_member.Visible = false
      self.page_member.Fixed = true
      self.page_member.Left = 4
      self.page_member.Top = 78
      self.page_member.btn_invite.have_right = false
    end
    local page_candidate = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_candidate", true, false)
    if self.groupbox_bg_out:Add(page_candidate) then
      self.page_candidate = page_candidate
      self.page_candidate.Visible = false
      self.page_candidate.Fixed = true
      self.page_candidate.Left = 190
      self.page_candidate.Top = 78
    end
    local page_manage = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_manage", true, false)
    if self.groupbox_bg_out:Add(page_manage) then
      self.page_manage = page_manage
      self.page_manage.Visible = false
      self.page_manage.Fixed = true
      self.page_manage.Left = 2
      self.page_manage.Top = 75
    end
    local page_info = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info_frame", true, false)
    if self.groupbox_bg_out:Add(page_info) then
      self.page_info = page_info
      self.page_info.Visible = false
      self.page_info.Fixed = true
      self.page_info.Left = 4
      self.page_info.Top = 71
    end
    local page_drawings = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_drawings", true, false)
    if self.groupbox_bg_out:Add(page_drawings) then
      self.page_drawings = page_drawings
      self.page_drawings.Visible = false
      self.page_drawings.Fixed = true
      self.page_drawings.Left = 4
      self.page_drawings.Top = 68
    end
    local page_league = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_league", true, false)
    if self.groupbox_bg_out:Add(page_league) then
      self.page_league = page_league
      self.page_league.Visible = false
      self.page_league.Fixed = true
      self.page_league.Left = 5
      self.page_league.Top = 45
      self:ToBack(page_league)
    end
    local domaininfo = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_domain_info", true, false)
    if self.groupbox_bg_out:Add(domaininfo) then
      self.page_domaininfo = domaininfo
      self.page_domaininfo.Left = 0
      self.page_domaininfo.Top = 65
      self.page_domaininfo.Visible = false
    end
    local form_courtfire_info = util_get_form("form_stage_main\\form_guild_fire\\form_courtfire_info", true, false)
    if self.groupbox_bg_out:Add(form_courtfire_info) then
      self.form_courtfire_info = form_courtfire_info
      self.form_courtfire_info.Left = -1
      self.form_courtfire_info.Top = 69
    end
    local form_guild_dkp = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_dkp", true, false)
    if self.groupbox_bg_out:Add(form_guild_dkp) then
      self.page_dkp = form_guild_dkp
      self.page_dkp.Left = 0
      self.page_dkp.Top = 65
      self.page_dkp.Visible = false
    end
    local form_guild_auth = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_authentication", true, false)
    if self.groupbox_bg_out:Add(form_guild_auth) then
      self.page_auth = form_guild_auth
      self.page_auth.Left = 0
      self.page_auth.Top = 65
      self.page_auth.Visible = false
    end
    local form_guild_war_info = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_info", true, false)
    if self.groupbox_bg_out:Add(form_guild_war_info) then
      self.page_guild_war_info = form_guild_war_info
      self.page_guild_war_info.Left = 0
      self.page_guild_war_info.Top = 65
      self.page_guild_war_info.Visible = false
    end
    local form_guild_pray = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_pray", true, false)
    if self.groupbox_bg_out:Add(form_guild_pray) then
      self.page_luck_pray = form_guild_pray
      self.page_luck_pray.Left = 0
      self.page_luck_pray.Top = 65
      self.page_luck_pray.Visible = false
    end
    self.FirstOpen = false
  end
  custom_request_basic_guild_info()
  custom_guild_get_logo()
  custom_request_guild_intro_info()
  custom_request_guild_authority()
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("GuildName", "wstring", self, nx_current(), "on_guild_name_change")
  end
  self.rbtn_info.Checked = true
  self.btn_open_right.Visible = false
  self.sender_menu.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    self.btn_plus.Visible = false
    self.btn_plus.Enabled = false
  end
end
function on_size_change()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if nx_is_valid(form) then
    resize_form_size(form)
  end
end
function on_guild_contri_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("GuildContribute") then
    local contribute = client_player:QueryProp("GuildContribute")
    form.lbl_contribution.Text = guild_util_get_text("ui_guild_contribution", nx_int64(contribute))
  end
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
function on_main_form_close(self)
  ui_destroy_attached_form(form)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_manage_disband", "close_time")
  local form_tvt_info = nx_value("form_stage_main\\form_tvt\\form_tvt_info")
  if nx_is_valid(form_tvt_info) then
    form_tvt_info:Close()
  end
  if nx_is_valid(self.page_domaininfo) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_domain_info", "close_preview")
  end
  local GuildManager = nx_value("GuildManager")
  if nx_is_valid(GuildManager) then
    GuildManager:EndTimer()
  end
  self.Visible = false
  nx_destroy(self)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function show_infor_label(form)
  form.groupbox_left.Visible = true
  form.btn_open_right.Visible = false
  form.btn_close_right.Visible = true
  form.Width = form.groupbox_bg_out.Width + form.groupbox_left.Width + 10
end
function on_recv_basic_info(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form) or table.getn(arg) ~= 14 then
    return 0
  end
  local guild_name = nx_widestr(arg[1])
  local level = nx_int(arg[2])
  local hotness = nx_int(arg[11])
  local all = nx_int(arg[14])
  local online = nx_int(arg[13])
  form.lbl_name.Text = guild_util_get_text("ui_guild_full_name", nx_widestr(guild_name))
  form.lbl_level.Text = guild_util_get_text("ui_guild_lv", nx_int(level))
  form.lbl_hotness.Text = guild_util_get_text("ui_guild_hotness1", nx_int(hotness))
  form.lbl_member_count.Text = guild_util_get_text("ui_guild_member_count", nx_int(all), nx_int(online))
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form_relationship) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryProp("Name")
  local gui = nx_value("gui")
  form_relationship.mltbox_title.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_sns_backbutton1", name) .. gui.TextManager:GetFormatText("ui_sns_backbutton18", nx_int(1)) .. gui.TextManager:GetFormatText("ui_sns_backbutton19", nx_int(all)))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_open_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_left.Visible = true
  form.btn_close_right.Visible = true
  btn.Visible = false
  form.Width = form.groupbox_bg_out.Width + form.groupbox_left.Width + 10
end
function on_btn_close_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_left.Visible = false
  form.btn_open_right.Visible = true
  btn.Visible = false
  form.Width = form.groupbox_bg_out.Width + 10
end
function on_rbtn_member_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_member) then
    local page_member = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", true, false)
    if form:Add(page_member) then
      form.page_member = page_member
      form.page_member.Visible = false
      form.page_member.Fixed = true
      form.page_member.Left = 190
      form.page_member.Top = 130
      form.page_member.btn_invite.have_right = false
    end
  end
  custom_request_guild_authority()
  form.page_member.Visible = true
  form.page_member.rbtn_member_list.Checked = true
  form:ToFront(form.page_member)
  if form.page_member.btn_online.Checked then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "request_member_list", form.page_member.pageno)
  else
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "request_online_member_list", form.page_member.pageno)
  end
  form.lbl_1.Text = btn.Text
  return 1
end
function on_rbtn_authority_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_manage) then
    local page_manage = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_manage", true, false)
    if self.groupbox_bg_out:Add(page_manage) then
      self.page_manage = page_manage
      self.page_manage.Visible = false
      self.page_manage.Fixed = true
      self.page_manage.Left = 27
      self.page_manage.Top = 130
    end
  end
  form.page_manage.Visible = true
  form:ToFront(form.page_manage)
  form.lbl_1.Text = btn.Text
  return
end
function on_rbtn_info_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_info) then
    local page_info = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_info_frame", true, false)
    if self.groupbox_bg_out:Add(page_info) then
      self.page_info = page_info
      self.page_info.Visible = false
      self.page_info.Fixed = true
      self.page_info.Left = 27
      self.page_info.Top = 130
    end
  end
  if not nx_is_valid(form.page_notice) then
    local page_notice = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_notice", true, false)
    if form.groupbox_bg_out:Add(page_notice) then
      form.page_notice = page_notice
      form.page_notice.Visible = false
      form.page_notice.Fixed = true
      form.page_notice.Left = 50
      form.page_notice.Top = 250
    end
  end
  form.page_info.Visible = true
  form.page_notice.Visible = true
  form:ToFront(form.page_info)
  form:ToFront(form.page_notice)
  form.lbl_1.Text = btn.Text
  return
end
function on_rbtn_drawings_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_drawings) then
    local page_drawings = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_drawings", true, false)
    if form.groupbox_bg_out:Add(page_drawings) then
      form.page_drawings = page_drawings
      form.page_drawings.Visible = false
      form.page_drawings.Fixed = true
      form.page_drawings.Left = 4
      form.page_drawings.Top = 38
    end
  end
  form.lbl_1.Text = btn.Text
  form.page_drawings.Visible = true
  form.groupbox_left.Visible = false
  form.btn_open_right.Visible = false
  form.btn_close_right.Visible = false
  form.groupbox_bg_out.Width = form.groupbox_bg_out.Width + form.groupbox_left.Width + 10
  form.Width = form.groupbox_bg_out.Width + 10
end
function on_rbtn_league_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_league) then
    local page_league = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\page_league", true, false)
    if form.groupbox_bg_out:Add(page_league) then
      self.page_league = page_league
      self.page_league.Visible = false
      self.page_league.Fixed = true
      self.page_league.Left = 5
      self.page_league.Top = 120
    end
  end
  form.lbl_1.Text = btn.Text
  form.page_league.Visible = true
end
function on_rbtn_pos_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local level = string.sub(nx_string(rbtn.Name), -1, -1)
  local SUB_CUSTOMMSG_REQUEST_MEMBER_LIST_BY_POSITION = 55
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_MEMBER_LIST_BY_POSITION), nx_int(level))
  end
  local parent = rbtn.Parent
  local pre_name = "lbl_bg_"
  for i = 1, 4 do
    label_bg_name = pre_name .. nx_string(i)
    local label_bg = parent:Find(label_bg_name)
    if not nx_is_valid(label_bg) then
      return
    end
    if nx_int(i) == nx_int(level) then
      label_bg.Visible = true
    else
      label_bg.Visible = false
    end
  end
end
function on_rbtn_domaininfo_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_domaininfo) then
    local domaininfo = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_domain_info", true, false)
    if form:Add(domaininfo) then
      form.page_domaininfo = domaininfo
      form.page_domaininfo.Left = 0
      form.page_domaininfo.Top = 65
    end
  end
  form.lbl_1.Text = btn.Text
  form.page_domaininfo.Visible = true
end
function on_rbtn_cf_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.form_courtfire_info) then
    local form_courtfire_info = util_get_form("form_stage_main\\form_guild_fire\\form_courtfire_info", true, false)
    if form.groupbox_bg_out:Add(form_courtfire_info) then
      form.form_courtfire_info = form_courtfire_info
      form.form_courtfire_info.Left = -1
      form.form_courtfire_info.Top = 69
    end
  end
  form.lbl_1.Text = rbtn.Text
  form.form_courtfire_info.Visible = true
end
function on_rbtn_dkp_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_dkp) then
    local form_dkp = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_dkp", true, false)
    if form.groupbox_bg_out:Add(form_dkp) then
      form.page_dkp = form_dkp
      form.page_dkp.Left = 5
      form.page_dkp.Top = 120
    end
  end
  form.lbl_1.Text = rbtn.Text
  form.page_dkp.Visible = true
  form.groupbox_left.Visible = false
  form.btn_open_right.Visible = false
  form.btn_close_right.Visible = false
  form.groupbox_bg_out.Width = form.groupbox_bg_out.Width + form.groupbox_left.Width + 10
  form.Width = form.groupbox_bg_out.Width + 10
end
function on_rbtn_auth_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_auth) then
    local form_auth = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_authentication", true, false)
    if form.groupbox_bg_out:Add(form_auth) then
      form.page_auth = form_auth
      form.page_auth.Left = 5
      form.page_auth.Top = 120
    end
  end
  form.lbl_1.Text = rbtn.Text
  form.page_auth.Visible = true
end
function on_rbtn_war_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_guild_war_info) then
    local form_guild_war_info = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_info", true, false)
    if form.groupbox_bg_out:Add(form_guild_war_info) then
      form.page_guild_war_info = form_guild_war_info
      form.page_guild_war_info.Left = 5
      form.page_guild_war_info.Top = 120
    end
  end
  form.lbl_1.Text = rbtn.Text
  form.page_guild_war_info.Visible = true
end
function on_rbtn_luck_checked_changed(rbtn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(nx_int(ST_FUNCTION_GUILD_LUCK_JITIAN)) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_page(form)
  show_infor_label(form)
  if not nx_is_valid(form.page_luck_pray) then
    local form_guild_pray = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_pray", true, false)
    if form.groupbox_bg_out:Add(form_guild_pray) then
      form.page_luck_pray = form_guild_pray
      form.page_luck_pray.Left = 5
      form.page_luck_pray.Top = 120
    end
  end
  form.lbl_1.Text = rbtn.Text
  form.page_luck_pray.Visible = true
end
function on_member_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  if nx_find_custom(btn, "member_name") then
    nx_execute("form_stage_main\\form_relationship", "focus_player_model", RELATION_SUB_GROUP_BANGPAI, 0, nx_widestr(btn.member_name))
  end
end
function on_member_right_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(btn, "member_name") then
    return
  end
  if form.sender_menu.Visible then
    form.sender_menu.Visible = false
    return
  end
  local playername = nx_widestr(btn.member_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return false
  end
  local role_name = game_role:QueryProp("Name")
  if playername == role_name then
    form.sender_menu.Visible = false
    return
  end
  if playername == "" then
    form.sender_menu.Visible = false
    return
  end
  if form.sender_menu.Visible == true then
    form.sender_menu.Visible = false
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  if x + form.sender_menu.Width > form.AbsLeft + form.Width - 30 then
    form.sender_menu.AbsLeft = x - form.sender_menu.Width
  else
    form.sender_menu.AbsLeft = x
  end
  if y + form.sender_menu.Height > form.Height then
    form.sender_menu.AbsTop = y - form.sender_menu.Height
  else
    form.sender_menu.AbsTop = y
  end
  form.sender_menu.Visible = true
  form.sender_name = playername
end
function on_btn_show_right_click(btn)
  local form = btn.ParentForm
  if not form.groupbox_right.Visible then
    btn.NormalImage = "gui\\special\\sns_new\\btn_news1_out.png"
    btn.FocusImage = "gui\\special\\sns_new\\btn_news1_on.png"
    form.groupbox_right.Visible = true
  else
    btn.NormalImage = "gui\\special\\sns_new\\btn_news2_out.png"
    btn.FocusImage = "gui\\special\\sns_new\\btn_news2_on.png"
    form.groupbox_right.Visible = false
  end
end
function on_btn_down_click(btn)
  local form = btn.ParentForm
  form.groupscrollbox_member_list.VScrollBar.Value = form.groupscrollbox_member_list.VScrollBar.Maximum
end
function hide_all_sub_page(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.page_member) then
    form.page_member.Visible = false
    form.page_member.sender_menu.Visible = false
  end
  if nx_is_valid(form.page_candidate) then
    form.page_candidate.Visible = false
  end
  if nx_is_valid(form.page_manage) then
    form.page_manage.Visible = flase
  end
  if nx_is_valid(form.page_info) then
    form.page_info.Visible = false
  end
  if nx_is_valid(form.page_drawings) then
    form.page_drawings.Visible = false
  end
  if nx_is_valid(form.page_league) then
    form.page_league.Visible = false
  end
  if nx_is_valid(form.page_domaininfo) then
    form.page_domaininfo.Visible = false
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_domain_info", "close_preview")
  end
  if nx_is_valid(form.form_courtfire_info) then
    form.form_courtfire_info.Visible = false
  end
  if nx_is_valid(form.page_dkp) then
    form.page_dkp.Visible = false
  end
  if nx_is_valid(form.page_auth) then
    form.page_auth.Visible = false
  end
  if nx_is_valid(form.page_guild_war_info) then
    form.page_guild_war_info.Visible = false
  end
  if nx_is_valid(form.page_luck_pray) then
    form.page_luck_pray.Visible = false
  end
  if not form.groupbox_left.Visible and not form.btn_open_right.Visible then
    form.btn_open_right.Visible = true
    form.groupbox_bg_out.Width = form.groupbox_bg_out.Width - form.groupbox_left.Width - 10
    form.Width = form.groupbox_bg_out.Width + 10
  end
end
function on_recv_authority(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form) or table.getn(arg) < 11 then
    return
  end
  if nx_is_valid(form.page_notice) then
    if nx_int(arg[6]) == nx_int(1) then
      form.NoticeAuth = true
      form.page_notice.btn_edit.NoticeAuth = true
    else
      form.NoticeAuth = false
      form.page_notice.btn_edit.NoticeAuth = false
    end
  end
  if nx_is_valid(form.page_member) then
    if nx_int(arg[3]) == nx_int(1) then
      form.page_member.btn_invite.have_right = true
    else
      form.page_member.btn_invite.have_right = false
    end
  end
  local form_manage_disband = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_manage_disband")
  if nx_is_valid(form_manage_disband) then
    if nx_int(arg[1]) == nx_int(1) then
      form_manage_disband.btn_ok.Visible = true
      form_manage_disband.btn_ok.Enabled = true
    else
      form_manage_disband.btn_ok.Visible = false
      form_manage_disband.btn_ok.Enabled = false
    end
  end
  if nx_is_valid(form.page_manage) and nx_is_valid(form.page_manage.page_position) then
    if nx_int(arg[1]) == nx_int(1) then
      form.page_manage.page_position.is_captain = true
      form.page_manage.page_condition.pic_school.Visible = false
      form.page_manage.page_condition.pic_ability.Visible = false
    else
      form.page_manage.page_position.is_captain = false
      form.page_manage.page_condition.pic_school.Visible = true
      form.page_manage.page_condition.pic_ability.Visible = true
    end
  end
  if nx_is_valid(form.page_candidate) then
    if nx_int(arg[3]) == nx_int(1) then
      form.page_candidate.btn_3.Visible = true
      form.page_candidate.btn_3.Enabled = true
      form.page_candidate.btn_4.Visible = true
      form.page_candidate.btn_4.Enabled = true
    else
      form.page_candidate.btn_3.Visible = false
      form.page_candidate.btn_3.Enabled = false
      form.page_candidate.btn_4.Visible = false
      form.page_candidate.btn_4.Enabled = false
    end
  end
end
function on_sync_member_list()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form) then
    return
  end
  local page = form.page_member
  if not nx_is_valid(page) then
    return
  end
  local member_form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member")
  if not nx_is_valid(member_form) then
    return 0
  end
  if not nx_is_valid(member_form.btn_online) then
    return
  end
  if member_form.btn_online.Checked then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "request_member_list", page.pageno)
  else
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "request_online_member_list", page.pageno)
  end
end
function on_sync_candidate_list()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form) then
    return
  end
  local page = form.page_candidate
  if not nx_is_valid(page) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_candidate", "request_candidate_list", page.pageno)
end
function resize_form_size(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2 + 8
  form.AbsTop = (gui.Height - form.Height) / 3 + 48
end
function set_control_position(control)
  local gui = nx_value("gui")
  local form = control.ParentForm
  control.Top = (form.Height - control.Height) / 2 - 80
  control.Left = (form.Width - control.Width) / 2
end
function on_btn_hide_click(btn)
  local form = btn.Parent
  form.Visible = false
end
function on_recv_sns_info(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form) then
    return
  end
  form.groupscrollbox_member_list:DeleteAll()
  local size = table.getn(arg)
  if size < 0 or size % 5 ~= 0 then
    return
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local member_count = size / 5
  for i = 1, member_count do
    local player_name = arg[(i - 1) * 5 + 1]
    local position = arg[(i - 1) * 5 + 2]
    local school = arg[(i - 1) * 5 + 3]
    local photo = arg[(i - 1) * 5 + 4]
    local role_info = arg[(i - 1) * 5 + 5]
    nx_execute("form_stage_main\\form_relationship", "add_player_model", RELATION_SUB_GROUP_BANGPAI, 0, nx_widestr(player_name), nx_string(role_info), nx_string(school))
    local new_control = clone_control(form.GroupBox_, i)
    if not nx_is_valid(new_control) then
      return
    end
    new_control.Top = (new_control.Height + CONTROL_SPACE) * (i - 1)
    form.groupscrollbox_member_list:Add(new_control)
    local name = "Button_member_" .. nx_string(i)
    local event_control = new_control:Find(name)
    if nx_is_valid(event_control) then
      event_control.member_name = player_name
    end
    name = "Label_position_" .. nx_string(i)
    local position_control = new_control:Find(name)
    if nx_is_valid(position_control) then
      position_control.Text = nx_widestr(util_text(nx_string(position)))
    end
    name = "Label_name_" .. nx_string(i)
    local name_control = new_control:Find(name)
    if nx_is_valid(name_control) then
      name_control.Text = nx_widestr(player_name)
    end
    name = "Label_photo_" .. nx_string(i)
    local photo_control = new_control:Find(name)
    if nx_is_valid(photo_control) then
      photo_control.BackImage = photo
    end
  end
end
function on_recv_sns_info_for_group(...)
  local gui = nx_value("gui")
  local size = table.getn(arg)
  if size < 0 or size % 5 ~= 0 then
    return
  end
  local member_count = size / 5
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  local relation_name = util_text("ui_sns_new_" .. str_group[RELATION_TYPE_BANGPAI + 2])
  local my_guild = util_text("ui_rank_1_bp")
  for i = 1, member_count do
    local player_name = arg[(i - 1) * 5 + 1]
    local position = arg[(i - 1) * 5 + 2]
    local school = arg[(i - 1) * 5 + 3]
    local photo = arg[(i - 1) * 5 + 4]
    local role_info = arg[(i - 1) * 5 + 5]
    local group_id1 = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_ZONGLAN)
    local group_id2 = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_BANGPAI)
    local relation_group1 = sns_manager:GetRelationGroup(group_id1)
    local relation_group2 = sns_manager:GetRelationGroup(group_id2)
    if i == 1 then
      local index = nx_execute("form_stage_main\\form_relationship", "add_player_model", RELATION_GROUP_ZONGLAN, RELATION_TYPE_BANGPAI, nx_widestr(relation_name), nx_string(role_info), school)
      if index ~= -1 then
        relation_group1:SetHeadBalloonType(RELATION_TYPE_BANGPAI, index, 1)
        relation_group1:SetSnsObjectState(RELATION_TYPE_BANGPAI, index, 0)
        relation_group1:CreateSnsObj(RELATION_TYPE_BANGPAI, index)
      end
      local index = nx_execute("form_stage_main\\form_relationship", "add_player_model", RELATION_GROUP_BANGPAI, 0, nx_widestr(my_guild), nx_string(role_info), school)
      if index ~= -1 then
        relation_group2:SetHeadBalloonType(0, index, 1)
        relation_group2:SetSnsObjectState(0, index, 0)
        relation_group2:CreateSnsObj(0, index)
      end
    else
      local index = nx_execute("form_stage_main\\form_relationship", "add_player_model", RELATION_GROUP_ZONGLAN, RELATION_TYPE_BANGPAI, nx_widestr(player_name), nx_string(role_info), school)
      if index ~= -1 then
        relation_group1:SetHeadBalloonType(RELATION_TYPE_BANGPAI, index, 0)
        relation_group1:SetSnsObjectState(RELATION_TYPE_BANGPAI, index, 0)
        relation_group1:CreateSnsObj(RELATION_TYPE_BANGPAI, index)
      end
      index = nx_execute("form_stage_main\\form_relationship", "add_player_model", RELATION_GROUP_BANGPAI, 0, nx_widestr(player_name), nx_string(role_info), school)
      if index ~= -1 then
        relation_group2:SetHeadBalloonType(0, index, 0)
        relation_group2:SetSnsObjectState(0, index, 0)
        relation_group2:CreateSnsObj(0, index)
      end
    end
  end
  if member_count < 5 then
    nx_execute("form_stage_main\\form_relationship", "add_black_model", RELATION_GROUP_ZONGLAN, RELATION_TYPE_BANGPAI, 5 - member_count, "ZONGLAN")
    nx_execute("form_stage_main\\form_relationship", "add_black_model", RELATION_GROUP_BANGPAI, 0, 5 - member_count, "BANGPAI")
  end
end
function clone_control(control, index)
  local entity_name = nx_name(control)
  if string.len(entity_name) == 0 then
    return nil
  end
  local gui = nx_value("gui")
  local new_control = gui:Create(entity_name)
  new_control.Name = nx_string(control.Name) .. nx_string(index)
  new_control.Top = control.Top
  new_control.Left = control.Left
  new_control.Height = control.Height
  new_control.Width = control.Width
  new_control.VAnchor = control.VAnchor
  new_control.HAnchor = control.HAnchor
  new_control.NoFrame = control.NoFrame
  new_control.DrawMode = control.DrawMode
  new_control.BackImage = control.BackImage
  new_control.AutoSize = control.AutoSize
  new_control.Text = control.Text
  new_control.Font = control.Font
  new_control.ForeColor = control.ForeColor
  new_control.BackColor = control.BackColor
  new_control.BlendColor = control.BlendColor
  new_control.LineColor = control.LineColor
  if entity_name == "Button" then
    new_control.NormalImage = control.NormalImage
    new_control.FocusImage = control.FocusImage
    new_control.PushImage = control.PushImage
    new_control.DisableImage = control.DisableImage
    nx_bind_script(new_control, nx_current())
    nx_callback(new_control, "on_click", "on_member_click")
    nx_callback(new_control, "on_right_click", "on_member_right_click")
  elseif entity_name == "Label" then
  elseif entity_name == "GroupBox" then
    local control_list = control:GetChildControlList()
    local control_count = table.getn(control_list)
    for i = 1, control_count do
      local new_child = clone_control(control_list[i], index)
      if nx_is_valid(new_child) then
        new_control:Add(new_child)
      end
    end
  end
  return new_control
end
function on_btn_secret_chat_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "on_btn_secret_chat_click", btn)
end
function on_btn_friend_request_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "on_btn_friend_request_click", btn)
end
function on_btn_add_blacklist_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "on_btn_add_blacklist_click", btn)
end
function on_btn_team_request_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "on_btn_team_request_click", btn)
end
function on_btn_member_manage_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "on_btn_member_manage_click", btn)
end
function on_btn_shanrang_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "on_btn_shanrang_click", btn)
end
function on_btn_kick_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member", "on_btn_kick_click", btn)
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
function open_guild_war_sub_form()
  if not is_in_guild() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_open_guildwar_form_no_guild"), 2)
    end
    return false
  end
  local form_name = "form_stage_main\\form_relation\\form_relation_guild\\form_guild"
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return false
    end
  end
  form.Visible = true
  form:Show()
  form.rbtn_war.Checked = true
  return true
end
function on_btn_plus_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_prosperity", "open_form")
end
