require("const_define")
require("define\\request_type")
require("share\\client_custom_define")
require("share\\capital_define")
require("util_functions")
require("util_gui")
require("util_role_prop")
require("player_state\\state_const")
require("custom_sender")
BEG_INI_FILE = "share\\Life\\BegInfo.ini"
REQUEST_ARRAY = {}
INDEX_REQUEST_TYPE = 1
INDEX_REQUEST_PLAYER = 2
INDEX_REQUEST_PARAMS = 3
INDEX_REQUEST_BUTTON = 4
local BUI_HEIGHT = 60
local BUT_WIDTH = 60
local LBL_HEIGHT = 20
local LBL_WIDTH = 60
icon_limite = {
  REQUESTTYPE_ORIGIN_NOTIFY,
  REQUESTTYPE_SOLE_PROMPT,
  REQUESTTYPE_FRESHMAN_JIAYUAN,
  REQUESTTYPE_FRESHMAN_SWORN,
  REQUESTTYPE_ROYAL_TREASURE,
  REQUESTTYPE_SANMENG_MATCH
}
request_icon = {
  [REQUESTTYPE_TEAMREQUEST] = "team_mark",
  [REQUESTTYPE_EXCHANGE] = "business_mark",
  [REQUESTTYPE_GUILD] = "icon\\func\\default.png",
  [REQUESTTYPE_FRIEND] = "freindship_mark",
  [REQUESTTYPE_BUDDY] = "freindship_mark",
  [REQUESTTYPE_ACTION] = "icon\\func\\default.png",
  [REQUESTTYPE_INVITE_STUTDENT] = "icon\\func\\default.png",
  [REQUESTTYPE_INVITE_TEACHER] = "icon\\func\\default.png",
  [REQUESTTYPE_FREE_TEACHRELATION] = "icon\\func\\default.png",
  [REQUESTTYPE_CLIECKNEWS] = "icon\\func\\default.png",
  [REQUESTTYPE_CORPS] = "icon\\func\\default.png",
  [REQUESTTYPE_TRANS_TOOL] = "icon\\func\\default.png",
  [REQUESTTYPE_CHALLENGE] = "challenge_mark",
  [REQUESTTYPE_INVITETEAM] = "team_mark",
  [REQUESTTYPE_NEIG_PK] = "icon\\func\\default.png",
  [REQUESTTYPE_IMPART] = "icon\\func\\default.png",
  [REQUESTTYPE_RANK_CHALLENGE] = "icon\\func\\default.png",
  [REQUESTTYPE_FORTUNETELLING] = "qiugua_mark",
  [REQUESTTYPE_FORTUNETELLINGOTHER] = "qiugua_mark",
  [REQUESTTYPE_BEG] = "qitao_mark",
  [REQUESTTYPE_ASK_GUILD_LEADER_FOR_SCHOOL_WAR] = "gui\\special\\life\\puzzle_quest\\common\\quantou1-on.png",
  [REQUESTTYPE_ASK_GUILD_PEOPLE_FOR_SCHOOL_WAR] = "gui\\special\\life\\puzzle_quest\\common\\quantou1-on.png",
  [REQUESTTYPE_ASK_SCHOOL_PEOPLE_FOR_SCHOOL_WAR] = "gui\\special\\btn_main\\btn_challenge_down.png",
  [REQUESTTYPE_ASK_SCHOOL_PEOPLE_SWITCH] = "gui\\special\\xxzhaoshi-outon.png",
  [REQUESTTYPE_ORIGIN_NOTIFY] = "shenfen",
  [REQUESTTYPE_SOLE_PROMPT] = "sole_prompt_",
  [REQUESTTYPE_ANSHAO_NOTIFY] = "gui\\special\\life\\puzzle_quest\\dushi\\yellow_1.png",
  [REQUESTTYPE_ANSHAO_PLAYER_MASS] = "gui\\special\\life\\puzzle_quest\\dushi\\yellow_1.png",
  [REQUESTTYPE_ROB_PRISON_FRIEND] = "jieyu",
  [REQUESTTYPE_SYSTEM_FRIENDS] = "gui\\special\\sns_new\\btn_systemfriend_out.png",
  [REQUESTTYPE_MASS_SCHOOL_WAR] = "gui\\special\\xxzhaoshi-outon.png",
  [PLAYER_REQUESTTYPE_LEITAI_PK] = "leitai_mark",
  [REQUESTTYPE_WORLD_LEITAI] = "leitai_mark",
  [REQUESTTYPE_PLAYER_LEITAI_PK_NOTICE] = "leitai_mark",
  [REQUESTTYPE_JOIN_FACULTY] = "train_mark",
  [REQUESTTYPE_INVITE_FACULTY] = "train_mark",
  [REQUESTTYPE_PLAY_GEMGAME] = "sole_prompt_0",
  [REQUESTTYPE_LEITAI_REVENGE] = "leitai_mark",
  [REQUESTTYPE_WQGAME] = "sole_prompt_0",
  [REQUESTTYPE_ROB_PRISON_FOE] = "jieyu",
  [REQUESTTYPE_MULTI_RIDE] = "ride_other",
  [REQUESTTYPE_PRISONBEHEAD_LOOK_FRIEND] = "behead_look",
  [REQUESTTYPE_PRISONBEHEAD_LOOK_ENEMY] = "behead_look",
  [REQUESTTYPE_GUILD_WATER_TASK] = "jiuhuo",
  [REQUESTTYPE_ASK_LEAGUE_JOIN_GUILDWAR] = "gui\\language\\ChineseS\\animations\\sole_prompt_4\\sole_prompt_4_1.png",
  [REQUESTTYPE_BATTLEFIELD_SWITCH] = "gui\\language\\ChineseS\\battlefield\\battle_join.png",
  [REQUESTTYPE_TVT_INFO] = "challenge_mark",
  [REQUESTTYPE_SCHOOL_VOTE] = "vote_mark",
  [REQUESTTYPE_ASK_SWITCH_TO_WORLD_WAR] = "gui\\special\\WorldWar\\menu\\zhanqi2.png",
  [REQUESTTYPE_ASK_SIGNUP_WORLD_WAR] = "gui\\special\\WorldWar\\menu\\duilie.png",
  [REQUESTTYPE_DIVORCE] = "marry_btn",
  [REQUESTTYPE_WEDDING_LOOK] = "marry_btn",
  [REQUESTTYPE_BAI_SHI] = "gui\\special\\XD_on.png",
  [REQUESTTYPE_SHOU_TU] = "gui\\special\\XD_on.png",
  [REQUESTTYPE_SHITU_CALL] = "gui\\special\\XD_on.png",
  [REQUESTTYPE_SHITU_INHERIT_HOMEPOINT] = "gui\\special\\XD_on.png",
  [REQUESTTYPE_REMOVE_SHITU_RELATION] = "gui\\special\\XD_on.png",
  [REQUESTTYPE_HUASHAN_JOIN_MATCH_GAME] = "hs_btn",
  [REQUESTTYPE_HUASHAN_SHOW_FORM] = "hs_btn",
  [REQUESTTYPE_SCHOOL_POSE_FIGHT] = "shimen_mark",
  [REQUESTTYPE_SBKILLER] = "SuperBook_kill",
  [REQUESTTYPE_EGWAR] = "bt_match",
  [REQUESTTYPE_BATTLEFIELD_WRESTLE_HELP] = "gui\\language\\ChineseS\\battlefield\\battle_join.png",
  [REQUESTTYPE_TIGUAN_DANSHUA_INVITE] = "gui\\special\\tiguan\\tiguan_invite.png",
  [REQUESTTYPE_MAKE_ITEM] = "mask_make",
  [REQUESTTYPE_TAOHUA_LEAD] = "thd_help_mark",
  [REQUESTTYPE_ANSWER_QUESTION] = "gui\\language\\ChineseS\\answer\\answer_tishi.png",
  [REQUESTTYPE_ENTRY_AWARD_1] = "bt_match_2",
  [REQUESTTYPE_ENTRY_AWARD_2] = "bt_match_2",
  [REQUESTTYPE_ENTRY_AWARD_3] = "bt_match_2",
  [REQUESTTYPE_ENTRY_AWARD_4] = "bt_match_2",
  [REQUESTTYPE_ENTRY_AWARD_5] = "bt_match_2",
  [REQUESTTYPE_CAPTURE_CITY_PRE] = "bt_match_2",
  [REQUESTTYPE_TREASURE_MORE_REFRESH] = "gui\\special\\WorldWar\\menu\\lx_menu_xiangzi.png",
  [REQUESTTYPE_KILLER_FIND_ME_ADV] = "gui\\special\\WorldWar\\menu\\xiashi02_qy_01.png",
  [REQUESTTYPE_NEIGHBOUR] = "home",
  [REQUESTTYPE_USE_ITEM_ACCOST] = "accost_mark",
  [REQUESTTYPE_ACTIVITY_PARTNER] = "jieban_hd",
  [REQUESTTYPE_TRAP_OPEN_MINIGAME] = "sole_prompt_0",
  [REQUESTTYPE_TRAP_TRANS_TO] = "sole_prompt_0",
  [REQUESTTYPE_ITEM_COURSE] = "item_newworld",
  [REQUESTTYPE_FRESHMAN_JIAYUAN] = "gui\\special\\home\\yindao\\btn_home_yd.png",
  [REQUESTTYPE_GUMU_CHALLENGE] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_GUMU_DIG_TREASURE] = "gui\\language\\ChineseS\\battlefield\\battle_join_out.png",
  [REQUESTTYPE_ANCIENTTOMB_SRTX] = "gui\\special\\srtx\\srtx.png",
  [REQUESTTYPE_ANCIENTTOMB_LOT] = "gui\\animations\\jiaohu\\jh_1.png",
  [REQUESTTYPE_ANCIENTTOMB_REMOVE_LOT] = "gui\\animations\\jiaohu\\1.png",
  [REQUESTTYPE_GUMU_REFINE] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_GUMU_ATTACK] = "gui\\language\\ChineseS\\battlefield\\battle_join_out.png",
  [REQUESTTYPE_GUMU_GUARD] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_BODYGUARD_SMDH_TEAM] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_CHANGFENG_GOTE] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_CHANGFENG_SEIZE] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_SSG_PROBATION] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_GUILD_CROSSCLONE_CAN_ENTRY] = "gui\\special\\btn_main40rh\\guild_war_out.png",
  [REQUESTTYPE_TEAM_CONFIRM] = "gui\\animations\\jiaohu\\jh_1.png",
  [REQUESTTYPE_SSG_MRLX] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_NEW_TERRITORY_PVP] = "gui\\special\\btn_main\\battle_on.png",
  [REQUESTTYPE_FRESHMAN_SWORN] = "sworn_new",
  [REQUESTTYPE_SWORN_SUMMON] = "gui\\special\\sworn\\btn_summon.png",
  [REQUESTTYPE_RED_PACKET] = "gui\\special\\hongbao\\btn_hongbao_down.png",
  [REQUESTTYPE_TRANSTO_CANWU_SCENE] = "hs_btn",
  [REQUESTTYPE_WXJ_MDSS] = "gui\\special\\btn_main\\btn_newschool_smdh_on.png",
  [REQUESTTYPE_WXJ_LSGLX] = "gui\\special\\btn_main\\btn_newschool_smdh_on.png",
  [REQUESTTYPE_SHENG_SI_FU] = "gui\\special\\btn_main\\shengsifu_yaoqing.png",
  [REQUESTTYPE_FLEE_BACHELOR] = "gui\\special\\btn_main\\btn_11_qftd.png",
  [REQUESTTYPE_DAMO_PK] = "gui\\special\\btn_main\\battle_on.png",
  [REQUESTTYPE_YEAR_BOSS] = "gui\\special\\btn_main\\btn_ns_checked.png",
  [REQUESTTYPE_OUTLAND_WAR_VOTE] = "outland_war_vote",
  [REQUESTTYPE_FOURFAMILY_ACTIVITY_MURONG] = "FourFamilyActivity",
  [REQUESTTYPE_FOURFAMILY_ACTIVITY_DONGFANG1] = "FourFamilyActivity",
  [REQUESTTYPE_FOURFAMILY_ACTIVITY_YANMEN] = "FourFamilyActivity",
  [REQUESTTYPE_FOURFAMILY_ACTIVITY_NANGONG1] = "FourFamilyActivity",
  [REQUESTTYPE_FOURFAMILY_ACTIVITY_NANGONG2] = "FourFamilyActivity",
  [REQUESTTYPE_FOURFAMILY_ACTIVITY_DONGFANG2] = "FourFamilyActivity",
  [REQUESTTYPE_TEACHER_INVITE] = "gui\\language\\ChineseS\\battlefield\\battle_join_on.png",
  [REQUESTTYPE_NEW_BAI_SHI] = "gui\\special\\XD_on.png",
  [REQUESTTYPE_NEW_SHOU_TU] = "gui\\special\\XD_on.png",
  [REQUESTTYPE_HOME_GAME_INVITE] = "gui\\special\\btn_main\\home_out.png",
  [REQUESTTYPE_INVITE_LEAGUE] = "gui\\special\\btn_guild_out.png",
  [REQUESTTYPE_BALANCE_WAR_MATCHING_CONFIRM] = "gui\\language\\ChineseS\\battlefield\\battle_join.png",
  [REQUESTTYPE_AGREE_WAR_IN] = "gui\\special\\btn_main40rh\\yuezhan_2_out.png",
  [REQUESTTYPE_AGREE_WAR_REQ] = "gui\\special\\btn_main40rh\\yuezhan_out.png",
  [REQUESTTYPE_GUILD_LUCK_TASK] = "gui\\guild\\guild_jingbiao\\mengyoucanzhan.png",
  [REQUESTTYPE_WUDAO_WAR_GO] = "gui\\language\\ChineseS\\battlefield\\battle_join.png",
  [REQUESTTYPE_HIDE_PLAYER] = "gui\\special\\btn_fresh\\book_over.png",
  [REQUESTTYPE_AGREE_WAR_MEMBER_IN] = "gui\\special\\btn_main40rh\\yuezhan_member_in.png",
  [REQUESTTYPE_WUDAO_ROOM_INVITE] = "gui\\language\\ChineseS\\battlefield\\battle_join.png",
  [REQUESTTYPE_JIUYANG_CALLHELPER] = "sole_prompt_10",
  [REQUESTTYPE_GUILD_MEMBER_PLUS] = "gui\\guild\\guild_jingbiao\\mengyoucanzhan.png",
  [REQUESTTYPE_LUAN_DOU_GO] = "gui\\special\\btn_main40rh\\btn_scuffle_out.png",
  [REQUESTTYPE_LUAN_DOU_WEEK_PUSH] = "gui\\special\\btn_main40rh\\btn_scuffle_out.png",
  [REQUESTTYPE_TAOSHA_GO] = "dataosha",
  [REQUESTTYPE_JIUYANG_CALLDEFENDER] = "sole_prompt_10",
  [REQUESTTYPE_DUALPLAYER_PARTNER] = "gui\\special\\gujsrltzbs\\gujlong\\long9.png",
  [REQUESTTYPE_DUALPLAYER_PARTNER_TIGUAN] = "gui\\special\\gujsrltzbs\\gujlong\\long9.png",
  [REQUESTTYPE_DUALPLAYER_TIGUAN] = "gui\\special\\gujsrltzbs\\gujlong\\long9.png",
  [REQUESTTYPE_HORSE_RACE_GO] = "gui\\special\\btn_main40rh\\btn_scuffle_out.png",
  [REQUESTTYPE_CROSS_STATION_WAR_GO] = "ani_guild_kuafu",
  [REQUESTTYPE_DAY_PACKET] = "gui\\special\\hongbao\\btn_hongbao_down.png",
  [REQUESTTYPE_CHAMPION] = "gui\\language\\ChineseS\\btn_main\\btn_guild_out.png",
  [REQUESTTYPE_MAZE_HUNT] = "gui\\special\\btn_main\\mmzw_mpfg_down.png",
  [REQUESTTYPE_JZ] = "icon\\func\\open_form_relationship.png",
  [REQUESTTYPE_LEAGUE_MATCHES] = "gui\\language\\ChineseS\\btn_main\\btn_guild_out.png"
}
function Init(form_main)
  if not nx_is_valid(form_main) then
    form_main = nx_value(GAME_GUI_MAIN)
  end
  if not nx_is_valid(form_main) then
    return
  end
  form_main.g_top = form_main.Height / 3 * 2
  form_main.g_start_left = form_main.Width / 3 * 2
  form_main.g_to_desktop_right = form_main.Width / 3 * 1.2
  form_main.g_image_width = 60
  form_main.g_image_inter = 10
  form_main.g_move_speed = 5
  form_main.g_sametime_show_count = 5
end
function clear_request()
  if nx_running(nx_current(), "begin_count") then
    nx_kill(nx_current(), "begin_count")
  end
  local form_main = nx_value(GAME_GUI_MAIN)
  local gui = nx_value("gui")
  local size = table.maxn(REQUEST_ARRAY)
  for i = 1, size do
    if REQUEST_ARRAY[i] ~= nil then
      local btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
      if nx_is_valid(btn) and nx_find_custom(btn, "label") and nx_is_valid(btn.label) then
        if nx_is_valid(form_main) then
          form_main:Remove(btn.label)
          form_main:Remove(btn)
        end
        gui:Delete(btn.label)
        gui:Delete(btn)
      end
    end
  end
  REQUEST_ARRAY = {}
end
function get_recv_msg_photo(sect_name, key_name)
  local ini = get_ini("ini\\ui\\sysnotice\\sysnotice.ini")
  local sect_index = ini:FindSectionIndex(sect_name)
  if 0 <= sect_index then
    return ini:ReadString(sect_index, key_name, "gui\\common\\imagegrid_new\\suo.png")
  end
  return "gui\\common\\imagegrid_new\\suo.png"
end
function clear_item()
  local gui = nx_value("gui")
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  for i = 1, table.maxn(REQUEST_ARRAY) do
    if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_CROSS_STATION_WAR_GO then
      local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
      if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
        form_main:Remove(old_btn.label)
        form_main:Remove(old_btn)
        gui:Delete(old_btn.label)
        gui:Delete(old_btn)
      end
      table.remove(REQUEST_ARRAY, i)
      break
    end
  end
end
function add_request_item(request_type, request_player, left_time, param1, param2, param3)
  local stage = nx_value("stage")
  if stage ~= "main" then
    return
  end
  local gui = nx_value("gui")
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  if is_need_filter(request_type) then
    return
  end
  if (REQUESTTYPE_TEAMREQUEST == request_type or REQUESTTYPE_INVITETEAM == request_type) and nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "is_filter_player", nx_widestr(request_player)) then
    return
  end
  local WarFlag = player_in_pingheng_war()
  if WarFlag then
    for i = 1, #icon_limite do
      if nx_int(request_type) == nx_int(icon_limite[i]) then
        return
      end
    end
  end
  local button = gui:Create("Button")
  button.NormalImage = "icon\\func\\default.png"
  button.FocusImage = "icon\\func\\default.png"
  button.PushImage = "icon\\func\\default.png"
  if request_type == REQUESTTYPE_HELPER then
    button.NormalImage = param1
    button.FocusImage = param2
    button.PushImage = param3
  elseif request_type == REQUESTTYPE_SOLE_PROMPT then
    if -1 < param1 then
      local sole_prompt_icon = nx_string(request_icon[request_type]) .. nx_string(param1)
      button.NormalImage = sole_prompt_icon
      button.FocusImage = sole_prompt_icon
      button.PushImage = sole_prompt_icon
    end
  elseif request_type == REQUESTTYPE_SANMENG_MATCH then
    button.NormalImage = "sole_prompt_smzb"
    button.FocusImage = "sole_prompt_smzb"
    button.PushImage = "sole_prompt_smzb"
    left_time = -1
  elseif request_type == REQUESTTYPE_ROYAL_TREASURE then
    button.NormalImage = "wcbz_yd"
    button.FocusImage = "wcbz_yd"
    button.PushImage = "wcbz_yd"
    left_time = -1
  elseif request_type == REQUESTTYPE_LEAVE_SCHOOL then
    button.NormalImage = "sole_prompt_smzb"
    button.FocusImage = "sole_prompt_smzb"
    button.PushImage = "sole_prompt_smzb"
    left_time = -1
  elseif request_type >= REQUESTTYPE_MIN and request_type <= REQUESTTYPE_MAX then
    if request_type == REQUESTTYPE_LUAN_DOU_WEEK_PUSH then
      left_time = 30
    end
    button.NormalImage = request_icon[request_type]
    button.FocusImage = request_icon[request_type]
    button.PushImage = request_icon[request_type]
  end
  if request_type == REQUESTTYPE_LIFE_JOB_SHARE then
    button.NormalImage = "sole_prompt_0"
    button.FocusImage = "sole_prompt_0"
    button.PushImage = "sole_prompt_0"
  end
  if request_type == REQUESTTYPE_ACTION then
    button.NormalImage = "jiaohu"
    button.FocusImage = "jiaohu"
    button.PushImage = "jiaohu"
  end
  if request_type == REQUESTTYPE_CHALLENGE then
    nx_execute("util_sound", "play_link_sound", "fight_pk_tips.wav", nx_value("role"), 0, 0, 0, 1, 5, 1, "snd\\action\\fight\\other\\")
  end
  if request_type == REQUESTTYPE_ROB_PRISON_FOE then
    left_time = 10
  end
  if request_type == REQUESTTYPE_SBKILLER or request_type == REQUESTTYPE_JZ then
    left_time = 30
  end
  if request_type == REQUESTTYPE_FRESHMAN_JIAYUAN then
    left_time = -1
  end
  if request_type == REQUESTTYPE_CHAMPION then
    left_time = 60
  end
  if request_type == REQUESTTYPE_DUALPLAYER_PARTNER then
    button.NormalImage = "jiaohu"
    button.FocusImage = "jiaohu"
    button.PushImage = "jiaohu"
  end
  if request_type == REQUESTTYPE_DUALPLAYER_PARTNER_TIGUAN then
    button.NormalImage = "jiaohu"
    button.FocusImage = "jiaohu"
    button.PushImage = "jiaohu"
  end
  if request_type == REQUESTTYPE_DUALPLAYER_TIGUAN then
    button.NormalImage = "gujlong"
    button.FocusImage = "gujlong"
    button.PushImage = "gujlong"
    left_time = -1
  end
  if request_type == REQUESTTYPE_FRESHMAN_SWORN then
    left_time = -1
  end
  if request_type == REQUESTTYPE_SHENG_SI_FU then
    left_time = 30
  end
  if request_type == REQUESTTYPE_JIUYANG_CALLDEFENDER then
    left_time = 60
  end
  if request_type == REQUESTTYPE_ORIGIN_NOTIFY then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_ORIGIN_NOTIFY then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_LEAGUE_MATCHES then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_LEAGUE_MATCHES then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_CROSS_STATION_WAR_GO then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_CROSS_STATION_WAR_GO then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_TEAM_CONFIRM then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_TEAM_CONFIRM then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_SWORN_SUMMON then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_SWORN_SUMMON then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_NEW_BAI_SHI then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_NEW_BAI_SHI then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_NEW_SHOU_TU then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_NEW_SHOU_TU then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_INVITE_LEAGUE then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_INVITE_LEAGUE then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_TAOSHA_GO then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_TAOSHA_GO then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  if request_type == REQUESTTYPE_HORSE_RACE_GO then
    for i = 1, table.maxn(REQUEST_ARRAY) do
      if REQUEST_ARRAY[i][INDEX_REQUEST_TYPE] == REQUESTTYPE_HORSE_RACE_GO then
        local old_btn = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
        if nx_is_valid(old_btn) and nx_is_valid(old_btn.label) then
          form_main:Remove(old_btn.label)
          form_main:Remove(old_btn)
          gui:Delete(old_btn.label)
          gui:Delete(old_btn)
        end
        table.remove(REQUEST_ARRAY, i)
        break
      end
    end
  end
  button.Visible = false
  button.AutoSize = false
  button.DrawMode = "FitWindow"
  button.Height = BUI_HEIGHT
  button.Width = BUT_WIDTH
  button.Cursor = "Hand"
  button.HAnchor = "Center"
  button.VAnchor = "Bottom"
  button.first_move = true
  button.label = gui:Create("Label")
  button.label.Visible = false
  button.label.Height = LBL_HEIGHT
  button.label.Width = LBL_WIDTH
  button.label.Align = "Center"
  button.label.HAnchor = "Center"
  button.label.VAnchor = "Bottom"
  button.label.ForeColor = "255,255,255,255"
  button.label.Font = "font_main"
  button.label.left_time = left_time or 60
  button.label.Text = nx_widestr(button.label.left_time)
  if left_time == -1 then
    button.label.left_time = nil
    button.label.Visible = false
    button.label.Text = nx_widestr("")
  end
  form_main:Add(button)
  form_main:Add(button.label)
  local size = table.maxn(REQUEST_ARRAY) + 1
  REQUEST_ARRAY[size] = {}
  REQUEST_ARRAY[size][INDEX_REQUEST_TYPE] = request_type
  REQUEST_ARRAY[size][INDEX_REQUEST_PLAYER] = request_player
  REQUEST_ARRAY[size][INDEX_REQUEST_PARAMS] = {}
  REQUEST_ARRAY[size][INDEX_REQUEST_BUTTON] = button
  nx_bind_script(button, nx_current(), "button_init")
  show_request()
  nx_execute(nx_current(), "begin_count")
  return size
end
function button_init(btn)
  nx_callback(btn, "on_click", "on_click_request")
end
function add_request_para(index, para)
  if REQUEST_ARRAY == nil or index == nil or para == nil then
    return
  end
  if REQUEST_ARRAY[index] == nil then
    REQUEST_ARRAY[index] = {}
  end
  if REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS] == nil then
    REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS] = {}
  end
  local para_index = table.getn(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS])
  REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][para_index + 1] = para
end
function get_request_button(index)
  return REQUEST_ARRAY[index][INDEX_REQUEST_BUTTON]
end
function show_request()
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  local size = table.maxn(REQUEST_ARRAY)
  local move_count = size
  if size < form_main.g_sametime_show_count then
    move_count = size
  else
    move_count = form_main.g_sametime_show_count
  end
  for i = 1, move_count do
    local button = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
    if nx_is_valid(button) then
      if button.first_move then
        button.AbsLeft = form_main.g_start_left
        button.AbsTop = form_main.g_top
        button.first_move = false
      end
      button.index = i
      button.Visible = true
      local timer = nx_value(GAME_TIMER)
      timer:Register(10, 1, nx_current(), "begin_move_action", button, i, -1)
    end
  end
end
function begin_count()
  if nx_running(nx_current(), "begin_count") then
    return
  end
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  while true do
    local sep = nx_pause(1)
    local size = table.maxn(REQUEST_ARRAY)
    if size == 0 then
      break
    end
    form_main = nx_value(GAME_GUI_MAIN)
    if not nx_is_valid(form_main) then
      break
    end
    if size > form_main.g_sametime_show_count then
      size = form_main.g_sametime_show_count
    end
    for index = size, 1, -1 do
      if index > table.maxn(REQUEST_ARRAY) or index < 1 then
        break
      end
      local button = REQUEST_ARRAY[index][INDEX_REQUEST_BUTTON]
      if not nx_is_valid(button) then
        break
      end
      if button.label.left_time ~= nil then
        if REQUESTTYPE_SCHOOL_POSE_FIGHT == REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] then
          sep = 1
        end
        button.label.left_time = nx_int(button.label.left_time) - nx_int(sep)
        if 0 > button.label.left_time then
          local player = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
          if REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_PLAYER_LEITAI_PK_NOTICE then
            nx_execute("form_stage_main\\form_leitai\\form_leitai_invite_request.lua", "refuse_join_leitai", REQUEST_ARRAY[size][INDEX_REQUEST_PARAMS][8])
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_GUILD_WATER_TASK then
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_SCHOOL_POSE_FIGHT then
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_USE_ITEM_ACCOST then
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_NEW_TERRITORY_PVP then
            nx_execute("form_stage_main\\form_new_territory\\form_new_territory", "on_pvp_cancel")
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_EGWAR then
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_RED_PACKET then
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_AGREE_WAR_IN then
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_AGREE_WAR_REQ then
          elseif REQUEST_ARRAY[index][INDEX_REQUEST_TYPE] == REQUESTTYPE_AGREE_WAR_MEMBER_IN then
          else
            nx_execute("custom_sender", "custom_request_answer", REQUEST_ARRAY[index][INDEX_REQUEST_TYPE], player, 0)
          end
          form_main:Remove(button.label)
          form_main:Remove(button)
          local gui = nx_value("gui")
          gui:Delete(button.label)
          gui:Delete(button)
          table.remove(REQUEST_ARRAY, index)
          show_request()
        else
          button.label.Text = nx_widestr(button.label.left_time)
        end
      end
    end
  end
end
function get_begin_left()
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return 0
  end
  local left = form_main.Width - form_main.g_to_desktop_right + form_main.g_image_width + form_main.g_image_inter
  return left
end
function get_btn_width()
  return BUT_WIDTH
end
function get_btn_height()
  return BUI_HEIGHT
end
function get_begin_top()
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return 0
  end
  return form_main.g_top
end
function begin_move_action(button, index)
  local form_main = button.ParentForm
  local dest_left = form_main.Width - form_main.g_to_desktop_right - (index - 1) * (form_main.g_image_width + form_main.g_image_inter)
  if nx_is_valid(button) then
    button.AbsLeft = dest_left
    button.label.AbsLeft = button.AbsLeft
    button.label.AbsTop = button.AbsTop + button.Height + 1
    button.label.Visible = true
  end
end
function get_info_idname(request_type)
  return "ui_main_requestinfo_" .. nx_string(nx_int(request_type))
end
function find_special_request(type)
  local size = table.maxn(REQUEST_ARRAY)
  for i = 1, size do
    local request_type = REQUEST_ARRAY[i][INDEX_REQUEST_TYPE]
    if type == request_type then
      return i
    end
  end
end
function clear_special_request(type)
  local gui = nx_value("gui")
  local i = find_special_request(type)
  while i do
    local request_type = REQUEST_ARRAY[i][INDEX_REQUEST_TYPE]
    if type == request_type then
      local button = REQUEST_ARRAY[i][INDEX_REQUEST_BUTTON]
      local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main", true, false)
      if not nx_is_valid(form) then
        return
      end
      if nx_is_valid(button) and nx_find_custom(button, "label") and nx_is_valid(button.label) then
        form:Remove(button.label)
        gui:Delete(button.label)
      end
      if nx_is_valid(button) then
        form:Remove(button)
        gui:Delete(button)
      end
      table.remove(REQUEST_ARRAY, i)
      show_request()
    end
    i = find_special_request(type)
  end
end
function on_click_request(button)
  local form = button.ParentForm
  local index = button.index
  local size = table.maxn(REQUEST_ARRAY)
  if index > size or index < 1 then
    return
  end
  local gui = nx_value("gui")
  local request_type = REQUEST_ARRAY[index][INDEX_REQUEST_TYPE]
  local dialog
  if request_type >= REQUESTTYPE_ENTRY_AWARD_1 and request_type <= REQUESTTYPE_ENTRY_AWARD_5 then
    local text = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    util_msgbox(text)
    return
  end
  if request_type == REQUESTTYPE_RED_PACKET then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RED_PACKET), nx_int(1))
    return
  end
  if request_type == REQUESTTYPE_SANMENG_MATCH then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_match\\form_sanmeng_goto_join", true)
    if nx_is_valid(form) then
      form:Show()
    end
    return
  end
  if request_type == REQUESTTYPE_KILLER_FIND_ME_ADV then
    local text = "qy_event_khd_aqzw_01"
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return false
    end
    dialog.Name = "form_confirm"
    local label = dialog.mltbox_info
    label.HtmlText = nx_widestr(gui.TextManager:GetText(text))
    dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_yes"))
    dialog.cancel_btn.Text = nx_widestr(gui.TextManager:GetText("ui_no"))
    dialog:ShowModal()
    local Ret = nx_wait_event(100000000, dialog, "confirm_return")
    if Ret == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SPECIAL_ADV), nx_int(0))
    end
    return
  end
  if request_type == REQUESTTYPE_TREASURE_MORE_REFRESH then
    local text = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return false
    end
    dialog.Name = "form_confirm"
    local label = dialog.mltbox_info
    label.HtmlText = nx_widestr(gui.TextManager:GetText(text))
    dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_yes"))
    dialog.cancel_btn.Text = nx_widestr(gui.TextManager:GetText("ui_no"))
    dialog:ShowModal()
    local Ret = nx_wait_event(100000000, dialog, "confirm_return")
    if Ret == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(25))
    end
    return
  end
  if request_type == REQUESTTYPE_CAPTURE_CITY_PRE then
    local text = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return false
    end
    dialog.Name = "form_confirm"
    local label = dialog.mltbox_info
    label.HtmlText = nx_widestr(gui.TextManager:GetText(text))
    dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_yes"))
    dialog.cancel_btn.Text = nx_widestr(gui.TextManager:GetText("ui_no"))
    dialog:ShowModal()
    local Ret = nx_wait_event(100000000, dialog, "confirm_return")
    if Ret == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CAPTURE_CITY_PRE), nx_int(1))
    end
    return
  end
  if request_type == REQUESTTYPE_ORIGIN_NOTIFY then
    local origin_id = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    local origin_manager = nx_value("OriginManager")
    if not nx_is_valid(origin_manager) then
      return
    end
    local outland_res = nx_execute("form_stage_main\\form_outland\\form_outland_origin", "is_outland_origin", nx_string(origin_id))
    local is_shijia_origin = nx_execute("form_stage_main\\form_shijia\\form_shijia_origin", "is_shijia_origin", nx_int(origin_id))
    if origin_manager:IsDongHaiOrigin(nx_int(origin_id)) then
      nx_execute("form_stage_main\\form_origin_new\\form_new_origin_main", "open_origin_desc_form_by_id", nx_int(origin_id))
    elseif outland_res then
      nx_execute("form_stage_main\\form_outland\\form_outland_main", "open_outland_origin_subform")
    elseif is_shijia_origin then
      nx_execute("form_stage_main\\form_shijia\\form_shijia_origin", "show_shijia_origin", nx_int(origin_id))
    elseif nx_int(origin_id) > nx_int(0) then
      nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "custom_open_limite_form_origin", nx_int(3), nx_int(origin_id))
    else
      nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "custom_open_limite_form", nx_int(3))
    end
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_TVT_INFO then
    util_auto_show_hide_form("form_stage_main\\form_tvt\\form_tvt_main")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    return
  end
  if request_type == REQUESTTYPE_ASK_LEAGUE_JOIN_GUILDWAR then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    local domain_id_str = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    local defend_guild = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2]
    local attack_guild = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][3]
    local show_text_id = "league_join_confirm_text"
    gui.TextManager:Format_SetIDName(show_text_id)
    gui.TextManager:Format_AddParam(domain_id_str)
    gui.TextManager:Format_AddParam(defend_guild)
    gui.TextManager:Format_AddParam(attack_guild)
    local show_Info = gui.TextManager:Format_GetText()
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, show_Info)
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    local start_pos, end_pos = string.find(domain_id_str, "ui_dipan_")
    local domain_id = string.sub(domain_id_str, end_pos + 1)
    if res == "ok" then
      game_visual:CustomSend(nx_int(8), nx_int(4), nx_int(domain_id))
    end
    return
  end
  if request_type == REQUESTTYPE_PLAYER_LEITAI_PK_NOTICE then
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_invite_request", true, false)
    dialog:ShowModal()
    dialog.leitai_type = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2]
    dialog.pos_x = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][3]
    dialog.pos_y = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][4]
    dialog.pos_z = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][5]
    dialog.pos_o = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][6]
    dialog.sence = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][7]
    dialog.register_npc = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][8]
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_ITEM_COURSE then
    if is_newjhmodule() then
      util_show_form("form_stage_main\\form_task\\form_jianghu_explore", false)
      util_show_form("form_stage_main\\form_task\\form_jianghu_explore", true)
    end
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_FRESHMAN_JIAYUAN then
    nx_execute("form_stage_main\\form_freshman\\form_freshman_jiayuan", "open_form")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_DUALPLAYER_TIGUAN then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_dual_play", "open_form")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_FRESHMAN_SWORN then
    nx_execute("form_stage_main\\form_freshman\\form_freshman_sworn", "open_form")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_ANCIENTTOMB_SRTX then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(util_format_string("gmp_srtx_sys_010"))
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, text)
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ANCIENT_TOMB), nx_int(0))
    end
    return
  end
  if request_type == REQUESTTYPE_ANCIENTTOMB_LOT then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = util_format_string("ui_lot_001", REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ANCIENT_TOMB), nx_int(22))
    end
    return
  end
  if request_type == REQUESTTYPE_ANCIENTTOMB_REMOVE_LOT then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(util_text("ui_lot_002")))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ANCIENT_TOMB), nx_int(23))
    end
    return
  end
  if request_type == REQUESTTYPE_BODYGUARD_SMDH_TEAM then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = util_format_string("ui_bodyguard_create_team", REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BODYGUARDOFFICE), nx_int(18))
    end
    return
  end
  if request_type == REQUESTTYPE_CROSS_STATION_WAR_GO then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "open_cross_station_war")
    return
  end
  if request_type == REQUESTTYPE_SWORN_SUMMON then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = util_format_string("ui_sworn_summon", REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    local player_name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SWORN), nx_int(9), nx_widestr(player_name))
    end
    return
  end
  if request_type == REQUESTTYPE_TEAM_CONFIRM then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = util_format_string("ui_team_confirm", REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    local player_name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_CONFIRM), nx_int(0), nx_widestr(player_name), nx_int(1))
    else
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_CONFIRM), nx_int(0), nx_widestr(player_name), nx_int(0))
    end
    return
  end
  if request_type == REQUESTTYPE_FLEE_BACHELOR then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local player_name = nx_widestr(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    local isLucky = nx_int(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2])
    local text = util_format_string("ui_flee_confirm_" .. nx_string(isLucky), player_name)
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FLEE_BACHELOR), nx_int(1))
    else
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FLEE_BACHELOR), nx_int(0))
    end
    return
  end
  if request_type == REQUESTTYPE_OUTLAND_WAR_VOTE then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local player_name = nx_widestr(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    local vote_type = nx_int(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    local text = util_format_string("ui_outland_war_vote_" .. nx_string(vote_type), player_name)
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      custom_outland_war(8, player_name, 1)
    else
      custom_outland_war(8, player_name, 2)
    end
    return
  end
  if request_type == REQUESTTYPE_AGREE_WAR_IN then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local player_name = nx_widestr(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    local text = util_format_string("ui_req_agree_war_in", player_name)
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      custom_agree_war(17, player_name, 1)
    else
      custom_agree_war(17, player_name, 0)
    end
    return
  end
  if request_type == REQUESTTYPE_WUDAO_ROOM_INVITE then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    local wuado_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local gm_name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    local room_id = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2]
    local enemy_team_name = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][3]
    local text = util_format_string("ui_wudao_group_apply_yes_or_no", enemy_team_name)
    nx_execute("form_common\\form_confirm", "show_common_text", wuado_dialog, nx_widestr(text))
    wuado_dialog:ShowModal()
    wuado_dialog.Left = (gui.Width - wuado_dialog.Width) / 2
    wuado_dialog.Top = (gui.Height - wuado_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, wuado_dialog, "confirm_return")
    if res == "ok" then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(request_type), gm_name, nx_int(1), nx_int(room_id))
    else
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(request_type), gm_name, nx_int(0), nx_int(room_id))
    end
    return
  end
  if request_type == REQUESTTYPE_LUAN_DOU_GO then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local captain_name = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2]
    local text = util_format_string("sys_jianghudaluandou_tips_025", captain_name)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(request_type), nx_widestr("System"), nx_int(1))
    else
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(request_type), nx_widestr("System"), nx_int(0))
    end
    return
  end
  if request_type == REQUESTTYPE_LUAN_DOU_WEEK_PUSH then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "open_form")
    return
  end
  if request_type == REQUESTTYPE_AGREE_WAR_REQ then
    nx_execute("form_stage_main\\form_agree_war\\form_agree_war_main", "open_form_2")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_AGREE_WAR_MEMBER_IN then
    local player_name = nx_widestr(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    local war_id = nx_string(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    local camp_id = nx_int(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2])
    local text = util_format_string("ui_agree_war_member_in", player_name)
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_agree_war(nx_int(2), nx_string(war_id), nx_int(camp_id))
    end
    return
  end
  if request_type == REQUESTTYPE_NEW_BAI_SHI then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local player_name = nx_widestr(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    local had_reward = nx_int(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    local chushi_reward = nx_int(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2])
    local text = util_format_string("ui_new_teacher_ans_baishi", player_name, nx_int(had_reward))
    if nx_int(chushi_reward) == nx_int(0) then
      text = text .. nx_widestr(util_format_string("ui_new_teacher_chushi_no"))
    else
      text = text .. nx_widestr(util_format_string("ui_new_teacher_chushi_yes"))
    end
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(2), nx_int(1))
    else
    end
    return
  elseif request_type == REQUESTTYPE_NEW_SHOU_TU then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local player_name = nx_widestr(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    local chushi_num = nx_int(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    local text = util_format_string("ui_new_teacher_ans_shoutu", player_name, chushi_num)
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(3), nx_int(1))
    else
    end
    return
  end
  if request_type == REQUESTTYPE_INVITE_LEAGUE then
    local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local source_guild = nx_widestr(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    local player_name = nx_widestr(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    local text = util_format_string("19960", source_guild)
    nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, nx_widestr(text))
    guild_dialog:ShowModal()
    guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
    guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(106), nx_widestr(source_guild))
    else
    end
    return
  end
  if request_type == REQUESTTYPE_GUILD_LUCK_TASK then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "switch_to_sub_form", "rbtn_activity", "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_activity", "rbtn_task")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_HIDE_PLAYER then
    nx_execute("form_stage_main\\form_help\\form_help_hide_player", "open_form")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_GUILD_MEMBER_PLUS then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_prosperity", "open_form")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  end
  if request_type == REQUESTTYPE_HELPER then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "on_btn_next_click", button)
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_SOLE_PROMPT then
    local info_id = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    local PromptIndex = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2]
    nx_execute("form_stage_main\\form_sys_sole_prompt", "show_sole_prompt", info_id, PromptIndex)
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_BEG then
    local name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    local argarr = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]
    local sack_name, sack_icon = get_beg_budai_info(nx_int(argarr[1]))
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_peddle_info", true, false)
    dialog.mltbox_yinzi.HtmlText = get_yin_info(nx_int(argarr[2]))
    dialog.qigai_name.Text = nx_widestr(nx_string(name))
    dialog.sack_name.Text = nx_widestr(util_text(sack_name))
    dialog.price = nx_int(argarr[2])
    dialog.mltbox_des.HtmlText = gui.TextManager:GetText("ui_baodai_" .. nx_string(nx_int(argarr[1])))
    dialog.imagegrid:AddItem(0, nx_string(sack_icon), nx_widestr(nx_int(argarr[1])), 1, -1)
  elseif request_type == REQUESTTYPE_CHALLENGE and 0 < table.getn(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]) then
    local name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    local argarr = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]
    local wcsInfo = gui.TextManager:GetFormatText("ui_chanllege_with_money", nx_string(name), nx_number(argarr[1]))
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_be_qiecuo", true, false)
    dialog.mltbox_info:Clear()
    dialog.mltbox_info.HtmlText = nx_widestr(wcsInfo)
  elseif request_type == REQUESTTYPE_FORTUNETELLINGOTHER then
    local name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    local argarr = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_fortunetellingother", true, false)
  elseif request_type == REQUESTTYPE_SYSTEM_FRIENDS then
    nx_execute("form_stage_main\\form_relation\\form_system_friends", "set_gui_bevisible")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_WORLD_LEITAI then
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_world_leitai_invite", true, false)
    local name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    local argarr = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]
    local wcsInfo = gui.TextManager:GetFormatText("ui_main_requestinfo_34", nx_widestr(argarr[1]), nx_widestr(name))
    dialog.mltbox_info:Clear()
    dialog.mltbox_info.HtmlText = nx_widestr(wcsinfo)
    dialog.time = math.floor(button.label.left_time) - 2
  elseif request_type == REQUESTTYPE_LEITAI_REVENGE then
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_world_leitai_invite", true, false)
    local name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    local argarr = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]
    if #argarr == 1 then
      local wcsInfo = gui.TextManager:GetFormatText("ui_main_requestinfo_40", nx_widestr(name))
      dialog.mltbox_info:Clear()
      if argarr[1] > 0 then
        wcsInfo = nx_widestr(wcsInfo) .. nx_widestr(gui.TextManager:GetText("ui_jieshouyaoqing_wanjia1"))
      else
        wcsInfo = nx_widestr(wcsInfo) .. nx_widestr(gui.TextManager:GetText("ui_jieshouyaoqing_wanjia2"))
      end
      dialog.mltbox_info.HtmlText = nx_widestr(wcsInfo)
    end
    dialog.InviteType = REQUESTTYPE_LEITAI_REVENGE
    dialog.time = math.floor(button.label.left_time) - 2
  elseif request_type == REQUESTTYPE_GUILD_WATER_TASK then
    nx_execute("form_stage_main\\form_guild_fire\\form_fire_info", "show_water_task_confirm")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_SCHOOL_VOTE then
    nx_execute("custom_sender", "custom_get_school_vote_info")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_HUASHAN_JOIN_MATCH_GAME then
    nx_execute("form_stage_main\\form_huashan\\form_huashan_main", "open_join_match_game")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_HUASHAN_SHOW_FORM then
    local sub_type = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    if sub_type == 1 then
      nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "show_origin")
    elseif sub_type == 2 then
      nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "show_ytj")
    end
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_SCHOOL_POSE_FIGHT then
    local submsg_type = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    nx_execute("form_stage_main\\form_school_war\\form_school_pose_fight", "on_school_pose_fight_msg", submsg_type)
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_EGWAR then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return false
    end
    dialog.Name = "form_confirm"
    local label = dialog.mltbox_info
    label.HtmlText = nx_widestr(gui.TextManager:GetText("ui_egwar_trans"))
    dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_yes"))
    dialog.cancel_btn.Text = nx_widestr(gui.TextManager:GetText("ui_no"))
    dialog:ShowModal()
    local Ret = nx_wait_event(100000000, dialog, "confirm_return")
    if Ret == "ok" then
      local egwar = nx_value("EgWarModule")
      if nx_is_valid(egwar) then
        nx_execute("custom_sender", "custom_egwar_trans", 1, egwar.CrossServerID, egwar.WarName, egwar.RuleIndex, egwar.WarSceneID, egwar.SubRound, egwar.StartTime)
      end
    end
    return
  elseif request_type == REQUESTTYPE_TAOHUA_LEAD then
    local lead_id = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    nx_execute("form_stage_main\\form_help\\form_help_thd_lead", "open_form", lead_id)
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_ANSWER_QUESTION then
    nx_execute("form_stage_main\\form_activity\\form_activity_answer_join", "open_form")
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    return
  elseif request_type == REQUESTTYPE_USE_ITEM_ACCOST then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    local request_player = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return false
    end
    dialog.Name = "form_confirm"
    gui.TextManager:Format_SetIDName("ui_accost_useitem01")
    gui.TextManager:Format_AddParam(nx_widestr(request_player))
    local text = gui.TextManager:Format_GetText()
    local label = dialog.mltbox_info
    label.HtmlText = nx_widestr(text)
    dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_yes"))
    dialog.cancel_btn.Text = nx_widestr(gui.TextManager:GetText("ui_no"))
    dialog:ShowModal()
    local Ret = nx_wait_event(100000000, dialog, "confirm_return")
    if Ret == "ok" then
      nx_execute("custom_sender", "custom_offline_accost", nx_int(5), nx_widestr(request_player), 1)
    else
      nx_execute("custom_sender", "custom_offline_accost", nx_int(5), nx_widestr(request_player), 2)
    end
    return
  elseif request_type == REQUESTTYPE_NEW_TERRITORY_PVP then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    nx_execute("form_stage_main\\form_new_territory\\form_new_territory", "on_pvp_begin")
    return
  elseif request_type == REQUESTTYPE_TRANSTO_CANWU_SCENE then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local CLIENT_CUSTOMMSG_HUASHAN = 965
    local HuaShanCToS_TransToScene = 16
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUASHAN), nx_int(HuaShanCToS_TransToScene))
    return
  elseif request_type == REQUESTTYPE_ROYAL_TREASURE then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    nx_execute("form_stage_main\\form_helper\\form_royal_treasure_helper", "open_form", "royal_treasure")
    return
  elseif request_type == REQUESTTYPE_DAY_PACKET then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    custom_pick_daypacket(1)
    return
  elseif request_type == REQUESTTYPE_LEAVE_SCHOOL then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    nx_execute("form_stage_main\\form_school_travel", "open_form")
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", "leave_school_guild")
    return
  elseif request_type == REQUESTTYPE_LEAGUE_MATCHES then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    nx_execute("form_stage_main\\form_league_matches\\form_lm_invite", "open_form")
    return
  elseif request_type == REQUESTTYPE_CHAMPION then
    local open_type = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    nx_execute("form_stage_main\\form_guild_battle\\form_cw_show", "open_form", open_type)
    return
  elseif request_type == REQUESTTYPE_JZ then
    form:Remove(button.label)
    form:Remove(button)
    gui:Delete(button.label)
    gui:Delete(button)
    table.remove(REQUEST_ARRAY, index)
    show_request()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return false
    end
    dialog.Name = "form_confirm"
    local label = dialog.mltbox_info
    label.HtmlText = nx_widestr(gui.TextManager:GetText("sys_huodong_dy_jhjfm10"))
    dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_yes"))
    dialog.cancel_btn.Text = nx_widestr(gui.TextManager:GetText("ui_no"))
    dialog:ShowModal()
    local Ret = nx_wait_event(100000000, dialog, "confirm_return")
    if Ret == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JZ), nx_int(0))
    end
    return
  else
    dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  end
  local idname = get_info_idname(REQUEST_ARRAY[index][INDEX_REQUEST_TYPE])
  local argarr = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]
  gui.TextManager:Format_SetIDName(idname)
  gui.TextManager:Format_AddParam(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
  if request_type == REQUESTTYPE_ACTION then
    local action_name = "ui_action_notice_" .. nx_string(argarr[1])
    gui.TextManager:Format_AddParam(action_name)
  end
  if request_type == REQUESTTYPE_BEG then
    local sack_name, sack_icon = get_beg_budai_info(nx_int(argarr[1]))
    gui.TextManager:Format_AddParam(nx_widestr(util_text(sack_name)))
    gui.TextManager:Format_AddParam(nx_int(argarr[2]))
  elseif request_type == REQUESTTYPE_BAI_SHI then
    gui.TextManager:Format_SetIDName("ui_shitu_baishi_request_" .. nx_string(nx_int(argarr[1])))
    gui.TextManager:Format_AddParam(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    for i, para in pairs(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]) do
      if i ~= 1 then
        local type = nx_type(para)
        if type == "number" then
          gui.TextManager:Format_AddParam(nx_int(para))
        elseif type == "string" then
          gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
        else
          gui.TextManager:Format_AddParam(para)
        end
      end
    end
  elseif request_type == REQUESTTYPE_SHOU_TU then
    gui.TextManager:Format_SetIDName("ui_shitu_shoutu_request_" .. nx_string(nx_int(argarr[1])))
    gui.TextManager:Format_AddParam(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    for i, para in pairs(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]) do
      if i ~= 1 then
        local type = nx_type(para)
        if type == "number" then
          gui.TextManager:Format_AddParam(nx_int(para))
        elseif type == "string" then
          gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
        else
          gui.TextManager:Format_AddParam(para)
        end
      end
    end
  elseif request_type == REQUESTTYPE_FORTUNETELLINGOTHER then
    if nx_int(argarr[3]) == nx_int(0) then
      gui.TextManager:Format_SetIDName(idname)
      gui.TextManager:Format_AddParam(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    elseif nx_int(argarr[3]) == nx_int(1) then
      gui.TextManager:Format_SetIDName("ui_sh_gsgq14")
      gui.TextManager:Format_AddParam(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    end
    for i, para in pairs(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]) do
      local type = nx_type(para)
      if type == "number" then
        gui.TextManager:Format_AddParam(nx_int(para))
      elseif type == "string" then
        gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
      else
        gui.TextManager:Format_AddParam(para)
      end
    end
  elseif request_type == REQUESTTYPE_TEACHER_INVITE then
    local player_name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    gui.TextManager:Format_SetIDName("info_stzc_request_summon")
    gui.TextManager:Format_AddParam(player_name)
  elseif request_type == REQUESTTYPE_HOME_GAME_INVITE then
    local player_name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    local home_uid = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1]
    local game_name = REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2]
    gui.TextManager:Format_SetIDName("ui_jy_fszh_01")
    gui.TextManager:Format_AddParam(player_name)
    gui.TextManager:Format_AddParam(game_name)
  elseif request_type == REQUESTTYPE_BALANCE_WAR_MATCHING_CONFIRM then
    gui.TextManager:Format_SetIDName("balance_war_systeminfo_10027")
  elseif request_type == REQUESTTYPE_WUDAO_WAR_GO then
    gui.TextManager:Format_SetIDName("systeminfo_wudaodahui_preview_53")
  elseif request_type == REQUESTTYPE_JIUYANG_CALLHELPER then
    gui.TextManager:Format_SetIDName(idname)
    gui.TextManager:Format_AddParam(argarr[1])
  elseif request_type == REQUESTTYPE_TAOSHA_GO then
    gui.TextManager:Format_SetIDName("ui_taosha_acced")
  elseif request_type == REQUESTTYPE_JIUYANG_CALLDEFENDER then
    local player_name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    if nx_widestr(player_name) == nx_widestr("") then
      gui.TextManager:Format_SetIDName("sys_jiuyang_005")
    else
      gui.TextManager:Format_SetIDName("sys_jiuyang_004")
      gui.TextManager:Format_AddParam(player_name)
    end
  elseif request_type == REQUESTTYPE_DUALPLAYER_PARTNER then
    local player_name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    gui.TextManager:Format_SetIDName("ui_tiguan_dual_play_22")
    gui.TextManager:Format_AddParam(player_name)
  elseif request_type == REQUESTTYPE_DUALPLAYER_PARTNER_TIGUAN then
    local player_name = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    gui.TextManager:Format_SetIDName("ui_tiguan_dual_play_23")
    gui.TextManager:Format_AddParam(player_name)
  elseif request_type == REQUESTTYPE_HORSE_RACE_GO then
    gui.TextManager:Format_SetIDName("ui_horse_race_go")
  else
    for i, para in pairs(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]) do
      local type = nx_type(para)
      if type == "number" then
        gui.TextManager:Format_AddParam(nx_int(para))
      elseif type == "string" then
        gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
      else
        gui.TextManager:Format_AddParam(para)
      end
    end
  end
  local wcsInfo = gui.TextManager:Format_GetText()
  if request_type ~= REQUESTTYPE_CHALLENGE and request_type ~= REQUESTTYPE_LEITAI_REVENGE or table.getn(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]) <= 0 then
    dialog.mltbox_info:Clear()
    dialog.mltbox_info.HtmlText = nx_widestr(wcsInfo)
  end
  if request_type == REQUESTTYPE_MASS_SCHOOL_WAR then
    local targetname = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    local text = gui.TextManager:GetFormatText("ui_schoolwar_question", targetname)
    dialog.mltbox_info.HtmlText = nx_widestr(text)
  end
  local res
  if request_type ~= REQUESTTYPE_LIFE_JOB_SHARE then
    dialog:ShowModal()
    res = nx_wait_event(100000000, dialog, "confirm_return")
    if not nx_is_valid(button) then
      return
    end
    index = button.index
  else
    res = "ok"
  end
  if request_type == REQUESTTYPE_FORTUNETELLINGOTHER then
    if nx_int(argarr[3]) == nx_int(0) then
      gui.TextManager:Format_SetIDName("ui_sh_gsgq19")
      gui.TextManager:Format_AddParam(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    elseif nx_int(argarr[3]) == nx_int(1) then
      gui.TextManager:Format_SetIDName("ui_sh_gsgq18")
      gui.TextManager:Format_AddParam(REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER])
    end
    for i, para in pairs(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS]) do
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
    if not ShowTipDialog(nx_widestr(info)) then
      res = "cancel"
    end
  end
  local player = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
  if res == "cancel" then
    nx_execute("custom_sender", "custom_request_answer", REQUEST_ARRAY[index][INDEX_REQUEST_TYPE], player, 0)
  else
    if request_type == REQUESTTYPE_ACTION then
      local game_visual = nx_value("game_visual")
      local player = game_visual:GetPlayer()
      local state_index = game_visual:QueryRoleStateIndex(player)
      if state_index ~= STATE_STATIC_INDEX then
        nx_execute("custom_sender", "custom_request_answer", REQUEST_ARRAY[index][INDEX_REQUEST_TYPE], player, 0)
      end
    end
    local para_count = 0
    if REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS] ~= nil then
      para_count = table.getn(REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS])
    end
    if request_type == REQUESTTYPE_BEG then
      local value = 0
      if dialog.cbtn_dashang.Checked then
        value = dialog.count
      end
      REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][para_count + 1] = value
      para_count = para_count + 1
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    local requesttype = REQUEST_ARRAY[index][INDEX_REQUEST_TYPE]
    local targetname = REQUEST_ARRAY[index][INDEX_REQUEST_PLAYER]
    if para_count == 0 then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(requesttype), targetname, nx_int(1))
    elseif para_count == 1 then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(requesttype), targetname, nx_int(1), REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1])
    elseif para_count == 2 then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(requesttype), targetname, nx_int(1), REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2])
    elseif para_count == 3 then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(requesttype), targetname, nx_int(1), REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][3])
    elseif para_count == 4 then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(requesttype), targetname, nx_int(1), REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][3], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][4])
    elseif para_count == 5 then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(requesttype), targetname, nx_int(1), REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][1], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][2], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][3], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][4], REQUEST_ARRAY[index][INDEX_REQUEST_PARAMS][5])
    end
  end
  form:Remove(button.label)
  form:Remove(button)
  gui:Delete(button.label)
  gui:Delete(button)
  table.remove(REQUEST_ARRAY, index)
  show_request()
end
function get_yin_info(n)
  local gui = nx_value("gui")
  local capital_manager = nx_value("CapitalModule")
  local res = {}
  local htmlTextYinZi = nx_widestr("<center>")
  if nx_is_valid(capital_manager) then
    res = capital_manager:SplitCapital(nx_int(n), CAPITAL_TYPE_SILVER)
    local ding = res[1]
    local liang = res[2]
    local wen = res[3]
    local capital = nx_int(n)
    local gui = nx_value("gui")
    local textyZi = nx_widestr("")
    if 0 < ding then
      local text = gui.TextManager:GetText("ui_ding")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
    end
    if 0 < liang then
      local text = gui.TextManager:GetText("ui_liang")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
    end
    if 0 < wen then
      local text = gui.TextManager:GetText("ui_wen")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
    end
    if capital == 0 then
      local text = gui.TextManager:GetText("ui_wen")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(htmlText)
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("</center>")
  end
  return htmlTextYinZi
end
function get_beg_budai_info(player_rank)
  local ini = nx_execute("util_functions", "get_ini", BEG_INI_FILE)
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_count = ini:GetSectionCount()
  if sec_count < 0 then
    return
  end
  local budai_name, budai_icon
  for i = 0, sec_count do
    local rank = ini:ReadInteger(i, "Rank", 0)
    if nx_int(player_rank) == nx_int(rank) then
      budai_name = ini:ReadString(i, "Name", "")
      budai_icon = ini:ReadString(i, "Photo", "")
      return budai_name, budai_icon
    end
  end
  return "", ""
end
function is_need_filter(request_type)
  local filter_table = {
    REQUESTTYPE_TEAMREQUEST,
    REQUESTTYPE_EXCHANGE,
    REQUESTTYPE_GUILD,
    REQUESTTYPE_FRIEND,
    REQUESTTYPE_BUDDY,
    REQUESTTYPE_ACTION,
    REQUESTTYPE_FREE_TEACHRELATION,
    REQUESTTYPE_CHALLENGE,
    REQUESTTYPE_INVITETEAM,
    REQUESTTYPE_FORTUNETELLING,
    REQUESTTYPE_FORTUNETELLINGOTHER,
    REQUESTTYPE_BEG,
    REQUESTTYPE_JOIN_FACULTY,
    REQUESTTYPE_INVITE_FACULTY,
    REQUESTTYPE_PLAY_GEMGAME,
    REQUESTTYPE_MULTI_RIDE,
    REQUESTTYPE_BAI_SHI,
    REQUESTTYPE_WQGAME
  }
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return false
  end
  local key = util_get_property_key(game_config_info, "filter_playerask", 0)
  if nx_string(key) == nx_string("1") then
    for i = 1, table.getn(filter_table) do
      if nx_int(request_type) == nx_int(filter_table[i]) then
        return true
      end
    end
  end
  return false
end
function player_in_pingheng_war()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  local BalanceFlag = player:QueryProp("BalanceWarIsInWar")
  if nx_int(BalanceFlag) > nx_int(0) then
    return true
  end
  local WudaoFlag = nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "is_in_wudao_scene")
  if WudaoFlag then
    return true
  end
  local LuandouFlag = nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "is_in_luandou_scene")
  if LuandouFlag then
    return true
  end
  local TaoShaFlag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  if TaoShaFlag then
    return true
  end
  local ApexFlag = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if ApexFlag then
    return true
  end
  local YanWuFlag = nx_execute("form_stage_main\\form_die_util", "IsInWuDaoYanWuScene")
  if YanWuFlag then
    return true
  end
  return false
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
