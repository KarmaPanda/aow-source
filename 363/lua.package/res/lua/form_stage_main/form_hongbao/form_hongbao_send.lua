require("util_gui")
require("custom_sender")
require("util_functions")
require("tips_data")
require("form_stage_main\\form_chat_system\\chat_util_define")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_hongbao\\form_hongbao_send"
local FORM_CHAT = "form_stage_main\\form_main\\form_main_chat"
local FORM_CHAT_WINDOW = "form_stage_main\\form_chat_system\\form_chat_window"
local POWER_NUM = 27
PLAYER_GROUP_CHAT_REC = "player_group_chat_rec"
player_group_rec_groupid = 0
player_group_rec_groupname = 1
local money_min = 10000
local money_max = 5000000
local money = 0
local num = 1
local rule = 1
local vip = 1
local power = 0
local chanel_and_group = 0
local bless = ""
local group_id = 0
local position = 0
local wish_num = 25
function main_form_init(self)
  self.Fixed = false
  self.is_chat_gtoup = true
end
function open_form()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_int(client_player:QueryProp("StallState")) == nx_int(2) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_send_failed_baitan"), 2)
    end
    return
  end
  local is_exchange = client_player:QueryProp("IsExchange")
  if nx_int(is_exchange) ~= nx_int(0) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_send_failed_jiaoyi"), 2)
    end
    return
  end
  if client_player:FindProp("LogicState") then
    local logic_state = client_player:QueryProp("LogicState")
    if nx_int(logic_state) == nx_int(1) then
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_send_failed_zhandou"), 2)
      end
      return
    end
  end
  if client_player:FindProp("LogicState") then
    local logic_state = client_player:QueryProp("LogicState")
    if nx_int(logic_state) == nx_int(120) then
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_send_failed_siwang"), 2)
      end
      return
    end
  end
  if client_player:FindProp("LogicState") then
    local logic_state = client_player:QueryProp("LogicState")
    if nx_int(logic_state) == nx_int(121) then
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_send_failed_zhongshang"), 2)
      end
      return
    end
  end
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
    form:Show()
  else
    util_show_form(FORM_NAME, true)
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  default_send_way()
  guild_hongbao_condition(self, false)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  clear_send_choose()
  nx_destroy(self)
end
function on_btn_close_1_click(btn)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_2_click(btn)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_send_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    local enable = switch_manager:CheckSwitchEnable(ST_FUNCTION_NEWPACKET)
    if not nx_boolean(enable) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      local gui = nx_value("gui")
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_close"), 2)
      return
    end
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local number = form.ipt_number
  local money_ding = form.ipt_ding
  local money_liang = form.ipt_liang
  local money_wen = form.ipt_wen
  local wish = form.ipt_wish
  local pin = form.rbtn_random
  local normal = form.rbtn_normal
  local lbl_money = form.lbl_money_num
  local lbl_fail = form.lbl_fail
  num = number.Text
  bless = form.combobox_wish.Text
  local temp_money
  local is_pin = true
  if pin.Checked then
    is_pin = true
    money = nx_number(money_ding.Text) * 1000000 + nx_number(money_liang.Text) * 1000 + nx_number(money_wen.Text)
  elseif normal.Checked then
    is_pin = false
    money = nx_number(money_ding.Text) * 1000000 + nx_number(money_liang.Text) * 1000 + nx_number(money_wen.Text)
  end
  local temp_money = 0
  if is_pin then
    temp_money = money
  else
    temp_money = nx_number(money) * nx_number(num)
  end
  if not is_value_money(temp_money) and not is_value_num(num) then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_limit_tip3"), 2)
    end
    clear_ipt()
    return
  end
  if not is_value_num(num) then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_limit_tip2"), 2)
    end
    clear_ipt()
    return
  end
  if not is_value_money(nx_number(temp_money)) then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_limit_tip1"), 2)
    end
    clear_ipt()
    return
  end
  if lbl_fail.Visible then
    lbl_fail.Visible = false
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_limit_tip4"), 2)
    end
    clear_ipt()
    return
  end
  if not check_channel_valid(chanel_and_group, form) then
    return
  end
  if nx_number(chanel_and_group) == 0 and not panel_confirm() then
    return
  end
  custom_send_newpacket(money, num, rule, vip, power, chanel_and_group, bless, group_id, position)
  clear_ipt()
end
function on_btn_record_click(btn)
  custom_see_getrecord()
end
function default_send_way()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local lbl_tips = form.lbl_tips
  lbl_tips.Visible = false
  form.groupbox_limit_guild.Visible = false
  form.groupbox_limit_school.Visible = false
  form.groupbox_limit_group.Visible = false
  local wish_text = form.ipt_wish
  wish_text.Text = nx_widestr(util_text("ui_hongbao_send_wishdesc"))
  local choose_tip = form.choose_1
  choose_tip.Text = nx_widestr(util_text("ui_hongbao_send"))
  local chanel = form.rbtn_channel
  local pin = form.rbtn_random
  local ding_str = nx_widestr(util_text("ui_ding"))
  local liang_str = nx_widestr(util_text("ui_liang"))
  local wen_str = nx_widestr(util_text("ui_wen"))
  chanel.Checked = true
  pin.Checked = true
  form.lbl_fail.Visible = false
  form.lbl_money_num.Text = nx_widestr(nx_number(0)) .. nx_widestr(ding_str) .. nx_widestr(nx_number(0)) .. nx_widestr(liang_str) .. nx_widestr(nx_number(0)) .. nx_widestr(wen_str)
  local vip_1 = form.combobox_vip_1
  vip_1.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_vip")))
  vip_1.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_no_vip")))
  vip_1.Text = nx_widestr(util_text("ui_hongbao_vip"))
  local power_1 = form.combobox_powerlevel_1
  for i = 1, POWER_NUM do
    if i < 10 then
      local temp_name = "desc_title00"
      temp_name = temp_name .. nx_string(i)
      power_1.DropListBox:AddString(nx_widestr(util_text(temp_name)))
    else
      local temp_name = "desc_title0"
      temp_name = temp_name .. nx_string(i)
      power_1.DropListBox:AddString(nx_widestr(util_text(temp_name)))
    end
  end
  power_1.Text = nx_widestr(util_text("desc_title001"))
  local zhiwei = form.combobox_zhiwei
  zhiwei.DropListBox:AddString(nx_widestr(util_text("ui_guild_pos_level8_name")))
  zhiwei.DropListBox:AddString(nx_widestr(util_text("ui_guild_pos_level7_name")))
  zhiwei.DropListBox:AddString(nx_widestr(util_text("ui_guild_pos_level6_name")))
  zhiwei.DropListBox:AddString(nx_widestr(util_text("ui_guild_pos_level5_name")))
  zhiwei.DropListBox:AddString(nx_widestr(util_text("ui_guild_pos_level4_name")))
  zhiwei.DropListBox:AddString(nx_widestr(util_text("ui_guild_pos_level3_name")))
  zhiwei.DropListBox:AddString(nx_widestr(util_text("ui_guild_pos_level2_name")))
  zhiwei.DropListBox:AddString(nx_widestr(util_text("ui_guild_pos_level1_name")))
  zhiwei.Text = nx_widestr(util_text("ui_guild_pos_level8_name"))
  local wish_com = form.combobox_wish
  for i = 1, wish_num do
    local temp_name = "ui_hongbao_send_wishdesc_"
    temp_name = temp_name .. nx_string(i - 1)
    wish_com.DropListBox:AddString(nx_widestr(util_text(temp_name)))
  end
  wish_com.Text = nx_widestr(util_text("ui_hongbao_send_wishdesc_0"))
  local form_chat_window = nx_value(FORM_CHAT_WINDOW)
  if nx_is_valid(form_chat_window) then
    form.rbtn_group.Checked = form_chat_window.Visible
  end
end
function on_combobox_wish_selected(self)
end
function on_ipt_changed(self)
  money_change_show(self)
end
function money_change_show(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local money_ding = form.ipt_ding
  local money_liang = form.ipt_liang
  local money_wen = form.ipt_wen
  local pin = form.rbtn_random
  local normal = form.rbtn_normal
  local temp_num = form.ipt_number.Text
  local temp = 0
  local lbl_money = form.lbl_money_num
  local lbl_tips = form.lbl_tips
  local lbl_fail = form.lbl_fail
  if pin.Checked then
    temp = nx_number(money_ding.Text) * 1000000 + nx_number(money_liang.Text) * 1000 + nx_number(money_wen.Text)
    show_tips(temp, temp_num, lbl_tips, lbl_fail, lbl_money)
    local wen = nx_number(money_wen.Text)
    local ding = nx_number(money_ding.Text)
    local liang = nx_number(money_liang.Text)
    show_money_num(ding, liang, wen, lbl_money)
  elseif normal.Checked then
    temp = (nx_number(money_ding.Text) * 1000000 + nx_number(money_liang.Text) * 1000 + nx_number(money_wen.Text)) * nx_number(temp_num)
    show_tips(temp, temp_num, lbl_tips, lbl_fail, lbl_money)
    local wen = nx_number(math.fmod(temp, 1000))
    local ding = nx_number(math.floor(temp / 1000000))
    local liang = nx_number(math.fmod(temp - wen, 1000000) / 1000)
    show_money_num(ding, liang, wen, lbl_money)
  end
end
function on_rbtn_random_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  money_change_show(btn)
  if btn.Checked then
    local pin = form.lbl_pin
    local total = form.lbl_total
    local single = form.lbl_single
    pin.Visible = true
    total.Visible = true
    single.Visible = false
    rule = 1
  else
    rule = 0
  end
end
function on_rbtn_normal_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  money_change_show(btn)
  if btn.Checked then
    local pin = form.lbl_pin
    local total = form.lbl_total
    local single = form.lbl_single
    pin.Visible = false
    total.Visible = false
    single.Visible = true
  end
end
function on_rbtn_channel_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if self.Checked then
    local choose_tip = form.choose_1
    choose_tip.Text = nx_widestr(util_text("ui_hongbao_send"))
    chanel_and_group = 0
    group_id = 0
    form.combobox_1.DropListBox:ClearString()
    local chanel = form.combobox_1
    chanel.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_chanael_world")))
    chanel.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_chanael_menpai")))
    chanel.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_chanael_yinshi")))
    chanel.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_chanael_menyin")))
    chanel.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_chanael_guild")))
    chanel.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_chanael_tuandui")))
    chanel.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_chanael_duiwu")))
    chanel.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_chanael_shili")))
    chanel.Text = nx_widestr(util_text("ui_hongbao_chanael_world"))
  end
end
function on_rbtn_group_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if self.Checked then
    local choose_tip = form.choose_1
    choose_tip.Text = nx_widestr(util_text("ui_hongbao_send_group"))
    chanel_and_group = 8
    group_id = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, 0, player_group_rec_groupid)
    form.combobox_1.DropListBox:ClearString()
    local chanel = form.combobox_1
    chanel.Text = ""
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not client_player:FindRecord(PLAYER_GROUP_CHAT_REC) then
      return false
    end
    local rows = client_player:GetRecordRows(PLAYER_GROUP_CHAT_REC)
    for i = 0, rows - 1 do
      local group_name = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, i, player_group_rec_groupname)
      chanel.DropListBox:AddString(nx_widestr(nx_string(group_name)))
    end
    chanel.Text = nx_widestr(nx_string(client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, 0, player_group_rec_groupname)))
  end
end
function on_combobox_1_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_channel.Checked then
    chanel_and_group = self.DropListBox.SelectIndex
    if nx_number(chanel_and_group) == nx_number(4) then
      guild_hongbao_condition(form, true)
    else
      guild_hongbao_condition(form, false)
    end
  elseif form.rbtn_group.Checked then
    chanel_and_group = 8
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local index = self.DropListBox.SelectIndex
    group_id = client_player:QueryRecord(PLAYER_GROUP_CHAT_REC, index, player_group_rec_groupid)
  end
end
function on_combobox_vip_1_selected(self)
  if self.Text == nx_widestr(util_text("ui_hongbao_no_vip")) then
    vip = 0
  else
    vip = 1
  end
end
function on_combobox_powerlevel_1_selected(self)
  power = self.DropListBox.SelectIndex
end
function on_combobox_zhiwei_selected(self)
  position = self.DropListBox.SelectIndex
end
function clear_ipt()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local lbl_tip = form.lbl_tips
  local ipt_ding = form.ipt_ding
  local ipt_liang = form.ipt_liang
  local ipt_wen = form.ipt_wen
  local ipt_num = form.ipt_number
  ipt_ding.Text = ""
  ipt_liang.Text = ""
  ipt_wen.Text = ""
  ipt_num.Text = ""
  if nx_string(ipt_ding.Text) == "" and nx_string(ipt_liang.Text) == "" and nx_string(ipt_wen.Text) == "" and nx_string(ipt_num.Text) == "" then
    lbl_tip.Visible = false
  end
end
function is_value_money(money)
  if nx_number(money) < money_min or nx_number(money) > money_max then
    return false
  end
  return true
end
function is_value_num(num)
  if nx_number(num) < 2 or nx_number(num) > 50 then
    return false
  end
  return true
end
function show_tips(money, num, lbl_tips, lbl_fail, lbl_money)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local number = form.ipt_number
  local money_ding = form.ipt_ding
  local money_liang = form.ipt_liang
  local money_wen = form.ipt_wen
  if nx_string(number.Text) ~= "" and (nx_string(money_ding.Text) ~= "" or nx_string(money_liang.Text) ~= "" or nx_string(money_wen.Text) ~= "") then
    lbl_tips.Visible = true
  end
  if not is_value_money(money) then
    lbl_tips.Text = nx_widestr(util_text("ui_hongbao_limit_tip1"))
  end
  if not is_value_num(num) then
    lbl_tips.Text = nx_widestr(util_text("ui_hongbao_limit_tip2"))
  end
  if not is_value_money(money) and not is_value_num(num) then
    lbl_tips.Text = nx_widestr(util_text("ui_hongbao_limit_tip3"))
  end
  if is_value_money(money) and is_value_num(num) then
    lbl_tips.Text = ""
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital1 = client_player:QueryProp("CapitalType2")
  if money > capital1 / 1.05 then
    lbl_fail.Visible = true
    lbl_money.ForeColor = "255, 255, 0, 0"
  else
    lbl_fail.Visible = false
    lbl_money.ForeColor = "255, 255, 255, 255"
  end
end
function panel_confirm()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if not nx_is_valid(dialog) then
    return false
  end
  local text = nx_widestr(util_text("ui_hongbao_send_pindao_tip1"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" == res then
    return true
  end
  return false
end
function show_money_num(ding, liang, wen, lbl_money)
  local ding_str = nx_widestr(util_text("ui_ding"))
  local liang_str = nx_widestr(util_text("ui_liang"))
  local wen_str = nx_widestr(util_text("ui_wen"))
  local money_text = ""
  if 0 < ding then
    money_text = nx_widestr(ding) .. nx_widestr(ding_str)
  end
  if 0 < liang then
    money_text = nx_widestr(money_text) .. nx_widestr(liang) .. nx_widestr(liang_str)
  end
  if 0 < wen then
    money_text = nx_widestr(money_text) .. nx_widestr(wen) .. nx_widestr(wen_str)
  end
  lbl_money.Text = money_text
end
function channel_send_condition_changed(form, channel)
  local lbl_condition = form.lbl_vip_1
  local combox_condition = form.combobox_vip_1
  if nx_number(channel) == nx_number(0) or nx_number(channel) == nx_number(5) or nx_number(channel) == nx_number(6) then
    lbl_condition.Text = nx_widestr(util_text("ui_viptime"))
    combox_condition.DropListBox:ClearString()
    combox_condition.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_no_vip")))
    combox_condition.DropListBox:AddString(nx_widestr(util_text("ui_hongbao_vip")))
    combox_condition.Text = nx_widestr(util_text("ui_hongbao_no_vip"))
  elseif nx_number(channel) == nx_number(1) or nx_number(channel) == nx_number(2) or nx_number(channel) == nx_number(3) then
    lbl_condition.Text = nx_widestr("\201\237\183\221\207\222\214\198")
    combox_condition.DropListBox:ClearString()
    combox_condition.DropListBox:AddString(nx_widestr("1"))
    combox_condition.DropListBox:AddString(nx_widestr("2"))
    combox_condition.Text = nx_widestr("1")
  elseif nx_number(channel) == nx_number(4) then
    lbl_condition.Text = nx_widestr("\214\176\206\187\207\222\214\198")
    combox_condition.DropListBox:ClearString()
    combox_condition.DropListBox:AddString(nx_widestr("3"))
    combox_condition.DropListBox:AddString(nx_widestr("4"))
    combox_condition.Text = nx_widestr("3")
  end
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
    if guild ~= "" then
      return true
    end
  end
  return false
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
function have_new_school_prop()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local school = client_player:QueryProp("NewSchool")
  if client_player:FindProp("NewSchool") then
    local school = client_player:QueryProp("NewSchool")
    if school ~= "" then
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
function check_channel_valid(channnel, form)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_number(channnel) == nx_number(1) then
    if not have_school_prop() and nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_pindao_failed_menpai"), 2)
      return false
    end
  elseif nx_number(channnel) == nx_number(2) then
    if not have_new_school_prop() and nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_pindao_failed_yinshi"), 2)
      return false
    end
  elseif nx_number(channnel) == nx_number(4) then
    if not have_guild_prop() and nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_pindao_failed_banghui"), 2)
      return false
    end
  elseif nx_number(channnel) == nx_number(5) then
    if nx_int(-1) == nx_int(get_teamtype_prop()) and nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_pindao_failed_tuandui"), 2)
      return false
    end
  elseif nx_number(channnel) == nx_number(6) then
    if not have_teamid_prop() and nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_pindao_failed_duiwu"), 2)
      return false
    end
  elseif nx_number(channnel) == nx_number(7) and not have_force_prop() and nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_hongbao_pindao_failed_shili"), 2)
    return false
  end
  return true
end
function guild_hongbao_condition(form, is_show)
  form.lbl_zhiwei.Visible = is_show
  form.lbl_back_zhiwei.Visible = is_show
  form.combobox_zhiwei.Visible = is_show
end
function clear_send_choose()
  chanel_and_group = 0
  vip = 1
  rule = 1
  power = 0
  position = 0
end
