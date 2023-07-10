require("util_gui")
require("util_functions")
require("util_role_prop")
require("form_stage_main\\form_chat_system\\chat_util_define")
local FORM_CHAT_LIGHT = "form_stage_main\\form_chat_system\\form_chat_light"
local FORM_CHAT_WINDOW = "form_stage_main\\form_chat_system\\form_chat_window"
local FORM_CHAT_PANEL = "form_stage_main\\form_chat_system\\form_chat_panel"
local FORM_CHAT_GROUP = "form_stage_main\\form_chat_system\\form_chat_group"
local FORM_MAIN_FUNCBTNS = "form_stage_main\\form_main\\form_main_func_btns"
local UI_NORMAL = "normal"
local UI_NEWWORLD = "newworld"
local hongbao_str = "newpacket"
local temp_str = "<a href=\"newpacket"
function main_form_init(form)
  form.Fixed = true
  form.chat_content = ""
  form.private_record_list = nil
  form.group_record_list = nil
  form.xml_doc = nil
  form.cur_ui_type = nil
  form.btn_no_light = nil
  form.btn_light = nil
  form.lbl_chatnum = nil
  form.btn_openchat = nil
  form.lbl_chatoutline = nil
  form.btn_opengroup = nil
  form.lbl_groupoutline = nil
end
function on_main_form_open(form)
  InitUI(form)
  change_form_size()
  form.private_record_list = nx_call("util_gui", "get_arraylist", "light:private_record_list")
  form.group_record_list = nx_call("util_gui", "get_arraylist", "light:group_record_list")
  form.xml_doc = create_chat_record_doc()
  form.btn_hongbao.Visible = false
  form.lbl_hongbao.Visible = false
  form.lbl_chatnum.Visible = false
  form.btn_openchat.Visible = false
  form.lbl_chatoutline.Visible = false
  form.btn_opengroup.Visible = false
  form.lbl_groupoutline.Visible = false
  form.btn_light.Visible = false
  form.btn_no_light.Visible = true
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", form, nx_current(), "on_entry_newworld")
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("CurJHSceneConfigID", form)
  end
  if nx_is_valid(form.private_record_list) then
    form.private_record_list:ClearChild()
    nx_destroy(form.private_record_list)
  end
  if nx_is_valid(form.group_record_list) then
    form.group_record_list:ClearChild()
    nx_destroy(form.group_record_list)
  end
  if nx_is_valid(form.xml_doc) then
    nx_destroy(form.xml_doc)
  end
  nx_destroy(form)
end
function on_btn_no_light_click(btn)
  if is_newjhmodule() then
    nx_execute("form_stage_main\\form_chat_system\\form_new_friend_list", "open_form")
  else
    util_auto_show_hide_form(FORM_CHAT_PANEL)
  end
end
function on_btn_light_click(btn)
  local form = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) then
    return
  end
  form.chat_content = ""
  form.btn_light.Visible = false
  form.btn_no_light.Visible = true
  form.btn_hongbao.Visible = false
  form.lbl_hongbao.Visible = false
  start_read_record()
  start_read_groupchat()
end
function on_btn_openchat_click(btn)
  local form = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) then
    return
  end
  form.btn_openchat.Visible = false
  form.lbl_chatoutline.Visible = false
  form.lbl_hongbao.Visible = false
  local form_chat = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form_chat) then
    return
  end
  form_chat.Visible = true
  form_chat.is_minimize = false
end
function on_btn_opengroup_click(btn)
  start_read_group_record()
end
function on_entry_newworld(form)
  local uitype = nx_string(form.cur_ui_type)
  if is_newjhmodule() and uitype ~= UI_NEWWORLD then
    UseNewWorldUI()
  end
end
function reset_scene()
  if is_newjhmodule() then
    UseNewWorldUI()
  else
    UseNormalUI()
  end
end
function RegisterCallback(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.btn_no_light) then
    nx_bind_script(form.btn_no_light, nx_current())
    nx_callback(form.btn_no_light, "on_click", "on_btn_no_light_click")
  end
  if nx_is_valid(form.btn_light) then
    nx_bind_script(form.btn_light, nx_current())
    nx_callback(form.btn_light, "on_click", "on_btn_light_click")
  end
  if nx_is_valid(form.btn_openchat) then
    nx_bind_script(form.btn_openchat, nx_current())
    nx_callback(form.btn_openchat, "on_click", "on_btn_openchat_click")
  end
  if nx_is_valid(form.btn_opengroup) then
    nx_bind_script(form.btn_opengroup, nx_current())
    nx_callback(form.btn_opengroup, "on_click", "on_btn_opengroup_click")
  end
end
function InitUI(form)
  form.cur_ui_type = UI_NORMAL
  form.btn_no_light = form.btn_no_light1
  form.btn_light = form.btn_light1
  form.lbl_chatnum = form.lbl_chatnum1
  form.btn_openchat = form.btn_openchat1
  form.lbl_chatoutline = form.lbl_chatoutline1
  form.btn_opengroup = form.btn_opengroup1
  form.lbl_groupoutline = form.lbl_groupoutline1
  RegisterCallback(form)
end
function UseNormalUI()
  local form = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) then
    return
  end
  if not (nx_is_valid(form.btn_no_light) and nx_is_valid(form.btn_light) and nx_is_valid(form.lbl_chatnum) and nx_is_valid(form.btn_openchat) and nx_is_valid(form.lbl_chatoutline) and nx_is_valid(form.btn_opengroup)) or not nx_is_valid(form.lbl_groupoutline) then
    return
  end
  form.cur_ui_type = UI_NORMAL
  form.Visible = true
  local bVisible = form.btn_no_light.Visible
  form.btn_no_light = form.btn_no_light1
  form.btn_no_light.Visible = bVisible
  local bVisible = form.btn_light.Visible
  form.btn_light = form.btn_light1
  form.btn_light.Visible = bVisible
  local bVisible = form.lbl_chatnum.Visible
  local text = form.lbl_chatnum.Text
  form.lbl_chatnum = form.lbl_chatnum1
  form.lbl_chatnum.Text = text
  form.lbl_chatnum.Visible = bVisible
  local bVisible = form.btn_openchat.Visible
  form.btn_openchat = form.btn_openchat1
  form.btn_openchat.Visible = bVisible
  local bVisible = form.lbl_chatoutline.Visible
  form.lbl_chatoutline = form.lbl_chatoutline1
  form.lbl_chatoutline.Visible = bVisible
  local bVisible = form.btn_opengroup.Visible
  form.btn_opengroup = form.btn_opengroup1
  form.btn_opengroup.Visible = bVisible
  local bVisible = form.lbl_groupoutline.Visible
  form.lbl_groupoutline = form.lbl_groupoutline1
  form.lbl_groupoutline.Visible = bVisible
  RegisterCallback(form)
end
function UseNewWorldUI()
  local form = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) then
    return
  end
  local form_btns = nx_value(FORM_MAIN_FUNCBTNS)
  if not nx_is_valid(form_btns) then
    return
  end
  if not (nx_is_valid(form.btn_no_light) and nx_is_valid(form.btn_light) and nx_is_valid(form.lbl_chatnum) and nx_is_valid(form.btn_openchat) and nx_is_valid(form.lbl_chatoutline) and nx_is_valid(form.btn_opengroup)) or not nx_is_valid(form.lbl_groupoutline) then
    return
  end
  form.cur_ui_type = UI_NEWWORLD
  form.Visible = false
  local bVisible = form.btn_no_light.Visible
  form.btn_no_light = form_btns.btn_no_light2
  form.btn_no_light.Visible = bVisible
  local bVisible = form.btn_light.Visible
  form.btn_light = form_btns.btn_light2
  form.btn_light.Visible = bVisible
  local bVisible = form.lbl_chatnum.Visible
  local text = form.lbl_chatnum.Text
  form.lbl_chatnum = form_btns.lbl_chatnum2
  form.lbl_chatnum.Text = text
  form.lbl_chatnum.Visible = bVisible
  local bVisible = form.btn_openchat.Visible
  form.btn_openchat = form_btns.btn_openchat2
  form.btn_openchat.Visible = bVisible
  local bVisible = form.lbl_chatoutline.Visible
  form.lbl_chatoutline = form_btns.lbl_chatoutline2
  form.lbl_chatoutline.Visible = bVisible
  local bVisible = form.btn_opengroup.Visible
  form.btn_opengroup = form_btns.btn_opengroup2
  form.btn_opengroup.Visible = bVisible
  local bVisible = form.lbl_groupoutline.Visible
  form.lbl_groupoutline = form_btns.lbl_groupoutline2
  form.lbl_groupoutline.Visible = bVisible
  RegisterCallback(form)
end
function show_light(bShow)
  local form = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) then
    return
  end
  if is_hongbao_chat() then
    form.btn_hongbao.Visible = bShow
    form.lbl_hongbao.Visible = bShow
  else
    form.btn_light.Visible = bShow
    form.btn_no_light.Visible = not bShow
  end
end
function start_read_record()
  local form = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) then
    return
  end
  local private_record_list = form.private_record_list
  if not nx_is_valid(private_record_list) then
    return
  end
  local list_count = private_record_list:GetChildCount()
  for i = 0, list_count - 1 do
    local obj = private_record_list:GetChildByIndex(i)
    if obj.readflag == false then
      obj.readflag = true
      nx_execute(FORM_CHAT_WINDOW, "start_chat", obj.targetname)
      local form_chat = nx_value(FORM_CHAT_WINDOW)
      nx_execute(FORM_CHAT_WINDOW, "accept_content", form_chat, obj.targetname, obj.chatcontent, obj.chattype, obj.chattime)
    end
  end
  form.btn_openchat.Visible = false
  form.lbl_chatoutline.Visible = false
  update_light()
end
function start_read_groupchat()
  local form = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) then
    return
  end
  local group_record_list = form.group_record_list
  if not nx_is_valid(group_record_list) then
    return
  end
  local list_count = group_record_list:GetChildCount()
  for i = 0, list_count - 1 do
    local obj = group_record_list:GetChildByIndex(i)
    if obj.readflag == false then
      obj.readflag = true
      nx_execute(FORM_CHAT_WINDOW, "start_groupchat", obj.groupid)
      local form_chat = nx_value(FORM_CHAT_WINDOW)
      nx_execute(FORM_CHAT_WINDOW, "accept_groupchat_content", form_chat, obj.groupid, obj.targetname, obj.chatcontent, 0, obj.chattime)
    end
  end
  form.btn_opengroup.Visible = false
  form.lbl_groupoutline.Visible = false
  update_light()
end
function open_chat_window(sender_name)
  if is_filter_player(sender_name) then
    return
  end
  nx_execute(FORM_CHAT_WINDOW, "start_chat", sender_name)
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if nx_is_valid(form_light) then
    local private_record_list = form_light.private_record_list
    if nx_is_valid(private_record_list) then
      local list_count = private_record_list:GetChildCount()
      for i = 0, list_count - 1 do
        local obj = private_record_list:GetChildByIndex(i)
        if nx_ws_equal(nx_widestr(sender_name), nx_widestr(obj.targetname)) and obj.readflag == false then
          obj.readflag = true
          local form_chat = nx_value(FORM_CHAT_WINDOW)
          nx_execute(FORM_CHAT_WINDOW, "accept_content", form_chat, obj.targetname, obj.chatcontent, obj.chattype, obj.chattime)
        end
      end
    end
    form_light.btn_openchat.Visible = false
    form_light.lbl_chatoutline.Visible = false
  end
  update_light()
end
function open_groupchat_window(groupid)
  nx_execute(FORM_CHAT_WINDOW, "start_groupchat", groupid)
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if nx_is_valid(form_light) then
    local private_record_list = form_light.private_record_list
    if nx_is_valid(private_record_list) then
      local list_count = private_record_list:GetChildCount()
      for i = 0, list_count - 1 do
        local obj = private_record_list:GetChildByIndex(i)
        if nx_ws_equal(nx_widestr(sender_name), nx_widestr(obj.targetname)) and obj.readflag == false then
          obj.readflag = true
          local form_chat = nx_value(FORM_CHAT_WINDOW)
          nx_execute(FORM_CHAT_WINDOW, "accept_content", form_chat, obj.targetname, obj.chatcontent, obj.chattype, obj.chattime)
        end
      end
    end
    form_light.btn_openchat.Visible = false
    form_light.lbl_chatoutline.Visible = false
  end
  update_light()
end
function add_record(target_name, chat_content, chat_type, chat_time)
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form_light) then
    return
  end
  local checkads = nx_value("checkads")
  if nx_is_valid(checkads) and checkads:CheckIsHaveAds(chat_content) then
    return
  end
  local form_chat = nx_value(FORM_CHAT_WINDOW)
  if nx_is_valid(form_chat) and form_chat.chater_list:FindChild(nx_string(target_name)) then
    nx_execute(FORM_CHAT_WINDOW, "accept_content", form_chat, target_name, chat_content, chat_type, chat_time)
    local xml_doc = get_record_doc()
    write_chat_record(xml_doc, target_name, target_name, chat_content, chat_type, chat_time)
    form_light.btn_openchat.Visible = form_chat.is_minimize
    form_light.lbl_chatoutline.Visible = form_chat.is_minimize
    if form_chat.is_minimize then
      play_message_gound()
    end
    return
  end
  local private_record_list = form_light.private_record_list
  local list_count = private_record_list:GetChildCount()
  if 0 < list_count then
    for i = list_count - 1, 0, -1 do
      local obj = private_record_list:GetChildByIndex(i)
      if obj.readflag == true then
        private_record_list:RemoveChildByIndex(i)
      end
    end
  end
  local record = private_record_list:CreateChild("")
  record.targetname = target_name
  record.chatcontent = chat_content
  record.chattype = chat_type
  record.chattime = chat_time
  record.readflag = false
  form_light.chat_content = chat_content
  if is_filter_player(sender_name) then
    return
  end
  local xml_doc = get_record_doc()
  write_chat_record(xml_doc, target_name, target_name, chat_content, chat_type, chat_time)
  form_light.btn_openchat.Visible = false
  form_light.lbl_chatoutline.Visible = false
  update_light()
  play_message_gound()
end
function add_groupchat_record(groupid, target_name, chat_content, chat_time)
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form_light) then
    return
  end
  form_light.chat_content = chat_content
  local checkads = nx_value("checkads")
  if nx_is_valid(checkads) and checkads:CheckIsHaveAds(chat_content) then
    return
  end
  local form_chat = nx_value(FORM_CHAT_WINDOW)
  if nx_is_valid(form_chat) and form_chat.chater_list:FindChild(nx_string(groupid)) then
    nx_execute(FORM_CHAT_WINDOW, "accept_groupchat_content", form_chat, groupid, target_name, chat_content, 0, chat_time)
    local xml_doc = get_record_doc()
    write_chat_record(xml_doc, groupid, target_name, chat_content, 0, chat_time)
    form_light.btn_openchat.Visible = form_chat.is_minimize
    form_light.lbl_chatoutline.Visible = form_chat.is_minimize
    local starts, ends = string.find(nx_string(nx_widestr(chat_content)), nx_string(nx_widestr(temp_str)))
    if starts ~= nil and ends ~= nil then
      form_light.lbl_hongbao.Visible = form_chat.is_minimize
    end
    if form_chat.is_minimize then
      play_message_gound()
    end
    return
  end
  local group_record_list = form_light.group_record_list
  local list_count = group_record_list:GetChildCount()
  if 0 < list_count then
    for i = list_count - 1, 0, -1 do
      local obj = group_record_list:GetChildByIndex(i)
      if obj.readflag == true then
        group_record_list:RemoveChildByIndex(i)
      end
    end
  end
  local record = group_record_list:CreateChild("")
  record.targetname = target_name
  record.groupid = groupid
  record.chatcontent = chat_content
  record.chattime = chat_time
  if get_groupchat_shield(groupid) then
    record.readflag = true
  else
    record.readflag = false
  end
  if is_filter_player(target_name) then
    return
  end
  local xml_doc = get_record_doc()
  write_chat_record(xml_doc, groupid, target_name, chat_content, chat_type, chat_time)
  form_light.btn_openchat.Visible = false
  form_light.lbl_chatoutline.Visible = false
  update_light()
  play_message_gound()
end
function add_offline_record()
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form_light) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(WHISPER_REC) then
    return
  end
  local rows = client_player:GetRecordRows(WHISPER_REC)
  for i = 0, rows - 1 do
    local target_name = client_player:QueryRecord(WHISPER_REC, i, WHISPER_REC_COL_SENDNAME)
    if not is_filter_player(target_name) then
      local uid = client_player:QueryRecord(WHISPER_REC, i, WHISPER_REC_COL_SENDUID)
      local content = client_player:QueryRecord(WHISPER_REC, i, WHISPER_REC_COL_VALUE)
      local flag = client_player:QueryRecord(WHISPER_REC, i, WHISPER_REC_COL_READFLAG)
      if nx_int(flag) == nx_int(0) then
        local content_table = util_split_string(nx_string(content), "\b")
        for j = 1, table.getn(content_table) do
          local item_table = util_split_string(nx_string(content_table[j]), "\f")
          if table.getn(item_table) == 2 then
            local chat_time = item_table[1]
            local chat_content = item_table[2]
            add_record(target_name, chat_content, 0, chat_time)
          end
        end
      end
    end
    nx_execute("custom_sender", "custom_remove_chat_whisper", target_name)
  end
end
function update_light()
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form_light) then
    return
  end
  local private_record_list = form_light.private_record_list
  if not nx_is_valid(private_record_list) then
    return
  end
  local player_table = {}
  local list_count = private_record_list:GetChildCount()
  for i = 0, list_count - 1 do
    local obj = private_record_list:GetChildByIndex(i)
    if obj.readflag == false then
      local player_name = nx_string(obj.targetname)
      if not is_filter_player(player_name) then
        local is_exists = false
        for j = 1, table.getn(player_table) do
          if nx_string(player_name) == nx_string(player_table[j]) then
            is_exists = true
          end
        end
        if not is_exists then
          table.insert(player_table, player_name)
        end
      end
    end
  end
  local group_record_list = form_light.group_record_list
  if not nx_is_valid(group_record_list) then
    return
  end
  list_count = group_record_list:GetChildCount()
  for i = 0, list_count - 1 do
    local obj = group_record_list:GetChildByIndex(i)
    if obj.readflag == false then
      local groupid = nx_string(obj.groupid)
      local is_exists = false
      for j = 1, table.getn(player_table) do
        if nx_string(groupid) == nx_string(player_table[j]) then
          is_exists = true
        end
      end
      if not is_exists then
        table.insert(player_table, groupid)
      end
    end
  end
  local player_num = table.getn(player_table)
  if 0 < player_num then
    show_light(true)
    if not is_hongbao_chat() then
      form_light.lbl_chatnum.Visible = true
      form_light.lbl_chatnum.Text = nx_widestr(player_num)
    end
  else
    form_light.btn_light.Visible = false
    form_light.btn_no_light.Visible = true
    form_light.lbl_chatnum.Visible = false
  end
end
function is_filter_player(target_name)
  local karmamgr = nx_value("Karma")
  if nx_is_valid(karmamgr) and karmamgr:IsFilterNative(nx_widestr(target_name)) then
    return true
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(FILTER_REC) then
    return false
  end
  local rows = client_player:GetRecordRows(FILTER_REC)
  for i = 0, rows - 1 do
    local player_name = client_player:QueryRecord(FILTER_REC, i, FILTER_REC_COL_NAME)
    if nx_ws_equal(nx_widestr(target_name), nx_widestr(player_name)) then
      return true
    end
  end
  return false
end
function start_read_group_record()
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form_light) then
    return
  end
  local group_record_list = form_light.group_record_list
  if not nx_is_valid(group_record_list) then
    return
  end
  nx_execute(FORM_CHAT_GROUP, "start_chat")
  local list_count = group_record_list:GetChildCount()
  for i = 0, list_count - 1 do
    local obj = group_record_list:GetChildByIndex(i)
    if obj.readflag == false then
      obj.readflag = true
      local form_group = nx_value(FORM_CHAT_GROUP)
      nx_execute(FORM_CHAT_GROUP, "accept_content", form_group, obj.targetname, obj.chatcontent, obj.chattime)
    end
  end
  form_light.btn_opengroup.Visible = false
  form_light.lbl_groupoutline.Visible = false
end
function add_group_record(send_name, chat_content, chat_time)
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form_light) then
    return
  end
  local checkads = nx_value("checkads")
  if nx_is_valid(checkads) and checkads:CheckIsHaveAds(chat_content) then
    return
  end
  local form_group = nx_value(FORM_CHAT_GROUP)
  if nx_is_valid(form_group) then
    nx_execute(FORM_CHAT_GROUP, "accept_content", form_group, send_name, chat_content, chat_time)
    local xml_doc = get_record_doc()
    write_chat_record(xml_doc, GROUP_MESSAGE_FLAG, send_name, chat_content, 0, chat_time)
    form_light.btn_openchat.Visible = form_group.is_minimize
    form_light.lbl_openchat.Visible = form_group.is_minimize
  else
    local group_record_list = form_light.group_record_list
    local list_count = group_record_list:GetChildCount()
    if 0 < list_count then
      for i = list_count - 1, 0, -1 do
        local obj = group_record_list:GetChildByIndex(i)
        if obj.readflag == true then
          group_record_list:RemoveChildByIndex(i)
        end
      end
    end
    local record = group_record_list:CreateChild("")
    record.targetname = send_name
    record.chatcontent = chat_content
    record.chattime = chat_time
    record.readflag = false
    local xml_doc = get_record_doc()
    write_chat_record(xml_doc, GROUP_MESSAGE_FLAG, send_name, chat_content, 0, chat_time)
    form_light.btn_openchat.Visible = true
    form_light.lbl_openchat.Visible = true
  end
end
function play_message_gound()
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) and nx_int(game_config_info.play_chatprompt_sound) == nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound("sound_msgprompt") then
    gui:AddSound("sound_msgprompt", nx_resource_path() .. "snd\\ui\\chat.wav")
  end
  gui:PlayingSound("sound_msgprompt")
end
function get_form_btn_absleft_top()
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form_light) then
    return 0, 0, 0
  end
  return form_light.btn_light1.AbsLeft, form_light.btn_light1.AbsTop, form_light.btn_light1.Height
end
function set_to_front()
  local form_chat_btn_right = nx_value(FORM_CHAT_LIGHT)
  if nx_is_valid(form_chat_btn_right) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.Desktop:ToFront(form_chat_btn_right)
    end
  end
end
function change_form_size()
end
function get_groupchat_shield(groupid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow(PLAYER_GROUP_CHAT_REC, player_group_rec_groupid, nx_string(groupid))
  if nx_int(row) < nx_int(0) then
    return false
  end
  local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
  local shield = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, row, player_group_rec_shield)
  if nx_int(shield) == nx_int(1) then
    return true
  end
  return false
end
function on_btn_hongbao_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.lbl_hongbao.Visible = false
  btn.Visible = false
  form.chat_content = ""
  start_read_groupchat()
end
function is_hongbao_chat()
  local form = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) then
    return
  end
  local starts, ends = string.find(nx_string(nx_widestr(form.chat_content)), nx_string(nx_widestr(temp_str)))
  if starts ~= nil and ends ~= nil then
    return true
  end
end
