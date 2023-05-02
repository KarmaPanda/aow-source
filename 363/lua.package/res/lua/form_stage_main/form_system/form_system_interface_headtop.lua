require("util_functions")
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
function on_cbtn_headinfo_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_myname.Enabled = cbtn.Checked
  form.cbtn_myname.Checked = cbtn.Checked
  form.cbtn_myorgind.Enabled = cbtn.Checked
  form.cbtn_myorgind.Checked = cbtn.Checked
  form.cbtn_myguild.Enabled = cbtn.Checked
  form.cbtn_myguild.Checked = cbtn.Checked
  form.cbtn_myguildid.Enabled = cbtn.Checked
  form.cbtn_myguildid.Checked = cbtn.Checked
  form.cbtn_friendname.Enabled = cbtn.Checked
  form.cbtn_friendname.Checked = cbtn.Checked
  form.cbtn_friendorgind.Enabled = cbtn.Checked
  form.cbtn_friendorgind.Checked = cbtn.Checked
  form.cbtn_friendguild.Enabled = cbtn.Checked
  form.cbtn_friendguild.Checked = cbtn.Checked
  form.cbtn_friendguildid.Enabled = cbtn.Checked
  form.cbtn_friendguildid.Checked = cbtn.Checked
  form.cbtn_enemyname.Enabled = cbtn.Checked
  form.cbtn_enemyname.Checked = cbtn.Checked
  form.cbtn_enemyorgind.Enabled = cbtn.Checked
  form.cbtn_enemyorgind.Checked = cbtn.Checked
  form.cbtn_enemyguild.Enabled = cbtn.Checked
  form.cbtn_enemyguild.Checked = cbtn.Checked
  form.cbtn_enemyguildid.Enabled = cbtn.Checked
  form.cbtn_enemyguildid.Checked = cbtn.Checked
  form.cbtn_npcname.Enabled = cbtn.Checked
  form.cbtn_npcname.Checked = cbtn.Checked
  form.cbtn_npcorgind.Enabled = cbtn.Checked
  form.cbtn_npcorgind.Checked = cbtn.Checked
  form.cbtn_npccorpsename.Enabled = cbtn.Checked
  form.cbtn_npccorpsename.Checked = cbtn.Checked
  form.cbtn_partnername.Enabled = cbtn.Checked
  form.cbtn_partnername.Checked = cbtn.Checked
end
function on_cbtn_myname_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_myorgind.Enabled = cbtn.Checked
  form.cbtn_myorgind.Checked = cbtn.Checked
end
function on_cbtn_myguild_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_myguildid.Enabled = cbtn.Checked
  form.cbtn_myguildid.Checked = cbtn.Checked
end
function on_cbtn_friendname_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_friendorgind.Enabled = cbtn.Checked
  form.cbtn_friendorgind.Checked = cbtn.Checked
end
function on_cbtn_friendguild_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_friendguildid.Enabled = cbtn.Checked
  form.cbtn_friendguildid.Checked = cbtn.Checked
end
function on_cbtn_enemyname_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_enemyorgind.Enabled = cbtn.Checked
  form.cbtn_enemyorgind.Checked = cbtn.Checked
end
function on_cbtn_enemyguild_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_enemyguildid.Enabled = cbtn.Checked
  form.cbtn_enemyguildid.Checked = cbtn.Checked
end
function on_cbtn_npcname_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_npcorgind.Enabled = cbtn.Checked
  form.cbtn_npcorgind.Checked = cbtn.Checked
  form.cbtn_npccorpsename.Enabled = cbtn.Checked
  form.cbtn_npccorpsename.Enabled = cbtn.Checked
end
function on_cbtn_headblod_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_playerblood.Enabled = cbtn.Checked
  form.cbtn_playerblood.Checked = cbtn.Checked
  form.cbtn_myblood.Enabled = cbtn.Checked
  form.cbtn_myblood.Checked = cbtn.Checked
  form.cbtn_friendblood.Enabled = cbtn.Checked
  form.cbtn_friendblood.Checked = cbtn.Checked
  form.cbtn_enemyblood.Enabled = cbtn.Checked
  form.cbtn_enemyblood.Checked = cbtn.Checked
  form.cbtn_npcblood.Enabled = cbtn.Checked
  form.cbtn_npcblood.Checked = cbtn.Checked
  form.cbtn_friendnpc.Enabled = cbtn.Checked
  form.cbtn_friendnpc.Checked = cbtn.Checked
  form.cbtn_enemynpc.Enabled = cbtn.Checked
  form.cbtn_enemynpc.Checked = cbtn.Checked
end
function on_cbtn_playerblood_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_myblood.Enabled = cbtn.Checked
  form.cbtn_myblood.Checked = cbtn.Checked
  form.cbtn_friendblood.Enabled = cbtn.Checked
  form.cbtn_friendblood.Checked = cbtn.Checked
  form.cbtn_enemyblood.Enabled = cbtn.Checked
  form.cbtn_enemyblood.Checked = cbtn.Checked
end
function on_cbtn_npcblood_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.cbtn_friendnpc.Enabled = cbtn.Checked
  form.cbtn_friendnpc.Checked = cbtn.Checked
  form.cbtn_enemynpc.Enabled = cbtn.Checked
  form.cbtn_enemynpc.Checked = cbtn.Checked
end
function on_cbtn_kungfu_checked_changed(cbtn)
  local form = cbtn.ParentForm
  set_headkfctrl_enable(form, cbtn.Checked)
end
function on_cbtn_3_checked_changed(cbtn)
  local form = cbtn.ParentForm
  set_headkfctrl_enable_for_adv_qg(form, cbtn.Checked)
end
function on_tbar_range_value_changed(tbar)
  local form = tbar.ParentForm
  form.pbar_range.Value = tbar.Value
end
function init_ui_content(form)
  local game_config_info = nx_value("game_config_info")
  local key = util_get_property_key(game_config_info, "auto_showheadinfo", 0)
  form.cbtn_aishow.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showhead_info", 1)
  form.cbtn_headinfo.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showself_name", 1)
  form.cbtn_myname.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showself_titleid", 1)
  form.cbtn_myorgind.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showself_guild", 1)
  form.cbtn_myguild.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showself_guildid", 1)
  form.cbtn_myguildid.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showfriends_name", 1)
  form.cbtn_friendname.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showfriends_titleid", 1)
  form.cbtn_friendorgind.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showfriends_guild", 1)
  form.cbtn_friendguild.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showfriends_guildid", 1)
  form.cbtn_friendguildid.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showenemy_name", 1)
  form.cbtn_enemyname.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showenemy_titleid", 1)
  form.cbtn_enemyorgind.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showenemy_guild", 1)
  form.cbtn_enemyguild.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showenemy_guildid", 1)
  form.cbtn_enemyguildid.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "shownpc_name", 1)
  form.cbtn_npcname.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "shownpc_idname", 1)
  form.cbtn_npcorgind.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "shownpc_corpsename", 1)
  form.cbtn_npccorpsename.Checked = nx_string(key) == nx_string("1") and true or false
  set_headinfoctrl_enable(form, form.cbtn_headinfo.Checked)
  key = util_get_property_key(game_config_info, "partner_name", 1)
  form.cbtn_partnername.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showhead_hp", 1)
  form.cbtn_headblod.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showplayer_hp", 1)
  form.cbtn_playerblood.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showself_hp", 0)
  form.cbtn_myblood.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showfriends_hp", 0)
  form.cbtn_friendblood.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showenemy_hp", 1)
  form.cbtn_enemyblood.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "shownpc_hp", 1)
  form.cbtn_npcblood.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showfriendnpc_hp", 0)
  form.cbtn_friendnpc.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showenemynpc_hp", 1)
  form.cbtn_enemynpc.Checked = nx_string(key) == nx_string("1") and true or false
  set_headbloodctrl_enable(form, form.cbtn_headblod.Checked)
  key = util_get_property_key(game_config_info, "showself_qg", 1)
  form.cbtn_kungfu.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "showqg_always", 1)
  if nx_string(key) == nx_string("1") then
    form.rbtn_kfall.Checked = true
    form.rbtn_kfuse.Checked = false
  else
    form.rbtn_kfall.Checked = false
    form.rbtn_kfuse.Checked = true
  end
  set_headkfctrl_enable(form, form.cbtn_kungfu.Checked)
  key = util_get_property_key(game_config_info, "show_adv_self_qg", 1)
  form.cbtn_3.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_adv_qg_always", 1)
  if nx_string(key) == nx_string("1") then
    form.rbtn_5.Checked = true
    form.rbtn_6.Checked = false
  else
    form.rbtn_5.Checked = false
    form.rbtn_6.Checked = true
  end
  set_headkfctrl_enable_for_adv_qg(form, form.cbtn_3.Checked)
  key = util_get_property_key(game_config_info, "head_zoom_value", 1)
  form.tbar_range.Value = nx_int(key)
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  util_set_property_key(game_config_info, "auto_showheadinfo", nx_int(form.cbtn_aishow.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showhead_info", nx_int(form.cbtn_headinfo.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showself_name", nx_int(form.cbtn_myname.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showself_titleid", nx_int(form.cbtn_myorgind.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showself_guild", nx_int(form.cbtn_myguild.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showself_guildid", nx_int(form.cbtn_myguildid.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showfriends_name", nx_int(form.cbtn_friendname.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showfriends_titleid", nx_int(form.cbtn_friendorgind.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showfriends_guild", nx_int(form.cbtn_friendguild.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showfriends_guildid", nx_int(form.cbtn_friendguildid.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showenemy_name", nx_int(form.cbtn_enemyname.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showenemy_titleid", nx_int(form.cbtn_enemyorgind.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showenemy_guild", nx_int(form.cbtn_enemyguild.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showenemy_guildid", nx_int(form.cbtn_enemyguildid.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "shownpc_name", nx_int(form.cbtn_npcname.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "shownpc_idname", nx_int(form.cbtn_npcorgind.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "shownpc_corpsename", nx_int(form.cbtn_npccorpsename.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "partner_name", nx_int(form.cbtn_partnername.Checked and "1" or "0"))
  nx_execute("form_stage_main\\form_marry\\form_marry_util", "request_set_show_partner_name", nx_int(form.cbtn_partnername.Checked))
  util_set_property_key(game_config_info, "showhead_hp", nx_int(form.cbtn_headblod.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showplayer_hp", nx_int(form.cbtn_playerblood.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showself_hp", nx_int(form.cbtn_myblood.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showfriends_hp", nx_int(form.cbtn_friendblood.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showenemy_hp", nx_int(form.cbtn_enemyblood.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "shownpc_hp", nx_int(form.cbtn_npcblood.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showfriendnpc_hp", nx_int(form.cbtn_friendnpc.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showenemynpc_hp", nx_int(form.cbtn_enemynpc.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showself_qg", nx_int(form.cbtn_kungfu.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "showqg_always", nx_int(form.rbtn_kfall.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_adv_self_qg", nx_int(form.cbtn_3.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_adv_qg_always", nx_int(form.rbtn_5.Checked and "1" or "0"))
  local key = util_get_property_key(game_config_info, "show_adv_qg_always", 1)
  util_set_property_key(game_config_info, "head_zoom_value", nx_int(form.tbar_range.Value))
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshHeadConfig()
  end
  refresh_head_zoom(form)
  refresh_obj_head()
end
function recover_to_default(form)
  form.cbtn_aishow.Checked = false
  form.cbtn_headinfo.Checked = true
  form.cbtn_myname.Checked = true
  form.cbtn_myorgind.Checked = true
  form.cbtn_myguild.Checked = true
  form.cbtn_myguildid.Checked = true
  form.cbtn_friendname.Checked = true
  form.cbtn_friendorgind.Checked = true
  form.cbtn_friendguild.Checked = true
  form.cbtn_friendguildid.Checked = true
  form.cbtn_enemyname.Checked = true
  form.cbtn_enemyorgind.Checked = true
  form.cbtn_enemyguild.Checked = true
  form.cbtn_enemyguildid.Checked = true
  form.cbtn_npcname.Checked = true
  form.cbtn_npcorgind.Checked = true
  form.cbtn_npccorpsename.Checked = true
  form.cbtn_partnername.Checked = true
  form.cbtn_headblod.Checked = true
  form.cbtn_playerblood.Checked = true
  form.cbtn_myblood.Checked = false
  form.cbtn_friendblood.Checked = false
  form.cbtn_enemyblood.Checked = true
  form.cbtn_npcblood.Checked = true
  form.cbtn_friendnpc.Checked = false
  form.cbtn_enemynpc.Checked = true
  form.cbtn_kungfu.Checked = true
  form.rbtn_kfall.Checked = false
  form.rbtn_kfuse.Checked = true
  form.cbtn_3.Checked = true
  form.rbtn_5.Checked = false
  form.rbtn_6.Checked = true
  form.tbar_range.Value = 200
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
function refresh_head_zoom(form)
  if not nx_is_valid(form) then
    return
  end
  local value = form.tbar_range.Value
  value = 0.98 + value * 1.0E-4
  local balls = nx_value("balls")
  if nx_is_valid(balls) then
    balls.FadeOutDepth = value
  end
end
function set_headinfoctrl_enable(form, value)
  form.cbtn_myname.Enabled = value
  form.cbtn_myguild.Enabled = value
  form.cbtn_friendname.Enabled = value
  form.cbtn_friendguild.Enabled = value
  form.cbtn_enemyname.Enabled = value
  form.cbtn_enemyguild.Enabled = value
  form.cbtn_npcname.Enabled = value
  form.cbtn_partnername.Enabled = value
  form.cbtn_myorgind.Enabled = form.cbtn_myname.Enabled and form.cbtn_myname.Checked
  form.cbtn_myguildid.Enabled = form.cbtn_myguild.Enabled and form.cbtn_myguild.Checked
  form.cbtn_friendorgind.Enabled = form.cbtn_friendname.Enabled and form.cbtn_friendname.Checked
  form.cbtn_friendguildid.Enabled = form.cbtn_friendguild.Enabled and form.cbtn_friendguild.Checked
  form.cbtn_enemyorgind.Enabled = form.cbtn_enemyname.Enabled and form.cbtn_enemyname.Checked
  form.cbtn_enemyguildid.Enabled = form.cbtn_enemyguild.Enabled and form.cbtn_enemyguild.Checked
  form.cbtn_npcorgind.Enabled = form.cbtn_npcname.Enabled and form.cbtn_npcname.Checked
  form.cbtn_npccorpsename.Enabled = form.cbtn_npcname.Enabled and form.cbtn_npcname.Checked
end
function set_headbloodctrl_enable(form, value)
  form.cbtn_playerblood.Enabled = value
  form.cbtn_npcblood.Enabled = value
  form.cbtn_myblood.Enabled = form.cbtn_playerblood.Enabled and form.cbtn_playerblood.Checked
  form.cbtn_friendblood.Enabled = form.cbtn_playerblood.Enabled and form.cbtn_playerblood.Checked
  form.cbtn_enemyblood.Enabled = form.cbtn_playerblood.Enabled and form.cbtn_playerblood.Checked
  form.cbtn_friendnpc.Enabled = form.cbtn_npcblood.Enabled and form.cbtn_npcblood.Checked
  form.cbtn_enemynpc.Enabled = form.cbtn_npcblood.Enabled and form.cbtn_npcblood.Checked
end
function set_headkfctrl_enable(form, value)
  form.rbtn_kfall.Enabled = value
  form.rbtn_kfuse.Enabled = value
end
function set_headkfctrl_enable_for_adv_qg(form, value)
  form.rbtn_5.Enabled = value
  form.rbtn_6.Enabled = value
end
