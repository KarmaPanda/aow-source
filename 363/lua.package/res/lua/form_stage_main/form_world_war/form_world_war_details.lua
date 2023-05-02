require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
local yunliang_config_id = ""
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  req_state_info()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_wujiang_click(btn)
  local form_sub_details = nx_value("form_stage_main\\form_world_war\\form_world_war_sub_details")
  if nx_is_valid(form_sub_details) then
    form_sub_details.Visible = false
  end
  local form_sub_details_aga = nx_value("form_stage_main\\form_world_war\\form_world_war_sub_details_aga")
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_stat")
  if not nx_is_valid(form) or not nx_is_valid(form_sub_details_aga) then
    return
  end
  form_sub_details_aga.Visible = true
  if form.Width > form.groupbox_form.Width then
    form.Width = form.groupbox_form.Width
    return
  end
  form.Width = form.Width + form_sub_details_aga.Width
end
function on_btn_station_click(btn)
  local form_sub_details_aga = nx_value("form_stage_main\\form_world_war\\form_world_war_sub_details_aga")
  if nx_is_valid(form_sub_details_aga) then
    form_sub_details_aga.Visible = false
  end
  local form_sub_details = nx_value("form_stage_main\\form_world_war\\form_world_war_sub_details")
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_stat")
  if not nx_is_valid(form) or not nx_is_valid(form_sub_details) then
    return
  end
  form_sub_details.Visible = true
  if form.Width > form.groupbox_form.Width then
    form.Width = form.groupbox_form.Width
    return
  end
  form.Width = form.Width + form_sub_details.Width
end
function req_state_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(CLIENT_WORLDWAR_STATE_INFO))
end
function rev_state_info(...)
  local form = util_get_form("form_stage_main\\form_world_war\\form_world_war_details", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_mingjun.Text = nx_widestr(arg[1])
  form.lbl_mengjun.Text = nx_widestr(arg[2])
  form.lbl_score_1.Text = nx_widestr(arg[3])
  form.lbl_point_num.Text = nx_widestr(arg[4])
  form.lbl_point_score.Text = nx_widestr(arg[5])
  form.lbl_trans_num.Text = nx_widestr(arg[6])
  form.lbl_trans_score.Text = nx_widestr(arg[7])
  form.lbl_gongjian_num.Text = nx_widestr(arg[8])
end
