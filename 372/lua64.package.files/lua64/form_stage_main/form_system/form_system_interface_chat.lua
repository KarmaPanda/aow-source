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
  local key = util_get_property_key(game_config_info, "show_whole_chat_info", 1)
  form.cbtn_bubble.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "show_team_chat_info", 1)
  form.cbtn_teambubble.Checked = nx_string(key) == nx_string("1") and true or false
  key = util_get_property_key(game_config_info, "play_chatprompt_sound", 1)
  form.cbtn_msgprompt.Checked = nx_string(key) == nx_string("1") and true or false
end
function save_to_file(form)
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  util_set_property_key(game_config_info, "show_whole_chat_info", nx_int(form.cbtn_bubble.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "show_team_chat_info", nx_int(form.cbtn_teambubble.Checked and "1" or "0"))
  util_set_property_key(game_config_info, "play_chatprompt_sound", nx_int(form.cbtn_msgprompt.Checked and "1" or "0"))
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshHeadConfig()
  end
end
function recover_to_default(form)
  form.cbtn_bubble.Checked = true
  form.cbtn_teambubble.Checked = true
  form.cbtn_msgprompt.Checked = true
end
function update_operate(form)
end
