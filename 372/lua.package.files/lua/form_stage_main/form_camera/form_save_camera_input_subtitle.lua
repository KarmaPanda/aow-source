function init(form)
  form.Fixed = false
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "camera_subtitle_edit_return", "cancel")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "camera_subtitle_edit_return", "cancel")
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local save_camera_form = nx_value("form_stage_main\\form_camera\\form_save_camera")
  if nx_is_valid(save_camera_form) then
    save_camera_form.subtitle_content = nx_string(form.ipt_subtitle.Text)
    save_camera_form.subtitle_duration = nx_number(form.ipt_duration.Text)
    if form.rbtn_top.Checked then
      save_camera_form.subtitle_toporbottom = 1
    else
      save_camera_form.subtitle_toporbottom = 0
    end
  end
  nx_gen_event(form, "camera_subtitle_edit_return", "ok")
  form:Close()
end
