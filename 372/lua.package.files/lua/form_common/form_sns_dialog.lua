require("util_functions")
require("share\\chat_define")
function get_new_confirm_form(form_type)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local form = nx_value(form_type .. "_form_sns_dialog")
  if nx_is_valid(form) then
    form.Visible = true
    form:ShowModal()
    return nx_null()
  end
  local gui = nx_value("gui")
  form = nx_call("util_gui", "util_get_form", "form_common\\form_sns_dialog", true, true)
  if not nx_is_valid(form) then
    local error_text = nx_widestr(util_text("msg_CreateFormFailed")) .. nx_widestr(gui.skin_path) .. nx_widestr("form_common\\form_sns_dialog.xml")
    return 0
  end
  form.event_type = form_type
  nx_set_value(form_type .. "_form_sns_dialog", form)
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
  return 1
end
function on_main_form_close(self)
  self.mltbox_info:Clear()
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function ok_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "sns_dialog_return", "ok")
  else
    nx_gen_event(form, event_type .. "_" .. "sns_dialog_return", "ok")
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
    nx_gen_event(form, "sns_dialog_return", "cancel")
  else
    nx_gen_event(form, event_type .. "_" .. "sns_dialog_return", "cancel")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function clear()
end
function on_btn_goto_click(btn)
  if not nx_find_custom(btn, "GotoName") then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_sns_forms_transmit_001"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_sns_feed_back_goto", nx_widestr(btn.GotoName))
    local form = btn.ParentForm
    form:Close()
  end
end
function on_btn_broadcast_click(btn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form = btn.ParentForm
  local item_count = form.mltbox_info.ItemCount
  if nx_number(item_count) ~= 1 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_sns_forms_tonghe_001"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local name = client_player:QueryProp("Name")
    local desc = form.mltbox_info:GetHtmlItemText(0)
    local text = nx_widestr(name) .. nx_widestr(util_text("ui_sns_forms_tonghe")) .. nx_widestr("\163\186") .. nx_widestr(desc)
    nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, nx_widestr(text), 1, "")
  end
end
function on_btn_reply_click(btn)
  if not nx_find_custom(btn, "FeedId") then
    return
  end
  if not nx_find_custom(btn, "Owner") then
    return
  end
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_relation\\form_feed_info", "get_reply_count", nx_string(btn.FeedId))
  local form_reply_simply = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply_simple", true, false)
  form_reply_simply.Owner = btn.Owner
  form_reply_simply.FeedId = btn.FeedId
  form_reply_simply.FeedDesc = ""
  local item_count = form.mltbox_info.ItemCount
  if nx_number(item_count) == 1 then
    form_reply_simply.FeedDesc = form.mltbox_info:GetHtmlItemText(0)
  end
end
function show_common_text(dialog, text)
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(text), -1)
end
