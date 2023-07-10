require("utils")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_chat_system\\chat_util_define")
require("form_stage_main\\switch\\switch_define")
local FORM_CHAT_GROUP = "form_stage_main\\form_chat_system\\form_chat_group"
local FORM_CHAT_LIGHT = "form_stage_main\\form_chat_system\\form_chat_light"
local FORM_CHAT_WINDOW = "form_stage_main\\form_chat_system\\form_chat_window"
local FORM_CHAT_HISTORY = "form_stage_main\\form_chat_system\\form_chat_history"
local FORM_MAIN_FACE_CHAT = "form_stage_main\\form_main\\form_main_face_chat"
local FORM_MAIN_FACE = "form_stage_main\\form_main\\form_main_face"
local icon_online = "gui\\special\\sns_new\\icon_state_01.png"
local icon_offline = "gui\\special\\sns_new\\icon_state_03.png"
local MEMBER_NAN = 20000
function main_form_init(form)
  form.Fixed = false
  form.is_minimize = false
end
function on_main_form_open(form)
  InitForm(form)
  form.is_minimize = false
end
function on_main_form_close(form)
  local gui = nx_value("gui")
  gui.hyperfocused = nil
  nx_destroy(form)
  local form_face = nx_value(FORM_MAIN_FACE)
  if nx_is_valid(form_face) then
    form_face:Close()
  end
  local form_history = nx_value("chat_group_history")
  if nx_is_valid(form_history) then
    form_history:Close()
  end
end
function open_form()
  local form = nx_value(FORM_CHAT_GROUP)
  if not nx_is_valid(form) then
    form = util_auto_show_hide_form(FORM_CHAT_GROUP)
  else
    form:Close()
    return
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
  form_light.btn_opengroup.Visible = true
  form_light.lbl_groupoutline.Visible = false
end
function on_btn_chat_face_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  gui.Focused = form.txt_content
  local face_form = nx_value(FORM_MAIN_FACE_CHAT)
  if nx_is_valid(face_form) then
    nx_gen_event(face_form, "selectface_return", "cancel", "")
  else
    local form_main_face = nx_execute("util_gui", "util_get_form", FORM_MAIN_FACE, true, false)
    nx_set_value(FORM_MAIN_FACE_CHAT, form_main_face)
    form_main_face.AbsLeft = btn.AbsLeft + btn.Width
    form_main_face.AbsTop = btn.AbsTop + btn.Height - form_main_face.Height
    form_main_face.type = 1
    form_main_face.Visible = true
    form_main_face:Show()
    local res, html = nx_wait_event(100000000, form_main_face, "selectface_return")
    local form_chat_group = nx_value(FORM_CHAT_GROUP)
    if res == "ok" and nx_is_valid(form_chat_group) then
      add_item_to_chatedit(form, html)
    end
    form_main_face:Close()
  end
  nx_set_value(FORM_MAIN_FACE_CHAT, nil)
end
function on_btn_chat_history_click(btn)
  local form = btn.ParentForm
  local form_history = nx_value("chat_group_history")
  if not nx_is_valid(form_history) then
    form_history = nx_execute("util_gui", "util_get_form", FORM_CHAT_HISTORY, true, false, 2)
    nx_set_value("chat_group_history", form_history)
    form_history.Left = form.Left + form.Width
    form_history.Top = form.Top
    form_history.Visible = true
    form_history:Show()
    nx_execute(FORM_CHAT_HISTORY, "Init_Form", form_history, GROUP_MESSAGE_FLAG)
  else
    nx_set_value("chat_group_history", nx_null())
    form_history:Close()
  end
end
function on_btn_send_click(btn)
  local form = btn.ParentForm
  if nx_string(form.txt_content.Text) == "" then
    return
  end
  local content = nx_widestr(form.txt_content.Text)
  send_content(form, content)
end
function on_txt_content_enter(redit)
  local form = redit.ParentForm
  on_btn_send_click(form.btn_send)
end
function on_txt_content_get_focus(redit)
  local gui = nx_value("gui")
  gui.hyperfocused = redit
end
function on_btn_refresh_click(btn)
  request_get_guild_info()
end
function on_item_select_changed(rbtn)
  if rbtn.Checked then
    ClearItemSelected(rbtn)
  end
end
function on_item_double_click(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local self_name = client_player:QueryProp("Name")
  local player_name = item.lbl_name.Text
  if nx_ws_equal(nx_widestr(self_name), nx_widestr(player_name)) then
    return
  end
  nx_execute("custom_sender", "custom_request_chat", player_name)
end
function on_item_right_click(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local self_name = client_player:QueryProp("Name")
  local player_name = item.lbl_name.Text
  if nx_ws_equal(nx_widestr(self_name), nx_widestr(player_name)) then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "chat_group", "chat_group")
  nx_execute("menu_game", "menu_recompose", menu_game, item)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x + 25, y)
end
function on_btn_unfold_click(btn)
  local form = btn.ParentForm
  form.Width = form.groupbox_info.Left + form.groupbox_info.Width + form.btn_fold.Width / 2
  form.groupbox_info.Visible = true
  form.btn_unfold.Visible = false
  form.btn_fold.Visible = true
end
function on_btn_fold_click(btn)
  local form = btn.ParentForm
  form.Width = form.lbl_back.Width + form.btn_unfold.Width / 2
  form.groupbox_info.Visible = false
  form.btn_unfold.Visible = true
  form.btn_fold.Visible = false
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
function on_receive_guild_basic_info(...)
  local form = nx_value(FORM_CHAT_GROUP)
  if not nx_is_valid(form) then
    return
  end
  local guild_name = nx_widestr(arg[1])
  local guild_level = nx_int(arg[2])
  local guild_purpose = nx_widestr(arg[7])
  local guild_notice = nx_widestr(arg[8])
  local guild_hotness = nx_int(arg[11])
  local guild_onlinecount = nx_int(arg[13])
  local guild_membercount = nx_int(arg[14])
  local name_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_name", guild_name)
  local hotness_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_hotness", guild_hotness)
  local level_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_level", guild_level)
  local membercount_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_membercount", guild_membercount)
  local purpose_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_aim", guild_purpose)
  local notice_info = get_format_info("ui_chat_guild_content", "ui_chat_guild_notice", guild_notice)
  form.lbl_title.Text = guild_name
  if nx_is_valid(form.lbl_guildname) then
    form.lbl_guildname.Text = guild_name
  end
  form.lbl_guildhotness.Text = nx_widestr(guild_hotness)
  form.lbl_guildlevel.Text = nx_widestr(guild_level)
  local fmt = string.format("%d/%d", nx_number(guild_onlinecount), nx_number(guild_membercount))
  form.lbl_guildmemcount.Text = nx_widestr(fmt)
  form.mltbox_purpose.HtmlText = nx_widestr(guild_purpose)
  form.mltbox_notice.HtmlText = nx_widestr(guild_notice)
  fmt = string.format("[%s/%s]", nx_string(guild_onlinecount), nx_string(guild_membercount))
  form.lbl_membercount.Text = nx_widestr(fmt)
end
function on_receive_member_list(from, to, rowcount, ...)
  local form = nx_value(FORM_CHAT_GROUP)
  if not nx_is_valid(form) then
    return
  end
  if from < 0 or from == to then
    return
  end
  local size = table.getn(arg)
  if size <= 0 or size % 8 ~= 0 then
    return
  end
  local online_table = {}
  local offline_table = {}
  for i = 1, rowcount do
    local base = (i - 1) * 8
    local member = {
      arg[base + 1],
      arg[base + 2],
      arg[base + 3],
      arg[base + 4],
      arg[base + 5],
      arg[base + 6],
      arg[base + 7],
      arg[base + 8]
    }
    local is_online = nx_int(arg[base + 6]) == nx_int(1)
    if is_online then
      table.insert(online_table, member)
    else
      table.insert(offline_table, member)
    end
  end
  local groupbox = form.groupbox_memberlist
  ClearAllChild(groupbox)
  UpdateForm_Member(groupbox, online_table)
  UpdateForm_Member(groupbox, offline_table)
end
function AddContentToList(form, senderName, chat_content, chat_time, auto_save)
  local sub_date = chat_time
  local sub_time = chat_time
  local index = string.find(chat_time, " ")
  if index ~= nil then
    sub_date = string.sub(chat_time, 1, index - 1)
    sub_time = string.sub(chat_time, index + 1)
  end
  local gui = nx_value("gui")
  local info = nx_widestr(gui.TextManager:GetFormatText("gcw_chat_record_message", senderName, sub_time, chat_content))
  ShowContent(form, info)
  if auto_save then
    local xml_doc = get_record_doc()
    write_chat_record(xml_doc, GROUP_MESSAGE_FLAG, senderName, chat_content, 0, chat_time)
  end
end
function ShowContent(form, info)
  if not nx_is_valid(form) then
    return
  end
  local mltbox_list = form.mltbox_list
  if nx_is_valid(mltbox_list) then
    mltbox_list:AddHtmlText(nx_widestr(info), -1)
    mltbox_list.VScrollBar.Value = mltbox_list.VScrollBar.Maximum
  end
end
function send_content(form, chat_content)
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local check_words = nx_value("CheckWords")
  if nx_is_valid(check_words) then
    chat_content = nx_execute("custom_sender", "check_word", check_words, nx_widestr(chat_content), 1)
  end
  local Time = os.date("*t", os.time())
  local chat_time = string.format("%d-%02d-%02d %02d:%02d:%02d", Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
  if nx_is_valid(form) then
    local self_name = client_player:QueryProp("Name")
    AddContentToList(form, self_name, chat_content, chat_time, true)
    form.txt_content.Text = nx_widestr("")
    local gui = nx_value("gui")
    gui.Focused = nx_null()
    gui.Focused = form.txt_content
  end
  nx_execute("custom_sender", "custom_send_group_chat_content", chat_content, chat_time)
end
function accept_content(form, target_name, chat_content, chat_time)
  AddContentToList(form, target_name, chat_content, chat_time, false)
end
function start_chat()
end
function add_item_to_chatedit(form, html)
  form.txt_content:Append(html, -1)
  local gui = nx_value("gui")
  gui.Focused = form.txt_content
end
function add_hyperlink(html)
  local form = nx_value(FORM_CHAT_GROUP)
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
function get_format_info(content_flag, name_tip, value_info)
  local gui = nx_value("gui")
  local name_info = gui.TextManager:GetText(name_tip)
  return gui.TextManager:GetFormatText(content_flag, name_info, value_info)
end
function request_get_guild_info()
  nx_execute("custom_sender", "custom_request_basic_guild_info")
  nx_execute("custom_sender", "custom_request_guild_member", 0, MEMBER_NAN)
end
function InitForm(form)
  if not nx_is_valid(form) then
    return
  end
  change_form_size()
  form.groupbox_item.Visible = false
  request_get_guild_info()
  local gui = nx_value("gui")
  gui.Focused = form.txt_content
end
function UpdateForm_Member(groupbox, member_table)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  local member_count = table.getn(member_table)
  for i = 1, member_count do
    local member = member_table[i]
    local item = GetNewItem()
    item.player_name = member[1]
    item.position_name = member[2]
    item.school = member[3]
    item.power = member[4]
    item.last_online = member[5]
    item.online_state = member[6]
    item.active_value = member[7]
    item.contribute_value = member[8]
    item.lbl_name.Text = nx_widestr(item.player_name)
    item.lbl_flag.BackImage = nx_int(item.online_state) == nx_int(1) and icon_online or icon_offline
    groupbox:Add(item)
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function ClearItemSelected(rbtn)
  local form = nx_value(FORM_CHAT_GROUP)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.groupbox_memberlist:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("item") then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.rbtn_item, rbtn) then
          child.rbtn_hide.Checked = true
        end
      else
        child.rbtn_hide.Checked = true
      end
    end
  end
end
function ClearAllChild(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  if 0 < child_count then
    for i = child_count, 1, -1 do
      local child = child_table[i]
      if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
        groupbox:Remove(child)
        gui:Delete(child)
      end
    end
  end
end
function GetNewItem()
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_GROUP)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "item"
  item.isneedremove = false
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  local tpl_bg = tpl_item:Find("item_bg")
  if nx_is_valid(tpl_bg) then
    local rbtn_item = gui:Create("RadioButton")
    rbtn_item.Left = tpl_bg.Left
    rbtn_item.Top = tpl_bg.Top
    rbtn_item.Width = tpl_bg.Width
    rbtn_item.Height = tpl_bg.Height
    rbtn_item.NormalImage = tpl_bg.NormalImage
    rbtn_item.FocusImage = tpl_bg.FocusImage
    rbtn_item.CheckedImage = tpl_bg.CheckedImage
    rbtn_item.DrawMode = tpl_bg.DrawMode
    rbtn_item.AutoSize = tpl_bg.AutoSize
    nx_bind_script(rbtn_item, nx_current())
    nx_callback(rbtn_item, "on_checked_changed", "on_item_select_changed")
    nx_callback(rbtn_item, "on_left_double_click", "on_item_double_click")
    nx_callback(rbtn_item, "on_right_click", "on_item_right_click")
    item:Add(rbtn_item)
    item.rbtn_item = rbtn_item
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
    item:Add(lbl_name)
    item.lbl_name = lbl_name
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
    item:Add(lbl_flag)
    item.lbl_flag = lbl_flag
  end
  return item
end
function change_form_size()
  local form = nx_value(FORM_CHAT_GROUP)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
