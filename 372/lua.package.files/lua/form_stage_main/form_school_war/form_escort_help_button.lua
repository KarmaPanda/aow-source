function main_form_init(form)
  form.Fixed = true
end
function main_form_open(form)
  form.count_tick = 10
  form.lbl_time.Visible = false
  local gui = nx_value("gui")
  form.Left = gui.Desktop.Width - form.Width
  form.Top = (gui.Desktop.Height - form.Height) * 2 / 10
  dove_pass(form, gui)
end
function dove_pass(form, gui)
  local top_start = form.Top
  local top_end = (gui.Desktop.Height - form.Height) * 5 / 10
  local use_time = 1
  local count_tick = 21
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("DoveMove", form)
    common_execute:AddExecute("DoveMove", form, nx_float(0), nx_float(top_start), nx_float(top_end), nx_float(use_time), nx_float(count_tick))
  end
end
function on_btn_show_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "show_info", "ok")
  form:Close()
end
