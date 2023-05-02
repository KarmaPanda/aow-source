require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\client_custom_define")
require("form_stage_main\\form_attribute_mall\\form_attribute_shop")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
require("form_stage_main\\form_tvt\\define")
local SUB_CUSTOMMSG_SAVE_EQUIP_PLANE = 1
local SUB_CUSTOMMSG_SAVE_CHANNELS_PLANE = 2
local SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_DATA = 10
local SUB_CUSTOMMSG_NORMAL_TO_CROSS = 60
local SUB_CUSTOMMSG_EQUIP_PLANE = 13
local SUB_CUSTOMMSG_CHANNELS_PLANE = 14
local SUB_CUSTOM_WUXUE_BY_DAY = 16
local CLIENT_SUB_WEEKGOAL_INFO = 515
local FORM_BALANCE = "form_stage_main\\form_battlefield\\form_battlefield_balance"
local balance_file = "share\\War\\BalanceWar\\balance_war.ini"
local max_level = "share\\War\\BalanceWar\\balance_war_ui_neigong_maxlevel.ini"
local channels_file = "share\\War\\BalanceWar\\balance_war_ui_jingmai.ini"
local neigong_file = "share\\War\\BalanceWar\\balance_war_ui_neigong.ini"
local menpai_lg = "share\\War\\BalanceWar\\balance_war_menpai_logo.ini"
local skill_file = "share\\War\\BalanceWar\\balance_war_ui_skill.ini"
local FILE_SKILL_INI = "share\\Skill\\skill_new.ini"
local balance_war_name = "ui_balance_war_name_"
local unable_image = "gui\\special\\battlefiled_balance\\choose_forbid.png"
local hinttext = "tips_balance_jingmai_stop_click"
colour_table = {
  "255,201,88,81",
  "255,152,160,205",
  "255,186,151,114",
  "255,153,153,153",
  "255,233,192,80",
  "255,163,202,68"
}
jm_name_table = {
  "ui_balance_jm_shoutaiyin",
  "ui_balance_jm_shoutaiyin_ni",
  "ui_balance_jm_shoushaoyang",
  "ui_balance_jm_shoushaoyang_ni",
  "ui_balance_jm_shoutaiyang",
  "ui_balance_jm_shoutaiyang_ni",
  "ui_balance_jm_zushaoyin",
  "ui_balance_jm_zushaoyin_ni",
  "ui_balance_jm_zujueyin",
  "ui_balance_jm_zujueyin_ni",
  "ui_balance_jm_zutaiyin",
  "ui_balance_jm_zutaiyin_ni",
  "ui_balance_jm_zushaoyang",
  "ui_balance_jm_zushaoyang_ni",
  "ui_balance_jm_zuyangming",
  "ui_balance_jm_zuyangming_ni",
  "ui_balance_jm_shouyangming",
  "ui_balance_jm_shouyangming_ni"
}
menpai_name_table = {
  "balance_menpai_shaolin",
  "balance_menpai_wudang",
  "balance_menpai_emei",
  "balance_menpai_gaibang",
  "balance_menpai_junzitang",
  "balance_menpai_tangmen",
  "balance_menpai_jinyiwei",
  "balance_menpai_jilegu",
  "balance_menpai_mingjiao",
  "balance_menpai_damopai",
  "balance_menpai_xishanumu",
  "balance_menpai_shenshuigong",
  "balance_menpai_changfengbiaoju",
  "balance_menpai_huashanpai",
  "balance_menpai_nianluoba",
  "balance_menpai_xuedaotang",
  "balance_menpai_wuxianjiao",
  "balance_menpai_shenjiying"
}
local EQUIP_RECORD = "BalanceWarEquip"
local CHANNELS_RECORD = "BalanceWarChannels"
local CUSTOM_EQUIP_INDEX = 1
local CUSTOM_WUQI_INDEX = 2
local CUSTOM_SHANGYI_INDEX = 3
local MAX_CHANNELS_NUM = 8
local TOTAL_CHANNELS_NUM = 18
local NEIGONG_NUM = 18
local LINE_NUM = 2
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_BALANCE_CROSS_WAR) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local is_in_balance_war = player:QueryProp("BalanceWarIsInWar")
  if nx_int(is_in_balance_war) == nx_int(1) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_balance_war_enable_open")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local form = nx_value(FORM_BALANCE)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_BALANCE, true)
  end
end
function main_form_init(self)
  self.Fixed = false
  self.plane = 1
  self.channels_plane = 1
  self.channels_str = ""
  self.default_equip = ""
  self.default_channels = ""
  self.equip_index = 0
  self.wuqi_index = 0
  self.shangyi_index = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  self.rbtn_ready.Checked = true
  init_join_condition_info(self)
  self.rbtn_equip_plane_1.Checked = true
  init_jingmai_grid(self)
  self.rbtn_channels_1.Checked = true
  self.rbtn_7.Checked = true
  self.day = 1
  init_neigong_grid(self)
  init_prize_grid(self)
  self.rbtn_exchange_1.Checked = true
  self.rbtn_current_score.Checked = true
  custom_request_balance_war_data()
  custom_request_balance_weekgoal_info()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_set_click(btn)
  nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "open_form")
end
function on_rbtn_child_form_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_widestr("rbtn_ready") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = true
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = false
    form.groupbox_wuxuestar.Visible = false
    form.groupbox_neigong.Visible = false
    form.groupbox_rank.Visible = false
    form.groupbox_exchange.Visible = false
  elseif nx_widestr("rbtn_equip") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = true
    form.groupbox_channels.Visible = false
    form.groupbox_wuxuestar.Visible = false
    form.groupbox_neigong.Visible = false
    form.groupbox_rank.Visible = false
    form.groupbox_exchange.Visible = false
  elseif nx_widestr("rbtn_channels") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = true
    form.groupbox_wuxuestar.Visible = false
    form.groupbox_neigong.Visible = false
    form.groupbox_rank.Visible = false
    form.groupbox_exchange.Visible = false
  elseif nx_widestr("rbtn_wuxuestar") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = false
    form.groupbox_wuxuestar.Visible = true
    form.groupbox_neigong.Visible = false
    form.groupbox_rank.Visible = false
    form.groupbox_exchange.Visible = false
  elseif nx_widestr("rbtn_neigong") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = false
    form.groupbox_wuxuestar.Visible = false
    form.groupbox_neigong.Visible = true
    form.groupbox_rank.Visible = false
    form.groupbox_exchange.Visible = false
  elseif nx_widestr("rbtn_rank") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = false
    form.groupbox_wuxuestar.Visible = false
    form.groupbox_neigong.Visible = false
    form.groupbox_rank.Visible = true
    form.groupbox_exchange.Visible = false
  elseif nx_widestr("rbtn_exchange") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = false
    form.groupbox_wuxuestar.Visible = false
    form.groupbox_neigong.Visible = false
    form.groupbox_rank.Visible = false
    form.groupbox_exchange.Visible = true
  end
end
function on_btn_entre_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_entre_cross_war()
  form:Close()
end
function on_rbtn_equip_plane_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.plane = rbtn.DataSource
  custom_request_equip_plane(nx_int(rbtn.DataSource))
end
function on_rbtn_equip_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.equip_index = rbtn.DataSource
end
function on_rbtn_wuqi_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.wuqi_index = rbtn.DataSource
end
function on_rbtn_shangyi_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.shangyi_index = rbtn.DataSource
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_save_equip_plane(form)
end
function on_rbtn_channels_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_cbtn_enabled_true()
  set_cover_lbl_visible_true()
  form.channels_plane = rbtn.DataSource
  if nx_int(form.channels_plane) ~= nx_int(3) then
    form.btn_channels_save.Visible = false
    set_cbtn_enabled_false()
  else
    form.btn_channels_save.Visible = true
    set_cover_lbl_visible_false()
  end
  if nx_int(form.channels_plane) ~= nx_int(3) then
    channels_default_set()
  else
    custom_request_chennels_plane(nx_int(rbtn.DataSource))
  end
end
function on_btn_channels_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  get_player_select_channels()
  local temp_table = util_split_string(form.channels_str, ";")
  local count = table.getn(temp_table)
  if nx_int(count - 1) ~= nx_int(MAX_CHANNELS_NUM) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_channels_1"), 2)
    end
    return
  end
  custom_save_channelsplane(form)
end
function on_imagegrid_jm_mod_get_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "jingmai_id") then
    return
  end
  if not nx_find_custom(grid, "static_data") then
    return
  end
  local jingmai_id = grid.jingmai_id
  local jingmai = nx_execute("tips_game", "get_tips_ArrayList")
  jingmai.ConfigID = nx_string(jingmai_id)
  jingmai.ItemType = 1003
  jingmai.Level = 216
  jingmai.StaticData = nx_int(grid.static_data)
  local x = grid.AbsLeft
  local y = grid.AbsTop
  nx_execute("tips_game", "show_goods_tip", jingmai, x, y, 32, 32, form, false)
end
function on_imagegrid_jm_mod_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_rbtn_wuxue_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.day = nx_int(rbtn.DataSource)
  custom_request_wuxue_by_day(form.day)
end
function on_rbtn_current_score_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
end
function on_imagegrid_mod_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "neigong_config") then
    return
  end
  if not nx_find_custom(grid, "static_data") then
    return
  end
  local neigong_config = grid.neigong_config
  local ng_level, buff_level, wu_xing = get_neigong_max_level(nx_string(neigong_config))
  local neigong = nx_execute("tips_game", "get_tips_ArrayList")
  neigong.ConfigID = nx_string(neigong_config)
  neigong.ItemType = 1002
  neigong.Level = nx_int(ng_level)
  neigong.MaxLevel = nx_int(ng_level)
  neigong.StaticData = nx_int(grid.static_data)
  neigong.BufferLevel = nx_int(buff_level)
  neigong.WuXing = nx_int(wu_xing)
  local x = grid.AbsLeft
  local y = grid.AbsTop
  nx_execute("tips_game", "show_goods_tip", neigong, x, y, 32, 32, form, false)
end
function on_imagegrid_mod_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_rbtn_exchange_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local data_type = nx_int(rbtn.DataSource)
  open_mall_by_group(form, data_type)
end
function on_btn_rank_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_rank_path = "form_stage_main\\form_rank\\form_rank_main"
  local form_rank = nx_value(form_rank_path)
  if not nx_is_valid(form_rank) then
    form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_rank\\form_rank_main", true, false)
  end
  if not nx_is_valid(form_rank) then
    return
  end
  form_rank:Show()
  form_rank.Visible = true
  local rank_name = util_text("rank_7_balance_war")
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form_rank, rank_name)
end
function on_rbtn_day_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local wuxue_id = nx_string(rbtn.DataSource)
  local form_wuxue = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_wuxue\\form_wuxue", true, false)
  if nx_is_valid(form_wuxue) then
    form_wuxue:Show()
  end
  local form_wuxue_skill = form_wuxue:Find("form_stage_main\\form_wuxue\\form_wuxue_skill")
  if not nx_is_valid(form_wuxue_skill) then
    return
  end
  form_wuxue_skill.cbtn_1.Checked = true
  local tree = form_wuxue_skill.tree_types
  if not nx_is_valid(tree) then
    return nil
  end
  local select_node = get_taolu_node(tree, wuxue_id)
  if select_node == nil then
    return
  end
  tree.SelectNode = select_node
end
function get_taolu_node(tree, strWuXuw)
  local root = tree.RootNode
  local tree_node_list = root:GetNodeList()
  for i = 1, #tree_node_list do
    local node = tree_node_list[i]
    local sub_node_list = node:GetNodeList()
    for j = 1, #sub_node_list do
      local sub_node = sub_node_list[j]
      if nx_string(sub_node.type_name) == nx_string(strWuXuw) then
        return sub_node
      end
    end
  end
  return nil
end
function on_imagegrid_skill_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local strTaolu = grid.taolu_id
  if nx_string(strTaolu) == "" or nx_string(strTaolu) == nil then
    return
  end
  local strSkill = get_taolu_prop(strTaolu, 2)
  local skill_list = util_split_string(strSkill, ";")
  local skill_id = skill_list[index + 1]
  if nx_string(skill_id) == "" then
    return
  end
  local staticdata = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, skill_id, "StaticData", "")
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(skill_id)
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(staticdata)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function custom_save_equip_plane(form)
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_SAVE_EQUIP_PLANE), nx_int(form.plane), nx_int(form.equip_index), nx_int(form.wuqi_index), nx_int(form.shangyi_index))
end
function custom_save_channelsplane(form)
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_SAVE_CHANNELS_PLANE), nx_int(form.channels_plane), nx_string(form.channels_str))
end
function custom_entre_cross_war()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_NORMAL_TO_CROSS))
end
function custom_request_balance_weekgoal_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_WEEKGOAL_INFO))
end
function custom_request_balance_war_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_BALANCE_WAR_DATA))
end
function custom_request_equip_plane(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_EQUIP_PLANE), nx_int(index))
end
function custom_request_chennels_plane(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_CHANNELS_PLANE), nx_int(index))
end
function custom_request_wuxue_by_day(day)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOM_WUXUE_BY_DAY), nx_int(day))
end
function rec_balance_war_equip_data(...)
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  local argNum = table.getn(arg)
  if nx_int(argNum) < nx_int(3) then
    return
  end
  local equip_index = nx_int(arg[1])
  local wuqi_index = nx_int(arg[2])
  local shangyi_index = nx_int(arg[3])
  if nx_int(equip_index) <= nx_int(0) or nx_int(wuqi_index) <= nx_int(0) or nx_int(shangyi_index) <= nx_int(0) then
    local default_equip_list = util_split_string(form.default_equip, ";")
    local list_count = table.getn(default_equip_list)
    if nx_int(list_count) < nx_int(form.plane) then
      return
    end
    local select_plane = ""
    if nx_int(form.plane) == nx_int(1) then
      select_plane = default_equip_list[1]
    elseif nx_int(form.plane) == nx_int(2) then
      select_plane = default_equip_list[2]
    elseif nx_int(form.plane) == nx_int(3) then
      select_plane = default_equip_list[3]
    end
    local temp_list = util_split_string(select_plane, ",")
    local temp_list_count = table.getn(temp_list)
    if nx_int(temp_list_count) ~= nx_int(4) then
      return
    end
    equip_index = nx_int(temp_list[2])
    wuqi_index = nx_int(temp_list[3])
    shangyi_index = nx_int(temp_list[4])
  end
  find_select_rbtn(equip_index, wuqi_index, shangyi_index)
end
function rec_balance_war_channels_data(...)
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  local argNum = table.getn(arg)
  if nx_int(argNum) ~= nx_int(8) then
    channels_default_set()
    return
  end
  for i = 1, 8 do
    if nx_int(arg[i]) <= nx_int(0) or nx_int(arg[i]) > nx_int(TOTAL_CHANNELS_NUM) then
      channels_default_set()
      return
    end
  end
  local channels_str = ""
  for i = 1, 8 do
    channels_str = channels_str .. nx_string(arg[i])
    if i ~= 8 then
      channels_str = channels_str .. nx_string(";")
    end
  end
  reflash_select_channels(channels_str)
end
function rec_balance_war_data(...)
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  local argNum = table.getn(arg)
  if nx_int(argNum) < nx_int(5) then
    return
  end
  local balance_score = nx_int(arg[1])
  get_level_from_score(form, balance_score)
  form.lbl_value.Text = nx_widestr(nx_string(balance_score))
  form.lbl_month_join.Text = nx_widestr(arg[2])
  local day_join_time = nx_int(arg[6])
  form.lbl_today_join.Text = nx_widestr(nx_string(arg[3]) .. nx_string("/") .. nx_string(day_join_time))
  local win_ratio = arg[4] * 100
  local str_ratio = string.format("%0.2f", win_ratio)
  form.lbl_win_ratio.Text = nx_widestr(str_ratio) .. nx_widestr("%")
  form.lbl_20.Text = nx_widestr(nx_string(nx_int(arg[7])))
  form.lbl_18.Text = nx_widestr(nx_string(nx_int(arg[8])))
  if nx_int(0) < nx_int(arg[9]) and nx_int(arg[9]) < nx_int(101) then
    form.lbl_21.Text = nx_widestr(nx_string(nx_int(arg[9])))
  else
    form.lbl_21.Text = nx_widestr(util_text("ui_gudian2_shp_037"))
  end
  form.lbl_current_rank.Text = nx_widestr(util_text(nx_string(balance_war_name) .. nx_string(arg[5])))
end
function rec_balance_wuxue_data_by_day(...)
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  local nDay = nx_int(arg[1])
  local wuxue_data = nx_string(arg[2])
  local wuxue_data_list = util_split_string(wuxue_data, ",")
  local wuxue_count = table.getn(wuxue_data_list)
  if nx_int(wuxue_count) <= nx_int(0) then
    return
  end
  form.groupscrollbox_3:DeleteAll()
  local refer_gbox = form.groupbox_detia
  if not nx_is_valid(refer_gbox) then
    return
  end
  for i = 1, wuxue_count do
    if wuxue_data_list[i] ~= "" then
      local gbox = create_ctrl("GroupBox", "gbox_wuxue_day_" .. nx_string(i), refer_gbox, form.groupscrollbox_3)
      if nx_is_valid(gbox) then
        local nAttack, nExist, nControl, nOperation, strDefine, nColour = get_taolu_prop(nx_string(wuxue_data_list[i]), 1)
        local lbl_name = create_ctrl("Label", "lbl_wuxue_name_" .. nx_string(i), form.lbl_wuxue_title, gbox)
        lbl_name.Text = nx_widestr(util_text(wuxue_data_list[i]))
        lbl_name.ForeColor = nx_string(colour_table[nColour])
        local lbl_attack = create_ctrl("Label", "lbl_wuxue_attack_" .. nx_string(i), form.lbl_wuxue_1, gbox)
        local gbox_attack = create_ctrl("GroupBox", "gbox_wuxue_attack_" .. nx_string(i), form.groupbox_attack, gbox)
        set_star(gbox_attack, nAttack)
        local lbl_exist = create_ctrl("Label", "lbl_wuxue_exist_" .. nx_string(i), form.lbl_wuxue_2, gbox)
        local gbox_exist = create_ctrl("GroupBox", "gbox_wuxue_exist_" .. nx_string(i), form.groupbox_defend, gbox)
        set_star(gbox_exist, nExist)
        local lbl_control = create_ctrl("Label", "lbl_wuxue_control_" .. nx_string(i), form.lbl_wuxue_3, gbox)
        local gbox_control = create_ctrl("GroupBox", "gbox_wuxue_control_" .. nx_string(i), form.groupbox_recover, gbox)
        set_star(gbox_control, nControl)
        local lbl_operation = create_ctrl("Label", "lbl_wuxue_operation_" .. nx_string(i), form.lbl_wuxue_4, gbox)
        local gbox_operation = create_ctrl("GroupBox", "gbox_wuxue_operation_" .. nx_string(i), form.groupbox_operate, gbox)
        set_star(gbox_operation, nOperation)
        local lbl_define = create_ctrl("Label", "lbl_wuxue_define_" .. nx_string(i), form.lbl_wuxue_5, gbox)
        local mtl_define = create_ctrl("MultiTextBox", "mtl_wuxue_define_" .. nx_string(i), form.mltbox_site, gbox)
        mtl_define.HtmlText = nx_widestr(util_text(strDefine))
        local igrid = create_ctrl("ImageGrid", "igrid_skill__" .. nx_string(i), form.imagegrid_skill, gbox)
        local strSkill = get_taolu_prop(nx_string(wuxue_data_list[i]), 2)
        local skill_list = util_split_string(strSkill, ";")
        local grid_index = 0
        for j = 1, #skill_list do
          if skill_list[j] ~= "" then
            local photo = skill_static_query_by_id(nx_string(skill_list[j]), "Photo")
            igrid:AddItem(grid_index, photo, util_text(skill_list[j]), 1, -1)
            grid_index = grid_index + 1
          end
        end
        igrid.taolu_id = nx_string(wuxue_data_list[i])
        nx_bind_script(igrid, nx_current())
        nx_callback(igrid, "on_mousein_grid", "on_imagegrid_skill_mousein_grid")
        nx_callback(igrid, "on_mouseout_grid", "on_imagegrid_skill_mouseout_grid")
      end
      change_ctrl_position(gbox, i)
    end
  end
  form.groupscrollbox_3.IsEditMode = false
  form.groupscrollbox_3:ApplyChildrenCustomYPos()
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function player_balance_equip_is_have(form)
  if not nx_is_valid(form) then
    return 0, 0, 0
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return 0, 0, 0
  end
  if not player:FindRecord(EQUIP_RECORD) then
    return 0, 0, 0
  end
  local row = player:FindRecordRow(EQUIP_RECORD, 0, nx_int(form.plane), 0)
  if row < 0 then
    return 0, 0, 0
  end
  local equip_plane = player:QueryRecord(EQUIP_RECORD, row, 1)
  local wuqi_plane = player:QueryRecord(EQUIP_RECORD, row, 2)
  local shangyi_plane = player:QueryRecord(EQUIP_RECORD, row, 3)
  return equip_plane, wuqi_plane, shangyi_plane
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function get_ini_info(select_type, select_index)
  local ini = nx_execute("util_functions", "get_ini", balance_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("plane")
  if sec_count < 0 then
    return ""
  end
  local select_info = nx_widestr("")
  if nx_int(select_type) == nx_int(CUSTOM_EQUIP_INDEX) then
    select_info = ini:ReadString(sec_count, "zhuangbei", "")
  elseif nx_int(select_type) == nx_int(CUSTOM_WUQI_INDEX) then
    select_info = ini:ReadString(sec_count, "wuqi", "")
  elseif nx_int(select_type) == nx_int(CUSTOM_SHANGYI_INDEX) then
    select_info = ini:ReadString(sec_count, "shangyi", "")
  end
  local select_info_list = util_split_string(select_info, ";")
  local select_info_list_num = table.getn(select_info_list)
  if nx_int(select_info_list_num) < nx_int(select_index) then
    return ""
  end
  return select_info_list[select_index]
end
function find_select_rbtn(index_1, index_2, index_3)
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  local rbtn_equip_name = "rbtn_equip_" .. nx_string(index_1)
  local rbtn_wuqi_name = "rbtn_wuqi_" .. nx_string(index_2)
  local rbtn_shangyi_name = "rbtn_shangyi_" .. nx_string(index_3)
  local rbtn_equip = form.groupbox_11:Find(nx_string(rbtn_equip_name))
  local rbtn_wuqi = form.groupbox_12:Find(nx_string(rbtn_wuqi_name))
  local rbtn_shangyi = form.groupbox_13:Find(nx_string(rbtn_shangyi_name))
  if nx_is_valid(rbtn_equip) and nx_is_valid(rbtn_wuqi) and nx_is_valid(rbtn_shangyi) then
    rbtn_equip.Checked = true
    rbtn_wuqi.Checked = true
    rbtn_shangyi.Checked = true
  end
end
function channels_default_set()
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  clear_selected_jingmai(form)
  local channels_list = util_split_string(form.default_channels, ";")
  local list_count = table.getn(channels_list)
  if nx_int(list_count) < nx_int(form.channels_plane) then
    return
  end
  local select_plane = ""
  if nx_int(form.channels_plane) == nx_int(1) then
    select_plane = channels_list[1]
  elseif nx_int(form.channels_plane) == nx_int(2) then
    select_plane = channels_list[2]
  elseif nx_int(form.channels_plane) == nx_int(3) then
    select_plane = channels_list[3]
  end
  local temp_list = util_split_string(select_plane, ",")
  local temp_list_count = table.getn(temp_list)
  if nx_int(temp_list_count) ~= nx_int(9) then
    return
  end
  for i = 2, temp_list_count do
    local index = nx_int(temp_list[i])
    local gbox_name = "groupbox_" .. nx_string(13 + index)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local lbl_name = "lbl_jingmai_" .. nx_string(index)
      local lbl = gbox:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) then
        lbl.Visible = false
      end
      local cbtn_name = "cbtn_" .. nx_string(index)
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) then
        cbtn.Checked = true
        if nx_int(form.channels_plane) ~= nx_int(3) then
          cbtn.DisableImage = unable_image
        end
      end
    end
  end
end
function set_cbtn_enabled_false()
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_" .. nx_string(13 + i)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_" .. nx_string(i)
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) then
        cbtn.Enabled = false
        cbtn.HintText = nx_widestr(util_text(hinttext))
      end
    end
  end
end
function set_cbtn_enabled_true()
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_" .. nx_string(13 + i)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_" .. nx_string(i)
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) then
        cbtn.DisableImage = " "
        cbtn.Enabled = true
        cbtn.HintText = " "
      end
    end
  end
end
function set_cover_lbl_visible_false()
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_" .. nx_string(13 + i)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local lbl_name = "lbl_jingmai_" .. nx_string(i)
      local lbl = gbox:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) then
        lbl.Visible = false
      end
    end
  end
end
function set_cover_lbl_visible_true()
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_" .. nx_string(13 + i)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local lbl_name = "lbl_jingmai_" .. nx_string(i)
      local lbl = gbox:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) then
        lbl.Visible = true
      end
    end
  end
end
function player_balance_channels_is_have(form)
  if not nx_is_valid(form) then
    return ""
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return ""
  end
  if not player:FindRecord(CHANNELS_RECORD) then
    return ""
  end
  local row = player:FindRecordRow(CHANNELS_RECORD, 0, nx_int(form.channels_plane), 0)
  if row < 0 then
    return ""
  end
  local channels_str = ""
  for i = 1, MAX_CHANNELS_NUM do
    local index = player:QueryRecord(CHANNELS_RECORD, row, i)
    channels_str = channels_str .. nx_string(index)
    if i ~= MAX_CHANNELS_NUM then
      channels_str = channels_str .. nx_string(";")
    end
  end
  return channels_str
end
function reflash_select_channels(channels_str)
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  local temp_table = util_split_string(channels_str, ";")
  local count = table.getn(temp_table)
  clear_selected_jingmai(form)
  for i = 1, count do
    local gbox_index = nx_int(13) + nx_int(temp_table[i])
    local gbox_name = "groupbox_" .. nx_string(gbox_index)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local lbl_name = "lbl_jingmai_" .. nx_string(temp_table[i])
      local lbl = gbox:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) then
        lbl.Visible = false
      end
      local cbtn_name = "cbtn_" .. nx_string(temp_table[i])
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) then
        cbtn.Checked = true
        if nx_int(form.channels_plane) ~= nx_int(3) then
          cbtn.DisableImage = unable_image
        end
      end
    end
  end
end
function clear_selected_jingmai(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_" .. nx_string(13 + i)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_" .. nx_string(i)
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) then
        cbtn.Checked = false
      end
    end
  end
end
function get_player_select_channels()
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  form.channels_str = ""
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_" .. nx_string(13 + i)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_" .. nx_string(i)
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) and cbtn.Checked then
        form.channels_str = form.channels_str .. nx_string(i) .. nx_string(";")
      end
    end
  end
end
function init_jingmai_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupscrollbox_7:Find(nx_string("groupbox_jm_mod"))
  if not nx_is_valid(gb_mod) then
    return
  end
  local gsb = form.groupscrollbox_7
  local gb_str = "groupbox_"
  local lbl_jm_str = "lbl_jm_"
  local img_jm_str = "imagegrid_"
  local cbtn_str = "cbtn_"
  local lbl_forbid_str = "lbl_jingmai_"
  local lbl_jm_mod = form.lbl_jm_mod
  local img_jm_mod = form.imagegrid_jm_mod
  local cbtn_mod = form.cbtn_mod
  local lbl_forbid_mod = form.lbl_jingmai_mod
  for i = 1, TOTAL_CHANNELS_NUM do
    local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(i + 13), gb_mod, gsb)
    local lbl_jm = create_ctrl("MultiTextBox", nx_string(lbl_jm_str) .. nx_string(i), lbl_jm_mod, gb)
    local img_jm = create_ctrl("ImageGrid", nx_string(img_jm_str) .. nx_string(i), img_jm_mod, gb)
    local cbtn = create_ctrl("CheckButton", nx_string(cbtn_str) .. nx_string(i), cbtn_mod, gb)
    local lbl_forbid = create_ctrl("Label", nx_string(lbl_forbid_str) .. nx_string(i), lbl_forbid_mod, gb)
    nx_bind_script(img_jm, nx_current())
    nx_callback(img_jm, "on_lost_capture", "on_imagegrid_jm_mod_lost_capture")
    nx_callback(img_jm, "on_get_capture", "on_imagegrid_jm_mod_get_capture")
    if math.fmod(i, 2) == 1 then
      gb.Width = math.floor((gsb.Width - 25) / (TOTAL_CHANNELS_NUM / LINE_NUM))
      gb.Left = (i - 1) / 2 * gb.Width + 2
      gb.Top = 0
      lbl_forbid.Width = gb.Width
      lbl_forbid.Height = gb.Height
    else
      gb.Width = math.floor((gsb.Width - 25) / (TOTAL_CHANNELS_NUM / LINE_NUM))
      gb.Left = (i / 2 - 1) * gb.Width + 2
      gb.Top = 203
      lbl_forbid.Width = gb.Width
      lbl_forbid.Height = gb.Height
    end
    local jingmai_id = get_jingmai_id(nx_string(i))
    if jingmai_id == nil then
      return
    end
    local grid = get_jingmai_grid(form, nx_int(i))
    local muti_text_box = get_jinmai_label(form, nx_int(i))
    if nx_is_valid(grid) then
      local photo, static_data = query_photo_by_configid(nx_string(jingmai_id), nx_int(1))
      grid.BackImage = photo
      muti_text_box.HtmlText = nx_widestr(util_text(jm_name_table[i]))
      grid.jingmai_id = jingmai_id
      grid.static_data = static_data
    end
  end
  gsb.IsEditMode = false
end
function get_jingmai_id(index)
  local ini = nx_execute("util_functions", "get_ini", channels_file)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_jingmai")
  if sec_count < 0 then
    return ""
  end
  local jingmai_id = ini:ReadString(sec_count, nx_string(index), "")
  return jingmai_id
end
function get_jingmai_grid(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local grid = nx_null()
  local gbox_name = "groupbox_" .. nx_string(13 + index)
  local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local grid_name = "imagegrid_" .. nx_string(index)
    grid = gbox:Find(nx_string(grid_name))
  end
  return grid
end
function get_jinmai_label(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local muti_text_box = nx_null()
  local gbox_name = "groupbox_" .. nx_string(13 + index)
  local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local muti_text_box_name = "lbl_jm_" .. nx_string(index)
    muti_text_box = gbox:Find(nx_string(muti_text_box_name))
  end
  return muti_text_box
end
function show_wuxue_star_level(form, index)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", balance_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex(nx_string(index))
  if sec_count < 0 then
    return
  end
  local wuxue = ini:ReadString(sec_count, "value", "")
  if wuxue == "" then
    return
  end
  local lbl_wuxue
  if nx_int(index) == nx_int(1) then
    lbl_wuxue = form.lbl_wuxue_model_1
  elseif nx_int(index) == nx_int(2) then
    lbl_wuxue = form.lbl_wuxue_model_2
  elseif nx_int(index) == nx_int(3) then
    lbl_wuxue = form.lbl_wuxue_model_3
  elseif nx_int(index) == nx_int(4) then
    lbl_wuxue = form.lbl_wuxue_model_4
  end
  if not nx_is_valid(lbl_wuxue) then
    return
  end
  form.groupscrollbox_3:DeleteAll()
  local wuxue_list = util_split_string(wuxue, ";")
  local wuxue_count = table.getn(wuxue_list)
  for i = 1, wuxue_count do
    if wuxue_list[i] ~= "" then
      local wuxue_label = create_ctrl("Label", "lbl_wuxue_" .. nx_string(i), lbl_wuxue, form.groupscrollbox_3)
      if nx_is_valid(wuxue_label) then
        wuxue_label.Text = nx_widestr(util_text(wuxue_list[i]))
        change_ctrl_position(wuxue_label, nx_int(i))
      end
    end
  end
  form.groupscrollbox_3.IsEditMode = false
  form.groupscrollbox_3:ApplyChildrenCustomYPos()
end
function change_ctrl_position(gbox, index)
  if not nx_is_valid(gbox) then
    return
  end
  if nx_int(index) <= nx_int(0) then
    return
  end
  local count = nx_number(index - 1)
  local row = math.fmod(count, 3)
  local col = math.floor(count / 3)
  gbox.Left = (gbox.Width + 2) * row
  gbox.Top = (gbox.Height + 2) * col + 1
end
function init_prize_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  local prize_config = get_prize_config()
  local prize_type = util_split_string(prize_config, ";")
  local prize_war = prize_type[1]
  local prize_week = prize_type[2]
  local prize_shop = prize_type[3]
  local prize_war_list = util_split_string(prize_war, ",")
  local prize_week_list = util_split_string(prize_week, ",")
  local prize_shop_list = util_split_string(prize_shop, ",")
  for i = 1, #prize_war_list do
    local grid = form.imagegrid_prize_1
    local photo = ItemsQuery:GetItemPropByConfigID(prize_war_list[i], "Photo")
    if photo == "" or photo == nil then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", prize_war_list[i], "Photo")
    end
    grid:AddItem(i - 1, photo, prize_war_list[i], 1, -1)
    grid.config_id = prize_war
  end
  for i = 1, #prize_week_list do
    local grid = form.imagegrid_prize_2
    local photo = ItemsQuery:GetItemPropByConfigID(prize_week_list[i], "Photo")
    if photo == "" or photo == nil then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", prize_week_list[i], "Photo")
    end
    grid:AddItem(i - 1, photo, prize_week_list[i], 1, -1)
    grid.config_id = prize_week
  end
  for i = 1, #prize_shop_list do
    local grid = form.imagegrid_prize_3
    local photo = ItemsQuery:GetItemPropByConfigID(prize_shop_list[i], "Photo")
    if photo == "" or photo == nil then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", prize_shop_list[i], "Photo")
    end
    grid:AddItem(i - 1, photo, prize_shop_list[i], 1, -1)
    grid.config_id = prize_shop
  end
end
function on_imagegrid_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local strConfidId = grid.config_id
  local config_id_list = util_split_string(strConfidId)
  local strConfig = config_id_list[index + 1]
  if strConfig == "" or strConfig == nil then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorClientPos()
  nx_execute("tips_game", "show_tips_by_config", strConfig, x, y)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function get_prize_config()
  local ini = nx_execute("util_functions", "get_ini", balance_file)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("balancewar_prize")
  if sec_count < 0 then
    return ""
  end
  prize_config = ini:ReadString(sec_count, nx_string(1), "")
  return prize_config
end
function init_neigong_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupscrollbox_4:Find(nx_string("groupbox_mod"))
  if not nx_is_valid(gb_mod) then
    return
  end
  local gsb = form.groupscrollbox_4
  local gb_str = "groupbox_1_"
  local lbl_menpai_img_str = "lblmenpai_1_"
  local lbl_menpai_name_str = "lblname_1_"
  local img_neigong_str = "imagegrid_1_"
  local lbl_neigong_name_str = "lbl_1_"
  local lbl_menpai_img_mod = form.lblmenpai_mod
  local lbl_menpai_name_mod = form.lblname_mod
  local img_neigong_mod = form.imagegrid_mod
  local lbl_neigong_name_mod = form.lbl_mod
  for i = 1, NEIGONG_NUM do
    local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(i), gb_mod, gsb)
    local lbl_menpai_img = create_ctrl("Label", nx_string(lbl_menpai_img_str) .. nx_string(i), lbl_menpai_img_mod, gb)
    local lbl_menpai_name = create_ctrl("Label", nx_string(lbl_menpai_name_str) .. nx_string(i), lbl_menpai_name_mod, gb)
    local img_neigong = create_ctrl("ImageGrid", nx_string(img_neigong_str) .. nx_string(i), img_neigong_mod, gb)
    local lbl_neigong = create_ctrl("Label", nx_string(lbl_neigong_name_str) .. nx_string(i), lbl_neigong_name_mod, gb)
    nx_bind_script(img_neigong, nx_current())
    nx_callback(img_neigong, "on_mousein_grid", "on_imagegrid_mod_mousein_grid")
    nx_callback(img_neigong, "on_mouseout_grid", "on_imagegrid_mod_mouseout_grid")
    if math.fmod(NEIGONG_NUM, LINE_NUM) == 0 then
      if i <= NEIGONG_NUM / LINE_NUM then
        gb.Width = math.floor((gsb.Width - 26) / (NEIGONG_NUM / LINE_NUM))
        gb.Left = (i - 1) * gb.Width + 5
        gb.Top = 0
      else
        gb.Width = math.floor((gsb.Width - 26) / (NEIGONG_NUM / LINE_NUM))
        gb.Left = (i - 1 - NEIGONG_NUM / LINE_NUM) * gb.Width + 5
        gb.Top = 204
      end
    elseif i <= (NEIGONG_NUM + 1) / LINE_NUM then
      gb.Width = math.floor((gsb.Width - 26) / ((NEIGONG_NUM + 1) / LINE_NUM))
      gb.Left = (i - 1) * gb.Width + 5
      gb.Top = 0
    else
      gb.Width = math.floor((gsb.Width - 26) / ((NEIGONG_NUM + 1) / LINE_NUM))
      gb.Left = (i - 1 - (NEIGONG_NUM + 1) / LINE_NUM) * gb.Width + 5
      gb.Top = 204
    end
    local neigong_config = get_neigong_config_id(nx_string(i))
    if neigong_config == nil then
      return
    end
    local menpai_logo = get_menpai_logo(i)
    if neigong_config ~= "" then
      local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(neigong_config), nx_int(2))
      local grid, label = find_neigong_grid_and_label(form, i)
      if nx_is_valid(grid) and nx_is_valid(label) then
        grid:AddItem(0, neigong_photo, nx_widestr(neigong_config), 1, -1)
        grid.neigong_config = neigong_config
        grid.static_data = neigong_static_data
        label.Text = nx_widestr(util_text(neigong_config))
      end
      local name, logo = find_menpai_name_and_logo(form, i)
      local temp = "gui\\special\\battlefiled_balance\\logo\\"
      if nx_is_valid(name) and nx_is_valid(logo) then
        name.Text = nx_widestr(util_text(menpai_name_table[i]))
        temp = temp .. nx_string(menpai_logo)
        logo.BackImage = temp
      end
    end
  end
  gsb.IsEditMode = false
end
function get_neigong_config_id(index)
  local ini = nx_execute("util_functions", "get_ini", neigong_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  local neigong = ini:ReadString(sec_count, nx_string(index), "")
  local neigong_list = util_split_string(neigong, ";")
  local neigong_id = neigong_list[1]
  return neigong_id
end
function get_menpai_logo(index)
  local ini = nx_execute("util_functions", "get_ini", menpai_lg)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  local menpai = ini:ReadString(sec_count, nx_string(index), "")
  local menpai_list = util_split_string(menpai, ";")
  local menpai_logo = menpai_list[1]
  return menpai_logo
end
function find_neigong_grid_and_label(form, index)
  if not nx_is_valid(form) then
    return nx_null(), nx_null()
  end
  local gbox_name = "groupbox_1_" .. nx_string(index)
  local gbox = form.groupscrollbox_4:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local grid_name = "imagegrid_1_" .. nx_string(index)
    local label_name = "lbl_1_" .. nx_string(index)
    local grid = gbox:Find(nx_string(grid_name))
    local label = gbox:Find(nx_string(label_name))
    return grid, label
  end
end
function find_menpai_name_and_logo(form, index)
  if not nx_is_valid(form) then
    return nx_null(), nx_null()
  end
  local gbox_name = "groupbox_1_" .. nx_string(index)
  local gbox = form.groupscrollbox_4:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local menpai_name = "lblname_1_" .. nx_string(index)
    local menpai_logo = "lblmenpai_1_" .. nx_string(index)
    local name = gbox:Find(nx_string(menpai_name))
    local logo = gbox:Find(nx_string(menpai_logo))
    return name, logo
  end
end
function query_photo_by_configid(config_id, item_type)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local file_name = ""
  if nx_int(item_type) == nx_int(1) then
    file_name = "share\\Skill\\JingMai\\jingmai.ini"
  elseif nx_int(item_type) == nx_int(2) then
    file_name = "share\\Skill\\NeiGong\\neigong.ini"
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager(file_name)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(config_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  IniManager:UnloadIniFromManager(file_name)
  local photo = ""
  if nx_int(item_type) == nx_int(1) then
    photo = data_query:Query(9, nx_int(static_data), "Photo")
  elseif nx_int(item_type) == nx_int(2) then
    photo = data_query:Query(26, nx_int(static_data), "Photo")
  end
  return photo, static_data
end
function get_level_from_score(form, score)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(score) < nx_int(0) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", balance_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("rank")
  if sec_index < 0 then
    return
  end
  local keys_count = ini:GetSectionItemCount(sec_index)
  for i = 1, keys_count do
    local score_end = ini:ReadInteger(sec_index, nx_string(i), 0)
    if nx_int(score) < nx_int(score_end) then
      form.lbl_current_level.Text = nx_widestr(util_text(nx_string(balance_war_name) .. nx_string(i - 1)))
      form.lbl_next_level.Text = nx_widestr(util_text(nx_string(balance_war_name) .. nx_string(i)))
      form.lbl_value.Text = nx_widestr(score) .. nx_widestr("/") .. nx_widestr(score_end)
      form.pbar_1.Value = score / score_end * 100
      return
    elseif nx_int(i) == nx_int(keys_count) then
      form.lbl_current_level.Text = nx_widestr(util_text(nx_string(balance_war_name) .. nx_string(i)))
      form.lbl_48.Visible = false
      form.lbl_next_level.Visible = false
      form.lbl_value.Text = nx_widestr(score) .. nx_widestr("/") .. nx_widestr(score_end)
      form.pbar_1.Value = 100
    end
  end
end
function init_join_condition_info(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", balance_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("condition")
  if sec_index < 0 then
    return
  end
  local join_condition = ini:ReadString(sec_index, "join_condition", "")
  form.lbl_join_condition.Text = nx_widestr(util_text(join_condition))
  local start_time = ini:ReadString(sec_index, "start_time", "")
  form.lbl_start_time.Text = nx_widestr(util_text(start_time))
  local war_rule = ini:ReadString(sec_index, "war_rule", "")
  form.lbl_war_rule.Text = nx_widestr(util_text(war_rule))
  local prize_rule = ini:ReadString(sec_index, "prize_rule", "")
  local sec_count = ini:FindSectionIndex("player_default")
  if 0 <= sec_count then
    form.default_equip = ini:ReadString(sec_count, "equip", "")
    form.default_channels = ini:ReadString(sec_count, "channels", "")
  end
end
function get_neigong_max_level(strConfig)
  if strConfig == nil or strConfig == "" then
    return 0, 0
  end
  local ini = nx_execute("util_functions", "get_ini", max_level)
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex(strConfig)
  if sec_index < 0 then
    return 0, 0
  end
  local max_level = ini:ReadInteger(sec_index, "value", 0)
  local buff_level = ini:ReadInteger(sec_index, "buff_level", 0)
  local wux_xing = ini:ReadInteger(sec_index, "define_deviation", 0)
  return max_level, buff_level, wux_xing
end
function show_battle_begin_animation()
  show_animation("battlefield_begin")
end
function show_animation(ani_name)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = ani_name
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = (gui.Width - 110) / 2
  animation.Top = gui.Height / 4
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "end_animation")
  animation:Play()
end
function end_animation(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function get_taolu_prop(taolu_id, nIndex)
  if taolu_id == nil or taolu_id == "" then
    return ""
  end
  if nx_int(nIndex) < nx_int(1) or nx_int(nIndex) > nx_int(2) then
    return ""
  end
  local ini = nx_execute("util_functions", "get_ini", skill_file)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(taolu_id)
  if sec_index < 0 then
    return ""
  end
  if nx_int(nIndex) == nx_int(2) then
    local strSkill = ini:ReadString(sec_index, "1", "")
    return strSkill
  end
  local nAttack = ini:ReadInteger(sec_index, "attack", 0)
  local nExist = ini:ReadInteger(sec_index, "exist", 0)
  local nControl = ini:ReadInteger(sec_index, "control", 0)
  local nOperation = ini:ReadInteger(sec_index, "operation", 0)
  local strDefine = ini:ReadString(sec_index, "definition", "")
  local nColour = ini:ReadInteger(sec_index, "colourset", "")
  return nAttack, nExist, nControl, nOperation, strDefine, nColour
end
function set_star(groupbox, num)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox:DeleteAll()
  for i = 1, num do
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = true
  end
end
function updata_week_goal(...)
  local form = nx_value(FORM_BALANCE)
  if not nx_is_valid(form) then
    return
  end
  local strGoal = nx_string(arg[1])
  local goal_list = util_split_string(strGoal, "|")
  for i = 1, #goal_list do
    local strOneGoal = goal_list[i]
    local one_goal_list = util_split_string(strOneGoal, ",")
    if nx_int(#one_goal_list) == nx_int(3) then
      local nGoalNum = one_goal_list[1]
      local nMaxNum = one_goal_list[2]
      if nx_int64(nGoalNum) > nx_int64(nMaxNum) then
        nGoalNum = nMaxNum
      end
      if nx_int(i) == nx_int(3) then
        nGoalNum = math.floor(nx_int(nGoalNum) / 10000)
        nGoalNum = nx_widestr(nGoalNum) .. util_text("ui_wan")
        nMaxNum = math.floor(nx_int(nMaxNum) / 10000)
        nMaxNum = nx_widestr(nMaxNum) .. util_text("ui_wan")
      end
      local flag = nx_int(one_goal_list[3])
      local lbl_goal_name = "lbl_goal_" .. nx_string(i)
      local lbl_get = form.groupbox_10:Find(nx_string(lbl_goal_name))
      if nx_is_valid(lbl_get) then
        if nx_int(flag) == nx_int(1) then
          lbl_get.Text = ""
          lbl_get.BackImage = "gui/special/war_scuffle/1_btn.png"
        else
          if nx_int(i) == nx_int(3) then
            lbl_get.Text = nGoalNum .. nx_widestr("/") .. nMaxNum
          else
            lbl_get.Text = nx_widestr(nGoalNum .. nx_string("/") .. nMaxNum)
          end
          lbl_get.BackImage = ""
        end
      end
    end
  end
end
function close_form()
  local form = nx_value(FORM_BALANCE)
  if nx_is_valid(form) then
    form:Close()
  end
end
function a(q)
  nx_msgbox(nx_string(q))
end
