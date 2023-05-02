require("utils")
require("util_gui")
require("util_functions")
require("SuspendManager")
require("share\\view_define")
local FORM_MAIN_SYSINFO = "form_stage_main\\form_main\\form_main_sysinfo"
local TRACKMODE = {
  [1] = {
    text = "ui_system_Fight_info_Type1",
    value = "normal"
  },
  [2] = {
    text = "ui_system_Fight_info_Type2",
    value = "up"
  },
  [3] = {
    text = "ui_system_Fight_info_Type3",
    value = "down"
  },
  [4] = {
    text = "ui_system_Fight_info_Type4",
    value = "arc"
  }
}
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  init_ui_content(form)
end
function on_main_form_close(form)
  local form_freedom = nx_value("form_stage_main\\form_system\\form_system_interface_fightfreedom")
  if nx_is_valid(form_freedom) then
    form_freedom:Close()
  end
  update_operate(form)
  nx_destroy(form)
end
function on_btn_ok_click(form)
  save_to_file(form)
end
function on_btn_cancel_click(form)
  form.cbx_trackmode.DroppedDown = false
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
function on_cbtn_open_attackinfo_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_target_info.Enabled = cbtn.Checked
  form.cbtn_target_info.Checked = cbtn.Checked
  form.cbtn_target_damage.Enabled = cbtn.Checked
  form.cbtn_target_damage.Checked = cbtn.Checked
  form.cbtn_target_effect.Enabled = cbtn.Checked
  form.cbtn_target_effect.Checked = cbtn.Checked
  form.cbtn_target_stisle.Enabled = cbtn.Checked
  form.cbtn_target_stisle.Checked = cbtn.Checked
  form.cbtn_self_info.Enabled = cbtn.Checked
  form.cbtn_self_info.Checked = cbtn.Checked
  form.cbtn_self_damage.Enabled = cbtn.Checked
  form.cbtn_self_damage.Checked = cbtn.Checked
  form.cbtn_self_effect.Enabled = cbtn.Checked
  form.cbtn_self_effect.Checked = cbtn.Checked
  form.cbtn_self_stisle.Enabled = cbtn.Checked
  form.cbtn_self_stisle.Checked = cbtn.Checked
  form.cbtn_self_recover.Enabled = cbtn.Checked
  form.cbtn_self_recover.Checked = cbtn.Checked
  form.cbtn_self_hits.Enabled = cbtn.Checked
  form.cbtn_self_hits.Checked = cbtn.Checked
  form.cbtn_self_inout.Enabled = cbtn.Checked
  form.cbtn_self_inout.Checked = cbtn.Checked
end
function on_cbtn_target_info_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_target_damage.Enabled = cbtn.Checked
  form.cbtn_target_damage.Checked = cbtn.Checked
  form.cbtn_target_effect.Enabled = cbtn.Checked
  form.cbtn_target_effect.Checked = cbtn.Checked
  form.cbtn_target_stisle.Enabled = cbtn.Checked
  form.cbtn_target_stisle.Checked = cbtn.Checked
end
function on_cbtn_self_info_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_self_damage.Enabled = cbtn.Checked
  form.cbtn_self_damage.Checked = cbtn.Checked
  form.cbtn_self_effect.Enabled = cbtn.Checked
  form.cbtn_self_effect.Checked = cbtn.Checked
  form.cbtn_self_recover.Enabled = cbtn.Checked
  form.cbtn_self_recover.Checked = cbtn.Checked
  form.cbtn_self_stisle.Enabled = cbtn.Checked
  form.cbtn_self_stisle.Checked = cbtn.Checked
  form.cbtn_self_inout.Enabled = cbtn.Checked
  form.cbtn_self_inout.Checked = cbtn.Checked
  form.cbtn_self_hits.Enabled = cbtn.Checked
  form.cbtn_self_hits.Checked = cbtn.Checked
end
function on_btn_advance_click(btn)
  local form_freedom = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_system\\form_system_interface_fightfreedom", true, false)
  if nx_is_valid(form_freedom) then
    form_freedom:ShowModal()
  end
end
function on_cbx_trackmode_selected(cbx)
end
function init_ui_content(form)
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  local key = util_get_property_key(game_config_info, "fight_open_info", 1)
  form.cbtn_open_attackinfo.Checked = nx_string(key) == nx_string("1") and true or false
  set_selfctrl_enable(form, nx_string(key) == nx_string("1"))
  set_targetctrl_enable(form, nx_string(key) == nx_string("1"))
  key = util_get_property_key(game_config_info, "fight_self_info", 1)
  form.cbtn_self_info.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_self_damage", 1)
  form.cbtn_self_damage.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_self_effect", 1)
  form.cbtn_self_effect.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_self_recover", 1)
  form.cbtn_self_recover.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_self_stisle", 1)
  form.cbtn_self_stisle.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_self_hits", 1)
  form.cbtn_self_hits.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_self_inout", 1)
  form.cbtn_self_inout.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_target_info", 1)
  form.cbtn_target_info.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_target_damage", 1)
  form.cbtn_target_damage.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_target_effect", 1)
  form.cbtn_target_effect.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "fight_target_stisle", 1)
  form.cbtn_target_stisle.Checked = nx_string(key) == nx_string("1") and true or false
  form.cbx_trackmode.DropListBox:ClearString()
  form.cbx_trackmode.DropListBox:AddString(gui.TextManager:GetText(TRACKMODE[1].text))
  form.cbx_trackmode.DropListBox:AddString(gui.TextManager:GetText(TRACKMODE[2].text))
  form.cbx_trackmode.DropListBox:AddString(gui.TextManager:GetText(TRACKMODE[3].text))
  form.cbx_trackmode.DropListBox:AddString(gui.TextManager:GetText(TRACKMODE[4].text))
  local index = nx_number(util_get_property_key(game_config_info, "fight_flutter_mode", 1))
  if nx_int(index) <= nx_int(0) then
    index = 1
  end
  form.cbx_trackmode.DropListBox.SelectIndex = index - 1
  form.cbx_trackmode.Text = gui.TextManager:GetText(TRACKMODE[nx_number(index)].text)
  key = util_get_property_key(game_config_info, "right_fight_info", 1)
  form.cbtn_rightfight.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "save_fight_info", 1)
  form.cbtn_savefightlog.Checked = nx_string(key) == nx_string("1") and true or false
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  util_set_property_key(game_config_info, "fight_open_info", nx_int(form.cbtn_open_attackinfo.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_self_info", nx_int(form.cbtn_self_info.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_self_damage", nx_int(form.cbtn_self_damage.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_self_effect", nx_int(form.cbtn_self_effect.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_self_recover", nx_int(form.cbtn_self_recover.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_self_stisle", nx_int(form.cbtn_self_stisle.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_self_hits", nx_int(form.cbtn_self_hits.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_self_inout", nx_int(form.cbtn_self_inout.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_target_info", nx_int(form.cbtn_target_info.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_target_damage", nx_int(form.cbtn_target_damage.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_target_effect", nx_int(form.cbtn_target_effect.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_target_stisle", nx_int(form.cbtn_target_stisle.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "fight_flutter_mode", nx_int(form.cbx_trackmode.DropListBox.SelectIndex + 1))
  local SpriteManager = nx_value("SpriteManager")
  if nx_is_valid(SpriteManager) then
    local index = form.cbx_trackmode.DropListBox.SelectIndex + 1
    SpriteManager:SetKeyword(TRACKMODE[nx_number(index)].value)
  end
  util_set_property_key(game_config_info, "right_fight_info", nx_int(form.cbtn_rightfight.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "save_fight_info", nx_int(form.cbtn_savefightlog.Checked and "1" or "0"))
  local form_info = nx_value(FORM_MAIN_SYSINFO)
  if nx_is_valid(form_info) then
    key = util_get_property_key(game_config_info, "right_fight_info", 1)
    form_info.info_group.Visible = nx_string(key) == nx_string("1") and true or false
  end
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
end
function recover_to_default(form)
  local gui = nx_value("gui")
  form.cbtn_open_attackinfo.Checked = true
  form.cbtn_self_info.Checked = true
  form.cbtn_self_damage.Checked = true
  form.cbtn_self_effect.Checked = true
  form.cbtn_self_recover.Checked = true
  form.cbtn_self_stisle.Checked = true
  form.cbtn_self_hits.Checked = true
  form.cbtn_self_inout.Checked = true
  form.cbtn_target_info.Checked = true
  form.cbtn_target_damage.Checked = true
  form.cbtn_target_effect.Checked = true
  form.cbtn_target_stisle.Checked = true
  form.cbx_trackmode.DropListBox.SelectIndex = 0
  form.cbx_trackmode.Text = gui.TextManager:GetText(TRACKMODE[1].text)
  form.cbtn_rightfight.Checked = true
  form.cbtn_savefightlog.Checked = true
end
function update_operate(form)
end
function set_selfctrl_enable(form, value)
  form.cbtn_self_info.Enabled = value
  form.cbtn_self_damage.Enabled = form.cbtn_self_info.Enabled and form.cbtn_self_info.Checked
  form.cbtn_self_effect.Enabled = form.cbtn_self_info.Enabled and form.cbtn_self_info.Checked
  form.cbtn_self_recover.Enabled = form.cbtn_self_info.Enabled and form.cbtn_self_info.Checked
  form.cbtn_self_stisle.Enabled = form.cbtn_self_info.Enabled and form.cbtn_self_info.Checked
  form.cbtn_self_inout.Enabled = form.cbtn_self_info.Enabled and form.cbtn_self_info.Checked
  form.cbtn_self_hits.Enabled = form.cbtn_self_info.Enabled and form.cbtn_self_info.Checked
end
function set_targetctrl_enable(form, value)
  form.cbtn_target_info.Enabled = value
  form.cbtn_target_damage.Enabled = form.cbtn_target_info.Enabled and form.cbtn_target_info.Checked
  form.cbtn_target_effect.Enabled = form.cbtn_target_info.Enabled and form.cbtn_target_info.Checked
  form.cbtn_target_stisle.Enabled = form.cbtn_target_info.Enabled and form.cbtn_target_info.Checked
end
