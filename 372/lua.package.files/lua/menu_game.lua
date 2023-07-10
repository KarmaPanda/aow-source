require("util_gui")
require("util_functions")
require("const_define")
require("define\\object_type_define")
require("define\\request_type")
require("define\\team_sign_define")
require("define\\team_rec_define")
require("share\\npc_type_define")
require("share\\client_custom_define")
require("share\\view_define")
require("define\\sysinfo_define")
require("form_stage_main\\form_home\\form_home_msg")
require("form_stage_main\\form_die_util")
require("custom_sender")
local team_icon_width = 22
function init_menu_data()
  local tip_weiyi = util_text("ui_WeiYi")
  local tip_haixiu = util_text("ui_HaiXiu")
  local tip_baoqi = util_text("ui_BaoQi")
  player_sign_data = {
    {
      "team",
      "player_set_sign_1",
      "  ",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[1],
      TEAM_SIGN_ICON_SIZE[1],
      team_icon_width
    },
    {
      "team",
      "player_set_sign_2",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[2],
      TEAM_SIGN_ICON_SIZE[2],
      team_icon_width
    },
    {
      "team",
      "player_set_sign_3",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[3],
      TEAM_SIGN_ICON_SIZE[3],
      team_icon_width
    },
    {
      "team",
      "player_set_sign_4",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[4],
      TEAM_SIGN_ICON_SIZE[4],
      team_icon_width
    },
    {
      "team",
      "player_set_sign_5",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[5],
      TEAM_SIGN_ICON_SIZE[5],
      team_icon_width
    },
    {
      "team",
      "player_set_sign_6",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[6],
      TEAM_SIGN_ICON_SIZE[6],
      team_icon_width
    },
    {
      "team",
      "player_set_sign_7",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[7],
      TEAM_SIGN_ICON_SIZE[7],
      team_icon_width
    },
    {
      "team",
      "player_set_sign_8",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[8],
      TEAM_SIGN_ICON_SIZE[8],
      team_icon_width
    },
    {
      "team",
      "player_set_sign_0",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[0],
      TEAM_SIGN_ICON_SIZE[0],
      team_icon_width
    }
  }
  team_sign_data = {
    {
      "team",
      "team_set_sign_1",
      "  ",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[1],
      TEAM_SIGN_ICON_SIZE[1],
      team_icon_width
    },
    {
      "team",
      "team_set_sign_2",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[2],
      TEAM_SIGN_ICON_SIZE[2],
      team_icon_width
    },
    {
      "team",
      "team_set_sign_3",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[3],
      TEAM_SIGN_ICON_SIZE[3],
      team_icon_width
    },
    {
      "team",
      "team_set_sign_4",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[4],
      TEAM_SIGN_ICON_SIZE[4],
      team_icon_width
    },
    {
      "team",
      "team_set_sign_5",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[5],
      TEAM_SIGN_ICON_SIZE[5],
      team_icon_width
    },
    {
      "team",
      "team_set_sign_6",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[6],
      TEAM_SIGN_ICON_SIZE[6],
      team_icon_width
    },
    {
      "team",
      "team_set_sign_7",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[7],
      TEAM_SIGN_ICON_SIZE[7],
      team_icon_width
    },
    {
      "team",
      "team_set_sign_8",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[8],
      TEAM_SIGN_ICON_SIZE[8],
      team_icon_width
    },
    {
      "team",
      "team_set_sign_0",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[0],
      TEAM_SIGN_ICON_SIZE[0],
      team_icon_width
    }
  }
  selectobj_sign_data = {
    {
      "player",
      "selectobj_set_sign_1",
      "  ",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[1],
      TEAM_SIGN_ICON_SIZE[1]
    },
    {
      "player",
      "selectobj_set_sign_2",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[2],
      TEAM_SIGN_ICON_SIZE[2]
    },
    {
      "player",
      "selectobj_set_sign_3",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[3],
      TEAM_SIGN_ICON_SIZE[3]
    },
    {
      "player",
      "selectobj_set_sign_4",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[4],
      TEAM_SIGN_ICON_SIZE[4]
    },
    {
      "player",
      "selectobj_set_sign_5",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[5],
      TEAM_SIGN_ICON_SIZE[5]
    },
    {
      "player",
      "selectobj_set_sign_6",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[6],
      TEAM_SIGN_ICON_SIZE[6]
    },
    {
      "player",
      "selectobj_set_sign_7",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[7],
      TEAM_SIGN_ICON_SIZE[7]
    },
    {
      "player",
      "selectobj_set_sign_8",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[8],
      TEAM_SIGN_ICON_SIZE[8]
    },
    {
      "player",
      "selectobj_set_sign_0",
      "",
      nil,
      nil,
      nil,
      TEAM_SIGN_ICON[0],
      TEAM_SIGN_ICON_SIZE[0]
    }
  }
  love_action_menu_data = {
    {
      "love",
      "action_yiwei",
      tip_weiyi,
      nil,
      nil,
      nil
    },
    {
      "love",
      "action_shame",
      tip_haixiu,
      nil,
      nil,
      nil
    },
    {
      "love",
      "action_inarm",
      tip_baoqi,
      nil,
      nil,
      nil
    }
  }
  life_job_share_menu_data = {
    {
      "share",
      "sh_tj",
      "sh_tj",
      nil,
      "sh_tj_share_menu",
      nil
    },
    {
      "share",
      "sh_ds",
      "sh_ds",
      nil,
      "sh_ds_share_menu",
      nil
    },
    {
      "share",
      "sh_ys",
      "sh_ys",
      nil,
      "sh_ys_share_menu",
      nil
    },
    {
      "share",
      "sh_cf",
      "sh_cf",
      nil,
      "sh_cf_share_menu",
      nil
    },
    {
      "share",
      "sh_cs",
      "sh_cs",
      nil,
      "sh_cs_share_menu",
      nil
    },
    {
      "share",
      "sh_jq",
      "sh_jq",
      nil,
      "sh_jq_share_menu",
      nil
    },
    {
      "share",
      "sh_gs",
      "sh_gs",
      nil,
      "sh_gs_share_menu",
      nil
    },
    {
      "share",
      "sh_ss",
      "sh_ss",
      nil,
      "sh_ss_share_menu",
      nil
    },
    {
      "share",
      "sh_hs",
      "sh_hs",
      nil,
      "sh_hs_share_menu",
      nil
    }
  }
  offline_fee_sub_menu_data = {
    {
      "player",
      "fee_sub_level_1",
      "desc_interact_number_1",
      nil,
      "fee_sub_level_1_menu",
      nil
    },
    {
      "player",
      "fee_sub_level_2",
      "desc_interact_number_2",
      nil,
      "fee_sub_level_2_menu",
      nil
    },
    {
      "player",
      "fee_sub_level_3",
      "desc_interact_number_3",
      nil,
      "fee_sub_level_3_menu",
      nil
    },
    {
      "player",
      "fee_sub_level_4",
      "desc_interact_number_4",
      nil,
      "fee_sub_level_4_menu",
      nil
    },
    {
      "player",
      "fee_sub_level_5",
      "desc_interact_number_5",
      nil,
      "fee_sub_level_5_menu",
      nil
    },
    {
      "player",
      "fee_sub_level_6",
      "desc_interact_number_6",
      nil,
      "fee_sub_level_6_menu",
      nil
    },
    {
      "player",
      "fee_sub_level_7",
      "desc_interact_number_7",
      nil,
      "fee_sub_level_7_menu",
      nil
    },
    {
      "player",
      "fee_sub_level_8",
      "desc_interact_number_8",
      nil,
      "fee_sub_level_8_menu",
      nil
    },
    {
      "player",
      "fee_sub_level_9",
      "desc_interact_number_9",
      nil,
      "fee_sub_level_9_menu",
      nil
    }
  }
  local tip_putong = util_text("ui_PuTong")
  local tip_jiaohu = util_text("ui_JiaoHu")
  local tip_lianai = util_text("ui_LianAi")
  action_menu_data = {
    {
      "action",
      "action_nomal",
      tip_putong,
      nil,
      nil,
      nil
    },
    {
      "action",
      "action_chat",
      tip_jiaohu,
      nil,
      nil,
      nil
    },
    {
      "action",
      "action_love",
      tip_lianai,
      love_action_menu_data,
      nil,
      nil,
      nil
    }
  }
  func_npc_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      "func_npc_copy_name"
    },
    {
      "player",
      "player_jiaohu",
      "ui_menu_jiaohu",
      nil,
      nil,
      nil
    },
    {
      "player",
      "npc_friend_add",
      "ui_npc_friend_add",
      nil,
      "npc_friend_add_menu",
      nil
    },
    {
      "player",
      "npc_buddy_add",
      "ui_npc_buddy_add",
      nil,
      "npc_buddy_add_menu",
      nil
    },
    {
      "player",
      "npc_relation_cut",
      "ui_npc_relation_cut",
      nil,
      "npc_relation_cut_menu",
      nil
    },
    {
      "player",
      "npc_attention_add",
      "ui_npc_attention_add",
      nil,
      "npc_attention_add_menu",
      nil
    },
    {
      "player",
      "npc_attention_remove",
      "ui_npc_attention_del",
      nil,
      "npc_attention_remove_menu",
      nil
    },
    {
      "player",
      "present_to_npc",
      "ui_present_to_npc_item",
      nil,
      "npc_gift_add_menu",
      nil
    },
    {
      "player",
      "query_good_feeling",
      "ui_query_good_feeling",
      nil,
      "npc_good_feeling_add_menu",
      nil
    },
    {
      "player",
      "cure_the_hero_npc",
      "ui_cure_the_hero_npc",
      nil,
      "cure_hero_npc_add_menu",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  func_npc_menu_data_without_look = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      "func_npc_copy_name"
    },
    {
      "player",
      "player_jiaohu",
      "ui_menu_jiaohu",
      nil,
      nil,
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  attk_npc_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_jiaohu",
      "ui_menu_jiaohu",
      nil,
      nil,
      nil
    },
    {
      "player",
      "set_sign",
      "ui_menu_setsign",
      selectobj_sign_data,
      "team_set_sign",
      "team_set_sign"
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  attk_npc_menu_data_without_look = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_jiaohu",
      "ui_menu_jiaohu",
      nil,
      nil,
      nil
    },
    {
      "player",
      "set_sign",
      "ui_menu_setsign",
      selectobj_sign_data,
      "team_set_sign",
      "team_set_sign"
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  other_npc_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      "func_npc_copy_name"
    },
    {
      "player",
      "player_jiaohu",
      "ui_menu_jiaohu",
      nil,
      nil,
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  cansign_npc_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      "func_npc_copy_name"
    },
    {
      "player",
      "player_jiaohu",
      "ui_menu_jiaohu",
      nil,
      nil,
      nil
    },
    {
      "player",
      "set_sign",
      "ui_menu_setsign",
      selectobj_sign_data,
      "team_set_sign",
      "team_set_sign"
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  pet_npc_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      "func_npc_copy_name"
    },
    {
      "player",
      "pet_gone",
      "ui_dis",
      nil,
      "pet_gone_menu",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  normal_pet_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      "func_npc_copy_name"
    },
    {
      "player",
      "open_depot",
      "inter_mn_furn_type_depot",
      nil,
      "open_depot_menu",
      nil
    },
    {
      "player",
      "dismiss_normalpet",
      "ui_dis",
      nil,
      "dismiss_normalpet_menu",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  home_npc_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      "func_npc_copy_name"
    },
    {
      "player",
      "home_move",
      "ui_home_move",
      nil,
      "home_move",
      nil
    },
    {
      "player",
      "home_back",
      "ui_home_back",
      nil,
      "home_back",
      nil
    },
    {
      "player",
      "home_del",
      "ui_home_del",
      nil,
      "home_del",
      nil
    },
    {
      "player",
      "home_turn_round",
      "ui_home_turn_round",
      nil,
      "home_turn_round",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  home_npc_npc_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      "func_npc_copy_name"
    },
    {
      "player",
      "home_move",
      "ui_home_move",
      nil,
      nil,
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  trans_npc_menu_data = {
    {
      "player",
      "player_finish_bus",
      "ui_menu_finishbus",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_jiaohu",
      "ui_menu_jiaohu",
      nil,
      nil,
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  sweet_employ_npc_menu_data = {
    {
      "player",
      "sweet_pet_js",
      "ui_dismiss_pet",
      nil,
      "sweet_pet_js_menu",
      nil
    },
    {
      "player",
      "sweet_pet_use_tl",
      "ui_sweet_pet_tl",
      nil,
      "sweet_pet_js_menu",
      nil
    },
    {
      "player",
      "sweet_pet_use_ng",
      "ui_sweet_pet_ng",
      nil,
      "sweet_pet_js_menu",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  select_player_menu_data = {
    {
      "player",
      "cure_relive",
      "ui_help_relive",
      nil,
      "cure_relive",
      nil
    },
    {
      "player",
      "player_exchange",
      "ui_playerlink_jiaoyi",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_send_mail",
      "ui_mail_fasong",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_challenge",
      "ui_playerlink_juedou",
      nil,
      "player_challenge",
      "player_challenge"
    },
    {
      "player",
      "follow_others",
      "ui_menu_follow",
      nil,
      nil,
      nil
    },
    {
      "player",
      "request_multiride",
      "ui_multi_ride",
      nil,
      "multi_ride_menu",
      nil
    },
    {
      "player",
      "player_rank_challenge",
      "ui_playerlink_juedou_rank",
      nil,
      "player_rank_challenge",
      nil
    },
    {
      "player",
      "life_job_share",
      "ui_life_job_share",
      life_job_share_menu_data,
      "life_job_share_menu",
      nil
    },
    {
      "player",
      "life_wqgame",
      "ui_life_wqgame",
      nil,
      "life_wqgame",
      nil
    },
    {
      "player",
      "player_request_gemfight",
      "ui_wj_fight",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_friend_request",
      "ui_playerlink_jiaweihaoyou",
      nil,
      nil,
      "friend_request"
    },
    {
      "player",
      "player_attention_request",
      "ui_menu_friend_jiawei_attention",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_filter_request",
      "ui_menu_friend_jiawei_filter",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_filter_native_request",
      "ui_add_filter_native",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_team_join",
      "ui_playerlink_shenqingzudui",
      nil,
      nil,
      "select_team_jion"
    },
    {
      "player",
      "player_team_request",
      "ui_playerlink_yaoqingzudui",
      nil,
      nil,
      "select_team_request"
    },
    {
      "player",
      "team_change_leader0",
      "ui_team_captain_change",
      nil,
      nil,
      "team_team_change_leader"
    },
    {
      "player",
      "team_realse_work0",
      "ui_team_realse_work",
      nil,
      "team_realse_work",
      "team_realse_work"
    },
    {
      "player",
      "team_kick0",
      "ui_team_kickout",
      nil,
      nil,
      "team_team_kick"
    },
    {
      "player",
      "set_sign",
      "ui_menu_setsign",
      selectobj_sign_data,
      "team_set_sign_1",
      "team_set_sign_1"
    },
    {
      "player",
      "offline_setfree",
      "off_setfree",
      nil,
      "offline_setfree_menu",
      nil
    },
    {
      "player",
      "arrest_accuse",
      "ui_arrest_accuse",
      nil,
      "arrest_accuse_menu",
      nil
    },
    {
      "player",
      "join_faculty",
      "ui_join_faculty",
      nil,
      "join_faculty_menu",
      nil
    },
    {
      "player",
      "copy_name",
      "ui_playerlink_fuzhinicheng",
      nil,
      nil,
      nil
    },
    {
      "player",
      "invite_respond",
      "ui_invite_respond",
      nil,
      "invite_respond_menu",
      nil
    },
    {
      "player",
      "join_guild",
      "ui_guild_join",
      nil,
      "join_guild_menu",
      nil
    },
    {
      "player",
      "player_look",
      "ui_playerlink_chakanzhuangbei",
      nil,
      nil,
      nil
    },
    {
      "player",
      "binglu_look",
      "ui_chakan_binglu",
      nil,
      nil,
      nil
    },
    {
      "player",
      "tvt_look",
      "ui_menu_tvt",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_game_info_look",
      "ui_playerlink_chakanxinxi",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_target_secret_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      nil
    },
    {
      "player",
      "invite_member",
      "ui_guild_invite",
      nil,
      "invite_member_menu",
      nil
    },
    {
      "player",
      "respond_guild",
      "ui_guild_respond",
      nil,
      "respond_guild_menu",
      nil
    },
    {
      "player",
      "set_zhenyan",
      "ui_set_zhenyan",
      nil,
      "set_zhenyan",
      nil
    },
    {
      "player",
      "pupil_baishi",
      "ui_menu_baishi",
      nil,
      "pupil_baishi",
      nil
    },
    {
      "player",
      "shou_tu",
      "ui_menu_shoutu",
      nil,
      "shou_tu",
      nil
    },
    {
      "player",
      "schoolfight_kick",
      "ui_schoolfight_kick",
      nil,
      "schoolfight_kick",
      nil
    },
    {
      "player",
      "schoolfight_report",
      "ui_schoolfight_report",
      nil,
      "schoolfight_report",
      nil
    },
    {
      "player",
      "make_item",
      "ui_make_item",
      nil,
      "make_item",
      nil
    },
    {
      "player",
      "player_report_ad",
      "ui_player_report_ad",
      nil,
      "player_report_ad",
      nil
    },
    {
      "player",
      "invite_guild_war",
      "ui_invite_guild_war",
      nil,
      "invite_guild_war",
      nil
    },
    {
      "player",
      "ssg_yjp_qqss",
      "ui_ssg_yjp_qqss",
      nil,
      "ssg_yjp",
      nil
    }
  }
  select_offline_player_menu_data = {
    {
      "player",
      "offline_accost",
      "ui_offline_accost",
      nil,
      "offline_accost_menu",
      nil
    },
    {
      "player",
      "player_look",
      "ui_playerlink_chakanzhuangbei",
      nil,
      nil,
      nil
    },
    {
      "player",
      "copy_name",
      "ui_playerlink_fuzhinicheng",
      nil,
      nil,
      nil
    },
    {
      "player",
      "offline_abduct",
      "off_abduct",
      nil,
      "offline_abduct_menu",
      nil
    },
    {
      "player",
      "offline_setfree",
      "off_setfree",
      nil,
      "offline_setfree_menu",
      nil
    },
    {
      "player",
      "life_job_share",
      "ui_life_job_share",
      life_job_share_menu_data,
      "offline_life_job_share_menu",
      nil
    },
    {
      "player",
      "interact_type_1",
      "desc_type_1",
      offline_fee_sub_menu_data,
      "interact_menu_type_1",
      nil
    },
    {
      "player",
      "interact_type_2",
      "desc_type_2",
      offline_fee_sub_menu_data,
      "interact_menu_type_2",
      nil
    },
    {
      "player",
      "interact_type_3",
      "desc_type_3",
      offline_fee_sub_menu_data,
      "interact_menu_type_3",
      nil
    },
    {
      "player",
      "interact_type_4",
      "desc_type_4",
      offline_fee_sub_menu_data,
      "interact_menu_type_4",
      nil
    },
    {
      "player",
      "interact_type_5",
      "desc_type_5",
      offline_fee_sub_menu_data,
      "interact_menu_type_5",
      nil
    },
    {
      "player",
      "off_tvt_stun",
      "ui_off_tvt_stun",
      nil,
      "off_tvt_stun_menu",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  select_taosha_player_menu_data = {
    {
      "player",
      "player_look",
      "ui_playerlink_chakanzhuangbei",
      nil,
      nil,
      nil
    }
  }
  select_sns_blog_name = {
    {
      "player",
      "sns_blog_player_info",
      "ui_menu_look",
      nil,
      nil,
      nil
    },
    {
      "player",
      "sns_blog_player_find",
      "ui_sns_search",
      nil,
      nil,
      nil
    }
  }
  select_npc_karma_list = {
    {
      "player",
      "npc_present_far",
      "ui_present_to_npc_item",
      nil,
      "far_give_npc_gift_menu",
      nil
    },
    {
      "player",
      "query_good_feeling_far",
      "ui_query_good_feeling",
      nil,
      "far_npc_good_feeling_add_menu",
      nil
    },
    {
      "player",
      "npc_avenge_serve",
      "ui_mafan_title",
      nil,
      "far_npc_avenge_serve_menu",
      nil
    },
    {
      "player",
      "npc_friend_add_far",
      "ui_npc_friend_add",
      nil,
      "far_add_npc_friend_menu",
      nil
    },
    {
      "player",
      "npc_buddy_add_far",
      "ui_npc_buddy_add",
      nil,
      "far_add_npc_buddy_menu",
      nil
    },
    {
      "player",
      "npc_relation_cut_far",
      "ui_npc_relation_cut",
      nil,
      "far_cut_npc_relation_menu",
      nil
    },
    {
      "player",
      "npc_attention_add_far",
      "ui_npc_attention_add",
      nil,
      "far_add_npc_attention_menu",
      nil
    },
    {
      "player",
      "npc_attention_remove_far",
      "ui_npc_attention_del",
      nil,
      "far_remove_npc_attention_menu",
      nil
    },
    {
      "player",
      "npc_relation_refresh_far",
      "ui_npc_relation_refresh",
      nil,
      nil,
      nil
    },
    {
      "player",
      "npc_info_far",
      "ui_npc_info_show",
      nil,
      "far_look_npc_info_menu",
      nil
    }
  }
  select_npc_karma_delay = {
    {
      "player",
      "karma_delay_add",
      "ui_karma_delay_add",
      nil,
      nil,
      nil
    },
    {
      "player",
      "karma_delay_remove",
      "ui_karma_delay_remove",
      nil,
      nil,
      nil
    }
  }
  select_offline_log_name = {
    {
      "player",
      "offline_player_secret_chat",
      "ui_menu_secret_chat",
      nil,
      nil,
      nil
    },
    {
      "player",
      "offline_player_send_mail",
      "ui_chuanshu",
      nil,
      nil,
      nil
    }
  }
  team_allocate_mode_data = {
    {
      "team",
      "team_alloc_free",
      "ui_menu_free_alloc",
      nil,
      nil,
      "team_alloc_free"
    },
    {
      "team",
      "team_alloc_turn",
      "ui_menu_turn_alloc",
      nil,
      nil,
      "team_alloc_turn"
    },
    {
      "team",
      "team_alloc_team",
      "ui_menu_team_alloc",
      nil,
      nil,
      "team_alloc_team"
    },
    {
      "team",
      "team_alloc_leader",
      "ui_menu_leader_alloc",
      nil,
      nil,
      "team_alloc_leader"
    },
    {
      "team",
      "team_alloc_compete",
      "ui_menu_compete_alloc",
      nil,
      nil,
      "team_alloc_compete"
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  team_quality_need_data = {
    {
      "team",
      "team_quality_1",
      "ui_menu_quality_1",
      nil,
      nil,
      "team_quality_1"
    },
    {
      "team",
      "team_quality_2",
      "ui_menu_quality_2",
      nil,
      nil,
      "team_quality_2"
    },
    {
      "team",
      "team_quality_3",
      "ui_menu_quality_3",
      nil,
      nil,
      "team_quality_3"
    },
    {
      "team",
      "team_quality_4",
      "ui_menu_quality_4",
      nil,
      nil,
      "team_quality_4"
    },
    {
      "team",
      "team_quality_5",
      "ui_menu_quality_5",
      nil,
      nil,
      "team_quality_5"
    },
    {
      "team",
      "team_quality_6",
      "ui_menu_quality_6",
      nil,
      nil,
      "team_quality_6"
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  leitai_mode_menu_data = {
    {
      "leitai",
      "create_leitai_common",
      "ui_leitai_common",
      nil,
      nil,
      nil
    },
    {
      "leitai",
      "create_leitai_random",
      "ui_leitai_random",
      nil,
      nil,
      nil
    },
    {
      "leitai",
      "create_leitai_wudou",
      "ui_leitai_wudou",
      nil,
      "create_wudou",
      nil
    }
  }
  select_role_menu_data = {
    {
      "player",
      "copy_name",
      "ui_menu_copyname",
      nil,
      nil,
      nil
    },
    {
      "team",
      "create_team",
      "ui_menu_create_team",
      nil,
      "role_create_team",
      nil
    },
    {
      "team",
      "team_allocate",
      "ui_menu_team_allocate",
      team_allocate_mode_data,
      "role_team_allocate",
      nil
    },
    {
      "team",
      "team_quality",
      "ui_menu_team_quality",
      team_quality_need_data,
      "role_team_quality",
      nil
    },
    {
      "team",
      "team_leave",
      "ui_menu_team_leave",
      nil,
      "role_team_leave",
      nil
    },
    {
      "team",
      "team_disband",
      "ui_team_disband",
      nil,
      "role_team_disband",
      nil
    },
    {
      "player",
      "set_sign_form",
      "ui_menu_setsign",
      player_sign_data,
      "team_set_sign_1",
      "team_set_sign_1"
    },
    {
      "leitai",
      "create_leitai",
      "ui_leitaijijing",
      leitai_mode_menu_data,
      "create_leitai",
      nil
    },
    {
      "player",
      "sweet_pet_cz",
      "ui_summon_pet",
      nil,
      "sweet_pet_cz_menu",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  friend_menu_data = {
    {
      "player",
      "player_team_request",
      "ui_playerlink_yaoqingzudui",
      nil,
      nil,
      "select_team_request"
    },
    {
      "player",
      "player_sns_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_team_request2",
      "ui_menu_team_request",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_add_blacklist2",
      "ui_menu_addto_blacklist",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_send_msg",
      "ui_chuanshu",
      nil,
      nil,
      nil
    }
  }
  team_menu_data = {
    {
      "player",
      "player_exchange1",
      "ui_playerlink_jiaoyi",
      nil,
      nil,
      "is_me"
    },
    {
      "player",
      "player_team_send_mail",
      "ui_mail_fasong",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_sns_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      "is_me"
    },
    {
      "player",
      "player_friend_request2",
      "ui_menu_friend_request",
      nil,
      nil,
      "is_me"
    },
    {
      "team",
      "team_change_leader",
      "ui_team_captain_change",
      nil,
      "team_team_change_leader",
      "is_me"
    },
    {
      "team",
      "team_realse_work",
      "ui_team_realse_work",
      nil,
      "team_realse_work",
      "team_realse_work"
    },
    {
      "team",
      "team_kick",
      "ui_team_kickout",
      nil,
      "team_team_kick",
      "is_me"
    },
    {
      "team",
      "battlefield_kick",
      "ui_battlefield_kickout",
      nil,
      "team_battlefield_kick",
      "is_me"
    },
    {
      "player",
      "copy_name1",
      "ui_menu_copyname",
      nil,
      nil,
      nil
    },
    {
      "team",
      "set_sign_form",
      "ui_menu_setsign",
      team_sign_data,
      "team_set_sign_1",
      "team_set_sign_1"
    },
    {
      "player",
      "player_game_info_look",
      "ui_playerlink_chakanxinxi",
      nil,
      nil,
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  chat_menu_data = {}
  select_player_in_recruit = {
    {
      "player",
      "player_friend_request1",
      "ui_menu_friend_request",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_attention_request1",
      "ui_menu_friend_jiawei_attention",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_filter_request1",
      "ui_menu_friend_jiawei_filter",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_team_request1",
      "ui_menu_team_request",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_secret_chat_recruit",
      "ui_menu_secret_chat",
      nil,
      nil,
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  chat_sender_menu_data = {
    {
      "player",
      "player_sns_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_friend_request2",
      "ui_menu_friend_request",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_attention_request2",
      "ui_menu_friend_jiawei_attention",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_filter_request2",
      "ui_menu_friend_jiawei_filter",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_add_blacklist2",
      "ui_menu_addto_blacklist",
      nil,
      nil,
      nil
    }
  }
  rank_menu_data = {
    {
      "player",
      "player_sns_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_friend_request2",
      "ui_menu_friend_request",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_attention_request2",
      "ui_menu_friend_jiawei_attention",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_filter_request2",
      "ui_menu_friend_jiawei_filter",
      nil,
      nil,
      nil
    },
    {
      "player",
      "copy_name1",
      "ui_menu_copyname",
      nil,
      nil,
      nil
    }
  }
  activity_prize_rank_menu_data = {
    {
      "player",
      "player_sns_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_friend_request2",
      "ui_menu_friend_request",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_attention_request2",
      "ui_menu_friend_jiawei_attention",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_filter_request2",
      "ui_menu_friend_jiawei_filter",
      nil,
      nil,
      nil
    },
    {
      "player",
      "copy_name1",
      "ui_menu_copyname",
      nil,
      nil,
      nil
    }
  }
  market_menu_data = {
    {
      "player",
      "player_sns_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_friend_request2",
      "ui_menu_friend_request",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_attention_request2",
      "ui_menu_friend_jiawei_attention",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_filter_request2",
      "ui_menu_friend_jiawei_filter",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_team_request3",
      "ui_menu_team_request",
      nil,
      nil,
      nil
    },
    {
      "player",
      "player_game_info_look",
      "ui_playerlink_chakanxinxi",
      nil,
      nil,
      nil
    },
    {
      "player",
      "copy_name1",
      "ui_menu_copyname",
      nil,
      nil,
      nil
    }
  }
  scenario_add_data = {
    {
      "scenario",
      "scenario_npc",
      "NPC",
      nil,
      nil,
      nil
    },
    {
      "scenario",
      "scenario_camera",
      "\201\227\207\241\187\250",
      nil,
      nil,
      nil
    },
    {
      "scenario",
      "scenario_player",
      "\205\230\188\210",
      nil,
      nil,
      nil
    },
    {
      "scenario",
      "scenario_effect",
      "\204\216\208\167",
      nil,
      nil,
      nil
    },
    {
      "scenario",
      "scenario_fade",
      "\181\173\200\235\181\173\179\246",
      nil,
      nil,
      nil
    },
    {
      "scenario",
      "scenario_ppdof",
      "\190\176\201\238",
      nil,
      nil,
      nil
    },
    {
      "scenario",
      "scenario_team",
      "\215\233\182\211\182\211\212\177",
      nil,
      nil,
      nil
    },
    {
      "scenario",
      "scenario_movietalk",
      "\181\231\211\176\182\212\176\215",
      nil,
      nil,
      nil
    }
  }
  scenario_menu_data = {
    {
      "scenario",
      "scenario_delete",
      "\201\190\179\253",
      nil,
      nil,
      nil
    },
    {
      "scenario",
      "scenario_add",
      "\204\237\188\211",
      scenario_add_data,
      nil,
      nil
    }
  }
  tiny_team_info_menu_data = {
    {
      "tiny_team_info",
      "tiny_team_info_close",
      "ui_menu_tiny_info_close",
      nil,
      nil,
      nil
    },
    {
      "tiny_team_info",
      "tiny_team_info_showgoodbuffer",
      "ui_menu_tiny_info_showgood",
      nil,
      nil,
      nil
    },
    {
      "tiny_team_info",
      "tiny_team_info_showbadbuffer",
      "ui_menu_tiny_info_showbad",
      nil,
      nil,
      nil
    },
    {
      "tiny_team_info",
      "tiny_team_info_hidebuffer",
      "ui_menu_tiny_info_hide",
      nil,
      nil,
      nil
    }
  }
  tiny_single_info_menu_data = {
    {
      "tiny_single_info",
      "tiny_single_info_close",
      "ui_menu_tiny_info_close",
      nil,
      nil,
      nil
    },
    {
      "tiny_single_info",
      "tiny_single_info_showgoodbuffer",
      "ui_menu_tiny_info_showgood",
      nil,
      nil,
      nil
    },
    {
      "tiny_single_info",
      "tiny_single_info_showbadbuffer",
      "ui_menu_tiny_info_showbad",
      nil,
      nil,
      nil
    },
    {
      "tiny_single_info",
      "tiny_single_info_hidebuffer",
      "ui_menu_tiny_info_hide",
      nil,
      nil,
      nil
    }
  }
  chat_panel_menu_data = {
    {
      "chat_panel",
      "chat_panel_secret_chat",
      "ui_sns_chat_top_title",
      nil,
      "chat_panel_secret_chat",
      nil
    },
    {
      "chat_panel",
      "chat_panel_request_team",
      "ui_playerlink_yaoqingzudui",
      nil,
      "chat_panel_request_team",
      nil
    },
    {
      "chat_panel",
      "chat_panel_send_mail",
      "ui_mail_fasong",
      nil,
      "chat_panel_send_mail",
      nil
    },
    {
      "chat_panel",
      "chat_panel_invite_member",
      "ui_guild_invite",
      nil,
      "chat_panel_invite_member",
      nil
    },
    {
      "chat_panel",
      "chat_panel_summon_player",
      "ui_menu_seekhelp",
      nil,
      "chat_panel_summon_player",
      nil
    },
    {
      "chat_panel",
      "chat_panel_invite_player",
      "ui_menu_invite_player",
      nil,
      "chat_panel_invite_player",
      nil
    },
    {
      "chat_panel",
      "chat_panel_sanhill_invite",
      "ui_menu_sanhill_invite",
      nil,
      "chat_panel_sanhill_invite",
      nil
    },
    {
      "chat_panel",
      "chat_panel_update_zhiyou",
      "ui_menu_friend_update_zhiyou",
      nil,
      "chat_panel_update_zhiyou",
      nil
    },
    {
      "chat_panel",
      "chat_panel_delete_friend",
      "ui_menu_friend_delete_haoyou",
      nil,
      "chat_panel_delete_friend",
      nil
    },
    {
      "chat_panel",
      "chat_panel_down_haoyou",
      "ui_menu_friend_down_haoyou",
      nil,
      "chat_panel_down_haoyou",
      nil
    },
    {
      "chat_panel",
      "chat_panel_delete_buddy",
      "ui_menu_friend_delete_zhiyou",
      nil,
      "chat_panel_delete_buddy",
      nil
    },
    {
      "chat_panel",
      "chat_panel_update_xuechou",
      "ui_menu_friend_update_xuechou",
      nil,
      "chat_panel_update_xuechou",
      nil
    },
    {
      "chat_panel",
      "chat_panel_delete_enemy",
      "ui_menu_friend_delete_chouren",
      nil,
      "chat_panel_delete_enemy",
      nil
    },
    {
      "chat_panel",
      "chat_panel_down_choujia",
      "ui_menu_friend_down_chouren",
      nil,
      "chat_panel_down_choujia",
      nil
    },
    {
      "chat_panel",
      "chat_panel_delete_blood",
      "ui_menu_friend_delete_xuechou",
      nil,
      "chat_panel_delete_blood",
      nil
    },
    {
      "chat_panel",
      "chat_panel_add_friend",
      "ui_playerlink_jiaweihaoyou",
      nil,
      "chat_panel_add_friend",
      nil
    },
    {
      "chat_panel",
      "chat_panel_delete_attention",
      "ui_menu_friend_delete_attention",
      nil,
      "chat_panel_delete_attention",
      nil
    },
    {
      "chat_panel",
      "chat_panel_delete_acquaint",
      "ui_menu_friend_delete_acquaint",
      nil,
      "chat_panel_delete_acquaint",
      nil
    },
    {
      "chat_panel",
      "chat_panel_jiawei_filter",
      "ui_menu_friend_jiawei_filter",
      nil,
      "chat_panel_jiawei_filter",
      nil
    },
    {
      "chat_panel",
      "chat_panel_delete_filter",
      "ui_menu_friend_delete_filter",
      nil,
      "chat_panel_delete_filter",
      nil
    },
    {
      "chat_panel",
      "chat_panel_delete_filter_native",
      "ui_delete_filter_native",
      nil,
      "chat_panel_delete_filter_native",
      nil
    },
    {
      "chat_panel",
      "chat_panel_game_info_look",
      "ui_playerlink_chakanxinxi",
      nil,
      "chat_panel_game_info_look",
      nil
    },
    {
      "chat_panel",
      "chat_panel_teacher_invite",
      "ui_menu_teacher_invite",
      nil,
      "chat_panel_teacher_invite",
      nil
    },
    {
      "chat_panel",
      "chat_panel_home_game_invite",
      "ui_jy_fszh_02",
      nil,
      "chat_panel_home_game_invite",
      nil
    },
    {
      "chat_panel",
      "chat_panel_rtm_invite",
      "ui_menu_rtm_invite",
      nil,
      "chat_panel_rtm_invite",
      nil
    }
  }
  chat_group_menu_data = {
    {
      "chat_group",
      "chat_panel_secret_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      nil
    },
    {
      "chat_group",
      "chat_panel_request_team",
      "ui_playerlink_yaoqingzudui",
      nil,
      "chat_group_request_team",
      nil
    },
    {
      "chat_group",
      "chat_panel_send_mail",
      "ui_mail_fasong",
      nil,
      nil,
      nil
    }
  }
  member_groupchat_menu_data = {
    {
      "member_groupchat",
      "member_groupchat_secret_chat",
      "ui_sns_chat_top_title",
      nil,
      nil,
      nil
    },
    {
      "member_groupchat",
      "member_groupchat_game_info_look",
      "ui_playerlink_chakanxinxi",
      nil,
      nil,
      nil
    },
    {
      "member_groupchat",
      "member_groupchat_quit",
      "ui_groupchat_quit",
      nil,
      "member_groupchat_quit",
      nil
    },
    {
      "member_groupchat",
      "member_groupchat_del_member",
      "ui_groupchat_del_member",
      nil,
      "member_groupchat_del_member",
      nil
    },
    {
      "member_groupchat",
      "member_groupchat_del_group",
      "ui_groupchat_del_group",
      nil,
      "member_groupchat_del_group",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  groupchat_menu_data = {
    {
      "groupchat",
      "groupchat_quit",
      "ui_groupchat_quit",
      nil,
      "groupchat_quit",
      nil
    },
    {
      "groupchat",
      "groupchat_del_group",
      "ui_groupchat_del_group",
      nil,
      "groupchat_del_group",
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  schoolfight_rank_menu_data = {
    {
      "player",
      "schoolfight_rank_kick",
      "ui_rank_kick",
      nil,
      "schoolfight_rank_kick",
      nil
    }
  }
  city_kapai_trace_menu_data = {
    {
      "player",
      "open_kapai",
      "ui_open_kapai",
      nil,
      nil,
      nil
    },
    {
      "menu",
      "close",
      "ui_g_close",
      nil,
      nil,
      nil
    }
  }
  home_neighbor = {
    {
      "home",
      "visit_home",
      "tips_home_1",
      nil,
      "visit_home",
      nil
    },
    {
      "home",
      "sale_home",
      "tips_home_2",
      nil,
      "sale_home",
      nil
    },
    {
      "home",
      "delete_friend",
      "tips_home_4",
      nil,
      nil,
      nil
    }
  }
  home_resident = {
    {
      "home",
      "add_friend",
      "tips_home_3",
      nil,
      nil,
      nil
    },
    {
      "home",
      "sale_home",
      "tips_home_2",
      nil,
      "sale_home",
      nil
    },
    {
      "home",
      "goto_home",
      "tips_home_6",
      nil,
      nil,
      nil
    }
  }
  home_employee = {
    {
      "home",
      "home_fire",
      "ui_home_fire",
      nil,
      nil,
      nil
    },
    {
      "home",
      "home_setca",
      "ui_home_setca",
      nil,
      "home_setca",
      nil
    },
    {
      "home",
      "home_equip_exchange",
      "inter_furn_type6_1",
      nil,
      "home_equip_exchange",
      nil
    },
    {
      "home",
      "home_equip_split",
      "inter_furn_type6_2",
      nil,
      "home_equip_split",
      nil
    }
  }
  home_visit_friend = {
    {
      "home",
      "delete_visit_friend",
      "tips_home_4",
      nil,
      nil,
      nil
    }
  }
  chat_hlink_menu_data = {
    {
      "chat_hlink",
      "chit_report_ad",
      "ui_player_report_ad",
      nil,
      "chit_report_ad",
      nil
    }
  }
  follow_sable_list = {
    {
      "player",
      "follow_others",
      "ui_menu_follow",
      nil,
      nil,
      nil
    }
  }
  chat_item = {
    {
      "chat_item",
      "open_auction",
      "tips_chat_item_1",
      nil,
      nil,
      "chat_auction"
    },
    {
      "chat_item",
      "open_market",
      "tips_chat_item_2",
      nil,
      nil,
      nil
    }
  }
end
LastMenuType = nil
LastMenuTarget = nil
function menu_game_reset(menutype, target)
  LastMenuType = menutype
  LastMenuTarget = target
  local menu_game = nx_value("menu_game")
  if nx_is_valid(menu_game) then
    menu_game.type = menutype
  end
end
function menu_game_init(menu)
  init_menu_data()
  local gui = nx_value("gui")
  menu.BackImage = "gui\\common\\form_back\\bg_menu.png"
  menu.DrawMode = "Expand"
  menu.ItemHeight = 20
  menu.LeftBar = false
  menu.LeftBarWidth = 20
  menu.Width = 140
  menu.Font = "Default"
  menu.ForeColor = "255,225,204,20"
  menu.SelectBackColor = "255,160,36,18"
  menu.SelectBorderColor = "255,0,0,0"
  return 1
end
function menu_recompose(menu, userdata)
  menu:DeleteAllItem()
  local menu_data
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
  end
  if LastMenuTarget == "role" then
    local role_name = game_role:QueryProp("Name")
    menu_data = select_role_menu_data
    local root_menu = menu
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, game_role)
  elseif LastMenuTarget == "selectobj" then
    local select_target_ident = game_role:QueryProp("LastObject")
    local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
    if not nx_is_valid(select_target) then
      return
    end
    local target_type = select_target:QueryProp("Type")
    if target_type == TYPE_PLAYER then
      if nx_execute("form_stage_main\\form_offline\\offline_util", "is_offline", select_target) then
        menu_data = select_offline_player_menu_data
      elseif nx_execute("form_stage_main\\form_match\\form_banxuan_taolu", "is_match_revenge", select_target) then
        return
      elseif nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene") then
        return
      elseif nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene") then
        return
      elseif nx_execute("form_stage_main\\form_night_forever\\form_fin_main", "is_in_flee_in_night") then
        return
      else
        menu_data = select_player_menu_data
      end
    elseif target_type == TYPE_NPC then
      local npc_info_ini = nx_execute("util_functions", "get_ini", "ini\\ClientNpcInfo\\Client_Npc_Info.ini")
      if not nx_is_valid(npc_info_ini) then
        return
      end
      local client_kind_npc = 0
      if select_target:FindProp("CKindID") then
        client_kind_npc = select_target:QueryProp("CKindID")
      end
      local npc_type = select_target:QueryProp("NpcType")
      if npc_type == 0 then
        if tonumber(client_kind_npc) > 2 then
          menu_data = attk_npc_menu_data_without_look
        else
          menu_data = attk_npc_menu_data
          if tonumber(client_kind_npc) ~= 0 then
            menu_data[2][3] = "ui_menu_tujian"
          else
            menu_data[2][3] = "ui_menu_look"
          end
        end
      elseif npc_type == NpcType203 then
        menu_data = trans_npc_menu_data
      elseif npc_type == 281 or npc_type == 282 then
        menu_data = pet_npc_menu_data
      elseif npc_type == 283 then
        menu_data = follow_sable_list
      elseif npc_type == 370 then
        menu_close_click()
        return
      elseif npc_type == 333 then
        menu_data = home_npc_menu_data
      elseif npc_type == 334 then
        menu_data = home_npc_npc_menu_data
      elseif npc_type == 401 then
        menu_data = func_npc_menu_data
      elseif npc_type == 700 or npc_type == 704 then
        menu_data = normal_pet_menu_data
      elseif 0 < npc_type then
        if tonumber(client_kind_npc) > 2 and tonumber(client_kind_npc) ~= 5 then
          menu_data = func_npc_menu_data_without_look
        else
          menu_data = func_npc_menu_data
          local bFlag = false
          for i = 1, MAX_MAX_NPCTYPE do
            local canSignNpcType = TEAM_SIGN_NPCTYPE[i]
            if nx_number(canSignNpcType) == nx_number(npc_type) then
              bFlag = true
              break
            end
          end
          if bFlag then
            menu_data = cansign_npc_menu_data
          end
          if menu_data ~= nil then
            if tonumber(client_kind_npc) ~= 0 then
              menu_data[2][3] = "ui_menu_tujian"
            else
              menu_data[2][3] = "ui_menu_look"
            end
          end
        end
      else
        menu_data = other_npc_menu_data
      end
    else
      return
    end
    local root_menu = menu
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, select_target)
  elseif LastMenuTarget == "team" then
    local root_menu = menu
    menu_data = team_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "friend" then
    local root_menu = menu
    menu_data = friend_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "scenario" then
    local root_menu = menu
    menu_data = scenario_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "chat_sender" then
    local root_menu = menu
    menu_data = chat_sender_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "chat" then
    local root_menu = menu
    menu_data = chat_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "recruit" then
    local root_menu = menu
    menu_data = select_player_in_recruit
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "tiny_team_info" then
    local root_menu = menu
    menu_data = tiny_team_info_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "tiny_single_info" then
    local root_menu = menu
    menu_data = tiny_single_info_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "rank" then
    local root_menu = menu
    menu_data = rank_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "activity_prize_rank" then
    local root_menu = menu
    menu_data = activity_prize_rank_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "market" then
    local root_menu = menu
    menu_data = market_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "offline_log_name" then
    local root_menu = menu
    menu_data = select_offline_log_name
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "select_sns_blog_name" then
    local root_menu = menu
    menu_data = select_sns_blog_name
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "select_npc_karma_list" then
    local root_menu = menu
    menu_data = select_npc_karma_list
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "select_npc_karma_delay" then
    local root_menu = menu
    menu_data = select_npc_karma_delay
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "chat_panel" then
    local root_menu = menu
    menu_data = chat_panel_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "chat_group" then
    local root_menu = menu
    menu_data = chat_group_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "member_groupchat" then
    local root_menu = menu
    menu_data = member_groupchat_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "groupchat" then
    local root_menu = menu
    menu_data = groupchat_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "schoolfight_rank" then
    local root_menu = menu
    menu_data = schoolfight_rank_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "city_kapai_trace_menu_data" then
    local root_menu = menu
    menu_data = city_kapai_trace_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "sweet_employee_menu" then
    local root_menu = menu
    menu_data = sweet_employ_npc_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "home_neighbor" then
    local root_menu = menu
    menu_data = home_neighbor
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "home_visit_friend" then
    local root_menu = menu
    menu_data = home_visit_friend
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "home_resident" then
    local root_menu = menu
    menu_data = home_resident
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "home_employee" then
    local root_menu = menu
    menu_data = home_employee
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "chat_hlink" then
    local root_menu = menu
    menu_data = chat_hlink_menu_data
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  elseif LastMenuTarget == "chat_item" then
    local root_menu = menu
    menu_data = chat_item
    menu_fresh_bydata(root_menu, menu, menu_data, game_role, userdata)
  end
  return 1
end
function menu_fresh_bydata(root_menu, menu, menudata, role, targetinfo)
  if menudata == nil then
    return
  end
  root_menu.target = targetinfo
  local gui = nx_value("gui")
  local count = table.maxn(menudata)
  local lasttype = menudata[1][1]
  local sindex = 1
  for i = 1, count do
    local bCreatedIt = true
    if menudata[i][5] == nil then
      if menudata[i][6] ~= nil then
        local enabled = nx_execute("menu_functions", "is_enable_" .. menudata[i][6], role, targetinfo)
        if nx_int(enabled) == nx_int(1) then
          bCreatedIt = false
        end
      end
    else
      local visibled = nx_execute("menu_functions", "is_visible_" .. menudata[i][5], role, targetinfo)
      local enabled = 2
      if nx_int(visibled) == nx_int(0) then
        bCreatedIt = false
      elseif menudata[i][6] ~= nil then
        enabled = nx_execute("menu_functions", "is_enable_" .. menudata[i][6], role, targetinfo)
        if nx_int(enabled) == nx_int(1) then
          bCreatedIt = false
        end
      end
    end
    if bCreatedIt == true then
      local menutext = gui.TextManager:GetText(menudata[i][3])
      local item = menu:CreateItem(menudata[i][2], menutext)
      if menudata[i][7] ~= nil then
        item.Icon = nx_string(menudata[i][7])
      else
        menu.LeftBarWidth = 0
      end
      if menudata[i][8] ~= nil then
        menu.ItemHeight = nx_int(menudata[i][8])
      end
      if menudata[i][9] ~= nil then
        menu.LeftBarWidth = nx_int(menudata[i][9])
      end
      if menudata[i][4] ~= nil then
        local submenu = gui:Create("Menu")
        nx_bind_script(submenu, "menu_game", "menu_game_init")
        submenu.AutoSize = false
        submenu.ForeColor = "255,255,161,92"
        submenu.Visible = false
        submenu.BackImage = "gui\\common\\form_back\\bg_menu.png"
        submenu.DrawMode = "Expand"
        submenu.ItemHeight = 18
        submenu.Width = 140
        submenu.LeftBar = true
        submenu.LeftBarWidth = 0
        submenu.LeftBarBackColor = "0,255,255,255"
        submenu.Font = "FZHTJT18"
        submenu.ForeColor = "255,0,177,8"
        submenu.SelectBackColor = "255,40,40,40"
        submenu.SelectBorderColor = "255,80,80,80"
        submenu.target = targetinfo
        item.SubMenu = submenu
        local submenudata = menudata[i][4]
        menu_fresh_bydata(root_menu, submenu, submenudata, role, targetinfo)
      else
        local event = "on_" .. menudata[i][2] .. "_click"
        local callback = "menu_" .. menudata[i][2] .. "_click"
        nx_callback(menu, nx_string(event), nx_string(callback))
      end
    end
  end
end
function get_selected_player_name()
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return nx_widestr("")
  end
  local objtype = selectobj:QueryProp("Type")
  if nx_number(objtype) == TYPE_PLAYER then
    return selectobj:QueryProp("Name")
  end
  return nx_widestr("")
end
function create_team_sign_str(new_sign, target_name)
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  local select_target_ident = game_role:QueryProp("LastObject")
  local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
  local target_type = TYPE_PLAYER
  if target_name == nil then
    if not nx_is_valid(select_target) then
      return nil
    end
    target_type = select_target:QueryProp("Type")
  end
  if target_type == TYPE_PLAYER then
    if target_name ~= nil then
      select_target_ident = nx_widestr(target_name)
    else
      select_target_ident = select_target:QueryProp("Name")
    end
    new_sign = -new_sign
  end
  local captainname = game_role:QueryProp("TeamCaptain")
  local row = game_role:FindRecordRow("team_rec", TEAM_REC_COL_NAME, nx_widestr(captainname))
  if row < 0 then
    return nil
  end
  local signstr = game_role:QueryRecord("team_rec", row, TEAM_REC_COL_SIGN_STR)
  local signstr_lst = util_split_string(signstr, ",")
  local count = nx_int(table.getn(signstr_lst) / 2)
  local new_one = true
  for i = 1, nx_number(count) do
    local sign = signstr_lst[i * 2 - 1]
    local target_ident = signstr_lst[i * 2]
    if nx_string(target_ident) == nx_string(select_target_ident) and nx_string(sign) == nx_string(new_sign) then
      new_one = false
      return nil
    end
    if nx_string(target_ident) == nx_string(select_target_ident) then
      signstr_lst[i * 2 - 1] = nx_string(new_sign)
      new_one = false
    end
    if nx_string(math.abs(nx_number(sign))) == nx_string(math.abs(nx_number(new_sign))) then
      signstr_lst[i * 2] = nx_string(select_target_ident)
      signstr_lst[i * 2 - 1] = new_sign
      new_one = false
    end
  end
  local new_signstr = ""
  if new_one then
    if nx_int(count) > nx_int(0) then
      new_signstr = nx_string(nx_string(signstr) .. "," .. nx_string(new_sign) .. "," .. nx_string(select_target_ident))
    else
      new_signstr = nx_string(nx_string(signstr) .. nx_string(new_sign) .. "," .. nx_string(select_target_ident))
    end
    return new_signstr
  end
  new_signstr = signstr_lst[1] .. "," .. signstr_lst[2]
  for i = 2, nx_number(count) do
    local sign = signstr_lst[i * 2 - 1]
    local target_ident = signstr_lst[i * 2]
    local canadd = 1
    for j = 1, i - 1 do
      local before_sign = signstr_lst[j * 2 - 1]
      local before_target_ident = signstr_lst[j * 2]
      if math.abs(before_sign) == math.abs(sign) or before_target_ident == target_ident then
        canadd = 0
        break
      end
    end
    if canadd == 1 then
      new_signstr = new_signstr .. "," .. nx_string(sign) .. "," .. nx_string(target_ident)
    end
  end
  return new_signstr
end
function menu_close_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if nx_is_valid(menu_game) then
    gui:Delete(menu_game)
  end
end
function menu_set_sign_click()
end
function menu_set_sign_form_click(form)
end
function menu_selectobj_set_sign_0_click()
  local sign_str = create_team_sign_str(0, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_selectobj_set_sign_1_click()
  local sign_str = create_team_sign_str(1, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_selectobj_set_sign_2_click()
  local sign_str = create_team_sign_str(2, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_selectobj_set_sign_3_click()
  local sign_str = create_team_sign_str(3, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_selectobj_set_sign_4_click()
  local sign_str = create_team_sign_str(4, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_selectobj_set_sign_5_click()
  local sign_str = create_team_sign_str(5, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_selectobj_set_sign_6_click()
  local sign_str = create_team_sign_str(6, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_selectobj_set_sign_7_click()
  local sign_str = create_team_sign_str(7, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_selectobj_set_sign_8_click()
  local sign_str = create_team_sign_str(8, nil)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_0_click(form)
  local sign_str = create_team_sign_str(0, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_1_click(form)
  local sign_str = create_team_sign_str(1, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_2_click(form)
  local sign_str = create_team_sign_str(2, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_3_click(form)
  local sign_str = create_team_sign_str(3, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_4_click(form)
  local sign_str = create_team_sign_str(4, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_5_click(form)
  local sign_str = create_team_sign_str(5, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_6_click(form)
  local sign_str = create_team_sign_str(6, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_7_click(form)
  local sign_str = create_team_sign_str(7, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_team_set_sign_8_click(form)
  local sign_str = create_team_sign_str(8, form.target)
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_0_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(0, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_1_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(1, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_2_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(2, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_3_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(3, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_4_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(4, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_5_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(5, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_6_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(6, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_7_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(7, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_player_set_sign_8_click(form)
  if not nx_is_valid(form.target) then
    return
  end
  local sign_str = create_team_sign_str(8, form.target:QueryProp("Name"))
  if nx_string(sign_str) ~= nx_string(nil) then
    nx_execute("custom_sender", "custom_team_sign_set", nx_string(sign_str))
  end
end
function menu_tvt_look_click(form)
  nx_execute("form_stage_main\\form_main\\form_main_select", "on_look_selectobj_tvt")
  menu_close_click()
end
function menu_copy_name_click(form)
  local name
  if not nx_is_valid(form.target) then
    return
  end
  local target_type = form.target:QueryProp("Type")
  if TYPE_PLAYER == target_type then
    name = form.target:QueryProp("Name")
  else
    local config_id = form.target:QueryProp("ConfigID")
    local gui = nx_value("gui")
    name = gui.TextManager:GetText(config_id)
  end
  nx_function("ext_copy_wstr", nx_widestr(name))
end
function menu_copy_name1_click(form)
  nx_function("ext_copy_wstr", nx_widestr(form.target))
end
function menu_my_info_click(form)
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  local name = game_role:QueryProp("Name")
  nx_execute("form_stage_main\\form_role_chakan", "get_player_info", name)
  menu_close_click()
end
function menu_player_look_click(form)
  nx_execute("form_stage_main\\form_main\\form_main_select", "on_look_selectobj_prop")
  menu_close_click()
end
function menu_binglu_look_click(form)
  nx_execute("form_stage_main\\form_main\\form_main_select", "on_look_selectobj_binglu")
  menu_close_click()
end
function menu_player_game_info_look_click(form)
  local player_name = nx_widestr("")
  if LastMenuTarget == "selectobj" then
    local select_obj = nx_value(GAME_SELECT_OBJECT)
    if not nx_is_valid(select_obj) then
      return
    end
    local obj_type = select_obj:QueryProp("Type")
    if obj_type ~= TYPE_PLAYER then
      return
    end
    player_name = select_obj:QueryProp("Name")
  end
  if LastMenuTarget == "team" or LastMenuTarget == "market" then
    player_name = nx_widestr(form.target)
  end
  nx_execute("custom_sender", "custom_send_get_player_game_info", player_name)
  menu_close_click()
end
function menu_player_tiguan_click(form)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_tiguan\\form_tiguan_other")
  menu_close_click()
end
function menu_set_zhenyan_click(form)
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    nx_execute("custom_sender", "custom_set_zhenyan", select_obj.Ident)
  end
  menu_close_click()
end
function menu_player_jiaohu_click()
  nx_execute("form_stage_main\\form_main\\form_main_select", "on_select_photo_box_click")
end
function menu_player_look_click1(form)
  menu_close_click()
end
function menu_player_exchange_click()
  local player = get_selected_player_name()
  if player == "" then
    menu_close_click()
    return 0
  end
  nx_execute("custom_sender", "custom_request", REQUESTTYPE_EXCHANGE, nx_widestr(player))
  menu_close_click()
end
function menu_player_exchange1_click(form)
  nx_execute("custom_sender", "custom_request", REQUESTTYPE_EXCHANGE, nx_widestr(form.target))
  menu_close_click()
end
function menu_follow_others_click()
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_scene_obj = game_visual:GetSceneObj(selectobj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return false
  end
  local follow_motion = nx_value("FollowManager")
  if not nx_is_valid(follow_motion) then
    follow_motion = nx_create("PlayerTrackModule")
    nx_set_value("PlayerTrackModule", follow_motion)
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(client_player:QueryProp("StallState")) == nx_int(2) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7040"))
    menu_close_click()
    return
  end
  follow_motion:RequestFollow(visual_scene_obj)
  menu_close_click()
end
function menu_request_multiride_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MULTIRIDE_REQUEST), 1, nx_widestr(name))
    end
  end
  menu_close_click()
end
function menu_present_to_npc_click()
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local target_player = game_visual:GetSceneObj(selectobj.Ident)
  local main_player = game_visual:GetPlayer()
  if nx_is_valid(main_player) and nx_is_valid(target_player) then
    local x1, y1, z1 = main_player.PositionX, main_player.PositionY, main_player.PositionZ
    local x2, y2, z2 = target_player.PositionX, target_player.PositionY, target_player.PositionZ
    local sx = x2 - x1
    local sy = y2 - y1
    local sz = z2 - z1
    local dist = math.sqrt(sx * sx + sz * sz + sy * sy)
    if dist < 10 then
      local form = nx_value("form_stage_main\\form_present_to_npc")
      if nx_is_valid(form) then
        nx_destroy(form)
      end
      local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_present_to_npc", true, false)
      if not nx_is_valid(form) then
        return
      end
      form.npc_id = selectobj:QueryProp("ConfigID")
      form.scene_id = get_scene_id()
      form.type = 1
      form:Show()
      nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
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
    else
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("40014"))
    end
  end
end
function menu_query_good_feeling_click()
  local npc = nx_value("game_select_obj")
  if not nx_is_valid(npc) then
    return
  end
  local configid = npc:QueryProp("ConfigID")
  local scene_id = get_scene_id()
  if nx_int(scene_id) <= nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = util_format_string("ui_karma_query_distance", nx_int(1000))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog.ok_btn.Text = nx_widestr(util_format_string("ui_karma_query_yes"))
  dialog.cancel_btn.Text = nx_widestr(util_format_string("ui_karma_query_no"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_query_good_feeling", nx_int(11), configid, scene_id)
  end
end
function menu_cure_the_hero_npc_click()
  local npc = nx_value("game_select_obj")
  if not nx_is_valid(npc) then
    return
  end
  local configid = npc:QueryProp("ConfigID")
  local scene_id = get_scene_id()
  if nx_int(scene_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_cure_hero_npc", nx_int(17), configid, scene_id)
end
function menu_player_filter_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_filter", name)
  end
  menu_close_click()
end
function menu_player_filter_native_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    local karmamgr = nx_value("Karma")
    if nx_is_valid(karmamgr) then
      karmamgr:AddFilterNative(nx_widestr(name))
    end
  end
  menu_close_click()
end
function menu_player_filter_request1_click()
  local name = LastMenuType
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_filter", name)
  menu_close_click()
end
function menu_player_filter_request2_click(form)
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_filter", nx_widestr(form.target))
  menu_close_click()
end
function menu_player_attention_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", name)
  end
  menu_close_click()
end
function menu_player_attention_request1_click()
  local name = LastMenuType
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", name)
  menu_close_click()
end
function menu_player_attention_request2_click(form)
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", nx_widestr(form.target))
  menu_close_click()
end
function menu_player_chouren_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_chouren", name)
  end
  menu_close_click()
end
function menu_player_chouren_request1_click()
  local name = LastMenuType
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_chouren", name)
  menu_close_click()
end
function menu_player_chouren_request2_click(form)
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_chouren", nx_widestr(form.target))
  menu_close_click()
end
function menu_player_friend_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", name)
  end
  menu_close_click()
end
function menu_player_friend_request1_click()
  local name = LastMenuType
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", name)
  menu_close_click()
end
function menu_player_friend_request2_click(form)
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", nx_widestr(form.target))
  menu_close_click()
end
function menu_player_add_blacklist_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_add_blacklist", name)
  end
  menu_close_click()
end
function menu_player_add_blacklist2_click(self)
  local name = self.target
  menu_close_click()
end
function menu_create_team_click()
  nx_execute("custom_sender", "custom_team_create")
  menu_close_click()
end
function menu_team_kick_click(form)
  local name = form.target
  nx_execute("custom_sender", "custom_kickout_team", nx_widestr(name))
  menu_close_click()
end
function menu_battlefield_kick_click(form)
  local name = form.target
  local CLIENT_SUBMSG_REQUEST_COMPLAIN = 9
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_COMPLAIN, nx_widestr(name))
  menu_close_click()
end
function menu_team_kick0_click(form)
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_kickout_team", name)
  end
  menu_close_click()
end
function menu_team_leave_click()
  nx_execute("custom_sender", "custom_leave_team")
  menu_close_click()
end
function menu_team_disband_click()
  nx_execute("custom_sender", "custom_team_destroy")
  menu_close_click()
end
function menu_team_realse_work_click(form)
  local name = form.target
  nx_execute("form_stage_main\\form_team\\form_team_large_recruit", "release_work_byname", nx_widestr(name))
end
function menu_team_realse_work0_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("form_stage_main\\form_team\\form_team_large_recruit", "release_work_byname", name)
  end
end
function menu_team_change_leader_click(form)
  local name = form.target
  nx_execute("custom_sender", "custom_caption_change", nx_widestr(name))
  menu_close_click()
end
function menu_team_change_leader0_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_caption_change", name)
  end
  menu_close_click()
end
function menu_player_send_msg_click()
  util_auto_show_hide_form("form_stage_main\\form_mail\\form_mail")
end
function menu_player_team_join_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    if nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "is_filter_player", nx_widestr(name)) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("11521"), CENTERINFO_PERSONAL_NO)
      end
      return
    end
    nx_execute("custom_sender", "custom_team_request_join", name)
  end
  menu_close_click()
end
function menu_player_team_request_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local name = self.target:QueryProp("Name")
    if nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "is_filter_player", nx_widestr(name)) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("11521"), CENTERINFO_PERSONAL_NO)
      end
      return
    end
    nx_execute("custom_sender", "custom_team_invite", name)
  end
  menu_close_click()
end
function menu_player_team_request1_click()
  local name = LastMenuType
  nx_execute("custom_sender", "custom_team_invite", nx_widestr(name))
  menu_close_click()
end
function menu_player_team_request2_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local name = self.target:QueryProp("Name")
    nx_execute("custom_sender", "custom_team_invite", name)
  end
  menu_close_click()
end
function menu_player_team_request3_click(self)
  nx_execute("custom_sender", "custom_team_invite", nx_widestr(self.target))
  menu_close_click()
end
function menu_player_receiveprentice_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", 7, name)
  end
  menu_close_click()
end
function menu_player_callmaster_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", 8, name)
  end
  menu_close_click()
end
function menu_player_freemasprenralation_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", 9, name)
  end
  menu_close_click()
end
function menu_player_challenge_click()
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(select_obj) then
    return
  end
  local name = select_obj:QueryProp("Name")
  nx_execute("custom_sender", "custom_request", REQUESTTYPE_CHALLENGE, nx_widestr(name))
  menu_close_click()
  nx_execute("util_sound", "play_link_sound", "fight_pk_challenge.wav", nx_value("role"), 0, 0, 0, 1, 5, 1, "snd\\action\\fight\\other\\")
end
function menu_player_rank_challenge_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", REQUESTTYPE_RANK_CHALLENGE, nx_widestr(name))
  end
  menu_close_click()
end
function menu_life_wqgame_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", REQUESTTYPE_WQGAME, nx_widestr(name))
  end
  menu_close_click()
end
function menu_player_request_gemfight_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", REQUESTTYPE_PLAY_GEMGAME, nx_widestr(name))
  end
  menu_close_click()
end
function menu_player_send_mail_click(form)
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
    local form_send_mail = nx_value("form_stage_main\\form_mail\\form_mail_send")
    if nx_is_valid(form_send_mail) then
      form_send_mail.targetname.Text = nx_widestr(name)
    end
  end
  menu_close_click()
end
function menu_player_team_send_mail_click(form)
  nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
  local form_send_mail = nx_value("form_stage_main\\form_mail\\form_mail_send")
  if nx_is_valid(form_send_mail) then
    form_send_mail.targetname.Text = nx_widestr(form.target)
  end
  menu_close_click()
end
function menu_sh_tj_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_tj")
    nx_execute("form_stage_main\\form_life\\form_job_share", "open_form", select_obj, "sh_tj")
  end
  menu_close_click()
end
function menu_sh_cs_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_cs")
    nx_execute("form_stage_main\\form_life\\form_job_share", "open_form", select_obj, "sh_cs")
  end
  menu_close_click()
end
function menu_sh_ds_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_ds")
    nx_execute("form_stage_main\\form_life\\form_job_share", "open_form", select_obj, "sh_ds")
  end
  menu_close_click()
end
function menu_sh_ys_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_ys")
    nx_execute("form_stage_main\\form_life\\form_job_share", "open_form", select_obj, "sh_ys")
  end
  menu_close_click()
end
function menu_sh_cf_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_cf")
    nx_execute("form_stage_main\\form_life\\form_job_share", "open_form", select_obj, "sh_cf")
  end
  menu_close_click()
end
function menu_sh_jq_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_jq")
    nx_execute("form_stage_main\\form_life\\form_job_share", "open_form", select_obj, "sh_jq")
  end
  menu_close_click()
end
function menu_sh_gs_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_gs")
    nx_execute("custom_sender", "custom_request_fortunetelling", name)
  end
  menu_close_click()
end
function menu_sh_ss_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_ss")
    nx_execute("form_stage_main\\form_life\\form_job_share", "open_form", select_obj, "sh_ss")
  end
  menu_close_click()
end
function menu_sh_hs_click()
  if CurSceneIsCloneScene() then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("60019"), 2)
    end
    menu_close_click()
    return
  end
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_life_request_look", nx_widestr(name), "sh_hs")
    nx_execute("form_stage_main\\form_life\\form_job_share", "open_form", select_obj, "sh_hs")
  end
  menu_close_click()
end
function menu_player_marriage_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request_marriage", name)
  end
  menu_close_click()
end
function menu_player_lover_request_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", 10, name)
  end
  menu_close_click()
end
function menu_player_lover_del_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request_lover_free", name)
  end
  menu_close_click()
end
function menu_player_finish_bus_click()
  nx_execute("custom_sender", "custom_request_bus_finish")
end
function menu_team_set_quality_click()
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_team\\form_quality")
  menu_close_click()
end
function menu_team_alloc_free_click()
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_FREE)
  menu_close_click()
end
function menu_team_alloc_turn_click()
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_TURN)
  menu_close_click()
end
function menu_team_alloc_team_click()
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_TEAM)
  menu_close_click()
end
function menu_team_alloc_leader_click()
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_CAPTAIN)
  menu_close_click()
end
function menu_team_alloc_need_click()
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_NEED)
  menu_close_click()
end
function menu_team_alloc_compete_click()
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_COMPETE)
  menu_close_click()
end
function menu_team_quality_1_click()
  nx_execute("custom_sender", "custom_set_team_allot_quality", 1)
  menu_close_click()
end
function menu_team_quality_2_click()
  nx_execute("custom_sender", "custom_set_team_allot_quality", 2)
  menu_close_click()
end
function menu_team_quality_3_click()
  nx_execute("custom_sender", "custom_set_team_allot_quality", 3)
  menu_close_click()
end
function menu_team_quality_4_click()
  nx_execute("custom_sender", "custom_set_team_allot_quality", 4)
  menu_close_click()
end
function menu_team_quality_5_click()
  nx_execute("custom_sender", "custom_set_team_allot_quality", 5)
  menu_close_click()
end
function menu_team_quality_6_click()
  nx_execute("custom_sender", "custom_set_team_allot_quality", 6)
  menu_close_click()
end
function menu_chat_new_page_click()
  nx_execute("form_stage_main\\form_main\\form_main_chat", "add_new_chat_page")
  menu_close_click()
end
function menu_player_sns_chat_click(self)
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  if not nx_is_valid(form) then
    return
  end
  local name = self.target
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(name))
end
function menu_player_target_secret_chat_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local name = self.target:QueryProp("Name")
    if nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "is_filter_player", nx_widestr(name)) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("7114"), CENTERINFO_PERSONAL_NO)
      end
      return
    end
    nx_execute("custom_sender", "custom_request_chat", nx_widestr(name))
  end
end
function menu_chat_panel_secret_chat_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_request_chat", nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function menu_chat_group_request_team_click(self)
end
function menu_member_groupchat_secret_chat_click(menu_game)
  if not nx_find_custom(menu_game, "target_name") or not nx_find_custom(menu_game, "groupid") then
    return
  end
  nx_execute("custom_sender", "custom_request_chat", menu_game.target_name)
  menu_close_click()
end
function menu_member_groupchat_game_info_look_click(menu_game)
  if not nx_find_custom(menu_game, "target_name") or not nx_find_custom(menu_game, "groupid") then
    return
  end
  nx_execute("custom_sender", "custom_send_get_player_game_info", menu_game.target_name)
  menu_close_click()
end
function menu_member_groupchat_quit_click(menu_game)
  if not nx_find_custom(menu_game, "target_name") or not nx_find_custom(menu_game, "groupid") then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_member_groupchat_quit")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "groupchat_member_quit", menu_game.groupid)
  end
  menu_close_click()
end
function menu_member_groupchat_del_member_click(menu_game)
  if not nx_find_custom(menu_game, "target_name") or not nx_find_custom(menu_game, "groupid") then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  gui.TextManager:Format_SetIDName(nx_string("ui_member_groupchat_del_member"))
  gui.TextManager:Format_AddParam(menu_game.target_name)
  local text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "groupchat_del_member", menu_game.groupid, menu_game.target_name)
  end
  menu_close_click()
end
function menu_member_groupchat_del_group_click(menu_game)
  if not nx_find_custom(menu_game, "target_name") or not nx_find_custom(menu_game, "groupid") then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_member_groupchat_del_group")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "groupchat_del_groupchat", menu_game.groupid)
  end
  menu_close_click()
end
function menu_groupchat_quit_click(menu_game)
  if not nx_find_custom(menu_game, "groupid") then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_member_groupchat_quit")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "groupchat_member_quit", menu_game.groupid)
  end
  menu_close_click()
end
function menu_groupchat_del_group_click(menu_game)
  if not nx_find_custom(menu_game, "groupid") then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_member_groupchat_del_group")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "groupchat_del_groupchat", menu_game.groupid)
  end
  menu_close_click()
end
function menu_chat_panel_request_team_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_team_invite", nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function menu_chat_panel_invite_member_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_guild_invite_member", nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function menu_chat_panel_send_mail_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
      local form_send_mail = nx_value("form_stage_main\\form_mail\\form_mail_send")
      if nx_is_valid(form_send_mail) then
        form_send_mail.targetname.Text = nx_widestr(player_name)
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_summon_player_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_jianghu_help", nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function menu_chat_panel_invite_player_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_avatar_clone_invite_help", nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function menu_chat_panel_sanhill_invite_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_sanhill_msg", 9, nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function menu_chat_panel_teacher_invite_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_teach_exam", 3, nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function get_menu_label_name(menu)
  if nx_is_valid(menu) and nx_find_custom(menu, "target") and nx_is_valid(menu.target) then
    local item = menu.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      return item.lbl_name.Text
    end
  end
  return nil
end
function menu_chat_panel_home_game_invite_click(self)
  local player_name = get_menu_label_name(self)
  if player_name ~= nil then
    nx_execute("custom_sender", "custom_request", REQUESTTYPE_HOME_GAME_INVITE, nx_widestr(player_name))
  end
  menu_close_click()
end
local SUB_MSG_RELATION_ADD_APPLY = 1
local SUB_MSG_RELATION_ADD_CONFIRM = 2
local SUB_MSG_RELATION_ADD_CANCEL = 3
local SUB_MSG_RELATION_ADD_SELF = 4
local SUB_MSG_RELATION_ADD_BOTH = 5
local SUB_MSG_RELATION_REMOVE_SELF = 6
local SUB_MSG_RELATION_REMOVE_BOTH = 7
local SUB_MSG_RELATION_ATTENTION_ADD = 8
local SUB_MSG_RELATION_ATTENTION_REMOVE = 9
local SUB_MSG_RELATION_ADD_ENEMY = 10
local RELATION_TYPE_FRIEND = 0
local RELATION_TYPE_BUDDY = 1
local RELATION_TYPE_BROTHER = 2
local RELATION_TYPE_ENEMY = 3
local RELATION_TYPE_BLOOD = 4
local RELATION_TYPE_ATTENTION = 5
local RELATION_TYPE_ACQUAINT = 6
local RELATION_TYPE_FANS = 7
local RELATION_TYPE_FLITER = 8
local RELATION_TYPE_STRANGER = 9
function menu_chat_panel_update_zhiyou_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_ADD_BOTH, nx_widestr(player_name), RELATION_TYPE_BUDDY, RELATION_TYPE_FRIEND)
    end
  end
  menu_close_click()
end
function menu_chat_panel_delete_friend_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_REMOVE_BOTH, nx_widestr(player_name), RELATION_TYPE_FRIEND, nx_int(-1))
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_down_haoyou_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_sns_confirm_down_haoyou", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_ADD_BOTH, nx_widestr(player_name), RELATION_TYPE_FRIEND, RELATION_TYPE_BUDDY)
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_delete_buddy_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_REMOVE_BOTH, nx_widestr(player_name), RELATION_TYPE_BUDDY, nx_int(-1))
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_update_xuechou_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_xuechou_prompt", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_ADD_SELF, nx_widestr(player_name), RELATION_TYPE_BLOOD, RELATION_TYPE_ENEMY)
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_delete_enemy_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("form_stage_main\\form_relation\\form_friend_list", "del_enemy_open_present", player_name)
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_down_choujia_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_ADD_SELF, nx_widestr(player_name), RELATION_TYPE_ENEMY, RELATION_TYPE_BLOOD)
    end
  end
  menu_close_click()
end
function menu_chat_panel_delete_blood_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("form_stage_main\\form_relation\\form_friend_list", "del_enemy_open_present", player_name)
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_add_friend_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_ADD_APPLY, nx_widestr(player_name), RELATION_TYPE_FRIEND, RELATION_TYPE_ACQUAINT)
    end
  end
  menu_close_click()
end
function menu_chat_panel_delete_attention_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_ATTENTION_REMOVE, nx_widestr(player_name), RELATION_TYPE_ATTENTION, nx_int(-1))
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_delete_acquaint_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_REMOVE_SELF, nx_widestr(player_name), RELATION_TYPE_ACQUAINT, nx_int(-1))
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_jiawei_filter_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_modify_filter", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_ADD_SELF, nx_widestr(player_name), RELATION_TYPE_FLITER, nx_int(-1))
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_delete_filter_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        nx_execute("custom_sender", "custom_add_relation", SUB_MSG_RELATION_REMOVE_SELF, nx_widestr(player_name), RELATION_TYPE_FLITER, nx_int(-1))
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_delete_filter_native_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      local gui = nx_value("gui")
      local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", player_name)
      local res = util_form_confirm("", info)
      if res == "ok" then
        local karmamgr = nx_value("Karma")
        if nx_is_valid(karmamgr) and karmamgr:IsFilterNative(nx_widestr(player_name)) then
          karmamgr:DelFilterNative(nx_widestr(player_name))
          return
        end
      end
    end
  end
  menu_close_click()
end
function menu_chat_panel_game_info_look_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_send_get_player_game_info", player_name)
    end
  end
  menu_close_click()
end
function menu_chit_report_ad_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) and nx_find_custom(self.target, "report_index") and nx_find_custom(self.target, "report_name") then
    local form_main_chat_logic = nx_value("form_main_chat")
    if not nx_is_valid(form_main_chat_logic) then
      return
    end
    local mltbox = self.target
    local player_name = nx_widestr(mltbox.report_name)
    local index = nx_int(mltbox.report_index)
    local info = mltbox:GetItemTextNoHtml(index)
    info = form_main_chat_logic:DeleteHtml(info)
    local str = string.gsub(nx_string(info), "%d%d%d%d[-]%d%d[-]%d%d", "")
    str = string.gsub(nx_string(str), "%d%d:%d%d:%d%d", "")
    str = string.gsub(nx_string(str), " ", "")
    str = string.gsub(nx_string(str), "\161\161", "")
    str = string.gsub(nx_string(str), "\t", "")
    if str == "" then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("99601"))
      menu_close_click()
      return
    end
    info = nx_widestr(player_name) .. info
    local gui = nx_value("gui")
    local excuse = gui.TextManager:GetText("msg_report_ad_excuse")
    nx_execute("form_stage_main\\form_gmcc\\form_gmcc_main", "notify_player", player_name, 3, excuse, info)
  end
  menu_close_click()
end
function menu_player_secret_chat_recruit_click()
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  local gui = nx_value("gui")
  form.chat_channel_btn.Text = gui.TextManager:GetText("ui_chat_channel_3")
  form.chat_edit.chat_type = 3
  gui.Focused = form.chat_edit
  local name = LastMenuType
  form.chat_edit.Text = nx_widestr(name)
end
function menu_offline_player_secret_chat_click()
  local form_log = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline_log", true, false)
  if not nx_find_custom(form_log, "TargetName") then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  local gui = nx_value("gui")
  form.chat_channel_btn.Text = gui.TextManager:GetText("ui_chat_channel_3")
  form.chat_edit.chat_type = 3
  gui.Focused = form.chat_edit
  local name = form_log.TargetName
  form.chat_edit.Text = nx_widestr("")
  form.chat_edit:Append(nx_widestr(name), -1)
  form.chat_edit:Append(nx_widestr(" "), -1)
  nx_execute("form_stage_main\\form_main\\form_main_chat", "show_chat")
end
function menu_offline_player_send_mail_click()
  local form_log = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline_log", true, false)
  if not nx_find_custom(form_log, "TargetName") then
    return
  end
  local name = form_log.TargetName
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail", true, false)
  form:Show()
  local form_send = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail_send", true, false)
  form_send.targetname.Text = nx_widestr(name)
end
function menu_free_friend_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local name = self.target
    nx_execute("custom_sender", "custom_del_friend", name)
  end
end
function menu_user_remark_click(self)
  local name = self.target
end
function menu_scenario_delete_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local name = self.target
    nx_execute("story_editor\\form_scenario_editor", "delete_request", name)
  end
end
function menu_scenario_add_click(self)
end
function menu_scenario_npc_click(self)
  nx_execute("story_editor\\form_scenario_editor", "add_npc_request")
end
function menu_scenario_camera_click(self)
  nx_execute("story_editor\\form_scenario_editor", "add_camera_request")
end
function menu_scenario_player_click(self)
  nx_execute("story_editor\\form_scenario_editor", "add_player_request")
end
function menu_scenario_effect_click(self)
  nx_execute("story_editor\\form_scenario_editor", "add_effect_request")
end
function menu_scenario_fade_click(self)
  nx_execute("story_editor\\form_scenario_editor", "add_fade_request")
end
function menu_scenario_ppdof_click(self)
  nx_execute("story_editor\\form_scenario_editor", "add_ppdof_request")
end
function menu_scenario_team_click(self)
  nx_execute("story_editor\\form_scenario_editor", "add_team_request")
end
function menu_scenario_movietalk_click(self)
  nx_execute("story_editor\\form_scenario_editor", "add_movietalk_request")
end
function menu_tiny_team_info_close_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_tiny_team", "on_close_click", self.target)
end
function menu_tiny_team_info_showgoodbuffer_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_tiny_team", "on_show_good_buffer", self.target)
end
function menu_tiny_team_info_showbadbuffer_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_tiny_team", "on_show_bad_buffer", self.target)
end
function menu_tiny_team_info_hidebuffer_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_tiny_team", "on_hide_buffer", self.target)
end
function menu_tiny_single_info_close_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_tiny_single", "on_close_click", self.target)
end
function menu_tiny_single_info_showgoodbuffer_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_tiny_single", "on_show_good_buffer", self.target)
end
function menu_tiny_single_info_showbadbuffer_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_tiny_single", "on_show_bad_buffer", self.target)
end
function menu_tiny_single_info_hidebuffer_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_tiny_single", "on_hide_buffer", self.target)
end
function menu_neigong_pk_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request_neigong_pk", name)
  end
  menu_close_click()
end
function menu_join_neigong_pk_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_join__neigong_pk", name)
  end
  menu_close_click()
end
function menu_player_impart_click()
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", REQUESTTYPE_IMPART, nx_widestr(name))
  end
  menu_close_click()
end
function menu_invite_respond_click()
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(select_obj) then
    return
  end
  local responded_guildname = select_obj:QueryProp("RespondedGuildName")
  if select_obj:FindProp("RespondedGuildName") and nx_string(responded_guildname) ~= nx_string("") then
    local info = util_text("19311")
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(info, 0, 0)
    end
    return
  end
  local name = select_obj:QueryProp("Name")
  nx_execute("custom_sender", "custom_guild_invite_respond", nx_widestr(name))
end
function menu_join_faculty_click()
  local player = get_selected_player_name()
  if player == "" then
    menu_close_click()
    return 0
  end
  nx_execute("custom_sender", "custom_request", REQUESTTYPE_JOIN_FACULTY, nx_widestr(player))
  menu_close_click()
end
function menu_pupil_baishi_click()
  local player = get_selected_player_name()
  if player == "" then
    menu_close_click()
    return 0
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(11), nx_int(1), nx_widestr(player))
  end
  menu_close_click()
end
function menu_shou_tu_click()
  local player = get_selected_player_name()
  if player == "" then
    menu_close_click()
    return 0
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(11), nx_int(2), nx_widestr(player))
  end
  menu_close_click()
end
function menu_join_guild_click()
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(select_obj) then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local self_guild = player_obj:QueryProp("GuildName")
  if nx_string(self_guild) ~= nx_string("0") and nx_string(self_guild) ~= nx_string("") then
    return
  end
  local guild_name = select_obj:QueryProp("GuildName")
  if nx_string(guild_name) == nx_string("0") or nx_string(guild_name) == nx_string("") then
    return
  end
  nx_execute("custom_sender", "custom_request_join_guild", nx_widestr(guild_name))
end
function menu_interact_appraise_click(self)
  if nx_string(LastMenuType) == "friend" or nx_string(LastMenuType) == "rank" then
    name = self.target
  else
    local select_obj = nx_value("game_select_obj")
    if not nx_is_valid(select_obj) then
      return
    end
    name = select_obj:QueryProp("Name")
  end
  nx_execute("form_stage_main\\form_charge_shop\\form_interact_appraise", "show_interact_appraise", name)
  menu_close_click()
end
function menu_show_offline_info_click()
  local target = nx_value("game_select_obj")
  if nx_is_valid(target) and nx_execute("form_stage_main\\form_offline\\offline_util", "is_offline", target) then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_target_info", true, false)
    if nx_is_valid(form) then
      form:Show()
      nx_execute("form_stage_main\\form_offline\\form_offline_target_info", "refresh_offline_info", form, target)
    end
  end
end
function show_use_abduct_item_tip()
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("40061")
  local info = gui.TextManager:Format_GetText()
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
  end
end
TIME_INFINITE = -1
function menu_offline_abduct_click()
  local bagform = nx_value("form_stage_main\\form_bag")
  if not nx_is_valid(bagform) then
    return
  end
  if not nx_find_custom(bagform, "imagegrid_tool") then
    return
  end
  local grid_tool = bagform.imagegrid_tool
  if not nx_is_valid(grid_tool) then
    return
  end
  local table_has_abduct_item, table_abduct_item_grid_index = get_offline_abduct_item(grid_tool)
  if table_has_abduct_item == nil or table_abduct_item_grid_index == nil then
    return
  end
  local count_abduct_item_grid_index = table.getn(table_abduct_item_grid_index)
  if 0 < count_abduct_item_grid_index then
    show_use_abduct_item_tip()
    local form = nx_value("form_stage_main\\form_bag")
    if nx_is_valid(form) and form.Visible then
      glisten_bag_item(grid_tool, count_abduct_item_grid_index, table_abduct_item_grid_index, TIME_INFINITE)
      return
    end
    if nx_execute("form_stage_main\\form_bag_func", "open_bag_by_configid", table_has_abduct_item[1]) then
      glisten_bag_item(grid_tool, count_abduct_item_grid_index, table_abduct_item_grid_index, TIME_INFINITE)
    end
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("no_abduct_item"), 2)
    end
  end
end
function get_offline_abduct_item(grid_tool)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local table_abduct_item = {
    "offitem_miyao01",
    "offitem_miyao02",
    "offitem_miyao03",
    "offitem_miyao04",
    "offitem_miyao05",
    "offitem_miyao06",
    "offitem_miyao07",
    "offitem_miyao08",
    "offitem_miyao09",
    "offitem_miyao10"
  }
  local table_has_abduct_item = {}
  for i = 1, table.getn(table_abduct_item) do
    local count = goods_grid:GetItemCount(nx_string(table_abduct_item[i]))
    if nx_number(count) > 0 then
      table.insert(table_has_abduct_item, table_abduct_item[i])
    end
  end
  local table_abduct_item_grid_index = {}
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return
  end
  local item_lst = view:GetViewObjList()
  for i, item in pairs(item_lst) do
    for j = 1, table.getn(table_abduct_item) do
      if item:FindProp("ConfigID") and nx_ws_equal(nx_widestr(item:QueryProp("ConfigID")), nx_widestr(table_abduct_item[j])) then
        local view_index = nx_number(item.Ident)
        local grid_index = goods_grid:GetGridIndexFromViewIndex(grid_tool, nx_number(view_index))
        table.insert(table_abduct_item_grid_index, grid_index)
      end
    end
  end
  return table_has_abduct_item, table_abduct_item_grid_index
end
function glisten_bag_item(grid, num_grid_index, table_item_grid_index, time)
  for i = 1, nx_number(num_grid_index) do
    nx_execute("form_stage_main\\form_bag_func", "show_Cover_by_grid_index", grid, table_item_grid_index[i], true, "xuanzekuang_on")
  end
  if time == TIME_INFINITE then
    return
  end
  nx_pause(time)
  for j = 1, nx_number(num_grid_index) do
    nx_execute("form_stage_main\\form_bag_func", "show_Cover_by_grid_index", grid, table_item_grid_index[j], false, "xuanzekuang_on")
  end
end
function stop_glisten_bag_item(grid, num_grid_index, table_item_grid_index)
  for i = 1, nx_number(num_grid_index) do
    nx_execute("form_stage_main\\form_bag_func", "show_Cover_by_grid_index", grid, table_item_grid_index[i], false, "xuanzekuang_on")
  end
end
function stop_glisten_bag_abduct_item()
  local bagform = nx_value("form_stage_main\\form_bag")
  local grid_tool = bagform.imagegrid_tool
  if not nx_is_valid(grid_tool) then
    return
  end
  local table_has_abduct_item, table_abduct_item_grid_index = get_offline_abduct_item(grid_tool)
  if table_has_abduct_item == nil or table_abduct_item_grid_index == nil then
    return
  end
  local count_abduct_item_grid_index = table.getn(table_abduct_item_grid_index)
  if 0 < count_abduct_item_grid_index then
    local form = nx_value("form_stage_main\\form_bag")
    if nx_is_valid(form) then
      stop_glisten_bag_item(grid_tool, count_abduct_item_grid_index, table_abduct_item_grid_index)
    end
  end
end
function menu_offline_setfree_click()
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local money = nx_execute("form_stage_main\\form_offline\\offline_util", "get_setfree_money_by_level", target)
  local text_money = nx_execute("util_functions", "trans_capital_string", nx_int64(money))
  gui.TextManager:Format_SetIDName(nx_string("desc_can_set_free_others"))
  gui.TextManager:Format_AddParam(nx_widestr(text_money))
  local text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_offline_setfree", nx_int(1))
  end
end
function menu_off_tvt_stun_click()
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  if not target:FindProp("Name") then
    return
  end
  local targetname = target:QueryProp("Name")
  nx_execute("custom_sender", "stun_offline_book_keeper", nx_widestr(targetname))
end
function menu_offline_accost_click()
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  local can = nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee_utils.lua", "can_accost")
  if can ~= true then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_banlv_accost_001")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "accost_npc")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
  end
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "accost_npc_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_offline_accost", nx_int(1))
    end
  end
end
function menu_offline_togather_click()
  nx_execute("form_stage_main\\form_offline\\form_offline_together_training", "show_window")
end
function menu_fee_sub_level_1_click(self, menu)
  begin_offline_fee(1)
end
function menu_fee_sub_level_2_click(self, menu)
  begin_offline_fee(2)
end
function menu_fee_sub_level_3_click(self, menu)
  begin_offline_fee(3)
end
function menu_fee_sub_level_4_click(self, menu)
  begin_offline_fee(4)
end
function menu_fee_sub_level_5_click(self, menu)
  begin_offline_fee(5)
end
function menu_fee_sub_level_6_click(self, menu)
  begin_offline_fee(6)
end
function menu_fee_sub_level_7_click(self, menu)
  begin_offline_fee(7)
end
function menu_fee_sub_level_8_click(self, menu)
  begin_offline_fee(8)
end
function menu_fee_sub_level_9_click(self, menu)
  begin_offline_fee(9)
end
function begin_offline_fee(fee_level)
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  if not target:FindProp("Name") then
    return
  end
  local fee_type = nx_execute("form_stage_main\\form_offline\\offline_util", "get_fee_type", target)
  if nx_number(fee_type) <= 0 or nx_number(fee_type) > 5 then
    return
  end
  local feeLevel = nx_int(fee_level) - 1
  local targetname = target:QueryProp("Name")
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_INTERACT), nx_widestr(targetname), nx_int(feeLevel), nx_int(fee_type))
  end
end
function menu_Delete_click()
  nx_execute("form_stage_main\\form_map\\form_map_label_list", "delete_label")
  menu_close_click()
end
function menu_Modify_click()
  nx_execute("form_stage_main\\form_map\\form_map_label_list", "modify_label")
  menu_close_click()
end
function menu_respond_guild_click()
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(select_obj) then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local self_guild = player_obj:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(self_guild), nx_widestr("")) == false and nx_ws_equal(nx_widestr(self_guild), nx_widestr("0")) == false then
    return
  end
  local guild_name = select_obj:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(guild_name), nx_widestr("")) or nx_ws_equal(nx_widestr(guild_name), nx_widestr("0")) then
    return
  end
  if select_obj:FindProp("School") then
    local school = select_obj:QueryProp("School")
    if school == "" then
      local form_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_logic) then
        form_logic:AddSystemInfo(util_text("19315"), 0, 0)
      end
      return
    end
  end
  nx_execute("custom_sender", "custom_respond_guild", nx_widestr(guild_name))
end
function menu_friend_delete_click(self)
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "on_friend_delete_click", self.target)
end
function menu_friend_add_click(self)
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "on_friend_add_click", self.target)
end
function menu_friend_update_zhiyou_click(self)
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "on_friend_update_zhiyou_click", self.target)
end
function menu_friend_down_haoyou_click(self)
  nx_execute("form_stage_main\\form_relation\\form_friend_list", "on_friend_down_haoyou_click", self.target)
end
function menu_invite_member_click()
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(select_obj) then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local self_guild = player_obj:QueryProp("GuildName")
  if nx_widestr(self_guild) == nx_widestr("") and nx_widestr(self_guild) == nx_widestr("0") then
    return
  end
  local guild_name = select_obj:QueryProp("GuildName")
  if nx_widestr(guild_name) ~= nx_widestr("") and nx_widestr(guild_name) ~= nx_widestr("0") then
    return
  end
  if select_obj:FindProp("School") then
    local school = select_obj:QueryProp("School")
    if school == "" then
      local form_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_logic) then
        form_logic:AddSystemInfo(util_text("19315"), 0, 0)
      end
      return
    end
  end
  local Name = select_obj:QueryProp("Name")
  nx_execute("custom_sender", "custom_guild_invite_member", nx_widestr(Name))
end
function menu_sns_blog_player_info_click(menu_game)
  local bFind, relation, uid = nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "get_relation_type_by_name", menu_game.TargetName)
  if relation ~= nil and nx_number(relation) >= 0 and nx_number(relation) <= 5 then
    nx_execute("custom_sender", "custom_send_get_player_game_info", menu_game.TargetName)
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_sns_prompt"), 0)
  end
end
function menu_sns_blog_player_find_click(menu_game)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  form.name_edit.Text = nx_widestr(menu_game.TargetName)
  form:ShowModal()
end
function menu_cure_relive_click(form)
  nx_execute("form_stage_main\\form_die_util", "curetarget", 1)
  menu_close_click()
end
function menu_arrest_accuse_click()
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(select_obj) then
    return
  end
  name = select_obj:QueryProp("Name")
  nx_execute("form_stage_main\\form_arrest\\form_arrest", "accuse_wanted", nx_widestr(name))
end
function menu_npc_friend_add_click()
  local npc = nx_value("game_select_obj")
  if not nx_is_valid(npc) then
    return
  end
  local configid = npc:QueryProp("ConfigID")
  local scene_id = get_scene_id()
  if nx_int(scene_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(0), nx_string(configid), nx_int(scene_id))
end
function menu_npc_buddy_add_click()
  local npc = nx_value("game_select_obj")
  if not nx_is_valid(npc) then
    return
  end
  local configid = npc:QueryProp("ConfigID")
  local scene_id = get_scene_id()
  if nx_int(scene_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(1), nx_string(configid), nx_int(scene_id))
end
function menu_npc_attention_add_click()
  local npc = nx_value("game_select_obj")
  if not nx_is_valid(npc) then
    return
  end
  local configid = npc:QueryProp("ConfigID")
  local scene_id = get_scene_id()
  if nx_int(scene_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(6), nx_string(configid), nx_int(scene_id))
end
function menu_npc_attention_remove_click()
  local npc = nx_value("game_select_obj")
  if not nx_is_valid(npc) then
    return
  end
  local configid = npc:QueryProp("ConfigID")
  local scene_id = get_scene_id()
  if nx_int(scene_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(7), nx_string(configid), nx_int(scene_id))
end
function menu_npc_relation_cut_click()
  local npc = nx_value("game_select_obj")
  if not nx_is_valid(npc) then
    return
  end
  local configid = npc:QueryProp("ConfigID")
  local scene_id = get_scene_id()
  if nx_int(scene_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(-1), nx_string(configid), nx_int(scene_id))
end
function menu_npc_friend_add_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(0), nx_string(menu_game.npc_id), nx_int(menu_game.scene_id))
end
function menu_npc_buddy_add_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(1), nx_string(menu_game.npc_id), nx_int(menu_game.scene_id))
end
function menu_npc_attention_add_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(6), nx_string(menu_game.npc_id), nx_int(menu_game.scene_id))
end
function menu_npc_attention_remove_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(7), nx_string(menu_game.npc_id), nx_int(menu_game.scene_id))
end
function menu_npc_relation_cut_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(-1), nx_string(menu_game.npc_id), nx_int(menu_game.scene_id))
end
function menu_npc_relation_refresh_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(2), nx_string(menu_game.npc_id), nx_int(menu_game.scene_id))
end
function menu_npc_present_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  local form = nx_value("form_stage_main\\form_present_to_npc")
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_present_to_npc", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.npc_id = menu_game.npc_id
  form.scene_id = menu_game.scene_id
  form.type = 2
  form:Show()
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
function menu_npc_info_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_npc_info", "show_npc_info", menu_game.npc_id, menu_game.scene_id)
end
function menu_query_good_feeling_far_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = util_format_string("ui_karma_query_distance", nx_int(1000))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog.ok_btn.Text = nx_widestr(util_format_string("ui_karma_query_yes"))
  dialog.cancel_btn.Text = nx_widestr(util_format_string("ui_karma_query_no"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_query_good_feeling", nx_int(11), menu_game.npc_id, menu_game.scene_id)
  end
end
function menu_npc_avenge_serve_click(menu_game)
  if not nx_find_custom(menu_game, "npc_id") or not nx_find_custom(menu_game, "scene_id") then
    return
  end
  nx_execute("custom_sender", "custom_avenge", nx_int(7), nx_string(menu_game.npc_id), nx_int(menu_game.scene_id))
end
function menu_karma_delay_add_click(menu_game)
  if not nx_find_custom(menu_game, "event_uid") then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(3), nx_string(menu_game.event_uid), nx_int(0))
end
function menu_karma_delay_remove_click(menu_game)
  if not nx_find_custom(menu_game, "event_uid") then
    return
  end
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(4), nx_string(menu_game.event_uid), nx_int(0))
end
function menu_create_leitai_common_click(menu_game)
  nx_execute("form_stage_main\\form_leitai\\form_leitai", "open_form_by_func_type", 4)
end
function menu_create_leitai_random_click(menu_game)
  nx_execute("form_stage_main\\form_leitai\\form_leitai", "open_form_by_func_type", 5)
end
function menu_create_leitai_wudou_click(menu_game)
  nx_execute("form_stage_main\\form_leitai\\form_leitai", "open_form_by_func_type", 6)
end
function menu_pet_gone_click(menu_game)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("PetConfig") then
    return
  end
  local pet_id = client_player:QueryProp("PetConfig")
  if nx_string("") == nx_string(pet_id) then
    return
  end
  nx_execute("custom_sender", "custom_pet", nx_int(1), pet_id)
end
function menu_dismiss_normalpet_click(menu_game)
  nx_execute("custom_sender", "custom_normal_pet", nx_int(0))
end
function menu_open_depot_click(menu_game)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DEPOT_MSG), 9)
end
function menu_home_move_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_func_round", "close_form")
  home_manager:MoveHomeNpc(target_obj)
end
function menu_home_turn_round_click(menu_game)
  local page_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_func_round", true, false)
  if not nx_is_valid(page_form) then
    return
  end
  page_form.Visible = true
  page_form:Show()
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  page_form.target_npc = nx_object(target_obj.Ident)
end
function menu_home_back_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_func_round", "close_form")
  nx_execute("form_stage_main\\form_home\\form_home_myhome", "back_furniture", target_obj)
end
function menu_home_del_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_func_round", "close_form")
  nx_execute("form_stage_main\\form_home\\form_home_myhome", "del_furniture", target_obj)
end
function menu_home_fire_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_myhome", "fire_home_npc", target_obj)
end
function menu_home_setca_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_set_ca", "open_form", target_obj)
end
function menu_home_equip_exchange_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 14, nx_object(target_obj.Ident))
end
function menu_home_equip_split_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  if not target_obj:FindProp("Job") then
    return
  end
  local job_id = target_obj:QueryProp("Job")
  nx_execute("custom_sender", "custom_lifeskill_split_item", nx_string(job_id))
end
function menu_home_equip_composite_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local target_obj = menu_game.target
  if not nx_is_valid(target_obj) then
    return
  end
  if not target_obj:FindProp("Job") then
    return
  end
  local job_id = target_obj:QueryProp("Job")
  nx_execute("form_stage_main\\form_home\\form_home_equipment_fuse", "open_form", nx_string(job_id))
end
function menu_home_weapon_reset_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  nx_execute("form_stage_main\\form_life\\form_recast_attribute_weapon", "open_form")
end
function menu_home_clothes_reset_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  nx_execute("form_stage_main\\form_life\\form_recast_attribute", "open_form")
end
function menu_schoolfight_kick_click(form)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ui_schoolfight_report_001"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local select_obj = nx_value("game_select_obj")
    if nx_is_valid(select_obj) then
      local select_type = select_obj:QueryProp("Type")
      if nx_number(select_type) == TYPE_PLAYER then
        local select_name = select_obj:QueryProp("Name")
        nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 24, 0, nx_widestr(select_name))
      end
    end
  end
  menu_close_click()
end
function menu_schoolfight_report_click(form)
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local select_type = select_obj:QueryProp("Type")
    if nx_number(select_type) ~= TYPE_PLAYER then
      return
    end
    local select_name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 26, nx_widestr(select_name))
  end
  menu_close_click()
end
function menu_schoolfight_rank_kick_click(form)
  local player_name = nx_widestr(form.target)
  local result = nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "CanKickTarget")
  if result then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local gui = nx_value("gui")
    local text = nx_widestr(gui.TextManager:GetText("ui_schoolfight_report_001"))
    dialog.mltbox_info:Clear()
    dialog.mltbox_info:AddHtmlText(text, -1)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 24, 0, nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function menu_player_report_ad_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "target") then
    return
  end
  local player = menu_game.target
  if not nx_is_valid(player) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetSceneObj(player.Ident)
  if not nx_is_valid(visual_player) then
    return
  end
  local player_name = player:QueryProp("Name")
  local server_id = nx_int(game_config.server_id)
  local server_name = game_config.server_name
  local scene_id = get_scene_id()
  local x, y, z = visual_player.PositionX, visual_player.PositionY, visual_player.PositionZ
  local pos = nx_widestr(x) .. nx_widestr(", ") .. nx_widestr(z)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local excuse = gui.TextManager:GetText("msg_report_ad_excuse")
  local info = gui.TextManager:GetFormatText("msg_report_ad_norecord", player_name, server_id, server_name, scene_id, pos)
  nx_execute("form_stage_main\\form_gmcc\\form_gmcc_main", "notify_player", player_name, 3, excuse, info)
  menu_close_click()
end
function get_scene_id()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nx_int(-1)
  end
  local config_id = client_scene:QueryProp("ConfigID")
  local ini = nx_execute("util_functions", "get_ini", "ini\\scenes.ini")
  if not nx_is_valid(ini) then
    return nx_int(-1)
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local id = ini:GetSectionByIndex(i)
    local config = ini:ReadString(i, "Config", "")
    if nx_string(config) == nx_string(config_id) then
      return nx_int(id)
    end
  end
  return nx_int(-1)
end
function menu_sweet_pet_js_click(menu_game)
  nx_execute("custom_sender", "custom_offline_employ", nx_int(5))
end
function menu_sweet_pet_cz_click(menu_game)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local status = client_player:QueryRecord("rec_pet_show_base_prop", 0, 3)
  if nx_number(status) == nx_number(0) then
    nx_execute("custom_sender", "custom_offline_employ", nx_number(6))
  end
end
function menu_sweet_pet_use_tl_click(menu_game)
  local form_emp = nx_value("form_stage_main\\form_sweet_employ\\form_offline_employee")
  if not nx_is_valid(form_emp) then
    nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee", "auto_show_hide_employee_info")
  end
  local sweet_employee = nx_value("form_stage_main\\form_sweet_employ\\form_offline_employee")
  if not nx_is_valid(sweet_employee) then
    return
  end
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee", "on_btn_neigongquery_click", sweet_employee.btn_neigongquery)
end
function menu_sweet_pet_use_ng_click(menu_game)
  local form_emp = nx_value("form_stage_main\\form_sweet_employ\\form_offline_employee")
  if not nx_is_valid(form_emp) then
    nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee", "auto_show_hide_employee_info")
  end
  local sweet_employee = nx_value("form_stage_main\\form_sweet_employ\\form_offline_employee")
  if not nx_is_valid(sweet_employee) then
    return
  end
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee", "on_btn_taoluquery_click", sweet_employee.btn_taoluquery)
end
function menu_make_item_click(menu_game)
  local select_obj = nx_value("game_select_obj")
  if nx_is_valid(select_obj) then
    local name = select_obj:QueryProp("Name")
    nx_execute("custom_sender", "custom_request", REQUESTTYPE_MAKE_ITEM, nx_widestr(name))
  end
  menu_close_click()
end
function menu_open_kapai_click(menu_game)
  if not nx_find_custom(menu_game, "KapaiID") then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_world_city_kapai_trace", "open_form_kapai", nx_int(menu_game.KapaiID))
end
function menu_visit_home_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "home_id") then
    return
  end
  nx_execute("custom_sender", "custom_home", CLIENT_SUB_ENTRY, nx_string(menu_game.home_id), 2)
end
function menu_sale_home_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "home_id") then
    return
  end
  nx_execute("custom_sender", "custom_home", CLIENT_SUB_DIRECT_BID, nx_string(menu_game.home_id))
end
function menu_delete_friend_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "home_id") then
    return
  end
  local home_id = menu_game.home_id
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetText("ui_delete_home_neighbor"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog.ok_btn.Text = nx_widestr(util_format_string("ui_yes"))
  dialog.cancel_btn.Text = nx_widestr(util_format_string("ui_no"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_home", CLIENT_SUB_DEL_NEIGHBOUR, nx_string(home_id))
  end
end
function menu_delete_visit_friend_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "home_id") then
    return
  end
  local home_id = menu_game.home_id
  local player_id = menu_game.player_id
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetText("ui_delete_home_neighbor"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog.ok_btn.Text = nx_widestr(util_format_string("ui_yes"))
  dialog.cancel_btn.Text = nx_widestr(util_format_string("ui_no"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_home", CLIENT_SUB_DEL_VISITORS, nx_string(home_id), nx_string(player_id))
  end
end
function menu_add_friend_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "home_id") then
    return
  end
  nx_execute("custom_sender", "custom_home", CLIENT_SUB_ADD_NEIGHBOUR, nx_string(menu_game.home_id))
end
function menu_steal_home_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "home_id") then
    return
  end
  nx_execute("custom_sender", "custom_home", CLIENT_SUB_ENTRY, nx_string(menu_game.home_id), 3)
end
function menu_invite_guild_war_click(menu_game)
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(select_obj) then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local self_guild = player_obj:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(self_guild), nx_widestr("")) == true and nx_ws_equal(nx_widestr(self_guild), nx_widestr("0")) == true then
    return
  end
  local guild_name = select_obj:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(guild_name), nx_widestr("")) == true or nx_ws_equal(nx_widestr(guild_name), nx_widestr("0")) == true then
    return
  end
  if nx_ws_equal(nx_widestr(guild_name), nx_widestr(self_guild)) == false then
    return
  end
  local CLIENT_SUBMSG_ADD_GUILDWAR_MEMBER = 43
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_ADD_GUILDWAR_MEMBER), select_obj:QueryProp("Name"))
  end
end
function menu_ssg_yjp_qqss_click(menu_game)
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(select_obj) then
    return
  end
  nx_execute("custom_sender", "custom_ssg_yjp", nx_int(1), select_obj:QueryProp("Name"))
end
function menu_goto_home_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "home_signid") then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if trace_flag == 1 or trace_flag == 2 then
    local home_sceneid = home_manager:GetHomeSceneID(nx_int(menu_game.home_signid))
    local home_x = home_manager:GetHomeX(nx_int(menu_game.home_signid))
    local home_y = home_manager:GetHomeY(nx_int(menu_game.home_signid))
    local home_z = home_manager:GetHomeZ(nx_int(menu_game.home_signid))
    path_finding:FindPathScene(get_scene_name(home_sceneid), home_x, home_y, home_z, 0)
  end
end
function get_scene_name(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    return
  end
  return ini:ReadString(0, nx_string(index), "")
end
function menu_chat_panel_rtm_invite_click(self)
  if nx_is_valid(self) and nx_find_custom(self, "target") and nx_is_valid(self.target) then
    local item = self.target
    if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") then
      local player_name = item.lbl_name.Text
      nx_execute("custom_sender", "custom_rtm_invite_help", nx_widestr(player_name))
    end
  end
  menu_close_click()
end
function menu_open_auction_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "config") or not nx_find_custom(menu_game, "item_name") then
    return
  end
  nx_execute("form_stage_main\\form_auction\\form_auction_main", "open_form")
  local form_auction = nx_value("form_stage_main\\form_auction\\form_auction_main")
  if not nx_is_valid(form_auction) then
    return
  end
  form_auction.config = menu_game.config
  form_auction.search_word = nx_widestr(menu_game.item_name)
  nx_execute("form_stage_main\\form_auction\\form_auction_main", "send_search", form_auction)
  menu_close_click()
end
function menu_open_market_click(menu_game)
  if not nx_is_valid(menu_game) then
    return
  end
  if not nx_find_custom(menu_game, "config") or not nx_find_custom(menu_game, "item_name") then
    return
  end
  local item_name = menu_game.item_name
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_config_id = menu_game.config
  nx_execute("form_stage_main\\form_market\\form_market", "auto_show_hide_form_market", true)
  local form_market = nx_value("form_stage_main\\form_market\\form_market")
  if not nx_is_valid(form_market) then
    return
  end
  local gui = nx_value("gui")
  gui.Focused = form_market.ipt_search_key
  form_market.tree_market.SelectNode = form_market.tree_market.RootNode:FindNode(util_text("ui_market_node_" .. "1"))
  form_market.ipt_search_key.Text = nx_widestr(item_name)
  form_market.combobox_itemname.DroppedDown = false
  form_market.cur_page = 1
  form_market.search_type = 1
  form_market.item_type = 0
  form_market.combobox_itemname.config = nx_string(item_config_id)
  form_market.btn_search_key.Enabled = true
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config_id), nx_string("ItemType"))
  local color_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config_id), nx_string("ColorLevel"))
  local SUB_CLIENT_ITEM_SELECT_CONFIGID = 21
  nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_CONFIGID, nx_int(item_type), nx_int(color_level), nx_string(item_config_id))
  menu_close_click()
end
