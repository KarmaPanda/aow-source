require("share\\client_custom_define")
require("define\\request_type")
require("define\\move_define")
require("player_state\\state_const")
require("form_stage_main\\form_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
require("share\\logicstate_define")
require("define\\camera_mode")
require("util_functions")
require("share\\chat_define")
require("form_stage_main\\switch\\url_define")
require("define\\jiuyinzhi_define")
require("define\\sysinfo_define")
require("define\\star_module_define")
require("form_stage_main\\form_task\\task_define")
require("form_stage_main\\form_tvt\\define")
function check_word(CheckWords, content, count)
  if 10 < count then
    return content
  end
  count = count + 1
  local front = nx_function("ext_ws_find", content, nx_widestr("<a href"))
  local back = nx_function("ext_ws_find", content, nx_widestr("a>"))
  if front ~= -1 and back ~= -1 then
    local hylink_begin_pos = front
    local hylink_end_pos = back + 1
    local hylink_len = hylink_end_pos - hylink_begin_pos + 1
    local front_len = front
    local front_str = nx_function("ext_ws_substr", content, 0, front_len)
    local center = nx_function("ext_ws_substr", content, hylink_begin_pos, hylink_len)
    local back_str = nx_function("ext_ws_substr", content, hylink_end_pos + 1, -1)
    local end_word = check_word(CheckWords, front_str, count) .. center .. check_word(CheckWords, back_str, count)
    return end_word
  else
    content = nx_widestr(CheckWords:CleanWords(nx_widestr(content)))
    return content
  end
end
function custom_chat(chat_type, content, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return 0
  end
  content = nx_widestr(content)
  local count = 1
  local new_word = check_word(CheckWords, content, count)
  chat_info = nx_widestr(new_word)
  local is_leader_mode = 0
  if CHATTYPE_GUILD == chat_type or CHATTYPE_SCHOOL == chat_type then
    local form_chat_main = nx_value("form_stage_main\\form_main\\form_main_chat")
    if nx_is_valid(form_chat_main) and form_chat_main.cbtn_gaoshi.Checked then
      is_leader_mode = 1
    end
  end
  local str = util_encrypt_string(chat_info)
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAT), nx_int(chat_type), nx_widestr(str), nx_int(is_leader_mode))
end
function custom_speaker(chat_type, info, send_cnt, ani_pic, switch)
  send_cnt = send_cnt or 1
  ani_pic = ani_pic or ""
  if switch == nil then
    switch = 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return 0
  end
  local count = 1
  local new_word = check_word(CheckWords, nx_widestr(info), count)
  local chat_info = nx_widestr(new_word)
  local str = util_encrypt_string(chat_info)
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAT), nx_int(chat_type), nx_widestr(str), nx_int(send_cnt), nx_string(ani_pic), nx_int(switch))
end
function custom_get_cross_speaker_queue()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAT), nx_int(CHATTYPE_GET_SPEAKER_QUEUE))
end
function custom_get_cross_speaker_data(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAT), nx_int(CHATTYPE_SANMENG_INTEGRAL), unpack(arg))
end
function custom_get_speaker_queue()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAT), nx_int(CHATTYPE_GET_SPEAKER_QUEUE))
end
function custom_get_speaker_rank()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAT), nx_int(CHATTYPE_GET_SPEAKER_RANK))
end
function custom_gminfo(info)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GM), info)
end
function custom_update_ng_bind(info)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEIGONGBIND), info)
end
function custom_attack(attack_type, x, y, z, orient, hit_action)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ATTACK), nx_int(attack_type), nx_float(x), nx_float(y), nx_float(z), nx_float(orient), hit_action)
end
function custom_use_skill(skill_id, x, y, z, orient, dx, dy, dz, item_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) or not nx_is_valid(visual_player) then
    return
  end
  local sit_cross_skill = nx_execute("sitcross", "sitcross_configID")
  if nx_string(sit_cross_skill) == nx_string(skill_id) then
    local logic_state = client_player:QueryProp("LogicState")
    if nx_int(logic_state) == nx_int(LS_SITCROSS) then
      nx_execute("sitcross", "end_sitcross")
    elseif nx_int(logic_state) == nx_int(LS_NORMAL) or nx_int(logic_state) == nx_int(LS_WARNING) then
      if game_visual:HasRoleUserData(visual_player) then
        local state_index = game_visual:QueryRoleStateIndex(visual_player)
        if state_index == STATE_STATIC_INDEX then
          nx_execute("sitcross", "begin_sitcross")
        end
      else
        nx_execute("sitcross", "begin_sitcross")
      end
    end
  else
    if item_id == nil then
      item_id = ""
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_SKILL), nx_string(skill_id), nx_float(x), nx_float(y), nx_float(z), nx_float(orient), nx_float(dx), nx_float(dy), nx_float(dz), nx_string(item_id))
  end
end
function custom_use_next_skill(skill_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_NEXT_SKILL), nx_string(skill_id))
end
function custom_use_qinggong(qinggong_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_QINGGONG), nx_string(qinggong_id))
end
function custom_use_zhenfa(zhenfa_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_ZHENFA), nx_string(zhenfa_id))
end
function custom_end_zhenfa(zhenfa_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_ZHENFA))
end
function custom_set_zhenyan(target)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_ZHENYAN), nx_object(target))
end
function custom_resume_skill(x, y, z, orient, ntype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RESUME_SKILL), nx_float(x), nx_float(y), nx_float(z), nx_float(orient), ntype)
end
function custom_use_item(src_viewid, src_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USEITEM), nx_int(src_viewid), nx_int(src_pos))
end
function custom_use_item_on_item(src_viewid, src_pos, dst_viewid, dst_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USEITEM_ON_ITEM), nx_int(src_viewid), nx_int(src_pos), nx_int(dst_viewid), nx_int(dst_pos))
end
function custom_delete_item(src_viewid, src_pos, amount)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DELETEITEM), nx_int(src_viewid), nx_int(src_pos), nx_int(amount))
end
function custom_arrange_item(src_viewid, beginindex, endindex)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARANGEITEM), nx_int(src_viewid), nx_int(beginindex), nx_int(endindex))
end
function custom_condition_details(exchange_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_CONDITION_SHOP), nx_int(exchange_index))
end
function custom_buy_item(shopid, page, pos, amount)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BUY_FROM_SHOP), nx_string(shopid), nx_int(page), nx_int(pos), nx_int(amount))
end
function custom_sell_item(srcview_ident, srcviewindex, amount, shopid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SELL_TO_SHOP), nx_int(srcview_ident), nx_int(srcviewindex), nx_int(amount), nx_string(shopid))
end
function custom_open_mount_shop(opt)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_MOUNT_SHOP), nx_int(opt))
end
function custom_set_shortcut(index, param1, param2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SETSHORTCUT), nx_int(index), param1, param2)
end
function custom_remove_shortcut(row)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REMOVESHORTCUT), nx_int(row))
end
function custom_add_relation(submsg, name, relation_new, relation_old)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RELATION), nx_int(submsg), nx_widestr(name), nx_int(relation_new), nx_int(relation_old))
end
function custom_add_friend(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ADD_FRIEND), nx_widestr(name))
end
function custom_del_friend(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
end
function custom_add_blacklist(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ADD_BLACKLIST), nx_widestr(name))
end
function custom_del_blacklist(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DEL_BLACKLIST), nx_widestr(name))
end
function custom_moveto_blacklist(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOVE_TO_BLACKLIST), nx_widestr(name))
end
function custom_show_npc_friend()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHOW_NPC_FRIEND))
end
function custom_kickout_team(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_KICKOUT), nx_widestr(name))
end
function custom_leave_team()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_LEAVE))
end
function custom_caption_change(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_CHANGE_CAPTAIN), nx_widestr(name))
end
function custom_team_destroy()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_DESTROY))
end
function custom_team_request_join(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_REQUEST_JOIN), nx_widestr(name))
end
function custom_team_invite(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_INVITE), nx_widestr(name))
end
function custom_change_team_type(team_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_TYPE_SET), nx_int(team_type))
end
function custom_team_member_set(set_type, set_param, target_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_MEMBER_SET), nx_int(set_type), nx_int(set_param), nx_widestr(target_name))
end
function custom_team_sign_set(sign_str)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_SET_SIGN), nx_string(sign_str))
end
function custom_team_create()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_CREATE))
end
function custom_team_info_refresh()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_REFRESH_INFO))
end
function custom_team_recruit_info_get(team_id, team_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_INFO_GET), nx_int(team_id), nx_widestr(team_name))
end
function custom_team_add_info(info_type, info_mission, info_content)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_ADD_INFO), nx_widestr(info_type), nx_widestr(info_mission), nx_widestr(info_content))
end
function custom_team_remove_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_REMOVE_INFO))
end
function custom_team_player_open()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_PLAYER_OPEN))
end
function custom_team_player_close()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_PLAYER_CLOSE))
end
function custom_set_team_allot_quality(quality)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_SET_PICK_QUALITY), nx_int(quality))
end
function custom_set_team_allot_mode(mode)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_SET_PICK_MODE), nx_int(mode))
end
function custom_request_festival_sign_info(submsg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FESTIVAL_SIGN), nx_int(submsg))
end
function custom_request_festival_sign_acctask(submsg, task_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FESTIVAL_SIGN), nx_int(submsg), nx_int(task_id))
end
function custom_request_festival_sign_get_big(submsg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FESTIVAL_SIGN), nx_int(submsg))
end
function custom_request_festival_sign_card_get(submsg, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FESTIVAL_SIGN), nx_int(submsg), nx_int(index))
end
function custom_giveup_task(taskid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(giveup_task), nx_int(taskid))
end
function send_task_msg(cmd, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(cmd), unpack(arg))
end
function custom_refresh_npc_effect(npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REFRESH_TASK_NPC_EFFECT), nx_int(refresh_npc_effect), nx_object(npc))
end
function custom_delete_plot(plot_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DELETE_PLOT), nx_int(plot_id))
end
function custom_refresh_adventure()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REFRESH_ADVENTURE))
end
function custom_use_adventure_item()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_ADVENTURE_ITEM))
end
function custom_click_accept_btn(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLICK_ADVENTURE_ACCEPT), nx_int(index))
end
function custom_click_defuse_btn(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLICK_ADVENTURE_DEFUSE), nx_int(index))
end
function custom_share_adventur(taskid, friendname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHARE_ADVENTURE), nx_int(taskid), nx_widestr(friendname))
end
function custom_refresh_adventure_share_msg()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REFRESH_ADVENTURE_SHAREMSG))
end
function custom_refresh_adventure_share_result(taskid, friendname, result)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DO_SHARE_RESULT), nx_int(taskid), nx_widestr(friendname), nx_int(result))
end
function custom_defuse_share_adventure(row)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GIVEUP_SHARE_ADV), nx_int(row))
end
function custom_auto_show_prize_box(flag)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AUTO_PRIZE_BOX), nx_int(flag))
end
function custom_publish_collect_task(title, collect_info, golden, silver, time_limit)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PUBLISH_COLLECT_TASK), nx_widestr(title), nx_string(collect_info), nx_int(golden), nx_int(silver), nx_int(time_limit))
end
function custom_open_publish_form()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_PUBLISH_FORM))
end
function custom_open_query_edit_task()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_QUERY_EDIT_FORM))
end
function custom_query_type_task(type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QUERY_TYPE_TASK), nx_int(type))
end
function custom_task_prev_next_page(prev_next, type, taskid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QUERY_PREV_NEXT_PAGE), nx_string(prev_next), nx_int(type), nx_int(taskid))
end
function custom_query_select_edittask_info(taskid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QUERY_SELECT_TASK_INFO), nx_int(taskid))
end
function custom_accept_edit_task(taskid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACCEPT_EDIT_TASK), nx_int(taskid))
end
function custom_open_edit_task_accepted()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_EDIT_FORM_ACCEPTED))
end
function custom_open_depot()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_DIRECTDEPOT))
end
function custom_request(request_type, targetname, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST), nx_int(request_type), targetname, unpack(arg))
end
function custom_request_answer(requesttype, targetname, accept)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ANSWER), nx_int(requesttype), targetname, nx_int(accept))
end
function custom_exchange_ok()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXCHANGE_OK))
end
function custom_exchange_lock()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXCHANGE_LOCK))
end
function custom_exchange_cancel()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local test = CLIENT_CUSTOMMSG_EXCHANGE_CANCEL
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXCHANGE_CANCEL), 1)
end
function custom_exchange_setmoney(moneytype, money)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXCHANGE_MONEY), moneytype, money)
end
function custom_exchange_add_item(src_viewid, src_pos, src_amount, dest_viewid, dest_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXCHANGE_ADD_ITEM), nx_int(src_viewid), nx_int(src_pos), nx_int(dest_viewid), nx_int(dest_pos))
end
function custom_exchange_remove_item(src_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXCHANGE_REMOVE_ITEM), nx_int(src_pos))
end
function custom_request_stall()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_STALL))
end
function custom_stall_open_stall(shopname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_STALL), shopname)
end
function custom_stall_begin_stall(name, style, puff)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_STALL), nx_widestr(name), nx_int(style), nx_widestr(puff))
end
function custom_stall_add_item(src_view, src_pos, dst_pos, gold, silver)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(src_view), nx_int(CLIENT_CUSTOMMSG_ADD_STALL_ITEM), nx_int(src_pos), nx_int(dst_pos), nx_int(gold), nx_int(silver))
end
function custom_stall_remove_item(src_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REMOVE_STALL_ITEM), nx_int(src_pos))
end
function custom_stall_stop_stall()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLOSE_STALL))
end
function custom_stall_set_itemprice(pos, gold, silver)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_STALL_ITEMPRICE), nx_int(pos), nx_int(gold), nx_int(silver))
end
function custom_stall_buy_from_stall(master_name, uniqueid, count, price)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_BUY_OTHERONE_STALL), nx_widestr(master_name), nx_string(uniqueid), nx_int(count), nx_int64(price))
end
function custom_stall_return_ready()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_CLOSE_STALL))
end
function custom_open_lookup_stall(playername)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_LOOKUP_STALL), nx_widestr(playername))
end
function custom_close_lookup_stall()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLOSE_LOOKUP_STALL))
end
function custom_set_purchase_item(pos, config, count, gold, silver)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_PURCHASE_ITEM), nx_int(pos), nx_string(config), nx_int(count), nx_int64(gold), nx_int64(silver))
end
function custom_del_purchase_item(pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DEL_PURCHASE_ITEM), nx_int(pos))
end
function custom_sell_purchase_item(stallpos, toolpos, config, count, gold, silver)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SEL_PURCHASE_ITEM), nx_int(stallpos), nx_int(toolpos), nx_string(config), nx_int(count), nx_int64(gold), nx_int64(silver))
end
function custom_sell_purchase_item_select(stallpos, sellnum)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SEL_PURCHASE_ITEM_SELECT), nx_int(stallpos), nx_int(sellnum))
end
function custom_open_mail_box(boxtype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_OPENBOX), nx_int(boxtype))
end
function custom_send_letter(targetname, lettername, content, gold, silver, trademoney)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_SEND), nx_widestr(targetname), nx_widestr(lettername), nx_widestr(content), nx_string(gold), nx_string(silver), nx_string(trademoney))
end
function custom_read_letter(serialno)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_READ), nx_string(serialno))
end
function custom_cancel_send_letter()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_CANCEL))
end
function custom_select_letter(ntype, param1, param2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_SELECT), ntype, param1, param2)
end
function custom_select_send_letter(param1, param2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_SELECT_SEND), nx_int(param1), nx_int(param2))
end
function custom_close_mail_readbox()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_CLOSE_READBOX))
end
function custom_get_appendix(serialno)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_GET_APPEDIX), nx_string(serialno))
end
function custom_del_letter(del_type, serial_no)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_DEl), del_type, serial_no)
end
function custom_del_send_letter()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_DEl_SEND))
end
function custom_del_letter_ok(del_type, serial_no)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_DEl_OK), del_type, serial_no)
end
function custom_save_money_to_bank(capitialtype, value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SAVECAPITAL), nx_int(capitialtype), nx_int(value))
end
function custom_get_money_from_bank(capitialtype, value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_UNSAVECAPITAL), nx_int(capitialtype), nx_int(value))
end
function custom_add_point(str, dex, ing, spi, sta)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BASEPROP_ADDPOINT), "Str", str, "Dex", dex, "Ing", ing, "Spi", spi, "Sta", sta)
end
function custom_dec_point(str, dex, ing, spi, sta)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BASEPROP_DECPOINT), "Str", str, "Dex", dex, "Ing", ing, "Spi", spi, "Sta", sta)
end
function custom_relive_check()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RELIVE_CHECK))
end
function custom_relive(relive_type, check, value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if check == nil then
    check = nx_int(0)
  end
  if value == nil then
    value = ""
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RELIVE), nx_int(relive_type), check, value)
end
function custom_set_pkmode(pkmode)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SETPKMODE), pkmode)
end
function custom_set_pkprotect(pkprotect, checked)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SETPKPROTECT), pkprotect, checked)
end
function custom_change_warning()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local state_index = game_visual:QueryRoleStateIndex(visual_player)
  if state_index ~= STATE_STATIC_INDEX and state_index ~= STATE_MOTION_INDEX then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHANGEWARNING))
end
function custom_queryteachprenlist(flag, pagetype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QUERYTEACHPRNELIST), nx_int(flag), nx_int(pagetype))
end
function custom_request_teacher(request_type, targetname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST), nx_int(request_type), nx_widestr(targetname))
end
function custom_send_teacher_commend(sex)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GETLISTBYCONDITION), nx_int(sex))
end
function custom_get_prentice_income(targetname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GETPRENTICE_INCOME), nx_widestr(targetname))
end
function custom_protocolfreerelation(request_type, targetname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST), nx_int(request_type), nx_widestr(targetname))
end
function custom_singlefreeteachpren(targetname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SINGLEFREETEACHPRNRELATION), 1, nx_widestr(targetname))
end
function custom_judge_teach_result(restype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JUDGETEACH_RESULT), restype)
end
function custom_pick_crop(view_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PICK_CROP), nx_int(view_index))
end
function custom_pick_all_crop()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PICK_ALL_CROP))
end
function custom_pick_crop_close()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PICK_CROP_CLOSE))
end
function custom_pickup_all_item()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PICKUP_ALL_ITEMS))
end
function custom_pickup_single_item(vpos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PICKUP_DROPITEM), nx_int(vpos))
end
function custom_close_drop_box()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLOSE_DROPBOX))
end
function custom_roll_item_result(item, dice_mode)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROLL_ITEM_RESULT), nx_object(item), nx_int(dice_mode))
end
function custom_teamleader_alloc_item(pos, gainer, mode)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAMLEADER_ALLOC_ITEM), nx_int(pos), nx_widestr(gainer), nx_int(mode))
end
function custom_pickup_cloneitem(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PICKUP_CLONEITEM), nx_int(index))
end
function custom_request_marriage(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_MARRIAGE), nx_widestr(name))
end
function custom_request_lover_free(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_LOVER_FREE), nx_widestr(name))
end
function custom_start_trustee(ntype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_START_TRUSTEE), nx_int(ntype))
end
function custom_stop_trustee()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_STOP_TRUSTEE))
end
function custom_set_trustee(ntype, value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_TRUSTEE), nx_int(ntype), nx_int(value))
end
function custom_neishangcure()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEISHANGCURE))
end
function custom_use_neigong(neigong_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_NEIGONG), neigong_id)
end
function custom_launch_neigong()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LAUNCH_NEIGONG))
end
function custom_upgrade_xinfa(xinfa_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_UPGRADE_XINFA), xinfa_id)
end
function custom_wear_jinfa(opt_type, neigong_id, jinfa_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WEAR_JINFA), nx_int(opt_type), nx_string(neigong_id), nx_string(jinfa_id))
end
function custom_change_move_type(type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOVE_TYPE), nx_int(type))
end
function custom_change_ride_swim_speed(type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHANGE_RIDE_SWIM_SPEED), nx_int(type))
end
function custom_clear_trustee_log()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLEAR_TRUSTEE_LOG))
end
function custom_request_action(action)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ACTION), nx_string(action))
end
function custom_over_mutual_action()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SUB_CLIENT_MUTUAL_END = 2
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MUTUAL_ACTION), nx_int(SUB_CLIENT_MUTUAL_END))
end
function custom_sitcross(para)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SITCROSS), nx_int(para))
end
function custom_dance()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DANCING))
end
function custom_ride(para)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RIDE), nx_int(para))
end
function custom_tiguanchallenge(...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUANCHALLENGE), unpack(arg))
  end
end
function custom_ride_spurt(para)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RIDE_SPURT), nx_int(para))
end
function custom_select_mount(para)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHOSE_MOUNT), nx_int(para))
end
function custom_select(client_ident)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local last_client_ident = nx_value("select_object")
  local cur_time = nx_function("ext_get_tickcount")
  if last_client_ident ~= nil and last_client_ident == client_ident and nx_find_custom(game_visual, "last_select_time") then
    local sub_time = cur_time - game_visual.last_select_time
    if 10 < sub_time and sub_time < 1000 then
      return 0
    end
  end
  game_visual.last_select_time = cur_time
  game_visual:Select(client_ident, 0)
  nx_set_value("select_object", client_ident)
  local joystick_mode = nx_execute("control_set", "is_joystick_fight_operate_mode")
  if not joystick_mode then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AUTO_SELECT), nx_object(client_ident))
  end
end
function custom_select_cancel()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SELECT_CANCEL))
  nx_set_value("select_object", nx_null())
  local fight = nx_value("fight")
  if nx_is_valid(fight) then
    fight:ClearLockTarget()
  end
  local joystick_mode = nx_execute("control_set", "is_joystick_fight_operate_mode")
  if not joystick_mode then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AUTO_SELECT), nx_object("0-0"))
  end
end
function custom_auto_select(client_ident)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AUTO_SELECT), nx_object(client_ident))
end
function custom_accept_task(func_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(accept_task), nx_int(func_id))
end
function custom_complete_task(taskid, present_id, npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_string("complete_task"), nx_int(taskid), nx_int(present_id), nx_object(npc))
end
function custom_return_share_task_result(task_id, sharer_name, result)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_string("share_res"), nx_int(task_id), nx_widestr(sharer_name), nx_int(result))
end
function custom_share_task(task_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(share_task), nx_int(task_id))
end
function custom_accept_share_task()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(accept_share_task))
end
function custom_active_qinggong(qinggong_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QG_SKILL), qinggong_id)
end
function custom_chat_look_item(playername, uniqueid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LOOK_ITEM), playername, uniqueid)
end
function custom_request_bus_finish()
  local game_visual = nx_value("game_visual")
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_BUSINESS_FINISH))
end
function custom_showequip_type(type)
  local game_visual = nx_value("game_visual")
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHOWEQUIP_TYPE), nx_int(type))
end
function custom_specialitem_request(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SPECIAL_ITEM_QUERY), nx_string(index))
end
function custom_giveup_edittask(taskid, title)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GIVEUP_EDIT_TASK), nx_int(taskid), nx_widestr(title))
end
function custom_submit_edittask(taskid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SUBMIT_EDIT_TASK), nx_int(taskid))
end
function custom_show_submit_collect_box(flag)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHOW_SUBMIT_BOX), nx_int(flag))
end
function custom_submit_collect_edit_task(task_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SUBMIT_COLLECT_EDITTASK), nx_int(task_id))
end
function custom_create_world_trans_tool(sub_msg, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CREATE_WORLD_TRANS_TOOL), nx_int(sub_msg), nx_string(to))
end
function custom_send_compose(formula_name, count, share_type, compose_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_COMPOSITE), formula_name, count, share_type, compose_type)
end
function custom_send_fuse(formula_name, count, share_type, bind_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FUSE), formula_name, count, share_type, bind_type)
end
function custom_send_skillpage_fuse(formula_name, count, share_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SKILLPAGE_FUSE), formula_name, count, share_type)
end
function custom_cancel_fuse()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CANCEL_FUSE))
end
function custom_home(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HOME), unpack(arg))
end
function custom_home_furn(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), unpack(arg))
end
function custom_send_origin_limit(origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QUERY_ORIGIN_LIMIT), origin_id)
end
function custom_send_get_origin_prize(origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ORIGIN_PRIZE), origin_id)
end
function custom_send_abandon_origin(origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ABANDON_ORIGIN), origin_id)
end
function custom_send_offline_addrequest(off_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_ADD_ACT), nx_string(off_id))
end
function custom_send_offline_delrequest(del_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_DEL_ACT), nx_int(del_index))
end
function custom_send_offline_setact_request(offlinetype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_SET_ACT), nx_int(offlinetype))
end
function custom_send_start_offline()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_START_OFFLIN))
end
function custom_get_tourprize(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JH_EXPLORE), unpack(arg))
end
function custom_send_end_offline()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_OFFLIN))
end
function custom_send_show_origin_type(show_origin_id, origin_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_SHOW_ORIGIN), nx_string(show_origin_id), nx_int(origin_type))
end
function custom_send_can_get_side_origin(origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CANGET_SIDE_ORIGIN), nx_string(origin_id))
end
function custom_send_get_origin(origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ORIGIN), nx_string(origin_id))
end
function custom_get_offline_prize(act_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_GET_PRIZE), nx_string(act_id))
end
function custom_giveup_offline_prize(act_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_GIVEUP_PRIZE), nx_string(act_id))
end
function custom_offline_setfree(type)
  local name = ""
  if nx_number(type) == nx_number(1) then
    local target = nx_value("game_select_obj")
    if not nx_is_valid(target) then
      return 0
    end
    if not target:FindProp("Name") then
      return 0
    end
    name = target:QueryProp("Name")
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_SET_FREE), nx_int(type), nx_widestr(name))
end
function custom_repare_fortunetelling()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PREPARE_FORTUNETELLING))
end
function custom_begin_fortunetelling(name, style, puff, price_sprite, price_person, price_god)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_FORTUNETELLING), nx_widestr(name), nx_int(style), nx_widestr(puff), nx_int(price_sprite), nx_int(price_person), nx_int(price_god))
end
function custom_canopen_fortunetelling()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CANOPEN_FORTUNETELLING))
end
function custom_stop_fortunetelling()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_FORTUNETELLING))
end
function custom_request_fortunetelling(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_FORTUNETELLING), nx_widestr(name))
end
function custom_begin_fishing(flag)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_FISHING), nx_int(flag))
end
function custom_op_fishing()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OP_FISHING))
end
function custom_send_beg(para)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEG), nx_string(para))
end
function custom_send_fortunetellingother(para)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PREPARE_FORTUNETELLINGOTHER), nx_string(para))
end
function custom_send_begplayer(target_obj, rank)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGPLAYER), nx_object(target_obj), nx_int(rank))
end
function custom_send_suangua()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SUANGUA))
end
function custom_send_chaolu(viewid, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_COPY), nx_int(viewid), index)
end
function custom_send_annotate(viewid, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_ANNOTATE), nx_int(viewid), index)
end
function custom_send_qianghua(view_id, index, jobid, itemreduce)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_QIANGHUA), nx_int(view_id), nx_int(index), nx_string(jobid), nx_string(itemreduce))
end
function custom_before_movie_end(movie_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEFORE_END_MOVIE), nx_int(movie_id))
end
function custom_movie_end(movie_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_MOVIE), nx_int(movie_id))
end
function custom_agree_movie()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AGREE_MOVIE))
end
function custom_help_step_complete(nextStepID)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_COMPLETE_FRESHMAN_HELP_STEP), nx_int(0), nx_string(nextStepID))
end
function custom_movie_start(npc, movie_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_START_MOVIE), nx_object(npc), nx_int(movie_id))
end
function custom_end_freshman_help()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_FRESHMAN_HELP))
end
function custom_send_repair_addbags(viewid, index, bDecMoney)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REPAIR_ADDBAG), nx_int(viewid), nx_int(index), nx_int(bDecMoney))
end
function custom_send_repair_item(viewid, index, bDecMoney, serviceman, silvertype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  serviceman = serviceman or 0
  silvertype = silvertype or 0
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REPAIRITEM), nx_int(viewid), nx_int(index), nx_int(bDecMoney), nx_int(serviceman), nx_int(silvertype))
end
function custom_send_repair_all(bDecMoney, serviceman, silvertype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  serviceman = serviceman or 0
  silvertype = silvertype or 0
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REPAIRALL), nx_int(bDecMoney), nx_int(serviceman), nx_int(silvertype))
end
function custom_send_open_capital(bOpen)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CAPITAL_GIRD), nx_int(bOpen))
end
function custom_send_start_forge()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_START_FORGE))
end
function custom_send_end_forge()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_FORGE))
end
function custom_send_test_forge_hit(color)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEST_FORGE_STEP_HIT), nx_int(color))
end
function custom_send_cancel_step(color)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CANCEL_STEP), nx_int(color))
end
function custom_send_rescue_request()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RESCUE_REQUEST))
end
function custom_send_rescue_cancel()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RESCUE_CANCEL))
end
function custom_send_rescue_deal(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RESCUE_DEAL), nx_widestr(name))
end
function custom_send_get_base_info(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_BASE_INFO), nx_widestr(name))
end
function custom_send_get_equip_info(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_EQUIP_INFO), nx_widestr(name))
end
function custom_send_get_binglu_info(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_BINGLU_INFO), nx_widestr(name))
end
function custom_send_get_player_game_info(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  if nx_ws_length(player_name) == 0 then
    local text = util_format_string("2501")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_GAME_INFO), nx_widestr(player_name))
  return true
end
function custom_send_fight_ent_ani_end(ani_name, npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FIGHT_ENT_ANI_END), nx_object(npc), nx_string(ani_name))
end
function custom_send_faculty_msg(sub_id, arg1, arg2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FACULTY_INFO), nx_int(sub_id), arg1, arg2)
end
function custom_team_faculty(sub_command, arg1)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEAM_FACULTY), nx_int(sub_command), arg1)
end
function custom_pickup_money_item(vpos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_DROP_MONEY_ITEM), nx_int(vpos))
end
function custom_send_input_compositebox(src_index, dst_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_COMPOSITEBOX_ADDITEM), nx_int(src_index), nx_int(dst_index))
end
function custom_send_del_item_compositebox(dst_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_COMPOSITEBOX_REMOVEITEM), nx_int(dst_index))
end
function custom_send_open_compositebox(job_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_COMPOSITEBOX), nx_string(job_id))
end
function custom_send_close_compositebox(src_index, dst_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLOSE_COMPOSITEBOX))
end
function custom_send_composite_auto_put(formula)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_COMPOSITEBOX_AUTO_PUT), nx_string(formula))
end
function custom_scenario_black()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCENARIO_BLACK))
end
function custom_remove_buffer(buffer_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REMOVE_BUFFER), nx_string(buffer_id))
end
function update_task_trace_state(task_list)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(update_trace), nx_string(task_list))
end
function update_log_read(get_date)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_UPDATE_LOG_READ), nx_string(get_date))
end
function reset_all_clone()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RESET_ALL_CLONE))
end
function custom_random_clone(sub_type, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RANDOM_CLONE_SCENE), nx_int(sub_type), unpack(arg))
end
function reset_save_clone(cloneConfig, level)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RESET_SAVE_CLONE), nx_string(cloneConfig), nx_int(level))
end
function captain_reset_save_clone(cloneConfig, level)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CAPTAIN_RESET_SAVE_CLONE), nx_string(cloneConfig), nx_int(level))
end
function get_leave_time_clone()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_LEAVE_TIME_CLONE))
end
function custom_on_npc_ready(npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(custom_on_npc_ready), nx_object(npc))
end
function custom_on_player_ready(player)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LOOK_PLAYER), nx_object(player))
end
function custom_send_link_to_float_area(npc, offset_x, offset_y, offset_z, offset_orient)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LINK_TO_FLOAT), nx_object(npc), offset_x, offset_y, offset_z, offset_orient)
end
function custom_send_link_move(offset_x, offset_y, offset_z, offset_orient)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LINK_MOVE), offset_x, offset_y, offset_z, offset_orient)
end
function custom_send_unlink_from_float_area(dest_x, dest_y, dest_z, dest_orient)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_UNLINK_FROM_FLOAT), dest_x, dest_y, dest_z, dest_orient)
end
function custom_send_syn_npc_pos(npc, x, y, z)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SYN_NPC_POS), nx_object(npc), x, y, z)
end
function custom_request_join_guild(guild_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_JOIN_GUILD), guild_name)
end
function custom_request_guild_candidate(from, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_CANDIDATE), nx_int(from), nx_int(to))
end
function custom_request_accept_guild_member(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_ACCEPT_GUILD_MEMBER), player_name)
end
function custom_request_reject_guild_member(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_REJECT_GUILD_MEMBER), player_name)
end
function custom_request_guild_member(from, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_MEMBER), nx_int(from), nx_int(to))
end
function custom_request_guild_online_member(from, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_ONLINE_MEMBER), nx_int(from), nx_int(to))
end
function custom_request_get_notice()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_NOTICE))
end
function custom_request_set_notice(notice)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_SET_NOTICE), notice)
end
function custom_request_guild_invite(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_INVITE), player_name)
end
function custom_request_guild_invite_confirm(from_player, result)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_INVITE_CONFIRM), from_player, result)
end
function custom_request_guild_donate(num)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_DONATE), num)
end
function custom_request_guild_authority()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_POSTION_AUTHORITY))
end
function custom_request_guild_set_authority(pos_lv, chat, accept, appoint, fire, notice, purpose, storage, choose_point, delete_point, use_capital, receive_custom_clothes, can_dkp, can_guild_war)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_SET_AUTHORITY), nx_int(pos_lv), nx_int(chat), nx_int(accept), nx_int(appoint), nx_int(fire), nx_int(notice), nx_int(purpose), nx_int(storage), nx_int(choose_point), nx_int(delete_point), nx_int(use_capital), nx_int(receive_custom_clothes), nx_int(can_dkp), nx_int(can_guild_war))
end
function custom_request_guild_disband_list(guild_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_TICKET_PLAYERS), guild_name)
end
function custom_request_guild_set_suggest(school, ability, without_school, without_newschool)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_SET_JOIN_SUGGEST), nx_string(school), nx_int(ability), nx_int(without_school), nx_int(without_newschool))
end
function custom_request_join_suggest(guild_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_JOIN_SUGGEST), guild_name)
end
function custom_request_guild_set_postion_name(pos_lv, pos_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_SET_POSITION_NAME), nx_int(pos_lv), nx_widestr(pos_name))
end
function custom_request_guild_add_position(pos_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_ADD_POSITION), nx_widestr(pos_name))
end
function custom_request_guild_set_position_level(pos_lv, delta)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_SET_POS_LV), nx_int(pos_lv), nx_int(delta))
end
function custom_request_quit_guild()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_QUIT_GUILD))
end
function custom_request_guild_event(from, to, eventtype, sub_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_EVENT), nx_int(from), nx_int(to), nx_int(eventtype), nx_int(sub_type))
end
function custom_request_old_guild_event(from, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_HISTORY_EVENT), nx_int(from), nx_int(to))
end
function custom_request_set_guild_purpose(purpose)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_SET_PURPOSE), nx_widestr(purpose))
end
function custom_request_guild_pos_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_POS_LIST))
end
function custom_request_change_position(player, pos_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_CHANGE_POSITION), nx_widestr(player), nx_widestr(pos_name))
end
function custom_request_disband_guild()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DISBAND_GUILD))
end
function custom_request_disband_vote(is_agree)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_VOTE_RESULT), nx_int(is_agree))
end
function custom_request_respond_guild(is_support, guild_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_RESPOND_GUILD), is_support, guild_name)
end
function custom_request_neigong_pk(target)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_COUSOMMSG_REQUEST_NEIG_PK), target)
end
function custom_neigong_pk_chipin(target)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_CHIP_IN))
end
function custom_join__neigong_pk(target)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JOIN_NEIG_PK), target)
end
function custom_begin_impart(value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_IMPART_BEGIN), value)
end
function custom_cancel_impart()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_IMPART_CANCEL))
end
function custom_set_title(titleID)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SETTITLE), titleID)
end
function custom_update_chellenge_rank_by_page(page)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_CHALLENGE_RANK_BY_PAGE), nx_int(page))
end
function custom_update_chellenge_rank_by_name(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_CHALLENGE_RANK_BY_NAME), nx_widestr(name))
end
function custom_update_chellenge_target_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_CHALLENGE_TARGET_LIST))
end
function custom_chellenge_set_nickname(nickname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHALLENGE_SET_NICKNAME), nickname)
end
function custom_school_war_register(is_defense)
  local CLIENT_CUSTOMMSG_SCHOOL_WAR = 1015
  local SUB_CUSTOMMSG_REGISTER = 0
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_WAR), nx_int(SUB_CUSTOMMSG_REGISTER), nx_int(is_defense))
end
function custom_schoolwar_accept_invite()
  local CLIENT_CUSTOMMSG_SCHOOL_WAR = 1015
  local SUB_CUSTOMMSG_CONFIRM_INVITE = 1
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_WAR), nx_int(SUB_CUSTOMMSG_CONFIRM_INVITE))
end
function custom_get_player_position(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_PLAYER_POSITION), nx_widestr(name))
end
function custom_add_life_share(formula_name, jobname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_COMPOSITE_ADD), nx_string(formula_name), nx_string(jobname))
end
function custom_del_life_share(jobname, row)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_COMPOSITE_DEL), nx_string(jobname), nx_int(row))
end
function custom_set_life_compose_share(jobname, prize)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_COMPOSITE_MODIFY), nx_string(jobname), nx_string(prize))
end
function custom_set_life_skill_share(jobname, prize)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_SKILL_MODIFY), nx_string(jobname), nx_string(prize))
end
function custom_clear_life_share(jobname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_COMPOSITE_CLEAR), nx_string(jobname))
end
function custom_start_life_trade()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_LIFE_SHARE_START))
end
function custom_stop_life_trade()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_LIFE_SHARE_STOP))
end
function custom_life_qis_equip_zhanshu(zhanshuid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_QIS_EQUIP_ZHANSHU), nx_string(zhanshuid))
end
function custom_life_qis_clear_equip_zhanshu()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_QIS_CLEAR_EQUIP_ZHANSHU))
end
function custom_life_request_look(name, jobid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_REQUEST_LOOK), nx_widestr(name), nx_string(jobid))
end
function custom_stall_note(player_name, note)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_STALL_NOTE), nx_int(1), nx_widestr(player_name), nx_widestr(note))
end
function custom_buy_guild_domain(msgid, rowNum, pageNum, maxRow)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDDOMAIN_OPER), nx_int(msgid), nx_int(rowNum))
end
function custom_guild_domain_page_up_down(msgid, pageNum)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDDOMAIN_OPER), nx_int(msgid), nx_int(pageNum))
end
function custom_expendmountstore(itemname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXPEND_MOUNTSTORE))
end
function custom_set_stall_style(style)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_STALL_STYLE), nx_int(style))
end
function custom_get_tiguan_one_info(object, cg_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_ONE_INFO), nx_object(object), nx_int(cg_id))
end
function custom_get_tiguan_all_info(object)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_ALL_INFO), nx_object(object))
end
function custom_get_tiguan_team_state()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_TEAM_STATE))
end
function custom_tiguan_random_npc(is_stop)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_RANDOM_NPC), nx_int(is_stop))
end
function custom_tiguan_request_leave()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_LEAVE))
end
function custom_battlefield(sub_type, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BATTLEFIELD), nx_int(sub_type), unpack(arg))
end
function custom_put_item_from_guilddepot_to_toolbox(src_view_id, src_view_index, src_amount, dest_view_id, dest_view_index, depot_npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_DEPOT_PUT_OUT_ITEM), nx_int(src_view_id), nx_int(src_view_index), nx_int(src_amount), nx_int(dest_view_id), nx_int(dest_view_index), depot_npc)
end
function custom_contribute_money(capital, depot_npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_DEPOT_CONTRIBUTE_MONEY), nx_int(capital), depot_npc)
end
function custom_contribute_goods(npcid, config, num, num_replace)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_UPDATE_CONTRIBUTE), npcid, config, num, num_replace)
end
function custom_upgrade_faster(npcid, num)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_UPDATE_ACCELERATE), npcid, num)
end
function custom_put_item_from_toolbox_to_guilddepot(src_view_id, src_view_index, src_amount, dest_view_id, dest_view_index, depot_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_DEPOT_PUT_IN_ITEM), nx_int(src_view_id), nx_int(src_view_index), nx_int(src_amount), nx_int(dest_view_id), nx_int(dest_view_index), depot_id)
end
function custom_guild_del_viewport(view_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_DEL_VIEWPORT), nx_int(view_id))
end
function custom_move_item_from_guilddepot_to_guilddepot(src_view_id, src_view_index, src_amount, dest_view_id, dest_view_index, depot_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_DEPOT_MOVE_ITEM), nx_int(src_view_id), nx_int(src_view_index), nx_int(src_amount), nx_int(dest_view_id), nx_int(dest_view_index), depot_id)
end
function custom_guildbuilding_employ_npc(npc, pos_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_EMPLOY_NPC), nx_object(npc), nx_int(pos_type))
end
function custom_query_employ_info(pos_type, npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_QUERY_EMPLOY_INFO), nx_int(pos_type), nx_object(npc))
end
function custom_guild_shanrang(to_player)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SUB_CUSTOMMSG_REQUEST_SHANRANG = 28
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_SHANRANG), nx_widestr(to_player))
end
function custom_guild_func_jiguan(id, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_FUNC_OPER), id, arg[1], arg[2])
end
function custom_guild_viewport_jiguan(subtype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_FUNC_OPER), nx_int(subtype))
end
function custom_guild_kickout(kick_player)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SUB_CUSTOMMSG_REQUEST_KICKOUT = 29
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_KICKOUT), nx_widestr(kick_player))
end
function custom_guild_invite_respond(player)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SUB_CUSTOMMSG_INVITE_RESPOND = 30
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_INVITE_RESPOND), nx_widestr(player))
end
function custom_guild_get_logo()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SUB_CUSTOMMSG_GET_LOGO = 31
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GET_LOGO))
end
function custom_guild_set_logo(logo)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SUB_CUSTOMMSG_SET_LOGO = 32
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_SET_LOGO), logo)
end
function custom_occupy_item_guild_war_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CLIENT_SUBMSG_REQUEST_GUILD_WAR_INFO = 6
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUEST_GUILD_WAR_INFO))
end
function custom_use_guild_war_occupy_item(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CLIENT_SUBMSG_USE_GUILD_WAR_OCCUPY_ITEM = 5
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_USE_GUILD_WAR_OCCUPY_ITEM), nx_int(arg[1]), nx_int(arg[2]), nx_int(arg[3]), nx_int(arg[4]))
end
function custom_end_xiulian()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_END_XIULIAN = 120
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_END_XIULIAN))
end
function custom_hold_faculty(sub_command, value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIVEPOINT_INFO), nx_int(sub_command), nx_int(value))
end
function custom_buy_faculty(sub_command, gold, faculty)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIVEPOINT_INFO), nx_int(sub_command), nx_int(gold), nx_int(faculty))
end
function custom_market_msg(sub_command, arg1, arg2, arg3, arg4)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MARKET), nx_int(sub_command), arg1, arg2, arg3, arg4)
end
function custom_guild_buybook(config_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_BUYBOOK = 121
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_BUYBOOK), nx_string(config_id))
end
function custom_give_item(optype, index, npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GIVE_ITEM_MSG_TYPE), nx_int(optype), nx_int(index), nx_string(npc))
end
function custom_split_item(viewid, uniqueid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SPLIT_ITEM), nx_int(viewid), nx_string(uniqueid))
end
function custom_cancel_split_item()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CANCEL_SPLIT_ITEM))
end
function custom_lifeskill_split_item(jobid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFESKILL_SPLITITEM), nx_string(jobid))
end
function custom_uninstall_skillitem()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLOSE_ITEMSKILL))
end
function custom_select_bind(bind_type, func_name, str_var)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SELECT_BIND), bind_type, func_name, str_var)
end
function custom_request_start_escort(npcname, pathid, carriagetype, rank)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_START_ESCORT), nx_string(npcname), nx_int(pathid), nx_int(carriagetype), nx_int(rank))
end
function custom_request_school_pose_fight(submsg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_POSE_FIGHT), submsg, unpack(arg))
end
function custom_get_escort_info(args)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ESCORT_INFO), args)
end
function custom_get_is_special_time(msgid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ISSPECIALTIME), nx_int(msgid))
end
function custom_request_fire_guild_info(from, to)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local sub_cmd = 0
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(sub_cmd), nx_int(from), nx_int(to))
end
function custom_request_fire_guild_task(guild_name, domain_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local sub_cmd = 1
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(sub_cmd), nx_widestr(guild_name), nx_int(domain_id))
end
function custom_request_fire_newstrike_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local GUILD_FIRE_TASK_SUB_CMD_NEW_FIRE_DATA = 26
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_TASK_SUB_CMD_NEW_FIRE_DATA))
end
function custom_respond_guild(guild_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SUB_CUSTOMMSG_REQUEST_RESPOND_GUILD = 27
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_RESPOND_GUILD), nx_int(0), nx_widestr(guild_name))
end
function custom_guild_invite_member(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SUB_CUSTOMMSG_REQUEST_GUILD_INVITE = 11
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_INVITE), nx_widestr(player_name))
end
function custom_request_basic_guild_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_BASIC_GUILD_INFO))
end
function custom_request_guild_intro_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_INTRO_INFO))
end
function custom_request_escort_control(obj, param)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ESCORT_MOVE_CONTROL), obj, param)
end
function custom_request_shop_exchange_form(viewid, bindindex, shopid, page, pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_SHOP_EXCHANGE_FORM), nx_int(viewid), nx_int(bindindex), nx_string(shopid), nx_int(page), nx_int(pos))
end
function custom_exchange_item(shopid, page, pos, amount)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXCHANGE_FROM_SHOP), nx_string(shopid), nx_int(page), nx_int(pos), nx_int(amount))
end
function custom_request_life_share(request_type, targetname, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LIFE_SHARE_REQUEST), nx_int(request_type), targetname, unpack(arg))
end
function custom_send_leitai_call_for_confirm(type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_CALL_FOR_CONFIRMED), nx_int(type))
end
function custom_send_leitai_wager_info(player_name, gamble_money, npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_LEITAI_WAGER = 5
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_LEITAI_WAGER), nx_widestr(player_name), nx_int(gamble_money), npc)
end
function custom_send_leitai_reward_info(item_index, integral_type, npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_REWARD_ITEM_INFO), nx_int(item_index), nx_int(integral_type), npc)
end
function custom_send_leitai_integral_num()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_REWARD_COUNT))
end
function custom_send_leitai_qiecuo_num()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_QIECUO_COUNT))
end
function custom_send_leitai_integral_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_INTEGRAL_INFO))
end
function custom_send_challenge_lose()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHALLENGE_LOSE))
end
function custom_send_leitai_info(args)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_REQUIRE_LEITAI_INFO = 8
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_REQUIRE_LEITAI_INFO), unpack(args))
end
function custom_send_leitai_apply(args)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_LEITAI_APPLY = 7
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_LEITAI_APPLY))
end
function custom_send_clone_challenge_rec(target)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLONE_CHALLENGE_COUNT), nx_object(target.Ident))
end
function custom_send_interact_msg(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_INTERACTIVE_MSG), nx_int(subtype), unpack(arg))
end
function custom_send_Request_Declare_Fight(schoolId)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL), nx_int(1), nx_int(schoolId))
end
function custom_send_bribe(sub_id, arg1)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BRIBE), nx_int(sub_id), nx_int(arg1))
end
function custom_sync_recent_feeds(sub_msg, feed_id, owner_name, text_desc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if nx_number(sub_msg) == 2 then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED), nx_int(sub_msg))
  elseif nx_number(sub_msg) == 3 then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED), nx_int(sub_msg), nx_widestr(owner_name), nx_string(feed_id), nx_widestr(text_desc))
  elseif nx_number(sub_msg) == 5 then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("ui_sns_up_money", nx_string(name))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED), nx_int(sub_msg), nx_string(feed_id))
    end
  elseif nx_number(sub_msg) == 6 then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("ui_sns_down_money", nx_string(name))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED), nx_int(sub_msg), nx_string(feed_id))
    end
  elseif nx_number(sub_msg) == 7 then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED), nx_int(sub_msg), nx_string(feed_id))
  elseif nx_number(sub_msg) == 8 then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED), nx_int(sub_msg), nx_string(feed_id))
  elseif nx_number(sub_msg) == 9 then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED), nx_int(sub_msg), nx_widestr(owner_name))
  end
end
function custom_sns_feed_back_goto(targetname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED_BACK), nx_int(1), nx_widestr(targetname))
end
function custom_sns_feed_back_broadcast(text)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED_BACK), nx_int(2), nx_widestr(text))
end
function custom_sns_shuoshuo(content)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FEED), nx_int(10), nx_widestr(content))
end
function custom_send_request_look_school_fight_info(req_type, sub_type, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if nx_int(req_type) == nx_int(0) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(1) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type), nx_int(arg[1]), nx_int(arg[2]))
  elseif nx_int(req_type) == nx_int(2) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type))
  elseif nx_int(req_type) == nx_int(3) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type), nx_int(arg[1]))
  elseif nx_int(req_type) == nx_int(4) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type), nx_int(arg[1]), nx_int(arg[2]), nx_int(arg[3]))
  elseif nx_int(req_type) == nx_int(5) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(6) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(7) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type), nx_int(arg[1]))
  elseif nx_int(req_type) == nx_int(8) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type))
  elseif nx_int(req_type) == nx_int(9) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(11) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type))
  elseif nx_int(req_type) == nx_int(12) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type), unpack(arg))
  elseif nx_int(req_type) == nx_int(13) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type), unpack(arg))
  elseif nx_int(req_type) == nx_int(14) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(15) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(16) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(21) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(22) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_widestr(sub_type))
  elseif nx_int(req_type) == nx_int(23) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type))
  elseif nx_int(req_type) == nx_int(24) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_int(sub_type), unpack(arg))
  elseif nx_int(req_type) == nx_int(25) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_widestr(sub_type), unpack(arg))
  elseif nx_int(req_type) == nx_int(26) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_FIGHT), nx_int(req_type), nx_widestr(sub_type))
  end
end
function custom_req_domain_build_info(domain_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local sub_cmd = 4
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(sub_cmd), nx_int(domain_id))
end
function custom_req_single_build_info(domain_id, main_type, sub_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local sub_cmd = 5
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(sub_cmd), nx_int(domain_id), nx_int(main_type), nx_int(sub_type))
end
function custom_req_self_domain_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local sub_cmd = 8
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(sub_cmd))
end
function custom_req_target_domain_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local sub_cmd = 9
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(sub_cmd))
end
function custom_req_potential_fire_players(domain_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local sub_cmd = 6
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(sub_cmd), nx_int(domain_id))
end
function custom_req_potential_water_players(domain_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local sub_cmd = 7
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(sub_cmd), nx_int(domain_id))
end
function custom_request_restart_ai(npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NPC_RESTART_AI), nx_object(npc))
end
function custom_active_parry(subtype, arg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVE_PARRY), nx_int(subtype), nx_int(arg))
end
function custom_send_gmcc_msg(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GMCC_MSG), nx_int(subtype), unpack(arg))
end
function custom_send_new_neigong_pk_msg(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_NEIGPK), nx_int(subtype), unpack(arg))
end
function custom_send_ride_skill(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_RIDE_SKILL), unpack(arg))
end
function custom_send_msgbox_results_msg(subtype, res, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ANSWERMESSAGEBOX), nx_int(subtype), nx_int(res), unpack(arg))
end
function custom_send_inputbox_results_msg(subtype, data)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ANSWERINPUTBOX), nx_int(subtype), nx_widestr(data))
end
function custom_get_school_msg_info(schoolid, page)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL), nx_int(2), nx_int(schoolid), nx_int(page))
end
function custom_return_school_home_point()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL), nx_int(3))
end
function custom_get_school_vote_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL), nx_int(4))
end
function custom_get_school_homepoint_info(SchoolID)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL), nx_int(5), SchoolID)
end
function custom_checked_selectrole(state)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHECKED_SELECTROLE), nx_int(state))
end
function custom_add_split_item(viewid, pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ADD_SPLITITEM), nx_int(viewid), nx_int(pos))
end
function custom_remove_split_item()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REMOVE_SPLITITEM))
end
function request_unenthrall(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_UNENTHRALL), unpack(arg))
end
function custom_escort_skill(skill_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local decal = nx_value("ground_pick_decal")
  if not nx_is_valid(decal) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ESCORT_SKILL), nx_string(skill_id), decal.PosX, decal.PosY, decal.PosZ)
end
function custom_escort_anshao_msg(msgid, anshao_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ESCORT_MSG), msgid, anshao_id)
end
function custom_send_escort_msg(msgid, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ESCORT_MSG), msgid, unpack(arg))
end
function custom_giveup_job(jobname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JOB), 1, jobname)
end
function custom_study_job(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JOB), 2, unpack(arg))
end
function custom_study_job_upgrade(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JOB), 3, unpack(arg))
end
function custom_accept_fortunetelling_result(res)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACCEPT_FORTUNETELLING_RESULT), res)
end
function custom_buy_back(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BUY_BACK_FORM_SHOP), index)
end
function custom_auto_equip_shotweapon(flag)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AUTO_EQUIP_SHOTWEAPON), flag)
end
function send_depot_msg(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DEPOT_MSG), unpack(arg))
end
function send_home_depot_msg(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HOME), unpack(arg))
end
function custom_inphase_clone(uid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_INPHASE_CLONE), nx_string(uid))
end
function send_faction_msg(domain_id, num)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUIRE_FACTION), nx_int(domain_id), nx_int(num))
end
function custom_save_chatpage_config(config)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_UPDATE_CHATPAGE), nx_widestr(config))
end
function custom_query_npc_karma(npc_id, scene_id, flag)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_NPC_KARMA), nx_string(npc_id), nx_int(scene_id), nx_int(flag))
end
function custom_send_liezhen_skill(liezhen_type, skill_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_LIEZHEN_SKILL), nx_int(liezhen_type), nx_string(skill_name))
end
function custom_get_npc_karma_value(npc_ident)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local cur_time = os.time()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_find_custom(client_player, "get_karma_lasttime") then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_NPC_KARMA_VALUE), nx_string(npc_ident))
    client_player.get_karma_lasttime = cur_time
    return
  end
  if os.difftime(cur_time, client_player.get_karma_lasttime) > 5 then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_NPC_KARMA_VALUE), nx_string(npc_ident))
    client_player.get_karma_lasttime = cur_time
  end
end
function custom_query_enemy_info(submsg, relation, name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local cur_time = os.time()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_find_custom(client_player, "get_enemy_info_lasttime") then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_ENEMY_INFO_RESULT), nx_int(submsg), nx_int(relation), nx_widestr(name))
    client_player.get_enemy_info_lasttime = cur_time
    return
  end
  if os.difftime(cur_time, client_player.get_enemy_info_lasttime) > 5 then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_ENEMY_INFO_RESULT), nx_int(submsg), nx_int(relation), nx_widestr(name))
    client_player.get_enemy_info_lasttime = cur_time
  end
end
function stun_offline_book_keeper(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_BOOK_KEEPER_STUN), nx_widestr(name))
end
function end_school_penance()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_PENANCE))
end
function end_repent()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CLIENT_SUB_END_REPENT = 1
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REPENT), nx_int(CLIENT_SUB_END_REPENT))
end
function custom_set_operate_mode(mode)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_OPERATEMODE), nx_int(mode))
end
function apply_add_npc_relation(sub_msg, npc_id, scene_id, para_ex)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if para_ex ~= nil then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MAIN_KARMA), nx_int(sub_msg), nx_string(npc_id), nx_int(scene_id), nx_string(para_ex))
  else
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MAIN_KARMA), nx_int(sub_msg), nx_string(npc_id), nx_int(scene_id))
  end
end
function custom_doqin(itemname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_QIN), nx_string(itemname))
end
function custom_qin_use_skill(skillid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QIN_USESKILL), nx_string(skillid))
end
function custom_buy_capital(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BUY_CAPITAL), unpack(arg))
end
function custom_cancel_open_life_flag(jobid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLOSE_LIFE_PROMPT), nx_string(jobid))
end
function custom_cancel_open_life_skill_flag(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLOSE_LIFE_SKILL_PROMPT), unpack(arg))
end
function custom_change_gem_job(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHANGE_GEM_JOB), unpack(arg))
end
function custom_check_appearance(number)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHECK_APPEARANCE_RESULT), nx_int(number))
end
function custom_get_server_id()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    game_config.server_id = nil
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_SERVER_ID))
end
function custom_get_login_account()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ACCOUNT))
end
function custom_record_account_log(strmsg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ACCOUNT), 1, strmsg)
end
function custom_get_game_step()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_GAME_STEP))
end
function custom_get_login_account_id()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ACCOUNT_ID))
end
function custom_start_compound(msgid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(msgid), 0)
end
function custom_cancel_compound(msgid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(msgid), 1)
end
function custom_add_compound_item(msgid, SrcViewId, SrcPos, nDstPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(msgid), 2, SrcViewId, SrcPos, nDstPos)
end
function custom_remove_compound_item(msgid, SrcPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(msgid), 3, SrcPos)
end
function custom_start_contribute()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CONTRIBUTE), 0)
end
function custom_cancel_contribute()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CONTRIBUTE), 1)
end
function custom_add_contribute_item(SrcViewId, SrcPos, nDstPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CONTRIBUTE), 2, SrcViewId, SrcPos, nDstPos)
end
function custom_remove_contribute_item(SrcPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CONTRIBUTE), 3, SrcPos)
end
function custom_start_npc_exchange(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NPCEXCHANGE), 0, index)
end
function custom_cancel_npc_exchange()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NPCEXCHANGE), 1)
end
function custom_add_npc_exchange_item(SrcViewId, SrcPos, nDstPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NPCEXCHANGE), 2, SrcViewId, SrcPos, nDstPos)
end
function custom_remove_npc_exchange_item(SrcPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NPCEXCHANGE), 3, SrcPos)
end
function custom_start_change_equip(index, item_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHANGE_EQUIP_ATTRIBUTE), 0, index, item_index)
end
function custom_cancel_change_equip()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHANGE_EQUIP_ATTRIBUTE), 1)
end
function custom_add_change_equip(SrcViewId, SrcPos, nDstPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHANGE_EQUIP_ATTRIBUTE), 2, SrcViewId, SrcPos, nDstPos)
end
function custom_remove_change_equip(SrcPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHANGE_EQUIP_ATTRIBUTE), 3, SrcPos)
end
function custom_create_groupchat(submsg, chat_name, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_CHAT), nx_int(submsg), nx_widestr(chat_name), unpack(arg))
end
function custom_del_groupchat(submsg, groupid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_CHAT), nx_int(submsg), nx_string(groupid))
end
function custom_open_groupchat(submsg, groupid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_CHAT), nx_int(submsg), nx_string(groupid))
end
function custom_groupchat_add_member(submsg, groupid, groupname, member_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_CHAT), nx_int(submsg), nx_string(groupid), nx_widestr(groupname), nx_widestr(member_name))
end
function custom_groupchat_del_member(submsg, groupid, groupname, member_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_CHAT), nx_int(submsg), nx_string(groupid), nx_widestr(groupname), nx_widestr(member_name))
end
function custom_groupchat_member_quit(submsg, groupid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_CHAT), nx_int(submsg), nx_string(groupid))
end
function custom_send_groupchat_content(submsg, groupid, chat_content, chat_time)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_CHAT), nx_int(submsg), nx_string(groupid), nx_widestr(chat_content), nx_string(chat_time))
end
function custom_groupchat_set_shield(submsg, groupid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_CHAT), nx_int(submsg), nx_string(groupid))
end
function custom_start_split_book()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SPLIT_BOOK), 0)
end
function custom_cancel_split_book()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SPLIT_BOOK), 1)
end
function custom_add_split_book(SrcViewId, SrcPos, nDstPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SPLIT_BOOK), 2, SrcViewId, SrcPos, nDstPos)
end
function custom_remove_split_book(SrcPos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SPLIT_BOOK), 3, SrcPos)
end
function custom_send_leitai_filter_Info_request()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_REQUIRE_SCORE_SECTION = 7
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_REQUIRE_SCORE_SECTION))
end
function custom_clone_reduce_difficulty_choice(choice, boss_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BOSS_STRENGTH_CHANGE), choice, boss_id)
end
function custom_clone_request_open_col_award()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_COL_AWARD))
end
function custom_rob_prison(type, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROB_PRISON), type, unpack(arg))
end
function custom_set_second_word(new_word1, new_word2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_SET_SECOND_WORD = 0
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_SET_SECOND_WORD), nx_widestr(new_word1), nx_widestr(new_word2))
end
function modify_second_word(second_word)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_REQUEST_MODIFY_SECOND_WORD = 2
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_REQUEST_MODIFY_SECOND_WORD), nx_widestr(second_word))
end
function cancel_second_word(second_word)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_CANCEL_SECOND_WORD = 4
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_CANCEL_SECOND_WORD), nx_widestr(second_word))
end
function check_second_word(second_word)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_CHECK_SECOND_WORD = 1
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_CHECK_SECOND_WORD), nx_widestr(second_word))
end
function add_second_word_lock()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_ADD_LOCK = 3
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_ADD_LOCK))
end
function del_second_word_lock()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_DEL_LOCK = 9
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_DEL_LOCK))
end
function request_set_second_word()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_REQUEST_SECOND_WORD = 6
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_REQUEST_SECOND_WORD))
end
function modify_word_protect_time(second_word)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_REQUEST_PROTECT_TIME = 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_REQUEST_PROTECT_TIME), nx_widestr(second_word))
end
function custom_set_word_protect_time(enable, normaltime, clashtime)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_SET_PROTECT_TIME = 11
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORD_CHECK), nx_int(CLIENT_SUBMSG_SET_PROTECT_TIME), nx_int(enable), nx_int(normaltime), nx_int(clashtime))
end
function custom_wqgame_look(player)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WQGAME_LOOK), player)
end
function custom_request_chat(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHITCHAT_REQUEST_CHAT), nx_widestr(player_name))
end
function custom_request_silence(chat_type, player_name)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAT_SILENCE), nx_int(chat_type), nx_widestr(player_name))
  end
end
function custom_send_chat_content(target_name, chat_content, chat_type, chat_time)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHITCHAT_SEND_CONTENT), nx_widestr(target_name), nx_widestr(chat_content), nx_int(chat_type), nx_string(chat_time))
end
function custom_send_group_chat_content(chat_content, chat_time)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHITCHAT_SEND_GROUP_CONTENT), nx_widestr(chat_content), nx_string(chat_time))
end
function custom_get_chater_info(player_name, request_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHITCHAT_GET_PLAYER_INFO), nx_widestr(player_name), nx_int(request_type))
end
function custom_remove_chat_whisper(target_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHITCHAT_WHISPER_READ), nx_widestr(target_name))
end
function custom_recommend_friends()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RECOMMEND_FRIENDS), 1, 0)
end
function custom_jianghu_help(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_ADVE_SUMMON), nx_widestr(player_name))
end
function custom_avatar_clone_invite_help(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_INVITE_HELPER), nx_widestr(player_name))
end
function custom_send_webexchange_msg(msgtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SELL_ITEM_TOWEB), nx_int(msgtype), unpack(arg))
end
function custom_arena_create(scene_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUB_CREATE = 1
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARENA), nx_int(CLIENT_SUB_CREATE), nx_int(scene_id))
end
function custom_arena_init(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUB_INIT = 2
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARENA), nx_int(CLIENT_SUB_INIT), unpack(arg))
end
function custom_arena_join(scene_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUB_JOIN = 3
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARENA), nx_int(CLIENT_SUB_JOIN), nx_int(scene_id))
end
function custom_arena_leave()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUB_LEAVE = 4
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARENA), nx_int(CLIENT_SUB_LEAVE))
end
function custom_set_wuxue_leave(need_faculty, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUB_SET_WUXUE = 11
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARENA), nx_int(CLIENT_SUB_SET_WUXUE), nx_int(need_faculty), unpack(arg))
end
function custom_reset_wuxue_faculty(need_faculty, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUB_RESET_WUXUE = 12
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARENA), nx_int(CLIENT_SUB_RESET_WUXUE))
end
function custom_arena_game_over()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUB_JUDGE_CLOSE = 20
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARENA), nx_int(CLIENT_SUB_JUDGE_CLOSE))
end
function custom_dongfang_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DONGFANG), nx_int(sub_msg), unpack(arg))
end
function custom_close_equip_blend()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLOSE_EQUIP_BLEND))
end
function custom_add_equip_blend_item(src_viewid, src_pos, dst_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ADD_EQUIP_BLEND_ITEM), nx_int(src_viewid), nx_int(src_pos), nx_int(dst_pos))
end
function custom_remove_equip_blend_item(view_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REMOVE_EQUIP_BLEND_ITEM), view_index)
end
function custom_begin_blend_equip()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_BLEND_EQUIP))
end
function custom_begin_recover_equip(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_RECOVER_EQUIP), nx_int(index))
end
function custom_kapai_msg(type, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_KAPAI_EVENT), nx_int(type), unpack(arg))
end
function custom_switch_msg(type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHECK_SWITCH_ENABLE), nx_int(type))
end
function custom_jingmai_msg(type, arg1)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JINGMAI), nx_int(type), arg1)
end
function custom_jingmai_wuji_msg(type, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JINGMAI_WUJI), nx_int(type), unpack(arg))
end
function custom_sns_search_friend(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_SEARCH_FRIEND), nx_widestr(name))
end
function custom_open_huaren_charge(url_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUAREN_CHARGE), nx_int(url_type))
end
function custom_onestep_equip_msg_add(proj, pos, item_unid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ONESTEP_EQUIP_ADD), nx_int(proj), nx_int(pos), nx_string(item_unid))
end
function custom_onestep_equip_msg_del(proj, pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ONESTEP_EQUIP_DEL), nx_int(proj), nx_int(pos))
end
function custom_onestep_equip_msg_clear(type_index, sel_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ONESTEP_EQUIP_CLEAR), type_index, sel_index)
end
function custom_onestep_equip_msg_equipall(index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  if not player:FindProp("InteractStatus") then
    return 0
  end
  local interact_status = player:QueryProp("InteractStatus")
  if nx_int(interact_status) == nx_int(ITT_BALANCE_WAR) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ONESTEP_EQUIP_EQUIPALL), index)
end
function custom_set_compete_baseprice(item, price, mode)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FINISH_BASEPRICE), nx_object(item), nx_int(price), nx_int(mode))
end
function custom_compete_item_result(item, price)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_COMPETE_ITEM_RESULT), nx_object(item), nx_int(price))
end
function custom_request_gamble(child_msg_id, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GAMBLE), nx_int(child_msg_id), unpack(arg))
end
function custom_avenge(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AVENGE), nx_int(sub_msg), unpack(arg))
end
function custom_school_gxd()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_CONTRIBUTE))
end
function custom_clonestore_purchase(pos, configid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLONESTORE_PURCHASE), nx_int(pos), nx_string(configid))
end
function custom_get_guildenemy_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_ENEMY_LIST))
end
function custom_query_jiuyinzhi_current_step()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIUYINZHI_GET_INFO), "", nx_int(MSGID_JIUYINZHI_QUERY_CURRENT_GAME_STEP))
end
function custom_equipblend_collect(src_view, pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BEGIN_COLLECT_EQUIP), nx_int(src_view), nx_int(pos))
end
function custom_equipblend_freight(configid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FREIGHT_COLLECT_EQUIP), nx_string(configid))
end
function custom_trace_role(type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NPC_QUERY_ROLE), nx_int(type))
end
function custom_delieve(type, name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NPC_QUERY_ROLE), nx_int(type), nx_widestr(name))
end
function custom_query_good_feeling(type, npc_id, scene_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NPC_QUERY_ROLE), nx_int(type), nx_string(npc_id), nx_int(scene_id))
end
function custom_cure_hero_npc(type, npc_id, scene_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(type), nx_string(npc_id), nx_int(scene_id))
end
function custom_equipblend_active(configid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVE_BLEND_EQUIP), nx_string(configid))
end
function custom_attire_equip_copy_msg(configid, num, use_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ATTIRE_EQUIP_COPY), nx_string(configid), nx_int(num), nx_int(use_type))
end
function custom_send_clf_roll_game(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLFROLLGAME), unpack(arg))
end
function custom_send_hwq_choice(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUAWUQUE_RACE), unpack(arg))
end
function custom_ssg_schoolmeet(msg_id, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SSG_SCHOOLMEET), nx_int(msg_id), unpack(arg))
end
function ssg_exit_schoolmeet_test()
  custom_ssg_schoolmeet(2)
end
function custom_wxj_schoolmeet(msg_id, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WXJ_SCHOOLMEET), nx_int(msg_id), unpack(arg))
end
function wxj_exit_schoolmeet_test()
  custom_wxj_schoolmeet(0)
end
function custom_dmp_schoolmeet(msg_id, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DMP_SCHOOLMEET), nx_int(msg_id), unpack(arg))
end
function dmp_exit_schoolmeet_test()
  custom_dmp_schoolmeet(0)
end
function custom_send_jyz_msg(player_name, msgID, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIUYINZHI_GET_INFO), player_name, nx_int(msgID), unpack(arg))
end
function custom_send_jzsj_qhyc(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JZSJ_QHYC), unpack(arg))
end
function custom_send_single_step(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SINGLE_STEP), unpack(arg))
end
function custom_req_active()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QUERY_HOLIDAY_ACTIVE))
  end
end
function custom_lottery_msg(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LOTTERY), unpack(arg))
end
function custom_request_huashan(child_msg_id, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUASHAN), nx_int(child_msg_id), unpack(arg))
end
function custom_treasurebox_msg(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TREASUREBOX_MSG), unpack(arg))
end
function custom_get_mvp()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUASHAN_MVP), 1)
end
function custom_ballot(mvp_type, name, vote_type, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUASHAN_MVP), 0, mvp_type, name, vote_type, unpack(arg))
end
function custom_get_schoolleader_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_SCHOOLLEADER_INFO))
end
function custom_world_war_sender(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_group_purchase_msg(msg_id, item_id_str)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_PURCHASE), nx_int(msg_id), nx_string(item_id_str))
end
function custom_seek_mine_msg(nType, nIndex)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SEEK_MINE), nx_int(nType), nx_int(nIndex))
end
function custom_seek_mine_moveto_msg(nType, item_config, ret)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SEEK_MINE), nx_int(nType), nx_string(item_config), nx_int(ret))
end
function custom_face(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_FACE), unpack(arg))
end
function custom_pet(sub_msg, pet_id, group_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PET), nx_int(sub_msg), nx_string(pet_id), nx_string(group_id))
end
function custom_normal_pet(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NORMAL_PET), unpack(arg))
end
function custom_teacher_pupil(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEACHER_PUPIL), nx_int(sub_msg), unpack(arg))
end
function custom_get_power_num()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(11))
  end
end
function custom_power_redeem(num)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(12), num)
  end
end
function custom_get_novice_num()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(14))
  end
end
function custom_novice_redeem(num)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(13), num)
  end
end
function custom_msg_home_gouhuo(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HOME), unpack(arg))
end
function custom_get_old_num()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(16))
  end
end
function custom_old_redeem(num)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(15), num)
  end
end
function custom_damingtongdian()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(25))
  end
end
function custom_request_signin()
  local CLIENT_SUBMSG_REQUEST_SIGNIN = 9
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_SIGNIN))
  end
end
function custom_draw_prize(submsg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DRAW_PRIZE), nx_int(submsg))
end
function custom_request_signin_vip()
  local CLIENT_SUBMSG_REQUEST_SIGNIN_VIP = 10
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_SIGNIN_VIP))
  end
end
function custom_msg_recast_lock(view_id, n_pos, sel_op)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EQUIPRANDPROP_LOCK), nx_int(view_id), nx_int(n_pos), nx_int(sel_op))
end
function custom_request_safe_login()
  local CLIENT_SUBMSG_REQUEST_SAFE_LOGIN_BU = 19
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_SAFE_LOGIN_BU))
  end
end
function custom_request_login()
  local CLIENT_SUBMSG_REQUEST_LOGIN_BU = 20
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_LOGIN_BU))
  end
end
function custom_send_name_change(new_name, del_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NAME_CHANGE), nx_widestr(new_name), nx_int(del_type))
end
function custom_marry(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MARRY), nx_int(subtype), unpack(arg))
end
function custom_msg_marryshop(optype, itemid_str)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MARRY_SHOP), nx_int(optype), itemid_str)
end
function custom_msg_recast_unlock(view_id, n_pos, sel_op)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EQUIPRANDPROP_UNLOCK), nx_int(view_id), nx_int(n_pos), nx_int(sel_op))
end
function custom_choice(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CHOICEITEM), nx_int(subtype), unpack(arg))
end
function custom_msg_recast_randprop(view_id, n_pos, sel_op, cost_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_YURANDPROP), nx_int(view_id), nx_int(n_pos), nx_int(sel_op), nx_int(cost_type))
end
function custom_msg_recast_sureprop(view_id, n_pos, sel_op)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SUREEQUIPPROP), nx_int(view_id), nx_int(n_pos), nx_int(sel_op))
end
function custom_upgrade_equip(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_UPGRADE_EQUIP), nx_int(subtype), unpack(arg))
end
function custom_send_world_rank_query_no(sub_cmd, rank_name, no)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_RANK), nx_int(sub_cmd), nx_string(rank_name), nx_int(no))
end
function custom_modify_binglu(sub_msg, item_id, binglu_type, add_item_num)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MODIFY_BINGLU), nx_int(sub_msg), item_id, binglu_type, add_item_num)
end
function custom_ws_check_test_server_open()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CUSTOMMSG_SUB_CHECK_TEST_SERVER_OPEN = 0
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEST_SERVER), nx_int(CUSTOMMSG_SUB_CHECK_TEST_SERVER_OPEN))
end
function custom_gem_smahing_egg_game(green_egg, gold_egg, red_egg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GEM_SMAHING_EGG_GAME_MSG), nx_int(green_egg), nx_int(gold_egg), nx_int(red_egg))
end
function custom_enter_scene(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_SHANDA_AWARD), subtype)
  return 1
end
function custom_send_danshua_tiguan_msg(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DANSHUA_TIGUAN), nx_int(subtype), unpack(arg))
end
function custommsg_activity_point(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_POINT), nx_int(sub_msg), unpack(arg))
  end
end
function custom_query_star_info(type, sign)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_STAR), nx_int(CLIENT_SUB_QUERY_STAR), nx_int(type), nx_string(sign))
end
function custom_msg_pk_punish(sub_msg, item_uid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PUNISH), nx_int(sub_msg), nx_string(item_uid))
end
function custom_manyrevenge_match(subtype, war_type, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if 3 == subtype then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MANY_REVENGE), nx_int(subtype), nx_widestr(war_type), unpack(arg))
  else
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MANY_REVENGE), nx_int(subtype), nx_int(war_type), unpack(arg))
  end
end
function custom_chang_equip_wx(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CONVERT_EQUIP), nx_int(subtype), unpack(arg))
end
function custom_chang_equip_qm(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QIMEN_EQUIP), nx_int(subtype), unpack(arg))
end
function custom_map_get_dynamic_object_pos(flag)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_NPC_POS), nx_int(flag))
end
function custom_send_forget_skill_msg(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FORGET_SKILL), nx_int(subtype), unpack(arg))
end
function custom_send_to_spy(sub_msg, name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_INTERACTIVE_MSG), nx_int(sub_msg), nx_widestr(name))
end
function custom_shijia_qte(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHIJIA_QTE), nx_int(sub_msg))
end
function custom_send_to_shool_dance(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_DANCE), nx_int(sub_msg))
end
function custom_send_transQte_result(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLIENT_TRANS_QTE), nx_int(sub_msg))
end
function custom_send_jumpgame_result(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JUMP_GAME), nx_int(sub_msg))
end
function custom_add_protect_item(view_id, view_index)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PROTECTITEMADD), nx_int(view_id), nx_int(view_index))
  end
end
function custom_del_protect_item(uid)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PROTECTITEMDEL), nx_string(uid))
  end
end
function custom_send_skill_general_result(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SKILL_GENERAL), nx_int(sub_msg))
end
function custom_egwar_trans(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EGWAR), nx_int(sub_msg), unpack(arg))
end
function custom_gossip(sub_msg, text, bagua_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BAGUA), nx_int(sub_msg), nx_widestr(text), bagua_id)
end
function custom_game_match(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GAME_MATCH), nx_int(subtype), unpack(arg))
end
function custom_revenge_match(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REVENGE), nx_int(subtype), unpack(arg))
end
function custom_box_event(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BOX_EVENT), nx_int(sub_msg), unpack(arg))
  end
end
function custom_treasure_chest(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TREASURE_CHEST), nx_int(sub_msg), unpack(arg))
  end
end
function custom_extra_skill(...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_EXTRA_SKILL), unpack(arg))
  end
end
function custom_copy_skill(...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_COPY_SKILL), unpack(arg))
  end
end
function custom_make_item(sub_smg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MAKE_ITEM), nx_int(sub_smg), unpack(arg))
  end
end
function custom_register(...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REGISTER), unpack(arg))
  end
end
function custom_yhg_td_request_leave(...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_LEAVE_YHG_TD))
  end
end
function custom_wjd_request(sub_type)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_WUJIDAO), nx_int(sub_type))
  end
end
function custom_tersure_lock(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(0), nx_int(view), nx_int(index))
end
function custom_tersure_unlock(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(1), nx_int(view), nx_int(index))
end
function custom_tersure_get_max_value(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(2), nx_int(view), nx_int(index))
end
function custom_refresh_tersure(sub_type, view, index, type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(sub_type), nx_int(view), nx_int(index), nx_int(type))
end
function custom_save_tersure_pro(sub_type, view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(sub_type), nx_int(view), nx_int(index))
end
function custom_upgrade_tersure(view, index, stuff_view, stuff_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(5), nx_int(view), nx_int(index), nx_int(stuff_view), nx_int(stuff_index))
end
function custom_tersure_lock_prop(sub_type, sel_view, sel_index, row)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(sub_type), nx_int(sel_view), nx_int(sel_index), nx_int(row))
end
function custom_newtersure_lock(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(14), nx_int(view), nx_int(index))
end
function custom_newtersure_unlock(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(15), nx_int(view), nx_int(index))
end
function custom_newtersure_stuff_lock(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(16), nx_int(view), nx_int(index))
end
function custom_newtersure_stuff_unlock(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(17), nx_int(view), nx_int(index))
end
function custom_newtersure_grave(view, index, prop_count)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(18), nx_int(view), nx_int(index), nx_int(prop_count))
end
function custom_newtersure_transfer(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(19), nx_int(view), nx_int(index))
end
function custom_newtersure_replace(view, index, select_1, select_2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(20), nx_int(view), nx_int(index), nx_int(select_1), nx_int(select_2))
end
function custom_newtersure_intensify(view, index, select)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(21), nx_int(view), nx_int(index), nx_int(select))
end
function custom_treasure_repair(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(22), nx_int(view), nx_int(index))
end
function custom_equip_name_start(sub_smg, view_id, n_pos, name, desc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CUSTOMEQUIPNAME), nx_int(sub_smg), nx_int(view_id), nx_int(n_pos), name, desc)
end
function custom_zhongqiu_subgroup(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TRAINPAT_CELLPAT), nx_int(-1), nx_int(sub_msg))
end
function custom_pikongzhang_activity(sub_smg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PIKONGZHANG_ACTIVITY), nx_int(sub_smg), unpack(arg))
end
function custom_item_exchange(src_id, src_num, dest_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ITEM_EXCHANGE), nx_string(src_id), nx_int(src_num), nx_string(dest_id))
end
function custom_weather_war(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WEATHER_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_weather_war_subgroup(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WEATHER_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_get_area_tianqi(scene_id, sub_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WEATHER), nx_int(sub_type), scene_id)
end
function custom_xjz_gh_skill(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GOUHUO), nx_int(subtype), unpack(arg))
end
function custom_xjz_jh_game(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIAHUO), nx_int(subtype), unpack(arg))
end
function custom_xjz_sk_game(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHAOKAO), nx_int(subtype), unpack(arg))
end
function custom_send_query_round_task(sub_type, task_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROUND_TASK), nx_int(sub_type), nx_int(task_id))
end
function custom_get_leave_school_info(type, name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_LEAVE_SCHOOL_INFO), nx_int(type), nx_widestr(name))
end
function custom_query_match_data(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MATCH_DATA), nx_int(sub_msg), unpack(arg))
end
function custom_question(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QUESTION), nx_int(sub_msg), unpack(arg))
end
function custom_check_afk_question(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHECK_AFK_QUESTION), nx_int(sub_msg), unpack(arg))
end
function custom_query_inv_rank(rank_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLENIT_CUSTOMMSG_QUERY_INV_RANK), nx_int(1), nx_string(rank_type))
end
function custom_query_friend_rank(rank_type, friend_list, player_list)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLENIT_CUSTOMMSG_QUERY_INV_RANK), nx_int(2), nx_string(rank_type), nx_string(friend_list), nx_widestr(player_list))
end
function custom_reply_trans_server_list(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REPLY_TRANSFER_SERVER), nx_int(sub_msg), unpack(arg))
end
function custom_offline_accost(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_ACCOST), nx_int(sub_msg), unpack(arg))
  end
end
function custom_send_bodyguardoffice_sender(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BODYGUARDOFFICE), nx_int(sub_msg), unpack(arg))
end
function custom_offline_employ(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_EMPLOY), nx_int(sub_msg), unpack(arg))
  end
end
function custom_msg_sweet_pet_clothes(msg, sweet_type)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SWEET_PET_CLOTHES), nx_int(sweet_type), nx_string(msg))
end
function custom_ancient_tomb_sender(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ANCIENT_TOMB), nx_int(sub_msg), unpack(arg))
end
function custom_send_scene_compete_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCENE_COMPETE), nx_int(sub_msg), unpack(arg))
end
function custom_request_swap_goods(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_SWAP_GOODS), nx_int(sub_msg), unpack(arg))
end
function custom_send_jhpk_get_rank_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CUSTOM_SUB_JHPK_GET_RANK = 5
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCENE_JHPK), nx_int(CUSTOM_SUB_JHPK_GET_RANK), nx_widestr(""))
end
function custom_send_scene_jhpk(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCENE_JHPK), nx_int(sub_msg), unpack(arg))
end
function custom_send_home_farm(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HOME_FARM), nx_int(sub_msg), unpack(arg))
end
function custom_send_home_mine(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HOME_MINE), nx_int(sub_msg), unpack(arg))
end
function custom_send_newjh_back_home()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIANGHU_HOMEBACK))
end
function custom_send_move_item_to_new(move_op, strpos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOVEITEM_TO_NEW), nx_int(move_op), nx_string(strpos))
end
function custom_use_temp_skill(skill_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_TEMP_SKILL), skill_id)
end
function custom_send_world_boss(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_BOSS), nx_int(sub_msg), unpack(arg))
end
function custom_send_nlb_shimen(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NLB_SHIMEN), nx_int(sub_msg), unpack(arg))
end
function custom_send_sjy_shimen(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SJY_SCHOOL_MEET), nx_int(sub_msg), unpack(arg))
end
function custom_quit_sjy_school_meet()
  custom_send_sjy_shimen(0)
end
function custom_send_xmg_shimen(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_XMG_SCHOOL_MEET), nx_int(sub_msg), unpack(arg))
end
function custom_quit_xmg_school_meet()
  custom_send_xmg_shimen(0)
end
function custom_foeman_infall(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_BOSS), nx_int(sub_msg), unpack(arg))
end
function custom_cross_school(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), unpack(arg))
end
function custom_send_accept_friend_letter_flag(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_POST_ACCEPT_FRIEND), unpack(arg))
end
function custom_send_guild_station_activity(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_STATION_ACTIVITY), unpack(arg))
end
function custom_send_guild_city_def(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CITY_DEFENSE), unpack(arg))
end
function custom_attire_equip_blend(use_type, info)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ATTIRE_EQUIP_BLEND), nx_int(use_type), nx_string(info))
end
function custom_dbomall_request(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DBOMALL_MESSAGE), nx_int(sub_msg), unpack(arg))
end
function custom_huashan_school(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUASHAN_SCHOOL), nx_int(sub_msg), unpack(arg))
end
function custom_tg_roll_game(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TGROLL_GAME), nx_int(sub_msg), unpack(arg))
end
function custom_world_auction(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_AUCTION), nx_int(sub_msg), unpack(arg))
end
function custom_champion_war(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_cw_back()
  custom_champion_war(nx_int(1))
end
function custom_tarot(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TAROT), nx_int(sub_msg), unpack(arg))
end
function custom_agree_war(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AGREE_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_outland_war(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OUTLAND_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_ssg_yjp(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SSG_YJP), nx_int(sub_msg), unpack(arg))
end
function custom_sworn(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SWORN), nx_int(sub_msg), unpack(arg))
end
function custom_cross_guild_war(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_CROSS_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_red_packet(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RED_PACKET), unpack(arg))
end
function custom_prepare_jingmai_active(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PREPARE_JINGMAI), nx_int(sub_msg), unpack(arg))
end
function custom_wuxue_canwu(sub_msg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUASHAN), nx_int(sub_msg))
end
function custom_linxiao_zhizun(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LINGXIAO_ZHIZUN), nx_int(sub_msg), unpack(arg))
end
function custom_linxiao_exchange(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_LINXIAO_EXCHANGE), unpack(arg))
end
function custom_song_jing_request(sub_type)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SONGJING_GAME), nx_int(sub_type))
  end
end
function custom_escort_game_answer(sub_type, answerlist)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ESCORT_GAME), nx_string(answerlist))
  end
end
function custom_outland_reward(sub_msg)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local client_sub_msg_click_outland_reward = 1
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OUTLAND_VALUE_AWARD), nx_int(client_sub_msg_click_outland_reward), nx_int(sub_msg))
  end
end
function custom_outland_event_select_item(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OUTLAND_EVENT), nx_int(sub_msg), unpack(arg))
  end
end
function custom_form_outland_send_get_origin(origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ORIGIN), nx_int(origin_id))
end
function custom_form_outland_send_get_item(origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ORIGIN_PRIZE), nx_int(origin_id))
end
function custom_msg_activity_guide()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_GUIDE))
end
function custom_skyhill_achievement(sub_msg)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local SkyHill_ClientMsg_Show_Achi = 6
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SKY_HILL), nx_int(SkyHill_ClientMsg_Show_Achi), nx_int(sub_msg))
  end
end
function custom_skyhill_get_reward(sub_msg)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local SkyHill_ClientMsg_Achi_Prize = 7
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SKY_HILL), nx_int(SkyHill_ClientMsg_Achi_Prize), nx_int(sub_msg))
  end
end
function custom_skyhill_next(sub_msg)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SKY_HILL), nx_int(sub_msg))
  end
end
function custom_form_ttf_template(sub_msg)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SKY_HILL), nx_int(sub_msg))
  end
end
function custom_treasure_repair(view, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TERSURE), nx_int(22), nx_int(view), nx_int(index))
end
function custom_school_counter_attack_data(sub_msg)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_EXTINCT), nx_int(sub_msg))
  end
end
function custom_shijia_trains(sub_msg, id)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHIJIA), nx_int(sub_msg), nx_int(id))
  end
end
function custom_shcool_destroy(sub_msg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_EXTINCT), nx_int(sub_msg))
end
function custom_sanhill_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SAN_HILL), nx_int(sub_msg), unpack(arg))
  end
end
function custom_single_shop_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SINGLE_SHOP), nx_int(sub_msg), unpack(arg))
  end
end
function custom_shijia_achievement_data(sub_msg, id)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHIJAI_CHENGJIU), nx_int(sub_msg), nx_int(id))
  end
end
function custom_protect_school_step()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_EXTINCT), nx_int(21))
  end
end
function custom_protect_school_time(school_id)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_EXTINCT), nx_int(23), nx_int(school_id))
  end
end
function custom_protect_school_reward()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_EXTINCT), nx_int(22))
  end
end
function custom_protect_school_enter(school_id)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SCHOOL_EXTINCT), nx_int(24), nx_int(school_id))
  end
end
function custom_match_sanmeng(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MATCH_SANMENG), nx_int(sub_msg), unpack(arg))
end
function custom_guild_luck_pray(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_LUCK_PRAY), nx_int(sub_msg), unpack(arg))
end
function custom_teach_exam(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TEACH_EXAM), nx_int(sub_msg), unpack(arg))
end
function custom_auction(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AUCTION_MSG), nx_int(sub_msg), unpack(arg))
end
function custom_teacher_pupil_new(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(sub_msg), unpack(arg))
end
function custom_wudao(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_luandou(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(sub_msg), unpack(arg))
end
function custom_taosha(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TAOSHA), nx_int(sub_msg), unpack(arg))
end
function custom_apex(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_APEX), nx_int(sub_msg), unpack(arg))
end
function custom_five_sky(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FIVE_SKY), nx_int(sub_msg), unpack(arg))
end
function custom_ghost_city(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GHOST_CITY), nx_int(sub_msg), unpack(arg))
end
function custom_descapital_addbuff(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(sub_msg), unpack(arg))
end
function custom_see(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SEE), nx_int(sub_msg), unpack(arg))
end
function custom_select_school(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOM_SCHOOL_MSG), nx_int(sub_msg), unpack(arg))
end
function custom_betray_new_school(sub_msg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOM_SCHOOL_MSG), nx_int(sub_msg))
end
function custom_rtm_invite_help(player_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROYAL_TREASURE), nx_int(1), nx_widestr(player_name))
end
function custom_quit_royal_treasure()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROYAL_TREASURE), nx_int(3))
end
function custom_learn_gupu_skill()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEARN_GUPU_SKILL))
end
function custom_get_activity_value_rank_prize_rec()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_AWARD), nx_int(3))
end
function custom_jiuyang_faculty(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIUYANG_FACULTY), nx_int(sub_msg), unpack(arg))
end
function custom_activity_collect_pieces(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_COLLECT_PIECES), nx_int(sub_msg), unpack(arg))
end
function custom_quit_jiuyang_faculty()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIUYANG_FACULTY), nx_int(2))
end
function custom_quit_sjy_drill()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TASK_MSG), nx_int(13))
end
function custom_quit_yubi_activity()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FESTIVAL_SIGN), nx_int(4))
end
function custom_quit_middle_spring_hunt()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MIDDLE_SPRING_HUNT), nx_int(1))
end
function custom_tiguan_dual_play(sub_msg, ...)
  local CLIENT_CUSTOMMSG_TIGUAN_DUAL_PLAYER = 802
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_DUAL_PLAYER), nx_int(sub_msg), unpack(arg))
end
function custom_form_sign_and_draw(sub_msg, ...)
  local CLIENT_CUSTOMMSG_SIGN_N_DRAW = 421
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SIGN_N_DRAW), nx_int(sub_msg), unpack(arg))
end
function custom_guildglobalwar(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_GLOBAL_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_corss_station_war(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CROSS_STATION_WAR), nx_int(sub_msg), unpack(arg))
end
function custom_league_matches(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEAGUE_MATCHES), nx_int(sub_msg), unpack(arg))
end
function custom_league_matches_back()
  custom_league_matches(2)
end
function custom_flee_in_night(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FLEE_IN_NIGHT), nx_int(sub_msg), unpack(arg))
end
function custom_flee_in_night_back()
  custom_flee_in_night(1)
end
function custom_kof(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_KOF), nx_int(sub_msg), unpack(arg))
end
function custom_check_delete_force(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHECK_DELETE_FORCE), nx_int(sub_msg), unpack(arg))
end
function custom_wudao_yanwu(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_YANWU), nx_int(sub_msg), unpack(arg))
end
function custom_online_purchase_rebate(sub_msg, ...)
  local CLIENT_CUSTOMMSG_ONLINE_PURCHASE_REBATE = 513
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ONLINE_PURCHASE_REBATE), nx_int(sub_msg), unpack(arg))
end
function custom_horse_race(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_HORSE_RACE), nx_int(sub_msg), unpack(arg))
end
function custom_pick_daypacket(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DAY_REDPT), nx_int(sub_msg), unpack(arg))
end
function custom_guild_list(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(sub_msg), unpack(arg))
end
function custom_send_newpacket(money, num, rule, vip, powerlevel, channel, bless, groupid, position)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CheckWords = nx_value("CheckWords")
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_hongbao_send_chat_desc")
  local show_text1 = nx_widestr(gui.TextManager:Format_GetText())
  gui.TextManager:Format_SetIDName("ui_hongbao_send_chat_receive")
  local get_text = nx_widestr(gui.TextManager:Format_GetText())
  local content_bless = nx_widestr(CheckWords:CleanWords(nx_widestr(bless)))
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_PACKET), nx_int(0), nx_int(money), nx_int(num), nx_int(rule), nx_int(vip), nx_int(powerlevel), nx_int(channel), nx_widestr(content_bless), nx_string(groupid), nx_widestr(show_text1), nx_widestr(get_text), nx_int(position))
end
function custom_get_newpacket(uid_packet)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_PACKET), nx_int(1), nx_string(uid_packet))
end
function custom_see_singlepacket(uid_packet)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_PACKET), nx_int(2), nx_string(uid_packet))
end
function custom_see_getrecord()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_PACKET), nx_int(3))
end
function custom_see_sendrecord()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_PACKET), nx_int(4))
end
function custom_reply_packet(uid_packet, content)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_PACKET), nx_int(6), nx_string(uid_packet), nx_widestr(content))
end
function custom_attr_mall(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ATTRIBUTE_MALL), nx_int(sub_msg), unpack(arg))
end
function custom_ver_201904(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_VER_201904), nx_int(sub_msg), unpack(arg))
end
function custom_cross_server(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CROSS_SERVER), nx_int(sub_msg), unpack(arg))
end
function custom_request_guildbl()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(10))
end
function custom_request_guildplnum()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(11))
end
function custom_act_grouppurchase()
  local form = nx_value("form_stage_main\\form_act_grouppurchase")
  if nx_is_valid(form) and form.Visible == true then
    form:Close()
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_PURCHASE), 0)
end
