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
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_disband_guild()
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