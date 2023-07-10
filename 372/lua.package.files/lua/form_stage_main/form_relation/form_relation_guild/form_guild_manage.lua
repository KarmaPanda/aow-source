require("util_gui")
function main_form_init(self)
  self.Fixed = true
  self.FirstOpen = true
end
function on_main_form_open(self)
  if self.FirstOpen then
    local page_position = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position", true, false)
    if self:Add(page_position) then
      self.page_position = page_position
      self.page_position.Visible = false
      self.page_position.Fixed = true
      self.page_position.Left = 160
      self.page_position.Top = 10
    end
    local page_condition = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_invite_condition", true, false)
    if self:Add(page_condition) then
      self.page_condition = page_condition
      self.page_condition.Visible = false
      self.page_condition.Fixed = true
      self.page_condition.Left = 160
      self.page_condition.Top = 10
    end
    local page_disband = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_manage_disband", true, false)
    if self:Add(page_disband) then
      self.page_disband = page_disband
      self.page_disband.Visible = false
      self.page_disband.Fixed = true
      self.page_disband.Left = 160
      self.page_disband.Top = 10
    end
    self.FirstOpen = false
    on_rbtn_position_checked_changed(self.rbtn_position)
  end
  return 1
end
function hide_all_sub_page(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.page_position) then
    form.page_position.Visible = false
  end
  if nx_is_valid(form.page_condition) then
    form.page_condition.Visible = false
  end
  if nx_is_valid(form.page_disband) then
    form.page_disband.Visible = false
  end
end
function on_rbtn_position_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_position) then
    local page_position = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_position", true, false)
    if form:Add(page_position) then
      self.page_position = page_position
      self.page_position.Visible = false
      self.page_position.Fixed = true
      self.page_position.Left = 160
      self.page_position.Top = 10
    end
  end
  form.page_position.Visible = true
  form:ToFront(form.page_position)
end
function on_rbtn_condition_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_condition) then
    local page_condition = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_invite_condition", true, false)
    if form:Add(page_condition) then
      self.page_condition = page_condition
      self.page_condition.Visible = false
      self.page_condition.Fixed = true
      self.page_condition.Left = 160
      self.page_condition.Top = 10
    end
  end
  form.page_condition.Visible = true
  form:ToFront(form.page_condition)
end
function on_rbtn_disband_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  hide_all_sub_page(form)
  if not nx_is_valid(form.page_position) then
    local page_disband = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_manage_disband", true, false)
    if form:Add(page_disband) then
      self.page_disband = page_disband
      self.page_disband.Visible = false
      self.page_disband.Fixed = true
      self.page_disband.Left = 160
      self.page_disband.Top = 10
    end
  end
  form.page_disband.Visible = true
  form:ToFront(form.page_disband)
end
function on_main_form_close(self)
end
