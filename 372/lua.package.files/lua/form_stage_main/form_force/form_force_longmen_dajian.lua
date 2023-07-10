require("util_gui")
require("custom_sender")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_execute("form_stage_main\\form_main\\form_main", "show_changfeng_dajian_btn", true)
end
function on_main_form_close(form)
  nx_execute("form_stage_main\\form_main\\form_main", "show_changfeng_dajian_btn", false)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 2, form.obj, 0)
  form.Visible = false
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 2, form.obj, 1)
  form.Visible = false
end
function on_btn_3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 2, form.obj, 2)
  form.Visible = false
end
function show_form(obj)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_dajian", true)
  form.Visible = true
  form.obj = obj
  form:Show()
  return 1
end
function close_form()
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_dajian", false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function refresh_form(index)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_dajian", false)
  if not nx_is_valid(form) then
    return
  end
  if index == 0 then
    form.btn_1.Enabled = false
  elseif index == 1 then
    form.btn_2.Enabled = false
  elseif index == 2 then
    form.btn_3.Enabled = false
  end
end
function show_or_hide()
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_dajian", false)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == true then
    form.Visible = false
  else
    form.Visible = true
  end
end
