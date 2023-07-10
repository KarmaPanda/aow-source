require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
function main_form_init(self)
  self.Fixed = false
  self.player = ""
  self.string_id = "ui_guild_kickout_confirm"
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_guild_kickout(form.player)
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_kickout(player)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_kickout", true)
  if nx_is_valid(form) then
    form.player = player
    form.redit_1.Text = guild_util_get_text(form.string_id, nx_widestr(player))
    form.Visible = true
    form:Show()
  end
end
