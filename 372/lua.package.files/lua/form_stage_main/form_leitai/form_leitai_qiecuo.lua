function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local ding = nx_int64(form.ipt_d.Text)
  local liang = nx_int64(form.ipt_l.Text)
  local chip = ding * 1000000 + liang * 1000
  nx_gen_event(form, "form_leitai_qiecuo", "OK", chip)
  form:Close()
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "form_leitai_qiecuo", "cancel")
  if nx_is_valid(form) then
    form:Close()
  end
end
