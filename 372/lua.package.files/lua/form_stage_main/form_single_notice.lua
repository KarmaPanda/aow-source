require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_tvt\\define")
require("form_stage_main\\form_guild_war\\form_guild_war_girl")
local FormInstanceID = "SingleNoticeForm"
local SingleLimitDataRec = "SingleLimitDataRec"
local CountConfigPath = "share\\Rule\\CountLimit.ini"
local TimeConfigPath = "share\\Rule\\TimeLimit.ini"
local VIEWPORT_GUILDWAR_BOX = 132
local LIMIT_TYPE_ERROR = 0
local LIMIT_TYPE_TIME = 1
local LIMIT_TYPE_COUNT = 2
local LIMIT_TYPE_MAX = 3
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
local TVT_TYPE_SCHOOLDANCE = 31
local TVT_TYPE_EGWAR_START = 34
local TVT_TYPE_EGWAR_END = 35
local TVT_TYPE_EGWAR_LEAVE = 36
local TVT_XJZ_LYBS = 38
local TVT_YHG_TXCL = 39
local TVT_XUJIA_FISHING = 40
local TVT_TAOHUA_PRESENT = 41
local TVT_TAOHUA_ENEMY = 42
local TVT_KILLER_ADV = 44
local TVT_YIHUA_DEF = 45
local TVT_WEATHER_WAR = 46
local TVT_TYPE_PIKONGZHANG = 47
local TVT_TYPE_WGM_YANREN = 48
local TVT_COMMON_GROUP_SCENE = 50
local TVT_GUILD_DOTA = 51
local TVT_WORLDWAR_COLLECT = 52
local TVT_LMBJ_DMXB = 53
local TVT_TG_RANDOM_FIGHT = 55
local TVT_CROSS_CLONE = 56
local TVT_GMDD_TOTAL = 57
local TVT_GMDD_TEST = 58
local TVT_GUMU_RESCUE = 59
local TVT_TYPE_SF_TRACEINFO = 60
local TVT_TYPE_FIGHT = 61
local TVT_GUILD_DOTA = 62
local TVT_NY_ITEM = 63
local TVT_FOEMAN_INFALL = 64
local TVT_WORLDLEITAI_WUDOU = 65
local TVT_ANCIENTTOMB_SMDH = 66
local TVT_BODYGUARD_SMDH = 67
local TYPE_NEW_FANGHUO = 68
local TVT_GUILD_STATION = 69
local TVT_HSP_MEET = 70
local TVT_HSP_WXJZ = 71
local TVT_CHAOTIC_YANYU = 73
local TVT_SWORN_SEREMONY = 74
local TVT_FIVE_FAIRY_GLORY = 77
local TVT_XINMO = 79
local TYPE_WUJIDAO = 81
local TYPE_WUXIAN_FETE = 83
local TVT_CONQUER_DEMON = 84
local TVT_STEAL_IN_GET_INTELLIGENCE = 89
local TVT_STEAL_IN_SAVE_HOSTAGE = 90
local TVT_BALANCE_WAR = 103
local LIMIT_TVT_WUDAO_WAR = 104
local LIMIT_TVT_LUAN_DOU = 105
local TVT_MINGJIAO_DUILIAN = 106
local LIMIT_TVT_JYF_LOCAL_PLAYER = 107
local LIMIT_TVT_JYF_CROSS_PLAYER = 109
local LIMIT_TVT_WUDAO_YANWU = 112
local LIMIT_TVT_HORSE_RACE = 113
local LIMIT_TVT_ROGUE = 125
local TVT_TYPE_MAX = 128
local TYPEINFO = {
  [TVT_TYPE_COMMON] = {
    -1,
    "",
    0
  },
  [TVT_TYPE_BANGPAI] = {
    ITT_BANGPAIZHAN,
    "ui_Type2",
    0
  },
  [TVT_TYPE_MENPAI] = {
    ITT_MENPAIZHAN,
    "ui_Type3",
    0
  },
  [TVT_TYPE_JINDI] = {
    -1,
    "ui_Type4",
    1
  },
  [TVT_TYPE_SHILI] = {
    -1,
    "ui_Type5",
    0
  },
  [TVT_TYPE_DUOSHU] = {
    ITT_DUOSHU,
    "ui_Type6",
    1
  },
  [TVT_TYPE_CITAN] = {
    ITT_SPY_MENP,
    "ui_Type7",
    1
  },
  [TVT_TYPE_FANGHUO] = {
    ITT_FANGHUO,
    "ui_Type8",
    1
  },
  [TVT_TYPE_YUNBIAO] = {
    ITT_YUNBIAO,
    "ui_Type9",
    0
  },
  [TVT_TYPE_XUECHOU] = {
    -1,
    "ui_xuechou_title",
    0
  },
  [TVT_TYPE_HUSHU] = {
    ITT_HUSHU,
    "ui_Type19",
    1
  },
  [TVT_TYPE_XUNLUO] = {
    ITT_PATROL,
    "ui_Type20",
    1
  },
  [TVT_TYPE_HAIBU] = {
    ITT_ARREST,
    "ui_Type10",
    0
  },
  [TVT_TYPE_SANLEI] = {
    ITT_WORLDLEITAI,
    "ui_Type11",
    1
  },
  [TVT_TYPE_XIASHI] = {
    ITT_XIASHI,
    "ui_Type12",
    0
  },
  [TVT_TYPE_BANGFEI] = {
    ITT_BANGFEI,
    "ui_Type13",
    0
  },
  [TVT_TYPE_WULIN] = {ITT_WORLDLEITAI_RANDOM, "ui_Type14"},
  [TVT_TYPE_SHOULEI] = {
    ITT_SHOULEI,
    "ui_Type15",
    0
  },
  [TVT_TYPE_JIUHUO] = {
    ITT_JIUHUO,
    "ui_Type16",
    1
  },
  [TVT_TYPE_JIEFEI] = {
    ITT_JIEBIAO,
    "ui_Type17",
    0
  },
  [TVT_TYPE_SHIMEN] = {
    ITT_SHIMEN,
    "ui_Type18",
    0
  },
  [TVT_TYPE_DALEI] = {
    ITT_DALEI,
    "ui_Type15",
    0
  },
  [TVT_TYPE_BATTLE] = {
    -1,
    "ui_battlefield",
    1
  },
  [TVT_TYPE_ZHUIZONG] = {
    -1,
    "ui_zhibao_zhuizong_title",
    1
  },
  [TVT_TYPE_WORLDWAR] = {
    -1,
    "",
    0
  },
  [TVT_TYPE_HUASHAN] = {
    -1,
    "",
    0
  },
  [LIMIT_TVT_BOSSHELER] = {
    -1,
    "ui_random_clone",
    1
  },
  [TVT_TYPE_JHBOSS] = {
    27,
    "ui_jh_005",
    1
  },
  [TVT_TYPE_JHBOSS2] = {
    -1,
    "ui_jh_005",
    0
  },
  [TYPE_JIUYINZHI] = {
    -1,
    "ui_jh_005",
    0
  },
  [TVT_TYPE_SCHOOLDANCE] = {
    ITT_SCHOOL_DANCE,
    "ui_school_dance",
    0
  },
  [TVT_TYPE_EGWAR_START] = {
    ITT_EGWAR,
    "ui_egwar_timelimit_start",
    0
  },
  [TVT_TYPE_EGWAR_END] = {
    ITT_EGWAR,
    "ui_egwar_timelimit_end",
    0
  },
  [TVT_TYPE_EGWAR_LEAVE] = {
    ITT_EGWAR,
    "ui_egwar_timelimit_leave",
    0
  },
  [TVT_YIHUA_DEF] = {
    -1,
    "yhg_swhd_jf",
    0
  },
  [TVT_XJZ_LYBS] = {
    -1,
    "info_xjz_010",
    0
  },
  [TVT_YHG_TXCL] = {
    -1,
    "sys_yhgtxcl_title",
    0
  },
  [TVT_XUJIA_FISHING] = {
    -1,
    "ui_xujia_fishing",
    0
  },
  [TVT_TAOHUA_PRESENT] = {
    -1,
    "ui_taohua_present_single",
    0
  },
  [TVT_TAOHUA_ENEMY] = {
    -1,
    "ui_taohua_enemy_single",
    0
  },
  [TVT_KILLER_ADV] = {
    ITT_KILLER_ADV,
    "ui_sh_001",
    1
  },
  [TVT_YIHUA_DEF] = {
    -1,
    "yhg_swhd_jf",
    0
  },
  [TVT_TYPE_PIKONGZHANG] = {
    ITT_THD_PIKONGZHANG,
    "thd_pikongzhang",
    1
  },
  [TVT_TYPE_WGM_YANREN] = {
    ITT_QS_YANREN,
    "ui_qs_yanren",
    1
  },
  [TVT_WORLDWAR_COLLECT] = {
    -1,
    "ui_lxc_collect",
    0
  },
  [TVT_LMBJ_DMXB] = {
    ITT_BODYGUARDOFFICE_DMXB,
    "ui_lmbj_dmxb",
    1
  },
  [TVT_CROSS_CLONE] = {
    -1,
    "ui_Type4",
    0
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
  [TVT_GMDD_TEST] = {
    -1,
    "ui_Type58",
    0
  },
  [TVT_GUMU_RESCUE] = {
    -1,
    "ui_Type59",
    0
  },
  [TVT_ANCIENTTOMB_SMDH] = {
    -1,
    "ui_Type66",
    0
  },
  [TVT_BODYGUARD_SMDH] = {
    -1,
    "ui_Type67",
    0
  },
  [TVT_WORLDLEITAI_WUDOU] = {
    ITT_WORLDLEITAI_WUDOU,
    "ui_Type65",
    1
  },
  [TYPE_NEW_FANGHUO] = {
    ITT_NEW_FANGHUO,
    "ui_Type8",
    1
  },
  [TVT_GUILD_STATION] = {
    -1,
    "ui_Type69",
    0
  },
  [TVT_HSP_MEET] = {
    ITT_HUASHANSCHOOL_MEET,
    "ui_Type70",
    1
  },
  [TVT_HSP_WXJZ] = {
    ITT_HUASHANSCHOOL_WXJZ,
    "ui_Type71",
    1
  },
  [TVT_CHAOTIC_YANYU] = {
    -1,
    "ui_Type73",
    0
  },
  [TVT_SWORN_SEREMONY] = {
    -1,
    "ui_Type74",
    0
  },
  [TVT_FIVE_FAIRY_GLORY] = {
    ITT_FIVEFAIRY_GLORY,
    "ui_Type77",
    1
  },
  [TVT_XINMO] = {
    TVT_XINMO,
    "ui_Type79",
    1
  },
  [TYPE_WUXIAN_FETE] = {
    -1,
    "ui_Type83",
    0
  },
  [TVT_CONQUER_DEMON] = {
    ITT_DMP_CONQUER_DEMON,
    "ui_Type84",
    1
  },
  [TVT_STEAL_IN_GET_INTELLIGENCE] = {
    ITT_STEAL_IN_GET_INTELLIGENCE,
    "ui_GET_INTELLIGENCE",
    1
  },
  [TVT_STEAL_IN_SAVE_HOSTAGE] = {
    ITT_STEAL_IN_SAVE_HOSTAGE,
    "ui_SAVE_HOSTAGE",
    1
  },
  [TVT_BALANCE_WAR] = {
    -1,
    "jsq_balance_war",
    1
  },
  [LIMIT_TVT_WUDAO_WAR] = {
    -1,
    "ui_wudaodahui_headtitle",
    1
  },
  [LIMIT_TVT_LUAN_DOU] = {
    -1,
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
    -1,
    "tips_testskill_tips",
    1
  },
  [LIMIT_TVT_HORSE_RACE] = {
    -1,
    "tips_horse_race_tips",
    1
  },
  [LIMIT_TVT_ROGUE] = {
    -1,
    "tips_rogue_tips",
    1
  }
}
local g_icon = "<img src=\"gui\\special\\tvt\\tvt_xuanzhongbiaoji.png\" valign=\"bottom\" only=\"line\" data=\"\" />"
local g_normal_icon = "<img src=\"gui\\special\\tvt\\tvt_kong.png\" valign=\"bottom\" only=\"line\" data=\"\" />"
local TVTHELPFORM = {
  [TVT_TYPE_COMMON] = ""
}
local cache_title_args = {}
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
  if nx_number(type_index) == 111 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_single_notice", false, false, instanceid)
    if not nx_is_valid(form) then
      return
    end
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_single_notice", true, false, instanceid)
  if not nx_is_valid(form) then
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
    local delay_timer = nx_value("timer_game")
    delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
    local stage_main_flag = nx_value("stage_main")
    local loading_flag = nx_value("loading")
    if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
      delay_timer:Register(5000, -1, nx_current(), "on_delay_show_form_time", form, -1, -1)
    else
      form:Show()
      if nx_find_custom(form, "showformflag") then
        form.Visible = form.showformflag
      end
    end
  end
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(nx_widestr(formattext), -1)
  form.btn_fold.Visible = true
  form.btn_unfold.Visible = false
  form.HaveTextInfo = true
  change_form_size(form, GetItemNum(form, LIMIT_TYPE_TIME), GetItemNum(form, LIMIT_TYPE_COUNT))
end
function ClearText(type_index)
  if type_index == nil then
    return
  end
  if not IsTypeInRange(type_index) then
    return
  end
  local instanceid = nx_string(FormInstanceID) .. nx_string(type_index)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_single_notice", false, false, instanceid)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_desc:Clear()
  form.HaveTextInfo = false
  local time_num = GetItemNum(form, LIMIT_TYPE_TIME)
  local count_num = GetItemNum(form, LIMIT_TYPE_COUNT)
  if nx_number(time_num) <= 0 and nx_number(count_num) <= 0 then
    form:Close()
    return
  end
  change_form_size(form, time_num, count_num)
end
function main_form_init(form)
  form.Fixed = false
  form.refresh_time = 0
  form.HaveTextInfo = false
  return 1
end
function on_main_form_open(form)
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "add_form", 1, form.BelongType)
  form.changesize = true
  form.btn_unfix.Visible = false
  form.btn_fold.Visible = false
  form.btn_unfold.Visible = true
  form.btn_show.Visible = false
  form.btn_guild.Visible = false
  form.showformflag = true
  form.notice_ui_ini = load_form_config_ini()
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("InteractTraceRec", form, "form_stage_main\\form_single_notice", "on_tvt_trace_rec_changed")
  if form.BelongType == TVT_TYPE_BANGPAI then
  end
  form.btn_help.Visible = false
  local type = form.BelongType
  if TVT_TYPE_DUOSHU == type or TVT_TYPE_HUSHU == type or TVT_TYPE_CITAN == type or TVT_TYPE_XUNLUO == type or TVT_TYPE_PIKONGZHANG == type then
    form.btn_help.Visible = true
  end
  if type == TVT_GUILD_STATION then
    form.btn_guild.Visible = true
  end
  local gui = nx_value("gui")
  local form_load = nx_value("form_common\\form_loading")
  local form_goto_cover = nx_value("form_stage_main\\form_goto_cover")
  if nx_is_valid(form_load) or nx_is_valid(form_goto_cover) then
    gui.Desktop:ToBack(form)
  else
    gui.Desktop:ToFront(form)
  end
end
function on_main_form_close(form)
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "del_form", 1, form.BelongType)
  on_leave(form)
  end_timer(form)
  if nx_find_custom(form, "data_rec") and nx_is_valid(form.data_rec) then
    form.data_rec:ClearChild()
    nx_destroy(form.data_rec)
  end
  if nx_find_custom(form, "notice_ui_ini") and nx_is_valid(form.notice_ui_ini) then
    form.notice_ui_ini:WriteInteger("Size", "Left", form.Left)
    form.notice_ui_ini:WriteInteger("Size", "Top", form.Top)
    form.notice_ui_ini:SaveToFile()
    nx_destroy(form.notice_ui_ini)
    form.notice_ui_ini = nx_null()
  end
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
  nx_destroy(form)
end
function IsTypeInRange(belong_type)
  if belong_type <= TVT_TYPE_ERROR or belong_type >= TVT_TYPE_MAX then
    return false
  end
  return true
end
function IsLimitTypeInRange(limit_type)
  if limit_type <= LIMIT_TYPE_ERROR or limit_type >= LIMIT_TYPE_MAX then
    return false
  end
  return true
end
function GetItemNum(form, item_type)
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_find_custom(form, "data_rec") or not nx_is_valid(form.data_rec) then
    return 0
  end
  local count = form.data_rec:GetChildCount()
  if count <= 0 then
    return 0
  end
  local num = 0
  for i = 0, count do
    local child = form.data_rec:GetChildByIndex(i)
    if nx_is_valid(child) and nx_number(child.limit_type) == nx_number(item_type) then
      num = num + 1
    end
  end
  return num
end
function get_format_time_text(time)
  local format_time = nx_widestr("")
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
  return nx_widestr(format_time) .. nx_widestr("<br>")
end
function change_form_size(form, time_num, count_num)
  if not nx_is_valid(form) then
    return
  end
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
  if form.btn_fold.Visible and nx_find_custom(form, "HaveTextInfo") and form.HaveTextInfo then
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
  if form.BelongType ~= TVT_TG_RANDOM_FIGHT then
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
    form.Left = form_left
    form.Top = form_top
  end
end
function on_delay_show_form_time(form)
  if not nx_is_valid(form) then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  local gui = nx_value("gui")
  local tvt_type = form.BelongType
  update_info(form)
  local type_info = TYPEINFO[tvt_type]
  if type_info ~= nil and table.getn(type_info) >= 2 then
    form.lbl_title.Text = nx_widestr(gui.TextManager:GetText(type_info[2]))
  end
  if nx_number(GetItemNum(form, LIMIT_TYPE_TIME)) > 0 then
    init_timer(form)
  end
  form:Show()
  if nx_find_custom(form, "showformflag") then
    form.Visible = form.showformflag
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
  change_form_size(form, GetItemNum(form, LIMIT_TYPE_TIME), GetItemNum(form, LIMIT_TYPE_COUNT))
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
end
function show_form(limit_type, tvt_type, title_name, item_data, max_count, ...)
  if not IsLimitTypeInRange(limit_type) then
    return
  end
  if not IsTypeInRange(tvt_type) then
    return
  end
  local instanceid = nx_string(FormInstanceID) .. nx_string(tvt_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_single_notice", true, false, instanceid)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.BelongType = tvt_type
  if not nx_find_custom(form, "data_rec") or not nx_is_valid(form.data_rec) then
    form.data_rec = nx_call("util_gui", "get_arraylist", SingleLimitDataRec .. nx_string(tvt_type))
  end
  local child = form.data_rec:GetChild(nx_string(title_name))
  if not nx_is_valid(child) then
    child = form.data_rec:CreateChild(nx_string(title_name))
  end
  child.data = item_data
  child.max_count = max_count
  child.limit_name_arg = nx_create("ArrayList")
  child.limit_type = limit_type
  local n = #arg
  if 0 < n then
    cache_title_args[title_name] = {}
    local title_arg = cache_title_args[title_name]
    for i = 1, #arg do
      table.insert(title_arg, arg[i])
    end
  end
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    delay_timer:Register(5000, -1, nx_current(), "on_delay_show_form_time", form, -1, -1)
    return
  end
  update_info(form)
  local type_info = TYPEINFO[tvt_type]
  if type_info ~= nil and table.getn(type_info) >= 2 then
    form.lbl_title.Text = nx_widestr(gui.TextManager:GetText(type_info[2]))
  end
  if 0 < nx_number(GetItemNum(form, LIMIT_TYPE_TIME)) then
    init_timer(form)
  end
  form:Show()
  if nx_find_custom(form, "showformflag") then
    form.Visible = form.showformflag
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
  change_form_size(form, GetItemNum(form, LIMIT_TYPE_TIME), GetItemNum(form, LIMIT_TYPE_COUNT))
end
function update_info(form)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "data_rec") then
    return false
  end
  if not nx_is_valid(form.data_rec) then
    return false
  end
  form.ImageControlGrid:Clear()
  form.ImageControlGrid1:Clear()
  form.ImageControlGrid.GridsPos = ""
  form.ImageControlGrid1.GridsPos = ""
  local count = form.data_rec:GetChildCount()
  if count <= 0 then
    return false
  end
  change_form_size(form, GetItemNum(form, LIMIT_TYPE_TIME), GetItemNum(form, LIMIT_TYPE_COUNT))
  local gui = nx_value("gui")
  local curTimeIndex = 0
  local curCountIndex = 0
  for index = 1, count do
    local child = form.data_rec:GetChildByIndex(index - 1)
    if nx_is_valid(child) then
      local limit_type = nx_number(child.limit_type)
      local title_name = nx_string(child.Name)
      if limit_type == LIMIT_TYPE_TIME then
        local server_end_time = nx_int64(child.data)
        local msgdelay = nx_value("MessageDelay")
        local server_cur_time = msgdelay:GetServerNowTime()
        local timer = (nx_int64(server_end_time) - nx_int64(server_cur_time)) / 1000
        if nx_int(timer) < nx_int(0) or nx_number(server_cur_time) == nx_number(0) then
          timer = 0
        end
        local format_timer = get_format_time_text(timer)
        local IniManager = nx_value("IniManager")
        local ini = IniManager:GetIniDocument(TimeConfigPath)
        local desc = gui.TextManager:GetFormatText(nx_string(title_name))
        local photo = " "
        local nflag = 1
        local sec_index = ini:FindSectionIndex(nx_string(title_name))
        if 0 <= sec_index then
          local title = ini:ReadString(sec_index, "Dest_Title", "")
          photo = ini:ReadString(sec_index, "Photo", " ")
          nflag = ini:ReadInteger(sec_index, "Flag", 1)
          desc = gui.TextManager:GetFormatText(title)
          local title_args = cache_title_args[title_name]
          if title_args ~= nil and 0 < #title_args then
            desc = gui.TextManager:GetFormatText(title, unpack(title_args))
          end
        end
        if photo == "" or photo == nil then
          photo = " "
        end
        form.ImageControlGrid:AddItem(curTimeIndex, nx_string(photo), nx_widestr(title_name), nx_int(0), nx_int(0))
        form.ImageControlGrid:SetItemAddInfo(curTimeIndex, 0, nx_widestr(desc))
        form.ImageControlGrid:ShowItemAddInfo(curTimeIndex, 0, true)
        form.ImageControlGrid:SetItemAddInfo(curTimeIndex, 1, nx_widestr(format_timer))
        form.ImageControlGrid:ShowItemAddInfo(curTimeIndex, 1, true)
        if nflag == 0 then
          form.ImageControlGrid:ChangeItemImageToBW(curTimeIndex, true)
        end
        curTimeIndex = curTimeIndex + 1
      elseif limit_type == LIMIT_TYPE_COUNT then
        local count = nx_number(child.data)
        local IniManager = nx_value("IniManager")
        local ini = IniManager:GetIniDocument(CountConfigPath)
        local sec_index = ini:FindSectionIndex(nx_string(title_name))
        local desc = gui.TextManager:GetFormatText(nx_string(title_name))
        local photo = " "
        local nflag = 1
        local count_info = nx_widestr(count)
        if 0 <= sec_index then
          local title = ini:ReadString(sec_index, "Dest_Title", "")
          photo = ini:ReadString(sec_index, "Photo", "")
          nflag = ini:ReadInteger(sec_index, "Flag", 1)
          desc = gui.TextManager:GetFormatText(title)
          if 0 < child.max_count then
            count_info = count_info .. nx_widestr("/") .. nx_widestr(child.max_count)
          elseif ini:FindSectionItemIndex(sec_index, "MaxCount") ~= -1 then
            local max_count = ini:ReadString(sec_index, "MaxCount", "")
            count_info = count_info .. nx_widestr("/") .. nx_widestr(max_count)
          end
          local title_args = cache_title_args[title_name]
          if title_args ~= nil and 0 < #title_args then
            desc = gui.TextManager:GetFormatText(title, unpack(title_args))
          end
        end
        if photo == "" or photo == nil then
          photo = " "
        end
        form.ImageControlGrid1:AddItem(curCountIndex, nx_string(photo), nx_widestr(title_name), nx_int(0), nx_int(0))
        form.ImageControlGrid1:SetItemAddInfo(curCountIndex, 0, nx_widestr(desc))
        form.ImageControlGrid1:ShowItemAddInfo(curCountIndex, 0, true)
        form.ImageControlGrid1:SetItemAddInfo(curCountIndex, 1, nx_widestr(count_info))
        form.ImageControlGrid1:ShowItemAddInfo(curCountIndex, 1, true)
        if nflag == 0 then
          form.ImageControlGrid1:ChangeItemImageToBW(curCountIndex, true)
        end
        curCountIndex = curCountIndex + 1
      end
    end
  end
end
function remove_item(limit_type, tvt_type, title_name)
  if not IsLimitTypeInRange(limit_type) then
    return
  end
  if not IsTypeInRange(tvt_type) then
    return
  end
  local instanceid = nx_string(FormInstanceID) .. nx_string(tvt_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_single_notice", false, false, instanceid)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "data_rec") or not nx_is_valid(form.data_rec) then
    form:Close()
    return
  end
  local count = form.data_rec:GetChildCount()
  if count <= 0 then
    form:Close()
    return
  end
  if not nx_find_custom(form, "HaveTextInfo") then
    form:Close()
    return
  end
  for index = count, 1, -1 do
    local child = form.data_rec:GetChildByIndex(index - 1)
    if nx_is_valid(child) and nx_number(child.limit_type) == nx_number(limit_type) and nx_string(child.Name) == nx_string(title_name) then
      form.data_rec:RemoveChildByIndex(index - 1)
    end
  end
  local time_num = GetItemNum(form, LIMIT_TYPE_TIME)
  local count_num = GetItemNum(form, LIMIT_TYPE_COUNT)
  if 0 >= nx_number(time_num) and 0 >= nx_number(count_num) and not form.HaveTextInfo then
    form:Close()
    return
  end
  update_info(form)
  change_form_size(form, time_num, count_num)
end
function check_close_form()
  for i = 1, table.getn(TYPEINFO) do
    local type_info = TYPEINFO[i]
    local tvt_type = nx_number(type_info[1])
    local instanceid = nx_string(FormInstanceID) .. nx_string(i)
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_single_notice", false, false, instanceid)
    if nx_is_valid(form) then
      local time_num = GetItemNum(form, LIMIT_TYPE_TIME)
      local count_num = GetItemNum(form, LIMIT_TYPE_COUNT)
      if nx_number(time_num) <= 0 and nx_number(count_num) <= 0 and not form.HaveTextInfo then
        form:Close()
      end
    end
  end
end
function init_timer(form)
  local common_execute = nx_value("common_execute")
  common_execute:AddExecute("SingleNotice", form, nx_float(1))
end
function end_timer(form)
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("SingleNotice", form)
end
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "data_rec") or not nx_is_valid(form.data_rec) then
    form:Close()
    return
  end
  local msgdelay = nx_value("MessageDelay")
  local CurServerTime = msgdelay:GetServerNowTime()
  local delitem = false
  local count = form.data_rec:GetChildCount()
  for index = count, 1, -1 do
    local child = form.data_rec:GetChildByIndex(index - 1)
    if nx_is_valid(child) and nx_number(child.limit_type) == nx_number(LIMIT_TYPE_TIME) and nx_number(child.data) <= nx_number(CurServerTime) and nx_number(CurServerTime) ~= nx_number(0) then
      delitem = true
      form.data_rec:RemoveChildByIndex(index - 1)
    end
  end
  local time_num = GetItemNum(form, LIMIT_TYPE_TIME)
  local count_num = GetItemNum(form, LIMIT_TYPE_COUNT)
  if nx_number(time_num) <= 0 then
    end_timer(form)
    if nx_number(count_num) <= 0 then
      form:Close()
      return
    end
  end
  if delitem then
    update_info(form)
  else
    local count = form.data_rec:GetChildCount()
    for index = 1, count do
      local child = form.data_rec:GetChildByIndex(index - 1)
      if nx_is_valid(child) then
        local limit_type = nx_number(child.limit_type)
        local title_name = nx_string(child.Name)
        if limit_type == LIMIT_TYPE_TIME then
          local index = form.ImageControlGrid:FindItem(nx_widestr(title_name))
          if 0 <= index then
            local server_end_time = nx_int64(child.data)
            local timer = (nx_int64(server_end_time) - nx_int64(CurServerTime)) / 1000
            if nx_int(timer) < nx_int(0) or nx_int64(CurServerTime) == nx_int64(0) then
              timer = 0
            end
            local format_timer = get_format_time_text(timer)
            form.ImageControlGrid:SetItemAddInfo(index, 1, nx_widestr(format_timer))
            form.ImageControlGrid:ShowItemAddInfo(index, 1, true)
          end
        elseif limit_type == LIMIT_TYPE_COUNT then
          local index = form.ImageControlGrid1:FindItem(nx_widestr(title_name))
          if 0 <= index then
            local count = nx_number(child.data)
            local IniManager = nx_value("IniManager")
            local ini = IniManager:GetIniDocument(CountConfigPath)
            local sec_index = ini:FindSectionIndex(nx_string(title_name))
            local count_info = nx_widestr(count)
            if 0 <= sec_index and ini:FindSectionItemIndex(sec_index, "MaxCount") ~= -1 then
              local max_count = ini:ReadString(sec_index, "MaxCount", "")
              count_info = count_info .. nx_widestr("/") .. nx_widestr(max_count)
            end
            form.ImageControlGrid1:SetItemAddInfo(index, 1, nx_widestr(count_info))
            form.ImageControlGrid1:ShowItemAddInfo(index, 1, true)
          end
        end
      end
    end
    change_form_size(form, time_num, count_num)
  end
end
function on_ImageControlGrid_mousein_grid(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index_name = self:GetItemName(index)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(TimeConfigPath)
  local sec_index = ini:FindSectionIndex(nx_string(index_name))
  if sec_index < 0 then
    return
  end
  local tips_text = ini:ReadString(sec_index, "TipsText", "")
  if nx_string(tips_text) == "" then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string(tips_text))
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
  local index_name = self:GetItemName(index)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(CountConfigPath)
  local sec_index = ini:FindSectionIndex(nx_string(index_name))
  if sec_index < 0 then
    return
  end
  local tips_text = ini:ReadString(sec_index, "TipsText", "")
  if nx_string(tips_text) == "" then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string(tips_text))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_ImageControlGrid1_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
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
  if tvt_type ~= nil and tvt_type ~= -1 then
    send_server_msg(g_msg_giveup, tvt_type)
  end
  local g_func = {
    [TVT_TYPE_JINDI] = {
      src = "form_stage_main\\form_clone\\form_clone_info",
      funcname = "client_request_leave_clone"
    },
    [TVT_TYPE_BANGFEI] = {
      src = "form_stage_main\\form_offline\\form_offline_abduct_tip",
      funcname = "GiveupAbduct"
    },
    [TVT_TYPE_FANGHUO] = {
      src = "form_stage_main\\form_guild_fire\\form_fire_info",
      funcname = "GiveupFireTask"
    },
    [TVT_TYPE_JIUHUO] = {
      src = "form_stage_main\\form_guild_fire\\form_fire_info",
      funcname = "GiveupWaterTask"
    },
    [TVT_TYPE_BATTLE] = {
      src = "form_stage_main\\form_battlefield\\form_battlefield_join",
      funcname = "request_leave_battlefield"
    },
    [TVT_TYPE_ZHUIZONG] = {
      src = "form_stage_main\\form_relation\\super_book_trace\\form_npcqueryrole",
      funcname = "endzhibao"
    },
    [LIMIT_TVT_BOSSHELER] = {
      src = "form_stage_main\\form_clone\\form_clone_killer",
      funcname = "cancel_apply_killer"
    },
    [TVT_BALANCE_WAR] = {
      src = "form_stage_main\\form_battlefield\\form_battlefield_balance_result",
      funcname = "custom_request_quit_balance_war"
    },
    [LIMIT_TVT_WUDAO_WAR] = {
      src = "form_stage_main\\form_battlefield_wulin\\wudao_util",
      funcname = "request_quit_wudao_war"
    },
    [LIMIT_TVT_LUAN_DOU] = {
      src = "form_stage_main\\form_war_scuffle\\luandou_util",
      funcname = "confirm_quit"
    },
    [LIMIT_TVT_JYF_CROSS_PLAYER] = {
      src = "custom_sender",
      funcname = "custom_quit_jiuyang_faculty"
    },
    [LIMIT_TVT_WUDAO_YANWU] = {
      src = "form_stage_main\\form_war_scuffle\\form_balance_total",
      funcname = "on_btn_quit_click"
    },
    [LIMIT_TVT_HORSE_RACE] = {
      src = "form_stage_main\\form_war_scuffle\\form_balance_total",
      funcname = "on_btn_quit_horse_race_click"
    },
    [LIMIT_TVT_ROGUE] = {
      src = "form_stage_main\\form_rogue",
      funcname = "request_quit_rogue"
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
function on_btn_fold_click(btn)
  local form = btn.ParentForm
  local nType = form.BelongType
  if not IsTypeInRange(nType) then
    return
  end
  form.btn_unfold.Visible = true
  form.btn_fold.Visible = false
  change_form_size(form, GetItemNum(form, LIMIT_TYPE_TIME), GetItemNum(form, LIMIT_TYPE_COUNT))
end
function on_btn_unfold_click(btn)
  local form = btn.ParentForm
  local nType = form.BelongType
  if not IsTypeInRange(nType) then
    return
  end
  form.btn_unfold.Visible = false
  form.btn_fold.Visible = true
  change_form_size(form, GetItemNum(form, LIMIT_TYPE_TIME), GetItemNum(form, LIMIT_TYPE_COUNT))
end
function on_btn_minimize_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  if nx_int(form.BelongType) == nx_int(TVT_TYPE_JHBOSS2) then
    local boss_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_JiangHu_Boss", false, false)
    if nx_is_valid(boss_form) then
      boss_form.Visible = false
    end
  end
  form.showformflag = form.Visible
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "check_cbtn_state", 1, form.BelongType)
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
  if form.BelongType == TVT_TYPE_JHBOSS2 then
    util_show_form("form_stage_main\\form_task\\form_JiangHu_Boss", true)
  end
  form.btn_show.Visible = false
  form.groupbox_time.Visible = true
  form.groupbox_desc.Visible = true
  form.groupbox_extend.Visible = true
  change_form_size(form, GetItemNum(form, LIMIT_TYPE_TIME), GetItemNum(form, LIMIT_TYPE_COUNT))
end
function on_btn_help_click(btn)
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
  if TVT_TYPE_DUOSHU == nType then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_duoshu_help"), "1")
  elseif TVT_TYPE_HUSHU == nType then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_hushu_help"), "1")
  elseif TVT_TYPE_CITAN == nType then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_citan_help"), "1")
  elseif TVT_TYPE_XUNLUO == nType then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_xunluo_help"), "1")
  elseif TVT_TYPE_PIKONGZHANG == nType then
    nx_execute("form_stage_main\\form_main\\form_main_pikongzhang_desc", "show_form")
  end
end
function on_btn_guild_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "BelongType") then
    return
  end
  if TVT_GUILD_STATION ~= form.BelongType then
    return
  end
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_task", "open_form")
end
function on_tvt_trace_rec_changed(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if optype == "del" and optype == "clear" then
    return
  end
  show_tvt_trace_info()
end
function show_tvt_trace_info()
  local tvt_mgr = nx_value("InteractManager")
  if not nx_is_valid(tvt_mgr) then
    return false
  end
  local tvt_type = tvt_mgr:GetCurrentTvtType()
  if nx_number(tvt_type) < 0 then
    return false
  end
  if nx_number(tvt_type) == ITT_HUASHAN_FIGHTER or nx_number(tvt_type) == ITT_HUASHAN_LOOK then
    return false
  end
  if nx_number(tvt_type) == ITT_EGWAR then
    return false
  end
  if nx_number(tvt_type) == ITT_WEATHERWAR then
    return false
  end
  if nx_number(tvt_type) == TVT_XINMO then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindRecord("InteractTraceRec") then
    return false
  end
  local form_type = conver_tvt_type(tvt_type)
  if nx_number(form_type) == TVT_TYPE_COMMON then
    return false
  end
  local instanceid = nx_string(FormInstanceID) .. nx_string(form_type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_single_notice", true, false, instanceid)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  if not nx_find_custom(form, "BelongType") then
    form.BelongType = form_type
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
    local delay_timer = nx_value("timer_game")
    delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
    local stage_main_flag = nx_value("stage_main")
    local loading_flag = nx_value("loading")
    if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
      delay_timer:Register(5000, -1, nx_current(), "on_delay_show_form_time", form, -1, -1)
    else
      form:Show()
      if nx_find_custom(form, "showformflag") then
        form.Visible = form.showformflag
      end
    end
  end
  form.mltbox_desc:Clear()
  form.HaveTextInfo = false
  local trace_info = tvt_mgr.TraceInfo
  local trace_type = math.floor(trace_info / 1000 - 1)
  local trace_step = math.floor(math.mod(trace_info, 1000))
  local rows = client_player:GetRecordRows("InteractTraceRec")
  for i = 1, rows do
    local item_type = client_player:QueryRecord("InteractTraceRec", i - 1, 0)
    local item_id = client_player:QueryRecord("InteractTraceRec", i - 1, 1)
    if nx_number(item_type) == nx_number(tvt_type) then
      local item_info = client_player:QueryRecord("InteractTraceRec", i - 1, 2)
      local text = util_split_wstring(nx_widestr(item_info), ";")
      local parse_text = nx_widestr("")
      if nx_number(trace_type) == nx_number(tvt_type) and nx_number(trace_step) == nx_number(item_id) then
        parse_text = nx_widestr(parse_text) .. nx_widestr(g_icon)
      else
        parse_text = nx_widestr(parse_text) .. nx_widestr(g_normal_icon)
      end
      parse_text = nx_widestr(parse_text) .. nx_widestr(format_string(unpack(text)))
      form.mltbox_desc:AddHtmlText(nx_widestr(parse_text), nx_int(item_id))
      form.HaveTextInfo = true
    end
  end
  form.btn_fold.Visible = true
  form.btn_unfold.Visible = false
  change_form_size(form, GetItemNum(form, LIMIT_TYPE_TIME), GetItemNum(form, LIMIT_TYPE_COUNT))
  return true
end
function clear_tvt_trace_info(tvt_type)
  local form_type = conver_tvt_type(tvt_type)
  if not IsTypeInRange(form_type) then
    return
  end
  ClearText(form_type)
end
function conver_tvt_type(tvt_type)
  for i = 1, TVT_TYPE_MAX do
    local temp = TYPEINFO[i]
    if temp ~= nil and nx_number(temp[1]) == nx_number(tvt_type) then
      return i
    end
  end
  return TVT_TYPE_COMMON
end
function format_string(...)
  local msg = {}
  for i = 1, table.getn(arg) do
    local iteminfo = util_split_wstring(arg[i], ",")
    local data_type = nx_number(iteminfo[1])
    if data_type == 2 or data_type == 3 then
      table.insert(msg, nx_int(iteminfo[2]))
    elseif data_type == 4 or data_type == 5 then
      table.insert(msg, nx_float(iteminfo[2]))
    elseif data_type == 6 then
      table.insert(msg, nx_string(iteminfo[2]))
    elseif data_type == 7 then
      table.insert(msg, iteminfo[2])
    end
  end
  return nx_widestr(util_format_string(unpack(msg)))
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
function update_gumu_rescue_progress(cur_count, total_count)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local desc = gui.TextManager:GetFormatText("gmp_qqzr_plan", nx_int(cur_count), nx_int(total_count))
  NotifyText(TVT_GUMU_RESCUE, desc)
end
function check_jyf_form()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local is_attacker = client_player:QueryProp("IsJYFaucltyAttacker")
  if nx_int(is_attacker) == nx_int(1) then
    return
  end
  remove_item(LIMIT_TYPE_TIME, 109, "time_jysg_jq_103")
end
