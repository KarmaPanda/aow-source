require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
function exit_main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
end
function on_exit_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_exit_main_form_close(self)
  nx_destroy(self)
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  nx_gen_event(form, "respond", "save")
  if nx_is_valid(form) then
    form:Close()
  end
  return
end
function on_btn_no_save_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  nx_gen_event(form, "respond", "nosave")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form.Visivle = false
  nx_gen_event(form, "respond", "cancel")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_open_form(form)
  form.Visible = true
end
