require("util_gui")
require("utils")
require("share\\client_custom_define")
require("form_stage_main\\switch\\switch_define")
require("game_object")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function show_form_protect_sure(count)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\from_word_protect\\form_protect_sure", true)
  local form = nx_value("form_stage_main\\from_word_protect\\form_protect_sure")
  nx_execute("util_gui", "ui_show_attached_form", form)
  if nx_int(count) > nx_int(0) then
    form.groupbox_countdown.Visible = true
    form.countdown = count
    on_protect_time_countdown(form)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(1000, count, nx_current(), "on_protect_time_countdown", form, -1, -1)
    end
  end
end
function on_main_form_init(self)
  self.Fixed = false
  self.select_edit = nil
  self.open_upper = false
  self.soft_edit = nil
end
function on_main_form_open(self)
  local form = self.ParentForm
  form.lbl_notice.Visible = false
  form.groupbox_countdown.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    local is_open = switch_manager:CheckSwitchEnable(ST_FUNCTION_OPEN_WORD_PROTECT_TIME)
    if not is_open then
      form.btn_timeprotect.Visible = false
    end
  end
  if nx_is_valid(switch_manager) then
    local is_open = switch_manager:CheckSwitchEnable(ST_FUNCTION_EMAIL_VALIDATE)
    if not is_open then
      form.btn_find_bymail.Visible = false
    end
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_main_form_close(self)
  ui_destroy_attached_form(self)
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_modify_btn_click(btn)
  local form = btn.ParentForm
  local word_text = form.redit_1.Text
  if not check_second_word(word_text) then
    return
  end
  nx_execute("custom_sender", "modify_second_word", nx_widestr(word_text))
  form:Close()
end
function on_cancel_btn_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local word_text = form.redit_1.Text
  if not check_second_word(word_text) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_password_annul_tips"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if result == "ok" then
    nx_execute("custom_sender", "cancel_second_word", nx_widestr(word_text))
    form:Close()
  end
end
function on_ok_btn_click(btn)
  local form = btn.ParentForm
  local word_text = form.redit_1.Text
  if not check_second_word(word_text) then
    return
  end
  nx_execute("custom_sender", "check_second_word", nx_widestr(word_text))
  form:Close()
end
function on_btn_keyboard_click(btn)
  local form = btn.ParentForm
  local subform = util_get_form("form_common\\form_minkeyboard", true)
  if nx_is_valid(subform) then
    form:Add(subform)
    subform.Left = form.btn_keyboard.Left - subform.Width + 70
    subform.Top = form.btn_keyboard.Top + form.btn_keyboard.Height
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
function check_second_word(word_text)
  if nx_string(word_text) == "" then
    local gui = nx_value("gui")
    local text_info = gui.TextManager:GetText("24014")
    show_confirm(text_info)
    return false
  end
  return true
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_find_click(btn)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), 7, nx_widestr("00000000000"))
  end
  local form = btn.ParentForm
  form:Close()
end
function on_btn_find_bymail_click(btn)
  local form = nx_value("form_stage_main\\from_word_protect\\form_secword_bymail_confirm")
  if not nx_is_valid(form) then
    nx_execute("form_stage_main\\from_word_protect\\form_secword_bymail_request", "show_form")
  end
  local form = btn.ParentForm
  form:Close()
end
function on_btn_timeprotect_click(btn)
  local form = btn.ParentForm
  local word_text = form.redit_1.Text
  if not check_second_word(word_text) then
    return
  end
  nx_execute("custom_sender", "modify_word_protect_time", nx_widestr(word_text))
  form:Close()
end
function on_redit_changed(btn)
  local form = btn.ParentForm
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
function on_redit_lost_focus(btn)
  local form = btn.ParentForm
  form.select_edit = nil
  close_upper_deal(form)
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
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_protect_time_countdown(form)
  local count = nx_int(form.countdown)
  local hour = 0
  local minute = 0
  local second = 0
  if nx_int(count) == nx_int(0) then
    form.groupbox_countdown.Visible = false
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_protect_time_countdown", form)
    end
    return
  end
  if nx_int(count) >= nx_int(3600) then
    hour = nx_int(count / 3600)
    local last = count - hour * 3600
    if nx_int(last) >= nx_int(60) then
      minute = nx_int(last / 60)
      second = last - minute * 60
    else
      second = last
    end
  elseif nx_int(count) >= nx_int(60) then
    minute = nx_int(count / 60)
    second = count - minute * 60
  else
    second = count
  end
  local fmt = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(minute), nx_number(second))
  form.lbl_countdown.Text = nx_widestr(fmt)
  form.countdown = count - 1
end
function on_switch_changed(type, is_open)
  if nx_int(type) == nx_int(ST_FUNCTION_OPEN_WORD_PROTECT_TIME) then
    local form = nx_value("form_stage_main\\from_word_protect\\form_protect_sure")
    if nx_is_valid(form) then
      form.btn_timeprotect.Visible = is_open
    end
  end
  if nx_int(type) == nx_int(ST_FUNCTION_EMAIL_VALIDATE) then
    local form = nx_value("form_stage_main\\from_word_protect\\form_protect_sure")
    if nx_is_valid(form) then
      form.btn_find_bymail.Visible = is_open
    end
  end
end
