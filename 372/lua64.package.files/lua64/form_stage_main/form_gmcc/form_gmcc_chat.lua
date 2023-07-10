require("util_gui")
require("util_functions")
require("form_stage_main\\form_gmcc\\form_gmcc_msg_define")
local g_form_name = "form_stage_main\\form_gmcc\\form_gmcc_chat"
local g_player_name = ""
function on_main_form_init(form)
end
function on_main_form_open(form)
  form.Fixed = false
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if nx_is_valid(player) then
    g_player_name = player:QueryProp("Name")
  end
  local gui = nx_value("gui")
  form.AbsLeft = gui.Desktop.Width - form.Width - 20
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
end
function on_main_form_close(form)
  form.Visible = false
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_hide_click(btn)
  local module = nx_value("GmccModule")
  if nx_is_valid(module) and module.bapprise then
    nx_execute("form_stage_main\\form_gmcc\\form_gmcc_appraise", "open_appraise_form", nx_widestr("@ui_gmcc_01"))
    module.bapprise = false
  end
  local form = btn.ParentForm
  form:Close()
end
function close_form()
  local form = nx_value("form_stage_main\\form_gmcc\\form_gmcc_chat")
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_send_click(btn)
  local module = nx_value("GmccModule")
  if nx_is_valid(module) and module.bapprise then
    nx_execute("form_stage_main\\form_gmcc\\form_gmcc_appraise", "open_appraise_form", nx_widestr("@ui_gmcc_01"))
    module.bapprise = false
    return
  end
  local form = btn.ParentForm
  local edtwrite = form.redit_write
  local edtstr = edtwrite.Text
  if nx_widestr("") == nx_widestr(edtstr) then
    return
  end
  local edtstr_utf8 = nx_function("ext_widestr_to_utf8", edtstr)
  local edtstr_utf8 = string.gsub(edtstr_utf8, "<br/>", "@")
  edtstr = nx_function("ext_utf8_to_widestr", edtstr_utf8)
  local msgtab = util_split_wstring(edtstr, nx_widestr("@"))
  local msgnum = table.getn(msgtab) - 1
  local msgres = nx_widestr("")
  for i = 1, msgnum do
    local gmccmsg = util_split_wstring(nx_widestr(msgtab[i]), nx_widestr(">"))
    edtstr = nx_widestr(gmccmsg[2])
    gmccmsg = util_split_wstring(nx_widestr(edtstr), nx_widestr("<"))
    edtstr = nx_widestr(gmccmsg[1])
    if edtstr ~= nx_widestr("") then
      msgres = nx_widestr(msgres) .. nx_widestr(edtstr) .. nx_widestr("\n")
    end
  end
  edtwrite.Text = ""
  on_body_talk(nx_widestr(g_player_name), nx_widestr(msgres), GetSysTime())
  local msg = nx_widestr(msgres)
  send_gmcc_msg(0, nx_widestr(msg))
end
function GetSysTime()
  local tm = os.date("%X", os.time())
  return nx_widestr(tm)
end
function on_body_talk(body, context, tm)
  util_show_form(nx_string(g_form_name), true)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local mlbrecord = form.mltbox_record
  local headstr = nx_widestr("<font color=\"#0000ee\" face=\"\203\206\204\229\" >") .. nx_widestr(body) .. nx_widestr(" (") .. nx_widestr(tm) .. nx_widestr(")</font>")
  local context_utf8 = nx_function("ext_widestr_to_utf8", context)
  local context_utf8 = string.gsub(context_utf8, "\r", "@")
  local context_utf8 = string.gsub(context_utf8, "\n", "@")
  context = nx_function("ext_utf8_to_widestr", context_utf8)
  local msgtab = util_split_wstring(context, nx_widestr("@"))
  local msgnum = table.getn(msgtab)
  local contextstr = ""
  for i = 1, msgnum do
    local tempstr
    if nx_widestr(msgtab[i]) ~= nx_widestr("") then
      tempstr = nx_widestr("<font color=\"#000000\" face=\"\203\206\204\229\" >") .. nx_widestr("  ") .. nx_widestr(msgtab[i]) .. nx_widestr("</font>")
    end
    if nx_widestr(tempstr) ~= nx_widestr("nil") then
      contextstr = nx_widestr(contextstr) .. nx_widestr(tempstr) .. nx_widestr("<br/>")
    end
  end
  mlbrecord:AddHtmlText(nx_widestr(headstr), nx_int(0))
  mlbrecord.ForeColor = "255,0,0,0"
  mlbrecord:AddHtmlText(nx_widestr(contextstr), nx_int(0))
  mlbrecord:GotoEnd()
end
function send_gmcc_msg(subtype, ...)
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  module:AddChatInfo(nx_widestr(g_player_name), GetSysTime(), nx_widestr(arg[1]))
  nx_execute("custom_sender", "custom_send_gmcc_msg", subtype, unpack(arg))
end
