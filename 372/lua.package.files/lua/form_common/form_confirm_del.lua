require("util_functions")
function main_form_init(self)
  self.Fixed = false
  self.event_type = ""
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local gui = nx_value("gui")
  local text_del = gui.TextManager:GetText("ui_hp_del")
  local text = gui.TextManager:GetFormatText("ui_bag_delmsg", text_del)
  text = nx_widestr(text)
  self.info_label.Visible = false
  self.mltbox_info.Visible = true
  self.mltbox_info:Clear()
  self.mltbox_info:AddHtmlText(text, -1)
  self.del_edit.MaxLength = nx_ws_length(text_del)
  self.Default = self.ok_btn
  return 1
end
function on_main_form_close(self)
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  if nx_is_valid(self) then
    self.info_label.Text = nx_widestr("")
    self.mltbox_info:Clear()
    nx_destroy(self)
  end
end
function ok_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  local text = form.del_edit.Text
  local gui = nx_value("gui")
  local text_del = gui.TextManager:GetText("ui_hp_del")
  text_del = nx_widestr(text_del)
  local event_str = "ok"
  if not nx_ws_equal(text, text_del) then
    event_str = "cancel"
  end
  if event_type == "" then
    nx_gen_event(form, "confirm_return", event_str)
  else
    nx_gen_event(form, event_type .. "_" .. "confirm_return", event_str)
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "confirm_return", "cancel")
  else
    nx_gen_event(form, event_type .. "_" .. "confirm_return", "cancel")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function clear()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm_del", false, false)
  if nx_is_valid(dialog) then
    dialog:Close()
    if nx_is_valid(dialog) then
      nx_destroy(dialog)
    end
  end
end
