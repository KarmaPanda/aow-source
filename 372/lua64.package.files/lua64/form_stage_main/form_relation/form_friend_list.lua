require("util_gui")
require("util_functions")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
local FRIEND_REC = "rec_friend"
local BUDDY_REC = "rec_buddy"
local BROTHER_REC = "rec_brother"
local ENEMY_REC = "rec_enemy"
local BLOOD_REC = "rec_blood"
local FILTER_REC = "rec_filter"
local ATTENTION_REC = "rec_attention"
local FANS_REC = "rec_fans"
local ACQUAINT_REC = "rec_acquaint"
local SWORN_REC = "SwornRelationRec"
local FRIEND_REC_UID = 0
local FRIEND_REC_NAME = 1
local FRIEND_REC_PHOTO = 2
local FRIEND_REC_CHENGHAO = 3
local FRIEND_REC_LEVEL = 4
local FRIEND_REC_MENPAI = 5
local FRIEND_REC_BANGPAI = 6
local FRIEND_REC_XINQING = 7
local FRIEND_REC_ONLINE = 8
local FRIEND_REC_SCENE = 9
local FRIEND_REC_MODEL = 10
local FRIEND_REC_SELFFRIEND = 11
local FRIEND_REC_TARGETFRIEND = 12
local FRIEND_REC_CHARFLAG = 13
local FRIEND_REC_CAHRVALUE = 14
local ACQUAINT_REC_UID = 0
local ACQUAINT_REC_NAME = 1
local ACQUAINT_REC_PHOTO = 2
local ACQUAINT_REC_CHENGHAO = 3
local ACQUAINT_REC_LEVEL = 4
local ACQUAINT_REC_MENPAI = 5
local ACQUAINT_REC_BANGPAI = 6
local ACQUAINT_REC_XINQING = 7
local ACQUAINT_REC_ONLINE = 8
local ACQUAINT_REC_SCENE = 9
local ACQUAINT_REC_MODEL = 10
local ACQUAINT_REC_GOOD = 11
local ACQUAINT_REC_BAD = 12
local ACQUAINT_COUNT = 13
local ACQUAINT_LASTTIME = 14
local ACQUAINT_THING1 = 15
local ACQUAINT_THING2 = 16
local ACQUAINT_THING3 = 17
local ACQUAINT_DETAIL1 = 18
local ACQUAINT_DETAIL2 = 19
local ACQUAINT_DETAIL3 = 20
local ENEMY_REC_UID = 0
local ENEMY_REC_NAME = 1
local ENEMY_REC_PHOTO = 2
local ENEMY_REC_CHENGHAO = 3
local ENEMY_REC_LEVEL = 4
local ENEMY_REC_MENPAI = 5
local ENEMY_REC_BANGPAI = 6
local ENEMY_REC_XINQING = 7
local ENEMY_REC_ONLINE = 8
local ENEMY_REC_SCENE = 9
local ENEMY_REC_MODEL = 10
local ENEMY_REC_SELFFRIEND = 11
local ENEMY_REC_TARGETFRIEND = 12
local ENEMY_REC_CHARFLAG = 13
local ENEMY_REC_CAHRVALUE = 14
local FANS_REC_UID = 0
local FANS_REC_NAME = 1
local FANS_REC_PHOTO = 2
local FANS_REC_CHENGHAO = 3
local FANS_REC_LEVEL = 4
local FANS_REC_MENPAI = 5
local FANS_REC_BANGPAI = 6
local FANS_REC_XINQING = 7
local FILTER_REC_UID = 0
local FILTER_REC_NAME = 1
local FILTER_REC_PHOTO = 2
local SWORN_REC_COL_NAME = 0
local SWORN_REC_COL_ONLINE = 1
local OFFLINE_STATE_ERROR = -1
local OFFLINE_STATE_OFFLINE = -1
local OFFLINE_STATE_OFFLINE_JOB = 106
local OFFLINE_STATE_OFFLINE_TRAINING = 109
local OFFLINE_STATE_OFFLINE_STALL = 111
local OFFLINE_STATE_ONLINE = 0
local OFFLINE_STATE_NONE = -1
local SUB_MSG_RELATION_ADD_APPLY = 1
local SUB_MSG_RELATION_ADD_CONFIRM = 2
local SUB_MSG_RELATION_ADD_CANCEL = 3
local SUB_MSG_RELATION_ADD_SELF = 4
local SUB_MSG_RELATION_ADD_BOTH = 5
local SUB_MSG_RELATION_REMOVE_SELF = 6
local SUB_MSG_RELATION_REMOVE_BOTH = 7
local SUB_MSG_RELATION_ATTENTION_ADD = 8
local SUB_MSG_RELATION_ATTENTION_REMOVE = 9
local SUB_MSG_RELATION_ADD_ENEMY = 10
local RELATION_TYPE_FRIEND = 0
local RELATION_TYPE_BUDDY = 1
local RELATION_TYPE_BROTHER = 2
local RELATION_TYPE_ENEMY = 3
local RELATION_TYPE_BLOOD = 4
local RELATION_TYPE_ATTENTION = 5
local RELATION_TYPE_ACQUAINT = 6
local RELATION_TYPE_FANS = 7
local RELATION_TYPE_FLITER = 8
local RELATION_TYPE_STRANGER = 9
local RELATION_TYPE_TEACHER_PUPIL = 10
local RELATION_TYPE_SWORN = 11
local FRIEND_TYPE = 0
local BUDDY_TYPE = 1
local BROTHER_TYPE = 2
local ENEMY_TYPE = 3
local BLOOD_TYPE = 4
local GUANZHU_TYPE = 5
local ACQUAINT_TYPE = 6
local FANS_TYPE = 7
local FILTER_TYPE = 8
local TEACHER_PUPIL_TYPE = 9
local NPC_FRIEND_TYPE = 101
local NPC_BUDDY_TYPE = 102
local NPC_ATTENTION_TYPE = 103
local PAGESIZE = 6
local man_player_backimage = "gui\\mainform\\icon_skill.png"
local woman_player_backimage = "gui\\mainform\\icon_skill.png"
local offline_player_backimage = "gui\\mainform\\icon_skill.png"
local online_player_backimage = "gui\\mainform\\icon_skill.png"
local ProgressImage = "gui\\mainform\\role\\pbr_hp.png"
local man_fore_color = "255,255,255,255"
local woman_fore_color = "255,255,255,255"
local offline_fore_color = "255,255,255,255"
local online_fore_color = "255,255,255,255"
local menpai_fore_color = "255,0,0,0"
local dagong_backimage = "gui\\language\\ChineseS\\sns\\timework.png"
local tesu_backimage = "gui\\language\\ChineseS\\sns\\special.png"
local stall_backimage = "gui\\language\\ChineseS\\sns\\stall.png"
local xiulian_backimage = "gui\\language\\ChineseS\\sns\\xiulian.png"
local offline_backimage = "gui\\language\\ChineseS\\sns\\btn_offline1_out.png"
function main_form_init(self)
  self.Fixed = false
  self.PageNo = 1
  self.MaxPage = 0
  self.PlayerType = FRIEND_TYPE
  self.relation = 0
  return 1
end
function main_form_open(self)
  local form = self
  local gui = nx_value("gui")
  local VScrollBar = form.player_list.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  form.mltbox_friendinfo:Clear()
  form.mltbox_friendinfo.Width = 180
  form.mltbox_friendinfo.Height = 90
  form.mltbox_friendinfo.Left = 0
  form.mltbox_friendinfo.LineHeight = 12
  form.mltbox_friendinfo.Top = 60
  form.mltbox_friendinfo.ViewRect = "12,10,160,160"
  form.mltbox_friendinfo.BackImage = "gui\\special\\sns_new\\bg_relation.png"
  form.mltbox_friendinfo.LineColor = "0,0,0,0"
  form.mltbox_friendinfo.Font = "font_sns_event"
  form.mltbox_friendinfo.DrawMode = "FitWindow"
  form.mltbox_friendinfo:SetHtmlItemSelectable(nx_int(0), false)
  form.mltbox_friendinfo:SetHtmlItemSelectable(nx_int(1), false)
  form.mltbox_friendinfo.Visible = false
  local databinder = nx_value("data_binder")
  databinder:AddTableBind(FRIEND_REC, self, "form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist_changed")
  databinder:AddTableBind(BUDDY_REC, self, "form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist_changed")
  databinder:AddTableBind(ENEMY_REC, self, "form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist_changed")
  databinder:AddTableBind(BLOOD_REC, self, "form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist_changed")
  databinder:AddTableBind(FILTER_REC, self, "form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist_changed")
  databinder:AddTableBind(ATTENTION_REC, self, "form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist_changed")
  databinder:AddTableBind(ACQUAINT_REC, self, "form_stage_main\\form_relation\\form_friend_list", "refresh_playerlist_changed")
  form.ipt_search_name.Text = nx_widestr(gui.TextManager:GetText("ui_sns_search_chazhao_defulttext"))
  return 1
end
function main_form_close(self)
  self.Visible = false
  nx_destroy(self)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function menu_game_init(menu)
  menu.BackImage = "gui\\common\\form_back\\bg_menu.png"
  menu.DrawMode = "Expand"
  menu.ItemHeight = 20
  menu.LeftBar = false
  menu.LeftBarWidth = 20
  menu.Width = 140
  menu.Font = "Default"
  menu.ForeColor = "255,225,204,20"
  menu.SelectBackColor = "255,160,36,18"
  menu.SelectBorderColor = "255,0,0,0"
  return 1
end
function refresh_playerlist(form, select)
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    return
  end
  if form.PlayerType == FRIEND_TYPE then
    form.player_list:DeleteAll()
    if select == nil then
      select = 0
    end
    on_friend_changed(form, client_role, select)
  elseif form.PlayerType == BUDDY_TYPE then
    form.player_list:DeleteAll()
    if select == nil then
      select = 0
    end
    on_buddy_changed(form, client_role, select)
  elseif form.PlayerType == BROTHER_TYPE then
    form.player_list:DeleteAll()
    if select == nil then
      select = 0
    end
    on_brother_changed(form, client_role, select)
  elseif form.PlayerType == ENEMY_TYPE then
    form.player_list:DeleteAll()
    if select == nil then
      select = 1
    end
    on_enemy_changed(form, client_role, select)
  elseif form.PlayerType == BLOOD_TYPE then
    form.player_list:DeleteAll()
    if select == nil then
      select = 1
    end
    on_blood_changed(form, client_role, select)
  elseif form.PlayerType == FILTER_TYPE then
    form.player_list:DeleteAll()
    if select == nil then
      select = 1
    end
    on_black_changed(form, client_role, select)
  elseif form.PlayerType == GUANZHU_TYPE then
    form.player_list:DeleteAll()
    if select == nil then
      select = 0
    end
    on_guanzhu_changed(form, client_role, select)
  elseif form.PlayerType == ACQUAINT_TYPE then
    form.player_list:DeleteAll()
    if select == nil then
      select = 1
    end
    on_acquaint_changed(form, client_role, select)
  elseif form.PlayerType == FANS_TYPE then
    form.player_list:DeleteAll()
    on_fans_changed(form, client_role, select)
  elseif form.PlayerType == TEACHER_PUPIL_TYPE then
    form.player_list:DeleteAll()
    on_shixiongdi_changed(form, client_role, select)
  elseif form.PlayerType == NPC_FRIEND_TYPE then
    form.player_list:DeleteAll()
    show_npc_relation(form, form.relation)
  elseif form.PlayerType == NPC_BUDDY_TYPE then
    form.player_list:DeleteAll()
    show_npc_relation(form, form.relation)
  elseif form.PlayerType == NPC_ATTENTION_TYPE then
    form.player_list:DeleteAll()
    show_npc_relation(form, form.relation)
  end
end
function refresh_playerlist_changed(form, recordname, optype, row, clomn)
  local form_relation = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form_relation) and form_relation.rbtn_fujin.Checked then
    return
  end
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form_relationship) then
    return
  end
  if nx_find_custom(form_relationship, "CheckPlayerName") then
    form_relationship.CheckPlayerName = ""
  end
  menu_close_click()
  refresh_playerlist(form)
  form.player_list.IsEditMode = false
  form.player_list:ResetChildrenYPos()
  if nx_int(row) < nx_int(0) then
    return
  end
  local relation_type = -1
  if nx_string(recordname) == nx_string(FRIEND_REC) then
    relation_type = RELATION_TYPE_FRIEND
  elseif nx_string(recordname) == nx_string(BUDDY_REC) then
    relation_type = RELATION_TYPE_BUDDY
  elseif nx_string(recordname) == nx_string(BROTHER_REC) then
    relation_type = RELATION_TYPE_BROTHER
  elseif nx_string(recordname) == nx_string(ENEMY_REC) then
    relation_type = RELATION_TYPE_ENEMY
  elseif nx_string(recordname) == nx_string(BLOOD_REC) then
    relation_type = RELATION_TYPE_BLOOD
  elseif nx_string(recordname) == nx_string(ATTENTION_REC) then
    relation_type = RELATION_TYPE_ATTENTION
  elseif nx_string(recordname) == nx_string(ACQUAINT_REC) then
    relation_type = RELATION_TYPE_ACQUAINT
  elseif nx_string(recordname) == nx_string(TEACHER_PUPIL_REC) then
    relation_type = RELATION_TYPE_TEACHER_PUPIL
  end
  if nx_int(relation_type) < nx_int(0) then
    return
  end
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  if nx_int(clomn) == nx_int(10) and nx_string(optype) == nx_string("update") then
    if nx_string(recordname) == nx_string(FRIEND_REC) or nx_string(recordname) == nx_string(BUDDY_REC) or nx_string(recordname) == nx_string(ATTENTION_REC) or nx_string(recordname) == nx_string(TEACHER_PUPIL_REC) then
      show_friend_model_relation(recordname, relation_type)
    elseif nx_string(recordname) == nx_string(ENEMY_REC) or nx_string(recordname) == nx_string(BLOOD_REC) then
      show_enemy_model_relation(recordname, relation_type)
    end
  elseif nx_string(optype) == nx_string("del") then
  end
end
function refresh_fans_changed(form, recordname, optype, row, clomn)
  local gui = nx_value("gui")
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local rows = player:GetRecordRows(FANS_REC)
  if string.len(rows) > 3 then
    shownumberimage(form.lbl_fans_num1, 9)
    shownumberimage(form.lbl_fans_num2, 9)
    shownumberimage(form.lbl_fans_num3, 9)
  elseif string.len(rows) == 3 then
    shownumberimage(form.lbl_fans_num1, string.sub(rows, 1, 1))
    shownumberimage(form.lbl_fans_num2, string.sub(rows, 2, 2))
    shownumberimage(form.lbl_fans_num3, string.sub(rows, 3, 3))
  elseif string.len(rows) == 2 then
    shownumberimage(form.lbl_fans_num2, string.sub(rows, 1, 1))
    shownumberimage(form.lbl_fans_num3, string.sub(rows, 2, 2))
  elseif string.len(rows) == 1 then
    shownumberimage(form.lbl_fans_num3, string.sub(rows, 1, 1))
  end
end
function shownumberimage(lbl_fans_num, num)
  if nx_number(num) == nx_number(0) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\0.png"
  elseif nx_number(num) == nx_number(1) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\1.png"
  elseif nx_number(num) == nx_number(2) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\2.png"
  elseif nx_number(num) == nx_number(3) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\3.png"
  elseif nx_number(num) == nx_number(4) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\4.png"
  elseif nx_number(num) == nx_number(5) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\5.png"
  elseif nx_number(num) == nx_number(6) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\6.png"
  elseif nx_number(num) == nx_number(7) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\7.png"
  elseif nx_number(num) == nx_number(8) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\8.png"
  elseif nx_number(num) == nx_number(9) then
    lbl_fans_num.BackImage = "gui\\language\\ChineseS\\sns_new\\number\\9.png"
  end
end
function show_friend_model_relation(table_name, relation_type)
end
function show_enemy_model_relation(table_name, relation_type)
end
function show_friend_relation(form, player, table_name)
  if not player:FindRecord(table_name) then
    return
  end
  local table_rec = {}
  table.insert(table_rec, table_name)
  if nx_string(table_name) == nx_string(FRIEND_REC) then
    table.insert(table_rec, BUDDY_REC)
  elseif nx_string(table_name) == nx_string(ENEMY_REC) then
    table.insert(table_rec, BLOOD_REC)
  end
  for index = 1, table.getn(table_rec) do
    table_name = table_rec[index]
    local rows = player:GetRecordRows(table_name)
    for i = 0, rows - 1 do
      local index = i
      local uid = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_UID))
      local player_name = nx_widestr(player:QueryRecord(table_name, index, FRIEND_REC_NAME))
      local player_icon = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_PHOTO))
      local player_menpai = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_MENPAI))
      local player_offline_state = nx_int(player:QueryRecord(table_name, index, FRIEND_REC_ONLINE))
      if nx_int(OFFLINE_STATE_ONLINE) == player_offline_state then
        local bChecked = false
        local CheckPlayerName = ""
        if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
          CheckPlayerName = form.CheckPlayerName
        end
        if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
          bChecked = true
        end
        add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
      end
    end
    for i = 0, rows - 1 do
      local index = i
      local uid = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_UID))
      local player_name = nx_widestr(player:QueryRecord(table_name, index, FRIEND_REC_NAME))
      local player_icon = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_PHOTO))
      local player_menpai = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_MENPAI))
      local player_offline_state = nx_int(player:QueryRecord(table_name, index, FRIEND_REC_ONLINE))
      if nx_int(OFFLINE_STATE_ONLINE) ~= player_offline_state then
        local bChecked = false
        local CheckPlayerName = ""
        if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
          CheckPlayerName = form.CheckPlayerName
        end
        if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
          bChecked = true
        end
        add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
      end
    end
  end
end
function show_friend_list(groupscrollbox, tablename, ...)
  local form = groupscrollbox.ParentForm
  local playerlist = arg
  local rows = table.getn(playerlist)
  if rows <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord(nx_string(tablename)) then
    return
  end
  groupscrollbox.IsEditMode = true
  for i = 1, rows do
    local playername = playerlist[i]
    local index = player:FindRecordRow(tablename, FRIEND_REC_NAME, playername)
    if 0 <= index then
      local uid = nx_string(player:QueryRecord(nx_string(tablename), index, FRIEND_REC_UID))
      local player_name = nx_widestr(player:QueryRecord(nx_string(tablename), index, FRIEND_REC_NAME))
      local player_icon = nx_string(player:QueryRecord(nx_string(tablename), index, FRIEND_REC_PHOTO))
      local player_menpai = nx_string(player:QueryRecord(nx_string(tablename), index, FRIEND_REC_MENPAI))
      local player_offline_state = nx_int(player:QueryRecord(nx_string(tablename), index, FRIEND_REC_ONLINE))
      if nx_int(OFFLINE_STATE_ONLINE) == player_offline_state then
        local bChecked = false
        local CheckPlayerName = ""
        if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
          CheckPlayerName = form.CheckPlayerName
        end
        if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
          bChecked = true
        end
        add_player(groupscrollbox, index, player_name, nx_string(tablename), player_icon, player_menpai, player_offline_state, bChecked)
      else
        local bChecked = false
        local CheckPlayerName = ""
        if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
          CheckPlayerName = form.CheckPlayerName
        end
        if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
          bChecked = true
        end
        add_player(groupscrollbox, index, player_name, nx_string(tablename), player_icon, player_menpai, player_offline_state, bChecked)
      end
    end
  end
  groupscrollbox:ResetChildrenYPos()
  groupscrollbox.IsEditMode = false
end
function show_enemy_relation(form, player, table_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, ENEMY_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_MENPAI))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, ENEMY_REC_ONLINE))
    if nx_int(OFFLINE_STATE_ONLINE) == player_offline_state then
      local bChecked = false
      local CheckPlayerName = ""
      if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
        CheckPlayerName = form.CheckPlayerName
      end
      if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
        bChecked = true
      end
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
    end
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, ENEMY_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_MENPAI))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, ENEMY_REC_ONLINE))
    if nx_int(OFFLINE_STATE_ONLINE) ~= player_offline_state then
      local bChecked = false
      local CheckPlayerName = ""
      if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
        CheckPlayerName = form.CheckPlayerName
      end
      if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
        bChecked = true
      end
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
    end
  end
end
function show_fans_relation(form, player, table_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, FANS_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, FANS_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, FANS_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, FANS_REC_MENPAI))
    local player_offline_state = 0
    local bChecked = false
    local CheckPlayerName = ""
    if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
      CheckPlayerName = form.CheckPlayerName
    end
    if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
      bChecked = true
    end
    add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
  end
end
function show_shixiongdi_relation(form, player, table_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, PUPIL_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, PUPIL_REC_NAME))
    local player_menpai = nx_string(player:QueryProp("School"))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, PUPIL_REC_OLSTATE))
    local tp_sex = player:QueryRecord(table_name, index, PUPIL_REC_SEX)
    local player_icon = player:QueryRecord(table_name, index, PUPIL_REC_ROLE_PHOTO)
    if nx_string(player_icon) == nx_string("") then
      if nx_int(tp_sex) == nx_int(0) then
        player_icon = nx_resource_path() .. "icon\\players\\boy01_create.png"
      else
        player_icon = nx_resource_path() .. "icon\\players\\girl01_create.png"
      end
    end
    if nx_int(OFFLINE_STATE_ONLINE) == player_offline_state then
      local bChecked = false
      local CheckPlayerName = ""
      if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
        CheckPlayerName = form.CheckPlayerName
      end
      if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
        bChecked = true
      end
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
    end
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, PUPIL_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, PUPIL_REC_NAME))
    local player_menpai = nx_string(player:QueryProp("School"))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, PUPIL_REC_OLSTATE))
    local tp_sex = player:QueryRecord(table_name, index, PUPIL_REC_SEX)
    local player_icon = player:QueryRecord(table_name, index, PUPIL_REC_ROLE_PHOTO)
    if nx_string(player_icon) == nx_string("") then
      if nx_int(tp_sex) == nx_int(0) then
        player_icon = nx_resource_path() .. "icon\\players\\boy01_create.png"
      else
        player_icon = nx_resource_path() .. "icon\\players\\girl01_create.png"
      end
    end
    if nx_int(OFFLINE_STATE_ONLINE) ~= player_offline_state then
      local bChecked = false
      local CheckPlayerName = ""
      if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
        CheckPlayerName = form.CheckPlayerName
      end
      if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
        bChecked = true
      end
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
    end
  end
end
function show_jingmai_shixiongdi_relation(form, player, table_name)
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, PUPIL_REC_JM_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, PUPIL_REC_JM_NAME))
    local player_menpai = nx_string(player:QueryProp("School"))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, PUPIL_REC_JM_OLSTATE))
    local tp_sex = player:QueryRecord(table_name, index, PUPIL_REC_JM_SEX)
    local player_icon = player:QueryRecord(table_name, index, PUPIL_REC_JM_ROLE_PHOTO)
    if nx_string(player_icon) == nx_string("") then
      if nx_int(tp_sex) == nx_int(0) then
        player_icon = nx_resource_path() .. "icon\\players\\boy01_create.png"
      else
        player_icon = nx_resource_path() .. "icon\\players\\girl01_create.png"
      end
    end
    if nx_int(OFFLINE_STATE_ONLINE) == player_offline_state then
      local bChecked = false
      local CheckPlayerName = ""
      if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
        CheckPlayerName = form.CheckPlayerName
      end
      if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
        bChecked = true
      end
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
    end
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, PUPIL_REC_JM_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, PUPIL_REC_JM_NAME))
    local player_menpai = nx_string(player:QueryProp("School"))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, PUPIL_REC_JM_OLSTATE))
    local tp_sex = player:QueryRecord(table_name, index, PUPIL_REC_JM_SEX)
    local player_icon = player:QueryRecord(table_name, index, PUPIL_REC_JM_ROLE_PHOTO)
    if nx_string(player_icon) == nx_string("") then
      if nx_int(tp_sex) == nx_int(0) then
        player_icon = nx_resource_path() .. "icon\\players\\boy01_create.png"
      else
        player_icon = nx_resource_path() .. "icon\\players\\girl01_create.png"
      end
    end
    if nx_int(OFFLINE_STATE_ONLINE) ~= player_offline_state then
      local bChecked = false
      local CheckPlayerName = ""
      if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
        CheckPlayerName = form.CheckPlayerName
      end
      if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
        bChecked = true
      end
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state, bChecked)
    end
  end
end
function on_friend_changed(form, player, select)
  if select == 0 then
    show_friend_relation(form, player, FRIEND_REC)
  elseif select == 1 then
    show_friend_relation(form, player, FRIEND_REC)
  elseif select == 2 then
    show_npc_relation(form, form.relation)
  end
end
function on_buddy_changed(form, player, select)
  if select == 0 then
    show_friend_relation(form, player, BUDDY_REC)
  elseif select == 1 then
    show_friend_relation(form, player, BUDDY_REC)
  elseif select == 2 then
    show_npc_relation(form, form.relation)
  end
end
function on_brother_changed(form, player, select)
  if select == 0 then
    show_friend_relation(form, player, BROTHER_REC)
    show_npc_relation(form, form.relation)
  elseif select == 1 then
    show_friend_relation(form, player, BROTHER_REC)
  elseif select == 2 then
    show_npc_relation(form, form.relation)
  end
end
function on_guanzhu_changed(form, player, select)
  if select == 0 then
    show_friend_relation(form, player, ATTENTION_REC)
  elseif select == 1 then
    show_friend_relation(form, player, ATTENTION_REC)
  elseif select == 2 then
    show_npc_relation(form, form.relation)
  end
end
function on_acquaint_changed(form, player, select)
  show_friend_relation(form, player, ACQUAINT_REC)
end
function on_fans_changed(form, player, select)
  if select == 0 then
    show_friend_relation(form, player, FANS_REC)
    show_npc_relation(form, form.relation)
  elseif select == 1 then
    show_friend_relation(form, player, FANS_REC)
  elseif select == 2 then
    show_npc_relation(form, form.relation)
  end
end
function on_enemy_changed(form, player, select)
  if select == 0 then
    show_friend_relation(form, player, ENEMY_REC)
    show_npc_relation(form, form.relation)
  elseif select == 1 then
    show_friend_relation(form, player, ENEMY_REC)
  elseif select == 2 then
    show_npc_relation(form, form.relation)
  end
end
function on_blood_changed(form, player, select)
  if select == 0 then
    show_friend_relation(form, player, BLOOD_REC)
    show_npc_relation(form, form.relation)
  elseif select == 1 then
    show_friend_relation(form, player, BLOOD_REC)
  elseif select == 2 then
    show_npc_relation(form, form.relation)
  end
end
function on_shixiongdi_changed(form, player, select)
  if select == 0 then
    show_shixiongdi_relation(form, player, TEACHER_PUPIL_REC)
    show_jingmai_shixiongdi_relation(form, player, PUPIL_JINGMAI_REC)
    show_npc_relation(form, form.relation)
  elseif select == 1 then
    show_shixiongdi_relation(form, player, TEACHER_PUPIL_REC)
    show_jingmai_shixiongdi_relation(form, player, PUPIL_JINGMAI_REC)
  elseif select == 2 then
    show_npc_relation(form, form.relation)
  end
end
function on_black_changed(form, player)
  if not player:FindRecord(FILTER_REC) then
    return
  end
  local rows = player:GetRecordRows(FILTER_REC)
  if rows == 0 then
    return
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(FILTER_REC, index, FILTER_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(FILTER_REC, index, FILTER_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(FILTER_REC, index, FILTER_REC_PHOTO))
    local bChecked = false
    local CheckPlayerName = ""
    if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") then
      CheckPlayerName = form.CheckPlayerName
    end
    if CheckPlayerName ~= "" and nx_ws_equal(CheckPlayerName, player_name) then
      bChecked = true
    end
    add_player(form.player_list, index, player_name, FILTER_REC, player_icon, "", -1, bChecked)
  end
end
function check_back_selected(form, playerName)
  local itemlist = form.player_list:GetChildControlList()
  for i = 1, table.getn(itemlist) do
    local gb_player = itemlist[i]
    if nx_is_valid(gb_player) then
      if nx_ws_equal(playerName, gb_player.target) then
        gb_player.BackImage = "gui\\special\\sns\\bg_select.png"
      else
        gb_player.BackImage = ""
      end
    end
  end
end
function add_player(groupscrollbox, index, playerName, playerTable, playerIcon, playerMenPai, playerOfflineState, bChecked)
  local form = groupscrollbox.ParentForm
  local gui = nx_value("gui")
  local gb_player = gui:Create("GroupBox")
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local lb_bg = gui:Create("Label")
  lb_bg.Width = 46
  lb_bg.Height = 49
  lb_bg.Left = 9
  lb_bg.Top = 10
  if nx_int(playerOfflineState) == nx_int(OFFLINE_STATE_ONLINE) then
    lb_bg.BackImage = online_player_backimage
  else
    lb_bg.BackImage = offline_player_backimage
  end
  gb_player:Add(lb_bg)
  local lb_name = gui:Create("Label")
  lb_name.Width = 60
  lb_name.Height = 22
  lb_name.Left = 58
  lb_name.Top = 10
  lb_name.Text = nx_widestr(playerName)
  lb_name.Font = "font_sns_list"
  lb_name.Align = "Left"
  if nx_int(playerOfflineState) == nx_int(OFFLINE_STATE_ONLINE) then
    lb_name.ForeColor = online_fore_color
  else
    lb_name.ForeColor = offline_fore_color
  end
  gb_player:Add(lb_name)
  local lb_menpai = gui:Create("Label")
  lb_menpai.Width = 86
  lb_menpai.Height = 22
  lb_menpai.Left = 62
  lb_menpai.Top = 30
  lb_menpai.AutoSize = true
  lb_menpai.ForeColor = "255,119,119,119"
  local menpai = karmamgr:ParseColValue(FRIEND_REC_MENPAI, nx_string(playerMenPai))
  if nx_string(menpai) == "" then
    lb_menpai.Text = gui.TextManager:GetText("ui_task_school_null")
  else
    lb_menpai.Text = gui.TextManager:GetText(menpai)
  end
  lb_menpai.Font = "font_sns_list"
  lb_menpai.Align = "Left"
  gb_player:Add(lb_menpai)
  local lb_face = gui:Create("Label")
  lb_face.Width = 40
  lb_face.Height = 50
  lb_face.Left = 12
  lb_face.Top = 1
  lb_face.BackImage = karmamgr:ParseColValue(FRIEND_REC_PHOTO, nx_string(playerIcon))
  lb_face.DrawMode = "FitWindow"
  if playerOfflineState ~= OFFLINE_STATE_ONLINE then
    lb_face.BlendColor = "255,230,234,208"
  end
  if nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_JOB) then
    lb_face.BlendColor = "255,230,234,208"
  elseif nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_TRAINING) then
    lb_face.BlendColor = "255,230,234,208"
  elseif nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_STALL) then
    lb_face.BlendColor = "255,230,234,208"
  elseif nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE) then
    lb_face.BlendColor = "255,230,234,208"
  else
    lb_face.BlendColor = "255,255,255,255"
  end
  gb_player:Add(lb_face)
  local lb_state = gui:Create("Label")
  lb_state.Width = 31
  lb_state.Height = 19
  lb_state.Left = 10
  lb_state.Top = 40
  lb_state.DrawMode = "FitWindow"
  local lb_offline = gui:Create("Label")
  lb_offline.Width = 23
  lb_offline.Height = 24
  lb_offline.Left = 125
  lb_offline.Top = 10
  lb_offline.DrawMode = "FitWindow"
  lb_offline.BackImage = offline_backimage
  if nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_JOB) then
    lb_state.BackImage = dagong_backimage
    gb_player:Add(lb_offline)
  elseif nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_TRAINING) then
    lb_state.BackImage = xiulian_backimage
    gb_player:Add(lb_offline)
  elseif nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_STALL) then
    lb_state.BackImage = stall_backimage
    gb_player:Add(lb_offline)
  end
  gb_player:Add(lb_state)
  local lbl_friendly_show = gui:Create("Label")
  lbl_friendly_show.Width = 10
  lbl_friendly_show.Height = 10
  lbl_friendly_show.Left = lb_menpai.Left + lb_menpai.Width - 10
  lbl_friendly_show.Top = 35
  lbl_friendly_show.Transparent = false
  local lbl_friendly = gui:Create("Label")
  lbl_friendly.Width = 60
  lbl_friendly.Height = 22
  lbl_friendly.Left = lbl_friendly_show.Left + lbl_friendly_show.Width + 5
  lbl_friendly.Top = 32
  lbl_friendly.ForeColor = "255,255,255,255"
  lbl_friendly.Id = nx_widestr(playerName)
  lbl_friendly_show.Id = nx_widestr(playerName)
  if playerTable == FRIEND_REC or playerTable == BUDDY_REC then
    lbl_friendly_show.BackImage = "gui\\special\\sns_new\\icon_relation_1.png"
    lbl_friendly.Text = nx_widestr(player:QueryRecord(playerTable, index, FRIEND_REC_SELFFRIEND) + player:QueryRecord(playerTable, index, FRIEND_REC_TARGETFRIEND))
    lbl_friendly.self = nx_widestr(player:QueryRecord(playerTable, index, FRIEND_REC_SELFFRIEND))
    lbl_friendly_show.self = nx_widestr(player:QueryRecord(playerTable, index, FRIEND_REC_SELFFRIEND))
    lbl_friendly.target = nx_widestr(player:QueryRecord(playerTable, index, FRIEND_REC_TARGETFRIEND))
    lbl_friendly_show.target = nx_widestr(player:QueryRecord(playerTable, index, FRIEND_REC_TARGETFRIEND))
  elseif playerTable == ENEMY_REC or playerTable == BLOOD_REC then
    lbl_friendly_show.BackImage = "gui\\special\\sns_new\\icon_relation_2.png"
    lbl_friendly_show.AutoSize = true
    lbl_friendly.Text = nx_widestr(player:QueryRecord(playerTable, index, ENEMY_REC_SELFFRIEND) + player:QueryRecord(playerTable, index, ENEMY_REC_TARGETFRIEND))
    lbl_friendly.self = nx_widestr(player:QueryRecord(playerTable, index, ENEMY_REC_SELFFRIEND))
    lbl_friendly_show.self = nx_widestr(player:QueryRecord(playerTable, index, ENEMY_REC_SELFFRIEND))
    lbl_friendly.target = nx_widestr(player:QueryRecord(playerTable, index, ENEMY_REC_TARGETFRIEND))
    lbl_friendly_show.target = nx_widestr(player:QueryRecord(playerTable, index, ENEMY_REC_TARGETFRIEND))
  else
    lbl_friendly_show.Visible = false
    lbl_friendly.Visible = false
  end
  lbl_friendly.Font = "font_sns_figure"
  lbl_friendly.Transparent = false
  nx_bind_script(lbl_friendly, nx_script_name(form))
  nx_callback(lbl_friendly, "on_get_capture", "on_lbl_friendly_get_capture")
  nx_callback(lbl_friendly, "on_lost_capture", "on_lbl_friendly_lost_capture")
  nx_bind_script(lbl_friendly_show, nx_script_name(form))
  nx_callback(lbl_friendly_show, "on_get_capture", "on_lbl_friendly_show_get_capture")
  nx_callback(lbl_friendly_show, "on_lost_capture", "on_lbl_friendly_show_lost_capture")
  gb_player:Add(lbl_friendly)
  gb_player:Add(lbl_friendly_show)
  local lbl_character = gui:Create("Label")
  lbl_character.Width = 80
  lbl_character.Height = 22
  lbl_character.Left = lb_name.Left + 86
  lbl_character.Top = 12
  lbl_character.AutoSize = true
  lbl_character.Transparent = false
  if nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_JOB) or nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_TRAINING) or nx_number(playerOfflineState) == nx_number(OFFLINE_STATE_OFFLINE_STALL) then
    lbl_character.Visible = false
  end
  if playerTable == FRIEND_REC or playerTable == BUDDY_REC or playerTable == ATTENTION_REC then
    lbl_character.charactervalue = nx_widestr(player:QueryRecord(playerTable, index, FRIEND_REC_CAHRVALUE))
    lbl_character.characterflag = nx_widestr(player:QueryRecord(playerTable, index, FRIEND_REC_CHARFLAG))
    lbl_character.BackImage = nx_execute("form_stage_main\\form_chat_system\\chat_util_define", "get_shane_image", lbl_character.characterflag, lbl_character.charactervalue)
  elseif playerTable == ENEMY_REC or playerTable == BLOOD_REC then
    lbl_character.charactervalue = nx_widestr(player:QueryRecord(playerTable, index, ENEMY_REC_CAHRVALUE))
    lbl_character.characterflag = nx_widestr(player:QueryRecord(playerTable, index, ENEMY_REC_CHARFLAG))
    lbl_character.BackImage = nx_execute("form_stage_main\\form_chat_system\\chat_util_define", "get_shane_image", lbl_character.characterflag, lbl_character.charactervalue)
  end
  lbl_character.Left = lb_name.Left + 58 + 20.5 - lbl_character.Width / 2
  lbl_character.Top = 21.5 - lbl_character.Height / 2
  nx_bind_script(lbl_character, nx_script_name(form))
  nx_callback(lbl_character, "on_get_capture", "on_lbl_character_get_capture")
  if playerTable == FRIEND_REC or playerTable == BUDDY_REC or playerTable == ENEMY_REC or playerTable == BLOOD_REC or playerTable == ATTENTION_REC then
    gb_player:Add(lbl_character)
  end
  gb_player.Left = 10
  gb_player.Width = 160
  gb_player.Height = 62
  gb_player.NoFrame = true
  gb_player.BackColor = "0,255,255,255"
  gb_player.target = nx_widestr(playerName)
  gb_player.DrawMode = "FitWindow"
  if playerTable == ACQUAINT_REC then
    gb_player.thing1 = nx_widestr(player:QueryRecord(ACQUAINT_REC, index, ACQUAINT_THING1))
    gb_player.detail1 = nx_widestr(player:QueryRecord(ACQUAINT_REC, index, ACQUAINT_DETAIL1))
    gb_player.thing2 = nx_widestr(player:QueryRecord(ACQUAINT_REC, index, ACQUAINT_THING2))
    gb_player.detail2 = nx_widestr(player:QueryRecord(ACQUAINT_REC, index, ACQUAINT_DETAIL2))
    gb_player.thing3 = nx_widestr(player:QueryRecord(ACQUAINT_REC, index, ACQUAINT_THING3))
    gb_player.detail3 = nx_widestr(player:QueryRecord(ACQUAINT_REC, index, ACQUAINT_DETAIL3))
    gb_player.count = nx_int(player:QueryRecord(ACQUAINT_REC, index, ACQUAINT_COUNT))
  end
  local ctrlList = form.player_list:GetChildControlList()
  local ctrlCount = table.getn(ctrlList)
  gb_player.Top = 8 + 65 * ctrlCount
  if bChecked then
    gb_player.BackImage = "gui\\special\\sns\\bg_select.png"
  else
    gb_player.BackImage = ""
  end
  nx_bind_script(gb_player, nx_script_name(form))
  nx_callback(gb_player, "on_left_double_click", "on_gb_player_left_double_click")
  nx_callback(gb_player, "on_right_click", "on_gb_player_right_click")
  nx_callback(gb_player, "on_get_capture", "on_gb_player_get_capture")
  nx_callback(gb_player, "on_lost_capture", "on_gb_player_lost_capture")
  groupscrollbox:Add(gb_player)
  return 1
end
function on_gb_player_left_double_click(gb_player)
  local form = gb_player.ParentForm
  if not nx_is_valid(form) then
    return
  end
  playerName = nx_widestr(gb_player.target)
  focus_sns_model_object(RELATION_GROUP_RENMAI, playerName)
  form.CheckPlayerName = playerName
  check_back_selected(form, playerName)
end
function show_focus_player_back(form, relation_type)
  if nx_number(relation_type) == nx_number(RELATION_TYPE_FRIEND) then
    form.rbtn_all.Checked = true
    form.PlayerType = FRIEND_TYPE
  elseif nx_number(relation_type) == nx_number(RELATION_TYPE_BUDDY) then
    form.rbtn_all.Checked = true
    form.PlayerType = BUDDY_TYPE
  elseif nx_number(relation_type) == nx_number(RELATION_TYPE_ENEMY) then
    form.rbtn_all.Checked = true
    form.PlayerType = ENEMY_TYPE
  elseif nx_number(relation_type) == nx_number(RELATION_TYPE_BLOOD) then
    form.PlayerType = BLOOD_TYPE
  elseif nx_number(relation_type) == nx_number(RELATION_TYPE_FLITER) then
    form.PlayerType = FILTER_TYPE
  elseif nx_number(relation_type) == nx_number(RELATION_TYPE_ATTENTION) then
    form.PlayerType = GUANZHU_TYPE
  elseif nx_number(relation_type) == nx_number(RELATION_TYPE_ACQUAINT) then
    form.PlayerType = ACQUAINT_TYPE
  elseif nx_number(relation_type) == nx_number(RELATION_TYPE_TEACHER_PUPIL) then
    form.PlayerType = TEACHER_PUPIL_TYPE
  end
  refresh_playerlist(form)
  form.player_list.IsEditMode = false
  form.player_list:ResetChildrenYPos()
end
function on_gb_player_right_click(gb_player, x, y)
  local form = gb_player.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.PlayerType == FRIEND_TYPE then
    show_friendtype_menu_item(gb_player, x, y)
  elseif form.PlayerType == BUDDY_TYPE then
    show_buddytype_menu_item(gb_player, x, y)
  elseif form.PlayerType == BROTHER_TYPE then
    show_brothertype_menu_item(gb_player, x, y)
  elseif form.PlayerType == ENEMY_TYPE then
    show_choujiatype_menu_item(gb_player, x, y)
  elseif form.PlayerType == BLOOD_TYPE then
    show_xuechoutype_menu_item(gb_player, x, y)
  elseif form.PlayerType == FILTER_TYPE then
    show_filtertype_menu_item(gb_player, x, y)
  elseif form.PlayerType == GUANZHU_TYPE then
    show_attentiontype_menu_item(gb_player, x, y)
  elseif form.PlayerType == ACQUAINT_TYPE then
    show_acquainttype_menu_item(gb_player, x, y)
  elseif form.PlayerType == TEACHER_PUPIL_TYPE then
  end
end
function menu_delete_relation_both_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local form = gb_player.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", nx_widestr(gb_player.target))
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local playerType = RELATION_TYPE_FRIEND
    if form.PlayerType == FRIEND_TYPE then
      playerType = RELATION_TYPE_FRIEND
    elseif form.PlayerType == BUDDY_TYPE then
      playerType = RELATION_TYPE_BUDDY
    elseif form.PlayerType == BROTHER_TYPE then
      playerType = RELATION_TYPE_BROTHER
    end
    if not nx_is_valid(gb_player) then
      return
    end
    sender_message(SUB_MSG_RELATION_REMOVE_BOTH, nx_widestr(gb_player.target), playerType, nx_int(-1))
    local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
    if nx_is_valid(form_renmai) then
      form_renmai.gb_center.Visible = false
    end
  end
end
function menu_add_friend_click()
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_add"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" then
    sender_message(SUB_MSG_RELATION_ADD_APPLY, name, RELATION_TYPE_FRIEND, nx_int(-1))
  end
end
function menu_player_team_request_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  local name = nx_widestr(gb_player.target)
  nx_execute("custom_sender", "custom_team_invite", name)
end
function menu_player_send_mail_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local name = nx_widestr(gb_player.target)
  nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
  local form_send = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail_send", true, false)
  form_send.targetname.Text = nx_widestr(name)
end
function menu_invite_member_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local name = nx_widestr(gb_player.target)
  nx_execute("custom_sender", "custom_guild_invite_member", nx_widestr(name))
end
function menu_jianghu_help_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local name = nx_widestr(gb_player.target)
  nx_execute("custom_sender", "custom_jianghu_help", nx_widestr(name))
end
function menu_interact_appraise_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  local name = nx_widestr(gb_player.target)
  nx_execute("form_stage_main\\form_charge_shop\\form_interact_appraise", "show_interact_appraise", name)
end
function menu_update_zhiyou_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  sender_message(SUB_MSG_RELATION_ADD_BOTH, nx_widestr(gb_player.target), RELATION_TYPE_BUDDY, RELATION_TYPE_FRIEND)
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) then
    form_renmai.gb_center.Visible = false
  end
end
function menu_down_haoyou_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetFormatText("ui_sns_confirm_down_haoyou", nx_widestr(gb_player.target))
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(gb_player) then
      return
    end
    sender_message(SUB_MSG_RELATION_ADD_BOTH, nx_widestr(gb_player.target), RELATION_TYPE_FRIEND, RELATION_TYPE_BUDDY)
    local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
    if nx_is_valid(form_renmai) then
      form_renmai.gb_center.Visible = false
    end
  end
end
function menu_acquint_add_friend_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  sender_message(SUB_MSG_RELATION_ADD_APPLY, nx_widestr(gb_player.target), RELATION_TYPE_FRIEND, RELATION_TYPE_ACQUAINT)
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) then
    form_renmai.gb_center.Visible = false
  end
end
function menu_update_xiongdi_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  sender_message(SUB_MSG_RELATION_ADD_BOTH, nx_widestr(gb_player.target), RELATION_TYPE_BROTHER, RELATION_TYPE_BUDDY)
end
function menu_jiawei_filter_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  local form = gb_player.ParentForm
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetFormatText("ui_menu_friend_modify_filter", nx_widestr(gb_player.target))
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local playerType = RELATION_TYPE_FRIEND
    if form.PlayerType == FRIEND_TYPE then
      playerType = RELATION_TYPE_FRIEND
    elseif form.PlayerType == BUDDY_TYPE then
      playerType = RELATION_TYPE_BUDDY
    elseif form.PlayerType == BROTHER_TYPE then
      playerType = RELATION_TYPE_BROTHER
    end
    if not nx_is_valid(gb_player) then
      return
    end
    sender_message(SUB_MSG_RELATION_ADD_SELF, nx_widestr(gb_player.target), RELATION_TYPE_FLITER, nx_int(-1))
    local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
    if nx_is_valid(form_renmai) then
      form_renmai.gb_center.Visible = false
    end
  end
end
function menu_update_xuechou_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetFormatText("ui_menu_xuechou_prompt", nx_widestr(gb_player.target))
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" and nx_is_valid(gb_player) then
    sender_message(SUB_MSG_RELATION_ADD_SELF, nx_widestr(gb_player.target), RELATION_TYPE_BLOOD, RELATION_TYPE_ENEMY)
  end
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) then
    form_renmai.gb_center.Visible = false
  end
end
function menu_down_choujia_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  sender_message(SUB_MSG_RELATION_ADD_SELF, nx_widestr(gb_player.target), RELATION_TYPE_ENEMY, RELATION_TYPE_BLOOD)
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) then
    form_renmai.gb_center.Visible = false
  end
end
function menu_acquint_add_enemy_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  sender_message(SUB_MSG_RELATION_ADD_SELF, nx_widestr(gb_player.target), RELATION_TYPE_ENEMY, RELATION_TYPE_ACQUAINT)
end
function menu_delete_relation_self_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local form = gb_player.ParentForm
  local playerType = RELATION_TYPE_ENEMY
  if form.PlayerType == ENEMY_TYPE then
    playerType = RELATION_TYPE_ENEMY
  elseif form.PlayerType == BLOOD_TYPE then
    playerType = RELATION_TYPE_BLOOD
  elseif form.PlayerType == FILTER_TYPE then
    playerType = RELATION_TYPE_FLITER
  elseif form.PlayerType == ACQUAINT_TYPE then
    playerType = RELATION_TYPE_ACQUAINT
  end
  if playerType == RELATION_TYPE_ENEMY or playerType == RELATION_TYPE_BLOOD then
    del_enemy_open_present(gb_player.target)
    local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
    if nx_is_valid(form_renmai) then
      form_renmai.gb_center.Visible = false
    end
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", nx_widestr(gb_player.target))
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(gb_player) then
      return
    end
    sender_message(SUB_MSG_RELATION_REMOVE_SELF, nx_widestr(gb_player.target), playerType, nx_int(-1))
    local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
    if nx_is_valid(form_renmai) then
      form_renmai.gb_center.Visible = false
    end
  end
end
function del_enemy_open_present(name)
  local form_present = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_present", true, false)
  if not nx_is_valid(form_present) then
    return
  end
  form_present.TypeMode = 0
  form_present.SendPlayerName = nx_widestr(name)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form_present)
  form_present.Visible = true
  form_present:Show()
  local info = gui.TextManager:GetFormatText("9927")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(info, 2)
  end
  local form_send = form_present.page_send
  if not nx_is_valid(form_send) then
    return
  end
  local rb_itemtype = form_send.gb_ItemTypeList:Find("rb_ui_sns_gift_memento")
  if not nx_is_valid(rb_itemtype) then
    return
  end
  rb_itemtype.Checked = true
  local gb_item = rb_itemtype.GroupScrollBox:Find("gb_sns_forgive_001")
  if not nx_is_valid(gb_item) then
    return
  end
  local cb_item = gb_item:Find(gb_item.cb_item_name)
  if not nx_is_valid(cb_item) then
    return
  end
  cb_item.Checked = true
  local ani_select = gui:Create("Animation")
  ani_select.AnimationImage = "enemy_prop"
  ani_select.PlayMode = 0
  ani_select.Left = -13
  ani_select.Top = -12
  gb_item:Add(ani_select)
end
function menu_down_zhiyou_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return 0
  end
  sender_message(SUB_MSG_RELATION_ADD_BOTH, nx_widestr(gb_player.target), RELATION_TYPE_BUDDY, RELATION_TYPE_BROTHER)
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) then
    form_renmai.gb_center.Visible = false
  end
end
function menu_si_chat_click()
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.chat_channel_btn.Text = gui.TextManager:GetText("ui_chat_channel_3")
  form.chat_edit.chat_type = 3
  gui.Focused = form.chat_edit
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local name = nx_widestr(gb_player.target)
  form.chat_edit.Text = nx_widestr("")
  form.chat_edit:Append(nx_widestr(name), -1)
  form.chat_edit:Append(nx_widestr(" "), -1)
  nx_execute("form_stage_main\\form_main\\form_main_chat", "show_chat")
end
function menu_delete_attention_relation_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local form = gb_player.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", nx_widestr(gb_player.target))
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(gb_player) then
      return
    end
    if nx_find_custom(gb_player, "target") then
      sender_message(SUB_MSG_RELATION_ATTENTION_REMOVE, nx_widestr(gb_player.target), nx_int(RELATION_TYPE_ATTENTION), nx_int(-1))
    end
    local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
    if nx_is_valid(form_renmai) then
      form_renmai.gb_center.Visible = false
    end
  end
end
function on_gb_player_get_capture(gb_player)
  if not nx_is_valid(gb_player) then
    return
  end
  local form = gb_player.ParentForm
  local gui = nx_value("gui")
  gb_player.BackImage = "gui\\special\\sns\\bg_select.png"
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  if form.PlayerType == ACQUAINT_TYPE then
    form.mltbox_friendinfo.Top = gb_player.Top
    form.mltbox_friendinfo.Visible = true
    form.mltbox_friendinfo.Font = "font_sns_event"
    form.mltbox_friendinfo.LineHeight = 12
    form.mltbox_friendinfo:Clear()
    local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\acquitthings.ini")
    if not nx_is_valid(ini) then
      return nil
    end
    local sect_count = ini:GetSectionCount()
    for sect = 0, nx_number(sect_count - 1) do
      local thingscode1 = ini:ReadString(sect, nx_string(gb_player.thing1), "")
      local thingsmark1 = gui.TextManager:GetFormatText(thingscode1, gb_player.target, gb_player.detail1)
      local thingscode2 = ini:ReadString(sect, nx_string(gb_player.thing2), "")
      local thingsmark2 = gui.TextManager:GetFormatText(thingscode2, gb_player.target, gb_player.detail2)
      local thingscode3 = ini:ReadString(sect, nx_string(gb_player.thing3), "")
      local thingsmark3 = gui.TextManager:GetFormatText(thingscode3, gb_player.target, gb_player.detail3)
      if nx_int(gb_player.count) == nx_int(1) then
        form.mltbox_friendinfo:AddHtmlText(nx_widestr(thingsmark1), nx_int(-1))
      elseif nx_int(gb_player.count) == nx_int(2) then
        form.mltbox_friendinfo:AddHtmlText(nx_widestr(thingsmark1), nx_int(-1))
        form.mltbox_friendinfo:AddHtmlText(nx_widestr(thingsmark2), nx_int(-1))
      elseif nx_int(gb_player.count) >= nx_int(3) then
        form.mltbox_friendinfo:AddHtmlText(nx_widestr(thingsmark1), nx_int(-1))
        form.mltbox_friendinfo:AddHtmlText(nx_widestr(thingsmark2), nx_int(-1))
        form.mltbox_friendinfo:AddHtmlText(nx_widestr(thingsmark3), nx_int(-1))
      end
    end
  end
  if form.PlayerType == ENEMY_TYPE then
    nx_execute("custom_sender", "custom_query_enemy_info", 1, RELATION_TYPE_ENEMY, gb_player.target)
    local form = gb_player.ParentForm
    form.mltbox_friendinfo.Top = gb_player.Top
    form.mltbox_friendinfo.Font = "font_sns_event"
    form.mltbox_friendinfo.LineHeight = 12
    if nx_find_custom(form.mltbox_friendinfo, "enemyname") and nx_find_custom(form.mltbox_friendinfo, "enemyinfo") and nx_ws_equal(form.mltbox_friendinfo.enemyname, gb_player.target) then
      form.mltbox_friendinfo.Visible = true
      form.mltbox_friendinfo:Clear()
      form.mltbox_friendinfo:AddHtmlText(nx_widestr(form.mltbox_friendinfo.enemyinfo), nx_int(-1))
    end
  end
  if form.PlayerType == BLOOD_TYPE then
    nx_execute("custom_sender", "custom_query_enemy_info", 1, RELATION_TYPE_BLOOD, gb_player.target)
    local form = gb_player.ParentForm
    form.mltbox_friendinfo.Top = gb_player.Top
    form.mltbox_friendinfo.Font = "font_sns_event"
    form.mltbox_friendinfo.LineHeight = 12
    if nx_find_custom(form.mltbox_friendinfo, "enemyname") and nx_find_custom(form.mltbox_friendinfo, "enemyinfo") and nx_ws_equal(form.mltbox_friendinfo.enemyname, gb_player.target) then
      form.mltbox_friendinfo.Visible = true
      form.mltbox_friendinfo:Clear()
      form.mltbox_friendinfo:AddHtmlText(nx_widestr(form.mltbox_friendinfo.enemyinfo), nx_int(-1))
    end
  end
end
function on_gb_player_lost_capture(gb_player)
  if not nx_is_valid(gb_player) then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_friend_list")
  if nx_is_valid(form) and nx_find_custom(form, "CheckPlayerName") and nx_ws_equal(nx_widestr(gb_player.target), nx_widestr(form.CheckPlayerName)) then
    gb_player.BackImage = "gui\\special\\sns\\bg_select.png"
    return
  end
  gb_player.BackImage = ""
  form.mltbox_friendinfo.Visible = false
end
function menu_huihua_chat_click()
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  local gb_player = menu_game.gb_player
  if not nx_is_valid(gb_player) then
    return
  end
  local name = nx_widestr(gb_player.target)
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(name))
end
function menu_close_click()
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if nx_is_valid(menu_game) then
    gui:Delete(menu_game)
  end
end
function on_btn_feedinfo_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_relation\\form_feed_info")
end
function can_invite_member()
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local self_guild = player_obj:QueryProp("GuildName")
  if nx_widestr(self_guild) ~= nx_widestr("") and nx_widestr(self_guild) ~= nx_widestr("0") then
    return true
  end
  return false
end
function show_friendtype_menu_item(gb_player, x, y)
  if nx_find_custom(gb_player, "is_npc") then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local cur_player = game_client:GetPlayer()
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, nx_current(), "menu_game_init")
    nx_set_value("relation_menu_game", menu_game)
  end
  menu_game:DeleteAllItem()
  menu_game:CreateItem("huihua_chat", gui.TextManager:GetText("ui_sns_chat_top_title"))
  menu_game:CreateItem("player_team_request", gui.TextManager:GetText("ui_playerlink_yaoqingzudui"))
  menu_game:CreateItem("player_send_mail", gui.TextManager:GetText("ui_mail_fasong"))
  if can_invite_member() then
    menu_game:CreateItem("invite_member", gui.TextManager:GetText("ui_guild_invite"))
  end
  if cur_player:QueryProp("CanSummonInAdve") == 1 then
    menu_game:CreateItem("jianghu_help", gui.TextManager:GetText("ui_menu_seekhelp"))
  end
  local row = cur_player:FindRecordRow(BUDDY_REC, FRIEND_REC_NAME, gb_player.target, 0)
  if row < 0 then
    menu_game:CreateItem("update_zhiyou", gui.TextManager:GetText("ui_menu_friend_update_zhiyou"))
    menu_game:CreateItem("delete_relation_both", gui.TextManager:GetText("ui_menu_friend_delete_haoyou"))
  else
    menu_game:CreateItem("down_haoyou", gui.TextManager:GetText("ui_menu_friend_down_haoyou"))
    menu_game:CreateItem("delete_relation_both", gui.TextManager:GetText("ui_menu_friend_delete_zhiyou"))
  end
  menu_game.gb_player = gb_player
  local event = "on_huihua_chat_click"
  local callback = "menu_huihua_chat_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_player_team_request_click"
  callback = "menu_player_team_request_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_player_send_mail_click"
  callback = "menu_player_send_mail_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_invite_member_click"
  callback = "menu_invite_member_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_jianghu_help_click"
  callback = "menu_jianghu_help_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_delete_relation_both_click"
  callback = "menu_delete_relation_both_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  if row < 0 then
    event = "on_update_zhiyou_click"
    callback = "menu_update_zhiyou_click"
    nx_callback(menu_game, nx_string(event), nx_string(callback))
  else
    event = "on_down_haoyou_click"
    callback = "menu_down_haoyou_click"
    nx_callback(menu_game, nx_string(event), nx_string(callback))
  end
  gui:TrackPopupMenu(menu_game, x, y)
end
function show_buddytype_menu_item(gb_player, x, y)
  if nx_find_custom(gb_player, "is_npc") then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local cur_player = game_client:GetPlayer()
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, nx_current(), "menu_game_init")
    nx_set_value("relation_menu_game", menu_game)
  end
  menu_game:DeleteAllItem()
  menu_game:CreateItem("huihua_chat", gui.TextManager:GetText("ui_sns_chat_top_title"))
  menu_game:CreateItem("player_team_request", gui.TextManager:GetText("ui_playerlink_yaoqingzudui"))
  menu_game:CreateItem("player_send_mail", gui.TextManager:GetText("ui_mail_fasong"))
  if can_invite_member() then
    menu_game:CreateItem("invite_member", gui.TextManager:GetText("ui_guild_invite"))
  end
  if cur_player:QueryProp("CanSummonInAdve") == 1 then
    menu_game:CreateItem("jianghu_help", gui.TextManager:GetText("ui_menu_seekhelp"))
  end
  menu_game:CreateItem("down_haoyou", gui.TextManager:GetText("ui_menu_friend_down_haoyou"))
  menu_game:CreateItem("delete_relation_both", gui.TextManager:GetText("ui_menu_friend_delete_zhiyou"))
  menu_game.gb_player = gb_player
  local event = "on_huihua_chat_click"
  local callback = "menu_huihua_chat_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_player_team_request_click"
  callback = "menu_player_team_request_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_player_send_mail_click"
  callback = "menu_player_send_mail_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_invite_member_click"
  callback = "menu_invite_member_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_jianghu_help_click"
  callback = "menu_jianghu_help_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_delete_relation_both_click"
  callback = "menu_delete_relation_both_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_down_haoyou_click"
  callback = "menu_down_haoyou_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  gui:TrackPopupMenu(menu_game, x, y)
end
function show_brothertype_menu_item(gb_player, x, y)
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, nx_current(), "menu_game_init")
    nx_set_value("relation_menu_game", menu_game)
  end
  menu_game:DeleteAllItem()
  menu_game:CreateItem("si_chat", gui.TextManager:GetText("ui_menu_secret_chat"))
  menu_game:CreateItem("delete_relation_both", gui.TextManager:GetText("ui_menu_friend_delete_xiongdi"))
  menu_game:CreateItem("down_zhiyou", gui.TextManager:GetText("ui_menu_friend_down_zhiyou"))
  menu_game:CreateItem("close", gui.TextManager:GetText("ui_g_close"))
  menu_game.gb_player = gb_player
  local event = "on_si_chat_click"
  local callback = "menu_si_chat_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_delete_relation_both_click"
  callback = "menu_delete_relation_both_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_down_zhiyou_click"
  callback = "menu_down_zhiyou_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_close_click"
  callback = "menu_close_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  gui:TrackPopupMenu(menu_game, x, y)
end
function show_choujiatype_menu_item(gb_player, x, y)
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, nx_current(), "menu_game_init")
    nx_set_value("relation_menu_game", menu_game)
  end
  local game_client = nx_value("game_client")
  local cur_player = game_client:GetPlayer()
  menu_game:DeleteAllItem()
  menu_game:CreateItem("huihua_chat", gui.TextManager:GetText("ui_sns_chat_top_title"))
  local row = cur_player:FindRecordRow(BLOOD_REC, FRIEND_REC_NAME, gb_player.target, 0)
  if row < 0 then
    menu_game:CreateItem("update_xuechou", gui.TextManager:GetText("ui_menu_friend_update_xuechou"))
    menu_game:CreateItem("delete_relation_self", gui.TextManager:GetText("ui_menu_friend_delete_chouren"))
  else
    menu_game:CreateItem("down_choujia", gui.TextManager:GetText("ui_menu_friend_down_chouren"))
    menu_game:CreateItem("delete_relation_self", gui.TextManager:GetText("ui_menu_friend_delete_xuechou"))
  end
  menu_game.gb_player = gb_player
  local event = "on_huihua_chat_click"
  local callback = "menu_huihua_chat_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_delete_relation_self_click"
  callback = "menu_delete_relation_self_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  if row < 0 then
    event = "on_update_xuechou_click"
    callback = "menu_update_xuechou_click"
    nx_callback(menu_game, nx_string(event), nx_string(callback))
  else
    event = "on_down_choujia_click"
    callback = "menu_down_choujia_click"
    nx_callback(menu_game, nx_string(event), nx_string(callback))
  end
  gui:TrackPopupMenu(menu_game, x, y)
end
function show_xuechoutype_menu_item(gb_player, x, y)
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, nx_current(), "menu_game_init")
    nx_set_value("relation_menu_game", menu_game)
  end
  menu_game:DeleteAllItem()
  menu_game:CreateItem("huihua_chat", gui.TextManager:GetText("ui_sns_chat_top_title"))
  menu_game:CreateItem("down_choujia", gui.TextManager:GetText("ui_menu_friend_down_chouren"))
  menu_game:CreateItem("delete_relation_self", gui.TextManager:GetText("ui_menu_friend_delete_xuechou"))
  menu_game.gb_player = gb_player
  local event = "on_huihua_chat_click"
  local callback = "menu_huihua_chat_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_delete_relation_self_click"
  callback = "menu_delete_relation_self_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_down_choujia_click"
  callback = "menu_down_choujia_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  gui:TrackPopupMenu(menu_game, x, y)
end
function show_filtertype_menu_item(gb_player, x, y)
  local gui = nx_value("gui")
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, nx_current(), "menu_game_init")
    nx_set_value("relation_menu_game", menu_game)
  end
  menu_game:DeleteAllItem()
  menu_game:CreateItem("delete_relation_self", gui.TextManager:GetText("ui_menu_friend_delete_filter"))
  menu_game.gb_player = gb_player
  event = "on_delete_relation_self_click"
  callback = "menu_delete_relation_self_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  gui:TrackPopupMenu(menu_game, x, y)
end
function show_attentiontype_menu_item(gb_player, x, y)
  if nx_find_custom(gb_player, "is_npc") then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local cur_player = game_client:GetPlayer()
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, nx_current(), "menu_game_init")
    nx_set_value("relation_menu_game", menu_game)
  end
  menu_game:DeleteAllItem()
  menu_game:CreateItem("huihua_chat", gui.TextManager:GetText("ui_sns_chat_top_title"))
  menu_game:CreateItem("player_team_request", gui.TextManager:GetText("ui_playerlink_yaoqingzudui"))
  menu_game:CreateItem("player_send_mail", gui.TextManager:GetText("ui_mail_fasong"))
  if can_invite_member() then
    menu_game:CreateItem("invite_member", gui.TextManager:GetText("ui_guild_invite"))
  end
  if cur_player:QueryProp("CanSummonInAdve") == 1 then
    menu_game:CreateItem("jianghu_help", gui.TextManager:GetText("ui_menu_seekhelp"))
  end
  menu_game:CreateItem("add_friend", gui.TextManager:GetText("ui_playerlink_jiaweihaoyou"))
  menu_game:CreateItem("delete_attention_relation", gui.TextManager:GetText("ui_menu_friend_delete_attention"))
  menu_game.gb_player = gb_player
  local event = "on_huihua_chat_click"
  local callback = "menu_huihua_chat_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_player_team_request_click"
  callback = "menu_player_team_request_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_player_send_mail_click"
  callback = "menu_player_send_mail_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_invite_member_click"
  callback = "menu_invite_member_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_jianghu_help_click"
  callback = "menu_jianghu_help_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_delete_attention_relation_click"
  callback = "menu_delete_attention_relation_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_add_friend_click"
  callback = "menu_acquint_add_friend_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  gui:TrackPopupMenu(menu_game, x, y)
end
function show_acquainttype_menu_item(gb_player, x, y)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local cur_player = game_client:GetPlayer()
  local menu_game = nx_value("relation_menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, nx_current(), "menu_game_init")
    nx_set_value("relation_menu_game", menu_game)
  end
  menu_game:DeleteAllItem()
  menu_game:CreateItem("huihua_chat", gui.TextManager:GetText("ui_sns_chat_top_title"))
  menu_game:CreateItem("player_team_request", gui.TextManager:GetText("ui_playerlink_yaoqingzudui"))
  menu_game:CreateItem("player_send_mail", gui.TextManager:GetText("ui_mail_fasong"))
  if can_invite_member() then
    menu_game:CreateItem("invite_member", gui.TextManager:GetText("ui_guild_invite"))
  end
  if cur_player:QueryProp("CanSummonInAdve") == 1 then
    menu_game:CreateItem("jianghu_help", gui.TextManager:GetText("ui_menu_seekhelp"))
  end
  menu_game:CreateItem("add_friend", gui.TextManager:GetText("ui_playerlink_jiaweihaoyou"))
  menu_game:CreateItem("delete_acquaint_relation", gui.TextManager:GetText("ui_menu_friend_delete_acquaint"))
  menu_game:CreateItem("jiawei_filter", gui.TextManager:GetText("ui_menu_friend_jiawei_filter"))
  menu_game.gb_player = gb_player
  local event = "on_huihua_chat_click"
  local callback = "menu_huihua_chat_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_player_team_request_click"
  callback = "menu_player_team_request_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_player_send_mail_click"
  callback = "menu_player_send_mail_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_invite_member_click"
  callback = "menu_invite_member_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_jianghu_help_click"
  callback = "menu_jianghu_help_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_delete_acquaint_relation_click"
  callback = "menu_delete_relation_self_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_add_friend_click"
  callback = "menu_acquint_add_friend_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  event = "on_jiawei_filter_click"
  callback = "menu_jiawei_filter_click"
  nx_callback(menu_game, nx_string(event), nx_string(callback))
  gui:TrackPopupMenu(menu_game, x, y)
end
function on_rbtn_checked_changed(btn, playerType)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked == true then
    form.PlayerType = playerType
    refresh_playerlist(form)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function on_rbtn_all_checked_changed(btn)
  if btn.Checked then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.lbl_friend.Visible = true
    form.lbl_zhiyou.Visible = false
    form.lbl_chouren.Visible = false
    refresh_playerlist(form, 0)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function on_rbtn_player_checked_changed(btn)
  if btn.Checked then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.lbl_friend.Visible = false
    form.lbl_zhiyou.Visible = true
    form.lbl_chouren.Visible = false
    refresh_playerlist(form, 1)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function on_rbtn_xiongdi_checked_changed(btn)
end
function on_rbtn_npc_checked_changed(btn)
  if btn.Checked then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.lbl_friend.Visible = false
    form.lbl_zhiyou.Visible = false
    form.lbl_chouren.Visible = true
    refresh_playerlist(form, 2)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function on_rbtn_xuechou_checked_changed(btn)
end
function on_rbtn_guanzhu_checked_changed(btn)
end
function on_rbtn_jieshi_checked_changed(btn)
end
function on_rbtn_fans_checked_changed(btn)
end
function on_rbtn_blacklist_checked_changed(btn)
end
function on_btn_add_player_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.PlayerType == FRIEND_TYPE then
    on_add_btn_friend_click(btn)
  elseif form.PlayerType == ENEMY_TYPE then
    on_btn_add_chouren_click(btn)
  elseif form.PlayerType == FILTER_TYPE then
    on_btn_add_filter_click(btn)
  elseif form.PlayerType == GUANZHU_TYPE then
    on_btn_add_guanzhu_click(btn)
  end
end
function on_btn_add_guanzhu_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_add_guanzhu"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" and name ~= "" then
    sender_message(nx_int(SUB_MSG_RELATION_ATTENTION_ADD), nx_widestr(name), nx_int(RELATION_TYPE_ATTENTION), nx_int(-1))
  end
end
function on_btn_add_filter_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_add_filter"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" and name ~= "" then
    sender_message(nx_int(SUB_MSG_RELATION_ADD_SELF), nx_widestr(name), nx_int(RELATION_TYPE_FLITER), nx_int(-1))
  end
end
function on_btn_add_chouren_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_add_chouren"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" and name ~= "" then
    sender_message(nx_int(SUB_MSG_RELATION_ADD_SELF), nx_widestr(name), nx_int(RELATION_TYPE_ENEMY), nx_int(-1))
  end
end
function on_add_btn_friend_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_add"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" and name ~= "" then
    sender_message(nx_int(SUB_MSG_RELATION_ADD_APPLY), nx_widestr(name), nx_int(RELATION_TYPE_FRIEND), nx_int(-1))
  end
end
function search_friend_result(form, player, table_name, table_type, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, FRIEND_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_MENPAI))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, FRIEND_REC_ONLINE))
    if string.find(nx_string(player_name), nx_string(key_name)) then
      form.PlayerType = table_type
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state)
    end
  end
  return false
end
function search_enemy_result(form, player, table_name, table_type, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, ENEMY_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_MENPAI))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, ENEMY_REC_ONLINE))
    if string.find(nx_string(player_name), nx_string(key_name)) then
      form.PlayerType = table_type
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state)
    end
  end
  return false
end
function search_filter_result(form, player, table_name, table_type, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, ENEMY_REC_NAME))
    local player_icon = "gui\\special\\sns_new\\sns_head\\common_head.png"
    local player_menpai = ""
    local player_offline_state = -1
    if string.find(nx_string(player_name), nx_string(key_name)) then
      form.PlayerType = table_type
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state)
    end
  end
  return false
end
function search_shixiongdi_result(form, player, table_name, table_type, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, PUPIL_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, PUPIL_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, ENEMY_REC_PHOTO))
    local player_menpai = ""
    local player_offline_state = -1
    if string.find(nx_string(player_name), nx_string(key_name)) then
      form.PlayerType = table_type
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state)
    end
  end
  return false
end
function search_acquaint_result(form, player, table_name, table_type, key_name)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return false
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, ACQUAINT_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, ACQUAINT_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, ACQUAINT_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, ACQUAINT_REC_MENPAI))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, ACQUAINT_REC_ONLINE))
    if string.find(nx_string(player_name), nx_string(key_name)) then
      form.PlayerType = table_type
      add_player(form.player_list, index, player_name, table_name, player_icon, player_menpai, player_offline_state)
    end
  end
  return false
end
function search_npc_relation_result(form, player, relation, key_name)
  if relation == FRIEND_TYPE or relation == BUDDY_TYPE then
    local table_name = "rec_npc_relation"
    if not player:FindRecord(table_name) then
      return
    end
    local rows = player:GetRecordRows(table_name)
    if rows <= 0 then
      return
    end
    for i = 0, rows - 1 do
      local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
      local npc_scene_id = nx_string(player:QueryRecord(table_name, i, 1))
      local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
      local npc_name = util_text(npc_id)
      if nx_int(npc_relation) == nx_int(relation) and string.find(nx_string(npc_name), nx_string(key_name)) then
        add_npc(form, npc_id, npc_scene_id, false)
      end
    end
  elseif relation == GUANZHU_TYPE then
    local table_name = "rec_npc_attention"
    if not player:FindRecord(table_name) then
      return
    end
    local rows = player:GetRecordRows(table_name)
    if rows <= 0 then
      return
    end
    for i = 0, rows - 1 do
      local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
      local npc_scene_id = nx_string(player:QueryRecord(table_name, i, 1))
      local npc_name = util_text(npc_id)
      if string.find(nx_string(npc_name), nx_string(key_name)) then
        add_npc(form, npc_id, npc_scene_id, false)
      end
    end
  else
    return
  end
end
function incremental_search_friend(form, player, name_info)
  if not nx_is_valid(form) or not nx_is_valid(player) then
    return
  end
  if nx_string(name_info) == nx_string("") then
    return
  end
  form.player_list:DeleteAll()
  if form.PlayerType == FRIEND_TYPE then
    search_friend_result(form, player, FRIEND_REC, FRIEND_TYPE, name_info)
  elseif form.PlayerType == BUDDY_TYPE then
    search_friend_result(form, player, BUDDY_REC, BUDDY_TYPE, name_info)
  elseif form.PlayerType == BROTHER_TYPE then
    search_friend_result(form, player, BROTHER_REC, BROTHER_TYPE, name_info)
  elseif form.PlayerType == ENEMY_TYPE then
    search_enemy_result(form, player, ENEMY_REC, ENEMY_TYPE, name_info)
  elseif form.PlayerType == BLOOD_TYPE then
    search_enemy_result(form, player, BLOOD_REC, BLOOD_TYPE, name_info)
  elseif form.PlayerType == GUANZHU_TYPE then
    search_friend_result(form, player, ATTENTION_REC, GUANZHU_TYPE, name_info)
  elseif form.PlayerType == ACQUAINT_TYPE then
    search_acquaint_result(form, player, ACQUAINT_REC, ACQUAINT_TYPE, name_info)
  elseif form.PlayerType == FANS_TYPE then
  elseif form.PlayerType == FILTER_TYPE then
    search_filter_result(form, player, FILTER_REC, FILTER_TYPE, name_info)
  elseif form.PlayerType == TEACHER_PUPIL_TYPE then
    search_shixiongdi_result(form, player, TEACHER_PUPIL_REC, TEACHER_PUPIL_TYPE, name_info)
  elseif form.PlayerType == NPC_FRIEND_TYPE then
    search_npc_relation_result(form, player, FRIEND_TYPE, name_info)
  elseif form.PlayerType == NPC_BUDDY_TYPE then
    search_npc_relation_result(form, player, BUDDY_TYPE, name_info)
  elseif form.PlayerType == NPC_ATTENTION_TYPE then
    search_npc_relation_result(form, player, GUANZHU_TYPE, name_info)
  else
    return
  end
  form.player_list:ResetChildrenYPos()
end
function incremental_search_npc(form, player, index, name_info)
  if not nx_is_valid(form) or not nx_is_valid(player) then
    return
  end
  form.player_list:DeleteAll()
  local cur_scene = get_scene_id()
  if index == RELATION_SUB_FUJIN_FRIEND or index == RELATION_SUB_FUJIN_ZHIYOU or index == RELATION_SUB_FUJIN_FUJIN then
    local table_name = "rec_npc_relation"
    if not player:FindRecord(table_name) then
      return
    end
    local rows = player:GetRecordRows(table_name)
    if rows <= 0 then
      return
    end
    for i = 0, rows - 1 do
      local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
      local npc_scene_id = nx_string(player:QueryRecord(table_name, i, 1))
      local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
      local npc_name = util_text(npc_id)
      if nx_function("ext_ws_find", nx_widestr(npc_name), nx_widestr(name_info)) > -1 then
        if index == RELATION_SUB_FUJIN_FRIEND and nx_number(npc_relation) == 0 then
          add_npc(form, npc_id, npc_scene_id, false)
        elseif index == RELATION_SUB_FUJIN_ZHIYOU and nx_number(npc_relation) == 1 then
          add_npc(form, npc_id, npc_scene_id, false)
        elseif index == RELATION_SUB_FUJIN_FUJIN and nx_int(npc_scene_id) == nx_int(cur_scene) then
          add_npc(form, npc_id, npc_scene_id, false)
        end
      end
    end
  elseif index == RELATION_SUB_FUJIN_GUANZHU then
    local table_name = "rec_npc_attention"
    if not player:FindRecord(table_name) then
      return
    end
    local rows = player:GetRecordRows(table_name)
    if rows <= 0 then
      return
    end
    for i = 0, rows - 1 do
      local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
      local npc_scene_id = nx_string(player:QueryRecord(table_name, i, 1))
      local npc_name = util_text(npc_id)
      if nx_function("ext_ws_find", nx_widestr(npc_name), nx_widestr(name_info)) > -1 then
        add_npc(form, npc_id, npc_scene_id, false)
      end
    end
  end
  form.player_list:ResetChildrenYPos()
end
function on_ipt_search_name_enter(self)
  on_btn_search_click(self)
end
function on_ipt_search_name_changed(self)
  local form = self.ParentForm
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  local form_fujin = nx_value("form_stage_main\\form_relation\\form_relation_fujin")
  if nx_is_valid(form_renmai) then
    if nx_string(self.Text) == nx_string("") then
      form.rbtn_all.Checked = true
      on_rbtn_all_checked_changed(form.rbtn_all)
    else
      local client_role = get_client_player()
      if not nx_is_valid(client_role) then
        return
      end
      incremental_search_friend(form, client_role, nx_string(self.Text))
    end
  elseif nx_is_valid(form_fujin) then
    local client_role = get_client_player()
    if not nx_is_valid(client_role) then
      return
    end
    local index = RELATION_SUB_FUJIN_FRIEND
    if form.rbtn_haoyou.Checked then
      index = RELATION_SUB_FUJIN_FRIEND
    elseif form.rbtn_zhiyou.Checked then
      index = RELATION_SUB_FUJIN_ZHIYOU
    elseif form.rbtn_guan.Checked then
      index = RELATION_SUB_FUJIN_GUANZHU
    else
      index = RELATION_SUB_FUJIN_FUJIN
    end
    incremental_search_npc(form, client_role, index, nx_string(self.Text))
  end
end
function on_ipt_search_name_get_focus(btn)
  local form = btn.ParentForm
  form.ipt_search_name.Text = nx_widestr("")
end
function on_ipt_search_name_lost_focus(btn)
  local form = btn.ParentForm
  if form.ipt_search_name.Text == "" then
    local gui = nx_value("gui")
    form.ipt_search_name.Text = nx_widestr(gui.TextManager:GetText("ui_sns_search_chazhao_defulttext"))
  end
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local playerName = nx_widestr(form.ipt_search_name.Text)
  if playerName == nil or nx_ws_equal(playerName, nx_widestr("")) then
    return
  end
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    return
  end
  form.player_list:DeleteAll()
  local bFind = search_friend_result(form, client_role, FRIEND_REC, FRIEND_TYPE, playerName)
  if bFind then
    return
  end
  bFind = search_friend_result(form, client_role, BUDDY_REC, BUDDY_TYPE, playerName)
  if bFind then
    return
  end
  bFind = search_friend_result(form, client_role, BROTHER_REC, BROTHER_TYPE, playerName)
  if bFind then
    return
  end
  bFind = search_friend_result(form, client_role, ATTENTION_REC, GUANZHU_TYPE, playerName)
  if bFind then
    return
  end
  bFind = search_enemy_result(form, client_role, ENEMY_REC, ENEMY_TYPE, playerName)
  if bFind then
    return
  end
  bFind = search_enemy_result(form, client_role, BLOOD_REC, BLOOD_TYPE, playerName)
  if bFind then
    return
  end
  bFind = search_acquaint_result(form, client_role, ACQUAINT_REC, ACQUAINT_TYPE, playerName)
  if bFind then
    return
  end
  bFind = search_filter_result(form, client_role, FILTER_REC, FILTER_TYPE, playerName)
  if bFind then
    return
  end
  bFind = search_shixiongdi_result(form, client_role, TEACHER_PUPIL_REC, TEACHER_PUPIL_TYPE, playerName)
  if bFind then
    return
  end
end
function sender_message(submsg, name, relation_new, relation_old)
  nx_execute("custom_sender", "custom_add_relation", submsg, name, relation_new, relation_old)
end
function focus_sns_model_object(relation_type, player_name)
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if not nx_is_valid(form) then
    return
  end
  local group_id = sns_manager:GetGroupIdByDefineIndex(relation_type)
  sns_manager:FocusPlayer(group_id, form.relation_type, nx_widestr(player_name))
  form.CurrentRelation = relation_type
  form.CheckPlayerName = player_name
  nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_btnlist", relation_type, nx_widestr(player_name), false)
  nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_player_name", nx_widestr(player_name))
end
function on_lbl_friendly_get_capture(btn)
  getfriendlyinfo(btn, btn.target, btn.self)
end
function getfriendlyinfo(btn, target, self)
  local form = btn.ParentForm
  local gb_box = btn.Parent
  local gb_box_Parent = gb_box.Parent.Parent
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local top = gb_box_Parent.Top
  form.mltbox_friendinfo.Top = top + gb_box.Top
  form.mltbox_friendinfo.Visible = true
  form.mltbox_friendinfo.Font = "font_sns_event"
  form.mltbox_friendinfo:Clear()
  if form.PlayerType == FRIEND_TYPE or form.PlayerType == BUDDY_TYPE then
    form.mltbox_friendinfo:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_sns_friendlytoself")) .. nx_widestr(target), nx_int(-1))
    form.mltbox_friendinfo:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_sns_friendlytotarget")) .. nx_widestr(self), nx_int(-1))
  elseif form.PlayerType == ENEMY_TYPE or form.PlayerType == BLOOD_TYPE then
    form.mltbox_friendinfo:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_sns_Enemitytoself")) .. nx_widestr(target), nx_int(-1))
    form.mltbox_friendinfo:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_sns_Enemitytotarget")) .. nx_widestr(self), nx_int(-1))
  end
end
function on_lbl_friendly_lost_capture(btn)
  local form = btn.ParentForm
  form.mltbox_friendinfo.Visible = false
end
function on_lbl_friendly_show_get_capture(btn)
  getfriendlyinfo(btn, btn.target, btn.self)
end
function on_lbl_friendly_show_lost_capture(self)
  on_lbl_friendly_lost_capture(self)
end
function on_lbl_character_get_capture(self)
  self.HintText = get_shane_tip(self.characterflag, self.charactervalue)
end
function get_shane_tip(CharacterFlag, CharacterValue)
  local text = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", CharacterFlag, CharacterValue)
  return text
end
function get_enemy_info(...)
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(3) then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_friend_list")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local name = arg[1]
  local scene_name = arg[2]
  scene_name = gui.TextManager:GetFormatText(nx_string(scene_name))
  local enemyinfo_type = arg[3]
  local info = {
    "sns_Enemy_text_Abduct",
    "sns_Enemy_text_SchoolWar",
    "sns_Enemy_text_Escort",
    "sns_Enemy_text_Challenge",
    "sns_Enemy_text_Spy",
    "sns_Enemy_text_Snatchbook",
    "sns_Enemy_text_Fire",
    "sns_Enemy_text_Default"
  }
  local info = gui.TextManager:GetFormatText(info[nx_number(enemyinfo_type + 1)], nx_widestr(name), nx_widestr(scene_name))
  form.mltbox_friendinfo:Clear()
  form.mltbox_friendinfo:AddHtmlText(nx_widestr(info), nx_int(-1))
  form.mltbox_friendinfo.Visible = true
  form.mltbox_friendinfo.enemyinfo = info
  form.mltbox_friendinfo.enemyname = nx_widestr(name)
end
function show_npc_relation(form, relation)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local table_name = "rec_npc_relation"
  if player:FindRecord(table_name) then
    local rows = player:GetRecordRows(table_name)
    if 0 < rows then
      for i = 0, rows - 1 do
        local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
        local npc_scene_id = nx_string(player:QueryRecord(table_name, i, 1))
        local npc_relation = nx_string(player:QueryRecord(table_name, i, 3))
        if nx_number(npc_relation) == relation then
          add_npc(form, npc_id, npc_scene_id, false)
        end
      end
    end
  end
  if relation == 2 then
    table_name = "rec_npc_attention"
    if player:FindRecord(table_name) then
      local rows = player:GetRecordRows(table_name)
      if 0 < rows then
        for i = 0, rows - 1 do
          local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
          local npc_scene_id = nx_string(player:QueryRecord(table_name, i, 1))
          add_npc(form, npc_id, npc_scene_id, false)
        end
      end
    end
  end
end
function is_cur_scene_num1(npc_id)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return false
  end
  local cur_scene = get_scene_id()
  local rows = player:GetRecordRows("rec_npc_relation")
  for i = 0, rows - 1 do
    local cur_npc_id = nx_string(player:QueryRecord("rec_npc_relation", i, 0))
    local scene = nx_int(player:QueryRecord("rec_npc_relation", i, 1))
    if scene == cur_scene then
      if nx_string(npc_id) == cur_npc_id then
        return true
      else
        return false
      end
    end
  end
  return false
end
function show_npc_relation_fujin(form)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local cur_scene = get_scene_id()
  if not player:FindRecord("rec_npc_relation") then
    return
  end
  local rows = player:GetRecordRows("rec_npc_relation")
  for i = 0, rows - 1 do
    local npc_id = nx_string(player:QueryRecord("rec_npc_relation", i, 0))
    local scene = nx_int(player:QueryRecord("rec_npc_relation", i, 1))
    if scene == cur_scene then
      add_npc(form, npc_id, scene)
    end
  end
end
function show_fujin_npc_by_karmatype(form, karma_type)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local cur_scene = get_scene_id()
  local rows = player:GetRecordRows("rec_npc_relation")
  for i = 0, rows - 1 do
    local npc_id = nx_string(player:QueryRecord("rec_npc_relation", i, 0))
    local scene = nx_int(player:QueryRecord("rec_npc_relation", i, 1))
    local karm_value = nx_string(player:QueryRecord("rec_npc_relation", i, 2))
    if scene == cur_scene and nx_string(get_karma_name(karm_value)) == "ui_karma_rela" .. nx_string(karma_type) then
      add_npc(form, npc_id, scene)
    end
  end
end
function get_karma_name(value)
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex("Karma")
  if sec_index < 0 then
    return ""
  end
  local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(GroupMsgData)) do
    local stepData = util_split_string(GroupMsgData[i], ",")
    if nx_int(stepData[1]) <= nx_int(value) and nx_int(value) <= nx_int(stepData[2]) then
      return nx_string(stepData[3])
    end
  end
  return ""
end
function is_attention_relation(npc_id)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindRecord("rec_npc_relation") then
    return false
  end
  local cur_scene = get_scene_id()
  local index = player:FindRecordRow("rec_npc_relation", 0, npc_id, 0)
  if index < 0 then
    return false
  end
  local scene = nx_int(player:QueryRecord("rec_npc_relation", index, 1))
  local npc_relation = nx_number(player:QueryRecord("rec_npc_relation", index, 3))
  if 0 == npc_relation or 1 == npc_relation or scene == cur_scene then
    return true
  end
  return false
end
function show_npc_relation_gz(form)
  local table_name = "rec_npc_attention"
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  form.player_list:DeleteAll()
  for i = 0, rows - 1 do
    local npc_id = nx_string(player:QueryRecord(table_name, i, 0))
    local npc_scene_id = nx_string(player:QueryRecord(table_name, i, 1))
    add_npc(form, npc_id, npc_scene_id)
  end
end
function add_npc(form, npc_id, npc_scene_id, bChecked)
  local gui = nx_value("gui")
  local gb_player = gui:Create("GroupBox")
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  local index = player:FindRecordRow("rec_npc_relation", 0, npc_id)
  local relationvalue = 0
  if 0 <= index then
    relationvalue = player:QueryRecord("rec_npc_relation", index, 2)
  end
  local lb_bg = gui:Create("Label")
  lb_bg.Width = 46
  lb_bg.Height = 49
  lb_bg.Left = 9
  lb_bg.Top = 10
  lb_bg.BackImage = online_player_backimage
  gb_player:Add(lb_bg)
  local playerName = util_text(nx_string(npc_id))
  local lb_name = gui:Create("Label")
  lb_name.Width = 60
  lb_name.Height = 22
  lb_name.Left = 62
  lb_name.Top = 10
  lb_name.Text = nx_widestr(playerName)
  lb_name.Font = "font_sns_list"
  lb_name.Align = "Left"
  lb_name.ForeColor = online_fore_color
  gb_player:Add(lb_name)
  local lb_menpai = gui:Create("Label")
  lb_menpai.Width = 86
  lb_menpai.Height = 22
  lb_menpai.Left = 62
  lb_menpai.Top = 30
  lb_menpai.AutoSize = true
  lb_menpai.ForeColor = "255,119,119,119"
  local origin = npc_id .. "_1"
  if gui.TextManager:IsIDName(nx_string(origin)) then
    origin = util_text(nx_string(origin))
  else
    origin = util_text(nx_string("ui_karma_none"))
  end
  lb_menpai.Text = nx_widestr(origin)
  lb_menpai.Font = "font_sns_list"
  lb_menpai.Align = "Left"
  local npc_news_num = get_npc_news(npc_id)
  local lbl_news_num = gui:Create("Label")
  lbl_news_num.Name = "lbl_news_num_" .. nx_string(npc_id)
  lbl_news_num.Top = lb_name.Top
  lbl_news_num.Left = -35
  lbl_news_num.AutoSize = true
  lbl_news_num.HAnchor = "Right"
  lbl_news_num.BackImage = "gui\\special\\sns_new\\btn_enchou_price\\icon_prompt_03.png"
  lbl_news_num.Text = nx_widestr(npc_news_num)
  lbl_news_num.Align = "Center"
  lbl_news_num.Font = "font_system_news"
  lbl_news_num.ForeColor = "255,255,255,255"
  gb_player:Add(lbl_news_num)
  if npc_news_num == nx_int(0) then
    lbl_news_num.Visible = false
  end
  gb_player:Add(lb_menpai)
  local playerIcon = ""
  local ItemQuery = nx_value("ItemQuery")
  if nx_is_valid(ItemQuery) then
    playerIcon = ItemQuery:GetItemPropByConfigID(npc_id, nx_string("Photo"))
  end
  if playerIcon == "" then
    playerIcon = "gui\\special\\sns_new\\sns_head\\common_head.png"
  end
  local lb_face = gui:Create("Label")
  lb_face.Width = 40
  lb_face.Height = 50
  lb_face.Left = 12
  lb_face.Top = 1
  lb_face.BackImage = playerIcon
  lb_face.DrawMode = "FitWindow"
  lb_face.BlendColor = "255,255,255,255"
  gb_player:Add(lb_face)
  local lbl_feeling = gui:Create("Label")
  lbl_feeling.Left = 8
  lbl_feeling.Top = 31
  lbl_feeling.ForeColor = "255,0,0,0"
  lbl_feeling.ShadowColor = "0,0,0,0"
  lbl_feeling.BackImage = "gui\\special\\sns_new\\icon_feeling.png"
  lbl_feeling.AutoSize = true
  lbl_feeling.DrawMode = "Tile"
  gb_player:Add(lbl_feeling)
  local lbl_head = gui:Create("Label")
  lbl_head.Left = 8
  lbl_head.Top = 31
  lbl_head.Width = 14
  lbl_head.Height = 18
  lbl_head.ForeColor = "255,0,0,0"
  lbl_head.ShadowColor = "0,0,0,0"
  lbl_head.BackImage = "gui\\mainform\\NPC\\Level_1.png"
  lbl_head.AutoSize = false
  lbl_head.DrawMode = "FitWindow"
  gb_player:Add(lbl_head)
  nx_execute("form_stage_main\\form_relationship", "set_karma_groupbox", lbl_feeling, lbl_head, relationvalue)
  gb_player.Name = "gb_player_" .. nx_string(npc_id)
  gb_player.Left = 20
  gb_player.Width = 200
  gb_player.Height = 62
  gb_player.NoFrame = true
  gb_player.BackColor = "0,255,255,255"
  gb_player.target = nx_widestr(playerName)
  gb_player.npc_id = npc_id
  gb_player.npc_scene_id = npc_scene_id
  gb_player.DrawMode = "FitWindow"
  local ctrlList = form.player_list:GetChildControlList()
  local ctrlCount = table.getn(ctrlList)
  gb_player.Top = 8 + 65 * ctrlCount
  if bChecked then
    gb_player.BackImage = "gui\\special\\sns\\bg_select.png"
  else
    gb_player.BackImage = ""
  end
  gb_player.is_npc = true
  nx_bind_script(gb_player, nx_current())
  nx_callback(gb_player, "on_left_double_click", "on_gb_npc_left_double_click")
  nx_callback(gb_player, "on_right_click", "on_gb_npc_right_click")
  nx_callback(gb_player, "on_get_capture", "on_gb_player_get_capture")
  nx_callback(gb_player, "on_lost_capture", "on_gb_player_lost_capture")
  form.player_list:Add(gb_player)
  return 1
end
function on_gb_npc_right_click(obj, x, y)
  if not nx_is_valid(obj) then
    return
  end
  if not nx_find_custom(obj, "npc_id") or not nx_find_custom(obj, "npc_scene_id") then
    return
  end
  local npc_id = obj.npc_id
  local scene_id = obj.npc_scene_id
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "select_npc_karma_list", "select_npc_karma_list")
  nx_execute("menu_game", "menu_recompose", menu_game, npc_id)
  menu_game.npc_id = nx_string(npc_id)
  menu_game.scene_id = nx_string(scene_id)
  gui:TrackPopupMenu(menu_game, x, y)
end
function on_gb_npc_left_double_click(self)
  local form = self.ParentForm
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local npc_id = self.npc_id
  local define_index = RELATION_SUB_FUJIN_FRIEND
  local form_fujin = nx_value("form_stage_main\\form_relation\\form_relation_fujin")
  if nx_is_valid(form_fujin) and form_fujin.Visible then
    define_index = RELATION_GROUP_FUJIN
    local group_id = sns_manager:GetGroupIdByDefineIndex(define_index)
    sns_manager:SetRelationType(group_id, 0)
    local bFocus = sns_manager:FocusPlayer(group_id, 0, nx_widestr(npc_id))
    if not bFocus and not is_cur_scene_num1(npc_id) then
      return
    end
    nx_execute("form_stage_main\\form_relation\\form_relation_fujin", "on_focus_change_event", group_id, 0, 0, npc_id)
  end
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  if nx_is_valid(form_renmai) and form_renmai.Visible then
    if form.PlayerType == FRIEND_TYPE then
      define_index = RELATION_SUB_GROUP_FRIEND
    elseif form.PlayerType == BUDDY_TYPE then
      define_index = RELATION_SUB_GROUP_BUDDY
    elseif form.PlayerType == BROTHER_TYPE then
      define_index = RELATION_TYPE_BROTHER
    elseif form.PlayerType == ENEMY_TYPE then
      define_index = RELATION_SUB_GROUP_ENEMY
    elseif form.PlayerType == BLOOD_TYPE then
      define_index = RELATION_SUB_GROUP_BLOOD
    elseif form.PlayerType == GUANZHU_TYPE then
      define_index = RELATION_SUB_GROUP_ATTENTION
    elseif form.PlayerType == ACQUAINT_TYPE then
      define_index = RELATION_SUB_GROUP_ACQUAINT
    elseif form.PlayerType == TEACHER_PUPIL_TYPE then
      define_index = RELATION_SUB_GROUP_TEACHER_PUPIL
    elseif form.PlayerType == NPC_FRIEND_TYPE then
      define_index = RELATION_SUB_GROUP_NPC_FRIEND
    elseif form.PlayerType == NPC_BUDDY_TYPE then
      define_index = RELATION_SUB_GROUP_NPC_BUDDY
    elseif form.PlayerType == NPC_ATTENTION_TYPE then
      define_index = RELATION_SUB_GROUP_NPC_ATTENTION
    end
    local group_id = sns_manager:GetGroupIdByDefineIndex(define_index)
    sns_manager:SetRelationType(group_id, 0)
    sns_manager:FocusPlayer(group_id, 0, nx_widestr(npc_id))
    nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_btnlist", group_id, npc_id, true)
    nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_player_name", npc_id)
  end
  form.CheckPlayerName = util_text(nx_string(npc_id))
  check_back_selected(form, util_text(nx_string(npc_id)))
end
function on_rbtn_haoyou_checked_changed(self)
  if self.Checked then
    local form = self.ParentForm
    form.player_list:DeleteAll()
    show_npc_relation(form, 0)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function on_rbtn_zhiyou_checked_changed(self)
  if self.Checked then
    local form = self.ParentForm
    form.player_list:DeleteAll()
    show_npc_relation(form, 1)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function on_rbtn_guan_checked_changed(self)
  if self.Checked then
    local form = self.ParentForm
    form.player_list:DeleteAll()
    show_npc_relation_gz(form)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function on_rbtn_fujin_checked_changed(self)
  if self.Checked then
    local form = self.ParentForm
    form.player_list:DeleteAll()
    show_npc_relation_fujin(form)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function on_rbtn_karma_checked_changed(self)
  if self.Checked then
    local karma_type = nx_int(string.sub(nx_string(self.Name), string.len("rbtn_karma_") + 1))
    local form = self.ParentForm
    form.player_list:DeleteAll()
    show_fujin_npc_by_karmatype(form, karma_type)
    form.player_list.IsEditMode = false
    form.player_list:ResetChildrenYPos()
  end
end
function show_friends_list_page(group_index)
  local form = nx_value("form_stage_main\\form_relation\\form_friend_list")
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_zhiyou.Visible = false
  form.rbtn_guan.Visible = false
  form.rbtn_fujin.Visible = false
  form.rbtn_haoyou.Visible = false
  if group_index == RELATION_SUB_FUJIN_ZHIYOU then
    form.rbtn_zhiyou.Checked = true
    form.rbtn_zhiyou.Visible = true
    form.rbtn_zhiyou.Top = 64
  elseif group_index == RELATION_SUB_FUJIN_GUANZHU then
    form.rbtn_guan.Checked = true
    form.rbtn_guan.Visible = true
    form.rbtn_guan.Top = 64
  elseif group_index == RELATION_SUB_FUJIN_FUJIN then
    form.rbtn_fujin.Checked = true
    form.rbtn_fujin.Visible = true
    form.rbtn_fujin.Top = 64
    for i = 1, 7 do
      local rbtn_karma = form.groupbox_npc_radiobutton:Find("rbtn_karma_" .. i)
      rbtn_karma.Visible = true
      rbtn_karma.Top = 64 + i * 50
    end
  else
    form.rbtn_haoyou.Checked = true
    form.rbtn_haoyou.Visible = true
    form.rbtn_haoyou.Top = 64
  end
end
function get_scene_id()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nx_int(-1)
  end
  local config_id = client_scene:QueryProp("ConfigID")
  local ini = nx_execute("util_functions", "get_ini", "ini\\scenes.ini")
  if not nx_is_valid(ini) then
    return nx_int(-1)
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local id = ini:GetSectionByIndex(i)
    local config = ini:ReadString(i, "Config", "")
    if nx_string(config) == nx_string(config_id) then
      return nx_int(id)
    end
  end
  return nx_int(-1)
end
function get_npc_news(npc_id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return 0
  end
  local res_list = karmamgr:GetNpcPrize(nx_string(npc_id))
  local news_count = nx_number(table.getn(res_list)) / 3
  return nx_int(news_count)
end
