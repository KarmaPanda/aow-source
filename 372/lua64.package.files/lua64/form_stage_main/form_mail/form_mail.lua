require("util_functions")
require("util_gui")
local form_send_box = "form_stage_main\\form_mail\\form_mail_send"
local form_accept_box = "form_stage_main\\form_mail\\form_mail_accept"
local form_send_list_box = "form_stage_main\\form_mail\\form_mail_sendlist"
local LETTER_SYSTEM_TYPE_MIN = 100
local LETTER_SYSTEM_POST_USER = 101
local LETTER_SYSTEM_TEACH_NOTIFY = 102
local LETTER_SYSTEM_SINGLE_DIVORCE_NOTIFY = 103
local LETTER_SYSTEM_LOVER_RELATION_FREE = 104
local LETTER_SYSTEM_FRIEND = 105
local LETTER_USER_POST_TASK = 106
local LETTER_USER_OWNER_CROP_RECORD = 108
local LETTER_SYSTEM_TYPE_MAX = 199
local LETTER_USER_TYPE_MIN = 0
local LETTER_USER_POST_USER = 1
local LETTER_USER_POST_BACK_USER_OUT_TIME = 2
local LETTER_USER_POST_BACK_USER_REFUSE = 3
local LETTER_USER_POST_BACK_USER_FULL = 4
local LETTER_USER_POST_TRADE = 5
local LETTER_USER_POST_TRADE_PAY = 6
local LETTER_USER_WHISPER_USER = 10
local LETTER_USER_TYPE_MAX = 99
local POST_TABLE_SENDNAME = 0
local POST_TABLE_SENDUID = 1
local POST_TABLE_TYPE = 2
local POST_TABLE_LETTERNAME = 3
local POST_TABLE_VALUE = 4
local POST_TABLE_GOLD = 5
local POST_TABLE_SILVER = 6
local POST_TABLE_APPEDIXVALUE = 7
local POST_TABLE_DATE = 8
local POST_TABLE_READFLAG = 9
local POST_TABLE_SERIALNO = 10
local POST_TABLE_TRADE_MONEY = 11
local POST_TABLE_SELECT = 12
local POST_TABLE_LEFT_TIME = 13
local POST_TABLE_TRADE_DONE = 14
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 10
  self.AbsTop = (gui.Height - self.Height) / 2
  nx_execute("custom_sender", "custom_open_mail_box")
  self.Visible = true
end
function auto_show_mail_form()
  local form = nx_value("form_stage_main\\form_mail\\form_mail")
  if nx_is_valid(form) and form.Visible then
    form:Close()
  else
    open_form()
    form = nx_value("form_stage_main\\form_mail\\form_mail")
    nx_execute("util_gui", "ui_show_attached_form", form)
  end
end
function open_form(open_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail", true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  open_send_accpet_box(form, open_type)
end
function open_send_accpet_box(form, open_type)
  local sendpage = nx_execute("util_gui", "util_get_form", form_send_box, true, false)
  local is_load = form:Add(sendpage)
  if is_load then
    form.sendpage = sendpage
    form.sendpage.Left = 8
    form.sendpage.Top = 54
  end
  local acceptpage = nx_execute("util_gui", "util_get_form", form_accept_box, true, false)
  local is_load = form:Add(acceptpage)
  if is_load then
    form.acceptpage = acceptpage
    form.acceptpage.Left = 8
    form.acceptpage.Top = 70
  end
  local sendpagelist = nx_execute("util_gui", "util_get_form", form_send_list_box, true, false)
  local is_load = form:Add(sendpagelist)
  if is_load then
    form.sendpagelist = sendpagelist
    form.sendpagelist.Left = 8
    form.sendpagelist.Top = 70
  end
  if open_type == 1 then
    send_on_click(form.send)
  elseif open_type == 2 then
    accept_on_click(form.accept)
  elseif is_have_noread_mail() then
    if is_have_user_noread_mail() then
      accept_on_click(form.accept)
    else
      system_on_click(form.system)
    end
  else
    send_on_click(form.send)
  end
end
function accept_on_click(self)
  local form = self.Parent.Parent
  self.Checked = true
  form.acceptpage.mail_type = 1
  form.caption.Visible = true
  form.caption2.Visible = false
  form.caption3.Visible = false
  form.acceptpage.Visible = true
  form.sendpage.Visible = false
  form.sendpagelist.Visible = false
  nx_execute(form_accept_box, "mail_fresh", form.acceptpage)
  nx_execute(form_accept_box, "fresh_page", form.acceptpage)
  nx_execute(form_accept_box, "fresh_select_all_state", form.acceptpage)
end
function send_on_click(self)
  local form = self.Parent.Parent
  self.Checked = true
  form.caption.Visible = false
  form.caption2.Visible = true
  form.caption3.Visible = false
  form.acceptpage.Visible = false
  form.sendpage.Visible = true
  form.sendpagelist.Visible = false
end
function system_on_click(self)
  local form = self.Parent.Parent
  self.Checked = true
  form.acceptpage.mail_type = 2
  form.caption.Visible = false
  form.caption2.Visible = false
  form.caption3.Visible = true
  form.acceptpage.Visible = true
  form.sendpage.Visible = false
  form.sendpagelist.Visible = false
  nx_execute(form_accept_box, "mail_fresh", form.acceptpage)
  nx_execute(form_accept_box, "fresh_page", form.acceptpage)
  nx_execute(form_accept_box, "fresh_select_all_state", form.acceptpage)
end
function on_sendlist_click(self)
  local form = self.Parent.Parent
  self.Checked = true
  form.caption.Visible = false
  form.caption2.Visible = true
  form.caption3.Visible = false
  form.sendpagelist.Visible = true
  form.acceptpage.Visible = false
  form.sendpage.Visible = false
  nx_execute(form_send_list_box, "mail_fresh", form.sendpagelist)
  nx_execute(form_send_list_box, "fresh_page", form.sendpagelist)
  nx_execute(form_send_list_box, "fresh_select_all_state", form.sendpagelist)
end
function xia_on_click(self)
  local form = self.Parent.Parent
  form:Close()
  form.Visible = false
  self.BackImage = "gui\\mail\\send_mail\\xz01.png"
  return 1
end
function main_form_close(self)
  ui_destroy_attached_form(self)
  local form = nx_value(form_send_box)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_value(form_accept_box)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_value(form_send_list_box)
  if nx_is_valid(form) then
    form:Close()
  end
  self.Visible = false
  nx_destroy(self)
  local form_mail_read = nx_value("form_stage_main\\form_mail\\form_mail_read")
  if nx_is_valid(form_mail_read) then
    form_mail_read:Close()
  end
end
function close_form()
  local form = nx_value("form_stage_main\\form_mail\\form_mail")
  if nx_is_valid(form) then
    ui_destroy_attached_form(self)
    local form = nx_value(form_send_box)
    if nx_is_valid(form) then
      form:Close()
    end
    form = nx_value(form_accept_box)
    if nx_is_valid(form) then
      form:Close()
    end
    form = nx_value(form_send_list_box)
    if nx_is_valid(form) then
      form:Close()
    end
    form = nx_value("form_stage_main\\form_mail\\form_mail_read")
    if nx_is_valid(form) then
      form:Close()
    end
    form = nx_value("form_stage_main\\form_mail\\form_mail")
    form.Visible = false
    nx_destroy(form)
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function close_on_click(self)
  local form = self.Parent.Parent
  form.Visible = false
  form:Close()
  return 1
end
function is_have_noread_mail()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local rownum = client_player:GetRecordRows("RecvLetterRec")
  for row = 0, rownum - 1 do
    local is_read = client_player:QueryRecord("RecvLetterRec", row, POST_TABLE_READFLAG)
    if nx_int(is_read) == nx_int(0) then
      return true
    end
  end
  return false
end
function is_have_user_noread_mail()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local rownum = client_player:GetRecordRows("RecvLetterRec")
  for row = 0, rownum - 1 do
    local ntype = client_player:QueryRecord("RecvLetterRec", row, POST_TABLE_TYPE)
    if nx_int(ntype) > nx_int(LETTER_USER_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_USER_TYPE_MAX) then
      local is_read = client_player:QueryRecord("RecvLetterRec", row, POST_TABLE_READFLAG)
      if nx_int(is_read) == nx_int(0) then
        return true
      end
    end
  end
  return false
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
