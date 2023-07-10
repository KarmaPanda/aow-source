require("util_gui")
function on_main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local form = self.ParentForm
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_cancel_btn_click(btn)
  local form = btn.ParentForm
  close_tips_dialog(form)
end
function close_tips_dialog(self)
  if nx_is_valid(self) then
    self:Close()
  end
end
function on_ok_btn_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\from_word_protect\\form_protect_set", "open_sencond_word_set", 1)
  close_tips_dialog(form)
end
