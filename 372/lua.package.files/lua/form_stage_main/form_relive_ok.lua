require("util_functions")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.Default = self.ok_btn
  nx_set_value("form_state_main\\form_relive_ok", self)
  return 1
end
function on_main_form_close(self)
  self.mltbox_info:Clear()
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function ok_btn_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "confirm_return", "ok")
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "confirm_return", "cancel")
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function clear()
  local form = nx_value("form_state_main\\form_relive_ok")
  if nx_is_valid(form) then
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
  end
end
