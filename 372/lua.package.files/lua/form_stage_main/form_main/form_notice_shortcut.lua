require("util_functions")
require("util_gui")
require("util_role_prop")
local TVT_TYPE_ERROR = 0
local TVT_TYPE_COMMON = 1
local TVT_TYPE_BANGPAI = 2
local TVT_TYPE_MENPAI = 3
local TVT_TYPE_JINDI = 4
local TVT_TYPE_SHILI = 5
local TVT_TYPE_DUOSHU = 6
local TVT_TYPE_CITAN = 7
local TVT_TYPE_FANGHUO = 8
local TVT_TYPE_YUNBIAO = 9
local TVT_TYPE_XUECHOU = 10
local TVT_TYPE_HUSHU = 11
local TVT_TYPE_XUNLUO = 12
local TVT_TYPE_HAIBU = 13
local TVT_TYPE_SANLEI = 14
local TVT_TYPE_XIASHI = 15
local TVT_TYPE_BANGFEI = 16
local TVT_TYPE_WULIN = 17
local TVT_TYPE_SHOULEI = 18
local TVT_TYPE_JIUHUO = 19
local TVT_TYPE_JIEFEI = 20
local TVT_TYPE_SHIMEN = 21
local TVT_TYPE_DALEI = 22
local TVT_TYPE_BATTLE = 23
local TVT_TYPE_ZHUIZONG = 24
local TVT_TYPE_WORLDWAR = 25
local TVT_TYPE_HUASHAN = 26
local LIMIT_TVT_BOSSHELER = 27
local TVT_TYPE_JHBOSS = 28
local TVT_TYPE_JHBOSS2 = 29
local TYPE_JIUYINZHI = 30
local TVT_TYPE_SCHOOL_DANCE = 31
local TVT_TYPE_MARRY = 32
local TVT_TYPE_MARRY_BTNS = 33
local TVT_TYPE_EGWAR_START = 34
local TVT_TYPE_EGWAR_END = 35
local TVT_TYPE_EGWAR_LEAVE = 36
local TVT_XJZ_LYBS = 38
local TVT_YHG_TXCL = 39
local TVT_XUJIA_FISHING = 40
local TVT_TAOHUA_PRESENT = 41
local TVT_TAOHUA_ENEMY = 42
local TYPE_YHG_SHIER = 43
local TVT_KILLER_ADV = 44
local TVT_YIHUA_DEF = 45
local TVT_WEATHER_WAR = 46
local TVT_TYPE_PIKONGZHANG = 47
local TVT_WEATHER_SUBGROUP = 48
local TVT_GREED_ABDUCTOR = 49
local TVT_COMMON_GROUP_SCENE = 50
local TVT_WORLDWAR_COLLECT = 52
local TVT_LMBJ_DMXB = 53
local TVT_TG_RANDOM_FIGHT = 55
local TVT_CROSS_CLONE = 56
local TVT_GMDD_TOTAL = 57
local TVT_GMDD_TEST = 58
local TVT_GUMU_RESCUE = 59
local TVT_TYPE_SF_TRACEINFO = 60
local TVT_TYPE_FIGHT = 61
local TVT_NY_ITEM = 63
local TVT_FOEMAN_INFALL = 64
local TVT_WORLDLEITAI_WUDOU = 65
local TVT_ANCIENTTOMB_SMDH = 66
local TVT_BODYGUARD_SMDH = 67
local TYPE_NEW_FANGHUO = 68
local TVT_GUILD_STATION = 69
local TVT_HUASHANSCHOOL_SMDH = 70
local TVT_HUASHANSCHOOL_WXJZ = 71
local TVT_GUILD_CROSS_WAR = 72
local TVT_CHAOTIC_YANYU = 73
local TVT_SWORN = 74
local TVT_NEW_TERRITORY_PVP_1 = 75
local TVT_NEW_TERRITORY_PVP_2 = 76
local TVT_FIVE_FAIRY_GLORY = 77
local TVT_XINMO = 79
local TYPE_SSG_SCHOOLMEET = 80
local TYPE_WUJIDAO = 81
local TYPE_WXJ_SCHOOLMEET_TEST = 82
local TYPE_WUXIAN_FETE = 83
local TVT_CONQUER_DEMON = 84
local TYPE_DMP_SCHOOLMEET_TEST = 85
local TYPE_SONG_JING = 86
local TYPE_ACT_ESCORT = 87
local TYPE_YEAR_BOSS_ACT = 88
local TVT_STEAL_IN_GET_INTELLIGENCE = 89
local TVT_STEAL_IN_SAVE_HOSTAGE = 90
local TVT_OUTLAND_WAR = 91
local TVT_OUTLAND_WAR_TITLE = 92
local TVT_OUTLAND_WAR_GUIDE = 93
local TVT_SKY_HILL = 94
local TVT_PROTECT_SCHOOL = 97
local TYPE_SCHOOL_COUNTER_ATTACK = 98
local TVT_SCHOOL_EXTINCT_GUIDE = 99
local TYPE_GUILD_BOSS = 100
local TYPE_TEACH_EXAM = 101
local TYPE_ROYAL_TREASURE = 102
local TYPE_BALANCE_WAR = 103
local LIMIT_TVT_WUDAO_WAR = 104
local LIMIT_TVT_LUAN_DOU = 105
local TVT_MINGJIAO_DUILIAN = 106
local LIMIT_TVT_JYF_LOCAL_PLAYER = 107
local LIMIT_TVT_JYF_CROSS_PLAYER = 109
local LIMIT_TVT_GUILD_GLOBAL_WAR = 111
local LIMIT_TVT_WUDAO_YANWU = 112
local LIMIT_TVT_HORSE_RACE = 113
local LIMIT_TVT_SJY_SCHOOL_MEET = 114
local LIMIT_TVT_SHENJI_DRILL = 115
local LIMIT_TVT_MIDDLE_SPRING_HUNT = 116
local LIMIT_TVT_YUBI_ACTIVITY = 117
local LIMIT_TVT_GUILD_CHAMPION_WAR = 119
local LIMIT_TVT_GUILD_CHAMPION_TJ = 120
local LIMIT_TVT_MAZE_HUNT = 121
local LIMIT_TVT_XMG_SCHOOL_MEET = 122
local LIMIT_TVT_DEFEND_YG = 123
local LIMIT_TVT_LEAGUE_MATCHES = 124
local LIMIT_TVT_ROGUE = 125
local LIMIT_TVT_FLEE_IN_NIGHT = 126
local LIMIT_DREAM_LAND = 127
local TYPE_MAX = 128
local TYPEINFO = {
  [TVT_TYPE_COMMON] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png"
  },
  [TVT_TYPE_BANGPAI] = {
    "gui\\special\\btn_main\\btn_guild_out_36.png",
    "gui\\special\\btn_main\\btn_guild_on_36.png",
    "gui\\special\\btn_main\\btn_guild_checked_36.png",
    "ui_main_tips_bhz"
  },
  [TVT_TYPE_MENPAI] = {
    "gui\\special\\btn_main\\btn_menpai_out_36.png",
    "gui\\special\\btn_main\\btn_menpai_on_36.png",
    "gui\\special\\btn_main\\btn_menpai_checked_36.png",
    "ui_main_tips_mpz"
  },
  [TVT_TYPE_JINDI] = {
    "gui\\special\\btn_main\\btn_clone_out_36.png",
    "gui\\special\\btn_main\\btn_clone_on_36.png",
    "gui\\special\\btn_main\\btn_clone_checked_36.png",
    "ui_main_tips_jd"
  },
  [TVT_TYPE_SHILI] = {
    "gui\\special\\btn_main\\btn_tiguan_out_36.png",
    "gui\\special\\btn_main\\btn_tiguan_on_36.png",
    "gui\\special\\btn_main\\btn_tiguan_checked_36.png",
    "ui_main_tips_tg"
  },
  [TVT_TYPE_DUOSHU] = {
    "gui\\special\\btn_main\\btn_duoshu_out.png",
    "gui\\special\\btn_main\\btn_duoshu_on.png",
    "gui\\special\\btn_main\\btn_duoshu_checked.png",
    "ui_main_tips_ds"
  },
  [TVT_TYPE_CITAN] = {
    "gui\\special\\btn_main\\btn_citan_out.png",
    "gui\\special\\btn_main\\btn_citan_on.png",
    "gui\\special\\btn_main\\btn_citan_checked.png",
    "ui_main_tips_ct"
  },
  [TVT_TYPE_FANGHUO] = {
    "gui\\special\\btn_main\\btn_fanghuo_out.png",
    "gui\\special\\btn_main\\btn_fanghuo_on.png",
    "gui\\special\\btn_main\\btn_fanghuo_checked.png",
    "ui_main_tips_fh"
  },
  [TVT_TYPE_YUNBIAO] = {
    "gui\\special\\btn_main\\btn_yunbiao_out.png",
    "gui\\special\\btn_main\\btn_yunbiao_on.png",
    "gui\\special\\btn_main\\btn_yunbiao_checked.png",
    "ui_main_tips_yb"
  },
  [TVT_TYPE_XUECHOU] = {
    "gui\\special\\btn_main\\btn_xuechou_trace_out.png",
    "gui\\special\\btn_main\\btn_xuechou_trace_on.png",
    "gui\\special\\btn_main\\btn_xuechou_trace_checked.png",
    "ui_main_tips_xc"
  },
  [TVT_TYPE_HUSHU] = {
    "gui\\special\\btn_main\\btn_duoshu_out.png",
    "gui\\special\\btn_main\\btn_duoshu_on.png",
    "gui\\special\\btn_main\\btn_duoshu_checked.png",
    "ui_main_tips_hs"
  },
  [TVT_TYPE_XUNLUO] = {
    "gui\\special\\btn_main\\btn_citan_out.png",
    "gui\\special\\btn_main\\btn_citan_on.png",
    "gui\\special\\btn_main\\btn_citan_checked.png",
    "ui_main_tips_xl"
  },
  [TVT_TYPE_SANLEI] = {
    "gui\\special\\btn_main\\btn_leitai_out_36.png",
    "gui\\special\\btn_main\\btn_leitai_on_36.png",
    "gui\\special\\btn_main\\btn_leitai_checked_36.png",
    "ui_main_tips_sl"
  },
  [TVT_TYPE_XIASHI] = {
    "gui\\special\\btn_main\\btn_bangjia_out.png",
    "gui\\special\\btn_main\\btn_bangjia_on.png",
    "gui\\special\\btn_main\\btn_bangjia_checked.png",
    "ui_main_tips_xs"
  },
  [TVT_TYPE_BANGFEI] = {
    "gui\\special\\btn_main\\btn_bangjia_out.png",
    "gui\\special\\btn_main\\btn_bangjia_on.png",
    "gui\\special\\btn_main\\btn_bangjia_checked.png",
    "ui_main_tips_bf"
  },
  [TVT_TYPE_WULIN] = {
    "gui\\special\\btn_main\\btn_leitai_out_36.png",
    "gui\\special\\btn_main\\btn_leitai_on_36.png",
    "gui\\special\\btn_main\\btn_leitai_checked_36.png",
    "ui_main_tips_wldh"
  },
  [TVT_TYPE_SHOULEI] = {
    "gui\\special\\btn_main\\btn_leitai_out_36.png",
    "gui\\special\\btn_main\\btn_leitai_on_36.png",
    "gui\\special\\btn_main\\btn_leitai_down_36.png",
    "ui_main_tips_ssl"
  },
  [TVT_TYPE_JIUHUO] = {
    "gui\\special\\btn_main\\btn_fanghuo_out.png",
    "gui\\special\\btn_main\\btn_fanghuo_on.png",
    "gui\\special\\btn_main\\btn_fanghuo_checked.png",
    "ui_main_tips_jiuhuo"
  },
  [TVT_TYPE_JIEFEI] = {
    "gui\\special\\btn_main\\btn_yunbiao_out.png",
    "gui\\special\\btn_main\\btn_yunbiao_on.png",
    "gui\\special\\btn_main\\btn_yunbiao_checked.png",
    "ui_main_tips_jb"
  },
  [TVT_TYPE_SHIMEN] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_main_tips_smdh"
  },
  [TVT_TYPE_DALEI] = {
    "gui\\special\\btn_main\\btn_leitai_out_36.png",
    "gui\\special\\btn_main\\btn_leitai_on_36.png",
    "gui\\special\\btn_main\\btn_leitai_down_36.png",
    "ui_main_tips_ssl"
  },
  [TVT_TYPE_BATTLE] = {
    "gui\\special\\btn_main\\battle_out.png",
    "gui\\special\\btn_main\\battle_on.png",
    "gui\\special\\btn_main\\battle_down.png",
    "ui_battlefield"
  },
  [TVT_TYPE_ZHUIZONG] = {
    "gui\\special\\btn_main\\btn_zhibao_out.png",
    "gui\\special\\btn_main\\btn_zhibao_on.png",
    "gui\\special\\btn_main\\btn_zhibao_checked.png",
    "ui_main_tips_rw1"
  },
  [TVT_TYPE_WORLDWAR] = {
    "gui\\special\\btn_main\\btn_worldwar_out.png",
    "gui\\special\\btn_main\\btn_worldwar_on.png",
    "gui\\special\\btn_main\\btn_worldwar_checked.png",
    "ui_worldwar_yyzctip001"
  },
  [TVT_TYPE_HUASHAN] = {
    "gui\\language\\ChineseS\\huashan\\hslj_out.png",
    "gui\\language\\ChineseS\\huashan\\hslj_on.png",
    "gui\\language\\ChineseS\\huashan\\hslj_cheched.png",
    "ui_type26"
  },
  [LIMIT_TVT_BOSSHELER] = {
    "gui\\special\\btn_main\\killer_out.png",
    "gui\\special\\btn_main\\killer_on.png",
    "gui\\special\\btn_main\\killer_checked.png",
    "ui_type27"
  },
  [TVT_TYPE_JHBOSS] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "ui_jh_005"
  },
  [TVT_TYPE_JHBOSS2] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "ui_jh_005"
  },
  [TYPE_JIUYINZHI] = {
    "gui\\special\\btn_main\\jyz_count_01_out.png",
    "gui\\special\\btn_main\\jyz_count_01_on.png",
    "gui\\special\\btn_main\\jyz_count_01_down.png",
    "ui_jyz_type30_01"
  },
  [TVT_TYPE_MARRY] = {
    "gui\\special\\marry\\btn\\hljc_out.png",
    "gui\\special\\marry\\btn\\hljc_on.png",
    "gui\\special\\marry\\btn\\hljc_down.png",
    "tips_marrystep"
  },
  [TVT_TYPE_MARRY_BTNS] = {
    "gui\\special\\marry\\btn\\zz_out.png",
    "gui\\special\\marry\\btn\\zz_on.png",
    "gui\\special\\marry\\btn\\zz_down.png",
    "ui_marryts"
  },
  [TVT_TYPE_SF_TRACEINFO] = {
    "gui\\language\\ChineseS\\btn_main\\btn_challenge_out.png",
    "gui\\language\\ChineseS\\btn_main\\btn_challenge_on.png",
    "gui\\language\\ChineseS\\btn_main\\btn_challenge_down.png",
    "ui_schoolfight_report_tips_4"
  },
  [TVT_TYPE_SCHOOL_DANCE] = {
    "gui\\special\\btn_main\\btn_school_dance_out.png",
    "gui\\special\\btn_main\\btn_school_dance_on.png",
    "gui\\special\\btn_main\\btn_school_dance_down.png",
    "ui_type_schooldance_39"
  },
  [TVT_TYPE_EGWAR_START] = {
    "gui\\special\\match\\btn4_out.png",
    "gui\\special\\match\\btn4_on.png",
    "gui\\special\\match\\btn4_down.png",
    "ui_EGWAR"
  },
  [TVT_TYPE_EGWAR_END] = {
    "gui\\special\\match\\btn4_out.png",
    "gui\\special\\match\\btn4_on.png",
    "gui\\special\\match\\btn4_down.png",
    "ui_EGWAR"
  },
  [TVT_TYPE_EGWAR_LEAVE] = {
    "gui\\special\\match\\btn4_out.png",
    "gui\\special\\match\\btn4_on.png",
    "gui\\special\\match\\btn4_checked.png",
    "ui_EGWAR"
  },
  [TVT_XJZ_LYBS] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "info_xjz_010"
  },
  [TVT_YHG_TXCL] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "sys_yhgtxcl_title"
  },
  [TVT_TYPE_FIGHT] = {
    "gui\\language\\ChineseS\\battlefield\\battle_banner_b.png",
    "gui\\language\\ChineseS\\battlefield\\battle_banner_b.png",
    "gui\\language\\ChineseS\\battlefield\\battle_banner_b.png",
    "tips_battle_prepare"
  },
  [TVT_KILLER_ADV] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "ui_sh_001"
  },
  [TYPE_YHG_SHIER] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "tips_yhg_taofa"
  },
  [TVT_YIHUA_DEF] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "yhg_swhd_jf"
  },
  [TVT_XUJIA_FISHING] = {
    "gui\\special\\btn_main\\btn_school_dance_out.png",
    "gui\\special\\btn_main\\btn_school_dance_on.png",
    "gui\\special\\btn_main\\btn_school_dance_down.png",
    "ui_xujia_fishing"
  },
  [TVT_TAOHUA_PRESENT] = {
    "gui\\special\\forceschool\\force_qzyb_out.png",
    "gui\\special\\forceschool\\force_qzyb_on.png",
    "gui\\special\\forceschool\\force_qzyb_down.png",
    "ui_taohua_present"
  },
  [TVT_TAOHUA_ENEMY] = {
    "gui\\special\\forceschool\\force_edrq_out.png",
    "gui\\special\\forceschool\\force_edrq_on.png",
    "gui\\special\\forceschool\\force_edrq_down.png",
    "ui_taohua_enemy"
  },
  [TVT_WEATHER_WAR] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "tianqi_jianghu_1"
  },
  [TVT_TYPE_PIKONGZHANG] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "thd_pikongzhang"
  },
  [TVT_WEATHER_SUBGROUP] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "tianqi_jianghu_1"
  },
  [TVT_GREED_ABDUCTOR] = {
    "gui\\special\\btn_main\\btn_abduct_out.png",
    "gui\\special\\btn_main\\btn_abduct_on.png",
    "gui\\special\\btn_main\\btn_abduct_down.png",
    "tvt_abduct_1"
  },
  [TVT_COMMON_GROUP_SCENE] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    ""
  },
  [TVT_NY_ITEM] = {
    "gui\\special\\btn_main\\btn_role_out_36.png",
    "gui\\special\\btn_main\\btn_role_on_36.png",
    "gui\\special\\btn_main\\btn_role_down_36.png",
    "ui_worldwar_lxc_status"
  },
  [TVT_WORLDWAR_COLLECT] = {
    "gui\\special\\btn_main\\btn_worldwar_out.png",
    "gui\\special\\btn_main\\btn_worldwar_on.png",
    "gui\\special\\btn_main\\btn_worldwar_checked.png",
    "ui_lxc_collect"
  },
  [TVT_LMBJ_DMXB] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "ui_main_tips_damoxingbiao"
  },
  [TVT_GMDD_TOTAL] = {
    "gui\\special\\btn_main\\hzdd_out.png",
    "gui\\special\\btn_main\\hzdd_on.png",
    "gui\\special\\btn_main\\hzdd_down.png",
    "ui_tips_gmdd_total"
  },
  [TVT_GMDD_TEST] = {
    "gui\\special\\btn_main\\hzdd_out.png",
    "gui\\special\\btn_main\\hzdd_on.png",
    "gui\\special\\btn_main\\hzdd_down.png",
    "ui_tips_gmdd_test"
  },
  [TVT_GUMU_RESCUE] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "tips_qqzr_btn"
  },
  [TVT_TG_RANDOM_FIGHT] = {
    "gui\\special\\btn_main\\btn_tiguan_out_36.png",
    "gui\\special\\btn_main\\btn_tiguan_on_36.png",
    "gui\\special\\btn_main\\btn_tiguan_checked_36.png",
    "ui_tips_tiguan_day"
  },
  [TVT_FOEMAN_INFALL] = {
    "gui\\special\\btn_main\\btn_bangpaizhan_out_36.png",
    "gui\\special\\btn_main\\btn_bangpaizhan_on_36.png",
    "gui\\special\\btn_main\\btn_bangpaizhan_checked_36.png",
    "ui_main_tips_wkrq"
  },
  [TVT_WORLDLEITAI_WUDOU] = {
    "gui\\special\\btn_main\\btn_wudou_out.png",
    "gui\\special\\btn_main\\btn_wudou_on.png",
    "gui\\special\\btn_main\\btn_wudou_down.png",
    "ui_main_tips_wudou"
  },
  [TVT_ANCIENTTOMB_SMDH] = {
    "gui\\special\\btn_main\\btn_newschool_smdh_out.png",
    "gui\\special\\btn_main\\btn_newschool_smdh_on.png",
    "gui\\special\\btn_main\\btn_newschool_smdh_down.png",
    "ui_newschool_smdh_tips"
  },
  [TVT_BODYGUARD_SMDH] = {
    "gui\\special\\btn_main\\btn_newschool_smdh_out.png",
    "gui\\special\\btn_main\\btn_newschool_smdh_on.png",
    "gui\\special\\btn_main\\btn_newschool_smdh_down.png",
    "ui_newschool_smdh_tips"
  },
  [TYPE_NEW_FANGHUO] = {
    "gui\\special\\btn_main\\btn_fanghuo_out.png",
    "gui\\special\\btn_main\\btn_fanghuo_on.png",
    "gui\\special\\btn_main\\btn_fanghuo_checked.png",
    "ui_main_tips_fh"
  },
  [TVT_GUILD_STATION] = {
    "gui\\special\\btn_main40rh\\btn_guild_war_out.png",
    "gui\\special\\btn_main40rh\\btn_guild_war_on.png",
    "gui\\special\\btn_main40rh\\btn_guild_war_down.png",
    "ui_guild_station_tips"
  },
  [TVT_HUASHANSCHOOL_SMDH] = {
    "gui\\special\\btn_main\\btn_newschool_smdh_out.png",
    "gui\\special\\btn_main\\btn_newschool_smdh_on.png",
    "gui\\special\\btn_main\\btn_newschool_smdh_down.png",
    "ui_newschool_smdh_tips"
  },
  [TVT_HUASHANSCHOOL_WXJZ] = {
    "gui\\special\\btn_main\\btn_hsp_wxjz_out.png",
    "gui\\special\\btn_main\\btn_hsp_wxjz_on.png",
    "gui\\special\\btn_main\\btn_hsp_wxjz_down.png",
    "ui_hsp_wxjz_tips"
  },
  [TVT_NEW_TERRITORY_PVP_1] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "tianqi_jianghu_1"
  },
  [TVT_NEW_TERRITORY_PVP_2] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "tianqi_jianghu_1"
  },
  [TVT_XINMO] = {
    "gui\\special\\btn_main40rh\\btn_xmqy_out.png",
    "gui\\special\\btn_main40rh\\btn_xmqy_on.png",
    "gui\\special\\btn_main40rh\\btn_xmqy_down.png",
    "ui_xmqy_tips"
  },
  [TYPE_SSG_SCHOOLMEET] = {
    "gui\\special\\btn_main40rh\\btn_schoolwar_out.png",
    "gui\\special\\btn_main40rh\\btn_schoolwar_on.png",
    "gui\\special\\btn_main40rh\\btn_schoolwar_down.png",
    "ui_ssg_smdh"
  },
  [TVT_CHAOTIC_YANYU] = {
    "gui\\special\\btn_main\\btn_bangjia_out.png",
    "gui\\special\\btn_main\\btn_bangjia_on.png",
    "gui\\special\\btn_main\\btn_bangjia_down.png",
    "ui_yyzl"
  },
  [TVT_SWORN] = {
    "gui\\special\\btn_main40rh\\btn_sworn_out.png",
    "gui\\special\\btn_main40rh\\btn_sworn_on.png",
    "gui\\special\\btn_main40rh\\btn_sworn_down.png",
    "ui_sworn"
  },
  [TVT_FIVE_FAIRY_GLORY] = {
    "gui\\special\\btn_main40rh\\btn_wxj_ryzz_out.png",
    "gui\\special\\btn_main40rh\\btn_wxj_ryzz_on.png",
    "gui\\special\\btn_main40rh\\btn_wxj_ryzz_down.png",
    "ui_wxj_ryzz"
  },
  [TVT_GUILD_CROSS_WAR] = {
    "gui\\guild\\guildwar\\guild_war_out.png",
    "gui\\guild\\guildwar\\guild_war_on.png",
    "gui\\guild\\guildwar\\guild_war_down.png",
    "ui_kuafu_item_xuanfukuang_01"
  },
  [TYPE_WUJIDAO] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_down_36.png",
    "tips_wjd_gc"
  },
  [TYPE_WXJ_SCHOOLMEET_TEST] = {
    "gui\\special\\btn_main40rh\\btn_schoolwar_out.png",
    "gui\\special\\btn_main40rh\\btn_schoolwar_on.png",
    "gui\\special\\btn_main40rh\\btn_schoolwar_down.png",
    "ui_wxj_smdh"
  },
  [TYPE_WUXIAN_FETE] = {
    "gui\\special\\btn_main\\jyz_count_01_out.png",
    "gui\\special\\btn_main\\jyz_count_01_on.png",
    "gui\\special\\btn_main\\jyz_count_01_down.png",
    "ui_tips_jsdd_total"
  },
  [TVT_CONQUER_DEMON] = {
    "gui\\special\\btn_main40rh\\btn_dmp_fyxm_out.png",
    "gui\\special\\btn_main40rh\\btn_dmp_fyxm_on.png",
    "gui\\special\\btn_main40rh\\btn_dmp_fyxm_down.png",
    "ui_tips_dmp_fyxm"
  },
  [TYPE_DMP_SCHOOLMEET_TEST] = {
    "gui\\special\\btn_main40rh\\btn_schoolwar_out.png",
    "gui\\special\\btn_main40rh\\btn_schoolwar_on.png",
    "gui\\special\\btn_main40rh\\btn_schoolwar_down.png",
    "ui_dmp_smdh"
  },
  [TYPE_SONG_JING] = {
    "gui\\special\\btn_main\\btn_school_dance_out.png",
    "gui\\special\\btn_main\\btn_school_dance_on.png",
    "gui\\special\\btn_main\\btn_school_dance_down.png",
    "ui_Type86"
  },
  [TYPE_ACT_ESCORT] = {
    "gui\\special\\btn_main40rh\\btn_act_escort_out.png",
    "gui\\special\\btn_main40rh\\btn_act_escort_on.png",
    "gui\\special\\btn_main40rh\\btn_act_escort_down.png",
    "ui_tips_act_escort"
  },
  [TYPE_YEAR_BOSS_ACT] = {
    "gui\\special\\btn_main\\btn_ns_out.png",
    "gui\\special\\btn_main\\btn_ns_on.png",
    "gui\\special\\btn_main\\btn_ns_down.png",
    "ui_type_yearboss"
  },
  [TVT_STEAL_IN_GET_INTELLIGENCE] = {
    "gui\\special\\btn_main\\btn_citan_out.png",
    "gui\\special\\btn_main\\btn_citan_on.png",
    "gui\\special\\btn_main\\btn_citan_down.png",
    "ui_type_steal_in_get_intelligence"
  },
  [TVT_STEAL_IN_SAVE_HOSTAGE] = {
    "gui\\special\\btn_main\\btn_citan_out.png",
    "gui\\special\\btn_main\\btn_citan_on.png",
    "gui\\special\\btn_main\\btn_citan_down.png",
    "ui_type_steal_in_save_hostage"
  },
  [TVT_OUTLAND_WAR] = {
    "gui\\special\\Outlandwar\\btn_outland_war_out.png",
    "gui\\special\\Outlandwar\\btn_outland_war_on.png",
    "gui\\special\\Outlandwar\\btn_outland_war_down.png",
    "ui_tips_outland_war"
  },
  [TVT_OUTLAND_WAR_TITLE] = {
    "gui\\special\\outland\\daoout.png",
    "gui\\special\\outland\\daoon.png",
    "gui\\special\\outland\\daoout.png",
    "newworld_erengu_systeminfo_000"
  },
  [TVT_OUTLAND_WAR_GUIDE] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_tips_outland_war_guide"
  },
  [TVT_SKY_HILL] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_tips_skyhill"
  },
  [TVT_PROTECT_SCHOOL] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_tips_protect_school"
  },
  [TYPE_SCHOOL_COUNTER_ATTACK] = {
    "gui\\special\\btn_main\\mmzw_mpfg_out.png",
    "gui\\special\\btn_main\\mmzw_mpfg_on.png",
    "gui\\special\\btn_main\\mmzw_mpfg_down.png",
    "ui_mmzw_mpfg_tubiao_01"
  },
  [TVT_SCHOOL_EXTINCT_GUIDE] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_tips_school_extinct_guide"
  },
  [TYPE_GUILD_BOSS] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_tips_guild_boss"
  },
  [TYPE_TEACH_EXAM] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_tips_teach_exam"
  },
  [TYPE_BALANCE_WAR] = {
    "gui\\special\\btn_main\\battle_out.png",
    "gui\\special\\btn_main\\battle_on.png",
    "gui\\special\\btn_main\\battle_down.png",
    "ui_battlefield"
  },
  [TYPE_ROYAL_TREASURE] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_tips_wcbz"
  },
  [LIMIT_TVT_WUDAO_WAR] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "ui_tips_wddh_gui"
  },
  [LIMIT_TVT_LUAN_DOU] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "tips_chos_war_tips"
  },
  [TVT_MINGJIAO_DUILIAN] = {
    "gui\\animations\\mingjiaoduilian\\out.png",
    "gui\\animations\\mingjiaoduilian\\on.png",
    "gui\\animations\\mingjiaoduilian\\down.png",
    "ui_tips_mjdl_gui"
  },
  [LIMIT_TVT_JYF_LOCAL_PLAYER] = {
    "gui\\special\\btn_main\\btn_schoolwar_out.png",
    "gui\\special\\btn_main\\btn_schoolwar_on.png",
    "gui\\special\\btn_main\\btn_schoolwar_down.png",
    "tips_jiuyang_faculty"
  },
  [LIMIT_TVT_JYF_CROSS_PLAYER] = {
    "gui\\special\\btn_main\\btn_schoolwar_out.png",
    "gui\\special\\btn_main\\btn_schoolwar_on.png",
    "gui\\special\\btn_main\\btn_schoolwar_down.png",
    "tips_jiuyang_faculty"
  },
  [LIMIT_TVT_GUILD_GLOBAL_WAR] = {
    "gui\\special\\btn_main\\btn_guild_out_36.png",
    "gui\\special\\btn_main\\btn_guild_on_36.png",
    "gui\\special\\btn_main\\btn_guild_checked_36.png",
    "ui_main_tips_bhz"
  },
  [LIMIT_TVT_WUDAO_YANWU] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "tips_testskill_tips"
  },
  [LIMIT_TVT_SJY_SCHOOL_MEET] = {
    "gui\\special\\btn_main\\btn_worldwar_out.png",
    "gui\\special\\btn_main\\btn_worldwar_on.png",
    "gui\\special\\btn_main\\btn_worldwar_checked.png",
    "tips_sjy_school_met_tips"
  },
  [LIMIT_TVT_HORSE_RACE] = {
    "gui\\special\\btn_main\\btn_schoolwar_out_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_on_36.png",
    "gui\\special\\btn_main\\btn_schoolwar_checked_36.png",
    "tips_horse_race_tips"
  },
  [LIMIT_TVT_SHENJI_DRILL] = {
    "gui\\special\\btn_main\\btn_citan_out.png",
    "gui\\special\\btn_main\\btn_citan_on.png",
    "gui\\special\\btn_main\\btn_citan_checked.png",
    "tips_sjy_drill"
  },
  [LIMIT_TVT_MIDDLE_SPRING_HUNT] = {
    "gui/special/btn_main/btn_newschool_smdh_out.png",
    "gui/special/btn_main/btn_newschool_smdh_on.png",
    "gui/special/btn_main/btn_newschool_smdh_down.png",
    "tips_middle_spring_hunt"
  },
  [LIMIT_TVT_YUBI_ACTIVITY] = {
    "gui\\special\\btn_main\\btn_schoolwar_out.png",
    "gui\\special\\btn_main\\btn_schoolwar_on.png",
    "gui\\special\\btn_main\\btn_schoolwar_down.png",
    "tips_yubi_activity"
  },
  [LIMIT_TVT_GUILD_CHAMPION_WAR] = {
    "gui\\special\\btn_main\\battle_out.png",
    "gui\\special\\btn_main\\battle_on.png",
    "gui\\special\\btn_main\\battle_down.png",
    "tips_guild_champion_war"
  },
  [LIMIT_TVT_MAZE_HUNT] = {
    "gui\\special\\btn_main\\battle_out.png",
    "gui\\special\\btn_main\\battle_on.png",
    "gui\\special\\btn_main\\battle_down.png",
    "tips_maze_hunt_activity"
  },
  [LIMIT_TVT_XMG_SCHOOL_MEET] = {
    "gui\\special\\btn_main\\btn_worldwar_out.png",
    "gui\\special\\btn_main\\btn_worldwar_on.png",
    "gui\\special\\btn_main\\btn_worldwar_checked.png",
    "tips_xmg_school_met_tips"
  },
  [LIMIT_TVT_DEFEND_YG] = {
    "gui\\special\\btn_main\\btn_dyyg_out.png",
    "gui\\special\\btn_main\\btn_dyyg_on.png",
    "gui\\special\\btn_main\\btn_dyyg_down.png",
    "tips_dyyg_tips"
  },
  [LIMIT_TVT_LEAGUE_MATCHES] = {
    "gui\\special\\btn_main\\btn_bhls_out.png",
    "gui\\special\\btn_main\\btn_bhls_on.png",
    "gui\\special\\btn_main\\btn_bhls_down.png",
    "tips_bhls_tips"
  },
  [LIMIT_TVT_ROGUE] = {
    "gui\\special\\btn_main\\btn_rogue_out.png",
    "gui\\special\\btn_main\\btn_rogue_on.png",
    "gui\\special\\btn_main\\btn_rogue_down.png",
    "tips_btn_rogue_tips"
  },
  [LIMIT_TVT_FLEE_IN_NIGHT] = {
    "gui\\special\\btn_main\\btn_dryy_out.png",
    "gui\\special\\btn_main\\btn_dyrr_on.png",
    "gui\\special\\btn_main\\btn_dryy_down.png",
    "tips_dryy_tips"
  },
  [LIMIT_DREAM_LAND] = {
    "gui\\special\\btn_main\\btn_dreamland_out.png",
    "gui\\special\\btn_main\\btn_dreamland_on.png",
    "gui\\special\\btn_main\\btn_dreamland_down.png",
    "tips_dreamland_tips"
  }
}
local FORM = "form_stage_main\\form_main\\form_notice_shortcut"
local MAX_NUM = 5
function main_form_init(self)
  self.Fixed = false
  self.LimitInScreen = true
  self.single_notice = ","
  self.common_notice = ","
end
function on_main_form_open(self)
  refresh_form_size()
  load_notice_shortcut_location(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", self, nx_current(), "update_newjh_notice_ui")
  end
end
function on_main_form_close(self)
  local gui = nx_value("gui")
  for i = 2, MAX_NUM do
    local lbl = self.groupbox_main:Find("lbl_base" .. nx_string(i))
    local cbtn = self.groupbox_main:Find("cbtn_base" .. nx_string(i))
    if nx_is_valid(lbl) then
      self.groupbox_main:Remove(lbl)
      gui:Delete(lbl)
    end
    if nx_is_valid(cbtn) then
      self.groupbox_main:Remove(cbtn)
      gui:Delete(cbtn)
      self.lbl_back.Width = self.lbl_back.Width - 40
      self.groupbox_main.Width = self.lbl_back.Width + 10
    end
  end
end
function on_main_form_shut(self)
  save_notice_shortcut_location(self)
end
function on_cbtn_base_checked_changed(cbtn)
  local form_task = nx_value("form_stage_main\\form_task\\form_task_trace")
  if nx_is_valid(form_task) then
    form_task.Visible = cbtn.Checked
  end
  adj_form_pos(form_task)
  if cbtn.Checked then
    check_groupbox_checkstate(cbtn)
  end
end
function on_cbtn_checked_changed(cbtn)
  if cbtn.Checked then
    check_groupbox_checkstate(cbtn)
  end
  local notice_type = cbtn.NOTICE_TYPE
  local tvt_type = cbtn.TVT_TYPE
  if nx_number(tvt_type) == TVT_TYPE_SF_TRACEINFO then
    local form_sf_msg = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_school_fight\\form_school_fight_message", false, false)
    if nx_is_valid(form_sf_msg) then
      form_sf_msg.Visible = cbtn.Checked
    end
    return 0
  end
  if nx_number(tvt_type) == TVT_TYPE_MARRY then
    local form_marry_trace = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_marry\\form_marry_trace", false, false)
    if nx_is_valid(form_marry_trace) then
      form_marry_trace.Visible = cbtn.Checked
    end
    return 0
  end
  if nx_number(tvt_type) == TVT_TYPE_MARRY_BTNS then
    local form_marry_btns = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_marry\\form_marry_btns", false, false)
    if nx_is_valid(form_marry_btns) then
      form_marry_btns.Visible = cbtn.Checked
    end
    return 0
  end
  if nx_number(tvt_type) == TVT_OUTLAND_WAR_TITLE then
    local form_outland_title = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_outland\\form_outland_eren_war_title", false, false)
    if nx_is_valid(form_outland_title) then
      form_outland_title.Visible = cbtn.Checked
    end
    return 0
  end
  local scr_form = "form_stage_main\\form_common_notice"
  local FormInstanceID = "CommonNoteForm"
  if cbtn.NOTICE_TYPE ~= 0 then
    FormInstanceID = "SingleNoticeForm"
    scr_form = "form_stage_main\\form_single_notice"
  end
  local instanceid = nx_string(FormInstanceID) .. nx_string(tvt_type)
  local sub_form = nx_execute("util_gui", "util_get_form", scr_form, false, false, instanceid)
  if nx_is_valid(sub_form) then
    sub_form.Visible = cbtn.Checked
    sub_form.showformflag = cbtn.Checked
    adj_form_pos(sub_form)
    if nx_int(tvt_type) == nx_int(TVT_TYPE_JHBOSS2) then
      local boss_form = nx_value("form_stage_main\\form_task\\form_JiangHu_Boss")
      local boss_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_JiangHu_Boss", false, false)
      if nx_is_valid(boss_form) then
        boss_form.Visible = cbtn.Checked
      end
    end
  end
end
function check_groupbox_checkstate(cbtn)
  if not nx_is_valid(cbtn) or not cbtn.Checked then
    return
  end
  local groupbox = cbtn.Parent
  if not nx_is_valid(groupbox) then
    return
  end
  if nx_name(groupbox) ~= "GroupBox" then
    return
  end
  local obj_list = groupbox:GetChildControlList()
  for _, obj in pairs(obj_list) do
    if not (nx_is_valid(obj) and "CheckButton" == nx_name(obj) and obj.Checked) or nx_id_equal(cbtn, obj) or nx_find_custom(obj, "NOTICE_TYPE") and nx_find_custom(obj, "TVT_TYPE") and 1 == obj.NOTICE_TYPE and TVT_TYPE_FIGHT == nx_number(obj.TVT_TYPE) then
    else
      obj.Checked = false
    end
  end
end
function adj_form_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local form_self = nx_value(nx_current())
  if not nx_is_valid(form_self) then
    return
  end
  form.AbsLeft = form_self.AbsLeft
  form.AbsTop = form_self.AbsTop + form_self.Height
end
function add_form(notice_type, tvt_type)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local single_notice_str = form.single_notice
  local common_notice_str = form.common_notice
  if notice_type == 0 then
    if string.find(common_notice_str, "," .. nx_string(tvt_type) .. ",") then
      return
    end
    form.common_notice = form.common_notice .. nx_string(tvt_type) .. ","
  else
    if string.find(single_notice_str, "," .. nx_string(tvt_type) .. ",") then
      return
    end
    if tvt_type == TVT_TYPE_SCHOOL_DANCE then
      return
    end
    form.single_notice = form.single_notice .. nx_string(tvt_type) .. ","
  end
  refresh_form_size()
end
function del_form(notice_type, tvt_type)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  if notice_type == 0 then
    form.common_notice = string.gsub(form.common_notice, "," .. nx_string(tvt_type), "")
  else
    form.single_notice = string.gsub(form.single_notice, "," .. nx_string(tvt_type), "")
  end
  refresh_form_size()
end
function check_cbtn_state(notice_type, tvt_type)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  for i = 2, MAX_NUM do
    local cbtn = form.groupbox_main:Find("cbtn_base" .. nx_string(i))
    if nx_is_valid(cbtn) and nx_string(cbtn.NOTICE_TYPE) == nx_string(notice_type) and nx_string(cbtn.TVT_TYPE) == nx_string(tvt_type) then
      cbtn.Checked = false
      return
    end
  end
end
function change_form_size()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  if form.Left + form.Width > desktop.Width or form.Top + form.Height > desktop.Height then
    form.Left = desktop.Width - form.Width - 180
    form.Top = (desktop.Height - form.Height) / 4
  end
end
function refresh_form_size()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  for i = 2, MAX_NUM do
    local lbl = form.groupbox_main:Find("lbl_base" .. nx_string(i))
    local cbtn = form.groupbox_main:Find("cbtn_base" .. nx_string(i))
    if nx_is_valid(lbl) then
      form.groupbox_main:Remove(lbl)
      gui:Delete(lbl)
    end
    if nx_is_valid(cbtn) then
      form.groupbox_main:Remove(cbtn)
      gui:Delete(cbtn)
      form.lbl_back.Width = form.lbl_back.Width - 40
      form.groupbox_main.Width = form.lbl_back.Width + 10
    end
  end
  local single_notice_str = form.single_notice
  local common_notice_str = form.common_notice
  local single_list = util_split_string(single_notice_str, ",")
  local common_list = util_split_string(common_notice_str, ",")
  local num = 2
  for i = 1, table.getn(single_list) do
    if single_list[i] ~= "" and num < MAX_NUM then
      local lbl = gui:Create("Label")
      lbl.Name = "lbl_base" .. nx_string(num)
      lbl.Left = form.lbl_base.Left + (form.lbl_base.Width + 5) * (num - 1)
      lbl.Top = form.lbl_base.Top
      lbl.Width = form.lbl_base.Width
      lbl.Height = form.lbl_base.Height
      lbl.BackImage = form.lbl_base.BackImage
      form.groupbox_main:Add(lbl)
      local cbtn = gui:Create("CheckButton")
      cbtn.Name = "cbtn_base" .. nx_string(num)
      cbtn.Left = form.cbtn_base.Left + (form.cbtn_base.Width + 3) * (num - 1)
      cbtn.Top = form.cbtn_base.Top
      cbtn.Width = form.cbtn_base.Width
      cbtn.Height = form.cbtn_base.Height
      cbtn.DrawMode = form.cbtn_base.DrawMode
      cbtn.NOTICE_TYPE = 1
      cbtn.TVT_TYPE = single_list[i]
      local image_info = TYPEINFO[nx_number(cbtn.TVT_TYPE)]
      if image_info ~= nil then
        cbtn.NormalImage = image_info[1]
        cbtn.FocusImage = image_info[2]
        cbtn.CheckedImage = image_info[3]
        if image_info[4] ~= nil then
          cbtn.HintText = nx_widestr(util_text(image_info[4]))
        end
      end
      form.lbl_back.Width = form.lbl_back.Width + 40
      form.groupbox_main.Width = form.lbl_back.Width + 10
      form.groupbox_main:Add(cbtn)
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_checked_changed")
      cbtn.Checked = true
      num = num + 1
    end
  end
  for i = 1, table.getn(common_list) do
    if common_list[i] ~= "" and num < MAX_NUM then
      local lbl = gui:Create("Label")
      lbl.Name = "lbl_base" .. nx_string(num)
      lbl.Left = form.lbl_base.Left + (form.lbl_base.Width + 5) * (num - 1)
      lbl.Top = form.lbl_base.Top
      lbl.Width = form.lbl_base.Width
      lbl.Height = form.lbl_base.Height
      lbl.BackImage = form.lbl_base.BackImage
      form.groupbox_main:Add(lbl)
      local cbtn = gui:Create("CheckButton")
      cbtn.Name = "cbtn_base" .. nx_string(num)
      cbtn.Left = form.cbtn_base.Left + (form.cbtn_base.Width + 3) * (num - 1)
      cbtn.Top = form.cbtn_base.Top
      cbtn.Width = form.cbtn_base.Width
      cbtn.Height = form.cbtn_base.Height
      cbtn.DrawMode = form.cbtn_base.DrawMode
      cbtn.NOTICE_TYPE = 0
      cbtn.TVT_TYPE = common_list[i]
      local image_info = TYPEINFO[nx_number(cbtn.TVT_TYPE)]
      if image_info ~= nil then
        cbtn.NormalImage = image_info[1]
        cbtn.FocusImage = image_info[2]
        cbtn.CheckedImage = image_info[3]
        if image_info[4] ~= nil then
          cbtn.HintText = nx_widestr(util_text(image_info[4]))
        end
      end
      form.lbl_back.Width = form.lbl_back.Width + 40
      form.groupbox_main.Width = form.lbl_back.Width + 10
      form.groupbox_main:Add(cbtn)
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_checked_changed")
      cbtn.Checked = true
      num = num + 1
    end
  end
  form.Width = form.groupbox_main.Left + form.groupbox_main.Width + 10
end
function save_notice_shortcut_location(self)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\notice_shortcut.ini"
  ini:LoadFromFile()
  ini:WriteInteger("notice_shortcut", "Left", nx_int(self.Left))
  ini:WriteInteger("notice_shortcut", "Top", nx_int(self.Top))
  ini:SaveToFile()
  nx_destroy(ini)
end
function load_notice_shortcut_location(self)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  local l = desktop.Width - self.Width - 180
  local t = (desktop.Height - self.Height) / 4
  self.Left = l
  self.Top = t
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\notice_shortcut.ini"
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return
    end
    self.Left = ini:ReadInteger("notice_shortcut", "Left", l)
    self.Top = ini:ReadInteger("notice_shortcut", "Top", t)
  end
  nx_destroy(ini)
end
function update_newjh_notice_ui(form)
  if not nx_is_valid(form) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.Visible = false
  else
    form.Visible = true
  end
  return
end
