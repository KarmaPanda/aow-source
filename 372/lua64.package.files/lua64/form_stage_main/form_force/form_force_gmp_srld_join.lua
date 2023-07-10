require("util_functions")
require("share\\client_custom_define")
require("const_define")
require("util_gui")
require("control_set")
local STC_SRLD_SUBMSG_PARAM = {
  IS_JOIN = 1,
  IS_START = 2,
  WAIT_PLAYER_JOIN = 3,
  WAIT_PLAYER_START = 4,
  LD_START = 5,
  LD_BROKEN = 6,
  LD_END = 7,
  END_JOIN = 8,
  WAIT_FLOW_BROKEN = 9,
  WAIT_FLOW_TIME_OUT = 10
}
local CTS_SRLD_SUBMSG = {
  JOIN = 4,
  NOT_JOIN = 5,
  START = 6,
  NOT_START = 7,
  END_JOIN = 8
}
local SRLD_FORM_FLAG = {
  IS_JOIN_FORM = 1,
  WAIT_PLAYER_JOIN_FORM = 2,
  IS_START_FORM = 3,
  START_LD_FORM = 4,
  WAIT_PLAYER_START_FORM = 5
}
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2 + form.Width
  form.AbsTop = form.Height / 2
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  if form.srld_form_flag ~= nil and form.srld_form_flag ~= SRLD_FORM_FLAG.IS_JOIN_FORM then
    nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SRLD_SUBMSG.END_JOIN)
  end
  nx_destroy(form)
  return
end
function on_btn_ok_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.srld_form_flag == SRLD_FORM_FLAG.IS_JOIN_FORM then
    nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SRLD_SUBMSG.JOIN)
  elseif form.srld_form_flag == SRLD_FORM_FLAG.IS_START_FORM then
    nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SRLD_SUBMSG.START)
  end
  form.srld_form_flag = nil
  form:Close()
  return
end
function on_btn_close_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.srld_form_flag == SRLD_FORM_FLAG.IS_JOIN_FORM then
    nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SRLD_SUBMSG.NOT_JOIN)
  elseif form.srld_form_flag == SRLD_FORM_FLAG.IS_START_FORM then
    nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SRLD_SUBMSG.NOT_START)
  elseif form.srld_form_flag == SRLD_FORM_FLAG.WAIT_PLAYER_JOIN_FORM then
    nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SRLD_SUBMSG.END_JOIN)
  elseif form.srld_form_flag == SRLD_FORM_FLAG.START_LD_FORM then
    nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SRLD_SUBMSG.END_JOIN)
  elseif form.srld_form_flag == SRLD_FORM_FLAG.WAIT_PLAYER_START_FORM then
    nx_execute("custom_sender", "custom_ancient_tomb_sender", CTS_SRLD_SUBMSG.END_JOIN)
  end
  form.srld_form_flag = nil
  form:Close()
  return
end
function handle_message(...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sub_msg_param = arg[1]
  if sub_msg_param == STC_SRLD_SUBMSG_PARAM.IS_JOIN then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = SRLD_FORM_FLAG.IS_JOIN_FORM
    form.btn_ok.Visible = true
    form.btn_cancel.Visible = true
    form.Visible = true
    form:Show()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.WAIT_PLAYER_JOIN then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = SRLD_FORM_FLAG.WAIT_PLAYER_JOIN_FORM
    form.btn_ok.Visible = false
    form.btn_cancel.Visible = true
    form.mltbox_desc_info:ChangeHtmlText(nx_int(0), nx_widestr(gui.TextManager:GetFormatText("ui_gmp_smdh_wf_03")))
    form.Visible = true
    form:Show()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.IS_START then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = SRLD_FORM_FLAG.IS_START_FORM
    form.btn_ok.Visible = true
    form.btn_cancel.Visible = true
    form.mltbox_desc_info:ChangeHtmlText(nx_int(0), nx_widestr(gui.TextManager:GetFormatText("ui_gmp_smdh_wf_04")))
    form.Visible = true
    form:Show()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.WAIT_PLAYER_START then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = SRLD_FORM_FLAG.WAIT_PLAYER_START_FORM
    form.btn_ok.Visible = false
    form.btn_cancel.Visible = true
    form.mltbox_desc_info:ChangeHtmlText(nx_int(0), nx_widestr(gui.TextManager:GetFormatText("ui_gmp_smdh_wf_07")))
    form.Visible = true
    form:Show()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.LD_START then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    form.btn_ok.Visible = false
    form.btn_cancel.Visible = true
    form.srld_form_flag = SRLD_FORM_FLAG.START_LD_FORM
    form.mltbox_desc_info:ChangeHtmlText(nx_int(0), nx_widestr(gui.TextManager:GetFormatText("ui_gmp_smdh_wf_05")))
    form.Visible = true
    form:Show()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.LD_BROKEN then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = nil
    form:Close()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.LD_END then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = nil
    form:Close()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.END_JOIN then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = nil
    form:Close()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.WAIT_FLOW_BROKEN then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = nil
    form:Close()
  elseif sub_msg_param == STC_SRLD_SUBMSG_PARAM.WAIT_FLOW_TIME_OUT then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    form.srld_form_flag = nil
    form:Close()
  end
  return
end
