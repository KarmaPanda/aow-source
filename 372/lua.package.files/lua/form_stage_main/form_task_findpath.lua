function on_main_form_open(form)
  local gui = nx_value("gui")
  gui.Desktop:ToBack(form)
  form.lbl_title.Text = nx_widestr("")
  form.no_need_motion_alpha = true
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  text = gui.TextManager:GetFormatText("ui_task_findpath")
  common_execute:AddExecute("display_literally", form.lbl_title, nx_float(0.3), nx_widestr(text), nx_float(0.3))
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_task_findpath")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.Top = (gui.Desktop.Height - form.Height) / 2 - 180
    if form.Top <= 0 then
      form.Top = 0
    end
    form.Left = (gui.Desktop.Width - form.Width) / 2
  end
end
function on_main_form_close(form)
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  common_execute:RemoveExecute("display_literally", form.lbl_title)
end
