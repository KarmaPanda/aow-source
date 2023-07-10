require("custom_sender")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  local player_name = form.ipt_1.Text
  if nx_widestr(player_name) ~= nx_widestr("") then
    custom_request_guild_invite(player_name)
  end
  form:Close()
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
