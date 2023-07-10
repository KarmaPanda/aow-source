require("util_gui")
function on_main_form_init(self)
end
function on_main_form_open(self)
  resize()
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_go_click(self)
  local form = self.ParentForm
  nx_function("ext_open_url", "http://9yinbbs.woniu.com/viewthread.php?tid=951712&extra=page%3D1")
  form:Close()
  nx_gen_event(nx_null(), "login_sddl", "cancel")
end
function on_btn_close_click(self)
  self.ParentForm:Close()
  nx_gen_event(nx_null(), "login_sddl", "cancel")
end
function resize()
  local form = nx_value("form_stage_login\\form_login_sddl")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.AbsTop = (gui.Desktop.Height - form.Height) / 2
      form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
      gui.Desktop:ToFront(form)
    end
  end
end
