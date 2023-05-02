require("const_define")
require("share\\itemtype_define")
require("util_functions")
function reset_scene()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2 - gui.Height / 8
  local drivenpc = nx_value("DriveNpcMgr")
  if not nx_is_valid(drivenpc) then
    return
  end
  drivenpc:SetGunManCoord(form.Left + form.Width / 2, form.Top + form.Height / 2)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
end
function change_form_size()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2 - gui.Height / 8
  local drivenpc = nx_value("DriveNpcMgr")
  if not nx_is_valid(drivenpc) then
    return
  end
  drivenpc:SetGunManCoord(form.Left + form.Width / 2, form.Top + form.Height / 2)
end
