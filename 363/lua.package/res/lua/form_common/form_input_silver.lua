function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.ipt_0
  self.ipt_0.Text = nx_widestr("0")
  self.ipt_1.Text = nx_widestr("0")
  self.ipt_2.Text = nx_widestr("0")
  return 1
end
function trans_price(price)
  local price_ding = nx_int64(price / 10000)
  local temp = nx_int64(price - price_ding * 10000)
  local price_liang = nx_int64(temp / 100)
  local price_wen = nx_int64(temp - price_liang * 100)
  return price_ding, price_liang, price_wen
end
function on_ipt_changed(ipt)
  local form = ipt.Parent
  local silver0 = nx_number(form.ipt_0.Text)
  local silver1 = nx_number(form.ipt_1.Text)
  local silver2 = nx_number(form.ipt_2.Text)
  local silver = silver0 * 10000 + silver1 * 100 + silver2
  if silver > form.max_silver then
    silver = form.max_silver
  else
    return 0
  end
  local ding, liang, wen = trans_price(silver)
  form.ipt_0.Text = nx_widestr(ding)
  form.ipt_1.Text = nx_widestr(liang)
  form.ipt_2.Text = nx_widestr(wen)
end
function ok_btn_click(self)
  local form = self.Parent
  form:Close()
  local silver0 = nx_number(form.ipt_0.Text)
  local silver1 = nx_number(form.ipt_1.Text)
  local silver2 = nx_number(form.ipt_2.Text)
  local silver = silver0 * 10000 + silver1 * 100 + silver2
  nx_gen_event(form, "input_silver_return", "ok", silver)
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "input_silver_return", "cancel")
  nx_destroy(form)
  return 1
end
