require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\capital_define")
local enter_type_owner = 1
local enter_type_visit = 2
local enter_type_open_lock = 3
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
  form.npc = 0
  form.homeid = 0
  form.IsOverDay = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 4
  gui.Desktop:ToFront(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(form)
  close_form()
end
function open_form(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.homeid = arg[1]
  form.npc = arg[2]
  local baseprice = arg[3]
  local fixedprice = arg[4]
  local remainbidtime = arg[5]
  local home_name = arg[6]
  local scene_name = arg[7]
  local home_level = arg[8]
  local bidder_name = arg[9]
  local sign_id = arg[10]
  local isNeighbour = arg[11]
  form.btn_request.Visible = false
  form.btn_visit.Visible = false
  if nx_int(isNeighbour) == nx_int(1) then
    form.btn_visit.Visible = true
  end
  if nx_int(isNeighbour) == nx_int(0) then
    form.btn_request.Visible = true
  end
  local hour = nx_int(remainbidtime / 1000 / 3600)
  local minute = nx_int((remainbidtime / 1000 - 3600 * hour) / 60)
  form.ipt_hour.Text = nx_widestr(hour)
  form.ipt_minute.Text = nx_widestr(minute)
  local base_ding = nx_int64(nx_int64(baseprice) / 1000000)
  local base_liang = nx_int64((nx_int64(baseprice) - nx_int64(base_ding) * 1000000) / 1000)
  local base_wen = nx_int64(nx_int64(baseprice) - nx_int64(base_ding) * 1000000 - nx_int64(base_liang) * 1000)
  form.ipt_bidding.Text = nx_widestr(base_ding)
  form.ipt_bidliang.Text = nx_widestr(base_liang)
  form.ipt_bidwen.Text = nx_widestr(base_wen)
  if nx_int64(0) == nx_int64(fixedprice) then
    form.IsOverDay = 1
    form.btn_buy.Visible = false
  end
  local fixed_ding = nx_int64(nx_int64(fixedprice) / 1000000)
  local fixed_liang = nx_int64((nx_int64(fixedprice) - nx_int64(fixed_ding) * 1000000) / 1000)
  local fixed_wen = nx_int64(nx_int64(fixedprice) - nx_int64(fixed_ding) * 1000000 - nx_int64(fixed_liang) * 1000)
  form.ipt_fixding.Text = nx_widestr(fixed_ding)
  form.ipt_fixliang.Text = nx_widestr(fixed_liang)
  form.ipt_fixwen.Text = nx_widestr(fixed_wen)
  form.lbl_home_name.Text = nx_widestr(home_name)
  local place = nx_widestr("")
  place = util_text(scene_name)
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local site = "(" .. nx_string(home_manager:GetHomeX(sign_id)) .. "," .. nx_string(home_manager:GetHomeZ(sign_id)) .. ")"
  place = place .. nx_widestr(site)
  form.lbl_place.Text = place
  if nx_widestr(bidder_name) == nx_widestr("") then
    form.lbl_bidder_name.Text = util_text("ui_haiwai_home_buy_001")
  else
    form.lbl_bidder_name.Text = nx_widestr(bidder_name)
  end
  local gui = nx_value("gui")
  for i = 1, nx_number(home_level) do
    local lbl_star = gui:Create("Label")
    form.groupbox_star:Add(lbl_star)
    lbl_star.Name = "lbl_star_" .. nx_string(i)
    lbl_star.Left = (i - 1) * 20 + 8
    lbl_star.Top = 9
    lbl_star.BackImage = "gui\\special\\home\\main\\start.png"
    lbl_star.AutoSize = true
  end
  local money = 999999
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    money = mgr:GetCapital(CAPITAL_TYPE_SILVER_CARD) / 1000
  end
  form.ipt_upliang.MaxDigit = nx_int(money)
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_request_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local homeid = form.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ADD_NEIGHBOUR, nx_string(homeid))
end
function on_btn_visit_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local homeid = form.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(homeid), nx_int(enter_type_visit))
end
function on_btn_buy_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.IsOverDay) == nx_int(1) then
    return
  end
  local homeid = form.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_FIXBUY, nx_string(homeid), nx_object(form.npc))
  close_form()
end
function on_btn_bid_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local homeid = form.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  local upliang = nx_int64(form.ipt_upliang.Text) * 1000
  if nx_int64(upliang) < nx_int64(50000) then
    self_systemcenterinfo("home_trade_failed_07")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_BID, nx_string(homeid), nx_object(form.npc), nx_int64(upliang), nx_int(form.IsOverDay))
  close_form()
end
function is_my_home(homeid)
  local recordname = "self_home_rec"
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  row = client_player:FindRecordRow(recordname, 0, homeid, 0)
  if row >= 0 then
    return true
  end
  return false
end
function self_systemcenterinfo(msgid)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text(nx_string(msgid))), 2)
  end
end
