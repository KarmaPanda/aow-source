require("util_gui")
require("util_functions")
require("form_stage_main\\form_gmcc\\form_gmcc_msg_define")
function send_gmcc_msg(subtype, ...)
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  module:ClearChatInfo()
  module:AddChatInfo(nx_widestr("YOU"), GetSysTime(), nx_widestr(arg[1]))
  nx_execute("custom_sender", "custom_send_gmcc_msg", subtype, unpack(arg))
end
function to_ask_gmcc()
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  local form = nx_value("form_stage_main\\form_gmcc\\form_gmcc_chat")
  if nx_is_valid(form) then
    local mlbrecord = form.mltbox_record
    mlbrecord:Clear()
  end
  local count = module:GetChatInfoCount()
  if count > module.Index + 3 then
    for i = module.Index, count - 1 do
      local tab = module:GetChatInfo(i)
      local msg_type = gmcc_msg_type(nx_string(tab[3]))
      if msg_type == GMCC_MSG_CHAT then
        util_show_form("form_stage_main\\form_gmcc\\form_gmcc_chat", true)
        nx_execute("form_stage_main\\form_gmcc\\form_gmcc_chat", "on_body_talk", nx_widestr(tab[1]), nx_widestr(tab[3]), nx_string(tab[2]))
      elseif msg_type == GMCC_MSG_ANSWER_APRS then
        module.bapprise = true
      end
    end
  else
    module.ShutName = nx_widestr("GM")
    send_gmcc_msg(0, nx_widestr("#EXTE#regard"))
  end
end
function check_is_chatting()
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  local count = module:GetChatInfoCount()
  if count <= module.Index + 3 then
    return false
  end
  for i = module.Index, count - 1 do
    local tab = module:GetChatInfo(i)
    if gmcc_msg_type(nx_string(tab[3])) == GMCC_MSG_CHAT then
      return true
    end
  end
  return false
end
function gmcc_msg_type(gmcc_msg)
  local gmccmsg = util_split_string(nx_string(gmcc_msg), "#")
  local count = table.getn(gmccmsg)
  if 2 < count then
    if gmccmsg[2] == GMCC_MSG_HEAD then
      if 5 < count and gmccmsg[3] == GMCC_MSG_ANSWER_INIT then
        return GMCC_MSG_ANSWER_INIT
      elseif 3 < count and gmccmsg[3] == GMCC_MSG_ANSWER_APRS then
        return GMCC_MSG_ANSWER_APRS
      end
    end
    return ""
  elseif count == 2 then
    return ""
  else
    return GMCC_MSG_CHAT
  end
end
function is_chatform_open()
  local temp_form = nx_value("form_stage_main\\form_gmcc\\form_gmcc_chat")
  if nx_is_valid(temp_form) and temp_form.Visible then
    return true
  end
  return false
end
function is_mainform_open()
  local temp_form = nx_value("form_stage_main\\form_gmcc\\form_gmcc_main")
  if nx_is_valid(temp_form) and temp_form.Visible then
    return true
  end
  return false
end
function is_appraiseform_open()
  local temp_form = nx_value("form_stage_main\\form_gmcc\\form_gmcc_appraise")
  if nx_is_valid(temp_form) and temp_form.Visible then
    return true
  end
  return false
end
function is_allform_close()
  if not is_chatform_open() and not is_mainform_open() and not is_appraiseform_open() then
    return true
  end
  return false
end
function GetSysTime()
  local tm = os.date("%X", os.time())
  return nx_widestr(tm)
end
function on_recive_gmcc_msg(gmname, gmccinfo)
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  local gmccmsg = util_split_wstring(nx_widestr(gmccinfo), nx_widestr("#"))
  local count = table.getn(gmccmsg)
  if count == 2 then
    return
  end
  if count == 1 then
    util_show_form("form_stage_main\\form_gmcc\\form_gmcc_chat", true)
    nx_execute("form_stage_main\\form_gmcc\\form_gmcc_chat", "on_body_talk", "GM", gmccmsg[1], GetSysTime())
  end
  local msg_id = nx_string(gmccmsg[3])
  if msg_id == GMCC_MSG_ANSWER_INIT then
    if count < 6 then
      return
    end
    module.strappr = nx_widestr(gmccmsg[6])
    if is_allform_close() and 2 > module:GetChatInfoCount() then
      nx_execute("form_stage_main\\form_gmcc\\form_gmcc_main", "on_server_open_form", nx_widestr(gmccmsg[5]))
      nx_execute("form_stage_main\\form_gmcc\\form_gmcc_appraise", "on_rec_appraise_str", nx_widestr(gmccmsg[6]))
    else
      nx_execute("form_stage_main\\form_gmcc\\form_gmcc_appraise", "on_rec_appraise_str", nx_widestr(gmccmsg[6]))
      return
    end
  elseif msg_id == GMCC_MSG_ANSWER_APRS then
    if nx_string(module.ShutName) == "GM" then
      if not is_allform_close() then
        util_show_form("form_stage_main\\form_gmcc\\form_gmcc_chat", false)
        nx_execute("form_stage_main\\form_gmcc\\form_gmcc_appraise", "open_appraise_form", gmccmsg[4])
      end
    elseif nx_string(module.ShutName) == "YOU" then
      if 6 < module:GetChatInfoCount() then
        util_show_form("form_stage_main\\form_gmcc\\form_gmcc_chat", false)
        nx_execute("form_stage_main\\form_gmcc\\form_gmcc_appraise", "open_appraise_form", gmccmsg[4])
      else
        module:ClearChatInfo()
        module.ShutName = nx_widestr("GM")
      end
    end
  end
  module:AddChatInfo(nx_widestr("GM"), GetSysTime(), nx_widestr(gmccinfo))
end
