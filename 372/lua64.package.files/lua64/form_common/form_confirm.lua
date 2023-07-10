require("util_functions")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function get_new_confirm_form(form_type)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local form = nx_value(form_type .. "_form_confirm")
  if nx_is_valid(form) then
    form:ShowModal()
    return form
  end
  local gui = nx_value("gui")
  form = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_common\\form_confirm.xml")
  if not nx_is_valid(form) then
    nx_msgbox(nx_string(util_text("msg_CreateFormFailed")) .. gui.skin_path .. formname .. ".xml")
    return 0
  end
  form.Name = "form_common\\form_confirm"
  form.event_type = form_type
  nx_set_value(form_type .. "_form_confirm", form)
  if "exit_game" == form_type then
    local sdo_login_interface = nx_value("SdoLoginInterface")
    if nx_is_valid(sdo_login_interface) then
      if sdo_login_interface.ShowLoginDialog then
        form.show_login_dialog = true
        local form_login = nx_value("form_stage_login\\form_login")
        if not nx_is_valid(form_login) then
          return
        end
        nx_execute("form_stage_login\\form_login", "set_sdo_login_dialog", form_login, false)
      end
      sdo_login_interface.ShowLoginDialog = false
    end
    local login_form = nx_value("form_stage_login\\form_login")
    if nx_is_valid(login_form) and login_form.groupbox_web.Visible then
      login_form.web_view_login:Disable()
      login_form.groupbox_web.Visible = false
    end
  end
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
  self.relogin_btn.Visible = false
  return 1
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    if nx_find_custom(self, "show_login_dialog") and self.show_login_dialog then
      local sdo_login_interface = nx_value("SdoLoginInterface")
      if nx_is_valid(sdo_login_interface) and self.show_login_dialog then
        local form_login = nx_value("form_stage_login\\form_login")
        if not nx_is_valid(form_login) then
          return
        end
        nx_execute("form_stage_login\\form_login", "set_sdo_login_dialog", form_login, true)
      end
      self.show_login_dialog = false
    end
    self.info_label.Text = nx_widestr("")
    self.mltbox_info:Clear()
    nx_destroy(self)
  end
end
function ok_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "confirm_return", "ok")
  else
    nx_gen_event(form, event_type .. "_" .. "confirm_return", "ok")
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
function close_btn_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 1
  end
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "confirm_return", "close")
  else
    nx_gen_event(form, event_type .. "_" .. "confirm_return", "close")
  end
  form:Close()
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
  local relogin_form_confirm = nx_value("relogin_form_confirm")
  if nx_is_valid(relogin_form_confirm) then
    relogin_form_confirm:Close()
    if nx_is_valid(relogin_form_confirm) then
      nx_destroy(relogin_form_confirm)
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
  local wuxue_lvlup_form = nx_value("wuxue_lvlup_form_confirm")
  if nx_is_valid(wuxue_lvlup_form) then
    wuxue_lvlup_form:Close()
    if nx_is_valid(wuxue_lvlup_form) then
      nx_destroy(wuxue_lvlup_form)
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
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_dont_speedup"))
  dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_ok"))
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
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_dont_speedup2"))
  dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_ok"))
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
    local mltbox = dialog.mltbox_info
    local height = mltbox:GetContentHeight()
    if height > mltbox.Height then
      mltbox.Height = height + 2
      dialog.lbl_xian.Top = mltbox.Top + mltbox.Height
      dialog.relogin_btn.Top = dialog.lbl_xian.Top + 7
      dialog.ok_btn.Top = dialog.relogin_btn.Top
      dialog.cancel_btn.Top = dialog.relogin_btn.Top
      dialog.lbl_5.Top = dialog.lbl_xian.Top + 6
      dialog.lbl_kuang.Height = mltbox.Height + 16
      dialog.Height = dialog.ok_btn.Top + dialog.ok_btn.Height + 5
    end
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
function hide_cancel_btn(dialog)
  dialog.ok_btn.Left = dialog.cancel_btn.Left
  dialog.cancel_btn.Visible = false
end
