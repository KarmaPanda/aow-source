require("util_gui")
require("util_functions")
require("custom_sender")
STC_SUB_KOF_FORM_ALL_INFO = 0
STC_SUB_KOF_FORM_PLAYER_WUXUE = 1
STC_SUB_KOF_FORM_PLAYER_NEIGONG = 2
STC_SUB_KOF_FORM_STAGE = 3
STC_SUB_KOF_FORM_LOADING = 4
STC_SUB_KOF_FORM_ROUND_RES = 5
STC_SUB_KOF_FORM_WAR_RES = 6
STC_SUB_KOF_RETURN_PLAYER_INFO = 7
STC_SUB_KOF_ADD_MATCH = 8
STC_SUB_KOF_LOOKER_CHAT = 9
STC_SUB_KOF_RETURN_RULE = 10
STC_SUB_KOF_RETURN_RANK = 11
STC_SUB_KOF_RETURN_RANK_SCORE = 12
CTS_SUB_KOF_APPLY = 0
CTS_SUB_KOF_CANCEL = 1
CTS_SUB_KOF_LEAVE = 2
CTS_SUB_KOF_SEL_WUXUE = 3
CTS_SUB_KOF_DEL_WUXUE = 4
CTS_SUB_KOF_GET_PLAYER_INFO = 5
CTS_SUB_KOF_LOOKER_CHAT = 6
KOF_STAGE_PICK = 1
KOF_STAGE_DECISION = 2
KOF_STAGE_LOADING = 3
KOF_STAGE_ROUND_1 = 4
KOF_STAGE_ROUND_2 = 5
KOF_STAGE_ROUND_3 = 6
KOF_STAGE_ROUND_4 = 7
KOF_STAGE_ROUND_5 = 8
KOF_STAGE_END = 9
KOF_ROUND_STAGE_READY = 1
KOF_ROUND_STAGE_WAR = 2
KOF_ROUND_STAGE_END = 3
local tab_score_level = {
  -11000,
  -10000,
  -9000,
  -8000,
  -7000,
  -6000,
  -5000,
  -4000,
  -3000,
  -2000,
  -1000,
  0,
  1000,
  2000,
  3000,
  4000,
  5000,
  6000,
  7000,
  8000,
  9000,
  10000,
  11000,
  99999
}
function get_score_image(score)
  local score_level = 1
  for i = 1, #tab_score_level do
    if score < tab_score_level[i] then
      score_level = i
      break
    end
  end
  return "gui\\special\\kof\\score_" .. nx_string(score_level) .. ".png"
end
function on_msg_all_info(...)
  local rule = nx_number(arg[1])
  local stage_info = nx_string(arg[2])
  local all_info = nx_widestr(arg[3])
  local tab_stage = util_split_string(stage_info, ",")
  local stage = nx_number(tab_stage[1])
  local left_time = nx_number(tab_stage[2])
  if stage == KOF_STAGE_PICK or stage == KOF_STAGE_DECISION then
    nx_execute("form_stage_main\\form_kof\\form_kof_main", "open_form")
    nx_execute("form_stage_main\\form_kof\\form_kof_main", "update_stage", stage, left_time)
    nx_execute("form_stage_main\\form_kof\\form_kof_main", "update_rule", rule)
    local tab_all_info = util_split_wstring(all_info, ",")
    nx_execute("form_stage_main\\form_kof\\form_kof_main", "update_players", stage, unpack(tab_all_info))
  else
    nx_execute("form_stage_main\\form_kof\\form_kof_main", "close_form")
  end
  if stage >= KOF_STAGE_ROUND_1 and stage <= KOF_STAGE_ROUND_5 then
    nx_execute("form_stage_main\\form_kof\\form_kof_looker", "open_form")
    nx_execute("form_stage_main\\form_kof\\form_kof_fighter", "open_form_and_hide")
    local tab_all_info = util_split_wstring(all_info, ",")
    nx_execute("form_stage_main\\form_kof\\form_kof_looker", "update_team_info", unpack(tab_all_info))
  end
  on_msg_stage(stage_info)
end
function test()
  nx_execute("form_stage_main\\form_kof\\form_kof_looker", "open_form_and_hide")
  nx_execute("form_stage_main\\form_kof\\form_kof_fighter", "open_form_and_hide")
  local tab_all_info = util_split_wstring(all_info, ",")
  nx_execute("form_stage_main\\form_kof\\form_kof_looker", "update_team_info", "\210\187", 100, 0, "ng_1", "CS_sjy_dkd", "CS_yh_hsqs", 0, 0, "\182\254", 200, 0, "ng_2", "CS_jh_zq", "CS_wd_lyjf", 0, 0, "\188\242\203\216\199\228", 200, 0, "ng_2", "CS_jh_kfdf", "CS_jh_qxz", 0, 0, "\210\187", 100, 0, "ng_1", "CS_sjy_dkd", "CS_yh_hsqs", 0, 0, "\182\254", 200, 0, "ng_2", "CS_jh_zq", "CS_wd_lyjf", 0, 0, "\188\242\203\216\199\228", 200, 0, "ng_2", "CS_jh_kfdf", "CS_jh_qxz", 0, 1)
end
function on_msg_player_wuxue(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_main", "update_player_one_wuxue", unpack(arg))
end
function on_msg_player_neigong(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_main", "update_player_one_neigong", unpack(arg))
end
function on_msg_stage(...)
  local info = nx_string(arg[1])
  local tab_info = util_split_string(info, ",")
  local stage = nx_number(tab_info[1])
  local left_time = nx_number(tab_info[2])
  nx_execute("form_stage_main\\form_kof\\form_kof_main", "update_stage", stage, left_time)
  if stage >= KOF_STAGE_ROUND_1 and stage <= KOF_STAGE_ROUND_5 then
    local round_stage = nx_number(tab_info[3])
    local round_left_time = nx_number(tab_info[4])
    nx_execute("form_stage_main\\form_kof\\form_kof_fighter", "update_stage_info", round_stage, round_left_time)
    nx_execute("form_stage_main\\form_kof\\form_kof_looker", "update_stage_info", round_stage, round_left_time)
    if round_stage == KOF_ROUND_STAGE_READY then
      reset_self_view()
    end
  end
end
function on_msg_loading(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_loading", "update_form", unpack(arg))
end
function on_msg_round_res(...)
  local res = nx_widestr(arg[1])
  local tab_res = util_split_wstring(res, ",")
  nx_execute("form_stage_main\\form_kof\\form_kof_round_res", "update_info", unpack(tab_res))
end
function on_msg_war_res(...)
  local res = nx_widestr(arg[1])
  local tab_res = util_split_wstring(res, ",")
  nx_execute("form_stage_main\\form_kof\\form_kof_war_res", "update_form", unpack(tab_res))
end
function on_msg_player_info(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_apply", "update_info", unpack(arg))
end
function on_msg_add_match(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_wait", "open_form")
end
function on_msg_looker_chat(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_looker", "looker_chat", unpack(arg))
end
function on_msg_return_rule(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_apply", "update_rule", unpack(arg))
end
function on_msg_return_rank(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_apply", "update_rank", unpack(arg))
end
function on_msg_return_rank_score(...)
  nx_execute("form_stage_main\\form_kof\\form_kof_apply", "update_rank_score", unpack(arg))
end
function show_fighter()
  local form_fighter = util_get_form("form_stage_main\\form_kof\\form_kof_fighter", false)
  local form_looker = util_get_form("form_stage_main\\form_kof\\form_kof_looker", false)
  if nx_is_valid(form_fighter) and nx_is_valid(form_looker) then
    form_fighter.Visible = true
    nx_execute("form_stage_main\\form_kof\\form_kof_looker", "hide_some_gb")
  end
  nx_execute("gui", "gui_open_closedsystem_form_easy")
end
function show_looker()
  local form_fighter = util_get_form("form_stage_main\\form_kof\\form_kof_fighter", false)
  local form_looker = util_get_form("form_stage_main\\form_kof\\form_kof_looker", false)
  if nx_is_valid(form_fighter) and nx_is_valid(form_looker) then
    form_fighter.Visible = false
    nx_execute("form_stage_main\\form_kof\\form_kof_looker", "show_some_gb")
  end
  nx_execute("gui", "gui_close_allsystem_form_easy", 4)
end
function get_main_player_name()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  return player:QueryProp("Name")
end
function is_main_player(player_name)
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("Name") then
    return false
  end
  return player_name == player:QueryProp("Name")
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function reset_self_view()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_control = client_player.scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.Target = nx_null()
  game_control.TargetMode = 0
end
function get_round_stage_text(round_stage)
  return util_text("ui_kof_round_stage_" .. nx_string(round_stage))
end
function is_in_kof()
  local client = nx_value("game_client")
  local scene = client:GetScene()
  if nx_is_valid(scene) then
    local scene_resource = scene:QueryProp("Resource")
    return nx_string(scene_resource) == "battle_kof"
  end
  return false
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(b)
  nx_msgbox(nx_string(b))
end
