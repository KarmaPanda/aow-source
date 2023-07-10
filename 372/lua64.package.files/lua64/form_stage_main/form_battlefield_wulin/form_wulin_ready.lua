require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local wudao_file = "share\\War\\WuDaoWar\\wudao_war.ini"
local neigong_ini = "share\\War\\WuDaoWar\\wudao_war_ui_neigong.ini"
local FORM_WULIN_READY = "form_stage_main\\form_battlefield_wulin\\form_wulin_ready"
function close_form()
  local form = nx_value(FORM_WULIN_READY)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_wudao_ready_form(...)
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
  local form = nx_value(FORM_WULIN_READY)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_WULIN_READY, true)
  end
  form = nx_value(FORM_WULIN_READY)
  if not nx_is_valid(form) then
    return
  end
  form.left_time = arg[1]
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", form)
    game_timer:Register(1000, -1, nx_current(), "update_left_time", form, -1, -1)
  end
end
function main_form_init(self)
  self.Fixed = true
  self.equip_plane = 0
  self.channels_plane = 0
  self.neigong_plane = 0
  self.str_prop = ""
  custom_request_wuxue()
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  set_prop_value_to_rbtn(self)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  get_prop_value_str(form)
  custom_send_select_data(form)
end
function on_rbtn_neigong_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.neigong_plane = rbtn.DataSource
  init_ipt_text(form)
end
function on_rbtn_equip_plane_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.equip_plane = rbtn.DataSource
  custom_request_equip_plane_in_war(nx_int(rbtn.DataSource))
end
function on_rbtn_channels_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.channels_plane = rbtn.DataSource
end
function custom_request_wuxue()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_WUXUE))
end
function custom_send_select_data(form)
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_SELECT_PLANE_DATA), nx_int(form.neigong_plane), nx_int(form.equip_plane), nx_int(form.channels_plane), nx_string(form.str_prop))
end
function custom_request_equip_plane_in_war(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_EQUIP_PLANE_IN_WAR), nx_int(1), nx_int(index))
end
function custom_request_player_plane_have()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_BEFORE_SELECT_PLANE), nx_int(2))
end
function rec_wuxue_info(...)
  local form = nx_value(FORM_WULIN_READY)
  if not nx_is_valid(form) then
    return
  end
  local argNum = table.getn(arg)
  form.groupscrollbox_1:DeleteAll()
  for i = 1, argNum do
    local wuxue_info = nx_string(arg[i])
    if wuxue_info ~= "" then
      local wuxue_info_list = util_split_string(wuxue_info, ",")
      if nx_int(#wuxue_info_list) == nx_int(3) then
        local wuxue_id = wuxue_info_list[1]
        local neigong_wuxing = nx_int(wuxue_info_list[2])
        local jingmai_wuxing = nx_int(wuxue_info_list[3])
        local gbox = create_ctrl("GroupBox", "gbox_wuxue_" .. nx_string(i), form.groupbox_refer, form.groupscrollbox_1)
        if nx_is_valid(gbox) then
          local mltbox = create_ctrl("MultiTextBox", "lbl_wuxue_" .. nx_string(i), form.lbl_refer, gbox)
          local text = util_text(wuxue_id)
          if nx_int(neigong_wuxing) > nx_int(0) and nx_int(neigong_wuxing) < nx_int(6) then
            text = nx_string(text) .. nx_string(util_text("desc_wuxue_neigong_define_" .. nx_string(neigong_wuxing)))
          end
          if nx_int(jingmai_wuxing) > nx_int(0) and nx_int(jingmai_wuxing) < nx_int(6) then
            text = nx_string(text) .. nx_string(util_text("desc_wuxue_jingmai_define_" .. nx_string(jingmai_wuxing)))
          end
          mltbox.HtmlText = nx_widestr(text)
        end
      end
    end
  end
  form.groupscrollbox_1.IsEditMode = false
  form.groupscrollbox_1:ResetChildrenYPos()
  custom_request_player_plane_have()
end
function rec_equip_data_in_war(...)
  local form = nx_value(FORM_WULIN_READY)
  if not nx_is_valid(form) then
    return
  end
  local mltbox = form.mltbox_2
  if not nx_is_valid(mltbox) then
    return
  end
  mltbox.HtmlText = nx_widestr("")
  local argNum = table.getn(arg)
  if nx_int(argNum) < nx_int(4) then
    return
  end
  local page_index = nx_int(arg[1])
  if nx_int(page_index) ~= nx_int(1) then
    return
  end
  local equip_index = nx_int(arg[2])
  local wuqi_index = nx_int(arg[3])
  local shangyi_index = nx_int(arg[4])
  local text = ""
  if nx_int(wuqi_index) > nx_int(0) and nx_int(wuqi_index) < nx_int(6) then
    text = util_text("desc_balance_wuqi_" .. nx_string(wuqi_index))
  end
  if nx_int(equip_index) > nx_int(0) and nx_int(equip_index) < nx_int(6) then
    text = nx_string(text) .. nx_string(util_text("desc_balance_zhuangbei_" .. nx_string(equip_index)))
  end
  if nx_int(shangyi_index) > nx_int(0) and nx_int(shangyi_index) < nx_int(6) then
    text = nx_string(text) .. nx_string(util_text("desc_balance_shangyi_" .. nx_string(shangyi_index)))
  end
  mltbox.HtmlText = nx_widestr(text)
end
function rec_player_plane_have(...)
  local form = nx_value(FORM_WULIN_READY)
  if not nx_is_valid(form) then
    return
  end
  local page_index = nx_int(arg[1])
  if nx_int(page_index) ~= nx_int(2) then
    return
  end
  local strPlane = nx_string(arg[2])
  if nx_string(strPlane) == nx_string("") or strPlane == nil then
    read_default_set(form)
    return
  end
  local plane_list = util_split_string(strPlane, ";")
  local plane_num = table.getn(plane_list)
  if nx_int(plane_num) ~= nx_int(3) then
    read_default_set(form)
    return
  end
  local neigong_rbtn = find_rbtn(form, nx_int(plane_list[1]))
  local equip_rbtn = find_equip_rbtn(form, nx_int(plane_list[2]))
  local channels_rbtn = find_channels_rbtn(form, nx_int(plane_list[3]))
  if nx_is_valid(neigong_rbtn) and nx_is_valid(equip_rbtn) and nx_is_valid(channels_rbtn) then
    neigong_rbtn.Checked = true
    equip_rbtn.Checked = true
    channels_rbtn.Checked = true
  else
    read_default_set(form)
  end
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
function init_ipt_text(form)
  if not nx_is_valid(form) then
    return
  end
  local rbtn = find_rbtn(form, form.neigong_plane)
  if not nx_is_valid(rbtn) then
    return
  end
  form.ipt_1.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 1, 3))
  form.ipt_2.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 2, 3))
  form.ipt_3.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 3, 3))
  form.ipt_4.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 4, 3))
  form.ipt_5.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 5, 3))
end
function set_prop_value_to_rbtn(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", neigong_ini)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return
  end
  local key_num = ini:GetSectionItemCount(sec_count)
  for i = 1, key_num do
    local key_value = ini:GetSectionItemValue(sec_count, i - 1)
    if nx_string(key_value) ~= nx_string("") then
      local key_value_list = util_split_string(key_value, ";")
      local key_value_list_num = table.getn(key_value_list)
      if nx_int(key_value_list_num) == nx_int(6) then
        local rbtn = find_rbtn(form, i)
        if nx_is_valid(rbtn) then
          rbtn.bili = key_value_list[2]
          rbtn.shenfa = key_value_list[3]
          rbtn.neixi = key_value_list[4]
          rbtn.gangqi = key_value_list[5]
          rbtn.tipo = key_value_list[6]
        end
      end
    end
  end
end
function get_prop_value_str(form)
  if not nx_is_valid(form) then
    return
  end
  form.str_prop = ""
  form.str_prop = form.str_prop .. nx_string(form.ipt_1.Text) .. nx_string(";")
  form.str_prop = form.str_prop .. nx_string(form.ipt_2.Text) .. nx_string(";")
  form.str_prop = form.str_prop .. nx_string(form.ipt_3.Text) .. nx_string(";")
  form.str_prop = form.str_prop .. nx_string(form.ipt_4.Text) .. nx_string(";")
  form.str_prop = form.str_prop .. nx_string(form.ipt_5.Text)
end
function find_rbtn(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local rbtn_name = "rbtn_" .. nx_string(index)
  local rbtn = form.groupbox_neigong:Find(nx_string(rbtn_name))
  return rbtn
end
function query_neigong_prop_value(form, rbtn_index, prop_index, value_type)
  if not nx_is_valid(form) then
    return 0
  end
  local rbtn = find_rbtn(form, rbtn_index)
  if not nx_is_valid(rbtn) then
    return 0
  end
  if nx_int(prop_index) == nx_int(1) then
    if not nx_find_custom(rbtn, "bili") then
      return 0
    end
    local str_bili = rbtn.bili
    local bili_list = util_split_string(str_bili, ",")
    local bili_list_num = table.getn(bili_list)
    if nx_int(value_type) > nx_int(bili_list_num) then
      return 0
    end
    return bili_list[value_type]
  elseif nx_int(prop_index) == nx_int(2) then
    if not nx_find_custom(rbtn, "shenfa") then
      return 0
    end
    local str_shenfa = rbtn.shenfa
    local shenfa_list = util_split_string(str_shenfa, ",")
    local shenfa_list_num = table.getn(shenfa_list)
    if nx_int(value_type) > nx_int(shenfa_list_num) then
      return 0
    end
    return shenfa_list[value_type]
  elseif nx_int(prop_index) == nx_int(3) then
    if not nx_find_custom(rbtn, "neixi") then
      return 0
    end
    local str_neixi = rbtn.neixi
    local neixi_list = util_split_string(str_neixi, ",")
    local neixi_list_num = table.getn(neixi_list)
    if nx_int(value_type) > nx_int(neixi_list_num) then
      return 0
    end
    return neixi_list[value_type]
  elseif nx_int(prop_index) == nx_int(4) then
    if not nx_find_custom(rbtn, "gangqi") then
      return 0
    end
    local str_gangqi = rbtn.gangqi
    local gangqi_list = util_split_string(str_gangqi, ",")
    local gangqi_list_num = table.getn(gangqi_list)
    if nx_int(value_type) > nx_int(gangqi_list_num) then
      return 0
    end
    return gangqi_list[value_type]
  elseif nx_int(prop_index) == nx_int(5) then
    if not nx_find_custom(rbtn, "tipo") then
      return 0
    end
    local str_tipo = rbtn.tipo
    local tipo_list = util_split_string(str_tipo, ",")
    local tipo_list_num = table.getn(tipo_list)
    if nx_int(value_type) > nx_int(tipo_list_num) then
      return 0
    end
    return tipo_list[value_type]
  end
  return 0
end
function update_left_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.left_time = form.left_time - 1
  if nx_int(form.left_time) <= nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "update_left_time", form)
    end
    form:Close()
  else
    form.mltbox_time.HtmlText = nx_widestr(form.left_time)
  end
end
function read_default_set(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", wudao_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("player_default")
  if sec_index < 0 then
    return
  end
  local select_neigong = ini:ReadInteger(sec_index, "neigong", 0)
  local neigong_rbtn_name = "rbtn_" .. nx_string(select_neigong)
  local neigong_rbtn = form.groupbox_neigong:Find(neigong_rbtn_name)
  if nx_is_valid(neigong_rbtn) then
    neigong_rbtn.Checked = true
  end
  local select_equip = ini:ReadInteger(sec_index, "equip_index", 0)
  local equip_rbtn_name = "rbtn_equip_" .. nx_string(select_equip)
  local equip_rbtn = form.groupbox_equip:Find(equip_rbtn_name)
  if nx_is_valid(equip_rbtn) then
    equip_rbtn.Checked = true
  end
  local select_channels = ini:ReadInteger(sec_index, "channels_index", 0)
  local channels_rbtn_name = "rbtn_channels_" .. nx_string(select_channels)
  local channels_rbtn = form.groupbox_channels:Find(channels_rbtn_name)
  if nx_is_valid(channels_rbtn) then
    channels_rbtn.Checked = true
  end
end
function close_ready_form()
  local form = nx_value(FORM_WULIN_READY)
  if nx_is_valid(form) then
    form:Close()
  end
end
function find_equip_rbtn(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local rbtn_name = "rbtn_equip_" .. nx_string(index)
  local rbtn = form.groupbox_equip:Find(nx_string(rbtn_name))
  return rbtn
end
function find_channels_rbtn(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local rbtn_name = "rbtn_channels_" .. nx_string(index)
  local rbtn = form.groupbox_channels:Find(nx_string(rbtn_name))
  return rbtn
end
