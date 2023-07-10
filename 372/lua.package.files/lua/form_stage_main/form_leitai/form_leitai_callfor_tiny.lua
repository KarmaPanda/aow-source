function on_btn_lei_tai_click(self)
  local full_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_callfor_full", true)
  full_form.leitai_callfor_time = nx_number(self.Parent.leitai_callfor_time)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_leitai\\form_leitai_callfor_full", true)
end
function main_form_init(self)
end
function on_main_form_open(self)
  self.lbl_time.Text = nx_widestr(self.leitai_callfor_time)
  local gui = nx_value("gui")
  self.Left = gui.Desktop.Left + 2 * gui.Desktop.Width / 3
  self.Top = gui.Desktop.Top + gui.Desktop.Height / 3
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
    timer:Register(1000, -1, nx_current(), "on_timer", self, -1, -1)
  end
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
  end
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_timer(self)
  self.leitai_callfor_time = nx_number(self.leitai_callfor_time) - 1
  self.lbl_time.Text = nx_widestr(self.leitai_callfor_time)
  if self.leitai_callfor_time < 0 then
    self:Close()
  end
end
