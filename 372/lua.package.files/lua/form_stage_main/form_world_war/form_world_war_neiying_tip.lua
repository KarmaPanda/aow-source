local form_name = "form_stage_main\\form_world_war\\form_world_war_neiying_tip"
require("form_stage_main\\form_world_war\\form_world_war_define")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_1_click(btn)
  send_world_war_custom_msg(CLIENT_WORLDWAR_TRAITOR_VOTE_INFO)
end
function send_world_war_custom_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(sub_msg), unpack(arg))
end
