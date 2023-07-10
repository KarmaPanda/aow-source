require("util_functions")
require("util_gui")
local FORM_NAME = "form_stage_main\\form_confirm_force"
function main_form_init(self)
  self.Fixed = false
  self.event_type = ""
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_betray_new_school_del")
  text = nx_widestr(text)
  self.info_label.Visible = false
  self.mltbox_info.Visible = true
  self.mltbox_info:Clear()
  self.mltbox_info:AddHtmlText(text, -1)
  local text_del = gui.TextManager:GetText("ui_betray_input_text")
  self.del_edit.MaxLength = nx_ws_length(text_del)
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
function on_btn_ok_click(self)
  local form = self.ParentForm
  local text = form.del_edit.Text
  local gui = nx_value("gui")
  local text_del = gui.TextManager:GetText("ui_betray_input_text")
  text_del = nx_widestr(text_del)
  if not nx_ws_equal(text, text_del) then
    return
  end
  nx_execute("custom_sender", "custom_check_delete_force")
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  nx_execute("custom_sender", "custom_check_delete_force", 1)
  form:Close()
end
function open_panel(...)
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
