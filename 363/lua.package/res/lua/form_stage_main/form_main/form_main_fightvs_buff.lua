require("form_stage_main\\form_main\\form_main_fightvs_util")
function main_form_init(form)
  form.Fixed = true
  form.no_need_motion_alpha = true
  form.buff_id = ""
  form.eff_name = 0
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = 250
  form.AbsTop = 200
  gui.Desktop:ToBack(form)
end
function main_form_close(form)
  local form_main_buff = nx_value("form_main_buff")
  if nx_is_valid(form_main_buff) then
    form_main_buff:del_hide_buff_state(form)
  end
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("BuffTimeDown", form)
  nx_destroy(form)
end
function change_form_size()
  local form = util_get_form(FORM_FIGHT_VS_BUFF, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.AbsLeft = 250
  form.AbsTop = 200
end
function hide_buff_state(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.buff_id = ""
  form.eff_name = ""
  form:Close()
end
function show_buff_state(buff_id, eff_name, live_time)
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return 0
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return 0
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return 0
  end
  local form = util_get_form(FORM_FIGHT_VS_BUFF, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  if form.eff_name ~= "" and FIGHT_BUFF_EFFECT[form.eff_name] ~= nil and FIGHT_BUFF_EFFECT[form.eff_name][1] > FIGHT_BUFF_EFFECT[eff_name][1] then
    return 0
  end
  timer:UnRegister(FORM_FIGHT_VS_BUFF, "hide_buff_state", form)
  common_execute:RemoveExecute("BuffTimeDown", form)
  form.buff_id = buff_id
  form.eff_name = eff_name
  form.lbl_back.Visible = false
  form.ani_back.PlayMode = 2
  form.ani_type.PlayMode = 2
  form.ani_type.AnimationImage = FIGHT_BUFF_EFFECT[eff_name][5]
  form.lbl_pbar_back.BackImage = FIGHT_BUFF_EFFECT[eff_name][3]
  form.lbl_pbar_fore.BackImage = FIGHT_BUFF_EFFECT[eff_name][4]
  form.lbl_pbar_back.Visible = false
  form.lbl_pbar_fore.Visible = false
  if nx_string(buff_id) ~= "" then
    local msg_delay = nx_value("MessageDelay")
    local cur_time = msg_delay:GetServerNowTime()
    live_time = (nx_int64(live_time) - nx_int64(cur_time)) / 1000
  end
  if 0 >= nx_number(live_time) then
    form.buff_id = ""
    form.eff_name = 0
    return 0
  end
  util_show_form(FORM_FIGHT_VS_BUFF, true)
  local pbar_time = live_time - (ANI_TIME_BACK + ANI_TYPE_BACK)
  if 0 >= nx_number(pbar_time) then
    return 0
  end
  common_execute:AddExecute("BuffTimeDown", form, nx_float(0.01), nx_float(ANI_TIME_BACK), nx_float(ANI_TYPE_BACK), nx_float(pbar_time))
  timer:Register(nx_int(live_time) * 1000, 1, FORM_FIGHT_VS_BUFF, "hide_buff_state", form, -1, -1)
end
function add_buffer_info(buff_id, target_ident, eff_type, end_time)
  local sprite_manager = nx_value("SpriteManager")
  if not nx_is_valid(sprite_manager) then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_obj = game_client:GetSceneObj(nx_string(target_ident))
  if not nx_is_valid(client_obj) then
    return 0
  end
  if buff_id == nil or buff_id == "" then
    return 0
  end
  local visible = buff_static_query(nx_string(buff_id), "Visible")
  if nx_string(visible) ~= "1" then
    return 0
  end
  if not game_client:IsPlayer(nx_string(target_ident)) then
    return 0
  end
  if eff_type == nil or eff_type == "" then
    return 0
  end
  local eff_name = ""
  local eff_level = 0
  for key, sub_tab in pairs(FIGHT_BUFF_EFFECT) do
    if nx_function("ext_is_buff_type", nx_int(eff_type), nx_int(sub_tab[2])) and eff_level < nx_number(sub_tab[1]) then
      eff_name = key
      eff_level = nx_number(sub_tab[1])
    end
  end
  if nx_string(eff_name) == "" then
    return 0
  end
  if end_time == nil or end_time == "" then
    return 0
  end
  show_buff_state(buff_id, eff_name, nx_int64(end_time))
end
function del_buffer_info(buff_id, target_ident)
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return 0
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return 0
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_obj = game_client:GetSceneObj(nx_string(target_ident))
  if not nx_is_valid(client_obj) then
    return 0
  end
  if not game_client:IsPlayer(nx_string(target_ident)) then
    return 0
  end
  if buff_id == nil or buff_id == "" then
    return 0
  end
  local form = util_get_form(FORM_FIGHT_VS_BUFF, false)
  if not nx_is_valid(form) then
    return 0
  end
  if form.buff_id ~= buff_id then
    return 0
  end
  timer:UnRegister(FORM_FIGHT_VS_BUFF, "hide_buff_state", form)
  form.buff_id = ""
  form.eff_name = ""
  form:Close()
end
