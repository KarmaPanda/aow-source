require("util_functions")
function get_new_confirm_form(form_type)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local form = nx_value(form_type .. "_" .. "form_common\\form_confirm")
  if nx_is_valid(form) then
    form:ShowModal()
    return nx_null()
  end
  local gui = nx_value("gui")
  form = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_common\\form_confirm.xml")
  if not nx_is_valid(form) then
    nx_msgbox(util_text("msg_CreateFormFailed") .. gui.skin_path .. formname .. ".xml")
    return 0
  end
  form.Name = "form_common\\form_confirm"
  form.event_type = form_type
  nx_set_value(form_type .. "_form_confirm", form)
  return form
end
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
  if form.rbtn_1.Checked then
    if event_type == "" then
      nx_gen_event(form, "confirm_return", "silver_card")
    else
      nx_gen_event(form, event_type .. "_" .. "confirm_return", "silver_card")
    end
  elseif event_type == "" then
    nx_gen_event(form, "confirm_return", "silver")
  else
    nx_gen_event(form, event_type .. "_" .. "confirm_return", "silver")
  end
  form:Close()
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
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", false, false)
  if nx_is_valid(dialog) then
    dialog:Close()
    if nx_is_valid(dialog) then
      nx_destroy(dialog)
    end
  end
  local connect_break_form = nx_value("breakconnect_form_confirm")
  if nx_is_valid(connect_break_form) then
    connect_break_form:Close()
    if nx_is_valid(connect_break_form) then
      nx_destroy(connect_break_form)
    end
  end
  local exit_game_form = nx_value("exit_game_form_confirm")
  if nx_is_valid(exit_game_form) then
    exit_game_form:Close()
    if nx_is_valid(exit_game_form) then
      nx_destroy(exit_game_form)
    end
  end
  local inphase_clone_menu_form = nx_value("inphase_clone_menu_form_confirm")
  if nx_is_valid(inphase_clone_menu_form) then
    inphase_clone_menu_form:Close()
    if nx_is_valid(inphase_clone_menu_form) then
      nx_destroy(inphase_clone_menu_form)
    end
  end
  local reset_clone_form = nx_value("reset_clone_form_confirm")
  if nx_is_valid(reset_clone_form) then
    reset_clone_form:Close()
    if nx_is_valid(reset_clone_form) then
      nx_destroy(reset_clone_form)
    end
  end
end
function show_no_speedup_msgbox()
  local gui = nx_value("gui")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
  if not nx_is_valid(dialog) then
    return
  end
  dialog.cancel_btn.Visible = false
  dialog.ok_btn.Width = dialog.ok_btn.Width + 30
  dialog.ok_btn.Left = (dialog.Width - dialog.ok_btn.Width) / 2
  dialog.mltbox_info.HtmlText = gui.TextManager:GetText("ui_dont_speedup")
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_ok")
  dialog:ShowModal()
end
function show_no_speedup_msgbox2()
  local gui = nx_value("gui")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
  if not nx_is_valid(dialog) then
    return
  end
  dialog.cancel_btn.Visible = false
  dialog.ok_btn.Width = dialog.ok_btn.Width + 30
  dialog.ok_btn.Left = (dialog.Width - dialog.ok_btn.Width) / 2
  dialog.mltbox_info.HtmlText = gui.TextManager:GetText("ui_dont_speedup2")
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_ok")
  dialog:ShowModal()
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
function relogin_btn_click(btn)
  local form = btn.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "confirm_return", "relogin")
  else
    nx_gen_event(form, event_type .. "_" .. "confirm_return", "relogin")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
