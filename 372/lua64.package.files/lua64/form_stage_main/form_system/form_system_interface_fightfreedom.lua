require("util_functions")
local CLIENT_SET_PARRY = 2
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_ui_content(form)
end
function on_main_form_close(form)
  update_operate(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_apply_click(btn)
  local form = btn.ParentForm
  save_to_file(form)
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_default_click(btn)
  local form = btn.ParentForm
  recover_to_default(form)
end
function on_cbtn_movieword_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_movie.Enabled = cbtn.Checked
  form.cbtn_word.Enabled = cbtn.Checked
  form.cbtn_movie.Checked = cbtn.Checked
  form.cbtn_word.Checked = cbtn.Checked
end
function on_cbtn_shotweapon_get_capture(cbtn)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = nx_widestr(gui.TextManager:GetText("ui_hw_auto_2"))
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
end
function on_cbtn_shotweapon_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_tbar_keepdelay_value_changed(tbar)
  local form = tbar.ParentForm
  form.pbar_keepdelay.Value = tbar.Value
end
function on_tbar_keepdelay_get_capture(tbar)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = nx_widestr(gui.TextManager:GetText("ui_system_fight_delay_tip"))
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
end
function on_tbar_keepdelay_lost_capture(tbar)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_keepdelay_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.tbar_keepdelay.Enabled = cbtn.Checked
end
function init_ui_content(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local game_config_info = nx_value("game_config_info")
  local mode = util_get_property_key(game_config_info, "operate_control_mode", 0)
  if nx_int(mode) == nx_int(0) then
    form.groupbox_3d.Visible = false
    form.groupbox_all.Top = form.groupbox_3d.Top
  else
    form.groupbox_3d.Visible = true
    form.groupbox_all.Top = form.groupbox_3d.Top + form.groupbox_3d.Height
  end
  local key = util_get_property_key(game_config_info, "autopath_clicktarget", 0)
  form.cbtn_autopath_click.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "autopath_useskill", 0)
  form.cbtn_useskill.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "priority_skill_effect", 1)
  form.cbtn_prorityskill.Checked = nx_string(key) == nx_string("1") and true or false
  if nx_is_valid(client_player) then
    local parry_type = client_player:QueryProp("ParryType")
    if nx_int(parry_type) == nx_int(0) then
      form.rbtn_manualparry.Checked = true
      form.rbtn_autoparry.Checked = false
    elseif nx_int(parry_type) == nx_int(2) then
      form.rbtn_manualparry.Checked = false
      form.rbtn_autoparry.Checked = true
    end
  end
  key = util_get_property_key(game_config_info, "autoselect_target", 1)
  form.cbtn_autoseltarget.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "movie_animation_effect", 1)
  form.cbtn_movieword.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "open_movie_scene_start", 1)
  form.cbtn_movie.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "open_animation_img", 1)
  form.cbtn_word.Checked = nx_string(key) == nx_string("1") and true or false
  form.cbtn_movie.Enabled = form.cbtn_movieword.Checked
  form.cbtn_word.Enabled = form.cbtn_movieword.Checked
  key = util_get_property_key(game_config_info, "auto_equip_shotweapon", 0)
  form.cbtn_shotweapon.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "start_keep_delay", 1)
  form.cbtn_keepdelay.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "keep_delay_sec", 100)
  form.tbar_keepdelay.Enabled = form.cbtn_keepdelay.Checked
  form.tbar_keepdelay.Value = nx_int(key)
  form.pbar_keepdelay.Value = nx_int(key)
  key = util_get_property_key(game_config_info, "speedattack", 0)
  form.cbtn_speedattack.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fightparry", 0)
  form.cbtn_fightparry.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_range_buff_effect", 1)
  form.cbtn_range_effect.Checked = nx_string(key) == nx_string("1") and true or false
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  if nx_int(game_config_info.operate_control_mode) == nx_int(1) then
    util_set_property_key(game_config_info, "autopath_clicktarget", nx_int(form.cbtn_autopath_click.Checked and "1" or "0"))
    util_set_property_key(game_config_info, "autopath_useskill", nx_int(form.cbtn_useskill.Checked and "1" or "0"))
  end
  util_set_property_key(game_config_info, "priority_skill_effect", nx_int(form.cbtn_prorityskill.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "autoselect_target", nx_int(form.cbtn_autoseltarget.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "movie_animation_effect", nx_int(form.cbtn_movieword.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "open_movie_scene_start", nx_int(form.cbtn_movie.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "open_animation_img", nx_int(form.cbtn_word.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "auto_equip_shotweapon", nx_int(form.cbtn_shotweapon.Checked and "1" or "0"))
  nx_execute("custom_sender", "custom_auto_equip_shotweapon", form.cbtn_shotweapon.Checked and nx_int(1) or nx_int(0))
  util_set_property_key(game_config_info, "start_keep_delay", nx_int(form.cbtn_keepdelay.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "keep_delay_sec", nx_int(form.tbar_keepdelay.Value))
  if form.cbtn_keepdelay.Checked then
    local fight = nx_value("fight")
    if nx_is_valid(fight) then
      fight.KeepDelaySec = form.tbar_keepdelay.Value * 4
    end
  end
  util_set_property_key(game_config_info, "speedattack", nx_int(form.cbtn_speedattack.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fightparry", nx_int(form.cbtn_fightparry.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_range_buff_effect", nx_int(form.cbtn_range_effect.Checked and "1" or "0"))
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  nx_execute("form_stage_main\\form_system\\form_system_interface_setting", "save_config_to_server")
  local parry_type = 0
  if form.rbtn_manualparry.Checked then
    parry_type = 0
  else
    parry_type = 2
  end
  nx_execute("custom_sender", "custom_active_parry", nx_int(CLIENT_SET_PARRY), nx_int(parry_type))
end
function recover_to_default(form)
  form.cbtn_autopath_click.Checked = false
  form.cbtn_useskill.Checked = false
  form.cbtn_autoseltarget.Checked = true
  form.rbtn_autoparry.Checked = false
  form.rbtn_manualparry.Checked = true
  form.cbtn_movieword.Checked = true
  form.cbtn_movie.Checked = true
  form.cbtn_word.Checked = true
  form.cbtn_shotweapon.Checked = false
  form.cbtn_prorityskill.Checked = true
  form.cbtn_keepdelay.Checked = true
  form.tbar_keepdelay.Value = 100
  form.cbtn_speedattack.Checked = false
  form.cbtn_fightparry.Checked = false
  form.cbtn_range_effect.Checked = true
end
function update_operate(form)
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
function on_cbtn_shotweapon_checked_changed(cbtn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
