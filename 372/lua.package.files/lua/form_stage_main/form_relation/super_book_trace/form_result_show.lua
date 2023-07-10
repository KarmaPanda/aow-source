require("util_gui")
local TYPE_SHOW_TIP = 0
local TYPE_SHOW_NO_QUEREN = 1
local TYPE_SHOW_QUEREN = 2
local SUB_MSG_STRAT_TRACE = 1
local SUB_MSG_CLOSE_TRACE = 10
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  if nx_find_custom(form, "exit_flag") and nx_int(form.exit_flag) == nx_int(1) then
    form.exit_flag = 0
    return
  end
  nx_execute("custom_sender", "custom_trace_role", nx_int(SUB_MSG_CLOSE_TRACE))
  form.Visible = false
  nx_destroy(form)
end
function ShowCommonShow(type, context)
  if nx_int(type) == nx_int(TYPE_SHOW_TIP) then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_result_show", true, false)
    if not nx_is_valid(form) then
      return
    end
    form.mltbox_neirong:Clear()
    form.mltbox_neirong:AddHtmlText(nx_widestr(context), -1)
    form.lbl_line.Visible = false
    form.btn_dueding.Visible = false
    form.btn_quxiao.Visible = false
    form:Show()
    form.Visible = true
  end
  if nx_int(type) == nx_int(TYPE_SHOW_NO_QUEREN) then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_result_show", false, false)
    if not nx_is_valid(form) then
      return
    end
    form.mltbox_neirong:Clear()
    form.mltbox_neirong:AddHtmlText(nx_widestr(context), -1)
    form.btn_quxiao.Visible = true
    form.lbl_line.Visible = true
    form:Show()
    form.Visible = true
  end
  if nx_int(type) == nx_int(TYPE_SHOW_QUEREN) then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_result_show", false, false)
    if not nx_is_valid(form) then
      return
    end
    form.mltbox_neirong:Clear()
    form.mltbox_neirong:AddHtmlText(nx_widestr(context), -1)
    form.btn_dueding.Visible = true
    form.btn_quxiao.Visible = true
    form.lbl_line.Visible = true
    form:Show()
    form.Visible = true
  end
end
function on_btn_dueding_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_trace_role", nx_int(SUB_MSG_STRAT_TRACE))
  form.exit_flag = 1
  form:Close()
end
function on_btn_quxiao_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
