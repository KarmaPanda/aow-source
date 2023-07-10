require("util_gui")
function main_form_init(self)
  self.Fixed = false
end
function main_form_open(self)
  local gui = nx_value("gui")
end
function main_form_close(self)
end
function on_btn_close_click(self)
  on_btn_cancel_click(self)
end
function on_btn_confirm_click(self)
  local form = self.Parent
  form:Close()
  if nx_find_custom(form, "trade_mode") and nx_string(form.trade_mode) == nx_string("sell") then
    nx_gen_event(form, "form_stage_main\\form_shop\\form_trade_buy_return_sell", "ok")
  else
    nx_gen_event(form, "form_stage_main\\form_shop\\form_trade_buy_return", "ok")
  end
  nx_destroy(form)
end
function on_btn_cancel_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "form_stage_main\\form_shop\\form_trade_buy_return", "cancel")
  nx_destroy(form)
end
