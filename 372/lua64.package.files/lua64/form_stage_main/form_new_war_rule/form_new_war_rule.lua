require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_MAIN_NAME = "form_stage_main\\form_new_war_rule\\form_new_war_rule"
local ST_FUNCTION_SCHOOL_FIGHT = 925
local ST_FUNCTION_CROSS_SCHOOL_FIGHT = 926
local REWARD_TYPE_COUNT = 4
local DEFEND_INDEX = 1
local ATTACK_INDEX = 2
local STC_CLOSE_LEAVE_TIMER = 0
local STC_CLIENT_GUI_CONTROL = 1
local STC_CLIENT_OPEN_TIMER = 2
local STC_ANSWER_SINGLE_REC_DATA = 3
local STC_ANSWER_GUILD_REC_DATA = 4
local STC_SEND_FIGHT_OVER = 5
local STC_SEND_PLAYER_KILL_NUMBER = 6
local STC_SEND_PLAYER_HELP_KILL_NUMBER = 7
local STC_ANSWER_FIGHT_INFO_SCHOOL_FIGHT = 20
local CS_REQUEST_FIGHT_INFO = 0
local CS_REQUEST_ENTER_WAR = 1
local CS_REQUEST_QUIT_WAR = 2
local CS_REQUEST_GAME_DATA = 3
local UBST_SCHOOL_FIGHT = 3
local UBST_CROSS_SCHOOL_FIGHT = 4
function on_server_msg(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(STC_CLOSE_LEAVE_TIMER) then
    local form_map = util_get_form("form_stage_main\\form_main\\form_main_map", true)
    if nx_is_valid(form_map) then
      form_map.btn_new_war_rule.Visible = false
    end
    local game_type = arg[1]
    if game_type == UBST_SCHOOL_FIGHT or game_type == UBST_CROSS_SCHOOL_FIGHT then
      nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_timer_school_fight", "close_form")
      nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_score_school_fight", "close_form")
    end
    nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_killnum", "refresh_killnum", -1)
  elseif nx_int(sub_msg) == nx_int(STC_CLIENT_GUI_CONTROL) then
    on_handler_modal_form(unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_CLIENT_OPEN_TIMER) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local sub_type = client_player:QueryProp("BattleSubType")
    if sub_type == UBST_SCHOOL_FIGHT or sub_type == UBST_CROSS_SCHOOL_FIGHT then
      nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_timer_school_fight", "check_open_form")
      nx_execute("form_stage_main\\form_universal_school_fight\\form_universal_school_fight_progress", "open_form")
    end
  elseif nx_int(sub_msg) == nx_int(STC_ANSWER_SINGLE_REC_DATA) then
    local game_type = arg[1]
    table.remove(arg, 1)
    if game_type == UBST_SCHOOL_FIGHT or game_type == UBST_CROSS_SCHOOL_FIGHT then
      nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_score_school_fight", "refresh_single_data", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(STC_ANSWER_GUILD_REC_DATA) then
    local game_type = arg[1]
    table.remove(arg, 1)
    if game_type == UBST_SCHOOL_FIGHT or game_type == UBST_CROSS_SCHOOL_FIGHT then
      nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_score_school_fight", "refresh_guild_data", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(STC_SEND_FIGHT_OVER) then
    on_show_rank_stat(unpack(arg))
  elseif sub_msg == STC_SEND_PLAYER_KILL_NUMBER then
    nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_killnum", "refresh_killnum", nx_int(arg[1]))
  elseif sub_msg == STC_SEND_PLAYER_HELP_KILL_NUMBER then
    nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_killnum", "refresh_zhugong_num", nx_int(arg[1]))
  elseif nx_int(sub_msg) >= nx_int(STC_ANSWER_FIGHT_INFO_SCHOOL_FIGHT) then
    nx_execute("form_stage_main\\form_universal_school_fight\\form_universal_school_fight_main", "on_server_msg", sub_msg, unpack(arg))
  end
end
function send_server_msg(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_WAR_RULE), unpack(arg))
end
function on_handler_modal_form(...)
  if table.getn(arg) < 1 then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  if nx_int(arg[1]) == nx_int(1) then
    if not util_is_lockform_visible("form_stage_main\\form_new_war_rule\\form_new_war_rule_wait") then
      util_auto_show_hide_form_lock("form_stage_main\\form_new_war_rule\\form_new_war_rule_wait")
    end
  elseif nx_int(arg[1]) == nx_int(0) then
    local wait_form = util_get_form("form_stage_main\\form_new_war_rule\\form_new_war_rule_wait", false)
    if not nx_is_valid(wait_form) then
      return
    end
    wait_form:Close()
  end
end
function on_show_rank_stat()
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1500, 1, nx_current(), "on_open_rank_stat", nx_value("game_client"), -1, -1)
  end
end
function on_open_rank_stat()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sub_type = client_player:QueryProp("BattleSubType")
  if sub_type == UBST_SCHOOL_FIGHT or sub_type == UBST_CROSS_SCHOOL_FIGHT then
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_new_war_rule\\form_new_war_rule_score_school_fight", true, false)
  end
  if not nx_is_valid(dialog) then
    return
  end
  dialog:Show()
end
