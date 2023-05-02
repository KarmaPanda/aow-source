require("util_gui")
require("util_functions")
require("util_static_data")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_attribute_mall\\form_attribute_shop")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
require("form_stage_main\\form_tvt\\define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local CLIENT_SUB_SAVE_JM_PLANE = 500
local CLIENT_SUB_SAVE_NG_PLANE = 501
local CLIENT_SUB_SAVE_EQ_PLANE = 502
local CLIENT_SUB_SAVE_TL_PLANE = 503
local CLIENT_SUB_DEL_TL_PLANE = 504
local CLIENT_SUB_SAVE_OPEN_FORM = 505
local CLIENT_SUB_SAVE_PLANE_NAME = 506
local CLIENT_SUB_SAVE_BAOWU_PROP = 518
local power_count = 5
local can_select_prop_num = 3
local baowu_num = 5
local FORM_NAME = "form_stage_main\\form_battlefield_new\\form_bat_new_power_set"
local neigong_file = "share\\War\\GuDianNew\\gudian_ui_neigong.ini"
local channels_file = "share\\War\\GuDianNew\\gudian_ui_jingmai.ini"
local MAX_LEVEL = "share\\War\\GuDianNew\\gudian_ui_neigong_maxlevel.ini"
local baowu_config = "share\\War\\NewBalanceWar\\new_balance_war_baowu_prop.ini"
local MAX_CHANNELS_NUM = 8
local TOTAL_CHANNELS_NUM = 0
local TOTAL_NEIGONG_NUM = 0
local NEIGONG_COL_NUM = 9
local JINGMAI_COL_NUM = 9
local BASE_PROP_NUM = 0
local jm_name = {}
local menpai_name = {}
local logo_name = {}
local zhunagbei_tips = {
  "ui_balance_scuffle_zhuangbei_chisong_content",
  "ui_balance_scuffle_zhuangbei_tuohui_content",
  "ui_balance_scuffle_zhuangbei_jiuxian_content",
  "ui_balance_scuffle_zhuangbei_danran_content",
  "ui_balance_scuffle_zhuangbei_yongse_content",
  "ui_balance_scuffle_wuqi_chisong_content",
  "ui_balance_scuffle_wuqi_tuohui_content",
  "ui_balance_scuffle_wuqi_jiuxian_content",
  "ui_balance_scuffle_wuqi_danran_content",
  "ui_balance_scuffle_wuqi_yongse_content",
  "ui_balance_scuffle_shangyi_chisong_content",
  "ui_balance_scuffle_shangyi_tuohui_content",
  "ui_balance_scuffle_shangyi_jiuxian_content",
  "ui_balance_scuffle_shangyi_danran_content",
  "ui_balance_scuffle_shangyi_yongse_content"
}
local base_prop_ui = {
  "base_prop_ui_1",
  "base_prop_ui_2",
  "base_prop_ui_3",
  "base_prop_ui_4",
  "base_prop_ui_5",
  "base_prop_ui_6",
  "base_prop_ui_7"
}
local baowu_prop_ui = {
  "baowu_prop_ui_1",
  "baowu_prop_ui_2",
  "baowu_prop_ui_3",
  "baowu_prop_ui_4",
  "baowu_prop_ui_5",
  "baowu_prop_ui_6",
  "baowu_prop_ui_7",
  "baowu_prop_ui_8",
  "baowu_prop_ui_9"
}
function main_form_init(self)
  self.Fixed = false
  self.plane_index = 0
  self.plane_rbtn = nil
  self.equip_plane = 0
  self.wuqi_plane = 0
  self.shangyi_plane = 0
  self.neigong_plane = 0
  self.baowu_prop_num = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_ng_jm_num(self)
  init_jm_ng_name(self)
  init_jm_data(form)
  init_ng_data(form)
  init_baowu_data(form)
  default_choose(form)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function open_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
    form:Show()
  else
    util_show_form(FORM_NAME, true)
  end
end
function yyy()
  open_form_ppp(1)
end
function open_form_ppp(data)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
    form:Show()
  else
    util_show_form(FORM_NAME, true)
  end
  local a = form.rbtn_custom_1
  for i = 1, 5 do
    local rbtn_name = "rbtn_custom_" .. nx_string(i)
    local rbtn = form.groupbox_1:Find(nx_string(rbtn_name))
    if nx_is_valid(rbtn) and nx_int(data) == nx_int(rbtn.DataSource) then
      rbtn.Checked = true
    end
  end
  form.rbtn_custom_1.Checked = true
end
function init_jm_ng_name(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuDianNew\\gudian_ui_name.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("jm_name")
  if sec_count < 0 then
    return ""
  end
  local num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local jingmai_name = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(jm_name, nx_string(jingmai_name))
  end
  sec_count = ini:FindSectionIndex("menpai_name")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local neigong_name = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(menpai_name, nx_string(neigong_name))
  end
  sec_count = ini:FindSectionIndex("menpai_logo")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local logo = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(logo_name, nx_string(logo))
  end
end
function init_ng_jm_num(form)
  local ini = nx_execute("util_functions", "get_ini", neigong_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  TOTAL_NEIGONG_NUM = nx_number(ini:GetSectionItemCount(sec_count))
  local ini = nx_execute("util_functions", "get_ini", channels_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_jingmai")
  if sec_count < 0 then
    return ""
  end
  TOTAL_CHANNELS_NUM = nx_number(ini:GetSectionItemCount(sec_count))
  local ini = nx_execute("util_functions", "get_ini", baowu_config)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("base_prop")
  if sec_count < 0 then
    return ""
  end
  BASE_PROP_NUM = nx_number(ini:GetSectionItemCount(sec_count))
  sec_count = ini:FindSectionIndex("baowu_prop")
  if sec_count < 0 then
    return ""
  end
  local form = nx_value(FORM_NAME)
  form.baowu_prop_num = nx_number(ini:GetSectionItemCount(sec_count))
end
function on_rbtn_power_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local data = nx_int(rbtn.DataSource)
  if data == nx_int(1) then
    form.groupbox_equip.Visible = true
    form.groupbox_channels.Visible = false
    form.groupbox_neigong.Visible = false
    form.groupbox_treasure.Visible = false
  elseif data == nx_int(2) then
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = true
    form.groupbox_neigong.Visible = false
    form.groupbox_treasure.Visible = false
  elseif data == nx_int(3) then
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = false
    form.groupbox_neigong.Visible = true
    form.groupbox_treasure.Visible = false
  elseif data == nx_int(4) then
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = false
    form.groupbox_neigong.Visible = false
    form.groupbox_treasure.Visible = true
  end
end
function default_choose(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_custom_1.Checked = true
  form.rbtn_equip.Checked = true
  form.btn_show_side.Visible = false
  form.rbtn_equip_1.Checked = true
  form.rbtn_wuqi_1.Checked = true
  form.rbtn_shangyi_1.Checked = true
end
function on_rbtn_plane_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.cbtn_neigong.Checked = false
  form.rbtn_waigong.Checked = false
  form.plane_index = nx_int(rbtn.DataSource)
  form.plane_rbtn = rbtn
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_OPEN_FORM), nx_int(form.plane_index), nx_int(0))
end
function init_jm_data(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupbox_jingmai_mod
  if not nx_is_valid(gb_mod) then
    return
  end
  local gsb = form.groupscrollbox_jingmai_mod
  local gb_str = "groupbox_jingmai_"
  local cbtn_jm_str = "cbtn_jm_"
  local imagegrid_jm_str = "imagegrid_jm_"
  local lbl_jm_name_str = "lbl_jm_name_"
  local cbtn_jm_mod = form.cbtn_jm_mod
  local imagegrid_jm_mod = form.imagegrid_jm_mod
  local lbl_jm_name_mod = form.lbl_jm_name_mod
  for i = 1, TOTAL_CHANNELS_NUM do
    local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(i), gb_mod, gsb)
    local cbtn_jingmai = create_ctrl("CheckButton", nx_string(cbtn_jm_str) .. nx_string(i), cbtn_jm_mod, gb)
    local imagegrid_jm = create_ctrl("ImageGrid", nx_string(imagegrid_jm_str) .. nx_string(i), imagegrid_jm_mod, gb)
    local lbl_jm_name = create_ctrl("MultiTextBox", nx_string(lbl_jm_name_str) .. nx_string(i), lbl_jm_name_mod, gb)
    gb.Left = math.fmod(i - 1, JINGMAI_COL_NUM) * gb.Width
    gb.Top = math.floor((i - 1) / JINGMAI_COL_NUM) * gb.Height
    nx_bind_script(imagegrid_jm, nx_current())
    nx_callback(imagegrid_jm, "on_lost_capture", "on_imagegrid_lost_capture")
    nx_callback(imagegrid_jm, "on_get_capture", "on_imagegrid_get_capture")
    local jingmai_id = get_jingmai_id(nx_string(i))
    local grid, lbl = get_jingmai_grid(form, nx_int(i))
    if nx_is_valid(grid) and nx_is_valid(lbl) then
      local photo, static_data = query_photo_by_configid(nx_string(jingmai_id), nx_int(1))
      lbl.HtmlText = nx_widestr(util_text(jm_name[i]))
      grid:AddItem(0, photo, nx_widestr(jingmai_id), 1, -1)
      grid.jingmai_id = jingmai_id
      grid.static_data = static_data
    end
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
  init_side_jm_data(form)
end
function init_side_jm_data(form)
  local gsb = form.groupbox_side_jm
  gsb.IsEditMode = true
  local jm_side_gb_mod = form.groupbox_side_jm_mod
  local jm_side_grid_mod = form.imagegrid_side_jm
  local jm_side_lbl_mod = form.lbl_side_jm
  local jm_side_gb_mod_str = "jm_side_gb_"
  local jm_side_grid_str = "jm_side_grid_"
  local jm_side_lbl_str = "jm_side_lbl_"
  for i = 1, MAX_CHANNELS_NUM do
    local gb = create_ctrl("GroupBox", nx_string(jm_side_gb_mod_str) .. nx_string(i), jm_side_gb_mod, gsb)
    local imagegrid_jm = create_ctrl("ImageGrid", nx_string(jm_side_grid_str) .. nx_string(i), jm_side_grid_mod, gb)
    local lbl_jm_name = create_ctrl("Label", nx_string(jm_side_lbl_str) .. nx_string(i), jm_side_lbl_mod, gb)
    nx_bind_script(imagegrid_jm, nx_current())
    nx_callback(imagegrid_jm, "on_lost_capture", "on_imagegrid_side_lost_capture")
    nx_callback(imagegrid_jm, "on_get_capture", "on_imagegrid_side_get_capture")
    gb.Top = 20 + (gb.Height + 2) * (i - 1)
    gb.Left = 10
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
end
function on_imagegrid_side_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_imagegrid_side_get_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "jm_id") then
    return
  end
  if not nx_find_custom(grid, "static_data") then
    return
  end
  local jingmai_id = grid.jm_id
  local jingmai = nx_execute("tips_game", "get_tips_ArrayList")
  jingmai.ConfigID = nx_string(jingmai_id)
  jingmai.ItemType = 1003
  jingmai.Level = 216
  jingmai.StaticData = nx_int(grid.static_data)
  local x = grid.AbsLeft
  local y = grid.AbsTop
  nx_execute("tips_game", "show_goods_tip", jingmai, x, y, 32, 32, form, false)
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
  local lbl = nx_null()
  local gbox_name = "groupbox_jingmai_" .. nx_string(index)
  local gbox = form.groupscrollbox_jingmai_mod:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local grid_name = "imagegrid_jm_" .. nx_string(index)
    grid = gbox:Find(nx_string(grid_name))
    local lbl_name = "lbl_jm_name_" .. nx_string(index)
    lbl = gbox:Find(nx_string(lbl_name))
  end
  return grid, lbl
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
function on_cbtn_jm_nei_wai_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  clear_all_select_jm(form)
  if cbtn.Checked and cbtn.Name == "cbtn_neigong" then
    form.rbtn_waigong.Checked = false
    form.cbtn_jm_1.Checked = true
    form.cbtn_jm_2.Checked = true
    form.cbtn_jm_4.Checked = true
    form.cbtn_jm_5.Checked = true
    form.cbtn_jm_10.Checked = true
    form.cbtn_jm_11.Checked = true
    form.cbtn_jm_13.Checked = true
    form.cbtn_jm_14.Checked = true
  elseif cbtn.Checked and cbtn.Name == "rbtn_waigong" then
    form.cbtn_neigong.Checked = false
    form.cbtn_jm_3.Checked = true
    form.cbtn_jm_6.Checked = true
    form.cbtn_jm_7.Checked = true
    form.cbtn_jm_8.Checked = true
    form.cbtn_jm_12.Checked = true
    form.cbtn_jm_15.Checked = true
    form.cbtn_jm_16.Checked = true
    form.cbtn_jm_17.Checked = true
  end
end
function clear_all_select_jm(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_jingmai_" .. nx_string(i)
    local gbox = form.groupscrollbox_jingmai_mod:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_jm_" .. nx_string(i)
      cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) then
        cbtn.Checked = false
      end
    end
  end
end
function on_imagegrid_get_capture(grid, index)
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
function on_imagegrid_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_channels_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strChannels = get_player_select_channels()
  local temp_table = util_split_string(strChannels, ",")
  local count = table.getn(temp_table)
  if nx_int(count - 1) ~= nx_int(MAX_CHANNELS_NUM) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_channels_1"), 2)
    end
    return
  end
  local strNew = ""
  for i = 1, MAX_CHANNELS_NUM do
    if i ~= MAX_CHANNELS_NUM then
      strNew = strNew .. nx_string(temp_table[i]) .. nx_string(",")
    else
      strNew = strNew .. nx_string(temp_table[i])
    end
  end
  custom_save_channels_plane(strNew, form.plane_index)
end
function custom_save_channels_plane(strChannelsPlane, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_JM_PLANE), nx_int(power_id), nx_string(strChannelsPlane))
end
function get_player_select_channels()
  local strChannels = ""
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return strChannels
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_jingmai_" .. nx_string(i)
    local gbox = form.groupscrollbox_jingmai_mod:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_jm_" .. nx_string(i)
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) and cbtn.Checked then
        strChannels = strChannels .. nx_string(i) .. nx_string(",")
      end
    end
  end
  return strChannels
end
function init_ng_data(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupbox_ng_mod
  if not nx_is_valid(gb_mod) then
    return
  end
  nx_bind_script(form.imagegrid_side_ng, nx_current())
  nx_callback(form.imagegrid_side_ng, "on_mousein_grid", "on_imagegrid_neigong_mousein_grid")
  nx_callback(form.imagegrid_side_ng, "on_mouseout_grid", "on_imagegrid_neigong_mouseout_grid")
  local gsb = form.groupscrollbox_ng
  local gb_str = "groupbox_neigong_"
  local cbtn_ng_str = "cbtn_1_"
  local lbl_bg_str = "lbl_bg_"
  local lbl_mp_name_str = "lbl_mp_name_"
  local lbl_logo_str = "lbl_logo_"
  local imagegrid_ng_str = "imagegrid_1_"
  local lbl_ng_name_str = "lbl_ng_name_"
  local cbtn_ng_mod = form.cbtn_ng_mod
  local lbl_bg_mod = form.lbl_bg_mod
  local lbl_mp_name_mod = form.lbl_mp_name_mod
  local lbl_logo_mod = form.lbl_logo_mod
  local imagegrid_ng_mod = form.imagegrid_ng_mod
  local lbl_ng_name_mod = form.lbl_ng_name_mod
  for i = 1, TOTAL_NEIGONG_NUM do
    local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(i), gb_mod, gsb)
    local cbtn_neigong = create_ctrl("CheckButton", nx_string(cbtn_ng_str) .. nx_string(i), cbtn_ng_mod, gb)
    local lbl_bg = create_ctrl("Label", nx_string(lbl_bg_str) .. nx_string(i), lbl_bg_mod, gb)
    local lbl_mp = create_ctrl("Label", nx_string(lbl_mp_name_str) .. nx_string(i), lbl_mp_name_mod, gb)
    local lbl_logo = create_ctrl("Label", nx_string(lbl_logo_str) .. nx_string(i), lbl_logo_mod, gb)
    local imagegrid_ng = create_ctrl("ImageGrid", nx_string(imagegrid_ng_str) .. nx_string(i), imagegrid_ng_mod, gb)
    local lbl_ng_name = create_ctrl("Label", nx_string(lbl_ng_name_str) .. nx_string(i), lbl_ng_name_mod, gb)
    gb.Left = math.fmod(i - 1, NEIGONG_COL_NUM) * gb.Width + 2
    gb.Top = math.floor((i - 1) / NEIGONG_COL_NUM) * gb.Height + 2
    nx_bind_script(cbtn_neigong, nx_current())
    nx_callback(cbtn_neigong, "on_checked_changed", "on_cbtn_neigong_index_checked_changed")
    nx_bind_script(imagegrid_ng, nx_current())
    nx_callback(imagegrid_ng, "on_mousein_grid", "on_imagegrid_neigong_mousein_grid")
    nx_callback(imagegrid_ng, "on_mouseout_grid", "on_imagegrid_neigong_mouseout_grid")
    cbtn_neigong.self_index = nx_number(i)
    local neigong_cbtn = search_neigong_cbtn(form, nx_string(i))
    local neigong_config = get_neigong_config_id(neigong_cbtn, nx_string(i))
    if neigong_config ~= "" then
      local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(neigong_config), nx_int(2))
      local label = find_neigong_grid_and_label(form, i)
      local grid = search_neigong_grid(form, i)
      local menpai_lbl, menpI_logo = get_menpai_lbl_logo(form, nx_string(i))
      if nx_is_valid(grid) and nx_is_valid(label) and nx_is_valid(menpai_lbl) and nx_is_valid(menpI_logo) then
        grid:AddItem(0, neigong_photo, nx_widestr(neigong_config), 1, -1)
        grid.neigong_config = neigong_config
        grid.static_data = neigong_static_data
        menpai_lbl.Text = nx_widestr(util_text(menpai_name[i]))
        local temp = "gui\\special\\battlefiled_balance\\logo\\" .. nx_string(logo_name[i])
        menpI_logo.BackImage = temp
        label.Text = nx_widestr(util_text(neigong_config))
      end
    end
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
end
function get_neigong_config_id(cbtn, index)
  local ini = nx_execute("util_functions", "get_ini", neigong_file)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  local neigong = ini:ReadString(sec_count, nx_string(index), "")
  local neigong_list = util_split_string(neigong, ";")
  if nx_int(#neigong_list) ~= nx_int(6) then
    return ""
  end
  if nx_is_valid(cbtn) then
    cbtn.bili = nx_int(neigong_list[2])
    cbtn.shenfa = nx_int(neigong_list[3])
    cbtn.neixi = nx_int(neigong_list[4])
    cbtn.gangqi = nx_int(neigong_list[5])
    cbtn.tipo = nx_int(neigong_list[6])
  end
  local neigong_id = neigong_list[1]
  return neigong_id
end
function get_ng_config_id(index)
  local ini = nx_execute("util_functions", "get_ini", neigong_file)
  if not nx_is_valid(ini) then
    return ""
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
function search_neigong_cbtn(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local cbtn = nx_null()
  local gb_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
  if nx_is_valid(gbox) then
    local rbtn_name = "cbtn_1_" .. nx_string(index)
    cbtn = gbox:Find(nx_string(rbtn_name))
  end
  return cbtn
end
function search_neigong_grid(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local grid = nx_null()
  local gb_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
  if nx_is_valid(gbox) then
    local grid_name = "imagegrid_1_" .. nx_string(index)
    grid = gbox:Find(nx_string(grid_name))
  end
  return grid
end
function find_neigong_grid_and_label(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local lbl = nx_null()
  local gb_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
  if nx_is_valid(gbox) then
    local lbl_name = "lbl_ng_name_" .. nx_string(index)
    lbl = gbox:Find(nx_string(lbl_name))
  end
  return lbl
end
function get_menpai_lbl_logo(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local menpai_lbl = nx_null()
  local menpai_logo = nx_null()
  local gb_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
  if nx_is_valid(gbox) then
    local menpai_lbl_name = "lbl_mp_name_" .. nx_string(index)
    local menpai_logo_name = "lbl_logo_" .. nx_string(index)
    menpai_lbl = gbox:Find(nx_string(menpai_lbl_name))
    menpai_logo = gbox:Find(nx_string(menpai_logo_name))
  end
  return menpai_lbl, menpai_logo
end
function show_neigong_prop(form, rbtn)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(rbtn) then
    return
  end
  form.lbl_bili.Text = nx_widestr(rbtn.bili)
  form.lbl_shenfa.Text = nx_widestr(rbtn.shenfa)
  form.lbl_neixi.Text = nx_widestr(rbtn.neixi)
  form.lbl_gangqi.Text = nx_widestr(rbtn.gangqi)
  form.lbl_tipo.Text = nx_widestr(rbtn.tipo)
end
function on_cbtn_neigong_index_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  form.neigong_plane = nx_int(cbtn.self_index)
  for i = 1, TOTAL_NEIGONG_NUM do
    local gb_name = "groupbox_neigong_" .. nx_string(i)
    local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_1_" .. nx_string(i)
      local cbtn_ng = gbox:Find(nx_string(cbtn_name))
      if cbtn_ng.self_index ~= cbtn.self_index then
        cbtn_ng.Checked = false
      end
    end
  end
  show_neigong_prop(form, cbtn)
end
function on_imagegrid_neigong_mousein_grid(grid, index)
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
  if nx_string(neigong_config) == nx_string("") then
    return
  end
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
function on_imagegrid_neigong_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function get_neigong_max_level(strConfig)
  if strConfig == nil or strConfig == "" then
    return 0, 0
  end
  local ini = nx_execute("util_functions", "get_ini", MAX_LEVEL)
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
function init_baowu_data(form)
  if not nx_is_valid(form) then
    return
  end
  get_quick_choose_config(form)
  local gsb = form.groupbox_treasure
  local lbl_base_prop_mod = form.lbl_base_prop_mod
  local lbl_base_prop_str = "lbl_base_prop_"
  local gb_baowu_prop_mod = form.groupbox_baowu_prop_mod
  local cbtn_baowu_mod = form.cbtn_baowu_mod
  local lbl_baowu_mod = form.lbl_baowu_mod
  local gb_baowu_prop_str = "gb_baowu_prop_"
  local cbtn_baowu_str = "cbtn_baowu_"
  local lbl_baowu_str = "lbl_baowu_"
  for i = 1, BASE_PROP_NUM do
    local lbl_base = create_ctrl("Label", nx_string(lbl_base_prop_str) .. nx_string(i), lbl_base_prop_mod, form.groupbox_base_prop)
    lbl_base.Top = 20 + (lbl_base.Height + 5) * (i - 1)
    lbl_base.Left = 40
    local attr_id, attr_value = get_baowu_prop_info(1, i)
    lbl_base.Text = util_text(base_prop_ui[i]) .. nx_widestr("+") .. nx_widestr(attr_value)
  end
  for i = 1, baowu_num do
    local gb = create_ctrl("GroupBox", nx_string(gb_baowu_prop_str) .. nx_string(i), gb_baowu_prop_mod, gsb)
    gb.prop_sl_num = 0
    gb.Left = (i - 1) * (gb.Width + 3)
    gb.Top = 150
    for i = 1, form.baowu_prop_num do
      local cbtn_baowu = create_ctrl("CheckButton", nx_string(cbtn_baowu_str) .. nx_string(i), cbtn_baowu_mod, gb)
      local lbl_baowu = create_ctrl("Label", nx_string(lbl_baowu_str) .. nx_string(i), lbl_baowu_mod, gb)
      cbtn_baowu.index = i
      cbtn_baowu.parent_ctrl = gb
      cbtn_baowu.lbl = lbl_baowu
      nx_bind_script(cbtn_baowu, nx_current())
      nx_callback(cbtn_baowu, "on_checked_changed", "on_cbtn_baowu_index_checked_changed")
      cbtn_baowu.Top = 20 + (cbtn_baowu.Height + 5) * (i - 1)
      cbtn_baowu.Left = 0
      lbl_baowu.Top = 27 + (lbl_baowu.Height + 18) * (i - 1)
      lbl_baowu.Left = 30
      local attr_id, attr_value = get_baowu_prop_info(2, i)
      lbl_baowu.Text = util_text(baowu_prop_ui[i]) .. nx_widestr("+") .. nx_widestr(attr_value) .. nx_widestr("%")
    end
  end
end
function get_quick_choose_config(form)
  local ini = nx_execute("util_functions", "get_ini", baowu_config)
  if not nx_is_valid(ini) then
    return nx_null()
  end
  local sec_count = ini:FindSectionIndex("quick_choose")
  if sec_count < 0 then
    return nx_null()
  end
  local quick_choose = ini:ReadString(sec_count, nx_string(1), "")
  local temp_list = util_split_string(quick_choose, ";")
  form.rbtn_quick_1.quick_data = nx_string(temp_list[1])
  form.rbtn_quick_2.quick_data = nx_string(temp_list[2])
end
function get_baowu_prop_info(prop_type, index)
  local ini = nx_execute("util_functions", "get_ini", baowu_config)
  if not nx_is_valid(ini) then
    return nx_null()
  end
  local sec_count
  if nx_int(1) == nx_int(prop_type) then
    sec_count = ini:FindSectionIndex("base_prop")
    if sec_count < 0 then
      return nx_null()
    end
  elseif nx_int(2) == nx_int(prop_type) then
    sec_count = ini:FindSectionIndex("baowu_prop")
    if sec_count < 0 then
      return nx_null()
    end
  end
  local item_count = ini:GetSectionItemCount(sec_count)
  if item_count < 1 then
    return nx_null()
  end
  if index < 1 and index >= item_count then
    return nx_null()
  end
  local prop = ini:GetSectionItemValue(sec_count, index - 1)
  local prop_list = util_split_string(prop, ",")
  if nx_int(#prop_list) ~= nx_int(2) then
    return nx_null()
  end
  return nx_string(prop_list[1]), nx_number(prop_list[2])
end
function on_cbtn_baowu_index_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local parent_ctrl = cbtn.parent_ctrl
  if not nx_is_valid(parent_ctrl) then
    return
  end
  if cbtn.Checked then
    cbtn.lbl.ForeColor = "255,255,204,0"
  else
    cbtn.lbl.ForeColor = "255,197,184,159"
  end
  local count = 0
  for i = 1, form.baowu_prop_num do
    local cbtn_name = "cbtn_baowu_"
    local cbtn = parent_ctrl:Find(cbtn_name .. nx_string(i))
    if nx_is_valid(cbtn) and cbtn.Checked then
      count = count + 1
    end
  end
  if count == can_select_prop_num then
    for i = 1, form.baowu_prop_num do
      local cbtn_name = "cbtn_baowu_"
      local cbtn = parent_ctrl:Find(cbtn_name .. nx_string(i))
      if nx_is_valid(cbtn) and not cbtn.Checked then
        cbtn.Enabled = false
      end
    end
  else
    for i = 1, form.baowu_prop_num do
      local cbtn_name = "cbtn_baowu_"
      local cbtn = parent_ctrl:Find(cbtn_name .. nx_string(i))
      if nx_is_valid(cbtn) and not cbtn.Checked then
        cbtn.Enabled = true
      end
    end
  end
end
function on_rbtn_quick_choose_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  local data = btn.quick_data
  local no_list = util_split_string(data, ",")
  if nx_int(#no_list) ~= nx_int(3) then
    return ""
  end
  clear_bw_cbtn(form)
  for i = 1, baowu_num do
    local bw_gb_name = "gb_baowu_prop_" .. nx_string(i)
    local gb_bw = form.groupbox_treasure:Find(nx_string(bw_gb_name))
    if not nx_is_valid(gb_bw) then
      return
    end
    for j = 1, nx_number(3) do
      local bw_cbtn_name = "cbtn_baowu_" .. nx_string(no_list[j])
      local cbtn_bw = gb_bw:Find(nx_string(bw_cbtn_name))
      if not nx_is_valid(cbtn_bw) then
        return
      end
      cbtn_bw.Checked = true
    end
  end
end
function on_btn_custom_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local Text = form.ipt_custom.Text
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_PLANE_NAME), nx_int(form.plane_index), nx_widestr(Text))
end
function on_btn_save_neigong_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nIndex = nx_int(form.neigong_plane)
  if nx_int(nIndex) < nx_int(1) or nx_int(nIndex) > nx_int(TOTAL_NEIGONG_NUM) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("luandou_systeminfo_10101"), 2)
    end
    return
  end
  custom_save_neigong_plane(nIndex, form.plane_index)
end
function custom_save_neigong_plane(nNeiGong, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_NG_PLANE), nx_int(power_id), nx_int(nNeiGong))
end
function on_rbtn_equip_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.equip_plane = nx_int(rbtn.DataSource)
end
function on_rbtn_wuqi_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.wuqi_plane = nx_int(rbtn.DataSource)
end
function on_rbtn_shangyi_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.shangyi_plane = nx_int(rbtn.DataSource)
end
function on_btn_equip_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.equip_plane) < nx_int(1) or nx_int(form.equip_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("luandou_systeminfo_10102"), 2)
    end
    return
  end
  if nx_int(form.wuqi_plane) < nx_int(1) or nx_int(form.wuqi_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("luandou_systeminfo_10103"), 2)
    end
    return
  end
  if nx_int(form.shangyi_plane) < nx_int(1) or nx_int(form.shangyi_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("luandou_systeminfo_10104"), 2)
    end
    return
  end
  local strPlane = nx_string(form.equip_plane) .. nx_string(",") .. nx_string(form.wuqi_plane) .. nx_string(",") .. nx_string(form.shangyi_plane)
  custom_save_equip_plane(strPlane, form.plane_index)
end
function custom_save_equip_plane(strEquipPlane, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_EQ_PLANE), nx_int(power_id), nx_string(strEquipPlane))
end
function on_btn_bw_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strBaowu = ""
  for i = 1, baowu_num do
    local gb_name = "gb_baowu_prop_" .. nx_string(i)
    local gb = form.groupbox_treasure:Find(nx_string(gb_name))
    if not nx_is_valid(gb) then
      return
    end
    local num = 0
    local str = ""
    for j = 1, form.baowu_prop_num do
      local cbtn_name = "cbtn_baowu_" .. nx_string(j)
      local cbtn = gb:Find(nx_string(cbtn_name))
      if not nx_is_valid(cbtn) then
        return
      end
      if cbtn.Checked == true then
        num = num + 1
        if nx_number(num) ~= nx_number(can_select_prop_num) then
          str = str .. nx_string(cbtn.index) .. nx_string(",")
        else
          str = str .. nx_string(cbtn.index)
        end
      end
    end
    if i ~= 5 then
      strBaowu = strBaowu .. nx_string(str) .. nx_string(";")
    else
      strBaowu = strBaowu .. nx_string(str)
    end
    if nx_number(num) ~= nx_number(can_select_prop_num) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("new_balance_systeminfo_baowu"), 2)
      end
      return
    end
  end
  custom_save_baowu_plane(strBaowu, form.plane_index)
end
function custom_save_baowu_plane(strBaoWuPlane, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_BAOWU_PROP), nx_int(power_id), nx_string(strBaoWuPlane))
end
function updata_player_equip_data_test()
  updata_player_equip_data("1,2,5")
end
function updata_player_equip_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_equip_lbl(form)
  local strEquip = nx_string(arg[2])
  local equip_list = util_split_string(strEquip, ",")
  if nx_int(#equip_list) ~= nx_int(3) then
    clear_eq_cbtn(form)
    return
  end
  form.lbl_equip.Text = nx_widestr(util_text("luandou_zhaungbei_" .. equip_list[1]))
  form.lbl_equip.ForeColor = nx_string("255,197,184,159")
  form.lbl_equip.HintText = util_text(zhunagbei_tips[nx_number(equip_list[1])])
  form.lbl_wuqi.Text = nx_widestr(util_text("luandou_zhaungbei_" .. equip_list[2]))
  form.lbl_wuqi.ForeColor = nx_string("255,197,184,159")
  form.lbl_wuqi.HintText = util_text(zhunagbei_tips[nx_number(5) + nx_number(equip_list[2])])
  form.lbl_shangyi.Text = nx_widestr(util_text("luandou_zhaungbei_" .. equip_list[3]))
  form.lbl_shangyi.ForeColor = nx_string("255,197,184,159")
  form.lbl_shangyi.HintText = util_text(zhunagbei_tips[nx_number(10) + nx_number(equip_list[3])])
  local gsb = form.groupbox_11
  local cbtn_equip = gsb:Find("rbtn_equip_" .. nx_string(equip_list[1]))
  if not nx_is_valid(cbtn_equip) then
    return
  end
  cbtn_equip.Checked = true
  gsb = form.groupbox_12
  local cbtn_wuqi = gsb:Find("rbtn_wuqi_" .. nx_string(equip_list[2]))
  if not nx_is_valid(cbtn_wuqi) then
    return
  end
  cbtn_wuqi.Checked = true
  gsb = form.groupbox_13
  local cbtn_shangyi = gsb:Find("rbtn_shangyi_" .. nx_string(equip_list[3]))
  if not nx_is_valid(cbtn_shangyi) then
    return
  end
  cbtn_shangyi.Checked = true
end
function clear_eq_cbtn(form)
  local gsb = form.groupbox_11
  for i = 1, 5 do
    local cbtn_equip = gsb:Find("rbtn_equip_" .. nx_string(i))
    if not nx_is_valid(cbtn_equip) then
      return
    end
    cbtn_equip.Checked = false
    gsb = form.groupbox_12
    local cbtn_wuqi = gsb:Find("rbtn_wuqi_" .. nx_string(i))
    if not nx_is_valid(cbtn_wuqi) then
      return
    end
    cbtn_wuqi.Checked = false
    gsb = form.groupbox_13
    local cbtn_shangyi = gsb:Find("rbtn_shangyi_" .. nx_string(i))
    if not nx_is_valid(cbtn_shangyi) then
      return
    end
    cbtn_shangyi.Checked = false
  end
end
function clear_equip_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_equip.Text = util_text("ui_choswar_interface_005")
  form.lbl_equip.ForeColor = nx_string("255,255,0,0")
  form.lbl_wuqi.Text = util_text("ui_choswar_interface_005")
  form.lbl_wuqi.ForeColor = nx_string("255,255,0,0")
  form.lbl_shangyi.Text = util_text("ui_choswar_interface_005")
  form.lbl_shangyi.ForeColor = nx_string("255,255,0,0")
end
function updata_player_jm_data_test()
  updata_player_jm_data("11,12,13,14,15,16,17,18")
end
function updata_player_jm_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local strChannels = nx_string(arg[2])
  if nx_string(strChannels) == "" then
    clear_jm_cbtn(form)
    local gbox = form.groupbox_side_jm
    for i = 1, 8 do
      local gb_jm = gbox:Find(nx_string("jm_side_gb_") .. nx_string(i))
      if not nx_is_valid(gb_jm) then
        return
      end
      local grid_jm = gb_jm:Find(nx_string("jm_side_grid_") .. nx_string(i))
      local lbl_jm = gb_jm:Find(nx_string("jm_side_lbl_") .. nx_string(i))
      grid_jm.jm_id = ""
      local photo, static_data = query_photo_by_configid(nx_string(grid_jm.jm_id), nx_int(1))
      grid_jm:DelItem(0)
      grid_jm.static_data = static_data
      lbl_jm.Text = util_text("ui_choswar_interface_005")
      lbl_jm.ForeColor = nx_string("255,255,0,0")
    end
    return
  end
  local channels_list = util_split_string(strChannels, ",")
  if nx_int(#channels_list) ~= nx_int(8) then
    return
  end
  local gbox = form.groupbox_side_jm
  for i = 1, #channels_list do
    local gb_jm = gbox:Find(nx_string("jm_side_gb_") .. nx_string(i))
    if not nx_is_valid(gb_jm) then
      return
    end
    local jm_index = nx_number(channels_list[i])
    local grid_jm = gb_jm:Find(nx_string("jm_side_grid_") .. nx_string(i))
    local lbl_jm = gb_jm:Find(nx_string("jm_side_lbl_") .. nx_string(i))
    grid_jm.jm_id = get_jingmai_id(nx_string(jm_index))
    local photo, static_data = query_photo_by_configid(nx_string(grid_jm.jm_id), nx_int(1))
    grid_jm:AddItem(0, photo, nx_widestr(jm_id), 1, -1)
    grid_jm.static_data = static_data
    lbl_jm.Text = util_text(grid_jm.jm_id)
    lbl_jm.ForeColor = nx_string("255,197,184,159")
  end
  clear_jm_cbtn(form)
  local gsb_mod = form.groupscrollbox_jingmai_mod
  for i = 1, #channels_list do
    local gb_jm = gsb_mod:Find("groupbox_jingmai_" .. nx_string(channels_list[i]))
    if not nx_is_valid(gb_jm) then
      return
    end
    local cbtn_jm = gb_jm:Find("cbtn_jm_" .. nx_string(channels_list[i]))
    if not nx_is_valid(cbtn_jm) then
      return
    end
    cbtn_jm.Checked = true
  end
end
function clear_jm_cbtn(form)
  local gsb_mod = form.groupscrollbox_jingmai_mod
  for i = 1, TOTAL_CHANNELS_NUM do
    local gb_jm = gsb_mod:Find("groupbox_jingmai_" .. nx_string(i))
    if not nx_is_valid(gb_jm) then
      return
    end
    local cbtn_jm = gb_jm:Find("cbtn_jm_" .. nx_string(i))
    if not nx_is_valid(cbtn_jm) then
      return
    end
    cbtn_jm.Checked = false
  end
  local gbox = form.groupbox_side_jm
end
function updata_player_ng_data_test()
  updata_player_ng_data(1)
end
function updata_player_ng_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid_ng = form.imagegrid_side_ng
  local lbl_ng = form.lbl_side_ng_name
  local nNeiGongIndex = nx_int(arg[2])
  if nx_int(nNeiGongIndex) == nx_int(0) then
    clear_ng_cbtn(form)
    local strConfig = ""
    local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(strConfig), nx_int(2))
    grid_ng.neigong_config = strConfig
    grid_ng.static_data = neigong_static_data
    grid_ng:DelItem(0)
    form.lbl_side_ng_name.Text = util_text("ui_choswar_interface_005")
    form.lbl_side_ng_name.ForeColor = nx_string("255,255,0,0")
    return
  end
  local strConfig = get_ng_config_id(nNeiGongIndex)
  local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(strConfig), nx_int(2))
  grid_ng.neigong_config = strConfig
  grid_ng.static_data = neigong_static_data
  grid_ng:AddItem(0, neigong_photo, nx_widestr(neigong_config), 1, -1)
  form.lbl_side_ng_name.Text = util_text(grid_ng.neigong_config)
  form.lbl_side_ng_name.ForeColor = nx_string("255,197,184,159")
  clear_ng_cbtn(form)
  local gsb = form.groupscrollbox_ng
  local gb_ng = gsb:Find("groupbox_neigong_" .. nx_string(nNeiGongIndex))
  if not nx_is_valid(gb_ng) then
    return
  end
  local cbtn_ng = gb_ng:Find("cbtn_1_" .. nx_string(nNeiGongIndex))
  if not nx_is_valid(cbtn_ng) then
    return
  end
  cbtn_ng.Checked = true
end
function clear_ng_cbtn(form)
  local gsb = form.groupscrollbox_ng
  for i = 1, TOTAL_NEIGONG_NUM do
    local gb_ng = gsb:Find("groupbox_neigong_" .. nx_string(i))
    if not nx_is_valid(gb_ng) then
      return
    end
    local cbtn_ng = gb_ng:Find("cbtn_1_" .. nx_string(i))
    if not nx_is_valid(cbtn_ng) then
      return
    end
    cbtn_ng.Checked = false
  end
end
function updata_baowu_plane_test()
  updata_baowu_plane("")
end
function updata_baowu_plane(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_bw_cbtn(form)
  local strBaoWu = nx_string(arg[2])
  local bw_list = util_split_string(strBaoWu, ";")
  if nx_int(#bw_list) ~= nx_int(5) then
    return
  end
  local gsb = form.groupbox_treasure
  if not nx_is_valid(gsb) then
    return
  end
  for i = 1, #bw_list do
    local bw_gb_name = "gb_baowu_prop_" .. nx_string(i)
    local gb_bw = gsb:Find(nx_string(bw_gb_name))
    if not nx_is_valid(gb_bw) then
      return
    end
    local bw_index_str = util_split_string(bw_list[i], ",")
    if nx_int(#bw_index_str) ~= nx_int(can_select_prop_num) then
      return
    end
    for j = 1, nx_number(form.baowu_prop_num) do
      local bw_cbtn_name = "cbtn_baowu_" .. nx_string(j)
      local cbtn_bw = gb_bw:Find(nx_string(bw_cbtn_name))
      if not nx_is_valid(cbtn_bw) then
        return
      end
      for k = 1, #bw_index_str do
        if nx_int(cbtn_bw.index) == nx_int(bw_index_str[k]) then
          cbtn_bw.Checked = true
        end
      end
    end
  end
end
function clear_bw_cbtn(form)
  if not nx_is_valid(form) then
    return
  end
  local gsb = form.groupbox_treasure
  if not nx_is_valid(gsb) then
    return
  end
  for i = 1, baowu_num do
    local bw_gb_name = "gb_baowu_prop_" .. nx_string(i)
    local gb_bw = gsb:Find(nx_string(bw_gb_name))
    if not nx_is_valid(gb_bw) then
      return
    end
    for j = 1, nx_number(form.baowu_prop_num) do
      local bw_cbtn_name = "cbtn_baowu_" .. nx_string(j)
      local cbtn_bw = gb_bw:Find(nx_string(bw_cbtn_name))
      if not nx_is_valid(cbtn_bw) then
        return
      end
      cbtn_bw.Checked = false
    end
  end
end
function updata_player_pn_data_test()
  updata_player_pn_data("")
end
function updata_player_pn_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.groupbox_1
  for i = 1, power_count do
    local rbtn = gb:Find("rbtn_custom_" .. nx_string(i))
    if not nx_is_valid(rbtn) then
      return
    end
    if nx_widestr(arg[i + 1]) ~= nx_widestr(nx_string("")) then
      rbtn.Text = nx_widestr(arg[i + 1])
    else
      rbtn.Text = util_text("ui_nbw_plane_name") .. nx_widestr(i)
    end
  end
end
function on_btn_show_hide_side_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local data = btn.DataSource
  if nx_int(data) == nx_int(1) then
    form.btn_show_side.Visible = false
    form.groupbox_side.Visible = true
  end
  if nx_int(data) == nx_int(0) then
    form.btn_show_side.Visible = true
    form.groupbox_side.Visible = false
  end
end
function a(b)
  nx_msgbox(nx_string(b))
end
