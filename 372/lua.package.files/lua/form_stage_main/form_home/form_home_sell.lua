require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
  form.sign_id = 0
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
  form.sign_id = arg[1]
  form.npc = arg[2]
  form.homeid = arg[5]
  form.lbl_place.Text = nx_widestr(util_text(arg[3]))
  form.lbl_home.Text = nx_widestr(arg[4])
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_sell_click(btn)
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
  local bidhour = form.ipt_bidtime.Text
  local baseding = form.ipt_baseding.Text
  local baseliang = form.ipt_baseliang.Text
  local basewen = form.ipt_basewen.Text
  local baseprice = nx_int64(basewen) + nx_int64(baseliang) * 1000 + nx_int64(baseding) * 1000000
  local fixedding = form.ipt_fixedding.Text
  local fixedliang = form.ipt_fixedliang.Text
  local fixedwen = form.ipt_fixedwen.Text
  local fixedprice = nx_int64(fixedwen) + nx_int64(fixedliang) * 1000 + nx_int64(fixedding) * 1000000
  if nx_int64(baseding) > nx_int64(999) then
    return
  elseif nx_int64(baseliang) > nx_int64(999) then
    return
  elseif nx_int64(basewen) > nx_int64(999) then
    return
  end
  if nx_int64(fixedding) > nx_int64(999) then
    return
  elseif nx_int64(fixedliang) > nx_int64(999) then
    return
  elseif nx_int64(fixedwen) > nx_int64(999) then
    return
  end
  if nx_int64(fixedprice) <= nx_int64(0) then
    return
  end
  if nx_int64(baseprice) <= nx_int64(0) then
    return
  end
  if nx_int64(fixedprice) <= nx_int64(baseprice) then
    self_systemcenterinfo("home_trade_failed_03")
    return
  end
  if nx_int(bidhour) < nx_int(24) then
    self_systemcenterinfo("home_trade_failed_02")
    return
  elseif nx_int(bidhour) > nx_int(96) then
    self_systemcenterinfo("home_trade_failed_02")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SELLHOME, nx_string(homeid), nx_int(form.sign_id), nx_object(form.npc), nx_int64(bidhour), nx_int64(baseprice), nx_int64(fixedprice))
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
