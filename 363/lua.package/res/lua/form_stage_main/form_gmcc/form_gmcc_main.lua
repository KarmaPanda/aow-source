require("util_gui")
require("util_functions")
require("form_stage_main\\form_gmcc\\form_gmcc_msg_define")
local g_form_name = "form_stage_main\\form_gmcc\\form_gmcc_main"
local g_gm_name = ""
function open_form()
  util_auto_show_hide_form(nx_current())
end
function on_main_form_init(form)
end
function on_main_form_open(form)
  form.Fixed = false
end
function on_main_form_close(form)
  util_show_form(g_form_name, false)
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  util_show_form(g_form_name, false)
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  module:ClearChatInfo()
end
function close_form()
  local form = nx_value("form_stage_main\\form_gmcc\\form_gmcc_main")
  if not nx_is_valid(form) then
    return
  end
  local module = nx_value("GmccModule")
  if nx_is_valid(module) then
    module:ClearChatInfo()
  end
  form:Close()
end
function on_server_open_form(str)
  local info = util_split_wstring(nx_widestr(str), nx_widestr(";"))
  local count = table.getn(info)
  if count < 1 then
    return
  end
  util_show_form(g_form_name, true)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local clew = form.mltbox_clew
  clew.HtmlText = nx_widestr("@ui_gmcc_02")
  local group = form.groupbox_func
  group:DeleteAll()
  local btn_wh, btn_ht = 80, 30
  local btns_ht = 10
  local class = 2
  local topht = 45
  local gui = nx_value("gui")
  for i, name in pairs(info) do
    local btn = gui:Create("Button")
    group:Add(btn)
    btn.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
    btn.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
    btn.PushImage = "gui\\common\\button\\btn_normal2_down.png"
    btn.DrawMode = "ExpandH"
    btn.Width = btn_wh
    btn.Height = btn_ht
    btn.Left = (nx_int(group.Width / class) - btn_wh) / 2 + math.mod(i - 1, class) * nx_int(group.Width / class)
    btn.Top = topht + (btn_ht + btns_ht) * nx_int((i - 1) / class)
    btn.Text = nx_widestr(name)
    btn.Font = "font_main"
    btn.ShadowColor = "0,20,0,0"
    nx_bind_script(btn, nx_current(), "", "")
    nx_callback(btn, "on_click", "on_btn_down")
    nx_set_custom(btn, "index", name)
  end
end
function on_btn_down(btn)
  local ntype = nx_custom(btn, "index")
  local msg = nx_widestr("#EXTE#") .. nx_widestr(GMCC_MSG_ASK_CHAT) .. nx_widestr("#") .. nx_widestr(ntype)
  send_gmcc_msg(0, msg)
  util_show_form(g_form_name, false)
  util_show_form("form_stage_main\\form_gmcc\\form_gmcc_chat", true)
end
function GetSysTime()
  local tm = os.date("%X", os.time())
  return nx_widestr(tm)
end
function notify_player(notify_name, type, excuse, info)
  send_gmcc_msg(1, notify_name, type, excuse, info)
end
function send_gmcc_msg(subtype, ...)
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  module:AddChatInfo(nx_widestr("GMCC"), GetSysTime(), nx_widestr(arg[1]))
  nx_execute("custom_sender", "custom_send_gmcc_msg", subtype, unpack(arg))
end
