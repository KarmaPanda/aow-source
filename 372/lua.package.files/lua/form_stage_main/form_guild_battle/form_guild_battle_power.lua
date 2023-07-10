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
local FORM_NAME = "form_stage_main\\form_guild_battle\\form_guild_battle_power"
local channels_file = "share\\War\\GuildBattle\\guild_battle_ui_jingmai.ini"
local neigong_file = "share\\War\\GuildBattle\\guild_battle_ui_neigong.ini"
local max_level = "share\\War\\GuildBattle\\guild_battle_ui_neigong_maxlevel.ini"
local wuxue_file = "share\\War\\GuildBattle\\guild_battle_ui_wuxue.ini"
local wuxue_prop_file = "share\\War\\GuildBattle\\guild_battle_ui_wuxue_prop.ini"
local FILE_SKILL_INI = "share\\Skill\\skill_new.ini"
local CTS_SUB_GB_MSG_OPENFORM = 201
local CTS_SUB_GB_MSG_SAVE_JINGMAI = 202
local CTS_SUB_GB_MSG_SAVE_NEIGONG = 203
local CTS_SUB_GB_MSG_SAVE_EQUIP = 204
local CTS_SUB_GB_MSG_ADD_WUXUE = 205
local CTS_SUB_GB_MSG_DEL_WUXUE = 206
local JINGMAI_NUM = 0
local JINGMAO_MAX_BUM = 8
local LINE_NUM = 2
local NEIGONG_NUM = 0
local EQUIP_NUM = 5
local WUXUE_TYPE_NUM = 6
local MENPAI_NUM = 10
local SHILI_NUM = 6
local YINSHI_num = 10
local WUXUE_LINE = 4
local WUXUE_LIMIT_NUM = 0
local menpai_ng_table = {}
local yinshi_ng_table = {}
local shili_ng_table = {}
local jianghu_ng_table = {}
local gbp_zhuangbei = "luandou_zhaungbei_"
NODE_PROP = {
  first = {
    ForeColor = "255,255,255,255",
    NodeBackImage = "gui\\special\\market_new\\main_menu.png",
    NodeFocusImage = "gui\\special\\market_new\\main_menu.png",
    NodeSelectImage = "gui\\special\\market_new\\main_menu.png",
    Font = "font_treeview"
  },
  second = {
    ForeColor = "255,255,249,194",
    NodeBackImage = "gui\\special\\war_scuffle\\2_btn1_out.png",
    NodeFocusImage = "gui\\special\\war_scuffle\\2_btn1_on.png",
    NodeSelectImage = "gui\\special\\war_scuffle\\2_btn1_down.png",
    ItemWidth = 20,
    ItemHeight = 30,
    TextOffsetX = 5,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  third = {
    ForeColor = "255,255,255,255",
    NodeBackImage = "gui\\guild\\guild_battle\\C_btn1_out.png",
    NodeFocusImage = "gui\\guild\\guild_battle\\C_btn1_on.png",
    NodeSelectImage = "gui\\guild\\guild_battle\\C_btn1_down.png",
    ItemWidth = 56,
    ItemHeight = 28,
    TextOffsetX = 5,
    TextOffsetY = 6,
    Font = "font_treeview"
  }
}
jm_name_table = {}
menpai_name_table = {}
equip_name_tanbe = {}
equip_detail_tanbe = {}
wuqi_detail_tanbe = {}
shangyi_detail_tanbe = {}
function main_form_init(self)
  self.Fixed = false
  self.equip_plane = 0
  self.wuqi_plane = 0
  self.shangyi_plane = 0
  self.neigong_plane = 0
  self.select_wuxue_id = ""
  self.power_id = 0
  self.wuxue_nei_wai_type = 0
  self.wuxue_total_type = 0
  self.wuxue_menpai_type = 0
  self.wuxue_shili_type = 0
  self.wuxue_yinshi_type = 0
end
function on_main_form_open(form)
  form.sl_node = nil
  form.wuxue_num = 0
  init_name_table(form)
  init_wuxue_limit_num(form)
  inin_taolu_lbl(form)
  init_wuxue_num(form)
  init_neigong_num(form)
  init_jingmai_num(form)
  form.groupbox_skill.Visible = true
  init_jingmai_grid(form)
  init_neigong_grid(form)
  init_equip_data(form)
  init_wuxue_data(form)
  default_choose(form)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  menpai_ng_table = {}
  yinshi_ng_table = {}
  shili_ng_table = {}
  jianghu_ng_table = {}
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
function default_choose(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_show_side.Visible = false
  form.rbtn_menpai.Checked = true
  form.cbtn_neigong_1.Checked = true
  form.rbtn_zb.Checked = true
  form.cbtn_equip_1.Checked = true
  form.cbtn_wuqi_1.Checked = true
  form.cbtn_shangyi_1.Checked = true
  form.cbtn_wuxue_type_nei.Checked = true
  form.cbtn_wuxue_type_wai.Checked = true
  form.rbtn_power_swbh.Checked = true
end
function on_rbtn_skill_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_channels.Visible = false
  form.groupbox_neigong.Visible = false
  form.groupbox_equip.Visible = false
  form.groupbox_skill.Visible = true
end
function on_rbtn_equip_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_channels.Visible = false
  form.groupbox_neigong.Visible = false
  form.groupbox_equip.Visible = true
  form.groupbox_skill.Visible = false
end
function on_rbtn_channels_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_channels.Visible = true
  form.groupbox_neigong.Visible = false
  form.groupbox_equip.Visible = false
  form.groupbox_skill.Visible = false
end
function on_rbtn_neigong_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_channels.Visible = false
  form.groupbox_neigong.Visible = true
  form.groupbox_equip.Visible = false
  form.groupbox_skill.Visible = false
end
function init_name_table(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildBattle\\guild_battle_ui_name.ini")
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
    table.insert(jm_name_table, nx_string(jingmai_name))
  end
  sec_count = ini:FindSectionIndex("ng_name")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local neigong_name = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(menpai_name_table, nx_string(neigong_name))
  end
  sec_count = ini:FindSectionIndex("zhuangbei_name")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local zhuangebi_name = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(equip_name_tanbe, nx_string(zhuangebi_name))
  end
  sec_count = ini:FindSectionIndex("zhuangbei_details")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local equip_detail = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(equip_detail_tanbe, nx_string(equip_detail))
  end
  sec_count = ini:FindSectionIndex("wuqi_details")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local wuqi_detail = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(wuqi_detail_tanbe, nx_string(wuqi_detail))
  end
  sec_count = ini:FindSectionIndex("shangyi_details")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local shangyi_detail = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(shangyi_detail_tanbe, nx_string(shangyi_detail))
  end
end
function init_wuxue_num(form)
  local ini = nx_execute("util_functions", "get_ini", wuxue_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_wuxue")
  if sec_count < 0 then
    return ""
  end
  form.wuxue_num = nx_number(ini:GetSectionItemCount(sec_count))
end
function init_wuxue_num(form)
  local ini = nx_execute("util_functions", "get_ini", wuxue_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_wuxue")
  if sec_count < 0 then
    return ""
  end
  form.wuxue_num = nx_number(ini:GetSectionItemCount(sec_count))
end
function init_wuxue_limit_num(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildBattle\\guild_battle.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("player_default")
  if sec_count < 0 then
    return ""
  end
  WUXUE_LIMIT_NUM = ini:ReadString(sec_count, "selcet_skill", "")
end
function init_neigong_num(form)
  local ini = nx_execute("util_functions", "get_ini", neigong_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  NEIGONG_NUM = nx_number(ini:GetSectionItemCount(sec_count))
end
function init_jingmai_num(form)
  local ini = nx_execute("util_functions", "get_ini", channels_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_jingmai")
  if sec_count < 0 then
    return ""
  end
  JINGMAI_NUM = nx_number(ini:GetSectionItemCount(sec_count))
end
function init_jingmai_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupbox_jm_mod
  if not nx_is_valid(gb_mod) then
    return
  end
  local gsb = form.groupscrollbox_7
  local gb_str = "groupbox_jm_"
  local img_jm_str = "imagegrid_jm_"
  local rbtn_jm_str = "rbtn_jm_"
  local lbl_jm_str = "lbl_jm_"
  local lbl_back_jm_str = "lbl_back_jm_"
  local img_jm_mod = form.jm_imagegrid_mod
  local rbtn_jm_mod = form.jm_rbtn_mod
  local lbl_jm_mod = form.jm_lbl_mod
  local lbl_back_jm_mod = form.lbl_channels_back
  for i = 1, JINGMAI_NUM do
    local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(i), gb_mod, gsb)
    local cbtn = create_ctrl("CheckButton", nx_string(rbtn_jm_str) .. nx_string(i), rbtn_jm_mod, gb)
    local lbl_back_jm = create_ctrl("Label", nx_string(lbl_back_jm_str) .. nx_string(i), lbl_back_jm_mod, gb)
    local lbl_jm = create_ctrl("Label", nx_string(lbl_jm_str) .. nx_string(i), lbl_jm_mod, gb)
    local img_jm = create_ctrl("ImageGrid", nx_string(img_jm_str) .. nx_string(i), img_jm_mod, gb)
    nx_bind_script(img_jm, nx_current())
    nx_callback(img_jm, "on_lost_capture", "on_imagegrid_jm_mod_lost_capture")
    nx_callback(img_jm, "on_get_capture", "on_imagegrid_jm_mod_get_capture")
    if math.fmod(JINGMAI_NUM, 2) == 0 then
      if i <= JINGMAI_NUM / 2 then
        gb.Top = (i - 1) * gb.Height + 2
        gb.Left = 0
      else
        gb.Top = (i - JINGMAI_NUM / 2 - 1) * gb.Height + 2
        gb.Left = 270
      end
    elseif i <= (JINGMAI_NUM + 1) / 2 then
      gb.Top = (i - 1) * gb.Height + 2
      gb.Left = 0
    else
      gb.Top = (i - (JINGMAI_NUM + 1) / 2 - 1) * gb.Height + 2
      gb.Left = 270
    end
    local jingmai_id = get_jm_config_id(nx_string(i))
    if jingmai_id == nil then
      return
    end
    local grid = get_jingmai_grid(form, nx_int(i))
    local lbl = get_jinmai_label(form, nx_int(i))
    if nx_is_valid(grid) and nx_is_valid(grid) then
      local photo, static_data = query_photo_by_configid(nx_string(jingmai_id), nx_int(1))
      grid:AddItem(0, photo, nx_widestr(jingmai_id), 1, -1)
      lbl.Text = nx_widestr(util_text(jm_name_table[i]))
      grid.jingmai_id = jingmai_id
      grid.static_data = static_data
    end
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
end
function get_jm_config_id(index)
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
  local gbox_name = "groupbox_jm_" .. nx_string(index)
  local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local grid_name = "imagegrid_jm_" .. nx_string(index)
    grid = gbox:Find(nx_string(grid_name))
  end
  return grid
end
function get_jinmai_label(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local lbl = nx_null()
  local gbox_name = "groupbox_jm_" .. nx_string(index)
  local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local muti_text_box_name = "lbl_jm_" .. nx_string(index)
    lbl = gbox:Find(nx_string(muti_text_box_name))
  end
  return lbl
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
function on_imagegrid_jm_mod_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
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
function on_rbtn_jm_nei_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  clear_all_select_jm(form)
  if rbtn.Checked then
    form.rbtn_jm_1.Checked = true
    form.rbtn_jm_11.Checked = true
    form.rbtn_jm_2.Checked = true
    form.rbtn_jm_12.Checked = true
    form.rbtn_jm_5.Checked = true
    form.rbtn_jm_15.Checked = true
    form.rbtn_jm_4.Checked = true
    form.rbtn_jm_14.Checked = true
  end
end
function on_rbtn_jm_wai_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  clear_all_select_jm(form)
  if rbtn.Checked then
    form.rbtn_jm_3.Checked = true
    form.rbtn_jm_13.Checked = true
    form.rbtn_jm_6.Checked = true
    form.rbtn_jm_16.Checked = true
    form.rbtn_jm_7.Checked = true
    form.rbtn_jm_17.Checked = true
    form.rbtn_jm_8.Checked = true
    form.rbtn_jm_18.Checked = true
  end
end
function clear_all_select_jm(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, JINGMAI_NUM do
    local gbox_name = "groupbox_jm_" .. nx_string(i)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "rbtn_jm_" .. nx_string(i)
      cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) then
        cbtn.Checked = false
      end
    end
  end
end
function on_btn_channels_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strChannels = get_player_select_channels()
  local temp_table = util_split_string(strChannels, ",")
  local count = table.getn(temp_table)
  if nx_int(count) ~= nx_int(JINGMAO_MAX_BUM) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_channels_1"), 2)
    end
    return
  end
  custom_save_channels_plane(strChannels, form.power_id)
end
function get_player_select_channels()
  local strChannels = ""
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return strChannels
  end
  for i = 1, JINGMAI_NUM do
    local gbox_name = "groupbox_jm_" .. nx_string(i)
    local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "rbtn_jm_" .. nx_string(i)
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) and cbtn.Checked then
        strChannels = strChannels .. nx_string(i) .. nx_string(",")
      end
    end
  end
  if strChannels ~= "" then
    strChannels = string.sub(strChannels, 1, string.len(strChannels) - 1)
  end
  return strChannels
end
function on_rbtn_neigong_type_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local data = rbtn.DataSource
  if not rbtn.Checked then
    return
  end
  get_neigong_type(data)
end
function on_cbtn_wuxue_type_checked_changed(cbtn)
end
function a(info)
  nx_msgbox(nx_string(info))
end
function init_neigong_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupbox_neigong_mod
  if not nx_is_valid(gb_mod) then
    return
  end
  local gsb = form.groupscrollbox_4
  local gb_str = "groupbox_neigong_"
  local img_neigong_str = "imagegrid_neigong_"
  local cbtn_neigong_str = "cbtn_neigong_"
  local lbl_neigong_str = "lbl_neigong_"
  local lbl_back_neigong_str = "lbl_back_neigong_"
  local img_neigong_mod = form.imagegrid_neigong_mod
  local cbtn_neigong_mod = form.cbtn_neigong_mod
  local lbl_neigong_mod = form.lbl_neigong_mod
  local lbl_back_neigong_mod = form.lbl_neigong_back
  for i = 1, NEIGONG_NUM do
    local neigong_config, neigong_type = get_neigong_config_id(nx_string(i))
    local real_index = fix_index(i)
    if neigong_config == nil or neigong_type == nil then
      return
    end
    local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(real_index), gb_mod, gsb)
    local cbtn_neigong = create_ctrl("CheckButton", nx_string(cbtn_neigong_str) .. nx_string(real_index), cbtn_neigong_mod, gb)
    local lbl_back_neigong = create_ctrl("Label", nx_string(lbl_back_neigong_str) .. nx_string(real_index), lbl_back_neigong_mod, gb)
    local img_neigong = create_ctrl("ImageGrid", nx_string(img_neigong_str) .. nx_string(real_index), img_neigong_mod, gb)
    local lbl_neigong = create_ctrl("Label", nx_string(lbl_neigong_str) .. nx_string(real_index), lbl_neigong_mod, gb)
    nx_bind_script(img_neigong, nx_current())
    nx_callback(img_neigong, "on_lost_capture", "on_imagegrid_ng_mod_lost_capture")
    nx_callback(img_neigong, "on_get_capture", "on_imagegrid_ng_mod_get_capture")
    nx_bind_script(cbtn_neigong, nx_current())
    nx_callback(cbtn_neigong, "on_checked_changed", "on_cbtn_ng_checked_changed")
    cbtn_neigong.self_index = nx_number(real_index)
    gb.neigong_type = neigong_type
    init_neigong_type_table(gb.neigong_type, gb)
    local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(neigong_config), nx_int(2))
    local grid, label = find_neigong_grid_and_label(form, real_index)
    if nx_is_valid(grid) and nx_is_valid(label) then
      grid:AddItem(0, neigong_photo, nx_widestr(neigong_config), 1, -1)
      grid.neigong_config = neigong_config
      grid.static_data = neigong_static_data
      label.Text = nx_widestr(nx_widestr(util_text(menpai_name_table[i])))
    end
  end
  gsb.IsEditMode = false
end
function fix_index(index)
  local ini = nx_execute("util_functions", "get_ini", neigong_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  local real_index = ini:GetSectionItemKey(sec_count, nx_number(index) - 1)
  return real_index
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
  local neigong = ini:GetSectionItemValue(sec_count, nx_number(index) - 1)
  local neigong_list = util_split_string(neigong, ";")
  local neigong_id = neigong_list[1]
  local neigong_type = neigong_list[2]
  return neigong_id, neigong_type
end
function find_neigong_grid_and_label(form, index)
  if not nx_is_valid(form) then
    return nx_null(), nx_null()
  end
  local gbox_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_4:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local grid_name = "imagegrid_neigong_" .. nx_string(index)
    local label_name = "lbl_neigong_" .. nx_string(index)
    local grid = gbox:Find(nx_string(grid_name))
    local label = gbox:Find(nx_string(label_name))
    return grid, label
  end
end
function on_cbtn_ng_checked_changed(cbtn)
  local self_index = cbtn.self_index
  if not cbtn.Checked then
    return
  end
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.neigong_plane = self_index
  for i = 1, NEIGONG_NUM do
    local neigong_config, neigong_type = get_neigong_config_id(nx_string(i))
    local real_index = fix_index(i)
    local groupbox = form.groupscrollbox_4
    local gb_name = "groupbox_neigong_" .. nx_string(real_index)
    local gb = groupbox:Find(nx_string(gb_name))
    if nx_is_valid(gb) then
      local cbtn_name = "cbtn_neigong_" .. nx_string(real_index)
      local cbtn = gb:Find(nx_string(cbtn_name))
      if cbtn.self_index ~= self_index then
        cbtn.Checked = false
      end
    end
  end
end
function on_imagegrid_ng_mod_get_capture(grid, index)
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
function on_imagegrid_ng_mod_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function get_neigong_type(index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local neigong_gsb = form.groupscrollbox_4
  neigong_gsb.IsEditMode = true
  local neigong_index = 0
  for i = 1, NEIGONG_NUM do
    local gbox = form.groupscrollbox_4
    local neigong_config, neigong_type = get_neigong_config_id(nx_string(i))
    local real_index = fix_index(i)
    local name = "groupbox_neigong_" .. nx_string(real_index)
    local gb_neigong = gbox:Find(nx_string(name))
    if nx_is_valid(gb_neigong) then
      gb_neigong.Visible = false
    end
  end
  for i = 1, NEIGONG_NUM do
    local gbox = form.groupscrollbox_4
    local neigong_config, neigong_type = get_neigong_config_id(nx_string(i))
    local real_index = fix_index(i)
    local name = "groupbox_neigong_" .. nx_string(real_index)
    local gb_neigong = gbox:Find(nx_string(name))
    if nx_is_valid(gb_neigong) and nx_find_custom(gb_neigong, "neigong_type") and nx_int(index) == nx_int(gb_neigong.neigong_type) then
      gb_neigong.Visible = true
      gb_neigong.Left = 2
      gb_neigong.Top = neigong_index * gb_neigong.Height + 2
      neigong_index = neigong_index + 1
    end
  end
  neigong_gsb.IsEditMode = false
  neigong_gsb.Height = neigong_gsb.Height
end
function init_neigong_type_table(types, gb)
  if nx_int(types) == nx_int(0) then
    table.insert(menpai_ng_table, nx_string(gb.Name))
  elseif nx_int(types) == nx_int(1) then
    table.insert(yinshi_ng_table, nx_string(gb.Name))
  elseif nx_int(types) == nx_int(2) then
    table.insert(shili_ng_table, nx_string(gb.Name))
  elseif nx_int(types) == nx_int(3) then
    table.insert(jianghu_ng_table, nx_string(gb.Name))
  end
end
function on_btn_save_neigong_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nIndex = nx_int(form.neigong_plane)
  custom_save_neigong_plane(nIndex, form.power_id)
end
function init_equip_data(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupbox_equip_mod
  if not nx_is_valid(gb_mod) then
    return
  end
  local gsb = form.groupscrollbox_10
  local gb_equip_str = "groupbox_equip_"
  local label_equip_str = "label_equip_"
  local mltbox_equip_str = "mltbox_equip_"
  local cbtn_equip_str = "cbtn_equip_"
  local gb_wuqi_str = "groupbox_wuqi_"
  local label_wuqi_str = "label_wuqi_"
  local mltbox_wuqi_str = "mltbox_wuqi_"
  local cbtn_wuqi_str = "cbtn_wuqi_"
  local gb_shnagyi_str = "groupbox_shangyi_"
  local label_shangyi_str = "label_shangyi_"
  local mltbox_shangyi_str = "mltbox_shangyi_"
  local cbtn_shangyi_str = "cbtn_shangyi_"
  local label_equip = form.lbl_equip_mod
  local mltbox_equip = form.mltbox_equip_mod
  local cbtn_equip = form.cbtn_equip_mod
  for i = 1, EQUIP_NUM do
    local gb_equip = create_ctrl("GroupBox", nx_string(gb_equip_str) .. nx_string(i), gb_mod, gsb)
    local cbtn_equip = create_ctrl("CheckButton", nx_string(cbtn_equip_str) .. nx_string(i), cbtn_equip, gb_equip)
    local mltbox_equip = create_ctrl("MultiTextBox", nx_string(mltbox_equip_str) .. nx_string(i), mltbox_equip, gb_equip)
    local label_equip = create_ctrl("Label", nx_string(label_equip_str) .. nx_string(i), label_equip, gb_equip)
    cbtn_equip.index = nx_int(i)
    nx_bind_script(cbtn_equip, nx_current())
    nx_callback(cbtn_equip, "on_checked_changed", "on_cbtn_equip_checked_changed")
    gb_equip.Left = 0
    gb_equip.Top = (i - 1) * gb_equip.Height + 20
    local lbl_equip, mutbox_equip = get_equip_lbl_mutbox(form, i)
    if nx_is_valid(lbl_equip) and nx_is_valid(mutbox_equip) then
      lbl_equip.Text = nx_widestr(util_text(equip_name_tanbe[i]))
      mutbox_equip.HtmlText = nx_widestr(util_text(equip_detail_tanbe[i]))
    end
    gb_equip.Visible = false
    local gb_wuqi = create_ctrl("GroupBox", nx_string(gb_wuqi_str) .. nx_string(i), gb_mod, gsb)
    local cbtn_wuqi = create_ctrl("CheckButton", nx_string(cbtn_wuqi_str) .. nx_string(i), cbtn_equip, gb_wuqi)
    local mltbox_wuqi = create_ctrl("MultiTextBox", nx_string(mltbox_wuqi_str) .. nx_string(i), mltbox_equip, gb_wuqi)
    local label_wuqi = create_ctrl("Label", nx_string(label_wuqi_str) .. nx_string(i), label_equip, gb_wuqi)
    cbtn_wuqi.index = nx_int(i)
    nx_bind_script(cbtn_wuqi, nx_current())
    nx_callback(cbtn_wuqi, "on_checked_changed", "on_cbtn_wuqi_checked_changed")
    gb_wuqi.Left = 0
    gb_wuqi.Top = (i - 1) * gb_wuqi.Height + 20
    local lbl_wuqi, mutbox_wuqi = get_wuqi_lbl_mutbox(form, i)
    if nx_is_valid(lbl_wuqi) and nx_is_valid(mutbox_wuqi) then
      lbl_wuqi.Text = nx_widestr(util_text(equip_name_tanbe[i]))
      mutbox_wuqi.HtmlText = nx_widestr(util_text(wuqi_detail_tanbe[i]))
    end
    gb_wuqi.Visible = false
    local gb_shangyi = create_ctrl("GroupBox", nx_string(gb_shnagyi_str) .. nx_string(i), gb_mod, gsb)
    local cbtn_shangyi = create_ctrl("CheckButton", nx_string(cbtn_shangyi_str) .. nx_string(i), cbtn_equip, gb_shangyi)
    local mltbox_shangyi = create_ctrl("MultiTextBox", nx_string(mltbox_shangyi_str) .. nx_string(i), mltbox_equip, gb_shangyi)
    local label_shangyi = create_ctrl("Label", nx_string(label_shangyi_str) .. nx_string(i), label_equip, gb_shangyi)
    cbtn_shangyi.index = nx_int(i)
    nx_bind_script(cbtn_shangyi, nx_current())
    nx_callback(cbtn_shangyi, "on_checked_changed", "on_cbtn_shangyi_checked_changed")
    gb_shangyi.Left = 0
    gb_shangyi.Top = (i - 1) * gb_shangyi.Height + 20
    local lbl_shangyi, mutbox_shangyi = get_shangyi_lbl_mutbox(form, i)
    if nx_is_valid(lbl_shangyi) and nx_is_valid(mutbox_shangyi) then
      lbl_shangyi.Text = nx_widestr(util_text(equip_name_tanbe[i]))
      mutbox_shangyi.HtmlText = nx_widestr(util_text(shangyi_detail_tanbe[i]))
    end
    gb_shangyi.Visible = false
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
end
function get_equip_lbl_mutbox(form, index)
  if not nx_is_valid(form) then
    return nx_null(), nx_null()
  end
  local gbox_name = "groupbox_equip_" .. nx_string(index)
  local gbox = form.groupscrollbox_10:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local lbl_name = "label_equip_" .. nx_string(index)
    local mltbox_name = "mltbox_equip_" .. nx_string(index)
    local lbl = gbox:Find(nx_string(lbl_name))
    local mltbox = gbox:Find(nx_string(mltbox_name))
    return lbl, mltbox
  end
end
function get_wuqi_lbl_mutbox(form, index)
  if not nx_is_valid(form) then
    return nx_null(), nx_null()
  end
  local gbox_name = "groupbox_wuqi_" .. nx_string(index)
  local gbox = form.groupscrollbox_10:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local lbl_name = "label_wuqi_" .. nx_string(index)
    local mltbox_name = "mltbox_wuqi_" .. nx_string(index)
    local lbl = gbox:Find(nx_string(lbl_name))
    local mltbox = gbox:Find(nx_string(mltbox_name))
    return lbl, mltbox
  end
end
function get_shangyi_lbl_mutbox(form, index)
  if not nx_is_valid(form) then
    return nx_null(), nx_null()
  end
  local gbox_name = "groupbox_shangyi_" .. nx_string(index)
  local gbox = form.groupscrollbox_10:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local lbl_name = "label_shangyi_" .. nx_string(index)
    local mltbox_name = "mltbox_shangyi_" .. nx_string(index)
    local lbl = gbox:Find(nx_string(lbl_name))
    local mltbox = gbox:Find(nx_string(mltbox_name))
    return lbl, mltbox
  end
end
function on_cbtn_equip_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  local index = cbtn.index
  form.equip_plane = index
  for i = 1, EQUIP_NUM do
    local gbox = form.groupscrollbox_10
    local gb_name = "groupbox_equip_" .. nx_string(i)
    local gb = gbox:Find(nx_string(gb_name))
    if nx_is_valid(gb) then
      local cbtn_name = "cbtn_equip_" .. nx_string(i)
      local cbtn = gb:Find(nx_string(cbtn_name))
      if nx_int(index) ~= nx_int(cbtn.index) then
        cbtn.Checked = false
      end
    end
  end
end
function on_cbtn_wuqi_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  local index = cbtn.index
  form.wuqi_plane = index
  for i = 1, EQUIP_NUM do
    local gbox = form.groupscrollbox_10
    local gb_name = "groupbox_wuqi_" .. nx_string(i)
    local gb = gbox:Find(nx_string(gb_name))
    if nx_is_valid(gb) then
      local cbtn_name = "cbtn_wuqi_" .. nx_string(i)
      local cbtn = gb:Find(nx_string(cbtn_name))
      if nx_int(index) ~= nx_int(cbtn.index) then
        cbtn.Checked = false
      end
    end
  end
end
function on_cbtn_shangyi_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  local index = cbtn.index
  form.shangyi_plane = index
  for i = 1, EQUIP_NUM do
    local gbox = form.groupscrollbox_10
    local gb_name = "groupbox_shangyi_" .. nx_string(i)
    local gb = gbox:Find(nx_string(gb_name))
    if nx_is_valid(gb) then
      local cbtn_name = "cbtn_shangyi_" .. nx_string(i)
      local cbtn = gb:Find(nx_string(cbtn_name))
      if nx_int(index) ~= nx_int(cbtn.index) then
        cbtn.Checked = false
      end
    end
  end
end
function on_rbtn_equip_wuqi_shangyi_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local index = rbtn.DataSource
  show_equip_wuqi_shangyi(index)
end
function show_equip_wuqi_shangyi(index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(index) == nx_int(1) then
    hide_equip_wuqi_shangyi()
    for i = 1, EQUIP_NUM do
      local gbox = form.groupscrollbox_10
      local gb_name = "groupbox_equip_" .. nx_string(i)
      local gb = gbox:Find(nx_string(gb_name))
      if nx_is_valid(gb) then
        gb.Visible = true
        gb.Left = 0
        gb.Top = (i - 1) * gb.Height + 10
      end
    end
  elseif nx_int(index) == nx_int(2) then
    hide_equip_wuqi_shangyi()
    for i = 1, EQUIP_NUM do
      local gbox = form.groupscrollbox_10
      local gb_name = "groupbox_wuqi_" .. nx_string(i)
      local gb = gbox:Find(nx_string(gb_name))
      if nx_is_valid(gb) then
        gb.Visible = true
        gb.Left = 0
        gb.Top = (i - 1) * gb.Height + 10
      end
    end
  elseif nx_int(index) == nx_int(3) then
    hide_equip_wuqi_shangyi()
    for i = 1, EQUIP_NUM do
      local gbox = form.groupscrollbox_10
      local gb_name = "groupbox_shangyi_" .. nx_string(i)
      local gb = gbox:Find(nx_string(gb_name))
      if nx_is_valid(gb) then
        gb.Visible = true
        gb.Left = 0
        gb.Top = (i - 1) * gb.Height + 10
      end
    end
  end
end
function hide_equip_wuqi_shangyi()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, EQUIP_NUM do
    local gbox = form.groupscrollbox_10
    local gb_equip_name = "groupbox_equip_" .. nx_string(i)
    local gb_wuqi_name = "groupbox_wuqi_" .. nx_string(i)
    local gb_shangyi_name = "groupbox_shangyi_" .. nx_string(i)
    local gb_equip = gbox:Find(nx_string(gb_equip_name))
    local gb_wuqi = gbox:Find(nx_string(gb_wuqi_name))
    local gb_shangyi = gbox:Find(nx_string(gb_shangyi_name))
    if nx_is_valid(gb_equip) and nx_is_valid(gb_wuqi) and nx_is_valid(gb_shangyi) then
      gb_equip.Visible = false
      gb_wuqi.Visible = false
      gb_shangyi.Visible = false
    end
  end
end
function on_btn_equip_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.equip_plane) < nx_int(1) or nx_int(form.equip_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_2), 2)
    end
    return
  end
  if nx_int(form.wuqi_plane) < nx_int(1) or nx_int(form.wuqi_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_3), 2)
    end
    return
  end
  if nx_int(form.shangyi_plane) < nx_int(1) or nx_int(form.shangyi_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_4), 2)
    end
    return
  end
  local strPlane = nx_string(form.equip_plane) .. nx_string(",") .. nx_string(form.wuqi_plane) .. nx_string(",") .. nx_string(form.shangyi_plane)
  custom_save_equip_plane(strPlane, form.power_id)
end
function init_wuxue_data(form)
  if not nx_is_valid(form) then
    return
  end
  init_tree_wuxue_node(form)
  local gsb = form.groupscrollbox_8
  local rbtn_wuxue_str = "rbtn_wuxue_"
  local rbtn_wuxue_mod = form.rbtn_wuxue_mod
  for i = 1, form.wuxue_num do
    local rbtn_wuxue = create_ctrl("RadioButton", nx_string(rbtn_wuxue_str) .. nx_string(i), rbtn_wuxue_mod, gsb)
    rbtn_wuxue.Height = 30
    rbtn_wuxue.Width = 95
    local wuxue_configid, wuxue_actionid, wuxue_nei_wai_type, wuxue_total_type, wuxue_sub_type = get_wuxue_configid(i)
    rbtn_wuxue.configid = wuxue_configid
    rbtn_wuxue.actionid = wuxue_actionid
    rbtn_wuxue.wuxue_nei_wai_type = nx_number(wuxue_nei_wai_type)
    rbtn_wuxue.main_type = nx_number(wuxue_total_type)
    rbtn_wuxue.sub_type = nx_number(wuxue_sub_type)
    local nAttack, nExist, nControl, nOperation, strDefine, nColour, wuji = get_taolu_prop(rbtn_wuxue.configid, 1)
    rbtn_wuxue.wuji_mark = wuji
    if nx_int(rbtn_wuxue.wuji_mark) == nx_int(1) then
      rbtn_wuxue.NormalImage = "gui\\special\\war_scuffle\\2_btn_cy_out_wuji.png"
      rbtn_wuxue.FocusImage = "gui\\special\\war_scuffle\\2_btn_cy_on_wuji.png"
      rbtn_wuxue.CheckedImage = "gui\\special\\war_scuffle\\2_btn_cy_down_wuji.png"
    end
    nx_bind_script(rbtn_wuxue, nx_current())
    nx_callback(rbtn_wuxue, "on_checked_changed", "on_rbtn_can_select_skill_checked_changed")
    rbtn_wuxue.Text = util_text(nx_string(wuxue_configid))
    rbtn_wuxue.Top = math.floor((i - 1) / 3) * (rbtn_wuxue.Height + 5) + 5
    rbtn_wuxue.Left = math.fmod(i - 1, 3) * (rbtn_wuxue.Width + 10) + 15
  end
  gsb.IsEditMode = false
end
function get_wuxue_configid(index)
  local ini = nx_execute("util_functions", "get_ini", wuxue_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_wuxue")
  if sec_count < 0 then
    return ""
  end
  local wuxue = ini:ReadString(sec_count, nx_string(index), "")
  local wuxue_list = util_split_string(wuxue, ";")
  local wuxue_id = wuxue_list[1]
  local wuxue_actionid = wuxue_list[2]
  local wuxue_nei_wai_type = wuxue_list[3]
  local wuxue_total_type = wuxue_list[4]
  local wuxue_sub_type = wuxue_list[5]
  return wuxue_id, wuxue_actionid, wuxue_nei_wai_type, wuxue_total_type, wuxue_sub_type
end
function on_rbtn_can_select_skill_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local wuxue_id = rbtn.configid
  form.select_wuxue_id = wuxue_id
  local nAttack, nExist, nControl, nOperation, strDefine, nColour = get_taolu_prop(wuxue_id, 1)
  if nAttack == "" then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_6), 2)
    end
    return
  end
  form.lbl_wuxue_title.Text = nx_widestr(util_text(wuxue_id))
  set_star(form.groupbox_attack, nAttack)
  set_star(form.groupbox_defend, nExist)
  set_star(form.groupbox_recover, nControl)
  set_star(form.groupbox_operate, nOperation)
  form.mltbox_site.HtmlText = nx_widestr(util_text(strDefine))
  local neigong_wuxing, jingmai_wuxing = get_neigong_and_jingmai_devation(wuxue_id)
  if nx_int(neigong_wuxing) > nx_int(0) and nx_int(neigong_wuxing) < nx_int(6) then
    form.mltbox_ng.HtmlText = nx_widestr(util_text("desc_luandou_neigong_define_" .. nx_string(neigong_wuxing)))
  end
  if nx_int(jingmai_wuxing) > nx_int(0) and nx_int(jingmai_wuxing) < nx_int(6) then
    form.mltbox_jm.HtmlText = nx_widestr(util_text("desc_luandou_jingmai_define_" .. nx_string(jingmai_wuxing)))
  end
  local strSkill = get_taolu_prop(wuxue_id, 2)
  local skill_list = util_split_string(strSkill, ";")
  local grid = form.imagegrid_skill
  if not nx_is_valid(grid) then
    return
  end
  grid:Clear()
  for j = 1, #skill_list do
    if skill_list[j] ~= "" then
      local photo = skill_static_query_by_id(nx_string(skill_list[j]), "Photo")
      grid:AddItem(nx_int(j - 1), photo, util_text(skill_list[j]), 1, -1)
    end
  end
  local action_id = nx_string(rbtn.actionid)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "show_item_action", form, action_id, WUXUE_SHOW_SKILL, true)
end
function get_taolu_prop(taolu_id, nIndex)
  if taolu_id == nil or taolu_id == "" then
    return ""
  end
  if nx_int(nIndex) < nx_int(1) or nx_int(nIndex) > nx_int(2) then
    return ""
  end
  local ini = nx_null()
  ini = nx_execute("util_functions", "get_ini", wuxue_prop_file)
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
  local wuji = ini:ReadInteger(sec_index, "wuji", "")
  return nAttack, nExist, nControl, nOperation, strDefine, nColour, wuji
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
function get_neigong_and_jingmai_devation(strWuXue)
  if strWuXue == nil or strWuXue == "" then
    return 0, 0
  end
  local ini = nx_null()
  ini = nx_execute("util_functions", "get_ini", wuxue_prop_file)
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(strWuXue))
  if sec_index < 0 then
    return 0, 0
  end
  local neigong_deviation = ini:ReadInteger(sec_index, "deviation_neigong", 0)
  local jingmai_deviation = ini:ReadInteger(sec_index, "deviation_jingmai", 0)
  return neigong_deviation, jingmai_deviation
end
function on_imagegrid_skill_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strTaolu = form.select_wuxue_id
  if nx_string(strTaolu) == nx_string("") then
    return
  end
  local strSkill = get_taolu_prop(strTaolu, 2)
  local skill_list = util_split_string(strSkill, ";")
  local skill_id = skill_list[index + 1]
  if nx_string(skill_id) == nx_string("") then
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
function on_cbtn_wuxue_type_checked_changed(cbtn)
  local form = cbtn.ParentForm
  sift(form)
end
function on_tree_wuxue_type_select_changed(self, cur_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.sl_node = cur_node
  sift(form)
end
function init_tree_wuxue_node(form)
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_wuxue_type:CreateRootNode(nx_widestr(util_text("ui_guild_battle_wuxue_type")))
  form.tree_wuxue_type:BeginUpdate()
  set_node_prop(root, "first")
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildBattle\\guild_battle_ui_power_tree.ini")
  if not nx_is_valid(ini) then
    return
  end
  local main_count = ini:GetSectionCount()
  for i = 0, main_count - 1 do
    local main_name = ini:GetSectionByIndex(i)
    local main_root = root:CreateNode(nx_widestr(util_text(main_name)))
    set_node_prop(main_root, "second")
    main_root.main_type = nx_number(i) + 1
    local sub_count = ini:GetSectionItemCount(i)
    for j = 0, sub_count - 1 do
      local sub_name = ini:GetSectionItemValue(i, j)
      local sub_root = main_root:CreateNode(nx_widestr(util_text(sub_name)))
      set_node_prop(sub_root, "third")
      sub_root.main_type = nx_number(i) + 1
      sub_root.sub_type = nx_number(j) + 1
    end
  end
  root.Expand = true
  form.tree_wuxue_type:EndUpdate()
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function sift(form)
  local wuxue_gsb = form.groupscrollbox_8
  wuxue_gsb.IsEditMode = true
  local sl_node = form.sl_node
  local sift_main_type = 0
  local sift_sub_type = 0
  if sl_node ~= nil then
    if nx_find_custom(sl_node, "main_type") then
      sift_main_type = sl_node.main_type
    end
    if nx_find_custom(sl_node, "sub_type") then
      sift_sub_type = sl_node.sub_type
    end
  end
  local show_index = 0
  for i = 1, form.wuxue_num do
    local rbtn_name = "rbtn_wuxue_" .. nx_string(i)
    local rbtn = form.groupscrollbox_8:Find(nx_string(rbtn_name))
    if not nx_is_valid(rbtn) then
      return
    end
    rbtn.Visible = false
    local is_show = false
    if rbtn.wuxue_nei_wai_type == 1 then
      if form.cbtn_wuxue_type_nei.Checked then
        is_show = true
      end
    elseif rbtn.wuxue_nei_wai_type == 2 and form.cbtn_wuxue_type_wai.Checked then
      is_show = true
    end
    if rbtn.main_type ~= sift_main_type and sift_main_type ~= 0 then
      is_show = false
    end
    if rbtn.sub_type ~= sift_sub_type and sift_sub_type ~= 0 then
      is_show = false
    end
    if is_show then
      show_index = show_index + 1
      rbtn.Visible = true
      rbtn.Top = math.floor((show_index - 1) / 3) * (rbtn.Height + 5) + 5
      rbtn.Left = math.fmod(show_index - 1, 3) * (rbtn.Width + 10) + 15
    end
  end
  wuxue_gsb.IsEditMode = false
  wuxue_gsb.Height = wuxue_gsb.Height
end
function shile_menpai_yinshi(wuxue_total_type, wuxue_nei_wai_type, types, btn, temp_table)
  if nx_int(wuxue_total_type) == nx_int(1) then
    if nx_int(btn.wuxue_total_type) == nx_int(wuxue_total_type) and nx_int(btn.wuxue_nei_wai_type) == nx_int(wuxue_nei_wai_type) and nx_int(btn.wuxue_menpai_type) == nx_int(types) then
      table.insert(temp_table, nx_string(btn.Name))
    end
  elseif nx_int(wuxue_total_type) == nx_int(2) then
    if nx_int(btn.wuxue_total_type) == nx_int(wuxue_total_type) and nx_int(btn.wuxue_nei_wai_type) == nx_int(wuxue_nei_wai_type) and nx_int(btn.wuxue_shili_type) == nx_int(types) then
      table.insert(temp_table, nx_string(btn.Name))
    end
  elseif nx_int(wuxue_total_type) == nx_int(3) and nx_int(btn.wuxue_total_type) == nx_int(wuxue_total_type) and nx_int(btn.wuxue_nei_wai_type) == nx_int(wuxue_nei_wai_type) and nx_int(btn.wuxue_yinshi_type) == nx_int(types) then
    table.insert(temp_table, nx_string(btn.Name))
  end
end
function on_btn_add_wuxue_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wuxue_str = form.select_wuxue_id
  custom_add_skill(wuxue_str, form.power_id)
end
function on_btn_delete_wuxue_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local data = btn.DataSource
  custom_del_skill(data, form.power_id)
end
function custom_del_skill(index, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(CTS_SUB_GB_MSG_DEL_WUXUE), nx_int(power_id), nx_int(index))
end
function on_btn_show_side_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gb_side = form.groupbox_side
  gb_side.Visible = true
  btn.Visible = false
end
function on_btn_hide_side_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gb_side = form.groupbox_side
  local show_btn = form.btn_show_side
  gb_side.Visible = false
  show_btn.Visible = true
end
function custom_save_equip_plane(strEquipPlane, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(CTS_SUB_GB_MSG_SAVE_EQUIP), nx_int(power_id), nx_string(strEquipPlane))
end
function custom_save_channels_plane(strChannelsPlane, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(CTS_SUB_GB_MSG_SAVE_JINGMAI), nx_int(power_id), nx_string(strChannelsPlane))
end
function custom_save_neigong_plane(nNeiGong, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(CTS_SUB_GB_MSG_SAVE_NEIGONG), nx_int(power_id), nx_int(nNeiGong))
end
function custom_add_skill(strSkill, power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(CTS_SUB_GB_MSG_ADD_WUXUE), nx_int(power_id), nx_string(strSkill))
end
function test_ng()
  updata_player_ng_data(3)
end
function updata_player_ng_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_side_ng.Text = nx_widestr("")
  local nNeiGongIndex = nx_int(arg[1])
  local strConfig = get_ng_config_id(nNeiGongIndex)
  if strConfig == nil or nx_string(strConfig) == nx_string("") then
    form.lbl_side_ng.Text = util_text("ui_choswar_interface_005")
    form.lbl_side_ng.ForeColor = nx_string("255,255,0,0")
    return
  end
  form.lbl_side_ng.Text = nx_widestr(util_text(nx_string(strConfig)))
  form.lbl_side_ng.ForeColor = nx_string("255,197,184,159")
  local gsb = form.groupscrollbox_4
  local gb = gsb:Find("groupbox_neigong_" .. nx_string(nNeiGongIndex))
  if nx_is_valid(gb) then
    local rbtn = gb:Find("cbtn_neigong_" .. nx_string(nNeiGongIndex))
    if nx_is_valid(rbtn) then
      rbtn.Checked = true
    end
  end
end
function get_ng_config_id(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildBattle\\guild_battle_ui_neigong.ini")
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
function updata_player_jm_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_jm_lbl(form)
  local strChannels = nx_string(arg[1])
  local channels_list = util_split_string(strChannels, ",")
  if nx_int(#channels_list) ~= nx_int(8) then
    return
  end
  clear_all_select_jm(form)
  for i = 1, #channels_list do
    local jm_index = nx_number(channels_list[i])
    local jm_id = get_jm_id(jm_index)
    local lbl_name = "lbl_jm_" .. nx_string(i)
    local lbl = form.groupbox_side_jm:Find(lbl_name)
    if nx_is_valid(lbl) then
      lbl.Text = nx_widestr(util_text(jm_id))
      lbl.ForeColor = nx_string("255,197,184,159")
    end
    local cbtn = find_channels_cbtn(form, jm_index)
    if nx_is_valid(cbtn) then
      cbtn.Checked = true
    end
  end
end
function clear_jm_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  local gbox = form.groupbox_side_jm
  if not nx_is_valid(gbox) then
    return
  end
  for i = 1, JINGMAO_MAX_BUM do
    local lbl_name = "lbl_jm_" .. nx_string(i)
    local lbl = gbox:Find(nx_string(lbl_name))
    if nx_is_valid(lbl) then
      lbl.Text = util_text("ui_choswar_interface_005")
      lbl.ForeColor = nx_string("255,255,0,0")
    end
  end
end
function get_jm_id(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildBattle\\guild_battle_ui_jingmai.ini")
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
function find_channels_cbtn(form, index)
  local cbtn = nx_null()
  if not nx_is_valid(form) then
    return cbtn
  end
  local gbox_name = "groupbox_jm_" .. nx_string(index)
  local gbox = form.groupscrollbox_7:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local cbtn_name = "rbtn_jm_" .. nx_string(index)
    cbtn = gbox:Find(nx_string(cbtn_name))
  end
  return cbtn
end
function updata_player_equip_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_equip_lbl(form)
  local strEquip = nx_string(arg[1])
  local equip_list = util_split_string(strEquip, ",")
  if nx_int(#equip_list) ~= nx_int(3) then
    return
  end
  form.lbl_equip.Text = nx_widestr(util_text(gbp_zhuangbei .. equip_list[1]))
  form.lbl_equip.ForeColor = nx_string("255,197,184,159")
  form.lbl_wuqi.Text = nx_widestr(util_text(gbp_zhuangbei .. equip_list[2]))
  form.lbl_wuqi.ForeColor = nx_string("255,197,184,159")
  form.lbl_shangyi.Text = nx_widestr(util_text(gbp_zhuangbei .. equip_list[3]))
  form.lbl_shangyi.ForeColor = nx_string("255,197,184,159")
  local gsb = form.groupscrollbox_10
  local gb_equip = gsb:Find("groupbox_equip_" .. nx_string(equip_list[1]))
  local cbtn_equip = gb_equip:Find("cbtn_equip_" .. nx_string(equip_list[1]))
  if not nx_is_valid(cbtn_equip) then
    return
  end
  cbtn_equip.Checked = true
  local gb_wuqi = gsb:Find("groupbox_wuqi_" .. nx_string(equip_list[2]))
  local cbtn_wuqi = gb_wuqi:Find("cbtn_wuqi_" .. nx_string(equip_list[2]))
  if not nx_is_valid(cbtn_wuqi) then
    return
  end
  cbtn_wuqi.Checked = true
  local gb_shangyi = gsb:Find("groupbox_shangyi_" .. nx_string(equip_list[3]))
  local cbtn_shangyi = gb_shangyi:Find("cbtn_shangyi_" .. nx_string(equip_list[3]))
  if not nx_is_valid(cbtn_shangyi) then
    return
  end
  cbtn_shangyi.Checked = true
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
function updata_player_own_skill_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_taolu_lbl(form)
  local index = 1
  for i = 1, #arg do
    local strSkill = nx_string(arg[i])
    if strSkill ~= "" and strSkill ~= nil then
      local lbl_name = "lbl_own_skill_" .. nx_string(index)
      local lbl = form.groupbox_side_skill:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) then
        lbl.Text = util_text(strSkill)
        lbl.ForeColor = nx_string("255,197,184,159")
      end
      local btn = form.groupbox_side_skill:Find("btn_del_skill_" .. nx_string(i))
      if nx_is_valid(btn) then
        btn.Visible = true
      end
    end
    index = index + 1
  end
end
function clear_taolu_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  local gbox = form.groupbox_side_skill
  if not nx_is_valid(gbox) then
    return
  end
  for i = 1, 3 do
    local lbl_name = "lbl_own_skill_" .. nx_string(i)
    local lbl = gbox:Find(nx_string(lbl_name))
    if nx_is_valid(lbl) then
      lbl.Text = util_text("ui_choswar_interface_005")
      lbl.ForeColor = nx_string("255,255,0,0")
    end
    local btn = gbox:Find("btn_del_skill_" .. nx_string(i))
    if nx_is_valid(btn) then
      btn.Visible = false
    end
  end
end
function inin_taolu_lbl(form)
  local gbox = form.groupbox_side_skill
  if not nx_is_valid(gbox) then
    return
  end
  for i = 1, 3 do
    local lbl_name = "lbl_own_skill_" .. nx_string(i)
    local lbl = gbox:Find(nx_string(lbl_name))
    local btn = gbox:Find("btn_del_skill_" .. nx_string(i))
    if nx_is_valid(btn) and nx_is_valid(lbl) then
      if nx_int(i) <= nx_int(WUXUE_LIMIT_NUM) then
        btn.Visible = true
        lbl.Visible = true
      else
        btn.Visible = false
        lbl.Visible = false
      end
    end
  end
end
function on_rbtn_power_type_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.power_id = nx_int(rbtn.DataSource)
  request_data(form.power_id)
end
function request_data(power_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAMPION_WAR), nx_int(CTS_SUB_GB_MSG_OPENFORM), nx_int(power_id))
end
