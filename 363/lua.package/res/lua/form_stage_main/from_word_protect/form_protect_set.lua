require("util_gui")
require("utils")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local MODIFY_SECOND_WORD = 0
local SET_SECOND_WORD = 1
function on_main_form_init(self)
  self.Fixed = false
  self.select_edit = nil
  self.open_upper = false
  self.soft_edit = nil
end
function on_main_form_open(self)
  local form = self.ParentForm
  form.lbl_notice.Visible = false
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function open_sencond_word_set(set_type)
  local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\from_word_protect\\form_protect_set", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if set_type == MODIFY_SECOND_WORD then
    form.lbl_1.Text = nx_widestr(gui.TextManager:GetText("ui_password_revise"))
    form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetText("ui_password_revise_tips"))
  elseif set_type == SET_SECOND_WORD then
    form.lbl_1.Text = nx_widestr(gui.TextManager:GetText("ui_password_set"))
    form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetText("ui_password_set_tips"))
  end
end
function close_word_set_dialog(self)
  if nx_is_valid(self) then
    self:Close()
  end
end
function on_cancel_btn_click(btn)
  local form = btn.ParentForm
  close_word_set_dialog(form)
end
function on_ok_btn_click(btn)
  local form = btn.ParentForm
  local new_word_1, new_word_2 = enter_second_word_input(form)
  if new_word_1 == nil or new_word_1 == "" or new_word_1 == nil or new_word_1 == "" then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_password_get_tips"))
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
  if result == "ok" then
    nx_execute("custom_sender", "custom_set_second_word", new_word_1, new_word_2)
    close_word_set_dialog(form)
  end
end
function enter_second_word_input(self)
  local form = self.ParentForm
  local new_word_1 = nx_widestr(form.redit_1.Text)
  local new_word_2 = nx_widestr(form.redit_2.Text)
  local new_word_1_length = nx_number(string.len(nx_string(new_word_1)))
  local new_word_2_length = nx_number(string.len(nx_string(new_word_2)))
  if not nx_function("ext_check_words_error", new_word_1) or not nx_function("ext_check_words_error", new_word_2) then
    word_error_deal(form, "ui_password_error_1")
    return
  end
  if new_word_1_length < nx_number(6) or new_word_1_length > nx_number(14) or new_word_2_length < nx_number(6) or new_word_2_length > nx_number(14) then
    word_error_deal(form, "24003")
    return
  end
  if new_word_1 == new_word_2 then
    return new_word_1, new_word_2
  else
    word_error_deal(form, "ui_password_error")
  end
end
function word_error_deal(form, notice_id)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local text_info = gui.TextManager:GetText(nx_string(notice_id))
  show_confirm(text_info)
  form.redit_1.Text = nx_widestr("")
  form.redit_2.Text = nx_widestr("")
end
function on_btn_keyboard_click(btn)
  local form = btn.ParentForm
  local subform = util_get_form("form_common\\form_minkeyboard", true)
  if nx_is_valid(subform) then
    form:Add(subform)
    subform.Left = form.btn_keyboard.Left - subform.Width
    subform.Top = form.btn_keyboard.Top
    subform:Show()
    subform.Visible = true
    subform.file_name = nx_current()
    subform.Fixed = true
  end
end
function on_in_put_key(form, key)
  local gui = nx_value("gui")
  if form.soft_edit == nil then
    return
  end
  form.soft_edit:Append(nx_widestr(key))
end
function on_redit_1_get_focus(btn)
  local form = btn.ParentForm
  form.select_edit = btn
  form.soft_edit = btn
  if nx_function("ext_check_open_upper") then
    form.open_upper = true
    open_upper_deal(form)
  else
    close_upper_deal(form)
  end
end
function on_redit_lost_focus(btn)
  local form = btn.ParentForm
  form.select_edit = nil
  close_upper_deal(form)
end
function on_del_key(form)
  if form.soft_edit == nil then
    return
  end
  if form.soft_edit.IsSelectText then
    form.soft_edit:DeleteSelectText()
  elseif 0 ~= form.soft_edit.InputPos and form.soft_edit:DeleteText(form.soft_edit.InputPos - 1, 1) then
    form.soft_edit.InputPos = form.soft_edit.InputPos - 1
  end
  form.soft_edit:ClearSelect()
  form.soft_edit:ResetEditInfo()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_redit_changed(edit)
  local form = edit.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.open_upper == false then
    if nx_function("ext_check_open_upper") then
      form.open_upper = true
      open_upper_deal(form)
    end
  elseif not nx_function("ext_check_open_upper") then
    form.open_upper = false
    close_upper_deal(form)
  end
end
function open_upper_deal(self)
  if not nx_is_valid(self) then
    return
  end
  if self.select_edit == nil then
    return
  end
  self.lbl_notice.Visible = true
  self.lbl_notice.Top = self.select_edit.Top + self.select_edit.Height
  self.lbl_notice.Left = self.select_edit.Left
end
function close_upper_deal(self)
  if not nx_is_valid(self) then
    return
  end
  self.lbl_notice.Visible = false
end
