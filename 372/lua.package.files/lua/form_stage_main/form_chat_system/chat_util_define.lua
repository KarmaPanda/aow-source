require("util_functions")
require("game_object")
GROUP_MESSAGE_FLAG = "GroupChatList"
HYPERLINK_MAX_NUM = 6
FRIEND_REC = "rec_friend"
BUDDY_REC = "rec_buddy"
ATTENTION_REC = "rec_attention"
ACQUAINT_REC = "rec_acquaint"
ENEMY_REC = "rec_enemy"
BLOOD_REC = "rec_blood"
BROTHER_REC = "rec_brother"
FILTER_REC = "rec_filter"
FANS_REC = "rec_fans"
PRESENT_REC = "rec_present"
QIFU_REC = "rec_qifu"
PUPIL_REC = "rec_teacherpupil"
WHISPER_REC = "RecvWhisperRec"
NPC_RELATION_REC = "rec_npc_relation"
NPC_ATTENTION_REC = "rec_npc_attention"
PUPIL_JINGMAI_REC = "rec_jingmai_tp"
SWORN_REC = "SwornRelationRec"
NEW_TEACHER_REC = "rec_newteacher"
PLAYER_GROUP_CHAT_REC = "player_group_chat_rec"
player_group_rec_groupid = 0
player_group_rec_groupname = 1
player_group_rec_master = 2
player_group_rec_memberlist = 3
player_group_rec_shield = 4
NPC_RELATION_CONFIG = 0
NPC_RELATION_SCENEID = 1
NPC_RELATION_KARMA_VALUE = 2
NPC_RELATION_TYPE = 3
WHISPER_REC_COL_SENDNAME = 0
WHISPER_REC_COL_SENDUID = 1
WHISPER_REC_COL_VALUE = 2
WHISPER_REC_COL_READFLAG = 3
FILTER_REC_COL_UID = 0
FILTER_REC_COL_NAME = 1
FILTER_REC_COL_PHOTO = 2
FRIEND_REC_COL_UID = 0
FRIEND_REC_COL_NAME = 1
FRIEND_REC_COL_PHOTO = 2
FRIEND_REC_COL_CHENGHAO = 3
FRIEND_REC_COL_LEVEL = 4
FRIEND_REC_COL_MENPAI = 5
FRIEND_REC_COL_BANGPAI = 6
FRIEND_REC_COL_XINQING = 7
FRIEND_REC_COL_ONLINE = 8
FRIEND_REC_COL_SCENE = 9
FRIEND_REC_COL_MODEL = 10
FRIEND_REC_COL_SELFFRIENDLY = 11
FRIEND_REC_COL_TARGETFRIENDLY = 12
FRIEND_REC_COL_CHARACTERFLAG = 13
FRIEND_REC_COL_CHARACTERVALUE = 14
FRIEND_REC_COL_REVENGEPOINT = 15
BUDDY_REC_COL_UID = 0
BUDDY_REC_COL_NAME = 1
BUDDY_REC_COL_PHOTO = 2
BUDDY_REC_COL_CHENGHAO = 3
BUDDY_REC_COL_LEVEL = 4
BUDDY_REC_COL_MENPAI = 5
BUDDY_REC_COL_BANGPAI = 6
BUDDY_REC_COL_XINQING = 7
BUDDY_REC_COL_ONLINE = 8
BUDDY_REC_COL_SCENE = 9
BUDDY_REC_COL_MODEL = 10
BUDDY_REC_COL_SELFFRIENDLY = 11
BUDDY_REC_COL_TARGETFRIENDLY = 12
BUDDY_REC_COL_CHARACTERFLAG = 13
BUDDY_REC_COL_CHARACTERVALUE = 14
BUDDY_REC_COL_REVENGEPOINT = 15
ENEMY_REC_COL_UID = 0
ENEMY_REC_COL_NAME = 1
ENEMY_REC_COL_PHOTO = 2
ENEMY_REC_COL_CHENGHAO = 3
ENEMY_REC_COL_LEVEL = 4
ENEMY_REC_COL_MENPAI = 5
ENEMY_REC_COL_BANGPAI = 6
ENEMY_REC_COL_XINQING = 7
ENEMY_REC_COL_ONLINE = 8
ENEMY_REC_COL_SCENE = 9
ENEMY_REC_COL_MODEL = 10
ENEMY_REC_COL_SELFENMITY = 11
ENEMY_REC_COL_TARGETENMITY = 12
ENEMY_REC_COL_CHARACTERFLAG = 13
ENEMY_REC_COL_CHARACTERVALUE = 14
ENEMY_REC_COL_REVENGEPOINT = 15
BLOOD_REC_COL_UID = 0
BLOOD_REC_COL_NAME = 1
BLOOD_REC_COL_PHOTO = 2
BLOOD_REC_COL_CHENGHAO = 3
BLOOD_REC_COL_LEVEL = 4
BLOOD_REC_COL_MENPAI = 5
BLOOD_REC_COL_BANGPAI = 6
BLOOD_REC_COL_XINQING = 7
BLOOD_REC_COL_ONLINE = 8
BLOOD_REC_COL_SCENE = 9
BLOOD_REC_COL_MODEL = 10
BLOOD_REC_COL_SELFENMITY = 11
BLOOD_REC_COL_TARGETENMITY = 12
BLOOD_REC_COL_CHARACTERFLAG = 13
BLOOD_REC_COL_CHARACTERVALUE = 14
BLOOD_REC_COL_REVENGEPOINT = 15
ATTENTION_REC_COL_UID = 0
ATTENTION_REC_COL_NAME = 1
ATTENTION_REC_COL_PHOTO = 2
ATTENTION_REC_COL_CHENGHAO = 3
ATTENTION_REC_COL_LEVEL = 4
ATTENTION_REC_COL_MENPAI = 5
ATTENTION_REC_COL_BANGPAI = 6
ATTENTION_REC_COL_XINQING = 7
ATTENTION_REC_COL_ONLINE = 8
ATTENTION_REC_COL_SCENE = 9
ATTENTION_REC_COL_MODEL = 10
ACQUAINT_REC_COL_UID = 0
ACQUAINT_REC_COL_NAME = 1
ACQUAINT_REC_COL_PHOTO = 2
ACQUAINT_REC_COL_CHENGHAO = 3
ACQUAINT_REC_COL_LEVEL = 4
ACQUAINT_REC_COL_MENPAI = 5
ACQUAINT_REC_COL_BANGPAI = 6
ACQUAINT_REC_COL_XINQING = 7
ACQUAINT_REC_COL_ONLINE = 8
ACQUAINT_REC_COL_SCENE = 9
ACQUAINT_REC_COL_MODEL = 10
ACQUAINT_REC_COL_GOOD = 11
ACQUAINT_REC_COL_BAD = 12
ACQUAINT_REC_COL_COUNT = 13
ACQUAINT_REC_COL_LASTTIME = 14
ACQUAINT_REC_COL_THING1 = 15
ACQUAINT_REC_COL_THING2 = 16
ACQUAINT_REC_COL_THING3 = 17
ACQUAINT_REC_COL_THINGDETAIL1 = 18
ACQUAINT_REC_COL_THINGDETAIL2 = 19
ACQUAINT_REC_COL_THINGDETAIL3 = 20
PUPIL_REC_COL_NAME = 0
PUPIL_REC_COL_TYPE = 1
PUPIL_REC_COL_LEVEL = 2
PUPIL_REC_COL_DATE_BAISHI = 3
PUPIL_REC_COL_RECENT_ONLINE = 4
PUPIL_REC_COL_SHI_TU_VALUE = 5
PUPIL_REC_COL_OLSTATE = 6
PUPIL_REC_COL_GUILD = 7
JM_UID = 0
JM_NAME = 1
JM_GUILD = 2
JM_SEX = 3
JM_ROLE_INFO = 4
JM_ROLE_MODEL = 5
JM_TYPE = 6
JM_BAISHI_DATE = 7
JM_RECENT_ONLINE_DATE = 8
JM_ACTIVE_TYPE = 9
JM_OLSTATE = 10
JM_XUEWEI_COUNT = 11
JM_SHI_TU_VALUE = 12
SWORN_REC_COL_NAME = 0
SWORN_REC_COL_ONLINE = 1
NEW_TEACHER_REC_COL_NAME = 0
NEW_TEACHER_REC_COL_ONLINE = 1
function get_partner_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  if not client_player:FindProp("PartnerNamePrivate") then
    return {}
  end
  local player_name = client_player:QueryProp("PartnerNamePrivate")
  if nx_string(player_name) == "" then
    return {}
  end
  local partner_table = {}
  local record = {}
  record.player_name = player_name
  record.online = nx_int(1)
  record.self_relation = nx_int(0)
  record.target_relation = nx_int(0)
  record.character_flag = nx_int(0)
  record.character_value = nx_int(0)
  local row = -1
  if client_player:FindRecord(FRIEND_REC) then
    row = client_player:FindRecordRow(FRIEND_REC, FRIEND_REC_COL_NAME, nx_widestr(record.player_name))
    if 0 <= row then
      record.online = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_ONLINE))
      record.self_relation = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_SELFFRIENDLY))
      record.target_relation = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_TARGETFRIENDLY))
      record.character_flag = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_CHARACTERFLAG))
      record.character_value = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_CHARACTERVALUE))
      record.revenge_point = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_REVENGEPOINT))
    end
  end
  if row < 0 and client_player:FindRecord(BUDDY_REC) then
    row = client_player:FindRecordRow(BUDDY_REC, BUDDY_REC_COL_NAME, nx_widestr(record.player_name))
    if 0 <= row then
      record.online = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_ONLINE))
      record.self_relation = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_SELFFRIENDLY))
      record.target_relation = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_TARGETFRIENDLY))
      record.character_flag = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_CHARACTERFLAG))
      record.character_value = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_CHARACTERVALUE))
      record.revenge_point = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_REVENGEPOINT))
    end
  end
  table.insert(partner_table, record)
  return partner_table
end
function get_friend_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  if not client_player:FindRecord(FRIEND_REC) then
    return {}
  end
  local friend_table = {}
  local rows = client_player:GetRecordRows(FRIEND_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(FRIEND_REC, i, FRIEND_REC_COL_NAME)
    record.online = nx_int(client_player:QueryRecord(FRIEND_REC, i, FRIEND_REC_COL_ONLINE))
    record.self_relation = nx_int(client_player:QueryRecord(FRIEND_REC, i, FRIEND_REC_COL_SELFFRIENDLY))
    record.target_relation = nx_int(client_player:QueryRecord(FRIEND_REC, i, FRIEND_REC_COL_TARGETFRIENDLY))
    record.character_flag = nx_int(client_player:QueryRecord(FRIEND_REC, i, FRIEND_REC_COL_CHARACTERFLAG))
    record.character_value = nx_int(client_player:QueryRecord(FRIEND_REC, i, FRIEND_REC_COL_CHARACTERVALUE))
    record.revenge_point = nx_int(client_player:QueryRecord(FRIEND_REC, i, FRIEND_REC_COL_REVENGEPOINT))
    table.insert(friend_table, record)
  end
  return friend_table
end
function get_buddy_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  if not client_player:FindRecord(BUDDY_REC) then
    return {}
  end
  local buddy_table = {}
  local rows = client_player:GetRecordRows(BUDDY_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(BUDDY_REC, i, BUDDY_REC_COL_NAME)
    record.online = nx_int(client_player:QueryRecord(BUDDY_REC, i, BUDDY_REC_COL_ONLINE))
    record.self_relation = nx_int(client_player:QueryRecord(BUDDY_REC, i, BUDDY_REC_COL_SELFFRIENDLY))
    record.target_relation = nx_int(client_player:QueryRecord(BUDDY_REC, i, BUDDY_REC_COL_TARGETFRIENDLY))
    record.character_flag = nx_int(client_player:QueryRecord(BUDDY_REC, i, BUDDY_REC_COL_CHARACTERFLAG))
    record.character_value = nx_int(client_player:QueryRecord(BUDDY_REC, i, BUDDY_REC_COL_CHARACTERVALUE))
    record.revenge_point = nx_int(client_player:QueryRecord(BUDDY_REC, i, BUDDY_REC_COL_REVENGEPOINT))
    table.insert(buddy_table, record)
  end
  return buddy_table
end
function get_attention_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  if not client_player:FindRecord(ATTENTION_REC) then
    return {}
  end
  local attention_table = {}
  local rows = client_player:GetRecordRows(ATTENTION_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(ATTENTION_REC, i, ATTENTION_REC_COL_NAME)
    record.online = nx_int(client_player:QueryRecord(ATTENTION_REC, i, ATTENTION_REC_COL_ONLINE))
    record.self_relation = nx_int(0)
    record.target_relation = nx_int(0)
    record.character_flag = nx_int(0)
    record.character_value = nx_int(0)
    record.revenge_point = nx_int(0)
    table.insert(attention_table, record)
  end
  return attention_table
end
function get_acquaint_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  if not client_player:FindRecord(ACQUAINT_REC) then
    return {}
  end
  local acquaint_table = {}
  local rows = client_player:GetRecordRows(ACQUAINT_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(ACQUAINT_REC, i, ACQUAINT_REC_COL_NAME)
    record.online = nx_int(client_player:QueryRecord(ACQUAINT_REC, i, ACQUAINT_REC_COL_ONLINE))
    record.self_relation = nx_int(0)
    record.target_relation = nx_int(0)
    record.character_flag = nx_int(0)
    record.character_value = nx_int(0)
    record.revenge_point = nx_int(0)
    table.insert(acquaint_table, record)
  end
  return acquaint_table
end
function get_enemy_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  if not client_player:FindRecord(ENEMY_REC) then
    return {}
  end
  local enemy_table = {}
  local rows = client_player:GetRecordRows(ENEMY_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(ENEMY_REC, i, ENEMY_REC_COL_NAME)
    record.online = nx_int(client_player:QueryRecord(ENEMY_REC, i, ENEMY_REC_COL_ONLINE))
    record.self_relation = nx_int(client_player:QueryRecord(ENEMY_REC, i, ENEMY_REC_COL_SELFENMITY))
    record.target_relation = nx_int(client_player:QueryRecord(ENEMY_REC, i, ENEMY_REC_COL_TARGETENMITY))
    record.character_flag = nx_int(client_player:QueryRecord(ENEMY_REC, i, ENEMY_REC_COL_CHARACTERFLAG))
    record.character_value = nx_int(client_player:QueryRecord(ENEMY_REC, i, ENEMY_REC_COL_CHARACTERVALUE))
    record.revenge_point = nx_int(client_player:QueryRecord(ENEMY_REC, i, ENEMY_REC_COL_REVENGEPOINT))
    table.insert(enemy_table, record)
  end
  return enemy_table
end
function get_blood_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  if not client_player:FindRecord(BLOOD_REC) then
    return {}
  end
  local blood_table = {}
  local rows = client_player:GetRecordRows(BLOOD_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(BLOOD_REC, i, BLOOD_REC_COL_NAME)
    record.online = nx_int(client_player:QueryRecord(BLOOD_REC, i, BLOOD_REC_COL_ONLINE))
    record.self_relation = nx_int(client_player:QueryRecord(BLOOD_REC, i, BLOOD_REC_COL_SELFENMITY))
    record.target_relation = nx_int(client_player:QueryRecord(BLOOD_REC, i, BLOOD_REC_COL_TARGETENMITY))
    record.character_flag = nx_int(client_player:QueryRecord(BLOOD_REC, i, BLOOD_REC_COL_CHARACTERFLAG))
    record.character_value = nx_int(client_player:QueryRecord(BLOOD_REC, i, BLOOD_REC_COL_CHARACTERVALUE))
    record.revenge_point = nx_int(client_player:QueryRecord(BLOOD_REC, i, BLOOD_REC_COL_REVENGEPOINT))
    table.insert(blood_table, record)
  end
  return blood_table
end
function get_filter_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  if not client_player:FindRecord(FILTER_REC) then
    return {}
  end
  local filter_table = {}
  local rows = client_player:GetRecordRows(FILTER_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(FILTER_REC, i, FILTER_REC_COL_NAME)
    record.online = 1
    record.self_relation = nx_int(0)
    record.target_relation = nx_int(0)
    record.character_flag = nx_int(0)
    record.character_value = nx_int(0)
    record.revenge_point = nx_int(0)
    table.insert(filter_table, record)
  end
  return filter_table
end
function get_filter_native_table()
  local filter_native_table = {}
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return {}
  end
  local res = karmamgr:GetFilterNative()
  for i = 1, table.getn(res) do
    local record = {}
    record.player_name = res[i]
    record.online = 1
    record.self_relation = nx_int(0)
    record.target_relation = nx_int(0)
    record.character_flag = nx_int(0)
    record.character_value = nx_int(0)
    record.revenge_point = nx_int(0)
    table.insert(filter_native_table, record)
  end
  return filter_native_table
end
function get_pupil_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  local pupil_table = {}
  local rows = client_player:GetRecordRows(PUPIL_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(PUPIL_REC, i, PUPIL_REC_COL_NAME)
    record.online = client_player:QueryRecord(PUPIL_REC, i, PUPIL_REC_COL_OLSTATE)
    record.self_relation = nx_int(0)
    record.target_relation = nx_int(0)
    record.character_flag = nx_int(0)
    record.character_value = nx_int(0)
    record.revenge_point = nx_int(0)
    table.insert(pupil_table, record)
  end
  rows = client_player:GetRecordRows(PUPIL_JINGMAI_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(PUPIL_JINGMAI_REC, i, JM_NAME)
    record.online = client_player:QueryRecord(PUPIL_JINGMAI_REC, i, JM_OLSTATE)
    record.self_relation = nx_int(0)
    record.target_relation = nx_int(0)
    record.character_flag = nx_int(0)
    record.character_value = nx_int(0)
    record.revenge_point = nx_int(0)
    table.insert(pupil_table, record)
  end
  return pupil_table
end
function get_sworn_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  local sworn_table = {}
  local rows = client_player:GetRecordRows(SWORN_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(SWORN_REC, i, SWORN_REC_COL_NAME)
    record.online = client_player:QueryRecord(SWORN_REC, i, SWORN_REC_COL_ONLINE)
    if nx_int(record.online) == nx_int(0) then
      record.online = 1
    else
      record.online = 0
    end
    record.self_relation = nx_int(0)
    record.target_relation = nx_int(0)
    record.character_flag = nx_int(0)
    record.character_value = nx_int(0)
    record.revenge_point = nx_int(0)
    local row = -1
    if client_player:FindRecord(FRIEND_REC) then
      row = client_player:FindRecordRow(FRIEND_REC, FRIEND_REC_COL_NAME, nx_widestr(record.player_name))
      if 0 <= row then
        record.online = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_ONLINE))
        record.self_relation = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_SELFFRIENDLY))
        record.target_relation = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_TARGETFRIENDLY))
        record.character_flag = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_CHARACTERFLAG))
        record.character_value = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_CHARACTERVALUE))
        record.revenge_point = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_REVENGEPOINT))
      end
    end
    if row < 0 and client_player:FindRecord(BUDDY_REC) then
      row = client_player:FindRecordRow(BUDDY_REC, BUDDY_REC_COL_NAME, nx_widestr(record.player_name))
      if 0 <= row then
        record.online = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_ONLINE))
        record.self_relation = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_SELFFRIENDLY))
        record.target_relation = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_TARGETFRIENDLY))
        record.character_flag = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_CHARACTERFLAG))
        record.character_value = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_CHARACTERVALUE))
        record.revenge_point = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_REVENGEPOINT))
      end
    end
    table.insert(sworn_table, record)
  end
  return sworn_table
end
function get_new_teacher_table()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return {}
  end
  local new_teacher_table = {}
  local rows = client_player:GetRecordRows(NEW_TEACHER_REC)
  for i = 0, rows - 1 do
    local record = {}
    record.player_name = client_player:QueryRecord(NEW_TEACHER_REC, i, SWORN_REC_COL_NAME)
    record.online = client_player:QueryRecord(NEW_TEACHER_REC, i, SWORN_REC_COL_ONLINE)
    if nx_int(record.online) == nx_int(0) then
      record.online = 1
    else
      record.online = 0
    end
    record.self_relation = nx_int(0)
    record.target_relation = nx_int(0)
    record.character_flag = nx_int(0)
    record.character_value = nx_int(0)
    record.revenge_point = nx_int(0)
    local row = -1
    if client_player:FindRecord(FRIEND_REC) then
      row = client_player:FindRecordRow(FRIEND_REC, FRIEND_REC_COL_NAME, nx_widestr(record.player_name))
      if 0 <= row then
        record.online = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_ONLINE))
        record.self_relation = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_SELFFRIENDLY))
        record.target_relation = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_TARGETFRIENDLY))
        record.character_flag = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_CHARACTERFLAG))
        record.character_value = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_CHARACTERVALUE))
        record.revenge_point = nx_int(client_player:QueryRecord(FRIEND_REC, row, FRIEND_REC_COL_REVENGEPOINT))
      end
    end
    if row < 0 and client_player:FindRecord(BUDDY_REC) then
      row = client_player:FindRecordRow(BUDDY_REC, BUDDY_REC_COL_NAME, nx_widestr(record.player_name))
      if 0 <= row then
        record.online = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_ONLINE))
        record.self_relation = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_SELFFRIENDLY))
        record.target_relation = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_TARGETFRIENDLY))
        record.character_flag = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_CHARACTERFLAG))
        record.character_value = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_CHARACTERVALUE))
        record.revenge_point = nx_int(client_player:QueryRecord(BUDDY_REC, row, BUDDY_REC_COL_REVENGEPOINT))
      end
    end
    table.insert(new_teacher_table, record)
  end
  return new_teacher_table
end
function get_npc_friend_table(type)
  local friend_table = {}
  local buddy_table = {}
  local null_table = {}
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return null_table
  end
  if not client_player:FindRecord(NPC_RELATION_REC) then
    return null_table
  end
  local cur_scene = nx_int(nx_execute("form_stage_main\\form_relation\\form_friend_list", "get_scene_id"))
  local rows = client_player:GetRecordRows(NPC_RELATION_REC)
  for i = 0, rows - 1 do
    local record_table = {}
    record_table.config = client_player:QueryRecord(NPC_RELATION_REC, i, NPC_RELATION_CONFIG)
    record_table.sceneid = nx_int(client_player:QueryRecord(NPC_RELATION_REC, i, NPC_RELATION_SCENEID))
    record_table.karma = nx_int(client_player:QueryRecord(NPC_RELATION_REC, i, NPC_RELATION_KARMA_VALUE))
    record_table.relatype = client_player:QueryRecord(NPC_RELATION_REC, i, NPC_RELATION_TYPE)
    if nx_int(record_table.relatype) == nx_int(0) then
      table.insert(friend_table, record_table)
    elseif nx_int(record_table.relatype) == nx_int(1) then
      table.insert(buddy_table, record_table)
    end
  end
  if nx_number(type) == nx_number(0) then
    return friend_table
  elseif nx_number(type) == nx_number(1) then
    return buddy_table
  else
    return null_table
  end
end
function get_npc_attention_table()
  local attention_table = {}
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return attention_table
  end
  if not client_player:FindRecord(NPC_ATTENTION_REC) then
    return attention_table
  end
  local cur_scene = nx_int(nx_execute("form_stage_main\\form_relation\\form_friend_list", "get_scene_id"))
  local rows = client_player:GetRecordRows(NPC_ATTENTION_REC)
  for i = 0, rows - 1 do
    local record_table = {}
    record_table.config = client_player:QueryRecord(NPC_ATTENTION_REC, i, NPC_RELATION_CONFIG)
    record_table.sceneid = nx_int(client_player:QueryRecord(NPC_ATTENTION_REC, i, NPC_RELATION_SCENEID))
    record_table.karma = getkarmavalue(record_table.config)
    table.insert(attention_table, record_table)
  end
  return attention_table
end
function getkarmavalue(npcid)
  local karma = -100001
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return karma
  end
  if not client_player:FindRecord(NPC_RELATION_REC) then
    return karma
  end
  local row = client_player:FindRecordRow(NPC_RELATION_REC, NPC_RELATION_CONFIG, npcid)
  if 0 <= row then
    karma = nx_int(client_player:QueryRecord(NPC_RELATION_REC, row, NPC_RELATION_KARMA_VALUE))
  end
  return karma
end
function is_partner_player(player_name)
  local partner_table = get_partner_table()
  for i = 1, table.getn(partner_table) do
    local partner = partner_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(partner.player_name)) then
      return true
    end
  end
  return false
end
function is_friend_player(player_name)
  local friend_table = get_friend_table()
  for i = 1, table.getn(friend_table) do
    local friend = friend_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(friend.player_name)) then
      return true
    end
  end
  return false
end
function is_buddy_player(player_name)
  local buddy_table = get_buddy_table()
  for i = 1, table.getn(buddy_table) do
    local buddy = buddy_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(buddy.player_name)) then
      return true
    end
  end
  return false
end
function is_attention_player(player_name)
  local attention_table = get_attention_table()
  for i = 1, table.getn(attention_table) do
    local attention = attention_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(attention.player_name)) then
      return true
    end
  end
  return false
end
function is_acquaint_player(player_name)
  local acquaint_table = get_acquaint_table()
  for i = 1, table.getn(acquaint_table) do
    local acquaint = acquaint_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(acquaint.player_name)) then
      return true
    end
  end
  return false
end
function is_enemy_player(player_name)
  local enemy_table = get_enemy_table()
  for i = 1, table.getn(enemy_table) do
    local enemy = enemy_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(enemy.player_name)) then
      return true
    end
  end
  return false
end
function is_blood_player(player_name)
  local blood_table = get_blood_table()
  for i = 1, table.getn(blood_table) do
    local blood = blood_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(blood.player_name)) then
      return true
    end
  end
  return false
end
function is_pupil_player(player_name)
  local pupil_table = get_pupil_table()
  for i = 1, table.getn(pupil_table) do
    local pupil = pupil_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(pupil.player_name)) then
      return false
    end
  end
end
function is_filter_player(player_name)
  local filter_table = get_filter_table()
  for i = 1, table.getn(filter_table) do
    local filter = filter_table[i]
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(filter.player_name)) then
      return true
    end
  end
  return false
end
function is_teacher()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return false
  end
  local shitu_flag = client_player:QueryProp("NewShiTuFlag")
  return shitu_flag == 1
end
function is_teacher_of(other_name)
  if not is_teacher() then
    return false
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindRecord(NEW_TEACHER_REC) then
    return false
  end
  local row = client_player:FindRecordRow(NEW_TEACHER_REC, NEW_TEACHER_REC_COL_NAME, nx_widestr(other_name))
  return 0 <= row
end
function is_strangeness(player_name)
  if is_friend_player(player_name) then
    return false
  end
  if is_buddy_player(player_name) then
    return false
  end
  if is_pupil_player(player_name) then
    return false
  end
  return true
end
function is_limit_frequent_send(ms)
  ms = ms or 500
  local cur_time = nx_function("ext_get_tickcount")
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return true
  end
  if nx_find_custom(client_player, "lastsendchattick") then
    local tick = nx_int(cur_time) - nx_int(client_player.lastsendchattick)
    if nx_int(tick) >= nx_int(0) and nx_int(tick) <= nx_int(ms) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "7118")
      return true
    end
  end
  client_player.lastsendchattick = cur_time
  return false
end
function get_shane_image(character_flag, character_value)
  local ArrImageXia = {
    [0] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia.png",
    [1] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia_2.png",
    [2] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia_3_01.png",
    [3] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia_3_02.png",
    [4] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia_3_03.png",
    [5] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia_3_04.png",
    [6] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia_3_05.png"
  }
  local ArrImageE = {
    [0] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e.png",
    [1] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e_2.png",
    [2] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e_3_01.png",
    [3] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e_3_02.png",
    [4] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e_3_03.png",
    [5] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e_3_04.png",
    [6] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e_3_05.png"
  }
  local ArrImageKuang = {
    [0] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang.png",
    [1] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang_2.png",
    [2] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang_3_01.png",
    [3] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang_3_02.png",
    [4] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang_3_03.png",
    [5] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang_3_04.png",
    [6] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang_3_05.png"
  }
  local ArrImageXie = {
    [0] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie.png",
    [1] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie_2.png",
    [2] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie_3_01.png",
    [3] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie_3_02.png",
    [4] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie_3_03.png",
    [5] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie_3_04.png",
    [6] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie_3_05.png"
  }
  character_flag = nx_number(character_flag)
  character_value = nx_number(character_value)
  local level = 0
  if character_value <= 899 then
    level = 0
  elseif 900 <= character_value and character_value <= 9999 then
    level = 1
  elseif 10000 <= character_value and character_value <= 19999 then
    level = 2
  elseif 20000 <= character_value and character_value <= 29999 then
    level = 3
  elseif 30000 <= character_value and character_value <= 39999 then
    level = 4
  elseif 40000 <= character_value and character_value < 50000 then
    level = 5
  elseif character_value == 50000 then
    level = 6
  else
    return ""
  end
  if character_flag == 0 then
    return "gui\\language\\ChineseS\\sns_new\\mark\\mark_chu.png"
  elseif character_flag == 1 then
    return ArrImageXia[level]
  elseif character_flag == 2 then
    return ArrImageE[level]
  elseif character_flag == 3 then
    return ArrImageKuang[level]
  elseif character_flag == 4 then
    return ArrImageXie[level]
  end
  return ""
end
function load_revenge_room_config()
  local revenge_table = {}
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_Revenge.ini")
  if not nx_is_valid(ini) then
    return revenge_table
  end
  local sec_index = ini:FindSectionIndex("HeadValue")
  if nx_int(sec_index) < nx_int(0) then
    return revenge_table
  end
  local RoomData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, table.getn(RoomData) do
    local stepData = util_split_string(RoomData[i], "/")
    if table.getn(stepData) >= 2 then
      local item = {}
      item.room_name = nx_string(stepData[1])
      item.revenge_value = nx_int(stepData[2])
      table.insert(revenge_table, item)
    end
  end
  return revenge_table
end
function get_revenge_room_name(revenge)
  if nx_int(revenge) < nx_int(0) then
    return ""
  end
  local room_name = ""
  local revenge_table = load_revenge_room_config()
  for i = 1, table.getn(revenge_table) do
    local item = revenge_table[i]
    if nx_int(revenge) >= nx_int(item.revenge_value) then
      room_name = nx_string(item.room_name)
    end
  end
  return room_name
end
function get_record_path_name()
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local self_name = client_player:QueryProp("Name")
  local file_name = util_encrypt_string("record_" .. nx_string(self_name))
  local full_filename = util_get_account_path() .. file_name .. ".xml"
  return full_filename
end
function create_chat_record_doc()
  local xml_doc = nx_create("XmlDocument")
  if not nx_is_valid(xml_doc) then
    return nil
  end
  local full_filename = get_record_path_name()
  if not nx_find_method(xml_doc, "LoadFile") then
    return nil
  end
  if not xml_doc:LoadFile(full_filename) then
    local root = xml_doc:CreateRootElement("Records")
    if not xml_doc:SaveFile(full_filename) then
      nx_destroy(xml_doc)
      return nil
    end
  end
  return xml_doc
end
function get_record_doc()
  local form_light = nx_value("form_stage_main\\form_chat_system\\form_chat_light")
  if not nx_is_valid(form_light) then
    return nil
  end
  if not nx_find_custom(form_light, "xml_doc") or not nx_is_valid(form_light.xml_doc) then
    form_light.xml_doc = create_chat_record_doc()
  end
  return form_light.xml_doc
end
function get_chat_record(xml_doc, target_name)
  local record = {}
  if not nx_is_valid(xml_doc) then
    return record
  end
  local xmlroot = xml_doc.RootElement
  if not nx_is_valid(xmlroot) then
    return record
  end
  local Record_List = xmlroot:GetChildList("Record")
  local Record
  for i = 1, table.getn(Record_List) do
    local child = Record_List[i]
    local name = util_dencrypt_string(child:QueryAttr("name"))
    if nx_string(target_name) == nx_string(name) then
      Record = child
      break
    end
  end
  if Record == nil then
    return record
  end
  local Item_List = Record:GetChildList("Item")
  for i = 1, table.getn(Item_List) do
    local child = Item_List[i]
    local item = {}
    item.name = util_dencrypt_string(child:QueryAttr("name"))
    item.content = util_dencrypt_string(child:QueryAttr("content"))
    item.time = util_dencrypt_string(child:QueryAttr("time"))
    table.insert(record, item)
  end
  return record
end
function clear_all_chat_record(xml_doc)
  if not nx_is_valid(xml_doc) then
    return
  end
  local xmlroot = xml_doc.RootElement
  if not nx_is_valid(xmlroot) then
    return
  end
  local Record_List = xmlroot:GetChildList("Record")
  local count = table.getn(Record_List)
  for i = count, 1, -1 do
    xmlroot:RemoveChild(Record_List[i])
  end
  local full_filename = get_record_path_name()
  xml_doc:SaveFile(full_filename)
end
function delete_chat_record(xml_doc, target_name)
  if not nx_is_valid(xml_doc) then
    return
  end
  local xmlroot = xml_doc.RootElement
  if not nx_is_valid(xmlroot) then
    return
  end
  local Record_List = xmlroot:GetChildList("Record")
  local Record
  for i = 1, table.getn(Record_List) do
    local child = Record_List[i]
    local name = util_dencrypt_string(child:QueryAttr("name"))
    if nx_string(target_name) == nx_string(name) then
      Record = child
      break
    end
  end
  if nx_is_valid(Record) then
    xmlroot:RemoveChild(Record)
    local full_filename = get_record_path_name()
    xml_doc:SaveFile(full_filename)
  end
end
function write_chat_record(xml_doc, recordName, senderName, chat_content, chat_type, chat_time)
  if not nx_is_valid(xml_doc) then
    return
  end
  local full_filename = get_record_path_name()
  if not nx_file_exists(full_filename) then
    clear_all_chat_record(xml_doc)
  end
  if nx_int(chat_type) ~= nx_int(0) then
    return
  end
  local xmlroot = xml_doc.RootElement
  if not nx_is_valid(xmlroot) then
    return
  end
  local encode_flag = util_encrypt_string(recordName)
  local Record_List = xmlroot:GetChildList("Record")
  local Record
  for i = 1, table.getn(Record_List) do
    local child = Record_List[i]
    local name = child:QueryAttr("name")
    if nx_string(name) == nx_string(encode_flag) then
      Record = child
      break
    end
  end
  if Record == nil then
    Record = xmlroot:CreateChild("Record")
    Record:SetAttr("name", nx_string(encode_flag))
  end
  local Record_Item = Record:CreateChild("Item")
  Record_Item:SetAttr("name", nx_string(util_encrypt_string(senderName)))
  Record_Item:SetAttr("time", nx_string(util_encrypt_string(chat_time)))
  Record_Item:SetAttr("content", nx_string(util_encrypt_string(chat_content)))
  xml_doc:SaveFile(full_filename)
end
