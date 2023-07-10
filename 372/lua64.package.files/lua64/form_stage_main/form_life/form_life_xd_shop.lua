require("util_functions")
require("util_gui")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
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
  nx_execute(G_SHOP_PATH, "show_charge_shop", CHARGE_GATHER_SHOP)
  if nx_is_valid(form) then
    form:Close()
  end
end
function cancel_btn_click(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
