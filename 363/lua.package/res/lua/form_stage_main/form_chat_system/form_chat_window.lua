require("utils")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_chat_system\\chat_util_define")
require("form_stage_main\\switch\\switch_define")
local FORM_CHAT_LIGHT = "form_stage_main\\form_chat_system\\form_chat_light"
local FORM_CHAT_WINDOW = "form_stage_main\\form_chat_system\\form_chat_window"
local FORM_CHAT_HISTORY = "form_stage_main\\form_chat_system\\form_chat_history"
local FORM_CHAT_PANEL = "form_stage_main\\form_chat_system\\form_chat_panel"
local FORM_MAIN_FACE_CHAT = "form_stage_main\\form_main\\form_main_face_chat"
local FORM_MAIN_FACE = "form_stage_main\\form_main\\form_main_face"
local REQUESTTYPE_SECURITY = 1
local REQUESTTYPE_INFO = 2
local color_online = "255,255,255,255"
local color_offline = "255,128,128,128"
function main_form_init(form)
  form.Fixed = false
  form.curTargetName = ""
  form.curGroupid = ""
  form.curRightTargetName = ""
  form.hide_reply = false
  form.chater_list = nil
  form.is_minimize = false
end
function on_main_form_open(form)
  change_form_size()
  form.chater_list = nx_call("util_gui", "get_arraylist", "chat:chater_list")
  form.groupbox_item.Visible = false
  form.gb_prompt.Visible = false
  form.mltbox_list.Visible = false
  form.groupchat_item.Visible = false
  local gui = nx_value("gui")
  gui.Focused = form.txt_content
  form.is_minimize = false
  update_self_info(form)
  add_groupchat_binder(form)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    local enable = switch_manager:CheckSwitchEnable(ST_FUNCTION_NEWPACKET)
    form.btn_hongbao.Enabled = nx_boolean(enable)
  end
end
function on_main_form_close(form)
  local gui = nx_value("gui")
  gui.hyperfocused = nil
  if nx_is_valid(form.chater_list) then
    form.chater_list:ClearChild()
    nx_destroy(form.chater_list)
  end
  del_groupchat_binder(form)
  nx_destroy(form)
  local form_face = nx_value(FORM_MAIN_FACE)
  if nx_is_valid(form_face) then
    form_face:Close()
  end
  local form_history = nx_value("chat_window_history")
  if nx_is_valid(form_history) then
    form_history:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_min_click(btn)
  local form = btn.ParentForm
  local form_light = nx_value(FORM_CHAT_LIGHT)
  if not nx_is_valid(form) or not nx_is_valid(form_light) then
    return
  end
  form.Visible = false
  form.is_minimize = true
  form_light.btn_openchat.Visible = true
  form_light.lbl_chatoutline.Visible = false
end
function on_btn_chat_face_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  gui.Focused = form.txt_content
  local face_form = nx_value(FORM_MAIN_FACE_CHAT)
  if nx_is_valid(face_form) then
    nx_gen_event(face_form, "selectface_return", "cancel", "")
  else
    local form_main_face = nx_execute("util_gui", "util_get_form", FORM_MAIN_FACE, true, false, "", true)
    nx_set_value(FORM_MAIN_FACE_CHAT, form_main_face)
    form_main_face.AbsLeft = btn.AbsLeft + btn.Width
    form_main_face.AbsTop = btn.AbsTop + btn.Height - form_main_face.Height
    form_main_face.type = 1
    form_main_face.vip_face_type = 2
    form_main_face.Visible = true
    form_main_face:Show()
    local res, html = nx_wait_event(100000000, form_main_face, "selectface_return")
    local form_chat_window = nx_value(FORM_CHAT_WINDOW)
    if res == "ok" and nx_is_valid(form_chat_window) then
      add_item_to_chatedit(form, html)
    end
    form_main_face:Close()
  end
  nx_set_value(FORM_MAIN_FACE_CHAT, nil)
end
function on_btn_hongbao_click(btn)
  nx_execute("form_stage_main\\form_hongbao\\form_hongbao_send", "open_form")
end
function on_btn_roleinfo_click(btn)
  local form = btn.ParentForm
  if form.curGroupid ~= "" then
    return
  end
  nx_execute("custom_sender", "custom_sns_search_friend", form.curTargetName)
end
function on_btn_chat_history_click(btn)
  local form = btn.ParentForm
  local form_history = nx_value("chat_window_history")
  if not nx_is_valid(form_history) then
    form_history = nx_execute("util_gui", "util_get_form", FORM_CHAT_HISTORY, true, false, 1)
    nx_set_value("chat_window_history", form_history)
    form_history.Left = form.Left + form.Width
    form_history.Top = form.Top
    form_history.Visible = true
    form_history:Show()
    local target = ""
    if form.curGroupid ~= "" then
      target = form.curGroupid
    else
      target = form.curTargetName
    end
    nx_execute(FORM_CHAT_HISTORY, "Init_Form", form_history, target)
  else
    nx_set_value("chat_window_history", nx_null())
    form_history:Close()
  end
end
function on_btn_send_click(btn)
  local form = btn.ParentForm
  if (nx_string(form.curTargetName) == "" or nx_string(form.txt_content.Text) == "") and (nx_string(form.curGroupid) == "" or nx_string(form.txt_content.Text) == "") then
    return
  end
  local content = nx_widestr(form.txt_content.Text)
  if form.curGroupid ~= "" then
    send_groupchat_content(form, form.curGroupid, content)
  else
    send_content(form, form.curTargetName, content, 0)
  end
end
function auto_send(target_name, content)
  start_chat(target_name)
  local form = util_get_form(FORM_CHAT_WINDOW, false)
  if nx_is_valid(form) then
    send_content(form, form.curTargetName, content, 0)
  end
end
function on_txt_content_enter(redit)
  local form = redit.ParentForm
  on_btn_send_click(form.btn_send)
end
function on_txt_content_get_focus(redit)
  local gui = nx_value("gui")
  gui.hyperfocused = redit
end
function on_cbtn_hide_reply_checked_changed(btn)
  local form = btn.ParentForm
  form.hide_reply = not form.hide_reply
  local msg = form.hide_reply and "gcw_hidereply_true" or "gcw_hidereply_false"
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, msg)
end
function on_item_select_changed(rbtn)
  local form = rbtn.ParentForm
  local item = rbtn.Parent
  if rbtn.Checked then
    clear_tab_selected(rbtn)
    show_tab_flag(item, false)
    local target_name = item.target
    if nx_find_custom(item, "groupid") then
      target_name = get_groupname(item.groupid)
      SwitchToGroupChatPanel(form, item.groupid, target_name)
      update_group_member_info(form, item.groupid)
    else
      SwitchToChatPanel(form, item.target)
      update_player_info(form, item.target)
    end
  end
end
function on_g_item_select_changed(rbtn)
  local form = rbtn.ParentForm
  local item = rbtn.Parent
  if rbtn.Checked then
    clear_groupchat_tab_selected(rbtn)
  end
end
function on_g_item_bg_right_click(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  local form = item.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.curRightTargetName = item.target
  if form.groupbox_gchat_member.Visible then
    nx_execute("menu_game", "menu_game_reset", "member_groupchat", "member_groupchat")
    nx_execute("menu_game", "menu_recompose", menu_game, item)
    menu_game.target_name = nx_widestr(item.target)
    menu_game.groupid = nx_string(item.groupid)
  end
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x + 25, y)
end
function on_g_item_double_click(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local player_name = item.lbl_name.Text
  nx_execute("custom_sender", "custom_request_chat", player_name)
end
function on_item_close_click(btn)
  local form = btn.ParentForm
  local item = btn.Parent
  RemoveChatPanel(form, item.target)
end
function on_hyperlink_right_click(mltbox, itemindex, linkdata)
  local form = mltbox.ParentForm
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) then
    local enable = switchmgr:CheckSwitchEnable(ST_FUNCTION_GMCC_JUBAO)
    if not enable then
      return
    end
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local param_table = nx_function("ext_split_wstring", linkdata, nx_widestr(","))
  local count = table.maxn(param_table)
  if count < 2 then
    return
  end
  if nx_string(param_table[1]) ~= nx_string("PN") then
    return
  end
  local self_name = nx_widestr(client_player:QueryProp("Name"))
  local player_name = nx_widestr(param_table[2])
  if nx_ws_equal(self_name, player_name) then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  mltbox.report_index = itemindex
  mltbox.report_name = player_name
  nx_execute("menu_game", "menu_game_reset", "chat_hlink", "chat_hlink")
  nx_execute("menu_game", "menu_recompose", menu_game, mltbox)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x + 25, y)
end
function AddContentToList(form, recordName, senderName, chat_content, chat_type, chat_time, auto_save)
  local sub_date = chat_time
  local sub_time = chat_time
  local index = string.find(chat_time, " ")
  if index ~= nil then
    sub_date = string.sub(chat_time, 1, index - 1)
    sub_time = string.sub(chat_time, index + 1)
  end
  local gui = nx_value("gui")
  local info = nx_widestr(gui.TextManager:GetFormatText("gcw_chat_record_message", senderName, sub_time, chat_content))
  ShowContent(form, recordName, info)
  if auto_save then
    local xml_doc = get_record_doc()
    write_chat_record(xml_doc, recordName, senderName, chat_content, chat_type, chat_time)
  end
end
function AddGroupchatContentToList(form, groupid, senderName, chat_content, chat_type, chat_time, auto_save)
  local sub_date = chat_time
  local sub_time = chat_time
  local index = string.find(chat_time, " ")
  if index ~= nil then
    sub_date = string.sub(chat_time, 1, index - 1)
    sub_time = string.sub(chat_time, index + 1)
  end
  local gui = nx_value("gui")
  local info = nx_widestr(gui.TextManager:GetFormatText("gcw_chat_record_message", senderName, sub_time, chat_content))
  ShowContent(form, groupid, info)
  if auto_save then
    local xml_doc = get_record_doc()
    write_chat_record(xml_doc, groupid, senderName, chat_content, chat_type, chat_time)
  end
end
function ShowContent(form, player_name, info)
  if not nx_is_valid(form) then
    return
  end
  local mltbox_list = get_tab_mltboxlist(form, player_name)
  if nx_is_valid(mltbox_list) then
    mltbox_list:AddHtmlText(nx_widestr(info), -1)
    mltbox_list.VScrollBar.Value = mltbox_list.VScrollBar.Maximum
  end
end
function send_content(form, target_name, chat_content, chat_type)
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local Time = os.date("*t", os.time())
  local chat_time = string.format("%d-%02d-%02d %02d:%02d:%02d", Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
  if nx_int(chat_type) ~= nx_int(3) then
    local check_words = nx_value("CheckWords")
    if nx_is_valid(check_words) then
      chat_content = nx_execute("custom_sender", "check_word", check_words, nx_widestr(chat_content), 1)
    end
    if nx_is_valid(form) then
      local self_name = client_player:QueryProp("Name")
      AddContentToList(form, target_name, self_name, chat_content, chat_type, chat_time, true)
      form.txt_content.Text = nx_widestr("")
      local gui = nx_value("gui")
      gui.Focused = form.txt_content
    end
  end
  nx_execute("custom_sender", "custom_send_chat_content", target_name, chat_content, chat_type, chat_time)
end
function send_groupchat_content(form, groupid, chat_content)
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local Time = os.date("*t", os.time())
  local chat_time = string.format("%d-%02d-%02d %02d:%02d:%02d", Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
  local check_words = nx_value("CheckWords")
  if nx_is_valid(check_words) then
    chat_content = nx_execute("custom_sender", "check_word", check_words, nx_widestr(chat_content), 1)
  end
  if nx_is_valid(form) then
    local self_name = client_player:QueryProp("Name")
    AddGroupchatContentToList(form, groupid, self_name, chat_content, 0, chat_time, true)
    form.txt_content.Text = nx_widestr("")
    local gui = nx_value("gui")
    gui.Focused = form.txt_content
  end
  nx_execute("custom_sender", "custom_send_groupchat_content", 4, groupid, chat_content, chat_time)
end
function accept_content(form, target_name, chat_content, chat_type, chat_time)
  if form.cbtn_hide_reply.Checked and chat_type ~= 0 then
    return
  end
  local is_chating = nx_ws_equal(nx_widestr(form.curTargetName), nx_widestr(target_name))
  local tab_item = get_tab_item(form, target_name)
  show_tab_flag(tab_item, not is_chating)
  AddContentToList(form, target_name, target_name, chat_content, chat_type, chat_time, false)
end
function accept_groupchat_content(form, groupid, target_name, chat_content, chat_type, chat_time)
  if is_filter_player(target_name) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  if nx_ws_equal(nx_widestr(self_name), nx_widestr(target_name)) and false == nx_function("ext_is_newpacket_link", chat_content) then
    return
  end
  if not nx_is_valid(form) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    local info = gui.TextManager:GetText("sys_groupchat_009")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  local is_chating = nx_ws_equal(nx_widestr(form.curGroupid), nx_widestr(groupid))
  local tab_item = get_tab_item(form, groupid)
  show_tab_flag(tab_item, not is_chating)
  AddGroupchatContentToList(form, groupid, target_name, chat_content, chat_type, chat_time, false)
end
function start_chat(player_name)
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", FORM_CHAT_WINDOW, true, false)
    form:Show()
  end
  form.Visible = true
  form.is_minimize = false
  if form.chater_list:FindChild(nx_string(player_name)) then
    SelectChatPanel(form, player_name)
    return
  end
  form.chater_list:CreateChild(nx_string(player_name))
  CreateNewChatPanel(form, player_name)
  SelectChatPanel(form, player_name)
  if is_strangeness(player_name) then
    show_security_info(player_name)
  end
end
function show_security_info(player_name)
  nx_execute("custom_sender", "custom_get_chater_info", player_name, 1)
end
function on_receive_security_info(...)
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return
  end
  local request_type = nx_int(arg[1])
  local player_name = nx_widestr(arg[2])
  local sex = nx_int(arg[3])
  local title_id = nx_int(arg[4])
  local photo = nx_string(arg[5])
  local level_title = nx_string(arg[6])
  local power_level = nx_int(arg[7])
  local school = nx_string(arg[8])
  local guild = nx_widestr(arg[9])
  local CharacterFlag = nx_int(arg[10])
  local CharacterValue = nx_int(arg[11])
  local RevengeIntegral = nx_int(arg[12])
  local scene_id = nx_int(arg[13])
  if nx_int(REQUESTTYPE_SECURITY) == nx_int(request_type) then
    local desc_level = gui.TextManager:GetText("desc_" .. level_title)
    local info = gui.TextManager:GetFormatText("gcw_chat_security_prompt", desc_level)
    local form = nx_value(FORM_CHAT_WINDOW)
    ShowContent(form, player_name, info)
  elseif nx_int(REQUESTTYPE_INFO) == nx_int(request_type) and nx_ws_equal(nx_widestr(form.curTargetName), nx_widestr(player_name)) then
    form.lbl_info_photo1.BackImage = photo
    local title_name = gui.TextManager:GetText("desc_" .. level_title)
    form.lbl_info_power1.Text = nx_widestr(title_name)
    local school_name = get_school_name(school)
    form.lbl_info_menpai1.Text = nx_widestr(school_name)
    form.lbl_info_bangpai1.Text = nx_widestr(guild)
    if nx_string(guild) == "" then
      guild = gui.TextManager:GetFormatText("ui_wu")
    end
    form.lbl_info_bangpai1.Text = nx_widestr(guild)
    local revenge_room = get_revenge_room_name(nx_int(RevengeIntegral))
    local cn_name = gui.TextManager:GetText("ui_tianti_" .. revenge_room)
    form.lbl_info_roomname1.Text = nx_widestr(cn_name)
    form.lbl_info_point1.Text = nx_widestr(RevengeIntegral)
  end
end
function add_item_to_chatedit(form, html)
  form.txt_content:Append(html, -1)
  local gui = nx_value("gui")
  gui.Focused = form.txt_content
end
function add_hyperlink(html)
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return
  end
  local cur_chat_info = nx_string(form.txt_content.Text)
  if not can_add_hyperlink(cur_chat_info) then
    local gui = nx_value("gui")
    gui.Focused = form.txt_content
    return
  end
  add_item_to_chatedit(form, html)
end
function can_add_hyperlink(chat_info)
  local html_num = 0
  local n_start, n_end = string.find(chat_info, "HLChatItem")
  while n_start ~= nil and n_end ~= nil do
    html_num = html_num + 1
    n_start, n_end = string.find(chat_info, "HLChatItem", n_end)
  end
  if nx_number(html_num) >= HYPERLINK_MAX_NUM then
    return false
  end
  return true
end
function CreateNewChatPanel(form, name)
  local tabCount = get_tab_count(form)
  local gb_charter = GetNewTabItem(name)
  gb_charter.target = nx_widestr(name)
  form.gsb_chater_list:Add(gb_charter)
  form.gsb_chater_list.IsEditMode = false
  form.gsb_chater_list:ResetChildrenYPos()
  local mltbox_list = GetNewRichEdit(name)
  form.groupbox_1:Add(mltbox_list)
end
function CreateNewGroupChatPanel(form, groupid, name)
  local tabCount = get_tab_count(form)
  local gb_charter = GetNewTabGroupItem(groupid, name)
  gb_charter.target = nx_widestr(groupid)
  gb_charter.groupid = groupid
  form.gsb_chater_list:Add(gb_charter)
  form.gsb_chater_list.IsEditMode = false
  form.gsb_chater_list:ResetChildrenYPos()
  local mltbox_list = GetNewRichEdit(groupid)
  form.groupbox_1:Add(mltbox_list)
end
function RemoveChatPanel(form, name)
  local gui = nx_value("gui")
  local tab_item = get_tab_item(form, name)
  if not nx_is_valid(tab_item) then
    return
  end
  local is_remove_cur_chat = tab_item.rbtn_bg.Checked
  local tabCount = get_tab_count(form)
  if tabCount == 1 then
    form:Close()
    return
  end
  form.gsb_chater_list:Remove(tab_item)
  gui:Delete(tab_item)
  form.gsb_chater_list.IsEditMode = false
  form.gsb_chater_list:ResetChildrenYPos()
  local mltbox_list = get_tab_mltboxlist(form, name)
  if nx_is_valid(mltbox_list) then
    form.groupbox_1:Remove(mltbox_list)
    gui:Delete(mltbox_list)
  end
  local chater_list = form.chater_list
  if chater_list:FindChild(nx_string(name)) then
    chater_list:RemoveChild(nx_string(name))
  end
  if is_remove_cur_chat then
    local item = get_first_tab_item(form)
    if nx_is_valid(item) then
      SelectChatPanel(form, item.target)
    end
  end
end
function SelectChatPanel(form, name)
  local tab_item = get_tab_item(form, name)
  if not nx_is_valid(tab_item) then
    return
  end
  if nx_find_custom(tab_item, "rbtn_bg") and nx_name(tab_item.rbtn_bg) == "RadioButton" then
    tab_item.rbtn_bg.Checked = true
  end
end
function SwitchToChatPanel(form, name)
  local gui = nx_value("gui")
  form.btn_roleinfo.Visible = true
  form.cbtn_hide_reply.Visible = true
  form.lbl_hide_reply.Visible = true
  form.cbtn_gchat_shield.Visible = false
  form.lbl_gchat_shield.Visible = false
  show_chat_panel(form, name)
  form.curTargetName = name
  form.curGroupid = ""
  form.lbl_title.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_chat_form_title", name))
  gui.Focused = form.txt_content
end
function SwitchToGroupChatPanel(form, groupid, name)
  local gui = nx_value("gui")
  form.btn_roleinfo.Visible = false
  form.cbtn_hide_reply.Visible = false
  form.lbl_hide_reply.Visible = false
  form.cbtn_gchat_shield.Visible = true
  form.lbl_gchat_shield.Visible = true
  form.cbtn_gchat_shield.Checked = get_groupchat_shield(groupid)
  if is_groupchat_master(groupid) then
    form.btn_add_member.Visible = true
    form.btn_quit_group.Visible = false
  else
    form.btn_add_member.Visible = false
    form.btn_quit_group.Visible = true
  end
  show_chat_panel(form, groupid)
  form.curGroupid = groupid
  form.curTargetName = ""
  form.lbl_title.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_chat_form_title", name))
  gui.Focused = form.txt_content
end
function show_chat_panel(form, name)
  local ctrlList = form.gsb_chater_list:GetChildControlList()
  for i = 1, table.getn(ctrlList) do
    local gb_charter = ctrlList[i]
    if nx_is_valid(gb_charter) and nx_find_custom(gb_charter, "target") then
      if nx_ws_equal(nx_widestr(gb_charter.target), nx_widestr(name)) then
        local mltbox_list = get_tab_mltboxlist(form, name)
        if nx_is_valid(mltbox_list) then
          mltbox_list.Visible = true
        end
      else
        local mltbox_list = get_tab_mltboxlist(form, gb_charter.target)
        if nx_is_valid(mltbox_list) then
          mltbox_list.Visible = false
        end
      end
    end
  end
end
function clear_tab_selected(rbtn)
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.gsb_chater_list:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "target") then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.rbtn_bg, rbtn) then
          child.rbtn_hide.Checked = true
        end
      else
        child.rbtn_hide.Checked = true
      end
    end
  end
end
function clear_groupchat_tab_selected(rbtn)
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.groupchat_list:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "target") then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.rbtn_bg, rbtn) then
          child.rbtn_hide.Checked = true
        end
      else
        child.rbtn_hide.Checked = true
      end
    end
  end
end
function update_player_info(form, player_name)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_2.Visible = true
  form.groupbox_gchat_member.Visible = false
  if nx_string(player_name) == "" then
    return
  end
  clear_player_info(form)
  form.lbl_info_name1.Text = nx_widestr(player_name)
  local relation_name = get_relation_name(player_name)
  form.lbl_info_friend.Text = nx_widestr("(") .. nx_widestr(relation_name) .. nx_widestr(")")
  nx_execute("custom_sender", "custom_get_chater_info", player_name, 2)
end
function update_group_member_info(form, groupid)
  form.groupbox_2.Visible = false
  form.groupbox_gchat_member.Visible = true
  update_group_member_box(form, form.groupchat_list, groupid)
end
function update_group_member_box(form, groupbox, groupid)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  if 0 < child_count then
    for i = child_count, 1, -1 do
      local child = child_table[i]
      groupbox:Remove(child)
    end
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(PLAYER_GROUP_CHAT_REC) then
    return
  end
  local row = client_player:FindRecordRow(PLAYER_GROUP_CHAT_REC, player_group_rec_groupid, nx_string(groupid))
  if nx_int(row) < nx_int(0) then
    return
  end
  local member_list = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, row, player_group_rec_memberlist)
  local str_lst = util_split_wstring(nx_widestr(member_list), ";")
  local member_lst = gchat_do_sort_byonline(str_lst)
  for i = 1, table.getn(member_lst) do
    local name_lst = util_split_wstring(nx_widestr(member_lst[i]), ",")
    local name = name_lst[1]
    local gb_charter = GetNewTabGroupchatItem(nx_widestr(name))
    local is_online = nx_int(name_lst[2])
    gb_charter.groupid = groupid
    gb_charter.target = nx_widestr(name)
    gb_charter.lbl_flag.Visible = false
    if is_online == nx_int(1) then
      gb_charter.lbl_name.ForeColor = color_online
    else
      gb_charter.lbl_name.ForeColor = color_offline
    end
    if is_groupchat_master_name(groupid, name) then
      gb_charter.lbl_flag.Visible = true
    end
    groupbox:Add(gb_charter)
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function clear_player_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_info_photo1.BackImage = ""
  form.lbl_info_friend.Text = nx_widestr("--")
  form.lbl_info_power1.Text = nx_widestr("--")
  form.lbl_info_menpai1.Text = nx_widestr("--")
  form.lbl_info_bangpai1.Text = nx_widestr("--")
  form.lbl_info_roomname1.Text = nx_widestr("--")
  form.lbl_info_point1.Text = nx_widestr("--")
end
function get_relation_name(player_name)
  local gui = nx_value("gui")
  if is_buddy_player(player_name) then
    return gui.TextManager:GetText("ui_menu_friend_item_zhiyou")
  end
  if is_friend_player(player_name) then
    return gui.TextManager:GetText("ui_menu_friend_item_haoyou")
  end
  if is_enemy_player(player_name) then
    return gui.TextManager:GetText("ui_menu_friend_item_chouren")
  end
  if is_blood_player(player_name) then
    return gui.TextManager:GetText("ui_menu_friend_item_xuechou")
  end
  if is_attention_player(player_name) then
    return gui.TextManager:GetText("ui_menu_friend_item_guanzhu")
  end
  return gui.TextManager:GetText("ui_wu")
end
function update_self_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local self_name = client_player:QueryProp("Name")
  form.lbl_info_name2.Text = nx_widestr(self_name)
  form.lbl_info_photo2.BackImage = client_player:QueryProp("Photo")
  local title = client_player:QueryProp("LevelTitle")
  local title_name = gui.TextManager:GetText("desc_" .. title)
  form.lbl_info_power2.Text = nx_widestr(title_name)
  local school = client_player:QueryProp("School")
  if nx_string(school) == "" or nx_string(school) == "0" then
    school = client_player:QueryProp("NewSchool")
  end
  local school_name = get_school_name(school)
  form.lbl_info_menpai2.Text = nx_widestr(school_name)
  local guild_name = nx_widestr("")
  if not client_player:FindProp("GuildName") then
    guild_name = gui.TextManager:GetFormatText("ui_wu")
  else
    guild_name = client_player:QueryProp("GuildName")
    if nx_string(guild_name) == "" then
      guild_name = gui.TextManager:GetFormatText("ui_wu")
    end
  end
  form.lbl_info_bangpai2.Text = nx_widestr(guild_name)
  local revenge_point = client_player:QueryProp("RevengeIntegral")
  form.lbl_info_point2.Text = nx_widestr(revenge_point)
  local revenge_room = get_revenge_room_name(nx_int(revenge_point))
  local cn_name = gui.TextManager:GetText("ui_tianti_" .. revenge_room)
  form.lbl_info_roomname2.Text = nx_widestr(cn_name)
end
function get_tab_item(form, name)
  local ctrlList = form.gsb_chater_list:GetChildControlList()
  for i = 1, table.getn(ctrlList) do
    local gb_charter = ctrlList[i]
    if nx_is_valid(gb_charter) and nx_name(gb_charter) == "GroupBox" and nx_find_custom(gb_charter, "target") and nx_ws_equal(nx_widestr(gb_charter.target), nx_widestr(name)) then
      return gb_charter
    end
  end
  return nil
end
function get_first_tab_item(form)
  local tab_list = form.gsb_chater_list:GetChildControlList()
  for i = 1, table.getn(tab_list) do
    local child = tab_list[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "target") then
      return child
    end
  end
  return nil
end
function get_tab_count(form)
  local count = 0
  local ctrlList = form.gsb_chater_list:GetChildControlList()
  for i = 1, table.getn(ctrlList) do
    local child = ctrlList[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "target") then
      count = count + 1
    end
  end
  return count
end
function get_tab_mltboxlist(form, name)
  local ctrlName = "mltbox_list_" .. nx_string(name)
  local ctrl = form.groupbox_1:Find(ctrlName)
  if nx_is_valid(ctrl) then
    return ctrl
  end
  return nil
end
function get_prompt_groupbox(form, name)
  local ctrlName = "gb_prompt_" .. nx_string(name)
  local ctrl = form.groupbox_1:Find(ctrlName)
  if nx_is_valid(ctrl) then
    return ctrl
  end
  return nil
end
function get_school_name(school_id)
  local gui = nx_value("gui")
  local school_name = ""
  school_id = nx_string(school_id)
  if school_id == "school_shaolin" then
    school_name = gui.TextManager:GetText("ui_neigong_category_sl")
  elseif school_id == "school_wudang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_wd")
  elseif school_id == "school_emei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_em")
  elseif school_id == "school_junzitang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jz")
  elseif school_id == "school_jinyiwei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jy")
  elseif school_id == "school_jilegu" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jl")
  elseif school_id == "school_gaibang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_gb")
  elseif school_id == "school_tangmen" then
    school_name = gui.TextManager:GetText("ui_neigong_category_tm")
  elseif school_id == "school_mingjiao" then
    school_name = gui.TextManager:GetText("ui_neigong_category_mj")
  elseif school_id == "school_tianshan" then
    school_name = gui.TextManager:GetText("ui_neigong_category_ts")
  elseif school_id == "newschool_gumu" or school_id == "newschool_xuedao" or school_id == "newschool_huashan" or school_id == "newschool_damo" or school_id == "newschool_shenshui" or school_id == "newschool_changfeng" or school_id == "newschool_nianluo" or school_id == "newschool_shenji" or school_id == "newschool_xingmiao" or school_id == "newschool_wuxian" then
    school_name = gui.TextManager:GetText(school_id)
  else
    school_name = gui.TextManager:GetText("ui_task_school_null")
  end
  return school_name
end
function show_tab_flag(item, bShow)
  if nx_is_valid(item) and nx_name(item) == "GroupBox" and nx_find_custom(item, "target") and nx_find_custom(item, "lbl_flag") then
    item.lbl_flag.Visible = bShow
  end
end
function GetNewTabItem(name)
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_item
  if nx_is_valid(item) and nx_is_valid(tpl_item) then
    item.Name = "gb_chater_" .. nx_string(name)
    item.Left = tpl_item.Left
    item.Top = tpl_item.Top
    item.Width = tpl_item.Width
    item.Height = tpl_item.Height
    item.BackColor = tpl_item.BackColor
    item.NoFrame = tpl_item.NoFrame
    local tpl_bg = tpl_item:Find("item_bg")
    if nx_is_valid(tpl_bg) then
      local rbtn_bg = gui:Create("RadioButton")
      rbtn_bg.Left = tpl_bg.Left
      rbtn_bg.Top = tpl_bg.Top
      rbtn_bg.Width = tpl_bg.Width
      rbtn_bg.Height = tpl_bg.Height
      rbtn_bg.NormalImage = tpl_bg.NormalImage
      rbtn_bg.FocusImage = tpl_bg.FocusImage
      rbtn_bg.CheckedImage = tpl_bg.CheckedImage
      rbtn_bg.DrawMode = tpl_bg.DrawMode
      rbtn_bg.AutoSize = tpl_bg.AutoSize
      nx_bind_script(rbtn_bg, nx_current())
      nx_callback(rbtn_bg, "on_checked_changed", "on_item_select_changed")
      item:Add(rbtn_bg)
      item.rbtn_bg = rbtn_bg
    end
    local tpl_hide = tpl_item:Find("item_hide")
    if nx_is_valid(tpl_hide) then
      local rbtn_hide = gui:Create("RadioButton")
      rbtn_hide.Left = tpl_hide.Left
      rbtn_hide.Top = tpl_hide.Top
      rbtn_hide.Width = tpl_hide.Width
      rbtn_hide.Height = tpl_hide.Height
      rbtn_hide.NormalImage = tpl_hide.NormalImage
      rbtn_hide.FocusImage = tpl_hide.FocusImage
      rbtn_hide.CheckedImage = tpl_hide.CheckedImage
      rbtn_hide.DrawMode = tpl_hide.DrawMode
      rbtn_hide.AutoSize = tpl_hide.AutoSize
      rbtn_hide.Visible = false
      item:Add(rbtn_hide)
      item.rbtn_hide = rbtn_hide
    end
    local tpl_flag = tpl_item:Find("item_flag")
    if nx_is_valid(tpl_flag) then
      local lbl_flag = gui:Create("Label")
      lbl_flag.Left = tpl_flag.Left
      lbl_flag.Top = tpl_flag.Top
      lbl_flag.Width = tpl_flag.Width
      lbl_flag.Height = tpl_flag.Height
      lbl_flag.DrawMode = tpl_flag.DrawMode
      lbl_flag.AutoSize = tpl_flag.AutoSize
      lbl_flag.Align = tpl_flag.Align
      lbl_flag.BackImage = tpl_flag.BackImage
      item:Add(lbl_flag)
      item.lbl_flag = lbl_flag
    end
    local tpl_name = tpl_item:Find("item_name")
    if nx_is_valid(tpl_name) then
      local lbl_name = gui:Create("Label")
      lbl_name.Left = tpl_name.Left
      lbl_name.Top = tpl_name.Top
      lbl_name.Width = tpl_name.Width
      lbl_name.Height = tpl_name.Height
      lbl_name.ForeColor = tpl_name.ForeColor
      lbl_name.Font = tpl_name.Font
      lbl_name.Align = tpl_name.Align
      lbl_name.Text = nx_widestr(name)
      item:Add(lbl_name)
      item.lbl_name = lbl_name
    end
    local tpl_close = tpl_item:Find("item_close")
    if nx_is_valid(tpl_close) then
      local btn_close = gui:Create("Button")
      btn_close.Left = tpl_close.Left
      btn_close.Top = tpl_close.Top
      btn_close.Width = tpl_close.Width
      btn_close.Height = tpl_close.Height
      btn_close.NormalImage = tpl_close.NormalImage
      btn_close.FocusImage = tpl_close.FocusImage
      btn_close.PushImage = tpl_close.PushImage
      btn_close.DrawMode = tpl_close.DrawMode
      btn_close.AutoSize = tpl_close.AutoSize
      nx_bind_script(btn_close, nx_current())
      nx_callback(btn_close, "on_click", "on_item_close_click")
      item:Add(btn_close)
      item.btn_close = btn_close
    end
  end
  return item
end
function GetNewTabGroupchatItem(name)
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupchat_item
  if nx_is_valid(item) and nx_is_valid(tpl_item) then
    item.Name = "groupchat_" .. nx_string(groupid)
    item.Left = tpl_item.Left
    item.Top = tpl_item.Top
    item.Width = tpl_item.Width
    item.Height = tpl_item.Height
    item.BackColor = tpl_item.BackColor
    item.NoFrame = tpl_item.NoFrame
    local tpl_bg = tpl_item:Find("g_item_bg")
    if nx_is_valid(tpl_bg) then
      local rbtn_bg = gui:Create("RadioButton")
      rbtn_bg.Left = tpl_bg.Left
      rbtn_bg.Top = tpl_bg.Top
      rbtn_bg.Width = tpl_bg.Width
      rbtn_bg.Height = tpl_bg.Height
      rbtn_bg.NormalImage = tpl_bg.NormalImage
      rbtn_bg.FocusImage = tpl_bg.FocusImage
      rbtn_bg.CheckedImage = tpl_bg.CheckedImage
      rbtn_bg.DrawMode = tpl_bg.DrawMode
      rbtn_bg.AutoSize = tpl_bg.AutoSize
      nx_bind_script(rbtn_bg, nx_current())
      nx_callback(rbtn_bg, "on_checked_changed", "on_g_item_select_changed")
      nx_callback(rbtn_bg, "on_right_click", "on_g_item_bg_right_click")
      nx_callback(rbtn_bg, "on_left_double_click", "on_g_item_double_click")
      item:Add(rbtn_bg)
      item.rbtn_bg = rbtn_bg
    end
    local tpl_hide = tpl_item:Find("g_item_hide")
    if nx_is_valid(tpl_hide) then
      local rbtn_hide = gui:Create("RadioButton")
      rbtn_hide.Left = tpl_hide.Left
      rbtn_hide.Top = tpl_hide.Top
      rbtn_hide.Width = tpl_hide.Width
      rbtn_hide.Height = tpl_hide.Height
      rbtn_hide.NormalImage = tpl_hide.NormalImage
      rbtn_hide.FocusImage = tpl_hide.FocusImage
      rbtn_hide.CheckedImage = tpl_hide.CheckedImage
      rbtn_hide.DrawMode = tpl_hide.DrawMode
      rbtn_hide.AutoSize = tpl_hide.AutoSize
      rbtn_hide.Visible = false
      item:Add(rbtn_hide)
      item.rbtn_hide = rbtn_hide
    end
    local tpl_name = tpl_item:Find("g_item_name")
    if nx_is_valid(tpl_name) then
      local lbl_name = gui:Create("Label")
      lbl_name.Left = tpl_name.Left
      lbl_name.Top = tpl_name.Top
      lbl_name.Width = tpl_name.Width
      lbl_name.Height = tpl_name.Height
      lbl_name.ForeColor = tpl_name.ForeColor
      lbl_name.Font = tpl_name.Font
      lbl_name.Align = tpl_name.Align
      lbl_name.Text = nx_widestr(name)
      item:Add(lbl_name)
      item.lbl_name = lbl_name
    end
    local tpl_flag = tpl_item:Find("g_item_flag")
    if nx_is_valid(tpl_flag) then
      local lbl_flag = gui:Create("Label")
      lbl_flag.Left = tpl_flag.Left
      lbl_flag.Top = tpl_flag.Top
      lbl_flag.Width = tpl_flag.Width
      lbl_flag.Height = tpl_flag.Height
      lbl_flag.DrawMode = tpl_flag.DrawMode
      lbl_flag.AutoSize = tpl_flag.AutoSize
      lbl_flag.Align = tpl_flag.Align
      lbl_flag.BackImage = tpl_flag.BackImage
      item:Add(lbl_flag)
      item.lbl_flag = lbl_flag
    end
  end
  return item
end
function GetNewTabGroupItem(groupid, name)
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_item
  if nx_is_valid(item) and nx_is_valid(tpl_item) then
    item.Name = "gb_chater_" .. nx_string(groupid)
    item.Left = tpl_item.Left
    item.Top = tpl_item.Top
    item.Width = tpl_item.Width
    item.Height = tpl_item.Height
    item.BackColor = tpl_item.BackColor
    item.NoFrame = tpl_item.NoFrame
    local tpl_bg = tpl_item:Find("item_bg")
    if nx_is_valid(tpl_bg) then
      local rbtn_bg = gui:Create("RadioButton")
      rbtn_bg.Left = tpl_bg.Left
      rbtn_bg.Top = tpl_bg.Top
      rbtn_bg.Width = tpl_bg.Width
      rbtn_bg.Height = tpl_bg.Height
      rbtn_bg.NormalImage = tpl_bg.NormalImage
      rbtn_bg.FocusImage = tpl_bg.FocusImage
      rbtn_bg.CheckedImage = tpl_bg.CheckedImage
      rbtn_bg.DrawMode = tpl_bg.DrawMode
      rbtn_bg.AutoSize = tpl_bg.AutoSize
      nx_bind_script(rbtn_bg, nx_current())
      nx_callback(rbtn_bg, "on_checked_changed", "on_item_select_changed")
      item:Add(rbtn_bg)
      item.rbtn_bg = rbtn_bg
    end
    local tpl_hide = tpl_item:Find("item_hide")
    if nx_is_valid(tpl_hide) then
      local rbtn_hide = gui:Create("RadioButton")
      rbtn_hide.Left = tpl_hide.Left
      rbtn_hide.Top = tpl_hide.Top
      rbtn_hide.Width = tpl_hide.Width
      rbtn_hide.Height = tpl_hide.Height
      rbtn_hide.NormalImage = tpl_hide.NormalImage
      rbtn_hide.FocusImage = tpl_hide.FocusImage
      rbtn_hide.CheckedImage = tpl_hide.CheckedImage
      rbtn_hide.DrawMode = tpl_hide.DrawMode
      rbtn_hide.AutoSize = tpl_hide.AutoSize
      rbtn_hide.Visible = false
      item:Add(rbtn_hide)
      item.rbtn_hide = rbtn_hide
    end
    local tpl_flag = tpl_item:Find("item_flag")
    if nx_is_valid(tpl_flag) then
      local lbl_flag = gui:Create("Label")
      lbl_flag.Left = tpl_flag.Left
      lbl_flag.Top = tpl_flag.Top
      lbl_flag.Width = tpl_flag.Width
      lbl_flag.Height = tpl_flag.Height
      lbl_flag.DrawMode = tpl_flag.DrawMode
      lbl_flag.AutoSize = tpl_flag.AutoSize
      lbl_flag.Align = tpl_flag.Align
      lbl_flag.BackImage = tpl_flag.BackImage
      item:Add(lbl_flag)
      item.lbl_flag = lbl_flag
    end
    local tpl_name = tpl_item:Find("item_name")
    if nx_is_valid(tpl_name) then
      local lbl_name = gui:Create("Label")
      lbl_name.Left = tpl_name.Left
      lbl_name.Top = tpl_name.Top
      lbl_name.Width = tpl_name.Width
      lbl_name.Height = tpl_name.Height
      lbl_name.ForeColor = tpl_name.ForeColor
      lbl_name.Font = tpl_name.Font
      lbl_name.Align = tpl_name.Align
      lbl_name.Text = nx_widestr(name)
      item:Add(lbl_name)
      item.lbl_name = lbl_name
    end
    local tpl_close = tpl_item:Find("item_close")
    if nx_is_valid(tpl_close) then
      local btn_close = gui:Create("Button")
      btn_close.Left = tpl_close.Left
      btn_close.Top = tpl_close.Top
      btn_close.Width = tpl_close.Width
      btn_close.Height = tpl_close.Height
      btn_close.NormalImage = tpl_close.NormalImage
      btn_close.FocusImage = tpl_close.FocusImage
      btn_close.PushImage = tpl_close.PushImage
      btn_close.DrawMode = tpl_close.DrawMode
      btn_close.AutoSize = tpl_close.AutoSize
      nx_bind_script(btn_close, nx_current())
      nx_callback(btn_close, "on_click", "on_item_close_click")
      item:Add(btn_close)
      item.btn_close = btn_close
    end
    local tpl_g_flag = tpl_item:Find("item_g_flag")
    if nx_is_valid(tpl_g_flag) then
      local lbl_g_flag = gui:Create("Label")
      lbl_g_flag.Left = tpl_g_flag.Left
      lbl_g_flag.Top = tpl_g_flag.Top
      lbl_g_flag.Width = tpl_g_flag.Width
      lbl_g_flag.Height = tpl_g_flag.Height
      lbl_g_flag.DrawMode = tpl_g_flag.DrawMode
      lbl_g_flag.AutoSize = tpl_g_flag.AutoSize
      lbl_g_flag.Align = tpl_g_flag.Align
      lbl_g_flag.BackImage = tpl_g_flag.BackImage
      item:Add(lbl_g_flag)
      item.lbl_g_flag = lbl_g_flag
    end
  end
  return item
end
function GetNewRichEdit(name)
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return nil
  end
  local richedit = gui:Create("MultiTextBox")
  local tpl_richedit = form.mltbox_list
  if nx_is_valid(richedit) and tpl_richedit then
    richedit.Name = "mltbox_list_" .. nx_string(name)
    richedit.Top = tpl_richedit.Top
    richedit.Left = tpl_richedit.Left
    richedit.Width = tpl_richedit.Width
    richedit.Height = tpl_richedit.Height
    richedit.NoFrame = tpl_richedit.NoFrame
    richedit.DrawMode = tpl_richedit.DrawMode
    richedit.AutoSize = tpl_richedit.AutoSize
    richedit.BackImage = tpl_richedit.BackImage
    richedit.ForeColor = tpl_richedit.ForeColor
    richedit.BackColor = tpl_richedit.BackColor
    richedit.Font = tpl_richedit.Font
    richedit.TextColor = tpl_richedit.TextColor
    richedit.SelectBarColor = tpl_richedit.SelectBarColor
    richedit.MouseInBarColor = tpl_richedit.MouseInBarColor
    richedit.ScrollSize = tpl_richedit.ScrollSize
    richedit.HasVScroll = tpl_richedit.HasVScroll
    richedit.AlwaysVScroll = tpl_richedit.AlwaysVScroll
    richedit.ViewRect = tpl_richedit.ViewRect
    richedit.LineHeight = tpl_richedit.LineHeight
    nx_bind_script(richedit, nx_current())
    nx_callback(richedit, "on_right_click_hyperlink", "on_hyperlink_right_click")
    if nx_is_valid(richedit.VScrollBar) and nx_is_valid(tpl_richedit.VScrollBar) then
      local vscrollbar = richedit.VScrollBar
      local tpl_vscrollbar = tpl_richedit.VScrollBar
      vscrollbar.BackColor = tpl_vscrollbar.BackColor
      vscrollbar.ButtonSize = tpl_vscrollbar.ButtonSize
      vscrollbar.FullBarBack = tpl_vscrollbar.FullBarBack
      vscrollbar.ShadowColor = tpl_vscrollbar.ShadowColor
      vscrollbar.BackImage = tpl_vscrollbar.BackImage
      vscrollbar.NoFrame = tpl_vscrollbar.NoFrame
      vscrollbar.DrawMode = tpl_vscrollbar.DrawMode
      vscrollbar.DecButton.NormalImage = tpl_vscrollbar.DecButton.NormalImage
      vscrollbar.DecButton.FocusImage = tpl_vscrollbar.DecButton.FocusImage
      vscrollbar.DecButton.PushImage = tpl_vscrollbar.DecButton.PushImage
      vscrollbar.DecButton.Width = tpl_vscrollbar.DecButton.Width
      vscrollbar.DecButton.Height = tpl_vscrollbar.DecButton.Height
      vscrollbar.DecButton.DrawMode = tpl_vscrollbar.DecButton.DrawMode
      vscrollbar.IncButton.NormalImage = tpl_vscrollbar.IncButton.NormalImage
      vscrollbar.IncButton.FocusImage = tpl_vscrollbar.IncButton.FocusImage
      vscrollbar.IncButton.PushImage = tpl_vscrollbar.IncButton.PushImage
      vscrollbar.IncButton.Width = tpl_vscrollbar.IncButton.Width
      vscrollbar.IncButton.Height = tpl_vscrollbar.IncButton.Height
      vscrollbar.IncButton.DrawMode = tpl_vscrollbar.IncButton.DrawMode
      vscrollbar.TrackButton.NormalImage = tpl_vscrollbar.TrackButton.NormalImage
      vscrollbar.TrackButton.FocusImage = tpl_vscrollbar.TrackButton.FocusImage
      vscrollbar.TrackButton.PushImage = tpl_vscrollbar.TrackButton.PushImage
      vscrollbar.TrackButton.Width = tpl_vscrollbar.TrackButton.Width
      vscrollbar.TrackButton.Height = tpl_vscrollbar.TrackButton.Height
      vscrollbar.TrackButton.Enabled = tpl_vscrollbar.TrackButton.Enabled
      vscrollbar.TrackButton.DrawMode = tpl_vscrollbar.TrackButton.DrawMode
    end
  end
  return richedit
end
function change_form_size()
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function start_groupchat(groupid)
  local groupname = get_groupname(groupid)
  if nx_string(groupname) == "" then
    return
  end
  local form = nx_value(FORM_CHAT_WINDOW)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", FORM_CHAT_WINDOW, true, false)
    form:Show()
  end
  form.Visible = true
  form.is_minimize = false
  form.curGroupid = groupid
  if form.chater_list:FindChild(nx_string(groupid)) then
    SelectChatPanel(form, groupid)
    return
  end
  local node = form.chater_list:CreateChild(nx_string(groupid))
  node.groupid = groupid
  CreateNewGroupChatPanel(form, groupid, groupname)
  SelectChatPanel(form, groupid)
end
function get_groupname(groupid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(PLAYER_GROUP_CHAT_REC) then
    return false
  end
  local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
  for i = 0, rows - 1 do
    local group_id = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_groupid)
    if nx_string(group_id) == nx_string(groupid) then
      return client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_groupname)
    end
  end
  return ""
end
function add_groupchat_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddTableBind(PLAYER_GROUP_CHAT_REC, form, nx_current(), "on_player_group_chat_rec_changed")
  end
end
function del_groupchat_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind(PLAYER_GROUP_CHAT_REC, form)
  end
end
function on_player_group_chat_rec_changed(form, rec_name, opt_type, row, col)
  if form.curGroupid ~= "" then
    update_group_member_info(form, form.curGroupid)
  end
  if nx_string(opt_type) == "del" then
    update_group_chater_list(form)
  end
end
function update_group_chater_list(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(PLAYER_GROUP_CHAT_REC) then
    return
  end
  local list_count = form.chater_list:GetChildCount()
  for i = list_count - 1, 0, -1 do
    local item = form.chater_list:GetChildByIndex(i)
    if nx_is_valid(item) and nx_find_custom(item, "groupid") then
      local row = client_player:FindRecordRow(PLAYER_GROUP_CHAT_REC, player_group_rec_groupid, nx_string(item.groupid))
      if nx_int(row) < nx_int(0) then
        RemoveChatPanel(form, item.groupid)
      end
    end
  end
end
function on_btn_add_member_click(btn)
  local form = btn.ParentForm
  if nx_string(form.curGroupid) == "" then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(util_text("ui_groupchat_add_member1"))
  dialog.info_label.Text = nx_widestr(util_text("ui_groupchat_add_member"))
  dialog.allow_empty = false
  dialog:ShowModal()
  local res, name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_groupchat_add_member", 5, form.curGroupid, get_groupname(form.curGroupid), nx_widestr(name))
  end
end
function groupchat_member_quit(groupid)
  nx_execute("custom_sender", "custom_groupchat_member_quit", 7, groupid)
end
function groupchat_del_member(groupid, target_name)
  nx_execute("custom_sender", "custom_groupchat_del_member", 6, groupid, get_groupname(groupid), target_name)
end
function groupchat_del_groupchat(groupid)
  nx_execute("custom_sender", "custom_groupchat_del_member", 2, groupid)
end
function is_groupchat_master(groupid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryProp("Name")
  local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
  for i = 0, rows - 1 do
    local group_id = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_groupid)
    if nx_string(groupid) == nx_string(group_id) then
      local master = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_master)
      if nx_ws_equal(nx_widestr(name), nx_widestr(master)) then
        return true
      end
    end
  end
  return false
end
function is_groupchat_master_name(groupid, name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
  for i = 0, rows - 1 do
    local group_id = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_groupid)
    if nx_string(groupid) == nx_string(group_id) then
      local master = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_master)
      if nx_ws_equal(nx_widestr(name), nx_widestr(master)) then
        return true
      end
    end
  end
  return false
end
function gchat_do_sort_byonline(record_table)
  local online_table = {}
  local offline_table = {}
  local count = table.getn(record_table)
  for i = 1, count do
    local name_lst = util_split_wstring(nx_widestr(record_table[i]), ",")
    if nx_int(name_lst[2]) == nx_int(1) then
      table.insert(online_table, record_table[i])
    else
      table.insert(offline_table, record_table[i])
    end
  end
  local new_table = {}
  count = table.getn(online_table)
  for i = 1, count do
    table.insert(new_table, online_table[i])
  end
  count = table.getn(offline_table)
  for i = 1, count do
    table.insert(new_table, offline_table[i])
  end
  return new_table
end
function on_btn_quit_group_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local groupid = form.curGroupid
  if groupid == "" then
    return false
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_member_groupchat_quit")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    groupchat_member_quit(groupid)
  end
end
function on_cbtn_gchat_shield_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local groupid = form.curGroupid
  if groupid == "" then
    return false
  end
  nx_execute("custom_sender", "custom_groupchat_set_shield", 8, groupid)
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
function close_form()
  local form = nx_value(FORM_CHAT_WINDOW)
  if nx_is_valid(form) then
    form:Close()
  end
end
