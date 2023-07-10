function main_form_init(form)
end
function on_main_form_open(form)
  if form.cbtn_select.Checked then
    form.btn_ok.Enabled = true
  else
    form.btn_ok.Enabled = false
  end
  local gui = nx_value("gui")
  gui.Focused = form.btn_ok
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
  nx_gen_event(nx_null(), "login_tips", "ok")
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
  nx_gen_event(nx_null(), "login_tips", "cancel")
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
  nx_gen_event(nx_null(), "login_tips", "cancel")
end
function on_cbtn_select_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.btn_ok.Enabled = cbtn.Checked
  local file_name = "logintips.ini"
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_property(game_config, "login_account") then
    local account = game_config.login_account
    file_name = account .. "\\" .. file_name
  end
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    ini:SaveToFile()
  end
  ini:WriteInteger("Show", "Checked", cbtn.Checked)
  ini:SaveToFile()
  nx_destroy(ini)
  ini = nx_null()
end
function is_need_login_tips()
  return true
end
