require("util_gui")
require("util_functions")
require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("tips_data")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_tiguan\\form_new_tiguan_main"
local FORCE_NAME = "group_karma_"
local FORM_ATTRIBUTE_MALL_TIGUAN = "form_stage_main\\form_attribute_mall\\form_attribute_shop_tiguan"
local FORM_TIGUAN_FRIEND = "form_stage_main\\form_tiguan\\form_tiguan_friend"
local TG_NEW_CONFIG = "share\\War\\tiguan_new_rule.ini"
local guan_lv_num = 6
local tiguan_level_max = 6
local tiguan_arrest_max = 9
local tiguan_challenge_task_max = 9
local rank_col_count = 18
local rank_default_fore_color = "255,204,204,204"
local rank_select_fore_color = "255,255,204,0"
local rank_player_fore_color = "255,255,63,12"
local rank_apply_text_id_1 = "ui_rank_canjiaanniu1"
local rank_apply_text_id_2 = "ui_rank_canjiaanniu2"
local rank_col_guan_name = 0
local rank_col_level_name = 1
local rank_col_apply_control = 2
local rank_col_apply_num = 3
local rank_col_player_name = 4
local rank_col_title = 5
local rank_col_award_1 = 6
local rank_col_last_week = 7
local rank_col_my_score = 8
local rank_col_next_week = 9
local rank_col_rule_is_get = 10
local rank_col_rule_level = 11
local rank_col_rule_guan_id = 12
local rank_col_rule_sort = 13
local rank_col_rule_award = 14
local rank_col_rule_last = 15
local rank_col_rule_best = 16
local rank_col_rule_time = 17
local guan_danci_name = {
  [1] = "ui_dengji1",
  [2] = "ui_dengji2",
  [3] = "ui_dengji3",
  [4] = "ui_dengji4",
  [5] = "ui_dengji5",
  [6] = "ui_dengji6"
}
local guan_level_text = {
  [1] = "ui_dengji1",
  [2] = "ui_dengji2",
  [3] = "ui_dengji3",
  [4] = "ui_dengji4",
  [5] = "ui_dengji5",
  [6] = "ui_dengji6"
}
local arrest_boss_desc = {
  [1] = "ui_dantongji_1",
  [2] = "ui_dantongji_2",
  [3] = "ui_dantongji_3",
  [4] = "ui_dantongji_4",
  [5] = "ui_dantongji_5",
  [6] = "ui_dantongji_6"
}
local arrest_boss_double_desc = {
  [1] = "ui_dantongji_1_1",
  [2] = "ui_dantongji_2_1",
  [3] = "ui_dantongji_3_1",
  [4] = "ui_dantongji_4_1",
  [5] = "ui_dantongji_5_1",
  [6] = "ui_dantongji_6_1"
}
local rank_col_list = {
  [1] = "ui_tiguan_one_rank_1",
  [2] = "ui_tiguan_one_rank_2",
  [3] = "ui_tiguan_one_rank_3",
  [4] = "ui_tiguan_one_rank_4",
  [5] = "ui_tiguan_one_rank_5",
  [6] = "ui_tiguan_one_rank_6",
  [7] = "ui_tiguan_one_rank_7",
  [8] = "ui_tiguan_one_rank_8",
  [9] = "ui_tiguan_one_rank_9",
  [10] = "ui_tiguan_one_rank_10"
}
local tab_sort = {}
function main_form_init(self)
  self.Fixed = false
  self.guan_id_sel = 0
  self.opentime = 0
  self.reccount = 0
  self.cur_tiguan_level = 1
  self.cur_tiguan_count = 0
  self.cur_time = 0
  self.cur_level_limit = 0
  self.all_kill_guan_id = 0
  self.free_appoint = 0
  self.boss_count_all = 0
  self.turn_out = false
  self.reset_times = 0
  self.is_in_double = 0
  self.day_defeat = 0
  self.award_time = 0
  self.award_max_time = 15
  self.can_apply = 0
  self.friend_card_count = 0
  self.easy_type = 0
  self.rank_rows = 0
  self.rank_capture_row = -1
  self.rank_capture_col = -1
  self.rank_select_guanid = -1
  self.rank_sort_col = -1
  self.bSendRankQuest = false
  self.rank_apply_guanid = 0
  self.rank_repeat_time = 0
end
function main_form_open(self)
  set_rbtn_type(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  self.player_name = client_player:QueryProp("Name")
  self.rbtn_tiaozhan.Checked = true
  add_store_form()
  add_friend_form()
  init_rank_info(self)
  init_challenge_ctrl(self)
  request_this_week_jingsu()
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_FORM_INIT)
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_RANK_INFO)
  send_tiguan_info(self)
  request_boss_value()
  default_choose(self)
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("TGChallengeValue", "int", self, FORM_NAME, "on_TGChallengeValue_changed")
end
function main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("TGChallengeValue", self)
  end
  nx_destroy(self)
end
function on_TGChallengeValue_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("TGChallengeValue")
  if nx_number(value) < 0 then
    value = 0
  end
  local max_value = get_ini_prop_maxvalue("TGChallengeValue")
  form.lbl_21.Text = nx_widestr(value) .. nx_widestr("/") .. nx_widestr(max_value)
end
function get_ini_prop_maxvalue(prop)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\common_inc_prop_value\\PropIncEffect.ini")
  if not nx_is_valid(ini) then
    return
  end
  if not ini:FindSection(nx_string(prop)) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(prop))
  if sec_index < 0 then
    return
  end
  return ini:ReadInteger(sec_index, "max_value", 0)
end
function default_choose(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_guan_all.Checked = true
end
function request_boss_value()
  for i = 1, tiguan_level_max do
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_BOSS_NOTE, nx_number(i))
  end
end
function set_rbtn_type(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.btn_rank_1.sort_id = rank_col_rule_level
  form.btn_rank_1.default_sort_id = rank_col_rule_sort
  form.btn_rank_1.click_times = 0
  form.btn_rank_1.colour_col = 1
  form.btn_rank_1.bGreater = false
  form.btn_rank_2.sort_id = rank_col_rule_award
  form.btn_rank_2.default_sort_id = rank_col_rule_sort
  form.btn_rank_2.click_times = 0
  form.btn_rank_2.colour_col = rank_col_award_1
  form.btn_rank_2.bGreater = true
  form.btn_rank_3.sort_id = rank_col_rule_last
  form.btn_rank_3.default_sort_id = rank_col_rule_sort
  form.btn_rank_3.click_times = 0
  form.btn_rank_3.colour_col = rank_col_next_week
  form.btn_rank_3.bGreater = true
end
function init_rank_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  form.textgrid_rank:BeginUpdate()
  form.textgrid_rank:ClearRow()
  form.textgrid_rank.ColCount = rank_col_count
  form.textgrid_rank.HeaderBackColor = "0,255,255,255"
  for i = 1, rank_col_count do
    local head_name = gui.TextManager:GetFormatText(rank_col_list[i])
    form.textgrid_rank:SetColTitle(i - 1, nx_widestr(head_name))
  end
  form.textgrid_rank:EndUpdate()
end
function send_tiguan_info(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local now_time = nx_function("ext_get_tickcount") / 1000
  if nx_int(self.opentime) == 0 or nx_int(now_time - self.opentime) >= nx_int(REFRESH_TIME) then
    self.opentime = now_time
    self.reccount = 0
    nx_execute("custom_sender", "custom_get_tiguan_all_info", nx_object(player.Ident))
  end
end
function open_form()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
    return
  end
  form:Close()
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function init_challenge_ctrl(form)
  if not nx_is_valid(form) then
    return
  end
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  local guan_share_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(guan_ui_ini) then
    return
  end
  if not nx_is_valid(guan_share_ini) then
    return
  end
  form.gpsb_guans:DeleteAll()
  local gsb = form.gpsb_guans
  local gb_guan_mod = form.gbox_guan1
  local cbtn_guan_mod = form.cbtn_guan_sel
  local lbl_guan_bg1_mod = form.lbl_bg1
  local lbl_guan_bg2_mod = form.lbl_bg2
  local lbl_guan_sort_mod = form.lbl_guan_sort
  local lbl_guan_name_mod = form.lbl_guan_name
  local lbl_guan_box_mod = form.lbl_guan_box
  local cbtn_guan_box_mod = form.cbtn_guan_box
  local lbl_open_mod = form.lbl_open
  local lbl_today_join_des_mod = form.lbl_today_join_des
  local lbl_today_success_des_mod = form.lbl_today_success_des
  local lbl_today_join_mod = form.lbl_today_join
  local lbl_today_success_mod = form.lbl_today_success
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return
  end
  tab_sort = {}
  local section_count = guan_ui_ini:GetSectionCount()
  form.guan_count = section_count
  gsb.IsEditMode = true
  for i = 1, section_count do
    local guan_id = guan_ui_ini:GetSectionByIndex(i - 1)
    local gb_guan = create_ctrl("GroupBox", "gb_guan_" .. guan_id, gb_guan_mod, gsb)
    local lbl_guan_bg2 = create_ctrl("Label", "lbl_guan_bg2_" .. guan_id, lbl_guan_bg2_mod, gb_guan)
    local lbl_guan_bg1 = create_ctrl("Label", "lbl_guan_bg1_" .. guan_id, lbl_guan_bg1_mod, gb_guan)
    local cbtn_guan = create_ctrl("CheckButton", "cbtn_guan_" .. guan_id, cbtn_guan_mod, gb_guan)
    local lbl_guan_sort = create_ctrl("Label", "lbl_guan_sort_" .. guan_id, lbl_guan_sort_mod, gb_guan)
    local lbl_guan_name = create_ctrl("Label", "lbl_guan_name_" .. guan_id, lbl_guan_name_mod, gb_guan)
    local lbl_guan_box = create_ctrl("Label", "lbl_guan_box_" .. guan_id, lbl_guan_box_mod, gb_guan)
    local cbtn_guan_box = create_ctrl("CheckButton", "cbtn_guan_box_" .. guan_id, cbtn_guan_box_mod, gb_guan)
    local lbl_open = create_ctrl("Label", "lbl_open_" .. guan_id, lbl_open_mod, gb_guan)
    local lbl_today_join_des = create_ctrl("Label", "lbl_today_join_des_" .. guan_id, lbl_today_join_des_mod, gb_guan)
    local lbl_today_success_des = create_ctrl("Label", "lbl_today_success_des_" .. guan_id, lbl_today_success_des_mod, gb_guan)
    local lbl_today_join = create_ctrl("Label", "lbl_today_join_" .. guan_id, lbl_today_join_mod, gb_guan)
    local lbl_today_success = create_ctrl("Label", "lbl_today_success_" .. guan_id, lbl_today_success_mod, gb_guan)
    local sec_index_1 = guan_ui_ini:FindSectionIndex(nx_string(guan_id))
    local sec_index_2 = guan_share_ini:FindSectionIndex(nx_string(guan_id))
    local index = guan_share_ini:FindSectionIndex(guan_id)
    if 0 <= index then
      gb_guan.limitcount = guan_share_ini:ReadString(index, "LimitCountPerDay", "")
      gb_guan.limitsucceed = guan_share_ini:ReadString(index, "LimitSuccessPerDay", "")
      cbtn_guan_box.limitsucceed = guan_share_ini:ReadString(index, "LimitSuccessPerDay", "")
    end
    lbl_guan_bg1.BackImage = get_guan_image(guan_id, 1)
    cbtn_guan_box.ClickEvent = true
    nx_bind_script(cbtn_guan_box, nx_current())
    nx_callback(cbtn_guan_box, "on_click", "on_cbtn_box_click")
    nx_bind_script(cbtn_guan, nx_current())
    nx_callback(cbtn_guan, "on_checked_changed", "on_cbtn_sel_checked_changed")
    gb_guan.guan_id = guan_id
    cbtn_guan.guan_id = guan_id
    cbtn_guan_box.guan_id = guan_id
    local level = guan_ui_ini:ReadString(i - 1, "Level", "")
    gb_guan.level = level
    local str_sort = guan_ui_ini:ReadString(i - 1, "Sort", "")
    lbl_guan_sort.Text = get_desc_by_id(str_sort)
    lbl_guan_name.Text = get_desc_by_id(guan_ui_ini:ReadString(i - 1, "Name", ""))
    local tab_sort_info = util_split_string(str_sort, "_")
    local sort = nx_number(tab_sort_info[4])
    tab_sort[nx_string(sort)] = guan_id
    gb_guan.Top = (i - 1) * gb_guan.Height
    gb_guan.Left = 0
    local is_open = guan_ui_ini:ReadString(i - 1, "IsOpen", "1")
    gb_guan.is_open = nx_number(is_open)
    if is_open == "0" then
      lbl_open.Visible = true
    else
      lbl_open.Visible = false
    end
  end
  form.cbtn_guan_26.Checked = true
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
  guan_sift(0, form)
end
function init_week_award_btn_info(form, lv, guan_list, num, max_num)
  local tg_new_config = nx_execute("util_functions", "get_ini", TG_NEW_CONFIG)
  if not nx_is_valid(tg_new_config) then
    return
  end
  local sec_count = tg_new_config:FindSectionIndex("guan_lv")
  if sec_count < 0 then
    return
  end
  local count = nx_number(tg_new_config:GetSectionItemCount(sec_count))
  if nx_number(6) ~= nx_number(count) then
    return
  end
  local lv_str = tg_new_config:ReadString(sec_count, nx_string(lv), "")
  local cbtn_week = form.gb_tg:Find("cbtn_week_" .. nx_string(lv))
  local tip = util_split_string(lv_str)
  if nx_is_valid(cbtn_week) then
    local str
    if max_num <= num then
      str = nx_widestr(util_format_string("ui_tg_cuobai_tips_02", num, max_num))
    else
      str = nx_widestr(util_format_string("ui_tg_cuobai_tips_01", num, max_num))
    end
    for j = 1, table.getn(tip) do
      local temp = get_name_id_byindex(tip[j])
      local is_true = is_finish_guan_id(guan_list, tip[j])
      if is_true then
        str = nx_widestr(str) .. nx_widestr("<font color=\"#00FF00\">") .. nx_widestr(util_text(nx_string(temp))) .. nx_widestr("</font>") .. nx_widestr("<br>")
      else
        str = nx_widestr(str) .. nx_widestr(util_text(nx_string(temp))) .. nx_widestr("<br>")
      end
    end
    cbtn_week.HintText = nx_widestr(str)
  end
end
function is_finish_guan_id(str_source, str_dest)
  local id_list = util_split_string(str_source, ",")
  for i = 1, table.getn(id_list) do
    if nx_string(id_list[i]) == nx_string(str_dest) then
      return true
    end
  end
  return false
end
function get_name_id_byindex(index)
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(guan_ui_ini) then
    return
  end
  local sec_index_1 = guan_ui_ini:FindSectionIndex(nx_string(index))
  local name = ""
  if nx_int(index) >= nx_int(0) then
    name = guan_ui_ini:ReadString(sec_index_1, "Name", "")
  end
  return name
end
function get_desc_by_id(text_id)
  local gui = nx_value("gui")
  return gui.TextManager:GetText(nx_string(text_id))
end
function on_cbtn_box_click(self)
  if not nx_find_custom(self, "guan_id") then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_BOX_OPEN), 0, nx_int(self.guan_id))
  self.Checked = not self.Checked
end
function on_cbtn_sel_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_find_custom(cbtn, "guan_id") then
    return 0
  end
  if cbtn.Checked == true then
    if nx_int(form.guan_id_sel) ~= nx_int(cbtn.guan_id) then
      local gb_old = form.gpsb_guans:Find("gb_guan_" .. nx_string(form.guan_id_sel))
      if nx_is_valid(gb_old) then
        local cbtn_old = gb_old:Find("cbtn_guan_" .. nx_string(form.guan_id_sel))
        form.guan_id_sel = cbtn.guan_id
        cbtn_old.Checked = false
      else
        form.guan_id_sel = cbtn.guan_id
      end
      show_guan_info_form(form.guan_id_sel)
    end
  elseif nx_int(form.guan_id_sel) == nx_int(cbtn.guan_id) then
    cbtn.Checked = true
  end
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local auto_invite = get_danshua_auto_invite()
  on_close_select_boss_form()
  on_close_select_friend_form()
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_BEGIN, nx_number(form.cur_tiguan_level), auto_invite)
end
function on_cbtn_js_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked == true then
    if nx_int(form.cur_tiguan_level) ~= nx_int(cbtn.guuan_lv) then
      local gb_old = form.groupscrollbox_jingsu:Find("gb_js_" .. nx_string(form.cur_tiguan_level))
      if nx_is_valid(gb_old) then
        local cbtn_old = gb_old:Find("cbtn_js_" .. nx_string(form.cur_tiguan_level))
        form.cur_tiguan_level = cbtn.guuan_lv
        cbtn_old.Checked = false
      else
        form.cur_tiguan_level = cbtn.guuan_lv
      end
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_LEVEL_INFO, nx_number(cbtn.guuan_lv))
      form.boss_count_all = CalculateLevelGuanBossCount(form.cur_tiguan_level)
      refresh_attack_boss_times()
      refresh_arrest_info()
      refresh_arrest_desc(form)
    end
  elseif nx_int(form.cur_tiguan_level) == nx_int(cbtn.guuan_lv) then
    cbtn.Checked = true
  end
end
function refresh_arrest_desc(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local level = nx_number(form.cur_tiguan_level)
  if level < 1 or level > tiguan_level_max then
    return 0
  end
  if form.is_in_double ~= 0 then
    local html_text = gui.TextManager:GetText(arrest_boss_double_desc[nx_number(level)])
    form.mltbox_shuoming:Clear()
    form.mltbox_shuoming:AddHtmlText(html_text, -1)
    form.lbl_double_image.Visible = true
  else
    local html_text = gui.TextManager:GetText(arrest_boss_desc[nx_number(level)])
    form.mltbox_shuoming:Clear()
    form.mltbox_shuoming:AddHtmlText(html_text, -1)
    form.lbl_double_image.Visible = false
  end
end
function refresh_attack_boss_times()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  gui.TextManager:Format_SetIDName("ui_jibai")
  gui.TextManager:Format_AddParam(nx_string(guan_level_text[nx_number(form.cur_tiguan_level)]))
  gui.TextManager:Format_AddParam(nx_int(form.boss_count_all))
  gui.TextManager:Format_SetIDName("ui_mengyou_times")
  gui.TextManager:Format_AddParam(nx_int(form.friend_card_count))
  form.mltbox_friend_card:Clear()
  form.mltbox_friend_card:AddHtmlText(gui.TextManager:Format_GetText(), -1)
end
function CalculateLevelGuanBossCount(guan_level)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 0
  end
  local tiguan_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(tiguan_ini) then
    return 0
  end
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(guan_ui_ini) then
    return 0
  end
  local boss_count_all = 0
  local section_count = tiguan_ini:GetSectionCount()
  for i = 1, section_count do
    local Section = tiguan_ini:GetSectionByIndex(i - 1)
    local Level = tiguan_ini:ReadInteger(i - 1, "Level", 0)
    local guan_id = nx_string(Section)
    if nx_number(get_achieve_record(guan_id, "boss_value")) ~= 0 and nx_number(guan_level) == nx_number(Level) then
      boss_count_all = boss_count_all + CalculateGuanBossCount(guan_id)
    end
  end
  return boss_count_all
end
function set_achieve_record(guan_id, name, value)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  local array_name = "tiguan" .. nx_string(guan_id)
  local is_exist = common_array:FindArray(array_name)
  if not is_exist then
    common_array:AddArray(array_name, nx_current(), common_array_time, false)
  end
  common_array:RemoveChild(array_name, nx_string(name))
  common_array:AddChild(array_name, nx_string(name), value)
end
function get_achieve_record(guan_id, name)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return ""
  end
  local array_name = "tiguan" .. nx_string(guan_id)
  local is_exist = common_array:FindArray(array_name)
  if is_exist then
    local value = common_array:FindChild(array_name, nx_string(name))
    if value ~= nil then
      return value
    end
  end
  return ""
end
function CalculateGuanBossCount(guan_id)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 0
  end
  local ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(ui_ini) then
    return 0
  end
  guan_id = nx_string(guan_id)
  local boss_value = nx_number(get_achieve_record(guan_id, "boss_value"))
  local boss_count_all = 0
  if 0 < boss_value then
    local tiguan_manager = nx_value("tiguan_manager")
    if not nx_is_valid(tiguan_manager) then
      return 0
    end
    local boss_list = get_boss_id_list(nx_string(guan_id))
    if boss_list ~= nil then
      local boss_count = table.getn(boss_list)
      for i = 1, boss_count do
        local boss_id = nx_string(boss_list[i])
        local info = tiguan_manager:bit_and(nx_number(boss_value), 2 ^ i)
        if 0 < info then
          boss_count_all = boss_count_all + 1
        end
      end
    end
  end
  return boss_count_all
end
function on_btn_choice_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local select_boss_item_id = get_item_id_for_choice_boss(btn.guuan_lv)
  local item_count = goods_grid:GetItemCount(select_boss_item_id)
  if item_count <= 0 and 0 >= form.free_appoint and select_boss_item_id ~= "" then
    local item_name = gui.TextManager:GetText(select_boss_item_id)
    gui.TextManager:Format_SetIDName("ui_resethint2")
    gui.TextManager:Format_AddParam(nx_string(item_name))
    local text = gui.TextManager:Format_GetText()
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
  else
    local nguan_id = btn.Parent.guan_id
    local form_tiguan_choice_boss = util_show_form(FORM_TIGUAN_CHOICE_BOSS, true)
    if not nx_is_valid(form_tiguan_choice_boss) then
      return
    end
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_choice_boss", "show_choice_boss_info", btn.guuan_lv, nguan_id, form.free_appoint)
  end
end
function on_btn_invite_friend_click(btn)
  local form = btn.ParentForm
  form.gb_friend.Visible = not form.gb_friend.Visible
end
function hide_gb_friend()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.gb_friend.Visible = false
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  on_close_select_boss_form()
  on_close_select_friend_form()
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_BEGIN, nx_number(form.cur_tiguan_level), 0)
end
function show_guan_info_form(guan_id)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return
  end
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return
  end
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  local guan_share_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(guan_ui_ini) or not nx_is_valid(guan_share_ini) then
    return
  end
  local sec_index_1 = guan_ui_ini:FindSectionIndex(nx_string(guan_id))
  local sec_index_2 = guan_share_ini:FindSectionIndex(nx_string(guan_id))
  if nx_number(sec_index_1) < 0 or nx_number(sec_index_2) < 0 then
    return
  end
  local name_id = guan_ui_ini:ReadString(sec_index_1, "Name", "")
  form.lbl_guan_info_name.Text = nx_widestr(get_desc_by_id(name_id))
  local cdt_id = guan_share_ini:ReadString(sec_index_2, "MemberConditionID", "")
  form.lb_condition.Text = nx_widestr(get_desc_by_id(cdt_mgr:GetConditionDesc(nx_int(cdt_id))))
  if check_iscan_enter(cdt_id) then
    form.lb_condition.ForeColor = "255,0,128,0"
  else
    form.lb_condition.ForeColor = "255,255,0,0"
  end
  form.lbl_guan_info_photo.BackImage = get_guan_image(guan_id, 2)
  local location_id = guan_ui_ini:ReadString(sec_index_1, "Location", "")
  form.mltbox_guan_infO_pos.HtmlText = nx_widestr(get_desc_by_id(location_id))
  local desc1_id = guan_ui_ini:ReadString(sec_index_1, "DetailDesc1", "")
  form.mltbox_info_1.HtmlText = nx_widestr(get_desc_by_id(desc1_id))
  local desc2_id = guan_ui_ini:ReadString(sec_index_1, "DetailDesc2", "")
  form.mltbox_info_2.HtmlText = nx_widestr(get_desc_by_id(desc2_id))
  local desc3_id = guan_ui_ini:ReadString(sec_index_1, "DetailDesc3", "")
  form.mltbox_info_3.HtmlText = nx_widestr(get_desc_by_id(desc3_id))
  local friends_id = guan_ui_ini:ReadString(sec_index_1, "FriendGroup", "")
  form.grid_friend:ClearSelect()
  form.grid_friend:ClearRow()
  local friend_tab = util_split_string(friends_id, ",")
  local friend = "ui_tiguan_relation_friend"
  for i = 1, table.getn(friend_tab) do
    local name_id = FORCE_NAME .. nx_string(friend_tab[i])
    if i == 1 then
      friend = nx_widestr(util_text(friend)) .. nx_widestr(": ") .. nx_widestr(get_desc_by_id(name_id))
    else
      friend = nx_widestr(friend) .. nx_widestr("  ") .. nx_widestr(get_desc_by_id(name_id))
    end
  end
  if nx_int(0) == nx_int(table.getn(friend_tab)) then
    friend = nx_widestr(util_text("ui_tiguan_relation_friend")) .. nx_widestr(": ")
  end
  form.lbl_friend.Text = nx_widestr(friend)
  local enemys_id = guan_ui_ini:ReadString(sec_index_1, "EnemyGroup", "")
  form.grid_enemy:ClearSelect()
  form.grid_enemy:ClearRow()
  local enemy_tab = util_split_string(enemys_id, ",")
  local enemy = "ui_tiguan_relation_enemy"
  for i = 1, table.getn(enemy_tab) do
    local name_id = FORCE_NAME .. nx_string(enemy_tab[i])
    if i == 1 then
      enemy = nx_widestr(util_text(enemy)) .. nx_widestr(": ") .. nx_widestr(get_desc_by_id(name_id))
    else
      enemy = nx_widestr(enemy) .. nx_widestr("  ") .. nx_widestr(get_desc_by_id(name_id))
    end
  end
  if nx_int(0) == nx_int(table.getn(enemy_tab)) then
    enemy = nx_widestr(util_text("ui_tiguan_relation_enemy")) .. nx_widestr(": ")
  end
  form.lbl_enemy.Text = nx_widestr(enemy)
end
function check_iscan_enter(conditions_id)
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local cdt_tab = util_split_string(nx_string(conditions_id), ";")
  for i = 1, table.getn(cdt_tab) do
    if not cdt_mgr:CanSatisfyCondition(player, player, nx_int(cdt_tab[i])) then
      return false
    end
  end
  return true
end
function request_this_week_jingsu()
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_RANDOM, 0, 0)
end
function on_rbtn_main_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  if nx_int(1) == nx_int(rbtn.DataSource) then
    form.gb_tg.Visible = true
    form.gb_js.Visible = false
    form.gb_rank.Visible = false
    form.gb_store.Visible = false
  elseif nx_int(2) == nx_int(rbtn.DataSource) then
    form.gb_tg.Visible = false
    form.gb_js.Visible = true
    form.gb_rank.Visible = false
    form.gb_store.Visible = false
    form.gb_friend.Visible = false
  elseif nx_int(3) == nx_int(rbtn.DataSource) then
    form.gb_tg.Visible = false
    form.gb_js.Visible = false
    form.gb_rank.Visible = true
    form.gb_store.Visible = false
  elseif nx_int(5) == nx_int(rbtn.DataSource) then
    form.gb_tg.Visible = false
    form.gb_js.Visible = false
    form.gb_rank.Visible = false
    form.gb_store.Visible = true
  end
end
function on_rbtn_guan_lv_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local data = rbtn.DataSource
  guan_sift(data, form)
end
function guan_sift(data, form)
  local gsb = form.gpsb_guans
  gsb.IsEditMode = true
  local index = 0
  for i = 1, form.guan_count do
    local is_right = false
    local gb_guan_name = "gb_guan_"
    local guan_index = tab_sort[nx_string(i)]
    local gb_guan = gsb:Find(nx_string(gb_guan_name) .. nx_string(guan_index))
    if not nx_is_valid(gb_guan) then
      return
    end
    gb_guan.Visible = false
    if nx_int(gb_guan.level) == nx_int(data) then
      is_right = true
    end
    if nx_int(data) == nx_int(0) then
      is_right = true
    end
    if is_right and gb_guan.is_open == 1 then
      index = index + 1
      gb_guan.Visible = true
      gb_guan.Left = 0
      gb_guan.Top = (index - 1) * gb_guan.Height
    end
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
end
function on_btn_switch_guan_click(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = btn.ParentForm
  local guan_id = nx_number(form.guan_id_sel)
  if guan_id <= 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("30344"))
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local guan_name = gui.TextManager:GetText("ui_tiguan_name_" .. nx_string(guan_id))
  local text = gui.TextManager:GetFormatText("ui_tiguan_move", guan_name)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_SWITCH), nx_int(guan_id))
  end
end
function show_tiguan_count(type, switch, ...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.switch = nx_number(switch)
  if nx_number(type) == LOOK_INFO_WIN_GUAN then
    for i = 1, table.getn(arg) / 6 do
      local guan_id = nx_number(arg[i * 6 - 5])
      local entercount = nx_number(arg[i * 6 - 2])
      local todaysucceed = nx_number(arg[i * 6 - 1])
      local todayrepick = nx_number(arg[i * 6 - 0])
      updata_guan_info(form, guan_id, entercount, todaysucceed, todayrepick, switch)
    end
  elseif nx_number(type) == LOOK_INFO_WIN_GUAN then
    form.reccount = nx_number(form.reccount) + nx_number(table.getn(arg) / 6)
  end
  if form.switch == 1 then
    form.btn_switch_guan.Enabled = true
  else
    form.btn_switch_guan.Enabled = false
  end
end
function updata_guan_info(form, guan_id, entercount, todaysucceed, todayrepick, switch)
  if not nx_is_valid(form) then
    return
  end
  local gb_str = "gb_guan_" .. nx_string(guan_id)
  local gb_guan = form.gpsb_guans:Find(nx_string(gb_str))
  if not nx_is_valid(gb_guan) then
    return
  end
  local lbl_today_join = gb_guan:Find("lbl_today_join_" .. nx_string(guan_id))
  local lbl_today_success = gb_guan:Find("lbl_today_success_" .. nx_string(guan_id))
  local cbtn_guan_box = gb_guan:Find("cbtn_guan_box_" .. nx_string(guan_id))
  if nx_is_valid(lbl_today_join) and nx_is_valid(lbl_today_success) and nx_is_valid(cbtn_guan_box) then
    lbl_today_join.Text = nx_widestr(nx_string(entercount) .. nx_string("/") .. nx_string(gb_guan.limitcount))
    lbl_today_success.Text = nx_widestr(nx_string(todaysucceed) .. nx_string("/") .. nx_string(gb_guan.limitsucceed))
    if nx_number(todayrepick) == 1 then
      cbtn_guan_box.Checked = true
    elseif nx_int(todaysucceed) == nx_int(gb_guan.limitsucceed) then
      cbtn_guan_box.Enabled = true
    else
      cbtn_guan_box.Enabled = false
    end
  end
end
function on_cbtn_week_box_lost_capture(cbtn)
  local data = cbtn.DataSource
  local form = cbtn.ParentForm
  nx_execute("tips_game", "hide_tip", form)
  form.bShowTips = false
end
function on_cbtn_week_box_get_capture(cbtn)
  local data = cbtn.DataSource
end
function on_cbtn_week_click(cbtn)
  cbtn.Checked = not cbtn.Checked
  local data = cbtn.DataSource
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_BOX_OPEN), 1, nx_int(data))
end
function show_week_dang_info(lv, ...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local lbl_week = form.gb_tg:Find("lbl_week_" .. nx_string(lv))
  if not nx_is_valid(lbl_week) then
    return
  end
  local cbtn_week = form.gb_tg:Find("cbtn_week_" .. nx_string(lv))
  if not nx_is_valid(cbtn_week) then
    return
  end
  local count = arg[1]
  local aim_num = arg[2]
  local guan_id_str = nx_string(arg[3])
  local award_state = arg[4]
  if nx_int(count) > nx_int(aim_num) then
    count = aim_num
  end
  lbl_week.Text = nx_widestr(nx_string(count) .. nx_string("/") .. nx_string(aim_num))
  if nx_int(count) < nx_int(aim_num) then
    cbtn_week.Enabled = false
  else
    cbtn_week.Enabled = true
    if nx_int(1) == nx_int(award_state) then
      cbtn_week.Checked = true
    else
      cbtn_week.Checked = false
    end
  end
  init_week_award_btn_info(form, lv, guan_id_str, count, aim_num)
end
function show_rand_guan(arg)
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  local guan_share_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(guan_ui_ini) then
    return
  end
  if not nx_is_valid(guan_share_ini) then
    return
  end
  local lv_count = table.getn(arg) / 4
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.lv_count = lv_count
  local gsb = form.groupscrollbox_jingsu
  gsb:DeleteAll()
  for i = 1, lv_count do
    local gb_guan = create_ctrl("GroupBox", "gb_js_" .. nx_string(i), form.gb_jingsu, gsb)
    local lbl_js_bg2 = create_ctrl("Label", "lbl_guan_bg2_" .. nx_string(i), form.lbl_js_bg2, gb_guan)
    local lbl_js_bg1 = create_ctrl("Label", "lbl_guan_bg1_" .. nx_string(i), form.lbl_js_bg1, gb_guan)
    local lbl_js_sort = create_ctrl("Label", "lbl_js_sort_" .. nx_string(i), form.lbl_js_sort, gb_guan)
    local lbl_js_name = create_ctrl("Label", "lbl_js_name_" .. nx_string(i), form.lbl_js_name, gb_guan)
    local lbl_js_tj_dec = create_ctrl("Label", "lbl_js_tj_dec_" .. nx_string(i), form.lbl_js_tj_dec, gb_guan)
    local lbl_js_tongji = create_ctrl("Label", "lbl_js_tongji_" .. nx_string(i), form.lbl_js_tongji, gb_guan)
    local cbtn_js = create_ctrl("CheckButton", "cbtn_js_" .. nx_string(i), form.cbtn_js, gb_guan)
    local btn_js_boss_sel = create_ctrl("Button", "btn_js_boss_sel_" .. nx_string(i), form.btn_js_boss_sel, gb_guan)
    local guan_lv = arg[1 + 4 * (i - 1)]
    local guan_id = arg[2 + 4 * (i - 1)]
    local boss_index = arg[3 + 4 * (i - 1)]
    cbtn_js.guuan_lv = guan_lv
    cbtn_js.guan_id = guan_id
    gb_guan.guan_id = guan_id
    btn_js_boss_sel.guuan_lv = guan_lv
    btn_js_boss_sel.guan_id = guan_id
    lbl_js_tongji.guan_id = guan_id
    cbtn_js.bNotice = false
    gb_guan.Left = 0
    gb_guan.Top = (i - 1) * gb_guan.Height
    local sec_index_1 = guan_ui_ini:FindSectionIndex(nx_string(guan_id))
    local sec_index_2 = guan_share_ini:FindSectionIndex(nx_string(guan_id))
    lbl_js_bg1.BackImage = get_guan_image(guan_id, 3)
    lbl_js_bg2.Enabled = false
    lbl_js_name.Text = get_desc_by_id(guan_ui_ini:ReadString(sec_index_1, "Name", ""))
    lbl_js_sort.Text = nx_widestr(nx_string(i))
    lbl_js_tongji.Text = get_desc_by_id(get_boss_id(guan_id, boss_index))
    nx_bind_script(cbtn_js, nx_current())
    nx_callback(cbtn_js, "on_checked_changed", "on_cbtn_js_checked_changed")
    nx_bind_script(btn_js_boss_sel, nx_current())
    nx_callback(btn_js_boss_sel, "on_click", "on_btn_choice_click")
  end
  local gb_js = gsb:Find("gb_js_1")
  if nx_is_valid(gb_js) then
    local choose_js_cbtn = gb_js:Find("cbtn_js_1")
    if nx_is_valid(choose_js_cbtn) then
      choose_js_cbtn.Checked = true
    end
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
end
function show_tiguan_one_test()
  show_tiguan_one(14, 7, 1, 1)
end
function show_tiguan_one(type, ...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if not form.Visible then
    return 0
  end
  if nx_number(type) == SERVER_MSG_DS_RANK_INFO then
    local count = table.getn(arg)
    if count < 6 then
      return 0
    end
    refresh_rank_info(arg)
  elseif nx_number(type) == SERVER_MSG_DS_REGIST_RANK then
    if table.getn(arg) < 1 then
      return 0
    end
    form.rank_apply_guanid = nx_number(arg[1])
    refresh_rank_apply(form)
  elseif nx_number(type) == SERVER_MSG_DS_REGIST_NUM then
    if table.getn(arg) < 2 then
      return 0
    end
    refresh_rank_apply_persion_count(form, arg)
  elseif nx_number(type) == SERVER_MSG_DS_INIT_FORM then
    if table.getn(arg) < 11 then
      return 0
    end
    form.lbl_score.Text = nx_widestr(arg[3])
    if 0 < nx_number(arg[8]) then
    else
    end
    form.free_appoint = nx_number(arg[6])
    form.rank_apply_guanid = nx_number(arg[10])
    form.friend_card_count = nx_number(arg[12])
    if nx_widestr(arg[13]) ~= nx_widestr("") then
      form.btn_invite_friend.Text = nx_widestr(arg[13])
    end
    local join_num = nx_number(arg[15])
    local join_limit_num = nx_number(arg[16])
    form.lbl_js_joinNum.Text = nx_widestr(nx_string(join_num) .. nx_string("/") .. nx_string(join_limit_num))
  elseif nx_number(type) == SERVER_MSG_DS_ALTER_ALLY then
    if table.getn(arg) < 1 then
      return 0
    end
    form.btn_invite_friend.Text = nx_widestr(arg[1])
  elseif nx_number(type) == ERVER_MSG_DS_APPOINT_BOSS then
    if table.getn(arg) < 3 then
      return 0
    end
    local guan_id = nx_string(arg[1])
    local boss_index = nx_number(arg[2])
    form.free_appoint = nx_number(arg[3])
    for i = 1, form.lv_count do
      local gb_js = form.groupscrollbox_jingsu:Find("gb_js_" .. nx_string(i))
      if nx_is_valid(gb_js) then
        local lbl_js_tongji = gb_js:Find("lbl_js_tongji_" .. nx_string(i))
        if nx_number(lbl_js_tongji.guan_id) == nx_number(guan_id) then
          lbl_js_tongji.Text = get_desc_by_id(get_boss_id(guan_id, boss_index))
        end
      end
    end
  elseif nx_number(type) == SERVER_MSG_DS_BOSS_NOTE then
    if table.getn(arg) < 3 then
      return 0
    end
    local rows = 3
    local info_count = table.getn(arg) / rows
    for i = 1, info_count do
      local tiguan_id = nx_string(arg[1 + (i - 1) * rows])
      local boss_value = nx_number(arg[2 + (i - 1) * rows])
      local boss_appraise = nx_number(arg[3 + (i - 1) * rows])
      set_achieve_record(tiguan_id, "boss_value", boss_value)
      set_achieve_record(tiguan_id, "boss_appraise", boss_appraise)
    end
    form.boss_count_all = CalculateLevelGuanBossCount(form.cur_tiguan_level)
    refresh_attack_boss_times()
    refresh_arrest_info()
  elseif nx_number(type) == SERVER_MSG_DS_RANDOM_INFO then
    show_rand_guan(arg)
  elseif nx_number(type) == SERVER_MSG_DS_ARREST_INFO then
    if table.getn(arg) < 1 then
      return 0
    end
    local guan_level = nx_number(arg[1])
    if guan_level > tiguan_level_max then
      return 0
    end
    local info_count = (table.getn(arg) - 1) / 2
    for i = 1, info_count do
      local array_name = "tiguan_arrest" .. nx_string(guan_level)
      local child_name = "arrest_data" .. nx_string(i)
      local value = nx_string(arg[2 + (i - 1) * 2]) .. "," .. nx_string(arg[3 + (i - 1) * 2])
      set_tiguan_record(array_name, child_name, value)
    end
    refresh_arrest_info()
  end
end
function set_tiguan_record(array_name, child_name, value)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  array_name = nx_string(array_name)
  child_name = nx_string(child_name)
  local is_exist = common_array:FindArray(array_name)
  if not is_exist then
    common_array:AddArray(array_name, nx_current(), common_array_time, false)
  end
  common_array:RemoveChild(array_name, child_name)
  common_array:AddChild(array_name, child_name, value)
end
function refresh_arrest_info()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(ui_ini) then
    return 0
  end
  clear_arrest_info(form)
  local level = nx_number(form.cur_tiguan_level)
  if level < 1 or level > tiguan_level_max then
    return 0
  end
  form.mltbox_arrest1:Clear()
  form.mltbox_arrest2:Clear()
  for i = 1, tiguan_arrest_max do
    local html_text = nx_widestr("")
    local guan_name = nx_widestr("")
    local guan_id = nx_string(get_arrest_data(level, i, 1))
    local boss_id = nx_string(get_arrest_data(level, i, 2))
    if guan_id ~= "" and boss_id ~= "" then
      local index = ui_ini:FindSectionIndex(guan_id)
      if 0 <= index then
        guan_name = get_desc_by_id(ui_ini:ReadString(index, "Name", ""))
      end
      local boss_name = gui.TextManager:GetText(boss_id)
      local nBeComplete = 0
      for j = 1, tiguan_challenge_task_max do
        local array_name = "guan" .. nx_string(level) .. "sub" .. nx_string(j)
        local record_guan_id = nx_number(get_tiguan_record(array_name, "value1"))
        local record_boss_index = nx_number(get_tiguan_record(array_name, "value2"))
        local is_complete = nx_number(get_tiguan_record(array_name, "value7"))
        if record_guan_id == nx_number(guan_id) then
          local boss_id_temp = get_boss_id(record_guan_id, record_boss_index)
          if boss_id_temp == boss_id then
            nBeComplete = 1
            break
          end
        end
      end
      if nBeComplete == 1 then
        html_text = html_text .. nx_widestr("<font color=\"#6c5644\">") .. guan_name .. gui.TextManager:GetText("ui_tiaozhan_5") .. nx_widestr("</font>") .. nx_widestr("<font color=\"#8c2e0e\">") .. boss_name .. nx_widestr("</font>")
      else
        html_text = html_text .. guan_name .. gui.TextManager:GetText("ui_tiaozhan_5") .. boss_name
      end
      local boss_level_count = get_boss_arrest_level_by_id(guan_id, boss_id)
      for i = 1, boss_level_count do
        html_text = html_text .. nx_widestr("<img src=\"knife" .. "\" only=\"line\" valign=\"center\"/>")
      end
      if i <= 4 then
        form.mltbox_arrest1:AddHtmlText(html_text, -1)
      else
        form.mltbox_arrest2:AddHtmlText(html_text, -1)
      end
    end
  end
end
function get_boss_id(guan_id, boss_index)
  local ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(guan_id))
  local str_id = ini:ReadString(sec_index, "BossList", "")
  local id_tab = util_split_string(str_id, ";")
  if boss_index < 1 or boss_index > table.getn(id_tab) then
    return ""
  end
  return id_tab[boss_index]
end
function get_boss_id_list(guan_id)
  local ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(ini) then
    return nil
  end
  local sec_index = ini:FindSectionIndex(nx_string(guan_id))
  local str_id = ini:ReadString(sec_index, "BossList", "")
  return util_split_string(str_id, ";")
end
function get_boss_arrest_level_by_id(guan_id, boss_id)
  local ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(guan_id))
  if index < 0 then
    return 0
  end
  local boss_list = ini:ReadString(index, "BossList", "")
  local boss_tab = util_split_string(boss_list, ";")
  local boss_count = table.getn(boss_tab)
  local boss_index = 0
  for i = 1, boss_count do
    if nx_string(boss_tab[i]) == nx_string(boss_id) then
      boss_index = nx_number(i)
      break
    end
  end
  if boss_index ~= 0 then
    return get_boss_arrest_level(guan_id, boss_index)
  else
    return 0
  end
end
function get_boss_arrest_level(guan_id, boss_index)
  local ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(ini) then
    return ""
  end
  boss_index = nx_number(boss_index)
  local sec_index = ini:FindSectionIndex(nx_string(guan_id))
  local str_id = ini:ReadString(sec_index, "BossLevel", "")
  local level_tab = util_split_string(str_id, ",")
  if boss_index < 1 or boss_index > table.getn(level_tab) then
    return 0
  end
  return level_tab[boss_index]
end
function get_arrest_data(array_level, child_index, data_index)
  local str_data = get_tiguan_record("tiguan_arrest" .. nx_string(array_level), "arrest_data" .. nx_string(child_index))
  local data_tab = util_split_string(str_data, ",")
  local data_count = table.getn(data_tab)
  data_index = nx_number(data_index)
  if data_count < data_index or data_index <= 0 then
    return ""
  end
  return data_tab[data_index]
end
function get_tiguan_record(array_name, child_name)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return ""
  end
  array_name = nx_string(array_name)
  child_name = nx_string(child_name)
  local is_exist = common_array:FindArray(array_name)
  if is_exist then
    local value = common_array:FindChild(array_name, child_name)
    if value ~= nil then
      return value
    end
  end
  return ""
end
function clear_arrest_info(form)
  form.groupbox_tongji_quantou1.IsEditMode = true
  form.groupbox_tongji_quantou1:DeleteAll()
  form.groupbox_tongji_quantou1.IsEditMode = false
  form.groupbox_tongji_quantou2.IsEditMode = true
  form.groupbox_tongji_quantou2:DeleteAll()
  form.groupbox_tongji_quantou2.IsEditMode = false
end
function refresh_rank_info(arg)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 0
  end
  local tiguan_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(tiguan_ini) then
    return 0
  end
  local tiguan_award_ini = nx_execute("util_functions", "get_ini", SHARE_TIGUAN_AWARD_INI)
  if not nx_is_valid(tiguan_award_ini) then
    return 0
  end
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(guan_ui_ini) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local tiguan_one_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_ONE_INI)
  if not nx_is_valid(tiguan_one_ini) then
    return 0
  end
  local reward_index = tiguan_one_ini:FindSectionIndex("rank_reward")
  if reward_index < 0 then
    return 0
  end
  local title_index = tiguan_one_ini:FindSectionIndex("rank_title")
  if title_index < 0 then
    return 0
  end
  local msg_count = 9
  form.textgrid_rank:BeginUpdate()
  local count = table.getn(arg)
  if msg_count > count then
    return 0
  end
  local arg_count = nx_int(count / msg_count)
  local row_count = form.textgrid_rank.RowCount
  local row_index = row_count
  for i = 0, arg_count - 1 do
    local nIndex1 = tiguan_ini:FindSectionIndex(nx_string(arg[1 + i * msg_count]))
    local nLevel = tiguan_ini:ReadInteger(nIndex1, "Level", 0)
    local LevelName = get_desc_by_id(guan_danci_name[nx_number(nLevel)])
    local nIndex2 = guan_ui_ini:FindSectionIndex(nx_string(arg[1 + i * msg_count]))
    local GuanName = get_desc_by_id(guan_ui_ini:ReadString(nIndex2, "Name", ""))
    local award_section = "week_rank_" .. nx_string(arg[1 + i * msg_count])
    local nIndex3 = tiguan_award_ini:FindSectionIndex(award_section)
    local title_id = tiguan_award_ini:ReadInteger(nIndex3, "title", 0)
    local title_text = gui.TextManager:GetText("role_title_" .. title_id)
    local str_award_item = tiguan_award_ini:ReadString(nIndex3, "item", "")
    local award_item_list = util_split_string(nx_string(str_award_item), ",")
    local award_item_count = table.getn(award_item_list)
    local award_time_name = ""
    local award_item_id = ""
    if 0 < award_item_count then
      award_time_name = gui.TextManager:GetText(award_item_list[1])
      award_item_id = award_item_list[1]
    end
    local title_key = "guan" .. nx_string(arg[1 + i * msg_count])
    local title_pic_str = tiguan_one_ini:ReadString(title_index, title_key, "")
    local reward_key = "guan" .. nx_string(arg[1 + i * msg_count])
    local reward_pic_str = tiguan_one_ini:ReadString(reward_index, reward_key, "")
    form.textgrid_rank:InsertRow(-1)
    form.textgrid_rank:SetGridText(row_index, 0, nx_widestr(GuanName))
    form.textgrid_rank:SetGridText(row_index, 1, nx_widestr(LevelName))
    create_rank_apply_control(form, row_index, 2, arg[1 + i * msg_count])
    form.textgrid_rank:SetGridText(row_index, 3, nx_widestr(0))
    if nx_widestr(arg[2 + i * msg_count]) ~= nx_widestr("") then
      form.textgrid_rank:SetGridText(row_index, 4, nx_widestr(arg[2 + i * msg_count]))
    else
      form.textgrid_rank:SetGridText(row_index, 4, nx_widestr("--"))
    end
    create_rank_title_pic(form, row_index, 5, title_pic_str, title_text)
    if nx_number(arg[5 + i * msg_count]) ~= 0 then
      create_rank_grid_control(form, row_index, 6, reward_pic_str, nx_int(arg[5 + i * msg_count]), award_item_id)
    else
      form.textgrid_rank:SetGridText(row_index, 6, nx_widestr("--"))
    end
    if nx_number(arg[3 + i * msg_count]) ~= 0 then
      form.textgrid_rank:SetGridText(row_index, 7, nx_widestr(arg[3 + i * msg_count]))
    else
      form.textgrid_rank:SetGridText(row_index, 7, nx_widestr("--"))
    end
    if nx_number(arg[4 + i * msg_count]) ~= 0 then
      form.textgrid_rank:SetGridText(row_index, 8, nx_widestr(arg[4 + i * msg_count]))
    else
      form.textgrid_rank:SetGridText(row_index, 8, nx_widestr("--"))
    end
    if nx_number(arg[4 + i * msg_count]) >= 160 then
      form.can_apply = 1
    end
    create_rank_grid_control(form, row_index, 9, reward_pic_str, nx_int(arg[6 + i * msg_count]), award_item_id)
    form.textgrid_rank:SetGridText(row_index, 10, nx_widestr(arg[7 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 11, nx_widestr(nLevel))
    form.textgrid_rank:SetGridText(row_index, 12, nx_widestr(arg[1 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 13, nx_widestr(row_index))
    form.textgrid_rank:SetGridText(row_index, 14, nx_widestr(arg[5 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 15, nx_widestr(arg[6 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 16, nx_widestr(arg[8 + i * msg_count]))
    form.textgrid_rank:SetGridText(row_index, 17, nx_widestr(arg[9 + i * msg_count]))
    for j = 0, rank_col_count - 1 do
      form.textgrid_rank:SetGridForeColor(row_index, j, rank_default_fore_color)
    end
    if form.player_name == form.textgrid_rank:GetGridText(row_index, 2) then
      for j = 0, form.textgrid_rank.ColCount - 1 do
        form.textgrid_rank:SetGridForeColor(row_index, j, rank_player_fore_color)
      end
    end
    row_index = row_index + 1
  end
  refresh_rank_color(form)
  refresh_rank_apply(form)
  form.textgrid_rank:EndUpdate()
end
function create_rank_apply_control(form, row, col, guan_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Name = "groupbox_rank_apply_" .. nx_string(guan_id)
  local btn = gui:Create("Button")
  groupbox:Add(btn)
  btn.Name = "btn_rank_apply_crt" .. nx_string(guan_id)
  btn.Text = nx_widestr("    ") .. gui.TextManager:GetText(rank_apply_text_id_1)
  btn.ForeColor = form.btn_rank_apply_no.ForeColor
  btn.Font = form.btn_rank_apply_no.Font
  btn.Width = form.btn_rank_apply_no.Width
  btn.Height = form.btn_rank_apply_no.Height
  btn.Top = form.btn_rank_apply_no.Top
  btn.Left = form.btn_rank_apply_no.Left
  btn.NormalImage = form.btn_rank_apply_no.NormalImage
  btn.FocusImage = form.btn_rank_apply_no.FocusImage
  btn.PushImage = form.btn_rank_apply_no.PushImage
  btn.DisableImage = form.btn_rank_apply_no.DisableImage
  btn.DrawMode = form.btn_rank_apply_no.DrawMode
  btn.SelectColor = "0,0,0,0"
  btn.DataSource = nx_string(guan_id)
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "on_btn_rank_apply_click")
  if form.rank_apply_guanid == nx_number(guan_id) then
    btn.NormalImage = form.btn_rank_apply_yes.NormalImage
    btn.FocusImage = form.btn_rank_apply_yes.FocusImage
    btn.PushImage = form.btn_rank_apply_yes.PushImage
    btn.DisableImage = form.btn_rank_apply_yes.DisableImage
    btn.Text = nx_widestr("    ") .. gui.TextManager:GetText(rank_apply_text_id_2)
  end
  form.textgrid_rank:SetGridControl(row, col, groupbox)
end
function create_rank_title_pic(form, row, col, pic, title_text)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Name = "groupbox_rank_title_" .. nx_string(row)
  local grid_item = gui:Create("ImageGrid")
  groupbox:Add(grid_item)
  grid_item.Name = "imagegrid_rank_title_" .. nx_string(row)
  grid_item.BackImage = pic
  grid_item.Width = form.imagegrid_rank_title.Width
  grid_item.Height = form.imagegrid_rank_title.Height
  grid_item.Top = form.imagegrid_rank_title.Top
  grid_item.Left = form.imagegrid_rank_title.Left
  grid_item.DrawMode = form.imagegrid_rank_title.DrawMode
  grid_item.SelectColor = form.imagegrid_rank_title.SelectColor
  grid_item.MouseInColor = form.imagegrid_rank_title.MouseInColor
  grid_item.NoFrame = form.imagegrid_rank_title.NoFrame
  grid_item.title_text = title_text
  nx_bind_script(grid_item, nx_current())
  nx_callback(grid_item, "on_get_capture", "on_imagegrid_rank_title_item_get_capture")
  nx_callback(grid_item, "on_lost_capture", "on_imagegrid_rank_title_item_lost_capture")
  form.textgrid_rank:SetGridControl(row, col, groupbox)
end
function create_rank_grid_control(form, row, col, pic, count, item_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Name = "groupbox_rank_reward_" .. nx_string(row) .. "_" .. nx_string(col)
  local grid_item = gui:Create("ImageGrid")
  groupbox:Add(grid_item)
  grid_item.BackImage = pic
  grid_item.Width = form.imagegrid_rank_reward_item.Width
  grid_item.Height = form.imagegrid_rank_reward_item.Height
  grid_item.Top = form.imagegrid_rank_reward_item.Top
  grid_item.Left = form.imagegrid_rank_reward_item.Left
  grid_item.Name = "imagegrid_rank_reward_item_" .. nx_string(row) .. "_" .. nx_string(col)
  grid_item.DrawMode = form.imagegrid_rank_reward_item.DrawMode
  grid_item.SelectColor = form.imagegrid_rank_reward_item.SelectColor
  grid_item.MouseInColor = form.imagegrid_rank_reward_item.MouseInColor
  grid_item.NoFrame = form.imagegrid_rank_reward_item.NoFrame
  grid_item.item_id = item_id
  nx_bind_script(grid_item, nx_current())
  nx_callback(grid_item, "on_get_capture", "on_imagegrid_rank_reward_item_get_capture")
  nx_callback(grid_item, "on_lost_capture", "on_imagegrid_rank_reward_item_lost_capture")
  local label_name = gui:Create("Label")
  groupbox:Add(label_name)
  label_name.Width = form.lbl_rank_reward_name.Width
  label_name.Height = form.lbl_rank_reward_name.Height
  label_name.Top = form.lbl_rank_reward_name.Top
  label_name.Left = form.lbl_rank_reward_name.Left
  label_name.Text = nx_widestr("X") .. nx_widestr(count)
  label_name.ForeColor = form.lbl_rank_reward_name.ForeColor
  label_name.Name = "lbl_rank_reward_name"
  form.textgrid_rank:SetGridControl(row, col, groupbox)
end
function refresh_rank_color(form)
  local row_count = form.textgrid_rank.RowCount
  for i = 0, row_count - 1 do
    local guan_id = nx_number(form.textgrid_rank:GetGridText(i, rank_col_rule_guan_id))
    if form.rank_select_guanid == guan_id then
      for j = 0, form.textgrid_rank.ColCount - 1 do
        form.textgrid_rank:SetGridForeColor(i, j, rank_select_fore_color)
      end
    elseif form.player_name == form.textgrid_rank:GetGridText(i, rank_col_player_name) then
      for j = 0, form.textgrid_rank.ColCount - 1 do
        form.textgrid_rank:SetGridForeColor(i, j, rank_player_fore_color)
      end
    else
      for j = 0, form.textgrid_rank.ColCount - 1 do
        form.textgrid_rank:SetGridForeColor(i, j, rank_default_fore_color)
      end
      if form.rank_sort_col ~= -1 then
        form.textgrid_rank:SetGridForeColor(i, form.rank_sort_col, rank_select_fore_color)
      end
    end
    local groupbox1 = form.textgrid_rank:GetGridControl(i, rank_col_award_1)
    if nx_is_valid(groupbox1) then
      local lable_name = groupbox1:Find("lbl_rank_reward_name")
      local color = form.textgrid_rank:GetGridForeColor(i, rank_col_award_1)
      if nx_is_valid(lable_name) then
        lable_name.ForeColor = color
      end
    end
    local groupbox2 = form.textgrid_rank:GetGridControl(i, rank_col_next_week)
    if nx_is_valid(groupbox2) then
      local lable_name = groupbox2:Find("lbl_rank_reward_name")
      local color = form.textgrid_rank:GetGridForeColor(i, rank_col_next_week)
      if nx_is_valid(lable_name) then
        lable_name.ForeColor = color
      end
    end
  end
end
function refresh_rank_apply(form)
  local message_delay = nx_value("MessageDelay")
  if not nx_is_valid(message_delay) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  tm = os.date("*t", message_delay:GetServerSecond())
  local in_time = true
  if nx_number(tm.wday) == 2 and nx_number(tm.hour) >= 5 and nx_number(tm.hour) <= 6 then
    in_time = false
  end
  local row_count = form.textgrid_rank.RowCount
  for i = 0, row_count - 1 do
    local guan_id = nx_number(form.textgrid_rank:GetGridText(i, rank_col_rule_guan_id))
    local groupbox = form.textgrid_rank:GetGridControl(i, rank_col_apply_control)
    if nx_is_valid(groupbox) then
      local cbtn = groupbox:Find("btn_rank_apply_crt" .. nx_string(guan_id))
      if nx_is_valid(cbtn) then
        if in_time then
          cbtn.Enabled = true
        else
          cbtn.Enabled = false
        end
        if form.rank_apply_guanid == guan_id then
          cbtn.NormalImage = form.btn_rank_apply_yes.NormalImage
          cbtn.FocusImage = form.btn_rank_apply_yes.FocusImage
          cbtn.PushImage = form.btn_rank_apply_yes.PushImage
          cbtn.DisableImage = form.btn_rank_apply_yes.DisableImage
          cbtn.Text = nx_widestr("    ") .. gui.TextManager:GetText(rank_apply_text_id_2)
        else
          cbtn.NormalImage = form.btn_rank_apply_no.NormalImage
          cbtn.FocusImage = form.btn_rank_apply_no.FocusImage
          cbtn.PushImage = form.btn_rank_apply_no.PushImage
          cbtn.DisableImage = form.btn_rank_apply_no.DisableImage
          cbtn.Text = nx_widestr("    ") .. gui.TextManager:GetText(rank_apply_text_id_1)
        end
      end
    end
  end
end
function refresh_rank_apply_persion_count(form, arg)
  local arg_count = table.getn(arg)
  if arg_count < 2 then
    return 0
  end
  local count = nx_number(arg_count / 2)
  for i = 1, count do
    local guan_id = nx_number(arg[i * 2 - 1])
    local apply_count = nx_number(arg[i * 2])
    local row_count = form.textgrid_rank.RowCount
    for j = 0, row_count - 1 do
      local rank_guan_id = nx_number(form.textgrid_rank:GetGridText(j, rank_col_rule_guan_id))
      if nx_number(guan_id) == nx_number(rank_guan_id) then
        form.textgrid_rank:SetGridText(j, rank_col_apply_num, nx_widestr(apply_count))
      end
    end
  end
end
function on_btn_rank_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.textgrid_rank:ClearSelect()
  form.btn_rank_get.Enabled = false
  form.rank_select_guanid = -1
  if btn.click_times % 2 == 0 then
    form.textgrid_rank:SortRowsByInt(btn.sort_id, btn.bGreater)
    form.rank_sort_col = btn.colour_col
  else
    form.textgrid_rank:SortRowsByInt(btn.default_sort_id, false)
    form.rank_sort_col = -1
  end
  btn.click_times = btn.click_times + 1
  refresh_rank_color(form)
end
function on_textgrid_rank_select_row(self, row)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local get_text = form.textgrid_rank:GetGridText(row, rank_col_rule_is_get)
  if form.player_name == self:GetGridText(row, rank_col_player_name) and nx_number(get_text) == 0 then
    form.btn_rank_get.Enabled = true
  else
    form.btn_rank_get.Enabled = false
  end
  form.rank_select_guanid = nx_number(form.textgrid_rank:GetGridText(row, rank_col_rule_guan_id))
  refresh_rank_color(form)
end
function on_btn_rank_get_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local row = form.textgrid_rank.RowSelectIndex
  if 0 <= row then
    local guan_id = form.textgrid_rank:GetGridText(row, rank_col_rule_guan_id)
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_RANK_AWARD, nx_number(guan_id))
    btn.Enabled = false
    form.textgrid_rank:SetGridText(row, rank_col_rule_is_get, nx_widestr(1))
  end
end
function on_btn_rank_apply_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local apply_time_val = nx_number(os.time()) - form.rank_repeat_time
  if apply_time_val < 2 then
    local repeat_show_text = gui.TextManager:GetText("ui_rank_baoming8")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(repeat_show_text, 2)
    end
    return 0
  end
  form.rank_repeat_time = nx_number(os.time())
  local guan_id = nx_number(btn.DataSource)
  if nx_number(form.rank_apply_guanid) ~= guan_id then
    local applyer_1 = 40
    local applyer_2 = 50
    local guan_id = nx_number(btn.DataSource)
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return 0
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local apply_count = get_apply_count(form, guan_id)
    if applyer_2 <= nx_number(apply_count) then
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_APPLY_RANK, guan_id, 0)
    elseif applyer_1 <= nx_number(apply_count) then
      local text = gui.TextManager:GetText("ui_tiguan_rank_apply_2")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" then
        nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_APPLY_RANK, guan_id, 1)
      end
    else
      nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_APPLY_RANK, guan_id, 0)
    end
  else
    nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_CANCE_RANK, guan_id)
  end
end
function get_apply_count(form, guan_id)
  local apply_count = 0
  local row_count = form.textgrid_rank.RowCount
  for i = 0, row_count - 1 do
    local rank_guan_id = nx_number(form.textgrid_rank:GetGridText(i, rank_col_rule_guan_id))
    if guan_id == rank_guan_id then
      apply_count = nx_number(form.textgrid_rank:GetGridText(i, rank_col_apply_num))
      break
    end
  end
  return apply_count
end
function on_imagegrid_rank_reward_item_get_capture(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local x, y = gui:GetCursorPosition()
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(self.item_id)
    item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(self.item_id), "ItemType", "0")
    nx_execute("tips_game", "show_goods_tip", item, x, y, 40, 40, self.ParentForm)
  end
end
function on_imagegrid_rank_reward_item_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_imagegrid_rank_title_item_get_capture(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(self.title_text), x, y, 0, self.ParentForm)
end
function on_imagegrid_rank_title_item_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function add_store_form()
  local form_sub = nx_execute("util_gui", "util_get_form", FORM_ATTRIBUTE_MALL_TIGUAN, true, false)
  if not nx_is_valid(form_sub) then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.gb_store:Add(form_sub)
  form_sub.Top = 0
  form_sub.Left = 0
  form_sub.Visible = true
end
function add_friend_form()
  local form_sub = nx_execute("util_gui", "util_get_form", FORM_TIGUAN_FRIEND, true, false)
  if not nx_is_valid(form_sub) then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.gb_friend:Add(form_sub)
  form_sub.Top = 0
  form_sub.Left = 0
  form_sub.Visible = true
  form.gb_friend.Width = form_sub.Width
  form.gb_friend.Height = form_sub.Height
  form.gb_friend.Left = form.btn_invite_friend.Left + (form.btn_invite_friend.Width - form.gb_friend.Width) / 2
  form.gb_friend.Top = form.btn_invite_friend.Top - form.gb_friend.Height
end
function get_guan_image(guan_id, index)
  return "gui\\special\\tiguan\\tiguan_new\\" .. nx_string(guan_id) .. "_" .. nx_string(index) .. ".png"
end
function a(info)
  nx_msgbox(nx_string(info))
end
