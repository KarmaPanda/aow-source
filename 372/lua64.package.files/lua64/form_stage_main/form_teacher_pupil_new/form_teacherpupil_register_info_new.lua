require("util_gui")
require("util_functions")
require("define\\request_type")
require("form_stage_main\\form_teacher_pupil_new\\teacherpupil_define_new")
function on_main_form_init(form)
  form.Fixed = false
  form.shitu_flag = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.redit_remark.Focus = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if form.redit_remark.Size - 1 > 20 then
    local systemcenterinfo = nx_value("SystemCenterInfo")
    if nx_is_valid(systemcenterinfo) then
      systemcenterinfo:ShowSystemCenterInfo(nx_widestr(util_text("ui_shitu_beizhu")), 2)
    end
    form:Close()
    return
  end
  nx_execute("custom_sender", CUSTOM_MSG_FUN, NT_CTS_ASK_REGIST, form.shitu_flag, nx_widestr(form.redit_remark.Text))
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
