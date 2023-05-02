require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild")
local FORM_GUILD_INTRO = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_intro"
local FORM_GUILD_EVENT_LIST = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_event_list"
local FORM_GUILD_MEMBER = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_member"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local groupbox = form.groupbox_all
  if not nx_is_valid(groupbox) then
    return false
  end
  local form_intro = util_get_form(FORM_GUILD_INTRO, true, false)
  if nx_is_valid(form_intro) then
    form_intro.Visible = true
    form_intro.Fixed = true
    form_intro.Left = 0
    form_intro.Top = 0
    groupbox:Add(form_intro)
    form.form_intro = form_intro
  end
  local form_event_list = util_get_form(FORM_GUILD_EVENT_LIST, true, false)
  if nx_is_valid(form_event_list) then
    form_event_list.Visible = false
    form_event_list.Fixed = true
    form_event_list.Left = 0
    form_event_list.Top = 0
    groupbox:Add(form_event_list)
    form.form_event_list = form_event_list
  end
  local form_member = util_get_form(FORM_GUILD_MEMBER, true, false)
  if nx_is_valid(form_member) then
    form_member.Visible = false
    form_member.Fixed = true
    form_member.Left = 0
    form_member.Top = 0
    form_member.btn_invite.have_right = false
    groupbox:Add(form_member)
    form.form_member = form_member
  end
  form.rbtn_intro.Checked = true
  custom_request_guild_authority()
  return true
end
function on_main_form_close(form)
  close_all_sub_page(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  return true
end
function on_rbtn_intro_checked_changed(rbtn)
  if not rbtn.Checked then
    return false
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  hide_all_sub_page(form)
  if not nx_is_valid(form.form_intro) then
    local form_intro = util_get_form(FORM_GUILD_INTRO, true, false)
    if nx_is_valid(form_intro) then
      form_intro.Left = 0
      form_intro.Top = 0
      form.groupbox_all:Add(form_intro)
      form.form_intro = form_intro
    end
  end
  if nx_is_valid(form.form_intro) then
    form.form_intro.Visible = true
    form:ToFront(form.form_intro)
  end
  return true
end
function on_rbtn_event_checked_changed(rbtn)
  if not rbtn.Checked then
    return false
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  hide_all_sub_page(form)
  if not nx_is_valid(form.form_event_list) then
    local form_event_list = util_get_form(FORM_GUILD_EVENT_LIST, true, false)
    if nx_is_valid(form_event_list) then
      form_event_list.Left = 0
      form_event_list.Top = 0
      form.groupbox_all:Add(form_event_list)
      form.form_event_list = form_event_list
    end
  end
  if nx_is_valid(form.form_event_list) then
    form.form_event_list.Visible = true
    form:ToFront(form.form_event_list)
  end
  return true
end
function on_rbtn_member_checked_changed(rbtn)
  if not rbtn.Checked then
    return false
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  hide_all_sub_page(form)
  if not nx_is_valid(form.form_member) then
    local form_member = util_get_form(FORM_GUILD_MEMBER, true, false)
    if nx_is_valid(form_member) then
      form_member.Left = 0
      form_member.Top = 0
      form_member.btn_invite.have_right = false
      form.groupbox_all:Add(form_member)
      form.form_member = form_member
    end
  end
  if nx_is_valid(form.form_member) then
    form.form_member.Visible = true
    form:ToFront(form.form_member)
  end
  return true
end
function hide_all_sub_page(form)
  if not nx_is_valid(form) then
    return false
  end
  if nx_is_valid(form.form_intro) then
    form.form_intro.Visible = false
  end
  if nx_is_valid(form.form_event_list) then
    form.form_event_list.Visible = false
  end
  if nx_is_valid(form.form_member) then
    form.form_member.Visible = false
  end
  return true
end
function close_all_sub_page(form)
  if not nx_is_valid(form) then
    return false
  end
  if nx_is_valid(form.form_intro) then
    form.form_intro:Close()
  end
  if nx_is_valid(form.form_event_list) then
    form.form_event_list:Close()
  end
  if nx_is_valid(form.form_member) then
    form.form_member:Close()
  end
end
function custom_request_guild_authority()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_POSTION_AUTHORITY))
  return true
end
function on_recv_authority(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return false
  end
  if nx_is_valid(form.form_intro) then
    if nx_int(arg[6]) == nx_int(1) then
      form.NoticeAuth = true
      form.form_intro.btn_notice.Visible = true
    else
      form.NoticeAuth = false
      form.form_intro.btn_notice.Visible = false
    end
    if nx_int(arg[7]) == nx_int(1) then
      form.TenetAuth = true
      form.form_intro.btn_tenet.Visible = true
    else
      form.TenetAuth = false
      form.form_intro.btn_tenet.Visible = false
    end
  end
  if nx_is_valid(form.form_member) then
    if nx_int(arg[3]) == nx_int(1) then
      form.form_member.btn_invite.have_right = true
    else
      form.form_member.btn_invite.have_right = false
    end
  end
  return true
end
