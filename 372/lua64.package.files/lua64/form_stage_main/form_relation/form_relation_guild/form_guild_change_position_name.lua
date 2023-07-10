require("custom_sender")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
  self.pos_lv = -1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_change_position_name(pos_lv)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_change_position_name", true)
  if nx_is_valid(form) then
    form.pos_lv = nx_int(pos_lv)
    form.Visible = true
    form:Show()
  end
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.pos_lv then
    local pos_name = form.ipt_1.Text
    if 0 >= nx_ws_length(nx_widestr(pos_name)) then
      show_common_dialog("ui_input")
      return 0
    end
    local check_words = nx_value("CheckWords")
    if nx_is_valid(check_words) and not check_words:CheckBadWords(nx_widestr(pos_name)) then
      show_common_dialog("ui_EnterValidPosName")
      form.ipt_1.Text = ""
      return 0
    end
    custom_request_guild_set_postion_name(nx_int(form.pos_lv), nx_widestr(pos_name))
  end
  form:Close()
end
function show_common_dialog(text)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local show_text = gui.TextManager:GetText(text)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, show_text)
  dialog:ShowModal()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
