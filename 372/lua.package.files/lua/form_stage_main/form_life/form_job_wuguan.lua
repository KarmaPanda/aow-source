function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(self)
  change_form_size()
  change_desc_info(self, "ui_jiaoxue_wuguan")
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  form:Close()
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_life\\form_job_wuguan_02")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function change_desc_info(form, info_id)
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText(info_id)
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(nx_widestr(info), -1)
end
