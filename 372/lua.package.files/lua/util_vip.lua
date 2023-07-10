require("custom_sender")
require("share\\client_custom_define")
require("util_functions")
G_CMD_OPEN_AUTO_PATH_FIND = 1
G_CMD_OPEN_CLOSE_PATH_FIND = 2
G_CMD_BUY_VIP = 3
G_CMD_LOGIN_INFO = 4
G_CMD_GET_VIPPRICE = 7
VIP_GET_PRIZE_INFO = 8
VIP_GIVE_PRIZE = 9
VIP_KICK = 10
g_buy_vip_price = 30
g_buy_vip_time = 2592000
VT_NORMAL = 1
VT_JINGXIU = 2
VIR_TYPE = 0
VIR_STATUS = 1
VIR_VALID_TIME = 2
VIR_FLAG = 3
VIR_TOTAL_TIME = 4
VIR_PRIZE_TIME = 5
function on_server_msg(cmd, ...)
  cmd = nx_number(cmd)
  if cmd == G_CMD_LOGIN_INFO then
  elseif cmd == VIP_GET_PRIZE_INFO then
    nx_execute("form_stage_main\\form_zhizunvip\\form_vip_reward", "on_server_msg", cmd, ...)
  end
end
function is_week_get_prize()
  local vip_module = nx_value("VipModule")
  if not nx_is_valid(vip_module) then
    return false
  end
  local info = vip_module:QueryVipInfo(VT_NORMAL, VIR_PRIZE_TIME)
  if table.getn(info) < 1 then
    return false
  end
  return nx_number(info[1]) > nx_number(vip_module:GetServerSecond())
end
function is_vip(player, vip_type)
  local vip_module = nx_value("VipModule")
  if not nx_is_valid(vip_module) then
    return false
  end
  return vip_module:IsVip(vip_type)
end
function get_vip_time(player, vip_type)
  local vip_module = nx_value("VipModule")
  if not nx_is_valid(vip_module) then
    return nx_int64(0)
  end
  return vip_module:GetVipValidTime(vip_type)
end
function get_vip_revert_time(vip_type)
  local vip_module = nx_value("VipModule")
  if not nx_is_valid(vip_module) then
    return nx_int64(0)
  end
  return vip_module:GetVipRevertTime(vip_type)
end
function is_auto_find_path()
  local vip_module = nx_value("VipModule")
  if not nx_is_valid(vip_module) then
    return false
  end
  return vip_module:IsAutoFindPath()
end
function set_vip_auto_find_path(bAuto)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not is_vip(player, VT_NORMAL) then
    return
  end
  local g_flag = G_CMD_OPEN_CLOSE_PATH_FIND
  if bAuto then
    g_flag = G_CMD_OPEN_AUTO_PATH_FIND
  end
  send_vip_msg(g_flag)
end
function send_vip_msg(type, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_VIP_MSG), nx_int(type), unpack(arg))
  end
end
function on_ready(first, ...)
  local serialmodule = nx_value("HardWareSerial")
  if not nx_is_valid(serialmodule) then
    serialmodule = nx_create("HardWareSerial")
    nx_set_value("HardWareSerial", serialmodule)
  end
  local index = 2
  if nx_is_valid(serialmodule) then
    local info = serialmodule:GetHardSerial(nx_string(arg[1]))
    if 2 <= table.getn(info) then
      local ret = nx_number(info[1])
      local addr = nx_string(info[2])
      send_vip_msg(G_CMD_LOGIN_INFO, nx_int(ret), addr)
      return
    end
  end
  local net_address = nx_function("ext_get_net_serial")
  send_vip_msg(G_CMD_LOGIN_INFO, -1, net_address)
end
function on_set_kick(...)
  local flag = nx_number(arg[1])
  if 0 < flag then
    local diff = os.time()
    while true do
      local ready = nx_value("scene_ready")
      if ready then
        break
      end
      nx_pause(0.5)
    end
    diff = os.time() - diff
    flag = flag - diff
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    nx_set_custom(dialog, "is_vip_kick", 1)
    local item = dialog.mltbox_info
    item:Clear()
    local index = item:AddHtmlText(util_format_string("ui_timeserver_tips", nx_widestr(flag)), nx_int(-1))
    dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
    dialog:ShowModal()
    nx_wait_event(100000000, dialog, "error_return")
  else
    local form = nx_value("form_common\\form_error")
    if not nx_is_valid(form) then
      return
    end
    if not nx_find_custom(form, "is_vip_kick") then
      return
    end
    form.Visible = false
    form:Close()
  end
end
