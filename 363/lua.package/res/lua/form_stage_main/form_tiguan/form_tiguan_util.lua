require("util_gui")
require("util_functions")
FORM_TIGUAN_MAIN = "form_stage_main\\form_tiguan\\form_tiguan_main"
FORM_TIGUAN_OTHER = "form_stage_main\\form_tiguan\\form_tiguan_other"
FORM_TIGUAN_TRACE = "form_stage_main\\form_tiguan\\form_tiguan_trace"
FORM_TIGUAN_RESULT = "form_stage_main\\form_tiguan\\form_tiguan_result"
FORM_TIGUAN_READY = "form_stage_main\\form_tiguan\\form_tiguan_ready"
FORM_TIGUAN_GO = "form_stage_main\\form_tiguan\\form_tiguan_go"
FORM_TIGUAN_DETAIL = "form_stage_main\\form_tiguan\\form_tiguan_detail"
FORM_TIGUAN_TALK = "form_stage_main\\form_tiguan\\form_tiguan_talk"
FORM_TIGUAN_BOXAWARD = "form_stage_main\\form_tiguan\\form_tiguan_boxaward"
FORM_TIGUAN_ONE = "form_stage_main\\form_tiguan\\form_tiguan_one"
FORM_TIGUAN_EXCHANGE = "form_stage_main\\form_tiguan\\form_tiguan_exchange"
FORM_TIGUAN_CHOICE_BOSS = "form_stage_main\\form_tiguan\\form_tiguan_choice_boss"
FORM_TIGUAN_FRIEND = "form_stage_main\\form_tiguan\\form_tiguan_friend"
FORM_TIGUAN_STRONG_BOSS = "form_stage_main\\form_tiguan\\form_tiguan_strong_boss"
CHANGGUAN_AREA_INI = "ini\\ui\\tiguan\\changguan_area.ini"
CHANGGUAN_UI_INI = "ini\\ui\\tiguan\\changguan.ini"
CHANGGUAN_CDT_INI = "share\\War\\tiguan_success_condition.ini"
CHANGGUAN_APPEND_CDT_INI = "share\\War\\tiguan_append_condition.ini"
SHARE_CHANGGUAN_INI = "share\\War\\tiguan.ini"
CHANGGUAN_UI_ACHIEVE_INI = "ini\\ui\\tiguan\\tiguan_achieve.ini"
CHANGGUAN_UI_EXCHANGE_INI = "ini\\ui\\tiguan\\tiguan_exchange.ini"
SHARE_TIGUAN_DANSHUA_INI = "share\\War\\tiguan_danshua.ini"
CHANGGUAN_UI_ONE_INI = "ini\\ui\\tiguan\\tiguan_one.ini"
SHARE_TIGUAN_AWARD_INI = "share\\War\\tiguan_danshua_award.ini"
SHARE_TIGUAN_CONDITION = "share\\War\\tiguan_danshua_condition.ini"
SHARE_TIGUAN_EXCHANGE = "share\\War\\tiguan_danshua_exchange.ini"
SKILL_BACKIMAGE = "gui\\special\\tiguan\\TGJN.png"
RESULT_BACKIMAGE = {
  "gui\\language\\ChineseS\\tiguan\\win.png",
  "gui\\language\\ChineseS\\tiguan\\lose.png",
  "gui\\language\\ChineseS\\tiguan\\timeout.png"
}
DIFFICULT_PHOTO = {
  "gui\\special\\tiguan\\nd_1.png",
  "gui\\special\\tiguan\\nd_2.png",
  "gui\\special\\tiguan\\nd_3.png"
}
TG_SCORE_ANI_LEVEL = {
  "tg_score_level_1",
  "tg_score_level_2",
  "tg_score_level_3",
  "tg_score_level_4"
}
TIGUAN_SOUND = {
  [1] = {
    "tigaun_warn_snd",
    "snd\\ui\\tiguan_warning.wav"
  },
  [2] = {
    "tigaun_result_snd",
    "snd\\ui\\tiguan_result.wav"
  }
}
BTN_TEXT = {
  [1] = "ui_tiguan_start",
  [2] = "ui_tiguan_stop"
}
LBL_TEXT = {
  [1] = "ui_tiguan_wait_select",
  [2] = "ui_tiguan_wait_enter"
}
ENTER_GUAN_CDT_STATE = {
  [1] = {
    "ui_tiguan_can_enter",
    "255,0,255,0"
  },
  [2] = {
    "ui_tiguan_no_times",
    "255,255,0,0"
  },
  [3] = {
    "ui_tiguan_no_score",
    "255,255,0,0"
  },
  [4] = {
    "ui_tuguan_no_repute",
    "255,255,0,0"
  },
  [5] = {
    "ui_tiguan_mession",
    "255,255,0,0"
  },
  [6] = {
    "ui_tiguan_fighting",
    "255,255,0,0"
  }
}
LOOK_INFO_WIN_NPC = 0
LOOK_INFO_WIN_GUAN = 1
TG_RESULT_SUCCEED = 0
TG_RESULT_FAILED = 1
TG_RESULT_TIMEOUT = 2
ENTER_GUAN_INIT = 0
ENTER_GUAN_STAR = 1
ENTER_GUAN_STOP = 2
ENTER_GUAN_CLOSE = 3
ENTER_GUAN_TALK = 4
FINISH_CDT_OPEN = 0
FINISH_CDT_REFRESH_BASE = 1
FINISH_CDT_REFRESH_APPEND = 2
FINISH_CDT_OPEN_CONTINUE = 3
FINISH_CDT_REFRESH_BASE_CONTINUE = 4
FINISH_CDT_REFRESH_APPEND_CONTINUE = 5
FINISH_CDT_CLOSE = 6
SHOW_DETAIL_OPEN = 0
SHOW_DETAIL_CLOSE = 1
SHOW_BOXAWARD_OPEN = 0
SHOW_BOXAWARD_CLOSE = 1
SHOW_BOXAWARD_AGAIN = 2
JION_TIGUAN_BEGIN = 0
JION_TIGUAN_CONTINUE = 1
JION_TIGUAN_HILFWAY = 2
TG_DEAD_TIME_DOWN_STAR = 0
TG_DEAD_TIME_DOWN_STOP = 1
REFRESH_TIME = 8
AREA_CG_COUNT = 20
CHANGGUAN_DIT_LEVEL = 12
ENTER_GUAN_PLAY_COUNT = 6
GUAN_COUNT_MAX = 32
NODE_TYPE_CG = 1
NODE_TYPE_NPC = 2
NODE_FORECOLOR_NORMAL = "255,181,154,128"
NODE_FORECOLOR_DISABLE = "255,114,114,114"
RANDOM_NPC_TIME = 10
GROUP_NPC_COUNT = 3
REPUTE_CHANGE_TIME = 3
SCORE_LEVEL_0 = 0
SCORE_LEVEL_1 = 100
SCORE_LEVEL_2 = 130
SCORE_LEVEL_3 = 160
SCORE_LEVEL_4 = 330
NODE_PROP = {
  [1] = {
    NodeBackImage = "gui\\common\\treeview\\tree_1_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png",
    NodeCoverImage = "gui\\special\\tiguan\\chac.png",
    Font = "font_treeview",
    ForeColor = "255,197,184,159",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 6
  },
  [2] = {
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeCoverImage = "gui\\special\\tiguan\\chac.png",
    Font = "font_treeview",
    ItemHeight = 22,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 3
  }
}
function play_sound(sound_data)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if sound_data == nil or table.getn(sound_data) ~= 2 then
    return
  end
  if not gui:FindSound(nx_string(sound_data[1])) then
    gui:AddSound(nx_string(sound_data[1]), nx_resource_path() .. nx_string(sound_data[2]))
  end
  gui:PlayingSound(nx_string(sound_data[1]))
end
function get_large_photo(normal_photo)
  if normal_photo == nil then
    return ""
  end
  local len = string.len(normal_photo)
  if len <= 4 then
    return ""
  end
  local prefix = string.sub(normal_photo, 1, len - 4)
  local suffix = string.sub(normal_photo, len - 3)
  return prefix .. "_large" .. suffix
end
function get_ani_by_score(score)
  if nx_number(score) >= SCORE_LEVEL_0 and nx_number(score) < SCORE_LEVEL_1 then
    return TG_SCORE_ANI_LEVEL[1]
  elseif nx_number(score) >= SCORE_LEVEL_1 and nx_number(score) < SCORE_LEVEL_2 then
    return TG_SCORE_ANI_LEVEL[2]
  elseif nx_number(score) >= SCORE_LEVEL_2 and nx_number(score) < SCORE_LEVEL_3 then
    return TG_SCORE_ANI_LEVEL[3]
  elseif nx_number(score) >= SCORE_LEVEL_3 then
    return TG_SCORE_ANI_LEVEL[4]
  end
  return ""
end
function get_dual_play_star_by_score(score)
  if nx_number(score) >= SCORE_LEVEL_0 and nx_number(score) < SCORE_LEVEL_1 then
    return 1
  elseif nx_number(score) >= SCORE_LEVEL_1 and nx_number(score) < SCORE_LEVEL_2 then
    return 2
  elseif nx_number(score) >= SCORE_LEVEL_2 and nx_number(score) < SCORE_LEVEL_3 then
    return 3
  elseif nx_number(score) >= SCORE_LEVEL_3 then
    return 4
  end
  return 0
end
function check_is_TeamCaption()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local team = client_player:QueryProp("TeamCaptain")
  local name = client_player:QueryProp("Name")
  return nx_string(team) == nx_string(name)
end
function is_player_in_guan()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local cur_guan_id = client_player:QueryProp("CurGuanID")
  if nx_number(cur_guan_id) ~= 0 then
    local show_text = gui.TextManager:GetText("cuanlimitweek_1")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(show_text, CENTERINFO_PERSONAL_NO)
    end
    return true
  end
  return false
end
function set_node_prop(node, index)
  if not nx_is_valid(node) then
    return 0
  end
  if 0 > nx_number(index) or nx_number(index) > table.getn(NODE_PROP) then
    return 0
  end
  for prop_name, value in pairs(NODE_PROP[nx_number(index)]) do
    nx_set_property(node, nx_string(prop_name), value)
  end
end
function get_item_info(configid, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function get_item_id_for_choice_boss(level)
  local danshua_ini = nx_execute("util_functions", "get_ini", SHARE_TIGUAN_DANSHUA_INI)
  if not nx_is_valid(danshua_ini) then
    return ""
  end
  level = nx_number(level)
  local index = danshua_ini:FindSectionIndex("Info")
  if index < 0 then
    return ""
  end
  local item_str = danshua_ini:ReadString(index, "AppointItem", "")
  local item_tab = util_split_string(item_str, ",")
  if level > table.getn(item_tab) or level <= 0 then
    return ""
  end
  return item_tab[level]
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
function get_desc_by_id(text_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  return gui.TextManager:GetText(nx_string(text_id))
end
function on_close_exchange_form()
  local form_tiguan_exchange = util_show_form(FORM_TIGUAN_EXCHANGE, false)
  if nx_is_valid(form_tiguan_exchange) then
    form_tiguan_exchange:Close()
  end
end
function on_close_select_boss_form()
  local form_tiguan_select = util_show_form(FORM_TIGUAN_CHOICE_BOSS, false)
  if nx_is_valid(form_tiguan_select) then
    form_tiguan_select:Close()
  end
end
function on_close_select_friend_form()
  local form_frined = util_show_form(FORM_TIGUAN_FRIEND, false)
  if nx_is_valid(form_frined) then
    form_frined:Close()
  end
end
CLIENT_MSG_DS_FORM_INIT = 0
CLIENT_MSG_DS_LEVEL_INFO = 1
CLIENT_MSG_DS_BOSS_NOTE = 2
CLIENT_MSG_DS_RANDOM = 3
CLIENT_MSG_DS_BEGIN = 4
CLIENT_MSG_DS_ACHIEVE_INFO = 5
CLIENT_MSG_DS_ACHIEVE_AWARD = 6
CLIENT_MSG_DS_EXCHANGE = 7
CLIENT_MSG_DS_PASS_AWARD = 8
CLIENT_MSG_DS_RANK_AWARD = 9
CLIENT_MSG_DS_RANK_INFO = 10
CLIENT_MSG_DS_FIRST_DEFEAT_INFO = 11
CLIENT_MSG_DS_LEVEL_APPRAISE = 12
CLIENT_MSG_DS_DIRECT_FINISH = 13
CLIENT_MSG_DS_APPOINT_BOSS = 14
CLIENT_MSG_DS_OFFSET_OMIT = 16
CLIENT_MSG_DS_DOUBLE_MODEL = 17
CLIENT_MSG_DS_APPLY_RANK = 18
CLIENT_MSG_DS_CANCE_RANK = 19
CLIENT_MSG_DS_INVITE_ALLY = 20
CLIENT_MSG_DS_ALTER_ALLY = 21
CLIENT_MSG_DS_PRACTICE_MODEL = 22
CLIENT_MSG_DS_EXCHANGE_QUERY = 23
CLIENT_MSG_DS_STRONG_BOSS = 24
SERVER_MSG_DS_INIT_FORM = 0
SERVER_MSG_DS_ARREST_INFO = 1
SERVER_MSG_DS_TODAY_INFO = 2
SERVER_MSG_DS_RANDOM_INFO = 3
SERVER_MSG_DS_ACHIEVE_INFO = 4
SERVER_MSG_DS_RANK_INFO = 5
SERVER_MSG_DS_FIRST_DEFEAT_INFO = 6
SERVER_MSG_DS_BOSS_NOTE = 7
SERVER_MSG_DS_FINISH_ACHIEVE = 8
SERVER_MSG_DS_CLOSE_FORM = 9
SERVER_MSG_DS_LEVEL_APPRAISE = 10
SERVER_MSG_DS_COMPARE_INFO = 12
SERVER_MSG_DS_LEAD_ACHIEVE = 13
ERVER_MSG_DS_APPOINT_BOSS = 14
ERVER_MSG_DS_OPEN_FORM = 15
SERVER_MSG_DS_DIS_CONDITION = 16
SERVER_MSG_DS_EXCHANGE_SUC = 17
SERVER_MSG_DS_REGIST_RANK = 18
SERVER_MSG_DS_REGIST_NUM = 19
SERVER_MSG_DS_ALTER_ALLY = 20
SERVER_MSG_DS_INVITE_SUC = 21
SERVER_MSG_DS_EXCHANGE_NUM = 22
SERVER_MSG_DS_REMAIN_INVITE = 23
SERVER_MSG_DS_STRONG_BOSS = 24
SERVER_MSG_DS_SWITCH_EXCHANGE = 25
SERVER_MSG_DS_BEGIN = 50
SERVER_MSG_DS_END = 51
function tiguan_danshua_msg(type, ...)
  if SERVER_MSG_DS_BEGIN == type then
    in_out_danshua(1)
  elseif SERVER_MSG_DS_END == type then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_ds_trace", "close_form", unpack(arg))
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_strong_boss", "close_form", unpack(arg))
    in_out_danshua(0)
  elseif ERVER_MSG_DS_OPEN_FORM == type then
    local form = util_get_form(FORM_TIGUAN_ONE, true)
    if nx_is_valid(form) then
      nx_execute("util_gui", "util_show_form", FORM_TIGUAN_ONE, true)
    end
  elseif SERVER_MSG_DS_COMPARE_INFO == type then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_ds_trace", "show_ds_trace", unpack(arg))
  elseif SERVER_MSG_DS_INVITE_SUC == type then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_ds_trace", "invite_ally_suc", unpack(arg))
  elseif SERVER_MSG_DS_REMAIN_INVITE == type then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_ds_trace", "updata_remain_invite", unpack(arg))
  elseif SERVER_MSG_DS_STRONG_BOSS == type then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_strong_boss", "show_strong_boss", unpack(arg))
  end
end
function in_out_danshua(type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local role = game_client:GetPlayer()
  if not nx_is_valid(role) then
    return
  end
  role.InDanShua = type
end
