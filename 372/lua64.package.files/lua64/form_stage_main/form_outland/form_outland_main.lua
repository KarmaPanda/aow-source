require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
require("form_stage_main\\switch\\switch_define")
local FORM_OUTLAND_MAIN = "form_stage_main\\form_outland\\form_outland_main"
local OUTLAND_FORM = {
  "",
  "form_stage_main\\form_outland\\form_outland_play",
  "form_stage_main\\form_outland\\form_outland_person",
  "form_stage_main\\form_outland\\form_outland_origin",
  "form_stage_main\\form_outland_war\\form_outland_war_achieve"
}
local SUBFORM_COUNT = 0
local COMMON_TEXTID = {
  "ui_outland_play_desc_1_47",
  "ui_outland_play_desc_1_6",
  "ui_outland_play_desc_1_5",
  "ui_outland_play_desc_1_4",
  "ui_outland_play_desc_1_8",
  "sys_outlandwar_lpf006",
  "sys_outlandwar_lpf007",
  "sns_new_05"
}
local SIGNUP_TIMES = 0
local MAX_FREQUENCE = 1
local DEFAULT_SUBFORM = 1
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_OUTLAND_ORIGIN_FORM) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  nx_execute("custom_sender", "custom_outland_war", 5)
end
function on_server_msg(...)
  SIGNUP_TIMES = arg[1]
  util_show_form(FORM_OUTLAND_MAIN, true)
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.cur_subform = nil
  form.refresh_time = 0
  SUBFORM_COUNT = nx_number(table.getn(OUTLAND_FORM))
  gui.TextManager:Format_SetIDName(nx_string(COMMON_TEXTID[6]))
  gui.TextManager:Format_AddParam(nx_int(SIGNUP_TIMES))
  form.btn_signup.HintText = gui.TextManager:Format_GetText()
  local gbox_rbtns = form.groupbox_radio
  local childs = gbox_rbtns:GetChildControlList()
  local childs_count = table.getn(childs)
  if childs_count <= 0 then
    return
  end
  if childs_count >= DEFAULT_SUBFORM then
    local tmp_text = "rbtn_" .. nx_string(DEFAULT_SUBFORM)
    local rbtn = nx_custom(form, tmp_text)
    if nx_is_valid(rbtn) then
      rbtn.Checked = true
    end
  end
  form.lbl_name.Text = util_text(COMMON_TEXTID[1])
end
function on_main_form_close(form)
  if nx_find_custom(form, "cur_subform") then
    local cur_subform = form.cur_subform
    if nx_is_valid(cur_subform) then
      cur_subform:Close()
    end
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_sub_form_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_type = nx_number(rbtn.DataSource)
  local gbox_default_main = form.groupbox_main
  local gbox_subform = form.groupbox_all
  DEFAULT_SUBFORM = form_type
  if form_type == 1 then
    gbox_default_main.Visible = true
    gbox_subform.Visible = false
    form.lbl_name.Text = util_text(COMMON_TEXTID[1])
  elseif 1 < form_type and form_type <= SUBFORM_COUNT then
    gbox_default_main.Visible = false
    gbox_subform.Visible = true
    form.lbl_name.Text = util_text(COMMON_TEXTID[form_type])
    gbox_subform:DeleteAll()
    local cur_subform = util_get_form(OUTLAND_FORM[form_type], true, false)
    if not nx_is_valid(cur_subform) then
      return
    end
    gbox_subform:Add(cur_subform)
    if not nx_find_custom(form, "cur_subform") then
      return
    end
    form.cur_subform = cur_subform
  end
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_signup_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "refresh_time") then
    return
  end
  local old_time = form.refresh_time
  local new_time = os.time()
  if new_time - old_time <= MAX_FREQUENCE then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(COMMON_TEXTID[8]), 2)
    end
    return
  end
  form.refresh_time = new_time
  if common_form_confirm(form, COMMON_TEXTID[7]) then
    nx_execute("custom_sender", "custom_outland_war", 6)
  end
end
function common_form_confirm(form, text)
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  local info = util_text(text)
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.Left = form.Left + (form.Width - dialog.Width) / 2
  dialog.Top = form.Top + (form.Height - dialog.Height) / 2
  dialog.relogin_btn.Visible = false
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function open_outland_origin_subform()
  local outland_main = nx_value(FORM_OUTLAND_MAIN)
  if nx_is_valid(outland_main) then
    outland_main:Close()
  end
  DEFAULT_SUBFORM = 4
  open_form()
end
function init_outland_subform()
  DEFAULT_SUBFORM = 1
end
