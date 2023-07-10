require("custom_sender")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_invite(guild_name, from_player)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_invite_confirm", true)
  if nx_is_valid(form) then
    form.lbl_player.Text = from_player
    form.lbl_guild.Text = guild_name
    form.Visible = true
    form:Show()
  end
end
function on_btn_accept_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  custom_request_guild_invite_confirm(form.lbl_player.Text, 1)
  form:Close()
end
function on_btn_reject_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  custom_request_guild_invite_confirm(form.lbl_player.Text, 0)
  form:Close()
end
function on_main_form_close(self)
  return 1
end
