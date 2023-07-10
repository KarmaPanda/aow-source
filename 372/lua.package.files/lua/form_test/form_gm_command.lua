require("custom_sender")
require("util_functions")
require("define\\gamehand_type")
require("share\\static_data_type")
local FUN_ALL_INFO = {
  basefunc = {
    [1] = {
      "setobj,set Str DEFAULT_STR,hp,mp",
      "-1",
      "ui_luaChinese_1",
      "ui_luaChinese_2"
    },
    [2] = {
      "setobj,set Dead 0,leave_injured_state,hp,mp,set LogicState 0",
      "0",
      "ui_luaChinese_3",
      "ui_luaChinese_4"
    },
    [3] = {
      "setobj,hide",
      "0",
      "ui_luaChinese_5",
      "ui_luaChinese_6"
    },
    [4] = {
      "setobj,show",
      "0",
      "ui_luaChinese_7",
      "ui_luaChinese_8"
    },
    [5] = {
      "hp,mp",
      "0",
      "ui_luaChinese_9",
      "ui_luaChinese_10"
    },
    [6] = {
      "setobj,set MoveSpeed DEFAULT_MOVE",
      "-1",
      "ui_luaChinese_11",
      "ui_luaChinese_12"
    },
    [7] = {
      "setobj,set JumpSpeed DEFAULT_JUMP",
      "-1",
      "ui_luaChinese_13",
      "ui_luaChinese_14"
    },
    [8] = {
      "setobj,set WalkSpeed DEFAULT_WALK",
      "-1",
      "ui_luaChinese_15",
      "ui_luaChinese_16"
    },
    [9] = {
      "setobj,set Str DEFAULT_STR",
      "-1",
      "ui_luaChinese_17",
      "ui_luaChinese_18"
    },
    [10] = {
      "setobj,set Dex DEFAULT_DEX",
      "-1",
      "ui_luaChinese_19",
      "ui_luaChinese_20"
    },
    [11] = {
      "setobj,set Ing DEFAULT_ING",
      "-1",
      "ui_luaChinese_21",
      "ui_luaChinese_22"
    },
    [12] = {
      "setobj,set Spi DEFAULT_SPI",
      "-1",
      "ui_luaChinese_23",
      "ui_luaChinese_24"
    },
    [13] = {
      "setobj,set Sta DEFAULT_STA",
      "-1",
      "ui_luaChinese_25",
      "ui_luaChinese_26"
    },
    [14] = {
      "setobj,set PhyDef DEFAULT_PHYDEF",
      "-1",
      "ui_luaChinese_27",
      "ui_luaChinese_28"
    },
    [15] = {
      "setobj select",
      "0",
      "ui_luaChinese_29",
      "ui_luaChinese_30"
    },
    [16] = {
      "offlinejob",
      "0",
      "ui_luaChinese_31",
      "ui_luaChinese_32"
    },
    [17] = {
      "setobj index DEFAULF_INDEX",
      "-1",
      "ui_luaChinese_33",
      "ui_luaChinese_34"
    },
    [18] = {
      "setobj,setobj child ToolBox,child",
      "0",
      "ui_luaChinese_35",
      "ui_luaChinese_36"
    },
    [19] = {
      "setobj,setobj SkillContainer,child",
      "0",
      "ui_luaChinese_37",
      "ui_luaChinese_38"
    },
    [20] = {
      "setobj,setobj BufferContainer,child",
      "0",
      "ui_luaChinese_39",
      "ui_luaChinese_40"
    },
    [21] = {
      "setobj,setobj NeiGongContainer,child",
      "0",
      "ui_luaChinese_41",
      "ui_luaChinese_42"
    },
    [22] = {
      "setobj,setobj QingGongContainer,child",
      "0",
      "ui_luaChinese_43",
      "ui_luaChinese_44"
    },
    [23] = {
      "setobj,setobj JingMaiContainer,child",
      "0",
      "ui_luaChinese_45",
      "ui_luaChinese_46"
    },
    [24] = {
      "setobj,setobj XueWeiContainer,child",
      "0",
      "ui_luaChinese_47",
      "ui_luaChinese_48"
    },
    [25] = {
      "setobj,set CapitalType0 DEFAULF_CAP0",
      "-1",
      "ui_luaChinese_49",
      "ui_luaChinese_50"
    },
    [26] = {
      "setobj,incmoney 1 DEFAULF_CAP1",
      "-1",
      "ui_luaChinese_51",
      "ui_luaChinese_52"
    },
    [27] = {
      "setobj,incmoney 2 DEFAULF_CAP2",
      "-1",
      "ui_luaChinese_53",
      "ui_luaChinese_54"
    },
    [28] = {
      "setobj,changerepute repute_jianghu REPUT_JH",
      "-1",
      "ui_luaChinese_55",
      "ui_luaChinese_56"
    },
    [29] = {
      "setobj,changerepute repute_shaolin REPUT_SL",
      "-1",
      "ui_luaChinese_57",
      "ui_luaChinese_58"
    },
    [30] = {
      "setobj,changerepute repute_tangmen REPUT_TM",
      "-1",
      "ui_luaChinese_59",
      "ui_luaChinese_60"
    },
    [31] = {
      "setobj,addneigong ng_jh_001,addwuxuelevel ng_jh_001 10,set PKMode 2,set IsProtectGuild 0,set IsProtectSchool 0,set IsProtectCamp 0,set IsProtectGood 0,set IsProtectFriend 0",
      "0",
      "ui_luaChinese_61",
      "ui_luaChinese_62"
    },
    [32] = {
      "XXXXXXX",
      "0",
      "ui_luaChinese_63",
      "ui_luaChinese_64"
    }
  },
  reload = {
    [1] = {
      "reload_buffer_config,clear_all_buffer",
      "0",
      "ui_luaChinese_65",
      "ui_luaChinese_66"
    },
    [2] = {
      "reload_skill_config,recreate_all_skill",
      "0",
      "ui_luaChinese_67",
      "ui_luaChinese_68"
    },
    [3] = {
      "reload_transport_roadpoint",
      "0",
      "ui_luaChinese_69",
      "ui_luaChinese_70"
    },
    [4] = {
      "reload_path_resource",
      "0",
      "ui_luaChinese_71",
      "ui_luaChinese_72"
    },
    [5] = {
      "reload_qinggong_config",
      "0",
      "ui_luaChinese_73",
      "ui_luaChinese_74"
    },
    [6] = {
      "reload_neigong_config",
      "0",
      "ui_luaChinese_75",
      "ui_luaChinese_76"
    },
    [7] = {
      "reload_xuewei_config",
      "0",
      "ui_luaChinese_77",
      "ui_luaChinese_78"
    },
    [8] = {
      "reload_jingmai_config",
      "0",
      "ui_luaChinese_79",
      "ui_luaChinese_80"
    },
    [9] = {
      "reload_item_config",
      "0",
      "ui_luaChinese_81",
      "ui_luaChinese_82"
    },
    [10] = {
      "reload_normal_npc_config",
      "0",
      "ui_luaChinese_83",
      "ui_luaChinese_271"
    },
    [11] = {
      "reload_scene_npc",
      "0",
      "ui_luaChinese_84",
      "ui_luaChinese_85"
    },
    [12] = {
      "reload_clone_event",
      "0",
      "ui_luaChinese_86",
      "ui_luaChinese_87"
    },
    [13] = {
      "reload_clone_config",
      "0",
      "ui_luaChinese_88",
      "ui_luaChinese_89"
    },
    [14] = {
      "reload_path_resource",
      "0",
      "ui_luaChinese_90",
      "ui_luaChinese_91"
    },
    [15] = {
      "reload_task_resource",
      "0",
      "ui_luaChinese_92",
      "ui_luaChinese_93"
    },
    [16] = {
      "reload_lifejob_config",
      "0",
      "ui_luaChinese_94",
      "ui_luaChinese_95"
    },
    [17] = {
      "reload_option_resource",
      "0",
      "ui_luaChinese_96",
      "ui_luaChinese_97"
    },
    [18] = {
      "reload_offline_resource",
      "0",
      "ui_luaChinese_98",
      "ui_luaChinese_99"
    },
    [19] = {
      "reload_gemgame_resource",
      "0",
      "ui_luaChinese_100",
      "ui_luaChinese_101"
    },
    [20] = {
      "reload_npc_karma_resource",
      "0",
      "ui_luaChinese_102",
      "ui_luaChinese_103"
    },
    [21] = {
      "reload_item_config,reload_normal_npc_config,reload_scene_npc,reload_task_resource",
      "0",
      "ui_luaChinese_104",
      "ui_luaChinese_105"
    },
    [22] = {
      "reload_timelimit_resource",
      "0",
      "ui_luaChinese_106",
      "ui_luaChinese_107"
    },
    [23] = {
      "reload_hireshop_config",
      "0",
      "ui_luaChinese_108",
      "ui_luaChinese_109"
    },
    [24] = {
      "reload_trigger_res",
      "0",
      "ui_luaChinese_110",
      "ui_luaChinese_111"
    },
    [25] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_112",
      "ui_luaChinese_113"
    },
    [26] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_114",
      "ui_luaChinese_115"
    },
    [27] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_116",
      "ui_luaChinese_117"
    },
    [28] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_118",
      "ui_luaChinese_119"
    },
    [29] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_120",
      "ui_luaChinese_121"
    },
    [30] = {
      "dump_performance_info",
      "-1",
      "ui_luaChinese_122",
      "ui_luaChinese_123"
    },
    [31] = {
      "clear_all_buffer",
      "0",
      "ui_luaChinese_124",
      "ui_luaChinese_125"
    },
    [32] = {
      "clear_all_visible_buffer",
      "0",
      "ui_luaChinese_126",
      "ui_luaChinese_127"
    }
  },
  createobj = {
    [1] = {
      "setobj,cobjitem",
      "2",
      "ui_luaChinese_128",
      "ui_luaChinese_129"
    },
    [2] = {
      "cobj",
      "1",
      "ui_luaChinese_130",
      "ui_luaChinese_131"
    },
    [3] = {
      "del",
      "0",
      "ui_luaChinese_132",
      "ui_luaChinese_133"
    },
    [4] = {
      "addskill",
      "1",
      "ui_luaChinese_134",
      "ui_luaChinese_135"
    },
    [5] = {
      "delskill",
      "1",
      "ui_luaChinese_136",
      "ui_luaChinese_137"
    },
    [6] = {
      "add_buff",
      "1",
      "ui_luaChinese_138",
      "ui_luaChinese_139"
    },
    [7] = {
      "remove_buff",
      "1",
      "ui_luaChinese_140",
      "ui_luaChinese_141"
    },
    [8] = {
      "NEWSHOU_SKILL",
      "-2",
      "ui_luaChinese_142",
      "ui_luaChinese_143"
    },
    [9] = {
      "WUDANG_SKILL",
      "-2",
      "ui_luaChinese_144",
      "ui_luaChinese_145"
    },
    [10] = {
      "SHAOLIN_SKILL",
      "-2",
      "ui_luaChinese_146",
      "ui_luaChinese_147"
    },
    [11] = {
      "TANGMEN_SKILL",
      "-2",
      "ui_luaChinese_148",
      "ui_luaChinese_149"
    },
    [12] = {
      "setobj",
      "-1",
      "ui_wudaodahui_gm_18",
      "ui_luaChinese_151"
    },
    [13] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_152",
      "ui_luaChinese_153"
    },
    [14] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_154",
      "ui_luaChinese_155"
    },
    [15] = {
      "switch_gm_buff",
      "-1",
      "ui_luaChinese_156",
      "ui_luaChinese_157"
    },
    [16] = {
      "change_text",
      "0",
      "ui_luaChinese_158",
      "ui_luaChinese_159"
    },
    [17] = {
      "accepttask",
      "1",
      "ui_luaChinese_160",
      "ui_luaChinese_161"
    },
    [18] = {
      "giveuptask",
      "1",
      "ui_luaChinese_162",
      "ui_luaChinese_163"
    },
    [19] = {
      "clearalltask",
      "0",
      "ui_luaChinese_164",
      "ui_luaChinese_165"
    },
    [20] = {
      "create_effect",
      "1",
      "ui_luaChinese_166",
      "ui_luaChinese_167"
    },
    [21] = {
      "delete_effect",
      "1",
      "ui_luaChinese_168",
      "ui_luaChinese_169"
    },
    [22] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_170",
      "ui_luaChinese_171"
    },
    [23] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_172",
      "ui_luaChinese_173"
    },
    [24] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_174",
      "ui_luaChinese_175"
    },
    [25] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_176",
      "ui_luaChinese_177"
    },
    [26] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_178",
      "ui_luaChinese_179"
    },
    [27] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_180",
      "ui_luaChinese_181"
    },
    [28] = {
      "XXXXXXX",
      "-1",
      "ui_luaChinese_182",
      "ui_luaChinese_183"
    },
    [29] = {
      "offlinejobstart",
      "0",
      "ui_luaChinese_184",
      "ui_luaChinese_185"
    },
    [30] = {
      "offlinejobend",
      "0",
      "ui_luaChinese_186",
      "ui_luaChinese_187"
    },
    [31] = {
      "initoffLinepath",
      "1",
      "ui_luaChinese_188",
      "ui_luaChinese_189"
    },
    [32] = {
      "addofflinejob",
      "1",
      "ui_luaChinese_190",
      "ui_luaChinese_191"
    }
  }
}
local DEF_ALL_PARA = {
  [1] = {
    name = "DEFAULT_MOVE",
    value = 30
  },
  [2] = {
    name = "DEFAULT_JUMP",
    value = 30
  },
  [3] = {
    name = "DEFAULT_WALK",
    value = 10
  },
  [4] = {
    name = "DEFAULT_STR",
    value = 8000000
  },
  [5] = {
    name = "DEFAULT_DEX",
    value = 7000000
  },
  [6] = {
    name = "DEFAULT_ING",
    value = 6000000
  },
  [7] = {
    name = "DEFAULT_SPI",
    value = 5000000
  },
  [8] = {
    name = "DEFAULT_STA",
    value = 4000000
  },
  [9] = {
    name = "DEFAULT_PHYDEF",
    value = 200
  },
  [10] = {
    name = "DEFAULF_CAP0",
    value = 1000000
  },
  [11] = {
    name = "DEFAULF_CAP1",
    value = 1000000
  },
  [12] = {
    name = "DEFAULF_CAP2",
    value = 1000000
  },
  [13] = {
    name = "DEFAULF_INDEX",
    value = ""
  },
  [14] = {name = "REPUT_JH", value = 1000},
  [15] = {name = "REPUT_SL", value = 1000},
  [16] = {name = "REPUT_TM", value = 1000},
  [17] = {
    name = "NEWSHOU_SKILL",
    value = "NEWSHOU_SKILL_TABLE"
  },
  [18] = {
    name = "WUDANG_SKILL",
    value = "WUDANG_SKILL_TABLE"
  },
  [19] = {
    name = "SHAOLIN_SKILL",
    value = "SHAOLIN_SKILL_TABLE"
  },
  [20] = {
    name = "TANGMEN_SKILL",
    value = "TANGMEN_SKILL_TABLE"
  }
}
local ALL_SKILL = {
  NEWSHOU_SKILL_TABLE = {
    [1] = "addskill zs_default_01",
    [2] = "addskill zs_suicide",
    [3] = "addskill wx_base0101",
    [4] = "addskill wx_base0102",
    [5] = "addskill wx_base0103",
    [6] = "addskill wx_base0201",
    [7] = "addskill wx_base0202",
    [8] = "addskill wx_base0203",
    [9] = "addskill wx_base0301",
    [10] = "addskill wx_base0302",
    [11] = "addskill wx_base0303",
    [12] = "addskill wx_base0401",
    [13] = "addskill wx_base0402",
    [14] = "addskill wx_base0403"
  },
  WUDANG_SKILL_TABLE = {
    [1] = "addskill wx_wd_lyjf01",
    [2] = "addskill wx_wd_lyjf02",
    [3] = "addskill wx_wd_lyjf03",
    [4] = "addskill wx_wd_lyjf04",
    [5] = "addskill wx_wd_lyjf05",
    [6] = "addskill wx_wd_tjj01",
    [7] = "addskill wx_wd_tjj02",
    [8] = "addskill wx_wd_tjj03",
    [9] = "addskill wx_wd_tjj04",
    [10] = "addskill wx_wd_tjj05",
    [11] = "addskill wx_wd_tjj06",
    [12] = "addskill wx_wd_tjj07",
    [13] = "addskill wx_wd_tjq01",
    [14] = "addskill wx_wd_tjq02",
    [15] = "addskill wx_wd_tjq03",
    [16] = "addskill wx_wd_tjq04",
    [17] = "addskill wx_wd_tjq05",
    [18] = "addskill wx_wd_tjq06",
    [19] = "addskill wx_wd_tjq07",
    [20] = "addskill wx_jh_xfsy01",
    [21] = "addskill wx_jh_xfsy02",
    [22] = "addskill wx_jh_xfsy03",
    [23] = "addskill wx_jh_xfsy04",
    [24] = "addskill wx_jh_xfsy05",
    [25] = "addskill wx_jh_xfsy06",
    [26] = "addskill wx_jh_xfsy07",
    [27] = "addskill wx_jh_xfsy08",
    [28] = "addskill wx_wd_tljf01",
    [29] = "addskill wx_wd_tljf02",
    [30] = "addskill wx_wd_tljf03",
    [31] = "addskill wx_wd_tljf04",
    [32] = "addskill wx_wd_tljf05",
    [33] = "addskill wx_wd_tymz01",
    [34] = "addskill wx_wd_tymz02",
    [35] = "addskill wx_wd_tymz03",
    [36] = "addskill wx_wd_tymz04",
    [37] = "addskill wx_wd_tymz05",
    [38] = "addskill wx_wd_tymz06",
    [39] = "addskill wx_jh_jzj01",
    [40] = "addskill wx_jh_jzj02",
    [41] = "addskill wx_jh_jzj03",
    [42] = "addskill wx_jh_jzj04",
    [43] = "addskill wx_jh_jzj05",
    [44] = "addskill wx_jh_jzj06",
    [45] = "addskill wx_jh_jzj07",
    [46] = "addskill wx_jh_jzj08",
    [47] = "addskill wx_jh_quanzjf01",
    [48] = "addskill wx_jh_quanzjf02",
    [49] = "addskill wx_jh_quanzjf03",
    [50] = "addskill wx_jh_quanzjf04",
    [51] = "addskill wx_jh_quanzjf05",
    [52] = "addskill wx_jh_quanzjf06",
    [53] = "addskill wx_jh_quanzjf07",
    [54] = "addskill wx_jh_quanzjf08"
  },
  SHAOLIN_SKILL_TABLE = {
    [1] = "addskill wx_sl_dmgf01",
    [2] = "addskill wx_sl_dmgf02",
    [3] = "addskill wx_sl_dmgf03",
    [4] = "addskill wx_sl_dmgf04",
    [5] = "addskill wx_sl_dmgf07",
    [6] = "addskill wx_sl_dmgf08",
    [7] = "addskill wx_sl_lhg01",
    [8] = "addskill wx_sl_lhg02",
    [9] = "addskill wx_sl_lhg03",
    [10] = "addskill wx_sl_lhg04",
    [11] = "addskill wx_sl_lhg05",
    [12] = "addskill wx_sl_lhq01",
    [13] = "addskill wx_sl_lhq02",
    [14] = "addskill wx_sl_lhq03",
    [15] = "addskill wx_sl_lhq04",
    [16] = "addskill wx_sl_lhq05",
    [17] = "addskill wx_sl_lhq06",
    [18] = "addskill wx_sl_lhq07",
    [19] = "addskill wx_sl_tzcq01",
    [20] = "addskill wx_sl_tzcq02",
    [21] = "addskill wx_sl_tzcq03",
    [22] = "addskill wx_sl_tzcq04",
    [23] = "addskill wx_sl_tzcq05",
    [24] = "addskill wx_sl_tzcq08",
    [25] = "addskill wx_sl_lzs01",
    [26] = "addskill wx_sl_lzs02",
    [27] = "addskill wx_sl_lzs03",
    [28] = "addskill wx_sl_lzs04",
    [29] = "addskill wx_sl_lzs05",
    [30] = "addskill wx_sl_lzs06",
    [31] = "addskill wx_jh_tlq01",
    [32] = "addskill wx_jh_tlq02",
    [33] = "addskill wx_jh_tlq03",
    [34] = "addskill wx_jh_tlq04",
    [35] = "addskill wx_jh_tlq05",
    [36] = "addskill wx_jh_tlq06",
    [37] = "addskill wx_jh_tlq07",
    [38] = "addskill wx_jh_tlq08",
    [39] = "addskill wx_jh_wlbg01",
    [40] = "addskill wx_jh_wlbg02",
    [41] = "addskill wx_jh_wlbg03",
    [42] = "addskill wx_jh_wlbg04",
    [43] = "addskill wx_jh_wlbg05",
    [44] = "addskill wx_jh_wlbg06",
    [45] = "addskill wx_jh_wlbg07",
    [46] = "addskill wx_jh_wlbg08"
  },
  TANGMEN_SKILL_TABLE = {
    [1] = "addskill wx_tm_jsc01",
    [2] = "addskill wx_tm_jsc02",
    [3] = "addskill wx_tm_jsc03",
    [4] = "addskill wx_tm_jsc04",
    [5] = "addskill wx_tm_jsc05",
    [6] = "addskill wx_tm_mhb01",
    [7] = "addskill wx_tm_mhb02",
    [8] = "addskill wx_tm_mhb03",
    [9] = "addskill wx_tm_mhb04",
    [10] = "addskill wx_jy_tmzh01",
    [11] = "addskill wx_jy_tmzh02",
    [12] = "addskill wx_jy_tmzh03",
    [13] = "addskill wx_jy_tmzh04",
    [14] = "addskill wx_jy_tmzh05",
    [15] = "addskill wx_tm_fg01",
    [16] = "addskill wx_tm_fg02",
    [17] = "addskill wx_tm_fg03",
    [18] = "addskill wx_tm_fg04",
    [19] = "addskill wx_tm_fg05",
    [20] = "addskill wx_tm_fg06",
    [21] = "addskill wx_tm_dm01",
    [22] = "addskill wx_tm_dm02",
    [23] = "addskill wx_tm_dm03",
    [24] = "addskill wx_tm_dm04",
    [25] = "addskill wx_tm_dm05",
    [26] = "addskill wx_tm_dm06",
    [27] = "addskill wx_tm_cxd01",
    [28] = "addskill wx_tm_cxd02",
    [29] = "addskill wx_tm_cxd03",
    [30] = "addskill wx_tm_cxd04",
    [31] = "addskill wx_tm_cxd05",
    [32] = "addskill wx_jh_lbz01",
    [33] = "addskill wx_jh_lbz02",
    [34] = "addskill wx_jh_lbz03",
    [35] = "addskill wx_jh_lbz04",
    [36] = "addskill wx_jh_lbz05"
  }
}
local ALL_TABLE = {
  [1] = {
    "ForceRec",
    "ui_luaChinese_192"
  },
  [2] = {
    "PatrolPointRec",
    "ui_luaChinese_193"
  },
  [3] = {
    "TeamMovieRec",
    "ui_luaChinese_194"
  },
  [4] = {
    "OffLineJob",
    "ui_luaChinese_195"
  },
  [5] = {
    "OffLineJob_Log",
    "ui_luaChinese_196"
  },
  [6] = {
    "RecvLetterRec",
    "ui_luaChinese_197"
  },
  [7] = {
    "DramaRec",
    "ui_luaChinese_198"
  },
  [8] = {
    "RandomDramaRec",
    "ui_luaChinese_199"
  },
  [9] = {
    "Repute_Record",
    "ui_luaChinese_200"
  },
  [10] = {
    "Origin_Active",
    "ui_luaChinese_201"
  },
  [11] = {
    "Origin_Notify",
    "ui_luaChinese_202"
  },
  [12] = {
    "Origin_Completed",
    "ui_luaChinese_203"
  },
  [13] = {
    "Origin_Prized",
    "ui_luaChinese_204"
  },
  [14] = {
    "Origin_Record",
    "ui_luaChinese_205"
  },
  [15] = {
    "talk_rec",
    "ui_luaChinese_206"
  },
  [16] = {
    "OpenMapRec",
    "ui_luaChinese_207"
  },
  [17] = {
    "friend_rec",
    "ui_luaChinese_208"
  },
  [18] = {
    "blacklist_rec",
    "ui_luaChinese_209"
  },
  [19] = {
    "enemy_rec",
    "ui_luaChinese_210"
  },
  [20] = {
    "team_rec",
    "ui_luaChinese_211"
  },
  [21] = {
    "team_recruit_info_rec",
    "ui_luaChinese_212"
  },
  [22] = {
    "team_recruit_rec",
    "ui_luaChinese_213"
  },
  [23] = {
    "shortcut_rec",
    "ui_luaChinese_214"
  },
  [24] = {
    "title_rec",
    "ui_luaChinese_215"
  },
  [25] = {
    "attack_target_rec",
    "ui_luaChinese_216"
  },
  [26] = {
    "cooldown_rec",
    "ui_luaChinese_217"
  },
  [27] = {
    "nocooldown_team_rec",
    "ui_luaChinese_218"
  },
  [28] = {
    "nocooldown_skill_rec",
    "ui_luaChinese_219"
  },
  [29] = {
    "fight_relation_rec",
    "ui_luaChinese_220"
  },
  [30] = {
    "attack_back_rec",
    "ui_luaChinese_221"
  },
  [31] = {
    "change_prop_rec",
    "ui_luaChinese_222"
  },
  [32] = {
    "buffer_rec",
    "ui_luaChinese_223"
  },
  [33] = {
    "neigong_effect_obj_rec",
    "ui_luaChinese_224"
  },
  [34] = {
    "QingGongRec",
    "ui_luaChinese_225"
  },
  [35] = {
    "ActiveQGSkillRec",
    "ui_luaChinese_226"
  },
  [36] = {
    "job_rec",
    "ui_luaChinese_227"
  },
  [37] = {"crop_rec", "crop_rec"},
  [38] = {
    "FormulaRec",
    "ui_luaChinese_228"
  },
  [39] = {
    "clone_rec_not_save",
    "ui_luaChinese_229"
  },
  [40] = {
    "clone_rec_save",
    "ui_luaChinese_230"
  },
  [41] = {
    "PropModifyRec",
    "ui_luaChinese_231"
  },
  [42] = {
    "SkillModifyRec",
    "ui_luaChinese_232"
  },
  [43] = {
    "BuffModifyRecIn",
    "ui_luaChinese_233"
  },
  [44] = {
    "BuffModifyRecOut",
    "ui_luaChinese_234"
  },
  [45] = {
    "EquipModifyRec",
    "ui_luaChinese_235"
  },
  [46] = {
    "TaskModifyRec",
    "ui_luaChinese_236"
  },
  [47] = {
    "Count_Event_Rec",
    "ui_luaChinese_237"
  },
  [48] = {
    "Record_Event_Rec",
    "ui_luaChinese_238"
  },
  [49] = {
    "Op_CallBack_Event_Rec",
    "ui_luaChinese_239"
  },
  [50] = {
    "Timer_Event_Rec",
    "ui_luaChinese_240"
  },
  [51] = {
    "Container_Event_Rec",
    "ui_luaChinese_241"
  },
  [52] = {
    "Prop_Event_Rec",
    "ui_luaChinese_242"
  },
  [53] = {
    "specialitemtalbe",
    "ui_luaChinese_243"
  },
  [54] = {
    "Task_Accepted",
    "ui_luaChinese_244"
  },
  [55] = {
    "Task_Record",
    "ui_luaChinese_245"
  },
  [56] = {
    "Task_Completed",
    "ui_luaChinese_246"
  },
  [57] = {
    "TaskRepeatRec",
    "ui_luaChinese_247"
  },
  [58] = {
    "RoundRandomTaskRec",
    "ui_luaChinese_248"
  },
  [59] = {
    "RoundChoiceTaskRec",
    "ui_luaChinese_249"
  },
  [60] = {
    "TimeLimitRec",
    "ui_luaChinese_250"
  },
  [61] = {
    "StateTaskRec",
    "ui_luaChinese_251"
  },
  [62] = {
    "Task_Addition_Rec",
    "ui_luaChinese_252"
  },
  [63] = {
    "Task_Verify_Rec",
    "ui_luaChinese_253"
  },
  [64] = {
    "Task_Fail_OnLoad_Rec",
    "ui_luaChinese_254"
  },
  [65] = {
    "Task_Hide_Rec",
    "ui_luaChinese_255"
  },
  [66] = {
    "CmpltCloneTaskRec",
    "ui_luaChinese_256"
  },
  [67] = {
    "Plot_Record",
    "ui_luaChinese_257"
  },
  [68] = {
    "ZhenFaMemberRec",
    "ui_luaChinese_258"
  },
  [69] = {
    "OutRangeMemberRec",
    "ui_luaChinese_259"
  },
  [70] = {
    "ZhenYanRec",
    "ui_luaChinese_260"
  },
  [71] = {
    "flow_hittime_rec",
    "ui_luaChinese_261"
  },
  [72] = {
    "AIFindPathRec",
    "ui_luaChinese_262"
  },
  [73] = {
    "AIPathSceneList",
    "ui_luaChinese_263"
  },
  [74] = {
    "OfflineFindPathRec",
    "ui_luaChinese_264"
  },
  [75] = {
    "requested_guild",
    "ui_luaChinese_265"
  },
  [77] = {
    "sh_gather_vip_rec",
    "ui_luaChinese_266"
  }
}
local CTRL_BASE_LEFT = 0
local CTRL_BASE_TOP = 5
local CTRL_DISTANCE_Y = 5
local CTRL_DISTANCE_X = 3
local CTRL_BTN_WIDTH = 220
local CTRL_BTN_HEIGHT = 24
local CTRL_LBL_WIDTH = 100
local CTRL_LBL_HEIGHT = 16
function main_form_init(self)
  self.Fixed = true
  self.functype = ""
  self.no_need_motion_alpha = true
  self.string_list = nx_create("StringList")
  add_to_file(self, "", false)
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.InputBox
  self.func_grpbox.Visible = false
  self.basefunc_grpbox.load = false
  self.reload_grpbox.load = false
  self.createobj_grpbox.load = false
  self.somegms_grpbox.load = false
  self.basefunc_grpbox.functype = "basefunc"
  self.reload_grpbox.functype = "reload"
  self.createobj_grpbox.functype = "createobj"
  self.somegms_grpbox.functype = "somegms"
  self.cleardata_grpbox.functype = "cleardata"
  local gui = nx_value("gui")
  self.listbox_table:ClearString()
  for i = 1, table.getn(ALL_TABLE) do
    local text_name = gui.TextManager:GetText(ALL_TABLE[i][2])
    local text = text_name .. nx_widestr("(") .. nx_widestr(ALL_TABLE[i][1]) .. nx_widestr(")")
    self.listbox_table:AddString(nx_widestr(text))
  end
  local fs = nx_create("FileSearch")
  fs:SearchFile(nx_work_path() .. "gm\\", "*.txt")
  local file_table = fs:GetFileList()
  self.combobox_files.DropListBox:ClearString()
  for i = 1, table.getn(file_table) do
    self.combobox_files.DropListBox:AddString(nx_widestr(file_table[i]))
  end
  nx_destroy(fs)
  self.basefunc_rbtn.Checked = true
end
function on_main_form_close(self)
  local gui = nx_value("gui")
  gui.Focused = nx_null()
end
function on_inputbox_enter(self)
  if not nx_is_valid(self) then
    return 0
  end
  local info = self.Text
  local wInfo = self.Text
  if nx_ws_length(info) == 0 then
    return 0
  end
  self.Text = nx_widestr("")
  if nx_string(info) == "action_list" then
    get_action_list()
    return
  end
  info = nx_string(info)
  if nx_string(info) == "cls" then
    local form = self.ParentForm
    if nx_is_valid(form) then
      form.ListBox:ClearString()
    end
    return
  end
  local subinfo = string.sub(nx_string(info), 0, 3)
  if nx_string(subinfo) == "hd " then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    if not gui.GameHand:IsEmpty() and gui.GameHand.Type == GHT_VIEWITEM then
      local view_id = nx_number(gui.GameHand.Para1)
      local view_index = nx_number(gui.GameHand.Para2)
      local game_client = nx_value("game_client")
      if not nx_is_valid(game_client) then
        return
      end
      custom_gminfo(nx_widestr("setobj"))
      custom_gminfo(nx_widestr("setobj view " .. nx_string(view_id) .. " " .. nx_string(view_index)))
      local real_cmd = string.sub(nx_string(info), 3, string.len(nx_string(info)))
      custom_gminfo(nx_widestr(real_cmd))
    end
    return
  end
  custom_gminfo(nx_widestr(wInfo))
end
function get_action_list()
  local form_gm_command = nx_value("form_test\\form_gm_command")
  if not nx_is_valid(form_gm_command) then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  local client_player = game_client:GetPlayer()
  local actor_role = visual_player:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    actor_role = visual_player
  end
  local blend_list = actor_role:GetActionBlendList()
  for i = 1, table.getn(blend_list) do
    form_gm_command.ListBox:AddString(nx_widestr(blend_list[i]))
  end
end
function on_adjuster_drag_move(button, newX, newY)
  local form = button.ParentForm
  local listbox = form.ListBox
  local minW = 470
  local minH = 206
  local maxW = 1166
  local maxH = 790
  local top = newY
  local width = newX - listbox.AbsLeft
  local height = listbox.Height + listbox.AbsTop - newY
  if minW > width then
    width = minW
  elseif maxW < width then
    width = maxW
  end
  if minH > height then
    top = listbox.Height + listbox.AbsTop - minH
    height = minH
  elseif maxH < height then
    top = listbox.Height + listbox.AbsTop - maxH
    height = maxH
  end
  button.AbsTop = top
  button.AbsLeft = listbox.AbsLeft + width - button.Width
  listbox.AbsTop = top
  listbox.Width = width
  listbox.Height = height
end
function on_adjuster_2_drag_move(button, newX, newY)
  local mixleft = 27
  local maxright = 480
  local left = newX
  if mixleft > left then
    left = mixleft
  end
  if maxright < left then
    left = maxright
  end
  local arf = (left - mixleft) / ((maxright - mixleft) / 255)
  local listbox = button.ParentForm.ListBox
  listbox.BackColor = nx_string(arf) .. ", 255, 255, 255"
  button.AbsLeft = left
end
function on_btn_func_click(btn)
  local form = btn.ParentForm
  form.func_grpbox.Visible = not form.func_grpbox.Visible
end
function on_basefunc_rbtn_checked_changed(self)
  self.ParentForm.basefunc_grpbox.Visible = self.Checked
  update_func_ctrl(self, self.ParentForm.basefunc_grpbox)
  if self.Checked == true then
    self.ParentForm.param_edit.Visible = true
    self.ParentForm.lbl_2.Visible = true
  end
end
function on_reload_rbtn_checked_changed(self)
  self.ParentForm.reload_grpbox.Visible = self.Checked
  update_func_ctrl(self, self.ParentForm.reload_grpbox)
  if self.Checked == true then
    self.ParentForm.param_edit.Visible = true
    self.ParentForm.lbl_2.Visible = true
  end
end
function on_createobj_rbtn_checked_changed(self)
  self.ParentForm.createobj_grpbox.Visible = self.Checked
  update_func_ctrl(self, self.ParentForm.createobj_grpbox)
  if self.Checked == true then
    self.ParentForm.param_edit.Visible = true
    self.ParentForm.lbl_2.Visible = true
    local fs = nx_create("FileSearch")
    fs:SearchFile(nx_work_path() .. "gm\\", "*.txt")
    local file_table = fs:GetFileList()
    self.ParentForm.combobox_files.DropListBox:ClearString()
    for i = 1, table.getn(file_table) do
      self.ParentForm.combobox_files.DropListBox:AddString(nx_widestr(file_table[i]))
    end
    nx_destroy(fs)
  end
end
function on_somegms_rbtn_checked_changed(self)
  self.ParentForm.somegms_grpbox.Visible = self.Checked
  if self.Checked == true then
    self.ParentForm.param_edit.Visible = false
    self.ParentForm.lbl_2.Visible = false
  end
end
function on_cleardata_rbtn_checked_changed(self)
  self.ParentForm.cleardata_grpbox.Visible = self.Checked
  if self.Checked == true then
    self.ParentForm.param_edit.Visible = false
    self.ParentForm.lbl_2.Visible = false
  end
end
function on_ListBox_select_click(self, index)
  local form = self.ParentForm
  local seltext = nx_string(self.SelectString)
  form.InputBox.Text = self.SelectString
end
function update_func_ctrl(rbtn, grpbox)
  local form = rbtn.ParentForm
  if rbtn.Checked == false then
    return 0
  end
  local gui = nx_value("gui")
  form.functype = grpbox.functype
  if grpbox.load == true then
    return 0
  end
  local top = CTRL_BASE_TOP
  local left = CTRL_BASE_LEFT
  for i = 1, table.getn(FUN_ALL_INFO[form.functype]) do
    local onefun = FUN_ALL_INFO[form.functype][i]
    local text = gui.TextManager:GetText(nx_string(onefun[3]))
    local hit_text = gui.TextManager:GetText(nx_string(onefun[4]))
    create_one_ctrl(grpbox, "Button", i, text, hit_text, top, left, CTRL_BTN_WIDTH, CTRL_BTN_HEIGHT)
    top = top + CTRL_BTN_HEIGHT + CTRL_DISTANCE_Y
    if i == 16 then
      left = left + CTRL_BTN_WIDTH + CTRL_DISTANCE_X
      top = CTRL_BASE_TOP
    end
  end
  grpbox.load = true
  return 1
end
function create_one_ctrl(grpbox, ctrtype, index, text, hinttext, top, left, width, height)
  local gui = nx_value("gui")
  local ctr = gui:Create(ctrtype)
  if nx_is_valid(ctr) then
    grpbox:Add(ctr)
    ctr.Font = "GE_FONT"
    ctr.Top = top
    ctr.Left = left
    ctr.Width = width
    ctr.Height = height
    ctr.Text = nx_widestr(text)
    ctr.HintText = nx_widestr(hinttext)
    ctr.index = nx_int(index)
    if ctrtype == "Button" then
      nx_bind_script(ctr, nx_current())
      nx_callback(ctr, "on_click", "custom_btn_click")
    end
  end
  return ctr
end
function custom_btn_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local functype = form.functype
  local funcid = nx_number(self.index)
  local funcname = FUN_ALL_INFO[form.functype][nx_number(self.index)][1]
  local paramcnt = FUN_ALL_INFO[form.functype][nx_number(self.index)][2]
  local paramval = nx_string(form.param_edit.Text)
  if funcname == "dump_performance_info" then
    dump_performance_info()
    return
  end
  if functype == "basefunc" and self.index == 32 then
    form.ListBox:ClearString()
    if form.close_cbtn.Checked == false then
      form.func_grpbox.Visible = false
    end
    return
  end
  if functype == "createobj" then
    on_click_createobj_menu(self.index, paramval)
  end
  if paramcnt == "0" then
    if funcname == "change_text" then
      gui.TextManager.ShowTextID = not gui.TextManager.ShowTextID
      if gui.TextManager.UseResProcess then
        gui.TextManager.UseResProcess = false
        nx_execute("gui", "reload_text")
      end
      local childlist = gui.Desktop:GetChildControlList()
      for i = table.maxn(childlist), 1, -1 do
        local control = childlist[i]
        if nx_is_valid(control) and nx_is_kind(control, "Form") then
          control:Close()
        end
      end
      gui.Desktop:Close()
      gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_main\\form_main\\form_main.xml")
      gui.Desktop.Left = 0
      gui.Desktop.Top = 0
      gui.Desktop.Width = gui.Width
      gui.Desktop.Height = gui.Height
      gui.Desktop.Transparent = true
      gui.Desktop:ShowModal()
      return
    end
  elseif paramcnt == "-1" then
    for i = 1, table.getn(DEF_ALL_PARA) do
      local repl = paramval
      if repl == "" then
        repl = DEF_ALL_PARA[i].value
      end
      local str, cnt = string.gsub(funcname, DEF_ALL_PARA[i].name, repl)
      if 1 <= cnt then
        funcname = str
        if DEF_ALL_PARA[i].name == "DEFAULF_INDEX" and repl == "" then
          local error_text = gui.TextManager:GetText("ui_luaChinese_267")
          nx_msgbox(nx_string(error_text))
          return 0
        end
        break
      end
    end
  elseif paramcnt == "-2" then
    for i = 1, table.getn(DEF_ALL_PARA) do
      local repl = DEF_ALL_PARA[i].value
      local str, cnt = string.gsub(funcname, DEF_ALL_PARA[i].name, repl)
      if 1 <= cnt then
        funcname = str
      end
    end
  else
    if paramval == "" then
      local error_text = gui.TextManager:GetText("ui_luaChinese_268")
      nx_msgbox(nx_string(error_text))
      return 0
    end
    local params = util_split_string(paramval, " ")
    if functype ~= "createobj" and table.getn(params) ~= nx_number(paramcnt) or table.getn(params) ~= nx_number(paramcnt) and table.getn(params) ~= nx_number(paramcnt) - 1 then
      local error_text = gui.TextManager:GetText("ui_luaChinese_269")
      nx_msgbox(nx_string(error_text))
      return 0
    end
    if funcname == "create_effect" then
      local game_visual = nx_value("game_visual")
      local visual_player = game_visual:GetPlayer()
      nx_execute("game_effect", "create_effect", nx_string(paramval), visual_player, visual_player)
      return
    elseif funcname == "delete_effect" then
      local game_visual = nx_value("game_visual")
      local visual_player = game_visual:GetPlayer()
      nx_execute("game_effect", "remove_effect", nx_string(paramval), visual_player, visual_player)
      return
    end
    funcname = funcname .. " " .. paramval
  end
  if form.close_cbtn.Checked == false then
    form.func_grpbox.Visible = false
  end
  local cmds_tab = {}
  if ALL_SKILL[nx_string(funcname)] ~= nil then
    cmds_tab = ALL_SKILL[nx_string(funcname)]
  else
    cmds_tab = util_split_string(nx_string(funcname), ",")
  end
  for i = 1, table.getn(cmds_tab) do
    if cmds_tab[i] == "reload_buffer_config" then
      reload_client_buffer_config()
    elseif cmds_tab[i] == "reload_skill_config" then
      reload_client_skill_config()
    end
    custom_gminfo(nx_widestr(cmds_tab[i]))
  end
end
function on_readfile_btn_click(self)
  local form = self.ParentForm
  local gm_list = nx_create("StringList")
  local file = nx_work_path() .. "gm\\" .. nx_string(form.combobox_files.Text)
  if not nx_function("ext_is_file_exist", file) then
    return 0
  end
  if not gm_list:LoadFromFile(file) then
    nx_destroy(gm_list)
    return 0
  end
  form.gms_lbox:ClearString()
  local gm_num = gm_list:GetStringCount()
  for i = 0, gm_num - 1 do
    local gm = gm_list:GetStringByIndex(i)
    if gm ~= "" then
      form.gms_lbox:AddString(nx_widestr(gm))
    end
  end
  return 1
end
function on_btn_out_click(btn)
  local form = btn.ParentForm
  local file = nx_work_path() .. "gm\\" .. nx_string(form.combobox_files.Text)
  if not nx_function("ext_is_file_exist", file) then
    return 0
  end
  local arg_list = {file}
  local name_list = ""
  local gm_num = form.gms_lbox.ItemCount
  if 200 < gm_num then
    local gui = nx_value("gui")
    local error_text = gui.TextManager:GetText("ui_luaChinese_270")
    nx_msgbox(nx_string(error_text))
    return 0
  end
  for i = 0, gm_num - 1 do
    local gm = form.gms_lbox:GetString(i)
    name_list = name_list .. nx_string(gm)
    if i ~= gm_num - 1 then
      name_list = name_list .. ","
    end
  end
  table.insert(arg_list, nx_widestr(name_list))
  custom_send_leitai_info(arg_list)
end
function on_run_btn_click(self)
  local form = self.ParentForm
  local gm_num = form.gms_lbox.ItemCount
  for i = 0, gm_num - 1 do
    local gm = form.gms_lbox:GetString(i)
    custom_gminfo(nx_widestr(gm))
  end
end
function on_gms_lbox_select_changed(self, old_index)
  local form = self.ParentForm
  local seltext = nx_string(self:GetString(self.SelectIndex))
  form.onegm_edit.Text = nx_widestr(seltext)
end
function on_gmedit_btn_click(self)
  local form = self.ParentForm
  local new_gm = nx_string(form.onegm_edit.Text)
  if new_gm == "" then
    form.gms_lbox:RemoveByIndex(form.gms_lbox.SelectIndex)
  else
    form.gms_lbox:ChangeString(form.gms_lbox.SelectIndex, nx_widestr(new_gm))
  end
end
function on_clear_btn_click(self)
  local form = self.ParentForm
  local index = form.listbox_table.SelectIndex
  if index <= -1 then
    return 0
  end
  local tab_name = ALL_TABLE[index + 1][1]
  custom_gminfo(nx_widestr("setobj"))
  custom_gminfo(nx_widestr("recordclear " .. tab_name))
end
function reload_client_buffer_config()
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:ReloadAllIniToManager()
  end
  local data_query = nx_value("data_query_manager")
  if nx_is_valid(data_query) then
    data_query:ReloadStaticData(STATIC_DATA_BUFF)
  end
end
function reload_client_skill_config()
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:ReloadAllIniToManager()
  end
  local data_query = nx_value("data_query_manager")
  if nx_is_valid(data_query) then
    data_query:ReloadStaticData(STATIC_DATA_SKILL_STATIC)
    data_query:ReloadStaticData(STATIC_DATA_SKILL_LOCK_DATA)
    data_query:ReloadStaticData(STATIC_DATA_SKILL_FLOW)
    data_query:ReloadStaticData(STATIC_DATA_SKILL_CONSUME)
    data_query:ReloadStaticData(STATIC_DATA_SKILL_TARGETSHAPE)
    data_query:ReloadStaticData(STATIC_DATA_SKILL_HITSHAPE)
    data_query:ReloadStaticData(STATIC_DATA_SKILL_TARGET_SELECT)
    data_query:ReloadStaticData(STATIC_DATA_FORMULA)
    data_query:ReloadStaticData(STATIC_DATA_JINGMAI)
  end
end
function dump_performance_info()
  local device_caps = nx_value("device_caps")
  if not nx_is_valid(device_caps) then
    nx_msgbox("No device caps!")
    return
  end
  local table_mem = device_caps:QueryMemory()
  local memload = table_mem[1]
  local totalphys = table_mem[2]
  local availphys = table_mem[3]
  local totalpagefile = table_mem[4]
  local availpagefile = table_mem[5]
  local totalvirtual = table_mem[6]
  local availvirtual = table_mem[7]
  local usedvirtual = totalvirtual - availvirtual
  local process_table_mem = device_caps:QueryCurrentProcessMemory()
  local PageFaultCount = process_table_mem[1]
  local PeakWorkingSetSize = process_table_mem[2]
  local WorkingSetSize = process_table_mem[3]
  local QuotaPeakPagedPoolUsage = process_table_mem[4]
  local QuotaPagedPoolUsage = process_table_mem[5]
  local QuotaPeakNonPagedPoolUsage = process_table_mem[6]
  local QuotaNonPagedPoolUsage = process_table_mem[7]
  local PagefileUsage = process_table_mem[8]
  local PeakPagefileUsage = process_table_mem[9]
  local table_video_mem = device_caps:QueryVideoMemory()
  local total_video_mem = table_video_mem[1]
  local free_video_mem = table_video_mem[2]
  local total_agp_mem = table_video_mem[3]
  local free_age_mem = table_video_mem[4]
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    nx_msgbox("Gui not found")
    return
  end
  local phy_heaps = -1
  local world = nx_value("world")
  local main_scene = world.MainScene
  if nx_is_valid(main_scene) and nx_find_custom(main_scene, "physics_scene") then
    local physics_scene = main_scene.physics_scene
    if nx_is_valid(physics_scene) then
      phy_heaps = physics_scene.GpuHeapUsageTotal
    end
  end
  local average_FPS = gui.AverageFPS
  local text_grid = nx_create("TextGrid")
  local file_name = "ClientPerf_" .. nx_string(nx_function("ext_get_time_string_for_file")) .. ".txt"
  text_grid.FileName = file_name
  text_grid.DataBegin = 1
  text_grid:AddColumns(23)
  text_grid:SetColName(0, "CPU\202\185\211\195\194\202")
  text_grid:SetColName(1, "\215\220\206\239\192\237\196\218\180\230")
  text_grid:SetColName(2, "\202\163\211\224\206\239\192\237\196\218\180\230")
  text_grid:SetColName(3, "\215\220\210\179\195\230\206\196\188\254")
  text_grid:SetColName(4, "\202\163\211\224\195\230\206\196\188\254")
  text_grid:SetColName(5, "\215\220\208\233\196\226\196\218\180\230")
  text_grid:SetColName(6, "\202\163\211\224\208\233\196\226\196\218\180\230")
  text_grid:SetColName(7, "\202\185\211\195\208\233\196\226\196\218\180\230\161\239")
  text_grid:SetColName(8, "\210\179\195\230\180\237\206\243")
  text_grid:SetColName(9, "\185\164\215\247\201\232\214\195\183\229\214\181")
  text_grid:SetColName(10, "\185\164\215\247\201\232\214\195\196\218\180\230")
  text_grid:SetColName(11, "QuotaPeakPagedPoolUsage")
  text_grid:SetColName(12, "QuotaPagedPoolUsage")
  text_grid:SetColName(13, "QuotaPeakNonPagedPoolUsage")
  text_grid:SetColName(14, "QuotaNonPagedPoolUsage")
  text_grid:SetColName(15, "\210\179\195\230\206\196\188\254\180\243\208\161\161\239")
  text_grid:SetColName(16, "\210\179\195\230\206\196\188\254\183\229\214\181")
  text_grid:SetColName(17, "\207\212\180\230\215\220\193\191")
  text_grid:SetColName(18, "\207\212\180\230\202\163\211\224\193\191")
  text_grid:SetColName(19, "AGP\207\212\180\230\215\220\193\191")
  text_grid:SetColName(20, "AGP\207\212\180\230\202\163\211\224\193\191")
  text_grid:SetColName(21, "\198\189\190\249\214\161\202\253")
  text_grid:SetColName(22, "PhysX\210\209\190\173\202\185\211\195\181\196\207\212\180\230\200\221\193\191")
  local row = text_grid:AddRow("")
  text_grid:SetValueString(nx_int(row), "CPU\202\185\211\195\194\202", nx_string(memload))
  text_grid:SetValueString(nx_int(row), "\215\220\206\239\192\237\196\218\180\230", nx_string(totalphys))
  text_grid:SetValueString(nx_int(row), "\202\163\211\224\206\239\192\237\196\218\180\230", nx_string(availphys))
  text_grid:SetValueString(nx_int(row), "\215\220\210\179\195\230\206\196\188\254", nx_string(totalpagefile))
  text_grid:SetValueString(nx_int(row), "\202\163\211\224\195\230\206\196\188\254", nx_string(availpagefile))
  text_grid:SetValueString(nx_int(row), "\215\220\208\233\196\226\196\218\180\230", nx_string(totalvirtual))
  text_grid:SetValueString(nx_int(row), "\202\163\211\224\208\233\196\226\196\218\180\230", nx_string(availvirtual))
  text_grid:SetValueString(nx_int(row), "\202\185\211\195\208\233\196\226\196\218\180\230\161\239", nx_string(usedvirtual))
  text_grid:SetValueString(nx_int(row), "\210\179\195\230\180\237\206\243", nx_string(PageFaultCount))
  text_grid:SetValueString(nx_int(row), "\185\164\215\247\201\232\214\195\183\229\214\181", nx_string(PeakWorkingSetSize))
  text_grid:SetValueString(nx_int(row), "\185\164\215\247\201\232\214\195\196\218\180\230", nx_string(WorkingSetSize))
  text_grid:SetValueString(nx_int(row), "QuotaPeakPagedPoolUsage", nx_string(QuotaPeakPagedPoolUsage))
  text_grid:SetValueString(nx_int(row), "QuotaPagedPoolUsage", nx_string(QuotaPagedPoolUsage))
  text_grid:SetValueString(nx_int(row), "QuotaPeakNonPagedPoolUsage", nx_string(QuotaPeakNonPagedPoolUsage))
  text_grid:SetValueString(nx_int(row), "QuotaNonPagedPoolUsage", nx_string(QuotaNonPagedPoolUsage))
  text_grid:SetValueString(nx_int(row), "\210\179\195\230\206\196\188\254\180\243\208\161\161\239", nx_string(PagefileUsage))
  text_grid:SetValueString(nx_int(row), "\210\179\195\230\206\196\188\254\183\229\214\181", nx_string(PeakPagefileUsage))
  text_grid:SetValueString(nx_int(row), "\207\212\180\230\215\220\193\191", nx_string(total_video_mem))
  text_grid:SetValueString(nx_int(row), "\207\212\180\230\202\163\211\224\193\191", nx_string(free_video_mem))
  text_grid:SetValueString(nx_int(row), "AGP\207\212\180\230\215\220\193\191", nx_string(total_agp_mem))
  text_grid:SetValueString(nx_int(row), "AGP\207\212\180\230\202\163\211\224\193\191", nx_string(free_age_mem))
  text_grid:SetValueString(nx_int(row), "\198\189\190\249\214\161\202\253", nx_string(average_FPS))
  text_grid:SetValueString(nx_int(row), "PhysX\210\209\190\173\202\185\211\195\181\196\207\212\180\230\200\221\193\191", nx_string(phy_heaps))
  text_grid:SaveToFile()
  nx_destroy(text_grid)
  nx_msgbox("Dump ok : " .. file_name)
end
function add_to_file(self, msg, check)
  if not nx_is_valid(self.string_list) then
    return
  end
  if check == nil then
    check = true
  end
  if check and not self.cbtn_save.Checked then
    return
  end
  self.string_list:AddString(nx_string(msg))
  self.string_list:SaveToFile(nx_work_path() .. "gm.txt")
end
function on_click_createobj_menu(menu_slot, arg)
  if menu_slot == 12 then
    nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_gm", "open_form")
  end
end
