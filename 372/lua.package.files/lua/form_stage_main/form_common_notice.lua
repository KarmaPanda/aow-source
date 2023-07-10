require("util_functions")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_tvt\\define")
require("util_role_prop")
local FormInstanceID = "CommonNoteForm"
local CountConfigPath = "share\\Rule\\CountLimit.ini"
local TimeConfigPath = "share\\Rule\\TimeLimit.ini"
local TimeLimitRecTableName = "Time_Limit_Form_Rec"
local CountLimitRecTableName = "Count_Limit_Form_Rec"
local TimeLimitTable = {}
local CountLimitTable = {}
local TYPE_ERROR = 0
local TYPE_COMMON = 1
local TYPE_BANGPAI = 2
local TYPE_MENPAI = 3
local TYPE_JINDI = 4
local TYPE_SHILI = 5
local TYPE_DUOSHU = 6
local TYPE_CITAN = 7
local TYPE_FANGHUO = 8
local TYPE_YUNBIAO = 9
local TYPE_XUECHOU = 10
local TYPE_HUSHU = 11
local TYPE_XUNLUO = 12
local TYPE_HAIBU = 13
local TYPE_SANLEI = 14
local TYPE_XIASHI = 15
local TYPE_BANGFEI = 16
local TYPE_WULIN = 17
local TYPE_SHOULEI = 18
local TYPE_JIUHUO = 19
local TYPE_JIEFEI = 20
local TYPE_SHIMEN = 21
local TYPE_DALEI = 22
local TYPE_BATTLE = 23
local TYPE_JIUYINZHI_OLD = 24
local TYPE_WORLDWAR = 25
local TYPE_HUASHAN = 26
local LIMIT_TVT_BOSSHELER = 27
local TVT_TYPE_JHBOSS = 28
local TVT_TYPE_JHBOSS2 = 29
local TYPE_JIUYINZHI = 30
local TYPE_SCHOOLDANCE = 31
local TYPE_XUJIA_FISHING = 40
local TYPE_TAOHUA_PRESENT = 41
local TYPE_TAOHUA_ENEMY = 42
local TYPE_YHG_SHIER = 43
local TVT_YIHUA_DEF = 45
local TVT_WEATHER_WAR = 46
local TVT_WEATHER_SUBGROUP = 48
local TVT_GREED_ABDUCTOR = 49
local TVT_ZHONGQIU_ACTIVITY = 50
local TVT_GUILD_DOTA = 51
local TVT_WORLDWAR_COLLECT = 52
local TYPE_CROSSCLONE = 54
local TVT_TG_RANDOM_FIGHT = 55
local TVT_GMDD_TOTAL = 57
local TVT_GUMU_RESCUE = 59
local TVT_GUMU_KILL_RENEGADE = 60
local TVT_FOEMAN_INFALL = 64
local TVT_GUILD_STATION = 69
local TVT_CROSS_GUILD_WAR = 72
local TVT_NEW_TERRITORY_PVP_1 = 75
local TVT_NEW_TERRITORY_PVP_2 = 76
local TVT_XINMO = 79
local TYPE_SSG_SCHOOLMEET = 80
local TYPE_WUJIDAO = 81
local TYPE_WXJ_SCHOOLMEET_TEST = 82
local TYPE_WUXIAN_FETE = 83
local TYPE_DMP_SCHOOLMEET_TEST = 85
local TYPE_SONG_JING = 86
local TYPE_ACT_ESCORT = 87
local TYPE_YEAR_BOSS_ACT = 88
local TVT_OUTLAND_WAR = 91
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
  [TYPE_COMMON] = {
    -1,
    "",
    0
  },
  [TYPE_BANGPAI] = {
    ITT_BANGPAIZHAN,
    "ui_Type2",
    0
  },
  [TYPE_MENPAI] = {
    ITT_MENPAIZHAN,
    "ui_Type3",
    0
  },
  [TYPE_JINDI] = {
    -1,
    "ui_Type4",
    1
  },
  [TYPE_SHILI] = {
    -1,
    "ui_Type5",
    1
  },
  [TYPE_DUOSHU] = {
    ITT_DUOSHU,
    "ui_Type6",
    1
  },
  [TYPE_CITAN] = {
    ITT_SPY_MENP,
    "ui_Type7",
    1
  },
  [TYPE_FANGHUO] = {
    ITT_FANGHUO,
    "ui_Type8",
    1
  },
  [TYPE_YUNBIAO] = {
    ITT_YUNBIAO,
    "ui_Type9",
    0
  },
  [TYPE_XUECHOU] = {
    -1,
    "ui_xuechou_title",
    0
  },
  [TYPE_HUSHU] = {
    ITT_HUSHU,
    "ui_Type19",
    1
  },
  [TYPE_XUNLUO] = {
    ITT_PATROL,
    "ui_Type20",
    1
  },
  [TYPE_HAIBU] = {
    ITT_ARREST,
    "ui_Type10",
    0
  },
  [TYPE_SANLEI] = {
    ITT_WORLDLEITAI,
    "ui_Type11",
    1
  },
  [TYPE_XIASHI] = {
    ITT_XIASHI,
    "ui_Type12",
    0
  },
  [TYPE_BANGFEI] = {
    ITT_BANGFEI,
    "ui_Type13",
    0
  },
  [TYPE_WULIN] = {
    ITT_WORLDLEITAI_RANDOM,
    "ui_Type14",
    1
  },
  [TYPE_SHOULEI] = {
    ITT_SHOULEI,
    "ui_Type15",
    0
  },
  [TYPE_JIUHUO] = {
    ITT_JIUHUO,
    "ui_Type16",
    1
  },
  [TYPE_JIEFEI] = {
    ITT_JIEBIAO,
    "ui_Type17",
    0
  },
  [TYPE_SHIMEN] = {
    ITT_SHIMEN,
    "ui_Type18",
    0
  },
  [TYPE_DALEI] = {
    ITT_DALEI,
    "ui_Type15",
    0
  },
  [TYPE_BATTLE] = {
    -1,
    "ui_battlefield",
    1
  },
  [TYPE_WORLDWAR] = {
    -1,
    "ui_worldwar",
    0
  },
  [TYPE_HUASHAN] = {
    -1,
    "ui_Type26",
    0
  },
  [LIMIT_TVT_BOSSHELER] = {
    -1,
    "ui_random_clone",
    1
  },
  [TYPE_JIUYINZHI] = {
    -1,
    "ui_jyz_type30_01",
    0
  },
  [TYPE_SCHOOLDANCE] = {
    ITT_SCHOOL_DANCE,
    "ui_school_dance",
    0
  },
  [TYPE_XUJIA_FISHING] = {
    -1,
    "ui_xujia_fishing",
    0
  },
  [TYPE_TAOHUA_PRESENT] = {
    -1,
    "ui_taohua_present_scene",
    0
  },
  [TYPE_TAOHUA_ENEMY] = {
    -1,
    "ui_taohua_enemy_scene",
    0
  },
  [TYPE_YHG_SHIER] = {
    -1,
    "ui_yhg_twelvedock",
    1
  },
  [TVT_WEATHER_WAR] = {
    -1,
    "tianqi_jianghu_1",
    1
  },
  [TVT_WEATHER_SUBGROUP] = {
    -1,
    "tianqi_subgroup",
    1
  },
  [TVT_GREED_ABDUCTOR] = {
    -1,
    "tvt_abduct_1",
    0
  },
  [TVT_ZHONGQIU_ACTIVITY] = {
    -1,
    "zhongqiu_type",
    1
  },
  [TVT_WORLDWAR_COLLECT] = {
    -1,
    "ui_lxc_collect",
    0
  },
  [TYPE_CROSSCLONE] = {
    -1,
    "ui_Type4",
    1
  },
  [TVT_TG_RANDOM_FIGHT] = {
    -1,
    "ui_Type55",
    0
  },
  [TVT_GMDD_TOTAL] = {
    -1,
    "ui_Type57",
    0
  },
  [TVT_GUMU_RESCUE] = {
    -1,
    "ui_Type59",
    0
  },
  [TVT_GUMU_KILL_RENEGADE] = {
    -1,
    "ui_gmp_smdh_wf_06",
    1
  },
  [TVT_FOEMAN_INFALL] = {
    -1,
    "ui_Type64",
    1
  },
  [TVT_XINMO] = {
    TVT_XINMO,
    "ui_Type79",
    1
  },
  [TVT_CROSS_GUILD_WAR] = {
    -1,
    "ui_guild_kuafu_001",
    1
  },
  [TVT_NEW_TERRITORY_PVP_1] = {
    -1,
    "ui_dhpvp_title_001",
    1
  },
  [TVT_NEW_TERRITORY_PVP_2] = {
    -1,
    "ui_dhpvp_title_002",
    1
  },
  [TYPE_SSG_SCHOOLMEET] = {
    -1,
    "ui_Type80",
    1
  },
  [TYPE_WUJIDAO] = {
    -1,
    "ui_Type81",
    1
  },
  [TYPE_WXJ_SCHOOLMEET_TEST] = {
    -1,
    "ui_Type82",
    1
  },
  [TYPE_WUXIAN_FETE] = {
    -1,
    "ui_Type83",
    0
  },
  [TYPE_DMP_SCHOOLMEET_TEST] = {
    -1,
    "ui_Type85",
    1
  },
  [TYPE_SONG_JING] = {
    -1,
    "ui_Type86",
    1
  },
  [TYPE_ACT_ESCORT] = {
    ITT_ACTIVE_ESCORT,
    "ui_Type87",
    1
  },
  [TYPE_YEAR_BOSS_ACT] = {
    ITT_YEAR_BOSS_ACT,
    "ui_type_yearboss",
    1
  },
  [TVT_OUTLAND_WAR] = {
    ITT_OUTLAND_WAR,
    "ui_Type91",
    1
  },
  [TVT_OUTLAND_WAR_GUIDE] = {
    -1,
    "ui_type_outland_war_guide",
    0
  },
  [TVT_SKY_HILL] = {
    ITT_SKY_HILL,
    "ui_type_skyhill",
    1
  },
  [TVT_PROTECT_SCHOOL] = {
    ITT_PROTECT_SCHOOL,
    "ui_type_protect_school",
    1
  },
  [TYPE_SCHOOL_COUNTER_ATTACK] = {
    ITT_SCHOOL_COUNTER_ATTACK,
    "ui_type_school_counter_attack",
    1
  },
  [TVT_SCHOOL_EXTINCT_GUIDE] = {
    -1,
    "ui_type_school_extinct_guide",
    0
  },
  [TYPE_GUILD_BOSS] = {
    ITT_GUILD_BOSS,
    "ui_type_guild_boss",
    0
  },
  [TYPE_TEACH_EXAM] = {
    ITT_TEACH_EXAM,
    "ui_type_teach_exam",
    1
  },
  [TYPE_ROYAL_TREASURE] = {
    -1,
    "ui_type_royal_treasure",
    1
  },
  [TYPE_BALANCE_WAR] = {
    ITT_BALANCE_WAR,
    "jsq_balance_war",
    1
  },
  [LIMIT_TVT_WUDAO_WAR] = {
    ITT_WUDAO_WAR,
    "ui_wudaodahui_headtitle",
    1
  },
  [LIMIT_TVT_LUAN_DOU] = {
    ITT_LUAN_DOU,
    "tips_chos_war_tips",
    1
  },
  [TVT_MINGJIAO_DUILIAN] = {
    -1,
    "ui_mingjiaoduilian_title",
    0
  },
  [LIMIT_TVT_JYF_LOCAL_PLAYER] = {
    -1,
    "tips_jiuyang_faculty",
    0
  },
  [LIMIT_TVT_JYF_CROSS_PLAYER] = {
    -1,
    "tips_jiuyang_faculty",
    1
  },
  [LIMIT_TVT_WUDAO_YANWU] = {
    ITT_WUDAO_YANWU,
    "tips_testskill_tips",
    1
  },
  [LIMIT_TVT_HORSE_RACE] = {
    ITT_HORSE_RACE,
    "tips_horse_race_tips",
    1
  },
  [LIMIT_TVT_SJY_SCHOOL_MEET] = {
    ITT_SJY_MEET,
    "tips_sjy_school_met_tips",
    1
  },
  [LIMIT_TVT_SHENJI_DRILL] = {
    ITT_SHENJI_DRILL,
    "tips_sjy_drill",
    1
  },
  [LIMIT_TVT_MIDDLE_SPRING_HUNT] = {
    ITT_MIDDLE_SPRING_HUNT,
    "tips_middle_spring_hunt",
    1
  },
  [LIMIT_TVT_YUBI_ACTIVITY] = {
    ITT_YUBI_ACTIVITY,
    "tips_yubi_activity",
    1
  },
  [LIMIT_TVT_GUILD_CHAMPION_WAR] = {
    -1,
    "tips_guild_champion_war",
    1
  },
  [LIMIT_TVT_MAZE_HUNT] = {
    ITT_MAZE_HUNT_HILL,
    "tips_maze_hunt_activity",
    1
  },
  [LIMIT_TVT_XMG_SCHOOL_MEET] = {
    ITT_XMG_MEET,
    "tips_xmg_school_met_tips",
    1
  },
  [LIMIT_TVT_DEFEND_YG] = {
    -1,
    "tips_dyyg_tips",
    0
  },
  [LIMIT_TVT_LEAGUE_MATCHES] = {
    -1,
    "tips_bhls_tips",
    1
  },
  [LIMIT_TVT_ROGUE] = {
    ITT_ROGUE,
    "tips_rogue_tips",
    1
  },
  [LIMIT_TVT_FLEE_IN_NIGHT] = {
    ITT_FLEE_IN_NIGHT,
    "tips_dryy_tips",
    1
  },
  [LIMIT_DREAM_LAND] = {
    -1,
    "ui_type127",
    1
  }
}
local TVTHELPFORM = {
  [TYPE_COMMON] = "",
  [TVT_CROSS_GUILD_WAR] = "form_stage_main\\form_guild_war\\form_guild_war_list"
}
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function NotifyText(type_index, formattext)
  if type_index == nil then
    return
  end
  if not IsTypeInRange(type_index) then
    return
  end
  local instanceid = nx_string(FormInstanceID) .. nx_string(type_index)
  local b_create = true
  if nx_int(type_index) == nx_int(LIMIT_TVT_JYF_LOCAL_PLAYER) or nx_int(type_index) == nx_int(LIMIT_TVT_JYF_CROSS_PLAYER) then
    b_create = false
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", b_create, false, instanceid)
  if not nx_is_valid(form) then
    local stage_main_flag = nx_value("stage_main")
    local loading_flag = nx_value("loading")
    if (loading_flag or nx_string(stage_main_flag) ~= nx_string("success")) and not b_create then
      local delay_timer = nx_value("timer_game")
      local game_client = nx_value("game_client")
      if not nx_find_custom(game_client, "common_notice_text") then
        game_client.common_notice_text = nx_string("")
      end
      game_client.common_notice_text = game_client.common_notice_text .. nx_string(type_index) .. nx_string("|") .. nx_string(formattext) .. nx_string("|")
      if nx_is_valid(delay_timer) then
        delay_timer:UnRegister(nx_current(), "on_delay_show_notify_text", game_client)
        delay_timer:Register(5000, -1, nx_current(), "on_delay_show_notify_text", game_client, -1, -1)
      end
    end
    return
  end
  local gui = nx_value("gui")
  if not nx_find_custom(form, "BelongType") then
    form.BelongType = type_index
    local type_info = TYPEINFO[form.BelongType]
    if type_info ~= nil and table.getn(type_info) >= 2 then
      form.lbl_title.Text = nx_widestr(gui.TextManager:GetText(type_info[2]))
    end
    if type_info == nil or type_info[1] == nil or type_info[1] == -1 then
      form.btn_tvt.Visible = false
    end
    if type_info == nil or type_info[3] == nil or type_info[3] == 0 then
      form.btn_quit.Visible = false
    end
    if type_info ~= nil and type_info[4] ~= nil and type_info[4] ~= "" then
      form.btn_show.NormalImage = type_info[4]
      form.btn_show.FocusImage = type_info[5]
      form.btn_show.PushImage = type_info[6]
    end
  end
  if nx_find_custom(form, "showformflag") then
    form.Visible = form.showformflag
  end
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(nx_widestr(formattext), -1)
  local time_num, count_num = GetItemNum(nx_number(type_index))
  change_form_size(form, time_num, count_num)
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    delay_timer:Register(3000, -1, nx_current(), "on_delay_show_form_time", form, -1, -1)
  else
    form:Show()
    form.HaveTextInfo = true
    form.btn_fold.Visible = true
    form.btn_unfold.Visible = false
  end
end
function ClearText(type_index)
  if type_index == nil then
    return
  end
  if not IsTypeInRange(type_index) then
    return
  end
  local instanceid = nx_string(FormInstanceID) .. nx_string(type_index)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", false, false, instanceid)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_desc:Clear()
  form.HaveTextInfo = false
  local time_num, count_num = GetItemNum(nx_number(type_index))
  if nx_number(time_num) <= 0 and nx_number(count_num) <= 0 then
    form:Close()
    return
  end
  change_form_size(form, time_num, count_num)
end
function on_delay_show_form_time(form)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  form:Show()
  form.HaveTextInfo = true
  form.btn_fold.Visible = true
  form.btn_unfold.Visible = false
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
end
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "add_form", 0, form.BelongType)
  form.changesize = true
  form.btn_unfix.Visible = false
  form.btn_fold.Visible = false
  form.btn_unfold.Visible = true
  form.btn_show.Visible = false
  if nx_int(form.BelongType) == nx_int(TVT_CROSS_GUILD_WAR) then
    form.btn_enter.Visible = true
    form.btn_enter.Text = nx_widestr(util_text("ui_guild_kuafu_001"))
  else
    form.btn_enter.Visible = false
  end
  form.HaveTextInfo = false
  form.showformflag = true
  form.notice_ui_ini = load_form_config_ini()
  local gui = nx_value("gui")
  local form_load = nx_value("form_common\\form_loading")
  local form_goto_cover = nx_value("form_stage_main\\form_goto_cover")
  if nx_is_valid(form_load) or nx_is_valid(form_goto_cover) then
    gui.Desktop:ToBack(form)
  else
    gui.Desktop:ToFront(form)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", form, nx_current(), "update_newjh_common_notice_ui")
  end
end
function on_main_form_close(form)
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "del_form", 0, form.BelongType)
  nx_execute("form_stage_main\\form_tiguan\\form_tiguan_trace", "close_form")
  end_timer(form)
  if nx_find_custom(form, "notice_ui_ini") and nx_is_valid(form.notice_ui_ini) then
    form.notice_ui_ini:WriteInteger("Size", "Left", form.Left)
    form.notice_ui_ini:WriteInteger("Size", "Top", form.Top)
    form.notice_ui_ini:SaveToFile()
    nx_destroy(form.notice_ui_ini)
    form.notice_ui_ini = nx_null()
  end
  for i = 1, TYPE_MAX - 1 do
    local time_item_name = "timelimititem" .. nx_string(i)
    if nx_find_custom(form, time_item_name) then
      local time_item_list = nx_custom(form, time_item_name)
      if nx_is_valid(time_item_list) then
        time_item_list:ClearChild()
        nx_destroy(time_item_list)
      end
    end
    local count_item_name = "countlimititem" .. nx_string(i)
    if nx_find_custom(form, count_item_name) then
      local count_item_list = nx_custom(form, count_item_name)
      if nx_is_valid(count_item_list) then
        count_item_list:ClearChild()
        nx_destroy(count_item_list)
      end
    end
  end
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
  nx_destroy(form)
end
function IsTypeInRange(belong_type)
  if belong_type <= TYPE_ERROR or belong_type >= TYPE_MAX then
    return false
  end
  return true
end
function IsExistTimeLimitTable(strId, belong_type)
  local instanceid = nx_string(FormInstanceID) .. nx_string(belong_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", false, false, instanceid)
  if not nx_is_valid(form) then
    return false
  end
  local item_name = "timelimititem" .. nx_string(belong_type)
  if not nx_find_custom(form, item_name) then
    return false
  end
  local item_list = nx_custom(form, item_name)
  if not nx_is_valid(item_list) then
    return false
  end
  if item_list:FindChild(nx_string(strId)) then
    return true
  end
  return false
end
function IsExistCountLimitTable(strId, belong_type)
  local instanceid = nx_string(FormInstanceID) .. nx_string(belong_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", false, false, instanceid)
  if not nx_is_valid(form) then
    return false
  end
  local item_name = "countlimititem" .. nx_string(belong_type)
  if not nx_find_custom(form, item_name) then
    return false
  end
  local item_list = nx_custom(form, item_name)
  if not nx_is_valid(item_list) then
    return false
  end
  if item_list:FindChild(nx_string(strId)) then
    return true
  end
  return false
end
function IsExistGroupID(nGroupID)
  if nx_int(-1) == nx_int(nGroupID) then
    return true
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local player_groupid = client_player:QueryProp("GroupID")
  if nx_int(nGroupID) == nx_int(player_groupid) then
    return true
  end
  return false
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time) .. "<br>"
end
function GetDomainName(strId, strDesc)
  local gui = nx_value("gui")
  local domain_name = ""
  if string.find(strId, "guildwar001") ~= nil or string.find(strId, "guildwar002") ~= nil then
    local str_lst = nx_function("ext_split_string", strId, "_")
    local count = table.getn(str_lst)
    if nx_int(count) >= nx_int(2) then
      local domain_id = str_lst[2]
      local name_str = "ui_dipan_" .. nx_string(domain_id)
      domain_name = gui.TextManager:GetText(name_str)
      domain_name = nx_widestr(domain_name) .. nx_widestr(":") .. nx_widestr(strDesc)
    end
  else
    return strDesc
  end
  return domain_name
end
function GetItemType(filename, itemid)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(filename) then
    IniManager:LoadIniToManager(filename)
  end
  local ini = IniManager:GetIniDocument(filename)
  local nType = TYPE_ERROR
  local find_index = ini:FindSectionIndex(nx_string(itemid))
  if 0 <= find_index then
    nType = ini:ReadInteger(find_index, "Type", TYPE_ERROR)
  end
  return nType
end
function create_timelimit_table()
  for i = 1, TYPE_MAX - 1 do
    local instanceid = nx_string(FormInstanceID) .. nx_string(i)
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", false, false, instanceid)
    local item_name = "timelimititem" .. nx_string(i)
    if nx_is_valid(form) and nx_find_custom(form, item_name) then
      local item_list = nx_custom(form, item_name)
      if nx_is_valid(item_list) then
        item_list:ClearChild()
      end
    end
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(client_scene) then
    return
  end
  if not client_scene:FindRecord(TimeLimitRecTableName) then
    return
  end
  local rows = client_scene:GetRecordRows(TimeLimitRecTableName)
  if rows == 0 then
    return
  end
  local cdtkmgr = nx_value("ConditionManager")
  if not nx_is_valid(cdtkmgr) then
    return
  end
  local gui = nx_value("gui")
  for i = 0, rows - 1 do
    local strId = client_scene:QueryRecord(TimeLimitRecTableName, i, 0)
    if strId ~= nil then
      strId = nx_string(strId)
      local strDescId = client_scene:QueryRecord(TimeLimitRecTableName, i, 1)
      local strDesc = gui.TextManager:GetText(nx_string(strDescId))
      local nTimer = nx_number(client_scene:QueryRecord(TimeLimitRecTableName, i, 2))
      local nTimeLimit = nx_number(client_scene:QueryRecord(TimeLimitRecTableName, i, 3))
      local nTag = nx_number(client_scene:QueryRecord(TimeLimitRecTableName, i, 4))
      local strCondition = nx_string(client_scene:QueryRecord(TimeLimitRecTableName, i, 5))
      local nFlag = nx_number(client_scene:QueryRecord(TimeLimitRecTableName, i, 6))
      local nGroupID = nx_int(client_scene:QueryRecord(TimeLimitRecTableName, i, 7))
      local nType = GetItemType(TimeConfigPath, strId)
      strDesc = GetDomainName(strId, strDesc)
      if IsTypeInRange(nType) and not IsExistTimeLimitTable(strId, nType) and IsExistGroupID(nGroupID) then
        local msgdelay = nx_value("MessageDelay")
        local server_time = msgdelay:GetServerNowTime()
        if nTimeLimit > server_time and (nTag == 1 or cdtkmgr:CanSatisfyCondition(player_obj, player_obj, nx_int(strCondition))) then
          local instanceid = nx_string(FormInstanceID) .. nx_string(nType)
          local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", true, false, instanceid)
          if nx_is_valid(form) then
            local item_name = "timelimititem" .. nx_string(nType)
            if not nx_find_custom(form, item_name) then
              local time_item_list = nx_call("util_gui", "get_arraylist", item_name)
              time_item_list:ClearChild()
              nx_set_custom(form, item_name, time_item_list)
            end
            local item_list = nx_custom(form, item_name)
            if nx_is_valid(item_list) then
              local child = item_list:GetChild(nx_string(strId))
              if not nx_is_valid(child) then
                child = item_list:CreateChild(nx_string(strId))
              end
              child.desc = nx_widestr(strDesc)
              child.timelimit = nx_int64(nTimeLimit)
              child.id = nx_string(strId)
              child.flag = nx_int(nFlag)
              child.groupid = nx_int(nGroupID)
            end
          end
        end
      end
    end
  end
end
function create_countlimit_table()
  for i = 1, TYPE_MAX - 1 do
    local instanceid = nx_string(FormInstanceID) .. nx_string(i)
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", false, false, instanceid)
    local item_name = "countlimititem" .. nx_string(i)
    if nx_is_valid(form) and nx_find_custom(form, item_name) then
      local item_list = nx_custom(form, item_name)
      if nx_is_valid(item_list) then
        item_list:ClearChild()
      end
    end
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(client_scene) then
    return
  end
  if not client_scene:FindRecord(CountLimitRecTableName) then
    return
  end
  local rows = client_scene:GetRecordRows(CountLimitRecTableName)
  if rows == 0 then
    return
  end
  local cdtkmgr = nx_value("ConditionManager")
  if not nx_is_valid(cdtkmgr) then
    return
  end
  local gui = nx_value("gui")
  for i = 0, rows - 1 do
    local strId = nx_string(client_scene:QueryRecord(CountLimitRecTableName, i, 0))
    local strDescId = nx_string(client_scene:QueryRecord(CountLimitRecTableName, i, 1))
    local strDesc = gui.TextManager:GetText(strDescId)
    local nCount = nx_number(client_scene:QueryRecord(CountLimitRecTableName, i, 2))
    local nTag = nx_number(client_scene:QueryRecord(CountLimitRecTableName, i, 3))
    local strCondition = nx_string(client_scene:QueryRecord(CountLimitRecTableName, i, 4))
    local nFlag = nx_number(client_scene:QueryRecord(CountLimitRecTableName, i, 5))
    local nGroupID = nx_number(client_scene:QueryRecord(CountLimitRecTableName, i, 6))
    local nType = GetItemType(CountConfigPath, strId)
    if IsTypeInRange(nType) and not IsExistCountLimitTable(strId, nType) and IsExistGroupID(nGroupID) and (nTag == 1 or cdtkmgr:CanSatisfyCondition(player_obj, player_obj, nx_int(strCondition))) then
      local instanceid = nx_string(FormInstanceID) .. nx_string(nType)
      local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", true, false, instanceid)
      if nx_is_valid(form) then
        local item_name = "countlimititem" .. nx_string(nType)
        if not nx_find_custom(form, item_name) then
          local count_item_list = nx_call("util_gui", "get_arraylist", item_name)
          count_item_list:ClearChild()
          nx_set_custom(form, item_name, count_item_list)
        end
        local item_list = nx_custom(form, item_name)
        if nx_is_valid(item_list) then
          local child = item_list:GetChild(nx_string(strId))
          if not nx_is_valid(child) then
            child = item_list:CreateChild(nx_string(strId))
          end
          child.desc = nx_widestr(strDesc)
          child.count = nx_int(nCount)
          child.id = nx_string(strId)
          child.flag = nx_int(nFlag)
        end
      end
    end
  end
end
function change_form_size(form, time_num, count_num)
  if form.btn_show.Visible then
    return
  end
  local gui = nx_value("gui")
  form.groupbox_time.Height = nx_number(50 + 25 * (time_num + count_num))
  form.ImageControlGrid.Height = 22 * time_num
  form.ImageControlGrid.RowNum = time_num
  form.ImageControlGrid.ClomnNum = 1
  form.ImageControlGrid.ViewRect = string.format("%d,%d,%d,%d", 0, 0, form.ImageControlGrid.Width, nx_number(22 * time_num))
  form.ImageControlGrid1.Top = form.ImageControlGrid.Top + form.ImageControlGrid.Height
  form.ImageControlGrid1.Height = 22 * count_num
  form.ImageControlGrid1.RowNum = count_num
  form.ImageControlGrid1.ClomnNum = 1
  form.ImageControlGrid1.ViewRect = string.format("%d,%d,%d,%d", 0, 0, form.ImageControlGrid1.Width, nx_number(22 * count_num))
  local desc_text_size = 0
  if nx_find_custom(form, "HaveTextInfo") and form.HaveTextInfo and form.btn_fold.Visible then
    desc_text_size = form.mltbox_desc:GetContentHeight()
  end
  form.groupbox_desc.Top = form.groupbox_time.Top + form.groupbox_time.Height
  form.groupbox_desc.Height = 0
  form.mltbox_desc.Top = 0
  form.mltbox_desc.Height = desc_text_size
  form.groupbox_desc.Height = form.mltbox_desc.Height
  if nx_number(form.groupbox_desc.Top) < 80 then
    form.groupbox_desc.Top = 80
  end
  form.groupbox_extend.Top = form.groupbox_desc.Top + form.groupbox_desc.Height
  form.Height = form.groupbox_extend.Top + form.groupbox_extend.Height
  form.changesize = false
  local default_left = (gui.Width - form.Width) * 4 / 5
  local default_top = (gui.Height - form.Height) / 2
  local form_notice = nx_value("form_stage_main\\form_main\\form_notice_shortcut")
  if nx_is_valid(form_notice) then
    default_left = form_notice.Left
    default_top = form_notice.Top + form_notice.Height
  end
  local form_left = default_left
  local form_top = default_top
  local limit_left = gui.Width - form.Width
  local limit_top = gui.Height - form.Height
  if form_left < 0 or form_left > limit_left or form_top < 0 or form_top > limit_top then
    form_left = default_left
    form_top = default_top
  end
end
function show_form()
  create_timelimit_table()
  create_countlimit_table()
  for i = 1, TYPE_MAX - 1 do
    local time_num, count_num = GetItemNum(nx_number(i))
    local itmecount = time_num + count_num
    local instanceid = nx_string(FormInstanceID) .. nx_string(i)
    if 0 < itmecount then
      local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", true, false, instanceid)
      if nx_is_valid(form) then
        form.BelongType = i
        update_info(form)
        local type_info = TYPEINFO[form.BelongType]
        if type_info ~= nil and table.getn(type_info) >= 2 then
          local gui = nx_value("gui")
          form.lbl_title.Text = nx_widestr(gui.TextManager:GetText(type_info[2]))
        end
        if nx_number(time_num) > 0 then
          init_timer(form)
        end
        form:Show()
        if nx_find_custom(form, "showformflag") then
          form.Visible = form.showformflag
        end
        local gui = nx_value("gui")
        if type_info == nil or type_info[1] == nil or type_info[1] == -1 then
          form.btn_tvt.Visible = false
        end
        if type_info == nil or type_info[3] == nil or type_info[3] == 0 then
          form.btn_quit.Visible = false
        end
        if type_info ~= nil and type_info[4] ~= nil and type_info[4] ~= "" then
          form.btn_show.NormalImage = type_info[4]
          form.btn_show.FocusImage = type_info[5]
          form.btn_show.PushImage = type_info[6]
        end
        local time_num, count_num = GetItemNum(nx_number(i))
        change_form_size(form, time_num, count_num)
      end
    else
      local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", false, false, instanceid)
      if nx_is_valid(form) then
        form:Close()
      end
    end
  end
end
function update_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "BelongType") then
    return
  end
  local nType = form.BelongType
  if not IsTypeInRange(nType) then
    return
  end
  form.ImageControlGrid:Clear()
  form.ImageControlGrid1:Clear()
  form.ImageControlGrid.GridsPos = ""
  form.ImageControlGrid1.GridsPos = ""
  local time_num, count_num = GetItemNum(nx_number(nType))
  change_form_size(form, time_num, count_num)
  local time_item_name = "timelimititem" .. nx_string(nType)
  if nx_find_custom(form, time_item_name) then
    local time_item_list = nx_custom(form, time_item_name)
    if nx_is_valid(time_item_list) then
      local msgdelay = nx_value("MessageDelay")
      local server_time = msgdelay:GetServerNowTime()
      for i = 1, time_item_list:GetChildCount() do
        local time_item_info = time_item_list:GetChildByIndex(i - 1)
        local strDesc = nx_widestr(time_item_info.desc)
        local timer = (nx_int64(time_item_info.timelimit) - nx_int64(server_time)) / 1000
        if nx_int(timer) < nx_int(0) or nx_number(server_time) == nx_number(0) then
          timer = 0
        end
        local format_timer = get_format_time_text(timer)
        local index_name = nx_widestr(time_item_info.id)
        local nflag = nx_number(time_item_info.flag)
        local IniManager = nx_value("IniManager")
        local ini = IniManager:GetIniDocument(TimeConfigPath)
        local photo = " "
        local sec_index = ini:FindSectionIndex(nx_string(index_name))
        if 0 <= sec_index then
          photo = ini:ReadString(sec_index, "Photo", " ")
        end
        if photo == "" or photo == nil then
          photo = " "
        end
        form.ImageControlGrid:AddItem(i - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
        form.ImageControlGrid:SetItemName(i - 1, nx_widestr(index_name))
        form.ImageControlGrid:SetItemAddInfo(i - 1, 0, nx_widestr(strDesc))
        form.ImageControlGrid:ShowItemAddInfo(i - 1, 0, true)
        form.ImageControlGrid:SetItemAddInfo(i - 1, 1, nx_widestr(format_timer))
        form.ImageControlGrid:ShowItemAddInfo(i - 1, 1, true)
        if nflag == 0 then
          form.ImageControlGrid:ChangeItemImageToBW(i - 1, true)
        end
      end
    end
  end
  local count_item_name = "countlimititem" .. nx_string(nType)
  if nx_find_custom(form, count_item_name) then
    local count_item_list = nx_custom(form, count_item_name)
    if nx_is_valid(count_item_list) then
      for j = 1, count_item_list:GetChildCount() do
        local count_item_info = count_item_list:GetChildByIndex(j - 1)
        local strDesc = nx_widestr(count_item_info.desc)
        local count = nx_number(count_item_info.count)
        local index_name = nx_widestr(count_item_info.id)
        local nflag = nx_number(count_item_info.flag)
        local IniManager = nx_value("IniManager")
        local ini = IniManager:GetIniDocument(CountConfigPath)
        local sec_index = ini:FindSectionIndex(nx_string(index_name))
        local photo = " "
        local count_info = nx_widestr(count)
        if 0 <= sec_index then
          photo = ini:ReadString(sec_index, "Photo", " ")
          if ini:FindSectionItemIndex(sec_index, "MaxCount") ~= -1 then
            local max_count = ini:ReadString(sec_index, "MaxCount", "")
            count_info = count_info .. nx_widestr("/") .. nx_widestr(max_count)
          end
        end
        if photo == "" or photo == nil then
          photo = " "
        end
        if TYPE_BATTLE == nType then
          if j == 1 then
            form.ImageControlGrid1:AddItem(j - 1, nx_string("icon\\limit\\sword_r.png"), nx_widestr(""), nx_int(0), nx_int(0))
          elseif j == 2 then
            form.ImageControlGrid1:AddItem(j - 1, nx_string("icon\\limit\\sword_b.png"), nx_widestr(""), nx_int(0), nx_int(0))
          end
        else
          form.ImageControlGrid1:AddItem(j - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
        end
        form.ImageControlGrid1:SetItemName(j - 1, nx_widestr(index_name))
        form.ImageControlGrid1:SetItemAddInfo(j - 1, 0, nx_widestr(strDesc))
        form.ImageControlGrid1:ShowItemAddInfo(j - 1, 0, true)
        form.ImageControlGrid1:SetItemAddInfo(j - 1, 1, nx_widestr(count_info))
        form.ImageControlGrid1:ShowItemAddInfo(j - 1, 1, true)
        if nflag == 0 then
          form.ImageControlGrid1:ChangeItemImageToBW(j - 1, true)
        end
      end
    end
  end
end
function close_form()
  for i = 1, TYPE_MAX - 1 do
    local instanceid = nx_string(FormInstanceID) .. nx_string(i)
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", false, false, instanceid)
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function init_timer(form)
  local common_execute = nx_value("common_execute")
  common_execute:AddExecute("CommonNotice", form, nx_float(1))
end
function end_timer(form)
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("CommonNotice", form)
end
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "BelongType") then
    return
  end
  local nType = nx_number(form.BelongType)
  if not IsTypeInRange(nType) then
    return
  end
  local msgdelay = nx_value("MessageDelay")
  local CurServerTime = msgdelay:GetServerNowTime()
  local time_item_name = "timelimititem" .. nx_string(nType)
  if nx_find_custom(form, time_item_name) then
    local time_item_list = nx_custom(form, time_item_name)
    if nx_is_valid(time_item_list) then
      for i = time_item_list:GetChildCount(), 1, -1 do
        local time_item_info = time_item_list:GetChildByIndex(i - 1)
        if not IsExistGroupID(time_item_info.groupid) or nx_int64(CurServerTime) > nx_int64(time_item_info.timelimit) then
          time_item_list:RemoveChildByIndex(i - 1)
        end
      end
    end
  end
  local time_num, count_num = GetItemNum(nx_number(nType))
  if time_num + count_num <= 0 then
    form:Close()
    return
  end
  update_info(form)
  change_form_size(form, time_num, count_num)
end
function on_ImageControlGrid_mousein_grid(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "BelongType") then
    return
  end
  local nType = nx_number(form.BelongType)
  if not IsTypeInRange(nType) then
    return
  end
  local item_name = "timelimititem" .. nx_string(nType)
  if not nx_find_custom(form, item_name) then
    return
  end
  local item_list = nx_custom(form, item_name)
  if not nx_is_valid(item_list) then
    return
  end
  local item_info = item_list:GetChildByIndex(index)
  if not nx_is_valid(item_info) then
    return
  end
  local index_name = self:GetItemName(index)
  local nFlag = nx_number(item_info.flag)
  local file_name = TimeConfigPath
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string(index_name))
  if sec_index < 0 then
    return
  end
  local tips_text = ini:ReadString(sec_index, "TipsText", "")
  local TipsArray = util_split_string(nx_string(tips_text), ",")
  if table.getn(TipsArray) < 2 then
    return
  end
  local gui = nx_value("gui")
  local strTips = TipsArray[nFlag + 1]
  local text = gui.TextManager:GetFormatText(nx_string(strTips))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_ImageControlGrid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_ImageControlGrid1_mousein_grid(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "BelongType") then
    return
  end
  local nType = nx_number(form.BelongType)
  if not IsTypeInRange(nType) then
    return
  end
  local item_name = "countlimititem" .. nx_string(nType)
  if not nx_find_custom(form, item_name) then
    return
  end
  local item_list = nx_custom(form, item_name)
  if not nx_is_valid(item_list) then
    return
  end
  local item_info = item_list:GetChildByIndex(index)
  if not nx_is_valid(item_info) then
    return
  end
  local index_name = self:GetItemName(index)
  local nFlag = nx_number(item_info.flag)
  local file_name = CountConfigPath
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string(index_name))
  if sec_index < 0 then
    return
  end
  local tips_text = ini:ReadString(sec_index, "TipsText", "")
  local TipsArray = util_split_string(nx_string(tips_text), ",")
  if table.getn(TipsArray) < 2 then
    return
  end
  local gui = nx_value("gui")
  if TYPE_BATTLE == nType then
    local arena_side = 0
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    if client_player:FindProp("ArenaSide") then
      arena_side = client_player:QueryProp("ArenaSide")
    end
    if arena_side ~= 0 and arena_side ~= index + 1 then
      nFlag = 0
    end
  end
  local strTips = TipsArray[nFlag + 1]
  local text = gui.TextManager:GetFormatText(nx_string(strTips))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_ImageControlGrid1_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_ImageControlGrid1_select_changed(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "BelongType") then
    return
  end
  local nType = nx_number(form.BelongType)
  if TYPE_JIUYINZHI == nType then
    if util_is_lockform_visible("form_stage_main\\form_9yinzhi") then
      nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_main", "ansyn_close_9yinzhi")
    else
      local jyzStateId = ""
      local jyzState = ""
      local count_item_name = "countlimititem" .. nx_string(nType)
      if nx_find_custom(form, count_item_name) then
        local count_item_list = nx_custom(form, count_item_name)
        if nx_is_valid(count_item_list) and nx_number(index) < nx_number(count_item_list:GetChildCount()) then
          local count_item_info = count_item_list:GetChildByIndex(index)
          jyzStateId = nx_string(count_item_info.id) .. "_open_jyz"
        end
      end
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        jyzState = nx_string(gui.TextManager:GetFormatText(nx_string(jyzStateId)))
      end
      if jyzState ~= jyzStateId then
        nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_main", "set_open_state", nx_string(jyzState))
        nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_main", "ansyn_open_9yinzhi")
      end
    end
  end
end
function on_ImageControlGrid_select_changed(self, index)
end
function on_btn_unfix_click(btn)
  local form = btn.ParentForm
  form.Fixed = false
  btn.Visible = false
  form.btn_fix.Visible = true
end
function on_btn_fix_click(btn)
  local form = btn.ParentForm
  form.Fixed = true
  btn.Visible = false
  form.btn_unfix.Visible = true
end
function on_btn_tvt_click(btn)
  local form = btn.ParentForm
  local type_info = TYPEINFO[form.BelongType]
  if type_info == nil then
    return
  end
  if type_info[1] == nil or type_info[1] == -1 then
    return
  end
  send_server_msg(g_msg_player_list, type_info[1])
  nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "show_type_info", type_info[1])
end
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  local type_info = TYPEINFO[form.BelongType]
  if type_info == nil then
    return
  end
  local tvt_type = nx_number(type_info[1])
  if nx_number(form.BelongType) == TVT_CROSS_GUILD_WAR and not show_confirm_info("ui_kuafu_item_xuanfukuang_02") then
    return
  end
  if nx_number(form.BelongType) == TVT_OUTLAND_WAR and not show_confirm_info("ui_outland_war_quit") then
    return
  end
  if nx_number(form.BelongType) == LIMIT_TVT_GUILD_CHAMPION_WAR and not show_confirm_info("ui_cw_quit_ok") then
    return
  end
  if tvt_type ~= nil and tvt_type ~= -1 then
    send_server_msg(g_msg_giveup, tvt_type)
  end
  if nx_number(form.BelongType) == TYPE_JINDI then
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "send_out_clone")
    if not nx_is_valid(dialog) then
      return
    end
    dialog:ShowModal()
    local text = nx_widestr(util_text("ui_out_door"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    local res = nx_wait_event(100000000, dialog, "send_out_clone_confirm_return")
    if res == "ok" then
      nx_execute("form_stage_main\\form_clone\\form_clone_info", "client_request_leave_clone")
      return
    else
      return
    end
  end
  local g_func = {
    [TYPE_JINDI] = {
      src = "form_stage_main\\form_clone\\form_clone_info",
      funcname = "client_request_leave_clone"
    },
    [TYPE_BANGFEI] = {
      src = "form_stage_main\\form_offline\\form_offline_abduct_tip",
      funcname = "GiveupAbduct"
    },
    [TYPE_FANGHUO] = {
      src = "form_stage_main\\form_guild_fire\\form_fire_info",
      funcname = "GiveupFireTask"
    },
    [TYPE_JIUHUO] = {
      src = "form_stage_main\\form_guild_fire\\form_fire_info",
      funcname = "GiveupWaterTask"
    },
    [TYPE_BATTLE] = {
      src = "form_stage_main\\form_battlefield\\form_battlefield_join",
      funcname = "request_leave_battlefield"
    },
    [LIMIT_TVT_BOSSHELER] = {
      src = "form_stage_main\\form_clone\\form_clone_killer",
      funcname = "cancel_apply_killer"
    },
    [TYPE_SHILI] = {
      src = "form_stage_main\\form_tiguan\\form_tiguan_go",
      funcname = "client_request_leave_tiguan"
    },
    [TYPE_YHG_SHIER] = {
      src = "form_stage_main\\form_force_school\\form_yhg_shier",
      funcname = "client_request_leave_yhg_td"
    },
    [TVT_WEATHER_WAR] = {
      src = "form_stage_main\\form_common_notice",
      funcname = "request_leave_weatherwar"
    },
    [TVT_WEATHER_SUBGROUP] = {
      src = "form_stage_main\\form_common_notice",
      funcname = "request_leave_weatherwar_subgroup"
    },
    [TVT_ZHONGQIU_ACTIVITY] = {
      src = "form_stage_main\\form_common_notice",
      funcname = "request_leave_zhongqiu_subgroup"
    },
    [TVT_GUMU_KILL_RENEGADE] = {
      src = "form_stage_main\\form_common_notice",
      funcname = "request_quit_gmp_kill_renegade"
    },
    [TVT_FOEMAN_INFALL] = {
      src = "form_stage_main\\form_common_notice",
      funcname = "request_quit_foeman_infall"
    },
    [TYPE_SSG_SCHOOLMEET] = {
      src = "custom_sender",
      funcname = "ssg_exit_schoolmeet_test"
    },
    [TYPE_WXJ_SCHOOLMEET_TEST] = {
      src = "custom_sender",
      funcname = "wxj_exit_schoolmeet_test"
    },
    [TYPE_DMP_SCHOOLMEET_TEST] = {
      src = "custom_sender",
      funcname = "dmp_exit_schoolmeet_test"
    },
    [TVT_CROSS_GUILD_WAR] = {
      src = "form_stage_main\\form_common_notice",
      funcname = "request_quit_corss_war"
    },
    [TVT_NEW_TERRITORY_PVP_1] = {
      src = "form_stage_main\\form_new_territory\\form_new_territory",
      funcname = "on_pvp_quit"
    },
    [TVT_NEW_TERRITORY_PVP_2] = {
      src = "form_stage_main\\form_new_territory\\form_new_territory",
      funcname = "on_pvp_quit"
    },
    [TYPE_WUJIDAO] = {
      src = "form_stage_main\\form_common_notice",
      funcname = "custom_wjd_request_leave"
    },
    [TYPE_SONG_JING] = {
      src = "form_stage_main\\form_common_notice",
      funcname = "custom_songjing_leave_join"
    },
    [TYPE_SCHOOL_COUNTER_ATTACK] = {
      src = "form_stage_main\\form_school_counterattack\\form_counter_attack_rank",
      funcname = "on_btn_quit_click"
    },
    [TYPE_ROYAL_TREASURE] = {
      src = "custom_sender",
      funcname = "custom_quit_royal_treasure"
    },
    [LIMIT_TVT_JYF_CROSS_PLAYER] = {
      src = "custom_sender",
      funcname = "custom_quit_jiuyang_faculty"
    },
    [LIMIT_TVT_SJY_SCHOOL_MEET] = {
      src = "custom_sender",
      funcname = "custom_quit_sjy_school_meet"
    },
    [LIMIT_TVT_SHENJI_DRILL] = {
      src = "custom_sender",
      funcname = "custom_quit_sjy_drill"
    },
    [LIMIT_TVT_MIDDLE_SPRING_HUNT] = {
      src = "custom_sender",
      funcname = "custom_quit_middle_spring_hunt"
    },
    [LIMIT_TVT_YUBI_ACTIVITY] = {
      src = "custom_sender",
      funcname = "custom_quit_yubi_activity"
    },
    [LIMIT_TVT_GUILD_CHAMPION_WAR] = {
      src = "custom_sender",
      funcname = "custom_cw_back"
    },
    [LIMIT_TVT_XMG_SCHOOL_MEET] = {
      src = "custom_sender",
      funcname = "custom_quit_xmg_school_meet"
    },
    [LIMIT_TVT_LEAGUE_MATCHES] = {
      src = "custom_sender",
      funcname = "custom_league_matches_back"
    },
    [LIMIT_TVT_FLEE_IN_NIGHT] = {
      src = "custom_sender",
      funcname = "custom_flee_in_night_back"
    },
    [LIMIT_DREAM_LAND] = {
      src = "form_stage_main\\form_dream_land\\form_dream_land",
      funcname = "request_quit_dream_land"
    }
  }
  local cfg = g_func[form.BelongType]
  if cfg == nil then
    return
  end
  if cfg.src ~= nil and cfg.funcname ~= nil then
    nx_execute(cfg.src, cfg.funcname, tvt_type)
  end
end
function show_confirm_info(tip)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog:ShowModal()
    local text = nx_widestr(util_text(tip))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return false
    end
  end
  return true
end
function on_btn_fold_click(btn)
  local form = btn.ParentForm
  local nType = form.BelongType
  if not IsTypeInRange(nType) then
    return
  end
  form.btn_unfold.Visible = true
  form.btn_fold.Visible = false
  local time_num, count_num = GetItemNum(nx_number(nType))
  change_form_size(form, time_num, count_num)
end
function on_btn_unfold_click(btn)
  local form = btn.ParentForm
  local nType = form.BelongType
  if not IsTypeInRange(nType) then
    return
  end
  form.btn_unfold.Visible = false
  form.btn_fold.Visible = true
  local time_num, count_num = GetItemNum(nx_number(nType))
  change_form_size(form, time_num, count_num)
end
function on_btn_minimize_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form.showformflag = form.Visible
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "check_cbtn_state", 0, form.BelongType)
end
function on_btn_show_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nType = form.BelongType
  if not IsTypeInRange(nType) then
    return
  end
  form.btn_show.Visible = false
  form.groupbox_time.Visible = true
  form.groupbox_desc.Visible = true
  form.groupbox_extend.Visible = true
  local time_num, count_num = GetItemNum(nx_number(nType))
  change_form_size(form, time_num, count_num)
end
function on_cbtn_help_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "BelongType") then
    return
  end
  local nType = nx_number(form.BelongType)
  if not IsTypeInRange(nType) then
    return
  end
  if TVTHELPFORM[nType] == nil or TVTHELPFORM[nType] == "" then
    return
  end
  nx_execute(nx_string(TVTHELPFORM[nType]), "show_form", cbtn.Checked)
end
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "BelongType") then
    return
  end
  local nType = nx_number(form.BelongType)
  if not IsTypeInRange(nType) then
    return
  end
  if TVTHELPFORM[nType] == nil or TVTHELPFORM[nType] == "" then
    return
  end
  nx_execute(nx_string(TVTHELPFORM[nType]), "open_form")
end
function GetItemNum(index)
  local time_num = 0
  local count_num = 0
  local instanceid = nx_string(FormInstanceID) .. nx_string(index)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_common_notice", false, false, instanceid)
  if not nx_is_valid(form) then
    return time_num, count_num
  end
  local time_item_name = "timelimititem" .. nx_string(index)
  if nx_find_custom(form, time_item_name) then
    local time_item_list = nx_custom(form, time_item_name)
    if nx_is_valid(time_item_list) then
      time_num = nx_number(time_item_list:GetChildCount())
    end
  end
  local count_item_name = "countlimititem" .. nx_string(index)
  if nx_find_custom(form, count_item_name) then
    local count_item_list = nx_custom(form, count_item_name)
    if nx_is_valid(count_item_list) then
      count_num = nx_number(count_item_list:GetChildCount())
    end
  end
  return time_num, count_num
end
function load_form_config_ini()
  local file_name = "noticeui.ini"
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_property(game_config, "login_account") then
    local account = game_config.login_account
    file_name = account .. "\\" .. file_name
  end
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    ini:SaveToFile()
  end
  return ini
end
function request_leave_zhongqiu_subgroup(tvt_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("zhongqiu_subgroup_confirm"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_zhongqiu_subgroup", 999)
  end
end
function request_leave_weatherwar(tvt_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("tianqi_jianghu_2"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_weather_war", 1)
  end
end
function request_leave_weatherwar_subgroup(tvt_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("tianqi_subgroup_confirm"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_weather_war_subgroup", 2)
  end
end
function update_newjh_common_notice_ui(form)
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
function request_quit_gmp_kill_renegade()
  local CTS_SUB_MSG_ANCIENTTOMB_KILL_RENEGADE_QUIT = 11
  nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SUB_MSG_ANCIENTTOMB_KILL_RENEGADE_QUIT)
  return
end
function request_quit_foeman_infall()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("sys_activity_918_05"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_foeman_infall", 1)
  end
end
function request_quit_corss_war()
  nx_execute("custom_sender", "custom_cross_guild_war", 6)
end
function custom_wjd_request_leave()
  nx_execute("custom_sender", "custom_wjd_request", 1)
end
function custom_songjing_leave_join()
  nx_execute("custom_sender", "custom_song_jing_request", 3)
end
function on_delay_show_notify_text(game_client)
  if not nx_is_valid(game_client) then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  local delay_timer = nx_value("timer_game")
  if not nx_is_valid(delay_timer) then
    return
  end
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  if not nx_find_custom(game_client, "common_notice_text") then
    delay_timer:UnRegister(nx_current(), "on_delay_show_notify_text", nx_value("game_client"))
    return
  end
  delay_timer:UnRegister(nx_current(), "on_delay_show_notify_text", nx_value("game_client"))
  local infos = util_split_string(game_client.common_notice_text, "|")
  local info_size = table.getn(infos)
  for i = 1, info_size do
    if i % 2 ~= 0 and info_size >= i + 1 then
      nx_execute("form_stage_main\\form_common_notice", "NotifyText", nx_int(infos[i]), nx_string(infos[i + 1]))
    end
  end
  game_client.common_notice_text = nx_string("")
end
