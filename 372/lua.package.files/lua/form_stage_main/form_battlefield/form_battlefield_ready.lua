require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
require("form_stage_main\\form_battlefield\\form_battlefield_balance")
local FORM_READY = "form_stage_main\\form_battlefield\\form_battlefield_ready"
local FORM_BEFORE_READY = "form_stage_main\\form_battlefield\\form_battlefield_ready_before"
local ready_ini = "share\\War\\BalanceWar\\balance_war_ui_neigong.ini"
local balance_file = "share\\War\\BalanceWar\\balance_war.ini"
local skill_file = "share\\War\\BalanceWar\\balance_war_ui_skill.ini"
local SUB_CUSTOMMSG_REQUEST_WUXUE = 3
local SUB_CUSTOMMSG_SEND_SELECT_DATA = 4
local SUB_CUSTOMMSG_REQUEST_EQUIP_DATA_IN_WAR = 15
local SUB_CUSTOMMSG_REQUEST_SELECTED_PLANE = 18
local SELECT_WUXUE = 3
local MAX_PROP_NUM = 5
function open_balance_war_form(...)
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
  local form_ready_before = nx_value(FORM_BEFORE_READY)
  if nx_is_valid(form_ready_before) then
    form_ready_before:Close()
  end
  local form = nx_value(FORM_READY)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_READY, true)
  end
  form = nx_value(FORM_READY)
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
  self.Fixed = false
  self.equip_plane = 0
  self.channels_plane = 0
  self.neigong_plane = 0
  self.wuxue_num = 0
  self.str_wuxue = ""
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
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("BalanceWarIsInWar", "int", self, nx_current(), "close_balance_form")
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("BalanceWarIsInWar", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
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
    return
  end
  local cbtn_index = cbtn.index
  local mltbox = find_wuxue_left_mltbox(form, nx_int(cbtn_index))
  if nx_is_valid(mltbox) then
    local left_times = nx_int(mltbox.DataSource)
    if nx_int(left_times) <= nx_int(0) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_ready_3"), 2)
      end
      cbtn.Checked = false
    end
  end
end
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_num = get_player_selected_wuxue_number(form)
  if nx_int(select_num) ~= nx_int(SELECT_WUXUE) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_ready_1"), 2)
    end
    return
  end
  local is_available = check_select_wuxue(form)
  if not is_available then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_ready_4"), 2)
    end
    return
  end
  set_player_select_wuxue(form)
  local flag = check_prop_value(form)
  if not flag then
    local text = util_text("ui_balance_war_prop_error")
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "balance_war_set_default_prop")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "balance_war_set_default_prop_confirm_return")
    if res ~= "ok" then
      dialog:Close()
      return
    end
    dialog:Close()
    local default_btn = form.btn_recet
    if nx_is_valid(default_btn) then
      on_btn_recet_click(btn)
      return
    end
  end
  get_prop_value_str(form)
  custom_send_select_data(form)
  local form_balance = nx_value("form_stage_main\\form_battlefield\\form_battlefield_balance")
  if nx_is_valid(form_balance) then
    form_balance:Close()
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
function on_btn_max_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local custom_data = btn.DataSource
  if nx_int(custom_data) < nx_int(0) or nx_int(custom_data) > nx_int(MAX_PROP_NUM) then
    return
  end
  local ipt_name = "ipt_" .. nx_string(custom_data)
  local ipt = form.groupbox_ready:Find(nx_string(ipt_name))
  if not nx_is_valid(ipt) then
    return
  end
  local ipt_value = nx_int(ipt.Text)
  local max_prop = query_neigong_prop_value(form, nx_int(form.neigong_plane), custom_data, 1)
  if nx_int(ipt_value) == nx_int(max_prop) then
    btn.Enabled = false
    return
  end
  local left_total_prop = nx_int(form.lbl_total.Text)
  if nx_int(max_prop) <= nx_int(left_total_prop) then
    ipt.Text = nx_widestr(max_prop)
    form.lbl_total.Text = nx_widestr(left_total_prop - nx_int(max_prop))
  else
    ipt.Text = nx_widestr(left_total_prop)
    form.lbl_total.Text = nx_widestr(0)
  end
  btn.Enabled = false
end
function on_btn_recet_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  init_ipt_text(form)
end
function on_btn_self_define_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.ipt_1.Text = nx_widestr("")
  form.ipt_2.Text = nx_widestr("")
  form.ipt_3.Text = nx_widestr("")
  form.ipt_4.Text = nx_widestr("")
  form.ipt_5.Text = nx_widestr("")
  form.btn_bili.Enabled = true
  form.btn_shenfa.Enabled = true
  form.btn_neixi.Enabled = true
  form.btn_gangqi.Enabled = true
  form.btn_tipo.Enabled = true
end
function custom_request_wuxue()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_WUXUE))
end
function custom_send_select_data(form)
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_SEND_SELECT_DATA), nx_string(form.str_wuxue), nx_int(form.neigong_plane), nx_int(form.equip_plane), nx_int(form.channels_plane), nx_string(form.str_prop))
end
function custom_request_equip_plane_in_war(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_EQUIP_DATA_IN_WAR), nx_int(1), nx_int(index))
end
function custom_request_player_plane_have()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(SUB_CUSTOMMSG_REQUEST_SELECTED_PLANE), nx_int(2))
end
function rec_wuxue_info(...)
  local form = nx_value(FORM_READY)
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
        local mltbox_left = create_ctrl("MultiTextBox", "mltbox_wuxue_" .. nx_string(i), form.mltbox_refer, gbox)
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
  custom_request_player_plane_have()
end
function rec_equip_data_in_war(...)
  local form = nx_value(FORM_READY)
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
    text = nx_widestr(text) .. nx_widestr(util_text("desc_balance_zhuangbei_" .. nx_string(equip_index)))
  end
  if nx_int(shangyi_index) > nx_int(0) and nx_int(shangyi_index) < nx_int(6) then
    text = nx_widestr(text) .. nx_widestr(util_text("desc_balance_shangyi_" .. nx_string(shangyi_index)))
  end
  mltbox.HtmlText = nx_widestr(text)
end
function rec_player_plane_have(...)
  local form = nx_value(FORM_READY)
  if not nx_is_valid(form) then
    return
  end
  local page_index = nx_int(arg[1])
  if nx_int(page_index) ~= nx_int(2) then
    return
  end
  local strPlane = nx_string(arg[2])
  if nx_string(strPlane) == nx_string(" ") or strPlane == nil then
    read_default_set(form)
    return
  end
  local plane_list = util_split_string(strPlane, ";")
  local plane_num = table.getn(plane_list)
  if nx_int(plane_num) ~= nx_int(4) then
    read_default_set(form)
    return
  end
  local strWuXue = plane_list[1]
  local wuxue_list = util_split_string(strWuXue, ",")
  local wuxue_num = table.getn(wuxue_list)
  if nx_int(wuxue_num) ~= nx_int(3) then
    read_default_set(form)
    return
  end
  local wuxue_cbtn_1 = nx_execute(FORM_BEFORE_READY, "find_wuxue_cbtn", form, nx_int(wuxue_list[1]))
  local wuxue_cbtn_2 = nx_execute(FORM_BEFORE_READY, "find_wuxue_cbtn", form, nx_int(wuxue_list[2]))
  local wuxue_cbtn_3 = nx_execute(FORM_BEFORE_READY, "find_wuxue_cbtn", form, nx_int(wuxue_list[3]))
  local neigong_rbtn = find_rbtn(form, nx_int(plane_list[2]))
  local equip_rbtn = nx_execute(FORM_BEFORE_READY, "find_equip_rbtn", form, nx_int(plane_list[3]))
  local channels_rbtn = nx_execute(FORM_BEFORE_READY, "find_channels_rbtn", form, nx_int(plane_list[4]))
  if nx_is_valid(wuxue_cbtn_1) and nx_is_valid(wuxue_cbtn_2) and nx_is_valid(wuxue_cbtn_3) and nx_is_valid(neigong_rbtn) and nx_is_valid(equip_rbtn) and nx_is_valid(channels_rbtn) then
    wuxue_cbtn_1.Checked = true
    wuxue_cbtn_2.Checked = true
    wuxue_cbtn_3.Checked = true
    neigong_rbtn.Checked = true
    equip_rbtn.Checked = true
    channels_rbtn.Checked = true
  else
    read_default_set(form)
  end
end
function rec_updata_wuxue_left_times(...)
  local form = nx_value(FORM_READY)
  if not nx_is_valid(form) then
    return
  end
  local strLefts = nx_string(arg[1])
  if nx_string(strLefts) == nx_string("") or nx_string(strLefts) == nil then
    return
  end
  local left_list = util_split_string(strLefts, ",")
  local left_list_num = table.getn(left_list)
  if nx_int(left_list_num) ~= nx_int(form.wuxue_num) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 1, left_list_num do
    local left_times = nx_int(left_list[i])
    local left_mltbox = find_wuxue_left_mltbox(form, i)
    if nx_is_valid(left_mltbox) then
      gui.TextManager:Format_SetIDName("ui_balance_wuxue_left_times")
      gui.TextManager:Format_AddParam(nx_int(left_times))
      left_mltbox.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
      left_mltbox.DataSource = left_list[i]
    end
    if nx_int(left_times) <= nx_int(0) then
      local wuxue_cbtn = nx_execute(FORM_BEFORE_READY, "find_wuxue_cbtn", form, i)
      if nx_is_valid(wuxue_cbtn) and wuxue_cbtn.Checked then
        wuxue_cbtn.Checked = false
      end
    end
  end
end
function set_player_select_wuxue(form)
  if not nx_is_valid(form) then
    return
  end
  form.str_wuxue = ""
  local flag = 0
  for i = 1, form.wuxue_num do
    local gbox_name = "gbox_wuxue_" .. nx_string(i)
    local gbox = form.groupscrollbox_1:Find(gbox_name)
    if nx_is_valid(gbox) then
      local wuxue_cbtn_name = "cbtn_wuxue_" .. nx_string(i)
      local wuxue_cbtn = gbox:Find(wuxue_cbtn_name)
      if nx_is_valid(wuxue_cbtn) and wuxue_cbtn.Checked then
        flag = flag + 1
        local temp_data = wuxue_cbtn.index
        if nx_int(flag) == nx_int(SELECT_WUXUE) then
          form.str_wuxue = form.str_wuxue .. nx_string(temp_data)
        else
          form.str_wuxue = form.str_wuxue .. nx_string(temp_data) .. nx_string(";")
        end
      end
    end
  end
end
function get_player_selected_wuxue_number(form)
  if not nx_is_valid(form) then
    return
  end
  local count = 0
  for i = 1, form.wuxue_num do
    local gbox_name = "gbox_wuxue_" .. nx_string(i)
    local gbox = form.groupscrollbox_1:Find(gbox_name)
    if nx_is_valid(gbox) then
      local wuxue_cbtn_name = "cbtn_wuxue_" .. nx_string(i)
      local wuxue_cbtn = gbox:Find(wuxue_cbtn_name)
      if nx_is_valid(wuxue_cbtn) and wuxue_cbtn.Checked then
        count = count + 1
      end
    end
  end
  return count
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
  form.btn_bili.Enabled = false
  form.btn_shenfa.Enabled = false
  form.btn_neixi.Enabled = false
  form.btn_gangqi.Enabled = false
  form.btn_tipo.Enabled = false
  form.lbl_total.Text = nx_widestr(0)
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
function check_prop_value(form)
  if not nx_is_valid(form) then
    return false
  end
  for i = 1, MAX_PROP_NUM do
    local ipt_name = "ipt_" .. nx_string(i)
    local ipt = form.groupbox_ready:Find(nx_string(ipt_name))
    if not nx_is_valid(ipt) then
      return false
    end
    local temp_data = nx_int(ipt.Text)
    local prop_max = query_neigong_prop_value(form, form.neigong_plane, i, 1)
    local prop_min = query_neigong_prop_value(form, form.neigong_plane, i, 2)
    if nx_int(temp_data) <= nx_int(prop_max) and nx_int(temp_data) >= nx_int(prop_min) then
    else
      return false
    end
  end
  return true
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
function close_balance_form(form, propname, proptype, value)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(value) == nx_int(0) then
    form:Close()
  end
end
function close_form(form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function read_default_set(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", balance_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("player_default")
  if sec_index < 0 then
    return
  end
  local select_wuxue = ini:ReadString(sec_index, "wuxue", "")
  local select_wuxue_list = util_split_string(select_wuxue, ";")
  local select_wuxue_number = table.getn(select_wuxue_list)
  for i = 1, select_wuxue_number do
    local gbox_name = "gbox_wuxue_" .. nx_string(select_wuxue_list[i])
    local gbox = form.groupscrollbox_1:Find(gbox_name)
    if nx_is_valid(gbox) then
      local wuxue_cbtn_name = "cbtn_wuxue_" .. nx_string(select_wuxue_list[i])
      local wuxue_cbtn = gbox:Find(wuxue_cbtn_name)
      if nx_is_valid(wuxue_cbtn) then
        wuxue_cbtn.Checked = true
      end
    end
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
function find_wuxue_left_mltbox(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local gbox_name = "gbox_wuxue_" .. nx_string(index)
  local gbox = form.groupscrollbox_1:Find(gbox_name)
  if nx_is_valid(gbox) then
    local mltbox_name = "mltbox_wuxue_" .. nx_string(index)
    local mltbox = gbox:Find(mltbox_name)
    return mltbox
  end
  return nx_null()
end
function close_ready_form()
  local form = nx_value(FORM_READY)
  if nx_is_valid(form) then
    form:Close()
  end
end
function check_select_wuxue(form)
  if not nx_is_valid(form) then
    return false
  end
  for i = 1, form.wuxue_num do
    local wuxue_cbtn = nx_execute(FORM_BEFORE_READY, "find_wuxue_cbtn", form, i)
    if nx_is_valid(wuxue_cbtn) and wuxue_cbtn.Checked then
      local mltbox = find_wuxue_left_mltbox(form, i)
      if nx_is_valid(mltbox) then
        local left_times = nx_int(mltbox.DataSource)
        if nx_int(left_times) <= nx_int(0) then
          return false
        end
      end
    end
  end
  return true
end
function on_lbl_title_click(Label)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
