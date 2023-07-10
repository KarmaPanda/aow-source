require("util_gui")
require("custom_sender")
require("define\\gamehand_type")
require("form_stage_main\\form_world_war\\form_world_war_define")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_stop_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_world_war_sender", CLIENT_WORLDWAR_ESCORT_CONTROL, form.obj, 1)
  form.Visible = false
  form:Close()
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_world_war_sender", CLIENT_WORLDWAR_ESCORT_CONTROL, form.obj, 2)
  form.Visible = false
  form:Close()
end
function show_form(obj, ntype)
  local form = util_get_form("form_stage_main\\form_world_war\\form_world_war_escort_control", true)
  form.Visible = true
  form.obj = obj
  init_button(form, ntype)
  form:Show()
  return 1
end
function init_button(form, btntype)
  if btntype == 1 then
    form.btn_stop.Visible = true
    form.btn_start.Visible = false
    return
  end
  if btntype == 2 then
    form.btn_stop.Visible = false
    form.btn_start.Visible = true
    return
  end
end
