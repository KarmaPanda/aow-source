require("util_gui")
require("custom_sender")
require("define\\map_lable_define")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) * 3 / 4
  form.Top = (gui.Height - form.Height) * 3 / 4
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 10)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", 11)
  nx_execute("form_stage_main\\form_main\\form_main", "show_changfeng_jiu_btn", false)
  nx_destroy(form)
end
function on_update_time(form, param1, param2)
  local last = form.lbl_time.Text
  if nx_int(last) <= nx_int(0) then
    form:Close()
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(last) - nx_int(1))
end
function on_btn_ok_click(btn)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_response", false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function on_btn_cancel_click(btn)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_response", false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_close_click(btn)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_response", false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function show_form(...)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_response", false)
  if not nx_is_valid(form) then
    form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_response", true)
    form.Visible = true
    form:Show()
  end
  nx_execute("form_stage_main\\form_main\\form_main", "show_changfeng_jiu_btn", true)
  form.lbl_time.Text = nx_widestr(arg[1])
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  if nx_widestr(arg[2]) == nx_widestr("") then
    form.lbl_scene.Text = nx_widestr("")
    form.lbl_x.Text = nx_widestr("")
    form.lbl_z.Text = nx_widestr("")
    nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", 11)
  else
    local gui = nx_value("gui")
    form.lbl_scene.Text = nx_widestr(gui.TextManager:GetText(arg[2]))
    form.lbl_x.Text = nx_widestr(arg[3])
    form.lbl_z.Text = nx_widestr(arg[4])
    nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map_ani", 11, arg[3], arg[4], 54, 54, MAP_CLIENT_NPC, "ui_fqfs_tips_jiu")
  end
end
function close_form()
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_response", false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function show_or_hide()
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_jiu_response", false)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == true then
    form.Visible = false
  else
    form.Visible = true
  end
end
