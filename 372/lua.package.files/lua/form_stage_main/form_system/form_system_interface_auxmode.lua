require("util_gui")
require("util_functions")
require("define\\camera_mode")
require("define\\control_mode_define")
require("define\\fight_operate_mode_define")
local FORM_GUIDE = "form_stage_main\\form_system\\form_system_interface_guide"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  init_ui_content(form)
end
function on_main_form_close(form)
  update_operate(form)
  nx_destroy(form)
end
function on_btn_ok_click(form)
  save_to_file(form)
end
function on_btn_cancel_click(form)
  form:Close()
end
function on_btn_apply_click(form)
  save_to_file(form)
end
function on_btn_default_click(form)
  recover_to_default(form)
end
function on_switchto_3dmode(form)
end
function on_switchto_25dmode(form)
end
function on_rbtn_joystick_checked_changed(rbtn)
end
function on_btn_operate_click(btn)
  nx_execute(FORM_GUIDE, "auto_show_hide_guide")
end
function init_ui_content(form)
  local game_config_info = nx_value("game_config_info")
  local camera_mode = game_config_info.camera_value
  if nx_int(camera_mode) == nx_int(GAME_CAMERA_NORMAL) then
    form.rbtn_joystick.Checked = false
    form.rbtn_mouse.Checked = true
  elseif nx_int(camera_mode) == nx_int(GAME_CAMERA_BINDPOS) then
    form.rbtn_joystick.Checked = true
    form.rbtn_mouse.Checked = false
  else
    form.rbtn_joystick.Checked = false
    form.rbtn_mouse.Checked = true
  end
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if form.rbtn_joystick.Checked == true then
    game_config_info.camera_value = nx_int(GAME_CAMERA_BINDPOS)
    game_config_info.game_control_mode = 1
    game_control.CameraMode = GAME_CAMERA_BINDPOS
    game_control.FightOperateMode = FIGHT_OPERATE_MODE_JOYSTICK
  else
    game_config_info.camera_value = nx_int(GAME_CAMERA_NORMAL)
    game_config_info.game_control_mode = 0
    game_control.CameraMode = GAME_CAMERA_NORMAL
    game_control.FightOperateMode = FIGHT_OPERATE_MODE_NORMAL
  end
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
end
function recover_to_default(form)
  local game_config_info = nx_value("game_config_info")
  form.rbtn_joystick.Checked = false
  form.rbtn_mouse.Checked = true
end
function update_operate(form)
end
