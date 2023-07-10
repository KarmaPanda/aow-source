require("util_functions")
require("util_gui")
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
  form.cbtn_jump_auto.Visible = false
  form.lbl_jump_auto.Visible = false
end
function on_switchto_25dmode(form)
  local game_config_info = nx_value("game_config_info")
  form.cbtn_jump_auto.Visible = true
  form.lbl_jump_auto.Visible = true
  local key = util_get_property_key(game_config_info, "auto_small_jump", 1)
  form.cbtn_jump_auto.Checked = nx_int(key) == nx_int(1) and true or false
end
function on_tb_scale_value_changed(bar)
  local form = bar.ParentForm
  form.lbl_scale_number.Text = nx_widestr(nx_decimals(bar.Value * 0.1, 1))
  form.pbar_scale.Value = bar.Value
end
function on_cbtn_scale_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.tb_scale.Enabled = cbtn.Checked
  if not cbtn.Checked then
    form.tb_scale.Value = 10
    form.pbar_scale.Value = 10
    form.lbl_scale_number.Text = nx_widestr("1.0")
  end
end
function init_ui_content(form)
  local game_config_info = nx_value("game_config_info")
  local mode = util_get_property_key(game_config_info, "operate_control_mode", 0)
  if nx_int(mode) == nx_int(0) then
    form.cbtn_jump_auto.Visible = false
    form.lbl_jump_auto.Visible = false
  else
    form.cbtn_jump_auto.Visible = true
    form.lbl_jump_auto.Visible = true
  end
  local key = util_get_property_key(game_config_info, "show_strength_cmp_photo", 0)
  form.cbtn_power.Checked = nx_string(key) == nx_string("1") and true or false
  local key = util_get_property_key(game_config_info, "is_check_equip_hardiness", 1)
  form.cbtn_check_hardiness.Checked = nx_string(key) == nx_string("1") and true or false
  form.cbtn_scale.Checked = nx_string(game_config_info.ui_scale_enable) == nx_string("1") and true or false
  form.tb_scale.Value = nx_string(game_config_info.ui_scale_value) * 0.1
  form.tb_scale.Enabled = nx_string(game_config_info.ui_scale_enable) == nx_string("1") and true or false
  form.lbl_scale_number.Text = nx_widestr(nx_decimals(nx_int(game_config_info.ui_scale_value) * 0.01, 1))
  key = util_get_property_key(game_config_info, "dialog_alpha", 0)
  form.cbtn_desalt.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "auto_small_jump", 1)
  form.cbtn_jump_auto.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "right_motionblur_info", 1)
  form.cbtn_fuzzy.Checked = nx_string(key) == nx_string("1") and true or false
  local key = util_get_property_key(game_config_info, "select_effect", 0)
  if nx_string(key) == nx_string("0") then
    form.rbtn_depict.Checked = false
    form.rbtn_hightlight.Checked = true
  else
    form.rbtn_depict.Checked = true
    form.rbtn_hightlight.Checked = false
  end
  key = util_get_property_key(game_config_info, "guide_voice", 1)
  form.cbtn_guide_voice.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "is_ride_on_path", 0)
  form.cbtn_is_ride_path.Checked = nx_string(key) == nx_string("0") and true or false
  key = util_get_property_key(game_config_info, "is_auto_ride", 0)
  form.cbtn_is_auto_ride.Checked = nx_string(key) == nx_string("0") and true or false
  key = util_get_property_key(game_config_info, "is_auto_get_hongbao_place", 1)
  form.cbtn_hongbao.Checked = nx_string(key) == nx_string("0") and true or false
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  local operate_mode = util_get_property_key(game_config_info, "operate_control_mode", 0)
  util_set_property_key(game_config_info, "show_strength_cmp_photo", nx_int(form.cbtn_power.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "is_check_equip_hardiness", nx_int(form.cbtn_check_hardiness.Checked and "1" or "0"))
  if is_change_scale(form) then
    game_config_info.ui_scale_enable = form.cbtn_scale.Checked and 1 or 0
    game_config_info.ui_scale_value = form.tb_scale.Value * 10
    nx_execute("game_config", "set_ui_scale", game_config_info.ui_scale_enable, game_config_info.ui_scale_value)
  end
  util_set_property_key(game_config_info, "dialog_alpha", nx_int(form.cbtn_desalt.Checked and "1" or "0"))
  if nx_int(operate_mode) == nx_int(1) then
    util_set_property_key(game_config_info, "auto_small_jump", nx_int(form.cbtn_jump_auto.Checked and "1" or "0"))
  end
  util_set_property_key(game_config_info, "right_motionblur_info", nx_int(form.cbtn_fuzzy.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "select_effect", nx_int(form.rbtn_depict.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "guide_voice", nx_int(form.cbtn_guide_voice.Checked and "1" or "0"))
  if not form.cbtn_guide_voice.Checked then
    local form_freshman_voice = util_get_form("form_stage_main\\form_freshman\\form_freshman_voice", false, false)
    if nx_is_valid(form_freshman_voice) then
      form_freshman_voice:Close()
    end
  end
  util_set_property_key(game_config_info, "is_ride_on_path", nx_int(form.cbtn_is_ride_path.Checked and "0" or "1"))
  util_set_property_key(game_config_info, "is_auto_ride", nx_int(form.cbtn_is_auto_ride.Checked and "0" or "1"))
  util_set_property_key(game_config_info, "is_auto_get_hongbao_place", nx_int(form.cbtn_hongbao.Checked and "0" or "1"))
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshHeadConfig()
  end
  refresh_obj_head()
  nx_execute("form_stage_main\\form_camera\\form_movie_save", "Save_movie_config", true)
end
function recover_to_default(form)
  local game_config_info = nx_value("game_config_info")
  local operate_mode = util_get_property_key(game_config_info, "operate_control_mode", 0)
  form.cbtn_power.Checked = false
  form.cbtn_scale.Checked = false
  form.tb_scale.Value = 10
  form.tb_scale.Enabled = false
  form.lbl_scale_number.Text = nx_widestr("1.0")
  form.cbtn_desalt.Checked = false
  if nx_int(operate_mode) == nx_int(1) then
    form.cbtn_jump_auto.Checked = true
  end
  form.cbtn_fuzzy.Checked = true
  form.rbtn_hightlight.Checked = true
  form.rbtn_depict.Checked = false
  form.cbtn_check_hardiness.Checked = true
  form.cbtn_guide_voice.Checked = true
  form.cbtn_is_ride_path.Checked = true
  form.cbtn_is_auto_ride.Checked = true
  form.cbtn_hongbao.Checked = false
end
function update_operate(form)
end
function refresh_obj_head()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return 0
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return 0
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    head_game:RefreshAll(visual_obj)
  end
end
function is_change_scale(form)
  local game_config_info = nx_value("game_config_info")
  local ui_scale_enable = nx_string(game_config_info.ui_scale_enable) == nx_string("1") and true or false
  if form.cbtn_scale.Checked ~= ui_scale_enable then
    return true
  end
  if nx_int(game_config_info.ui_scale_value) ~= nx_int(form.tb_scale.Value * 10) then
    return true
  end
  return false
end
