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
  self.Default = self.ok_btn
  change_control_size(self)
  return 1
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    self.info_label.Text = nx_widestr("")
    self.mltbox_info:Clear()
    nx_destroy(self)
  end
end
function change_control_size(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupscrollbox_mlt.IsEditMode = true
  local mltbox = form.mltbox_info
  local text_height = mltbox:GetContentHeight()
  mltbox.Height = text_height + 10
  form.groupscrollbox_mlt.Height = 190
  form.groupscrollbox_mlt.IsEditMode = false
end
function ok_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "third_confirm_return", "ok")
  else
    nx_gen_event(form, event_type .. "_" .. "third_confirm_return", "ok")
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
    nx_gen_event(form, "third_confirm_return", "cancel")
  else
    nx_gen_event(form, event_type .. "_" .. "third_confirm_return", "cancel")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function clear()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", false, false)
  if nx_is_valid(dialog) then
    dialog:Close()
    if nx_is_valid(dialog) then
      nx_destroy(dialog)
    end
  end
end
function show_common_text(dialog, text)
  text = nx_widestr(text)
  local len = nx_ws_length(text)
  if len <= 10 then
    dialog.mltbox_info.Visible = false
    dialog.info_label.Visible = true
    dialog.info_label.Text = nx_widestr(text)
  else
    dialog.info_label.Visible = false
    dialog.mltbox_info.Visible = true
    dialog.mltbox_info:Clear()
    dialog.mltbox_info:AddHtmlText(text, -1)
  end
end
