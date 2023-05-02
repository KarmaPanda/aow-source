require("util_functions")
require("util_gui")
local FORM_GUILD_ACTIVITY = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_activity"
function main_form_init(self)
  self.Fixed = true
  self.FirstOpen = true
end
function on_main_form_open(self)
  if not nx_is_valid(self) then
    return
  end
  if self.FirstOpen then
    local groupbox = self.groupbox_1
    if not nx_is_valid(groupbox) then
      return
    end
    local form_escort = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_escort", true, false)
    if nx_is_valid(form_escort) then
      form_escort.Left = 0
      form_escort.Top = 0
      groupbox:Add(form_escort)
      self.form_escort = form_escort
    end
    local form_task = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_task", true, false)
    if nx_is_valid(form_task) then
      form_task.Left = 0
      form_task.Top = 0
      groupbox:Add(form_task)
      self.form_task = form_task
    end
    local form_pray = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_pray", true, false)
    if nx_is_valid(form_pray) then
      form_pray.Left = 0
      form_pray.Top = 0
      groupbox:Add(form_pray)
      self.form_pray = form_pray
    end
    local form_auth = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_authentication", true, false)
    if nx_is_valid(form_auth) then
      form_auth.Left = 0
      form_auth.Top = 0
      groupbox:Add(form_auth)
      self.form_auth = form_auth
    end
    local form_suits = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_suits", true, false)
    if nx_is_valid(form_suits) then
      form_suits.Left = 0
      form_suits.Top = 0
      groupbox:Add(form_suits)
      self.form_suits = form_suits
    end
    local form_qunfengwenwu = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_newguild_war_scuffle", true, false)
    if nx_is_valid(form_qunfengwenwu) then
      form_qunfengwenwu.Left = 0
      form_qunfengwenwu.Top = 0
      groupbox:Add(form_qunfengwenwu)
      self.form_qunfengwenwu = form_qunfengwenwu
    end
    self.FirstOpen = false
  end
  self.rbtn_escort.Checked = true
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
  if form.rbtn_escort.Checked and nx_id_equal(rbtn, form.rbtn_escort) then
    form.form_escort.Visible = true
    form.form_task.Visible = false
    form.form_pray.Visible = false
    form.form_auth.Visible = false
    form.form_suits.Visible = false
    form.form_qunfengwenwu.Visible = false
  elseif form.rbtn_task.Checked and nx_id_equal(rbtn, form.rbtn_task) then
    form.form_task.Visible = true
    form.form_escort.Visible = false
    form.form_pray.Visible = false
    form.form_auth.Visible = false
    form.form_suits.Visible = false
    form.form_qunfengwenwu.Visible = false
  elseif form.rbtn_pray.Checked and nx_id_equal(rbtn, form.rbtn_pray) then
    form.form_pray.Visible = true
    form.form_task.Visible = false
    form.form_escort.Visible = false
    form.form_auth.Visible = false
    form.form_suits.Visible = false
    form.form_qunfengwenwu.Visible = false
  elseif form.rbtn_authentication.Checked and nx_id_equal(rbtn, form.rbtn_authentication) then
    form.form_auth.Visible = true
    form.form_pray.Visible = false
    form.form_task.Visible = false
    form.form_escort.Visible = false
    form.form_suits.Visible = false
    form.form_qunfengwenwu.Visible = false
  elseif form.rbtn_cloth.Checked and nx_id_equal(rbtn, form.rbtn_cloth) then
    form.form_suits.Visible = true
    form.form_auth.Visible = false
    form.form_pray.Visible = false
    form.form_task.Visible = false
    form.form_escort.Visible = false
    form.form_qunfengwenwu.Visible = false
  elseif form.rbtn_qunfengwenwu.Checked and nx_id_equal(rbtn, form.rbtn_qunfengwenwu) then
    form.form_suits.Visible = false
    form.form_auth.Visible = false
    form.form_pray.Visible = false
    form.form_task.Visible = false
    form.form_escort.Visible = false
    form.form_qunfengwenwu.Visible = true
  end
end
function on_main_form_close(self)
  if nx_find_custom(self, "form_escort") and nx_is_valid(self.form_escort) then
    self.form_escort:Close()
  end
  if nx_find_custom(self, "form_task") and nx_is_valid(self.form_task) then
    self.form_task:Close()
  end
  if nx_find_custom(self, "form_pray") and nx_is_valid(self.form_pray) then
    self.form_pray:Close()
  end
  if nx_find_custom(self, "form_auth") and nx_is_valid(self.form_auth) then
    self.form_auth:Close()
  end
  if nx_find_custom(self, "form_suits") and nx_is_valid(self.form_suits) then
    self.form_suits:Close()
  end
  if nx_find_custom(self, "form_qunfengwenwu") and nx_is_valid(self.form_qunfengwenwu) then
    self.form_qunfengwenwu:Close()
  end
  nx_destroy(self)
end
function open_form()
  local form = util_get_form(FORM_GUILD_ACTIVITY, true)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_cloth.Checked = true
end
