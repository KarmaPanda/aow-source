function main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_10_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_23_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_12_click(btn)
  local form = btn.ParentForm
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
end
function on_btn_24_click(btn)
  local form = btn.ParentForm
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = true
end
function on_btn_22_click(btn)
  local form = btn.ParentForm
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = true
end
function on_item_click(btn)
  local form = btn.ParentForm
  local AOWSteamClient = nx_value("AOWSteamClient")
  if not nx_is_valid(AOWSteamClient) then
    return
  end
  if nx_string(btn.DataSource) == "" then
    return
  end
  AOWSteamClient:SteamPayStart(nx_string(btn.DataSource))
end
