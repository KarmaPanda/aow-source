require("form_stage_main\\switch\\url_define")
function form_init(form)
  form.Fixed = false
  form.event_name = ""
  return 1
end
function on_form_open(form)
  form.Default = form.btn_return
  form.btn_url.Visible = false
  form.btn_51089.Visible = false
  form.btn_single_vip.Visible = false
  return 1
end
function on_btn_return_click(btn)
  local form = btn.Parent
  if string.len(form.event_name) > 0 then
    nx_gen_event(form, form.event_name)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  return 1
end
function on_btn_url_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_ACTIVATION_CODE_LOGIN)
  end
  local form = btn.Parent
  if string.len(form.event_name) > 0 then
    nx_gen_event(form, form.event_name)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  return 1
end
function on_btn_51089_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_PASSPORT_LOGIN)
  end
  local form = btn.Parent
  if string.len(form.event_name) > 0 then
    nx_gen_event(form, form.event_name)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  return 1
end
function on_btn_single_vip_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_SINGLE_PLAYER_VIP)
  end
  local form = btn.Parent
  if string.len(form.event_name) > 0 then
    nx_gen_event(form, form.event_name)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function ok_btn_cancel_click(btn)
  local form = btn.Parent
  if string.len(form.event_name) > 0 then
    nx_gen_event(form, form.event_name, "cancel")
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  return 1
end
function clear()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_connect", false, false)
  if nx_is_valid(dialog) then
    dialog:Close()
    nx_destroy(dialog)
  end
end
function on_btn_ok_click(btn)
  local form = btn.Parent
  if string.len(form.event_name) > 0 then
    nx_gen_event(form, form.event_name, "ok")
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
