require("share\\chat_define")
require("form_stage_main\\form_tvt\\define")
require("util_gui")
require("util_vip")
require("form_stage_main\\switch\\switch_define")
require("util_role_prop")
local chat_channel_table = {
  ui_chat_channel_1 = CHATTYPE_VISUALRANGE,
  ui_chat_channel_2 = CHATTYPE_SCENE,
  ui_chat_channel_4 = CHATTYPE_TEAM,
  ui_chat_channel_5 = CHATTYPE_FRIEND,
  ui_chat_channel_6 = CHATTYPE_GUILD,
  ui_chat_channel_7 = CHATTYPE_UNION,
  ui_chat_channel_8 = CHATTYPE_SCHOOL,
  ui_chat_channel_9 = CHATTYPE_WORLD,
  ui_chat_channel_19 = CHATTYPE_ROW,
  ui_chat_channel_22 = CHATTYPE_SCHOOL_FIGHT,
  ui_chat_channel_23 = CHATTYPE_BATTLE_FIELD,
  ui_chat_channel_25 = CHATTYPE_WORLD_WAR,
  ui_chat_channel_30 = CHATTYPE_FORCE,
  ui_chat_channel_32 = CHATTYPE_NEW_SCHOOL,
  ui_chat_channel_33 = CHATTYPE_NEW_TERRITORY,
  ui_chat_channel_34 = CHATTYPE_OUTLAND_WAR,
  ui_chat_channel_35 = CHATTYPE_MATCH_SANMENG,
  ui_chat_channel_39 = CHATTYPE_ALL_SCHOOL,
  ui_chat_channel_40 = CHATTYPE_GUILD_LEAGUE,
  ui_chat_channel_41 = CHATTYPE_BALANCE_WAR,
  ui_chat_channel_42 = CHATTYPE_WUDAO,
  ui_chat_channel_43 = CHATTYPE_LUANDOU,
  ui_chat_channel_80 = CHATTYPE_NEW_WAR_RULE_START
}
local chat_channel_short_table = {
  ["/fj "] = CHATTYPE_VISUALRANGE,
  ["/td "] = CHATTYPE_TEAM,
  ["/dw "] = CHATTYPE_ROW,
  ["/cj "] = CHATTYPE_SCENE,
  ["/mp "] = CHATTYPE_SCHOOL,
  ["/bp "] = CHATTYPE_GUILD,
  ["/sj "] = CHATTYPE_WORLD,
  ["/zx "] = CHATTYPE_UNION,
  ["/zc "] = CHATTYPE_BATTLE_FIELD,
  ["/zy "] = CHATTYPE_WORLD_WAR,
  ["/mpz "] = CHATTYPE_NEW_WAR_RULE_START,
  ["/sl"] = CHATTYPE_FORCE,
  ["/ys "] = CHATTYPE_NEW_SCHOOL,
  ["/nt "] = CHATTYPE_NEW_TERRITORY,
  ["/ow "] = CHATTYPE_OUTLAND_WAR,
  ["/zb "] = CHATTYPE_MATCH_SANMENG,
  ["/zpys "] = CHATTYPE_ALL_SCHOOL,
  ["/lm "] = CHATTYPE_GUILD_LEAGUE,
  ["/gd "] = CHATTYPE_BALANCE_WAR,
  ["/wd "] = CHATTYPE_WUDAO,
  ["/qf "] = CHATTYPE_LUANDOU
}
local chat_channel_clolor_table = {
  [CHATTYPE_VISUALRANGE] = "255,255,255,255",
  [CHATTYPE_TEAM] = "255,255,255,255",
  [CHATTYPE_ROW] = "255,255,255,255",
  [CHATTYPE_SCENE] = "255,255,255,255",
  [CHATTYPE_SCHOOL] = "255,255,255,255",
  [CHATTYPE_GUILD] = "255,255,255,255",
  [CHATTYPE_WORLD] = "255,255,255,255",
  [CHATTYPE_UNION] = "255,255,255,255",
  [CHATTYPE_SCHOOL_FIGHT] = "255,255,255,255",
  [CHATTYPE_BATTLE_FIELD] = "255,255,255,255",
  [CHATTYPE_WORLD_WAR] = "255,255,255,255",
  [CHATTYPE_FORCE] = "255,255,255,255",
  [CHATTYPE_NEW_SCHOOL] = "255,255,255,255",
  [CHATTYPE_NEW_TERRITORY] = "255,255,255,255",
  [CHATTYPE_OUTLAND_WAR] = "255,255,255,255",
  [CHATTYPE_MATCH_SANMENG] = "255,255,255,255",
  [CHATTYPE_ALL_SCHOOL] = "255,255,255,255",
  [CHATTYPE_GUILD_LEAGUE] = "255,255,255,255",
  [CHATTYPE_BALANCE_WAR] = "255,255,255,255",
  [CHATTYPE_WUDAO] = "255,255,255,255",
  [CHATTYPE_LUANDOU] = "255,255,255,255",
  [CHATTYPE_NEW_WAR_RULE_START] = "255,255,255,255"
}
local chat_channel_index_table = {
  ["/sj "] = 3,
  ["/bp "] = 4,
  ["/mp "] = 5,
  ["/cj "] = 6,
  ["/td "] = 7,
  ["/fj "] = 9,
  ["/dw "] = 10,
  ["/mpz "] = 80,
  ["/zc "] = 23,
  ["/zy "] = 25,
  ["/sl "] = 30,
  ["/ys "] = 32,
  ["/nt "] = 33,
  ["/ow "] = 34,
  ["/zb "] = 35,
  ["/zpys "] = 39,
  ["/lm "] = 40,
  ["/gd "] = 41,
  ["/wd "] = CHATTYPE_WUDAO,
  ["/qf "] = CHATTYPE_LUANDOU
}
local chat_chanel_sort_ui_table = {
  [CHATTYPE_GOSSIP] = 1,
  [CHATTYPE_WORLD] = 3,
  [CHATTYPE_GUILD] = 4,
  [CHATTYPE_SCHOOL] = 5,
  [CHATTYPE_SCENE] = 6,
  [CHATTYPE_TEAM] = 7,
  [CHATTYPE_ROW] = 10,
  [CHATTYPE_VISUALRANGE] = 9,
  [CHATTYPE_NEW_WAR_RULE_START] = 22,
  [CHATTYPE_BATTLE_FIELD] = 23,
  [CHATTYPE_WORLD_WAR] = 25,
  [CHATTYPE_FORCE] = 30,
  [CHATTYPE_NEW_SCHOOL] = 32,
  [CHATTYPE_NEW_TERRITORY] = 33,
  [CHATTYPE_OUTLAND_WAR] = 34,
  [CHATTYPE_MATCH_SANMENG] = 35,
  [CHATTYPE_ALL_SCHOOL] = 39,
  [CHATTYPE_GUILD_LEAGUE] = 40,
  [CHATTYPE_BALANCE_WAR] = 41,
  [CHATTYPE_WUDAO] = CHATTYPE_WUDAO,
  [CHATTYPE_LUANDOU] = CHATTYPE_LUANDOU
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
FORM_MAIN_CHAT = "form_stage_main\\form_main\\form_main_chat"
FORM_MAIN_PAGE = "form_stage_main\\form_main\\form_main_page"
local CMDSTEP_ERROR = 0
local CMDSTEP_NO_ARGS = 1
local CMDSTEP_HAVE_ARGS = 2
local CMDSTEP_EMPTY_ARGS = 3
local CHAT_LIST_HEIGHT = 20
local EQUIP_LINK_MAX_NUM = 6
local SHOW_ALL = 0
local SHOW_GOODS = 1
local SHOW_NO_GOODS = -1
local MAX_INFO_CNT = 500
local MAX_CHANNEL_IDX = 34
function get_channel_index_intable(channel)
  local channel_index = nx_int(chat_channel_index_table[nx_string(channel)])
  if nx_int(channel_index) >= nx_int(1) and nx_int(channel_index) <= nx_int(MAX_CHANNEL_IDX) then
    return channel_index
  end
  return nil
end
function chat_check_type_notice(gui, form, channel_type)
  if channel_type == CHATTYPE_ROW then
    if not have_teamid_prop() then
      chat_system_notice(gui, form, "2400")
      return 0
    end
  elseif channel_type == CHATTYPE_TEAM then
    if nx_int(get_teamtype_prop()) ~= nx_int(1) then
      chat_system_notice(gui, form, "2401")
      return 0
    end
  elseif channel_type == CHATTYPE_SCHOOL then
    if not have_school_prop() then
      chat_system_notice(gui, form, "2402")
      return 0
    end
  elseif channel_type == CHATTYPE_GUILD then
    if not have_guild_prop() then
      chat_system_notice(gui, form, "2403")
      return 0
    end
  elseif channel_type == CHATTYPE_SCHOOL_FIGHT then
    if not is_in_school_fight() then
      chat_system_notice(gui, form, "16582")
      return 0
    end
  elseif channel_type == CHATTYPE_BATTLE_FIELD then
    if not is_in_battle_field() then
      chat_system_notice(gui, form, "16583")
      return 0
    end
  elseif channel_type == CHATTYPE_WORLD_WAR then
    if not is_in_world_war() then
      chat_system_notice(gui, form, "16581")
      return 0
    end
  elseif channel_type == CHATTYPE_NEW_SCHOOL then
    if not have_new_school_prop() then
      return 0
    end
  elseif channel_type == CHATTYPE_NEW_TERRITORY then
    if not is_in_new_territory() then
      return 0
    end
  elseif channel_type == CHATTYPE_ALL_SCHOOL and not have_all_school_prop() then
    return 0
  end
  return -1
end
function chat_system_notice(gui, form, text_id)
  gui.TextManager:Format_SetIDName("ui_chat_200")
  gui.TextManager:Format_AddParam(gui.TextManager:GetText(nx_string(text_id)))
  local chat_info = gui.TextManager:Format_GetText()
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:AddChatInfoEx(chat_info, CHATTYPE_SYSTEM, false)
  end
  clear_input(form)
end
function add_new_chat_page()
  local form = nx_value(FORM_MAIN_CHAT)
  on_btn_newpage_click(form.btn_newpage)
end
function is_chat_edit_focused()
  local gui = nx_value("gui")
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  return nx_id_equal(gui.Focused, form.chat_edit)
end
function on_chat_enter_end(focus)
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  if nx_id_equal(focus, form.chat_edit) then
    on_chat_edit_enter(form.chat_edit)
  end
end
function on_chat_edit_get_focus(self)
  local gui = nx_value("gui")
  gui.Focused = self
end
function on_chat_edit_lost_focus(self)
  local gui = nx_value("gui")
  gui.Focused = nx_null()
end
local last_chat_msg = ""
local match_times = 0
function main_form_init(self)
  self.Fixed = true
  self.no_need_motion_alpha = true
  self.chat_edit_mouse_in = 0
  self.cur_info_page = 0
  self.new_page_count = 0
  self.page_show_count = 0
  self.info_setting_count = 0
  self.show_add_page = true
  self.is_click_link = false
  self.chatlist_index = 0
  self.chatlist_playername = ""
  return 1
end
function set_tips_link_click(link_way)
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form.is_click_link = link_way
  end
end
function main_form_open(self)
  self.zonghe_tip.AutoSize = true
  self.zonghe_tip.Visible = false
  self.zonghe_tip.BackImage = "hongbao_xiao"
  local chatlist = self.chat_list
  self.sender_name = ""
  self.sender_type = -1
  self.is_open = true
  self.cur_lines = 1
  self.cur_height = self.chat_edit.Height
  self.input_old_buttom = self.group_chat_input.Top + self.group_chat_input.Height
  self.group_chat_input.old_top = self.group_chat_input.Top
  self.groupbox_transparence.Visible = false
  self.tbar_transparence.Value = 0
  self.sender_menu.Visible = false
  self.chat_edit.Text = nx_widestr("")
  self.btn_open.isshow = true
  self.chat_edit.Remember = true
  self.chat_edit.ReturnAllFormat = true
  self.chat_edit.ReturnFontFormat = false
  self.name_list_index = 0
  self.drag_size_change.Cursor = "WIN_SIZENESW"
  local gui = nx_value("gui")
  if nx_is_valid(gui) and nx_find_custom(gui, "chat_btn_ForeColor") and nx_find_custom(gui, "chat_btn_Text") and nx_find_custom(gui, "chat_type") then
    self.chat_channel_btn.Text = gui.chat_btn_Text
    self.chat_edit.chat_type = gui.chat_type
    self.chat_channel_btn.ForeColor = gui.chat_btn_ForeColor
  else
    self.chat_edit.chat_type = CHATTYPE_VISUALRANGE
  end
  init_chat_list(chatlist)
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    nx_destroy(form_main_chat_logic)
  end
  local form_main_chat_logic = nx_create("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    nx_set_value("form_main_chat", form_main_chat_logic)
    self.form_main_chat_logic = form_main_chat_logic
  end
  self.btn_channel.page_chat = chatlist
  chatlist.is_normal = SHOW_ALL
  self.btn_channel.Checked = true
  chatlist.page_btn = self.btn_channel
  nx_set_custom(self.btn_channel, "chat_enable_" .. nx_string(nx_int(chat_zonghe_set[1])), true)
  nx_set_custom(self.btn_channel, "chat_enable_" .. nx_string(nx_int(chat_zonghe_set[2])), true)
  nx_set_custom(self.btn_channel, "chat_enable_" .. nx_string(nx_int(chat_zonghe_set[6])), true)
  nx_set_custom(self.btn_channel, "chat_enable_" .. nx_string(nx_int(chat_zonghe_set[7])), true)
  chatlist:ShowKeyItems(nx_int(chat_zonghe_set[1]))
  chatlist:ShowKeyItems(nx_int(chat_zonghe_set[2]))
  chatlist:ShowKeyItems(nx_int(chat_zonghe_set[6]))
  chatlist:ShowKeyItems(nx_int(chat_zonghe_set[7]))
  chatlist:ShowKeyItems(nx_int(CHATTYPE_SYSTEM))
  self.image_change_size.Visible = false
  self.drag_size_change.Visible = false
  self.groupbox_pagebtn.Visible = false
  self.btn_newpage.Visible = false
  self.chat_toggle_check.AbsTop = self.chat_face_btn.AbsTop
  self.chat_toggle_check.AbsLeft = self.btn_bottom.AbsLeft
  self.chat_toggle_check.Visible = false
  self.group_select_channel.Visible = false
  self.groupbox_channel_set.Visible = false
  self.lbl_bottom.Visible = false
  self.group_chat_input.Visible = false
  local max_num = form_main_chat_logic:GetMaxNum()
  if max_num < 40 then
    self.chat_edit.MaxLength = 255
  else
    self.chat_edit.MaxLength = max_num
  end
  self.confirm_channel = false
  nx_execute(FORM_MAIN_PAGE, "load_page_infoEx")
  init_chat_channel_binder(self)
  change_btn_photo(self)
  self.groupbox_ctrl.Visible = false
  self.btn_open.Visible = false
  local databinder = nx_value("data_binder")
  databinder:AddTableBind("title_rec", self.btn_1, nx_current(), "refresh_title_btn")
  databinder:AddTableBind("SchoolPoseRec", self.cbtn_gaoshi, nx_current(), "refresh_cbtn_gaoshi")
  databinder:AddRolePropertyBind("GuildTitle", "string", self, nx_current(), "refresh_cbtn_gaoshi_title_btn")
  databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", self, nx_current(), "on_jhmode_changed")
  local page_btn = self.btn_channel
  nx_execute(FORM_MAIN_PAGE, "Open", page_btn)
  local main_page = nx_value(FORM_MAIN_PAGE)
  main_page.Visible = false
  nx_execute(FORM_MAIN_PAGE, "init_check_btns", page_btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    local enable = switch_manager:CheckSwitchEnable(ST_FUNCTION_NEWPACKET)
    self.btn_hongbao.Enabled = nx_boolean(enable)
  end
end
function on_jhmode_changed(self, prop_name)
  local bIsNewJHModule = is_newjhmodule()
  self.Visible = not bIsNewJHModule
  if not self.Visible then
    set_gui_focused_null()
  end
end
function show_hide_page(form, is_visible)
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupbox_pagebtn
  local table_child = groupbox:GetChildControlList()
  local count = table.getn(table_child)
  for i = 1, count do
    local child = table_child[i]
    if nx_is_valid(child) and nx_find_custom(child, "is_add") then
      child.Visible = is_visible
    end
  end
end
function refresh_cbtn_gaoshi_title_btn()
  refresh_title_btn()
  refresh_cbtn_gaoshi()
end
function refresh_title_btn()
  local form_chat_main = nx_value(nx_current())
  form_chat_main.btn_1.Enabled = false
  form_chat_main.btn_1.HintText = nx_widestr(util_text("ui_chat_tequan_1"))
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form_main_chat = nx_value("form_main_chat")
  if not nx_is_valid(form_main_chat) then
    return
  end
  local row_count = client_player:GetRecordRows("title_rec")
  for r = 0, row_count - 1 do
    local rec_title = client_player:QueryRecord("title_rec", r, 0)
    if form_main_chat:IsNeedTitlePic(rec_title) then
      form_chat_main.btn_1.Enabled = true
      form_chat_main.btn_1.HintText = nx_widestr(util_text("ui_chat_tequan_2"))
      return
    end
  end
  local guild_title = client_player:QueryProp("GuildTitle")
  local is_guild_leader = "ui_guild_pos_level1_name" == nx_string(guild_title) or "ui_guild_pos_level2_name" == nx_string(guild_title)
  if is_guild_leader then
    form_chat_main.btn_1.Enabled = true
    form_chat_main.btn_1.HintText = nx_widestr(util_text("ui_chat_tequan_2"))
  end
end
function refresh_cbtn_gaoshi()
  local form_chat_main = nx_value(nx_current())
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local row = client_player:FindRecordRow("SchoolPoseRec", 1, nx_widestr(player_name), 0)
  local is_school_leader = false
  if 0 <= row then
    local pos_id = client_player:QueryRecord("SchoolPoseRec", row, 0)
    local pos_type = pos_id % 100 / 10
    is_school_leader = 0 < pos_type and pos_type <= 3
  end
  local guild_title = client_player:QueryProp("GuildTitle")
  local is_guild_leader = "ui_guild_pos_level1_name" == nx_string(guild_title) or "ui_guild_pos_level2_name" == nx_string(guild_title)
  form_chat_main.cbtn_gaoshi.Enabled = is_guild_leader or is_school_leader
end
function init_chat_list(chat_list)
  local gui = nx_value("gui")
  chat_list.LineHeight = CHAT_LIST_HEIGHT
  new_page_chatlist_init(chat_list)
  chat_list.ViewRect = "10,0," .. chat_list.Width - 10 .. "," .. chat_list.Height - 10
  chat_list:Reset()
  if nx_is_valid(gui) and nx_find_custom(gui, "chatlist_Width") and nx_find_custom(gui, "chatlist_Height") then
    chat_list.Width = gui.chatlist_Width
    chat_list.Height = gui.chatlist_Height
  else
    chat_list.Width = 400
    chat_list.Height = 170
  end
  chat_size_change(chat_list.Width, chat_list.Height)
end
function on_btn_open_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(btn, "isshow") then
    btn.isshow = true
  end
  btn.isshow = not btn.isshow
  form.chat_group.Visible = btn.isshow
  local gui = nx_value("gui")
  form.group_select_channel.Visible = false
  form.group_chat_input.Visible = btn.isshow
  form.lbl_bg_chat_input.Visible = btn.isshow
  form.groupbox_pagebtn.Visible = btn.isshow
  form.groupbox_ctrl.Visible = btn.isshow
  gui.Focused = nx_null()
  change_btn_photo(form)
end
function change_btn_photo(form)
  if form.chat_group.Visible then
    form.btn_open.NormalImage = "gui\\common\\button\\btn_left\\btn_left3_out.png"
    form.btn_open.FocusImage = "gui\\common\\button\\btn_left\\btn_left3_on.png"
    form.btn_open.PushImage = "gui\\common\\button\\btn_left\\btn_left3_down.png"
    form.btn_open.HintText = nx_widestr(util_text("ui_liaotian_guanbi"))
  else
    form.btn_open.NormalImage = "gui\\common\\button\\btn_right\\btn_right3_out.png"
    form.btn_open.FocusImage = "gui\\common\\button\\btn_right\\btn_right3_on.png"
    form.btn_open.PushImage = "gui\\common\\button\\btn_right\\btn_right3_down.png"
    form.btn_open.HintText = nx_widestr(util_text("ui_liaotian_kaiqi"))
  end
end
function on_chat_redit_changed(chat_redit)
  local form = chat_redit.ParentForm
  local group_chat_input = form.group_chat_input
  local real_lines = chat_redit.LineNum
  local height = real_lines * (chat_redit.LineHeight + 6) + 2
  local bShow = true
  if form.cur_height ~= height then
    if height < 34 then
      height = 34
      bShow = false
    end
    form.cur_height = height
    chat_redit.Height = height
    group_chat_input.Height = height + 20
    group_chat_input.Top = form.input_old_buttom - (height + 20)
    form.lbl_chateditback.Height = group_chat_input.old_top - group_chat_input.Top + form.chat_channel_btn.Height
  end
end
function on_chat_edit_get_focus(chat_redit)
  local gui = nx_value("gui")
  gui.hyperfocused = chat_redit
end
function main_form_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelTableBind("title_rec", self.btn_1)
  databinder:DelTableBind("SchoolPoseRec", self.cbtn_gaoshi)
  databinder:DelRolePropertyBind("GuildTitle", self)
  databinder:DelRolePropertyBind("CurJHSceneConfigID", self)
  local gui = nx_value("gui")
  gui.hyperfocused = nil
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    nx_destroy(form_main_chat_logic)
  end
  nx_destroy(self)
  nx_set_value(FORM_MAIN_CHAT, nx_null())
  del_chat_channel_binder(self)
end
function add_chat_page(form, new_name)
  local pre_page_chat = form.chat_list
  local pre_page_btn = form.btn_channel
  local pre_page_scrollbar = form.scrollbar_list
  for n_index = 1, form.new_page_count do
    local page_btn = form.groupbox_pagebtn:Find("new_page_button" .. nx_string(n_index))
    if nx_is_valid(page_btn) and page_btn.need_save then
      return nil
    end
  end
  if form.new_page_count ~= 0 then
    pre_page_btn = form.groupbox_pagebtn:Find("new_page_button" .. nx_string(nx_int(form.new_page_count)))
    pre_page_chat = form.chat_group:Find("new_chatlist" .. nx_string(nx_int(form.new_page_count)))
    pre_page_scrollbar = form.chat_group:Find("new_scrollbar" .. nx_string(nx_int(form.new_page_count)))
  end
  local gui = nx_value("gui")
  local new_page_chat = gui:Create("MultiTextBox")
  local new_page_btn = gui:Create("RadioButton")
  local new_page_set_btn = gui:Create("Button")
  new_page_btn.page_chat = new_page_chat
  new_page_chat.page_btn = new_page_btn
  new_page_chat.LineHeight = CHAT_LIST_HEIGHT
  new_page_set_btn.page_btn = new_page_btn
  new_page_btn.is_add = true
  form.groupbox_pagebtn:Add(new_page_btn)
  form.chat_group:Add(new_page_chat)
  form.groupbox_pagebtn:Add(new_page_set_btn)
  local list_prop_table = nx_property_list(pre_page_chat)
  for i = 1, table.maxn(list_prop_table) do
    local value = nx_property(pre_page_chat, list_prop_table[i])
    nx_set_property(new_page_chat, list_prop_table[i], value)
  end
  new_page_chat.Top = pre_page_chat.Top
  new_page_chat.ViewRect = "10,0," .. new_page_chat.Width - 10 .. "," .. new_page_chat.Height - 10
  nx_bind_script(new_page_chat, FORM_MAIN_CHAT, "new_page_chatlist_init", new_page_chat)
  nx_callback(new_page_chat, "on_get_capture", "on_chat_list_get_capture")
  nx_callback(new_page_chat, "on_lost_capture", "on_chat_list_lost_capture")
  nx_callback(new_page_chat, "on_click_hyperlink", "on_chat_list_click_hyperlink")
  nx_callback(new_page_chat, "on_right_click_hyperlink", "on_chat_list_right_click_hyperlink")
  local button_prop_table = nx_property_list(pre_page_btn)
  for i = 1, table.maxn(button_prop_table) do
    local value = nx_property(pre_page_btn, button_prop_table[i])
    if button_prop_table[i] ~= "Checked" then
      nx_set_property(new_page_btn, button_prop_table[i], value)
    end
  end
  new_page_btn.Text = nx_widestr(new_name)
  nx_bind_script(new_page_btn, FORM_MAIN_CHAT)
  nx_callback(new_page_btn, "on_checked_changed", "on_page_checked_changed")
  nx_callback(new_page_btn, "on_get_capture", "on_cbtn_page_get_capture")
  nx_callback(new_page_btn, "on_lost_capture", "on_cbtn_page_lost_capture")
  nx_callback(new_page_btn, "on_click", "on_page_click")
  new_page_set_btn.AutoSize = true
  new_page_set_btn.NormalImage = "gui\\mainform\\chat\\arrow_out.png"
  new_page_set_btn.FocusImage = "gui\\mainform\\chat\\arrow_on.png"
  new_page_set_btn.PushImage = "gui\\mainform\\chat\\arrow_down.png"
  new_page_set_btn.TabIndex = -1
  new_page_set_btn.TabStop = false
  nx_bind_script(new_page_set_btn, FORM_MAIN_CHAT)
  nx_callback(new_page_set_btn, "on_get_capture", "on_btn_page_set_get_capture")
  nx_callback(new_page_set_btn, "on_lost_capture", "on_btn_page_set_lost_capture")
  nx_callback(new_page_set_btn, "on_click", "on_btn_page_set_click")
  new_page_btn.Visible = true
  new_page_chat.Visible = false
  new_page_btn.need_save = true
  form.new_page_count = form.new_page_count + 1
  new_page_btn.Name = "new_page_button" .. nx_string(nx_int(form.new_page_count))
  new_page_btn.DataSource = nx_string(nx_int(form.new_page_count))
  new_page_chat.Name = "new_chatlist" .. nx_string(nx_int(form.new_page_count))
  new_page_chat.DataSource = nx_string(nx_int(form.new_page_count))
  new_page_set_btn.Name = "new_page_set_button" .. nx_string(nx_int(form.new_page_count))
  new_page_set_btn.DataSource = nx_string(nx_int(form.new_page_count))
  new_page_chat.is_normal = SHOW_ALL
  local btn_newpage = form.btn_newpage
  new_page_btn.AbsLeft = pre_page_btn.AbsLeft + pre_page_btn.Width + 2
  btn_newpage.AbsLeft = new_page_btn.AbsLeft + new_page_btn.Width + 2
  new_page_set_btn.Top = form.btn_channel_set.Top + 2
  new_page_set_btn.AbsLeft = new_page_btn.AbsLeft + new_page_btn.Width - new_page_set_btn.Width - 3
  form.show_add_page = false
  local prop_name = ""
  for i = 1, table.maxn(chat_zonghe_set) do
    prop_name = "chat_enable_" .. nx_string(nx_int(chat_zonghe_set[i]))
    nx_set_custom(new_page_btn, prop_name, true)
  end
  return new_page_chat
end
function new_page_chatlist_init(chat_list)
  chat_list.cur_back_alpha = 0
  set_BlendColor(chat_list, 0)
  chat_list.NoFrame = true
  for i = 1, 20 do
    chat_list:AddHtmlText(nx_widestr("    "), nx_int(-1))
  end
end
function chat_enter_begin()
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local btn_open = form.btn_open
  if nx_find_custom(btn_open, "isshow") and not btn_open.isshow then
    return
  end
  local gui = nx_value("gui")
  gui.Focused = form.chat_edit
  form.group_chat_input.Visible = true
end
function on_chat_edit_enter(rich_inputbox)
  if not is_show_chat() then
    return
  end
  local gui = nx_value("gui")
  local form = rich_inputbox.ParentForm
  if form.confirm_channel then
    return
  end
  local chat_edit = rich_inputbox
  if not nx_is_valid(chat_edit) then
    return 0
  end
  local info = chat_edit.Text
  local valid = nx_execute("util_functions", "is_space", nx_string(info))
  valid = valid or nx_ws_length(info) == 0
  if valid then
    chat_edit.Text = nx_widestr("")
    hide_chat_edit(form)
    return
  end
  local chat_type = chat_edit.chat_type
  if chat_type == CHATTYPE_VISUALRANGE or chat_type == CHATTYPE_SCENE or chat_type == CHATTYPE_SCHOOL or chat_type == CHATTYPE_WORLD or chat_type == CHATTYPE_GOSSIP or chat_type == CHATTYPE_SCHOOL_FIGHT then
    local CheckWords = nx_value("CheckWords")
    if nx_is_valid(CheckWords) and CheckWords:CheckFilterRegion(nx_widestr(info)) then
      clear_input(form)
      return
    end
  end
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return 0
  end
  info = nx_function("ext_ws_replace", nx_widestr(info), nx_widestr("<br/>"), nx_widestr(""))
  local space_pos = nx_function("ext_ws_find", info, nx_widestr(" "))
  if -1 ~= space_pos then
    local choose_channel = nx_function("ext_ws_substr", info, 0, space_pos + 1)
    local channel_index = get_channel_index_intable(nx_string(choose_channel))
    if nil ~= channel_index then
      local form_main_chat = nx_value(FORM_MAIN_CHAT)
      local control = form_main_chat.group_select_channel:Find("btn_channel" .. nx_string(channel_index))
      if not nx_is_valid(control) then
        return 0
      end
      local channel_type = chat_channel_short_table[nx_string(choose_channel)]
      local info_len = nx_ws_length(info)
      if space_pos + 1 + nx_ws_length(nx_widestr("<br/>")) == info_len then
        if chat_check_type_notice(gui, form, channel_type) == 0 then
          return 0
        end
        if control.Enabled then
          local bIsNewJHModule = is_newjhmodule()
          if bIsNewJHModule and channel_type ~= CHATTYPE_VISUALRANGE then
            on_select_chat_channel(form_main_chat.btn_channel9)
            clear_input(form)
            return
          end
          on_select_chat_channel(control)
        end
        clear_input(form)
        return 0
      else
        local chat_str = nx_function("ext_ws_substr", info, space_pos + 1, info_len)
        if nx_number(channel_index) ~= chat_chanel_sort_ui_table[CHATTYPE_VISUALRANGE] then
          local form_main_chat_logic = nx_value("form_main_chat")
          if nx_is_valid(form_main_chat_logic) then
            chat_str = form_main_chat_logic:del_vip_face_info(nx_widestr(chat_str))
          end
        end
        if chat_check_type_notice(gui, form, channel_type) == 0 then
          return 0
        end
        if chat_check_channel(form, channel_type, control.Enabled) then
          return 0
        end
        if control.Enabled then
          nx_execute("custom_sender", "custom_chat", channel_type, chat_str)
        end
        clear_input(form)
        return 0
      end
    end
  end
  if CHATTYPE_TEAM == chat_type then
    if nx_int(get_teamtype_prop()) ~= nx_int(1) then
      chat_system_notice(gui, form, "2401")
      return 0
    end
  elseif CHATTYPE_ROW == chat_type then
    if not have_teamid_prop() then
      chat_system_notice(gui, form, "2400")
      return 0
    end
  elseif CHATTYPE_NEW_SCHOOL == chat_type then
    if not have_new_school_prop() then
      return 0
    end
  elseif CHATTYPE_NEW_TERRITORY == chat_type then
    if not is_in_new_territory() then
      return 0
    end
  elseif CHATTYPE_OUTLAND_WAR == chat_type then
    if not is_in_outlandwar() then
      return 0
    end
  elseif CHATTYPE_MATCH_SANMENG == chat_type then
    if not is_in_match_sanmeng() then
      return 0
    end
  elseif CHATTYPE_ALL_SCHOOL == chat_type then
    if not have_all_school_prop() then
      return 0
    end
  elseif CHATTYPE_GUILD_LEAGUE == chat_type then
    if not have_guild_league() then
      return 0
    end
  elseif CHATTYPE_BALANCE_WAR == chat_type then
    if not is_in_balance_war() then
      return 0
    end
  elseif CHATTYPE_WUDAO == chat_type then
    if not is_in_wudao() then
      return 0
    end
  elseif CHATTYPE_NEW_WAR_RULE_START == chat_type and not is_in_new_war_rule() then
    return 0
  end
  if chat_check_channel(form, chat_type, true) then
    return 0
  end
  if chat_type ~= CHATTYPE_VISUALRANGE then
    local form_main_chat_logic = nx_value("form_main_chat")
    if nx_is_valid(form_main_chat_logic) then
      info = form_main_chat_logic:del_vip_face_info(nx_widestr(info))
    end
  else
    local vipstatus = get_player_prop("VipStatus")
    if nx_number(vipstatus) ~= 1 then
      local form_main_chat_logic = nx_value("form_main_chat")
      if nx_is_valid(form_main_chat_logic) then
        info = form_main_chat_logic:del_vip_face_info(nx_widestr(info))
      end
    end
    if analysis_mutual_act_shortcut_key(nx_string(info)) then
      clear_input(form)
      return
    end
  end
  info = kui_hua_bao_dian_chat_change(info)
  nx_execute("custom_sender", "custom_chat", chat_type, info)
  clear_input(form)
  return 1
end
function clear_input(form)
  form.chat_edit.Text = nx_widestr("")
  on_chat_redit_changed(form.chat_edit)
  hide_chat_edit(form)
end
function hide_chat_edit(form)
  local gui = nx_value("gui")
  gui.Focused = form.chat_face_btn
  gui.Focused = nx_null()
  form.group_chat_input.Visible = false
  form.chat_edit_mouse_in = 0
end
function replace_first_shortcut_key(message)
  local count = string.len(message)
  if count == 0 then
    return ""
  end
  local i, j = 0, 0
  local face_index = 0
  while true do
    i, j = string.find(message, "/%d+ ", j + 1)
    if i == nil or j == nil then
      return ""
    end
    local str = string.sub(message, i + 1, j - 1)
    face_index = nx_number(str)
    if face_index == 0 then
      return ""
    end
    local max_num = nx_execute("form_stage_main\\form_main\\form_main_face", "get_max_icon_num")
    if 0 < face_index and face_index <= max_num then
      break
    end
  end
  local html = "<img src=\"Face" .. face_index .. "\" only=\"line\" valign=\"bottom\"/>"
  local leader_str = string.sub(message, 1, i - 1)
  local follow_str = string.sub(message, j + 1)
  return leader_str .. html .. follow_str
end
function analysis_mutual_act_shortcut_key(message)
  local count = string.len(message)
  if count == 0 then
    return false
  end
  local pos = string.find(nx_string(message), "/")
  if nx_int(pos) ~= nx_int(1) then
    return false
  end
  local str = string.sub(message, pos + 1, count - 5)
  local mutual_action = nx_value("mutual_action")
  if not nx_is_valid(mutual_action) then
    return false
  end
  local mutual_act_id = mutual_action:GetShortCutMutualActionName(str)
  log(nx_string(mutual_act_id))
  if mutual_act_id == "" or mutual_act_id == nil then
    return false
  end
  if not mutual_action:IsExist(mutual_act_id) then
    return false
  end
  if mutual_action:GetMutualType(nx_string(mutual_act_id)) == 2 and not mutual_action:CheckMutualPos() then
    return true
  end
  nx_execute("custom_sender", "custom_request_action", nx_string(mutual_act_id))
  return true
end
function kui_hua_bao_dian_chat_change(info)
  local kui_hua_bao_dian_chat = nx_value("kui_hua_bao_dian_chat")
  if not nx_is_valid(kui_hua_bao_dian_chat) then
    return info
  end
  info = kui_hua_bao_dian_chat:ReplaceChatText(info)
  info = kui_hua_bao_dian_chat:AddLinkModifyText(info)
  return info
end
function on_chat_size_change(button, newX, newY)
  button.mouse_moved = true
  local form = button.ParentForm
  local gui = nx_value("gui")
  local image_change = form.image_change_size
  form.btn_trumpet.Visible = false
  image_change.Visible = true
  local group = form.chat_group
  image_change.AbsLeft = form.chat_list.AbsLeft
  local bottom = form.chat_list.AbsTop + form.chat_list.Height
  image_change.Width = newX - image_change.AbsLeft
  local min = 283
  local max = 400
  if min > image_change.Width then
    image_change.Width = min
  end
  if max < image_change.Width then
    image_change.Width = max
  end
  image_change.Height = bottom - newY
  min = 170
  max = 400 - form.btn_channel.Height
  if min > image_change.Height then
    image_change.Height = min
  end
  if max < image_change.Height then
    image_change.Height = max
  end
  image_change.AbsTop = bottom - image_change.Height
end
function on_chat_size_change_over(button, newX, newY)
  if not nx_find_custom(button, "mouse_moved") or not button.mouse_moved then
    return
  end
  local gui = nx_value("gui")
  local form = button.ParentForm
  local image_change = form.image_change_size
  image_change.Visible = false
  local chatlist = form.chat_list
  local group_chat_input = form.group_chat_input
  local group = button.Parent
  local drag = form.drag_size_change
  local bottom = group.AbsTop + group.Height
  group.Width = image_change.Width + chatlist.Left
  group.Height = image_change.Height + form.groupbox_pagebtn.Height + 66
  chatlist.Width = image_change.Width
  chatlist.Height = image_change.Height
  group.AbsTop = bottom - group.Height
  chatlist.AbsTop = bottom - chatlist.Height
  drag.AbsLeft = chatlist.AbsLeft + chatlist.Width - drag.Width
  drag.AbsTop = chatlist.AbsTop
  chatlist.ViewRect = "10,0," .. chatlist.Width - 10 .. "," .. chatlist.Height - 10
  chatlist.AutoScroll = true
  chatlist:Reset()
  local new_page_count = form.new_page_count
  for i = 1, new_page_count do
    local new_page_list = form.chat_group:Find("new_chatlist" .. nx_string(i))
    set_chat_list_size(new_page_list, chatlist)
  end
  if form.cur_info_page == 0 then
    form.scrollbar_list.Maximum = chatlist.VerticalMaxValue
    form.scrollbar_list.Value = chatlist.VerticalValue
  else
    local new_page_list = form.chat_group:Find("new_chatlist" .. nx_string(form.cur_info_page))
    form.scrollbar_list.Maximum = new_page_list.VerticalMaxValue
    form.scrollbar_list.Value = new_page_list.VerticalValue
  end
  local puzzle_form = nx_value("form_stage_main\\puzzle_quest\\form_puzzle_quest")
  local b_trumpet_show = true
  if nx_is_valid(puzzle_form) then
    b_trumpet_show = false
  end
  init_trumpet_btn_status(false, b_trumpet_show)
  nx_execute("form_stage_main\\form_main\\form_main_trumpet", "change_form_size")
  button.mouse_moved = false
end
function set_chat_list_size(chat_list_target, chat_list)
  if nx_is_valid(chat_list_target) and nx_is_valid(chat_list) then
    chat_list_target.AbsLeft = chat_list.AbsLeft
    chat_list_target.AbsTop = chat_list.AbsTop
    chat_list_target.Width = chat_list.Width
    chat_list_target.Height = chat_list.Height
    chat_list_target.ViewRect = chat_list.ViewRect
    chat_list_target:Reset()
  end
end
function chat_size_change(chat_width, chat_height)
  local form = nx_value(FORM_MAIN_CHAT)
  local image_change = form.image_change_size
  image_change.Width = chat_width
  image_change.Height = chat_height
  image_change.Visible = false
  local chatlist = form.chat_list
  local group_chat_input = form.group_chat_input
  local group = form.chat_group
  local drag = form.drag_size_change
  local bottom = group.AbsTop + group.Height
  group.Width = image_change.Width + chatlist.Left
  group.Height = image_change.Height + form.groupbox_pagebtn.Height + 66
  chatlist.Width = image_change.Width
  chatlist.Height = image_change.Height
  group.AbsTop = bottom - group.Height
  chatlist.AbsTop = bottom - chatlist.Height
  drag.AbsLeft = chatlist.AbsLeft + chatlist.Width - drag.Width
  drag.AbsTop = chatlist.AbsTop
  init_trumpet_btn_status(true, true)
  chatlist.ViewRect = "10,0," .. chatlist.Width - 10 .. "," .. chatlist.Height - 10
  chatlist:Reset()
  local new_page_count = form.new_page_count
  for i = 1, new_page_count do
    local new_page_list = form.chat_group:Find("new_chatlist" .. nx_string(i))
    new_page_list.AbsLeft = chatlist.AbsLeft
    new_page_list.AbsTop = chatlist.AbsTop
    new_page_list.Width = chatlist.Width
    new_page_list.Height = chatlist.Height
    new_page_list.ViewRect = chatlist.ViewRect
    new_page_list:Reset()
  end
  if form.cur_info_page == 0 then
    form.scrollbar_list.Maximum = chatlist.VerticalMaxValue
    form.scrollbar_list.Value = chatlist.VerticalValue
  else
    local new_page_list = form.chat_group:Find("new_chatlist" .. nx_string(form.cur_info_page))
    form.scrollbar_list.Maximum = new_page_list.VerticalMaxValue
    form.scrollbar_list.Value = new_page_list.VerticalValue
  end
  nx_execute("form_stage_main\\form_main\\form_main_trumpet", "change_form_size")
end
function on_show_channellist(self)
  if is_newjhmodule() then
    return
  end
  local form = self.ParentForm
  local list = form.group_select_channel
  list.Visible = not list.Visible
  list.AbsLeft = self.AbsLeft
  list.AbsTop = self.AbsTop - list.Height
  local gui = nx_value("gui")
  gui.Focused = form.chat_edit
  form.btn_channel32.Visible = false
  form.btn_channel32.Enabled = false
  if have_school_prop() then
    form.btn_channel30.Visible = false
    form.btn_channel30.Enabled = false
    form.btn_channel5.Visible = true
    form.btn_channel5.Enabled = true
  else
    form.btn_channel5.Visible = true
    form.btn_channel5.Enabled = false
  end
  if have_force_prop() then
    form.btn_channel5.Visible = false
    form.btn_channel5.Enabled = false
    form.btn_channel30.Visible = true
    form.btn_channel30.Enabled = true
  else
    form.btn_channel30.Visible = false
    form.btn_channel30.Enabled = false
  end
  if have_new_school_prop() then
    form.btn_channel30.Visible = false
    form.btn_channel30.Enabled = false
    form.btn_channel5.Visible = false
    form.btn_channel5.Enabled = false
    form.btn_channel32.Visible = true
    form.btn_channel32.Enabled = true
  end
  if is_in_new_war_rule() then
    form.btn_channel22.Enabled = true
  else
    form.btn_channel22.Enabled = false
  end
  if is_in_battle_field() then
    form.btn_channel23.Enabled = true
    form.btn_channel6.Enabled = false
  else
    form.btn_channel23.Enabled = false
    form.btn_channel6.Enabled = true
  end
  if have_guild_prop() then
    form.btn_channel4.Enabled = true
  else
    form.btn_channel4.Enabled = false
  end
  if not have_teamid_prop() then
    form.btn_channel10.Enabled = false
  else
    form.btn_channel10.Enabled = true
  end
  if nx_int(get_teamtype_prop()) ~= nx_int(1) then
    form.btn_channel7.Enabled = false
  else
    form.btn_channel7.Enabled = true
    form.btn_channel10.Enabled = true
  end
  if is_in_world_war() then
    form.btn_channel25.Enabled = true
    form.btn_channel6.Enabled = false
  else
    form.btn_channel25.Enabled = false
    form.btn_channel6.Enabled = true
  end
  if is_in_new_territory() then
    form.btn_channel33.Enabled = true
  else
    form.btn_channel33.Enabled = false
  end
  if is_in_outlandwar() then
    form.btn_channel34.Enabled = true
  else
    form.btn_channel34.Enabled = false
  end
  if is_in_match_sanmeng() then
    form.btn_channel35.Enabled = true
  else
    form.btn_channel35.Enabled = false
  end
  if have_school_prop() or have_all_school_prop() then
    form.btn_channel39.Enabled = true
  else
    form.btn_channel39.Enabled = false
  end
  if have_guild_league() then
    form.btn_channel40.Enabled = true
  else
    form.btn_channel40.Enabled = false
  end
  if is_in_balance_war() then
    form.btn_channel41.Enabled = true
  else
    form.btn_channel41.Enabled = false
  end
  form.btn_channel42.Enabled = is_in_wudao()
  local btn_channel43 = list:Find("btn_channel43")
  if nx_is_valid(btn_channel43) then
    form.btn_channel43.Enabled = is_in_luandou()
  end
  for i = 2, 10 do
    if i ~= 3 then
      local btn_name = "btn_channel" .. nx_string(i)
      local btn = list:Find(btn_name)
      if nx_is_valid(btn) then
        if not nx_find_custom(btn, "backupHit") then
          btn.backupHit = btn.HintText
        end
        if btn.Enabled == false then
          btn.HintText = btn.backupHit
        else
          btn.HintText = nx_widestr("")
        end
      end
    end
  end
  return 1
end
function on_select_chat_channel(self)
  self.Parent.Visible = false
  local channelindex = nx_number(self.DataSource)
  local form = self.ParentForm
  for idname, value in pairs(chat_channel_table) do
    if value == channelindex then
      local gui = nx_value("gui")
      form.chat_channel_btn.Text = gui.TextManager:GetText(idname)
      form.chat_edit.chat_type = channelindex
      form.chat_channel_btn.ForeColor = self.ForeColor
      break
    end
  end
  local curr_page_btn = get_current_page_btn(form)
  curr_page_btn.default_channel = channelindex
end
function get_current_page_btn(form)
  if form.cur_info_page == 0 then
    return form.btn_channel
  else
    return form.groupbox_pagebtn:Find("new_page_button" .. nx_string(form.cur_info_page))
  end
end
function on_btn_hongbao_click(btn)
  nx_execute("form_stage_main\\form_hongbao\\form_hongbao_send", "open_form")
end
function on_click_btn_facepannel(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui.Focused = form.chat_edit
  local form_main_face = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_face", true, false)
  local face_form = nx_value("form_stage_main\\form_main\\form_main_face_chat")
  if nx_is_valid(face_form) then
    if form_main_face.type == 1 then
      nx_gen_event(face_form, "selectface_return", "cancel", "")
    else
      form_main_face.type = 1
      nx_execute("form_stage_main\\form_main\\form_main_face", "show_page", form_main_face, 0)
    end
  else
    local groupbox = self.Parent
    local gui = nx_value("gui")
    form_main_face.type = 1
    form_main_face.vip_face_type = 1
    nx_set_value("form_stage_main\\form_main\\form_main_face_chat", form_main_face)
    form_main_face.AbsLeft = groupbox.AbsLeft + groupbox.Width
    form_main_face.AbsTop = groupbox.AbsTop + groupbox.Height - form_main_face.Height
    form_main_face:Show()
    form_main_face.Visible = true
    while true do
      local res, html = nx_wait_event(100000000, form_main_face, "selectface_return")
      if res == "ok" then
        add_chatface_to_chatedit(html)
      else
        form_main_face:Close()
        break
      end
    end
  end
end
function on_chat_action_btn_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui.Focused = form.chat_edit
  local form_main_face = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_face", true, false, "", true)
  local face_form = nx_value("form_stage_main\\form_main\\form_main_face_chat")
  if nx_is_valid(face_form) then
    if form_main_face.type == 2 then
      nx_gen_event(face_form, "selectface_return", "cancel", "")
    else
      form_main_face.type = 2
      nx_execute("form_stage_main\\form_main\\form_main_face", "show_page", form_main_face, 0)
    end
  else
    local groupbox = self.Parent
    local gui = nx_value("gui")
    form_main_face.type = 2
    nx_set_value("form_stage_main\\form_main\\form_main_face_chat", form_main_face)
    form_main_face.AbsLeft = groupbox.AbsLeft + groupbox.Width
    form_main_face.AbsTop = groupbox.AbsTop + groupbox.Height - form_main_face.Height
    form_main_face:Show()
    form_main_face.Visible = true
    local res, html = nx_wait_event(100000000, form_main_face, "selectface_return")
    if res == "ok" then
      add_chatface_to_chatedit(html)
    end
    form_main_face:Close()
  end
end
function is_show_chat()
  local form = nx_value(FORM_MAIN_CHAT)
  if nx_is_valid(form) then
    return form.chat_group.Visible
  end
  return false
end
function on_showchat_cbtn_changed(self)
  local mainform = self.ParentForm
  mainform.chat_group.Visible = self.Checked
  local form_main_face = nx_value("form_stage_main\\form_main\\form_main_face")
  if nx_is_valid(form_main_face) and form_main_face.Visible then
    form_main_face:Close()
  end
  mainform.group_select_channel.Visible = false
  mainform.group_chat_input.Visible = self.Checked
  change_btn_photo(mainform)
end
function show_chat()
  local mainform = nx_value(FORM_MAIN_CHAT)
  mainform.chat_group.Visible = true
  local form_main_face = nx_value("form_stage_main\\form_main\\form_main_face")
  if nx_is_valid(form_main_face) and form_main_face.Visible then
    form_main_face:Close()
  end
  mainform.group_select_channel.Visible = false
  mainform.chat_toggle_check.Checked = true
  local btn_open = mainform.btn_open
  if not btn_open.isshow then
    on_btn_open_click(btn_open)
  end
  add_mousein_count(mainform)
end
function on_chatlist_gotoend(self)
  local form = self.ParentForm
  if form.cur_info_page == 0 then
    form.chat_list:GotoEnd()
    form.scrollbar_list.Value = form.scrollbar_list.Maximum
  else
    local index = form.cur_info_page
    local chat_list = form.chat_group:Find("new_chatlist" .. nx_string(index))
    chat_list:GotoEnd()
    form.scrollbar_list.Value = form.scrollbar_list.Maximum
  end
  form.lbl_bottom.Visible = false
end
function check_equip_link_num(chat_info)
  local html_num = 0
  local n_start, n_end = string.find(chat_info, "HLChatItem")
  while n_start ~= nil and n_end ~= nil do
    html_num = html_num + 1
    n_start, n_end = string.find(chat_info, "HLChatItem", n_end)
  end
  if nx_number(html_num) >= EQUIP_LINK_MAX_NUM then
    return false
  end
  return true
end
function check_face_num(chat_info)
  local face_num = 0
  local n_start, n_end = string.find(chat_info, "<img")
  while n_start ~= nil and n_end ~= nil do
    face_num = face_num + 1
    n_start, n_end = string.find(chat_info, "<img", n_end)
  end
  if nx_number(face_num) > 4 then
    return false
  end
  return true
end
function add_chatface_to_chatedit(html)
  local form_main = nx_value(FORM_MAIN_CHAT)
  local html_info = nx_string(html)
  local n_html_start, n_html_end = string.find(html_info, "<a href")
  if n_html_start ~= nil and n_html_end ~= nil then
    local cur_chat_info = nx_string(form_main.chat_edit.Text)
    if false == check_equip_link_num(cur_chat_info) then
      return
    end
  end
  local n_face_start, n_face_end = string.find(html_info, "<img")
  if n_face_start ~= nil and n_face_end ~= nil then
    local cur_chat_info = nx_string(form_main.chat_edit.Text)
    if false == check_face_num(cur_chat_info) then
      return
    end
  end
  form_main.chat_edit:Append(html, -1)
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  gui.Focused = form_main.chat_edit
  on_chat_redit_changed(form_main.chat_edit)
end
function add_item_to_chatedit(html)
  add_chatface_to_chatedit(html)
  chat_enter_begin()
end
function set_BlendColor(control, alpha)
  control.BlendColor = nx_string(nx_int(alpha)) .. ",255,255,255"
end
function set_ctrl_container_blendcolor(ctrl_container, alpha)
  if not nx_is_valid(ctrl_container) then
    return
  end
  local form_logic = nx_value("form_main_chat")
  if nx_is_valid(form_logic) and nx_find_method(form_logic, "SetGroupBoxBlendColor") then
    form_logic:SetGroupBoxBlendColor(ctrl_container, nx_int(alpha))
  end
end
function on_chat_list_get_capture(chat_list)
  nx_pause(0)
  if not nx_is_valid(chat_list) then
    return
  end
  local form = chat_list.ParentForm
  add_mousein_count(form)
  show_chat_list_and_groupbox_ctrl(form)
end
function on_chat_list_lost_capture(chat_list)
  if not nx_is_valid(chat_list) then
    return
  end
  local form = chat_list.ParentForm
  del_mousein_count(form)
  hide_chat_list_and_groupbox_ctrl(form)
end
function on_chat_edit_get_capture(chat_edit)
  local form = chat_edit.ParentForm
  add_mousein_count(form)
  show_chat_list_and_groupbox_ctrl(form)
end
function on_chat_edit_lost_capture(chat_edit)
  local form = chat_edit.ParentForm
  del_mousein_count(form)
  hide_chat_list_and_groupbox_ctrl(form)
end
function show_chat_list_and_groupbox_ctrl(form)
  nx_pause(0)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_ctrl.Visible = true
  form.btn_open.Visible = true
  add_cbtn_page_lost_capture(form)
  form.drag_size_change.Visible = true
  local chat_list = form.chat_list
  if not nx_is_valid(chat_list) then
    return
  end
  chat_list.NoFrame = false
  chat_list.is_addalpha = true
  chat_list.is_delalpha = false
  while nx_is_valid(chat_list) and chat_list.is_addalpha and chat_list.cur_back_alpha < 160 do
    chat_list.cur_back_alpha = chat_list.cur_back_alpha + 3
    set_BlendColor(chat_list, chat_list.cur_back_alpha)
    nx_pause(0)
  end
  if nx_is_valid(chat_list) and chat_list.is_addalpha then
    set_BlendColor(chat_list, 160)
  end
end
function hide_chat_list_and_groupbox_ctrl(form)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
  nx_set_value("look_item", false)
  nx_set_value("item_data", "")
  local chat_list = form.chat_list
  if not nx_is_valid(chat_list) then
    return
  end
  chat_list.NoFrame = true
  local gui = nx_value("gui")
  if not is_mouse_in_mltbox(chat_list) then
    form.groupbox_ctrl.Visible = false
    form.btn_open.Visible = false
  end
  del_cbtn_page_lost_capture(form)
  if not nx_id_equal(gui.Capture, chat_list) and form.page_show_count == 0 then
    form.drag_size_change.Visible = false
  end
  chat_list.is_addalpha = false
  chat_list.is_delalpha = true
  local min_value = form.tbar_transparence.Value
  while chat_list.is_delalpha and min_value < chat_list.cur_back_alpha do
    chat_list.cur_back_alpha = chat_list.cur_back_alpha - 3
    set_BlendColor(chat_list, chat_list.cur_back_alpha)
    nx_pause(0)
    if not nx_is_valid(chat_list) then
      return
    end
  end
  if chat_list.is_delalpha then
    set_BlendColor(chat_list, min_value)
  end
end
function on_chat_face_btn_get_capture(btn)
  local form = btn.ParentForm
  add_mousein_count(form)
end
function on_chat_face_btn_lost_capture(btn)
  local form = btn.ParentForm
  del_mousein_count(form)
end
function on_chat_action_btn_get_capture(btn)
  local form = btn.ParentForm
  add_mousein_count(form)
end
function on_chat_action_btn_lost_capture(btn)
  local form = btn.ParentForm
  del_mousein_count(form)
end
function on_cbtn_gaoshi_get_capture(btn)
  local form = btn.ParentForm
  add_mousein_count(form)
end
function on_cbtn_gaoshi_lost_capture(btn)
  local form = btn.ParentForm
  del_mousein_count(form)
end
function on_cbtn_gaoshi_checked_changed(cbtn)
  if cbtn.Checked then
    cbtn.HintText = nx_widestr(util_text("ui_chat_gonggao_true"))
  else
    cbtn.HintText = nx_widestr(util_text("ui_chat_gonggao_false"))
  end
end
function on_btn_hongbao_get_capture(btn)
  local form = btn.ParentForm
  add_mousein_count(form)
end
function on_btn_hongbao_lost_capture(btn)
  local form = btn.ParentForm
  del_mousein_count(form)
end
function add_mousein_count(form)
  if form.chat_edit_mouse_in == 0 then
    resume_chat(form)
  end
  form.chat_edit_mouse_in = form.chat_edit_mouse_in + 1
  form.group_chat_input.Visible = true
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_MAIN_CHAT, "do_close_chat_edit", form)
  end
end
function del_mousein_count(form)
  form.chat_edit_mouse_in = form.chat_edit_mouse_in - 1
  if form.chat_edit_mouse_in <= 0 and not is_any_submenu_show(form) then
    local gui = nx_value("gui")
    if not nx_id_equal(gui.Focused, form.chat_edit) then
      local timer = nx_value("timer_game")
      if nx_is_valid(timer) then
        timer:Register(500, -1, FORM_MAIN_CHAT, "do_close_chat_edit", form, -1, -1)
      end
    end
  end
end
function do_close_chat_edit(form)
  if form.chat_edit_mouse_in <= 0 then
    form.group_chat_input.Visible = false
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_MAIN_CHAT, "do_close_chat_edit", form)
  end
end
function on_chat_edit_space(chat_edit)
  local chat_string = nx_string(chat_edit.Text)
  local count = string.len(chat_string)
  if count < 5 then
    local value = chat_channel_short_table[chat_string]
    if value ~= nil then
      change_chat_channel(value)
      chat_edit.Text = nx_widestr("")
      return
    end
  elseif count < 7 then
    local gui = nx_value("gui")
    for idname, value in pairs(chat_channel_table) do
      local channel_text = nx_string(gui.TextManager:GetText(idname))
      if string.find(chat_string, "/" .. channel_text) then
        change_chat_channel(value)
        chat_edit.Text = nx_widestr("")
        return
      end
    end
  end
  local process_string = chat_string
  local replaced_string = ""
  while process_string ~= "" do
    process_string = replace_first_shortcut_key(process_string)
    if process_string ~= "" then
      replaced_string = process_string
    end
  end
  if replaced_string ~= "" then
    chat_edit.Text = nx_widestr("")
    chat_edit:Append(nx_widestr(replaced_string), -1)
  end
  return
end
function change_chat_channel(channel_value)
  if not can_change_chat_channel(channel_value) then
    return 0
  end
  local form_main_chat = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form_main_chat) then
    return 0
  end
  for i = 1, MAX_CHANNEL_IDX do
    local control = form_main_chat.group_select_channel:Find("btn_channel" .. nx_string(nx_int(i)))
    if nx_is_valid(control) and nx_number(control.DataSource) == channel_value then
      on_select_chat_channel(control)
    end
  end
end
function can_change_chat_channel(channel_value)
  if channel_value == CHATTYPE_GUILD then
    return false
  elseif channel_value == CHATTYPE_UNION then
    return false
  elseif channel_value == CHATTYPE_SCHOOL and not have_school_prop() then
    return false
  end
  return true
end
function on_btn_newpage_click(btn_newpage)
  nx_execute(FORM_MAIN_PAGE, "Open")
  local form_page = nx_value(FORM_MAIN_PAGE)
  form_page.lbl_title.Text = nx_widestr("@ui_menu_chat_new_page")
  form_page.set_system_info = false
  form_page.cbtn_1.Enabled = true
  form_page.cbtn_2.Enabled = true
  form_page.cbtn_3.Enabled = true
  form_page.cbtn_4.Enabled = true
  form_page.cbtn_5.Enabled = true
  form_page.cbtn_6.Enabled = true
  form_page.cbtn_7.Enabled = true
  form_page.cbtn_8.Enabled = true
  form_page.cbtn_9.Enabled = true
  form_page.cbtn_10.Enabled = true
  form_page.cbtn_12.Enabled = true
  form_page.cbtn_13.Enabled = true
  form_page.cbtn_14.Enabled = true
  form_page.cbtn_15.Enabled = true
  form_page.cbtn_16.Enabled = true
  form_page.cbtn_17.Enabled = true
  form_page.cbtn_18.Enabled = true
  form_page.cbtn_19.Enabled = true
end
function on_page_click(cbtn)
  if nx_int(cbtn.DataSource) == nx_int(0) then
    cbtn.ParentForm.zonghe_tip.Visible = false
  end
  if nx_find_custom(cbtn, "need_save") and cbtn.need_save then
    local index = nx_int(cbtn.DataSource)
    nx_execute(FORM_MAIN_PAGE, "set_default_page", index)
  end
  if nx_find_custom(cbtn, "default_channel") then
    local page_chat = cbtn.page_chat
    if nx_is_valid(page_chat) and nx_find_custom(page_chat, "info_tip") and nx_find_custom(page_chat, "info_cue") then
      page_chat.info_tip.Visible = false
      page_chat.info_cue.Visible = false
    end
    if nx_is_valid(page_chat) and nx_find_custom(page_chat, "info_hongbao") and nx_find_custom(page_chat, "info_cue") then
      page_chat.info_hongbao.Visible = false
      page_chat.info_cue.Visible = false
    end
    set_default_page_channel(cbtn)
  else
    on_select_chat_channel(cbtn.ParentForm.btn_channel9)
  end
end
function on_page_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local index = nx_int(cbtn.DataSource)
  local list
  if index == nx_int(0) then
    list = form.chat_list
  else
    list = form.chat_group:Find("new_chatlist" .. nx_string(nx_int(index)))
  end
  if not nx_is_valid(list) then
    return
  end
  local game_config_info = nx_value("game_config_info")
  local key = util_get_property_key(game_config_info, "is_auto_get_hongbao_place", 1)
  if cbtn.Checked then
    list.Visible = true
    form.cur_info_page = index
    form.scrollbar_list.Maximum = list.VerticalMaxValue
    if nx_int(key) == nx_int(1) then
      form.scrollbar_list.Value = list.VerticalMaxValue
    else
      for i = list.ItemCount - 1, 0, -1 do
        local text = nx_widestr(form.chat_list:GetHtmlItemText(i))
        local zonghe_tip = form.zonghe_tip
        local page_chat = cbtn.page_chat
        if nx_is_valid(page_chat) and nx_find_custom(page_chat, "info_hongbao") and nx_find_custom(page_chat, "info_cue") then
          if string.find(nx_string(text), "a href=\"newpacket") and page_chat.info_hongbao.Visible == true then
            form.scrollbar_list.Value = i
            break
          else
            form.scrollbar_list.Value = list.VerticalMaxValue
          end
        end
        if string.find(nx_string(text), "a href=\"newpacket") and zonghe_tip.Visible then
          form.scrollbar_list.Value = i
          break
        else
          form.scrollbar_list.Value = list.VerticalMaxValue
        end
      end
    end
    show_info_type_btn_change(form, cbtn.page_chat.is_normal)
  else
    list.Visible = false
  end
end
function del_cbtn_page_lost_capture(form)
  form.page_show_count = form.page_show_count - 1
  if form.page_show_count < 0 then
    form.page_show_count = 0
  end
  if form.page_show_count == 0 and not is_any_submenu_show(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(100, -1, FORM_MAIN_CHAT, "do_close_page_group", form, -1, -1)
    end
  end
end
function add_cbtn_page_lost_capture(form)
  if form.page_show_count == 0 then
    resume_chat(form)
  end
  form.page_show_count = form.page_show_count + 1
  form.groupbox_pagebtn.Visible = true
  form.btn_newpage.Visible = form.show_add_page
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_MAIN_CHAT, "do_close_page_group", form)
  end
end
function on_cbtn_page_lost_capture(cbtn_page)
  local form = cbtn_page.ParentForm
  del_cbtn_page_lost_capture(form)
end
function on_btn_newpage_get_capture(btn_newpage)
  local form = btn_newpage.ParentForm
  add_cbtn_page_lost_capture(form)
end
function on_btn_newpage_lost_capture(btn_newpage)
  local form = btn_newpage.ParentForm
  del_cbtn_page_lost_capture(form)
end
function do_close_page_group(form)
  if form.page_show_count <= 0 then
    form.groupbox_pagebtn.Visible = false
    form.btn_newpage.Visible = false
    form.drag_size_change.Visible = false
    form.groupbox_channel_set.Visible = false
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_MAIN_CHAT, "do_close_page_group", form)
  end
end
function on_cbtn_page_get_capture(cbtn_page)
  local form = cbtn_page.ParentForm
  form.page_show_count = form.page_show_count + 1
end
function change_form_size()
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local menu_game = nx_value("menu_game")
  if nx_is_valid(menu_game) and menu_game.Visible and nx_find_custom(menu_game, "type") then
    local type = menu_game.type
    if type == "chat" then
      menu_game.AbsLeft = form.btn_channel.AbsLeft + form.btn_channel.Width / 2
      menu_game.AbsTop = form.btn_channel.AbsTop + form.btn_channel.Height / 2
    end
  end
  local groupbox = form.group_chat_input
  local form_main_face = nx_value("form_stage_main\\form_main\\form_main_face_chat")
  if nx_is_valid(form_main_face) then
    form_main_face.AbsLeft = groupbox.AbsLeft + groupbox.Width
    form_main_face.AbsTop = groupbox.AbsTop + groupbox.Height - form_main_face.Height
  end
end
function is_any_submenu_show(form)
  local menu_game = nx_value("menu_game")
  if nx_is_valid(menu_game) and menu_game.Visible then
    return true
  end
  if form.group_select_channel.Visible then
    return true
  end
  return false
end
function on_scrollbar_list_value_changed(scrollbar)
  local form = scrollbar.ParentForm
  local chat_list = form.chat_list
  if form.cur_info_page ~= 0 then
    chat_list = form.chat_group:Find("new_chatlist" .. nx_string(form.cur_info_page))
  end
  chat_list.VerticalValue = scrollbar.Value
  if math.abs(scrollbar.Maximum - scrollbar.Value) < 2 then
    chat_list.AutoScroll = true
    form.lbl_bottom.Visible = false
    copy_tmp_chat_list_to_normal()
  else
    chat_list.AutoScroll = false
  end
end
function copy_tmp_chat_list_to_normal()
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local tmp_chat_list = form:Find("tmp_chat_list")
  if not nx_is_valid(tmp_chat_list) then
    return
  end
  local chat_list = form.chat_list
  local tmp_len = tmp_chat_list.ItemCount
  for i = 1, tmp_len do
    local info = tmp_chat_list:GetHtmlItemText(0)
    local chat_type = tmp_chat_list:GetItemKeyByIndex(0)
    chat_list.TextColor = chat_channel_clolor_table[chat_type]
    if SHOW_ALL == chat_list.is_normal then
      chat_list:AddHtmlText(info, nx_int(chat_type))
    elseif SHOW_GOODS == chat_list.is_normal then
      form.form_main_chat_logic:AddChatInfo(chat_list, info, nx_int(chat_type))
    else
      form.form_main_chat_logic:AddChatInfoNoGoods(chat_list, info, nx_int(chat_type))
    end
    if chat_list.ItemCount >= MAX_INFO_CNT then
      chat_list:DelHtmlItem(0)
    end
    for j = 1, form.new_page_count do
      local new_list = form.chat_group:Find("new_chatlist" .. nx_string(j))
      local tmp_page_btn = new_list.page_btn
      local tmp_chat_enable = "chat_enable_" .. nx_string(chat_type)
      if nx_find_custom(tmp_page_btn, tmp_chat_enable) then
        if SHOW_ALL == new_list.is_normal then
          new_list:AddHtmlText(info, nx_int(chat_type))
        elseif SHOW_GOODS == new_list.is_normal then
          form.form_main_chat_logic:AddChatInfo(new_list, info, nx_int(chat_type))
        else
          form.form_main_chat_logic:AddChatInfoNoGoods(new_list, info, nx_int(chat_type))
        end
        if new_list.ItemCount >= MAX_INFO_CNT then
          new_list:DelHtmlItem(0)
        end
      end
    end
    tmp_chat_list:DelHtmlItem(0)
  end
  local cur_chat_list = form.chat_list
  if form.cur_info_page ~= 0 then
    cur_chat_list = form.chat_group:Find("new_chatlist" .. nx_string(form.cur_info_page))
  end
  form.scrollbar_list.Maximum = cur_chat_list.VerticalMaxValue
  form.scrollbar_list.Value = cur_chat_list.VerticalMaxValue
  if nx_is_valid(tmp_chat_list) and tmp_chat_list.ItemCount <= 0 then
    local gui = nx_value("gui")
    form:Remove(tmp_chat_list)
    gui:Delete(tmp_chat_list)
  end
end
function show_hyper_link_iteminfo(item_info, uniqueid)
  if not nx_value("look_item") then
    return
  end
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local xmldoc = nx_create("XmlDocument")
  if not xmldoc:ParseXmlData(item_info, 1) then
    nx_destroy(xmldoc)
    return
  end
  local xmlroot = xmldoc.RootElement
  local array_data = nx_call("util_gui", "get_arraylist", "form_main_chat:show_hyper_link_iteminfo")
  array_data:ClearChild()
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    nx_set_custom(array_data, name, value)
  end
  local xml_element_record = xmlroot:GetChildByIndex(1)
  if nx_is_valid(xml_element_record) then
    local record_num = xml_element_record:GetChildCount()
    local str_record_group = ""
    for i = 0, record_num - 1 do
      local child = xml_element_record:GetChildByIndex(i)
      local record_name = child:QueryAttr("name")
      local record_rows = child:QueryAttr("rows")
      local sz_child_info = nx_string(record_name) .. "," .. nx_string(record_rows)
      local record_prop_num = 0
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        record_prop_num = nx_int(record_prop_num) + (nx_int(child_child:GetAttrCount()) - 1)
      end
      sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(record_prop_num / record_rows)
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        local record_prop_num = child_child:GetAttrCount()
        for record_index = 1, record_prop_num - 1 do
          local prop_name = child_child:GetAttrName(record_index)
          local prop_value = child_child:GetAttrValue(record_index)
          sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(prop_value)
        end
      end
      if str_record_group == "" then
        str_record_group = nx_string(sz_child_info)
      else
        str_record_group = nx_string(str_record_group) .. "," .. nx_string(sz_child_info)
      end
    end
    if nx_int(record_num) > nx_int(0) then
      array_data.item_rec_data_info = str_record_group
    end
  end
  array_data.is_chat_link = true
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  if form.is_click_link then
    nx_execute("tips_game", "show_link_good_tips", array_data, form.chat_list.Left + form.chat_list.Width, y - 320, 32, 32, form, uniqueid)
  else
    nx_execute("tips_game", "show_goods_tip", array_data, x + 32, y - 20, 32, 32, form)
  end
  nx_destroy(array_data)
  nx_destroy(xmldoc)
end
function get_arraylist_by_parse_xmldata(item_info, array_data)
  local xmldoc = nx_create("XmlDocument")
  if not xmldoc:ParseXmlData(item_info, 1) then
    nx_destroy(xmldoc)
    return nil
  end
  local xmlroot = xmldoc.RootElement
  array_data:ClearChild()
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return nil
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    nx_set_custom(array_data, name, value)
  end
  local xml_element_record = xmlroot:GetChildByIndex(1)
  if nx_is_valid(xml_element_record) then
    local record_num = xml_element_record:GetChildCount()
    local str_record_group = ""
    for i = 0, record_num - 1 do
      local child = xml_element_record:GetChildByIndex(i)
      local record_name = child:QueryAttr("name")
      local record_rows = child:QueryAttr("rows")
      local sz_child_info = nx_string(record_name) .. "," .. nx_string(record_rows)
      local record_prop_num = 0
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        record_prop_num = nx_int(record_prop_num) + (nx_int(child_child:GetAttrCount()) - 1)
      end
      sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(record_prop_num / record_rows)
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        local record_prop_num = child_child:GetAttrCount()
        for record_index = 1, record_prop_num - 1 do
          local prop_name = child_child:GetAttrName(record_index)
          local prop_value = child_child:GetAttrValue(record_index)
          sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(prop_value)
        end
      end
      if str_record_group == "" then
        str_record_group = nx_string(sz_child_info)
      else
        str_record_group = nx_string(str_record_group) .. "," .. nx_string(sz_child_info)
      end
    end
    if nx_int(record_num) > nx_int(0) then
      array_data.item_rec_data_info = str_record_group
    end
  end
  array_data.is_chat_link = true
  nx_destroy(xmldoc)
  return array_data
end
function hide_menu(form)
  if nx_is_valid(form) then
    form.group_select_channel.Visible = false
    form.sender_menu.Visible = false
  end
end
function right_down()
  local form = nx_value(FORM_MAIN_CHAT)
  hide_menu(form)
end
function left_down()
  local form = nx_value(FORM_MAIN_CHAT)
  hide_menu(form)
end
function have_school_prop()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("School") then
    local school = client_player:QueryProp("School")
    if school ~= "" then
      return true
    end
  end
  return false
end
function have_force_prop()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("Force") then
    local force = client_player:QueryProp("Force")
    if force ~= "" then
      return true
    end
  end
  return false
end
function have_guild_prop()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("GuildName") then
    local guild = client_player:QueryProp("GuildName")
    if guild ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function get_teamtype_prop()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("TeamType") then
    return nx_int(client_player:QueryProp("TeamType"))
  end
  return nx_int(-1)
end
function have_teamid_prop()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("TeamID") then
    local team_id = client_player:QueryProp("TeamID")
    if 0 < team_id then
      return true
    end
  end
  return false
end
function on_chat_edit_ctrl_keydown(form, key)
  local Key_Str = ""
  if nx_int(key) == nx_int(83) then
    channel_type = CHATTYPE_VISUALRANGE
    Key_Str = "S"
  elseif nx_int(key) == nx_int(80) then
    channel_type = CHATTYPE_TEAM
    Key_Str = "P"
  elseif nx_int(key) == nx_int(71) then
    channel_type = CHATTYPE_GUILD
    Key_Str = "G"
  elseif nx_int(key) == nx_int(87) then
    channel_type = CHATTYPE_WORLD
    Key_Str = "W"
  else
    return
  end
  change_chat_channel(channel_type)
  chat_enter_begin()
end
function on_btn_transparence_click(btn)
  local form = btn.ParentForm
  if form.groupbox_transparence.Visible == false then
    form.groupbox_transparence.Visible = true
  else
    form.groupbox_transparence.Visible = false
  end
end
function on_tbar_transparence_drag_leave(self)
  local group_box = self.Parent
  group_box.Visible = false
end
function on_tbar_transparence_value_changed(self)
  local lbl = self.ParentForm.lbl_p
  local chat_list = self.ParentForm.chat_list
  lbl.Top = self.Top
  lbl.Left = self.Left
  local length = self.TrackButton.Left
  if 5 < length then
    length = length + 3
  end
  lbl.Width = length
  local num = nx_int(self.Value / 160 * 100)
  if num == nx_int(0) then
    lbl.Visible = false
  else
    lbl.Visible = true
  end
  self.ParentForm.lbl_num.Text = nx_widestr(nx_string(num) .. nx_string("%"))
  if self.Value >= 0 and self.Value <= 160 then
    chat_list.cur_back_alpha = self.Value
    set_BlendColor(chat_list, chat_list.cur_back_alpha)
    for i = 1, self.ParentForm.new_page_count do
      local dy_chat_list = self.ParentForm.chat_group:Find("new_chatlist" .. nx_string(i))
      if nx_is_valid(dy_chat_list) then
        dy_chat_list.cur_back_alpha = self.Value
        set_BlendColor(dy_chat_list, dy_chat_list.cur_back_alpha)
      end
    end
  end
end
function on_chat_list_click_hyperlink(self, itemindex, linkdata)
  local form = self.ParentForm
  if form.sender_menu.Visible == true then
    form.sender_menu.Visible = false
    return
  end
  linkdata = nx_widestr(linkdata)
  local param_table = nx_function("ext_split_wstring", linkdata, nx_widestr(","))
  local count = table.maxn(param_table)
  if count <= 0 then
    return
  end
  if nx_ws_equal(nx_widestr(param_table[1]), nx_widestr("chat")) then
    local game_client = nx_value("game_client")
    local player = game_client:GetPlayer()
    local player_name = player:QueryProp("Name")
    if not nx_ws_equal(nx_widestr(param_table[2]), nx_widestr(player_name)) then
      nx_execute("custom_sender", "custom_request_chat", nx_widestr(param_table[2]))
    end
  end
  if nx_ws_equal(nx_widestr(param_table[1]), nx_widestr("channel")) then
    local channel = nx_number(param_table[2])
    if channel == 3 then
      form.sender_name = nx_widestr(param_table[3])
      on_btn_secret_chat_click(form.btn_secret_chat)
    else
      change_chat_channel(channel)
    end
    chat_enter_begin()
  end
end
function RePutMenu(form)
  local btns = {
    form.btn_add_chat,
    form.btn_friend_request,
    form.btn_add_attention,
    form.btn_add_blacklist,
    form.btn_add_blacklist_native,
    form.btn_team_request,
    form.btn_add_invite_guild,
    form.btn_search_guild,
    form.btn_send_mail,
    form.btn_impeach,
    form.btn_silence,
    form.btn_wudao_invite,
    form.btn_wudao_join_team
  }
  local btn_height = 20
  local margin_top = 4
  local margin_middle = 1
  local margin_bottom = 4
  local n = table.getn(btns)
  local menu_total_height = 0
  local visible_btn_count = 0
  for i = 1, n do
    local btn = btns[i]
    if btn.Visible then
      btn.Top = margin_top + visible_btn_count * (btn_height + margin_middle)
      menu_total_height = btn.Top + btn_height + margin_bottom
      visible_btn_count = visible_btn_count + 1
    end
  end
  form.sender_menu.Height = menu_total_height
end
function on_chat_list_right_click_hyperlink(self, itemindex, linkdata)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local form = self.ParentForm
  if form.sender_menu.Visible == true then
    form.sender_menu.Visible = false
    return
  end
  linkdata = nx_widestr(linkdata)
  local param_table = nx_function("ext_split_wstring", linkdata, nx_widestr(","))
  local count = table.maxn(param_table)
  if count < 2 then
    return
  end
  local chat_type = nx_int(0)
  if 3 < count then
    chat_type = nx_int(param_table[3])
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local player_name = player:QueryProp("Name")
  local gui = nx_value("gui")
  local b_default = nx_ws_equal(nx_widestr(param_table[2]), gui.TextManager:GetText("ui_chat_default_name"))
  local b_player_name = nx_ws_equal(nx_widestr(param_table[2]), player_name)
  if nx_ws_equal(nx_widestr(param_table[1]), nx_widestr("chat")) and not b_default and not b_player_name then
    local playername = nx_widestr(param_table[2])
    local x, y = gui:GetCursorPosition()
    form.sender_menu.AbsLeft = x + 10
    form.sender_menu.AbsTop = y - 80
    if form.btn_silence.Visible then
      form.sender_menu.Height = form.sender_menu.Height - 22
      form.btn_silence.Visible = false
    end
    form.sender_menu.Visible = true
    form.sender_name = playername
    form.sender_type = self:GetItemKeyByIndex(nx_int(itemindex))
    if need_show_silence(form.sender_type) then
      form.sender_menu.Height = form.sender_menu.Height + 22
      form.btn_silence.Visible = true
    end
    form.btn_wudao_invite.Visible = false
    form.btn_wudao_join_team.Visible = false
    if IsInWuDaoScene() then
      if IsWuDaoWarTeamCaptain() then
        form.btn_wudao_invite.Visible = true
      end
      if chat_type == nx_int(CHATTYPE_WUDAO) then
        form.target_wudao_team_name = nx_widestr(param_table[4])
        form.target_is_wudao_team_leader = nx_int(param_table[5])
        if form.target_wudao_team_name ~= nx_widestr("") and not IsInWuDaoWarTeam() then
          form.btn_wudao_join_team.Visible = true
        end
      end
    end
    RePutMenu(form)
    if form.sender_menu.Top + form.sender_menu.Height > form.Height then
      form.sender_menu.Top = form.Height - form.sender_menu.Height
    end
    form.chatlist_index = itemindex
    form.chatlist_playername = nx_widestr(param_table[2])
  elseif nx_ws_equal(nx_widestr(param_table[1]), nx_widestr("item")) then
    local linkindex = self.MouseInHyperLink
    local hyper_text = self:GetHyperLinkText(itemindex, linkindex)
    local form_main_chat_logic = nx_value("form_main_chat")
    if not nx_is_valid(form_main_chat_logic) then
      return
    end
    if nx_string(param_table[4]) == "" then
      return
    end
    local item_config_id = nx_string(param_table[4])
    local item_name = form_main_chat_logic:TrimItemName(hyper_text)
    local switch_manager = nx_value("SwitchManager")
    if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_AUCTION_COMPANY) then
      local gui = nx_value("gui")
      local menu_game = nx_value("menu_game")
      if not nx_is_valid(menu_game) then
        menu_game = gui:Create("Menu")
        nx_bind_script(menu_game, "menu_game", "menu_game_init")
        nx_set_value("menu_game", menu_game)
      end
      nx_execute("menu_game", "menu_game_reset", "chat_item", "chat_item")
      nx_execute("menu_game", "menu_recompose", menu_game)
      menu_game.config = item_config_id
      menu_game.item_name = item_name
      local curx, cury = gui:GetCursorPosition()
      gui:TrackPopupMenu(menu_game, curx, cury)
    else
      nx_execute("form_stage_main\\form_market\\form_market", "auto_show_hide_form_market", true)
      local form_market = nx_value("form_stage_main\\form_market\\form_market")
      if not nx_is_valid(form_market) then
        return
      end
      local ItemQuery = nx_value("ItemQuery")
      if not nx_is_valid(ItemQuery) then
        return
      end
      local gui = nx_value("gui")
      gui.Focused = form_market.ipt_search_key
      form_market.tree_market.SelectNode = form_market.tree_market.RootNode:FindNode(util_text("ui_market_node_" .. "1"))
      form_market.ipt_search_key.Text = nx_widestr(item_name)
      form_market.combobox_itemname.DroppedDown = false
      form_market.cur_page = 1
      form_market.search_type = 1
      form_market.item_type = 0
      form_market.combobox_itemname.config = nx_string(item_config_id)
      form_market.btn_search_key.Enabled = true
      local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config_id), nx_string("ItemType"))
      local color_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config_id), nx_string("ColorLevel"))
      local SUB_CLIENT_ITEM_SELECT_CONFIGID = 21
      nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_CONFIGID, nx_int(item_type), nx_int(color_level), nx_string(item_config_id))
    end
  end
end
function on_btn_team_request_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_team_invite", nx_widestr(form.sender_name))
end
function on_btn_friend_request_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", nx_widestr(form.sender_name))
end
function on_btn_add_attention_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", nx_widestr(form.sender_name))
end
function on_btn_add_chat_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.sender_name))
end
function on_btn_add_blacklist_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_filter", nx_widestr(form.sender_name))
end
function on_btn_add_blacklist_native_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  local karmamgr = nx_value("Karma")
  if nx_is_valid(karmamgr) then
    karmamgr:AddFilterNative(nx_widestr(form.sender_name))
  end
end
function on_btn_silence_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat_silence")
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = util_format_string("ui_schoolvoice_07", nx_widestr(form.sender_name))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" == res then
    nx_execute("custom_sender", "custom_request_silence", nx_int(form.sender_type), nx_widestr(form.sender_name))
  end
end
function need_show_silence(chat_type)
  if CHATTYPE_SCHOOL ~= chat_type and CHATTYPE_SCHOOL_FIGHT ~= chat_type then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_commandleader = 1 == client_player:QueryProp("SchoolFightCommandLeader")
  local player_name = client_player:QueryProp("Name")
  local row = client_player:FindRecordRow("SchoolPoseRec", 1, nx_widestr(player_name), 0)
  local is_school_leader = false
  if 0 <= row then
    local pos_id = client_player:QueryRecord("SchoolPoseRec", row, 0)
    local pos_type = pos_id % 100 / 10
    is_school_leader = nx_int(1) == nx_int(pos_type)
  end
  return is_commandleader or is_school_leader
end
local repeat_items = {}
function del_repeat_item(name)
  repeat_items[name] = nil
end
function on_btn_send_click(btn)
  local form = btn.ParentForm
  on_chat_edit_enter(form.chat_edit)
end
function set_gui_focused_null()
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    gui.Focused = form.chat_channel_btn
    gui.Focused = nx_null()
  end
end
function on_lbl_bg_get_capture(lbl)
  local form = lbl.ParentForm
  add_cbtn_page_lost_capture(form)
end
function on_lbl_bg_lost_capture(lbl)
  local form = lbl.ParentForm
  del_cbtn_page_lost_capture(form)
end
function on_lbl_bg_chat_input_get_capture(self)
  local form = self.ParentForm
  add_mousein_count(form)
  show_chat_list_and_groupbox_ctrl(form)
end
function on_lbl_bg_chat_input_lost_capture(self)
  local form = self.ParentForm
  del_mousein_count(form)
  hide_chat_list_and_groupbox_ctrl(form)
end
function on_btn_add_invite_guild_click(btn)
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local self_guild = player_obj:QueryProp("GuildName")
  if nx_widestr(self_guild) == nx_widestr("") and nx_widestr(self_guild) == nx_widestr("0") then
    return
  end
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_guild_invite_member", nx_widestr(form.sender_name))
end
function on_btn_search_guild_click(btn)
  local form = btn.ParentForm
  local sname = form.sender_name
  form.sender_menu.Visible = false
  nx_execute("custom_sender", "custom_send_get_player_game_info", sname)
end
function on_btn_channel_set_click(btn)
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local btn_channel = form.btn_channel
  nx_execute(FORM_MAIN_PAGE, "Open", btn_channel)
  local form_page = nx_value(FORM_MAIN_PAGE)
  form_page.lbl_title.Text = form.btn_channel.Text
  form_page.set_system_info = true
  form_page.cbtn_1.Enabled = true
  form_page.cbtn_2.Enabled = true
  form_page.cbtn_3.Enabled = true
  form_page.cbtn_4.Enabled = true
  form_page.cbtn_5.Enabled = true
  form_page.cbtn_6.Enabled = true
  form_page.cbtn_7.Enabled = true
  form_page.cbtn_8.Enabled = true
  form_page.cbtn_9.Enabled = true
  form_page.cbtn_10.Enabled = true
  form_page.cbtn_12.Enabled = true
  form_page.cbtn_13.Enabled = true
  form_page.cbtn_14.Enabled = true
  form_page.cbtn_15.Enabled = true
  form_page.cbtn_16.Enabled = true
  form_page.cbtn_17.Enabled = true
  form_page.cbtn_18.Enabled = true
  form_page.cbtn_19.Enabled = true
end
function on_btn_trumpet_click(self)
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if nx_is_valid(form) then
    form.Visible = not form.Visible
    if form.Visible then
      nx_execute("form_stage_main\\form_main\\form_laba_info", "init", form)
    end
  end
end
function on_btn_page_set_click(btn)
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_channel_set = form.groupbox_channel_set
  groupbox_channel_set.page_btn = btn.page_btn
  if groupbox_channel_set.AbsLeft ~= btn.AbsLeft then
    groupbox_channel_set.AbsLeft = btn.AbsLeft
    groupbox_channel_set.AbsTop = btn.AbsTop - groupbox_channel_set.Height - 5
    groupbox_channel_set.Visible = true
  else
    groupbox_channel_set.AbsTop = btn.AbsTop - groupbox_channel_set.Height - 5
    groupbox_channel_set.Visible = not groupbox_channel_set.Visible
  end
  if nx_find_custom(groupbox_channel_set.page_btn, "auto_page") and groupbox_channel_set.page_btn.auto_page == true then
    form.btn_channel_set_p.Enabled = false
  else
    form.btn_channel_set_p.Enabled = true
  end
  form.btn_channel_del_p.Enabled = true
  if nx_find_custom(groupbox_channel_set.page_btn, "can_delete") then
    form.btn_channel_del_p.Enabled = groupbox_channel_set.page_btn.can_delete
  end
  nx_execute(FORM_MAIN_PAGE, "Open", btn.page_btn)
  local form_page = nx_value(FORM_MAIN_PAGE)
  form_page.Visible = false
  if not nx_is_valid(form_page) then
    return
  end
end
function on_btn_channel_set_p_click(btn)
  local page_btn = btn.Parent.page_btn
  nx_execute(FORM_MAIN_PAGE, "Open", page_btn)
  btn.Parent.Visible = false
  local form_page = nx_value(FORM_MAIN_PAGE)
  form_page.set_system_info = false
  local form = nx_value(FORM_MAIN_CHAT)
  if nx_is_valid(form) and nx_id_equal(page_btn, form.btn_channel) then
    form_page.set_system_info = true
  end
end
function on_btn_channel_del_p_click(btn)
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local page_btn = btn.Parent.page_btn
  if nx_is_valid(page_btn) then
    del_chat_page(form, page_btn.Text)
    btn.Parent.Visible = false
  end
end
function init_chat_channel_binder(form)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(data_binder) then
    return
  end
  data_binder:AddRolePropertyBind("School", "string", form.btn_channel, nx_current(), "on_channel_school")
  data_binder:AddRolePropertyBind("LeaveSchoolType", "string", form.btn_channel, nx_current(), "on_channel_school")
  data_binder:AddRolePropertyBind("LastSchool", "string", form.btn_channel, nx_current(), "on_channel_school")
  data_binder:AddRolePropertyBind("SchoolMark", "string", form.btn_channel, nx_current(), "on_channel_school")
  data_binder:AddRolePropertyBind("NewSchool", "string", form.btn_channel, nx_current(), "on_channel_school")
  data_binder:AddRolePropertyBind("GuildName", "string", form.btn_channel, nx_current(), "on_channel_guild")
  data_binder:AddRolePropertyBind("TeamID", "int", form.btn_channel, nx_current(), "on_channel_team")
  data_binder:AddRolePropertyBind("IsInSchoolFight", "int", form.btn_channel, nx_current(), "on_channel_SchoolFight")
  data_binder:AddRolePropertyBind("BattlefieldState", "int", form.btn_channel, nx_current(), "on_channel_Battlefield")
  data_binder:AddRolePropertyBind("WorldWarForce", "int", form.btn_channel, nx_current(), "on_channel_world_war")
  data_binder:AddRolePropertyBind("Force", "string", form.btn_channel, nx_current(), "on_channel_force")
  data_binder:AddRolePropertyBind("NewSchool", "string", form.btn_channel, nx_current(), "on_channel_newschool")
  data_binder:AddRolePropertyBind("LeaveSchoolType", "string", form.btn_channel, nx_current(), "on_channel_newschool")
  data_binder:AddRolePropertyBind("LastSchool", "string", form.btn_channel, nx_current(), "on_channel_newschool")
  data_binder:AddRolePropertyBind("SchoolMark", "string", form.btn_channel, nx_current(), "on_channel_newschool")
  data_binder:AddRolePropertyBind("NewSchool", "string", form.btn_channel, nx_current(), "on_channel_newschool")
  data_binder:AddRolePropertyBind("NewTerritoryStatus", "int", form.btn_channel, nx_current(), "on_channel_newterritory")
  data_binder:AddRolePropertyBind("InteractStatus", "int64", form.btn_channel, nx_current(), "on_channel_outlandwar")
  data_binder:AddRolePropertyBind("IsSanmeng", "int", form.btn_channel, nx_current(), "on_channel_match_sanmeng")
  data_binder:AddRolePropertyBind("InteractStatus", "int64", form.btn_channel, nx_current(), "on_channel_balance_war")
  data_binder:AddRolePropertyBind("WuDaoPlayerState", "int", form.btn_channel, nx_current(), "on_channel_wudao")
  data_binder:AddRolePropertyBind("LuanDouPlayerState", "int", form.btn_channel, nx_current(), "on_channel_luandou")
  data_binder:AddRolePropertyBind("IsNewWarRule", "int", form.btn_channel, nx_current(), "on_channel_new_war_rule")
end
function del_chat_channel_binder(form)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(date_binder) then
    return
  end
  data_binder:DelRolePropertyBind("TeamID", form.btn_channel)
  data_binder:DelRolePropertyBind("GuildName", form.btn_channel)
  data_binder:DelRolePropertyBind("School", form.btn_channel)
  data_binder:DelRolePropertyBind("IsInSchoolFight", form.btn_channel)
  data_binder:DelRolePropertyBind("BattlefieldState", form.btn_channel)
  data_binder:DelRolePropertyBind("WorldWarForce", form.btn_channel)
  data_binder:DelRolePropertyBind("NewSchool", form.btn_channel)
  data_binder:DelRolePropertyBind("NewTerritoryStatus", form.btn_channel)
  data_binder:DelRolePropertyBind("InteractStatus", form.btn_channel)
  data_binder:DelRolePropertyBind("IsSanmeng", form.btn_channel)
  data_binder:DelRolePropertyBind("InteractStatus", form.btn_channel)
  data_binder:DelRolePropertyBind("WuDaoPlayerState", form.btn_channel)
  data_binder:DelRolePropertyBind("LuanDouPlayerState", form.btn_channel)
  data_binder:DelRolePropertyBind("IsNewWarRule", form.btn_channel)
end
function on_channel_Battlefield()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_battle = gui.TextManager:GetText("ui_chat_channel_23")
  if is_in_battle_field() then
    add_auto_chat_page(form, channel_battle, CHATTYPE_BATTLE_FIELD, CHATTYPE_BATTLE_FIELD)
  else
    del_chat_page(form, channel_battle)
  end
end
function on_channel_world_war()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_world_war = gui.TextManager:GetText("ui_chat_channel_25")
  if is_in_world_war() then
    add_auto_chat_page(form, channel_world_war, CHATTYPE_WORLD_WAR, CHATTYPE_WORLD_WAR)
  else
    del_chat_page(form, channel_world_war)
  end
end
function is_in_world_war()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local WorldWarForce = client_player:QueryProp("WorldWarForce")
  return 0 < WorldWarForce
end
function is_in_new_territory()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local flag = client_player:QueryProp("NewTerritoryStatus")
  if nx_int(flag) == nx_int(1) then
    return true
  end
  return false
end
function is_in_outlandwar()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_OUTLAND_WAR) == PIS_IN_GAME then
    return true
  end
  return false
end
function is_in_battle_field()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local battle_field_state = client_player:QueryProp("BattlefieldState")
  return 3 == battle_field_state
end
function is_in_match_sanmeng()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local isInSanmeng = client_player:QueryProp("IsSanmeng")
  return 1 == isInSanmeng
end
function is_in_new_war_rule()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local isInNewWarRule = client_player:QueryProp("IsNewWarRule")
  return 1 == isInNewWarRule
end
function is_in_balance_war()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_BALANCE_WAR) == PIS_IN_GAME then
    return true
  end
  if nx_execute("form_stage_main\\form_kof\\kof_util", "is_in_kof") then
    return true
  end
  return false
end
function is_in_wudao()
  return nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "is_in_wudao_scene")
end
function is_in_luandou()
  return nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "is_in_luandou_scene")
end
function on_channel_SchoolFight()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_team = gui.TextManager:GetText("ui_chat_channel_22")
  if is_in_school_fight() then
    add_auto_chat_page(form, channel_team, CHATTYPE_SCHOOL_FIGHT, CHATTYPE_SCHOOL_FIGHT)
  else
    del_chat_page(form, channel_team)
  end
end
function is_in_school_fight()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local is_in_school_fight = client_player:QueryProp("IsInSchoolFight")
  return 1 == is_in_school_fight
end
function on_channel_team()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_team = gui.TextManager:GetText("ui_chat_channel_19")
  if have_teamid_prop() then
    add_auto_chat_page(form, channel_team, CHATTYPE_ROW, CHATTYPE_TEAM)
  else
    del_chat_page(form, channel_team)
  end
end
function on_channel_guild()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_guild = gui.TextManager:GetText("ui_shenfen0005")
  if have_guild_league() then
    add_auto_chat_page(form, channel_guild, CHATTYPE_GUILD_LEAGUE, CHATTYPE_GUILD)
  elseif have_guild_prop() then
    add_auto_chat_page(form, channel_guild, CHATTYPE_GUILD, CHATTYPE_GUILD_LEAGUE)
  else
    del_chat_page(form, channel_guild)
  end
end
function on_channel_school()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_school = gui.TextManager:GetText("ui_shenfen0002")
  if have_school_prop() then
    local channel_force = gui.TextManager:GetText("ui_force")
    del_chat_page(form, channel_force)
    local channel_newschool = gui.TextManager:GetText("ui_xinmep")
    del_chat_page(form, channel_newschool)
    add_auto_chat_page(form, channel_school, CHATTYPE_SCHOOL)
  else
    del_chat_page(form, channel_school)
  end
  local channel_all_school = gui.TextManager:GetText("ui_mpys")
  if have_all_school_prop() then
    add_auto_chat_page(form, channel_all_school, CHATTYPE_ALL_SCHOOL)
  else
    del_chat_page(form, channel_all_school)
  end
end
function on_channel_force()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_force = gui.TextManager:GetText("ui_shili")
  if have_force_prop() then
    local channel_school = gui.TextManager:GetText("ui_shenfen0002")
    del_chat_page(form, channel_school)
    local channel_newschool = gui.TextManager:GetText("ui_xinmep")
    del_chat_page(form, channel_newschool)
    add_auto_chat_page(form, channel_force, CHATTYPE_FORCE)
  else
    del_chat_page(form, channel_force)
  end
end
function on_channel_newschool()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_newschool = gui.TextManager:GetText("ui_xinmep")
  if have_new_school_prop() then
    local channel_school = gui.TextManager:GetText("ui_shenfen0002")
    del_chat_page(form, channel_school)
    local channel_force = gui.TextManager:GetText("ui_shili")
    del_chat_page(form, channel_force)
    add_auto_chat_page(form, channel_newschool, CHATTYPE_NEW_SCHOOL)
  else
    del_chat_page(form, channel_newschool)
  end
  local channel_all_school = gui.TextManager:GetText("ui_mpys")
  if have_all_school_prop() then
    add_auto_chat_page(form, channel_all_school, CHATTYPE_ALL_SCHOOL)
  else
    del_chat_page(form, channel_all_school)
  end
end
function on_channel_newterritory()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_territory = gui.TextManager:GetText("ui_newterritory")
  if is_in_new_territory() then
    add_auto_chat_page(form, channel_territory, CHATTYPE_NEW_TERRITORY)
  else
    del_chat_page(form, channel_territory)
  end
end
function on_channel_outlandwar()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_outlandwar = gui.TextManager:GetText("ui_outlandwar")
  if is_in_outlandwar() then
    add_auto_chat_page(form, channel_outlandwar, CHATTYPE_OUTLAND_WAR)
  else
    del_chat_page(form, channel_outlandwar)
  end
end
function on_channel_match_sanmeng()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_sanmeng = gui.TextManager:GetText("ui_smzb_sayguj")
  if is_in_match_sanmeng() then
    add_auto_chat_page(form, channel_sanmeng, CHATTYPE_MATCH_SANMENG)
  else
    del_chat_page(form, channel_sanmeng)
  end
end
function on_channel_new_war_rule()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
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
  local sub_type = client_player:QueryProp("BattleSubType")
  local power_index = client_player:QueryProp("JoinPower")
  local channel_new_war_rule = gui.TextManager:GetText("ui_smzb_sayguj_" .. nx_string(sub_type) .. "_" .. nx_string(power_index))
  if is_in_new_war_rule() then
    add_auto_chat_page(form, channel_new_war_rule, CHATTYPE_NEW_WAR_RULE_START)
  else
    del_chat_page(form, channel_new_war_rule)
  end
end
function on_channel_guild_league()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_guildleague = gui.TextManager:GetText("ui_chat_channel_40")
  if have_guild_league() then
    add_auto_chat_page(form, channel_guildleague, CHATTYPE_GUILD, CHATTYPE_GUILD_LEAGUE)
  else
    del_chat_page(form, channel_guildleague)
  end
end
function on_channel_balance_war()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_balancewar = gui.TextManager:GetText("ui_chat_channel_41")
  if is_in_balance_war() then
    add_auto_chat_page(form, channel_balancewar, CHATTYPE_BALANCE_WAR)
  else
    del_chat_page(form, channel_balancewar)
  end
end
function on_channel_wudao()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_wudao = gui.TextManager:GetText("ui_chat_channel_42")
  if is_in_wudao() then
    add_auto_chat_page(form, channel_wudao, CHATTYPE_WUDAO)
  else
    del_chat_page(form, channel_wudao)
  end
end
function on_channel_luandou()
  local form = nx_value(FORM_MAIN_CHAT)
  local gui = nx_value("gui")
  if not nx_is_valid(form) and nx_is_valid(gui) then
    return
  end
  local channel_luandou = gui.TextManager:GetText("ui_chat_channel_43")
  if is_in_luandou() then
    add_auto_chat_page(form, channel_luandou, CHATTYPE_LUANDOU)
  else
    del_chat_page(form, channel_luandou)
  end
end
function del_chat_page(form, channel_name)
  local groupbox_pagebtn = form.groupbox_pagebtn
  local chat_group = form.chat_group
  local form_main_chat_logic = form.form_main_chat_logic
  if not nx_is_valid(form_main_chat_logic) then
    return
  end
  local is_need_check = false
  local section_name
  for i = 1, form.new_page_count do
    local page_btn = groupbox_pagebtn:Find("new_page_button" .. nx_string(i))
    local page_channel = chat_group:Find("new_chatlist" .. nx_string(i))
    local page_set_btn = groupbox_pagebtn:Find("new_page_set_button" .. nx_string(i))
    if nx_is_valid(page_btn) and nx_is_valid(page_channel) and nx_is_valid(page_set_btn) and page_btn.Text == channel_name then
      if page_btn.need_save then
        section_name = page_btn.Text
      end
      local gui = nx_value("gui")
      is_need_check = page_btn.Checked
      form.groupbox_pagebtn:Remove(page_btn)
      gui:Delete(page_btn)
      if nx_find_custom(page_channel, "info_tip") then
        local page_info_tip = page_channel.info_tip
        form.groupbox_pagebtn:Remove(page_info_tip)
        gui:Delete(page_info_tip)
      end
      if nx_find_custom(page_channel, "info_cue") then
        local page_info_cue = page_channel.info_cue
        form.groupbox_pagebtn:Remove(page_info_cue)
        gui:Delete(page_info_cue)
      end
      if nx_find_custom(page_channel, "info_hongbao") then
        local page_info_hongbao = page_channel.info_hongbao
        form.groupbox_pagebtn:Remove(page_info_hongbao)
        gui:Delete(page_info_hongbao)
      end
      form_main_chat_logic:DelChatInfoPage(page_channel.Name)
      form.chat_group:Remove(page_channel)
      gui:Delete(page_channel)
      form.chat_group:Remove(page_set_btn)
      gui:Delete(page_set_btn)
      local last_button = form.btn_channel
      local count = 1
      for i = 1, form.new_page_count do
        local leave_button = form.groupbox_pagebtn:Find("new_page_button" .. nx_string(i))
        local leave_list = form.chat_group:Find("new_chatlist" .. nx_string(i))
        local leave_set_button = form.groupbox_pagebtn:Find("new_page_set_button" .. nx_string(i))
        if nx_is_valid(leave_button) and nx_is_valid(leave_list) and nx_is_valid(leave_set_button) then
          leave_button.Name = "new_page_button" .. nx_string(nx_int(count))
          leave_list.Name = "new_chatlist" .. nx_string(nx_int(count))
          leave_button.DataSource = nx_string(nx_int(count))
          leave_button.AbsLeft = last_button.AbsLeft + last_button.Width + 2
          leave_set_button.Name = "new_page_set_button" .. nx_string(nx_int(count))
          leave_set_button.AbsLeft = leave_button.AbsLeft + leave_button.Width - leave_set_button.Width - 2
          leave_set_button.DataSource = nx_string(nx_int(count))
          last_button = leave_button
          form_main_chat_logic:ChangeChatPageName("new_chatlist" .. i, "new_chatlist" .. count)
          if leave_button.Checked then
            form.cur_info_page = nx_int(leave_button.DataSource)
          end
          count = count + 1
          if nx_find_custom(leave_list, "info_tip") then
            local leave_info_tip = leave_list.info_tip
            local leave_info_cue = leave_list.info_cue
            local leace_info_hongbao = leave_list.info_hongbao
            leace_info_hongbao.AbsLeft = leave_button.AbsLeft + 5
            leave_info_tip.AbsLeft = leave_button.AbsLeft + 5
            leave_info_cue.AbsLeft = leave_button.AbsLeft + 2
          end
        end
      end
      form.new_page_count = form.new_page_count - 1
      form.btn_newpage.AbsLeft = last_button.AbsLeft + last_button.Width + 2
      break
    end
  end
  if is_need_check then
    form.btn_channel.Checked = true
    on_select_chat_channel(form.btn_channel9)
  end
  if section_name ~= nil then
    form.show_add_page = true
    nx_execute(FORM_MAIN_PAGE, "delete_pageEx", section_name)
  end
end
function add_auto_chat_page(form, channel_name, ...)
  for n_index = 1, form.new_page_count do
    local btn_page = form.groupbox_pagebtn:Find("new_page_button" .. nx_string(n_index))
    if nx_is_valid(btn_page) and btn_page.Text == channel_name then
      return
    end
  end
  local pre_page_chat = form.chat_list
  local pre_page_btn = form.btn_channel
  local pre_page_scrollbar = form.scrollbar_list
  if form.new_page_count ~= 0 then
    pre_page_btn = form.groupbox_pagebtn:Find("new_page_button" .. nx_string(nx_int(form.new_page_count)))
    pre_page_chat = form.chat_group:Find("new_chatlist" .. nx_string(nx_int(form.new_page_count)))
    pre_page_scrollbar = form.chat_group:Find("new_scrollbar" .. nx_string(nx_int(form.new_page_count)))
  end
  local gui = nx_value("gui")
  local new_page_chat = gui:Create("MultiTextBox")
  local new_page_btn = gui:Create("RadioButton")
  local new_page_set_btn = gui:Create("Button")
  local new_page_info_tip = gui:Create("Label")
  local new_page_info_cue = gui:Create("Label")
  local new_page_info_hongbao = gui:Create("Label")
  new_page_btn.page_chat = new_page_chat
  new_page_chat.page_btn = new_page_btn
  new_page_chat.LineHeight = CHAT_LIST_HEIGHT
  new_page_chat.info_tip = new_page_info_tip
  new_page_chat.info_cue = new_page_info_cue
  new_page_set_btn.page_btn = new_page_btn
  new_page_chat.info_hongbao = new_page_info_hongbao
  new_page_btn.is_add = true
  form.groupbox_pagebtn:Add(new_page_btn)
  form.chat_group:Add(new_page_chat)
  form.groupbox_pagebtn:Add(new_page_set_btn)
  form.groupbox_pagebtn:Add(new_page_info_tip)
  form.groupbox_pagebtn:Add(new_page_info_cue)
  form.groupbox_pagebtn:Add(new_page_info_hongbao)
  local list_prop_table = nx_property_list(pre_page_chat)
  for i = 1, table.maxn(list_prop_table) do
    local value = nx_property(pre_page_chat, list_prop_table[i])
    nx_set_property(new_page_chat, list_prop_table[i], value)
  end
  new_page_chat.Top = pre_page_chat.Top
  new_page_chat.ViewRect = "10,0," .. new_page_chat.Width - 10 .. "," .. new_page_chat.Height - 10
  nx_bind_script(new_page_chat, FORM_MAIN_CHAT, "new_page_chatlist_init", new_page_chat)
  nx_callback(new_page_chat, "on_get_capture", "on_chat_list_get_capture")
  nx_callback(new_page_chat, "on_lost_capture", "on_chat_list_lost_capture")
  nx_callback(new_page_chat, "on_click_hyperlink", "on_chat_list_click_hyperlink")
  nx_callback(new_page_chat, "on_right_click_hyperlink", "on_chat_list_right_click_hyperlink")
  local button_prop_table = nx_property_list(pre_page_btn)
  for i = 1, table.maxn(button_prop_table) do
    local value = nx_property(pre_page_btn, button_prop_table[i])
    if button_prop_table[i] ~= "Checked" then
      nx_set_property(new_page_btn, button_prop_table[i], value)
    end
  end
  new_page_btn.Text = nx_widestr(channel_name)
  nx_bind_script(new_page_btn, FORM_MAIN_CHAT)
  nx_callback(new_page_btn, "on_checked_changed", "on_page_checked_changed")
  nx_callback(new_page_btn, "on_get_capture", "on_cbtn_page_get_capture")
  nx_callback(new_page_btn, "on_lost_capture", "on_cbtn_page_lost_capture")
  nx_callback(new_page_btn, "on_click", "on_page_click")
  new_page_set_btn.AutoSize = true
  new_page_set_btn.NormalImage = "gui\\mainform\\chat\\arrow_out.png"
  new_page_set_btn.FocusImage = "gui\\mainform\\chat\\arrow_on.png"
  new_page_set_btn.PushImage = "gui\\mainform\\chat\\arrow_down.png"
  new_page_set_btn.TabIndex = -1
  new_page_set_btn.TabStop = false
  nx_bind_script(new_page_set_btn, FORM_MAIN_CHAT)
  nx_callback(new_page_set_btn, "on_get_capture", "on_btn_page_set_get_capture")
  nx_callback(new_page_set_btn, "on_lost_capture", "on_btn_page_set_lost_capture")
  nx_callback(new_page_set_btn, "on_click", "on_btn_page_set_click")
  new_page_info_tip.AutoSize = true
  new_page_info_tip.BackImage = "chat_qipao"
  new_page_info_cue.BackImage = "chat_tips"
  new_page_info_hongbao.AutoSize = true
  new_page_info_hongbao.BackImage = "hongbao_xiao"
  new_page_btn.Visible = true
  new_page_chat.Visible = false
  new_page_info_cue.Visible = true
  new_page_info_tip.Visible = false
  new_page_info_hongbao.Visible = is_show_cue
  new_page_info_hongbao.Visible = false
  new_page_chat.is_normal = SHOW_ALL
  form.new_page_count = form.new_page_count + 1
  new_page_btn.Name = "new_page_button" .. nx_string(nx_int(form.new_page_count))
  new_page_btn.DataSource = nx_string(nx_int(form.new_page_count))
  new_page_chat.Name = "new_chatlist" .. nx_string(nx_int(form.new_page_count))
  new_page_chat.DataSource = nx_string(nx_int(form.new_page_count))
  new_page_set_btn.Name = "new_page_set_button" .. nx_string(nx_int(form.new_page_count))
  new_page_set_btn.DataSource = nx_string(nx_int(form.new_page_count))
  new_page_info_cue.Name = "new_page_info_cue" .. nx_string(nx_int(form.new_page_count))
  new_page_info_cue.DataSource = nx_string(nx_int(form.new_page_count))
  new_page_info_tip.Name = "new_page_info_tip" .. nx_string(nx_int(form.new_page_count))
  new_page_info_tip.DataSource = nx_string(nx_int(form.new_page_count))
  new_page_info_hongbao.Name = "new_page_info_hongbao" .. nx_string(nx_int(form.new_page_count))
  new_page_info_hongbao.DataSource = nx_string(nx_int(form.new_page_count))
  local btn_newpage = form.btn_newpage
  new_page_btn.AbsLeft = pre_page_btn.AbsLeft + pre_page_btn.Width + 2
  btn_newpage.AbsLeft = new_page_btn.AbsLeft + new_page_btn.Width + 2
  new_page_set_btn.Top = form.btn_channel_set.Top + 2
  new_page_set_btn.AbsLeft = new_page_btn.AbsLeft + new_page_btn.Width - new_page_set_btn.Width - 3
  new_page_info_cue.AbsTop = new_page_btn.AbsTop + 2
  new_page_info_cue.AbsLeft = new_page_btn.AbsLeft + 2
  new_page_info_cue.Height = new_page_btn.Height
  new_page_info_cue.Width = new_page_btn.Width - 3
  new_page_info_tip.AbsTop = new_page_btn.AbsTop - 25
  new_page_info_tip.AbsLeft = new_page_btn.AbsLeft + 5
  new_page_info_hongbao.AbsTop = new_page_btn.AbsTop - 25
  new_page_info_hongbao.AbsLeft = new_page_btn.AbsLeft + 5
  new_page_btn.auto_page = true
  new_page_btn.can_delete = true
  local chat_type = nx_int(arg[1])
  if nx_int(arg[1]) == nx_int(CHATTYPE_GUILD) then
    new_page_btn.auto_page = false
  end
  if chat_type == nx_int(CHATTYPE_LUANDOU) then
    new_page_btn.can_delete = false
  end
  if chat_type == nx_int(CHATTYPE_ROW) and nx_execute("form_stage_main\\form_kof\\kof_util", "is_in_kof") then
    on_page_click(new_page_btn)
  end
  new_page_btn.need_save = false
  new_page_btn.page_type = arg[1]
  new_page_btn.default_channel = arg[1]
  local prop_name = ""
  for n_index, channel in ipairs(arg) do
    prop_name = "chat_enable_" .. nx_string(nx_int(channel))
    nx_set_custom(new_page_btn, prop_name, true)
    new_page_chat:ShowKeyItems(nx_int(channel))
  end
  set_ctrl_container_blendcolor(form.groupbox_pagebtn, 200)
  set_ctrl_container_blendcolor(form.group_chat_input, 200)
  form.group_chat_input.Visible = form.btn_open.isshow
  form.groupbox_pagebtn.Visible = form.btn_open.isshow
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_MAIN_CHAT, "resume_chat", form)
    timer:Register(10000, -1, FORM_MAIN_CHAT, "resume_chat", form, 1, -1)
  end
end
function on_btn_page_set_get_capture(self)
  local form = self.ParentForm
  add_cbtn_page_lost_capture(form)
end
function on_btn_page_set_lost_capture(self)
  local form = self.ParentForm
  del_cbtn_page_lost_capture(form)
end
function on_btn_channel_set_get_capture(self)
  local form = self.ParentForm
  add_cbtn_page_lost_capture(form)
end
function on_btn_channel_set_lost_capture(self)
  local form = self.ParentForm
  del_cbtn_page_lost_capture(form)
end
function on_btn_channel_set_p_get_capture(self)
  local form = self.ParentForm
  add_cbtn_page_lost_capture(form)
end
function on_btn_channel_set_p_lost_capture(self)
  local form = self.ParentForm
  del_cbtn_page_lost_capture(form)
end
function on_btn_channel_del_p_get_capture(self)
  local form = self.ParentForm
  add_cbtn_page_lost_capture(form)
end
function on_btn_channel_del_p_lost_capture(self)
  local form = self.ParentForm
  del_cbtn_page_lost_capture(form)
end
function set_default_page_channel(cbtn_page)
  if not nx_is_valid(cbtn_page) or not nx_find_custom(cbtn_page, "default_channel") then
    return
  end
  local btn_channel_index = chat_chanel_sort_ui_table[cbtn_page.default_channel]
  local control = cbtn_page.ParentForm.group_select_channel:Find("btn_channel" .. nx_string(btn_channel_index))
  if not nx_is_valid(control) then
    return
  end
  local gui = nx_value("gui")
  if chat_check_type_notice(gui, form, n_curr_chanenl) == 0 then
    return
  end
  control.Enabled = true
  on_select_chat_channel(control)
end
function resume_chat(form, n_visible)
  if not nx_is_valid(form) then
    return
  end
  local form_logic = nx_value("form_main_chat")
  if nx_is_valid(form_logic) and nx_find_method(form_logic, "ResumeChat") then
    form_logic:ResumeChat(form, nx_int(n_visible))
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_MAIN_CHAT, "resume_chat", form)
  end
end
function dec_page()
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local scrollbar = form.scrollbar_list
  if scrollbar.Value == scrollbar.Maximum then
    return
  end
  if scrollbar.Value + 5 > scrollbar.Maximum then
    scrollbar.Value = scrollbar.Maximum
  else
    scrollbar.Value = scrollbar.Value + 5
  end
  if form.cur_info_page == 0 then
    form.chat_list.VerticalValue = scrollbar.Value
  else
    local chat_list = form.chat_group:Find("new_chatlist" .. nx_string(form.cur_info_page))
    chat_list.VerticalValue = scrollbar.Value
  end
end
function inc_page()
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  local scrollbar = form.scrollbar_list
  if scrollbar.Value == scrollbar.Minimum then
    return
  end
  if scrollbar.Value - 5 < scrollbar.Minimum then
    scrollbar.Value = scrollbar.Minimum
  else
    scrollbar.Value = scrollbar.Value - 5
  end
  if form.cur_info_page == 0 then
    form.chat_list.VerticalValue = scrollbar.Value
  else
    local chat_list = form.chat_group:Find("new_chatlist" .. nx_string(form.cur_info_page))
    chat_list.VerticalValue = scrollbar.Value
  end
end
function chat_check_channel(form_chat, channel_type, is_channel_enable)
  form_chat.confirm_channel = true
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule and channel_type ~= CHATTYPE_VISUALRANGE then
    form_chat.confirm_channel = false
    return true
  end
  if channel_type == CHATTYPE_SCHOOL or channel_type == CHATTYPE_SCENE or channel_type == CHATTYPE_ALL_SCHOOL then
    if not is_channel_enable then
      form_chat.confirm_channel = false
      clear_input(form_chat)
      return true
    end
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      form_chat.confirm_channel = false
      return true
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      form_chat.confirm_channel = false
      return true
    end
    if is_vip(client_player, VT_NORMAL) or client_player:QueryProp("PowerLevel") >= 16 then
      form_chat.confirm_channel = false
      return false
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat_vip")
    if not nx_is_valid(dialog) then
      form_chat.confirm_channel = false
      return true
    end
    local gui = nx_value("gui")
    dialog.ok_btn.Text = gui.TextManager:GetText("ui_chat_vip_btn")
    local text = gui.TextManager:GetFormatText("ui_chat_vip_tips")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if "ok" == res and not util_is_form_visible("form_stage_main\\form_vip_info") then
      util_auto_show_hide_form("form_stage_main\\form_vip_info")
    end
    form_chat.confirm_channel = false
    return true
  end
  if channel_type ~= CHATTYPE_WORLD and channel_type ~= CHATTYPE_GOSSIP then
    form_chat.confirm_channel = false
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if not nx_is_valid(dialog) then
    form_chat.confirm_channel = false
    return false
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_congirm_channel_" .. nx_string(channel_type))
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(1505) and channel_type ~= CHATTYPE_DEAL then
    text = gui.TextManager:GetText("ui_congirm_channel_" .. nx_string(channel_type) .. "_1")
  end
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(134) and (channel_type == CHATTYPE_WORLD or channel_type == CHATTYPE_GOSSIP) then
    local goods_grid = nx_value("GoodsGrid")
    if nx_is_valid(goods_grid) then
      local count_1 = goods_grid:GetItemCount("item_laba_bangding")
      local count_2 = goods_grid:GetItemCount("item_laba_feibangding")
      if 0 < count_1 + count_2 then
        text = gui.TextManager:GetText("ui_congirm_channel_" .. nx_string(channel_type) .. "_2")
      end
    end
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  form_chat.confirm_channel = false
  return res == "cancel"
end
function on_btn_show_goods_click(btn)
  local form = btn.ParentForm
  local n_page_index = form.cur_info_page
  local btn_page = get_current_page_btn(form)
  if not nx_is_valid(btn_page) then
    return
  end
  local chat_list = btn_page.page_chat
  local form_main_chat_logic = form.form_main_chat_logic
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:ShowGoodsInfo(chat_list)
    chat_list.is_normal = SHOW_GOODS
    show_info_type_btn_change(form, SHOW_GOODS)
    form.scrollbar_list.Maximum = chat_list.VerticalMaxValue
    form.scrollbar_list.Value = chat_list.VerticalValue
  end
end
function on_btn_show_no_goods_click(btn)
  local form = btn.ParentForm
  local btn_all = form.btn_show_normal
  on_btn_show_normal_click(btn_all)
  local n_page_index = form.cur_info_page
  local btn_page = get_current_page_btn(form)
  if not nx_is_valid(btn_page) then
    return
  end
  local chat_list = btn_page.page_chat
  local form_main_chat_logic = form.form_main_chat_logic
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:ShowNoGoodsInfo(chat_list)
    chat_list.is_normal = SHOW_NO_GOODS
    show_info_type_btn_change(form, SHOW_NO_GOODS)
    form.scrollbar_list.Maximum = chat_list.VerticalMaxValue
    form.scrollbar_list.Value = chat_list.VerticalValue
  end
end
function on_btn_1_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_origin\\form_origin_chose")
end
function on_btn_show_normal_click(btn)
  local form = btn.ParentForm
  local n_page_index = form.cur_info_page
  local btn_page = get_current_page_btn(form)
  if not nx_is_valid(btn_page) then
    return
  end
  local chat_list = btn_page.page_chat
  local form_main_chat_logic = form.form_main_chat_logic
  if nx_is_valid(chat_list) and nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:ShowNormalInfo(chat_list)
    chat_list.is_normal = SHOW_ALL
    show_info_type_btn_change(form, SHOW_ALL)
    form.scrollbar_list.Maximum = chat_list.VerticalMaxValue
    form.scrollbar_list.Value = chat_list.VerticalMaxValue
  end
end
function show_info_type_btn_change(form, show_type)
  if SHOW_ALL == show_type then
    form.btn_show_normal.Visible = false
    form.btn_show_goods.Visible = true
    form.btn_show_no_goods.Visible = false
  elseif SHOW_GOODS == show_type then
    form.btn_show_normal.Visible = false
    form.btn_show_goods.Visible = false
    form.btn_show_no_goods.Visible = true
  else
    form.btn_show_normal.Visible = true
    form.btn_show_goods.Visible = false
    form.btn_show_no_goods.Visible = false
  end
end
function is_mouse_in_mltbox(mltbox)
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_y = gui:GetCursorPosition()
  if nx_float(mouse_x) > nx_float(form.AbsLeft) and nx_float(mouse_x) < nx_float(form.AbsLeft + mltbox.Width) and nx_float(mouse_y) > nx_float(mltbox.AbsTop) and nx_float(mouse_y) < nx_float(mltbox.AbsTop + mltbox.Height) then
    return true
  else
    return false
  end
end
function on_btn_send_mail_click(self)
  local form = self.ParentForm
  local sname = form.sender_name
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
  local form_send_mail = nx_value("form_stage_main\\form_mail\\form_mail_send")
  if nx_is_valid(form_send_mail) then
    form_send_mail.targetname.Text = nx_widestr(sname)
  end
end
function close_form()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", false, false, "chat")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", dialog.cancel_btn)
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", false, false, "chat_vip")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", dialog.cancel_btn)
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", false, false, "chat_silence")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", dialog.cancel_btn)
  end
end
function vip_face_channel()
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return false
  end
  local chat_type = form.chat_edit.chat_type
  if chat_type ~= CHATTYPE_VISUALRANGE then
    local gui = nx_value("gui")
    local info = gui.TextManager:GetText("face_vip_tips")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return false
  end
  return true
end
function get_player_prop(prop_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp(nx_string(prop_name)) then
    return ""
  end
  return client_player:QueryProp(nx_string(prop_name))
end
function on_btn_impeach_click(self)
  local form = self.ParentForm
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) then
    local enable = switchmgr:CheckSwitchEnable(ST_FUNCTION_GMCC_JUBAO)
    if not enable then
      return
    end
  end
  if not nx_find_custom(form, "chatlist_index") and not nx_find_custom(form, "chatlist_playername") then
    return
  end
  if form.chatlist_playername == "" or form.chatlist_playername == nil then
    return
  end
  local form_main_chat_logic = nx_value("form_main_chat")
  if not nx_is_valid(form_main_chat_logic) then
    return
  end
  local info = form.chat_list:GetItemTextNoHtml(form.chatlist_index)
  info = form_main_chat_logic:DeleteHtml(info)
  local str = string.gsub(nx_string(info), " ", "")
  str = string.gsub(nx_string(str), "\161\161", "")
  str = string.gsub(nx_string(str), "\t", "")
  if str == ":" or str == "" then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("99601"))
    return
  end
  info = nx_widestr(form.chatlist_playername) .. info
  local gui = nx_value("gui")
  local excuse = gui.TextManager:GetText("msg_report_ad_excuse")
  nx_execute("form_stage_main\\form_gmcc\\form_gmcc_main", "notify_player", nx_widestr(form.chatlist_playername), 3, excuse, info)
  form.chatlist_playername = ""
end
function have_new_school_prop()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("NewSchool") then
    local school = client_player:QueryProp("NewSchool")
    if school ~= "" then
      return true
    end
  end
end
function have_all_school_prop()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("School") then
    local school = client_player:QueryProp("School")
    if school ~= "" then
      return true
    end
  end
  if client_player:FindProp("LeaveSchoolType") then
    local leave_school_type = client_player:QueryProp("LeaveSchoolType")
    if nx_number(leave_school_type) == 2 or nx_number(leave_school_type) == 3 then
      local last_school = client_player:QueryProp("LastSchool")
      if last_school ~= "" then
        return true
      end
    end
  end
  if client_player:FindProp("SchoolMark") then
    local school_mark = client_player:QueryProp("SchoolMark")
    if nx_number(school_mark) == 1 and client_player:FindProp("NewSchool") then
      local new_school = client_player:QueryProp("NewSchool")
      if new_school ~= "" then
        return true
      end
    end
  end
  return false
end
function have_guild_league()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("GuildLeagueName") then
    local guild_league = client_player:QueryProp("GuildLeagueName")
    if guild_league ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function on_btn_get_trumpet_form_click(btn)
  nx_execute("form_stage_main\\form_main\\form_laba_info", "open_trumpet_publish_form")
end
function on_btn_trumpet_click(btn)
  local form_type = nx_number(btn.TabIndex)
  if form_type ~= 1 and form_type ~= 2 then
    return
  end
  local Speaker = nx_value("Speaker")
  if not nx_is_valid(Speaker) then
    return
  end
  local res = false
  if form_type == 1 then
    res = Speaker:CanChangeMsgTextbox(0)
  elseif form_type == 2 then
    res = Speaker:CanChangeMsgTextbox(2)
  end
  if res then
    change_trumpet_textbox(form_type)
  end
end
function change_trumpet_textbox(index)
  local form_type = nx_number(index)
  if form_type == 1 or form_type == 2 then
    local form_ordinary = nx_value("form_stage_main\\form_main\\form_main_trumpet")
    local form_cross = nx_value("form_stage_main\\form_main\\form_main_trumpet_cross")
    local Speaker = nx_value("Speaker")
    if not (nx_is_valid(form_ordinary) and nx_is_valid(form_cross)) or not nx_is_valid(Speaker) then
      return
    end
    form_ordinary.Visible = true
    form_cross.Visible = true
    if form_type == 1 then
      form_ordinary.Visible = true
      form_cross.Visible = false
      Speaker:SetTrumpetMsgReadFlag(0)
    elseif form_type == 2 then
      form_ordinary.Visible = false
      form_cross.Visible = true
      Speaker:SetTrumpetMsgReadFlag(2)
    end
  end
end
function init_trumpet_btn_status(b_init, b_visible)
  local form = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form) then
    return
  end
  if not b_visible then
    nx_execute("form_stage_main\\form_main\\form_laba_info", "set_all_trumpet_form_visible", false)
    return
  end
  if b_init then
    form.btn_get_trumpet_form.Visible = true
    form.lbl_trumpet_count.Visible = false
    form.lbl_cross_count.Visible = false
    form.ani_1.Visible = false
    form.ani_2.Visible = false
    form.ani_1:Stop()
    form.ani_1:Play()
    form.ani_2:Stop()
    form.ani_2:Play()
  end
  local SPACING = 0
  local SPACING_CHATLIST = 30
  local BASE_ABSTOP = form.chat_list.AbsTop - SPACING_CHATLIST
  form.btn_get_trumpet_form.AbsLeft = form.btn_open.AbsLeft
  form.btn_trumpet.AbsLeft = form.btn_open.AbsLeft
  form.btn_trumpet_cross_server.AbsLeft = form.btn_open.AbsLeft
  form.btn_trumpet_cross_server.AbsTop = BASE_ABSTOP - form.btn_trumpet_cross_server.Height
  form.btn_trumpet.AbsTop = form.btn_trumpet_cross_server.AbsTop - form.btn_trumpet.Height - SPACING
  form.btn_get_trumpet_form.AbsTop = form.btn_trumpet.AbsTop - form.btn_get_trumpet_form.Height - SPACING
  form.ani_1.AbsLeft = form.btn_trumpet.AbsLeft
  form.ani_1.AbsTop = form.btn_trumpet.AbsTop
  form.ani_2.AbsLeft = form.btn_trumpet_cross_server.AbsLeft
  form.ani_2.AbsTop = form.btn_trumpet_cross_server.AbsTop
  form.lbl_trumpet_count.AbsLeft = form.btn_trumpet.AbsLeft
  form.lbl_trumpet_count.AbsTop = form.btn_trumpet.AbsTop + 8
  form.lbl_cross_count.AbsLeft = form.btn_trumpet_cross_server.AbsLeft
  form.lbl_cross_count.AbsTop = form.btn_trumpet_cross_server.AbsTop + 8
end
function IsInWuDaoScene()
  return nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "is_in_wudao_scene")
end
function IsInWuDaoWarTeam()
  return nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team.lua", "is_player_in_war_team")
end
function IsWuDaoWarTeamCaptain()
  return nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team.lua", "player_is_team_leader")
end
function on_btn_wudao_invite_click(btn)
  local form = btn.ParentForm
  local target_name = form.sender_name
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_invite", "custom_player_join_team", target_name)
end
function on_btn_wudao_join_team_click(btn)
  local form = btn.ParentForm
  local target_name = form.sender_name
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_search_team", "custom_apply_join", form.target_wudao_team_name)
end
function zonghe_page_hongbao_tip(self)
  local zonghe_btn = self.btn_channel
  local gui = nx_value("gui")
  local zonghe_page_hongbao_tip = gui:Create("Label")
  zonghe_page_hongbao_tip.AutoSize = true
  zonghe_page_hongbao_tip.BackImage = "chat_qipao"
  self.groupbox_pagebtn:Add(zonghe_page_hongbao_tip)
  zonghe_page_hongbao_tip.Visible = true
  zonghe_page_hongbao_tip.AbsTop = zonghe_btn.AbsTop - 25
  zonghe_page_hongbao_tip.AbsLeft = zonghe_btn.AbsLeft + 10
end
function a(b)
  nx_msgbox(nx_string(b))
end
