require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
  form.npc = 0
  form.homeid = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 4
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
  form.npc = arg[2]
  form.homeid = arg[1]
  local baseprice = arg[3]
  local fixedprice = arg[4]
  local remainbidtime = arg[5]
  local bidder_name = arg[6]
  local home_name = arg[7]
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
  local fixed_ding = nx_int64(nx_int64(fixedprice) / 1000000)
  local fixed_liang = nx_int64((nx_int64(fixedprice) - nx_int64(fixed_ding) * 1000000) / 1000)
  local fixed_wen = nx_int64(nx_int64(fixedprice) - nx_int64(fixed_ding) * 1000000 - nx_int64(fixed_liang) * 1000)
  form.ipt_fixding.Text = nx_widestr(fixed_ding)
  form.ipt_fixliang.Text = nx_widestr(fixed_liang)
  form.ipt_fixwen.Text = nx_widestr(fixed_wen)
  if nx_widestr(bidder_name) == nx_widestr("") then
    form.lbl_bidder_name.Text = util_text("ui_haiwai_home_buy_001")
  else
    form.lbl_bidder_name.Text = nx_widestr(bidder_name)
  end
  form.lbl_home_name.Text = nx_widestr(home_name)
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local homeid = form.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if not is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_02")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENDTRADE, nx_string(homeid), nx_object(form.npc))
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
