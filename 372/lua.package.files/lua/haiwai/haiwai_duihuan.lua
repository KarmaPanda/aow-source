require("form_stage_main\\switch\\url_define")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    local bIsBindAccount = client_player:QueryProp("IsBindAccount")
    if bIsBindAccount == 1 then
      form_error(form, "zhanghao_tishi3")
      return
    end
  end
  local str1 = form.ipt_im.Text
  local str2 = form.ipt_code.Text
  if nx_string(str1) == "" or nx_string(str2) == "" then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if str1 ~= str2 then
    form.ipt_im.Text = nx_widestr("")
    form.ipt_code.Text = nx_widestr("")
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    form_error(form, "zhanghao_tishi2")
    return
  end
  nx_execute("custom_sender", "custom_record_account_log", nx_widestr(str1))
  form_error(form, "zhanghao_tishi1")
  form.ipt_im.Text = nx_widestr("")
  form.ipt_code.Text = nx_widestr("")
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_1_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_INDONESIA_9YIN_ACCOUNT_REG)
  end
end
function form_error(form, text)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  local info = gui.TextManager:GetFormatText(text)
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.Left = form.Left + (form.Width - dialog.Width) / 2
  dialog.Top = form.Top + (form.Height - dialog.Height) / 2
  dialog:ShowModal()
  nx_wait_event(100000000, dialog, "error_return")
end
