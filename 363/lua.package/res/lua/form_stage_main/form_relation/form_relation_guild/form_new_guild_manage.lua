require("util_gui")
local GUILD_MANAGE = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_manage"
function main_form_init(self)
  self.Fixed = true
  self.FirstOpen = true
end
function on_main_form_open(self)
  if self.FirstOpen then
    local groupbox = self.groupbox_all
    if not nx_is_valid(groupbox) then
      return
    end
    local form_position = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_position", true, false)
    if nx_is_valid(form_position) then
      form_position.Left = 0
      form_position.Top = 0
      groupbox:Add(form_position)
      self.form_position = form_position
    end
    local form_disband = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_manage_disband", true, false)
    if nx_is_valid(form_disband) then
      form_disband.Left = 0
      form_disband.Top = 0
      form_disband.Visible = false
      groupbox:Add(form_disband)
      self.form_disband = form_disband
    end
    local form_dkp = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_dkp", true, false)
    if nx_is_valid(form_dkp) then
      form_dkp.Left = 0
      form_dkp.Top = 0
      form_dkp.Visible = false
      groupbox:Add(form_dkp)
      self.form_dkp = form_dkp
    end
    self.FirstOpen = false
  end
  self.rbtn_position.Checked = true
  return
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_position.Checked and nx_id_equal(rbtn, form.rbtn_position) then
    form.form_position.Visible = true
    form.form_disband.Visible = false
    form.form_dkp.Visible = false
  elseif form.rbtn_disband.Checked and nx_id_equal(rbtn, form.rbtn_disband) then
    form.form_disband.Visible = true
    form.form_position.Visible = false
    form.form_dkp.Visible = false
  elseif form.rbtn_dkp.Checked and nx_id_equal(rbtn, form.rbtn_dkp) then
    form.form_dkp.Visible = true
    form.form_disband.Visible = false
    form.form_position.Visible = false
  end
end
function on_main_form_close(self)
  if nx_find_custom(self, "form_position") and nx_is_valid(self.form_position) then
    self.form_position:Close()
  end
  if nx_find_custom(self, "form_disband") and nx_is_valid(self.form_disband) then
    self.form_disband:Close()
  end
  if nx_find_custom(self, "form_dkp") and nx_is_valid(self.form_dkp) then
    self.form_dkp:Close()
  end
  nx_destroy(self)
end
