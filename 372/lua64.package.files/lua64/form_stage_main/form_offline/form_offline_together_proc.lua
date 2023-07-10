require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("form_stage_main\\form_offline\\offline_define")
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  update_form_pos(form)
  form.Visible = true
  dataBind(form)
  refresh_form(form)
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.lbl_1.Text = nx_widestr(util_text("ui_WuXueShuangXiu"))
  dialog.lbl_3.Visible = false
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(util_text("ui_stop_training")), -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_END_TOGETHER))
  end
end
function update_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = gui.Height * 3 / 8
end
function show_window(ratio)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_together_proc", true, false)
  form.lbl_ratio.Text = nx_widestr("+" .. nx_string(ratio) .. "%")
  if nx_number(ratio) > 0 then
    form:Show()
  else
    form:Close()
  end
end
function dataBind(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Faculty", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_1", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_2", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_3", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_4", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_5", "int", form, nx_current(), "prop_callback_refresh")
  end
end
function prop_callback_refresh(form, PropName, PropType, Value)
  if not nx_is_valid(form) then
    return 1
  end
  refresh_form(form)
  return 1
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return 1
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local faculty = player:QueryProp("Faculty")
  local liveGroove = player:QueryProp("LiveGroove_1") + player:QueryProp("LiveGroove_2") + player:QueryProp("LiveGroove_3") + player:QueryProp("LiveGroove_4") + player:QueryProp("LiveGroove_5")
  form.pbar_faculty.Maximum = 2100000000
  form.pbar_faculty.Value = faculty
  form.pbar_liveGroove.Maximum = 999
  form.pbar_liveGroove.Value = liveGroove / 1000
end
