CLIENT_SUB_CREATE = 1
CLIENT_SUB_ENTRY = 2
CLIENT_SUB_LEFT = 3
CLIENT_SUB_LEVELUP = 4
CLIENT_SUB_QUERY = 5
CLIENT_SUB_UPDATE_NEIGHBOUR = 6
CLIENT_SUB_ROLE_HOMES = 7
CLIENT_SUB_COMMUNITY_HOMES = 8
CLIENT_SUB_CHANGE_NAME = 9
CLIENT_SUB_PUT_GOODS = 10
CLIENT_BUY_FURNITURN = 11
CLIENT_SEND_FURNITURN = 12
CLIENT_GETBACK_STORAGE = 13
CLIENT_SUB_ADD_NEIGHBOUR = 14
CLIENT_SUB_QUERY_VISITORS = 15
CLIENT_SUB_DESTORY = 16
CLIENT_SUB_MOVE_GOODS = 17
CLIENT_SUB_BACK_GOODS = 18
CLIENT_SUB_EVENT = 19
CLIENT_SUB_HIRE_FUNCNPC = 20
CLIENT_SUB_UNHIRE_FUNCNPC = 21
CLIENT_SUB_SET_FUNCNPC_CRY = 22
CLIENT_SUB_CHOOSE_FUNCNPC_ACTION = 23
CLIENT_SUB_MOVE_FUNCNPC = 24
CLIENT_SUB_HIRENPC_INFO = 25
CLIENT_SUB_REQUEST_SELLHOME = 26
CLIENT_SUB_BUYHOME = 27
CLIENT_SUB_SELLHOME = 28
CLIENT_SUB_SELLINFO = 29
CLIENT_SUB_FIXBUY = 30
CLIENT_SUB_BID = 31
CLIENT_SUB_ENDTRADE = 32
CLIENT_SUB_DEL_NEIGHBOUR = 33
CLIENT_SUB_DIRECT_BID = 34
CLIENT_SUB_DIRECT_SELLHOME = 35
CLIENT_SUB_DEL_VISITORS = 36
CLIENT_SUB_SET_EVENT_LOG = 38
CLIENT_SUB_QUERY_PARTNER_HOME_INFO = 39
CLIENT_SUB_REQUEST_MOVEHOME = 40
CLIENT_SUB_SET_VISIT = 41
CLIENT_SUB_REQUEST_BUILDING_ACTIVE_NUMBER = 42
CLIENT_SUB_GET_HOME_FRIEND = 47
CLIENT_SUB_GET_HIRE_ALL_INFO = 48
CLIENT_SUB_GET_HIRE_SINGLE_INFO = 49
CLIENT_SUB_GET_HIRE_MORE_INFO = 50
CLIENT_SUB_BUILDING_ACTIVE = 51
CLIENT_SUB_BUILDING_SELECT = 52
CLIENT_SUB_STABLE_SELECT = 53
CLIENT_SUB_INTER_BUILDING = 55
CLIENT_SUB_HOME_GOUHUO = 56
CLIENT_SUB_BUILDING_LEVELUP = 57
CLIENT_SUB_BUILDING_HIRE = 58
CLIENT_SUB_GET_LEVEL_INFO = 59
CLIENT_SUB_BUILDING_MAX = 60
CLIENT_SUB_ORDER_REFRESH = 61
CLIENT_SUB_ORDER_SEND = 62
CLIENT_SUB_ORDER_BACK = 63
CLIENT_SUB_ORDER_GET_AWARK = 64
CLIENT_SUB_PET_HOME = 71
CLIENT_SUB_HOME_SPECIAL_ORDER = 72
CLIENT_SUB_HOME_QIN_PLAY = 73
CLIENT_SUB_HOME_INFO = 80
CLIENT_SUB_SCENE_SELL_INFO = 81
CLIENT_SUB_REQUEST_CREATE_HOME = 82
CLIENT_SUB_BUY_MY_HOME = 83
CLIENT_SUB_REQUEST_HOME_PRICE = 84
CLIENT_SUB_SEARCH_HOME = 85
SERVER_SUB_CREATE_OPEN = 1
SERVER_SUB_OPEN_COMPOSE = 2
SERVER_SUB_QUERY_HOME = 3
SERVER_SUB_ROLE_HOMES = 4
SERVER_SUB_COMMUNITY_HOMES = 5
SERVER_SUB_SELECT_HOMES = 6
SERVER_SUB_CREATE_SUCCESS = 11
SERVER_SUB_CREATE_FAILED = 12
CLIENT_SUB_PUT_GOODS_SUCCESS = 13
CLIENT_SUB_PUT_GOODS_FAILED = 14
SERVER_SUB_QUERY_VISITORS = 15
SERVER_SUB_HIRENPC_INFO = 16
SERVER_SUB_SELLHOME = 17
SERVER_SUB_BUYHOME = 18
SERVER_SUB_SELLINFO = 19
SERVER_SUB_OPEN_HOME_HELP = 20
SERVER_SUB_FENGSHUI = 21
SERVER_SUB_QUERY_PARTNER_HOME_INFO = 22
SERVER_SUB_QUERY_BUILDING_ACTIVED_NUM = 23
SERVER_SUB_OPEN_TYGN_HELP = 24
SERVER_SUB_GET_HOME_FRIEND = 30
SERVER_SUB_BUILDING_ACTIVE = 31
SERVER_SUB_BUILDING_SELECT = 32
SERVER_SUB_STABLE_SELECT = 33
SERVER_SUB_BUILDING_ACTIVE_OK = 34
SERVER_SUB_INTER_BUILDING = 35
SERVER_SUB_GET_LEVEL_INFO = 36
SERVER_SUB_GET_HIRE_ALL_INFO = 37
SERVER_SUB_GET_HIRE_SINGLE_INFO = 38
SERVER_SUB_GET_HIRE_MORE_INFO = 39
SERVER_SUB_BUILDING_MAX = 40
SERVER_SUB_HOME_ORDER = 41
SERVER_SUB_HOME_LEITAI_JOIN = 45
SERVER_SUB_HOME_LEITAI_LEAVE = 46
SERVER_SUB_HOME_LEITAI_FORM = 47
SERVER_SUB_PET_HOME_FORM_OPEN = 51
SERVER_SUB_PARTNER_PET_HOME_UPDATE = 52
SERVER_SUB_HOME_QIN_OPEN_UI = 53
SERVER_SUB_HOME_QIN_INFO = 54
SERVER_SUB_HOMEINFO = 60
SERVER_SUB_SCENE_SELL = 61
SERVER_SUB_OPEN_HOME_MAP = 62
SERVER_SUB_VOER_HOME_PRICE = 63
SERVER_SUB_SEARCH_HOMEINFO = 64
SERVER_SUB_SPECIAL_ORDER = 65
HOME_STATUS_ERROR = 0
HOME_STATUS_IDLE = 1
HOME_STATUS_LIVE = 2
HOME_STATUS_SELL = 3
HOME_STATUS_WASTE = 4
function server_to_client_msg(msg_type, sub_cmd, ...)
  if SERVER_SUB_CREATE_OPEN == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_build", "open_form", nx_int(arg[1]))
  elseif SERVER_SUB_OPEN_HOME_MAP == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home", "open_form", unpack(arg))
  elseif SERVER_SUB_OPEN_COMPOSE == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_main", "open_form", 2)
  elseif SERVER_SUB_ROLE_HOMES == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_neighbor", "fresh_wife_home", unpack(arg))
  elseif SERVER_SUB_QUERY_HOME == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_myhome", "fresh_home_detail", unpack(arg))
    nx_execute("form_stage_main\\form_home\\form_home_neighbor", "fresh_home_detail", unpack(arg))
    nx_execute("form_stage_main\\form_home\\form_home", "refresh_visit", unpack(arg))
  elseif SERVER_SUB_COMMUNITY_HOMES == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_world", "fresh_home", unpack(arg))
  elseif SERVER_SUB_SELECT_HOMES == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_zh", "open_form", unpack(arg))
  elseif SERVER_SUB_CREATE_SUCCESS == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_build", "close_form")
    nx_execute("form_stage_main\\form_home\\form_home", "close_home_form")
  elseif SERVER_SUB_QUERY_VISITORS == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_myhome", "fresh_wife_home", unpack(arg))
    nx_execute("form_stage_main\\form_home\\form_home_mutual", "fresh_wife_home", unpack(arg))
  elseif SERVER_SUB_HIRENPC_INFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_myhome", "fresh_guyong", unpack(arg))
    nx_execute("form_stage_main\\form_home\\form_home_neighbor", "fresh_guyong", unpack(arg))
  elseif SERVER_SUB_SELLHOME == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_sell", "open_form", unpack(arg))
  elseif SERVER_SUB_SELLINFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_sellinfo", "open_form", unpack(arg))
  elseif SERVER_SUB_SCENE_SELL == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home", "receive_home_sell_data", unpack(arg))
  elseif SERVER_SUB_HOMEINFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home", "receive_server_ownership_data", unpack(arg))
  elseif SERVER_SUB_SEARCH_HOMEINFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home", "receive_search_ownership", unpack(arg))
  elseif SERVER_SUB_BUYHOME == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_buy", "open_form", unpack(arg))
  elseif SERVER_SUB_OPEN_HOME_HELP == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_help", "open_form")
  elseif SERVER_SUB_FENGSHUI == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_function", "handle_fengshui_msg", unpack(arg))
  elseif SERVER_SUB_QUERY_PARTNER_HOME_INFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_myhome", "add_partner_home_list", unpack(arg))
  elseif SERVER_SUB_VOER_HOME_PRICE == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home", "show_current_recycle_price", unpack(arg))
  elseif SERVER_SUB_HOME_ORDER == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_order", "open_form", unpack(arg))
  elseif SERVER_SUB_BUILDING_ACTIVE == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_building_active", "open_form_active", unpack(arg))
  elseif SERVER_SUB_BUILDING_SELECT == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_building_select", "open_form", unpack(arg))
  elseif SERVER_SUB_STABLE_SELECT == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_stable", "on_server_msg", unpack(arg))
  elseif SERVER_SUB_BUILDING_ACTIVE_OK == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_building_active", "close_form")
  elseif SERVER_SUB_GET_LEVEL_INFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_building_levelup", "update_info", unpack(arg))
  elseif SERVER_SUB_GET_HIRE_ALL_INFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_building_hire_all_info", "update_info", unpack(arg))
  elseif SERVER_SUB_GET_HIRE_SINGLE_INFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_building_hire", "update_info", unpack(arg))
  elseif SERVER_SUB_GET_HIRE_MORE_INFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_building_hire_info", "update_info", unpack(arg))
  elseif SERVER_SUB_GET_HOME_FRIEND == sub_cmd then
    local mouse_control = nx_value("MouseControl")
    if nx_is_valid(mouse_control) then
      mouse_control:UpdateHomeFriend(nx_string(arg[1]), nx_int(arg[2]), nx_int(arg[3]))
    end
  elseif SERVER_SUB_PET_HOME_FORM_OPEN == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_pet", "on_server_msg_open_form", unpack(arg))
  elseif SERVER_SUB_PARTNER_PET_HOME_UPDATE == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_partner_pet", "on_partner_form_update", unpack(arg))
  elseif SERVER_SUB_INTER_BUILDING == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_ceaseb_meun", "on_server_msg", unpack(arg))
  elseif SERVER_SUB_QUERY_BUILDING_ACTIVED_NUM == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_myhome", "fresh_building_active", unpack(arg))
  elseif SERVER_SUB_OPEN_TYGN_HELP == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_help_ty", "open_form")
  elseif SERVER_SUB_HOME_LEITAI_JOIN == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_enter", "hide_homeleitai_form")
  elseif SERVER_SUB_HOME_LEITAI_LEAVE == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_enter", "show_homeleitai_form")
  elseif SERVER_SUB_HOME_LEITAI_FORM == sub_cmd then
    nx_execute("form_stage_main\\form_leitai\\form_leitai", "open_form_by_func_type", 4)
  elseif SERVER_SUB_SPECIAL_ORDER == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_home_order", "rec_home_order_finish_time", unpack(arg))
  elseif SERVER_SUB_HOME_QIN_OPEN_UI == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_qin_player", "open_form")
  elseif SERVER_SUB_HOME_QIN_INFO == sub_cmd then
    nx_execute("form_stage_main\\form_home\\form_qin_player", "show_info", unpack(arg))
  end
end
function client_to_server_msg(sub_cmd, ...)
  nx_execute("custom_sender", "custom_home", nx_int(sub_cmd), unpack(arg))
end
