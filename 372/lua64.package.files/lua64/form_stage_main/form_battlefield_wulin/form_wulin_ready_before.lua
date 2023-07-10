require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_READY_BEFORE = "form_stage_main\\form_battlefield_wulin\\form_wulin_ready_before"
function open_wudao_ready_before_form(...)
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
  local form = nx_value(FORM_WULIN_READY_BEFORE)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_WULIN_READY_BEFORE, true)
  end
end
function main_form_init(self)
  self.Fixed = false
  self.equip_plane = 0
  self.channels_plane = 0
  self.neigong_plane = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  custom_request_player_wudao_before_selected()
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
  local strPlaneData = nx_string(form.neigong_plane) .. nx_string(";")
  strPlaneData = strPlaneData .. nx_string(form.equip_plane) .. nx_string(";")
  strPlaneData = strPlaneData .. nx_string(form.channels_plane)
  custom_save_before_select_data(strPlaneData)
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
  custom_request_wudao_equip_plane_in_war(nx_int(rbtn.DataSource))
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
function custom_save_before_select_data(strData)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_SAVE_BEFORE_PLANE), nx_string(strData))
end
function custom_request_wudao_equip_plane_in_war(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_EQUIP_PLANE_IN_WAR), nx_int(2), nx_int(index))
end
function custom_request_player_wudao_before_selected()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_BEFORE_SELECT_PLANE), nx_int(1))
end
function rec_player_wudao_selected_plane(...)
  local form = nx_value(FORM_WULIN_READY_BEFORE)
  if not nx_is_valid(form) then
    return
  end
  local page_index = nx_int(arg[1])
  if nx_int(page_index) ~= nx_int(1) then
    return
  end
  local strPlane = nx_string(arg[2])
  if nx_string(strPlane) == nx_string("") or strPlane == nil then
    set_data_by_default(form)
    return
  end
  local plane_list = util_split_string(strPlane, ";")
  local plane_num = table.getn(plane_list)
  if nx_int(plane_num) ~= nx_int(3) then
    set_data_by_default(form)
    return
  end
  local neigong_rbtn = find_neigong_rbtn(form, nx_int(plane_list[1]))
  local equip_rbtn = find_equip_rbtn(form, nx_int(plane_list[2]))
  local channels_rbtn = find_channels_rbtn(form, nx_int(plane_list[3]))
  if nx_is_valid(neigong_rbtn) and nx_is_valid(equip_rbtn) and nx_is_valid(channels_rbtn) then
    neigong_rbtn.Checked = true
    equip_rbtn.Checked = true
    channels_rbtn.Checked = true
  else
    set_data_by_default(form)
  end
end
function rec_player_wudao_before_equip_plane(...)
  local form = nx_value(FORM_WULIN_READY_BEFORE)
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
    text = nx_string(text) .. nx_string(util_text("desc_balance_zhuangbei_" .. nx_string(equip_index)))
  end
  if nx_int(shangyi_index) > nx_int(0) and nx_int(shangyi_index) < nx_int(6) then
    text = nx_string(text) .. nx_string(util_text("desc_balance_shangyi_" .. nx_string(shangyi_index)))
  end
  mltbox.HtmlText = nx_widestr(text)
end
function set_data_by_default(form)
  form.rbtn_1.Checked = true
  form.rbtn_equip_1.Checked = true
  form.rbtn_channels_1.Checked = true
end
function find_neigong_rbtn(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local rbtn_name = "rbtn_" .. nx_string(index)
  local rbtn = form.groupbox_neigong:Find(nx_string(rbtn_name))
  return rbtn
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
function close_form()
  local form = nx_value(FORM_WULIN_READY_BEFORE)
  if nx_is_valid(form) then
    form:Close()
  end
end
