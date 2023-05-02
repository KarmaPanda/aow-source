require("share\\server_custom_define")
require("share\\client_custom_define")
require("share\\view_define")
require("share\\npc_type_define")
require("util_gui")
require("util_functions")
require("const_define")
require("define\\request_type")
require("define\\task_npc_flag")
require("share\\chat_define")
require("define\\sysinfo_define")
require("share\\npc_type_define")
require("role_composite")
require("util_static_data")
require("utils")
require("player_state\\state_input")
require("player_state\\logic_const")
require("player_state\\state_const")
require("form_stage_main\\switch\\url_define")
require("form_stage_main\\form_common_self_add_notice")
require("define\\camera_mode")
require("form_stage_main\\form_task\\task_define")
require("define\\map_lable_define")
require("util_role_prop")
local HEART_TIME = 1000
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
local nip_radian = function(r)
  local ret = r - nx_number(nx_int(r / (2 * math.pi))) * (2 * math.pi)
  if ret < 0 then
    ret = ret + 2 * math.pi
  end
  return ret
end
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function custom_handler_init(chander)
  nx_callback(chander, "on_scene_obj_action", "custom_scene_obj_action")
  nx_callback(chander, "on_scene_obj_jump", "custom_scene_obj_jump")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ACTION, "custom_action")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHAT, "custom_chat")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REQUEST, "custom_be_request")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SYSINFO, "custom_sysinfo")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SPECIFIC_SYSINFO, "custom_specific_sysinfo")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ASYN_TIME, "custom_asyn_time")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_MENU, "custom_beginmenu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ADD_TITLE, "custom_addtitle")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ADD_MENU, "custom_addmenu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_MENU, "custom_endmenu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_MENU, "custom_closemenu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EFFECT, "custom_effect")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SKILL_ACTION_WITH_TRANSLATE, "custom_skill_action_with_tanslate")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SKILL_ACTION, "custom_skill_action")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_CURSE, "custom_begin_curse")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_CURSE, "custom_end_curse")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ADJUST_SKILL_CURSE, "custom_adjust_skill_curse")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NOT_COMPLETE_TASK_INFO, "open_task_not_complete_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NOTICE_NPCFLAG, "change_tasknpc_flag")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_TOOLBOX, "open_tool_box")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_SELECT_DIALOG, "open_task_select_dialog")
  nx_callback(chander, "on_" .. SREVER_CUSTOMMSG_NOTICE_NPCEFFECT, "change_tasknpc_effect")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_SHARE_TASK_MENU, "show_share_task_menu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_QUERY_EDIT_TASK_INFO, "show_query_edit_task_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SEND_SELECT_TASK_INFO, "show_select_edittask_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPENSUBMIT_COLLECT_BOX, "open_submit_collect_box")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_TIME_LIMIT_SHOW, "time_limit_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HIDE_NPC_ONLY_SELF, "hide_npc_client")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PLAY_SOUND, "custom_play_point_sound")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_TALK, "on_npc_talk")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RANDOMADVENTUR_SYSTEM_INFO, "random_adventure_system_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_KARMA_SPRING, "on_npc_karma_spring")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_NPC_FRIEND, "on_show_npc_friend")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_UPDATE_NPC_KARMA_VALUE, "on_update_npc_karma_value")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_UPDATE_NPC_KARMA, "on_update_npc_karma")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_PAUSE_SKILL, "npc_begin_pause_skill")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_PAUSE_SKILL, "npc_end_pause_skill")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SEND_LETTER_RESULT, "send_letter_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_IS_DELETE_LETTER, "is_delete_letter")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_LETTER_MONEY_SUCCESS, "get_letter_money_success")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_VIRTUALREC_ADD, "virtualrec_add")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_VIRTUALREC_CLEAR, "virtualrec_clear")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_VIRTUALREC_UPDATE, "virtualrec_update")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_VIRTUALREC_UPDATE_ROW, "virtualrec_updaterow")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_VIRTUALREC_REMOVE_ROW, "virtualrec_removerow")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_INPUT_COMMEND_MARRIAGE_DLG, "custom_marriage_npc")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PUSH_ROLL_ITEM, "custom_push_roll_item")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_POP_ASSIGN_DLG, "custom_team_assign_dlg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOLPOSE_VOTE, "on_recive_schoolpose_vote")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_POP_COMPETE_BASEPRICE_DLG, "custom_open_compete_baseprice_dlg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_COMPETE, "custom_begin_compete")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_COMPETE_RESULT_INFO, "custom_handle_compete_result_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_PRODUCEJIGUAN, "custom_producejiguan_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_ANIMATION, "custom_show_animation")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DEL_ANIMATION, "custom_del_animation")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BORN, "custom_new_born")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LOOK_ITEM_ECHO, "custom_receive_item_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GAME_START_STUMP, "custom_game_stump_start")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GAME_STOP_STUMP, "custom_game_stump_stop")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_TIMER, "custom_start_timer")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SWITCH_SCENE_BEGIN, "custom_switch_scene_begin")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_MOVE, "custom_npc_move")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REFRESH_ORIGIN, "custom_refresh_origin")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_A_NEW_ORIGIN, "custom_notify_a_new_origin")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHENGHUO_ACTION, "custom_shenghuo_action")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LIFE_SKILL_FLOW_HIT, "custom_life_skill_hit")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_A_NEW_LIFEJOB, "custom_get_a_new_lifejob")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PLAYER_ONREADY, "custorm_player_enter_scene_onready")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PLAYER_ONCONTINUE, "custorm_player_oncontinue")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_MODEL_DIALOG_INFO, "custom_show_model_dialog_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_MOVIE, "custom_start_movie")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MOVIE_REQUEST, "custom_movie_request")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STOP_MOVIE, "custom_stop_movie")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ENTER_NEW_SCENE, "custom_set_city_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NOT_FINISH_OFFLINEWORK, "custom_offline_not_finish")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_OFFLINE_JOB_LOG, "custom_show_offline_job_log")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_OFFLINE_JOB_DAILY, "custom_show_offline_job_daily")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HIDE_OFFLINE_JOB_DAILY, "custom_hide_offline_job_daily")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_OFFLINE_PRIZE, "custom_show_offline_prize")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_PLAYSNAIL_MAIN, "custom_open_playsnail_main")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_OFFLINE_JOB_INTERACT, "custom_show_offline_job_interact")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HIDE_OFFLINE_JOB_INTERACT, "custom_hide_offline_job_interact")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_OFFLINE_JOB_INTERACT_PRIZE, "custom_show_offline_job_interact_prize")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HIDE_OFFLINE_JOB_INTERACT_PRIZE, "custom_hide_offline_job_interact_prize")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_OFFLINE_TOGETHER, "custom_show_offline_togather")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OFFLINE_CLIENT_CLOSE, "custom_close_client")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CAPTAIN_RESET_CLONE, "captain_reset_clone")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_UPDATE_PLAYER_POS, "custom_update_player_pos")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_HELP_FORM, "custom_open_help_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OFFLINEWORK_ONLINE_EFFECT, "custom_offlinework_online_effect")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_A_NEW_SKILL, "custom_get_a_new_skill")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LIFE_FRESHMAN_HELP, "custom_show_life_freshmanhelp")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FRESHMAN_HELP_STEP, "custom_help_step")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_INTERACTIVE_ACTION, "custom_start_inter_action")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_INTERACTIVE_ACTION, "custom_end_inter_action")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BAND_RELIVE_POS, "custom_band_relive_pos")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RELIVE_END, "custom_relive_end")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RELIVE_CHECK, "custom_relive_check")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DONGHAI_RELIVE_CHECK, "custom_donghai_relive_check")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORGE_STARTED, "custom_forge_started")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORGE_STOPPED, "custom_forge_stopped")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORGE_TIMEOUT, "custom_forge_timeout")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CANCEL_STEP, "custom_forge_cancel_step")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORGE_STEP_DIFF, "custom_forge_step_diff")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_ROADSIGN, "custom_show_roadsign")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_BASE_INFO, "custom_show_base_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_BINGLU_INFO, "custom_show_binglu_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_EQUIP_INFO, "custom_show_equip_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_GAME_INFO, "custom_show_game_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_SCHOOLLEADER_INFO, "custom_show_schoolleader_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CAN_FORTUNETELLINGSTALL, "custom_can_fortunetellingstall")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORTUNETELLINGSTALL_OKAY, "custom_start_fortunetellingstall")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_PATHING_OKAY, "stall_pathing_okay")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_BUSINESS, "close_business")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_POSITION_OKAY, "stall_position_okay")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MARKET, "custom_market_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_LIUYAN_OKAY, "liuyan_okay")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_CLEAR_LIUYAN_OKAY, "liuyan_clear_okay")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_CLEAR_JILU_OKAY, "jilu_clear_okay")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORTUNETELLINGSTALL_CANCELED, "custom_canceled_fortunetellingstall")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEED_FORTUNETELLING, "custom_need_fortunetelling")
  nx_callback(chander, "on_" .. SERVER_ACCEPT_FORTUNETELLING_RESULT, "custom_accpet_fortunetelling_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SEARCH_XUECHOU, "custom_xuechou_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CAN_STALL, "custom_can_stall")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SELECT_STALL_OK, "can_select_stall_ok")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GOTO, "custom_goto")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_OKAY, "custom_stall_okay")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_CANCELED, "custom_stall_canceled")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OFFLINE_STALL_OKAY, "custom_offline_stall_okay")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CAN_OFFLINE_STALL, "can_offline_stall")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CROP_EFFECT_CHANGE, "change_crop_grow_effect")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_FIGHT_ANI_START, "npc_fight_animatio_start")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FACULTY_MSG, "custom_faculty_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TEAM_FACULTY, "custom_team_faculty")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHIJIA_QTE, "custom_shijia_qte")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_DANCE, "custom_shool_faculty")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ARENA, "custom_arena")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_ARENA_QUERY, "on_open_arena_query")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HOLDFACULTY_MSG, "custom_holdfaculty_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MACNPC_SPRING_ACT_START, "custom_machine_spring_start")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MACNPC_SPRING_ACT_END, "custom_machine_spring_end")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REFRESH_TASK_TRACKINFO, "custom_refresh_track_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_TASK_1201, "begin_task_1201")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TRIGGER_SKILL_EFFECT, "custom_trigger_skill_effect")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SKILL_ICON_FLASH, "skill_icon_flash")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PLAY_MUSIC, "play_music")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_POSE_FIGHT, "school_pose_fight")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_FIGHT, "school_fight")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GATHER_EFFECT, "gather_effect")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TASK_MSG, "task_msg_logic")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TASK_NOTICE_PLAYSNAIL_MSG, "task_notice_playsnail")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OUT_CLONE_TIME, "out_clone_time")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_RESET_CLONE_UI, "open_reset_clone_ui")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_INVITE_HELPER, "invite_helper")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_AVATAR_CLONE_INVITE_NEW_HELP, "avatar_clone_invite_new_help")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_AVATAR_CLONE_NOTICE, "avatar_clone_notice")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_AVATAR_CLONE_HELPER, "avatar_clone_helper")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TIPS_MSG, "on_client_tips")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_CLONE_MENU, "show_clone_menu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_CLONE_MENU, "close_clone_menu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_INPHASE_CLONE_MENU, "inphase_clone_menu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONE_LEAD_OPEN, "custom_clone_lead_form_open")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONE_LEAD_CLOSE, "custom_clone_lead_form_close")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONE_LEAD_CHANGE, "custom_clone_lead_form_change")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RANDOM_CLONE_OPEN_TIMER_FORM, "custom_self_add_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RANDOM_CLONE_CLOSE_TIMER_FORM, "custom_close_self_add_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RANDOM_CLONE_ENTER_CLONE, "custom_random_clone_enter_clone")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WUXUE_FLASH, "custom_wuxue_flash")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_COMMON_SKILLGRID, "common_skillgrid")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REFRESH_TRAINPAT_BTN, "refresh_trainpat_btn")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_COMMON_SKILLGRID, "close_common_skillgrid")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DRIVE_SKILL_OPEN, "drive_skill_open")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUILD_ENEMY_LIST, "on_custom_guild_enemy")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_BUY_GUILD_DOMAIN, "show_buy_guild_domain_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SEND_BUY_GUILD_DOMAIN_DATA, "recv_buy_guild_domain_data")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ZHENFA_LINE, "custom_zhenfa_line")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ZHENFA_MAP, "custom_zhenfa_map")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REFRESH_ZHENFA_EFFECT, "custom_refresh_zhenfa_effect")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEIGPK_MSG, "on_neig_pk_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_HIED_DROP_VIEW, "show_hide_drop_view")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_SPECIAL_RIDE, "start_special_ride")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_SPECIAL_RIDE, "end_special_ride")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_RIDE, "start_ride")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_RIDE, "end_ride")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_RIDE_SPURT, "start_ride_spurt")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_WORLD_TRANS, "start_world_trans")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_WORLD_TRANS, "end_world_trans")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_SCENE_TRANS, "start_scene_trans")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_SCENE_TRANS, "end_scene_trans")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OFF_TRANS, "off_trans")
  nx_callback(chander, "on_" .. SERVERMSG_PUSLISH_NEWS, "publish_news")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_TIME_LIMIT_FORM, "show_time_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_TIME_LIMIT_FORM, "close_time_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_COUNT_LIMIT_FORM, "show_count_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_INC_COUNT_LIMIT_FORM, "inc_count_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_COUNT_LIMIT_FORM, "close_count_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NOTIFY_DESC_LIMIT_FORM, "notify_desc_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLEAR_DESC_LIMIT_FORM, "clear_desc_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ASYN_SERVER_TIME, "asyn_server_time")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_CONFIG, "show_stall_config")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TRANSTOOL_CONTINUE_MOVE, "transtool_continue_move")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WORLD_RANK, "custom_world_rank")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_BREATH_IN_WATER, "custom_begin_breath_in_water")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_BREATH_IN_WATER, "custom_end_breath_in_water")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HEAD_TEXT, "custom_update_head_text")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHALLENGE_ORIENT, "custom_challenge_orient")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FISHING_FORM, "custom_fishing_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OFFLINE_ONHAND_SHOWFORM, "showform_offline_onhand")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MINIGAME_ITEMRESULT, "game_minigame_itemresult")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STOP_USE_SKILL, "stop_use_skill")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SUCCESS_STALL_SHENGJI, "stall_success_shengji")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BUY_STALL_STYLE_OK, "buy_stall_style_ok")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_AUGUR, "start_augur")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_AUGUR_RESULT, "end_augur")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLF_ROLLGAME, "on_clf_rollgame")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HUAWUQUE_RACE, "on_hwq_choice")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUMU_HZDD, "on_gumu_hzdd")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WUXIAN_FETE, "on_wuxian_fete")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STALL_NOTE, "on_stall_note")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_VOTE_FORM, "show_vote_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_VOTE_RESULT, "show_vote_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_USE_LUCKITEM, "on_use_luckitem")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_LIFE_TRADE, "begin_life_trade")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CAMERA_VIBRATE, "camera_vibrate")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TIGUAN_MSG, "tiguan_all_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TIGUANCHALLENGE, "tiguanchallenge_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BATTLEFIELD_MSG, "battlefield_all_msg")
  nx_callback(chander, "on_" .. SERVER_BEGPLAYER_RESULT, "begplayer_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GEM_TEMP_SKILL_SET, "on_gem_temp_skill_set")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SELECT_TARGET, "select_target")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HIRE_SHOP, "on_hire_shop_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_POINT_CONSIGN, "on_point_consign_msg")
  nx_callback(chander, "on_" .. SERVER_PREPARE_FORTUNETELLINGOTHER_RESULT, "on_prepare_fortunetellingother_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHARGE_SHOP_MSG, "on_charge_shop_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_PERSONATE, "on_npc_personnate")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DO_LOCK_EFFECT, "do_lock_effect")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GIVE_ITEM, "on_give_item")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GIVE_CLONE_AWARD, "on_give_clone_award")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_CLONE_AWARD, "on_end_clone_award")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUILDBANK_SHOW, "on_guild_bank_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SPY, "on_spy_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ONADD_SKILLITEM, "install_tmp_skill_item")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ONREMOVE_SKILLITEM, "uninstall_tmp_skill_item")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HUIHAI_MSG, "on_huihai_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FUSE_BEGIN, "on_fuse_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SKILLPAGE_FUSE_BEGIN, "on_skillpage_fuse_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_COMPOUND_BEGIN, "on_compound_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SPLIT_BOOK_BEGIN, "on_split_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CONTRIBUTE_BEGIN, "on_contribute_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_UPGRADE_EQUIP, "on_upgrade_equip_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EQUIP_CONVERT, "on_convert_equip_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EQUIP_QIMEN, "on_qimen_equip_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_EXCHANGE_BEGIN, "on_npc_exchange_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHANGE_EQUIP_ATTRIBUTE_BEGIN, "on_changeequip_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_EXCHANGE_BEGIN, "on_npcexchange_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ALCHEMY, "on_alchemy_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TREASUREBOX, "on_treasurebox_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FIRE_GUILD_MSG, "on_fire_guild_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ALL_ESCORT_LIST, "on_all_escort_list_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_INFO, "on_escort_info_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_FORM_OPEN, "on_escort_open_form_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_BEGIN, "on_escort_begin_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_END, "on_escort_end_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_AUDIO, "on_escort_audio_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_TIME_START, "on_server_escort_time_begin")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_TIME_END, "on_server_escort_time_end")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_MSG, "on_server_escort_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_LIST, "on_escort_list_open")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_GAME, "on_escort_game_open")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_ISSPECTIME, "on_escort_isspecialtime")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ACTIVE_LOCATION, "on_active_location")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SELECT_BIND, "on_select_bindtype")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ITEMSPLIT_FORM_OPEN, "on_split_item_form_open")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ITEMSPLIT_BREAKBTN_SHOW, "on_split_item_break_btn_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ITEMFUSE_BREAKBTN_SHOW, "on_fuse_item_break_btn_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ITEMSPLIT_SUCCESS, "on_split_item_success")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SIMULATE_JUMP, "on_simulate_jump")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_PLAY_ANIMATION_FORM, "on_open_play_animation_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_JOB_FORM, "on_open_job_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SINGLE_STEP, "process_single_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_PLAY_ANIMATION_FORM, "on_close_play_animation_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_CHINESE_CHESS_GAME, "on_start_chinese_chess_game")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_READY_CONFIRM, "on_leitai_ready_confirm")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ESCORT_LIST, "on_escort_list_open")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LIVEGROOVE_FACULTY, "on_form_livegroove_to_faculty")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_ROLL_GAME, "on_begin_roll_game")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_VIP_MSG, "on_vip_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_CALL_FOR_CONFIRM, "on_server_leitai_call_for_confirm")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_SYN_TIME, "on_server_leitai_syn_time")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_WAGER_INFO, "on_server_leitai_wager_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_REWARD_INFO, "on_server_leitai_reward_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_REWARD_COUNT, "on_server_leitai_reward_count")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_QIECUO_COUNT, "on_server_leitai_qiecuo_count")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_INTEGRAL_INFO, "on_server_leitai_integral_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_WAR_INFO, "on_server_leitai_war_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONE_CHALLENGE_SUCCESS_RECORD, "on_server_clone_challenge_success_record")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_SYSINFO, "on_server_sns_msg_sysinfo")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_SEARCH_FRIEND_RESULT, "on_sns_search_friend_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_ENEMY_INFO_RESULT, "on_sns_enemy_info_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_PLAYERINFO_RESULT, "on_sns_player_info_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_FEED, "on_server_sns_msg_feed")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_SEND_PRESENT_RESULT, "on_sns_send_present_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHITCHAT_SEND_CONTENT_RESULT, "on_chitchat_send_content_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GROUPCHAT_SEND_CONTENT_RESULT, "on_groupchat_send_content_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHITCHAT_SEND_GROUP_CONTENT_RESULT, "on_chitchat_send_group_content_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHITCHAT_REQUEST_CHAT_RESULT, "on_chitchat_request_chat_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHITCHAT_GET_PLAYER_INFO, "on_chitchat_get_player_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_ACCPECT_PRESENT_RESULT, "on_sns_accpect_present_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_SEND_QIFU_RESULT, "on_sns_send_qifu_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_ACCPECT_QIFU_RESULT, "on_sns_accpect_qifu_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_SEND_OKEY_RESULT, "on_sns_send_okey_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_RELATION_ADD_APPLY, "custom_show_relation_add_apply")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_INTERACTIVE_MSG, "on_custom_interact_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEW_PLAYER_GUID, "on_new_player_guid")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_SCHOOLWAR_DEAD_FORM_MSG, "on_custom_open_schoolwar_dead_form")
  nx_callback(chander, "on_" .. SERVER_CUTTOMMSG_UP_PUBLICPOINT_MSG, "on_custom_updata_worldwar_publicpoint")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BRIBE_PLAY_GAME, "on_bribe_play_game_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HOME_POINT, "on_home_point_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GMCC, "on_recive_gmcc_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOWMESSAGEBOX, "on_custom_show_public_msgbox")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOWINPUTBOX, "on_custom_show_public_inputbox")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_MSG, "on_custom_school_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_HOMEPOINT_MSG, "on_custom_school_homepoint_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_UNENTHRALL, "on_custom_unenthrall_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ADJUST_OBJ_ANGLE, "on_custom_adjust_obj_angle")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_POP_REPAIR_DLG, "on_pop_repair_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_POP_REPAIR_ADDBAG, "on_pop_repair_addbag")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_FIGHT_FORM, "on_open_fight_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_UPDATE_FREE_FIGHT_RANK, "on_update_free_fight_rank")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_END_FREE_FIGHT_RANK, "on_end_free_fight_rank")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_SHORTCUT_KEY_FORM, "on_open_shortcut_key_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_HEAD_TALK, "on_npc_head_talking")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_HELPER_FORM, "on_open_helper_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEITAI_CLOSE_TIME_PANEL, "on_close_leitai_time_panel")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BUFFER, "on_buffer_change")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SOLE_PROMPT, "on_show_sole_prompt")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CAN_USE_SKILL, "on_can_use_skill")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_FACTION, "on_show_faction")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_AUTO_EQUIP_SHOTWEAPON, "on_auto_equip_shotweapon")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEWNEIGONGPK, "on_recive_newneigongpk_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_XITIE, "on_open_xietie_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SYSTEM_FRIENDS, "on_recive_systemfriends_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RESULT_GIFT_TO_NPC, "on_recive_ruselt_gifttonpc_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TABLE_MSGINFO, "on_table_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ARREST_WARRANT, "on_arrest_warrant")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_VOTE, "on_school_vote_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REFRESH_CLIENT_NPC, "on_refresh_client_npc")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ZHENFA_LIEZHEN, "on_zhenfa_liezhen")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BOSS_CALL_HELP, "on_boss_call_help")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CPF_HELPER, "on_cpf_helper")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_QS_HELPER, "on_qs_helper")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_FRESHMAN_HELP, "on_open_freshman_help")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_VERSION_NOMATCHE, "on_version_nomatch")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PARSER_CUSTOMIZING, "on_parser_customizing")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FRESHMAN_OPEN_HELP_INFO, "on_freshman_open_help_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BUY_CAPITAL, "on_buy_captal_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FIGHT_ERROR_SYSINFO, "on_fight_error_sysinfo")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_START_CHECK_APPEARANCE, "on_check_appearance")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_SKILLITEM_FORM, "on_close_skillitem_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SERVER_ID, "on_server_id")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LOGIN_ACCOUNT, "on_login_account")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LOGIN_ACCOUNT_ID, "on_login_account_id")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONE_COL_END, "on_open_clone_col_award")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BOSS_STRENGTH_CHANGE, "on_boss_strength_change")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_QUERY_ROLE, "custom_npc_query_role")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MULTIRIDE, "on_multi_ride")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CONFIRM_TVT_GIVEUP, "on_custom_request_sure_dialog_model")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ROB_PRISON, "on_custom_rob_prison")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DARE_SCHOOL_TASK, "on_dare_school_task")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHECK_SECOND_WORD, "on_check_second_word")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_DRAMA, "on_begin_drama")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MINIGAME_WQ_IS_LOOK, "on_minigame_wq_is_look")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_SINGLE_LIMIT, "on_open_single_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_SINGLE_LIMIT, "on_close_single_limit_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ADVE_SUMMON_REQUEST, "on_adve_summon_request")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MOBILE_COMFIRM_MSG, "on_mobile_comfirm")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_KAPAI_MSG, "on_kapai_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_PRIZE_CODE_MSG, "on_open_prize_code")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_KEEP_ITEM, "on_keep_item")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_INTRODUCE, "on_open_school_introduce")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JOIN_SCHOOL, "on_join_school_movie")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_EQUIP_BLEND_MSG, "on_open_equip_blend")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REFRESH_HUANPI_BLEND, "on_refresh_huanpi_blend")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DELETE_HUANPI_BLEND, "on_delete_huanpi_blend")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EQUIP_BLEND_SUCCESS, "on_equip_blend_success")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_SHOW, "on_npc_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_GIFT_CODE_MSG, "on_open_gift_code")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_YYTASK_CODE_MSG, "on_open_yytask_code")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TVT_PROMPT, "on_server_tvt_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PET_SABLE, "on_process_pet_sable")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SABLE_SKILL, "on_open_sable_sikll")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_YUFENG_HANDLE, "on_yufeng_hold_power")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHECK_SWITCH_ENABLE, "on_open_check_switch_enable")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JIUYINZHI_CALLBACK, "on_jyz_sever_msg_handle")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JIUYINZHI_HIGH_LIGHT, "on_jyz_high_light_btn")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JIUYINZHI_MAP_ICON, "on_jyz_map_icon_state")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TRIGGER_DEBUG_SHOW, "on_trigger_debug_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_QUERY_FRESH_MAN, "on_query_fresh_man")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_HOLIDAY_ACTIVE, "custom_open_holiday_active")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_USE_TONIC, "on_use_tonic")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JINGMAI, "custom_jingmai_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GAMBLE, "on_gamble_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OFFLINE_ACCOST, "custom_accost")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SWEET_EMPLOY, "custom_sweet_employ")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BOX_EVENT, "custom_box_event")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TREASURE_CHEST, "custom_treasure_chest")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SWEETEMPLOY_ITEM, "on_sweet_pet_equip")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_AVENGE, "custom_avenge")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_CONTRIBUTE, "custom_gongxun_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONESTORE_OPENLIGHT, "custom_clonestore_openlight")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONESTORE_RECEIVE, "custom_clonestore_receive")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONESTORE_SELLED, "custom_clonestore_selled")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONESTORE_RECOOLING, "custom_clonestore_recooling")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONESTORE_PUNISH, "custom_clonestore_punish")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JIANGHU_BOSS, "custom_jianghu_boss_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JIUYINZHI_CURRENT_STEP, "custom_jiuyinzhi_current_step_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JZSJ_QHYC, "custom_jzsj_qhyc")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SSG_SCHOOLMEET, "custom_ssg_schoolmeet")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WXJ_SCHOOLMEET, "custom_wxj_schoolmeet")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DMP_SCHOOLMEET, "custom_dmp_schoolmeet")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLONE_HEAD, "custom_clone_head")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GROUP_PURCHASE, "on_custom_group_purchase")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LOTTERY, "on_custom_lottery_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SEEK_MINE, "on_custom_seek_mine")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GAME_MATCH, "on_match_msgbox")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HUASHAN, "on_huashan_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ACTIVITY_VALUE_RANK_PRIZE, "on_activity_value_rank_prize_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_DISGUISE, "on_custom_open_disguise")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_QINGGONG_USE_FAILED, "custom_qinggong_use_failed")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_POWER_REDEEM_NUM, "on_custom_get_power_redeem_num")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_OLD_REDDDM_NUM, "on_custom_get_old_redeem_num")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_NOVICE_REDDDM_NUM, "on_custom_get_novice_redeem_num")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TEACHER_PUPIL, "on_teacher_pupil_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_RECAST_EQUIP, "custom_recastattribute_randprop_open")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EQUIPRANDPROP_RESULT, "custom_recastattribute_randprop_succeed")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EQUIPRANDPROP_FINISH, "custom_recastattribute_sure")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MARRY, "custom_marry")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PRESENT_TO_NPC, "on_present_to_npc")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SINGLE_PLAYER_MODULE_INFO, "custom_single_player_module_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_NAME_MODIFY_UI, "open_name_modify_ui")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NPC_POS, "on_map_dynamic_object_pos")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RECONNECT_SERVER, "custom_reconnect_server")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RECONNECT_NORMAL_SERVER, "custom_reconnect_noraml_server")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DONGFANG, "on_dongfang_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MODIFY_BINGLU, "on_modify_binglu_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EGG_GETITEM, "on_egg_get_item")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STAR_MSG, "on_star_show")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PLATE_AWARD, "on_plate_award")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_FORM, "on_show_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WEATHERSKY, "on_weather_sky")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HOME, "on_home_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOLPOSE_PROMPT, "on_recive_schoolpose_prompt")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REVENGE, "on_revenge_match")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WHACK_INFO, "on_whack_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EGWAR, "on_egwar_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DAY_DIVINE, "on_msg_day_divine")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REGISTER, "on_register_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORGET_SKILL, "on_forget_skill")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WEATHER_WAR, "on_weather_war_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_EXTRA_SKILL, "on_extra_skill_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_COPY_SKILL, "on_copy_skill_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CONDITION_DETAILS, "on_condition_details")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORCE_MAKE_ITEM, "on_make_item")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TAOHUA_MAZE, "on_taohua_maze")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PACKAGE_DESTROYED, "on_custom_package_destroyed")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORCE_ACTIVITY, "on_force_activity")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEW_SCHOOL_TRENDS, "on_new_school_trends")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TAOHUA_MASSES_FIGHT, "on_taohua_masses_fight")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RESETFACE_SUCCEED, "on_resetface_succeed")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GAME_RPS_RES, "on_rpg_game_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CUSTOM_EQUIP_NAME, "on_custom_equip_name")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CUSTOM_EQUIP_SUCCEED, "on_custom_equip_name_succ")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PIKONGZHANG_ACTIVITY, "on_custom_pikongzhang_activity")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_TERSURE_MAX_VALUE, "on_custom_show_tersuer_max_value")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_TERSURE_RESULT, "on_custom_show_tersuer_result")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_UPDATE_TERSURE_UPGRADE, "on_custom_update_tersure_upgrade")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHOW_TERSURE, "on_custom_show_tersure")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ITEMEXCHANGE, "on_custom_itemexchange")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_CHECK_JJ_FORM, "on_custom_open_check_jj_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GOUHUO, "on_xjz_gouhuo")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MUSICAL_NOTE, "on_musical_note")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JIAHUO, "on_xjz_jiahuo")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHAOKAO, "on_xjz_shaokao")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ROUND_TASK, "on_custom_round_task")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SETPLAYERCAMERA, "on_set_player_camera")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_CHECK_PLAYER_FORM, "on_open_check_player_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEAVE_SCHOOL, "on_leave_school")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WORLD_BOSS_DEMAGE_STAT, "on_open_world_boss_demage_stat")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NLB_SHIMEN_FORM, "on_open_nlb_shimen_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SJY_SCHOOL_MEET, "on_open_sjy_shimen_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_XMG_SCHOOL_MEET, "on_open_xmg_shimen_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_INTRO_CLOSE, "on_close_school_introduce_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_LEAVE_SCHOOL_INFO, "on_get_leave_school_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CLOSE_SCENE, "simulate_close_scene")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MATCH_DATA, "on_server_custommsg_match_data")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GET_ORIGIN_SUCCEED, "get_origin_succeed")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_ADDBTN_LEAD, "on_addbtn_lead_info_open")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_INTERACTIVE_FURNITURE, "on_interactive_furniture")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_QUESTION_MSG, "on_question_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RANDOM_QUESTION_MSG, "on_random_question_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHECK_AFK_QUESTION_MSG, "on_check_afk_question_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DEPOT_MSG, "on_depot_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HOME_DEPOT_MSG, "on_home_depot_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HOME_GOUHUO_MSG, "on_home_gouhuo_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_INV_RANK_INFO, "on_inv_rank_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TRANS_SERVER_LIST, "on_trans_server_list")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PUSH_BOX_GAME, "on_push_box")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FLASH_WINDOW, "on_flash_window")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ACTIVITY_PARTNER, "on_activity_partner")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BEGIN_SCENE_COMPETE, "on_custom_begin_scene_compete")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CONSUME_BACK, "on_consume_back_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LANTERN, "on_use_lantern_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BODYGUARDOFFICE, "on_bodyguardoffice_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_SHOP_EXCHANGE_FORM, "on_open_shop_exchange_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CALL_HELPER, "on_call_helper_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_SWAP_GOODS_FORM, "on_open_swap_goods_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WUJI_HELPER, "on_wuji_helper")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCENE_JHPK, "on_open_scene_jhpk")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JIANGHU_GOUHUO, "on_jianghu_gouhuo_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JH_AWARD, "on_jianghu_award_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CARD, "on_card_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUMU_RESCUE, "on_gumu_rescue_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FIND_WATER, "on_find_water_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_NEW_BAG, "open_new_bag")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OLD_TO_NEW_ITEM, "oldbag_to_newbag1")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FORM_INTERFACE, "on_form_interface")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SWORN, "on_sworn")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ANCIENTTOMB, "on_ancienttomb")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HUASHANSCHOOL, "on_huashan_school")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TGROLL_GAME, "on_tg_roll_game")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WORLD_AUCTION, "on_world_auction")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_AGREE_WAR, "on_agree_war")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OUTLAND_WAR, "on_outland_war")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_PUZZLE_GAME, "on_server_custommsg_puzzle_game")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JH_EXPLORE, "on_server_custommsg_jh_explore")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NORMAL_PET, "on_normal_pet_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEARN_JINGMAI, "learn_jingmai")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEW_PLAYER_GUID_JHSCENE, "on_jianghu_guide")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEW_SCHOOL_FIGHT, "on_cross_school_fight")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DOUBLE_XIULIAN, "on_double_xiulian_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ACCEPT_FRIEND_LETTER_FLAG, "on_accept_friend_letter_flag")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHANGFENG_MOVETO, "on_changfeng_moveto")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUILD_STATION_ACTIVITY, "on_guild_station_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUILD_CITY_DEF, "on_guild_city_def_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FESTIVAL_SIGN, "on_festival_sign")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DRAW_PRIZE, "on_draw_prize")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DBOMALL_HEAD, "on_dbomall_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JOB_MSG, "on_job_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HUASHAN_JIANBEI, "on_huashan_jianbei_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MANY_REVENGE, "on_many_revenge")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEW_TERRITORY, "on_new_territory_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WEATHERWAR_SWITCH, "on_weather_war_switch")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BODY_CHANGE, "on_body_change")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_STATUE_MSG, "on_statue_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SKILL_SELECT_LIMIT, "on_skill_select_limit")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WUJIDAO, "on_custom_wujidao")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHANGE_BODY_FUSE_BEGIN, "on_change_body_fuse")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_RED_PACKET, "on_redpacket_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FUSE_DAZAOTAI, "on_fuse_dazaotai")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LINXIAO_ZHIZUN, "on_linxiao_zhizun")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REPENT, "on_repent_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SONGJING_GAME, "on_custom_songjing_game")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEWTRESURE_UPDATE, "on_custom_newtresure_update")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_REFRESH_NEWTERSURE_UPGRADE, "on_custom_refresh_newtresure_upgrade")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OUTLAND_EVENT, "on_msg_outland_event")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_OPEN_BINGLU_RECOVER, "on_open_binglu_recover_form")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BADGUY_VALLY_INFO, "on_msg_bad_guy_vally_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ACTIVITY_GUIDE_INFO, "on_msg_activity_guide_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SKY_HILL, "on_sky_hill_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SAN_HILL, "on_san_hill_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SINGLE_SHOP, "on_single_shop_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_YANMEN_BAZHENTU, "on_msg_yanmen_bazhentu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHIJIA_CHENGJIU, "on_msg_shijia_achievement_info")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SCHOOL_EXTINCT, "on_school_extinct")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SHIJIA_MSG, "on_msg_shijia_trans")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_FF_ACTIVITY, "on_msg_shijia_play_time")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MATCH_SANMENG, "on_msg_match_sanmeng")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_AUCTION_MSG, "on_msg_auction")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_YANWU_MATCH_WEAPON, "on_msg_shijia_yanwu")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUILD_LUCK_PRAY, "on_guild_luck_pray")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_MAP_NPC_ICON, "on_map_npc_icon_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEW_TEACHER_NOTICE, "on_new_teacher_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEWSCHOOL, "on_betray_school_confirm")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SELECT_SHCOOL, "on_select_school_confirm")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUPU_LEARN, "custom_gupu_learn")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ROYAL_TREASURE, "on_royal_treasure")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_BALANCE_WAR, "on_balance_war_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WUDAO_WAR, "on_wudao_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LUAN_DOU, "on_luandou_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TAOSHA, "on_taosha_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_APEX, "on_apex_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SEE, "on_see_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SNS_NEWS, "on_sns_news")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HOME_FARM, "on_home_farm")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_HOME_MINE, "on_home_mine")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_JIUYANG_FACULTY, "on_handle_jyf")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_SIGN_N_DRAW, "on_custom_sign_n_draw")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ONLINE_PURCHASE_REBATE, "on_custom_online_purchase_rebate")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_GUILD_GLOBAL_WAR_MSG, "on_custom_guildglobalwar")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CROSS_STATION_WAR_MSG, "on_cross_station_war_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_LEAGUE_MATCHES, "on_league_matches_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHAMPION_WAR_MSG, "on_champion_war_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_TAROT, "on_tarot_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_WUDAO_YANWU, "on_wudao_yanwu_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ACTIVITY_HORSE_RACE, "on_activity_horse_race_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_DAY_RED_PACKET, "on_tj_redpacket")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CHECK_DELETE_FORCE, "on_custom_check_delete_force")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEW_PACKET, "on_custom_newpacket")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_ACCOUNT_LOG, "custom_receive_record_account_log")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_VER_201904, "on_custom_ver_201904")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_CROSS_SERVER, "on_cross_server_msg")
  nx_callback(chander, "on_" .. SERVER_CUSTOMMSG_NEW_WAR_RULE, "on_msg_new_war_rule")
  return 1
end
function custom_receive_record_account_log(chander, arg_num, msg_type, ...)
  util_auto_show_hide_form("haiwai\\haiwai_duihuan")
end
function on_new_player_guid(chander, arg_num, msg_type, transfer_type, ...)
  if "juqi_fei_help" == nx_string(transfer_type) then
    local effect_jingmai = nx_value("EffectJingMai")
    if not nx_is_valid(effect_jingmai) then
      return
    end
    effect_jingmai.help_info = true
    local time_count = 0
    local scene = nx_value("game_scene")
    if not nx_is_valid(scene) then
      return
    end
    local game_control = scene.game_control
    local role = util_get_role_model()
    local angle_y = role.AngleY
    game_control.Distance = 3.498071
    game_control.YawAngle = nip_radian(angle_y)
    game_control.PitchAngle = 0.27
    while time_count < 3 do
      time_count = time_count + nx_pause(0)
    end
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string(transfer_type), "1", unpack(arg))
  else
    local time_count = 0
    while time_count < 0.5 do
      time_count = time_count + nx_pause(0)
    end
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string(transfer_type), "1", unpack(arg))
  end
  return 0
end
function do_lock_effect(chander, arg_num, msg_type, self_id, target_id, skill)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local ident = nx_string(self_id)
  local self = game_visual:GetSceneObj(ident)
  ident = nx_string(target_id)
  local target = game_visual:GetSceneObj(ident)
  if not nx_is_valid(self) then
    return 0
  end
  local self_x = self.PositionX
  local self_y = self.PositionY
  local self_z = self.PositionZ
  local self_angle_y = self.AngleY
  if not nx_is_valid(target) then
    target = self
  end
  local target_x = target.PositionX
  local target_y = target.PositionY
  local target_z = target.PositionZ
  local target_angle_y = target.AngleY
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DO_LOCK_EFFECT), nx_object(self_id), nx_float(self_x), nx_float(self_y), nx_float(self_z), nx_float(self_angle_y), nx_object(target_id), nx_float(target_x), nx_float(target_y), nx_float(target_z), nx_float(target_angle_y), nx_object(skill))
  return 1
end
function custom_scene_obj_action(chander, arg_num, msg_type, obj_id, action, loop)
  local game_client = nx_value("game_client")
  console_log("SERVER_CUSTOMMSG_ACTION " .. nx_string(msg_type) .. " action  =" .. action)
  local ident = nx_string(obj_id)
  if game_client:IsPlayer(ident) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  local vis_object = game_visual:GetSceneObj(ident)
  local action_module = nx_value("action_module")
  if nx_number(loop) == 1 then
    action_module:ChangeState(vis_object, action)
  else
    action_module:DoAction(vis_object, action)
  end
  return 1
end
function custom_action(chander, arg_num, msg_type, obj_id, action, bClear)
  local game_client = nx_value("game_client")
  local ident = nx_string(obj_id)
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetSceneObj(ident)
  if not nx_is_valid(role) then
    return false
  end
  local action_module = nx_value("action_module")
  if nx_string(bClear) == "1" then
    action_module:ClearAction(role)
  end
  action_module:DoAction(role, nx_string(action))
  return 1
end
function custom_scene_obj_jump(chander, arg_num, msg_type, obj_id, action)
  local game_client = nx_value("game_client")
  local ident = nx_string(obj_id)
  if game_client:IsPlayer(ident) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetSceneObj(ident)
  if not nx_is_valid(role) then
    return false
  end
  local action_module = nx_value("action_module")
  action_module:DoAction(role, nx_string(action))
  return 1
end
function custom_specific_sysinfo(chander, arg_num, msg_type, tips_type, string_id, ...)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(nx_string(string_id))
  for i, para in pairs(arg) do
    local type = nx_type(para)
    if type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    elseif type == "widestr" then
      gui.TextManager:Format_AddParam(para)
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  local info = gui.TextManager:Format_GetText()
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local form_main_chat_logic = nx_value("form_main_chat")
  if not nx_is_valid(form_main_chat_logic) then
    return
  end
  local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
  if not nx_is_valid(form_main_sysinfo_logic) then
    return
  end
  if tips_type == TIPSTYPE_SYSTEMINFO then
    form_main_sysinfo_logic:AddSystemInfo(info, 0, 0)
    form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
  elseif tips_type == TIPSTYPE_SYSTEMNO then
    form_main_sysinfo_logic:AddSystemInfo(info, SYSTYPE_SYSTEM, 0)
  elseif tips_type == TIPSTYPE_TIPSINFO then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
  elseif tips_type == TIPSTYPE_PERSONAL then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL)
    end
  elseif tips_type == TIPSTYPE_WORLDINFO then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_WORLD)
    end
  elseif tips_type == TIPSTYPE_FIGHTINFO then
    form_main_sysinfo_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function explain_info(tips_type, string_id)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local gui = nx_value("gui")
  local list = util_split_string(string_id, "|")
  local counts = table.getn(list)
  local info = nx_widestr("")
  local isfirst = false
  if tips_type == TIPSTYPE_TASKINFO then
    for n = 1, counts do
      local id, num, icon
      if nil ~= list[n] and list[n] ~= "" then
        id = list[n]
        local temp = util_split_string(id, ",")
        if table.getn(temp) == 2 then
          if nil ~= temp[1] and nil ~= temp[2] then
            id = temp[1]
            gui.TextManager:Format_SetIDName(id)
            gui.TextManager:Format_AddParam(nx_int(temp[2]))
          end
        elseif table.getn(temp) == 3 and nil ~= temp[1] and nil ~= temp[2] and nil ~= temp[3] then
          id = temp[1]
          gui.TextManager:Format_SetIDName(id)
          gui.TextManager:Format_AddParam(gui.TextManager:GetText(temp[2]))
          gui.TextManager:Format_AddParam(nx_int(temp[3]))
        end
        if not isfirst then
          isfirst = true
          info = nx_widestr("<center>") .. gui.TextManager:Format_GetText() .. nx_widestr("</center>|")
        else
          info = info .. nx_widestr("<center>") .. gui.TextManager:Format_GetText() .. nx_widestr("</center>|")
        end
      end
    end
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_TASK)
    end
    return true
  elseif tips_type == TIPSTYPE_RESINFO then
    for n = 1, counts do
      local id, photo
      if nil ~= list[n] and list[n] ~= "" then
        id = list[n]
        local temp = util_split_string(id, ",")
        if nil ~= temp[1] and nil ~= temp[2] then
          id = temp[1]
          config_id = temp[2]
          local item_query = nx_value("ItemQuery")
          local name
          if item_query:FindItemByConfigID(config_id) then
            photo = item_query_ArtPack_by_id(config_id, "Photo")
          end
          gui.TextManager:Format_SetIDName(config_id)
          name = gui.TextManager:Format_GetText()
          gui.TextManager:Format_SetIDName(id)
          gui.TextManager:Format_AddParam(name)
          gui.TextManager:Format_AddParam(nx_int(temp[3]))
        end
        if not isfirst then
          isfirst = true
          info = nx_widestr(photo) .. nx_widestr(",") .. gui.TextManager:Format_GetText() .. nx_widestr("|")
        else
          info = info .. nx_widestr(photo) .. nx_widestr(",") .. gui.TextManager:Format_GetText() .. nx_widestr("|")
        end
      end
    end
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_RES)
    end
    return true
  elseif tips_type == TIPSTYPE_TEXTINFO then
    for n = 1, counts do
      local id = list[n]
      info = nx_widestr(info) .. nx_widestr("<center>") .. gui.TextManager:GetFormatText(id) .. nx_widestr("</center>|")
    end
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_TASK)
    end
    return true
  end
  return false
end
local PromptKeysTable = {
  [1] = {
    stringid = "19095",
    key = "prompt_guild_login",
    defval = "1"
  },
  [2] = {
    stringid = "19096",
    key = "prompt_guild_logout",
    defval = "1"
  },
  [3] = {
    stringid = "87300",
    key = "prompt_friend_login",
    defval = "1"
  },
  [4] = {
    stringid = "87307",
    key = "prompt_friend_logout",
    defval = "1"
  },
  [5] = {
    stringid = "87301",
    key = "prompt_friend_login",
    defval = "1"
  },
  [6] = {
    stringid = "87308",
    key = "prompt_friend_logout",
    defval = "1"
  },
  [7] = {
    stringid = "87302",
    key = "prompt_attent_login",
    defval = "1"
  },
  [8] = {
    stringid = "87309",
    key = "prompt_attent_logout",
    defval = "1"
  }
}
function prompt_is_valid(stringid)
  local game_config_info = nx_value("game_config_info")
  for i = 1, table.getn(PromptKeysTable) do
    if nx_string(stringid) == nx_string(PromptKeysTable[i].stringid) then
      local value = util_get_property_key(game_config_info, PromptKeysTable[i].key, PromptKeysTable[i].defval)
      if nx_string(value) == nx_string("0") then
        return false
      end
    end
  end
  return true
end
function custom_sysinfo(chander, arg_num, msg_type, tips_type, string_id, ...)
  local loading_form = nx_value("form_common\\form_loading")
  if nx_is_valid(loading_form) and loading_form.Visible then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not prompt_is_valid(string_id) then
    return
  end
  explain_info(tips_type, string_id)
  if nx_int(string_id) >= nx_int(9000) and nx_int(string_id) < nx_int(9500) then
    nx_execute("form_test\\form_fight_error_info", "server_add_fight_error_info", string_id)
  end
  if tips_type == TIPSTYPE_TIPSINFO and string_id == "1400" and arg[1] ~= nil then
    local view_name = nx_string(arg[1])
    string_id = "1400_" .. view_name
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_number(tips_type) == nx_number(1) and nx_string(string_id) == nx_string("37031") and table.getn(arg) == nx_number(4) and (nx_string(arg[1]) == nx_string("item_avenge_use01") or nx_string(arg[1]) == nx_string("item_avenge_use02") or nx_string(arg[1]) == nx_string("item_avenge_use03") or nx_string(arg[1]) == nx_string("item_avenge_use04") or nx_string(arg[1]) == nx_string("item_avenge_use05") or nx_string(arg[1]) == nx_string("item_avenge_use06") or nx_string(arg[1]) == nx_string("item_avenge_usenpc01") or nx_string(arg[1]) == nx_string("item_avenge_usenpc02")) then
    local item_config = arg[1]
    gui.TextManager:Format_SetIDName(item_config)
    gui.TextManager:Format_AddParam(arg[2])
    gui.TextManager:Format_AddParam(arg[3])
    item_config = gui.TextManager:Format_GetText()
    gui.TextManager:Format_SetIDName(string_id)
    gui.TextManager:Format_AddParam(item_config)
    gui.TextManager:Format_AddParam(nx_int(arg[4]))
  elseif nx_number(tips_type) == nx_number(TIPSTYPE_GUILD_REQ_HELP) and nx_string(string_id) == nx_string("info_guild_qzl") and table.getn(arg) == nx_number(9) then
    local name = nx_widestr(arg[1])
    local name2 = nx_widestr("[") .. nx_widestr(arg[1]) .. nx_widestr("]:")
    local scene_id = get_scene_id_by_name(arg[2])
    local area = util_text(arg[3])
    local x = nx_int(arg[4])
    local z = nx_int(arg[5])
    local player_name = name
    local uid = arg[7]
    local trans_cost = arg[8]
    local trans_cd_time = arg[9]
    gui.TextManager:Format_SetIDName(string_id)
    gui.TextManager:Format_AddParam(name)
    gui.TextManager:Format_AddParam(name2)
    gui.TextManager:Format_AddParam("")
    gui.TextManager:Format_AddParam(scene_id)
    gui.TextManager:Format_AddParam(area)
    gui.TextManager:Format_AddParam(x)
    gui.TextManager:Format_AddParam(z)
    gui.TextManager:Format_AddParam(player_name)
    gui.TextManager:Format_AddParam(uid)
    gui.TextManager:Format_AddParam(trans_cost)
    gui.TextManager:Format_AddParam(trans_cd_time)
  elseif nx_number(tips_type) == nx_number(TIPSTYPE_TEAM_DROP) then
    if nx_string(string_id) == nx_string("ui_drop_item") then
      local player_name = nx_widestr(arg[1])
      local npc_config = nx_string(arg[2])
      local item_nums = nx_number(arg[3])
      local new_ui_text = "ui_drop_item_" .. nx_string(item_nums)
      gui.TextManager:Format_SetIDName(new_ui_text)
      gui.TextManager:Format_AddParam(npc_config)
      for i = 1, table.getn(arg) - 3 do
        local str_item_info = nx_string(arg[i + 3])
        local item_info = util_split_string(str_item_info, ",")
        local item_config = nx_string(item_info[1])
        local item_amount = nx_int(item_info[2])
        local item_bind = nx_int(item_info[3])
        gui.TextManager:Format_AddParam("config:" .. item_config)
        gui.TextManager:Format_AddParam(item_amount)
        gui.TextManager:Format_AddParam(item_bind)
        gui.TextManager:Format_AddParam(item_config)
      end
    end
  else
    gui.TextManager:Format_SetIDName(string_id)
    for i, para in pairs(arg) do
      local type = nx_type(para)
      if type == "number" then
        gui.TextManager:Format_AddParam(nx_int(para))
      elseif type == "string" then
        gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
      elseif type == "widestr" then
        gui.TextManager:Format_AddParam(para)
      else
        gui.TextManager:Format_AddParam(para)
      end
    end
  end
  local info = gui.TextManager:Format_GetText()
  if tips_type == TIPSTYPE_GMINFO then
    local form_gm_command = nx_value("form_test\\form_gm_command")
    if nx_is_valid(form_gm_command) then
      form_gm_command.ListBox:AddString(info)
      nx_execute("form_test\\form_gm_command", "add_to_file", form_gm_command, info)
      while form_gm_command.ListBox.ItemCount > 500 do
        form_gm_command.ListBox:RemoveByIndex(0)
      end
      form_gm_command.ListBox.VScrollBar.Value = form_gm_command.ListBox.VScrollBar.Maximum - 1
    end
    return
  elseif tips_type == TIPSTYPE_DEBUGLOG then
    nx_function("ext_append_write_file", "", "server_child_obj.ini", nx_string(info) .. "\n")
    return
  elseif tips_type == TIPSTYPE_TVT_MENPAIZHAN then
    nx_execute("form_stage_main\\form_school_fight\\form_school_fight_message", "add_content_by_id", string_id, info)
  end
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_main", "agree_war_sys", string_id, unpack(arg))
  local form_main_chat_logic = nx_value("form_main_chat")
  if not nx_is_valid(form_main_chat_logic) then
    return
  end
  local form_general_info_logic = nx_value("form_main_general_info_logic")
  if not nx_is_valid(form_general_info_logic) then
    return
  end
  local form_sysinfo_logic = nx_value("form_main_sysinfo")
  if not nx_is_valid(form_sysinfo_logic) then
    return
  end
  local use_channel = false
  local sysinfosort = nx_value("SysInfoSort")
  if nx_is_valid(sysinfosort) then
    local channels = sysinfosort:FindSysInfoStylesByID(string_id)
    use_channel = table.getn(channels) > 0
    for _, channel_type in ipairs(channels) do
      if nx_int(channel_type) == nx_int(1) then
        if nx_is_valid(SystemCenterInfo) then
          if tips_type == TIPSTYPE_MARRYINFO then
            SystemCenterInfo:ShowSystemCenterInfoEx(info, "gui\\mainform\\bg_system_2_1.png", CENTERINFO_WORLD)
          elseif tips_type == TIPSTYPE_NPC_CONTRIBUTE then
            SystemCenterInfo:ShowSystemCenterInfoEx(info, "gui\\mainform\\bg_system_2_4.png", CENTERINFO_WORLD)
          else
            SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_WORLD)
          end
        end
      elseif nx_int(channel_type) == nx_int(2) then
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
        end
      elseif nx_int(channel_type) == nx_int(3) then
        if msg_type == SERVER_CUSTOMMSG_SYSINFO and tips_type == TIPSTYPE_SYSTEMNO and string_id == "0" and table.getn(arg) == 2 and arg[2] == "/broadcast" then
          local sys_broadcast = gui.TextManager:GetText("ui_sys_broadca")
          info = sys_broadcast .. info
        end
        local photo_info = gui.TextManager:GetText("ui_chat_system")
        local chat_info = photo_info .. info
        form_main_chat_logic:AddChatInfoEx(chat_info, CHATTYPE_SYSTEM, false)
      elseif nx_int(channel_type) == nx_int(4) then
        if tips_type >= TIPSTYPE_TVT_JINDI and tips_type <= TIPSTYPE_TVT_YUNBIAO then
          nx_execute("form_stage_main\\form_main\\form_main_sysinfo", "init_tvt_info_list")
          form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_TVT, tips_type)
        elseif tips_type >= TIPSTYPE_EMOTIONINFO_NPC and tips_type <= TIPSTYPE_EMOTIONINFO_REWARD then
          nx_execute("form_stage_main\\form_main\\form_main_sysinfo", "init_emotion_info_list")
          form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_EMOTION, tips_type)
        else
          form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_SYSTEM, 0)
        end
      elseif nx_int(channel_type) == nx_int(5) then
        form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
      elseif nx_int(channel_type) == nx_int(6) then
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_YES)
        end
      elseif nx_int(channel_type) == nx_int(7) then
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_SNS_FRIEND)
        end
      elseif nx_int(channel_type) == nx_int(8) then
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL)
        end
      elseif nx_int(channel_type) == nx_int(9) then
        if nx_is_valid(form_general_info_logic) then
          form_general_info_logic:AddInfo(string_id, info)
        end
      elseif nx_int(channel_type) == nx_int(10) and nx_is_valid(form_general_info_logic) then
        form_general_info_logic:AddInfo(string_id, info)
      end
    end
  end
  if use_channel then
    return
  end
  if tips_type == TIPSTYPE_SYSTEMINFO then
    if tips_type >= TIPSTYPE_TVT_JINDI and tips_type <= TIPSTYPE_TVT_YUNBIAO then
      nx_execute("form_stage_main\\form_main\\form_main_sysinfo", "init_tvt_info_list")
      form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_TVT, tips_type)
    elseif tips_type >= TIPSTYPE_EMOTIONINFO_NPC and tips_type <= TIPSTYPE_EMOTIONINFO_REWARD then
      nx_execute("form_stage_main\\form_main\\form_main_sysinfo", "init_emotion_info_list")
      form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_EMOTION, tips_type)
    else
      form_sysinfo_logic:AddSystemInfo(info, 0, 0)
    end
    form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
  elseif tips_type == TIPSTYPE_SYSTEMNO then
    if msg_type == SERVER_CUSTOMMSG_SYSINFO then
      local sys_broadcast = gui.TextManager:GetText("ui_sys_broadca")
      info = nx_widestr(sys_broadcast) .. nx_widestr(info)
    end
    if tips_type >= TIPSTYPE_TVT_JINDI and tips_type <= TIPSTYPE_TVT_YUNBIAO then
      nx_execute("form_stage_main\\form_main\\form_main_sysinfo", "init_tvt_info_list")
      form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_TVT, tips_type)
    elseif tips_type >= TIPSTYPE_EMOTIONINFO_NPC and tips_type <= TIPSTYPE_EMOTIONINFO_REWARD then
      nx_execute("form_stage_main\\form_main\\form_main_sysinfo", "init_emotion_info_list")
      form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_EMOTION, tips_type)
    else
      form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_SYSTEM, 0)
    end
  elseif tips_type == TIPSTYPE_PERSONAL then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL)
    end
  elseif tips_type == TIPSTYPE_TIPSINFO then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
  elseif tips_type == TIPSTYPE_WORLDINFO then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_WORLD)
    end
  elseif tips_type == TIPSTYPE_FIGHTINFO then
    form_sysinfo_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  elseif tips_type == TIPSTYPE_NPCTALKINFO then
    gui.TextManager:Format_SetIDName("ui_chat_13")
    if nil ~= arg[1] and nil ~= arg[2] then
      local name = nx_widestr(arg[1])
      if nx_ws_equal(nx_widestr(arg[2]), nx_widestr("BossNpc")) then
        gui.TextManager:Format_SetIDName("ui_chat_14")
      elseif nx_ws_equal(nx_widestr(arg[2]), nx_widestr("FuncNpc")) then
        gui.TextManager:Format_SetIDName("ui_chat_15")
      elseif nx_ws_equal(nx_widestr(arg[2]), nx_widestr("CommonNpc")) then
        gui.TextManager:Format_SetIDName("ui_chat_16")
      elseif nx_ws_equal(nx_widestr(arg[2]), nx_widestr("ConvoyNpc")) then
        gui.TextManager:Format_SetIDName("ui_chat_16")
      elseif nx_ws_equal(nx_widestr(arg[2]), nx_widestr("Monster")) then
        gui.TextManager:Format_SetIDName("ui_chat_17")
      elseif nx_ws_equal(nx_widestr(arg[2]), nx_widestr("CloneScene")) then
        gui.TextManager:Format_SetIDName("ui_chat_13")
      elseif nx_ws_equal(nx_widestr(arg[2]), nx_widestr("AttackNpc")) then
        gui.TextManager:Format_SetIDName("ui_chat_16")
      end
      if nil ~= arg[3] and nx_ws_equal(nx_widestr(arg[3]), nx_widestr("npc_talk")) then
        info = nx_widestr("[") .. name .. nx_widestr("]:") .. info
      elseif nil ~= arg[3] and nx_ws_equal(nx_widestr(arg[3]), nx_widestr("npc_talk_to_palyer")) then
        info = nx_widestr("[") .. name .. nx_widestr("]:") .. string_id
      elseif nil ~= arg[3] and nx_ws_equal(nx_widestr(arg[3]), nx_widestr("player_talk")) then
        info = nx_widestr("[") .. name .. nx_widestr("]:") .. info
        form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
        return
      end
    end
    gui.TextManager:Format_AddParam(info)
    local chat_info = gui.TextManager:Format_GetText()
    form_main_chat_logic:AddChatInfoEx(chat_info, CHATTYPE_SYSTEM, false)
  elseif tips_type == TIPSTYPE_MARRYINFO then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfoEx(info, "gui\\mainform\\bg_system_2_1.png", CENTERINFO_WORLD)
    end
  elseif tips_type == TIPSTYPE_EASTSEAGUILD_WORLD then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfoEx(info, "gui\\mainform\\bg_system_2_2.png", CENTERINFO_WORLD)
    end
  elseif tips_type == TIPSTYPE_EASTSEAGUILD_PERSONAL then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfoEx(info, "gui\\mainform\\bg_system_2_3.png", CENTERINFO_WORLD)
    end
  elseif tips_type == TIPSTYPE_NPC_CONTRIBUTE then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfoEx(info, "gui\\mainform\\bg_system_2_4.png", CENTERINFO_WORLD)
    end
  elseif tips_type == TIPSTYPE_GMINFO then
    local form_gm_command = nx_value("form_test\\form_gm_command")
    if nx_is_valid(form_gm_command) then
      form_gm_command.ListBox:AddString(info)
      nx_execute("form_test\\form_gm_command", "add_to_file", form_gm_command, info)
      while form_gm_command.ListBox.ItemCount > 500 do
        form_gm_command.ListBox:RemoveByIndex(0)
      end
      form_gm_command.ListBox.VScrollBar.Value = form_gm_command.ListBox.VScrollBar.Maximum - 1
    end
  elseif tips_type == TIPSTYPE_DEBUGINFO then
    form_sysinfo_logic:AddSystemInfo(info, 0, 0)
  elseif tips_type == TIPSTYPE_GUILD_REQ_HELP then
    local photo_info = gui.TextManager:GetText("ui_chat_system")
    local chat_info = photo_info .. info
    form_main_chat_logic:AddChatInfoEx(chat_info, CHATTYPE_GUILD, false)
  elseif tips_type == TIPSTYPE_TEAM_DROP then
    local player_name = nx_widestr(arg[1])
    if nx_execute("form_stage_main\\form_main\\form_main_team", "is_in_team_large") then
      local photo_info = util_format_string("ui_chat_team_large_image", player_name)
      local chat_info = photo_info .. info
      form_main_chat_logic:AddChatInfoEx(chat_info, CHATTYPE_TEAM, false)
    else
      local photo_info = util_format_string("ui_chat_team_image", player_name)
      local chat_info = photo_info .. info
      form_main_chat_logic:AddChatInfoEx(chat_info, CHATTYPE_ROW, false)
    end
  end
  return 1
end
function custom_asyn_time(chander, arg_num, msg_type, server_time)
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    game_client.server_asyn_time = server_time
  end
end
function custom_beginmenu(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_talk_data", "on_beginmenu")
  return 1
end
function custom_addtitle(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_talk_data", "on_addtitle", unpack(arg))
  return 1
end
function custom_addmenu(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_talk_data", "on_addmenu", unpack(arg))
  return 1
end
function custom_endmenu(chander, arg_num, msg_type, target)
  nx_execute("form_stage_main\\form_talk_data", "on_endmenu", target)
  return 1
end
function custom_closemenu(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_talk_data", "on_closemenu")
  return 1
end
function custom_effect(chander, arg_num, msg_type, target, effecttype, ...)
  local ident = nx_string(target)
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    return
  end
  if effecttype == "HP" then
    nx_execute("custom_effect", "custom_effect_dechp", ident, arg[1], nx_string(arg[2]), false)
  elseif effecttype == "VAHP" then
    nx_execute("custom_effect", "custom_effect_dechp", ident, arg[1], nx_string(arg[2]), true)
  elseif effecttype == "HITBACK" then
    local src = nx_string(arg[1])
    local bfailed = nx_number(arg[2]) == 0
    local locktime = arg[3]
    local x = arg[4]
    local z = arg[5]
    nx_execute("custom_effect", "custom_hitback", src, ident, bfailed, locktime, x, z)
  elseif effecttype == "ESCAPE" then
    local name = nx_string(arg[1])
    local open = nx_int(arg[2])
    nx_execute("custom_effect", "custom_escape_effect", ident, name, open)
  elseif effecttype == "HITDOWN" then
    local src = nx_string(arg[1])
    local bfailed = nx_number(arg[2]) == 0
    local locktime = arg[3]
    nx_execute("custom_effect", "custom_hitdown", src, ident, bfailed, locktime)
  elseif effecttype == "HITOUT" then
    local src = nx_string(arg[1])
    local bfailed = nx_number(arg[2]) == 0
    local locktime = arg[3]
    local x = arg[4]
    local z = arg[5]
    nx_execute("custom_effect", "custom_hitout", src, ident, bfailed, locktime, x, z)
  elseif effecttype == "HITBREAK" then
    local src = nx_string(arg[1])
    local bfailed = nx_number(arg[2]) == 0
    local locktime = arg[3]
    nx_execute("custom_effect", "custom_hitbreak", src, ident, bfailed, locktime)
  elseif effecttype == "MISS" then
    nx_execute("custom_effect", "custom_miss", ident)
  elseif effecttype == "HITS" then
    nx_execute("custom_effect", "custom_effect_hits", ident, arg[1])
  elseif effecttype == "ADDHP" then
    nx_execute("custom_effect", "custom_effect_addhp", ident, arg[1])
  elseif effecttype == "ADDMP" then
    nx_execute("custom_effect", "custom_effect_addmp", ident, arg[1])
  elseif effecttype == "DECMP" then
    nx_execute("custom_effect", "custom_effect_decmp", ident, arg[1])
  elseif effecttype == "ADDEXP" then
    nx_execute("custom_effect", "custom_effect_addexp", ident, arg[1])
  elseif effecttype == "SHOWSKILLNAME" then
    nx_execute("custom_effect", "custom_effect_show_skill_name", ident, arg[1], arg[2])
  elseif effecttype == "LEVELUP" then
    nx_execute("custom_effect", "custom_effect_levelup", ident)
  elseif effecttype == "BORN" then
    nx_execute("custom_effect", "custom_effect_born", ident)
  elseif effecttype == "RECVLETTER" then
    nx_execute("custom_effect", "custom_effect_recv_letter", ident)
  elseif effecttype == "SENDLETTER" then
    nx_execute("custom_effect", "custom_effect_send_letter", ident)
  elseif effecttype == "INTERACTIVE" then
    nx_execute("custom_effect", "custom_effect_interactive", ident, arg[1])
  elseif effecttype == "SPRINGEFFECT" then
    nx_execute("custom_effect", "custom_effect_spring", ident, arg[1])
  elseif effecttype == "COMPOSEEFFECT" then
    nx_execute("custom_effect", "custom_effect_compose", ident, arg[1])
  elseif effecttype == "FIRE" then
    nx_execute("custom_effect", "custom_effect_fire", ident)
  elseif effecttype == "OnceEffect" then
    nx_execute("custom_effect", "custom_effect_once", ident, arg[1])
  elseif effecttype == "DestoryOnceEffect" then
    nx_execute("custom_effect", "custom_destory_effect_once", ident, arg[1])
  elseif effecttype == "AlphaOnceEffect" then
    nx_execute("custom_effect", "custom_alpha_effect_once", ident, arg[1], arg[2])
  elseif effecttype == "OFFLINE" then
    local effect_name = arg[1]
    local be_open = arg[2]
    nx_execute("custom_effect", "custom_effect_offline_ai", ident, effect_name, be_open)
  elseif effecttype == "LEITAI_RANGE" then
    local x = nx_number(arg[1])
    local y = nx_number(arg[2])
    local z = nx_number(arg[3])
    local r = nx_number(arg[4])
    local disp = nx_number(arg[5])
    nx_execute("custom_effect", "custom_effect_show_leitai_range", ident, x, y, z, r, disp)
  elseif effecttype == "CHALLENGE_RANGE" then
    local x = nx_number(arg[1])
    local y = nx_number(arg[2])
    local z = nx_number(arg[3])
    local r = nx_number(arg[4])
    local disp = nx_number(arg[5])
    nx_execute("custom_effect", "custom_effect_show_challenge_range", ident, x, y, z, r, disp)
  elseif effecttype == "CHALLENGE_EFFECT" then
    local x = nx_number(arg[1])
    local y = nx_number(arg[2])
    local z = nx_number(arg[3])
    local r = nx_number(arg[4])
    local type = nx_number(arg[5])
    local srcuid = nx_string(arg[6])
    nx_execute("custom_effect", "custom_challenge_effect_show", ident, x, y, z, r, type, srcuid)
  elseif effecttype == "SKILLCOMPARE" then
    local self_skill_id = nx_string(arg[1])
    local target_skill_id = nx_string(arg[2])
    local self_effect_type = nx_number(arg[3])
    local target_effect_type = nx_number(arg[4])
    local result = nx_string(arg[5])
    nx_execute("custom_effect", "custom_effect_show_compare", target, self_skill_id, target_skill_id, self_effect_type, target_effect_type, result)
  elseif effecttype == "Buffer_hit_effect" then
    local effect_id = nx_string(arg[1])
    local buffer_effect = nx_value("BufferEffect")
    buffer_effect:BufferEffectShowHit(target, effect_id)
  elseif effecttype == "obj_move_12" then
    local x = nx_number(arg[1])
    local y = nx_number(arg[2])
    local z = nx_number(arg[3])
    local scene = nx_value("game_scene")
    local eff = nx_execute("game_effect", "create_eff_model_in_mainscene", scene, "item_duelflag01", x, y, z)
    if nx_is_valid(eff) then
      eff.LifeTime = 5
    end
  elseif effecttype == "SKILL" then
    local stage = arg[1]
    local effect_id = arg[2]
    nx_execute("custom_effect", "custom_do_skill_stage_effect", ident, stage, effect_id)
  end
end
function custom_skill_action_with_tanslate(chander, arg_num, msg_type, self, target, action, lock_time1, lock_time2, x1, y1, z1, o1, dist1, x2, y2, z2, o2, dist2)
  local game_visual = nx_value("game_visual")
  local vis_self = game_visual:GetSceneObj(nx_string(self))
  if not nx_is_valid(vis_self) then
    return
  end
  local vis_target = game_visual:GetSceneObj(nx_string(target))
  vis_self.attack_target = vis_target
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) then
    skill_effect:SkillActionWithTranslate(vis_self, vis_target, action, lock_time1, lock_time2, x1, y1, z1, o1, dist1, x2, y2, z2, o2, dist2)
    return
  end
end
function custom_skill_action(chander, arg_num, msg_type, self, action, skill_target)
  local game_visual = nx_value("game_visual")
  local vis_self = game_visual:GetSceneObj(nx_string(self))
  if not nx_is_valid(vis_self) then
    return
  end
  emit_player_input(vis_self, PLAYER_INPUT_LOGIC, LOGIC_SKILL_ACTION)
  vis_self.zhaoshi_play_target = game_visual:GetSceneObj(nx_string(skill_target))
  nx_execute("skill_effect", "play_skill_action", vis_self, action)
end
function custom_begin_curse(chander, arg_num, msg_type, ticks, curse_text, cursetype)
  if nx_running("custom_effect", "custom_begin_curse") then
    nx_kill("custom_effect", "custom_begin_curse")
  end
  nx_execute("custom_effect", "custom_begin_curse", ticks, nx_string(curse_text), nx_string(cursetype))
end
function custom_end_curse(chander, arg_num, msg_type, msg)
  nx_execute("custom_effect", "custom_end_curse", msg)
end
function custom_adjust_skill_curse(chander, arg_num, msg_type, curse_text, ticks)
  local form = util_get_form("form_stage_main\\form_main\\form_main_fightvs_alone", false)
  if nx_is_valid(form) then
  end
end
function custom_chat(chander, arg_num, msg_type, chat_type, srcname, content, delaytime)
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  if chat_type ~= CHATINFO_OFFLINE then
    local gui = nx_value("gui")
    if chat_type == CHATTYPE_GOSSIP and gui.TextManager:IsIDName(nx_string(srcname)) then
      srcname = gui.TextManager:GetText(nx_string(srcname))
    end
    gui.TextManager:Format_SetIDName("ui_chat_" .. nx_number(chat_type))
    gui.TextManager:Format_AddParam(srcname)
    gui.TextManager:Format_AddParam(content)
    local chat_info = gui.TextManager:Format_GetText()
    if chat_type == CHATTYPE_WHISPER then
    end
    local form_main_chat_logic = nx_value("form_main_chat")
    if nx_is_valid(form_main_chat_logic) then
      if not is_newjhmodule() then
        form_main_chat_logic:AddChatInfoEx(chat_info, chat_type, false)
      elseif form_main_chat_logic:IsJHChannel(chat_type) then
        form_main_chat_logic:AddChatInfoEx(chat_info, chat_type, false)
      end
    end
    if chat_type == CHATTYPE_WHISPER_ECHO then
      nx_execute("form_stage_main\\form_main\\form_main_chat", "add_name_to_private_chat_list", srcname)
    end
  end
  if chat_type == CHATTYPE_VISUALRANGE or chat_type == CHATINFO_OFFLINE then
    local client_chat_obj = nx_execute("util_functions", "util_find_client_player_by_name", srcname)
    if client_chat_obj ~= nil and nx_is_valid(client_chat_obj) then
      if delaytime == nil or delaytime == "" or delaytime == 0 then
        head_game:ShowChatTextOnHead(client_chat_obj, nx_widestr(content), 5000)
      else
        head_game:ShowChatTextOnHead(client_chat_obj, nx_widestr(content), delaytime)
      end
    end
  elseif chat_type == CHATTYPE_MOVIE then
    local client_chat_obj = nx_execute("util_functions", "util_find_client_player_by_name", srcname)
    if client_chat_obj ~= nil and nx_is_valid(client_chat_obj) then
      local gui = nx_value("gui")
      local wide_str = gui.TextManager:GetText(nx_string(content))
      if delaytime == nil or delaytime == "" or delaytime == 0 then
        head_game:ShowChatTextOnHead(client_chat_obj, nx_widestr(wide_str), 5000)
      else
        head_game:ShowChatTextOnHead(client_chat_obj, nx_widestr(wide_str), delaytime)
      end
    end
  end
end
function open_task_not_complete_info(chander, arg_num, msg_type, task_id, npc, rec_id)
  local gui = nx_value("gui")
  local form_talk = nx_value("form_stage_main\\form_talk")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_talk", "clear_data")
    nx_execute("form_stage_main\\form_talk", "clear_control")
  else
    form_talk = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_talk", true)
  end
  form_talk.talk_list:Clear()
  form_talk.opentype = 6
  form_talk.taskid = task_id
  form_talk.recid = rec_id
  form_talk.npcid = nx_string(npc)
  local game_client = nx_value("game_client")
  while true do
    nx_pause(0)
    if not nx_is_valid(form_talk) then
      return
    end
    local client_scene_obj = game_client:GetSceneObj(nx_string(npc))
    if nx_is_valid(client_scene_obj) then
      local string_id = client_scene_obj:QueryProp("ConfigID")
      local npc_name = gui.TextManager:GetText(nx_string(string_id))
      form_talk.name_label.Text = npc_name
      local photo_head = tostring(client_scene_obj:QueryProp("Photo"))
      if photo_head ~= "" then
        local str_const = "_large."
        local str_lst = nx_function("ext_split_string", nx_string(photo_head), ".")
        if table.getn(str_lst) >= 2 then
          local str_temp = str_lst[1]
          form_talk.lhbodynpc.BackImage = str_lst[1] .. str_const .. str_lst[2]
        end
      end
      break
    end
  end
  if form_talk.Visible then
    nx_execute("form_stage_main\\form_talk", "refresh_form_talk", form_talk)
  else
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_talk", true)
  end
end
function change_tasknpc_flag(chander, arg_num, msg_type, npc, flagtype)
end
function change_tasknpc_effect(chander, arg_num, msg_type, npc, effecttype)
end
function show_share_task_menu(chander, arg_num, msg_type, task_id, task_title, sharer_name)
  nx_execute("form_stage_main\\form_talk_data", "on_show_share_form", task_id, task_title, sharer_name)
end
function show_query_edit_task_info(chander, arg_num, msg_type, ...)
  local counts = table.maxn(arg)
  local msg_string = ""
  for i = 1, counts do
    local task_info = nx_string(arg[i])
    local info_lst = util_split_string(task_info, ",")
    local info_num = table.getn(info_lst)
    if info_num ~= 4 then
      return 0
    end
    for j = 1, info_num do
      msg_string = msg_string .. nx_string(info_lst[j])
      if j ~= info_num then
        msg_string = msg_string .. ","
      end
    end
    if i ~= counts then
      msg_string = msg_string .. ","
    end
  end
  nx_execute("form_sns_edittask_accept", "show_task_info_by_msg", nx_string(msg_string))
end
function show_select_edittask_info(chander, arg_num, msg_type, task_type, require_info, prop_info, prize_info)
  local msg_info = ""
  msg_info = msg_info .. nx_string(task_type) .. "|" .. nx_string(require_info) .. "|" .. nx_string(prop_info) .. "|" .. nx_string(prize_info)
  nx_execute("form_sns_edittask_accept", "show_select_task_info_by_msg", nx_string(msg_info))
  nx_execute("form_sns_edittask_accepted", "show_select_task_info_by_msg", nx_string(msg_info))
end
function open_submit_collect_box(chander, arg_num, msg_type, task_id)
  local gui = nx_value("gui")
  local form = nx_value("form_sns_edittask_submit")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_sns_edittask_submit", true, false)
    nx_set_value("form_sns_edittask_submit", form)
  end
  if nx_int(task_id) <= nx_int(0) then
    util_show_form("form_sns_edittask_submit", false)
    return 1
  end
  form.taskid = task_id
  util_show_form("form_sns_edittask_submit", true)
end
function custom_be_request(chander, arg_num, msg_type, request_type, request_name, ...)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if request_type == nil then
    return
  end
  if request_type == REQUESTTYPE_OUTLAND_MAIN_FORM then
    nx_execute("form_stage_main\\form_outland\\form_outland_main", "init_outland_subform")
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", "outland_main_help")
    return
  end
  if nx_int(request_type) == nx_int(REQUESTTYPE_HOME_HELP_TYGN) then
    nx_execute("form_stage_main\\form_home\\form_home_help_tygn", "open_form")
    return
  end
  if request_type == REQUESTTYPE_DBOMALL_ACTIVE then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", "dbomall_main_help")
    return
  end
  local left_time
  if request_type == REQUESTTYPE_CHALLENGE or request_type == PLAYER_REQUESTTYPE_LEITAI_PK or request_type == REQUESTTYPE_USE_ITEM_ACCOST then
    left_time = 30
  end
  if request_type == REQUESTTYPE_BATTLEFIELD_SWITCH then
    left_time = nx_int(arg[1]) / nx_int(1000)
  elseif request_type == REQUESTTYPE_BALANCE_WAR_MATCHING_CONFIRM then
    left_time = nx_int(arg[1])
  end
  if request_type == REQUESTTYPE_LIFE_JOB_SHARE then
    local player_state = client_player:QueryProp("LogicState")
    if player_state == LS_OFFLINE_STALL then
      return
    end
  end
  local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", request_type, request_name, left_time)
  if index == nil then
    return
  end
  if 0 < index then
    for i = 1, table.getn(arg) do
      nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, arg[i])
    end
  end
end
function send_letter_result(chander, arg_num, msg_type, result)
  nx_execute("form_stage_main\\form_mail\\form_mail_send", "on_send_letter_result", result)
end
function is_delete_letter(chander, arg_num, msg_type, del_type, text_type, serial_no)
  local gui = nx_value("gui")
  local text = ""
  if text_type == 1 then
    text = gui.TextManager:GetText("ui_is_delete_all_letter")
  elseif text_type == 2 then
    text = gui.TextManager:GetText("ui_is_delete_letter")
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_del_letter_ok", del_type, serial_no)
  end
end
function get_letter_money_success(chander, arg_num, msg_type, ntype)
  nx_execute("form_stage_main\\form_mail\\form_mail_read", "on_get_money_success", ntype)
end
function virtualrec_add(chander, msgid, operate_name, recname, ...)
end
function virtualrec_clear(chander, msgid, recname)
end
function virtualrec_update(chander, msgid, recname, row, col, value)
end
function virtualrec_updaterow(chander, msgid, recname, row, ...)
  for i, para in pairs(arg) do
  end
end
function virtualrec_removerow(chander, msgid, recname, row)
end
function custom_marriage_npc(chander, argnum, msgtype, flag)
  if not nx_execute("util_gui", "util_is_form_visible", "test") then
    nx_execute("util_gui", "util_show_form", "test", true)
    local form = nx_value("test")
    form.funid = flag
  else
    nx_execute("util_gui", "util_show_form", "test", false)
  end
end
function custom_neishangcure_npc()
  nx_execute("form_stage_main//form_die", "form_die_neishangcure_confirm")
end
function custom_push_roll_item(chander, argnum, msgtype, item, item_info, amount, wait_time)
  nx_execute("form_stage_main\\form_dicemanager", "push_dice_item", item, item_info, amount, wait_time)
end
function custom_team_assign_dlg(chander, arg_num, msg_type, mode)
  local pickup_interface = ""
  if nx_int(mode) == nx_int(0) then
    pickup_interface = "form_stage_main\\form_pick\\form_droppick"
  elseif nx_int(mode) == nx_int(1) then
    pickup_interface = "form_stage_main\\form_clone_awards"
  end
  if pickup_interface == "" then
    return
  end
  local form = nx_value(pickup_interface)
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_team\\form_team_assign", "show_form_assign", form, nx_number(mode))
  end
end
function custom_open_compete_baseprice_dlg(chander, arg_num, msg_type, ...)
  local item = arg[1]
  local item_info = nx_string(arg[2])
  local amount = nx_number(arg[3])
  local mode = nx_number(arg[4])
  nx_execute("form_stage_main\\form_compete\\form_baseprice", "push_compete_item", item, item_info, amount, mode)
end
function custom_begin_compete(chander, arg_num, msg_type, ...)
  local opt_type = nx_number(arg[1])
  local item = arg[2]
  if opt_type == 1 then
    local form_opened = nx_value("form_stage_main\\form_compete\\form_compete" .. nx_string(item))
    if nx_is_valid(form_opened) then
      return
    end
    local form_compete = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_compete\\form_compete", true, false, nx_string(item))
    if nx_is_valid(form_compete) then
      form_compete.item = arg[2]
      form_compete.item_info = nx_string(arg[3])
      form_compete.amount = nx_number(arg[4])
      form_compete.base_price = nx_number(arg[5])
      form_compete.wait_time = nx_number(arg[6])
      form_compete:Show()
    end
  else
    local form_compete = nx_value("form_stage_main\\form_compete\\form_compete" .. nx_string(item))
    if nx_is_valid(form_compete) then
      form_compete:Close()
    end
  end
end
function custom_handle_compete_result_info(chander, arg_num, msg_type, ...)
  local compete_optype = nx_number(arg[1])
  local item = arg[2]
  local form_compete = nx_value("form_stage_main\\form_compete\\form_compete" .. nx_string(item))
  if not nx_is_valid(form_compete) then
    return
  end
  if compete_optype == 0 then
    local player_name = nx_widestr(arg[3])
    nx_execute("form_stage_main\\form_compete\\form_compete", "append_abandon_msg", form_compete, player_name)
  elseif compete_optype == 1 then
    local player_name = nx_widestr(arg[3])
    local money = nx_number(arg[4])
    nx_execute("form_stage_main\\form_compete\\form_compete", "append_bidden_msg", form_compete, player_name, money)
  end
end
function custom_show_animation(self, argnum, msgtype, name, index)
  nx_execute("animation", "show_animation", name, index)
end
function custom_del_animation(self, argnum, msgtype, name)
  nx_execute("animation", "del_animation", name)
end
function buy_stall_style_ok(self, argnum, msgtype)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_setstyle", false, false)
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_stage_main\\form_stall\\form_stall_setstyle", "refresh_grid", dialog)
end
function open_tool_box(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag")
end
function custom_new_born(chander, arg_num, msg_type, page)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local origin_id = client_player:QueryRecord("Origin_Main", 0, 0)
  if origin_id == "" or origin_id == nil then
    return 0
  end
  nx_execute("form_stage_main\\form_origin_notify", "set_origin_id", origin_id)
  nx_execute("form_stage_main\\form_origin_notify", "set_new_flag", 1)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_origin_notify", true, false)
  dialog:ShowModal()
end
function custom_play_point_sound(chander, arg_num, msg_type, sound_name, x, y, z)
  nx_execute("util_sound", "play_action_sound", sound_name, x, y, z)
end
function on_npc_talk(chander, arg_num, msg_type, talk_obj, talk_id, stage, mode, configid, name, other_info_1, other_info_2)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local wide_str = ""
  if configid ~= nil and name ~= nil and nx_ws_length(nx_widestr(name)) > 0 then
    wide_str = gui.TextManager:GetFormatText(nx_string(talk_id), nx_widestr(name))
    if stage == 9 then
      local talk_text = nx_widestr("")
      local other_talk_id = nx_int(other_info_2)
      if other_talk_id == nx_int(0) then
        talk_text = nx_widestr(gui.TextManager:GetText("baofu_zyb_001"))
      elseif other_talk_id == nx_int(1) then
        talk_text = nx_widestr(gui.TextManager:GetText("baofu_zyb_002"))
      elseif other_talk_id == nx_int(2) then
        talk_text = nx_widestr(gui.TextManager:GetText("baofu_zyb_003"))
      end
      wide_str = ""
      wide_str = gui.TextManager:GetFormatText(nx_string(talk_id), nx_widestr(name), nx_widestr(other_info_1), nx_widestr(talk_text))
      local info = nx_widestr("[") .. nx_widestr(gui.TextManager:GetText(nx_string(configid))) .. nx_widestr("]:") .. wide_str
      local form_main_chat_logic = nx_value("form_main_chat")
      if nx_is_valid(form_main_chat_logic) then
        form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
      end
    end
  else
    wide_str = gui.TextManager:GetText(nx_string(talk_id))
  end
  local ident = nx_string(talk_obj)
  local game_client = nx_value("game_client")
  local client_scene_obj = game_client:GetSceneObj(ident)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowChatTextOnHead(client_scene_obj, nx_widestr(wide_str), 5000)
  end
  if mode == nil or mode == 0 then
    return
  end
  if stage == 5 and not nx_is_valid(client_scene_obj) then
    return
  end
  if configid == nil and name ~= nil and nx_ws_length(nx_widestr(name)) > 0 then
    custom_sysinfo(chander, arg_num, msg_type, TIPSTYPE_NPCTALKINFO, talk_id, name, wide_str, "player_talk")
  elseif configid ~= nil and name ~= nil and nx_ws_length(nx_widestr(name)) > 0 then
    local nameid = nx_string(configid)
    local nametext = gui.TextManager:GetText(nx_string(nameid))
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(configid))
    if not bExist then
      return
    end
    local text = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("script"))
    custom_sysinfo(chander, arg_num, msg_type, TIPSTYPE_NPCTALKINFO, wide_str, nametext, text, "npc_talk_to_palyer")
  elseif configid ~= nil then
    local nameid = nx_string(configid)
    local nametext = gui.TextManager:GetText(nx_string(nameid))
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(configid))
    if not bExist then
      return
    end
    local text = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("script"))
    custom_sysinfo(chander, arg_num, msg_type, TIPSTYPE_NPCTALKINFO, talk_id, nametext, text, "npc_talk")
  end
end
function random_adventure_system_info(chander, arg_num, msg_type, text_id, hour, minute, second, npc_id, npc)
  nx_pause(5)
  local game_visual = nx_value("game_visual")
  local npc_visual = game_visual:GetSceneObj(nx_string(npc))
  if not nx_is_valid(npc_visual) then
    return
  end
  if not npc_visual.LoadFinish then
    return
  end
  if not game_visual:QueryRoleCreateFinish(npc_visual) then
    return
  end
  custom_sysinfo(chander, arg_num, msg_type, TIPSTYPE_SYSTEMNO, text_id, hour, minute, second, npc_id)
end
function on_npc_karma_spring(self, arg_num, msg_type, npc, old_val, new_val)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local head_game = nx_value("HeadGame")
  local visual_scene_obj = game_visual:GetSceneObj(nx_string(npc))
  if nx_is_valid(visual_scene_obj) then
    head_game:ShowNpcKarmaAnim(visual_scene_obj, old_val, new_val)
  end
end
function on_show_npc_friend(self, arg_num, msg_type, ...)
  if nx_number(arg_num) <= 1 then
    return
  end
  local data = ""
  local split = ";"
  a = 1
  for _, value in ipairs(arg) do
    data = data .. nx_string(split) .. nx_string(value)
    if math.mod(a, 3) ~= 0 then
      split = ","
    else
      split = ";"
    end
    a = a + 1
  end
  data = string.sub(data, 2)
  nx_execute("form_stage_main\\form_karma", "show_npc_friend", data)
end
function on_update_npc_karma_value(chander, arg_num, msg_type, npc, karma)
  local mouse_control = nx_value("MouseControl")
  if nx_is_valid(mouse_control) then
    mouse_control:UpDateNpcHeadKarma(npc, karma)
  end
end
function on_update_npc_karma(chander, arg_num, msg_type, npc_id, karma)
  nx_execute("form_stage_main\\form_group_karma", "update_npc_karma", npc_id, karma)
end
function custom_receive_item_info(chander, arg_num, msg_type, player_name, item_info, uniqueid)
  nx_execute("form_stage_main\\form_main\\form_main_chat", "show_hyper_link_iteminfo", item_info, uniqueid)
end
function custom_game_stump_start(self, arg_num, msg_type, time)
  local gui = nx_value("gui")
  local form_stump = nx_value("form_stage_main\\form_smallgame\\form_game_stump")
  if not nx_is_valid(form_stump) then
    form_stump = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_smallgame\\form_game_stump", true, false)
    nx_set_value("form_stage_main\\form_smallgame\\form_game_stump", form_stump)
  end
  form_stump.Limit = nx_int(time)
  form_stump:Show()
end
function custom_game_stump_stop(self, arg_num, msg_type)
  local gui = nx_value("gui")
  local form_stump = nx_value("form_stage_main\\form_smallgame\\form_game_stump")
  if nx_is_valid(form_stump) then
    nx_execute("form_stage_main\\form_smallgame\\form_game_stump", "stump_game_stop", form_stump)
  end
end
function custom_start_timer(chander, arg_num, msg_type, ntype, time, ident)
  if ntype == 0 then
    nx_execute("link", "init_timer", time, ident)
  end
end
function custom_npc_move(chander, arg_num, msg_type, ident)
  nx_execute("scene_npc_line_move", "Npc_move", nx_string(ident))
end
function custom_refresh_origin(chander, arg_num, msg_type, ...)
  local cmd = arg[1]
  local para = 0
  if cmd == 0 then
    para = arg[2]
  end
  nx_execute("form_stage_main\\form_origin\\form_origin", "on_command_update_origin", cmd, para)
end
function custom_notify_a_new_origin(chander, arg_num, msg_type, ...)
  local origin_id = arg[1]
  if origin_id == nil then
    return
  end
  nx_execute("form_stage_main\\form_sys_notice", "notify_a_new_origin", origin_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  nx_execute("custom_effect", "custom_effect_levelup", nx_string(client_player.Ident))
end
function custom_shenghuo_action(chander, arg_num, msg_type, obj_id, flag)
  local ident = nx_string(obj_id)
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetSceneObj(ident)
  nx_execute("role_composite", "control_role_weapon_position", role, flag)
  return 1
end
function custom_can_get_side_origin(chander, arg_num, msg_type, origin_id, ret)
  local can_get = 0 < tonumber(ret)
  nx_execute("form_stage_main\\form_origin_details", "set_btn_get_origin", origin_id, can_get)
end
function custom_have_offline_prize(chander, arg_num, msg_type)
end
function custorm_player_enter_scene_onready(chander, arg_num, msg_type, scene, first)
  nx_execute("scene_obj_prop", "enter_warning_area")
  nx_execute("form_stage_main\\form_FB_lead", "close_clone_lead_form")
  nx_execute("form_stage_main\\form_common_notice", "show_form")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "add_offline_record")
  nx_execute("form_stage_main\\form_talk_movie", "cancel_ppdof_effect")
  nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "on_ready")
  nx_execute("form_stage_main\\form_name_modify", "on_ready")
  nx_execute("game_control", "set_foucs_height")
  nx_execute("form_stage_main\\form_outland\\form_outland_war_title", "on_ready")
  nx_execute("form_stage_main\\form_main\\form_main_map", "on_ready")
  if nx_number(first) > 0 then
    nx_execute("util_vip", "on_ready", first)
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_buff")
  if nx_is_valid(form) then
    local form_main_buff = nx_value("form_main_buff")
    if nx_is_valid(form_main_buff) then
      form_main_buff:form_refresh_buffer(form)
    end
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) and nx_is_valid(client_player) then
    local bind_dead = databinder:QueryIntRoleProp("Dead")
    local player_dead = client_player:QueryProp("Dead")
    databinder:SetIntRoleProp("Dead", nx_number(player_dead))
    if nx_number(player_dead) == nx_number(0) then
      nx_function("ext_set_scene_effect_dead")
    else
      local fight = nx_value("fight")
      if nx_is_valid(fight) then
        fight:DeadChange(client_player)
      end
    end
  end
end
function custorm_player_oncontinue(chander, arg_num, msg_type, scene)
  nx_execute("scene_obj_prop", "enter_warning_area")
  nx_execute("form_stage_main\\form_FB_lead", "close_clone_lead_form")
  nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "on_continue")
end
function custom_show_model_dialog_info(chander, arg_num, msg_type, string_id, ...)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(string_id)
  for i, para in pairs(arg) do
    local type = nx_type(para)
    if type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  local info = gui.TextManager:Format_GetText()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.relogin_btn.Visible = false
  dialog.cancel_btn.Visible = false
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), -1)
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
end
function custom_life_skill_hit(chander, arg_num, msg_type, flowname, result)
  nx_execute("life_skill", "refresh_npc_name")
end
function custom_start_movie(chander, arg_num, msg_type, npc_id, movie_id, movie_mode, ...)
  local gui = nx_value("gui")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local role = game_visual:GetPlayer()
  if not nx_is_valid(role) then
    return
  end
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and form_talk.Visible then
    nx_execute("form_stage_main\\form_talk_movie", "form_close", 1)
  end
  if not nx_find_custom(role, "scene") then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "game_effect") then
    return
  end
  local game_effect = scene.game_effect
  if nx_is_valid(game_effect) and nx_find_custom(game_effect, "SetGlobalEffect") then
    game_effect:SetGlobalEffect(0, role, 0, "", 0)
  end
  if movie_mode == 7 then
    nx_execute("form_common\\form_play_video", "play_video", movie_id)
  else
    nx_execute("custom_handler", "start_movie", movie_id, npc_id, movie_mode, unpack(arg))
  end
end
function start_movie(movie_id, npc_id, movie_mode, ...)
  local form_movie_effect = nx_value("form_stage_main\\form_movie_effect")
  if nx_is_valid(form_movie_effect) and form_movie_effect.Visible then
    nx_wait_event(5, nx_null(), "form_movie_effect_end")
  end
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and form_talk.Visible then
    nx_execute("form_stage_main\\form_talk_movie", "form_close", 1)
  end
  local form = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_movie_new", true, false)
    nx_set_value("form_stage_main\\form_movie_new", form)
  end
  form.movie_id = movie_id
  form.npcid = npc_id
  form.movie_mode = tonumber(movie_mode)
  form.team_member_idents = ""
  for count = 1, table.getn(arg) do
    if count == 1 then
      form.team_member_idents = form.team_member_idents .. nx_string(arg[count])
    else
      form.team_member_idents = form.team_member_idents .. "|" .. nx_string(arg[count])
    end
  end
  util_show_form("form_stage_main\\form_movie_new", true)
end
function custom_movie_request(chander, arg_num, msg_type, npc_id, movie_id)
  nx_execute("form_stage_main\\form_movie_notice", "on_custom_movie_request", npc_id, movie_id)
end
function custom_stop_movie(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_movie_new", "close_movie_form")
  local form_video = nx_value("form_common\\form_play_video")
  if nx_is_valid(form_video) then
    form_video:Close()
  end
end
function custom_zhenfa_line(chander, arg_num, msg_type, target, line_type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene_obj = game_client:GetSceneObj(nx_string(target))
  if nx_is_valid(client_scene_obj) then
    nx_execute("custom_effect", "custom_effect_zhenfa_line", client_scene_obj, line_type)
  end
end
function custom_zhenfa_map(chander, arg_num, msg_type, target, op_type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene_obj = game_client:GetSceneObj(nx_string(target))
  if nx_is_valid(client_scene_obj) then
    nx_execute("custom_effect", "custom_effect_refresh_zhenfamap", client_scene_obj)
  end
end
function custom_refresh_zhenfa_effect(chander, arg_num, msg_type, type)
  if type == 1 then
    nx_execute("custom_effect", "custom_effect_refresh_zhenfa_effect")
  elseif type == 2 then
    nx_execute("custom_effect", "custom_effect_clear_zhenfa_effect")
  end
end
function custom_set_city_show(chander, arg_num, msg_type, city_name, b_first)
  if tonumber(arg_num) ~= tonumber(3) or tonumber(b_first) == tonumber(1) then
  end
  nx_execute("form_stage_main\\form_sys_notice", "show_notice", city_name)
end
function custom_offline_not_finish(chander, arg_num, msg_type)
end
function custom_show_offline_job_log(chander, arg_num, msg_type)
end
function custom_show_offline_job_daily(chander, arg_num, msg_type, date, show_type, job_id1, job_id2, job_id3, job_id4, job_id5, idCnt, sceneID, jobSuff, isNewRole, stage)
  nx_execute("form_stage_main\\form_offline\\form_offline", "show_window", date, show_type, job_id1, job_id2, job_id3, job_id4, job_id5, idCnt, sceneID, jobSuff, isNewRole, stage)
end
function custom_hide_offline_job_daily(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_offline\\form_offline", "hide_window")
end
function custom_show_offline_prize(chander, arg_num, msg_type, date, offTime, prizeCnt, ...)
  nx_execute("form_stage_main\\form_offline\\form_offline_prize", "init_prize", date, offTime, prizeCnt, unpack(arg))
end
function custom_open_playsnail_main(chander, arg_num, msg_type, open)
  if nx_int(open) > nx_int(0) then
    nx_execute("playsnail\\form_playsnail_main", "show_playsnail_main_form")
  end
end
function custom_show_offline_job_interact(chander, arg_num, msg_type, job_id, fee_list, cvt_flag)
end
function custom_hide_offline_job_interact(chander, arg_num, msg_type)
end
function custom_show_offline_job_interact_prize(chander, arg_num, msg_type, prize_type, item_id, num, money_type, money, name, desc)
  nx_execute("form_stage_main\\form_offline\\form_offline_job_interact_prize", "show_window", prize_type, item_id, num, money_type, money, name, desc)
end
function custom_hide_offline_job_interact_prize(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_offline\\form_offline_job_interact_prize", "hide_window")
end
function custom_show_offline_togather(chander, arg_num, msg_type, ratio)
  nx_execute("form_stage_main\\form_offline\\form_offline_together_proc", "show_window", nx_int(ratio))
end
function custom_close_client(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_offline\\offline_util", "player_offline")
end
function captain_reset_clone(chander, arg_num, msg_type, captain_name, scene_configid, level)
  local form_captain_reset = nx_value("form_stage_main\\form_captain_reset_clone")
  if not nx_is_valid(form_captain_reset) then
    form_captain_reset = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_captain_reset_clone", true, false)
    nx_set_value("form_stage_main\\form_captain_reset_clone", form_captain_reset)
  end
  nx_execute("form_stage_main\\form_captain_reset_clone", "show_captain_reset_info", captain_name, scene_configid, level)
end
function custom_update_player_pos(chander, arg_num, msg_type, player, x, y, z, o)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(nx_string(player))
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  nx_execute("player_state\\state_utils", "update_obj_pos", terrain, visual_scene_obj, x, y, z)
end
function custom_get_a_new_lifejob(chander, arg_num, msg_type, jobid)
  nx_execute("form_stage_main\\form_sys_notice", "show_notice", jobid)
end
function custom_open_help_form(chander, arg_num, msg_type, taskid)
  local gui = nx_value("gui")
  local form_help = nx_value("form_help")
  if not nx_is_valid(form_help) then
    form_help = nx_execute("util_gui", "util_get_form", "form_help", true, false)
    nx_set_value("form_help", form_help)
  end
  form_help.taskid = taskid
  form_help:Show()
end
function custom_offlinework_online_effect(chander, arg_num, msg_type, target, ...)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") do
    nx_pause(0)
    stage_main_flag = nx_value("stage_main")
    loading_flag = nx_value("loading")
  end
  local ident = nx_string(target)
  local effect_list = util_split_string(arg[1], ";")
  for i = 1, table.getn(effect_list) do
    nx_execute("custom_effect", "custom_effect_offline_ai", ident, effect_list[i], 1)
  end
end
function custom_get_a_new_skill(chander, arg_num, msg_type, skillid, skilltype)
  nx_execute("form_stage_main\\form_sys_notice", "show_notice", skillid)
  if nx_string(skilltype) == nx_string("QingGong") and (nx_string(skillid) == nx_string("qinggong_20") or nx_string(skillid) == nx_string("qinggong_21") or nx_string(skillid) == nx_string("qinggong_24") or nx_string(skillid) == nx_string("qinggong_25")) then
    if not util_is_lockform_visible("form_stage_main\\form_help\\form_help_qinggong_video") then
      util_auto_show_hide_form_lock("form_stage_main\\form_help\\form_help_qinggong_video")
    end
  else
    nx_execute("freshman_help", "study_skill_callback", skillid)
  end
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "save_new_wuxue", skillid, skilltype)
end
function custom_show_life_freshmanhelp(chander, arg_num, msg_type, noticetype)
  nx_execute("form_stage_main\\form_sys_notice", "show_notice", noticetype)
end
function time_limit_show(chander, arg_num, msg_type, cur_time)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_task\\form_task_time_limit")
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_task_time_limit", true, false)
  nx_execute("form_stage_main\\form_task\\form_task_time_limit", "refresh_time_info", form, cur_time)
end
function custom_help_step(chander, arg_num, msg_type, stepID)
  nx_execute("freshman_help", "player_onready", stepID)
end
function custom_start_inter_action(chander, arg_num, msg_type, player, npc, player_action, npc_action)
  nx_execute("interactive_item", "start_action", player, npc, player_action, npc_action)
end
function custom_end_inter_action(chander, arg_num, msg_type, player, npc)
  nx_execute("interactive_item", "end_action", player, npc)
end
function custom_band_relive_pos(chander, arg_num, msg_type, player)
  local ident = nx_string(player)
  nx_execute("custom_effect", "custom_effect_levelup", ident)
end
function custom_relive_end(chander, arg_num, msg_type, player, relive_type)
  nx_execute("form_stage_main\\form_die", "player_relive_end", relive_type)
end
function custom_relive_check(chander, arg_num, msg_type, ret)
  local form = util_get_form("form_stage_main\\form_die", false)
  if not nx_is_valid(form) then
    nx_execute("form_stage_main\\form_hurt_danger", "on_relive_check", ret)
  end
  nx_execute("form_stage_main\\form_die", "on_relive_check", ret)
end
function custom_donghai_relive_check(chander, arg_num, msg_type, ret)
  nx_execute("form_stage_main\\form_die_donghai", "on_relive_check", ret)
end
function custom_forge_started(chander, arg_num, msg_type)
  nx_execute("form_forge", "handle_started")
end
function custom_forge_stopped(chander, arg_num, msg_type)
  nx_execute("form_forge", "handle_stopped")
end
function custom_forge_timeout(chander, arg_num, msg_type)
  nx_execute("form_forge", "handle_timeup")
end
function custom_forge_cancel_step(chander, arg_num, msg_type, id)
  nx_execute("form_forge", "handle_cancel", id)
end
function custom_forge_step_diff(chander, arg_num, msg_type, index, diff)
  nx_execute("form_forge", "on_diff_time", index, diff)
end
function hide_npc_client(chander, arg_num, msg_type, ident)
  nx_execute("hide_npc_for_client", "hide_npc", ident)
end
function custom_show_roadsign(chander, arg_num, msg_type, npc)
  local form_roadsign = nx_value("form_stage_main\\form_roadsign")
  if nx_is_valid(form_roadsign) then
    form_roadsign:Close()
  end
  form_roadsign = util_get_form("form_stage_main\\form_roadsign", true)
  if nx_is_valid(form_roadsign) then
    form_roadsign.npc = nx_string(npc)
    util_show_form("form_stage_main\\form_roadsign", true)
  end
end
function custom_show_base_info(chander, arg_num, msg_type, ...)
  local data = ""
  for _, value in ipairs(arg) do
    data = data .. "," .. nx_string(value)
  end
  data = string.sub(data, 2)
  nx_execute("form_stage_main\\form_role_chakan", "set_base_info", data)
end
function custom_show_binglu_info(chander, arg_num, msg_type, ...)
  local data = ""
  for _, value in ipairs(arg) do
    data = data .. "," .. nx_string(value)
  end
  data = string.sub(data, 2)
  nx_execute("form_stage_main\\form_binglu_chakan", "set_binglu_info", data)
end
function custom_show_equip_info(chander, arg_num, msg_type, ...)
  local data = ""
  for _, value in ipairs(arg) do
    data = data .. "*" .. nx_string(value)
  end
  data = string.sub(data, 2)
  nx_execute("form_stage_main\\form_role_chakan", "set_equip_info", data)
end
function custom_show_game_info(chander, arg_num, msg_type, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local player_name = nx_widestr(arg[1])
  local player_title = arg[2]
  local player_level = arg[3]
  local player_photo = arg[4]
  local character_flag = arg[5]
  local character_value = arg[6]
  local player_scene = arg[7]
  local player_school = arg[8]
  local player_guild = arg[9]
  local player_guild_pos = arg[10]
  local player_sh_count = arg[11]
  local player_sh = ""
  if nx_string(player_school) == nx_string("") then
    player_school = gui.TextManager:GetText("ui_jianghu")
  else
    player_school = gui.TextManager:GetText(player_school)
  end
  if nx_string(player_guild) == nx_string("") then
    player_guild = gui.TextManager:GetText("ui_showinfo_none")
  else
    player_guild = nx_widestr(player_guild)
  end
  if nx_string(player_guild_pos) == nx_string("") then
    player_guild_pos = gui.TextManager:GetText("ui_showinfo_none")
  else
    player_guild_pos = gui.TextManager:GetText(nx_string(player_guild_pos))
  end
  local bIsSwornTitle = false
  if nx_int(player_title) == nx_int(0) then
    player_title = nx_widestr(gui.TextManager:GetText("ui_neigong_cur_info_without"))
  elseif nx_int(player_title) >= nx_int(9001) and nx_int(player_title) <= nx_int(9100) then
    bIsSwornTitle = true
  else
    player_title = nx_widestr(gui.TextManager:GetText("role_title_" .. nx_string(player_title)))
  end
  if nx_int(player_sh_count) == nx_int(0) then
    player_sh = gui.TextManager:GetText("ui_showinfo_none")
  else
    local sh_text = ""
    for i = 1, player_sh_count do
      sh_text = gui.TextManager:GetFormatText(nx_string(arg[11 + i]))
      player_sh = nx_widestr(player_sh) .. sh_text .. nx_widestr(" ")
    end
  end
  player_level = gui.TextManager:GetText("desc_" .. player_level)
  local player_pk_step = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", character_flag, character_value)
  local para_num = 11 + player_sh_count
  local is_vip = arg[para_num + 1]
  local teacher_name = nx_widestr(arg[para_num + 2])
  local partner_name = nx_widestr(arg[para_num + 3])
  local sworn_title = nx_widestr(arg[para_num + 5])
  local sworn_info = nx_widestr(arg[para_num + 6])
  if bIsSwornTitle then
    local list = util_split_wstring(nx_widestr(sworn_title), nx_widestr(","))
    local counts = table.getn(list)
    if counts < 3 then
      return
    end
    local title_name = nx_widestr(list[1])
    local player_num = nx_int(list[2])
    local titld_id = nx_int(list[3])
    if nx_int(player_num) >= nx_int(2) and nx_int(player_num) <= nx_int(6) then
      player_title = nx_widestr(gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(titld_id), nx_widestr(title_name)))
    end
  end
  nx_execute("form_stage_main\\form_relation\\form_player_info", "on_look_up_msg", player_name, player_title, player_level, player_photo, player_pk_step, player_scene, player_school, player_guild, player_guild_pos, player_sh, is_vip, teacher_name, partner_name, sworn_info)
end
function start_augur(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_small_game\\form_augurgame", "start_augur")
end
function end_augur(chander, arg_num, msg_type, index)
  nx_execute("form_stage_main\\form_small_game\\form_augurgame", "end_augur", index)
end
function on_clf_rollgame(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_clf_rollgame", "custom_message_callback", unpack(arg))
end
function on_hwq_choice(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = nx_int(arg[1])
  if sub_msg < nx_int(0) then
    return
  end
  if sub_msg <= nx_int(3) then
    nx_execute("form_stage_main\\form_hwq_choice_roomnpc", "custom_message_callback", unpack(arg))
  elseif sub_msg == nx_int(4) then
    nx_execute("form_stage_main\\form_force\\form_force_wuque", "on_server_msg", unpack(arg))
  elseif sub_msg == nx_int(5) then
    nx_execute("form_stage_main\\form_force\\form_wuque_buy_extra", "open_form", unpack(arg))
  elseif sub_msg == nx_int(6) then
    nx_execute("form_stage_main\\form_force\\form_wuque_buy_extra", "close_form", unpack(arg))
  end
end
function on_gumu_hzdd(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_force_school\\form_gumu_hzdd", "on_server_msg", unpack(arg))
end
function on_wuxian_fete(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_force_school\\form_wuxian_fete", "on_server_msg", unpack(arg))
end
function custom_can_fortunetellingstall(chander, arg_num, msg_type)
  util_show_form("form_stage_main\\form_life\\form_fortunetelling_op", true)
end
function custom_start_fortunetellingstall(chander, arg_num, msg_type, text, stallname)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  nx_execute("form_stage_main\\form_life\\form_fortunetelling_op", "start_fortunetelling")
end
function stall_pathing_okay(chander, arg_num, msg_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_option", false, false)
  if nx_is_valid(dialog) then
    nx_execute("form_stage_main\\form_stall\\form_option", "custom_begin_stall", dialog)
  end
end
function close_business(chander, arg_num, msg_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stallbusiness", false, false)
  if nx_is_valid(dialog) then
    dialog:Close()
  end
end
function stall_position_okay(chander, arg_num, msg_type, stall_pos_index)
  nx_execute("form_stage_main\\form_stall\\form_stall_main", "get_stall_pos_index_okey", stall_pos_index)
end
function liuyan_okay(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_stall\\form_liuyan", "on_liuyan_ok")
end
function liuyan_clear_okay(chander, arg_num, msg_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_liuyan", false, false)
  nx_execute("form_stage_main\\form_stall\\form_stall_liuyan", "init_info", form)
end
function jilu_clear_okay(chander, arg_num, msg_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_stallnotes", false, false)
  nx_execute("form_stage_main\\form_stall\\form_stall_stallnotes", "init_info", form)
end
function custom_canceled_fortunetellingstall(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_life\\form_fortunetelling_op", "close_form")
  nx_execute("form_stage_main\\form_main\\form_main_chat", "del_repeat_item", "StallText")
end
function custom_need_fortunetelling(chander, arg_num, msg_type, target, spritemoney, personmoney, godmoney, rank)
  local form_talk = nx_value("form_stage_main\\form_life\\form_fortunetelling_list")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  util_show_form("form_stage_main\\form_life\\form_fortunetelling_list", true)
  nx_execute("form_stage_main\\form_life\\form_fortunetelling_list", "Init", target, spritemoney, personmoney, godmoney, rank)
end
function custom_accpet_fortunetelling_result(chander, arg_num, msg_type, desc, money)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_sh_gsgq1")
  gui.TextManager:Format_AddParam(desc)
  gui.TextManager:Format_AddParam(nx_int(money))
  local info = gui.TextManager:Format_GetText()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), -1)
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_sh_gsgq7")
  dialog.ok_btn.HintText = gui.TextManager:GetText("tips_gua_11")
  dialog.cancel_btn.Text = gui.TextManager:GetText("ui_sh_gsgq8")
  dialog.cancel_btn.HintText = gui.TextManager:GetText("tips_gua_12")
  dialog.relogin_btn.Visible = true
  dialog.relogin_btn.Text = gui.TextManager:GetText("ui_sh_gsgq9")
  dialog.relogin_btn.HintText = gui.TextManager:GetText("tips_gua_13")
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_accept_fortunetelling_result", 0)
  elseif res == "cancel" then
    nx_execute("custom_sender", "custom_accept_fortunetelling_result", 1)
  else
    nx_execute("custom_sender", "custom_accept_fortunetelling_result", 2)
  end
end
function custom_xuechou_result(chander, arg_num, msg_type, msg_id, ...)
  nx_execute("form_stage_main\\form_life\\form_fortunetelling_list", "xuechou_trace_msg", msg_id, unpack(arg))
end
function custom_can_stall(chander, arg_num, msg_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_config", true, false)
  form:Show()
end
function can_select_stall_ok(chander, arg_num, msg_type, stall_type, scene_id, x, y, z, o)
  nx_execute("form_stage_main\\form_stall\\form_stall_config", "select_stall_ok", scene_id, x, y, z, o, stall_type)
end
function custom_goto(chander, arg_num, msg_type, player, doornpcid)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_goto_cover", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.ImageIndex = doornpcid
  form:Show()
end
function custom_stall_okay(chander, arg_num, msg_type, nOnLine)
  if nx_int(nOnLine) == nx_int(1) then
    nx_execute("form_stage_main\\form_stall\\form_stall_main", "custom_online_ok")
  elseif nx_int(nOnLine) == nx_int(0) then
    nx_execute("form_stage_main\\form_stall\\form_stall_main", "start_offline_stall")
  end
end
function custom_stall_canceled(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_main\\form_main_chat", "del_repeat_item", "StallText")
  nx_execute("form_stage_main\\form_stall\\form_option", "reset_ok")
end
function can_offline_stall(chander, arg_num, msg_type)
end
function custom_offline_stall_okay(chander, arg_num, msg_type, text)
  nx_execute("form_stage_main\\form_stall\\form_stall_main", "start_offline_stall")
end
function npc_begin_pause_skill(chander, arg_num, msg_type, npc, time)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowNpcSkill(nx_string(npc), nx_number(time))
  end
  nx_execute("form_stage_main\\form_main\\form_main_select", "show_select_skill", npc, time)
end
function npc_end_pause_skill(chander, arg_num, msg_type, npc)
end
function change_crop_grow_effect(chander, arg_num, msg_type, crop)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  if nx_is_valid(game_visual) then
    local client_scene_obj = game_client:GetSceneObj(nx_string(crop))
    if not nx_is_valid(client_scene_obj) then
      return
    end
    local npc_type = client_scene_obj:QueryProp("NpcType")
    if nx_number(npc_type) ~= nx_number(NpcType201) then
      return
    end
    local visual_scene_obj = game_visual:GetSceneObj(nx_string(crop))
    if nx_is_valid(visual_scene_obj) then
      nx_execute("head_game", "cancel_npc_head_effect", visual_scene_obj)
      nx_execute("head_game", "set_npc_head_effect", visual_scene_obj)
    end
  end
end
function npc_fight_animatio_start(chander, arg_num, msg_type, ani_name, npc, state)
  if 0 == state then
    nx_execute("npc_animation", "close_npc_ani")
  else
    nx_execute("npc_animation", "play_npc_ani", nx_string(ani_name), nx_string(npc))
  end
end
function custom_faculty_msg(chander, arg_num, msg_type, arg1, arg2)
  nx_execute("faculty", "on_msg", arg1, arg2)
end
function custom_team_faculty(chander, arg_num, msg_type, sub_cmd, ...)
  nx_execute("form_stage_main\\form_wuxue\\form_faculty_team", "on_msg", sub_cmd, unpack(arg))
end
function custom_shijia_qte(chander, arg_num, msg_type, sub_cmd, ...)
  nx_execute("form_stage_main\\form_shijia\\form_shijia_qte", "on_msg", sub_cmd, unpack(arg))
end
function custom_shool_faculty(chander, arg_num, msg_type, sub_cmd, ...)
  nx_execute("form_stage_main\\form_school_dance\\form_school_dance", "on_msg", sub_cmd, unpack(arg))
end
function custom_arena(chander, arg_num, msg_type, sub_cmd, ...)
  nx_execute("form_stage_main\\form_fight\\form_fight_main", "on_msg", sub_cmd, unpack(arg))
end
function on_open_arena_query(chander, arg_num, msg_type, arg1, arg2)
  nx_execute("form_stage_main\\form_fight\\form_fight_view", "on_msg", arg1, arg2)
end
function custom_holdfaculty_msg(chander, arg_num, msg_type, sub_cmd, arg1)
  if nx_int(sub_cmd) == nx_int(3) then
    nx_execute("form_stage_main\\form_wuxue\\form_faculty_exchange", "on_msg", arg1)
  else
    nx_execute("form_stage_main\\form_wuxue\\form_holdfaculty_buy", "on_msg", sub_cmd, arg1)
  end
end
function custom_machine_spring_start(self, arg_num, msg_type, npc, player, band_point, npc_action, player_action)
  nx_execute("machinenpc_band_action", "machine_spring_start", npc, player, band_point, npc_action, player_action)
end
function custom_machine_spring_end(self, arg_num, msg_type, npc, player, band_point, npc_action, player_action)
  nx_execute("machinenpc_band_action", "machine_spring_end", npc, player, band_point, npc_action, player_action)
end
function custom_trigger_skill_effect(chander, arg_num, msg_type, attacker, skillID, ...)
  for _, target in ipairs(arg) do
    nx_execute("game_effect", "create_range_skill_effect", attacker, target, skillID)
  end
end
function custom_refresh_track_info(chander, arg_num, msg_type, first_flag, server_time)
  nx_execute("form_stage_main\\form_task\\form_task_main", "on_entry", first_flag, server_time)
  nx_execute("form_stage_main\\form_group_karma", "on_entry", first_flag)
  nx_execute("form_stage_main\\form_penance", "end_penance")
end
function show_hide_npc(chander, arg_num, msg_type, npc)
  nx_execute("hide_npc_for_client", "show_hide_npc", npc)
end
function custom_game_pichai_start(self, arg_num, msg_type)
  local gui = nx_value("gui")
  local form_game_pichai = nx_value("form_stage_main\\form_smallgame\\form_game_pichai")
  if not nx_is_valid(form_game_pichai) then
    form_game_pichai = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_smallgame\\form_game_pichai", true, false)
    nx_set_value("form_stage_main\\form_smallgame\\form_game_pichai", form_game_pichai)
  end
  form_game_pichai:Show()
end
function custom_game_pichai_stop(self, arg_num, msg_type)
  local gui = nx_value("gui")
  local form_game_pichai = nx_value("form_stage_main\\form_smallgame\\form_game_pichai")
  if nx_is_valid(form_game_pichai) then
    nx_execute("form_stage_main\\form_small_game\\form_game_pichai", "pichai_game_stop", form_game_pichai)
  end
end
function skill_icon_flash(self, arg_num, msg_type, index, flag)
  local b = true
  if flag == 0 then
    b = false
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "skill_flash", index, b)
end
function play_music(chander, arg_num, msg_type, flag, music)
  nx_execute("custom_effect", "play_music", flag, music)
end
function school_pose_fight(chander, arg_num, msg_type, submsg_type, ...)
  local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_SCHOOL_POSE_FIGHT, "", 60, submsg_type)
  if 0 < index then
    nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, submsg_type)
  end
end
function school_fight(chander, arg_num, msg_type, submsg_type, ...)
  if nx_int(submsg_type) == nx_int(0) then
    nx_execute("form_stage_main\\form_school_war\\form_school_fight_info", "open_form", nx_number(submsg_type), unpack(arg))
  elseif nx_int(submsg_type) == nx_int(1) then
    nx_execute("form_stage_main\\form_school_war\\form_school_fight_rank", "open_form", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(2) then
    nx_execute("form_stage_main\\form_school_war\\form_school_fight_item", "open_form", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(3) then
    nx_execute("form_stage_main\\form_school_war\\form_school_fight_info", "open_form", nx_number(submsg_type), unpack(arg))
  elseif nx_int(submsg_type) == nx_int(4) then
    nx_execute("form_stage_main\\form_school_fight\\form_school_fight_help_info", "open_form", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(5) then
    nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "open_form", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(6) then
    nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "receive_observer_change_success", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(7) then
    nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "refresh_team_list", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(8) then
    nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "refresh_commander_info", nx_widestr(arg[1]))
  elseif nx_int(submsg_type) == nx_int(9) then
    nx_execute("form_stage_main\\form_school_war\\form_school_war_control", "open_form", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(10) then
    nx_execute("form_stage_main\\form_school_war\\form_school_fight_info", "on_school_fight_cele_win", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(11) then
    nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "refresh_report_list", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(12) then
    nx_execute("form_stage_main\\form_school_fight\\form_school_fight_message", "open_form", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(13) then
    nx_execute("form_stage_main\\form_school_fight\\form_school_fight_message", "add_all_trace_info", unpack(arg))
  elseif nx_int(submsg_type) == nx_int(21) then
    nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "refresh_school_notice", nx_widestr(arg[1]))
    nx_execute("form_stage_main\\form_school_war\\form_newschool_school_msg_info", "refresh_school_notice", nx_widestr(arg[1]))
  end
end
function gather_effect(chander, arg_num, msg_type, npc, effect_type, slice, effect_name, effect_pos, x, y, z)
  nx_execute("custom_effect", "gather_effect", npc, effect_type, slice, effect_name, effect_pos, x, y, z)
end
function task_msg_logic(self, arg_num, msg_type, submsg, ...)
  local sTalk = "form_stage_main\\form_talk_data"
  local sTrance = "form_stage_main\\form_task\\form_task_trace"
  local sInfo = "form_stage_main\\form_task\\form_task_main"
  if submsg == 1 then
    nx_execute(sTalk, "on_show_accept_form", unpack(arg))
    return
  elseif submsg == 2 then
    nx_execute(sTalk, "on_show_submit_form", unpack(arg))
    return
  elseif submsg == 4 then
    nx_execute(sTalk, "on_show_task_uncomplete_info", unpack(arg))
    return
  elseif submsg == 8 then
    local game_client = nx_value("game_client")
    local game_visual = nx_value("game_visual")
    local player = game_client:GetPlayer()
    if nx_is_valid(player) and player:FindProp("LastObject") then
      local visual_scene_obj = game_visual:GetSceneObj(nx_string(player:QueryProp("LastObject")))
      if nx_is_valid(visual_scene_obj) then
        local head_game = nx_value("HeadGame")
        if nx_is_valid(head_game) then
          head_game:RefreshAll(visual_scene_obj)
        end
      end
    end
    local task_id = arg[1]
    nx_execute(sInfo, "on_task_submit", nx_int(task_id))
  elseif submsg == 9 then
    local task_id = arg[1]
    nx_execute(sInfo, "on_task_add", nx_int(task_id))
  elseif submsg == 11 then
    nx_execute("hide_npc_for_client", "show_or_hide_npc", "show", arg[1])
  elseif submsg == 12 then
    nx_execute("hide_npc_for_client", "show_or_hide_npc", "hide", arg[1])
  elseif submsg == 13 then
    nx_execute("form_stage_main\\form_task\\form_task_time_limit", "check_time", arg[1])
  elseif submsg == 14 then
    local npc_configid = arg[1]
    local npc_photo = arg[2]
    local task_id = arg[3]
    local title_id = arg[4]
    local context_id = arg[5]
    local target_id = arg[6]
    nx_execute("form_stage_main\\form_task\\form_fuben_task_tips", "show_fuben_task", npc_configid, npc_photo, task_id, title_id, context_id, target_id)
  elseif submsg == 15 then
    local taskmgr = nx_value("TaskManager")
    if nx_is_valid(taskmgr) then
      taskmgr:OperateTaskEffectFromServer(nx_string(arg[1]), nx_int(arg[2]))
    end
  elseif submsg == 16 then
    nx_execute(sTrance, "update_trace_info", arg[1], 2)
  elseif 17 <= submsg and submsg <= 24 then
    nx_execute("form_stage_main\\form_task\\form_tiaozhan", "on_tiaozhan_msg", submsg, unpack(arg))
  elseif submsg == 25 then
    nx_execute("form_stage_main\\form_task\\form_task_main", "fresh_wuguan_npc_effect", arg[1])
  end
end
function task_notice_playsnail(chander, arg_num, msg_type, nTaskID, nServerID, nAccount)
  nx_execute("playsnail\\playsnail_common", "SubmitTask", nTaskID, nServerID, nAccount)
end
function out_clone_time(chander, arg_num, msg_type, time)
  nx_execute("form_stage_main\\form_team\\form_team_out_clone", "show_out_clone_time", nx_int(time))
end
function open_reset_clone_ui(chander, arg_num, msg_type)
  util_show_form("form_stage_main\\form_clone\\form_clone_guide", true)
end
function avatar_clone_notice(chander, arg_num, msg_type)
  local form_avatar_clone_notice = nx_value("form_stage_main\\form_avatar_clone\\form_avatar_clone_notice")
  if not nx_is_valid(form_avatar_clone_notice) then
    form_avatar_clone_notice = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_avatar_clone\\form_avatar_clone_notice", true, false)
    nx_set_value("form_stage_main\\form_avatar_clone\\form_avatar_clone_notice", form_avatar_clone_notice)
  end
  nx_execute("form_stage_main\\form_avatar_clone\\form_avatar_clone_notice", "show_avatar_notice_form", form_avatar_clone_notice)
end
function avatar_clone_helper(chander, arg_num, msg_type)
  util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
  local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
  if nx_is_valid(form_help) then
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, "jhqb,jianghuqy02,xinmo03_03,award04")
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function invite_helper(chander, arg_num, msg_type, invitor_name)
  local form_invite_help = nx_value("form_stage_main\\form_avatar_clone\\form_invite_friend_help")
  if not nx_is_valid(form_invite_help) then
    form_invite_help = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_avatar_clone\\form_invite_friend_help", true, false)
    nx_set_value("form_stage_main\\form_avatar_clone\\form_invite_friend_help", form_invite_help)
  end
  nx_execute("form_stage_main\\form_avatar_clone\\form_invite_friend_help", "show_invite_friend_info", invitor_name)
end
function avatar_clone_invite_new_help(chander, arg_num, msg_type)
  local form_invite_new_help = nx_value("form_stage_main\\form_avatar_clone\\form_help_qyqz")
  if not nx_is_valid(form_invite_new_help) then
    form_invite_new_help = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_avatar_clone\\form_help_qyqz", true, false)
    nx_set_value("form_stage_main\\form_avatar_clone\\form_help_qyqz", form_invite_new_help)
  end
  form_invite_new_help:Show()
end
function on_client_tips(self, arg_num, msg_type, subMsg, info, return_info)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_tips", true, false)
  dialog.mltbox_info:Clear()
  local show_text = gui.TextManager:GetText(info)
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(show_text), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
end
function show_clone_menu(chander, arg_num, msg_type, npcid, cloneid, ...)
  local arg_tab = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil
  }
  for i, para in pairs(arg) do
    arg_tab[i] = para
  end
  nx_execute("form_stage_main\\form_clone_talk", "show_clone_menu", npcid, cloneid, arg_tab[1], arg_tab[2], arg_tab[3], arg_tab[4], arg_tab[5], arg_tab[6], arg_tab[7], arg_tab[8])
end
function close_clone_menu(chander, arg_num, msg_type, need_respond)
  local form_clone_talk = nx_value("form_stage_main\\form_clone_talk")
  if nx_is_valid(form_clone_talk) then
    form_clone_talk.needrespond = need_respond
    form_clone_talk:Close()
  end
end
function inphase_clone_menu(chander, arg_num, msg_type, uid)
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "inphase_clone_menu")
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_fuben0009"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "inphase_clone_menu_confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_inphase_clone", uid)
  end
end
function custom_clone_lead_form_open(chander, arg_num, msg_type, col_id)
  if col_id == nil then
    return
  end
  nx_execute("form_stage_main\\form_FB_lead", "open_grid_by_configid", nx_string(col_id))
end
function custom_clone_lead_form_close(chander, arg_num, msg_type, col_id)
  if col_id == nil then
    return
  end
  nx_execute("form_stage_main\\form_FB_lead", "close_grid_by_configid", nx_string(col_id))
end
function custom_clone_lead_form_change(chander, arg_num, msg_type, col_id, spring_id, spring_flg)
  if col_id == nil or spring_id == nil or spring_flg == nil then
    return
  end
  nx_execute("form_stage_main\\form_FB_lead", "enable_grid_by_index", nx_string(col_id), nx_string(spring_id), nx_int(spring_flg))
end
function custom_self_add_form(self, arg_num, msg_type)
  nx_execute("form_stage_main\\form_common_self_add_notice", "show_form")
end
function custom_random_clone_enter_clone(chander, arg_num, msg_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_into_door"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_random_clone", 3)
  elseif res == "cancel" then
    nx_execute("custom_sender", "custom_random_clone", 6)
  end
end
function custom_close_self_add_form(self, arg_num, msg_type)
  nx_execute("form_stage_main\\form_common_self_add_notice", "close_form")
end
function custom_wuxue_flash(self, arg_num, msg_type)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "wuxue_faculty_flash")
end
function drive_skill_open(self, arg_num, msg_type, npc, open_flag)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_drivenpc", "server_drivernpc_op", npc, open_flag)
end
function common_skillgrid(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_buff_common", "on_show_skillgrid", unpack(arg))
end
function refresh_trainpat_btn(chander, arg_num, msg_type, sign)
  nx_execute("form_stage_main\\form_role_info\\form_train_pat", "refresh_trainpat_main", nx_int(sign))
end
function close_common_skillgrid(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_buff_common", "on_close_common_skill_grid")
end
function custom_guild(chander, arg_num, msg_type, sub_msg, ...)
end
function on_custom_guild_enemy(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main_map", "on_custom_guild_enemy", unpack(arg))
end
function custom_guildbuilding(chander, arg_num, msg_type, sub_msg, ...)
  local SERVER_SUBMSG_SHOW_BUILDING_INFO = 1
  local SERVER_SUBMSG_REFRESH_KENGWEINUM = 2
  local SERVER_SUBMSG_KENGWEI_USEFORM = 3
  local SERVER_SUBMSG_KENGWEI_UPGRADE = 4
  local SERVER_SUBMSG_SHOW_LEFT_TIME = 5
  local SERVER_SUBMSG_KENGWEI_KICKOUT = 6
  local SERVER_SUBMSG_DEPOT_OPEN = 101
  local SERVER_SUBMSG_DEPOT_UPGRADE_CAPITAL = 102
  local SERVER_SUBMSG_DEPOT_CONTRIBUTE_MONEY_ACK = 103
  local SERVER_SUBMSG_EMPLOY_OPEN = 110
  local SERVER_SUBMSG_ANSWER_EMPLOY_INFO = 111
  local CLIENT_SUBMSG_DEPOT_CONTRIBUTE_MONEY = 104
  local SERVER_SUBMSG_BAG_OPEN = 120
  local SERVER_SUBMSG_PRE_CREATE_NPC = 130
  local SERVER_SUBMSG_SHOW_BOOKLIST = 131
  local GB_MTYPE_KENGWEI_BUILD = 1
  local GB_MTYPE_JUYI_BUILD = 2
  local GB_MTYPE_YISHI_BUILD = 3
  local GB_MTYPE_JIGUAN_BUILD = 4
  if sub_msg == SERVER_SUBMSG_SHOW_BUILDING_INFO then
    local type = arg[1]
    if type == GB_MTYPE_KENGWEI_BUILD then
      nx_execute("form_stage_main\\form_guildbuilding\\form_guildbuild_upgrade_1", "on_recv_houseinfo", unpack(arg))
    else
      nx_execute("form_stage_main\\form_guildbuilding\\form_guildbuild_upgrade_2", "on_recv_houseinfo", unpack(arg))
    end
  elseif sub_msg == SERVER_SUBMSG_REFRESH_KENGWEINUM then
    local type = arg[1]
    if type == GB_MTYPE_KENGWEI_BUILD then
      nx_execute("form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_1", "on_recv_kengweinum", unpack(arg))
    end
  elseif sub_msg == SERVER_SUBMSG_KENGWEI_USEFORM then
    local npc_id = arg[1]
    local form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_usekengwei")
    if not nx_is_valid(form) then
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_xiulian", true, false)
      nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_xiulian", form)
    end
    form.npcid = npc_id
    form:Show()
    form.Visible = true
  elseif sub_msg == SERVER_SUBMSG_KENGWEI_UPGRADE then
    local npc_id = arg[1]
    local form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_kengwei")
    if not nx_is_valid(form) then
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_kengwei", true, false)
      nx_set_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_kengwei", form)
    end
    form.npcid = npc_id
    form:Show()
    form.Visible = true
  elseif sub_msg == SERVER_SUBMSG_KENGWEI_KICKOUT then
    local npc_id = arg[1]
    local target = arg[2]
    local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_kengwei_kiciout")
    if not nx_is_valid(form) then
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_kengwei_kiciout", true, false)
      nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_kengwei_kiciout", form)
    end
    form.target = target
    form.npcid = npc_id
    form:Show()
    form.Visible = true
  elseif sub_msg == SERVER_SUBMSG_DEPOT_OPEN then
    local guild_depot_window = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku"
    if not nx_execute("util_gui", "util_is_form_visible", guild_depot_window) then
      local gui = nx_value("gui")
      local form_guild_depot = nx_value(guild_depot_window)
      if not nx_is_valid(form_guild_depot) then
        form_guild_depot = nx_execute("util_gui", "util_get_form", guild_depot_window, true, false)
        nx_set_value(guild_depot_window, form_guild_depot)
      end
      form_guild_depot:Show()
      form_guild_depot.Visible = true
      nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag")
    else
      nx_execute("util_gui", "util_show_form", guild_depot_window, false)
    end
  elseif sub_msg == SERVER_SUBMSG_DEPOT_UPGRADE_CAPITAL then
    nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku", "on_Upgrade_guild_capital", unpack(arg))
  elseif sub_msg == SERVER_SUBMSG_DEPOT_CONTRIBUTE_MONEY_ACK then
    nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku", "on_Reveive_Contribute_Money_Ack", unpack(arg))
  elseif sub_msg == SERVER_SUBMSG_EMPLOY_OPEN then
    local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_guyongNPC")
    if nx_is_valid(form) then
      form.npc_id = arg[1]
      local game_client = nx_value("game_client")
      local npc = game_client:GetSceneObj(nx_string(form.npc_id))
      if nx_is_valid(npc) then
        local config = npc:QueryProp("ConfigID")
        local resource = npc:QueryProp("Resource")
        nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_guyongNPC", "refresh_employ_npc", form, npc, config, resource)
      end
    else
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_guyongNPC", true, false)
      if nx_is_valid(form) then
        form.npc_id = arg[1]
        form:Show()
      end
    end
  elseif sub_msg == SERVER_SUBMSG_ANSWER_EMPLOY_INFO then
    local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_guyongNPC")
    if nx_is_valid(form) then
      local sub_type = arg[1]
      local already_num = arg[2]
      local max_num = arg[3]
      nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_guyongNPC", "refresh_employ_info", form, sub_type, already_num, max_num)
    end
  elseif sub_msg == SERVER_SUBMSG_BAG_OPEN then
    nx_execute("form_stage_main\\form_task\\form_task_trace", "click_task_item", unpack(arg))
  elseif sub_msg == SERVER_SUBMSG_SHOW_LEFT_TIME then
  elseif sub_msg == SERVER_SUBMSG_PRE_CREATE_NPC then
    local pre_create_manager = nx_value("GuildPreCreateManager")
    if nx_is_valid(pre_create_manager) and table.getn(arg) >= 11 then
      local client_ident = arg[1]
      local resource = arg[2]
      local x = arg[3]
      local y = arg[4]
      local z = arg[5]
      local o = arg[6]
      local scale = arg[7]
      local domain_id = arg[8]
      local main_type = arg[9]
      local sub_type = arg[10]
      local cur_level = arg[11]
      local guild_name = arg[12]
      local show_logo = arg[13]
      local rotate_param = arg[14]
      if client_ident ~= nil and resource ~= nil and x ~= nil and y ~= nil and z ~= nil and o ~= nil and scale ~= nil and domain_id ~= nil and main_type ~= nil and sub_type ~= nil and cur_level ~= nil then
        pre_create_manager:AddPreCreateNpc(nx_string(client_ident), "ini\\" .. nx_string(resource) .. ".ini", nx_number(x), nx_number(y), nx_number(z), nx_number(o), nx_string(scale), nx_int(domain_id), nx_int(main_type), nx_int(sub_type), nx_int(cur_level), nx_widestr(guild_name), nx_string(show_logo), nx_string(rotate_param))
      end
    end
  elseif sub_msg == SERVER_SUBMSG_SHOW_BOOKLIST then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_guildbuilding\\form_guild_build_booklist", true)
    nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_booklist", "get_NPC_id", unpack(arg))
  elseif sub_msg == 132 then
    local all_member_num = nx_int(arg[1])
    local active_member_num = nx_int(arg[2])
    local current_siliver_num = nx_int(arg[3])
    local from = nx_int(arg[4])
    local to = nx_int(arg[5])
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    nx_execute("form_stage_main\\form_guild\\form_guild_bank_distribute", "on_recv_member_list", all_member_num, active_member_num, current_siliver_num, from, to, unpack(arg))
  elseif sub_msg == 133 then
    nx_execute("form_stage_main\\form_guild\\form_guild_bank_info", "get_guildbank_info", unpack(arg))
  elseif sub_msg == nx_int(134) then
    nx_execute("form_stage_main\\form_guild\\form_guild_bank_event", "on_get_guildbank_event_list", unpack(arg))
  elseif sub_msg == nx_int(135) then
    nx_execute("form_stage_main\\form_guild\\form_guild_bank_event", "on_get_guildbank_seetlement_list", unpack(arg))
  elseif sub_msg == nx_int(136) then
  end
end
function show_buy_guild_domain_form(self, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_domain", "auto_show_hide_form_guild_build_domain", true)
end
function on_neig_pk_msg(self, arg_num, msg_type, sub_msg, ...)
  local path = "form_stage_main\\skill\\neig_pk"
  nx_execute(path, "on_server_msg", sub_msg, unpack(arg))
end
function show_hide_drop_view(self, arg_num, msg_type, open_type)
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if nx_int(open_type) == nx_int(1) then
    if flag then
      util_show_form("form_stage_main\\form_taosha\\form_taosha_pick", true)
      util_show_form("form_stage_main\\form_bag", true)
      util_show_form("form_stage_main\\form_role_info\\form_role_info", true)
    elseif flag_apex then
      util_show_form("form_stage_main\\form_taosha\\form_apex_pick", true)
      util_show_form("form_stage_main\\form_bag", true)
      util_show_form("form_stage_main\\form_role_info\\form_role_info", true)
    else
      util_show_form("form_stage_main\\form_pick\\form_droppick", true)
    end
  elseif nx_int(open_type) == nx_int(0) then
    if flag then
      util_show_form("form_stage_main\\form_taosha\\form_taosha_pick", false)
      util_show_form("form_stage_main\\form_bag", false)
      local form_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
      if nx_is_valid(form_info) then
        form.Visible = false
      end
    elseif flag_apex then
      util_show_form("form_stage_main\\form_taosha\\form_apex_pick", false)
      util_show_form("form_stage_main\\form_bag", false)
      local form_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
      if nx_is_valid(form_info) then
        form.Visible = false
      end
    else
      util_show_form("form_stage_main\\form_pick\\form_droppick", false)
    end
  end
end
function start_special_ride(self, arg_num, msg_type, name)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "server_up_special_ride", 2, name)
end
function end_special_ride(self, arg_num, msg_type, open_type)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "server_dn_special_ride", 2)
end
function start_ride(self, arg_num, msg_type, name)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "server_up_special_ride", 1, name)
end
function end_ride(self, arg_num, msg_type, open_type)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "server_dn_special_ride", 1)
end
function start_ride_spurt(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_life\\form_ride_op", "on_ride_spurt", nx_number(arg[1]), nx_number(arg[2]))
end
function start_world_trans(self, arg_num, msg_type, open_type)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_world_trans_tool", true)
end
function end_world_trans(self, arg_num, msg_type, open_type)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_world_trans_tool", false)
end
function start_scene_trans(self, arg_num, msg_type, ...)
  util_show_form("form_stage_main\\form_map\\form_map_scene_trans", true)
  nx_execute("form_stage_main\\form_map\\form_map_scene_trans", "init_scene_trans", unpack(arg))
end
function end_scene_trans(self, arg_num, msg_type, open_type)
  nx_execute("form_stage_main\\form_map\\form_map_scene_trans", "on_close_form")
end
function off_trans(self, arg_num, msg_type, trans_type)
  local game_visual = nx_value("game_visual")
  local player = game_visual:GetPlayer()
  if nx_is_valid(player) then
    game_visual:SwitchPlayerState(player, "trans", nx_int(STATE_TRANS_INDEX))
  end
end
function publish_news(self, arg_num, msg_type, newsType, repeatTime, infoId, ...)
  nx_execute("form_stage_main\\form_publish_news", "publish_news", newsType, repeatTime, infoId, unpack(arg))
end
function show_time_limit_form(self, arg_num, msg_type)
  nx_execute("form_stage_main\\form_common_notice", "show_form")
end
function close_time_limit_form(self, arg_num, msg_type)
  nx_execute("form_stage_main\\form_common_notice", "close_form")
end
function show_count_limit_form(self, arg_num, msg_type, form_name, form_count, form_title, form_info)
  nx_execute("form_stage_main\\form_common_notice", "show_form", form_name, form_count, form_title, form_info)
end
function inc_count_limit_form(self, arg_num, msg_type, form_name, count_value)
  nx_execute("form_stage_main\\form_common_notice", "show_form", form_name, count_value)
end
function close_count_limit_form(self, arg_num, msg_type)
  nx_execute("form_stage_main\\form_common_notice", "close_form")
end
function notify_desc_limit_form(self, arg_num, msg_type, form_type, limit_type, desc)
  local gui = nx_value("gui")
  local formattext = nx_widestr(gui.TextManager:GetText(nx_string(desc)))
  if nx_number(form_type) == 0 then
    nx_execute("form_stage_main\\form_common_notice", "NotifyText", limit_type, formattext)
  elseif nx_number(form_type) == 1 then
    nx_execute("form_stage_main\\form_single_notice", "NotifyText", limit_type, formattext)
  end
end
function clear_desc_limit_form(self, arg_num, msg_type, form_type, limit_type)
  if nx_number(form_type) == 0 then
    nx_execute("form_stage_main\\form_common_notice", "ClearText", nx_number(limit_type))
  elseif nx_number(form_type) == 1 then
    nx_execute("form_stage_main\\form_single_notice", "ClearText", nx_number(limit_type))
  end
end
function asyn_server_time(self, arg_num, msg_type, server_time)
end
function show_stall_config(self, arg_num, msg_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_config", true, false)
  dialog:Show()
end
function transtool_continue_move(self, arg_num, msg_type)
  nx_pause(0.1)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_find_custom(client_player, "vislink") then
    return
  end
  local linkid = client_player.vislink
  if not nx_is_valid(linkid) then
    return
  end
  local game_visual = nx_value("game_visual")
  local link_client_ident = game_visual:QueryRoleClientIdent(linkid)
  nx_execute("scene_npc_line_move", "Meet_npc_move", link_client_ident, client_player.Ident)
end
function custom_world_rank(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "receive_data", unpack(arg))
end
function custom_begin_breath_in_water(self)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") do
    nx_pause(0.5)
    stage_main_flag = nx_value("stage_main")
    loading_flag = nx_value("loading")
  end
  nx_execute("form_stage_main\\form_main\\form_breath_pro", "begin_easy_progress")
end
function custom_end_breath_in_water(self)
  nx_execute("form_stage_main\\form_main\\form_breath_pro", "end_easy_progress")
end
function asyn_update_head_text(name, str_id, delaytime, pause_time)
  local client_obj = nx_execute("util_functions", "util_find_client_player_by_name", name)
  if nx_is_valid(client_obj) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText(nx_string(str_id))
    nx_pause(pause_time)
    local head_game = nx_value("HeadGame")
    if nx_is_valid(head_game) then
      head_game:ShowChatTextOnHead(client_obj, nx_widestr(text), delaytime)
    end
  end
end
function custom_update_head_text(self, arg_num, msg_type, name, str_id, delaytime, pause_time)
  if pause_time == nil then
    local client_obj = nx_execute("util_functions", "util_find_client_player_by_name", name)
    if nx_is_valid(client_obj) then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetText(nx_string(str_id))
      local head_game = nx_value("HeadGame")
      if nx_is_valid(head_game) then
        head_game:ShowChatTextOnHead(client_obj, nx_widestr(text), delaytime)
      end
    end
  else
    nx_execute(nx_current(), "asyn_update_head_text", name, str_id, delaytime, pause_time)
  end
end
function custom_challenge_orient(self, arg_num, msg_type, name, x, z)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_obj = nx_execute("util_functions", "util_find_client_player_by_name", name)
  if not nx_is_valid(client_obj) then
    return
  end
  local visual_player = game_visual:GetSceneObj(client_obj.Ident)
  if not nx_is_valid(visual_player) then
    return
  end
  local scene_obj = nx_value("scene_obj")
  scene_obj:SceneObjAdjustAngle(visual_player, x, z)
end
function custom_fishing_form(self, arg_num, msg_type)
  nx_execute("form_stage_main\\form_life\\form_fishing_op", "open_form")
end
function showform_offline_onhand(self, arg_num, msg_type)
  nx_execute("form_stage_main\\form_offline\\form_offline_onhand", "show_window")
end
function game_minigame_itemresult(self, arg_num, msg_type, ...)
  util_show_form("form_stage_main\\form_small_game\\form_itemminigameresult", true)
  nx_execute("form_stage_main\\form_small_game\\form_itemminigameresult", "forminit", arg[1], arg[2], arg[3], arg[4], arg[5], arg[6])
end
function begin_life_trade(self, arg_num, msg_type, share_type, ...)
  if nx_int(share_type) == nx_int(1) then
    local target_name = arg[1]
    local jobid = arg[2]
    local formula = arg[3]
    local count = arg[4]
    nx_execute("form_stage_main\\form_life\\form_job_share_confirm", "open_form_compose", target_name, jobid, formula, count)
  else
    local target_name = arg[1]
    local jobid = arg[2]
    local configID = arg[3]
    local skillID = arg[4]
    nx_execute("form_stage_main\\form_life\\form_job_share_confirm", "open_form_skill", target_name, jobid, configID, skillID)
  end
end
function camera_vibrate(self, arg_num, msg_type, vibrate_name)
  local ini = nx_execute("util_functions", "get_ini", "ini\\camera_vibrate.ini")
  if nx_is_valid(ini) then
    if ini:FindSection(nx_string(vibrate_name)) then
      local type = ini:ReadInteger(nx_string(vibrate_name), "Type", 0)
      local swing_begin = ini:ReadFloat(nx_string(vibrate_name), "SwingBegin", 0)
      local swing_end = ini:ReadFloat(nx_string(vibrate_name), "SwingEnd", 0)
      local period = ini:ReadFloat(nx_string(vibrate_name), "Wheel", 0)
      local keep_time = ini:ReadFloat(nx_string(vibrate_name), "LifeTime", 0)
      nx_execute("game_control", "camera_vibrate", nx_int(type), nx_number(swing_begin), nx_number(swing_end), nx_number(period), nx_number(keep_time))
    end
  else
    nx_log("ini\\camera_vibrate.ini " .. get_msg_str("msg_120"))
  end
end
function stop_use_skill(self, arg_num, msg_type)
  local fight = nx_value("fight")
  if nx_is_valid(fight) then
    fight:StopUseSkill()
    fight:StopCheckCurSkill()
  end
end
function stall_success_shengji(self, arg_num, msg_type, ntype)
  if ntype == 1 then
    nx_execute("form_stage_main\\form_stall\\form_stall_sell", "shengji_success")
  else
    nx_execute("form_stage_main\\form_stall\\form_stall_buy", "shengji_success")
  end
end
function on_stall_note(self, arg_num, msg_type, note_type, ...)
  if 1 == note_type then
    nx_execute("form_stage_main\\form_stall\\form_stall_note", "add_player_note", nx_string(arg[1]), nx_string(arg[2]))
  elseif 2 == note_type then
    local seller = arg[1]
    local item = arg[2]
    local count = arg[3]
    local money = arg[4]
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.TextManager:Format_SetIDName("desc_stall_sell")
      gui.TextManager:Format_AddParam(nx_widestr(seller))
      gui.TextManager:Format_AddParam(nx_widestr(item))
      gui.TextManager:Format_AddParam(nx_widestr(count))
      gui.TextManager:Format_AddParam(nx_widestr(money))
      local note = nx_string(gui.TextManager:Format_GetText())
      nx_execute("form_stage_main\\form_stall\\form_stall_note", "add_trade_note", note)
    end
  elseif 3 == note_type then
    local buyer = arg[1]
    local item = arg[2]
    local count = arg[3]
    local money = arg[4]
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.TextManager:Format_SetIDName("desc_stall_buy")
      gui.TextManager:Format_AddParam(nx_widestr(buyer))
      gui.TextManager:Format_AddParam(nx_widestr(item))
      gui.TextManager:Format_AddParam(nx_widestr(count))
      gui.TextManager:Format_AddParam(nx_widestr(money))
      local note = nx_string(gui.TextManager:Format_GetText())
      nx_execute("form_stage_main\\form_stall\\form_stall_note", "add_trade_note", note)
    end
  end
end
function show_vote_form(self, arg_num, msg_type, vote_id)
  nx_execute("form_stage_main\\form_vote", "show_form", vote_id)
end
function show_vote_result(self, arg_num, msg_type, vote_id, ...)
  local loading_form = nx_value("form_common\\form_loading")
  if nx_is_valid(loading_form) and loading_form.Visible then
    return
  end
  local file_name = "share\\Rule\\Vote.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string(vote_id))
  if sec_index < 0 then
    return
  end
  local vote_title = ini:ReadString(sec_index, "VoteTitle", "")
  local vote_timer = ini:ReadInteger(sec_index, "Timer", 0)
  local vote_options = ini:ReadString(sec_index, "Options", "")
  local OptionsArray = util_split_string(nx_string(vote_options), ",")
  local strResult = nx_widestr("<font color='#ff0000'>") .. nx_widestr(vote_title) .. nx_widestr(":</font>") .. nx_widestr("<br>")
  for i = 1, table.getn(OptionsArray) do
    local j = i * 2 - 1
    strResult = nx_widestr(strResult) .. nx_widestr("<font color='#ff0000'>") .. nx_widestr(arg[j]) .. nx_widestr(OptionsArray[i]) .. nx_widestr(":</font>") .. nx_widestr("<font color='#ffffff'>") .. nx_widestr(arg[j + 1]) .. nx_widestr("</font>") .. nx_widestr("<br>")
  end
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(strResult, SYSTYPE_FIGHT, 0)
  end
end
function on_use_luckitem(self, arg_num, msg_type, name)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_charge_shop\\form_input_interact_info", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  if name == "" then
    dialog.name_edit.Text = gui.TextManager:GetText("ui_input")
  else
    dialog.name_edit.Text = name
  end
  dialog.reason_edit.Text = gui.TextManager:GetText("ui_input_interact_info")
  dialog:ShowModal()
  local res, text, reason = nx_wait_event(100000000, dialog, "input_search_return")
  if res == "ok" then
    if nx_string(text) == "" then
      return 0
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_LUCKITEM), nx_widestr(text), nx_widestr(reason))
  end
end
function recv_buy_guild_domain_data(chander, arg_num, msg_type, msgid, ...)
  nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_domain", "recv_data", msgid, unpack(arg))
end
function tiguan_all_msg(chander, arg_num, msg_type, type, sub_type, ...)
  local TG_MSG_TYPE_FINISH_RESULT = 0
  local TG_MSG_TYPE_LOOK_SELF_INFO = 1
  local TG_MSG_TYPE_LOOK_YOUR_INFO = 2
  local TG_MSG_TYPE_SHOW_FINISH_CDT = 3
  local TG_MSG_TYPE_ENTER_GUAN_STEP = 4
  local TG_MSG_TYPE_SHOW_DETAIL = 5
  local TG_MSG_TYPE_DAN_SHUA = 6
  local TG_MSG_TYPE_DAY_RANDOM_FIGHT = 7
  local TG_MSG_TYPE_DUAL_PLAYER = 8
  if nx_number(type) == TG_MSG_TYPE_FINISH_RESULT then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_result", "show_tiguan_result", sub_type)
  elseif nx_number(type) == TG_MSG_TYPE_LOOK_SELF_INFO then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_tiguan", "show_tiguan_count", sub_type, unpack(arg))
    nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "show_tiguan_count", sub_type, unpack(arg))
  elseif nx_number(type) == TG_MSG_TYPE_LOOK_YOUR_INFO then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_other", "show_tiguan_count", sub_type, unpack(arg))
  elseif nx_number(type) == TG_MSG_TYPE_SHOW_FINISH_CDT then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_trace", "show_tiguan_cdts", sub_type, unpack(arg))
  elseif nx_number(type) == TG_MSG_TYPE_ENTER_GUAN_STEP then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_ready", "show_tiguan_ready", sub_type, unpack(arg))
  elseif nx_number(type) == TG_MSG_TYPE_SHOW_DETAIL then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_detail", "show_tiguan_detail", sub_type, unpack(arg))
  elseif nx_number(type) == TG_MSG_TYPE_DAN_SHUA then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_one", "show_tiguan_one", sub_type, unpack(arg))
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_util", "tiguan_danshua_msg", sub_type, unpack(arg))
  elseif nx_number(type) == TG_MSG_TYPE_DAY_RANDOM_FIGHT then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_trace", "show_day_random_fight", sub_type, unpack(arg))
  elseif nx_number(type) == TG_MSG_TYPE_DUAL_PLAYER then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_dual_play", "on_refresh", sub_type, unpack(arg))
  end
end
function tiguanchallenge_msg(self, arg_num, msg_type, sub_type, ...)
  nx_execute("form_stage_main\\form_tiguanchallenge\\form_tiguanchallenge_trace", "tiguan_challenge_msg", sub_type, unpack(arg))
end
function battlefield_all_msg(self, arg_num, msg_type, sub_type, ...)
  local SERVER_BFTYPE_LOOK_INFO = 1
  local SERVER_BFTYPE_FORCE_INFO = 2
  local SERVER_BFTYPE_SORT_INFO = 3
  local SERVER_BFTYPE_SORT_SCORE_INFO = 4
  local SERVER_BFTYPE_SERIAL_KILL = 5
  local SERVER_BFTYPE_KILL_NUMBER = 6
  local SERVER_BFTYPE_BANNER_PLACE = 7
  local SERVER_BFTYPE_JIANQI_COUNT = 8
  local SERVER_BFTYPE_HOLD_ATTACK = 9
  local SERVER_BFTYPE_BANNER_GRAPING = 10
  local SERVER_BFTYPE_KILL_TOTAL = 11
  local SERVER_BFTYPE_SHOW_MYBFBTN = 12
  local SERVER_BFTYPE_WRESTLE_PLAYER_INFOS = 13
  local SERVER_BFTYPE_WRESTLE_PLAYER_LEAVE = 14
  local SERVER_BFTYPE_WRESTLE_PLAYER_SORT = 15
  local SERVER_BFTYPE_WRESTLE_DAMAGE = 16
  local SERVER_BFTYPE_WRESTLE_PLAYER_NUM = 17
  local SERVER_BFTYPE_WRESTLE_READY = 18
  local SERVER_BFTYPE_WRESTLE_BEGIN = 19
  local SERVER_BFTYPE_WRESTLE_END = 20
  local SERVER_BFTYPE_WRESTLE_BOUT_CLOSE = 21
  local SERVER_BFTYPE_WRESTLE_HELP_FORM = 22
  local SERVER_BFTYPE_BATTLEFIELD_FINISH = 23
  local SERVER_BFTYPE_WRESTLE_TEAM_INFO = 24
  local SERVER_BFTYPE_SELF_SCORE = 25
  if nx_number(sub_type) == SERVER_BFTYPE_FORCE_INFO then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_join", "update_battlefield_info", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_LOOK_INFO then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_result", "update_battlefield_result", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_SORT_INFO then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_order", "update_battlefield_order", false, unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_SORT_SCORE_INFO then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_order", "update_battlefield_order", true, unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_SERIAL_KILL then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_display", "DisplayInfo", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_KILL_NUMBER then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "DisplayScore", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_BANNER_PLACE then
    nx_execute("form_stage_main\\form_battlefield\\battlefield_manager", "show_banner_place", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_JIANQI_COUNT then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "RefreshProgressBar", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_HOLD_ATTACK then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_display", "DisplayInfo2")
  elseif nx_number(sub_type) == SERVER_BFTYPE_BANNER_GRAPING then
    nx_execute("form_stage_main\\form_battlefield\\battlefield_manager", "show_banner_graping", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_KILL_TOTAL then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "RefreshKillCountDiff", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_SHOW_MYBFBTN then
    local main_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main", false, false)
    if nx_is_valid(main_form) then
      nx_execute("form_stage_main\\form_main\\form_main", "refresh_battlefield_btn_show", main_form, ture)
    end
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_PLAYER_INFOS then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_fight", "refresh_players_info", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_PLAYER_LEAVE then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_fight", "player_quit", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_PLAYER_SORT then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_fight", "display_players_sort", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_DAMAGE then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_trace", "refresh_wrestle_damage", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_PLAYER_NUM then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_trace", "refresh_wrestle_player_num", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_READY then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_trace", "refresh_wrestle_flow", 1, unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_BEGIN then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_trace", "refresh_wrestle_flow", 2, unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_END then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_trace", "refresh_wrestle_flow", 3, unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_BOUT_CLOSE then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_trace", "close_wrestle_flow", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_HELP_FORM then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "DisplayBtn", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_BATTLEFIELD_FINISH then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_trace", "refresh_wrestle_flow", 4, unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_WRESTLE_TEAM_INFO then
    nx_execute("form_stage_main\\form_main\\form_main_team", "refresh_form_state", unpack(arg))
  elseif nx_number(sub_type) == SERVER_BFTYPE_SELF_SCORE then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_self_score", "refresh_score", unpack(arg))
  end
end
function custom_producejiguan_show(self, arg_num, msg_type, sub_msg, ...)
  if nx_number(sub_msg) == 0 then
    local npc_id = arg[1]
    local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy")
    if not nx_is_valid(form) then
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy", true, false)
      nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy", form)
    end
    form.npcid = npc_id
    form:Show()
    form.Visible = true
  elseif nx_number(sub_msg) == 1 then
    nx_execute("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy", "recv_show_data", unpack(arg))
  end
end
function begplayer_result(chander, arg_num, msg_type, target, rank)
  util_show_form("form_stage_main\\form_life\\form_beg_mini_list", true)
  nx_execute("form_stage_main\\form_life\\form_beg_mini_list", "Init", target, rank)
end
function on_gem_temp_skill_set(chander, arg_num, msg_type, ...)
  local form_skill = nx_value("form_stage_main\\puzzle_quest\\form_skill")
  if nx_is_valid(form_skill) then
    nx_execute("form_stage_main\\puzzle_quest\\form_skill", "get_data_and_update_form", form_skill)
  end
end
function select_target(self, arg_num, msg_type, target, select_flag)
  local fight = nx_value("fight")
  if nx_is_valid(fight) then
    fight:SelectTargetByServer(target, select_flag)
  end
end
function on_hire_shop_msg(chander, arg_num, msg_type, sub_msg, ...)
  local SUBMSG_SHOW_PRICE_FORM = 0
  local SUBMSG_SHOW_HIRE_SHOP_FORM = 1
  local SUBMSG_SHOW_HIRE_SHOP_STATE = 2
  local SUBMSG_SHOW_HIRE_SHOP_KUORONG = 3
  local SUBMSG_SEND_GOODS_LIST = 4
  local SUBMSG_SEND_SHOP_LIST = 5
  local SUBMSG_SEND_SHOPCOMPETE_LIST = 6
  local gui = nx_value("gui")
  if sub_msg == SUBMSG_SHOW_PRICE_FORM then
    local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_price")
    if nx_is_valid(form) then
      form:Close()
    end
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hire_shop\\form_hire_shop_price", true, false)
    nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop_price", form)
    local npc_id = arg[1]
    form.npcid = npc_id
    form.remain_time = arg[2]
    form.state = arg[3]
    form.cur_silver = arg[4]
    form:Show()
  elseif sub_msg == SUBMSG_SHOW_HIRE_SHOP_FORM then
    local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop")
    if nx_is_valid(form) then
      form:Close()
    end
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hire_shop\\form_hire_shop", true, false)
    nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop", form)
    local npc_id = arg[1]
    form.remain_time = arg[2]
    form.is_online = arg[3]
    form.owner = arg[4]
    form.CurMaxCapacity = arg[5]
    form.npcid = npc_id
    form:Show()
  elseif sub_msg == SUBMSG_SHOW_HIRE_SHOP_KUORONG then
    local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_show")
    if nx_is_valid(form) then
      local max_capacity = arg[1]
      nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_show", "refresh_page", form, max_capacity)
    end
  elseif sub_msg == SUBMSG_SHOW_HIRE_SHOP_STATE then
    local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_additem")
    if nx_is_valid(form) then
      local npc_id = arg[1]
      local state = arg[2]
      form.npcid = npc_id
      if state == 1 then
        form.btn_ShouTan.Visible = true
        form.btn_ChuTan.Visible = false
      else
        form.btn_ShouTan.Visible = false
        form.btn_ChuTan.Visible = true
      end
    end
  elseif sub_msg == SUBMSG_SEND_GOODS_LIST then
    local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_show")
    if not nx_is_valid(form) then
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hire_shop\\form_hire_shop_show", true, false)
      nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop_show", form)
    end
    local rows = nx_int(arg[1])
    table.remove(arg, 1)
    nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_show", "on_recv_goods_list", rows, unpack(arg))
  elseif sub_msg == SUBMSG_SEND_SHOP_LIST then
    local myShopRes = "form_stage_main\\form_hire_shop\\form_hire_shop_mine"
    local form = nx_value(myShopRes)
    if not nx_is_valid(form) then
      form = nx_execute("util_gui", "util_get_form", myShopRes, true, false)
      nx_set_value(myShopRes, form)
    end
    nx_execute(myShopRes, "on_recv_hire_shop_list", unpack(arg))
  elseif sub_msg == SUBMSG_SEND_SHOPCOMPETE_LIST then
    local path = "form_stage_main\\form_hire_shop\\form_hire_shop_my_compete"
    local form = nx_value(path)
    if not nx_is_valid(form) then
      form = nx_execute("util_gui", "util_get_form", path, true, false)
      nx_set_value(path, form)
    end
    nx_execute(path, "on_recv_hireshop_compete_list", unpack(arg))
  end
end
function on_point_consign_msg(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_consign\\consign_msg", "OnServerMsg", self, unpack(arg))
end
function on_prepare_fortunetellingother_result(self, arg_num, msg_type, target, rank)
  local form_talk = nx_value("form_stage_main\\form_life\\form_fortunetellingother_list")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  nx_execute("form_stage_main\\form_life\\form_fortunetellingother_list", "openform", target, rank)
end
function on_charge_shop_msg(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_charge_shop\\form_charge_shop", "OnServerMsg", self, unpack(arg))
end
function on_npc_personnate(self, arg_num, msg_type, ...)
  local npcid = arg[1]
  local behave = arg[2]
  if npcid == nil or behave == nil then
    return
  end
  local behave_lst = util_split_string(behave, "/")
  if table.getn(behave_lst) ~= 5 then
    return
  end
  local game_visual = nx_value("game_visual")
  local vis_obj = game_visual:GetSceneObj(nx_string(npcid))
  local times = 0
  while not nx_is_valid(vis_obj) do
    nx_pause(0)
    vis_obj = game_visual:GetSceneObj(nx_string(npcid))
    times = times + 1
    if 500 < times then
      return
    end
  end
  if game_visual:HasRoleUserData(vis_obj) then
    while not game_visual:QueryRoleCreateFinish(vis_obj) do
      nx_pause(0)
    end
  end
  link_skin(vis_obj, "hat", nx_string(behave_lst[1]) .. ".xmod")
  link_skin(vis_obj, "hair", nx_string(behave_lst[2]) .. ".xmod")
  link_skin(vis_obj, "cloth", nx_string(behave_lst[3]) .. ".xmod")
  link_skin(vis_obj, "pants", nx_string(behave_lst[4]) .. ".xmod")
  link_skin(vis_obj, "shoes", nx_string(behave_lst[5]) .. ".xmod")
end
function on_give_item(self, arg_num, msg_type, npc, ...)
  local form = nx_value("form_stage_main\\form_give_item")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_give_item", true, false)
    nx_set_value("form_stage_main\\form_give_item", form)
  end
  form.npc = nx_string(npc)
  form:Show()
end
function on_give_clone_award(self, arg_num, msg_type, award_desc, drop_id, exp_1, use_time)
  local form = nx_value("form_stage_main\\form_clone_awards")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_awards", true, false)
    nx_set_value("form_stage_main\\form_clone_awards", form)
  end
  nx_execute("form_stage_main\\form_clone_awards", "refresh_desc", form, drop_id, use_time)
  form:Show()
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    form.Visible = false
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form)
  end
  local bColAward = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_clone_col_awards")
  if bColAward then
    form.Visible = false
  end
end
function on_end_clone_award(self, arg_num, msg_type, ...)
  local form = nx_value("form_stage_main\\form_clone_awards")
  if nx_is_valid(form) then
    form:Close()
  end
  local form1 = nx_value("form_stage_main\\form_clone_awards_min")
  if nx_is_valid(form1) then
    form1:Close()
  end
end
function on_guild_bank_show(slef, arg_num, msg_type, ...)
  local npcid = arg[1]
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_guild\\form_guild_bank")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild\\form_guild_bank", true, false)
    nx_set_value("form_stage_main\\form_guild\\form_guild_bank", form)
  end
  form.npcid = npcid
  form:Show()
end
function on_spy_msg(self, arg_num, msg_type, ...)
  local sub_cmd = nx_number(arg[1])
  if sub_cmd == 1 then
    local target = nx_string(arg[2])
    local effect_name = arg[3]
    local add = nx_number(arg[4])
    nx_execute("custom_effect", "check_spy_effect", target, effect_name, 0 < add)
  elseif sub_cmd == 2 then
    local npc = arg[2]
    local funcid = nx_int(arg[3])
    local title = arg[4]
    local menu = arg[5]
    local prize_info = arg[6]
    local game_client = nx_value("game_client")
    local player = game_client:GetPlayer()
    if not nx_is_valid(player) then
      return
    end
    local lastobject = nx_object(player:QueryProp("LastObject"))
    local client_target = game_client:GetSceneObj(nx_string(lastobject))
    if not nx_is_valid(client_target) then
      return 0
    end
    local talktype = client_target:QueryProp("NpcTalkType")
    local form_talk = "form_stage_main\\form_talk_movie"
    if nx_int(talktype) == nx_int(1) then
      form_talk = "form_stage_main\\form_talk"
    end
    nx_execute(form_talk, "show_spy_prize", npc, funcid, title, menu, prize_info)
  end
end
function install_tmp_skill_item(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_itemskill", "server_install_itemskill")
end
function uninstall_tmp_skill_item(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_itemskill", "server_uninstall_itemskill")
end
function on_huihai_msg(self, arg_num, msg_type, sub_cmd, ...)
  local SUB_SERVER_NG_WEAR_REFRESH = 1
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_NG_WEAR_REFRESH) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_neigong", "refresh_ng_jinfa_rec")
  end
end
function on_fuse_begin_msg(self, arg_num, msg_type, job_id, ...)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local table_task = {
    822,
    824,
    826,
    830,
    832,
    834,
    837,
    839,
    841,
    844,
    846,
    848,
    851,
    853,
    855
  }
  local count = table.getn(table_task)
  local find = false
  for i = 1, count do
    local row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(table_task[i]), 0)
    if 0 <= row then
      find = true
      break
    end
  end
  if find == false then
    nx_execute("form_stage_main\\form_life\\form_item_fuse", "on_fuse_form_open", job_id)
  else
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("life_help_ronghe"), "1")
    nx_execute("form_stage_main\\form_life\\form_item_fuse", "on_fuse_form_open", job_id)
    nx_execute("form_stage_main\\form_life\\form_item_fuse", "on_fuse_form_open", job_id)
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "set_form_to_front")
  end
end
function on_home_msg(self, arg_num, msg_type, sub_cmd, ...)
  nx_execute("form_stage_main\\form_home\\form_home_msg", "server_to_client_msg", msg_type, sub_cmd, unpack(arg))
end
function on_skillpage_fuse_begin_msg(self, arg_num, msg_type, npcid, ...)
  nx_execute("form_stage_main\\form_life\\form_page_advance", "on_fuse_form_open", npcid)
end
function on_compound_begin_msg(self, arg_num, msg_type, job_id, ...)
  nx_execute("form_stage_main\\form_life\\form_item_book", "on_fuse_form_open", job_id)
end
function on_split_begin_msg(self, arg_num, msg_type, job_id, ...)
  nx_execute("form_stage_main\\form_life\\form_item_book", "on_fuse_form_open", job_id)
end
function on_npc_exchange_begin_msg(self, arg_num, msg_type, job_id, ...)
  nx_execute("form_stage_main\\form_life\\form_npc_exchange", "on_npc_exchange_form_open", job_id)
end
function on_changeequip_begin_msg(self, arg_num, msg_type, job_id, ...)
  nx_execute("form_stage_main\\form_life\\form_change_equip", "on_changeequip_form_open", job_id)
end
function on_contribute_begin_msg(self, arg_num, msg_type, job_id, ...)
  nx_execute("form_stage_main\\form_life\\form_contribute", "on_contribute_form_open", job_id)
end
function on_npcexchange_begin_msg(self, arg_num, msg_type, npc_id, ...)
  nx_execute("form_stage_main\\form_life\\form_npc_exchange", "on_npc_exchange_form_open", npc_id)
end
function on_upgrade_equip_msg(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_life\\form_equip_upgrade", "on_equip_upgrade_msg", unpack(arg))
end
function on_convert_equip_msg(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_life\\form_equip_upgrade", "on_convert_equip_msg", unpack(arg))
end
function on_qimen_equip_msg(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_life\\form_equip_upgrade", "on_qimen_equip_msg", unpack(arg))
end
function on_fire_guild_msg(self, arg_num, msg_type, sub_cmd, ...)
  local SERVER_SUB_CMD_FORM_DOMAIN_LIST = 0
  local SERVER_SUB_CMD_ACCEPT_WATER_TASK = 1
  local SERVER_SUB_CMD_GUILD_DOMAIN_LIST = 2
  local SERVER_SUB_CMD_ENEMY_GUILD_WITH_DOMAIN = 3
  local SERVER_SUB_CMD_DOMAIN_BUILD_INFO = 4
  local SERVER_SUB_CMD_SINGLE_BUILD_INFO = 5
  local SERVER_SUB_CMD_SELF_DOMAIN_LIST = 8
  local SERVER_SUB_CMD_TARGET_DOMAIN_LIST = 9
  local SERVER_SUB_CMD_CF_ALL_GUILD_DOMAIN = 21
  local SERVER_SUB_CMD_CF_SELF = 22
  local SERVER_SUB_CMD_CF_GET_VOTER = 23
  local SERVER_SUB_CMD_CF_GET_STAGE = 24
  local SERVER_SUB_CMD_NEW_GUILD_STRIKE_INFO = 25
  if sub_cmd == SERVER_SUB_CMD_FORM_DOMAIN_LIST then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_guild_fire\\form_guild_fire", true)
  elseif sub_cmd == SERVER_SUB_CMD_ACCEPT_WATER_TASK then
    nx_execute("form_stage_main\\form_guild_fire\\form_fire_info", "show_water_task_confirm")
  elseif sub_cmd == SERVER_SUB_CMD_GUILD_DOMAIN_LIST then
    nx_execute("form_stage_main\\form_guild_fire\\form_guild_fire", "load_fire_guild_info", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_ENEMY_GUILD_WITH_DOMAIN then
    nx_execute("form_stage_main\\form_guild_fire\\form_courtfire_info", "rec_guilds_info", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_DOMAIN_BUILD_INFO then
    nx_execute("form_stage_main\\form_guild_fire\\form_fire_interact", "set_build_fire_state", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_SINGLE_BUILD_INFO then
    nx_execute("form_stage_main\\form_guild_fire\\form_fire_interact", "set_single_fire_state", unpack(arg))
  elseif sub_cmd == 6 then
    nx_execute("form_stage_main\\form_guild_fire\\form_fire_interact", "rec_fire_player_info", unpack(arg))
  elseif sub_cmd == 7 then
    nx_execute("form_stage_main\\form_guild_fire\\form_fire_interact", "rec_water_player_info", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_SELF_DOMAIN_LIST then
    nx_execute("form_stage_main\\form_guild_fire\\form_fire_interact", "rec_self_domain_info", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_TARGET_DOMAIN_LIST then
    nx_execute("form_stage_main\\form_guild_fire\\form_fire_interact", "rec_fire_domain_info", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_CF_GET_STAGE then
    nx_execute("form_stage_main\\form_guild_fire\\form_courtfire_info", "rec_stage_info", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_CF_ALL_GUILD_DOMAIN then
    nx_execute("form_stage_main\\form_guild_fire\\form_courtfire_info", "rec_guilddomain_info", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_CF_GET_VOTER or sub_cmd == SERVER_SUB_CMD_CF_SELF then
    nx_execute("form_stage_main\\form_guild_fire\\form_courtfire_info", "rec_voter_info", unpack(arg))
  elseif sub_cmd == SERVER_SUB_CMD_NEW_GUILD_STRIKE_INFO then
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_escort", "rec_fire_newstrike_info", unpack(arg))
  end
end
function on_all_escort_list_msg(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_school_war\\form_escortpath_info", "OnEscortListMsg", unpack(arg))
end
function on_escort_info_msg(self, arg_num, msg_type, escort_info, ...)
  nx_execute("form_stage_main\\form_school_war\\form_escort_trace", "on_escort_team_info", escort_info)
end
function on_escort_open_form_msg(self, arg_num, msg_type, npcname, escort_list)
  nx_execute("form_stage_main\\form_school_war\\form_escort", "ShowEscortForm", npcname, escort_list)
end
function on_escort_begin_msg(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_school_war\\form_escort", "ClosetForm")
end
function on_escort_audio_msg(self, arg_num, msg_type, sound_name)
  local scene = nx_value("game_scene")
  local camera = scene.camera
  camera.scene = scene
  if not nx_is_valid(camera) then
    return
  end
  nx_execute("util_sound", "play_link_sound", sound_name, scene.camera, 0, 0, 0, 1, 5, 1, "snd\\action\\npc\\")
end
function on_escort_end_msg(self, arg_num, msg_type, ...)
end
function on_server_escort_time_begin(self, arg_num, msg_type, ...)
  local time = arg[1]
  local goodsnum = arg[2]
  if nx_int(0) == nx_int(time) then
    nx_execute("form_stage_main\\form_school_war\\form_escort_time_limit", "Update_goodsinfo", goodsnum)
  else
    local tolgoodsnum = arg[3]
    nx_execute("form_stage_main\\form_school_war\\form_escort_time_limit", "ShowEscortTimeLimit", time, goodsnum, tolgoodsnum)
  end
end
function on_server_escort_time_end(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_single_notice", "ClearText", nx_int(9))
end
function on_server_escort_msg(self, arg_num, msg_type, ...)
  local msg = arg[1]
  if nx_int(msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_school_war\\form_escort_trace", "on_anshao_msg", msg)
  elseif nx_int(msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_school_war\\form_escort_help", "show_escort_help_info", unpack(arg))
  elseif nx_int(msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_school_war\\form_escort_help", "show_rob_info", unpack(arg))
  end
end
function on_active_location(self, arg_num, msg_type, obj, x, y, z, o)
  local game_visual = nx_value("game_visual")
  local vis_obj = game_visual:GetSceneObj(nx_string(obj))
  if not nx_is_valid(vis_obj) then
    return
  end
  local scene = nx_value("game_scene")
  if not (nx_is_valid(scene) and nx_find_custom(scene, "terrain")) or not nx_is_valid(scene.terrain) then
    return
  end
  local terrain = scene.terrain
  local scene_obj = nx_value("scene_obj")
  scene_obj:LocatePlayer(vis_obj, x, y, z, o)
  vis_obj:SetAngle(0, o, 0)
end
function on_select_bindtype(chander, arg_num, msg_type, str_info, str_var)
  nx_execute("form_stage_main\\form_life\\form_job_bind_type_confirm", "open_form", str_info, str_var)
end
function on_split_item_form_open(chander, arg_num, msg_type, job_id)
  local form_split = nx_null()
  if nx_string(job_id) == nx_string("home_manger") then
    form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_split", true)
  else
    form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split", true)
  end
  if nx_is_valid(form_split) then
    form_split.jobid = job_id
    form_split:Show()
    form_split.Visible = true
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.Desktop:ToFront(form_split)
    end
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  end
end
function on_split_item_break_btn_show(chander, arg_num, msg_type, show, job_id)
  local form_split = nx_null()
  if nx_string(job_id) == nx_string("home_manger") then
    form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_split")
  else
    form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split")
  end
  if nx_is_valid(form_split) then
    nx_execute("form_stage_main\\form_life\\form_job_split", "process_break_btn_show", form_split, show)
  end
end
function on_fuse_item_break_btn_show(chander, arg_num, msg_type, show)
  local form_fuse = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_item_fuse")
  if nx_is_valid(form_fuse) then
    nx_execute("form_stage_main\\form_life\\form_item_fuse", "process_break_btn_show", form_fuse, show)
  end
end
function on_split_item_success(chander, arg_num, msg_type, job_id)
  local form_split = nx_null()
  if nx_string(job_id) == nx_string("home_manger") then
    form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_split")
  else
    form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split")
  end
  if nx_is_valid(form_split) then
    nx_execute("form_stage_main\\form_life\\form_job_split", "reset_control", form_split)
  end
end
function on_simulate_jump(chander, arg_num, msg_type, object, x, y, z, preparetime, jumptime)
  local game_visual = nx_value("game_visual")
  local vis_object = game_visual:GetSceneObj(nx_string(object))
  if not nx_is_valid(vis_object) then
    return
  end
  emit_player_input(vis_object, PLAYER_INPUT_LOGIC, LOGIC_SERVER_JUMP_POS, x, y, z, preparetime, jumptime)
end
function on_open_play_animation_form(chander, arg_num, msg_type, animation, isautostop)
  local form_animation = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_animation", true)
  if nx_is_valid(form_animation) then
    form_animation:Show()
    form_animation.Visible = true
    if isautostop == "skill" then
      nx_execute("form_stage_main\\form_life\\form_job_animation", "show_animation", form_animation, animation)
    else
      form_animation.animation = animation
      nx_execute("form_stage_main\\form_life\\form_job_animation", "show_form", form_animation, isautostop)
      if nx_find_custom(form_animation.ani_1, "id") and animation == "" then
        nx_execute("form_stage_main\\form_life\\form_job_animation", "show_animation", form_animation, form_animation.ani_1.id)
      end
    end
  end
end
function on_close_play_animation_form(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_life\\form_job_animation", "close_form")
end
function on_open_job_form(chander, arg_num, msg_type, num, ...)
  if 2 >= nx_number(num) then
    local form_animation = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_animation", true)
    if nx_is_valid(form_animation) then
      form_animation:Show()
      form_animation.Visible = true
      form_animation.groupbox_1.Visible = false
      nx_execute("form_stage_main\\form_life\\form_job_animation", "open_job_form", form_animation, num, unpack(arg))
    end
  else
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_res", true)
    if nx_is_valid(form) then
      form:Show()
      form.Visible = true
      nx_execute("form_stage_main\\form_life\\form_job_animation", "show_res_form", form, num)
    end
  end
end
function process_single_msg(chander, arg_num, msg_type, sub_type, value)
  if 0 == nx_number(sub_type) then
    nx_execute("form_stage_main\\form_single_check", "single_teach_form", value)
  elseif 1 == nx_number(sub_type) then
    nx_execute("form_stage_main\\form_single_check", "open_this_form")
  elseif 2 == nx_number(sub_type) then
    nx_execute("form_stage_main\\form_single_check", "custom_single_set_form", value)
  elseif 3 == nx_number(sub_type) then
    nx_execute("form_stage_main\\form_single_check", "single_player_giveup")
  elseif 4 == nx_number(sub_type) then
    nx_execute("form_stage_main\\form_single_check", "single_old_check")
  end
end
function on_start_chinese_chess_game(chander, arg_num, msg_type, server_time)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_chessnpc", "start_chinese_chess_game", server_time)
end
function on_escort_list_open(chander, arg_num, msg_type, escortnpc, ntype)
  nx_execute("form_stage_main\\form_school_war\\form_escortnpc_control_list", "show_form", escortnpc, ntype)
end
function on_escort_game_open(chander, arg_num, msg_type, keylist)
  nx_execute("form_stage_main\\form_school_war\\form_escortnpc_control_game", "show_form", keylist)
end
function on_escort_isspecialtime(chander, arg_num, msg_type, nIsTime, nMsgID)
  if nMsgID == 0 then
    nx_execute("form_stage_main\\form_school_war\\form_escort_trace", "IsSpecialTime", nIsTime)
  end
end
function on_form_livegroove_to_faculty(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_main\\form_main_player", "refresh_form_livegroove_to_faculty")
end
function on_leitai_ready_confirm(chander, arg_num, msg_type, ...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_leitai\\form_leitai_ready_confirm")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_ready_confirm", true, false)
    nx_set_value("form_stage_main\\form_leitai\\form_leitai_ready_confirm", form)
  end
  form:Show()
end
function on_begin_roll_game(chander, arg_num, msg_type, lpoint, rpoint)
  nx_execute("form_stage_main\\form_small_game\\form_rollgame", "start_roll", lpoint, rpoint)
end
function on_vip_msg(player, arg_num, msg_type, sub_cmd, ...)
  local SUB_CMD_VIP_STATUS_CHANGED = 0
  local SUB_CMD_OPEN_PATHFINDING = 1
  local SUB_CMD_CLOSE_PATHFINDING = 2
  if sub_cmd == nil then
    sub_cmd = 0
  end
  if sub_cmd == 5 then
    nx_execute("form_stage_main\\form_charge_shop\\form_charge_keep", "on_server_msg", "vip", 0, unpack(arg))
  elseif sub_cmd == 7 then
    nx_execute("form_stage_main\\form_buyvip_confirm", "open_form", unpack(arg))
  else
    nx_execute("util_vip", "on_server_msg", sub_cmd, unpack(arg))
  end
end
function on_server_leitai_call_for_confirm(player, arg_num, msg_type, time)
  if player == nil then
    return
  end
  local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_LEITAI_PK, player, nx_number(time) / 1000, "")
end
function on_server_leitai_syn_time(player, arg_num, msg_type, status, time)
  nx_execute("form_stage_main\\form_leitai\\form_leitai_time", "process_leitai_time", status, time)
end
function on_server_leitai_wager_info(self, arg_num, msg_type, npc_id)
  local old_form = nx_value("form_stage_main\\form_leitai\\form_leitai_gamble")
  if nx_is_valid(old_form) then
    nx_destroy(old_form)
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_gamble", true)
  form.leitai_wager_npc_id = npc_id
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_leitai\\form_leitai_gamble", true)
end
function on_server_leitai_reward_info(self, arg_num, msg_type, npc_id)
  local old_form = nx_value("form_stage_main\\form_leitai\\form_leitai_reward")
  if nx_is_valid(old_form) then
    nx_destroy(old_form)
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_reward", true)
  form.select_npc_id = npc_id
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_leitai\\form_leitai_reward", true)
end
function on_server_leitai_reward_count(self, arg_num, msg_type, reward_num)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_integral_reward", true)
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_leitai\\form_leitai_integral_reward", "set_leitai_reward_num", form, reward_num)
  end
end
function on_server_leitai_qiecuo_count(self, arg_num, msg_type, qiecuo_num)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_day_reward", true)
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_leitai\\form_leitai_day_reward", "set_leitai_qiecuo_num", form, qiecuo_num)
  end
end
function on_server_leitai_integral_info(self, arg_num, msg_type, integral_info)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_integral_reward", true)
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_leitai\\form_leitai_integral_reward", "set_leitai_integral_info", form, integral_info)
  end
end
function on_server_leitai_war_info(self, arg_num, msg_type, ...)
  local SERVER_SUBMSG_LEITAI_NOTICE = 0
  local SERVER_SUBMSG_LEITAI_OPEN_FORM = 1
  local SERVER_SUBMSG_LEITAI_SHOW_DIALOG = 2
  local SERVER_SUBMSG_LEITAI_SCORE_SECTION = 3
  local SERVER_SUBMSG_LEITAI_REVENGE = 4
  local SERVER_SUBMSG_LEITAI_TIME = 5
  local SERVER_SUBMSG_LEITAI_INFO = 6
  local SERVER_SUBMSG_LEITAI_APPLY_EXPENSES = 9
  if nx_number(arg[1]) == nx_number(SERVER_SUBMSG_LEITAI_NOTICE) then
    local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_PLAYER_LEITAI_PK_NOTICE, self, nx_number(30))
    if 0 < index then
      for i = 1, table.getn(arg) do
        nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, arg[i])
      end
    end
  elseif nx_int(arg[1]) == nx_int(SERVER_SUBMSG_LEITAI_OPEN_FORM) then
    local npc_id = arg[2]
    local func_type = arg[3]
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    nx_execute("form_stage_main\\form_leitai\\form_leitai", "open_form_by_func_type", func_type, npc_id, unpack(arg))
  elseif nx_number(arg[1]) == nx_number(SERVER_SUBMSG_LEITAI_SHOW_DIALOG) then
    nx_execute("form_stage_main\\form_leitai\\form_leitai", "open_form_by_func_type", nx_int(0), npc_id, unpack(arg))
  elseif nx_number(arg[1]) == nx_number(SERVER_SUBMSG_LEITAI_SCORE_SECTION) then
    nx_execute("form_stage_main\\form_leitai\\form_world_leitai_filter", "update_data_filter_info", unpack(arg))
  elseif nx_number(arg[1]) == nx_number(SERVER_SUBMSG_LEITAI_REVENGE) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_world_leitai_invite", true, false)
    if nx_is_valid(dialog) then
      dialog.InviteType = 1
      dialog.revenge_name = arg[2]
      dialog:ShowModal()
      local res = nx_wait_event(60, dialog, "confirm_return")
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return 0
      end
      local CLIENT_SUBMSG_GO_REVENGE_OR_NOT = 9
      if res == "ok" then
        game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_inx(CLIENT_SUBMSG_GO_REVENGE_OR_NOT), nx_int(1))
      elseif res == "cancel" then
        game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_GO_REVENGE_OR_NOT), nx_int(0))
      end
    end
  elseif nx_number(arg[1]) == nx_number(SERVER_SUBMSG_LEITAI_TIME) then
    nx_execute("form_stage_main\\form_leitai\\form_world_leitai_time", "on_show_time_form", unpack(arg))
  elseif nx_number(arg[1]) == nx_number(SERVER_SUBMSG_LEITAI_INFO) then
    local count = #arg
    if count < 3 then
      nx_msgbox("no player info!")
      return
    end
    local file = arg[2]
    local info_list = util_split_wstring(arg[3], ";")
    local player_count = #info_list
    if player_count == 0 then
      return
    end
    if not nx_function("ext_is_file_exist", file) then
      return
    end
    local gm_list = nx_create("StringList")
    if not gm_list:LoadFromFile(file) then
      nx_destroy(gm_list)
      return
    end
    gm_list:ClearString()
    for i = 1, player_count do
      if not gm_list:AddString(nx_string(info_list[i])) then
        nx_msgbox("Add " .. nx_string(info_list[i]) .. " error")
      end
    end
    local now_time = os.time()
    local now_date = os.date("*t", now_time)
    local new_file = string.sub(file, 1, -5) .. "_" .. nx_string(now_date.year) .. "_" .. nx_string(now_date.month) .. "_" .. nx_string(now_date.day) .. "_" .. nx_string(now_date.hour) .. "_" .. nx_string(now_date.min) .. "_" .. nx_string(now_date.sec) .. ".txt"
    gm_list:SaveToFile(new_file)
    nx_destroy(gm_list)
    nx_msgbox("Check Out Completed!")
  elseif nx_number(arg[1]) == nx_number(SERVER_SUBMSG_LEITAI_APPLY_EXPENSES) then
    if #arg < 2 then
      return
    end
    local expenses = arg[2]
    nx_execute("form_stage_main\\form_leitai\\form_leitai", "leitai_apply", expenses)
  end
end
function on_server_clone_challenge_success_record(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_clone_describe", "show_clone_scene_desc_form", unpack(arg))
end
function on_sns_search_friend_result(self, arg_num, msg_type, ...)
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(1) then
    return
  end
  if nx_number(arg[1]) == 1 then
    local form = nx_value("form_stage_main\\form_relation\\form_input_name")
    if nx_is_valid(form) and nx_find_custom(form, "is_siliao") and form.is_siliao then
      nx_execute("custom_sender", "custom_request_chat", nx_widestr(arg[2]))
      form:Close()
    else
      local searchForm = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", false, false)
      if nx_is_valid(searchForm) then
        searchForm:Close()
      end
      table.remove(arg, 1)
      custom_show_game_info(0, 0, 0, unpack(arg))
    end
  else
    nx_execute("form_stage_main\\form_relation\\form_search_result", "InitInfo", arg[1])
  end
end
function on_sns_enemy_info_result(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "get_enemy_info", unpack(arg))
end
function on_sns_player_info_result(self, arg_num, msg_type, ...)
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(2) then
    return
  end
  local menpai = arg[1]
  local roleInfo = arg[2]
  nx_execute("form_stage_main\\form_relationship", "add_self_model", menpai, roleInfo)
end
function on_sns_send_present_result(self, arg_num, msg_type, bSuccuss)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_present", false, false)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_number(bSuccuss) == 1 then
    local info = gui.TextManager:GetText("ui_sns_send_liwu_success")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
  else
    local info = gui.TextManager:GetText("ui_sns_send_liwu_falid")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
  end
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_chitchat_request_chat_result(self, arg_num, msg_type, ...)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local argnum = table.getn(arg)
  if argnum < 1 then
    return
  end
  local bSuccess = arg[1]
  if nx_number(bSuccess) == 0 then
  elseif nx_number(bSuccess) == 1 then
    if argnum < 3 then
      return
    end
    local is_groupchat = nx_int(arg[2])
    local sender_name = nx_widestr(arg[3])
    if is_groupchat == nx_int(1) then
      local group_create_form = nx_value("form_stage_main\\form_chat_system\\form_create_groupchat")
      if nx_is_valid(group_create_form) then
        group_create_form:Close()
      end
      nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "open_groupchat_window", sender_name)
    else
      nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "open_chat_window", sender_name)
    end
  elseif nx_number(bSuccess) == 2 then
  end
end
function on_chitchat_get_player_info(self, arg_num, msg_type, ...)
  local gui = nx_value("gui")
  local argnum = table.getn(arg)
  if argnum < 1 then
    return
  end
  local bSuccess = arg[1]
  if nx_number(bSuccess) == 1 then
    local table_info = {}
    for i = 2, table.getn(arg) do
      table.insert(table_info, arg[i])
    end
    nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "on_receive_security_info", unpack(table_info))
  else
  end
end
function on_chitchat_send_content_result(self, arg_num, msg_type, ...)
  local gui = nx_value("gui")
  local argnum = table.getn(arg)
  if argnum < 1 then
    return
  end
  local msg_type = nx_int(arg[1])
  local send_name = nx_widestr(arg[2])
  local chat_content = nx_widestr(arg[3])
  local chat_time = nx_string(arg[4])
  local chat_type = nx_int(arg[5])
  if send_name == nil then
    return
  end
  local controlwatch = nx_value("ControlWatch")
  if not nx_is_valid(controlwatch) then
    return
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return 0
  end
  chat_content = CheckWords:CautionWords(chat_content)
  local FORM_CHAT = "form_stage_main\\form_chat_system\\form_chat_window"
  local form_chat = nx_value(FORM_CHAT)
  if not nx_is_valid(form_chat) then
    form_chat = 0
  end
  if nx_int(msg_type) == nx_int(1) and nx_int(controlwatch.State) == nx_int(3) then
    local isStranger = nx_execute("form_stage_main\\form_chat_system\\chat_util_define", "is_strangeness", send_name)
    if isStranger and nx_int(chat_type) == nx_int(0) then
      local chat_content = gui.TextManager:GetFormatText("gcw_chat_refuse_message", nx_string(controlwatch.RefuseChatMessage))
      nx_execute(FORM_CHAT, "send_content", form_chat, send_name, chat_content, controlwatch.State)
      return
    end
  end
  local FORM_LIGHT = "form_stage_main\\form_chat_system\\form_chat_light"
  nx_execute(FORM_LIGHT, "add_record", send_name, chat_content, chat_type, chat_time)
  if nx_int(msg_type) == nx_int(1) and controlwatch.State ~= 0 and nx_int(chat_type) == nx_int(0) then
    local chat_content = ""
    if 1 == controlwatch.State then
      chat_content = gui.TextManager:GetFormatText("gcw_chat_na_message", nx_string(controlwatch.NAMessage))
    elseif 2 == controlwatch.State then
      chat_content = gui.TextManager:GetFormatText("gcw_chat_dontdisturb_message", nx_string(controlwatch.DontDisturbMessage))
    else
      return
    end
    nx_execute(FORM_CHAT, "send_content", form_chat, send_name, chat_content, controlwatch.State)
  end
end
function on_groupchat_send_content_result(self, arg_num, msg_type, ...)
  local gui = nx_value("gui")
  local argnum = table.getn(arg)
  if argnum < 3 then
    return
  end
  local send_name = nx_widestr(arg[1])
  local groupid = nx_string(arg[2])
  local chat_content = nx_widestr(arg[3])
  local chat_time = nx_string(arg[4])
  if send_name == nil then
    return
  end
  local controlwatch = nx_value("ControlWatch")
  if not nx_is_valid(controlwatch) then
    return
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return 0
  end
  chat_content = CheckWords:CautionWords(chat_content)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryProp("Name")
  if not nx_ws_equal(nx_widestr(name), nx_widestr(send_name)) then
    local FORM_LIGHT = "form_stage_main\\form_chat_system\\form_chat_light"
    nx_execute(FORM_LIGHT, "add_groupchat_record", groupid, send_name, chat_content, chat_time)
  elseif nx_function("ext_is_newpacket_link", chat_content) then
    local FORM_LIGHT = "form_stage_main\\form_chat_system\\form_chat_light"
    nx_execute(FORM_LIGHT, "add_groupchat_record", groupid, send_name, chat_content, chat_time)
  end
end
function on_chitchat_send_group_content_result(self, arg_num, msg_type, ...)
  local argnum = table.getn(arg)
  if argnum < 1 then
    return
  end
  local msg_type = nx_int(arg[1])
  local send_name = nx_widestr(arg[2])
  local chat_content = nx_widestr(arg[3])
  local chat_time = nx_string(arg[4])
  if send_name == nil then
    return
  end
  if msg_type == nx_int(1) then
    local FORM_LIGHT = "form_stage_main\\form_chat_system\\form_chat_light"
  else
  end
end
function on_sns_accpect_present_result(self, arg_num, msg_type, bSuccuss)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_acpect_present", false, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_number(bSuccuss) == 1 then
    nx_execute("form_stage_main\\form_relation\\form_acpect_present", "show_loading", form, false)
  else
    nx_execute("form_stage_main\\form_relation\\form_acpect_present", "show_loading", form, false)
  end
end
function on_sns_send_okey_result(self, arg_num, msg_type, optype)
  nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "focus_light", nx_number(optype))
  nx_execute("form_stage_main\\form_relation\\form_relation_self", "focus_light", nx_number(optype))
  nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "focus_light", nx_number(optype))
end
function on_sns_accpect_qifu_result(self, arg_num, msg_type, bSuccuss)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_acpect_qifu", false, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_number(bSuccuss) == 1 then
    nx_execute("form_stage_main\\form_relation\\form_acpect_qifu", "show_loading", form, false)
  else
    nx_execute("form_stage_main\\form_relation\\form_acpect_qifu", "show_loading", form, false)
  end
end
function on_sns_send_qifu_result(self, arg_num, msg_type, bSuccuss)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_qifu", false, false)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_number(bSuccuss) == 1 then
    local info = gui.TextManager:GetText("ui_sns_send_qifu_success")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    if nx_is_valid(form) then
      form:Close()
    end
  else
    local info = gui.TextManager:GetText("ui_sns_send_qifu_falid")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
  end
end
function on_server_sns_msg_sysinfo(self, arg_num, msg_type, feed_type, name, feed_id, feed_function, text, ...)
  return
end
function on_server_tvt_info(self, arg_num, msg_type)
  local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_TVT_INFO, "", -1)
end
function on_server_sns_msg_feed(self, arg_num, msg_type, ...)
  if is_newjhmodule() then
    return
  end
  local argnum = table.getn(arg)
  if nx_number(argnum) <= nx_number(2) then
    return
  end
  local sub_msg = arg[1]
  if nx_number(sub_msg) == nx_number(0) then
    if nx_number(argnum) ~= nx_number(9) then
      return
    end
    local snsmgr = nx_value("sns_manager")
    if not nx_is_valid(snsmgr) then
      return
    end
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if not nx_is_valid(SystemCenterInfo) then
      return
    end
    local strPara = snsmgr:GetFeedInfo(nx_int(arg[6]), nx_widestr(arg[4]))
    if nx_string(strPara) == "" then
      return
    end
    local table_feed = util_split_string(nx_string(strPara), "&")
    local num = table.getn(table_feed)
    if nx_number(num) ~= nx_number(3) then
      return
    end
    local game_config_info = nx_value("game_config_info")
    local key = util_get_property_key(game_config_info, "prompt_buddynews", 1)
    if nx_int(key) == nx_int(0) then
      return
    end
    if nx_string(table_feed[2]) == "no_send" then
      return
    end
    nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_red_dot", true)
    local table_desc = util_split_string(nx_string(arg[7]), ";")
    local desc_num = table.getn(table_desc)
    if nx_number(desc_num) <= 0 then
      return
    end
    local feed_text = nx_string(table_desc[1])
    if nx_string(table_feed[2]) ~= "" and nx_string(table_feed[2]) ~= "no_send" then
      feed_text = nx_string(table_feed[2])
    end
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName(feed_text)
    local desc_text = gui.TextManager:GetText(feed_text)
    local pos = string.find(nx_string(desc_text), "{@0:name}")
    if pos ~= nil and nx_number(pos) > 0 then
      gui.TextManager:Format_AddParam(nx_widestr(arg[4]))
    end
    if nx_number(desc_num) > 1 then
      for i = 2, desc_num do
        if nx_number(table_desc[i]) > nx_number(0) then
          gui.TextManager:Format_AddParam(nx_int(table_desc[i]))
        else
          local text_tran = gui.TextManager:GetText(table_desc[i])
          gui.TextManager:Format_AddParam(text_tran)
        end
      end
    end
    local info = gui.TextManager:Format_GetText()
    local feed_function = table_feed[3]
    local info_group = nx_widestr(arg[4]) .. nx_widestr("&") .. nx_widestr(info) .. nx_widestr("&") .. nx_widestr(arg[3]) .. nx_widestr("&") .. nx_widestr(feed_function)
    local feed_type = nx_number(table_feed[1])
    if feed_type == 2 then
      SystemCenterInfo:ShowSystemCenterInfo(info, 1)
    elseif feed_type == 3 then
      local game_config_info = nx_value("game_config_info")
      local key = util_get_property_key(game_config_info, "prompt_banners", 1)
      if nx_string(key) == nx_string("1") then
        SystemCenterInfo:ShowSystemCenterInfo(info, 4)
      end
    elseif feed_type == 5 then
      nx_execute("form_stage_main\\form_sys_notice_bottom", "add_sys_notice", nx_widestr(info_group))
    elseif feed_type == 7 then
      local index, sub_index = nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_item", 1, self)
      nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_para", index, sub_index, nx_widestr(info_group))
    elseif feed_type == 8 then
      local index, sub_index = nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_item", 2, self)
      nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_para", index, sub_index, nx_widestr(info_group))
    elseif feed_type == 9 then
      local index, sub_index = nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_item", 3, self)
      nx_execute("form_stage_main\\form_main\\form_main_request_right", "add_request_para", index, sub_index, nx_widestr(info_group))
    end
  elseif nx_number(sub_msg) == nx_number(1) then
    local time_server = arg[2]
    local num = argnum - 2
    if nx_number(num) < nx_number(10) then
      return
    end
    local feed_num = nx_number(num) / nx_number(10)
    if nx_number(feed_num) * 10 ~= nx_number(num) then
      return
    end
    local feed_text = nx_widestr("")
    for i = 3, argnum do
      feed_text = feed_text .. nx_widestr(arg[i])
      local IsEnd = false
      local feed_count = nx_int((i - 2) / 10)
      if nx_number(feed_count) > 0 and nx_number(i - 2) == nx_number(feed_count * 10) then
        IsEnd = true
      end
      if argnum > i then
        if IsEnd then
          feed_text = feed_text .. nx_widestr("*")
        else
          feed_text = feed_text .. nx_widestr("&")
        end
      end
    end
    local target_name = arg[5]
    if nx_string(target_name) == "" then
      if util_is_form_visible("form_stage_main\\form_relation\\form_feed_info") or util_is_form_visible("form_stage_main\\form_relation\\form_feed_reply") or util_is_form_visible("form_stage_main\\form_relation\\form_relation_news") then
        nx_execute("form_stage_main\\form_relation\\form_feed_info", "show_feeds", nx_widestr(feed_text))
      else
        if util_is_form_visible("form_stage_main\\form_relation\\form_feed_simple") then
          nx_execute("form_stage_main\\form_relation\\form_feed_simple", "show_feeds", nx_double(time_server), nx_widestr(feed_text))
        else
        end
      end
    else
      local form_relation_news = nx_value("form_stage_main\\form_relation\\form_relation_news")
      if nx_is_valid(form_relation_news) then
        nx_execute("form_stage_main\\form_relation\\form_feed_reply", "show_form_with_reply", nx_widestr(feed_text))
        return
      end
      if util_is_form_visible("form_stage_main\\form_relationship") then
        nx_execute("form_stage_main\\form_relation\\form_feed_reply", "show_reply", nx_widestr(feed_text))
      else
        nx_execute("form_stage_main\\form_relation\\form_feed_reply_simple", "show_reply", nx_widestr(feed_text))
      end
    end
  elseif nx_number(sub_msg) == nx_number(2) then
    if nx_number(argnum) ~= 5 then
      return
    end
    local feed_id = arg[2]
    local good = arg[3]
    local bad = arg[4]
    local reply = arg[5]
    nx_execute("form_stage_main\\form_relation\\form_feed_info", "update_feed_info_count", feed_id, good, bad, reply)
  end
end
function show_guild_girl_form(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_girl", "show_guild_girl_form", unpack(arg))
end
function custom_show_relation_add_apply(chander, arg_num, msg_type, name, relation, relation_old)
  nx_execute("form_stage_main\\form_relation\\form_relation", "on_relation_add", name, relation, relation_old)
end
function on_custom_interact_msg(self, arg_num, msg_type, sub_type, ...)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "on_recv_server_msg", sub_type, unpack(arg))
end
function on_custom_open_schoolwar_dead_form(chander, argnum, msg_type, sceneid, ...)
  local school_war_dead_info = nx_call("util_gui", "get_global_arraylist", "school_war_dead_info", true)
  school_war_dead_info.sceneid = sceneid
  for i = 1, table.getn(arg) do
    nx_set_custom(school_war_dead_info, "arg" .. nx_string(i), arg[i])
  end
end
function on_custom_updata_worldwar_publicpoint(chander, argnum, msg_type, ...)
  local worldwar_public_info = nx_call("util_gui", "get_global_arraylist", "worldwar_public_info", true)
  for i = 1, table.getn(arg) do
    nx_set_custom(worldwar_public_info, "arg" .. nx_string(i), arg[i])
  end
  local form = nx_value("form_stage_main\\form_die_world_war")
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_die_world_war", "show_picture_control", form)
end
function on_bribe_play_game_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_bribe\\form_bribe", "on_msg", unpack(arg))
end
function on_home_point_game_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_homepoint\\form_home_point", "InitHomePointForm", unpack(arg))
end
function on_home_point_msg(chander, arg_num, msg_type, sub_type, ...)
  if nx_int(1) == nx_int(sub_type) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "homepoint_guide_flag", true)
  else
    nx_execute("form_stage_main\\form_homepoint\\form_home_point", "on_homepoint_msg", sub_type, unpack(arg))
  end
end
function on_recive_newneigongpk_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_newneigongpk\\form_newneigongpk_msg", "on_recive_msg", unpack(arg))
end
function on_recive_gmcc_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_gmcc\\form_gmcc_msg_call", "on_recive_gmcc_msg", unpack(arg))
end
function on_custom_show_public_msgbox(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_public_msgbox", "show_msgbox", unpack(arg))
end
function on_custom_show_public_inputbox(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_public_inputbox", "show_inputbox", unpack(arg))
end
function on_custom_school_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "show_msg_info", unpack(arg))
end
function on_custom_school_homepoint_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "show_homepoint_info", unpack(arg))
end
function on_custom_adjust_obj_angle(chander, arg_num, msg_type, client_obj, x, z)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_obj = game_visual:GetSceneObj(nx_string(client_obj))
  if not nx_is_valid(visual_obj) then
    return
  end
  local scene_obj = nx_value("scene_obj")
  if not nx_is_valid(scene_obj) then
    return
  end
  scene_obj:SceneObjAdjustAngle(visual_obj, x, z)
end
function on_custom_unenthrall_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_enthrall\\enthrall", "on_server_msg", unpack(arg))
end
function on_pop_repair_form(chander, arg_num, msg_type, ...)
  local repair_type = arg[1]
  local money = arg[2]
  local param1 = arg[3]
  local param2 = arg[4]
  local serviceman = arg[5]
  local silvertype = arg[6]
  local card_num = arg[7]
  local silver_num = arg[8]
  nx_execute("form_stage_main\\form_bag_func", "show_form", repair_type, money, param1, param2, serviceman, silvertype, card_num, silver_num)
end
function on_pop_repair_addbag(chander, arg_num, msg_type, ...)
  local viewid = arg[1]
  local index = arg[2]
  local money = arg[3]
  nx_execute("form_stage_main\\form_bag_func", "show_repair_addbag_form", viewid, index, money)
end
function on_open_fight_form(chander, arg_num, msg_type, arg_1, arg_2)
  nx_execute("form_stage_main\\form_helper\\form_fight_help", "util_open_fight_info", nx_number(arg_1), nx_number(arg_2))
end
function on_update_free_fight_rank(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_school_war\\form_free_fight_rank", "openform", unpack(arg))
end
function on_end_free_fight_rank(chander, arg_num, msg_type, ...)
  util_show_form("form_stage_main\\form_school_war\\form_free_fight_rank", false)
end
function begin_task_1201(chander, arg_num, msg_type, Repute, npc_ident, ...)
end
function on_open_shortcut_key_form(chander, arg_num, msg_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shortcut_key", true, false)
  dialog:ShowModal()
end
function on_npc_head_talking(chander, arg_num, msgid, talk_obj, talk_id, ...)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(talk_id)
  for i, para in pairs(arg) do
    local type = nx_type(para)
    if type == "widestr" then
      gui.TextManager:Format_AddParam(para)
    end
  end
  local info = gui.TextManager:Format_GetText()
  local ident = nx_string(talk_obj)
  local game_client = nx_value("game_client")
  local client_scene_obj = game_client:GetSceneObj(ident)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowChatTextOnHead(client_scene_obj, nx_widestr(info), 5000)
  end
end
function on_open_helper_show(chander, arg_num, msgid, ...)
  local help_id = arg[1]
  if nil == help_id then
    return
  end
  if "help_nei_gong" == help_id then
    util_auto_show_hide_form("form_stage_main\\form_help\\form_help_NeiGongLang")
  else
    nx_execute("form_stage_main\\form_help\\form_help_AllGui_New", "init_help_form", help_id)
  end
end
function on_close_leitai_time_panel(chander, arg_num, msgid, ...)
  local form = nx_value("form_stage_main\\form_leitai\\form_leitai_time")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_buffer_change(chander, arg_num, msgid, type, buffer_id, owner, sender, owner_name, sender_name, ...)
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    return
  end
  if type == "add" then
    local end_time = arg[1]
    local category = arg[2]
    local form_main_buff = nx_value("form_main_buff")
    if nx_is_valid(form_main_buff) and end_time ~= nil and category ~= nil then
      form_main_buff:add_buffer_info(buffer_id, nx_string(owner), nx_int(category), nx_int64(end_time))
    end
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:BufferInfo(owner_name, sender_name, buffer_id, type)
    end
  elseif type == "remove" then
    local form_main_buff = nx_value("form_main_buff")
    if nx_is_valid(form_main_buff) then
      form_main_buff:del_buffer_info(buffer_id, nx_string(owner))
    end
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:BufferInfo(owner_name, sender_name, buffer_id, type)
    end
  elseif type == "update" then
    local end_time = arg[1]
    local category = arg[2]
    local form_main_buff = nx_value("form_main_buff")
    if nx_is_valid(form_main_buff) and end_time ~= nil and category ~= nil then
      form_main_buff:add_buffer_info(buffer_id, nx_string(owner), nx_int(category), nx_int64(end_time))
    end
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:BufferInfo(owner_name, sender_name, buffer_id, type)
    end
  end
end
function on_can_use_skill(chander, arg_num, msgid, skill_id, val, check_type)
  check_type = nx_number(check_type)
  local goods_grid = nx_value("GoodsGrid")
  local fight = nx_value("fight")
  if not nx_is_valid(goods_grid) or not nx_is_valid(fight) then
    return
  end
  if check_type == 1 then
    if nx_string(goods_grid.wait_skill) == nx_string(skill_id) and nx_number(val) > 0 then
      local skill = fight:FindSkill(skill_id)
      local radius = skill:QueryProp("HitShapePara2")
      local range = skill:QueryProp("TargetShapePara2")
      nx_execute("game_effect", "add_ground_pick_effect", radius * 2, range)
    end
  elseif check_type == 2 then
    if nx_number(val) > 0 then
    end
  else
    return
  end
end
function on_show_sole_prompt(chander, arg_num, msg_type, val1, val2)
  nx_execute("form_stage_main\\form_sys_sole_prompt", "show_sole_prompt_msg", val1, val2)
end
function on_auto_equip_shotweapon(chander, arg_num, msg_type, val1)
  local game_config_info = nx_value("game_config_info")
  util_set_property_key(game_config_info, "auto_equip_shotweapon", nx_int(val1))
end
function on_show_faction(chander, arg_num, msg_type, ...)
  local faction_name = arg[2]
  local faction_state = arg[3]
  local num = arg[4]
  nx_execute("form_stage_main\\form_map\\form_map_scene", "show_faction", faction_name, faction_state, num)
end
function on_open_xietie_msg(chander, arg_num, msg_type, ...)
  local player = arg[1]
  local carrywords = arg[2]
  nx_execute("form_stage_main\\form_relation\\form_present", "on_show_xitie", player, carrywords)
end
function on_recive_systemfriends_msg(chander, arg_num, msg_type, ...)
  local arg_count = table.getn(arg)
  local sender_type = arg[1]
  local other_arg = {}
  for i = 2, arg_count do
    table.insert(other_arg, arg[i])
  end
  util_show_form("form_stage_main\\form_relation\\form_system_friends", true)
  nx_execute("form_stage_main\\form_relation\\form_system_friends", "init_date", sender_type, unpack(other_arg))
end
function on_recive_schoolpose_vote(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_SCHOOL_VOTE, "", -1)
end
function on_recive_schoolpose_prompt(chander, arg_num, msg_type, ...)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("Name") then
    return
  end
  local gui = nx_value("gui")
  nx_execute("form_stage_main\\form_main\\form_laba_info", "send_laba_immediate", nx_widestr(gui.TextManager:GetText("ui_xiaolaba_special_tishi_3")), nx_widestr(gui.TextManager:GetFormatText("ui_xiaolaba_special_title_3", nx_widestr(client_player:QueryProp("Name")))), 7, CONFIRM_SCHOOLPOSE_PROMPT)
end
function on_recive_ruselt_gifttonpc_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_present_to_npc", "on_result_from_server", unpack(arg))
end
function on_table_info(chander, arg_num, msg_type, ownername, table_remaintime, item_name, compose_remaintime, ...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  dialog.relogin_btn.Visible = false
  dialog.cancel_btn.Visible = false
  local gui = nx_value("gui")
  dialog.VAnchor = "Top"
  dialog.HAnchor = "Left"
  dialog.lbl_1.Text = nx_widestr(gui.TextManager:GetText("ui_dazaotai_info05"))
  dialog.lbl_1.Left = (dialog.Width - dialog.lbl_1.Width) / 2
  gui.TextManager:Format_SetIDName("ui_dazaotai_info01")
  gui.TextManager:Format_AddParam(ownername)
  local text = gui.TextManager:Format_GetText() .. nx_widestr("<br>")
  gui.TextManager:Format_SetIDName("ui_dazaotai_info02")
  gui.TextManager:Format_AddParam(nx_int(table_remaintime / 3600))
  gui.TextManager:Format_AddParam(nx_int(table_remaintime % 3600 / 60))
  text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
  if item_name ~= nil then
    gui.TextManager:Format_SetIDName("ui_dazaotai_info03")
    gui.TextManager:Format_AddParam(item_name)
    text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
    gui.TextManager:Format_SetIDName("ui_dazaotai_info04")
    gui.TextManager:Format_AddParam(nx_int(compose_remaintime / 3600))
    gui.TextManager:Format_AddParam(nx_int(compose_remaintime % 3600 / 60))
    text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
  end
  if table.getn(arg) > 0 then
    local next_item = arg[1]
    gui.TextManager:Format_SetIDName("ui_dazaotai_info07")
    gui.TextManager:Format_AddParam(next_item)
    text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:Show()
end
function on_arrest_warrant(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_arrest\\form_arrest", "deal_arrest_message", unpack(arg))
end
function on_school_vote_info(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_school_war\\form_school_vote", "show_voteform", arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9])
end
function on_refresh_client_npc(chander, arg_num, msg_type, client_npc_file)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local client_npc_manager = nx_value("client_npc_manager")
  if not nx_is_valid(client_npc_manager) then
    return
  end
  client_npc_manager:Clear()
  local filepath
  if not nx_find_custom(client_npc_manager, "filepath") then
    return
  end
  if not client_scene:FindProp("ClineNpcFile") then
    return
  end
  local client_file_name = nx_string(client_scene:QueryProp("ClineNpcFile")) .. ".ini"
  client_npc_manager:Load(client_npc_manager.filepath .. client_file_name)
end
function on_zhenfa_liezhen(chander, arg_num, msg_type, ...)
  local type = arg[1]
  if nx_int(type) == nx_int(1) then
    local skillID = arg[2]
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_liezhen_captain", "show_form", skillID)
  elseif nx_int(type) == nx_int(2) then
    local skillID = arg[2]
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_liezhen_member", "show_form", skillID)
  elseif nx_int(type) == nx_int(3) then
    local point = arg[2]
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_liezhen_captain", "add_liezhen_point", point)
  elseif nx_int(type) == nx_int(4) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_liezhen_captain", "hide_form", point)
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_liezhen_member", "hide_form", point)
  end
end
function on_boss_call_help(chander, arg_num, msg_type, boss_configid, boss_help_info)
  local bCallHelp = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_boss_help")
  if not bCallHelp then
    nx_execute("form_stage_main\\form_boss_help", "show_boss_help_info", boss_configid, boss_help_info)
  end
end
function on_cpf_helper(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_cpf_helper", "custom_handle", unpack(arg))
end
function on_version_nomatch(chander, arg_num, msg_type, ...)
end
function on_qs_helper(chander, arg_num, msg_type, player_name, help_info)
  local bCallHelp = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_force_school\\form_qs_helper")
  if not bCallHelp then
    nx_execute("form_stage_main\\form_force_school\\form_qs_helper", "show_boss_help_info", player_name, help_info)
  end
end
function on_open_freshman_help(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_system\\form_system_interface_guide", "auto_show_hide_guide")
  local form = nx_value("form_stage_main\\form_system\\form_system_interface_guide")
  form.first_flag = true
end
function on_parser_customizing(chander, arg_num, msg_type, ...)
  local customizing = nx_value("customizing_manager")
  if not nx_is_valid(customizing) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  local customstr = arg[1]
  customizing:UpdateToConfigObj(customstr)
  if nx_string(customstr) == nx_string("") then
    nx_execute("game_config", "init_game_config_info", game_config_info)
  end
  game_config_info.camera_value = 0
  game_config_info.game_control_mode = 0
  nx_execute("game_config", "save_game_config", game_config, "system_set.ini", "main")
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  nx_execute("form_stage_main\\form_camera\\form_movie_save", "Save_movie_config", false)
end
function on_freshman_open_help_info(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main_map", "add_regulations_note", arg[1])
  nx_execute("form_stage_main\\form_main\\form_main", "open_btn_freshman", arg[1])
end
function on_buy_captal_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_consign\\form_buy_capital", "on_server_msg", unpack(arg))
end
function on_fight_error_sysinfo(self, arg_num, msg_type, error_index, ...)
  nx_execute("form_test\\form_fight_error_info", "server_add_fight_error_info", error_index)
end
function on_check_appearance(self, arg_num, msg_type, number, ...)
  math.randomseed(os.clock())
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return
  end
  local GameReceiver = sock.Receiver
  if not nx_is_valid(GameReceiver) then
    return
  end
  if not nx_find_method(GameReceiver, "CheckMemState") then
    return
  end
  local iRetNumber = nx_int(number)
  if GameReceiver:CheckMemState() then
    iRetNumber = iRetNumber + math.random(1, 100)
  end
  nx_execute("custom_sender", "custom_check_appearance", iRetNumber)
end
function on_server_id(self, arg_num, msg_type, server_id)
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    game_config.server_id = server_id
  end
end
function on_login_account(self, arg_num, msg_type, login_account)
  local operators_name = get_operators_name()
  if OPERATORS_TYPE_SNDA ~= operators_name then
    return
  end
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    local account = nx_string(login_account)
    if string.sub(account, 1, 2) == "$#" then
      account = string.sub(account, 3, string.len(account))
    end
    game_config.login_account = account
  end
end
function on_login_account_id(self, arg_num, msg_type, login_account_id)
  if login_account_id == 0 then
    return
  end
  local str = " 10 " .. nx_string(login_account_id)
  local path = nx_work_path() .. "GameFetchEx.exe" .. str
  nx_function("ext_win_exec", path)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  game_config.login_account_id = nx_string(login_account_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("IsBindYY") then
    return
  end
  if client_player:QueryProp("IsBindYY") == 0 then
    return
  end
end
function on_close_skillitem_form(chander)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_itemskill", "close_itemskill_form")
end
function on_open_clone_col_award(self, arg_num, msg_type, score_level, ntotal_score, col_use_time, col_try_count)
  local form = util_get_form("form_stage_main\\form_clone_col_awards", true, false)
  form.Visible = true
  form:Show()
  local award_form = nx_value("form_stage_main\\form_clone_awards")
  if nx_is_valid(award_form) then
    award_form.Visible = false
  end
  nx_execute("form_stage_main\\form_clone_col_awards", "refresh_col_award_form", form, score_level, ntotal_score, col_use_time, col_try_count)
end
function on_boss_strength_change(self, arg_num, msg_type, boss_id, ...)
  local form = util_get_form("form_stage_main\\form_clone_reduce_difficulty", true, false)
  form.Visible = true
  form:Show()
  nx_execute("form_stage_main\\form_clone_reduce_difficulty", "refresh_form", form, boss_id, unpack(arg))
end
function custom_market_msg(self, arg_num, msg_type, sub_cmd, arg1, arg2)
  nx_execute("form_stage_main\\form_market\\form_market", "on_market_msg", sub_cmd, arg1, arg2)
end
function on_custom_request_sure_dialog_model(chander, arg_num, msg_type, tvt_type, string_id, ...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.relogin_btn.Visible = false
  dialog.cancel_btn.Visible = false
  dialog:ShowModal()
  local index = dialog.mltbox_info:AddHtmlText(util_format_string(string_id, unpack(arg)), -1)
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  local bret = 0
  if res == "ok" then
    bret = 1
  end
  nx_execute("form_stage_main\\form_tvt\\define", "send_server_msg", bret, tvt_type)
end
function on_multi_ride(self, arg_num, msg_type, handle_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "multi_ride_handle", handle_type, unpack(arg))
end
function on_custom_rob_prison(self, arg_num, msg_type, sub_type, ...)
  if nx_number(sub_type) == 0 then
    nx_execute("form_stage_main\\form_rob_prison\\from_rob_prison_apply", "show_rob_prison_apply", unpack(arg))
  elseif nx_number(sub_type) == 1 then
    nx_execute("form_stage_main\\form_rob_prison\\form_rob_prison_detail", "show_rob_prison_detail", unpack(arg))
  end
end
function on_dare_school_task(self, arg_num, msg_type, submsg, ...)
  if submsg == 0 then
    nx_execute("form_stage_main\\form_task\\form_dare_school_task", "on_open_form", unpack(arg))
  elseif submsg == 1 then
    nx_execute("form_stage_main\\form_task\\form_dare_school_task", "refresh_complete_task", arg[1])
  elseif submsg == 2 then
    nx_execute("form_stage_main\\form_task\\form_dare_school_task", "tool_item_removed")
  end
end
function on_check_second_word(self, arg_num, msg_type, ...)
  local SERVER_SUBMSG_NO_HAVE_WORD = 0
  local SERVER_SUBMSG_SECOND_WORD_MODIFY = 1
  local SERVER_SUBMSG_SECOND_WORD_CHECK = 2
  local SERVER_SUBMSG_QUERY_MOBILE_CODE = 3
  local SERVER_SUBMSG_RESET_SECOND_WORD = 4
  local SERVER_SUMMSG_PROTECT_TIME_MODIFY = 5
  local SERVER_SUBMSG_QUERY_MAIL_CODE = 6
  local sub_msg_index = arg[1]
  if sub_msg_index == SERVER_SUBMSG_NO_HAVE_WORD then
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\from_word_protect\\form_protect_tips", true)
    local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
    if bMovie then
      form.Visible = false
      nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form)
    end
  elseif sub_msg_index == SERVER_SUBMSG_SECOND_WORD_MODIFY then
    nx_execute("form_stage_main\\from_word_protect\\form_protect_set", "open_sencond_word_set", 0)
  elseif sub_msg_index == SERVER_SUBMSG_SECOND_WORD_CHECK then
    local count = 0
    if 1 < table.getn(arg) then
      count = arg[2]
    end
    nx_execute("form_stage_main\\from_word_protect\\form_protect_sure", "show_form_protect_sure", nx_int(count))
  elseif sub_msg_index == SERVER_SUBMSG_QUERY_MOBILE_CODE then
    nx_execute("form_stage_main\\from_word_protect\\form_enthrall_secword", "on_server_msg", unpack(arg))
  elseif sub_msg_index == SERVER_SUBMSG_RESET_SECOND_WORD then
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\from_word_protect\\form_protect_tips", true)
    local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
    if bMovie then
      form.Visible = false
      nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form)
    end
    form = nx_value("form_stage_main\\from_word_protect\\form_enthrall_secword")
    if nx_is_valid(form) then
      form:Close()
    end
  elseif sub_msg_index == SERVER_SUMMSG_PROTECT_TIME_MODIFY then
    nx_execute("form_stage_main\\from_word_protect\\form_time_protect", "show_form")
  elseif sub_msg_index == SERVER_SUBMSG_QUERY_MAIL_CODE then
    nx_execute("form_stage_main\\from_word_protect\\form_secword_bymail_confirm", "on_server_msg", unpack(arg))
  end
end
function on_begin_drama(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_task\\form_drama_tips", "show_begin_drama_info", unpack(arg))
end
function on_minigame_wq_is_look(self, arg_num, msg_type, player)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = gui.TextManager:GetText("ui_qishi_islook")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_wqgame_look", player)
  end
end
function on_open_single_limit_form(self, arg_num, msg_type, ...)
  local n = #arg
  if n < 4 then
    return
  end
  local max_count = -1
  local limit_name_arg = {}
  if 5 <= n then
    max_count = nx_number(arg[5])
    for i = 6, n do
      table.insert(limit_name_arg, arg[i])
    end
  end
  nx_execute("form_stage_main\\form_single_notice", "show_form", nx_number(arg[1]), nx_number(arg[2]), nx_string(arg[3]), arg[4], max_count, unpack(limit_name_arg))
end
function on_close_single_limit_form(self, arg_num, msg_type, ...)
  if table.getn(arg) < 3 then
    return
  end
  nx_execute("form_stage_main\\form_single_notice", "remove_item", nx_number(arg[1]), nx_number(arg[2]), nx_string(arg[3]))
end
function on_adve_summon_request(self, arg_num, msg_type, adve_name, group_id)
  nx_execute("form_stage_main\\form_jianghu_help", "show_jianghu_help_info", adve_name, group_id)
end
function on_mobile_comfirm(chander, arg_num, msg_type, ...)
  local subtype = arg[1]
  table.remove(arg, 1)
  if nx_int(subtype) == nx_int(1) then
    nx_execute("form_stage_main\\form_enthrall\\form_mobilecode", "on_server_msg", unpack(arg))
  elseif nx_int(subtype) == nx_int(2) then
    nx_execute("form_stage_main\\form_enthrall\\form_mobilemonth", "on_server_msg", unpack(arg))
  elseif nx_int(subtype) == nx_int(3) or nx_int(subtype) == nx_int(4) then
    nx_execute("form_stage_main\\form_enthrall\\form_mobilemonth_drawprize", "on_server_msg", subtype, unpack(arg))
  end
end
function on_open_prize_code(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_enthrall\\form_prizecode", "on_server_msg", unpack(arg))
end
function on_keep_item(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_charge_shop\\form_charge_keep", "on_server_msg", "item", unpack(arg))
end
function on_open_school_introduce(self, arg_num, msg_type, type)
  if nx_int(type) == nx_int(1) then
    util_auto_show_hide_form("form_stage_main\\form_main\\form_school_introduce")
  else
    nx_execute("form_stage_create\\form_main_join_school", "open_form")
  end
end
function on_join_school_movie(self, arg_num, msg_type, cartoon_id)
  nx_execute("form_stage_main\\form_school_war\\form_school_join", "on_join_school", nx_string(cartoon_id))
  local ret = nx_execute("form_stage_main\\form_help\\form_help_thd_lead", "on_is_lead", nx_string(cartoon_id))
  if ret == false then
    return
  end
  local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_TAOHUA_LEAD, nx_string("noplayer"), -1)
  if 0 < index then
    nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, nx_string(cartoon_id))
  end
end
function on_npc_show(chander, arg_num, msg_type, NpcType)
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "on_show_scene_npc", map_query:GetCurrentScene(), nx_int(NpcType))
  end
end
function on_open_equip_blend(chander, arg_num, msg_type, opt)
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "open_form")
end
function on_refresh_huanpi_blend(chander, arg_num, msg_type, ...)
  local form_equipblend = nx_value("form_stage_main\\form_equipblend")
  if not nx_is_valid(form_equipblend) then
    return
  end
  local cell_name = nx_string(arg[1])
  local configid = nx_string(arg[2])
  nx_execute("form_stage_main\\form_equipblend", "show_huanpi_grid", form_equipblend, cell_name, configid)
end
function on_delete_huanpi_blend(chander, arg_num, msg_type, ...)
  local form_equipblend = nx_value("form_stage_main\\form_equipblend")
  if not nx_is_valid(form_equipblend) then
    return
  end
  local view_index = nx_int(arg[1])
  nx_execute("form_stage_main\\form_equipblend", "clear_huapi_grid", form_equipblend, view_index)
end
function on_equip_blend_success(chander, arg_num, msg_type, ...)
  local form_equipblend = nx_value("form_stage_main\\form_equipblend")
  if not nx_is_valid(form_equipblend) then
    return
  end
  local success_num = nx_int(arg[1])
  nx_execute("form_stage_main\\form_equipblend", "equip_blend_success", form_equipblend, success_num)
end
function on_open_gift_code(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_enthrall\\form_giftcode", "on_server_msg", unpack(arg))
end
function on_open_yytask_code(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_enthrall\\form_yytaskcode", "on_server_msg", unpack(arg))
end
function on_process_pet_sable(chander, arg_num, msg_type, ...)
  local arg_count = table.getn(arg)
  local handle_type = nx_number(arg[1])
  if handle_type == 0 then
    local form = nx_value("form_stage_main\\form_animalkeep\\form_sable_info")
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_animalkeep\\form_sable_info", "main_form_close", form)
    end
  elseif handle_type == 1 then
    local item_config = arg[2]
    local item_name = arg[3]
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_animalkeep\\form_sable_info", true)
    nx_execute("form_stage_main\\form_animalkeep\\form_sable_info", "init_sableinfo", form, item_config, item_name)
  elseif handle_type == 2 then
    nx_execute("form_stage_main\\form_animalkeep\\form_sable_info", "sable_map_pos_handle", unpack(arg))
  end
end
function on_open_sable_sikll(chander, arg_num, msg_type, ...)
  local arg_count = table.getn(arg)
  local handle_type = arg[1]
  if nx_number(handle_type) == 0 then
    local form = nx_value("form_stage_main\\form_animalkeep\\form_sable_skill")
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_animalkeep\\form_sable_skill", "server_close_sable_skill", form)
    end
  else
    local item_config = arg[2]
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_animalkeep\\form_sable_skill", true)
    nx_execute("form_stage_main\\form_animalkeep\\form_sable_skill", "server_open_sable_skill", form, item_config)
  end
end
function on_yufeng_hold_power(chander, arg_num, msg_type, ...)
  local arg_count = table.getn(arg)
  local handle_type = arg[1]
  if nx_number(handle_type) == 0 then
    local form = nx_value("form_stage_main\\form_yufeng_power")
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_yufeng_power", "server_close_power_skin", form)
    end
  else
    local item_config = arg[2]
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_yufeng_power", true)
    nx_execute("form_stage_main\\form_yufeng_power", "server_open_power_skin", form, item_config)
  end
end
function on_normal_pet_msg(chander, arg_num, msg_type, ...)
  if nx_int(msg_type) == nx_int(0) then
    nx_execute("form_stage_main\\form_magicslave\\form_magicslave_skill", "server_custom_message_callback", unpack(arg))
  end
end
function on_kapai_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_origin\\form_kapai", "on_server_msg", unpack(arg))
end
function on_open_check_switch_enable(chander, arg_num, msg_type, switch_type, enable)
  nx_execute("form_stage_main\\switch\\util_switch_function", "on_query_switch", switch_type, enable)
end
function custom_open_holiday_active(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_active", "on_srv_msg", unpack(arg))
end
function on_jyz_sever_msg_handle(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_main", "custom_message_callback", unpack(arg))
end
function on_jyz_high_light_btn(chander, arg_num, msg_type, ...)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if nx_is_valid(form) then
    local bIsNewJHModule = is_newjhmodule()
    if bIsNewJHModule then
      return
    end
    form.lbl_9yin.Visible = true
  end
end
function on_jyz_map_icon_state(chander, arg_num, msg_type, ...)
  local arg_count = table.getn(arg)
  if arg_count < 2 then
    return
  end
  local map_type = nx_int(arg[1])
  local flag = nx_int(arg[2]) ~= nx_int(0)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "show_npc_by_type", map_type, flag)
end
function on_trigger_debug_show(chander, arg_num, msg_type, ...)
  nx_execute("form_test\\form_trigger_show", "server_msg_handle", unpack(arg))
end
function on_query_fresh_man(chander, arg_num, msg_type, ...)
  local dialog_black = nx_execute("util_gui", "util_get_form", "form_single_blackback", true, false)
  dialog_black:ShowModal()
  local dialog = nx_execute("util_gui", "util_get_form", "form_single_select", true, false)
  if not nx_is_valid(dialog) then
    dialog_black:Close()
    nx_destroy(dialog_black)
    return
  end
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_single_step", 4)
    dialog_black:Close()
    nx_destroy(dialog_black)
    return
  end
  local dialog_question = nx_execute("util_gui", "util_get_form", "form_single_question", true, false)
  if not nx_is_valid(dialog_question) then
    dialog_black:Close()
    nx_destroy(dialog_black)
    return
  end
  dialog_question:ShowModal()
  local res_question = nx_wait_event(100000000, dialog_question, "confirm_return")
  if res_question == "can_skip" then
    nx_execute("custom_sender", "custom_send_single_step", 5)
  else
    nx_execute("custom_sender", "custom_send_single_step", 4)
  end
  dialog_black:Close()
  nx_destroy(dialog_black)
end
function on_alchemy_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_life\\form_item_alchemy", "on_server_msg", unpack(arg))
end
function on_treasurebox_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_life\\form_treasure_box", "on_server_msg", unpack(arg))
end
function on_use_tonic(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_jingmai", "on_tonic_msg")
end
function custom_jingmai_msg(chander, arg_num, msg_type, sub_cmd, ...)
  local MSG_SERVER_WEAR_WUJI_INFO = 4
  local MSG_SERVER_WEAR_WUJI_REFRESH = 5
  local MSG_SERVER_LEARN_WUJI_INFO = 6
  local MSG_SERVER_OVER_LOAD = 7
  local MSG_SERVER_DEL_WUJI_INFO = 8
  local MSG_SERVER_NEW_HELPER = 9
  if sub_cmd == MSG_SERVER_NEW_HELPER then
    local helper_form = nx_value("helper_form")
    if helper_form then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
    return
  end
  if sub_cmd == MSG_SERVER_WEAR_WUJI_INFO or sub_cmd == MSG_SERVER_WEAR_WUJI_REFRESH or sub_cmd == MSG_SERVER_LEARN_WUJI_INFO or sub_cmd == MSG_SERVER_OVER_LOAD or sub_cmd == MSG_SERVER_DEL_WUJI_INFO then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", "on_wuji_msg", sub_cmd, unpack(arg))
  else
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_jingmai", "on_jingmai_msg", sub_cmd, unpack(arg))
  end
end
function on_gamble_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_huashan\\form_gamble_main_msg", "on_server_msg", unpack(arg))
end
function custom_box_event(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_box_event_prize", "on_server_msg", unpack(arg))
end
function custom_treasure_chest(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_treasure_chest", "on_server_msg", unpack(arg))
end
function custom_avenge(chander, arg_num, msg_type, ...)
  local sub_msg = arg[1]
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_avenge_search", true, false)
  if nx_number(sub_msg) == nx_number(1) then
    local avenge_serve_type = arg[2]
    if nx_is_valid(form) then
      if nx_number(avenge_serve_type) == nx_number(1) then
        form.npc_id = nx_string(arg[3])
        form.npc_scene_id = nx_int(arg[4])
      end
      form.avenge_serve_type = nx_int(avenge_serve_type)
      form:ShowModal()
    end
  elseif nx_number(sub_msg) == nx_number(2) then
    if nx_is_valid(form) and form.Visible then
      nx_execute("form_stage_main\\form_relation\\form_avenge_search", "show_avenge_form", form, unpack(arg))
    end
  elseif nx_number(sub_msg) == nx_number(3) then
    if nx_is_valid(form) and form.Visible then
      nx_execute("form_stage_main\\form_relation\\form_avenge_search", "player_not_exist", form)
    end
  elseif nx_number(sub_msg) == nx_number(4) then
    if nx_is_valid(form) and form.Visible then
      nx_execute("form_stage_main\\form_relation\\form_avenge_search", "player_deleted", form)
    end
  elseif nx_number(sub_msg) == nx_number(5) then
    if nx_is_valid(form) and form.Visible then
      nx_execute("form_stage_main\\form_relation\\form_avenge_search", "player_karma_beyond", form)
    end
  elseif nx_number(sub_msg) == nx_number(6) then
    if nx_is_valid(form) and form.Visible then
      nx_execute("form_stage_main\\form_relation\\form_avenge_search", "self_karma_none", form)
    end
  elseif nx_number(sub_msg) == nx_number(7) then
    nx_execute("form_stage_main\\form_relation\\form_avenge_confirm", "show_avenge_payoff_confirm", unpack(arg))
  elseif nx_number(sub_msg) == nx_number(8) then
    nx_execute("form_stage_main\\form_relation\\form_avenge_confirm", "show_avenge_goto_confirm", unpack(arg))
  elseif nx_number(sub_msg) == nx_number(9) then
    nx_execute("form_stage_main\\form_relation\\form_avenge_confirm", "show_avenge_switch", unpack(arg))
  end
end
function on_teacher_pupil_msg(chander, arg_num, msg_type, sub_type, ...)
  if nx_int(sub_type) == nx_int(0) then
    nx_execute("form_stage_main\\form_teacher_pupil\\form_teacherpupil_register", "on_server_msg", unpack(arg))
  elseif nx_int(sub_type) == nx_int(6) then
    nx_execute("form_stage_main\\form_teacher_pupil\\form_teacherpupil_shop", "on_server_msg", sub_type, unpack(arg))
  else
    nx_execute("form_stage_main\\form_teacher_pupil\\form_teacherpupil_request", "on_server_msg", sub_type, unpack(arg))
  end
end
function custom_gongxun_msg(self, arg_num, msg_type, gxd, ...)
  nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "refresh_gxd", gxd)
end
function custom_clonestore_openlight(chander, arg_num, msg_type, ...)
  local FORM_CLONE_LIGHT = "form_stage_main\\form_clone_store\\form_clone_light"
  local FORM_CLONE_STORE = "form_stage_main\\form_clone_store\\form_clone_store"
  local form_clone_light = nx_value(FORM_CLONE_LIGHT)
  if nx_is_valid(form_clone_light) then
    form_clone_light:Close()
  end
  local form_clone_store = nx_value(FORM_CLONE_STORE)
  if nx_is_valid(form_clone_store) then
    form_clone_store:Close()
  end
  form_clone_light = nx_execute("util_gui", "util_get_form", FORM_CLONE_LIGHT, true, false)
  if nx_is_valid(form_clone_light) then
    form_clone_light.wait_time = nx_number(arg[1])
    form_clone_light:Show()
  end
end
function custom_clonestore_receive(chander, arg_num, msg_type, ...)
  local cool_time = nx_number(arg[1])
  local work_time = nx_number(arg[2])
  local goods = {}
  for i = 3, table.getn(arg) do
    table.insert(goods, arg[i])
  end
  local FORM_CLONE_STORE = "form_stage_main\\form_clone_store\\form_clone_store"
  local form_clone_store = nx_value(FORM_CLONE_STORE)
  if not nx_is_valid(form_clone_store) then
    form_clone_store = nx_execute("util_gui", "util_get_form", FORM_CLONE_STORE, true, false)
  end
  form_clone_store:Show()
  nx_execute(FORM_CLONE_STORE, "update_store_goods", form_clone_store, cool_time, work_time, unpack(goods))
end
function custom_clonestore_selled(chander, arg_num, msg_type, ...)
  local opt_type = nx_number(arg[1])
  local FORM_CLONE_STORE = "form_stage_main\\form_clone_store\\form_clone_store"
  local form_clone_store = nx_value(FORM_CLONE_STORE)
  if not nx_is_valid(form_clone_store) then
    return
  end
  if opt_type == 0 then
    local FORM_CLONE_LIGHT = "form_stage_main\\form_clone_store\\form_clone_light"
    local form_clone_light = nx_value(FORM_CLONE_LIGHT)
    if nx_is_valid(form_clone_light) then
      form_clone_light:Close()
    end
    form_clone_store:Close()
  elseif opt_type == 1 then
    local pos = nx_number(arg[2])
    local configid = nx_string(arg[3])
    nx_execute(FORM_CLONE_STORE, "update_selled_goods", form_clone_store, pos, configid)
  end
end
function custom_clonestore_recooling(chander, arg_num, msg_type, ...)
  local FORM_CLONE_STORE = "form_stage_main\\form_clone_store\\form_clone_store"
  local form_clone_store = nx_value(FORM_CLONE_STORE)
  if not nx_is_valid(form_clone_store) then
    return
  end
  local cool_time = nx_int(arg[1])
  local goods = {}
  for i = 2, table.getn(arg) do
    table.insert(goods, arg[i])
  end
  nx_execute(FORM_CLONE_STORE, "refresh_current_cooling", form_clone_store, cool_time, unpack(goods))
end
function custom_clonestore_punish(chander, arg_num, msg_type, ...)
  local FORM_CLONE_STORE = "form_stage_main\\form_clone_store\\form_clone_store"
  local form_clone_store = nx_value(FORM_CLONE_STORE)
  if not nx_is_valid(form_clone_store) then
    return
  end
  local punish_time = nx_number(arg[1])
  nx_execute(FORM_CLONE_STORE, "update_punish_time", form_clone_store, punish_time)
end
function custom_jianghu_boss_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_task\\form_JiangHu_Boss", "show_form", unpack(arg))
end
function custom_jiuyinzhi_current_step_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_role_info\\form_rp_arm", "refresh_step", arg[1])
  nx_execute("form_stage_main\\form_role_info\\form_onestep_equip", "refresh_step", arg[1])
end
function custom_jzsj_qhyc(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = arg[1]
  if nx_number(0) == nx_number(sub_msg) then
    if table.getn(arg) < 2 then
      return
    end
    local bShow = arg[2]
    if nx_number(bShow) == 1 then
      nx_execute("form_stage_main\\form_jzsj_qhyc_quit", "ShowForm")
    else
      nx_execute("form_stage_main\\form_jzsj_qhyc_quit", "HideForm")
    end
  end
end
function custom_ssg_schoolmeet(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = arg[1]
  if nx_number(0) == nx_number(sub_msg) then
    if table.getn(arg) < 3 then
      return
    end
    local join_type = nx_int(arg[2])
    local join_side = nx_int(arg[3])
    local dialog_confirm = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "ssg_join_px")
    if not nx_is_valid(dialog_confirm) then
      return
    end
    local text
    if join_type == nx_int(0) then
      text = nx_widestr(util_text("sys_ssg_smdh_15"))
    elseif join_type == nx_int(1) then
      if join_side == nx_int(1) then
        text = nx_widestr(util_text("sys_ssg_smdh_16"))
      elseif join_side == nx_int(2) then
        text = nx_widestr(util_text("sys_ssg_smdh_17"))
      end
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog_confirm, text)
    dialog_confirm:ShowModal()
    local res = nx_wait_event(100000000, dialog_confirm, "ssg_join_px_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_ssg_schoolmeet", 0, 1)
    else
      nx_execute("custom_sender", "custom_ssg_schoolmeet", 0, 0)
    end
  elseif nx_number(1) == nx_number(sub_msg) then
    local dialog_confirm = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "ssg_leave_px")
    if not nx_is_valid(dialog_confirm) then
      return
    end
    local text = nx_widestr(util_text("sys_ssg_smdh_18"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog_confirm, text)
    dialog_confirm:ShowModal()
    local res = nx_wait_event(100000000, dialog_confirm, "ssg_leave_px_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_ssg_schoolmeet", 1)
    end
  elseif nx_number(2) == nx_number(sub_msg) then
    nx_execute("form_stage_main\\form_force\\form_force_ssg_smdh", "server_msg_handle", unpack(arg))
  elseif nx_number(3) == nx_number(sub_msg) then
    nx_execute("form_stage_main\\form_force\\form_force_ssg_smdh", "server_msg_handle", unpack(arg))
  elseif nx_number(4) == nx_number(sub_msg) then
    nx_execute("form_stage_main\\form_force\\form_force_ssg_smdh", "server_msg_handle", unpack(arg))
  end
end
function custom_wxj_schoolmeet(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = arg[1]
  if nx_number(0) == nx_number(sub_msg) then
    nx_execute("form_stage_main\\form_force\\form_force_wxj_smdh", "server_msg_handle", unpack(arg))
  elseif nx_number(1) == nx_number(sub_msg) then
    nx_execute("form_stage_main\\form_force\\form_force_wxj_smdh", "server_msg_handle", unpack(arg))
  end
end
function custom_dmp_schoolmeet(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = arg[1]
  if nx_number(0) == nx_number(sub_msg) then
    nx_execute("form_stage_main\\form_force\\form_force_dmp_smdh", "server_msg_handle", unpack(arg))
  elseif nx_number(1) == nx_number(sub_msg) then
    nx_execute("form_stage_main\\form_force\\form_force_dmp_smdh", "server_msg_handle", unpack(arg))
  end
end
function custom_clone_head(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = nx_number(arg[1])
  if nx_number(0) == sub_msg then
    nx_execute("form_stage_main\\form_clone\\form_dynamic_score", "custom_handle", unpack(arg))
  end
end
function on_custom_group_purchase(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_act_grouppurchase", "on_server_msg", unpack(arg))
end
function custom_single_set_form(chander, arg_num, msg_type, value)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form) then
    local bshow = false
    if value == 1 then
      bshow = true
    end
    form.groupbox_4.Visible = bshow
  end
end
function on_custom_seek_mine(chander, arg_num, msg_type, ...)
  local nType = arg[1]
  if nx_int(nType) == nx_int(1) or nx_int(nType) == nx_int(3) then
    nx_execute("form_stage_main\\form_task\\form_seek_mine", "on_server_msg", unpack(arg))
  else
    nx_execute("form_stage_main\\form_task\\form_seek_mine_gift", "on_server_msg", unpack(arg))
  end
end
function on_custom_lottery_info(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_lottery\\form_lottery_main", "on_server_msg", unpack(arg))
end
function custom_show_schoolleader_info(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "on_server_schoolleader_msg", unpack(arg))
end
function on_activity_value_rank_prize_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_activity\\form_activity_value_rank_prize", "on_server_msg", unpack(arg))
end
function on_huashan_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_huashan\\form_huashan_main", "on_server_msg", unpack(arg))
  nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "on_server_msg", unpack(arg))
  nx_execute("form_stage_main\\form_match\\form_match", "on_server_msg", unpack(arg))
  if 17 == nx_number(arg[1]) then
    nx_execute("form_stage_main\\form_huashan\\form_huashan_NameList", "on_server_msg_list", unpack(arg))
    nx_execute("form_stage_main\\form_huashan\\form_huashan_lottery", "on_server_msg_list", unpack(arg))
  end
  if 18 == nx_number(arg[1]) or 19 == nx_number(arg[1]) or nx_number(arg[1]) == 20 then
    nx_execute("form_stage_main\\form_huashan\\form_huashan_tp_mvp", "open_form", unpack(arg))
  end
  local REQUESTTYPE_TRANSTO_CANWU_SCENE = 116
  if 21 == nx_number(arg[1]) then
    local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_TRANSTO_CANWU_SCENE, "noplayer", -1)
    if 0 < index then
      nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, 2)
    end
  end
  if 22 == nx_number(arg[1]) then
    nx_execute("form_stage_main\\form_huashan\\form_huashan_wuxue_canwu", "on_wuxue_canwu_result", unpack(arg))
  end
  if 23 == nx_number(arg[1]) then
    nx_execute("form_stage_main\\form_huashan\\form_huashan_wuxue_canwu", "on_canwu_scene_zhaoshi_action", unpack(arg))
  end
end
function custom_qinggong_use_failed(chander, arg_num, msg_type, obj_id, qinggong_type)
  local game_visual = nx_value("game_visual")
  local vis_self = game_visual:GetSceneObj(nx_string(obj_id))
  if not nx_is_valid(vis_self) then
    return
  end
  local qinggong = nx_value("qinggong")
  if not nx_is_valid(qinggong) then
    return
  end
  vis_self.failed_qinggong_type = qinggong_type
end
function on_custom_get_power_redeem_num(chander, arg_num, msg_type, num)
  nx_execute("form_stage_main\\form_activity\\form_activity_power_redeem", "open_form", num)
end
function on_custom_get_novice_redeem_num(chander, arg_num, msg_type, num)
  nx_execute("form_stage_main\\form_activity\\form_activity_novice_redeem", "open_form", num)
end
function on_custom_get_old_redeem_num(chander, arg_num, msg_type, num)
  nx_execute("form_stage_main\\form_activity\\form_activity_oldserver_redeem", "open_form", num)
end
function custom_recastattribute_randprop_open(chander, arg_num, msg_type, open_id)
  if nx_int(open_id) == nx_int(1) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute", "open_form")
  elseif nx_int(open_id) == nx_int(2) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute_weapon", "open_form")
  elseif nx_int(open_id) == nx_int(3) then
    nx_execute("form_stage_main\\form_life\\form_recast_zhuishi", "open_form")
  end
end
function custom_npc_query_role(chander, arg_num, msg_type, sub_cmd, ...)
  nx_execute("form_stage_main\\form_relation\\super_book_trace\\form_npcqueryrole", "on_npc_query_event", sub_cmd, unpack(arg))
end
function custom_recastattribute_randprop_succeed(chander, arg_num, msg_type, op_type, newpackprop)
  if nx_int(op_type) >= nx_int(3) and nx_int(op_type) <= nx_int(5) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute_weapon", "show_randprop_succeed", op_type, newpackprop)
  elseif nx_int(op_type) >= nx_int(1) and nx_int(op_type) <= nx_int(2) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute", "show_randprop_succeed", op_type, newpackprop)
  elseif nx_int(op_type) == nx_int(6) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute", "show_randprop_succeed", op_type, newpackprop)
  elseif nx_int(op_type) == nx_int(7) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute", "show_randprop_succeed", op_type, newpackprop)
  elseif nx_int(op_type) == nx_int(8) then
    nx_execute("form_stage_main\\form_life\\form_recast_zhuishi", "show_randprop_succeed", op_type, newpackprop)
  end
end
function custom_recastattribute_sure(chander, arg_num, msg_type, op_type)
  if nx_int(op_type) >= nx_int(3) and nx_int(op_type) <= nx_int(5) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute_weapon", "clear_recast_info", op_type)
  elseif nx_int(op_type) >= nx_int(1) and nx_int(op_type) <= nx_int(2) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute", "clear_recast_info", op_type)
  elseif nx_int(op_type) == nx_int(6) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute", "clear_recast_info", op_type)
  elseif nx_int(op_type) == nx_int(7) then
    nx_execute("form_stage_main\\form_life\\form_recast_attribute", "clear_recast_info", op_type)
  elseif nx_int(op_type) == nx_int(8) then
    nx_execute("form_stage_main\\form_life\\form_recast_zhuishi", "clear_recast_info", op_type)
  end
end
function custom_marry(chander, arg_num, msg_type, sub_type, ...)
  nx_execute("form_stage_main\\form_marry\\form_marry_util", "show_marry_form", sub_type, unpack(arg))
end
function on_present_to_npc(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_present_to_npc", "show_present_form", arg[1], arg[2], 1)
  local task_id = {
    1206,
    1207,
    1208,
    1209,
    1994
  }
  for _, v in pairs(task_id) do
    local task_state = nx_execute("form_stage_main\\form_task\\form_task_main", "get_task_complete_state", v)
    if task_state == 0 then
      local game_client = nx_value("game_client")
      local client_player = game_client:GetPlayer()
      if not nx_is_valid(client_player) then
        return
      end
      local bRight = nx_execute("form_stage_main\\form_task\\form_task_main", "check_task_step", client_player, v, 1)
      if bRight then
        nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("karma_help_01"), "1")
      end
    end
  end
end
function custom_single_player_module_info(chander, arg_num, msg_type, sub_type, ...)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_consign_buy")
  if nx_int(sub_type) == nx_int(1) then
    local left_time = nx_int(arg[1]) / 60
    local show_text_id = "ui_vip_tishi_1"
    gui.TextManager:Format_SetIDName(show_text_id)
    gui.TextManager:Format_AddParam(nx_int(left_time))
    text = gui.TextManager:Format_GetText()
    dialog.cancel_btn.Text = gui.TextManager:GetText("ui_off_close")
  elseif nx_int(sub_type) == nx_int(2) then
    local left_time = nx_int(arg[1]) / 60
    local show_text_id = "ui_vip_tishi_2"
    gui.TextManager:Format_SetIDName(show_text_id)
    gui.TextManager:Format_AddParam(nx_int(left_time))
    text = gui.TextManager:Format_GetText()
    dialog.cancel_btn.Text = gui.TextManager:GetText("ui_off_close")
  elseif nx_int(sub_type) == nx_int(3) then
    text = gui.TextManager:GetText("ui_vip_tishi_3")
    dialog.cancel_btn.Text = gui.TextManager:GetText("ui_xl_quit")
    local world = nx_value("world")
    local game_control = world.MainScene.game_control
    game_control.AllowControl = false
  elseif nx_int(sub_type) == nx_int(4) then
    local left_time = nx_int(arg[1]) / 60
    local show_text_id = "ui_vip_tishi_4"
    gui.TextManager:Format_SetIDName(show_text_id)
    gui.TextManager:Format_AddParam(nx_int(left_time))
    text = gui.TextManager:Format_GetText()
    dialog.cancel_btn.Text = gui.TextManager:GetText("ui_off_close")
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local switch_manager = nx_value("SwitchManager")
    if nx_is_valid(switch_manager) then
      switch_manager:OpenUrl(URL_TYPE_SINGLE_PLAYER_VIP)
    end
    if nx_int(sub_type) == nx_int(3) then
      local world = nx_value("world")
      local game_control = world.MainScene.game_control
      game_control.AllowControl = false
    end
  end
  if res == "cancel" and nx_int(sub_type) == nx_int(3) then
    nx_execute("main", "direct_exit_game")
  end
end
function on_plate_award(chander, arg_num, msg_type, server_cmd_id, module, ...)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") do
    nx_pause(0.5)
    stage_main_flag = nx_value("stage_main")
    loading_flag = nx_value("loading")
  end
  nx_execute("form_stage_main\\form_xmqy_detail", "on_server_message", server_cmd_id, module, unpack(arg))
end
function open_name_modify_ui(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_name_modify", "on_server_msg", unpack(arg))
end
function custom_reconnect_server(chander, arg_num, msg_type, ip_addr, port, server_id, scene_id, cross_type, cross_server_type)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  nx_log("[cross server]type:" .. nx_string(cross_type) .. "," .. nx_string(ip_addr) .. ":" .. nx_string(port))
  game_config.switch_server = false
  game_config.switch_ip = ""
  game_config.switch_port = 0
  if nx_string(ip_addr) ~= "" and nx_int(port) > nx_int(0) then
    if nx_int(cross_type) == nx_int(0) then
      game_config.switch_ip = ip_addr
      game_config.switch_port = port
      game_config.is_login_switch_server = true
      game_config.is_cross_ready = false
    elseif nx_int(cross_type) == nx_int(1) then
      if nx_string(game_config.area_addr) ~= "" and nx_int(game_config.area_port) > nx_int(0) then
        game_config.switch_ip = game_config.area_addr
        game_config.switch_port = game_config.area_port
      else
        game_config.switch_ip = ip_addr
        game_config.switch_port = port
      end
    else
      nx_log("[cross server]Send cross_type error")
      return
    end
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_tvt\\form_tvt_skill", false)
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_main_shortcut_buff_common", false)
    game_config.switch_server = true
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CROSS_SERVER), nx_int(1), nx_int(server_id), nx_int(scene_id), nx_int(cross_server_type))
    nx_execute("game_sock", "cross_server_ready")
  end
end
function custom_reconnect_noraml_server(chander, arg_num, msg_type, ip_addr, port, server_id, scene_id, cross_target_type, cross_server_type, player_cross_name, player_customizing, player_prompt_freshman_info, player_sole_prompt)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  nx_log("[cross normal server]type:" .. nx_string(cross_target_type) .. "," .. nx_string(ip_addr) .. ":" .. nx_string(port))
  game_config.switch_normal_server = false
  game_config.switch_ip = ""
  game_config.switch_port = 0
  if nx_string(ip_addr) ~= "" and nx_int(port) > nx_int(0) then
    if nx_int(cross_target_type) == nx_int(2) then
      game_config.switch_ip = ip_addr
      game_config.switch_port = port
      game_config.is_login_switch_server = true
      local split_name = util_split_wstring(nx_widestr(player_cross_name), nx_widestr("("))
      if 2 <= table.getn(split_name) then
        player_cross_name = nx_widestr(split_name[1]) .. nx_widestr("_")
        local split_other_name = util_split_wstring(nx_widestr(split_name[2]), nx_widestr(")"))
        if 2 <= table.getn(split_other_name) then
          player_cross_name = player_cross_name .. nx_widestr(split_other_name[1])
          player_cross_name = player_cross_name .. nx_widestr(split_other_name[2])
        else
          player_cross_name = player_cross_name .. nx_widestr(split_name[2])
        end
      end
      game_config.role_name = nx_widestr(player_cross_name)
      game_config.role_sex = nx_int(client_player:QueryProp("Sex"))
      game_config.role_photo = nx_string(client_player:QueryProp("Photo"))
      game_config.role_face = nx_string(client_player:QueryProp("Face"))
      game_config.role_hair = nx_string(client_player:QueryProp("Hair"))
      game_config.shortcut_key = nx_string(client_player:QueryProp("ShortcutKey"))
      game_config.shortcut_key1 = nx_string(client_player:QueryProp("ShortcutKey1"))
      game_config.shortcut_key2 = nx_string(client_player:QueryProp("ShortcutKey2"))
      game_config.customizing = nx_string(player_customizing)
      game_config.operateMode = nx_int(client_player:QueryProp("OperateMode"))
      game_config.finish_freshman_rec_str = nx_string(client_player:QueryProp("FinishFreshmanRecStr"))
      game_config.prompt_freshman_rec_rtr = nx_string(player_prompt_freshman_info)
      game_config.sole_prompt = nx_int64(player_sole_prompt)
    elseif nx_int(cross_target_type) == nx_int(1) then
      if game_config.area_addr ~= "" and 0 < game_config.area_port then
        game_config.switch_ip = game_config.area_addr
        game_config.switch_port = game_config.area_port
      else
        game_config.switch_ip = ip_addr
        game_config.switch_port = port
      end
    else
      nx_log("[cross normal server]Send cross_target_type error")
      return
    end
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_tvt\\form_tvt_skill", false)
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_main_shortcut_buff_common", false)
    game_config.switch_normal_server = true
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CROSS_SERVER), nx_int(2), nx_int(server_id), nx_int(scene_id), nx_int(cross_server_type))
    nx_execute("game_sock", "cross_normal_server_ready")
  end
end
function on_dongfang_msg(chander, arg_num, msg_type, sub_cmd, ...)
  nx_execute("form_stage_main\\form_marry\\form_dongfang_info", "on_msg", sub_cmd, unpack(arg))
end
function on_map_dynamic_object_pos(chander, arg_num, msg_type, flag, pos_info, ...)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  if flag == MAP_TRENDS_NPC or flag == MAP_TENT_NPC or flag == MAP_ALL_NPC or flag == MAP_CLIENT_NPC then
    map_query:CreatLabelByServerInfo(pos_info)
  elseif flag == MAP_PLAYER_BUDDY or flag == MAP_PLAYER_BLOOD or flag == MAP_PLAYER_RELATION then
  end
end
function on_modify_binglu_msg(chander, arg_num, msg_type, item_id, ...)
  local form_path = "form_stage_main\\form_tiguan\\form_tiguan_binglu"
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(855) then
    form_path = "form_stage_main\\form_tiguan\\form_tiguan_binglu_new"
  end
  nx_execute(form_path, "open_form", item_id)
end
function on_egg_get_item(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "add_prize", unpack(arg))
end
function on_star_show(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "on_server_star_show", unpack(arg))
end
function on_show_form()
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "")
end
function on_weather_sky(chander, arg_num, msg_type, sub_type, ...)
  local weather_manager = nx_value("weather_manager")
  if not nx_is_valid(weather_manager) then
    return
  end
  local rain_enable = false
  local WeatherTimeManager = nx_value("WeatherTimeManager")
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_is_valid(WeatherTimeManager) then
    local rain_type = WeatherTimeManager:GetWeatherType(-1)
    if game_config.weather_enable and (rain_type == 1 or rain_type == 2 or rain_type == 3) then
      rain_enable = true
    end
  end
  local open_rain = false
  if nx_is_valid(game_config) and (game_config.level == "high" or game_config.level == "ultra") then
    open_rain = true
  end
  if not support_pom_rian_skin() then
    open_rain = false
  end
  local world = nx_value("world")
  local terrain = nx_null()
  if nx_find_custom(world.MainScene, "terrain") then
    terrain = world.MainScene.terrain
  end
  if nx_is_valid(terrain) then
    if open_rain then
      terrain.EnableRain = rain_enable
    else
      terrain.EnableRain = false
    end
  end
  local IsLua = weather_manager:IsLua()
  if sub_type == 1 then
  elseif sub_type == 2 then
    nx_execute("form_stage_main\\form_main\\form_main_map", "update_weather")
  elseif sub_type == 3 then
    if not IsLua then
      weather_manager:ChangeWeatherTime(arg[1], arg[2], arg[3], arg[4], arg[5], 0)
      return
    end
    local weather_set_data = nx_value("weather_set_data")
    if nx_is_valid(weather_set_data) then
      local world = nx_value("world")
      local timer_game = nx_value(GAME_TIMER)
      timer_game:UnRegister("terrain\\weather_set", "change_time_automatic", world)
      weather_set_data.time_now = arg[1] .. "," .. arg[2] .. "," .. arg[3] .. "," .. arg[4] .. "," .. arg[5] .. ",0"
      weather_set_data.time_adjust = true
      timer_game:Register(HEART_TIME, -1, "terrain\\weather_set", "change_time_automatic", world, -1, -1)
    end
  elseif sub_type == 4 then
    if not IsLua then
      if nx_is_valid(weather_manager) and nx_string(arg[1]) ~= "" then
        weather_manager:ChangeWeatherEffect(nx_string(arg[1]), nx_int(arg[2]), nx_string(arg[3]), nx_int(sub_type))
      end
      nx_execute("form_stage_main\\form_main\\form_main_map", "update_weather")
      return
    end
    nx_execute("form_stage_main\\form_main\\form_main_map", "update_weather")
    local weather_set_data = nx_value("weather_set_data")
    if nx_is_valid(weather_set_data) then
      local weather_table = util_split_string(weather_set_data.data, ";")
      local temp = nx_string(weather_table[1]) .. ";" .. nx_string(weather_table[2]) .. ";"
      if nx_string(arg[1]) ~= "" then
        temp = nx_string(arg[1]) .. ";" .. nx_string(arg[2]) .. ";"
        weather_set_data.period_current = nx_string(arg[1])
        weather_set_data.period_change = true
      end
      weather_set_data.data = temp .. nx_string(arg[3])
      local date = util_split_string(weather_set_data.data, ";")
      local specific_list = util_split_string(date[3], ",")
      if "" ~= specific_list[2] and "" ~= specific_list[1] then
        local world = nx_value("world")
        if nx_find_custom(weather_set_data, "weather_change_item_ini") then
          local ini = nx_custom(weather_set_data, "weather_change_item_ini")
          if nx_is_valid(ini) then
            local child = weather_set_data:GetChild("weather_parameter")
            if nx_is_valid(child) then
              local section = nx_string(specific_list[1])
              if ini:FindSection(section) then
                child.type = ini:ReadString(section, "Para", "")
                if "" ~= child.type then
                  local path = nx_resource_path() .. "share\\Rule\\Weather\\SceneParaStore\\" .. nx_string(child.type) .. "\\"
                  local tag = nx_call("terrain\\weather_set", "path_is_null", nx_string(child.type))
                  if tag then
                    local scene = world.MainScene
                    local cloud = scene.cloud
                    if nx_is_valid(cloud) then
                      cloud.special = false
                    end
                    weather_set_data.special_change = true
                    nx_call("terrain\\weather", "change_special_weather", scene, path)
                  end
                end
              end
            end
          end
        end
      end
    end
  elseif sub_type == 5 then
    if not IsLua then
      if nx_is_valid(weather_manager) and nx_string(arg[1]) ~= "" then
        weather_manager:ChangeWeatherEffect(nx_string(arg[1]), nx_int(arg[2]), nx_string(arg[3]), nx_int(sub_type))
      end
      nx_execute("form_stage_main\\form_main\\form_main_map", "update_weather")
      return
    end
    local weather_set_data = nx_value("weather_set_data")
    if nx_is_valid(weather_set_data) then
      weather_set_data.data = arg[1] .. ";" .. arg[2] .. ";" .. arg[3]
      local child = weather_set_data:GetChild("weather_parameter")
      if nx_is_valid(child) then
        child.type = "default"
      end
      weather_set_data.special_change = true
      nx_execute("terrain\\weather_set", "judge_weather_state")
    end
    nx_execute("form_stage_main\\form_main\\form_main_map", "update_weather")
  elseif sub_type == 6 then
  elseif sub_type == 7 then
    local WeatherTimeManager = nx_value("WeatherTimeManager")
    if nx_is_valid(WeatherTimeManager) then
      WeatherTimeManager:SetGameTime(nx_int(arg[1]), nx_int(arg[2]), nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[5]))
    end
  elseif sub_type == 8 then
    local WeatherTimeManager = nx_value("WeatherTimeManager")
    if nx_is_valid(WeatherTimeManager) then
      WeatherTimeManager:LoadResource()
    end
  elseif sub_type == 9 then
    if nx_string(arg[1]) ~= "" then
      nx_execute("form_stage_main\\form_map\\form_map_scene", "show_area_tianqi", nx_string(arg[1]))
    end
  elseif sub_type == 10 then
    if not IsLua then
      if nx_is_valid(weather_manager) then
        weather_manager:SetMustPlayLighting(true)
      end
      return
    end
    local weather_set_data = nx_value("weather_set_data")
    if nx_is_valid(weather_set_data) and not weather_set_data.lightning_ongoing and not weather_set_data.lightning_gm then
      weather_set_data.lightning_gm = true
      nx_execute("terrain\\weather_set", "lightning_gm_start")
    end
  elseif sub_type == 11 then
    nx_execute("form_stage_main\\form_main\\form_main_tianqi", "show_all_tianqi", nx_string(arg[1]), nx_string(arg[2]), nx_string(arg[3]))
  end
end
function on_revenge_match(chander, arg_num, msg_type, sub_type, ...)
  nx_execute("form_stage_main\\form_match\\form_match", "on_server_msg_revenge", sub_type, unpack(arg))
end
function on_server_custommsg_match_data(chander, arg_num, msg_type, sub_type, ...)
  if sub_type == 4 then
    nx_execute("form_stage_main\\form_general_info\\form_general_info_zhanli", "server_msg_name", unpack(arg))
  elseif sub_type == 5 then
    nx_execute("form_stage_main\\form_general_info\\form_general_info_bisai", "on_server_msg", unpack(arg))
  elseif sub_type == 6 then
    nx_execute("form_stage_main\\form_general_info\\form_general_info_zhanli", "server_msg_name_ex", unpack(arg))
  elseif sub_type == 7 then
    nx_execute("form_stage_main\\form_match\\form_match", "set_bisai", unpack(arg))
  else
    nx_execute("form_stage_main\\form_general_info\\form_general_info_zhanli", "server_msg_receive", unpack(arg))
  end
end
function on_whack_info(chander, arg_num, msg_type, sub_type, ...)
  if nx_number(sub_type) == 1 then
    local fight = nx_value("fight")
    if nx_is_valid(fight) then
      fight:ClearWhackSkill()
    end
  end
end
function on_egwar_msg(chander, arg_num, msg_type, ...)
  local SUBMSG_EGWAR_CLIENT_TRANS_IN = 1
  local SUBMSG_EGWAR_CLIENT_STARTTIME = 2
  local SUBMSG_EGWAR_CLIENT_ENDTIME = 3
  local SUBMSG_EGWAR_CLIENT_SYNC = 4
  local SUBMSG_EGWAR_CLIENT_SYNC1 = 411
  local SUBMSG_EGWAR_CLIENT_START = 5
  local SUBMSG_EGWAR_CLIENT_END = 6
  local SUBMSG_EGWAR_CLIENT_WIN = 7
  local SUBMSG_EGWAR_SET_TAOLU = 8
  local SUBMSG_EGWAR_SELECT_BAN_TAOLU = 11
  local SUBMSG_EGWAR_SET_TAOLU_NEW = 13
  local sub_msg = arg[1]
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_CLIENT_TRANS_IN) then
    local egwar = nx_value("EgWarModule")
    if nx_is_valid(egwar) then
      egwar.CrossServerID = nx_int(arg[2])
      egwar.WarName = nx_string(arg[3])
      egwar.RuleIndex = nx_int(arg[4])
      egwar.WarSceneID = nx_int(arg[5])
      egwar.SubRound = nx_int(arg[6])
      egwar.StartTime = nx_int64(arg[7])
      egwar.IconDelay = nx_int(arg[8])
    end
    local nWaitIcon = egwar.IconDelay
    if nWaitIcon == 0 or nWaitIcon == nil then
      nWaitIcon = 60
    end
    nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_EGWAR, nx_string("System"), nWaitIcon)
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_CLIENT_SYNC) then
    local n64Time = nx_int64(arg[2])
    local egwar = nx_value("EgWarModule")
    if nx_is_valid(egwar) then
      egwar:SetNotice(n64Time)
    else
      nx_msgbox("NoModule")
    end
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_CLIENT_SYNC1) then
    local form_djs = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_huashan\\form_huashan_djs", true, false)
    if nx_is_valid(form_djs) then
      form_djs:Show()
    end
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_CLIENT_END) then
    local form_djs = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_huashan\\form_huashan_djs", true, false)
    if nx_is_valid(form_djs) then
      form_djs:Close()
    end
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_CLIENT_WIN) then
    local nRoundCur = nx_int(arg[2])
    local nRoundEnd = nx_int(arg[3])
    local nWin = nx_int(arg[4])
    local nRoundWin = nx_int(arg[5])
    local sWinName = nx_string(arg[6])
    if nRoundEnd == 1 then
      custom_sysinfo(1, 1, 1, 2, "1000252", sWinName)
    else
      custom_sysinfo(1, 1, 1, 2, "1000248", sWinName)
    end
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_CLIENT_STARTTIME) then
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_CLIENT_ENDTIME) then
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_SET_TAOLU) then
    nx_execute("form_stage_main\\form_match\\form_taolu_confirm", "open_form", unpack(arg))
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_SELECT_BAN_TAOLU) then
    nx_execute("form_stage_main\\form_match\\form_banxuan_taolu", "CustomMsgOper", unpack(arg))
  end
  if nx_int(sub_msg) == nx_int(SUBMSG_EGWAR_SET_TAOLU_NEW) then
    nx_execute("form_stage_main\\form_match\\form_taolu_confirm_new", "open_form", unpack(arg))
  end
end
function on_msg_day_divine(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_day_divine\\form_day_divine", "on_server_msg", unpack(arg))
end
function on_register_msg(chander, arg_num, msg_type, ...)
  local reg_type = nx_int(arg[1])
  local reg_id = nx_int(arg[2])
  nx_execute("form_stage_main\\form_register", "on_server_msg", unpack(arg))
end
function on_forget_skill(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "on_server_msg", unpack(arg))
end
function on_match_msgbox(self, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_match\\form_match_rank", "on_match_rank_form", unpack(arg))
  nx_execute("form_stage_main\\form_match\\form_match_info", "on_match_info_form", unpack(arg))
  nx_execute("form_stage_main\\form_match\\form_match", "on_match_main_form", unpack(arg))
end
function on_condition_details(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_shop\\form_exchange", "on_update_condition2", unpack(arg))
end
function on_make_item(chander, arg_num, msg_type, msgid, ...)
  nx_execute("form_stage_main\\form_force_school\\form_make_item", "on_server_msg", msgid, unpack(arg))
end
function on_weather_war_msg(chander, arg_num, msg_type, submsg_type, ...)
  if nx_int(submsg_type) == nx_int(0) then
    local talk_id = nx_number(arg[1])
    nx_execute("form_stage_main\\form_weather_war\\form_common_talk", "show_form", talk_id)
  end
end
function on_extra_skill_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_extraskill", "on_server_msg", unpack(arg))
end
function on_copy_skill_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_copyskill", "on_server_msg", unpack(arg))
end
function on_taohua_masses_fight(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_fight\\form_masses_fight_rank", "show_rank_form")
end
function on_taohua_maze(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_force_school\\form_taohua_maze", "on_server_msg", unpack(arg))
end
function on_custom_package_destroyed(chander, arg_num, msg_type)
  local stage_flag = nx_value("stage")
  local loading_flag = nx_value("loading")
  while loading_flag or nx_string(stage_flag) ~= nx_string("roles") do
    nx_pause(1)
    stage_flag = nx_value("stage")
    loading_flag = nx_value("loading")
  end
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText("ui_msg_001")
  local res = util_form_confirm("", info, 0)
end
function on_force_activity(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_force_school\\form_taohua_present", "on_server_msg", unpack(arg))
end
function on_new_school_trends(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 3 then
    return
  end
  local SERVER_SEND_NEW_SCHOOL_TRENDS = 0
  local sub_msg = nx_number(arg[1])
  if sub_msg == SERVER_SEND_NEW_SCHOOL_TRENDS then
    local new_school_id = nx_string(arg[2])
    nx_execute("form_stage_main\\form_school_war\\form_newschool_school_msg_info", "refresh_new_school_trends", new_school_id, unpack(arg))
  end
end
function on_resetface_succeed(chander, arg_num, msg_type, op_type)
  if op_type == 1 then
    nx_execute("form_stage_main\\form_main\\form_main_reset_face", "reset_face_succeed")
  elseif op_type == 2 then
    nx_execute("form_stage_create\\form_create_on", "reset_face_succeed")
  end
end
function on_custom_open_disguise(chander, arg_num, msg_type, open_type)
  if open_type == 1 then
    util_auto_show_hide_form("form_stage_main\\form_main\\form_main_reset_face")
  elseif open_type == 2 then
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "open_form")
  end
end
function on_rpg_game_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_small_game\\form_game_rps", "on_server_msg", unpack(arg))
end
function on_custom_equip_name(chander, arg_num, msg_type, open)
  nx_execute("form_stage_main\\form_life\\form_mingke_equip", "open_form")
end
function on_custom_equip_name_succ(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_life\\form_mingke_equip", "on_equip_name_succeed")
end
function on_custom_pikongzhang_activity(self, arg_num, msg_type, sub_type, ...)
  local SERVER_SUBMSG_OPEN_SKILL_FORM = 1
  local SERVER_SUBMSG_CLOSE_SKILL_FORM = 2
  local SERVER_SUBMSG_NOTIFY_TRACE_TEXT = 3
  local SERVER_SUBMSG_OPEN_RULE_FORM = 4
  local SERVER_SUBMSG_SHOW_SCORE_FORM = 5
  local SERVER_SUBMSG_REHRESH_ACTIVE_COUNT = 6
  if nx_number(sub_type) == SERVER_SUBMSG_OPEN_SKILL_FORM then
    nx_execute("form_stage_main\\form_main\\form_main_pikongzhang_skill", "open_form", unpack(arg))
  elseif nx_number(sub_type) == SERVER_SUBMSG_CLOSE_SKILL_FORM then
    nx_execute("form_stage_main\\form_main\\form_main_pikongzhang_skill", "close_form", unpack(arg))
  elseif nx_number(sub_type) == SERVER_SUBMSG_NOTIFY_TRACE_TEXT then
    if 2 <= table.getn(arg) then
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        local type_index = nx_int(arg[1])
        local type_text = gui.TextManager:GetText(nx_string(arg[2]))
        nx_execute("form_stage_main\\form_single_notice", "NotifyText", type_index, type_text)
      end
    end
  elseif nx_number(sub_type) == SERVER_SUBMSG_OPEN_RULE_FORM then
    nx_execute("form_stage_main\\form_main\\form_main_pikongzhang_desc", "show_form", unpack(arg))
  elseif nx_number(sub_type) == SERVER_SUBMSG_SHOW_SCORE_FORM then
    if table.getn(arg) < 0 then
      return
    end
    local SpriteManager = nx_value("SpriteManager")
    if not nx_is_valid(SpriteManager) then
      return
    end
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local score = arg[1]
    if nx_number(score) == 20 then
      score = "+"
    elseif nx_number(score) < 0 then
      score = "0"
    end
    SpriteManager:ShowBallFormModelPos("self_PkzScore", nx_string(score), client_player.Ident, "")
  elseif nx_number(sub_type) == SERVER_SUBMSG_REHRESH_ACTIVE_COUNT then
  end
end
function on_custom_show_tersuer_max_value(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_life\\form_treasure_recast", "show_tersuer_max_value", unpack(arg))
end
function on_custom_show_tersuer_result(chander, arg_num, msg_type, sub_type, ...)
  if sub_type == 0 or sub_type == 1 then
    nx_execute("form_stage_main\\form_life\\form_treasure_recast", "show_tersuer_result", sub_type)
  elseif sub_type == 8 or sub_type == 9 then
    nx_execute("form_stage_main\\form_life\\form_treasure_reset_add", "show_tersuer_result", sub_type)
  elseif sub_type == 10 then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_grave", "show_newtersure_grave_result", sub_type)
  elseif sub_type == 11 then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_grave", "show_newtersure_replace_result", sub_type)
  elseif sub_type == 12 then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_update", "show_recover_restore", sub_type)
  elseif sub_type == 13 then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_grave", "show_intensify_result", sub_type)
  elseif sub_type == 14 then
    nx_execute("form_stage_main\\form_life\\form_treasure_repair", "show_repair_result")
  else
    nx_execute("form_stage_main\\form_life\\form_treasure_reset", "show_tersuer_result", sub_type)
  end
end
function on_custom_update_tersure_upgrade(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_life\\form_treasure_upgrade", "clear_form")
end
function on_custom_show_tersure(chander, arg_num, msg_type, sub_type)
  if "899000000" == nx_string(sub_type) then
    nx_execute("form_stage_main\\form_life\\form_treasure_upgrade", "open_form")
  elseif "899000001" == nx_string(sub_type) then
    nx_execute("form_stage_main\\form_life\\form_treasure_recast", "open_form")
  elseif "899000008" == nx_string(sub_type) then
    nx_execute("form_stage_main\\form_life\\form_treasure_reset", "open_form")
  elseif "899000021" == nx_string(sub_type) then
    nx_execute("form_stage_main\\form_life\\form_treasure_reset_add", "open_form")
  elseif "899000024" == nx_string(sub_type) then
    nx_execute("form_stage_main\\form_life\\form_treasure_repair", "open_form")
  end
end
function on_custom_itemexchange(chander, arg_num, msg_type, msgid, ...)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_life\\form_huohuan_duihuan")
end
function on_xjz_gouhuo(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_life\\form_gou_huo_skill", "on_gou_huo_msg", unpack(arg))
end
function on_xjz_jiahuo(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_small_game\\form_jia_huo_game", "on_jia_huo_msg", unpack(arg))
end
function on_musical_note(chander, arg_num, msg_type, value)
  nx_execute("form_stage_main\\form_main\\form_main_fightvs_musical_note", "show_musical_note", value)
end
function on_xjz_shaokao(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_small_game\\form_shao_kao_game", "on_shao_kao_msg", unpack(arg))
end
function on_custom_open_check_jj_form(chander, arg_num, msg_type, msgid, ...)
  local form = nx_value("form_stage_main\\form_force_school\\form_check_jj")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_force_school\\form_check_jj", true, false)
    nx_set_value("form_stage_main\\form_force_school\\form_check_jj", form)
  end
  nx_execute("form_stage_main\\form_force_school\\form_check_jj", "refresh_form", form)
  form:Show()
end
function on_custom_round_task(chander, arg_num, msg_type, ...)
  if nx_int(arg[1]) == nx_int(5) then
    nx_execute("form_stage_main\\form_shijia\\form_shijia_play", "open_play_form", unpack(arg))
  else
    nx_execute("form_stage_main\\form_school_war\\form_new_school_msg_info", "on_school_msg", msg_type, unpack(arg))
    nx_execute("form_stage_main\\form_school_war\\form_newschool_school_msg_info", "on_school_msg", msg_type, unpack(arg))
    nx_execute("form_stage_main\\form_outland\\form_outland_play_single", "on_msg_received", msg_type, unpack(arg))
  end
end
function on_set_player_camera(chander, arg_num, msg_type, ...)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local camera_story = game_control:GetCameraController(2)
  if not nx_is_valid(camera_story) then
    return
  end
  local player_pos_x = visual_player.PositionX
  local player_pos_y = visual_player.PositionY
  local player_pos_z = visual_player.PositionZ
  if table.getn(arg) < 1 then
    return
  end
  if arg[1] == 0 then
    if not nx_find_custom(scene, "cameramode") or not nx_find_custom(scene, "cameracollide") then
      return
    end
    game_control.CameraMode = scene.cameramode
    game_control.CameraCollide = scene.cameracollide
    game_control.CameraRock = false
    camera_story.StartPlayerMove = true
    game_control:ResetCamera()
  else
    if table.getn(arg) < 7 then
      return
    end
    if nx_find_custom(scene, "cameramode") and nx_find_custom(scene, "cameracollide") then
      game_control.CameraMode = scene.cameramode
      game_control.CameraCollide = scene.cameracollide
    end
    scene.cameramode = game_control.CameraMode
    scene.cameracollide = game_control.CameraCollide
    game_control.CameraMode = 2
    game_control.CameraCollide = false
    game_control.CameraRock = true
    game_control.RockKeepTime = 1000
    camera_story.StartPlayerMove = false
    local move_angle_y = nx_float(arg[2])
    local move_length = nx_float(arg[4])
    local camera_angle_x = nx_float(arg[5])
    local camera_angle_y = nx_float(arg[6])
    local camera_angle_z = nx_float(arg[7])
    if nx_find_custom(visual_player, "face_angle") then
      player_pos_x = player_pos_x + move_length * math.sin(visual_player.face_angle + move_angle_y)
      player_pos_z = player_pos_z + move_length * math.cos(visual_player.face_angle + move_angle_y)
      camera_angle_y = math.pi + visual_player.face_angle + move_angle_y
    end
    camera_story:SetCameraDirect(player_pos_x, player_pos_y + nx_float(arg[3]), player_pos_z, camera_angle_x, camera_angle_y, camera_angle_z)
  end
end
function on_open_check_player_form(chander, arg_num, msg_type, ...)
  local form = nx_value("form_stage_main\\form_force_school\\form_search_player_point")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_force_school\\form_search_player_point", true, false)
    nx_set_value("form_stage_main\\form_force_school\\form_search_player_point", form)
  end
  form:Show()
end
function on_leave_school(chander, arg_num, msg_type, leavetype, ...)
  nx_execute("form_stage_main\\form_school_war\\form_school_leave", "open_form", leavetype)
end
function on_open_world_boss_demage_stat(chander, arg_num, msg_type, sub_type, ...)
  local SERVER_WORLD_BOSS_STAT_INFO = 0
  local SERVER_JHSCENE_BOSS_STAT_INFO = 1
  local SERVER_JHSCENE_BOSS_MAP_INFO = 2
  if SERVER_WORLD_BOSS_STAT_INFO == nx_number(sub_type) then
    nx_execute("form_stage_main\\form_world_boss_stat", "on_server_msg", unpack(arg))
  elseif SERVER_JHSCENE_BOSS_STAT_INFO == nx_number(sub_type) then
    nx_execute("form_stage_main\\form_jhscene_boss_stat", "on_server_msg", unpack(arg))
  elseif SERVER_JHSCENE_BOSS_MAP_INFO == nx_number(sub_type) then
    local id = arg[1]
    if nx_string(id) == "" then
      nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", JHSCENE_BOSS)
    else
      nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", JHSCENE_BOSS, arg[2], arg[3], MAP_JHSCENE_BOSS)
    end
  end
end
function on_open_nlb_shimen_form(chander, arg_num, msg_type, sub_type, ...)
  local SERVER_NLB_SHIMEN_RANK_INFO = 0
  if SERVER_NLB_SHIMEN_RANK_INFO == nx_number(sub_type) then
    nx_execute("form_stage_main\\form_nlb_shimen_rank", "on_server_msg", unpack(arg))
  end
end
function on_open_sjy_shimen_form(chander, arg_num, msg_type, sub_type, ...)
  local SJYMSM_QUERY_RANK = 1
  local SJYMSM_KILL_NUM = 2
  local SJYMSM_MATCH_CD = 3
  if nx_int(sub_type) == nx_int(SJYMSM_QUERY_RANK) then
    nx_execute("form_stage_main\\form_sjy_shimen_rank", "refresh_rank", unpack(arg))
  elseif nx_int(sub_type) == nx_int(SJYMSM_KILL_NUM) then
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_sjy_school_meet_ui", unpack(arg))
    nx_execute("form_stage_main\\form_main\\form_main", "refresh_kill_num", unpack(arg))
  elseif nx_int(sub_type) == nx_int(SJYMSM_MATCH_CD) then
    nx_execute("form_stage_main\\form_main\\form_main", "start_counddown")
  end
end
function on_open_xmg_shimen_form(chander, arg_num, msg_type, sub_type, ...)
  local XMGMSM_QUERY_RANK = 1
  local XMGMSM_KILL_NUM = 2
  local XMGMSM_MATCH_CD = 3
  if nx_int(sub_type) == nx_int(XMGMSM_QUERY_RANK) then
    nx_execute("form_stage_main\\form_xmg_shimen_rank", "refresh_rank", unpack(arg))
  elseif nx_int(sub_type) == nx_int(XMGMSM_KILL_NUM) then
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_xmg_school_meet_ui", unpack(arg))
    nx_execute("form_stage_main\\form_main\\form_main", "refresh_kill_num", unpack(arg))
  elseif nx_int(sub_type) == nx_int(XMGMSM_MATCH_CD) then
    nx_execute("form_stage_main\\form_main\\form_main", "start_counddown")
  end
end
function on_repent_msg(chander, arg_num, msg_type, sub_type, ...)
  local SERVER_SUB_UPDATE_UI = 1
  if sub_type == SERVER_SUB_UPDATE_UI then
    nx_execute("form_stage_main\\form_repent", "on_server_msg_update_ui", unpack(arg))
  end
end
function on_close_school_introduce_form(chander, arg_num, msg_type, sub_type, ...)
  local form = nx_value("form_stage_main\\form_main\\form_school_introduce")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_get_leave_school_info(chander, arg_num, msg_type, sub_type, name, info)
  local school_list = util_split_string(info, ";")
  local real_school_list = {}
  local real_force_list = {}
  local real_newschool_list = {}
  local text = nx_widestr("")
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local leave_school_info = ""
  local leave_force_info = ""
  local leave_newschool_info = ""
  for i = 1, table.getn(school_list) do
    if school_list[i] ~= nil and school_list[i] ~= "" then
      local school = util_split_string(school_list[i], ",")
      local school_time = school[1]
      local school_name = school[2]
      local school_type = school[3]
      if is_force(school_name) then
        leave_force_info = leave_force_info .. nx_string(school_name) .. "," .. nx_string(school_time) .. ";"
        local is_exit = false
        for j = 1, table.getn(real_force_list) do
          if real_force_list[j] == school_name then
            is_exit = true
          end
        end
        if not is_exit then
          real_force_list[table.getn(real_force_list) + 1] = school_name
        end
      elseif is_new_school(school_name) then
        leave_newschool_info = leave_newschool_info .. nx_string(school_name) .. "," .. nx_string(school_time) .. ";"
        local is_exit = false
        for j = 1, table.getn(real_newschool_list) do
          if real_newschool_list[j] == school_name then
            is_exit = true
          end
        end
        if not is_exit then
          real_newschool_list[table.getn(real_newschool_list) + 1] = school_name
        end
      else
        leave_school_info = nx_string(school_time)
        local is_exit = false
        for j = 1, table.getn(real_school_list) do
          if real_school_list[j] == school_name then
            is_exit = true
          end
        end
        if not is_exit and nx_string(school_name) ~= "school_wumenpai" then
          real_school_list[table.getn(real_school_list) + 1] = school_name
        end
      end
      local year, month, day = nx_function("ext_decode_date", nx_double(school_time))
      if school_type == "0" then
        text = text .. nx_widestr("<font color=\"#5AB496\">") .. nx_widestr(year .. "." .. month .. "." .. day .. " ") .. util_text(school[2]) .. util_text("ui_force_complete") .. nx_widestr("</font><br>")
      elseif nx_string(school_name) == "school_wumenpai" then
        text = text .. nx_widestr(year .. "." .. month .. "." .. day .. " ") .. util_text(school[2]) .. util_text("ui_force_complete") .. nx_widestr("<br>")
      elseif is_new_school(school_name) and school_type == "1" then
        text = text .. nx_widestr("<font color=\"#5AB496\">") .. nx_widestr(year .. "." .. month .. "." .. day .. " ") .. util_text(school[2]) .. util_text("ui_leaveschool_1") .. nx_widestr("</font><br>")
      else
        text = text .. nx_widestr(year .. "." .. month .. "." .. day .. " ") .. util_text(school[2]) .. util_text("ui_leaveschool_" .. school[3]) .. nx_widestr("<br>")
      end
    end
  end
  local school_num_text = nx_widestr("")
  if table.getn(real_school_list) > 0 then
    gui.TextManager:Format_SetIDName("ui_player_school_log")
    gui.TextManager:Format_AddParam(nx_int(table.getn(real_school_list)))
    school_num_text = gui.TextManager:Format_GetText()
  end
  if table.getn(real_force_list) > 0 then
    gui.TextManager:Format_SetIDName("ui_player_force_log")
    gui.TextManager:Format_AddParam(nx_int(table.getn(real_force_list)))
    if table.getn(real_school_list) > 0 then
      school_num_text = school_num_text .. util_text("ui_sign") .. gui.TextManager:Format_GetText()
    else
      school_num_text = school_num_text .. gui.TextManager:Format_GetText()
    end
  end
  if table.getn(real_school_list) > 0 or table.getn(real_force_list) > 0 then
    school_num_text = school_num_text .. nx_widestr("<br>")
  end
  if table.getn(real_newschool_list) > 0 then
    gui.TextManager:Format_SetIDName("ui_player_newschool_log")
    gui.TextManager:Format_AddParam(nx_int(table.getn(real_newschool_list)))
    school_num_text = school_num_text .. gui.TextManager:Format_GetText()
  end
  if table.getn(real_newschool_list) > 0 then
    school_num_text = school_num_text .. nx_widestr("<br>")
  end
  text = school_num_text .. text
  if sub_type == 1 then
    nx_execute("form_stage_main\\form_main\\form_main_player", "show_leave_school_tips", text, leave_school_info, leave_force_info)
    if nx_is_valid(client_player) and client_player:QueryProp("Name") == name then
      client_player.leave_school_all_text = text
      client_player.leave_school_info = leave_school_info
      client_player.leave_force_info = leave_force_info
      client_player.leave_newschool_info = leave_newschool_info
    end
  elseif sub_type == 2 then
    nx_execute("form_stage_main\\form_main\\form_main_select", "show_leave_school_tips", text, leave_school_info, leave_force_info, leave_newschool_info)
    if nx_is_valid(client_player) then
      local select_target_ident = client_player:QueryProp("LastObject")
      local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
      if nx_is_valid(select_target) and select_target:QueryProp("Name") == name then
        select_target.leave_school_all_text = text
        select_target.leave_school_info = leave_school_info
        select_target.leave_force_info = leave_force_info
        select_target.leave_newschool_info = leave_newschool_info
      end
    end
  elseif nx_is_valid(client_player) and client_player:QueryProp("Name") == name then
    client_player.leave_school_all_text = text
    client_player.leave_school_info = leave_school_info
    client_player.leave_force_info = leave_force_info
    client_player.leave_newschool_info = leave_newschool_info
  end
end
function is_new_school(school)
  if school == "newschool_gumu" or school == "newschool_xuedao" or school == "newschool_changfeng" or school == "newschool_nianluo" or school == "newschool_shenshui" or school == "newschool_huashan" or school == "newschool_damo" or school == "newschool_wuxian" or school == "newschool_shenji" or school == "newschool_xingmiao" then
    return true
  else
    return false
  end
end
function is_force(school)
  if school == "force_yihua" or school == "force_taohua" or school == "force_xujia" or school == "force_wugen" or school == "force_wanshou" or school == "force_jinzhen" then
    return true
  else
    return false
  end
end
function simulate_close_scene(chander, arg_num, msg_type, ...)
  local form = nx_value("form_stage_main\\form_close_scene")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_close_scene", true, false)
    nx_set_value("form_stage_main\\form_close_scene", form)
  end
  form.simulate = 1
  form:Show()
  nx_pause(2)
  form.keep_time = 3
  nx_execute("form_stage_main\\form_close_scene", "up_and_down_open", form)
  nx_pause(3.5)
  nx_destroy(form)
end
function get_origin_succeed(chander, arg_num, msg_type, origin_id)
  local ret = nx_execute("form_stage_main\\form_help\\form_help_thd_lead", "on_is_lead", nx_string(origin_id))
  if ret == false then
    return
  end
  local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_TAOHUA_LEAD, nx_string("noplayer"), -1)
  if 0 < index then
    nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, nx_string(origin_id))
  end
end
function on_addbtn_lead_info_open(chander, arg_num, msg_type)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) or not nx_find_custom(game_config, "first_lead") then
    return
  end
  nx_set_custom(game_config, "first_lead", true)
  local funcbtns = nx_value("form_main_func_btns")
  if nx_is_valid(funcbtns) then
    funcbtns:OnActiveBtn()
  end
end
function on_interactive_furniture(chander, arg_num, msg_type, sub_type, ...)
  local SERVER_FURNITURE_SAVE_OPEN = 6
  local SERVER_FURNITURE_SAVE_FRESH = 7
  local SERVER_FURNITURE_SAVE_CLOSE = 8
  local SERVER_FURNITURE_OPEN_CLOTHES_RACK_FORM = 11
  local SERVER_FURNITURE_OPEN_RECOVER_EQUIP_FORM = 12
  local SERVER_FURNITURE_STOP_INTER_FURN_FORM_CLOSE = 13
  local SERVER_FURNITURE_WEAPON_RACK_REPLY = 14
  local SERVER_FURNITURE_CLOTHESPRESS_REPLY = 15
  if nx_number(sub_type) == 0 then
    nx_execute("form_stage_main\\form_home\\form_interaction_menu", "show_form", 13)
  elseif nx_number(sub_type) == 1 then
    nx_execute("form_stage_main\\form_home\\form_interaction_menu", "show_form", 12)
  elseif nx_number(sub_type) == 2 then
    if 1 > table.getn(arg) then
      return
    end
    nx_execute("form_stage_main\\form_home\\form_interaction_menu", "show_form", unpack(arg))
  elseif nx_number(sub_type) == 3 then
    if table.getn(arg) < 4 then
      return
    end
    nx_execute("form_stage_main\\form_home\\form_cease_meun", "show_form", unpack(arg))
  elseif nx_number(sub_type) == 4 then
    local scene = nx_value("game_scene")
    if not nx_is_valid(scene) then
      return
    end
    local game_control = scene.game_control
    if not nx_is_valid(game_control) then
      return
    end
    local camera_normal = game_control:GetCameraController(0)
    if not nx_is_valid(camera_normal) then
      return
    end
    camera_normal.CheckCollideLevel = 3
  elseif nx_number(sub_type) == 5 then
    local scene = nx_value("game_scene")
    if not nx_is_valid(scene) then
      return
    end
    local game_control = scene.game_control
    if not nx_is_valid(game_control) then
      return
    end
    local camera_normal = game_control:GetCameraController(0)
    if not nx_is_valid(camera_normal) then
      return
    end
    camera_normal.CheckCollideLevel = 5
  elseif nx_number(sub_type) == SERVER_FURNITURE_SAVE_OPEN then
    nx_execute("form_stage_main\\form_home\\form_save_furn", "open_form", unpack(arg))
  elseif nx_number(sub_type) == SERVER_FURNITURE_SAVE_FRESH then
    nx_execute("form_stage_main\\form_home\\form_save_furn", "fresh_form", unpack(arg))
  elseif nx_number(sub_type) == SERVER_FURNITURE_SAVE_CLOSE then
    nx_execute("form_stage_main\\form_home\\form_save_furn", "close_form")
  elseif nx_number(sub_type) == 9 then
    nx_execute("form_stage_main\\form_home\\form_interaction_menu", "close_form")
  elseif nx_number(sub_type) == 10 then
    nx_execute("form_stage_main\\form_home\\form_home_wuxue", "update_wuxue_info")
  elseif nx_number(sub_type) == SERVER_FURNITURE_OPEN_CLOTHES_RACK_FORM then
    nx_execute("form_stage_main\\form_home\\form_clothes_rack", "open_form", unpack(arg))
  elseif nx_number(sub_type) == SERVER_FURNITURE_OPEN_RECOVER_EQUIP_FORM then
    nx_execute("form_stage_main\\form_home\\form_equip_recover", "show_form", unpack(arg))
  elseif nx_number(sub_type) == SERVER_FURNITURE_STOP_INTER_FURN_FORM_CLOSE then
    nx_execute("form_stage_main\\form_home\\form_cease_meun", "close_form")
  elseif nx_number(sub_type) == SERVER_FURNITURE_WEAPON_RACK_REPLY then
    nx_execute("form_stage_main\\form_home\\form_weapon_rack", "handle_message", unpack(arg))
  elseif nx_number(sub_type) == SERVER_FURNITURE_CLOTHESPRESS_REPLY then
    nx_execute("form_stage_main\\form_home\\form_clothespress", "handle_message", unpack(arg))
  end
end
function on_random_question_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_helper\\form_image_tips", "open_form", nx_int(arg[1]))
end
function on_question_msg(chander, arg_num, msg_type, sub_type, ...)
  if nx_int(sub_type) == nx_int(0) then
    nx_execute("form_stage_main\\form_activity\\form_activity_answer_join", "question_server_msg", sub_type, unpack(arg))
  else
    nx_execute("form_stage_main\\form_activity\\form_activity_answer", "question_server_msg", sub_type, unpack(arg))
  end
end
function on_check_afk_question_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_check_afk_question", "on_server_msg", unpack(arg))
end
function on_push_box(chander, arg_num, msg_type, sub_type, ...)
  if nx_int(sub_type) == nx_int(1) then
    nx_execute("form_stage_main\\form_small_game\\form_push_box", "open_form", arg[1])
  elseif nx_int(sub_type) == nx_int(2) then
    nx_execute("form_stage_main\\form_small_game\\form_push_box", "close_form")
  end
end
function on_inv_rank_info(chander, arg_num, msg_type, ...)
  local sub_type = arg[1]
  if sub_type == 1 then
    nx_execute("form_stage_main\\form_general_info\\form_general_info_bisai", "on_refesh_form", arg[2], arg[3], arg[4])
  elseif sub_type == 2 then
    nx_execute("form_stage_main\\form_general_info\\form_general_info_zhanli", "on_refesh_firend", arg[2], arg[3])
  end
end
function on_depot_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_depot", "on_server_msg", unpack(arg))
end
function on_home_depot_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_home\\form_home_depot", "on_server_msg", unpack(arg))
end
function on_home_gouhuo_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_home\\form_home_gouhuo", "on_server_msg", unpack(arg))
end
function on_trans_server_list(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    local ST_FUNCTION_TRANS_SERVER = 144
    local enable = switch_manager:CheckSwitchEnable(ST_FUNCTION_TRANS_SERVER)
    if not enable then
      return
    end
  end
  local TRANSSERVER_SUBMSG_NOTICE_RECEIVEDATA = 1
  local TRANSSERVER_SUBMSG_NOTICE_PROMPTTRANS = 2
  local opt_type = arg[1]
  if nx_int(opt_type) == nx_int(TRANSSERVER_SUBMSG_NOTICE_RECEIVEDATA) then
    local data = {}
    for i = 2, table.getn(arg) do
      table.insert(data, arg[i])
    end
    nx_execute("form_stage_main\\form_transfer_server", "on_receive_server_list", unpack(data))
  elseif nx_int(opt_type) == nx_int(TRANSSERVER_SUBMSG_NOTICE_PROMPTTRANS) then
    local stage_main_flag = nx_value("stage_main")
    local loading_flag = nx_value("loading")
    while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") do
      nx_pause(0.5)
      stage_main_flag = nx_value("stage_main")
      loading_flag = nx_value("loading")
    end
    nx_execute("form_stage_main\\form_transfer_server", "open_form")
  end
end
function custom_accost(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_sweet_employ\\form_accost", "on_server_accost_msg", unpack(arg))
end
function custom_sweet_employ(chander, arg_num, msg_type, ...)
  if nx_int(table.getn(arg)) < nx_int(1) then
    return
  end
  local sub_msg = arg[1]
  local server_sub_msg_game_step = 7
  if nx_int(sub_msg) == nx_int(2) then
    if nx_int(table.getn(arg)) < nx_int(2) then
      return
    end
    local lookup_type = arg[2]
    table.remove(arg, 1)
    table.remove(arg, 1)
    nx_execute("form_stage_main\\form_sweet_employ\\form_qingyuan", "on_server_msg_show_qingyuan", lookup_type, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    local form = util_get_form("form_stage_main\\form_sweet_employ\\form_employ_confirm", true, false)
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_sweet_employ\\form_employ_confirm", "init_info", form, true, unpack(arg))
      form:ShowModal()
    end
  elseif nx_int(sub_msg) == nx_int(4) then
    if nx_int(table.getn(arg)) < nx_int(2) then
      return
    end
    nx_execute("form_stage_main\\form_main\\form_main_sweet_employ", "open_form", nx_string(arg[2]))
  elseif nx_int(sub_msg) == nx_int(5) then
    local sweet_hp_form = util_get_form("form_stage_main\\form_main\\form_main_sweet_employ", false, false)
    if nx_is_valid(sweet_hp_form) then
      sweet_hp_form.Visible = false
      sweet_hp_form:Close()
    end
  elseif nx_int(sub_msg) == nx_int(6) then
    util_show_form("form_stage_main\\form_sweet_employ\\form_buy_charm", true)
  elseif nx_int(sub_msg) == nx_int(server_sub_msg_game_step) then
    local origin_manager = nx_value("OriginManager")
    if nx_is_valid(origin_manager) then
      origin_manager:SetCurGameStep(nx_int(arg[2]), nx_int(arg[3]))
    end
  elseif nx_int(sub_msg) == nx_int(8) then
    if nx_int(table.getn(arg)) < nx_int(2) then
      return
    end
    util_show_form("form_stage_main\\form_sweet_employ\\form_task_skill", true)
  elseif nx_int(sub_msg) == nx_int(9) then
    util_show_form("form_stage_main\\form_sweet_employ\\form_task_skill", false)
  end
end
function on_sweet_pet_equip(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 2 then
    return
  end
  local form = nx_value("form_stage_main\\form_sweet_employ\\form_sweet_pet_shop")
  if not nx_is_valid(form) or form.Visible ~= true then
    return
  end
  local equip_type = arg[1]
  if equip_type == 1 or equip_type == 2 then
    nx_execute("form_stage_main\\form_sweet_employ\\form_sweet_pet_shop", "on_refresh_form")
  elseif equip_type == 3 then
    nx_execute("form_stage_main\\form_sweet_employ\\form_sweet_pet_shop", "on_equip_pet", form)
  elseif equip_type == 4 then
    nx_execute("form_stage_main\\form_sweet_employ\\form_sweet_pet_shop", "on_unequip_pet", form)
  end
end
function on_flash_window()
  nx_function("ext_flash_window")
end
function on_activity_partner(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_activity\\form_activity_partner", "on_server_msg", unpack(arg))
end
function on_custom_begin_scene_compete(chander, arg_num, msg_type, ...)
  local odtype = arg[1]
  local OD_SCENE_COMPETE_START = 1
  local OD_SCENE_COMPETE_END = 2
  local OD_SCENE_COMPETE_OPENDLG = 3
  local OD_SCENE_COMPETE_OFFER = 4
  if nx_int(odtype) == nx_int(OD_SCENE_COMPETE_START) then
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_scene_compete_icon", true)
  elseif nx_int(odtype) == nx_int(OD_SCENE_COMPETE_END) then
    local bSuccess = nx_int(arg[2]) == nx_int(1)
    local configid = nx_string(arg[3])
    local player_name = nx_widestr(arg[4])
    local money = nx_int(arg[5])
    if bSuccess then
      local game_client = nx_value("game_client")
      if nx_is_valid(game_client) then
        local client_player = game_client:GetPlayer()
        if nx_is_valid(client_player) then
          local self_name = nx_widestr(client_player:QueryProp("Name"))
          if not nx_ws_equal(self_name, player_name) then
            custom_sysinfo(0, 0, 0, 2, nx_string("8966"), player_name, money, configid)
          end
        end
      end
    end
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_scene_compete_icon", false)
    nx_execute("form_stage_main\\form_scene_compete\\form_scene_compete", "close_form")
  elseif nx_int(odtype) == nx_int(OD_SCENE_COMPETE_OPENDLG) then
    local msg = {}
    for i = 2, table.getn(arg) do
      table.insert(msg, arg[i])
    end
    nx_execute("form_stage_main\\form_scene_compete\\form_scene_compete", "open_form", unpack(msg))
  elseif nx_int(odtype) == nx_int(OD_SCENE_COMPETE_OFFER) then
    local player_name = nx_widestr(arg[2])
    local money = nx_int(arg[3])
    local tick_count = nx_int(arg[4])
    nx_execute("form_stage_main\\form_scene_compete\\form_scene_compete", "on_player_offer_item", player_name, money, tick_count)
  end
end
function on_consume_back_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_expense\\form_expense_back", "on_server_msg", unpack(arg))
end
function on_use_lantern_msg(chander, arg_num, msg_type, sub_type, ...)
  if nx_int(sub_type) == nx_int(1) then
    nx_execute("form_stage_main\\form_activity\\form_lantern_select", "on_server_msg", unpack(arg))
  elseif nx_int(sub_type) == nx_int(2) then
    nx_execute("form_stage_main\\form_activity\\form_lantern_answer", "on_server_msg", unpack(arg))
  elseif nx_int(sub_type) == nx_int(3) then
    nx_execute("form_stage_main\\form_activity\\form_kongming_send", "on_server_msg", unpack(arg))
  elseif nx_int(sub_type) == nx_int(4) then
    nx_execute("form_stage_main\\form_activity\\form_kongming_recive", "on_server_msg", unpack(arg))
  end
end
function on_bodyguardoffice_msg(chander, arg_num, msg_type, sub_type, ...)
  if nx_int(sub_type) == nx_int(1) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_control", "show_form", unpack(arg))
  elseif nx_int(sub_type) == nx_int(2) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_dajian", "show_form", unpack(arg))
  elseif nx_int(sub_type) == nx_int(3) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_dajian", "refresh_form", unpack(arg))
  elseif nx_int(sub_type) == nx_int(4) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_gezi_response", "show_form", unpack(arg))
  elseif nx_int(sub_type) == nx_int(5) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_ying_response", "show_form", unpack(arg))
  elseif nx_int(sub_type) == nx_int(6) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_ying_response", "close_form")
  elseif nx_int(sub_type) == nx_int(7) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_jiu_confirm", "show_form", unpack(arg))
  elseif nx_int(sub_type) == nx_int(8) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_jiu_response", "show_form", unpack(arg))
  elseif nx_int(sub_type) == nx_int(9) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_jiu_response", "close_form")
  elseif nx_int(sub_type) == nx_int(10) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_huaquan", "show_form", unpack(arg))
  elseif nx_int(sub_type) == nx_int(11) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_smdh", "update_con_list", unpack(arg))
  elseif nx_int(sub_type) == nx_int(12) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_smdh", "update_damage_list", unpack(arg))
  elseif nx_int(sub_type) == nx_int(13) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_smdh", "update_member_info", unpack(arg))
  end
end
function on_open_shop_exchange_form(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 6 then
    return
  end
  local view_ident = nx_int(arg[1])
  local bind_index = nx_int(arg[2])
  local shop_id = nx_string(arg[3])
  local page = nx_int(arg[4])
  local pos = nx_int(arg[5])
  local config_str = nx_string(arg[6])
  nx_execute("form_stage_main\\form_shop\\form_exchange", "show_form", view_ident, bind_index, shop_id, page, pos, config_str)
end
function on_call_helper_msg(chander, arg_num, msg_type, sub_type, ...)
  local bCallHelp = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_boss_help")
  if not bCallHelp then
    nx_execute("form_stage_main\\form_boss_help", "show_call_info", unpack(arg))
  end
end
function on_open_swap_goods_form(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local OP_SWAPGOODS_OPEN = 1
  local OP_SWAPGOODS_DATA = 2
  local OP_SWAPGOODS_END = 3
  local opt_type = nx_int(arg[1])
  local msg = {}
  for i = 2, table.getn(arg) do
    table.insert(msg, arg[i])
  end
  if nx_int(opt_type) == nx_int(OP_SWAPGOODS_OPEN) then
    local npc_id = nx_string(arg[2])
    nx_execute("form_stage_main\\form_life\\form_reclaim", "open_form", npc_id)
  elseif nx_int(opt_type) == nx_int(OP_SWAPGOODS_DATA) then
    nx_execute("form_stage_main\\form_life\\form_reclaim", "on_receive_swap_goods", unpack(msg))
  elseif nx_int(opt_type) == nx_int(OP_SWAPGOODS_END) then
    nx_execute("form_stage_main\\form_life\\form_reclaim", "clear_image_grid")
  end
end
function get_scene_id_by_name(scene_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local item_count = ini:GetSectionItemCount(0)
  local index = 0
  local scene_name = ""
  for i = 1, item_count do
    index = index + 1
    local scene_name = nx_string(ini:GetSectionItemValue(0, i - 1))
    if index == scene_id then
      return scene_name
    end
  end
  return ""
end
function on_open_scene_jhpk(chander, arg_num, msg_type, sub_type, ...)
  local SERVER_SUB_JHPK_BE_CALLUP = 1
  local SERVER_SUB_JHPK_BE_BUND = 2
  local SERVER_SUB_JHPK_GET_RANK = 3
  local SERVER_SUB_CHOOSEFORM_OPEN = 4
  local SERVER_SUB_CHOOSEFORM_SCENEINFO = 5
  local SERVER_SUB_CHOOSEFORM_CLEAN_OK = 6
  local SERVER_SUB_RESET_SCENE = 7
  if nx_int(SERVER_SUB_JHPK_BE_CALLUP) == nx_int(sub_type) then
    if 1 > table.getn(arg) then
      return
    end
    nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "on_be_callup", nx_widestr(arg[1]))
  elseif nx_int(SERVER_SUB_JHPK_BE_BUND) == nx_int(sub_type) then
    if 2 > table.getn(arg) then
      return
    end
    nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "on_be_bund", nx_widestr(arg[1]), nx_widestr(arg[2]))
  elseif nx_int(SERVER_SUB_JHPK_GET_RANK) == nx_int(sub_type) then
    local form_main_chat = nx_value("form_main_chat")
    if nx_is_valid(form_main_chat) then
      form_main_chat:Reset_Rank(unpack(arg))
    end
  elseif nx_int(sub_type) >= nx_int(SERVER_SUB_CHOOSEFORM_OPEN) and nx_int(sub_type) <= nx_int(SERVER_SUB_CHOOSEFORM_CLEAN_OK) then
    nx_execute("form_stage_main\\form_map\\form_map_jianghu_xiyudoor", "custom_message_callback", nx_int(sub_type), unpack(arg))
  elseif nx_int(SERVER_SUB_RESET_SCENE) == nx_int(sub_type) then
    nx_execute("form_stage_main\\form_relation\\form_scene_jhpk_skill", "reset_scene")
  end
end
function on_wuji_helper(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("wuji_helper"), "1")
end
function on_jianghu_gouhuo_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_task\\form_jianghu_gouhuo", "on_server_msg", unpack(arg))
end
function on_card_msg(chander, arg_num, msg_type, ...)
  if table.getn(arg) < 1 then
    return
  end
  local SERVER_CUSTOMMSG_CARD_EXCHANGE = 0
  local SERVER_CUSTOMMSG_CARD_REPLACE = 1
  local SERVER_CUSTOMMSG_CARD_COLLECT = 2
  local SERVER_CUSTOMMSG_CARD_RESULT = 3
  local opt_type = nx_int(arg[1])
  if nx_int(opt_type) == nx_int(SERVER_CUSTOMMSG_CARD_EXCHANGE) then
    nx_execute("form_stage_main\\form_card\\form_card_exchange", "open_form")
  elseif nx_int(opt_type) == nx_int(SERVER_CUSTOMMSG_CARD_REPLACE) then
    nx_execute("form_stage_main\\form_card\\form_card_replace", "open_form")
  elseif nx_int(opt_type) == nx_int(SERVER_CUSTOMMSG_CARD_COLLECT) then
    nx_execute("form_stage_main\\form_card\\form_collect_card", "open_form")
  elseif nx_int(opt_type) == nx_int(SERVER_CUSTOMMSG_CARD_RESULT) then
    nx_execute("form_stage_main\\form_card\\form_collect_card", "show_request_reason", unpack(arg))
  end
end
function on_find_water_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_task\\form_find_water", "on_server_msg", unpack(arg))
end
function open_new_bag(chander, arg_num, msg_type, sub_type, ...)
  local form_mapping = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mapping_bag", true, false)
  if nx_is_valid(form_mapping) then
    form_mapping:Show()
    form_mapping.Visible = true
  end
end
function on_jianghu_award_msg(chander, arg_num, msg_type, ...)
  local type = nx_number(arg[1])
  if type == SERVER_SUB_CUSTOMMSG_JH_AWARD_OPEN then
    nx_execute("form_stage_main\\form_task\\form_juqingjieju", "on_server_msg", unpack(arg))
  else
    nx_execute("form_stage_main\\form_task\\form_jianghu_explore", "refresh_btn_jiangli", unpack(arg))
  end
end
function oldbag_to_newbag1(chander, arg_num, msg_type, ...)
  local form = nx_value("form_stage_main\\form_prebag")
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_prebag", "refresh_bag", form, false)
  end
  local form_prenew = nx_value("form_stage_main\\form_prenewbag")
  if nx_is_valid(form_prenew) then
    nx_execute("form_stage_main\\form_prenewbag", "refresh_bag", form_prenew, false)
  end
end
function on_form_interface(chander, arg_num, msg_type, file, func, ...)
  nx_execute(nx_string(file), nx_string(func), unpack(arg))
end
function on_sworn(chander, arg_num, msg_type, sub_msg, ...)
  local STC_SUB_MSG_SWORN_TITLE_FORM_CLOSE = 5
  local STC_SUB_MSG_SWORN_TITLE_FORM_OPEN = 6
  local STC_SUB_MSG_SWORN_SKILL_FORM_OPEN = 7
  local STC_SUB_MSG_SWORN_SKILL_FORM_CLOSE = 8
  local STC_SUB_MSG_SWORN_SEND_TITLE_INFO = 9
  local STC_SUB_MSG_SWORN_SEND_PLAYER_NUM = 10
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_info", "update_sworn_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_SUB_MSG_SWORN_TITLE_FORM_CLOSE) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_title", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_SUB_MSG_SWORN_TITLE_FORM_OPEN) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_title", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_jinlanpu_question", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_jinlanpu", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_jinlanpu", "close_form")
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_res_tips", "open_form")
  elseif nx_int(sub_msg) == nx_int(STC_SUB_MSG_SWORN_SKILL_FORM_OPEN) then
    nx_execute("form_stage_main\\form_sworn\\form_main_sworn_skill", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_SUB_MSG_SWORN_SKILL_FORM_CLOSE) then
    nx_execute("form_stage_main\\form_sworn\\form_main_sworn_skill", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_SUB_MSG_SWORN_SEND_TITLE_INFO) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_info", "get_title_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_SUB_MSG_SWORN_SEND_PLAYER_NUM) then
    nx_execute("form_stage_main\\form_sworn\\form_sworn_title", "get_sworn_num", unpack(arg))
  end
end
function on_ancienttomb(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_srtx", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_srtx", "refresh_time_game", unpack(arg))
    local index = arg[2]
    local diff = arg[3]
    if nx_int(index) == nx_int(0) then
      nx_execute("form_stage_main\\form_small_game\\form_game_bee", "open_form_by_diff", nx_int(diff))
    elseif nx_int(index) == nx_int(1) then
      nx_execute("form_stage_main\\form_small_game\\form_game_balance", "open_form_by_diff", nx_int(diff))
    elseif nx_int(index) == nx_int(2) then
      nx_execute("form_stage_main\\form_small_game\\form_game_pick", "open_form_by_diff", nx_int(diff))
    elseif nx_int(index) == nx_int(3) then
      nx_execute("form_stage_main\\form_small_game\\form_game_question", "open_form_by_diff", nx_int(diff))
    end
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_srtx", "refresh_time_turns", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_srtx", "refresh_turns_right", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_srtx", "close_form")
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_force\\form_force_gmp_srld_join", "handle_message", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(21) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_lot", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(24) then
    nx_execute("form_stage_main\\form_school_war\\form_newschool_school_msg_info", "update_lot_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(31) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_smdh", "update_con_list", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(32) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_smdh", "update_damage_list", unpack(arg))
  end
end
function on_huashan_school(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_force\\form_force_hsp_meet", "update_meet", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_fly_bar", "add_debuff", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_fly_bar", "remove_debuff", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", "open_form", "throw")
    nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_throw_bar", "open_form")
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", "close_form")
    nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_throw_bar", "close_form")
  elseif nx_int(sub_msg) == nx_int(5) then
    local game_visual = nx_value("game_visual")
    local vis_object = game_visual:GetSceneObj(nx_string(arg[1]))
    if not nx_is_valid(vis_object) then
      return
    end
    nx_call("player_state\\state_input", "emit_player_input", vis_object, PLAYER_INPUT_LOGIC, LOGIC_SERVER_WXJZ, arg[2], arg[3], arg[4], arg[5], arg[6])
  end
end
function on_tg_roll_game(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_start_single")
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_chip", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_sys", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_sys_again", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_player", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_player_again", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(7) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_cheat", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(8) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_sum_single", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(9) then
    nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "close_form")
  end
end
function on_world_auction(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_main\\form_main", "show_world_auction")
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_world_auction\\form_world_auction", "update_auction_single", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_world_auction\\form_world_auction", "update_auction", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_world_auction\\form_world_auction_see_boss", "update_boss", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_world_auction\\form_world_auction", "update_histroy", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_world_auction\\form_boss_auction_drop", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_main\\form_main", "hide_world_auction")
  end
end
function on_agree_war(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "update_round_more_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_main", "update_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_ans", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "update_round_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "update_ready_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "update_fight_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "update_war_res", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(7) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_dead", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(8) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_dead", "close_form")
  elseif nx_int(sub_msg) == nx_int(9) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_score", "update_stage_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(10) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "change_stage")
  elseif nx_int(sub_msg) == nx_int(11) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_main", "update_player_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(12) then
  elseif nx_int(sub_msg) == nx_int(13) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "reopen_form")
  elseif nx_int(sub_msg) == nx_int(14) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "open_form_round_end", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(15) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_score", "update_relive", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(16) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_score", "update_ready", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(17) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_score", "update_nodead", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(18) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_main", "update_achievement", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(19) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_req", "update_guild_list", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(20) then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_main", "update_his_info", unpack(arg))
  end
end
function on_outland_war(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_outland_war\\form_outland_war_achieve", "update_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_outland\\form_outland_play_multiple", "update_war_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_die_erg_war", "show_relive_point", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_outland_war\\form_outland_war_map", "update_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_outland\\form_outland_main", "on_server_msg", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(11) then
    nx_execute("form_stage_main\\form_outland_war\\form_outland_war_score", "update_meet", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(12) then
    nx_execute("form_stage_main\\form_outland_war\\form_outland_war_achieve", "update_achieve", unpack(arg))
  end
end
function on_server_custommsg_puzzle_game(chander, arg_num, ...)
  nx_execute("form_stage_main\\form_small_game\\form_puzzle_game", "on_puzzle_game_svr_msg", chander, arg_num, unpack(arg))
  return
end
function on_server_custommsg_jh_explore(chander, arg_num, msg_type, sub_type, ...)
  if nx_int(1) == nx_int(sub_type) then
    nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_ITEM_COURSE, "", -1)
  elseif nx_int(2) == nx_int(sub_type) then
    nx_execute("form_stage_main\\form_task\\form_jianghu_explore", "update_today_youli", unpack(arg))
  elseif nx_int(3) == nx_int(sub_type) then
    nx_execute("form_stage_main\\form_main\\form_main_func_btns", "on_jianghu_info_change", sub_type)
  elseif nx_int(4) == nx_int(sub_type) then
    nx_execute("form_stage_main\\form_main\\form_main_func_btns", "on_jianghu_info_change", sub_type)
  elseif nx_int(5) == nx_int(sub_type) then
    nx_execute("form_stage_main\\form_main\\form_main_func_btns", "on_jianghu_info_change", sub_type)
  end
end
function learn_jingmai(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("learn_jingmai"), "1")
end
function on_jianghu_guide(chander, arg_num, msg_type, ...)
  local FRESHMAN_JHSCENE_SUB_GET_DRUG = 1
  local FRESHMAN_JHSCENE_SUB_GET_CLOTH = 2
  local FRESHMAN_JHSCENE_SUB_GET_TRAP = 3
  local FRESHMAN_JHSCENE_SUB_GET_CRUSHEQUIP = 4
  local FRESHMAN_JHSCENE_SUB_DEBUFF = 5
  local FRESHMAN_JHSCENE_SUB_KILL_TARGET = 6
  local FRESHMAN_JHSCENE_SUB_GET_POINT = 7
  local helper_id = arg[1]
  local sub_type = arg[2]
  if helper_id ~= "none" then
    local config_id = arg[3]
    if config_id == nil or config_id == "" then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string(helper_id), "1")
    else
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string(helper_id), "1", nx_string(config_id))
    end
  else
    nx_execute("form_stage_main\\form_task\\form_jianghu_guide", "open_form", nx_int(sub_type))
  end
end
function on_cross_school_fight(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_cross_school_fight\\form_cross_school_fight", "on_cross_school_fight_msg", unpack(arg))
end
function on_gumu_rescue_msg(chander, arg_num, msg_type, ...)
  if nx_int(table.getn(arg)) < nx_int(1) then
    return
  end
  local sub_msg = arg[1]
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "add_form", 1, 59)
    if nx_int(table.getn(arg)) < nx_int(3) then
      return
    end
    local cur_count = nx_int(arg[2])
    local total_count = nx_int(arg[3])
    nx_execute("form_stage_main\\form_single_notice", "update_gumu_rescue_progress", cur_count, total_count)
  elseif nx_int(sub_msg) == nx_int(2) then
    if nx_int(table.getn(arg)) < nx_int(3) then
      return
    end
    local cur_count = nx_int(arg[2])
    local total_count = nx_int(arg[3])
    nx_execute("form_stage_main\\form_single_notice", "update_gumu_rescue_progress", cur_count, total_count)
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "del_form", 1, 59)
    nx_execute("form_stage_main\\form_single_notice", "ClearText", 59)
  end
end
function on_double_xiulian_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_task\\form_gmp_task_zhaoshi_1", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_task\\form_gmp_task_zhaoshi_1", "close_form", unpack(arg))
  end
end
function on_accept_friend_letter_flag(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_mail\\form_mail_accept", "refresh_accept_firend_letter_flag", unpack(arg))
end
function on_changfeng_moveto(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_force_school\\form_changfeng_map", "on_changfeng_moveto_msg", unpack(arg))
end
function on_guild_station_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_task", "on_guildstation_msg", unpack(arg))
end
function on_guild_city_def_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_def_escort", "on_guild_city_def_msg", unpack(arg))
end
function on_job_msg(chander, arg_num, msg_type, submsg, ...)
  if nx_int(submsg) == nx_int(3) and arg[1] ~= "" then
    nx_execute("form_stage_main\\form_origin\\form_origin", "show_origin_form", arg[1])
    return
  end
  local ret = ShowTipDialog(util_text("ui_sh_xsbh_01"))
  if nx_int(submsg) == nx_int(1) and ret then
    nx_execute("custom_sender", "custom_study_job")
  end
  if nx_int(submsg) == nx_int(2) and ret then
    nx_execute("custom_sender", "custom_study_job_upgrade")
  end
end
function on_dbomall_msg(chander, arg_num, msg_type, sub_msg, ...)
  local DMS_SUBMSG_FIRSTPAY_DATAINFO = 0
  local DMS_SUBMSG_FAVOUR_DATAINFO = 1
  local DMS_SUBMSG_TOTAL_DATAINFO = 2
  local DMS_SUBMSG_GUILD_AUTH_SEE = 11
  local DMS_SUBMSG_GUILD_AUTH_SEE_MEMBER = 12
  if nx_int(sub_msg) == nx_int(DMS_SUBMSG_FIRSTPAY_DATAINFO) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbofirst", "on_recv_firstpay_datainfo", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(DMS_SUBMSG_FAVOUR_DATAINFO) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbofavour", "on_recv_favour_datainfo", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(DMS_SUBMSG_TOTAL_DATAINFO) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbototal", "on_recv_total_datainfo", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(DMS_SUBMSG_GUILD_AUTH_SEE) then
    nx_execute("form_stage_main\\form_dbomall\\form_dboguild", "update_auth", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(DMS_SUBMSG_GUILD_AUTH_SEE_MEMBER) then
    nx_execute("form_stage_main\\form_dbomall\\form_dboguild", "update_auth_member", unpack(arg))
  end
end
function on_festival_sign(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_task\\form_yubi_activity", "on_server_msg", sub_msg, unpack(arg))
  else
    nx_execute("form_stage_main\\form_task\\form_festival_sign", "receive_server_msg", sub_msg, unpack(arg))
  end
end
function on_draw_prize(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_task\\form_draw_prize", "on_server_msg", sub_msg, unpack(arg))
end
function on_huashan_jianbei_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_force_school\\form_huashan_jianbei", "on_server_msg", unpack(arg))
end
function on_many_revenge(chander, arg_num, msg_type, sub_type, ...)
  if 3 == sub_type then
    nx_execute("form_stage_main\\form_tvt_person_info", "on_server_msg_manyrevenge", sub_type, unpack(arg))
  else
    nx_execute("form_stage_main\\form_match\\form_match", "on_server_msg_manyrevenge", sub_type, unpack(arg))
  end
end
function on_new_territory_msg(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_new_territory\\form_new_territory", "on_server_msg", unpack(arg))
end
function on_body_change(chander, arg_num, msg_type, ntype, action_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local player_visual = game_visual:GetPlayer()
  if not nx_is_valid(player_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if ntype == 3 then
    local role_composite = nx_value("role_composite")
    if nx_is_valid(role_composite) then
      role_composite:ChangeCustomAction(player_visual, client_player, true)
    end
  elseif ntype == 4 then
    local role_composite = nx_value("role_composite")
    if nx_is_valid(role_composite) then
      role_composite:ChangeCustomAction(player_visual, client_player, false)
    end
  elseif ntype == 1 then
    local action = nx_value("action_module")
    if not nx_is_valid(action) then
      return
    end
    action:BlendAction(player_visual, nx_string(action_id), false, false)
  end
end
function on_weather_war_switch(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "on_weather_msg", unpack(arg))
end
function on_statue_msg(chander, arg_num, msg_type, sub_msg, ...)
  local SVR_STATUE_SUBMSG_RELOAD = 0
  if nx_int(sub_msg) == nx_int(SVR_STATUE_SUBMSG_RELOAD) then
    local role_composite = nx_value("role_composite")
    if nx_is_valid(role_composite) then
      role_composite:LoadStatueInfo()
    end
  end
end
function on_skill_select_limit(chander, arg_num, msg_type, sub_msg, ...)
  local SERVER_SKILL_SELECT_TAOLU_LIST = 0
  local SERVER_SKILL_SELECT_OPEN_FORM = 1
  if nx_int(sub_msg) == nx_int(SERVER_SKILL_SELECT_TAOLU_LIST) then
    nx_execute("form_stage_main\\form_clone\\form_taolu_select", "refresh_select_taolu_list", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SERVER_SKILL_SELECT_OPEN_FORM) then
    nx_execute("form_stage_main\\form_clone\\form_taolu_select", "open_form", nx_int(arg[1]))
  end
end
function on_change_body_fuse(chander, arg_num, msg_type, sub_msg, ...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_item_fuse_bianshen", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_fuse_dazaotai(chander, arg_num, msg_type, sub_msg, ...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_fuse_dazaotai_additem", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Desktop:ToFront(form)
  end
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.rbtn_material.Checked = true
  end
end
function on_custom_wujidao(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_guild_war\\form_guild_chase_wjdgdxx", "reset_wjdgd_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    local form_mini_map = nx_value("form_stage_main\\form_main\\form_main_map")
    if nx_is_valid(form_mini_map) then
      form_mini_map.btn_wujidao_war.Visible = true
    end
  elseif nx_int(sub_msg) == nx_int(4) then
    local form_mini_map = nx_value("form_stage_main\\form_main\\form_main_map")
    if nx_is_valid(form_mini_map) then
      form_mini_map.btn_wujidao_war.Visible = false
    end
  end
end
function on_redpacket_msg(chander, _num, msg_type, ...)
  nx_execute("form_stage_main\\form_hongbaohuodong\\form_hongbaohuodong_hongbao", "on_server_msg", unpack(arg))
end
function on_linxiao_zhizun(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_lingxiao\\form_linxiao_zhizun", "on_server_msg", sub_msg, unpack(arg))
end
function on_custom_songjing_game(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "on_server_msg", sub_msg, unpack(arg))
end
function on_custom_newtresure_update(chander, arg_num, msg_type, sub_type)
  if "899000022" == nx_string(sub_type) then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_grave", "open_form")
  elseif "899000023" == nx_string(sub_type) then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_transfer", "open_form")
  elseif "899000025" == nx_string(sub_type) then
    nx_execute("form_stage_main\\form_help\\form_help_fcww", "open_form")
  end
end
function on_custom_refresh_newtresure_upgrade(chander, arg_num, msg_type)
  nx_execute("form_stage_main\\form_life\\form_newtreasure_transfer", "clear_form")
end
function on_msg_outland_event(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_outland\\form_movie_chose", "on_server_msg", sub_msg, unpack(arg))
end
function on_open_binglu_recover_form(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_binglu_huishou", "open_form")
end
function on_msg_bad_guy_vally_info(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_outland\\form_outland_play_achievement", "on_server_msg", unpack(arg))
    nx_execute("form_stage_main\\form_outland\\form_outland_play", "on_server_msg", unpack(arg))
  end
end
function on_msg_activity_guide_info(...)
  nx_execute("form_stage_main\\form_activity_guide", "load_activity_guide_info", unpack(arg))
end
function on_sky_hill_info(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_skyhill\\form_ttf_template", "server_reset_shilian_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_skyhill\\form_ttf_template", "server_open_shilian_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_skyhill\\form_clone_skyhill_achievement", "update_form", sub_msg, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_skyhill\\form_clone_skyhill_achievement", "update_form", sub_msg, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_skyhill\\form_ttf_template", "close_shilian_form")
    nx_execute("form_stage_main\\form_tongguanjiangli_five", "close_form")
    nx_execute("form_stage_main\\form_tongguanjiangli", "close_form")
    nx_execute("form_stage_main\\form_tongguanshibai", "close_form")
    nx_execute("form_stage_main\\form_xmqy_detail", "close_match_below")
  elseif nx_int(sub_msg) == nx_int(5) then
    if nx_int(arg[4]) == nx_int(0) then
      nx_execute("form_stage_main\\form_tongguanjiangli_five", "open_form", unpack(arg))
    else
      nx_execute("form_stage_main\\form_tongguanjiangli", "open_form", unpack(arg))
    end
  else
    if nx_int(sub_msg) == nx_int(7) then
      nx_execute("form_stage_main\\form_tongguanshibai", "open_form", unpack(arg))
    else
    end
  end
end
function on_san_hill_info(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_skyhill\\form_sanhill", "on_server_msg", sub_msg, unpack(arg))
end
function on_single_shop_info(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_shop\\form_single_shop", "on_server_msg", sub_msg, unpack(arg))
end
function on_msg_shijia_achievement_info(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_shijia\\form_shijia_achievement", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
  end
end
function on_school_extinct(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_school_counterattack\\form_counter_attack_rank", "update_rank", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "refresh_sca_npc_pos", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_school_destroy\\form_school_destroy_fightback", "on_fightback_server_msg", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(20) then
    nx_execute("form_stage_main\\form_school_destroy\\form_protect_school_map", "on_map_msg", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(21) then
    nx_execute("form_stage_main\\form_school_destroy\\form_invade_battle", "show_step_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(22) then
    nx_execute("form_stage_main\\form_school_destroy\\form_invade_battle", "show_leavetime_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(23) then
    nx_execute("form_stage_main\\form_school_destroy\\form_protect_school_map", "on_camp_msg", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(40) then
    nx_execute("form_stage_main\\form_school_destroy\\form_school_destroy_main", "on_school_historylog", unpack(arg))
    nx_execute("form_stage_main\\form_school_war\\form_school_msg_info_extermination", "on_extermin_server_msg", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(41) then
    nx_execute("form_stage_main\\form_school_destroy\\form_school_destroy_main", "on_school_current_stage", unpack(arg))
  end
end
function on_msg_shijia_trans(chander, arg_num, msg_type, sub_msg, times)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_shijia\\form_shijia_play", "on_server_msg", nx_int(times))
  end
end
function on_msg_shijia_play_time(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_shijia\\form_play_time", "on_shijia_play_time", unpack(arg))
end
function on_msg_yanmen_bazhentu(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_main\\form_main", "set_btn_bzt_visible", unpack(arg))
end
function on_msg_match_sanmeng(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_match\\form_match_sanmeng", "on_server_msg", unpack(arg))
  nx_execute("form_stage_main\\form_match\\form_guild_union", "on_server_msg", unpack(arg))
end
function on_msg_auction(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "update_compete", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "update_sell", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "update_sell_single", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "delete_refresh_single", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "update_refresh_single", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "update_refresh", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "compete_ok", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(7) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "buy_ok", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(8) then
    nx_execute("form_stage_main\\form_auction\\form_auction_main", "down_ok", unpack(arg))
  end
end
function on_msg_shijia_yanwu(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_shijia\\form_shijia_yanwu", "on_server_msg", sub_msg, unpack(arg))
end
function on_guild_luck_pray(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_pray", "on_server_msg", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_task", "show_guild_luck_task", unpack(arg))
  end
end
function on_map_npc_icon_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "add_move_npc_icon", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "del_move_npc_icon", unpack(arg))
  end
end
function on_new_teacher_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_request_new", "on_server_msg", sub_msg, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) or nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_request_new", "on_server_msg", sub_msg, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_teacher_pupil_new\\form_my_teacher_pupil_new", "on_server_msg", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_register_new", "on_server_msg", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) or nx_int(sub_msg) == nx_int(7) or nx_int(sub_msg) == nx_int(8) then
    nx_execute("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_shop_new", "on_server_msg", sub_msg, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_teacher_pupil_new\\form_my_teacher_pupil_new", "on_server_msg_task", unpack(arg))
  end
end
function on_select_school_confirm(chander, arg_num, msg_type, ...)
  if table.getn(arg) ~= nx_number(1) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("ui_chooseschool_001", nx_widestr(gui.TextManager:GetText(arg[1])))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_select_school", 1, arg[1])
  end
end
function on_betray_school_confirm(chander, arg_num, msg_type, ...)
  if table.getn(arg) ~= nx_number(1) then
    return
  end
  if nx_int(1) ~= nx_int(arg[1]) then
    return
  end
  local gui = nx_value("gui")
  local dia = nx_execute("util_gui", "util_get_form", "form_common\\form_betray_new_school_confirm", true, false)
  dia.event_type = "betray"
  dia:ShowModal()
  local res = nx_wait_event(100000000, dia, "betray_confirm_return")
  if "ok" == res then
    nx_execute("custom_sender", "custom_betray_new_school", 2)
    return
  else
    return
  end
end
function on_royal_treasure(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "set_in_rtm_group", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_royal_treasure_invite", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_royal_treasure", "open_form", unpack(arg))
  end
end
function on_balance_war_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready", "open_balance_war_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready", "rec_wuxue_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_info", "rec_balance_war_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_info", "rec_balance_war_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_result", "rec_self_team_balance_war_result", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_result", "rec_enemy_team_balance_war_result", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(7) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_result", "open_balance_result_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(8) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_result", "compel_close_result_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(9) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance", "rec_balance_war_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(10) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_room", "open_room_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(11) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_shortcut_form_main_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(12) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance", "show_battle_begin_animation", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(13) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "neigong_bing_weapon", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(14) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "balance_war_open_score_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(15) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance", "rec_balance_war_equip_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(16) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance", "rec_balance_war_channels_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(17) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(1) then
      nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready", "rec_equip_data_in_war", unpack(arg))
    elseif nx_int(page_index) == nx_int(2) then
      nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready_before", "rec_player_before_equip_plane", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(18) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance", "rec_balance_wuxue_data_by_day", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(19) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(20) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready_before", "rec_before_wuxue_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(21) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(1) then
      nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready_before", "rec_player_selected_plane", unpack(arg))
    elseif nx_int(page_index) == nx_int(2) then
      nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready", "rec_player_plane_have", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(30) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_kick", "open_kick_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(31) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready", "rec_updata_wuxue_left_times", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(32) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready", "close_ready_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(500) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(0) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "updata_player_jm_data", unpack(arg))
    elseif nx_int(page_index) == nx_int(1) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "updata_player_jm_data", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(501) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(0) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "updata_player_ng_data", unpack(arg))
    elseif nx_int(page_index) == nx_int(1) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "updata_player_ng_data", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(502) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(0) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "updata_player_equip_data", unpack(arg))
    elseif nx_int(page_index) == nx_int(1) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "updata_player_equip_data", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(503) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "updata_player_tl_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(504) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(0) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "updata_player_pn_data", unpack(arg))
    elseif nx_int(page_index) == nx_int(1) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "updata_player_pn_data", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(505) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_shortcut_form_main_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(506) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "neigong_bing_weapon", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(507) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_leader_BP", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(508) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_leader_BP", "updata_bp_wuxue_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(509) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "show_team_enemy_name_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(510) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "show_team_self_name_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(511) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "updata_self_bp_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(512) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "updata_enemy_bp_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(513) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(514) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(515) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_leader_BP", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(516) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "show_team_select_wuxue", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(517) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_abandon", "updata_abandon_state", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(518) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_abandon", "updata_abandon_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(519) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_BP", "updata_left_select_num", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(520) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance", "updata_week_goal", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(521) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_leader_BP", "rec_is_Leader", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(522) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_abandon", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(523) then
    nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_abandon", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(524) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(0) then
      nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "updata_baowu_plane", unpack(arg))
    elseif nx_int(page_index) == nx_int(1) then
    end
  elseif nx_int(sub_msg) == nx_int(525) then
  elseif nx_int(sub_msg) == nx_int(526) then
  elseif nx_int(sub_msg) == nx_int(527) then
  elseif nx_int(sub_msg) == nx_int(528) then
  elseif nx_int(sub_msg) == nx_int(529) then
  end
end
function on_wudao_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "rec_take_part_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(12) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_kick", "open_kick_form", unpack(arg))
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_kick", "set_left_time", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(13) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "begin_look", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(14) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "show_battle_begin_animation", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(15) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "rec_team_member_ready_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(16) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready", "open_wudao_ready_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(17) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_result", "open_wudao_wulin_result_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(18) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_result", "rec_wudao_war_result_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(19) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "balance_war_open_score_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(20) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main", "rec_wudao_join_time", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(21) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_gm", "receive_gm_ui", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(22) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "open_room_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(23) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "open_group_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(24) then
    nx_execute("form_stage_main\\form_main\\form_main", "show_or_hide_effect", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(25) then
    nx_execute("form_stage_main\\form_main\\form_main", "open_alive_web", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(50) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "rec_player_owner_team_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(51) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "rec_team_member_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(52) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_invite", "rec_invent_to_join", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(53) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_daily", "rec_wudao_team_event_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(54) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_apply", "rec_wudao_team_apply_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(55) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_invite", "rec_can_invent_player_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(56) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "rec_team_list", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(57) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "rec_team_name_check_result", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(58) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_invite", "rec_server_list", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(59) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_invite", "rec_find_player_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(60) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_search_team", "rec_query_war_team_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(61) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "shut_war_team_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(62) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main", "rec_wudao_war_equip_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(63) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(1) then
      nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready", "rec_equip_data_in_war", unpack(arg))
    elseif nx_int(page_index) == nx_int(2) then
      nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready_before", "rec_player_wudao_before_equip_plane", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(64) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main", "rec_wudao_war_channels_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(65) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_shortcut_form_main_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(66) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "neigong_bing_weapon", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(67) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready_before", "open_wudao_ready_before_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(68) then
    local page_index = nx_int(arg[1])
    if nx_int(page_index) == nx_int(1) then
      nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready_before", "rec_player_wudao_selected_plane", unpack(arg))
    elseif nx_int(page_index) == nx_int(2) then
      nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready", "rec_player_plane_have", unpack(arg))
    end
  elseif nx_int(sub_msg) == nx_int(69) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready", "close_ready_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(70) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready", "rec_wuxue_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(71) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(72) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(73) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "rec_room_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(74) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_group_result", "rec_team_score_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(75) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "rec_group_match_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_banpick", "update_ban", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(7) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_banpick", "update_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(8) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_banpick", "reopen_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(9) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_banpick", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(10) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_banpick", "update_player", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(11) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_banpick", "update_stage", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(76) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_final", "receive_final_ui", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(77) then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_final", "receive_final_ui_one_group", unpack(arg))
  end
end
function on_luandou_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "rec_can_open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "rec_luan_dou_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_skill_choose", "rec_player_own_skill", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_skill_choose", "rec_all_player_can_select_skill", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_shortcut_form_main_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "neigong_bing_weapon", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(7) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "updata_player_equip_data")
  elseif nx_int(sub_msg) == nx_int(8) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "updata_player_jm_data")
  elseif nx_int(sub_msg) == nx_int(9) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "updata_player_ng_data")
  elseif nx_int(sub_msg) == nx_int(10) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "open_limite_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(101) then
    nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "show_battle_begin_animation", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(102) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "rec_every_week_goal", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(103) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_single", "rec_player_achievement", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(104) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_score", "force_open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(105) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_score", "receive_result_ui", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(106) then
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "balance_war_open_score_form", unpack(arg))
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "hide_win")
  elseif nx_int(sub_msg) == nx_int(107) then
    local add_score = nx_int(arg[1])
    nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "show_add_score_effect", add_score)
  elseif nx_int(sub_msg) == nx_int(108) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_score", "refresh_ui", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(109) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_best", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(110) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "rec_luandou_record", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(111) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "rec_self_luandou_record", unpack(arg))
  end
end
function on_taosha_msg(chander, arg_num, msg_type, sub_msg, ...)
  local count = table.getn(arg)
  if nx_int(sub_msg) == nx_int(200) then
    if count < 3 then
      return
    end
    local TaoShaManager = nx_value("TaoShaManager")
    if nx_is_valid(TaoShaManager) then
      TaoShaManager:ShowBorder(nx_float(arg[1]), nx_float(arg[2]), nx_float(arg[3]), 0)
    end
  elseif nx_int(sub_msg) == nx_int(202) then
    if nx_int(table.getn(arg)) < nx_int(5) then
      return
    end
    local TaoShaManager = nx_value("TaoShaManager")
    if nx_is_valid(TaoShaManager) then
      TaoShaManager:UpdateTaoShaEventRange(nx_int(arg[1]), nx_int(arg[2]), nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[5]))
    end
  elseif nx_int(sub_msg) == nx_int(203) then
    if count < 3 then
      return
    end
    local TaoShaManager = nx_value("TaoShaManager")
    if nx_is_valid(TaoShaManager) then
      local radius = nx_float(arg[1])
      local x = nx_float(arg[2])
      local z = nx_float(arg[3])
      local circle_type = nx_int(2)
      local image = nx_string("gui\\special\\taosha\\taosha_2.png")
      TaoShaManager:ShowCircleAtMap(circle_type, image, radius, x, z)
    end
  elseif nx_int(sub_msg) == nx_int(101) then
    nx_execute("form_stage_main\\form_taosha\\taosha_util", "show_snow_warn_animation")
  elseif nx_int(sub_msg) == nx_int(102) then
    nx_execute("form_stage_main\\form_taosha\\form_taosha_main", "rec_main_form_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(104) then
    nx_execute("form_stage_main\\form_taosha\\form_taosha_main", "rec_bao_ming_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(105) then
    nx_execute("form_stage_main\\form_taosha\\form_taosha_awards", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(106) then
    nx_execute("form_stage_main\\form_taosha\\form_taosha_notice", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_shortcut_form_main_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_taosha\\form_taosha_main", "rec_player_pickup_item_num", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_taosha\\form_skill_choose", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_taosha\\form_skill_choose", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_taosha\\form_taosha_map_scene", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(11) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "rec_taolu_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(12) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "rec_skill_yushe_info", unpack(arg))
  end
end
function on_apex_msg(chander, arg_num, msg_type, sub_msg, ...)
  local count = table.getn(arg)
  if nx_int(sub_msg) == nx_int(50) then
    nx_execute("form_stage_main\\form_taosha\\form_apex_match", "on_apex_invite", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(51) then
    nx_execute("form_stage_main\\form_taosha\\form_apex_match", "on_apex_apply_success", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(52) then
    nx_execute("form_stage_main\\form_taosha\\form_apex_match", "on_apex_apply_cancel", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(106) then
    nx_execute("form_stage_main\\form_taosha\\form_apex_notice", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(200) then
    if count < 3 then
      return
    end
    local TaoShaManager = nx_value("TaoShaManager")
    if nx_is_valid(TaoShaManager) then
      TaoShaManager:ShowBorder(nx_float(arg[1]), nx_float(arg[2]), nx_float(arg[3]), 1)
    end
  elseif nx_int(sub_msg) == nx_int(202) then
    if nx_int(table.getn(arg)) < nx_int(5) then
      return
    end
    local TaoShaManager = nx_value("TaoShaManager")
    if nx_is_valid(TaoShaManager) then
      TaoShaManager:UpdateTaoShaEventRange(nx_int(arg[1]), nx_int(arg[2]), nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[5]))
    end
  elseif nx_int(sub_msg) == nx_int(203) then
    if count < 3 then
      return
    end
    local TaoShaManager = nx_value("TaoShaManager")
    if nx_is_valid(TaoShaManager) then
      local radius = nx_float(arg[1])
      local x = nx_float(arg[2])
      local z = nx_float(arg[3])
      local circle_type = nx_int(2)
      local image = nx_string("gui\\special\\taosha\\taosha_2.png")
      TaoShaManager:ShowCircleAtMap(circle_type, image, radius, x, z)
    end
  elseif nx_int(sub_msg) == nx_int(101) then
    nx_execute("form_stage_main\\form_taosha\\apex_util", "show_snow_warn_animation")
  elseif nx_int(sub_msg) == nx_int(102) then
  elseif nx_int(sub_msg) == nx_int(104) then
  elseif nx_int(sub_msg) == nx_int(105) then
    nx_execute("form_stage_main\\form_taosha\\form_apex_awards", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(106) then
    nx_execute("form_stage_main\\form_taosha\\form_apex_notice", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(108) then
    nx_execute("form_stage_main\\form_taosha\\form_team_ts_succeed", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(109) then
    nx_execute("form_stage_main\\form_taosha\\apex_util", "confirm_relife_member")
  elseif nx_int(sub_msg) == nx_int(110) then
    nx_execute("form_stage_main\\form_taosha\\apex_util", "confirm_npc_relife_member")
  elseif nx_int(sub_msg) == nx_int(111) then
    nx_execute("form_stage_main\\form_taosha\\form_apex_apply", "week_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(112) then
    nx_execute("form_stage_main\\form_taosha\\form_apex_apply", "refresh_box_achievement")
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_shortcut_form_main_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_taosha\\apex_util", "rec_player_pickup_item_num", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_taosha\\form_skill_choose", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_taosha\\form_skill_choose", "close_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_taosha\\form_taosha_map_scene", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(11) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "rec_taolu_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(12) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "rec_skill_yushe_info", unpack(arg))
  end
end
function on_see_msg(chander, arg_num, msg_type, sub_msg, ...)
  local n = #arg
  if nx_int(sub_msg) == nx_int(1) then
    if n <= 0 then
      return
    end
    local target_name = nx_widestr(arg[1])
    nx_execute("form_stage_main\\form_taosha\\see_util", "recv_start_see", target_name)
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_taosha\\see_util", "recv_stop", unpack(arg))
  end
end
function custom_gupu_learn(chander, arg_num, msg_type, ...)
  if table.getn(arg) ~= nx_number(2) then
    return
  end
  local valid_time = arg[1]
  local gupu_skill_state = arg[2]
  local gui = nx_value("gui")
  local retain_time_text = nx_widestr("")
  if nx_number(valid_time) > 0 then
    local day = math.floor(nx_number(valid_time) / 86400)
    if nx_int(day) > nx_int(0) then
      retain_time_text = nx_widestr(day) .. nx_widestr(util_text("ui_day"))
    end
    local hour_min = math.floor(nx_number(valid_time) % 86400)
    local hour = math.floor(nx_number(hour_min) / 3600)
    local min = math.floor(nx_number(hour_min) % 3600 / 60)
    if nx_int(hour) > nx_int(0) then
      retain_time_text = nx_widestr(retain_time_text) .. nx_widestr(hour) .. nx_widestr(util_text("ui_hour"))
    end
    if nx_int(min) > nx_int(0) then
      retain_time_text = nx_widestr(retain_time_text) .. nx_widestr(min) .. nx_widestr(util_text("ui_minute"))
    end
  end
  local text = ""
  if gupu_skill_state == 1 then
    text = gui.TextManager:GetFormatText("sys_gujsmzb_gujgup_001")
  elseif gupu_skill_state == 2 then
    text = gui.TextManager:GetFormatText("sys_gujsmzb_gujgup_002") .. nx_widestr("<font color='#ff0000'>") .. nx_widestr(retain_time_text) .. nx_widestr("</font>")
  elseif gupu_skill_state == 3 then
    text = gui.TextManager:GetFormatText("sys_gujsmzb_gujgup_003")
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_learn_gupu_skill")
  end
end
function on_sns_news(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_relation\\form_great_events", "show_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_red_dot", true)
  end
end
function on_home_farm(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_home\\form_home_farm", "on_server", sub_msg, unpack(arg))
end
function on_home_mine(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_home\\form_home_mine", "on_server", sub_msg, unpack(arg))
end
function on_handle_jyf(chander, arg_num, msg_type, sub_msg, ...)
  local STCM_UPGRADE_SKILL_PLAY_ACTION = nx_int(1)
  local STCM_OPEN_WAIT_UI = nx_int(2)
  local STCM_CLOSE_WAIT_UI = nx_int(3)
  local STCM_SHOW_RANK_RESULT = nx_int(4)
  local STCM_QUERY_ALL_SCHEDULE = nx_int(5)
  local STCM_JIUYANG_FACULTY_AWARD = nx_int(6)
  local STCM_FACULTY_FINISH = nx_int(7)
  local STCM_FACULTY_START = nx_int(8)
  local STCM_FACULTY_FINISHEX = nx_int(9)
  if nx_int(sub_msg) == STCM_OPEN_WAIT_UI then
    nx_execute("form_stage_main\\form_jiuyang_faculty\\form_jyf_wait", "show_form", true)
  elseif nx_int(sub_msg) == STCM_CLOSE_WAIT_UI then
    nx_execute("form_stage_main\\form_jiuyang_faculty\\form_jyf_wait", "show_form", false)
  elseif nx_int(sub_msg) == STCM_UPGRADE_SKILL_PLAY_ACTION then
    nx_execute("form_stage_main\\form_jiuyang_faculty\\form_jiuyang_faculty_upgrade", "show_zhaoshi_by_index", unpack(arg))
  elseif nx_int(sub_msg) == STCM_SHOW_RANK_RESULT then
    nx_execute("form_stage_main\\form_jiuyang_faculty\\form_jiuyang_rank", "open_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STCM_QUERY_ALL_SCHEDULE) then
    nx_execute("form_stage_main\\form_jiuyang_faculty\\form_jyf_schedule", "reset_schedule", unpack(arg))
  elseif nx_int(sub_msg) == STCM_JIUYANG_FACULTY_AWARD then
    nx_execute("form_stage_main\\form_jiuyang_faculty\\form_jiuyang_faculty_award", "open_form", unpack(arg))
    nx_execute("form_stage_main\\form_main\\form_main_map", "close_form_battlefield_score")
  elseif nx_int(sub_msg) == STCM_FACULTY_FINISH then
    local delay_timer = nx_value("timer_game")
    if nx_is_valid(delay_timer) then
      delay_timer:UnRegister(nx_current(), "on_delay_show_jyf_info", nx_value("game_client"))
    end
    nx_execute("form_stage_main\\form_main\\form_main_map", "set_btn_jy_rank_visible", false)
    nx_execute("form_stage_main\\form_map\\form_map_scene", "del_jyf_icon")
  elseif nx_int(sub_msg) == STCM_FACULTY_START then
    local stage_main_flag = nx_value("stage_main")
    local loading_flag = nx_value("loading")
    local arg1, arg2
    if 2 <= table.getn(arg) then
      arg1 = arg[1]
      arg2 = arg[2]
    end
    if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
      local delay_timer = nx_value("timer_game")
      if nx_is_valid(delay_timer) then
        delay_timer:UnRegister(nx_current(), "on_delay_show_jyf_info", nx_value("game_client"))
        delay_timer:Register(5000, -1, nx_current(), "on_delay_show_jyf_info", nx_value("game_client"), arg1, arg2)
      end
    else
      on_delay_show_jyf_info(nx_value("game_client"), arg1, arg2)
    end
  elseif nx_int(sub_msg) == nx_int(STCM_FACULTY_FINISHEX) then
    nx_execute("form_stage_main\\form_main\\form_main_map", "close_form_battlefield_score")
  end
end
function on_delay_show_jyf_info(obj, scene_id, stage)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  local delay_timer = nx_value("timer_game")
  if nx_is_valid(delay_timer) then
    delay_timer:UnRegister(nx_current(), "on_delay_show_jyf_info", nx_value("game_client"))
    nx_execute("form_stage_main\\form_main\\form_main_map", "set_btn_jy_rank_visible", true)
    if scene_id ~= nil and stage ~= nil then
      nx_execute("form_stage_main\\form_map\\form_map_scene", "set_jyf_info", nx_string(scene_id) .. "," .. nx_string(stage))
    end
  end
end
function on_custom_sign_n_draw(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_dbomall\\form_sign_and_draw", "on_refresh", sub_msg, unpack(arg))
end
function on_custom_online_purchase_rebate(chander, arg_num, msg_type, sub_msg, ...)
  nx_execute("form_stage_main\\form_dbomall\\form_dboconsume", "on_refresh", sub_msg, unpack(arg))
end
function on_custom_guildglobalwar(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_domain", "on_receive", unpack(arg))
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_map", "on_receive", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_rank", "on_receive", 3, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_rank", "on_receive", 4, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(3) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_domain", "refresh_player_trace", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(4) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_domain", "on_war_receive", unpack(arg))
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_map", "update_domain_info", unpack(arg))
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_map", "on_war_receive", unpack(arg))
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_small_map", "update_domain_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(5) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_tips", "close_form")
  elseif nx_int(sub_msg) == nx_int(6) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_h", "open_form", 2)
  elseif nx_int(sub_msg) == nx_int(101) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_map", "update_info", unpack(arg))
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_small_map", "update_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(102) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_dead", "update_info", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(103) then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_word", "update_info", unpack(arg))
  end
end
function on_cross_station_war_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_number(sub_msg) == 0 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "update_next_war", unpack(arg))
  elseif nx_number(sub_msg) == 1 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "update_last_war_res", unpack(arg))
  elseif nx_number(sub_msg) == 2 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_award", "update_info", unpack(arg))
  elseif nx_number(sub_msg) == 3 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_h", "update_guild_info", unpack(arg))
  elseif nx_number(sub_msg) == 4 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_h", "update_guild_rank", unpack(arg))
  elseif nx_number(sub_msg) == 5 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_buy", "update_flag_nums", unpack(arg))
  end
end
function on_cross_server_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_number(sub_msg) == 0 then
    nx_execute("form_stage_main\\form_league_matches\\form_cross_wait", "open_form", unpack(arg))
  end
end
function on_league_matches_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_number(sub_msg) == 0 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_lm_apply", unpack(arg))
    nx_execute("form_stage_main\\form_league_matches\\form_lm_main", "on_lm_apply", unpack(arg))
  elseif nx_number(sub_msg) == 1 then
    local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_LEAGUE_MATCHES, chander, 60)
  elseif nx_number(sub_msg) == 2 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_lm_guild", unpack(arg))
    nx_execute("form_stage_main\\form_league_matches\\form_lm_main", "on_lm_guild", unpack(arg))
  elseif nx_number(sub_msg) == 3 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_lm_cross", unpack(arg))
    nx_execute("form_stage_main\\form_league_matches\\form_lm_main", "on_lm_cross", unpack(arg))
  elseif nx_number(sub_msg) == 4 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_lm_group", unpack(arg))
    nx_execute("form_stage_main\\form_league_matches\\form_lm_main", "on_lm_group", unpack(arg))
  elseif nx_number(sub_msg) == 5 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_lm_rank", unpack(arg))
    nx_execute("form_stage_main\\form_league_matches\\form_lm_main", "on_lm_rank", unpack(arg))
  elseif nx_number(sub_msg) == 6 then
    nx_execute("form_stage_main\\form_league_matches\\form_lm_war_info", "on_lm_war_info", unpack(arg))
  elseif nx_number(sub_msg) == 7 then
    nx_execute("form_stage_main\\form_league_matches\\form_lm_drag", "on_lm_drag", unpack(arg))
  elseif nx_number(sub_msg) == 8 then
    nx_execute("form_stage_main\\form_league_matches\\form_lm_see_list", "on_lm_see_list", unpack(arg))
  elseif nx_number(sub_msg) == 9 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_lm_res_his", unpack(arg))
    nx_execute("form_stage_main\\form_league_matches\\form_lm_main", "on_lm_res_his", unpack(arg))
  elseif nx_number(sub_msg) == 10 then
    nx_execute("form_stage_main\\form_league_matches\\form_lm_see", "open_form", unpack(arg))
  elseif nx_number(sub_msg) == 11 then
    nx_execute("form_stage_main\\form_league_matches\\form_lm_see", "close_form", unpack(arg))
  elseif nx_number(sub_msg) == 12 then
    nx_execute("form_stage_main\\form_league_matches\\form_lm_drag", "on_lm_drag_confirm", unpack(arg))
  elseif nx_number(sub_msg) == 13 then
    nx_execute("form_stage_main\\form_league_matches\\form_cross_wait", "on_handler_modal_form", unpack(arg))
  end
end
function on_champion_war_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_number(sub_msg) == 0 then
    nx_execute("form_stage_main\\form_guild_battle\\form_cw_invite", "open_form", unpack(arg))
  elseif nx_number(sub_msg) == 1 then
    nx_execute("form_stage_main\\form_guild_battle\\form_cw_match", "close_form", unpack(arg))
  elseif nx_number(sub_msg) == 2 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_cw_circle_info", unpack(arg))
  elseif nx_number(sub_msg) == 3 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_cw_circle_stage", unpack(arg))
  elseif nx_number(sub_msg) == 4 then
    custom_sysinfo(0, 0, 0, 2, nx_string("sys_cw_015"))
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_apply_ok", unpack(arg))
  elseif nx_number(sub_msg) == 5 then
    custom_sysinfo(0, 0, 0, 2, nx_string("sys_cw_016"))
  elseif nx_number(sub_msg) == 6 then
    nx_execute("form_stage_main\\form_guild_battle\\form_cw_match", "open_form", unpack(arg))
    nx_execute("custom_sender", "custom_champion_war", 103)
  elseif nx_number(sub_msg) == 7 then
    custom_sysinfo(0, 0, 0, 2, nx_string("sys_cw_017"))
    nx_execute("form_stage_main\\form_guild_battle\\form_cw_match", "close_form", unpack(arg))
  elseif nx_number(sub_msg) == 8 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_cw_today_res", unpack(arg))
  elseif nx_number(sub_msg) == 9 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_cw_member_info", unpack(arg))
  elseif nx_number(sub_msg) == 10 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_cw_member_his", unpack(arg))
  elseif nx_number(sub_msg) == 11 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_cw_guild_his", unpack(arg))
  elseif nx_number(sub_msg) == 12 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_cw_player_info", unpack(arg))
  elseif nx_number(sub_msg) == 13 then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info", "on_cw_gold_rank", unpack(arg))
  elseif nx_number(sub_msg) == 20 then
    nx_execute("form_stage_main\\form_guild_battle\\form_guild_battle_score", "on_server_msg", unpack(arg))
  elseif nx_number(sub_msg) == 21 then
    local wartype = nx_int(arg[1])
    if nx_int(wartype) == nx_int(1) then
      local sub_type = nx_int(arg[2])
      local form_ui = "form_stage_main\\form_guild_battle\\form_guildbattle_show_" .. nx_string(sub_type)
      local form = util_get_form(nx_string(form_ui), true)
      if nx_is_valid(form) then
        form:Show()
        form.Visible = true
      end
    end
  elseif nx_number(sub_msg) == 22 then
    local wartype = nx_int(arg[1])
    local form_ui = "form_stage_main\\form_guild_battle\\form_guildbattle_" .. nx_string(wartype) .. "_1"
    nx_execute(form_ui, "on_server_msg", unpack(arg))
  elseif nx_number(sub_msg) == 23 then
  elseif nx_number(sub_msg) == 24 then
  elseif nx_number(sub_msg) == 202 then
    nx_execute("form_stage_main\\form_guild_battle\\form_guild_battle_power", "updata_player_jm_data", unpack(arg))
  elseif nx_number(sub_msg) == 203 then
    nx_execute("form_stage_main\\form_guild_battle\\form_guild_battle_power", "updata_player_ng_data", unpack(arg))
  elseif nx_number(sub_msg) == 204 then
    nx_execute("form_stage_main\\form_guild_battle\\form_guild_battle_power", "updata_player_equip_data", unpack(arg))
  elseif nx_number(sub_msg) == 205 then
    nx_execute("form_stage_main\\form_guild_battle\\form_guild_battle_power", "updata_player_own_skill_data", unpack(arg))
  elseif nx_number(sub_msg) == 206 then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_shortcut_form_main_page", unpack(arg))
  elseif nx_number(sub_msg) == 207 then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "neigong_bing_weapon", unpack(arg))
  end
end
function on_tarot_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(0) then
    nx_execute("form_stage_main\\form_tarot\\form_tarot_main", "update_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_tarot\\form_tarot_collect", "update_form", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_tarot\\form_tarot_main", "on_query", unpack(arg))
  end
end
function on_wudao_yanwu_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_shortcut_form_main_page", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(2) then
    nx_execute("form_stage_main\\form_war_scuffle\\form_balance_total", "rec_wudao_yanwu_attend_info", unpack(arg))
  end
end
function on_activity_horse_race_msg(chander, arg_num, msg_type, sub_msg, ...)
  if nx_int(sub_msg) == nx_int(1) then
    nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "show_battle_begin_animation", unpack(arg))
  end
end
function on_custom_check_delete_force(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_confirm_force", "open_panel", unpack(arg))
end
function on_tj_redpacket(chander, arg_num, msg_type, submsg, ...)
  if nx_int(submsg) == nx_int(1) then
    nx_execute("form_stage_main\\form_newhongbao\\form_newhongbao", "on_server_msg", submsg, unpack(arg))
  elseif nx_int(submsg) == nx_int(2) then
    nx_execute("form_stage_main\\form_newhongbao\\form_newhongbao", "on_server_msg", submsg, unpack(arg))
  end
end
function on_custom_newpacket(chander, arg_num, msg_type, submsg, ...)
  if nx_int(0) == nx_int(submsg) then
    nx_execute("form_stage_main\\form_hongbao\\form_hongbao_detail", "on_server_msg", unpack(arg))
  elseif nx_int(1) == nx_int(submsg) then
    nx_execute("form_stage_main\\form_hongbao\\form_hongbao_record", "on_server_get_record", unpack(arg))
  elseif nx_int(2) == nx_int(submsg) then
    nx_execute("form_stage_main\\form_hongbao\\form_hongbao_record", "on_server_send_record", unpack(arg))
  elseif nx_int(3) == nx_int(submsg) then
    util_show_form("form_stage_main\\form_hongbao\\form_hongbao_receive", false)
    util_show_form("form_stage_main\\form_hongbao\\form_hongbao_open", false)
    nx_execute("form_stage_main\\form_hongbao\\form_hongbao_open", "on_server_msg", unpack(arg))
  elseif nx_int(4) == nx_int(submsg) then
    util_show_form("form_stage_main\\form_hongbao\\form_hongbao_receive", false)
    nx_execute("form_stage_main\\form_hongbao\\form_hongbao_receive", "on_server_msg", unpack(arg))
  end
end
function on_custom_ver_201904(chander, arg_num, msg_type, submsg, ...)
  if nx_int(0) == nx_int(submsg) then
    nx_execute("form_stage_main\\form_ver_201904\\form_scene_form", "on_server_msg", unpack(arg))
  end
end
function on_msg_new_war_rule(chander, arg_num, msg_type, ...)
  nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "on_server_msg", unpack(arg))
end
