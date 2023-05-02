function on_click_restart_label(btn)
  nx_msgbox("\210\209\187\216\181\247")
  local plugsys = nx_value("PlugSys")
  if nx_is_valid(plugsys) then
    nx_remove_value("PlugSys")
    nx_destroy(plugsys)
    nx_msgbox("\210\209\199\229\179\253")
    return
  end
  if not nx_is_valid(plugsys) then
    plugsys = nx_create("PlugSys")
    if nx_is_valid(plugsys) then
      nx_set_value("PlugSys", plugsys)
    end
  end
  if nx_is_valid(plugsys) then
    nx_msgbox("\210\209\198\244\182\175")
    plugsys:StartMain()
  end
end
function on_click_msgbox_closebtn(btn)
  local par_id = btn.ParentForm
  if not nx_is_valid(par_id) then
    return
  end
  par_id.Visible = false
  par_id:Close()
end
function on_click_start_button(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    plugsys = nx_create("PlugSys")
    if nx_is_valid(plugsys) then
      nx_set_value("PlugSys", plugsys)
    end
  end
  if nx_is_valid(plugsys) then
    plugsys:StartMain()
  end
end
function on_click_end_button(btn)
  local plugsys = nx_value("PlugSys")
  if nx_is_valid(plugsys) then
    nx_remove_value("PlugSys")
    nx_destroy(plugsys)
  end
end
function on_open(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_open")
end
function on_close(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_close")
end
function on_move(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_move")
end
function on_click(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_click")
end
function on_push(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_push")
end
function on_drag_move(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_drag_move")
end
function on_checked_changed(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_checked_changed")
end
function on_selected(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_selected")
end
function on_select_click(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_select_click")
end
function on_select_changed(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_select_changed")
end
function on_get_focus(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_get_focus")
end
function on_lost_focus(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_lost_focus")
end
function on_drag(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_drag")
end
function on_changed(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_changed")
end
function on_add(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_add")
end
function on_remove(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_remove")
end
function on_set_hint(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_set_hint")
end
function on_set_context(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_set_context")
end
function on_get_capture(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_get_capture")
end
function on_lost_capture(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_lost_capture")
end
function on_right_click(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_right_click")
end
function on_left_double_click(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_left_double_click")
end
function on_drag_enter(btn)
  local plugsys = nx_value("PlugSys")
  if not nx_is_valid(plugsys) then
    return
  end
  plugsys:OnMsgTrans(btn, "on_drag_enter")
end
