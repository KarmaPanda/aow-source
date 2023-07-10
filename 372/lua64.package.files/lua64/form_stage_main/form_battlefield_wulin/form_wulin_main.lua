require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_MAIN = "form_stage_main\\form_battlefield_wulin\\form_wulin_main"
local WuDaoWarClientMsg_RequestMainUI = 118
local wudao_file = "share\\War\\WuDaoWar\\wudao_war.ini"
local max_level_file = "share\\War\\WuDaoWar\\wudao_war_ui_neigong_maxlevel.ini"
local channels_file = "share\\War\\WuDaoWar\\wudao_war_ui_jingmai.ini"
local neigong_file = "share\\War\\WuDaoWar\\wudao_war_ui_neigong.ini"
local unable_image = "gui\\special\\battlefiled_balance\\choose_forbid.png"
local hinttext = "tips_balance_jingmai_stop_click"
local MAX_CHANNELS_NUM = 8
local TOTAL_CHANNELS_NUM = 16
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_WUDAO_WAR) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  if is_in_wudao_fight_scene() or is_in_wudao_fighting() then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text(wudao_in_war)
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local form = nx_value(FORM_WULIN_MAIN)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_WULIN_MAIN, true)
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
  custom_request_wudao_time_info()
  self.rbtn_ready.Checked = true
  init_join_condition_info(self)
  self.rbtn_equip_plane_1.Checked = true
  init_jingmai_grid(self)
  self.rbtn_channels_1.Checked = true
  init_neigong_grid(self)
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
    form.groupbox_neigong.Visible = false
  elseif nx_widestr("rbtn_equip") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = true
    form.groupbox_channels.Visible = false
    form.groupbox_neigong.Visible = false
  elseif nx_widestr("rbtn_channels") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = true
    form.groupbox_neigong.Visible = false
  elseif nx_widestr("rbtn_neigong") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = false
    form.groupbox_equip.Visible = false
    form.groupbox_channels.Visible = false
    form.groupbox_neigong.Visible = true
  end
end
function on_btn_entre_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_entre_wudao_cross_war()
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
  custom_request_wudao_equip_plane(nx_int(rbtn.DataSource))
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
  custom_save_wudao_equip_plane(form)
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
    custom_request_wudao_chennels_plane(nx_int(rbtn.DataSource))
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
  custom_save_wudao_channelsplane(form)
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
function custom_save_wudao_equip_plane(form)
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_SAVE_EQUIP_PLANE), nx_int(form.plane), nx_int(form.equip_index), nx_int(form.wuqi_index), nx_int(form.shangyi_index))
end
function custom_save_wudao_channelsplane(form)
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_SAVE_CHANNELS_PLANE), nx_int(form.channels_plane), nx_string(form.channels_str))
end
function custom_entre_wudao_cross_war()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_NORMAL_TO_CROSS))
end
function custom_request_wudao_equip_plane(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_EQUIP_PLANE), nx_int(index))
end
function custom_request_wudao_chennels_plane(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_CHANNELS_PLANE), nx_int(index))
end
function custom_request_wudao_time_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_RequestMainUI))
end
function rec_wudao_war_equip_data(...)
  local form = nx_value(FORM_WULIN_MAIN)
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
function rec_wudao_war_channels_data(...)
  local form = nx_value(FORM_WULIN_MAIN)
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
function rec_wudao_join_time(...)
  local form = nx_value(FORM_WULIN_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(#arg) < nx_int(6) then
    return
  end
  local apply_begin_time = nx_int64(arg[1])
  local apply_end_time = nx_int64(arg[2])
  local apply_day_time = nx_string(arg[3])
  local sea_begin_time = nx_int64(arg[4])
  local sea_end_time = nx_int64(arg[5])
  local sea_day_time = nx_string(arg[6])
  form.mltbox_18.HtmlText = gui.TextManager:GetFormatText("ui_wudaodahui_participation_regulation_2", get_time_range_text("ui_wudaodahui_participation_regulation_mixed", apply_begin_time, apply_end_time, apply_day_time))
  form.mltbox_19.HtmlText = gui.TextManager:GetFormatText("ui_wudaodahui_participation_regulation_3", get_time_range_text("ui_wudaodahui_participation_regulation_mixed", sea_begin_time, sea_end_time, sea_day_time))
  local group_begin_time = nx_int64(arg[7])
  local group_end_time = nx_int64(arg[8])
  local group_day_time = nx_string(arg[9])
  form.mltbox_20.HtmlText = gui.TextManager:GetFormatText("ui_wudaodahui_participation_regulation_4", get_time_range_text("ui_wudaodahui_participation_regulation_mixed", group_begin_time, group_end_time, group_day_time))
  local final_begin_time = nx_int64(arg[10])
  local final_end_time = nx_int64(arg[11])
  local final_day_time = nx_string(arg[12])
  form.mltbox_21.HtmlText = gui.TextManager:GetFormatText("ui_wudaodahui_participation_regulation_5", get_time_range_text("ui_wudaodahui_participation_regulation_mixed", final_begin_time, final_end_time, final_day_time))
end
function find_select_rbtn(index_1, index_2, index_3)
  local form = nx_value(FORM_WULIN_MAIN)
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
  local form = nx_value(FORM_WULIN_MAIN)
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
  local form = nx_value(FORM_WULIN_MAIN)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 16 do
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
  local form = nx_value(FORM_WULIN_MAIN)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 16 do
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
  local form = nx_value(FORM_WULIN_MAIN)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 16 do
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
  local form = nx_value(FORM_WULIN_MAIN)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 16 do
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
function reflash_select_channels(channels_str)
  local form = nx_value(FORM_WULIN_MAIN)
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
  for i = 1, 16 do
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
  local form = nx_value(FORM_WULIN_MAIN)
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
  for i = 1, 16 do
    local jingmai_id = get_jingmai_id(nx_string(i))
    local grid = get_jingmai_grid(form, nx_int(i))
    if nx_is_valid(grid) then
      local photo, static_data = query_photo_by_configid(nx_string(jingmai_id), nx_int(1))
      grid:AddItem(0, photo, nx_widestr(jingmai_id), 1, -1)
      grid.jingmai_id = jingmai_id
      grid.static_data = static_data
    end
  end
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
function init_neigong_grid(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 16 do
    local neigong_config = get_neigong_config_id(nx_string(i))
    if neigong_config ~= "" then
      local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(neigong_config), nx_int(2))
      local grid, label = find_neigong_grid_and_label(form, i)
      if nx_is_valid(grid) and nx_is_valid(label) then
        grid:AddItem(0, neigong_photo, nx_widestr(neigong_config), 1, -1)
        grid.neigong_config = neigong_config
        grid.static_data = neigong_static_data
        label.Text = nx_widestr(util_text(neigong_config))
      end
    end
  end
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
function init_join_condition_info(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", wudao_file)
  if not nx_is_valid(ini) then
    return
  end
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
  local ini = nx_execute("util_functions", "get_ini", max_level_file)
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex(strConfig)
  if sec_index < 0 then
    return 0, 0
  end
  local max_level = ini:ReadInteger(sec_index, "value", 0)
  local buff_level = ini:ReadInteger(sec_index, "buff_level", 0)
  local wu_xing = ini:ReadInteger(sec_index, "define_deviation", 0)
  return max_level, buff_level, wu_xing
end
function on_btn_1_click(btn)
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "open_form")
end
function get_time_text(time64)
  return nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "get_time_text", time64)
end
function get_time_range_text(tip_text, begin_time, end_time, day_time)
  return nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "get_time_range_text", tip_text, begin_time, end_time, day_time)
end
