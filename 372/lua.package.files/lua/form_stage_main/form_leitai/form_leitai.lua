require("util_gui")
require("define\\request_type")
require("share\\client_custom_define")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
local FORM_LEITAI = "form_stage_main\\form_leitai\\form_leitai"
local FORM_LEITAI_FILTER = "form_stage_main\\form_leitai\\form_world_leitai_filter"
local MAX_LEITAI_NAME_LEN = 18
local CLIENT_CUSTOMMSG_LEITAI_WAR = 758
local SUB_MSG_LEITAI_CREATE = 3
local SUB_MSG_LEITAI_JOIN = 4
local CLIENT_SUBMSG_LEITAI_RULE = 6
local FUNC_TYPE_ZHIMING_SET = 0
local FUNC_TYPE_ZHIMING_GET = 1
local FUNC_TYPE_WORLD_SET = 2
local FUNC_TYPE_WORLD_GET = 3
local FUNC_TYPE_COMMON = 4
local FUNC_TYPE_RANDOM = 5
local FUNC_TYPE_WUDOU = 6
local WORLD_LEITAI_PLAYER_REVENGE = 1
local LEITAI_RULE_COMMON = 0
local LEITAI_RULE_RANDOM = 1
local LEITAI_RULE_REVENGE = 2
local LEITAI_RULE_WUDOU = 3
function main_form_init(form)
  form.Fixed = false
  form.npc_id = 0
  form.func_type = 0
  form.select_lv = -1
  form.is_player_revenge = -1
  form.revenge_player_name = ""
  form.stake_limit = 10000000
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.mltbox_desc.HtmlText = gui.TextManager:GetText("ui_find_player_desc")
  form.mltbox_desc.Height = form.mltbox_desc:GetContentHeight() + 2
  form.groupbox_introduce.Height = form.mltbox_desc.Top + form.mltbox_desc.Height
  form.btn_wager.Visible = false
  form.btn_score_condition.Visible = false
  form.select_rule = 0
  form.rbtn_mode_1.Visible = false
  form.rbtn_mode_2.Visible = false
  form.rbtn_mode_3.Visible = false
  form.rbtn_mode_4.Visible = false
end
function init_revenge_dialog_control(self)
  local form = self.ParentForm
  form.is_player_revenge = WORLD_LEITAI_PLAYER_REVENGE
  form.func_type = FUNC_TYPE_WORLD_SET
  local gui = nx_value("gui")
  form.lbl_name.Text = gui.TextManager:GetText("ui_revenge_dialog_title")
  form.combobox_mode.Visible = false
  form.lbl_9.Visible = false
  form.btn_search.Visible = false
  form.btn_score_condition.Enabled = false
  form.lbl_request_name.Text = nx_widestr(form.revenge_player_name)
  adjust_form_by_config(form, LEITAI_RULE_REVENGE)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local func_type = form.func_type
  if func_type == FUNC_TYPE_WORLD_SET or func_type == FUNC_TYPE_COMMON or func_type == FUNC_TYPE_RANDOM or func_type == FUNC_TYPE_WUDOU then
    if not create_leitai(form) then
      return
    end
  elseif func_type == FUNC_TYPE_WORLD_GET then
    join_leitai()
  elseif func_type == FUNC_TYPE_ZHIMING_SET then
    requester_invite_player()
  end
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form_relationship) then
    form_relationship:Close()
  end
  local form_tvt_info = nx_value("form_stage_main\\form_tvt\\form_tvt_info")
  if nx_is_valid(form_tvt_info) then
    form_tvt_info:Close()
  end
  close_child_dialog()
  form:Close()
end
function close_child_dialog()
  local form_leitai_filter = nx_value(FORM_LEITAI_FILTER)
  if nx_is_valid(form_leitai_filter) and form_leitai_filter.Visible then
    form_leitai_filter:Close()
  end
end
function on_btn_wager_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local old_form = nx_value("form_stage_main\\form_leitai\\form_leitai_gamble")
  if nx_is_valid(old_form) then
    nx_destroy(old_form)
  end
  local wager_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_gamble", true)
  wager_form.leitai_wager_npc_id = form.npc_id
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_leitai\\form_leitai_gamble", true)
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  close_child_dialog()
  form:Close()
end
function on_btn_find_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_leitai\\form_leitai_invite_list")
end
function on_cbtn_stake_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.ipt_ding.Text = ""
  form.ipt_liang.Text = ""
  form.ipt_wen.Text = ""
  if cbtn.Checked then
    form.groupbox_stake.Visible = true
  else
    form.groupbox_stake.Visible = false
  end
end
function on_ipt_changed(ipt)
  local text = nx_string(ipt.Text)
  if string.find(text, "%D") then
    text = string.gsub(text, "%D", "")
    ipt.Text = nx_widestr(text)
  end
end
function open_form_by_func_type(func_type, npc_id, ...)
  local form = nx_value(FORM_LEITAI)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_auto_show_hide_form", FORM_LEITAI)
  if func_type == FUNC_TYPE_ZHIMING_SET then
    local gui = nx_value("gui")
    form.ipt_name.Text = gui.TextManager:GetText("ui_zhimingleitai")
    form.ipt_name.ReadOnly = true
    form.lbl_wager_text.Visible = false
    form.cbtn_wager.Visible = false
    form.btn_score_condition.Visible = false
    form.combobox_mode.Visible = false
    form.lbl_9.Visible = false
    form.cbtn_stake.Visible = false
    form.lbl_stake_text.Visible = false
    form.groupbox_stake.Visible = false
    form.func_type = FUNC_TYPE_ZHIMING_SET
  elseif func_type == FUNC_TYPE_WORLD_SET then
    form.groupbox_invite.Visible = false
    form.func_type = FUNC_TYPE_COMMON
  elseif func_type == FUNC_TYPE_WORLD_GET then
    form.groupbox_invite.Visible = false
    freeze_control(form.groupbox_setting)
    form.npc_id = npc_id
    form.func_type = func_type
  elseif func_type == FUNC_TYPE_COMMON then
    form.groupbox_invite.Visible = false
    form.func_type = func_type
  elseif func_type == FUNC_TYPE_RANDOM then
    form.groupbox_invite.Visible = false
    form.func_type = func_type
  elseif func_type == FUNC_TYPE_WUDOU then
    form.groupbox_invite.Visible = false
    form.func_type = func_type
  end
  resize_form(form, func_type)
  init_mode_list(form)
  if func_type == FUNC_TYPE_WORLD_GET then
    init_form_by_server_info(arg)
  end
  if not is_open_dubo() then
    form.cbtn_wager.Visible = false
    form.cbtn_stake.Visible = false
    form.lbl_wager_text.Visible = false
    form.lbl_stake_text.Visible = false
    form.ipt_ding.Visible = false
    form.ipt_liang.Visible = false
    form.ipt_wen.Visible = false
    form.lbl_ding.Visible = false
    form.lbl_liang.Visible = false
    form.lbl_wen.Visible = false
    form.btn_wager.Visible = false
  end
end
function freeze_control(container)
  if not container.IsContainer then
    return
  end
  local control_list = container:GetChildControlList()
  local control_num = table.getn(control_list)
  for i = 1, control_num do
    local control = control_list[i]
    if control.IsContainer then
      freeze_control(control)
    else
      control.Enabled = false
    end
  end
end
function resize_form(form, func_type)
  local adjust_height = 50
  if func_type == FUNC_TYPE_WORLD_SET or func_type == FUNC_TYPE_WORLD_GET or func_type == FUNC_TYPE_COMMON or func_type == FUNC_TYPE_RANDOM or func_type == FUNC_TYPE_WUDOU then
    local bottom = form.groupbox_introduce.Top + form.groupbox_introduce.Height
    form.Height = bottom + adjust_height
    form.lbl_bg_main.Height = bottom - 13
  elseif func_type == FUNC_TYPE_ZHIMING_SET or func_type == FUNC_TYPE_ZHIMING_GET then
    local bottom = form.groupbox_invite.Top + form.groupbox_invite.Height
    form.Height = bottom + adjust_height - 15
    form.lbl_bg_main.Height = bottom - 28
  end
end
function create_leitai(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(player_obj) then
    return false
  end
  local name = form.ipt_name.Text
  if nx_int(string.len(nx_string(nx_widestr(name)))) > nx_int(MAX_LEITAI_NAME_LEN) then
    local text = gui.TextManager:GetText("9959")
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return false
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return false
  end
  if not CheckWords:CheckChinese(nx_widestr(name)) then
    local gui = nx_value("gui")
    local text = util_text("ui_SecondName_error")
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return false
  end
  if not CheckWords:CheckBadWords(nx_widestr(name)) then
    local gui = nx_value("gui")
    local text = util_text("ui_senseword_error")
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return false
  end
  local game_visual = nx_value("game_visual")
  local player_visual = game_visual:GetSceneObj(player_obj.Ident)
  if not nx_is_valid(player_visual) then
    return false
  end
  if not nx_find_custom(player_visual, "state") then
    return false
  end
  if player_visual.state ~= "static" and player_visual.state ~= "motion" then
    local text = gui.TextManager:GetText("82209")
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return false
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local name, item, wager, stake, stake_count = get_leitai_param()
    if not check_leitai_stake(form) then
      return false
    end
    if nx_ws_length(name) == 0 then
      name = gui.TextManager:GetText("LeitaiAnyWhereNpc01")
    end
    if form.is_player_revenge == WORLD_LEITAI_PLAYER_REVENGE then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(SUB_MSG_LEITAI_CREATE), nx_int(LEITAI_RULE_REVENGE), nx_widestr(name), item, wager, stake, stake_count, nx_widestr(form.revenge_player_name))
    else
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(SUB_MSG_LEITAI_CREATE), nx_int(form.select_rule), nx_widestr(name), item, wager, stake, stake_count, nx_int(form.select_lv))
    end
  end
  return true
end
function join_leitai()
  local form = nx_value(FORM_LEITAI)
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_stake.Checked then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if nx_is_valid(dialog) then
      local gui = nx_value("gui")
      dialog.mltbox_info:Clear()
      dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_world_stake_confirm"))
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "cancel" then
        return
      end
    end
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(SUB_MSG_LEITAI_JOIN), form.npc_id, 2)
  end
end
function requester_invite_player()
  form = nx_value(FORM_LEITAI)
  local gui = nx_value("gui")
  local invite_player_name = form.lbl_request_name.Text
  if invite_player_name == nil or nx_string(invite_player_name) == "" then
    local text = gui.TextManager:GetText("82085")
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(player_obj) then
    return
  end
  if player_obj:QueryProp("LeiTaiCurPlayerState") ~= 1 then
    local text = gui.TextManager:GetText("82086")
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return
  end
  nx_execute("custom_sender", "custom_request", PLAYER_REQUESTTYPE_LEITAI_PK, invite_player_name)
  send_leitai_rule()
end
function get_leitai_param()
  local form = nx_value(FORM_LEITAI)
  if not nx_is_valid(form) then
    return 0, 0, 0
  end
  local name, item, wager, stake, stake_count = "", 0, 0, 0, 0
  name = form.ipt_name.Text
  if form.cbtn_item.Checked then
    item = 1
  end
  if form.cbtn_wager.Checked then
    wager = 1
  end
  if form.cbtn_stake.Checked then
    stake = 1
    local money_wen = form.ipt_wen.Text
    local money_liang = form.ipt_liang.Text
    local money_ding = form.ipt_ding.Text
    stake_count = nx_int(money_wen) + nx_int(money_liang) * 1000 + nx_int(money_ding) * 1000 * 1000
  end
  return name, item, wager, stake, stake_count
end
function init_form_by_server_info(arg)
  if table.getn(arg) < 4 then
    return
  end
  local form = nx_value(FORM_LEITAI)
  if not nx_is_valid(form) then
    return
  end
  local name = arg[1]
  local item = arg[2]
  local wager = arg[3]
  local rule_index = arg[4]
  local have_stake = arg[5]
  local stake = arg[6]
  form.select_rule = rule_index
  form.ipt_name.Text = nx_widestr(name)
  adjust_form_by_config(form, rule_index)
  if item == 1 then
    form.cbtn_item.Checked = true
    form.cbtn_item.DisableImage = form.cbtn_item.CheckedImage
  end
  if wager == 1 then
    form.cbtn_wager.Checked = true
    form.cbtn_wager.DisableImage = form.cbtn_wager.CheckedImage
    form.btn_wager.Visible = true
  end
  if have_stake == 1 then
    form.cbtn_stake.Checked = true
    form.cbtn_stake.DisableImage = form.cbtn_stake.CheckedImage
    local ding = nx_int(stake / 1000000)
    local temp = nx_int(stake - ding * 1000000)
    local liang = nx_int(temp / 1000)
    local wen = nx_int(temp - liang * 1000)
    form.ipt_ding.Text = nx_widestr(ding)
    form.ipt_liang.Text = nx_widestr(liang)
    form.ipt_wen.Text = nx_widestr(wen)
    form.groupbox_stake.Visible = true
  end
end
function send_leitai_rule()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local name, item, wager, stake, stake_count = get_leitai_param()
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_LEITAI_RULE), item, wager, stake, stake_count)
  end
end
function init_mode_list(form)
  form.rbtn_mode_1.Visible = false
  form.rbtn_mode_2.Visible = false
  form.rbtn_mode_3.Visible = false
  form.rbtn_mode_4.Visible = false
  local func_type = form.func_type
  if func_type == FUNC_TYPE_ZHIMING_SET or func_type == FUNC_TYPE_ZHIMING_GET then
    return
  end
  if func_type == FUNC_TYPE_COMMON then
    form.select_rule = LEITAI_RULE_COMMON
  elseif func_type == FUNC_TYPE_RANDOM then
    form.select_rule = LEITAI_RULE_RANDOM
  elseif func_type == FUNC_TYPE_WUDOU then
    form.select_rule = LEITAI_RULE_WUDOU
  end
  adjust_form_by_config(form, form.select_rule)
end
function on_btn_score_condition_click(btn)
  local form = btn.ParentForm
  nx_execute("util_gui", "util_show_form", FORM_LEITAI_FILTER, true)
end
function adjust_form_by_config(form, rule_index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local LeiTaiRewardManager = nx_value("leitai_reward_manager")
  if not nx_is_valid(LeiTaiRewardManager) then
    return
  end
  local rule_info = LeiTaiRewardManager:GetWorldLeiTaiRuleInfo(nx_int(rule_index))
  if #rule_info < 6 then
    return
  end
  rule_name = rule_info[1]
  mode = rule_info[2]
  use_item = rule_info[3]
  can_wager = rule_info[4]
  can_stake = rule_info[5]
  form.stake_limit = rule_info[6]
  if nx_int(mode) == nx_int(LEITAI_RULE_RANDOM) then
    form.btn_score_condition.Visible = true
  else
    form.btn_score_condition.Visible = false
  end
  if nx_int(mode) == nx_int(LEITAI_RULE_REVENGE) then
    form.rbtn_mode_1.Enabled = false
    form.rbtn_mode_2.Enabled = false
    form.rbtn_mode_3.Enabled = false
    form.rbtn_mode_4.Enabled = false
  end
  if nx_int(use_item) == nx_int(0) then
    form.cbtn_item.Visible = false
    form.lbl_item_text.Visible = false
  else
    form.cbtn_item.Visible = true
    form.lbl_item_text.Visible = true
  end
  if nx_int(can_wager) == nx_int(0) then
    form.cbtn_wager.Visible = false
    form.lbl_wager_text.Visible = false
  else
    form.cbtn_wager.Visible = true
    form.lbl_wager_text.Visible = true
    if nx_int(mode) == nx_int(LEITAI_RULE_WUDOU) then
      form.cbtn_wager.Left = 32
      form.lbl_wager_text.Left = 50
    else
      form.cbtn_wager.Left = 179
      form.lbl_wager_text.Left = 197
    end
  end
  if nx_int(can_stake) == nx_int(0) then
    form.cbtn_stake.Visible = false
    form.lbl_stake_text.Visible = false
  else
    form.cbtn_stake.Visible = true
    form.lbl_stake_text.Visible = true
    if nx_int(mode) == nx_int(LEITAI_RULE_WUDOU) then
      form.lbl_stake_text.Text = util_text("ui_find_wudou")
    else
      form.lbl_stake_text.Text = util_text("ui_find_stake")
    end
  end
  form.groupbox_stake.Visible = false
  form.mltbox_desc.HtmlText = gui.TextManager:GetText("ui_mode_desc_" .. nx_string(rule_name))
  form.mltbox_desc.Height = form.mltbox_desc:GetContentHeight() + 2
  form.groupbox_introduce.Height = form.mltbox_desc.Top + form.mltbox_desc.Height
  local bottom = form.groupbox_introduce.Top + form.groupbox_introduce.Height
  if form.groupbox_invite.Visible then
    form.groupbox_invite.Top = bottom
    bottom = bottom + form.groupbox_invite.Height
  end
  form.Height = bottom + 50
  form.lbl_bg_main.Height = bottom - 13
end
function check_leitai_stake(form)
  if not form.cbtn_stake.Checked then
    return true
  end
  local money_limit = form.stake_limit
  local money_wen = form.ipt_wen.Text
  local money_liang = form.ipt_liang.Text
  local money_ding = form.ipt_ding.Text
  local cur_wager_money = nx_int(money_wen) + nx_int(money_liang) * 1000 + nx_int(money_ding) * 1000 * 1000
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_silver = client_player:QueryProp("CapitalType2")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_int64(cur_wager_money) <= nx_int64(0) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("82223"), 2)
    end
    return false
  elseif nx_int64(cur_wager_money) > nx_int64(money_limit) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("82222"), 2)
    end
    return false
  elseif nx_number(player_silver) < nx_number(cur_wager_money) then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("82224"), 2)
    end
    return false
  end
  return true
end
function on_btn_search_click(btn)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_invite_list", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function set_requester_name(name)
  local form = nx_value(FORM_LEITAI)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_request_name.Text = nx_widestr(name)
end
function leitai_apply(expenses)
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.mltbox_info:Clear()
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_shengsilei_baoming", expenses))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_leitai_apply")
  end
end
function is_open_dubo()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  return switch_manager:CheckSwitchEnable(ST_FUNCTION_LEITAI_DUBO)
end
