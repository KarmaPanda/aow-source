require("share\\server_custom_define")
require("share\\client_custom_define")
require("const_define")
require("util_gui")
require("define\\jiuyinzhi_define")
local PAGESTATE_MAINPAGE = 0
local PAGESTATE_SUBPAGE1 = 1
local PAGESTATE_WAITMSG = 2
local PROGRESSSTATE_NULL = 0
local PROGRESSSTATE_PROGRESS = 1
local PROGRESSSTATE_COMPLETED = 2
local EVENT_TYPE_PROGRESS = 1
local EVENT_TYPE_RESULT = 2
local PROGRESS_LABEL_MAX_NUM_EACH_PAGE = 5
local EVENT_LABEL_MAX_NUM_EACH_PAGE = 4
local EVENT_MAX_NUM_EACH_PAGE = 2 * EVENT_LABEL_MAX_NUM_EACH_PAGE
local FORM_JIUYINZHI_MAIN_PATH = "form_stage_main\\form_9yinzhi"
local FORM_JIUYINZHI_MAIN_LUA_PATH = "form_stage_main\\form_9yinzhi\\form_9yinzhi_main"
local ImagePath_NoText = "gui\\special\\scroll_of_wulin\\"
local ImagePath_Text = "gui\\language\\ChineseS\\scroll_of_wulin\\"
local FixedImage = {
  pic_start = ImagePath_Text .. "sow_scroll_left.png",
  pic_middle = ImagePath_NoText .. "sow_scroll_middle.png",
  pic_end = ImagePath_NoText .. "sow_scroll_right.png",
  pic_event_progress = ImagePath_NoText .. "sow_scroll_1.png",
  pic_event_result = ImagePath_NoText .. "sow_scroll_2.png",
  story_in_progress = ImagePath_Text .. "sow_InProgress.png",
  story_completed = ImagePath_Text .. "sow_complete_2.png",
  event_progress_completed = ImagePath_Text .. "sow_complete_1.png",
  event_result_completed = ImagePath_Text .. "sow_unlock.png",
  pic_sow_scroll_on = ImagePath_NoText .. "sow_scroll_on.png",
  pic_sow_scroll_down = ImagePath_NoText .. "sow_scroll_down.png"
}
local SchoolIconPath = {
  ImagePath_Text .. "sow_logo_sl.png",
  ImagePath_Text .. "sow_logo_wd.png",
  ImagePath_Text .. "sow_logo_em.png",
  ImagePath_Text .. "sow_logo_gb.png",
  ImagePath_Text .. "sow_logo_jzt.png",
  ImagePath_Text .. "sow_logo_tm.png",
  ImagePath_Text .. "sow_logo_jyw.png",
  ImagePath_Text .. "sow_logo_jlg.png"
}
local mlt_text_in_group_table = {}
local lbl_school_icon_in_group_table = {}
local pic_state_in_group_table = {}
local mlt_title_in_group_table = {}
local mlt_color_text_in_group_table = {}
local picTable = {}
local picProgressTable = {}
local picStableTable = {}
local picStateTable = {}
local picNullTable = {}
local picTextTable = {}
local lbl_event_title_table = {}
local pic_rope_table = {}
local groupbox_event_table = {}
local btn_special_table = {}
local pic_cover_table = {}
local pic_lock_table = {}
local SERVER_MSGID_JIUYINZHI_ERROR = 1
local SERVER_MSGID_JIUYINZHI_EVENTCOUNT = 2
local SERVER_MSGID_JIUYINZHI_EVENT = 3
local SERVER_MSGID_JIUYINZHI_EVENT_DETAIL = 4
local SERVER_MSGID_JIUYINZHI_OPEN_AWARD_FORM = 5
local SERVER_MSGID_JIUYINZHI_CLOSE_AWARD_FORM = 6
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function sendCustomMsgGetInfo(msgID, ...)
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return false
  end
  if not client_role:FindProp("Name") then
    return false
  end
  local player_name = nx_widestr(client_role:QueryProp("Name"))
  if msgID == MSGID_JIUYINZHI_GET_EVENT then
    if table.getn(arg) > 0 then
      nx_execute("custom_sender", "custom_send_jyz_msg", player_name, nx_int(msgID), nx_int(arg[1]))
    end
  elseif msgID == MSGID_JIUYINZHI_GET_EVENT_DETAIL then
    if table.getn(arg) > 0 then
      nx_execute("custom_sender", "custom_send_jyz_msg", player_name, nx_int(msgID), nx_int(arg[1]))
    end
  elseif msgID == MSGID_JIUYINZHI_OPEN then
    nx_execute("custom_sender", "custom_send_jyz_msg", player_name, nx_int(msgID))
  elseif msgID == MSGID_JIUYINZHI_QUERY_HIGH_LIGHT then
    nx_execute("custom_sender", "custom_send_jyz_msg", player_name, nx_int(msgID))
  elseif msgID == MSGID_JIUYINZHI_UPDATE_VIEW_GAME_STEP then
    nx_execute("custom_sender", "custom_send_jyz_msg", player_name, nx_int(msgID))
  elseif msgID == MSGID_JIUYINZHI_GET_AWARD_EVENT and table.getn(arg) > 0 then
    nx_execute("custom_sender", "custom_send_jyz_msg", player_name, nx_int(msgID), nx_string(arg[1]))
  end
end
function parseEventString(str, num)
  local returnTable = util_split_string(str, ";")
  local n = table.getn(returnTable) - 1
  if num > n then
    for i = n + 1, num do
      returnTable[i] = ""
    end
  end
  return returnTable
end
function a(info)
  nx_msgbox(nx_string(info))
end
function custom_message_callback(pubDataName, msgID, ...)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if pubDataName == nil or msgID == nil then
    return
  end
  if nx_widestr(pubDataName) ~= nx_widestr("DomainJiuYinZhi") then
    return
  end
  local mainForm = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  local tempProgressNum = 0
  local tempReceiveCount = 0
  local receiveMsgID = nx_number(msgID)
  if receiveMsgID == SERVER_MSGID_JIUYINZHI_EVENTCOUNT or receiveMsgID == SERVER_MSGID_JIUYINZHI_EVENT or receiveMsgID == SERVER_MSGID_JIUYINZHI_EVENT_DETAIL then
    if not nx_is_valid(mainForm) then
      return
    end
    if nx_find_custom(mainForm, "ProgressNum") and mainForm.ProgressNum ~= nil then
      tempProgressNum = mainForm.ProgressNum
    end
    if nx_find_custom(mainForm, "ReceiveCount") and mainForm.ReceiveCount ~= nil then
      tempReceiveCount = mainForm.ReceiveCount
    end
    initSomeTable(mainForm)
  end
  if receiveMsgID == SERVER_MSGID_JIUYINZHI_EVENTCOUNT then
    if table.getn(arg) < 1 then
      return
    end
    tempReceiveCount = 0
    tempProgressNum = nx_number(arg[1])
    if 0 < tempProgressNum then
      for i = 1, tempProgressNum do
        local tableName = "ProgressTable" .. nx_string(i)
        common_array:AddArray(tableName, mainForm, 3600, false)
        sendCustomMsgGetInfo(MSGID_JIUYINZHI_GET_EVENT, i - 1)
      end
    end
    mainForm.ProgressNum = tempProgressNum
    mainForm.ReceiveCount = tempReceiveCount
    nx_set_value(FORM_JIUYINZHI_MAIN_PATH, mainForm)
  elseif receiveMsgID == SERVER_MSGID_JIUYINZHI_EVENT then
    if table.getn(arg) < 3 then
      return
    end
    local eventID = arg[1]
    if tempProgressNum <= eventID then
      return
    end
    local tableName = "ProgressTable" .. nx_string(eventID + 1)
    local ResName = nx_string(arg[2])
    local EventState = nx_number(arg[3])
    common_array:AddChild(tableName, "ResName", ResName)
    common_array:AddChild(tableName, "ProgressState", EventState)
    tempReceiveCount = tempReceiveCount + 1
    mainForm.ReceiveCount = tempReceiveCount
    nx_set_value(FORM_JIUYINZHI_MAIN_PATH, mainForm)
  elseif receiveMsgID == SERVER_MSGID_JIUYINZHI_EVENT_DETAIL then
    if table.getn(arg) < 8 then
      return
    end
    local eventID = arg[1]
    if tempProgressNum <= eventID then
      return
    end
    local tableName = "ProgressTable" .. nx_string(eventID + 1)
    local str_index = nx_string(arg[2])
    local tab_index = util_split_string(str_index, ",")
    local TotalEventProgressNum = table.getn(tab_index)
    local TotalEventResultNum = nx_number(arg[3])
    common_array:AddChild(tableName, "TotalEventProgressNum", TotalEventProgressNum)
    common_array:AddChild(tableName, "TotalEventResultNum", TotalEventResultNum)
    common_array:AddChild(tableName, "str_index", str_index)
    local subTableName = tableName .. "EventNecessary"
    common_array:AddArray(subTableName, mainForm, 3600, false)
    local eventNecessaryTable = parseEventString(nx_string(arg[4]), TotalEventProgressNum)
    for i = 1, TotalEventProgressNum do
      local index = tab_index[i]
      common_array:AddChild(subTableName, nx_string(i), eventNecessaryTable[i])
    end
    subTableName = tableName .. "EventProcessMax"
    common_array:AddArray(subTableName, mainForm, 3600, false)
    local eventProcessMaxTable = parseEventString(nx_string(arg[5]), TotalEventProgressNum)
    for i = 1, TotalEventProgressNum do
      common_array:AddChild(subTableName, nx_string(i), eventProcessMaxTable[i])
    end
    subTableName = tableName .. "EventProcess"
    common_array:AddArray(subTableName, mainForm, 3600, false)
    local eventProcessTable = parseEventString(nx_string(arg[6]), TotalEventProgressNum)
    for i = 1, TotalEventProgressNum do
      common_array:AddChild(subTableName, nx_string(i), eventProcessTable[i])
    end
    subTableName = tableName .. "EventCompleteMenPai"
    common_array:AddArray(subTableName, mainForm, 3600, false)
    local eventCompleteMenPaiTable = parseEventString(nx_string(arg[7]), TotalEventProgressNum)
    for i = 1, TotalEventProgressNum do
      common_array:AddChild(subTableName, nx_string(i), eventCompleteMenPaiTable[i])
    end
    subTableName = tableName .. "EventAssociate"
    common_array:AddArray(subTableName, mainForm, 3600, false)
    local eventAssociateTable = parseEventString(nx_string(arg[8]), TotalEventProgressNum)
    for i = 1, TotalEventProgressNum do
      common_array:AddChild(subTableName, nx_string(i), eventAssociateTable[i])
    end
    subTableName = tableName .. "EventDependence"
    common_array:AddArray(subTableName, mainForm, 3600, false)
    local eventDependenceTable = parseEventString(nx_string(arg[9]), TotalEventProgressNum)
    for i = 1, TotalEventProgressNum do
      common_array:AddChild(subTableName, nx_string(i), eventDependenceTable[i])
    end
    mainForm.PageState = PAGESTATE_SUBPAGE1
    mainForm.PageNum = 1
    clearControllerState()
    draw()
    nx_set_value(FORM_JIUYINZHI_MAIN_PATH, mainForm)
  elseif receiveMsgID == SERVER_MSGID_JIUYINZHI_OPEN_AWARD_FORM then
    nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_award", "open_form", unpack(arg))
    return
  elseif receiveMsgID == SERVER_MSGID_JIUYINZHI_CLOSE_AWARD_FORM then
    nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_award", "close_form")
    return
  elseif receiveMsgID == SERVER_MSGID_JIUYINZHI_ERROR then
    return
  else
    return
  end
  if (receiveMsgID == SERVER_MSGID_JIUYINZHI_EVENTCOUNT or receiveMsgID == SERVER_MSGID_JIUYINZHI_EVENT) and tempReceiveCount == tempProgressNum then
    util_show_form(FORM_JIUYINZHI_MAIN_PATH, true)
    mainForm.isOpenning = false
    nx_set_value(FORM_JIUYINZHI_MAIN_PATH, mainForm)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_opening_overtime", mainForm)
    end
  end
end
function open_form()
  nx_execute(FORM_JIUYINZHI_MAIN_LUA_PATH, "ansyn_open_9yinzhi")
end
function ansyn_open_9yinzhi()
  if nx_running(FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_open") then
    return
  end
  if nx_running(FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_close") then
    return
  end
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if nx_is_valid(form) and form.isOpenning then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form) then
    timer:UnRegister(FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_close", form)
  end
  nx_execute(FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_open")
end
function ansyn_close_9yinzhi()
  util_show_form(FORM_JIUYINZHI_MAIN_PATH, false)
  if nx_running(FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_open") then
    return
  end
  if nx_running(FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_close") then
    return
  end
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  local timer = nx_value("timer_game")
  if nx_is_valid(form) and nx_is_valid(timer) then
    timer:Register(2000, 1, FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_close", form, -1, -1)
  end
end
function tread_open()
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  local form = util_get_form(FORM_JIUYINZHI_MAIN_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  form.isOpenning = true
  nx_set_value(FORM_JIUYINZHI_MAIN_PATH, form)
  timer:UnRegister(FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_opening_overtime", form)
  timer:Register(2000, 1, FORM_JIUYINZHI_MAIN_LUA_PATH, "tread_opening_overtime", form, -1, -1)
  sendCustomMsgGetInfo(MSGID_JIUYINZHI_OPEN)
end
function tread_close()
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if nx_is_valid(form) then
    nx_remove_value(FORM_JIUYINZHI_MAIN_PATH)
    nx_destroy(form)
  end
end
function tread_opening_overtime()
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.isOpenning = false
  nx_set_value(FORM_JIUYINZHI_MAIN_PATH, form)
end
function initVariables(form)
  local OldPageState = nx_value("jyz_old_pagestate")
  local OldPageNum = nx_value("jyz_old_pagenum")
  local OldSub1PageNum = nx_value("jyz_old_sub1pagenum")
  local OldSelectedIndex = nx_value("jyz_old_selectedindex")
  if OldPageState and OldPageState >= PAGESTATE_MAINPAGE and OldPageState <= PAGESTATE_SUBPAGE1 then
    form.PageState = OldPageState
  else
    form.PageState = PAGESTATE_MAINPAGE
  end
  if OldPageNum and nx_number(OldPageNum) >= 1 then
    form.PageNum = OldPageNum
  else
    form.PageNum = 1
  end
  if OldSub1PageNum and nx_number(OldSub1PageNum) >= 1 then
    form.Sub1PageNum = OldSub1PageNum
  else
    form.Sub1PageNum = 1
  end
  if OldSelectedIndex and nx_number(OldSelectedIndex) >= 1 then
    form.SelectedIndex = OldSelectedIndex
  else
    form.SelectedIndex = 1
  end
  form.TotalPageNum = 1
  form.TotalSub1PageNum = 1
  if not form.ProgressNum then
    form.ProgressNum = 0
  end
  if form.PageState == PAGESTATE_SUBPAGE1 then
    local sub1IsValid = IsSub1PageValid(form, form.SelectedIndex)
    if not sub1IsValid then
      form.PageState = PAGESTATE_MAINPAGE
      form.PageNum = 1
      form.Sub1PageNum = 1
      form.SelectedIndex = 1
    end
  end
end
function initSomeTable(form)
  groupbox_event_table = {
    form.groupscrollbox_01,
    form.groupscrollbox_02,
    form.groupscrollbox_11,
    form.groupscrollbox_12,
    form.groupscrollbox_21,
    form.groupscrollbox_22,
    form.groupscrollbox_31,
    form.groupscrollbox_32
  }
  mlt_text_in_group_table = {
    form.mlt_text_in_group_01,
    form.mlt_text_in_group_02,
    form.mlt_text_in_group_11,
    form.mlt_text_in_group_12,
    form.mlt_text_in_group_21,
    form.mlt_text_in_group_22,
    form.mlt_text_in_group_31,
    form.mlt_text_in_group_32
  }
  pic_state_in_group_table = {
    form.pic_state_in_group_01,
    form.pic_state_in_group_02,
    form.pic_state_in_group_11,
    form.pic_state_in_group_12,
    form.pic_state_in_group_21,
    form.pic_state_in_group_22,
    form.pic_state_in_group_31,
    form.pic_state_in_group_32
  }
  mlt_color_text_in_group_table = {
    form.mlt_color_text_in_group_01,
    form.mlt_color_text_in_group_02,
    form.mlt_color_text_in_group_11,
    form.mlt_color_text_in_group_12,
    form.mlt_color_text_in_group_21,
    form.mlt_color_text_in_group_22,
    form.mlt_color_text_in_group_31,
    form.mlt_color_text_in_group_32
  }
  lbl_school_icon_in_group_table = {
    form.lbl_school_icon_01,
    form.lbl_school_icon_02,
    form.lbl_school_icon_11,
    form.lbl_school_icon_12,
    form.lbl_school_icon_21,
    form.lbl_school_icon_22,
    form.lbl_school_icon_31,
    form.lbl_school_icon_32
  }
  mlt_title_in_group_table = {
    form.mlt_title_in_group_01,
    form.mlt_title_in_group_02,
    form.mlt_title_in_group_11,
    form.mlt_title_in_group_12,
    form.mlt_title_in_group_21,
    form.mlt_title_in_group_22,
    form.mlt_title_in_group_31,
    form.mlt_title_in_group_32
  }
  picTable = {
    form.pic_1,
    form.pic_2,
    form.pic_3,
    form.pic_4,
    form.pic_5,
    form.pic_6,
    form.pic_7
  }
  picProgressTable = {
    form.pic_progress_1,
    form.pic_progress_2,
    form.pic_progress_3,
    form.pic_progress_4,
    form.pic_progress_5
  }
  pic_cover_table = {
    form.pic_cover_1,
    form.pic_cover_2,
    form.pic_cover_3,
    form.pic_cover_4,
    form.pic_cover_5
  }
  picStateTable = {
    form.pic_2_state,
    form.pic_3_state,
    form.pic_4_state,
    form.pic_5_state,
    form.pic_6_state
  }
  picStableTable = {
    form.pic_stable_1,
    form.pic_stable_2
  }
  picNullTable = {
    form.pic_1_null,
    form.pic_2_null,
    form.pic_3_null,
    form.pic_4_null,
    form.pic_5_null
  }
  picTextTable = {
    form.pic_1_text,
    form.pic_2_text,
    form.pic_3_text,
    form.pic_4_text,
    form.pic_5_text
  }
  lbl_event_title_table = {
    form.lbl_1_event_title,
    form.lbl_2_event_title,
    form.lbl_3_event_title,
    form.lbl_4_event_title
  }
  pic_rope_table = {
    form.pic_rope_01,
    form.pic_rope_02,
    form.pic_rope_11,
    form.pic_rope_12,
    form.pic_rope_21,
    form.pic_rope_22,
    form.pic_rope_31,
    form.pic_rope_32,
    form.pic_rope_41,
    form.pic_rope_42,
    form.pic_rope_51,
    form.pic_rope_52
  }
  pic_lock_table = {
    form.pic_lock_1_1,
    form.pic_lock_1_2,
    form.pic_lock_2_1,
    form.pic_lock_2_2,
    form.pic_lock_3_1,
    form.pic_lock_3_2,
    form.pic_lock_4_1,
    form.pic_lock_4_2
  }
  btn_special_table = {
    form.btn_special_1,
    form.btn_special_2,
    form.btn_special_3,
    form.btn_special_4,
    form.btn_special_5
  }
end
function main_form_init(form)
  form.Fixed = false
  return
end
function on_main_form_open(form)
  initVariables(form)
  initSomeTable(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  if form.PageState == PAGESTATE_MAINPAGE then
    clearControllerState()
    draw()
  elseif form.PageState == PAGESTATE_SUBPAGE1 then
    clearControllerState()
    mainPagePicLeftDown(form, form.SelectedIndex)
  end
end
function on_main_form_close(form)
  nx_set_value("jyz_old_pagestate", form.PageState)
  nx_set_value("jyz_old_pagenum", form.PageNum)
  nx_set_value("jyz_old_sub1pagenum", form.Sub1PageNum)
  nx_set_value("jyz_old_selectedindex", form.SelectedIndex)
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) and form.ProgressNum then
    for i = 1, form.ProgressNum do
      local tableName = "ProgressTable" .. nx_string(i)
      common_array:RemoveArray(tableName)
      local subTableName = tableName .. "EventNecessary"
      common_array:RemoveArray(subTableName)
      subTableName = tableName .. "EventProcessMax"
      common_array:RemoveArray(subTableName)
      subTableName = tableName .. "EventProcess"
      common_array:RemoveArray(subTableName)
      subTableName = tableName .. "EventCompleteMenPai"
      common_array:RemoveArray(subTableName)
      subTableName = tableName .. "EventAssociate"
      common_array:RemoveArray(subTableName)
      subTableName = tableName .. "EventDependence"
      common_array:RemoveArray(subTableName)
    end
    form.ProgressNum = nil
  end
  form.PageState = nil
  form.PageNum = nil
  form.TotalPageNum = nil
  form.Sub1PageNum = nil
  form.TotalSub1PageNum = nil
  form.SelectedIndex = nil
  if form.ProgressNum then
    form.ProgressNum = nil
  end
  if form.ReceiveCount then
    form.ReceiveCount = nil
  end
end
function set_open_state(args)
  local arglist = parseEventString(args, 4)
  local pageState = nx_int(arglist[1])
  local pageNum = nx_int(arglist[2])
  local selectedIndex = nx_int(arglist[3])
  local sub1PageNum = nx_int(arglist[4])
  nx_set_value("jyz_old_pagestate", pageState)
  nx_set_value("jyz_old_pagenum", pageNum)
  nx_set_value("jyz_old_sub1pagenum", sub1PageNum)
  nx_set_value("jyz_old_selectedindex", selectedIndex)
end
function on_form_active(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  ui_show_attached_form(form)
end
function on_btn_close_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  ui_destroy_attached_form(form)
  ansyn_close_9yinzhi()
end
function clearControllerState()
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 7 do
    picTable[i].Image = ""
    picTable[i].HintText = nx_widestr("")
    picTable[i].Visible = false
  end
  for i = 2, 6 do
    picTable[i].Transparent = false
  end
  for i = 1, 5 do
    picProgressTable[i].Image = ""
    picProgressTable[i].Visible = false
    pic_cover_table[i].Image = ""
    pic_cover_table[i].Visible = false
    picStateTable[i].Image = ""
    picStateTable[i].Visible = false
    picTextTable[i].Image = ""
    picTextTable[i].Visible = false
    picNullTable[i].Visible = false
    btn_special_table[i].HintText = nx_widestr("")
    btn_special_table[i].Visible = false
  end
  for i = 1, 2 do
    picStableTable[i].Visible = false
  end
  for i = 1, 8 do
    groupbox_event_table[i].Visible = false
    pic_state_in_group_table[i].Image = ""
    pic_state_in_group_table[i].Visible = false
    lbl_school_icon_in_group_table[i].BackImage = ""
    lbl_school_icon_in_group_table[i].Visible = false
    mlt_text_in_group_table[i]:Clear()
    mlt_text_in_group_table[i].Visible = false
    mlt_color_text_in_group_table[i]:Clear()
    mlt_color_text_in_group_table[i].Visible = false
    mlt_title_in_group_table[i]:Clear()
    mlt_title_in_group_table[i].Visible = false
    pic_lock_table[i].Visible = false
  end
  for i = 1, 4 do
    lbl_event_title_table[i].Text = nx_widestr("")
    lbl_event_title_table[i].HintText = nx_widestr("")
    lbl_event_title_table[i].Visible = false
  end
  for i = 1, 12 do
    pic_rope_table[i].Visible = false
  end
  form.pic_subpage1_text.Image = ""
  form.pic_subpage1_text.Visible = false
  form.lbl_PageNum1.Text = nx_widestr("")
  form.lbl_PageNum1.Visible = false
  form.lbl_PageNum2.Text = nx_widestr("")
  form.lbl_PageNum2.Visible = false
  form.btn_return.Visible = false
  form.btn_page_pre.Visible = false
  form.btn_page_next.Visible = false
  form.btn_close.Visible = false
  form.pic_end_lable_text.Visible = false
  if form.ProgressNum == 0 then
    form.TotalPageNum = 1
  else
    form.TotalPageNum = math.ceil(form.ProgressNum / PROGRESS_LABEL_MAX_NUM_EACH_PAGE)
  end
  if 1 > form.PageNum or form.PageNum > form.TotalPageNum then
    form.PageNum = 1
  end
end
function get_text_index(event_index)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local tableName = "ProgressTable" .. nx_string(form.SelectedIndex)
  local str_index = nx_string(common_array:FindChild(tableName, "str_index"))
  local tab_index = util_split_string(str_index, ",")
  return tab_index[nx_number(event_index)] + 1
end
function UpdateEventGroupBox(eventType, isCompleted, groupIndex, eventIndex, resName, arg1, arg2, arg3, arg4)
  if nx_int(arg1) > nx_int(arg2) then
    arg1 = arg2
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local textID = ""
  if eventType == EVENT_TYPE_PROGRESS then
    textID = "ui_jiuyinzhi_" .. resName .. "_ep_" .. nx_string(eventIndex)
  elseif eventType == EVENT_TYPE_RESULT then
    textID = "ui_jiuyinzhi_" .. resName .. "_er_" .. nx_string(eventIndex)
  end
  local mltTextStr = gui.TextManager:GetFormatText(textID)
  mlt_text_in_group_table[groupIndex]:Clear()
  mlt_text_in_group_table[groupIndex]:AddHtmlText(mltTextStr, -1)
  if eventType == EVENT_TYPE_PROGRESS then
    if 0 < arg2 then
      textID = "ui_jiuyinzhi_" .. resName .. "_ep_" .. nx_string(eventIndex) .. "_title"
      local titleText = gui.TextManager:GetFormatText(textID)
      mlt_title_in_group_table[groupIndex]:Clear()
      mlt_title_in_group_table[groupIndex]:AddHtmlText(titleText, -1)
      local colorText
      if isCompleted then
        colorText = nx_widestr("<font color=\"#006400\">(</font><font face=\"font_conten_tasktrace\" color=\"#BBEB37\">" .. nx_string(arg1) .. "/" .. nx_string(arg2) .. "</font><font color=\"#006400\">)</font>")
      else
        colorText = nx_widestr("<font color=\"#006400\">(</font><font face=\"Default\" color=\"#006400\">" .. nx_string(arg1) .. "/" .. nx_string(arg2) .. "</font><font color=\"#006400\">)</font>")
      end
      mlt_color_text_in_group_table[groupIndex]:Clear()
      mlt_color_text_in_group_table[groupIndex]:AddHtmlText(colorText, -1)
      nx_bind_script(mlt_color_text_in_group_table[groupIndex], "")
      textID = "ui_jiuyinzhi_" .. resName .. "_ep_" .. nx_string(eventIndex) .. "_tip"
      local hintText = gui.TextManager:GetFormatText(textID, unpack(arg4))
      mlt_title_in_group_table[groupIndex].HintText = hintText
      mlt_color_text_in_group_table[groupIndex].HintText = hintText
    end
  elseif eventType == EVENT_TYPE_RESULT then
    textID = "ui_jiuyinzhi_" .. resName .. "_er_" .. nx_string(eventIndex) .. "_title"
    local titleText = gui.TextManager:GetFormatText(textID)
    mlt_title_in_group_table[groupIndex]:Clear()
    mlt_title_in_group_table[groupIndex]:AddHtmlText(titleText, -1)
    textID = "ui_jiuyinzhi_" .. resName .. "_er_" .. nx_string(eventIndex) .. "_color_text"
    local tempText = gui.TextManager:GetFormatText(textID)
    textID = "ui_jiuyinzhi_" .. resName .. "_er_" .. nx_string(eventIndex) .. "_hyperlink"
    local history_hyperlink_item = nx_string(gui.TextManager:GetFormatText(textID))
    if textID == history_hyperlink_item then
      history_hyperlink_item = nx_string("")
      nx_bind_script(mlt_color_text_in_group_table[groupIndex], "")
    else
      nx_bind_script(mlt_color_text_in_group_table[groupIndex], nx_current())
      nx_callback(mlt_color_text_in_group_table[groupIndex], "on_click_hyperlink", "click_hyperlink")
    end
    history_hyperlink_item = nx_widestr("<a href=\"") .. nx_widestr(history_hyperlink_item) .. nx_widestr("\" style=\"HLStype1\">(") .. nx_widestr(tempText) .. nx_widestr(")</a>")
    mlt_color_text_in_group_table[groupIndex]:Clear()
    mlt_color_text_in_group_table[groupIndex]:AddHtmlText(history_hyperlink_item, -1)
    textID = "ui_jiuyinzhi_" .. resName .. "_er_" .. nx_string(eventIndex) .. "_tip"
    local hintText = gui.TextManager:GetFormatText(textID)
    mlt_title_in_group_table[groupIndex].HintText = hintText
    mlt_color_text_in_group_table[groupIndex].HintText = hintText
  end
  mlt_text_in_group_table[groupIndex].Height = mlt_text_in_group_table[groupIndex]:GetContentHeight()
  mlt_title_in_group_table[groupIndex].Height = mlt_title_in_group_table[groupIndex]:GetContentHeight()
  mlt_title_in_group_table[groupIndex].Width = mlt_title_in_group_table[groupIndex]:GetContentWidth()
  mlt_color_text_in_group_table[groupIndex].Height = mlt_color_text_in_group_table[groupIndex]:GetContentHeight()
  mlt_color_text_in_group_table[groupIndex].Width = mlt_color_text_in_group_table[groupIndex]:GetContentWidth()
  groupbox_event_table[groupIndex].VScrollBar.Value = 0
  if eventType == EVENT_TYPE_PROGRESS then
    if arg3 == 1 then
      lbl_school_icon_in_group_table[groupIndex].BackImage = SchoolIconPath[1]
    else
      lbl_school_icon_in_group_table[groupIndex].BackImage = SchoolIconPath[arg3 - 1]
      local hintText = gui.TextManager:GetFormatText("tips_jiuyinzhi_school_icon")
      lbl_school_icon_in_group_table[groupIndex].HintText = hintText
    end
    mlt_title_in_group_table[groupIndex].Top = 0
    mlt_color_text_in_group_table[groupIndex].Top = mlt_title_in_group_table[groupIndex].Top + mlt_title_in_group_table[groupIndex].Height + 4
    lbl_school_icon_in_group_table[groupIndex].Top = mlt_color_text_in_group_table[groupIndex].Top + mlt_color_text_in_group_table[groupIndex].Height
    if isCompleted then
      pic_state_in_group_table[groupIndex].Image = FixedImage.event_progress_completed
      pic_state_in_group_table[groupIndex].Top = lbl_school_icon_in_group_table[groupIndex].Top + 8
      pic_state_in_group_table[groupIndex].Left = mlt_title_in_group_table[groupIndex].Left
      pic_state_in_group_table[groupIndex].Visible = true
    end
    if lbl_school_icon_in_group_table[groupIndex].Visible then
      mlt_text_in_group_table[groupIndex].Top = lbl_school_icon_in_group_table[groupIndex].Top + lbl_school_icon_in_group_table[groupIndex].Height + 4
    elseif pic_state_in_group_table[groupIndex].Visible then
      mlt_text_in_group_table[groupIndex].Top = pic_state_in_group_table[groupIndex].Top + pic_state_in_group_table[groupIndex].Height + 4
    else
      mlt_text_in_group_table[groupIndex].Top = mlt_color_text_in_group_table[groupIndex].Top + mlt_color_text_in_group_table[groupIndex].Height + 4
    end
    mlt_title_in_group_table[groupIndex].Left = mlt_text_in_group_table[groupIndex].Left
    mlt_color_text_in_group_table[groupIndex].Left = mlt_title_in_group_table[groupIndex].Left
    lbl_school_icon_in_group_table[groupIndex].Left = groupbox_event_table[groupIndex].Width - lbl_school_icon_in_group_table[groupIndex].Width - groupbox_event_table[groupIndex].VScrollBar.Width
  elseif eventType == EVENT_TYPE_RESULT then
    mlt_title_in_group_table[groupIndex].Top = 0
    mlt_color_text_in_group_table[groupIndex].Top = mlt_title_in_group_table[groupIndex].Top + mlt_title_in_group_table[groupIndex].Height + 4
    mlt_title_in_group_table[groupIndex].Left = mlt_text_in_group_table[groupIndex].Left
    mlt_color_text_in_group_table[groupIndex].Left = mlt_title_in_group_table[groupIndex].Left
    if isCompleted then
      lbl_school_icon_in_group_table[groupIndex].Image = SchoolIconPath[1]
      pic_state_in_group_table[groupIndex].Image = FixedImage.event_result_completed
      lbl_school_icon_in_group_table[groupIndex].Top = mlt_color_text_in_group_table[groupIndex].Top + mlt_color_text_in_group_table[groupIndex].Height
      pic_state_in_group_table[groupIndex].Top = lbl_school_icon_in_group_table[groupIndex].Top + 8
      mlt_text_in_group_table[groupIndex].Top = pic_state_in_group_table[groupIndex].Top + pic_state_in_group_table[groupIndex].Height + 4
      pic_state_in_group_table[groupIndex].Left = mlt_title_in_group_table[groupIndex].Left
      pic_state_in_group_table[groupIndex].Visible = true
    else
      mlt_text_in_group_table[groupIndex].Top = mlt_color_text_in_group_table[groupIndex].Top + mlt_color_text_in_group_table[groupIndex].Height + 4
    end
  end
  mlt_color_text_in_group_table[groupIndex].Visible = true
  mlt_title_in_group_table[groupIndex].Visible = true
  mlt_text_in_group_table[groupIndex].Visible = true
  groupbox_event_table[groupIndex].Visible = true
  groupbox_event_table[groupIndex].HasVScroll = groupbox_event_table[groupIndex].HasVScroll
  local largeChange = groupbox_event_table[groupIndex].VScrollBar.TrackButton.Height * groupbox_event_table[groupIndex].VScrollBar.Maximum
  largeChange = largeChange / (groupbox_event_table[groupIndex].VScrollBar.Height - groupbox_event_table[groupIndex].VScrollBar.TrackButton.Height)
  groupbox_event_table[groupIndex].VScrollBar.LargeChange = largeChange
  groupbox_event_table[groupIndex].IsEditMode = false
end
function draw()
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    for i = 1, 7 do
      if i == 1 then
        picTable[i].Image = FixedImage.pic_start
      elseif i == 7 then
        picTable[i].Image = FixedImage.pic_end
        form.pic_end_lable_text.Left = picTable[i].Left
        form.pic_end_lable_text.Visible = true
      else
        picTable[i].Image = FixedImage.pic_middle
      end
      picTable[i].Visible = true
    end
    for i = 1, 12 do
      pic_rope_table[i].Visible = true
    end
    form.Width = picTable[7].Left + picTable[7].Width
    form.btn_close.Left = form.Width - form.btn_close.Width - 9
    form.btn_close.Visible = true
    picStableTable[2].Visible = true
    picStableTable[1].Visible = true
    form.lbl_PageNum1.Text = nx_widestr(form.PageNum)
    form.lbl_PageNum2.Text = nx_widestr(form.TotalPageNum)
    form.lbl_PageNum1.Visible = true
    form.lbl_PageNum2.Visible = true
    if 1 < form.PageNum then
      form.btn_page_pre.Visible = true
      form.btn_page_pre.Left = 888
    end
    if form.PageNum < form.TotalPageNum then
      form.btn_page_next.Visible = true
      form.btn_page_next.Left = 888
    end
    local baseNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE
    for i = 1, 5 do
      if baseNum + i <= form.ProgressNum then
        local tableName = "ProgressTable" .. nx_string(baseNum + i)
        local ResName = nx_string(common_array:FindChild(tableName, "ResName"))
        local proState = nx_number(common_array:FindChild(tableName, "ProgressState"))
        if proState == PROGRESSSTATE_PROGRESS then
          picProgressTable[i].Image = ImagePath_NoText .. ResName .. "_background_1.png"
          picStateTable[i].Image = FixedImage.story_in_progress
        elseif proState == PROGRESSSTATE_COMPLETED then
          picProgressTable[i].Image = ImagePath_NoText .. ResName .. "_background_1_complete.png"
          picStateTable[i].Image = FixedImage.story_completed
        end
        picProgressTable[i].Visible = true
        picStateTable[i].Visible = true
        picTextTable[i].Image = ImagePath_Text .. ResName .. "_text_1.png"
        picTextTable[i].Left = picProgressTable[i].Left + (picProgressTable[i].Width - picTextTable[i].Width) / 2
        picTextTable[i].Top = picProgressTable[i].Top + picProgressTable[i].Height - picTextTable[i].Height
        picTextTable[i].Visible = true
        local textID = "ui_jiuyinzhi_" .. ResName .. "_event_tips"
        picTable[i + 1].HintText = gui.TextManager:GetFormatText(textID)
        local event_close_text_id, event_open_text_id
        event_close_text_id = "text_jiuyinzhi_" .. ResName .. "_close"
        event_open_text_id = "text_jiuyinzhi_" .. ResName .. "_open"
        btn_special_table[i].ForeColor = "255,196,136,115"
        if proState == PROGRESSSTATE_PROGRESS then
          btn_special_table[i].NormalImage = ImagePath_NoText .. "sow_combobox_2.png"
          btn_special_table[i].FocusImage = ImagePath_NoText .. "sow_combobox_2.png"
          btn_special_table[i].PushImage = ImagePath_NoText .. "sow_combobox_2.png"
          btn_special_table[i].Text = gui.TextManager:GetFormatText(event_close_text_id)
        elseif proState == PROGRESSSTATE_COMPLETED then
          btn_special_table[i].NormalImage = ImagePath_NoText .. "sow_combobox_1.png"
          btn_special_table[i].FocusImage = ImagePath_NoText .. "sow_combobox_1.png"
          btn_special_table[i].PushImage = ImagePath_NoText .. "sow_combobox_1.png"
          btn_special_table[i].Text = gui.TextManager:GetFormatText(event_open_text_id)
        end
        btn_special_table[i].HintText = gui.TextManager:GetFormatText(textID)
        btn_special_table[i].Left = picProgressTable[i].Left + (picProgressTable[i].Width - btn_special_table[i].Width) / 2
        btn_special_table[i].Top = picProgressTable[i].Top + picProgressTable[i].Height - btn_special_table[i].Height - 24
        btn_special_table[i].Visible = true
      else
        picNullTable[i].Left = picProgressTable[i].Left + (picProgressTable[i].Width - picNullTable[i].Width) / 2
        picNullTable[i].Top = picProgressTable[i].Top + (picProgressTable[i].Height - picNullTable[i].Height) / 2
        picNullTable[i].Visible = true
      end
    end
  elseif form.PageState == PAGESTATE_SUBPAGE1 then
    nx_assert(form.SelectedIndex <= form.ProgressNum)
    local tableName = "ProgressTable" .. nx_string(form.SelectedIndex)
    local ResName = nx_string(common_array:FindChild(tableName, "ResName"))
    local TotalEventProNum = common_array:FindChild(tableName, "TotalEventProgressNum")
    local TotalEventResNum = common_array:FindChild(tableName, "TotalEventResultNum")
    local ProgressLabelNum = math.ceil(TotalEventProNum / 2)
    local ResultLabelNum = math.ceil(TotalEventResNum / 2)
    form.TotalSub1PageNum = math.ceil((ProgressLabelNum + ResultLabelNum) / EVENT_LABEL_MAX_NUM_EACH_PAGE)
    if 1 > form.Sub1PageNum or form.Sub1PageNum > form.TotalSub1PageNum then
      form.Sub1PageNum = 1
    end
    picStableTable[1].Visible = true
    form.lbl_PageNum1.Text = nx_widestr(form.Sub1PageNum)
    form.lbl_PageNum2.Text = nx_widestr(form.TotalSub1PageNum)
    form.lbl_PageNum1.Visible = true
    form.lbl_PageNum2.Visible = true
    if 1 < form.Sub1PageNum then
      form.btn_page_pre.Visible = true
    end
    if form.Sub1PageNum < form.TotalSub1PageNum then
      form.btn_page_next.Visible = true
    end
    picProgressTable[1].Image = ImagePath_NoText .. ResName .. "_background_2.png"
    picProgressTable[1].Visible = true
    local proState = nx_number(common_array:FindChild(tableName, "ProgressState"))
    if proState == PROGRESSSTATE_PROGRESS then
      picStateTable[1].Image = FixedImage.story_in_progress
    elseif proState == PROGRESSSTATE_COMPLETED then
      picStateTable[1].Image = FixedImage.story_completed
    end
    picStateTable[1].Visible = true
    form.pic_subpage1_text.Image = ImagePath_Text .. ResName .. "_text_2.png"
    form.pic_subpage1_text.Left = picProgressTable[1].Left + (picProgressTable[1].Width - form.pic_subpage1_text.Width) / 2
    form.pic_subpage1_text.Top = picProgressTable[1].Top + picProgressTable[1].Height - form.pic_subpage1_text.Height
    form.pic_subpage1_text.Visible = true
    local event_close_text_id, event_open_text_id
    event_close_text_id = "text_jiuyinzhi_" .. ResName .. "_close"
    event_open_text_id = "text_jiuyinzhi_" .. ResName .. "_open"
    btn_special_table[1].ForeColor = "255,196,136,115"
    if proState == PROGRESSSTATE_PROGRESS then
      btn_special_table[1].NormalImage = ImagePath_NoText .. "sow_combobox_2.png"
      btn_special_table[1].FocusImage = ImagePath_NoText .. "sow_combobox_2.png"
      btn_special_table[1].PushImage = ImagePath_NoText .. "sow_combobox_2.png"
      btn_special_table[1].Text = gui.TextManager:GetFormatText(event_close_text_id)
    elseif proState == PROGRESSSTATE_COMPLETED then
      btn_special_table[1].NormalImage = ImagePath_NoText .. "sow_combobox_1.png"
      btn_special_table[1].FocusImage = ImagePath_NoText .. "sow_combobox_1.png"
      btn_special_table[1].PushImage = ImagePath_NoText .. "sow_combobox_1.png"
      btn_special_table[1].Text = gui.TextManager:GetFormatText(event_open_text_id)
    end
    btn_special_table[1].Left = picProgressTable[1].Left + (picProgressTable[1].Width - btn_special_table[1].Width) / 2
    btn_special_table[1].Top = picProgressTable[1].Top + picProgressTable[1].Height - btn_special_table[1].Height - 24
    btn_special_table[1].Visible = true
    local baseProgressLabelIndex = (form.Sub1PageNum - 1) * EVENT_LABEL_MAX_NUM_EACH_PAGE
    local baseResultLabelIndex = 0
    local progressLabelNumOnPage = 0
    local eventProgressNumOnPage = 0
    if ProgressLabelNum > baseProgressLabelIndex then
      for i = baseProgressLabelIndex + 1, ProgressLabelNum do
        if progressLabelNumOnPage >= EVENT_LABEL_MAX_NUM_EACH_PAGE then
          break
        end
        progressLabelNumOnPage = progressLabelNumOnPage + 1
        picProgressTable[progressLabelNumOnPage + 1].Image = FixedImage.pic_event_progress
        picProgressTable[progressLabelNumOnPage + 1].Visible = true
        lbl_event_title_table[progressLabelNumOnPage].Text = gui.TextManager:GetFormatText("text_jiuyinzhi_eventprogress")
        lbl_event_title_table[progressLabelNumOnPage].HintText = gui.TextManager:GetFormatText("text_jiuyinzhi_eventprogress_tips")
        lbl_event_title_table[progressLabelNumOnPage].Visible = true
      end
      for i = baseProgressLabelIndex * 2 + 1, TotalEventProNum do
        if eventProgressNumOnPage >= EVENT_MAX_NUM_EACH_PAGE then
          break
        end
        eventProgressNumOnPage = eventProgressNumOnPage + 1
        local subTableName = tableName .. "EventProcessMax"
        local maxProcess = nx_number(common_array:FindChild(subTableName, nx_string(i)))
        subTableName = tableName .. "EventProcess"
        local curProcess = nx_number(common_array:FindChild(subTableName, nx_string(i)))
        subTableName = tableName .. "EventCompleteMenPai"
        local schoolType = nx_number(common_array:FindChild(subTableName, nx_string(i)))
        subTableName = tableName .. "EventAssociate"
        local strAssociateEp = nx_string(common_array:FindChild(subTableName, nx_string(i)))
        local associateEpTable = {}
        if strAssociateEp ~= "" then
          associateEpTable = util_split_string(strAssociateEp, ",")
        end
        local assTableNum = table.getn(associateEpTable)
        if nx_number(assTableNum) > nx_number(0) then
          associateEpTable[assTableNum] = nil
        end
        if nx_number(assTableNum) > nx_number(1) then
          for assTableIndex = 1, assTableNum - 1 do
            if nx_number(associateEpTable[assTableIndex]) > nx_number(0) then
              associateEpTable[assTableIndex] = gui.TextManager:GetFormatText("jyz_completed")
            else
              associateEpTable[assTableIndex] = gui.TextManager:GetFormatText("jyz_not_completed")
            end
          end
        end
        subTableName = tableName .. "EventDependence"
        local bIsGray = false
        if nx_number(common_array:FindChild(subTableName, nx_string(i))) ~= nx_number(0) then
          bIsGray = true
        end
        if bIsGray then
          pic_lock_table[i].Visible = true
          local lockTips = "jyz_" .. ResName .. "_lock_" .. nx_string(i)
          pic_lock_table[i].HintText = gui.TextManager:GetFormatText(lockTips)
        end
        local bIsComplete = false
        if maxProcess <= curProcess then
          bIsComplete = true
        end
        local text_index = get_text_index(i)
        UpdateEventGroupBox(EVENT_TYPE_PROGRESS, bIsComplete, eventProgressNumOnPage, text_index, ResName, curProcess, maxProcess, schoolType, associateEpTable)
      end
    else
      baseResultLabelIndex = baseProgressLabelIndex - ProgressLabelNum
    end
    local resultLabelNumOnPage = 0
    local eventResultNumOnPage = 0
    if ResultLabelNum > baseResultLabelIndex then
      for i = baseResultLabelIndex + 1, ResultLabelNum do
        if resultLabelNumOnPage >= EVENT_LABEL_MAX_NUM_EACH_PAGE - progressLabelNumOnPage then
          break
        end
        resultLabelNumOnPage = resultLabelNumOnPage + 1
        picProgressTable[resultLabelNumOnPage + progressLabelNumOnPage + 1].Image = FixedImage.pic_event_result
        picProgressTable[resultLabelNumOnPage + progressLabelNumOnPage + 1].Visible = true
        lbl_event_title_table[resultLabelNumOnPage + progressLabelNumOnPage].Text = gui.TextManager:GetFormatText("text_jiuyinzhi_eventresult")
        lbl_event_title_table[resultLabelNumOnPage + progressLabelNumOnPage].HintText = gui.TextManager:GetFormatText("text_jiuyinzhi_eventresult_tips")
        lbl_event_title_table[resultLabelNumOnPage + progressLabelNumOnPage].Visible = true
      end
      for i = baseResultLabelIndex * 2 + 1, TotalEventResNum do
        if eventResultNumOnPage >= EVENT_MAX_NUM_EACH_PAGE - progressLabelNumOnPage * 2 then
          break
        end
        eventResultNumOnPage = eventResultNumOnPage + 1
        local eventResultIndex = progressLabelNumOnPage * 2 + eventResultNumOnPage
        local proState = nx_number(common_array:FindChild(tableName, "ProgressState"))
        UpdateEventGroupBox(EVENT_TYPE_RESULT, proState == PROGRESSSTATE_COMPLETED, eventResultIndex, i, ResName)
      end
    end
    local LabelTotalNum = progressLabelNumOnPage + resultLabelNumOnPage + 3
    for i = 1, LabelTotalNum do
      if i == 1 then
        picTable[i].Image = FixedImage.pic_start
      elseif i == LabelTotalNum then
        picTable[i].Image = FixedImage.pic_end
        form.pic_end_lable_text.Left = picTable[i].Left
        form.pic_end_lable_text.Visible = true
        picTable[i].Transparent = true
      else
        picTable[i].Image = FixedImage.pic_middle
      end
      picTable[i].Visible = true
    end
    for i = 1, (LabelTotalNum - 1) * 2 do
      pic_rope_table[i].Visible = true
    end
    form.Width = picTable[LabelTotalNum].Left + picTable[LabelTotalNum].Width
    form.btn_close.Left = form.Width - form.btn_close.Width - 9
    form.btn_close.Visible = true
    form.btn_return.Left = picTable[LabelTotalNum - 1].Left + (picTable[LabelTotalNum - 1].Width - form.btn_return.Width) / 2
    form.btn_return.Text = gui.TextManager:GetFormatText("text_jiuyinzhi_return")
    form.btn_return.Visible = true
    picStableTable[2].Visible = true
    form.btn_page_pre.Left = picTable[LabelTotalNum].Left - 10
    form.btn_page_next.Left = form.btn_page_pre.Left
  else
    return
  end
end
function on_btn_page_pre_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if mouseID ~= 0 then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local oldPageNum = form.PageNum
    if form.PageNum > 1 then
      form.PageNum = form.PageNum - 1
    end
    if form.PageNum ~= oldPageNum then
      clearControllerState()
      draw()
    end
  elseif form.PageState == PAGESTATE_SUBPAGE1 then
    local oldPageNum = form.Sub1PageNum
    if 1 < form.Sub1PageNum then
      form.Sub1PageNum = form.Sub1PageNum - 1
    end
    if form.Sub1PageNum ~= oldPageNum then
      clearControllerState()
      draw()
    end
  else
    return
  end
end
function on_btn_page_next_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if mouseID ~= 0 then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local oldPageNum = form.PageNum
    if form.PageNum < form.TotalPageNum then
      form.PageNum = form.PageNum + 1
    end
    if form.PageNum ~= oldPageNum then
      clearControllerState()
      draw()
    end
  elseif form.PageState == PAGESTATE_SUBPAGE1 then
    local oldPageNum = form.Sub1PageNum
    if form.Sub1PageNum < form.TotalSub1PageNum then
      form.Sub1PageNum = form.Sub1PageNum + 1
    end
    if form.Sub1PageNum ~= oldPageNum then
      clearControllerState()
      draw()
    end
  else
    return
  end
end
function on_btn_return_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState ~= PAGESTATE_SUBPAGE1 or mouseID ~= 0 then
    return
  end
  form.Sub1PageNum = 1
  form.PageState = PAGESTATE_MAINPAGE
  clearControllerState()
  draw()
end
function mainPagePicLeftDown(form, tableNum)
  if tableNum > form.ProgressNum then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local tableName = "ProgressTable" .. nx_string(tableNum)
  local proState = common_array:FindChild(tableName, "ProgressState")
  if nx_number(proState) ~= nx_number(PROGRESSSTATE_NULL) then
    sendCustomMsgGetInfo(MSGID_JIUYINZHI_GET_EVENT_DETAIL, tableNum - 1)
    form.PageState = PAGESTATE_WAITMSG
    form.SelectedIndex = tableNum
  end
end
function IsSub1PageValid(form, selectIndex)
  if selectIndex > form.ProgressNum then
    return false
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return false
  end
  local tableName = "ProgressTable" .. nx_string(selectIndex)
  local proState = common_array:FindChild(tableName, "ProgressState")
  if nx_number(proState) == nx_number(PROGRESSSTATE_NULL) then
    return false
  end
  return true
end
function on_pic_2_left_down(self, x, y)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 1
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[1].Image = FixedImage.pic_sow_scroll_down
    pic_cover_table[1].Visible = true
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_pic_2_get_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 1
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[1].Image = FixedImage.pic_sow_scroll_on
    pic_cover_table[1].Visible = true
  end
end
function on_pic_2_lost_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 1
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[1].Image = ""
    pic_cover_table[1].Visible = false
  end
end
function on_pic_3_left_down(self, x, y)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 2
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[2].Image = FixedImage.pic_sow_scroll_down
    pic_cover_table[2].Visible = true
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_pic_3_get_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 2
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[2].Image = FixedImage.pic_sow_scroll_on
    pic_cover_table[2].Visible = true
  end
end
function on_pic_3_lost_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 2
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[2].Image = ""
    pic_cover_table[2].Visible = false
  end
end
function on_pic_4_left_down(self, x, y)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 3
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[3].Image = FixedImage.pic_sow_scroll_down
    pic_cover_table[3].Visible = true
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_pic_4_get_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 3
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[3].Image = FixedImage.pic_sow_scroll_on
    pic_cover_table[3].Visible = true
  end
end
function on_pic_4_lost_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 3
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[3].Image = ""
    pic_cover_table[3].Visible = false
  end
end
function on_pic_5_left_down(self, x, y)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 4
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[4].Image = FixedImage.pic_sow_scroll_down
    pic_cover_table[4].Visible = true
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_pic_5_get_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 4
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[4].Image = FixedImage.pic_sow_scroll_on
    pic_cover_table[4].Visible = true
  end
end
function on_pic_5_lost_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 4
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[4].Image = ""
    pic_cover_table[4].Visible = false
  end
end
function on_pic_6_left_down(self, x, y)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 5
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[5].Image = FixedImage.pic_sow_scroll_down
    pic_cover_table[5].Visible = true
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_pic_6_get_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 5
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[5].Image = FixedImage.pic_sow_scroll_on
    pic_cover_table[5].Visible = true
  end
end
function on_pic_6_lost_capture(self)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 5
    if tableNum > form.ProgressNum then
      return
    end
    pic_cover_table[5].Image = ""
    pic_cover_table[5].Visible = false
  end
end
function on_btn_special_1_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 1
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_btn_special_2_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 2
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_btn_special_3_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 3
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_btn_special_4_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 4
    mainPagePicLeftDown(form, tableNum)
  end
end
function on_btn_special_5_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.PageState == PAGESTATE_MAINPAGE then
    local tableNum = (form.PageNum - 1) * PROGRESS_LABEL_MAX_NUM_EACH_PAGE + 5
    mainPagePicLeftDown(form, tableNum)
  end
end
function click_hyperlink(mltbox, linkitem, linkdata)
  if linkdata == nil or nx_string(linkdata) == "" then
    return
  end
  local data_list = util_split_string(nx_string(linkdata), ";")
  local data_cnt = table.getn(data_list)
  local form_name = data_list[1]
  local form = util_show_form(nx_string(form_name), true)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(data_cnt) > nx_number(1) and nx_string(form_name) == "form_stage_main\\form_helper\\form_theme_helper" then
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form, nx_string(data_list[2]))
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Desktop:ToFront(form)
end
