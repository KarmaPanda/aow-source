require("util_gui")
require("util_functions")
local g_form_name = "form_common\\form_revert_time"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) * 79 / 100
  form.Top = (gui.Height - form.Height) / 14
end
function on_main_form_open(form)
  form.Fixed = false
  local box = form.mltbox_1
  box.Left = 0
  box.Top = 0
  box.Width = form.Width
  box.Height = form.Height
  local dis = 0
  local view = nx_string(dis) .. "," .. nx_string(dis) .. "," .. nx_string(box.Width - dis) .. "," .. nx_string(box.Height - dis)
  box.ViewRect = view
  box:Clear()
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) * 79 / 100
  form.Top = (gui.Height - form.Height) / 14
end
function on_main_form_close(form)
  local mgr = nx_value("PlayerTrackModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("PlayerTrackModule")
    nx_set_value("PlayerTrackModule", mgr)
  end
  mgr:EndShowTrack()
  nx_destroy(form)
end
function on_gui_size_change()
  local form = nx_value(g_form_name)
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.Left = (gui.Width - form.Width) * 79 / 100
    form.Top = (gui.Height - form.Height) / 14
  end
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function show_revert()
  util_show_form(g_form_name, true)
end
function close_revert()
  util_show_form(g_form_name, false)
end
