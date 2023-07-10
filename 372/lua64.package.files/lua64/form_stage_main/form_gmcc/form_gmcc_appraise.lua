require("util_gui")
require("util_functions")
require("form_stage_main\\form_gmcc\\form_gmcc_msg_define")
local g_form_name = "form_stage_main\\form_gmcc\\form_gmcc_appraise"
local g_hint_str = "@ui_gmcc_03"
function on_main_form_init(form)
end
function on_main_form_open(form)
  form.Fixed = false
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  g_appraise_str = nx_widestr(module.strappr)
  if g_appraise_str == nil then
    return
  end
  local appraise_str = nx_value("gmcc_appraise_str")
  local info = util_split_wstring(nx_widestr(appraise_str), nx_widestr(";"))
  local count = table.getn(info)
  if count < 1 then
    return
  end
  local hint = form.mltbox_hint
  hint:AddHtmlText(nx_widestr(g_hint_str), nx_int(0))
  local group = form.groupbox_func
  group:DeleteAll()
  local gui = nx_value("gui")
  for i, name in pairs(info) do
    local rdobtn = gui:Create("RadioButton")
    local label = gui:Create("Label")
    group:Add(rdobtn)
    group:Add(label)
    rdobtn.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
    rdobtn.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
    rdobtn.CheckedImage = "gui\\common\\checkbutton\\cbtn_2_down.png"
    rdobtn.Width = 14
    rdobtn.Height = 12
    rdobtn.Left = (nx_int(group.Width / count) - rdobtn.Width) / 2 + (i - 1) * nx_int(group.Width / count) - 7
    rdobtn.Top = 20
    label.Width = 14
    label.Height = 12
    label.Left = 15 + rdobtn.Left
    label.Top = 20
    label.Text = nx_widestr(name)
    rdobtn.cur_name = nx_widestr(name)
    nx_bind_script(rdobtn, nx_current(), "", "")
    nx_callback(rdobtn, "on_checked_changed", "on_checked_changed")
  end
  form.radio_str = nx_widestr("")
end
function close_form()
  local form = nx_value("form_stage_main\\form_gmcc\\form_gmcc_appraise")
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_main_form_close(form)
  local module = nx_value("GmccModule")
  if nx_is_valid(module) then
    module:ClearChatInfo()
  end
  nx_destroy(form)
end
function open_appraise_form(str)
  if nx_widestr(str) ~= nx_widestr("") then
    g_hint_str = nx_widestr(str)
  end
  util_show_form("form_stage_main\\form_gmcc\\form_gmcc_appraise", true)
end
function on_rec_appraise_str(str)
  nx_set_value("gmcc_appraise_str", nx_widestr(str))
end
function on_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_checked_changed(btn)
  if btn.Checked then
    local form = btn.ParentForm
    form.radio_str = nx_widestr(btn.cur_name)
  end
end
function on_btn_ok_click(btn)
  nx_execute("form_stage_main\\form_gmcc\\form_gmcc_chat", "close_form")
  nx_execute("form_stage_main\\form_gmcc\\form_gmcc_main", "close_form")
  local module = nx_value("GmccModule")
  if nx_is_valid(module) then
    module.ShutName = nx_widestr("GM")
  end
  local form = btn.ParentForm
  local redittxt = form.redit_txt
  local gmccmsg = util_split_wstring(nx_widestr(redittxt.Text), nx_widestr(">"))
  edtstr = nx_widestr(gmccmsg[2])
  gmccmsg = util_split_wstring(nx_widestr(edtstr), "<")
  edtstr = nx_widestr(gmccmsg[1])
  local apprs = nx_widestr("#EXTE#voteRes#") .. nx_widestr(form.radio_str) .. nx_widestr("#") .. nx_widestr(edtstr)
  send_gmcc_msg(0, nx_widestr(apprs))
  form:Close()
end
function GetSysTime()
  local tm = os.date("%X", os.time())
  return nx_string(tm)
end
function send_gmcc_msg(subtype, ...)
  local module = nx_value("GmccModule")
  if not nx_is_valid(module) then
    module = nx_create("GmccModule")
    nx_set_value("GmccModule", module)
  end
  module:AddChatInfo(nx_widestr("GMCC"), GetSysTime(), nx_widestr(nx_widestr(arg[1])))
  module.Index = module.Index + 1
  nx_execute("custom_sender", "custom_send_gmcc_msg", subtype, unpack(arg))
end
