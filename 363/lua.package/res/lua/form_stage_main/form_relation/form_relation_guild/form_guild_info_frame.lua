require("util_gui")
local guild_title_path = "form_stage_main\\form_relation\\form_relation_guild\\form_guild_title"
function main_form_init(self)
  self.Fixed = true
  self.FirstOpen = true
end
function on_main_form_open(self)
  if self.FirstOpen then
    local page_intro = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_intro", true, false)
    if self:Add(page_intro) then
      self.page_intro = page_intro
      self.page_intro.Visible = false
      self.page_intro.Fixed = true
      self.page_intro.Left = 160
      self.page_intro.Top = 10
    end
    local page_event = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_event_list", true, false)
    if self:Add(page_event) then
      self.page_event = page_event
      self.page_event.Visible = false
      self.page_event.Fixed = true
      self.page_event.Left = 150
      self.page_event.Top = 0
    end
    local page_activity = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_activity", true, false)
    if self:Add(page_activity) then
      self.page_activity = page_activity
      self.page_activity.Visible = false
      self.page_activity.Fixed = true
      self.page_activity.Left = 150
      self.page_activity.Top = 0
    end
    local page_title = util_get_form(guild_title_path, true, false)
    if self:Add(page_title) then
      self.page_title = page_title
      self.page_title.Visible = false
      self.page_title.Fixed = true
      self.page_title.Left = 150
      self.page_title.Top = 0
    end
    local page_degrade = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_demotion", true, false)
    if self:Add(page_degrade) then
      self.page_degrade = page_degrade
      self.page_degrade.Visible = false
      self.page_degrade.Fixed = true
      self.page_degrade.Left = 150
      self.page_degrade.Top = 0
    end
    self.FirstOpen = false
    on_rbtn_event_checked_changed(self.rbtn_event)
  end
  return 1
end
function hide_all_sub_page(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.page_intro) then
    form.page_intro.Visible = false
  end
  if nx_is_valid(form.page_event) then
    form.page_event.Visible = false
  end
  if nx_is_valid(form.page_activity) then
    form.page_activity.Visible = false
  end
  if nx_is_valid(form.page_title) then
    form.page_title.Visible = false
  end
  if nx_is_valid(form.page_degrade) then
    form.page_degrade.Visible = false
  end
end
function on_rbtn_intro_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_intro) then
    local page_intro = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_intro", true, false)
    if form:Add(page_intro) then
      form.page_intro = page_intro
      form.page_intro.Visible = false
      form.page_intro.Fixed = true
      form.page_intro.Left = 115
      form.page_intro.Top = 10
    end
  end
  form.page_intro.Visible = true
  form:ToFront(form.page_intro)
end
function on_rbtn_event_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_event) then
    local page_event = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_event_list", true, false)
    if form:Add(page_event) then
      form.page_event = page_event
      form.page_event.Visible = false
      form.page_event.Fixed = true
      form.page_event.Left = 115
      form.page_event.Top = 10
    end
  end
  form.page_event.Visible = true
  form:ToFront(form.page_event)
end
function on_rbtn_activity_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_activity) then
    local page_activity = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_activity", true, false)
    if form:Add(page_activity) then
      form.page_activity = page_activity
      form.page_activity.Visible = false
      form.page_activity.Fixed = true
      form.page_activity.Left = 115
      form.page_activity.Top = 10
    end
  end
  form.page_activity.Visible = true
  form:ToFront(form.page_activity)
end
function on_rbtn_guild_title_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_title) then
    local page_title = util_get_form(guild_title_path, true, false)
    if form:Add(page_title) then
      form.page_title = page_title
      form.page_title.Visible = false
      form.page_title.Fixed = true
      form.page_title.Left = 115
      form.page_title.Top = 10
    end
  end
  form.page_title.Visible = true
  form:ToFront(form.page_activity)
end
function on_rbtn_degrade_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_degrade) then
    local page_degrade = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_demotion", true, false)
    if form:Add(page_degrade) then
      form.page_degrade = page_degrade
      form.page_degrade.Visible = false
      form.page_degrade.Fixed = true
      form.page_degrade.Left = 115
      form.page_degrade.Top = 10
    end
  end
  form.page_degrade.Visible = true
  form:ToFront(form.page_degrade)
end
function on_main_form_close(self)
end
