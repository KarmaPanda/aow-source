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
function init_ui_content(form)
  local game_config_info = nx_value("game_config_info")
  local key = util_get_property_key(game_config_info, "prompt_friend_login", 1)
  form.cbtn_friendlogin.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "prompt_friend_logout", 1)
  form.cbtn_friendlogout.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "prompt_attent_login", 1)
  form.cbtn_attentlogin.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "prompt_attent_logout", 1)
  form.cbtn_attentlogout.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "prompt_guild_login", 1)
  form.cbtn_guild_login.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "prompt_guild_logout", 1)
  form.cbtn_guild_logout.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "prompt_banners", 1)
  form.cbtn_banners.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "prompt_buddynews", 1)
  form.cbtn_buddynews.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "prompt_enemy_point", 1)
  form.cbtn_enemy_point.Checked = nx_string(key) == nx_string("1") and true or false
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  util_set_property_key(game_config_info, "prompt_friend_login", nx_int(form.cbtn_friendlogin.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "prompt_friend_logout", nx_int(form.cbtn_friendlogout.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "prompt_attent_login", nx_int(form.cbtn_attentlogin.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "prompt_attent_logout", nx_int(form.cbtn_attentlogout.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "prompt_guild_login", nx_int(form.cbtn_guild_login.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "prompt_guild_logout", nx_int(form.cbtn_guild_logout.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "prompt_banners", nx_int(form.cbtn_banners.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "prompt_buddynews", nx_int(form.cbtn_buddynews.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "prompt_enemy_point", nx_int(form.cbtn_enemy_point.Checked and "1" or "0"))
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
end
function recover_to_default(form)
  form.cbtn_friendlogin.Checked = true
  form.cbtn_friendlogout.Checked = true
  form.cbtn_attentlogin.Checked = true
  form.cbtn_attentlogout.Checked = true
  form.cbtn_guild_login.Checked = true
  form.cbtn_guild_logout.Checked = true
  form.cbtn_banners.Checked = true
  form.cbtn_buddynews.Checked = true
  form.cbtn_enemy_point.Checked = true
end
function update_operate(form)
end
