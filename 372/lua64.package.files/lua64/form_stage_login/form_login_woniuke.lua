require("util_gui")
function main_form_init(self)
end
function main_form_open(self)
  local form = nx_value("form_stage_login\\form_login_woniuke")
  if not nx_is_valid(form) then
    return
  end
  form.ipt_pass.Text = nx_widestr("")
  form.btn_ok.Enabled = false
  form.Default = form.btn_ok
end
function main_form_close(self)
  nx_destroy(self)
  nx_set_value("form_stage_login\\form_login_woniuke", nil)
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local game_config = nx_value("game_config")
  game_config.login_validate = form.validate
  game_config.login_password = form.pswd
  if form.type == 0 then
    game_config.login_niudun = nx_string(form.ipt_pass.Text)
  elseif form.type == 1 then
    game_config.login_shoujiniudun = nx_string(form.ipt_pass.Text)
  end
  local form_login = nx_value("form_stage_login\\form_login")
  if not nx_is_valid(form_login) then
    return
  end
  nx_execute("form_stage_login\\form_login", "try_login_game", form_login)
  form:Close()
end
function on_btn_cancel_click(self)
  self.ParentForm:Close()
  local sock = nx_execute("client", "get_game_sock")
  if not nx_is_valid(sock) then
    return
  end
  local sender = sock.Sender
  if not nx_is_valid(sender) then
    return
  end
  local receiver = sock.Receiver
  if not nx_is_valid(receiver) then
    return
  end
  local form = nx_value("form_stage_login\\form_login")
  form.btn_enter.Enabled = true
  form.btn_return.Enabled = true
  receiver:ClearAll()
  if sock.Connected then
    sock:Disconnect()
    console_log("Disconnect...")
  end
end
function resize()
  local form = nx_value("form_stage_login\\form_login_woniuke")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.AbsTop = (gui.Desktop.Height - form.Height) / 2
      form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
    end
  end
end
function on_ipt_pass_changed(self)
  local form = self.ParentForm
  if nx_string(self.Text) ~= "" then
    form.btn_ok.Enabled = true
  else
    form.btn_ok.Enabled = false
  end
end
