function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(self)
end
function on_btn_Yes_click(self)
  local form = self.ParentForm
  local pop_confirm = false
  if not form.rbtn_lbtn_1.Checked and not form.rbtn_lbtn_2.Checked then
    pop_confirm = true
  end
  if not form.rbtn_lbtn_3.Checked and not form.rbtn_lbtn_4.Checked then
    pop_confirm = true
  end
  if not form.rbtn_lbtn_5.Checked and not form.rbtn_lbtn_6.Checked then
    pop_confirm = true
  end
  if pop_confirm then
    local dialog_confirm = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "single_question")
    if not nx_is_valid(dialog_confirm) then
      return
    end
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_SPYD_noanswer")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog_confirm, nx_widestr(text))
    nx_execute("form_common\\form_confirm", "hide_cancel_btn", dialog_confirm)
    dialog_confirm:ShowModal()
    local res = nx_wait_event(100000000, dialog_confirm, "single_question_confirm_return")
    if res == "ok" then
      return
    end
  end
  local can_skip = false
  if form.rbtn_lbtn_2.Checked and form.rbtn_lbtn_4.Checked and form.rbtn_lbtn_6.Checked then
    can_skip = true
  end
  form:Close()
  if can_skip then
    nx_gen_event(form, "confirm_return", "can_skip")
  else
    answon_error(form)
  end
  nx_destroy(form)
end
function answon_error(form)
  local dialog = nx_execute("util_gui", "util_get_form", "form_single_wrong", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "wrong_return")
  if res == "ok" then
    nx_gen_event(form, "confirm_return", "not_skip")
  end
end
