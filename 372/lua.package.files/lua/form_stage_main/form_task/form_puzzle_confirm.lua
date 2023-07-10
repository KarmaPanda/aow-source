require("util_functions")
require("define\\object_type_define")
function main_form_init(self)
  self.Fixed = false
  self.event_type = ""
  self.add_arrest = 0
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.Default = self.ok_btn
  return 1
end
function on_main_form_close(self)
  self.info_label.Text = nx_widestr("")
  self.mltbox_info:Clear()
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function ok_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  form:Close()
  if event_type == "" then
    nx_gen_event(form, "puzzle_confirm_return", "ok")
  else
    nx_gen_event(form, event_type .. "_" .. "puzzle_confirm_return", "ok")
  end
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  form:Close()
  if event_type == "" then
    nx_gen_event(form, "puzzle_confirm_return", "cancel")
  else
    nx_gen_event(form, event_type .. "_" .. "puzzle_confirm_return", "cancel")
  end
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function show_common_text(dialog, text)
  if not nx_is_valid(dialog) then
    return
  end
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
function clear()
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_puzzle_confirm", false, false)
  if nx_is_valid(dialog) then
    dialog:Close()
    if nx_is_valid(dialog) then
      nx_destroy(dialog)
    end
  end
end
