require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\switch\\switch_define")
local FORM_READY_BEFORE = "form_stage_main\\form_battlefield\\form_battlefield_ready_before"
local ready_ini = "share\\War\\BalanceWar\\balance_war_ui_neigong.ini"
local skill_file = "share\\War\\BalanceWar\\balance_war_ui_skill.ini"
local SUB_CUSTOMMSG_REQUEST_EQUIP_DATA_IN_WAR = 15
local SUB_CUSTOMMSG_REQUEST_BEFORE_WUXUE = 17
local SUB_CUSTOMMSG_REQUEST_SELECTED_PLANE = 18
local SUB_CUSTOMMSG_REQUEST_SAVE_PLANE_DATA = 19
function open_ready_before_form(...)
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
  local form = nx_value(FORM_READY_BEFORE)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_READY_BEFORE, true)
  end
  form = nx_value(FORM_READY_BEFORE)
  if not nx_is_valid(form) then
    return
  end
end
function main_form_init(self)
  self.Fixed = false
  self.str_wuxue = ""
  self.neigong_plane = 0
  self.equip_plane = 0
  self.channels_plane = 0
  self.wuxue_num = 0
  custom_request_before_wuxue()
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
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_num = get_player_selected_wuxue_number(form)
  if nx_int(select_num) ~= nx_int(3) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_ready_1"), 2)
    end
    return
  end
  set_player_select_wuxue(form)
  local strPlaneData = nx_string(form.str_wuxue) .. nx_string(";")
  strPlaneData = strPlaneData .. nx_string(form.neigong_plane) .. nx_string(";")
  strPlaneData = strPlaneData .. nx_string(form.equip_plane) .. nx_string(";")
  strPlaneData = strPlaneData .. nx_string(form.channels_plane)
  custom_request_save_plane_data(strPlaneData)
end
function on_cbtn_wuxue_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  local selected_num = get_player_selected_wuxue_number(form)
  if nx_int(selected_num) > nx_int(3) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_ready_1"), 2)
    end
    cbtn.Checked = false
  end
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
  reflash_ipt_text(form)
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
  custom_request_equip_plane_before(nx_int(rbtn.DataSource))
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
function custom_request_before_wuxue()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_BEFORE_WUXUE))
end
function custom_request_player_selected_plane()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_SELECTED_PLANE), nx_int(1))
end
function custom_request_save_plane_data(strData)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_SAVE_PLANE_DATA), nx_string(strData))
end
function custom_request_equip_plane_before(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_EQUIP_DATA_IN_WAR), nx_int(2), nx_int(index))
end
function rec_before_wuxue_info(...)
  local form = nx_value(FORM_READY_BEFORE)
  if not nx_is_valid(form) then
    return
  end
  local argNum = table.getn(arg)
  form.wuxue_num = nx_int(argNum)
  form.groupscrollbox_1:DeleteAll()
  for i = 1, argNum do
    if nx_string(arg[i]) ~= " " then
      local gbox = create_ctrl("GroupBox", "gbox_wuxue_" .. nx_string(i), form.groupbox_refer, form.groupscrollbox_1)
      if nx_is_valid(gbox) then
        local cbtn = create_ctrl("CheckButton", "cbtn_wuxue_" .. nx_string(i), form.cbtn_refer, gbox)
        local mltbox = create_ctrl("MultiTextBox", "lbl_wuxue_" .. nx_string(i), form.lbl_refer, gbox)
        if nx_is_valid(cbtn) and nx_is_valid(mltbox) then
          cbtn.index = i
          nx_bind_script(cbtn, nx_current())
          nx_callback(cbtn, "on_checked_changed", "on_cbtn_wuxue_checked_changed")
          local neigong_wuxing, jingmai_wuxing = get_neigong_and_jingmai_wuxing(nx_string(arg[i]))
          local text = util_text(nx_string(arg[i]))
          if nx_int(neigong_wuxing) > nx_int(0) and nx_int(neigong_wuxing) < nx_int(6) then
            text = nx_widestr(text) .. nx_widestr(util_text("desc_wuxue_neigong_define_" .. nx_string(neigong_wuxing)))
          end
          if nx_int(jingmai_wuxing) > nx_int(0) and nx_int(jingmai_wuxing) < nx_int(6) then
            text = nx_widestr(text) .. nx_widestr(util_text("desc_wuxue_jingmai_define_" .. nx_string(jingmai_wuxing)))
          end
          mltbox.HtmlText = nx_widestr(text)
          mltbox.Text = nx_widestr(util_text(text))
        end
      end
    end
  end
  form.groupscrollbox_1.IsEditMode = false
  form.groupscrollbox_1:ResetChildrenYPos()
  custom_request_player_selected_plane()
end
function rec_player_selected_plane(...)
  local form = nx_value(FORM_READY_BEFORE)
  if not nx_is_valid(form) then
    return
  end
  local page_index = nx_int(arg[1])
  if nx_int(page_index) ~= nx_int(1) then
    return
  end
  local strPlane = nx_string(arg[2])
  if nx_string(strPlane) == nx_string(" ") or strPlane == nil then
    set_data_by_default(form)
    return
  end
  local plane_list = util_split_string(strPlane, ";")
  local plane_num = table.getn(plane_list)
  if nx_int(plane_num) ~= nx_int(4) then
    set_data_by_default(form)
    return
  end
  local strWuXue = plane_list[1]
  local wuxue_list = util_split_string(strWuXue, ",")
  local wuxue_num = table.getn(wuxue_list)
  if nx_int(wuxue_num) ~= nx_int(3) then
    set_data_by_default(form)
    return
  end
  local wuxue_cbtn_1 = find_wuxue_cbtn(form, nx_int(wuxue_list[1]))
  local wuxue_cbtn_2 = find_wuxue_cbtn(form, nx_int(wuxue_list[2]))
  local wuxue_cbtn_3 = find_wuxue_cbtn(form, nx_int(wuxue_list[3]))
  local neigong_rbtn = find_neigong_rbtn(form, nx_int(plane_list[2]))
  local equip_rbtn = find_equip_rbtn(form, nx_int(plane_list[3]))
  local channels_rbtn = find_channels_rbtn(form, nx_int(plane_list[4]))
  if nx_is_valid(wuxue_cbtn_1) and nx_is_valid(wuxue_cbtn_2) and nx_is_valid(wuxue_cbtn_3) and nx_is_valid(neigong_rbtn) and nx_is_valid(equip_rbtn) and nx_is_valid(channels_rbtn) then
    wuxue_cbtn_1.Checked = true
    wuxue_cbtn_2.Checked = true
    wuxue_cbtn_3.Checked = true
    neigong_rbtn.Checked = true
    equip_rbtn.Checked = true
    channels_rbtn.Checked = true
  else
    set_data_by_default(form)
  end
end
function rec_player_before_equip_plane(...)
  local form = nx_value(FORM_READY_BEFORE)
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
  if nx_int(page_index) ~= nx_int(2) then
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
    text = nx_widestr(text) .. nx_widestr(util_text("desc_balance_zhuangbei_" .. nx_string(equip_index)))
  end
  if nx_int(shangyi_index) > nx_int(0) and nx_int(shangyi_index) < nx_int(6) then
    text = nx_widestr(text) .. nx_widestr(util_text("desc_balance_shangyi_" .. nx_string(shangyi_index)))
  end
  mltbox.HtmlText = nx_widestr(text)
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
function find_neigong_rbtn(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local rbtn_name = "rbtn_" .. nx_string(index)
  local rbtn = form.groupbox_neigong:Find(nx_string(rbtn_name))
  return rbtn
end
function set_prop_value_to_rbtn(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", ready_ini)
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
        local rbtn = find_neigong_rbtn(form, i)
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
function find_wuxue_cbtn(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local gbox_name = "gbox_wuxue_" .. nx_string(index)
  local gbox = form.groupscrollbox_1:Find(gbox_name)
  if nx_is_valid(gbox) then
    local wuxue_cbtn_name = "cbtn_wuxue_" .. nx_string(index)
    local wuxue_cbtn = gbox:Find(wuxue_cbtn_name)
    return wuxue_cbtn
  end
  return nx_null()
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
function set_data_by_default(form)
  local cbtn_wuxue_1 = find_wuxue_cbtn(form, 1)
  if nx_is_valid(cbtn_wuxue_1) then
    cbtn_wuxue_1.Checked = true
  end
  local cbtn_wuxue_2 = find_wuxue_cbtn(form, 2)
  if nx_is_valid(cbtn_wuxue_2) then
    cbtn_wuxue_2.Checked = true
  end
  local cbtn_wuxue_3 = find_wuxue_cbtn(form, 3)
  if nx_is_valid(cbtn_wuxue_3) then
    cbtn_wuxue_3.Checked = true
  end
  form.rbtn_1.Checked = true
  form.rbtn_equip_1.Checked = true
  form.rbtn_channels_1.Checked = true
end
function reflash_ipt_text(form)
  if not nx_is_valid(form) then
    return
  end
  form.ipt_1.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 1, 3))
  form.ipt_2.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 2, 3))
  form.ipt_3.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 3, 3))
  form.ipt_4.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 4, 3))
  form.ipt_5.Text = nx_widestr(query_neigong_prop_value(form, nx_int(form.neigong_plane), 5, 3))
end
function query_neigong_prop_value(form, rbtn_index, prop_index, value_type)
  if not nx_is_valid(form) then
    return 0
  end
  local rbtn = find_neigong_rbtn(form, rbtn_index)
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
function get_player_selected_wuxue_number(form)
  if not nx_is_valid(form) then
    return
  end
  local count = 0
  for i = 1, form.wuxue_num do
    local wuxue_cbtn = find_wuxue_cbtn(form, i)
    if nx_is_valid(wuxue_cbtn) and wuxue_cbtn.Checked then
      count = count + 1
    end
  end
  return count
end
function set_player_select_wuxue(form)
  if not nx_is_valid(form) then
    return
  end
  form.str_wuxue = ""
  local flag = 0
  for i = 1, form.wuxue_num do
    local wuxue_cbtn = find_wuxue_cbtn(form, i)
    if nx_is_valid(wuxue_cbtn) and wuxue_cbtn.Checked then
      flag = flag + 1
      local temp_data = wuxue_cbtn.index
      if nx_int(flag) == nx_int(3) then
        form.str_wuxue = form.str_wuxue .. nx_string(temp_data)
      else
        form.str_wuxue = form.str_wuxue .. nx_string(temp_data) .. nx_string(",")
      end
    end
  end
end
function get_neigong_and_jingmai_wuxing(strWuXue)
  local ini = nx_execute("util_functions", "get_ini", skill_file)
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(strWuXue))
  if sec_index < 0 then
    return 0, 0
  end
  local neigong_wuxing = ini:ReadInteger(sec_index, "deviation_neigong", 0)
  local jingmai_wuxing = ini:ReadInteger(sec_index, "deviation_jingmai", 0)
  return neigong_wuxing, jingmai_wuxing
end
function close_form()
  local form = nx_value(FORM_READY_BEFORE)
  if nx_is_valid(form) then
    form:Close()
  end
end
