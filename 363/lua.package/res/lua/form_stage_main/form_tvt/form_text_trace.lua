require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
local g_form_name = "form_stage_main\\form_tvt\\form_text_trace"
local g_rec = "InteractTraceRec"
local g_max_arrows = 15
local g_icon = "<img src=\"gui\\special\\tvt\\tvt_xuanzhongbiaoji.png\" valign=\"bottom\" only=\"line\" data=\"\" />"
local g_normal_icon = "<img src=\"gui\\special\\tvt\\tvt_kong.png\" valign=\"bottom\" only=\"line\" data=\"\" />"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  set_form_size(form)
  form.show = true
  form.tbar_fade.Visible = false
  form.groupbox_2.BlendColor = nx_string(form.tbar_fade.Value) .. ",255,255,255"
  local gui = nx_value("gui")
  form.Top = (gui.Height - form.Height) / 2 + 20
  form.Left = gui.Width - form.Width - 10
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind(g_rec, form, g_form_name, "on_trace_rec_changed")
  databinder:AddTableBind("tvt_add_trace", form, g_form_name, "on_add_trace_rec_changed")
  form.ShowHelp = false
  form.btn_help.Visible = false
  local mgr = nx_value("InteractManager")
  if nx_is_valid(mgr) then
    local type = mgr:GetCurrentTvtType()
    if ITT_DUOSHU == type or ITT_HUSHU == type or ITT_SPY_MENP == type or ITT_PATROL == type or ITT_SPY_CHAOTING == type then
      form.ShowHelp = true
      form.btn_help.Visible = true
    end
  end
end
function on_main_form_move(form)
  set_form_size(form)
end
function set_form_size(form)
  form.w = form.Width
  form.h = form.Height
  form.l = form.Left
  form.t = form.Top
  form.bl = form.cbtn_min.Left
  form.bt = form.cbtn_min.Top
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_groupbox_func_get_capture(group)
  local form = group.ParentForm
  form.btn_mainform.Visible = true
  form.btn_infoform.Visible = true
  form.btn_fix.Visible = true
  form.btn_fade.Visible = true
  form.cbtn_min.Visible = true
  if form.ShowHelp then
    form.btn_help.Visible = true
  end
end
function on_groupbox_func_lost_capture(group)
  local form = group.ParentForm
  form.btn_mainform.Visible = false
  form.btn_infoform.Visible = false
  form.btn_fix.Visible = false
  form.btn_fade.Visible = false
  if not form.cbtn_min.Checked then
    form.cbtn_min.Visible = false
  end
  form.tbar_fade.Visible = false
  if form.ShowHelp then
    form.btn_help.Visible = false
  end
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function show_trace()
  util_show_form(g_form_name, true)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local mbox = form.mltbox_tvttrace
  mbox:Clear()
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    util_show_form(g_form_name, false)
    return
  end
  local type, step = set_trace_str(mbox)
  if type == -1 then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_info", "close_trace")
    return
  end
  local bShowLeida = 0 <= step
  util_show_form("form_stage_main\\form_tvt\\form_trace", bShowLeida)
  if 0 <= step then
    mgr:InitTrace(type, step)
  end
  local info = mgr:GetTvtBaseInfo(type)
  form.lbl_tvtname.Text = info[1]
end
function set_trace_str(box)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return -1, -1
  end
  local type = mgr:GetCurrentTvtType()
  if type < 0 then
    return -1, -1
  end
  local bTrace = mgr.TraceFlag
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1, -1
  end
  if not client_player:FindRecord(g_rec) then
    return -1, -1
  end
  function format_string(...)
    local msg = {}
    local count = table.getn(arg)
    local num = 1
    for i = 1, count do
      local s = util_split_wstring(arg[i], ",")
      local type = nx_number(s[1])
      if type == 2 or type == 3 then
        msg[num] = nx_int(s[2])
        num = num + 1
      elseif type == 4 or type == 5 then
        msg[num] = nx_float(s[2])
        num = num + 1
      elseif type == 6 then
        msg[num] = nx_string(s[2])
        num = num + 1
      elseif type == 7 then
        msg[num] = s[2]
        num = num + 1
      end
    end
    return nx_string(util_format_string(unpack(msg)))
  end
  local trace_info = mgr.TraceInfo
  local trace_type = math.floor(trace_info / 1000 - 1)
  local trace_step = math.floor(math.mod(trace_info, 1000))
  local bTraceLeida = false
  local step = -1
  local rows = client_player:GetRecordRows(g_rec) - 1
  for i = 0, rows do
    local temp_type = client_player:QueryRecord(g_rec, i, 0)
    local temp_id = client_player:QueryRecord(g_rec, i, 1)
    if temp_type == type then
      local arg = util_split_wstring(client_player:QueryRecord(g_rec, i, 2), ";")
      local str = ""
      if trace_type == type and trace_step == temp_id then
        str = str .. g_icon
        step = temp_id
        bTraceLeida = true
      else
        str = str .. g_normal_icon
      end
      str = str .. format_string(unpack(arg))
      box:AddHtmlText(nx_widestr(str), nx_int(temp_id))
    end
  end
  return type, step
end
function on_trace_rec_changed(self, recordname, optype, row, clomn)
  if optype == "add" then
  end
  if optype == "update" then
  end
  if optype == "del" then
  end
  if optype == "clear" then
  end
  local mgr = nx_value("InteractManager")
  if nx_is_valid(mgr) and mgr.TraceFlag then
    show_trace()
  end
end
function on_add_trace_rec_changed(self, recordname, optype, row, clomn)
  local mgr = nx_value("InteractManager")
  if nx_is_valid(mgr) and mgr.TraceFlag then
    show_trace()
  end
end
function on_click_tvt_step(multtextbox, index)
end
function on_btn_mainform_click(btn)
  util_show_form("form_stage_main\\form_tvt\\form_tvt_main", true)
end
function on_btn_infoform_click(btn)
  local mgr = nx_value("InteractManager")
  if nx_is_valid(mgr) then
    local type = mgr:GetCurrentTvtType()
    nx_execute("form_stage_main\\form_tvt\\form_tvt_info", "show_tvt_info", type)
  end
end
function on_quit_trace(btn)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_info", "close_trace")
end
function on_min_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.Width = cbtn.Width
    form.Height = cbtn.Height
    form.Top = form.Top + cbtn.Top
    form.Left = form.Left + cbtn.Left
    cbtn.Top = 0
    cbtn.Left = 0
    cbtn.Visible = true
  else
    cbtn.Top = form.bt
    cbtn.Left = form.bl
    form.Width = form.w
    form.Height = form.h
    form.Top = form.t
    form.Left = form.l
  end
end
function on_btn_fix_click(btn)
  local form = btn.ParentForm
  form.Fixed = not form.Fixed
end
function on_btn_fade_click(btn)
  local form = btn.ParentForm
  local bar = form.tbar_fade
  bar.Visible = true
end
function on_tbar_fade_value_changed(tbar)
  local form = tbar.ParentForm
  local value = tbar.Value
  form.groupbox_2.BlendColor = nx_string(value) .. ",255,255,255"
end
function on_tbar_fade_lost_capture(tbar)
end
function on_btn_help_click(btn)
  local mgr = nx_value("InteractManager")
  if nx_is_valid(mgr) then
    local type = mgr:GetCurrentTvtType()
    if ITT_DUOSHU == type then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_duoshu_help"), "1")
    elseif ITT_HUSHU == type then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_hushu_help"), "1")
    elseif ITT_SPY_MENP == type then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_citan_help"), "1")
    elseif ITT_PATROL == type then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_xunluo_help"), "1")
    elseif ITT_SPY_CHAOTING == type then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("howto_citan_help"), "1")
    end
  end
end
