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
  return 1
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function ok_btn_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "sell_stall_price_input_return", "ok")
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "sell_stall_price_input_return", "cancel")
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
