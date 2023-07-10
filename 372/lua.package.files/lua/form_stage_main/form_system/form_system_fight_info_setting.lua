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
local SystemInfo = {
  Attack_Ball = false,
  Attack_Miss = false,
  Attack_Hits = false,
  AddHP = false,
  AddMP = false,
  Other_Miss = false,
  Self_Bva = false,
  Self_Damage_HP = false,
  Other_Damage_HP = false
}
function main_form_init(form)
  form.Fixed = false
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.cbx_trackmode.DropListBox:ClearString()
  form.cbx_trackmode.DropListBox:AddString(gui.TextManager:GetText(TRACKMODE[1].text))
  form.cbx_trackmode.DropListBox:AddString(gui.TextManager:GetText(TRACKMODE[2].text))
  form.cbx_trackmode.DropListBox:AddString(gui.TextManager:GetText(TRACKMODE[3].text))
  form.cbx_trackmode.DropListBox:AddString(gui.TextManager:GetText(TRACKMODE[4].text))
  show_to_form(form)
  SystemInfo.Attack_Miss = form.cbtn_6.Checked
  SystemInfo.Attack_Hits = form.cbtn_15.Checked
  local game_config = nx_value("game_config")
  nx_execute("game_config", "backup_game_config", game_config)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  local game_config = nx_value("game_config")
  form.cbx_trackmode.DroppedDown = false
  nx_execute("game_config", "restore_game_config", game_config)
  form:Close()
end
function on_btn_Yes_click(btn)
  local form = btn.ParentForm
  local game_config = nx_value("game_config")
  local game_config_info = nx_value("game_config_info")
  save_to_file(form)
  local form_info = nx_value(FORM_MAIN_SYSINFO)
  if nx_is_valid(form_info) then
    form_info.info_group.Visible = game_config_info.right_fight_info == 1 and true or false
  end
  local SpriteManager = nx_value("SpriteManager")
  if nx_is_valid(SpriteManager) then
    SpriteManager:SetKeyword(game_config_info.keyword)
  end
  nx_execute("game_config", "set_ui_scale", game_config_info.ui_scale_enable, game_config_info.ui_scale_value)
  nx_execute("game_config", "save_game_config", game_config, "system_set.ini", "main")
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  nx_execute("form_stage_main\\form_camera\\form_movie_save", "Save_movie_config", true)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshHeadConfig()
  end
  refresh_obj_head()
  form:Close()
end
function on_close_all_target_click(btn)
  if btn.Checked then
    return
  end
  local form = btn.ParentForm
  form.cbtn_4.Checked = false
  form.cbtn_5.Checked = false
end
function on_close_all_attack_click(btn)
  if btn.Checked then
    return
  end
  local form = btn.ParentForm
  form.cbtn_6.Checked = false
  form.cbtn_7.Checked = false
  form.cbtn_8.Checked = false
  form.cbtn_9.Checked = false
  form.cbtn_10.Checked = false
  form.cbtn_11.Checked = false
  form.cbtn_12.Checked = false
  form.cbtn_13.Checked = false
  form.cbtn_14.Checked = false
  form.cbtn_15.Checked = false
  form.cbtn_19.Checked = false
end
function on_target_checked_changed(btn)
  local form = btn.ParentForm
  form.cbtn_1.Checked = btn.Checked or form.cbtn_1.Checked
end
function on_attack_checked_changed(btn)
  local form = btn.ParentForm
  form.cbtn_3.Checked = btn.Checked or form.cbtn_3.Checked
end
function on_motionblur_checked_changed(btn)
  local form = btn.ParentForm
  form.cbtn_3.Checked = btn.Checked or form.cbtn_1.Checked
end
function on_movieeffect_checked_changed(btn)
  local form = btn.ParentForm
  form.cbtn_3.Checked = btn.Checked or form.cbtn_1.Checked
end
function on_cbx_trackmode_selected(self)
  set_TrackMode_Keyword(self.DropListBox.SelectIndex)
end
function on_cbtn_strength_checked_changed(self)
end
function on_ui_scale_track_value_changed(self)
  self.Parent.ui_scale_label.Text = nx_widestr(nx_decimals(self.Value * 0.1, 1))
end
function on_dialog_alpha_checked_changed(self)
  local form = self.ParentForm
  form.cbtn_24.Checked = self.Checked or form.cbtn_24.Checked
end
function show_to_form(form)
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  local game_config_info = nx_value("game_config_info")
  form.cbtn_1.Checked = get_info_by_index(0, "Target")
  form.cbtn_2.Checked = get_info_by_index(0, "Effect")
  form.cbtn_3.Checked = get_info_by_index(0, "Attack")
  form.cbtn_4.Checked = get_info_by_index(1, "Target") and form.cbtn_1.Checked
  form.cbtn_5.Checked = get_info_by_index(2, "Target") and form.cbtn_1.Checked
  form.cbtn_6.Checked = get_info_by_index(1, "Attack") and form.cbtn_3.Checked
  form.cbtn_7.Checked = get_info_by_index(2, "Attack") and form.cbtn_3.Checked
  form.cbtn_8.Checked = get_info_by_index(3, "Attack") and form.cbtn_3.Checked
  form.cbtn_9.Checked = get_info_by_index(4, "Attack") and form.cbtn_3.Checked
  form.cbtn_10.Checked = get_info_by_index(5, "Attack") and form.cbtn_3.Checked
  form.cbtn_11.Checked = get_info_by_index(6, "Attack") and form.cbtn_3.Checked
  form.cbtn_12.Checked = get_info_by_index(7, "Attack") and form.cbtn_3.Checked
  form.cbtn_13.Checked = get_info_by_index(8, "Attack") and form.cbtn_3.Checked
  form.cbtn_14.Checked = get_info_by_index(9, "Attack") and form.cbtn_3.Checked
  form.cbtn_15.Checked = get_info_by_index(10, "Attack") and form.cbtn_3.Checked
  form.cbtn_16.Checked = game_config_info.right_fight_info == 1 and true or false
  form.cbtn_23.Checked = game_config_info.save_fight_info == 1 and true or false
  form.cbtn_20.Checked = game_config_info.right_motionblur_info == 1 and true or false
  form.cbtn_21.Checked = game_config_info.right_movieeffect_info == 1 and true or false
  form.cbtn_22.Checked = game_config_info.show_strength_cmp_photo == 1 and true or false
  form.cbtn_24.Checked = game_config_info.dialog_alpha == 1 and true or false
  local index = 1
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    for i = 1, table.getn(TRACKMODE) do
      if TRACKMODE[i].value == game_config_info.keyword then
        index = i
        break
      end
    end
  end
  form.cbx_trackmode.DropListBox.SelectIndex = index - 1
  form.cbx_trackmode.Text = gui.TextManager:GetText(TRACKMODE[index].text)
  form.ShowHeadHP_check.Checked = game_config_info.showhead_hp == 1 and true or false
  form.ShowHeadInfo_check.Checked = game_config_info.showhead_info == 1 and true or false
  form.ui_scale_check.Checked = nx_string(game_config_info.ui_scale_enable) == nx_string("1") and true or false
  form.ui_scale_track.Value = nx_int(game_config_info.ui_scale_value) * 0.1
  form.ui_scale_label.Text = nx_widestr(nx_decimals(nx_int(game_config_info.ui_scale_value) * 0.01, 1))
end
function save_to_file(form)
  local game_config = nx_value("game_config")
  local game_config_info = nx_value("game_config_info")
  game_config_info.attack_info = nx_string(get_attack_info(form))
  game_config_info.attack_self = nx_int(form.cbtn_3.Checked and "1" or "0")
  game_config_info.target_info = nx_string(get_target_info(form))
  game_config_info.target_self = nx_int(form.cbtn_1.Checked and "1" or "0")
  game_config_info.effect_info = ""
  game_config_info.effect_self = nx_int(form.cbtn_2.Checked and "1" or "0")
  game_config_info.keyword = TRACKMODE[form.cbx_trackmode.DropListBox.SelectIndex + 1].value
  game_config_info.trackmode = nx_int(form.cbtn_2.Checked and "1" or "0")
  game_config_info.right_fight_info = nx_int(form.cbtn_16.Checked and "1" or "0")
  game_config_info.save_fight_info = nx_int(form.cbtn_23.Checked and "1" or "0")
  game_config_info.showhead_hp = nx_int(form.ShowHeadHP_check.Checked and "1" or "0")
  game_config_info.showhead_info = nx_int(form.ShowHeadInfo_check.Checked and "1" or "0")
  game_config_info.ui_scale_enable = nx_int(form.ui_scale_check.Checked and "1" or "0")
  game_config_info.ui_scale_value = nx_int(form.ui_scale_track.Value * 10)
  game_config_info.right_motionblur_info = nx_int(form.cbtn_20.Checked and "1" or "0")
  game_config_info.right_movieeffect_info = nx_int(form.cbtn_21.Checked and "1" or "0")
  game_config_info.show_strength_cmp_photo = nx_int(form.cbtn_22.Checked and "1" or "0")
  game_config_info.dialog_alpha = nx_int(form.cbtn_24.Checked and "1" or "0")
end
function get_attack_info(form)
  local text = form.cbtn_6.Checked and form.cbtn_3.Checked and "1" or "0"
  local Value = form.cbtn_7.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  Value = form.cbtn_8.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  Value = form.cbtn_9.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  Value = form.cbtn_10.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  Value = form.cbtn_11.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  Value = form.cbtn_12.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  Value = form.cbtn_13.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  Value = form.cbtn_14.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  Value = form.cbtn_15.Checked and form.cbtn_3.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  return text
end
function get_target_info(form)
  local text = form.cbtn_4.Checked and form.cbtn_1.Checked and "1" or "0"
  local Value = form.cbtn_5.Checked and form.cbtn_1.Checked and "1" or "0"
  text = nx_string(text .. "," .. Value)
  return text
end
function get_info_by_index(index, strtype)
  local info_list = {}
  if "Attack" == nx_string(strtype) then
    info_list = get_attack_info_list()
  elseif "Target" == nx_string(strtype) then
    info_list = get_target_info_list()
  elseif "Effect" == nx_string(strtype) then
    info_list = get_effect_info_list()
  end
  if info_list == nil or info_list == "" then
    return ""
  end
  local info = info_list[index + 1] == "1" and true or false
  return info
end
function get_attack_info_list()
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return nil
  end
  local info = game_config_info.attack_info
  local tuple = util_split_string(info, ",")
  info = game_config_info.attack_self
  table.insert(tuple, 1, info)
  return tuple
end
function get_target_info_list()
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return nil
  end
  local info = game_config_info.target_info
  local tuple = util_split_string(info, ",")
  info = game_config_info.target_self
  table.insert(tuple, 1, info)
  return tuple
end
function get_effect_info_list()
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return nil
  end
  local info = game_config_info.effect_info
  local tuple = util_split_string(info, ",")
  info = game_config_info.effect_self
  table.insert(tuple, 1, info)
  return tuple
end
function get_info_is_visible(index)
  return SystemInfo[index]
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
