require("util_functions")
local POSITION = {
  [1] = {
    text = "tips_obj_position_mouse",
    value = "mouse"
  },
  [2] = {
    text = "tips_obj_position_fixed",
    value = "fixed"
  }
}
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
  form.combo_tipposition.DroppedDown = false
  form:Close()
end
function on_btn_apply_click(form)
  save_to_file(form)
end
function on_btn_default_click(form)
  recover_to_default(form)
end
function on_switchto_3dmode(form)
  form.rbtn_lbtn_move.Checked = false
  form.rbtn_lbtn_view.Checked = true
  form.rbtn_rbtn_dir.Checked = true
  form.rbtn_rbtn_view.Checked = false
end
function on_switchto_25dmode(form)
  form.rbtn_lbtn_move.Checked = true
  form.rbtn_lbtn_view.Checked = false
  form.rbtn_rbtn_dir.Checked = true
  form.rbtn_rbtn_view.Checked = false
end
function on_cbtn_tipguildname_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_tipguildtitle.Enabled = cbtn.Checked
end
function on_tbar_flexible_value_changed(tbar)
  local form = tbar.ParentForm
  form.pbar_flexible.Value = tbar.Value
end
function init_ui_content(form)
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  local lm_mode_set = game_config_info.lmouse_normal_mode
  if nx_int(lm_mode_set) == nx_int(0) then
    form.rbtn_lbtn_move.Checked = true
    form.rbtn_lbtn_view.Checked = false
  elseif nx_int(lm_mode_set) == nx_int(1) then
    form.rbtn_lbtn_move.Checked = false
    form.rbtn_lbtn_view.Checked = true
  else
    form.rbtn_lbtn_move.Checked = false
    form.rbtn_lbtn_view.Checked = true
  end
  local rm_mode_set = game_config_info.mr_rotate_mode
  if nx_int(rm_mode_set) == nx_int(0) then
    form.rbtn_rbtn_dir.Checked = true
    form.rbtn_rbtn_view.Checked = false
  elseif nx_int(rm_mode_set) == nx_int(1) then
    form.rbtn_rbtn_dir.Checked = false
    form.rbtn_rbtn_view.Checked = true
  else
    form.rbtn_rbtn_dir.Checked = true
    form.rbtn_rbtn_view.Checked = false
  end
  form.combo_tipposition.DropListBox:ClearString()
  form.combo_tipposition.DropListBox:AddString(gui.TextManager:GetText(POSITION[1].text))
  form.combo_tipposition.DropListBox:AddString(gui.TextManager:GetText(POSITION[2].text))
  local key = util_get_property_key(game_config_info, "show_tips_position", 0)
  form.combo_tipposition.DropListBox.SelectIndex = nx_int(key)
  form.combo_tipposition.Text = gui.TextManager:GetText(POSITION[nx_int(key) + 1].text)
  key = util_get_property_key(game_config_info, "show_tips_name", 1)
  form.cbtn_tipname.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_tips_school", 1)
  form.cbtn_tipschool.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_tips_guildname", 1)
  form.cbtn_tipguildname.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_tips_guildtitle", 1)
  form.cbtn_tipguildtitle.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_tips_origin", 1)
  form.cbtn_tiporigin.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_tips_strength", 1)
  form.cbtn_tipstrength.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_tips_target", 1)
  form.cbtn_tiptarget.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_tips_force", 1)
  form.cbtn_tipforce.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_tips_distance", 1)
  form.cbtn_tipdistance.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "pick_position", 1)
  form.rbtn_pickfixed.Checked = nx_string(key) == nx_string("1") and true or false
  form.rbtn_pickmouse.Checked = not form.rbtn_pickfixed.Checked
  key = util_get_property_key(game_config_info, "pick_autopick", 1)
  form.cbtn_autopick.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "mouse_response_rate", 15)
  form.tbar_flexible.Value = nx_int(key)
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if form.rbtn_lbtn_move.Checked == true then
    game_config_info.lmouse_normal_mode = 0
    game_control.MLKeySlideCamera = false
  else
    game_config_info.lmouse_normal_mode = 1
    game_control.MLKeySlideCamera = true
  end
  if form.rbtn_rbtn_dir.Checked == true then
    game_config_info.mr_rotate_mode = 0
    game_control.MRKeySlideCamera = true
  else
    game_config_info.mr_rotate_mode = 1
    game_control.MRKeySlideCamera = true
  end
  util_set_property_key(game_config_info, "show_tips_position", nx_int(form.combo_tipposition.DropListBox.SelectIndex))
  util_set_property_key(game_config_info, "show_tips_name", nx_int(form.cbtn_tipname.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_tips_school", nx_int(form.cbtn_tipschool.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_tips_strength", nx_int(form.cbtn_tipstrength.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_tips_guildname", nx_int(form.cbtn_tipguildname.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_tips_guildtitle", nx_int(form.cbtn_tipguildtitle.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_tips_target", nx_int(form.cbtn_tiptarget.Checked and "1" or "0"))
  util_get_property_key(game_config_info, "show_tips_force", nx_int(form.cbtn_tipforce.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_tips_origin", nx_int(form.cbtn_tiporigin.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_tips_distance", nx_int(form.cbtn_tipdistance.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "pick_position", nx_int(form.rbtn_pickfixed.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "pick_autopick", nx_int(form.cbtn_autopick.Checked and "1" or "0"))
  local rate = form.tbar_flexible.Value
  util_set_property_key(game_config_info, "mouse_response_rate", nx_int(rate))
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.MouseResponseRate = nx_float(rate / 10)
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
end
function recover_to_default(form)
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  local operate_control_mode = game_config_info.operate_control_mode
  if nx_int(operate_control_mode) == nx_int(0) then
    form.rbtn_lbtn_move.Checked = false
    form.rbtn_lbtn_view.Checked = true
    form.rbtn_rbtn_dir.Checked = true
    form.rbtn_rbtn_view.Checked = false
  elseif nx_int(operate_control_mode) == nx_int(1) then
    form.rbtn_lbtn_move.Checked = true
    form.rbtn_lbtn_view.Checked = false
    form.rbtn_rbtn_dir.Checked = true
    form.rbtn_rbtn_view.Checked = false
  else
    form.rbtn_lbtn_move.Checked = false
    form.rbtn_lbtn_view.Checked = true
    form.rbtn_rbtn_dir.Checked = true
    form.rbtn_rbtn_view.Checked = false
  end
  form.combo_tipposition.DropListBox.SelectIndex = 0
  form.combo_tipposition.Text = gui.TextManager:GetText(POSITION[1].text)
  form.cbtn_tipname.Checked = true
  form.cbtn_tipschool.Checked = true
  form.cbtn_tipguildname.Checked = true
  form.cbtn_tipguildtitle.Checked = true
  form.cbtn_tiporigin.Checked = true
  form.cbtn_tipstrength.Checked = true
  form.cbtn_tiptarget.Checked = true
  form.cbtn_tipforce.Checked = true
  form.cbtn_tipdistance.Checked = true
  form.rbtn_pickfixed.Checked = true
  form.rbtn_pickmouse.Checked = false
  form.cbtn_autopick.Checked = true
  form.tbar_flexible.Value = 15
end
function update_operate(form)
end
