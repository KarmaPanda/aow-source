require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
function main_form_init(self)
  self.Fixed = false
  self.string_id = "ui_invite_respond_info"
  self.guild_name = ""
  self.guild_captain = ""
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_respond_guild(0, form.guild_name)
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    custom_request_respond_guild(1, form.guild_name)
    form:Close()
  end
end
function show_invite_respond(guild_name, guild_captain)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_invite_respond", true)
  if not nx_is_valid(form) then
    return
  end
  form.redit_1.Text = guild_util_get_text(form.string_id, guild_captain, guild_name)
  form.guild_name = guild_name
  form.guild_captain = guild_captain
  form.Visible = true
  form:Show()
end
