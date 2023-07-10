require("custom_sender")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local check_words = nx_value("CheckWords")
  if nx_is_valid(check_words) and not check_words:CheckBadWords(nx_widestr(pos_name)) then
    local gui = nx_value("gui")
    local text = nx_widestr(gui.TextManager:GetText("ui_EnterValidPosName"))
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    form:Close()
    return 0
  end
  if nx_string(form.ipt_1.Text) ~= nx_string("") then
    custom_request_guild_add_position(nx_widestr(form.ipt_1.Text))
  end
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(self)
  return 1
end
