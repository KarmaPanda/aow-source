require("form_stage_main\\switch\\url_define")
require("util_gui")
require("util_functions")
function on_online_changed(player, mgr, online)
  if online <= 0 then
    return
  end
  if not nx_is_valid(player) or not nx_is_valid(mgr) then
    return
  end
  online = nx_number(online / 1000)
  if 0 < online and online < 3600 then
    if not mgr:HadTip(0) then
      local ret = show_tip(online)
      mgr:SetTip(0, ret)
    end
  elseif 3600 <= online and online < 7200 then
    if not mgr:HadTip(1) then
      local ret = show_tip(online)
      mgr:SetTip(1, ret)
    end
  elseif 7200 <= online and online < 10800 then
    if not mgr:HadTip(2) then
      local ret = show_tip(online)
      mgr:SetTip(2, ret)
    end
  elseif 10800 <= online then
    mgr:SetTip(3, true)
  end
end
function show_tip(online)
  local str = "form_stage_main\\form_enthrall\\form_enthrall"
  util_show_form(str, true)
  local form = nx_value(str)
  if not nx_is_valid(form) then
    return false
  end
  local h = nx_int(online / 3600)
  local m = nx_int(math.mod(online, 3600) / 60)
  local s = nx_int(math.mod(online, 60))
  local txt = util_format_string("ui_fcm_online", h, m, s)
  form.mltbox_info.HtmlText = txt
  return true
end
function show_quit()
  util_show_form("form_stage_main\\form_enthrall\\form_quit", true)
end
function quit_game()
  local form = nx_value("form_stage_main\\form_enthrall\\form_quit")
  if nx_is_valid(form) then
    form:Close()
  end
  local gEffect = nx_value("global_effect")
  if nx_is_valid(gEffect) then
    gEffect:ClearEffects()
  end
  nx_execute("stage", "set_current_stage", "login")
  nx_execute("client", "close_connect")
end
function on_online_zero()
  local name = "form_stage_main\\form_enthrall\\form_quit"
  local form = nx_value(name)
  if nx_is_valid(form) and form.Visible then
    util_show_form(name, false)
  end
  name = "form_stage_main\\form_enthrall\\form_attest"
  form = nx_value(name)
  if nx_is_valid(form) and form.Visible then
    util_show_form(name, false)
  end
  name = "form_stage_main\\form_enthrall\\form_enthrall"
  form = nx_value(name)
  if nx_is_valid(form) and form.Visible then
    util_show_form(name, false)
  end
  local mgr = nx_value("UnenthrallModule")
  if nx_is_valid(mgr) then
    mgr.Enthrall = false
  end
end
function show_reg()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    nx_log("show unenthrall reg form, no switch manager")
    return
  end
  local operators = get_operators_name()
  nx_log("show unenthrall reg form, operators is " .. nx_string(operators))
  if operators == OPERATORS_TYPE_SNDA then
    switch_manager:OpenUrl(URL_TYPE_SNDA_UNENTHRALL)
  else
    util_show_form("form_stage_main\\form_enthrall\\form_attest", true)
  end
end
function request_unenthrall(...)
  nx_execute("custom_sender", "request_unenthrall", unpack(arg))
end
function on_server_msg(...)
  local aid = nx_widestr(arg[1])
  local rnm = nx_widestr(arg[2])
  local idt = nx_widestr(arg[3])
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("UnenthrallModule")
    nx_set_value("UnenthrallModule", mgr)
  end
  local ret = mgr:RegUnenthrall(aid, rnm, idt)
  if 2 > table.getn(ret) then
    nx_log("InvokeWebService error: not fond any interface from InvokeWebService.dll")
    return
  end
  local path = "form_stage_main\\form_main\\form_main_centerinfo"
  local tipid = nx_number(ret[1])
  if tipid == -1 then
    nx_log("InvokeWebService error: call for InvokeWebService.dll error")
    return
  end
  nx_log("InvokeWebService result: " .. tostring(tipid) .. " info:" .. nx_string(ret[2]))
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if tipid ~= 1 then
    local tipinfo = "reg_unenthrall_" .. nx_string(tipid)
    if tipid == -100 then
      tipinfo = "reg_unenthrall_cnnt"
    elseif tipid == -99 then
      tipinfo = "reg_unenthrall_error"
    end
    if tipinfo ~= nil and nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_format_string(tipinfo), 2)
    end
  else
    name = "form_stage_main\\form_enthrall\\form_attest"
    form = nx_value(name)
    if nx_is_valid(form) and form.Visible then
      util_show_form(name, false)
    end
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_format_string("reg_unenthrall_1"), 2)
    end
    nx_pause(10)
    request_unenthrall(2)
  end
end
