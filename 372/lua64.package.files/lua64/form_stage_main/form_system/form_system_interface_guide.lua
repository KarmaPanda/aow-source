require("util_gui")
require("util_functions")
local FORM_MAIN = "form_stage_main\\form_system\\form_system_interface_setting"
local FORM_GUIDE = "form_stage_main\\form_system\\form_system_interface_guide"
local MODE_3D = 0
local MODE_25D = 1
function auto_show_hide_guide()
  local form = nx_value(FORM_GUIDE)
  if nx_is_valid(form) then
    form.Visible = not form.Visible
    if form.Visible then
      on_gui_size_change()
      init_ui_content(form)
      form:Show()
      local gui = nx_value("gui")
      gui.Desktop:ToFront(form)
    else
      on_btn_close_click(form.btn_close)
    end
  else
    util_show_form(FORM_GUIDE, true)
  end
end
function reset_scene()
  local form = nx_value(FORM_GUIDE)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", FORM_GUIDE, true, false)
  if nx_is_valid(form) then
    form.Visible = false
  end
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  on_gui_size_change()
  init_ui_content(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "first_flag") and form.first_flag then
    form.first_flag = nil
  end
  form.Visible = false
end
function on_rbtn_25d_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    local result = update_operate_mode(rbtn.ParentForm, MODE_25D)
    if not result and nx_is_valid(form) then
      form.rbtn_3d.Enabled = false
      form.rbtn_3d.Checked = true
      form.rbtn_3d.Enabled = true
    end
  end
end
function on_rbtn_3d_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    local result = update_operate_mode(rbtn.ParentForm, MODE_3D)
    if not result and nx_is_valid(form) then
      form.rbtn_25d.Enabled = false
      form.rbtn_25d.Checked = true
      form.rbtn_25d.Enabled = true
    end
  end
end
function on_btn_ok_click(btn)
  on_btn_close_click(btn)
end
function init_ui_content(form)
  local game_config_info = nx_value("game_config_info")
  form.rbtn_3d.Enabled = false
  form.rbtn_25d.Enabled = false
  local mode = util_get_property_key(game_config_info, "operate_control_mode", MODE_3D)
  if nx_int(mode) == nx_int(MODE_3D) then
    form.rbtn_3d.Checked = true
    form.rbtn_25d.Checked = false
  else
    form.rbtn_3d.Checked = false
    form.rbtn_25d.Checked = true
  end
  form.rbtn_3d.Enabled = true
  form.rbtn_25d.Enabled = true
end
function update_operate_mode(form, mode)
  if not nx_is_valid(form) then
    return false
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return false
  end
  if nx_int(mode) ~= nx_int(MODE_3D) then
    mode = MODE_25D
  end
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText(nx_int(mode) == nx_int(MODE_3D) and "ui_control_3D" or "ui_control_2.5D")
  local result = util_form_confirm("", info)
  if result == "ok" and nx_is_valid(form) then
    if nx_find_custom(form, "open_after_close") and form.open_after_close then
      game_config_info.is_first_open = 0
      form.open_after_close = nil
      util_auto_show_hide_form(FORM_MAIN)
    end
    nx_execute(FORM_MAIN, "switch_mode", nx_string(mode))
    handle_switch_event(nx_string(mode))
    return true
  else
    return false
  end
end
function handle_switch_event(mode)
  local form = nx_value(FORM_MAIN)
  if nx_is_valid(form) and nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
    nx_execute(nx_string(form.subform.Name), nx_int(mode) == nx_int(0) and "on_switchto_3dmode" or "on_switchto_25dmode", form.subform)
    form.rbtn_tag3D.Checked = nx_int(mode) == nx_int(0) and true or false
    form.rbtn_tag25D.Checked = nx_int(mode) == nx_int(1) and true or false
  end
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
