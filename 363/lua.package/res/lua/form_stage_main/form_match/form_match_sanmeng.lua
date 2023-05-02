require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_match\\form_match_sanmeng"
local INI_FILE = "share\\Item\\item_exchange_sanmeng.ini"
local SERVER_USE_CAHCE = 1
local SERVER_CLEAR_CAHCE = 2
local SERVER_NEW_DATA = 3
local SUB_CLIENT_CHECK = 1
local SUB_CLIENT_QUERY = 2
local SANMENG_RANK_WEEK = "rank_smzb_banghui_001"
local SANMENG_RANK_SEASON = "rank_smzb_banghui_002"
local SANMENG_RANK_PERSON = "rank_smzb_geren_002"
local TYPE_PLAYER = 1
local TYPE_GUILD = 2
local TYPE_LEITAI = 3
local TYPE_LEITAI_GAME = 4
local COL_COUNT = 7
local REWARD_TYPE_COUNT = 4
local rank_test_data = "1,30,\188\170\176\215\193\213,5158,0,newschool_gumu,,2,1,\210\174\194\201\213\253,4808,0,school_wudang,\210\208\194\165\204\253\183\231\211\234,3,3,\195\183\179\164\203\213,4808,0,school_wudang,\192\197\231\240\176\241,4,3,\187\168\216\175\199\167\185\199,4808,0,newschool_shenshui,\210\208\194\165\204\253\183\231\211\234,5,45,\204\183\213\215\183\201,4805,0,,\210\208\194\165\204\253\183\231\211\234,6,6,\241\210\207\163\190\195,4792,0,,,7,7,\204\236\179\175\179\199\185\220,4790,0,school_jinyiwei,,8,8,\199\252\205\187\206\162\195\163,4291,0,school_jilegu,,9,9,\200\171\188\209\214\165,4142,0,school_wudang,,10,10,\205\216\176\207\216\175\212\194\182\249,4140,0,newschool_shenshui,\210\208\194\165\204\253\183\231\211\234,11,11,\204\198\196\254,4140,0,school_tangmen,\201\241\203\174\185\172\215\168\210\181\178\226\202\212\208\161\215\233,12,12,\203\174\184\231,4140,0,,\210\208\194\165\204\253\183\231\211\234,13,13,\190\211\200\187,4092,0,school_junzitang,,14,14,\192\215\206\228\193\250,4018,0,school_jilegu,,15,15,\207\242\190\197\179\190,3948,0,newschool_damo,,16,16,\213\212\232\186\183\168,3946,0,newschool_xuedao,\210\208\194\165\204\253\183\231\211\234,17,17,\212\192\190\178\209\213,3910,0,school_wudang,\210\208\194\165\204\253\183\231\211\234,18,18,\194\230\205\241\190\253,3908,0,,,19,19,\182\203\196\190\186\189\210\187,3731,0,,,20,20,\206\247\195\197\202\171\202\171,3718,0,,\210\208\194\165\204\253\183\231\211\234,21,21,\213\212\232\186\210\187,3660,0,,,22,22,\198\164\230\182\211\176,3638,0,newschool_xuedao,,23,23,\187\168\199\167\185\199,3629,0,newschool_damo,,24,24,\176\217\192\239\179\245\209\244,3627,0,school_wudang,,25,25,\210\187\182\254\200\253,3552,0,,,26,26,\176\215\192\199\189\220\194\222\204\216,3551,0,newschool_gumu,\206\222\181\208,27,27,\210\187\187\225\182\249,3550,0,,,28,28,\184\240\196\170\211\199,3550,0,,,29,29,\194\179\201\208\210\187\206\228\210\187,3550,0,,,30,30,\187\234\202\171\198\188,3549,0,,,31,31,\186\188\183\201\209\239,3548,0,,,32,32,\205\245\207\227\207\227,3548,0,,,33,33,\206\192\210\187\243\221,3548,0,,,34,34,\210\187\204\169\211\239\210\187,3548,0,newschool_damo,,35,35,\191\220\176\215\195\197,3496,0,newschool_wuxian,,36,36,\207\238\179\172\200\186,3494,0,newschool_damo,,37,37,\203\190\194\237\200\241,3494,0,school_jilegu,\210\208\194\165\204\253\183\231\211\234,38,38,\196\201\192\188\187\219\199\228,3473,0,newschool_damo,,39,39,\214\236\185\197\193\166,3459,0,newschool_wuxian,,40,40,\213\212\207\227,3443,0,newschool_huashan,\210\208\194\165\204\253\183\231\211\234,41,41,\182\171\183\189\176\162\202\178\182\217,3438,0,,,42,42,\200\192\230\225,3426,0,,,43,43,\188\180\196\171\180\181\209\169,3426,0,newschool_xuedao,d\196\190,44,44,\210\187\240\175\196\166\214\199\210\187,3426,0,newschool_damo,\186\206\210\212\243\207\243\239\196\172,45,45,\206\247\183\189\177\216\176\220,3426,0,,,46,46,\176\217\192\239\189\240\182\183,3426,0,newschool_xuedao,,47,47,\183\231\196\167\208\161\204\171\192\201,3426,0,newschool_xuedao,\210\208\194\165\204\253\183\231\211\234,48,48,\183\231\199\231\209\169,3424,0,newschool_nianluo,\210\208\194\165\204\253\183\231\211\234,49,49,\193\245\208\254\210\226,3422,0,newschool_shenshui,\210\208\194\165\204\253\183\231\211\234,50,50,\184\199\216\175\196\244,3422,0,newschool_huashan,\210\208\194\165\204\253\183\231\211\234,51,51,\189\240\193\234\202\174\200\253\238\206,3422,0,newschool_nianluo,\210\208\194\165\204\253\183\231\211\234,52,52,\201\207\201\188\216\175\199\171\208\197,3420,0,newschool_changfeng,\186\206\210\212\243\207\243\239\196\172,53,53,\206\197\200\203\216\204,3420,0,school_emei,\186\206\210\212\243\207\243\239\196\172,54,54,\185\171\203\239\208\249\212\175,3420,0,newschool_xuedaomen,\210\208\194\165\204\253\183\231\211\234,55,55,\213\212\216\175\196\172\243\207,3420,0,newschool_changfeng,,56,56,\204\198\216\175\195\195,3420,0,newschool_nianluo,,57,57,\182\161\216\175\135\142\216\136,3420,0,newschool_changfeng,,58,58,\196\207\186\163\216\175\201\241\196\225,3420,0,newschool_changfeng,,59,59,\185\172\177\249\212\198\210\187,3115,0,school_wudang,,60,60,\192\207\140\141\216\175\186\205\201\208,2988,0,newschool_xuedao,\211\196\182\188,61,61,\196\171\188\210\216\175\190\216\215\211,2988,0,newschool_xuedao,,62,62,\207\238\216\175\201\217\193\250,2988,0,newschool_changfeng,\210\208\194\165\204\253\183\231\211\234,63,63,\182\171\183\189\176\216,2956,0,newschool_shenshui,,64,64,\176\217\192\239\205\192\203\213,2886,0,newschool_nianluo,\210\208\194\165\204\253\183\231\211\234,65,65,\214\211\195\206\193\250\176\161\209\189,2881,0,,,66,66,\213\231\207\203\207\203,2784,0,,,67,67,\186\244\209\211\186\246\186\246,2773,0,newschool_nianluo,,68,68,\183\182\191\213\191\213,2757,0,,,69,69,\203\190\194\237\191\161,2692,0,newschool_gumu,,70,70,\201\179\218\228\196\176,2640,0,school_wudang,,71,71,\203\190\205\189\183\168\177\166,2628,0,school_wudang,,72,72,\201\242\192\203,2618,0,newschool_huashan,,73,73,\211\200\183\227,2523,0,newschool_changfeng,\180\243\192\237\203\194,74,74,\201\241\177\202\216\175\194\237\193\188,2522,0,newschool_changfeng,,75,75,\228\189\216\175\201\180\207\170,2483,0,newschool_gumu,\211\196\182\188,76,76,\199\217\216\175\199\229,2483,0,newschool_gumu,\209\176\199\216\188\199,77,77,\210\187\181\219\129W\210\185\201\177,2419,0,newschool_nianluo,,78,78,\210\187\213\197\208\161\186\227\210\187,2375,0,newschool_nianluo,,79,79,\186\194\204\236\192\199,2368,0,school_wudang,,80,80,\206\247\195\198\199\228\199\228,2261,0,,,81,81,\213\197\231\173,2260,0,,,82,82,\204\198\205\168\204\236,2259,0,,,83,83,\211\247\202\230,2258,0,,,84,84,\210\187\182\254\210\187\182\254\210\187,2258,0,,,85,85,\186\226\195\247\210\187,2258,0,,,86,86,\208\249\212\175\247\236,2135,0,newschool_huashan,\210\208\194\165\204\253\183\231\211\234,87,87,\213\197\211\162\196\193,2134,0,newschool_xuedao,,88,88,\212\189\208\254\193\250,2093,0,,,89,89,\177\223\190\179\196\193\209\242\185\183,1960,0,school_jilegu,,90,90,\194\189\216\175\208\161\248P,1939,0,school_junzitang,,91,91,\213\212\229\208\210\163,1911,0,,,92,92,\183\239\183\201\183\201,1910,0,school_changfengbiaoju,,93,93,\241\210\185\225\214\210,1909,0,,,94,94,\209\213\195\192,1909,0,,,95,95,\210\187\203\191\178\187\194\182,1885,0,school_wudang,,96,96,\206\247\195\197\201\168\181\216,1884,0,,\210\208\194\165\204\253\183\231\211\234,97,97,\180\190\211\218\203\173\183\162,1876,0,,,98,98,\202\177\195\241\210\187,1876,0,,,99,99,\176\162\180\243,1876,0,newschool_changfeng,,100,100,\186\226\212\173,1875,0,,,"
local YQ_INDEX = 3
local ZQ_INDEX = 1
local HQ_INDEX = 2
local SUB_MSG_JOIN = 0
local SUB_MSG_OPEN_TIMER = 1
local SUB_MSG_CLOSE_TIMER = 2
local STC_SEND_SINGLE_REC_DATA = 3
local STC_SEND_GUILD_REC_DATA = 4
local STC_GUILD_SCORE = 5
local STC_SHOW_RANK_STAT = 6
local STC_PLAYER_KILL_NUMBER = 7
local STC_SEND_SELF_GUILD_REC_DATA = 8
local STC_PLAYER_HELP_KILL_NUMBER = 9
local CS_GUILD_SCORE = 3
local CTS_EXCHANGE_ITEM = 6
local BST_SANMENG = 1
local BST_GUILD_UNION = 2
NODE_PROP = {
  first = {
    ForeColor = "255,220,198,160",
    NodeBackImage = "gui\\special\\smzb\\anniu_out.png",
    NodeFocusImage = "gui\\special\\smzb\\anniu_on.png",
    NodeSelectImage = "gui\\special\\smzb\\anniu_down.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  second = {
    ForeColor = "255,181,154,128",
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    ItemHeight = 22,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 3,
    Font = "font_treeview"
  }
}
function main_form_init(self)
  self.Fixed = false
  self.refresh_time = -1
  self.refresh_reward = false
  return 1
end
function open_form()
  local ST_FUNCTION_MATCH_SANMENG = 663
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MATCH_SANMENG) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_smzb_012"))
    return
  end
  util_auto_show_hide_form(FORM_NAME)
end
function open_form_guide()
  local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_match\\form_match_sanmeng", true)
  if nx_is_valid(form) then
    form:Show()
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  local cache_list = nx_value("Cache_SanMeng_Rank")
  if not nx_is_valid(cache_list) then
    self.cache_list = nx_call("util_gui", "get_global_arraylist", "Cache_SanMeng_Rank")
    init_rank_cache(self.cache_list)
  else
    self.cache_list = cache_list
  end
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(INI_FILE) then
    IniManager:LoadIniToManager(INI_FILE)
  end
  self.rbtn_join.Checked = true
  on_rbtn_join_checked_changed(self.rbtn_join)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_server_msg(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(SUB_MSG_JOIN) then
    on_handler_modal_form(unpack(arg))
  elseif nx_int(sub_msg) == nx_int(SUB_MSG_OPEN_TIMER) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local sub_type = client_player:QueryProp("BattleSubType")
    if sub_type == BST_SANMENG then
      nx_execute("form_stage_main\\form_match\\form_sanmeng_timer", "check_open_form")
    elseif sub_type == BST_GUILD_UNION then
      nx_execute("form_stage_main\\form_match\\form_guildunion_timer", "check_open_form")
    end
  elseif nx_int(sub_msg) == nx_int(SUB_MSG_CLOSE_TIMER) then
    local form_map = util_get_form("form_stage_main\\form_main\\form_main_map", true)
    if nx_is_valid(form_map) then
      form_map.btn_sanmeng.Visible = false
    end
    nx_execute("form_stage_main\\form_match\\form_sanmeng_timer", "close_form")
    nx_execute("form_stage_main\\form_match\\form_sanmeng_score", "close_form")
    nx_execute("form_stage_main\\form_match\\form_sanmeng_killnum", "refresh_killnum", -1)
  elseif nx_int(sub_msg) == nx_int(STC_SEND_SINGLE_REC_DATA) then
    nx_execute("form_stage_main\\form_match\\form_sanmeng_score", "refresh_single_data", unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_SEND_GUILD_REC_DATA) then
    nx_execute("form_stage_main\\form_match\\form_sanmeng_score", "refresh_guild_data", unpack(arg))
  elseif sub_msg == STC_GUILD_SCORE then
    on_refresh_score(unpack(arg))
  elseif sub_msg == STC_SHOW_RANK_STAT then
    on_show_rank_stat()
  elseif sub_msg == STC_PLAYER_KILL_NUMBER then
    nx_execute("form_stage_main\\form_match\\form_sanmeng_killnum", "refresh_killnum", nx_int(arg[1]))
  elseif sub_msg == STC_SEND_SELF_GUILD_REC_DATA then
    nx_execute("form_stage_main\\form_match\\form_sanmeng_score", "refresh_selfguild_data", unpack(arg))
  elseif sub_msg == STC_PLAYER_HELP_KILL_NUMBER then
    nx_execute("form_stage_main\\form_match\\form_sanmeng_killnum", "refresh_zhugong_num", nx_int(arg[1]))
  end
end
function on_rbtn_join_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_join.Visible = true
  form.groupbox_rank.Visible = false
  form.groupbox_price.Visible = false
  form.groupbox_exchange.Visible = false
end
function on_rbtn_rank_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_join.Visible = false
  form.groupbox_rank.Visible = true
  form.groupbox_price.Visible = false
  form.groupbox_exchange.Visible = false
  form.rbtn_pr.Checked = true
  form.rbtn_gr.Checked = false
  form.rbtn_gmr.Checked = false
  form.groupbox_pr.Visible = true
  form.groupbox_gr.Visible = false
  form.groupbox_gmr.Visible = false
  on_rbtn_pr_checked_changed(form.rbtn_pr)
  request_score(form)
end
function on_rbtn_price_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_join.Visible = false
  form.groupbox_rank.Visible = false
  form.groupbox_price.Visible = true
  form.groupbox_exchange.Visible = false
  if form.refresh_reward == false then
    on_show_price_info(form)
  end
end
function on_rbtn_exchange_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_join.Visible = false
  form.groupbox_rank.Visible = false
  form.groupbox_price.Visible = false
  form.groupbox_exchange.Visible = true
  on_show_exchange_tree(form)
end
function on_rbtn_pr_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_pr.Visible = true
  form.groupbox_gr.Visible = false
  form.groupbox_gmr.Visible = false
  request_query(form, SANMENG_RANK_PERSON)
  refresh_rank(form)
end
function on_rbtn_gr_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_pr.Visible = false
  form.groupbox_gr.Visible = true
  form.groupbox_gmr.Visible = false
  request_query(form, SANMENG_RANK_WEEK)
  refresh_rank(form)
end
function on_rbtn_gmr_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_pr.Visible = false
  form.groupbox_gr.Visible = false
  form.groupbox_gmr.Visible = true
  request_query(form, SANMENG_RANK_SEASON)
  refresh_rank(form)
end
function on_btn_hq_click(btn)
  send_server_msg(nx_int(SUB_MSG_JOIN), nx_int(HQ_INDEX))
end
function on_btn_zq_click(btn)
  send_server_msg(nx_int(SUB_MSG_JOIN), nx_int(ZQ_INDEX))
end
function on_btn_yq_click(btn)
  send_server_msg(nx_int(SUB_MSG_JOIN), nx_int(YQ_INDEX))
end
function send_server_msg(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MATCH_SANMENG), unpack(arg))
end
function on_handler_rank_data(...)
  if table.getn(arg) < 2 then
    return
  end
  local sub_cmd = arg[1]
  local rank_name = arg[2]
  if rank_name == nil or nx_string(rank_name) == nx_string("") then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_CLEAR_CAHCE) then
    on_clear_cache(form, rank_name)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_USE_CAHCE) then
    on_use_cache(form, rank_name)
    local timer = nx_value(GAME_TIMER)
    timer:Register(500, 1, nx_current(), "on_time_refresh", form, -1, -1)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_NEW_DATA) then
    local rank_rows = arg[3]
    local publish_time = arg[4]
    local rank_string = arg[5]
    on_set_cache(form, rank_name, rank_rows, publish_time, rank_string)
    on_use_cache(form, rank_name)
    local timer = nx_value(GAME_TIMER)
    timer:Register(500, 1, nx_current(), "on_time_refresh", form, -1, -1)
    return
  end
  return true
end
function on_clear_cache(form, rank_name)
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  rank_obj.total_rows = 0
  rank_obj.publish_time = -1
  rank_obj.rank_string = "null"
  return
end
function on_use_cache(form, rank_name)
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
end
function on_set_cache(form, rank_name, rank_rows, publish_time, rank_string)
  local rank_obj = get_cache(form, rank_name)
  if nx_is_valid(rank_obj) then
    rank_obj.total_rows = rank_rows
    rank_obj.publish_time = publish_time
    rank_obj.rank_string = rank_string
  end
  return
end
function on_time_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  refresh_rank(form)
end
function get_cache(form, rank_name)
  local cache = form.cache_list
  if not nx_is_valid(cache) then
    return
  end
  local obj = cache:GetChild(nx_string(rank_name))
  if not nx_is_valid(obj) then
    return
  end
  return obj
end
function init_rank_cache(cache_list)
  if not nx_is_valid(cache_list) then
    return
  end
  cache_list:ClearChild()
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return
  end
  child = cache_list:CreateChild(GUILD_KUAFU_GUILD_JIFEN_RANK_NAME)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
  child = cache_list:CreateChild(GUILD_KUAFU_PLAYER_JIFEN_RANK_NAME)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
end
function request_query(form, rank_name)
  if not nx_is_valid(form) then
    return
  end
  if rank_name == nil then
    return
  end
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  if rank_obj.rank_string ~= "null" then
    send_query_rank(SUB_CLIENT_CHECK, rank_name, rank_obj.publish_time)
  else
    send_query_rank(SUB_CLIENT_QUERY, rank_name, 0)
  end
end
function send_query_rank(sub_cmd, rank_name, publish_time)
  if sub_cmd == nil or rank_name == nil then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_RANK), nx_int(sub_cmd), nx_string(rank_name), nx_int(publish_time))
end
function refresh_rank(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rank_name, key_name, rank_gird
  if form.groupbox_gr.Visible == true then
    rank_name = SANMENG_RANK_WEEK
    rank_gird = form.textgrid_gr
    key_name = client_player:QueryProp("GuildName")
  elseif form.groupbox_gmr.Visible == true then
    rank_name = SANMENG_RANK_SEASON
    rank_gird = form.textgrid_gmr
    key_name = client_player:QueryProp("GuildName")
  elseif form.groupbox_pr.Visible == true then
    rank_name = SANMENG_RANK_PERSON
    rank_gird = form.textgrid_pr
    key_name = client_player:QueryProp("Name")
  else
    return
  end
  local rank_string
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  rank_string = rank_obj.rank_string
  rank_gird:BeginUpdate()
  rank_gird:ClearRow()
  rank_gird.ColCount = COL_COUNT
  rank_gird.ColWidths = nx_string(get_rank_prop(rank_name, "ColWide"))
  rank_gird.HeaderBackColor = "0,255,255,255"
  local col_list = nx_function("ext_split_string", get_rank_prop(rank_name, "ColName"), ",")
  if table.getn(col_list) ~= COL_COUNT then
    return
  end
  for i = 1, COL_COUNT do
    local head_name = gui.TextManager:GetFormatText(col_list[i])
    rank_gird:SetColTitle(i - 1, nx_widestr(head_name))
  end
  local rank_type = get_rank_prop(rank_name, "Type")
  local main_type = get_rank_prop(rank_name, "MainType")
  local string_table = util_split_wstring(nx_widestr(rank_string), ",")
  form.self_row = -1
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local key_name = ""
  if nx_int(rank_type) == nx_int(TYPE_PLAYER) or nx_int(rank_type) == nx_int(TYPE_LEITAI) or nx_int(rank_type) == nx_int(TYPE_LEITAI_GAME) then
    key_name = client_player:QueryProp("Name")
  elseif nx_int(rank_type) == nx_int(TYPE_GUILD) then
    key_name = client_player:QueryProp("GuildName")
  end
  local begin_index = 1
  for row = 0, 99 do
    if begin_index + COL_COUNT > table.getn(string_table) then
      break
    end
    rank_gird:InsertRow(-1)
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridText(row, index, nx_widestr(string_table[begin_index]))
      begin_index = begin_index + 1
    end
    local temp_name = rank_gird:GetGridText(row, 2)
    if nx_ws_equal(nx_widestr(key_name), nx_widestr(temp_name)) then
      form.self_row = row
    end
    local last_test, last_color = get_last_no(rank_gird:GetGridText(row, 0), rank_gird:GetGridText(row, 1))
    rank_gird:SetGridText(row, 1, nx_widestr(last_test))
    rank_gird:SetGridForeColor(row, 1, last_color)
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) then
      local player_name = rank_gird:GetGridText(row, 2)
      if nx_ws_equal(nx_widestr(player_name), nx_widestr("")) == false then
        local str_len = string.len(nx_string(player_name))
        if nx_number(str_len) > 5 then
          local sub_str = string.sub(nx_string(player_name), -5, -1)
          if nx_string(sub_str) == "(npc)" then
            local npc_name = nx_string(string.sub(nx_string(player_name), 1, -6))
            local show_name = nx_widestr(gui.TextManager:GetFormatText(npc_name))
            rank_gird:SetGridText(row, 2, show_name)
          end
        end
      end
    end
    if nx_int(rank_type) == nx_int(TYPE_PLAYER) or nx_int(rank_type) == nx_int(TYPE_LEITAI) or nx_int(rank_type) == nx_int(TYPE_LEITAI_GAME) then
      local school_name = rank_gird:GetGridText(row, 5)
      if nx_ws_equal(nx_widestr(school_name), nx_widestr("")) == false then
        rank_gird:SetGridText(row, 5, nx_widestr(gui.TextManager:GetFormatText(nx_string(school_name))))
      end
    end
  end
  if nx_int(form.self_row) >= nx_int(0) then
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridForeColor(form.self_row, index, "255,255,0,0")
    end
  end
  rank_gird:SetGridText(0, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_first")))
  rank_gird:SetGridText(1, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_second")))
  rank_gird:SetGridText(2, 0, gui.TextManager:GetFormatText(nx_string("ui_rank_third")))
  rank_gird:EndUpdate()
end
function get_rank_prop(rank_name, prop)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(rank_name))
  if sec_index < 0 then
    return ""
  end
  return ini:ReadString(sec_index, nx_string(prop), "")
end
function get_last_no(cur_no, last_no)
  local text = ""
  local color = "255,255,255,255"
  if nx_int(cur_no) <= nx_int(0) then
    return text, color
  end
  local gui = nx_value("gui")
  if nx_int(last_no) <= nx_int(0) then
    text = gui.TextManager:GetFormatText("ui_rank_change_new")
    color = "255,255,0,0"
    return text, color
  end
  if nx_int(cur_no) == nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_no")
    color = "255,0,0,0"
    return text, color
  end
  if nx_int(cur_no) < nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_up")
    text = nx_string(text) .. nx_string(nx_int(last_no) - nx_int(cur_no))
    color = "255,0,255,0"
    return text, color
  end
  if nx_int(cur_no) > nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_down")
    text = nx_string(text) .. nx_string(nx_int(cur_no) - nx_int(last_no))
    color = "255,255,0,0"
    return text, color
  end
end
function init_rank_cache(cache_list)
  if not nx_is_valid(cache_list) then
    return
  end
  cache_list:ClearChild()
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return
  end
  local child = cache_list:CreateChild(SANMENG_RANK_PERSON)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
  child = cache_list:CreateChild(SANMENG_RANK_WEEK)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
  child = cache_list:CreateChild(SANMENG_RANK_SEASON)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
end
function on_textgrid_pr_right_select_grid(self, row, col)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local name = self:GetGridText(row, 2)
  if name == nil or nx_string(name) == "" then
    return
  end
  local rank_type = get_rank_prop(SANMENG_RANK_PERSON, "Type")
  if nx_int(rank_type) == nx_int(2) then
    return
  end
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "rank", "rank")
  nx_execute("menu_game", "menu_recompose", menu_game, name)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_findme_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "self_row") or form.self_row < 0 then
    return
  end
  local rank_gird
  if form.groupbox_gr.Visible == true then
    rank_gird = form.textgrid_gr
  elseif form.groupbox_gmr.Visible == true then
    rank_gird = form.textgrid_gmr
  elseif form.groupbox_pr.Visible == true then
    rank_gird = form.textgrid_pr
  else
    return
  end
  rank_gird:SelectRow(form.self_row)
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
    if not util_is_lockform_visible("form_stage_main\\form_match\\form_sanmeng_wait") then
      util_auto_show_hide_form_lock("form_stage_main\\form_match\\form_sanmeng_wait")
    end
  elseif nx_int(arg[1]) == nx_int(0) then
    local wait_form = util_get_form("form_stage_main\\form_match\\form_sanmeng_wait", false)
    if not nx_is_valid(wait_form) then
      return
    end
    wait_form:Close()
  end
end
function request_score(form)
  local new_time = nx_function("ext_get_tickcount")
  if new_time - form.refresh_time < 300000 and form.refresh_time ~= -1 then
    return
  end
  send_server_msg(nx_int(CS_GUILD_SCORE))
  form.refresh_time = new_time
end
function on_refresh_score(...)
  if table.getn(arg) < 2 then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
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
  local player_score = client_player:QueryProp("SingleWarIntegral")
  local guild_week_score = arg[1]
  local guild_season_score = arg[2]
  form.lbl_r1_score.Text = nx_widestr(player_score)
  form.lbl_r2_score.Text = nx_widestr(guild_week_score)
  form.lbl_r3_score.Text = nx_widestr(guild_season_score)
end
function on_show_rank_stat()
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1500, 1, nx_current(), "on_open_rank_stat", nx_value("game_client"), -1, -1)
  end
end
function on_open_rank_stat()
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_match\\form_sanmeng_rank_stat", true, false)
  dialog:Show()
end
function get_reward_info(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_SanMeng.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string("CRewardInfo"))
  if sec_index < 0 then
    return 0
  end
  return ini:ReadString(sec_index, nx_string(index), "")
end
function on_show_price_info(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, REWARD_TYPE_COUNT do
    local str_reward = get_reward_info(i)
    if str_reward ~= "" then
      local item = util_split_string(str_reward, ";")
      for j = 1, table.getn(item) do
        local info = util_split_string(item[j], ",")
        if table.getn(info) >= 2 then
          local top = (i - 1) * 103 + 50
          local left = form.groupbox_price.Width - 70 - (table.getn(item) - j) * 45
          create_imagegrid(form, info[1], info[2], top, left)
        end
      end
    end
  end
  form.refresh_reward = true
end
function create_imagegrid(form, itemid, itemcount, top, left)
  local gui = nx_value("gui")
  local imagegrid = gui:Create("ImageGrid")
  if nx_is_valid(imagegrid) then
    imagegrid.NoFrame = true
    imagegrid.BackColor = "0,255,255,255"
    imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item.png"
    imagegrid.DrawMouseIn = "xuanzekuang_on"
    imagegrid.Width = 40
    imagegrid.Height = 40
    imagegrid.GridWidth = 38
    imagegrid.GridHeight = 38
    imagegrid.GridBackOffsetX = -4
    imagegrid.GridBackOffsetY = -3
    imagegrid.SelectColor = "0,0,0,0"
    imagegrid.MouseInColor = "0,0,0,0"
    imagegrid.Top = top
    imagegrid.Left = left
    local item_photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", itemid, "Photo")
    imagegrid:AddItem(0, item_photo, "", itemcount, -1)
    imagegrid.config_id = itemid
    nx_bind_script(imagegrid, "form_stage_main\\form_match\\form_match_sanmeng")
    nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_mousein_grid")
    nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
    form.groupbox_price:Add(imagegrid)
  end
end
function on_imagegrid_mousein_grid(imagegrid)
  if imagegrid.config_id == nil then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local item_type = ItemQuery:GetItemPropByConfigID(imagegrid.config_id, "ItemType")
  nx_execute("tips_game", "show_tips_common", imagegrid.config_id, nx_number(item_type), x, y, imagegrid.ParentForm)
end
function on_imagegrid_mouseout_grid(imagegrid)
  if imagegrid.config_id == nil then
    return
  end
  nx_execute("tips_game", "hide_tip", imagegrid.ParentForm)
end
function on_show_exchange_tree(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local tree = form.tree
  local root = tree:CreateRootNode(nx_widestr(gui.TextManager:GetFormatText("")))
  root:ClearNode()
  tree:BeginUpdate()
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("root"))
  if sec_index < 0 then
    return
  end
  local text = ini:ReadString(sec_index, nx_string("nodes"), "")
  if text == "" or text == nil then
    return
  end
  local text_array = util_split_string(nx_string(text), ",")
  for i = 1, table.getn(text_array) do
    local sub_node_sec = text_array[i]
    create_exchange_node(ini, root, text_array[i], "first")
  end
  root.Expand = true
  tree.IsNoDrawRoot = true
  tree:EndUpdate()
  local node_table = root:GetNodeList()
  if 1 <= table.getn(node_table) then
    on_tree_select_changed(tree, node_table[1])
  end
end
function create_exchange_node(ini, parent_node, sec_name, layer_prop)
  if ini == nil or not nx_is_valid(ini) then
    return
  end
  if parent_node == nil or not nx_is_valid(parent_node) then
    return
  end
  if sec_name == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(sec_name))
  if sec_index < 0 then
    return
  end
  local text = ini:ReadString(sec_index, nx_string("desc"), "")
  local node = parent_node:CreateNode(nx_widestr(util_text(text)))
  node.sec_name = sec_name
  set_node_prop(node, layer_prop)
  local sub_node_text = ini:ReadString(sec_index, nx_string("sub_node"), "")
  if nx_string(sub_node_text) ~= nx_string("") then
    local text_array = util_split_string(nx_string(sub_node_text), ",")
    for i = 1, table.getn(text_array) do
      create_exchange_node(ini, node, text_array[i], "second")
    end
  end
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function on_tree_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(cur_node) then
    return
  end
  if not nx_find_custom(cur_node, "sec_name") then
    return
  end
  show_item_info(form, cur_node.sec_name)
end
function show_item_info(form, sec_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(sec_name))
  if sec_index < 0 then
    return
  end
  local items_sec_index = ini:FindSectionIndex(nx_string("items"))
  if items_sec_index < 0 then
    return
  end
  local text = ini:ReadString(sec_index, nx_string("items"), "")
  if text == "" or text == nil then
    return
  end
  form.gsbox_item.IsEditMode = true
  form.gsbox_item:DeleteAll()
  local items = util_split_string(text, ",")
  local index = 1
  local row = 0
  local remainder = table.getn(items) % 4
  local added = 0
  if 0 < remainder then
    added = 1
  end
  local groupbox
  for i = 0, nx_int(table.getn(items) / 4) + added do
    for sub_i = 1, 4 do
      local item_sec = items[i * 4 + sub_i]
      if item_sec ~= nil then
        if sub_i == 1 then
          groupbox = gui:Create("GroupBox")
          groupbox.BackColor = "0,0,0,0"
          groupbox.NoFrame = true
          groupbox.Width = 588
          groupbox.Height = 147
        end
        local text = ini:ReadString(items_sec_index, nx_string(item_sec), "")
        if text ~= nil and text ~= "" then
          local gbox_item = create_item_view(form, gui, i, sub_i, item_sec, text)
          gbox_item.Top = 0
          gbox_item.Left = (sub_i - 1) * 147
          if gbox_item ~= nil then
            groupbox:Add(gbox_item)
          end
        end
      end
    end
    form.gsbox_item:Add(groupbox)
  end
  form.gsbox_item.IsEditMode = false
  form.gsbox_item:ResetChildrenYPos()
end
function create_item_view(form, gui, row, col, item_sec, text)
  local text_array = util_split_string(text, ",")
  if table.getn(text_array) < 5 then
    return
  end
  local award_item_text = text_array[1]
  local award_item_text_array = util_split_string(award_item_text, ":")
  if table.getn(award_item_text_array) < 3 then
    return
  end
  local item_id = award_item_text_array[2]
  local item_count = award_item_text_array[3]
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Width = 147
  groupbox.Height = 147
  groupbox.Name = "gbox_item" .. nx_string(row) .. "_" .. nx_string(col)
  local button = gui:Create("Button")
  button.Name = "btn_item_" .. nx_string(item_sec)
  button.ForeColor = "255,255,255,255"
  button.DataSource = item_id
  button.SectionName = item_sec
  button.DrawMode = "FitWindow"
  button.Width = 147
  button.Height = 147
  button.NormalImage = nx_string("gui\\special\\newshitu\\kuang_out.png")
  button.FocusImage = nx_string("gui\\special\\newshitu\\kuang_on.png")
  button.PushImage = nx_string("gui\\special\\newshitu\\kuang_down.png")
  button.Visible = true
  nx_bind_script(button, nx_current())
  nx_callback(button, "on_click", "on_btn_exitem_click")
  groupbox:Add(button)
  local imagegrid = gui:Create("ImageControlGrid")
  imagegrid.AutoSize = false
  imagegrid.Name = "img_grid_" .. nx_string(row) .. "_" .. nx_string(col)
  imagegrid.BackImage = "gui\\common\\imagegrid\\icon_item2.png"
  imagegrid.DrawMode = "Expand"
  imagegrid.NoFrame = true
  imagegrid.HasVScroll = false
  imagegrid.Width = 47
  imagegrid.Height = 47
  imagegrid.Left = 50
  imagegrid.Top = 10
  imagegrid.RowNum = 1
  imagegrid.ClomnNum = 1
  imagegrid.GridBackOffsetX = -1
  imagegrid.GridBackOffsetY = -1
  imagegrid.GridWidth = 42
  imagegrid.GridHeight = 42
  imagegrid.GridsPos = "3,3"
  imagegrid.RoundGrid = false
  imagegrid.BackColor = "0,0,0,0"
  imagegrid.SelectColor = "0,0,0,0"
  imagegrid.MouseInColor = "0,0,0,0"
  imagegrid.CoverColor = "0,0,0,0"
  imagegrid.MouseDownAlpha = 255
  imagegrid.MouseDownScale = 1
  imagegrid.MouseDownOffsetX = 0
  imagegrid.MouseDownOffsetY = 0
  imagegrid.DataSource = item_id
  imagegrid.SectionName = item_sec
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  imagegrid:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_exchange_imagegrid_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_exchange_imagegrid_mouseout_grid")
  nx_callback(imagegrid, "on_select_changed", "on_grid_select_changed")
  groupbox:Add(imagegrid)
  local mltbox = gui:Create("MultiTextBox")
  mltbox.Name = "mlt_exitem_name_" .. nx_string(row) .. "_" .. nx_string(col)
  mltbox.Transparent = true
  mltbox.NoFrame = true
  mltbox.Font = "font_sns_list"
  local name = nx_widestr("<font color=\"#ffffff\" >") .. nx_widestr(gui.TextManager:GetText(item_id)) .. nx_widestr("</font>")
  mltbox:AddHtmlText(name, -1)
  local height = mltbox:GetContentHeight()
  local width = mltbox:GetContentWidth()
  local left = 0
  if width <= groupbox.Width then
    left = groupbox.Width / 2 - width / 2
  end
  mltbox.Height = height
  mltbox.Width = width
  mltbox.Left = left
  mltbox.Top = 65
  mltbox.ViewRect = "0,0," .. nx_string(mltbox.Width) .. "," .. nx_string(mltbox.Height)
  groupbox:Add(mltbox)
  local need_item_text = text_array[2]
  local need_item_text_array = util_split_string(need_item_text, ":")
  if table.getn(need_item_text_array) < 3 then
    return
  end
  local need_item_id = need_item_text_array[2]
  local need_item_count = need_item_text_array[3]
  local need_item_name = nx_widestr(gui.TextManager:GetText(need_item_id))
  local need_item_desc
  if need_item_text_array[1] == "1" then
    need_item_desc = nx_widestr(gui.TextManager:GetFormatText("ui_smzb_consume_capital", nx_int(nx_int(need_item_count) / 1000)))
  else
    need_item_desc = nx_widestr(gui.TextManager:GetFormatText("ui_smzb_consume_item", nx_int(need_item_count), need_item_name))
  end
  local mltbox_need = gui:Create("MultiTextBox")
  mltbox_need.Name = "mlt_exitem_need_" .. nx_string(item_sec)
  mltbox_need.Transparent = true
  mltbox_need.NoFrame = true
  mltbox_need.Font = "font_sns_list"
  mltbox_need.item_desc = need_item_desc
  local name = nx_widestr("<font color=\"#ffcc00\" >") .. need_item_desc .. nx_widestr("</font>")
  mltbox_need:AddHtmlText(name, -1)
  local height = mltbox_need:GetContentHeight()
  local width = mltbox_need:GetContentWidth()
  local left = 0
  if width <= groupbox.Width then
    left = groupbox.Width / 2 - width / 2
  end
  mltbox_need.Height = height
  mltbox_need.Width = width
  mltbox_need.Left = left
  mltbox_need.Top = mltbox.Top + mltbox.Height + 5
  mltbox_need.ViewRect = "0,0," .. nx_string(mltbox_need.Width) .. "," .. nx_string(mltbox_need.Height)
  groupbox:Add(mltbox_need)
  nx_set_custom(form, nx_string(mltbox_need.Name), mltbox_need)
  local limit_type = nx_int(text_array[3])
  if limit_type == nx_int(1) or limit_type == nx_int(2) then
    local ex_count_max = nx_int(text_array[4])
    local mltbox_limit = gui:Create("MultiTextBox")
    local limit_name = "mlt_exitem_limit_" .. nx_string(item_sec)
    mltbox_limit.Name = limit_name
    mltbox_limit.Transparent = true
    mltbox_limit.NoFrame = true
    mltbox_limit.Font = "font_sns_list"
    local tips_text
    if limit_type == nx_int(1) then
      tips_text = nx_widestr(gui.TextManager:GetFormatText("ui_smzb_day_limit_desc", ex_count_max))
    else
      tips_text = nx_widestr(gui.TextManager:GetFormatText("ui_smzb_week_limit_desc", ex_count_max))
    end
    local name = nx_widestr("<font color=\"#9c9c9c\" >") .. tips_text .. nx_widestr("</font>")
    mltbox_limit:AddHtmlText(name, -1)
    local height = mltbox_limit:GetContentHeight()
    local width = mltbox_limit:GetContentWidth()
    local left = 0
    if width <= groupbox.Width then
      left = groupbox.Width / 2 - width / 2
    end
    mltbox_limit.Height = height
    mltbox_limit.Width = width
    mltbox_limit.Left = left
    mltbox_limit.Top = mltbox_need.Top + mltbox_need.Height + 5
    mltbox_limit.ViewRect = "0,0," .. nx_string(mltbox_limit.Width) .. "," .. nx_string(mltbox_limit.Height)
    groupbox:Add(mltbox_limit)
  end
  return groupbox
end
function on_exchange_imagegrid_mousein_grid(grid)
  local ConfigID = grid.DataSource
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_exchange_imagegrid_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip")
end
function on_grid_select_changed(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_match\\form_sanmeng_exchange", "open_form")
  local need_item_desc
  if nx_find_custom(form, "mlt_exitem_need_" .. grid.SectionName) then
    local ctrl = nx_custom(form, "mlt_exitem_need_" .. grid.SectionName)
    if nx_is_valid(ctrl) then
      need_item_desc = ctrl.item_desc
    end
  end
  nx_execute("form_stage_main\\form_match\\form_sanmeng_exchange", "show_exchange_item_info", grid.DataSource, grid.SectionName, need_item_desc)
end
function on_btn_exitem_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_match\\form_sanmeng_exchange", "open_form")
  local need_item_desc
  if nx_find_custom(form, "mlt_exitem_need_" .. btn.SectionName) then
    local ctrl = nx_custom(form, "mlt_exitem_need_" .. btn.SectionName)
    if nx_is_valid(ctrl) then
      need_item_desc = ctrl.item_desc
    end
  end
  nx_execute("form_stage_main\\form_match\\form_sanmeng_exchange", "show_exchange_item_info", btn.DataSource, btn.SectionName, need_item_desc)
end
