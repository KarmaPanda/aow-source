require("util_role_prop")
function main_form_init(self)
  self.Fixed = true
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Desktop.Width - self.Width) / 2
    self.Top = (gui.Desktop.Height - self.Height) / 2
  end
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  local groupbox = form.groupbox_1
  if groupbox.Visible then
    return
  else
    groupbox.Visible = true
    form.groupbox_2.Visible = false
  end
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  local groupbox = form.groupbox_2
  if groupbox.Visible then
    return
  else
    groupbox.Visible = true
    form.groupbox_1.Visible = false
  end
end
function on_btn_3_click(btn)
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    nx_execute("custom_sender", "custom_damingtongdian")
  end
end
