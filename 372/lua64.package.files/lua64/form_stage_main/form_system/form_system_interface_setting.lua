require("util_functions")
require("define\\camera_mode")
local FORM_PATH = "form_stage_main\\form_system\\form_system_interface_setting"
function chat_open_form()
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  on_cbtn_func_click(form.cbtn_func7)
end
local sub_interfaces = {
  "form_stage_main\\form_system\\form_system_interface_auxmode",
  "form_stage_main\\form_system\\form_system_interface_shot",
  "form_stage_main\\form_system\\form_system_interface_mouse",
  "form_stage_main\\form_system\\form_system_interface_fight",
  "form_stage_main\\form_system\\form_system_interface_chat",
  "form_stage_main\\form_system\\form_system_interface_headtop",
  "form_stage_main\\form_system\\form_system_interface_social",
  "form_stage_main\\form_system\\form_system_interface_other"
}
FORM_INTERFACE_MAIN = "form_stage_main\\form_system\\form_system_interface_setting"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_form(form)
  set_tag_enable(form, 1)
  create_sub_interface(sub_interfaces[1])
end
function on_main_form_close(form)
  close_all_sub_interfaces()
  nx_destroy(form)
end
function on_gui_size_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 1
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_cbtn_func_click(cbtn)
  local form = cbtn.ParentForm
  local index = nx_number(cbtn.DataSource)
  set_tag_enable(form, index)
  create_sub_interface(sub_interfaces[index])
end
function on_btn_default_click(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
    nx_execute(nx_string(form.subform.Name), "on_btn_default_click", form.subform)
  end
end
function on_btn_apply_click(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
    nx_execute(nx_string(form.subform.Name), "on_btn_apply_click", form.subform)
    save_config_to_server()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
    nx_execute(nx_string(form.subform.Name), "on_btn_cancel_click", form.subform)
  end
  local form = btn.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
    nx_execute(nx_string(form.subform.Name), "on_btn_ok_click", form.subform)
    save_config_to_server()
  end
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_tag3D_click(rbtn)
  local form = rbtn.ParentForm
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  if nx_int(game_config_info.operate_control_mode) == nx_int(0) then
    return
  end
  local text = gui.TextManager:GetText("ui_control_3D")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if result == "ok" then
    switch_mode("0")
    if nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
      nx_execute(nx_string(form.subform.Name), "on_switchto_3dmode", form.subform)
    end
  else
    form.rbtn_tag3D.Checked = false
    form.rbtn_tag25D.Checked = true
  end
end
function on_rbtn_tag25D_click(rbtn)
  local form = rbtn.ParentForm
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  if nx_int(game_config_info.operate_control_mode) == nx_int(1) then
    return
  end
  local text = gui.TextManager:GetText("ui_control_2.5D")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if result == "ok" then
    switch_mode("1")
    if nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
      nx_execute(nx_string(form.subform.Name), "on_switchto_25dmode", form.subform)
    end
  else
    form.rbtn_tag3D.Checked = true
    form.rbtn_tag25D.Checked = false
  end
end
function create_sub_interface(form_name)
  local form = nx_value(FORM_INTERFACE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
    if nx_string(form.subform.Name) == nx_string(form_name) then
      return
    end
    form.subform:Close()
  end
  local subface = nx_execute("util_gui", "util_get_form", form_name, true, false)
  if not nx_is_valid(subface) then
    return
  end
  form.groupbox_main:Add(subface)
  form.subform = subface
  subface.Top = 0
  subface.Left = 0
  subface.Visible = true
end
function close_all_sub_interfaces()
  for i = 1, table.getn(sub_interfaces) do
    local subface = nx_value(sub_interfaces[i])
    if nx_is_valid(subface) then
      subface:Close()
    end
  end
end
function init_form(form)
  local game_config_info = nx_value("game_config_info")
  if nx_int(game_config_info.operate_control_mode) == nx_int(0) then
    form.rbtn_tag3D.Checked = true
    form.rbtn_tag25D.Checked = false
  elseif nx_int(game_config_info.operate_control_mode) == nx_int(1) then
    form.rbtn_tag3D.Checked = false
    form.rbtn_tag25D.Checked = true
  end
end
function set_tag_enable(form, index)
  local cbtn_name = "cbtn_func"
  for i = 1, 8 do
    local cbtn = cbtn_name .. nx_string(i)
    if nx_find_custom(form, cbtn) then
      local control = nx_custom(form, cbtn)
      control.Checked = nx_int(index) == nx_int(i)
      control.ForeColor = control.Checked and "255,255,255,255" or "255,178,153,127"
    end
  end
end
function switch_mode(mode)
  local game_config_info = nx_value("game_config_info")
  game_config_info.operate_control_mode = nx_int(mode)
  nx_execute("custom_sender", "custom_set_operate_mode", mode)
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if nx_string(mode) == nx_string("0") then
    game_config_info.lmouse_normal_mode = 1
    game_config_info.mr_rotate_mode = 0
    game_control.MLKeySlideCamera = true
    game_control.MRKeySlideCamera = true
    local camera_control = game_control:GetCameraController(GAME_CAMERA_NORMAL)
    camera_control.LockCamera = false
    game_config_info.lock_camera = 0
  elseif nx_string(mode) == nx_string("1") then
    game_config_info.lmouse_normal_mode = 0
    game_config_info.mr_rotate_mode = 0
    game_control.MLKeySlideCamera = false
    game_control.MRKeySlideCamera = true
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if nx_is_valid(shortcut_keys) then
    shortcut_keys:SwitchOperateMode(nx_int(mode))
  end
  nx_execute("form_stage_main\\form_shortcut_key", "update_window")
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  save_config_to_server()
end
function save_config_to_server()
  local customizing = nx_value("customizing_manager")
  if not nx_is_valid(customizing) then
    return
  end
  customizing:SaveConfigToServer()
end
